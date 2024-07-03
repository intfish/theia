# intfish/theia

Theia based general purpose IDE base image for various projects.

## Pull

```sh
docker pull ghcr.io/intfish/theia:latest
```

## Build

`docker build -t intfish/theia:dev .`

## Run
#### Example with `THEIA_WORKSPACE`
```
docker run -it --init -p 3000:3000 \
    -v /home/user/projects:/home/workspace \
    -e THEIA_WORKSPACE=/home/workspace/mypro theia-image
```

## Notes
`THEIA_WORKSPACE`- Sets default workspace path.

When you have `.theia` directory with `settings.json` in the root of your project dir, preferences will be loaded automatically.


## Theia extensions development POC

## Run
Mount theia extensions directory to workspace.
```
docker run -it --init -p 3000:3000 \
    -v /theia/extensions:/home/workspace \
    -e THEIA_WORKSPACE=/home/workspace theia-image
```

Edit `/home/theia/package.json`. by adding `"hello-world-test": "file:/home/workspace/hello-world-test"` to dependencies.

Run `yarn && yarn theia build ` in `/home/theia/`.

Refresh browser window and trigger the command "Say hello" via the command palette (F1 => "Say Hello"). A message dialog will pop up saying "Hello World".
