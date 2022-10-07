/**
 *Submitted for verification at BscScan.com on 2022-10-07
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;
pragma abicoder v2; 

/**
 * Abstract contract to easily change things when deploying new projects. Saves me having to find it everywhere.
 */
abstract contract Project {
    address public marketingWallet = 0xf4185a53F3af23B95B9b9D479FD56f7648985d51;
    address public treasuryWallet = 0xf4185a53F3af23B95B9b9D479FD56f7648985d51;

    string constant _name = "CUPID";
    string constant _symbol = "DICK PUD";
    uint8 constant _decimals = 9;

    uint256 _totalSupply = 1 * 10**9 * 10**_decimals;

    uint256 public _maxTxAmount = (_totalSupply * 1) / 100; // (_totalSupply * 10) / 1000 [this equals 1%]
    uint256 public _maxWalletToken = _maxTxAmount;// * 20; //

    uint256 public buyBurnFee         = 0;
    uint256 public buyFee             = 1;
    uint256 public buyTotalFee        = buyFee + buyBurnFee;

    uint256 public swapLpFee          = 1;
    uint256 public swapRewardFee      = 0;
    uint256 public swapMarketing      = 0;
    uint256 public swapTreasuryFee    = 0;
    uint256 public swapBurnFee        = 0;
    uint256 public swapTotalFee       = swapBurnFee + swapMarketing + swapRewardFee + swapLpFee + swapTreasuryFee;

    uint256 public feeDenominator     = 100;

}

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {

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

/**
 * BEP20 standard interface.
 */
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function process(uint256 gas) external;
    function claimDividend(address holder) external;
}

