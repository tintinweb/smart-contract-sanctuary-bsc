/**
 *Submitted for verification at BscScan.com on 2022-08-23
*/

// File: @openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.14;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
                /// @solidity memory-safe-assembly
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

// File: @openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;


/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
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
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

// File: @openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol


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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// File: @openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol


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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// File: @openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol


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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// File: @openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

// File: escrow.sol


//SPDX-License-Identifier: MIT
// File: escrows/Address.sol
pragma solidity ^0.8.14;




contract Escrow is ReentrancyGuardUpgradeable,OwnableUpgradeable {
     using AddressUpgradeable for address payable;

    enum State{initiated,paid,disputed}
    

    // Struct typed data structure to represent each Proposal and its information inside
    struct proposal{
        uint256 id;
        address buyer;
        address payable seller;
        uint256 amt;
        uint256 time;
        bool accepted;
        uint256 payTokenType;
    }

   // Struct typed data structure to represent each Escrow and its information inside
    struct instance{
        uint256 id;
        address buyer;
        address payable seller;
        uint256 payTokenType; // 0 if BNB/ 1 if LKN tokens /2 if BUSD Token
        uint256 totalAmt;
        uint256 amtPaid;
        bool sellerConfirmation;
        bool buyerConfirmation;
        uint256 start;
        uint256 timeInDays;
        State currentState;
    }
    
     // Info of each pool.
    struct PoolInfo {
        IERC20Upgradeable token;           // Address of token contract.
    }


    //Liquiduty pool address
    address payable public liquidityPool;

    //Admin adress
    address payable public admin;

    // Burn Address
    address payable public burnAddress;
    
    // Total number of Proposals 
    uint256 public proposalCount;
    
    // Mapping for storing each proposal
    mapping(uint256=>proposal) public getProposal;

    // Mapping for storing each Escrow
    mapping(uint256 => instance) public getEscrow;

    //mapping for storing BNBamounts corresponding to each Escrow
    mapping(uint256=>uint256) public escrowAmtsBNB;
    
    //mapping for storing Tokenamounts corresponding to each Escrow
    mapping(uint256=>uint256) public escrowAmtsToken;

    // Mapping for BNB balances to store if they send directly to this smart contract
    mapping(address => uint256) balances;
     
    address public signer;

    // Owner cut
    uint8 public ownerCut;

    // PoolCut
     uint8 public PoolCut;

    // Admin Cut for Non-Token Based
    uint8 public adminCutBNB;
    
    // Admin Cut Token Based
    uint8 public adminCutLKN;
    
    // Burn Cut for Non-Token Based
    uint8 public burnCutBNB;
    
    // Burn Cut for Token Based
    uint8 public burnCutLKN;
    
    // Buyer refelction
    uint8 public buyerRef;


    //Mapping to store Disputed Escrow ID with the Disputer Address(Who raised dispute)
    mapping(uint256=> address) public disputedRaisedBy;

    //Mapping to store Escrow creator with Escrow Ids
    mapping(address=>uint256) public AddressEscrowMap;
    mapping(address => bool) whitelistedAddresses;

    // Total Number of Escrows
    uint256 public totalEscrows;

    // Max number of time limit(in Days)
    uint256 public timeLimitInDays;

    // Array to store all disputed escrows
    uint256[] public disputedEscrows;
 
    // Array to store Info of each pool.
    PoolInfo[] public poolInfo;
     mapping(uint256 => bool) private usedNonce;

    struct Sign {
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 nonce;
    }
    
    // Event emitter type when Escrow will be created
    event EscrowCreated(
        uint256 id,
        address buyer,
        address payable seller,
        uint256 payTokenType,
        uint256 paid,
        uint256 start,
        uint256 timeInDays,
        State currentState
    );
    // Proposal emitter type when Proposal will be created
     event ProposalCreated(
        uint256 id,
        address buyer,
        address payable seller,
        uint256 payTokenType,
        uint256 paid,
        uint256 start,
        uint256 timeInDays
    );
    

    // State change event emitter
    event StateChanged(uint256 indexed id,State indexed _state);


  
    
 
    modifier isWhitelisted(address _address) {
  require(whitelistedAddresses[_address], "You need to be whitelisted");
  _;
  }

    constructor() {
    
    }

    function initialize(uint256 _timeLimitInDays,address payable _admin,address payable _liquidityPool,address payable _burnAddress,uint8 fees,uint8 _adminBNB,uint8 _adminLKN,uint8 _poolCut,uint8 _burnCutBNB,uint8 _burnCutLKN,uint8 _buyerRef) external initializer{
        burnAddress = _burnAddress;
        admin = _admin;
        liquidityPool = _liquidityPool;
        totalEscrows =0;
        timeLimitInDays = _timeLimitInDays;
        ownerCut = fees;
        PoolCut = _poolCut;
        adminCutBNB=_adminBNB;
        adminCutLKN=_adminLKN;
        burnCutBNB=_burnCutBNB;
        burnCutLKN=_burnCutLKN;
        buyerRef= _buyerRef;
        signer = msg.sender;
         __Ownable_init();
         __ReentrancyGuard_init();
        
        poolInfo.push(PoolInfo({token: IERC20Upgradeable(address(0x31ACFCE536B824ad0739E8D7b27CEFAa4b8E4673))}));
        poolInfo.push(PoolInfo({token: IERC20Upgradeable(address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56))}));
    }
    

    // Function to set tax %age and also update it and it can only be called by admin
    function setFeesAdminPoolCut(uint8 fees,uint8 _adminBNB,uint8 _adminLKN,uint8 _poolCut,uint8 _burnCutBNB,uint8 _burnCutLKN,uint8 _buyerRef) public onlyOwner {
        ownerCut = fees;
        PoolCut = _poolCut;
        adminCutBNB=_adminBNB;
        adminCutLKN=_adminLKN;
        burnCutBNB=_burnCutBNB;
        burnCutLKN=_burnCutLKN;
        buyerRef= _buyerRef;
        
    }
    // Function to create each proposal along with all the info needed
    function createProposal(uint256 amt,uint256 time,uint256 payType) public payable {
        require(msg.value >=amt);
        address payable _seller = payable(address(0));
        proposalCount++;
        uint256 _id = proposalCount;
        getProposal[_id]=proposal(_id,msg.sender,_seller,amt,time,false,payType);
        emit ProposalCreated(_id,msg.sender,_seller,payType,amt,block.timestamp,time);
    }
    
    // Function to accept each proposal along with all the info needed and Creating ESCROW in the end
    function acceptProposal(uint256 _id, Sign calldata sign) public nonReentrant {
          require(!usedNonce[sign.nonce],"Nonce : Invalid Nonce");
          usedNonce[sign.nonce] = true;
          isVerifiedSign(_id,sign);
        require(!getProposal[_id].accepted,"already accepted");
        getProposal[_id].seller = payable(msg.sender);
        getProposal[_id].accepted = true;
        proposal memory temp = getProposal[_id];
        if(temp.payTokenType ==0){
            createEscrowBNB(temp.buyer,temp.seller,temp.amt,temp.time);   
        }else {
            createEscrowToken(temp.buyer,temp.payTokenType,temp.seller,temp.amt,temp.time);
        }
        
    }
       function isVerifiedSign( uint256 _id, Sign calldata sign) internal view {
        bytes32 hash = keccak256(abi.encodePacked(msg.sender,_id, sign.nonce));
        require(signer == verifySigner(hash, sign), " sign verification failed");
    }

  
     
     // Function to create proposals for Tokens based 
    function createProposalToken(uint256 amt, uint256 taxAmt, uint256 time,uint256 payTokenType) internal {
        PoolInfo storage pool = poolInfo[payTokenType-1];
        IERC20Upgradeable token = pool.token;
        require(token.balanceOf(address(msg.sender))>=taxAmt,"You dont have enough Tokens");
        address payable _seller = payable(address(0));
        proposalCount++;
        uint256 _id = proposalCount;
        token.transferFrom(address(msg.sender), address(this), taxAmt);
        getProposal[_id]=proposal(_id,msg.sender,_seller,amt,time,false,payTokenType);
        emit ProposalCreated(_id,msg.sender,_seller,payTokenType,amt,block.timestamp,time);
    }

    // Function to create milestone proposals for Tokens based
    function createProposalMileStoneToken(uint256[] calldata amounts, uint256[] calldata taxAmts, uint256[] calldata times,uint256[] calldata payType) public {
           uint256 len = amounts.length;
           for(uint256 i=0;i<len;i++){
                createProposalToken(amounts[i], taxAmts[i], times[i],payType[i]);
           }
    }

    // Function to create milestone proposals for Non-Token based
    function createProposalMileStone(uint256[] calldata amounts,uint256 sum, uint256[] calldata times,uint256[] calldata payType) public payable {
           require(msg.value>=sum,"You arent depositing enough funds");
           uint256 len = amounts.length;
           for(uint256 i=0;i<len;i++){
                createProposal(amounts[i],times[i],payType[i]);
           }
    }
    
    // Function to accept milestone proposals
    function acceptProposalMilestone(uint256[] calldata _ids, Sign calldata sign) public nonReentrant {
           uint256 len = _ids.length;
             require(!usedNonce[sign.nonce],"Nonce : Invalid Nonce");
                 usedNonce[sign.nonce] = true;
          isVerifiedSign(_ids[0],sign);
           for(uint256 i=0;i<len;i++){
        require(!getProposal[_ids[i]].accepted,"already accepted");
        getProposal[_ids[i]].seller = payable(msg.sender);
        getProposal[_ids[i]].accepted = true;
        proposal memory temp = getProposal[_ids[i]];
        if(temp.payTokenType ==0){
            createEscrowBNB(temp.buyer,temp.seller,temp.amt,temp.time);   
        }else {
            createEscrowToken(temp.buyer,temp.payTokenType,temp.seller,temp.amt,temp.time);
        }
              //  acceptProposal(_ids[i],sign[i]);
           }
    }
    
    // Function to create Escrow of type Non-Token Based
    function createEscrowBNB(address _buyer,address payable _seller,uint256 amt,uint256 timeInDays) internal {
        require(timeInDays <= timeLimitInDays,"timePeriod more than limit");
        totalEscrows++;
        uint256 id = totalEscrows;
        getEscrow[id]= instance(id,_buyer,_seller,0,amt,0,false,false,block.timestamp,timeInDays,State.initiated);
        escrowAmtsBNB[id] = amt;
        AddressEscrowMap[_buyer] = id;
        emit EscrowCreated(id,_buyer,_seller,0,amt,block.timestamp,timeInDays,State.initiated);
    }

    // Function to create Escrow of type Token Based
    function createEscrowToken(address __buyer,uint256 _tokenID,address payable _seller,uint256 amt,uint256 timeInDays) internal {
        require(timeInDays <= timeLimitInDays,"timePeriod more than limit");
        totalEscrows++;
        uint256 id = totalEscrows;
        getEscrow[id]= instance(id,__buyer,_seller,_tokenID,amt,0,false,false,block.timestamp,timeInDays,State.initiated);
        escrowAmtsToken[id] = amt;
        AddressEscrowMap[__buyer] = id;
        emit EscrowCreated(id,__buyer,_seller,_tokenID,amt,block.timestamp,timeInDays,State.initiated);
    }

    // Function to release Payments associated with each Escrow ID
    function releasePayment(uint256 _id) public nonReentrant{
        instance memory temp = getEscrow[_id];
        require(msg.sender == temp.buyer,"you are not a seller");
        require(temp.currentState != State.disputed, 'Unalbe to release payment, Escrow in dispute state');
        require(!getEscrow[_id].buyerConfirmation,"Buyer already confirmed");
        delete getEscrow[_id];

        if(temp.payTokenType ==0){
            uint256 Temp= escrowAmtsBNB[_id];
            uint256 _PoolCut = ceilDiv((PoolCut*Temp),10000);
            uint256 _adminCut = ceilDiv((adminCutBNB*Temp),10000);//service fee
            uint256 _burnCut = ceilDiv((burnCutBNB*Temp),10000);
            escrowAmtsBNB[_id] = 0;
            temp.seller.sendValue(Temp);
            admin.sendValue(_adminCut);
            burnAddress.sendValue(_burnCut);
            liquidityPool.sendValue(_PoolCut);
        }

        else if (temp.payTokenType ==1){
            PoolInfo storage pool = poolInfo[temp.payTokenType-1];
            IERC20Upgradeable token = pool.token;
            uint256 _temp = escrowAmtsToken[_id];
            
            uint256 buyerReflection= ceilDiv((buyerRef * _temp),10000);
            uint256 _adminCut = ceilDiv((adminCutLKN * _temp),10000);
            uint256 _burnCut = ceilDiv((burnCutLKN * _temp),10000);
            escrowAmtsToken[_id] = 0;   
            token.transfer(temp.seller,_temp);
            token.transfer(admin,_adminCut);
            token.transfer(burnAddress,_burnCut);
            token.transfer(temp.buyer, buyerReflection);
        }
        else{
            PoolInfo storage pool = poolInfo[temp.payTokenType-1];
            IERC20Upgradeable token = pool.token;
            uint256 _temp = escrowAmtsToken[_id];
            uint256 _adminCut = ceilDiv((adminCutBNB * _temp),10000);
            uint256 _burnCut = ceilDiv((burnCutBNB * _temp),10000);
            uint256 _PoolCut = ceilDiv((PoolCut * _temp),10000);
            escrowAmtsToken[_id] = 0;   
            token.transfer(temp.seller,_temp);
            token.transfer(admin,_adminCut);
            token.transfer(burnAddress,_burnCut);
            token.transfer(liquidityPool, _PoolCut);
        }
        getEscrow[_id].buyerConfirmation=true;
        getEscrow[_id].currentState = State.paid;
    }
    function requestPayment(uint256 _id) public nonReentrant{
        instance memory temp = getEscrow[_id];
        require(block.timestamp >= temp.start + temp.timeInDays *  1 days ,"Wait Until the Release Payment Day" );
        require(msg.sender == temp.seller,"you are not a buyer");
        require(temp.currentState != State.disputed, 'Unalbe to release payment, Escrow in dispute state');
        require(!getEscrow[_id].buyerConfirmation,"Buyer already confirmed");
        delete getEscrow[_id];

        if(temp.payTokenType ==0){
            uint256 Temp= escrowAmtsBNB[_id];
            uint256 _PoolCut = ceilDiv((PoolCut * Temp),10000);
            uint256 _adminCut = ceilDiv((adminCutBNB * Temp),10000);//service fee
            uint256 _burnCut = ceilDiv((burnCutBNB * Temp),10000);
            escrowAmtsBNB[_id] = 0;
            temp.seller.sendValue(Temp);
            admin.sendValue(_adminCut);
            burnAddress.sendValue(_burnCut);
            liquidityPool.sendValue(_PoolCut);
        }

        else if (temp.payTokenType ==1){
            PoolInfo storage pool = poolInfo[temp.payTokenType-1];
            IERC20Upgradeable token = pool.token;
            uint256 _temp = escrowAmtsToken[_id];
            
            uint256 buyerReflection= ceilDiv((buyerRef * _temp),10000);
            uint256 _adminCut = ceilDiv((adminCutLKN * _temp),10000);
            uint256 _burnCut = ceilDiv((burnCutLKN * _temp),10000);
            escrowAmtsToken[_id] = 0;   
            token.transfer(temp.seller,_temp);
            token.transfer(admin,_adminCut);
            token.transfer(burnAddress,_burnCut);
            token.transfer(temp.buyer, buyerReflection);
        }
        else{
            PoolInfo storage pool = poolInfo[temp.payTokenType-1];
            IERC20Upgradeable token = pool.token;
            uint256 _temp = escrowAmtsToken[_id];
            uint256 _adminCut = ceilDiv((adminCutBNB * _temp),10000);
            uint256 _burnCut = ceilDiv((burnCutBNB * _temp),10000);
            uint256 _PoolCut = ceilDiv((PoolCut * _temp),10000);
            escrowAmtsToken[_id] = 0;   
            token.transfer(temp.seller,_temp);
            token.transfer(admin,_adminCut);
            token.transfer(burnAddress,_burnCut);
            token.transfer(liquidityPool, _PoolCut);
        }
        getEscrow[_id].buyerConfirmation=true;
        getEscrow[_id].currentState = State.paid;
    }


    //Function to raise dispute by rightful users
    function raiseDispute(uint256 id) public nonReentrant{
        require(msg.sender == getEscrow[id].seller || msg.sender == getEscrow[id].buyer);
        require(!getEscrow[id].buyerConfirmation || !getEscrow[id].sellerConfirmation);
        require(getEscrow[id].currentState != State.disputed);
        getEscrow[id].currentState = State.disputed;
        disputedEscrows.push(id);
        disputedRaisedBy[id] == msg.sender;
        emit StateChanged(id, getEscrow[id].currentState);
    }

     function approveForWithdraw(uint256 id,bool withdrawParty) public isWhitelisted(msg.sender) nonReentrant { //onlyOwner function
            // withdrawParty -- true if buyer,false if seller
            require(getEscrow[id].currentState == State.disputed);
            instance memory temp = getEscrow[id];
            if(withdrawParty){
            if(temp.payTokenType ==0){
                 payable(getEscrow[id].buyer).sendValue(escrowAmtsBNB[id]);
            }
            else if(temp.payTokenType==1)
                {
                PoolInfo storage pool = poolInfo[temp.payTokenType-1];
                IERC20Upgradeable token = pool.token;
                uint256 _temp = escrowAmtsToken[id];
                escrowAmtsToken[id] = 0;
                token.transfer(temp.buyer,_temp);

                }
            else{
                PoolInfo storage pool = poolInfo[temp.payTokenType-1];
                IERC20Upgradeable token = pool.token;
                uint256 _temp = escrowAmtsToken[id];
                escrowAmtsToken[id] = 0;
                token.transfer(temp.buyer,_temp);
                }

            }
            else if(!withdrawParty){
            if(temp.payTokenType ==0)
            {
                getEscrow[id].seller.sendValue(escrowAmtsBNB[id]);
            }
            else if (temp.payTokenType ==1){
                PoolInfo storage pool = poolInfo[temp.payTokenType-1];
                IERC20Upgradeable token = pool.token;
                uint256 _temp = escrowAmtsToken[id];
                escrowAmtsToken[id] = 0;
                token.transfer(temp.seller,_temp);
                }
            else{
                PoolInfo storage pool = poolInfo[temp.payTokenType-1];
                IERC20Upgradeable token = pool.token;
                uint256 _temp = escrowAmtsToken[id];
                escrowAmtsToken[id] = 0;
                token.transfer(temp.seller,_temp);
            }


            }
            }
    
    // Function to cancel proposal before User B accepts the proposal and created Escrow
    function cancelProposal(uint256[] calldata _ids) public nonReentrant{
        uint256 len = _ids.length;
        for(uint256 _id=0;_id<len;_id++){
        uint256 id = _ids[_id];    
        require((getProposal[id].buyer==msg.sender) || (getProposal[id].seller == msg.sender),"You havent created this Proposal");
        require(!(getProposal[id].accepted), "Proposal accepted by seller, try raising dispute instead");
        uint256 _amount = getProposal[id].amt;
        if(getProposal[id].payTokenType ==0){
          payable(getProposal[id].buyer).sendValue(_amount);
        }
        else{
             PoolInfo storage pool = poolInfo[getProposal[id].payTokenType-1];
             IERC20Upgradeable token = pool.token;
             token.transfer(getProposal[id].buyer,_amount);
        }
        delete getProposal[id];
        }
    }
     function verifySigner(bytes32 hash, Sign memory sign) internal pure returns(address) {
        return ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)), sign.v, sign.r, sign.s); 
    }

     // Function to cancel Escrow and refund funds back to user A
    function cancelEscrow(uint256[] calldata _ids) public  nonReentrant{
        uint256 len = _ids.length;
        for(uint256 _id=0;_id<len;_id++){
        uint256 id = _ids[_id];    
        require((getEscrow[id].buyer==msg.sender) || (getEscrow[id].seller == msg.sender),"You havent created this Escrow");
        uint256 _amount = getEscrow[id].totalAmt;
        if(getEscrow[id].payTokenType ==0){
            payable(getEscrow[id].buyer).sendValue(_amount);
        }
        else{
             PoolInfo storage pool = poolInfo[getEscrow[id].payTokenType-1];
             IERC20Upgradeable token = pool.token;
             token.transfer(getEscrow[id].buyer,_amount);
        }
        delete getEscrow[id];
        }
    }

    function setCSAAddress(address _addressToWhitelist) public onlyOwner {
    whitelistedAddresses[_addressToWhitelist] = true;
    }

    
    function getPoolInfo(uint256 _id) public view returns(PoolInfo memory){
        return poolInfo[_id];
    }

    
    //Function to get all disputed Escrows
    function getDisputedEscrows() public view returns(uint256[] memory) {
        return disputedEscrows;
    }
    

    // Function for Ceil Devision
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }

     // Fallback function which gets triggered when someone sends BNB to this contracts address directly
    receive() external payable {
        balances[msg.sender] += msg.value;
    }
    // set New Signer 
    function setSigner(address _newSigner) external onlyOwner{
        signer=_newSigner;
    }

}