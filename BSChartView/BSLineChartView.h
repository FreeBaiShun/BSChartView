//
//  BSLineChartView.h
//

#import <UIKit/UIKit.h>
@class BSLineChartView;

#define LineValueEmpty @"LineValueEmpty"

@protocol LineChartViewDataSource <NSObject>

@required
// 底部标题
- (NSArray *)titlesArrayOfLineChartView:(BSLineChartView *)lineChartView;

@optional
// 折线图数据源
- (NSArray *)lineValuesArrayOfLineChartView:(BSLineChartView *)lineChartView;
- (NSArray *)barValuesArrayOfLineChartView:(BSLineChartView *)lineChartView;
- (NSArray *)colorsArrayOfLineChartView:(BSLineChartView *)lineChartView;

@end

@interface BSLineChartView : UIView

@property (assign, nonatomic) id <LineChartViewDataSource> dataSource;

//下面是可选配置
/** 是否显示竖线（默认不显示）*/
@property (assign, nonatomic) BOOL displayVerticalLine;
/** Y轴刻度值自动适应值 （默认是0） */
@property (assign, nonatomic) CGFloat YScaleAdapt;


/**
 重新刷新数据(当数据源被重新赋值后调用此方法可以重新刷新数据)
 */
- (void)refreshAllData;
@end
