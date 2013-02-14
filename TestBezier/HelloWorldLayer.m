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
      player1movements = [[NSMutableArray alloc] init];
      player2movements = [[NSMutableArray alloc] init];
      
      bezierArray = [[NSMutableArray alloc] init];
      pointArray = [[NSMutableArray alloc] init];
      
      CCSprite *bg = [CCSprite spriteWithFile:@"FbField.png"];
      bg.position = ccp(160, 240);
      //[self addChild:bg z:-500];
      
      
      fieldTileLayer = [CCLayer node];
      [self addChild:fieldTileLayer z:0];
      
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
         //[fieldTileLayer addChild:tile];
         [fieldTileArray addObject:tile];
      }
      
      qb = [CCSprite spriteWithFile:@"Player2.png"];
      qb.position = ccp(160, 20);
      [self addChild:qb z:50];
      
      player1 = [CCSprite spriteWithFile:@"Player2.png"];
      player1.position = ccp(0, 0);
      player1.tag = 1;
      [playerLayer addChild:player1];
      [playerArray addObject:player1];
      
      player2 = [CCSprite spriteWithFile:@"Player2.png"];
      player2.position = ccp(300, 0);
      player2.tag = 2;
      [playerLayer addChild:player2];
      [playerArray addObject:player2];
      
      player1startPos = ccp(0, 0);
      player2startPos = ccp(300, 0);
      
      [startingPos addObject:[NSValue valueWithCGPoint:player1startPos]];
      [startingPos addObject:[NSValue valueWithCGPoint:player2startPos]];
      
      
      [self playerStreak1];
      [self playerStreak2];
      
      swipeStarted = NO;
      pastDistance = NO;
      touchStartedAtPlayer = NO;
      timeSwiped = 0;
      playIsLive = NO;
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
-(void) playerStreak1{
   player1.position = ccp(0, 0);
   id callback = [CCCallFunc actionWithTarget:self selector:@selector(streakFinished1:)];
   
   id straight = [CCMoveBy actionWithDuration:4.0f position:ccp(0, 200)];
   id streak = [CCMoveBy actionWithDuration:3.0f position:ccp(300, 200)];
   [player1 runAction:[CCSequence actions:straight, streak, callback, nil]];
}
-(void)streakFinished1:(id)sender{
   //[self playerStreak1];
   //create path to new random point
   
   
   int randX = arc4random()%320;
   int randY = arc4random()%300 + 100;
   CGPoint randPoint = CGPointMake(randX, randY);
   
   //make sure the new point is at least 150 pixels away from current position
   while (ccpDistance(player1.position, randPoint) < 150){
      int randX = arc4random()%320;
      int randY = arc4random()%300 + 100;
      randPoint = CGPointMake(randX, randY);
   }
   //calc dist to new point
   float newDist = ccpDistance(player1.position, randPoint);
   //find time to new point
   float time = newDist/480*5;
   id callback = [CCCallFunc actionWithTarget:self selector:@selector(streakFinished1:)];
   //minimun delay time is .5 seconds, max is 1.5 seconds
   float delayTime = ((arc4random()%100) + 50) / 100;
   id delay = [CCDelayTime actionWithDuration:delayTime];
   id moveTo = [CCMoveTo actionWithDuration:time position:randPoint];
   [player1 runAction:[CCSequence actions:delay, moveTo, callback, nil]];
   
}
-(void) playerStreak2{
   player2.position = ccp(300, 0);
   id callback = [CCCallFunc actionWithTarget:self selector:@selector(streakFinished2:)];
   
   id straight = [CCMoveBy actionWithDuration:4.0f position:ccp(0, 300)];
   id streak = [CCMoveBy actionWithDuration:3.0f position:ccp(-250, 120)];
   [player2 runAction:[CCSequence actions:straight, streak, callback, nil]];
   
}
-(void)streakFinished2:(id)sender{
   //create path to new random point
   int randX = arc4random()%320;
   int randY = arc4random()%300 + 100;
   CGPoint randPoint = CGPointMake(randX, randY);
   
   //make sure the new point is at least 150 pixels away from current position
   while (ccpDistance(player2.position, randPoint) < 150){
      int randX = arc4random()%320;
      int randY = arc4random()%300 + 100;
      randPoint = CGPointMake(randX, randY);
   }
   //calc dist to new point
   float newDist = ccpDistance(player2.position, randPoint);
   //find time to new point
   float time = newDist/480*5;
   id callback = [CCCallFunc actionWithTarget:self selector:@selector(streakFinished2:)];
   //minimun delay time is .5 seconds, max is 1.5 seconds
   float delayTime = ((arc4random()%100) + 50) / 100;
   id delay = [CCDelayTime actionWithDuration:delayTime];
   id moveTo = [CCMoveTo actionWithDuration:time position:randPoint];
   [player2 runAction:[CCSequence actions:delay, moveTo, callback, nil]];
}
-(void)performBezierMovement{
   id callback = [CCCallFunc actionWithTarget:self selector:@selector(bezierFinished:)];
   NSMutableArray *bezierArray1 = [NSMutableArray array];
   // Add Beziers
   // Bezier 0
   ccBezierConfig bzConfig_0;
   
   if(bezierLTR) {
      
      bzConfig_0.controlPoint_1 = ccp(80, 315);
      bzConfig_0.controlPoint_2 = ccp(265, 172);
      bzConfig_0.endPosition = ccp(268, 463);
      CCBezierTo *bezierTo_0 = [CCBezierTo actionWithDuration:4 bezier:bzConfig_0];
      [bezierArray1 addObject:bezierTo_0];
   }
   else {
      bzConfig_0.controlPoint_1 = ccp(265, 172);
      bzConfig_0.controlPoint_2 = ccp(80, 315);
      bzConfig_0.endPosition = ccp(0, 0);
      CCBezierTo *bezierTo_0 = [CCBezierTo actionWithDuration:4 bezier:bzConfig_0];
      [bezierArray1 addObject:bezierTo_0];
   }
   // create actionsequence and run action
   CCSequence *bezierSeq = [CCSequence actionWithArray:bezierArray1];
   [player1 runAction: [CCSequence actions:bezierSeq, callback, nil]];
}