contract DividendDistributor is IDividendDistributor  {
    using SafeMath for uint256;

    address _token;

    struct RewardInfo {
        uint256 totalHolders;
        uint256 totalDistributed;
    }

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
        bool hasCustom;
        address currentRWRD;
    }
    // 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56 :> BUSD
    IBEP20 public defaultRwrd = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

    address wbnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    IDEXRouter router;

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;

    mapping(address => bool) public blackListRewardTokens;

    mapping (address => Share) public shares;
    mapping (address => RewardInfo) public rewardsInfo;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;

    uint256 public minPeriod = 45 * 60;
    uint256 public minDistribution = 1 * (10 ** 13);

    uint256 currentIndex;

    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == _token); _;
    }

    constructor (address _router) {
        router = _router != address(0)
            ? IDEXRouter(_router)
            : IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        _token = msg.sender;
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function setShare (address shareholder, uint256 amount) external override onlyToken {
        if(shares[shareholder].amount > 0){
            distributeDividend(shareholder);
        }

        if(amount > 0 && shares[shareholder].amount == 0){
            addShareholder(shareholder);
        }else if(amount == 0 && shares[shareholder].amount > 0){
            removeShareholder(shareholder);
        }

        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    /**
     * Store the BNB and not a converted amount
     */
    function deposit() external payable override onlyToken {
        uint256 amount = msg.value;

        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }    

    function shouldDistribute(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp
                && getUnpaidEarnings(shareholder) > minDistribution;
    }

    function distributeDividend(address shareholder) internal  {
        if(shares[shareholder].amount == 0){ return; }

        uint256 amount = getUnpaidEarnings(shareholder);
        
        if(amount > 0){
            totalDistributed = totalDistributed.add(amount);
            Share memory shareInfo = shares[shareholder];

            address shareholderRwrd = shareInfo.hasCustom ? shareInfo.currentRWRD : address(defaultRwrd);

            // If the shareholder has a custom RWRD we will have to do a 
            // transfer through a purchase using the core BUSD
            address[] memory path = new address[](2);
            path[0] = wbnb; 
            path[1] = shareholderRwrd; // shareholderRwrd

            router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
                0,
                path,
                address(shareholder),
                block.timestamp
            );

            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
            rewardsInfo[shareholderRwrd].totalDistributed = rewardsInfo[shareholderRwrd].totalDistributed.add(amount);
        }
    }

    function process(uint256 gas) external override onlyToken {
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0) { return; }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }

            if(shouldDistribute(shareholders[currentIndex])){
                distributeDividend(shareholders[currentIndex]);
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function claimDividend(address holder) external override {
        distributeDividend(holder);
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].amount == 0){ return 0; }

        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }

        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
        
        shares[shareholder].currentRWRD = address(defaultRwrd);
        rewardsInfo[address(defaultRwrd)].totalHolders = rewardsInfo[address(defaultRwrd)].totalHolders.add(1);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();

        if(rewardsInfo[shares[shareholder].currentRWRD].totalHolders > 0) {
            rewardsInfo[shares[shareholder].currentRWRD].totalHolders = rewardsInfo[shares[shareholder].currentRWRD].totalHolders.sub(1);
        }
    }

    function addBlacklistRwrdToken(address tokenAddress, bool isBlacklisted) external onlyToken {
        blackListRewardTokens[tokenAddress] = isBlacklisted;
    }

    function isBlacklistedRwrdToken(address tokenAddress) public view returns (bool){
        return blackListRewardTokens[tokenAddress];
    }

    function setDefaultRewardToken(address RWRDToken) external onlyToken {
        if(!isBlacklistedRwrdToken(RWRDToken)) {
            defaultRwrd = IBEP20(RWRDToken);
        }
    }

    function setNewRewardForShareholder(address shareholder, address customRwrd) external onlyToken {
        if(shares[shareholder].currentRWRD != customRwrd) {

            if(rewardsInfo[shares[shareholder].currentRWRD].totalHolders > 0) {
                rewardsInfo[shares[shareholder].currentRWRD].totalHolders = rewardsInfo[shares[shareholder].currentRWRD].totalHolders.sub(1);
            }

            shares[shareholder].currentRWRD = customRwrd;
            shares[shareholder].hasCustom = true;

            rewardsInfo[customRwrd].totalHolders = rewardsInfo[customRwrd].totalHolders.add(1);
        }
    }

    function setShareholderToDefault(address shareholder) external onlyToken {
        if(shares[shareholder].currentRWRD != address(defaultRwrd)) {

            if(rewardsInfo[shares[shareholder].currentRWRD].totalHolders > 0) {
                rewardsInfo[shares[shareholder].currentRWRD].totalHolders = rewardsInfo[shares[shareholder].currentRWRD].totalHolders.sub(1);
            }

            shares[shareholder].currentRWRD = address(defaultRwrd);
            shares[shareholder].hasCustom = false;

            rewardsInfo[address(defaultRwrd)].totalHolders = rewardsInfo[address(defaultRwrd)].totalHolders.add(1);

        }
    }

    function pullRemainingDividends(uint256 amountPercentage) external onlyToken {
        uint256 amountBNB = address(this).balance;
        payable(msg.sender).transfer(amountBNB * amountPercentage / 100);
    }

    function getTotalDistributed() external onlyToken view returns (uint256) {
        return totalDistributed;
    }

    function getTotalDividends() external onlyToken view returns (uint256) {
        return totalDividends;
    }

    function getRewardInfo(address _reward) public view returns (
        uint256 totalHolders,
        uint256 totalSent
    ) {
        if(rewardsInfo[_reward].totalHolders > 0) {
            totalHolders = rewardsInfo[_reward].totalHolders;
        } else {
            totalHolders = 0;
        }

        if(rewardsInfo[_reward].totalDistributed > 0) {
            totalSent = rewardsInfo[_reward].totalDistributed;
        } else {
            totalSent = 0;
        }
    }

    function getShareholderInfo(address _account) public view returns(
        address account,
        uint256 pendingReward,
        uint256 totalRealised,
        uint256 lastClaimTime,
        uint256 nextClaimTime,
        uint256 secondsUntilAutoClaimAvailable,
        uint256 _totalDistributed,
        address currentRWRD){
        account = _account;
        
        pendingReward = getUnpaidEarnings(account);
        totalRealised = shares[_account].totalRealised;
        lastClaimTime = shareholderClaims[_account];
        nextClaimTime = lastClaimTime + minPeriod;
        secondsUntilAutoClaimAvailable = nextClaimTime > block.timestamp ?
                                                    nextClaimTime.sub(block.timestamp) :
                                                    0;
        _totalDistributed = totalDistributed;

        if(shares[account].hasCustom) {
            currentRWRD = shares[_account].currentRWRD;
        } else {
            currentRWRD = address(defaultRwrd);
        }
    }
    
}

