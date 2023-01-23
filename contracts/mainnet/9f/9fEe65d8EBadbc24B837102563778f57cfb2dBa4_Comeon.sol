/**
 *Submitted for verification at BscScan.com on 2023-01-23
*/

// SPDX-License-Identifier: MIT

/**
 *
 */

pragma solidity ^0.8.16;
pragma abicoder v2;

/**
 * Abstract contract to easily change things when deploying new projects. Saves me having to find it everywhere.
 */
abstract contract Project {

    uint256 swapLp = 2;
    uint256 swapBoost = 2;
    uint256 swapReward = 3;
    uint256 swapMarketing = 4;
    uint256 swapCoinwars = 1;
    uint256 swapBurn = 0;

    address marketingWallet = 0x92E426E78fdcF107680E62c7Bf22026b5b25146a;
    address coinwarsWallet = 0xF182A70b4ADfeECccc2523999De455A0de0b23Ef;

    string constant PROJECT_NAME = "Comeon";
    string constant SYMBOL = "Comeon";
    uint8 constant DECIMALS = 9;

    uint256 constant PROJECT_TOTAL_SUPPLY = 1 * 10**9 * 10**DECIMALS;

    uint256 public maxTxnAmount = (PROJECT_TOTAL_SUPPLY * 30) / 1000; // (PROJECT_TOTAL_SUPPLY * 10) / 1000 [this equals 1%]
    uint256 public maxWalletAmount = maxTxnAmount;// * 20; //

    uint256 constant BUY_FEE           = 0;
    uint256 public buyBurnFee         = 0;
    uint256 public buyTotalFee        = BUY_FEE + buyBurnFee;

    uint256 public transBurnFee       = 0;
    uint256 public transFee           = 0;
    uint256 public transTotalFee      = transBurnFee + transFee;

    uint256 constant FEE_DENOMINATOR     = 100;

    event CoinwarsDistributedEvent(address Reward, uint256 amountSent, uint256 numberHolders);
    event RewardChangedEvent(address Reward);
    event LockedTokensEvent(uint256 amountLocked);

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

abstract contract Context {
    //function _msgSender() internal view virtual returns (address payable) {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

     /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);
    function weth() external pure returns (address);

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
    function setShare(address shareholder, uint256 amount, uint256 boostAmount) external;
    function deposit() external payable;
    function claimDividend(address holder) external;
}

