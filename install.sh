#!/bin/bash

HOST_DIR_NAME=${PWD}
#------------------- Env vars ---------------------------------------------
#Number of Cpu for main VM
mainCpu=1
#GB of RAM for main VM
mainRam=1Gb
#GB of HDD for main VM
mainHddGb=10Gb
#--------------------------------------------------------------------------

#Include functions
. $(dirname $0)/script/__functions.sh 

msg_warn "Check prerequisites..."

#Check prerequisites
check_command_exists "multipass"

msg_warn "Creating vm"
multipass launch -m $mainRam -d $mainHddGb -c $mainCpu -n $VM_NAME

msg_info $VM_NAME" is up!"

msg_info "[Task 1]"
msg_warn "Mount host drive with installation scripts"

multipass mount ${HOST_DIR_NAME} $VM_NAME

multipass list

msg_info "[Task 2]"
msg_warn "Configure $VM_NAME"

cat <<EOF >${HOST_DIR_NAME}/config/docker-compose.yml
version: '3.3'
services:
    $REDIS_CONTAINER_NAME:
        container_name: $REDIS_CONTAINER_NAME
        environment:
            - 'REDIS_ARGS=--requirepass $REDIS_PASSWORD'
        ports:
            - '$REDIS_HOST_PORT:$REDIS_CONTAINER_PORT'
            - '$ADMIN_HOST_PORT:$ADMIN_CONTAINER_PORT'
        image: '$REDIS_CONTAINER_IMAGE'
EOF

run_command_on_vm "$VM_NAME" "${HOST_DIR_NAME}/script/_configure.sh ${HOST_DIR_NAME}"

msg_info "[Task 3]"
msg_warn "Start env"
${HOST_DIR_NAME}/start.sh
