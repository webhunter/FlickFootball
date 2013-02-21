//
//  HelloWorldLayer.m
//  TestBezier
//
//  Created by KirbyGee on 1/23/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}
// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
      self.isTouchEnabled = YES;
      
      ballArray = [[NSMutableArray alloc] init];
      removeArray = [[NSMutableArray alloc] init];
      playerArray = [[NSMutableArray alloc] init];
      streakArray = [[NSMutableArray alloc] init];
      fieldTileArray = [[NSMutableArray alloc] init];
      startingPos = [[NSMutableArray alloc] init];
      
      bezierArray = [[NSMutableArray alloc] init];
      pointArray = [[NSMutableArray alloc] init];
      
      
      player1Book = [[NSMutableArray alloc] init];
      player2Book = [[NSMutableArray alloc] init];
      
      
      player1Movements = [[NSMutableArray alloc] init];
      player2Movements = [[NSMutableArray alloc] init];
      
      
      CCSprite *bg = [CCSprite spriteWithFile:@"FbField.png"];
      bg.position = ccp(160, 240);
      //[self addChild:bg z:-500];
      
      
      fieldTileLayer = [CCLayer node];
      [self addChild:fieldTileLayer z:-50];
      
      ballLayer = [CCLayer node];
      [self addChild:ballLayer z:1];
      
      playerLayer = [CCLayer node];
      [self addChild:playerLayer z:1];
      
      
      NSString *tileName;
      //place tiles on screen
      for (int i = 0; i < 14; i ++){
         int randInt = arc4random()%4 + 1;
         
         //if even
         if (i%2 == 0){
            tileName = [NSString stringWithFormat:@"Green1%i.png", randInt];
         }
         //else odd
         else{
            tileName = [NSString stringWithFormat:@"Green2%i.png", randInt];
            
         }
         NSLog(@"Tile names: %@", tileName);
         
         CCSprite *tile = [CCSprite spriteWithFile:tileName];
         tile.position = ccp(160, 22 + 44*i);
         tile.tag = 100 + i;
         [fieldTileLayer addChild:tile z:0];
         [fieldTileArray addObject:tile];
      }
      
      [self readPlaybookWithPlay:1];
      player1startPos = [[player1Book objectAtIndex:0] CGPointValue];
      
      qb = [CCSprite spriteWithFile:@"Player2.png"];
      qb.position = ccp(160, 20);
      [self addChild:qb z:50];
      
      player1 = [CCSprite spriteWithFile:@"Player2.png"];
      player1.position = player1startPos;
      player1.tag = 1;
      [playerLayer addChild:player1];
      [playerArray addObject:player1];
      
      NSLog(@"Player 1 starting pos: %@, %@", NSStringFromCGPoint(player1.position), NSStringFromCGPoint(player1startPos));
      player2 = [CCSprite spriteWithFile:@"Player2.png"];
      player2.position = ccp(300, 0);
      player2.tag = 2;
      [playerLayer addChild:player2];
      [playerArray addObject:player2];
      
      player2startPos = ccp(300, 0);
      
      [startingPos addObject:[NSValue valueWithCGPoint:player1startPos]];
      [startingPos addObject:[NSValue valueWithCGPoint:player2startPos]];
      
      
      
      
      swipeStarted = NO;
      pastDistance = NO;
      touchStartedAtPlayer = NO;
      timeSwiped = 0;
      player1BottomtoTop = YES;
      player2BottomtoTop = YES;
      
      player1Moving = YES;
      player2Moving = YES;
      showRoutes = NO;
      playStarted = NO;
      tan = CGPointMake(160, 240);
      
      for (int i = 0; i < [playerArray count]; i ++){
         CCSprite *player = (CCSprite*)[playerArray objectAtIndex:i];
         CCMotionStreak *playerStreak = [CCMotionStreak streakWithFade:0.8 minSeg:1 width:16 color:ccWHITE textureFilename:@"Streak.png"];
         [playerStreak setPosition:player.position];
         [self addChild:playerStreak z:-1];
         [streakArray addObject:playerStreak];
      }
      
      [self schedule:@selector(tick:)];
      
	}
	return self;
}

