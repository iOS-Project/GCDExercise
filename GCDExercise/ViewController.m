//
//  ViewController.m
//  GCDExercise
//
//  Created by Lun Sovathana on 11/13/15.
//  Copyright © 2015 Lun Sovathana. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate, NSURLConnectionDelegate>

@end

@implementation ViewController

NSMutableData *_responseData;
NSMutableArray *json;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tblView.delegate = self;
    self.tblView.dataSource = self;
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc]initWithURL:
                                       [NSURL URLWithString:@"https://api.parse.com/1/classes/APUploadToParse"]];
    
    urlRequest.HTTPMethod = @"GET";
    [urlRequest addValue:@"jGJU4zicgO4Fiejw6sLwYqQn7qcQbqVvOQyo76Y3"
      forHTTPHeaderField:@"X-Parse-Application-Id"];
     [urlRequest addValue:@"ZiWq01FMNJTse8qc1vIyQ2NSUsu3UKgqt7DXdZVS"
       forHTTPHeaderField:@"X-Parse-REST-API-Key"];
    
    
    // Create the request.
    //NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://google.com"]];
    
    // Create url connection and fire request
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    
    //NSString *jsonString = @"[{\"id\": \"1\", \"name\":\"Aaa\"}, {\"id\": \"2\", \"name\":\"Bbb\"}]";
    //NSData *jsonData = [_responseData dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e = nil;
    NSArray *root = [NSJSONSerialization JSONObjectWithData:_responseData options:NSJSONReadingMutableContainers error:&e];
    json = [[NSMutableArray alloc]initWithArray:[root valueForKeyPath:@"results"]];
    [self.tblView reloadData];
    NSLog(@"%@", json);
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [json count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"messageCell" forIndexPath:indexPath];
    cell.textLabel.text = [[json objectAtIndex:indexPath.row] objectForKey:@"name"];
    
    cell.tag = indexPath.row;
    
    cell.imageView.image = nil;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^(void) {
        
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[[json objectAtIndex:indexPath.row] objectForKey:@"image"] objectForKey:@"url"]]];
                             
                             UIImage *image = [UIImage imageWithData:data];
                             if (image) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     if (cell.tag == indexPath.row) {
                                         cell.imageView.image = image;
                                         [cell setNeedsLayout];
                                     }
                                 });
                             }
        });
    
    
    return cell;
}

//void runOnMainQueueWithoutDeadlocking(void (^block)(void))
//{
//    if ([NSThread isMainThread])
//    {
//        block();
//    }
//    else
//    {
//        dispatch_sync(dispatch_get_main_queue(), block);
//    }
//}

@end
