dnl
dnl check for GCC 4.6 with plugin support enabled and plugins
dnl
AC_DEFUN([AC_CHECK_GCC46_I386_VERSION],[
    AC_ARG_WITH(gcc46,
    [  --with-gcc46=executable-path path where the GCC 4.6 is installed ],
    [
       ac_gcc46="$withval"
    ])

   echo xi386_g ... 46

dnl switch to c
AC_LANG_PUSH([C])

if test "x$ac_gcc46" = x; then
   GCC_TO_BE_CHECKED="/usr/bin/gcc-4.6 /usr/bin/gcc"
else
   GCC_TO_BE_CHECKED=$ac_gcc46;
fi
echo xi386_gcc46 checking "$GCC_TO_BE_CHECKED"
echo "looking for gcc 4.6..."
for compiler in $GCC_TO_BE_CHECKED; do
   if test -f $compiler; then
      echo "checking $compiler..."
      dnl check for gcc
      I386_GCC46_VERSION=`$compiler -dumpspecs | grep \*version -A1 | tail -1`
   echo xi386_gcc46 version is "$I386_GCC46_VERSION"
      I386_GCC46_FULL_VERSION=`$compiler --version`
      AS_VERSION_COMPARE($1, [4.6.0], MIN_GCC46=[4.6.0], MIN_GCC46=$1, MIN_GCC46=$1)
      AS_VERSION_COMPARE([4.7.0], $2, MAX_GCC46=[4.7.0], MAX_GCC46=$2, MAX_GCC46=$2)
      AS_VERSION_COMPARE($I386_GCC46_VERSION, $MIN_GCC46, echo "xi386_g1 checking $compiler >= $MIN_GCC46... no"; min=no, echo "xi386_g2 checking $compiler >= $MIN_GCC46... yes"; min=yes, echo "xi386_g3 checking $compiler >= $MIN_GCC46... yes"; min=yes)
      if test "$min" = "no" ; then
         continue;
      fi
      AS_VERSION_COMPARE($I386_GCC46_VERSION, $MAX_GCC46, echo "xi386_g4 checking $compiler < $MAX_GCC46... yes"; max=yes, echo "xi386_g5 checking $compiler < $MAX_GCC46... no"; max=no, echo "xi386_g6 checking $compiler < $MAX_GCC46... no"; max=no)
      if test "$max" = "no" ; then
         continue;
      fi
      I386_GCC46_EXE=$compiler;
      I386_GCC46_PLUGIN_DIR=`$I386_GCC46_EXE -print-file-name=plugin`
      if test "x$I386_GCC46_PLUGIN_DIR" = "xplugin"; then
         echo "checking plugin support... no. Package gcc-4.6-plugin-dev missing?"
         break;
      fi
      echo "checking plugin directory...$I386_GCC46_PLUGIN_DIR"
   echo xi386_gcc46 plugin dir is "$I386_GCC46_PLUGIN_DIR"
      gcc_file=`basename $I386_GCC46_EXE`
      gcc_dir=`dirname $I386_GCC46_EXE`
      cpp=`echo $gcc_file | sed s/gcc/cpp/`
      I386_CPP46_EXE=$gcc_dir/$cpp
      if test -f $I386_CPP46_EXE; then
         echo "checking cpp...$I386_CPP46_EXE"
   echo xi386_gcc46 cpp is good
      else
         echo "checking cpp...no"
         I386_GCC46_EXE=""
   echo xi386_gcc46 cpp is bad
         continue
      fi
      ac_save_CC="$CC"
      ac_save_CFLAGS="$CFLAGS"
      ac_save_LDFLAGS="$LDFLAGS"
      ac_save_LIBS="$LIBS"
      CC=$I386_GCC46_EXE
      CFLAGS="-m32"
      LDFLAGS=
      LIBS=
      AC_LANG_PUSH([C])
      AC_LINK_IFELSE([AC_LANG_SOURCE([int main(void){ return 0;}])],I386_GCC46_MULTIARCH=yes,I386_GCC46_MULTIARCH=no)
      AC_LANG_POP([C])
      CC=$ac_save_CC
      CFLAGS=$ac_save_CFLAGS
      LDFLAGS=$ac_save_LDFLAGS
      LIBS=$ac_save_LIBS
      if test "x$I386_GCC46_MULTIARCH" != xyes; then
         echo "checking support to -m32... no"
   echo xi386_gcc46 m32 failed
dnf         continue
      else
   echo xi386_gcc46 m32 maybe success
      fi
      gpp=`echo $gcc_file | sed s/gcc/g\+\+/`
      I386_GPP46_EXE=$gcc_dir/$gpp
      if test -f $I386_GPP46_EXE; then
         echo "checking g++...$I386_GPP46_EXE"
   echo xi386_gcc46 gpp is good
      else
         echo "checking g++...no"
   echo xi386_gcc46 gpp is bad
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
      echo xi386_gcc46a is "x$I386_GCC46_EXE"
      echo xi386_gpp46a is "x$I386_GPP46_EXE"
      dnl for plugin_compiler in $I386_GCC46_EXE $I386_GPP46_EXE; do
      for plugin_compiler in $I386_GCC46_EXE; do
         if test -f plugin_test.so; then
            rm plugin_test.so
         fi
         $plugin_compiler -I$TOPSRCDIR/etc/gcc_plugin/ -fPIC -shared plugin_test.c -o plugin_test.so -I$I386_GCC46_PLUGIN_DIR/include 2> /dev/null
         if test ! -f plugin_test.so; then
            echo "checking $plugin_compiler -I$TOPSRCDIR/etc/gcc_plugin/ -fPIC -shared plugin_test.c -o plugin_test.so -I$I386_GCC46_PLUGIN_DIR/include... no"
      echo xi386_gpp46 plugin fail1 cmd was "$plugin_compiler -I$TOPSRCDIR/etc/gcc_plugin/ -fPIC -shared plugin_test.c -o plugin_test.so -I$I386_GCC46_PLUGIN_DIR/include"
            continue
         fi
         echo "checking $plugin_compiler -I$TOPSRCDIR/etc/gcc_plugin/ -fPIC -shared plugin_test.c -o plugin_test.so -I$I386_GCC46_PLUGIN_DIR/include... yes"
      echo xi386_gpp46 plugin success1 with "$plugin_compiler"
         ac_save_CC="$CC"
         ac_save_CFLAGS="$CFLAGS"
         CC=$plugin_compiler
         CFLAGS="-fplugin=$BUILDDIR/plugin_test.so"
         AC_LANG_PUSH([C])
         AC_COMPILE_IFELSE([AC_LANG_SOURCE([[
               ]],[[
                  return 0;
               ]])],
         I386_GCC46_PLUGIN_COMPILER=$plugin_compiler,I386_GCC46_PLUGIN_COMPILER=)
         AC_LANG_POP([C])
     echo xi386_gcc46b is "x$I386_GCC46_PLUGIN_COMPILER"
         CC=$ac_save_CC
         CFLAGS=$ac_save_CFLAGS
         #If plugin compilation fails, skip this executable
         if test "x$I386_GCC46_PLUGIN_COMPILER" = x; then
      echo xi386_gpp46 plugin fail2
            continue
         fi
      echo xi386_gpp46 plugin success2
         echo "Looking for gcc46 gengtype"
         I386_GCC46_GENGTYPE=`$I386_GCC46_EXE -print-file-name=gengtype`
         if test "x$I386_GCC46_GENGTYPE" = "xgengtype"; then
            I386_GCC46_GENGTYPE=`$I386_GCC46_EXE -print-file-name=plugin/gengtype`
            if test "x$I386_GCC46_GENGTYPE" = "xplugin/gengtype"; then
               I386_GCC46_ROOT_DIR=`dirname $I386_GCC46_EXE`/..
               I386_GCC46_GENGTYPE=`find $I386_GCC46_ROOT_DIR -name gengtype | head -n1`
               if test "x$I386_GCC46_GENGTYPE" = "x"; then
                  I386_GCC46_PLUGIN_COMPILER=
         echo xi386_gcc46c is "x$I386_GCC46_PLUGIN_COMPILER"
                  continue
               fi
            fi
         fi
         echo "Looking for gtype.state"
         I386_GCC46_GTYPESTATE=`$I386_GCC46_EXE -print-file-name=gtype.state`
         if test "x$I386_GCC46_GTYPESTATE" = "xgtype.state"; then
            I386_GCC46_GTYPESTATE=`$I386_GCC46_EXE -print-file-name=plugin/gtype.state`
            if test "x$I386_GCC46_GTYPESTATE" = "xplugin/gtype.state"; then
               I386_GCC46_PLUGIN_COMPILER=
         echo xi386_gcc46d is "x$I386_GCC46_PLUGIN_COMPILER"
               continue
            fi
         fi
         echo "OK, we have found the compiler"
         build_I386_GCC46=yes;
         build_I386_GCC46_EMPTY_PLUGIN=yes;
         build_I386_GCC46_SSA_PLUGIN=yes;
         build_I386_GCC46_SSA_PLUGINCPP=yes;
         build_I386_GCC46_SSAVRP_PLUGIN=yes;
         build_I386_GCC46_TOPFNAME_PLUGIN=yes;
         break;
      done
      if test "x$I386_GCC46_PLUGIN_COMPILER" != x; then
         break;
      fi
   else
      echo "checking $compiler... not found"
   fi
done

if test x$I386_GCC46_PLUGIN_COMPILER != x; then
  dnl set configure and makefile variables
  I386_GCC46_EMPTY_PLUGIN=gcc46_plugin_dumpGimpleEmpty
  I386_GCC46_SSA_PLUGIN=gcc46_plugin_dumpGimpleSSA
  I386_GCC46_SSA_PLUGINCPP=gcc46_plugin_dumpGimpleSSACpp
  I386_GCC46_SSAVRP_PLUGIN=gcc46_plugin_dumpGimpleSSAVRP
  I386_GCC46_TOPFNAME_PLUGIN=gcc46_plugin_topfname
  AC_SUBST(I386_GCC46_EMPTY_PLUGIN)
  AC_SUBST(I386_GCC46_SSA_PLUGIN)
  AC_SUBST(I386_GCC46_SSA_PLUGINCPP)
  AC_SUBST(I386_GCC46_SSAVRP_PLUGIN)
  AC_SUBST(I386_GCC46_TOPFNAME_PLUGIN)
  AC_SUBST(I386_GCC46_PLUGIN_DIR)
  AC_SUBST(I386_GCC46_GENGTYPE)
  AC_SUBST(I386_GCC46_GTYPESTATE)
  AC_SUBST(I386_GCC46_EXE)
  AC_SUBST(I386_GCC46_VERSION)
  AC_SUBST(I386_GCC46_PLUGIN_COMPILER)
  AC_DEFINE(HAVE_I386_GCC46_COMPILER, 1, "Define if GCC 4.6 I386 compiler is compliant")
  AC_DEFINE_UNQUOTED(I386_GCC46_EXE, "${I386_GCC46_EXE}", "Define the plugin gcc")
  AC_DEFINE_UNQUOTED(I386_CPP46_EXE, "${I386_CPP46_EXE}", "Define the plugin cpp")
  AC_DEFINE_UNQUOTED(I386_GPP46_EXE, "${I386_GPP46_EXE}", "Define the plugin g++")
  AC_DEFINE_UNQUOTED(I386_GCC46_EMPTY_PLUGIN, "${I386_GCC46_EMPTY_PLUGIN}", "Define the filename of the GCC PandA Empty plugin")
  AC_DEFINE_UNQUOTED(I386_GCC46_SSA_PLUGIN, "${I386_GCC46_SSA_PLUGIN}", "Define the filename of the GCC PandA SSA plugin")
  AC_DEFINE_UNQUOTED(I386_GCC46_SSA_PLUGINCPP, "${I386_GCC46_SSA_PLUGINCPP}", "Define the filename of the GCC PandA C++ SSA plugin")
  AC_DEFINE_UNQUOTED(I386_GCC46_SSAVRP_PLUGIN, "${I386_GCC46_SSAVRP_PLUGIN}", "Define the filename of the GCC PandA SSAVRP plugin")
  AC_DEFINE_UNQUOTED(I386_GCC46_TOPFNAME_PLUGIN, "${I386_GCC46_TOPFNAME_PLUGIN}", "Define the filename of the GCC PandA topfname plugin")
  AC_DEFINE_UNQUOTED(I386_GCC46_VERSION, "${I386_GCC46_VERSION}", "Define the gcc version")
  AC_DEFINE_UNQUOTED(I386_GCC46_PLUGIN_COMPILER, "${I386_GCC46_PLUGIN_COMPILER}", "Define the plugin compiler")
fi

dnl switch back to old language
AC_LANG_POP([C])

])