#pragma mark Playbook
-(void) readPlaybookWithPlay:(int) playNumber{
   NSBundle *playBundle = [NSBundle mainBundle];
   NSString *playPath = [playBundle pathForResource:@"PlayBook" ofType:@"plist"];
   NSDictionary *playDictionary = [[NSDictionary alloc] initWithContentsOfFile:playPath];
   
   //select the first play
   NSArray *playArray = [[playDictionary allValues] objectAtIndex:playNumber - 1];
   //coordinates for first player
   NSArray *firstPlay = [playArray objectAtIndex:0];
   NSArray *secondPlay = [playArray objectAtIndex:1];
   
   int yCoord;
   int xCoord;
   
   for (int i = 0; i < [firstPlay count]; i ++){
      NSString *rawPlay = [firstPlay objectAtIndex:i];
      xCoord = [[[rawPlay componentsSeparatedByString:@"x"] objectAtIndex:0] integerValue];
      yCoord = [[[rawPlay componentsSeparatedByString:@"x"] objectAtIndex:1] integerValue];
      
      CGPoint point = CGPointMake(xCoord, yCoord);
      [player1Book addObject:[NSValue valueWithCGPoint:point]];
      
   }
   
   for (int i = 0; i < [secondPlay count]; i++){
      NSString *rawPlay = [secondPlay objectAtIndex:i];
      xCoord = [[[rawPlay componentsSeparatedByString:@"x"] objectAtIndex:0] integerValue];
      yCoord = [[[rawPlay componentsSeparatedByString:@"x"] objectAtIndex:1] integerValue];
      
      CGPoint point = CGPointMake(xCoord, yCoord);
      [player2Book addObject:[NSValue valueWithCGPoint:point]];
      
   }
   NSLog(@"Play Array: %@", playArray);
   NSLog(@"First Play: %@", firstPlay);
   NSLog(@"Coordinates1: %@", player1Book);
   NSLog(@"Coordinates2: %@", player2Book);
   
}
-(void) playerStreak1{
   player1Moving = YES;
   id callback = [CCCallFunc actionWithTarget:self selector:@selector(streakFinished1:)];
   
   NSMutableArray *playArray = [[NSMutableArray alloc] init];
   for (int i = 1; i < [player1Book count]; i++){
      CGPoint point = [[player1Book objectAtIndex:i] CGPointValue];
      float pointDist = ccpDistance([[player1Book objectAtIndex:i-1] CGPointValue], point);
      float time = pointDist/480*5;
      
      CCAction *moveTo = [CCMoveTo actionWithDuration:time position:point];
      [playArray addObject:moveTo];
   }
   [playArray addObject:callback];
   [player1 runAction:[CCSequence actionWithArray:playArray]];
   
}
-(void) playerStreak2{
   player2Moving = YES;
   id callback = [CCCallFunc actionWithTarget:self selector:@selector(streakFinished2:)];
   
   [player2 runAction:[CCRotateBy actionWithDuration:2.0f angle:720]];
   NSMutableArray *playArray = [[NSMutableArray alloc] init];
   for (int i = 1; i < [player2Book count]; i++){
      CGPoint point = [[player2Book objectAtIndex:i] CGPointValue];
      float pointDist = ccpDistance([[player2Book objectAtIndex:i-1] CGPointValue], point);
      float time = pointDist/480*5;
      
      CCAction *moveTo = [CCMoveTo actionWithDuration:time position:point];
      [playArray addObject:moveTo];
   }
   [playArray addObject:callback];
   [player2 runAction:[CCSequence actionWithArray:playArray]];
   
}