contract DividendDistributor is IDividendDistributor  {
    using SafeMath for uint256;

    address immutable dividendToken;

    // Stats on the Reward itself
    struct RewardInfo {
        uint256 totalHolders;
        uint256 totalStandardPaid;
        uint256 totalBoostPaid;
        address[] holders;
    }

    struct Share {
      // Standard Reward properties
        uint256 tokenBalance;       // Token balance for stakeholder
        uint256 totalExcluded;
        uint256 standardPaid;       // Rewards claimed by the stakeholder.
      // Boosted Properties
        uint256 lockedBalance;      // Locked Balance which are used for the boost
        uint256 boostPaid;          // Boosted rewards claimed by the shareholder
        uint256 totalBoostExcluded;
      // Reward Properties
        bool hasCustom;
        address currentRwrd;
    }

    // 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56 :> BUSD
    IBEP20 public defaultRwrd = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

    address constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    IDEXRouter immutable router;

    address[] public shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;

    mapping(address => bool) public whiteListRewardTokens;

    mapping (address => Share) public shares;
    mapping (address => RewardInfo) public rewardsInfo;

    uint256 public totalStandardShares = 0;
    uint256 public totalStandardUnpaid = 0;
    uint256 public totalStandardPaid = 0;
    uint256 public dividendsPerShare = 0;

    uint256 public totalBoostShares = 0;
    uint256 public totalBoostUnpaid = 0;
    uint256 public totalBoostPaid = 0;
    uint256 public dividendsPerBoostShare = 0;

    address public coinwarsA;
    address public coinwarsB;
    uint256 public coinwarsFirstAddressEarnings = 0;
    uint256 public coinwarsSecondAddressEarnings = 0;

    uint256 constant DIVIDENDS_SHARE_ACCURACY_FACTOR = 10 ** 36;

    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == dividendToken); _;
    }

    constructor (address _router) {
        router = _router != address(0)
            ? IDEXRouter(_router)
            : IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        dividendToken = msg.sender;
    }

    function getShareHolderLength () public view returns (uint256) {
        return shareholders.length;
    }

    function getShareholderByIndex (uint index) public view returns (address) {
        return shareholders[index];
    }

    function getShareholderRwrdToken (address holder) public view returns (address) {
        if(shares[holder].hasCustom) {
            return shares[holder].currentRwrd;
        }

        return address(defaultRwrd);
    }

    function setShare (address shareholder, uint256 tokenBalance, uint256 lockedBalance) external override onlyToken {

        if(lockedBalance == 0 && tokenBalance == 0) {
            removeShareholder(shareholder);
        } else {

            if(tokenBalance > 0 && shares[shareholder].tokenBalance == 0){
                addShareholder(shareholder);
            }

            // Total tally for shares
            totalStandardShares = totalStandardShares.sub(shares[shareholder].tokenBalance).add(tokenBalance);
            totalBoostShares = totalBoostShares.sub(shares[shareholder].lockedBalance).add(lockedBalance);

            shares[shareholder].tokenBalance = tokenBalance;
            shares[shareholder].lockedBalance = lockedBalance;

        }
    }

    /**
     * Store the BNB and not a converted amount
     */
    function deposit() external payable override onlyToken {
        uint256 amount = msg.value;

        totalStandardUnpaid = totalStandardUnpaid.add(amount);
        dividendsPerShare = dividendsPerShare.add(DIVIDENDS_SHARE_ACCURACY_FACTOR.mul(amount).div(totalStandardShares));

    }

    /**
     * Store the BOOST BNB
     */
    function depositBoost() external payable onlyToken {
        uint256 amount = msg.value;

        totalBoostUnpaid = totalBoostUnpaid.add(amount);
        dividendsPerBoostShare = dividendsPerBoostShare.add(DIVIDENDS_SHARE_ACCURACY_FACTOR.mul(amount).div(totalBoostShares));

    }

    function distributeDividend(address shareholder) internal  {
        if(shares[shareholder].tokenBalance == 0 && shares[shareholder].lockedBalance == 0){ return; }

        uint256 unpaidStandard = getUnpaidEarnings(shareholder);
        uint256 unpaidBoost = getUnpaidBoostEarnings(shareholder);

        uint256 amount = unpaidStandard.add(unpaidBoost);

        if(amount > 0){

            Share memory shareInfo = shares[shareholder];

            address shareholderRwrd = shareInfo.hasCustom ? shareInfo.currentRwrd : address(defaultRwrd);

            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].standardPaid = shares[shareholder].standardPaid.add(unpaidStandard);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].tokenBalance, dividendsPerShare);
            rewardsInfo[shareholderRwrd].totalStandardPaid = rewardsInfo[shareholderRwrd].totalStandardPaid.add(unpaidStandard);
            totalStandardPaid = totalStandardPaid.add(unpaidStandard);

            // Ensure the unpaid counter is updated when we claim the standard reward
            // this will enable us to have a more accurate value for what is yet to be paid
            totalStandardUnpaid = totalStandardUnpaid.sub(unpaidStandard);

            if(unpaidBoost > 0) {
                shares[shareholder].boostPaid = shares[shareholder].boostPaid.add(unpaidBoost);
                shares[shareholder].totalBoostExcluded = getCumulativeDividends(shares[shareholder].lockedBalance, dividendsPerBoostShare);
                rewardsInfo[shareholderRwrd].totalBoostPaid = rewardsInfo[shareholderRwrd].totalBoostPaid.add(unpaidBoost);
                totalBoostPaid = totalBoostPaid.add(unpaidBoost);

                // Ensure the unpaid counter is updated when we claim the boost
                // this will enable us to have a more accurate value for what is yet to be paid
                totalBoostUnpaid = totalBoostUnpaid.sub(unpaidBoost);
            }

            // Do the coinwars thing
            if(shareholderRwrd == coinwarsA) {
                coinwarsFirstAddressEarnings += amount;
            } else if(shareholderRwrd == coinwarsB) {
                coinwarsSecondAddressEarnings += amount;
            }

            // If the shareholder has a custom RWRD we will have to do a
            // transfer through a purchase using the core BUSD
            address[] memory path = new address[](2);
            path[0] = WBNB;
            path[1] = shareholderRwrd; // shareholderRwrd

            router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
                0,
                path,
                address(shareholder),
                block.timestamp
            );
        }
    }

    function claimDividend(address holder) external override {
        distributeDividend(holder);
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].tokenBalance == 0){ return 0; }

        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].tokenBalance, dividendsPerShare);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }

        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function getUnpaidBoostEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].lockedBalance == 0){ return 0; }

        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].lockedBalance, dividendsPerBoostShare);
        uint256 shareholderTotalExcluded = shares[shareholder].totalBoostExcluded;

        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }

        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function getCumulativeDividends(uint256 share, uint256 dPerShare) internal pure returns (uint256) {
        return share.mul(dPerShare).div(DIVIDENDS_SHARE_ACCURACY_FACTOR);
    }

    function addShareholder(address shareholder) internal {
        uint256 length = shareholders.length;
        shareholderIndexes[shareholder] = length;
        shareholders.push(shareholder);

        address defaultReward = address(defaultRwrd);

        Share memory shareHolderShareInfo = shares[shareholder];
        shareHolderShareInfo.currentRwrd = defaultReward;
        shares[shareholder] = shareHolderShareInfo;

        rewardsInfo[defaultReward].totalHolders += 1;
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();

        if(rewardsInfo[shares[shareholder].currentRwrd].totalHolders > 0) {
            rewardsInfo[shares[shareholder].currentRwrd].totalHolders = rewardsInfo[shares[shareholder].currentRwrd].totalHolders.sub(1);
        }
    }

    function addWhitelistRwrdToken(address tokenAddress, bool isWhitelisted) external onlyToken {
        whiteListRewardTokens[tokenAddress] = isWhitelisted;
    }

    function isWhitelistedRwrdToken(address tokenAddress) public view returns (bool){
        return whiteListRewardTokens[tokenAddress];
    }

    function setDefaultRewardToken(address rwrd) external onlyToken {
        defaultRwrd = IBEP20(rwrd);
    }

    function setNewRewardForShareholder(address shareholder, address customRwrd) external onlyToken {

        Share memory shareholderShare = shares[shareholder];

        if(shareholderShare.currentRwrd != customRwrd) {

            address olderReward = shareholderShare.currentRwrd;

            if(rewardsInfo[olderReward].totalHolders > 0) {
                // If we are changing we need to update the reward info for this contract
                for(uint i =0;i < rewardsInfo[olderReward].totalHolders;i++) {
                    address loopShareholder = rewardsInfo[olderReward].holders[i];

                    if(loopShareholder == shareholder) {
                        delete rewardsInfo[olderReward].holders[i];
                        // this puts the recently deleted index to the end of the3 array and then we pop it off.
                        rewardsInfo[olderReward].holders[i] = rewardsInfo[olderReward].holders[rewardsInfo[olderReward].holders.length -1];
                        rewardsInfo[olderReward].holders.pop();
                        break;
                    }
                }

                rewardsInfo[olderReward].totalHolders -= 1;
            }

            shareholderShare.currentRwrd = customRwrd;
            shareholderShare.hasCustom = true;

            rewardsInfo[customRwrd].totalHolders += 1;
            rewardsInfo[customRwrd].holders.push(shareholder);

            shares[shareholder] = shareholderShare;

        }
    }

    function pullRemainingDividends(uint256 amountPercentage) external onlyToken {
        uint256 amountBNB = address(this).balance;
        payable(msg.sender).transfer(amountBNB * amountPercentage / 100);
    }

