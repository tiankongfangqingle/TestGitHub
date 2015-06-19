//
//  ViewController.m
//  hhh
//
//  Created by lanou3g on 15/6/18.
//  Copyright (c) 2015年 小强. All rights reserved.
//

#import "ViewController.h"
#import <sqlite3.h>
#import "shop.h"

@interface ViewController ()<UITableViewDataSource,UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameFiled;

@property (weak, nonatomic) IBOutlet UITextField *priceFiled;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,assign)sqlite3 *db;

@property (nonatomic,strong)NSMutableArray *dataArray;

@end

@implementation ViewController

- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        
        self.dataArray = [NSMutableArray array];
    }
    return _dataArray;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.frame = CGRectMake(0, 0, 320, 44);
    self.tableView.tableHeaderView = searchBar;
    
    // 打开数据库
    [self openDB];
    
}


// 插入数据
- (IBAction)buttonAction:(UIButton *)sender {
    
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO t_shop(name,price) VALUES ('%@', %f);",self.nameFiled.text,self.priceFiled.text.doubleValue];
    sqlite3_exec(self.db, sql.UTF8String, NULL, NULL, NULL);
    
    // 刷新表格
    shop *s = [[shop alloc] init];
    s.name = self.nameFiled.text;
    s.price = self.priceFiled.text;
    
    [self.dataArray addObject:s];
    
    [self.tableView reloadData];
    
    
}


#pragma mark - 数据库操作

// 打开数据库(建表)
- (void)openDB
{
    // 打开数据库
    NSString *fileName = [[NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"goods.sqlite"];
    
    int status = sqlite3_open(fileName.UTF8String, &_db);
    if (status == SQLITE_OK) {
        NSLog(@"数据库打开成功");
        
        // 建表
        const char *sql = "CREATE TABLE IF NOT EXISTS t_shop (id integer PRIMARY KEY, name text NOT NULL, price real);";
        char *errmsg = NULL;
        sqlite3_exec(self.db, sql, NULL, NULL, &errmsg);
        if (errmsg) {
            
            NSLog(@"建表失败--%s",errmsg);
        }
    }else{
        NSLog(@"打开数据库失败");
    }
    
}

// 查询数据
- (void)selectData
{
    const char *sql = "SELECT name,price FROM t_shop";
    
    sqlite3_stmt *stmt = NULL;
    
    int status = sqlite3_prepare_v2(self.db, sql, -1, &stmt, NULL);
    if (status == SQLITE_OK) {
        
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            const char *name = (const char *)sqlite3_column_text(stmt, 0);
            const char *price = (const char *)sqlite3_column_text(stmt, 1);
            
            
            shop *s = [[shop alloc] init];
            s.name = [NSString stringWithUTF8String:name];
            s.price = [NSString stringWithUTF8String:price];
            
            [self.dataArray addObject:s];
        }
    }
    
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"shop";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        cell.backgroundColor = [UIColor grayColor];
    }
    
    shop *s = [[shop alloc] init];
    cell.textLabel.text = s.name;
    cell.detailTextLabel.text = s.price;
    
    
    return cell;
}


#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self.dataArray removeAllObjects];
    
    NSString *sql = [NSString stringWithFormat:@"SELECT name,price FROM t_shop WHERE name LIKE '%%%@%%' OR price LIKE '%%%@%%';",searchBar.text,searchBar.text];
    
    sqlite3_stmt *stmt = NULL;
    int status = sqlite3_prepare_v2(self.db, sql.UTF8String, -1, &stmt, NULL);
    if (status == SQLITE_OK) {
        
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            
            const char *name = (const char *)sqlite3_column_text(stmt, 0);
            const char *price = (const char *)sqlite3_column_text(stmt, 1);
            shop *s = [[shop alloc] init];
            s.name = [NSString stringWithUTF8String:name];
            s.price = [NSString stringWithUTF8String:price];
            [self.dataArray addObject:s];
        }
    }
    [self.tableView reloadData];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
