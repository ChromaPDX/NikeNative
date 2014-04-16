
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <CoreGraphics/CoreGraphics.h>

#if defined(__ARM_NEON__)
#import <arm_neon.h>
#endif

#pragma mark -
#pragma mark NK VECTOR TYPES
#pragma mark -

#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) / 180.0 * M_PI)
#define CONVERT_UV_U_TO_ST_S(u) ((2*u) / M_PI)

typedef GLubyte U1t;
typedef GLfloat F1t;
typedef CGPoint P2t;
typedef CGSize S2t;

typedef struct {
	F1t x;
	F1t y;
	F1t z;
} V3t ; // VECTOR 3

typedef struct {
	GLushort	i1;
	GLushort	i2;
	GLushort	i3;
} I3t; // INDEX 3

typedef struct {
	V3t	v1;
	V3t	v2;
	V3t	v3;
} T3t; // INDEX 3

union _C4t {
    struct
    
    {
    F1t r;
	F1t g;
	F1t b;
    F1t a;
    };
    
    F1t p[4];
    
}; // COLOR 4

typedef union _C4t C4t;

typedef struct {
	F1t x;
	F1t y;
	F1t z;
    F1t w;
} Q4t; // QUATERNION 4

typedef struct {
	F1t a;
	F1t x;
	F1t y;
    F1t z;
} A4t; // ANGLE+AXIS 4

typedef struct {
	F1t x;
	F1t y;
	F1t w;
    F1t h;
} R4t; // RECTANGLE 4

union _V9t
{
    struct
    {
        V3t xAxis;
        V3t yAxis;
        V3t zAxis;
    };
    
    F1t m[9];
} ;

typedef union _V9t V9t;

union _M16t
{
    struct
    {
        F1t m00, m01, m02, m03;
        F1t m10, m11, m12, m13;
        F1t m20, m21, m22, m23;
        F1t m30, m31, m32, m33;
    };
    struct
    {
        F1t a[4][4];
    };
    
    F1t m[16];
} __attribute__((aligned(16)));

typedef union _M16t M16t;

#pragma MAKE FUNCTIONS

static inline V3t  V3Make(F1t x, F1t y, F1t z)
{
	V3t  ret = {x,y,z};
	return ret;
}

static inline T3t T3Make(V3t v1,V3t v2,V3t v3){
    T3t T3;
    
    T3.v1 = v1;
    T3.v2 = v2;
    T3.v3 = v3;
    
    return T3;
}



static inline Q4t Q4Make(float x, float y, float z, float w)
{
    Q4t q = { x, y, z, w };
    return q;
}

static inline Q4t Q4MakeIdentity(){
    return Q4Make(0,0,0,1.);
}

static inline C4t C4Make(float r, float g, float b, float a)
{
    C4t c = { r, g, b, a };
    return c;
}

static inline R4t R4Make(float x, float y, float w, float h)
{
    R4t r = { x, y, w, h };
    return r;
}

static inline A4t A4Make(float angle, float x, float y, float z){
    A4t A4;
    
    A4.a = angle;
    A4.x = x;
    A4.y = y;
    A4.z = z;
    
    return A4;
}


static inline M16t M16IdentityMake(){
    M16t ret;
    ret.m[0] = ret.m[5] = ret.m[10] = ret.m[15] = 1.0;
    ret.m[1] = ret.m[2] = ret.m[3] = ret.m[4] = 0.0;
    ret.m[6] = ret.m[7] = ret.m[8] = ret.m[9] = 0.0;
    ret.m[11] = ret.m[12] = ret.m[13] = ret.m[14] = 0.0;
    return ret;
}

#pragma mark - Point 2 Type

#define P2Make CGPointMake

static inline P2t P2Add (P2t a, P2t b){
    return P2Make(a.x + b.x, a.y + b.y);
}

static inline P2t P2Subtract (P2t a, P2t b){
    return P2Make(a.x - b.x, a.y - b.y);
}

static inline P2t P2Divide (P2t a, P2t b){
    return P2Make(a.x / b.x, a.y / b.y);
}

static inline P2t P2DivideFloat (P2t a, F1t b){
    return P2Make(a.x / b, a.y / b);
}

static inline bool P2Bool(P2t a){
    if (a.x != 0 || a.y != 0) {
        return true;
    }
    return false;
}

static inline F1t weightedAverage (F1t src, F1t dst, F1t d){
    
    return src == dst ? src : ((src * (1.-d) + dst * d));
    
}

static inline V3t getTweenPoint(V3t src, V3t dst, F1t d){
    return V3Make(weightedAverage(src.x, dst.x, d),
                  weightedAverage(src.y, dst.y, d),
                  weightedAverage(src.z, dst.z, d));
}


static inline CGPoint polToCar(CGPoint pol) {
    
    CGPoint car;
    
    car.x = pol.x*cosf(pol.y);
    car.y = pol.x*sin(pol.y);
    
    return car;
    
}

static inline CGPoint carToPol(CGPoint car){
    
    CGPoint pol;
    
    pol.x = sqrt(car.x*car.x + car.y*car.y);
    pol.y = atan2( car.y, car.x );
    
    return pol;
    
}

#pragma mark - Vector 3 Type

static inline V3t V3FromQ4(Q4t q1) {
    
    V3t  euler;
    
    double sqw = q1.w*q1.w;
    double sqx = q1.x*q1.x;
    double sqy = q1.y*q1.y;
    double sqz = q1.z*q1.z;
    
	double unit = sqx + sqy + sqz + sqw; // if normalised is one, otherwise is correction factor
	double test = q1.x*q1.y + q1.z*q1.w;
	if (test > 0.499*unit) { // singularity at north pole
		euler.x = 2. * atan2(q1.x,q1.w);
		euler.y = M_PI/2.;
		euler.z = 0.;
        
        return euler;
        
	}
	else if (test < -0.499*unit) { // singularity at south pole
		euler.x = -2. * atan2(q1.x,q1.w);
		euler.y = -M_PI/2.;
		euler.z = 0;
        
        return euler;
	}
    else {
        
        euler.x = atan2(2.*q1.y*q1.w-2*q1.x*q1.z , sqx - sqy - sqz + sqw);
        euler.y = asin(2.*test/unit);
        euler.z = atan2(2.*q1.x*q1.w-2*q1.y*q1.z , -sqx + sqy - sqz + sqw);
        
        return euler;
        
    }
    
    
}

static inline V3t V3Add(V3t vectorLeft, V3t vectorRight)
{
    V3t v = { vectorLeft.x + vectorRight.x,
        vectorLeft.y + vectorRight.y,
        vectorLeft.z + vectorRight.z };
    return v;
}

static inline V3t V3Subtract(V3t vectorLeft, V3t vectorRight)
{
    V3t v = { vectorLeft.x - vectorRight.x,
            vectorLeft.y - vectorRight.y,
            vectorLeft.z - vectorRight.z };
    return v;
}

static inline V3t V3Multiply(V3t vectorLeft, V3t vectorRight)
{
    V3t v = { vectorLeft.x * vectorRight.x,
        vectorLeft.y * vectorRight.y,
        vectorLeft.z * vectorRight.z };
    return v;
}

static inline V3t V3Divide(V3t vectorLeft, V3t vectorRight)
{
    V3t v = { vectorLeft.x / vectorRight.x,
        vectorLeft.y / vectorRight.y,
        vectorLeft.z / vectorRight.z };
    return v;
}

static inline V3t V3Negate(V3t vector)
{
    V3t v = { -vector.x, -vector.y, -vector.z};
    return v;
}

static inline V3t V3AddScalar(V3t vector, float value)
{
    V3t v = { vector.x + value,
        vector.y + value,
        vector.z + value };
    return v;
}

static inline V3t V3SubtractScalar(V3t vector, float value)
{
    V3t v = { vector.x - value,
        vector.y - value,
        vector.z - value };
    return v;
}

static inline V3t V3MultiplyScalar(V3t vector, float value)
{
    V3t v = { vector.x * value,
        vector.y * value,
        vector.z * value };
    return v;
}

static inline V3t V3DivideScalar(V3t vector, float value)
{
    V3t v = { vector.x / value,
        vector.y / value,
        vector.z / value };
    return v;
}


static inline F1t V3Length(V3t vector)
{
    return sqrtf(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z);
}

static inline V3t V3Normalize(V3t vector)
{
    F1t scale = 1.0f / V3Length(vector);
    V3t v = { vector.x * scale, vector.y * scale, vector.z * scale };
    return v;
}

static inline float V3DotProduct(V3t vectorLeft, V3t vectorRight)
{
    return vectorLeft.x * vectorRight.x + vectorLeft.y * vectorRight.y + vectorLeft.z * vectorRight.z;
}


static inline float V3Distance(V3t vectorStart, V3t vectorEnd)
{
    return V3Length(V3Subtract(vectorEnd, vectorStart));
}

static inline V3t V3Lerp(V3t vectorStart, V3t vectorEnd, float t)
{
    V3t v = { vectorStart.x + ((vectorEnd.x - vectorStart.x) * t),
        vectorStart.y + ((vectorEnd.y - vectorStart.y) * t),
        vectorStart.z + ((vectorEnd.z - vectorStart.z) * t) };
    return v;
}

static inline V3t V3CrossProduct(V3t vectorLeft, V3t vectorRight)
{
    V3t v = { vectorLeft.y * vectorRight.z - vectorLeft.z * vectorRight.y,
        vectorLeft.z * vectorRight.x - vectorLeft.x * vectorRight.z,
        vectorLeft.x * vectorRight.y - vectorLeft.y * vectorRight.x };
    return v;
}

static inline V3t V3Project(V3t vectorToProject, V3t projectionVector)
{
    float scale = V3DotProduct(projectionVector, vectorToProject) / V3DotProduct(projectionVector, projectionVector);
    V3t v = V3MultiplyScalar(projectionVector, scale);
    return v;
}

static inline V3t V3MakeFromPoints(V3t start, V3t end){
    V3t ret = V3Subtract(end, start);
    V3Normalize(ret);
    return ret;
}

static inline V3t V3GetM16Translation(M16t M16) {
	return V3Make(M16.m30,M16.m31,M16.m32);
}

