/*
 *  FFT.h
 *  PRICE
 *
 *  Created by Riccardo Mottola on Sat Sep 13 2003.
 *  Copyright (c) 2002-2003 Carduus. All rights reserved.
 *
 */

// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#include <math.h>
#include <limits.h>
#include <float.h>

#define PI 3.14159265359

int initTrigonometrics(int num, unsigned int bitNumber);
unsigned int binaryLog(unsigned int a);
unsigned int binpow(unsigned int n);
unsigned int bitrev(unsigned int i, unsigned int len);
int fft(int num, unsigned int bitNumber, double Ar[], double Ai[], double yr[], double yi[]);
int ifft(int num, unsigned int bitNumber, double Ar[], double Ai[], double yr[], double yi[]);
