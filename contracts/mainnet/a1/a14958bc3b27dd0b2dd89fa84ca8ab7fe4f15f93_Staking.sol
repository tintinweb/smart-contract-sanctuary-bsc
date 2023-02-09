/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: contracts/Staking.sol



pragma solidity ^0.8.0;




contract Staking is Ownable {
    using SafeMath for uint256;

    enum TransactionType {
        DEPOSIT,
        CLAIM,
        COMPOUND
    }

    event RewardsTransferred(address holder, uint256 amount);

    struct ReferralEarning {
        address[] stakingAddress;
        address[] user;
        uint256[] amount;
        uint256[] timestamp;
    }

    struct TransactionHistory {
        uint256[] timestamp;
        uint256[] amount;
        TransactionType[] transactionType;
    }

    // token contract address
    address private tokenAddress;
    address public adminWallet;

    uint256 private rewardInterval;

    // unstaking fee 5 percent
    uint256 private unstakingFeeRate;

    // calaim possible after each clifftime interval - value in seconds
    uint256 public cliffTime;

    uint256 public lastDistributionTime;

    uint256 public totalClaimedRewards = 0;

    uint256 public totalStakedToken = 0;

    uint256 public maxReturn = 20000;

    //  array of holders;
    address[] public holders;

    mapping(address => uint256) public depositedTokens;
    mapping(address => uint256) public stakingTime;
    mapping(address => uint256) public lastClaimedTime;
    mapping(address => uint256) public totalEarnedTokens;
    mapping(address => uint256) public availableReferralIncome;
    mapping(address => uint256) public totalReferralIncome;
    mapping(address => address) public myReferralAddresses; // get my referal address that i refer
    mapping(address => bool) public alreadyReferral;
    mapping(address => TransactionHistory) private transactionHistory;
    mapping(address => bool) public userMatured;

    //Referral
    mapping(address => address) userReferral; // which refer user used
    mapping(address => address[]) userReferrales; // referral address which use users address
    mapping(address => uint256) public totalReferalAmount; // get my total referal amount
    mapping(address => ReferralEarning) referralEarning;
    uint256[] public referrals;
    address public depositToken;
    address[] public stakingContract;

    // @update Initialize NFT contract

    constructor(
        address _tokenAddress,
        address _adminWallet,
        uint256 _rewardInterval,
        uint256 _unstakingFeeRate,
        uint256 _cliffTime,
        uint256 _lastDistributionTime
    ) {
        tokenAddress = _tokenAddress;
        adminWallet = _adminWallet;
        rewardInterval = _rewardInterval;
        unstakingFeeRate = _unstakingFeeRate;
        cliffTime = _cliffTime;
        lastDistributionTime = _lastDistributionTime;
        referrals = [2000, 1000, 500, 400, 300, 200, 200, 200, 100, 100];
    }

    // All constant value view function

    /**
     * @notice Reward interval
     * @return rewardInterval of staking
     */
    function getRewardInterval() public view returns (uint256) {
        return rewardInterval;
    }

    /**
     * @notice Staking Fee Rate
     * @return unstakingFeeRate will be send to owner at unstaking time
     */
    function getUnstakingFeeRate() public view returns (uint256) {
        return unstakingFeeRate;
    }

    /**
     * @notice Cliff time
     * @return cliffTime after which time user can wwithdraw their stake
     */
    function getCliffTime() public view returns (uint256) {
        return cliffTime;
    }

    /**
     * @notice Token address
     * @return tokenAddress of erc20 token address which is stake in this contract
     */
    function getTokenAddress() public view returns (address) {
        return tokenAddress;
    }

    function getTransactionHistory(address _holder)
        public
        view
        returns (TransactionHistory memory)
    {
        return transactionHistory[_holder];
    }

    function getLastDistributionTime() public view returns (uint256) {
        require(block.timestamp > lastDistributionTime, "Invalid time");
        uint256 times = block.timestamp.sub(lastDistributionTime).div(
            cliffTime
        );
        if (times == 0) {
            return lastDistributionTime;
        }
        uint256 currentTime = lastDistributionTime.add(cliffTime.mul(times));
        return currentTime;
    }

    /**
     * @notice Change Unstaking fee rate
     */
    function setUnstakingFeeRate(uint256 _rate) public onlyOwner {
        unstakingFeeRate = _rate;
    }

    /**
     * @notice Change Cliff Time
     */
    function setCliffTime(uint256 _cliffTime) public onlyOwner {
        cliffTime = _cliffTime;
    }

    function setReferralIncome(address _userAddress, uint256 _amount) internal {
        availableReferralIncome[_userAddress] += _amount;
    }

    /**
     * @notice Only Holder - check holder is exists in our contract or not
     * @return bool value
     */
    function onlyHolder() public view returns (bool) {
        bool condition = false;
        for (uint256 i = 0; i < holders.length; i++) {
            if (holders[i] == msg.sender) {
                condition = true;
                return true;
            }
        }
        return false;
    }

    /**
     * @notice Update Account
     * @param account account address of the user
     */
    function updateAccount(address account, TransactionType _transactionType)
        private
    {
        uint256 pendingDivs = getUnLockedPendingDivs(account);
        uint256 referralIncome = availableReferralIncome[account];
        if (_transactionType != TransactionType.DEPOSIT) {
            if (pendingDivs > 0) {
                totalEarnedTokens[account] += pendingDivs.add(referralIncome);
                availableReferralIncome[account] = 0;
                totalReferralIncome[account] += referralIncome;
                totalClaimedRewards = totalClaimedRewards.add(pendingDivs);
                if (
                    totalEarnedTokens[account] >=
                    depositedTokens[account].mul(maxReturn).div(1e4)
                ) {
                    uint256 diff = totalEarnedTokens[account] -
                        depositedTokens[account].mul(maxReturn).div(1e4);
                    pendingDivs = pendingDivs.sub(diff);
                    userMatured[account] = true;
                }
                // require(
                //     totalEarnedTokens[account] <=
                //         depositedTokens[account].mul(maxReturn).div(1e4),
                //     "Earning limit reached"
                // );
                transactionHistory[account].timestamp.push(block.timestamp);
                transactionHistory[account].amount.push(
                    pendingDivs + referralIncome
                );
                if (_transactionType == TransactionType.COMPOUND) {
                    depositedTokens[account] += pendingDivs.add(referralIncome);
                    transactionHistory[account].transactionType.push(
                        TransactionType.COMPOUND
                    );
                } else {
                    transactionHistory[account].transactionType.push(
                        TransactionType.CLAIM
                    );
                    uint256 fee = pendingDivs
                        .add(referralIncome)
                        .mul(unstakingFeeRate)
                        .div(1e4);
                    uint256 amountToTransfer = pendingDivs
                        .add(referralIncome)
                        .sub(fee);
                    totalClaimedRewards += pendingDivs.add(referralIncome);
                    require(
                        IERC20(tokenAddress).transfer(owner(), fee),
                        "Could not transfer tokens."
                    );
                    require(
                        IERC20(tokenAddress).transfer(
                            account,
                            amountToTransfer
                        ),
                        "Could not transfer tokens."
                    );
                    if (account != owner()) {
                        require(
                            payReferral(account, account, 0, pendingDivs),
                            "Can't pay referral"
                        );
                    }
                }

                emit RewardsTransferred(account, pendingDivs);
            }
            // if (block.timestamp > cliffTime.add(lastDistributionTime)) {
            //     //check condition
            //     //for loop to determine gloal time from start time
            //     lastDistributionTime += cliffTime;
            // }
            lastClaimedTime[account] = getLastDistributionTime();
        }
    }

    /**
     * @notice Get Pending divs
     * @param _holder account address of the user
     * @return pendingDivs;
     */
    function getLockedPendingDivs(address _holder)
        public
        view
        returns (uint256)
    {
        uint256 _lastDistributionTime = getLastDistributionTime();
        uint256 timeDiff;
        uint256 _lastInteractionTime;
        if (lastClaimedTime[_holder] == 0) {
            _lastInteractionTime = stakingTime[_holder];
        } else {
            _lastInteractionTime = lastClaimedTime[_holder];
        }
        if (block.timestamp < _lastDistributionTime.add(cliffTime)) {
            if (_lastInteractionTime >= _lastDistributionTime) {
                timeDiff = block.timestamp.sub(_lastInteractionTime);
            } else {
                timeDiff = block.timestamp.sub(lastDistributionTime);
            }
        }
        uint256 stakedAmount = depositedTokens[_holder];
        uint256 rewardRate;
        if (stakedAmount <= 1000 ether) {
            rewardRate = 50;
        } else if (stakedAmount > 1000 ether && stakedAmount <= 3000 ether) {
            rewardRate = 60;
        } else if (stakedAmount > 3000 ether && stakedAmount <= 5000 ether) {
            rewardRate = 75;
        } else if (stakedAmount > 5000 ether && stakedAmount <= 10000 ether) {
            rewardRate = 90;
        } else if (stakedAmount > 10000 ether) {
            rewardRate = 100;
        }
        uint256 pendingDivs = stakedAmount
            .mul(rewardRate)
            .mul(timeDiff)
            .div(rewardInterval)
            .div(1e4);

        return uint256(pendingDivs);
    }

    function getUnLockedPendingDivs(address _holder)
        public
        view
        returns (uint256)
    {
        uint256 _lastDistributionTime = getLastDistributionTime();
        uint256 _lastInteractionTime;
        if (lastClaimedTime[_holder] == 0) {
            _lastInteractionTime = stakingTime[_holder];
        } else {
            _lastInteractionTime = lastClaimedTime[_holder];
        }

        if (_lastDistributionTime < _lastInteractionTime) {
            return 0;
        }
        uint256 timeDiff = _lastDistributionTime.sub(_lastInteractionTime);
        //currentgolabal - userlast = timediff
        // if (block.timestamp > lastDistributionTime.add(cliffTime)) {
        //     timeDiff = block.timestamp.sub(lastClaimedTime[_holder]);
        // }
        uint256 stakedAmount = depositedTokens[_holder];
        uint256 rewardRate;
        if (stakedAmount <= 1000 ether) {
            rewardRate = 50;
        } else if (stakedAmount > 1000 ether && stakedAmount <= 3000 ether) {
            rewardRate = 60;
        } else if (stakedAmount > 3000 ether && stakedAmount <= 5000 ether) {
            rewardRate = 75;
        } else if (stakedAmount > 5000 ether && stakedAmount <= 10000 ether) {
            rewardRate = 90;
        } else if (stakedAmount > 10000 ether) {
            rewardRate = 100;
        }
        uint256 pendingDivs = stakedAmount
            .mul(rewardRate)
            .mul(timeDiff)
            .div(rewardInterval)
            .div(1e4);

        return uint256(pendingDivs);
    }

    /**
     * @notice Get number of holders
     * @notice will return length of holders array
     * @return holders;
     */
    function getNumberOfHolders() public view returns (uint256) {
        return holders.length;
    }

    /**
     * @notice Deposit
     * @notice A transfer is used to bring tokens into the staking contract so pre-approval is required
     * @param amountToStake amount of total tokens user staking and get NFT basis on that
     */
    function deposit(uint256 amountToStake, address _referral) public {
        require(
            amountToStake >= 100 ether,
            "Cannot deposit less than 100 Tokens"
        );
        if (msg.sender != owner()) {
            require(
                _referral != address(0) &&
                    _referral != msg.sender &&
                    _referral != address(this) &&
                    depositedTokens[_referral] > 0,
                "Invalid Referral Address"
            );
        }
        if (alreadyReferral[msg.sender]) {
            _referral = myReferralAddresses[msg.sender];
        }
        require(
            IERC20(tokenAddress).transferFrom(
                msg.sender,
                address(this),
                amountToStake
            ),
            "Insufficient Token Allowance"
        );

        require(
            IERC20(tokenAddress).transfer(adminWallet, amountToStake),
            "Deposit Failed"
        );
        updateAccount(msg.sender, TransactionType.DEPOSIT);

        transactionHistory[msg.sender].timestamp.push(block.timestamp);
        transactionHistory[msg.sender].amount.push(amountToStake);
        transactionHistory[msg.sender].transactionType.push(
            TransactionType.DEPOSIT
        );
        depositedTokens[msg.sender] += amountToStake;
        stakingTime[msg.sender] = block.timestamp;
        totalStakedToken += amountToStake;
        userMatured[msg.sender] = false;

        if (
            amountToStake > 0 &&
            _referral != address(0) &&
            _referral != msg.sender &&
            depositedTokens[_referral] > 0
        ) {
            alreadyReferral[msg.sender] = true;
            myReferralAddresses[msg.sender] = _referral;

            require(
                setUserReferral(msg.sender, _referral),
                "Can't set user referral"
            );

            require(
                setReferralAddressesOfUsers(msg.sender, _referral),
                "Can't update referral list"
            );

            // require(
            //     payReferral(
            //         msg.sender,
            //         msg.sender,
            //         0,
            //         amountToStake
            //     ),
            //     "Can't pay referral"
            // );
        }
        // lastClaimedTime[msg.sender] = block.timestamp;
        if (!onlyHolder()) {
            holders.push(msg.sender);
            stakingTime[msg.sender] = block.timestamp;
        }
    }

    /**
     * @notice Claim reward tokens call by directly from user
     */
    function claimDivs() public {
        require(!userMatured[msg.sender], "User earning limit reached");
        updateAccount(msg.sender, TransactionType.CLAIM);
    }

    function compound() public {
        require(!userMatured[msg.sender], "User earning limit reached");
        updateAccount(msg.sender, TransactionType.COMPOUND);
    }

    /**
     * @notice Get stakers list
     * @param startIndex index of array from point
     * @param endIndex index of array end point
     * @return stakers
     * @return stakingTimestamps
     * @return lastClaimedTimeStamps
     * @return stakedTokens
     */
    function getStakersList(uint256 startIndex, uint256 endIndex)
        public
        view
        returns (
            address[] memory stakers,
            uint256[] memory stakingTimestamps,
            uint256[] memory lastClaimedTimeStamps,
            uint256[] memory stakedTokens
        )
    {
        require(startIndex < endIndex);

        uint256 length = endIndex.sub(startIndex);
        address[] memory _stakers = new address[](length);
        uint256[] memory _stakingTimestamps = new uint256[](length);
        uint256[] memory _lastClaimedTimeStamps = new uint256[](length);
        uint256[] memory _stakedTokens = new uint256[](length);

        for (uint256 i = startIndex; i < endIndex; i = i.add(1)) {
            // address staker = holders.at(i);
            address staker = holders[i];
            uint256 listIndex = i.sub(startIndex);
            _stakers[listIndex] = staker;
            _stakingTimestamps[listIndex] = stakingTime[staker];
            _lastClaimedTimeStamps[listIndex] = lastClaimedTime[staker];
            _stakedTokens[listIndex] = depositedTokens[staker];
        }

        return (
            _stakers,
            _stakingTimestamps,
            _lastClaimedTimeStamps,
            _stakedTokens
        );
    }

    // function to allow admin to claim *other* ERC20 tokens sent to this contract (by mistake)
    // Admin cannot transfer out Staking Token from this smart contract
    function transferAnyERC20Tokens(
        address _tokenAddr,
        address _to,
        uint256 _amount
    ) public onlyOwner {
        require(
            _tokenAddr != tokenAddress,
            "Cannot Transfer Out Staking Token!"
        );
        IERC20(_tokenAddr).transfer(_to, _amount);
    }

    //Referral
    function getUserReferralInformation(address userAddress)
        public
        view
        returns (
            address[] memory,
            address[] memory,
            uint256[] memory,
            uint256[] memory
        )
    {
        return (
            referralEarning[userAddress].stakingAddress,
            referralEarning[userAddress].user,
            referralEarning[userAddress].amount,
            referralEarning[userAddress].timestamp
        );
    }

    function addNewLevel(uint256 levelRate) public onlyOwner {
        referrals.push(levelRate);
    }

    function updateExistingLevel(uint256 index, uint256 levelRate)
        public
        onlyOwner
    {
        referrals[index] = levelRate;
    }

    function setUserReferral(address beneficiary, address referral)
        internal
        returns (bool)
    {
        userReferral[beneficiary] = referral;
        return true;
    }

    function setReferralAddressesOfUsers(address beneficiary, address referral)
        internal
        returns (bool)
    {
        userReferrales[referral].push(beneficiary);
        return true;
    }

    function getUserReferral(address user) public view returns (address) {
        return userReferral[user];
    }

    function getReferralAddressOfUsers(address user)
        public
        view
        returns (address[] memory)
    {
        return userReferrales[user];
    }

    function payReferral(
        address _userAddress,
        address _secondaryAddress,
        uint256 _index,
        uint256 _mainAmount
    ) internal returns (bool) {
        if (_index >= referrals.length) {
            return true;
        } else {
            if (userReferral[_userAddress] != address(0)) {
                uint256 transferAmount = (_mainAmount * referrals[_index]) /
                    10000;
                referralEarning[userReferral[_userAddress]].stakingAddress.push(
                        msg.sender
                    );
                referralEarning[userReferral[_userAddress]].user.push(
                    _secondaryAddress
                );
                referralEarning[userReferral[_userAddress]].amount.push(
                    transferAmount
                );
                referralEarning[userReferral[_userAddress]].timestamp.push(
                    block.timestamp
                );
                // if(!Staking(msg.sender).isBlackListForRefer(userReferral[_userAddress])){
                // require(
                //     Token(depositToken).transfer(
                //         userReferral[_userAddress],
                //         transferAmount
                //     ),
                //     "Could not transfer referral amount"
                // );
                if (!userMatured[userReferral[_userAddress]]) {
                    setReferralIncome(
                        userReferral[_userAddress],
                        transferAmount
                    );
                }
                totalReferalAmount[userReferral[_userAddress]] =
                    totalReferalAmount[userReferral[_userAddress]] +
                    (transferAmount);
                // }
                payReferral(
                    userReferral[_userAddress],
                    _secondaryAddress,
                    _index + 1,
                    _mainAmount
                );
                return true;
            } else {
                return false;
            }
        }
    }
}