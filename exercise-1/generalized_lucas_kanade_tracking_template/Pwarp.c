/******************************************************************************
 * Pwarp.c
 *
 * MEX file to do projective warp
 * Fast version for contiguous image based on first differences
 * Same functionality as Pwarp.m (but about 8 times faster for 640*320 warp)
 *
 * Copyright (c) 1998 Frank Dellaert
 * All rights reserved
 *****************************************************************************/

#include <math.h>
#include "resampling.h"

/******************************************************************************
 * fully specified Pwarp, completely C. No mex stuff here...
 * However: all pointers use -1 trick to get base 1 integer access
 *****************************************************************************/

#define crop 0.5

void Pwarp(const double *original, int m, int n,
           const double *H,
           const double *mosaic,
           int blend,
           double *warped, double *goodpix, 
	   int nrRowsWarped, int nrColsWarped
          )
  {
  /* get homography coefficients      */
  double a=H[1],b=H[4],c=H[7],
         d=H[2],e=H[5],f=H[8],
         g=H[3],h=H[6],i=H[9];

  int ix,iy;     /* integer coordinates in warped */

  /* for each scanline */
  for(iy=1;iy<=nrRowsWarped;iy++) 
    {
    double U,V,W;             /* homogeneous coordinates in original */
    int indexInWarped = iy;  /* integer index (base 1) in warped */

    /* calculate the first preimage in the scanline */
    {
    double x = 0.5, y = iy - 0.5;  /* double coordinates in warped */
    U = a*x + b*y + c;
    V = d*x + e*y + f;
    W = g*x + h*y + i;
    }

    for (ix=1;ix<=nrColsWarped;ix++)
      {
      /*calculate image coordinates in original */
      double u = U/W, v = V/W;
      
      /* filter out pixels that land outside original */
      int good = v>crop && v<m-crop && u>crop && u<n-crop;
      
      if (good)
        {
        double resampled = sampleBilinear(original,m,u,v);
	goodpix[indexInWarped] = 1;
        
        /* (primitive) blend or not */
        if (blend)
          warped[indexInWarped]=(mosaic[indexInWarped]+resampled)/2;
        else
          warped[indexInWarped]=resampled;
        }
      else {
	goodpix[indexInWarped] = 0;
        if (mosaic)
          warped[indexInWarped]=mosaic[indexInWarped];
      }
      /* update by first differencing */
      U += a; V += d; W += g; indexInWarped += nrRowsWarped;
      }
    }
  }

/******************************************************************************
 * all MEX stuff below this line
 *****************************************************************************/

#include "mex.h"

/******************************************************************************
 * 4 argument version
 * all pointers use -1 trick to get base 1 integer access
 *****************************************************************************/

mxArray *goodpix;

mxArray *Pwarp4(const mxArray *original, const mxArray *H, const mxArray *mosaic, int blend)
  {
  /* get image size */
  int m = mxGetM(original);
  int n = mxGetN(original);

  /* create a warped image the same size as the mosaic */
  int nrRowsWarped = mxGetM(mosaic);
  int nrColsWarped = mxGetN(mosaic);
  mxArray *warped = mxCreateDoubleMatrix(nrRowsWarped,nrColsWarped,mxREAL);

  /* get pointers to data */
  double * HPr        = mxGetPr(H)       -1;
  double * warpedPr   = mxGetPr(warped)  -1;
  double * originalPr = mxGetPr(original)-1;
  double * mosaicPr   = mxGetPr(mosaic)  -1;

  double *goodPr;
  goodpix = mxCreateDoubleMatrix(nrRowsWarped,nrColsWarped,mxREAL);
  goodPr     = mxGetPr(goodpix)    -1;

  Pwarp(originalPr, m, n,
        HPr, mosaicPr, blend,
        warpedPr, goodPr, nrRowsWarped, nrColsWarped
        );

  return warped;
  }

/******************************************************************************
 * three argument version
 *****************************************************************************/

mxArray *Pwarp3(const mxArray *original, const mxArray *H, const mxArray *mosaic)
  {
  return Pwarp4(original, H, mosaic, 0);
  }

/******************************************************************************
 * two argument version
 * all pointers use -1 trick to get base 1 integer access
 *****************************************************************************/

mxArray *Pwarp2(const mxArray *original, const mxArray *H)
  {
  /* get image size */
  int m = mxGetM(original);
  int n = mxGetN(original);

  /* create a warped image the same size as the original */
  int nrRowsWarped = m;
  int nrColsWarped = n;
  mxArray *warped = mxCreateDoubleMatrix(nrRowsWarped,nrColsWarped,mxREAL);

  /* get pointers to data */
  double * HPr        = mxGetPr(H)       -1;
  double * warpedPr   = mxGetPr(warped)  -1;
  double * originalPr = mxGetPr(original)-1;

  double *goodPr;
  goodpix = mxCreateDoubleMatrix(nrRowsWarped,nrColsWarped,mxREAL);
  goodPr     = mxGetPr(goodpix)    -1;

  Pwarp(originalPr, m, n,
        HPr, NULL, 0,
        warpedPr, goodPr, nrRowsWarped, nrColsWarped
        );

  return warped;
  }

/******************************************************************************
 * function warped = Pwarp(original,H,mosaic,blend)
 * hack: mere existence of input argument blend makes blend=1
 *****************************************************************************/

void mexFunction(int nargout, mxArray *out[], int nargin, const mxArray	*in[])
  {
  mxArray *warped;

  if (nargout>2) goto usage;

  switch(nargin)
    {
    case 2: warped = Pwarp2(in[0],in[1]); break;
    case 3: warped = Pwarp3(in[0],in[1],in[2]); break;
    case 4: warped = Pwarp4(in[0],in[1],in[2],1); break;
    default: goto usage;
    }

  out[0] = warped;
  out[1] = goodpix;
  return;

usage:
  mexErrMsgTxt("usage: [warped, goodpix] = Pwarp(original,H[,mosaic,blend])");
  }

/******************************************************************************/
