//
//  KCAnnotation.h
//  MapDemo
//
//  Created by Start on 2017/7/19.
//  Copyright © 2017年 het. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface KCAnnotation : NSObject<MKAnnotation>

@property (nonatomic,) CLLocationCoordinate2D coordinate;
@property (nonatomic,  copy, nullable) NSString *title;
@property (nonatomic,  copy, nullable) NSString *subtitle;


/**添加一个图片属性 在创建大头针视图时使用*/
@property(nonatomic,strong)UIImage * _Nonnull image;


/**大头针左侧视图坐标*/
@property(nonatomic,strong)UIImage * _Nonnull icon;
/**大头针详情描述*/
@property(nonatomic,copy)NSString * _Nonnull detail;
/**大头针右下角星级评价*/
@property(nonatomic,strong)UIImage * _Nonnull rate;

@end
