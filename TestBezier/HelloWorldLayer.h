//
//  HelloWorldLayer.h
//  TestBezier
//
//  Created by KirbyGee on 1/23/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate>
{
   CCLayer *ballLayer;
   CCLayer *playerLayer;
   CCLayer *fieldTileLayer;
   BOOL bezierLTR;
   BOOL swipeStarted;
   BOOL pastDistance;
   BOOL touchStartedAtPlayer;
   BOOL playIsLive;
   int timeSwiped;
   int sentTime;
   
   CCSprite *qb;
   CCSprite *player1;
   CCSprite *player2;
   
   NSMutableArray *ballArray;
   NSMutableArray *removeArray;
   NSMutableArray *playerArray;
   NSMutableArray *streakArray;
   NSMutableArray *fieldTileArray;
   CGPoint playerTouchPoint;
   CGPoint touchLocation;
   CGPoint tlCopy;
   float velo;
   float dist;
   
   CGPoint controlPoint1;
   CGPoint controlPoint2;
   CGPoint endPosition;
   CGPoint newPoint;
   CGPoint midPoint;
   
   CGPoint point1;
   CGPoint point2;
   
   CGPoint tan;
   CGPoint tanSect;
   CGPoint startTouch;
   
   CGPoint player1startPos;
   CGPoint player2startPos;
   
   NSMutableArray *pointArray;
   NSMutableArray *bezierArray;
   NSMutableArray *startingPos;
   NSMutableArray *player1movements;
   NSMutableArray *player2movements;

   
   CGPoint p1;
   CGPoint p2;
   CGPoint p3;
   CGPoint p4;

   CGPoint player1Control;
   CGPoint player1hold;
   
   CGPoint player2Control;
   CGPoint player2hold;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
