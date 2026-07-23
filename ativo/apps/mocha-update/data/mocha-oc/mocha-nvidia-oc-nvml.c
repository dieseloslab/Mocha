#define _POSIX_C_SOURCE 200809L
#include <dlfcn.h>
#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

typedef int nvmlReturn_t;
typedef struct nvmlDevice_st *nvmlDevice_t;

enum { NVML_SUCCESS = 0 };

static const char *STATE_DIR = "/run/mocha-update";
static const char *STATE_FILE = "/run/mocha-update/mocha-oc-runtime.conf";
static const int TARGET_CORE = 50;
static const int TARGET_MEMORY = 400;

typedef nvmlReturn_t (*fn_nvmlInit_v2)(void);
typedef nvmlReturn_t (*fn_nvmlShutdown)(void);
typedef nvmlReturn_t (*fn_nvmlDeviceGetHandleByIndex_v2)(unsigned int, nvmlDevice_t *);
typedef nvmlReturn_t (*fn_nvmlDeviceGetOffset)(nvmlDevice_t, int *);
typedef nvmlReturn_t (*fn_nvmlDeviceSetOffset)(nvmlDevice_t, int);
typedef nvmlReturn_t (*fn_nvmlDeviceGetMinMaxOffset)(nvmlDevice_t, int *, int *);
typedef const char *(*fn_nvmlErrorString)(nvmlReturn_t);

struct nvml_api {
    void *library;
    fn_nvmlInit_v2 init;
    fn_nvmlShutdown shutdown;
    fn_nvmlDeviceGetHandleByIndex_v2 get_device;
    fn_nvmlDeviceGetOffset get_core;
    fn_nvmlDeviceGetOffset get_memory;
    fn_nvmlDeviceSetOffset set_core;
    fn_nvmlDeviceSetOffset set_memory;
    fn_nvmlDeviceGetMinMaxOffset get_core_range;
    fn_nvmlDeviceGetMinMaxOffset get_memory_range;
    fn_nvmlErrorString error_string;
};

static const char *nvml_error(const struct nvml_api *api, nvmlReturn_t rc) {
    if (api->error_string != NULL) {
        const char *text = api->error_string(rc);
        if (text != NULL && text[0] != '\0') {
            return text;
        }
    }
    return "erro NVML sem descrição";
}

static void *required_symbol(void *library, const char *name) {
    dlerror();
    void *symbol = dlsym(library, name);
    const char *error = dlerror();
    if (error != NULL || symbol == NULL) {
        fprintf(stderr, "ERRO: símbolo NVML obrigatório ausente: %s (%s)\n",
                name, error != NULL ? error : "símbolo nulo");
        return NULL;
    }
    return symbol;
}

static void *optional_symbol(void *library, const char *name) {
    dlerror();
    void *symbol = dlsym(library, name);
    (void)dlerror();
    return symbol;
}

static int load_api(struct nvml_api *api) {
    memset(api, 0, sizeof(*api));
    api->library = dlopen("libnvidia-ml.so.1", RTLD_NOW | RTLD_LOCAL);
    if (api->library == NULL) {
        fprintf(stderr, "ERRO: libnvidia-ml.so.1 não pôde ser aberta: %s\n", dlerror());
        return 1;
    }

#define LOAD_REQUIRED(field, type, symbol_name)                                      \
    do {                                                                              \
        void *symbol_value = required_symbol(api->library, symbol_name);              \
        if (symbol_value == NULL) {                                                    \
            return 1;                                                                 \
        }                                                                             \
        memcpy(&api->field, &symbol_value, sizeof(api->field));                       \
    } while (0)

#define LOAD_OPTIONAL(field, symbol_name)                                             \
    do {                                                                              \
        void *symbol_value = optional_symbol(api->library, symbol_name);              \
        if (symbol_value != NULL) {                                                    \
            memcpy(&api->field, &symbol_value, sizeof(api->field));                   \
        }                                                                             \
    } while (0)

    LOAD_REQUIRED(init, fn_nvmlInit_v2, "nvmlInit_v2");
    LOAD_REQUIRED(shutdown, fn_nvmlShutdown, "nvmlShutdown");
    LOAD_REQUIRED(get_device, fn_nvmlDeviceGetHandleByIndex_v2,
                  "nvmlDeviceGetHandleByIndex_v2");
    LOAD_REQUIRED(get_core, fn_nvmlDeviceGetOffset, "nvmlDeviceGetGpcClkVfOffset");
    LOAD_REQUIRED(get_memory, fn_nvmlDeviceGetOffset, "nvmlDeviceGetMemClkVfOffset");
    LOAD_REQUIRED(set_core, fn_nvmlDeviceSetOffset, "nvmlDeviceSetGpcClkVfOffset");
    LOAD_REQUIRED(set_memory, fn_nvmlDeviceSetOffset, "nvmlDeviceSetMemClkVfOffset");
    LOAD_OPTIONAL(get_core_range, "nvmlDeviceGetGpcClkMinMaxVfOffset");
    LOAD_OPTIONAL(get_memory_range, "nvmlDeviceGetMemClkMinMaxVfOffset");
    LOAD_OPTIONAL(error_string, "nvmlErrorString");

#undef LOAD_REQUIRED
#undef LOAD_OPTIONAL
    return 0;
}

