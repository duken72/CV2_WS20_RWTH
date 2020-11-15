/******************************************************************************
 * resampling.c
 *
 * defines routines to resample an image at a location u v
 *
 * Copyright (c) 1998 Frank Dellaert
 * All rights reserved
 *****************************************************************************/

#include <math.h>

/******************************************************************************
 * take nearest sample from original at (iu:int, iv:int)
 *****************************************************************************/

double sampleNearest(const double *original, int nrRowsOriginal, int iu, int iv)
  {
  /* calculate 1D index (base 1) */
  int indexInOriginal = iv + (iu-1)*nrRowsOriginal;
  
  double resampled=original[indexInOriginal];

  return resampled;
  }

/******************************************************************************
 * take bilinearly interpolated sample from original at (u:double, v:double)
 *****************************************************************************/

double sampleBilinear(const double *original, int nrRowsOriginal, double u, double v)
  {
  /* get north-west (NW) corner coordinates and add 1 to get SW */
  int Wu=(int)floor(u+0.5),Eu=Wu+1;
  int Nv=(int)floor(v+0.5),Sv=Nv+1;

  /* get base 1 integer indices of all corners */
  int NW = Nv + (Wu-1)*nrRowsOriginal;
  int NE = Nv + (Eu-1)*nrRowsOriginal;
  int SE = Sv + (Eu-1)*nrRowsOriginal;
  int SW = Sv + (Wu-1)*nrRowsOriginal;

  /* calculate weights for each corner */
  double wN=(Sv-0.5-v), wS=1.0-wN;
  double wW=(Eu-0.5-u), wE=1.0-wW;
  double wNW=wN*wW, wNE=wN*wE, wSE=wS*wE, wSW=wS*wW;

  /* resample */
  double resampled = wNW*original[NW]
                   + wNE*original[NE]
                   + wSE*original[SE]
                   + wSW*original[SW];

  return resampled;
  }

/******************************************************************************/
