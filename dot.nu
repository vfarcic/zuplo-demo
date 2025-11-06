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

    main apply dot-ai --host $"dot-ai.($ingress_data.host)" --ingress-class $ingress_data.class

    main print source

}

def "main destroy" [
    provider: string
] {

    main destroy kubernetes $provider

}
