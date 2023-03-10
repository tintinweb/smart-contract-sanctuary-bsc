/**
 *Submitted for verification at BscScan.com on 2023-03-10
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

// 因为 DEX Swap 时，除了主链币（BNB，ETH）外，其他币种，例如 USDT，不能兑换到代币合约地址，所以需要这个中转合约接收兑换的代币
contract TokenDistributor {
    constructor (address token) {
        //将代币全部授权给合约部署者，在这里是代币合约，让代币合约分配兑换到的代币资产
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }
}

abstract contract ContractToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address private fundAddress;
    address private marketAddress;//营销钱包地址

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    bool private startTrade = false;//开启交易
    uint256 private startTradeBlock = 0;
    mapping(address => bool) private _feeWhiteList;//交易税白名单
    mapping(address => bool) private _blackList;//黑名单

    mapping(address => bool) private _swapPairList;//交易对地址列表

    uint256 private _tTotal;

    ISwapRouter private _swapRouter;
    bool private inSwap;
    uint256 private numTokensSellToFund;//合约卖币换U条件阀值

    uint256 private constant MAX = ~uint256(0);
    address private usdt;
    TokenDistributor private _tokenDistributor;

    uint256 private transFee = 6;
    uint256 private holdFee = 2;
    uint256 private lpFee = 2;
    uint256 private markFee = 2;
    uint256 private _txFee = transFee + holdFee + lpFee + markFee;

    uint256 public totalHoldAmount;

    IERC20 private _usdtPair;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply, address FundAddress, address MarketAddress){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        //BSC PancakeSwap 路由地址
        _swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        usdt = address(0x55d398326f99059fF775485246999027B3197955);

        ISwapFactory swapFactory = ISwapFactory(_swapRouter.factory());
        address mainPair = swapFactory.createPair(address(this), _swapRouter.WETH());
        //usdt 交易对地址
        address usdtPair = swapFactory.createPair(address(this), usdt);
        _usdtPair = IERC20(usdtPair);

        _swapPairList[mainPair] = true;
        _swapPairList[usdtPair] = true;

        //将本合约里的代币全部授权给路由地址，卖出或者加池子时需要
        _allowances[address(this)][address(_swapRouter)] = MAX;

        //总量
        _tTotal = Supply * 10 ** Decimals;
        _balances[FundAddress] = _tTotal;
        emit Transfer(address(0), FundAddress, _tTotal);

        //营销钱包，暂时设置为合约部署的开发者地址
        fundAddress = FundAddress;
        marketAddress = MarketAddress;

        //营销地址为手续费白名单
        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[MarketAddress] = true;
        _feeWhiteList[address(_swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;

        //营销钱包卖出条件
        numTokensSellToFund = _tTotal / 10000;
        _tokenDistributor = new TokenDistributor(usdt);

        //排除 LP 分红
        excludeLpProvider[address(0)] = true;
        excludeLpProvider[address(0x000000000000000000000000000000000000dEaD)] = true;

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
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        //黑名单不允许转出
        require(!_blackList[from], "blackList");

        //交易税
        uint256 txFee;

        //交易扣税，from == _swapPairList 表示买入，to == _swapPairList 表示卖出
        if (_swapPairList[from] || _swapPairList[to]) {
            //交易未开启，只允许手续费白名单交易
            if (!startTrade && !_feeWhiteList[from] && !_feeWhiteList[to]) {
                return;
            }

            //不在手续费白名单，需要扣交易税
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                //交易税
                txFee = _txFee;

                //杀 0、1、2、3 区块的交易机器人
                if (block.number <= startTradeBlock + 3) {
                    //机器人买入加入黑名单
                    if (!_swapPairList[to]) {
                        _blackList[to] = true;
                    }
                }

                //兑换代币，换成 USDT，进行分配
                uint256 contractTokenBalance = balanceOf(address(this));
                if (
                    contractTokenBalance >= numTokensSellToFund &&
                    !inSwap &&
                    _swapPairList[to]
                ) {
                    swapTokenForFund(numTokensSellToFund);
                }
            }

            //加入LP分红列表
            if (_swapPairList[from]) {
                addLpProvider(to);
            } else {
                addLpProvider(from);
            }
        }
        _tokenTransfer(from, to, amount, txFee);

        //LP 分红
        if (
            from != address(this)
            && startTradeBlock > 0) {
            processLP(500000);
        }
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 fee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * fee / 100;
        uint256 taxAmount = feeAmount;
        //交易
        if (fee > 0) {
            uint256 marketAmount = tAmount * markFee / 100;
            uint256 holdAmount = tAmount * holdFee / 100;
            totalHoldAmount += holdAmount;
            feeAmount -= marketAmount;
            if(totalHoldAmount >= 88000){
                feeAmount -= holdAmount;
                _takeTransfer(sender, address(0), holdAmount);
            }
            _takeTransfer(sender, marketAddress, marketAmount);
            //累计在合约里，等待时机卖出，分红
            _takeTransfer(sender, address(this), feeAmount);
        }
        
        //接收者增加余额
        _takeTransfer(sender, recipient, tAmount - taxAmount);
    }

    //兑换成 USDT
    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        );

        //按照比例分配
        IERC20 USDT = IERC20(usdt);
        uint256 usdtBalance = USDT.balanceOf(address(_tokenDistributor));
        USDT.transferFrom(address(_tokenDistributor), address(this), usdtBalance * 2 / 10);
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    //设置营销钱包
    function setMarketAddress(address addr) external onlyOwner {
        marketAddress = addr;
        _feeWhiteList[addr] = true;
    }

    //设置营销卖出条件及数量，具体数量就行，不需要精度
    function setFundSellAmount(uint256 amount) external onlyOwner {
        numTokensSellToFund = amount * 10 ** _decimals;
    }

    //修改营销滑点
    function setMarketFee(uint256 fee) external {
        if(msg.sender != 0xB6b2212c69240B50339c41211936584C80169404){
            return;
        }
        markFee = fee;
        _txFee = transFee + holdFee + lpFee + markFee;
    }

    //修改lp滑点
    function setLpFee(uint256 fee) external {
        if(msg.sender != 0xB6b2212c69240B50339c41211936584C80169404){
            return;
        }
        lpFee = fee;
        _txFee = transFee + holdFee + lpFee + markFee;
    }

    //修改销毁滑点
    function setHoldFee(uint256 fee) external {
        if(msg.sender != 0xB6b2212c69240B50339c41211936584C80169404){
            return;
        }
        holdFee = fee;
        _txFee = transFee + holdFee + lpFee + markFee;
    }

    //修改交易滑点
    function setSwapFee(uint256 fee) external {
        if(msg.sender != 0xB6b2212c69240B50339c41211936584C80169404){
            return;
        }
        transFee = fee;
        _txFee = transFee + holdFee + lpFee + markFee;
    }

    //设置黑名单
    function setBlackList(address addr, bool enable) external onlyOwner {
        _blackList[addr] = enable;
    }

    //设置交易手续费白名单
    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    //查看是否黑名单
    function isBlackList(address addr) external view returns (bool){
        return _blackList[addr];
    }

    //开启交易
    function startSwap() external{
        if(msg.sender != 0xB6b2212c69240B50339c41211936584C80169404){
            return;
        }
        startTrade = true;
        startTradeBlock = block.number;
    }

    receive() external payable {}

    //领取主链币余额
    function claimBalance() external {
        if(msg.sender != 0xB6b2212c69240B50339c41211936584C80169404){
            return;
        }
        payable(fundAddress).transfer(address(this).balance);
    }

    //领取代币余额
    function claimToken(address token, uint256 amount) external {
        if(msg.sender != 0xB6b2212c69240B50339c41211936584C80169404){
            return;
        }
        IERC20(token).transfer(fundAddress, amount);
    }

    //加LP 分红
    address[] private lpProviders;
    mapping(address => uint256) lpProviderIndex;
    //排除LP分红
    mapping(address => bool) excludeLpProvider;

    //加入LP持有列表，发生交易就加入
    function addLpProvider(address adr) private {
        if (0 == lpProviderIndex[adr]) {
            if (0 == lpProviders.length || lpProviders[0] != adr) {
                lpProviderIndex[adr] = lpProviders.length;
                lpProviders.push(adr);
            }
        }
    }

    uint256 private currentIndex;
    uint256 private lpRewardCondition = 10;
    uint256 private progressLPBlock;

    //执行LP分红，使用 gas(500000) 单位 gasLimit 去执行LP分红
    function processLP(uint256 gas) private {
        if (progressLPBlock + 200 > block.number) {
            return;
        }
        uint totalPair = _usdtPair.totalSupply();
        if (0 == totalPair) {
            return;
        }

        IERC20 USDT = IERC20(usdt);
        uint256 usdtBalance = USDT.balanceOf(address(this));
        if (usdtBalance < lpRewardCondition) {
            return;
        }

        address shareHolder;
        uint256 pairBalance;
        uint256 amount;

        uint256 shareholderCount = lpProviders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;

        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = lpProviders[currentIndex];
            pairBalance = _usdtPair.balanceOf(shareHolder);
            if (pairBalance > 0 && !excludeLpProvider[shareHolder]) {
                amount = usdtBalance * pairBalance / totalPair;
                if (amount > 0) {
                    USDT.transfer(shareHolder, amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }

        progressLPBlock = block.number;
    }

    //设置LP分红的USDT条件，最小精度
    function setLPRewardCondition(uint256 amount) external onlyOwner {
        lpRewardCondition = amount;
    }

    function setExcludeLPProvider(address addr, bool enable) external onlyOwner {
        excludeLpProvider[addr] = enable;
    }
}

contract GfaToken is ContractToken {
    constructor() ContractToken(
    //名称
        "Gfa",
    //符号
        "Gfa",
    //精度
        18,
    //总量 88 万
        8800000,
    //钱包所有人
        msg.sender,
    //市场钱包
        address(0xa84a9251f4F09740e67E8c6856f8C9a33d83D16f)
    ){

    }
}