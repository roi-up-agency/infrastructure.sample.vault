#!/usr/bin/env bash

command -v gcloud >/dev/null 2>&1 || { echo >&2 "I require gcloud cli but it's not installed.  Aborting."; exit 1; }

gcloud services enable \
    cloudapis.googleapis.com \
    cloudkms.googleapis.com \
    cloudresourcemanager.googleapis.com \
    cloudshell.googleapis.com \
    container.googleapis.com \
    containerregistry.googleapis.com \
    iam.googleapis.com