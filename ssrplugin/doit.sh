#!/bin/bash
# This is how you can compile ssrplugin with HoTT
# First we make the new Coq standard library (you did run ./configure, right?)
make -C .. stdlib
# Then we make the dynamic library
export COQBIN=$HOME/Documents/project/homotopy/coq/bin/
if test "$COQBIN" = "unconfigured"; then
   echo "You should first set the COQBIN variable in doit.sh, and please include a trailing slash."
   exit
fi
export PATH=$COQBIN:$PATH
# We replace the standard Coq with the HoTT version
COQC=../hoqc make all

