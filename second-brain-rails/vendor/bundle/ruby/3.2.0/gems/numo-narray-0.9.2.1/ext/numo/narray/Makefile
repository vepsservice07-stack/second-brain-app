
SHELL = /bin/sh

# V=0 quiet, V=1 verbose.  other values don't work.
V = 0
V0 = $(V:0=)
Q1 = $(V:1=)
Q = $(Q1:0=@)
ECHO1 = $(V:1=@ :)
ECHO = $(ECHO1:0=@ echo)
NULLCMD = :

#### Start of system configuration section. ####

srcdir = .
topdir = /usr/include/ruby-3.2.0
hdrdir = $(topdir)
arch_hdrdir = /usr/include/x86_64-linux-gnu/ruby-3.2.0
PATH_SEPARATOR = :
VPATH = $(srcdir):$(arch_hdrdir)/ruby:$(hdrdir)/ruby
prefix = $(DESTDIR)/usr
rubysitearchprefix = $(sitearchlibdir)/$(RUBY_BASE_NAME)
rubyarchprefix = $(archlibdir)/$(RUBY_BASE_NAME)
rubylibprefix = $(libdir)/$(RUBY_BASE_NAME)
exec_prefix = $(prefix)
vendorarchhdrdir = $(sitearchincludedir)/$(RUBY_VERSION_NAME)/vendor_ruby
sitearchhdrdir = $(sitearchincludedir)/$(RUBY_VERSION_NAME)/site_ruby
rubyarchhdrdir = $(archincludedir)/$(RUBY_VERSION_NAME)
vendorhdrdir = $(rubyhdrdir)/vendor_ruby
sitehdrdir = $(rubyhdrdir)/site_ruby
rubyhdrdir = $(includedir)/$(RUBY_VERSION_NAME)
vendorarchdir = $(rubysitearchprefix)/vendor_ruby/$(ruby_version)
vendorlibdir = $(vendordir)/$(ruby_version)
vendordir = $(rubylibprefix)/vendor_ruby
sitearchdir = $(DESTDIR)/usr/local/lib/x86_64-linux-gnu/site_ruby
sitelibdir = $(sitedir)/$(ruby_version)
sitedir = $(DESTDIR)/usr/local/lib/site_ruby
rubyarchdir = $(rubyarchprefix)/$(ruby_version)
rubylibdir = $(rubylibprefix)/$(ruby_version)
sitearchincludedir = $(includedir)/$(sitearch)
archincludedir = $(includedir)/$(arch)
sitearchlibdir = $(libdir)/$(sitearch)
archlibdir = $(libdir)/$(arch)
ridir = $(datarootdir)/$(RI_BASE_NAME)
mandir = $(datarootdir)/man
localedir = $(datarootdir)/locale
libdir = $(exec_prefix)/lib
psdir = $(docdir)
pdfdir = $(docdir)
dvidir = $(docdir)
htmldir = $(docdir)
infodir = $(datarootdir)/info
docdir = $(datarootdir)/doc/$(PACKAGE)
oldincludedir = $(DESTDIR)/usr/include
includedir = $(prefix)/include
runstatedir = $(DESTDIR)/var/run
localstatedir = $(DESTDIR)/var
sharedstatedir = $(prefix)/com
sysconfdir = $(DESTDIR)/etc
datadir = $(datarootdir)
datarootdir = $(prefix)/share
libexecdir = $(exec_prefix)/libexec
sbindir = $(exec_prefix)/sbin
bindir = $(exec_prefix)/bin
archdir = $(rubyarchdir)


CC_WRAPPER = 
CC = x86_64-linux-gnu-gcc
CXX = x86_64-linux-gnu-g++
LIBRUBY = $(LIBRUBY_SO)
LIBRUBY_A = lib$(RUBY_SO_NAME)-static.a
LIBRUBYARG_SHARED = -l$(RUBY_SO_NAME)
LIBRUBYARG_STATIC = -l$(RUBY_SO_NAME)-static $(MAINLIBS)
empty =
OUTFLAG = -o $(empty)
COUTFLAG = -o $(empty)
CSRCFLAG = $(empty)