static void unload_api(struct nvml_api *api) {
    if (api->library != NULL) {
        dlclose(api->library);
        api->library = NULL;
    }
}

static int initialize_device(struct nvml_api *api, nvmlDevice_t *device) {
    nvmlReturn_t rc = api->init();
    if (rc != NVML_SUCCESS) {
        fprintf(stderr, "ERRO: nvmlInit_v2 falhou: %s (rc=%d)\n", nvml_error(api, rc), rc);
        return 1;
    }

    rc = api->get_device(0U, device);
    if (rc != NVML_SUCCESS) {
        fprintf(stderr,
                "ERRO: não foi possível obter a GPU NVIDIA de índice 0: %s (rc=%d)\n",
                nvml_error(api, rc), rc);
        (void)api->shutdown();
        return 1;
    }
    return 0;
}

static int query_offsets(const struct nvml_api *api, nvmlDevice_t device,
                         int *core, int *memory) {
    nvmlReturn_t rc = api->get_core(device, core);
    if (rc != NVML_SUCCESS) {
        fprintf(stderr, "ERRO: consulta do offset de core falhou: %s (rc=%d)\n",
                nvml_error(api, rc), rc);
        return 1;
    }

    rc = api->get_memory(device, memory);
    if (rc != NVML_SUCCESS) {
        fprintf(stderr, "ERRO: consulta do offset de memória falhou: %s (rc=%d)\n",
                nvml_error(api, rc), rc);
        return 1;
    }
    return 0;
}

static int check_range(const struct nvml_api *api, nvmlDevice_t device,
                       int core, int memory) {
    int minimum = 0;
    int maximum = 0;
    nvmlReturn_t rc;

    if (api->get_core_range != NULL) {
        rc = api->get_core_range(device, &minimum, &maximum);
        if (rc == NVML_SUCCESS) {
            printf("CORE_OFFSET_MIN=%d\nCORE_OFFSET_MAX=%d\n", minimum, maximum);
            if (core < minimum || core > maximum) {
                fprintf(stderr,
                        "ERRO: offset de core %d fora da faixa NVML [%d,%d]\n",
                        core, minimum, maximum);
                return 1;
            }
        }
    }

    if (api->get_memory_range != NULL) {
        rc = api->get_memory_range(device, &minimum, &maximum);
        if (rc == NVML_SUCCESS) {
            printf("MEMORY_OFFSET_MIN=%d\nMEMORY_OFFSET_MAX=%d\n", minimum, maximum);
            if (memory < minimum || memory > maximum) {
                fprintf(stderr,
                        "ERRO: offset de memória %d fora da faixa NVML [%d,%d]\n",
                        memory, minimum, maximum);
                return 1;
            }
        }
    }
    return 0;
}

static int set_offsets(const struct nvml_api *api, nvmlDevice_t device,
                       int core, int memory) {
    nvmlReturn_t rc = api->set_core(device, core);
    if (rc != NVML_SUCCESS) {
        fprintf(stderr, "ERRO: aplicação do offset de core %d falhou: %s (rc=%d)\n",
                core, nvml_error(api, rc), rc);
        return 1;
    }

    rc = api->set_memory(device, memory);
    if (rc != NVML_SUCCESS) {
        fprintf(stderr,
                "ERRO: aplicação do offset de memória %d falhou: %s (rc=%d)\n",
                memory, nvml_error(api, rc), rc);
        return 1;
    }
    return 0;
}

