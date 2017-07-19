//
//  KCCalloutAnnotationView.m
//  MapDemo
//
//  Created by Start on 2017/7/19.
//  Copyright © 2017年 het. All rights reserved.
//

#import "KCCalloutAnnotationView.h"
#define kSpaceing 5
#define kDetailFontSize 12
#define kViewOffset 80


@interface KCCalloutAnnotationView()
/**背景*/
@property(nonatomic,strong)UIView *backgroundView;
/**左侧icon*/
@property(nonatomic,strong)UIImageView *iconView;
/**标题*/
@property(nonatomic,strong)UILabel *detailLabel;
/**底部图片*/
@property(nonatomic,strong)UIImageView *rateView;
@end
@implementation KCCalloutAnnotationView
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

-(void)setupSubViews
{
    //1.继承MKAnnotationView 2.自定义控件
    //添加视图
    [self addSubview:self.backgroundView];
    [self addSubview:self.iconView];
    [self addSubview:self.detailLabel];
    [self addSubview:self.rateView];
}

+(instancetype)calloutViewWithMapView:(MKMapView *)mapView
{
    static NSString *calloutKey = @"calloutKey1";
    KCCalloutAnnotationView *calloutView = (KCCalloutAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:calloutKey];
    if (!calloutView) {
        calloutView = [[KCCalloutAnnotationView alloc]init];
    }
    return calloutView;
}

-(void)prepareForReuse
{
    [super prepareForReuse];
    
}

-(void)setAnnotation:(KCCalloutAnotation *)annotation
{
    [super setAnnotation:annotation];
    //设置frame和数据
    self.iconView.image = annotation.icon;
    self.iconView.frame = CGRectMake(kSpaceing, kSpaceing, annotation.icon.size.width, annotation.icon.size.height);
    //设置detail
    self.detailLabel.text = annotation.detail;
    float detailWidth = 150.0;
    CGSize detailSize = [annotation.detail boundingRectWithSize:CGSizeMake(detailWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:kDetailFontSize]} context:nil].size;
    
    float detailX = CGRectGetMaxX(self.iconView.frame) + kSpaceing;
    self.detailLabel.frame = CGRectMake(detailX, kSpaceing, detailSize.width, detailSize.height);
    //设置星星
    self.rateView.image = annotation.rate;
    self.rateView.frame = CGRectMake(detailX, CGRectGetMaxY(self.detailLabel.frame)+kSpaceing, annotation.rate.size.width, annotation.rate.size.height);
    float backgroundWidth = CGRectGetMaxX(self.detailLabel.frame) + kSpaceing;
    float backgroundHeight = self.iconView.frame.size.height + 2*kSpaceing;
    self.backgroundView.frame = CGRectMake(0, 0, backgroundWidth, backgroundHeight);
    self.bounds = CGRectMake(0, 0, backgroundWidth, backgroundHeight);
}

#pragma mark - **************** 懒加载
-(UIView *)backgroundView
{
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc]init];
        _backgroundView.backgroundColor = [UIColor whiteColor];
    }
    return _backgroundView;
}

-(UIImageView *)iconView
{
    if (!_iconView) {
        _iconView = [[UIImageView alloc]init];
    }
    return _iconView;
}

//上方详情
-(UILabel *)detailLabel
{
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc]init];
        _detailLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _detailLabel.font = [UIFont systemFontOfSize:kDetailFontSize];
    }
    return _detailLabel;
}

-(UIImageView *)rateView
{
    if (!_rateView) {
        _rateView = [[UIImageView alloc]init];
    }
    return _rateView;
}
@end

