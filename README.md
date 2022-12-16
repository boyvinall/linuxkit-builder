# linuxkit-builder

This repo can be used to build the `linuxkit` cli tool, plus the various different pkg/service images.
It does not currently build the kernel.

## howto

- Clone the repo, and type `make`.  This will build everything, including a sample image
- To run the image that was built, type `make run`
- Once the VM is running, you might want to kill qemu with `docker exec -ti builder pkill qemu` - or, 
  from a getty console, you can run `poweroff`.

## notes

- The makefile knows how to build the linuxkit/alpine image - but, currently, the different pkg images
  reference particular versions of that, so it's a bit pointless building the latest one.

- The container **name** `linuxkit-builder` is used by `linuxkit pkg` to run a buildkit container. Don't
  use this name for any other containers.

- Can't seem to access nginx when running the image in a container, but it does work if you `linuxkit push openstack <...>`
  and run there.