static inline V3t V3GetM16Scale(M16t M16) {
	V3t x_vec = V3Make(M16.m00,M16.m10,M16.m20);
	V3t y_vec = V3Make(M16.m01,M16.m11,M16.m21);
	V3t z_vec = V3Make(M16.m02,M16.m12,M16.m22);
	return V3Make(V3Length(x_vec), V3Length(y_vec), V3Length(z_vec));
}

// --------------------------------------------------------------------------------------------
// This is an implementation of the famous Quake fast inverse square root algorithm. Although
// it comes from the Quake 3D code, which was released under the GPL, John Carmack has stated
// that this code was not written by him or his ID counterparts. The actual origins of this
// algorithm have never been definitively found, but enough different people have contributed
// to it that I believe it is safe to assume it's in the public domain.
// --------------------------------------------------------------------------------------------
static inline F1t InvSqrt(F1t x)
{
	GLfloat xhalf = 0.5f * x;
	NSInteger i = *(NSInteger*)&x;	// store floating-point bits in integer
	i = 0x5f3759d5 - (i >> 1);		// initial guess for Newton's method
	x = *(GLfloat*)&i;				// convert new bits into float
	x = x*(1.5f - xhalf*x*x);		// One round of Newton's method
	return x;
}
// END Fast invqrt code -----------------------------------------------------------------------
static inline F1t V3FastInverseMagnitude(V3t vector)
{
	return InvSqrt((vector.x * vector.x) + (vector.y * vector.y) + (vector.z * vector.z));
}
static inline void V3FastNormalize(V3t *vector)
{
	F1t vecInverseMag = V3FastInverseMagnitude(*vector);
	if (vecInverseMag == 0.0)
	{
		vector->x = 1.0;
		vector->y = 0.0;
		vector->z = 0.0;
	}
	vector->x *= vecInverseMag;
	vector->y *= vecInverseMag;
	vector->z *= vecInverseMag;
}

#pragma mark - Triangle 3 Type


static inline V3t V3GetTriangleSurfaceNormal(T3t triangle)
{
    
	V3t u = V3MakeFromPoints(triangle.v2, triangle.v1);
	V3t v = V3MakeFromPoints(triangle.v3, triangle.v1);
	
	V3t ret;
	ret.x = (u.y * v.z) - (u.z * v.y);
	ret.y = (u.z * v.x) - (u.x * v.z);
	ret.z = (u.x * v.y) - (u.y * v.x);
	return ret;
}

#pragma mark - Rect 4 Type


//
//void getOrthonormals(V3t  normal, V3t  orthonormal1, V3t  *orthonormal2)
//{
//    M16t OrthoX;
//    M16RotateX(90, OrthoX);
//
//    M16t OrthoY;
//    M16RotateY(90, OrthoY);
//
//    V3t  w = transformByMatrix(normal, &OrthoX);
//
//    float dot = normal.dot(w);
//
//    if (fabsf(dot) > 0.6)
//    {
//        w = transformByMatrix(normal, &OrthoY);
//        OrthoY * normal;
//    }
//    w.normalize();
//
//    *orthonormal1 = normal.cross(w);
//    orthonormal1->normalize();
//    *orthonormal2 = normal.cross(*orthonormal1);
//    orthonormal2->normalize();
//}

//float getQuaternionTwist(Q4t q, V3t  axis)
//{
//    axis.normalize();
//
//    //get the plane the axis is a normal of
//    V3t  orthonormal1, orthonormal2;
//
//    getOrthonormals(axis, &orthonormal1, &orthonormal2);
//
//    V3t  transformed = orthonormal1 * q;
//
//    //project transformed vector onto plane
//    V3t  flattened = transformed - transformed.dot(axis) * axis;
//    flattened.normalize();
//
//
//    //get angle between original vector and projected transform to get angle around normal
//    float a = (float)acosf(orthonormal1.dot(flattened));
//
//    return a;
//
//}

//V3t  transformByMatrix(V3t  v, M16t* m)
//{
//    V3t  result;
//    for ( int i = 0; i < 4; ++i )
//        result.m[i] = v[0] * m->_mat[0][i] + v[1] * m->_mat[1][i] + v[2] + m->_mat[2][i] + v[3] * m->_mat[3][i];
//    result.m[0] = result.m[0]/result.m[3];
//    result.m[1] = result.m[1]/result.m[3];
//    result.m[2] = result.m[2]/result.m[3];
//    return result.m;
//}

//static inline void getSwingTwistQuaternions( const Q4t& rotation,
//                                     const V3t &      direction,
//                                     Q4t&       swing,
//                                     Q4t&       twist)
//{
//    V3t  ra = rotation.asVec3(); // rotation axis
//    V3t  p = parallelProjection(ra,direction); // projection( ra, direction ); // return projection v1 on to v2  (parallel component)
//    twist.set( p.x, p.y, p.z, rotation.w() );
//    twist.normalize();
//    swing = rotation * twist.conj();
//}
//
//V3t  parallelProjection(V3t  vec1, V3t  vec2){
//    V3t  t = vec2.normalized();
//    return t*vec1.dot(t);
//}

#pragma mark - Q4 - QUATERNION TYPE



//static inline Q4t Q4FromV3(V3t  vector, float scalar)
//{
//    Q4t q = { vector.x, vector.y, vector.z, scalar };
//    return q;
//}

static inline Q4t Q4FromV3(V3t euldeg)
{
    Q4t quat;
    V3t eul = V3Make(DEGREES_TO_RADIANS(euldeg.z),DEGREES_TO_RADIANS(euldeg.y),DEGREES_TO_RADIANS(euldeg.x));
    
    float cr, cp, cy, sr, sp, sy, cpcy, spsy;
    // calculate trig identities
    cr = cos(eul.z/2.);
    cp = cos(eul.y/2.);
    cy = cos(eul.x/2.);
    sr = sin(eul.z/2.);
    sp = sin(eul.y/2.);
    sy = sin(eul.x/2.);
    cpcy = cp * cy;
    spsy = sp * sy;
    quat.w = cr * cpcy + sr * spsy;
    quat.x = sr * cpcy - cr * spsy;
    quat.y = cr * sp * cy + sr * cp * sy;
    quat.z = cr * cp * sy - sr * sp * cy;
    
    return quat;
}

static inline Q4t Q4FromArray(float values[4])
{
#if defined(GLK_SSE3_INTRINSICS)
    __m128 v = _mm_load_ps(values);
    return *(Q4t *)&v;
#else
    Q4t q = { values[0], values[1], values[2], values[3] };
    return q;
#endif
}

static inline Q4t Q4FromA4(A4t A4)
{
    float halfAngle = A4.a * 0.5f;
    float scale = sinf(halfAngle);
    Q4t q = { scale * A4.x, scale * A4.y, scale * A4.z, cosf(halfAngle) };
    return q;
}

static inline Q4t Q4FromAngleAndV3(float degrees, V3t  axisVector)
{
    return Q4FromA4(A4Make(DEGREES_TO_RADIANS(degrees), axisVector.x, axisVector.y, axisVector.z));
}

static inline Q4t Q4FromAngleAndAxes(float degrees, float x, float y, float z)
{
    return Q4FromA4(A4Make(DEGREES_TO_RADIANS(degrees), x, y, z));
}

static inline Q4t Q4Add(Q4t quaternionLeft, Q4t quaternionRight)
{
#if defined(__ARM_NEON__)
    float32x4_t v = vaddq_f32(*(float32x4_t *)&quaternionLeft,
                              *(float32x4_t *)&quaternionRight);
    return *(Q4t *)&v;
#elif defined(GLK_SSE3_INTRINSICS)
    __m128 v = _mm_load_ps(&quaternionLeft.x) + _mm_load_ps(&quaternionRight.x);
    return *(Q4t *)&v;
#else
    Q4t q = { quaternionLeft.x + quaternionRight.x,
        quaternionLeft.y + quaternionRight.y,
        quaternionLeft.z + quaternionRight.z,
        quaternionLeft.w + quaternionRight.w };
    return q;
#endif
}

/* Return product of quaternion q by scalar w. */
static inline Q4t Q4Scale(Q4t q, double w)
{
	Q4t qq;
    
	qq.w = q.w*w;
	qq.x = q.x*w;
	qq.y = q.y*w;
	qq.z = q.z*w;
    
	return (qq);
}

// THIS IS AN ALTERNATE Q4 GETTER THAN OF VERSION

static inline float SIGN(float x) {return (x >= 0.0f) ? +1.0f : -1.0f;}
static inline float NORM(float a, float b, float c, float d) {return sqrt(a * a + b * b + c * c + d * d);}

static inline Q4t Q4GetM16Rotate(M16t M16){
    
    Q4t quaternion;
    
    quaternion.x = ( M16.m11 + M16.m22 + M16.m33 + 1.0f) / 4.0f;
    quaternion.y = ( M16.m11 - M16.m22 - M16.m33 + 1.0f) / 4.0f;
    quaternion.z = (-M16.m11 + M16.m22 - M16.m33 + 1.0f) / 4.0f;
    quaternion.w = (-M16.m11 - M16.m22 + M16.m33 + 1.0f) / 4.0f;
    
    if(quaternion.x < 0.0f) quaternion.x = 0.0f;
    if(quaternion.y < 0.0f) quaternion.y = 0.0f;
    if(quaternion.z < 0.0f) quaternion.z = 0.0f;
    if(quaternion.w < 0.0f) quaternion.w = 0.0f;
    quaternion.x = sqrt(quaternion.x);
    quaternion.y = sqrt(quaternion.y);
    quaternion.z = sqrt(quaternion.z);
    quaternion.w = sqrt(quaternion.w);
    if(quaternion.x >= quaternion.y && quaternion.x >= quaternion.z && quaternion.x >= quaternion.w) {
        quaternion.x *= +1.0f;
        quaternion.y *= SIGN(M16.m32 - M16.m23);
        quaternion.z *= SIGN(M16.m13 - M16.m31);
        quaternion.w *= SIGN(M16.m21 - M16.m12);
    } else if(quaternion.y >= quaternion.x && quaternion.y >= quaternion.z && quaternion.y >= quaternion.w) {
        quaternion.x *= SIGN(M16.m32 - M16.m23);
        quaternion.y *= +1.0f;
        quaternion.z *= SIGN(M16.m21 + M16.m12);
        quaternion.w *= SIGN(M16.m13 + M16.m31);
    } else if(quaternion.z >= quaternion.x && quaternion.z >= quaternion.y && quaternion.z >= quaternion.w) {
        quaternion.x *= SIGN(M16.m13 - M16.m31);
        quaternion.y *= SIGN(M16.m21 + M16.m12);
        quaternion.z *= +1.0f;
        quaternion.w *= SIGN(M16.m32 + M16.m23);
    } else if(quaternion.w >= quaternion.x && quaternion.w >= quaternion.y && quaternion.w >= quaternion.z) {
        quaternion.x *= SIGN(M16.m21 - M16.m12);
        quaternion.y *= SIGN(M16.m31 + M16.m13);
        quaternion.z *= SIGN(M16.m32 + M16.m23);
        quaternion.w *= +1.0f;
    } else {
        NSLog(@"Q4 from Matrix: coding error\n");
    }
    
    float r = NORM(quaternion.x, quaternion.y, quaternion.z, quaternion.w);
    quaternion.x /= r;
    quaternion.y /= r;
    quaternion.z /= r;
    quaternion.w /= r;
    
    return quaternion;
    
}

