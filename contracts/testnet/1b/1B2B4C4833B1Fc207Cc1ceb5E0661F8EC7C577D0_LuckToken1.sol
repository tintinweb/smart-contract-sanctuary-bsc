/**
 *Submitted for verification at BscScan.com on 2022-09-04
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

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

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IPancakeRouter {
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

//This interface is for authorized wallet only, to set feeTokens and limits!!! It is automated in Python!
interface AboutFeesAndLimits {

    //OPTIONALS

    //Change if a wallet is exempt from max wallet. With NFT, max wallet can be increased.
    function changeIfWalletIsMaxWalletLimitExempt(address holder, bool exempt) external;
    //Change if a wallet has max wallet fix. With NFT, max wallet can be fixed.
    function changeIfWalletIsMaxWalletLimitFixed(address holder, bool exempt) external;

    //Check if wallet has Winner's increase.
    function checkIfWinnersIncreaseIsActive(address holder, bool exempt) external;
    //Check if wallet has Loser's decrease.
    function checkIfLosersDecreaseIsActive(address holder, bool exempt) external;
    //Check if wallet has Lucky Shares increase.
    function checkIfLuckySharesIncreaseIsActive(address holder, bool exempt) external;
}

//This interface is also automated by Python, at given times the dice is rolled, and the chanche to win is open!!
interface RollTheDices {

    /*
        Every 1-3 hours 5-15% of all 0.001%+ holders are chosen to be winners,
        and 5-15% of all 0.001%+ holders are chosen to be losers (10-30% of all holders altogether).
        Winners will receive the losers’ tokens (only 5-10% of it).
        If a winner is already holding more than the actual max wallet, he is simply removed from the winner team and a new winner is selected.
        If a loser has less than 0.1%, this wallet is also removed from the loser team (other losers will NOT lose more).
        Winners also get the “winners’ reward” fee in BUSD (10% - 70%) of it. (30% will always remain on the contract, so the reward will increase overtime).
        If the roll is successfull, it should return True.
    */
    function ChooseTheWinnersAndLoosers() external returns (bool);

    /*
        The dice is rolled, and if it hits 6, jackpot will be payed out. (random number between and including 1-6). If its 1-5, reward will keep increasing, if its 6, jackpot will be sent out to the winners.
        1 to 10 wallets will receive the full amount, shared equally between them.
        If the roll is successfull, it should return True.
    */
    function RollTheJackpot() external returns (bool);

    /*
        Lucky shares are for holders that holds above the half of the actual maximum wallet amount. (If the actual maximum wallet is 1% ~ 10.000.000 tokens, then every wallet holding more than 5.000.000 tokens are eligible to this share). It is sent out every 24 hours, exactly when the jackpot is rolled.
        Lucky share limit can be divided by 2 on bscscan, so if we hit much higher market cap, we can decrease the necessary holding amount for lucky shares. (For 0.001%+ holders only)
        If the roll is successfull, it should return True.
    */
    function ChooseEligibleWalletsForLuckyShares() external returns (bool);
    //Set new limit for the eligible wallets for the lucky shares. It is given as percent of the half of the actual max wallet.
    function ChangeLuckySharesLimit() external returns (bool);

    /*
        Newcomer’s fee is for small wallets. If you come late, or can’t afford to buy big, do not be afraid. Just hold your token, and you’ll be eligible for this share. Wallets above 0.001% hold are eligible, up to the Lucky shares limit.
        Basically if you hold long term, you will change your tier from Newcomer to Lucky shares.
        If the number of Lucky share eligible wallets are less than Newcomer share eligible wallets, the half of the Newcomer share will go to the Lucky share eligible wallets!!! (If there are a lot of small wallets, it won’t pay them more than the Lucky share)
    */
    function ChooseEligibleWalletsForNewcomerShares() external returns (bool);

}

//Safemath for uint256
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

//Authentication
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

