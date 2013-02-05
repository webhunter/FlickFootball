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
      bezierArray = [[NSMutableArray alloc] init];
      
      pointArray = [[NSMutableArray alloc] init];
      
      ballLayer = [CCLayer node];
      [self addChild:ballLayer z:1];
      
      playerLayer = [CCLayer node];
      [self addChild:playerLayer z:1];
      
      qb = [CCSprite spriteWithFile:@"Player2.png"];
      qb.position = ccp(160, 20);
      [self addChild:qb];
      
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
      
      [self playerStreak1];
      [self playerStreak2];
      
      swipeStarted = NO;
      pastDistance = NO;
      touchStartedAtPlayer = NO;
      timeSwiped = 0;
      bezierLTR = YES;
      //[self performBezierMovement];
      
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
   [self playerStreak1];
   
}
-(void) playerStreak2{
   player2.position = ccp(300, 0);
   id callback = [CCCallFunc actionWithTarget:self selector:@selector(streakFinished2:)];
   
   id straight = [CCMoveBy actionWithDuration:4.0f position:ccp(0, 300)];
   id streak = [CCMoveBy actionWithDuration:3.0f position:ccp(-250, 120)];
   [player2 runAction:[CCSequence actions:straight, streak, callback, nil]];
}
-(void)streakFinished2:(id)sender{
   [self playerStreak2];
   
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
-(void)bezierFinished:(id)sender
{
	// Reverse
	bezierLTR = !bezierLTR;
	
	// Perform the movement
	[self performBezierMovement];
}

- (void)tick:(ccTime) dt {
   
   for (int i = 0; i < [playerArray count]; i ++){
      CCMotionStreak *streak = (CCMotionStreak *)[streakArray objectAtIndex:i];
      CCSprite *player = (CCSprite *)[playerArray objectAtIndex:i];
      streak.position = player.position;
   }
   
   velo = dist/100;
   
   for (CCSprite *ball in ballLayer.children){
      ball.position = ccpAdd(ball.position, ccp(([[pointArray objectAtIndex:[pointArray count]-1] CGPointValue].x - qb.position.x) * velo /sentTime, ([[pointArray objectAtIndex:[pointArray count]-1] CGPointValue].y - qb.position.y) * velo/sentTime));
      for (CCSprite *player in playerLayer.children){
         if (CGRectIntersectsRect(player.boundingBox, ball.boundingBox)){
            [removeArray addObject:ball];
            [ballArray removeObject:ball];
         }
      }
   }
   
   for (CCSprite *ball in ballLayer.children){
      if (ball.position.y >= 480 || ball.position.x <= 0 || ball.position.x >= 300){
         [removeArray addObject:ball];
         [ballArray removeObject:ball];
      }
   }
   
   for (int i = 0; i < [removeArray count]; i++) {
      [ballLayer removeChild:(CCSprite *)[removeArray objectAtIndex:i] cleanup:YES];
   }
   
   if (swipeStarted) {
      timeSwiped+=6;
      NSLog(@"Time: %i", timeSwiped);
   }
   
}

-(void)throwBallWithTime:(int)time andPosition: (CGPoint )location{
   CCSprite *ball1 = [CCSprite spriteWithFile:@"Player2.png"];
   ball1.position = qb.position;
   [ballLayer addChild:ball1];
   [ballArray addObject:ball1];
   tlCopy = location;
   sentTime = time;
   timeSwiped = 0;
   NSLog(@"called: %i", time);
}
-(void)calculateFarthestPoint:(NSArray *)array{
   CGPoint firstPoint = [[array objectAtIndex:0] CGPointValue];
   CGPoint lastPoint = [[array objectAtIndex:[array count] -1] CGPointValue];
   
   float slope = (lastPoint.y - firstPoint.y) / (lastPoint.x - firstPoint.x);
   
   
   float distHolder = 0;
   NSMutableArray *holdingArray = [[NSMutableArray alloc] init];
   for (int i = 0; i < [array count]; i ++){
      float x = [[array objectAtIndex:i] CGPointValue].x;
      float y = [[array objectAtIndex:i] CGPointValue].y;
      
      float posX = ((slope * ((x/slope) + y + (lastPoint.x * slope) - lastPoint.y))/(pow(slope, 2) + 1));
      float posY = slope * (posX - lastPoint.x) + lastPoint.y;
      
      float posDist = ccpDistance(ccp(posX, posY), [[array objectAtIndex:i] CGPointValue]);
      NSLog(@"pos: (%f, %f) ----> %f", posX, posY, posDist);
      
      if (posDist > distHolder){
         distHolder = posDist;
         [holdingArray removeAllObjects];
         [holdingArray addObject:[NSValue valueWithCGPoint:CGPointMake(posX, posY)]];
         //control point 1
         [bezierArray addObject:[NSValue valueWithCGPoint:CGPointMake(x,y)]];
      }
   }
   
   //calculate control point 2
   
   
   
   NSLog(@"Longest: %@", holdingArray);
   
}
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
   
   if (swipeStarted && !pastDistance){
      for (UITouch *touch in touches) {
         if (touchStartedAtPlayer){
            
            touchLocation = [touch locationInView: [touch view]];
            touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
            
            dist = sqrtf(pow((touchLocation.x - qb.position.x), 2) + pow((touchLocation.y - qb.position.y), 2));
            dist = ccpDistance(touchLocation, qb.position);
            
            NSLog(@"Distance:%f", dist);
            velo = ([[CCDirector sharedDirector] winSize].height)/dist;
            [self throwBallWithTime: timeSwiped andPosition:touchLocation];
            
         }
         swipeStarted = NO;
         timeSwiped = 0;
      }
   }
   
   
   pastDistance = NO;
   touchStartedAtPlayer = NO;
}
-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
   swipeStarted = YES;
   [pointArray removeAllObjects];
   [bezierArray removeAllObjects];
   for (UITouch *touch in touches) {
      touchLocation = [touch locationInView: [touch view]];
      touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
      
      if (CGRectContainsPoint(qb.boundingBox, touchLocation )){
         touchStartedAtPlayer = YES;
      }
   }
}
- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
   
   for (UITouch *touch in touches) {
      if (touchStartedAtPlayer){
         touchLocation = [touch locationInView: [touch view]];
         touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
         playerTouchPoint = touchLocation;
         dist = sqrtf(pow((touchLocation.x - qb.position.x), 2) + pow((touchLocation.y - qb.position.y), 2));
         dist = ccpDistance(touchLocation, qb.position);
         velo = ([[CCDirector sharedDirector] winSize].height)/dist;
         if (dist <=180){
            [pointArray addObject:[NSValue valueWithCGPoint:touchLocation]];
         }
         if (dist >= 180 && [ballArray count] < 1){
            [self throwBallWithTime: timeSwiped andPosition:touchLocation];
            pastDistance = YES;
            swipeStarted = NO;
            touchStartedAtPlayer = NO;
            
            NSLog(@"Final touch location: %@", NSStringFromCGPoint(touchLocation));
            [self calculateFarthestPoint:pointArray];
            NSLog(@"Point array: %@", pointArray);
            
         }
      }
   }
}

