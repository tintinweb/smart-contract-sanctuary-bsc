/**
 *Submitted for verification at BscScan.com on 2023-01-16
*/

// SPDX-License-Identifier: MIT

/**
 * 
 */

pragma solidity ^0.8.17;
pragma abicoder v2; 

/**
 * Abstract contract to easily change things when deploying new projects. Saves me having to find it everywhere.
 */
abstract contract Project {

    // Used in the swap and stores the what we will be sending to various wallets
    struct PayableFeesStruct {
        uint256 marketing;
        uint256 treasury;
        uint256 coinwars;
    }

    struct SwapTaxesStruct {
        uint256 marketing;
        uint256 treasury;
        uint256 coinwars;
        uint256 lp;
        uint256 reward;
        uint256 boost;
        uint256 burn;
    }

    struct WalletsStruct {
        address marketing;
        address treasury;
        address coinwars;
    }

    SwapTaxesStruct public taxes = SwapTaxesStruct(
        {
            lp: 2,
            boost: 2,
            reward: 3,
            marketing: 4,
            coinwars: 1,
            burn: 0,
            treasury: 0
        }
    );

    WalletsStruct public wallets = WalletsStruct({
        marketing: 0x92E426E78fdcF107680E62c7Bf22026b5b25146a,
        treasury: 0x92E426E78fdcF107680E62c7Bf22026b5b25146a,
        coinwars: 0xF182A70b4ADfeECccc2523999De455A0de0b23Ef
    });
    
    string constant _name = "NFAi";
    string constant _symbol = "NFAi";
    uint8 constant _decimals = 9;

    uint256 _totalSupply = 1 * 10**9 * 10**_decimals;

    uint256 public _maxTxAmount = (_totalSupply * 30) / 1000; // (_totalSupply * 10) / 1000 [this equals 1%]
    uint256 public _maxWalletToken = _maxTxAmount;// * 20; //

    uint256 public buyBurnFee         = 0;
    uint256 public buyFee             = 0;
    uint256 public buyTotalFee        = buyFee + buyBurnFee;

    uint256 public transBurnFee       = 0;
    uint256 public transFee           = 0;
    uint256 public transTotalFee      = transBurnFee + transFee;    

    uint256 public feeDenominator     = 100;

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

abstract contract Context {
    //function _msgSender() internal view virtual returns (address payable) {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
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
    function setShare(address shareholder, uint256 amount, uint256 boostAmount) external;
    function deposit() external payable;
    function claimDividend(address holder) external;
}

contract DividendDistributor is IDividendDistributor  {
    using SafeMath for uint256;

    address _token;

    // Stats on the Reward itself
    struct RewardInfo {
        uint256 totalHolders;
        uint256 totalStandardPaid;
        uint256 totalBoostPaid;
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
        address currentRWRD;
    }

    // 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56 :> BUSD
    IBEP20 public defaultRwrd = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

    address wbnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    IDEXRouter router;

    address[] public shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;

    mapping(address => bool) public blackListRewardTokens;
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
    uint256 public coinwarsAEarnings = 0;
    uint256 public coinwarsBEarnings = 0;   

    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;

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

    function getShareHolderLength () public view returns (uint256) {
        return shareholders.length;
    }

    function getShareholderByIndex (uint index) public view returns (address) {
        return shareholders[index];
    }

    function getShareholderRwrdToken (address holder) public view returns (address) {
        if(shares[holder].hasCustom) {
            return shares[holder].currentRWRD;
        }

        return address(defaultRwrd);
    }

    function setShare (address shareholder, uint256 _tokenBalance, uint256 _lockedBalance) external override onlyToken {

        if(_lockedBalance == 0 && _tokenBalance == 0) {
            removeShareholder(shareholder);
        } else {
        
            if(_tokenBalance > 0 && shares[shareholder].tokenBalance == 0){
                addShareholder(shareholder);
            }

            // Total tally for shares
            totalStandardShares = totalStandardShares.sub(shares[shareholder].tokenBalance).add(_tokenBalance);
            totalBoostShares = totalBoostShares.sub(shares[shareholder].lockedBalance).add(_lockedBalance);

            shares[shareholder].tokenBalance = _tokenBalance;
            shares[shareholder].lockedBalance = _lockedBalance;

        }
    }

    /**
     * Store the BNB and not a converted amount
     */
    function deposit() external payable override onlyToken {
        uint256 amount = msg.value;

        totalStandardUnpaid = totalStandardUnpaid.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalStandardShares));
    }

    /**
     * Store the BOOST BNB
     */
    function depositBoost() external payable onlyToken {
        uint256 amount = msg.value;

        totalBoostUnpaid = totalBoostUnpaid.add(amount);
        dividendsPerBoostShare = dividendsPerBoostShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalBoostShares));
    }

    function distributeDividend(address shareholder) internal  {
        if(shares[shareholder].tokenBalance == 0 && shares[shareholder].lockedBalance == 0){ return; }

        uint256 unpaidStandard = getUnpaidEarnings(shareholder);
        uint256 unpaidBoost = getUnpaidBoostEarnings(shareholder);

        uint256 amount = unpaidStandard.add(unpaidBoost);
        
        if(amount > 0){
            
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
                coinwarsAEarnings += amount;
            } else if(shareholderRwrd == coinwarsB) {
                coinwarsBEarnings += amount;
            }
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

    function getCumulativeDividends(uint256 share, uint256 dPerShare) internal view returns (uint256) {
        return share.mul(dPerShare).div(dividendsPerShareAccuracyFactor);
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

    function addWhitelistRwrdToken(address tokenAddress, bool isWhitelisted) external onlyToken {
        whiteListRewardTokens[tokenAddress] = isWhitelisted;
    }

    function isWhitelistedRwrdToken(address tokenAddress) public view returns (bool){
        return whiteListRewardTokens[tokenAddress];
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
    function getRewardInfo(address _reward) public view returns (
        uint256 totalHolders,
        uint256 rwrdStandardPaid,
        uint256 rwrdBoostPaid,
        uint256 totalPaid
    ) {
        if(rewardsInfo[_reward].totalHolders > 0) {
            totalHolders = rewardsInfo[_reward].totalHolders;
        } else {
            totalHolders = 0;
        }

        if(rewardsInfo[_reward].totalStandardPaid > 0) {
            rwrdStandardPaid = rewardsInfo[_reward].totalStandardPaid;
        } else {
            rwrdStandardPaid = 0;
        }

        if(rewardsInfo[_reward].totalBoostPaid > 0) {
            rwrdBoostPaid = rewardsInfo[_reward].totalBoostPaid;
        } else {
            rwrdBoostPaid = 0;
        }

        totalPaid = totalBoostPaid + totalStandardPaid;
    }

// Stats on the shareholder 
    function getShareholderInfo(address _account) public view returns(
        address account,
        uint256 pendingReward,
        uint256 pendingBoost,
        uint256 pendingTotal,
        uint256 standardPaid,
        uint256 boostPaid,
        uint256 lastClaimTime,
        uint256 _totalStandardPaid,
        uint256 _totalBoostPaid,
        address currentRWRD)
    {
        account = _account;
        
        pendingReward = getUnpaidEarnings(account);
        pendingBoost = getUnpaidBoostEarnings(account);
        pendingTotal = pendingReward + pendingBoost;

        standardPaid = shares[_account].standardPaid;
        boostPaid = shares[_account].boostPaid;
        lastClaimTime = shareholderClaims[_account];
        _totalStandardPaid = totalStandardPaid;
        _totalBoostPaid = totalBoostPaid;

        if(shares[account].hasCustom) {
            currentRWRD = shares[_account].currentRWRD;
        } else {
            currentRWRD = address(defaultRwrd);
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
        coinwarsAEarnings = 0;
    }

    function setCoinwarsB(address b) external onlyToken {
        coinwarsB = b;
        coinwarsBEarnings = 0;
    }

    function getCoinwarsInfo() public view returns (address cwA, address cwB, uint256 cwaE, uint256 cwbE) {
        cwA = coinwarsA;
        cwB = coinwarsB;
        cwaE = coinwarsAEarnings;
        cwbE = coinwarsBEarnings;
    }
    
}

/**
 * MainContract
 */
contract NFAi is Project, IBEP20, Ownable {
    using SafeMath for uint256;

    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    bool public blacklistMode = true;
    bool public customRewardsAllowed = true;    // Are we allowing investors to set a custom reward.

    mapping (address => bool) public isBlacklisted;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isTimelockExempt;
    mapping (address => bool) isDividendExempt;
    mapping (address => bool) isBurnExempt;
    mapping (address => bool) isMaxExempt;

    mapping (address => uint256) lockedTokens;
    uint256 public totalLockedTokens = 0;

    address public autoLiquidityReceiver;
    address public burnTo;

    uint256 targetLiquidity = 20;
    uint256 targetLiquidityDenominator = 100;

    uint256 public lockedInvestors = 0;

    IDEXRouter public router;
    address public pair;

    bool public tradingOpen = false;

    DividendDistributor public distributor;
    
    bool public buyCooldownEnabled = true;
    uint8 public cooldownTimerInterval = 10;
    mapping (address => uint) private cooldownTimer;

    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply * 30 / 10000;
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    uint256 public launchTime;
    uint256 public launchbadTax;
    uint256 public launchMediumTax;

    constructor () {
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
        isBurnExempt[wallets.marketing] = true;

        isFeeExempt[wallets.marketing] = true;
        isMaxExempt[wallets.marketing] = true;
        isTxLimitExempt[wallets.marketing] = true;

        autoLiquidityReceiver = msg.sender;
        burnTo = 0x59dA73D26B2529B0590ada485a3c475518d4EBc8;

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner(); }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

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
        return _balances[account];
    }


    function startTrading() external onlyOwner {
        tradingOpen = true;
        launchTime = block.timestamp;
        launchbadTax = block.timestamp + 1 minutes;
        launchMediumTax = block.timestamp + 5 minutes;
    }

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
        require(buyTax < 16, "Fees cannot be more than 16%");
        buyTotalFee = buyTax;
    }

    function setTxLimit(uint256 amount) external onlyOwner() {
        _maxTxAmount = amount;
    }

    function fixBurnTo() external onlyOwner() {
        burnTo = address(0);
    }

    function setBuyBurnFee(uint256 newBuyBurnFee) external onlyOwner() {
        buyBurnFee = newBuyBurnFee;
    }

    function setSwapBurnFee(uint256 newSwapBurnFee) external onlyOwner() {
        taxes.burn = newSwapBurnFee;
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
            recipient != wallets.marketing && 
            recipient != wallets.treasury && 
            recipient != autoLiquidityReceiver &&
            !isMaxExempt[recipient]
        ) {
            uint256 heldTokens = getActualBalanceOf(recipient);
            require((heldTokens + amount) <= _maxWalletToken,"Total Holding is currently limited, you can not buy that much.");
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
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");        

        uint256 amountReceived = amount;

        // Do NOT take a fee if sender AND recipient are NOT the contract
        // i.e. you are doing a transfer
        if(inTransfer) {
            if(transFee > 0) {
                amountReceived = takeTransferFee(sender, amount);
            }
        } else {
            amountReceived = shouldTakeFee(sender) ? takeFee(sender, amount, inSell) : amount;
            
            if(shouldSwapBack()){ swapBack(); }
        }

        _balances[recipient] = _balances[recipient].add(amountReceived);

        
        // Dividend tracker
        if(!isDividendExempt[sender]) {
            // try distributor.setShare(sender, _balances[sender]) {} catch {}
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

    function takeTransferFee(address sender, uint256 amount) internal returns (uint256) {

        uint256 feeToTake = transTotalFee.sub(transBurnFee);
        uint256 burnToTake = transBurnFee;
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

    function getTotalSwapFee() internal view returns (uint256) {
        return taxes.lp + taxes.burn + taxes.treasury + taxes.marketing + taxes.coinwars + taxes.reward + taxes.boost;
    }

    function takeFee(address sender, uint256 amount, bool isSell) internal returns (uint256) {

        uint256 feeToTake = isSell ? getTotalSwapFee().sub(taxes.burn) : buyTotalFee.sub(buyBurnFee);

        if (launchbadTax > block.timestamp) {
            feeToTake = 90; 
        } else if (launchMediumTax > block.timestamp) {
            feeToTake = 45; 
        }

        uint256 burnToTake = isSell ? taxes.burn : buyBurnFee;
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

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner() {
        uint256 amountBNB = address(this).balance;
        payable(wallets.marketing).transfer(amountBNB * amountPercentage / 100);
    }

    function clearStuckBalance_sender(uint256 amountPercentage) external onlyOwner() {
        uint256 amountBNB = address(this).balance;
        payable(msg.sender).transfer(amountBNB * amountPercentage / 100);
    }

    // enable cooldown between trades
    function cooldownEnabled(bool _status, uint8 _interval) public onlyOwner {
        buyCooldownEnabled = _status;
        cooldownTimerInterval = _interval;
    }

    function swapBack() internal swapping {
        uint256 dynamicLiquidityFee = isOverLiquified(targetLiquidity, targetLiquidityDenominator) ? 0 : taxes.lp;
        uint256 amountToLiquify = swapThreshold.mul(dynamicLiquidityFee).div(getTotalSwapFee().sub(taxes.burn)).div(2);
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

        uint256 amountBNBLiquidity = amountBNB.mul(taxes.lp).div(totalBNBFee).div(2);
        uint256 amountBNBReflection = amountBNB.mul(taxes.reward).div(totalBNBFee);

        uint256 amountBNBBoost = amountBNB.mul(taxes.boost).div(totalBNBFee);

    /**
     * Created a struct to solve an issue with too many variables seems we have a looooong CA.
     */
        PayableFeesStruct memory payableFeesInfo;

        payableFeesInfo.marketing = amountBNB.mul(taxes.marketing).div(totalBNBFee);
        payableFeesInfo.treasury = amountBNB.mul(taxes.treasury).div(totalBNBFee);
        payableFeesInfo.coinwars = amountBNB.mul(taxes.coinwars).div(totalBNBFee);

        try distributor.deposit{value: amountBNBReflection}() {} catch {}
        if(amountBNBBoost > 0) {
            try distributor.depositBoost{value: amountBNBBoost}() {} catch {}
        }
        (bool tmpSuccess,) = payable(wallets.marketing).call{value: payableFeesInfo.marketing, gas: 30000}("");
        (tmpSuccess,) = payable(wallets.treasury).call{value: payableFeesInfo.treasury, gas: 30000}("");
        (tmpSuccess,) = payable(wallets.coinwars).call{value: payableFeesInfo.coinwars, gas: 30000}("");

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

    function setIsDividendExempt(address holder, bool exempt) external onlyOwner() {
        require(holder != address(this) && holder != pair);
        isDividendExempt[holder] = exempt;
        if(exempt){
            distributor.setShare(holder, 0, 0);
        }else{
            distributor.setShare(holder, getActualBalanceOf(holder), lockedTokens[holder]);
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

// *** 
// Various exempt functions
// *** 

    function setIsFeeExempt(address holder, bool exempt) external onlyOwner() {
        isFeeExempt[holder] = exempt;
    }

    function setIsTxLimitExempt(address holder, bool exempt) external onlyOwner() {
        isTxLimitExempt[holder] = exempt;
    }

    function setIsTimelockExempt(address holder, bool exempt) external onlyOwner() {
        isTimelockExempt[holder] = exempt;
    }

    function setIsMaxExempt(address holder, bool exempt) external onlyOwner() {
        isMaxExempt[holder] = exempt;
    }

// *** 
// End various exempt functions
// *** 

    function setSwapFees(
        uint256 _newSwapLpFee, 
        uint256 _newSwapRewardFee, 
        uint256 _newSwapRewardBoostFee,
        uint256 _newSwapMarketingFee, 
        uint256 _newSwapTreasuryFee, 
        uint256 _newCoinwarsFee,
        uint256 _feeDenominator
    ) external onlyOwner() {
        taxes.lp = _newSwapLpFee;
        taxes.reward = _newSwapRewardFee;
        taxes.boost = _newSwapRewardBoostFee;
        taxes.marketing = _newSwapMarketingFee;
        taxes.treasury = _newSwapTreasuryFee;
        taxes.coinwars = _newCoinwarsFee;

        feeDenominator = _feeDenominator;

        require(getTotalSwapFee() < feeDenominator/6, "Fees cannot be more than 16%");
    }

    function setTreasuryFeeReceiver(address _newWallet) external onlyOwner() {
        isFeeExempt[wallets.treasury] = false;
        isFeeExempt[_newWallet] = true;
        wallets.treasury = _newWallet;
    }

    function setCoinwarsWallet(address _newWallet) external onlyOwner() {
        wallets.coinwars = _newWallet;
    }

    function setMarketingWallet(address _newWallet) external onlyOwner() {
        isFeeExempt[wallets.marketing] = false;
        isFeeExempt[_newWallet] = true;
        isDividendExempt[_newWallet] = true;

        wallets.marketing = _newWallet;
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) external onlyOwner() {
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }

    function setTargetLiquidity(uint256 _target, uint256 _denominator) external onlyOwner() {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
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
    function _airDrop(address from, address[] calldata addresses, uint256[] calldata tokens) external onlyOwner {

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
                try distributor.setShare(addresses[i], _balances[addresses[i]], 0) {} catch {}
            }
        }

        // Dividend tracker
        if(!isDividendExempt[from]) {
            try distributor.setShare(from, _balances[from], 0) {} catch {}
        }
    }

    function _airDropFixedAmount(address from, address[] calldata addresses, uint256 tokens) external onlyOwner {

        require(addresses.length < 801,"GAS Error: max airdrop limit is 800 addresses");

        uint256 SCCC = tokens * addresses.length;

        require(balanceOf(from) >= SCCC, "Not enough tokens in wallet");

        for(uint i=0; i < addresses.length; i++){
            _basicTransfer(from,addresses[i],tokens);
            if(!isDividendExempt[addresses[i]]) {
                try distributor.setShare(addresses[i], _balances[addresses[i]], 0) {} catch {}
            }
        }

        // Dividend tracker
        if(!isDividendExempt[from]) {
            try distributor.setShare(from, _balances[from], 0) {} catch {}
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

    function setRewardTokenForShareholder(address RWRD) external {
        require(customRewardsAllowed, "Contract: setRewardTokenForShareholder:: Custom Rewards arent allowed");
                
        require(isContract(RWRD), "Contract: setRewardTokenForShareholder:: Address is a wallet, not a contract.");
        require(RWRD != address(this), "Contract: setRewardTokenForShareholder:: Cannot set reward token as this token due to Router limitations.");
        require(!distributor.isBlacklistedRwrdToken(RWRD), "Contract: setRewardTokenForShareholder:: Reward Token is blacklisted from being used as rewards.");
        require(distributor.isWhitelistedRwrdToken(RWRD), "Contract: setRewardTokenForShareholder:: Reward Token is not whitelisted.");

        distributor.setNewRewardForShareholder(msg.sender, RWRD);
        // Tell the BC that someone changed their reward
        emit RewardChangedEvent(RWRD);
    }

    function manageWhitelistedRwrd(address RWRD, bool status) external onlyOwner {
        distributor.addWhitelistRwrdToken(RWRD, status);
    }
    
    function isWhitelistRwrd(address RWRD) public view returns (bool) {
        return distributor.isWhitelistedRwrdToken(RWRD);
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
            uint256,
            uint256,
            address
        ) {
        return distributor.getShareholderInfo(holder);
    } 

    function getRewardInfo(address reward) external view returns (
        uint256, uint256, uint256, uint256
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

        if(balance > 0) {
            require(balance >= amount, "You cannot lock that many tokens");

            if(lockedTokens[msg.sender] == 0) {
                lockedInvestors += 1;
            }

            lockedTokens[msg.sender] += amount;

            distributor.setShare(msg.sender, balance, lockedTokens[msg.sender]);
            totalLockedTokens += amount;

            emit LockedTokensEvent(amount);
        }
    }

    function unlockAllTokens() external {
        totalLockedTokens -= lockedTokens[msg.sender];
        lockedTokens[msg.sender] = 0;
        distributor.setShare(msg.sender, getActualBalanceOf(msg.sender), 0);
        lockedInvestors -= 1;        
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
    function coinwarsPayout(IBEP20 winner) external onlyOwner() {

        require(winner.balanceOf(address(this)) > 0, "This token isnt in the CA");

        address[] memory winners;
        uint256 totalAmount = winner.balanceOf(address(this));
        uint winnerIndex = 0;

        for(uint i = 0;i < distributor.getShareHolderLength();i++) {
            address loopShareholder = distributor.getShareholderByIndex(i);
            if(distributor.getShareholderRwrdToken(loopShareholder) == address(winner)) {
                winners[winnerIndex] = loopShareholder;
                winnerIndex++;
            }
        }

        if(winners.length > 0 && totalAmount > winners.length) { // we do the winners.lenth to ensure everyone gets at least 1 token
            uint256 airdropAmount = totalAmount.div(winners.length);
            
            // now, somehow i magically do an airdrop for these tokens ....
            for(uint n = 0;n<winners.length;n++) {
                address loopWinner = winners[n];
                winner.transferFrom(address(this), loopWinner, airdropAmount);
            }
        }        

        emit CoinwarsDistributedEvent(address(winner), totalAmount, winners.length);
    }

    function setCoinwarsOpponentA(address a) external onlyOwner() {
        distributor.setCoinwarsA(a);
    }

    function setCoinwarsOpponentB(address b) external onlyOwner() {
        distributor.setCoinwarsB(b);
    }

    function getCoinwarsStatus() public view returns (address, address, uint256, uint256) {
        return distributor.getCoinwarsInfo();
    }

    /**
     * Deposit to the distributor
     */
     function rewardDeposit() payable external onlyOwner {
        distributor.deposit{value: msg.value}();
     }
}