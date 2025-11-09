#!/usr/bin/env nu

source scripts/kubernetes.nu
source scripts/common.nu
source scripts/dot-ai.nu
source scripts/ingress.nu

def main [] {}

def "main setup" [] {
    
    rm --force .env

    let provider = main get provider --providers ["aws" "azure" "google"]

    main create kubernetes $provider

    let ingress_data = main apply ingress --provider $provider

    main apply dot-ai --host $"dot-ai.($ingress_data.host)" --ingress-class $ingress_data.class --version "0.139.0"

    open routes.oas.json
        | upsert servers.0.url $"http://dot-ai.($ingress_data.host)"
        | save --force routes.oas.json

    open .mcp.json
        | upsert mcpServers."dot-ai".url $"http://dot-ai.($ingress_data.host)"
        | save --force .mcp.json

    main print source

    start https://portal.zuplo.com

    print $"
Please register at (ansi yellow_bold)https://portal.zuplo.com(ansi reset)
"

}

def "main destroy" [
    provider: string
] {

    main destroy kubernetes $provider

}
