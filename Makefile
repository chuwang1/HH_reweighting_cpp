################################################################################
#
# Makefile to compile and link C programs
#
# Version valid for Linux machines
#
# "make" compiles and links the specified main programs and modules
# using the specified libraries (if any), and produces the executables
#
# "make clean" removes all files created by "make"
#
# Dependencies on included files are automatically taken care of
#
################################################################################
all: rmxeq mkdep mkxeq
.PHONY: all

GCC = g++

# main programs and required modules
MAIN =  make_weights
MODULES = THWeightInterface

# search path for modules

MDIR = ./


# root
ROOTINCS = $(shell root-config --cflags)
ROOTLIBS = $(shell root-config --glibs)

# gsl
GSLINCS = $(shell gsl-config --cflags)
GSLLIBS = $(shell gsl-config --libs)

# PY
PYINCS = $(shell python2.7-config --cflags)
PYLD   = $(shell python2.7-config --ldflags)
PYLIBS = $(shell python2.7-config --libs)

# scheduling and optimization options (such as -DSSE -DSSE2 -DP4)
CFLAGS = -ansi -O3 -Wall -std=c++11 #$(ROOTCFLAGS)
#CXXFLAGS += -std=c++11x
#-I /opt/rh/python27/root/usr/include/python2.7

# additional include directories
INCPATH = $(PYINCS) #$(ROOTINCS)

# additional libraries to be included
### find your Python.h with the command: find / -name Python.h 2>/dev/null
LIBS =  -lboost_system $(PYLIBS) $(ROOTLIBS) #  #-lpython2.7 $(PYLD) 
# -L/usr/lib/python2.7/config -lGenVector
# -I/opt/rh/python27/root/usr/include/python2.7/
#-L/cvmfs/cms.cern.ch/slc6_amd64_gcc630/cms/cmssw-patch/CMSSW_9_4_6_patch1/external/slc6_amd64_gcc630/bin
############################## do not change ###################################

SHELL=/bin/bash

CC=$(GCC)

PGMS= $(MAIN) $(MODULES)

INCDIRS = $(INCPATH)

OBJECTS = $(addsuffix .o,$(MODULES))

LDFLAGS = $(LIBS)

-include $(addsuffix .d,$(PGMS))

# rule to make dependencies

$(addsuffix .d,$(PGMS)): %.d: %.cc Makefile
	@ $(CC) -MM -ansi $(INCDIRS) $< -o $@

# rule to compile source programs

$(addsuffix .o,$(PGMS)): %.o: %.cc Makefile
	$(CC) $< -c $(CFLAGS) $(INCDIRS) -o $@

# rule to link object files

$(MAIN): %: %.o $(OBJECTS) Makefile
	$(CC) $< $(OBJECTS) $(CFLAGS) $(LDFLAGS) -o $@

# produce executables

mkxeq: $(MAIN)

# remove old executables and old error log file

rmxeq:
	@ -rm -f $(MAIN); \
	echo "delete old executables"


# make dependencies

mkdep:  $(addsuffix .d,$(PGMS))
	@ echo "generate tables of dependencies"


# clean directory

clean:
	@ -rm -rf *.d *.o *~ $(MAIN) *.eps *.data plots/*~ plots/*.eps *.a analysis/*~ analysis/*.eps
.PHONY: clean