//Contains everything about the feeTokens
abstract contract AllTheFees is Auth {
    using SafeMath for uint256;
    mapping (address => bool) public isFeeExempt;
	mapping (address => bool) public isTxLimitExempt;
	mapping (address => bool) public isWalletLimitExempt;
	mapping (address => bool) public LSisDividendExempt;
	mapping (address => bool) public NSisDividendExempt;

    function changeIsFeeExempt(address holder, bool exempt) external authorized{
        isFeeExempt[holder] = exempt;
    }
	function changeisWalletLimitExempt(address holder, bool exempt) external authorized {
        isWalletLimitExempt[holder] = exempt;
    }
	function changeIsTxLimitExempt(address holder, bool exempt) external authorized {
        isTxLimitExempt[holder] = exempt;
    }

    //BUY feeTokens
    uint256 BuyFeeLP = 1;            // LP fee 1-2%
    function ActualFeeOfBuyLP() external view returns (uint256) { return BuyFeeLP; }

    uint256 BuyFeeMarketing = 1;     // Marketing fee 1-2%
    function ActualFeeOfBuyFeeMarketing() external view returns (uint256) { return BuyFeeMarketing; }

    uint256 BuyFeeBB = 1;            // Buyback and burn 1-2%
    function ActualFeeOfBuyFeeBB() external view returns (uint256) { return BuyFeeBB; }

    uint256 BuyFeeWinnersReward = 1; // Winner's reward 1-4%
    function ActualFeeOfBuyFeeWinnersReward() external view returns (uint256) { return BuyFeeWinnersReward; }

    uint256 BuyFeeJackpotReward = 1; // Jackpot reward FIX 1%
    function ActualFeeOfBuyFeeJackpotReward() external view returns (uint256) { return BuyFeeJackpotReward; }

    uint256 BuyFeeLuckyShares = 2;   // Lucky Shares FIX 2%
    function ActualFeeOfBuyFeeLuckyShares() external view returns (uint256) { return BuyFeeLuckyShares; }

    uint256 BuyFeeNewcomerShares = 1;      // NewComer FIX 1%
    function ActualFeeOfBuyFeeNewcomerShares() external view returns (uint256) { return BuyFeeNewcomerShares; }

    uint256 BuyFeeHouse = 1;         // Fee of the house FIX 1%
    function ActualFeeOfBuyFeeHouse() external view returns (uint256) { return BuyFeeHouse; }

    uint256 totalBuyFee = BuyFeeMarketing.add(BuyFeeLP).add(BuyFeeBB).add(BuyFeeWinnersReward).add(BuyFeeJackpotReward).add(BuyFeeLuckyShares).add(BuyFeeNewcomerShares).add(BuyFeeHouse);
    function ActualFeeOfBuy() external view returns (uint256) { return totalBuyFee; }
	
    //Total 9-15%

    function changeBuyFees(
        uint256 newBuyFeeLP, 
        uint256 newBuyFeeMarketing, 
        uint256 newBuyFeeBB, 
        uint256 newBuyFeeWinnersReward,
        uint256 newBuyFeeJackpotReward, 
        uint256 newBuyFeeLuckyShares, 
        uint256 newBuyFeeNewcomerShares,
        uint256 newBuyFeeHouse
        ) external authorized {
        BuyFeeLP = newBuyFeeLP;
        BuyFeeMarketing = newBuyFeeMarketing;
        BuyFeeBB = newBuyFeeBB;
        BuyFeeWinnersReward = newBuyFeeWinnersReward;
		BuyFeeJackpotReward = newBuyFeeJackpotReward;
        BuyFeeLuckyShares = newBuyFeeLuckyShares;
        BuyFeeNewcomerShares = newBuyFeeNewcomerShares;
        BuyFeeHouse = newBuyFeeHouse;
        
        totalBuyFee = BuyFeeLP.add(BuyFeeMarketing).add(BuyFeeBB).add(BuyFeeWinnersReward).add(BuyFeeJackpotReward).add(BuyFeeLuckyShares).add(BuyFeeNewcomerShares).add(BuyFeeHouse);
		require(totalBuyFee <= 15);
    }



    
    //Sell feeTokens
    uint256 SellFeeLP = 2;            // LP fee 2-4%
    function ActualFeeOfSellFeeLP() external view returns (uint256) { return SellFeeLP; }

    uint256 SellFeeMarketing = 2;     // Marketing fee 2-4%
    function ActualFeeOfSellFeeMarketing() external view returns (uint256) { return SellFeeMarketing; }

    uint256 SellFeeBB = 2;            // Buyback and burn 2-4%
    function ActualFeeOfSellFeeBB() external view returns (uint256) { return SellFeeBB; }

    uint256 SellFeeWinnersReward = 2; // Winner's reward 2-6%
    function ActualFeeOfSellFeeWinnersReward() external view returns (uint256) { return SellFeeWinnersReward; }

    uint256 SellFeeJackpotReward = 2; // Jackpot reward FIX 2%
    function ActualFeeOfSellFeeJackpotReward() external view returns (uint256) { return SellFeeJackpotReward; }

    uint256 SellFeeLuckyShares = 2;   // Lucky Shares FIX 2%
    function ActualFeeOfSellFeeLuckyShares() external view returns (uint256) { return SellFeeLuckyShares; }

    uint256 SellFeeNewcomerShares = 1;      // NewComer FIX 1%
    function ActualFeeOfSellFeeNewcomerShares() external view returns (uint256) { return SellFeeNewcomerShares; }


    uint256 QuittersPenalty = 2;      // Quitters Penalty 2-6% If someone sells more than 90% of their tokens, some extra fee is applied to the sell! (Don't leave us if you wanna become rich)
    function ActualFeeOfQuittersPenalty() external view returns (uint256) { return QuittersPenalty; }

    //This should be implemented in the trade function, it is not added to the TotalSellFee for now!!
    
    uint256 SellFeeHouse = 1;         // Fee of the house FIX 1%
    function ActualFeeOfSellFeeHouse() external view returns (uint256) { return SellFeeHouse; }

    uint256 totalSellFee = SellFeeMarketing.add(SellFeeLP).add(SellFeeBB).add(SellFeeWinnersReward).add(SellFeeJackpotReward).add(SellFeeLuckyShares).add(SellFeeNewcomerShares).add(SellFeeHouse);
	function ActualFeeOfSell() external view returns (uint256) { return totalSellFee; }
    //Total 16-30%

    
    function changeSellFees(
        uint256 newSellFeeLP, 
        uint256 newSellFeeMarketing, 
        uint256 newSellFeeBB, 
        uint256 newSellFeeWinnersReward,
        uint256 newSellFeeJackpotReward, 
        uint256 newSellFeeLuckyShares, 
        uint256 newSellFeeNewcomerShares,
        uint256 newQuittersPenalty,
        uint256 newSellFeeHouse
        ) external authorized {
        SellFeeLP = newSellFeeLP;
        SellFeeMarketing = newSellFeeMarketing;
        SellFeeBB = newSellFeeBB;
        SellFeeWinnersReward = newSellFeeWinnersReward;
		SellFeeJackpotReward = newSellFeeJackpotReward;
        SellFeeLuckyShares = newSellFeeLuckyShares;
        SellFeeNewcomerShares = newSellFeeNewcomerShares;
        QuittersPenalty = newQuittersPenalty;
        SellFeeHouse = newSellFeeHouse;
        
        totalSellFee = SellFeeLP.add(SellFeeMarketing).add(SellFeeBB).add(SellFeeWinnersReward).add(SellFeeJackpotReward).add(SellFeeLuckyShares).add(SellFeeNewcomerShares).add(QuittersPenalty).add(SellFeeHouse);
		require(totalSellFee <= 30);
    }

	uint256 unpayedJackpotOnContract;
	uint256 alreadyPayedJackpot;
	uint256 unpayedWinnersRewardOnContract;
	uint256 alreadyPayedWinnersReward;

    constructor(){
        isFeeExempt[msg.sender] = true;
        isFeeExempt[address(this)] = true;
		unpayedJackpotOnContract = 0;
		alreadyPayedJackpot = 0;
		unpayedWinnersRewardOnContract = 0;
		alreadyPayedWinnersReward = 0;
    }
	
	
}


