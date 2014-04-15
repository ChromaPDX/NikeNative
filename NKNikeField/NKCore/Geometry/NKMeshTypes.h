//
//  NKMeshTypes.h
//  NKNative
//
//  Created by Leif Shackelford on 4/6/14.
//  Copyright (c) 2014 Chroma Developer. All rights reserved.
//

#ifndef NKNative_NKMeshTypes_h
#define NKNative_NKMeshTypes_h

#define kGroupIndexVertex               0
#define kGroupIndexTextureCoordIndex	1
#define kGroupIndexNormalIndex			2

#pragma mark -
#pragma mark VertexTextureCombinations
#pragma mark -
// This implements a binary search tree that will help us determine which vertices need to be duplicated. In
// OpenGL, each vertex has to have one and only one set of texture coordinates, so if a single vertex is shared
// by multiple triangles and has different texture coordinates in each, those vertices need to be duplicated
// so that there is one copy of that vertex for every distinct set of texture coordinates.

// This works with index values, not actual Vertex3D values, for speed, and because that's the way the
// OBJ file format tells us about them
//
// An actualVertex value of UINT_MAX means that the actual integer value hasn't been determined yet.
typedef struct {
	GLuint	originalVertex;
	GLuint	textureCoords;
	GLuint	actualVertex;
	void	*greater;
	void	*lesser;
	
} VertexTextureIndex;
static inline VertexTextureIndex *VertexTextureIndexMake(GLuint inVertex, GLuint inTextureCoords, GLuint inActualVertex)
{
	VertexTextureIndex *ret = (VertexTextureIndex*)malloc(sizeof(VertexTextureIndex));
	ret->originalVertex = inVertex;
	ret->textureCoords = inTextureCoords;
	ret->actualVertex = inActualVertex;
	ret->greater = NULL;
	ret->lesser = NULL;
	return ret;
}
#define VertexTextureIndexMakeEmpty(x,y) VertexTextureIndexMake(x, y, UINT_MAX)
// recursive search function - looks for a match for a given combination of vertex and
// texture coordinates. If not found, returns UINT_MAX
static inline GLuint VertexTextureIndexMatch(VertexTextureIndex *node, GLuint matchVertex, GLuint matchTextureCoords)
{
	if (node->originalVertex == matchVertex && node->textureCoords == matchTextureCoords)
		return node->actualVertex;
	
	if (node->greater != NULL)
	{
		GLuint greaterIndex = VertexTextureIndexMatch((VertexTextureIndex*)node->greater, matchVertex, matchTextureCoords);
		if (greaterIndex != UINT_MAX)
			return greaterIndex;
	}
	
	if (node->lesser != NULL)
	{
		GLuint lesserIndex = VertexTextureIndexMatch((VertexTextureIndex*)node->lesser, matchVertex, matchTextureCoords);
		return lesserIndex;
	}
	return UINT_MAX;
}
static inline VertexTextureIndex * VertexTextureIndexAddNode(VertexTextureIndex *node, GLuint newVertex, GLuint newTextureCoords)
{
	// If requested new node matches the one being added to, then don't add, just return pointer to match
	if (node->originalVertex == newVertex && node->textureCoords == newTextureCoords)
		return node;
	if (node->originalVertex > newVertex || (node->originalVertex == newVertex && node->textureCoords > newTextureCoords))
	{
		if (node->lesser != NULL)
			return VertexTextureIndexAddNode((VertexTextureIndex*)node->lesser, newVertex, newTextureCoords);
		else
		{
			VertexTextureIndex *newNode = VertexTextureIndexMakeEmpty(newVertex, newTextureCoords);
			node->lesser = newNode;
			return (VertexTextureIndex*)node->lesser;
		}
	}
	else
	{
		if (node->greater != NULL)
			return VertexTextureIndexAddNode((VertexTextureIndex*)node->greater, newVertex, newTextureCoords);
		else
		{
			VertexTextureIndex *newNode = VertexTextureIndexMakeEmpty(newVertex, newTextureCoords);
			node->greater = newNode;
			return (VertexTextureIndex*)node->greater;
		}
	}
	return NULL; // shouldn't ever reach here.
}
static inline BOOL VertexTextureIndexContainsVertexIndex(VertexTextureIndex *node, GLuint matchVertex)
{
	if (node->originalVertex == matchVertex)
		return YES;
	
	BOOL greaterHas = NO;
	BOOL lesserHas = NO;
	
	if (node->greater != NULL)
		greaterHas = VertexTextureIndexContainsVertexIndex((VertexTextureIndex*)node->greater, matchVertex);
	if (node->lesser != NULL)
		lesserHas = VertexTextureIndexContainsVertexIndex((VertexTextureIndex*)node->lesser, matchVertex);
	return lesserHas || greaterHas;
}
static inline void VertexTextureIndexFree(VertexTextureIndex *node)
{
	if (node != NULL)
	{
		if (node->greater != NULL)
			VertexTextureIndexFree((VertexTextureIndex*)node->greater);
		if (node->lesser != NULL)
			VertexTextureIndexFree((VertexTextureIndex*)node->lesser);
		free(node);
	}
	
}
static inline GLuint VertexTextureIndexCountNodes(VertexTextureIndex *node)
{
	GLuint ret = 0;
	
	if (node)
	{
		ret++; // count this node
		
		// Add the children
		if (node->greater != NULL)
			ret += VertexTextureIndexCountNodes((VertexTextureIndex*)node->greater);
		if (node->lesser != NULL)
			ret += VertexTextureIndexCountNodes((VertexTextureIndex*)node->lesser);
	}
	return ret;
}

#endif
