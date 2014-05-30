//
//  Menu.h
//  nike3dField
//
//  Created by Chroma Developer on 3/25/14.
//
//

#import "NKSceneNode.h"
#import "NKScrollNode.h"

@class FuelBar;

@interface MainMenu : NKSceneNode <NKTableCellDelegate>
{
    FuelBar *fuelBar;
}

@end