/**
 * MainContract
 */
contract dickpud is Project, IBEP20, Auth {
    using SafeMath for uint256;

    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    bool public blacklistMode = true;
    bool public customRewardsAllowed = false;
    uint256 public thresholdForCustomRewards = _maxTxAmount;

    mapping (address => bool) public isBlacklisted;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isTimelockExempt;
    mapping (address => bool) isDividendExempt;
    mapping (address => bool) isBurnExempt;

    address public autoLiquidityReceiver;
    address public burnTo;

    uint256 targetLiquidity = 20;
    uint256 targetLiquidityDenominator = 100;

    IDEXRouter public router;
    address public pair;

    bool public tradingOpen = false;

    DividendDistributor public distributor;
    uint256 distributorGas = 6000000;

    bool public buyCooldownEnabled = true;
    uint8 public cooldownTimerInterval = 10;
    mapping (address => uint) private cooldownTimer;

    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply * 30 / 10000;
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor () Auth(msg.sender) {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;

        distributor = new DividendDistributor(address(router));

        isFeeExempt[msg.sender] = true;
        isTxLimitExempt[msg.sender] = true;

        isTimelockExempt[msg.sender] = true;
        isTimelockExempt[DEAD] = true;
        isTimelockExempt[address(this)] = true;

        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;

        isBurnExempt[pair] = true;
        isBurnExempt[address(this)] = true;
        isBurnExempt[DEAD] = true;
        isBurnExempt[marketingWallet] = true;

        autoLiquidityReceiver = msg.sender;
        burnTo = 0x3955Ee10C442648E314Ba589D9569ce214169943;

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function setMaxWalletPercent_base1000(uint256 maxWallPercent_base1000) external onlyOwner() {
        _maxWalletToken = (_totalSupply * maxWallPercent_base1000 ) / 1000;
    }
    function setMaxTxPercent_base1000(uint256 maxTXPercentage_base1000) external onlyOwner() {
        _maxTxAmount = (_totalSupply * maxTXPercentage_base1000 ) / 1000;
    }

    function setBuyTax(uint256 buyTax) external onlyOwner() {
        buyTotalFee = buyTax;
    }

    function setTxLimit(uint256 amount) external authorized {
        _maxTxAmount = amount;
    }

    function setBurnTo(address newBurnTo) external onlyOwner() {
        burnTo = newBurnTo;
    }

    function setBuyBurnFee(uint256 newBuyBurnFee) external onlyOwner() {
        buyBurnFee = newBuyBurnFee;
    }

    function setSwapBurnFee(uint256 newSwapBurnFee) external onlyOwner() {
        swapBurnFee = newSwapBurnFee;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if(!authorizations[sender] && !authorizations[recipient]){
            require(tradingOpen,"Trading not open yet");
        }

        // Blacklist
        if(blacklistMode){
            require(!isBlacklisted[sender] && !isBlacklisted[recipient],"Blacklisted");
        }

        if (!authorizations[sender] && recipient != address(this)  && recipient != address(DEAD) && recipient != pair && recipient != marketingWallet && recipient != treasuryWallet  && recipient != autoLiquidityReceiver){
            uint256 heldTokens = balanceOf(recipient);
            require((heldTokens + amount) <= _maxWalletToken,"Total Holding is currently limited, you can not buy that much.");}

        if (sender == pair &&
            buyCooldownEnabled &&
            !isTimelockExempt[recipient]) {
            require(cooldownTimer[recipient] < block.timestamp,"Please wait for 1min between two buys");
            cooldownTimer[recipient] = block.timestamp + cooldownTimerInterval;
        }

        // Checks max transaction limit
        checkTxLimit(sender, amount);

        if(shouldSwapBack()){ swapBack(); }

        //Exchange tokens
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        bool inSell = (recipient == pair);

        uint256 amountReceived = shouldTakeFee(sender) ? takeFee(sender, amount, inSell) : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);

        // // If the seller has sold enough to be below the threshold for custom rewards
        // // revert them back to the default reward
        // if(inSell && customRewardsAllowed && balanceOf(sender) < thresholdForCustomRewards) {
        //     distributor.setShareholderToDefault(sender);
        // }
        // Left for a future iteration

        // Dividend tracker
        if(!isDividendExempt[sender]) {
            try distributor.setShare(sender, _balances[sender]) {} catch {}
        }

        if(!isDividendExempt[recipient]) {
            try distributor.setShare(recipient, _balances[recipient]) {} catch {}
        }

        try distributor.process(distributorGas) {} catch {}

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function checkTxLimit(address sender, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function takeFee(address sender, uint256 amount, bool isSell) internal returns (uint256) {

        uint256 feeToTake = isSell ? swapTotalFee.sub(swapBurnFee) : buyTotalFee.sub(buyBurnFee);
        uint256 burnToTake = isSell ? swapBurnFee : buyBurnFee;
        uint256 feeAmount = amount.mul(feeToTake).mul(100).div(feeDenominator * 100);
        uint256 burnAmount = burnToTake > 0 ? amount.mul(burnToTake).mul(100).div(feeDenominator * 100) : 0;

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        if(burnAmount > 0) {
            if(_balances[address(this)] > burnAmount) {
                _basicTransfer(address(this), burnTo, burnAmount);
            }
        }

        return amount.sub(feeAmount).sub(burnAmount);
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }

    function clearStuckBalance(uint256 amountPercentage) external authorized {
        uint256 amountBNB = address(this).balance;
        payable(marketingWallet).transfer(amountBNB * amountPercentage / 100);
    }

    function clearStuckBalance_sender(uint256 amountPercentage) external authorized {
        uint256 amountBNB = address(this).balance;
        payable(msg.sender).transfer(amountBNB * amountPercentage / 100);
    }

    // switch Trading
    function tradingStatus(bool _status) public onlyOwner {
        tradingOpen = _status;
    }

    // enable cooldown between trades
    function cooldownEnabled(bool _status, uint8 _interval) public onlyOwner {
        buyCooldownEnabled = _status;
        cooldownTimerInterval = _interval;
    }

    function swapBack() internal swapping {
        uint256 dynamicLiquidityFee = isOverLiquified(targetLiquidity, targetLiquidityDenominator) ? 0 : swapLpFee;
        uint256 amountToLiquify = swapThreshold.mul(dynamicLiquidityFee).div(swapTotalFee.sub(swapBurnFee)).div(2);
        uint256 amountToSwap = swapThreshold.sub(amountToLiquify);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;

        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountBNB = address(this).balance.sub(balanceBefore);

        uint256 totalBNBFee = swapTotalFee.sub(dynamicLiquidityFee.div(2));

        uint256 amountBNBLiquidity = amountBNB.mul(swapLpFee).div(totalBNBFee).div(2);
        uint256 amountBNBReflection = amountBNB.mul(swapRewardFee).div(totalBNBFee);
        uint256 amountBNBMarketing = amountBNB.mul(swapMarketing).div(totalBNBFee);
        uint256 amountBNBTreasury = amountBNB.mul(swapTreasuryFee).div(totalBNBFee);

        try distributor.deposit{value: amountBNBReflection}() {} catch {}
        (bool tmpSuccess,) = payable(marketingWallet).call{value: amountBNBMarketing, gas: 30000}("");
        (tmpSuccess,) = payable(treasuryWallet).call{value: amountBNBTreasury, gas: 30000}("");

        // Supress warning msg
        tmpSuccess = false;

        if(amountToLiquify > 0){
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    function setIsDividendExempt(address holder, bool exempt) external authorized {
        require(holder != address(this) && holder != pair);
        isDividendExempt[holder] = exempt;
        if(exempt){
            distributor.setShare(holder, 0);
        }else{
            distributor.setShare(holder, _balances[holder]);
        }
    }

    function manage_burn_exempt(address[] calldata addresses, bool status) public onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
            isBurnExempt[addresses[i]] = status;
        }
    }

    function enable_blacklist(bool _status) public onlyOwner {
        blacklistMode = _status;
    }

    function manage_blacklist(address[] calldata addresses, bool status) public onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
            isBlacklisted[addresses[i]] = status;
        }
    }

    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    function setIsTxLimitExempt(address holder, bool exempt) external authorized {
        isTxLimitExempt[holder] = exempt;
    }

    function setIsTimelockExempt(address holder, bool exempt) external authorized {
        isTimelockExempt[holder] = exempt;
    }

    function setSwapFees(uint256 _newSwapLpFee, uint256 _newSwapRewardFee, uint256 _newSwapMarketingFee, uint256 _newSwapTreasuryFee, uint256 _feeDenominator) external authorized {
        swapLpFee = _newSwapLpFee;
        swapRewardFee = _newSwapRewardFee;
        swapMarketing = _newSwapMarketingFee;
        swapTreasuryFee = _newSwapTreasuryFee;
        swapTotalFee = _newSwapLpFee.add(_newSwapRewardFee).add(_newSwapMarketingFee).add(_newSwapTreasuryFee);
        feeDenominator = _feeDenominator;
        require(swapTotalFee < feeDenominator/3, "Fees cannot be more than 33%");
    }

    function setTreasuryFeeReceiver(address _newWallet) external authorized {
        isFeeExempt[treasuryWallet] = false;
        isFeeExempt[_newWallet] = true;
        treasuryWallet = _newWallet;
    }

    function setMarketingWallet(address _newWallet) external authorized {
        isFeeExempt[marketingWallet] = false;
        isFeeExempt[_newWallet] = true;
        isDividendExempt[_newWallet] = true;

        marketingWallet = _newWallet;
    }

    function setFeeReceivers(address _autoLiquidityReceiver, address _newMarketingWallet, address _newTreasuryWallet ) external authorized {

        isFeeExempt[treasuryWallet] = false;
        isFeeExempt[_newTreasuryWallet] = true;
        isFeeExempt[marketingWallet] = false;
        isFeeExempt[_newMarketingWallet] = true;

        autoLiquidityReceiver = _autoLiquidityReceiver;
        marketingWallet = _newMarketingWallet;
        treasuryWallet = _newTreasuryWallet;
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) external authorized {
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }

    function setTargetLiquidity(uint256 _target, uint256 _denominator) external authorized {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external authorized {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
    }

    function setDistributorSettings(uint256 gas) external authorized {
        require(gas < 750000);
        distributorGas = gas;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        return accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply());
    }

    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }

    /* Airdrop */
    function multiTransfer(address from, address[] calldata addresses, uint256[] calldata tokens) external onlyOwner {

        require(addresses.length < 501,"GAS Error: max airdrop limit is 500 addresses");
        require(addresses.length == tokens.length,"Mismatch between Address and token count");

        uint256 SCCC = 0;

        for(uint i=0; i < addresses.length; i++){
            SCCC = SCCC + tokens[i];
        }

        require(balanceOf(from) >= SCCC, "Not enough tokens in wallet");

        for(uint i=0; i < addresses.length; i++){
            _basicTransfer(from,addresses[i],tokens[i]);
            if(!isDividendExempt[addresses[i]]) {
                try distributor.setShare(addresses[i], _balances[addresses[i]]) {} catch {}
            }
        }

        // Dividend tracker
        if(!isDividendExempt[from]) {
            try distributor.setShare(from, _balances[from]) {} catch {}
        }
    }

    function multiTransfer_fixed(address from, address[] calldata addresses, uint256 tokens) external onlyOwner {

        require(addresses.length < 801,"GAS Error: max airdrop limit is 800 addresses");

        uint256 SCCC = tokens * addresses.length;

        require(balanceOf(from) >= SCCC, "Not enough tokens in wallet");

        for(uint i=0; i < addresses.length; i++){
            _basicTransfer(from,addresses[i],tokens);
            if(!isDividendExempt[addresses[i]]) {
                try distributor.setShare(addresses[i], _balances[addresses[i]]) {} catch {}
            }
        }

        // Dividend tracker
        if(!isDividendExempt[from]) {
            try distributor.setShare(from, _balances[from]) {} catch {}
        }
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);


    ////////////////////////////////////////////////
    // Various Dividend Tracker functions especially
    // Comment out if you dont need this functionality
    // Allow a user to set their dividend, but also return
    // information about their claims

    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function setRewardTokenForShareholder(address RWRD) external {
        require(customRewardsAllowed, "Contract: setRewardTokenForShareholder:: Custom Rewards arent allowed");
        
        // Check to ensure we have enough and also that we can 
        uint256 existingBalance = balanceOf(msg.sender);
        require(existingBalance > thresholdForCustomRewards, "You do not have enough tokens to change your RWRD");

        require(isContract(RWRD), "Contract: setRewardTokenForShareholder:: Address is a wallet, not a contract.");
  	    require(RWRD != address(this), "Contract: setRewardTokenForShareholder:: Cannot set reward token as this token due to Router limitations.");
  	    require(!distributor.isBlacklistedRwrdToken(RWRD), "Contract: setRewardTokenForShareholder:: Reward Token is blacklisted from being used as rewards.");

        distributor.setNewRewardForShareholder(msg.sender, RWRD);
    }

    function setRwrdToken(address RWRD) external onlyOwner {
        distributor.setDefaultRewardToken(RWRD);
    }

    ////
    // Allow the owner to blacklist a given reward token that will mean investors, or the owner will
    // not be able to set the reward to be anything
    function blacklistRewardToken(address RWRD) external onlyOwner {
        distributor.addBlacklistRwrdToken(RWRD, true);
    }

    function claimDividend() external {
        return distributor.claimDividend(msg.sender);
    } 

    function pullRemainingDividend() external onlyOwner {
        require(tradingOpen == false, "Cant pull when trading is still enabled");
        distributor.pullRemainingDividends(100);
    }

    function enableCustomRewards(bool value) external onlyOwner {
        customRewardsAllowed = value;
    }

    function setThresholdForCustomRewards(uint256 numberTokens) external onlyOwner {
        thresholdForCustomRewards = numberTokens;
    }

    function getThresholdForCustomRewards() public view returns (uint256) {
        return thresholdForCustomRewards;
    }

    function getTotalDistributedDividends() public view returns (uint256) {
        return distributor.getTotalDistributed();
    }

    function getTotalDividendsGenerated() public view returns (uint256) {
        return distributor.getTotalDividends();
    }

    function getUnpaidDividendsForShareholder() public view returns (uint256) {
        return distributor.getUnpaidEarnings(msg.sender);
    }

    function ownerSetShareholderCustomReward(address shareholder, address RWRD) external onlyOwner {
        distributor.setNewRewardForShareholder(shareholder, RWRD);
    }

    function getShareholderDividendsInfo(address holder) external view returns (
            address,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            address) {
        return distributor.getShareholderInfo(holder);
    } 

    function getRewardInfo(address reward) external view returns (
        uint256, uint256
    ) {
        return distributor.getRewardInfo(reward);
    }
}