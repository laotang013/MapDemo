//
//  ViewController.m
//  MapDemo
//
//  Created by Start on 2017/7/18.
//  Copyright © 2017年 het. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "KCAnnotation.h"
#import "KCCalloutAnotation.h"
#import "KCCalloutAnnotationView.h"
@interface ViewController ()<CLLocationManagerDelegate,MKMapViewDelegate>
/**定位时间管理类*/
@property(nonatomic,strong)CLLocationManager *locationManager;
/**CLGeocoder*/
@property(nonatomic,strong)CLGeocoder *geocoder;
/**地图控件*/
@property(nonatomic,strong)MKMapView *mapView;
/**Tap方法*/
@property(nonatomic,strong)UITapGestureRecognizer *tapGes;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //案例1
    //[self location];
    //案例2
    //初始化UI
    [self setupSubViews];
    [self drawLine];
    //点击添加大头针
    //[self addAnnotation];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - **************** 初始化控件
-(void)setupSubViews
{
    CGRect rect = [UIScreen mainScreen].bounds;
    self.mapView = [[MKMapView alloc]initWithFrame:rect];
    [self.view addSubview:self.mapView];
    //设置代理
    self.mapView.delegate = self;
    //请求定位服务
    self.locationManager = [[CLLocationManager alloc]init];
    if (![CLLocationManager locationServicesEnabled]||[CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    //设置用户追踪
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
    //设置地图类型
    self.mapView.mapType = MKMapTypeStandard;
    self.geocoder = [[CLGeocoder alloc]init];
    
    //添加大头针
    [self addKCAnnotation:CLLocationCoordinate2DMake(39.95, 116.35) title:@"中国" subTitle:@"北京" image:@"dingweidian_map" icon:@"location_marker" detail:@"北京标题" rate:@"pic_guangdian"];
    [self addKCAnnotation:CLLocationCoordinate2DMake(39.35, 116.35) title:@"美国" subTitle:@"自由女神" image:@"icon_warnning" icon:@"location_marker" detail:@"自由女神标题" rate:@"pic_guangdian1_02"];
}

-(void)addKCAnnotation:(CLLocationCoordinate2D )location2D
                 title:(NSString *)title
              subTitle:(NSString *)subtitle
              image:(NSString *)imageStr
                  icon:(NSString *)iconStr
                detail:(NSString *)detailStr
                  rate:(NSString *)rateStr
{
    KCAnnotation *annotion = [[KCAnnotation alloc]init];
    annotion.coordinate = location2D;
    annotion.title = title;
    annotion.subtitle = subtitle;
    annotion.image = [UIImage imageNamed:imageStr];
    annotion.icon = [UIImage imageNamed:iconStr];
    annotion.detail = detailStr;
    annotion.rate = [UIImage imageNamed:rateStr];
    [self.mapView addAnnotation:annotion];
    
}

#pragma mark - **************** 定位
-(void)location
{
    //1.初始化定位管理
    self.locationManager = [[CLLocationManager alloc]init];
    //1.1 判断是否启用定位服务了
    if (![self.locationManager locationServicesEnabled]) {
        NSLog(@"定位服务没有打开,请打开定位服务");
        return ;
    }
    //1.2 判断用户有没有授权 kCLAuthorizationStatusNotDetermined 用户已经明确禁止使用定位服务
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
        //使用此应用时允许访问用户定位
    }else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse)
    {
        //1.3设置代理 设置精度 设置定位频率 启动跟踪定位
        self.locationManager.delegate = self;
        //精确定位
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        CLLocationDistance distance = 10.0;//位置更新的最小距离 只有移动大于这个距离才更新位置信息,默认为kCLDistanceFilterNone：不进行距离限制
        self.locationManager.distanceFilter = distance;
        //开始定位追踪,开始定位后按照用户设置的更新频率执行
        [self.locationManager startUpdatingLocation];
        
    }

    //2.0 CGGeocoder
    self.geocoder = [[CLGeocoder alloc]init];
    [self getCoordinateByAddress:@"北京"];

}



#pragma mark - **************** 代理方法
//反馈定位信息
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *location = [locations firstObject];
    //返回当前坐标的位置
    CLLocationCoordinate2D coordinate = location.coordinate;
    NSLog(@"经度 %f 纬度 %f",coordinate.longitude,coordinate.latitude);
    //如果不需要实时定位，使用完毕则可以关闭定位服务
   // [_locationManager stopUpdatingLocation];
    [self getAddressFromLocation:location];
    
}

#pragma mark - **************** 地理方法

//地理编码 根据地名获取地理坐标
-(void)getCoordinateByAddress:(NSString *)addressStr
{
    [self.geocoder geocodeAddressString:addressStr completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        //定位框架中地标类，封装了详细的地理信息。
        CLPlacemark *placeMark = [placemarks firstObject];
        CLLocation *location = placeMark.location;
        CLLocationCoordinate2D coordinate = location.coordinate;
        NSLog(@"经度 %f 纬度 %f",coordinate.longitude,coordinate.latitude);
    }];
}



