plus_sec := $(call as-instr,.arch_extension sec,+sec)

AFLAGS_bridge_pub2sec.o +=-Wa,-march=armv7-a$(plus_sec)

ifeq ($(CONFIG_SECURITY_MIDDLEWARE_COMPONENT),y)
obj-$(CONFIG_ARCH_OMAP3)	+= omap3/
obj-$(CONFIG_ARCH_OMAP4)	+= omap4/
endif