RUBY_EXTCONF_H = /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/numo/extconf.h
cflags   = $(optflags) $(debugflags) $(warnflags)
cxxflags = 
optflags = -O3 -fno-fast-math
debugflags = -ggdb3
warnflags = -Wall -Wextra -Wdeprecated-declarations -Wdiv-by-zero -Wduplicated-cond -Wimplicit-function-declaration -Wimplicit-int -Wmisleading-indentation -Wpointer-arith -Wwrite-strings -Wold-style-definition -Wimplicit-fallthrough=0 -Wmissing-noreturn -Wno-cast-function-type -Wno-constant-logical-operand -Wno-long-long -Wno-missing-field-initializers -Wno-overlength-strings -Wno-packed-bitfield-compat -Wno-parentheses-equality -Wno-self-assign -Wno-tautological-compare -Wno-unused-parameter -Wno-unused-value -Wsuggest-attribute=format -Wsuggest-attribute=noreturn -Wunused-variable -Wundef
cppflags = 
CCDLFLAGS = -fPIC
CFLAGS   = $(CCDLFLAGS) -g -O2 -fno-omit-frame-pointer -mno-omit-leaf-frame-pointer -ffile-prefix-map=BUILDDIR=. -fstack-protector-strong -fstack-clash-protection -Wformat -Werror=format-security -fcf-protection -fdebug-prefix-map=BUILDDIR=/usr/src/ruby3.2-3.2.3-1ubuntu0.24.04.6 -fPIC $(ARCH_FLAG)
INCFLAGS = -I. -Itypes -I$(arch_hdrdir) -I$(hdrdir)/ruby/backward -I$(hdrdir) -I$(srcdir)
DEFS     = 
CPPFLAGS = -DRUBY_EXTCONF_H=\"$(RUBY_EXTCONF_H)\" -Wdate-time -D_FORTIFY_SOURCE=3 $(DEFS) $(cppflags)
CXXFLAGS = $(CCDLFLAGS) -g -O2 -fno-omit-frame-pointer -mno-omit-leaf-frame-pointer -ffile-prefix-map=BUILDDIR=. -fstack-protector-strong -fstack-clash-protection -Wformat -Werror=format-security -fcf-protection -fdebug-prefix-map=BUILDDIR=/usr/src/ruby3.2-3.2.3-1ubuntu0.24.04.6 $(ARCH_FLAG)
ldflags  = -L. -Wl,-Bsymbolic-functions -Wl,-z,relro -Wl,-z,now -fstack-protector-strong -rdynamic -Wl,-export-dynamic -Wl,--no-as-needed
dldflags = -Wl,-Bsymbolic-functions -Wl,-z,relro -Wl,-z,now 
ARCH_FLAG = 
DLDFLAGS = $(ldflags) $(dldflags) $(ARCH_FLAG)
LDSHARED = $(CC) -shared
LDSHAREDXX = $(CXX) -shared
AR = x86_64-linux-gnu-gcc-ar
EXEEXT = 

RUBY_INSTALL_NAME = $(RUBY_BASE_NAME)3.2
RUBY_SO_NAME = ruby-3.2
RUBYW_INSTALL_NAME = 
RUBY_VERSION_NAME = $(RUBY_BASE_NAME)-$(ruby_version)
RUBYW_BASE_NAME = rubyw
RUBY_BASE_NAME = ruby

arch = x86_64-linux-gnu
sitearch = $(arch)
ruby_version = 3.2.0
ruby = $(bindir)/$(RUBY_BASE_NAME)3.2
RUBY = $(ruby)
BUILTRUBY = $(bindir)/$(RUBY_BASE_NAME)3.2
ruby_headers = $(hdrdir)/ruby.h $(hdrdir)/ruby/backward.h $(hdrdir)/ruby/ruby.h $(hdrdir)/ruby/defines.h $(hdrdir)/ruby/missing.h $(hdrdir)/ruby/intern.h $(hdrdir)/ruby/st.h $(hdrdir)/ruby/subst.h $(arch_hdrdir)/ruby/config.h $(RUBY_EXTCONF_H)

