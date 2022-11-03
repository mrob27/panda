dnl
dnl check for GCC 9.x with plugin support enabled and plugins
dnl
AC_DEFUN([AC_CHECK_GCC9_I386_VERSION],[
    AC_ARG_WITH(gcc9,
    [  --with-gcc9=executable-path path where the GCC 9 is installed ],
    [
       ac_gcc9="$withval"
    ])

   echo xi386_g ... 9

dnl switch to c
AC_LANG_PUSH([C])

if test "x$ac_gcc9" = x; then
   GCC_TO_BE_CHECKED="/usr/lib/gcc-snapshot/bin/gcc /usr/bin/gcc-9 /usr/local/bin/gcc-9 /usr/bin/gcc-9 /usr/bin/gcc"
else
   GCC_TO_BE_CHECKED=$ac_gcc9;
fi

echo "looking for gcc 9..."
echo xi386_gcc9 checking "$GCC_TO_BE_CHECKED"
for compiler in $GCC_TO_BE_CHECKED; do
   if test -f $compiler; then
      echo "checking $compiler..."
      dnl check for gcc
      I386_GCC9_VERSION=`$compiler -dumpspecs | grep \*version -A1 | tail -1`
   echo xi386_gcc9 version is "$I386_GCC9_VERSION" s1 "$1" s2 "$2"
      I386_GCC9_FULL_VERSION=`$compiler --version`
      AS_VERSION_COMPARE($1, [9.0.0], MIN_GCC9=[9.0.0], MIN_GCC9=$1, MIN_GCC9=$1)
      AS_VERSION_COMPARE([10.0.0], $2, MAX_GCC9=[10.0.0], MAX_GCC9=$2, MAX_GCC9=$2)
      AS_VERSION_COMPARE($I386_GCC9_VERSION, $MIN_GCC9, echo "xi386_g1 checking $compiler >= $MIN_GCC9... no"; min=no, echo "xi386_g2 checking $compiler >= $MIN_GCC9... yes"; min=yes, echo "xi386_g3 checking $compiler >= $MIN_GCC9... yes"; min=yes)
      if test "$min" = "no" ; then
         continue;
      fi
      AS_VERSION_COMPARE($I386_GCC9_VERSION, $MAX_GCC9, echo "xi386_g4 checking $compiler < $MAX_GCC9... yes"; max=yes, echo "xi386_g5 checking $compiler < $MAX_GCC9... no"; max=no, echo "xi386_g6 checking $compiler < $MAX_GCC9... no"; max=no)
      if test "$max" = "no" ; then
         continue;
      fi
      I386_GCC9_EXE=$compiler;
      I386_GCC9_PLUGIN_DIR=`$I386_GCC9_EXE -print-file-name=plugin`
      if test "x$I386_GCC9_PLUGIN_DIR" = "xplugin"; then
         echo "checking plugin support... no. Package gcc-9-plugin-dev missing?"
         break;
      fi
      echo "checking plugin directory...$I386_GCC9_PLUGIN_DIR"
      gcc_file=`basename $I386_GCC9_EXE`
      gcc_dir=`dirname $I386_GCC9_EXE`
      cpp=`echo $gcc_file | sed s/gcc/cpp/`
      I386_CPP9_EXE=$gcc_dir/$cpp
      if test -f $I386_CPP9_EXE; then
         echo "checking cpp...$I386_CPP9_EXE"
      else
         echo "checking cpp...no"
         I386_GCC9_EXE=""
         continue
      fi
      gpp=`echo $gcc_file | sed s/gcc/g\+\+/`
      I386_GPP9_EXE=$gcc_dir/$gpp
      if test -f $I386_GPP9_EXE; then
         echo "checking g++...$I386_GPP9_EXE"
      else
         echo "checking g++...no"
         continue
      fi
      ac_save_CC="$CC"
      ac_save_CFLAGS="$CFLAGS"
      ac_save_LDFLAGS="$LDFLAGS"
      ac_save_LIBS="$LIBS"
      CC=$I386_GCC9_EXE
      CFLAGS="-m32"
      LDFLAGS=
      LIBS=
      AC_LANG_PUSH([C])
      AC_LINK_IFELSE([AC_LANG_SOURCE([int main(void){ return 0;}])],I386_GCC9_M32=yes,I386_GCC9_M32=no)
      AC_LANG_POP([C])
      CC=$ac_save_CC
      CFLAGS=$ac_save_CFLAGS
      LDFLAGS=$ac_save_LDFLAGS
      LIBS=$ac_save_LIBS
      if test "x$I386_GCC9_M32" == xyes; then
         AC_DEFINE(HAVE_I386_GCC9_M32,1,[Define if gcc 9 supports -m32 ])
         echo "checking support to -m32... yes"
      else
         echo "checking support to -m32... no"
      fi
      ac_save_CC="$CC"
      ac_save_CFLAGS="$CFLAGS"
      ac_save_LDFLAGS="$LDFLAGS"
      ac_save_LIBS="$LIBS"
      CC=$I386_GCC9_EXE
      CFLAGS="-mx32"
      LDFLAGS=
      LIBS=
      AC_LANG_PUSH([C])
      AC_LINK_IFELSE([AC_LANG_SOURCE([int main(void){ return 0;}])],I386_GCC9_MX32=yes,I386_GCC9_MX32=no)
      AC_LANG_POP([C])
      CC=$ac_save_CC
      CFLAGS=$ac_save_CFLAGS
      LDFLAGS=$ac_save_LDFLAGS
      LIBS=$ac_save_LIBS
      if test "x$I386_GCC9_MX32" == xyes; then
         AC_DEFINE(HAVE_I386_GCC9_MX32,1,[Define if gcc 9 supports -mx32 ])
         echo "checking support to -mx32... yes"
      else
         echo "checking support to -mx32... no"
      fi
      ac_save_CC="$CC"
      ac_save_CFLAGS="$CFLAGS"
      ac_save_LDFLAGS="$LDFLAGS"
      ac_save_LIBS="$LIBS"
      CC=$I386_GCC9_EXE
      CFLAGS="-m64"
      LDFLAGS=
      LIBS=
      AC_LANG_PUSH([C])
      AC_LINK_IFELSE([AC_LANG_SOURCE([int main(void){ return 0;}])],I386_GCC9_M64=yes,I386_GCC9_M64=no)
      AC_LANG_POP([C])
      CC=$ac_save_CC
      CFLAGS=$ac_save_CFLAGS
      LDFLAGS=$ac_save_LDFLAGS
      LIBS=$ac_save_LIBS
      if test "x$I386_GCC9_M64" == xyes; then
         AC_DEFINE(HAVE_I386_GCC9_M64,1,[Define if gcc 9 supports -m64 ])
         echo "checking support to -m64... yes"
      else
         echo "checking support to -m64... no"
      fi
      cat > plugin_test.c <<PLUGIN_TEST
      #include "plugin_includes.h"

      int plugin_is_GPL_compatible;

      extern struct cpp_reader *parse_in;

      void do_nothing(void * first, void * second)
      {
         cpp_define (parse_in, "TEST_GCC_PLUGIN=1");
      }

      int
      plugin_init (struct plugin_name_args * plugin_info, struct plugin_gcc_version * version)
      {
         if (!plugin_default_version_check(version, &gcc_version))
            return 1;
         register_callback("plugin_test", PLUGIN_START_UNIT, do_nothing, NULL);
         return 0;
      }
PLUGIN_TEST
      for plugin_compiler in $I386_GCC9_EXE $I386_GPP9_EXE; do
         if test -f plugin_test.so; then
            rm plugin_test.so
         fi
         plugin_option=
         case $host_os in
           mingw*) 
             plugin_option="-shared -Wl,--export-all-symbols $I386_GCC9_PLUGIN_DIR/cc1plus.exe.a"
           ;;
           darwin*)
             plugin_option='-fPIC -shared -undefined dynamic_lookup'
           ;;
           *)
             plugin_option='-fPIC -shared'
           ;;
         esac
         $plugin_compiler -I$TOPSRCDIR/etc/gcc_plugin/ plugin_test.c -o plugin_test.so -I$I386_GCC9_PLUGIN_DIR/include $plugin_option 2> /dev/null
         if test ! -f plugin_test.so; then
            echo "checking $plugin_compiler -I$TOPSRCDIR/etc/gcc_plugin/ plugin_test.c -o plugin_test.so -I$I386_GCC9_PLUGIN_DIR/include $plugin_option ... no"
            continue
         fi
         echo "checking $plugin_compiler -I$TOPSRCDIR/etc/gcc_plugin/ plugin_test.c -o plugin_test.so -I$I386_GCC9_PLUGIN_DIR/include $plugin_option... yes"
         ac_save_CC="$CC"
         ac_save_CFLAGS="$CFLAGS"
         CC=$plugin_compiler
         CFLAGS="-fplugin=$BUILDDIR/plugin_test.so"
         AC_LANG_PUSH([C])
         AC_COMPILE_IFELSE([AC_LANG_SOURCE([[
               ]],[[
                  return 0;
               ]])],
         I386_GCC9_PLUGIN_COMPILER=$plugin_compiler,I386_GCC9_PLUGIN_COMPILER=)
         AC_LANG_POP([C])
         CC=$ac_save_CC
         CFLAGS=$ac_save_CFLAGS
         #If plugin compilation fails, skip this executable
         if test "x$I386_GCC9_PLUGIN_COMPILER" = x; then
            continue
         fi
         echo "Looking for gcc9 gengtype"
         I386_GCC9_GENGTYPE=`$I386_GCC9_EXE -print-file-name=gengtype$ac_exeext`
         if test "x$I386_GCC9_GENGTYPE" = "xgengtype$ac_exeext"; then
            I386_GCC9_GENGTYPE=`$I386_GCC9_EXE -print-file-name=plugin/gengtype$ac_exeext`
            if test "x$I386_GCC9_GENGTYPE" = "xplugin/gengtype$ac_exeext"; then
               I386_GCC9_ROOT_DIR=`dirname $I386_GCC9_EXE`/..
               I386_GCC9_GENGTYPE=`find $I386_GCC9_ROOT_DIR -name gengtype$ac_exeext | head -n1`
               if test "x$I386_GCC9_GENGTYPE" = "x"; then
                  I386_GCC9_PLUGIN_COMPILER=
                  continue
               fi
            fi
         fi
         echo "Looking for gtype.state"
         I386_GCC9_GTYPESTATE=`$I386_GCC9_EXE -print-file-name=gtype.state`
         if test "x$I386_GCC9_GTYPESTATE" = "xgtype.state"; then
            I386_GCC9_GTYPESTATE=`$I386_GCC9_EXE -print-file-name=plugin/gtype.state`
            if test "x$I386_GCC9_GTYPESTATE" = "xplugin/gtype.state"; then
               I386_GCC9_PLUGIN_COMPILER=
               continue
            fi
         fi
         echo "OK, we have found the compiler"
         build_I386_GCC9=yes;
         build_I386_GCC9_EMPTY_PLUGIN=yes;
         build_I386_GCC9_SSA_PLUGIN=yes;
         build_I386_GCC9_SSA_PLUGINCPP=yes;
         build_I386_GCC9_TOPFNAME_PLUGIN=yes;
      done
      if test "x$I386_GCC9_PLUGIN_COMPILER" != x; then
         break;
      fi
   else
      echo "checking $compiler... not found"
   fi
