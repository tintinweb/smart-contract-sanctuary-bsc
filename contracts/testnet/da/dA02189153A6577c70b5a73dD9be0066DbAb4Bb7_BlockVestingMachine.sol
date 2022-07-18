/**
 *Submitted for verification at BscScan.com on 2022-07-17
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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

// File: @openzeppelin/contracts/security/Pausable.sol


// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// File: bv_vesting_noproxy.sol


pragma solidity ^0.8.0;





contract BlockVestingMachine is Ownable, ReentrancyGuard, Pausable {

    IERC20 public token;

    struct ClaimProfile {
        uint total_claimable;
        uint last_claimed_block; // need to update on every claim
        uint total_claimed; // need to update on every claim
        uint direct_vested_allocation;
        uint vesting_allocation;
        bool vesting_started;
    }

    uint public constant blockInOneMonth = 864000; // 30 * 24 * 60 * ( 60 / 3 )
    uint public constant secondPerBlock = 3;
    uint public direct_vested_release_time;
    uint public vesting_release_time;
    uint public vesting_duration; // in month

    mapping(address => ClaimProfile) public claimOf;

    event Claimed(address indexed account, uint256 amount);

    constructor() {
        token = IERC20(0xE8968C576e1567BE7778d84f7830a80cec85265c);

        direct_vested_release_time = 0; // 1658153700
        vesting_release_time = 1658153700; // 18 JULY 2022 1415 UTC , 1658153700
        vesting_duration = 17; // 17
    }

    function setToken(address _token) external onlyOwner {
        token = IERC20(_token);
    }

    function updateTGE(uint _direct_vested_release_time) external onlyOwner {
        direct_vested_release_time = _direct_vested_release_time;
    }

    function updateVesting(uint _vesting_release_time, uint _vesting_duration) external onlyOwner {
        vesting_release_time = _vesting_release_time;
        vesting_duration = _vesting_duration;
    }

    function claimAmount(address _account) public view returns (uint _amount) {

        if (block.timestamp < direct_vested_release_time) return 0;

        if (claimOf[_account].total_claimed >= claimOf[_account].total_claimable ) return 0; // fully released

        uint amount = 0;
        uint block_vested = 0;

        if ( claimOf[_account].last_claimed_block == 0 ) { 
            amount = claimOf[_account].direct_vested_allocation;
            
            if ( block.timestamp >= vesting_release_time ) {
                block_vested = ( block.timestamp - vesting_release_time ) / secondPerBlock; // 3 blocks per second
                if (block_vested > 0) amount = amount + ( claimOf[_account].vesting_allocation * block_vested / ( vesting_duration * blockInOneMonth ) );
            }
            
        } else {
            // need to handle case if tge and vesting start is different
            if ( block.timestamp >= vesting_release_time ) {

                block_vested = ( block.timestamp - vesting_release_time ) / secondPerBlock; // 3 blocks per second

                if (claimOf[_account].vesting_started) {
                    block_vested = block.number - claimOf[_account].last_claimed_block;
                }

                amount = claimOf[_account].vesting_allocation * block_vested / ( vesting_duration * blockInOneMonth );
            }
            
        }

        return amount;
    }

    function setClaimAmount(address[] calldata _address, uint256[] calldata _direct_amount, uint256[] calldata _vesting_amount) external onlyOwner {
        require(_address.length == _direct_amount.length, "Array is not matched.");
        require(_vesting_amount.length == _direct_amount.length, "Array2 is not matched.");

        for(uint i=0; i<_address.length; i++) {
            claimOf[_address[i]].direct_vested_allocation = _direct_amount[i];
            claimOf[_address[i]].vesting_allocation = _vesting_amount[i];
            claimOf[_address[i]].total_claimable = claimOf[_address[i]].direct_vested_allocation + claimOf[_address[i]].vesting_allocation;
        }
    }

    function claim() external whenNotPaused nonReentrant {

        uint amount = 0;
        uint block_vested = 0;

        if ( claimOf[msg.sender].last_claimed_block == 0 ) { 
            amount = claimOf[msg.sender].direct_vested_allocation;
            
            if ( block.timestamp >= vesting_release_time ) {
                block_vested = ( block.timestamp - vesting_release_time ) / secondPerBlock; // 3 blocks per second
                if (block_vested > 0) amount = amount + ( claimOf[msg.sender].vesting_allocation * block_vested / ( vesting_duration * blockInOneMonth ) );
            }
            
        } else {
            // need to handle case if tge and vesting start is different
            if ( block.timestamp >= vesting_release_time ) {

                block_vested = ( block.timestamp - vesting_release_time ) / secondPerBlock; // 3 blocks per second

                if (claimOf[msg.sender].vesting_started) {
                    block_vested = block.number - claimOf[msg.sender].last_claimed_block;
                }

                amount = claimOf[msg.sender].vesting_allocation * block_vested / ( vesting_duration * blockInOneMonth );
            }
            
        }

        if (block.timestamp < direct_vested_release_time) amount = 0;

        if (claimOf[msg.sender].total_claimed >= claimOf[msg.sender].total_claimable ) amount = 0; // fully released

        // uint amount = this.claimAmount(msg.sender);
        
        require(amount <= claimOf[msg.sender].total_claimable, "Invalid claim.");
        require(block.timestamp >= direct_vested_release_time, "TGE not yet started.");
        if ( amount >= (claimOf[msg.sender].total_claimable - claimOf[msg.sender].total_claimed) ) amount = claimOf[msg.sender].total_claimable - claimOf[msg.sender].total_claimed;

        claimOf[msg.sender].last_claimed_block = block.number;
        claimOf[msg.sender].total_claimed = claimOf[msg.sender].total_claimed + amount;

        if(block.timestamp >= vesting_release_time) {
            claimOf[msg.sender].vesting_started = true;
        }
        
        token.transfer(msg.sender, amount);
        emit Claimed(msg.sender, amount);
    }

    function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyOwner {
        IERC20(tokenAddress).transfer(msg.sender, tokenAmount);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

}