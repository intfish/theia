# Theia

## Build

`docker build -t theia-image .`

## Run
#### Example with `THEIA_WORKSPACE`
```
docker run -it --init -p 3000:3000 \
    -v /home/user/projects:/home/workspace \
    -e THEIA_WORKSPACE=/home/workspace/mypro theia-image
```

## Notes
`THEIA_WORKSPACE`- Sets default workspace path.

When you have `.theia` folder with `settings.json` in the root of your project dir, preferences will be loaded automatically.