RM = rm -f
RM_RF = rm -fr
RMDIRS = rmdir --ignore-fail-on-non-empty -p
MAKEDIRS = /bin/mkdir -p
INSTALL = /usr/bin/install -c
INSTALL_PROG = $(INSTALL) -m 0755
INSTALL_DATA = $(INSTALL) -m 644
COPY = cp
TOUCH = exit >

#### End of system configuration section. ####

preload = 
libpath = . $(archlibdir)
LIBPATH =  -L. -L$(archlibdir)
DEFFILE = 

CLEANFILES = mkmf.log
DISTCLEANFILES = 
DISTCLEANDIRS = 

extout = 
extout_prefix = 
target_prefix = /numo
LOCAL_LIBS = 
LIBS = $(LIBRUBYARG_SHARED)  -lm -lpthread  -lc
ORIG_SRCS = SFMT.c array.c data.c index.c kwargs.c math.c narray.c ndloop.c rand.c step.c struct.c
SRCS = $(ORIG_SRCS) narray.c array.c step.c index.c ndloop.c data.c t_bit.c t_int8.c t_int16.c t_int32.c t_int64.c t_uint8.c t_uint16.c t_uint32.c t_uint64.c t_sfloat.c t_dfloat.c t_scomplex.c t_dcomplex.c t_robject.c math.c SFMT.c struct.c rand.c
OBJS = SFMT.o array.o data.o index.o math.o narray.o ndloop.o rand.o step.o struct.o t_bit.o t_dcomplex.o t_dfloat.o t_int16.o t_int32.o t_int64.o t_int8.o t_robject.o t_scomplex.o t_sfloat.o t_uint16.o t_uint32.o t_uint64.o t_uint8.o
HDRS = $(srcdir)/SFMT-params.h $(srcdir)/SFMT-params19937.h $(srcdir)/SFMT.h
LOCAL_HDRS = 
TARGET = narray
TARGET_NAME = narray
TARGET_ENTRY = Init_$(TARGET_NAME)
DLLIB = $(TARGET).so
EXTSTATIC = 
STATIC_LIB = 

TIMESTAMP_DIR = .
BINDIR        = $(bindir)
RUBYCOMMONDIR = $(sitedir)$(target_prefix)
RUBYLIBDIR    = $(sitelibdir)$(target_prefix)
RUBYARCHDIR   = $(sitearchdir)$(target_prefix)
HDRDIR        = $(sitehdrdir)$(target_prefix)
ARCHHDRDIR    = $(sitearchhdrdir)$(target_prefix)
TARGET_SO_DIR =
TARGET_SO     = $(TARGET_SO_DIR)$(DLLIB)
CLEANLIBS     = $(TARGET_SO) false
CLEANOBJS     = $(OBJS) *.bak
TARGET_SO_DIR_TIMESTAMP = $(TIMESTAMP_DIR)/.sitearchdir.-.numo.time

all:    $(DLLIB)
static: $(STATIC_LIB)
.PHONY: all install static install-so install-rb
.PHONY: clean clean-so clean-static clean-rb

clean-static::
clean-rb-default::
clean-rb::
clean-so::
clean: clean-so clean-static clean-rb-default clean-rb
		-$(Q)$(RM_RF) $(CLEANLIBS) $(CLEANOBJS) $(CLEANFILES) .*.time

distclean-rb-default::
distclean-rb::
distclean-so::
distclean-static::
distclean: clean distclean-so distclean-static distclean-rb-default distclean-rb
		-$(Q)$(RM) Makefile $(RUBY_EXTCONF_H) conftest.* mkmf.log
		-$(Q)$(RM) core ruby$(EXEEXT) *~ $(DISTCLEANFILES)
		-$(Q)$(RMDIRS) $(DISTCLEANDIRS) 2> /dev/null || true

realclean: distclean
install: install-so install-rb

