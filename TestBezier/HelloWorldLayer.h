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
   
   BOOL bezierLTR;
   BOOL swipeStarted;
   BOOL pastDistance;
   
   int timeSwiped;
   int sentTime;
   
   CCSprite *qb;
   CCSprite *player1;
   CCSprite *player2;
   
   NSMutableArray *ballArray;
   NSMutableArray *removeArray;
   NSMutableArray *playerArray;
   NSMutableArray *streakArray;
   CGPoint playerTouchPoint;
   CGPoint touchLocation;
   float velo;
   float dist;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
