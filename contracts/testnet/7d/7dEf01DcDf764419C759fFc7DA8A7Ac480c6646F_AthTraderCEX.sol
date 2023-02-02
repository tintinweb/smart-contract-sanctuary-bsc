/**
 *Submitted for verification at BscScan.com on 2023-02-01
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
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function transfer(address to, uint256 value)
        external
        returns (bool success);

    // Approve tokens for spending
    function approve(address spender, uint256 amount) external returns (bool);

    // Returns user balance
    function balanceOf(address user) external view returns (uint256 value);

    //Returns token Decimals
    function decimals() external view returns (uint256);
}

// Link to AthSatking contract
interface IATHLEVEL {
    // Returns ath level of given address
    function athLevel(address user) external view returns (uint256 level);
}

// Link to AthReferral contract
interface IREFERRAL {
    // record referral Address
    function recordReferral(address user, address referrer) external;

    // record referral commission amount
    function recordReferralCommission(address referrer, uint256 commission)
        external;

    // record referral commissions
    function recordReferralCommissions(
        address[] memory _referrers,
        uint256[] memory _commissions
    ) external;

    // Returns referred address
    function getReferrer(address traderAddress, address user)
        external
        view
        returns (address);

    // Return true if its referral contract
    function isReferralContract() external pure returns (bool);
}

contract AthTraderCEX {
    using SafeMath for uint256;

    // Timestamp of last payout
    uint256 public lastPayoutAt;

    // Address of AthTrader owner
    address payable public owner;

    // Address of trader account
    address payable public trader;

    IBEP20Token public usdtToken =
        IBEP20Token(0x337610d27c682E347C9cD60BD4b3b107C9d34dDd);

    IBEP20Token public bnbToken =
        IBEP20Token(0x337610d27c682E347C9cD60BD4b3b107C9d34dDd);

    // Address of AthStaking contract
    address public immutable athLevel;

    // Minimum contribution required to deposit
    uint256 public immutable minDeposit = 10000000000000000000;

    // Address of Ath Referral Contract
    address public athReferral;

    // Status of emergency withdraw
    bool public isEmergencyWithdrawlEnabled;

    // Deposit fee for followers
    uint256 public depositFee = 500000000000000;

    // Claim fee for trader
    uint256 public claimFee = 500000000000000;

    // Total deposit amount
    uint256 public totalDeposit;

    // Total collectedfee amount
    uint256 public totalCollectedFee;

    // Total claimable amount
    uint256 public totalClaimable;

    // List of deposit addresses
    address[] public depositAddresses;

    // List of claimable addresses
    address[] public claimableAddresses;

    // List of unrecorded referral payout addresses
    address[] public unrecordedReferralAddresses;

    /**
     * @dev Returns whether given address has ever deposited
     */
    mapping(address => bool) public hasDeposited;

    /**
     * @dev Returns deposit amount for given address
     */
    mapping(address => uint256) public depositAmounts;

    /**
     * @dev Returns unrecorded referral payout for given address
     */
    mapping(address => uint256) private unrecordedReferralPayouts;

    /**
     * @dev Returns fee in percentage for given level
     */
    mapping(uint8 => uint8) public athLevelFee;

    /**
     * @dev Returns trader fee in percentage for given level
     */
    mapping(uint8 => uint8) public athLevelTraderFee;

    /**
     * @dev Returns referral commission in percentage for given level
     */
    mapping(uint8 => uint8) public athLevelReferralCommission;

    /**
     * @dev Fired in transferOwnership() when ownership is transferred
     *
     * @param previousOwner an address of previous owner
     * @param newOwner an address of new owner
     */
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Fired in setReferral() when Ath Referral address is updated by an owner
     *
     * @param previousReferralAddr an address of previous Referral contract address
     * @param newReferralAddr an address of new Referral contract address
     */
    event SetReferral(address previousReferralAddr, address newReferralAddr);

    /**
     * @dev Fired in setAthLevelFee() when fee is set by an owner
     *
     * @param level index of level for which fee is set
     * @param fee fee in percentage for given level
     */
    event SetFee(uint8 level, uint8 fee);

    /**
     * @dev Fired in setAthLevelTraderFee() when trader fee is set by an owner
     *
     * @param level index of level for which fee is set
     * @param fee fee in percentage for given level
     */
    event SetTraderFee(uint8 level, uint8 fee);

    /**
     * @dev Fired in setAthLevelReferralCommission() when commission rate is set by an owner
     *
     * @param level index of level for which commission rate is set
     * @param commission commission rate in percentage for given level
     */
    event SetReferralCommission(uint8 level, uint8 commission);

    /**
     * @dev Fired in deposit() when tokens are deposited by user
     *
     * @param investor address of investor
     * @param amount number of tokens deposited
     */
    event Deposit(address indexed investor, uint256 amount);

    /**
     * @dev Fired in withdraw() and emergencyWithdraw() when tokens are withdrawn by user
     *
     * @param investor address of an investor
     * @param amount number of tokens withdrawn
     */
    event WithdrawDeposit(address indexed investor, uint256 amount);

    /**
     * @dev Fired in claim() when tokens are withdrawn by trader
     *
     * @param trader address of the trader
     * @param amount number of tokens withdrawn
     */
    event Claim(address trader, uint256 amount);

    /**
     * @dev Fired in recordPayout() when tokens are transferred to Athena
     *
     * @param amount number of tokens transferred
     */
    event AthenaPayoutTransferred(uint256 amount);

    /**
     * @dev Fired in recordPayout() when trader's claimable amount is increased
     *
     * @param amount number of tokens recorded
     */
    event TraderClaimableIncreased(uint256 amount);

    /**
     * @dev Creates/deploys AthenaBank trading contract Version 1.0
     *
     * @param athStaking_ address of AthStaking smart contract
     * @param athReferral_ address of athReferral smart contract
     */
    constructor(
        address athStaking_,
        address athReferral_,
        address payable trader_,
        uint256 depositFee_,
        uint256 claimFee_
    ) {
        // Setup smart contract internal state
        owner = payable(msg.sender);
        athLevel = athStaking_;
        athReferral = athReferral_;
        trader = trader_;
        depositFee = depositFee_;
        claimFee = claimFee_;
        lastPayoutAt = block.timestamp;

        // Set initial fees
        athLevelFee[0] = 50;
        athLevelFee[1] = 30;
        athLevelFee[2] = 25;
        athLevelFee[3] = 20;

        // Set trader fees
        athLevelTraderFee[0] = 30;
        athLevelTraderFee[1] = 50;
        athLevelTraderFee[2] = 60;
        athLevelTraderFee[3] = 70;

        // Set initial referral commissions
        athLevelReferralCommission[0] = 5;
        athLevelReferralCommission[1] = 10;
        athLevelReferralCommission[2] = 15;
        athLevelReferralCommission[3] = 20;
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

    /**
     * @dev view function to check msg.sender is owner
     */
    function isOwner() internal view {
        require(owner == msg.sender, "Not an owner");
    }

    /**
     * @dev Transfer ownership to given address
     *
     * @notice restricted function, should be called by owner only
     * @param newOwner_ address of new owner
     */
    function transferOwnership(address payable newOwner_) external onlyOwner {
        // Update owner address
        owner = newOwner_;

        // Emit an event
        emit OwnershipTransferred(msg.sender, newOwner_);
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
     * @dev Sets deposit and claim fees for followers and trader
     *
     * @notice restricted function, should be called by owner only
     * @param depositFee_ new deposit fee
     * @param claimFee_ new claim fee
     */
    function setDepositAndClaimFees(uint256 depositFee_, uint256 claimFee_)
        external
        onlyOwner
    {
        depositFee = depositFee_;
        claimFee = claimFee_;
    }

    /**
     * @dev Sets fee for given level
     *
     * @notice restricted function, should be called by owner only
     * @param level_ index of level
     * @param fee_ fee defined in percentage for given level
     */
    function setAthLevelFee(uint8[] memory level_, uint8[] memory fee_)
        external
        onlyOwner
    {
        require(level_.length == fee_.length, "Invalid input");

        for (uint8 i; i < level_.length; i++) {
            // Record fee for given level
            athLevelFee[level_[i]] = fee_[i];

            // Emit an event
            emit SetFee(level_[i], fee_[i]);
        }
    }

    /**
     * @dev Sets trader fee for given level
     *
     * @notice restricted function, should be called by owner only
     * @param level_ index of level
     * @param fee_ fee defined in percentage for given level
     */
    function setAthLevelTraderFee(uint8[] memory level_, uint8[] memory fee_)
        external
        onlyOwner
    {
        require(level_.length == fee_.length, "Invalid input");

        for (uint8 i; i < level_.length; i++) {
            // Record fee for given level
            athLevelTraderFee[level_[i]] = fee_[i];

            // Emit an event
            emit SetTraderFee(level_[i], fee_[i]);
        }
    }

    /**
     * @dev Sets referral commission rate for given level
     *
     * @notice restricted function, should be called by owner only
     * @param level_ index of level
     * @param commissionRate_ commission rate defined in percentage for given level
     */
    function setAthLevelReferralCommission(
        uint8[] memory level_,
        uint8[] memory commissionRate_
    ) external onlyOwner {
        require(level_.length == commissionRate_.length, "Invalid input");

        for (uint8 i; i < level_.length; i++) {
            // Record commission for given level
            athLevelReferralCommission[level_[i]] = commissionRate_[i];

            // Emit an event
            emit SetReferralCommission(level_[i], commissionRate_[i]);
        }
    }

    /**
     * @dev Deposits tokens to the contract
     *
     * @param amount_ number of tokens to deposit
     */
    function deposit(uint256 amount_) external payable {
        // Check that the sender has sufficient USDT balance
        require(
            amount_ + depositAmounts[msg.sender] >= minDeposit,
            "Amount smaller than minimum deposit"
        );

        // Check that the sender has sufficient USDT balance
        require(
            usdtToken.balanceOf(msg.sender) >= amount_,
            "Insufficient USDT balance"
        );

        // Check that the sender has sufficient BNB balance
        require(msg.value >= depositFee, "Insufficient BNB deposit fee");

        // Transfer tokens to AthTrader contract
        usdtToken.approve(msg.sender, amount_);
        usdtToken.transferFrom(msg.sender, address(this), amount_);

        // Transfer the fee amount from the sender to the owner
        owner.transfer(depositFee);

        // Record deposited amount of given address
        depositAmounts[msg.sender] += amount_;

        // Add given address to depositers list
        if (!hasDeposited[msg.sender]) {
            depositAddresses.push(msg.sender);
            hasDeposited[msg.sender] = true;
        }

        // Record total deposit
        totalDeposit += amount_;

        // Record total collected fee
        totalCollectedFee += depositFee;

        // Emit an event
        emit Deposit(msg.sender, amount_);
    }

    /**
     * @dev Returns deposited amount for given address
     *
     * @param investor_ investor address
     */
    function getDepositedAmount(address investor_)
        external
        view
        returns (uint256 depositedAmount_)
    {
        depositedAmount_ = depositAmounts[investor_];
        return depositedAmount_;
    }

    /**
     * @dev Allows to withdraw deposited tokens
     */
    function withdraw() external {
        require(depositAmounts[msg.sender] == 0, "Already Withdrawn!!");

        // Get deposited amount of given address
        uint256 _amount = depositAmounts[msg.sender];

        // Transfer deposited amount to given address
        usdtToken.transfer(msg.sender, _amount);

        // Remove deposited amount data for given address
        depositAmounts[msg.sender] = 0;

        // Emit an event
        emit WithdrawDeposit(msg.sender, _amount);
    }

    /**
     * @dev Allows to set the last payout timestamp
     *
     * @notice restricted function, should be called by owner only
     */
    function setLastPayout() external onlyOwner {
        lastPayoutAt = block.timestamp;
    }

    /**
     * @dev Allows to record the last payout
     *
     * @notice restricted function, should be called by owner only
     */
    function recordPayout(
        address[] memory addresses_,
        uint256[] memory profits_
    ) external onlyTrader {
        // Check if we are currently allowed to record payouts
        // require(
        //     lastPayoutAt + 30 days <= block.timestamp,
        //     "No enough time has passed since last payout!"
        // );

        // Initialize variable to store Athena payout data
        uint256 _totalAthenaPayout;

        // Iterate through every follower address
        for (uint256 i = 0; i < addresses_.length; i++) {
            address _followerAddress = addresses_[i];
            uint256 _commissionFee = calculateFollowerFee(
                _followerAddress,
                profits_[i]
            );

            // Update deposit for follower
            depositAmounts[_followerAddress] =
                depositAmounts[_followerAddress] -
                _commissionFee;

            // Calculate trader and Athena payout
            uint256 _currTraderPayout = calculateTraderFee(_commissionFee);
            uint256 _currAthenaPayout = _commissionFee - _currTraderPayout;

            // Get follower's first-level referrer
            address referrer = IREFERRAL(athReferral).getReferrer(
                address(this),
                _followerAddress
            );

            if (referrer != address(0)) {
                // Add address to current referrers list if needed
                if (unrecordedReferralPayouts[referrer] == 0) {
                    unrecordedReferralAddresses.push(referrer);
                }

                // Calculate payout for follower's first-level referrer
                uint256 _firstReferrerPayout = calculateReferralCommission(
                    referrer,
                    _currAthenaPayout
                );

                // Record payout for follower's first-level referrer
                unrecordedReferralPayouts[referrer] += _firstReferrerPayout;

                // Get follower's second-level referrer
                address secondReferrer = IREFERRAL(athReferral).getReferrer(
                    address(this),
                    referrer
                );

                if (secondReferrer != address(0)) {
                    // Add address to current referrers list if needed
                    if (unrecordedReferralPayouts[secondReferrer] == 0) {
                        unrecordedReferralAddresses.push(secondReferrer);
                    }

                    // Calculate payout for follower's second-level referrer
                    uint256 _secondReferrerPayout = calculateReferralCommission(
                        secondReferrer,
                        _currAthenaPayout
                    );

                    // Record payout for follower's second-level referrer
                    unrecordedReferralPayouts[
                        secondReferrer
                    ] += _secondReferrerPayout;

                    // Subtract second-level referral fee from Athena's payout
                    _currAthenaPayout -= _secondReferrerPayout;
                }

                // Subtract first-level referral fee from Athena's payout
                _currAthenaPayout -= _firstReferrerPayout;
            }

            // Update total claimable amount for trader
            totalClaimable += _currTraderPayout;

            // Emit an event
            emit TraderClaimableIncreased(_currTraderPayout);

            // Update total payout for Athena
            _totalAthenaPayout += _currAthenaPayout;
        }

        // Transfer tokens to Athena
        usdtToken.transfer(owner, _totalAthenaPayout);

        // Emit an event
        emit AthenaPayoutTransferred(_totalAthenaPayout);

        uint256[] memory _unrecordedReferralPayouts = new uint256[](
            unrecordedReferralAddresses.length
        );
        // Iterate through every referrer address
        for (uint256 i = 0; i < unrecordedReferralAddresses.length; i++) {
            _unrecordedReferralPayouts[i] = unrecordedReferralPayouts[
                unrecordedReferralAddresses[i]
            ];
            unrecordedReferralPayouts[unrecordedReferralAddresses[i]] = 0;
        }

        // Send data to referral contract
        IREFERRAL(athReferral).recordReferralCommissions(
            unrecordedReferralAddresses,
            _unrecordedReferralPayouts
        );

        if (totalClaimable > 0) {
            // Send tokens to the trader
            usdtToken.transfer(trader, totalClaimable);

            // Emit an event
            emit Claim(msg.sender, totalClaimable);

            // Reset claimable amount
            totalClaimable = 0;
        }
    }

    /**
     * @dev Returns deposited amount for given address
     *
     * @return claimableAmount_ claimable amount
     */
    function getClaimableAmount()
        external
        view
        returns (uint256 claimableAmount_)
    {
        claimableAmount_ = totalClaimable;
        return claimableAmount_;
    }

    /**
     * @dev Returns trader fee

     * @param amount_ amount from which to calculate
     */
    function calculateTraderFee(uint256 amount_)
        public
        view
        returns (uint256)
    {
        return
            (athLevelTraderFee[uint8(IATHLEVEL(athLevel).athLevel(trader))] *
                amount_).div(100);
    }

    /**
     * @dev Returns trader fee
     *
     * @param follower_ follower address
     * @param amount_ amount from which to calculate
     */
    function calculateFollowerFee(address follower_, uint256 amount_)
        internal
        view
        returns (uint256)
    {
        return
            (athLevelFee[uint8(IATHLEVEL(athLevel).athLevel(follower_))] *
                amount_).div(100);
    }

    /**
     * @dev Returns referral commission
     *
     * @param referrer_ referrer address
     * @param amount_ amount from which to calculate
     */
    function calculateReferralCommission(address referrer_, uint256 amount_)
        internal
        view
        returns (uint256)
    {
        return
            (athLevelReferralCommission[
                uint8(IATHLEVEL(athLevel).athLevel(referrer_))
            ] * amount_).div(100);
    }

    /**
     * @dev Activates emergency withdraw
     *
     * @notice restricted function, should be called by owner only
     */
    function emergencyWithdraw() external onlyOwner {
        // Trigger emergency withdraw
        usdtToken.transfer(owner, usdtToken.balanceOf(address(this)));
        bnbToken.transfer(owner, bnbToken.balanceOf(address(this)));
    }

    function recordReferral(address referrer_) public {
        IREFERRAL(athReferral).recordReferral(msg.sender, referrer_);
    }
}