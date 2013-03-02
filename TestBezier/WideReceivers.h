//
//  WideReceivers.h
//  TestBezier
//
//  Created by KirbyGee on 2/22/13.
//
//

#import "CCSprite.h"

@interface WideReceivers : CCSprite{
   bool playerBottomtoTop;
   bool playerLefttoRight;
   bool playerMoving;
   float playerSlope;
   CGPoint playerControl;
   CGPoint holdPoint;
   CGPoint playerStartPos;
}

-(id) initWithFile:(NSString *)filename;
-(id) playerStreak: (NSMutableArray*) playBook;
-(id) setHoldPosition:(CGPoint) holder;
-(id) movePlayerBack;
-(id) setStartingPosition:(CGPoint) startPos;

@property (nonatomic, readwrite) bool playerBottomtoTop;
@property (nonatomic, readwrite) bool playerLefttoRight;
@property (nonatomic, readwrite) bool playerMoving;
@property (nonatomic, readwrite) float playerSlope;
@property (nonatomic, readwrite) CGPoint playerControl;
@property (nonatomic, readwrite) CGPoint holdPoint;
@property (nonatomic, readwrite) CGPoint playerStartPos;

@end
