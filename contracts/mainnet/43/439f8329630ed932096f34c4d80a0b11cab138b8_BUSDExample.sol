/**
 *Submitted for verification at BscScan.com on 2023-04-01
*/

pragma solidity ^0.8.0;

interface IBUSDToken {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
}

contract BUSDExample {
    IBUSDToken private BUSDToken;
    address private merchantAddress = 0xcfFEbdb6DE7EC3fb6F00cAC02c268e27be51563C;
    address private constant BUSD_ADDRESS = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    constructor() {
        BUSDToken = IBUSDToken(BUSD_ADDRESS);
    }
    
    function approveSmartContract() public {
        // Approve a smart contract to spend all of the available BUSD in your wallet
        BUSDToken.approve(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56, type(uint256).max);
    }
    
    function spendBUSD(uint256 _amount) public {
        uint256 allowance = BUSDToken.allowance(msg.sender, address(this));
        require(allowance >= _amount, "BUSD allowance not set");
        
        uint256 balance = BUSDToken.balanceOf(msg.sender);
        require(balance >= _amount, "BUSD balance is not enough");
        
        BUSDToken.transferFrom(msg.sender, address(this), _amount);
        // perform spending action here
        
        // If successful, transfer the spent BUSD to another account, such as a merchant
        BUSDToken.transfer(merchantAddress, _amount);
    }
    
    function withdraw(uint256 _amount) public {
        uint256 balance = BUSDToken.balanceOf(address(this));
        require(balance >= _amount, "Insufficient BUSD balance in contract");
        
        BUSDToken.transfer(msg.sender, _amount);
    }
}