install-so: $(DLLIB) $(TARGET_SO_DIR_TIMESTAMP)
	$(INSTALL_PROG) $(DLLIB) $(RUBYARCHDIR)
clean-static::
	-$(Q)$(RM) $(STATIC_LIB)
install-rb: pre-install-rb do-install-rb install-rb-default
install-rb-default: pre-install-rb-default do-install-rb-default
pre-install-rb: Makefile
pre-install-rb-default: Makefile
do-install-rb:
do-install-rb-default:
pre-install-rb-default:
	@$(NULLCMD)
pre-install-rb: $(TIMESTAMP_DIR)/.sitearchdir.-.numo.-.numo.time
do-install-rb: $(RUBYARCHDIR)/numo/compat.h
$(RUBYARCHDIR)/numo/compat.h: $(srcdir)/numo/compat.h $(TIMESTAMP_DIR)/.sitearchdir.-.numo.-.numo.time
	$(Q) $(INSTALL_DATA) $(srcdir)/numo/compat.h $(@D)
do-install-rb: $(RUBYARCHDIR)/numo/intern.h
$(RUBYARCHDIR)/numo/intern.h: $(srcdir)/numo/intern.h $(TIMESTAMP_DIR)/.sitearchdir.-.numo.-.numo.time
	$(Q) $(INSTALL_DATA) $(srcdir)/numo/intern.h $(@D)
do-install-rb: $(RUBYARCHDIR)/numo/narray.h
$(RUBYARCHDIR)/numo/narray.h: $(srcdir)/numo/narray.h $(TIMESTAMP_DIR)/.sitearchdir.-.numo.-.numo.time
	$(Q) $(INSTALL_DATA) $(srcdir)/numo/narray.h $(@D)
do-install-rb: $(RUBYARCHDIR)/numo/ndloop.h
$(RUBYARCHDIR)/numo/ndloop.h: $(srcdir)/numo/ndloop.h $(TIMESTAMP_DIR)/.sitearchdir.-.numo.-.numo.time
	$(Q) $(INSTALL_DATA) $(srcdir)/numo/ndloop.h $(@D)
do-install-rb: $(RUBYARCHDIR)/numo/template.h
$(RUBYARCHDIR)/numo/template.h: $(srcdir)/numo/template.h $(TIMESTAMP_DIR)/.sitearchdir.-.numo.-.numo.time
	$(Q) $(INSTALL_DATA) $(srcdir)/numo/template.h $(@D)
do-install-rb: $(RUBYARCHDIR)/numo/extconf.h
$(RUBYARCHDIR)/numo/extconf.h: $(srcdir)/numo/extconf.h $(TIMESTAMP_DIR)/.sitearchdir.-.numo.-.numo.time
	$(Q) $(INSTALL_DATA) $(srcdir)/numo/extconf.h $(@D)
pre-install-rb: $(TIMESTAMP_DIR)/.sitearchdir.-.numo.-.numo.-.types.time
do-install-rb: $(RUBYARCHDIR)/numo/types/bit.h
$(RUBYARCHDIR)/numo/types/bit.h: $(srcdir)/numo/types/bit.h $(TIMESTAMP_DIR)/.sitearchdir.-.numo.-.numo.-.types.time
	$(Q) $(INSTALL_DATA) $(srcdir)/numo/types/bit.h $(@D)
do-install-rb: $(RUBYARCHDIR)/numo/types/complex.h
$(RUBYARCHDIR)/numo/types/complex.h: $(srcdir)/numo/types/complex.h $(TIMESTAMP_DIR)/.sitearchdir.-.numo.-.numo.-.types.time
	$(Q) $(INSTALL_DATA) $(srcdir)/numo/types/complex.h $(@D)
do-install-rb: $(RUBYARCHDIR)/numo/types/complex_macro.h
$(RUBYARCHDIR)/numo/types/complex_macro.h: $(srcdir)/numo/types/complex_macro.h $(TIMESTAMP_DIR)/.sitearchdir.-.numo.-.numo.-.types.time
	$(Q) $(INSTALL_DATA) $(srcdir)/numo/types/complex_macro.h $(@D)
