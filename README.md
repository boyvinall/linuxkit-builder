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

- Once the image is built
  - you can run a VM from inside the container with `make run`
  - if you have qemu installed locally, you can alternatively run `make run-local`

- Once the VM is running, you can shut it down from a getty console with `poweroff`.

## Notes

- The makefile knows how to build the linuxkit/alpine image - but, currently, the different pkg images
  reference particular versions of that, so it's a bit pointless building the latest one.

- The container **name** `linuxkit-builder` is used by `linuxkit pkg` to run a buildkit container. Don't
  use this name for any other containers.

- There's an nginx running in the VM on port 80, which is exposed by docker-compose on port 8000

- If you don't run the VM with enough RAM then it might fail to decompress the disk fully and files will
  randomly be missing.
