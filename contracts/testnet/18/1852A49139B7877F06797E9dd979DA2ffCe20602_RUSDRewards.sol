/**
 *Submitted for verification at BscScan.com on 2022-03-09
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

library CastU256U128 {
    /// @dev Safely cast an uint256 to an uint128
    function u128(uint256 x) internal pure returns (uint128 y) {
        require(x <= type(uint128).max, "Cast overflow");
        y = uint128(x);
    }
}

library CastU256U32 {
    /// @dev Safely cast an uint256 to an u32
    function u32(uint256 x) internal pure returns (uint32 y) {
        require(x <= type(uint32).max, "Cast overflow");
        y = uint32(x);
    }
}

/**
 * @title SafeMathInt
 * @dev Math operations for int256 with overflow safety checks.
 */
library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    /**
     * @dev Multiplies two int256 variables and fails on overflow.
     */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        // Detect overflow when multiplying MIN_INT256 with -1
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    /**
     * @dev Division of two int256 variables and fails on overflow.
     */
    function div(int256 a, int256 b) internal pure returns (int256) {
        // Prevent overflow when dividing MIN_INT256 by -1
        require(b != -1 || a != MIN_INT256);

        // Solidity already throws when dividing by 0.
        return a / b;
    }

    /**
     * @dev Subtracts two int256 variables and fails on overflow.
     */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    /**
     * @dev Adds two int256 variables and fails on overflow.
     */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    /**
     * @dev Converts to absolute value, and fails on overflow.
     */
    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {
    /**
     * @dev Multiplies two numbers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two numbers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private initializing;

    /**
     * @dev Modifier to use in the initializer function of a contract.
     */
    modifier initializer() {
        require(
            initializing || isConstructor() || !initialized,
            "Contract instance has already been initialized"
        );

        bool wasInitializing = initializing;
        initializing = true;
        initialized = true;

        _;

        initializing = wasInitializing;
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function isConstructor() private view returns (bool) {
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.

        // MINOR CHANGE HERE:

        // previous code
        // uint256 cs;
        // assembly { cs := extcodesize(address) }
        // return cs == 0;

        // current code
        address _self = address(this);
        uint256 cs;
        assembly {
            cs := extcodesize(_self)
        }
        return cs == 0;
    }

    // Reserved storage space to allow for layout changes in the future.
    uint256[50] private ______gap;
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable is Initializable {
    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function initialize(address sender) public virtual initializer {
        _owner = sender;
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[50] private ______gap;
}


contract RUSDRewards is Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using CastU256U32 for uint256;
    using CastU256U128 for uint256;

    event LogDeveloperAddress(address developer);
    event RewardsSet(uint32 start, uint32 end, uint256 rate);
    event RewardsPerTokenUpdated(uint256 accumulated);
    event UserRewardsUpdated(
        address user,
        uint256 userRewards,
        uint256 paidRewardPerToken
    );
    event Claimed(address receiver, uint256 claimed);

    enum RewardStatus {
        NOT_ADDED,
        PENDING,
        APPROVED,
        REJECTED
    }

    struct RewardsPeriod {
        uint32 start; // Start time for the current rewardsToken schedule
        uint32 end; // End time for the current rewardsToken schedule
    }

    struct RewardsPerToken {
        uint128 accumulated; // Accumulated rewards per token for the period, scaled up by 1e18
        uint32 lastUpdated; // Last time the rewards per token accumulator was updated
        uint96 rate; // Wei rewarded per second among all token holders
    }

    struct UserRewards {
        uint128 accumulated; // Accumulated rewards for the user until the checkpoint
        uint128 checkpoint; // RewardsPerToken the last time the user rewards were updated
    }

    struct TempRewardDetail {
        address tokenOwner;
        uint32 start;
        uint32 end;
        uint256 rate;
        uint256 fee;
    }

    RewardsPerToken public rewardsPerToken; // Accumulator to track rewards per token
    mapping(address => mapping(IERC20 => UserRewards)) public rewards; // Rewards accumulated by users
    mapping(IERC20 => RewardStatus) public rewardStatus;
    mapping(IERC20 => RewardsPerToken) public rewardsTokenDetail;
    mapping(IERC20 => RewardsPeriod) public rewardsPeriod;
    mapping(IERC20 => TempRewardDetail) public tempRewardDetails;
    mapping(address => uint256) gaslessClaimTimestamp;

    address public developer;
    address public reflectoAdd;
    uint256 public gaslessClaimPeriod;
    IERC20[] public rewardPool;
    IERC20[] public pendingPool;
    IERC20 public defaultReward;
    IERC20 rusdToken;
    uint256 public MAX_REWARD_POOL;

    constructor(IERC20 _rusdToken) {
        gaslessClaimPeriod = 86400; // Gasless Claim once every 1 day
        MAX_REWARD_POOL = 130;
        rusdToken = _rusdToken;
        Ownable.initialize(msg.sender);
    }

    function setMaxRewardPoolLength(uint256 _maxRewardPool) external onlyOwner {
        MAX_REWARD_POOL = _maxRewardPool;
    }

    /*-------------------------------- Rewards ------------------------------------*/

    /// @dev Return the earliest of two timestamps
    function earliest(uint32 x, uint32 y) internal pure returns (uint32 z) {
        z = (x < y) ? x : y;
    }

    /// @dev Set a rewards schedule
    function setDefaultReward(
        uint32 start,
        uint32 end,
        uint96 rate
    ) external onlyOwner {
        require(start < end, "Incorrect input");
        // A new rewards program can be set if one is not running
        require(
            block.timestamp.u32() < rewardsPeriod[defaultReward].start ||
                block.timestamp.u32() > rewardsPeriod[defaultReward].end,
            "Ongoing rewards"
        );
        require(
            rewardStatus[defaultReward] == RewardStatus.APPROVED,
            "this token is not approved reward"
        );
        rewardsPeriod[defaultReward].start = uint32(block.timestamp) + start;
        rewardsPeriod[defaultReward].end = uint32(block.timestamp) + end;

        // If setting up a new rewards program, the rewardsPerToken.accumulated is used and built upon
        // New rewards start accumulating from the new rewards program start
        // Any unaccounted rewards from last program can still be added to the user rewards
        // Any unclaimed rewards can still be claimed
        rewardsTokenDetail[defaultReward].lastUpdated =
            uint32(block.timestamp) +
            start;
        rewardsTokenDetail[defaultReward].rate = rate;

        emit RewardsSet(start, end, rate);
    }

    /// @dev Update the rewards per token accumulator.
    /// @notice Needs to be called on each liquidity event
    function _updateRewardsPerToken() public {
        // RewardsPerToken memory rewardsPerToken_ = rewardsPerToken;
        // RewardsPeriod memory rewardsPeriod_ = rewardsPeriod;
        uint256 totalSupply_ = rusdToken.totalSupply();

        for (uint8 i = 0; i < rewardPool.length; i++) {
            // We skip the update if the program hasn't started
            if (block.timestamp.u32() < rewardsPeriod[rewardPool[i]].start)
                return;

            // Find out the unaccounted time
            uint32 end = earliest(
                block.timestamp.u32(),
                rewardsPeriod[rewardPool[i]].end
            );
            uint256 unaccountedTime = end -
                rewardsTokenDetail[rewardPool[i]].lastUpdated; // Cast to uint256 to avoid overflows later on
            if (unaccountedTime == 0) return; // We skip the storage changes if already updated in the same block

            // Calculate and update the new value of the accumulator. unaccountedTime casts it into uint256, which is desired.
            // If the first mint happens mid-program, we don't update the accumulator, no one gets the rewards for that period.
            if (totalSupply_ != 0)
                rewardsTokenDetail[rewardPool[i]]
                    .accumulated = (rewardsTokenDetail[rewardPool[i]]
                    .accumulated +
                    (1e9 *
                        unaccountedTime *
                        rewardsTokenDetail[rewardPool[i]].rate) /
                    totalSupply_).u128(); // The rewards per token are scaled up for precision
            rewardsTokenDetail[rewardPool[i]].lastUpdated = end;
        }
        // emit RewardsPerTokenUpdated(rewardsTokenDetail[rewardPool[i]].accumulated);
    }

    /// @dev Accumulate rewards for an user..
    /// @notice Needs to be called on each liquidity event, or when user balances change.
    function _updateUserRewards(address user) public {
        // UserRewards memory userRewards_ = rewards[user];
        // RewardsPerToken memory rewardsPerToken_ = rewardsPerToken;

        for (uint8 i = 0; i < rewardPool.length; i++) {
            // Calculate and update the new value user reserves. _fracBalances[user] casts it into uint256, which is desired.
            // accumulated+= (RUSD_BALANCE * (RPT.accumulated - UR.checkpoint)/ 1e9)
            rewards[user][rewardPool[i]].accumulated = (rewards[user][
                rewardPool[i]
            ].accumulated +
                (rusdToken.balanceOf(user) *
                    (rewardsTokenDetail[rewardPool[i]].accumulated -
                        rewards[user][rewardPool[i]].checkpoint)) /
                1e9).u128(); // We must scale down the rewards by the precision factor

            rewards[user][rewardPool[i]].checkpoint = rewardsTokenDetail[
                rewardPool[i]
            ].accumulated;
        }
        // emit UserRewardsUpdated(user, userRewards_.accumulated, userRewards_.checkpoint);
        // return userRewards_.accumulated;
    }

    function setReflectoContractAddress(address reflectoAdd_)
        external
        onlyOwner
    {
        reflectoAdd = reflectoAdd_;
    }

    function setDeveloperAddress(address developer_) external onlyOwner {
        developer = developer_;
        emit LogDeveloperAddress(developer_);
    }

    function addReward(
        IERC20 _rewardToken,
        uint32 start,
        uint32 end,
        uint32 rate
    ) external payable {
        require(MAX_REWARD_POOL > 0, "Limit of reward pool cannot be 0");
        require(
            rewardStatus[_rewardToken] != RewardStatus.PENDING,
            "Already exists in pending pool"
        );
        require(
            _rewardToken.allowance(msg.sender, address(this)) > 0,
            "approve before adding"
        );
        uint8 flag = 0;
        // IF Token is present in the reward pool but the supply is 0, then allow addition
        if (
            (rewardStatus[_rewardToken] == RewardStatus.APPROVED) &&
            (_rewardToken.balanceOf(address(this)) != 0)
        ) {
            revert();
        }
        require(
            start > 0 && end > 0 && rate > 10 && end > start && msg.value > 0,
            "does not meet requirements"
        );
        // If the rewardPool if filled and there are no tokens with 0 supply, then revert
        if (rewardPool.length == MAX_REWARD_POOL) {
            for (uint8 i = 1; i < rewardPool.length; i++) {
                if (IERC20(rewardPool[i]).balanceOf(address(this)) == 0) {
                    flag = 1;
                }
            }
        }
        if (flag == 1) {
            revert();
        }

        payable(reflectoAdd).transfer(msg.value / 2);
        payable(developer).transfer(msg.value / 2);
        tempRewardDetails[_rewardToken].start = uint32(block.timestamp) + start;
        tempRewardDetails[_rewardToken].end = uint32(block.timestamp) + end;
        tempRewardDetails[_rewardToken].rate = rate;
        tempRewardDetails[_rewardToken].tokenOwner = msg.sender;
        rewardStatus[_rewardToken] = RewardStatus.PENDING;
        pendingPool.push(_rewardToken);
    }

    function approveReward(IERC20 _rewardToken) public onlyOwner {
        require(
            rewardStatus[_rewardToken] == RewardStatus.PENDING,
            "token needs to be added first"
        );
        require(rewardPool.length > 0, "Default reward must be added");
        address tokenOwner = tempRewardDetails[_rewardToken].tokenOwner;

        // set reward period with rate
        rewardsPeriod[_rewardToken].start = tempRewardDetails[_rewardToken]
            .start;
        rewardsPeriod[_rewardToken].end = tempRewardDetails[_rewardToken].end;
        rewardsTokenDetail[_rewardToken].lastUpdated = rewardsPeriod[
            _rewardToken
        ].start;
        rewardsTokenDetail[_rewardToken].rate = uint96(
            tempRewardDetails[_rewardToken].rate
        );
        // delete the struct data for tempRewardDetails
        delete tempRewardDetails[_rewardToken];

        if (rewardPool.length >= MAX_REWARD_POOL) {
            for (uint8 i = 1; i < rewardPool.length; i++) {
                if (IERC20(rewardPool[i]).balanceOf(address(this)) == 0) {
                    rewardPool[i] = _rewardToken; // overwritten with this new token
                    removeToken(rewardPool[i]);
                    break;
                }
            }
        } else {
            rewardPool.push(_rewardToken);
        }
        // remove this token from pending pool
        for (uint8 i = 0; i < pendingPool.length; i++) {
            if (pendingPool[i] == _rewardToken) {
                delete pendingPool[i];
                break;
            }
        }

        rewardStatus[_rewardToken] = RewardStatus.APPROVED;
        // get the tokens in this contract
        IERC20(_rewardToken).transferFrom(
            tokenOwner,
            address(this),
            _rewardToken.allowance(tokenOwner, address(this))
        );
    }

    function removeToken(IERC20 _rewardToken) internal {
        rewardStatus[_rewardToken] = RewardStatus.NOT_ADDED;
        delete rewardsTokenDetail[_rewardToken];
    }

    function approveMultipleReward(IERC20[] memory _rewardToken) external {
        for (uint8 i = 0; i < _rewardToken.length; i++) {
            approveReward(_rewardToken[i]);
        }
    }

    // List of approved tokens
    function approvedTokens() public view returns (IERC20[] memory) {
        return rewardPool;
    }

    // list of Unapproves/Pending tokens
    function pendingTokens() public view returns (IERC20[] memory) {
        return pendingPool;
    }

    function setDefaultToken(IERC20 _defaultToken) external onlyOwner {
        defaultReward = _defaultToken;
        rewardPool.push(defaultReward);
        rewardStatus[defaultReward] = RewardStatus.APPROVED;
    }

    function getMessageHash(
        address _to,
        uint256 _amount,
        string memory _message,
        uint256 _nonce
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_to, _amount, _message, _nonce));
    }

    function verify(
        address _signer,
        bytes32 _messageHash,
        bytes memory signature
    ) internal pure returns (bool) {
        return recoverSigner(_messageHash, signature) == _signer;
    }

    function recoverSigner(
        bytes32 _ethSignedMessageHash,
        bytes memory _signature
    ) public pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
        public
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            /*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        // implicitly return (r, s, v)
    }

    function setClaimPeriod(uint256 gaslessClaimPeriod_) external onlyOwner {
        gaslessClaimPeriod = gaslessClaimPeriod_;
    }

    function gaslessClaim(
        address _to,
        IERC20[] memory _rewardTokens,
        bytes32 _messageHash,
        bytes memory signature
    ) external onlyOwner {
        require(
            block.timestamp >=
                gaslessClaimTimestamp[_to].add(gaslessClaimPeriod),
            "Cannot reclaim before 1 day"
        );
        require(
            verify(_to, _messageHash, signature),
            "signature is not matching"
        );
        gaslessClaimTimestamp[_to] = block.timestamp;
        claim(_to, _rewardTokens);
    }

    /// @dev Claim all rewards from caller into a given address
    function claim(address _to, IERC20[] memory _rewardTokens) public {
        _updateRewardsPerToken();
        _updateUserRewards(_to);
        for (uint8 i = 0; i < _rewardTokens.length; i++) {
            uint256 claiming = rewards[_to][_rewardTokens[i]].accumulated;
            require(claiming > 0, "Claim amount cannot be less than 0");
            rewards[_to][_rewardTokens[i]].accumulated = 0;
            _rewardTokens[i].transfer(_to, claiming);
            emit Claimed(_to, claiming);
        }    
    }
}