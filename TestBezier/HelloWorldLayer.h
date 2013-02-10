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
   
   NSMutableArray *pointArray;
   NSMutableArray *bezierArray;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
