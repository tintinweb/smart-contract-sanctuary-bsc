/**
 *Submitted for verification at BscScan.com on 2022-07-21
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

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 public startTradeBlock;
    mapping(address => bool) public _feeWhiteList;

    mapping(address => bool) public _swapPairList;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    bool private inSwap;
    uint256 public numTokensSellToFund;

    uint256 private constant MAX = ~uint256(0);
    address public _fon;
    TokenDistributor public _tokenDistributor;

    uint256 public _buyLPFee = 100;
    uint256 public _buyFundFee = 100;
    uint256 public _buyHoldDividendFee = 200;

    uint256 public _sellLPFee = 100;
    uint256 public _sellHoldDividendFee = 200;
    uint256 public _sellDestroyFee = 100;

    uint256 public _transferFee = 0;

    address public _fonPair;

    uint256 public _invitorHoldCondition;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouteAddress, address FONAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address FundAddress, address ReceiveAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouteAddress);

        _swapRouter = swapRouter;
        _fon = FONAddress;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address fonPair = swapFactory.createPair(address(this), FONAddress);
        _fonPair = fonPair;

        _swapPairList[fonPair] = true;
        _allowances[address(this)][address(swapRouter)] = MAX;
        IERC20(FONAddress).approve(address(swapRouter), MAX);

        uint256 tTotal = Supply * 10 ** Decimals;
        _tTotal = tTotal;

        _balances[ReceiveAddress] = tTotal;
        emit Transfer(address(0), ReceiveAddress, tTotal);

        fundAddress = FundAddress;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
				
        numTokensSellToFund = 200 * 10 ** Decimals;
        _tokenDistributor = new TokenDistributor(FONAddress);

        excludeHolder[address(0)] = true;
        excludeHolder[address(0x000000000000000000000000000000000000dEaD)] = true;
        excludeHolder[address(0x7ee058420e5937496F5a2096f04caA7721cF70cc)] = true;

        rewardCondition = 10 * 10 ** IERC20(FONAddress).decimals();
        _holdCondition = 100 * 10 ** Decimals;
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
        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 99999 / 100000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        if (_swapPairList[from] || _swapPairList[to]) {
            //            if (0 == startTradeBlock) {
            //                if (_feeWhiteList[from] && _swapPairList[to] && IERC20(to).totalSupply() == 0) {
            //                    startTradeBlock = block.number;
            //                }
            //            }

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                require(0 < startTradeBlock, "!startTrade");
                if (block.number < startTradeBlock + 3) {
                    _fundTransfer(from, to, amount, 9000);
                    return;
                }
            }

            if (_swapPairList[from]) {
                addHolder(to);
            } else {
                addHolder(from);
            }
        }

        _tokenTransfer(from, to, amount);

        if (
            from != address(this)
            && startTradeBlock > 0) {
            processHoldReward(500000);
        }
    }

    function _fundTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 fee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * fee / 10000;
        if (feeAmount > 0) {
            _takeTransfer(
                sender,
                fundAddress,
                feeAmount, false
            );
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount, true);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        if (_feeWhiteList[sender] || _feeWhiteList[recipient]) {
            _fundTransfer(sender, recipient, tAmount, 0);
            return;
        }

        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;
        if (_swapPairList[sender]) {//Buy
            uint256 fundAmount = tAmount * _buyFundFee / 10000;
            if (fundAmount > 0) {
                feeAmount += fundAmount;
                _takeTransfer(sender, fundAddress, fundAmount, false);
            }

            uint256 thisAmount = tAmount * (_buyLPFee + _buyHoldDividendFee) / 10000;
            if (thisAmount > 0) {
                feeAmount += thisAmount;
                _takeTransfer(sender, address(this), thisAmount, false);
            }
        } else if (_swapPairList[recipient]) {//Sell
            uint256 thisAmount = tAmount * (_sellLPFee + _sellHoldDividendFee) / 10000;
            if (thisAmount > 0) {
                feeAmount += thisAmount;
                _takeTransfer(sender, address(this), thisAmount, false);
            }

            uint256 destroyAmount = tAmount * _sellDestroyFee / 10000;
            if (destroyAmount > 0) {
                feeAmount += destroyAmount;
                _takeTransfer(sender, address(0x000000000000000000000000000000000000dEaD), destroyAmount, false);
            }

            if (!inSwap) {
                uint256 thisBalance = balanceOf(address(this));
                if (thisBalance >= numTokensSellToFund) {
                    swapTokenForFund(numTokensSellToFund);
                }
            }
        } else {//Transfer
            uint256 transferFeeAmount = tAmount * _transferFee / 10000;
            if (transferFeeAmount > 0) {
                feeAmount += transferFeeAmount;
                _takeTransfer(sender, fundAddress, transferFeeAmount, false);
            }
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount, true);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        uint256 holdDividendFee = _buyHoldDividendFee + _sellHoldDividendFee;
        uint256 lpFee = _buyLPFee + _sellLPFee;
        address fon = _fon;

        uint256 txFee = holdDividendFee + lpFee;
        txFee += txFee;
        uint256 lpAmount = tokenAmount * lpFee / txFee;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = fon;
        address tokenDistributor = address(_tokenDistributor);
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount - lpAmount,
            0,
            path,
            tokenDistributor,
            block.timestamp
        );

        IERC20 FON = IERC20(fon);
        uint256 fonBalance = FON.balanceOf(tokenDistributor);
        FON.transferFrom(tokenDistributor, address(this), fonBalance);
        txFee -= lpFee;
        if (lpAmount > 0) {
            _swapRouter.addLiquidity(
                address(this),
                fon,
                lpAmount,
                fonBalance * lpFee / txFee,
                0, 0,
                fundAddress,
                block.timestamp
            );
        }

        uint256 fundAmount = balanceOf(fundAddress);
        uint256 fundSellAmount = tokenAmount;
        if (fundAmount >= fundSellAmount) {
            _tokenTransfer(fundAddress, address(this), fundSellAmount);
            _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                fundSellAmount,
                0,
                path,
                fundAddress,
                block.timestamp
            );
        }
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount,
        bool isLog
    ) private {
        _balances[to] = _balances[to] + tAmount;
        if (isLog && sender != address(this) && to != address(this)) {
            emit Transfer(sender, to, tAmount);
        }
    }

    function startTrade() external onlyFunder {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
    }

    function closeTrade() external onlyOwner {
        startTradeBlock = 0;
    }

    function setFundAddress(address addr) external onlyFunder {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setFundSellAmount(uint256 amount) external onlyFunder {
        numTokensSellToFund = amount;
    }

    function setSellFee(uint256 lpFee, uint256 holdDividendFee, uint256 destroyFee) external onlyOwner {
        _sellLPFee = lpFee;
        _sellHoldDividendFee = holdDividendFee;
        _sellDestroyFee = destroyFee;
    }

    function setTransferFee(uint256 transferFee) external onlyOwner {
        _transferFee = transferFee;
    }

    function setBuyFee(uint256 lpFee, uint256 holdDividendFee, uint256 fundFee) external onlyOwner {
        _buyLPFee = lpFee;
        _buyHoldDividendFee = holdDividendFee;
        _buyFundFee = fundFee;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyFunder {
        _feeWhiteList[addr] = enable;
    }

    receive() external payable {}

    function claimBalance(uint256 amount, address to) external onlyFunder {
        payable(to).transfer(amount);
    }

    function claimToken(address token, uint256 amount, address to) external onlyFunder {
        IERC20(token).transfer(to, amount);
    }

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
    uint256 public _holdCondition;
    uint256 public rewardCondition;
    uint256 public progressBlock;
    uint256 public _progressBlockDebt = 200;

    function processHoldReward(uint256 gas) private {
        if (progressBlock + _progressBlockDebt > block.number) {
            return;
        }

        uint totalBalance = totalSupply();

        IERC20 FON = IERC20(_fon);
        uint256 fonBalance = FON.balanceOf(address(this));
        if (fonBalance < rewardCondition) {
            return;
        }

        address shareHolder;
        uint256 holdBalance;
        uint256 amount;

        uint256 shareholderCount = holders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        uint256 holdCondition = _holdCondition;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = holders[currentIndex];
            holdBalance = balanceOf(shareHolder);
            if (holdBalance >= holdCondition && !excludeHolder[shareHolder]) {
                amount = fonBalance * holdBalance / totalBalance;
                if (amount > 0) {
                    FON.transfer(shareHolder, amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }

        progressBlock = block.number;
    }

    function setRewardCondition(uint256 amount) external onlyFunder {
        rewardCondition = amount;
    }

    function setHoldCondition(uint256 amount) external onlyFunder {
        _holdCondition = amount;
    }

    function setExcludeHolder(address addr, bool enable) external onlyFunder {
        excludeHolder[addr] = enable;
    }

    function setProgressBlockDebt(uint256 progressBlockDebt) external onlyFunder {
        _progressBlockDebt = progressBlockDebt;
    }

    modifier onlyFunder() {
        require(_owner == msg.sender || fundAddress == msg.sender, "!Funder");
        _;
    }
}

contract FONMOON is AbsToken {
    constructor() AbsToken(
    //Router
        address(0x1B6C9c20693afDE803B27F8782156c0f892ABC2d),
    //FON
        address(0x12a055D95855b4Ec2cd70C1A5EaDb1ED43eaeF65),
    //Name
        "FONMOON",
    //Symbol
        "FONMOON",
    //Decimals
        18,
    //Total
        1300000,
    //Fund
        address(0x08d0732FC8514c695D606cA78365795EcE750a88),
    //Receive
        address(0x7243eD9c868047a1B8842964fd33Ed6331A00882)
    ){

    }
}