do-install-rb: $(RUBYARCHDIR)/numo/types/dcomplex.h
$(RUBYARCHDIR)/numo/types/dcomplex.h: $(srcdir)/numo/types/dcomplex.h $(TIMESTAMP_DIR)/.sitearchdir.-.numo.-.numo.-.types.time
	$(Q) $(INSTALL_DATA) $(srcdir)/numo/types/dcomplex.h $(@D)
do-install-rb: $(RUBYARCHDIR)/numo/types/dfloat.h
$(RUBYARCHDIR)/numo/types/dfloat.h: $(srcdir)/numo/types/dfloat.h $(TIMESTAMP_DIR)/.sitearchdir.-.numo.-.numo.-.types.time
	$(Q) $(INSTALL_DATA) $(srcdir)/numo/types/dfloat.h $(@D)
do-install-rb: $(RUBYARCHDIR)/numo/types/float_def.h
$(RUBYARCHDIR)/numo/types/float_def.h: $(srcdir)/numo/types/float_def.h $(TIMESTAMP_DIR)/.sitearchdir.-.numo.-.numo.-.types.time
	$(Q) $(INSTALL_DATA) $(srcdir)/numo/types/float_def.h $(@D)
do-install-rb: $(RUBYARCHDIR)/numo/types/float_macro.h
$(RUBYARCHDIR)/numo/types/float_macro.h: $(srcdir)/numo/types/float_macro.h $(TIMESTAMP_DIR)/.sitearchdir.-.numo.-.numo.-.types.time
	$(Q) $(INSTALL_DATA) $(srcdir)/numo/types/float_macro.h $(@D)
do-install-rb: $(RUBYARCHDIR)/numo/types/int16.h
$(RUBYARCHDIR)/numo/types/int16.h: $(srcdir)/numo/types/int16.h $(TIMESTAMP_DIR)/.sitearchdir.-.numo.-.numo.-.types.time
	$(Q) $(INSTALL_DATA) $(srcdir)/numo/types/int16.h $(@D)
do-install-rb: $(RUBYARCHDIR)/numo/types/int32.h
$(RUBYARCHDIR)/numo/types/int32.h: $(srcdir)/numo/types/int32.h $(TIMESTAMP_DIR)/.sitearchdir.-.numo.-.numo.-.types.time
	$(Q) $(INSTALL_DATA) $(srcdir)/numo/types/int32.h $(@D)
do-install-rb: $(RUBYARCHDIR)/numo/types/int64.h
$(RUBYARCHDIR)/numo/types/int64.h: $(srcdir)/numo/types/int64.h $(TIMESTAMP_DIR)/.sitearchdir.-.numo.-.numo.-.types.time
	$(Q) $(INSTALL_DATA) $(srcdir)/numo/types/int64.h $(@D)
do-install-rb: $(RUBYARCHDIR)/numo/types/int8.h
$(RUBYARCHDIR)/numo/types/int8.h: $(srcdir)/numo/types/int8.h $(TIMESTAMP_DIR)/.sitearchdir.-.numo.-.numo.-.types.time
	$(Q) $(INSTALL_DATA) $(srcdir)/numo/types/int8.h $(@D)
do-install-rb: $(RUBYARCHDIR)/numo/types/int_macro.h
$(RUBYARCHDIR)/numo/types/int_macro.h: $(srcdir)/numo/types/int_macro.h $(TIMESTAMP_DIR)/.sitearchdir.-.numo.-.numo.-.types.time
	$(Q) $(INSTALL_DATA) $(srcdir)/numo/types/int_macro.h $(@D)
do-install-rb: $(RUBYARCHDIR)/numo/types/real_accum.h
$(RUBYARCHDIR)/numo/types/real_accum.h: $(srcdir)/numo/types/real_accum.h $(TIMESTAMP_DIR)/.sitearchdir.-.numo.-.numo.-.types.time
	$(Q) $(INSTALL_DATA) $(srcdir)/numo/types/real_accum.h $(@D)
