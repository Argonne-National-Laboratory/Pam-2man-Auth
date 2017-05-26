RHEL=/etc/redhat-release

ifeq ($(shell test -e $(RHEL) && echo -n true),true)
  OS_RPM=true
endif

ifeq ($(shell uname -p), x86_64)
  AMD64=true
  X86=false
else ifeq ($(PROCESSOR_ARCHITEW6432),x86)
  X86=true
  AMD64=false
endif

ifeq ($(OS_RPM), $(AMD64))
  libdir=/usr/lib64/security
else ifeq ($(OS_RPM), $(X86))
  libdir=/usr/lib/security
else 
  libdir=/lib/security
endif

sysconfdir=/etc

INSTALL=/usr/bin/install
CC=gcc
RM=/bin/rm
CP=/bin/cp
MKDIR_P=/bin/mkdir -p
RMDIR=/bin/rmdir
ifeq ($(OS_RPM), true)
  SRCDIR=rpm/etc
else
  SRCDIR=etc
endif

LIBRARIES=-lpam -lpam_misc

CFLAGS=-fPIC -O2 -c -g -Wall -Wformat-security -fno-strict-aliasing
LDFLAGS=-fPIC -shared

OBJECTS=2man.o
SHARED_OBJECT=pam_2man.so
SOURCES=2man.c

$(SHARED_OBJECT): $(OBJECTS)
	$(CC) $(LDFLAGS) $^ $(LIBRARIES) -o $@

$(OBJECTS): $(SOURCES)
	$(CC) $(CFLAGS) $(LIBRARIES) $(SOURCES)

clean: 
	$(RM) -f $(OBJECTS) $(SHARED_OBJECT)

install:
	$(MKDIR_P) $(DESTDIR)/$(sysconfdir)/2man/acl
	$(INSTALL) -m 0755 -d $(DESTDIR)/$(libdir)
	$(INSTALL) -m 0644 $(SHARED_OBJECT) /$(libdir)
	$(INSTALL) -m 0644 $(SRCDIR)/2man/2man_group $(sysconfdir)/pam.d
	$(INSTALL) -m 0644 $(SRCDIR)/2man/acl/sudo.acl $(sysconfdir)/2man/acl
        ifeq ($(OS_RPM), true)
	  $(INSTALL) -m 0644 $(SRCDIR)/pam.d/sudo $(sysconfdir)/pam.d
        endif


# use at your own risk
uninstall:
	$(RM) -f $(PAM_LIB_DIR)/$(SHARED_OBJECT)
	$(RM) -f $(sysconfdir)/2man/acl/sudo.acl
	$(RMDIR) $(sysconfdir)/2man/acl
	$(RM) -f $(sysconfdir)/2man/2man_group
	$(RMDIR) $(sysconfdir)/2man
