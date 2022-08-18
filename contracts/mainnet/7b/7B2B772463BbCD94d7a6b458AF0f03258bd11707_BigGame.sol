/**
 *Submitted for verification at BscScan.com on 2022-08-18
*/

/*
 /$$$$$$$  /$$$$$$  /$$$$$$           /$$$$$$   /$$$$$$  /$$      /$$ /$$$$$$$$
| $$__  $$|_  $$_/ /$$__  $$         /$$__  $$ /$$__  $$| $$$    /$$$| $$_____/
| $$  \ $$  | $$  | $$  \__/        | $$  \__/| $$  \ $$| $$$$  /$$$$| $$
| $$$$$$$   | $$  | $$ /$$$$ /$$$$$$| $$ /$$$$| $$$$$$$$| $$ $$/$$ $$| $$$$$
| $$__  $$  | $$  | $$|_  $$|______/| $$|_  $$| $$__  $$| $$  $$$| $$| $$__/
| $$  \ $$  | $$  | $$  \ $$        | $$  \ $$| $$  | $$| $$\  $ | $$| $$
| $$$$$$$/ /$$$$$$|  $$$$$$/        |  $$$$$$/| $$  | $$| $$ \/  | $$| $$$$$$$$
|_______/ |______/ \______/          \______/ |__/  |__/|__/     |__/|________/
*/


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


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

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
    constructor(address initialOwner) {
        require(initialOwner != address(0), "Zero owner address prohibited");
        _transferOwnership(initialOwner);
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


contract BigGame is Ownable {
    using SafeERC20 for IERC20;

    struct Fractal {
        uint256 secondLevelUserCount;
        uint256 timestamp;
        address upline;
        address[] firstLevelUsers;
    }


    struct User {
        uint256 id;
        uint256 refCount;
        address partner;
        mapping(uint256 => mapping(uint256 => uint256)) reinvestCount; // number of reinvests for each fractal -> level
        mapping(uint256 => mapping(uint256 => uint256)) earned; // amouint of earned BUSD for each fractal -> level
        mapping(uint256 => mapping(uint256 => Fractal)) fractals; // user fractals
    }

    struct UserData {
        uint256 id;
        uint256 partnersCount;
        uint256 partnerId;
        uint256 balance;
        address walletAddress;
    }


    struct FractalData {
        uint256[] reInvestCount;
        uint256[] fractalBalance;
        uint256[] timestamp;
        uint256[] idDownlineFirstMatrix;
        uint256[] idDownlineSecondMatrix;
        uint256[] firstMatrixRC;
        uint256[] secondMatrixRC;
    }

    mapping (uint256 => address) private _idToAddress;

    mapping (address => User) private _users; // mapping of users

    mapping (uint256 => uint256) private _fractalBonus; // bonus amount collected for each fractal

    uint256 private _lastUserId = 1;

    uint256 public _activationTime = 24 * 60 * 60;

    uint256 private _unclaimedAmount;

    uint256 private _basePrice = 20;

    uint256 private _baseBonus = 100;

    address private BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;


    event Register(address indexed _account, address indexed _ref);

    event FractalCreated(address indexed _account, uint256 _fractal, uint256 _level);

    event Bonus(address indexed _account, uint256 _fractal, uint256 _amount);

    event Payment(address indexed _upline, uint256 _fractal, uint256 _level, uint256 _amount);

    event Reinvest(address indexed _account, uint256 _fractal, uint256 _level);

    constructor(address initialOwner) Ownable(initialOwner) {
        User storage u = _users[initialOwner];
        u.id = 1;
        u.refCount = 0;
        u.partner = address(0);
        _idToAddress[1] = initialOwner;
        emit Register(initialOwner, address(0));
        for (uint i = 1; i<=8; i++) {
            Fractal storage f = _users[initialOwner].fractals[i][1];
            f.secondLevelUserCount = 0;
            f.timestamp = block.timestamp;
            f.upline = address(0);
            f.firstLevelUsers = new address[](0);
            emit FractalCreated(initialOwner, i, 1);
        }
    }

    function setBonus(uint256 _amount) external onlyOwner {
        _baseBonus = _amount;
    }

    function changeFractalTime(uint256 _period) external onlyOwner {
        _activationTime = _period;
    }

    function allParticipants() public view returns (uint256) {
        return _lastUserId;
    }


    function adminProfit() public view returns (uint256) {
        uint256 _adminProfit;
        for (uint i = 1; i<=8; i++) {
            _adminProfit += (_users[_idToAddress[1]].earned[i][1] + _users[_idToAddress[1]].earned[i][2]);
        }
        return _adminProfit;
    }


    function unclaimed() public view returns (uint256) {
        return _unclaimedAmount;
    }

    function fractalPrize() public view returns(uint256[] memory, uint256[] memory) {
        uint256[] memory requiredBonus = new uint256[](8);
        uint256[] memory actualBonus = new uint256[](8);
        for (uint i = 1; i <= 8; i++) {
            requiredBonus[i-1] = _baseBonus * 2 ** (i-1);
            actualBonus[i-1] = _fractalBonus[i] / 10 ** uint256(IERC20(BUSD).decimals());
        }
        return(actualBonus, requiredBonus);
    }


    function registerUser(address _account, uint256 _refId) internal {
        address _ref;
        if (_refId == 0 || _refId > _lastUserId) {
            _ref = _idToAddress[1];
        } else {
            _ref = _idToAddress[_refId];
        }
        _lastUserId += 1;
        User storage u = _users[_account];
        u.id = _lastUserId;
        u.refCount = 0;
        u.partner = _ref;
        _idToAddress[_lastUserId] = _account;
        _users[_ref].refCount += 1;
        emit Register(_account, _ref);
    }

    function userRegistered(address _account) internal view returns (bool) {
        return _users[_account].id > 0;
    }

    function hasFractal(address _account, uint256 _fractal, uint256 _level) internal view returns (bool) {
        return _users[_account].fractals[_fractal][_level].timestamp > 0;
    }

    function isInArray(address _account, address[] memory _array) internal pure returns(bool) {
        for (uint i = 0; i < _array.length; i++) {
            if (_array[i] == _account) return true;
        }
        return false;
    }

    function getMatrixLength(address _account, uint256 _fractal, uint256 _level) internal view returns(uint256) {
        return _users[_account].fractals[_fractal][_level].firstLevelUsers.length;
    }


    function findFreePlace(address _account, uint256 _fractal, uint256 _level) internal view returns(address) {
        address upline;
        address ref = _users[_account].partner;
        if (!hasFractal(ref, _fractal, _level)) {
            return (address(0));
        }
        if (isInArray(_account, _users[ref].fractals[_fractal][_level].firstLevelUsers)) {
            return (address(0));
        }
        if (getMatrixLength(ref, _fractal, _level) < 5) {
            upline = ref;
        }
        address user;
        for (uint i = 0; i < getMatrixLength(ref, _fractal, _level); i++) {
            user = _users[ref].fractals[_fractal][_level].firstLevelUsers[i];
            if (isInArray(_account, _users[user].fractals[_fractal][_level].firstLevelUsers)) {
                return (address(0));
            }
            if (getMatrixLength(user, _fractal, _level) < 5 && upline == address(0))  {
                upline = user;
            }
        }
        return upline;
    }


    function buyFractal(uint256 _fractal) public {
        if (userRegistered(_msgSender())) {
            buyFractal(_fractal, _users[_users[_msgSender()].partner].id);
        } else {
            buyFractal(_fractal, 0);
        }
    }


    function buyFractal(uint256 _fractal, uint256 _refId) public {
        if (!userRegistered(_msgSender())) {
            registerUser(_msgSender(), _refId);
        }
        require(!hasFractal(_msgSender(), _fractal, 1), "User already has this fractal active");
        require((_fractal > 0 && _fractal <= 8), "Invalid fractal value");
        if (_fractal > 1) {
            require(hasFractal(_msgSender(), _fractal-1, 1), "You must buy previos fractal first");
            require(block.timestamp - _users[_msgSender()].fractals[_fractal-1][1].timestamp > _activationTime, "You cannot buy fractals too often");
        }
        uint256 amount = _basePrice * 2 ** (_fractal-1) * 10 ** uint256(IERC20(BUSD).decimals());
        IERC20(BUSD).safeTransferFrom(_msgSender(), address(this), amount);
        address upline = findFreePlace(_msgSender(), _fractal, 1);
        Fractal storage f = _users[_msgSender()].fractals[_fractal][1];
        f.secondLevelUserCount = 0;
        f.timestamp = block.timestamp;
        f.upline = upline;
        f.firstLevelUsers = new address[](0);
        emit FractalCreated(_msgSender(), _fractal, 1);
        processUplines(_msgSender(), upline, _fractal, 1, amount);
    }

    function getAmounts(uint256 _fractal, uint256 _level, uint256 _amount) internal pure returns(uint256, uint256, uint256) {
        uint256 bonus;
        uint256 lOnePayment;
        if (_level == 1) {
            bonus = _amount / 4;
            lOnePayment = _amount / 4;
        } else {
            if (_fractal == 1) {
                lOnePayment = _amount * 30 / 100;
            } else {
                lOnePayment = _amount / 4;
            }
        }
        uint256 lTwoPayment = _amount - bonus - lOnePayment;
        return (bonus, lOnePayment, lTwoPayment);
    }


    function processBonus(address _sender, uint256 _fractal, uint256 _bonus) internal {
        if (_bonus == 0) return;
        uint256 required = _baseBonus * 2 ** (_fractal-1) * 10 ** uint256(IERC20(BUSD).decimals());
        if (_fractalBonus[_fractal] + _bonus < required) {
            _fractalBonus[_fractal] += _bonus;
        } else {
            IERC20(BUSD).safeTransfer(_sender, required / 2);
            _users[_sender].earned[_fractal][1] += required / 2;
            emit Bonus(_sender, _fractal, required / 2);
            IERC20(BUSD).safeTransfer(_users[_sender].partner, required / 2);
            _users[_users[_sender].partner].earned[_fractal][1] += required / 2;
            emit Bonus(_users[_sender].partner, _fractal, required / 2);
            _fractalBonus[_fractal] = _fractalBonus[_fractal] + _bonus - required;
        }
    }


    function processUplines(address _sender, address _upline, uint256 _fractal, uint256 _level, uint256 _amount) internal {
        (uint256 bonus, uint256 l1, uint256 l2) = getAmounts(_fractal, _level, _amount);
        if (_upline == address(0)) {
            _unclaimedAmount += (l1 + l2);
        } else {
            _users[_upline].fractals[_fractal][_level].firstLevelUsers.push(_sender);
            if (_users[_upline].fractals[_fractal][_level].firstLevelUsers.length < 5) {
                IERC20(BUSD).safeTransfer(_upline, l1);
                _users[_upline].earned[_fractal][_level] += l1;
                emit Payment(_upline, _fractal, _level, l1);
            }
            address upline2 = _users[_upline].fractals[_fractal][_level].upline;
            if (upline2 == address(0)) {
                _unclaimedAmount += l2;
            } else {
                _users[upline2].fractals[_fractal][_level].secondLevelUserCount += 1;
                if (_level == 1 && _users[upline2].fractals[_fractal][_level].secondLevelUserCount == 1 && !hasFractal(upline2, _fractal, 2)) {
                    buySecondLevel(upline2, _fractal);
                } else if (_users[upline2].fractals[_fractal][_level].secondLevelUserCount == 25) {
                    reinvest(upline2, _fractal, _level);
                    bonus = 0;
                } else {
                    IERC20(BUSD).safeTransfer(upline2, l2);
                    _users[upline2].earned[_fractal][_level] += l2;
                    emit Payment(upline2, _fractal, _level, l2);
                }
            }
        }
        processBonus(_sender, _fractal, bonus);
    }

    function buySecondLevel(address _account, uint256 _fractal) internal {
        uint256 amount = _basePrice * 2 ** (_fractal-1) * 10 ** uint256(IERC20(BUSD).decimals()) / 2;
        address upline = findFreePlace(_account, _fractal, 2);
        Fractal storage f = _users[_account].fractals[_fractal][2];
        f.secondLevelUserCount = 0;
        f.timestamp = block.timestamp;
        f.upline = upline;
        f.firstLevelUsers = new address[](0);
        emit FractalCreated(_account, _fractal, 2);
        processUplines(_account, upline, _fractal, 2, amount);
    }


    function reinvest(address _account, uint256 _fractal, uint256 _level) internal {
        uint256 amount;
        if (_level == 1) {
            amount = _basePrice * 2 ** (_fractal-1) * 10 ** uint256(IERC20(BUSD).decimals());
        } else {
            amount = _basePrice * 2 ** (_fractal-1) * 10 ** uint256(IERC20(BUSD).decimals()) / 2;
        }
        address upline = findFreePlace(_account, _fractal, _level);
        _users[_account].fractals[_fractal][_level].secondLevelUserCount = 0;
        _users[_account].fractals[_fractal][_level].upline = upline;
        _users[_account].fractals[_fractal][_level].firstLevelUsers = new address[](0);
        _users[_account].reinvestCount[_fractal][_level] += 1;
        emit Reinvest(_account, _fractal, _level);
        processUplines(_account, upline, _fractal, _level, amount);

    }


    function getUserData(address _account) public view returns(UserData memory) {
        uint256 balance;
        for (uint i = 1; i<=8; i++) {
            balance += (_users[_account].earned[i][1] + _users[_account].earned[i][2]);
        }
        UserData memory u = UserData({
                                    id: _users[_account].id,
                                    walletAddress: _account,
                                    partnersCount: _users[_account].refCount,
                                    partnerId: _users[_users[_account].partner].id,
                                    balance: balance
                                  });
        return u;
    }


    function getUserData(uint256 _id) public view returns(UserData memory) {
        address _account = _idToAddress[_id];
        uint256 balance;
        for (uint i = 1; i<=8; i++) {
            balance += (_users[_account].earned[i][1] + _users[_account].earned[i][2]);
        }
        UserData memory u = UserData({
                                    id: _id,
                                    walletAddress: _account,
                                    partnersCount: _users[_account].refCount,
                                    partnerId: _users[_users[_account].partner].id,
                                    balance: balance
                                  });
        return u;
    }



    function getIdMatrix(address _account, uint256 _fractal, uint256 _level) internal view returns(uint256[] memory) {
        uint256[] memory m = new uint256[](30);
        address user;
        for (uint i = 0; i < _users[_account].fractals[_fractal][_level].firstLevelUsers.length; i++) {
            user = _users[_account].fractals[_fractal][_level].firstLevelUsers[i];
            m[i] = _users[user].id;
            for (uint j = 0; j < _users[user].fractals[_fractal][_level].firstLevelUsers.length; j++) {
                m[(i+1) * 5 + j] = _users[_users[user].fractals[_fractal][_level].firstLevelUsers[j]].id;
            }
        }
        return m;
    }


    function getFractalData(address _account, uint256 _fractal) public view returns(FractalData memory) {
        uint256[] memory rc = new uint256[](2);
        rc[0] = _users[_account].reinvestCount[_fractal][1];
        rc[1] = _users[_account].reinvestCount[_fractal][2];
        uint256[] memory fb = new uint256[](2);
        fb[0] = _users[_account].earned[_fractal][1];
        fb[1] = _users[_account].earned[_fractal][2];
        uint256[] memory m1 = getIdMatrix(_account, _fractal, 1);
        uint256[] memory m2 = getIdMatrix(_account, _fractal, 2);
        uint256[] memory downRC1 = new uint256[](5);
        uint256[] memory downRC2 = new uint256[](5);
        for (uint i = 0; i < 5; i++) {
            if (m1[i] > 0) {
                downRC1[i] = _users[_idToAddress[m1[i]]].reinvestCount[_fractal][1];
            }
            if (m2[i] > 0) {
                downRC2[i] = _users[_idToAddress[m2[i]]].reinvestCount[_fractal][2];
            }
        }
        uint256[] memory ts = new uint256[](2);
        ts[0] = _users[_account].fractals[_fractal][1].timestamp;
        ts[1] = _users[_account].fractals[_fractal][2].timestamp;

        FractalData memory f = FractalData({
                                    reInvestCount: rc,
                                    fractalBalance: fb,
                                    timestamp: ts,
                                    idDownlineFirstMatrix: m1,
                                    idDownlineSecondMatrix: m2,
                                    firstMatrixRC: downRC1,
                                    secondMatrixRC: downRC2
                                  });
        return f;
    }


    function refundBUSD(uint256 _amount) external onlyOwner {
        require(_amount > 0, "Zero amount not allowed");
        IERC20(BUSD).safeTransfer(owner(), _amount);
        if (_unclaimedAmount >= _amount) {
            _unclaimedAmount -= _amount;
        } else {
            _unclaimedAmount = 0;
        }
    }
}