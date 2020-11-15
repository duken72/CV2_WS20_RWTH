/******************************************************************************
 * resampling.h
 *
 * declares routines to resample an image at a location u v
 *
 * Copyright (c) 1998 Frank Dellaert
 * All rights reserved
 *****************************************************************************/

#ifndef RESAMPLING
#define RESAMPLING

double sampleNearest(const double *original, int nrRowsOriginal, int iu, int iv);
double sampleBilinear(const double *original, int nrRowsOriginal, double u, double v);

#endif

/******************************************************************************/