static inline Q4t Q4MultiplyM16(M16t matrixLeft, Q4t vectorRight)
{
#if defined(__ARM_NEON__)
    float32x4x4_t iMatrix = *(float32x4x4_t *)&matrixLeft;
    float32x4_t v;
    
    iMatrix.val[0] = vmulq_n_f32(iMatrix.val[0], (float32_t)vectorRight.x);
    iMatrix.val[1] = vmulq_n_f32(iMatrix.val[1], (float32_t)vectorRight.y);
    iMatrix.val[2] = vmulq_n_f32(iMatrix.val[2], (float32_t)vectorRight.y);
    iMatrix.val[3] = vmulq_n_f32(iMatrix.val[3], (float32_t)vectorRight.z);
    
    iMatrix.val[0] = vaddq_f32(iMatrix.val[0], iMatrix.val[1]);
    iMatrix.val[2] = vaddq_f32(iMatrix.val[2], iMatrix.val[3]);
    
    v = vaddq_f32(iMatrix.val[0], iMatrix.val[2]);
    
    return *(Q4t *)&v;
#elif defined(GLK_SSE3_INTRINSICS)
	const __m128 v = _mm_load_ps(&vectorRight.x);
    
	const __m128 r = _mm_load_ps(&matrixLeft.m[0])  * _mm_shuffle_ps(v, v, _MM_SHUFFLE(0, 0, 0, 0))
    + _mm_load_ps(&matrixLeft.m[4])  * _mm_shuffle_ps(v, v, _MM_SHUFFLE(1, 1, 1, 1))
    + _mm_load_ps(&matrixLeft.m[8])  * _mm_shuffle_ps(v, v, _MM_SHUFFLE(2, 2, 2, 2))
    + _mm_load_ps(&matrixLeft.m[12]) * _mm_shuffle_ps(v, v, _MM_SHUFFLE(3, 3, 3, 3));
    
	Q4t ret;
	*(__m128*)&ret = r;
    return ret;
#else
    Q4t v = { matrixLeft.m[0] * vectorRight.x + matrixLeft.m[4] * vectorRight.y + matrixLeft.m[8] * vectorRight.y + matrixLeft.m[12] * vectorRight.z,
        matrixLeft.m[1] * vectorRight.x + matrixLeft.m[5] * vectorRight.y + matrixLeft.m[9] * vectorRight.y + matrixLeft.m[13] * vectorRight.z,
        matrixLeft.m[2] * vectorRight.x + matrixLeft.m[6] * vectorRight.y + matrixLeft.m[10] * vectorRight.y + matrixLeft.m[14] * vectorRight.z,
        matrixLeft.m[3] * vectorRight.x + matrixLeft.m[7] * vectorRight.y + matrixLeft.m[11] * vectorRight.y + matrixLeft.m[15] * vectorRight.z };
    return v;
#endif
}


/* Construct a unit quaternion from rotation matrix.  Assumes matrix is
 * used to multiply column vector on the left: vnew = mat vold.  Works
 * correctly for right-handed coordinate system and right-handed rotations.
 * Translation and perspective components ignored. */

static inline Q4t Q4FromMatrix(M16t mat)
{
    /* This algorithm avoids near-zero divides by looking for a large component
     * - first w, then x, y, or z.  When the trace is greater than zero,
     * |w| is greater than 1/2, which is as small as a largest component can be.
     * Otherwise, the largest diagonal entry corresponds to the largest of |x|,
     * |y|, or |z|, one of which must be larger than |w|, and at least 1/2. */
    Q4t qu = Q4Make(0,0,0,1);
    double tr, s;
    
    tr = mat.m00 + mat.m11 + mat.m22;
    if (tr >= 0.0)
    {
        s = sqrt(tr + mat.m33);
        qu.w = s*0.5;
        s = 0.5 / s;
        qu.x = (mat.m21 - mat.m12) * s;
        qu.y = (mat.m02 - mat.m20) * s;
        qu.z = (mat.m10 - mat.m01) * s;
    }
    else
    {
        int h = 0;
        if (mat.m11 > mat.m00) h = 1;
        if (mat.m22 > mat.a[h][h]) h = 2;
        switch (h) {
#define caseMacro(i,j,k,I,J,K) \
case I:\
s = sqrt( (mat.a[I][I] - (mat.a[J][J]+mat.a[K][K])) + mat.a[3][3] );\
qu.i = s*0.5;\
s = 0.5 / s;\
qu.j = (mat.a[I][J] + mat.a[J][I]) * s;\
qu.k = (mat.a[K][I] + mat.a[I][K]) * s;\
qu.w = (mat.a[K][J] - mat.a[J][K]) * s;\
break
                caseMacro(x,y,z,0,1,2);
                caseMacro(y,z,x,1,2,0);
                caseMacro(z,x,y,2,0,1);
        }
    }
    if (mat.a[3][3] != 1.0) qu = Q4Scale(qu, 1/sqrt(mat.a[3][3]));
    return (qu);
}



static inline Q4t Q4Subtract(Q4t quaternionLeft, Q4t quaternionRight)
{
#if defined(__ARM_NEON__)
    float32x4_t v = vsubq_f32(*(float32x4_t *)&quaternionLeft,
                              *(float32x4_t *)&quaternionRight);
    return *(Q4t *)&v;
#elif defined(GLK_SSE3_INTRINSICS)
    __m128 v = _mm_load_ps(&quaternionLeft.x) - _mm_load_ps(&quaternionRight.x);
    return *(Q4t *)&v;
#else
    Q4t q = { quaternionLeft.x - quaternionRight.x,
        quaternionLeft.y - quaternionRight.y,
        quaternionLeft.z - quaternionRight.z,
        quaternionLeft.w - quaternionRight.w };
    return q;
#endif
}

static inline Q4t Q4Multiply(Q4t quaternionLeft, Q4t quaternionRight)
{
#if defined(GLK_SSE3_INTRINSICS)
	const __m128 ql = _mm_load_ps(&quaternionLeft.x);
	const __m128 qr = _mm_load_ps(&quaternionRight.x);
    
	const __m128 ql3012 = _mm_shuffle_ps(ql, ql, _MM_SHUFFLE(2, 1, 0, 3));
	const __m128 ql3120 = _mm_shuffle_ps(ql, ql, _MM_SHUFFLE(0, 2, 1, 3));
	const __m128 ql3201 = _mm_shuffle_ps(ql, ql, _MM_SHUFFLE(1, 0, 2, 3));
    
	const __m128 qr0321 = _mm_shuffle_ps(qr, qr, _MM_SHUFFLE(1, 2, 3, 0));
	const __m128 qr1302 = _mm_shuffle_ps(qr, qr, _MM_SHUFFLE(2, 0, 3, 1));
	const __m128 qr2310 = _mm_shuffle_ps(qr, qr, _MM_SHUFFLE(0, 1, 3, 2));
	const __m128 qr3012 = _mm_shuffle_ps(qr, qr, _MM_SHUFFLE(2, 1, 0, 3));
    
    uint32_t signBit = 0x80000000;
    uint32_t zeroBit = 0x0;
    uint32_t __attribute__((aligned(16))) mask0001[4] = {zeroBit, zeroBit, zeroBit, signBit};
    uint32_t __attribute__((aligned(16))) mask0111[4] = {zeroBit, signBit, signBit, signBit};
    const __m128 m0001 = _mm_load_ps((float *)mask0001);
    const __m128 m0111 = _mm_load_ps((float *)mask0111);
    
	const __m128 aline = ql3012 * _mm_xor_ps(qr0321, m0001);
	const __m128 bline = ql3120 * _mm_xor_ps(qr1302, m0001);
	const __m128 cline = ql3201 * _mm_xor_ps(qr2310, m0001);
	const __m128 dline = ql3012 * _mm_xor_ps(qr3012, m0111);
	const __m128 r = _mm_hadd_ps(_mm_hadd_ps(aline, bline), _mm_hadd_ps(cline, dline));
    
    return *(Q4t *)&r;
#else
    
    Q4t q = { quaternionLeft.w * quaternionRight.x +
        quaternionLeft.x * quaternionRight.w +
        quaternionLeft.y * quaternionRight.z -
        quaternionLeft.z * quaternionRight.y,
        
        quaternionLeft.w * quaternionRight.y +
        quaternionLeft.y * quaternionRight.w +
        quaternionLeft.z * quaternionRight.x -
        quaternionLeft.x * quaternionRight.z,
        
        quaternionLeft.w * quaternionRight.z +
        quaternionLeft.z * quaternionRight.w +
        quaternionLeft.x * quaternionRight.y -
        quaternionLeft.y * quaternionRight.x,
        
        quaternionLeft.w * quaternionRight.w -
        quaternionLeft.x * quaternionRight.x -
        quaternionLeft.y * quaternionRight.y -
        quaternionLeft.z * quaternionRight.z };
    return q;
#endif
}

