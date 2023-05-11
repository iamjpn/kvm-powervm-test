Nested KVM on PowerVM PAPR API testing
======================================

This respository tests the Nested KVM on PowerVM PAPR API using qemu. qemu TCG pseries machine acts as both the hardware and L0. Linux is the L1 and and L2. A second qemu is used inside the L1 to drive KVM starting the L2. The L1 qemu and L2 linux can be unmodified but for simplicy here, we reuse the same code.

This repository combines a buildroot overlay and test scripts to automate building and integrating qemu, kernel and initrd to cover all of L0, L1 and L2 development.

Usage
-----

**Building everything**

1. `git submodule update --init --recursive --depth 10`
2. `make kvm_l1_defconfig`
3. `make`

This will take a long time the first time you do it, then it'll be fine.

**Rebuilding the kernel**

`make linux-rebuild`

Note that if modules are affected by your rebuilt kernel then you'll need to run `make` again.

**Rebuilding the L0 qemu**

`make host-qemu-rebuild`

**Rebuilding the L1 qemu**

`make qemu-l1-rebuild`

The L1 qemu binary will be in `/root`, but it won't be in `/usr/bin` without a `make`.

**Running**

`./run_L1.sh`

Log in with `root`.  You can then run L2 guests (i.e. using the scripts in `/root/tests`)

For automatic running of L1 + L2 via a pexpect:

`./test_L1.sh`

Development workflow
--------------------

**L0 qemu**

1. Make your qemu changes
2. `make host-qemu-rebuild`
3. `./run_L1.sh`

**L1 kernel**

1. Make your kernel changes
2. `make linux-rebuild` (and optionally `make` if necessary for modules)
3. `./run_L1.sh`

**L1 qemu**

1. Make your qemu changes
2. `make qemu-l1-rebuild`
3. `./run_L1.sh` (or, if you already have the L1 running, `scripts/copy_qemu.sh`)

Adding tests
------------

Anything in `overlay/` will be in `/root` in the L1 and L2 guests, so put anything designed to run inside the guests in there.

Adding things to the guest image
--------------------------------

Any desired packages for the guest image should be added to `kvm-on-powervm/configs/kvm_l1_defconfig`.  You'll want to run `make kvm_l1_defconfig && make` after any changes.

Troubleshooting/suggestions
---------------------------

Make an issue or ask in Slack.

Thanks
------
This was originally developed by Russell Currey. Many beers go his way.
