//
//  Gig.h
//  FestApp
//

#import <Foundation/Foundation.h>

@interface Gig : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)json;

// Gig properties
@property (nonatomic, strong) NSDate *begin;
@property (nonatomic, strong) NSDate *end;
@property (nonatomic, strong) NSString *stage;
@property (nonatomic, strong) NSString *day;

// Gig properties
@property (nonatomic, strong) NSString *gigId;
@property (nonatomic, strong) NSString *gigName;
@property (nonatomic, strong) NSString *info;
@property (nonatomic, strong) NSString *imagePath;

// optional
@property (nonatomic, strong) NSURL *wikipediaUrl;

// Helper selectors
@property (nonatomic, readonly) NSString *timeIntervalString;
@property (nonatomic, readonly) NSString *stageAndTimeIntervalString;
@property (nonatomic, readonly) NSTimeInterval duration;

@end
