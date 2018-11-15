//
//  TableSelectionView.m
//  Teraoka
//
//  Created by Thuan on 11/14/18.
//  Copyright © 2018 ss. All rights reserved.
//

#import "TableSelectionView.h"
#import "TableSelectionViewCell.h"

@interface TableSelectionView() <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (nonatomic, strong) NSArray *items;

@end

@implementation TableSelectionView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.tblView.delegate = self;
    self.tblView.dataSource = self;
    [self.tblView registerNib:[UINib nibWithNibName:@"TableSelectionViewCell" bundle:nil] forCellReuseIdentifier:@"TableSelectionViewCellID"];
}

- (void)setupData:(NSArray *)items {
    self.items = items;
    [self.tblView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TableSelectionViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableSelectionViewCellID" forIndexPath:indexPath];
    cell.lbTitle.text = self.items[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30;
}

@end