do-install-rb: $(RUBYARCHDIR)/numo/types/robj_macro.h
$(RUBYARCHDIR)/numo/types/robj_macro.h: $(srcdir)/numo/types/robj_macro.h $(TIMESTAMP_DIR)/.sitearchdir.-.numo.-.numo.-.types.time
	$(Q) $(INSTALL_DATA) $(srcdir)/numo/types/robj_macro.h $(@D)
do-install-rb: $(RUBYARCHDIR)/numo/types/robject.h
$(RUBYARCHDIR)/numo/types/robject.h: $(srcdir)/numo/types/robject.h $(TIMESTAMP_DIR)/.sitearchdir.-.numo.-.numo.-.types.time
	$(Q) $(INSTALL_DATA) $(srcdir)/numo/types/robject.h $(@D)
do-install-rb: $(RUBYARCHDIR)/numo/types/scomplex.h
$(RUBYARCHDIR)/numo/types/scomplex.h: $(srcdir)/numo/types/scomplex.h $(TIMESTAMP_DIR)/.sitearchdir.-.numo.-.numo.-.types.time
	$(Q) $(INSTALL_DATA) $(srcdir)/numo/types/scomplex.h $(@D)
do-install-rb: $(RUBYARCHDIR)/numo/types/sfloat.h
$(RUBYARCHDIR)/numo/types/sfloat.h: $(srcdir)/numo/types/sfloat.h $(TIMESTAMP_DIR)/.sitearchdir.-.numo.-.numo.-.types.time
	$(Q) $(INSTALL_DATA) $(srcdir)/numo/types/sfloat.h $(@D)
do-install-rb: $(RUBYARCHDIR)/numo/types/uint16.h
$(RUBYARCHDIR)/numo/types/uint16.h: $(srcdir)/numo/types/uint16.h $(TIMESTAMP_DIR)/.sitearchdir.-.numo.-.numo.-.types.time
	$(Q) $(INSTALL_DATA) $(srcdir)/numo/types/uint16.h $(@D)
do-install-rb: $(RUBYARCHDIR)/numo/types/uint32.h
$(RUBYARCHDIR)/numo/types/uint32.h: $(srcdir)/numo/types/uint32.h $(TIMESTAMP_DIR)/.sitearchdir.-.numo.-.numo.-.types.time
	$(Q) $(INSTALL_DATA) $(srcdir)/numo/types/uint32.h $(@D)
do-install-rb: $(RUBYARCHDIR)/numo/types/uint64.h
$(RUBYARCHDIR)/numo/types/uint64.h: $(srcdir)/numo/types/uint64.h $(TIMESTAMP_DIR)/.sitearchdir.-.numo.-.numo.-.types.time
	$(Q) $(INSTALL_DATA) $(srcdir)/numo/types/uint64.h $(@D)
do-install-rb: $(RUBYARCHDIR)/numo/types/uint8.h
$(RUBYARCHDIR)/numo/types/uint8.h: $(srcdir)/numo/types/uint8.h $(TIMESTAMP_DIR)/.sitearchdir.-.numo.-.numo.-.types.time
	$(Q) $(INSTALL_DATA) $(srcdir)/numo/types/uint8.h $(@D)
do-install-rb: $(RUBYARCHDIR)/numo/types/uint_macro.h
$(RUBYARCHDIR)/numo/types/uint_macro.h: $(srcdir)/numo/types/uint_macro.h $(TIMESTAMP_DIR)/.sitearchdir.-.numo.-.numo.-.types.time
	$(Q) $(INSTALL_DATA) $(srcdir)/numo/types/uint_macro.h $(@D)
do-install-rb: $(RUBYARCHDIR)/numo/types/xint_macro.h
$(RUBYARCHDIR)/numo/types/xint_macro.h: $(srcdir)/numo/types/xint_macro.h $(TIMESTAMP_DIR)/.sitearchdir.-.numo.-.numo.-.types.time
	$(Q) $(INSTALL_DATA) $(srcdir)/numo/types/xint_macro.h $(@D)
