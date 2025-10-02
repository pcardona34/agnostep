/*
 *  FFT.c
 *  PRICE
 *
 *  Created by Riccardo Mottola on Sat Sep 13 2003.
 *  Copyright (c) 2002-2005 Carduus. All rights reserved.
 *
 */

// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#include "FFT.h"

double *cosinus;
double *sinus;
unsigned int *bitRevIndex;

int initTrigonometrics(int num, unsigned int bitNumber)
/* we init here the trigonometric arrays
   but we also init the bit reerse array */
{
    int i;
    double alpha;
    
    alpha = (2 * PI) / num;
    for (i = 0; i < num; i++)
    {
        cosinus[i] = cos(-alpha * i);
        sinus[i] = sin(-alpha * i);
    }

    for (i = 0; i < num; i++)
        bitRevIndex[i] = bitrev(i, bitNumber);
        
    return 0;
}

unsigned int binaryLog(unsigned int a)
/* returns the smallest 2 power that contains the a */
{
    unsigned int i;
    unsigned int j;
    
    i = 1;
    j = 1;
    while (i < a)
    {
        i = i << 1;
        j++;
    }
    return j - 1;
}

unsigned int binpow(unsigned int n)
{
    return 1 << n;
}

unsigned int bitrev(unsigned int i, unsigned int len)
/* returns the bit-reverse of i given the bit number to work on */
{
    unsigned int r;
    unsigned int j;
    
    r = 0;
    for (j = 0; j < len-1; j++) /* we don't have to shift for the last position */
    {
        r = r | (i & 1);
        r = r << 1;
        i = i >> 1;
    }
    r = r | (i & 1);
    return r;
}

int fft(int num, unsigned int bitNumber, double Ar[], double Ai[], double yr[], double yi[])
{
    unsigned int i;
    unsigned int s;
    unsigned int m;
    unsigned int j;
    unsigned int k;
    register double omega_r, omega_i;  /* current unity root */
    register unsigned int gamma;
    register double t_r, t_i;
    register double u_r, u_i;
            
    for (i = 0; i < num; i++) /* exponents are 0 to n-1 for n bits */
    {
        yr[bitRevIndex[i]] = Ar[i];
        yi[bitRevIndex[i]] = Ai[i];
    }
    for (s = 1; s <= bitNumber; s++)
    {
        m = binpow(s);
        for (j = 0; j  < m/2; j++)
        {
            gamma = ((num / m) * j) % num;
            omega_r = cosinus[gamma];
            omega_i = sinus[gamma];
            for (k = j; k < num; k += m)
            {
                t_r = omega_r * yr[k + m/2] - omega_i * yi[k + m/2];
                t_i = omega_r * yi[k + m/2] + omega_i * yr[k + m/2];
                u_r = yr[k];
                u_i = yi[k];
                yr[k] = u_r + t_r;
                yi[k] = u_i + t_i;
                yr[k + m/2] = u_r - t_r;
                yi[k + m/2] = u_i - t_i;
            }
        }
    }
    return 0;
}

int ifft(int num, unsigned int bitNumber, double Ar[], double Ai[], double yr[], double yi[])
{
    unsigned int i;
    unsigned int s;
    unsigned int m;
    unsigned int j;
    unsigned int k;
    register double omega_r, omega_i;  /* current unity root */
    register unsigned int gamma;
    register double t_r, t_i;
    register double u_r, u_i;
        
    
    for (i = 0; i < num; i++) /* exponents are 0 to n-1 for n bits */
    {
        yr[bitRevIndex[i]] = Ar[i];
        yi[bitRevIndex[i]] = Ai[i];
    }
    for (s = 1; s <= bitNumber; s++)
    {
        m = binpow(s);
        for (j = 0; j  < m/2; j++)
        {
            /* we follow the unity roots in the opposite direction */
            /* but since sin(-a) = -sin(a) but cos(-a)=cos(a) just a sign is needed */
            gamma = ((num / m) * j) % num;
            omega_r = cosinus[gamma];
            omega_i = -sinus[gamma];
            for (k = j; k < num; k += m)
            {
                t_r = omega_r * yr[k + m/2] - omega_i * yi[k + m/2];
                t_i = omega_r * yi[k + m/2] + omega_i * yr[k + m/2];
                u_r = yr[k];
                u_i = yi[k];
                yr[k] = u_r + t_r;
                yi[k] = u_i + t_i;
                yr[k + m/2] = u_r - t_r;
                yi[k + m/2] = u_i - t_i;
            }
        }
    }
    for (i = 0; i < num; i++)
    {
        yr[i] = yr[i]/num;
        yi[i] = yi[i]/num;
    }
    return 0;
}
