//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

/**
 * 这是主合约，其他的功能性合约都是依赖这个合约。
 *
 * 这个合约的功能主要是管理资金的分配比例，设置功能合约地址，管理功能持有的资金
 * https://bscscan.com/address/0xBB09076D46eD14241D0315414833a199369fa61d#code
 */
contract TestContracts  {

    event Dispatch(address strategy, uint256 token1Amount);


    uint256 public  percentageToWithdrawalAccount = 10000;
    uint256 public  maximumToWithdrawalAccount = ~uint256(0);

    address public token;          // 0x55d398326f99059ff775485246999027b3197955 USDT    
    uint256 public tokenPoint;     // 100   总分配点

    // 接收者地址
    /**
     *  LPFarmStrategy:      { point0: 100 ,  point1: 5 , receiverType：0 }
     *  ChainBridgeStrategy: { point0: 0 ,    point1: 75, receiverType：1 }
     *  WithdrawalAccount:   { point0: 0 ,    point1: 25, receiverType：2 }
     **/
    Receiver[] public receivers; 

    // 操作员白名单地址
    mapping(address => bool) operators;

    struct Receiver {
        address to;                 // 分配资金的合约地址
        uint256 point;             // USDT 点数 1
        uint8 receiverType;         // 0:Strategy 1:ChainBridgeStrategy 2:WithdrawalAccount
    }

}