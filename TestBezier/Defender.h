//
//  Defender.h
//  TestBezier
//
//  Created by KirbyGee on 3/1/13.
//
//
#import "CCSprite.h"
#import "WideReceivers.h"
#import "Singleton.h"
@interface Defender : CCSprite{
   int playerNumber;
   bool defenderPlacementBool;
   WideReceivers *followPlayer;
   NSMutableArray *defenderMovementArray;
   bool hold;
}

-(id) initWithFile:(NSString *)filename;
-(id) followPlayer: (WideReceivers*) player;
-(id) moveDefenderBack:(CGPoint) endpt;

@property (readwrite) bool followPlayerBool;
@property (nonatomic, retain)NSMutableArray *defenderMovementArray;
@end
