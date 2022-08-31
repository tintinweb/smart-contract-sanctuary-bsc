/**
 *Submitted for verification at BscScan.com on 2022-08-31
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


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

contract Staking is Ownable , ReentrancyGuard {
    uint256 constant LOCK_TIME = 4 days; // change to 4 days
    uint256 constant REWARD_INTERVAL = 1 days; //changes to 1 day
    uint256 constant ROI_PERIOD = 365;
    
    address public tokenAddress;
    address public poolAddress;
    address public feeAddress;
    mapping(address => uint256[]) amounts;
    mapping(address => uint256[]) times;
    mapping(address => uint256[]) harvests;

    constructor(
        address tokenAddr,
        address poolAddr,
        address feeAddr
    ) {
        tokenAddress = tokenAddr;
        poolAddress = poolAddr;
        feeAddress = feeAddr;
    }

    function stake(uint256 amount) external {
        require(
            IERC20(tokenAddress).balanceOf(msg.sender) >= amount,
            "Insufficient Fund"
        );

        IERC20(tokenAddress).transferFrom(
            msg.sender,
            address(this),
            amount - amount / 20
        );
        IERC20(tokenAddress).transferFrom(msg.sender, feeAddress, amount / 20);
        amounts[msg.sender].push(amount);
        times[msg.sender].push(block.timestamp);
        harvests[msg.sender].push(0);
    }

    function claimable(address user) public view returns (uint256) {
        uint256 length = amounts[user].length;
        uint256 claimableAmount;
        for (uint256 i = 0; i < length; ++i) {
            claimableAmount += claimableAt(user, times[user][i]);
        }
        return claimableAmount;
    }

    function claimableAt(address user, uint256 timestamp)
        public
        view
        returns (uint256)
    {
        uint256 length = amounts[user].length;
        uint256 i;
        for (i = 0; i < length && times[user][i] != timestamp; ++i) {}
        require(i < length, "No Stakes like that");
        if (block.timestamp - times[user][i] < LOCK_TIME) {
            return 0;
        }
        return
            (amounts[user][i] *
                3 *
                ((block.timestamp - times[user][i]) / REWARD_INTERVAL)) /
            ROI_PERIOD -
            harvests[user][i];
    }

    function harvest() external nonReentrant {
        uint256 claimableAmount = claimable(msg.sender);
        require(claimableAmount > 0, "No Claimable Token");
        require(
            IERC20(tokenAddress).balanceOf(poolAddress) >= claimableAmount,
            "Insufficient Fund in Pool"
        );
        IERC20(tokenAddress).transferFrom(
            poolAddress,
            msg.sender,
            claimableAmount
        );
        uint256 length = amounts[msg.sender].length;
        for (uint256 i = 0; i < length; ++i) {
            if (block.timestamp - times[msg.sender][i] >= LOCK_TIME) {
                harvests[msg.sender][i] =
                    (amounts[msg.sender][i] *
                        3 *
                        ((block.timestamp - times[msg.sender][i]) /
                            REWARD_INTERVAL)) /
                    ROI_PERIOD;
            }
        }
    }

    function harvestAt(uint256 timestamp) external {
        uint256 claimableAmount = claimableAt(msg.sender, timestamp);
        require(claimableAmount > 0, "No Claimable Token");
        uint256 length = amounts[msg.sender].length;
        uint256 i;
        for (i = 0; i < length && times[msg.sender][i] != timestamp; ++i) {}
        require(i < length, "No Stakes like that");
        require(
            IERC20(tokenAddress).balanceOf(poolAddress) >= claimableAmount,
            "Insufficient Fund in Pool"
        );
        IERC20(tokenAddress).transferFrom(
            poolAddress,
            msg.sender,
            claimableAmount
        );
        harvests[msg.sender][i] =
            (amounts[msg.sender][i] *
                3 *
                ((block.timestamp - times[msg.sender][i]) / REWARD_INTERVAL)) /
            ROI_PERIOD;
    }

    function unstake(uint256 timestamp, uint256 amount) external nonReentrant {
        uint256 length = amounts[msg.sender].length;
        uint256 i;
        for (i = 0; i < length && times[msg.sender][i] != timestamp; ++i) {}
        require(i < length, "No Stakes like that");
        require(
            block.timestamp - times[msg.sender][i] >= LOCK_TIME,
            "Lock Period"
        );
        require(amounts[msg.sender][i] >= amount, "Insufficient staked token");
        uint256 claimableAmount = claimableAt(msg.sender, timestamp);
        require(
            IERC20(tokenAddress).balanceOf(poolAddress) >= claimableAmount,
            "Insufficient Fund in Pool"
        );
        IERC20(tokenAddress).transferFrom(
            poolAddress,
            msg.sender,
            claimableAmount
        );
        IERC20(tokenAddress).transfer(feeAddress, amount / 20);
        IERC20(tokenAddress).transfer(msg.sender, amount - (amount / 20) * 2);
        if (amounts[msg.sender][i] == amount) {
            amounts[msg.sender][i] = amounts[msg.sender][length - 1];
            amounts[msg.sender].pop();
            times[msg.sender][i] = times[msg.sender][length - 1];
            times[msg.sender].pop();
            harvests[msg.sender][i] = harvests[msg.sender][length - 1];
            harvests[msg.sender].pop();
        } else {
            amounts[msg.sender][i] -= amount;
            times[msg.sender][i] = block.timestamp;
            harvests[msg.sender][i] = 0;
        }
    }

    //TODO Add onlyOwner
    function updatePoolAddress(address account) public onlyOwner {
        poolAddress = account;
    }
    
    //TODO Add onlyOwner
    function updateFeeAddress(address account) public onlyOwner {
        feeAddress = account;
    }

    function getStakingInfo(address user)
        external
        view
        returns (
            uint256[] memory,
            uint256[] memory,
            uint256[] memory,
            uint256[] memory
        )
    {
        uint256 length = amounts[user].length;
        uint256[] memory claimables = new uint256[](length);
        uint256 i;
        for (i = 0; i < length; ++i) {
            claimables[i] = claimableAt(user, times[user][i]);
        }
        return (amounts[user], times[user], harvests[user], claimables);
    }
}