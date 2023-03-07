/**
 *Submitted for verification at BscScan.com on 2023-03-07
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
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
        require(_owner == msg.sender, "!o");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "n0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract TokenDistributor {
    address public _owner;
    constructor () {
        _owner = msg.sender;
    }

    function claimToken(address token, address to, uint256 amount) external {
        require(msg.sender == _owner, "!o");
        IERC20(token).transfer(to, amount);
    }
}

interface ISwapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function token0() external view returns (address);

    function sync() external;

    function totalSupply() external view returns (uint);
}

abstract contract AbsToken is IERC20, Ownable {
    struct UserInfo {
        uint256 buyAmount;
        uint256 lastRewardTime;
    }

    mapping(address => uint256) public _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;

    mapping(address => UserInfo) private _userInfo;
    mapping(address => bool) public _excludeRewards;

    uint256 private _tTotal;

    ISwapRouter public immutable _swapRouter;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public immutable _tokenDistributor;

    uint256 public _buyLPDividendFee = 300;
    uint256 public _buyDestroyFee = 50;
    uint256 public _buyLPFee = 100;
    uint256 public _buyFundFee = 100;

    uint256 public _sellLPDividendFee = 300;
    uint256 public _sellDestroyFee = 250;
    uint256 public _sellLPFee = 100;
    uint256 public _sellFundFee = 100;

    uint256 public startTradeBlock;
    uint256 public startAddLPBlock;
    address public immutable _mainPair;
    address public  immutable _weth;

    mapping(address => address) public _inviter;
    mapping(address => address[]) public _binders;
    mapping(address => mapping(address => bool)) public _maybeInvitor;

    uint256 public _startTradeTime;
    uint256 public _removeLPFeeDuration = 30 days;
    uint256 public _removeLPFee = 10000;
    mapping(address => bool) public _preLPList;

    uint256 public _startRewardTime = 1680105600;
    uint256 public _rewardRate = 41624;
    uint256 public constant _rewardFactor = 100000000;
    uint256 public _rewardDuration = 4 hours;
    uint256 public _rewardCondition;

    uint256 public _startLPRewardTime = 1679241600;
    TokenDistributor public immutable _dogeLPRewardDistributor;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address ReceiveAddress, address FundAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        _weth = swapRouter.WETH();
        address mainPair = swapFactory.createPair(address(this), _weth);
        _swapPairList[mainPair] = true;

        _mainPair = mainPair;

        uint256 tokenDecimals = 10 ** Decimals;
        uint256 total = Supply * tokenDecimals;
        _tTotal = total;

        uint256 receiveTotal = total * 10000 / 30000;
        _balances[ReceiveAddress] = receiveTotal;
        emit Transfer(address(0), ReceiveAddress, receiveTotal);
        fundAddress = FundAddress;

        receiveTotal = total * 7000 / 30000;
        _tokenDistributor = new  TokenDistributor();
        address tokenDistributor = address(_tokenDistributor);
        _balances[tokenDistributor] = receiveTotal;
        emit Transfer(address(0), tokenDistributor, receiveTotal);

        receiveTotal = total * 13000 / 30000;
        _dogeLPRewardDistributor = new  TokenDistributor();
        address dogeLPRewardDistributor = address(_dogeLPRewardDistributor);
        _balances[dogeLPRewardDistributor] = receiveTotal;
        emit Transfer(address(0), dogeLPRewardDistributor, receiveTotal);

        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;
        _feeWhiteList[tokenDistributor] = true;
        _feeWhiteList[dogeLPRewardDistributor] = true;

        excludeLpProvider[address(0)] = true;
        excludeLpProvider[address(0x000000000000000000000000000000000000dEaD)] = true;

        _excludeRewards[address(0)] = true;
        _excludeRewards[address(0x000000000000000000000000000000000000dEaD)] = true;
        _excludeRewards[address(this)] = true;
        _excludeRewards[tokenDistributor] = true;
        _excludeRewards[dogeLPRewardDistributor] = true;
        _excludeRewards[mainPair] = true;
        _excludeRewards[address(swapRouter)] = true;

        lpRewardCondition = 1 ether / 2;
        _rewardCondition = 10 * tokenDecimals;

        _addLpProvider(FundAddress);

        _dogeLPRewardCondition = 25 * tokenDecimals;
        _dogeLPInviteRewardCondition = 25 * tokenDecimals;
        lpHoldCondition = 10 ** IERC20(_mainPair).decimals() / 1000000;
        _dogeLPInviteRewardHoldThisCondition = 1 * tokenDecimals;
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
        (uint256 balance,) = _balanceOf(account);
        return balance;
    }

    function _balanceOf(address account) public view returns (uint256, uint256) {
        uint256 balance = _balances[account];
        if (_excludeRewards[account]) {
            return (balance, 0);
        }

        uint256 startTime = _startRewardTime;
        if (0 == startTime) {
            return (balance, 0);
        }

        uint256 rewardRate = _rewardRate;
        if (0 == rewardRate) {
            return (balance, 0);
        }

        UserInfo storage userInfo = _userInfo[account];
        uint256 buyAmount = userInfo.buyAmount;
        if (buyAmount < _rewardCondition) {
            return (balance, 0);
        }

        uint256 lastRewardTime = userInfo.lastRewardTime;
        if (lastRewardTime == 0) {
            lastRewardTime = startTime;
        }

        if (lastRewardTime < startTime) {
            lastRewardTime = startTime;
        }

        uint256 blockTime = block.timestamp;
        if (blockTime <= lastRewardTime) {
            return (balance, 0);
        }

        uint256 rewardDuration = _rewardDuration;
        uint256 times = (blockTime - lastRewardTime) / rewardDuration;
        uint256 reward;
        uint256 totalReward;
        for (uint256 i; i < times;) {
            reward = buyAmount * rewardRate / _rewardFactor;
            totalReward += reward;
            buyAmount += reward;
        unchecked{
            ++i;
        }
        }
        uint256 rewardBalance = _balances[address(_tokenDistributor)];
        if (totalReward > rewardBalance) {
            totalReward = rewardBalance;
        }
        return (balance + totalReward, lastRewardTime + times * rewardDuration);
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

    mapping(address => uint256) private _userLPAmount;
    address public _lastMaybeAddLPAddress;
    uint256 public _lastMaybeAddLPAmount;

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        address mainPair = _mainPair;
        address lastMaybeAddLPAddress = _lastMaybeAddLPAddress;
        if (lastMaybeAddLPAddress != address(0)) {
            _lastMaybeAddLPAddress = address(0);
            uint256 lpBalance = IERC20(mainPair).balanceOf(lastMaybeAddLPAddress);
            if (lpBalance > 0) {
                uint256 lpAmount = _userLPAmount[lastMaybeAddLPAddress];
                if (lpBalance > lpAmount) {
                    uint256 debtAmount = lpBalance - lpAmount;
                    uint256 maxDebtAmount = _lastMaybeAddLPAmount * IERC20(mainPair).totalSupply() / _balances[mainPair];
                    if (debtAmount > maxDebtAmount) {
                        excludeLpProvider[lastMaybeAddLPAddress] = true;
                    } else {
                        _addLpProvider(lastMaybeAddLPAddress);
                        _userLPAmount[lastMaybeAddLPAddress] = lpBalance;
                        uint256 blockTime = block.timestamp;
                        if (0 == _lastLPRewardTimes[lastMaybeAddLPAddress]) {
                            _lastLPRewardTimes[lastMaybeAddLPAddress] = blockTime;
                        }
                        if (0 == _lastDogeLPRewardTimes[lastMaybeAddLPAddress]) {
                            _lastDogeLPRewardTimes[lastMaybeAddLPAddress] = blockTime;
                        }
                    }
                }
            }
        }

        _calReward(from, to, amount);

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount;
            uint256 remainAmount = 10 ** (_decimals - 4);
            uint256 balance = _balances[from];
            if (balance > remainAmount) {
                maxSellAmount = balance - remainAmount;
            }
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        bool isAddLP;
        bool takeFee;
        bool isRemoveLP;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startAddLPBlock) {
                if (_feeWhiteList[from] && to == _mainPair && IERC20(to).totalSupply() == 0) {
                    startAddLPBlock = block.number;
                }
            }
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                takeFee = true;
                if (to == _mainPair) {
                    isAddLP = _isAddLiquidity(amount);
                    if (isAddLP) {
                        takeFee = false;
                    }
                } else if (from == _mainPair) {
                    isRemoveLP = _isRemoveLiquidity();
                }

                if (0 == startTradeBlock) {
                    require(0 < startAddLPBlock && isAddLP, "!T");
                    _preLPList[from] = true;
                }

                if (block.number < startTradeBlock + 3) {
                    _funTransfer(from, to, amount);
                    return;
                }
            }
        } else {
            if (address(0) == _inviter[to] && amount > 0 && from != to) {
                _maybeInvitor[to][from] = true;
            }
            if (address(0) == _inviter[from] && amount > 0 && from != to) {
                if (_maybeInvitor[from][to] && _binders[from].length == 0) {
                    _bindInvitor(from, to);
                }
            }
        }

        if (from == address(_swapRouter)) {
            isRemoveLP = true;
        }

        if (isRemoveLP) {
            if (!_feeWhiteList[to]) {
                takeFee = true;
                uint256 liquidity = (amount * ISwapPair(_mainPair).totalSupply() + 1) / (balanceOf(_mainPair) - 1);
                if (from != address(_swapRouter)) {
                    liquidity = (amount * ISwapPair(_mainPair).totalSupply() + 1) / (balanceOf(_mainPair) - amount - 1);
                }
                require(_userLPAmount[to] >= liquidity, ">uLP");
                _userLPAmount[to] -= liquidity;
            }
        }

        _tokenTransfer(from, to, amount, takeFee, isRemoveLP);

        UserInfo storage userInfo = _userInfo[to];
        userInfo.buyAmount = _balances[to];

        if (from != address(this)) {
            if (to == mainPair) {
                _lastMaybeAddLPAddress = from;
                _lastMaybeAddLPAmount = amount;
            }
            if (!_feeWhiteList[from] && !isAddLP) {
                uint256 rewardGas = _rewardGas;
                processDogeLP(rewardGas);
                if (_progressDogeLPBlock != block.number) {
                    processThisLP(rewardGas);
                }
            }
        }
    }

    function _calReward(address from, address to, uint256 amount) private {
        (uint256 fromBalance,uint256 fromTime) = _balanceOf(from);
        require(fromBalance >= amount, "BNE");

        address mainPair = _mainPair;
        address sender = address(_tokenDistributor);
        uint256 fromReward;
        if (from != mainPair) {
            uint256 fromBalanceBefore = _balances[from];
            fromReward = fromBalance - fromBalanceBefore;
            if (fromReward > 0) {
                _tokenTransfer(sender, from, fromReward, false, false);
                _balances[from] = fromBalance;
            }
            if (fromTime == 0 && _startRewardTime > 0) {
                fromTime = block.timestamp;
            }
            _userInfo[from].lastRewardTime = fromTime;
        }

        uint256 toReward;
        if (to != mainPair) {
            (uint256 toBalance,uint256 toTime) = _balanceOf(to);
            uint256 toBalanceBefore = _balances[to];
            toReward = toBalance - toBalanceBefore;
            if (toReward > 0) {
                _tokenTransfer(sender, to, toReward, false, false);
                _balances[to] = toBalance;
            }
            if (toTime == 0 && _startRewardTime > 0) {
                toTime = block.timestamp;
            }
            _userInfo[to].lastRewardTime = toTime;
        }

        _distributeInviteReward(from, fromReward, sender);
        _distributeInviteReward(to, toReward, sender);
    }

    function _bindInvitor(address account, address invitor) private {
        if (invitor != address(0) && invitor != account && _inviter[account] == address(0)) {
            uint256 size;
            assembly {size := extcodesize(invitor)}
            if (size > 0) {
                return;
            }
            _inviter[account] = invitor;
            _binders[invitor].push(account);
        }
    }

    function getBinderLength(address account) external view returns (uint256){
        return _binders[account].length;
    }

    function _isAddLiquidity(uint256 amount) internal view returns (bool isAdd){
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0, uint256 r1,) = mainPair.getReserves();

        address tokenOther = _weth;
        uint256 r;
        uint256 rToken;
        if (tokenOther < address(this)) {
            r = r0;
            rToken = r1;
        } else {
            r = r1;
            rToken = r0;
        }

        uint bal = IERC20(tokenOther).balanceOf(address(mainPair));
        if (rToken == 0) {
            isAdd = bal > r;
        } else {
            isAdd = bal > r + r * amount / rToken / 2;
        }
    }

    function _isRemoveLiquidity() internal view returns (bool isRemove){
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0,uint256 r1,) = mainPair.getReserves();

        address tokenOther = _weth;
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

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isRemoveLP
    ) private {
        uint256 senderBalance = _balances[sender];
        senderBalance -= tAmount;
        _balances[sender] = senderBalance;
        UserInfo storage userInfo = _userInfo[sender];
        userInfo.buyAmount = senderBalance;

        uint256 feeAmount;

        if (takeFee) {
            bool isSell;
            uint256 swapFeeAmount;
            uint256 destroyFeeAmount;
            if (isRemoveLP) {
                if (_preLPList[recipient] && block.timestamp < _startTradeTime + _removeLPFeeDuration) {
                    destroyFeeAmount = tAmount * _removeLPFee / 10000;
                } else {
                    swapFeeAmount = tAmount * (_buyLPDividendFee + _buyLPFee + _buyFundFee) / 10000;
                    destroyFeeAmount = tAmount * _buyDestroyFee / 10000;
                }
            } else if (_swapPairList[sender]) {//Buy
                swapFeeAmount = tAmount * (_buyLPDividendFee + _buyLPFee + _buyFundFee) / 10000;
                destroyFeeAmount = tAmount * _buyDestroyFee / 10000;
            } else if (_swapPairList[recipient]) {//Sell
                isSell = true;
                swapFeeAmount = tAmount * (_sellLPDividendFee + _sellLPFee + _sellFundFee) / 10000;
                destroyFeeAmount = tAmount * _sellDestroyFee / 10000;
            }

            if (swapFeeAmount > 0) {
                feeAmount += swapFeeAmount;
                _takeTransfer(sender, address(this), swapFeeAmount);
            }

            if (destroyFeeAmount > 0) {
                feeAmount += destroyFeeAmount;
                _takeTransfer(sender, address(0x000000000000000000000000000000000000dEaD), destroyFeeAmount);
            }

            if (isSell && !inSwap) {
                uint256 contractTokenBalance = _balances[address(this)];
                uint256 numToSell = swapFeeAmount * 230 / 100;
                if (numToSell > contractTokenBalance) {
                    numToSell = contractTokenBalance;
                }
                swapTokenForFund(numToSell);
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _distributeInviteReward(address current, uint256 reward, address sender) private {
        if (0 == reward) {
            return;
        }
        uint256 rewardBalance = _balances[sender];
        if (0 == rewardBalance) {
            return;
        }
        address invitor;
        uint256 perAmount = reward / 100;
        uint256 invitorAmount = perAmount * 20;
        uint256 inviteRewardHoldThisCondition = _dogeLPInviteRewardHoldThisCondition;
        uint256 fundAmount = reward;
        for (uint256 i; i < 16;) {
            invitor = _inviter[current];
            if (address(0) == invitor) {
                break;
            }
            if (1 == i) {
                invitorAmount = perAmount * 5;
            } else if (15 == i) {
                invitorAmount = perAmount * 10;
            }
            if (_balances[invitor] >= inviteRewardHoldThisCondition) {
                if (invitorAmount > rewardBalance) {
                    invitorAmount = rewardBalance;
                }
                _tokenTransfer(sender, invitor, invitorAmount, false, false);
                rewardBalance -= invitorAmount;
                fundAmount -= invitorAmount;
                if (0 == rewardBalance) {
                    break;
                }
            }

            current = invitor;
        unchecked{
            ++i;
        }
        }
        if (fundAmount > 100) {
            if (fundAmount > rewardBalance) {
                fundAmount = rewardBalance;
            }
            _tokenTransfer(sender, fundAddress, fundAmount, false, false);
        }
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        if (tokenAmount == 0) {
            return;
        }
        uint256 lpDividendFee = _buyLPDividendFee + _sellLPDividendFee;
        uint256 lpFee = _buyLPFee + _sellLPFee;
        uint256 fundFee = _buyFundFee + _sellFundFee;
        uint256 totalFee = lpDividendFee + lpFee + fundFee;
        totalFee += totalFee;

        address distributor = address(this);
        uint256 balance = distributor.balance;

        uint256 lpAmount = tokenAmount * lpFee / totalFee;
        totalFee -= lpFee;

        address weth = _weth;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = weth;
        _swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount - lpAmount,
            0,
            path,
            distributor,
            block.timestamp
        );

        balance = distributor.balance - balance;

        uint256 fundBalance = balance * 2 * fundFee / totalFee;
        if (fundBalance > 0) {
            fundAddress.call{value : fundBalance}("");
        }

        uint256 lpBalance = balance * lpFee / totalFee;
        if (lpBalance > 0 && lpAmount > 0) {
            (,,uint256 liquidity) = _swapRouter.addLiquidityETH{value : lpBalance}(
                address(this),
                lpAmount,
                0,
                0,
                fundAddress,
                block.timestamp
            );
            _userLPAmount[fundAddress] += liquidity;
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

    modifier onlyWhiteList() {
        address msgSender = msg.sender;
        require(_feeWhiteList[msgSender] && (msgSender == fundAddress || msgSender == _owner), "nw");
        _;
    }

    function setFundAddress(address addr) external onlyWhiteList {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
        _addLpProvider(addr);
    }

    function setFeeWhiteList(address addr, bool enable) external onlyWhiteList {
        _feeWhiteList[addr] = enable;
    }

    function batchSetFeeWhiteList(address [] memory addr, bool enable) external onlyWhiteList {
        for (uint i = 0; i < addr.length; i++) {
            _feeWhiteList[addr[i]] = enable;
        }
    }

    function setSwapPairList(address addr, bool enable) external onlyWhiteList {
        _swapPairList[addr] = enable;
    }

    function claimBalance(uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            payable(fundAddress).transfer(amount);
        }
    }

    function claimToken(address token, uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            IERC20(token).transfer(fundAddress, amount);
        }
    }

    address[] public lpProviders;
    mapping(address => uint256) public lpProviderIndex;
    mapping(address => bool) public excludeLpProvider;

    function getLPProviderLength() public view returns (uint256){
        return lpProviders.length;
    }

    function _addLpProvider(address adr) private {
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

    uint256 public currentLPIndex;
    uint256 public lpRewardCondition;
    uint256 public progressLPBlock;
    uint256 public progressLPBlockDebt = 1;
    uint256 public lpHoldCondition = 1000;
    uint256 public _rewardGas = 500000;
    mapping(address => uint256) public _lastLPRewardTimes;
    uint256 public _lpRewardTimeDebt = 8 hours;

    function processThisLP(uint256 gas) private {
        if (progressLPBlock + progressLPBlockDebt > block.number) {
            return;
        }

        IERC20 mainpair = IERC20(_mainPair);
        uint totalPair = mainpair.totalSupply();
        if (0 == totalPair) {
            return;
        }

        uint256 rewardCondition = lpRewardCondition;
        if (address(this).balance < rewardCondition) {
            return;
        }

        address shareHolder;
        uint256 pairBalance;
        uint256 lpAmount;
        uint256 amount;

        uint256 shareholderCount = lpProviders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        uint256 holdCondition = lpHoldCondition;

        uint256 rewardTimeDebt = _lpRewardTimeDebt;
        uint256 blockTime = block.timestamp;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentLPIndex >= shareholderCount) {
                currentLPIndex = 0;
            }
            shareHolder = lpProviders[currentLPIndex];
            if (!excludeLpProvider[shareHolder]) {
                pairBalance = mainpair.balanceOf(shareHolder);
                lpAmount = _userLPAmount[shareHolder];
                if (lpAmount < pairBalance) {
                    pairBalance = lpAmount;
                }
                if (pairBalance >= holdCondition && blockTime > _lastLPRewardTimes[shareHolder] + rewardTimeDebt) {
                    amount = rewardCondition * pairBalance / totalPair;
                    if (amount > 0) {
                        shareHolder.call{value : amount}("");
                        _lastLPRewardTimes[shareHolder] = blockTime;
                    }
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentLPIndex++;
            iterations++;
        }

        progressLPBlock = block.number;
    }

    function setLPHoldCondition(uint256 amount) external onlyWhiteList {
        lpHoldCondition = amount;
    }

    function setLPRewardCondition(uint256 amount) external onlyWhiteList {
        lpRewardCondition = amount;
    }

    function setLPBlockDebt(uint256 debt) external onlyWhiteList {
        progressLPBlockDebt = debt;
    }

    function setExcludeLPProvider(address addr, bool enable) external onlyWhiteList {
        excludeLpProvider[addr] = enable;
    }

    receive() external payable {}

    function claimContractToken(address contractAddress, address token, uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            TokenDistributor(contractAddress).claimToken(token, fundAddress, amount);
        }
    }

    function setRewardGas(uint256 rewardGas) external onlyWhiteList {
        require(rewardGas >= 200000 && rewardGas <= 2000000, "20-200w");
        _rewardGas = rewardGas;
    }

    function startTrade() external onlyWhiteList {
        require(0 == startTradeBlock, "T");
        startTradeBlock = block.number;
        _startTradeTime = block.timestamp;
    }

    function setRemoveLPFeeDuration(uint256 d) external onlyOwner {
        _removeLPFeeDuration = d;
    }

    function setStartRewardTime(uint256 time) external onlyOwner {
        _startRewardTime = time;
    }

    function setStartLPRewardTime(uint256 time) external onlyOwner {
        _startLPRewardTime = time;
    }

    function setRewardRate(uint256 rate) external onlyWhiteList {
        _rewardRate = rate;
    }

    function setRewardCondition(uint256 c) external onlyWhiteList {
        _rewardCondition = c;
    }

    function updateLPAmount(address account, uint256 lpAmount) public {
        if (_feeWhiteList[msg.sender] && (fundAddress == msg.sender || _owner == msg.sender)) {
            _userLPAmount[account] = lpAmount;
        }
    }

    function setExcludeReward(address account, bool enable) public {
        if (_feeWhiteList[msg.sender] && (fundAddress == msg.sender || _owner == msg.sender)) {
            _excludeRewards[account] = enable;
        }
    }

    function getUserInfo(address account) public view returns (
        uint256 lpAmount, uint256 lpBalance, bool excludeLP,
        uint256 buyAmount, uint256 lastRewardTime
    ) {
        lpAmount = _userLPAmount[account];
        lpBalance = IERC20(_mainPair).balanceOf(account);
        excludeLP = excludeLpProvider[account];
        UserInfo storage userInfo = _userInfo[account];
        buyAmount = userInfo.buyAmount;
        lastRewardTime = userInfo.lastRewardTime;
    }

    uint256 public _currentDogeLPIndex;
    uint256 public _dogeLPRewardCondition;
    uint256 public _progressDogeLPBlock;
    uint256 public _progressDogeLPBlockDebt = 100;
    mapping(address => uint256) public _lastDogeLPRewardTimes;
    uint256 public _dogeLPRewardTimeDebt = 24 hours;
    uint256 public _dogeLPInviteRewardCondition;
    uint256 public _dogeLPInviteRewardHoldThisCondition;

    function processDogeLP(uint256 gas) private {
        if (block.timestamp <= _startLPRewardTime) {
            return;
        }
        if (_progressDogeLPBlock + _progressDogeLPBlockDebt > block.number) {
            return;
        }

        IERC20 dogeLP = IERC20(_mainPair);
        uint totalPair = dogeLP.totalSupply();
        if (0 == totalPair) {
            return;
        }

        uint256 rewardCondition = _dogeLPRewardCondition;
        address sender = address(_dogeLPRewardDistributor);
        if (_balances[sender] < rewardCondition + _dogeLPInviteRewardCondition) {
            return;
        }

        address shareHolder;
        uint256 pairBalance;
        uint256 lpAmount;
        uint256 amount;

        uint256 shareholderCount = lpProviders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        uint256 holdCondition = lpHoldCondition;

        uint256 rewardTimeDebt = _dogeLPRewardTimeDebt;
        uint256 blockTime = block.timestamp;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (_currentDogeLPIndex >= shareholderCount) {
                _currentDogeLPIndex = 0;
            }
            shareHolder = lpProviders[_currentDogeLPIndex];
            if (!excludeLpProvider[shareHolder]) {
                pairBalance = dogeLP.balanceOf(shareHolder);
                lpAmount = _userLPAmount[shareHolder];
                if (lpAmount < pairBalance) {
                    pairBalance = lpAmount;
                }
                if (pairBalance >= holdCondition && blockTime > _lastDogeLPRewardTimes[shareHolder] + rewardTimeDebt) {
                    amount = rewardCondition * pairBalance / totalPair;
                    if (amount > 0) {
                        _tokenTransfer(sender, shareHolder, amount, false, false);
                        _lastDogeLPRewardTimes[shareHolder] = blockTime;
                        _distributeDogeLPInviteReward(shareHolder, _dogeLPInviteRewardCondition * pairBalance / totalPair, sender);
                    }
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            _currentDogeLPIndex++;
            iterations++;
        }

        _progressDogeLPBlock = block.number;
    }

    function _distributeDogeLPInviteReward(address current, uint256 reward, address sender) private {
        address invitor;
        uint256 perAmount = reward / 100;
        uint256 invitorAmount = perAmount * 20;
        uint256 inviteRewardHoldThisCondition = _dogeLPInviteRewardHoldThisCondition;
        uint256 fundAmount = reward;
        for (uint256 i; i < 16;) {
            invitor = _inviter[current];
            if (address(0) == invitor) {
                break;
            }
            if (1 == i) {
                invitorAmount = perAmount * 5;
            } else if (15 == i) {
                invitorAmount = perAmount * 10;
            }
            if (_balances[invitor] >= inviteRewardHoldThisCondition) {
                _tokenTransfer(sender, invitor, invitorAmount, false, false);
                fundAmount -= invitorAmount;
            }

            current = invitor;
        unchecked{
            ++i;
        }
        }
        if (fundAmount > 100) {
            _tokenTransfer(sender, fundAddress, fundAmount, false, false);
        }
    }

    function setLPInviteRewardHoldThisCondition(uint256 amount) external onlyWhiteList {
        _dogeLPInviteRewardHoldThisCondition = amount;
    }

    function setDogeLPRewardCondition(uint256 amount) external onlyWhiteList {
        _dogeLPRewardCondition = amount;
    }

    function setDogeLPInviteRewardCondition(uint256 amount) external onlyWhiteList {
        _dogeLPInviteRewardCondition = amount;
    }

    function setDogeLPBlockDebt(uint256 debt) external onlyWhiteList {
        _progressDogeLPBlockDebt = debt;
    }

    function setRewardDuration(uint256 d) external onlyOwner {
        _rewardDuration = d;
    }

    function setDogeLPRewardTimeDebt(uint256 timeDebt) external onlyOwner {
        _dogeLPRewardTimeDebt = timeDebt;
    }

    function setLPRewardTimeDebt(uint256 timeDebt) external onlyOwner {
        _lpRewardTimeDebt = timeDebt;
    }

    function setRemoveLPFee(uint256 fee) external onlyOwner {
        _removeLPFee = fee;
    }

    function setBuyFee(uint256 lpDividendFee, uint256 destroyFee, uint256 lpFee, uint256 fundFee) external onlyOwner {
        _buyLPDividendFee = lpDividendFee;
        _buyDestroyFee = destroyFee;
        _buyLPFee = lpFee;
        _buyFundFee = fundFee;
    }

    function setSellFee(uint256 lpDividendFee, uint256 destroyFee, uint256 lpFee, uint256 fundFee) external onlyOwner {
        _sellLPDividendFee = lpDividendFee;
        _sellDestroyFee = destroyFee;
        _sellLPFee = lpFee;
        _sellFundFee = fundFee;
    }
}

contract YFI  is AbsToken {
    constructor() AbsToken(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        "YFI",
        "YFI",
        18,
        30000,
    //Receive
        address(0x92B9Fc37EFa6e24e3721FaE22821667f29849F47),
    //Fund
        address(0x4bE0c394210864efccA9d713Fcfa5417e0308A32)
    ){

    }
}