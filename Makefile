
CFLAGS=-Wall -O2 -g -I.
LDFLAGS=-lpthread

HOSTTYPE=$(shell uname -m)

ifeq ("${HOSTTYPE}","x86_64")
ARCHTYPE=x86
endif
ifeq ("${HOSTTYPE}","i586")
ARCHTYPE=x86
endif
ifeq ("${HOSTTYPE}","i686")
ARCHTYPE=x86
endif
ifeq ("${HOSTTYPE}","powerpc")
ARCHTYPE=ppc
endif
ifeq ("${HOSTTYPE}","ppc64")
ARCHTYPE=ppc
endif

#debug
#CFLAGS=-Wall -g
#CFLAGS+=-DDEBUG_FULL_MB

#Changing the signal number used by the library. SIGUSR1 by default.
#CFLAGS+=-DSIGURCU=SIGUSR2

SRC_DEP=`echo $^ | sed 's/[^ ]*\.h//g'`

all: checkarch test_urcu test_urcu_dynamic_link test_urcu_timing \
	test_rwlock_timing test_rwlock test_perthreadlock_timing \
	test_perthreadlock test_urcu_yield test_urcu_mb \
	urcu-asm.S test_qsbr_timing test_qsbr urcu-asm.o urcutorture \
	urcutorture-yield liburcu.so test_mutex test_looplen test_urcu_gc \
	test_urcu_gc_mb test_qsbr_gc test_qsbr_lgc test_urcu_lgc \
	test_urcu_lgc_mb

checkarch:
ifeq (${ARCHTYPE},)
	@echo "Architecture ${HOSTTYPE} is currently unsupported by liburcu"
	@exit 1
endif

arch.h: arch_${ARCHTYPE}.h
	cp -f arch_${ARCHTYPE}.h arch.h

api.h: api_${ARCHTYPE}.h
	cp -f api_${ARCHTYPE}.h api.h

arch_atomic.h: arch_atomic_${ARCHTYPE}.h
	cp -f arch_atomic_${ARCHTYPE}.h arch_atomic.h

urcu.h: arch.h api.h arch_atomic.h

urcu-qsbr.h: arch.h api.h arch_atomic.h

test_urcu: urcu.o test_urcu.c urcu.h
	$(CC) ${CFLAGS} $(LDFLAGS) -o $@ $(SRC_DEP)

test_looplen: test_looplen.c urcu.h
	$(CC) ${CFLAGS} $(LDFLAGS) -o $@ $(SRC_DEP)

test_urcu_mb: urcu-mb.o test_urcu.c urcu.h
	$(CC) -DDEBUG_FULL_MB ${CFLAGS} $(LDFLAGS) -o $@ $(SRC_DEP)

test_urcu_gc: urcu.o test_urcu_gc.c urcu.h
	$(CC) ${CFLAGS} $(LDFLAGS) -o $@ $(SRC_DEP)

test_urcu_gc_mb: urcu-mb.o test_urcu_gc.c urcu.h
	$(CC) -DDEBUG_FULL_MB ${CFLAGS} $(LDFLAGS) -o $@ $(SRC_DEP)

test_urcu_lgc: urcu.o test_urcu_gc.c urcu.h
	$(CC) -DTEST_LOCAL_GC ${CFLAGS} $(LDFLAGS) -o $@ $(SRC_DEP)

test_urcu_lgc_mb: urcu-mb.o test_urcu_gc.c urcu.h
	$(CC) -DTEST_LOCAL_GC -DDEBUG_FULL_MB ${CFLAGS} $(LDFLAGS) -o $@ $(SRC_DEP)

test_qsbr: urcu-qsbr.o test_qsbr.c urcu-qsbr.h
	$(CC) ${CFLAGS} $(LDFLAGS) -o $@ $(SRC_DEP)

test_qsbr_gc: urcu-qsbr.o test_qsbr_gc.c urcu-qsbr.h
	$(CC) ${CFLAGS} $(LDFLAGS) -o $@ $(SRC_DEP)

