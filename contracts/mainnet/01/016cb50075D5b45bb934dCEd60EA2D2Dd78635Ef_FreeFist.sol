/**
 *Submitted for verification at BscScan.com on 2022-06-30
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

interface INFTDividend {
    function addTokenReward(uint256 rewardAmount) external;
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 public _buyInviteFee = 6;
    uint256 public _buyLPFee = 2;
    uint256 public _buyFundFee = 2;

    uint256 public _sellFundFee = 2;
    uint256 public _sellNFTFee = 8;

    uint256 public startTradeBlock;
    uint256 public startAddLPBlock;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _excludeRewardList;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;
    uint256 public _rTotal;

    mapping(address => bool) public _swapPairList;

    uint256 public _limitAmount;

    uint256  public apr15Minutes = 20630;
    uint256 private constant AprDivBase = 100000000;
    uint256 public _lastRewardTime;
    bool public _autoApy;
    uint256 public _invitorHoldCondition;

    bool private inSwap;

    address public _fist;
    ISwapRouter public _swapRouter;

    address public _nftAddress;

    constructor (address RouteAddress, address FistAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address ReceivedAddress, address FundAddress, address NFTAddress){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouteAddress);
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        _fist = FistAddress;
        address swapPair = ISwapFactory(swapRouter.factory()).createPair(address(this), FistAddress);
        _swapPairList[swapPair] = true;
        _excludeRewardList[swapPair] = true;

        uint256 tTotal = Supply * 10 ** Decimals;
        uint256 base = AprDivBase * 100;
        uint256 rTotal = MAX / base - (MAX / base % tTotal);
        _rOwned[ReceivedAddress] = rTotal;
        _tOwned[ReceivedAddress] = tTotal;
        emit Transfer(address(0), ReceivedAddress, tTotal);
        _rTotal = rTotal;
        _tTotal = tTotal;

        fundAddress = FundAddress;
        _nftAddress = NFTAddress;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[NFTAddress] = true;
        _feeWhiteList[ReceivedAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(swapRouter)] = true;

        _inProject[msg.sender] = true;
    }

    function calApy() public {
        if (!_autoApy) {
            return;
        }
        uint256 total = _tTotal;
        uint256 maxTotal = _rTotal;
        if (total == maxTotal) {
            return;
        }
        uint256 blockTime = block.timestamp;
        uint256 lastRewardTime = _lastRewardTime;
        if (blockTime < lastRewardTime + 15 minutes) {
            return;
        }
        uint256 deltaTime = blockTime - lastRewardTime;
        uint256 times = deltaTime / 15 minutes;

        for (uint256 i; i < times;) {
            total = total * (AprDivBase + apr15Minutes) / AprDivBase;
            if (total > maxTotal) {
                total = maxTotal;
                break;
            }
        unchecked{
            ++i;
        }
        }
        _tTotal = total;
        _lastRewardTime = lastRewardTime + times * 15 minutes;
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

    function tokenFromReflection(uint256 rAmount) public view returns (uint256){
        uint256 currentRate = _getRate();
        return rAmount / currentRate;
    }

    function _getRate() public view returns (uint256) {
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
        calApy();

        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 99999 / 100000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        bool takeFee;
        bool isBuy;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startAddLPBlock) {
                if (_feeWhiteList[from] && _swapPairList[to] && IERC20(to).totalSupply() == 0) {
                    startAddLPBlock = block.number;
                }
            }

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                if (0 == startTradeBlock) {
                    require(0 < startAddLPBlock && _swapPairList[to], "!startAddLP");
                }
                if (block.number < startTradeBlock + 4) {
                    _funTransfer(from, to, amount);
                    return;
                }

                takeFee = true;
                if (_swapPairList[from]) {
                    isBuy = true;
                }
            }
        } else {
            if (0 == balanceOf(to) && amount > 0) {
                _bindInvitor(to, from);
            }
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                takeFee = true;
            }
        }

        _tokenTransfer(from, to, amount, takeFee, isBuy);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isBuy
    ) private {
        if (_tOwned[sender] > tAmount) {
            _tOwned[sender] -= tAmount;
        } else {
            _tOwned[sender] = 0;
        }

        uint256 currentRate = _getRate();
        _rOwned[sender] = _rOwned[sender] - tAmount * currentRate;

        uint256 feeAmount;
        if (takeFee) {
            if (isBuy) {
                uint256 totalInviteAmount = tAmount * _buyInviteFee / 100;
                feeAmount += totalInviteAmount;
                uint256 fundAmount = totalInviteAmount;
                if (totalInviteAmount > 0) {
                    address current = recipient;
                    address invitor;
                    uint256 inviterAmount;
                    uint256 perInviteAmount = totalInviteAmount / 20;
                    uint256 invitorHoldCondition = _invitorHoldCondition;
                    for (uint256 i; i < 10;) {
                        invitor = _inviter[current];
                        if (address(0) == invitor) {
                            break;
                        }
                        if (0 == i) {
                            inviterAmount = perInviteAmount * 8;
                        } else if (1 == i) {
                            inviterAmount = perInviteAmount * 4;
                        } else {
                            inviterAmount = perInviteAmount;
                        }
                        if (0 == invitorHoldCondition || balanceOf(invitor) >= invitorHoldCondition) {
                            fundAmount -= inviterAmount;
                            _takeTransfer(sender, invitor, inviterAmount, currentRate);
                        }
                        current = invitor;
                    unchecked{
                        ++i;
                    }
                    }
                }
                if (fundAmount > 1000) {
                    _takeTransfer(sender, address(this), fundAmount, currentRate);
                }
                uint256 lpAmount = tAmount * _buyLPFee / 100;
                if (lpAmount > 0) {
                    feeAmount += lpAmount;
                    _takeTransfer(sender, sender, lpAmount, currentRate);
                }

                uint256 fundFeeAmount = tAmount * _buyFundFee / 100;
                if (fundFeeAmount > 0) {
                    feeAmount += fundFeeAmount;
                    _takeTransfer(sender, address(this), fundFeeAmount, currentRate);
                }
            } else {
                uint256 fundAmount = tAmount * _sellFundFee / 100;
                if (fundAmount > 0) {
                    feeAmount += fundAmount;
                    _takeTransfer(sender, address(this), fundAmount, currentRate);
                }
                uint256 nftAmount = tAmount * _sellNFTFee / 100;
                if (nftAmount > 0) {
                    feeAmount += nftAmount;
                    _takeTransfer(sender, _nftAddress, nftAmount, currentRate);
                    INFTDividend(_nftAddress).addTokenReward(nftAmount);
                }
                if (!inSwap && _swapPairList[recipient]) {
                    inSwap = true;
                    uint256 swapAmount = fundAmount * 3;
                    uint256 thisAmount = balanceOf(address(this));
                    if (swapAmount > thisAmount) {
                        swapAmount = thisAmount;
                    }
                    if (swapAmount > 0) {
                        address[] memory path = new address[](2);
                        path[0] = address(this);
                        path[1] = _fist;
                        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                            swapAmount,
                            0,
                            path,
                            fundAddress,
                            block.timestamp
                        );
                    }
                    inSwap = false;
                }
            }
        }

        _takeTransfer(
            sender,
            recipient,
            tAmount - feeAmount,
            currentRate
        );
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

        _takeTransfer(sender, fundAddress, tAmount / 100 * 80, currentRate);
        _takeTransfer(sender, recipient, tAmount / 100 * 20, currentRate);
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

        if (_limitAmount > 0 && !_swapPairList[to] && !_feeWhiteList[to]) {
            require(_limitAmount >= balanceOf(to), "exceed LimitAmount");
        }
    }

    receive() external payable {}

    function claimBalance() external onlyFunder {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount, address to) external onlyFunder {
        IERC20(token).transfer(to, amount);
    }

    function setFundAddress(address addr) external onlyFunder {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setNFTAddress(address addr) external onlyOwner {
        _nftAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyFunder {
        _feeWhiteList[addr] = enable;
    }

    function setSwapPairList(address addr, bool enable) external onlyFunder {
        _swapPairList[addr] = enable;
        if (enable) {
            _excludeRewardList[addr] = true;
        }
    }

    function setExcludeReward(address addr, bool enable) external onlyFunder {
        _tOwned[addr] = balanceOf(addr);
        _rOwned[addr] = _tOwned[addr] * _getRate();
        _excludeRewardList[addr] = enable;
    }

    function setBuyFee(uint256 buyInviteFee, uint256 buyLPFee, uint256 buyFundFee) external onlyOwner {
        _buyInviteFee = buyInviteFee;
        _buyLPFee = buyLPFee;
        _buyFundFee = buyFundFee;
    }

    function setSellFee(uint256 sellFundFee, uint256 sellNFTFee) external onlyOwner {
        _sellFundFee = sellFundFee;
        _sellNFTFee = sellNFTFee;
    }

    function setLimitAmount(uint256 amount) external onlyFunder {
        _limitAmount = amount * 10 ** _decimals;
    }

    function startTrade() external onlyFunder {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
    }

    function startAutoApy() external onlyFunder {
        require(!_autoApy, "autoAping");
        _autoApy = true;
        _lastRewardTime = block.timestamp;
    }

    function emergencyCloseAutoApy() external onlyFunder {
        _autoApy = false;
    }

    function closeAutoApy() external onlyFunder {
        calApy();
        _autoApy = false;
    }

    function setApr15Minutes(uint256 apr) external onlyFunder {
        calApy();
        apr15Minutes = apr;
    }

    function setInvitorHoldCondition(uint256 amount) external onlyFunder {
        _invitorHoldCondition = amount * 10 ** _decimals;
    }

    modifier onlyFunder() {
        require(_owner == msg.sender || fundAddress == msg.sender, "!Funder");
        _;
    }

    mapping(address => address) public _inviter;
    mapping(address => address[]) public _binders;
    mapping(address => bool) public _inProject;

    function bindInvitor(address account, address invitor) public {
        address caller = msg.sender;
        require(_inProject[caller], "notInProj");
        _bindInvitor(account, invitor);
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

    function setInProject(address adr, bool enable) external onlyFunder {
        _inProject[adr] = enable;
    }

    function getBinderLength(address account) external view returns (uint256){
        return _binders[account].length;
    }
}

contract FreeFist is AbsToken {
    constructor() AbsToken(
        address(0x1B6C9c20693afDE803B27F8782156c0f892ABC2d),
        address(0xC9882dEF23bc42D53895b8361D0b1EDC7570Bc6A),
        "Free Fist-DAO",
        "free fist",
        6,
        500000000,
        address(0x98a0ddD47F767E75653941dE523Cd1Eb6623847F),
        address(0xBFDfd544C5429eB5FD46136355E052FF79fa172c),
        address(0x92Efd62351cb49eF9A54Ac225717871B0bd20531)
    ){

    }
}