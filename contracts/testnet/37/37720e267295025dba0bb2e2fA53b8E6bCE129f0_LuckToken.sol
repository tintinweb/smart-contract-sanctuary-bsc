/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.17;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IUniswapV2Factory {
  event PairCreated(address indexed token0, address indexed token1, address pair, uint);

  function getPair(address tokenA, address tokenB) external view returns (address pair);
  function allPairs(uint) external view returns (address pair);
  function allPairsLength() external view returns (uint);

  function feeTo() external view returns (address);
  function feeToSetter() external view returns (address);

  function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router01 {
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
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

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

interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function process(uint256 gas) external;
    function claimDividend(address holder) external;
}

contract DividendDistributor is IDividendDistributor {

    using SafeMath for uint256;
    address _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    IUniswapV2Router02 router;
    address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address BUSDaddress = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
    IBEP20 RewardToken = IBEP20(BUSDaddress); 

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;
    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;

    uint256 public minPeriod = 1 minutes;
    uint256 public minDistribution = 1 * (10 ** 16);

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
        router = _router != address(0) ? IUniswapV2Router02(_router) : IUniswapV2Router02(routerAddress);
        _token = msg.sender;
    }

    function setDistributionCriteria(uint256 newMinPeriod, uint256 newMinDistribution) external override onlyToken {
        minPeriod = newMinPeriod;
        minDistribution = newMinDistribution;
    }

    function setShare(address shareholder, uint256 amount) external override onlyToken {

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

    function deposit() external payable override onlyToken {

        uint256 balanceBefore = RewardToken.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(RewardToken);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amount = RewardToken.balanceOf(address(this)).sub(balanceBefore);
        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }

    function process(uint256 gas) external override onlyToken {
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0) { return; }

        uint256 iterations = 0;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        while(gasUsed < gas && iterations < shareholderCount) {

            if(currentIndex >= shareholderCount){ currentIndex = 0; }

            if(shouldDistribute(shareholders[currentIndex])){
                distributeDividend(shareholders[currentIndex]);
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }
    
    function shouldDistribute(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp
                && getUnpaidEarnings(shareholder) > minDistribution;
    }

    function distributeDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }

        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){
            totalDistributed = totalDistributed.add(amount);
            RewardToken.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }

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
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
    
    function claimDividend(address holder) external override {
        distributeDividend(holder);
    }
}

