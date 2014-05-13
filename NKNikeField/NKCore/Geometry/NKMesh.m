//
//  NKMesh.m
//  nike3dField
//
//  Created by Chroma Developer on 3/24/14.
//
//

#import "NodeKitten.h"

static inline void	processOneVertex(VertexTextureIndex *rootNode, GLuint vertexIndex, GLuint vertexTextureIndex, GLuint *vertexCount, V3t	*vertices, GLfloat  *allTextureCoords, GLfloat *textureCoords, GLuint componentsPerTextureCoord, GLushort *faceVertexIndex)
{
	//NSLog(@"Processing Vertex: %d, Texture Index: %d", vertexIndex, vertexTextureIndex);
	BOOL alreadyExists = VertexTextureIndexContainsVertexIndex(rootNode, vertexIndex);
	VertexTextureIndex *vertexNode = VertexTextureIndexAddNode(rootNode, vertexIndex, vertexTextureIndex);
	if (vertexNode->actualVertex == UINT_MAX)
	{
		if (!alreadyExists || rootNode == vertexNode)
		{
			
			vertexNode->actualVertex = vertexNode->originalVertex;
			
			// Wavefront's texture coord order is flip-flopped from what OpenGL expects
			for (int i = 0; i < componentsPerTextureCoord; i++)
				textureCoords[(vertexNode->actualVertex * componentsPerTextureCoord) + i] = allTextureCoords[(vertexNode->textureCoords * componentsPerTextureCoord) + componentsPerTextureCoord - (i+1)] ;
			
		}
		else
		{
			vertices[*vertexCount].x = vertices[vertexNode->originalVertex].x;
			vertices[*vertexCount].y = vertices[vertexNode->originalVertex].y;
			vertices[*vertexCount].z = vertices[vertexNode->originalVertex].z;
			vertexNode->actualVertex = *vertexCount;
			
			for (int i = 0; i < componentsPerTextureCoord; i++)
				textureCoords[(vertexNode->actualVertex * componentsPerTextureCoord) + i] = allTextureCoords[(vertexNode->textureCoords * componentsPerTextureCoord) + componentsPerTextureCoord - (i+1)];
			*vertexCount = *vertexCount + 1;
		}
	}
	*faceVertexIndex = vertexNode->actualVertex;
}


@implementation NKMesh

@synthesize sourceObjFilePath;
@synthesize sourceMtlFilePath;
@synthesize materials;
@synthesize groups;

