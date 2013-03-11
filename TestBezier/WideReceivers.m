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
@synthesize playerBottomtoTop, playerLefttoRight, playerMoving, playerSlope, holdPoint, playerStartPos, playerMovementArray, playerBeziers;

-(id) initWithFile:(NSString *)filename {
	if ((self = [super initWithFile:filename])) {
      self.playerMovementArray = [[NSMutableArray alloc] init];
      self.playerBeziers = [[NSMutableArray alloc] init];
      
      self.playerStartPos = self.position;
      [self schedule:@selector(move:)];
      
   }
   return self;
}
-(void) move:(ccTime)dt{
   [self.playerMovementArray addObject:[NSValue valueWithCGPoint:self.position]];
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
-(void) callBack:(id)sender{
   [Singleton sharedSingleron].playersHaveReturned = YES;
}
-(void) removeArray:(id)sender{
   [self.playerMovementArray removeAllObjects];
   [self.playerBeziers removeAllObjects];
}
-(id) movePlayerBack{
   [self stopAllActions];
   
   CGPoint p1 = [[self.playerMovementArray objectAtIndex:[self.playerMovementArray count]-6] CGPointValue];
   CGPoint p2 = [[self.playerMovementArray objectAtIndex:[self.playerMovementArray count]-1] CGPointValue];
   
   float playerMovementSlope = (p2.y - p1.y) / (p2.x - p1.x);
   float adjDist = 180;
   float posX = sqrt(pow(adjDist, 2) / (1 + pow(playerMovementSlope, 2)));
   //calculate y coordinate of control point
   float posY = playerMovementSlope * posX;
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
      if (playerMovementSlope > 0){
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
      else if (playerMovementSlope < 0){
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
      else if (playerMovementSlope == 0){
         //moving left to right
         if (p2.x > p1.x){
            posX = 180;
            posY = 0;
            playerControl = ccpAdd(p2, ccp(posX, posY));

         }
         //moving right to left
         else if (p2.x < p1.x){
            posX = -180;
            posY = 0;
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
   bzConfig_0.controlPoint_2 = self.playerStartPos;
   bzConfig_0.endPosition = self.playerStartPos;
   CCBezierTo *bezierTo_0 = [CCBezierTo actionWithDuration:3.5f bezier:bzConfig_0];
   [bezierArray1 addObject:bezierTo_0];
   // create actionsequence and run action
   CCSequence *bezierSeq = [CCSequence actionWithArray:bezierArray1];
   
   [self runAction: [CCSequence actions:bezierSeq, nil]];
   [self performSelector:@selector(removeArray:) withObject:nil afterDelay:3.5f];
   
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
   //applies the play selected to the wide recievers route
   self.playerMoving = YES;
   id callback = [CCCallFunc actionWithTarget:self selector:@selector(streakFinished:)];
   
   NSMutableArray *playArray = [[NSMutableArray alloc] init];
   for (int i = 1; i < [playBook count]; i++){
      CGPoint cp0;
      CGPoint cp2;
      CGPoint cp2Copy;
      if (i <= [playBook count]-2){
         CGPoint point1 = [[playBook objectAtIndex:i] CGPointValue];
         
         //create bezier between points
         float adjDist = 30;
         CGPoint point0 = [[playBook objectAtIndex:i-1] CGPointValue];
         //first control point
         float slope0 = (point1.y - point0.y) / (point1.x - point0.x);
         
         float cp0X = sqrt((pow(adjDist, 2)) / (1 + pow(slope0, 2)));
         float cp0Y = slope0 * cp0X;
         bool infSlope1 = NO;
         
         
         //check if infinity slope
         if (point0.x  == point1.x){
            NSLog(@"inf slope");
            infSlope1 = YES;
            //moving bottom to top
            if (point0.y < point1.y){
               cp0X = 0;
               cp0Y = adjDist;
               cp0 = ccpAdd(point1, ccp(cp0X, -cp0Y));
               
            }
            //moving top to bottom
            else if (point0.y > point1.y){
               cp0X = 0;
               cp0Y = adjDist;
               cp0 = ccpAdd(point1, ccp(cp0X, cp0Y));
               
            }
            
         }
         //if the slope is not infinite
         if (!infSlope1){
            if (slope0 < 0){
               //negative slope moving bottom to top
               if (point0.y < point1.y){
                  cp0 = ccpAdd(point1, ccp(cp0X, cp0Y));
               }
               //negative slope moving top to bottom
               else if (point0.y > point1.y){
                  cp0 = ccpAdd(point1, ccp(-cp0X, -cp0Y));
                  
               }
            }
            else if (slope0 > 0){
               //negative slope moving bottom to top
               if (point0.y < point1.y){
                  cp0 = ccpAdd(point1, ccp(-cp0X, -cp0Y));
                  
               }
               //negative slope moving top to bottom
               else if (point0.y > point1.y){
                  cp0 = ccpAdd(point1, ccp(cp0X, cp0Y));
                  
               }
            }
            //slope of 0
            else if (slope0 == 0){
               NSLog(@"slope zerooo");
               //moving left to right
               if (point0.x < point1.x){
                  cp0X = -adjDist;
                  cp0Y = 0;
               }
               else if (point0.x > point1.x){
                  cp0X = adjDist;
                  cp0Y = 0;
               }

               cp0 = ccpAdd(point1, ccp(cp0X, cp0Y));

            }
         }
         

         
         CGPoint point2 = [[playBook objectAtIndex:i+1] CGPointValue];
         
         float slope2 = (point2.y - point1.y) / (point2.x - point1.x);
         float cp2X = sqrt((pow(adjDist, 2)) / (1 + pow(slope2, 2)));
         float cp2Y = slope2 * cp2X;
         
         bool infSlope2 = NO;

         //check if infinity slope
         if (point2.x  == point1.x){
            infSlope2 = YES;
            //moving bottom to top
            if (point2.y < point1.y){
               cp2X = 0;
               cp2Y = -adjDist;
            }
            //moving top to bottom
            else if (point2.y > point1.y){
               cp2X = 0;
               cp2Y = adjDist;
            }
            cp2 = ccpAdd(point1, ccp(cp2X, cp2Y));
         }
     
         
         //control point 2
         //if slope is negative
         if (slope2 < 0){
            //negative slop moving top to bottom
            if (point2.y < point1.y){
               cp2 = ccpAdd(point1, ccp(cp2X, cp2Y));
               
            }
            //negative slop moving bottom to top
            else if (point2.y > point1.y){
               cp2 = ccpAdd(point1, ccp(-cp2X, -cp2Y));
            }
         }
         //if slope is positive
         else if (slope2 > 0){
            //positive slop moving top to bottom
            if (point2.y < point1.y){
               cp2 = ccpAdd(point1, ccp(-cp2X, -cp2Y));
               
            }
            //positive slop moving bottom to top
            else if (point2.y > point1.y){
               cp2 = ccpAdd(point1, ccp(cp2X, cp2Y));
               
            }
         }
         else if (slope2 == 0){
            NSLog(@"slope zero");
            //moving left to right
            if (point1.x < point2.x){
               cp2X = adjDist;
               cp2Y = 0;
            }
            else if (point1.x > point2.x){
               cp2X = -adjDist;
               cp2Y = 0;
            }
            cp2 = ccpAdd(point1, ccp(cp2X, cp2Y));
         }
         
         if ( i == 1){
            //move player to first control point
            float pointDist = ccpDistance([[playBook objectAtIndex:i-1] CGPointValue], cp0);
            
            NSLog(@"p1: %@ p2: %@, dist: %f", NSStringFromCGPoint([[playBook objectAtIndex:i-1] CGPointValue]), NSStringFromCGPoint(cp0), pointDist);
            float time = pointDist/480*5;
            CCAction *moveTo = [CCMoveTo actionWithDuration:time position:cp0];
            [playArray addObject:moveTo];
         }
         else if (i > 1){
            //move player to first control point
            float pointDist = ccpDistance(cp2Copy, cp0);
            float time = pointDist/480*5;
            NSLog(@"not 1 p1: %@ p2: %@, dist: %f", NSStringFromCGPoint(cp2Copy), NSStringFromCGPoint(cp0), pointDist);

            CCAction *moveTo = [CCMoveTo actionWithDuration:time position:cp0];
            [playArray addObject:moveTo];
         }
         cp2Copy = cp2;
         NSMutableArray *bezierArray = [NSMutableArray array];
         // Add Beziers
         // Bezier 0
         
         [self.playerBeziers addObject:[NSValue valueWithCGPoint:cp0]];
         [self.playerBeziers addObject:[NSValue valueWithCGPoint:point1]];
         [self.playerBeziers addObject:[NSValue valueWithCGPoint:cp2]];

         ccBezierConfig bzConfig_0;
         bzConfig_0.controlPoint_1 = cp0;
         bzConfig_0.controlPoint_2 = point1;
         bzConfig_0.endPosition = cp2;
         
         CCBezierTo *bezierTo_0;
         float bezDist = [self findDistance];
         float bezTime = bezDist/480 * 5;

         bezierTo_0 = [CCBezierTo actionWithDuration:bezTime bezier:bzConfig_0];
         [bezierArray addObject:bezierTo_0];
         // create actionsequence and run action
         //CCSequence *bezierSeq = [CCSequence actionWithArray:bezierArray];
         [playArray addObject:bezierTo_0];
      }
      
      else if (i == [playBook count]-1){
         float pointDist = ccpDistance(cp2, [[playBook objectAtIndex:i] CGPointValue]);
         float time = pointDist/480*5;
         CCAction *moveTo = [CCMoveTo actionWithDuration:time position:[[playBook objectAtIndex:i] CGPointValue]];
         [playArray addObject:moveTo];
      }
   }
   
   for (int i = 0; i < [playArray count]; i ++){
      if ([[playArray objectAtIndex:i] isKindOfClass:[CCBezierTo class]]){
         //[playArray replaceObjectAtIndex:i withObject:[CCEaseSineOut actionWithAction:(CCBezierTo*)[playArray objectAtIndex:i]]];
         NSLog(@"plays: %@", [playArray objectAtIndex:i]);
      }
   }
   [playArray addObject:callback];
   [self runAction:[CCSequence actionWithArray:playArray]];
   

   return self;
}


// Bezier cubic formula:
//	((1 - t) + t)3 = 1
// Expands to…
//   (1 - t)3 + 3t(1-t)2 + 3t2(1 - t) + t3 = 1
static inline CGFloat bezierat( float a, float b, float c, float d, ccTime t )
{
	return (powf(1-t,3) * a + 3*t*(powf(1-t,2))*b + 3*powf(t,2)*(1-t)*c +powf(t,3)*d );
}
-(float) findDistance{
   CGFloat xa = 0;
   CGFloat xb = [[self.playerBeziers objectAtIndex:0] CGPointValue].x;
   CGFloat xc = [[self.playerBeziers objectAtIndex:1] CGPointValue].x;
   CGFloat xd = [[self.playerBeziers objectAtIndex:2] CGPointValue].x;
   
   CGFloat ya = 0;
   CGFloat yb = [[self.playerBeziers objectAtIndex:0] CGPointValue].y;
   CGFloat yc = [[self.playerBeziers objectAtIndex:1] CGPointValue].y;
   CGFloat yd = [[self.playerBeziers objectAtIndex:2] CGPointValue].y;
   NSMutableArray *bezierPath = [[NSMutableArray alloc] init];
   for (float t = .5; t <= 1; t+= .001){
      CGFloat x = bezierat(xa, xb, xc, xd, t);
      CGFloat y = bezierat(ya, yb, yc, yd, t);
      
      //NSLog(@"new points for loop: (%@)", NSStringFromCGPoint(ccp(x, y)));
      //NSLog(@"floats: %f, %f", x, y);
      [bezierPath addObject:[NSValue valueWithCGPoint:ccp(x, y)]];
      
   }
   
   float runningDist = 0;
   if ([bezierPath count] > 2){
      for (int i = 1; i < [bezierPath count]-1; i++){
         CGPoint p1 = [[bezierPath objectAtIndex:i-1] CGPointValue];
         CGPoint p2 = [[bezierPath objectAtIndex:i] CGPointValue];
         float instantaneousDist = ccpDistance(p1, p2);
         runningDist += instantaneousDist;
      }
   }
   
   //[self.playerBeziers removeAllObjects];
   return runningDist;
}
@end
