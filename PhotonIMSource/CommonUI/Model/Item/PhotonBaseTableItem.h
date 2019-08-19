//
//  PhotonBaseTableItem.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/21.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface PhotonBaseTableItem : NSObject<NSCoding>
/**
 持有的对象，业务层转递
 */
@property (nonatomic, strong, nullable) id userInfo;

/**
 显示内容的大小
 */
@property(nonatomic, assign)CGSize  contentSize;


/**
 计算cell的高度
 */
@property(nonatomic, assign)CGFloat itemHeight;
@end

NS_ASSUME_NONNULL_END