- (id)initWithPath:(NSString *)path
{
	
    if ([[NKStaticDraw meshesCache]objectForKey:path]) {
        return [[NKStaticDraw meshesCache]objectForKey:path];
    }
    
	if ((self = [super init]))
	{
		self.groups = [NSMutableArray array];
		
		self.sourceObjFilePath = path;
        
        NSError* error;
        
        NSString *objData = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
        
        if (error) {
            NSLog(@"error loading obj file");
            return nil;
        }
        
		//NSString *objData = [NSString stringWithContentsOfFile:path];
		NSUInteger vertexCount = 0, faceCount = 0, textureCoordsCount=0, groupCount = 0;
		// Iterate through file once to discover how many vertices, normals, and faces there are
		NSArray *lines = [objData componentsSeparatedByString:@"\n"];
		BOOL firstTextureCoords = YES;
		NSMutableArray *vertexCombinations = [[NSMutableArray alloc] init];
		for (NSString * line in lines)
		{
			if ([line hasPrefix:@"v "])
				vertexCount++;
			else if ([line hasPrefix:@"vt "])
			{
				textureCoordsCount++;
				if (firstTextureCoords)
				{
					firstTextureCoords = NO;
					NSString *texLine = [line substringFromIndex:3];
					NSArray *texParts = [texLine componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
					valuesPerCoord = [texParts count];
				}
			}
			else if ([line hasPrefix:@"m"])
			{
				NSString *truncLine = [line substringFromIndex:7];
				self.sourceMtlFilePath = truncLine;
				NSString *mtlPath = [[NSBundle mainBundle] pathForResource:[[truncLine lastPathComponent] stringByDeletingPathExtension] ofType:[truncLine pathExtension]];
				self.materials = [NKMaterial materialsFromMtlFile:mtlPath];
			}
			else if ([line hasPrefix:@"g"])
				groupCount++;
			else if ([line hasPrefix:@"f"])
			{
				faceCount++;
				NSString *faceLine = [line substringFromIndex:2];
				NSArray *faces = [faceLine componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
				for (NSString *oneFace in faces)
				{
					NSArray *faceParts = [oneFace componentsSeparatedByString:@"/"];
					
					NSString *faceKey = [NSString stringWithFormat:@"%@/%@", [faceParts objectAtIndex:0], ([faceParts count] > 1) ? [faceParts objectAtIndex:1] : 0];
					if (![vertexCombinations containsObject:faceKey])
						[vertexCombinations addObject:faceKey];
				}
			}
			
		}
		vertices = malloc(sizeof(V3t) *  [vertexCombinations count]);
		GLfloat *allTextureCoords = malloc(sizeof(GLfloat) *  textureCoordsCount * valuesPerCoord);
		textureCoords = (textureCoordsCount > 0) ?  malloc(sizeof(GLfloat) * valuesPerCoord * [vertexCombinations count]) : NULL;
		// Store the counts
		numberOfFaces = faceCount;
		numberOfVertices = [vertexCombinations count];
		GLuint allTextureCoordsCount = 0;
		textureCoordsCount = 0;
		GLuint groupFaceCount = 0;
		GLuint groupCoordCount = 0;
		// Reuse our count variables for second time through
		vertexCount = 0;
		faceCount = 0;
		NKMaterialGroup *currentGroup = nil;
		NSUInteger lineNum = 0;
		BOOL usingGroups = YES;
		
		VertexTextureIndex *rootNode = nil;
		for (NSString * line in lines)
		{
			if ([line hasPrefix:@"v "])
			{
				NSString *lineTrunc = [line substringFromIndex:2];
				NSArray *lineVertices = [lineTrunc componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
				vertices[vertexCount].x = [[lineVertices objectAtIndex:0] floatValue];
				vertices[vertexCount].y = [[lineVertices objectAtIndex:1] floatValue];
				vertices[vertexCount].z = [[lineVertices objectAtIndex:2] floatValue];
				// Ignore weight if it exists..
				vertexCount++;
			}
			else if ([line hasPrefix: @"vt "])
			{
				NSString *lineTrunc = [line substringFromIndex:3];
				NSArray *lineCoords = [lineTrunc componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
				//int coordCount = 1;
				for (NSString *oneCoord in lineCoords)
				{
                    //					if (valuesPerCoord == 2 /* using UV Mapping */ && coordCount++ == 1 /* is U value */)
                    //						allTextureCoords[allTextureCoordsCount] = CONVERT_UV_U_TO_ST_S([oneCoord floatValue]);
                    //					else
                    allTextureCoords[allTextureCoordsCount] = [oneCoord floatValue];
					//NSLog(@"Setting allTextureCoords[%d] to %f", allTextureCoordsCount, [oneCoord floatValue]);
					allTextureCoordsCount++;
				}
				
				// Ignore weight if it exists..
				textureCoordsCount++;
			}
			else if ([line hasPrefix:@"g "])
			{
				NSString *groupName = [line substringFromIndex:2];
				NSUInteger counter = lineNum+1;
				NSUInteger currentGroupFaceCount = 0;
				NSString *materialName = nil;
				while (counter < [lines count])
				{
					NSString *nextLine = [lines objectAtIndex:counter++];
					if ([nextLine hasPrefix:@"usemtl "])
						materialName = [nextLine substringFromIndex:7];
					else if ([nextLine hasPrefix:@"f "])
					{
						// TODO: Loook for quads and double-increment
						currentGroupFaceCount ++;
					}
					else if ([nextLine hasPrefix:@"g "])
						break;
				}
				
				NKMaterial *material = [materials objectForKey:materialName] ;
				if (material == nil)
					material = [NKMaterial defaultMaterial];
				
				currentGroup = [[NKMaterialGroup alloc] initWithName:groupName
                                                       numberOfFaces:currentGroupFaceCount
                                                            material:material];
				[groups addObject:currentGroup];
                //				[currentGroup release];
				groupFaceCount = 0;
				groupCoordCount = 0;
			}
			else if ([line hasPrefix:@"usemtl "])
			{
				NSString *materialKey = [line substringFromIndex:7];
				currentGroup.material = [materials objectForKey:materialKey];
			}
			else if ([line hasPrefix:@"f "])
			{
				NSString *lineTrunc = [line substringFromIndex:2];
				NSArray *faceIndexGroups = [lineTrunc componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
				
				// If no groups in file, create one group that has all the vertices and uses the default material
				if (currentGroup == nil)
				{
					NKMaterial *tempMaterial = nil;
					NSArray *materialKeys = [materials allKeys];
					if ([materialKeys count] == 2)
					{
						// 2 means there's one in file, plus default
						for (NSString *key in materialKeys)
							if (![key isEqualToString:@"default"])
								tempMaterial = [materials objectForKey:key];
					}
					if (tempMaterial == nil)
						tempMaterial = [NKMaterial defaultMaterial];
					
					currentGroup = [[NKMaterialGroup alloc] initWithName:@"default"
                                                           numberOfFaces:numberOfFaces
                                                                material:tempMaterial];
					[groups addObject:currentGroup];
                    //					[currentGroup release];
					usingGroups = NO;
				}
				
				// TODO: Look for quads and build two triangles
				
				NSArray *vertex1Parts = [[faceIndexGroups objectAtIndex:0] componentsSeparatedByString:@"/"];
				GLuint vertex1Index = [[vertex1Parts objectAtIndex:kGroupIndexVertex] intValue]-1;
				GLuint vertex1TextureIndex = 0;
				if ([vertex1Parts count] > 1)
					vertex1TextureIndex = [[vertex1Parts objectAtIndex:kGroupIndexTextureCoordIndex] intValue]-1;
				if (rootNode == NULL)
					rootNode =  VertexTextureIndexMake(vertex1Index, vertex1TextureIndex, UINT_MAX);
				
				processOneVertex(rootNode, vertex1Index, vertex1TextureIndex, &vertexCount, vertices, allTextureCoords, textureCoords, valuesPerCoord, &(currentGroup.faces[groupFaceCount].i1));
                
				NSArray *vertex2Parts = [[faceIndexGroups objectAtIndex:1] componentsSeparatedByString:@"/"];
                
				processOneVertex(rootNode, [[vertex2Parts objectAtIndex:kGroupIndexVertex] intValue]-1, [vertex2Parts count] > 1 ? [[vertex2Parts objectAtIndex:kGroupIndexTextureCoordIndex] intValue]-1 : 0, &vertexCount, vertices, allTextureCoords, textureCoords, valuesPerCoord, &currentGroup.faces[groupFaceCount].i2);
                
				NSArray *vertex3Parts = [[faceIndexGroups objectAtIndex:2] componentsSeparatedByString:@"/"];
                
				processOneVertex(rootNode, [[vertex3Parts objectAtIndex:kGroupIndexVertex] intValue]-1, [vertex3Parts count] > 1 ? [[vertex3Parts objectAtIndex:kGroupIndexTextureCoordIndex] intValue]-1 : 0, &vertexCount, vertices, allTextureCoords, textureCoords, valuesPerCoord, &currentGroup.faces[groupFaceCount].i3);
				
				faceCount++;
				groupFaceCount++;
			}
			lineNum++;
			
		}
		NSLog(@"Final vertex count: %d", numberOfVertices);
		NSLog(@"Final face count: %d", numberOfFaces);
		
		[self calculateNormals];
        
		if (allTextureCoords)
			free(allTextureCoords);
        
		VertexTextureIndexFree(rootNode);
	}
    
    [[NKStaticDraw meshesCache] setObject:self forKey:path];
    NSLog(@"add OBJ named: %@ to mesh cache", [path lastPathComponent]);
	return self;
}

- (void)calculateNormals
{
	if (surfaceNormals)
		free(surfaceNormals);
	
	// Calculate surface normals and keep running sum of vertex normals
	surfaceNormals = calloc(numberOfFaces, sizeof(V3t));
	vertexNormals = calloc(numberOfVertices, sizeof(V3t));
	NSUInteger index = 0;
	NSUInteger *facesUsedIn = calloc(numberOfVertices, sizeof(NSUInteger)); // Keeps track of how many triangles any given vertex is used in
	for (int i = 0; i < [groups count]; i++)
	{
		NKMaterialGroup *oneGroup = [groups objectAtIndex:i];
        
		for (int j = 0; j < oneGroup.numberOfFaces; j++)
		{
			T3t triangle = T3Make(vertices[oneGroup.faces[j].i1], vertices[oneGroup.faces[j].i2], vertices[oneGroup.faces[j].i3]);
			
			surfaceNormals[index] = V3GetTriangleSurfaceNormal(triangle);
#ifdef USE_FAST_NORMALIZE
			V3FastNormalize(&surfaceNormals[index]);
#else
			surfaceNormals[index] = V3Normalize(surfaceNormals[index]);
#endif
			vertexNormals[oneGroup.faces[j].i1] = V3Add(surfaceNormals[index], vertexNormals[oneGroup.faces[j].i1]);
			vertexNormals[oneGroup.faces[j].i2] = V3Add(surfaceNormals[index], vertexNormals[oneGroup.faces[j].i2]);
			vertexNormals[oneGroup.faces[j].i3] = V3Add(surfaceNormals[index], vertexNormals[oneGroup.faces[j].i3]);
			
			facesUsedIn[oneGroup.faces[j].i1]++;
			facesUsedIn[oneGroup.faces[j].i2]++;
			facesUsedIn[oneGroup.faces[j].i3]++;
			
			
			index++;
		}
	}
	
	// Loop through vertices again, dividing those that are used in multiple faces by the number of faces they are used in
	for (int i = 0; i < numberOfVertices; i++)
	{
		if (facesUsedIn[i] > 1)
		{
			vertexNormals[i].x /= facesUsedIn[i];
			vertexNormals[i].y /= facesUsedIn[i];
			vertexNormals[i].z /= facesUsedIn[i];
		}
#ifdef USE_FAST_NORMALIZE
		V3FastNormalize(&vertexNormals[i]);
#else
        vertexNormals[i] = V3Normalize(vertexNormals[i]);
#endif
	}
	free(facesUsedIn);
}

- (void)dealloc
{
	if (vertices)
		free(vertices);
	if (surfaceNormals)
		free(surfaceNormals);
	if (vertexNormals)
		free(vertexNormals);
	if (textureCoords)
		free(textureCoords);
    if (vertexColors) {
        free(vertexColors);
    }
}

-(V3t*) getVertices:(int*)count{
    *count = numberOfFaces;
    return vertices;
}

-(void) drawWithTexture:(NKTexture*)texture color:(C4t)color {
    
    if (NK_GL_VERSION == 2) {

        [texture enableAndBind:0];
        
        [vertexBuffer bind:^{
            glDrawArrays(vertexBuffer.drawMode, 0, vertexBuffer.numberOfElements);
        }];
        
    }
    
    else {
        glEnableClientState(GL_VERTEX_ARRAY);
        glEnableClientState(GL_NORMAL_ARRAY);
        glEnableClientState(GL_COLOR_ARRAY);
        glEnableClientState(GL_TEXTURE_COORD_ARRAY);
        
        glVertexPointer(3, GL_FLOAT, 0, vertices);
        glNormalPointer(GL_FLOAT, 0, vertexNormals);
        
        
        for (int i = 0; i < numberOfVertices; i++){
            memcpy(vertexColors+(i), &color.r, sizeof(C4t));
        }
        
        
        glTexCoordPointer(2, GL_FLOAT, 0, textureCoords);
        
        glColorPointer(4,GL_FLOAT, 0, &vertexColors[0]);
        
        
        if (_primitiveType || !groups.count) {
            
            
            [texture bind];
            
            
            C4t black = C4Make(0., 0., 0., 1.);
            
            
            glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, (const GLfloat *)&black);
            glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, (const GLfloat *)&black);
            glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, (const GLfloat *)&black);
            glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, 0.);
            
            glDrawArrays(GL_TRIANGLE_STRIP, 0, numberOfVertices);
            
            
            glDisableClientState(GL_TEXTURE_COORD_ARRAY);
            [texture unbind];
            
            
            glDisableClientState(GL_COLOR_ARRAY);
            
            
        }
        
        else {
            
            
            
            for (NKMaterialGroup *group in groups)
            {
                if (textureCoords != NULL && group.material.texture != nil)
                    [group.material.texture bind];
                
                // Set color and materials based on group's material
                C4t ambient = group.material.ambient;
                glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, (const GLfloat *)&ambient);
                
                C4t diffuse = group.material.diffuse;
                glColor4f(diffuse.r, diffuse.g, diffuse.b, diffuse.a);
                
                glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE,  (const GLfloat *)&diffuse);
                
                C4t specular = group.material.specular;
                glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, (const GLfloat *)&specular);
                
                glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, group.material.shininess);
                
                glDrawElements(GL_TRIANGLES, 3*group.numberOfFaces, GL_UNSIGNED_SHORT, &(group.faces[0]));
            }
            
            if (textureCoords != NULL)
                glDisableClientState(GL_TEXTURE_COORD_ARRAY);
        }
        
        glDisableClientState(GL_VERTEX_ARRAY);
        glDisableClientState(GL_NORMAL_ARRAY);
        
    }
    
}