//反地理编码 根据经纬度获取位置信息
-(void)getAddressFromLocation:(CLLocation *)location
{
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        //NSLog(@"%@",placemarks);
        CLPlacemark *placeMark  = [placemarks firstObject];
        NSLog(@"详细信息: %@",placeMark.addressDictionary);
    }];
}

#pragma mark - **************** mapKit
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(nonnull MKUserLocation *)userLocation
{
    // 设置地图显示范围(如果不进行区域设置会自动显示区域范围并指定当前用户位置为地图中心点)
    //MKCoordinateSpan span=MKCoordinateSpanMake(0.01, 0.01);
   //MKCoordinateRegion region=MKCoordinateRegionMake(userLocation.location.coordinate, span);
    //[_mapView setRegion:region animated:true];
    
    NSLog(@"userLocation:%@",userLocation);
    [self getAddressFromLocation:userLocation.location];
}

//自定义大头针 显示大头针时触发，返回大头针视图
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    //由于当前位置的标注也是一个大头针，所以此时需要判断,此代理方法返回nil返回默认的大头针
    if ([annotation isKindOfClass:[KCAnnotation class]]) {
        static NSString *key1 = @"AnnotationKey1";
        MKAnnotationView *annottationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:key1];
        if (!annottationView) {
            annottationView = [[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:key1];
            //annottationView.canShowCallout = true;//允许交互点击
            //定义详情视图偏移量
            annottationView.calloutOffset = CGPointMake(0, 1);
            annottationView.leftCalloutAccessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"location_marker"]];//定义详情左视图
        }
        annottationView.annotation = annotation;
        //设置大头针的图片
        annottationView.image = ((KCAnnotation *)annotation).image;
        return annottationView;
    }else if ([annotation isKindOfClass:[KCCalloutAnotation class]])
    {
        KCCalloutAnnotationView *calloutView = [KCCalloutAnnotationView calloutViewWithMapView:mapView];
        calloutView.annotation = annotation;
        //calloutView.canShowCallout = true;
        return calloutView;
    }
    else
    {
        return nil;
    }
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    KCAnnotation *annotation = view.annotation;
    if ([view.annotation isKindOfClass:[KCAnnotation class]]) {
        KCCalloutAnotation *annotation1 = [[KCCalloutAnotation alloc]init];
        annotation1.icon = annotation.icon;
        annotation1.detail = annotation.detail;
        annotation1.rate = annotation.rate;
        annotation1.coordinate = annotation.coordinate;
        [mapView addAnnotation:annotation1];
    }
}

#pragma mark 取消选中时触发
-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view{
    [self removeCustomAnnotation];
}

#pragma mark 移除所用自定义大头针
-(void)removeCustomAnnotation{
    [_mapView.annotations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[KCCalloutAnotation class]]) {
            [_mapView removeAnnotation:obj];
        }
    }];
}
/*
 //自定义大头针 显示大头针时触发，返回大头针视图
 -(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
 {
 //由于当前位置的标注也是一个大头针，所以此时需要判断,此代理方法返回nil返回默认的大头针
 if ([annotation isKindOfClass:[KCAnnotation class]]) {
 static NSString *key1 = @"AnnotationKey1";
 MKAnnotationView *annottationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:key1];
 if (!annottationView) {
 annottationView = [[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:key1];
 annottationView.canShowCallout = true;//允许交互点击
 //定义详情视图偏移量
 annottationView.calloutOffset = CGPointMake(0, 1);
 annottationView.leftCalloutAccessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"location_marker"]];//定义详情左视图
 }
 annottationView.annotation = annotation;
 //设置大头针的图片
 annottationView.image = ((KCAnnotation *)annotation).image;
 return annottationView;
 }else
 {
 return nil;
 }
 }

 */


