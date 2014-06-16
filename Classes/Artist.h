//
//  Gig.h
//  FestApp
//

#import <Foundation/Foundation.h>

@interface Artist : NSObject

- (instancetype)initFromJSON:(NSDictionary *)json;

@property (nonatomic, strong) NSString *artistId;
@property (nonatomic, strong) NSString *artistName;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSDate *begin;
@property (nonatomic, strong) NSDate *end;
@property (nonatomic, strong) NSString *venue;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *imagePath;
@property (nonatomic, strong) NSURL *spotifyUrl;
@property (nonatomic, strong) NSURL *youtubeUrl;
@property (nonatomic, strong) NSString *quote;
@property (nonatomic, strong) NSString *founded;
@property (nonatomic, strong) NSString *members;

@property (nonatomic, strong) NSString *day;

@property (nonatomic, readonly) NSString *timeIntervalString;
@property (nonatomic, readonly) NSString *stageAndTimeIntervalString;
@property (nonatomic, readonly) NSTimeInterval duration;

@end
