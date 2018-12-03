//
//  TableSelectionView.m
//  Teraoka
//
//  Created by Thuan on 11/14/18.
//  Copyright © 2018 ss. All rights reserved.
//

#import "TableSelectionView.h"
#import "TableSelectionViewCell.h"

@interface TableSelectionView() <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (weak, nonatomic) IBOutlet UITextField *searchTf;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSArray *filteredItems;

@end

@implementation TableSelectionView {
    BOOL isFiltered;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    isFiltered = NO;
    
    self.tblView.delegate = self;
    self.tblView.dataSource = self;
    [self.tblView registerNib:[UINib nibWithNibName:@"TableSelectionViewCell" bundle:nil] forCellReuseIdentifier:@"TableSelectionViewCellID"];
    
    [self.searchTf addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
}

- (void)setupData:(NSArray *)items {
    self.items = items;
    [self.tblView reloadData];
}

- (void)textFieldDidChange {
    if (self.searchTf.text.length > 0) {
        isFiltered = YES;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@",self.searchTf.text];
        self.filteredItems = [self.items filteredArrayUsingPredicate:predicate];
    } else {
        isFiltered = NO;
    }
    [self.tblView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (isFiltered) return self.filteredItems.count;
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TableSelectionViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableSelectionViewCellID" forIndexPath:indexPath];
    if (isFiltered) {
        cell.lbTitle.text = self.filteredItems[indexPath.row];
    } else {
        cell.lbTitle.text = self.items[indexPath.row];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *tableNo;
    if (isFiltered) {
        tableNo = self.filteredItems[indexPath.row];
    } else {
        tableNo = self.items[indexPath.row];
    }
    
    if (self.delegate) {
        [self.delegate didSelectItem:tableNo];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 35;
}

@end
