//
//  BSPieChartView.h
//

#import <UIKit/UIKit.h>

@class BSPieChartView;

@protocol PieChartViewDataSource <NSObject>

@required
- (CGFloat)radiusOfPieChartView:(BSPieChartView *)pieChartView;
- (NSArray *)valuseArrayOfPieChartView:(BSPieChartView *)pieChartView;
- (NSArray *)colorsArrayOfPieChartView:(BSPieChartView *)pieChartView;

@optional
- (NSArray *)valuesTitlesChartView:(BSPieChartView *)pieChartView;
@end

@interface BSPieChartView : UIView

@property (assign, nonatomic) id <PieChartViewDataSource>dataSource;

/** 能否点击 (默认不能) */
@property (assign, nonatomic) BOOL *canTouch;
/** 文字是否是模糊效果 (默认不模糊)*/
@property (assign, nonatomic) BOOL isTextVague;

/** 重新刷新数据(当数据源被重新赋值后调用此方法可以重新刷新数据) */
- (void)refreshAllData;
@end
