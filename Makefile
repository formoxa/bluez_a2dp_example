CFLAGS := $(CFLAGS) -O0 -g -DDEBUG -Wall
LDFLAGS := $(LDFLAGS)

all: a2dp-alsa libsbc.a a2dp-buffer

clean:
	-rm -f a2dp-alsa a2dp-buffer
	-rm -f sbc/*.a sbc/*.o

libsbc.a: sbc/libsbc.a

sbc/libsbc.a: sbc/sbc.o sbc/sbc_primitives_armv6.o sbc/sbc_primitives.o \
              sbc/sbc_primitives_iwmmxt.o sbc/sbc_primitives_mmx.o \
              sbc/sbc_primitives_neon.o
	ar rcvs $@ sbc/sbc.o sbc/sbc_primitives_armv6.o sbc/sbc_primitives.o \
              sbc/sbc_primitives_iwmmxt.o sbc/sbc_primitives_mmx.o \
              sbc/sbc_primitives_neon.o
              
%.o: %.c
	$(CC) $(CFLAGS) $(LDFLAGS) -c -o $@ $<

a2dp-alsa: a2dp-alsa.c sbc/libsbc.a
	$(CC) -pthread $(shell pkg-config --cflags dbus-1) $(CFLAGS) $(shell pkg-config --libs dbus-1) $(LDFLAGS) -o $@ $< sbc/libsbc.a

a2dp-buffer: a2dp-buffer.c
	$(CC) -o $@ $<
	
package: clean
	-rm -rf /tmp/a2dp-fossil
	-mkdir -p /tmp/a2dp-fossil
	-cp  -a * /tmp/a2dp-fossil
	-fossil info > /tmp/a2dp-fossil/fossil-version
	-echo Version $(shell date +%F) > /tmp/a2dp-fossil/VERSION
	-rm -f /tmp/a2dp-fossil/auth*
	-rm -f /tmp/a2dp-fossil/bluez-a2dp-sequence*
	-tar -C /tmp -cjvf ../a2dp-alsa-$(shell date +%F).tar.bz2 a2dp-fossil
	-rm -rf /tmp/a2dp-fossil

.PHONY: all clean libsbc.a
