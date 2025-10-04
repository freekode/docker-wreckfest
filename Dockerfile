# BUILD STAGE

FROM cm2network/steamcmd:root-bookworm AS build_stage

LABEL maintainer="iam@freekode.org"

ENV STEAMAPPID=361580
ENV STEAMAPP=wreckfest
ENV STEAMAPPDIR="${HOMEDIR}/${STEAMAPP}-dedicated"
ENV STEAMAPPVALIDATE=0

COPY entry.sh "${HOMEDIR}/entry.sh"

RUN set -x \
	# Install, update & upgrade packages
	&& apt-get update \
	&& apt-get install -y --no-install-recommends --no-install-suggests \
		wget \
		ca-certificates \
		lib32z1 \
                simpleproxy \
                libicu-dev \
                unzip \
		jq \
	&& mkdir -p "${STEAMAPPDIR}" \
	# Add entry script
	&& chmod +x "${HOMEDIR}/entry.sh" \
	&& chown -R "${USER}:${USER}" "${HOMEDIR}/entry.sh" "${STEAMAPPDIR}" \
	# Clean up
        && apt-get clean \
        && find /var/lib/apt/lists/ -type f -delete

RUN set -x \
        # && add-apt-repository multiverse \
        && dpkg --add-architecture i386 \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends --no-install-suggests \
		wine \
                wine32:i386 \
                xvfb 


# BASE

FROM build_stage AS bookworm-base

ENV WF_SERVER_NAME="wreckfest private server" \
    WF_PASSWORD="password" \
    WF_ADMINS="" \
    WF_OWNER_DISABLED=1 \
    WF_STEAM_PORT=27015 \
    WF_QUERY_PORT=27016 \
    WF_GAME_PORT=33540

# Set permissions on STEAMAPPDIR
#   Permissions may need to be reset if persistent volume mounted
RUN set -x \
        && chown -R "${USER}:${USER}" "${STEAMAPPDIR}" \
        && chmod 0777 "${STEAMAPPDIR}"

# Switch to user
USER ${USER}

WORKDIR ${HOMEDIR}

CMD ["bash", "entry.sh"]

# Expose ports
