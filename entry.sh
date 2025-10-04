#!/bin/bash

# Debug

## Steamcmd debugging
if [[ $DEBUG -eq 1 ]] || [[ $DEBUG -eq 3 ]]; then
    STEAMCMD_SPEW="+set_spew_level 4 4"
fi

# Create App Dir
mkdir -p "${STEAMAPPDIR}" || true

# Download Updates
if [[ "$STEAMAPPVALIDATE" -eq 1 ]]; then
    VALIDATE="validate"
else
    VALIDATE=""
fi

## SteamCMD can fail to download
## Retry logic
MAX_ATTEMPTS=3
attempt=0
while [[ $steamcmd_rc != 0 ]] && [[ $attempt -lt $MAX_ATTEMPTS ]]; do
    ((attempt+=1))
    if [[ $attempt -gt 1 ]]; then
        echo "Retrying SteamCMD, attempt ${attempt}"
        # Stale appmanifest data can lead for HTTP 401 errors when requesting old
        # files from SteamPipe CDN
        echo "Removing steamapps (appmanifest data)..."
        rm -rf "${STEAMAPPDIR}/steamapps"
    fi
    eval bash "${STEAMCMDDIR}/steamcmd.sh" "${STEAMCMD_SPEW}"\
                                +force_install_dir "${STEAMAPPDIR}" \
                                +@bClientTryRequestManifestWithoutCode 1 \
				+login anonymous \
				+app_update "${STEAMAPPID}" "${VALIDATE}"\
				+quit
    steamcmd_rc=$?
done

## Exit if steamcmd fails
if [[ $steamcmd_rc != 0 ]]; then
    exit $steamcmd_rc
fi

if [ ! -f "${STEAMAPPDIR}/server_config.cfg" ]; then
    cp "${STEAMAPPDIR}/initial_server_config.cfg" "${STEAMAPPDIR}/server_config.cfg"
fi

echo "Starting Wreckfest Dedicated Server"
cd "${STEAMAPPDIR}"
export DISPLAY=:0
Xvfb $DISPLAY -screen 0 1024x768x16 & sleep 5

eval wine ./Wreckfest.exe -s server_config=server_config.cfg -server_set \
    server_name=${WF_SERVER_NAME} \
    password=${WF_PASSWORD} \
    admin_steam_ids=${WF_ADMINS} \
    owner_disabled=${WF_OWNER_DISABLED} \
    steam_port=${WF_STEAM_PORT} \
    query_port=${WF_QUERY_PORT} \
    game_port=${WF_GAME_PORT} \
    ${WF_ADDITIONAL_ARGS}