static inline float Q4Length(Q4t quaternion)
{
#if defined(__ARM_NEON__)
    float32x4_t v = vmulq_f32(*(float32x4_t *)&quaternion,
                              *(float32x4_t *)&quaternion);
    float32x2_t v2 = vpadd_f32(vget_low_f32(v), vget_high_f32(v));
    v2 = vpadd_f32(v2, v2);
    return sqrt(vget_lane_f32(v2, 0));
#elif defined(GLK_SSE3_INTRINSICS)
	const __m128 q = _mm_load_ps(&quaternion.x);
	const __m128 product = q * q;
	const __m128 halfsum = _mm_hadd_ps(product, product);
	return _mm_cvtss_f32(_mm_sqrt_ss(_mm_hadd_ps(halfsum, halfsum)));
#else
    return sqrt(quaternion.x * quaternion.x +
                quaternion.y * quaternion.y +
                quaternion.z * quaternion.z +
                quaternion.w * quaternion.w);
#endif
}

static inline Q4t Q4Normalize(Q4t quaternion)
{
    float scale = 1.0f / Q4Length(quaternion);
#if defined(__ARM_NEON__)
    float32x4_t v = vmulq_f32(*(float32x4_t *)&quaternion,
                              vdupq_n_f32((float32_t)scale));
    return *(Q4t *)&v;
#elif defined(GLK_SSE3_INTRINSICS)
	const __m128 q = _mm_load_ps(&quaternion.x);
    __m128 v = q * _mm_set1_ps(scale);
    return *(Q4t *)&v;
#else
    Q4t q = { quaternion.x * scale, quaternion.y * scale, quaternion.z * scale, quaternion.w * scale };
    return q;
#endif
}

static inline Q4t Q4Conjugate(Q4t quaternion)
{
#if defined(__ARM_NEON__)
    float32x4_t *q = (float32x4_t *)&quaternion;
    
    uint32_t signBit = 0x80000000;
    uint32_t zeroBit = 0x0;
    uint32x4_t mask = vdupq_n_u32(signBit);
    mask = vsetq_lane_u32(zeroBit, mask, 3);
    *q = vreinterpretq_f32_u32(veorq_u32(vreinterpretq_u32_f32(*q), mask));
    
    return *(Q4t *)q;
#elif defined(GLK_SSE3_INTRINSICS)
    // Multiply first three elements by -1
    const uint32_t signBit = 0x80000000;
    const uint32_t zeroBit = 0x0;
    const uint32_t __attribute__((aligned(16))) mask[4] = {signBit, signBit, signBit, zeroBit};
    __m128 v_mask = _mm_load_ps((float *)mask);
	const __m128 q = _mm_load_ps(&quaternion.x);
    __m128 v = _mm_xor_ps(q, v_mask);
    
    return *(Q4t *)&v;
#else
    Q4t q = { -quaternion.x, -quaternion.y, -quaternion.z, quaternion.w };
    return q;
#endif
}

static inline Q4t Q4Invert(Q4t quaternion)
{
#if defined(__ARM_NEON__)
    float32x4_t *q = (float32x4_t *)&quaternion;
    float32x4_t v = vmulq_f32(*q, *q);
    float32x2_t v2 = vpadd_f32(vget_low_f32(v), vget_high_f32(v));
    v2 = vpadd_f32(v2, v2);
    float32_t scale = 1.0f / vget_lane_f32(v2, 0);
    v = vmulq_f32(*q, vdupq_n_f32(scale));
    
    uint32_t signBit = 0x80000000;
    uint32_t zeroBit = 0x0;
    uint32x4_t mask = vdupq_n_u32(signBit);
    mask = vsetq_lane_u32(zeroBit, mask, 3);
    v = vreinterpretq_f32_u32(veorq_u32(vreinterpretq_u32_f32(v), mask));
    
    return *(Q4t *)&v;
#elif defined(GLK_SSE3_INTRINSICS)
	const __m128 q = _mm_load_ps(&quaternion.x);
    const uint32_t signBit = 0x80000000;
    const uint32_t zeroBit = 0x0;
    const uint32_t __attribute__((aligned(16))) mask[4] = {signBit, signBit, signBit, zeroBit};
    const __m128 v_mask = _mm_load_ps((float *)mask);
	const __m128 product = q * q;
	const __m128 halfsum = _mm_hadd_ps(product, product);
	const __m128 v = _mm_xor_ps(q, v_mask) / _mm_hadd_ps(halfsum, halfsum);
    return *(Q4t *)&v;
#else
    float scale = 1.0f / (quaternion.x * quaternion.x +
                          quaternion.y * quaternion.y +
                          quaternion.z * quaternion.z +
                          quaternion.w * quaternion.w);
    Q4t q = { -quaternion.x * scale, -quaternion.y * scale, -quaternion.z * scale, quaternion.w * scale };
    return q;
#endif
}



static inline V3t  Q4RotateVector3(Q4t quaternion, V3t  vector)
{
    Q4t rotatedQuaternion = Q4Make(vector.x, vector.y, vector.z, 0.0f);
    rotatedQuaternion = Q4Multiply(Q4Multiply(quaternion, rotatedQuaternion), Q4Invert(quaternion));
    
    return V3Make(rotatedQuaternion.x, rotatedQuaternion.y, rotatedQuaternion.z);
}

static inline Q4t Q4RotateQ4(Q4t quaternion, Q4t vector)
{
    Q4t rotatedQuaternion = Q4Make(vector.x, vector.y, vector.z, 0.0f);
    rotatedQuaternion = Q4Multiply(Q4Multiply(quaternion, rotatedQuaternion), Q4Invert(quaternion));
    
    return Q4Make(rotatedQuaternion.x, rotatedQuaternion.y, rotatedQuaternion.z, vector.w);
}

static inline Q4t QuatSlerp(Q4t from, Q4t to, float t)
{
    Q4t res;
    float DELTA = .01; // THRESHOLD FOR LINEAR INTERP
    
    float           to1[4];
    double        omega, cosom, sinom, scale0, scale1;
    // calc cosine
    cosom = from.x * to.x + from.y * to.y + from.z * to.z
    + from.w * to.w;
    // adjust signs (if necessary)
    if ( cosom <0.0 ){ cosom = -cosom; to1[0] = - to.x;
        to1[1] = - to.y;
        to1[2] = - to.z;
        to1[3] = - to.w;
    } else  {
        to1[0] = to.x;
        to1[1] = to.y;
        to1[2] = to.z;
        to1[3] = to.w;
    }
    // calculate coefficients
    if ( (1.0 - cosom) > DELTA ) {
        // standard case (slerp)
        omega = acos(cosom);
        sinom = sin(omega);
        scale0 = sin((1.0 - t) * omega) / sinom;
        scale1 = sin(t * omega) / sinom;
    } else {
        // "from" and "to" quaternions are very close
        //  ... so we can do a linear interpolation
        scale0 = 1.0 - t;
        scale1 = t;
    }
    // calculate final values
    res.x = scale0 * from.x + scale1 * to1[0];
    res.y = scale0 * from.y + scale1 * to1[1];
    res.z = scale0 * from.z + scale1 * to1[2];
    res.w = scale0 * from.w + scale1 * to1[3];
    
    return res;
}

static inline Q4t QuatMul(Q4t q1, Q4t q2){
    
    Q4t res;
    
    float A, B, C, D, E, F, G, H;
    A = (q1.w + q1.x)*(q2.w + q2.x);
    B = (q1.z - q1.y)*(q2.y - q2.z);
    C = (q1.w - q1.x)*(q2.y + q2.z);
    D = (q1.y + q1.z)*(q2.w - q2.x);
    E = (q1.x + q1.z)*(q2.x + q2.y);
    F = (q1.x - q1.z)*(q2.x - q2.y);
    G = (q1.w + q1.y)*(q2.w - q2.z);
    H = (q1.w - q1.y)*(q2.w + q2.z);
    res.w = B + (-E - F + G + H) /2;
    res.x = A - (E + F + G + H)/2;
    res.y = C + (E - F + G - H)/2;
    res.z = D + (E - F - G + H)/2;
    
    return res;
}

#pragma mark - Angle Axis 4 Type



static inline A4t A4FromQuat(Q4t q1) {
    
    A4t A4;
    
    if (q1.w > 1) Q4Normalize(q1); // if w>1 acos and sqrt will produce errors, this cant happen if quaternion is normalised
    A4.a = 2. * acos(q1.w);
    double s = sqrt(1-q1.w*q1.w); // assuming quaternion normalised then w is less than 1, so term always positive.
    if (s < 0.001) { // test to avoid divide by zero, s is always positive due to sqrt
        // if s close to zero then direction of axis not important
        A4.x = q1.x; // if it is important that axis is normalised then replace with x=1; y=z=0;
        A4.y = q1.y;
        A4.z = q1.z;
    } else {
        A4.x = q1.x / s; // normalise axis
        A4.y = q1.y / s;
        A4.z = q1.z / s;
    }
    
    return A4;
    
}


#pragma mark - M16 - MATRIX 4x4 TYPE

static inline M16t M16MakeTranslate(float x, float y, float z)
{
    M16t M16 = M16IdentityMake();
    // Translate slots.
    M16.m30 = x;
    M16.m31 = y;
    M16.m32 = z;
    
    return M16;
}

static inline void M16SetV3Translation(M16t *M16, V3t V3)
{
    M16->m30 = V3.x;
    M16->m31 = V3.y;
    M16->m32 = V3.z;
}

