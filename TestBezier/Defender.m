//
//  Defender.m
//  TestBezier
//
//  Created by KirbyGee on 3/1/13.
//
//

#import "Defender.h"
#import "HelloWorldLayer.h"

extern bool followPlayers;

@implementation Defender
-(id) initWithFile:(NSString *)filename {
	if ((self = [super initWithFile:filename])) {
      i = 0;
   }
   return self;
}
-(int) getThePlayer{
   return playerNumber;
}
-(id) pickaPlayer{
   playerNumber = arc4random()%2 +1;
   
   return self;
}
-(id) followPlayer: (WideReceivers*) player{
   float dt = .0166;
   float dx = player.position.x - self.position.x;
   float dy = player.position.y - self.position.y;
   float d = sqrt(dx*dx + dy*dy);
   float v = 75;
   
   if (player.playerMoving){
      if (d > 1){
         self.position = ccpAdd(self.position, ccp(dx/d * v * dt, dy/d * v *dt));
         i = 0;
      }
   }
   else if (!player.playerMoving){
      i++;
      if (i < 2){
         float posDist = 40;
         float slope = (20 - player.position.y) / (160 - player.position.x);
         float posX = sqrt(pow(posDist, 2) / (1 + pow(slope, 2)));
         float posY = slope * posX;
         CGPoint endpt;
         if (slope > 0){
            endpt = ccpSub(player.position, ccp(posX, posY));
         }
         else if (slope < 0){
            endpt = ccpAdd(player.position, ccp(posX, posY));
         }
         NSMutableArray *bezierArray1 = [NSMutableArray array];
         // Add Beziers
         // Bezier 0
         ccBezierConfig bzConfig_0;
         
         bzConfig_0.controlPoint_1 = player.position;
         bzConfig_0.controlPoint_2 = endpt;
         bzConfig_0.endPosition = endpt;
         CCBezierTo *bezierTo_0 = [CCBezierTo actionWithDuration:.75f bezier:bzConfig_0];
         [bezierArray1 addObject:bezierTo_0];
         
         // create actionsequence and run action
         CCSequence *bezierSeq = [CCSequence actionWithArray:bezierArray1];
         [self runAction: [CCSequence actions:bezierSeq, nil]];

         followPlayers = YES;
      }
   }
   return self;
}
 
@end
