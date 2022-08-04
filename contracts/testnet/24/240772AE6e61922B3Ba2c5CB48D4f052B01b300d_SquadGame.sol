/**
 *Submitted for verification at BscScan.com on 2022-08-04
*/

// SPDX-License-Identifier: MIT
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

// File: @openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;




/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: contracts/1_august.sol



pragma solidity ^0.8.0;



contract SquadGameBasic {
   // address public impl;
    address public contractOwner;


    struct User {
        uint id;
        uint partnersCount;
        bool frozen;
        bool firstPayment;
        bool secPayment;
        address firstLevelReferrals; 
        address secondLevelReferrals;
        address thirdLevelReferrals;
        mapping(uint8 => bool) activeMainLevels;     
        mapping(uint8 => SmartMapping) smartMatrix;
    }
    
    struct SmartMapping {
        address currentReferrer;        
        bool bought;
        uint reinvestCount;
        address closedPart;
    }    

    uint256 public RegFee;
    uint8 public LAST_LEVEL;
    
    mapping(address => User) public users;
    mapping(uint => address) public idToAddress;
    mapping(uint => address) public userIds;
   // mapping(address => uint) public balances; 

    mapping(uint => LevelId) LevelPayments; 

    struct LevelId {
        uint[] Level_User_id;
        bool blocked;
    }

    uint public lastUserId;
    address public id1;
    address public secWallet;
    address public regWallet;
    
    mapping(uint8 => uint) public levelPrice;

    IERC20 public depositToken;
    
    uint public BASIC_PRICE;

    bool public locked;
    
    event Registration(address indexed user, address indexed referrer, uint indexed userId, uint referrerId);
    event Reinvest(address indexed user, address indexed currentReferrer, address indexed caller, uint8 matrix, uint8 level);
    event Upgrade(address indexed user, address indexed referrer, uint8 matrix, uint8 level);
    event NewUserPlace(address indexed user, address indexed referrer, uint8 matrix, uint8 level, uint8 place);
    event MissedEthReceive(address indexed receiver, address indexed from, uint8 matrix, uint8 level);
    event SentExtraEthDividends(address indexed from, address indexed receiver, uint8 matrix, uint8 level);
}


