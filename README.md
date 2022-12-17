# linuxkit-builder

This repo can be used to build the `linuxkit` cli tool, plus the various different pkg/service images.
It does not currently build the kernel.

## Howto

Pre-requisites:

- docker
- docker-compose
- git
- make

Run the following:

```bash
git submodule init
git submodule update
make
```

This will build everything, including a sample image.

- Once the image is built, you can run a VM with `make run`
- Once the VM is running, you might want to kill qemu with `docker exec -ti builder pkill qemu` - or,
  from a getty console, you can run `poweroff`.

## Notes

- The makefile knows how to build the linuxkit/alpine image - but, currently, the different pkg images
  reference particular versions of that, so it's a bit pointless building the latest one.

- The container **name** `linuxkit-builder` is used by `linuxkit pkg` to run a buildkit container. Don't
  use this name for any other containers.

- Can't seem to access nginx when running the image in a container, but it does work if you `linuxkit push openstack <...>`
  and run there.