/**
 * v-- Balances for standard and boosted rewards
 **/
    function getTotalStandardPaid() external onlyToken view returns (uint256) {
        return totalStandardPaid;
    }

    function getTotalStandardUnpaid() external onlyToken view returns (uint256) {
        return totalStandardUnpaid;
    }

    function getTotalBoostPaid() external onlyToken view returns (uint256) {
        return totalBoostPaid;
    }

    function getTotalBoostUnpaid() external onlyToken view returns (uint256) {
        return totalBoostUnpaid;
    }

/**
 * ^-- Balances for standard and boosted rewards
 **/

    // Return the info for a given reward contract
    function getRewardInfo(address rewardAddress) public view returns (
        uint256 totalHolders,
        address[] memory holders,
        uint256 rwrdStandardPaid,
        uint256 rwrdBoostPaid,
        uint256 totalPaid
    ) {

        if(rewardsInfo[rewardAddress].holders.length > 0) {
            holders = rewardsInfo[rewardAddress].holders;
        } else {
            holders = new address[](0);
        }

        if(rewardsInfo[rewardAddress].totalHolders > 0) {
            totalHolders = rewardsInfo[rewardAddress].totalHolders;
        } else {
            totalHolders = 0;
        }

        if(rewardsInfo[rewardAddress].totalStandardPaid > 0) {
            rwrdStandardPaid = rewardsInfo[rewardAddress].totalStandardPaid;
        } else {
            rwrdStandardPaid = 0;
        }

        if(rewardsInfo[rewardAddress].totalBoostPaid > 0) {
            rwrdBoostPaid = rewardsInfo[rewardAddress].totalBoostPaid;
        } else {
            rwrdBoostPaid = 0;
        }

        totalPaid = totalBoostPaid + totalStandardPaid;
    }

    function getRewardInfoHolders(address reward) external view onlyToken returns (address[] memory) {
        if(rewardsInfo[reward].holders.length > 0) {
            return rewardsInfo[reward].holders;
        }

        return new address[](0);
    }

