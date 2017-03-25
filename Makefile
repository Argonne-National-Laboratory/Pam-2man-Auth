libdir=/lib/security
sysconfdir=/etc

INSTALL=/usr/bin/install
CC=gcc
RM=/bin/rm
CP=/bin/cp
MKDIR_P=/bin/mkdir -p
RMDIR=/bin/rmdir

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
	$(INSTALL) -m 0644 $(SHARED_OBJECT) $(DESTDIR)/$(libdir)
	$(INSTALL) -m 0644 etc/2man/2man_group $(DESTDIR)/$(sysconfdir)/2man
	$(INSTALL) -m 0644 etc/2man/acl/sudo.acl $(DESTDIR)/$(sysconfdir)/2man/acl


# use at your own risk
uninstall:
	$(RM) -f $(PAM_LIB_DIR)/$(SHARED_OBJECT)
	$(RM) -f $(sysconfdir)/2man/acl/sudo.acl
	$(RMDIR) $(sysconfdir)/2man/acl
	$(RM) -f $(sysconfdir)/2man/2man_group
	$(RMDIR) $(sysconfdir)/2man
