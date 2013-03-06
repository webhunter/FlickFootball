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

-(id) initWithFile:(NSString *)filename {
	if ((self = [super initWithFile:filename])) {
      defenderPlacementBool = NO;
      [self schedule:@selector(move:)];
   }
   return self;
}
-(void) move:(ccTime)dt{
   if ([Singleton sharedSingleron].defenderFollowBool){
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
}
-(id) followPlayer: (WideReceivers*) player{
   followPlayer = player;
   return self;
}

@end
