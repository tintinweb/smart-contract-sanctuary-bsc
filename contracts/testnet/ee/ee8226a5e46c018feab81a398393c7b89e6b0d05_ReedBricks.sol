/**
 *Submitted for verification at BscScan.com on 2022-02-11
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length)
        internal
        pure
        returns (string memory)
    {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

interface IReedStake {
    function createRewards(address acount, uint256 tAmount) external;
    function deliver(uint256 tAmount) external;
    function getTotalAmountStaked() external view returns (uint256);
    function getTotalRewardsDistributed() external view returns (uint256);
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
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    
    address private _owner;
    address private _buybackOwner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    modifier onlyBuybackOwner() {
        require(
            _buybackOwner == _msgSender(),
            "Ownable: caller is not the buyback owner"
        );
        _;
    }

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        _buybackOwner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    // Allow contract ownership and access to contract onlyOwner functions
    // to be locked using ReedVilla with control gated by community vote.
    //
    // ReedBricks ($REED) stakers become voting members of the
    // decentralized autonomous organization (DAO) that controls access
    // to the token contract via the ReedBricks Ecosystem dApp ReedVilla
    function transferOwnership(address newOwner) external virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );

        _owner = newOwner;
    }

    function transferBuybackOwnership(address newOwner)
        external
        virtual
        onlyOwner
    {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );

        emit OwnershipTransferred(_buybackOwner, newOwner);
        _buybackOwner = newOwner;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function buybackOwner() public view returns (address) {
        return _buybackOwner;
    }
}

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

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

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
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
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
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
        require(paused(), "Pausable: not paused");
        _;
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

/**
 * @dev ERC20 token with pausable token transfers, minting and burning.
 *
 * Useful for scenarios such as preventing trades until the end of an evaluation
 * period, or having an emergency switch for freezing all token transfers in the
 * event of a large bug.
 */
abstract contract ERC20Pausable is ERC20, Pausable {
    /**
     * @dev See {ERC20-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - the contract must not be paused.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);
        require(!paused(), "ERC20Pausable: token transfer while paused");
    }
}

/**
 * @dev Collection of functions related to the address type
 */
library PairHelper {
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
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    // helper methods for discovering LP pair addresses
    bytes private constant token0Selector =
        abi.encodeWithSelector(IUniswapV2Pair.token0.selector);
    bytes private constant token1Selector =
        abi.encodeWithSelector(IUniswapV2Pair.token1.selector);

    function token0(address pair) internal view returns (address) {
        return token(pair, token0Selector);
    }

    function token1(address pair) internal view returns (address) {
        return token(pair, token1Selector);
    }

    function token(address pair, bytes memory selector)
        private
        view
        returns (address)
    {
        // Do not check if pair is not a contract to avoid warning in txn log
        if (!isContract(pair)) return address(0);

        (bool success, bytes memory data) = pair.staticcall(selector);

        if (success && data.length >= 32) {
            return abi.decode(data, (address));
        }

        return address(0);
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
        return _functionCallWithValue(target, data, 0, errorMessage);
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
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20Burnable is Context, ERC20, Ownable {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(
            currentAllowance >= amount,
            "ERC20: burn amount exceeds allowance"
        );
        unchecked {
            _approve(account, _msgSender(), currentAllowance - amount);
        }
        _burn(account, amount);
    }
}

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);
}

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    event Transfer(address indexed from, address indexed to, uint256 value);

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

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

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

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function nonces(address owner) external view returns (uint256);

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

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);
}

