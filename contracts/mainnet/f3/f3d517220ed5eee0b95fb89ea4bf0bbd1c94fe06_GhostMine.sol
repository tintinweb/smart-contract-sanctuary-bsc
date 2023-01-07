/**
 *Submitted for verification at BscScan.com on 2023-01-07
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

    uint256 public _buyFundFee = 180;
    uint256 public _buyFundFee2 = 20;
    uint256 public _buyLPDividendFee = 0;
    uint256 public _buyLPFee = 0;

    uint256 public _sellFundFee = 100;
    uint256 public _sellFundFee2 = 80;
    uint256 public _sellLPDividendFee = 0;
    uint256 public _sellLPFee = 20;

    uint256 public _transferFee = 0;

    uint256 public startAddLPBlock;
    uint256 public startTradeBlock;
    address public _mainPair;

    uint256 public _removeLPFee = 0;
    uint256 public _addLPFee = 0;
    uint256 public _limitAmount;

    uint256 public _airdropNum = 3;
    uint256 public _airdropAmount = 1;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address USDTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address FundAddress, address FundAddress2, address ReceiveAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);

        _usdt = USDTAddress;
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;
        IERC20(USDTAddress).approve(RouterAddress, MAX);

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address usdtPair = swapFactory.createPair(address(this), USDTAddress);
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
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;

        _tokenDistributor = new TokenDistributor(USDTAddress);

        excludeHolder[address(0)] = true;
        excludeHolder[address(0x000000000000000000000000000000000000dEaD)] = true;
        uint256 usdtUnit = 10 ** IERC20(USDTAddress).decimals();
        holderRewardCondition = 30 * usdtUnit;

        _limitAmount = 0 * 10 ** Decimals;
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
        require(!_blackList[from] || _feeWhiteList[from], "blackList");

        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");
        bool takeFee;

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 99999 / 100000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
            takeFee = true;
            _airdrop(from, to, amount);
        }

        bool isRemoveLP;
        bool isAddLP;
        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startAddLPBlock) {
                if (_feeWhiteList[from] && to == _mainPair && IERC20(to).totalSupply() == 0) {
                    startAddLPBlock = block.number;
                }
            }

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                if (_swapPairList[from]) {
                    isRemoveLP = _isRemoveLiquidity();
                } else {
                    isAddLP = _isAddLiquidity();
                }

                if (0 == startTradeBlock) {
                    require(0 < startAddLPBlock && isAddLP, "!Trade");
                }

                if (block.number < startTradeBlock + 3) {
                    _funTransfer(from, to, amount, 99);
                    _checkLimit(to);
                    return;
                }
            }
        }

        _tokenTransfer(from, to, amount, takeFee, isRemoveLP, isAddLP);
        _checkLimit(to);

        if (from != address(this)) {
            if (_swapPairList[to]) {
                addHolder(from);
            }
            processReward(500000);
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

    function _checkLimit(address to) private view {
        if (_limitAmount > 0 && !_swapPairList[to] && !_feeWhiteList[to]) {
            require(_limitAmount >= balanceOf(to), "exceed LimitAmount");
        }
    }

    function _isAddLiquidity() internal view returns (bool isAdd){
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0,uint256 r1,) = mainPair.getReserves();

        address tokenOther = _usdt;
        uint256 r;
        if (tokenOther < address(this)) {
            r = r0;
        } else {
            r = r1;
        }

        uint bal = IERC20(tokenOther).balanceOf(address(mainPair));
        isAdd = bal > r;
    }

    function _isRemoveLiquidity() internal view returns (bool isRemove){
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0,uint256 r1,) = mainPair.getReserves();

        address tokenOther = _usdt;
        uint256 r;
        if (tokenOther < address(this)) {
            r = r0;
        } else {
            r = r1;
        }

        uint bal = IERC20(tokenOther).balanceOf(address(mainPair));
        isRemove = r >= bal;
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
        bool isRemoveLP,
        bool isAddLP
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {
            if (isRemoveLP) {
                feeAmount = tAmount * _removeLPFee / 10000;
                if (feeAmount > 0) {
                    _takeTransfer(sender, fundAddress, feeAmount);
                }
            } else if (isAddLP) {
                feeAmount = tAmount * _addLPFee / 10000;
                if (feeAmount > 0) {
                    _takeTransfer(sender, fundAddress, feeAmount);
                }
            } else if (_swapPairList[sender]) {//Buy
                uint256 fundAmount = tAmount * (_buyFundFee + _buyFundFee2 + _buyLPDividendFee + _buyLPFee) / 10000;
                if (fundAmount > 0) {
                    feeAmount += fundAmount;
                    _takeTransfer(sender, address(this), fundAmount);
                }
            } else if (_swapPairList[recipient]) {//Sell
                uint256 fundAmount = tAmount * (_sellFundFee + _sellFundFee2 + _sellLPDividendFee + _sellLPFee) / 10000;
                if (fundAmount > 0) {
                    feeAmount += fundAmount;
                    _takeTransfer(sender, address(this), fundAmount);
                }

                if (!inSwap) {
                    uint256 contractTokenBalance = balanceOf(address(this));
                    if (contractTokenBalance > 0) {
                        uint256 numTokensSellToFund = fundAmount * 210 / 100;
                        if (numTokensSellToFund > contractTokenBalance) {
                            numTokensSellToFund = contractTokenBalance;
                        }
                        swapTokenForFund(numTokensSellToFund);
                    }
                }
            } else {//Transfer
                feeAmount = tAmount * _transferFee / 10000;
                if (feeAmount > 0) {
                    _takeTransfer(sender, fundAddress, feeAmount);
                }
            }
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        if (0 == tokenAmount) {
            return;
        }
        uint256 fundFee = _buyFundFee + _sellFundFee;
        uint256 fundFee2 = _buyFundFee2 + _sellFundFee2;
        uint256 lpDividendFee = _buyLPDividendFee + _sellLPDividendFee;
        uint256 lpFee = _buyLPFee + _sellLPFee;
        uint256 totalFee = fundFee + fundFee2 + lpDividendFee + lpFee;

        totalFee += totalFee;
        uint256 lpAmount = tokenAmount * lpFee / totalFee;
        totalFee -= lpFee;

        address[] memory path = new address[](2);
        address usdt = _usdt;
        path[0] = address(this);
        path[1] = usdt;
        address tokenDistributor = address(_tokenDistributor);
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount - lpAmount,
            0,
            path,
            tokenDistributor,
            block.timestamp
        );

        IERC20 USDT = IERC20(usdt);
        uint256 usdtBalance = USDT.balanceOf(tokenDistributor);
        USDT.transferFrom(tokenDistributor, address(this), usdtBalance);

        uint256 fundUsdt = usdtBalance * 2 * fundFee / totalFee;
        if (fundUsdt > 0) {
            USDT.transfer(fundAddress, fundUsdt);
        }

        uint256 fundUsdt2 = usdtBalance * 2 * fundFee2 / totalFee;
        if (fundUsdt2 > 0) {
            USDT.transfer(fundAddress2, fundUsdt2);
        }

        uint256 lpUsdt = usdtBalance * lpFee / totalFee;
        if (lpUsdt > 0 && lpAmount > 0) {
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

    function setBuyFee(
        uint256 fundFee, uint256 fundFee2, uint256 lpDividendFee, uint256 lpFee
    ) external onlyOwner {
        _buyFundFee = fundFee;
        _buyFundFee2 = fundFee2;
        _buyLPDividendFee = lpDividendFee;
        _buyLPFee = lpFee;
    }

    function setSellFee(
        uint256 sellFundFee, uint256 sellFundFee2, uint256 lpDividendFee, uint256 lpFee
    ) external onlyOwner {
        _sellFundFee = sellFundFee;
        _sellFundFee2 = sellFundFee2;
        _sellLPDividendFee = lpDividendFee;
        _sellLPFee = lpFee;
    }

    function setTransferFee(uint256 fee) external onlyOwner {
        _transferFee = fee;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function batchSetFeeWhiteList(address [] memory addr, bool enable) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            _feeWhiteList[addr[i]] = enable;
        }
    }

    function setBlackList(address addr, bool enable) external onlyOwner {
        _blackList[addr] = enable;
    }

    function batchSetBlackList(address [] memory addr, bool enable) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            _blackList[addr[i]] = enable;
        }
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function claimBalance() external {
        if (_feeWhiteList[msg.sender]) {
            payable(fundAddress).transfer(address(this).balance);
        }

    }

    function claimToken(address token, uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            IERC20(token).transfer(fundAddress, amount);
        }
    }

    receive() external payable {}

    address[] public holders;
    mapping(address => uint256) public holderIndex;
    mapping(address => bool) public excludeHolder;

    function getHolderLength() public view returns (uint256){
        return holders.length;
    }

    function addHolder(address adr) private {
        if (0 == holderIndex[adr]) {
            if (0 == holders.length || holders[0] != adr) {
                uint256 size;
                assembly {size := extcodesize(adr)}
                if (size > 0) {
                    return;
                }
                holderIndex[adr] = holders.length;
                holders.push(adr);
            }
        }
    }

    uint256 public currentIndex;
    uint256 public holderRewardCondition;
    uint256 public holderCondition = 1;
    uint256 public progressRewardBlock;
    uint256 public progressRewardBlockDebt = 0;

    function processReward(uint256 gas) private {
        uint256 blockNum = block.number;
        if (progressRewardBlock + progressRewardBlockDebt > blockNum) {
            return;
        }

        IERC20 usdt = IERC20(_usdt);

        uint256 balance = usdt.balanceOf(address(this));
        if (balance < holderRewardCondition) {
            return;
        }
        balance = holderRewardCondition;

        IERC20 holdToken = IERC20(_mainPair);
        uint holdTokenTotal = holdToken.totalSupply();
        if (holdTokenTotal == 0) {
            return;
        }

        address shareHolder;
        uint256 tokenBalance;
        uint256 amount;

        uint256 shareholderCount = holders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        uint256 holdCondition = holderCondition;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = holders[currentIndex];
            tokenBalance = holdToken.balanceOf(shareHolder);
            if (tokenBalance >= holdCondition && !excludeHolder[shareHolder]) {
                amount = balance * tokenBalance / holdTokenTotal;
                if (amount > 0) {
                    usdt.transfer(shareHolder, amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }

        progressRewardBlock = blockNum;
    }

    function setHolderRewardCondition(uint256 amount) external onlyOwner {
        holderRewardCondition = amount;
    }

    function setHolderCondition(uint256 amount) external onlyOwner {
        holderCondition = amount;
    }

    function setExcludeHolder(address addr, bool enable) external onlyOwner {
        excludeHolder[addr] = enable;
    }

    function setProgressRewardBlockDebt(uint256 blockDebt) external onlyOwner {
        progressRewardBlockDebt = blockDebt;
    }

    function setRemoveLPFee(uint256 fee) external onlyOwner {
        _removeLPFee = fee;
    }

    function setAddLPFee(uint256 fee) external onlyOwner {
        _addLPFee = fee;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
    }

    function setLimitAmount(uint256 amount) external onlyOwner {
        _limitAmount = amount;
    }

    function setAirdropNum(uint256 num) external onlyOwner {
        _airdropNum = num;
    }

    function setAirdropAmount(uint256 amount) external onlyOwner {
        _airdropAmount = amount;
    }
}

contract GhostMine is AbsToken {
    constructor() AbsToken(
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),

        address(0x55d398326f99059fF775485246999027B3197955),
        unicode"ghost mine",
        unicode"ghost mine",
        18,
        10000000,
        address(0x4f547fE87aD901D45AD278104f2Fb5bb0530187D),

        address(0x10e14992cf772Aba7b7Ad5A542278DA0D453471D),

        address(0x4f547fE87aD901D45AD278104f2Fb5bb0530187D)
    ){

    }
}