static int ensure_state_directory(void) {
    if (mkdir(STATE_DIR, 0755) == 0 || errno == EEXIST) {
        return 0;
    }
    fprintf(stderr, "ERRO: não foi possível criar %s: %s\n", STATE_DIR, strerror(errno));
    return 1;
}

static int write_state(int core, int memory) {
    if (ensure_state_directory() != 0) {
        return 1;
    }

    char temporary[PATH_MAX];
    int written = snprintf(temporary, sizeof(temporary), "%s.tmp.%ld",
                           STATE_FILE, (long)getpid());
    if (written < 0 || (size_t)written >= sizeof(temporary)) {
        fprintf(stderr, "ERRO: caminho temporário do estado NVML excedeu o limite\n");
        return 1;
    }

    int fd = open(temporary, O_WRONLY | O_CREAT | O_EXCL | O_CLOEXEC, 0600);
    if (fd < 0) {
        fprintf(stderr, "ERRO: não foi possível criar %s: %s\n",
                temporary, strerror(errno));
        return 1;
    }

    char contents[160];
    written = snprintf(contents, sizeof(contents),
                       "BACKEND=NVML\nCORE=%d\nMEMORY=%d\n", core, memory);
    if (written < 0 || (size_t)written >= sizeof(contents)) {
        fprintf(stderr, "ERRO: estado NVML excedeu o limite interno\n");
        close(fd);
        unlink(temporary);
        return 1;
    }

    ssize_t total = 0;
    while (total < written) {
        ssize_t count = write(fd, contents + total, (size_t)(written - total));
        if (count < 0) {
            if (errno == EINTR) {
                continue;
            }
            fprintf(stderr, "ERRO: gravação de %s falhou: %s\n",
                    temporary, strerror(errno));
            close(fd);
            unlink(temporary);
            return 1;
        }
        total += count;
    }

    if (fsync(fd) != 0) {
        fprintf(stderr, "ERRO: fsync de %s falhou: %s\n", temporary, strerror(errno));
        close(fd);
        unlink(temporary);
        return 1;
    }
    if (close(fd) != 0) {
        fprintf(stderr, "ERRO: fechamento de %s falhou: %s\n", temporary, strerror(errno));
        unlink(temporary);
        return 1;
    }
    if (rename(temporary, STATE_FILE) != 0) {
        fprintf(stderr, "ERRO: instalação de %s falhou: %s\n", STATE_FILE, strerror(errno));
        unlink(temporary);
        return 1;
    }
    return 0;
}

static int parse_state(int *core, int *memory) {
    FILE *stream = fopen(STATE_FILE, "re");
    if (stream == NULL) {
        if (errno == ENOENT) {
            *core = 0;
            *memory = 0;
            return 0;
        }
        fprintf(stderr, "ERRO: leitura de %s falhou: %s\n", STATE_FILE, strerror(errno));
        return 1;
    }

    bool got_core = false;
    bool got_memory = false;
    char line[160];
    while (fgets(line, sizeof(line), stream) != NULL) {
        int value = 0;
        if (sscanf(line, "CORE=%d", &value) == 1) {
            *core = value;
            got_core = true;
        } else if (sscanf(line, "MEMORY=%d", &value) == 1) {
            *memory = value;
            got_memory = true;
        }
    }

    if (ferror(stream)) {
        fprintf(stderr, "ERRO: leitura de %s foi interrompida\n", STATE_FILE);
        fclose(stream);
        return 1;
    }
    fclose(stream);

    if (!got_core || !got_memory) {
        fprintf(stderr, "ERRO: estado NVML incompleto em %s\n", STATE_FILE);
        return 1;
    }
    return 0;
}

static void print_status(int core, int memory) {
    printf("STATUS_CORE_OFFSET=%d\n", core);
    printf("STATUS_MEMORY_TRANSFER_RATE_OFFSET=%d\n", memory);
    printf("STATUS_BACKEND=NVML\n");
    printf("RUNTIME_ACTIVE=%s\n", access(STATE_FILE, F_OK) == 0 ? "true" : "false");
}

static int command_status(const struct nvml_api *api, nvmlDevice_t device) {
    int core = 0;
    int memory = 0;
    if (query_offsets(api, device, &core, &memory) != 0) {
        return 1;
    }
    print_status(core, memory);
    return 0;
}