#pragma mark - **************** 划线
-(void)drawLine
{
    //http://blog.csdn.net/u012701023/article/details/48832385
    //思路: 1.首先需要获取到两个位置 起点和终点的经纬度 2.给出起点和终点的详细信息 3.包装起点的节点和终点的节点 4.进行路线请求 5.发送请求 6.计算 7.要实现系统的代理方法 画线条
    
    CLLocationCoordinate2D start = {39.95, 116.35};
    CLLocationCoordinate2D end = {39.35, 116.35};
    //起点和终点的详细信息
    MKPlacemark *startPlace = [[MKPlacemark alloc]initWithCoordinate:start];
    MKPlacemark *endPlace =[[MKPlacemark alloc]initWithCoordinate:end];
    //起点 终点的节点
    MKMapItem *startItem = [[MKMapItem alloc]initWithPlacemark:startPlace];
    MKMapItem *endItem = [[MKMapItem alloc]initWithPlacemark:endPlace];
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc]init];
    request.source = startItem;
    request.destination = endItem;
    MKDirections *directions = [[MKDirections alloc]initWithRequest:request];
    __block NSInteger sumDistance = 0;
    //计算
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            //取出一条路线
            MKRoute *route = response.routes[0];
            //关键节点
            for (MKRouteStep *step in route.steps) {
                
                //大头针
//                MKPointAnnotation *annotation = [[MKPointAnnotation alloc]init];
//                annotation.coordinate = step.polyline.coordinate;
//                annotation.title = step.polyline.title;
//                annotation.subtitle = step.polyline.subtitle;
//                
//                
//                //添加大头针
//                [self.mapView addAnnotation:annotation];
                //添加路线 让我们可以在地图上放一层遮罩，如果要放一组遮罩，可以用addOverlays
                //只接受坐标相关的方法,而轨迹渐变自然要通过速度控制。但传不进去，所以重写一个实现MKOverlay协议的类
                [self.mapView addOverlay:step.polyline];
                sumDistance += step.distance;
            }
            NSLog(@"总距离:%ld",sumDistance);
        }
    }];
}
//划线的代理方法
-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *polylineRender = [[MKPolylineRenderer alloc]initWithPolyline:overlay];
        polylineRender.strokeColor = [UIColor redColor];
        polylineRender.lineWidth = 5;
        return polylineRender;
    }else
    {
        return nil;
    }

}
#pragma mark - **************** 点击添加大头针
-(void)addAnnotation
{
    //思路: 1.将获取的point转换为经纬度 2.添加大头针
    self.tapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(addAnnotation:)];
    [self.mapView addGestureRecognizer:self.tapGes];
}
-(void)addAnnotation:(UITapGestureRecognizer *)tapGes
{
    //获取点击是的位置
    CGPoint touchPoint = [tapGes locationInView:self.mapView];
    //获取经纬度
    CLLocationCoordinate2D touchMap = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc]init];
    annotation.coordinate = touchMap;
    [self.mapView addAnnotation:annotation];
}


#pragma mark - **************** 注释
/*
 http://www.cnblogs.com/kenshincui/p/4125570.html
  1.定位
     CoreLocation进行定位，Colocation可以单独进行使用,和MapKit完全是独立的。
     其中主要包括了定位、地理编码(包括反编码)
   1.1 实现定位的变化使用CLLocationManager类
      首先需要在info.plist配置中进行配置
         requestAlwaysAuthorization 请求获得应用一直使用定位服务授权，
         requestWhenInUseAuthorization 请求获得应用使用时的定位服务授权。
         如果不进行配置则默认情况下应用无法使用定位服务。
   1.2 定位成功后会根据情况频繁调用-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations方法,这个方法返回一组地理位置对象数组每个元素一个CLLocation代表地址位置之所以返回数组是因为有些时候一个位置点可能包含多个位置
  2. 地理编码 CLGeocoder
       2.1 定位服务还包含CLGeocoder类用于处理地理编码和逆地理编码(反地理编码)
           地理编码:根据给定的位置(通常是地名)确定地理坐标(经纬度)
           逆地理编码:可以根据地理坐标(经纬度)确定位置信息、
  3.地图
     两种方式：一种直接利用Mapkit框架进行地图开发，利用这种方式可以对地图进行精准的控制。另一种方式直接调用
             苹果官方自带的地图应用，主要用于一些简单的地图应用无法进行精确的控制。
       3.1 MapKit:
         地图展示控件MKMapView
         - (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation;用户位置发生改变时触发(第一次定位到用户位置时也触发该方法); 调用频率相当频繁
      3.2:大头针：只要一个NSObject类实现MKAnnotation协议就可以作为一个大头针，通过会重写协议
                 coordinate（标记位置）、title（标题）、subtitle（子标题）三个属性
        3.3 自定义大头针视图:
             - (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation;方法可以返回一个大头针视图，只要实现这个方法并在这个方法中定义一个大头针视图MKAnnotationView对象并设置相关属性就可以改变默认大头针的样式。
         3.4自定义大头针
             自定义大头针设置大头针模型布局界面时,此时需要注意新增大头针的位置通常需要偏移一定距离才能达到理想的效果。
 
       修改大头针详情视图:
            1.点击一个大头针A时重新在A的坐标处添加另一个大头针B作为详情模型(注意此时将A对应的大头针视图canShowCallout设置为false)然后在- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation;代理方法中判断大头针类型，如果是B则重写MKAnnotationView(可以自定义一个类C继承与MKAnnotationView)返回大头针B.
           2.定义一个大头针视图C继承与MKAnnotationView在自定义大头针视图中添加自己的控件，完成自定义布局.
 
 CLLocation：用于表示位置信息，包含地理坐标、海拔等信息，包含在CoreLoaction框架中。
 
 MKUserLocation：一个特殊的大头针，表示用户当前位置。
 
 CLPlacemark：定位框架中地标类，封装了详细的地理信息。
 
 MKPlacemark：类似于CLPlacemark，只是它在MapKit框架中，可以根据CLPlacemark创建MKPlacemark
    
   4.地图路线：
 
 */

















@end
