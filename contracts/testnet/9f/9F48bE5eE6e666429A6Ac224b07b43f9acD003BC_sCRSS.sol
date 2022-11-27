// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

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
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
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
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

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
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
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
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
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
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
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
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
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

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IsCRSS is IERC20 {
    function enter(uint256 _amount) external;

    function leave(uint256 _amount) external;

    function enterFor(uint256 _amount, address _to) external;

    function killswitch() external;

    function setCompoundingEnabled(bool _enabled) external;

    function setMaxTxAndWalletBPS(uint256 _pid, uint256 bps) external;

    function rescueToken(address _token, uint256 _amount) external;

    function rescueETH(uint256 _amount) external;

    function excludeFromDividends(address account, bool excluded) external;

    function upgradeDividend(address payable newDividendTracker) external;

    function impactFeeStatus(bool _value) external;

    function CRSStoSCRSS(uint256 _crssAmount, bool _impactFeeOn)
        external
        view
        returns (
            uint256 crssAmount,
            uint256 swapFee,
            uint256 impactFee
        );

    function sCRSStoCRSS(uint256 _sCrssAmount, bool _impactFeeOn)
        external
        view
        returns (
            uint256 crssAmount,
            uint256 swapFee,
            uint256 impactFee
        );

    event TradingHalted(uint256 timestamp);
    event TradingResumed(uint256 timestamp);
}

interface IControlCenter {
    function getAddress(uint256 _pid) external view returns (address);
}

