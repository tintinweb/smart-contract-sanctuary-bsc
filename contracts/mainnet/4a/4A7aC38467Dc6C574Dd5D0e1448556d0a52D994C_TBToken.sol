/**
 *Submitted for verification at BscScan.com on 2023-02-03
*/

/**
 *Submitted for verification at BscScan.com on 2023-01-20
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

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

contract TokenDistributor {
    constructor (address token) {
        IERC20(token).approve(msg.sender, ~uint256(0));
    }
}

contract RewardDistributor is Ownable {
    address public tokenAddress;
    constructor (address token) {
        tokenAddress = token;
    }

    function claimReward(address receiveAddress, uint256 amount) external onlyOwner {
        IERC20(tokenAddress).transfer(receiveAddress, amount);
    }
}

abstract contract AbsToken is IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;

    uint256 private _tTotal = 2490000 * 10 ** 18;

    ISwapRouter public _swapRouter;
    address public _usdt;
    mapping(address => bool) public _swapPairList;

    address public mappingTokenAddress;
    address public deadAddress = address(0x000000000000000000000000000000000000dEaD);

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;
    RewardDistributor public _tokenBDistributor;

    uint256 public _buyLPDividendFee = 300;
    uint256 public _buyInviteFee = 300;

    uint256 public _sellLPDividendFee = 300;
    uint256 public _sellFundFee = 300;

    uint256 public _transFee = 600;

    // uint256 public extraSupply;
    uint256 public SPY = 38580246913; //6% per month
    uint256 public buyLimitPerTimes = 3000 * 10 ** 18;
    mapping (address => bool) public buyLimitPerTimesExcluded;
    mapping (address => bool) public isExcludeTrade;

    struct MAPPINGDATA {
        uint256 totalMapping;
        uint256 paidMapping;
        uint256 lastUpdateTime;
    }
    mapping (address => MAPPINGDATA) userMapping;
    mapping(address => bool) public rewardBlacklist;

    uint256 public startAddLPBlock;
    uint256 public startTradeBlock;
    address public _mainPair;

    uint256 public _limitAmount;

    uint256 public _invitorCondition;
    mapping(address => bool) public excludeInvitor;

    event TokenMapping(address account, uint256 amount);

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    modifier calculateReward(address account) {
        if (account != address(0)) {
            MAPPINGDATA storage accountMapping = userMapping[account];
            uint256 reward = getReward(account);
            if (reward > 0) {
                _tokenTransfer(address(_tokenBDistributor), account, reward, false);
                accountMapping.paidMapping = accountMapping.paidMapping.add(reward);
            }
            accountMapping.lastUpdateTime = block.timestamp;
        }
        _;
    }

    constructor (
        address RouterAddress, address USDTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address FundAddress, address ReceiveAddress, address MappingAddress,
        uint256 LimitAmount
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
        address usdtPair = swapFactory.createPair(address(this), USDTAddress);
        _swapPairList[usdtPair] = true;
        _mainPair = usdtPair;

        uint256 tokenUnit = 10 ** Decimals;
        uint256 total = Supply * tokenUnit;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        fundAddress = FundAddress;
        mappingTokenAddress = MappingAddress;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;

        uint256 usdtUnit = 10 ** IERC20(USDTAddress).decimals();
        _limitAmount = LimitAmount * tokenUnit;
        _invitorCondition = 4000 * tokenUnit;

        _tokenDistributor = new TokenDistributor(USDTAddress);
        _tokenBDistributor = new RewardDistributor(address(this));
        _feeWhiteList[address(_tokenBDistributor)] = true;
        _balances[address(_tokenBDistributor)] = _tTotal.sub(total);
        emit Transfer(address(0), address(_tokenBDistributor), _tTotal.sub(total));

        buyLimitPerTimesExcluded[_mainPair] = true;
        buyLimitPerTimesExcluded[ReceiveAddress] = true;

        excludeLPHolder[address(0)] = true;
        excludeLPHolder[address(0x000000000000000000000000000000000000dEaD)] = true;
        lpRewardCondition = 100 * usdtUnit;
        lpCondition = 1000;
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
        MAPPINGDATA storage accountMapping = userMapping[account];
        uint256 mappingToAmount = accountMapping.totalMapping.sub(accountMapping.paidMapping);
        return _balances[account].add(mappingToAmount);
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

    function tokenMapping(uint256 _amount) public calculateReward(msg.sender) {
        require(_amount > 0, "Mapping amount must be more than 0");
        MAPPINGDATA storage accountMapping = userMapping[msg.sender];
        uint256 mappingAmount = _amount.div(2);
        accountMapping.totalMapping = accountMapping.totalMapping.add(mappingAmount);
        IERC20(mappingTokenAddress).transferFrom(msg.sender, deadAddress, _amount);
        emit TokenMapping(msg.sender, _amount);
    }

    function getReward(address account) public view returns (uint256) {
        MAPPINGDATA storage accountMapping = userMapping[account];
        if (
            accountMapping.lastUpdateTime == 0 
        || rewardBlacklist[account] 
        || accountMapping.totalMapping <= 0
        || accountMapping.paidMapping >= accountMapping.totalMapping
        ) {
            return 0;
        }
        uint256 reward = accountMapping.totalMapping.mul(SPY).mul(
                block.timestamp.sub(accountMapping.lastUpdateTime)
            ).div(10 ** 18);
        if(accountMapping.paidMapping.add(reward) > accountMapping.totalMapping) {
            reward = accountMapping.totalMapping.sub(accountMapping.paidMapping);
        }    
        return reward;
    }

    function getMappingInfo(address account) public view returns(MAPPINGDATA memory) {
        return userMapping[account];
    }

    address private _lastMaybeLPAddress;

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private calculateReward(from) calculateReward(to) {
        address lastMaybeLPAddress = _lastMaybeLPAddress;
        if (lastMaybeLPAddress != address(0) && _mainPair != address(0)) {
            _lastMaybeLPAddress = address(0);
            if (IERC20(_mainPair).balanceOf(lastMaybeLPAddress) > 0) {
                _addLpProvider(lastMaybeLPAddress);
            }
        }
        require(!isExcludeTrade[from] && !isExcludeTrade[to], "trading prohibition");
        uint256 balance = _balances[from]; // balanceOf(from);
        require(balance >= amount, "BNE");
        if(
            (_swapPairList[from] || _swapPairList[to])  && 
            (!buyLimitPerTimesExcluded[from] || !buyLimitPerTimesExcluded[to])
        ) {
            require(amount <= buyLimitPerTimes, "buy limit");
        }

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount;
            uint256 remainAmount = 10 ** (_decimals - 3);
            if (balance > remainAmount) {
                maxSellAmount = balance - remainAmount;
            }
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        bool takeFee;
        if (_swapPairList[from] || _swapPairList[to]) {
            if (startAddLPBlock == 0 && _mainPair == to && _feeWhiteList[from] && IERC20(to).totalSupply() == 0) {
                startAddLPBlock = block.number;
            }

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                takeFee = true;

                bool isAddLP;
                if (_swapPairList[to]) {
                    isAddLP = _isAddLiquidity();
                    if (isAddLP) {
                        takeFee = false;
                    }
                } else {
                    bool isRemoveLP = _isRemoveLiquidity();
                    if (isRemoveLP) {
                        takeFee = false;
                    }
                }

                if (0 == startTradeBlock) {
                    require(0 < startAddLPBlock && isAddLP, "!T");
                }
            }
        } else {
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                takeFee = true;
            }
            if (0 == _balances[to] && amount > 0 && to != address(0) && from != address(_tokenBDistributor)) {
                _bindInvitor(to, from);
            }
        }

        _tokenTransfer(from, to, amount, takeFee);

        uint256 limitAmount = _limitAmount;
        if (0 == startTradeBlock && limitAmount > 0 && !_swapPairList[to] && !_feeWhiteList[to]) {
            require(limitAmount >= _balances[to], "L");
        }

        if (from != address(this)) {
            if (_swapPairList[to]) {
                _lastMaybeLPAddress = from;
            }

            processLPReward(_rewardGas);
        }
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

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {
            uint256 swapFeeAmount;
            bool isSell;
            if (_swapPairList[sender]) {//Buy
                swapFeeAmount = tAmount * _buyLPDividendFee / 10000;
                uint256 inviteFeeAmount = tAmount * _buyInviteFee / 10000;
                if (inviteFeeAmount > 0) {
                    feeAmount += inviteFeeAmount;
                    address invitor = _inviter[recipient];
                    if (address(0) == invitor || excludeInvitor[invitor] || _balances[invitor] < _invitorCondition) {
                        invitor = address(0x000000000000000000000000000000000000dEaD);
                    }
                    _takeTransfer(sender, invitor, inviteFeeAmount);
                }
            } else if (_swapPairList[recipient]) {//Sell
                isSell = true;
                swapFeeAmount = tAmount * (_sellFundFee + _sellLPDividendFee) / 10000;
            } else {
                feeAmount = tAmount * _transFee / 10000;
                 _takeTransfer(sender, address(0x000000000000000000000000000000000000dEaD), feeAmount);
            }
            if (swapFeeAmount > 0) {
                feeAmount += swapFeeAmount;
                _takeTransfer(sender, address(this), swapFeeAmount);
            }
            if (isSell && !inSwap) {
                uint256 numToSell = swapFeeAmount * 2;
                uint256 contractTokenBalance = _balances[address(this)]; // balanceOf(address(this));
                if (numToSell > contractTokenBalance) {
                    numToSell = contractTokenBalance;
                }
                swapTokenForFund(numToSell);
            }
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        if (0 == tokenAmount) {
            return;
        }

        address[] memory path = new address[](2);
        path[0] = address(this);
        address usdt = _usdt;
        path[1] = usdt;
        address tokenDistributor = address(_tokenDistributor);

        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            tokenDistributor,
            block.timestamp
        );

        IERC20 USDT = IERC20(usdt);
        uint256 usdtBalance = USDT.balanceOf(tokenDistributor);
        USDT.transferFrom(tokenDistributor, address(this), usdtBalance);

        uint256 fundFee = _sellFundFee;
        uint256 lpDividendFee = _buyLPDividendFee + _sellLPDividendFee;
        uint256 totalFee = fundFee + lpDividendFee;

        uint256 fundUsdt = usdtBalance * fundFee / totalFee;
        if (fundUsdt > 0) {
            USDT.transfer(fundAddress, fundUsdt);
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

    function setBuyFee(
        uint256 lpDividendFee, uint256 inviteFee
    ) external onlyOwner {
        _buyLPDividendFee = lpDividendFee;
        _buyInviteFee = inviteFee;
    }

    function setSellFee(
        uint256 lpDividendFee, uint256 fundFee
    ) external onlyOwner {
        _sellLPDividendFee = lpDividendFee;
        _sellFundFee = fundFee;
    }

    function setTransFee(uint256 transFee) external onlyOwner {
        _transFee = transFee;
    }

    function setApy(uint256 _spy) external onlyOwner {
        SPY = _spy;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "T");
        startTradeBlock = block.number;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function batchSetFeeWhiteList(address [] memory addr, bool enable) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            _feeWhiteList[addr[i]] = enable;
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

    function claimReward(uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            _tokenBDistributor.claimReward(msg.sender, amount);
        }
    }

    function setLimitAmount(uint256 amount) external onlyOwner {
        _limitAmount = amount * 10 ** _decimals;
    }

    function setInvitorCondition(uint256 amount) external onlyOwner {
        _invitorCondition = amount * 10 ** _decimals;
    }

    receive() external payable {}

    address[] public lpProviders;
    mapping(address => uint256) public lpProviderIndex;

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

    uint256 public _rewardGas = 500000;

    mapping(address => bool)  public excludeLPHolder;
    uint256 public currentLPIndex;
    uint256 public lpRewardCondition;
    uint256 public lpCondition;
    uint256 public progressLPRewardBlock;
    uint256 public progressLPBlockDebt = 0;

    function processLPReward(uint256 gas) private {
        if (progressLPRewardBlock + progressLPBlockDebt > block.number) {
            return;
        }

        IERC20 USDT = IERC20(_usdt);
        uint256 rewardCondition = lpRewardCondition;
        if (USDT.balanceOf(address(this)) < rewardCondition) {
            return;
        }
        IERC20 holdToken = IERC20(_mainPair);
        uint holdTokenTotal = holdToken.totalSupply();
        if (0 == holdTokenTotal) {
            return;
        }

        address shareHolder;
        uint256 tokenBalance;
        uint256 amount;

        uint256 shareholderCount = lpProviders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        uint256 holdCondition = lpCondition;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentLPIndex >= shareholderCount) {
                currentLPIndex = 0;
            }
            shareHolder = lpProviders[currentLPIndex];
            tokenBalance = holdToken.balanceOf(shareHolder);
            if (tokenBalance >= holdCondition && !excludeLPHolder[shareHolder]) {
                amount = rewardCondition * tokenBalance / holdTokenTotal;
                if (amount > 0) {
                    USDT.transfer(shareHolder, amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentLPIndex++;
            iterations++;
        }
        progressLPRewardBlock = block.number;
    }

    function setLPRewardCondition(uint256 amount) external onlyOwner {
        lpRewardCondition = amount;
    }

    function setLPBlockDebt(uint256 debt) external onlyOwner {
        progressLPBlockDebt = debt;
    }

    function setLPCondition(uint256 amount) external onlyOwner {
        lpCondition = amount;
    }

    function setExcludeLPHolder(address addr, bool enable) external onlyOwner {
        excludeLPHolder[addr] = enable;
    }

    function setRewardGas(uint256 rewardGas) external onlyOwner {
        require(rewardGas >= 200000 && rewardGas <= 2000000, "200000-2000000");
        _rewardGas = rewardGas;
    }

    function setExcludeInvitor(address addr, bool enable) external onlyOwner {
        excludeInvitor[addr] = enable;
    }

    function setBuyLimitPerTimesExcluded(address addr, bool enable) external onlyOwner {
        buyLimitPerTimesExcluded[addr] = enable;
    }

    function setBuyLimitPerTimes(uint256 _buyLimitPerTimes) external onlyOwner {
        buyLimitPerTimes = _buyLimitPerTimes;
    }

    function setIsExcludeTrade(address addr, bool enable) external onlyOwner {
        isExcludeTrade[addr] = enable;
    }
}

contract TBToken is AbsToken {
    constructor() AbsToken(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    //USDT
        address(0x55d398326f99059fF775485246999027B3197955),
        "FSBjzy",
        "FSBJZY",
        18,
        650000,
    //Fund
        address(0xaC4fbBE82454e05Ad5Ae26cF838f8EbF223ec57b),
     //Received   
        address(0x219ceB0107101df6dA325c9F81379B16c8058ce3),
    //mappingToken
        address(0xD215571f2DeA811D5B62Cf1B6f55652422362377),
    //LimitAmount
        0
    ){

    }
}