/**
 *Submitted for verification at BscScan.com on 2023-01-07
*/

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
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

// File: @openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol


// OpenZeppelin Contracts (last updated v4.8.0) (proxy/utils/Initializable.sol)

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
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
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
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
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
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initialized`
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initializing`
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
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

// File: database.sol


pragma solidity ^0.8.0;



contract database is Initializable{
     address public admin;
    // IERC20 public immutable token;
    // storageP2P public storageP2p;
    address public tokenA;
    address public tokenB;

    function initialize() external initializer{
        admin = payable(msg.sender);
        // token = IERC20(0x11d1149202fbb7eeeA118BCEb85db1D7eAA3084A);
        tokenA = 0x428c89b700A673c49Af726786398552eE5dd2687;
        tokenB = 0x8ee8818eE9508b7bAD5197Ffd2466e02e8795515;

    }







  ////////////////////////////////////////////////////
  ////////////////////////////////////////////////////
  ////////////////////////////////////////////////////
  ///////////////GENERAL FUNCTIONS////////////////////
  ////////////////////////////////////////////////////
  ////////////////////////////////////////////////////



    function _transfer(address _token, address reciever, uint amount) external returns(bool){
  
        if(msg.sender == p2pCaller || msg.sender == poolCaller || msg.sender == extraCaller || msg.sender == admin){
            
            IERC20Upgradeable token = IERC20Upgradeable(_token);

            token.transfer(reciever, amount);

            return true;
        }else{
         revert("Unauthorised address");   
        }
       
   }

   
    function normalTransfer(address _token, address reciever, uint amount) internal returns(bool){
        
        IERC20Upgradeable token = IERC20Upgradeable(_token);

        token.transfer(reciever, amount);  
        
        return true;
   }










  ////////////////////////////////////////////////////
  ////////////////////////////////////////////////////
  ////////////////////////////////////////////////////
  ////////////////POOL FUNCTIONS//////////////////////
  ////////////////////////////////////////////////////
  ////////////////////////////////////////////////////







    mapping(address => mapping(string => mapping(uint => uint))) public poolBetidToStake;
    mapping(address => mapping(string => mapping(uint => address))) public poolTokenToStake;
    mapping(string => uint) public poolBetIdtoTotal;
    mapping(string => uint) public poolBetCount;
    mapping(address => mapping(string => mapping(uint => bool))) public poolBetidToClaimed;
    mapping(address => mapping(string => mapping(uint => bool))) public poolStaked;
    mapping(string => bool) public poolFullyClaimed;
    mapping(string => string) public poolGame;
    mapping(string => address) public poolFirstAddress;

    mapping(string => address) public poolfirstAddress;
    mapping(string => bool) public poolBetidStored;
    mapping(uint => string) public poolIndextoBetid;
    uint public poolBetidNumber;

    string[] public poolBetidArray;



    
    function poolSaveStakeData(address _token, address staker, string calldata  betid,uint transactionID, uint stakeAmount, string calldata game) external{
            
            require(msg.sender == poolCaller, "You are not allowed to call");
            
            if(!poolBetidStored[betid]){
                poolBetidStored[betid] = true;
                poolBetidNumber++;   
                poolBetidArray.push(betid);
                poolIndextoBetid[poolBetidNumber];

            }

            poolBetidToStake[staker][betid][transactionID] += stakeAmount;
            poolBetIdtoTotal[betid] += stakeAmount;
            poolBetCount[betid] +=1;
            poolTokenToStake[staker][betid][transactionID] = _token;
            poolStaked[staker][betid][transactionID] = true;


            poolGame[betid] = game;

    }



    function setPoolFirstAddress(address _token, string calldata betid) external{
        require(msg.sender == poolCaller, "You are not allowed to call");
        poolFirstAddress[betid] =_token;
    }

function poolSaveFinalise(string calldata betid, uint transactionID, address reciever, uint amount, uint newamount, uint fee, bool last) external{
        require(msg.sender == poolCaller, "You are not allowed to call");
        poolBetidToClaimed[reciever][betid][transactionID] = true;        
        delete poolBetidToStake[reciever][betid][transactionID];

        poolBetIdtoTotal[betid] -= amount;

        adminTotaFee[poolTokenToStake[reciever][betid][transactionID]] += fee;

        poolLastClaim(poolTokenToStake[reciever][betid][transactionID], betid, last, poolBetIdtoTotal[betid]);

              
        if (bonus == true && poolTokenToStake[reciever][betid][transactionID] == bonusAddress){
          poolBonus(newamount, reciever);
        }

   }

    function poolBonus(uint amount, address reciever) internal{
        

         amount = amount * bonusPercent/ 10000;
         if(amount > maxBonusAmount){

             amount = maxBonusAmount;
         }

        normalTransfer(bonusAddress, reciever, amount);

    }

   
  function poolLastClaim(address _token, string calldata betid, bool last, uint residual) internal{
        poolFullyClaimed[betid] = last;

        if(poolFullyClaimed[betid]){
            totalResiduals[_token] += residual;
        }
    }

    
        
    function _poolGetStaked(string calldata  betid, uint transactionID, address staker) external view returns(bool){
        require(msg.sender == poolCaller, "You are not allowed to call");
        return poolStaked[staker][betid][transactionID];
    }

    function _poolGetFinalised(string calldata  betid, uint transactionID, address reciever) external view returns(bool){
        require(msg.sender == poolCaller, "You are not allowed to call");
        return poolBetidToClaimed[reciever][betid][transactionID];
    }

    function poolGetStake(string calldata betid, uint transactionID, address staker) external view returns(uint){
        require(msg.sender == poolCaller, "You are not allowed to call");
        return poolBetidToStake[staker][betid][transactionID];
    }
    function poolGetTotalStake(string calldata betid) external view returns(uint){
        require(msg.sender == poolCaller, "You are not allowed to call");
        return poolBetIdtoTotal[betid];
    } 
    function _poolGetTokenToStake(string calldata betid, uint transactionID, address reciever) external view returns(address){
        require(msg.sender == poolCaller, "You are not allowed to call");
        return poolTokenToStake[reciever][betid][transactionID];
    }
    function getPoolBetCount(string calldata betid) external view returns(uint){
        require(msg.sender == poolCaller, "You are not allowed to call");
        return poolBetCount[betid];
    }
    function getPoolFirstAddress(string calldata betid) external view returns (address){
        require(msg.sender == poolCaller, "You are not allowed to call");
        return poolFirstAddress[betid];
    }

















  ////////////////////////////////////////////////////
  ////////////////////////////////////////////////////
  ////////////////////////////////////////////////////
  /////////////////P2P FUNCTIONS//////////////////////
  ////////////////////////////////////////////////////
  ////////////////////////////////////////////////////




    mapping(address => mapping(string => uint)) public p2pBetidToStake;
    mapping(address => mapping(string => address)) public p2pTokenToStake;
    mapping(string => uint) public P2PBetIdtoTotal;
    mapping(string => uint) public p2pBetCount;
    mapping(address => mapping(string => bool)) public p2pBetidToClaimed;
    mapping(address => mapping(string => bool)) public p2pStaked;
    mapping(string => bool) public p2pfullyClaimed;
    mapping(string => string) public p2pGame;
    mapping(string => address) public p2pfirstAddress;
    mapping(string => bool) public p2pBetidStored;
    mapping(uint => string) public p2pIndextoBetid;
    uint public p2pBetidNumber;

    string[] public p2pBetidArray;
   

    function p2pSaveStakeData(address _token, address staker, string calldata  betid, uint stakeAmount, string calldata game) external{
            
            require(msg.sender == p2pCaller, "You are not allowed to call");

            if(!p2pBetidStored[betid]){
                p2pBetidStored[betid] = true;
                p2pBetidNumber++;   
                p2pBetidArray.push(betid);
                p2pIndextoBetid[p2pBetidNumber];

            }
 
            p2pBetidToStake[staker][betid] += stakeAmount;
            P2PBetIdtoTotal[betid] += stakeAmount;
            p2pBetCount[betid] +=1;
            p2pTokenToStake[staker][betid] = _token;

            p2pStaked[staker][betid] = true;
            
            p2pGame[betid] = game;

    }



    function setP2PFirstAddress(address _token, string calldata betid) external{
        require(msg.sender == p2pCaller, "You are not allowed to call");
        p2pfirstAddress[betid] =_token;
    }


    function p2pSaveFinalise(string calldata betid, address reciever, uint amount, uint newamount, uint fee, bool last) external{
        require(msg.sender == p2pCaller, "You are not allowed to call");
        
        p2pBetidToClaimed[reciever][betid] = true;        
        delete p2pBetidToStake[reciever][betid];

        P2PBetIdtoTotal[betid] -= amount;

        adminTotaFee[p2pTokenToStake[reciever][betid]] += fee;

        p2pLastClaim(p2pTokenToStake[reciever][betid], betid, last, P2PBetIdtoTotal[betid]);

              
        if (bonus == true && p2pTokenToStake[reciever][betid] == bonusAddress){
          p2pBonus(newamount, betid, reciever);
        }

   }

    function p2pBonus(uint amount, string calldata betid, address reciever) internal{
        

         amount = amount * bonusPercent/ 10000;
         if(amount > maxBonusAmount){

             amount = maxBonusAmount;
         }

        normalTransfer(p2pTokenToStake[reciever][betid], reciever, amount);

    }

   
  function p2pLastClaim(address _token, string calldata betid, bool last, uint residual) internal{
        p2pfullyClaimed[betid] = last;

        if(p2pfullyClaimed[betid]){
            totalResiduals[_token] += residual;
        }
    }

    
        
    function _p2pGetStaked(string calldata  betid, address staker) external view returns(bool){
        require(msg.sender == p2pCaller, "You are not allowed to call");
        return p2pStaked[staker][betid];
    }

    function _p2pGetFinalised(string calldata  betid, address reciever) external view returns(bool){
        require(msg.sender == p2pCaller, "You are not allowed to call");
        return p2pBetidToClaimed[reciever][betid];
    }

    function p2pGetStake(string calldata betid, address staker) external view returns(uint){
        require(msg.sender == p2pCaller, "You are not allowed to call");
        return p2pBetidToStake[staker][betid];
    }
    function p2pGetTotalStake(string calldata betid) external view returns(uint){
        require(msg.sender == p2pCaller, "You are not allowed to call");
        return P2PBetIdtoTotal[betid];
    } 
    function _p2pGetTokenToStake(string calldata betid, address reciever) external view returns(address){
        require(msg.sender == p2pCaller, "You are not allowed to call");
        return p2pTokenToStake[reciever][betid];
    }
    function getBetCount(string calldata betid) external view returns(uint){
        require(msg.sender == p2pCaller, "You are not allowed to call");
        return p2pBetCount[betid];
    }
    function getFirstAddress(string calldata betid) external view returns (address){
        require(msg.sender == p2pCaller, "You are not allowed to call");
        return p2pfirstAddress[betid];
    }






























  ////////////////////////////////////////////////////
  ////////////////////////////////////////////////////
  ////////////////////////////////////////////////////
  ///////////////ADMIN FUNCTIONS//////////////////////
  ////////////////////////////////////////////////////
  ////////////////////////////////////////////////////



    
    mapping (address => uint) public adminTotaFee;
    mapping (address => uint) public totalResiduals;

    bool public bonus;
    uint public bonusPercent;
    uint public maxBonusAmount;
    address public bonusAddress;
    address public p2pCaller;
    address public poolCaller;
    address public extraCaller;

    function getTotalResidue(address _token) external view returns(uint){
          require(msg.sender == admin, "Not Admin");
        return totalResiduals[_token];
    }


            
     function withdrawFees(address _token, uint amount) external{
        require(msg.sender == admin, "Not Admin");
        require(amount <= adminTotaFee[_token], "Insufficient Amount in Balance");

        IERC20Upgradeable token = IERC20Upgradeable(_token);
        adminTotaFee[_token] -= amount;

        token.transfer(admin, amount);

        
    }
    
    function adminResidualWithdraw(address _token) external{
          require(msg.sender == admin, "Not Admin");
          require(totalResiduals[_token] > 0, "No Residuals Available");
        
        IERC20Upgradeable token = IERC20Upgradeable(_token);

          uint residual = totalResiduals[_token];

          delete totalResiduals[_token];

          token.transfer(admin, residual);
    }

    function setBonus(bool _bonus) external{
        require(msg.sender == admin, "Not Admin");

        bonus = _bonus;
    }

    function bonusDetails(address _bonusAddress, uint _max, uint percent) external{
        require(msg.sender == admin, "Not Admin");
        require(bonus, "Bonus not set");

        maxBonusAmount = _max;
        bonusPercent = percent;
        bonusAddress = _bonusAddress;

    }

    function setP2Pcaller(address caller) external{
     require(msg.sender == admin, "Not Admin");

     p2pCaller = caller;

    }


    function setPoolCaller(address _caller) external{
        require(msg.sender == admin, "Not Admin");
        poolCaller = _caller;

    }
    
    function setExtraCaller(address caller) external{
        require(msg.sender == admin, "Not Admin");
        extraCaller = caller;

    }

    function _Migrate(address migrator) external{
        require(msg.sender == admin, "Not Admin");

        IERC20Upgradeable token = IERC20Upgradeable(tokenA);

        
        normalTransfer(tokenA, migrator, token.balanceOf(address(this)));


        IERC20Upgradeable token2 = IERC20Upgradeable(tokenB);

        normalTransfer(tokenB, migrator, token2.balanceOf(address(this)));


    }


}
// File: Pool.sol