#pragma mark Randomly move players
-(void) player1Moving:(id)sender{
   player1Moving = YES;
}
-(void)streakFinished1:(id)sender{
   player1Moving = NO;
   //create path to new random point
   int randX = arc4random()%320;
   int randY = arc4random()%300 + 100;
   CGPoint randPoint = CGPointMake(randX, randY);
   
   //make sure the new point is at least 150 pixels away from current position
   while (ccpDistance(player1.position, randPoint) < 150){
      randX = arc4random()%320;
      randY = arc4random()%300 + 100;
      randPoint = CGPointMake(randX, randY);
   }
   player1Slope = (randPoint.y - player1.position.y) / (randPoint.x - player1.position.x);
   
   if (randPoint.y < player1.position.y){
      player1BottomtoTop = NO;
   }
   else if (randPoint.y > player1.position.y){
      player1BottomtoTop = YES;
   }
   
   if (randPoint.x < player1.position.x){
      player1LefttoRight = NO;
   }
   else if (randPoint.x > player1.position.x){
      player1LefttoRight = YES;
   }
   
   newP1 = randPoint;
   newP2 = player1.position;
   
   //calc dist to new point
   float newDist = ccpDistance(player1.position, randPoint);
   //find time to new point
   float time = newDist/480*5;
   id playerMoving = [CCCallFunc actionWithTarget:self selector:@selector(player1Moving:)];
   id callback = [CCCallFunc actionWithTarget:self selector:@selector(streakFinished1:)];
   //minimun delay time is .5 seconds, max is 1.5 seconds
   float delayTime = ((arc4random()%100) + 100) / 100;
   id delay = [CCDelayTime actionWithDuration:delayTime];
   id moveTo = [CCMoveTo actionWithDuration:time position:randPoint];
   [player1 runAction:[CCSequence actions:delay, playerMoving, moveTo, callback, nil]];
   
}
-(void) player2Moving:(id)sender{
   player2Moving = YES;
}
-(void)streakFinished2:(id)sender{
   player2Moving = NO;
   //create path to new random point
   int randX = arc4random()%320;
   int randY = arc4random()%300 + 100;
   CGPoint randPoint = CGPointMake(randX, randY);
   
   //make sure the new point is at least 150 pixels away from current position
   while (ccpDistance(player2.position, randPoint) < 150){
      randX = arc4random()%320;
      randY = arc4random()%300 + 100;
      randPoint = CGPointMake(randX, randY);
   }
   
   player2Slope = (randPoint.y - player2.position.y) / (randPoint.x - player2.position.x);
   
   if (randPoint.y < player2.position.y){
      player2BottomtoTop = NO;
   }
   else if (randPoint.y > player2.position.y){
      player2BottomtoTop = YES;
   }
   
   if (randPoint.x < player2.position.x){
      player2LefttoRight = NO;
   }
   else if (randPoint.x > player2.position.x){
      player2LefttoRight = YES;
   }
   newP12 = randPoint;
   newP22 = player2.position;
   
   //calc dist to new point
   float newDist = ccpDistance(player2.position, randPoint);
   //find time to new point
   float time = newDist/480*5;
   id playerMoving = [CCCallFunc actionWithTarget:self selector:@selector(player2Moving:)];
   id callback = [CCCallFunc actionWithTarget:self selector:@selector(streakFinished2:)];
   //minimun delay time is .5 seconds, max is 1.5 seconds
   float delayTime = ((arc4random()%100) + 100) / 100;
   id delay = [CCDelayTime actionWithDuration:delayTime];
   id moveTo = [CCMoveTo actionWithDuration:time position:randPoint];
   [player2 runAction:[CCSequence actions:delay, playerMoving, moveTo, callback, nil]];
}

