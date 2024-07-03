FROM node:18-alpine

RUN apk add --no-cache make gcc g++ pkgconfig \
	libsecret-dev python3 py3-setuptools git \
	openssh bash libsecret curl zsh shadow

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

RUN addgroup theia && \
	adduser -G theia -s /bin/zsh -D theia && \
	usermod -aG node theia

WORKDIR /home/theia

COPY package.json ./package.json

RUN yarn set version classic

RUN yarn && \
	NODE_OPTIONS="--max_old_space_size=4096" yarn theia build && \
	yarn theia download:plugins

RUN chmod g+rw /home && \
	mkdir -p /home/workspace && \
	chown -R theia:theia /home/theia && \
	chown -R theia:theia /home/workspace

COPY entrypoint.sh /entrypoint.sh

EXPOSE 3000

USER theia

ENTRYPOINT ["/entrypoint.sh"]