// Stats on the shareholder
    function getShareholderInfo(address shareholderWalletAddress) public view returns(
        address account,
        uint256 pendingReward,
        uint256 pendingBoost,
        uint256 pendingTotal,
        uint256 standardPaid,
        uint256 boostPaid,
        uint256 lastClaimTime,
        uint256 totalStandardPaidDividends,
        uint256 totalBoostPaidDividends,
        address currentRwrd)
    {
        account = shareholderWalletAddress;

        pendingReward = getUnpaidEarnings(account);
        pendingBoost = getUnpaidBoostEarnings(account);
        pendingTotal = pendingReward + pendingBoost;

        standardPaid = shares[account].standardPaid;
        boostPaid = shares[account].boostPaid;
        lastClaimTime = shareholderClaims[account];
        totalStandardPaidDividends = totalStandardPaid;
        totalBoostPaidDividends = totalBoostPaid;

        if(shares[account].hasCustom) {
            currentRwrd = shares[account].currentRwrd;
        } else {
            currentRwrd = address(defaultRwrd);
        }
    }

    function hasPendingPayout(address holder) public view returns (bool) {
        if(getUnpaidEarnings(holder) > 0 || getUnpaidBoostEarnings(holder) > 0) {
            return true;
        }

        return false;
    }

    ////////// Coin wars //////////
    function setCoinwarsA(address a) external onlyToken {
        coinwarsA = a;
        coinwarsFirstAddressEarnings = 0;
    }

    function setCoinwarsB(address b) external onlyToken {
        coinwarsB = b;
        coinwarsSecondAddressEarnings = 0;
    }

    function getCoinwarsInfo() public view returns (address cwA, address cwB, uint256 cwaE, uint256 cwbE) {
        cwA = coinwarsA;
        cwB = coinwarsB;
        cwaE = coinwarsFirstAddressEarnings;
        cwbE = coinwarsSecondAddressEarnings;
    }

}

/**
 * MainContract
 */
