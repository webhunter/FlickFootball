//
//  CopyBall.h
//  TestBezier
//
//  Created by KirbyGee on 3/5/13.
//
//

#import "CCSprite.h"
#import "Ball.h"

@interface CopyBall : CCSprite{
}
-(id) initWithFile:(NSString *)filename;
-(id) fadeAndRemove;

@end