#pragma mark Move Players Back
-(void) movePlayer1Back{
   
   [player1 stopAllActions];
   
   
   if (player1Moving){
      NSMutableArray *bezierArray1 = [NSMutableArray array];
      // Add Beziers
      // Bezier 0
      ccBezierConfig bzConfig_0;
      
      //calculate slope from points
      CGPoint lastPoint = player1.position;
      float player1MovementSlope = (player1.position.y - player1Hold.y) / (player1.position.x - player1Hold.x);
      float adjDist;
      
      if (player1.position.y < player1Hold.y){
         player1BottomtoTop = NO;
      }
      else if (player1.position.y > player1Hold.y){
         player1BottomtoTop = YES;
      }
      
      if (player1LefttoRight){
         float distToLeftBound = 320 - player1.position.x;
         adjDist = distToLeftBound;
      }
      else if (!player1LefttoRight){
         float distToRightBound = player1.position.x;
         adjDist = distToRightBound;
      }
      
      BOOL infSlope = NO;
      
      if (player1MovementSlope == player1MovementSlope + 20){
         infSlope = YES;
      }
      
      //slope is not infinity
      if (!infSlope){
         //player making random movements
         //calculate x coordinate of control point
         float posX = sqrt(pow(adjDist, 2) / (1 + pow(player1MovementSlope, 2)));
         //calculate y coordinate of control point
         float posY = player1MovementSlope * posX;
         
         //slope if greater than one
         if (player1MovementSlope >= 0){
            //player move bottom left to top right
            if (player1BottomtoTop){
               player1Control = ccpAdd(lastPoint, ccp(posX, posY));
            }
            //player moving top right to bottom left
            else if (!player1BottomtoTop){
               player1Control = ccpSub(lastPoint, ccp(posX, posY));
            }
         }
         //slope is less than 0
         else if (player1MovementSlope < 0){
            //player move bottom right to top left
            if (player1BottomtoTop){
               player1Control = ccpSub(lastPoint, ccp(posX, posY));
            }
            //player move top left to bottom right
            else if (!player1BottomtoTop){
               player1Control = ccpAdd(lastPoint, ccp(posX, posY));
            }
         }
         //slope is 0
         else if (player1MovementSlope == 0){
            //player moving left to right
            if (player1LefttoRight){
               player1Control = ccpAdd(lastPoint, ccp(adjDist, 0));
            }
            //player moving right to left
            else if (!player1LefttoRight){
               player1Control = ccpSub(lastPoint, ccp(adjDist, 0));
            }
         }
      }
      else{
         if (player1BottomtoTop){
            player1Control = ccpAdd(lastPoint, ccp(0, 200));
         }
         else if (!player1BottomtoTop){
            player1Control = ccpAdd(lastPoint, ccp(0, -200));
         }
      }
      
      p1 = player1Control;
      p2 = player1startPos;
      p3 = player1startPos;
      p4 = player1.position;
      bzConfig_0.controlPoint_1 = player1Control;
      bzConfig_0.controlPoint_2 = player1startPos;
      bzConfig_0.endPosition = player1startPos;
      CCBezierTo *bezierTo_0 = [CCBezierTo actionWithDuration:3.5f bezier:bzConfig_0];
      [bezierArray1 addObject:bezierTo_0];
      
      // create actionsequence and run action
      //id callback = [CCCallFunc actionWithTarget:self selector:@selector(streakFinished1:)];
      
      CCSequence *bezierSeq = [CCSequence actionWithArray:bezierArray1];
      [player1 runAction: [CCSequence actions:bezierSeq, nil]];
   }
   else if (!player1Moving){
      id moveBack = [CCMoveTo actionWithDuration:3.5 position:player1startPos];
      //id callback = [CCCallFunc actionWithTarget:self selector:@selector(streakFinished1:)];
      
      [player1 runAction:[CCSequence actions:moveBack, nil]];
   }
}
-(void) movePlayer2Back{
   
   [player2 stopAllActions];
   
   if (player2Moving){
      NSMutableArray *bezierArray1 = [NSMutableArray array];
      // Add Beziers
      // Bezier 0
      ccBezierConfig bzConfig_0;
      
      //calculate slope from points
      CGPoint lastPoint = player2.position;
      float player2MovementSlope = (player2.position.y - player2Hold.y) / (player2.position.x - player2Hold.x);
      
      if (player2.position.y < player2Hold.y){
         player2BottomtoTop = NO;
      }
      else if (player2.position.y > player2Hold.y){
         player2BottomtoTop = YES;
      }
      
      float adjDist;
      
      if (player2LefttoRight){
         float distToLeftBound = 320 - player2.position.x;
         adjDist = distToLeftBound;
      }
      else if (!player2LefttoRight){
         float distToRightBound = player2.position.x;
         adjDist = distToRightBound;
      }
      
      BOOL infSlope = NO;
      
      if (player2MovementSlope == player2MovementSlope + 20){
         infSlope = YES;
      }
      
      //slope if not infinity
      if (!infSlope){
         
         //calculate x coordinate of control point
         float posX = sqrt(pow(adjDist, 2) / (1 + pow(player2MovementSlope, 2)));
         //calculate y coordinate of control point
         float posY = player2MovementSlope * posX;
         
         //slope is greater than 0
         if (player2MovementSlope > 0){
            //player move bottom left to top right
            if (player2BottomtoTop){
               //moving down left from right
               player2Control = ccpAdd(lastPoint, ccp(posX, posY));
            }
            //player moving top right to bottom left
            else if (!player2BottomtoTop){
               //moving down left from right
               player2Control = ccpSub(lastPoint, ccp(posX, posY));
            }
         }
         //slope is less than 0
         else if (player2MovementSlope < 0){
            //player move bottom right to top left
            if (player2BottomtoTop){
               //moving down left from right
               player2Control = ccpSub(lastPoint, ccp(posX, posY));
            }
            //player move top left to bottom right
            else if (!player2BottomtoTop){
               //moving down left from right
               player2Control = ccpAdd(lastPoint, ccp(posX, posY));
            }
         }
         //slope is 0
         else if (player2MovementSlope == 0){
            //player moving left to right
            if (player2LefttoRight){
               player2Control = ccpAdd(lastPoint, ccp(adjDist, 0));
            }
            //player moving right to left
            else if (!player2LefttoRight){
               player2Control = ccpSub(lastPoint, ccp(adjDist, 0));
            }
         }
      }
      //infitie slope
      else{
         if (player2BottomtoTop){
            player2Control = ccpAdd(lastPoint, ccp(0, 200));
         }
         else if (!player2BottomtoTop){
            player2Control = ccpAdd(lastPoint, ccp(0, -200));
            
         }
      }
      
      p12 = player2Control;
      p22 = player2startPos;
      p32 = player2startPos;
      p42 = player2.position;
      
      bzConfig_0.controlPoint_1 = player2Control;
      bzConfig_0.controlPoint_2 = player2startPos;
      bzConfig_0.endPosition = player2startPos;
      CCBezierTo *bezierTo_0 = [CCBezierTo actionWithDuration:3.5f bezier:bzConfig_0];
      [bezierArray1 addObject:bezierTo_0];
      //id callback = [CCCallFunc actionWithTarget:self selector:@selector(streakFinished2:)];
      
      // create actionsequence and run action
      CCSequence *bezierSeq = [CCSequence actionWithArray:bezierArray1];
      [player2 runAction: [CCSequence actions:bezierSeq, nil]];
   }
   else if (!player2Moving){
      id moveBack = [CCMoveTo actionWithDuration:3.5 position:player2startPos];
      //id callback = [CCCallFunc actionWithTarget:self selector:@selector(streakFinished2:)];
      
      [player2 runAction:[CCSequence actions:moveBack, nil]];
   }
}

