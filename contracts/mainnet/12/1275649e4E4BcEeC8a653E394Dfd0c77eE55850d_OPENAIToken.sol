/**
 *Submitted for verification at BscScan.com on 2022-12-25
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

// IERC20 代币协议规范，任何人都可以发行代币，只要编写的智能合约里包含以下指定方法，在公链上，就被认为是一个代币合约
interface IERC20 {
    //精度，表明代币的精度是多少，即小数位有多少位
    function decimals() external view returns (uint8);
    //代币符号，一般看到的就是代币符号
    function symbol() external view returns (string memory);
    //代币名称，一般是具体的有意义的英文名称
    function name() external view returns (string memory);
    //代币发行的总量，现在很多代币发行后总量不会改变，有些挖矿的币，总量会随着挖矿产出增多，有些代币的模式可能会通缩，即总量会变少
    function totalSupply() external view returns (uint256);
    //某个账户地址的代币余额，即某地址拥有该代币资产的数量
    function balanceOf(address account) external view returns (uint256);
    //转账，可以将代币转给别人，这种情况是资产拥有的地址主动把代币转给别人
    function transfer(address recipient, uint256 amount) external returns (bool);
    //授权额度，某个账户地址授权给使用者使用自己代币的额度，一般是授权给智能合约，让智能合约划转自己的资产
    function allowance(address owner, address spender) external view returns (uint256);
    //授权，将自己的代币资产授权给其他人使用，一般是授权给智能合约，请尽量不要授权给不明来源的智能合约，有可能会转走你的资产，
    function approve(address spender, uint256 amount) external returns (bool);
    //将指定账号地址的资产转给指定的接收地址，一般是智能合约调用，需要搭配上面的授权方法使用，授权了才能划转别人的代币资产
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    //转账事件，一般区块浏览器是根据该事件来做代币转账记录，事件会存在公链节点的日志系统里
    event Transfer(address indexed from, address indexed to, uint256 value);
    //授权事件
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// Dex Swap 路由接口，实际上接口方法比这里写的还要更多一些，本代币合约里只用到以下方法
interface ISwapRouter {
    //路由的工厂方法，用于创建代币交易对
    function factory() external pure returns (address);
    //将指定数量的代币path[0]兑换为另外一种代币path[path.length-1]，支持手续费滑点
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
    //创建代币 tokenA、tokenB 的交易对，也就是常说的 LP，LP 交易对本身也是一种代币
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        //合约创建者拥有权限，也可以填写具体的地址
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    //查看权限在哪个地址上
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

//这个合约用于暂存USDT，用于回流和营销钱包，分红
contract TokenDistributor {
    //构造参数传USDT合约地址
    constructor (address token) {
        //将暂存合约的USDT授权给合约创建者，这里的创建者是代币合约，授权数量为最大整数
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }
}

//买卖10%滑点，3%销毁，3%回流筑池（1.5%币、1.5%U），3%LP分红 DAPP实现，1%基金会（U到账）
contract OPENAIToken is IERC20, Ownable {
    //用于存储每个地址的余额数量
    mapping(address => uint256) private _balances;
    //存储授权数量，资产拥有者 owner => 授权调用方 spender => 授权数量
    mapping(address => mapping(address => uint256)) private _allowances;
    // lp分润地址
    address private lpAddress = 0xAAD0Ed4aBF646EF55D76F11FeCDF9787bEB523f0;
    // 营销地址
    address private fundAddress = 0x48c92e76E4F32942e36363DA7863D0fcA866ceAf;
    // 空投地址
    address private ktAddress = 0x7b6764F8B82Ced72B5E0ec7308bC87d138038e3F;

    string private _name;//名称
    string private _symbol;//符号
    uint8 private _decimals;//精度

    // 买入LP分红比例
    uint256 public _ruLpRate = 100;
    // 买入销毁比例
    uint256 public _ruXhRate = 100;

    // 卖出LP分红比例
    uint256 public _chuLpRate = 100;
    // 卖出销毁比例
    uint256 public _chuXhRate = 100;
    // 卖出空投比例
    uint256 public _chuKtRate = 30;

    // 转账LP分红比例
    uint256 public _zzLpRate = 0;
    // 转账销毁比例
    uint256 public _zzXhRate = 0;

    address public mainPair;//主交易对地址

    mapping(address => bool) private _feeWhiteList;//交易税白名单

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;//总量

    ISwapRouter public _swapRouter;//dex swap 路由地址
    bool private inSwap;//是否正在交易，用于合约出售代币时加锁
    uint256 public numTokensSellToFund;//合约出售代币的门槛，即达到这个数量时出售代币

    TokenDistributor public _tokenDistributor;//USDT 暂存合约，因为 swap 不允许将代币返回给代币合约地址
    address private usdt;

    uint256 private startTradeBlock;//开放交易的区块，用于杀机器人
    mapping(address => bool) private _blackList;//黑名单

    address DEAD = 0x000000000000000000000000000000000000dEaD;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (){
         _name = "OPENAI";
        _symbol = "OPENAI";
        _decimals = 18;

        //BSC PancakeSwap 路由地址
        _swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        usdt = address(0x55d398326f99059fF775485246999027B3197955);
        // _swapRouter = ISwapRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        // usdt = address(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684);

        //创建交易对
        mainPair = ISwapFactory(_swapRouter.factory()).createPair(address(this), usdt);
        //将合约的资产授权给路由地址
        _allowances[address(this)][address(_swapRouter)] = MAX;
        IERC20(usdt).approve(address(_swapRouter), MAX);

        //总量
        _tTotal = 100000000000 * 10 ** _decimals;
        //初始代币转给营销钱包
        _balances[msg.sender] = _tTotal;
        emit Transfer(address(0), msg.sender, _tTotal);

        //营销地址为手续费白名单
        _feeWhiteList[lpAddress] = true;
        _feeWhiteList[fundAddress] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(_swapRouter)] = true;

        //营销钱包卖出条件
        numTokensSellToFund = 1000 * 10 ** _decimals;

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

    // 设置买入LP分润比例
    function setRuLpRate(uint256 fee) public onlyOwner{
        _ruLpRate = fee;
    }
    // 设置买入销毁比例
    function setRuXhRate(uint256 fee) public onlyOwner{
        _ruXhRate = fee;
    }
    // 设置卖出LP分润比例
    function setChuLpRate(uint256 fee) public onlyOwner{
        _chuLpRate = fee;
    }
    // 设置卖出销毁比例
    function setChuXhRate(uint256 fee) public onlyOwner{
        _chuXhRate = fee;
    }
    // 设置转账LP分润比例
    function setZzLpRate(uint256 fee) public onlyOwner{
        _zzLpRate = fee;
    }
    // 设置转账销毁比例
    function setZzXhRate(uint256 fee) public onlyOwner{
        _zzXhRate = fee;
    }
    // 设置卖出空投比例
    function setChuKtRate(uint256 fee) public onlyOwner{
        _chuKtRate = fee;
    }
    // 设置lp粉润地址
    function setLpAddress(address account) public onlyOwner{
        if(lpAddress != account){
            lpAddress = account;
        }
    }
    // 设置合约出售代币的门槛，即达到这个数量时出售代币
    function setMenkan(uint256 num) public onlyOwner{
        numTokensSellToFund = num;
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
        // 买
        if(takeFee && sender == mainPair){
            feeAmount = tAmount * (_ruLpRate + _ruXhRate) / 10000;
            //营销钱包
            _takeTransfer(sender, address(this), feeAmount);
        }else if(takeFee && recipient == mainPair){
            // 卖
            feeAmount = tAmount * (_chuLpRate + _chuXhRate) / 10000;
            //营销钱包
            _takeTransfer(sender, address(this), feeAmount);
            //空投
            uint256 burnAmount = tAmount * (_chuKtRate) / 10000;
            _takeTransfer(sender, ktAddress, burnAmount);
            //总手续费
            feeAmount = feeAmount + burnAmount;
        }else if(takeFee){
            // 转账
            // 卖
            feeAmount = tAmount * (_zzLpRate + _zzXhRate) / 10000;
            //营销钱包
            _takeTransfer(sender, address(this), feeAmount);
        }

        //接收者增加余额
        tAmount = tAmount - feeAmount;
        _takeTransfer(sender, recipient, tAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
       
        IERC20 USDT = IERC20(usdt);
        uint256 initialBalance = USDT.balanceOf(address(_tokenDistributor));

        //将代币兑换为USDT
        swapTokensForUsdt(tokenAmount);

        uint256 newBalance = USDT.balanceOf(address(_tokenDistributor)) - initialBalance;
        
        //营销钱包
        USDT.transferFrom(address(_tokenDistributor), lpAddress, newBalance/2);
        USDT.transferFrom(address(_tokenDistributor), fundAddress, newBalance/2);

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
}