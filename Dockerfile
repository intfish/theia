ARG NODE_VERSION=18

FROM node:${NODE_VERSION}-alpine

RUN apk add --no-cache make gcc g++ pkgconfig libsecret-dev python3 py3-setuptools

WORKDIR /home/theia
ADD package.json ./package.json

RUN yarn set version classic

RUN yarn && \
	NODE_OPTIONS="--max_old_space_size=4096" yarn theia build && \
	yarn theia download:plugins && \
	yarn --production && \
	yarn autoclean --init && \
	echo *.ts >> .yarnclean && \
	echo *.ts.map >> .yarnclean && \
	echo *.spec.* >> .yarnclean && \
	yarn autoclean  --force && \
	yarn cache clean --verbose

FROM node:${NODE_VERSION}-alpine

RUN addgroup theia && \
	adduser -G theia -s /bin/sh -D theia;

RUN chmod g+rw /home && \
	mkdir -p /home/workspace && \
	chown -R theia:theia /home/theia && \
	chown -R theia:theia /home/workspace;

RUN apk add --no-cache git openssh bash libsecret

ENV HOME /home/theia

WORKDIR /home/theia

COPY --from=0 --chown=theia:theia /home/theia /home/theia
COPY entrypoint.sh /entrypoint.sh

EXPOSE 3000

ENV SHELL=/bin/bash \
	THEIA_DEFAULT_PLUGINS=local-dir:/home/theia/plugins

USER theia

ENTRYPOINT ["/entrypoint.sh"]
