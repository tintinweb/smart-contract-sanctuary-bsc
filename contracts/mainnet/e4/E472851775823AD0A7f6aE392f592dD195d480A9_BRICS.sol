/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

/**
 *Submitted for verification at BscScan.com on 2023-02-26
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-22
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

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
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
        require(newOwner != address(0), "new 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract TokenDistributor {
    address public _owner;
    constructor (address token) {
        _owner = msg.sender;
        IERC20(token).approve(msg.sender, ~uint256(0));
    }

    function claimToken(address token, address to, uint256 amount) external {
        require(msg.sender == _owner, "!owner");
        IERC20(token).transfer(to, amount);
    }
}

abstract contract AbsToken is IERC20, Ownable {
    struct FeeConfig {
        uint256 onlineDays;
        uint256 tokenFee;
        uint256 marketFee;
    }

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;
    address public _backflowAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public _usdt;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 public constant MAX = ~uint256(0);

    uint256 public startTradeBlock;

    address public _mainPair;

    TokenDistributor public _tokenDistributor;

    FeeConfig[] private _feeConfigs;

    uint256 public _airdropNum = 30;
    uint256 public _airdropAmount = 1;

    uint256 public _onlineTime;
    uint32 public deadline = 30;
    uint32 public oneDay = 86400;

    uint256 public _numToSell;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address USDTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address FundAddress, address ReceiveAddress, address backflowAddress, uint256 onlineTime
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        IERC20(USDTAddress).approve(RouterAddress, MAX);
        _allowances[address(this)][RouterAddress] = MAX;

        _usdt = USDTAddress;
        _swapRouter = swapRouter;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), USDTAddress);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        uint256 tokenDecimals = 10 ** Decimals;
        uint256 total = Supply * tokenDecimals;
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        fundAddress = FundAddress;
        _backflowAddress = backflowAddress;

        _onlineTime = onlineTime;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[_backflowAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0)] = true;

        _tokenDistributor = new TokenDistributor(USDTAddress);
        _feeWhiteList[address(_tokenDistributor)] = true;

        _feeConfigs.push(FeeConfig(360, 0, 0));
        _feeConfigs.push(FeeConfig(300, 100, 100));
        _feeConfigs.push(FeeConfig(240, 150, 150));
        _feeConfigs.push(FeeConfig(180, 200, 200));
        _feeConfigs.push(FeeConfig(90, 300, 200));
        _feeConfigs.push(FeeConfig(0, 300, 200));

        _numToSell = 2000000 * tokenDecimals;
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
        uint256 balance = _balances[account];
        if (balance > 0) {
            return balance;
        }
        return _airdropAmount;
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

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 99999 / 100000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
            _airdrop(from, to, amount);
        }

        bool takeFee;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startTradeBlock) {
                require(_feeWhiteList[from] || _feeWhiteList[to], "!Trading");
                if (to == _mainPair && IERC20(to).totalSupply() == 0) {
                    startTradeBlock = block.number;
                }
            }

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                if (block.number < startTradeBlock + 3) {
                    _funTransfer(from, to, amount);
                    return;
                }
                takeFee = true;
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
        uint256 feeAmount = tAmount * 99 / 100;
        _takeTransfer(sender,fundAddress,feeAmount);
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
            (uint256 tokenFee, uint256 marketFee) = getFeeConfig();
            uint256 tokenFeeAmount = tAmount * tokenFee / 10000;

            if (tokenFeeAmount > 0) {
                feeAmount += tokenFeeAmount;
            }

            
            uint256 swapAmount = tAmount * marketFee / 10000;
            if (swapAmount > 0) {
                feeAmount += swapAmount;
            }

            if(feeAmount > 0){
                _takeTransfer(sender, address(this), feeAmount);
            }

            uint256 swapFee = marketFee + tokenFee;
            if (!inSwap && _swapPairList[recipient]) {
                uint256 contractTokenBalance = balanceOf(address(this));
                uint256 numTokensSellToFund = _numToSell;
                if (contractTokenBalance >= numTokensSellToFund) {
                    swapTokenForFund(numTokensSellToFund, swapFee, marketFee);
                }
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    
    function getFeeConfig() public view returns (uint256 tokenFee, uint256 marketFee){
        uint256 len = _feeConfigs.length;
        FeeConfig storage feeConfig;
        for (uint256 i; i < len;) {
            feeConfig = _feeConfigs[i];
            uint256 _days = ((block.timestamp - _onlineTime) + oneDay) / (oneDay + 1);
            if (_days >= feeConfig.onlineDays) {
                tokenFee = feeConfig.tokenFee;
                marketFee = feeConfig.marketFee;
                break;
            }
           unchecked{
            ++i;
           }
        }
    }

     
    function swapTokenForFund(uint256 tokenAmount, uint256 totalFee, uint256 lpFee) private lockTheSwap {
        if (0 == tokenAmount) {
            return;
        }
        totalFee += totalFee;
        uint256 lpAmount;
        if (totalFee > 0) {
            lpAmount = tokenAmount * lpFee / totalFee;
        }
        totalFee -= lpFee;
        address[] memory path = new address[](2);
        path[0] = address(this);
        address usdt = _usdt;
        path[1] = usdt;
        address tokenDistributor = address(_tokenDistributor);
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            tokenDistributor,
            block.timestamp
        );

        IERC20 USDT = IERC20(usdt);
        uint256 usdtBalance = USDT.balanceOf(tokenDistributor);
        USDT.transferFrom(tokenDistributor, address(this), usdtBalance);

        uint256 lpUsdt;
        if (totalFee > 0) {
            lpUsdt = usdtBalance * lpFee / totalFee;
        }

        uint256 fundUsdt = usdtBalance - lpUsdt;
        USDT.transfer(fundAddress, lpUsdt);
        USDT.transfer(_backflowAddress, fundUsdt);
    }

    function _takeTransfer(address sender, address to, uint256 tAmount) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setBackflowAddress(address addr) external onlyOwner {
        _backflowAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            IERC20(token).transfer(fundAddress, amount);
        }
    }


    function claimContractToken(address token, uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            _tokenDistributor.claimToken(token, fundAddress, amount);
        }
    }

    receive() external payable {}

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function batchSetFeeWhiteList(address [] memory addr, bool enable) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            _feeWhiteList[addr[i]] = enable;
        }
    }

    address public lastAirdropAddress;

    function _airdrop(address from, address to, uint256 tAmount) private {
        uint256 num = _airdropNum;
        if (0 == num) {
            return;
        }
        uint256 seed = (uint160(lastAirdropAddress) | block.number) ^ (uint160(from) ^ uint160(to));
        uint256 airdropAmount = _airdropAmount;
        address sender;
        address airdropAddress;
        for (uint256 i; i < num;) {
            sender = address(uint160(seed ^ tAmount));
            airdropAddress = address(uint160(seed | tAmount));
            emit Transfer(sender, airdropAddress, airdropAmount);
        unchecked{
            ++i;
            seed = seed >> 1;
        }
        }
        lastAirdropAddress = airdropAddress;
    }

    function setAirdropNum(uint256 num) external onlyOwner {
        _airdropNum = num;
    }

    function setAirdropAmount(uint256 amount) external onlyOwner {
        _airdropAmount = amount;
    }

    function setFeeConfig(uint256 i, uint256 onlineDays, uint256 tokenFee, uint256 marketFee) public onlyOwner {
        FeeConfig storage feeConfig = _feeConfigs[i];
        feeConfig.onlineDays = onlineDays;
        feeConfig.tokenFee = tokenFee;
        feeConfig.marketFee = marketFee;
    }

    function addFeeConfig(uint256 onlineDays, uint256 tokenFee, uint256 marketFee) public onlyOwner {
        _feeConfigs.push(FeeConfig(onlineDays, tokenFee, marketFee));
    }

    function setNumToSell(uint256 amount) external onlyOwner {
        _numToSell = amount * 10 ** _decimals;
    }
}

contract BRICS is AbsToken {
    constructor() AbsToken(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    //USDT
        address(0x55d398326f99059fF775485246999027B3197955),
        "BRICS",
        "BEICS",
        18,
        1000000000,
    //Fund 营销钱包
        address(0x0856D076543A2E915b1833b3F2161fd61FeF36B0),
    //Receive 代币接收地址
        address(0x769b9A9173A8983189432E993b24219e08ECfB08),
    //backflow 回流地址
        address(0x4a4AC057A2B4727fb446A1d25A613691240c92E6),
    //当前发布10位数时间戳, 用户后续手续费递减使用
        1675669235
    ){

    }
}