dnl
dnl check for GCC version 4.5 with plugin support enabled and plugins
dnl
AC_DEFUN([AC_CHECK_GCC45_I386_VERSION],[
    AC_ARG_WITH(gcc45,
    [  --with-gcc45=executable-path path where the GCC 4.5 is installed ],
    [
       ac_gcc45="$withval"
    ])

dnl switch to c
AC_LANG_PUSH([C])

if test "x$ac_gcc45" = x; then
   GCC_TO_BE_CHECKED="/usr/bin/gcc-4.5 /usr/bin/gcc"
else
   GCC_TO_BE_CHECKED=$ac_gcc45;
fi

echo "looking for gcc 4.5..."
for compiler in $GCC_TO_BE_CHECKED; do
   if test -f $compiler; then
      echo "checking $compiler..."
      dnl check for gcc
      I386_GCC45_VERSION=`$compiler -dumpspecs | grep \*version -A1 | tail -1`
      I386_GCC45_FULL_VERSION=`$compiler --version`
      AS_VERSION_COMPARE($1, [4.5.0], MIN_GCC45=[4.5.0], MIN_GCC45=$1, MIN_GCC45=$1)
      AS_VERSION_COMPARE([4.6.0], $2, MAX_GCC45=[4.6.0], MAX_GCC45=$2, MAX_GCC45=$2)
      AS_VERSION_COMPARE($I386_GCC45_VERSION, $MIN_GCC45, echo "checking $compiler >= $MIN_GCC45... no"; min=no, echo "checking $compiler >= $MIN_GCC45... yes"; min=yes, echo "checking $compiler >= $MIN_GCC45... yes"; min=yes)
      if test "$min" = "no" ; then
         continue;
      fi
      AS_VERSION_COMPARE($I386_GCC45_VERSION, $MAX_GCC45, echo "checking $compiler < $MAX_GCC45... yes"; max=yes, echo "checking $compiler < $MAX_GCC45... no"; max=no, echo "checking $compiler < $MAX_GCC45... no"; max=no)
      if test "$max" = "no" ; then
         continue;
      fi
      I386_GCC45_EXE=$compiler;
      I386_GCC45_PLUGIN_DIR=`$I386_GCC45_EXE -print-file-name=plugin`
      if test "x$I386_GCC45_PLUGIN_DIR" = "xplugin"; then
         echo "checking plugin support... no. Package gcc-4.5-plugin-dev missing?"
         break;
      fi
      echo "checking plugin directory...$I386_GCC45_PLUGIN_DIR"
      gcc_file=`basename $I386_GCC45_EXE`
      gcc_dir=`dirname $I386_GCC45_EXE`
      cpp=`echo $gcc_file | sed s/gcc/cpp/`
      I386_CPP45_EXE=$gcc_dir/$cpp
      if test -f $I386_CPP45_EXE; then
         echo "checking cpp...$I386_CPP45_EXE"
      else
         echo "checking cpp...no"
         I386_GCC45_EXE=""
         continue
      fi
      gpp=`echo $gcc_file | sed s/gcc/g\+\+/`
      I386_GPP45_EXE=$gcc_dir/$gpp
      if test -f $I386_GPP45_EXE; then
         echo "checking g++...$I386_GPP45_EXE"
      else
         echo "checking g++...no"
         continue
      fi
      ac_save_CC="$CC"
      ac_save_CFLAGS="$CFLAGS"
      ac_save_LDFLAGS="$LDFLAGS"
      ac_save_LIBS="$LIBS"
      CC=$I386_GCC45_EXE
      CFLAGS="-m32"
      LDFLAGS=
      LIBS=
      AC_LANG_PUSH([C])
      AC_LINK_IFELSE([AC_LANG_SOURCE([int main(void){ return 0;}])],I386_GCC45_MULTIARCH=yes,I386_GCC45_MULTIARCH=no)
      AC_LANG_POP([C])
      CC=$ac_save_CC
      CFLAGS=$ac_save_CFLAGS
      LDFLAGS=$ac_save_LDFLAGS
      LIBS=$ac_save_LIBS
      if test "x$I386_GCC45_MULTIARCH" != xyes; then
         echo "checking support to -m32... no"
         continue
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
      for plugin_compiler in $I386_GCC45_EXE $I386_GPP45_EXE; do
         if test -f plugin_test.so; then
            rm plugin_test.so
         fi
         $plugin_compiler -I$TOPSRCDIR/etc/gcc_plugin/ -fPIC -shared plugin_test.c -o plugin_test.so -I$I386_GCC45_PLUGIN_DIR/include
         if test ! -f plugin_test.so; then
            echo "checking $plugin_compiler -I$TOPSRCDIR/etc/gcc_plugin/ -fPIC -shared plugin_test.c -o plugin_test.so -I$I386_GCC45_PLUGIN_DIR/include... no"
            continue
         fi
         echo "checking $plugin_compiler -I$TOPSRCDIR/etc/gcc_plugin/ -fPIC -shared plugin_test.c -o plugin_test.so -I$I386_GCC45_PLUGIN_DIR/include... yes"
         ac_save_CC="$CC"
         ac_save_CFLAGS="$CFLAGS"
         CC=$plugin_compiler
         CFLAGS="-fplugin=$BUILDDIR/plugin_test.so"
         AC_LANG_PUSH([C])
         AC_COMPILE_IFELSE([AC_LANG_SOURCE([[
               ]],[[
                  return 0;
               ]])],
         I386_GCC45_PLUGIN_COMPILER=$plugin_compiler,I386_GCC45_PLUGIN_COMPILER=)
         AC_LANG_POP([C])
         CC=$ac_save_CC
         CFLAGS=$ac_save_CFLAGS
         if test "x$I386_GCC45_PLUGIN_COMPILER" != x; then
            break;
         fi
         ac_save_CC="$CC"
         ac_save_CFLAGS="$CFLAGS"
      done
      if test "x$I386_GCC45_PLUGIN_COMPILER" != x; then
         echo "OK, we have found the compiler"
         build_I386_GCC45=yes;
         build_I386_GCC45_EMPTY_PLUGIN=yes;
         build_I386_GCC45_SSA_PLUGIN=yes;
         build_I386_GCC45_SSA_PLUGINCPP=yes;
         build_I386_GCC45_SSAVRP_PLUGIN=yes;
         build_I386_GCC45_TOPFNAME_PLUGIN=yes;
         break;
      fi
   else
      echo "checking $compiler... not found"
   fi
done

if test x$I386_GCC45_PLUGIN_COMPILER != x; then
dnl set configure and makefile variables
  I386_GCC45_EMPTY_PLUGIN=gcc45_plugin_dumpGimpleEmpty
  I386_GCC45_SSA_PLUGIN=gcc45_plugin_dumpGimpleSSA
  I386_GCC45_SSA_PLUGINCPP=gcc45_plugin_dumpGimpleSSACpp
  I386_GCC45_SSAVRP_PLUGIN=gcc45_plugin_dumpGimpleSSAVRP
  I386_GCC45_TOPFNAME_PLUGIN=gcc45_plugin_topfname
  AC_SUBST(I386_GCC45_EMPTY_PLUGIN)
  AC_SUBST(I386_GCC45_SSA_PLUGIN)
  AC_SUBST(I386_GCC45_SSA_PLUGINCPP)
  AC_SUBST(I386_GCC45_SSAVRP_PLUGIN)
  AC_SUBST(I386_GCC45_TOPFNAME_PLUGIN)
  AC_SUBST(I386_GCC45_PLUGIN_DIR)
  AC_SUBST(I386_GCC45_EXE)
  AC_SUBST(I386_GCC45_VERSION)
  AC_SUBST(I386_GCC45_PLUGIN_COMPILER)
  AC_DEFINE(HAVE_I386_GCC45_COMPILER, 1, "Define if GCC 4.5 I386 compiler is compliant")
  AC_DEFINE_UNQUOTED(I386_GCC45_EXE, "${I386_GCC45_EXE}", "Define the plugin gcc")
  AC_DEFINE_UNQUOTED(I386_CPP45_EXE, "${I386_CPP45_EXE}", "Define the plugin cpp")
  AC_DEFINE_UNQUOTED(I386_GPP45_EXE, "${I386_GPP45_EXE}", "Define the plugin g++")
  AC_DEFINE_UNQUOTED(I386_GCC45_EMPTY_PLUGIN, "${I386_GCC45_EMPTY_PLUGIN}", "Define the filename of the GCC PandA Empty plugin")
  AC_DEFINE_UNQUOTED(I386_GCC45_SSA_PLUGIN, "${I386_GCC45_SSA_PLUGIN}", "Define the filename of the GCC PandA SSA plugin")
  AC_DEFINE_UNQUOTED(I386_GCC45_SSA_PLUGINCPP, "${I386_GCC45_SSA_PLUGINCPP}", "Define the filename of the GCC PandA C++ SSA plugin")
  AC_DEFINE_UNQUOTED(I386_GCC45_SSAVRP_PLUGIN, "${I386_GCC45_SSAVRP_PLUGIN}", "Define the filename of the GCC PandA SSAVRP plugin")
  AC_DEFINE_UNQUOTED(I386_GCC45_TOPFNAME_PLUGIN, "${I386_GCC45_TOPFNAME_PLUGIN}", "Define the filename of the GCC PandA topfname plugin")
  AC_DEFINE_UNQUOTED(I386_GCC45_VERSION, "${I386_GCC45_VERSION}", "Define the gcc version")
  AC_DEFINE_UNQUOTED(I386_GCC45_PLUGIN_COMPILER, "${I386_GCC45_PLUGIN_COMPILER}", "Define the plugin compiler")
fi


dnl switch back to old language
AC_LANG_POP([C])

])
