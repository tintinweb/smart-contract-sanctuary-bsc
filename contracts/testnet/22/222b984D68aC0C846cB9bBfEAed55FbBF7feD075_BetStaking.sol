// SPDX-License-Identifier: MIT
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(msg.sender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./Ownable.sol";

contract Runnable is Ownable {
    modifier whenRunning() {
        require(_isRunning, "Paused");
        _;
    }

    modifier whenNotRunning() {
        require(!_isRunning, "Running");
        _;
    }

    bool public _isRunning;

    constructor() {
        _isRunning = true;
    }

    function toggleRunning() external onlyOwner {
        _isRunning = !_isRunning;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./interfaces/IERC20.sol";
import "./security/ReentrancyGuard.sol";
import "./access/Runnable.sol";

contract BetStaking is ReentrancyGuard, Runnable {
    struct StakingPackage {
        uint256 id; //1: 7d 50%, 2: 15d 90%, 3: 30d 180%, 4: 60d 320%,
        bool enable;
        uint256 aprRate;
        uint256 minStakingAmount;
        uint256 durationInSeconds;
    }

    struct StakingDetail {
        uint256 id;
        uint256 stakingPackageId;
        address staker;
        uint256 aprRate;
        uint256 rewardAmount; //reward will not change if any update
        uint256 stakingAmount;
        uint256 status; //1: staking, 2: claimed
        uint256 startDate;
        uint256 endDate;
    }

    uint256 public _stakingCount = 0;
    uint256 public _totalStakingTimes = 0;
    uint256 public _totalVesting = 1000000e18;
    uint256 public _totalProfits = 0;
    uint256 public denominator = 1000;
    IERC20 public _token;
    mapping(uint256 => StakingPackage) public _stakingPackages;
    mapping(uint256 => StakingDetail) public _stakingDetails;

    constructor(address tokenAddress) {
        require(tokenAddress != address(0), "Address 0");
        _isRunning = true;
        _token = IERC20(tokenAddress);

        //Init data
        _stakingPackages[1] = StakingPackage(1, true, 500, 10000e18, 604800);
        _stakingPackages[2] = StakingPackage(2, true, 900, 10000e18, 1296000);
        _stakingPackages[3] = StakingPackage(3, true, 1800, 10000e18, 2592000);
        _stakingPackages[4] = StakingPackage(4, true, 3200, 10000e18, 5184000);
    }

    function calculateStakingReward(uint256 amount, uint256 packageId)
        internal
        view
        returns (uint256)
    {
        StakingPackage memory stakingPackage = _stakingPackages[packageId];
        return
            (amount * stakingPackage.aprRate * 365 * 3600 * 24) /
            stakingPackage.durationInSeconds /
            denominator;
    }

    function staking(uint256 amount, uint256 package)
        external
        whenRunning
        nonReentrant
        returns (uint256)
    {
        StakingPackage memory stakingPackage = _stakingPackages[package];
        require(stakingPackage.enable, "Staking package not support");
        require(
            amount >= stakingPackage.minStakingAmount,
            "Amount is less than minStakingAmount"
        );
        uint256 rewardAmount = calculateStakingReward(amount, package);
        require(
            _totalVesting > (_totalProfits + rewardAmount),
            "Staking filled this month"
        );
        require(_token.balanceOf(msg.sender) >= amount, "Not enough balance");

        //Transfer token to lock
        require(
            _token.transferFrom(msg.sender, address(this), amount),
            "Fail to transfer token to staking"
        );

        //Set staking detail
        _stakingCount += 1;
        _totalProfits += rewardAmount;
        StakingDetail memory stakingDetail = StakingDetail(
            _stakingCount,
            package,
            msg.sender,
            stakingPackage.aprRate,
            rewardAmount,
            amount,
            1,
            block.timestamp,
            block.timestamp + stakingPackage.durationInSeconds
        );
        _stakingDetails[_stakingCount] = stakingDetail;

        emit StakingCreated(
            stakingDetail.id,
            stakingPackage.id,
            stakingDetail.staker,
            stakingDetail.aprRate,
            stakingDetail.rewardAmount,
            stakingDetail.stakingAmount,
            stakingDetail.status,
            stakingDetail.startDate,
            stakingDetail.endDate
        );
        return stakingDetail.id;
    }

    function claim(uint256 stakingId) external whenRunning nonReentrant {
        StakingDetail memory stakingDetail = _stakingDetails[stakingId];
        require(stakingDetail.status == 1, "Not ready to claim");
        require(
            stakingDetail.endDate <= block.timestamp,
            "Time to claim not yet passed!"
        );
        require(stakingDetail.staker == msg.sender, "Not authorized to claim");

        //Set status staking detail
        stakingDetail.status = 2;
        _stakingDetails[stakingId] = stakingDetail;

        //Release staking token
        uint256 claimAmount = stakingDetail.stakingAmount +
            stakingDetail.rewardAmount;
        require(
            _token.transfer(msg.sender, claimAmount),
            "Fail to release staking token"
        );

        //Emit release reward
        emit ClaimBet(stakingId, msg.sender, claimAmount);
    }

    function setTokenAddress(address newAddress) external onlyOwner {
        require(newAddress != address(0), "Zero address");
        _token = IERC20(newAddress);
    }

    function setTotalVesting(uint256 newVestingAmount) external onlyOwner {
        require(newVestingAmount > 0, "Invalid increase vesting");
        _totalVesting = newVestingAmount + _totalVesting;
    }

    function setStakingPackage(
        uint256 id,
        bool enable,
        uint256 aprRate,
        uint256 minStakingAmount,
        uint256 durationInSeconds
    ) external onlyOwner {
        require(minStakingAmount > 0, "Invalid min staking amount");
        require(aprRate > 0, "Invalid aprRate");
        require(durationInSeconds > 0, "Invalid duration in second");
        StakingPackage memory stakingPackage = _stakingPackages[id];
        stakingPackage.enable = enable;
        stakingPackage.aprRate = aprRate;
        stakingPackage.minStakingAmount = minStakingAmount;
        stakingPackage.durationInSeconds = durationInSeconds;
        _stakingPackages[id] = stakingPackage;
    }

    function withdrawToken(address recepient) external onlyOwner {
        require(
            _token.transfer(recepient, _token.balanceOf(address(this))),
            "Failure withdraw"
        );
    }

    event StakingCreated(
        uint256 id,
        uint256 stakingPackageId,
        address staker,
        uint256 aprRate,
        uint256 rewardAmount,
        uint256 stakingAmount,
        uint256 status,
        uint256 startDate,
        uint256 endDate
    );
    event ClaimBet(uint256 id, address staker, uint256 amount);
}