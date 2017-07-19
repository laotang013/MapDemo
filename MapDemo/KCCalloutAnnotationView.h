//
//  KCCalloutAnnotationView.h
//  MapDemo
//
//  Created by Start on 2017/7/19.
//  Copyright © 2017年 het. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "KCCalloutAnotation.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
@interface KCCalloutAnnotationView : MKAnnotationView
/**大头针*/
@property(nonatomic,strong)KCCalloutAnotation *annotation;
+(instancetype)calloutViewWithMapView:(MKMapView *)mapView;
@end
