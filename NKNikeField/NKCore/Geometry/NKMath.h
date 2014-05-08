//
//  NKMath.h
//  NKNikeField
//
//  Created by Leif Shackelford on 5/7/14.
//  Copyright (c) 2014 Chroma Developer. All rights reserved.
//

#ifndef NKNikeField_NKMath_h
#define NKNikeField_NKMath_h

static inline float CGClamp(float n, float min, float max)
{
    return MIN(MAX(n,min),max);
}

static inline float CGMap(float n, float minIn, float maxIn, float minOut, float maxOut)
{
    float inRange = maxIn - minIn;
    float outRange = maxOut - minOut;
    float scalarN = (n-minIn) / inRange;
    float ret = minOut + (outRange * scalarN);
    if(isinf(ret) || isnan(ret)){
        ret = maxOut;
    }else{
        ret = CGClamp(ret, minOut, maxOut);
    }
    return ret;
}

static inline float RandScalar()
{
    return rand() / (float)RAND_MAX;
}

#endif