interface ILuckySharesDistributor {
    function LSsetDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function LSsetShare(address shareholder, uint256 amount) external;
    function LSdeposit() external payable;
    function LSprocess(uint256 gas) external;
    function LSclaimDividend(address holder) external;
}

interface INewcomerSharesDistributor {
    function NSsetDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function NSsetShare(address shareholder, uint256 amount) external;
    function NSdeposit() external payable;
    function NSprocess(uint256 gas) external;
    function NSclaimDividend(address holder) external;
}

struct Share {
    uint256 amount;
    uint256 totalExcluded;
    uint256 totalRealised;
}







contract LuckySharesDistributor is ILuckySharesDistributor{
	using SafeMath for uint256;
    address _token;
	
	IPancakeRouter router;
    address LSrouterAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    IBEP20 LSRewardToken = IBEP20(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee);
	
	address[] LSshareholders;
    mapping (address => uint256) LSshareholderIndexes;
    mapping (address => uint256) LSshareholderClaims;
    mapping (address => Share) public LSshares;
	
	uint256 public LStotalShares;
    uint256 public LStotalDividends;
    uint256 public LStotalDistributed;
    uint256 public LSdividendsPerShare;
    uint256 public LSdividendsPerShareAccuracyFactor = 10 ** 36;

    uint256 public LSminPeriod = 60 minutes;
    uint256 public LSminDistribution = 1 * (10 ** 18);

    uint256 LScurrentIndex;
	
	bool LSinitialized;
    modifier LSinitialization() {
        require(!LSinitialized);
        _;
        LSinitialized = true;
    }
	
	modifier LSonlyToken() {
        require(msg.sender == _token); _;
    }
	
	constructor (address _router) {
        router = _router != address(0) ? IPancakeRouter(_router) : IPancakeRouter(LSrouterAddress);
        _token = msg.sender;
    }

	function LSsetDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external override LSonlyToken {
		LSminPeriod = _minPeriod;
		LSminDistribution = _minDistribution;
	}
	
	function LSdeposit() external payable {
		uint256 amount = msg.value;
        LStotalDividends = LStotalDividends.add(amount);
        LSdividendsPerShare = LSdividendsPerShare.add(LSdividendsPerShareAccuracyFactor.mul(amount).div(LStotalShares));
	}

    function LSsetShare(address shareholder, uint256 amount) external override LSonlyToken {
	
		if(LSshares[shareholder].amount > 0){
            LSdistributeDividend(shareholder);
        }

        if(amount > 0 && LSshares[shareholder].amount == 0){
            LSaddShareholder(shareholder);
        }else if(amount == 0 && LSshares[shareholder].amount > 0){
            LSremoveShareholder(shareholder);
        }

        LStotalShares = LStotalShares.sub(LSshares[shareholder].amount).add(amount);
        LSshares[shareholder].amount = amount;
        LSshares[shareholder].totalExcluded = LSgetCumulativeDividends(LSshares[shareholder].amount);
	
	}
    
    function LSprocess(uint256 gas) external override LSonlyToken {
		uint256 LSshareholderCount = LSshareholders.length;

        if(LSshareholderCount == 0) { return; }

        uint256 LSiterations = 0;
        uint256 LSgasUsed = 0;
        uint256 LSgasLeft = gasleft();

        while(LSgasUsed < gas && LSiterations < LSshareholderCount) {

            if(LScurrentIndex >= LSshareholderCount){ LScurrentIndex = 0; }

            if(LSshouldDistribute(LSshareholders[LScurrentIndex])){
                LSdistributeDividend(LSshareholders[LScurrentIndex]);
            }

            LSgasUsed = LSgasUsed.add(LSgasLeft.sub(gasleft()));
            LSgasLeft = gasleft();
            LScurrentIndex++;
            LSiterations++;
        }
	}
	
	
	
	
	
	function LSaddShareholder(address shareholder) internal {
        LSshareholderIndexes[shareholder] = LSshareholders.length;
        LSshareholders.push(shareholder);
    }

    function LSremoveShareholder(address shareholder) internal {
        LSshareholders[LSshareholderIndexes[shareholder]] = LSshareholders[LSshareholders.length-1];
        LSshareholderIndexes[LSshareholders[LSshareholders.length-1]] = LSshareholderIndexes[shareholder];
        LSshareholders.pop();
    }
	
	function LSshouldDistribute(address shareholder) internal view returns (bool) {
        return LSshareholderClaims[shareholder] + LSminPeriod < block.timestamp
                && LSgetUnpaidEarnings(shareholder) > LSminDistribution;
    }
	
	function LSgetUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(LSshares[shareholder].amount == 0){ return 0; }

        uint256 LSshareholderTotalDividends = LSgetCumulativeDividends(LSshares[shareholder].amount);
        uint256 LSshareholderTotalExcluded = LSshares[shareholder].totalExcluded;

        if(LSshareholderTotalDividends <= LSshareholderTotalExcluded){ return 0; }

        return LSshareholderTotalDividends.sub(LSshareholderTotalExcluded);
    }
	
	function LSgetCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share.mul(LSdividendsPerShare).div(LSdividendsPerShareAccuracyFactor);
    }
	
	function LSdistributeDividend(address shareholder) internal {
		if(LSshares[shareholder].amount == 0){ return; }
		
		uint256 LSamount = LSgetUnpaidEarnings(shareholder);
        if(LSamount > 0){
            LStotalDistributed = LStotalDistributed.add(LSamount);
            LSRewardToken.transfer(shareholder, LSamount);
            LSshareholderClaims[shareholder] = block.timestamp;
            LSshares[shareholder].totalRealised = LSshares[shareholder].totalRealised.add(LSamount);
            LSshares[shareholder].totalExcluded = LSgetCumulativeDividends(LSshares[shareholder].amount);
        }
	}
	
    function LSclaimDividend(address holder) external override {
		LSdistributeDividend(holder);
	}

}

