-(void) drawWithColor:(C4t)color {
    
    if (NK_GL_VERSION == 2) {
        
        [vertexBuffer bind:^{
            glDrawArrays(vertexBuffer.drawMode, 0, vertexBuffer.numberOfElements);
        }];
        
    }
    else {
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_NORMAL_ARRAY);
    
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glNormalPointer(GL_FLOAT, 0, vertexNormals);
    
    
    for (int i = 0; i < numberOfVertices; i++){
        memcpy(vertexColors+(i), &color.r, sizeof(C4t));
    }
    
    glEnableClientState(GL_COLOR_ARRAY);
    glColorPointer(4,GL_FLOAT, 0, &vertexColors[0]);
    
    
    if (_primitiveType || !groups.count) {
        
        C4t black = C4Make(0., 0., 0., 1.);
        
        
        glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, (const GLfloat *)&black);
        glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, (const GLfloat *)&black);
        glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, (const GLfloat *)&black);
        glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, 0.);

        glDrawArrays(GL_TRIANGLE_STRIP, 0, numberOfVertices);
        
    }
    
    else {
        
        if (textureCoords != NULL)
        {
            glEnableClientState(GL_TEXTURE_COORD_ARRAY);
            glTexCoordPointer(valuesPerCoord, GL_FLOAT, 0, textureCoords);
        }
        
        for (NKMaterialGroup *group in groups)
        {
            if (textureCoords != NULL && group.material.texture != nil)
                [group.material.texture bind];
            
            // Set color and materials based on group's material
            C4t ambient = group.material.ambient;
            glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, (const GLfloat *)&ambient);
            
            C4t diffuse = group.material.diffuse;
            glColor4f(diffuse.r, diffuse.g, diffuse.b, diffuse.a);
            
            glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE,  (const GLfloat *)&diffuse);
            
            C4t specular = group.material.specular;
            glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, (const GLfloat *)&specular);
            
            glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, group.material.shininess);
            
            glDrawElements(GL_TRIANGLES, 3*group.numberOfFaces, GL_UNSIGNED_SHORT, &(group.faces[0]));
        }
        
    }
    glDisableClientState(GL_COLOR_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_NORMAL_ARRAY);
        
    }
    
}

