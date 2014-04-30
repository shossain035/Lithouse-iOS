//
//  ScanLAN.m
//  LAN Scan
//
//  Created by Mongi Zaidi on 24 February 2014.
//  Copyright (c) 2014 Smart Touch. All rights reserved.
//

#import "ScanLAN.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#include <netdb.h>
#import "SimplePingHelper.h"
#include <sys/param.h>
#include <sys/file.h>
#include <sys/socket.h>
#include <sys/sysctl.h>

#include <net/if.h>
#include <net/if_dl.h>
#include <net/ethernet.h>
#include <netinet/in.h>


#include <arpa/inet.h>

#include <err.h>
#include <errno.h>
#include <netdb.h>

#include <paths.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#import "LITLANDevice.h"

//#define RTF_LLINFO	0x400
//
//struct rt_metrics {
//	u_int32_t	rmx_locks;	/* Kernel must leave these values alone */
//	u_int32_t	rmx_mtu;	/* MTU for this path */
//	u_int32_t	rmx_hopcount;	/* max hops expected */
//	int32_t		rmx_expire;	/* lifetime for route, e.g. redirect */
//	u_int32_t	rmx_recvpipe;	/* inbound delay-bandwidth product */
//	u_int32_t	rmx_sendpipe;	/* outbound delay-bandwidth product */
//	u_int32_t	rmx_ssthresh;	/* outbound gateway buffer limit */
//	u_int32_t	rmx_rtt;	/* estimated round trip time */
//	u_int32_t	rmx_rttvar;	/* estimated rtt variance */
//	u_int32_t	rmx_pksent;	/* packets sent using this route */
//	u_int32_t	rmx_filler[4];	/* will be used for T/TCP later */
//};
//
//struct rt_msghdr {
//	u_short	rtm_msglen;		/* to skip over non-understood messages */
//	u_char	rtm_version;		/* future binary compatibility */
//	u_char	rtm_type;		/* message type */
//	u_short	rtm_index;		/* index for associated ifp */
//	int	rtm_flags;		/* flags, incl. kern & message, e.g. DONE */
//	int	rtm_addrs;		/* bitmask identifying sockaddrs in msg */
//	pid_t	rtm_pid;		/* identify sender */
//	int	rtm_seq;		/* for sender to identify action */
//	int	rtm_errno;		/* why failed */
//	int	rtm_use;		/* from rtentry */
//	u_int32_t rtm_inits;		/* which metrics we are initializing */
//	struct rt_metrics rtm_rmx;	/* metrics themselves */
//};
//
//struct sockaddr_inarp {
//    u_char  sin_len;
//    u_char  sin_family;
//    u_short sin_port;
//    struct  in_addr sin_addr;
//    struct  in_addr sin_srcaddr;
//    u_short sin_tos;
//    u_short sin_other;
//#define SIN_PROXY 1
//};


@interface ScanLAN ()

@property NSString *localAddress;
@property NSString *baseAddress;
@property NSInteger currentHostAddress;
@property NSTimer *timer;
@property NSString *netMask;
@property NSInteger baseAddressEnd;
@property NSInteger timerIterationNumber;
@property NSDictionary* portMapping;

@end

@implementation ScanLAN

- (id)initWithDelegate:(id<ScanLANDelegate>)delegate {
    NSLog(@"init scanner");
    self = [super init];
    if(self)
    {
		self.delegate = delegate;
    }
    
    self.portMapping = @{
                         [NSNumber numberWithInt : DEVICE_PORT_PC]      : DEVICE_TYPE_PC,
                         [NSNumber numberWithInt : DEVICE_PORT_MAC]     : DEVICE_TYPE_MAC,
                         [NSNumber numberWithInt : DEVICE_PORT_IOS]     : DEVICE_TYPE_IOS,
                         [NSNumber numberWithInt : DEVICE_PORT_PRINTER] : DEVICE_TYPE_PRINTER,
                        };
    return self;
}

- (void)startScan {
    NSLog(@"start scan");
    self.localAddress = [self localIPAddress];
    //This is used to test on the simulator
    //self.localAddress = @"192.168.1.8";
    //self.netMask = @"255.255.255.0";
    NSArray *a = [self.localAddress componentsSeparatedByString:@"."];
    NSArray *b = [self.netMask componentsSeparatedByString:@"."];
    if ([self isIpAddressValid:self.localAddress] && (a.count == 4) && (b.count == 4)) {
        for (int i = 0; i<4; i++) {
            int and = [[a objectAtIndex:i] integerValue] & [[b objectAtIndex:i] integerValue];
            if (!self.baseAddress.length) {
                self.baseAddress = [NSString stringWithFormat:@"%d", and];
            }
            else {
                self.baseAddress = [NSString stringWithFormat:@"%@.%d", self.baseAddress, and];
                self.currentHostAddress = and;
                self.baseAddressEnd = and;
            }
        }
        self.timer = [NSTimer scheduledTimerWithTimeInterval : 0.02
                                                      target : self
                                                    selector : @selector(pingAddress)
                                                    userInfo : nil
                                                     repeats : YES];
    }
}

- (void)stopScan {
    NSLog(@"stop scan");
    [self.timer invalidate];
}

- (void)pingAddress{
    self.currentHostAddress++;
    NSString *address = [NSString stringWithFormat:@"%@%d", self.baseAddress, self.currentHostAddress];
    [SimplePingHelper ping:address target:self sel:@selector(pingResult:address:)];
    if (self.currentHostAddress>=254) {
        [self.timer invalidate];
    }
}