abstract contract Auth {
    using SafeMath for uint256;

    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

abstract contract AllTheFees is IBEP20, Auth {
    using SafeMath for uint256;

    //BUY feeTokens
    uint256 public BuyFeeLP = 1;            // LP fee 1-2%
    uint256 public BuyFeeMarketing = 1;     // Marketing fee 1-2%
    uint256 public BuyFeeBB = 1;            // Buyback and server operation cost 1-2%
    uint256 public BuyFeeWinnersReward = 1; // Winner's reward 1-4%
    uint256 public BuyFeeJackpotReward = 1; // Jackpot reward FIX 1%
    uint256 public BuyFeeLuckyShares = 2;   // Lucky Shares FIX 2%
    uint256 public BuyFeeBurn = 1;          // Burn fee FIX 1%
    uint256 public BuyFeeHouse = 1;         // Fee of the house FIX 1%
    uint256 public BuyFeeTotal = BuyFeeMarketing.add(BuyFeeLP).add(BuyFeeBB).add(BuyFeeWinnersReward).add(BuyFeeJackpotReward).add(BuyFeeLuckyShares).add(BuyFeeBurn).add(BuyFeeHouse);
    //Total 9-15%

    function changeBuyFees(
        uint256 newBuyFeeLP, 
        uint256 newBuyFeeMarketing, 
        uint256 newBuyFeeBB, 
        uint256 newBuyFeeWinnersReward,
        uint256 newBuyFeeJackpotReward, 
        uint256 newBuyFeeLuckyShares, 
        uint256 newBuyFeeBurn,
        uint256 newBuyFeeHouse
        ) external authorized {
        BuyFeeLP = newBuyFeeLP;
        BuyFeeMarketing = newBuyFeeMarketing;
        BuyFeeBB = newBuyFeeBB;
        BuyFeeWinnersReward = newBuyFeeWinnersReward;
		BuyFeeJackpotReward = newBuyFeeJackpotReward;
        BuyFeeLuckyShares = newBuyFeeLuckyShares;
        BuyFeeBurn = newBuyFeeBurn;
        BuyFeeHouse = newBuyFeeHouse;
        
        BuyFeeTotal = BuyFeeLP.add(BuyFeeMarketing).add(BuyFeeBB).add(BuyFeeWinnersReward).add(BuyFeeJackpotReward).add(BuyFeeLuckyShares).add(BuyFeeBurn).add(BuyFeeHouse);
		require(BuyFeeTotal <= 15);
    }
    
    //Sell feeTokens
    uint256 public SellFeeLP = 2;            // LP fee 2-4%
    uint256 public SellFeeMarketing = 2;     // Marketing fee 2-4%
    uint256 public SellFeeBB = 2;            // Buyback and server operation cost 2-4%
    uint256 public SellFeeWinnersReward = 2; // Winner's reward 2-6%
    uint256 public SellFeeJackpotReward = 2; // Jackpot reward FIX 2%
    uint256 public SellFeeLuckyShares = 2;   // Lucky Shares FIX 2%
    uint256 public SellFeeBurn = 1;          // Burn fee FIX 1%
    uint256 public SellFeeHouse = 1;         // Fee of the house FIX 1%
    uint256 public SellFeeTotal = SellFeeMarketing.add(SellFeeLP).add(SellFeeBB).add(SellFeeWinnersReward).add(SellFeeJackpotReward).add(SellFeeLuckyShares).add(SellFeeBurn).add(SellFeeHouse);
    //Total 14-24%

    function changeSellFees(
        uint256 newSellFeeLP, 
        uint256 newSellFeeMarketing, 
        uint256 newSellFeeBB, 
        uint256 newSellFeeWinnersReward,
        uint256 newSellFeeJackpotReward, 
        uint256 newSellFeeLuckyShares, 
        uint256 newSellFeeBurn,
        uint256 newSellFeeHouse
        ) external authorized {
        SellFeeLP = newSellFeeLP;
        SellFeeMarketing = newSellFeeMarketing;
        SellFeeBB = newSellFeeBB;
        SellFeeWinnersReward = newSellFeeWinnersReward;
		SellFeeJackpotReward = newSellFeeJackpotReward;
        SellFeeLuckyShares = newSellFeeLuckyShares;
        SellFeeBurn = newSellFeeBurn;
        SellFeeHouse = newSellFeeHouse;
        
        SellFeeTotal = SellFeeLP.add(SellFeeMarketing).add(SellFeeBB).add(SellFeeWinnersReward).add(SellFeeJackpotReward).add(SellFeeLuckyShares).add(SellFeeBurn).add(SellFeeHouse);
		require(SellFeeTotal <= 25);
    }

    uint256 public unpayedJackpotOnContract;
	uint256 public alreadyPayedJackpot;
    mapping(address => uint256) public payedJackpotToSpecificAddress;

	uint256 public unpayedWinnersRewardOnContract;
	uint256 public alreadyPayedWinnersReward;
    mapping(address => uint256) public payedWinnersRewardToSpecificAddress;

    constructor(){
		unpayedJackpotOnContract = 0;
		alreadyPayedJackpot = 0;
		unpayedWinnersRewardOnContract = 0;
		alreadyPayedWinnersReward = 0;
    }
}

contract LuckToken is AllTheFees {
    using SafeMath for uint256;

    string constant _name = "TestLuckToken";
    string constant _symbol = "TESTLUCK";
    uint8 constant _decimals = 18;
    uint256 _totalSupply = 1000000000 * (10 ** _decimals);

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    uint256 public _maxWallet = _totalSupply / 100; //Max wallet 10m
    function changeMaxWallet(uint256 newValue) external authorized{
        _maxWallet = newValue * (10 ** _decimals);
    }
    uint256 public _maxTransaction  = _totalSupply / 100; //Max tx 10m
    function changeMaxTransaction(uint256 newValue) external authorized{
        _maxTransaction = newValue * (10 ** _decimals);
    }
    uint256 public _minimumTokensToSwap = _totalSupply / 500; //2m tokens to swap
    function changeMinimumTokensToSwap(uint256 newValue) external authorized{
        _minimumTokensToSwap = newValue * (10 ** _decimals);
    }

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    //Wallets for fees
    address marketingwallet = 0x2A1387e1F05F36A365D3f8986dE3ec879E049547; //Wallet of marketing fee
    address buybackwallet = 0x3016828035a1829B49de36a1F515d35Fe16c2E0b; //Wallet of burn and buyback fee
    address housewallet = 0xD8f98C478c6E891687C72816bf5907fEC19b2ea6; //Wallet of development fee
    address autoLiquidityReciever = 0xAc6bD92774d16462423e88318001903C79DfF4d7; //Should be the first wallet, that put in LP (owner)
    address DEAD = 0x000000000000000000000000000000000000dEaD;

    //Basic contract variables (router, pair, routeraddress, rewardToken)
    address routerAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    IUniswapV2Router02 public router = IUniswapV2Router02(routerAddress);
    address public pair = IUniswapV2Factory(router.factory()).createPair(router.WETH(), address(this));
    mapping (address => bool) public isMarketPair;
    
    address WBNBaddress = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    address BUSDaddress = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
    IBEP20 RewardTokenBUSD = IBEP20(BUSDaddress);
    

    //Exemptions
    mapping(address => bool) public exemptFromMaxWallet;
    function changeExemptFromMaxWallet(address holder, bool newValue) external authorized{
        exemptFromMaxWallet[holder] = newValue;
    }
    mapping(address => bool) public exemptFromMaxTransaction;
    function changeExemptFromMaxTransaction(address holder, bool newValue) external authorized{
        exemptFromMaxTransaction[holder] = newValue;
    }
    mapping(address => bool) public exemptFromFee;
    function changeExemptFromFee(address holder, bool newValue) external authorized{
        exemptFromFee[holder] = newValue;
    }
    mapping(address => bool) public exemptFromDividends;
    function changeExemptFromDividends(address holder, bool newValue) external authorized{
        exemptFromDividends[holder] = newValue;
    }


    //Dividends
    DividendDistributor public dividendDistributor;
    uint256 distributorGas = 300000;

    constructor() Auth(msg.sender){
        _balances[msg.sender] = _totalSupply; // Transfers all tokens to owner
        emit Transfer(address(0), msg.sender, _totalSupply);
        _allowances[address(this)][address(router)] = type(uint256).max;
        //_allowances[WBNBaddress][address(router)] = type(uint256).max;
        //_allowances[BUSDaddress][address(router)] = type(uint256).max;

        dividendDistributor = new DividendDistributor(address(router));

        exemptFromMaxWallet[msg.sender] = true;

        exemptFromMaxTransaction[msg.sender] = true;

        exemptFromFee[msg.sender] = true;
        exemptFromFee[address(this)] = true;

        exemptFromDividends[pair] = true;
        exemptFromDividends[msg.sender] = true;
        exemptFromDividends[address(this)] = true;
        exemptFromDividends[DEAD] = true;
        
        exemptFromMaxWallet[address(pair)] = true;
        isMarketPair[address(pair)] = true;
    }

    event Received(address, uint);
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    function totalSupply() external view returns (uint256){return _totalSupply;}
    function decimals() external pure returns (uint8){return _decimals;}
    function symbol() external pure returns (string memory){return _symbol;}
    function name() external pure returns (string memory){return _name;}
    function getOwner() external view returns (address){return owner;}
    function balanceOf(address account) public view returns (uint256){return _balances[account];}
    function allowance(address _holder, address spender) external view returns (uint256){return _allowances[_holder][spender];}
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function transfer(address recipient, uint256 amount) external returns (bool){
        /*if(msg.sender == pair){
            return _transferFrom(msg.sender, recipient, amount);
		}
        require(recipient != address(0), "Receiver address invalid");
        require(amount >= 0, "Value must be greater or equal to 0");
        require(_balances[msg.sender] > amount, "Not enough balance");
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(msg.sender, recipient, amount);
        return true;*/
		return _transferFrom(msg.sender, recipient, amount);
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool){
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwapAndLiquify)
        { 
            return _basicTransfer(sender, recipient, amount); 
        }
        else
        {
            //Swap tokens on contract

            if(balanceOf(address(this)) >= _minimumTokensToSwap && !inSwapAndLiquify && !isMarketPair[sender] && swapAndLiquifyEnabled){swapAndLiquify();}


            _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
            uint256 finalAmount = (exemptFromFee[sender] || exemptFromFee[recipient]) ? amount : takeFee(sender, recipient, amount);
            _balances[recipient] = _balances[recipient].add(finalAmount);
            emit Transfer(sender, recipient, finalAmount);


            // Dividend tracker
            if(!exemptFromDividends[sender]) {
                try dividendDistributor.setShare(sender, _balances[sender]) {} catch {}
            }

            if(!exemptFromDividends[recipient]) {
                try dividendDistributor.setShare(recipient, _balances[recipient]) {} catch {} 
            }

            try dividendDistributor.process(distributorGas) {} catch {}

            return true;
        }
    }

    function takeFee(address sender, address receiver, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = 0;
        
        //If its a buy
        if(isMarketPair[sender]) {
            feeAmount = amount.mul(BuyFeeTotal).div(100);
        }
        //If its a sell
        else if(isMarketPair[receiver]) {
            feeAmount = amount.mul(SellFeeTotal).div(100);
        }
        
        if(feeAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(feeAmount);
            emit Transfer(sender, address(this), feeAmount);
        }

        return amount.sub(feeAmount);
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    struct SwapTokens{
        uint256 startingBalance;
        uint256 lpAmount;
        uint256 marketingAmount;
        uint256 bbAmount;
        uint256 winnersRewardAmount;
        uint256 jackpotAmount;
        uint256 luckySharesAmount;
        uint256 burnAmount;
        uint256 houseAmount;
        uint256 tokensToSwapToEth;
    }

    struct SwapBNB{
        uint256 startingBalance;
        uint256 balanceAfterSwapToBNB;
        uint256 newlyGainedBNB;
        uint256 lpBNB;
        uint256 marketingBNB;
        uint256 bbBNB;
        uint256 houseBNB;
        uint256 luckyBNB;
        uint256 winnerBNB;
        uint256 jackpotBNB;
    }

    struct SwapBUSD{
        uint256 busdBalanceBeforeSwap;
        uint256 bnbToSwap;
        uint256 busdBalanceAfterSwap;
        uint256 newlyGainedBUSD;
        uint256 luckyBUSD;
        uint256 winnerBUSD;
        uint256 jackpotBUSD;
    }

    function swapAndLiquify() internal lockTheSwap{
        SwapTokens memory swapTokens;
        SwapBNB memory swapBNB;
        SwapBUSD memory swapBUSD;

        swapTokens.startingBalance = balanceOf(address(this));
        swapTokens.lpAmount = (swapTokens.startingBalance.mul(BuyFeeLP.add(SellFeeLP)).div(BuyFeeTotal.add(SellFeeTotal))).div(2);

        swapTokens.marketingAmount = swapTokens.startingBalance.mul(BuyFeeMarketing.add(SellFeeMarketing)).div(BuyFeeTotal.add(SellFeeTotal));
        swapTokens.bbAmount = swapTokens.startingBalance.mul(BuyFeeBB.add(SellFeeBB)).div(BuyFeeTotal.add(SellFeeTotal));
        swapTokens.winnersRewardAmount = swapTokens.startingBalance.mul(BuyFeeWinnersReward.add(SellFeeWinnersReward)).div(BuyFeeTotal.add(SellFeeTotal));
        swapTokens.jackpotAmount = swapTokens.startingBalance.mul(BuyFeeJackpotReward.add(SellFeeJackpotReward)).div(BuyFeeTotal.add(SellFeeTotal));
        swapTokens.luckySharesAmount = swapTokens.startingBalance.mul(BuyFeeLuckyShares.add(SellFeeLuckyShares)).div(BuyFeeTotal.add(SellFeeTotal));
        swapTokens.burnAmount = swapTokens.startingBalance.mul(BuyFeeBurn.add(SellFeeBurn)).div(BuyFeeTotal.add(SellFeeTotal));
        swapTokens.houseAmount = swapTokens.startingBalance.mul(BuyFeeHouse.add(SellFeeHouse)).div(BuyFeeTotal.add(SellFeeTotal));

        swapTokens.tokensToSwapToEth = swapTokens.startingBalance.sub(swapTokens.burnAmount).sub(swapTokens.lpAmount);

        //Átutalás dead walletre
        _balances[address(DEAD)] = _balances[address(DEAD)].add(swapTokens.burnAmount);
        emit Transfer(address(this), address(DEAD), swapTokens.burnAmount);
        _balances[address(this)] = _balances[address(this)].sub(swapTokens.burnAmount);

        swapBNB.startingBalance = address(this).balance;
        //Swapping to BNB
        swapTokensForEth(swapTokens.tokensToSwapToEth);

	    swapBNB.balanceAfterSwapToBNB = address(this).balance;
        swapBNB.newlyGainedBNB = swapBNB.balanceAfterSwapToBNB.sub(swapBNB.startingBalance);
        swapBNB.lpBNB = swapTokens.lpAmount.mul(swapBNB.newlyGainedBNB).div(swapTokens.tokensToSwapToEth);

        //Adding liquidity
        addLiquidity(swapTokens.lpAmount, swapBNB.lpBNB);

        swapBNB.marketingBNB = swapTokens.marketingAmount.mul(swapBNB.newlyGainedBNB).div(swapTokens.tokensToSwapToEth);
        swapBNB.bbBNB = swapTokens.bbAmount.mul(swapBNB.newlyGainedBNB).div(swapTokens.tokensToSwapToEth);
        swapBNB.houseBNB = swapTokens.houseAmount.mul(swapBNB.newlyGainedBNB).div(swapTokens.tokensToSwapToEth);

        swapBNB.luckyBNB = swapTokens.luckySharesAmount.mul(swapBNB.newlyGainedBNB).div(swapTokens.tokensToSwapToEth);
        swapBNB.winnerBNB = swapTokens.winnersRewardAmount.mul(swapBNB.newlyGainedBNB).div(swapTokens.tokensToSwapToEth);
        swapBNB.jackpotBNB = swapTokens.jackpotAmount.mul(swapBNB.newlyGainedBNB).div(swapTokens.tokensToSwapToEth);


        (bool tmpSuccess,) = payable(marketingwallet).call{value: swapBNB.marketingBNB, gas: 50000}("");
		(bool tmpSuccess1,) = payable(buybackwallet).call{value: swapBNB.bbBNB, gas: 50000}("");
		(bool tmpSuccess2,) = payable(housewallet).call{value: swapBNB.houseBNB, gas: 50000}("");
		// only to supress warning msg
        tmpSuccess = false;
        tmpSuccess1 = false;
		tmpSuccess2 = false;

	    swapBUSD.busdBalanceBeforeSwap = RewardTokenBUSD.balanceOf(address(this));
        //Swapping to BUSD
        swapBUSD.bnbToSwap = swapBNB.winnerBNB.add(swapBNB.jackpotBNB).add(swapBNB.luckyBNB);
        swapEthForBUSD(swapBUSD.bnbToSwap);

        swapBUSD.busdBalanceAfterSwap = RewardTokenBUSD.balanceOf(address(this));
        swapBUSD.newlyGainedBUSD = swapBUSD.busdBalanceAfterSwap.sub(swapBUSD.busdBalanceBeforeSwap);

        swapBUSD.luckyBUSD = swapBNB.luckyBNB.mul(swapBUSD.newlyGainedBUSD).div(swapBNB.luckyBNB.add(swapBNB.winnerBNB).add(swapBNB.jackpotBNB)); //Ezt majd dividend depositolni kell
        try dividendDistributor.deposit{value: swapBUSD.luckyBUSD}() {} catch {}
        swapBUSD.winnerBUSD = swapBNB.winnerBNB.mul(swapBUSD.newlyGainedBUSD).div(swapBNB.luckyBNB.add(swapBNB.winnerBNB).add(swapBNB.jackpotBNB));
        swapBUSD.jackpotBUSD = swapBNB.jackpotBNB.mul(swapBUSD.newlyGainedBUSD).div(swapBNB.luckyBNB.add(swapBNB.winnerBNB).add(swapBNB.jackpotBNB));

        unpayedWinnersRewardOnContract = unpayedWinnersRewardOnContract.add(swapBUSD.winnerBUSD);
		unpayedJackpotOnContract = unpayedJackpotOnContract.add(swapBUSD.jackpotBUSD);
    }

    function swapTokensForEth(uint256 tokenAmount) internal {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNBaddress;

        // make the swap
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this), // The contract
            block.timestamp
        );
        
        emit SwapTokensForETH(tokenAmount, path);
    }
    event SwapTokensForETH(
        uint256 amountIn,
        address[] path
    );

    function swapEthForBUSD(uint256 EthAmount) internal {
        // generate the uniswap pair path of weth -> busd
        address[] memory path = new address[](2);
        path[0] = WBNBaddress;
        path[1] = BUSDaddress;

        //router.WETH().approve(address(router), EthAmount);

        // make the swap
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: EthAmount}(
            0, // accept any amount of ETH
            path,
            address(this), // The contract
            block.timestamp
        );

        emit SwapETHForBusd(EthAmount, path);
    }
    event SwapETHForBusd(
        uint256 amountIn,
        address[] path
    );

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) internal {

        if(tokenAmount > 0){
            router.addLiquidityETH{value: ethAmount}(
                address(this),
                tokenAmount,
                0, // slippage is unavoidable
                0, // slippage is unavoidable
                autoLiquidityReciever,
                block.timestamp
            );
        emit LiquidityAdded(ethAmount, tokenAmount);
        }
    }
    event LiquidityAdded(
        uint256 ethAmount,
        uint256 tokenAmount
    );


}