contract SquadGame is SquadGameBasic {
    using SafeERC20 for IERC20;

    constructor() {                 
        contractOwner = msg.sender;
    }

    modifier onlyContractOwner() { 
        require(msg.sender == contractOwner, "onlyOwner"); 
        _; 
    }

    modifier onlyUnlocked() { 
        require(!locked || msg.sender == contractOwner); 
        _; 
    }
    ////////////////////////////////////////ИНИЦИАЛИЗАЦИЯ КОНТРАКТА/////////////////////////////////////////
    function init(address _ownerAddress, address _secWallet, address _regWallet, IERC20 _depositTokenAddress) public onlyContractOwner {
        
        RegFee = 3e12;
        BASIC_PRICE = 5e12;
        LAST_LEVEL = 16;

        levelPrice[1] = BASIC_PRICE;
        for (uint8 i = 2; i <= 8; i++) {
            levelPrice[i] = levelPrice[i-1] * 14/10;
        }

        levelPrice[9] = 8e13;
        levelPrice[10] = 11e13;
        levelPrice[11] = 16e13;
        levelPrice[12] = 22e13;
        levelPrice[13] = 32e13;
        levelPrice[14] = 44e13;
        levelPrice[15] = 65e13;
        levelPrice[16] = 80e13;
        
        id1 = _ownerAddress;
        
        User storage user= users[_ownerAddress];       
            user.id=1;
            user.firstPayment = false;
            user.secPayment = false;
            user.firstLevelReferrals=address(0);
            user.secondLevelReferrals=address(0);
            user.thirdLevelReferrals=address(0);
            user.partnersCount=uint(0);
 
        // users[_ownerAddress] = user;
        idToAddress[1] = _ownerAddress;
        
        for (uint8 i = 1; i <= LAST_LEVEL; i++) {
            users[_ownerAddress].activeMainLevels[i] = true;
           // LevelPayments[i].Level_User_id.push(users[_ownerAddress].id);  
        }
        
        userIds[1] = _ownerAddress;
        lastUserId = 2;
        secWallet = _secWallet;
        regWallet = _regWallet;

        depositToken = _depositTokenAddress;

        locked = true;
    }

    function changeLock() external onlyContractOwner() {
        locked = !locked;
    }
    
    // fallback() external {
    //     if(msg.data.length == 0) {
    //         return registrationRef(msg.sender, id1);
    //     }        
    //     registrationRef(msg.sender, bytesToAddress(msg.data));
    // }

    ///////////////////////////////////////РЕГИСТРАЦИЯ БЕЗ РЕФЕРАЛА/////////////////////////
    function registr(address userAddress) public payable {
        require(!isUserExists(userAddress), "user exists");
        require(msg.value >= RegFee,"Wrong value");

        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }
        
        User storage user= users[userAddress];       
            user.id=lastUserId;
            user.firstPayment = false;
            user.secPayment = false;
            user.firstLevelReferrals=address(0);
            user.secondLevelReferrals=address(0);
            user.thirdLevelReferrals=address(0);
            user.partnersCount=uint(0);
        
        idToAddress[lastUserId] = userAddress;
        
        userIds[lastUserId] = userAddress;
        lastUserId++;
        sendRegFee();
    }

    ///////////////////////////////////////////ПОКУПКА НОВОГО УРОВНЯ///////////////////////////////////////////
    function buyNewLevel(address _userAddress, uint8 level) public payable{
        require(msg.sender==_userAddress,"Wrong sender");
        require(msg.value >= levelPrice[level],"Wrong value");
        require(!LevelPayments[level].blocked,"Level blocked");
      
        require(isUserExists(_userAddress), "user is not exists. Register first.");

        require(level >= 1 && level <= LAST_LEVEL, "invalid level");

        require(!users[_userAddress].activeMainLevels[level], "level already activated");   

        if(level<16)
        {
            require(users[_userAddress].activeMainLevels[level+1], "buy previous level first");         
        }               

        if (users[_userAddress].smartMatrix[level-1].bought) {
            users[_userAddress].smartMatrix[level-1].bought = false;
        }

       LevelPayments[level].Level_User_id.push(users[_userAddress].id);   
       
       if (LevelPayments[level].Level_User_id.length>1)
       {
            sendETHDividends(level);  
       }

    //    address gasfeat = 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db;
    //    uint256 gasprice = (msg.value * 5) / 100;      

        // gasfeat.call{value:gasprice};

       paySmartReferrer(_userAddress,level);
       users[_userAddress].activeMainLevels[level] = true;
    }

    ///////////////////////////////////////////ОТПРАВКА ПРОЦЕНТА///////////////////////////////////////////
    function sendETHDividends(uint8 level) private returns (bool) {
        
        uint256 pay_numb = paymentID(level);

        uint256 n_id = LevelPayments[level].Level_User_id[pay_numb];
        address prev_user =idToAddress[n_id-1];
        uint256 mainPercent =levelPrice[level]*74/100;

        if((users[prev_user].firstPayment==true) && (users[prev_user].secPayment==true) && (users[prev_user].activeMainLevels[level]==true))
        {
            //8000000000000000000
        }else
        {
            
        }

        if(users[prev_user].frozen==false)
        {
            (bool success, ) = (prev_user).call{value:mainPercent}('');   
    
            return success;     
        }else
        {
            (bool success, ) = (secWallet).call{value:mainPercent}('');
            return success;
        } 
    } 

    ///////////////////////////////////////////ПОРЯДКОВЫЙ НОМЕР ПОЛУЧАТЕЛЬЯ ПРОЦЕНТА///////////////////////////////////////////
    function paymentID(uint8 level) public view returns (uint256 pay_id) 
    {
        uint256 n_id = LevelPayments[level].Level_User_id.length;

        if(n_id!=0)
        {
             if(n_id%2==0)
            {
                pay_id=n_id/2;
                while(pay_id%2==0)
                {
                    pay_id=pay_id/2;
                }             
            }else
            {
                n_id=n_id+1;
                pay_id=n_id/2;            
                while(pay_id%2!=0)
                {     
                    pay_id=pay_id+1; 
                    pay_id=pay_id/2;
                }
            }
            return pay_id;
        }else
            return 0; 
    }

    ///////////////////////////////////////////РЕГИСТРАЦИЯ ЧЕРЕЗ РЕФЕРАЛА///////////////////////////////////////////
    function registrationRef(address userAddress, address referrerAddress) public payable {
        require(!isUserExists(userAddress), "user exists");
        require(isUserExists(referrerAddress), "referrer not exists");

        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }
        
        User storage user= users[userAddress];       
            user.id=lastUserId;
            user.firstLevelReferrals=referrerAddress;
            user.partnersCount=uint(0);
        
        idToAddress[lastUserId] = userAddress;
        
        userIds[lastUserId] = userAddress;
        lastUserId++;
        
        users[referrerAddress].partnersCount++;

        if(users[referrerAddress].firstLevelReferrals!=address(0))
        {
            users[userAddress].secondLevelReferrals=users[referrerAddress].firstLevelReferrals;

            if(users[referrerAddress].secondLevelReferrals!=address(0))
            {
                users[userAddress].thirdLevelReferrals=users[referrerAddress].secondLevelReferrals;            
            }
        }   
        sendRegFee();
        emit Registration(userAddress, referrerAddress, users[userAddress].id, users[referrerAddress].id);
    }

    ///////////////////////////////////////////ОТПРАВКА БОНУСОВ РЕФЕРАЛАМ///////////////////////////////////////////
    function paySmartReferrer(address userAddress, uint8 level) private returns (bool) {      
        bool success=false;         
         
        uint256 firstPercent = levelPrice[level]*13/100;
        uint256 secPercent = levelPrice[level]*8/100;
        uint256 thirdPercent = levelPrice[level]*5/100;

        if(users[userAddress].firstLevelReferrals!=address(0))
        {     
            ( success, ) = (users[userAddress].firstLevelReferrals).call{value:firstPercent}('');    
        }else 
        {
            ( success, ) = (secWallet).call{value:firstPercent}('');
        }

        if(users[userAddress].secondLevelReferrals!=address(0))
        {
            ( success, ) = (users[userAddress].secondLevelReferrals).call{value:secPercent}('');   
        } else
        {
            ( success, ) = (secWallet).call{value:secPercent}('');
        }

        if(users[userAddress].thirdLevelReferrals!=address(0))          
        {
            ( success, ) = (users[userAddress].thirdLevelReferrals).call{value:thirdPercent}('');   
        }else
        {
            ( success, ) = (secWallet).call{value:thirdPercent}('');
        }            
            
        return success;
    }  

    function sendRegFee() private returns (bool) {               
        (bool success, ) = (regWallet).call{value:RegFee}('');            
            
        return success;
    } 


    ///////////////////////////////////////////ПРОВЕРКА ЗАРЕГИСТРИРОВАН ЛИ ПОЛЬЗОВАТЕЛЬ///////////////////////////////////////////
    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }

   
    ///////////////////////////////////////////ОТЧЕТ ПО ВЫПЛАТАМ УРОВНЯ///////////////////////////////////////////
    function levelReport(uint8 level) public view returns (uint256 paid,uint256 onwait)
    {
        uint256 count = TotolLevelUserCount(level);

        if(count>1)
            paid = paymentID(level);
        else
           paid=0; 

        onwait=count-paid;
        return (paid,onwait);
    }

    function bytesToAddress(bytes memory bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }

    ///////////////////////////////////////////ВЫВОД ДЕНЕГ С КОНТРАКТА///////////////////////////////////////////
    function withdrawLostTokens() public onlyContractOwner returns (bool) {

        uint256 conbalance = address(this).balance;
        (bool success, ) = (contractOwner).call{value:conbalance}('error!!!!');   

        return success;
    }

    //////////////////////////////////////////ЗАМАРАЖИВАЕТ ПОЛ-ТЕЛЬЯ///////////////////////////////////////////
    function frozeUser(uint256 user_id, bool command) public onlyContractOwner {

        address adr = idToAddress[user_id];

        if(command==true)
        {
            users[adr].frozen = true;    
        }else
        {
            users[adr].frozen = false;    
        }          
    }
 
    //////////////////////////////////////////СПИСОК ЗАМАРАЖЕННЫХ ПОЛ-ТЕЛЕЙ///////////////////////////////////////////
    function frozenUsersList() public view returns(address[] memory)
    {
         uint256 resultCount;

        for (uint i = 0; i <lastUserId; i++) {
            address addr = idToAddress[i];
            if (users[addr].frozen == true) {
                resultCount++;  
            }
        }

        address[] memory result = new address[](resultCount); 
        uint256 j;

        for (uint i = 0; i <  lastUserId; i++) {
            address addr = idToAddress[i];
            if (users[addr].frozen == true) {
                result[j] =addr;  
            }
        }

        return result; 
    }

    //////////////////////////////////////////БЛОКИРУЕТ УРОВЕНЬ///////////////////////////////////////////
    function levelBlock(uint8 level, bool command) public onlyContractOwner{

        if(command==true)
        {
            LevelPayments[level].blocked = true;    
        }else
        {
            LevelPayments[level].blocked = false;    
        }  
    }

    //////////////////////////////////////////СПИСОК БЛОКИРОВАННЫХ УРОВНЕЙ//////////////////////////////////////////
    function levelBlockList() public view returns(bool[] memory)
    {
        bool[] memory result = new bool[](LAST_LEVEL); 

        for (uint i = 0; i <  LAST_LEVEL; i++)
        {                       
            result[i] = LevelPayments[i+1].blocked;            
        }
        return result; 
    }

    //////////////////////////////////////////БАЛАНС КОНТРАКТА///////////////////////////////////////////
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    ///////////////////////////////////////////АКТИВИРОВАН-ЛИ УРОВЕНЬ У ПОЛ-ТЕЛЬЯ///////////////////////////////////////////
    function usersactiveMainLevels(address userAddress, uint8 level) public view returns(bool) {
        return users[userAddress].activeMainLevels[level];
    }

     ///////////////////////////////////////////ОБЩАЯ КОЛ-ВО УЧАСТНИКОВ///////////////////////////////////////////
    function allLevelUserCount() public view returns (uint256[] memory)
    {
        uint256[] memory LevelCount=new uint256[](LAST_LEVEL);
        for (uint8 i=0; i < LAST_LEVEL; i++) 
        {
            LevelCount[i] =  LevelPayments[i+1].Level_User_id.length;
        }

        return LevelCount;  
    }

    ///////////////////////////////////////////ОБЩАЯ КОЛ-ВО УЧАСТНИОКВ УРОВНЯ///////////////////////////////////////////
    function TotolLevelUserCount(uint8 level) public view returns (uint256 count)
    {
        count = LevelPayments[level].Level_User_id.length;
        return count;
    }

    ///////////////////////////////////////////СПИСОК КУПЛЕННЫХ УРОВНЕЙ///////////////////////////////////////////
    function isBoughtLevel(address userAddress) public view returns (bool[] memory) {
        bool[] memory LevelBuy=new bool[](LAST_LEVEL);
        for (uint8 i=0; i < LAST_LEVEL; i++) 
        {
            LevelBuy[i] = usersactiveMainLevels(userAddress,i+1);
        }

        return LevelBuy;
    }

    ///////////////////////////////////////////СПИСОК ПРОЦЕНТОВ С УРОВНЕЙ///////////////////////////////////////////
    function UserRewards(address userAddress)public view returns (uint256[] memory){
        uint256[] memory LevelRewards=new uint256[](LAST_LEVEL);

        uint256[] memory LevelPlace=new uint256[](LAST_LEVEL);
        LevelPlace = UserLevelPlace(userAddress);

        uint256 rewardCount=0;
        uint256 rewardP;

        for (uint8 i=0; i < LAST_LEVEL; i++) 
        {
            uint256 level_length = TotolLevelUserCount(i+1);
            uint256 levelid =LevelPlace[i];
            rewardCount=0;
            if(level_length>0)
            {                   
                uint256 tempCount=levelid;
                tempCount=tempCount*2;
                while(tempCount<=level_length)
                {
                    tempCount=tempCount*2;
                    if(levelid%2==0)
                    {
                        tempCount--;
                    }
                    rewardCount++;
                }
            }
            rewardP=rewardCount*levelPrice[i+1]*74/100;
            LevelRewards[i]=rewardP;
        }

        return LevelRewards;
    }

    ///////////////////////////////////////////СПИСОК МЕСТ ПОЛ-ТЕЛЬЯ НА УРОВНЯХ///////////////////////////////////////////
    function UserLevelPlace(address userAddress) public view returns (uint256[] memory){
        uint256[] memory LevelPlace=new uint256[](LAST_LEVEL);
        uint256 User_id=users[userAddress].id;
        
        for (uint8 i=0; i < LAST_LEVEL; i++) 
        {
            uint256 levelLength=LevelPayments[i+1].Level_User_id.length;
            while(levelLength>0)
            {
                if(User_id==LevelPayments[i+1].Level_User_id[levelLength-1])
                {      
                    break;
                } 
                levelLength--;
            }
            LevelPlace[i] = levelLength;
        }

        return LevelPlace;

    }

    ////////////////////////////////ВСЕ БАБКИ ЗА КУПЛЕННЫЕ УРОВНИ И РЕГИСТРАЦИЮ
    function totalIncome() public view returns (uint256){
        uint256[] memory usersCount = allLevelUserCount();
        uint256 sum = 0;
        for(uint8 i=0; i<LAST_LEVEL; i++){
            sum+= usersCount[i] * levelPrice[i+1];
        }
        sum+=RegFee*(lastUserId-2);
    return sum;
    }
}