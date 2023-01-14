/**
 *Submitted for verification at BscScan.com on 2023-01-13
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITTSPairFactory{
    function getWithdrawalfee() external  view returns (uint256);
    function getWithdrawalfeeaddress() external  view returns (address);
    function getTradefee() external  view returns (uint256);
    function getTradefeeaddress() external  view returns (address);
}

contract TTSPair{
    address public factory; // 工厂合约地址
    address public token0; // 代币1
    address public token1; // 代币2

    constructor() payable {
        factory = msg.sender;
    }
    

    // called once by the factory at time of deployment
    function initialize(address _token0, address _token1) external {
        require(msg.sender == factory, 'TTSswap: FORBIDDEN'); // sufficient check
        token0 = _token0;
        token1 = _token1;
    }

    //获取提取手续费
    function getTest() public view returns (uint256) {
        return ITTSPairFactory(factory).getTradefee();
    }
}