static inline void M16SetQ4Rotation(M16t *M16, Q4t Q4){
    
    double length2 = Q4Length(Q4);
    
    if (fabs(length2) <= DBL_MIN)
    {
        M16->m00 = 1.0; M16->m10 = 0.0; M16->m20 = 0.0;
        M16->m01 = 0.0; M16->m11 = 1.0; M16->m21 = 0.0;
        M16->m02 = 0.0; M16->m12 = 0.0; M16->m22 = 1.0;
    }
    else
    {
        double rlength2;
        // normalize quat if required.
        // We can avoid the expensive sqrt in this case since all 'coefficients' below are products of two q components.
        // That is a square of a square root, so it is possible to avoid that
        if (length2 != 1.0)
        {
            rlength2 = 2.0/length2;
        }
        else
        {
            rlength2 = 2.0;
        }
        
        // Source: Gamasutra, Rotating Objects Using Quaternions
        //
        //http://www.gamasutra.com/features/19980703/quaternions_01.htm
        
        double wx, wy, wz, xx, yy, yz, xy, xz, zz, x2, y2, z2;
        
        // calculate coefficients
        x2 = rlength2*Q4.x;
        y2 = rlength2*Q4.y;
        z2 = rlength2*Q4.z;
        
        xx = Q4.x * x2;
        xy = Q4.x * y2;
        xz = Q4.x * z2;
        
        yy = Q4.y * y2;
        yz = Q4.y * z2;
        zz = Q4.z * z2;
        
        wx = Q4.w * x2;
        wy = Q4.w * y2;
        wz = Q4.w * z2;
        
        // Note.  Gamasutra gets the matrix assignments inverted, resulting
        // in left-handed rotations, which is contrary to OpenGL and OSG's
        // methodology.  The matrix assignment has been altered in the next
        // few lines of code to do the right thing.
        // Don Burns - Oct 13, 2001
        M16->m00 = 1.0 - (yy + zz);
        M16->m10 = xy - wz;
        M16->m20 = xz + wy;
        
        
        M16->m01 = xy + wz;
        M16->m11 = 1.0 - (xx + zz);
        M16->m21 = yz - wx;
        
        M16->m02 = xz - wy;
        M16->m12 = yz + wx;
        M16->m22 = 1.0 - (xx + yy);
    }
    
    //#if 0
    //        _mat[0][3] = 0.0;
    //        _mat[1][3] = 0.0;
    //        _mat[2][3] = 0.0;
    //
    //        _mat[3][0] = 0.0;
    //        _mat[3][1] = 0.0;
    //        _mat[3][2] = 0.0;
    //        _mat[3][3] = 1.0;
    //#endif
    
}

static inline M16t M16MakeRotate(Q4t Q4){
    M16t M16 = M16IdentityMake();
    M16SetQ4Rotation(&M16, Q4);
    return M16;
}

static inline M16t M16MakeScale(V3t scale)
{
    M16t M16 = M16IdentityMake();
    
    // Scale slots.
    M16.m[0] = scale.x;
    M16.m[5] = scale.y;
    M16.m[10] = scale.z;
    
    return M16;
}

static inline M16t M16MakeRotateX(float degrees)
{
    float radians = DEGREES_TO_RADIANS(degrees);
    
    M16t M16 = M16IdentityMake();
    
    // Rotate X formula.
    M16.m[5] = cosf(radians);
    M16.m[6] = -sinf(radians);
    M16.m[9] = -M16.m[6];
    M16.m[10] = M16.m[5];
    
    return M16;
}

static inline M16t M16MakeRotateY(float degrees)
{
    float radians = DEGREES_TO_RADIANS(degrees);
    
    M16t M16 = M16IdentityMake();
    
    // Rotate Y formula.
    M16.m[0] = cosf(radians);
    M16.m[2] = sinf(radians);
    M16.m[8] = -M16.m[2];
    M16.m[10] = M16.m[0];
    
    return M16;
}

static inline M16t M16MakeRotateZ(float degrees)
{
    float radians = DEGREES_TO_RADIANS(degrees);
    
    M16t M16 = M16IdentityMake();
    
    // Rotate Z formula.
    M16.m[0] = cosf(radians);
    M16.m[1] = sinf(radians);
    M16.m[4] = -M16.m[1];
    M16.m[5] = M16.m[0];
    
    return M16;
}

static inline M16t M16Multiply(M16t m1, M16t m2)
{
    M16t result;
    // First Column
    result.m[0] = m1.m[0]*m2.m[0] + m1.m[4]*m2.m[1] + m1.m[8]*m2.m[2] + m1.m[12]*m2.m[3];
    result.m[1] = m1.m[1]*m2.m[0] + m1.m[5]*m2.m[1] + m1.m[9]*m2.m[2] + m1.m[13]*m2.m[3];
    result.m[2] = m1.m[2]*m2.m[0] + m1.m[6]*m2.m[1] + m1.m[10]*m2.m[2] + m1.m[14]*m2.m[3];
    result.m[3] = m1.m[3]*m2.m[0] + m1.m[7]*m2.m[1] + m1.m[11]*m2.m[2] + m1.m[15]*m2.m[3];
    
    // Second Column
    result.m[4] = m1.m[0]*m2.m[4] + m1.m[4]*m2.m[5] + m1.m[8]*m2.m[6] + m1.m[12]*m2.m[7];
    result.m[5] = m1.m[1]*m2.m[4] + m1.m[5]*m2.m[5] + m1.m[9]*m2.m[6] + m1.m[13]*m2.m[7];
    result.m[6] = m1.m[2]*m2.m[4] + m1.m[6]*m2.m[5] + m1.m[10]*m2.m[6] + m1.m[14]*m2.m[7];
    result.m[7] = m1.m[3]*m2.m[4] + m1.m[7]*m2.m[5] + m1.m[11]*m2.m[6] + m1.m[15]*m2.m[7];
    
    // Third Column
    result.m[8] = m1.m[0]*m2.m[8] + m1.m[4]*m2.m[9] + m1.m[8]*m2.m[10] + m1.m[12]*m2.m[11];
    result.m[9] = m1.m[1]*m2.m[8] + m1.m[5]*m2.m[9] + m1.m[9]*m2.m[10] + m1.m[13]*m2.m[11];
    result.m[10] = m1.m[2]*m2.m[8] + m1.m[6]*m2.m[9] + m1.m[10]*m2.m[10] + m1.m[14]*m2.m[11];
    result.m[11] = m1.m[3]*m2.m[8] + m1.m[7]*m2.m[9] + m1.m[11]*m2.m[10] + m1.m[15]*m2.m[11];
    
    // Fourth Column
    result.m[12] = m1.m[0]*m2.m[12] + m1.m[4]*m2.m[13] + m1.m[8]*m2.m[14] + m1.m[12]*m2.m[15];
    result.m[13] = m1.m[1]*m2.m[12] + m1.m[5]*m2.m[13] + m1.m[9]*m2.m[14] + m1.m[13]*m2.m[15];
    result.m[14] = m1.m[2]*m2.m[12] + m1.m[6]*m2.m[13] + m1.m[10]*m2.m[14] + m1.m[14]*m2.m[15];
    result.m[15] = m1.m[3]*m2.m[12] + m1.m[7]*m2.m[13] + m1.m[11]*m2.m[14] + m1.m[15]*m2.m[15];
    return result;
    
}

static inline V3t V3MultiplyM16(M16t matrixLeft, V3t vectorRight)
{
    Q4t Q4 = Q4MultiplyM16(matrixLeft, Q4Make(vectorRight.x, vectorRight.y, vectorRight.y, 0.0f));
    return V3Make(Q4.x, Q4.y, Q4.z);
}

// from http://en.wikipedia.org/wiki/Rotation_formalisms_in_three_dimensions



static inline M16t M16MakeAngleAxis(F1t radians, V3t  V3){
    
    M16t M16;
    
    float ax = V3.x * radians;
    float ay = V3.y * radians;
    float az = V3.z * radians;
    
    // First Column
    M16.m[0] = cosf(ay) * cosf(az);
    M16.m[1] = -cosf(ay)*sin(az);
    M16.m[2] = sin(ay);
    M16.m[3] = 0;
    //Second
    M16.m[4] = cosf(ax) * sinf(az) + sinf(ax) * sinf(ay) * cosf(az);
    M16.m[5] = cosf(ax) * cosf(az) - sinf(ax) * sinf(ay) * sinf(az);
    M16.m[6] = -sinf(ax) * cosf(ay);
    M16.m[7] = 0;
    //Third
    M16.m[8] = cosf(ax) * sinf(az) - cosf(ax) * sinf(ay) * cosf(az);
    M16.m[9] = sinf(ax) * cosf(az) + cosf(ax) * sinf(ay) * sinf(az);
    M16.m[10] = cosf(ax) * cosf(ay);
    M16.m[11] = 0;
    //Fourth
    M16.m[12] = 0;
    M16.m[13] = 0;
    M16.m[14] = 0;
    M16.m[15] = 1;
    
    return M16;
}

static inline M16t M16MakeEuler(V3t euler) {
    V3t rad = V3Make(DEGREES_TO_RADIANS(euler.x), DEGREES_TO_RADIANS(euler.y),DEGREES_TO_RADIANS(euler.z));
    return M16MakeAngleAxis(1., rad);
}

static inline M16t M16MakePerspective(float fovyRadians, float aspect, float nearZ, float farZ)
{
    float cotan = 1.0f / tanf(fovyRadians / 2.0f);
    
    M16t m = { cotan / aspect, 0.0f, 0.0f, 0.0f,
        0.0f, cotan, 0.0f, 0.0f,
        0.0f, 0.0f, (farZ + nearZ) / (nearZ - farZ), -1.0f,
        0.0f, 0.0f, (2.0f * farZ * nearZ) / (nearZ - farZ), 0.0f };
    
    return m;
}

static inline M16t M16MakeFrustum(float left, float right,
                           float bottom, float top,
                           float nearZ, float farZ)
{
    float ral = right + left;
    float rsl = right - left;
    float tsb = top - bottom;
    float tab = top + bottom;
    float fan = farZ + nearZ;
    float fsn = farZ - nearZ;
    
    M16t m = { 2.0f * nearZ / rsl, 0.0f, 0.0f, 0.0f,
        0.0f, 2.0f * nearZ / tsb, 0.0f, 0.0f,
        ral / rsl, tab / tsb, -fan / fsn, -1.0f,
        0.0f, 0.0f, (-2.0f * farZ * nearZ) / fsn, 0.0f };
    
    return m;
}

