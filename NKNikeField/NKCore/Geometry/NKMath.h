//
//  NKMath.h
//  NKNikeField
//
//  Created by Leif Shackelford on 5/7/14.
//  Copyright (c) 2014 Chroma Developer. All rights reserved.
//

#ifndef NKNikeField_NKMath_h
#define NKNikeField_NKMath_h

static inline F1t sgn(F1t val)
{
	return (val > 0.0f) ? 1.0f : ((val < 0.0f) ? -1.0f : 0.0f);
}

static inline F1t clampf(F1t n, F1t min, F1t max)
{
    return MIN(MAX(n,min),max);
}


static inline F1t weightedAverage (F1t src, F1t dst, F1t d){
    
    return src == dst ? src : (src * (1.-d) + dst * d);
   
}

static inline V3t getTweenPoint(V3t src, V3t dst, F1t d){
    return V3Make(weightedAverage(src.x, dst.x, d),
                  weightedAverage(src.y, dst.y, d),
                  weightedAverage(src.z, dst.z, d));
}


static inline P2t polToCar(P2t pol) {
    
    P2t car;
    
    car.x = pol.x*cosf(pol.y);
    car.y = pol.x*sin(pol.y);
    
    return car;
    
}

static inline P2t carToPol(P2t car){
    
    P2t pol;
    
    pol.x = sqrt(car.x*car.x + car.y*car.y);
    pol.y = atan2( car.y, car.x );
    
    return pol;
    
}


static inline F1t CGMap(F1t n, F1t minIn, F1t maxIn, F1t minOut, F1t maxOut)
{
    F1t inRange = maxIn - minIn;
    F1t outRange = maxOut - minOut;
    F1t scalarN = (n-minIn) / inRange;
    F1t ret = minOut + (outRange * scalarN);
    if(isinf(ret) || isnan(ret)){
        ret = maxOut;
    }else{
        ret = clampf(ret, minOut, maxOut);
    }
    return ret;
}

static inline F1t RandScalar()
{
    return rand() / (F1t)RAND_MAX;
}

#endif
