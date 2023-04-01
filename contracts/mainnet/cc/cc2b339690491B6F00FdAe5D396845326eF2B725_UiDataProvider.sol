// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: BUSL-1.1
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

pragma solidity ^0.8.0;

interface IGrainLGE {
    function userShares(address user) external view returns (uint256, uint256, uint256, uint256, address, uint256);
    function whitelistedBonuses(address nft) external view returns (uint256);
    function grain() external view returns (IERC20);
    function lgeEnd() external view returns (uint256);
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

interface IGrainSaleClaim {
    event Claim(address indexed user, uint256 value);
    function userShares(address user) external view returns (uint256, uint256, uint256);
    function cumulativeWeight() external view returns (uint256);
    function totalGrain() external view returns (uint256);
    function lgeEnd() external view returns (uint256);
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

import "./interfaces/IGrainLGE.sol";
import "./interfaces/IGrainSaleClaim.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract UiDataProvider {
    uint256 public constant PERIOD = 91 days;
    uint256 public constant MAX_KINK_RELEASES = 8;
    uint256 public constant MAX_RELEASES = 20;
    uint256 public constant maxKinkDiscount = 4e26;
    uint256 public constant maxDiscount = 6e26;
    uint256 public constant PERCENT_DIVISOR = 1e27;
    IGrainLGE public immutable lge;
    IGrainSaleClaim public immutable grainSaleClaim;

    struct UserData {
        uint256 numberOfReleases;
        uint256 totalOwed;
        uint256 pending;
        uint256 totalClaimed;
        uint256 userGrainLeft;
    }

    constructor(address _lge, address _grainSaleClaim) {
        lge = IGrainLGE(_lge);
        grainSaleClaim = IGrainSaleClaim(_grainSaleClaim);
    }
    
    // @dev: this function is used to get the user's total weight
    // @param user: the user's address
    function getUserTotalWeight(address user) public view returns (uint256 totalWeight) {
        (uint256 usdcValue, uint256 numberOfReleases,,, address nft,) = lge.userShares(user);

        uint256 whitelistedBonuses = lge.whitelistedBonuses(nft);

        uint256 vestingPremium;
        if (numberOfReleases == 0) {
            vestingPremium = 0;
        } else if (numberOfReleases <= MAX_KINK_RELEASES) {
            // range from 0 to 40% discount
            vestingPremium = maxKinkDiscount * numberOfReleases / MAX_KINK_RELEASES;
        } else if (numberOfReleases <= MAX_RELEASES) {
            // range from 40% to 60% discount
            // ex: user goes for 20 (5 years) -> 60%
            vestingPremium = (((maxDiscount - maxKinkDiscount) * (numberOfReleases - MAX_KINK_RELEASES)) / (MAX_RELEASES - MAX_KINK_RELEASES)) + maxKinkDiscount;
        }

        uint256 weight = vestingPremium == 0 ? usdcValue : usdcValue * PERCENT_DIVISOR / (PERCENT_DIVISOR - vestingPremium);

        uint256 bonusWeight = nft == address(0) ? 0 : weight * whitelistedBonuses / PERCENT_DIVISOR;

        totalWeight = weight + bonusWeight;
    }

    // @dev: this function is used to get the number of releases
    // @param user: the user's address
    function getNumberOfReleases(address user) public view returns (uint256 numberOfReleases) {
        (, numberOfReleases,,,,) = lge.userShares(user);
    }

    // @dev: this function is used to get the total owed
    // @param user: the user's address
    function getTotalOwed(address user) public view returns (uint256 userTotal) {
        uint256 userTotalWeight = getUserTotalWeight(user);
        uint256 totalWeight = grainSaleClaim.cumulativeWeight();
        uint256 totalGrain = grainSaleClaim.totalGrain();
        uint256 shareOfLge = userTotalWeight * PERCENT_DIVISOR / totalWeight;
        userTotal = (shareOfLge * totalGrain) / PERCENT_DIVISOR;
    }

    // @dev: this function is used to get the pending
    // @param user: the user's address
    function getPending(address user) public view returns (uint256 claimable) {
        (, uint256 numberOfReleases,,,,) = lge.userShares(user);
        (,, uint256 totalClaimed) = grainSaleClaim.userShares(user);
        uint256 lgeEnd = grainSaleClaim.lgeEnd();

        /// Get how many periods user is claiming
        if (numberOfReleases == 0) {
            // No vest
            claimable = getTotalOwed(user) - totalClaimed;
        } else {
            // Vest
            uint256 periodsSinceEnd = (block.timestamp - lgeEnd) / PERIOD;
            if(periodsSinceEnd > numberOfReleases){
                periodsSinceEnd = numberOfReleases;
            }
            claimable = (getTotalOwed(user) * periodsSinceEnd / numberOfReleases) - totalClaimed;
        }
    }

    // @dev: this function is used to get the total claimed
    // @param user: the user's address
    function getTotalClaimed(address user) public view returns (uint256 totalClaimed) {
        (,, uint256 claimed) = grainSaleClaim.userShares(user);
        totalClaimed = claimed;
    }

    // @dev: this function is used to get the user's grain left
    // @param user: the user's address
    function getUserGrainLeft(address user) public view returns (uint256 grainLeft) {
        (,, uint256 totalClaimed) = grainSaleClaim.userShares(user);
        grainLeft = getTotalOwed(user) - totalClaimed;
    }

    // @dev: this function is used to get the user's data
    // @param user: the user's address
    function getUserData(address user) public view returns (UserData memory userData) {
        userData.numberOfReleases = getNumberOfReleases(user);
        userData.totalOwed = getTotalOwed(user);
        userData.pending = getPending(user);
        userData.totalClaimed = getTotalClaimed(user);
        userData.userGrainLeft = getUserGrainLeft(user);
    }
}