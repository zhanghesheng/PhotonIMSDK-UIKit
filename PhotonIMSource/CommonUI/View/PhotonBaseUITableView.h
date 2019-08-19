//
//  PhotonBaseUITableView.h
//  PhotonIM
//
//  Created by Bruce on 2019/8/12.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PhotonBaseUITableView : UITableView
- (void)reloadDataWithoutScrollToTop;
- (void)scrollToBottomWithAnimation:(BOOL)animation;
@end

NS_ASSUME_NONNULL_END
