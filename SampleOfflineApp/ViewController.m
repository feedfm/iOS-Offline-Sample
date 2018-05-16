//
//  ViewController.m
//  SampleOfflineApp
//
//  Created by Arveen kumar on 5/15/18.
//  Copyright © 2018 Feed FM. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <FMStationDownloadDelegate>

@property (weak, nonatomic) IBOutlet FMMetadataLabel *track;
@property (weak, nonatomic) IBOutlet FMMetadataLabel *artist;
@property (weak, nonatomic) IBOutlet FMMetadataLabel *album;

@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UILabel *state;

@property (nonatomic) NSUInteger noOfstations;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _noOfstations = 1;
    [self.progress setProgress:0];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stateDidChange:) name:FMAudioPlayerPlaybackStateDidChangeNotification object:[FMAudioPlayer sharedPlayer]];
    
    // set the lock screen up to share the player background
    // (this only appears when phone is playing music and is locked)
    // [_player setLockScreenImage:self.backgroundImage.image];
    
    FMAudioPlayer *player = [FMAudioPlayer sharedPlayer];

   
    
    [player setSecondsOfCrossfade:5];
    [player setCrossfadeInEnabled:YES];
    
    [player whenAvailable:^{
        for (FMStation *station in player.stationList) {
            self->_noOfstations++;
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [button addTarget:self action:@selector(changeStation:) forControlEvents:UIControlEventTouchUpInside];
            [[button layer] setValue:station forKey:@"station"];
            [button setTitle:station.name forState:UIControlStateNormal];
            button.frame = CGRectMake(40.0, 50.0* (double)self->_noOfstations, 150.0, 50.0);
            [self.view addSubview:button];
            
            UIButton *button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [button1 addTarget:self action:@selector(downloadStation:) forControlEvents:UIControlEventTouchUpInside];
            [[button1 layer] setValue:station forKey:@"station"];
            [button1 setTitle:@"Download" forState:UIControlStateNormal];
            button1.frame = CGRectMake(180.0, 50.0* (double)self->_noOfstations, 150.0, 50.0);
            [self.view addSubview:button1];
            
        }
        [self addOfflineStaions];
        
    } notAvailable:^{
        [self addOfflineStaions];
    }];
}

- (void)addOfflineStaions{
    
    NSArray *stations = [[FMAudioPlayer sharedPlayer] getStationsAvailableOffline];
    for (FMStation *station in stations) {
        _noOfstations++;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button addTarget:self action:@selector(changeStation:) forControlEvents:UIControlEventTouchUpInside];
        [[button layer] setValue:station forKey:@"station"];
        [button setTitle:[@"Offline-" stringByAppendingString:station.name] forState:UIControlStateNormal];
        button.frame = CGRectMake(100.0, 50.0* (double)_noOfstations, 200.0, 50.0);
        [self.view addSubview:button];
    }
}

- (void)stateDidChange:(NSNotification *) notification {
    [self updateStateDisplay];
}


- (void) updateStateDisplay {
    _state.text = [FMAudioPlayer nameForType:[FMAudioPlayer sharedPlayer].playbackState];
}

- (void)downloadStation :(UIButton*) sender {
    
    FMStation *station = [[sender layer] valueForKey:@"station"];
    [[FMAudioPlayer sharedPlayer] downloadStation:station withDelegate:self];
    
}

- (void)changeStation: (UIButton*)sender
{
    FMStation *station = [[sender layer] valueForKey:@"station"];
    [[FMAudioPlayer sharedPlayer] setActiveStation:station withCrossfade:NO];
    [[FMAudioPlayer sharedPlayer] play];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)stationDownloadComplete:(FMStation *)station {
    NSLog(@"downloading done %@", station.identifier);
    dispatch_async( dispatch_get_main_queue(),
                   ^{
                       self.noOfstations++;
                       UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                       [button addTarget:self action:@selector(changeStation:) forControlEvents:UIControlEventTouchUpInside];
                       [[button layer] setValue:station forKey:@"station"];
                       [button setTitle:[@"Offline-" stringByAppendingString:station.name] forState:UIControlStateNormal];
                       button.frame = CGRectMake(100.0, 50.0* (double)self.noOfstations, 150.0, 50.0);
                       [self.view addSubview:button];
                   });
}

- (void)stationDownloadProgress:(FMStation *)station withParms:(NSDictionary *)parms {
    float total = [[parms valueForKey:@"TotalDownloads"] floatValue];
    float pending = [[parms valueForKey:@"DownloadsPending"] floatValue];
    float failed = [[parms valueForKey:@"FailedDownloads"] floatValue];
    float downloaded = total - pending - failed;
    float per = (float)(downloaded/total);
    [self.progress setProgress:per animated:YES];
    NSLog(@"downloading progress %f", per);
}

@end
