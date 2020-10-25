#!/usr/bin/env groovy

def generate_tfvars(String os_type, String ami, String region, String ansible_user) {
    echo "${os_type}_instance = {\n"
    +"ami = ${ami}\n"
    +"region = ${region}\n"
    +"ansible_user = ${ansible_user}\n"
    +"}"
}