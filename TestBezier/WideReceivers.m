//
//  WideReceivers.m
//  TestBezier
//
//  Created by KirbyGee on 2/22/13.
//
//

#import "WideReceivers.h"
#import "HelloWorldLayer.h"

@implementation WideReceivers
@synthesize playerBottomtoTop, playerLefttoRight, playerMoving, playerSlope, playerControl, holdPoint, playerStartPos;
-(id) initWithFile:(NSString *)filename {
	if ((self = [super initWithFile:filename])) {
      self.playerStartPos = self.position;      
   }
   return self;
}
-(id) setStartingPosition:(CGPoint) startPos{
   self.position = startPos;
   self.playerStartPos = startPos;
   
   return self;
}
-(id) setHoldPosition:(CGPoint) holder{
   self.holdPoint = holder;
   
   return self;
}
-(id) movePlayerBack{
   [self stopAllActions];
   if (self.playerMoving){
      NSMutableArray *bezierArray1 = [NSMutableArray array];
      // Add Beziers
      // Bezier 0
      ccBezierConfig bzConfig_0;
      
      //calculate slope from points
      CGPoint lastPoint = self.position;
      float playerMovementSlope = (self.position.y - holdPoint.y) / (self.position.x - holdPoint.x);
      if (self.position.y < holdPoint.y){
         self.playerBottomtoTop = NO;
      }
      else if (self.position.y > holdPoint.y){
         self.playerBottomtoTop = YES;
      }
      
      float adjDist;
      
      if (self.playerLefttoRight){
         float distToLeftBound = 320 - self.position.x;
         adjDist = distToLeftBound;
      }
      else if (!self.playerLefttoRight){
         float distToRightBound = self.position.x;
         adjDist = distToRightBound;
      }
      
      bool infSlope = NO;
      
      if (self.position.x == holdPoint.x){
         infSlope = YES;
      }
      
      //slope if not infinity
      if (!infSlope){
         
         //calculate x coordinate of control point
         float posX = sqrt(pow(adjDist, 2) / (1 + pow(playerMovementSlope, 2)));
         //calculate y coordinate of control point
         float posY = playerMovementSlope * posX;
         
         //slope is greater than 0
         if (playerMovementSlope > 0){
            //player move bottom left to top right
            if (self.playerBottomtoTop){
               //moving down left from right
               self.playerControl = ccpAdd(lastPoint, ccp(posX, posY));
            }
            //player moving top right to bottom left
            else if (!self.playerBottomtoTop){
               //moving down left from right
               self.playerControl = ccpSub(lastPoint, ccp(posX, posY));
            }
         }
         //slope is less than 0
         else if (playerMovementSlope < 0){
            //player move bottom right to top left
            if (self.playerBottomtoTop){
               //moving down left from right
               self.playerControl = ccpSub(lastPoint, ccp(posX, posY));
            }
            //player move top left to bottom right
            else if (!self.playerBottomtoTop){
               //moving down left from right
               self.playerControl = ccpAdd(lastPoint, ccp(posX, posY));
            }
         }
         //slope is 0
         else if (playerMovementSlope == 0){
            //player moving left to right
            if (self.playerLefttoRight){
               self.playerControl = ccpAdd(lastPoint, ccp(adjDist, 0));
            }
            //player moving right to left
            else if (!self.playerLefttoRight){
               self.playerControl = ccpSub(lastPoint, ccp(adjDist, 0));
            }
         }
      }
      //infitie slope
      else if (infSlope){
         if (self.playerBottomtoTop){
            self.playerControl = ccpAdd(lastPoint, ccp(0, 200));
         }
         else if (!self.playerBottomtoTop){
            self.playerControl = ccpAdd(lastPoint, ccp(0, -200));
            
         }
      }
      
      bzConfig_0.controlPoint_1 = self.playerControl;
      bzConfig_0.controlPoint_2 = self.playerStartPos;
      bzConfig_0.endPosition = self.playerStartPos;
      CCBezierTo *bezierTo_0 = [CCBezierTo actionWithDuration:3.5f bezier:bzConfig_0];
      [bezierArray1 addObject:bezierTo_0];
      
      // create actionsequence and run action
      CCSequence *bezierSeq = [CCSequence actionWithArray:bezierArray1];
      [self runAction: [CCSequence actions:bezierSeq, nil]];
   }
   else if (!self.playerMoving){
      id moveBack = [CCMoveTo actionWithDuration:3.5 position:playerStartPos];
      
      [self runAction:[CCSequence actions:moveBack, nil]];
   }
   
   return self;
}
-(void) playerMoving:(id)sender{
   self.playerMoving = YES;
}
-(void)streakFinished:(id)sender{
   self.playerMoving = NO;
   //create path to new random point
   int randX = arc4random()%320;
   int randY = arc4random()%300 + 100;
   CGPoint randPoint = CGPointMake(randX, randY);
   
   //make sure the new point is at least 150 pixels away from current position
   while (ccpDistance(self.position, randPoint) < 150){
      randX = arc4random()%320;
      randY = arc4random()%300 + 100;
      randPoint = CGPointMake(randX, randY);
   }
   
   self.playerSlope = (randPoint.y - self.position.y) / (randPoint.x - self.position.x);
   
   if (randPoint.y < self.position.y){
      self.playerBottomtoTop = NO;
   }
   else if (randPoint.y > self.position.y){
      self.playerBottomtoTop = YES;
   }
   
   if (randPoint.x < self.position.x){
      self.playerLefttoRight = NO;
   }
   else if (randPoint.x > self.position.x){
      self.playerLefttoRight = YES;
   }
   
   //calc dist to new point
   float newDist = ccpDistance(self.position, randPoint);
   //find time to new point
   float time = newDist/480*5;
   id playerMove = [CCCallFunc actionWithTarget:self selector:@selector(playerMoving:)];
   id callback = [CCCallFunc actionWithTarget:self selector:@selector(streakFinished:)];
   //minimun delay time is .5 seconds, max is 1.5 seconds
   float delayTime = ((arc4random()%100) + 100) / 100;
   id delay = [CCDelayTime actionWithDuration:delayTime];
   id moveTo = [CCMoveTo actionWithDuration:time position:randPoint];
   [self runAction:[CCSequence actions:delay, playerMove, moveTo, callback, nil]];
}
-(id) playerStreak: (NSMutableArray*) playBook{
   self.playerMoving = YES;
   id callback = [CCCallFunc actionWithTarget:self selector:@selector(streakFinished:)];
   
   NSMutableArray *playArray = [[NSMutableArray alloc] init];
   for (int i = 1; i < [playBook count]; i++){
      CGPoint point = [[playBook objectAtIndex:i] CGPointValue];
      float pointDist = ccpDistance([[playBook objectAtIndex:i-1] CGPointValue], point);
      float time = pointDist/480*5;
      
      CCAction *moveTo = [CCMoveTo actionWithDuration:time position:point];
      [playArray addObject:moveTo];
   }
   [playArray addObject:callback];
   [self runAction:[CCSequence actionWithArray:playArray]];
   
   return self;
}
@end