-(void) draw
{
	// Debugging
	
	//glEnable(GL_LINE_SMOOTH);
	glLineWidth(2);
   
   ccDrawLine(qb.position, ccp(qb.position.x + 160, qb.position.y + 82));
   ccDrawLine(qb.position, ccp(qb.position.x - 160, qb.position.y + 82));
   
   
   if ([pointArray count] > 2){
      for (int i = 0; i < [pointArray count]-2; i ++){
         ccDrawLine([[pointArray objectAtIndex:i] CGPointValue], [[pointArray objectAtIndex:i+1] CGPointValue]);
         
      }
      ccDrawLine(qb.position, [[pointArray objectAtIndex:[pointArray count]-1] CGPointValue]);
      
   }
   
   ccDrawCircle(qb.position, 180, 100, 100, NO);
   
   [self calculateBezierFromEndpoint: endPosition];
   endPosition = ccp(300, 480);
   controlPoint1 = ccp(300, 170);
   //controlPoint2 = ccp(120, 30);
   
   if ([bezierArray count] >= 1){
      ccDrawCubicBezier(qb.position, [[bezierArray objectAtIndex:0] CGPointValue], controlPoint1, endPosition,100);
   }
   
}
-(void) calculateBezierFromEndpoint:(CGPoint )endpt{
   
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