- (void)pingResult:(NSNumber*)success address:(NSString*) anAddress {
    self.timerIterationNumber++;
    if (success.boolValue) {
        NSLog(@"SUCCESS");
        dispatch_queue_t backgroundQueue = dispatch_queue_create("com.lithouse.lanscanQueue", 0);
        dispatch_async(backgroundQueue, ^{
            NSString *deviceIPAddress = [[anAddress stringByReplacingOccurrencesOfString : @".0" withString:@"."] stringByReplacingOccurrencesOfString:@".." withString:@".0."];
            NSString *macAddress = [self ip2mac : inet_addr([ deviceIPAddress UTF8String ])];
            NSLog(@"MAC = %@", macAddress);
            NSString *deviceName = [self getHostFromIPAddress :
                                    [deviceIPAddress cStringUsingEncoding : NSASCIIStringEncoding]];
            NSString *deviceType = nil;
        
            if ( [deviceIPAddress isEqualToString : self.localAddress] ) {
                deviceType = DEVICE_TYPE_IOS;
            } else {
                deviceType = [self deviceTypeOfHost : deviceIPAddress];
            }
        
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate scanLANDidFindNewAdrress : deviceIPAddress
                                         havingHostName : deviceName
                                       havingMACAddress : macAddress
                                             havingType : deviceType];
            });
        });
    }
    else {
       // NSLog(@"FAILURE");
    }
    if (self.timerIterationNumber+self.baseAddressEnd>=254) {
        [self.delegate scanLANDidFinishScanning];
    }
}

- (NSString *)getHostFromIPAddress:(const char*)ipAddress {
    NSString *hostName = nil;
    int error;
    struct addrinfo *results = NULL;
    
    error = getaddrinfo(ipAddress, NULL, NULL, &results);
    if (error != 0)
    {
        NSLog (@"Could not get any info for the address");
        return nil; // or exit(1);
    }
    
    for (struct addrinfo *r = results; r; r = r->ai_next)
    {
        char hostname[NI_MAXHOST] = {0};
        error = getnameinfo(r->ai_addr, r->ai_addrlen, hostname, sizeof hostname, NULL, 0 , 0);
        if (error != 0)
        {
            continue; // try next one
        }
        else
        {
            NSLog (@"Found hostname: %s", hostname);
            hostName = [NSString stringWithFormat:@"%s", hostname];
            break;
        }
        
    }
    
    freeaddrinfo(results);
    return hostName;
}

- (NSString*)ip2mac:(in_addr_t)addr
{
    //todo: compute mac address
    return nil;
    /*
    NSString *ret = nil;
    
    size_t needed;
    char *buf, *next;
    
    struct rt_msghdr *rtm;
    struct sockaddr_inarp *sin;
    struct sockaddr_dl *sdl;
    
    int mib[6];
    
    mib[0] = CTL_NET;
    mib[1] = PF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_INET;
    mib[4] = NET_RT_FLAGS;
    mib[5] = RTF_LLINFO;
    
    if (sysctl(mib, sizeof(mib) / sizeof(mib[0]), NULL, &needed, NULL, 0) < 0)
        err(1, "route-sysctl-estimate");
    
    if ((buf = (char*)malloc(needed)) == NULL)
        err(1, "malloc");
    
    if (sysctl(mib, sizeof(mib) / sizeof(mib[0]), buf, &needed, NULL, 0) < 0)
        err(1, "retrieval of routing table");
    
    for (next = buf; next < buf + needed; next += rtm->rtm_msglen) {
        
        rtm = (struct rt_msghdr *)next;
        sin = (struct sockaddr_inarp *)(rtm + 1);
        sdl = (struct sockaddr_dl *)(sin + 1);
        
        if (addr != sin->sin_addr.s_addr || sdl->sdl_alen < 6)
            continue;
        
        u_char *cp = (u_char*)LLADDR(sdl);
        
        ret = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
               cp[0], cp[1], cp[2], cp[3], cp[4], cp[5]];
        
        break;
    }
    
    free(buf);
    
    return ret;
     */
}

- (NSString *) localIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    
    if (success == 0)
    {
        temp_addr = interfaces;
        
        while(temp_addr != NULL)
        {
            // check if interface is en0 which is the wifi connection on the iPhone
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    self.netMask = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_netmask)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);
    
    return address;
}

- (BOOL) isPortOpenOfHost : (NSString *) hostAddress port : (int) aPort
{
    struct sockaddr_in address;
    short int sock = -1;
    fd_set fdset;
    struct timeval tv;
        
    address.sin_family = AF_INET;
    address.sin_addr.s_addr = inet_addr( [hostAddress UTF8String] );
    address.sin_port = htons( aPort);
    
    sock = socket(AF_INET, SOCK_STREAM, 0);
    fcntl(sock, F_SETFL, O_NONBLOCK);
    
    connect(sock, (struct sockaddr *)&address, sizeof(address));
    
    FD_ZERO(&fdset);
    FD_SET(sock, &fdset);
    tv.tv_sec = 10;             /* 10 second timeout */
    tv.tv_usec = 0;
    
    if (select(sock + 1, NULL, &fdset, NULL, &tv) == 1) {
        int so_error;
        socklen_t len = sizeof so_error;
        
        getsockopt(sock, SOL_SOCKET, SO_ERROR, &so_error, &len);
        
        if (so_error == 0) {
            return YES;
        }
    }
    
    close(sock);
    return NO;
}

- (NSString *) deviceTypeOfHost : (NSString *) hostAddress {
    for ( id port in self.portMapping ) {
        
        if ( [self isPortOpenOfHost : hostAddress port : [port intValue]] ) {
            return [self.portMapping objectForKey : port];
        }
    }
    
    return nil;
}

- (BOOL) isIpAddressValid : (NSString *)ipAddress{
    struct in_addr pin;
    int success = inet_aton([ipAddress UTF8String],&pin);
    if (success == 1) return TRUE;
    return FALSE;
}

@end
