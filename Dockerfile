ARG NODE_VERSION=22

FROM node:${NODE_VERSION}-alpine

RUN apk add --no-cache \
	git \
	gcc \
	g++ \
	make \
	libsecret-dev \
	libx11-dev \
	libxkbfile-dev \
	pkgconfig \
	python3 \
	py3-setuptools

WORKDIR /home/theia
RUN git clone --depth=1 https://github.com/eclipse-theia/theia theia
ADD package.json ./theia/custom/package.json
ADD tsconfig.json ./theia/custom/tsconfig.json
ADD webpack.config.js ./theia/custom/webpack.config.js

WORKDIR /home/theia/theia

RUN npm install && npm run compile && npm run download:plugins
RUN cd custom && npm run build:production


FROM node:${NODE_VERSION}-alpine

RUN deluser --remove-home node \
	&& addgroup -S node -g 2000 \
	&& adduser -S -G node -u 2000 node

RUN addgroup theia && \
	adduser -G theia -s /bin/sh -D theia;

RUN mkdir -p /home/workspace && \
	chown -R node:node /home/theia && \
	chown -R theia:theia /home/workspace;

RUN apk add --no-cache git openssh bash libsecret curl zsh shadow

ENV HOME=/home/theia \
	SHELL=/bin/zsh \
	THEIA_DEFAULT_PLUGINS=local-dir:/home/theia/theia/plugins

ENV THEIA_WORKSPACE=/home/workspace

RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

RUN cat <<EOT > "$HOME/.zshrc"
export ZSH="\$HOME/.oh-my-zsh"
ZSH_THEME="gnzh"
DISABLE_AUTO_UPDATE=true
plugins=(git)
source "\$ZSH/oh-my-zsh.sh"
zstyle ':omz:update' mode disabled
EOT

RUN chsh -s /bin/zsh theia
COPY entrypoint.sh /entrypoint.sh

COPY --from=0 /home/theia/theia /home/theia/theia
RUN chmod -R a+r /home/theia/theia && \
	mkdir -p /home/theia/.theia && chown theia:theia /home/theia/.theia

WORKDIR /home/theia/theia/custom
USER theia
EXPOSE 3000

ENTRYPOINT ["/entrypoint.sh"]
# ENTRYPOINT ["/bin/sh"]