- (instancetype)initWithPrimitive:(NKPrimitive)primitive
{
    NSString *pstring = [NKStaticDraw stringForPrimitive:primitive];
    
    if ([[NKStaticDraw meshesCache]objectForKey:pstring]) {
        return [[NKStaticDraw meshesCache]objectForKey:pstring];
    }
    
    self = [super init];
    
    if (self) {
        
    _primitiveType = primitive;
    
    switch (primitive) {
           
        case NKPrimitiveSphere:
            if (NK_GL_VERSION == 2) {
                vertexBuffer = [NKVertexBuffer sphereWithStacks:16 slices:16 squash:1.];
                numberOfVertices = vertexBuffer.numberOfElements;
            }
            else {
                [self sphereWithStacks:16 slices:16 squash:1.];
            }
            break;
           
        case NKPrimitiveCube:
            if (NK_GL_VERSION == 2){
                vertexBuffer = [NKVertexBuffer defaultCube];
                numberOfVertices = vertexBuffer.numberOfElements;
            }
            break;
            
        case NKPrimitiveRect:
            if (NK_GL_VERSION == 2) {
                vertexBuffer = [NKVertexBuffer defaultRect];
                numberOfVertices = 6;
            }
            else {
                [self defaultRect];
            }
            //  [self sphereWithStacks:16 slices:16 squash:1.];
            break;
        default:
            break;
    }
    
    [[NKStaticDraw meshesCache] setObject:self forKey:pstring];
        
    NSLog(@"add primitive: %@ to mesh cache with %d vertices", pstring, numberOfVertices);
        
    }
    return self;
}

