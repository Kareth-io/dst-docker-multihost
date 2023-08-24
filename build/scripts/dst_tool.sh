#!/bin/bash
BIN=/root/dst/bin/dontstarve_dedicated_server_nullrenderer
SERVER_DIR=${CLUSTER_DIR}/${SHARD}

#This script expects a multi server configuration, meaning that it will only boot up a overworld or cave instance, not both. It will not work with multiworld either.

#Network information of the shards should be pre-seeded from the docker environment

dst_start () {
    ${BIN} -persistent_storage_root ${PERSISTENT_STORAGE_ROOT} \
           -conf_dir ${CONF_DIR} -shard ${SHARD} \
           -console -monitor_parent_process $$
}

# Validating files
verify_cluster_token () {
    #Needs to be run before any other config stuff.
    #Just verifies that CLUSTER_TOKEN is set
    if [ -z "${CLUSTER_TOKEN}" ]; then
        echo "No token found, please check that CLUSTER_TOKEN is set"
        exit 1
    else
        if [ ! -s "${CLUSTER_DIR}/cluster_token.txt" ]; then
            echo "${CLUSTER_TOKEN}" >> "${CLUSTER_DIR}/cluster_token.txt"
        fi
    fi
}

update_missing_file () {
    #Copy files from skel dir if missing
    local short_name="$(basename "${1}")"
    cp -v /scripts/skel/${short_name} ${1}
}

check_for_missing_files () {
    #Handle non mod/cluster token files
    local expected_files=("${CLUSTER_DIR}/cluster.ini" \
                          "${SERVER_DIR}/server.ini")

    for fd in ${expected_files[@]}; do
        if [ ! -f "${fd}" ]; then
            update_missing_file ${fd}
        fi
    done
}

adjust_server_configs () {
    local expected_files=("${CLUSTER_DIR}/cluster.ini" \
                          "${SERVER_DIR}/server.ini")
    for fd in ${expected_files[@]}; do
        tmpfile=$(mktemp)
        cp --attributes-only --preserve $fd $tmpfile
        cat $fd | envsubst > $tmpfile && mv $tmpfile $fd
    done
    if [ "${SHARD}" == "Master" ]; then
        echo "is_master = true" >> ${SERVER_DIR}/server.ini
    else
        echo "is_master = false" >> ${SERVER_DIR}/server.ini
    fi
}
copy_vanilla_leveldata () {
    cp -v /scripts/skel/leveldataoverride_${SHARD}.lua ${SERVER_DIR}/leveldataoverride.lua
}
setup_mods () {
   python3 /scripts/mod_tool.py
}

verify_full_config () {
    if [ ! -f /root/dst/saves/first_time_config ]; then
        mkdir -vp ${SERVER_DIR}
        verify_cluster_token
        check_for_missing_files
        adjust_server_configs
        copy_vanilla_leveldata
	    setup_mods
        touch /root/dst/saves/first_time_config
    fi
}

verify_full_config
dst_start
