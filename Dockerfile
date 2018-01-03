FROM ubuntu:xenial

LABEL maintainer "Pedro Pereira <pedrogoncalvesp.95@gmail.com>"

ARG DEBIAN_FRONTEND=noninteractive
ENV LC_ALL C

RUN apt-get update && apt-get install -y \
	ca-certificates \
	gnupg2 \
	gnupg-curl \
	apt-transport-https \
	&& apt-key adv --fetch-keys https://rspamd.com/apt/gpg.key \
	&& echo "deb https://rspamd.com/apt/ xenial main" > /etc/apt/sources.list.d/rspamd.list \
	&& apt-get update && apt-get install -y rspamd \
	&& rm -rf /var/lib/apt/lists/* \
	&& echo '.include $LOCAL_CONFDIR/local.d/rspamd.conf.local' > /etc/rspamd/rspamd.conf.local \
	&& apt-get autoremove --purge \
	&& apt-get clean \
	&& mkdir -p /run/rspamd \
	&& chown _rspamd:_rspamd /run/rspamd

COPY settings.conf /etc/rspamd/modules.d/settings.conf
#COPY ratelimit.lua /usr/share/rspamd/lua/ratelimit.lua
#COPY lua_util.lua /usr/share/rspamd/lib/lua_util.lua
COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY tini /sbin/tini

COPY custom /etc/rspamd/custom
COPY local.d /etc/rspamd/local.d
COPY lua /etc/rspamd/lua
COPY override.d /etc/rspamd/override.d

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/usr/bin/rspamd", "-f", "-u", "_rspamd", "-g", "_rspamd"]