-(void)defaultRect {

    
        numberOfVertices = 4;
        
        V3t nvertices[] = {
            {-.5f,  .5f, -0.0},
            { .5f,  .5f, -0.0},
            {-.5f, -.5f, -0.0},
            { .5f, -.5f, -0.0}
        };
        
        V3t nnormals[] = {
            {0.0, 0.0, 1.0},
            {0.0, 0.0, 1.0},
            {0.0, 0.0, 1.0},
            {0.0, 0.0, 1.0}
        };
        
        GLfloat ntexCoords[] = {
            0.0, 1.0,
            1.0, 1.0,
            0.0, 0.0,
            1.0, 0.0
        };
        
        
        GLfloat col[4] = {1., 1., 1., 1.};
        
        vertices = (V3t*)malloc(sizeof(V3t)*numberOfVertices);
        memcpy(vertices, nvertices, sizeof(V3t)*numberOfVertices);
        
        vertexNormals = (V3t*)malloc(sizeof(V3t)*numberOfVertices);
        memcpy(vertexNormals, nnormals, sizeof(V3t)*numberOfVertices);
        
        textureCoords = (float*)malloc(sizeof(GLfloat)*2*numberOfVertices);
        memcpy(textureCoords, ntexCoords, sizeof(GLfloat)*2*numberOfVertices);
        
        vertexColors = (C4t*)malloc(sizeof(GLfloat)*4*numberOfVertices);
        for (int i = 0; i < numberOfVertices; i++){
            memcpy(vertexColors+(i), &col[0], sizeof(C4t));
        }
        
}

