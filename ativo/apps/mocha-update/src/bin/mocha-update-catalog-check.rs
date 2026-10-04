use mocha_update::update_catalog::{
    classify_updates, read_allowlist, read_catalog, read_installed_state,
};
use std::env;
use std::path::Path;

fn main() {
    if let Err(error) = run() {
        eprintln!("RESULTADO=FALHA");
        eprintln!("ERRO={error}");
        std::process::exit(1);
    }
}

fn run() -> Result<(), String> {
    let args: Vec<String> = env::args().collect();
    if args.len() != 4 && args.len() != 5 {
        return Err(format!(
            "uso: {} CATALOGO ALLOWLIST ESTADO_INSTALADO [ARQUITETURA]",
            args.first()
                .map(String::as_str)
                .unwrap_or("mocha-update-catalog-check")
        ));
    }

    let catalog = read_catalog(Path::new(&args[1]))?;
    let allowlist = read_allowlist(Path::new(&args[2]))?;
    let installed = read_installed_state(Path::new(&args[3]))?;
    let architecture = args.get(4).map(String::as_str).unwrap_or(env::consts::ARCH);
    let decisions = classify_updates(&catalog, &allowlist, &installed, architecture)?;

    println!("RESULTADO=SUCESSO");
    println!("SCHEMA={}", catalog.schema);
    println!("CANAL={}", catalog.channel);
    println!("GERADO_EM={}", catalog.generated_at);
    println!("ARQUITETURA={architecture}");
    println!("ITENS={}", decisions.len());

    for item in decisions {
        println!(
            "ITEM|ID={}|TIPO={}|INSTALADA={}|DISPONIVEL={}|DECISAO={}|BYTES={}|REINICIA_APP={}|REINICIA_SISTEMA={}|ARTEFATO={}",
            item.id,
            item.kind.as_str(),
            item.installed_version.as_deref().unwrap_or("AUSENTE"),
            item.available_version,
            item.decision.as_str(),
            item.size,
            if item.requires_app_restart { "SIM" } else { "NAO" },
            if item.requires_reboot { "SIM" } else { "NAO" },
            item.artifact,
        );
    }

    Ok(())
}
