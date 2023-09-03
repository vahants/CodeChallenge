//
//  ViewController.m
//  codeChallenge
//
//  Created by Nano Suarez on 18/04/2018.
//  Copyright © 2018 Fernando Suárez. All rights reserved.
//

#import "PhotosTableViewController.h"
#import "PhotosTableViewCell.h"
#import "codeChallenge-Swift.h"

@interface PhotosTableViewController ()

@property (nonatomic) NSMutableArray<CHFlickrPhoto *> *photos;
@property (nonatomic) NSInteger imagePageOffset;
@property (nonatomic) BOOL isRequesting;
@property (nonatomic) NSInteger totalPages;
@property (nonatomic) NSInteger perPage;
@property (nonatomic) FlickrPhotosSort sort;
@property (nonatomic, weak) id <INetworkOperation> operation;

@property (nonatomic) CHFlickrPhoto* selectedPhoto;

@end

@implementation PhotosTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Photos";
    UINib *cellNib = [UINib nibWithNibName:@"PhotosTableViewCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:@"PhotosTableViewCell"];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = UITableViewAutomaticDimension;
    [self resetRequest];
    [self loadFlickrPhotos];
}

#pragma mark - TableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  UITableViewAutomaticDimension;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.photos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"PhotosTableViewCell";
    PhotosTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    [cell configureCell:self.photos[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _selectedPhoto = self.photos[indexPath.row];

    [self performSegueWithIdentifier:@"DisplayAlternateView" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"DisplayAlternateView"])
    {
        // Get reference to the destination view controller
        CHPhotoViewController *vc = [segue destinationViewController];

        // Pass any objects to the view controller here, like...
        [vc setPhotoWithPhoto:_selectedPhoto];
    }
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row > self.photos.count - 2) {
        [self loadFlickrPhotos];
    }
    
}

- (void)reload {
     [self.tableView reloadData];
}

- (void)loadFlickrPhotos {
    
    if (_isRequesting == YES || _imagePageOffset == _totalPages) {
        return;
    }
    
    CHFlickrPhotosNetworkWorker *worker = [[CHFlickrPhotosNetworkWorker alloc] init];
    __weak PhotosTableViewController *weakSelf = self;
    _isRequesting = YES;
    
    _operation = [worker requestPhotosWithType:@"cooking" pageNumber:_imagePageOffset perPage:_perPage sort: _sort success:^(CHFlickrPhotoPageResult * _Nonnull page) {
        weakSelf.isRequesting = NO;
        weakSelf.imagePageOffset = MIN(weakSelf.imagePageOffset + 1, page.pages);
        weakSelf.totalPages = page.pages;
        [weakSelf.photos addObjectsFromArray:page.photos];
        [weakSelf.tableView reloadData];
    } failure:^(NSError * _Nonnull error) {
        weakSelf.isRequesting = NO;
    }];
}

-(void)resetRequest {
    [_operation cancel];
    _photos = [[NSMutableArray<CHFlickrPhoto *> alloc] init];
    _isRequesting = NO;
    _totalPages = 0;
    _imagePageOffset = 1;
    _perPage = 15;
    _sort = FlickrPhotosSortDatePostedDesc;
    [self.tableView reloadData];
}

#pragma mark --

- (FlickrPhotosSort)getSort {
    return  self.sort;
}

- (void)reloadSortWithSort:(enum FlickrPhotosSort)sort {
    [self resetRequest];
    self.sort = sort;
    [self loadFlickrPhotos];
}


@end
