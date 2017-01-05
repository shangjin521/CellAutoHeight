//
//  TweetCell.h
//  01-cellAuto动态高度cell
//
//  Created by macbook on 15/9/19.
//  Copyright (c) 2015年 macbook. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TweetCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *bodyLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *dataLabel;

@end
