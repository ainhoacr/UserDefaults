//
//  ViewController.m
//  UserDefaults
//
//  Created by Alexander Valero on 29/9/15.
//  Copyright © 2015 Alexander Valero. All rights reserved.
//

#import "ViewController.h"

static BOOL const kUseUserDefaults = NO;

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *nicknameField;
@property (weak, nonatomic) IBOutlet UISwitch *mySwitch;
@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) NSString *directory;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsDirectory = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];
    self.directory = [documentsDirectory stringByAppendingPathComponent:@"preferences"];
    NSError *error = nil;
    if (![fileManager fileExistsAtPath:self.directory])
    {
        [fileManager createDirectoryAtPath:self.directory withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    if (error) {
        NSLog(@"Error al crear el path %@", error);
    }
    else
    {
        self.path = [self.directory stringByAppendingPathComponent:@"preferences.plist"];
        
        if (kUseUserDefaults) {
            [self loadUserDefaults];
        }
        else
        {
            [self loadPlist];
        }
    }

}

- (void)loadUserDefaults
{
    NSString *username = [[NSUserDefaults standardUserDefaults]objectForKey:@"username"];
    self.usernameField.text = username;
    NSString *nickname = [[NSUserDefaults standardUserDefaults]objectForKey:@"nickname"];
    self.nicknameField.text = nickname;
    
    BOOL statusSwitch = [[NSUserDefaults standardUserDefaults]boolForKey:@"notification"];
    self.mySwitch.on = statusSwitch;
}

- (void)loadPlist
{
    NSArray *arrayPreferences = [NSArray arrayWithContentsOfFile:self.path];
    
    if (arrayPreferences.count == 3)
    {
        self.usernameField.text = arrayPreferences[0];
        self.nicknameField.text = arrayPreferences[1];
        self.mySwitch.on = [arrayPreferences[2] boolValue];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveButton:(UIButton *)sender {
    if (kUseUserDefaults)
    {
        [self saveDefaults];
    }
    else
    {
        [self savePlist];
    }
}


- (void)saveDefaults
{
    if (self.usernameField.text.length) {
        [[NSUserDefaults standardUserDefaults]setObject:self.usernameField.text forKey: @"username"];
    }
    
    if (self.nicknameField.text.length) {
        [[NSUserDefaults standardUserDefaults]setObject:self.nicknameField.text forKey: @"nickname"];
    }
    
    [[NSUserDefaults standardUserDefaults]setBool:self.mySwitch.on forKey:@"notification"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (void)savePlist
{
    NSMutableArray *arrayPreferences = [[NSMutableArray alloc]init];
    
    if (self.usernameField.text.length)
    {
        [arrayPreferences addObject:self.usernameField.text];
    }
    
    if (self.nicknameField.text.length)
    {
        [arrayPreferences addObject:self.nicknameField.text];
    }
    
    [arrayPreferences addObject:@(self.mySwitch.on)];
    
    NSArray *array = arrayPreferences.copy;
    [array writeToFile:self.path atomically:YES];
}

- (IBAction)resetPreferencesButton:(UIButton *)sender
{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    if (![fileManager removeItemAtPath:self.directory error:&error])
    {
        NSLog(@"[Error] %@ (%@)",error, self.directory);
    }
    
    self.usernameField.text = @"";
    self.nicknameField.text = @"";
    self.mySwitch.on = NO;
}

- (IBAction)buttonLogDirectory:(UIButton *)sender
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:self.directory error:&error];
    if (contents) {
        if (contents.count == 1)
        {
            NSLog(@"Ficheros: %@", contents[0]);
        }
    }
    else
    {
        NSLog(@"[Error] %@ (obtener contents)",error);
    }
}

@end