test_qsbr_lgc: urcu-qsbr.o test_qsbr_gc.c urcu-qsbr.h
	$(CC) -DTEST_LOCAL_GC ${CFLAGS} $(LDFLAGS) -o $@ $(SRC_DEP)

test_rwlock: urcu.o test_rwlock.c urcu.h
	$(CC) ${CFLAGS} $(LDFLAGS) -o $@ $(SRC_DEP)

test_perthreadlock: urcu.o test_perthreadlock.c urcu.h
	$(CC) ${CFLAGS} $(LDFLAGS) -o $@ $(SRC_DEP)

test_mutex: urcu.o test_mutex.c urcu.h
	$(CC) ${CFLAGS} $(LDFLAGS) -o $@ $(SRC_DEP)

test_urcu_dynamic_link: urcu.o test_urcu.c urcu.h
	$(CC) ${CFLAGS} -DDYNAMIC_LINK_TEST $(LDFLAGS) -o $@ $(SRC_DEP)

test_urcu_yield: urcu-yield.o test_urcu.c urcu.h
	$(CC) -DDEBUG_YIELD ${CFLAGS} $(LDFLAGS) -o $@ $(SRC_DEP)

test_urcu_timing: urcu.o test_urcu_timing.c urcu.h
	$(CC) ${CFLAGS} $(LDFLAGS) -o $@ $(SRC_DEP)

test_qsbr_timing: urcu-qsbr.o test_qsbr_timing.c urcu-qsbr.h
	$(CC) ${CFLAGS} $(LDFLAGS) -o $@ $(SRC_DEP)

test_rwlock_timing: urcu.o test_rwlock_timing.c urcu.h
	$(CC) ${CFLAGS} $(LDFLAGS) -o $@ $(SRC_DEP)

test_perthreadlock_timing: urcu.o test_perthreadlock_timing.c urcu.h
	$(CC) ${CFLAGS} $(LDFLAGS) -o $@ $(SRC_DEP)

urcu.o: urcu.c urcu.h
	$(CC) -fPIC ${CFLAGS} $(LDFLAGS) -c -o $@ $(SRC_DEP)

urcu-mb.o: urcu.c urcu.h
	$(CC) -fPIC -DDEBUG_FULL_MB ${CFLAGS} $(LDFLAGS) -c -o $@ $(SRC_DEP)

urcu-qsbr.o: urcu-qsbr.c urcu-qsbr.h
	$(CC) -fPIC ${CFLAGS} $(LDFLAGS) -c -o $@ $(SRC_DEP)

liburcu.so: urcu.o
	$(CC) -fPIC -shared -o $@ $<

urcu-yield.o: urcu.c urcu.h
	$(CC) -DDEBUG_YIELD ${CFLAGS} $(LDFLAGS) -c -o $@ $(SRC_DEP)

urcu-asm.S: urcu-asm.c urcu.h
	$(CC) ${CFLAGS} -S -o $@ $(SRC_DEP)

urcu-asm.o: urcu-asm.c urcu.h
	$(CC) ${CFLAGS} -c -o $@ $(SRC_DEP)

urcutorture: urcutorture.c urcu.o urcu.h rcutorture.h
	$(CC) ${CFLAGS} $(LDFLAGS) -o $@ $(SRC_DEP)

urcutorture-yield: urcutorture.c urcu-yield.o urcu.h rcutorture.h
	$(CC) -DDEBUG_YIELD ${CFLAGS} $(LDFLAGS) -o $@ $(SRC_DEP)

.PHONY: clean install checkarch

install: liburcu.so
	cp -f liburcu.so /usr/lib/
	cp -f arch.h arch_atomic.h compiler.h urcu.h urcu-static.h /usr/include/

clean:
	rm -f *.o test_urcu test_urcu_dynamic_link test_urcu_timing \
	test_rwlock_timing test_rwlock test_perthreadlock_timing \
	test_perthreadlock test_urcu_yield test_urcu_mb \
	urcu-asm.S test_qsbr_timing test_qsbr urcutorture \
	urcutorture-yield liburcu.so api.h arch.h arch_atomic.h \
	test_mutex test_urcu_gc test_urcu_gc_mb

