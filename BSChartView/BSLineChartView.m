//
//  BSLineChartView.m
//

#import "BSLineChartView.h"

#define kAnimationTime 1.5

struct ValueRange {
    CGFloat minValue;
    CGFloat maxValue;
};
typedef struct ValueRange ValueRange;


@interface BSLineChartView ()

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) NSArray *titleArray;
@property (strong, nonatomic) NSArray *lineValuesArray;
@property (strong, nonatomic) NSArray *barValuesArray;
@property (strong, nonatomic) NSArray *colorsArray;
@property (assign, nonatomic) CGFloat originWidth;
@property (assign, nonatomic) CGFloat lineMaxValue;
@property (assign, nonatomic) CGFloat lineMinValue;
@property (assign, nonatomic) CGFloat barMaxValue;
@property (assign, nonatomic) CGFloat barMinValue;

@end

@implementation BSLineChartView{
    NSMutableArray *arrMTag;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        self.originWidth = 40;        
    }
    return self;
}

- (void)setDataSource:(id<LineChartViewDataSource>)dataSource
{
    _dataSource = dataSource;
    
    // 1.初始化数据源
    [self initArray];
    
    // 2.初始化 scrollView
    [self initScrollView];
    
    // 3.画横线和竖线
    [self drawHorizontalLine];
    if (self.displayVerticalLine) {
        [self drawVerticalLine];
    }
    
    // 4.底部 title
    if (self.titleArray.count > 0)
    {
        [self drawBottomTitle];
    }
    
    // 5.折线图
    if (self.lineValuesArray.count > 0)
    {
        [self drawLineYTextLayer];
        [self drawValueLineLayer];
    }
    
    // 6.条形图
    if (self.barValuesArray.count > 0)
    {
        [self drawBarYTextLayer];
        [self drawValueBarLayer];
    }
}

- (void)initArray
{
    if ([self.dataSource respondsToSelector:@selector(lineValuesArrayOfLineChartView:)]) {
        self.lineValuesArray = [self.dataSource lineValuesArrayOfLineChartView:self];
    }
    if ([self.dataSource respondsToSelector:@selector(titlesArrayOfLineChartView:)]) {
        self.titleArray = [self.dataSource titlesArrayOfLineChartView:self];
    }
    if ([self.dataSource respondsToSelector:@selector(barValuesArrayOfLineChartView:)]) {
        self.barValuesArray = [self.dataSource barValuesArrayOfLineChartView:self];
    }
    if ([self.dataSource respondsToSelector:@selector(colorsArrayOfLineChartView:)]) {
        self.colorsArray = [self.dataSource colorsArrayOfLineChartView:self];
    }
}

- (void)initScrollView
{
    CGFloat leftInsert = self.lineValuesArray.count > 0 ? self.originWidth : 0;
    CGFloat rightInsert = self.barValuesArray.count > 0 ? self.originWidth : 0;
    
    self.scrollView = ({
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(leftInsert, 0, self.frame.size.width - leftInsert - rightInsert, self.frame.size.height)];
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.contentSize = CGSizeMake((self.titleArray.count + 1) * self.originWidth, self.scrollView.frame.size.height);
        [self addSubview:scrollView];
        scrollView;
    });
    
    [UIView animateWithDuration:kAnimationTime
                     animations:^{
                         self.scrollView.contentOffset = CGPointMake((self.titleArray.count + 1) * self.originWidth - self.scrollView.frame.size.width, 0);
                     }];
}

#pragma mark - HorizontalLine, VerticalLine, BottomTitle

//画横线
- (void)drawHorizontalLine
{
    CGFloat originHeight = self.scrollView.frame.size.height / 5;
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    for (int i=0; i<5; i++)
    {
        [path moveToPoint:CGPointMake(self.originWidth * 0.5, i*originHeight + 0.5 * originHeight)];
        [path addLineToPoint:CGPointMake(self.originWidth * 0.5 + self.originWidth * self.titleArray.count, i*originHeight  + 0.5 * originHeight)];
    }
    [self createLayerWith:path fillColor:[UIColor clearColor] strokeColor:[[UIColor blackColor]colorWithAlphaComponent:0.1] lineWidth:0.5 isData:NO];
}

