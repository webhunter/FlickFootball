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
@synthesize player1, player2, qb;
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
      
      bezierArray = [[NSMutableArray alloc] init];
      pointArray = [[NSMutableArray alloc] init];
      
      player1Book = [[NSMutableArray alloc] init];
      player2Book = [[NSMutableArray alloc] init];
      
      CCSprite *bg = [CCSprite spriteWithFile:@"FbField.png"];
      bg.position = ccp(160, 240);
      //[self addChild:bg z:-500];
      
      
      fieldTileLayer = [CCLayer node];
      [self addChild:fieldTileLayer z:-50];
      
      ballLayer = [CCLayer node];
      [self addChild:ballLayer z:1];
      
      playerLayer = [CCLayer node];
      [self addChild:playerLayer z:1];
      
      defenderLayer = [CCLayer node];
      [self addChild:defenderLayer z:1];
      
      menuLayer = [CCLayer node];
      [self addChild:menuLayer z:4];
      
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
      
      
      qb = [CCSprite spriteWithFile:@"Player2.png"];
      qb.position = ccp(160, 20);
      [self addChild:qb z:50];
      
      [self readPlaybookWithPlay:1];
      
      player1 = [WideReceivers spriteWithFile:@"Player2.png"];
      [player1 setStartingPosition:player1startPos];
      player1.position = player1startPos;
      [playerLayer addChild:player1];
      [playerArray addObject:player1];
      
      player2 = [WideReceivers spriteWithFile:@"Player2.png"];
      [player2 setStartingPosition:player2startPos];
      player2.position = player2startPos;
      [playerLayer addChild:player2];
      [playerArray addObject:player2];
      
      defender1 = [Defender spriteWithFile:@"Player2.png"];
      defender1.position = ccp(160, 100);
      defender1.color = ccYELLOW;
      [defenderLayer addChild:defender1];
      
      defender2 = [Defender spriteWithFile:@"Player2.png"];
      defender2.position = ccp(260, 100);
      defender2.color = ccYELLOW;
      [defenderLayer addChild:defender2];
      
      [defender1 followPlayer:player1];
      [defender2 followPlayer:player2];
      
      swipeStarted = NO;
      touchStartedAtPlayer = NO;
      timeSwiped = 0;
      showRoutes = NO;
      playStarted = NO;
      tan = CGPointMake(160, 240);
      menuShowing = YES;
      menuTouch = NO;
      menuAdjust = NO;
      [Singleton sharedSingleron].playersHaveReturned = YES;
      
      for (int i = 0; i < [playerArray count]; i ++){
         CCSprite *player = (CCSprite*)[playerArray objectAtIndex:i];
         CCMotionStreak *playerStreak = [CCMotionStreak streakWithFade:0.8 minSeg:1 width:16 color:ccWHITE textureFilename:@"Streak.png"];
         [playerStreak setPosition:player.position];
         [self addChild:playerStreak z:-1];
         [streakArray addObject:playerStreak];
      }
      
      CCSprite *topPiece = [CCSprite spriteWithFile:@"TopPiece.png"];
      topPiece.position = ccp(160, 480 - topPiece.boundingBox.size.height/2);
      [self addChild:topPiece z:10];
      
      playBg = [CCSprite spriteWithFile:@"Backboard.png"];
      playBg.position = ccp(160, 367);
      
      
      playBg1 = [CCSprite spriteWithFile:@"Backboard2.png"];
      playBg1.position = ccp(160, 367);
      
      playMaker = [CCSprite spriteWithFile:@"DownMarker.png"];
      playMaker.position = ccp(160, 281);
      
      playBg.anchorPoint = ccp(.5, .5);
      playBg1.anchorPoint = ccp(.5, .5);
      playMaker.anchorPoint = ccp(.5, .5);
      
      [menuLayer addChild:playBg z:3];
      [menuLayer addChild:playBg1 z:2];
      [self addChild:playMaker z:2];
      
		NSMutableArray* allItems = [NSMutableArray arrayWithCapacity:3];
      float offset;
		for (int i = 0; i < 3; ++i)
		{
			// create a menu item for each character
			NSString* image = [NSString stringWithFormat:@"Play%i", i+1];
			NSString* normalImage = [NSString stringWithFormat:@"%@.png", image];
			NSString* selectedImage = [NSString stringWithFormat:@"%@.png", image];
			
			CCSprite* normalSprite = [CCSprite spriteWithFile:normalImage];
			CCSprite* selectedSprite = [CCSprite spriteWithFile:selectedImage];
         CCMenuItemSprite* item =[CCMenuItemSprite itemWithNormalSprite:normalSprite selectedSprite:selectedSprite target:self selector:@selector(LaunchLevel:)];
         
			[allItems addObject:item];
         offset = normalSprite.boundingBox.size.width/2;
		}
      SlidingMenu* menuGrid = [SlidingMenu menuWithArray:allItems cols:3 rows:1 position:CGPointMake(offset + 5, playBg.position.y) padding:CGPointMake(5 + 2*offset, 0)];
      menuGrid.anchorPoint = ccp(.5, .5);
      [menuLayer addChild:menuGrid z:2];
      
      [self schedule:@selector(tick:)];
      
	}
	return self;
}
- (void) LaunchLevel:(id)sender{
   NSLog(@"Sender: %i", [sender tag]);
   [self readPlaybookWithPlay:[sender tag]];
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
   [player1Book removeAllObjects];
   [player2Book removeAllObjects];
   
   for (int i = 0; i < [firstPlay count]; i ++){
      NSString *rawPlay = [firstPlay objectAtIndex:i];
      xCoord = [[[rawPlay componentsSeparatedByString:@"x"] objectAtIndex:0] integerValue];
      yCoord = [[[rawPlay componentsSeparatedByString:@"x"] objectAtIndex:1] integerValue];
      
      CGPoint point = CGPointMake(xCoord, yCoord);
      [player1Book addObject:[NSValue valueWithCGPoint:point]];
      
      if (i == 0){
         player1startPos = point;
      }
   }
   
   for (int i = 0; i < [secondPlay count]; i++){
      NSString *rawPlay = [secondPlay objectAtIndex:i];
      xCoord = [[[rawPlay componentsSeparatedByString:@"x"] objectAtIndex:0] integerValue];
      yCoord = [[[rawPlay componentsSeparatedByString:@"x"] objectAtIndex:1] integerValue];
      
      CGPoint point = CGPointMake(xCoord, yCoord);
      [player2Book addObject:[NSValue valueWithCGPoint:point]];
      if (i == 0){
         player2startPos = point;
      }
   }
}
-(void) restartPlay:(id) sender{
   playStarted = NO;
}
-(void) removeBallCopy:(id)sender{
   [self removeChild:ballCopy cleanup:YES];
   ballToPlayer = NO;
}
-(void) moveBack:(NSString*)string{
   [player1 movePlayerBack];
   [player2 movePlayerBack];
   if ([string floatValue] != 0){
      id fade = [CCFadeOut actionWithDuration:1.5f];
      id callBack = [CCCallFunc actionWithTarget:self selector:@selector(removeBallCopy:)];
      [ballCopy runAction:[CCSequence actions:fade, callBack, nil]];
   }
}
-(void) playOverWithDelay:(float) delay withDistance: (float) ballDist{
   //move players back after delay
   NSString *object = [NSString stringWithFormat:@"%f", ballDist];
   [self performSelector:@selector(moveBack:) withObject:object afterDelay:delay];
   
   [self performSelector:@selector(restartPlay:) withObject:nil afterDelay:delay + 3.5];
   
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
-(void) moveDefenderBack{
   [defender1 runAction:[CCMoveTo actionWithDuration:1.0f position:ccp(160, 200)]];
   [defender2 runAction:[CCMoveTo actionWithDuration:1.0f position:ccp(260, 200)]];
   
}
#pragma mark Gamelogic
- (void)tick:(ccTime) dt {
   
   for (int i = 0; i < [playerArray count]; i ++){
      CCMotionStreak *streak = (CCMotionStreak *)[streakArray objectAtIndex:i];
      WideReceivers *player = (WideReceivers *)[playerArray objectAtIndex:i];
      streak.position = player.position;
   }
   
   for (Ball *ball in ballLayer.children){
      for (WideReceivers *player in playerLayer.children){
         
         if (CGRectIntersectsRect(player.boundingBox, ball.boundingBox)){
            [ball stopAllActions];
            [ball createCopy];
            
            ballCopy = [CCSprite spriteWithFile:@"Player2.png"];
            ballCopy.position = ball.position;
            ballCopy.color = ccRED;
            [self addChild:ballCopy z:20];
            ballToPlayer = YES;
            ballToStick = player;
            
            [removeArray addObject:ball];
            [ballArray removeObject:ball];
            
            //play is over ball is caught
            [player1 setHoldPosition: player1.position];
            [player2 setHoldPosition: player2.position];
            
            [Singleton sharedSingleron].defenderFollowBool = NO;
            
            float playDist = ball.position.y - qb.position.y;
            [self moveDefenderBack];
            [self playOverWithDelay:0.5f withDistance: playDist];
         }
      }
      
      for (Defender *defender in defenderLayer.children){
         if (CGRectIntersectsRect(defender.boundingBox, ball.boundingBox)){
            [ball stopAllActions];
            ballCopy = [CCSprite spriteWithFile:@"Player2.png"];
            ballCopy.position = ball.position;
            ballCopy.color = ccRED;
            [self addChild:ballCopy z:20];
            ballToPlayer = YES;
            ballToStick = defender;
            
         }
      }
      if (ball.position.y >= 480 || ball.position.x <= -60 || ball.position.x >= 380){
         [removeArray addObject:ball];
         [ballArray removeObject:ball];
         
         //play is over ball out of bounds
         [player1 setHoldPosition: player1.position];
         [player2 setHoldPosition: player2.position];
         
         [Singleton sharedSingleron].defenderFollowBool = NO;
         
         [self moveDefenderBack];
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
   }
   
   if (ballToPlayer){
      float dx = ballToStick.position.x - ballCopy.position.x;
      float dy = ballToStick.position.y - ballCopy.position.y;
      float d = sqrt(dx*dx + dy*dy);
      float v = 160;
      
      if (d > 2){
         ballCopy.position = ccpAdd(ballCopy.position, ccp(dx/d * v * dt, dy/d * v *dt));
      }
      else{
         ballCopy.position = ballToStick.position;
      }
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
}
-(void)throwBallWithTime:(int)time{
   if ([ballArray count] < 1){
      Ball *ball = [Ball spriteWithFile:@"Player2.png"];
      ball.position = qb.position;
      ball.color = ccRED;
      [ballLayer addChild:ball];
      [ballArray addObject:ball];
      
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
      [ball runAction: [CCSequence actions:bezierSeq, nil]];
      
      timeSwiped = 0;
   }
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
         [[[CCDirector sharedDirector] scheduler]setTimeScale:.5];
         
      }
      else if (menuTouch){
         CGPoint oldTouchLocation = [touch previousLocationInView:touch.view];
         oldTouchLocation = [[CCDirector sharedDirector] convertToGL:oldTouchLocation];
         oldTouchLocation = [self convertToNodeSpace:oldTouchLocation];
         
         //if dragged at least 80 pixels in either direction
         if (abs(firstTouch.y - touchLocation.y) > 80){
            //move menu up if it is showing
            if (menuShowing){
               [menuLayer runAction:[CCMoveTo actionWithDuration:.2f position:ccp(0, 157)]];
               [playMaker runAction:[CCMoveTo actionWithDuration:.2f position:ccp(160, 438)]];
               
               menuShowing = NO;
               
            }
            //move menu down if not showing
            else if (!menuShowing){
               [menuLayer runAction:[CCMoveTo actionWithDuration:.2f position:ccp(0, 0)]];
               [playMaker runAction:[CCMoveTo actionWithDuration:.2f position:ccp(160, 281)]];
               
               menuShowing = YES;
            }
            menuAdjust = NO;
            menuTouch = NO;
         }
         else{
            CGPoint translation = ccpSub(touchLocation, oldTouchLocation);
            menuAdjust = YES;
            //makes sure if menu is showing it wont go below its current position
            if (menuShowing && translation.y > 0){
               menuLayer.position = ccpAdd(menuLayer.position, ccp(0, translation.y));
               playMaker.position = ccpAdd(playMaker.position, ccp(0, translation.y));
            }
            //makes sure if menu is not showing it wont go above its current position
            else if (!menuShowing && translation.y < 0){
               menuLayer.position = ccpAdd(menuLayer.position, ccp(0, translation.y));
               playMaker.position = ccpAdd(playMaker.position, ccp(0, translation.y));
            }
         }
      }
   }
}
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
   showRoutes = NO;
   [[[CCDirector sharedDirector] scheduler]setTimeScale:1.0];
   
   for (UITouch *touch in touches) {
      if (touchStartedAtPlayer && [Singleton sharedSingleron].playersHaveReturned){
         touchLocation = [touch locationInView: [touch view]];
         touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
         
         dist = sqrtf(pow((touchLocation.x - qb.position.x), 2) + pow((touchLocation.y - qb.position.y), 2));
         dist = ccpDistance(touchLocation, qb.position);
         
         if ([pointArray count] > 0){
            //calculate straight path from first point to last
            [self calculatePoints];
            [self throwBallWithTime: timeSwiped];
            [Singleton sharedSingleron].playersHaveReturned = NO;
            
         }
      }
      
      //makes sure the menu is a difinitive showing or not showing
      else if (menuAdjust){
         [menuLayer runAction:[CCMoveTo actionWithDuration:.2f position:ccp(0, 0)]];
         [playMaker runAction:[CCMoveTo actionWithDuration:.2f position:ccp(160, 281)]];
         menuAdjust = NO;
      }
      
      touchStartedAtPlayer = NO;
      swipeStarted = NO;
      menuTouch = NO;
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
      //if touch contains qb and the play is started, throw the ball
      if (CGRectContainsPoint(qb.boundingBox, touchLocation) && playStarted){
         touchStartedAtPlayer = YES;
         swipeStarted = YES;
      }
      //if touch contains qb and play hasnt started, start the play
      else if (CGRectContainsPoint(qb.boundingBox, touchLocation) && !playStarted){
         playStarted = YES;
         //start the play
         [player1 playerStreak: player1Book];
         [player2 playerStreak: player2Book];
         [Singleton sharedSingleron].defenderFollowBool = YES;
         [Singleton sharedSingleron].playersHaveReturned = YES;
      }
      //if the touch contains the menu
      else if (CGRectContainsPoint(playMaker.boundingBox, touchLocation)){
         menuTouch = YES;
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
