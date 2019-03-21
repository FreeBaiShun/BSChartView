# BSChartView
1. 一个支持画折线图，柱状图，圆饼图的工具
2. 支持双Y轴显示，支持左右滑动，支持自定义样式。

# 效果
![image](https://github.com/FreeBaiShun/BSChartView/blob/master/BSChartView.gif)
gitHub地址：https://github.com/FreeBaiShun/BSChartView


# 用法
类似于tableView的使用
```

//
//  ViewController.m
//
//  Created by BS on 2019/8/25.
//  Copyright © 2019年 BS. All rights reserved.
//

#import "ViewController.h"
#import "BSLineChartView.h"
#import "BSPieChartView.h"

#define HEX_COLOR(hex)  [UIColor colorWithRed:((float)((hex &0xFF0000)>>16))/255.0 green:((float)((hex &0xFF00)>>8))/255.0 blue:((float)(hex &0xFF))/255.0 alpha:1] ///分类中已此宏

@interface ViewController ()<LineChartViewDataSource, PieChartViewDataSource>
@property (copy, nonatomic) NSMutableArray *arrMX;//x轴坐标数据
@property (copy, nonatomic) NSMutableArray *arrMData;//y左轴折线图数据1
@property (copy, nonatomic) NSMutableArray *arrMData1;//y左轴折线图数据2
@property (copy, nonatomic) NSMutableArray *arrMColumn;//y右轴柱状图数据

@property (copy, nonatomic) NSMutableArray *arrMPieData;//圆饼图的数据源
@property (copy, nonatomic) NSMutableArray *arrMPieTitles;//圆饼图的标题数据源
@property (copy, nonatomic) NSMutableArray *arrMPieDataChange;//圆饼图的替换数据源
@property (copy, nonatomic) NSMutableArray *arrMPieTitlesChange;//圆饼图的替换标题数据源

@property (strong, nonatomic) UIButton *btnRefresh;
@end

@implementation ViewController{
BSLineChartView *lineChartView;
int count;
BSPieChartView *chartView;
NSArray *arrPieData;
NSArray *arrPieTitleData;
}

//懒加载数据源
- (NSMutableArray *)arrMX{
if (_arrMX == nil) {
_arrMX = [NSMutableArray array];
for (int i = 1; i <= 30; i++) {
[_arrMX addObject:[NSString stringWithFormat:@"11-%d",i]];
}
}
return _arrMX;
}

- (NSMutableArray *)arrMData{
if (_arrMData == nil) {
_arrMData = [NSMutableArray array];
for (int i = 1; i <= 30; i++) {
if (i %2 == 0) {
[_arrMData addObject:@"200"];
}else{
[_arrMData addObject:@"100"];
}
}
}
return _arrMData;
}

- (NSMutableArray *)arrMData1{
if (_arrMData1 == nil) {
_arrMData1 = [NSMutableArray array];
for (int i = 1; i <= 30; i++) {
if (i %2 == 0) {
[_arrMData1 addObject:@"100"];
}else{
[_arrMData1 addObject:@"200"];
}
}
}
return _arrMData1;
}

- (NSMutableArray *)arrMColumn{
if (_arrMColumn == nil) {
_arrMColumn = [NSMutableArray array];
for (int i = 1; i <= 30; i++) {
if (i %2 == 0) {
[_arrMColumn addObject:@"150"];
}else{
[_arrMColumn addObject:@"250"];
}
}
}
return _arrMColumn;
}

- (NSMutableArray *)arrMPieData{
if (_arrMPieData == nil) {
_arrMPieData = [NSMutableArray arrayWithArray:@[@(0.1), @(0.25), @(0.2), @(0.1), @(0.15), @(0.2)]];
}
return _arrMPieData;
}

- (NSMutableArray *)arrMPieTitles{
if (_arrMPieTitles == nil) {
_arrMPieTitles = [NSMutableArray arrayWithArray:@[@"10.00%\n400人",@"25.00%\n400人",@"20.00%\n400人",@"10.00%\n400人",@"15.00%\n400人",@"20.00%\n400人"]];
}
return _arrMPieTitles;
}

- (NSMutableArray *)arrMPieDataChange{
if (_arrMPieDataChange == nil) {
_arrMPieDataChange = [NSMutableArray arrayWithArray:@[@(0.2), @(0.15), @(0.1), @(0.2), @(0.25), @(0.1)]];
}
return _arrMPieDataChange;
}

- (NSMutableArray *)arrMPieTitlesChange{
if (_arrMPieTitlesChange == nil) {
_arrMPieTitlesChange = [NSMutableArray arrayWithArray:@[@"20.00%\n100人",@"15.00%\n100人",@"10.00%\n100人",@"20.00%\n100人",@"25.00%\n100人",@"10.00%\n100人"]];
}
return _arrMPieTitlesChange;
}

- (void)viewDidLoad {
[super viewDidLoad];

arrPieData = self.arrMPieData;
arrPieTitleData = self.arrMPieTitles;
self.view.backgroundColor = [UIColor whiteColor];

//折线图,柱形图(可以支持双Y轴，一个折线图的Y轴，一个柱形Y轴)
lineChartView = [[BSLineChartView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/2-64)];

//可选配置(要在dataSource之前配置才会生效)
lineChartView.displayVerticalLine = NO;//显示竖线
lineChartView.YScaleAdapt = 50;//y轴刻度值自动适应值是50（就是最大数据值+50，最小数据值-50）

lineChartView.dataSource = self;
[self.view addSubview:lineChartView];

//圆饼图
chartView = [[BSPieChartView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/2-64, self.view.frame.size.width, self.view.frame.size.height/2-64)];
chartView.dataSource = self;
[self.view addSubview:chartView];

//重新刷新数据
self.btnRefresh = [[UIButton alloc] initWithFrame:CGRectMake(50, self.view.frame.size.height - 100, 80, 50)];
[self.btnRefresh setBackgroundColor:[UIColor blueColor]];
[self.btnRefresh setTitle:@"刷新数据" forState:UIControlStateNormal];
[self.btnRefresh addTarget:self action:@selector(btnRefreshClick) forControlEvents:UIControlEventTouchUpInside];
[self.view addSubview:self.btnRefresh];
}

#pragma mark - LineChartViewDataSource
- (NSArray *)titlesArrayOfLineChartView:(BSLineChartView *)lineChartView
{
return self.arrMX;
}
- (NSArray *)lineValuesArrayOfLineChartView:(BSLineChartView *)lineChartView
{
return @[self.arrMData];
}
- (NSArray *)barValuesArrayOfLineChartView:(BSLineChartView *)lineChartView
{
return self.arrMColumn;
}
- (NSArray *)colorsArrayOfLineChartView:(BSPieChartView *)pieChartView
{
return @[@[[UIColor redColor], [UIColor greenColor]],
[UIColor lightGrayColor]];
}


#pragma mark - PieChartViewDataSource
- (CGFloat)radiusOfPieChartView:(BSPieChartView *)pieChartView
{
return self.view.bounds.size.width/5;
}
- (NSArray *)valuseArrayOfPieChartView:(BSPieChartView *)pieChartView
{
return arrPieData;
}
- (NSArray *)colorsArrayOfPieChartView:(BSPieChartView *)pieChartView
{
return @[HEX_COLOR(0xd32f35), HEX_COLOR(0xe653f1), HEX_COLOR(0xa46b3e), HEX_COLOR(0x2f4567), HEX_COLOR(0xaa4111), HEX_COLOR(0xd11111)];
}
//自定义标题（可选协议）
- (NSArray *)valuesTitlesChartView:(BSPieChartView *)pieChartView{
return arrPieTitleData;
}

#pragma mark - 刷新数据按钮被点击
- (void)btnRefreshClick{
count ++;
if (count %2 == 0) {
self.arrMData = self.arrMData1;
arrPieData = self.arrMPieData;
arrPieTitleData = self.arrMPieTitles;
}else{
self.arrMData = self.arrMColumn;
arrPieData = self.arrMPieDataChange;
arrPieTitleData = self.arrMPieTitlesChange;
}

[lineChartView refreshAllData];
[chartView refreshAllData];
}
@end
```

