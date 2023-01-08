/**
 *Submitted for verification at BscScan.com on 2023-01-08
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

    function WETH() external pure returns (address);
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

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => mapping(address => uint256)) private _allowances;

    address public constant deadAddress = address(0x000000000000000000000000000000000000dEaD);
    address public fundAddress;
    address public marketAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 public _dividendFee = 100;
    uint256 public _destroyFee = 100;
    uint256 public _lpFee = 100;
    uint256 public _fundFee = 200;
    uint256 public _marketFee = 100;

    uint256 public startTradeBlock;
    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _excludeRewardList;
    mapping(address => bool) public _blackList;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;

    mapping(address => bool) public _swapPairList;
    ISwapRouter public _swapRouter;

    address public _usdtAddress;
    address public _usdtPair;
    address public _mainPair;

    bool private inSwap;
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    uint256 public _minTotal;

    constructor (address RouteAddress, address USDTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address FundAddress, address MarketAddress, address ReceivedAddress){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouteAddress);
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;
        IERC20(USDTAddress).approve(RouteAddress, MAX);

        address usdtPair = ISwapFactory(swapRouter.factory()).createPair(address(this), USDTAddress);
        _swapPairList[usdtPair] = true;
        _usdtPair = usdtPair;

        address mainPair = ISwapFactory(swapRouter.factory()).createPair(address(this), swapRouter.WETH());
        _swapPairList[mainPair] = true;
        _mainPair = mainPair;

        uint256 tTotal = Supply * 10 ** _decimals;
        uint256 rTotal = (MAX - (MAX % tTotal));
        _rOwned[ReceivedAddress] = rTotal;
        _tOwned[ReceivedAddress] = tTotal;
        emit Transfer(address(0), ReceivedAddress, tTotal);
        _rTotal = rTotal;
        _tTotal = tTotal;

        fundAddress = FundAddress;
        marketAddress = MarketAddress;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[ReceivedAddress] = true;
        _feeWhiteList[MarketAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[deadAddress] = true;

        _usdtAddress = USDTAddress;
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
        if (_excludeRewardList[account] || _swapPairList[account]) {
            return _tOwned[account];
        }
        return tokenFromReflection(_rOwned[account]);
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

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function tokenFromReflection(uint256 rAmount) public view returns (uint256){
        uint256 currentRate = _getRate();
        return rAmount / currentRate;
    }

    function _getRate() private view returns (uint256) {
        if (_rTotal < _tTotal) {
            return 1;
        }
        return _rTotal / _tTotal;
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
        require(!_blackList[from] || _feeWhiteList[from], "black");

        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 9999 / 10000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        bool takeFee;

        if (_swapPairList[from] || _swapPairList[to]) {
            //            if (0 == startTradeBlock) {
            //                if (_feeWhiteList[from] && to == _usdtPair && IERC20(to).totalSupply() == 0) {
            //                    startTradeBlock = block.number;
            //                }
            //            }

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                require(0 < startTradeBlock, "!Trading");
                if (block.number < startTradeBlock + 3) {
                    _funTransfer(from, to, amount);
                    return;
                }
                takeFee = true;
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
        if (_tOwned[sender] > tAmount) {
            _tOwned[sender] -= tAmount;
        } else {
            _tOwned[sender] = 0;
        }

        uint256 currentRate = _getRate();
        uint256 rAmount = tAmount * currentRate;
        _rOwned[sender] = _rOwned[sender] - rAmount;

        uint256 feeAmount;
        if (takeFee) {
            uint256 lpFeeAmount = tAmount * _lpFee / 10000;
            bool isSell = _swapPairList[recipient];
            if (lpFeeAmount > 0) {
                feeAmount += lpFeeAmount;
                if (isSell) {
                    _takeTransfer(sender, recipient, lpFeeAmount, currentRate);
                    ISwapPair(recipient).sync();
                } else {
                    _takeTransfer(sender, sender, lpFeeAmount, currentRate);
                }
            }

            uint256 destroyFeeAmount = _destroyFee * tAmount / 10000;
            if (destroyFeeAmount > 0) {
                feeAmount += destroyFeeAmount;
                _takeTransfer(sender, deadAddress, destroyFeeAmount, currentRate);
            }

            uint256 fundFeeAmount = _fundFee * tAmount / 10000;
            if (fundFeeAmount > 0) {
                feeAmount += fundFeeAmount;
                _takeTransfer(sender, fundAddress, fundFeeAmount, currentRate);
            }

            uint256 marketFeeAmount = _marketFee * tAmount / 10000;
            if (marketFeeAmount > 0) {
                feeAmount += marketFeeAmount;
                _takeTransfer(sender, marketAddress, marketFeeAmount, currentRate);
            }

            uint256 dividendAmount = tAmount * _dividendFee / 10000;
            if (dividendAmount > 0) {
                feeAmount += dividendAmount;
                _reflectFee(rAmount / 10000 * _dividendFee, dividendAmount);
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount, currentRate);
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        if (_tOwned[sender] > tAmount) {
            _tOwned[sender] -= tAmount;
        } else {
            _tOwned[sender] = 0;
        }

        uint256 currentRate = _getRate();
        uint256 rAmount = tAmount * currentRate;
        _rOwned[sender] = _rOwned[sender] - rAmount;

        _takeTransfer(sender, fundAddress, tAmount / 100 * 99, currentRate);
        _takeTransfer(sender, recipient, tAmount / 100 * 1, currentRate);
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount,
        uint256 currentRate
    ) private {
        _tOwned[to] += tAmount;

        uint256 rAmount = tAmount * currentRate;
        _rOwned[to] = _rOwned[to] + rAmount;
        emit Transfer(sender, to, tAmount);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal - rFee;
        _tFeeTotal = _tFeeTotal + tFee;
    }

    receive() external payable {}

    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            IERC20(token).transfer(fundAddress, amount);
        }
    }

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setMarketAddress(address addr) external onlyOwner {
        marketAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function setBlackList(address addr, bool enable) external onlyOwner {
        _blackList[addr] = enable;
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
        _tOwned[addr] = balanceOf(addr);
        _rOwned[addr] = _tOwned[addr] * _getRate();
        if (enable) {
            ISwapPair(addr).sync();
        }
    }

    function setExcludeReward(address addr, bool enable) external onlyOwner {
        _tOwned[addr] = balanceOf(addr);
        _rOwned[addr] = _tOwned[addr] * _getRate();
        _excludeRewardList[addr] = enable;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
    }
}

contract RBT is AbsToken {
    constructor() AbsToken(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    //USDT
        address(0x55d398326f99059fF775485246999027B3197955),
    //Name，
        "RabbitYuanYuan",
    //Symbol，
        "RabbitYuanYuan",
    //Decimals，
        18,
    //Total，
        32023000,
    //Fund，
        address(0xcd85Fcad6d79576454DCc02fDb5fB05F04F907eb),
    //Market，
        address(0xB7E6aCAF6EcEeE5e9cA187ABC81fe11ccF01685f),
    //Received，
        address(0xC820D25172E3Eb032f9dC72C1AbE68c16Bc2b27D)
    ){

    }
}