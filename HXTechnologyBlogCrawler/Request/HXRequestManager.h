//
//  HXRequestManager.h
//  HXTechnologyBlogCrawler
//
//  Created by 黄轩 on 16/8/20.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HXRequestManager : NSObject

- (void)request:(NSString *)key page:(NSInteger)page complete:(void(^)(NSArray *dataAry))complete;

@end
