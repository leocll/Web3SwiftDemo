//
//  MathWalletOperation.m
//  MathWalletDemo
//
//  Created by leocll on 2018/10/22.
//  Copyright © 2018年 leocll. All rights reserved.
//

#import "MathWalletOperation.h"
#import "MathWalletSDK.h"

@implementation MathWalletOperation

#pragma mark - 使用MathWallet进行登录操作
+ (void)login {
    MathWalletLoginReq *loginReq = [[MathWalletLoginReq alloc] init];
    // 公链标识
    loginReq.blockchain = @"ethereum";   // eosio、eosforce、ethereum
    // DApp信息
    loginReq.dappIcon = @"http://www.mathwallet.org/images/download/wallet_cn.png";
    loginReq.dappName = @"LiananTechHouse";
    // DApp Server
    loginReq.uuID = @"123456";
    loginReq.loginUrl = @"http://op.juhe.cn/onebox/movie/video?dtype=&q=dier&key=a0fae95083c57d3701829878c5269032";//@"https://www.baidu.com";// 若有服务器的情况下，服务器将其uuid的用户置于已登录的状态，用于后续业务逻辑处理
    
    loginReq.expired = [NSNumber numberWithLong:([NSDate date].timeIntervalSince1970 + 60)];
    loginReq.loginMemo = @"test备注";// 备注
    
    [MathWalletAPI sendReq:loginReq];
}

#pragma mark - 使用MathWallet进行转账操作
+ (void)transfer {
    NSString *constractAdress = @"0xc41b0268150d9f7e57768330f86de79f50c3db81";
    
    
    MathWalletTransferReq *transferReq = [[MathWalletTransferReq alloc] init];
    transferReq.action = @"transaction";//@"register";
    // 公链标识
    transferReq.blockchain = @"ethereum";  // eosio、eosforce、ethereum
    // DApp信息
    transferReq.dappIcon = @"http://www.mathwallet.org/images/download/wallet_cn.png";
    transferReq.dappName = @"LiananTechHouse";
    // 转账信息
    transferReq.from = @"0x68b05b7e1b003dF1F9ee3F59dcDf240c2ae527AC";//test//@"eosioaccount";
    transferReq.to = constractAdress;//@"0x4c4E30d8Edd69829B2659e30cF8aA5818EA8a3b8";//leocll@"eosioaccount";
    transferReq.amount = @"0";
    transferReq.precision = @(18);
    transferReq.symbol = @"ETH";//@"EOS";
//    transferReq.contract = @"eosio.token";
    transferReq.dappData = @"ipfsHash='leocll'";//转账的附属信息，将同步到去中心化服务器
    
    transferReq.desc = @"描述";//用于UI展示
    transferReq.expired = [NSNumber numberWithLong:([NSDate date].timeIntervalSince1970 + 60)];
    
    [MathWalletAPI sendReq:transferReq];
}

#pragma mark - 使用MathWallet进行自定义交易操作（执行合约）
+ (void)customTransfer {
    MathWalletTransactionReq *transactionReq = [[MathWalletTransactionReq alloc] init];
    // 公链标识
    transactionReq.blockchain = @"ethereum";
    // DApp信息
    transactionReq.dappIcon = @"http://www.mathwallet.org/images/download/wallet_cn.png";
    transactionReq.dappName = @"LiananTechHouse";
    // 转账信息
    transactionReq.from = @"testaccount1";
    transactionReq.actions = @[
                               @{
                                   @"code":@"eosio.token",
                                   @"action":@"transfer",
                                   @"binargs":@"4086089a7ad7bef6c0a6eb6c1acda891010000000000000004454f530000000006e5a487e6b3a8"
                                   }
                               ];
    
    transactionReq.desc = @"这是展示在钱包中的描述";
    transactionReq.expired = [NSNumber numberWithLong:[NSDate date].timeIntervalSince1970];
    [MathWalletAPI sendReq:transactionReq];
}

@end