static inline M16t M16MakeOrtho(float left, float right,
                         float bottom, float top,
                         float nearZ, float farZ)
{
    float ral = right + left;
    float rsl = right - left;
    float tab = top + bottom;
    float tsb = top - bottom;
    float fan = farZ + nearZ;
    float fsn = farZ - nearZ;
    
    M16t m = { 2.0f / rsl, 0.0f, 0.0f, 0.0f,
        0.0f, 2.0f / tsb, 0.0f, 0.0f,
        0.0f, 0.0f, -2.0f / fsn, 0.0f,
        -ral / rsl, -tab / tsb, -fan / fsn, 1.0f };
    
    return m;
}

static inline M16t M16MakeLookAt(float eyeX, float eyeY, float eyeZ,
                          float centerX, float centerY, float centerZ,
                          float upX, float upY, float upZ)
{
    V3t ev = { eyeX, eyeY, eyeZ };
    V3t cv = { centerX, centerY, centerZ };
    V3t uv = { upX, upY, upZ };
    V3t n = V3Normalize(V3Add(ev, V3Negate(cv)));
    V3t u = V3Normalize(V3CrossProduct(uv, n));
    V3t v = V3CrossProduct(n, u);
    
    M16t m = { u.x, v.x, n.x, 0.0f,
        u.y, v.y, n.y, 0.0f,
        u.z, v.z, n.z, 0.0f,
        V3DotProduct(V3Negate(u), ev),
        V3DotProduct(V3Negate(v), ev),
        V3DotProduct(V3Negate(n), ev),
        1.0f };
    
    return m;
}


// from
static inline M16t M16InvertColumnMajor(M16t M16, bool *isInvertible)
{
    M16t invOut;
    float det;
    int i;
    
    invOut.m[ 0] =  M16.m[5] * M16.m[10] * M16.m[15] - M16.m[5] * M16.m[11] * M16.m[14] - M16.m[9] * M16.m[6] * M16.m[15] + M16.m[9] * M16.m[7] * M16.m[14] + M16.m[13] * M16.m[6] * M16.m[11] - M16.m[13] * M16.m[7] * M16.m[10];
    invOut.m[ 4] = -M16.m[4] * M16.m[10] * M16.m[15] + M16.m[4] * M16.m[11] * M16.m[14] + M16.m[8] * M16.m[6] * M16.m[15] - M16.m[8] * M16.m[7] * M16.m[14] - M16.m[12] * M16.m[6] * M16.m[11] + M16.m[12] * M16.m[7] * M16.m[10];
    invOut.m[ 8] =  M16.m[4] * M16.m[ 9] * M16.m[15] - M16.m[4] * M16.m[11] * M16.m[13] - M16.m[8] * M16.m[5] * M16.m[15] + M16.m[8] * M16.m[7] * M16.m[13] + M16.m[12] * M16.m[5] * M16.m[11] - M16.m[12] * M16.m[7] * M16.m[ 9];
    invOut.m[12] = -M16.m[4] * M16.m[ 9] * M16.m[14] + M16.m[4] * M16.m[10] * M16.m[13] + M16.m[8] * M16.m[5] * M16.m[14] - M16.m[8] * M16.m[6] * M16.m[13] - M16.m[12] * M16.m[5] * M16.m[10] + M16.m[12] * M16.m[6] * M16.m[ 9];
    invOut.m[ 1] = -M16.m[1] * M16.m[10] * M16.m[15] + M16.m[1] * M16.m[11] * M16.m[14] + M16.m[9] * M16.m[2] * M16.m[15] - M16.m[9] * M16.m[3] * M16.m[14] - M16.m[13] * M16.m[2] * M16.m[11] + M16.m[13] * M16.m[3] * M16.m[10];
    invOut.m[ 5] =  M16.m[0] * M16.m[10] * M16.m[15] - M16.m[0] * M16.m[11] * M16.m[14] - M16.m[8] * M16.m[2] * M16.m[15] + M16.m[8] * M16.m[3] * M16.m[14] + M16.m[12] * M16.m[2] * M16.m[11] - M16.m[12] * M16.m[3] * M16.m[10];
    invOut.m[ 9] = -M16.m[0] * M16.m[ 9] * M16.m[15] + M16.m[0] * M16.m[11] * M16.m[13] + M16.m[8] * M16.m[1] * M16.m[15] - M16.m[8] * M16.m[3] * M16.m[13] - M16.m[12] * M16.m[1] * M16.m[11] + M16.m[12] * M16.m[3] * M16.m[ 9];
    invOut.m[13] =  M16.m[0] * M16.m[ 9] * M16.m[14] - M16.m[0] * M16.m[10] * M16.m[13] - M16.m[8] * M16.m[1] * M16.m[14] + M16.m[8] * M16.m[2] * M16.m[13] + M16.m[12] * M16.m[1] * M16.m[10] - M16.m[12] * M16.m[2] * M16.m[ 9];
    invOut.m[ 2] =  M16.m[1] * M16.m[ 6] * M16.m[15] - M16.m[1] * M16.m[ 7] * M16.m[14] - M16.m[5] * M16.m[2] * M16.m[15] + M16.m[5] * M16.m[3] * M16.m[14] + M16.m[13] * M16.m[2] * M16.m[ 7] - M16.m[13] * M16.m[3] * M16.m[ 6];
    invOut.m[ 6] = -M16.m[0] * M16.m[ 6] * M16.m[15] + M16.m[0] * M16.m[ 7] * M16.m[14] + M16.m[4] * M16.m[2] * M16.m[15] - M16.m[4] * M16.m[3] * M16.m[14] - M16.m[12] * M16.m[2] * M16.m[ 7] + M16.m[12] * M16.m[3] * M16.m[ 6];
    invOut.m[10] =  M16.m[0] * M16.m[ 5] * M16.m[15] - M16.m[0] * M16.m[ 7] * M16.m[13] - M16.m[4] * M16.m[1] * M16.m[15] + M16.m[4] * M16.m[3] * M16.m[13] + M16.m[12] * M16.m[1] * M16.m[ 7] - M16.m[12] * M16.m[3] * M16.m[ 5];
    invOut.m[14] = -M16.m[0] * M16.m[ 5] * M16.m[14] + M16.m[0] * M16.m[ 6] * M16.m[13] + M16.m[4] * M16.m[1] * M16.m[14] - M16.m[4] * M16.m[2] * M16.m[13] - M16.m[12] * M16.m[1] * M16.m[ 6] + M16.m[12] * M16.m[2] * M16.m[ 5];
    invOut.m[ 3] = -M16.m[1] * M16.m[ 6] * M16.m[11] + M16.m[1] * M16.m[ 7] * M16.m[10] + M16.m[5] * M16.m[2] * M16.m[11] - M16.m[5] * M16.m[3] * M16.m[10] - M16.m[ 9] * M16.m[2] * M16.m[ 7] + M16.m[ 9] * M16.m[3] * M16.m[ 6];
    invOut.m[ 7] =  M16.m[0] * M16.m[ 6] * M16.m[11] - M16.m[0] * M16.m[ 7] * M16.m[10] - M16.m[4] * M16.m[2] * M16.m[11] + M16.m[4] * M16.m[3] * M16.m[10] + M16.m[ 8] * M16.m[2] * M16.m[ 7] - M16.m[ 8] * M16.m[3] * M16.m[ 6];
    invOut.m[11] = -M16.m[0] * M16.m[ 5] * M16.m[11] + M16.m[0] * M16.m[ 7] * M16.m[ 9] + M16.m[4] * M16.m[1] * M16.m[11] - M16.m[4] * M16.m[3] * M16.m[ 9] - M16.m[ 8] * M16.m[1] * M16.m[ 7] + M16.m[ 8] * M16.m[3] * M16.m[ 5];
    invOut.m[15] =  M16.m[0] * M16.m[ 5] * M16.m[10] - M16.m[0] * M16.m[ 6] * M16.m[ 9] - M16.m[4] * M16.m[1] * M16.m[10] + M16.m[4] * M16.m[2] * M16.m[ 9] + M16.m[ 8] * M16.m[1] * M16.m[ 6] - M16.m[ 8] * M16.m[2] * M16.m[ 5];
    
    det = M16.m[0] * invOut.m[0] + M16.m[1] * invOut.m[4] + M16.m[2] * invOut.m[8] + M16.m[3] * invOut.m[12];
    
    if(det == 0){
        if(isInvertible)*isInvertible = false;
        NSLog(@"Error inverting matrix");
        return M16;
    }
    det = 1.f / det;
    
    for(i = 0; i < 16; i++)
        invOut.m[i] = invOut.m[i] * det;
    
    if(isInvertible)*isInvertible = true;
    return invOut;
}

#pragma mark - GL Utility Functions

static inline void nkMultMatrix(M16t matrix){
    glMultMatrixf(matrix.m);
}

#pragma mark MATRIX - DECOMPOSITION - ported FROM OpenFrameworks, untested

//typedef double _HMatrix[4][4];
//static _HMatrix mat_id = {{1,0,0,0},{0,1,0,0},{0,0,1,0},{0,0,0,1}};
//typedef Q4t HVect;
//
//enum QuatPart {X, Y, Z, W};
//
//typedef struct
//{
//	Q4t t;     // Translation Component;
//	Q4t q;           // Essential Rotation
//	Q4t u;          //Stretch rotation
//	HVect k;          //Sign of determinant
//	double f;          // Sign of determinant
//} _affineParts;

//#define SQRTHALF (0.7071067811865475244)
//#define qxtoz Q4Make(0,SQRTHALF,0,SQRTHALF)
//#define qytoz Q4Make(SQRTHALF,0,SQRTHALF,0)
//#define q0001 Q4Make(0,0,0,1)
//#define qppmm Q4Make( 0.5, 0.5,-0.5,-0.5)
//#define qpppp Q4Make( 0.5, 0.5, 0.5, 0.5)
//#define qmpmm Q4Make(-0.5, 0.5,-0.5,-0.5)
//#define q1000 Q4Make( 1.0, 0.0, 0.0, 0.0)
//#define qpppm Q4Make( 0.5, 0.5, 0.5,-0.5)

