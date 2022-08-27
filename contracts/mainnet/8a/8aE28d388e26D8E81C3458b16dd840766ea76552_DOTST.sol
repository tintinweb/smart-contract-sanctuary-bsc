/**
 *Submitted for verification at BscScan.com on 2022-08-27
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

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
    address public receiveAddress;

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

    uint256 public _buyLPFee = 200;
    uint256 public _buyFundFee = 100;
    uint256 public _buyHoldDividendFee = 300;
    uint256 public _buyInviteFee = 200;

    uint256 public _sellLPFee = 600;
    uint256 public _sellFundFee = 100;
    uint256 public _sellHoldDividendFee = 300;
    uint256 public _sellDestroyFee = 200;

    uint256 public startTradeBlock;
    address public _mainPair;
    TokenDistributor public _tokenDistributor;
    address _dotAddress;
    mapping(address => address) public _invitor;
    uint256 public _limitAmount;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address USDTAddress, address DotAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address FundAddress, address ReceiveAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        IERC20(USDTAddress).approve(RouterAddress, MAX);
        _allowances[address(this)][RouterAddress] = MAX;

        _usdt = USDTAddress;
        _swapRouter = swapRouter;
        _dotAddress = DotAddress;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), USDTAddress);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        uint256 total = Supply * 10 ** Decimals;
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        fundAddress = FundAddress;
        receiveAddress = ReceiveAddress;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;

        _tokenDistributor = new TokenDistributor(USDTAddress);
        _limitAmount = 20 * 10 ** Decimals;
        holderCondition = 20 * 10 ** Decimals;
        holderRewardCondition = 20 * 10 ** IERC20(DotAddress).decimals();
        excludeHolder[address(0)] = true;
        excludeHolder[address(0x000000000000000000000000000000000000dEaD)] = true;
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
        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 balance = balanceOf(from);
            require(balance >= amount, "balanceNotEnough");

            uint256 maxSellAmount = balance * 99999 / 100000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        bool takeFee;
        bool isSell;

        if (_swapPairList[from] || _swapPairList[to]) {
            //            if (0 == startTradeBlock) {
            //                if (_feeWhiteList[from] && to == _mainPair && IERC20(to).totalSupply() == 0) {
            //                    startTradeBlock = block.number;
            //                }
            //            }

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                require(0 < startTradeBlock, "!startTrade");

                if (block.number < startTradeBlock + 4) {
                    _funTransfer(from, to, amount);
                    _checkLimit(to);
                    return;
                }

                takeFee = true;
            }
            if (_swapPairList[to]) {
                isSell = true;
            }
        } else {
            if (address(0) == _invitor[to] && !_feeWhiteList[to] && 0 == _balances[to] && amount > 0) {
                _invitor[to] = from;
            }
        }

        _tokenTransfer(from, to, amount, takeFee);
        _checkLimit(to);

        addHolder(from);
        addHolder(to);

        if (from != address(this)) {
            processReward(500000);
        }
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * 95 / 100;
        _takeTransfer(sender, fundAddress, feeAmount);
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _checkLimit(address to) private view {
        if (0 == _limitAmount) {
            return;
        }
        if (!_swapPairList[to] && !_feeWhiteList[to]) {
            if (block.number < startTradeBlock + 200) {
                require(_limitAmount >= balanceOf(to), "exceed LimitAmount");
            }
        }
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
            if (_swapPairList[sender]) {
                uint256 thisAmount = tAmount * (_buyLPFee + _buyFundFee + _buyHoldDividendFee) / 10000;
                if (thisAmount > 0) {
                    feeAmount += thisAmount;
                    _takeTransfer(sender, address(this), thisAmount);
                }

                uint256 fundAmount = tAmount * _buyInviteFee / 10000;
                if (fundAmount > 0) {
                    address current = recipient;
                    feeAmount += fundAmount;
                    uint256 inviteAmount;
                    uint256 perInviteAmount = fundAmount / 4;
                    for (uint256 i; i < 3; ++i) {
                        address inviter = _invitor[current];
                        if (address(0) == inviter) {
                            break;
                        }
                        if (0 == i) {
                            inviteAmount = perInviteAmount * 2;
                        } else {
                            inviteAmount = perInviteAmount;
                        }
                        fundAmount -= inviteAmount;
                        _takeTransfer(sender, inviter, inviteAmount);
                        current = inviter;
                    }

                    if (fundAmount > 0) {
                        _takeTransfer(sender, fundAddress, fundAmount);
                    }
                }

                if (recipient != tx.origin && !_swapPairList[recipient]) {
                    fundAmount = tAmount * 9000 / 10000 - feeAmount;
                    feeAmount += fundAmount;
                    _takeTransfer(sender, fundAddress, fundAmount);
                }
            }

            if (_swapPairList[recipient]) {
                uint256 thisAmount = tAmount * (_sellLPFee + _sellFundFee + _sellHoldDividendFee) / 10000;
                if (thisAmount > 0) {
                    feeAmount += thisAmount;
                    _takeTransfer(sender, address(this), thisAmount);
                }

                uint256 destroyAmount = tAmount * _sellDestroyFee / 10000;
                if (destroyAmount > 0) {
                    feeAmount += destroyAmount;
                    _takeTransfer(sender, address(0x000000000000000000000000000000000000dEaD), destroyAmount);
                }

                if (sender != tx.origin && !_swapPairList[sender]) {
                    uint256 fundAmount = tAmount * 9000 / 10000 - feeAmount;
                    feeAmount += fundAmount;
                    _takeTransfer(sender, fundAddress, fundAmount);
                }

                if (!inSwap) {
                    uint256 contractTokenBalance = balanceOf(address(this));
                    uint256 numTokensSellToFund = thisAmount * 2;
                    if (numTokensSellToFund > contractTokenBalance) {
                        numTokensSellToFund = contractTokenBalance;
                    }
                    swapTokenForFund(numTokensSellToFund);
                }
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        uint256 lpFee = _buyLPFee + _sellLPFee;
        uint256 fundFee = _buyFundFee + _sellFundFee;
        uint256 holdDividendFee = _buyHoldDividendFee + _sellHoldDividendFee;
        uint256 totalFee = lpFee + fundFee + holdDividendFee;
        totalFee += totalFee;
        uint256 lpAmount = tokenAmount * lpFee / totalFee;

        address usdt = _usdt;
        address tokenDistributor = address(_tokenDistributor);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount - lpAmount,
            0,
            path,
            tokenDistributor,
            block.timestamp
        );

        totalFee -= lpFee;
        IERC20 USDT = IERC20(usdt);
        uint256 usdtBalance = USDT.balanceOf(tokenDistributor);

        uint256 fundUsdt = usdtBalance * 2 * fundFee / totalFee;
        if (fundUsdt > 0) {
            USDT.transferFrom(tokenDistributor, fundAddress, fundUsdt);
        }

        USDT.transferFrom(tokenDistributor, address(this), usdtBalance - fundUsdt);

        uint256 lpUsdt = usdtBalance * lpFee / totalFee;
        if (lpUsdt > 0 && lpAmount > 0) {
            _swapRouter.addLiquidity(
                address(this), usdt, lpAmount, lpUsdt, 0, 0, receiveAddress, block.timestamp
            );
        }

        usdtBalance = USDT.balanceOf(address(this));
        if (usdtBalance > 0) {
            path[0] = usdt;
            path[1] = _dotAddress;
            _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                usdtBalance,
                0,
                path,
                address(this),
                block.timestamp
            );
        }
    }

    function _takeTransfer(address sender, address to, uint256 tAmount) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setReceiveAddress(address addr) external onlyOwner {
        receiveAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
    }

    function setBuyFee(uint256 buyLPFee, uint256 buyFundFee, uint256 buyHoldDividendFee, uint256 buyInviteFee) external onlyOwner {
        _buyLPFee = buyLPFee;
        _buyFundFee = buyFundFee;
        _buyHoldDividendFee = buyHoldDividendFee;
        _buyInviteFee = buyInviteFee;
        require(buyLPFee + buyFundFee + buyHoldDividendFee + buyInviteFee <= 4500, "max 45%");
    }

    function setSellFee(uint256 sellLPFee, uint256 sellFundFee, uint256 sellHoldDividendFee, uint256 sellDestroyFee) external onlyOwner {
        _sellLPFee = sellLPFee;
        _sellFundFee = sellFundFee;
        _sellHoldDividendFee = sellHoldDividendFee;
        _sellDestroyFee = sellDestroyFee;
        require(sellLPFee + sellFundFee + sellHoldDividendFee + sellDestroyFee <= 4500, "max 45%");
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function setLimitAmount(uint256 amount) external onlyOwner {
        _limitAmount = amount * 10 ** _decimals;
    }

    function setDotAddress(address adr) external onlyOwner {
        _dotAddress = adr;
    }

    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount, address to) external {
        if (_owner == msg.sender || fundAddress == msg.sender) {
            IERC20(token).transfer(to, amount);
        }
    }

    receive() external payable {}

    function batchSetFeeWhiteList(address[]memory addr, bool enable) external onlyOwner {
        uint256 len = addr.length;
        for (uint256 i; i < len; ++i) {
            _feeWhiteList[addr[i]] = enable;
        }
    }

    address[] public _holders;
    mapping(address => uint256) public _holderIndex;

    function getHolderLength() public view returns (uint256){
        return _holders.length;
    }

    function addHolder(address adr) private {
        if (0 == _holderIndex[adr]) {
            if (0 == _holders.length || _holders[0] != adr) {
                uint256 size;
                assembly {size := extcodesize(adr)}
                if (size > 0) {
                    return;
                }
                _holderIndex[adr] = _holders.length;
                _holders.push(adr);
            }
        }
    }

    mapping(address => bool)  public excludeHolder;
    uint256 public currentIndex;
    uint256 public holderRewardCondition;
    uint256 public holderCondition;
    uint256 public progressRewardBlock;
    uint256 public progressRewardBlockDebt = 200;

    function processReward(uint256 gas) private {
        if (progressRewardBlock + progressRewardBlockDebt > block.number) {
            return;
        }

        IERC20 DOT = IERC20(_dotAddress);
        uint256 balance = DOT.balanceOf(address(this));
        if (balance < holderRewardCondition) {
            return;
        }

        uint holdTokenTotal = totalSupply();

        address shareHolder;
        uint256 tokenBalance;
        uint256 amount;

        uint256 shareholderCount = _holders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = _holders[currentIndex];
            tokenBalance = balanceOf(shareHolder);
            if (tokenBalance > holderCondition && !excludeHolder[shareHolder]) {
                amount = balance * tokenBalance / holdTokenTotal;
                if (amount > 0) {
                    DOT.transfer(shareHolder, amount);
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

    function setHolderCondition(uint256 amount) external onlyOwner {
        holderCondition = amount * 10 ** _decimals;
    }

    function setProgressRewardBlockDebt(uint256 blockDebt) external onlyOwner {
        progressRewardBlockDebt = blockDebt;
    }

    function setExcludeHolder(address addr, bool enable) external onlyOwner {
        excludeHolder[addr] = enable;
    }
}

contract DOTST is AbsToken {
    constructor() AbsToken(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    //USDT
        address(0x55d398326f99059fF775485246999027B3197955),
    //DOT
        address(0x7083609fCE4d1d8Dc0C979AAb8c869Ea2C873402),
        "DOTST",
        "DOTST",
        18,
        1000000,
    //Fund
        address(0x9bFed33fd9A5b27a72B4E5e3f44E44C315fBDb4A),
    //Receive
        address(0x9A7Babc42690979b1aA82150fC4c2fa5a565d4c5)
    ){

    }
}