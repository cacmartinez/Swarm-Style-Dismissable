//
//  ViewController.m
//  SwarmLikeDismissable
//
//  Created by Compean on 12/11/14.
//  Copyright (c) 2014 Icalia Labs. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property UIViewController *popupController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated{
    UIViewController *popupController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"popupController"];
    self.popupController = popupController;
    popupController.view.bounds = CGRectMake(0, 0, 250, 400);
    popupController.view.center = self.view.center;
    //[self presentViewController:popupController animated:NO completion:nil];
    [self.view addSubview:popupController.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
