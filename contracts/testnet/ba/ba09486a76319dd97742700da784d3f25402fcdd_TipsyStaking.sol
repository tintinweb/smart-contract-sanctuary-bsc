/**
 *Submitted for verification at BscScan.com on 2022-07-05
*/

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

// File: @openzeppelin/contracts/utils/Address.sol


// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// File: @openzeppelin/contracts/proxy/utils/Initializable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;


/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !Address.isContract(address(this));
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


// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

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
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
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
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;


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

// File: contracts/staking.sol


// Based on Synthetix and PancakeSwap staking contracts
pragma solidity 0.8.13;








interface IGinMinter {
    function mintTo(
        address _mintTo,
        uint256 _amount
    ) external returns (bool);

    function allocateGin(
        address _mintTo,
        uint256 _allocatedAmount
    ) external;
}

interface ITipsy is IERC20Metadata {
    function _reflexToReal(
        uint _amount
    ) external view returns (uint256);

    function _realToReflex(
        uint _amount
    ) external view returns (uint256);

}
//We use a slightly customised Ownable contract, to ensure it works nicely with our proxy setup
//And to prevent randos from initializing / taking over the base contract
abstract contract Ownable is Context {
    address private _owner;
    address public keeper;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event KeeperTransferred(address indexed previousKeeper, address indexed newKeeper);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
	//transfer to non 0 addy during constructor when deploying 4real to prevent our base contracts being taken over. Ensures only our proxy is usable
        //_transferOwnership(address(~uint160(0)));
        _transferOwnership(address(uint160(0)));
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
        require(owner() == _msgSender(), "TipsyOwnable: caller is not the owner");
        _;
    }

    modifier onlyOwnerOrKeeper()
    {
      require(owner() == _msgSender() || keeper == _msgSender(), "TipsyOwnable: caller is not the owner or not a keeper");   
      _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() external virtual onlyOwner {
        _transferOwnership(address(0x000000000000000000000000000000000000dEaD));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function transferKeeper(address _newKeeper) external virtual onlyOwner {
        require(_newKeeper != address(0), "Ownable: new Keeper is the zero address");
        emit KeeperTransferred(keeper, _newKeeper);
        keeper = _newKeeper;
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

    function initOwnership(address newOwner) public virtual {
        require(_owner == address(0), "Ownable: owner already set");
        require(newOwner != address(0), "Ownable: new owner can't be 0 address");
        _owner = newOwner;
        emit OwnershipTransferred(address(0), newOwner);
    }
}
/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 */

contract TipsyStaking is Ownable, Initializable, Pausable, ReentrancyGuard {

    //Private / Internal Vars
    //Not private for security reasons, just to prevent clutter in bscscan
    uint8 internal _levelCount;
    address internal TipsyAddress;
    address internal ginAddress;

    //Public Vars
    mapping(address => UserInfo) public userInfoMap;
    mapping(uint8 => StakingLevel) public UserLevels; 
    mapping(uint8 => string) public LevelNames; 
    uint256 public totalWeight;
    ITipsy public TipsyCoin;
    IGinMinter public GinBridge;
    uint public lockDuration;
    uint public ginDripPerUser; //Max amount per user to drip per second
    bool actualMint; //Are we actually live yet?
    address public constant DEAD_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    //Structs
    struct UserInfo {
        uint256 lastAction;
        uint256 lastWeight;
        //RewardDebt currently written but not read. May be used in part of future ecosystem - don't remove
        uint256 rewardDebt;
        uint256 lastRewardBlock;
        uint256 rewardEarnedNotMinted;
        uint8 userLevel;
        uint256 userMulti;
    }

    struct StakingLevel{
        //Minimum staked is in reflexSpace, and must be converted to realSpace before comparisons are made internally
        uint256 minimumStaked; //REFLEX SPACE
        uint256 multiplier; //1e4 == 1000 == 1x
    }

    //Events
    event GinAllocated(
        address indexed user,
        address indexed amount
    );

    event LiveGin(
        address indexed ginAddress,
        bool indexed live
    );

    event LockDurationChanged(
        uint indexed oldLock,
        uint indexed newLock
    );

    event Staked(
        address indexed from,
        uint indexed amount,
        uint indexed newTotal
    );

    event Unstaked(
        address indexed to,
        uint indexed amount,
        uint indexed newTotal
    );

    event LevelModified(
        address indexed to,
        uint indexed amount,
        uint indexed newTotal
    );

    event UserKicked(
        address indexed userKicked,
        uint8 indexed newLevel,
        uint indexed newMultiplier,
        bool adminKick
    );

    //View Functions
    function reflexToReal(uint _reflexAmount) public view returns (uint){
        return TipsyCoin._reflexToReal(_reflexAmount);
    }  

    function realToReflex(uint _realAmount) public view returns (uint){

        return TipsyCoin._realToReflex(_realAmount);
    }

    function getLockDurationOK(address _user) public view returns (bool)
    {
        //Returns whether lock duration is over. Staking resets duration, unstaking won't.
        return userInfoMap[_user].lastAction + lockDuration <= block.timestamp;   
    }

    //Front end needs to know how much gin has been allocated to a user, but not sent out yet
    //This function returns EARNED, BUT NOT LIVE Gin 
    //Function should not be used once Gin distribution begins on Polygon
    function getAllocatedGin(address _user) public view returns (uint _amount)
    {
        return userInfoMap[_user].rewardEarnedNotMinted;
    }

    //Important method, used to calculate how much gin to give to user
    //Easy to get the math wrong here
    function harvestCalc(address _user) public view returns (uint _amount)
    {
        if (userInfoMap[_user].lastWeight == 0)
        {
            return 0;
        }
        else
        {
        //return (block.timestamp - userInfoMap[_user].lastRewardBlock) * ginDripPerUser * UserLevels[userInfoMap[_user].userLevel].multiplier/1e3;
        //Use cached User level multi
        return (block.timestamp - userInfoMap[_user].lastRewardBlock) * ginDripPerUser * userInfoMap[_user].userMulti/1e3;
        }
    }

    function getStakeReflex(address user) public view returns (uint)
    {
        return TipsyCoin._realToReflex(userInfoMap[user].lastWeight + 1);
    }

    //Unused by contract now, but may be useful for frontend
    function getLevelByWeight(uint realWeight) public view returns (uint8)
    {
        return getLevel(TipsyCoin._realToReflex(realWeight + 1));
    }

    function getLevel(uint amountStaked) public view returns (uint8)
    {
        //amountStaked MUST BE IN reflexSpace
        //MinimumStake MUST BE IN reflexSpace
        //for loop not ideal here, but are only 3 levels planned, so not a big deal
        uint baseLine = UserLevels[0].minimumStaked;

        if (amountStaked < baseLine) return ~uint8(0);
        else {
            for (uint8 i = 1; i < _levelCount; i++)
            {
                if (UserLevels[i].minimumStaked > amountStaked) return i-1;
            }
        return _levelCount-1;
        }
    }

    //Not used in code, but may be useful for front end to easily show reflex space staked balance to user
    function getUserBal(address _user) public view returns (uint)
    {
        return (TipsyCoin._realToReflex(userInfoMap[_user].lastWeight));
    }

    //Testing View Params
    //added for TESTING
    function getUserRewardBlock(address _user) public view returns (uint256) 
    {
        return userInfoMap[_user].lastRewardBlock;
    }

    function getUserRewardDebt(address _user) public view returns (uint256) 
    {
        return userInfoMap[_user].rewardDebt;
    }

    function getLevelName(uint amountStaked) public view returns (string memory)
    {
        //AMOUNT STAKED MUST BE IN REFLEX SPACE
        uint8 _stakingLevel = getLevel(amountStaked + 1);
        return LevelNames[_stakingLevel];
    }

    //Not used in contract, may still be useful for FrontEnd
    function getUserLvlTxt_Cached(address _user) public view returns (string memory _level)
    {
        _level = LevelNames[ userInfoMap[_user].userLevel ];
        return _level;
    }

    //Public Write Functions


    //New stake strategy is to convert reflex 'amount' to real_amount and use real_amount as weight 
    //Need to store user tier after staking so tier adjustments don't mess it
    function stake(uint _amount) public whenNotPaused returns (uint)
    {
        //We have to be careful about a first harvest, because userLevel inits to 0, which is an actual real level
        //And lastRewardBlock will init to 0, too, so a bazillion tokens will be allocated
        harvest();
        //Convert reflex space _amount, into real space amount. +1 to prevent annoying division rounding errors
        //uint realAmount = reflexToReal(_amount + 1);
        //TipsyCoin public methods like transferFrom take reflex space params
        uint _prevBal = TipsyCoin.balanceOf(address(this));
        require(TipsyCoin.transferFrom(msg.sender, address(this), _amount), "Tipsy: transferFrom user failed");
        uint realAmount = TipsyCoin._reflexToReal(TipsyCoin.balanceOf(address(this))+1 - _prevBal);

        //Measure all weightings in real space
        userInfoMap[msg.sender].lastAction = block.timestamp;
        userInfoMap[msg.sender].lastWeight += realAmount;
        userInfoMap[msg.sender].userLevel = getLevel(getStakeReflex(msg.sender));
        userInfoMap[msg.sender].userMulti = UserLevels[userInfoMap[msg.sender].userLevel].multiplier;

        //Require user's stake be at a minimum level. Reminder that 255 is no level
        require(userInfoMap[msg.sender].userLevel < 255, "Tipsy: Amount staked insufficient for rewards");

        totalWeight += realAmount;
        emit Staked(msg.sender, _amount, userInfoMap[msg.sender].lastWeight);
        return _amount;
    }

    //Users may only unstake all tokens they have staked
    //Unstaking does not reset 3 month timer (pointless) 
    function unstakeAll() public whenNotPaused returns (uint _tokenToReturn)
    {
        require(getLockDurationOK(msg.sender), "Tipsy: Can't unstake before Lock is over");
        require(userInfoMap[msg.sender].lastWeight > 0, "Tipsy: Your staked amount is already Zero");
        harvest();
        //Calculate balance to return. Gets a bit difficult with reflex rewards
        //_tokenToReturn = TipsyCoin.balanceOf(address(this)) * userInfoMap[msg.sender].lastWeight / totalWeight;
	_tokenToReturn = TipsyCoin._realToReflex(userInfoMap[msg.sender].lastWeight) - 1;
        emit Unstaked(msg.sender, _tokenToReturn, 0);

        totalWeight -= userInfoMap[msg.sender].lastWeight;
        userInfoMap[msg.sender].lastWeight = 0;
        userInfoMap[msg.sender].userLevel = 255; //~0 is no level
        userInfoMap[msg.sender].userMulti = 0; //No multi

        //Transfer to user, check return
        require(TipsyCoin.transfer(msg.sender, _tokenToReturn), "Tipsy: transfer to user failed");
        return _tokenToReturn;
    }

    //Maybe? Only allow emergency withdraw if paused, and user forfeits any pending harvest
    function EmergencyUnstake() public whenPaused nonReentrant returns (uint _tokenToReturn)
    {
        require(userInfoMap[msg.sender].lastWeight > 0, "Tipsy: Can't unstake (no active stake)");
        _tokenToReturn = TipsyCoin._realToReflex(userInfoMap[msg.sender].lastWeight) - 1;
        emit Unstaked(msg.sender, _tokenToReturn, 0);
        totalWeight -= userInfoMap[msg.sender].lastWeight;
        userInfoMap[msg.sender].lastWeight = 0;
        userInfoMap[msg.sender].userLevel = 255; //~0 is no level
        userInfoMap[msg.sender].userMulti = 0; //No multi

        //do a transfer to user
        require(TipsyCoin.transfer(msg.sender, _tokenToReturn), "Tipsy: transfer to user failed");
        return _tokenToReturn;
    }

        function harvest() public whenNotPaused nonReentrant returns(uint _harvested)
    {
        //Calculate how many tokens have been earned
        _harvested = harvestCalc(msg.sender);
        userInfoMap[msg.sender].lastRewardBlock = block.timestamp;
        if (_harvested == 0) return 0;
        //Do a switch based on whether we're live Minting or just Allocating
        if (!actualMint)
        {
            userInfoMap[msg.sender].rewardEarnedNotMinted += _harvested;
        }
        else if (actualMint && userInfoMap[msg.sender].rewardEarnedNotMinted > 0)
        {
            _harvested = _harvested + userInfoMap[msg.sender].rewardEarnedNotMinted;
            userInfoMap[msg.sender].rewardEarnedNotMinted = 0;
            userInfoMap[msg.sender].rewardDebt += _harvested;
            GinBridge.mintTo(msg.sender, _harvested);
        }
        else
        {
            userInfoMap[msg.sender].rewardDebt += _harvested;
            GinBridge.mintTo(msg.sender, _harvested);
        }
        return _harvested;
    }

    function kick() public whenNotPaused
    {
        //User may use this to sync their level and multiplier, without needing to stake more tokens and reset their lock
        //Used if for e.g. we adjust the tiers to require a lower amount of Tipsy or increase the rewards per tier
        harvest();
        userInfoMap[msg.sender].userLevel = getLevel(getStakeReflex(msg.sender));
        userInfoMap[msg.sender].userMulti = UserLevels[userInfoMap[msg.sender].userLevel].multiplier;
        emit UserKicked(msg.sender, userInfoMap[msg.sender].userLevel, userInfoMap[msg.sender].userMulti, false);
    }

    //Restricted Write Functions

    function setGinAddress(address _gin) public onlyOwner
    {
        require (_gin != address(0));
        GinBridge = IGinMinter(_gin);
        actualMint = true;
        ginAddress = _gin;
        require (GinBridge.mintTo(DEAD_ADDRESS, 1e18), "Tipsy: Couldn't test-mint some Gin");
        emit LiveGin(_gin, actualMint);
    }


    function adminKick(address _user) public onlyOwnerOrKeeper whenPaused
    {
        //Admin Kick() for any user. Just so we can update old weights and multipliers if they're not behaving properly
        //May only be used when Paused
        userInfoMap[_user].userLevel = getLevel(getStakeReflex(_user));
        userInfoMap[_user].userMulti = UserLevels[userInfoMap[_user].userLevel].multiplier;
        emit UserKicked(_user, userInfoMap[_user].userLevel, userInfoMap[_user].userMulti, true);
    }

    function setLockDuration(uint _newDuration) public onlyOwner
    {
        //Sets lock duration in seconds. Default is 90 days, or 7776000 seconds
        lockDuration = _newDuration;
    }


    function addLevel(uint8 _stakingLevel, uint amountStaked, uint multiplier) public
    {
        require(UserLevels[_stakingLevel].minimumStaked == 0, "Not a new level");
        setLevel(_stakingLevel, amountStaked, multiplier);
        _levelCount++;
    }

    function setLevel(uint8 stakingLevel, uint amountStaked, uint _multiplier) public onlyOwnerOrKeeper
    {
        //SET LEVEL AMOUNT MUST BE IN REFLEX SPACE
        require(stakingLevel < ~uint8(0), "reserved for no stake status");
        if (stakingLevel == 0)
        {
            require(UserLevels[stakingLevel+1].minimumStaked == 0 || 
                    UserLevels[stakingLevel+1].minimumStaked > amountStaked, "Tipsy: staking amount set too high for Lv0");
        }
        else{
            require(UserLevels[stakingLevel-1].minimumStaked < amountStaked, "Tipsy: staking amount too low for level");
            require(UserLevels[stakingLevel+1].minimumStaked > amountStaked || UserLevels[stakingLevel+1].minimumStaked == 0, "Tipsy: staking amount too high for level");
        }
        UserLevels[stakingLevel].minimumStaked = amountStaked;
        UserLevels[stakingLevel].multiplier = _multiplier;
    }

    function setLevelName(uint8 stakingLevel, string memory _name) public onlyOwnerOrKeeper
    {
        LevelNames[stakingLevel] = _name;
    }

    function deleteLevel(uint8 stakingLevel) public onlyOwnerOrKeeper returns (bool)
    {
        require(stakingLevel == _levelCount-1, "Tipsy: Must delete Highest level first");
        UserLevels[stakingLevel].minimumStaked = 0;
        UserLevels[stakingLevel].multiplier = 0;
        _levelCount--;
        return true;
    }

    function pause() public onlyOwnerOrKeeper whenNotPaused
    {
        _pause();
    }

    function unpause() public onlyOwnerOrKeeper whenPaused
    {
        _unpause();
    }

    //Initializer Functions

    //Constructor is for Testing only. Real version should be initialized() as we're using proxies
    constructor(address _tipsyAddress)
    {   
        //Owner() = 48 hours Timelock owned by multisig will be used
        //Timelock found here: https://bscscan.com/address/0xe50B0004DC067E5D2Ff6EC0f7bf9E9d8Eb1E83a6
        //Multisig here: https://bscscan.com/address/0x884c908ea193b0bb39f6a03d8f61c938f862e153
        //Keeper will be an EOA

        initialize(msg.sender, msg.sender, _tipsyAddress);
        //stake(50e6 * 10 ** TipsyCoin.decimals());
        //require(getAllocatedGin(msg.sender) == 0, "Shoudn't be more than zero here");
        //Do anyother setup here
        //_transferOwnership(0xe50B0004DC067E5D2Ff6EC0f7bf9E9d8Eb1E83a6);
    }

    function initialize(address owner_, address _keeper, address _tipsyAddress) public initializer
    {   
        require(_keeper != address(0), "Tipsy: keeper can't be 0 address");
        require(owner_ != address(0), "Tipsy: owner can't be 0 address");
        require(_tipsyAddress != address(0), "Tipsy: Tipsy can't be 0 address");
        keeper = _keeper;
        TipsyAddress = _tipsyAddress;
        initOwnership(owner_);
        lockDuration = 90 days;
        actualMint = false;
        TipsyCoin = ITipsy(TipsyAddress);
        //AddLevel amount MUST BE IN REAL SPACE
        //AddLevel multiplier 1000 = 1x
        addLevel(0, 20e6 * 10 ** TipsyCoin.decimals()-100, 1000); //10 Million $tipsy, 1x
        addLevel(1, 100e6 * 10 ** TipsyCoin.decimals()-100, 6000); //100 Million $tipsy, 6x
        addLevel(2, 200e6 * 10 ** TipsyCoin.decimals()-100, 14000); //200 Million $tipsy, 14x
        setLevelName(0, "Tier I");
        setLevelName(1, "Tier II");
        setLevelName(2, "Tier III");
        setLevelName(~uint8(0), "No Stake");
        //AddLevel = Level, Amount Staked, Multiplier
        //GinDrip is PER SECOND, PER USER, based on a multiplier of 1000 (1x)
        ginDripPerUser = 1157407407407407; //100 Gin per day = 100×1e18 / 24 / 60 / 60
        //require(TipsyCoin._realToReflex(1e18) >= 1e18, "TipsyCoin: test check fail");
    }
}