pragma solidity ^0.8.0;




contract LogicPool is Initializable{

    address public admin;
    database public dataStorage;

    address public tokenA;
    address public tokenB;
    
    bool public isContractPaused;

    event GameName(string gamename);
    

    function initialize() external initializer{
        admin = payable(msg.sender);
        // token = IERC20(0xe10DCe92fB554E057619142AbFBB41688A7e8D07);
        tokenA = 0x428c89b700A673c49Af726786398552eE5dd2687;
        tokenB = 0x8ee8818eE9508b7bAD5197Ffd2466e02e8795515;
        dataStorage = database(0x1C1a11285a94B63E2468ac5F7bb5F64A5B086255);

    }
    


    receive() external payable{}

    function _Stake(address _token,  uint stakeAmount, address staker) internal returns(bool success){
            IERC20Upgradeable token = IERC20Upgradeable(_token);

            token.transferFrom(staker, address(dataStorage), stakeAmount);

            return true;
        
    }
    

    function Stake(address _token, string calldata  betid, string calldata game, uint transactionID, uint stakeAmount) external{
      require(!isContractPaused, "Contract is paused");
      if (_token == tokenA || _token == tokenB){
            
            if(dataStorage.getPoolBetCount(betid) == 0){
                    dataStorage.setPoolFirstAddress(_token, betid);
                    
                }else{
                    
                    require(_token == dataStorage.getPoolFirstAddress(betid), "Token not used in bet");
                    
            }

            bool success = _Stake(_token, stakeAmount, msg.sender);

            require(success, "transfer Failed");

            dataStorage.poolSaveStakeData(_token, msg.sender, betid, transactionID, stakeAmount, game);

   
            emit GameName(game);

        }else{
            revert("Unknown Token");
        }
     

    }

    function creditsStake(address _token, string calldata  betid, string calldata game, uint transactionID, uint stakeAmount) external{
         require(!isContractPaused, "Contract is paused");
         if (_token == tokenA || _token == tokenB){
            
            if(dataStorage.getPoolBetCount(betid) == 0){
                    dataStorage.setPoolFirstAddress(_token, betid);
                    
                }else{
                    
                    require(_token == dataStorage.getPoolFirstAddress(betid), "Token not used in bet");
                    
            }


            dataStorage.poolSaveStakeData(_token, msg.sender, betid, transactionID, stakeAmount, game);

   
            emit GameName(game);

        }else{
            revert("Unknown Token");
        }


    }

    function getpoolStaked(string calldata  betid, uint transactionID, address staker) external view returns(bool){
        return dataStorage._poolGetStaked(betid, transactionID, staker);
    }

    function getFinalised(string calldata  betid, uint transactionID, address reciever) public view returns(bool){
        return dataStorage._poolGetFinalised(betid, transactionID, reciever);
    }




    function end(string calldata  betid, uint transactionID, uint amount, uint fee, bool last) external{
        require(!isContractPaused, "Contract is paused");
        require(!getFinalised(betid, transactionID, msg.sender), "Address already claimed");
        
        uint stake = dataStorage.poolGetStake(betid, transactionID, msg.sender);
        uint totalStake = dataStorage.poolGetTotalStake(betid);

        require(amount <= totalStake, "Insufficient Amount in balance");
        require(stake > 0, "Did Not Stake");
         
        uint newamount = amount;
        
        bool success = dataStorage._transfer(dataStorage._poolGetTokenToStake(betid, transactionID, msg.sender), msg.sender, amount);
        require(success, "Transfer Not Successful");
        
        
        amount+= fee;

        dataStorage.poolSaveFinalise(betid, transactionID, msg.sender, amount, newamount, fee, last);
        
        

    }

  function setDataStorage(address newStorage) external{
        require(msg.sender == admin, "Not Admin");
        require(isContractPaused, "Pause the contract first");

        dataStorage = database(newStorage);
    }

    function pauseContract(bool pause) external{
        require(msg.sender == admin, "Not Admin");
        isContractPaused = pause;
    }

    
}