//// HELPERS FOR POLAR DECOMPOSITION
//
//#define matrixCopy(C, gets, A, n) {int i, j; for (i=0;i<n;i++) for (j=0;j<n;j++)\
//C[i][j] gets (A[i][j]);}
//
///** Copy transpose of nxn matrix A to C using "gets" for assignment **/
//#define mat_tpose(AT,gets,A,n) {int i,j; for(i=0;i<n;i++) for(j=0;j<n;j++)\
//AT[i][j] gets (A[j][i]);}
//
///** Fill out 3x3 matrix to 4x4 **/
//#define mat_pad(A) (A[W][X]=A[X][W]=A[W][Y]=A[Y][W]=A[W][Z]=A[Z][W]=0,A[W][W]=1)
//
///** Assign nxn matrix C the element-wise combination of A and B using "op" **/
//#define matBinop(C,gets,A,op,B,n) {int i,j; for(i=0;i<n;i++) for(j=0;j<n;j++)\
//C[i][j] gets (A[i][j]) op (B[i][j]);}
//
///** Copy nxn matrix A to C using "gets" for assignment **/
//#define mat_copy(C,gets,A,n) {int i,j; for(i=0;i<n;i++) for(j=0;j<n;j++)\
//C[i][j] gets (A[i][j]);}
//
//
//
///** Return index of column of M containing maximum abs entry, or -1 if M=0 **/
//static inline int find_max_col(_HMatrix M)
//{
//    double abs, max;
//    int i, j, col;
//    max = 0.0; col = -1;
//    for (i=0; i<3; i++) for (j=0; j<3; j++) {
//        abs = M[i][j]; if (abs<0.0) abs = -abs;
//        if (abs>max) {max = abs; col = j;}
//    }
//    return col;
//}
//
//static inline void vcross(double *va, double *vb, double *v)
//{
//    v[0] = va[1]*vb[2] - va[2]*vb[1];
//    v[1] = va[2]*vb[0] - va[0]*vb[2];
//    v[2] = va[0]*vb[1] - va[1]*vb[0];
//}
//
///** Return dot product of length 3 vectors va and vb **/
//static inline double vdot(double *va, double *vb)
//{
//    return (va[0]*vb[0] + va[1]*vb[1] + va[2]*vb[2]);
//}
//
///** Set MadjT to transpose of inverse of M times determinant of M **/
//static inline void adjoint_transpose(_HMatrix M, _HMatrix MadjT)
//{
//    vcross(M[1], M[2], MadjT[0]);
//    vcross(M[2], M[0], MadjT[1]);
//    vcross(M[0], M[1], MadjT[2]);
//}
//
///** Setup u for Household reflection to zero all v components but first **/
//static inline void make_reflector(double *v, double *u)
//{
//    double s = sqrt(vdot(v, v));
//    u[0] = v[0]; u[1] = v[1];
//    u[2] = v[2] + ((v[2]<0.0) ? -s : s);
//    s = sqrt(2.0/vdot(u, u));
//    u[0] = u[0]*s; u[1] = u[1]*s; u[2] = u[2]*s;
//}
//
///** Apply Householder reflection represented by u to column vectors of M **/
//static inline void reflect_cols(_HMatrix M, double *u)
//{
//    int i, j;
//    for (i=0; i<3; i++) {
//        double s = u[0]*M[0][i] + u[1]*M[1][i] + u[2]*M[2][i];
//        for (j=0; j<3; j++) M[j][i] -= u[j]*s;
//    }
//}
//
///** Apply Householder reflection represented by u to row vectors of M **/
//static inline void reflect_rows(_HMatrix M, double *u)
//{
//    int i, j;
//    for (i=0; i<3; i++) {
//        double s = vdot(u, M[i]);
//        for (j=0; j<3; j++) M[i][j] -= u[j]*s;
//    }
//}
//
///** Multiply the upper left 3x3 parts of A and B to get AB **/
//static inline void mat_mult(_HMatrix A, _HMatrix B, _HMatrix AB)
//{
//    int i, j;
//    for (i=0; i<3; i++) for (j=0; j<3; j++)
//        AB[i][j] = A[i][0]*B[0][j] + A[i][1]*B[1][j] + A[i][2]*B[2][j];
//}
//
//static inline double mat_norm(_HMatrix M, int tpose)
//{
//    int i;
//    double sum, max;
//    max = 0.0;
//    for (i=0; i<3; i++) {
//        if (tpose) sum = fabs(M[0][i])+fabs(M[1][i])+fabs(M[2][i]);
//        else       sum = fabs(M[i][0])+fabs(M[i][1])+fabs(M[i][2]);
//        if (max<sum) max = sum;
//    }
//    return max;
//}
//
//
//static inline double norm_inf(_HMatrix M) {return mat_norm(M, 0);}
//static inline double norm_one(_HMatrix M) {return mat_norm(M, 1);}
//
//
///** Find orthogonal factor Q of rank 1 (or less) M **/
//static inline void do_rank1(_HMatrix M, _HMatrix Q)
//{
//    double v1[3], v2[3], s;
//    int col;
//    mat_copy(Q,=,mat_id,4);
//    /* If rank(M) is 1, we should find a non-zero column in M */
//    col = find_max_col(M);
//    if (col<0) return; /* Rank is 0 */
//    v1[0] = M[0][col]; v1[1] = M[1][col]; v1[2] = M[2][col];
//    make_reflector(v1, v1); reflect_cols(M, v1);
//    v2[0] = M[2][0]; v2[1] = M[2][1]; v2[2] = M[2][2];
//    make_reflector(v2, v2); reflect_rows(M, v2);
//    s = M[2][2];
//    if (s<0.0) Q[2][2] = -1.0;
//    reflect_cols(Q, v1); reflect_rows(Q, v2);
//}
//
///** Find orthogonal factor Q of rank 2 (or less) M using adjoint transpose **/
//static inline void do_rank2(_HMatrix M, _HMatrix MadjT, _HMatrix Q)
//{
//    double v1[3], v2[3];
//    double w, x, y, z, c, s, d;
//    int col;
//    /* If rank(M) is 2, we should find a non-zero column in MadjT */
//    col = find_max_col(MadjT);
//    if (col<0) {do_rank1(M, Q); return;} /* Rank<2 */
//    v1[0] = MadjT[0][col]; v1[1] = MadjT[1][col]; v1[2] = MadjT[2][col];
//    make_reflector(v1, v1); reflect_cols(M, v1);
//    vcross(M[0], M[1], v2);
//    make_reflector(v2, v2); reflect_rows(M, v2);
//    w = M[0][0]; x = M[0][1]; y = M[1][0]; z = M[1][1];
//    if (w*z>x*y) {
//        c = z+w; s = y-x; d = sqrt(c*c+s*s); c = c/d; s = s/d;
//        Q[0][0] = Q[1][1] = c; Q[0][1] = -(Q[1][0] = s);
//    } else {
//        c = z-w; s = y+x; d = sqrt(c*c+s*s); c = c/d; s = s/d;
//        Q[0][0] = -(Q[1][1] = c); Q[0][1] = Q[1][0] = s;
//    }
//    Q[0][2] = Q[2][0] = Q[1][2] = Q[2][1] = 0.0; Q[2][2] = 1.0;
//    reflect_cols(Q, v1); reflect_rows(Q, v2);
//}
//
//
//
//
//
///******* Polar Decomposition *******/
///* Polar Decomposition of 3x3 matrix in 4x4,
// * M = QS.  See Nicholas Higham and Robert S. Schreiber,
// * Fast Polar Decomposition of An Arbitrary Matrix,
// * Technical Report 88-942, October 1988,
// * Department of Computer Science, Cornell University.
// */
//
//static inline double polarDecomp( _HMatrix M, _HMatrix Q, _HMatrix S)
//{
//    
//#define TOL 1.0e-6
//	_HMatrix Mk, MadjTk, Ek;
//	double det, M_one, M_inf, MadjT_one, MadjT_inf, E_one, gamma, g1, g2;
//	int i, j;
//    
//	mat_tpose(Mk,=,M,3);
//	M_one = norm_one(Mk);  M_inf = norm_inf(Mk);
//    
//	do
//	{
//		adjoint_transpose(Mk, MadjTk);
//		det = vdot(Mk[0], MadjTk[0]);
//		if (det==0.0)
//		{
//			do_rank2(Mk, MadjTk, Mk);
//			break;
//		}
//        
//		MadjT_one = norm_one(MadjTk);
//		MadjT_inf = norm_inf(MadjTk);
//        
//		gamma = sqrt(sqrt((MadjT_one*MadjT_inf)/(M_one*M_inf))/fabs(det));
//		g1 = gamma*0.5;
//		g2 = 0.5/(gamma*det);
//		matrixCopy(Ek,=,Mk,3);
//		matBinop(Mk,=,g1*Mk,+,g2*MadjTk,3);
//		mat_copy(Ek,-=,Mk,3);
//		E_one = norm_one(Ek);
//		M_one = norm_one(Mk);
//		M_inf = norm_inf(Mk);
//        
//	} while(E_one>(M_one*TOL));
//    
//	mat_tpose(Q,=,Mk,3); mat_pad(Q);
//	mat_mult(Mk, M, S);  mat_pad(S);
//    
//	for (i=0; i<3; i++)
//		for (j=i; j<3; j++)
//			S[i][j] = S[j][i] = 0.5*(S[i][j]+S[j][i]);
//	return (det);
//}
//
//
///******* Spectral Decomposition *******/
///* Compute the spectral decomposition of symmetric positive semi-definite S.
// * Returns rotation in U and scale factors in result, so that if K is a diagonal
// * matrix of the scale factors, then S = U K (U transpose). Uses Jacobi method.
// * See Gene H. Golub and Charles F. Van Loan. Matrix Computations. Hopkins 1983.
// */
//static inline HVect spectDecomp(_HMatrix S, _HMatrix U)
//{
//    HVect kv;
//    double Diag[3],OffD[3]; /* OffD is off-diag (by omitted index) */
//    double g,h,fabsh,fabsOffDi,t,theta,c,s,tau,ta,OffDq,a,b;
//    static char nxt[] = {Y,Z,X};
//    int sweep, i, j;
//    mat_copy(U,=,mat_id,4);
//    Diag[X] = S[X][X]; Diag[Y] = S[Y][Y]; Diag[Z] = S[Z][Z];
//    OffD[X] = S[Y][Z]; OffD[Y] = S[Z][X]; OffD[Z] = S[X][Y];
//    for (sweep=20; sweep>0; sweep--) {
//        double sm = fabs(OffD[X])+fabs(OffD[Y])+fabs(OffD[Z]);
//        if (sm==0.0) break;
//        for (i=Z; i>=X; i--) {
//            int p = nxt[i]; int q = nxt[p];
//            fabsOffDi = fabs(OffD[i]);
//            g = 100.0*fabsOffDi;
//            if (fabsOffDi>0.0) {
//                h = Diag[q] - Diag[p];
//                fabsh = fabs(h);
//                if (fabsh+g==fabsh) {
//                    t = OffD[i]/h;
//                } else {
//                    theta = 0.5*h/OffD[i];
//                    t = 1.0/(fabs(theta)+sqrt(theta*theta+1.0));
//                    if (theta<0.0) t = -t;
//                }
//                c = 1.0/sqrt(t*t+1.0); s = t*c;
//                tau = s/(c+1.0);
//                ta = t*OffD[i]; OffD[i] = 0.0;
//                Diag[p] -= ta; Diag[q] += ta;
//                OffDq = OffD[q];
//                OffD[q] -= s*(OffD[p] + tau*OffD[q]);
//                OffD[p] += s*(OffDq   - tau*OffD[p]);
//                for (j=Z; j>=X; j--) {
//                    a = U[j][p]; b = U[j][q];
//                    U[j][p] -= s*(b + tau*a);
//                    U[j][q] += s*(a - tau*b);
//                }
//            }
//        }
//    }
//    kv.x = Diag[X]; kv.y = Diag[Y]; kv.z = Diag[Z]; kv.w = 1.0;
//    return (kv);
//}
//
///******* Spectral Axis Adjustment *******/
//
///* Given a unit quaternion, q, and a scale vector, k, find a unit quaternion, p,
// * which permutes the axes and turns freely in the plane of duplicate scale
// * factors, such that q p has the largest possible w component, i.e. the
// * smallest possible angle. Permutes k's components to go with q p instead of q.
// * See Ken Shoemake and Tom Duff. Matrix Animation and Polar Decomposition.
// * Proceedings of Graphics Interface 1992. Details on p. 262-263.
// */
//static inline Q4t snuggle(Q4t q, HVect *k)
//{
//#define sgn(n,v)    ((n)?-(v):(v))
//#define swap(a,i,j) {a[3]=a[i]; a[i]=a[j]; a[j]=a[3];}
//#define cycle(a,p)  if (p) {a[3]=a[0]; a[0]=a[1]; a[1]=a[2]; a[2]=a[3];}\
//else   {a[3]=a[2]; a[2]=a[1]; a[1]=a[0]; a[0]=a[3];}
//    
//	Q4t p = Q4Make(0,0,0,1);
//	double ka[4];
//	int i, turn = -1;
//	ka[X] = k->x; ka[Y] = k->y; ka[Z] = k->z;
//    
//	if (ka[X]==ka[Y]) {
//		if (ka[X]==ka[Z])
//			turn = W;
//		else turn = Z;
//	}
//	else {
//		if (ka[X]==ka[Z])
//			turn = Y;
//		else if (ka[Y]==ka[Z])
//			turn = X;
//	}
//	if (turn>=0) {
//		Q4t qtoz, qp;
//		unsigned int  win;
//		double mag[3], t;
//		switch (turn) {
//			default: return (Q4Conjugate(q));
//			case X: q = Q4Multiply(q, qtoz = qxtoz); swap(ka,X,Z) break;
//			case Y: q = Q4Multiply(q, qtoz = qytoz); swap(ka,Y,Z) break;
//			case Z: qtoz = q0001; break;
//		}
//		q = Q4Conjugate(q);
//		mag[0] = (double)q.z*q.z+(double)q.w*q.w-0.5;
//		mag[1] = (double)q.x*q.z-(double)q.y*q.w;
//		mag[2] = (double)q.y*q.z+(double)q.x*q.w;
//        
//		bool neg[3];
//		for (i=0; i<3; i++)
//		{
//			neg[i] = (mag[i]<0.0);
//			if (neg[i]) mag[i] = -mag[i];
//		}
//        
//		if (mag[0]>mag[1]) {
//			if (mag[0]>mag[2])
//				win = 0;
//			else win = 2;
//		}
//		else {
//			if (mag[1]>mag[2]) win = 1;
//			else win = 2;
//		}
//        
//		switch (win) {
//			case 0: if (neg[0]) p = q1000; else p = q0001; break;
//			case 1: if (neg[1]) p = qppmm; else p = qpppp; cycle(ka,0) break;
//			case 2: if (neg[2]) p = qmpmm; else p = qpppm; cycle(ka,1) break;
//		}
//        
//		qp = Q4Multiply(q, p);
//		t = sqrt(mag[win]+0.5);
//		p = Q4Multiply(p, Q4Make(0.0,0.0,-qp.z/t,qp.w/t));
//		p = Q4Multiply(qtoz, Q4Conjugate(p));
//	}
//    
//	else {
//		double qa[4], pa[4];
//		unsigned int lo, hi;
//		bool par = false;
//		bool neg[4];
//		double all, big, two;
//		qa[0] = q.x; qa[1] = q.y; qa[2] = q.z; qa[3] = q.w;
//		for (i=0; i<4; i++) {
//			pa[i] = 0.0;
//			neg[i] = (qa[i]<0.0);
//			if (neg[i]) qa[i] = -qa[i];
//			par ^= neg[i];
//		}
//        
//		/* Find two largest components, indices in hi and lo */
//		if (qa[0]>qa[1]) lo = 0;
//		else lo = 1;
//        
//		if (qa[2]>qa[3]) hi = 2;
//		else hi = 3;
//        
//		if (qa[lo]>qa[hi]) {
//			if (qa[lo^1]>qa[hi]) {
//				hi = lo; lo ^= 1;
//			}
//			else {
//				hi ^= lo; lo ^= hi; hi ^= lo;
//			}
//		}
//		else {
//			if (qa[hi^1]>qa[lo]) lo = hi^1;
//		}
//        
//		all = (qa[0]+qa[1]+qa[2]+qa[3])*0.5;
//		two = (qa[hi]+qa[lo])*SQRTHALF;
//		big = qa[hi];
//		if (all>two) {
//			if (all>big) {/*all*/
//				{int i; for (i=0; i<4; i++) pa[i] = sgn(neg[i], 0.5);}
//				cycle(ka,par);
//			}
//			else {/*big*/ pa[hi] = sgn(neg[hi],1.0);}
//		} else {
//			if (two>big) { /*two*/
//				pa[hi] = sgn(neg[hi],SQRTHALF);
//				pa[lo] = sgn(neg[lo], SQRTHALF);
//				if (lo>hi) {
//					hi ^= lo; lo ^= hi; hi ^= lo;
//				}
//				if (hi==W) {
//					hi = "\001\002\000"[lo];
//					lo = 3-hi-lo;
//				}
//				swap(ka,hi,lo);
//			}
//			else {/*big*/
//				pa[hi] = sgn(neg[hi],1.0);
//			}
//		}
//		p.x = -pa[0]; p.y = -pa[1]; p.z = -pa[2]; p.w = pa[3];
//	}
//	k->x = ka[X]; k->y = ka[Y]; k->z = ka[Z];
//	return (p);
//}
//
///******* Decompose Affine Matrix *******/
//
///* Decompose 4x4 affine matrix A as TFRUK(U transpose), where t contains the
// * translation components, q contains the rotation R, u contains U, k contains
// * scale factors, and f contains the sign of the determinant.
// * Assumes A transforms column vectors in right-handed coordinates.
// * See Ken Shoemake and Tom Duff. Matrix Animation and Polar Decomposition.
// * Proceedings of Graphics Interface 1992.
// */
//
//static inline void decompAffine(_HMatrix A, _affineParts * parts)
//{
//	_HMatrix Q, S, U;
//	Q4t p;
//    
//	//Translation component.
//	parts->t = Q4Make(A[X][W], A[Y][W], A[Z][W], 0);
//	double det = polarDecomp(A, Q, S);
//	if (det<0.0)
//	{
//		matrixCopy(Q, =, -Q, 3);
//		parts->f = -1;
//	}
//	else
//		parts->f = 1;
//    
//	parts->q = Q4FromMatrix(Q);
//	parts->k = spectDecomp(S, U);
//	parts->u = Q4FromMatrix(U);
//	p = snuggle(parts->u, &parts->k);
//	parts->u = Q4Multiply(parts->u, p);
//}
//
//static inline void M16Decompose(M16t M16,V3t t,Q4t r,V3t s,Q4t so ){
//    
//	_affineParts parts;
//    _HMatrix hmatrix;
//    
//    // Transpose copy of LTW
//    for ( int i =0; i<4; i++)
//    {
//        for ( int j=0; j<4; j++)
//        {
//            hmatrix[i][j] = M16.m[j*4+i];
//        }
//    }
//    
//    decompAffine(hmatrix, &parts);
//    
//    double mul = 1.0;
//    if (parts.t.w != 0.0)
//        mul = 1.0 / parts.t.w;
//    
//    t.x = parts.t.x * mul;
//    t.y = parts.t.y * mul;
//    t.z = parts.t.z * mul;
//    
//    r = Q4Make(parts.q.x, parts.q.y, parts.q.z, parts.q.w);
//    
//    mul = 1.0;
//    if (parts.k.w != 0.0)
//        mul = 1.0 / parts.k.w;
//    
//    // mul be sign of determinant to support negative scales.
//    mul *= parts.f;
//    s.x= parts.k.x * mul;
//    s.y = parts.k.y * mul;
//    s.z = parts.k.z * mul;
//    
//    so = Q4Make(parts.u.x, parts.u.y, parts.u.z, parts.u.w);
//}