-(void)sphereWithStacks:(GLint)stacks slices:(GLint)slices squash:(GLfloat)squash
{
    unsigned int colorIncrement = 0;
    unsigned int blue = 1.;
    unsigned int red = 1.;
    unsigned int green = 1.;
    
    colorIncrement = 1./stacks;
    
    float m_Scale = 1.;

    // Vertices
    vertices = (V3t*)malloc(sizeof(V3t) * ((slices*2+2) * (stacks)));
    F1t *vPtr = (F1t*)&vertices[0];
    
    // Color
    vertexColors = (C4t*)malloc(sizeof(C4t) * ((slices*2+2) * (stacks)));
    F1t *cPtr = (F1t*)&vertexColors[0];
    
    // Normal pointers for lighting
    vertexNormals = (V3t*)malloc(sizeof(V3t) * ((slices*2+2) * (stacks)));
    F1t *nPtr = (F1t*)&vertexNormals[0];
    
    textureCoords = (F1t*)malloc(sizeof(F1t) * 2 * ((slices*2+2) * (stacks)));
    F1t *tPtr = &textureCoords[0];
    
    unsigned int phiIdx, thetaIdx;
    
    for(phiIdx = 0; phiIdx < stacks; phiIdx++)
    {
        //starts at -pi/2 goes to pi/2
        //the first circle
        float phi0 = M_PI * ((float)(phiIdx+0) * (1.0/(float)(stacks)) - 0.5);
        //second one
        float phi1 = M_PI * ((float)(phiIdx+1) * (1.0/(float)(stacks)) - 0.5);
        float cosPhi0 = cos(phi0);
        float sinPhi0 = sin(phi0);
        float cosPhi1 = cos(phi1);
        float sinPhi1 = sin(phi1);
        
        float cosTheta, sinTheta;
        //longitude
        for(thetaIdx = 0; thetaIdx < slices; thetaIdx++)
        {
            float theta = -2.0*M_PI * ((float)thetaIdx) * (1.0/(float)(slices - 1));
            cosTheta = cos(theta);
            sinTheta = sin(theta);
            //We're generating a vertical pair of points, such
            //as the first point of stack 0 and the first point of stack 1
            //above it. this is how triangle_strips work,
            //taking a set of 4 vertices and essentially drawing two triangles
            //at a time. The first is v0-v1-v2 and the next is v2-v1-v3, and so on.
            
            //get x-y-x of the first vertex of stack
            vPtr[0] = m_Scale*cosPhi0 * cosTheta;
            vPtr[1] = m_Scale*sinPhi0 * squash;
            vPtr[2] = m_Scale*(cosPhi0 * sinTheta);
            //the same but for the vertex immediately above the previous one.
            vPtr[3] = m_Scale*cosPhi1 * cosTheta;
            vPtr[4] = m_Scale*sinPhi1 * squash;
            vPtr[5] = m_Scale*(cosPhi1 * sinTheta);
            
            nPtr[0] = cosPhi0 * cosTheta;
            nPtr[1] = sinPhi0;
            nPtr[2] = cosPhi0 * sinTheta;
            nPtr[3] = cosPhi1 * cosTheta;
            nPtr[4] = sinPhi1;
            nPtr[5] = cosPhi1 * sinTheta;
            
            if(tPtr!=nil){
                GLfloat texX = (float)thetaIdx * (1.0f/(float)(slices-1));
                tPtr[0] = texX;
                tPtr[1] = (float)(phiIdx + 0) * (1.0f/(float)(stacks));
                tPtr[2] = texX;
                tPtr[3] = (float)(phiIdx + 1) * (1.0f/(float)(stacks));
            }
            
            cPtr[0] = red;
            cPtr[1] = green;
            cPtr[2] = blue;
            cPtr[4] = red;
            cPtr[5] = green;
            cPtr[6] = blue;
            cPtr[3] = cPtr[7] = 1.;
            
            cPtr += 2*4;
            vPtr += 2*3;
            nPtr += 2*3;
            
            if(tPtr != nil) tPtr += 2*2;
        }
//        blue+=colorIncrement;
//        red-=colorIncrement;
        
        //Degenerate triangle to connect stacks and maintain winding order
        
        vPtr[0] = vPtr[3] = vPtr[-3];
        vPtr[1] = vPtr[4] = vPtr[-2];
        vPtr[2] = vPtr[5] = vPtr[-1];
        
        nPtr[0] = nPtr[3] = nPtr[-3];
        nPtr[1] = nPtr[4] = nPtr[-2];
        nPtr[2] = nPtr[5] = nPtr[-1];
        
        if(tPtr != nil){
            tPtr[0] = tPtr[2] = tPtr[-2];
            tPtr[1] = tPtr[3] = tPtr[-1];
        }
        
    }
    
    numberOfVertices = (vPtr - (F1t*)&vertices[0])/3;
    
}

@end