contract NewcomerSharesDistributor is INewcomerSharesDistributor{
	using SafeMath for uint256;
    address _token;

	IPancakeRouter router;
    address NSrouterAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    IBEP20 NSRewardToken = IBEP20(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee);

	address[] NSshareholders;
    mapping (address => uint256) NSshareholderIndexes;
    mapping (address => uint256) NSshareholderClaims;
    mapping (address => Share) public NSshares;
	
	uint256 public NStotalShares;
    uint256 public NStotalDividends;
    uint256 public NStotalDistributed;
    uint256 public NSdividendsPerShare;
    uint256 public NSdividendsPerShareAccuracyFactor = 10 ** 36;

    uint256 public NSminPeriod = 60 minutes;
    uint256 public NSminDistribution = 1 * (10 ** 18);

    uint256 NScurrentIndex;

	bool NSinitialized;
    modifier NSinitialization() {
        require(!NSinitialized);
        _;
        NSinitialized = true;
    }

	modifier NSonlyToken() {
        require(msg.sender == _token); _;
    }
	
	constructor (address _router) {
        router = _router != address(0) ? IPancakeRouter(_router) : IPancakeRouter(NSrouterAddress);
        _token = msg.sender;
    }
	
	function NSsetDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external override NSonlyToken {
		NSminPeriod = _minPeriod;
		NSminDistribution = _minDistribution;
	}
	
	function NSdeposit() external payable {
		uint256 amount = msg.value;
        NStotalDividends = NStotalDividends.add(amount);
        NSdividendsPerShare = NSdividendsPerShare.add(NSdividendsPerShareAccuracyFactor.mul(amount).div(NStotalShares));
	}
	
	
	
    function NSsetShare(address shareholder, uint256 amount) external override NSonlyToken {
		if(NSshares[shareholder].amount > 0){
            NSdistributeDividend(shareholder);
        }

        if(amount > 0 && NSshares[shareholder].amount == 0){
            NSaddShareholder(shareholder);
        }else if(amount == 0 && NSshares[shareholder].amount > 0){
            NSremoveShareholder(shareholder);
        }

        NStotalShares = NStotalShares.sub(NSshares[shareholder].amount).add(amount);
        NSshares[shareholder].amount = amount;
        NSshares[shareholder].totalExcluded = NSgetCumulativeDividends(NSshares[shareholder].amount);
	}
    
    function NSprocess(uint256 gas) external override NSonlyToken {
		uint256 NSshareholderCount = NSshareholders.length;

        if(NSshareholderCount == 0) { return; }

        uint256 NSiterations = 0;
        uint256 NSgasUsed = 0;
        uint256 NSgasLeft = gasleft();

        while(NSgasUsed < gas && NSiterations < NSshareholderCount) {

            if(NScurrentIndex >= NSshareholderCount){ NScurrentIndex = 0; }

            if(NSshouldDistribute(NSshareholders[NScurrentIndex])){
                NSdistributeDividend(NSshareholders[NScurrentIndex]);
            }

            NSgasUsed = NSgasUsed.add(NSgasLeft.sub(gasleft()));
            NSgasLeft = gasleft();
            NScurrentIndex++;
            NSiterations++;
        }
	}
	
	
	
	
	
	
	
	function NSaddShareholder(address shareholder) internal {
        NSshareholderIndexes[shareholder] = NSshareholders.length;
        NSshareholders.push(shareholder);
    }

    function NSremoveShareholder(address shareholder) internal {
        NSshareholders[NSshareholderIndexes[shareholder]] = NSshareholders[NSshareholders.length-1];
        NSshareholderIndexes[NSshareholders[NSshareholders.length-1]] = NSshareholderIndexes[shareholder];
        NSshareholders.pop();
    }
	
	function NSshouldDistribute(address shareholder) internal view returns (bool) {
        return NSshareholderClaims[shareholder] + NSminPeriod < block.timestamp
                && NSgetUnpaidEarnings(shareholder) > NSminDistribution;
    }
	
	function NSgetUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(NSshares[shareholder].amount == 0){ return 0; }

        uint256 NSshareholderTotalDividends = NSgetCumulativeDividends(NSshares[shareholder].amount);
        uint256 NSshareholderTotalExcluded = NSshares[shareholder].totalExcluded;

        if(NSshareholderTotalDividends <= NSshareholderTotalExcluded){ return 0; }

        return NSshareholderTotalDividends.sub(NSshareholderTotalExcluded);
    }
	
	function NSgetCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share.mul(NSdividendsPerShare).div(NSdividendsPerShareAccuracyFactor);
    }
	
	function NSdistributeDividend(address shareholder) internal {
		if(NSshares[shareholder].amount == 0){ return; }
		
		uint256 NSamount = NSgetUnpaidEarnings(shareholder);
        if(NSamount > 0){
            NStotalDistributed = NStotalDistributed.add(NSamount);
            NSRewardToken.transfer(shareholder, NSamount);
            NSshareholderClaims[shareholder] = block.timestamp;
            NSshares[shareholder].totalRealised = NSshares[shareholder].totalRealised.add(NSamount);
            NSshares[shareholder].totalExcluded = NSgetCumulativeDividends(NSshares[shareholder].amount);
        }
	}
	
    function NSclaimDividend(address holder) external override{
		NSdistributeDividend(holder);
	}

}



























