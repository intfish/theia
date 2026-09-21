ARG NODE_VERSION=22
ARG THEIA_REF=v1.73.1

FROM node:${NODE_VERSION}-alpine
ARG THEIA_REF

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
RUN git clone --depth=1 -b ${THEIA_REF} https://github.com/eclipse-theia/theia theia
ADD package.json ./theia/custom/package.json
ADD tsconfig.json ./theia/custom/tsconfig.json
ADD webpack.config.js ./theia/custom/webpack.config.js

WORKDIR /home/theia/theia

# use the node headers shipped in the image instead of downloading them from
# unofficial-builds.nodejs.org (node:alpine sets use_prefix_to_find_headers=false).
# this way headers always match the runtime node version.
ENV npm_config_nodedir=/usr/local

# puppeteer's postinstall downloads Chrome into stage 0's cache. skip it.
ENV PUPPETEER_SKIP_DOWNLOAD=true

# node-pty ships a glibc prebuild (prebuilds/linux-x64/pty.node);
# on musl (Alpine) it loads but segfaults in spawn()
# rebuild it from source.
RUN npm install && \
	npm_config_build_from_source=true npm rebuild node-pty && \
	npm run compile && npm run download:plugins
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

# regression guard: node-pty must spawn a pty without segfaulting.
# fails the build if the glibc prebuild sneaks back in.
RUN cd /home/theia/theia && node -e 'const p=require("node-pty");const t=p.spawn("echo",["pty-ok"],{cols:80,rows:24});let out="";t.onData(d=>out+=d);t.onExit(e=>{console.log("node-pty spawn: exitCode="+e.exitCode+" signal="+e.signal+" out="+out.trim());if(e.signal||e.exitCode!==0||out.indexOf("pty-ok")<0)process.exit(1);process.exit(0)});'
RUN test ! -f /home/theia/theia/node_modules/node-pty/prebuilds/linux-x64/pty.node && echo "node-pty: musl build in use (no glibc prebuild)"

WORKDIR /home/theia/theia/custom
USER theia
EXPOSE 3000

ENTRYPOINT ["/entrypoint.sh"]
# ENTRYPOINT ["/bin/sh"]
