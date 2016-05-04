//
//  MEVHorizontalContactsModel.m
//  People Tracker
//
//  https://github.com/manuelescrig/MEVHorizontalContacts
//
//  Created by Manuel Escrig Ventura on 24/02/16.
//  Copyright (c) 2016 Manuel Escrig Ventura. All rights reserved.
//  Licence: MIT-Licence
//

#import "MEVHorizontalContacts.h"

static float const kMEVHorizontalContactsDefaultLabelHeight = 30.0f;
static float const kMEVHorizontalContactsDefaultItemSpacing = 5.0f;

@interface MEVHorizontalContacts()  <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MEVHorizontalContactsCellDelegate, MEVHorizontalContactsCellDataSource, MEVHorizontalContactsLayoutDataSource>

@property (nonatomic, strong) UICollectionView *horizontalContactListView;
@property (nonatomic, strong) MEVHorizontalContactsLayout *layout;
@property (nonatomic, assign) NSInteger selectedIndex;

@end

@implementation MEVHorizontalContacts


#pragma mark - View Life Cycle

- (id)init
{
    self = [super init];
    if (self) {
        [self setupView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self setupView];
    }
    return self;
}

- (void)setupView
{
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self setOpaque:YES];
    
    _selectedIndex = -1;
    
    // Contact List
    _layout = [[MEVHorizontalContactsLayout alloc] init];
    _layout.dataSource = self;
    _horizontalContactListView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)) collectionViewLayout:_layout];
    [_horizontalContactListView registerClass:[MEVHorizontalContactsCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [_horizontalContactListView setDataSource:self];
    [_horizontalContactListView setDelegate:self];
    [_horizontalContactListView setOpaque:YES];
    [_horizontalContactListView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    [_horizontalContactListView setAlwaysBounceHorizontal:YES];
    [_horizontalContactListView setShowsVerticalScrollIndicator:NO];
    [_horizontalContactListView setShowsHorizontalScrollIndicator:NO];
    [_horizontalContactListView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:_horizontalContactListView];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[horizontalContactsView]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:@{@"horizontalContactsView" : _horizontalContactListView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[horizontalContactsView]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:@{@"horizontalContactsView" : _horizontalContactListView}]];
}


#pragma mark - Layout

- (void)layoutSubviews
{    
    if ([_dataSource respondsToSelector:@selector(horizontalContactsItemSpacing)]) {
        _layout.itemSpacing =  [_dataSource horizontalContactsItemSpacing];
    } else {
        _layout.itemSpacing = kMEVHorizontalContactsDefaultItemSpacing;
    }
    
    UIEdgeInsets insets;
    if ([_dataSource respondsToSelector:@selector(horizontalContactsInsets)]) {
        insets =  [_dataSource horizontalContactsInsets];
    }
    
    _layout.insets = insets;
    _layout.itemHeight = CGRectGetHeight(self.frame) - insets.top - insets.bottom;
    _layout.itemWidth = _layout.itemHeight - kMEVHorizontalContactsDefaultLabelHeight;
    _layout.labelHeight = kMEVHorizontalContactsDefaultLabelHeight;
}


#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([_dataSource respondsToSelector:@selector(numberOfContacts)]) {
        return [_dataSource numberOfContacts];
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MEVHorizontalContactsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    cell.labelHeight = kMEVHorizontalContactsDefaultLabelHeight;
    cell.cellIndexPath = indexPath;
    cell.cellDelegate = self;
    cell.cellDataSource = self;
    
    if (indexPath.row == _selectedIndex) {
        cell.selected = YES;
        [cell showMenuOptionsAnimated:NO];
    } else {
        cell.selected = NO;
        [cell hideMenuOptionsAnimated:NO];
    }
    
    if ([_dataSource respondsToSelector:@selector(horizontalContactsItemSpacing)]) {
        cell.itemSpacing =  [_dataSource horizontalContactsItemSpacing];
    } else {
        cell.itemSpacing = kMEVHorizontalContactsDefaultItemSpacing;
    }
    
    if ([_dataSource respondsToSelector:@selector(contactAtIndex:)]) {
        MEVHorizontalContactsModel *contact = [_dataSource contactAtIndex:indexPath.row];
        [cell.imageView setImage:[contact image]];
        [cell.label setText:[contact name]];
    }

    return cell;
}

#pragma mark – MEVHorizontalContactsLayoutDataSource
#pragma mark – MEVHorizontalContactsCellDataSource 

- (NSInteger)numberOfItemsInCellIndexPath:(NSIndexPath *)indexPath
{
    if ([_dataSource respondsToSelector:@selector(numberOfItemsAtIndex:)]) {
        return [_dataSource numberOfItemsAtIndex:indexPath.row];
    }
    return 0;
}


#pragma mark – MEVHorizontalContactsCellDataSource

- (NSString *)textForItemAtIndex:(NSInteger)index atCellIndexPath:(NSIndexPath *)indexPath
{
    if ([_dataSource respondsToSelector:@selector(textForItem:atIndex:)]) {
        return [_dataSource textForItem:index atIndex:indexPath.row];
    }
    return @"";
}

- (UIImage *)imageForItemAtIndex:(NSInteger)index atCellIndexPath:(NSIndexPath *)indexPath
{
    if ([_dataSource respondsToSelector:@selector(imageForItem:atIndex:)]) {
        return [_dataSource imageForItem:index atIndex:indexPath.row];
    }
    return nil;
}

- (CGFloat)heightForLabel
{
    kMEVHorizontalContactsDefaultLabelHeight;
}

- (CGFloat)itemSpacing
{
    if ([_dataSource respondsToSelector:@selector(horizontalContactsItemSpacing)]) {
        return [_dataSource horizontalContactsItemSpacing];
    } else {
        return kMEVHorizontalContactsDefaultItemSpacing;
    }
}


#pragma mark – MEVHorizontalContactListCellDelegate

- (void)cellSelectedAtIndexPath:(NSIndexPath *)indexPath
{
    // Deselect old cell
    if (_selectedIndex >= 0 && _selectedIndex != indexPath.row) {
        
        // Deselect old cell
        MEVHorizontalContactsCell *cell = [_horizontalContactListView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_selectedIndex inSection:0]];
        cell.selected = NO;
        [cell hideMenuOptionsAnimated:YES];
        
    }
    

    
    // Select new cell, in case of deselecting then set -1 as default value
    _selectedIndex = _selectedIndex == indexPath.row ? -1 : indexPath.row;

    [_horizontalContactListView performBatchUpdates:^{
        [_horizontalContactListView setContentOffset:CGPointMake(indexPath.row  * (_layout.itemWidth + [self itemSpacing]), 0) animated:YES];
        } completion:^(BOOL finished) { }];
    
//    [_horizontalContactListView invalidateIntrinsicContentSize];

    if ([_delegate respondsToSelector:@selector(contactSelectedAtIndex:)]) {
        return [_delegate contactSelectedAtIndex:indexPath.row];
    }
}

- (void)menuOptionSelected:(NSInteger)option atCellIndexPath:(NSIndexPath *)indexPath
{
    if ([_delegate respondsToSelector:@selector(item:selectedAtIndex:)]) {
        return [_delegate item:option selectedAtIndex:indexPath.row];
    }
}

@end