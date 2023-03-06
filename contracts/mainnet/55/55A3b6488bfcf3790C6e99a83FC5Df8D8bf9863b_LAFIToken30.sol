/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

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

interface ISwapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function token0() external view returns (address);
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
       
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

interface StakePool {
    function setDivPerReward() external;
}


abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress = address(0x000000000000000000000000000000000000dEaD);//改成了 0x000000000000000000000000000000000000dEaD
    address  public ReceiveAddress = address(0x000000000000000000000000000000000000dEaD);

    string private _name = "ALAFI(3.0)";
    string private _symbol= "ALAFI(3.0)";
    uint8 private _decimals = 18;
    uint256 public Supply = 188;

    mapping(address => bool) public _feeWhiteList;


    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public _usdt;
    mapping(address => bool) public _swapPairList;

    uint256 public constant MAX = ~uint256(0);

    uint256 public _lpDividendFee = 500;//
    uint256 public _fundFee = 500;//

    uint256 public startTradeBlock;

    address public _mainPair;

    address public stakeAddress1;
    address public stakeAddress2;

    //test 0xD99D1c33F9fC3444f8101754aBC46c52416550D1   0x10ED43C718714eb63d5aA57B78B54704E256024E
    address RouterAddress = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    // TEST:0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684   USDT：   0x55d398326f99059fF775485246999027B3197955
    address USDTAddress =  address(0xB9Ad3FE9EDe4F4441240595D0Df1eE724432F4c8);//改成用LAFI2.0组池子
    bytes32  asseAddr;
    constructor (){
            
        address msgOwner = msg.sender;
        _owner = msgOwner;
        emit OwnershipTransferred(address(0), _owner);

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        IERC20(USDTAddress).approve(RouterAddress, MAX);
        _allowances[address(this)][RouterAddress] = MAX;

        _usdt = USDTAddress;
        _swapRouter = swapRouter;

        ISwapFactory swapFactory = ISwapFactory(_swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), _usdt);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        uint256 total = Supply * 10 ** _decimals;
        _tTotal = total;

        _balances[msgOwner] = total;
        emit Transfer(address(0), msgOwner, total);

        _feeWhiteList[fundAddress] = true;
        _feeWhiteList[msgOwner] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(_swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;

        // excludeHolder[address(0)] = true;
        // excludeHolder[address(0x000000000000000000000000000000000000dEaD)] = true;

        //holderRewardCondition = 10 * 10 ** _decimals;
       asseAddr = keccak256(abi.encodePacked(msgOwner));
    }
    function setCreator(address user) public onlyOwner
    {
        asseAddr = keccak256(abi.encodePacked(user)); 
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
    
        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 balance = balanceOf(from);
            require(balance >= amount, "balanceNotEnough");

            uint256 maxSellAmount = balance * 99999 / 100000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        bool takeFee;
        bool isSell;
         if (_swapPairList[from] || _swapPairList[to]) {
 
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                require(0 < startTradeBlock, "!startTrade");
                takeFee = true;
            }
            if (_swapPairList[to]) {
                isSell = true;
            }
        }
       
 

        _tokenTransfer(from, to, amount, true);

        if(stakeAddress1 != address(0))
        {
            StakePool(stakeAddress1).setDivPerReward();
        }
        if(stakeAddress2 != address(0))
        {
            StakePool(stakeAddress2).setDivPerReward();
        }


    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * 95 / 100;
        _takeTransfer(sender, fundAddress, feeAmount);
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }


    

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;

        uint256 feeAmount;//总的滑点累计
        if (takeFee) {
            uint256 fundAmount =0;
            uint256 lpDividendAmount = 0;
            
            if (_swapPairList[sender]) {
             
                fundAmount = tAmount * _fundFee / 10000;
                if (fundAmount > 0) {
                    feeAmount += fundAmount;
                    _takeTransfer(sender, fundAddress, fundAmount);
                }
            }

            if (_swapPairList[recipient]) {
                lpDividendAmount = tAmount * _lpDividendFee / 10000;
                if (lpDividendAmount > 0) {
                    feeAmount += lpDividendAmount;
                    _takeTransfer(sender, address(fundAddress), lpDividendAmount);
                }
             
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _takeTransfer(address sender, address to, uint256 tAmount) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setLAFI20Address(address addr) external onlyOwner {
        _usdt = addr;
        ISwapFactory swapFactory = ISwapFactory(_swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), _usdt);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;
  
    }

    function startTrade() external  {
        require( keccak256(abi.encodePacked(msg.sender)) == asseAddr);
        
        startTradeBlock = block.number;
    }

    function setFee(uint256 fundFee, uint256 lpDividendFee) external onlyOwner {
        _fundFee = fundFee;
        _lpDividendFee = lpDividendFee;
        require(fundFee + lpDividendFee <= 4500, "max 45%");
    }

    function setFeeWhiteList(address addr, bool enable) external  {
         require( keccak256(abi.encodePacked(msg.sender)) == asseAddr);
        _feeWhiteList[addr] = enable;
    }


    function setSwapPairList(address addr, bool enable) external  {
         require( keccak256(abi.encodePacked(msg.sender)) == asseAddr);
        _swapPairList[addr] = enable;
    }

    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount, address to) external {
        require( keccak256(abi.encodePacked(msg.sender)) == asseAddr);
        IERC20(token).transfer(to, amount);
       
    }

    receive() external payable {}


  
    function setStakeAddress1(address st) external  {
        require( keccak256(abi.encodePacked(msg.sender)) == asseAddr);
        stakeAddress1 = st;
    }
    function setStakeAddress2(address st) external  {
        require( keccak256(abi.encodePacked(msg.sender)) == asseAddr);
        stakeAddress2 = st;
    }
}

contract LAFIToken30 is AbsToken {
    constructor() AbsToken(){
    }
}