-(void) restartPlay{
   playStarted = NO;
   
}
-(void) playOverWithDelay:(float) delay withDistance: (float) ballDist{
   //move players back after delay
   [self performSelector:@selector(movePlayer1Back) withObject:nil afterDelay:delay];
   [self performSelector:@selector(movePlayer2Back) withObject:nil afterDelay:delay];
   
   NSLog(@"Is the player moving: %d", player1Moving);
   
   [self performSelector:@selector(restartPlay) withObject:nil afterDelay:delay + 3.5];
   NSLog(@"The dist: %f", ballDist);

   for (CCSprite *tile in fieldTileLayer.children){
      [tile runAction:[CCMoveBy actionWithDuration:3.5f position:ccp(0, -ballDist)]];
   }
}
-(NSString *)tileImageName:(CCSprite *)tile{
   NSString *returnString;
   int randInt = arc4random()%4 + 1;
   int tag = tile.tag;
   //if even
   if (tag%2 == 0){
      returnString = [NSString stringWithFormat:@"Green1%i.png", randInt];
   }
   //else odd
   else{
      returnString = [NSString stringWithFormat:@"Green2%i.png", randInt];
   }
   return returnString;
}

#pragma mark Gamelogic
- (void)tick:(ccTime) dt {
   
   for (int i = 0; i < [playerArray count]; i ++){
      CCMotionStreak *streak = (CCMotionStreak *)[streakArray objectAtIndex:i];
      CCSprite *player = (CCSprite *)[playerArray objectAtIndex:i];
      streak.position = player.position;
   }
   
   for (CCSprite *ball in ballLayer.children){
      for (CCSprite *player in playerLayer.children){
         if (CGRectIntersectsRect(player.boundingBox, ball.boundingBox)){
            [removeArray addObject:ball];
            [ballArray removeObject:ball];
            
            //play is over
            //ball is caught
            player1Hold = player1.position;
            player2Hold = player2.position;
            
            
            float playDist = ball.position.y - qb.position.y;
            NSLog(@"The dist: %f", playDist);
            [self playOverWithDelay:0.1f withDistance: playDist];
         }
      }
   }
   
   for (CCSprite *ball in ballLayer.children){
      if (ball.position.y >= 480 || ball.position.x <= 0 || ball.position.x >= 300){
         [removeArray addObject:ball];
         [ballArray removeObject:ball];
         
         //play is over
         //ball out of bounds
         player1Hold = player1.position;
         player2Hold = player2.position;
         
         [self playOverWithDelay:0.75f withDistance: 0];
      }
   }
   
   for (CCSprite *tile in fieldTileLayer.children){
      if (tile.position.y <= -50){
         tile.position = ccp(160, tile.position.y + 616);
         tile = [CCSprite spriteWithFile:[self tileImageName: tile]];
      }
      
   }
   for (int i = 0; i < [removeArray count]; i++) {
      [ballLayer removeChild:(CCSprite *)[removeArray objectAtIndex:i] cleanup:YES];
   }
   
   if (swipeStarted){
      timeSwiped ++;
      NSLog(@"Sent time: %i", timeSwiped);
   }
}
#pragma mark Touch Calculations

