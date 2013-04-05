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
@synthesize playerBottomtoTop, playerLefttoRight, playerMoving, playerSlope, holdPoint, playerStartPos, playerMovementArray, playerBeziers, dataDict, velo, xDt, xConst, yDt, yConst, functionIndex, theta, deltaT, pointCount, stopParametric;

-(id) initWithFile:(NSString *)filename {
	if ((self = [super initWithFile:filename])) {
      self.playerMovementArray = [[NSMutableArray alloc] init];
      self.playerBeziers = [[NSMutableArray alloc] init];
      self.dataDict = [[NSMutableDictionary alloc] init];
      self.stopParametric = NO;
      
      self.velo = 150;
      
      self.playerStartPos = self.position;
      
   }
   return self;
}
-(void) tick:(ccTime)dt{
   [self.playerMovementArray addObject:[NSValue valueWithCGPoint:self.position]];
   
   if ([Singleton sharedSingleron].runParametric){
      if (!self.stopParametric){
         self.deltaT += dt;
         
         if ([[self.dataDict objectForKey:[NSString stringWithFormat:@"Time%i", self.functionIndex]] floatValue] >= self.deltaT){
            //if even, run on slope
            if (self.functionIndex%2 == 0){
               if (self.deltaT <= dt*1.5){
                  self.xDt = [[self.dataDict objectForKey:[NSString stringWithFormat:@"LinearVeloX%i", self.functionIndex]] floatValue];
                  self.xConst = [[self.dataDict objectForKey:[NSString stringWithFormat:@"LinearVeloXConstant%i", self.functionIndex]] floatValue];
                  self.yDt = [[self.dataDict objectForKey:[NSString stringWithFormat:@"LinearVeloY%i", self.functionIndex]] floatValue];
                  self.yConst = [[self.dataDict objectForKey:[NSString stringWithFormat:@"LinearVeloYConstant%i", self.functionIndex]] floatValue];
               }
               self.position = ccp(velo * self.deltaT * self.xDt + self.xConst, self.velo * self.deltaT * self.yDt + self.yConst);
               [ballStreak setPosition:[self position]];
            }
            //otherwise, run in a  circle
            else{
               //linear velo / radius
               //60 / 100
               float startTheta = [[self.dataDict objectForKey:[NSString stringWithFormat:@"CircularThetaStart%i", self.functionIndex]] floatValue];
               float endTheta = [[self.dataDict objectForKey:[NSString stringWithFormat:@"CircularThetaEnd%i", self.functionIndex]] floatValue];
               float rad = [[self.dataDict objectForKey:[NSString stringWithFormat:@"CircularRadius%i", self.functionIndex]] floatValue];
               int rotFix = [[self.dataDict objectForKey:[NSString stringWithFormat:@"CircularRotationFix%i", self.functionIndex]] integerValue];
               CGPoint center = [[self.dataDict objectForKey:[NSString stringWithFormat:@"CircularCenter%i", self.functionIndex]] CGPointValue];
               
               float angVelBuffer = self.velo/rad;
               
               int rotation;
               if (startTheta > endTheta){
                  //clockwise
                  rotation = -1;
               }
               else if (startTheta < endTheta){
                  //counter clockwise
                  rotation = 1;
               }
               
               rotation *= rotFix;
               
               if (rotFix == -1){
                  endTheta = endTheta;
               }
               
               self.position = ccp(rad*cos(rotation * self.deltaT *angVelBuffer + startTheta) + center.x, rad*sin(rotation * self.deltaT *angVelBuffer + startTheta) + center.y);
               [ballStreak setPosition:[self position]];
            }
         }
         else {
            self.functionIndex++;
            
            if (self.functionIndex >= (self.pointCount*2)-3){
               //[self unschedule:@selector(tick:)];
               self.stopParametric = YES;
               id callback = [CCCallFunc actionWithTarget:self selector:@selector(streakFinished:)];
               [self runAction:[CCSequence actions:callback, nil]];
            }
            self.deltaT = 0;
         }
      }
   }
}
-(id) setStartingPosition:(CGPoint) startPos{
   self.position = startPos;
   self.playerStartPos = startPos;
   
   return self;
}
-(void) resetTicker:(id) sender{
   [self unschedule:@selector(tick:)];
}
-(id) setHoldPosition:(CGPoint) holder{
   self.holdPoint = holder;
   [self performSelector:@selector(resetTicker:) withObject:nil afterDelay:3.0f];
   return self;
}
-(void) callBack:(id)sender{
   [Singleton sharedSingleron].playersHaveReturned = YES;
}
-(void) removeArray:(id)sender{
   [self setTexture:[[CCTextureCache sharedTextureCache] addImage:@"Player2.png"]];
   [self.playerMovementArray removeAllObjects];
   [self.playerBeziers removeAllObjects];
   self.deltaT = 0;
}
-(id) movePlayerBack{
   [self stopAllActions];
   
   CGPoint p1 = [[self.playerMovementArray objectAtIndex:[self.playerMovementArray count]-6] CGPointValue];
   CGPoint p2 = [[self.playerMovementArray objectAtIndex:[self.playerMovementArray count]-1] CGPointValue];
   
   if (p1.x != p2.x && p1.y != p2.y){
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
      
      float bezDist = (ccpDistance(self.position, playerControl) + ccpDistance(playerControl, self.playerStartPos))*.75;
      float bezVelo = bezDist/self.velo;
      
      CCBezierTo *bezierTo_0 = [CCBezierTo actionWithDuration:bezVelo bezier:bzConfig_0];
      [bezierArray1 addObject:bezierTo_0];
      // create actionsequence and run action
      CCSequence *bezierSeq = [CCSequence actionWithArray:bezierArray1];
      
      [self runAction: [CCSequence actions:bezierSeq, nil]];
   }
   else{
      float moveTime = ccpDistance(self.position, self.playerStartPos)/self.velo;
      CCMoveTo *moveTo = [CCMoveTo actionWithDuration:moveTime position:self.playerStartPos];
      [self runAction: [CCSequence actions:moveTo, nil]];
   }
   [self performSelector:@selector(removeArray:) withObject:nil afterDelay:3.5f];
   
   return self;
}
-(void) playerMoving:(id)sender{
   self.playerMoving = YES;
}
-(void)streakFinished:(id)sender{
   NSLog(@"its called");
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
   float time = newDist/self.velo;
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
   self.pointCount = [playBook count];
   
   [self runParameticPath: playBook];
   [self schedule:@selector(tick:)];
   self.stopParametric = NO;
   [Singleton sharedSingleron].runParametric = YES;
   return self;
}
-(void)runParameticPath:(NSMutableArray*)pointArray{
   self.deltaT = 0;
   
   for (int i = 0; i < [pointArray count]-2; i++){
      CGPoint p1 = [[pointArray objectAtIndex:i] CGPointValue];
      CGPoint p2 = [[pointArray objectAtIndex:i+1] CGPointValue];
      CGPoint p3 = [[pointArray objectAtIndex:i+2] CGPointValue];
      
      if (i > 0) {
         p1 = [[self.dataDict objectForKey:[NSString stringWithFormat:@"Tan2-%i", i-1]] CGPointValue];
      }
      //find point on line x dist away from point 2
      CGPoint p1sec = [self getSec:p2 and:p1 withAdjustDist: 60];
      CGPoint p2sec = [self getSec:p2 and:p3 withAdjustDist: 60];
      
      
      //centerpoint of circle
      CGPoint centerPt = ccp((p1sec.x + p2sec.x) / 2, (p1sec.y + p2sec.y) / 2);
      
      //point tangent to path
      CGPoint tan1 = [self getTan:p1 and:p2 withCenterPoint:centerPt];
      CGPoint tan2 = [self getTan:p2 and:p3 withCenterPoint:centerPt];
      
      [self.dataDict setObject:[NSValue valueWithCGPoint:tan1] forKey:[NSString stringWithFormat:@"Tan1-%i", (i)]];
      [self.dataDict setObject:[NSValue valueWithCGPoint:tan2] forKey:[NSString stringWithFormat:@"Tan2-%i", (i)]];
      
      
      //find create paths and times
      float dist1 = ccpDistance(p1, tan1);
      float time1 = dist1 / self.velo;
      float distX = abs(tan1.x - p1.x);
      float distY = abs(tan1.y - p1.y);
      //x velocity
      float veloX = (distX/time1)/self.velo;
      float veloY = (distY/time1)/self.velo;
      
      float slopeTan1P1 = [self getSlope:tan1 and:p1];
      if (slopeTan1P1 < 0){
         if (tan1.x < p1.x){
            if (tan1.y > p1.y){
               veloX = -veloX;
               veloY = veloY;
            }
            else if (tan1.y < p1.y){
               veloX = -veloX;
               veloY = -veloY;
            }
         }
         else if (tan1.x > p1.x){
            veloX = veloX;
            veloY = -veloY;
         }
      }
      else if (slopeTan1P1 > 0){
         if (tan1.x < p1.x){
            if (tan1.y > p1.y){
               veloX = veloX;
               veloY = veloY;
            }
            else if (tan1.y < p1.y){
               veloX = -veloX;
               veloY = -veloY;
            }
         }
         else if (tan1.x > p1.x){
            if (tan1.y > p1.y){
               veloX = veloX;
               veloY = veloY;
            }
            else if (tan1.y < p1.y){
               veloX = -veloX;
               veloY = -veloY;
            }
         }
      }
      else if (slopeTan1P1 == 0){
         if (tan1.x < p1.x){
            veloX = -veloX;
            veloY = 0;
         }
         else if (tan1.x > p1.x){
            veloX = veloX;
            veloY = 0;
         }
      }
      
      if ([[NSString stringWithFormat:@"%f", [self getSlope:tan1 and:p1]] isEqual:[NSString stringWithFormat:@"inf"]] || [[NSString stringWithFormat:@"%f", [self getSlope:tan1 and:p1]] isEqual:[NSString stringWithFormat:@"-inf"]]){
         if (tan1.y < p1.y){
            veloX = 0;
            veloY = -(dist1/time1)/self.velo;
         }
         else if (tan1.y > p1.y){
            veloX = 0;
            veloY = (dist1/time1)/self.velo;
         }
      }
      
      [self.dataDict setObject:[NSNumber numberWithFloat:veloX] forKey:[NSString stringWithFormat:@"LinearVeloX%i", i*2]];
      [self.dataDict setObject:[NSNumber numberWithFloat:p1.x] forKey:[NSString stringWithFormat:@"LinearVeloXConstant%i", i*2]];
      [self.dataDict setObject:[NSNumber numberWithFloat:veloY] forKey:[NSString stringWithFormat:@"LinearVeloY%i", i*2]];
      [self.dataDict setObject:[NSNumber numberWithFloat:p1.y] forKey:[NSString stringWithFormat:@"LinearVeloYConstant%i", i*2]];
      
      if (i == [pointArray count]-3){
         float dist2 = ccpDistance(tan2, p3);
         float time3 = dist2 / self.velo;
         float distX2 = abs(tan2.x - p3.x);
         float distY2 = abs(tan2.y - p3.y);
         float veloX2 = (distX2/time3)/self.velo;
         float veloY2 = (distY2/time3)/self.velo;
         if ([self getSlope:tan2 and:p3] < 0){
            if (tan2.x < p3.x){
               veloX2 = veloX2;
               veloY2 = -veloY2;
            }
            else if (tan2.x > p3.x){
               veloX2 = -veloX2;
               veloY2 = veloY2;
            }
         }
         else if ([self getSlope:tan2 and:p3] > 0){
            if (tan2.x < p3.x){
               veloX2 = veloX2;
               veloY2 = veloY2;
            }
            else if (tan2.x > p3.x){
               veloX2 = -veloX2;
               veloY2 = -veloY2;
            }
         }
         else if ([self getSlope:tan2 and:p3] == 0){
            if (tan2.x < p3.x){
               veloX2 = veloX2;
               veloY2 = 0;
            }
            else if (tan2.x > p3.x){
               veloX2 = -veloX2;
               veloY2 = 0;
            }
         }
         
         if ([[NSString stringWithFormat:@"%f", [self getSlope:tan2 and:p3]] isEqual:[NSString stringWithFormat:@"inf"]] ||[[NSString stringWithFormat:@"%f", [self getSlope:tan2 and:p3]] isEqual:[NSString stringWithFormat:@"-inf"]]){
            
            if (tan2.y < p3.y){
               veloX2 = 0;
               veloY2 = (dist2/time3)/self.velo;
            }
            else if (tan2.y > p3.y){
               veloX2 = 0;
               veloY2 = -(dist2/time3)/self.velo;
            }
         }
         
         [self.dataDict setObject:[NSNumber numberWithFloat:veloX2] forKey:[NSString stringWithFormat:@"LinearVeloX%i", (i+1)*2]];
         [self.dataDict setObject:[NSNumber numberWithFloat:tan2.x] forKey:[NSString stringWithFormat:@"LinearVeloXConstant%i", (i+1)*2]];
         [self.dataDict setObject:[NSNumber numberWithFloat:veloY2] forKey:[NSString stringWithFormat:@"LinearVeloY%i", (i+1)*2]];
         [self.dataDict setObject:[NSNumber numberWithFloat:tan2.y] forKey:[NSString stringWithFormat:@"LinearVeloYConstant%i", (i+1)*2]];
         [self.dataDict setObject:[NSNumber numberWithFloat:time3] forKey:[NSString stringWithFormat:@"Time%i", (i+1)*2]];
      }
      self.functionIndex = 0;
      
      //run aruound the circle
      float radius = ccpDistance(centerPt, tan1);
      
      float thetaStart = acos((abs(centerPt.x - tan1.x))/radius);
      float thetaEnd = acos((abs(centerPt.x - tan2.x))/radius);
      
      if (abs(centerPt.x - tan1.x) == abs(centerPt.x - tan2.x)){
         thetaStart = asin((abs(centerPt.y - tan1.y))/radius);
         thetaEnd = asin((abs(centerPt.y - tan2.y))/radius);
      }
      
      if (centerPt.x > tan1.x){
         if (centerPt.y > tan1.y){
            thetaStart = M_PI + thetaStart;
         }
         else if (centerPt.y < tan1.y){
            thetaStart = M_PI - thetaStart;
         }
         else if (centerPt.y == tan1.y){
            thetaStart = M_PI;
         }
      }
      else if (centerPt.x < tan1.x){
         if (centerPt.y > tan1.y){
            thetaStart = -thetaStart;
         }
         else if (centerPt.y < tan1.y){
            thetaStart = thetaStart;
         }
         else if (centerPt.y == tan1.y){
            thetaStart = 0;
         }
      }
      else if (centerPt.x == tan1.x){
         if (centerPt.y > tan1.y){
            thetaStart = -thetaStart;
         }
         else if (centerPt.y < tan1.y){
            thetaStart = thetaStart;
         }
         else if (centerPt.y == tan1.y){
            thetaStart = 0;
         }
      }
      
      
      if (centerPt.x > tan2.x){
         if (centerPt.y > tan2.y){
            thetaEnd = M_PI + thetaEnd;
         }
         else if (centerPt.y < tan2.y){
            thetaEnd = M_PI - thetaEnd;
         }
         else if (centerPt.y == tan2.y){
            thetaEnd = M_PI;
            
         }
      }
      else if (centerPt.x < tan2.x){
         if (centerPt.y > tan2.y){
            thetaEnd = -thetaEnd;
         }
         else if (centerPt.y < tan2.y){
            thetaEnd = thetaEnd;
         }
         else if (centerPt.y == tan2.y){
            thetaEnd = 0;
         }
      }
      else if (centerPt.x == tan2.x){
         if (centerPt.y > tan2.y){
            thetaEnd = -thetaEnd;
         }
         else if (centerPt.y < tan2.y){
            thetaEnd = thetaEnd;
         }
         else if (centerPt.y == tan2.y){
            thetaEnd = 0;
         }
      }
      
      float thetaBoth = (thetaStart - thetaEnd);
      float arcLength = abs(thetaBoth * (2*M_PI*radius) / (2*M_PI));
      float circumference = 2*M_PI*radius;
      
      int rotationFix;
      //wrong way
      if (arcLength > circumference/2){
         rotationFix = -1;
         arcLength = circumference - arcLength;
      }
      else if (arcLength < circumference/2){
         rotationFix = 1;
      }
      
      //if thethaboth is basically 180, then change rotation adj
      if ((thetaBoth*180/M_PI) + .02 >= 180 && (thetaBoth*180/M_PI) - .02 <= 180){
         rotationFix *= -1;
      }
      
      [self.dataDict setObject:[NSNumber numberWithFloat:thetaStart] forKey:[NSString stringWithFormat:@"CircularThetaStart%i", (i*2)+1]];
      [self.dataDict setObject:[NSNumber numberWithFloat:thetaEnd] forKey:[NSString stringWithFormat:@"CircularThetaEnd%i", (i*2)+1]];
      [self.dataDict setObject:[NSNumber numberWithFloat:radius] forKey:[NSString stringWithFormat:@"CircularRadius%i", (i*2)+1]];
      [self.dataDict setObject:[NSNumber numberWithFloat:rotationFix] forKey:[NSString stringWithFormat:@"CircularRotationFix%i", (i*2)+1]];
      [self.dataDict setObject:[NSValue valueWithCGPoint:centerPt] forKey:[NSString stringWithFormat:@"CircularCenter%i", (i*2)+1]];
      
      float time2 = arcLength/self.velo;
      
      [self.dataDict setObject:[NSNumber numberWithFloat:time1] forKey:[NSString stringWithFormat:@"Time%i", i*2]];
      [self.dataDict setObject:[NSNumber numberWithFloat:time2] forKey:[NSString stringWithFormat:@"Time%i", i*2 + 1]];
   }
}
-(CGPoint) getTan:(CGPoint) p1 and: (CGPoint) p2 withCenterPoint: (CGPoint) centerPt{
   CGPoint returnPt;
   float slope = [self getSlope:p1 and:p2];
   float posX = ((centerPt.x / slope) + centerPt.y + (slope * p1.x) - p1.y) / (slope + (1/slope));
   float posY = (-1/slope) * (posX - centerPt.x) + centerPt.y;
   
   if (slope == 0){
      if (p1.x < p2.x){
         posX = centerPt.x;
         posY = centerPt.y - (centerPt.y - p2.y);
      }
      else if (p1.x > p2.x){
         posX = centerPt.x;
         posY = centerPt.y - (centerPt.y - p2.y);
      }
   }
   else if (slope+20 == slope){
      if (p1.x > centerPt.x){
         posX = centerPt.x + abs(p1.x - centerPt.x);
         posY = centerPt.y;
      }
      else if (p1.x < centerPt.x){
         posX = centerPt.x - abs(p1.x - centerPt.x);
         posY = centerPt.y;
         
      }
   }
   returnPt = ccp(posX, posY);
   return returnPt;
}
//p1 is always the point to add/sub to get sec points
-(CGPoint) getSec:(CGPoint) p1 and: (CGPoint) p2 withAdjustDist:(int) theDist{
   CGPoint returnPt;
   
   float distA = ccpDistance(p1, p2);
   float distB = ccpDistance(p1, ccp(p2.x, p1.y));
   float thetaa = acos(distB / distA);
   
   float slope = [self getSlope:p1 and:p2];
   
   bool infSlope = NO;
   if (slope == slope + 20){
      infSlope = YES;
   }
   int adjDist = theDist;
   if (!infSlope){
      if (p1.x < p2.x){
         if (slope < 0){
            returnPt = ccpAdd(p1, ccp(adjDist * cos(thetaa), -1*adjDist * sin(thetaa)));
         }
         else if (slope > 0){
            returnPt = ccpAdd(p1, ccp(adjDist * cos(thetaa), adjDist * sin(thetaa)));
            
         }
      }
      else if (p1.x > p2.x){
         if (slope < 0){
            returnPt = ccpSub(p1, ccp(adjDist * cos(thetaa), -1*adjDist * sin(thetaa)));
         }
         else if (slope > 0){
            returnPt = ccpSub(p1, ccp(adjDist * cos(thetaa), adjDist * sin(thetaa)));
         }
      }
      if (slope == 0){
         if (p1.x > p2.x){
            returnPt = ccpAdd(p1, ccp(-adjDist, 0));
         }
         else if (p1.x < p2.x){
            returnPt = ccpAdd(p1, ccp(adjDist, 0));
         }
      }
   }
   else if (infSlope){
      if (p1.y > p2.y){
         returnPt = ccpAdd(p1, ccp(0, -adjDist));
      }
      else if (p1.y < p2.y){
         returnPt = ccpAdd(p1, ccp(0, adjDist));
      }
      else if (slope == 0){
         if (p1.y == p2.y){
            returnPt = ccpAdd(p1, ccp(-adjDist, 0));
         }
         else if (p1.x < p2.x){
            returnPt = ccpAdd(p1, ccp(adjDist, 0));
         }
      }
   }
   return returnPt;
}
-(float) getSlope: (CGPoint) p1 and:(CGPoint) p2{
   float slope = (p2.y - p1.y) / (p2.x - p1.x);
   return slope;
}
@end