pre-install-rb:
	$(Q1:0=@$(MAKE) -q do-install-rb || )$(ECHO1:0=echo) installing narray libraries
$(TARGET_SO_DIR_TIMESTAMP):
	$(Q) $(MAKEDIRS) $(@D) $(RUBYARCHDIR)
	$(Q) $(TOUCH) $@
$(TIMESTAMP_DIR)/.sitearchdir.-.numo.-.numo.time:
	$(Q) $(MAKEDIRS) $(@D) $(RUBYARCHDIR)/numo
	$(Q) $(TOUCH) $@
$(TIMESTAMP_DIR)/.sitearchdir.-.numo.-.numo.-.types.time:
	$(Q) $(MAKEDIRS) $(@D) $(RUBYARCHDIR)/numo/types
	$(Q) $(TOUCH) $@

site-install: site-install-so site-install-rb
site-install-so: install-so
site-install-rb: install-rb

.SUFFIXES: .c .m .cc .mm .cxx .cpp .o .S

.cc.o:
	$(ECHO) compiling $(<)
	$(Q) $(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) $(COUTFLAG)$@ -c $(CSRCFLAG)$<

.cc.S:
	$(ECHO) translating $(<)
	$(Q) $(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) $(COUTFLAG)$@ -S $(CSRCFLAG)$<

.mm.o:
	$(ECHO) compiling $(<)
	$(Q) $(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) $(COUTFLAG)$@ -c $(CSRCFLAG)$<

.mm.S:
	$(ECHO) translating $(<)
	$(Q) $(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) $(COUTFLAG)$@ -S $(CSRCFLAG)$<

.cxx.o:
	$(ECHO) compiling $(<)
	$(Q) $(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) $(COUTFLAG)$@ -c $(CSRCFLAG)$<

.cxx.S:
	$(ECHO) translating $(<)
	$(Q) $(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) $(COUTFLAG)$@ -S $(CSRCFLAG)$<

.cpp.o:
	$(ECHO) compiling $(<)
	$(Q) $(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) $(COUTFLAG)$@ -c $(CSRCFLAG)$<

.cpp.S:
	$(ECHO) translating $(<)
	$(Q) $(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) $(COUTFLAG)$@ -S $(CSRCFLAG)$<

.c.o:
	$(ECHO) compiling $(<)
	$(Q) $(CC) $(INCFLAGS) $(CPPFLAGS) $(CFLAGS) $(COUTFLAG)$@ -c $(CSRCFLAG)$<

.c.S:
	$(ECHO) translating $(<)
	$(Q) $(CC) $(INCFLAGS) $(CPPFLAGS) $(CFLAGS) $(COUTFLAG)$@ -S $(CSRCFLAG)$<

.m.o:
	$(ECHO) compiling $(<)
	$(Q) $(CC) $(INCFLAGS) $(CPPFLAGS) $(CFLAGS) $(COUTFLAG)$@ -c $(CSRCFLAG)$<

.m.S:
	$(ECHO) translating $(<)
	$(Q) $(CC) $(INCFLAGS) $(CPPFLAGS) $(CFLAGS) $(COUTFLAG)$@ -S $(CSRCFLAG)$<

$(TARGET_SO): $(OBJS) Makefile
	$(ECHO) linking shared-object numo/$(DLLIB)
	-$(Q)$(RM) $(@)
	$(Q) $(LDSHARED) -o $@ $(OBJS) $(LIBPATH) $(DLDFLAGS) $(LOCAL_LIBS) $(LIBS)



###
$(OBJS): $(RUBY_EXTCONF_H)

