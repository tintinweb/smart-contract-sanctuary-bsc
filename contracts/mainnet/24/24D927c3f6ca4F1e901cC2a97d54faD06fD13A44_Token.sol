/**
 *Submitted for verification at BscScan.com on 2022-11-26
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ISwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress = address(0xAEebfaCF8ebDA0e68fACb151A715b5121400b07c);//1%
    address public fundAddress1 = address(0x194726EB280c46AD2d8CCf781F2F278d6D844ca0);//0.8%
    address public fundAddress2 = address(0xd92733236F360887b99Be9Efc1dCdaC7488dF663);//0.2%
    address public teamAddress = address(0x850B0b3CfA87f5B0c2939B6A3894A78561beF8DF);// put 100W coin
    address public dappAddress = address(0xAf56a3a2e4e71B11ba7d583b71E3258E8dd52209);// allow withdraw coin
    string private _name = "TFC";
    string private _symbol = "TFC";
    uint8 private _decimals = 18;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _blackList;

    uint256 private _tTotal = 80000000 * 10 ** _decimals;
    uint256 private _initCoin = 1000000 * 10 ** _decimals;
    uint256 private withdrawCoinEveryDay=14400 * 10 ** _decimals;

    ISwapRouter public _swapRouter;
    address public _usdt = address(0x55d398326f99059fF775485246999027B3197955);
    address public _routeAddress= address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    mapping(address => bool) public _swapPairList;

    uint256 private constant MAX = ~uint256(0);

    uint256 public _buyFundFee = 200;
    uint256 public _sellFundFee = 200;

    address public _mainPair;

    constructor (){
        ISwapRouter swapRouter = ISwapRouter(_routeAddress);
        IERC20(_usdt).approve(address(swapRouter), MAX);
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), _usdt);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        _balances[teamAddress] = _initCoin;
        emit Transfer(address(0),teamAddress, _initCoin);
        _balances[address(this)] = _tTotal-_initCoin;
        emit Transfer(address(0), address(this), _tTotal-_initCoin);

        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[teamAddress] = true;
        _feeWhiteList[dappAddress] = true;
        _feeWhiteList[fundAddress] = true;
        _feeWhiteList[fundAddress1] = true;
        _feeWhiteList[fundAddress2] = true;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(!_blackList[from] && !_blackList[to], "blackList");

        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 9999 / 10000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }
        bool takeFee;
        bool isSell;
        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                takeFee = true;
            }
            if (_swapPairList[to]) {
                isSell = true;
            }
        }

        _tokenTransfer(from, to, amount, takeFee, isSell);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isSell
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;
        if (takeFee) {
            uint256 swapFee=isSell?_sellFundFee:_buyFundFee;
            uint256 swapAmount = tAmount * swapFee / 10000;
            if (swapAmount > 0) {
                feeAmount += swapAmount;
                uint256 splitFee=swapAmount/10;
                _takeTransfer(sender,fundAddress,splitFee*5);
                _takeTransfer(sender,fundAddress1,splitFee*4);
                _takeTransfer(sender,fundAddress2,splitFee);
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }
    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }
    function setFee(uint256 buyFee,uint256 sellFee) public onlyOwner {
        _buyFundFee=buyFee;
        _sellFundFee=sellFee;
    }
    function excludeMultiFromFee(address[] calldata accounts,bool excludeFee) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _feeWhiteList[accounts[i]] = excludeFee;
        }
    }
    function _multiSetSniper(address[] calldata accounts,bool isSniper) external onlyOwner() {
        for(uint256 i = 0; i < accounts.length; i++) {
            _blackList[accounts[i]] = isSniper;
        }
    }
    function claim()  public{
        require(msg.sender==dappAddress);
        _takeTransfer(address(this),dappAddress,withdrawCoinEveryDay);
    }

    receive() external payable {}
}

contract Token is AbsToken {
    constructor() AbsToken(){}
}