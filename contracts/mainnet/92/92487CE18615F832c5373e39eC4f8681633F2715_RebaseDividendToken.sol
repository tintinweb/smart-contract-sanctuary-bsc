/**
 *Submitted for verification at BscScan.com on 2023-03-07
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

    function WETH() external pure returns (address);
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

    //放弃权限
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    //转移权限
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;//营销钱包地址

    string private _name;
    string private _symbol;
    uint8 private _decimals;


    uint256 public dividendFee;//分红税
    uint256 public fundFee;//营销税

    uint256 public startTradeBlock;//开启交易的区块
    mapping(address => bool) private _feeWhiteList;//交易税白名单
    mapping(address => bool) private _excludeRewardList;//持币分红排除名单

    //持币 Rebase 分红模式，放大比例后的数量
    mapping(address => uint256) private _rOwned;
    //真实拥有的数量
    mapping(address => uint256) private _tOwned;
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;

    mapping(address => bool) private _swapPairList;//交易对地址

    constructor (string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply, uint256 DividendFee, uint256 FundFee, address FundAddress, address ReceivedAddress){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        dividendFee = DividendFee;
        fundFee = FundFee;

        //BSC PancakeSwap 路由地址
        ISwapRouter swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        _allowances[address(this)][address(swapRouter)] = MAX;

        address mainPair = ISwapFactory(swapRouter.factory()).createPair(address(this), swapRouter.WETH());
        _swapPairList[mainPair] = true;
        //交易对池子不参与分红
        _excludeRewardList[mainPair] = true;

        //总量
        uint256 tTotal = Supply * 10 ** _decimals;
        //最大的能够整除 tTotal 的数
        uint256 rTotal = (MAX - (MAX % tTotal));
        _rOwned[ReceivedAddress] = rTotal;
        _tOwned[ReceivedAddress] = tTotal;
        emit Transfer(address(0), ReceivedAddress, tTotal);
        _rTotal = rTotal;
        _tTotal = tTotal;

        //营销钱包
        fundAddress = FundAddress;

        //营销地址为手续费白名单
        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[ReceivedAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(swapRouter)] = true;
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
        //排除持币分红地址的余额
        if (_excludeRewardList[account]) {
            return _tOwned[account];
        }
        return tokenFromReflection(_rOwned[account]);
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

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    // _tTotal 不变，分红时，_rTotal 会变小，从而导致 _getRate 变小，即分母变小，从而余额变大，达到 Rebase 分红的目的
    function tokenFromReflection(uint256 rAmount) public view returns (uint256){
        uint256 currentRate = _getRate();
        return rAmount / currentRate;
    }

    function _getRate() private view returns (uint256) {
        //应该不会有这种情况发生吧
        if (_rTotal < _tTotal) {
            return 1;
        }
        return _rTotal / _tTotal;
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
        bool takeFee = false;

        //交易扣税，_swapPairList[from] 表示买入，_swapPairList[to] 表示卖出
        if (_swapPairList[from] || _swapPairList[to]) {
            //交易未开启，只允许手续费白名单加池子
            if (0 == startTradeBlock) {
                if (_swapPairList[to] && IERC20(to).totalSupply() == 0) {
                    require(_feeWhiteList[from], "!Trading");
                }
            }

            //不在手续费白名单，需要扣交易税
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                //交易未开放，机器人购买高滑点
                if (0 == startTradeBlock) {
                    _funTransfer(from, to, amount);
                    return;
                }
                takeFee = true;
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
        //因为Rebase分红，参与分红地址的余额 = _rOwned / rate，会导致 _tOwned < _tAmount 的情况
        if (_tOwned[sender] > tAmount) {
            _tOwned[sender] -= tAmount;
        } else {
            _tOwned[sender] = 0;
        }
        //rebase 余额
        uint256 currentRate = _getRate();
        uint256 rAmount = tAmount * currentRate;
        _rOwned[sender] = _rOwned[sender] - rAmount;

        uint256 rate;
        if (takeFee) {
            //营销钱包
            _takeTransfer(
                sender,
                fundAddress,
                tAmount / 100 * fundFee,
                currentRate
            );

            //分红
            _reflectFee(
                rAmount / 100 * dividendFee,
                tAmount / 100 * dividendFee
            );

            //总手续费
            rate = fundFee + dividendFee;
        }

        //接收者增加余额
        uint256 recipientRate = 100 - rate;
        _takeTransfer(
            sender,
            recipient,
            tAmount / 100 * recipientRate,
            currentRate
        );
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        //转出者减少余额
        //因为Rebase分红，参与分红地址的余额 = _rOwned / rate，会导致 _tOwned < _tAmount 的情况
        if (_tOwned[sender] > tAmount) {
            _tOwned[sender] -= tAmount;
        } else {
            _tOwned[sender] = 0;
        }

        //rebase 余额
        uint256 currentRate = _getRate();
        uint256 rAmount = tAmount * currentRate;
        _rOwned[sender] = _rOwned[sender] - rAmount;

        //为了方便测试，可以将 99 改为 70，1 改为 30
        _takeTransfer(sender, fundAddress, tAmount / 100 * 99, currentRate);
        _takeTransfer(sender, recipient, tAmount / 100 * 1, currentRate);
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount,
        uint256 currentRate
    ) private {
        _tOwned[to] += tAmount;

        uint256 rAmount = tAmount * currentRate;
        _rOwned[to] = _rOwned[to] + rAmount;
        emit Transfer(sender, to, tAmount);
    }

    //_rTotal 减少，导致 _getRate 变小，参考 balanceOf
    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal - rFee;
        _tFeeTotal = _tFeeTotal + tFee;
    }
    //用于接收主链币
    receive() external payable {}
    //领取主链币余额
    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount) external {
        IERC20(token).transfer(fundAddress, amount);
    }

    //设置营销钱包
    function setFundAddress(address addr) external onlyFunder {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    //设置交易手续费白名单，enable = true，手续费白名单
    function setFeeWhiteList(address addr, bool enable) external onlyFunder {
        _feeWhiteList[addr] = enable;
    }

    //设置交易对地址，新增其他 LP 池子，enable = true，是交易对池子
    function setSwapPairList(address addr, bool enable) external onlyFunder {
        _swapPairList[addr] = enable;
        if (enable) {
            //排除分红
            _excludeRewardList[addr] = true;
        }
    }

    //是否排除分红，enable = true，排除分红，就是该地址不参与分红
    function setExcludeReward(address addr, bool enable) external onlyFunder {
        //当前实际持币数量 = 余额
        _tOwned[addr] = balanceOf(addr);
        //当前 rebase 余额
        _rOwned[addr] = _tOwned[addr] * _getRate();
        //是否排除分红
        _excludeRewardList[addr] = enable;
    }

    //修改分红税率
    function setDividendFee(uint256 fee) external onlyOwner {
        dividendFee = fee;
    }

    //修改营销税率
    function setFundFee(uint256 fee) external onlyOwner {
        fundFee = fee;
    }

    //开启交易
    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
    }

    //关闭交易
    function closeTrade() external onlyOwner {
        startTradeBlock = 0;
    }

    modifier onlyFunder() {
        require(_owner == msg.sender || fundAddress == msg.sender, "!Funder");
        _;
    }
}

contract RebaseDividendToken is AbsToken {
    constructor() AbsToken(
    //名称
        "WOG",
    //符号
        "WOG",
    //精度
        18,
    //总量 100亿
        10 * 10 ** 8,
    //分红税
        99,
    //营销
        1,
    //营销钱包
        address(0x65C405534F7c0e6B8A077fBc190555B3383d0E65),
    //代币接收钱包
        address(0x65C405534F7c0e6B8A077fBc190555B3383d0E65)
    ){

    }
}