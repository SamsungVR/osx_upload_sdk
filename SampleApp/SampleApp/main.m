//
//  main.m
//  SampleApp
//
//  Created by Venky on 2/27/17.
//  Copyright © 2017 Samsung. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DgApp.h"

int main(int argc, const char * argv[]) {
   
   DgApp *pDgApp = [[DgApp alloc] init];
   
   NSApplication *pApp = [NSApplication sharedApplication];
   [pApp setDelegate:pDgApp];
   [pApp performSelectorOnMainThread:@selector(run) withObject:nil waitUntilDone:YES];   
   return EXIT_SUCCESS;
}
