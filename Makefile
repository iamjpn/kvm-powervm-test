.PHONY: _all

_all : all

%:
	$(MAKE) O=$(CURDIR)/output BR2_EXTERNAL=$(CURDIR)/kvm-on-powervm BR2_GLOBAL_PATCH_DIR=$(CURDIR)/kvm-on-powervm/patches -C buildroot $@
