/**
 *Submitted for verification at BscScan.com on 2022-07-19
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

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

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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
}

abstract contract IERC223 {
    function name() public view virtual returns (string memory);

    function symbol() public view virtual returns (string memory);

    function standard() public view virtual returns (string memory);

    function decimals() public view virtual returns (uint8);

    function totalSupply() public view virtual returns (uint256);

    /**
     * @dev Returns the balance of the `who` address.
     */
    function balanceOf(address who) public view virtual returns (uint256);

    /**
     * @dev Transfers `value` tokens from `msg.sender` to `to` address
     * and returns `true` on success.
     */
    function transfer(address to, uint256 value)
        public
        virtual
        returns (bool success);

    /**
     * @dev Transfers `value` tokens from `msg.sender` to `to` address with `data` parameter
     * and returns `true` on success.
     */
    function transfer(
        address to,
        uint256 value,
        bytes calldata data
    ) public virtual returns (bool success);

    /**
     * @dev Event that is fired on successful transfer.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Additional event that is fired on successful transfer and logs transfer metadata,
     *      this event is implemented to keep Transfer event compatible with ERC20.
     */
    event TransferData(bytes data);
}

abstract contract IERC223Recipient {
    struct ERC223TransferInfo {
        address token_contract;
        address sender;
        uint256 value;
        bytes data;
    }

    ERC223TransferInfo private tkn;

    /**
     * @dev Standard ERC223 function that will handle incoming token transfers.
     *
     * @param _from  Token sender address.
     * @param _value Amount of tokens.
     * @param _data  Transaction metadata.
     */
    function tokenReceived(
        address _from,
        uint256 _value,
        bytes memory _data
    ) public virtual {
        /**
         * @dev Note that inside of the token transaction handler the actual sender of token transfer is accessible via the tkn.sender variable
         * (analogue of msg.sender for Ether transfers)
         *
         * tkn.value - is the amount of transferred tokens
         * tkn.data  - is the "metadata" of token transfer
         * tkn.token_contract is most likely equal to msg.sender because the token contract typically invokes this function
         */
        tkn.token_contract = msg.sender;
        tkn.sender = _from;
        tkn.value = _value;
        tkn.data = _data;

        // ACTUAL CODE
    }
}

