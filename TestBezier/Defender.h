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
   NSMutableArray *defenderArray;
   
}

-(id) initWithFile:(NSString *)filename;
-(id) followPlayer: (WideReceivers*) player;
-(id) moveBack:(CGPoint) endpt;

@property (readwrite) bool followPlayerBool;
@property (nonatomic, retain)NSMutableArray *defenderArray;
@end