-(void) calculatePoints{
   //first touch point
   CGPoint startPos = [[pointArray objectAtIndex:0] CGPointValue];
   startTouch = startPos;
   //last touch point
   CGPoint endPos = [[pointArray objectAtIndex:[pointArray count]-1] CGPointValue];
   
   //slope of first and last points
   float slope = (endPos.y - startPos.y) / (endPos.x - startPos.x);
   
   //extend the line to make the length the height of the screen
   float endPointLength = [[CCDirector sharedDirector] winSize].height;
   float endPointx = ((endPointLength - endPos.y)/slope) + endPos.x;
   
   endPosition = ccp(endPointx, endPointLength);
   
   //holder distance for point to tangent
   float tangentDist = 0;
   
   //find the touch point that is furthest away from the straight line path
   for (int i = 0; i < [pointArray count]-1; i ++){
      //get x value of point in array
      float x = [[pointArray objectAtIndex:i] CGPointValue].x;
      //get y value of point in array
      float y = [[pointArray objectAtIndex:i] CGPointValue].y;
      
      //tangent point from the touched path to the straightline of the slope
      float posX = ((slope * ((x/slope) + y + (endPos.x * slope) - endPos.y))/(pow(slope, 2) + 1));
      float posY = slope * (posX - endPos.x) + endPos.y;
      
      //distance between touch path and straight line of the slope
      float posDist = ccpDistance(ccp(posX, posY), [[pointArray objectAtIndex:i] CGPointValue]);
      
      if (posDist > tangentDist){
         //set new value for distance
         tangentDist = posDist;
         //point on the straight line that is intersection between line and its tangent (makes right angle)
         tan =  CGPointMake(posX, posY);
         //point that the user dragged that is the furthest from the straight line
         tanSect = ccp(x, y);
      }
   }
   
   float dist1 = ccpDistance(startPos, endPos);
   float dist2 = ccpDistance(tanSect, tan);
   float dist3 = (dist2 * endPointLength) / dist1;
   //dist3 = 100;
   //create bezier path
   controlPoint1 = tanSect;
   
   midPoint = ccp((startPos.x + endPosition.x)/2, (startPos.y + endPosition.y)/2);
   
   float tangentSlope = -1 / slope;
   
   float x1 = sqrt(pow(dist3, 2) / (1 + pow(tangentSlope, 2)));
   float y1 = tangentSlope * x1;
   
   float testPoint = slope * (controlPoint1.x - startPos.x) + startPos.y;
   
   if (slope > 0){
      if (testPoint > controlPoint1.y){
         point2 = ccpAdd(midPoint, ccp(x1, y1));
      }
      else if (testPoint < controlPoint1.y){
         point2 = ccpSub(midPoint, ccp(x1, y1));
      }
   }
   else if (slope <= 0){
      if (testPoint < controlPoint1.y){
         point2 = ccpAdd(midPoint, ccp(x1, y1));
      }
      else if (testPoint > controlPoint1.y){
         point2 = ccpSub(midPoint, ccp(x1, y1));
      }
   }
   
   float controlX = ((tanSect.x*slope) - tanSect.y + (midPoint.x/slope) + midPoint.y) / (slope + 1/slope);
   float controlY = slope * (controlX - tanSect.x) + tanSect.y;
   controlPoint1 = ccp(controlX, controlY);
   //NSLog(@"Distances: %f, %f, %f", dist1, dist2, dist3);
   
}
-(void)throwBallWithTime:(int)time{
   CCSprite *ball1 = [CCSprite spriteWithFile:@"Player2.png"];
   ball1.position = qb.position;
   [ballLayer addChild:ball1];
   
   //calculate time for action based on time taken to swipe
   float actionTime = timeSwiped * 15 / dist;
   if (actionTime < 0.5){
      actionTime = 0.5;
   }
   else if (actionTime > 3){
      actionTime = 3;
   }
   
   NSMutableArray *bezierArray1 = [NSMutableArray array];
   // Add Beziers
   // Bezier 0
   ccBezierConfig bzConfig_0;
   
   bzConfig_0.controlPoint_1 = startTouch;
   bzConfig_0.controlPoint_2 = point2;
   bzConfig_0.endPosition = endPosition;
   CCBezierTo *bezierTo_0 = [CCBezierTo actionWithDuration:actionTime bezier:bzConfig_0];
   [bezierArray1 addObject:bezierTo_0];
   
   // create actionsequence and run action
   CCSequence *bezierSeq = [CCSequence actionWithArray:bezierArray1];
   [ball1 runAction: [CCSequence actions:bezierSeq, nil]];
   
   timeSwiped = 0;
}
#pragma mark Touches

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
   
   for (UITouch *touch in touches) {
      touchLocation = [touch locationInView: [touch view]];
      touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
      if (touchStartedAtPlayer){
         
         [pointArray addObject:[NSValue valueWithCGPoint:touchLocation]];
         playerTouchPoint = touchLocation;
         dist = sqrtf(pow((touchLocation.x - qb.position.x), 2) + pow((touchLocation.y - qb.position.y), 2));
         dist = ccpDistance(touchLocation, qb.position);
         [self calculatePoints];
      }
      else if (firstTouch.y < touchLocation.y && firstTouch.y < 15){
         showRoutes = YES;
      }
   }
}
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
   showRoutes = NO;
   if (touchStartedAtPlayer){
      for (UITouch *touch in touches) {
         
         touchLocation = [touch locationInView: [touch view]];
         touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
         
         dist = sqrtf(pow((touchLocation.x - qb.position.x), 2) + pow((touchLocation.y - qb.position.y), 2));
         dist = ccpDistance(touchLocation, qb.position);
         
         if ([pointArray count] > 0){
            //calculate straight path from first point to last
            [self calculatePoints];
            [self throwBallWithTime: timeSwiped];
         }
      }
      touchStartedAtPlayer = NO;
      swipeStarted = NO;
   }
}
-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
   [pointArray removeAllObjects];
   [bezierArray removeAllObjects];
   for (UITouch *touch in touches) {
      touchLocation = [touch locationInView: [touch view]];
      touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
      
      UITouch *touch = [[touches allObjects] objectAtIndex:0];
      CGPoint location = [touch locationInView:[touch view]];
      firstTouch = [[CCDirector sharedDirector] convertToGL:location];
      timeSwiped = 0;
      if (CGRectContainsPoint(qb.boundingBox, touchLocation) && playStarted){
         touchStartedAtPlayer = YES;
         swipeStarted = YES;
      }
      if (CGRectContainsPoint(qb.boundingBox, touchLocation) && !playStarted){
         NSLog(@"Start");
         playStarted = YES;
         //start the play
         [self playerStreak1];
         [self playerStreak2];
      }
   }
}

