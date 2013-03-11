//
//  Defender.m
//  TestBezier
//
//  Created by KirbyGee on 3/1/13.
//
//

#import "Defender.h"
#import "HelloWorldLayer.h"


@implementation Defender
@synthesize defenderMovementArray;

-(id) initWithFile:(NSString *)filename {
	if ((self = [super initWithFile:filename])) {
      defenderPlacementBool = NO;
      self.defenderMovementArray = [[NSMutableArray alloc] init];
      hold = NO;
      [self schedule:@selector(move:)];
   }
   return self;
}
-(id) moveDefenderBack:(CGPoint) endpt{
   CGPoint p1 = [[self.defenderMovementArray objectAtIndex:[self.defenderMovementArray count]-6] CGPointValue];
   CGPoint p2 = [[self.defenderMovementArray objectAtIndex:[self.defenderMovementArray count]-1] CGPointValue];
   p2 = self.position;
   
   float defenderMovementSlope = (p2.y - p1.y) / (p2.x - p1.x);
   float adjDist = 180;
   float posX = sqrt(pow(adjDist, 2) / (1 + pow(defenderMovementSlope, 2)));
   //calculate y coordinate of control point
   float posY = defenderMovementSlope * posX;
   CGPoint playerControl;
   bool defenderBottomtoTop;
   
   if (p2.y > p1.y){
      defenderBottomtoTop = YES;
   }
   else if (p2.y < p1.y){
      defenderBottomtoTop = NO;
   }
   
   bool infSlope = NO;
   
   if (self.position.x == p1.x){
      infSlope = YES;
   }
   
   if (!infSlope){
      //slope is greater than 0
      if (defenderMovementSlope > 0){
         //player move bottom left to top right
         if (defenderBottomtoTop){
            //moving down left from right
            playerControl = ccpAdd(p2, ccp(posX, posY));
         }
         //player moving top right to bottom left
         else if (!defenderBottomtoTop){
            //moving down left from right
            playerControl = ccpSub(p2, ccp(posX, posY));
         }
      }
      //slope is less than 0
      else if (defenderMovementSlope < 0){
         //player move bottom right to top left
         if (defenderBottomtoTop){
            //moving down left from right
            playerControl = ccpSub(p2, ccp(posX, posY));
         }
         //player move top left to bottom right
         else if (!defenderBottomtoTop){
            //moving down left from right
            playerControl = ccpAdd(p2, ccp(posX, posY));
         }
      }
   }
   else if (infSlope){
      if (defenderBottomtoTop){
         playerControl = ccpAdd(p2, ccp(0, 200));
      }
      else if (!defenderBottomtoTop){
         playerControl = ccpAdd(p2, ccp(0, -200));
         
      }
   }
   NSMutableArray *bezierArray1 = [NSMutableArray array];
   // Add Beziers
   // Bezier 0
   ccBezierConfig bzConfig_0;
   bzConfig_0.controlPoint_1 = playerControl;
   bzConfig_0.controlPoint_2 = endpt;
   bzConfig_0.endPosition = endpt;
   CCBezierTo *bezierTo_0 = [CCBezierTo actionWithDuration:3.5f bezier:bzConfig_0];
   [bezierArray1 addObject:bezierTo_0];
   
   // create actionsequence and run action
   CCSequence *bezierSeq = [CCSequence actionWithArray:bezierArray1];
   
   [self runAction: [CCSequence actions:bezierSeq, nil]];
   
   return self;
}
-(void) move:(ccTime)dt{
   if ([Singleton sharedSingleron].defenderFollowBool){
      [self.defenderMovementArray addObject:[NSValue valueWithCGPoint:self.position]];
      
      float dx = followPlayer.position.x - self.position.x;
      float dy = followPlayer.position.y - self.position.y;
      float d = sqrt(dx*dx + dy*dy);
      float v = 75;
      if (followPlayer.playerMoving){
         if (d > 1){
            self.position = ccpAdd(self.position, ccp(dx/d * v * dt, dy/d * v *dt));
            defenderPlacementBool = YES;
         }
      }
      else if (!followPlayer.playerMoving){
         if (defenderPlacementBool){
            //move the defender in a beier path in front of the wide reciever
            float posDist = 40;
            float slope = (20 - followPlayer.position.y) / (160 - followPlayer.position.x);
            float posX = sqrt(pow(posDist, 2) / (1 + pow(slope, 2)));
            float posY = slope * posX;
            //slope is infinite
            if (followPlayer.position.x == 160){
               posY = -posDist;
            }
            
            CGPoint endpt;
            if (slope > 0){
               endpt = ccpSub(followPlayer.position, ccp(posX, posY));
            }
            else if (slope < 0){
               endpt = ccpAdd(followPlayer.position, ccp(posX, posY));
            }
            
            NSMutableArray *bezierArray1 = [NSMutableArray array];
            // Add Beziers
            // Bezier 0
            ccBezierConfig bzConfig_0;
            
            bzConfig_0.controlPoint_1 = followPlayer.position;
            bzConfig_0.controlPoint_2 = endpt;
            bzConfig_0.endPosition = endpt;
            CCBezierTo *bezierTo_0 = [CCBezierTo actionWithDuration:.75f bezier:bzConfig_0];
            [bezierArray1 addObject:bezierTo_0];
            
            // create actionsequence and run action
            CCSequence *bezierSeq = [CCSequence actionWithArray:bezierArray1];
            [self runAction: [CCSequence actions:bezierSeq, nil]];
            
            defenderPlacementBool = NO;
         }
      }
   }
   else if (![Singleton sharedSingleron].defenderFollowBool){
      [self.defenderMovementArray addObject:[NSValue valueWithCGPoint:self.position]];
      
      if ([self.defenderMovementArray count] > 0 && !hold){
         [self performSelector:@selector(removeArray:) withObject:nil afterDelay:3.5f];
         NSLog(@"arraycount: %i", [self.defenderMovementArray count]);
         //[defenderArray removeAllObjects];
         hold = YES;
      }
   }
}
-(void) removeArray:(id)sender{
   [self.defenderMovementArray removeAllObjects];
   hold = NO;
}
-(id) followPlayer: (WideReceivers*) player{
   followPlayer = player;
   return self;
}
@end
