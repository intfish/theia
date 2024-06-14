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

RUN apk add --no-cache git openssh bash libsecret curl zsh shadow

ENV HOME=/home/theia \
	SHELL=/bin/zsh \
	THEIA_DEFAULT_PLUGINS=local-dir:/home/theia/plugins

RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

RUN cat <<EOT > "$HOME/.zshrc"
export ZSH="\$HOME/.oh-my-zsh"
ZSH_THEME="gnzh"
DISABLE_AUTO_UPDATE=true
plugins=(git)
source "\$ZSH/oh-my-zsh.sh"
zstyle ':omz:update' mode disabled
EOT

WORKDIR /home/theia

RUN chsh -s /bin/zsh theia

COPY --from=0 --chown=theia:theia /home/theia /home/theia

COPY entrypoint.sh /entrypoint.sh

EXPOSE 3000

USER theia

ENTRYPOINT ["/entrypoint.sh"]