//画竖线
- (void)drawVerticalLine
{
    CGFloat originHeight = self.scrollView.frame.size.height / 5;
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    for (int i=0; i<self.titleArray.count; i++)
    {
        [path moveToPoint:CGPointMake(self.originWidth + self.originWidth * i, 0.5 * originHeight)];
        [path addLineToPoint:CGPointMake(self.originWidth + self.originWidth * i, 4*originHeight + 0.5 * originHeight)];
    }
    [self createLayerWith:path fillColor:[UIColor clearColor] strokeColor:[[UIColor blackColor]colorWithAlphaComponent:0.1] lineWidth:0.5 isData:NO];
}

- (void)drawBottomTitle
{
    int fontSize = 12;
    if (self.fontSize) {
        fontSize = self.fontSize.intValue;
    }
    for (int i = 0; i < self.titleArray.count; i++)
    {
        [self createTextLayerWith:CGRectMake(self.originWidth * 0.5 + self.originWidth * i, self.scrollView.frame.size.height - 14, self.originWidth, 14)
                           string:self.titleArray[i]
                        textColor:[UIColor grayColor]
                        alignment:kCAGravityCenter
                         fontSize:fontSize
                       superLayer:self.scrollView.layer];
    }
}

#pragma mark - LineView
- (void)drawLineYTextLayer
{
    NSMutableArray *yArray = [NSMutableArray array];
    for (NSArray *array in self.lineValuesArray) {
        [yArray addObjectsFromArray:array];
    }
    
    ValueRange range = [self getValueRangeWith:yArray];
    CGFloat max = range.maxValue + self.YScaleAdapt;
    CGFloat min = range.minValue - self.YScaleAdapt;
    CGFloat orginaNum = (max-min)/4;
    
    CGFloat originHeight = self.scrollView.frame.size.height / 5.0;
    
    UIColor *colorText = [UIColor grayColor];
    if (self.YTextColor) {
        colorText = self.YTextColor;
    }
    
    int fontSize = 12;
    if (self.fontSize) {
        fontSize = self.fontSize.intValue;
    }
    
    
    for (int i = 0; i < 5; i ++)
    {
        [self createTextLayerWith:CGRectMake(0, 0.5 * originHeight + originHeight * i - 7, self.originWidth, 14)
                           string:[NSString stringWithFormat:@"%.0f", max - orginaNum * i]
                        textColor:colorText
                        alignment:kCAGravityCenter
                         fontSize:fontSize
                       superLayer:self.layer];
    }
    
    _lineMaxValue = max;
    _lineMinValue = max - orginaNum * 4;
}

- (void)drawValueLineLayer
{
    CGFloat originHeight = self.scrollView.frame.size.height / 5;
    NSArray *colorArray = self.colorsArray.firstObject;
    for (int n = 0; n < self.lineValuesArray.count; n++)
    {
        UIBezierPath *lineBezierPath = [UIBezierPath bezierPath];
        UIBezierPath *pointBezierPath = [UIBezierPath bezierPath];
        
        NSArray *valueArray = self.lineValuesArray[n];
        
        UIColor *color = [UIColor lightGrayColor];
        if (colorArray.count > n) {
            color = [colorArray objectAtIndex:n];
        }
        
        for (int i = 0; i < self.titleArray.count; i++)
        {
            if (valueArray.count < i || [valueArray[i] isEqualToString:LineValueEmpty]) {
                continue;
            }
            
            CGFloat value = [valueArray[i] floatValue];
            CGFloat scale = (value - _lineMinValue) / (_lineMaxValue - _lineMinValue);
            CGFloat y = (1-scale) * originHeight * 4 + originHeight * 0.5;
            CGPoint point = CGPointMake(self.originWidth * (1+i), y);
            
            // 画出 value 点
            [pointBezierPath moveToPoint:point];
            [pointBezierPath addArcWithCenter:point radius:1.5 startAngle:-M_PI_2 endAngle:3*M_PI_2 clockwise:YES];
            
            // 连线
            if (i == 0) {
                [lineBezierPath moveToPoint:point];
            } else {
                [lineBezierPath addLineToPoint:point];
            }
        }
        
        [self createLayerWith:pointBezierPath fillColor:color strokeColor:color lineWidth:3 isData:YES];
        
        CAShapeLayer *shapeLayer = [self createLayerWith:lineBezierPath fillColor:[UIColor clearColor] strokeColor:color lineWidth:1 isData:YES];
        [self addBasicAnimationForLayer:shapeLayer];
    }
}

