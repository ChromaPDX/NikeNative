//
//  NKMaterial.m


//  Contains code from:
//  Created by Jeff LaMarche on 12/18/08.
//  Copyright 2008 Jeff LaMarche. All rights reserved.
//

#import "NodeKitten.h"

@implementation NKMaterial

@synthesize name;
@synthesize diffuse;
@synthesize ambient;
@synthesize specular;
@synthesize shininess;
@synthesize texture;

+ (id)defaultMaterial
{
	return [[NKMaterial alloc] initWithName:@"default"
                                               shininess:65.0
                                                 diffuse:C4Make(0.8, 0.8, 0.8, 1.0)
                                                 ambient:C4Make(0.2, 0.2, 0.2, 1.0)
                                                specular:C4Make(0.0, 0.0, 0.0, 1.0)];
}

+ (id)materialsFromMtlFile:(NSString *)path
{
	NSMutableDictionary *ret = [NSMutableDictionary dictionary];
	[ret setObject:[NKMaterial defaultMaterial] forKey:@"default"];
    
	NSString *mtlData = [NSString stringWithContentsOfFile:path];
    
	NSArray *mtlLines = [mtlData componentsSeparatedByString:@"\n"];
	// Can't use fast enumeration here, need to manipulate line order
	for (int i = 0; i < [mtlLines count]; i++)
	{
		NSString *line = [mtlLines objectAtIndex:i];
		if ([line hasPrefix:@"newmtl"]) // Start of new material
		{
			// Determine start of next material
			int mtlEnd = -1;
			for (int j = i+1; j < [mtlLines count]; j++)
			{
				NSString *innerLine = [mtlLines objectAtIndex:j];
				if ([innerLine hasPrefix:@"newmtl"])
				{
					mtlEnd = j-1;
					
					break;
				}
                
			}
			if (mtlEnd == -1)
				mtlEnd = [mtlLines count]-1;
            
			
			NKMaterial *material = [[NKMaterial alloc] init];
			for (int j = i; j <= mtlEnd; j++)
			{
				NSString *parseLine = [mtlLines objectAtIndex:j];
				// ignore Ni, d, and illum, and texture - at least for now
				if ([parseLine hasPrefix:@"newmtl "])
					material.name = [parseLine substringFromIndex:7];
				else if ([parseLine hasPrefix:@"Ns "])
					material.shininess = [[parseLine substringFromIndex:3] floatValue];
				else if ([parseLine hasPrefix:@"Ka spectral"]) // Ignore, don't want consumed by next else
				{
					
				}
				else if ([parseLine hasPrefix:@"Ka "])  // CIEXYZ currently not supported, must be specified as RGB
				{
					NSArray *colorParts = [[parseLine substringFromIndex:3] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
					material.ambient = C4Make([[colorParts objectAtIndex:0] floatValue], [[colorParts objectAtIndex:1] floatValue], [[colorParts objectAtIndex:2] floatValue], 1.0);
				}
				else if ([parseLine hasPrefix:@"Kd "])
				{
					NSArray *colorParts = [[parseLine substringFromIndex:3] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
					material.diffuse =  C4Make([[colorParts objectAtIndex:0] floatValue], [[colorParts objectAtIndex:1] floatValue], [[colorParts objectAtIndex:2] floatValue], 1.0);
				}
				else if ([parseLine hasPrefix:@"Ks "])
				{
					NSArray *colorParts = [[parseLine substringFromIndex:3] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
					material.specular =  C4Make([[colorParts objectAtIndex:0] floatValue], [[colorParts objectAtIndex:1] floatValue], [[colorParts objectAtIndex:2] floatValue], 1.0);
				}
				else if ([parseLine hasPrefix:@"map_Kd "])
				{
					glEnableClientState(GL_TEXTURE);
					NSString *texName = [parseLine substringFromIndex:7];
					NSString *baseName = [[texName componentsSeparatedByString:@"."] objectAtIndex:0];
					
					// Okay, since PVRT files are compressed and not supported by UIImage, we have to have a way
					// of knowing the size of the PVRT file beforehand. What we'll do is, when we create the PVRT
					// file, we'll incorporate the size into the filename, so texture1.jpg becomes texture1-512.pvr4
					// when converted to a PVRT file, assuming it's 512x512 pixes.
					NSString *textureFilename = nil;
					int width = 0, height = 0;
					for (int i=4; i <= 1028; i*=2)
					{
						
						NSString *newBase = [NSString stringWithFormat:@"%@-%d", baseName, i];
						NSString *path = [[NSBundle mainBundle] pathForResource:newBase ofType:@"pvr4"];
						if (path != nil)
						{
							textureFilename = [NSString stringWithFormat:@"%@.pvr4", newBase];
							width = i;
							height = i;
							break;
						}
						path =  [[NSBundle mainBundle] pathForResource:newBase ofType:@"pvr2"];
						if (path != nil)
						{
							textureFilename = [NSString stringWithFormat:@"%@.pvr4", newBase];
							width = i;
							height = i;
							break;
						}
						
					}
					// No PVRT file found use original file
					if (textureFilename == nil)
						textureFilename = texName;
					// TODO: Look for PVRT file
                    
                    NKTexture *theTex = [NKTexture textureWithPVRNamed:textureFilename size:S2Make(width, height)];
			
					material.texture = theTex;
				}
                
			}
			
			[ret setObject:material forKey:material.name];
            //			[material release];
			
			i = mtlEnd;
		}
	}
	return ret;
}

#pragma mark -

- (instancetype)initWithName:(NSString *)inName shininess:(GLfloat)inShininess diffuse:(C4t)inDiffuse ambient:(C4t)inAmbient specular:(C4t)inSpecular
{
	return [self initWithName:inName shininess:inShininess diffuse:inDiffuse ambient:inAmbient specular:inSpecular texture:nil];
}
- (instancetype)initWithName:(NSString *)inName shininess:(GLfloat)inShininess diffuse:(C4t)inDiffuse ambient:(C4t)inAmbient specular:(C4t)inSpecular texture:(NKTexture *)inTexture
{
	if ((self = [super init]))
	{
		self.name = (inName == nil) ? @"default" : inName;
		self.diffuse = inDiffuse;
		self.ambient = inAmbient;
		self.specular = inSpecular;
		self.shininess = shininess;
		self.texture = inTexture;
	}
	return self;
}
#pragma mark -
- (NSString *)description
{
	return [NSString stringWithFormat:@"Material: %@ (Shininess: %f, Diffuse: {%f, %f, %f, %f}, Ambient: {%f, %f, %f, %f}, Specular: {%f, %f, %f, %f})", self.name, self.shininess, self.diffuse.r, self.diffuse.g, self.diffuse.b, self.diffuse.a, self.ambient.r, self.ambient.g, ambient.b, ambient.a, specular.r, specular.g, specular.b, specular.a];
}

- (void)dealloc 
{
    //	[name release];
    //	[texture release];
    //	[super dealloc];
}
@end

@implementation NKMaterialGroup


- (id)initWithName:(NSString *)inName
numberOfFaces:(GLuint)inNumFaces
material:(NKMaterial *)inMaterial;

{
	if ((self = [super init]))
	{
		_name = inName;
		_numberOfFaces = inNumFaces;
		_material = inMaterial;
        
		_faces = malloc(sizeof(UB3t) * _numberOfFaces);
		
	}
	return self;
}

-(void)dealloc {
    free(_faces);
}

@end
