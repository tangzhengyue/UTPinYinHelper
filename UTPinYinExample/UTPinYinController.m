//
//  UTPinYinController.m
//  UTPinYinExample
//
//  Created by Walle on 15/3/30.
//  Copyright (c) 2015年 Walle. All rights reserved.
//

#import "UTPinYinController.h"
#import "UTPinYinHelper.h"

@interface UTPinYinController ()

@property(nonatomic, strong)NSArray *aryNames;
@property(nonatomic, strong)NSMutableArray *arySearchedNames;

@end

@implementation UTPinYinController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _aryNames = [NSArray arrayWithObjects:@"郭靖", @"黄蓉", @"黄药师", @"欧阳锋", @"王重阳", @"丘处机", @"小龙女", @"杨幂", @"傻姑", @"全真七子", @"张无忌", @"金毛狮王", @"锦毛鼠", @"包青天", @"周芷若", @"赵敏", @"小昭", @"甄子丹", @"李连杰", @"欧阳克", nil];
    
    _arySearchedNames = [NSMutableArray array];
    
    [self setupSearchTextView];
}

- (void)setupSearchTextView
{
    UITextField *searchBar = [[UITextField alloc] init];
    [searchBar addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
    
    // 设置背景图片
    UIImage *image = [UIImage imageNamed:@"searchbar_textfield_background"];
    searchBar.background = [image stretchableImageWithLeftCapWidth:image.size.width / 2 topCapHeight:image.size.height / 2];
    
    searchBar.frame = CGRectMake(0, 0, 200, 35);
    
    // 设置文字内容垂直居中
    searchBar.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    // 设置左边的放大镜
    UIImageView *leftView = [[UIImageView alloc] init];
    leftView.frame = CGRectMake(0, 0, 40, 35);
    leftView.image = [UIImage imageNamed:@"searchbar_textfield_search_icon"];
    searchBar.leftView = leftView;
    
    // 设置leftViewMode
    searchBar.leftViewMode = UITextFieldViewModeAlways;
    
    // 设置放大镜距离左边的间距，设置leftView的内容居中
    leftView.contentMode = UIViewContentModeCenter;
    
    // 添加到导航栏中
    self.navigationItem.titleView = searchBar;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arySearchedNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *strResuseID = @"SearchResultCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:strResuseID forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = self.arySearchedNames[indexPath.row];
    
    return cell;
}

#pragma mark - UITextField
-(void)textChanged:(UITextField *)textField
{
    NSString *strText = textField.text;
    [self.arySearchedNames removeAllObjects];
    
    if (strText.length <= 0) {
        [self.tableView reloadData];
        return;
    }
    
    [self.aryNames enumerateObjectsUsingBlock:^(NSString *strName, NSUInteger idx, BOOL *stop) {
        UTPinYinHelper *pinYinHelper = [UTPinYinHelper sharedPinYinHelper];
        if ([pinYinHelper isString:strName MatchsKey:strText IgnorCase:YES]) {
            [self.arySearchedNames addObject:strName];
        }
    }];
    
    [self.tableView reloadData];
}

@end