#pragma mark - BarView
- (void)drawBarYTextLayer
{
    ValueRange range = [self getValueRangeWith:self.barValuesArray];
    CGFloat max = range.maxValue + self.YScaleAdapt;
    CGFloat min = range.minValue - self.YScaleAdapt;
    CGFloat orginaNum = (max-min)/4;
    
    CGFloat originHeight = self.scrollView.frame.size.height / 5;
    for (int i = 0; i < 5; i ++)
    {
        [self createTextLayerWith:CGRectMake(self.frame.size.width - self.originWidth, 0.5 * originHeight + originHeight * i - 7, self.originWidth, 14)
                           string:[NSString stringWithFormat:@"%.1f", max - orginaNum * i]
                        textColor:[UIColor grayColor]
                        alignment:kCAGravityCenter
                         fontSize:12
                       superLayer:self.layer];
    }
    
    _barMaxValue = max;
    _barMinValue = max - orginaNum * 4;
}

- (void)drawValueBarLayer
{
    CGFloat originHeight = self.scrollView.frame.size.height / 5;
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    
    for (int i = 0; i < self.titleArray.count; i++)
    {
        if (self.barValuesArray.count < i || [self.barValuesArray[i] isEqualToString:LineValueEmpty]) {
            continue;
        }
        CGFloat value = [self.barValuesArray[i] floatValue];
        CGFloat scale = (value - _barMinValue) / (_barMaxValue - _barMinValue);
        CGFloat y = (1-scale) * originHeight * 4 + originHeight * 0.5;
        CGPoint point1 = CGPointMake(self.originWidth * (1+i), 4.5 * originHeight);
        CGPoint point2 = CGPointMake(self.originWidth * (1+i), y);
        
        [bezierPath moveToPoint:point1];
        [bezierPath addLineToPoint:point2];
    }
    
    UIColor *color = [UIColor lightGrayColor];
    if (self.colorsArray.count > 1) {
        color = self.colorsArray.lastObject;
    }
    
    CAShapeLayer *shapeLayer = [self createLayerWith:bezierPath
                                           fillColor:[UIColor clearColor]
                                         strokeColor:[color colorWithAlphaComponent:0.5]
                                           lineWidth:self.originWidth/2 isData:YES];
    
    [self addBasicAnimationForLayer:shapeLayer];
    
}

- (void)addBasicAnimationForLayer:(CAShapeLayer *)layer
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration = kAnimationTime;
    animation.repeatCount = 1;
    animation.fromValue = @(0);
    animation.toValue = @(1);
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    [layer addAnimation:animation forKey:nil];
}

- (CAShapeLayer *)createLayerWith:(UIBezierPath *)path fillColor:(UIColor *)fillColor strokeColor:(UIColor *)strokeColor lineWidth:(CGFloat)lineWidth isData:(BOOL)isData
{
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path.CGPath;
    shapeLayer.strokeColor = [strokeColor CGColor];
    shapeLayer.fillColor = [fillColor CGColor];
    shapeLayer.lineWidth = lineWidth;
    
    if (isData) {
        if (arrMTag == nil) {
            arrMTag = [NSMutableArray array];
        }
        [arrMTag addObject:shapeLayer];
    }
    
    [self.scrollView.layer addSublayer:shapeLayer];
    return shapeLayer;
}

- (CATextLayer *)createTextLayerWith:(CGRect)frame string:(NSString *)string textColor:(UIColor *)textColor alignment:(NSString *)alignment fontSize:(CGFloat)fontSize superLayer:(CALayer *)superLayer
{
    CATextLayer *textLayer = [CATextLayer layer];
    textLayer.frame = frame;
    textLayer.foregroundColor = textColor.CGColor;
    textLayer.alignmentMode = alignment;
    textLayer.fontSize = fontSize;
    textLayer.string = string;
    if (!self.isTextVague) {
        textLayer.contentsScale = [UIScreen mainScreen].scale;
    }
    [superLayer addSublayer:textLayer];
    
    if (self.fontName) {
        textLayer.font = (__bridge CFTypeRef)self.fontName;
    }

    return textLayer;
}

- (ValueRange)getValueRangeWith:(NSArray *)valuesArray
{
    ValueRange range = {[valuesArray[0] floatValue],[valuesArray[0]floatValue]};
    for (int i = 0; i < valuesArray.count; i++)
    {
        CGFloat num = [valuesArray[i] floatValue];
        if (num > range.maxValue) {
            range.maxValue = num;
        }
        if (num < range.minValue) {
            range.minValue = num;
        }
    }
    return range;
}

- (void)refreshAllData{
    [arrMTag enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CALayer *layer = obj;
        [layer removeFromSuperlayer];
        obj = nil;
    }];
    arrMTag = nil;
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    
    [self initArray];
    [self drawValueLineLayer];
    [self drawValueBarLayer];
}
@end


