contract ERC223Token is IERC223, Context, ReentrancyGuard {
    string private _name = "BUSDRice";
    string private _symbol = "RICE";
    uint8 private _decimals = 18;
    uint256 private _totalSupply;

    mapping(address => uint256) public balances; // List of user balances.

    /**
     * @dev ERC223 tokens must explicitly return "erc223" on standard() function call.
     */
    function standard() public pure override returns (string memory) {
        return "erc223";
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC223} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC223-balanceOf} and {IERC223-transfer}.
     */
    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC223-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Returns balance of the `_owner`.
     *
     * @param _owner   The address whose balance will be returned.
     * @return balance Balance of the `_owner`.
     */
    function balanceOf(address _owner) public view override returns (uint256) {
        return balances[_owner];
    }

    /**
     * @dev Transfer the specified amount of tokens to the specified address.
     *      Invokes the `tokenFallback` function if the recipient is a contract.
     *      The token transfer fails if the recipient is a contract
     *      but does not implement the `tokenFallback` function
     *      or the fallback function to receive funds.
     *
     * @param _to    Receiver address.
     * @param _value Amount of tokens that will be transferred.
     * @param _data  Transaction metadata.
     */
    function transfer(
        address _to,
        uint256 _value,
        bytes calldata _data
    ) public override returns (bool success) {
        // Standard function transfer similar to ERC20 transfer with no _data .
        // Added due to backwards compatibility reasons .
        balances[msg.sender] = balances[msg.sender] - _value;
        balances[_to] = balances[_to] + _value;
        if (Address.isContract(_to)) {
            IERC223Recipient(_to).tokenReceived(msg.sender, _value, _data);
        }
        emit Transfer(msg.sender, _to, _value);
        emit TransferData(_data);
        return true;
    }

    /**
     * @dev Transfer the specified amount of tokens to the specified address.
     *      This function works the same with the previous one
     *      but doesn't contain `_data` param.
     *      Added due to backwards compatibility reasons.
     *
     * @param _to    Receiver address.
     * @param _value Amount of tokens that will be transferred.
     */
    function transfer(address _to, uint256 _value)
        public
        override
        returns (bool success)
    {
        bytes memory _empty = hex"00000000";
        balances[msg.sender] = balances[msg.sender] - _value;
        balances[_to] = balances[_to] + _value;
        if (Address.isContract(_to)) {
            IERC223Recipient(_to).tokenReceived(msg.sender, _value, _empty);
        }
        emit Transfer(msg.sender, _to, _value);
        emit TransferData(_empty);
        return true;
    }

    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 _amount) internal virtual {
        balances[msg.sender] = balances[msg.sender] - _amount;
        _totalSupply = _totalSupply - _amount;

        emit Transfer(msg.sender, address(0), _amount);
    }

    /**
     * @dev See {ERC20-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the {MinterRole}.
     */
    function mint(address account, uint256 amount)
        internal
        virtual
        returns (bool)
    {
        bytes memory _empty = hex"00000000";
        balances[account] = balances[account] + amount;
        _totalSupply = _totalSupply + amount;
        if (Address.isContract(account)) {
            IERC223Recipient(account).tokenReceived(msg.sender, amount, _empty);
        }
        emit Transfer(address(0), account, amount);
        return true;
    }
}

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
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract ERC20 is Context, IERC20, ReentrancyGuard {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    string private _name = "BUSDRice";
    string private _symbol = "RICE";

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

contract BUSDRice is ERC223Token, Ownable {
    using SafeMath for uint256;

    event UserStake(
        address indexed addr,
        uint256 timestamp,
        uint256 rawAmount,
        uint256 duration
    );

    event UserStakeCollect(
        address indexed addr,
        uint256 timestamp,
        uint256 rawAmount
    );

    event UserLobby(address indexed addr, uint256 timestamp, uint256 rawAmount);

    event UserLobbyCollect(
        address indexed addr,
        uint256 timestamp,
        uint256 rawAmount
    );

    event stake_sell_request(
        address indexed addr,
        uint256 timestamp,
        uint256 price,
        uint256 rawAmount,
        uint256 stakeId
    );

    event stake_loan_request(
        address indexed addr,
        uint256 timestamp,
        uint256 rawAmount,
        uint256 duration,
        uint256 stakeId
    );

    event stake_lend(address indexed addr, uint256 timestamp, uint256 stakeId);

    event stake_loan(
        address indexed addr,
        uint256 timestamp,
        uint256 stakeId,
        uint256 value
    );

    event day_lobby_entry(uint256 timestamp, uint256 day, uint256 value);

    /* Address of flush accs */
    address internal busdriceTeam_addr = 0x0E2aE2B7462E5C9D0e91Ab850E1494Ac28bb254F;
    address internal marketing_addr = 0x0E2aE2B7462E5C9D0e91Ab850E1494Ac28bb254F;
    address internal buyBack_addr = 0x0E2aE2B7462E5C9D0e91Ab850E1494Ac28bb254F;

    /* BUSD Address */
    address internal busd_address = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    IERC20 public busd_token;

    /* % from every day's lobby entry dedicated to busdrice team, marketing and buy back */
    uint256 internal constant DM_busdriceTeam_percentage = 4;
    uint256 internal constant DM_marketing_percentage = 2;
    uint256 internal constant DM_buyBack_percentage = 1;

    /* Max staking days */
    uint256 internal constant max_stake_days = 300;

    /* Ref bonus NR, ex. 20 = 5% */
    uint256 internal constant ref_bonus_NR = 20;

    /* Refered person bonus NR, ex. 100 = 1% */
    uint256 internal constant ref_bonus_NRR = 100;

    /* dividends pool caps at 60 days, meaning that the lobby entery of days > 60 will only devide for next 60 days and no more */
    uint256 internal constant dividendsPoolCapDays = 60;

    /* Loaning feature is paused? */
    bool public loaningIsPaused = true;

    /* Stake selling feature is paused? */
    bool public stakeSellingIsPaused = true;

    uint256 public constant defaultLobby = 3000000 * 1e18;

    /* ------------------ for the sake of UI statistics ------------------ */
    // lobby memebrs overall data
    struct memberLobby_overallData {
        uint256 overall_collectedTokens;
        uint256 overall_lobbyEnteries;
        uint256 overall_stakedTokens;
        uint256 overall_collectedDivs;
    }
    // new map for every user's overall data
    mapping(address => memberLobby_overallData)
        public mapMemberLobby_overallData;
    // total lobby entry
    uint256 public overall_lobbyEntry;
    // total staked tokens
    uint256 public overall_stakedTokens;
    // total lobby token collected
    uint256 public overall_collectedTokens;
    // total stake divs collected
    uint256 public overall_collectedDivs;
    // total bonus token collected
    uint256 public overall_collectedBonusTokens;
    // total referrer bonus paid to an address
    mapping(address => uint256) public referrerBonusesPaid;
    // counting unique (unique for every day only) lobby enteries for each day
    mapping(uint256 => uint256) public usersCountDaily;
    // counting unique (unique for every day only) users
    uint256 public usersCount = 0;
    /* Total ever entered as stake tokens */
    uint256 public saveTotalToken;
    /* ------------------ for the sake of UI statistics ------------------ */

    /* lobby memebrs data */
    struct memberLobby {
        uint256 memberLobbyValue;
        bool hasCollected;
        address referrer;
    }

    /* new map for every entry (users are allowed to enter multiple times a day) */
    mapping(address => mapping(uint256 => memberLobby)) public mapMemberLobby;
    mapping(address => bool) public mapMemberBonus;

    /* day's total lobby entry */
    mapping(uint256 => uint256) public lobbyEntry;

    /* User stakes struct */
    struct memberStake {
        address userAddress;
        uint256 tokenValue;
        uint256 startDay;
        uint256 endDay;
        uint256 stakeId;
        uint256 price; // use: sell stake
        uint256 loansReturnAmount; // total of the loans return amount that have been taken on this stake
        bool stakeCollected;
        bool stake_hasSold; // stake been sold ?
        bool stake_forSell; // currently asking to sell stake ?
        bool stake_hasLoan; // is there an active loan on stake ?
        bool stake_forLoan; // currently asking for a loan on the stake ?
    }

    /* A map for each user */
    mapping(address => mapping(uint256 => memberStake)) public mapMemberStake;

    /* Total active tokens in stake for a day */
    mapping(uint256 => uint256) public daysActiveInStakeTokens;
    mapping(uint256 => uint256) public daysActiveInStakeTokensIncrese;
    mapping(uint256 => uint256) public daysActiveInStakeTokensDecrase;

    /* Time of contract launch */
    uint256 public LAUNCH_TIME;
    uint256 currentDay;
    bool public launched;

    constructor() {
        mint(msg.sender, defaultLobby);
        busd_token = IERC20(busd_address);
        LAUNCH_TIME = block.timestamp.add(180 days);
        launched = false;
    }

    function tokenReceived(
        address _from,
        uint256 _value,
        bytes calldata _data
    ) public {}

    function launch() public onlyOwner {
        require(launched == false, "contract already launched!");
        LAUNCH_TIME = block.timestamp.sub(1 days);
        launched = true;
    }

    /* Owner switching the loaning feature status */
    function switchLoaningStatus() external onlyOwner {
        if (loaningIsPaused == true) {
            loaningIsPaused = false;
        } else if (loaningIsPaused == false) {
            loaningIsPaused = true;
        }
    }

    /* Owner switching the stake selling feature status */
    function switchStakeSellingStatus() external onlyOwner {
        if (stakeSellingIsPaused == true) {
            stakeSellingIsPaused = false;
        } else if (stakeSellingIsPaused == false) {
            stakeSellingIsPaused = true;
        }
    }

    /* change marketing wallet address % */
    function do_changeMarketingAddress(address adr) external onlyOwner {
        marketing_addr = adr;
    }

    function _clcDay() public view returns (uint256) {
        return (block.timestamp - LAUNCH_TIME) / (1 days);
    }

    function _updateDaily() public {
        if (currentDay == _clcDay()) {
            return;
        }
        // this is true once a day

        if (currentDay < dividendsPoolCapDays) {
            for (
                uint256 _day = currentDay + 1;
                _day <= currentDay * 2;
                _day++
            ) {
                dayBNBPool[_day] +=
                    (lobbyEntry[currentDay] * 93) /
                    (currentDay * 100);
            }
        } else {
            for (
                uint256 _day = currentDay + 1;
                _day <= currentDay + dividendsPoolCapDays;
                _day++
            ) {
                dayBNBPool[_day] +=
                    (lobbyEntry[currentDay] * 93) /
                    (dividendsPoolCapDays * 100);
            }
        }

        currentDay = _clcDay();

        // total of 7% from every day's lobby entry goes to:
        _sendDevShare();
        // 1% marketing share
        _sendMarketingShare();
        // 1% buy back to current lobby day
        _buyLobbyBuybackShare();

        emit day_lobby_entry(
            block.timestamp,
            currentDay,
            lobbyEntry[currentDay - 1]
        );
    }

    /* Gets called once a day and withdraws busdrice team's share for the privious day of lobby */
    function _sendDevShare() internal nonReentrant {
        require(currentDay > 0);
        // busdriceTeamPercentage = 4% of every day's lobby entry
        uint256 busdriceTeamPercentage = (lobbyEntry[currentDay - 1] *
            DM_busdriceTeam_percentage) / 100;
        busd_token.transfer(busdriceTeam_addr, busdriceTeamPercentage);
    }

    /* Gets called once a day and withdraws marketing's share for the privious day of lobby */
    function _sendMarketingShare() internal nonReentrant {
        require(currentDay > 0);

        // marketing share = 2% of every day's lobby entry
        busd_token.transfer(
            marketing_addr,
            (lobbyEntry[currentDay - 1] * DM_marketing_percentage) / 100
        );
    }

    /* Gets called once a day and withdraws buy back share for the privious day of lobby */
    function _buyLobbyBuybackShare() internal nonReentrant {
        require(currentDay > 0);

        // marketing share = 1% of every day's lobby entry
        busd_token.transfer(
            buyBack_addr,
            (lobbyEntry[currentDay - 1] * DM_buyBack_percentage) / 100
        );
    }

    /**
     * @dev External function for entering the auction lobby for the current day
     * @param referrerAddr address of referring user (optional; 0x0 for no referrer)
     */
    function EnterLobby(address referrerAddr, uint256 amount) external {
        require(amount > 0, "ERR: Amount required");
        require(
            amount <= busd_token.allowance(msg.sender, address(this)),
            "You need to allow that token first"
        );

        busd_token.transferFrom(msg.sender, address(this), amount);

        _updateDaily();
        require(currentDay > 0);

        if (mapMemberLobby[msg.sender][currentDay].memberLobbyValue == 0) {
            usersCount++;
            usersCountDaily[currentDay]++;
        }

        mapMemberLobby_overallData[msg.sender].overall_lobbyEnteries += amount;
        lobbyEntry[currentDay] += amount;
        overall_lobbyEntry += amount;

        mapMemberLobby[msg.sender][currentDay].memberLobbyValue += amount;
        mapMemberLobby[msg.sender][currentDay].hasCollected = false;

        if (referrerAddr != msg.sender) {
            /* No Self-referred */
            mapMemberLobby[msg.sender][currentDay].referrer = referrerAddr;
        } else {
            mapMemberLobby[msg.sender][currentDay].referrer = address(0);
        }

        emit UserLobby(msg.sender, block.timestamp, amount);
    }

    /**
     * @dev External function for leaving the lobby / collecting the tokens
     * @param targetDay Target day of lobby to collect
     */
    function ExitLobby(uint256 targetDay) external {
        require(
            mapMemberLobby[msg.sender][targetDay].hasCollected == false,
            "ERR: Already collected"
        );
        _updateDaily();
        require(targetDay < currentDay);

        uint256 tokensToPay = _clcTokenValue(msg.sender, targetDay);

        mint(msg.sender, tokensToPay);
        mapMemberLobby[msg.sender][targetDay].hasCollected = true;

        overall_collectedTokens += tokensToPay;
        mapMemberLobby_overallData[msg.sender]
            .overall_collectedTokens += tokensToPay;

        address referrerAddress = mapMemberLobby[msg.sender][targetDay]
            .referrer;
        if (referrerAddress != address(0)) {
            /* there is a referrer, pay their % ref bonus of tokens */
            uint256 refBonus = tokensToPay / ref_bonus_NR;

            mint(referrerAddress, refBonus);
            referrerBonusesPaid[referrerAddress] += refBonus;

            /* pay the referred user bonus */
            mint(msg.sender, tokensToPay / ref_bonus_NRR);
        }

        emit UserLobbyCollect(msg.sender, block.timestamp, tokensToPay);
    }

    /**
     * @dev Calculating user's share from lobby based on their entry value
     * @param _Day The lobby day
     */
    function _clcTokenValue(address _address, uint256 _Day)
        public
        view
        returns (uint256)
    {
        require(_Day != 0, "ERR");
        uint256 _tokenVlaue;

        if (_Day != 0 && _Day < currentDay) {
            _tokenVlaue =
                (tokenForDay(_Day) / lobbyEntry[_Day]) *
                mapMemberLobby[_address][_Day].memberLobbyValue;
        } else {
            _tokenVlaue = 0;
        }

        return _tokenVlaue;
    }

    function tokenForDay(uint256 _day) public pure returns (uint256 value_) {
        if (_day < 1) {
            value_ = 0;
        } else {
            _day = _day - 1;
            if (_day > max_stake_days) {
                _day = max_stake_days;
            }
            value_ = defaultLobby;
            for (uint256 i = 0; i < _day; i++) {
                value_ = value_.add(value_.mul(2).div(100));
            }
        }
    }

    mapping(uint256 => uint256) public dayBNBPool;
    mapping(uint256 => uint256) public enterytokenMath;
    mapping(uint256 => uint256) public totalTokensInActiveStake;

    /**
     * @dev External function for users to create a stake
     * @param amount Amount of AVC tokens to stake
     * @param stakingDays Stake duration in days
     */

    function EnterStake(uint256 amount, uint256 stakingDays) external {
        require(stakingDays >= 1, "Staking: Staking days < 1");
        require(
            stakingDays <= max_stake_days,
            "Staking: Staking days > max_stake_days"
        );
        require(amount > 0, "Staking: Amount required");
        require(balanceOf(msg.sender) >= amount, "Not enough balance");

        _updateDaily();
        uint256 stakeId = calcStakeCount(msg.sender);

        overall_stakedTokens += amount;
        mapMemberLobby_overallData[msg.sender].overall_stakedTokens += amount;

        mapMemberStake[msg.sender][stakeId].stakeId = stakeId;
        mapMemberStake[msg.sender][stakeId].userAddress = msg.sender;
        mapMemberStake[msg.sender][stakeId].tokenValue = amount;
        mapMemberStake[msg.sender][stakeId].startDay = currentDay + 1;
        mapMemberStake[msg.sender][stakeId].endDay =
            currentDay +
            1 +
            stakingDays;
        mapMemberStake[msg.sender][stakeId].stakeCollected = false;
        mapMemberStake[msg.sender][stakeId].stake_hasSold = false;
        mapMemberStake[msg.sender][stakeId].stake_hasLoan = false;
        mapMemberStake[msg.sender][stakeId].stake_forSell = false;
        mapMemberStake[msg.sender][stakeId].stake_forLoan = false;
        // stake calcs for days: X >= startDay && X < endDay
        // startDay included / endDay not included

        for (uint256 i = currentDay + 1; i <= currentDay + stakingDays; i++) {
            totalTokensInActiveStake[i] += amount;
        }

        saveTotalToken += amount;
        daysActiveInStakeTokensIncrese[currentDay + 1] += amount;
        daysActiveInStakeTokensDecrase[currentDay + stakingDays + 1] += amount;

        /* On stake AVC tokens get burned */
        burn(amount);

        emit UserStake(msg.sender, block.timestamp, amount, stakingDays);
    }

    /**
     * @dev Counting user's stakes to be usead as stake id for a new stake
     * @param _address address of the user
     */
    function calcStakeCount(address _address) public view returns (uint256) {
        uint256 stakeCount = 0;

        for (
            uint256 i = 0;
            mapMemberStake[_address][i].userAddress == _address;
            i++
        ) {
            stakeCount += 1;
        }

        return (stakeCount);
    }

    /**
     * @dev External function for collecting a stake
     * @param stakeId Id of the target stake
     */
    function EndStake(uint256 stakeId) external {
        require(
            mapMemberStake[msg.sender][stakeId].endDay <= currentDay,
            "Stakes end day not reached yet"
        );
        require(
            mapMemberStake[msg.sender][stakeId].userAddress == msg.sender,
            "invalid sender"
        );
        require(
            mapMemberStake[msg.sender][stakeId].stakeCollected == false,
            "has collected"
        );
        require(
            mapMemberStake[msg.sender][stakeId].stake_hasLoan == false,
            "has loan"
        );
        require(
            mapMemberStake[msg.sender][stakeId].stake_hasSold == false,
            "has sold"
        );

        _updateDaily();

        /* if the stake is for sell, set it false since it's collected */
        mapMemberStake[msg.sender][stakeId].stake_forSell = false;
        mapMemberStake[msg.sender][stakeId].stake_forLoan = false;

        /* clc BNB divs */
        uint256 profit = calcStakeCollecting(msg.sender, stakeId);
        if (!mapMemberBonus[msg.sender]) {
            mapMemberBonus[msg.sender] = true;
            profit += (profit * 20 / 100);
        }

        overall_collectedDivs += profit;
        mapMemberLobby_overallData[msg.sender].overall_collectedDivs += profit;

        mapMemberStake[msg.sender][stakeId].stakeCollected = true;
        busd_token.transfer(msg.sender, profit);

        uint256 stakeReturn = mapMemberStake[msg.sender][stakeId].tokenValue;

        /* Pay the bonus token and stake return, if any, to the staker */
        if (stakeReturn != 0) {
            uint256 bonusAmount = calcBonusToken(
                mapMemberStake[msg.sender][stakeId].endDay,
                mapMemberStake[msg.sender][stakeId].startDay,
                stakeReturn
            );

            overall_collectedBonusTokens += bonusAmount;

            mint(msg.sender, stakeReturn + bonusAmount);
        }

        emit UserStakeCollect(msg.sender, block.timestamp, profit);
    }

    /**
     * @dev Calculating a stakes BNB divs payout value by looping through each day of it
     * @param _address User address
     * @param _stakeId Id of the target stake
     */
    function calcStakeCollecting(address _address, uint256 _stakeId)
        public
        view
        returns (uint256)
    {
        uint256 userDivs;
        uint256 _endDay = mapMemberStake[_address][_stakeId].endDay;
        uint256 _startDay = mapMemberStake[_address][_stakeId].startDay;
        uint256 _stakeValue = mapMemberStake[_address][_stakeId].tokenValue;

        for (
            uint256 _day = _startDay;
            _day < _endDay && _day < currentDay;
            _day++
        ) {
            userDivs +=
                (dayBNBPool[_day] * _stakeValue) /
                totalTokensInActiveStake[_day];
        }

        return (userDivs -
            mapMemberStake[_address][_stakeId].loansReturnAmount);
    }

    /**
     * @dev Calculating a stakes Bonus AVC tokens based on stake duration and stake amount
     * @param StakeAmount The stake's AVC tokens amount
     */
    function calcBonusToken(
        uint256 endDay,
        uint256 startDay,
        uint256 StakeAmount
    ) public pure returns (uint256) {
        require(endDay > startDay, "Staking: startDay > endDay");
        require(startDay > 0, "Staking: startDay < 1");
        uint256 StakeDuration = endDay - startDay;
        require(
            StakeDuration <= max_stake_days,
            "Staking: Staking days > max_stake_days"
        );
        uint256 startAmount = tokenForDay(startDay);
        uint256 endAmount = tokenForDay(endDay);

        uint256 _bonusAmount = endAmount.mul(1e18).div(startAmount);
        _bonusAmount = _bonusAmount.sub(1e18).mul(120).div(100);
        _bonusAmount = StakeAmount.mul(_bonusAmount).div(1e18);
        return _bonusAmount;
    }

    /**
     * @dev calculating user dividends for a specific day
     */
    uint256 public stakeLoanFee;
    uint256 public stakeLoanBuybackFee;
    uint256 public totalStakesSold;
    uint256 public totalTradeAmount;

    /* withdrawable funds for the stake seller address */
    mapping(address => uint256) public soldStakeFunds;
    mapping(address => uint256) public soldCredit;
    mapping(address => uint256) public totalStakeTradeAmount;

    /**
     * @dev User putting up their stake for sell or user changing the previously setted sell price of their stake
     * @param stakeId stake id
     * @param price sell price for the stake
     */
    function sellStakeRequest(uint256 stakeId, uint256 price) external {
        _updateDaily();

        require(stakeSellingIsPaused == false, "functionality is paused");
        require(
            mapMemberStake[msg.sender][stakeId].userAddress == msg.sender,
            "auth failed"
        );
        require(
            mapMemberStake[msg.sender][stakeId].stake_hasLoan == false,
            "Target stake has an active loan on it"
        );
        require(
            mapMemberStake[msg.sender][stakeId].stake_hasSold == false,
            "Target stake has been sold"
        );
        require(
            mapMemberStake[msg.sender][stakeId].endDay > currentDay,
            "Target stake is ended"
        );

        /* if stake is for loan, remove it from loan requests */
        if (mapMemberStake[msg.sender][stakeId].stake_forLoan == true) {
            cancelStakeLoanRequest(stakeId);
        }

        require(mapMemberStake[msg.sender][stakeId].stake_forLoan == false);

        mapMemberStake[msg.sender][stakeId].stake_forSell = true;
        mapMemberStake[msg.sender][stakeId].price = price;

        emit stake_sell_request(
            msg.sender,
            block.timestamp,
            price,
            mapMemberStake[msg.sender][stakeId].tokenValue,
            stakeId
        );
    }

    /**
     * @dev A user buying a stake
     * @param sellerAddress stake seller address (current stake owner address)
     * @param stakeId stake id
     */
    function buyStakeRequest(
        address sellerAddress,
        uint256 stakeId,
        uint256 _priceP
    ) external payable {
        _updateDaily();

        require(stakeSellingIsPaused == false, "functionality is paused");
        require(
            mapMemberStake[sellerAddress][stakeId].userAddress != msg.sender,
            "no self buy"
        );
        require(
            mapMemberStake[sellerAddress][stakeId].userAddress == sellerAddress,
            "auth failed"
        );
        require(
            mapMemberStake[sellerAddress][stakeId].stake_hasSold == false,
            "Target stake has been sold"
        );
        require(
            mapMemberStake[sellerAddress][stakeId].stake_forSell == true,
            "Target stake is not for sell"
        );
        uint256 priceP = _priceP;
        require(
            mapMemberStake[sellerAddress][stakeId].price == priceP,
            "not enough funds"
        );
        require(
            mapMemberStake[sellerAddress][stakeId].endDay > currentDay,
            "Error in currentday"
        );
        require(
            priceP <= busd_token.allowance(msg.sender, address(this)),
            "You need to allow that token first"
        );

        /* Save dev fee 1% (of stake price) - then get 4% on withdraw from User to mitigate the fee */
        /* Save 1% (of stake tokens) - then get 4% on withdraw from User to mitigate the manual buyback to the current lobby */
        stakeLoanFee += ((mapMemberStake[sellerAddress][stakeId].tokenValue * 1) / 100);
        stakeLoanBuybackFee += (priceP * 1) / 100;

        /* stake seller gets 90% of the stake's sold price */
        soldStakeFunds[sellerAddress] +=
            (mapMemberStake[sellerAddress][stakeId].price * 90) /
            100;

        /* buyer pay the price */
        busd_token.transferFrom(msg.sender, address(this), priceP);

        /* setting data for the old owner */
        mapMemberStake[sellerAddress][stakeId].stake_hasSold = true;
        mapMemberStake[sellerAddress][stakeId].stake_forSell = false;
        mapMemberStake[sellerAddress][stakeId].stakeCollected = true;

        totalStakeTradeAmount[msg.sender] += priceP;
        totalStakeTradeAmount[sellerAddress] += priceP;

        totalStakesSold += 1;
        totalTradeAmount += priceP;

        /* new stake & stake ID for the new stake owner (the stake buyer) */
        uint256 newStakeId = calcStakeCount(msg.sender);
        mapMemberStake[msg.sender][newStakeId].userAddress = msg.sender;
        mapMemberStake[msg.sender][newStakeId].tokenValue = mapMemberStake[
            sellerAddress
        ][stakeId].tokenValue;
        mapMemberStake[msg.sender][newStakeId].startDay = mapMemberStake[
            sellerAddress
        ][stakeId].startDay;
        mapMemberStake[msg.sender][newStakeId].endDay = mapMemberStake[
            sellerAddress
        ][stakeId].endDay;
        mapMemberStake[msg.sender][newStakeId]
            .loansReturnAmount = mapMemberStake[sellerAddress][stakeId]
            .loansReturnAmount;
        mapMemberStake[msg.sender][newStakeId].stakeId = newStakeId;
        mapMemberStake[msg.sender][newStakeId].stakeCollected = false;
        mapMemberStake[msg.sender][newStakeId].stake_hasSold = false;
        mapMemberStake[msg.sender][newStakeId].stake_hasLoan = false;
        mapMemberStake[msg.sender][newStakeId].stake_forSell = false;
        mapMemberStake[msg.sender][newStakeId].stake_forLoan = false;
        mapMemberStake[msg.sender][newStakeId].price = 0;
    }

    /**
     * @dev User asking to withdraw their funds from their sold stake
     */
    function withdrawSoldStakeFunds() external {
        require(soldStakeFunds[msg.sender] > 0, "No funds to withdraw");

        uint256 toBeSend = soldStakeFunds[msg.sender];
        uint256 stored = busd_token.balanceOf(address(this));

        // send reserved 4% of stakeLoanFee marketing_addr
        stakeLoanFee = stakeLoanFee * DM_busdriceTeam_percentage;
        stakeLoanBuybackFee = stakeLoanBuybackFee * DM_busdriceTeam_percentage;

        // if not enught BUSD to cover send FIRST on User what we can. Buyback after and refund later
        if (stakeLoanFee > stored) stakeLoanFee = stored - toBeSend;
        busd_token.transfer(marketing_addr, stakeLoanFee);
        mint(marketing_addr, stakeLoanBuybackFee);
        stakeLoanFee = 0;
        stakeLoanBuybackFee = 0;
        soldStakeFunds[msg.sender] = 0;

        // if not enught BUSD to cover send what we can. Buyback after and refund later
        stored = busd_token.balanceOf(address(this));
        if (toBeSend >= stored) {
            soldCredit[msg.sender] += (toBeSend - stored);
            toBeSend = stored;
        }

        busd_token.transfer(msg.sender, toBeSend);
    }

    struct loanRequest {
        address loanerAddress; // address
        address lenderAddress; // address (sets after loan request accepted by a lender)
        uint256 stakeId; // id of the stakes that is being loaned on
        uint256 loanAmount; // requesting loan BNB amount
        uint256 returnAmount; // requesting loan BNB return amount
        uint256 duration; // duration of loan (days)
        uint256 lend_startDay; // lend start day (sets after loan request accepted by a lender)
        uint256 lend_endDay; // lend end day (sets after loan request accepted by a lender)
        bool hasLoan;
        bool loanIsPaid; // gets true after loan due date is reached and loan is paid
    }

    struct lendInfo {
        address lenderAddress;
        address loanerAddress;
        uint256 stakeId;
        uint256 loanAmount;
        uint256 returnAmount;
        uint256 endDay;
        bool loanIsPaid;
    }

    /* withdrawable funds for the loaner address */
    mapping(address => uint256) public LoanedFunds;

    uint256 public totalLoanedAmount;
    uint256 public totalLoanedCount;

    mapping(address => mapping(uint256 => loanRequest))
        public mapRequestingLoans;
    mapping(address => mapping(uint256 => lendInfo)) public mapLenderInfo;
    mapping(address => uint256) public lendersPaidAmount; // total amounts of paid to lender

    /**
     * @dev User submiting a loan request on their stake or changing the previously setted loan request data
     * @param stakeId stake id
     * @param loanAmount amount of requesting BNB loan
     * @param returnAmount amount of BNB loan return
     * @param loanDuration duration of requesting loan
     */
    function getLoanOnStake(
        uint256 stakeId,
        uint256 loanAmount,
        uint256 returnAmount,
        uint256 loanDuration
    ) external {
        _updateDaily();

        require(loaningIsPaused == false, "functionality is paused");
        require(
            loanAmount < returnAmount,
            "loan return must be higher than loan amount"
        );
        require(loanDuration >= 4, "lowest loan duration is 4 days");
        require(
            mapMemberStake[msg.sender][stakeId].userAddress == msg.sender,
            "auth failed"
        );
        require(
            mapMemberStake[msg.sender][stakeId].stake_hasLoan == false,
            "Target stake has an active loan on it"
        );
        require(
            mapMemberStake[msg.sender][stakeId].stake_hasSold == false,
            "Target stake has been sold"
        );
        require(
            mapMemberStake[msg.sender][stakeId].endDay - loanDuration >
                currentDay
        );

        /* calc stake divs */
        uint256 stakeDivs = calcStakeCollecting(msg.sender, stakeId);

        /* max amount of possible stake return can not be higher than stake's divs */
        require(returnAmount <= stakeDivs);

        /* if stake is for sell, remove it from sell requests */
        if (mapMemberStake[msg.sender][stakeId].stake_forSell == true) {
            cancelSellStakeRequest(stakeId);
        }

        require(mapMemberStake[msg.sender][stakeId].stake_forSell == false);

        mapMemberStake[msg.sender][stakeId].stake_forLoan = true;

        /* data of the requesting loan */
        mapRequestingLoans[msg.sender][stakeId].loanerAddress = msg.sender;
        mapRequestingLoans[msg.sender][stakeId].stakeId = stakeId;
        mapRequestingLoans[msg.sender][stakeId].loanAmount = loanAmount;
        mapRequestingLoans[msg.sender][stakeId].returnAmount = returnAmount;
        mapRequestingLoans[msg.sender][stakeId].duration = loanDuration;
        mapRequestingLoans[msg.sender][stakeId].loanIsPaid = false;

        emit stake_loan_request(
            msg.sender,
            block.timestamp,
            loanAmount,
            loanDuration,
            stakeId
        );
    }

    /**
     * @dev Canceling loan request
     * @param stakeId stake id
     */
    function cancelStakeLoanRequest(uint256 stakeId) public {
        require(mapMemberStake[msg.sender][stakeId].stake_hasLoan == false);
        mapMemberStake[msg.sender][stakeId].stake_forLoan = false;
    }

    /**
     * @dev User asking to their stake's sell request
     */
    function cancelSellStakeRequest(uint256 _stakeId) internal {
        require(mapMemberStake[msg.sender][_stakeId].userAddress == msg.sender);
        require(mapMemberStake[msg.sender][_stakeId].stake_forSell == true);
        require(mapMemberStake[msg.sender][_stakeId].stake_hasSold == false);

        mapMemberStake[msg.sender][_stakeId].stake_forSell = false;
    }

    /**
     * @dev User filling loan request (lending)
     * @param loanerAddress address of loaner aka the person who is requesting for loan
     * @param stakeId stake id
     */
    function lendOnStake(
        address loanerAddress,
        uint256 stakeId,
        uint256 _priceP
    ) external payable nonReentrant {
        _updateDaily();

        require(loaningIsPaused == false, "functionality is paused");
        require(
            mapMemberStake[loanerAddress][stakeId].userAddress != msg.sender,
            "no self lend"
        );
        require(
            mapMemberStake[loanerAddress][stakeId].stake_hasLoan == false,
            "Target stake has an active loan on it"
        );
        require(
            mapMemberStake[loanerAddress][stakeId].stake_forLoan == true,
            "Target stake is not requesting a loan"
        );
        require(
            mapMemberStake[loanerAddress][stakeId].stake_hasSold == false,
            "Target stake is sold"
        );
        require(
            mapMemberStake[loanerAddress][stakeId].endDay > currentDay,
            "Target stake duration is finished"
        );

        uint256 loanAmount = mapRequestingLoans[loanerAddress][stakeId]
            .loanAmount;
        uint256 returnAmount = mapRequestingLoans[loanerAddress][stakeId]
            .returnAmount;
        uint256 rawAmount = _priceP;

        require(
            rawAmount == mapRequestingLoans[loanerAddress][stakeId].loanAmount
        );

        /* Save dev fee 1% (of stake price) - then get 4% on withdraw from User to mitigate the fee */
        /* Save 1% (of stake tokens) - then get 4% on withdraw from User to mitigate the manual buyback to the current lobby */
        stakeLoanFee += ((mapMemberStake[loanerAddress][stakeId].tokenValue * 1) / 100);
        stakeLoanBuybackFee += (rawAmount * 1) / 100;

        mapMemberStake[loanerAddress][stakeId]
            .loansReturnAmount += returnAmount;
        mapMemberStake[loanerAddress][stakeId].stake_hasLoan = true;
        mapMemberStake[loanerAddress][stakeId].stake_forLoan = false;

        mapRequestingLoans[loanerAddress][stakeId].hasLoan = true;
        mapRequestingLoans[loanerAddress][stakeId].loanIsPaid = false;
        mapRequestingLoans[loanerAddress][stakeId].lenderAddress = msg.sender;
        mapRequestingLoans[loanerAddress][stakeId].lend_startDay =
            currentDay +
            1;
        mapRequestingLoans[loanerAddress][stakeId].lend_endDay =
            currentDay +
            1 +
            mapRequestingLoans[loanerAddress][stakeId].duration;

        uint256 LenderStakeId = clcLenderStakeId(msg.sender);
        mapLenderInfo[msg.sender][LenderStakeId].lenderAddress = msg.sender;
        mapLenderInfo[msg.sender][LenderStakeId].loanerAddress = loanerAddress;
        mapLenderInfo[msg.sender][LenderStakeId].stakeId = LenderStakeId; // not same with the stake id on "mapRequestingLoans"
        mapLenderInfo[msg.sender][LenderStakeId].loanAmount = loanAmount;
        mapLenderInfo[msg.sender][LenderStakeId].returnAmount = returnAmount;
        mapLenderInfo[msg.sender][LenderStakeId].endDay = mapRequestingLoans[
            loanerAddress
        ][stakeId].lend_endDay;

        LoanedFunds[loanerAddress] += (rawAmount * 98) / 100;
        totalLoanedAmount += (rawAmount * 98) / 100;
        totalLoanedCount += 1;

        emit stake_lend(msg.sender, block.timestamp, LenderStakeId);

        emit stake_loan(
            loanerAddress,
            block.timestamp,
            stakeId,
            (rawAmount * 98) / 100
        );
    }

    /**
     * @dev User asking to withdraw their loaned funds
     */
    function withdrawLoanedFunds() external nonReentrant {
        require(LoanedFunds[msg.sender] > 0, "No funds to withdraw");

        uint256 toBeSend = LoanedFunds[msg.sender];
        uint256 stored = busd_token.balanceOf(address(this));

        // send reserved 4% of stakeLoanFee marketing_addr
        stakeLoanFee = stakeLoanFee * DM_busdriceTeam_percentage;
        stakeLoanBuybackFee = stakeLoanBuybackFee * DM_busdriceTeam_percentage;

        // if not enught BUSD to cover send FIRST on User what we can. Buyback after and refund later
        if (stakeLoanFee > stored) stakeLoanFee = stored - toBeSend;
        busd_token.transfer(marketing_addr, stakeLoanFee);
        mint(marketing_addr, stakeLoanBuybackFee);
        stakeLoanFee = 0;
        stakeLoanBuybackFee = 0;
        stakeLoanFee = 0;
        soldStakeFunds[msg.sender] = 0;

        // if not enught BUSD to cover send what we can. Buyback after and refund later
        stored = busd_token.balanceOf(address(this));
        if (toBeSend >= stored) {
            soldCredit[msg.sender] += (toBeSend - stored);
            toBeSend = stored;
        }

        busd_token.transfer(msg.sender, toBeSend);
    }

    /**
     * @dev returns a unique id for the lend by lopping through the user's lends and counting them
     * @param _address the lender user address
     */
    function clcLenderStakeId(address _address) public view returns (uint256) {
        uint256 stakeCount = 0;

        for (
            uint256 i = 0;
            mapLenderInfo[_address][i].lenderAddress == _address;
            i++
        ) {
            stakeCount += 1;
        }

        return stakeCount;
    }

    /* 
        after a loan's due date is reached there is no automatic way in contract to pay the lender and set the lend data as finished (for the sake of performance and gas)
        so either the lender user calls the "collectLendReturn" function or the loaner user automatically call the  "updateFinishedLoan" function by trying to collect their stake 
    */

    /**
     * @dev Lender requesting to collect their return amount from their finished lend
     * @param stakeId stake id
     */
    function collectLendReturn(uint256 stakeId, uint256 lenderStakeId)
        external
    {
        updateFinishedLoan(
            msg.sender,
            mapLenderInfo[msg.sender][stakeId].loanerAddress,
            lenderStakeId,
            stakeId
        );
    }

    /**
     * @dev Checks if the loan on loaner's stake is finished
     * @param lenderAddress lender address
     * @param loanerAddress loaner address
     * @param lenderStakeId lenderStakeId (different from stakeId)
     * @param stakeId stake id
     */
    function updateFinishedLoan(
        address lenderAddress,
        address loanerAddress,
        uint256 lenderStakeId,
        uint256 stakeId
    ) internal nonReentrant {
        _updateDaily();

        require(
            mapMemberStake[loanerAddress][stakeId].stake_hasLoan == true,
            "Target stake does not have an active loan on it"
        );
        require(
            currentDay >=
                mapRequestingLoans[loanerAddress][stakeId].lend_endDay,
            "Due date not yet reached"
        );
        require(
            mapLenderInfo[lenderAddress][lenderStakeId].loanIsPaid == false
        );
        require(mapRequestingLoans[loanerAddress][stakeId].loanIsPaid == false);
        require(mapRequestingLoans[loanerAddress][stakeId].hasLoan == true);

        mapMemberStake[loanerAddress][stakeId].stake_hasLoan = false;
        mapLenderInfo[lenderAddress][lenderStakeId].loanIsPaid = true;
        mapRequestingLoans[loanerAddress][stakeId].hasLoan = false;
        mapRequestingLoans[loanerAddress][stakeId].loanIsPaid = true;

        uint256 toBePaid = mapRequestingLoans[loanerAddress][stakeId]
            .returnAmount;
        lendersPaidAmount[lenderAddress] += toBePaid;

        mapRequestingLoans[loanerAddress][stakeId].returnAmount = 0;

        busd_token.transfer(lenderAddress, toBePaid);
    }
}