//Contains the basic stuff about the contract
abstract contract Token is Auth, IBEP20, AllTheFees {
    using SafeMath for uint256;

    IPancakeRouter public router;
    address public pair;
    address routerAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    //address routerAddressForMainnet = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
	IBEP20 RewardTokenBUSD = IBEP20(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee);

    address marketingwallet; //Wallet of marketing fee
    address burnandbuybackwallet; //Wallet of burn and buyback fee
    address housewallet; //Wallet of development fee

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

	address public autoLiquidityReceiver;
	

    function changeFeeReceiverWallets(address Marketing, address BuybackAndBurn, address House) external authorized {
        marketingwallet = Marketing;
        burnandbuybackwallet = BuybackAndBurn;
        housewallet = House;
    }

    function changeTxLimit(uint256 newLimit) external authorized {
        _maxTxAmount = newLimit;
    }

    function changeWalletLimit(uint256 newLimit) external authorized {
        _walletMax  = newLimit;
    }
	

    string constant _name = "LuckToken1";
    string constant _symbol = "LUCK1";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 1000000000 * (10 ** _decimals);
    uint256 public _maxTxAmount = _totalSupply / 2 / 100;
    uint256 public _walletMax = _totalSupply / 2 / 100;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

	bool addLPstatus;
	
	
	bool inSwapAndLiquify;
	bool public swapTokensAndLiquifyEnabled = true;
	
	uint256 public swapThreshold = _totalSupply * 5 / 2000; //If contract has 2,5m+ tokens, swap them
	
	modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
	
	LuckySharesDistributor public LSharesDistributor;
	uint256 LSdistributorGas = 300000;
	NewcomerSharesDistributor public NSharesDistributor;
	uint256 NSdistributorGas = 300000;

    constructor() Auth(msg.sender) {
		addLPstatus = true;
        router = IPancakeRouter(routerAddress);
        pair = IPancakeFactory(router.factory()).createPair(router.WETH(), address(this));
		autoLiquidityReceiver = msg.sender;

        _allowances[address(this)][address(router)] = type(uint256).max;
		
		LSharesDistributor = new LuckySharesDistributor(address(router));
		NSharesDistributor = new NewcomerSharesDistributor(address(router));

        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[pair] = true;
        isTxLimitExempt[DEAD] = true;
		isTxLimitExempt[address(this)] = true;
		
		
		isWalletLimitExempt[msg.sender] = true;
		isWalletLimitExempt[address(this)] = true;
		isWalletLimitExempt[pair] = true;
		isWalletLimitExempt[DEAD] = true;
		
		
		
		LSisDividendExempt[pair] = true;
        LSisDividendExempt[msg.sender] = true;
        LSisDividendExempt[address(this)] = true;
        LSisDividendExempt[DEAD] = true;
        LSisDividendExempt[ZERO] = true;
		
		NSisDividendExempt[pair] = true;
        NSisDividendExempt[msg.sender] = true;
        NSisDividendExempt[address(this)] = true;
        NSisDividendExempt[DEAD] = true;
        NSisDividendExempt[ZERO] = true;

		marketingwallet = 0xAc6bD92774d16462423e88318001903C79DfF4d7;
		burnandbuybackwallet = 0xAc6bD92774d16462423e88318001903C79DfF4d7;
		housewallet = 0xAc6bD92774d16462423e88318001903C79DfF4d7;
		
		isWalletLimitExempt[marketingwallet] = true;
		isWalletLimitExempt[burnandbuybackwallet] = true;
		isWalletLimitExempt[housewallet] = true;
		isTxLimitExempt[marketingwallet] = true;
		isTxLimitExempt[burnandbuybackwallet] = true;
		isTxLimitExempt[housewallet] = true;
		LSisDividendExempt[marketingwallet] = true;
        LSisDividendExempt[burnandbuybackwallet] = true;
        LSisDividendExempt[housewallet] = true;
		NSisDividendExempt[marketingwallet] = true;
        NSisDividendExempt[burnandbuybackwallet] = true;
        NSisDividendExempt[housewallet] = true;

        _balances[owner] = _totalSupply; // Transfers all tokens to owner
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable { }
}





//Contains basic functios from IBEP20, Auth and Token.
contract LuckToken1 is Token {
    using SafeMath for uint256;
	
    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) external view override returns (uint256) { return _balances[account]; }


    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) external override returns (bool) {
        require(amount > 0, "Value must be greater than 0");

        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    

    function transfer(address _to, uint256 _value) external override returns (bool success) {
	
		if(msg.sender == pair){
			return _transferFrom(msg.sender, _to, _value);
		}

        require(_to != address(0), "Receiver address invalid");
        require(_value >= 0, "Value must be greater or equal to 0");
        require(_balances[msg.sender] > _value, "Not enough balance");

        _balances[msg.sender] = _balances[msg.sender].sub(_value);
        _balances[_to] = _balances[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }
	
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
	
		if(inSwapAndLiquify){ return _basicTransfer(sender, recipient, amount); }
	
		require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
	
		//Swapping tokens on contract to BNB / BUSD / whatever
		if(msg.sender != pair && !inSwapAndLiquify && swapTokensAndLiquifyEnabled && _balances[address(this)] >= swapThreshold){ swapTokens(); }
	
	
		_balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
		
		if(!isWalletLimitExempt[recipient])
        {
            require(_balances[recipient].add(amount) <= _walletMax);
        }
		
		bool exemptbuysell = false;
		if(pair == sender && isFeeExempt[recipient] ) { exemptbuysell = true; }
		if(pair == recipient && isFeeExempt[sender] ) { exemptbuysell = true; }
		
		uint256 finalAmount = !exemptbuysell ? takeFee(sender, recipient, amount) : amount;
		
        _balances[recipient] = _balances[recipient].add(finalAmount);
		
		
		
		
		
		//LS tracker
		
		if(!LSisDividendExempt[sender]){
			try LSharesDistributor.LSsetShare(sender, _balances[sender]) {} catch {}
		}
		
		if(!LSisDividendExempt[recipient]){
			try LSharesDistributor.LSsetShare(recipient, _balances[recipient]) {} catch {}
		}
		
		try LSharesDistributor.LSprocess(LSdistributorGas) {} catch {}
		
		
		
		
		
		//NS tracker
		
		if(!NSisDividendExempt[sender]){
			try NSharesDistributor.NSsetShare(sender, _balances[sender]) {} catch {}
		}
		
		if(!NSisDividendExempt[recipient]){
			try NSharesDistributor.NSsetShare(recipient, _balances[recipient]) {} catch {}
		}
		
		try NSharesDistributor.NSprocess(LSdistributorGas) {} catch {}
		
		
		
        emit Transfer(sender, recipient, finalAmount);
        return true;
    }
	
	function changeSwapBackSettings(bool enableSwapBack, uint256 newSwapBackLimit) external authorized {
        swapTokensAndLiquifyEnabled  = enableSwapBack;
        swapThreshold = newSwapBackLimit;
    }
	
	function LSclaim() public {
        LSharesDistributor.LSclaimDividend(msg.sender);
    }
	
	function NSclaim() public {
        NSharesDistributor.NSclaimDividend(msg.sender);
    }
	
	function LSchangeIsDividendExempt(address holder, bool exempt) external authorized {
        require(holder != address(this) && holder != pair);
        LSisDividendExempt[holder] = exempt;
        
        if(exempt){
            LSharesDistributor.LSsetShare(holder, 0);
        }else{
            LSharesDistributor.LSsetShare(holder, _balances[holder]);
        }
    }
	
	function NSchangeIsDividendExempt(address holder, bool exempt) external authorized {
        require(holder != address(this) && holder != pair);
        NSisDividendExempt[holder] = exempt;
        
        if(exempt){
            NSharesDistributor.NSsetShare(holder, 0);
        }else{
            NSharesDistributor.NSsetShare(holder, _balances[holder]);
        }
    }
	
	function LSchangeDistributionCriteria(uint256 newinPeriod, uint256 newMinDistribution) external authorized {
        LSharesDistributor.LSsetDistributionCriteria(newinPeriod, newMinDistribution);
    }

    function LSchangeDistributorSettings(uint256 gas) external authorized {
        require(gas < 750000);
        LSdistributorGas = gas;
    }
	
	function NSchangeDistributionCriteria(uint256 newinPeriod, uint256 newMinDistribution) external authorized {
        NSharesDistributor.NSsetDistributionCriteria(newinPeriod, newMinDistribution);
    }

    function NSchangeDistributorSettings(uint256 gas) external authorized {
        require(gas < 750000);
        NSdistributorGas = gas;
    }
	
    struct FeeTokens {
		uint256 TokensToLpInPercentage;
        uint256 TokensToMarketingInPercentage;
        uint256 TokensToBBInPercentage;
		uint256 TokensToWinnersRewardInPercentage;
		uint256 TokensToJackpotRewardInPercentage;
		uint256 TokensToLuckySharesInPercentage;
		uint256 TokensToNewcomerSharesInPercentage;
		uint256 TokensToHouseInPercentage;
    }
	
	struct BNBStuff {
		uint256 amountBNB;
		uint256 percentageOfTokens;
		uint256 amountofBNBtoCalculate;
		uint256 percentageOfLP;
		
		uint256 amountToLiquify;
		uint256 amountToSwap;
		
		uint256 amountBNBToLP;
		uint256 amountBNBToMarketing;
		uint256 amountBNBToBB;
		uint256 amountBNBToHouse;
		uint256 amountBNBToLuckyShares;
		uint256 amountBNBToNewcomerShares;
		uint256 amountBNBToWinnersReward;
		uint256 amountBNBToJackpotReward;
	}
	
	struct BUSDStuff {
		uint256 amountToSwapFromBNBToBUSD;
		uint256 BUSDBalanceBeforeSwap;
		uint256 BUSDBalanceAfterSwap;
		uint256 newlyGainedBUSD;
		uint256 BUSDLuckyShares;
		uint256 BUSDNewcomerShares;
		uint256 BUSDWinnersReward;
		uint256 BUSDJackpotReward;
	}
	

	
	function swapTokens() internal lockTheSwap{
	
		uint256 totalTokensTheContractHolds = _balances[address(this)];
		
		FeeTokens memory feeTokens;
		
		feeTokens.TokensToLpInPercentage = 0;
		feeTokens.TokensToLpInPercentage.add(BuyFeeLP.div(totalBuyFee));
		feeTokens.TokensToLpInPercentage.add(SellFeeLP.div(totalSellFee));
		feeTokens.TokensToLpInPercentage.div(2);
		uint256 TokensToLp = totalTokensTheContractHolds.mul(feeTokens.TokensToLpInPercentage);
		
		feeTokens.TokensToMarketingInPercentage = 0;
		feeTokens.TokensToMarketingInPercentage.add(BuyFeeMarketing.div(totalBuyFee));
		feeTokens.TokensToMarketingInPercentage.add(SellFeeMarketing.div(totalSellFee));
		feeTokens.TokensToMarketingInPercentage.div(2);
		
		feeTokens.TokensToBBInPercentage = 0;
		feeTokens.TokensToBBInPercentage.add(BuyFeeBB.div(totalBuyFee));
		feeTokens.TokensToBBInPercentage.add(SellFeeBB.div(totalSellFee));
		feeTokens.TokensToBBInPercentage.div(2);
		
		feeTokens.TokensToWinnersRewardInPercentage = 0;
		feeTokens.TokensToWinnersRewardInPercentage.add(BuyFeeWinnersReward.div(totalBuyFee));
		feeTokens.TokensToWinnersRewardInPercentage.add(SellFeeWinnersReward.div(totalSellFee));
		feeTokens.TokensToWinnersRewardInPercentage.div(2);
		
		feeTokens.TokensToJackpotRewardInPercentage = 0;
		feeTokens.TokensToJackpotRewardInPercentage.add(BuyFeeJackpotReward.div(totalBuyFee));
		feeTokens.TokensToJackpotRewardInPercentage.add(SellFeeJackpotReward.div(totalSellFee));
		feeTokens.TokensToJackpotRewardInPercentage.div(2);
		
		feeTokens.TokensToLuckySharesInPercentage = 0;
		feeTokens.TokensToLuckySharesInPercentage.add(BuyFeeLuckyShares.div(totalBuyFee));
		feeTokens.TokensToLuckySharesInPercentage.add(SellFeeLuckyShares.div(totalSellFee));
		feeTokens.TokensToLuckySharesInPercentage.div(2);
		
		feeTokens.TokensToNewcomerSharesInPercentage = 0;
		feeTokens.TokensToNewcomerSharesInPercentage.add(BuyFeeNewcomerShares.div(totalBuyFee));
		feeTokens.TokensToNewcomerSharesInPercentage.add(SellFeeNewcomerShares.div(totalSellFee));
		feeTokens.TokensToNewcomerSharesInPercentage.div(2);
		
		feeTokens.TokensToHouseInPercentage = 0;
		feeTokens.TokensToHouseInPercentage.add(BuyFeeHouse.div(totalBuyFee));
		feeTokens.TokensToHouseInPercentage.add(SellFeeHouse.div(totalSellFee));
		feeTokens.TokensToHouseInPercentage.div(2);
		
		BNBStuff memory swappedBNBstuff;
		
		swappedBNBstuff.amountToLiquify = TokensToLp.div(2);
		swappedBNBstuff.amountToSwap = totalTokensTheContractHolds.sub(swappedBNBstuff.amountToLiquify);
		
		address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            swappedBNBstuff.amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );
		
		swappedBNBstuff.amountBNB = address(this).balance;
		swappedBNBstuff.percentageOfTokens = swappedBNBstuff.amountToSwap.mul(100).div(totalTokensTheContractHolds);
		swappedBNBstuff.amountofBNBtoCalculate = swappedBNBstuff.amountBNB.mul(100).div(swappedBNBstuff.percentageOfTokens);
		swappedBNBstuff.percentageOfLP = swappedBNBstuff.amountToLiquify.div(swappedBNBstuff.amountToSwap);
		
		swappedBNBstuff.amountBNBToLP = swappedBNBstuff.percentageOfLP.mul(swappedBNBstuff.amountBNB).div(100);
		swappedBNBstuff.amountBNBToMarketing = swappedBNBstuff.amountofBNBtoCalculate.mul(feeTokens.TokensToMarketingInPercentage);
		swappedBNBstuff.amountBNBToBB = swappedBNBstuff.amountofBNBtoCalculate.mul(feeTokens.TokensToBBInPercentage);
		swappedBNBstuff.amountBNBToHouse = swappedBNBstuff.amountofBNBtoCalculate.mul(feeTokens.TokensToHouseInPercentage);
		
		(bool tmpSuccess,) = payable(marketingwallet).call{value: swappedBNBstuff.amountBNBToMarketing, gas: 30000}("");
		(bool tmpSuccess1,) = payable(burnandbuybackwallet).call{value: swappedBNBstuff.amountBNBToBB, gas: 30000}("");
		(bool tmpSuccess2,) = payable(housewallet).call{value: swappedBNBstuff.amountBNBToHouse, gas: 30000}("");
		// only to supress warning msg
        tmpSuccess = false;
        tmpSuccess1 = false;
		tmpSuccess2 = false;
		
		if(TokensToLp > 0){
            router.addLiquidityETH{value: swappedBNBstuff.amountBNBToLP}(
                address(this),
                TokensToLp,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
            emit AutoLiquify(swappedBNBstuff.amountBNBToLP, TokensToLp);
        }
		
		swappedBNBstuff.amountBNBToLuckyShares = swappedBNBstuff.amountofBNBtoCalculate.mul(feeTokens.TokensToLuckySharesInPercentage);
		swappedBNBstuff.amountBNBToNewcomerShares = swappedBNBstuff.amountofBNBtoCalculate.mul(feeTokens.TokensToNewcomerSharesInPercentage);
		
		swappedBNBstuff.amountBNBToWinnersReward = swappedBNBstuff.amountofBNBtoCalculate.mul(feeTokens.TokensToWinnersRewardInPercentage);
		swappedBNBstuff.amountBNBToJackpotReward = swappedBNBstuff.amountofBNBtoCalculate.mul(feeTokens.TokensToJackpotRewardInPercentage);
		
		BUSDStuff memory busdstuff;
		
		busdstuff.amountToSwapFromBNBToBUSD = swappedBNBstuff.amountBNBToLuckyShares.add(swappedBNBstuff.amountBNBToNewcomerShares).add(swappedBNBstuff.amountBNBToWinnersReward).add(swappedBNBstuff.amountBNBToJackpotReward);
		
		address[] memory pathBNBBusd = new address[](2);
        pathBNBBusd[0] = router.WETH();
        pathBNBBusd[1] = address(RewardTokenBUSD);
		
		busdstuff.BUSDBalanceBeforeSwap = RewardTokenBUSD.balanceOf(address(this));

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            swappedBNBstuff.amountToSwap,
            0,
            pathBNBBusd,
            address(this),
            block.timestamp
        );
		
		busdstuff.BUSDBalanceAfterSwap = RewardTokenBUSD.balanceOf(address(this));
		busdstuff.newlyGainedBUSD = busdstuff.BUSDBalanceAfterSwap.sub(busdstuff.BUSDBalanceBeforeSwap);
		
		busdstuff.BUSDLuckyShares = busdstuff.newlyGainedBUSD.mul(swappedBNBstuff.amountBNBToLuckyShares).div(busdstuff.amountToSwapFromBNBToBUSD);
		try LSharesDistributor.LSdeposit{value: busdstuff.BUSDLuckyShares}() {} catch {}
		
		busdstuff.BUSDNewcomerShares = busdstuff.newlyGainedBUSD.mul(swappedBNBstuff.amountBNBToNewcomerShares).div(busdstuff.amountToSwapFromBNBToBUSD);
		try NSharesDistributor.NSdeposit{value: busdstuff.BUSDNewcomerShares}() {} catch {}
		
		busdstuff.BUSDWinnersReward = busdstuff.newlyGainedBUSD.mul(swappedBNBstuff.amountBNBToWinnersReward).div(busdstuff.amountToSwapFromBNBToBUSD);
		busdstuff.BUSDJackpotReward = busdstuff.newlyGainedBUSD.mul(swappedBNBstuff.amountBNBToJackpotReward).div(busdstuff.amountToSwapFromBNBToBUSD);
		
		unpayedWinnersRewardOnContract = unpayedWinnersRewardOnContract.add(busdstuff.BUSDWinnersReward);
		unpayedJackpotOnContract = unpayedJackpotOnContract.add(busdstuff.BUSDJackpotReward);
	}

	event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
	
	function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        uint256 buyorsell = pair == recipient ? totalSellFee : totalBuyFee;
		uint256 taxToPay = amount.mul(buyorsell).div(100);
		
		_balances[address(this)] = _balances[address(this)].add(taxToPay);
		emit Transfer(sender, address(this), taxToPay);
		return amount.sub(taxToPay);
    }

	function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }
	
	//The amounts are in BUSD!!
	function payOutWinnersReward() internal returns (bool) {
		
		//Ide jön a winner sorsolás / kifizetés!
		alreadyPayedWinnersReward = alreadyPayedWinnersReward.add(unpayedWinnersRewardOnContract);
		unpayedWinnersRewardOnContract = 0;
		return true;
	}
	
	//The amounts are in BUSD!!
	function payOutJackpot() internal returns (bool) {
		
		//Ide jön a jackpot sorsolás / kifizetés!
		alreadyPayedJackpot = alreadyPayedJackpot.add(unpayedJackpotOnContract);
		unpayedJackpotOnContract = 0;
		return true;
	}
}