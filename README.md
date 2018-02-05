# FSChartView
一款简单的图表库，内含柱状图(垂直&amp;水平)、折线图、饼状图，支持StoryBoard。

## Introduction
柱状图是使用UICollectionView实现，因为UICollectionView自带缓存池，所以选择UICollectionView，里面的很多delegate方法和dataSource方法，看起来很熟悉。折线图和饼状图主要使用CAShapeLayer和UIBezierPath实现。（柱状图写的是最low的，折线图写的是最bad的）
## Overview
![垂直柱状图.gif](https://github.com/Fly-Sunshine-J/FSChartView/blob/master/png/BarChartView_V.gif)

![水平柱状图.gif](https://github.com/Fly-Sunshine-J/FSChartView/blob/master/png/BarChartView_H.gif)

![折线图.gif](https://github.com/Fly-Sunshine-J/FSChartView/blob/master/png/LineChartView.gif)

![饼状图.gif](https://github.com/Fly-Sunshine-J/FSChartView/blob/master/png/PieChartView.gif)

![支持StoryBoard.gif](https://github.com/Fly-Sunshine-J/FSChartView/blob/master/png/StoryBoard.gif)

## List
![目录.png](https://github.com/Fly-Sunshine-J/FSChartView/blob/master/png/目录.png)

## Using CocoaPods

```
target 'projectName' do
use_frameworks!
pod 'FSChartView', '~> 1.0.0'
end

```

#### Tip

如果不能search到，请更新cocoapods库 , `pod setup` 如果还搜索不到，删除~/Library/Caches/CocoaPods目录下的search_index.json文件 再search

## Usage
三种图表的用法都必须遵守dataSource代理，实现对应必须要实现的dataSource方法。用法基本上都很统一，初始化之后设置dataSource和delgate，然后实现该实现的方法就可以。
#### 柱状图
![垂直柱状图.png](https://github.com/Fly-Sunshine-J/FSChartView/blob/master/png/垂直柱状图.png)
![水平柱状图.png](https://github.com/Fly-Sunshine-J/FSChartView/blob/master/png/水平柱状图.png)

```
垂直柱状图
FSBarChartView *chartView = [[FSBarChartView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 200)];
self.chartView = chartView;
[self.chartView registerClass:[FSBarChartViewCell class] forCellWithReuseIdentifier:@"CELL"];
chartView.delegate = self;
chartView.dataSource = self;
[self.view addSubview:chartView];
self.chartView.abscissaAxis.backgroundColor = [UIColor greenColor];

水平柱状图
FSBarChartView *chartView = [[FSBarChartView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 200) orientation:FSBarChartViewOrientationHorizontal];
self.chartView = chartView;
[self.chartView registerClass:[FSBarChartViewCell class] forCellWithReuseIdentifier:@"CELL"];
chartView.delegate = self;
chartView.dataSource = self;
[self.view addSubview:chartView];
```
Note：
- 水平柱状图在实现``- (__kindof FSBarChartViewCell *)barChartView:(FSBarChartView *)chartView cellForItemAtIndexPath:(NSIndexPath *)indexPath``方法的时候注意配置cell的portrait属性为NO
- 垂直柱状图和水平柱状图的数据轴是相反的，垂直柱状图数据轴是横轴，水平柱状图是纵轴，在实现数据源方法的时候注意区分。
- 柱状图两个section之间的间距可以通过代理方法``barChartView:spaceForSection:``进行设置。

#### 折线图
![折线图.png](https://github.com/Fly-Sunshine-J/FSChartView/blob/master/png/折线图.png)

```
FSLineChartView *lineViewChart = [[FSLineChartView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 200)];
self.lineChartView  = lineViewChart;
lineViewChart.delegate = self;
lineViewChart.dataSource = self;
[self.view addSubview:lineViewChart];

```
Note：
- 折线图的每一个点代表一个section，所以数据源方法和代理方法中的section大家不要误解；折线点的计算是通过数据源方法``ineChartView:percentageDataAtIndexPath:``返回的百分比计算的，所以这个百分比需要自己计算。
- 折线图默认的是一条折线，折线的数量可以通过数据源方法``numberOfLineForChartView:``设置。折线的颜色默认是[UIColor colorWithRed:77.0 / 255.0 green:196.0 / 255.0 blue:122.0 / 255.0 alpha:1.0f]；颜色可以通过代理方法``lineChartView:lineColorAtLineIndex:``进行设置。
- 折线的折点默认是没有样式，如果需要设置可以根据代理方法``lineChartView:lineJoinStyleAtIndexPath:``进行设置，折点的颜色可以通过lineChartView:lineJoinColorAtIndexPath:方法设置。

#### 饼状图
![饼状图.png](https://github.com/Fly-Sunshine-J/FSChartView/blob/master/png/饼状图.png)


```
FSPieChartView *pieChartView = [[FSPieChartView alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height + 20, self.view.frame.size.width, height)];
pieChartView.delegate = self;
pieChartView.dataSource = self;
[self.view addSubview:pieChartView];
self.chartView = pieChartView;
```
Note：
- 饼状图需要分成多少份需要通过数据源方法``numberOfSectionForChartView:``返回；每一份的百分比也是需要自己计算，然后可以通过数据源方法``pieChartView: percentageDataForSection:``返回
- 饼状图的内圆大小和颜色也可以通过代理方法进行设置。默认的内圆大小是宽高中比较小的1/6，颜色是和背景色一致的。
- 饼状图的起始角度默认是-M_PI_2，可以通过代理方法设置起始角度。
- 默认的饼状图不能多选，可以设置属性``allowMultiSelected``允许多选，选中再点击就是取消选择，或者点击内圆进行取消选择。

## 总结
虽然自己感觉写的不怎么样，但是也算给自己的一种鼓励。如果你喜欢欢迎在[Github](https://github.com/Fly-Sunshine-J/FSChartView)上star。如果有什么问题，欢迎各位留言。






