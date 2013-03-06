//
//  HelloWorldLayer.h
//  TestBezier
//
//  Created by KirbyGee on 1/23/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


#import <GameKit/GameKit.h>
#import "WideReceivers.h"
// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Defender.h"
#import "Ball.h"
#import "Singleton.h"
#import "SlidingMenu.h"
#import "WideReceivers.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate>
{
   CCLayer *ballLayer;
   CCLayer *playerLayer;
   CCLayer *fieldTileLayer;
   CCLayer *defenderLayer;
   BOOL swipeStarted;
   BOOL touchStartedAtPlayer;
   int timeSwiped;
   int sentTime;
   
   CCSprite *qb;
   WideReceivers *player1;
   WideReceivers *player2;
   Defender *defender1;
   Defender *defender2;
   CCSprite *ballToStick;

   CCSprite *ballCopy;
   NSMutableArray *ballArray;
   NSMutableArray *removeArray;
   NSMutableArray *playerArray;
   NSMutableArray *streakArray;
   NSMutableArray *fieldTileArray;
   CGPoint playerTouchPoint;
   CGPoint touchLocation;
   float velo;
   float dist;
   CGPoint endPosition;

   CGPoint controlPoint1;
   CGPoint controlPoint2;
   CGPoint newPoint;
   CGPoint midPoint;
   
   CGPoint point1;
   CGPoint point2;
   
   CGPoint tan;
   CGPoint tanSect;
   CGPoint startTouch;
   CGPoint firstTouch;
   CGPoint player1startPos;
   CGPoint player2startPos;
   
   NSMutableArray *pointArray;
   NSMutableArray *bezierArray;
   NSMutableArray *startingPos;

   CGPoint player1Control;
   CGPoint player2Control;
   
   BOOL showRoutes;

   BOOL playStarted;
   NSMutableArray *player1Book;
   NSMutableArray *player2Book;
   
   bool menuTouch;
   CCSprite *playMaker;
   CCSprite *playBg;
   CCSprite *playBg1;
   CCLayer *menuLayer;
   bool menuShowing;
   bool menuAdjust;
   bool ballToPlayer;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;
@property(nonatomic, retain)CCSprite *qb;
@property(nonatomic, retain)WideReceivers *player1;
@property(nonatomic, retain)WideReceivers *player2;
@property(nonatomic, readwrite)bool followPlayers;


@end