contract sCRSS is Ownable, IsCRSS {
    IERC20 public crssToken;
    DividendTracker public dividendTracker;

    string private _name = "sCRSS Token";
    string private _symbol = "sCRSS";
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public _owner; //control center
    bool public priceImpactFeeIsOn;
    bool public compoundingEnabled = true;
    bool public tradingHalted;

    uint256[] public txAndWalletBPS; // 0 for max tx amount, 1 for max wallet amount

    mapping(address => bool) private _isExcludedFromFees;

    event SendDividends(uint256 tokensSwapped, uint256 amount);
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event CompoundingEnabled(bool enabled);
    event DividendTrackerUpdated(address newAddress);

    constructor(IERC20 _crssToken) {
        _transferOwnership(_msgSender());
        crssToken = _crssToken;
        dividendTracker = new DividendTracker(
            _crssToken,
            IsCRSS(address(this))
        );
        dividendTracker.excludeFromDividends(address(dividendTracker), true);
        dividendTracker.excludeFromDividends(address(this), true);
        dividendTracker.excludeFromDividends(owner(), true);

        whitelistContract(owner(), true);
        whitelistContract(address(this), true);
        whitelistContract(address(dividendTracker), true);
        txAndWalletBPS.push(0);
        txAndWalletBPS.push(0);
        setMaxTxAndWalletBPS(0, 100);
        setMaxTxAndWalletBPS(0, 100);

        _mint(owner(), 1000000000 * (10**18));
    }

    receive() external payable {}

    // Enter staking. Pay some CRSS. Earn some shares.
    // Locks CRSS and mints sCRSS
    function enter(uint256 _amount) public override {
        // Gets the amount of CRSS locked in the contract
        uint256 totalCrss = crssToken.balanceOf(address(this));
        // Gets the amount of sCRSS in existence
        uint256 totalShares = totalSupply();
        // Send CRSS to the contract
        //in the frontend we should add approve functionality which gets triggered if(allowance(msg.sender, address(this)) < type(uint).max), this way users will only need to approve once,
        //since there will be no way for the contract to abuse approved user funds, we can safely make them approve max amount to save gas without security concerns

        crssToken.transferFrom(msg.sender, address(this), _amount);

        // If no sCRSS exists, mint it 1:1 to the amount put in
        if (totalShares == 0 || totalCrss == 0) {
            _mint(msg.sender, _amount);
        }
        // Calculate and mint the amount of sCRSS the CRSS is worth. The ratio will change overtime, as sCRSS is burned/minted and CRSS deposited + gained from fees / withdrawn.
        else {
            //0.25% CRSS swap fee, all earnings go to sCRSS dividends
            uint256 swapFee = (_amount * 250) / 10000;
            uint256 feeAdjustedAmount = _amount - swapFee;
            //initial rate
            uint256 amount0 = (feeAdjustedAmount * totalShares) / totalCrss;
            if (priceImpactFeeIsOn) {
                //rate after swap
                uint256 amount1 = (feeAdjustedAmount *
                    (totalShares - amount0)) / (totalCrss + amount0);
                //anti whale protection
                uint256 midRate = (amount0 + amount1) / 2;

                //mints medium rate amount between before and after swap, this accounts for price impact, difference sent to IFReceiver

                _mint(IControlCenter(_owner).getAddress(4), amount0 - midRate);
                amount0 = midRate;
            }
            _mint(msg.sender, amount0);
            crssToken.transfer(address(dividendTracker), swapFee);
        }
    }

    // Leave staking. Claim back your CRSS.
    // Unlocks the staked + gained CRSS and burns sCRSS
    function leave(uint256 _amount) public override {
        // Gets the amount of CRSS locked in the contract
        uint256 totalCrss = crssToken.balanceOf(address(this));
        // Gets the amount of sCRSS in existence
        uint256 totalShares = totalSupply();
        _burn(msg.sender, _amount);
        //initial rate
        uint256 amountCrss0 = (_amount * totalCrss) / totalShares;
        /////////////////////// require(amountCrss0 < (totalCrss * supplyGuardPercentage) / 10000);
        uint256 swapFee = (amountCrss0 * 250) / 10000;
        if (priceImpactFeeIsOn) {
            //rate after swap, amountCrss1 < amountCrss0
            uint256 amountCrss1 = (_amount * (totalCrss - amountCrss0)) /
                (totalShares + _amount);
            //anti whale protection
            uint256 midRate = (amountCrss0 + amountCrss1) / 2;
            uint256 coefficient = (midRate * 10**18) / amountCrss0;
            uint256 impactAdjusted = (_amount * coefficient) / 10**18;
            _mint(
                IControlCenter(_owner).getAddress(4),
                _amount - impactAdjusted
            );
            //initial rate
            uint256 adjustedCrss0 = (impactAdjusted * totalCrss) / totalShares;
            //rate after swap, amount1 < amount0
            uint256 adjustedCrss1 = (impactAdjusted *
                (totalCrss - adjustedCrss0)) / (totalShares + impactAdjusted);
            amountCrss0 = (adjustedCrss0 + adjustedCrss1) / 2;
            //0.25% CRSS swap fee, all earnings go to sCRSS dividends
            swapFee = (amountCrss0 * 250) / 10000;
        }
        crssToken.transfer(address(dividendTracker), swapFee);
        crssToken.transfer(msg.sender, amountCrss0 - swapFee);
    }

    function enterFor(uint256 _amount, address _to) public override {
        // Gets the amount of CRSS locked in the contract
        uint256 totalCrss = crssToken.balanceOf(address(this));
        // Gets the amount of sCRSS in existence
        uint256 totalShares = totalSupply();
        // Send CRSS to the contract
        //in the frontend we should add approve functionality which gets triggered if(allowance(msg.sender, address(this)) < type(uint).max), this way users will only need to approve once,
        //since there will be no way for the contract to abuse approved user funds, we can safely make them approve max amount to save gas without security concerns

        crssToken.transferFrom(msg.sender, address(this), _amount);

        // If no sCRSS exists, mint it 1:1 to the amount put in
        if (totalShares == 0 || totalCrss == 0) {
            _mint(_to, _amount);
        }
        // Calculate and mint the amount of sCRSS the CRSS is worth. The ratio will change overtime, as sCRSS is burned/minted and CRSS deposited + gained from fees / withdrawn.
        else {
            //0.25% CRSS swap fee, all earnings go to sCRSS dividends
            uint256 swapFee = (_amount * 250) / 10000;
            uint256 feeAdjustedAmount = _amount - swapFee;
            //initial rate
            uint256 amount0 = (feeAdjustedAmount * totalShares) / totalCrss;
            if (priceImpactFeeIsOn) {
                //rate after swap
                uint256 amount1 = (feeAdjustedAmount *
                    (totalShares - amount0)) / (totalCrss + amount0);
                //anti whale protection
                uint256 midRate = (amount0 + amount1) / 2;

                //mints medium rate amount between before and after swap, this accounts for price impact, difference sent to IFReceiver

                _mint(IControlCenter(_owner).getAddress(4), amount0 - midRate);
                amount0 = midRate;
            }
            _mint(_to, amount0);
            crssToken.transfer(address(dividendTracker), swapFee);
        }
    }

    function killswitch() external override {
        require(msg.sender == _owner, "sCRSS:Only control center");
        bool isHalted = tradingHalted;
        if (isHalted == false) {
            isHalted = true;
            emit TradingHalted(block.timestamp);
        } else {
            isHalted = false;
            emit TradingResumed(block.timestamp);
        }
    }

    function impactFeeStatus(bool _value) external override onlyOwner {
        require(_value != priceImpactFeeIsOn, "sCRSS:Already set value");
        priceImpactFeeIsOn = _value;
    }

    function whitelistContract(address _address, bool _value) public {
        require(
            msg.sender == owner() || msg.sender == address(this),
            "sCRSS:Only owner and contract"
        );
        require(
            _isExcludedFromFees[_address] != _value,
            "sCRSS:Already set value"
        );
        _isExcludedFromFees[_address] = _value;
    }

    function sCRSStoCRSS(uint256 _sCrssAmount, bool _impactFeeOn)
        public
        view
        override
        returns (
            uint256 crssAmount,
            uint256 swapFee,
            uint256 impactFee
        )
    {
        uint256 totalCrss = crssToken.balanceOf(address(this));
        // Gets the amount of sCRSS in existence
        uint256 totalShares = totalSupply();
        //initial rate
        uint256 amountCrss0 = (_sCrssAmount * totalCrss) / totalShares;
        swapFee = (amountCrss0 * 250) / 10000;
        impactFee = 0;
        crssAmount = amountCrss0 - swapFee;
        if (_impactFeeOn) {
            //rate after swap, amountCrss1 < amountCrss0
            uint256 amountCrss1 = (_sCrssAmount * (totalCrss - amountCrss0)) /
                (totalShares + _sCrssAmount);
            //anti whale protection
            uint256 midRate = (amountCrss0 + amountCrss1) / 2;
            uint256 coefficient = (midRate * 10**18) / amountCrss0;
            uint256 impactAdjusted = (_sCrssAmount * coefficient) / 10**18;
            impactFee = _sCrssAmount - impactAdjusted;
            //initial rate
            uint256 adjustedCrss0 = (impactAdjusted * totalCrss) / totalShares;
            //rate after swap, amount1 < amount0
            uint256 adjustedCrss1 = (impactAdjusted *
                (totalCrss - adjustedCrss0)) / (totalShares + impactAdjusted);
            amountCrss0 = (adjustedCrss0 + adjustedCrss1) / 2;
            //0.25% CRSS swap fee, all earnings go to sCRSS dividends
            swapFee = (amountCrss0 * 250) / 10000;
            crssAmount = amountCrss0 - swapFee;
        }
    }

    function CRSStoSCRSS(uint256 _crssAmount, bool _impactFeeOn)
        public
        view
        override
        returns (
            uint256 sCrssAmount,
            uint256 swapFee,
            uint256 impactFee
        )
    {
        // Gets the amount of CRSS locked in the contract
        uint256 totalCrss = crssToken.balanceOf(address(this));
        // Gets the amount of sCRSS in existence
        uint256 totalShares = totalSupply();

        // Calculate and mint the amount of sCRSS the CRSS is worth. The ratio will change overtime, as sCRSS is burned/minted and CRSS deposited + gained from fees / withdrawn
        //0.25% CRSS swap fee, all earnings go to sCRSS dividends
        swapFee = (_crssAmount * 250) / 10000;
        uint256 feeAdjustedAmount = _crssAmount - swapFee;
        //initial rate
        uint256 amount0 = (feeAdjustedAmount * totalShares) / totalCrss;
        impactFee = 0;
        if (_impactFeeOn) {
            //rate after swap
            uint256 amount1 = (feeAdjustedAmount * (totalShares - amount0)) /
                (totalCrss + amount0);
            //anti whale protection
            uint256 midRate = (amount0 + amount1) / 2;
            impactFee = amount0 - midRate;
            amount0 = midRate;
        }
        sCrssAmount = amount0;
    }

    function upgradeDividend(address payable newDividendTracker)
        external
        override
        onlyOwner
    {
        dividendTracker = DividendTracker(newDividendTracker);
        emit DividendTrackerUpdated(newDividendTracker);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue);
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        return true;
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount);
        _approve(sender, _msgSender(), currentAllowance - amount);
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(tradingHalted != true, "Not Open");

        require(sender != address(0));
        require(recipient != address(0));

        uint256 _maxTxAmount = (totalSupply() * txAndWalletBPS[0]) / 10000;
        uint256 _maxWallet = (totalSupply() * txAndWalletBPS[1]) / 10000;
        require(amount <= _maxTxAmount || _isExcludedFromFees[sender]);

        uint256 currentBalance = balanceOf(recipient);
        require(
            _isExcludedFromFees[recipient] ||
                (currentBalance + amount <= _maxWallet)
        );

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount);
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);

        dividendTracker.setBalance(payable(sender), balanceOf(sender));
        dividendTracker.setBalance(payable(recipient), balanceOf(recipient));
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0));
        require(spender != address(0));
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _mint(address account, uint256 amount) private {
        require(account != address(0));
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) private {
        require(account != address(0), "MFF: burn from the zero address");
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "MFF: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    function excludeFromDividends(address account, bool excluded)
        public
        override
        onlyOwner
    {
        dividendTracker.excludeFromDividends(account, excluded);
    }

    function isExcludedFromDividends(address account)
        public
        view
        returns (bool)
    {
        return dividendTracker.isExcludedFromDividends(account);
    }

    function claim() public {
        dividendTracker.processAccount(payable(_msgSender()));
    }

    function compound() public {
        require(compoundingEnabled);
        dividendTracker.compoundAccount(payable(_msgSender()));
    }

    function withdrawableDividendOf(address account)
        public
        view
        returns (uint256)
    {
        return dividendTracker.withdrawableDividendOf(account);
    }

    function withdrawnDividendOf(address account)
        public
        view
        returns (uint256)
    {
        return dividendTracker.withdrawnDividendOf(account);
    }

    function accumulativeDividendOf(address account)
        public
        view
        returns (uint256)
    {
        return dividendTracker.accumulativeDividendOf(account);
    }

    function getAccountInfo(address account)
        public
        view
        returns (
            address,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return dividendTracker.getAccountInfo(account);
    }

    function getLastClaimTime(address account) public view returns (uint256) {
        return dividendTracker.getLastClaimTime(account);
    }

    function setCompoundingEnabled(bool _enabled) external override onlyOwner {
        compoundingEnabled = _enabled;
        emit CompoundingEnabled(_enabled);
    }

    function setMaxTxAndWalletBPS(uint256 _pid, uint256 bps) public override {
        require(
            msg.sender == owner() || msg.sender == address(this),
            "sCRSS:Restricted access"
        );
        require(bps >= 20 && bps <= 10000);
        txAndWalletBPS[_pid] = bps;
    }

    //these rescue functions will allow the owner to extract any non CRSS/sCRSS tokens that might get stuck inside the contract over time
    //no security/centralization implications since the contract is designed to work with CRSS only
    function rescueToken(address _token, uint256 _amount)
        external
        override
        onlyOwner
    {
        require(
            _token != address(crssToken) && _token != address(this),
            "Can't rescue CRSS or sCRSS"
        );
        IERC20(_token).transfer(msg.sender, _amount);
    }

    function rescueETH(uint256 _amount) external override onlyOwner {
        payable(msg.sender).transfer(_amount);
    }

    function _add(uint256 a, uint256 b) private pure returns (uint256) {
        return a + b;
    }

    function _subtract(uint256 a, uint256 b) private pure returns (uint256) {
        return a - b;
    }
}

