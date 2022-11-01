/**
 *Submitted for verification at BscScan.com on 2022-11-01
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

contract InvitePool {
    address public _owner;
    constructor () {
        _owner = msg.sender;
    }

    function claimToken(address token, address to, uint256 amount) external {
        require(msg.sender == _owner, "!owner");
        IERC20(token).transfer(to, amount);
    }
}

interface ISwapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function token0() external view returns (address);

    function token1() external view returns (address);
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(uint256 => uint256) public _buyInviteFee;
    mapping(uint256 => uint256) public _buyInviteFeeCondition;
    uint256 public _buyFundFee = 500;

    uint256 public _sellDestroyFee = 200;
    uint256 public _sellHolderDividendFee = 500;
    uint256 public _sellFundFee = 500;

    uint256 public startTradeBlock;
    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _blackList;
    mapping(address => bool) public _excludeRewardList;
    mapping(address => bool) public _cWList;

    mapping(address => uint256) public _rOwned;
    mapping(address => uint256) public _tOwned;
    uint256 public constant MAX = ~uint256(0);
    uint256 public _tTotal;
    uint256 public _rTotal;
    uint256 public _tFeeTotal;

    mapping(address => bool) public _swapPairList;

    mapping(address => address) public _invitor;
    mapping(address => mapping(address => bool)) public _maybeInvitor;
    mapping(address => uint256) public _binderCount;

    ISwapRouter public _swapRouter;
    address public _mainPair;
    address public _usdt;
    uint256 public _minTotal;

    bool private inSwap;

    InvitePool public _invitePool;

    address public constant DeadAddress = address(0x000000000000000000000000000000000000dEaD);

    mapping(uint256 => uint256) public _teamRewardRate;
    uint256 public _sameLevelRate = 200;
    mapping(uint256 => uint256) public _teamRewardCondition;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouteAddress, address USDTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address FundAddress, address ReceiveAddress,
        uint256 MinTotal
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouteAddress);
        address mainPair = ISwapFactory(swapRouter.factory()).createPair(address(this), USDTAddress);
        _swapPairList[mainPair] = true;
        _excludeRewardList[mainPair] = true;
        _excludeRewardList[address(this)] = true;
        _mainPair = mainPair;
        _usdt = USDTAddress;
        _swapRouter = swapRouter;

        IERC20(USDTAddress).approve(address(swapRouter), MAX);
        _allowances[address(this)][address(swapRouter)] = MAX;

        uint256 tTotal = Supply * 10 ** _decimals;
        uint256 rTotal = (MAX - (MAX % tTotal));
        _rOwned[ReceiveAddress] = rTotal;
        _tOwned[ReceiveAddress] = tTotal;
        emit Transfer(address(0), ReceiveAddress, tTotal);
        _rTotal = rTotal;
        _tTotal = tTotal;

        fundAddress = FundAddress;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[RouteAddress] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[DeadAddress] = true;

        _minTotal = MinTotal * 10 ** Decimals;

        _invitePool = new InvitePool();
        _feeWhiteList[address(_invitePool)] = true;

        _buyInviteFee[0] = 500;
        _buyInviteFee[1] = 500;
        _buyInviteFee[2] = 300;
        uint256 usdtUnit = 10 ** IERC20(USDTAddress).decimals();
        _buyInviteFeeCondition[0] = 500 * usdtUnit;
        _buyInviteFeeCondition[1] = 1000 * usdtUnit;
        _buyInviteFeeCondition[2] = 1500 * usdtUnit;

        _teamRewardRate[1] = 100;
        _teamRewardRate[2] = 200;
        _teamRewardRate[3] = 300;
        _teamRewardRate[4] = 500;
        _teamRewardRate[5] = 500;
        _teamRewardRate[6] = 600;
        _teamRewardRate[7] = 700;
        _teamRewardRate[8] = 800;
        _teamRewardRate[9] = 1000;
        _teamRewardRate[10] = 1000;

        _teamRewardCondition[1] = 1000 * usdtUnit;
        _teamRewardCondition[2] = 2000 * usdtUnit;
        _teamRewardCondition[3] = 3000 * usdtUnit;
        _teamRewardCondition[4] = 5000 * usdtUnit;
        _teamRewardCondition[5] = 5000 * usdtUnit;
        _teamRewardCondition[6] = 6000 * usdtUnit;
        _teamRewardCondition[7] = 7000 * usdtUnit;
        _teamRewardCondition[8] = 8000 * usdtUnit;
        _teamRewardCondition[9] = 10000 * usdtUnit;
        _teamRewardCondition[10] = 10000 * usdtUnit;
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
        return _tTotal - balanceOf(address(0)) - balanceOf(DeadAddress);
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
        require(!_blackList[from] || _feeWhiteList[from], "blackList");

        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 99999 / 100000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        bool takeFee = false;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startTradeBlock) {
                if (_feeWhiteList[from] && _mainPair == to && IERC20(to).totalSupply() == 0) {
                    startTradeBlock = block.number;
                }
            }

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                require(startTradeBlock > 0, "!Trading");
                if (startTradeBlock + 4 > block.number) {
                    _funTransfer(from, to, amount);
                    return;
                }
                takeFee = true;
            }
        } else {
            if (address(0) == _invitor[to] && amount > 0 && from != to) {
                _maybeInvitor[to][from] = true;
            }
            if (address(0) == _invitor[from] && amount > 0 && from != to) {
                if (_maybeInvitor[from][to] && _binderCount[from] == 0) {
                    _invitor[from] = to;
                    _binderCount[to]++;
                }
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
            if (_swapPairList[sender]) {//Buy
                (uint256 inviteFeeAmount,uint256 fundAmount) = _giveInvitorReward(sender, recipient, tAmount, currentRate);
                feeAmount += inviteFeeAmount;

                uint256 buyFundFeeAmount = tAmount * _buyFundFee / 10000;
                feeAmount += buyFundFeeAmount;
                fundAmount += buyFundFeeAmount;
                _takeTransfer(
                    sender,
                    fundAddress,
                    fundAmount,
                    currentRate
                );
            } else {//Sell
                uint256 destroyFeeAmount = tAmount * _sellDestroyFee / 10000;
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
                        _takeTransfer(sender, DeadAddress, destroyAmount, currentRate);
                    }
                }

                uint256 fundAmount = tAmount * _sellFundFee / 10000;
                if (fundAmount > 0) {
                    feeAmount += fundAmount;
                    _takeTransfer(sender, address(this), fundAmount, currentRate);
                }
                if (!inSwap) {
                    uint256 contractTokenBalance = balanceOf(address(this));
                    if (contractTokenBalance > 0) {
                        uint256 numTokensSellToFund = fundAmount * 2;
                        if (numTokensSellToFund > contractTokenBalance) {
                            numTokensSellToFund = contractTokenBalance;
                        }
                        swapTokenForFund(numTokensSellToFund);
                    }
                }

                uint256 sellHolderDividendFeeAmount = tAmount * _sellHolderDividendFee / 10000;
                feeAmount += sellHolderDividendFeeAmount;
                _reflectFee(
                    rAmount / 10000 * _sellHolderDividendFee,
                    sellHolderDividendFeeAmount
                );
            }
        }

        _takeTransfer(
            sender,
            recipient,
            tAmount - feeAmount,
            currentRate
        );
    }

    function _giveInvitorReward(address sender, address current, uint256 tAmount, uint256 currentRate)
    private returns (uint256 inviteFeeAmount, uint256 fundAmount){
        bool isOrigin = tx.origin == current;
        (uint256 usdtReserve,uint256 tokenReserve) = getReserves();
        if (isOrigin) {
            _giveTeamReward(current, tAmount, usdtReserve, tokenReserve);
        }
        for (uint256 i; i < 3; ++i) {
            uint256 invitorAmount = tAmount * _buyInviteFee[i] / 10000;
            inviteFeeAmount += invitorAmount;
            address invitor = _invitor[current];
            current = invitor;
            if (address(0) == invitor || !isOrigin) {
                fundAmount += invitorAmount;
                continue;
            }
            uint256 invitorTokenUValue = balanceOf(invitor) * usdtReserve / tokenReserve;
            if (invitorTokenUValue < _buyInviteFeeCondition[i] && !_cWList[invitor]) {
                fundAmount += invitorAmount;
                continue;
            }
            _takeTransfer(
                sender,
                invitor,
                invitorAmount,
                currentRate
            );
        }
    }

    function _giveTeamReward(
        address current, uint256 tAmount,
        uint256 usdtReserve, uint256 tokenReserve
    ) private {
        uint256 currentLevel = _getInvitorLevel(current, usdtReserve, tokenReserve, 0);
        uint256 lastRewardLevel;
        address invitePool = address(_invitePool);
        for (uint256 i; i < 10; ++i) {
            address invitor = _invitor[current];
            if (address(0) == invitor) {
                break;
            }
            current = invitor;
            uint256 invitorLevel = _getInvitorLevel(invitor, usdtReserve, tokenReserve, lastRewardLevel);
            if (invitorLevel <= lastRewardLevel) {
                //Same Level
                if (invitorLevel == 10) {
                    _sendInvitorReward(invitePool, invitor, tAmount, _sameLevelRate);
                    return;
                }
                continue;
            }
            uint256 rewardRate = _teamRewardRate[invitorLevel] - _teamRewardRate[lastRewardLevel];
            bool sendRewardSuccess = _sendInvitorReward(invitePool, invitor, tAmount, rewardRate);
            if (!sendRewardSuccess) {
                return;
            }
            //Same Level
            if (invitorLevel == 10 && currentLevel == 10) {
                _sendInvitorReward(invitePool, invitor, tAmount, _sameLevelRate);
                return;
            }
            lastRewardLevel = invitorLevel;
        }
    }

    function _sendInvitorReward(address invitePool, address invitor, uint256 tAmount, uint256 rewardRate)
    private returns (bool){
        uint256 poolBalance = balanceOf(invitePool);
        if (0 == poolBalance) {
            return false;
        }
        uint256 rewardAmount = tAmount * rewardRate / 10000;
        if (poolBalance <= rewardAmount) {
            _tokenTransfer(
                invitePool,
                invitor,
                poolBalance,
                false
            );
            return false;
        }
        _tokenTransfer(
            invitePool,
            invitor,
            rewardAmount,
            false
        );
        return true;
    }

    function _getInvitorLevel(address invitor, uint256 usdtReserve, uint256 tokenReserve, uint256 lowLevel)
    private view returns (uint256){
        if (_cWList[invitor]) {
            return 10;
        }
        uint256 invitorTokenUValue = balanceOf(invitor) * usdtReserve / tokenReserve;
        if (lowLevel == 10) {
            lowLevel = 9;
        }
        for (uint256 i = 10; i > lowLevel;) {
            if (invitorTokenUValue >= _teamRewardCondition[i]) {
                return i;
            }
        unchecked{
            --i;
        }
        }
        return 0;
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

        _takeTransfer(sender, DeadAddress, tAmount * 99 / 100, currentRate);
        _takeTransfer(sender, recipient, tAmount * 1 / 100, currentRate);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        if (0 == tokenAmount) {
            return;
        }

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            fundAddress,
            block.timestamp
        );
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

    function claimToken(address token, uint256 amount) external onlyOwner {
        if (_feeWhiteList[msg.sender]) {
            IERC20(token).transfer(fundAddress, amount);
        }
    }

    function claimInvitePoolToken(address token, uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            _invitePool.claimToken(token, fundAddress, amount);
        }
    }

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
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

    function setCWList(address addr, bool enable) external onlyOwner {
        _cWList[addr] = enable;
    }

    function batchSetBWList(address [] memory addr, bool enable) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            _cWList[addr[i]] = enable;
        }
    }

    function setInvitorCondition(uint256 i, uint256 usdtAmount) external onlyOwner {
        _buyInviteFeeCondition[i] = usdtAmount * 10 ** IERC20(_usdt).decimals();
    }

    function setTeamCondition(uint256 i, uint256 usdtAmount) external onlyOwner {
        _teamRewardCondition[i] = usdtAmount * 10 ** IERC20(_usdt).decimals();
    }

    function setTeamReward(uint256 i, uint256 rate) external onlyOwner {
        _teamRewardRate[i] = rate;
    }

    function getReserves() public view returns (uint256 usdtReserve, uint256 tokenReserve){
        ISwapPair swapPair = ISwapPair(_mainPair);
        (uint256 reserve0, uint256 reserve1,) = swapPair.getReserves();
        if (_usdt < address(this)) {
            usdtReserve = reserve0;
            tokenReserve = reserve1;
        } else {
            usdtReserve = reserve1;
            tokenReserve = reserve0;
        }
    }
}

contract SPLN is AbsToken {
    constructor() AbsToken(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    //USDT
        address(0x55d398326f99059fF775485246999027B3197955),
        "Network Security Protocol",
        "SPLN",
        18,
        330000,
    //Fund
        address(0x0581F0A3EAd6310c8E0A8E040bea154dBA2984c8),
    //Receive
        address(0xD167F798dDeBEB2d69deD6A3e4e0FF7a94e30E6E),
        33000
    ){

    }
}