static int command_start(const struct nvml_api *api, nvmlDevice_t device) {
    int previous_core = 0;
    int previous_memory = 0;
    bool created_state = false;

    if (query_offsets(api, device, &previous_core, &previous_memory) != 0) {
        return 1;
    }
    if (check_range(api, device, TARGET_CORE, TARGET_MEMORY) != 0) {
        return 1;
    }

    if (access(STATE_FILE, F_OK) != 0) {
        if (errno != ENOENT) {
            fprintf(stderr, "ERRO: acesso a %s falhou: %s\n", STATE_FILE, strerror(errno));
            return 1;
        }
        if (write_state(previous_core, previous_memory) != 0) {
            return 1;
        }
        created_state = true;
    }

    if (set_offsets(api, device, TARGET_CORE, TARGET_MEMORY) != 0) {
        (void)set_offsets(api, device, previous_core, previous_memory);
        if (created_state) {
            (void)unlink(STATE_FILE);
        }
        return 1;
    }

    int core = 0;
    int memory = 0;
    if (query_offsets(api, device, &core, &memory) != 0 ||
        core != TARGET_CORE || memory != TARGET_MEMORY) {
        fprintf(stderr,
                "ERRO: NVML não confirmou o perfil Mocha OC: core=%d, memória=%d\n",
                core, memory);
        (void)set_offsets(api, device, previous_core, previous_memory);
        if (created_state) {
            (void)unlink(STATE_FILE);
        }
        return 1;
    }

    print_status(core, memory);
    return 0;
}

static int command_end(const struct nvml_api *api, nvmlDevice_t device) {
    int target_core = 0;
    int target_memory = 0;
    if (parse_state(&target_core, &target_memory) != 0) {
        return 1;
    }

    int current_core = 0;
    int current_memory = 0;
    if (query_offsets(api, device, &current_core, &current_memory) != 0) {
        return 1;
    }

    if (set_offsets(api, device, target_core, target_memory) != 0) {
        (void)set_offsets(api, device, current_core, current_memory);
        return 1;
    }

    int core = 0;
    int memory = 0;
    if (query_offsets(api, device, &core, &memory) != 0 ||
        core != target_core || memory != target_memory) {
        fprintf(stderr,
                "ERRO: NVML não confirmou a restauração: core=%d/%d, memória=%d/%d\n",
                core, target_core, memory, target_memory);
        (void)set_offsets(api, device, current_core, current_memory);
        return 1;
    }

    if (unlink(STATE_FILE) != 0 && errno != ENOENT) {
        fprintf(stderr, "ERRO: não foi possível remover %s: %s\n",
                STATE_FILE, strerror(errno));
        return 1;
    }

    print_status(core, memory);
    return 0;
}

int main(int argc, char **argv) {
    if (argc != 2) {
        fprintf(stderr, "uso: %s {start|end|reset|stop|status}\n", argv[0]);
        return 2;
    }
    if (geteuid() != 0) {
        fprintf(stderr, "ERRO: o helper NVML exige EUID 0\n");
        return 1;
    }

    struct nvml_api api;
    if (load_api(&api) != 0) {
        unload_api(&api);
        return 1;
    }

    nvmlDevice_t device = NULL;
    if (initialize_device(&api, &device) != 0) {
        unload_api(&api);
        return 1;
    }

    int result = 1;
    if (strcmp(argv[1], "status") == 0) {
        result = command_status(&api, device);
    } else if (strcmp(argv[1], "start") == 0) {
        result = command_start(&api, device);
    } else if (strcmp(argv[1], "end") == 0 ||
               strcmp(argv[1], "reset") == 0 ||
               strcmp(argv[1], "stop") == 0) {
        result = command_end(&api, device);
    } else {
        fprintf(stderr, "uso: %s {start|end|reset|stop|status}\n", argv[0]);
        result = 2;
    }

    nvmlReturn_t shutdown_rc = api.shutdown();
    if (shutdown_rc != NVML_SUCCESS && result == 0) {
        fprintf(stderr, "ERRO: nvmlShutdown falhou: %s (rc=%d)\n",
                nvml_error(&api, shutdown_rc), shutdown_rc);
        result = 1;
    }
    unload_api(&api);
    return result;
}