TAGSRC = \
 numo/types/*.h \
 *.c

tags : TAGS
TAGS : $(TAGSRC)
	etags $(TAGSRC)

doc :
	yard doc *.c

C_TMPL = /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/accum.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/accum_arg.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/accum_binary.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/accum_index.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/alloc_func.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/allocate.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/aref.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/aset.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/binary.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/binary2.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/binary_s.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/bincount.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/cast.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/cast_array.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/class.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/clip.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/coerce_cast.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/cond_binary.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/cond_unary.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/cum.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/each.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/each_with_index.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/ewcomp.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/extract.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/extract_data.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/eye.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/fill.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/format.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/format_to_a.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/frexp.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/init_class.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/init_module.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/inspect.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/lib.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/logseq.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/map_with_index.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/median.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/minmax.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/module.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/new_dim0.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/poly.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/pow.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/powint.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/qsort.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/rand.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/rand_norm.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/seq.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/set2.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/sort.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/sort_index.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/store.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/store_array.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/store_bit.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/store_from.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/store_numeric.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/to_a.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/unary.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/unary2.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/unary_ret2.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl/unary_s.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl_bit/allocate.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl_bit/aref.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl_bit/aset.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl_bit/binary.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl_bit/bit_count.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl_bit/bit_reduce.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl_bit/each.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl_bit/each_with_index.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl_bit/extract.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl_bit/fill.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl_bit/format.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl_bit/format_to_a.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl_bit/inspect.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl_bit/mask.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl_bit/none_p.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl_bit/store_array.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl_bit/store_bit.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl_bit/store_from.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl_bit/to_a.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl_bit/unary.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl_bit/where.c /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/tmpl_bit/where2.c

COGEN = /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/cogen.rb
DEPENDS = $(C_TMPL) /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/*.rb


t_bit.c: /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/def/bit.rb $(DEPENDS)
	ruby $(COGEN) -l -o $@ /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/def/bit.rb

t_dcomplex.c: /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/def/dcomplex.rb $(DEPENDS)
	ruby $(COGEN) -l -o $@ /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/def/dcomplex.rb

t_dfloat.c: /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/def/dfloat.rb $(DEPENDS)
	ruby $(COGEN) -l -o $@ /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/def/dfloat.rb

t_int16.c: /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/def/int16.rb $(DEPENDS)
	ruby $(COGEN) -l -o $@ /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/def/int16.rb

t_int32.c: /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/def/int32.rb $(DEPENDS)
	ruby $(COGEN) -l -o $@ /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/def/int32.rb

t_int64.c: /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/def/int64.rb $(DEPENDS)
	ruby $(COGEN) -l -o $@ /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/def/int64.rb

t_int8.c: /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/def/int8.rb $(DEPENDS)
	ruby $(COGEN) -l -o $@ /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/def/int8.rb

t_robject.c: /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/def/robject.rb $(DEPENDS)
	ruby $(COGEN) -l -o $@ /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/def/robject.rb

t_scomplex.c: /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/def/scomplex.rb $(DEPENDS)
	ruby $(COGEN) -l -o $@ /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/def/scomplex.rb

t_sfloat.c: /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/def/sfloat.rb $(DEPENDS)
	ruby $(COGEN) -l -o $@ /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/def/sfloat.rb

t_uint16.c: /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/def/uint16.rb $(DEPENDS)
	ruby $(COGEN) -l -o $@ /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/def/uint16.rb

t_uint32.c: /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/def/uint32.rb $(DEPENDS)
	ruby $(COGEN) -l -o $@ /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/def/uint32.rb

t_uint64.c: /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/def/uint64.rb $(DEPENDS)
	ruby $(COGEN) -l -o $@ /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/def/uint64.rb

t_uint8.c: /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/def/uint8.rb $(DEPENDS)
	ruby $(COGEN) -l -o $@ /home/asonibar/Code/second-brain-app/second-brain-rails/vendor/bundle/ruby/3.2.0/gems/numo-narray-0.9.2.1/ext/numo/narray/gen/def/uint8.rb


src : t_bit.c t_dcomplex.c t_dfloat.c t_int16.c t_int32.c t_int64.c t_int8.c t_robject.c t_scomplex.c t_sfloat.c t_uint16.c t_uint32.c t_uint64.c t_uint8.c

CLEANOBJS = *.o t_*.c *.bak
DISTCLEANFILES = depend TAGS
