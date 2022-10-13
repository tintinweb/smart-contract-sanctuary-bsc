/**
 *Submitted for verification at BscScan.com on 2022-10-13
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
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface ISwapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function token0() external view returns (address);

    function sync() external;
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
    constructor (address token) {
        IERC20(token).approve(msg.sender, ~uint256(0));
    }
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;
    address public foundationAddress = address(0x60EBd793477317cf52eeaa4ab1Eb5eD2D5974e36);
    address public communityAddress = address(0x204E529f28f10c9Ee09744e2FEb3123967016B1D);

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public _usdt;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);

    uint256 public _buyFee = 1;
    uint256 public _sellFee = 10;

    uint256 public _sellLPDividendRate = 40;
    uint256 public _sellDestroyRate = 20;
    uint256 public _sellCommunityRate = 20;
    uint256 public _sellFoundationRate = 10;
    uint256 public _sellFundRate = 10;

    uint256 public _allSellFeeRate = 100;

    uint256 public startTradeBlock;
    address public _usdtPair;

    uint256 public _minTotal;
    TokenDistributor public _tokenDistributor;

    mapping(uint256 => uint256) public dayPrice;
    uint256 public _addSellFeePriceRate = 80;
    uint256 public _addSellFeeStep = 5;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address USDTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address FundAddress, address ReceiveAddress, uint256 MinTotal
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        _usdt = USDTAddress;
        _swapRouter = swapRouter;
        _allowances[address(this)][RouterAddress] = MAX;
        IERC20(USDTAddress).approve(RouterAddress, MAX);

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address usdtPair = swapFactory.createPair(address(this), USDTAddress);
        _swapPairList[usdtPair] = true;

        _usdtPair = usdtPair;

        uint256 total = Supply * 10 ** Decimals;
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        fundAddress = FundAddress;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[communityAddress] = true;
        _feeWhiteList[foundationAddress] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;
        _feeWhiteList[address(0)] = true;

        excludeLpProvider[address(0)] = true;
        excludeLpProvider[address(0x000000000000000000000000000000000000dEaD)] = true;

        lpRewardCondition = 100 * 10 ** IERC20(USDTAddress).decimals();
        _minTotal = MinTotal * 10 ** Decimals;

        _tokenDistributor = new TokenDistributor(USDTAddress);
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

    function validTotal() public view returns (uint256) {
        return _tTotal - _balances[address(0)] - _balances[address(0x000000000000000000000000000000000000dEaD)];
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

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 99999 / 100000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        bool takeFee;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startTradeBlock) {
                require(_feeWhiteList[from] || _feeWhiteList[to], "!Trading");
                if (_usdtPair == to && IERC20(to).totalSupply() == 0) {
                    startTradeBlock = block.number;
                }
            }

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                if (block.number < startTradeBlock + 4) {
                    _funTransfer(from, to, amount, 90);
                    return;
                }
                takeFee = true;
            }
        }

        bool isSell;
        if (_swapPairList[to]) {
            addLpProvider(from);
            isSell = true;
            if (tx.origin == from) {
                uint256 day = today();
                if (0 == dayPrice[day]) {
                    dayPrice[day] = tokenPrice();
                }
            }
        } else {
            if (tx.origin == to) {
                uint256 day = today();
                if (0 == dayPrice[day]) {
                    dayPrice[day] = tokenPrice();
                }
            }
        }

        _tokenTransfer(from, to, amount, takeFee, isSell);

        if (from != address(this)) {
            processLP(500000);
        }
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 fee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * fee / 100;
        if (feeAmount > 0) {
            _takeTransfer(sender, fundAddress, feeAmount);
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isSell
    ) private {
        if (!takeFee) {
            _funTransfer(sender, recipient, tAmount, 0);
            return;
        }
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (isSell) {
            uint256 sellFee = getSellFee();
            feeAmount = tAmount * sellFee / 100;
            uint256 allSellFeeRate = _allSellFeeRate;
            uint256 destroyFeeAmount = feeAmount * _sellDestroyRate / allSellFeeRate;
            uint256 destroyAmount = destroyFeeAmount;
            uint256 currentTotal = validTotal();
            uint256 maxDestroyAmount;
            if (currentTotal > _minTotal) {
                maxDestroyAmount = currentTotal - _minTotal;
            }
            if (destroyAmount > maxDestroyAmount) {
                destroyAmount = maxDestroyAmount;
            }
            if (destroyAmount > 0) {
                _takeTransfer(sender, address(0x000000000000000000000000000000000000dEaD), destroyAmount);
            }

            uint256 fundAmount = feeAmount - destroyAmount;
            if (fundAmount > 0) {
                _takeTransfer(sender, address(this), fundAmount);
            }

            if (!inSwap) {
                swapTokenForFund(fundAmount + fundAmount);
            }
        } else {
            feeAmount = tAmount * _buyFee / 100;
            uint256 destroyAmount = feeAmount;
            uint256 currentTotal = validTotal();
            uint256 maxDestroyAmount;
            if (currentTotal > _minTotal) {
                maxDestroyAmount = currentTotal - _minTotal;
            }
            if (destroyAmount > maxDestroyAmount) {
                destroyAmount = maxDestroyAmount;
            }
            if (destroyAmount > 0) {
                _takeTransfer(sender, address(0x000000000000000000000000000000000000dEaD), destroyAmount);
            }
            uint256 fundAmount = feeAmount - destroyAmount;
            if (fundAmount > 0) {
                _takeTransfer(sender, address(this), fundAmount);
            }
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function getSellFee() public view returns (uint256){
        uint256 todayPrice = dayPrice[today()];
        uint256 price = tokenPrice();
        uint256 priceRate = price * 100 / todayPrice;
        uint256 sellFee = _sellFee;
        uint256 addSellFeePriceRate = _addSellFeePriceRate;
        if (addSellFeePriceRate > priceRate) {
            sellFee += _addSellFeeStep * (addSellFeePriceRate - priceRate);
        }
        return sellFee;
    }

    function swapTokenForFund(uint256 fundSwapAmount) private lockTheSwap {
        if (0 == fundSwapAmount) {
            return;
        }

        uint256 allRate = _allSellFeeRate - _sellDestroyRate;

        address tokenDistributor = address(_tokenDistributor);
        address usdt = _usdt;
        uint thisTokenBalance = balanceOf(address(this));

        if (fundSwapAmount > thisTokenBalance) {
            fundSwapAmount = thisTokenBalance;
        }

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            fundSwapAmount,
            0,
            path,
            tokenDistributor,
            block.timestamp
        );

        IERC20 USDT = IERC20(usdt);
        uint256 usdtBalance = USDT.balanceOf(tokenDistributor);
        USDT.transferFrom(tokenDistributor, address(this), usdtBalance);

        uint256 fundUsdt = usdtBalance * _sellFundRate / allRate;
        USDT.transfer(fundAddress, fundUsdt);

        uint256 communityUsdt = usdtBalance * _sellCommunityRate / allRate;
        USDT.transfer(communityAddress, communityUsdt);

        uint256 foundationUsdt = usdtBalance * _sellFoundationRate / allRate;
        USDT.transfer(foundationAddress, foundationUsdt);
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

    function setCommunityAddress(address addr) external onlyOwner {
        communityAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setFoundationAddress(address addr) external onlyOwner {
        foundationAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
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

    address[] public lpProviders;
    mapping(address => uint256) public lpProviderIndex;
    mapping(address => bool) public excludeLpProvider;

    function getLPProviderLength() external view returns (uint256){
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
    uint256 public progressLPBlock;
    uint256 public progressLPBlockDebt = 200;
    uint256 public _receiveRewardDuration = 28800;
    mapping(address => uint256) public _progressLPRewardTime;

    function processLP(uint256 gas) private {
        uint256 blockNum = block.number;
        if (progressLPBlock + progressLPBlockDebt > blockNum) {
            return;
        }
        IERC20 mainpair = IERC20(_usdtPair);
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
        uint256 receiveRewardDuration = _receiveRewardDuration;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = lpProviders[currentIndex];
            if (_progressLPRewardTime[shareHolder] + receiveRewardDuration <= blockNum) {
                pairBalance = mainpair.balanceOf(shareHolder);
                if (pairBalance > 0 && !excludeLpProvider[shareHolder]) {
                    amount = tokenBalance * pairBalance / totalPair;
                    if (amount > 0) {
                        _progressLPRewardTime[shareHolder] = blockNum;
                        token.transfer(shareHolder, amount);
                    }
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }

        progressLPBlock = blockNum;
    }

    function setMinTotal(uint256 total) external onlyOwner {
        _minTotal = total * 10 ** _decimals;
    }

    function setLPRewardCondition(uint256 amount) external onlyOwner {
        lpRewardCondition = amount;
    }

    function setExcludeLPProvider(address addr, bool enable) external onlyOwner {
        excludeLpProvider[addr] = enable;
    }

    function setProgressLPBlockDebt(uint256 blockDebt) external onlyOwner {
        progressLPBlockDebt = blockDebt;
    }

    function setReceiveRewardDuration(uint256 duration) external onlyOwner {
        _receiveRewardDuration = duration;
    }

    function setDayPrice(uint256 day, uint256 price) external onlyOwner {
        dayPrice[day] = price;
    }

    function today() public view returns (uint256){
        return block.timestamp / 86400;
    }

    function tokenPrice() public view returns (uint256){
        ISwapPair swapPair = ISwapPair(_usdtPair);
        (uint256 reverse0,uint256 reverse1,) = swapPair.getReserves();
        address token0 = swapPair.token0();
        uint256 usdtReverse;
        uint256 tokenReverse;
        if (_usdt == token0) {
            usdtReverse = reverse0;
            tokenReverse = reverse1;
        } else {
            usdtReverse = reverse1;
            tokenReverse = reverse0;
        }
        if (0 == tokenReverse) {
            return 0;
        }
        return 10 ** _decimals * usdtReverse / tokenReverse;
    }

    receive() external payable {}
}

contract SPZ is AbsToken {
    constructor() AbsToken(
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        address(0x55d398326f99059fF775485246999027B3197955),
        "SPZ",
        "SPZ",
        18,
        1310000,
        address(0xB89F4259B9ab5c6da7Ab5335890C558F1e3Dfa6F),
        address(0x4b2C85A2aa9E7777911F4A03949288EbA1584679),
        130000
    ){

    }
}