contract DividendTracker is Ownable, IERC20 {
    address UNISWAPROUTER;

    string private _name = "DDC_Dividend_Contract";
    string private _symbol = "DDC_Dividend_Contract";

    uint256 public lastProcessedIndex;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    uint256 private constant magnitude = 2**128;
    uint256 public immutable minTokenBalanceForDividends;
    uint256 private magnifiedDividendPerShare;
    uint256 public totalDividendsDistributed;
    uint256 public totalDividendsWithdrawn;

    IERC20 public crssToken;
    IsCRSS public sCrssToken;

    mapping(address => bool) public excludedFromDividends;
    mapping(address => int256) private magnifiedDividendCorrections;
    mapping(address => uint256) private withdrawnDividends;
    mapping(address => uint256) private lastClaimTimes;

    event DividendsDistributed(address indexed from, uint256 weiAmount);
    event DividendWithdrawn(address indexed to, uint256 weiAmount);
    event ExcludeFromDividends(address indexed account, bool excluded);
    event Claim(address indexed account, uint256 amount);
    event DividendsCompounded(
        address indexed account,
        uint256 amount,
        uint256 tokens
    );

    struct AccountInfo {
        address account;
        uint256 withdrawableDividends;
        uint256 totalDividends;
        uint256 lastClaimTime;
    }

    constructor(IERC20 _crssAddress, IsCRSS _sCrssAddress) {
        minTokenBalanceForDividends = 10000 * (10**18);
        crssToken = _crssAddress;
        sCrssToken = _sCrssAddress;
    }

    receive() external payable {
        //distributeDividends();
    }

    /*function distributeDividends() public payable {
        require(_totalSupply > 0);
        if (msg.value > 0) {
            magnifiedDividendPerShare =
                magnifiedDividendPerShare +
                ((msg.value * magnitude) / _totalSupply);
            emit DividendsDistributed(msg.sender, msg.value);
            totalDividendsDistributed += msg.value;
        }
    }*/

    function distributeTokenDividends(uint256 _amount) public payable {
        require(_totalSupply > 0);
        if (_amount > 0) {
            magnifiedDividendPerShare =
                magnifiedDividendPerShare +
                ((_amount * magnitude) / _totalSupply);
            uint256 totalCrssAmount = IERC20(crssToken).balanceOf(
                address(this)
            );
            //check to see if some CRSS tokens were sent in a way which bypasses this function, adjust dividend share value accordingly
            if (
                (totalCrssAmount * magnitude) / _totalSupply >
                magnifiedDividendPerShare
            ) {
                magnifiedDividendPerShare =
                    (totalCrssAmount * magnitude) /
                    _totalSupply;
            }
            totalDividendsDistributed += _amount;
            require(
                crssToken.transfer(address(this), _amount),
                "Transfer to dividend contract failed"
            );
            emit DividendsDistributed(msg.sender, _amount);
        }
    }

    function setBalance(address payable account, uint256 newBalance) external {
        require(
            msg.sender == owner() || msg.sender == address(sCrssToken),
            "sCRSS:Restricted access"
        );
        if (excludedFromDividends[account]) {
            return;
        }
        if (newBalance >= minTokenBalanceForDividends) {
            _setBalance(account, newBalance);
        } else {
            _setBalance(account, 0);
        }
    }

    function excludeFromDividends(address account, bool excluded)
        external
        onlyOwner
    {
        require(
            excludedFromDividends[account] != excluded,
            "Account already set to requested state"
        );
        excludedFromDividends[account] = excluded;
        if (excluded) {
            _setBalance(account, 0);
        } else {
            uint256 newBalance = crssToken.balanceOf(account);
            if (newBalance >= minTokenBalanceForDividends) {
                _setBalance(account, newBalance);
            } else {
                _setBalance(account, 0);
            }
        }
        emit ExcludeFromDividends(account, excluded);
    }

    function isExcludedFromDividends(address account)
        public
        view
        returns (bool)
    {
        return excludedFromDividends[account];
    }

    function manualSendDividend(uint256 amount, address holder)
        external
        onlyOwner
    {
        uint256 contractETHBalance = address(this).balance;
        payable(holder).transfer(amount > 0 ? amount : contractETHBalance);
    }

    function _setBalance(address account, uint256 newBalance) internal {
        uint256 currentBalance = _balances[account];
        if (newBalance > currentBalance) {
            uint256 addAmount = newBalance - currentBalance;
            _mint(account, addAmount);
        } else if (newBalance < currentBalance) {
            uint256 subAmount = currentBalance - newBalance;
            _burn(account, subAmount);
        }
    }

    function _mint(address account, uint256 amount) private {
        require(account != address(0), "Mint to the zero address");
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
        magnifiedDividendCorrections[account] =
            magnifiedDividendCorrections[account] -
            int256(magnifiedDividendPerShare * amount);
    }

    function _burn(address account, uint256 amount) private {
        require(account != address(0), "Burn from the zero address");
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "Burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
        magnifiedDividendCorrections[account] =
            magnifiedDividendCorrections[account] +
            int256(magnifiedDividendPerShare * amount);
    }

    function processAccount(address payable account) public returns (bool) {
        require(msg.sender == owner() || msg.sender == account, "Not allowed");
        uint256 amount = _withdrawDividendOfUser(account);
        if (amount > 0) {
            lastClaimTimes[account] = block.timestamp;
            emit Claim(account, amount);
            return true;
        }
        return false;
    }

    function _withdrawDividendOfUser(address payable account)
        private
        returns (uint256)
    {
        uint256 _withdrawableDividend = withdrawableDividendOf(account);
        if (_withdrawableDividend > 0) {
            withdrawnDividends[account] += _withdrawableDividend;
            require(_withdrawableDividend > 0, "Nothing to withdraw");
            withdrawnDividends[account] += _withdrawableDividend;
            totalDividendsWithdrawn += _withdrawableDividend;
            require(crssToken.transfer(account, _withdrawableDividend));
            emit DividendWithdrawn(account, _withdrawableDividend);
            return _withdrawableDividend;
        }
    }

    function compoundAccount(address payable account)
        public
        onlyOwner
        returns (bool)
    {
        (uint256 amount, uint256 tokens) = _compoundDividendOfUser(account);
        if (amount > 0) {
            lastClaimTimes[account] = block.timestamp;
            emit DividendsCompounded(account, amount, tokens);
            return true;
        }
        return false;
    }

    function _compoundDividendOfUser(address payable account)
        private
        returns (uint256, uint256)
    {
        uint256 _withdrawableDividend = withdrawableDividendOf(account);
        if (_withdrawableDividend > 0) {
            withdrawnDividends[account] += _withdrawableDividend;
            totalDividendsWithdrawn += _withdrawableDividend;
            emit DividendWithdrawn(account, _withdrawableDividend);
            uint256 initialBalance = sCrssToken.totalSupply();

            sCrssToken.enterFor(_withdrawableDividend, account);
            uint256 sCrssSentToUser = initialBalance - sCrssToken.totalSupply();
            return (_withdrawableDividend, sCrssSentToUser);
        }
        return (0, 0);
    }

    function withdrawableDividendOf(address account)
        public
        view
        returns (uint256)
    {
        return accumulativeDividendOf(account) - withdrawnDividends[account];
    }

    function withdrawnDividendOf(address account)
        public
        view
        returns (uint256)
    {
        return withdrawnDividends[account];
    }

    function accumulativeDividendOf(address account)
        public
        view
        returns (uint256)
    {
        int256 a = int256(magnifiedDividendPerShare * balanceOf(account));
        int256 b = magnifiedDividendCorrections[account]; // this is an explicit int256 (signed)
        return uint256(a + b) / magnitude;
    }

    function getAccountInfo(address account)
        public
        view
        returns (
            address,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        AccountInfo memory info;
        info.account = account;
        info.withdrawableDividends = withdrawableDividendOf(account);
        info.totalDividends = accumulativeDividendOf(account);
        info.lastClaimTime = lastClaimTimes[account];
        return (
            info.account,
            info.withdrawableDividends,
            info.totalDividends,
            info.lastClaimTime,
            totalDividendsWithdrawn
        );
    }

    function getLastClaimTime(address account) public view returns (uint256) {
        return lastClaimTimes[account];
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address, uint256) public pure override returns (bool) {
        revert("MFF_DividendTracker: method not implemented");
    }

    function allowance(address, address)
        public
        pure
        override
        returns (uint256)
    {
        revert("MFF_DividendTracker: method not implemented");
    }

    function approve(address, uint256) public pure override returns (bool) {
        revert("MFF_DividendTracker: method not implemented");
    }

    function transferFrom(
        address,
        address,
        uint256
    ) public pure override returns (bool) {
        revert("MFF_DividendTracker: method not implemented");
    }
}