interface IUniswapV2Router01 {
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

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

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

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

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

contract ReedBricks is Context, Ownable, ERC20Burnable, ERC20Pausable {
    using SafeMath for uint256;
    using PairHelper for address;

    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.
    uint256 private constant _FALSE = 1;
    uint256 private constant _TRUE = 2;

    // Business Development Address (BDA)
    address payable public BDA;
    // Staking Address (STK)
    address payable public STK;

    // Treasury Wallet is a safe wallet for minting and burning
    // REED tokens to balance the economy of the assets
    // Minting can only be done to the TRS and burning are
    // done from the TRS too.
    address payable public TRS; // Treasury Address (TRS)

    address public routerAddress = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
    // 0xD99D1c33F9fC3444f8101754aBC46c52416550D1; // Pancakeswap router Testnet
    // 0x10ED43C718714eb63d5aA57B78B54704E256024E; // Pancakeswap router Mainnet

    uint8 private _decimals = 8;

    //Total Cap is 160 Billion REEDs
    uint256 private _cap = 160 * 10**9 * 10**_decimals;

    //Total Supply is 60 Billion REEDs
    uint256 private _maxSupply = 60 * 10**9 * 10**_decimals;

    //Maximum Allowed Transaction Ammount (0.5% of _maxSupply)
    uint256 public _maxTxAmount = 3 * 10**9 * 10**_decimals;

    // 100 Million REEDs are initially sent to the dEaD wallet
    address private dEaD = 0x000000000000000000000000000000000000dEaD;

    // All Fees are caped to 10% to protect holders
    // from possible future increase in fees
    mapping(address => bool) private _isExcludedFromFee;
    uint256 public developerFee = 5; // 0 - 10
    uint256 private _previousDeveloperFee = developerFee;

    uint256 public sellFeeMarkup = 0; // 0 - 10 of developerFee
    uint256 public buyFeeMarkup = 0; // 0 - 10 of developerFee

    mapping(address => bool) private _isReedBricksEcosystemContract;
    address[] public allEcosystemContracts;

    // Liquidity Fees
    uint256 public liquidityFee = 2;
    uint256 private _previousLiquidityFee = liquidityFee;

    uint256 private _inSwapAndLiquify;
    uint256 private _checkingTokens;

    uint256 public developerDivisor = 2;

    bool public enableSenderFee = false;
    uint256 public senderFee = 0;

    uint256 private nextBuybackAmount = 0;
    uint256 private buyBackTriggerVolume = 100 * 10**6 * 10**_decimals;
    uint256 private buyBackUpperLimit = 10 * 10**18; //10 BNB
    uint256 private buyBackTriggerTokenLimit = 1 * 10**6 * 10**_decimals;
    uint256 private buyBackMinAvailability = 1 * 10**18; //1 BNB

    uint256 private buyVolume = 0;
    uint256 private sellVolume = 0;
    uint256 public totalBuyVolume = 0;
    uint256 public totalSellVolume = 0;
    uint256 public totalVolume = 0;

    uint256 public _maxBuyTxAmount = _maxTxAmount;
    uint256 public _maxSellTxAmount = _maxTxAmount;
    uint256 public maxWalletToken = _maxSupply;
    uint256 public zapperLockAmount = 10000;

    //Maximum Token Sell to reach to activate Liquidity (17% of _maxTxAmount)
    uint256 private numTokensSellToAddToLiquidity = 50 * 10**6 * 10**_decimals;

    bool public buyBackEnabled = true;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    IReedStake stakeToken;

    // We add all administrative members + developers to this team //
    // Only members added here can vote for minting and burning of tokens //
    mapping(address => uint256) public _ReedAdministrativeTeam;

    // HERE ARE OUR CORE TEAM PROFILES//
    /** 1. Engr. Agu Chux [ CO-FOUNDER & CEO/DEVELOPER ] : */
    /** 2. Mr. Ugwu C.J [ CO-FOUNDER & CFO ] : */
    /** 3. Dr (Mrs). Obiageli A [ CO-FOUNDER & OPS ] : */
    /** 4. Mr. Anthony A [ CTO ] : */
    /** 5. Mr. Alexander L [ Developer ] : */
    // ============================== //

    modifier lockTheSwap() {
        require(_inSwapAndLiquify != _TRUE);
        _inSwapAndLiquify = _TRUE;
        _;
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _inSwapAndLiquify = _FALSE;
    }
    event SwapETHForTokens(uint256 amountIn, address[] path);
    event SwapTokensForETH(uint256 amountIn, address[] path);
    event SwapTokensForTokens(uint256 amountIn, address[] path);

    event BuyBackAndRewardStakers(uint256 amount);
    event StakingAddressUpdated(address prevAddress, address newAddress);

    event ReedBricksEcosystemContractAdded(address contractAddress);
    event ReedBricksEcosystemContractRemoved(address contractAddress);

    event RouterAddressUpdated(address prevAddress, address newAddress);
    event LiquidityFeeUpdated(uint256 prevValue, uint256 newValue);
    event DeveloperFeeUpdated(uint256 prevValue, uint256 newValue);
    event EnableSenderFeeUpdated(uint256 prevValue, uint256 newValue);

    event WalletsChanged(address bda, address stk, address trs);

    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    modifier onlyTreasury(address _to) {
        require(TRS == _to, "Ownable: receipient is not Treasury Account");
        _;
    }

    constructor(
        string memory name,
        string memory symbol,
        address payable _bda,
        address payable _stk,
        address payable _trs
    ) ERC20(name, symbol) {
        BDA = _bda;
        STK = _stk;
        TRS = _trs;

        // The values being non-zero value makes deployment a bit more expensive,
        // but in exchange the refund on every call to modifiers will be lower in
        // amount. Since refunds are capped to a percentage of the total
        // transaction's gas, it is best to keep them low in cases like this one, to
        // increase the likelihood of the full refund coming into effect.

        _checkingTokens = _FALSE;
        _inSwapAndLiquify = _FALSE;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(routerAddress);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;

        stakeToken = IReedStake(STK);
        _ReedBricksEcosystemContractAdd(STK);

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[BDA] = true;
        _isExcludedFromFee[STK] = true;
        _isExcludedFromFee[TRS] = true;

        super._mint(owner(), _maxSupply);
        uint256 _maxTreasury = _cap.sub(_maxSupply);
        super._mint(TRS, _maxTreasury);
    }

    // Function to receive ETH when msg.data is be empty
    // Receives ETH from uniswapV2Router when swapping

    receive() external payable {}

    // Fallback function to receive ETH when msg.data is not empty
    fallback() external payable {}

    //=================================================================================//
    // Other Functionalities//

    function changeWallets(
        address payable _bda,
        address payable _stk,
        address payable _trs
    ) external virtual onlyOwner {
        require(_bda != BDA, "REED: new BDA is the same address");
        require(_stk != STK, "REED: new BDA is the same address");
        require(_trs != TRS, "REED: new BDA is the same address");

        BDA = _bda;
        STK = _stk;
        TRS = _trs;

        emit WalletsChanged(_bda, _stk, _trs);
    }

    function setRouterAddress(address new_routerAddress) external onlyOwner {
        require(
            new_routerAddress != address(0),
            "routerAddress should not be the zero address"
        );

        address prevAddress = address(uniswapV2Router);
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            new_routerAddress
        );
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).getPair(
            address(this),
            _uniswapV2Router.WETH()
        );