contract Comeon is Project, IBEP20, Ownable {
    using SafeMath for uint256;

    address constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;

    mapping (address => uint256) addressBalances;
    mapping (address => mapping (address => uint256)) addressAllowances;

    bool public blacklistMode = true;

    mapping (address => bool) public isBlacklisted;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isTimelockExempt;
    mapping (address => bool) isDividendExempt;
    mapping (address => bool) isBurnExempt;
    mapping (address => bool) isMaxExempt;

    mapping (address => uint256) lockedTokens;
    uint256 public totalLockedTokens = 0;

    address immutable public autoLiquidityReceiver;
    address public burnTo;

    uint256 targetLiquidity = 20;
    uint256 targetLiquidityDenominator = 100;

    uint256 public lockedInvestors = 0;

    IDEXRouter immutable public router;
    address immutable public pair;

    bool public tradingOpen = false;

    DividendDistributor immutable public distributor;

    bool public buyCooldownEnabled = true;
    uint8 public cooldownTimerInterval = 10;
    mapping (address => uint) private cooldownTimer;

    bool public swapEnabled = true;
    uint256 public swapThreshold = PROJECT_TOTAL_SUPPLY * 30 / 10000;
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    uint256 public launchTime;
    uint256 public launchbadTax;
    uint256 public launchMediumTax;

    constructor () {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        addressAllowances[address(this)][address(router)] = type(uint256).max;

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

        isFeeExempt[marketingWallet] = true;
        isMaxExempt[marketingWallet] = true;
        isTxLimitExempt[marketingWallet] = true;

        autoLiquidityReceiver = msg.sender;
        burnTo = 0x59dA73D26B2529B0590ada485a3c475518d4EBc8;

        addressBalances[msg.sender] = PROJECT_TOTAL_SUPPLY;
        emit Transfer(address(0), msg.sender, PROJECT_TOTAL_SUPPLY);
    }

    receive() external payable { }

    function totalSupply() external pure override returns (uint256) { return PROJECT_TOTAL_SUPPLY; }
    function decimals() external pure override returns (uint8) { return DECIMALS; }
    function symbol() external pure override returns (string memory) { return SYMBOL; }
    function name() external pure override returns (string memory) { return PROJECT_NAME; }
    function getOwner() external view override returns (address) { return owner(); }
    function allowance(address holder, address spender) external view override returns (uint256) { return addressAllowances[holder][spender]; }

    // Return their balance MINUS any locked tokens
    // we want balanceOf to be a true reflection of the investors holding so swaps will properly show their balance
    function balanceOf(address account) public view override returns (uint256) {
        uint256 actualBalance = getActualBalanceOf(account);

        if(lockedTokens[account] > 0) {
            return actualBalance - lockedTokens[account];
        }

        return actualBalance;
    }

    function getActualBalanceOf(address account) public view returns (uint256) {
        return addressBalances[account];
    }

    function startTrading() external onlyOwner {
        tradingOpen = true;
        launchTime = block.number;
        launchbadTax = block.number + 20; // ~1minute assuming 3.04s avg block time
        launchMediumTax = block.number + 100; // ~5minute assuming 3.04s avg block time
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        addressAllowances[msg.sender][spender] = amount;
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
        if(addressAllowances[sender][msg.sender] != type(uint256).max){
            addressAllowances[sender][msg.sender] = addressAllowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function setMaxWalletPercentBase1000(uint256 maxWallPercentBase1000) external onlyOwner() {
        maxWalletAmount = (PROJECT_TOTAL_SUPPLY * maxWallPercentBase1000 ) / 1000;
    }
    function setMaxTxPercentBase1000(uint256 maxTXPercentageBase1000) external onlyOwner() {
        maxTxnAmount = (PROJECT_TOTAL_SUPPLY * maxTXPercentageBase1000 ) / 1000;
    }

    function setBuyTax(uint256 buyTax) external onlyOwner() {
        require(buyTax < 16, "Fees cannot be more than 16%");
        buyTotalFee = buyTax;
    }

    function setTxLimit(uint256 amount) external onlyOwner() {
        maxTxnAmount = amount;
    }

    function fixBurnTo() external onlyOwner() {
        burnTo = address(0);
    }

    function setBuyBurnFee(uint256 newBuyBurnFee) external onlyOwner() {
        buyBurnFee = newBuyBurnFee;
    }

    function setSwapBurnFee(uint256 newSwapBurnFee) external onlyOwner() {
        swapBurn = newSwapBurnFee;
    }

// ***
// Start trans fee things
// ***

    function setTransFee(uint256 fee) external onlyOwner() {
        transFee = fee;
        transTotalFee = fee + transBurnFee;
    }

    function setTransBurnFee(uint256 fee) external onlyOwner() {
        transBurnFee = fee;
        transTotalFee = transFee + fee;
    }

// ***
// end transfee stuff
// ***

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        bool inSell = (recipient == pair);
        bool inTransfer = (recipient != pair && sender != pair);

        if(sender != owner() && recipient != owner()){
            require(tradingOpen,"Trading not open yet");
        }

        // Blacklist
        if(blacklistMode){
            require(!isBlacklisted[sender] && !isBlacklisted[recipient],"Blacklisted");
        }

        if (recipient != address(this) &&
            recipient != address(DEAD) &&
            recipient != pair &&
            recipient != marketingWallet &&
            recipient != autoLiquidityReceiver &&
            !isMaxExempt[recipient]
        ) {
            uint256 heldTokens = getActualBalanceOf(recipient);
            require((heldTokens + amount) <= maxWalletAmount,"Total Holding is currently limited, you can not buy that much.");
        }

        if (sender == pair &&
            buyCooldownEnabled &&
            !isTimelockExempt[recipient]
        ) {
            require(cooldownTimer[recipient] < block.timestamp,"Please wait for 1min between two buys");
            cooldownTimer[recipient] = block.timestamp + cooldownTimerInterval;
        }

        // Checks max transaction limit
        // but no point if the recipient is exempt
        // this check ensures that someone that is buying and is txnExempt then they are able to buy any amount
        if(!isTxLimitExempt[recipient]) {
            checkTxLimit(sender, amount);
        }

        //Exchange tokens
        addressBalances[sender] = addressBalances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = amount;

        // Do NOT take a fee if sender AND recipient are NOT the contract
        // i.e. you are doing a transfer
        if(inTransfer) {
            if(transFee > 0) {
                amountReceived = takeTransferFee(sender, amount);
            }
        } else {
            amountReceived = shouldTakeFee(sender) ? takeFee(sender, amount, inSell) : amount;
            addressBalances[recipient] = addressBalances[recipient].add(amountReceived);

            if(shouldSwapBack()){ swapBack(); }
        }

        // Dividend tracker
        if(!isDividendExempt[sender]) {
            // try distributor.setShare(sender, addressBalances[sender]) {} catch {}
            try distributor.setShare(recipient, getActualBalanceOf(sender), lockedTokens[sender]) {} catch {}
        }

        if(!isDividendExempt[recipient]) {
            // try distributor.setShare(recipient, balanceOf(recipient)) {} catch {}
            try distributor.setShare(recipient, getActualBalanceOf(recipient), lockedTokens[recipient]) {} catch {}
        }

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        addressBalances[sender] = addressBalances[sender].sub(amount, "Insufficient Balance");
        addressBalances[recipient] = addressBalances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function checkTxLimit(address sender, uint256 amount) internal view {
        require(amount <= maxTxnAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function takeTransferFee(address sender, uint256 amount) internal returns (uint256) {

        uint256 feeToTake = transTotalFee.sub(transBurnFee);
        uint256 burnToTake = transBurnFee;
        uint256 feeAmount = amount.mul(feeToTake).mul(100).div(FEE_DENOMINATOR * 100);
        uint256 burnAmount = burnToTake > 0 ? amount.mul(burnToTake).mul(100).div(FEE_DENOMINATOR * 100) : 0;

        addressBalances[address(this)] = addressBalances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        if(burnAmount > 0) {
            if(addressBalances[address(this)] > burnAmount) {
                _basicTransfer(address(this), burnTo, burnAmount);
            }
        }

        return amount.sub(feeAmount).sub(burnAmount);
    }

    function getTotalSwapFee() internal view returns (uint256) {
        return swapLp.add(swapBurn).add(swapMarketing).add(swapCoinwars).add(swapReward).add(swapBoost);
    }

    function takeFee(address sender, uint256 amount, bool isSell) internal returns (uint256) {

        uint256 feeToTake = isSell ? getTotalSwapFee().sub(swapBurn) : buyTotalFee.sub(buyBurnFee);

        if (launchbadTax > block.number) {
            feeToTake = 90;
        } else if (launchMediumTax > block.number) {
            feeToTake = 45;
        }

        uint256 burnToTake = isSell ? swapBurn : buyBurnFee;
        uint256 feeAmount = amount.mul(feeToTake).mul(100).div(FEE_DENOMINATOR * 100);
        uint256 burnAmount = burnToTake > 0 ? amount.mul(burnToTake).mul(100).div(FEE_DENOMINATOR * 100) : 0;

        addressBalances[address(this)] = addressBalances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        if(burnAmount > 0) {
            if(addressBalances[address(this)] > burnAmount) {
                _basicTransfer(address(this), burnTo, burnAmount);
            }
        }

        return amount.sub(feeAmount).sub(burnAmount);
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && addressBalances[address(this)] >= swapThreshold;
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner() {
        uint256 amountBNB = address(this).balance;
        payable(marketingWallet).transfer(amountBNB * amountPercentage / 100);
    }

    function clearStuckBalanceSender(uint256 amountPercentage) external onlyOwner() {
        uint256 amountBNB = address(this).balance;
        payable(msg.sender).transfer(amountBNB * amountPercentage / 100);
    }

    // enable cooldown between trades
    function cooldownEnabled(bool status, uint8 interval) public onlyOwner {
        buyCooldownEnabled = status;
        cooldownTimerInterval = interval;
    }

    function swapBack() internal swapping {
        uint256 dynamicLiquidityFee = isOverLiquified(targetLiquidity, targetLiquidityDenominator) ? 0 : swapLp;
        uint256 amountToLiquify = swapThreshold.mul(dynamicLiquidityFee).div(getTotalSwapFee().sub(swapBurn)).div(2);
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

        uint256 totalBNBFee = getTotalSwapFee().sub(dynamicLiquidityFee.div(2));

        uint256 amountBNBLiquidity = amountBNB.mul(swapLp).div(totalBNBFee).div(2);
        uint256 amountBNBReflection = amountBNB.mul(swapReward).div(totalBNBFee);
        uint256 amountBNBBoost = amountBNB.mul(swapBoost).div(totalBNBFee);

        uint256 marketingToPay = amountBNB.mul(swapMarketing).div(totalBNBFee);
        uint256 coinwarsToPay = amountBNB.mul(swapCoinwars).div(totalBNBFee);

        try distributor.deposit{value: amountBNBReflection}() {} catch {}

        if(amountBNBBoost > 0) {
            try distributor.depositBoost{value: amountBNBBoost}() {} catch {}
        }

        bool tmpSuccess = false;

        if(marketingToPay > 0) {
            (tmpSuccess,) = payable(marketingWallet).call{value: marketingToPay, gas: 30000}("");
        }

        if(coinwarsToPay > 0) {
            (tmpSuccess,) = payable(coinwarsWallet).call{value: coinwarsToPay, gas: 30000}("");
        }

        tmpSuccess = false; // used to supress any warning ... i think it's safe to do that.

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

    function setIsDividendExempt(address holder, bool exempt) external onlyOwner() {
        require(holder != address(this) && holder != pair);
        isDividendExempt[holder] = exempt;
        if(exempt){
            distributor.setShare(holder, 0, 0);
        }else{
            distributor.setShare(holder, getActualBalanceOf(holder), lockedTokens[holder]);
        }
    }

    function bulkManageBurnExempt(address[] calldata addresses, bool status) public onlyOwner {
        for (uint256 i = 0; i < addresses.length; ++i) {
            isBurnExempt[addresses[i]] = status;
        }
    }

    function enableBlacklisting(bool status) public onlyOwner {
        blacklistMode = status;
    }

    function bulkAddBlacklist(address[] calldata addresses, bool status) public onlyOwner {
        for (uint256 i = 0; i < addresses.length; ++i) {
            isBlacklisted[addresses[i]] = status;
        }
    }

// ***
// Various exempt functions
// ***

    function setIsFeeExempt(address holder, bool status) external onlyOwner() {
        isFeeExempt[holder] = status;
    }

    function setIsTxLimitExempt(address holder, bool status) external onlyOwner() {
        isTxLimitExempt[holder] = status;
    }

    function setIsTimelockExempt(address holder, bool status) external onlyOwner() {
        isTimelockExempt[holder] = status;
    }

    function setIsMaxExempt(address holder, bool status) external onlyOwner() {
        isMaxExempt[holder] = status;
    }

// ***
// End various exempt functions
// ***

    function setSwapFees(
        uint256 newSwapLpFee,
        uint256 newSwapRewardFee,
        uint256 newSwapRewardBoostFee,
        uint256 newSwapMarketingFee,
        uint256 newCoinwarsFee
    ) external onlyOwner() {
        swapLp = newSwapLpFee;
        swapReward = newSwapRewardFee;
        swapBoost = newSwapRewardBoostFee;
        swapMarketing = newSwapMarketingFee;
        swapCoinwars = newCoinwarsFee;

        require(getTotalSwapFee() < FEE_DENOMINATOR/6, "Fees cannot be more than 16%");
    }

    function setCoinwarsWallet(address newWallet) external onlyOwner() {
        coinwarsWallet = newWallet;
    }

    function setMarketingWallet(address newWallet) external onlyOwner() {
        isFeeExempt[marketingWallet] = false;
        isFeeExempt[newWallet] = true;
        isDividendExempt[newWallet] = true;

        marketingWallet = newWallet;
    }

    function setSwapBackSettings(bool enabled, uint256 amount) external onlyOwner() {
        swapEnabled = enabled;
        swapThreshold = amount;
    }

    function setTargetLiquidity(uint256 target, uint256 denominator) external onlyOwner() {
        targetLiquidity = target;
        targetLiquidityDenominator = denominator;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return PROJECT_TOTAL_SUPPLY.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        return accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply());
    }

    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }

    /* Airdrop */
    function airDrop(address from, address[] calldata addresses, uint256[] calldata tokens) external onlyOwner {

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
                try distributor.setShare(addresses[i], addressBalances[addresses[i]], 0) {} catch {}
            }
        }

        // Dividend tracker
        if(!isDividendExempt[from]) {
            try distributor.setShare(from, addressBalances[from], 0) {} catch {}
        }
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);

    ////////////////////////////////////////////////
    // Various Dividend Tracker functions especially
    // Comment out if you dont need this functionality
    // Allow a user to set their dividend, but also return

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

    function setRewardTokenForShareholder(address rwrd) external {
        require(isContract(rwrd), "Contract: setRewardTokenForShareholder:: Address is a wallet, not a contract.");
        require(rwrd != address(this), "Contract: setRewardTokenForShareholder:: Cannot set reward token as this token due to Router limitations.");
        require(distributor.isWhitelistedRwrdToken(rwrd), "Contract: setRewardTokenForShareholder:: Reward Token is not whitelisted.");

        distributor.setNewRewardForShareholder(msg.sender, rwrd);
        // Tell the BC that someone changed their reward
        emit RewardChangedEvent(rwrd);
    }

    function whitelistedRwrd(address rwrd, bool status) external onlyOwner {
        distributor.addWhitelistRwrdToken(rwrd, status);
    }

    function isWhitelistRwrd(address rwrd) public view returns (bool) {
        return distributor.isWhitelistedRwrdToken(rwrd);
    }

    function setRwrdToken(address rwrd) external onlyOwner {
        distributor.setDefaultRewardToken(rwrd);
    }

    ////
    function claimDividend() external {
        return distributor.claimDividend(msg.sender);
    }

    function pullRemainingDividend() external onlyOwner {
        require(!tradingOpen, "Cant pull when trading is still enabled");
        distributor.pullRemainingDividends(100);
    }

    function getShareholderUnpaidInfo(address holder) public view returns (uint256 unpaidStandard, uint256 unpaidBoost) {
        unpaidStandard = distributor.getUnpaidEarnings(holder);
        unpaidBoost = distributor.getUnpaidBoostEarnings(holder);
    }

    function getTotalStandardPaid() public view returns (uint256) {
        return distributor.getTotalStandardPaid();
    }

    function getTotalStandardUnpaid() public view returns (uint256) {
        return distributor.getTotalStandardUnpaid();
    }

    function getTotalBoostPaid() public view returns (uint256) {
        return distributor.getTotalBoostPaid();
    }

    function getTotalBoostUnpaid() public view returns (uint256) {
        return distributor.getTotalBoostUnpaid();
    }

    function hasPendingPayout() public view returns (bool) {
        return distributor.hasPendingPayout(msg.sender);
    }

    function ownerSetShareholderCustomReward(address shareholder, address rwrd) external onlyOwner {
        distributor.setNewRewardForShareholder(shareholder, rwrd);
    }

    function getShareholderDividendsInfo(address holder) external view returns (
            address,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            address
        ) {
        return distributor.getShareholderInfo(holder);
    }

    function getRewardInfo(address reward) external view returns (
        uint256, address[] memory, uint256, uint256, uint256
    ) {
        return distributor.getRewardInfo(reward);
    }


    ////////////////////////////////////////////////
    // Token locker functionality
    //
    // We allow investors to lock their tokens for an additional % boost on their rewards payout.

    function getMyLockedTokens() external view returns (uint256) {
        return lockedTokens[msg.sender];
    }

    function lockMyTokens(uint256 amount) external {
        // get the balance and check to see if they have enough to lock
        uint256 balance = getActualBalanceOf(msg.sender);
        require(balance >= amount, "You cannot lock that many tokens");

        uint256 currentlyLockedTokensForSender = lockedTokens[msg.sender];

        if(currentlyLockedTokensForSender == 0) {
            // if we have zero locked that means we're a new locker, so, increment
            lockedInvestors += 1;
        }

        uint256 newLockedTokensForSender = currentlyLockedTokensForSender + amount;

        lockedTokens[msg.sender] = newLockedTokensForSender;

        totalLockedTokens += amount;

        distributor.setShare(msg.sender, balance, newLockedTokensForSender);

        emit LockedTokensEvent(amount);
    }

    function unlockAllTokens() external {
        totalLockedTokens -= lockedTokens[msg.sender];
        lockedInvestors -= 1;
        lockedTokens[msg.sender] = 0;
        distributor.setShare(msg.sender, getActualBalanceOf(msg.sender), 0);
    }

    function partialUnlockTokens(uint256 amount) external {
        uint256 currentlylockedTokens = lockedTokens[msg.sender];

        if(currentlylockedTokens < amount) {
            totalLockedTokens -= currentlylockedTokens;
            lockedTokens[msg.sender] = 0;
        } else {
            totalLockedTokens -= amount;
            lockedTokens[msg.sender] -= amount;
        }

        distributor.setShare(msg.sender, getActualBalanceOf(msg.sender), lockedTokens[msg.sender]);
    }

    /**
    * Coinwars is a dapp feature of sensei. In this "mode" two coins are pitted against each other
    * the coint hat generates the most rewards will get an additional buy into their chart from us.
    * Any tokens bought with that buy will be distributed to all investors that have that reward picked
    * as their payout.
    *
    * Steps:
    *  1. Check to ensure the CA has these tokens
    *  2. Pull out all the addresses that have this reward
    *  3. Divide the amount in the CA against 2.
    *  4. Airdrop them
    *
    */
    event CoinwarsDistributedDebugAmnt(uint256 amount);
    event CoinwarsDistString(string message);
    event CoinwarsDistStringAdd(string message, address holder);
    event CoinwarsDistStringBool(string message, bool something);
    event CoinwarsDistStringNum(string message, uint256 num);
    event CoinwarsDistributedDebugShrdRwrd(address loopShareholder, uint loopIndex, bool matchExpected, uint256 winnersCount);
    event CoinwarsDistributedDebugAdrop(address loopWinner, uint256 airdropamount, uint loopIndex);

    function coinwarsPayout(IBEP20 winner) external onlyOwner() {

        require(winner.balanceOf(address(this)) > 0, "This token isnt in the CA");

        address[] memory winners = distributor.getRewardInfoHolders(address(winner));

        uint256 totalAmount = winner.balanceOf(address(this));

        emit CoinwarsDistStringNum("Winners length is", winners.length);
        emit CoinwarsDistStringNum("Total amount is", totalAmount);

        if(winners.length > 0 && totalAmount > winners.length) { // we do the winners.lenth to ensure everyone gets at least 1 token
            uint256 airdropAmount = totalAmount.div(winners.length);
            emit CoinwarsDistStringNum("We have an airdrop and the amount per holder is", airdropAmount);

            // now, somehow i magically do an airdrop for these tokens ....
            for(uint n = 0;n<winners.length;n++) {
                emit CoinwarsDistStringNum("Loop number", n);
                address loopWinner = winners[n];
                emit CoinwarsDistStringAdd("Address of winner", loopWinner);
                winner.transferFrom(address(this), loopWinner, airdropAmount);

                emit CoinwarsDistributedDebugAdrop(loopWinner, airdropAmount, n);
            }
        }

        emit CoinwarsDistributedEvent(address(winner), totalAmount, winners.length);
    }

    function setCWPlayers(address a, address b) external onlyOwner() {
        distributor.setCoinwarsA(a);
        distributor.setCoinwarsB(b);
    }

    function getCWStatus() public view returns (address, address, uint256, uint256) {
        return distributor.getCoinwarsInfo();
    }

    /**
     * Deposit to the distributor
     */
     function rewardDeposit() payable external onlyOwner {
        distributor.deposit{value: msg.value}();
     }
}