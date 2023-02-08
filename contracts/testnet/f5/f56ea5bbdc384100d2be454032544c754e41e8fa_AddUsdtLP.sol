/**
 *Submitted for verification at BscScan.com on 2023-02-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

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
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    //添加代币 tokenA、tokenB 交易对流动性
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
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }


    function owner() public view returns (address) {
        return _owner;
    }

    //拥有权限才能调用
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    //放弃权限
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    //转移权限
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract TokenDistributor {
    constructor (address token) {
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }
}

//买卖10%滑点，3%销毁，3%回流筑池（1.5%币、1.5%U），3%LP分红 DAPP实现，1%基金会（U到账）
abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;//营销钱包地址
    address public dividendAddress;//分红钱包地址

    string private _name;//名称
    string private _symbol;//符号
    uint8 private _decimals;//精度

    uint256 public fundFee = 100;
    uint256 public dividendFee = 300;
    uint256 public burnFee = 300;
    uint256 public lpFee = 300;

    address public mainPair;//主交易对地址

    mapping(address => bool) private _feeWhiteList;//交易税白名单

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;//总量

    ISwapRouter public _swapRouter;//dex swap 路由地址
    bool private inSwap;
    uint256 public numTokensSellToFund;

    TokenDistributor _tokenDistributor;
    address private usdt;

    uint256 private startTradeBlock;
    mapping(address => bool) private _blackList;//黑名单

    address DEAD = 0x000000000000000000000000000000000000dEaD;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply, address FundAddress, address DividendAddress){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        //BSC PancakeSwap 路由地址
        _swapRouter = ISwapRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        usdt = address(0xaB1a4d4f1D656d2450692D237fdD6C7f9146e814);

        //创建交易对
        mainPair = ISwapFactory(_swapRouter.factory()).createPair(address(this), usdt);
        //将合约的资产授权给路由地址
        _allowances[address(this)][address(_swapRouter)] = MAX;
        IERC20(usdt).approve(address(_swapRouter), MAX);

        //总量
        _tTotal = Supply * 10 ** _decimals;
        //初始代币转给营销钱包
        _balances[FundAddress] = _tTotal;
        emit Transfer(address(0), FundAddress, _tTotal);

        //营销钱包
        fundAddress = FundAddress;
        dividendAddress = DividendAddress;

        //营销地址为手续费白名单
        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[DividendAddress] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(_swapRouter)] = true;

        //营销钱包卖出条件
        numTokensSellToFund = _tTotal / 10000;

        _tokenDistributor = new TokenDistributor(usdt);
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

    function totalSupply() external view override returns (uint256) {
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
        require(owner != address(0), "approve from the zero address");
        require(spender != address(0), "approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "Transfer from the zero address");
        require(to != address(0), "Transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        //黑名单不允许转出，一般貔貅代码也是这样的逻辑
        require(!_blackList[from], "Transfer from the blackList address");

        bool takeFee = false;

        //交易扣税，from == mainPair 表示买入，to == mainPair 表示卖出
        if (from == mainPair || to == mainPair) {
            //交易未开启，只允许手续费白名单加池子，加池子即开放交易
            if (0 == startTradeBlock) {
                require(_feeWhiteList[from] || _feeWhiteList[to], "Trade not start");
                startTradeBlock = block.number;
            }

            //不在手续费白名单，需要扣交易税
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                takeFee = true;

                //杀 0、1、2 区块的交易机器人
                if (block.number <= startTradeBlock + 2) {
                    //不能把池子加入黑名单
                    if (to != mainPair) {
                        _blackList[to] = true;
                    }
                }

                //兑换资产到营销钱包
                uint256 contractTokenBalance = balanceOf(address(this));
                bool overMinTokenBalance = contractTokenBalance >= numTokensSellToFund;
                if (
                    overMinTokenBalance &&
                    !inSwap &&
                    from != mainPair
                ) {
                    swapTokenForFund(numTokensSellToFund);
                }
            }
        }

        _tokenTransfer(from, to, amount, takeFee);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        //转出者减少余额
        _balances[sender] = _balances[sender] - tAmount;

        uint256 feeAmount;
        if (takeFee) {
            feeAmount = tAmount * (lpFee + fundFee + dividendFee) / 10000;
            //营销钱包
            _takeTransfer(sender, address(this), feeAmount);
            //销毁
            uint256 burnAmount = tAmount * (burnFee) / 10000;
            _takeTransfer(sender, DEAD, burnAmount);
            //总手续费
            feeAmount = feeAmount + burnAmount;
        }

        //接收者增加余额
        tAmount = tAmount - feeAmount;
        _takeTransfer(sender, recipient, tAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        //预留加LP池子部分的代币
        uint256 lpAmount = tokenAmount * lpFee / (lpFee + dividendFee + fundFee) / 2;

        IERC20 USDT = IERC20(usdt);
        uint256 initialBalance = USDT.balanceOf(address(_tokenDistributor));

        //将代币兑换为USDT
        swapTokensForUsdt(tokenAmount - lpAmount);

        uint256 newBalance = USDT.balanceOf(address(_tokenDistributor)) - initialBalance;
        uint256 totalUsdtFee = lpFee / 2 + dividendFee + fundFee;
        //营销钱包
        USDT.transferFrom(address(_tokenDistributor), fundAddress, newBalance * fundFee / totalUsdtFee);
        USDT.transferFrom(address(_tokenDistributor), dividendAddress, newBalance * dividendFee / totalUsdtFee);

        uint256 lpUsdt = newBalance * lpFee / 2 / totalUsdtFee;
        USDT.transferFrom(address(_tokenDistributor), address(this), lpUsdt);
        //添加流动性
        addLiquidityUsdt(lpAmount, lpUsdt);
    }

    //添加USDT交易对
    function addLiquidityUsdt(uint256 tokenAmount, uint256 usdtAmount) private {
        _swapRouter.addLiquidity(
            address(this),
            usdt,
            tokenAmount,
            usdtAmount,
            0,
            0,
            fundAddress,
            block.timestamp
        );
    }

    //将代币兑换为USDT
    function swapTokensForUsdt(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(_tokenDistributor),
            block.timestamp
        );
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    //查看是否手续费白名单
    function isFeeWhiteList(address addr) external view returns (bool){
        return _feeWhiteList[addr];
    }

    //表示能接收主链币
    receive() external payable {}

    //设置交易手续费白名单
    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }


    //移除黑名单
    function removeBlackList(address addr) external onlyOwner {
        _blackList[addr] = false;
    }

    //查看是否黑名单
    function isBlackList(address addr) external view returns (bool){
        return _blackList[addr];
    }


    //提取主链币余额
    function claimBalance() public {
        payable(fundAddress).transfer(address(this).balance);
    }

    //提取代币
    function claimToken(address token, uint256 amount) public {
        IERC20(token).transfer(fundAddress, amount);
    }
}

contract AddUsdtLP is AbsToken {
    constructor() AbsToken(
    //名称
        "AiDao",
    //符号
        "AD",
    //精度
        18,
    //总量 120亿
        120 * 10 ** 8,
    //营销钱包
        address(0xCDFc73934e0B43DE10382Ab8aE65AF59C9A9C8dE),
    //分红钱包,
        address(0xc95e9D0503BDCB25a9bc8EfE0D82dE45cEd0A341)
    ){

    }
}