        uniswapV2Router = _uniswapV2Router;
        emit RouterAddressUpdated(prevAddress, new_routerAddress);
    }

    function ReedBricksEcosystemContractAdd(address contractAddress)
        external
        onlyOwner
    {
        require(
            contractAddress != address(0),
            "contractAddress should not be the zero address"
        );
        require(
            contractAddress != address(this),
            "ReedBricks token should not be added as an Ecosystem contract"
        );
        require(
            !_isReedBricksEcosystemContract[contractAddress],
            "contractAddress is already included as an ReedBricks Ecosystem contract"
        );
        _ReedBricksEcosystemContractAdd(contractAddress);
    }

    function _ReedBricksEcosystemContractAdd(address contractAddress) private {
        if (_isReedBricksEcosystemContract[contractAddress]) return;

        _isReedBricksEcosystemContract[contractAddress] = true;
        allEcosystemContracts.push(contractAddress);

        emit ReedBricksEcosystemContractAdded(contractAddress);
        _excludeFromFee(contractAddress);
    }

    function ReedBricksEcosystemContractRemove(address contractAddress)
        external
        onlyOwner
    {
        require(
            _isReedBricksEcosystemContract[contractAddress],
            "contractAddress is not included as ReedBricks Ecosystem contract"
        );

        _isReedBricksEcosystemContract[contractAddress] = false;

        for (uint256 i = 0; i < allEcosystemContracts.length; i++) {
            if (allEcosystemContracts[i] == contractAddress) {
                allEcosystemContracts[i] = allEcosystemContracts[
                    allEcosystemContracts.length - 1
                ];
                allEcosystemContracts.pop();
                break;
            }
        }

        emit ReedBricksEcosystemContractRemoved(contractAddress);
        _includeInFee(contractAddress);
    }

    function setBusinessDevelopmentAddress(address _businessDevelopmentAddress)
        external
        onlyOwner
    {
        require(
            _businessDevelopmentAddress != address(0),
            "_businessDevelopmentAddress should not be the zero address"
        );
        BDA = payable(_businessDevelopmentAddress);
    }

    function excludeFromFee(address account) external onlyOwner {
        require(
            !_isExcludedFromFee[account],
            "Account is not excluded for fees"
        );
        _excludeFromFee(account);
    }

    function includeInFee(address account) external onlyOwner {
        require(
            _isExcludedFromFee[account],
            "Account is not included for fees"
        );
        _includeInFee(account);
    }

    function removeAllFee() private {
        if (developerFee == 0) return;
        _previousDeveloperFee = developerFee;
        developerFee = 0;
    }

    function restoreAllFee() private {
        developerFee = _previousDeveloperFee;
    }

    function buyBackTokens(uint256 amount)
        private
        lockTheSwap
        returns (uint256)
    {
        uint256 tokensReceived;
        if (amount > 0) {
            tokensReceived = swapETHForTokensNoFee(address(this), STK, amount);
        }
        return tokensReceived;
    }

    // Other Functionalities//
    //=================================================================================//

    function getTotalAmountStaked() external view returns (uint256) {
        return stakeToken.getTotalAmountStaked();
    }

    function getTotalRewardsDistributed() external view returns (uint256) {
        return stakeToken.getTotalRewardsDistributed();
    }

    function distributeStakingRewards(uint256 amount) private {
        if (amount > 0) {
            stakeToken.createRewards(address(this), amount);
            stakeToken.deliver(amount);
            emit BuyBackAndRewardStakers(amount);
        }
    }

    function setLiquidityFeePercent(uint256 liquidityFeeRate)
        external
        onlyOwner
    {
        require(
            liquidityFeeRate <= 10,
            "liquidityFeeRate should be less than 10%"
        );
        uint256 prevValue = liquidityFee;
        liquidityFee = liquidityFeeRate;
        emit LiquidityFeeUpdated(prevValue, liquidityFee);
    }

    function setDeveloperFeePercent(uint256 developerFeeRate)
        external
        onlyOwner
    {
        require(
            developerFeeRate <= 10,
            "developerFeeRate should be less than 10%"
        );
        uint256 prevValue = developerFee;
        developerFee = developerFeeRate;
        emit DeveloperFeeUpdated(prevValue, developerFee);
    }

    function setStakingAddress(address payable _stakingAddress)
        external
        onlyOwner
    {
        require(
            _stakingAddress != address(0),
            "_stakingAddress should not be to zero address"
        );
        address prevAddress = STK;
        STK = _stakingAddress;
        stakeToken = IReedStake(_stakingAddress);
        emit StakingAddressUpdated(prevAddress, _stakingAddress);
        _ReedBricksEcosystemContractAdd(_stakingAddress);
    }

    function setSenderFeePercent(uint256 _senderFee) external onlyOwner {
        require(_senderFee <= 5, "senderFee should be less than 5%");
        uint256 prevValue = senderFee;
        senderFee = _senderFee;
        emit EnableSenderFeeUpdated(prevValue, liquidityFee);
    }

    function setBuyBackEnabled(bool _enabled) public onlyBuybackOwner {
        buyBackEnabled = _enabled;
    }

    function setSenderFeeEnabled(bool _enabled) public onlyOwner {
        enableSenderFee = _enabled;
    }

    function _excludeFromFee(address account) private {
        _isExcludedFromFee[account] = true;
        //emit ExcludeFromFeeUpdated(account);
    }

    function _includeInFee(address account) private {
        _isExcludedFromFee[account] = false;
        //emit IncludeInFeeUpdated(account);
    }

    function transferBalance() external onlyOwner {
        _msgSender().transfer(address(this).balance);
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function cap() public view virtual returns (uint256) {
        return _cap;
    }

    function _mint(address account, uint256 amount) internal virtual override {
        require(ERC20.totalSupply() + amount <= _cap, "REED: cap exceeded");
        super._mint(account, amount);
    }

    // We mint to the treasury (TRS) account //
    // MINT must happen and can only happen only if all team member voted //
    function mint(address to, uint256 amount)
        public
        virtual
        onlyTreasury(to)
        onlyOwner
    {
        _mint(to, amount);
    }

    // We burn from the treasury (TRS) account //
    //Burn must happen and can only happen only if all team member voted //
    function burn(uint256 amount)
        public
        virtual
        override
        onlyOwner
    {
        require(amount > 0, "REED: nothing to burn, amount cannot be zero");
        uint256 trsAmount = balanceOf(TRS);
        require(amount <= trsAmount, "REED: Insufficient amount from TRS");
        super.burnFrom(TRS, amount);
    }

    function pause() public virtual onlyOwner {
        _pause();
    }

    function unpause() public virtual onlyOwner {
        _unpause();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override(ERC20, ERC20Pausable) {
        super._beforeTokenTransfer(from, to, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if (from != owner() && to != owner())
            require(
                amount <= _maxTxAmount,
                "Transfer amount exceeds the maxTxAmount."
            );

        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is uniswap pair.
        uint256 contractTokenBalance = balanceOf(address(this));
        if (contractTokenBalance >= _maxTxAmount) {
            contractTokenBalance = _maxTxAmount;
        }

        bool overMinTokenBalance = contractTokenBalance >=
            numTokensSellToAddToLiquidity;

        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            from != uniswapV2Pair &&
            swapAndLiquifyEnabled
        ) {
            contractTokenBalance = numTokensSellToAddToLiquidity;
            //add liquidity
            swapAndLiquify(contractTokenBalance);
        }
        //===============================================================//

        // Following block is for the contract to convert the tokens to ETH and do the buy back
        if (
            buyBackEnabled &&
            address(this).balance > buyBackMinAvailability &&
            buyVolume.add(sellVolume) > buyBackTriggerVolume
        ) {
            if (nextBuybackAmount > address(this).balance) {
                // Don't try to buyback more than is available.
                // For example some "ETH" balance may have been
                // temporally switched to stable coin in crypto-market
                // downturn using swapTokens, for switching back later
                nextBuybackAmount = address(this).balance;
            }
            if (nextBuybackAmount > 0) {
                uint256 tokensReceived = buyBackTokens(nextBuybackAmount);
                //Distribute the rewards to the staking pool
                distributeStakingRewards(tokensReceived);
                nextBuybackAmount = 0; //reset the next buyback amount
                buyVolume = 0; //reset the buy volume
                sellVolume = 0; // reset the sell volume
            }
        }
        // Following block is for the contract to convert the tokens to ETH and do the buy back

        bool takeFee = true;
        bool excludedAccount = _isExcludedFromFee[from] ||
            _isExcludedFromFee[to];

        if (uniswapV2Pair == from && !excludedAccount) {
            require(
                amount <= _maxBuyTxAmount,
                "Transfer amount exceeds the maxTxAmount."
            );
            uint256 contractBalanceRecepient = balanceOf(to);
            require(
                contractBalanceRecepient + amount <= maxWalletToken,
                "Exceeds maximum wallet token amount."
            );
        } else if (uniswapV2Pair == to && !excludedAccount) {
            require(
                amount <= _maxSellTxAmount,
                "Sell transfer amount exceeds the maxSellTransactionAmount."
            );
            checkForCoolDown(from, to);
            if (balanceOf(from).sub(amount) == 0) {
                /**
                Provide Protection from account Zappers
                Account Zappers are people who drain their
                wallet and abandom project and community 
                 */
                amount -= zapperLockAmount;
                require(amount > 0, "Trying to make maximum sales.");
            }
        }

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (excludedAccount) {
            takeFee = false;
        }

        if (!takeFee) removeAllFee();

        if (takeFee) {
            // Take fees from Receiver and send to Developer wallet //
            uint256 fees = amount.mul(developerFee).div(100);
            // After fee is taken - amount left to send //
            amount = amount.sub(fees);
            // Take fees here and send to Developer wallet //
            super._transfer(from, BDA, fees);

            // Check if 'enableSenderFee' is enabled and charge sender//
            if (enableSenderFee) {
                // After fee is taken - amount left to debit Sender //
                uint256 _senderfees = amount.mul(senderFee).div(10**2);
                super._transfer(from, BDA, _senderfees);
            }
            // =====================================================//
        }

        // Send the remaining balance (amount) to receipient (to) //
        super._transfer(from, to, amount);
        // ===========================================================================//
        if (!takeFee) restoreAllFee();
    }

    function transferToAddressETH(address payable recipient, uint256 amount)
        private
    {
        recipient.transfer(amount);
    }

    function withdrawAccidentallyStuckTokens(
        IERC20 token,
        address recipient,
        uint256 amount
    ) external onlyOwner {
        require(address(token) != address(this), "Token not allowed!");
        token.transfer(recipient, amount);
    }

    function withdrawAccidentallyStuckEth(
        address payable recipient,
        uint256 amount
    ) external onlyOwner {
        recipient.transfer(amount);
    }

    function manualBuyback(uint256 amount, uint256 numOfDecimals)
        external
        onlyBuybackOwner
    {
        require(amount > 0 && numOfDecimals >= 0, "Invalid Input");
        uint256 value = amount.mul(10**18).div(10**numOfDecimals);
        uint256 tokensReceived = swapETHForTokensNoFee(
            address(this),
            STK,
            value
        );
        //Distribute the rewards to the staking pool
        distributeStakingRewards(tokensReceived);
    }

    function swapETHForTokensNoFee(
        address tokenAddress,
        address toAddress,
        uint256 amount
    ) private returns (uint256) {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = tokenAddress;

        // make the swap
        uint256[] memory amounts = uniswapV2Router.swapExactETHForTokens{
            value: amount
        }(
            0, // accept any amount of Tokens
            path,
            toAddress, // The contract
            block.timestamp.add(300)
        );

        emit SwapETHForTokens(amount, path);
        return amounts[1];
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        // split the contract balance into halves
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    // Auto-LP(AMM) is persistently owned by the Treasury Wallet
    // Can be burned or sent to dEaD wallet address
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            TRS,
            block.timestamp
        );
    }

    //////////----COOL DOWN FUNCTION --- //////////
    mapping(address => uint256) private lastTxnTimeStamp;
    bool public cooldownEnabled = false;
    uint256 public sellCooldownperiod = 3600;

    event CoolDownPeriodUpdated(
        address indexed operator,
        uint256 newCoolDownPeriod
    );

    function enableCooldown(bool value) external onlyOwner {
        require(value != cooldownEnabled, "CooldownEnabled is already set.");
        cooldownEnabled = value;
    }

    function checkForCoolDown(address from, address to) public {
        if (cooldownEnabled && to == uniswapV2Pair) {
            uint256 coolDownTimestamp = lastTxnTimeStamp[from].add(
                sellCooldownperiod
            );
            require(
                coolDownTimestamp < block.timestamp,
                "Wait till one hour Cool Down Pd"
            );
            lastTxnTimeStamp[from] = block.timestamp;
        }
    }

    function setSellCooldownperiod(uint256 _seconds) external onlyOwner {
        sellCooldownperiod = _seconds;
    }

}