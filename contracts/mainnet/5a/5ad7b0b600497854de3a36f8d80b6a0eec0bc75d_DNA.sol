/**
 *Submitted for verification at BscScan.com on 2022-08-30
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

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => mapping(address => uint256)) private _allowances;

    address public constant deadAddress = address(0x000000000000000000000000000000000000dEaD);
    address public fundAddress;
    address public devAddress = address(0x82db4e3fa7FF53A6DFf46684Ea65191Ab10a60b9);
    address public ecologyAddress = address(0x7fe73020B320E8bA37da753E44cF366Cfa3Afa74);
    address public unionAddress = address(0x7eC81Dc96376bE65a80566e5c8D2325fb9926070);

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 public _devFee = 100;
    uint256 public _fundFee = 200;
    uint256 public _dividendFee = 300;
    uint256 public _ecologyFee = 200;
    uint256 public _unionFee = 100;
    uint256 public _destroyFee = 100;

    uint256 public startTradeBlock;
    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _excludeRewardList;

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

    bool private inSwap;
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    uint256 public _minTotal;

    constructor (address RouteAddress, address USDTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address FundAddress, address ReceivedAddress, uint256 MinTotal){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouteAddress);
        _swapRouter = swapRouter;

        address usdtPair = ISwapFactory(swapRouter.factory()).createPair(address(this), USDTAddress);
        _swapPairList[usdtPair] = true;
        _excludeRewardList[usdtPair] = true;
        _usdtPair = usdtPair;

        uint256 tTotal = Supply * 10 ** _decimals;
        uint256 rTotal = (MAX - (MAX % tTotal));
        _rOwned[ReceivedAddress] = rTotal;
        _tOwned[ReceivedAddress] = tTotal;
        emit Transfer(address(0), ReceivedAddress, tTotal);
        _rTotal = rTotal;
        _tTotal = tTotal;

        fundAddress = FundAddress;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[ReceivedAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[deadAddress] = true;

        _usdtAddress = USDTAddress;

        _minTotal = MinTotal * 10 ** Decimals;
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

    function validTotal() public view returns (uint256) {
        return _tTotal - balanceOf(address(0)) - balanceOf(deadAddress);
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_excludeRewardList[account]) {
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
                if (_feeWhiteList[from] && to == _usdtPair && IERC20(to).totalSupply() == 0) {
                    startTradeBlock = block.number;
                }
            }

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                require(0 < startTradeBlock, "!Trading");
                if (block.number < startTradeBlock + 4) {
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
            uint256 devAmount = tAmount * _devFee / 10000;
            if (devAmount > 0) {
                feeAmount += devAmount;
                _takeTransfer(sender, devAddress, devAmount, currentRate);
            }

            uint256 fundAmount = tAmount * _fundFee / 10000;
            if (fundAmount > 0) {
                feeAmount += fundAmount;
                _takeTransfer(sender, fundAddress, fundAmount, currentRate);
            }

            uint256 ecologyAmount = tAmount * _ecologyFee / 10000;
            if (ecologyAmount > 0) {
                feeAmount += ecologyAmount;
                _takeTransfer(sender, ecologyAddress, ecologyAmount, currentRate);
            }

            uint256 unionAmount = tAmount * _unionFee / 10000;
            if (unionAmount > 0) {
                feeAmount += unionAmount;
                _takeTransfer(sender, unionAddress, unionAmount, currentRate);
            }

            uint256 destroyFeeAmount = _destroyFee * tAmount / 10000;
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
                    _takeTransfer(sender, deadAddress, destroyAmount, currentRate);
                }
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

    function claimToken(address token, uint256 amount, address to) external {
        if (msg.sender == _owner || msg.sender == fundAddress) {
            IERC20(token).transfer(to, amount);
        }
    }

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
        if (enable) {
            _excludeRewardList[addr] = true;
        }
    }

    function setExcludeReward(address addr, bool enable) external onlyOwner {
        _tOwned[addr] = balanceOf(addr);
        _rOwned[addr] = _tOwned[addr] * _getRate();
        _excludeRewardList[addr] = enable;
    }

    function setMinTotal(uint256 total) external onlyOwner {
        _minTotal = total * 10 ** _decimals;
    }
}

contract DNA is AbsToken {
    constructor() AbsToken(
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        address(0x55d398326f99059fF775485246999027B3197955),
        "DNA",
        "DNA",
        18,
        100000000,
    //Fund
        address(0x4a9C6de73d53Ee18133ff4217aD9E09Ad117cad0),
    //Received
        address(0x50348bb1eF918c0A0bAe65d8b664ed6160F64694),
        10000000
    ){

    }
}