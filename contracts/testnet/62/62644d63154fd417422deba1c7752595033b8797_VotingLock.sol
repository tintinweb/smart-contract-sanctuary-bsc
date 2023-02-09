/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

/**
 *Submitted for verification at BscScan.com on 2023-02-08
*/

// SPDX-License-Identifier: BSL 1.1
pragma solidity ^0.8.13;

//import "./openzeppelin/token/IERC20/IERC20.sol";
//import "./openzeppelin/access/Ownable.sol";
//import "./util/TimeDependent.sol";
//import "./VotingManager.sol";


/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
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
abstract contract Ownable is Context {
    address private _owner;

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
}


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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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

    constructor () {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
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


contract VotingLock is Ownable, ReentrancyGuard
{
    struct Lock {
        uint256 amountLocked;
        uint256 startTime;
        uint256 expirationTime;
        uint256 weeksLocked;
        bool hasWithdrawn;
    }

	uint256 ONE_WEEK = 1 minutes;

    IERC20 public lockedToken;
//  VotingManager public votingManager;

    uint256 public maxWeeksLocked = 52;

	// Historical locks to determine user vested amount at any time
	mapping(address => Lock[]) public locksForWallet;	// [wallet]


    event LockCreated(
        address indexed wallet,
        uint256 amountLocked,
        uint256 indexed expirationTimestamp );

    event ExpandLock(
        address indexed wallet,
        uint256 amountAdded,
		uint256 weeksExtended );

    event Withdrawal(
        address indexed wallet,
        uint256 amountWithdrawn );



	constructor()
	{
		lockedToken = IERC20(0x8DFb025853e10184036ec64cAEE471cB6EC3949c);
	}


//	function setVotingManager( address _votingManager ) external onlyOwner
//	{
//		votingManager = VotingManager( _votingManager );
//	}


	function setMaxWeeksLocked( uint256 _maxWeeksLocked ) external onlyOwner
	{
		maxWeeksLocked = _maxWeeksLocked;
	}


	function hasActiveLock( address wallet ) public view returns (bool)
	{
		Lock[] memory locks = locksForWallet[wallet];

		// Can't be active without any locks
		if ( locks.length == 0 )
			return false;

		// Make sure the most recent lock is still active
		Lock memory lock = locks[ locks.length - 1 ];

		return block.timestamp < lock.expirationTime;
	}


	function _markAllLocksAsWithdrawn( address wallet ) internal
	{
		Lock[] storage locks = locksForWallet[wallet];

		for( uint256 i = 0; i < locks.length; i++ ){
			if(locks[i].hasWithdrawn == false)
				locks[i].hasWithdrawn = true;
		}

	}


	function _markRecentLockAsWithdrawn( address wallet ) internal
	{
		Lock[] storage locks = locksForWallet[wallet];

		locks[ locks.length - 1 ].hasWithdrawn = true;
	}


	function mostRecentLock( address wallet ) public view returns (Lock memory)
	{
		Lock[] memory locks = locksForWallet[wallet];

		require( locks.length >= 1, "No locks found for wallet" );

		return locks[ locks.length - 1 ];
	}


	// Voting power is the amountLocked * weeksLocked
	// The voting power is constant over the life of the Lock
	// Unlike Curve's implementation, it doesn't decay linearly over time
	function userVotingPowerAtTime( address wallet, uint256 time ) public view returns (uint256)
	{
		Lock[] memory locks = locksForWallet[wallet];

		if ( locks.length == 0 )
			return 0;

		// Cycle backward through the user's locks and and find one at the given time
		// Locks cannot overlap and still be relevant so there will only be one of them (at most)
        uint256 power = 0;
		for( uint256 i = locks.length - 1; i >= 0; i--)
		{
			Lock memory lock = locks[i];

			if ( lock.startTime <= time ){
                if ( time < lock.expirationTime ){
                    power = lock.amountLocked * lock.weeksLocked;
                    break;
                }
            }
		}
		return power;
	}


	function userCurrentVotingPower( address wallet ) public view returns (uint256)
	{
		return userVotingPowerAtTime( wallet, block.timestamp );
	}


	function createLock( uint256 numberOfTokens, uint256 weeksLocked ) external nonReentrant
	{
		address wallet = msg.sender;

        require( weeksLocked <= maxWeeksLocked, "Trying to lock for too many weeks" );
		require( weeksLocked >= 1, "Have to lock for at least one week" );
		require( ! hasActiveLock( wallet ), "Wallet already has an active lock" );

		uint expirationTime = block.timestamp + weeksLocked * ONE_WEEK;

		Lock memory lock = Lock( numberOfTokens, block.timestamp, expirationTime, weeksLocked, false );
		locksForWallet[wallet].push( lock );

		// Deposit the tokens
        lockedToken.transferFrom( wallet, address(this), numberOfTokens );
        emit LockCreated( wallet, numberOfTokens, expirationTime );
	}

	function minimumWeekExtension(address wallet)public view returns (uint256){
		if(!hasActiveLock(wallet))
			return 0;
		
		Lock memory recentLock = mostRecentLock(wallet);
		uint256 passingWeek = (block.timestamp - recentLock.startTime)/ONE_WEEK;
		if(passingWeek <= recentLock.weeksLocked/2)
			return 0;
		else
			return passingWeek;
	}

	function expandLock(uint256 addedTokens, uint256 weeksExtended) external nonReentrant
	{
		address wallet = msg.sender;

		require(hasActiveLock(wallet), "No existing active lock for wallet" );
		Lock memory recentLock = mostRecentLock( wallet );

		if(addedTokens > 0){
			require(weeksExtended >= minimumWeekExtension(wallet), "You add more token then adding time have to meet minimum");
			lockedToken.transferFrom( wallet, address(this), addedTokens );
		}else {
			// Dont add token, just extend time
			require( weeksExtended >= 1, "Have to extend at least one week" );
		}

				// The old tokens won't be withdrawable any more as the tokens will be
		// accounted for in a new adjusted lock
		_markRecentLockAsWithdrawn(wallet);

		uint256 remainingWeek = recentLock.weeksLocked - (block.timestamp - recentLock.startTime)/ONE_WEEK;
		uint256 newWeeksLocked = remainingWeek + weeksExtended;
		require( newWeeksLocked <= maxWeeksLocked, "Trying to lock for too many weeks(limit 52)");
		uint256 newExpirationTime = block.timestamp + newWeeksLocked * ONE_WEEK;

		// Same tokens as before, but more weeks locked for more votingPower
		Lock memory newAdjustedLock = Lock( recentLock.amountLocked + addedTokens, block.timestamp, newExpirationTime, newWeeksLocked, false );
        locksForWallet[wallet].push(newAdjustedLock);

		emit ExpandLock(wallet, addedTokens, weeksExtended);
	}


	function amountWithdrawable( address wallet ) public view returns (uint256)
	{
		Lock[] memory locks = locksForWallet[wallet];

		uint256 sum = 0;
		for( uint256 i = 0; i < locks.length; i++ )
		{
			Lock memory lock = locks[i];

			// Make sure the lock hasn't been withdrawn and has been unlocked
			if (( !lock.hasWithdrawn ) && ( block.timestamp >= lock.expirationTime ))
				sum = sum + lock.amountLocked;
		}

		return sum;
	} 

	function amountLocked( address wallet ) public view returns (uint256)
	{
		if(!hasActiveLock(wallet))
			return 0;

		Lock memory recentLock = mostRecentLock( wallet );
		return recentLock.amountLocked;
	} 



	// Withdraws all the available tokens from the locks
	function withdraw() external nonReentrant
	{
		address wallet = msg.sender;

		require(!hasActiveLock(wallet), "Can't withdraw with a lock still active" );

		uint256 amountToWithdraw = amountWithdrawable( wallet );

       	lockedToken.transfer( wallet, amountToWithdraw );
       	emit Withdrawal( wallet, amountToWithdraw );

       	_markAllLocksAsWithdrawn( wallet );
	}
}