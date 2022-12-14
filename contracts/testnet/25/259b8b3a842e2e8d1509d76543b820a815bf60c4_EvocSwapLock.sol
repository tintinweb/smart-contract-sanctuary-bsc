/**
 *Submitted for verification at BscScan.com on 2022-12-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-09
*/

// SPDX-License-Identifier: MIT

// MFET - Lock Contract

// Feel free to use

// Mens et Manus
pragma solidity 0.8.17;

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

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }
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
}

contract EvocSwapLock is Context, ReentrancyGuard {
    using Counters for Counters.Counter;

    Counters.Counter private _lockId;

    // Lock needs
    struct Items {
        address user;
        uint256 amount;
        uint256 unlockTime;
        address token;
        uint256 isWithdrawn;
    }

    // Main lock mapping
    mapping(uint256 => Items) private _lockedToken;

    // With this mapping easy to find wallet balance
    mapping(address => mapping(address => uint256)) private _walletTokenBalance;

    // Get lock details of an address
    mapping(address => mapping(address => uint256[])) private _locksByAddress;

    // Get lock details of an token
    mapping(address => uint256[]) private _locksByToken;

    // Set a min timestamp
    uint256 private _minTimestamp = 1 * 10**10;

    // Events for deposit, withdrawal and extend duration
    event LogWithdrawal(address Token, address To, uint256 Amount);
    event LogDeposit(address Token, address From, uint256 Amount);
    event LogExtendDuration(
        uint256 Id,
        uint256 OldTimestamp,
        uint256 NewTimestamp
    );

    // Get total token balance in contract
    function getContractTotalTokenBalance(address token)
        public
        view
        returns (uint256)
    {
        return IERC20(token).balanceOf(address(this));
    }

    // Get last lock id
    /// this function returns a private value in contract
    function getLastLockId() external view returns (uint256) {
        return _lockId.current();
    }

    // Get single lock details
    function getLockDetails(uint256 id)
        external
        view
        returns (
            address user,
            uint256 amount,
            uint256 unlockTime,
            uint256 isWithdrawn,
            address token
        )
    {
        return (
            _lockedToken[id].user,
            _lockedToken[id].amount,
            _lockedToken[id].unlockTime,
            _lockedToken[id].isWithdrawn,
            _lockedToken[id].token
        );
    }

    // Get deposits by withdrawal address
    /// use to list locks make it easy to show in frontend
    function getLocksByWithdrawalAddress(address token, address wallet)
        external
        view
        returns (uint256[] memory)
    {
        return _locksByAddress[token][wallet];
    }

    // Get locks by token address
    /// to get a all locks ids according to token
    function getLocksByTokenAddress(address token)
        external
        view
        returns (uint256[] memory)
    {
        return _locksByToken[token];
    }

    // Create lock in contract
    function createLock(
        address user,
        uint256[] memory amounts,
        uint256[] memory unlockTimes,
        address token
    ) external nonReentrant {
        uint256 totalLockAmount = _createLock(
            user,
            amounts,
            unlockTimes,
            token
        );
        emit LogDeposit(token, _msgSender(), totalLockAmount);
    }

    //  Lock internal function
    function _createLock(
        address user,
        uint256[] memory amounts,
        uint256[] memory unlockTimes,
        address token
    ) internal returns (uint256) {
        // limit to 100
        require(
            amounts.length > 0 && amounts.length <= 100,
            "Array length cannot be zero"
        );
        require(
            unlockTimes.length > 0 && unlockTimes.length <= 100,
            "Array length cannot be zero"
        );
        require(amounts.length == unlockTimes.length, "Array length must same");

        uint256 a;
        uint256 u;

        // calculate total amount for check allowance
        uint256 totalLockAmount;
        for (a = 0; a < amounts.length; a++) {
            require(amounts[a] > 0, "Amount cannot be zero");
            totalLockAmount = totalLockAmount + amounts[a];
        }

        // check allowance
        uint256 allowance = IERC20(token).allowance(
            _msgSender(),
            address(this)
        );

        require(allowance >= totalLockAmount, "Allowance error");

        for (u = 0; u < unlockTimes.length; u++) {
            ///  block.timestamp is not critical we can use it
            require(
                unlockTimes[u] < _minTimestamp &&
                    unlockTimes[u] > block.timestamp,
                "Timestamp error"
            );

            _lockId.increment();
            uint256 id = _lockId.current();

            _lockedToken[id].user = user;
            _lockedToken[id].amount = amounts[u];
            _lockedToken[id].unlockTime = unlockTimes[u];
            _lockedToken[id].token = token;
            _lockedToken[id].isWithdrawn = 0;

            // push id to address array
            _locksByAddress[token][user].push(id);

            // push id to token array
            _locksByToken[token].push(id);
        }

        // user send tokens to lock contract
        IERC20(token).transferFrom(
            _msgSender(),
            address(this),
            totalLockAmount
        );

        // update balance in address at once
        /// before update value waiting for transfer success
        _walletTokenBalance[token][user] =
            _walletTokenBalance[token][user] +
            totalLockAmount;

        return totalLockAmount;
    }

    // Extend Lock duration
    function extendLockDuration(uint256 id, uint256 newUnlockTime)
        external
        nonReentrant
    {
        require(_lockedToken[id].isWithdrawn == 0, "Amount already withdrawn");
        /// only locked token owner can do this.
        require(
            _msgSender() == _lockedToken[id].user,
            "This is not your token"
        );
        /// block.timestamp is not critical we can use it
        require(
            newUnlockTime < _minTimestamp && newUnlockTime > block.timestamp,
            "Timestamp error"
        );
        require(newUnlockTime > _lockedToken[id].unlockTime, "Date error");

        //set new unlock time
        _lockedToken[id].unlockTime = newUnlockTime;

        /// timestamp change emit it
        emit LogExtendDuration(id, _lockedToken[id].unlockTime, newUnlockTime);
    }

    // Withdraw tokens from contract
    function withdrawTokens(uint256 id) external nonReentrant {
        /// to clean view for token contract address
        address _token = _lockedToken[id].token;
        require(_lockedToken[id].isWithdrawn == 0, "Amount already withdrawn");
        require(
            _msgSender() == _lockedToken[id].user,
            "This is not your token"
        );
        require(
            _walletTokenBalance[_token][_msgSender()] >=
                _lockedToken[id].amount,
            "Cannot withdraw then you have"
        );
        require(
            getContractTotalTokenBalance(_token) >= _lockedToken[id].amount,
            "Contract balance error"
        );

        _lockedToken[id].isWithdrawn = 1;

        // update balance in address
        _walletTokenBalance[_token][_msgSender()] =
            _walletTokenBalance[_token][_msgSender()] -
            _lockedToken[id].amount;

        // everything is ok now, transfer tokens to wallet address
        IERC20(_token).transfer(_msgSender(), _lockedToken[id].amount);

        emit LogWithdrawal(_token, _msgSender(), _lockedToken[id].amount);
    }
}
// Made with love.