/**
 * Porting of the libm library to the PandA framework
 * starting from the original FDLIBM 5.3 (Freely Distributable LIBM) developed by SUN
 * plus the newlib version 1.19 from RedHat and plus uClibc version 0.9.32.1 developed by Erik Andersen.
 * The author of this port is Fabrizio Ferrandi from Politecnico di Milano.
 * The porting fall under the LGPL v2.1, see the files COPYING.LIB and COPYING.LIBM_PANDA in this directory.
 * Date: September, 11 2013.
 */
/* wf_fmod.c -- float version of w_fmod.c.
 * Conversion to float by Ian Lance Taylor, Cygnus Support, ian@cygnus.com.
 */

/*
 * ====================================================
 * Copyright (C) 1993 by Sun Microsystems, Inc. All rights reserved.
 *
 * Developed at SunPro, a Sun Microsystems, Inc. business.
 * Permission to use, copy, modify, and distribute this
 * software is freely granted, provided that this notice
 * is preserved.
 * ====================================================
 */

/*
 * wrapper fmodf(x,y)
 */

#include "math_privatef.h"
#ifndef _IEEE_LIBM
#include <errno.h>
#endif

float fmodf(float x, float y) /* wrapper fmodf */
{
#ifdef _IEEE_LIBM
   return __hide_ieee754_fmodf(x, y);
#else
   float z;
   struct exception exc;
   z = __hide_ieee754_fmodf(x, y);
   if(_LIB_VERSION == _IEEE_ || isnanf(y) || isnanf(x))
      return z;
   if(y == (float)0.0)
   {
      /* fmodf(x,0) */
      exc.type = DOMAIN;
      exc.name = "fmodf";
      exc.err = 0;
      exc.arg1 = (double)x;
      exc.arg2 = (double)y;
      if(_LIB_VERSION == _SVID_)
         exc.retval = x;
      else
         exc.retval = 0.0 / 0.0;
      if(_LIB_VERSION == _POSIX_)
         errno = EDOM;
      else if(!matherr(&exc))
      {
         errno = EDOM;
      }
      if(exc.err != 0)
         errno = exc.err;
      return (float)exc.retval;
   }
   else
      return z;
#endif
}

#ifdef _DOUBLE_IS_32BITS

double fmod(double x, double y)
{
   return (double)fmodf((float)x, (float)y);
}

#endif /* defined(_DOUBLE_IS_32BITS) */
