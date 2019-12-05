//
//  PotonTableViewDataSource.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/21.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PhotonIMSDK/PhotonIMSDK.h"
NS_ASSUME_NONNULL_BEGIN

@protocol PotonTableViewDataSourceProtocol <UITableViewDataSource>
@property(nonatomic, strong,nullable)PhotonIMThreadSafeArray *items;
- (id)tableView:(UITableView *)tableView objectForRowAtIndexPath:(NSIndexPath *)indexPath;

- (Class)tableView:(UITableView *)tableView cellClassForObject:(id)object;

- (NSIndexPath *)tableView:(UITableView *)tableView indexPathForObject:(id)object;

- (void)tableView:(UITableView *)tableView cell:(UITableViewCell *)cell
willAppearAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface PotonTableViewDataSource : NSObject<PotonTableViewDataSourceProtocol>
@property(nonatomic, strong,nullable) NSMutableArray *items;
@property(nonatomic, assign) BOOL loadNibWithClassName;
- (id)initWithItems:(NSArray *)items;
@end

NS_ASSUME_NONNULL_END
