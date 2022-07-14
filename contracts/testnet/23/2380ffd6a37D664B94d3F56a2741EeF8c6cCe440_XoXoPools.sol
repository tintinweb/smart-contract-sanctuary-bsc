/**
 *Submitted for verification at BscScan.com on 2022-07-13
*/

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


// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

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

// File: XoXoPools.sol

//SPDX-License-Identifier: MIT
/**
* ===============================
* XoXo BUSD
* FROM PEOPLE BY THE PEOPLE
* Website  : https://xoxobusd.com
* ===============================
**/

pragma solidity ^0.8.4;



interface XoXoInterface {
    function getUserPoolData(address _user, uint16 _pool) external view returns (
        uint lastAction,
        uint slotLimit,
        uint earnAmount,
        uint loseAmount,
        uint earnByRef,
        uint[] memory slots
    );
    function getUserData(address _user) external view returns (
        uint id,
        address wallet,
        uint refCount,
        address invitedBy,
        address[] memory referrals
    );
    function addressToId(address _user) external view returns (uint id);
}

contract XoXoPools is Ownable {

    using SafeERC20 for IERC20;

    address public constant XoXo = 0x24F929f29EaC6Eab028254CD7B31D01249f723c7;
    XoXoInterface XoXoContract = XoXoInterface(XoXo);

    struct Pools {
        uint slotActive;
        uint slotCount;
        uint cycleCount;
        uint earnOverall;
        uint joinCost;
        uint rebuyBalance;        
        uint[] supportAmounts;
        bool[] supportTransfer;
        address[] supportTarget;
        mapping(address => bool) whitelisted;
        mapping(address => bool) inPool;
        mapping(address => uint) lastAction;
        mapping(address => uint) slotLimit;
        mapping(address => uint) earnAmount;
        mapping(address => uint) loseAmount;
        mapping(address => uint) earnByRef;
        mapping(address => uint[]) slots;
        mapping(uint => Slots) Slot;
        IERC20 payToken;
    }

    struct Settings {
        uint rebuyPercent;
        uint payRefAmount;
        uint paySlotAmount;
        uint needPrevSlots;
        uint cycleAt;
        bool status;
        bool prelaunch;
        bool payRef;
        bool countLoseAmount;
    }
    
    struct Slots {
        address user;
        uint    eventsCount;
        bool    rebuy;
        bool    reentry;
    }

    mapping(uint => Pools) public Pool;
    mapping(uint => Settings) public PoolSettings;
    uint public poolCount;

    event addSlotEvent(uint indexed userid, address indexed wallet, uint indexed pool, uint slot, bool rebuy, bool reentry);    
    event payAutopoolEvent(address indexed from, address indexed to, uint amount, uint indexed pool, bool refPayment, uint userid, uint slotid);

    address private ownerAddress;
    uint public _timeLimit = 86400;

    constructor(address _paymentToken, address _initAddress) {
        ownerAddress = _initAddress; 

        poolCount = 1;

        Pools storage p = Pool[1];
        Settings storage ps = PoolSettings[1];

        ps.rebuyPercent = 80;
        ps.payRefAmount = 25 * 10**18;
        ps.paySlotAmount = 50 * 10**18;
        ps.needPrevSlots = 0;
        ps.cycleAt = 3;

        ps.status = true;
        ps.prelaunch = true;
        ps.payRef = true;
        ps.countLoseAmount = true;

        p.joinCost = 125 * 10**18; //125000000000000000000       

        p.supportAmounts = [50 * 10**18]; //25000000000000000000
        p.supportTransfer = [true];
        p.supportTarget = [XoXo]; // 0x0000000000000000000000000000000000000000
                                  // 0x7EF2e0048f5bAeDe046f6BF797943daF4ED8CB47
        p.slotActive = 1;
        p.slotCount = 1;
        p.earnOverall = 0;
        p.rebuyBalance = 0;        

        p.inPool[ownerAddress] = true;
        p.lastAction[ownerAddress] = block.timestamp;
        p.slotLimit[ownerAddress] = 1;
        p.earnAmount[ownerAddress] = 0;
        p.loseAmount[ownerAddress] = 0;
        p.earnByRef[ownerAddress] = 0;

        p.payToken = IERC20(_paymentToken);

        p.Slot[1] = Slots({
            user: ownerAddress,
            eventsCount: 0,
            rebuy: false,
            reentry: false
        });
        p.slots[ownerAddress].push(1);
        emit addSlotEvent(1, ownerAddress, 1, 1, false, false);

    }

    function f(address a) internal pure returns (uint256) {
        return uint256(uint160(a));
    }

    function buyGlobalSlot(uint _pool) public {

        uint poolID = _pool;
        Settings storage ps = PoolSettings[_pool];
        require(poolID > 0, "Require Globalpool ID");
        address _buyer = msg.sender;
        bool eligible = isEligible(_buyer);
        require(eligible == true, "Not registered in XoXo");
        if (poolID > 1) {
            Pools storage pp = Pool[(poolID-1)];
            require(pp.inPool[_buyer] == true, "Not registered in previous pool");
        }

        Pools storage p = Pool[poolID];
        require(ps.status == true, "Pool disabled");
        if(ps.prelaunch == true) {
            uint _refCount = 0;
            if(poolID == 1) {
                (,,_refCount,,) = XoXoContract.getUserData(_buyer);
                require((p.whitelisted[_buyer] == true || _refCount >= 10), 'Not whitelisted or havent 10 refs');
            } else {
                (,,_refCount,,) = XoXoContract.getUserData(_buyer);
                require((p.whitelisted[_buyer] == true || _refCount >= 10), 'Not whitelisted or havent 10 refs');

                (,,,,,uint[] memory _prevSlots) = getUserPoolData(_buyer, (poolID-1));
                require((p.whitelisted[_buyer] == true || _prevSlots.length >= ps.needPrevSlots), 'Not whitelisted or havent slots in prev pool');
            }
        }

        if (p.inPool[_buyer] == false) p.inPool[_buyer] = true;

        if(p.slotLimit[_buyer] >= 10) {
            uint _resetTime = block.timestamp - p.lastAction[_buyer];
            if(_resetTime >= _timeLimit) p.slotLimit[_buyer] = 0;
        }
        p.lastAction[_buyer] = block.timestamp;
        require ((p.slotLimit[_buyer] <= 10), "Slot limit exceed. Wait for timeout reset.");

        p.slotLimit[_buyer]++;
        address _userActive = p.Slot[p.slotActive].user;

        uint joinCost = p.joinCost;

        require ((p.payToken.balanceOf(_buyer) >= joinCost), "Insufficient balance to buySlot");
        uint256 allowance = p.payToken.allowance(_buyer, address(this));
        require(allowance >= joinCost, "Not enough allowance");
        p.payToken.safeTransferFrom(_buyer, address(this), joinCost);

        uint distributeAmount = p.joinCost;
        for (uint i=0; i < p.supportAmounts.length; i++) {
            distributeAmount = distributeAmount - p.supportAmounts[i];
            if(p.supportTransfer[i] == false) {
                uint targetPoolID = f(p.supportTarget[i]);
                Pools storage poolTarget = Pool[targetPoolID];
                poolTarget.rebuyBalance += p.supportAmounts[i];
            } else {
                p.payToken.safeTransfer(p.supportTarget[i],  p.supportAmounts[i]);
            }
        }

        // Pay Valid Referral Bonus
        if (ps.payRef == true) payRefBonus(poolID, _buyer);
        // Pay To Global Active Slot
        bool reenter = payGlobalBonus(poolID, _buyer);
        // Create new Slot
        addSlot(poolID, _buyer, false, false);        

        // Pay Global Pool
        if (reenter) {            
            // rebuy under reentrance
            if (p.payToken.balanceOf(address(this)) >= joinCost) {
                rebuyGlobalSlot(poolID);
            }

            /// Reentrance of closed slot
            addSlot(poolID, _userActive, false, true);
            p.cycleCount++;
        }

        // rebuy at the end
        if (p.payToken.balanceOf(address(this)) >= joinCost) {
            rebuyGlobalSlot(poolID);
        }
    } 

    function rebuyGlobalSlot(uint _pool) private {        
        uint poolID = _pool;
        address _buyer = owner();
        Pools storage p = Pool[poolID];
        Settings storage ps = PoolSettings[poolID];
        p.lastAction[_buyer] = block.timestamp;
    
        address _userActive = p.Slot[p.slotActive].user;
        uint joinCost = p.joinCost;
        uint distributeAmount = p.joinCost;
        for (uint i=0; i < p.supportAmounts.length; i++) {
            distributeAmount = distributeAmount - p.supportAmounts[i];
            if(p.supportTransfer[i] == false) {
                uint targetPoolID = f(p.supportTarget[i]);
                Pools storage poolTarget = Pool[targetPoolID];
                poolTarget.rebuyBalance += p.supportAmounts[i];
            } else {
                p.payToken.safeTransfer(p.supportTarget[i],  p.supportAmounts[i]);
            }
        }
        p.earnOverall += distributeAmount;
        p.rebuyBalance -= joinCost;

        // Pay Valid Referral Bonus
        if (ps.payRef == true) payRefBonus(poolID, _buyer);
        // Pay To Global Active Slot
        bool reenter = payGlobalBonus(poolID, _buyer);
        // Create new Slot
        addSlot(poolID, _buyer, true, false);

        // Pay Global Pool
        if (reenter) {
            /// Reentrance of closed slot
            addSlot(poolID, _userActive, false, true);
            // Set cursor to next active slot
            p.cycleCount++;
        }        
    }

    function addSlot(uint _pool, address _user, bool _rebuy, bool _reentry) private {
        Pools storage p = Pool[_pool];
        // Increment slot count
        p.slotCount++;
        // Add slot to user and pool
        p.slots[_user].push(p.slotCount);
        p.Slot[p.slotCount] = Slots({
            user: _user,
            eventsCount: 0,
            rebuy: _rebuy,
            reentry: _reentry
        });
        emit addSlotEvent(XoXoContract.addressToId(_user), _user, _pool, p.slotCount, _rebuy, _reentry);
    }

    function findValidPayee(uint _pool, address _user) private returns(address _payee) {        
        Pools storage p = Pool[_pool];
        Settings storage ps = PoolSettings[_pool];
        (,,,address invitedBy,) = XoXoContract.getUserData(_user);

        address _valid = address(0x0);
        uint _transferamount = getDistributeAmount(_pool, true);
        address _checking = invitedBy;
        while(_valid == address(0x0)) {            
            if (p.inPool[_checking] == true) {
                _valid = _checking;
            } else {
                (,,,address _invitedBy,) = XoXoContract.getUserData(_checking);
                if (ps.countLoseAmount == true) p.loseAmount[_checking] += _transferamount;
                _checking = _invitedBy;
            }
        }
        return(_valid);
    }

    function payRefBonus(uint _pool, address _user) private {
        // Find Valid Referral
        Pools storage p = Pool[_pool];
        Settings storage ps = PoolSettings[_pool];
        address _to = findValidPayee(_pool, _user);
        uint _transferamount = getDistributeAmount(_pool, true);

        if (_to == owner()) {
            uint leavePercent = 100 - ps.rebuyPercent;
            p.rebuyBalance += _transferamount * ps.rebuyPercent / 100;
            _transferamount = _transferamount * leavePercent / 100;
        }        
        p.earnAmount[_to] += _transferamount;
        p.earnByRef[_to] += _transferamount;
        p.payToken.safeTransfer(_to, _transferamount);
        emit payAutopoolEvent(_user, _to, _transferamount, _pool, true, XoXoContract.addressToId(_user), p.slotCount);
    }

    function payGlobalBonus(uint _pool, address _user) private returns(bool reentrance) { 
        Pools storage p = Pool[_pool];
        Settings storage ps = PoolSettings[_pool];
        bool _reenter = false;

        p.Slot[p.slotActive].eventsCount++;
        if (p.Slot[p.slotActive].eventsCount == ps.cycleAt) { 
            p.slotActive++;
            p.Slot[p.slotActive].eventsCount++;
            _reenter = true;
        }

        address _to = p.Slot[p.slotActive].user;
        /*
        uint distributeAmount = p.joinCost;
        for (uint i=0; i < p.supportAmounts.length; i++) {
            distributeAmount = distributeAmount - p.supportAmounts[i];
        }
        */
        uint _transferamount = getDistributeAmount(_pool, false);

        if (_to == owner()) {
            uint leavePercent = 100 - ps.rebuyPercent;
            p.rebuyBalance += _transferamount * ps.rebuyPercent / 100;
            _transferamount = _transferamount * leavePercent / 100;
        }

        p.earnAmount[_to] += _transferamount;
        p.payToken.safeTransfer(_to, _transferamount);
        emit payAutopoolEvent(_user, _to, _transferamount, _pool, false, XoXoContract.addressToId(_user), p.slotCount);

        return _reenter;
        
    }

    function getUserPoolSlots(address _user, uint _pool) public view returns (Slots[] memory) {
        Pools storage p = Pool[_pool];
        uint[] memory slots = p.slots[_user];
        Slots[] memory id = new Slots[](slots.length);
        for (uint i = 0; i < slots.length; i++) {
            Slots storage slot = p.Slot[slots[i]];
            id[i] = slot;
        }
        return id;
    }

    function getUserPoolData(address _user, uint _pool) public view returns (
        uint lastAction,
        uint slotLimit,
        uint earnAmount,
        uint loseAmount,
        uint earnByRef,
        uint[] memory slots
    ) {
        Pools storage p = Pool[_pool];
        return ( 
            p.lastAction[_user],
            p.slotLimit[_user],
            p.earnAmount[_user],
            p.loseAmount[_user],
            p.earnByRef[_user],
            p.slots[_user]
        );
    }

    function getDistributeAmount(uint _pool, bool _isPayRef) private view returns(uint) {
        Settings storage ps = PoolSettings[_pool];
        if (_isPayRef == true) {
            if (ps.payRef == true) return ps.payRefAmount;
            else return ps.paySlotAmount;
        } else {
            return ps.paySlotAmount;
        }
    }

    function createPool(address _token, uint _poolEntrance, uint _rebuyPercent, uint[] memory _supportAmounts, bool[] memory _supportTransfer, address[] memory _supportTarget) public onlyOwner {
        require(_rebuyPercent < 100, 'Percent must be lower than 100');
        uint _supportAmountsCount = _supportAmounts.length;
        uint _supportTransferCount = _supportTransfer.length;
        uint _supportTargetCount = _supportTarget.length;
        require((_supportAmountsCount == _supportTransferCount) && (_supportTargetCount == _supportTransferCount) , 'Bad condition');
        
        poolCount++;        
        Pools storage p = Pool[poolCount];
        Settings storage ps = PoolSettings[poolCount];

        p.joinCost = _poolEntrance;
        p.supportAmounts = _supportAmounts;
        p.supportTransfer = _supportTransfer;
        p.supportTarget = _supportTarget;

        p.slotActive = 1;
        p.slotCount = 1;
        p.earnOverall = 0;
        p.rebuyBalance = 0;

        ps.status = true;
        ps.prelaunch = true;
        ps.payRef = true;
        ps.countLoseAmount = true;
        ps.cycleAt = 3;
        ps.rebuyPercent = _rebuyPercent;
        ps.payRefAmount = 25 * 10**18;
        ps.paySlotAmount = 50 * 10**18;
        ps.needPrevSlots = 0;

        p.inPool[ownerAddress] = true;
        p.lastAction[ownerAddress] = block.timestamp;
        p.slotLimit[ownerAddress] = 1;
        p.earnAmount[ownerAddress] = 0;
        p.loseAmount[ownerAddress] = 0;
        p.earnByRef[ownerAddress] = 0;

        p.payToken = IERC20(_token);

        p.Slot[1] = Slots({
            user: ownerAddress,
            eventsCount: 0,
            rebuy: false,
            reentry: false
        });
        p.slots[ownerAddress].push(1);
        emit addSlotEvent(1, ownerAddress, poolCount, 1, false, false);

    }
    function setPool(uint[4] memory _poolData, uint[] memory _supportAmounts, bool[] memory _supportTransfer, address[] memory _supportTarget) public onlyOwner {
        uint _pool = _poolData[0];
        uint _poolEntrance = _poolData[1];
        uint _rebuyPercent = _poolData[2];
        uint _rebuyBalance = _poolData[3];

        require(_rebuyPercent < 100, 'Percent must be lower than 100');        
        uint _supportAmountsCount = _supportAmounts.length;
        uint _supportTransferCount = _supportTransfer.length;
        uint _supportTargetCount = _supportTarget.length;
        require((_supportAmountsCount == _supportTransferCount) && (_supportTargetCount == _supportTransferCount) , 'Bad condition');

        Pools storage p = Pool[_pool];
        Settings storage ps = PoolSettings[_pool];
        p.joinCost = _poolEntrance;
        ps.rebuyPercent = _rebuyPercent;
        p.supportAmounts = _supportAmounts;
        p.supportTransfer = _supportTransfer;
        p.supportTarget = _supportTarget;
        p.rebuyBalance = _rebuyBalance;
    }
    function setPoolParams(uint _pool, bool _status, bool _prelaunch, bool _countLoseAmount, uint _needSlots, bool _payRef, uint _payRefAmount, uint _paySlotAmount)  public onlyOwner  {
        Settings storage ps = PoolSettings[_pool];
        ps.status = _status;
        ps.prelaunch = _prelaunch;
        ps.needPrevSlots = _needSlots;
        ps.countLoseAmount = _countLoseAmount;
        ps.payRefAmount = _payRefAmount;
        ps.paySlotAmount = _paySlotAmount;
        ps.payRef = _payRef;
    }
    function modifyWhitelist(address[] memory _list, uint _pool) public onlyOwner returns(uint count) {
        Pools storage p = Pool[_pool];
        uint _count = 0;
        for (uint256 i = 0; i < _list.length; i++) {
            if(p.whitelisted[_list[i]] != true){
                p.whitelisted[_list[i]] = true;
                _count++;
            }
        }
        return _count;
    }
    function preparePush(uint _pool, uint _amount) public onlyOwner {
        Pools storage p = Pool[_pool];
        p.rebuyBalance += _amount;
    }
    function manualPush(uint _pool) public onlyOwner {
        Pools storage p = Pool[_pool];
        require (p.payToken.balanceOf(address(this)) >= p.joinCost, 'Not enough token.balance to make a push');
        require (p.rebuyBalance >= p.joinCost, 'Not enough rebuy.balance to make a push');
        rebuyGlobalSlot(_pool);
    }    
    function recoveryToken(address _token) public onlyOwner {
        IERC20 token = IERC20(_token);
        uint tokenBalance = token.balanceOf(address(this));
        token.safeTransfer(msg.sender, tokenBalance);
    }
    function recoveryTokenPool(uint _pool) public onlyOwner {
        Pools storage p = Pool[_pool];
        IERC20 token = IERC20(p.payToken);
        uint tokenBalance = p.rebuyBalance;
        require(token.balanceOf(address(this)) >= tokenBalance, 'Not enough token.balance to recovery');
        token.safeTransfer(msg.sender, tokenBalance);
        p.rebuyBalance = p.rebuyBalance - tokenBalance;
    }
    function recoveryFunds() public onlyOwner {
        address payable _owner = payable(msg.sender);
        _owner.transfer(address(this).balance);
    }
    function isEligible(address _user) public view returns (bool _isEligible) {
        (uint _isInXoXo,,,,) = XoXoContract.getUserData(_user);
        (,,,,,uint[] memory _slotsGlobalpool) = XoXoContract.getUserPoolData(_user, 2);

        if (_isInXoXo > 0 && _slotsGlobalpool.length > 0) return true;
        else return false;
    }
    function addressToId(address _user) public view returns (uint id) {
        return (XoXoContract.addressToId(_user));
    }
    receive() external payable {}
}