#pragma mark Draw

-(void) draw
{
	// Debugging
   glLineWidth(4);
   //ccDrawColor4F(255.0f, 255.0f, 255.0f, 255.0f);
   //draws the users touch
   /*
    if ([pointArray count] > 2){
    for (int i = 0; i < [pointArray count]-2; i ++){
    ccDrawLine([[pointArray objectAtIndex:i] CGPointValue], [[pointArray objectAtIndex:i+1] CGPointValue]);
    
    }
    
    }
    */
   
   //ccDrawColor4F(200.0f, 100.0f, 100.0f, 255.0f);
   
   //draws straight line
   //ccDrawLine(startTouch, endPosition);
   //farthest point on touch to straight line
   //ccDrawLine(tanSect, tan);
   
   //ccDrawColor4F(0.0f, 255.0f, 255.0f, 255.0f);
   //start to generic control point
   //ccDrawLine(startTouch, controlPoint1);
   //tangent line to the midpoint to generic control point
   //ccDrawLine(midPoint, controlPoint1);
   
   ccDrawColor4F(0.0f, 255.0f, 0.0f, 255.0f);
   //start to main control point
   //ccDrawLine(startTouch, point2);
   //bezier path the ball travels
   
   //ccDrawCubicBezier(startTouch, startTouch, point2, endPosition,100);
   
   //ccDrawCubicBezier(p4, p1, p2, p3,100);
   //ccDrawCubicBezier(p42, p12, p22, p32,100);
   
   //ccDrawLine(player1Control, p4);
   //ccDrawLine(newP1, newP2);
   //ccDrawLine(newP12, newP22);
   
   if (showRoutes){
      for (int i = 1; i < [player1Book count]; i ++){
         ccDrawLine([[player1Book objectAtIndex:i-1] CGPointValue], [[player1Book objectAtIndex:i] CGPointValue]);
      }
      for (int i = 1; i < [player2Book count]; i ++){
         ccDrawLine([[player2Book objectAtIndex:i-1] CGPointValue], [[player2Book objectAtIndex:i] CGPointValue]);
      }
   }
   //ccDrawLine(player1Control, player1.position);
   //ccDrawLine(player2Control, player2.position);
   
}
// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}
@end
