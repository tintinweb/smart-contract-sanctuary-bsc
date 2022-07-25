// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


interface ILpIncentive {
    function distributeAirdrop(address user) external;
}

contract RLLpIncentive is ILpIncentive, Ownable {

    struct AirdropInfo {
        uint256 lastUpdateTimestamp;
        uint256 index;
    }

    uint constant internal LP_MINT_TOTAL = 8e6 * 1e18;
    //for mainnet
    uint constant internal SECOND_PER_DAY = 24 * 60 * 60;
    uint constant internal LP_MINT_PER_DAY = 5000 * 1e18;

    //for test TODO
    //    uint constant internal LP_MINT_PER_DAY = 1 * 1e18;
    //    uint constant internal SECOND_PER_DAY = 10 * 60; // half hour

    uint constant internal PRECISION = 1e18;

    IERC20 public lpToken;
    IERC20 public rewardToken;
    uint256 public initEmissionsPerSecond;
    uint256 public hasDistributed;
    uint256 public airdropStartTime;
    AirdropInfo public globalAirdropInfo;
    mapping(address => uint256) public usersIndex;
    mapping(address => uint256) public userUnclaimedRewards;

    constructor(IERC20 _lpToken, IERC20 _rewardToken) {
        lpToken = _lpToken;
        rewardToken = _rewardToken;
        initEmissionsPerSecond = LP_MINT_PER_DAY / SECOND_PER_DAY;
    }

    function setAirdropStartTime(uint256 _airdropStartTime) public onlyOwner {
        airdropStartTime = _airdropStartTime;
    }

    function distributeAirdrop(address user) public override {
        if (block.timestamp < airdropStartTime) {
            return;
        }
        updateIndex();
        uint256 rewards = getUserUnclaimedRewards(user);
        usersIndex[user] = globalAirdropInfo.index;
        if (rewards > 0) {
            uint256 bal = rewardToken.balanceOf(address(this));
            if (bal >= rewards) {
                rewardToken.transfer(user, rewards);
                userUnclaimedRewards[user] = 0;
            }
        }
    }

    function getUserUnclaimedRewards(address user) public view returns (uint256) {
        if (block.timestamp < airdropStartTime) {
            return 0;
        }
        (uint256 newIndex,) = getNewIndex();
        uint256 userIndex = usersIndex[user];
        if (userIndex >= newIndex || userIndex == 0) {
            return userUnclaimedRewards[user];
        } else {
            return userUnclaimedRewards[user] + (newIndex - userIndex) * lpToken.balanceOf(user) / PRECISION;
        }
    }

    function updateIndex() public {
        (uint256 newIndex, uint256 emissions) = getNewIndex();
        globalAirdropInfo.index = newIndex;
        globalAirdropInfo.lastUpdateTimestamp = block.timestamp;
        hasDistributed += emissions;
    }

    function getNewIndex() public view returns (uint256, uint256) {
        uint totalSupply = lpToken.totalSupply();
        if (globalAirdropInfo.lastUpdateTimestamp >= block.timestamp ||
        hasDistributed >= LP_MINT_TOTAL || totalSupply == 0 || globalAirdropInfo.lastUpdateTimestamp == 0) {
            if (globalAirdropInfo.index == 0) {
                return (PRECISION, 0);
            } else {
                return (globalAirdropInfo.index, 0);
            }
        }
        uint256 emissions = initEmissionsPerSecond * uint256(block.timestamp - globalAirdropInfo.lastUpdateTimestamp);
        return (globalAirdropInfo.index + emissions * PRECISION / totalSupply, emissions);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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