done

if test x$I386_GCC9_PLUGIN_COMPILER != x; then
  dnl set configure and makefile variables
  I386_GCC9_EMPTY_PLUGIN=gcc9_plugin_dumpGimpleEmpty
  I386_GCC9_SSA_PLUGIN=gcc9_plugin_dumpGimpleSSA
  I386_GCC9_SSA_PLUGINCPP=gcc9_plugin_dumpGimpleSSACpp
  I386_GCC9_TOPFNAME_PLUGIN=gcc9_plugin_topfname
  AC_SUBST(I386_GCC9_EMPTY_PLUGIN)
  AC_SUBST(I386_GCC9_SSA_PLUGIN)
  AC_SUBST(I386_GCC9_SSA_PLUGINCPP)
  AC_SUBST(I386_GCC9_TOPFNAME_PLUGIN)
  AC_SUBST(I386_GCC9_PLUGIN_DIR)
  AC_SUBST(I386_GCC9_GENGTYPE)
  AC_SUBST(I386_GCC9_GTYPESTATE)
  AC_SUBST(I386_GCC9_EXE)
  AC_SUBST(I386_GCC9_VERSION)
  AC_SUBST(I386_GCC9_PLUGIN_COMPILER)
  AC_DEFINE(HAVE_I386_GCC9_COMPILER, 1, "Define if GCC 9 I386 compiler is compliant")
  AC_DEFINE_UNQUOTED(I386_GCC9_EXE, "${I386_GCC9_EXE}", "Define the plugin gcc")
  AC_DEFINE_UNQUOTED(I386_CPP9_EXE, "${I386_CPP9_EXE}", "Define the plugin cpp")
  AC_DEFINE_UNQUOTED(I386_GPP9_EXE, "${I386_GPP9_EXE}", "Define the plugin g++")
  AC_DEFINE_UNQUOTED(I386_GCC9_EMPTY_PLUGIN, "${I386_GCC9_EMPTY_PLUGIN}", "Define the filename of the GCC PandA Empty plugin")
  AC_DEFINE_UNQUOTED(I386_GCC9_SSA_PLUGIN, "${I386_GCC9_SSA_PLUGIN}", "Define the filename of the GCC PandA SSA plugin")
  AC_DEFINE_UNQUOTED(I386_GCC9_SSA_PLUGINCPP, "${I386_GCC9_SSA_PLUGINCPP}", "Define the filename of the GCC PandA C++ SSA plugin")
  AC_DEFINE_UNQUOTED(I386_GCC9_TOPFNAME_PLUGIN, "${I386_GCC9_TOPFNAME_PLUGIN}", "Define the filename of the GCC PandA topfname plugin")
  AC_DEFINE_UNQUOTED(I386_GCC9_VERSION, "${I386_GCC9_VERSION}", "Define the gcc version")
  AC_DEFINE_UNQUOTED(I386_GCC9_PLUGIN_COMPILER, "${I386_GCC9_PLUGIN_COMPILER}", "Define the plugin compiler")
fi

dnl switch back to old language
AC_LANG_POP([C])

])
