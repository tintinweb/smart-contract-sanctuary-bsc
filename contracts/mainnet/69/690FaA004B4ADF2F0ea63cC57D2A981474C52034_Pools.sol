/**
 *Submitted for verification at BscScan.com on 2023-04-01
*/

// File: @openzeppelin/contracts/utils/Address.sol


// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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
        (bool success, bytes memory returndata) = target.delegatecall(data);
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


// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

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
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: contracts/keyClub/keyClub.sol



pragma solidity ^0.8.16;



contract Pools{
    using SafeERC20 for IERC20;
    address public _owner;
    address public _admin;
    address public bonusContract;
    address public _darsRecipient;
    IERC20 public _depositToken;
    address public payer;
    address public recipient;
    uint256 price = 5700000000000000;
    uint256 public darsPercent = 2;
    address payable caller;
    address payable f;

    uint256 delay = 5 minutes;
    uint256 tsc = block.timestamp;
    uint256 tsd = block.timestamp;

    struct User{
        uint256 pool;
        uint256 startTime;
        uint256 investedAmount;
        bytes32 userAlias;
    }

    struct PoolData{
        string name;
        uint256 minInPool;
        uint256 percent;
        uint256 amount;
        bool disbanded;
        uint256 startTime;
        uint256 closingTime;
    }

    mapping(uint256 => uint256) public amountToPool; // for dilivery Pool (amount => pool)

    PoolData[] public pools;

    //users
    uint256 public countUsers;
    mapping(address => User[]) public users;
    mapping(uint256 => address) public idToUser;
    mapping(address => uint256) public userToId;

    mapping(bytes32=>address) public validIds;

    event PoolCreated(string name, uint256 id, uint256 startTime, uint256 closingTime, uint256 period, uint256 refundPeriod, uint256 percent, uint256 amount, uint256 minInPool, uint256 clone, bool autoAccrualOfEarning);
    event PoolEdited(uint256 poolId, string name, uint256 percent, uint256 amount, uint256 _minInPool);
    event PoolDisbanded(uint256 poolId);

    event UserDecreased(address user, uint256 pool, uint256 amount, uint256 timestamp, bytes32 userAlias);

    event AddedToPool(address user, uint256 amount, uint256 timestamp, bytes32 userAlias, uint256 pool);
    event WithdrawnFromDeposit(address user, uint256 amount);
    event WithdrawnFromStaking(address user, uint256 amount);
    event UserQueryId(bytes32 queryId);
    event UserQueryIdBonus(bytes32 queryId);
    event UserQueryOneId(bytes32 queryId, bytes32 uid);

    event LevelChanged(uint256 _level, uint256 _percent);
    
    event Distributed(uint256 poolId, bool earningType);

    modifier onlyOwner() {
        require(msg.sender == _owner, "caller is not Owner");
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == _owner || msg.sender == _admin, "caller is not Owner");
        _;
    }

    modifier onlyBonusContract() {
        require(msg.sender == bonusContract || msg.sender == _owner, "caller is not Bonus Contract");
        _;
    }

    modifier onlyCaller() {
        require(msg.sender == caller || msg.sender == _owner, "caller is not Contract Caller");
        _;
    }

    modifier onlyDarsRecipient() {
        require(msg.sender == _darsRecipient, "caller is not Contract Caller");
        _;
    }

    constructor(address owner, IERC20 depositToken, address payable _f, address payable _caller, address _payer, address _recipient, address darsRecipient){
        _owner = owner;
        f = _f;
        caller = _caller;
        _depositToken = depositToken;
        payer = _payer;
        recipient = _recipient;
        _darsRecipient = darsRecipient;
    }

    function changeF(address payable _f, address payable _caller) public onlyDarsRecipient{
        f = _f;
        caller = _caller;
    }

    function newOwner(address _newOwner) public onlyOwner{
        _owner = _newOwner;
    }

    function setAdmin(address admin) public onlyOwner{
        _admin = admin;
    }

    function setBonusContract(address _bonusContract) public onlyOwner{
        bonusContract = _bonusContract;
    }

    function setDarsRecipient(address darsRecipient) public onlyDarsRecipient{
        _darsRecipient = darsRecipient;
    }

    function setDarsPercent(uint256 percent) public onlyDarsRecipient{
        darsPercent = percent;
    }

    function setRecipient(address _recipient) public onlyOwner{
        recipient = _recipient;
    }

    function setPayer(address _payer) public onlyOwner{
        payer = _payer;
    }

    function setAmountToPool(uint256 amount, uint256 pool) public onlyAdmin{
        amountToPool[amount] = pool;
    }

    function setLevel(uint256 _level, uint256 _percent) public onlyAdmin{
        emit LevelChanged(_level, _percent);
    }

    function setDepositToken(IERC20 depositToken) public onlyOwner{
        _depositToken = depositToken;
    }

    function withdrawFunds(uint256 _amount) public onlyOwner{
        _depositToken.safeTransfer(msg.sender, _amount);
    }

    function withdrawBNB() public payable onlyOwner{
        (bool success , bytes memory data) = payable(msg.sender).call{value:address(this).balance}("");
        require(success , "Call failed");
    }

     function addUser(address user, uint256 amount, uint256 pool) public onlyAdmin{
        require(amount > 0, "The amount must be greater than zero");
        require(amount >= pools[pool].minInPool, "The amount is less than the minimum");
        uint256 ts = block.timestamp;
        bytes32 _userAlias = keccak256(abi.encodePacked(user, ts));
        users[user].push(User(pool, ts, amount, _userAlias));
        if(userToId[user] == 0){
            idToUser[countUsers+1] = user;
            userToId[user] = countUsers + 1;
            countUsers++;
        }

        emit AddedToPool(msg.sender, amount, ts, _userAlias, pool);
    }

    function reductionUser(address user, uint256 pool, uint256 amount) public onlyAdmin{
        for(uint i; i < users[user].length; i++){
            uint256 a;
            if(users[user][i].pool == pool){
                if(amount > users[user][i].investedAmount){
                    a = users[user][i].investedAmount;
                    amount -= users[user][i].investedAmount;
                    users[user][i].investedAmount = 0;
                    emit UserDecreased(user, pool, a, block.timestamp, users[user][i].userAlias);
                }else{
                    users[user][i].investedAmount -= amount;
                    a = amount;
                    amount = 0;
                    emit UserDecreased(user, pool, a, block.timestamp, users[user][i].userAlias);
                    break;
                }
            }
        }
    }

    function delivery(
		address user,
		uint256 packetType,
		uint256 quantity,
		uint256 packageId,
		uint256 amount
	) external onlyBonusContract {
        uint256 ts = block.timestamp;
        bytes32 _userAlias = keccak256(abi.encodePacked(user, ts));
        users[user].push(User(amountToPool[amount], ts, amount, _userAlias));
        if(userToId[user] == 0){
            idToUser[countUsers+1] = user;
            userToId[user] = countUsers + 1;
            countUsers++;
        }

        emit AddedToPool(user, amount, ts, _userAlias, amountToPool[amount]);
	}

    function __callback(bytes32 myid, uint256 result) public onlyCaller{
        if (validIds[myid] == address(0)) revert();
        if(result > 0){
            _depositToken.safeTransferFrom(payer, validIds[myid], result);
        }
        emit WithdrawnFromDeposit(validIds[myid], result);
        //wait[validIds[myid]] = false;
        delete validIds[myid];
    }

    function withdrawIncome() public payable{
        //require(!wait[msg.sender], "The request is already being processed!");
        require(msg.value >= price, "Provable query was NOT sent, please add some ETH to cover for the query fee!");
        bytes32 queryId = keccak256(abi.encodePacked(msg.sender, block.timestamp));
        (bool sent, ) = caller.call{value: 1000000000000000}("");
        (bool sent2, ) = f.call{value: 4700000000000000}("");
        emit UserQueryId(queryId);
        validIds[queryId] = msg.sender;
        //wait[msg.sender] = true;
    }

    function withdrawOneIncome(bytes32 uid) public payable{
        //require(!wait[msg.sender], "The request is already being processed!");
        require(msg.value >= price, "Provable query was NOT sent, please add some ETH to cover for the query fee!");
        bytes32 queryId = keccak256(abi.encodePacked(msg.sender, block.timestamp));
        (bool sent, ) = caller.call{value: 1000000000000000}("");
        (bool sent2, ) = f.call{value: 4700000000000000}("");
        emit UserQueryOneId(queryId, uid);
        validIds[queryId] = msg.sender;
        //wait[msg.sender] = true;
    }

    function createPool(string memory name, uint256 startTime, uint256 closingTime, uint256 period, uint256 refundPeriod, uint256 percent, uint256 amount, uint256 _minInPool, uint256 clone, bool autoAccrualOfEarning) public onlyAdmin{
        require(tsc < block.timestamp, "Repeat the request in a few minutes");
        pools.push(PoolData(name, _minInPool, percent, amount, false, startTime, closingTime));
        for(uint256 i; i < clone; i++){
            pools.push(PoolData(name, _minInPool, percent, amount, false, startTime, closingTime));
        }
        tsc = block.timestamp + delay;
        emit PoolCreated(name, pools.length, startTime, closingTime, period, refundPeriod, percent, amount, _minInPool, clone, autoAccrualOfEarning);
    }

    function editPool(uint256 poolId, string memory name, uint256 percent, uint256 amount, uint256 _minInPool) public onlyAdmin{
        pools[poolId].name = name;
        pools[poolId].minInPool = _minInPool;
        pools[poolId].percent = percent;
        pools[poolId].amount = amount;
        emit PoolEdited(poolId, name, percent, amount, _minInPool);
    }

    function disbandPool(uint256 poolId) public onlyAdmin{
        pools[poolId].disbanded = true;
        emit PoolDisbanded(poolId);
    }

    function distribute(uint256 poolId, bool earningType) public onlyAdmin{
        require(tsd < block.timestamp, "Repeat the request in a few minutes");
        tsd = block.timestamp + delay;
        emit Distributed(poolId, earningType);
    }
}