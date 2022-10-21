dnl   NOTE: The main GCC compiler (not ARM or SPARC cross)
dnl   has separate m4 files for each supported version of GCC
dnl   gcc_vers45.m4, gcc_vers8.m4, etc.
dnl   To add another, edit the list in etc/macros/Makefile.am


dnl
dnl check for GCC 4.5 with ARM cross compilation plugin
dnl
AC_DEFUN([AC_CHECK_GCC_ARM_VERSION],[

echo "checking for arm cross compiler..."
dnl the directory where plugins will be put
if test "$prefix" != "NONE"; then
   ARM_PLUGIN_DIR=$prefix/gcc_plugins
else
   ARM_PLUGIN_DIR=/opt/gcc_plugins
fi

dnl checking for host gcc-4.5
AC_CHECK_PROG(ARM_HOST_PLUGIN_COMPILER, gcc-4.5, gcc-4.5,)
if test "x$ARM_HOST_PLUGIN_COMPILER" = x; then
   AC_MSG_ERROR("gcc-4.5 not found - arm plugins cannot be compiled)
fi


dnl switch to c
AC_LANG_PUSH([C])

dnl the list of gccs to be tested
GCC_TO_BE_CHECKED="$ac_arm_gcc /opt/x-tools/arm/bin/armeb-unknown-linux-gnueabi-gcc"

for compiler in $GCC_TO_BE_CHECKED; do
   if test -f $compiler; then
      echo "checking $compiler..."
      dnl check for minimum gcc
      ARM_GCC_VERSION=`$compiler -dumpspecs | grep \*version -A1 | tail -1`
      AS_VERSION_COMPARE($ARM_GCC_VERSION, $1, echo "checking $compiler >= $1... no"; min=no, echo "checking $compiler >= $1... yes"; min=yes, echo "checking $compiler >= $1... yes"; min=yes)
      if test "$min" = "no" ; then
         continue;
      fi
      AS_VERSION_COMPARE($ARM_GCC_VERSION, $2, echo "checking $compiler < $2... yes"; max=yes, echo "checking $compiler < $2... no"; max=no, echo "checking $compiler < $2... no"; max=no)
      if test "$max" = "no" ; then
         continue;
      fi
      ARM_GCC_VERSION=`echo $ARM_GCC_VERSION | sed 's/\./_/g'`
      echo "version is $ARM_GCC_VERSION"
      ARM_GCC_EXE=$compiler;
      ARM_GCC_PLUGIN_DIR=`$ARM_GCC_EXE -print-file-name=plugin`
      if test "x$ARM_GCC_PLUGIN_DIR" = "xplugin"; then
         ARM_GCC_EXE=""
         continue
      fi
      echo "checking plugin directory...$ARM_GCC_PLUGIN_DIR"
      ARM_GCC_CONFIGURE=`$TOPSRCDIR/../etc/macros/get_configure.sh $ARM_GCC_EXE`
      echo "checking arm gcc configure... $ARM_GCC_CONFIGURE"
      ARM_GCC_TARGET=`$TOPSRCDIR/../etc/macros/get_target.sh $ARM_GCC_EXE`
      echo "checking arm gcc target... $ARM_GCC_TARGET"
      ARM_GCC_SRC_DIR=`dirname $ARM_GCC_CONFIGURE`
      ARM_GCC_BUILT_DIR=$ARM_GCC_SRC_DIR/../../$ARM_GCC_TARGET/build/build-cc-final
      echo "checking arm gcc build... $ARM_GCC_BUILT_DIR"
      if test -d $ARM_GCC_SRC_DIR; then
         echo "checking arm gcc source directory...$ARM_GCC_SRC_DIR"
      else
         echo "checking arm gcc source directory...not found"
         ARM_GCC_EXE=""
         continue
      fi
      arm_gcc_file=`basename $ARM_GCC_EXE`
      arm_gcc_dir=`dirname $ARM_GCC_EXE`
      arm_cpp=`echo $arm_gcc_file | sed s/gcc/cpp/`
      ARM_CPP_EXE=$arm_gcc_dir/$arm_cpp
      if test -f $ARM_CPP_EXE; then
         echo "checking cpp...$ARM_CPP_EXE"
      else
         echo "checking cpp...no"
         ARM_GCC_EXE=""
         continue
      fi
      arm_gpp=`echo $arm_gcc_file | sed s/gcc/gpp/`
      ARM_GPP_EXE=$arm_gcc_dir/$arm_gpp
      if test -f $ARM_GPP_EXE; then
         echo "checking g++...$ARM_GPP_EXE"
         break
      else
         echo "checking g++...no"
         break
      fi
   else
      echo "checking $compiler... not found"
   fi
done

dnl if gcc has not been found, create in /opt/gcc-4.5.2
if test "x$ARM_GCC_EXE" = x; then
  build_ARM_GCC=yes;
  ARM_GCC_EXE=/opt/x-tools/arm/bin/armeb-unknown-linux-gnueabi-gcc
  ARM_CPP_EXE=/opt/x-tools/arm/bin/armeb-unknown-linux-gnueabi-cpp
  ARM_GCC_PLUGIN_DIR=/opt/x-tools/arm/lib/gcc/armeb-unknown-linux-gnueabi/4.5.2/plugin
  ARM_GCC_SRC_DIR=/opt/x-tools/build_arm/src/gcc-4.5.2
  ARM_GCC_BUILT_DIR=/opt/x-tools/build_arm/armeb-unknown-linux-gnueabi/build/build-cc-final
  ARM_GCC_VERSION=4_5_2
fi

dnl set configure and makefile variables
build_ARM_EMPTY_PLUGIN=yes;
build_ARM_SSA_PLUGIN=yes;
build_ARM_SSA_PLUGINCPP=yes;
build_ARM_RTL_PLUGIN=yes;
ARM_EMPTY_PLUGIN=ARM_plugin_dumpGimpleEmpty
ARM_SSA_PLUGIN=ARM_plugin_dumpGimpleSSA
ARM_SSA_PLUGINCPP=ARM_plugin_dumpGimpleSSACpp
ARM_RTL_PLUGIN=ARM_plugin_dumpRTL
AC_SUBST(ARM_EMPTY_PLUGIN)
AC_SUBST(ARM_SSA_PLUGIN)
AC_SUBST(ARM_SSA_PLUGINCPP)
AC_SUBST(ARM_RTL_PLUGIN)
AC_SUBST(ARM_GCC_PLUGIN_DIR)
AC_SUBST(ARM_GCC_EXE)
AC_SUBST(ARM_GCC_SRC_DIR)
AC_SUBST(ARM_PLUGIN_DIR)
AC_SUBST(ARM_GCC_VERSION)
AC_SUBST(ARM_GCC_BUILT_DIR)
AC_DEFINE(HAVE_ARM_COMPILER, 1, "Define if ARM cross compiler is already present")
AC_DEFINE_UNQUOTED(ARM_GCC_EXE, "${ARM_GCC_EXE}", "Define the plugin gcc")
AC_DEFINE_UNQUOTED(ARM_CPP_EXE, "${ARM_CPP_EXE}", "Define the plugin cpp")
AC_DEFINE_UNQUOTED(ARM_GPP_EXE, "${ARM_GPP_EXE}", "Define the plugin g++")
AC_DEFINE_UNQUOTED(ARM_EMPTY_PLUGIN, "${ARM_EMPTY_PLUGIN}", "Define the filename of the GCC PandA Empty plugin")
AC_DEFINE_UNQUOTED(ARM_SSA_PLUGIN, "${ARM_SSA_PLUGIN}", "Define the filename of the GCC PandA SSA plugin")
AC_DEFINE_UNQUOTED(ARM_SSA_PLUGINCPP, "${ARM_SSA_PLUGINCPP}", "Define the filename of the GCC PandA C++ SSA plugin")
AC_DEFINE_UNQUOTED(ARM_RTL_PLUGIN, "${ARM_RTL_PLUGIN}", "Define the filename of the GCC PandA RTL plugin")
AC_DEFINE_UNQUOTED(ARM_GCC_VERSION, "${ARM_GCC_VERSION}", "Define the arm gcc version")

])

dnl
dnl check for GCC 4.5 with SPARC cross-compiler plugin support enabled and plugins
dnl
AC_DEFUN([AC_CHECK_GCC_SPARC_VERSION],[

echo "checking for sparc cross compiler..."
dnl the directory where plugins will be put
if test "$prefix" != "NONE"; then
   SPARC_PLUGIN_DIR=$prefix/gcc_plugins
else
   SPARC_PLUGIN_DIR=/opt/gcc_plugins
fi

dnl checking for host gcc-4.5
AC_CHECK_PROG(SPARC_HOST_PLUGIN_COMPILER, gcc-4.5, gcc-4.5,)
if test "x$SPARC_HOST_PLUGIN_COMPILER" = x; then
   AC_MSG_ERROR("gcc-4.5 not found - sparc plugins cannot be compiled)
fi

dnl switch to c
AC_LANG_PUSH([C])

dnl the list of gccs to be tested
GCC_TO_BE_CHECKED="$ac_sparc_gcc /opt/x-tools/sparc/bin/sparc-unknown-linux-gnu-gcc"

for compiler in $GCC_TO_BE_CHECKED; do
   if test -f $compiler; then
      echo "checking $compiler..."
      dnl check for minimum gcc
      SPARC_GCC_VERSION=`$compiler -dumpspecs | grep \*version -A1 | tail -1`
      AS_VERSION_COMPARE($SPARC_GCC_VERSION, $1, echo "checking $compiler >= $1... no"; min=no, echo "checking $compiler >= $1... yes"; min=yes, echo "checking $compiler >= $1... yes"; min=yes)
      if test "$min" = "no" ; then
         continue;
      fi
      AS_VERSION_COMPARE($SPARC_GCC_VERSION, $2, echo "checking $compiler < $2... yes"; max=yes, echo "checking $compiler < $2... no"; max=no, echo "checking $compiler < $2... no"; max=no)
      if test "$max" = "no" ; then
         continue;
      fi
      SPARC_GCC_EXE=$compiler;
      SPARC_GCC_PLUGIN_DIR=`$SPARC_GCC_EXE -print-file-name=plugin`
      if test "x$SPARC_GCC_PLUGIN_DIR" = "xplugin"; then
         SPARC_GCC_EXE=""
         continue
      fi
      SPARC_GCC_VERSION=`echo $SPARC_GCC_VERSION | sed 's/\./_/g'`
      echo "version is $SPARC_GCC_VERSION"
      echo "checking plugin directory...$SPARC_GCC_PLUGIN_DIR"
      SPARC_GCC_CONFIGURE=`$TOPSRCDIR/../etc/macros/get_configure.sh $SPARC_GCC_EXE`
      echo "checking sparc gcc configure... $SPARC_GCC_CONFIGURE"
      SPARC_GCC_TARGET=`$TOPSRCDIR/../etc/macros/get_target.sh $SPARC_GCC_EXE`
      echo "checking sparc gcc target... $SPARC_GCC_TARGET"
      SPARC_GCC_SRC_DIR=`dirname $SPARC_GCC_CONFIGURE`
      SPARC_GCC_BUILT_DIR=$SPARC_GCC_SRC_DIR/../../$SPARC_GCC_TARGET/build/build-cc-final
      echo "checking sparc gcc build... $SPARC_GCC_BUILT_DIR"
      if test -d $SPARC_GCC_SRC_DIR; then
         echo "checking sparc gcc source directory...$SPARC_GCC_SRC_DIR"
      else
         echo "checking sparc gcc source directory...not found"
         SPARC_GCC_EXE=""
         continue
      fi
      sparc_gcc_file=`basename $SPARC_GCC_EXE`
      sparc_gcc_dir=`dirname $SPARC_GCC_EXE`
      sparc_cpp=`echo $sparc_gcc_file | sed s/gcc/cpp/`
      SPARC_CPP_EXE=$sparc_gcc_dir/$sparc_cpp
      if test -f $SPARC_CPP_EXE; then
         echo "checking cpp...$SPARC_CPP_EXE"
      else
         echo "checking cpp...no"
         SPARC_GCC_EXE=""
         continue
      fi
      sparc_gpp=`echo $sparc_gcc_file | sed s/gcc/gpp/`
      SPARC_GPP_EXE=$sparc_gcc_dir/$sparc_gpp
      if test -f $SPARC_GPP_EXE; then
         echo "checking gpp...$SPARC_GPP_EXE"
         break
      else
         echo "checking gpp...no"
         break
      fi
   else
      echo "checking $compiler... not found"
   fi
done

dnl if gcc has not been found, create in /opt/gcc-4.5.2
if test "x$SPARC_GCC_EXE" = x; then
  build_SPARC_GCC=yes;
  SPARC_GCC_EXE=/opt/x-tools/sparc/bin/sparc-unknown-linux-gnu-gcc
  SPARC_CPP_EXE=/opt/x-tools/sparc/bin/sparc-unknown-linux-gnu-cpp
  SPARC_GCC_PLUGIN_DIR=/opt/x-tools/sparc/lib/gcc/sparc-unknown-linux-gnu/4.5.2/plugin
  SPARC_GCC_SRC_DIR=/opt/x-tools/build_sparc/src/gcc-4.5.2
  SPARC_GCC_BUILT_DIR=/opt/x-tools/build_sparc/sparc-unknown-linux-gnu/build/build-cc-final
  SPARC_GCC_VERSION=4_5_2
fi

dnl set configure and makefile variables
build_SPARC_EMPTY_PLUGIN=yes;
build_SPARC_SSA_PLUGIN=yes;
build_SPARC_SSA_PLUGINCPP=yes;
build_SPARC_RTL_PLUGIN=yes;
SPARC_EMPTY_PLUGIN=SPARC_plugin_dumpGimpleEmpty
SPARC_SSA_PLUGIN=SPARC_plugin_dumpGimpleSSA
SPARC_SSA_PLUGINCPP=SPARC_plugin_dumpGimpleSSACpp
SPARC_RTL_PLUGIN=SPARC_plugin_dumpRTL
AC_SUBST(SPARC_EMPTY_PLUGIN)
AC_SUBST(SPARC_SSA_PLUGIN)
AC_SUBST(SPARC_SSA_PLUGINCPP)
AC_SUBST(SPARC_RTL_PLUGIN)
AC_SUBST(SPARC_GCC_PLUGIN_DIR)
AC_SUBST(SPARC_GCC_EXE)
AC_SUBST(SPARC_GCC_SRC_DIR)
AC_SUBST(SPARC_PLUGIN_DIR)
AC_SUBST(SPARC_GCC_VERSION)
AC_SUBST(SPARC_GCC_BUILT_DIR)
AC_DEFINE(HAVE_SPARC_COMPILER, 1, "Define if the sparc cross compiler exists")
AC_DEFINE_UNQUOTED(SPARC_GCC_EXE, "${SPARC_GCC_EXE}", "Define the plugin GCC")
AC_DEFINE_UNQUOTED(SPARC_CPP_EXE, "${SPARC_CPP_EXE}", "Define the plugin CPP")
AC_DEFINE_UNQUOTED(SPARC_GPP_EXE, "${SPARC_GPP_EXE}", "Define the plugin GPP")
AC_DEFINE_UNQUOTED(SPARC_EMPTY_PLUGIN, "${SPARC_EMPTY_PLUGIN}", "Define the filename of the GCC PandA Empty plugin")
AC_DEFINE_UNQUOTED(SPARC_SSA_PLUGIN, "${SPARC_SSA_PLUGIN}", "Define the filename of the GCC PandA SSA plugin")
AC_DEFINE_UNQUOTED(SPARC_SSA_PLUGINCPP, "${SPARC_SSA_PLUGINCPP}", "Define the filename of the GCC PandA C++ SSA plugin")
AC_DEFINE_UNQUOTED(SPARC_RTL_PLUGIN, "${SPARC_RTL_PLUGIN}", "Define the filename of the GCC PandA RTL plugin")
AC_DEFINE_UNQUOTED(SPARC_GCC_VERSION, "${SPARC_GCC_VERSION}", "Define the sparc gcc version")


])

#
# Check if gcc supports -Wpedantic
#
AC_DEFUN([AC_COMPILE_WPEDANTIC], [
  AC_CACHE_CHECK(if g++ supports -Wpedantic,
  ac_cv_cxx_compile_wpedantic_cxx,
  [AC_LANG_SAVE
  AC_LANG_CPLUSPLUS
  ac_save_CXXFLAGS="$CXXFLAGS"
  CXXFLAGS="$CXXFLAGS -Wpedantic"
  AC_TRY_COMPILE([
  int a;],,
  ac_cv_cxx_compile_wpedantic_cxx=yes, ac_cv_cxx_compile_wpedantic_cxx=no)
  CXXFLAGS="$ac_save_CXXFLAGS"
  AC_LANG_RESTORE
  ])

  if test "$ac_cv_cxx_compile_wpedantic_cxx" = yes; then
    AC_DEFINE(WPEDANTIC,1,[Define if g++ supports -Wpedantic ])
    panda_WPEDANTIC=yes
  fi
])



dnl
dnl checks if the plugin directory exists and is writable
dnl
AC_DEFUN([AC_CHECK_GCC_PLUGIN_DIR],[

if test "$prefix" != "NONE"; then
   GCC_PLUGIN_DIR=$prefix/gcc_plugins
else
   GCC_PLUGIN_DIR=/opt/gcc_plugins
fi

AC_DEFINE_UNQUOTED(GCC_PLUGIN_DIR, "${GCC_PLUGIN_DIR}", "Define the plugin dir")
AC_SUBST(GCC_PLUGIN_DIR)

])

dnl
dnl checks if the plugin directory exists and is writable
dnl
AC_DEFUN([AC_CHECK_CLANG_PLUGIN_DIR],[

if test "$prefix" != "NONE"; then
   CLANG_PLUGIN_DIR=$prefix/gcc_plugins
else
   CLANG_PLUGIN_DIR=/opt/gcc_plugins
fi

AC_DEFINE_UNQUOTED(CLANG_PLUGIN_DIR, "${CLANG_PLUGIN_DIR}", "Define the plugin dir")
AC_SUBST(CLANG_PLUGIN_DIR)

])


