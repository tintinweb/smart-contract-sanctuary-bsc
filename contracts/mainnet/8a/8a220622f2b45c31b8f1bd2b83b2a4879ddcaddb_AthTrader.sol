/**
 *Submitted for verification at BscScan.com on 2022-08-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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

// Link to bep20 token smart contract
interface IBEP20Token {
    // Transfer tokens on behalf
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool success);

    // Transfer tokens
    function transfer(
        address to,
        uint256 value
    ) external returns (bool success);

    // Approve tokens for spending
    function approve(address spender, uint256 amount) external returns (bool);

    // Returns user balance
    function balanceOf(address user) external view returns(uint256 value);

    //Returns token Decimals
    function decimals() external view returns (uint256);
}

// Link to AthSatking contract
interface IATHLEVEL {
    // Returns ath level of given address
    function athLevel(address user) external view returns(uint256 level);
}

// Link to router contract
interface IROUTER {
    // Swap tokens
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

// Link to pair contract
interface IPAIR {
    // Return token0 address of pair
    function token0() external view returns (address);

    // Return token1 address of pair
    function token1() external view returns (address);
}

/**
 * @title AthenaBank trader contract Version 1.0
 *
 * @author AthenaBank
 */
contract AthTrader {
    using SafeMath for uint256;

    // Address of AthTrader owner
    address public owner;

    // Address of AthStaking contract
    address public immutable athLevel;

    // Address of trader account
    address public trader;

    // Address of BinanaceAPI account
    address public binanceAPI;

    // Trader fee defined in percentage
    uint8 public traderFee;

    // Status of emergency withdraw
    bool public isEmergencyWithdrawlEnabled;

    // Address of participation token contract
    address public participationToken;

    // Funding start time defined in timestamp
    uint256 public fundingStartTime;

    // Funding period defined in seconds
    uint256 public fundingPeriod;

    // Trading period defined in seconds
    uint256 public tradingPeriod;

    // Claiming period defined in seconds
    uint256 public claimingPeriod;

    // Benchmark for total funding amount
    uint256 public fundingCap;

    // Minimum contribution required to participate in funding round
    uint256 public minContribution;

    // Total invested amount of participated token
    uint256 public totalInvestment;

    // Total amount of participated token Post trading Period
    uint256 public concludedTotalAmount;

    // Reward rate for calculating harvested amount
    uint256 public rewardRate;

    // bool check to verify contract is concluded or not
    bool public isTradingContractConcluded;

    // traded token array
    address[] public tradedToken;

    /**
     * @dev Returns fee in percentage for given level
     */
    mapping(uint8 => uint8) public athLevelFee;

    /**
     * @dev Returns true if given address is allowed for trading
     */
    mapping(address => bool) public allowedV2PairsAndRouters;

    /**
     * @dev Returns invested amount for given address
     */
    mapping(address => uint256) public investedAmount;

    /**
     * @dev Returns claimed amount of given address
     */
    mapping(address => uint256) public userClaimedAmount;

    /**
     * @dev Returns traded Token index of array
     */
    mapping(address => uint256) public tradedTokenMap;

    /**
     * @dev Returns referrer  of given address
     */
    mapping(address => address) public referrer ;

    /**
     * @dev Returns referrerFee in percentage  of given level
     */
    mapping(uint8 => uint8) public referrerFeeFromLevel;



    /**
	 * @dev Fired in transferOwnership() when ownership is transferred
	 *
	 * @param previousOwner an address of previous owner
	 * @param newOwner an address of new owner
	 */
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
	 * @dev Fired in setBinanaceAPI() when API address is updated by an owner
	 *
	 * @param previousAPI an address of previous API
	 * @param newAPI an address of new API
	 */
    event UpdateAPI(address previousAPI, address newAPI);

    /**
	 * @dev Fired in addToAllowed() and removeFromAllowed() when address is added into/removed from
     *      allowedV2PairsAndRouters
	 *
	 * @param pairOrRouter an address of pair or router contract
	 * @param isAllowed defines if address is added or removed
	 */
    event Allowed(address pairOrRouter, bool isAllowed);

    /**
	 * @dev Fired in setAthLevelFee() when fee is set by an owner
	 *
	 * @param level index of level for which fee is set
	 * @param fee fee in percentage for given level
	 */
    event SetFee(uint8 level, uint8 fee);

    /**
	 * @dev Fired in recoverToken() when tokens are recovered by an owner
	 *
	 * @param token address of token to recover
	 * @param amount number of tokens to recover
	 */
    event Recover(address token, uint256 amount);

    /**
	 * @dev Fired in recoverContract() when contract value is recovered by an owner
	 *
	 * @param amount value of the contract recovered
	 */
    event RecoverValue(uint256 amount);

    /**
	 * @dev Fired in invest() when tokens are invested by user
	 *
	 * @param investor address of investor
	 * @param amount number of tokens invested
	 */
    event Investment(address indexed investor, uint256 amount);

    /**
	 * @dev Fired in withdraw() and emergencyWithdraw() when tokens are withdrawn by user
	 *
	 * @param investor address of an investor
	 * @param amount number of tokens withdrawn
     * @param isEmergencyWithdrawl true if fired in emergencyWithdraw()
	 */
    event WithdrawInvestment(address indexed investor, uint256 amount, bool isEmergencyWithdrawl);

    /**
	 * @dev Fired in swap() when tokens are swapped by a trader or binanceAPI
	 *
	 * @param executor address of an executor
	 * @param router address of router
     * @param pair address of pair linked to given router
     * @param amountIn amount of input tokens to send
     * @param amountOutMin minimum amount of output tokens that must be received
     * @param deadline unix timestamp after which the transaction will revert
     * @param flow direction of swap (from token0 to token1 -> "true", from token1 to token0 -> "false")
	 */
    event Swap(address indexed executor, address router, address pair, uint amountIn, uint amountOutMin, uint deadline, bool flow);

    /**
	 * @dev Fired in harvestReward() tokens are harvested by user
	 *
	 * @param investor address of an investor
	 * @param amount number of tokens harvested
     * @param fee number of tokens paid as fee
	 */
    event Harvest(address indexed investor, uint256 amount, uint256 fee);

    /**
	 * @dev Fired in harvestReward() tokens are transferred to referrer
	 *
	 * @param referee address of an investor
	 * @param amount number of tokens transferred
     * @param referrer number of tokens paid as fee
	 */
    event ReferralPaid(address indexed referee, uint256 amount, address indexed referrer);

    /**
	 * @dev Fired in setReferrerFeeFromLevel() when fee is set by an owner
	 *
	 * @param level index of level for which fee is set
	 * @param fee fee in percentage for given level
	 */
    event SetReferrerFee(uint8 level, uint8 fee);


    /**
	 * @dev Creates/deploys AthenaBank trading contract Version 1.0
	 *
	 * @param athStaking_ address of AthStaking smart contract
	 */
    constructor(address athStaking_) {
        // Setup smart contract internal state
        owner = msg.sender;
        athLevel = athStaking_;
    }

    // To check if accessed by an owner
    modifier onlyOwner() {
        isOwner();
        _;
    }

    // To check if accessed by a trader
    modifier onlyTrader() {
        require(trader == msg.sender, "Not a trader");
        _;
    }

    // To check if accessed by an owner or a tarder
    modifier traderOrOwner() {
        require(trader == msg.sender || owner == msg.sender, "Invalid access");
        _;
    }

    // To check if accessed by a trader or a binanceAPI
    modifier traderOrAPI() {
        require(trader == msg.sender || binanceAPI == msg.sender, "Invalid access");
        _;
    }

    /**
	 * @dev Transfer ownership to given address
	 *
	 * @notice restricted function, should be called by owner only
	 * @param newOwner_ address of new owner
	 */
    function transferOwnership(address newOwner_) external onlyOwner {
        // Update owner address
        owner = newOwner_;

        // Emit an event
        emit OwnershipTransferred(msg.sender, newOwner_);
    }

    /**
	 * @dev Initializes trading contract parameters
	 *
	 * @notice restricted function, should be called by owner only
	 * @param trader_ address of a trader
     * @param startTime_ unix timestamp after which funding period will start
     * @param fundingPeriodInSeconds_ funding period defined in seconds
     * @param tradingPeriodInSeconds_ trading period defined in seconds
     * @param claimingPeriodInSeconds_ claiming Period defined in seconds
     * @param participationToken_ address of participation token contract
     * @param traderFee_ trader fee defined in terms of percentage
     * @param fundingCap_ benchmark for token amount to be raised
     * @param minContribution_ minimum contribution required to participate in funding round
	 */
    function initializeRound(
        address trader_,
        uint256 startTime_,
        uint256 fundingPeriodInSeconds_,
        uint256 tradingPeriodInSeconds_,
        uint256 claimingPeriodInSeconds_,
        address participationToken_,
        uint8 traderFee_,
        uint256 fundingCap_,
        uint256 minContribution_
    ) external onlyOwner {

        require(fundingStartTime == 0, "Active round");
        require(claimingPeriodInSeconds_ >= 60 days, "Invalid claiming period");

        // Setup smart contract internal state
        trader = trader_;
        fundingStartTime = startTime_;
        fundingPeriod = fundingPeriodInSeconds_;
        tradingPeriod = tradingPeriodInSeconds_;
        claimingPeriod = claimingPeriodInSeconds_;
        traderFee = traderFee_;
        participationToken = participationToken_;
        fundingCap = fundingCap_;
        minContribution = minContribution_;
    }

    /**
	 * @dev Sets binanceAPI address
	 *
	 * @notice restricted function, should be called by owner only
	 * @param api_ address of binanace API account
	 */
    function setBinanceAPI(
        address api_
    ) external onlyOwner {
        // Emit an event
        emit UpdateAPI(binanceAPI, api_);

        // Update API
        binanceAPI = api_;
    }

    /**
	 * @dev Adds router/pair address to allowed list
	 *
	 * @notice restricted function, should be called by owner only
	 * @param allowed_ address list of router/pair
	 */
    function addToAllowed(
        address[] memory allowed_
    ) external onlyOwner {
        for(uint8 i; i < allowed_.length; i++) {
            // Add address to the list
            allowedV2PairsAndRouters[allowed_[i]] = true;

            // Emit an event
            emit Allowed(allowed_[i], true);
        }
    }

    /**
	 * @dev Removes router/pair address from allowed list
	 *
	 * @notice restricted function, should be called by owner only
	 * @param notAllowed_ address of router/pair
	 */
    function removeFromAllowed(
        address[] memory notAllowed_
    ) external onlyOwner {
        for(uint8 i; i < notAllowed_.length; i++) {
            // Remove address from the list
            allowedV2PairsAndRouters[notAllowed_[i]] = false;

            // Emit an event
            emit Allowed(notAllowed_[i], false);
        }
    }

    /**
	 * @dev Enables/disables emergency withdraw
	 *
	 * @notice restricted function, should be called by owner only
	 */
    function emergencyWithdrawSwitch() external onlyOwner {
        // Trigger emergency withdraw switch
        isEmergencyWithdrawlEnabled = !isEmergencyWithdrawlEnabled;
    }

    /**
	 * @dev Sets fee for given level
	 *
	 * @notice restricted function, should be called by owner only
	 * @param level_ index of level
     * @param fee_ fee defined in percentage for given level
	 */
    function setAthLevelFee(
        uint8[] memory level_,
        uint8[] memory fee_
    ) external onlyOwner {
        require(level_.length == fee_.length, "Invalid input");

        for(uint8 i; i < level_.length; i++) {
            // Record fee for given level
            athLevelFee[level_[i]] = fee_[i];

            // Emit an event
            emit SetFee(level_[i], fee_[i]);
        }
    }

    /**
 * @dev Sets fee for given level
	 *
	 * @notice restricted function, should be called by owner only
	 * @param level_ index of level
     * @param fee_ fee defined in percentage for given level
	 */
    function setReferrerFeeFromLevel(
        uint8[] memory level_,
        uint8[] memory fee_
    ) external onlyOwner {
        require(level_.length == fee_.length, "Invalid input");

        for(uint8 i; i < level_.length; i++) {
            // Record fee for given level
            referrerFeeFromLevel[level_[i]] = fee_[i];

            // Emit an event
            emit SetReferrerFee(level_[i], fee_[i]);
        }
    }

    /**
	 * @dev Recovers tokens from the contract
	 *
	 * @notice restricted function, should be called by owner only
	 * @param token_ address of token to recover
     * @param amount_ number of tokens to recover
	 */
    function recoverToken(address token_, uint256 amount_) external onlyOwner {

        require(block.timestamp > fundingStartTime + fundingPeriod + tradingPeriod + claimingPeriod, "Claiming Period is not yet over!!!");

        // Transfer tokens to the owner
        IBEP20Token(token_).transfer(msg.sender, amount_);

        // Emit an event
        emit Recover(token_, amount_);
    }

    /**
	 * @dev Recovers value from the contract
	 *
	 * @notice restricted function, should be called by owner only
	 */
    function recoverContract() external onlyOwner {

        require(block.timestamp > fundingStartTime + fundingPeriod + tradingPeriod + claimingPeriod,  "Claiming Period is not yet over!!!");

        // Contract value to send
        uint256 _value = address(this).balance;

        // Verify balance is positive (non-zero)
        require(_value > 0, "zero balance");

        // Transfer value to the owner
        payable(msg.sender).transfer(_value);

        // Emit an event
        emit RecoverValue(_value);
    }


    /**
	 * @dev Ends funding period earlier if funding cap is reached
     *
     * @notice restricted function, should be called by owner or trader only
     */
    function concludeFundingPeriod() external traderOrOwner {
        require(isFundingActive(), "Inactive funding");

        require(totalInvestment >= fundingCap, "Cap not reached");

        // Decrease funding period time
        fundingPeriod = block.timestamp.sub(fundingStartTime);
    }

    /**
	 * @dev Ends trading contract and set reward rate
     *
     * @notice restricted function, should be called by owner or trader only
     * @param forceConclude pass true to forceConclude without verifing traded token conversion
     *                      only owner can forceConclude, trader can't
     */
    function concludeTradingContract(
        bool forceConclude
    ) external traderOrOwner {
        require(isRewardActive(), "Inactive reward");

        require(!isTradingContractConcluded, "Trading contract is already concluded!!!");

        require((owner == msg.sender && forceConclude) || isTradedTokenConverted(), "Yet to convert traded token!!!");

        // set final concluded participation token amount
        concludedTotalAmount = IBEP20Token(participationToken).balanceOf(address(this));
        // Set reward rate based on participation token balance
        rewardRate = concludedTotalAmount.mul(1e9).div(totalInvestment);
        // conclude trading contract
        isTradingContractConcluded = true;
    }

    /**
	 * @dev Ends trading period earlier
     *
     * @notice restricted function, should be called by owner or trader only
     */
    function concludeTradingPeriod() external traderOrOwner {
        require(isTradingActive(), "Inactive trading");

        // Decrease trading period time
        tradingPeriod = block.timestamp.sub(fundingStartTime.add(fundingPeriod));
    }

    /**
	 * @dev Returns true if funding is active
	 */
    function isFundingActive() public view returns(bool) {
        return (block.timestamp >= fundingStartTime) &&
        (block.timestamp < fundingStartTime + fundingPeriod);
    }

    /**
	 * @dev Returns true if trading is active
	 */
    function isTradingActive() public view returns(bool) {
        return (block.timestamp >= fundingStartTime + fundingPeriod) &&
        (block.timestamp < fundingStartTime + fundingPeriod + tradingPeriod) &&
        totalInvestment >= fundingCap;
    }

    /**
	 * @dev Returns array of trader token
	 */
    function getTradedTokenList() external view returns(address[] memory) {
        return tradedToken;
    }

    /**
	 * @dev Returns traded token list
	 */
    function isRewardActive() public view returns(bool) {
        return (block.timestamp > fundingStartTime + fundingPeriod + tradingPeriod) &&
        totalInvestment >= fundingCap;
    }

    /**
	 * @dev Returns true if all traded token is converted back to participation token
     *
     */
    function isTradedTokenConverted() public view returns(bool) {
        for (uint256 i = 0; i < tradedToken.length; i++) {
            // "10 ** (IBEP20Token(tradedToken[i]).decimals().sub(4))" is equivalent to 0.0001 token
            if (IBEP20Token(tradedToken[i]).balanceOf(address(this)) > 10 ** (IBEP20Token(tradedToken[i]).decimals().sub(4))) {
                return false;
            }
        }
        return true;
    }

    /**
	 * @dev Returns true if funding is active for given level
     *
     * @param level_ index of level
	 */
    function isFundingActiveForAthLevel(
        uint8 level_
    ) public view returns(bool) {
        uint256 lockPeriod = fundingPeriod.div(4);

        if (level_ == 0) {
            return (block.timestamp >= fundingStartTime.add(lockPeriod.mul(3)));
        } else if (level_ == 1) {
            return (block.timestamp >= fundingStartTime.add(lockPeriod.mul(2)));
        } else if (level_ == 2) {
            return (block.timestamp >= fundingStartTime + lockPeriod);
        } else if (level_ == 3) {
            return (block.timestamp >= fundingStartTime);
        } else {
            return false;
        }
    }

    /**
	 * @dev Invests participation tokens to the contract
     *
     * @param amount_ number of tokens to invest
     * @param referrer_ referrer wallet address
	 */
    function invest(
        uint256 amount_,
        address referrer_
    ) external {
        require(investedAmount[msg.sender] + amount_ >= minContribution, "Invalid amount");

        require(isFundingActive(), "Inactive funding");

        // Get level index
        uint8 _level = uint8(IATHLEVEL(athLevel).athLevel(msg.sender));

        require(trader == msg.sender || isFundingActiveForAthLevel(_level), "Inactive for level");

        // Transfer tokens to AthTrader contract
        IBEP20Token(participationToken).transferFrom(msg.sender, address(this), amount_);

        // Record invested amount of given address
        investedAmount[msg.sender] += amount_;

        // Record total investment amount
        totalInvestment += amount_;

        // record referrer address, if any
        if (referrer_ != address(0)) {
            referrer[msg.sender] = referrer_;
        }

        // Emit an event
        emit Investment(msg.sender, amount_);
    }

    /**
	 * @dev Allows to withdraw invested tokens if emergency withdraw is enabled by an owner
     */
    function emergencyWithdraw() external {
        require(isEmergencyWithdrawlEnabled, "Withdrawl disabled");

        require(userClaimedAmount[msg.sender] == 0, "Already Withdrawen!!");

        // Get invested amount of given address
        uint256 _amount = investedAmount[msg.sender];

        // update claimed amount
        userClaimedAmount[msg.sender] = _amount;

        // Transfer invested amount to given address
        IBEP20Token(participationToken).transfer(msg.sender, _amount);

        // Emit an event
        emit WithdrawInvestment(msg.sender, _amount, true);
    }

    /**
	 * @dev Allows to withdraw invested tokens if funding cap is not reached at the end of funding period
     */
    function withdraw() external {
        require(
            (block.timestamp >= fundingStartTime + fundingPeriod) && (totalInvestment < fundingCap),
            "Withdrawl disabled"
        );

        require(investedAmount[msg.sender] > 0, "No investment");

        // Get invested amount of given address
        uint256 _amount = investedAmount[msg.sender];

        // Transfer invested amount to given address
        IBEP20Token(participationToken).transfer(msg.sender, _amount);

        // Remove invested amount data for given address
        delete investedAmount[msg.sender];

        // Emit an event
        emit WithdrawInvestment(msg.sender, _amount, false);
    }

    /**
	 * @dev Harvests rewards after trading period gets over
     */
    function harvestReward() external {
        require(isRewardActive(), "Inactive reward");

        require(investedAmount[msg.sender] > 0, "No investment");

        require(userClaimedAmount[msg.sender] == 0, "Already Harvested!!");

        require(isTradingContractConcluded, "Trading contract is not concluded yet!!!");

        require(block.timestamp <= fundingStartTime + fundingPeriod + tradingPeriod + claimingPeriod, "Claiming Period is over!!!");

        // Calculate reward amount
        uint256 _rewardAmount = investedAmount[msg.sender].mul(rewardRate).div(1e9);

        // Calculate fee on profitable amount
        uint256 _fee = (_rewardAmount <= investedAmount[msg.sender]) ? 0
        : calculateFee(_rewardAmount.sub(investedAmount[msg.sender]));

        // fee is not applicable to trader wallet
        if (trader == msg.sender) {
            _fee = 0;
        }
        // Transfer harvested amount to given address
        IBEP20Token(participationToken).transfer(msg.sender, _rewardAmount.sub(_fee));

        // Check if fee is non zero
        if(_fee > 0) {

            // Initialize referrer fee
            uint256 _referrerFee = 0;

            // Calculate referral fee
            if (referrer[msg.sender] != address(0)) {
                _referrerFee = _fee.mul(referrerFeeFromLevel[uint8(IATHLEVEL(athLevel).athLevel(referrer[msg.sender]))]).div(100);
                // Transfer referral fee to referrer
                IBEP20Token(participationToken).transfer(referrer[msg.sender], _referrerFee);
                emit ReferralPaid(msg.sender, _referrerFee, referrer[msg.sender]);
            }

            // Calculate trader fee
            uint256 _traderFee = _fee.mul(traderFee).div(100);
            // Transfer owner share to owner account
            IBEP20Token(participationToken).transfer(owner, _fee.sub(_traderFee).sub(_referrerFee));

            // Transfer trader fee to trader account
            IBEP20Token(participationToken).transfer(trader, _traderFee);
        }

        // update claimed amount
        userClaimedAmount[msg.sender] = _rewardAmount.sub(_fee);


        // Emit an event
        emit Harvest(msg.sender, _rewardAmount, _fee);
    }

    /**
	 * @dev Swaps tokens invested in contract post trading period
     *
     * @notice restricted function, should be called by owner only
     * @param router_ address of router
     * @param pair_ address of pair linked to given router
     * @param amountIn_ amount of input tokens to send
     * @param amountOutMin_ minimum amount of output tokens that must be received
     * @param deadline_ unix timestamp after which the transaction will revert
     * @param flow_ direction of swap (from token0 to token1 -> "true", from token1 to token0 -> "false")
     */
    function ownableSwap(
        address router_,
        address pair_,
        uint amountIn_,
        uint amountOutMin_,
        uint deadline_,
        bool flow_
    ) public onlyOwner {
        require(isRewardActive(), "Trading is still active!!");

        require(!isTradingContractConcluded, "swap is not allowed!!!");

        internalSwap(router_, pair_, amountIn_, amountOutMin_, deadline_, flow_);
    }

    /**
	 * @dev Swaps tokens in batch invested in contract post trading period
     *
     * @notice restricted function, should be called by owner
     * @param router_ address of router
     * @param pair_ address of pair linked to given router
     * @param amountIn_ amount of input tokens to send
     * @param amountOutMin_ minimum amount of output tokens that must be received
     * @param deadline_ unix timestamp after which the transaction will revert
     * @param flow_ direction of swap (from token0 to token1 -> "true", from token1 to token0 -> "false")
     */
    function ownableSwapBatch(
        address[] memory router_,
        address[] memory pair_,
        uint[] memory amountIn_,
        uint[] memory amountOutMin_,
        uint deadline_,
        bool[] memory flow_
    ) external {
        for(uint i; i < router_.length; i++) {
            ownableSwap(router_[i], pair_[i], amountIn_[i], amountOutMin_[i], deadline_, flow_[i]);
        }
    }

    /**
	 * @dev Swaps tokens invested in contract
     *
     * @notice restricted function, should be called by trader or API only
     * @param router_ address of router
     * @param pair_ address of pair linked to given router
     * @param amountIn_ amount of input tokens to send
     * @param amountOutMin_ minimum amount of output tokens that must be received
     * @param deadline_ unix timestamp after which the transaction will revert
     * @param flow_ direction of swap (from token0 to token1 -> "true", from token1 to token0 -> "false")
     */
    function swap(
        address router_,
        address pair_,
        uint amountIn_,
        uint amountOutMin_,
        uint deadline_,
        bool flow_
    ) public traderOrAPI {
        require(isTradingActive(), "Inactive trading");

        internalSwap(router_, pair_, amountIn_, amountOutMin_, deadline_, flow_);
    }

    /**
	 * @dev Swaps tokens in batch invested in contract
     *
     * @notice restricted function, should be called by trader or API only
     * @param router_ address of router
     * @param pair_ address of pair linked to given router
     * @param amountIn_ amount of input tokens to send
     * @param amountOutMin_ minimum amount of output tokens that must be received
     * @param deadline_ unix timestamp after which the transaction will revert
     * @param flow_ direction of swap (from token0 to token1 -> "true", from token1 to token0 -> "false")
     */
    function swapBatch(
        address[] memory router_,
        address[] memory pair_,
        uint[] memory amountIn_,
        uint[] memory amountOutMin_,
        uint deadline_,
        bool[] memory flow_
    ) external {
        for(uint i; i < router_.length; i++) {
            swap(router_[i], pair_[i], amountIn_[i], amountOutMin_[i], deadline_, flow_[i]);
        }
    }

    /**
	 * @dev Swaps tokens invested in contract
     *
     * @notice its internal function being calling by mutliple functions
     * @param router_ address of router
     * @param pair_ address of pair linked to given router
     * @param amountIn_ amount of input tokens to send
     * @param amountOutMin_ minimum amount of output tokens that must be received
     * @param deadline_ unix timestamp after which the transaction will revert
     * @param flow_ direction of swap (from token0 to token1 -> "true", from token1 to token0 -> "false")
     */
    function internalSwap(
        address router_,
        address pair_,
        uint amountIn_,
        uint amountOutMin_,
        uint deadline_,
        bool flow_
    ) internal {
        require(allowedV2PairsAndRouters[router_] && allowedV2PairsAndRouters[pair_], "Invalid address");

        // Get token0 address from given pair
        address _token0 = IPAIR(pair_).token0();

        // Get token1 address from given pair
        address _token1 = IPAIR(pair_).token1();

        // Define path
        address[] memory _path = new address[](2);

        // Record addresses to the path
        if(flow_) {
            _path[0] = _token0;
            _path[1] = _token1;
        } else {
            _path[0] = _token1;
            _path[1] = _token0;
        }

        // Approve input tokens to router
        IBEP20Token(_path[0]).approve(router_, amountIn_);

        // Execute swap function of given router
        IROUTER(router_).swapExactTokensForTokens(amountIn_, amountOutMin_, _path, address(this), deadline_);

        // register token0 as traded token
        if (tradedTokenMap[_token0] == 0 && _token0 != participationToken) {
            tradedToken.push(_token0);
            tradedTokenMap[_token0] = tradedToken.length;
        }

        // register token1 as traded token
        if (tradedTokenMap[_token1] == 0 && _token1 != participationToken) {
            tradedToken.push(_token1);
            tradedTokenMap[_token1] = tradedToken.length;
        }

        // Emit an event
        emit Swap(msg.sender, router_, pair_, amountIn_, amountOutMin_, deadline_, flow_);
    }

    /**
	 * @dev Returns fee on surplus amount
     *
     * @param surPlus_ surplus amount of participation tokens
     */
    function calculateFee(
        uint256 surPlus_
    ) internal view returns(uint256) {
        return (athLevelFee[uint8(IATHLEVEL(athLevel).athLevel(msg.sender))] * surPlus_) / 100;
    }

    /**
	 * @dev view function to check msg.sender is owner
     */
    function isOwner() internal view {
        require(owner == msg.sender, "Not an owner");
    }
}