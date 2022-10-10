/**
 *Submitted for verification at BscScan.com on 2022-10-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// IERC20 代币协议规范
interface IERC20 {
    // 代币精度，即小数位有多少位
    function decimals() external view returns (uint8);

    // 代币符号
    function symbol() external view returns (string memory);

    // 代币名称
    function name() external view returns (string memory);

    // 代币发行的总量
    function totalSupply() external view returns (uint256);

    // 指定账户地址的代币余额
    function balanceOf(address account) external view returns (uint256);

    // 转账，代币拥有者主动把自己的代币转给别人
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    // 授权额度，某个账户地址授权给使用者使用自己代币的额度，一般是授权给智能合约，让智能合约划转自己的资产
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    // 授权，将自己的代币资产授权给其他人使用，一般是授权给智能合约
    function approve(address spender, uint256 amount) external returns (bool);

    // 转账，将指定账号地址的代币转给指定的接收地址，一般是智能合约调用，需配合授权方法使用
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    // 转账事件
    event Transfer(address indexed from, address indexed to, uint256 value);

    // 授权事件
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    // 测试
    event Test(uint256 value);
    event Test(string topic, uint256 v1, uint256 v2, uint256 v3, uint256 v4);
}

// PancakeSwap 路由接口
interface ISwapRouter {
    // 路由工厂，用于创建代币交易对
    function factory() external pure returns (address);

    // 将代币path[0]兑换为另外一种代币path[1]
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    // 添加代币 tokenA、tokenB 交易对流动性
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );
}

// 路由工厂接口，用于创建交易对
interface ISwapFactory {
    // 创建代币 tokenA、tokenB 的交易对
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

// 合约拥有者对权限的控制和管理
abstract contract Ownable {
    // 合约拥有者
    address private _owner;

    // 合约拥有者权限转移事件
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        // 将合约部署者设定为合约拥有者，用于控制权限
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    // 查看合约拥有者地址
    function owner() public view returns (address) {
        return _owner;
    }

    // 合约拥有者修改器，限制拥有权限才能调用
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    // 合约拥有者放弃自己的权限，等于转化为无主合约
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    // 合约拥有者将权限转移给新的地址
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// USDT 暂存合约，用于回流、营销以及分红
contract TokenDistributor {
    // 构造参数传 USDT 合约地址
    constructor(address token) {
        // 将暂存合约的 USDT 授权给合约创建者，这里的创建者是代币合约，授权数量为最大整数
        IERC20(token).approve(msg.sender, ~uint256(0));
    }
}

// NFT 合约
interface NFTContract {
    // reward 进行分红
    function reward(uint256 rewardTotal) external;
}

// 复利机制，日复利2.08%
// 复利一年结束
// 买滑点8%卖手续费共10％点 。
// 2％nft分红u，
// 5％点回流池子u。
// 1％点分红营销钱包u。
// 卖2%销毁
// 所有分红都是分u
// 复利要有在钱包交易才能刷新复利，不然安当时买币复利
abstract contract AbsToken is IERC20, Ownable {
    // 代币供应总量
    uint256 private _tTotal;

    // 用于存储每个地址的代币余额数量
    mapping(address => uint256) private _balances;

    // 存储授权数量，资产拥有者 owner => 授权调用方 spender => 授权数量
    mapping(address => mapping(address => uint256)) private _allowances;

    address private fundAddress; // 营销钱包地址
    address private dividendAddress; // nft合约地址

    string private _symbol; // 代币符号
    string private _name; // 代币名称
    uint8 private _decimals; // 代币精度

    // 买滑点8%，卖10%
    uint256 private fundFee = 100; // 1%营销钱包分红
    uint256 private dividendFee = 200; // 2%nft分红
    uint256 private lpFee = 500; // 5%回流
    uint256 private burnFee = 200; // 2%卖出销毁

    address private mainPair; // 主交易对地址
    uint256 private constant MAX = ~uint256(0); // 无限大

    ISwapRouter private _swapRouter; //DEX Swap 路由地址

    // 合约出售代币的门槛，即达到这个数量时出售代币，兑换到营销钱包
    // 到达3000个币量，就进行兑换
    uint256 private numTokensSellToFund;

    // USDT 暂存合约，因为 Swap 不允许将代币返回给代币合约地址
    TokenDistributor private _tokenDistributor;
    address private usdt;

    //uint256 private startTradeBlock; // 开放交易的区块，用于杀套利机器人
    mapping(address => bool) private _blackList; // 黑名单

    mapping(address => bool) private _feeWhiteList; // 交易免税白名单
    address DEAD = 0x000000000000000000000000000000000000dEaD; // 销毁地址

    //------------------------计算复利------------------------------------
    mapping(address => uint256) private _addressAmount; // 保存每个钱包最后交易余额
    mapping(address => uint256) private _addressLastSwapTime; // 保存每个钱包最后交易时间
    mapping(address => uint256) private _addressProfit; // 保存每个钱包应领取的复利收益，领取完成之后清零
    uint256 private _daySecond = 86400; //每天一共有多少秒
    uint256 private _dayProfitRate = 208; //每天的复利
    uint256 private constant _dayProfitDivBase = 10000; //每天的复利的分母
    //-----------------------------end-------------------------------

    
    uint256 private _startTimeDeploy; // 合约部署时间

    bool private inSwap; // 合约出售代币加锁，防止重入攻击
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(
        string memory Name,
        string memory Symbol,
        uint8 Decimals,
        uint256 Supply
    ) {
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        _startTimeDeploy = block.timestamp;

        // BSC PancakeSwap 路由合约地址
        _swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        // BSC usdt 代币合约地址
        usdt = address(0x55d398326f99059fF775485246999027B3197955);

        // 创建交易对
        mainPair = ISwapFactory(_swapRouter.factory()).createPair(
            address(this),
            usdt
        );

        // 将代币合约的资产授权给路由地址，用于代币交易
        _allowances[address(this)][address(_swapRouter)] = MAX;

        // 将usdt合约的资产授权给路由地址，用于兑换 usdt
        IERC20(usdt).approve(address(_swapRouter), MAX);

        // 代币实际供应总量
        uint256 tTotal = Supply * 10**_decimals;
        _tTotal = tTotal;

        // 初始代币转给发布者
        _balances[msg.sender] = _tTotal;
        emit Transfer(address(0), msg.sender, _tTotal);

        // 存币钱包、营销钱包、分红钱包等内部账号加入手续费白名单

        _feeWhiteList[msg.sender] = true; // 部署者地址
        _feeWhiteList[address(this)] = true; // 本币合约地址
        _feeWhiteList[address(_swapRouter)] = true; // 路由地址

        // 用于将各种税兑换为usdt的暂存合约
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

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] =
                _allowances[sender][msg.sender] -
                amount;
        }
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
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
        // 校验地址和金额的有效值
        require(from != address(0), "Transfer from the zero address");
        require(to != address(0), "Transfer to the zero address");
        //require(amount > 0, "Transfer amount must be greater than zero");

        // 黑名单不允许转出
        require(!_blackList[from], "Transfer from the blackList address");

        bool takeFee = false; // 用于标记是否收取税费
        bool selling = false; // 用于标记是买入操作还是卖出操作

        // 交易扣税，from == mainPair 表示买入，to == mainPair 表示卖出
        // 交易税只针对买入和卖出操作，普通账户之间的转账不收费用
        if (from == mainPair || to == mainPair) {
            if (to == mainPair) {
                // to == mainPair 表示卖出
                // 因为买入和卖出的税率不同，需要做标记
                selling = true;
                emit Test(11);
            }

            // 不在手续费白名单，需要扣交易税
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                takeFee = true;
                emit Test(13);
                // 收取的各种税费进行兑换，转到制定的到营销钱包、分红钱包
                // 兑换具有条件，合约资产必须超过门槛值，不能每一笔交易就进行兑换
                uint256 contractTokenBalance = balanceOf(address(this));
                bool overMinTokenBalance = contractTokenBalance >=
                    numTokensSellToFund;
                if (overMinTokenBalance && !inSwap && from != mainPair) {
                    emit Test(15);
                    swapTokenForFund(numTokensSellToFund);
                }
            }
        }
        emit Test(16);
        // 计算各种费用，进行代币转账
        _tokenTransfer(from, to, amount, takeFee, selling);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool selling
    ) private {
        // 转出者余额扣除本次交易额
        uint256 realAmount = tAmount;
        _balances[sender] -= realAmount;

        // 根据是否免除交易费标志takeFee，计算收取的各种费用
        uint256 feeAmount; // 总费用数量
        uint256 burnAmount; // 销毁数量
        if (takeFee && tAmount > 0) {
            // 收取各种费用，收取后放入本合约中
            if (selling) {
                emit Test(20);
                // 卖出收取交易税、分红税、流动性税、销毁税 wzb
                feeAmount =
                    (realAmount * (fundFee + dividendFee + lpFee)) /
                    10000;
                if (feeAmount > 0) {
                    _takeTransfer(sender, address(this), feeAmount);
                }

                // 按比例销毁
                burnAmount = (realAmount * burnFee) / 10000;
                if (feeAmount > 0) {
                    _takeTransfer(sender, DEAD, burnAmount);
                }

                // 计算总费用数量
                feeAmount += burnAmount;
            } else {
                emit Test(21);
                // 买入收取交易税、分红税、流动性税
                feeAmount =
                    (realAmount * (fundFee + dividendFee + lpFee)) /
                    10000;
                if (feeAmount > 0) {
                    _takeTransfer(sender, address(this), feeAmount);
                }
            }
        }

        // 计算接收者应该得到的金额
        uint256 recipientRealAmount = realAmount - feeAmount;

        //计算复制 //每交易一次就计算一次
        countProfit(sender, recipient, realAmount, recipientRealAmount);

        // 接收者增加余额
        _takeTransfer(sender, recipient, recipientRealAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        // 预留加LP池子的代币
        uint256 lpAmount = (tokenAmount * lpFee) / (lpFee + dividendFee + fundFee) / 2;

        // 将代币兑换为 USDT
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount - lpAmount,
            0, // accept any amount of usdt
            path,
            address(_tokenDistributor),
            block.timestamp
        );
        // emit Test("swap-usdt", balanceOf(address(this)),tokenAmount,tokenAmount-lpAmount,lpAmount);

        IERC20 USDT = IERC20(usdt);
        uint256 usdtBalance = USDT.balanceOf(address(_tokenDistributor));
        uint256 totalUsdtFee = dividendFee + fundFee + lpFee / 2;

        // 营销税到营销钱包
        uint256 usdtFund = (usdtBalance * fundFee) / totalUsdtFee;
        USDT.transferFrom(address(_tokenDistributor), fundAddress, usdtFund);

        // nft分红到nft钱包
        uint256 usdtDividend = (usdtBalance * dividendFee) / totalUsdtFee;
        USDT.transferFrom(
            address(_tokenDistributor),
            dividendAddress,
            usdtDividend
        );

        // 流动性usdt到合约
        uint256 lpUsdt = usdtBalance - usdtFund - usdtDividend;
        USDT.transferFrom(address(_tokenDistributor), address(this), lpUsdt);

        // 流动性注入
        _swapRouter.addLiquidity(
            address(this),
            usdt,
            lpAmount,
            lpUsdt,
            0,
            0,
            fundAddress,
            block.timestamp
        );
    }

    // 代币资产转移
    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    // 允许接收主链币
    receive() external payable {}

    // 设置交易手续费白名单
    // 参数 enable=true 为加入白名单， enable=false 为从白名单移除
    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    // 查看是否在交易手续费白名单中
    function isFeeWhiteList(address addr) external view returns (bool) {
        return _feeWhiteList[addr];
    }

    // 设置黑名单
    // 参数 enable=true 为加入黑名单， enable=false 为从黑名单移除
    function setFeeBlackList(address addr, bool enable) external onlyOwner {
        _blackList[addr] = enable;
    }

    // 查看是否在黑名单中
    function isBlackList(address addr) external view returns (bool) {
        return _blackList[addr];
    }


    //设置滑点换U阀值
    function setNumTokensSellToFund(uint256 num) external onlyOwner {
        numTokensSellToFund = num;
    }

    function getNumTokensSellToFund() external view returns (uint256) {
        return numTokensSellToFund;
    }

    // 营销钱包地址
    function setFundAddress(address addr) external onlyOwner {
        _feeWhiteList[addr] = true;
        fundAddress = addr;
    }

    function getFundAddress() external view returns (address) {
        return fundAddress;
    }

    // NFT钱包地址
    function setDividendAddress(address addr) external onlyOwner {
        _feeWhiteList[addr] = true;
        dividendAddress = addr;
    }

    function getDividendAddress() external view returns (address) {
        return dividendAddress;
    }
    
    // 提取合约主链币余额到营销账户
    function claimBalance() external onlyOwner {
        payable(fundAddress).transfer(address(this).balance);
    }

    //计算复利
    function countProfit(
        address from,
        address to,
        uint256 amount,
        uint256 recipientRealAmount
    ) private {
        //复利一年，之后不再复利
        if (block.timestamp - _startTimeDeploy > 3600){
            emit Test(100);
            return;
        }     
        emit Test(101);
        if (to==address(this) && amount == 0 && recipientRealAmount == 0) {
            emit Test(102);
             //当接收地址为币合约 而且转入金额为0 发放复利
            if (block.timestamp - _addressLastSwapTime[from] > 1 && _addressLastSwapTime[from]>0) {
                _addressProfit[from] = _addressProfit[from] + _addressAmount[from] * (block.timestamp - _addressLastSwapTime[from]) * _dayProfitRate / _dayProfitDivBase / _daySecond;
                               
                //发放复利
                _balances[from] = _balances[from] + _addressProfit[from];
                emit Transfer(address(0), from, _addressProfit[from]);
                _addressProfit[from]=0;
                if (block.timestamp - _addressLastSwapTime[from] >=600){
                    _addressAmount[from] = balanceOf(from);
                }               
                _addressLastSwapTime[from] = block.timestamp;
            }      
        } else {
            emit Test(103);
            //计算复利
            if (from == mainPair || to == mainPair) {
                emit Test(104);
                //swap交易计算
                if (from == mainPair) {
                    emit Test(105);
                    //买入
                    if ( block.timestamp - _addressLastSwapTime[to] > 1 ) {
                        _addressProfit[to] = _addressProfit[to] + _addressAmount[to] * (block.timestamp - _addressLastSwapTime[to]) * _dayProfitRate / _dayProfitDivBase / _daySecond;
                        _addressAmount[to] = _addressAmount[to] + recipientRealAmount;
                        _addressLastSwapTime[to] = block.timestamp;
                    }
                }
                if (to == mainPair) {
                    emit Test(106);
                    if ( block.timestamp - _addressLastSwapTime[from] > 1 ) {
                        _addressProfit[from] = _addressProfit[from] + _addressAmount[from] * (block.timestamp - _addressLastSwapTime[from]) * _dayProfitRate / _dayProfitDivBase /  _daySecond;
                        if(_addressAmount[from]>=amount){
                            _addressAmount[from] = _addressAmount[from] - amount;
                        }else{
                            _addressAmount[from] = balanceOf(from) - amount;
                        }                      
                        _addressLastSwapTime[from] = block.timestamp;
                    }
                }
            } else {
                emit Test(107);
                //转账时计算
                if (block.timestamp - _addressLastSwapTime[from] > 1) {
                    emit Test(108);
                    _addressProfit[from] =  _addressProfit[from] + _addressAmount[from] * (block.timestamp - _addressLastSwapTime[from]) * _dayProfitRate / _dayProfitDivBase / _daySecond;
                    if(_addressAmount[from]>=amount){
                        _addressAmount[from] = _addressAmount[from] - amount;
                    }else{
                        _addressAmount[from] = balanceOf(from) - amount;
                    }
                    _addressLastSwapTime[from] = block.timestamp;
                }
                if (block.timestamp - _addressLastSwapTime[to] > 1) {
                    emit Test(109);
                    _addressProfit[to] = _addressProfit[to] + _addressAmount[to] * (block.timestamp - _addressLastSwapTime[to]) * _dayProfitRate / _dayProfitDivBase / _daySecond;
                    _addressAmount[to] = _addressAmount[to] + recipientRealAmount;
                    _addressLastSwapTime[to] = block.timestamp;
                }
            }
        }
    }
}

// MyCoin合约就是代币合约，这里名称为MyCoin，符号位MCN
// 所有参数按照需求可自行修改
contract U13Token is AbsToken {
    constructor()
        AbsToken(
            "U13Token",
            "U13Token",
            18,
            1 * 10**8
        )
    {}
}