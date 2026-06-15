# some-pnpm-docker-image
debian based pnpm docker image using fish as shell with options as ssh, vim, emacs, just for fun, as always uses npm with protection :)

the default user is `node`

## build
build example using podman
```fish
podman build . \
  --build-arg NODE_PASSWORD=npm --build-arg VIM=1 --build-arg SSH=1 \
  -t somepnpmdockerimage:latest
```
### options
setting `NODE_PASSWORD` to `null`'ll not define a password for the user
- bool VIM=0
- bool EMACS=0
- bool SSH=0
## running
running with podman (ssh enabled)
```fish
podman run --name mypnpmcontainer \
  -p 6969:6969 -p 6767:22 -t \
  localhost/somepnpmdockerimage:latest && \
podman start mypnpmcontainer
```
I had to use -t,--tty cuz I was getting connection refused otherwise, so the first run enables sshd, but if you run without -t you should probably get a message that you have enabled sshd but it happens to not work, if so, you should just start and exec the container for it to run fine.