-(void) movePlayer1Back{
   
   [player1 stopAllActions];
   
   NSLog(@"points: %@", player1movements);
   NSMutableArray *bezierArray1 = [NSMutableArray array];
   // Add Beziers
   // Bezier 0
   ccBezierConfig bzConfig_0;
   
   //calculate slope from points
   CGPoint lastPoint2 = player1hold;
   CGPoint lastPoint = player1.position;
   
   NSLog(@"The two points1 are: %@, %@", NSStringFromCGPoint(lastPoint), NSStringFromCGPoint(lastPoint2));
   
   float playerMovementSlope = (lastPoint.y - lastPoint2.y) / (lastPoint.x - lastPoint2.x);
   float adjDist = 200;
   
   BOOL infSlope = NO;
   
   if (lastPoint.x == lastPoint2.x){
      infSlope = YES;
   }

   if (!infSlope){
      float posX = sqrtf(pow(adjDist, 2) / (1 + pow(playerMovementSlope, 2)));
      
      float posY = playerMovementSlope * posX;
      
      if (playerMovementSlope > 0){
         if (lastPoint.y > lastPoint2.y){
            //moving down left from right
            player1Control = ccpAdd(lastPoint, ccp(posX, posY));
         }
         else if (lastPoint.y < lastPoint2.y){
            //moving down left from right
            player1Control = ccpSub(lastPoint, ccp(posX, posY));
         }
         //player2Control = ccpAdd(lastPoint, ccp(posX, posY));
      }
      else if (playerMovementSlope < 0){
         if (lastPoint.y > lastPoint2.y){
            NSLog(@"ASDHAERHAERGAEGAEG:        3");
            
            //moving down left from right
            player1Control = ccp(lastPoint.x - posX, lastPoint.y + posY);
         }
         else if (lastPoint.y < lastPoint2.y){
            NSLog(@"ASDHAERHAERGAEGAEG:        4");
            //moving down left from right
            player1Control = ccp(lastPoint.x + posX, lastPoint.y + posY);
            
         }
         //player2Control = ccpSub(lastPoint, ccp(posX, posY));
      }      NSLog(@"Slope: %f", playerMovementSlope);
   }
   else{
      NSLog(@"Slope1 is ZERO");
      NSLog(@"Zero slope1 x's: %f, %f", lastPoint.x , lastPoint2.x);

      player1Control = ccpAdd(lastPoint, ccp(0, adjDist));
   }
   p1 = player1.position;
   p2 = player1Control;
   p3 = player1startPos;
   
   bzConfig_0.controlPoint_1 = player1Control;
   bzConfig_0.controlPoint_2 = player1startPos;
   bzConfig_0.endPosition = player1startPos;
   CCBezierTo *bezierTo_0 = [CCBezierTo actionWithDuration:3.5f bezier:bzConfig_0];
   [bezierArray1 addObject:bezierTo_0];
   
   // create actionsequence and run action
   id callback = [CCCallFunc actionWithTarget:self selector:@selector(streakFinished1:)];

   CCSequence *bezierSeq = [CCSequence actionWithArray:bezierArray1];
   [player1 runAction: [CCSequence actions:bezierSeq, callback, nil]];
   
}
-(void) movePlayer2Back{
   
   [player2 stopAllActions];
   
   NSLog(@"points: %@", player1movements);
   NSMutableArray *bezierArray1 = [NSMutableArray array];
   // Add Beziers
   // Bezier 0
   ccBezierConfig bzConfig_0;
   
   //calculate slope from points
   CGPoint lastPoint2 = player2hold;
   CGPoint lastPoint = player2.position;
   
   float playerMovementSlope = (lastPoint.y - lastPoint2.y) / (lastPoint.x - lastPoint2.x);
   float adjDist = 200;
   
   BOOL infSlope = NO;
   
   if (lastPoint.x == lastPoint2.x){
      infSlope = YES;
   }
   
   if (lastPoint.y > lastPoint2.y){
      //moving down left from right
      
      
   }
   NSLog(@"The two points2 are: %@, %@", NSStringFromCGPoint(lastPoint), NSStringFromCGPoint(lastPoint2));

   if (!infSlope){
      float posX = sqrtf(pow(adjDist, 2) / (1 + pow(playerMovementSlope, 2)));
      
      
      float posY = playerMovementSlope * posX;
      
      if (playerMovementSlope > 0){
         if (lastPoint.y > lastPoint2.y){
            //moving down left from right
            player2Control = ccpAdd(lastPoint, ccp(posX, posY));
         }
         else if (lastPoint.y < lastPoint2.y){
            //moving down left from right
            player2Control = ccpSub(lastPoint, ccp(posX, posY));
         }
         //player2Control = ccpAdd(lastPoint, ccp(posX, posY));
      }
      else if (playerMovementSlope < 0){
         if (lastPoint.y > lastPoint2.y){
            NSLog(@"ASDHAERHAERGAEGAEG:        3");

            //moving down left from right
            player2Control = ccp(lastPoint.x - posX, lastPoint.y + posY);
         }
         else if (lastPoint.y < lastPoint2.y){
            NSLog(@"ASDHAERHAERGAEGAEG:        4");
            //moving down left from right
            player2Control = ccp(lastPoint.x + posX, lastPoint.y + posY);

         }
         //player2Control = ccpSub(lastPoint, ccp(posX, posY));
      }
      NSLog(@"Slope: %f", playerMovementSlope);
      
   }
   else{
      NSLog(@"Slope2 is ZERO");
      NSLog(@"Zero slope2 x's: %f, %f", lastPoint.x , lastPoint2.x);

      player2Control = ccpAdd(lastPoint, ccp(0, adjDist));
   }

   
   bzConfig_0.controlPoint_1 = player2Control;
   bzConfig_0.controlPoint_2 = player2startPos;
   bzConfig_0.endPosition = player2startPos;
   CCBezierTo *bezierTo_0 = [CCBezierTo actionWithDuration:3.5f bezier:bzConfig_0];
   [bezierArray1 addObject:bezierTo_0];
   id callback = [CCCallFunc actionWithTarget:self selector:@selector(streakFinished2:)];

   // create actionsequence and run action
   CCSequence *bezierSeq = [CCSequence actionWithArray:bezierArray1];
   [player2 runAction: [CCSequence actions:bezierSeq, callback, nil]];
   
}
-(void) newPlay{
   //start next play
   [self playerStreak1];
   [self playerStreak2];
}
-(void) playOverWithDelay:(float) delay withDistance: (float) ballDist{
   //move players back after delay
   [self performSelector:@selector(movePlayer1Back) withObject:nil afterDelay:delay];
   [self performSelector:@selector(movePlayer2Back) withObject:nil afterDelay:delay];

   
   for (CCSprite *tile in fieldTileLayer.children){
      [tile runAction:[CCMoveBy actionWithDuration:1.5f position:ccp(0, -ballDist)]];
      
   }
   
   //[self performSelector:@selector(newPlay) withObject:nil afterDelay:2.0f];
   
   
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
            float playDist = ball.position.y - qb.position.y;
            playIsLive = NO;
            //[player1movements addObject:[NSValue valueWithCGPoint:player1.position]];
            player1hold = player1.position;
            player2hold = player2.position;
            
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
         playIsLive = NO;
         //[player1movements addObject:[NSValue valueWithCGPoint:player1.position]];
         player1hold = player1.position;
         player2hold = player2.position;

         NSLog(@"The player points are: %@", NSStringFromCGPoint(player1hold));

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
   
   if (playIsLive){
      [player2movements addObject:[NSValue valueWithCGPoint:player2.position]];
      NSLog(@"Player 1 pos: %@", NSStringFromCGPoint(player1.position));
      
   }
   
}
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
   //NSLog(@"The final dist: %f", ccpDistance(midPoint, point2));
   
   //point1 = ccp(x1minus, y1minus);
   //NSLog(@"adding values midpoint: %@: slope:%f  : %f , %f", NSStringFromCGPoint(midPoint), tangentSlope,  x1, y1);
   
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
   NSLog(@"ACtion time: %f", actionTime);
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
   
   NSLog(@"called: %i", time);
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
   
   if (touchStartedAtPlayer){
      for (UITouch *touch in touches) {
         touchLocation = [touch locationInView: [touch view]];
         touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
         [pointArray addObject:[NSValue valueWithCGPoint:touchLocation]];
         playerTouchPoint = touchLocation;
         dist = sqrtf(pow((touchLocation.x - qb.position.x), 2) + pow((touchLocation.y - qb.position.y), 2));
         dist = ccpDistance(touchLocation, qb.position);
         [self calculatePoints];
      }
   }
}
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
   
   if (touchStartedAtPlayer){
      for (UITouch *touch in touches) {
         
         touchLocation = [touch locationInView: [touch view]];
         touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
         
         dist = sqrtf(pow((touchLocation.x - qb.position.x), 2) + pow((touchLocation.y - qb.position.y), 2));
         dist = ccpDistance(touchLocation, qb.position);
         
         //calculate straight path from first point to last
         [self calculatePoints];
         [self throwBallWithTime: timeSwiped];
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
      timeSwiped = 0;
      if (CGRectContainsPoint(qb.boundingBox, touchLocation )){
         touchStartedAtPlayer = YES;
         swipeStarted = YES;
         playIsLive = YES;
      }
   }
}


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
   
   ccDrawLine(ccp(0, 0), ccp(0, 200));
   ccDrawLine(ccp(0, 200), ccp(300, 400));
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
   ccDrawCubicBezier(startTouch, startTouch, point2, endPosition,100);
   ccDrawCubicBezier(p1, p1, p2, p3,100);
   ccDrawLine(player1Control, player1.position);
   ccDrawLine(player2Control, player2.position);

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
