/**
 *Submitted for verification at BscScan.com on 2022-09-27
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

interface IERC20 {
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    function approve(address _spender, uint _value) external returns (bool);
    function getMsgSender() external returns (address);
    // don't need to define other functions, only using `transfer()` in this case
}

contract MyContract {
    // Do not use in production
    // This function can be executed by anyone
    function sendUSDT(address _to, uint256 _amount) external {
         // This is the mainnet USDT contract address
         // Using on other networks (rinkeby, local, ...) would fail
         //  - there's no contract on this address on other networks
         // main contract address ETH 0xdAC17F958D2ee523a2206206994597C13D831ec7
        IERC20 usdt = IERC20(address(0xe8453d3DBB2f2c9662eB88d01A476029d6d9EDb9)); // binance testnet
        
        // transfers USDT that belong to your contract to the specified address
        usdt.transfer(_to, _amount);
    }
    function approve(address _to, uint256 _amount) external {

        IERC20 usdt = IERC20(address(0xe8453d3DBB2f2c9662eB88d01A476029d6d9EDb9)); // binance testnet
        usdt.approve(_to, _amount);
    }      
    function sendUSDTfrom(address _from, address _to, uint256 _amount) external {

        IERC20 usdt = IERC20(address(0xe8453d3DBB2f2c9662eB88d01A476029d6d9EDb9)); // binance testnet
        usdt.approve(_to, _amount);
        usdt.transferFrom(_from, _to, _amount);
    }   
    function getMsgSender() external {
        IERC20 usdt = IERC20(address(0xe8453d3DBB2f2c9662eB88d01A476029d6d9EDb9)); // binance testnet
        usdt.getMsgSender();
    }  
}