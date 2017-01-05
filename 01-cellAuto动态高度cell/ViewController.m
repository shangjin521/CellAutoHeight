//
//  ViewController.m
//  01-cellAuto动态高度cell
//
//  Created by macbook on 15/9/19.
//  Copyright (c) 2015年 macbook. All rights reserved.
//

#import "ViewController.h"
#import "GDataXMLNode.h"
#import "AFNetworking.h"
#import "UIKit+AFNetworking.h"
#import "TweetCell.h"
#import "TweetModel.h"

#define k_width [UIScreen mainScreen].bounds.size.width

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *_dataArr;
    UITableView *_tableView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataArr = [[NSMutableArray alloc] init];
    [self createUI];
    [self startConnection];
}

//- (UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleLightContent;
//}

- (void)createUI{
    CGRect frame = self.view.frame;
//    frame.origin.y += 20;
//    frame.size.height += 20;
    _tableView = [[UITableView alloc] initWithFrame:frame];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    //注册
    [_tableView registerNib:[UINib nibWithNibName:@"TweetCell" bundle:nil] forCellReuseIdentifier:@"cellID"];
}

- (void)startConnection{
    NSString *urlStr = @"http://www.oschina.net/action/api/tweet_list?uid=0&pageIndex=0&pageSize=20";
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    // 返回格式
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    // 显示联网状态
    // [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    //
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation * Operation, id responseObject) {
    // [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    // NSDictionary *dicr = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
    // NSLog(@"%@",dicr);
        [self xml:responseObject];
    // NSLog(@"%@",responseObject);
    }
     
         failure:^(AFHTTPRequestOperation * Operation, NSError * error)
    {
    // [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSLog(@"error");
    }];
}

/*
 IOS学习：常用第三方库（GDataXMLNode：xml解析库）
//http://blog.csdn.net/wu_shu_jun/article/details/8992467
//http://blog.csdn.net/chowpan/article/details/8645224
 */

- (void)xml:(NSData *)data{
    
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:data options:0 error:nil];
    // 据对路径/oschina/tweets/tweet
    //从xml数据转成的 doc 中查询所有的 tweet 节点
    NSArray *tweetArr = [doc nodesForXPath:@"//tweet" error:nil];
    for (GDataXMLElement *tweetEle in tweetArr) {
        
        //将所有的tweet节点信息  转成模型
        
//        TweetModel *model = [[TweetModel alloc] init];
//        model.portrait = [[[tweetEle elementsForName:@"portrait"] lastObject] stringValue];
//        model.author = [[[tweetEle elementsForName:@"author"] lastObject] stringValue];
//        model.body = [[[tweetEle elementsForName:@"body"] lastObject] stringValue];
//        model.imgSmall = [[[tweetEle elementsForName:@"imgSmall"] lastObject] stringValue];
//        model.pubDate = [[[tweetEle elementsForName:@"pubDate"] lastObject] stringValue];
        
        
        //遍历  用这个方法取得所有的子节点值
        TweetModel *model = [[TweetModel alloc] init];
        //遍历tweetEle 里所有的子节点
        for (GDataXMLElement *chiledEle in [tweetEle children]) {
            //kvc赋值 childEle.name 是节点名  在工作中 需要自己去猜  
            [model setValue:chiledEle.stringValue forKey:chiledEle.name];
        }
//        NSLog(@"====%@", model.author);
        //将模型存到数据源里
        [_dataArr addObject:model];
    }
    [_tableView reloadData];
}

#pragma mark - tableview

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //用indexPath 设置对应的cell高度
    //1.根据对应的位置找到对应的模型
    //程序 会先按正常的套路 会先执行有多少组 行高多少 才会去加载数据  这个跟有xib 或者 是否注册相关
    //这个方法最好不用
    // TweetModel *model = (id)[tableView cellForRowAtIndexPath:indexPath];
    TweetModel *model = _dataArr[indexPath.row];
    //注意 高度只跟label有关 其他都是固定的 label是动态的 image需要判断有没有
    
    CGSize size = [model.body boundingRectWithSize:CGSizeMake(k_width - 90, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:14] forKey:NSFontAttributeName] context:nil].size;
    if (model.imgSmall.length) {
        //有图片   60 是 xibl里面 label 的高度
        return 270 -60 +size.height;
    }
//    return 100+arc4random_uniform(200); //100-200随机数
    return 270 - 60 + size.height - 120 -10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID" forIndexPath:indexPath];
    //cell 自适应高度
    //先根据对应的cell找到数据模型model 给cell赋值
    TweetModel *model = [_dataArr objectAtIndex:indexPath.row];
    //sd_setImageWithURL 也是一样的  是SD库里的写法  怕跟系统的冲突了
    [cell.iconView setImageWithURL:[NSURL URLWithString:model.portrait]];
    cell.nameLabel.text = model.author;
    cell.bodyLabel.text = model.body;
    cell.dataLabel.text = model.pubDate;
    //定义自动适应宽度  让无论是那个手机 label跟屏幕右边距离是固定的
    //cell被选中的时候 view的背景色都不显示 注意  cell特性 一般点中就进如下一个界面 所以不用改 也改不了
    //因为 有个原点不用 所以用CGSize
    /**
        计算一个字符串 完整的展示出来需要的size
     
     //计算机计算的也有误差 可能像素高差一点点 高度不够可能就会有省略号 刷新的时候可能会出现 代码没有问题 可能label肯能还是会有省略号  那就在 label的frame的高度加一点点值
     
     *  第一个   计算结果的限制,一般都只限制宽度
                是一个CGSize 可以计算出这个字符串完整的展示在uiview上需要多少的size 宽高
                所以第一个参数很有用 一般都是 设置宽高设置一个参数  CGFLOAT_MAX  无限大
     
        第二个参数 固定写法
                NSStringDrawingUsesLineFragmentOrigin 只能用这个 别的没有用
     
        第三个参数  字符串在计算占用size时,所采用的属性,比如字体大小
                文字属性  文字大小 阴影大小 等等  现在我们有label的指针,所以可以直接通过指针拿到label的字体
     
     */
   
     //  NSFontAttributeName  有阴影 点开进去找shar开头的阴影 设置一下就OK了
                                // 之前写的是 k_width - 85 减5 给一个计算的误差
    CGSize size = [model.body boundingRectWithSize:CGSizeMake(k_width - 90-1, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObject:cell.bodyLabel.font forKey:NSFontAttributeName] context:nil].size;
    //拿到label的frame
    CGRect frame = cell.bodyLabel.frame;
    frame.size.width = k_width - 90;   //减5 给一个计算的误差
    frame.size.height = size.height + 5; //加5 给一个计算的误差
    cell.bodyLabel.frame = frame;
    //判断留言中是否有图片
    if (!model.imgSmall.length)
    {
        //没有 imageview隐藏
        cell.imgView.hidden = YES;
    }
    else
    {
        //有 imageview显示  再修改frame
        cell.imgView.hidden = NO;
        //只需要改变imageview的y 值
        CGRect imgframe = cell.imgView.frame;
        imgframe.origin.y = frame.origin.y + frame.size.height + 10;//10是间隔 frame 是label的位置
        cell.imgView.frame = imgframe;
        [cell.imgView setImageWithURL:[NSURL URLWithString:model.imgSmall]];
        frame = imgframe;// 也是 cell.imgView.frame
        
    }
    //修改日期的frame  最终是根据
    CGRect dataFrame = cell.dataLabel.frame;
    dataFrame.origin.y = frame.origin.y + frame.size.height + 10;//frame 现在变成image的frame了
    cell.dataLabel.frame = dataFrame;
    return cell;
}

@end
