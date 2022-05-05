/**
 *Submitted for verification at BscScan.com on 2022-05-05
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

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;
    address public dividendAddress;
    address public lpReceiveAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 public fundFee = 300;
    uint256 public lpFee = 200;
    uint256 public dividendFee = 100;

    address public mainPair;

    mapping(address => bool) private _feeWhiteList;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    bool private inSwap;
    uint256 public numTokensSellToFund;

    TokenDistributor _tokenDistributor;
    address private _usdt;

    uint256 private startTradeBlock;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply, address FundAddress, address DividendAddress, address LPReceiveAddress){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address usdt = address(0x55d398326f99059fF775485246999027B3197955);

        _swapRouter = swapRouter;
        _usdt = usdt;

        mainPair = ISwapFactory(swapRouter.factory()).createPair(address(this), usdt);
        _allowances[address(this)][address(swapRouter)] = MAX;
        IERC20(usdt).approve(address(swapRouter), MAX);

        _tTotal = Supply * 10 ** _decimals;
        _balances[FundAddress] = _tTotal;
        emit Transfer(address(0), FundAddress, _tTotal);

        fundAddress = FundAddress;
        dividendAddress = DividendAddress;
        lpReceiveAddress = LPReceiveAddress;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[DividendAddress] = true;
        _feeWhiteList[LPReceiveAddress] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;

        numTokensSellToFund = _tTotal / 100000;

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
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        bool takeFee = false;
        if (to == mainPair && 0 == startTradeBlock) {
            require(_feeWhiteList[from], "Trade not start");
            startTradeBlock = block.number;
        }

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            if (from == mainPair || to == mainPair) {
                if (block.number < startTradeBlock + 4) {
                    _funTransfer(from, to, amount);
                    return;
                }
            }

            takeFee = true;
            if (mainPair == to) {
                uint256 contractTokenBalance = balanceOf(address(this));
                bool overMinTokenBalance = contractTokenBalance >= numTokensSellToFund;
                if (
                    overMinTokenBalance &&
                    !inSwap
                ) {
                    swapTokenForFund(numTokensSellToFund);
                }
            }
        }
        if (!_feeWhiteList[from]) {
            uint256 maxSellAmount = balanceOf(from) * 999 / 1000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }
        _tokenTransfer(from, to, amount, takeFee);
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * 75 / 100;
        _takeTransfer(
            sender,
            fundAddress,
            feeAmount
        );
        _takeTransfer(sender, recipient, tAmount - feeAmount);
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
            feeAmount = tAmount * (lpFee + dividendFee + fundFee) / 10000;
            _takeTransfer(sender, address(this), feeAmount);
        }

        tAmount = tAmount - feeAmount;
        _takeTransfer(sender, recipient, tAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        uint256 allFeeRate = lpFee + dividendFee + fundFee;
        allFeeRate += allFeeRate;
        //allFeeRate = 2*(lpFee + dividendFee + fundFee)

        uint256 lpAmount = tokenAmount * lpFee / allFeeRate;
        allFeeRate -= lpFee;
        //allFeeRate = 2*(lpFee + dividendFee + fundFee)-lpFee

        swapTokensForUsdt(tokenAmount - lpAmount);

        IERC20 USDT = IERC20(_usdt);
        uint256 usdtBalance = USDT.balanceOf(address(_tokenDistributor));

        USDT.transferFrom(address(_tokenDistributor), dividendAddress, usdtBalance * (dividendFee + dividendFee) / allFeeRate);
        USDT.transferFrom(address(_tokenDistributor), fundAddress, usdtBalance * (fundFee + fundFee) / allFeeRate);

        uint256 lpUsdt = usdtBalance * lpFee / allFeeRate;
        USDT.transferFrom(address(_tokenDistributor), address(this), lpUsdt);
        addLiquidityUsdt(lpAmount, lpUsdt);
    }

    function addLiquidityUsdt(uint256 tokenAmount, uint256 usdtAmount) private {
        _swapRouter.addLiquidity(
            address(this),
            _usdt,
            tokenAmount,
            usdtAmount,
            0,
            0,
            lpReceiveAddress,
            block.timestamp
        );
    }

    function swapTokensForUsdt(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
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

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setDividendAddress(address addr) external onlyOwner {
        dividendAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setLPReceiveAddress(address addr) external onlyOwner {
        lpReceiveAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setFeeRate(uint256 FundFee, uint256 LPFee, uint256 DividendFee) external onlyOwner {
        fundFee = FundFee;
        lpFee = LPFee;
        dividendFee = DividendFee;
    }

    receive() external payable {}

    function setFundSellAmount(uint256 amount) external onlyFunder {
        numTokensSellToFund = amount * 10 ** _decimals;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyFunder {
        _feeWhiteList[addr] = enable;
    }

    modifier onlyFunder() {
        require(_owner == msg.sender || fundAddress == msg.sender, "!Funder");
        _;
    }

    function claimBalance() public {
        payable(dividendAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount) public {
        IERC20(token).transfer(dividendAddress, amount);
    }
}

contract TQToken is AbsToken {
    constructor() AbsToken(
        "TangQian",
        "TQ",
        18,
        300000,
        address(0x00B4ACD0d9De6347695D92529FAc54c0F8E6fdAc),
        address(0xB8c3a604bE0cE2280B915CB4B33bDF6ca92Ff017),
        address(0x5F44Ed761CF80699F589f7f3f268a18930b47674)
    ){

    }
}