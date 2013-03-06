//
//  Ball.h
//  TestBezier
//
//  Created by KirbyGee on 2/21/13.
//
//

#import "CCSprite.h"

@interface Ball : CCSprite{
   CCSprite *ballCopy;
   CCSprite *player;
}

-(id) initWithFile:(NSString *)filename;
-(id) createCopy;
-(id) followPlayer:(CCSprite*)playerToFollow;

@end
