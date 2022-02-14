/**
 *Submitted for verification at BscScan.com on 2022-02-13
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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
        _setOwner(initialOwner);
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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





contract DepositPool is Ownable {
    using SafeERC20 for IERC20;
    using Address for address;

    IERC20 private USDT;


    struct User {
        address referral;
        uint256 regBlock;
        uint256 reward;
        uint256[] deposits;
    }


    struct Deposit {
        address user;
        uint256 index;
        uint256 amount;
        uint256 block;
        uint256 date;
    }


    struct Manager {
        address wallet; // кошелек
        uint256 share; // процент распределения депозита
        uint256 totalDeposits; // всего получено депозитов
        uint256 withdrawnAmount; // сколько вывел
        uint256 totalDividends; // сколько выплатил дивидендов
        uint256 regBlock; // блок, когда зарегистрировался
        uint256[] deposits; // массив id полученных депозитов
    }

    // user -> manager wallet -> reward id
    mapping (address => mapping (address => uint256)) private _lastClaimedDividendIndex;

    // manager address to position in managers list mapping
    mapping (address => uint256) private _managerIndex;

    mapping (address => bool) private _isManager;

    mapping (uint256 => mapping (address => uint256)) private _depositManagerIndex;


    // list of managers
    Manager[] private _managers;

    mapping (uint256 => Deposit) private _deposits;

    mapping (address => User) private _users;

    bool public _isLocked;

    uint256 private _totalDeposits;

    uint256 private _withdrawPool;

    uint256 private _totalUsers;

    uint256 private _depositLockPeriod = 3 * 30 * 24 * 60 * 60;

    uint256 private MIN_DEPOSIT_AMOUNT = 100 * 10 ** 18;

    uint256 private MAX_DEPOSITS_PER_USER = 10;

    uint256 private _lastDepositId;

    uint256 private _withdrawPoolRatio = 100;

    uint256 private _teamRatio = 250;

    uint256[5] private _percentages = [20, 10, 5, 3, 1];

    address private _teamWallet = 0x294658373ADBDBe836e2E841BB1996ceA9e56Fe3;

    event NewDeposit(address indexed sender, uint256 _id, uint256 _amount, uint256 _block);
    event DepositDistributed(uint256 _id, address indexed _manager, uint256 _amount);
    event DividendDistributed(uint256 _id, address indexed _wallet, uint256 _period, uint256 _deposit, uint256 _share);
    event BaseCalculated(uint256 _base);


    modifier onlyUser() {
        require(_users[_msgSender()].regBlock > 0, "User is not registered");
        _;
    }

    modifier onlyManager() {
        require(isManager(_msgSender()), "Only managers allowed to send dividends");
        _;
    }


    constructor(address cOwner) Ownable(cOwner) {

    }


    function getDepositLockPeriod() public view returns(uint256) {
        return _depositLockPeriod;

    }

    function setDepositLockPeriod(uint256 _value) public onlyOwner {
        _depositLockPeriod = _value;
    }

    function getMinDepositAmount() public view returns(uint256) {
        return MIN_DEPOSIT_AMOUNT;

    }

    function setMinDepositAmount(uint256 _value) public onlyOwner {
        require(_value > 0, "Min. deposit amount cannot be zero");
        MIN_DEPOSIT_AMOUNT = _value;
    }


    function getMaxDeposits() public view returns(uint256) {
        return MAX_DEPOSITS_PER_USER;

    }


    function setMaxDeposits(uint256 _value) public onlyOwner {
        require(_value > 0, "Max. deposits cannot be zero");
        MAX_DEPOSITS_PER_USER = _value;
    }


    function setUSDTContract(address account) public onlyOwner {
        require((account.isContract() && account != address(0)), "Invalid coin contract address");
        USDT = IERC20(account);
    }


    function setWithdrawPoolRatio(uint256 _value) public onlyOwner {
        require((_value > 0 && _value < 1000), "Invalid value, must be 1-1000");
        _withdrawPoolRatio = _value;
    }


    function setTeamRatio(uint256 _value) public onlyOwner {
        require((_value > 0 && _value < 1000), "Invalid value, must be 1-1000");
        _teamRatio = _value;
    }


    function isManager(address account) public view returns(bool) {
        return _isManager[account];
    }

    function toggleLock() external onlyOwner {
        _isLocked = !_isLocked;
    }

    function fixShares() private {
        uint256 totalShares;
        for (uint i = 0; i < _managers.length; i++) {
            totalShares += _managers[i].share;
        }
        if (totalShares < 10000) {
            _managers[_managers.length - 1].share += (10000 - totalShares);
        } else if (totalShares > 10000) {
            _managers[_managers.length - 1].share -= (totalShares - 10000);

        }

    }


    function addManager(address account, uint256 share) public onlyOwner {
        require(account != address(0), "Zero address not allowed");
        require(!isManager(account), "Address is already a manager");
        require((share > 0 && share < 10000), "Invalid share value");
        require(_managers.length < 100, "Maximum managers limit reached");

        if (_managers.length > 0) {
            uint256 shareRatio = share / _managers.length;
            for (uint i = 0; i < _managers.length; i++) {
                _managers[i].share -= shareRatio;
            }
            share -= (shareRatio * _managers.length);
        }

        uint256[] memory emptyArray;

        Manager memory man = Manager({
                                    wallet: account,
                                    share: share,
                                    totalDeposits: 0,
                                    withdrawnAmount: 0,
                                    totalDividends: 0,
                                    regBlock: block.number,
                                    deposits: emptyArray
                                });

        _isManager[account] = true;
        _managerIndex[account] = _managers.length;
        _managers.push(man);
        fixShares();
    }


    function removeManager(address account) public onlyOwner {
        require(account != address(0), "Zero address not allowed");
        require(isManager(account), "Address is not a manager");
        uint256 currentId = _managerIndex[account];
        uint256 lastId = _managers.length - 1;
        uint256 shareRatio = _managers[currentId].share / _managers.length-1;
        _isManager[account] = false;
        if (lastId != currentId) {
            _managers[currentId] = _managers[lastId];
            _managerIndex[_managers[currentId].wallet] = currentId;
        }
        _managers.pop();
        if (_managers.length > 0) {
            for (uint i = 0; i < _managers.length; i++) {
                _managers[i].share += shareRatio;
            }
            fixShares();
        }
    }


    function getManagerData(address account) public view returns(address, uint256, uint256, uint256, uint256, uint256) {
        require(isManager(account), "Address is not a manager");
        uint256 currentId = _managerIndex[account];
        return (
            _managers[currentId].wallet,
            _managers[currentId].share,
            _managers[currentId].totalDeposits,
            _managers[currentId].withdrawnAmount,
            _managers[currentId].totalDividends,
            _managers[currentId].regBlock
            );
    }


    function getReferrals(address account) public view returns(address[] memory) {
        require(_users[account].regBlock > 0, "User is not registered");
        address wallet = account;
        address[] memory result = new address[](5);
        for (uint8 i = 0; i < 5; i++) {
            if (_users[wallet].referral != address(0)) {
                result[i] = _users[wallet].referral;
                wallet = _users[wallet].referral;
            } else {
                break;
            }

        }
        return result;
    }


    function getUserDepositAmount(address account) public view returns(uint256) {
        require(_users[account].regBlock > 0, "User is not registered");
        uint result;
        for (uint i = 0; i < _users[account].deposits.length; i++) {
            result += _deposits[_users[account].deposits[i]].amount;
        }
        return result;
    }


    function getDepositsByUser(address account) public view returns(uint256[] memory, uint256[] memory) {
        require(_users[account].regBlock > 0, "User is not registered");
        uint[] memory amounts = new uint[](_users[account].deposits.length);
        uint[] memory ids = new uint[](_users[account].deposits.length);
        for (uint i = 0; i < _users[account].deposits.length; i++) {
            amounts[i] = _deposits[_users[account].deposits[i]].amount;
            ids[i] = _users[account].deposits[i];

        }
        return (ids, amounts);

    }


    function registerUser(address wallet, address ref) private {
        uint256[] memory emptyArray;
        User memory user = User({
                                    referral: ref,
                                    regBlock: block.number,
                                    reward: 0,
                                    deposits: emptyArray
                                });

        _users[wallet] = user;
        _totalUsers += 1;
    }


    function distributeDeposit(uint256 depositID, uint256 amount) private {
        uint totalAmount;
        uint256 share;
        for (uint i = 0; i < _managers.length-1; i++) {
            share = amount * _managers[i].share / 10000;
            _managers[i].totalDeposits += share;
            totalAmount += share;
            _managers[i].deposits.push(depositID);
            _depositManagerIndex[depositID][_managers[i].wallet] = _managers[i].deposits.length - 1;
            emit DepositDistributed(depositID, _managers[i].wallet, share);
        }
        _managers[_managers.length-1].totalDeposits += amount - totalAmount;
        _managers[_managers.length-1].deposits.push(depositID);
        _depositManagerIndex[depositID][_managers[_managers.length-1].wallet] = _managers[_managers.length-1].deposits.length - 1;
        emit DepositDistributed(depositID, _managers[_managers.length-1].wallet, amount - totalAmount);

    }


    function deposit(uint256 amount, address referral) public {
        require(amount >= MIN_DEPOSIT_AMOUNT, "Insufficient USDT amount");
        require(_users[_msgSender()].deposits.length < MAX_DEPOSITS_PER_USER, "Max deposits per user reached");
        require(_managers.length > 0, "No managers set, deposits are not allowed");
        require(address(USDT) != address(0), "USDT contract address is not set");
        require(!_isLocked, "Contract is locked now");
        USDT.safeTransferFrom(_msgSender(), address(this), amount);
        if (_users[_msgSender()].regBlock == 0) {
            registerUser(_msgSender(), referral);
        }
        uint256 totalAmount = amount;
        uint256 fee = amount * 2 / 100;

        if (_teamWallet != address(0)) {
            USDT.safeTransfer(_teamWallet, fee);
            totalAmount -= fee;
        }

        if (referral != address(0)) {
            USDT.safeTransfer(referral, fee);
            totalAmount -= fee;
        }

        _totalDeposits += totalAmount;
        _lastDepositId++;
        _users[_msgSender()].deposits.push(_lastDepositId);

        Deposit memory depo = Deposit({
                                    user: _msgSender(),
                                    index: _users[_msgSender()].deposits.length - 1,
                                    amount: totalAmount,
                                    block: block.number,
                                    date: block.timestamp
                                });

        _deposits[_lastDepositId] = depo;
        emit NewDeposit(_msgSender(), _lastDepositId, totalAmount, block.number);
        distributeDeposit(_lastDepositId, totalAmount);

    }


    function distibuteDividend(uint256 amount, uint managerId, uint256 blocknum) private {
        uint256 base;
        uint256 depositAmount;
        uint256 depositPeriod;
        for (uint i = 0; i < _managers[managerId].deposits.length; i++) {
            depositPeriod = blocknum - _deposits[_managers[managerId].deposits[i]].block;
            depositAmount = _deposits[_managers[managerId].deposits[i]].amount;
            base +=  (depositPeriod * depositAmount);
        }
        emit BaseCalculated(base);
        address userWallet;
        uint256 userShare;
        for (uint i = 0; i < _managers[managerId].deposits.length; i++) {
            userWallet = _deposits[_managers[managerId].deposits[i]].user;
            depositPeriod = blocknum - _deposits[_managers[managerId].deposits[i]].block;
            depositAmount = _deposits[_managers[managerId].deposits[i]].amount;
            userShare = depositAmount * depositPeriod * amount / base;
            _users[userWallet].reward += userShare;
            emit DividendDistributed(_managers[managerId].deposits[i], userWallet, depositPeriod, depositAmount, userShare);

        }

    }


    function payDividend(uint256 amount) public onlyManager {
        require(!_isLocked, "Contract is locked now");
        require(amount > 0, "Amount must be greater than zero");
        uint256 currentId = _managerIndex[_msgSender()];
        require(_managers[currentId].deposits.length > 0, "No deposits to pay dividends for");
        _managers[currentId].totalDividends += amount;
        USDT.safeTransferFrom(_msgSender(), address(this), amount);
        uint256 teamFee = amount * _teamRatio / 1000;
        uint256 wpFee = amount * _withdrawPoolRatio / 1000;
        if (teamFee > 0) {
            USDT.safeTransfer(_teamWallet, teamFee);
        }
        if (wpFee > 0) {
            _withdrawPool += wpFee;

        }
        distibuteDividend(amount - teamFee - wpFee, currentId, block.number);
    }


    function managerWithdraw() public onlyManager {
        uint currentId = _managerIndex[_msgSender()];
        uint withdrawAmount = _managers[currentId].totalDeposits - _managers[currentId].withdrawnAmount;
        require(withdrawAmount > 0, "Nothing to withdraw");
        require(USDT.balanceOf(address(this)) >=  withdrawAmount, "Insufficient USDT balance on contract to withdraw");
        _managers[currentId].withdrawnAmount += withdrawAmount;
        USDT.safeTransfer(_managers[currentId].wallet, withdrawAmount);
    }


    function withdrawDividends(uint256 amount) public onlyUser {
        require(amount <= _users[_msgSender()].reward, "Insufficient amount to withdraw");
        require(amount <= USDT.balanceOf(address(this)), "Insufficient USDT balance of contract to withdraw");
        uint totalAmount = amount;
        uint refBonus;
        address[] memory referrals = getReferrals(_msgSender());
        for (uint i = 0; i < referrals.length; i++) {
            if (referrals[i] != address(0)) {
                refBonus = amount * _percentages[i] / 100;
                USDT.safeTransfer(referrals[i], refBonus);
                totalAmount -= refBonus;
            } else {
                break;
            }
        }
        USDT.safeTransfer(_msgSender(), totalAmount);
        _users[_msgSender()].reward -= amount;
    }


    function getUserDividendsAmount(address account) public view returns (uint256) {
        return _users[account].reward;

    }


    function withdrawDeposit(uint256 depositId, uint256 amount) public onlyUser {
        require(_users[_msgSender()].deposits.length > 0, "User has no active deposits");
        require(amount > 0, "Amount cannot be zero");
        require(_deposits[depositId].user == _msgSender(), "Deposit doesn't belong to you");
        require(_deposits[depositId].amount >= amount, "Amount exceeds deposit amount");
        require(amount <= _withdrawPool, "Insufficient USDT balance on contract to withdraw");
        uint256 depositPeriod = block.timestamp - _deposits[depositId].date;
        require(depositPeriod > _depositLockPeriod, "Deposit cannot be withdrawn earlier");
        uint256 currentId = _deposits[depositId].index;
        uint256 lastId = _users[_msgSender()].deposits.length - 1;

        if (amount < _deposits[depositId].amount) {
            _deposits[depositId].amount -= amount;
        } else {
            if ( currentId != lastId) {
                _users[_msgSender()].deposits[currentId] = _users[_msgSender()].deposits[lastId];
            }
            _users[_msgSender()].deposits.pop();
            for (uint i = 0; i < _managers.length; i++) {
                currentId = _depositManagerIndex[depositId][_managers[i].wallet];
                lastId = _managers[i].deposits.length - 1;
                if ( currentId != lastId) {
                    _managers[i].deposits[currentId] = _managers[i].deposits[lastId];
                }
                _managers[i].deposits.pop();
            }
            delete _deposits[depositId];
        }
        uint fee;
        if (depositPeriod <= 365 * 24 * 60 * 60) {
            fee = amount * 26/100;
        }
        _withdrawPool -= (amount - fee);
        _totalDeposits -= amount;
        USDT.safeTransfer(_msgSender(), amount - fee);
    }


    function sendToWithdrawPool(uint256 amount) public {
        require(address(USDT) != address(0), "USDT contract address is not set");
        require(!_isLocked, "Contract is locked now");
        USDT.safeTransferFrom(_msgSender(), address(this), amount);
        _withdrawPool += amount;
    }


    function getTotalDepositsAmount() public view returns (uint256) {
        return _totalDeposits;
    }

    function getWithdrawPoolAmount() public view returns (uint256) {
        return _withdrawPool;
    }


    function getTotalUsersCount() public view returns (uint256) {
        return _totalUsers;
    }

    function getTotalManagersCount() public view returns (uint256) {
        return _managers.length;
    }






}