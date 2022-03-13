/**
 *Submitted for verification at BscScan.com on 2022-03-13
*/

// jes stake
//  blindbox_buyandopen_stake_magicstone

// blindbox&buyandsale&stake

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/utils/Strings.sol


// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

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
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
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

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

pragma solidity ^0.8.0;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


pragma solidity ^0.8.0;

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
    function balanceOf(address account) public view virtual override returns (uint256) {
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
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
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
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
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
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
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
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
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
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
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

// File: @openzeppelin/contracts/security/Pausable.sol


// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/utils/Address.sol


// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

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

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


pragma solidity ^0.8.0;

interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId) external view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}


pragma solidity ^0.8.0;

interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}



abstract contract ERC165 is IERC165 {

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }


    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }


    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }


    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }


    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }


    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }


    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }


    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }


    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }


    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }


    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

interface IERC1155Receiver is IERC165 {
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);

    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

interface IERC1155MetadataURI is IERC1155 {

    function uri(uint256 id) external view returns (string memory);
}

contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {
    using Address for address;

    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;

    constructor(string memory uri_) {
        _setURI(uri_);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function uri(uint256) public view virtual override returns (string memory) {
        return _uri;
    }


    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }


    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }


    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        // _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }
    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

        // _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }

    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }


    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);
    }

    function _burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);
    }

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}

// File: blindbox.sol

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BlindBox is Ownable, ERC1155, Pausable {
    string public name;
    string public symbol;
    string public baseURL;
    mapping (uint => address[] ) public WhiteList;
 
    mapping(address => bool) public minters;
    modifier onlyMinter() {
        require(minters[_msgSender()], "Mint: caller is not the minter");
        _;
    }
 
    struct Box {
        uint    id;
        string  name;
        uint256 mintNum;
        uint256 openNum;
        uint256 totalSupply;
        bool isNeedWhitelist;
    }
 
    mapping(uint => Box) public boxMap;

    function isWhiteList(uint _id, address _addr) public view returns(bool){
        for(uint i = 0; i < WhiteList[_id].length; i++){
            if(WhiteList[_id][i] == _addr){
                return true;
            }
        }
        return false;
    }
 
    constructor(string memory url_) ERC1155(url_) {
        name = "Slime Blind Box";
        symbol = "SBOX";
        baseURL = url_;
        minters[_msgSender()] = true;
    }
    function setWhitelist(uint _id, address[] memory _address ) public onlyOwner {
        WhiteList[_id] = _address;
    }

    function getWhitelist (uint _id) external view returns(address[] memory){
        return WhiteList[_id];
    }

    function newBox(uint boxID_, string memory name_, uint256 totalSupply_, bool _isNeedWhitelist ) public onlyOwner {
        require(boxID_ > 0 && boxMap[boxID_].id == 0, "box id invalid");
        boxMap[boxID_] = Box({
            id: boxID_,
            name: name_,
            mintNum: 0,
            openNum: 0,
            totalSupply: totalSupply_ ,
            isNeedWhitelist: _isNeedWhitelist
        });
    }
 
    function updateBox(uint boxID_, string memory name_, uint256 totalSupply_,bool _isNeedWhitelist) public onlyOwner {
        require(boxID_ > 0 && boxMap[boxID_].id == boxID_, "id invalid");
        require(totalSupply_ >= boxMap[boxID_].mintNum, "totalSupply err");
 
        boxMap[boxID_] = Box({
            id: boxID_,
            name: name_,
            mintNum: boxMap[boxID_].mintNum,
            openNum: boxMap[boxID_].openNum,
            totalSupply: totalSupply_,
            isNeedWhitelist: _isNeedWhitelist
        });
    }
 
    function mint(address to_, uint boxID_, uint num_) public onlyMinter whenNotPaused returns (bool) {
        require(num_ > 0, "mint number err");
        require(boxMap[boxID_].id != 0, "box id err");
        require(boxMap[boxID_].totalSupply >= boxMap[boxID_].mintNum + num_, "mint number is insufficient");
        if (boxMap[boxID_].isNeedWhitelist){
            require( isWhiteList( boxID_, to_), "Not in Whitelist");
        }
        boxMap[boxID_].mintNum += num_;
        _mint(to_, boxID_, num_, "");
        return true;
    }
 

 
    function burn(address from_, uint boxID_, uint256 num_) public whenNotPaused {
        require(_msgSender() == from_ || isApprovedForAll(from_, _msgSender()), "burn caller is not owner nor approved");
        boxMap[boxID_].openNum += num_;
        _burn(from_, boxID_, num_);
    }
 
 
    function setMinter(address newMinter, bool power) public onlyOwner {
        minters[newMinter] = power;
    }
 
    function boxURL(uint boxID_) public view returns (string memory) {
        require(boxMap[boxID_].id != 0, "box not exist");
        return string(abi.encodePacked(baseURL, boxID_));
    }
 
    function setURL(string memory newURL_) public onlyOwner {
        baseURL = newURL_;
    }
 
    function setPause(bool isPause) public onlyOwner {
        if (isPause) {
            _pause();
        } else {
            _unpause();
        }
    }
}
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}
interface IBlindBox {
    function setMinter(address newMinter, bool power) external;
    function newBox(uint256 boxID_, string memory name_, uint256 totalSupply_) external;
    function updateBox(uint256 boxID_, string memory name_, uint256 totalSupply_) external;
    function boxURL(uint256 boxID_) external view returns (string memory); 
    function setURL(string memory newURL_) external;
    function mint(address to_, uint256 boxID_, uint num_) external returns (bool);
    function burn(address from_, uint256 boxID_, uint256 num_) external;
    function balanceOf(address account, uint256 boxID_, uint256 num_) external;
}
library BirdsForestLibrary{
    struct BirdsForest {        
        uint Name;
        uint256 tokenId;
        uint Type;
    }
}
interface IBird {
    function mint(address minter, uint256 seed) external returns(uint256);
    function getItems(uint256 _itemId) external view returns (BirdsForestLibrary.BirdsForest memory);
}
contract BuyAndOpen is Ownable {
    using SafeMath for uint256;
    address public _box;
    address public _token;
    address public _erc721;
    address public _erc1155;
    address public _receiver;
    uint256 public _boxid;
    uint256 public _buyNeededAmount;
    uint256 public _probability;
    uint256 public _timelimitbefore;
    uint256 public _timelimitafter;
    
    

    uint256 public _maxbought;
    mapping(address => uint256)  public bought;

    function setProbability(uint256 probability)public onlyOwner {
        _probability = probability;
    }

    function getRandom() public view returns (uint256) {
        
        uint256 randomNumber = 
            uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender)));
        return randomNumber;
    }
    function setAddress(address receiver, address box, address token, address erc721, address erc1155) public onlyOwner {
        _box = box;
        _token = token;
        _erc721 = erc721;
        _erc1155 = erc1155;
        _receiver = receiver;
    }
    function setBoxInfo(uint256 boxid, uint256 buyNeededAmount) public onlyOwner {

        _boxid = boxid;
        _buyNeededAmount = buyNeededAmount;
    }
    function getProb() public view returns(uint256){
        return _probability;
    }



    function setLimit( uint256 timelimitbefore, uint256 timelimitafter, uint256 maxbought) public onlyOwner {
        _timelimitbefore = timelimitbefore;
        _timelimitafter = timelimitafter;
        _maxbought = maxbought;
    }
    function getInfo() external view returns(address,address,uint256,uint256,uint256,address,uint256,uint256,uint256){
        return(_erc721,_erc1155,_boxid,_maxbought,_buyNeededAmount,_token,_timelimitbefore,_timelimitafter,_probability);
    }
    constructor(uint256 probability, address receiver, address box, address token, address erc721, address erc1155, uint256 boxid, uint256 buyNeededAmount, uint256 timelimitbefore, uint256 timelimitafter,  uint256 maxbought){
        _box = box;
        _token = token;
        _erc721 = erc721;
        _erc1155 = erc1155;
        _boxid = boxid;
        _buyNeededAmount = buyNeededAmount;
        _timelimitbefore = timelimitbefore;
        _timelimitafter = timelimitafter;
        _maxbought = maxbought;
        _receiver = receiver;
        _probability = probability;

    }
    function buy( uint256 num) public {
        require(block.timestamp < _timelimitafter ,"Finished");
        require(_timelimitbefore < block.timestamp , "Have not started");
        IERC20(_token).transferFrom(msg.sender, _receiver, _buyNeededAmount);
        IBlindBox(_box).mint(msg.sender, _boxid, num);
        bought[msg.sender]+=num;
        require(bought[msg.sender]<= _maxbought, "amount limit");
    }
    function open() public {
        IBlindBox(_box).burn(msg.sender, _boxid, 1);
        require(msg.sender == tx.origin, "MUST_ORIDINARY_ACCOUNT");
        uint256 randomNumber = getRandom();
        
        if (_probability > randomNumber % 100){
            IBird(_erc721).mint(msg.sender,uint256(keccak256(abi.encodePacked(block.timestamp))));
        } else {
            IBlindBox(_erc1155).mint(msg.sender,1,1);
        }
        
    }
}


contract stake1NFT is Ownable{
    using SafeMath for uint256;
    address public _token;
    address public _erc721;
    uint public _name;
    uint public _type;
    uint256 public _reward;
    uint256 public _howlongtostake;
    uint256 public _whenstakestart;
    uint256 public _howmucherc20;
    bool public _iserc20;
    bool public _isMultiNFT;
    uint256 public _needNftAmount;
    
    
    mapping(address => uint256[]) public stakedtokenbyowner;
    mapping(address => mapping(uint256 => uint256)) public stakeinfo;
    

    function getInfo() public view returns(uint256,bool,bool,uint,uint,uint256,uint256,uint256,uint256) {
        return (_needNftAmount,_isMultiNFT,_iserc20,_name,_type,_reward,_howlongtostake,_whenstakestart,_howmucherc20);
    }

    function stake0(uint256 tokenid) public {
        uint name = IBird(_erc721).getItems(tokenid).Name;
        uint typee = IBird(_erc721).getItems(tokenid).Type;
        require(name == _name ,"not the token");
        require(typee == _type ,"not the token");
        require(block.timestamp>_whenstakestart,"have not start");
        IERC721(_erc721).transferFrom(msg.sender, address(this), tokenid);
        stakeinfo[msg.sender][tokenid] = block.timestamp.add(_howlongtostake);
        stakedtokenbyowner[msg.sender].push(tokenid);
        IBird(_erc721).mint(msg.sender, _reward);
    }


    function getDetails(address _addr) external view returns( uint256[] memory){
        return stakedtokenbyowner[_addr];
    }
    function unstake0(uint256 tokenid) public {
        require(block.timestamp > stakeinfo[msg.sender][tokenid], "time limit");
        require(stakeinfo[msg.sender][tokenid] != 0, "time limit");
        IERC721(_erc721).transferFrom(address(this), msg.sender,  tokenid);
        stakeinfo[msg.sender][tokenid] = 0;
    }

    function setAddress(address token, address erc721) public onlyOwner {

        _token = token;
        _erc721 = erc721;
    }
    function setItem(uint name, uint typee) public onlyOwner {

        _name = name;
        _type = typee;
    }
    function setReward(uint256 reward) public onlyOwner {

        _reward = reward;
    }
    function setOthers(uint256 howmucherc20, uint256 howlongtostake, uint256 whenstakestart,  bool iserc20) public onlyOwner {
        _iserc20 = iserc20;
        _howlongtostake = howlongtostake;
        _whenstakestart = whenstakestart;
        _howmucherc20 = howmucherc20;
    }


    constructor(uint256 nftNum, bool ismulti, uint256 howmucherc20, address token, address erc721, uint name, uint typee, uint256 reward, uint256 howlongtostake, uint256 whenstakestart,  bool iserc20){

        _token = token;
        _erc721 = erc721;
        _name = name;
        _type = typee;
        _reward = reward;
        _iserc20 = iserc20;
        _howlongtostake = howlongtostake;
        _whenstakestart = whenstakestart;
        _howmucherc20 = howmucherc20;
        _isMultiNFT = ismulti;
        _needNftAmount = nftNum;
    }
}

contract stake3NFT is Ownable{
    using SafeMath for uint256;
    address public _token;
    address public _erc721;
    uint public _name;
    uint public _type;
    uint256 public _reward;
    uint256 public _howlongtostake;
    uint256 public _whenstakestart;
    uint256 public _howmucherc20;
    bool public _iserc20;
    bool public _isMultiNFT;
    uint256 public _needNftAmount;
    
    
    mapping(address => mapping( uint256 => uint256[3] )) public stakedtokenbyowner;
    mapping(address => mapping(uint256 => uint256)) public stakeinfo;
    mapping(address => uint256) public stakeNum;
    

    function getInfo() public view returns(uint256,bool,bool,uint,uint,uint256,uint256,uint256,uint256) {
        return (_needNftAmount,_isMultiNFT,_iserc20,_name,_type,_reward,_howlongtostake,_whenstakestart,_howmucherc20);
    }

    function stake0(uint256 tokenid, uint256 _id, uint256 id_) public {
        uint name = IBird(_erc721).getItems(tokenid).Name;
        uint typee = IBird(_erc721).getItems(tokenid).Type;
        uint __name = IBird(_erc721).getItems(_id).Name;
        uint __typee = IBird(_erc721).getItems(_id).Type;
        uint name__ = IBird(_erc721).getItems(id_).Name;
        uint typee__ = IBird(_erc721).getItems(id_).Type;
        require(name == _name ,"not the token");
        require(typee == _type ,"not the token");
        require(__name == _name ,"not the token");
        require(__typee == _type ,"not the token");
        require(name__ == _name ,"not the token");
        require(typee__ == _type ,"not the token");
        require(block.timestamp>_whenstakestart,"have not start");
        IERC721(_erc721).transferFrom(msg.sender, address(this), tokenid);
        IERC721(_erc721).transferFrom(msg.sender, address(this), _id);
        IERC721(_erc721).transferFrom(msg.sender, address(this), id_);
        uint256[3] memory ids = [tokenid,_id,id_];
        stakeinfo[msg.sender][stakeNum[msg.sender]] = block.timestamp.add(_howlongtostake);
        stakedtokenbyowner[msg.sender][stakeNum[msg.sender]] = ids;
        stakeNum[msg.sender] += 1;
        IBird(_erc721).mint(msg.sender, _reward);
    }


    function getDetails(address _addr, uint256 _num) external view returns( uint256[3] memory){
        return stakedtokenbyowner[_addr][_num];
    }
    function unstake0(uint256 _id) public {
        require(block.timestamp > stakeinfo[msg.sender][_id], "time limit");
        require(stakeinfo[msg.sender][_id] != 0, "time limit");
        uint256[3] memory ids = stakedtokenbyowner[msg.sender][_id];
        
        IERC721(_erc721).transferFrom(address(this), msg.sender,  ids[0]);
        IERC721(_erc721).transferFrom(address(this), msg.sender,  ids[1]);
        IERC721(_erc721).transferFrom(address(this), msg.sender,  ids[2]);
        uint256 zero = 0;
        uint256[3] memory idss = [zero,zero,zero];
        stakedtokenbyowner[msg.sender][_id] = idss;
        stakeinfo[msg.sender][_id] = 0;
    }

    function setAddress(address token, address erc721) public onlyOwner {

        _token = token;
        _erc721 = erc721;
    }
    function setItem(uint name, uint typee) public onlyOwner {

        _name = name;
        _type = typee;
    }
    function setReward(uint256 reward) public onlyOwner {

        _reward = reward;
    }
    function setOthers(uint256 howmucherc20, uint256 howlongtostake, uint256 whenstakestart,  bool iserc20) public onlyOwner {
        _iserc20 = iserc20;
        _howlongtostake = howlongtostake;
        _whenstakestart = whenstakestart;
        _howmucherc20 = howmucherc20;
    }


    constructor(uint256 nftNum, bool ismul,uint256 howmucherc20, address token, address erc721, uint name, uint typee, uint256 reward, uint256 howlongtostake, uint256 whenstakestart,  bool iserc20){

        _token = token;
        _erc721 = erc721;
        _name = name;
        _type = typee;
        _reward = reward;
        _iserc20 = iserc20;
        _howlongtostake = howlongtostake;
        _whenstakestart = whenstakestart;
        _howmucherc20 = howmucherc20;
        _needNftAmount = nftNum;
        _isMultiNFT = ismul;
        
    }
}


contract stakeERC20 is Ownable{
    using SafeMath for uint256;
    address public _token;
    address public _erc721;
    uint public _name;
    uint public _type;
    uint256 public _reward;
    uint256 public _howlongtostake;
    uint256 public _whenstakestart;
    uint256 public _howmucherc20;
    bool public _iserc20;
    bool public _isMultiNFT;
    uint256 public _needNftAmount;
    
    
    mapping(address => uint256[]) public stakedtokenbyowner;
    mapping(address => mapping(uint256 => uint256)) public stakeinfo;
    

    function getInfo() public view returns(uint256,bool,bool,uint,uint,uint256,uint256,uint256,uint256) {
        return (_needNftAmount,_isMultiNFT,_iserc20,_name,_type,_reward,_howlongtostake,_whenstakestart,_howmucherc20);
    }

    function stake0() public {
        require(block.timestamp>_whenstakestart,"have not start");
        IERC20(_token).transferFrom(msg.sender, address(this), _howmucherc20);
        stakeinfo[msg.sender][stakedtokenbyowner[msg.sender].length] = block.timestamp.add(_howlongtostake);
        stakedtokenbyowner[msg.sender].push(_howmucherc20);
        IBird(_erc721).mint(msg.sender, _reward);
    }


    function getDetails(address _addr) external view returns( uint256[] memory){
        return stakedtokenbyowner[_addr];
    }
    function unstake0(uint256 _id) public {
        require(block.timestamp > stakeinfo[msg.sender][_id], "time limit");
        require(stakeinfo[msg.sender][_id] != 0, "time limit");
        IERC20(_token).transferFrom(address(this), msg.sender, stakedtokenbyowner[msg.sender][_id]);
        stakedtokenbyowner[msg.sender][_id] = 0;
        stakeinfo[msg.sender][_id] = 0;
    }

    function setAddress(address token, address erc721) public onlyOwner {

        _token = token;
        _erc721 = erc721;
    }
    function setItem(uint name, uint typee) public onlyOwner {

        _name = name;
        _type = typee;
    }
    function setReward(uint256 reward) public onlyOwner {

        _reward = reward;
    }
    function setOthers(uint256 howmucherc20, uint256 howlongtostake, uint256 whenstakestart,  bool iserc20) public onlyOwner {
        _iserc20 = iserc20;
        _howlongtostake = howlongtostake;
        _whenstakestart = whenstakestart;
        _howmucherc20 = howmucherc20;
    }


    constructor(uint256 nftNum, bool ismul,uint256 howmucherc20, address token, address erc721, uint name, uint typee, uint256 reward, uint256 howlongtostake, uint256 whenstakestart,  bool iserc20){

        _token = token;
        _erc721 = erc721;
        _name = name;
        _type = typee;
        _reward = reward;
        _iserc20 = iserc20;
        _howlongtostake = howlongtostake;
        _whenstakestart = whenstakestart;
        _howmucherc20 = howmucherc20;
        _needNftAmount = nftNum;
        _isMultiNFT = ismul;
    }
}




contract MagicStoneAndPotion is Ownable, ERC1155, Pausable {


    string public name;
    string public symbol;
    string public baseURL;
    uint[] public randomTable;
    uint256 accuracy;
    string public chances;
 
    mapping(address => bool) public minters;
    modifier onlyMinter() {
        require(minters[_msgSender()], "Mint: caller is not the minter");
        _;
    }
    function getRandom() public view returns (uint256) {
        uint256 randomNumber = 
            uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender)));
        return randomNumber;
    }
    
    struct items {
        uint    id;
        string  name;
        uint256 mintNum;
        uint256 openNum;
        uint256 totalSupply;
    }
 
    mapping(uint => items) public boxMap;
 
    constructor(string memory url_) ERC1155(url_) {
        name = "Slime Blind Box";
        symbol = "SBOX";
        baseURL = url_;
        minters[_msgSender()] = true;
        accuracy = 100 ;
    }
 
    function newBox(uint boxID_, string memory name_, uint256 totalSupply_) public onlyOwner {
        require(boxID_ > 0 && boxMap[boxID_].id == 0, "box id invalid");
        boxMap[boxID_] = items({
            id: boxID_,
            name: name_,
            mintNum: 0,
            openNum: 0,
            totalSupply: totalSupply_
        });
    }

    function setChances(string memory chance) public onlyOwner {
        chances = chance;
    }
 
    function updateBox(uint boxID_, string memory name_, uint256 totalSupply_) public onlyOwner {
        require(boxID_ > 0 && boxMap[boxID_].id == boxID_, "id invalid");
        require(totalSupply_ >= boxMap[boxID_].mintNum, "totalSupply err");
 
        boxMap[boxID_] = items({
            id: boxID_,
            name: name_,
            mintNum: boxMap[boxID_].mintNum,
            openNum: boxMap[boxID_].openNum,
            totalSupply: totalSupply_
        });
    }
 
    function mint(address to_  ) public onlyMinter whenNotPaused returns (bool) {
        
        uint256 seed = getRandom();
        uint256 boxID_ = randomTable[seed % accuracy];
        uint num_ =1;
        
        require(boxMap[boxID_].id != 0, "box id err");
        require(boxMap[boxID_].totalSupply >= boxMap[boxID_].mintNum + num_, "mint number is insufficient");
 
        boxMap[boxID_].mintNum += num_;
        _mint(to_, boxID_, num_, "");
        return true;
    }
 
 
    function burn(address from_, uint boxID_, uint256 num_) public whenNotPaused {
        require(_msgSender() == from_ || isApprovedForAll(from_, _msgSender()), "burn caller is not owner nor approved");
        boxMap[boxID_].openNum += num_;
        _burn(from_, boxID_, num_);
    }
 
 
    function setMinter(address newMinter, bool power) public onlyOwner {
        minters[newMinter] = power;
    }

    function setRandomTable(uint256[] memory values) public onlyOwner {
        randomTable = values;
    }

    function setAccuracy(uint256 values) public onlyOwner {
        accuracy = values;
    }
 
    function boxURL(uint boxID_) public view returns (string memory) {
        require(boxMap[boxID_].id != 0, "box not exist");
        return string(abi.encodePacked(baseURL, boxID_));
    }
 
    function setURL(string memory newURL_) public onlyOwner {
        baseURL = newURL_;
    }
 
    function setPause(bool isPause) public onlyOwner {
        if (isPause) {
            _pause();
        } else {
            _unpause();
        }
    }
}


pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

library Babylonian {

    function sqrt(uint256 x) internal pure returns (uint256) {
        if (x == 0) return 0;

        uint256 xx = x;
        uint256 r = 1;
        if (xx >= 0x100000000000000000000000000000000) {
            xx >>= 128;
            r <<= 64;
        }
        if (xx >= 0x10000000000000000) {
            xx >>= 64;
            r <<= 32;
        }
        if (xx >= 0x100000000) {
            xx >>= 32;
            r <<= 16;
        }
        if (xx >= 0x10000) {
            xx >>= 16;
            r <<= 8;
        }
        if (xx >= 0x100) {
            xx >>= 8;
            r <<= 4;
        }
        if (xx >= 0x10) {
            xx >>= 4;
            r <<= 2;
        }
        if (xx >= 0x8) {
            r <<= 1;
        }
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1; // Seven iterations should be enough
        uint256 r1 = x / r;
        return (r < r1 ? r : r1);
    }
}
contract Jeseco is Ownable{
    using SafeMath for uint256;

    address public lpAddress ;
    address  public tokenAddress ;
    address  public lpRewardPool ;
    address  public nodeRewardPool ;
    using Counters for Counters.Counter;
    Counters.Counter private _stakeItemIds;
    uint256  public totalStaked = 0;
    uint256[3] howLongTime = [691200,2592000,7776000];
    uint256  public beNodeAmount = 2000 * 10 ** 18;
    uint256  public beQualifiedAmount = 10000 * 10 ** 18;
    uint256  public nodeNumber ;
    uint256  public maxNodeNumber = 66 ;

    mapping(address => address) public myBoss;
    mapping(address => address[]) public mySon;
    mapping(address => uint256) public myRealSon;

    mapping(address =>bool) public isOverQualified;
    mapping(address =>bool) public isNode;
    mapping(address =>bool) public willBeNode;
    mapping(uint256 => StakeItem) public idToStake;
    mapping(address => uint256[]) public addressToStakeId;
    mapping(address => uint256) public addressToFinishedStakeAmount;
    mapping(address => uint256) public addressToFinishedStake;
    mapping(address => uint256) public addressTostakingAmount;
    mapping(address => bool) public isRegistered;
    mapping(address => address[]) public myNodeAddress;
    mapping(address => uint256) public myNodeAmount;
    mapping(address => uint256) public myNodeRuningAmount;
    // mapping(address => uint256) public myNodeFinishedAmount;
    
    


    struct StakeItem {
         uint256 amount;
         uint256 startTime;
         uint256 howLong;
         bool isFinished;
         uint256 stakeItemId;
         address node;
         bool isUnstaked;
         address owner;
         uint256 usdtAmount;
    }

    
    function getMySon() external view returns(uint256){
        return mySon[msg.sender].length;
    }

    function getMyRealSon() external view returns(uint256){
        return myRealSon[msg.sender];
    }


    // function getisOverQualified() external view returns(uint256){
    //     return totalStaked;
    // }
    // function getisNode() external view returns(uint256){
    //     return totalStaked;
    // }
    // function getwillBeNode() external view returns(uint256){
    //     return totalStaked;
    // }
    // function getaddressToFinishedStakeAmount() external view returns(uint256){
    //     return totalStaked;
    // }
    // function getaddressToFinishedStake() external view returns(uint256){
    //     return totalStaked;
    // }
    // function getmyBoss() external view returns(uint256){
    //     return totalStaked;
    // }
    // function getmySon() external view returns(uint256){
    //     return totalStaked;
    // }
    // function getmyRealSon() external view returns(uint256){
    //     return totalStaked;
    // }
    // function getmyNodeRuningAmount() external view returns(uint256){
    //     return totalStaked;
    // }
    // function getmyNodeAmount() external view returns(uint256){
    //     return totalStaked;
    // }





    


    function getwillBeNode() external view returns(bool){
        return willBeNode[msg.sender];
    }

    function getmyNodeAmount() external view returns(uint256){
        return myNodeAmount[msg.sender];
    }


    function getTotalStaked() external view returns(uint256){
        return totalStaked;
    }

    function getMyStaked() external view returns(uint256){
        return addressTostakingAmount[msg.sender];
    }

    function getTotalLpStakingAmount() public view returns(uint256){
        uint currentIndex = 0;
        uint itemCount = _stakeItemIds.current();
        uint256 totalStakeAmount = 0;
        for (uint i = 0; i < itemCount; i++){
            if(idToStake[ i + 1].isUnstaked == false){
                uint currentId =  i + 1;
                StakeItem storage currentItem = idToStake[currentId];
                totalStakeAmount += currentItem.amount;
                currentIndex += 1;
            }
        }
        return totalStakeAmount;
    }

    function getTotalNodeStakingAmount() public view returns(uint256){
        uint currentIndex = 0;
        uint itemCount = _stakeItemIds.current();
        uint256 totalStakeAmount = 0;
        for (uint i = 0; i < itemCount; i++){

            if( !idToStake[ i + 1].isUnstaked && isNode[idToStake[ i + 1].owner]){
                uint currentId =  i + 1;
                StakeItem storage currentItem = idToStake[currentId];
                totalStakeAmount += currentItem.amount;
                currentIndex += 1;
            }
        }
        return totalStakeAmount;
    }




    function divideLpReward(uint256 amount) public  {
        require(msg.sender == tokenAddress);
        uint currentIndex = 0;
        uint itemCount = _stakeItemIds.current();
        for (uint i = 0; i < itemCount; i++){
            if(idToStake[ i + 1].isUnstaked == false){
                uint currentId =  i + 1;
                StakeItem storage currentItem = idToStake[currentId];
                IERC20(tokenAddress).transferFrom(tokenAddress,currentItem.owner,amount.mul(currentItem.amount).div(getTotalLpStakingAmount()));
                currentIndex += 1;
            }
        }
        
    }

    function divideNodeReward(uint256 amount) public {
        require(msg.sender == tokenAddress);
        uint currentIndex = 0;
        uint itemCount = _stakeItemIds.current();

        for (uint i = 0; i < itemCount; i++){
             if( !idToStake[i+1].isUnstaked && isNode[idToStake[i+1].owner]){
                uint currentId =  i + 1;
                StakeItem storage currentItem = idToStake[currentId];
                IERC20(tokenAddress).transferFrom(tokenAddress,currentItem.owner,amount.mul(currentItem.amount).div(getTotalNodeStakingAmount()));
                currentIndex += 1;
            }
        }
        
    }

    function getMyStakingID() public view returns(uint256[] memory){
        uint currentIndex = 0;
        uint itemCount = _stakeItemIds.current();
        uint256[] memory myStakingID;
       
        for (uint i = 0; i < itemCount; i++){

            if( !idToStake[i+1].isUnstaked && idToStake[i+1].owner == msg.sender){
                uint currentId = i + 1;
                StakeItem storage currentItem = idToStake[currentId];
                myStakingID[currentIndex] = currentItem.stakeItemId;
                currentIndex += 1;
            }
        }
        return myStakingID;
    }


    // function fetchAllItems() public view returns (StakeItem[] memory) {
    //     uint currentIndex = 0;
    //     uint itemCount = _stakeItemIds.current();
    //     uint256 length1 = 0;

    //     for (uint i = 0; i < itemCount; i++) {
    //         if (idToStake[i + 1].owner == msg.sender) {
    //            length1 += 1;    
    //         }
    //     }

    //     StakeItem[] memory items = new StakeItem[](length1);
    //     for (uint i = 0; i < itemCount; i++) {
    //         if (idToStake[i + 1].owner == msg.sender) {
    //             uint currentId = i + 1;
    //             StakeItem storage currentItem = idToStake[currentId];
    //             items[currentIndex] = currentItem;
    //             currentIndex += 1;
    //         }
    //     }
    //     return items;
    // }


    function fetchMyAllItems() public view returns (StakeItem[] memory) {
        uint currentIndex = 0;
        uint itemCount = _stakeItemIds.current();
        uint256 length1 = 0;

        for (uint i = 0; i < itemCount; i++) {
            if (idToStake[i + 1].owner == msg.sender) {
               length1 += 1;    
            }
        }

        StakeItem[] memory items = new StakeItem[](length1);
        for (uint i = 0; i < itemCount; i++) {
            if (idToStake[i + 1].owner == msg.sender) {
                uint currentId = i + 1;
                StakeItem storage currentItem = idToStake[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }


    function fetchMySonAllItems() public view returns (StakeItem[] memory) {
        uint currentIndex = 0;
        uint itemCount = _stakeItemIds.current();
        address[] memory mySonAddresses = mySon[msg.sender];
        uint256 length1 = 0;

        for (uint i = 0; i < itemCount; i++) {
            for (uint j = 0; j < mySonAddresses.length; j++){
                if (idToStake[i + 1].owner == mySonAddresses[j]) {
                length1 += 1;
                }            
            }
        }
        
        StakeItem[] memory items = new StakeItem[](length1);
        for (uint i = 0; i < itemCount; i++) {
            for (uint j = 0; j < mySonAddresses.length; j++){
                if (idToStake[i + 1].owner == mySonAddresses[j]) {
                uint currentId = i + 1;
                StakeItem storage currentItem = idToStake[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
                }            
            }
        }
        return items;
    }


    function fetchMyNodeAllItems() public view returns (StakeItem[] memory) {
        uint currentIndex = 0;
        uint itemCount = _stakeItemIds.current();
        address[] memory myNodeAddresses = myNodeAddress[msg.sender];
        uint256 length1 = 0;


        for (uint i = 0; i < itemCount; i++) {
            for (uint j = 0; j < myNodeAddresses.length; j++){
                if (idToStake[i + 1].owner == myNodeAddresses[j]) {
                length1 += 1;
                }            
            }
        }

        StakeItem[] memory items = new StakeItem[](length1);
        for (uint i = 0; i < itemCount; i++) {
            for (uint j = 0; j < myNodeAddresses.length; j++){
                if (idToStake[i + 1].owner == myNodeAddresses[j]) {
                uint currentId = i + 1;
                StakeItem storage currentItem = idToStake[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
                }            
            }
        }
        return items;
    }












    function getMyAllStakeID() public view returns(uint256[] memory){
        return addressToStakeId[msg.sender];
    }
    
    function setAmount(uint256 node, uint256 qualified) public onlyOwner{
        beNodeAmount = node;
        beQualifiedAmount = qualified;
    }
   

    function setNode(address addr, bool _bol) public onlyOwner{
        if(_bol){
            isNode[addr] = true;
            nodeNumber +=1;
        
        }else{
            isNode[addr] = false;
            nodeNumber -=1;
        }
    }

    function setQualified(address addr) public onlyOwner{
        isOverQualified[addr] = true;
    }

    function beNode() public {
        require(nodeNumber <= maxNodeNumber, "node number is full");
        require(willBeNode[msg.sender] == true, "you have the right to be node");
        require(isNode[msg.sender] == false, "you have been node");
        
        isNode[msg.sender] = true;
        nodeNumber +=1;
        
    }


    function beQualified() public {
        bool ifAmount = myNodeAmount[msg.sender] >= beNodeAmount;
        bool ifHasQualified = isOverQualified[msg.sender] == false ;
        if(ifAmount&&ifHasQualified){
            isOverQualified[msg.sender] = true;

        }
    }

    function setAddress(address lptoken, address token, address lp, address node) public onlyOwner {
        lpAddress = lptoken;
        tokenAddress = token;
        lpRewardPool = lp;
        nodeRewardPool = node;
    }

    function setMaxNodeNum(uint256 num) public onlyOwner {
        maxNodeNumber = num;
    }
    


 
    function register(address _boss) public {
        require(isRegistered[_boss] == true,"your boss have been registered");
        require(isRegistered[msg.sender] == false, "already registered");
        myBoss[msg.sender] = _boss;
        mySon[_boss].push(msg.sender);
        isRegistered[msg.sender] = true;
    }

    function getRewardRate(address addr) public view returns(uint256) {
        if(myRealSon[addr] >= 8){
            return 5;
        } else {
            return 3;
        }
        
    }

    function getBNBPrice() public view returns(uint256) {
        // mainnet
        // uint256 bnbAmount = IERC20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c).balanceOf(0x16b9a82891338f9bA80E2D6970FddA79D1eb0daE);
        // uint256 usdtAmount = IERC20(0x55d398326f99059fF775485246999027B3197955).balanceOf(0x16b9a82891338f9bA80E2D6970FddA79D1eb0daE);
        
        // testnet
        uint256 bnbAmount = IERC20(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd).balanceOf(0xe3eBFc66885e9d2cE50A881D852d107Ed21583B2);
        uint256 usdtAmount = IERC20(0xba3bbC92C70BF973920CdE3DdAFab34F7ad44A15).balanceOf(0xe3eBFc66885e9d2cE50A881D852d107Ed21583B2);
        

        uint256 priceBNB = usdtAmount.div(bnbAmount);
        return priceBNB;
        
    }

    function getJesBnbPriceJesAmount(uint256 amount) public view returns(uint256) {
        // mainnet
        // uint256 bnbJesAmount = IERC20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c).balanceOf(lpAddress);

        // testnet
        uint256 bnbJesAmount = IERC20(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd).balanceOf(lpAddress);

        uint256 JesAmount = IERC20(tokenAddress).balanceOf(lpAddress);
        uint256 JesBnbPriceJesAmount = JesAmount.mul(amount).mul(amount).div(bnbJesAmount);
        uint256 sqrtPriceJesAmount = Babylonian.sqrt(JesBnbPriceJesAmount);
        return sqrtPriceJesAmount;
        
    }

    function getBnbJesPriceBnbAmount(uint256 amount) public view returns(uint256) {

        // mainnet
        // uint256 bnbJesAmount = IERC20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c).balanceOf(lpAddress);
        // testnet
        uint256 bnbJesAmount = IERC20(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd).balanceOf(lpAddress);

        uint256 JesAmount = IERC20(tokenAddress).balanceOf(lpAddress);
        uint256 BnbJesPriceBnbAmount = bnbJesAmount.mul(amount).mul(amount).div(JesAmount);
        uint256 sqrtPriceBnbAmount = Babylonian.sqrt(BnbJesPriceBnbAmount);
        return sqrtPriceBnbAmount;
        
    }

    function getUsdtAmount(uint256 amount) public view returns(uint256) {
        uint256 priceBNB = getBNBPrice();
        uint256 usdtAmount = amount.mul(priceBNB);
        return usdtAmount;
    }

    function stake(address addr, uint256 amount, uint256 howlong) public {

        require(isRegistered[msg.sender] == true, "not registered");
        require(isNode[addr], "not a node");
        _stakeItemIds.increment();
        uint256 itemId = _stakeItemIds.current();
        uint256 amountBnb = getBnbJesPriceBnbAmount(amount);
        // uint256 sqrtPrice = ad(amount);
        // uint256 amountBnb = amount.mul(sqrtPrice);
        uint256 usdtAmount = getUsdtAmount(amountBnb);
        myNodeAddress[addr].push(msg.sender);
        myNodeAmount[addr] += usdtAmount ;
        myNodeRuningAmount[addr] += usdtAmount;
        addressToStakeId[msg.sender].push(itemId);
        idToStake[itemId] = StakeItem(
            amount,
            block.timestamp,
            howLongTime[howlong],
            false,
            itemId,
            addr,
            false,
            msg.sender,
            usdtAmount
        );
        IERC20(lpAddress).transferFrom(msg.sender, address(this), amount);
        totalStaked += amount;
        addressTostakingAmount[msg.sender] += amount;
    }



    function unstake(uint256 _id) public {
        require(idToStake[_id].isUnstaked == false, "Has Unstaked");
        require(idToStake[_id].owner == msg.sender, "Not the owner");
        uint256 thisAmount = idToStake[_id].amount;
        uint256 sqrtPriceJesAmount = getJesBnbPriceJesAmount(thisAmount);
        uint256 rewardJes = sqrtPriceJesAmount.div(100);

        // uint256 rewardJes = idToStake[_id].amount.mul(sqrtPrice).div(100);

       

        addressTostakingAmount[msg.sender] -= idToStake[_id].amount;
        myNodeRuningAmount[msg.sender] -= idToStake[_id].usdtAmount;
        idToStake[_id].isUnstaked = true;
        totalStaked -= idToStake[_id].amount;
        uint256 rewardRate = getRewardRate(msg.sender);
        if(block.timestamp > idToStake[_id].startTime + idToStake[_id].howLong) {
            idToStake[_id].isFinished = true;
            addressToFinishedStakeAmount[msg.sender] += idToStake[_id].amount;
            addressToFinishedStake[msg.sender] += 1;
            myRealSon[myBoss[msg.sender]] += 1;
            IERC20(lpAddress).transfer(msg.sender, idToStake[_id].amount);


            if(idToStake[_id].howLong == 691200){
                if(block.timestamp < idToStake[_id].startTime + idToStake[_id].howLong + 86400){
                    IERC20(tokenAddress).transferFrom(lpRewardPool,msg.sender, rewardJes.mul(3));
                }
            
                IERC20(tokenAddress).transferFrom(lpRewardPool,myBoss[msg.sender], rewardJes.mul(3).mul(rewardRate).div(10));
                if(isOverQualified[msg.sender]){
                    IERC20(tokenAddress).transferFrom(nodeRewardPool, myBoss[msg.sender], rewardJes.mul(3).mul(2).div(10));
                }

            } else if(idToStake[_id].howLong == 2592000){
                if(idToStake[_id].usdtAmount>=beNodeAmount){
                    willBeNode[msg.sender] = true;
                }
                if(block.timestamp < idToStake[_id].startTime + idToStake[_id].howLong + 86400){
                    IERC20(tokenAddress).transferFrom(lpRewardPool, msg.sender, rewardJes.mul(15));
                }
                IERC20(tokenAddress).transferFrom(lpRewardPool, myBoss[msg.sender], rewardJes.mul(15).mul(rewardRate).div(10));
                if(isOverQualified[msg.sender]){
                    IERC20(tokenAddress).transferFrom(nodeRewardPool, myBoss[msg.sender], rewardJes.mul(15).mul(2).div(10));
                }

            } else if(idToStake[_id].howLong == 7776000){
                if(idToStake[_id].usdtAmount>=beNodeAmount){
                    willBeNode[msg.sender] = true;
                }
                if(block.timestamp < idToStake[_id].startTime + idToStake[_id].howLong + 86400){
                    IERC20(tokenAddress).transferFrom(lpRewardPool, msg.sender, rewardJes.mul(60));
                }
                IERC20(tokenAddress).transferFrom(lpRewardPool, myBoss[msg.sender], rewardJes.mul(60).mul(rewardRate).div(10));
                if(isOverQualified[msg.sender]){
                    IERC20(tokenAddress).transferFrom(nodeRewardPool, myBoss[msg.sender], rewardJes.mul(60).mul(2).div(10));
                }
            }
        } else {
            IERC20(lpAddress).transfer(msg.sender, idToStake[_id].amount.mul(92).div(100));
        }
    }

    


    constructor(){
        isNode[0x26c5DC1E138D5708d1bdB7f7eC7335b29609ae4a]=true;
        isRegistered[0x26c5DC1E138D5708d1bdB7f7eC7335b29609ae4a] = true;
        isNode[0x92698a25bda35282Fe89C967b777f8c67C7621a2]=true;
        isRegistered[0x7D63F3CceF611cC229F69B009da6AEFF82326c12] = true;
        isNode[0x543aCF094D937859d102f0Fcbf2E5Bb13906306a]=true;
        isNode[0x45cC2D06663fF32892bdC657Df889beF8495C94a]=true;
        isNode[0x020b86A6d99a8047Cb07a8B37c77e3bb50c26925]=true;
        isNode[0xCbcC095fdD879135A0F2F6013ca123324a7E6a74]=true;
        isNode[0x34EAFbb4d186A7c7a9E7Ee34c48Ef79f2a3D2302]=true;
        isNode[0xCbcC095fdD879135A0F2F6013ca123324a7E6a74]=true;
        isNode[0xb776Ee27b2889a681a477E6608e23d5C3644C7Af]=true;
        isNode[0xfCA0dEb3244CB7C07c01b334f4fa68A0686fd6A2]=true;

        isNode[0xd413bA10E93059B3f848F0B15f5C9Aa2b65AA6a3]=true;
        isNode[0x3168376Dd580B16E2B556e9b322289Fe53adDdfb]=true;
        isNode[0x55D5a99bc930a1b17d5D13d71738a21b5c18F415]=true;
        isNode[0x51531Ce15CaEAc26B2548C291ca5529B37375813]=true;
        isNode[0x749974f9fE50eb7c692eA84227C9417FEBB7F33F]=true;
        isNode[0xE8e2E0A861a7a68e0533dfcc62Dcd032B5A7b9aB]=true;
        isNode[0x357Fb5D612712aa0b307D74a1c24F3eC9570aBd9]=true;
        nodeNumber = 17;
    }
}


contract JesecoNodeRewardPool is Ownable{
    using SafeMath for uint256;
  
    address tokenAddress;
    address jesAddress;


    function setAddress( address token, address jes) public onlyOwner {
       
        jesAddress = jes;
        tokenAddress = token;
        uint256 total = IERC20(tokenAddress).totalSupply();
        IERC20(tokenAddress).approve(jesAddress, total);
    }
    
    function WithdrawalJes(address _adr, uint256 amount) public onlyOwner{
        if(amount == 0){
            uint256 balances = IERC20(tokenAddress).balanceOf(address(this));
            IERC20(tokenAddress).transfer(_adr, balances);

        }else{
            IERC20(tokenAddress).transfer(_adr, amount);
        }
    }

    constructor(address token, address jes){
        jesAddress = jes;
        tokenAddress = token;
        uint256 total = IERC20(tokenAddress).totalSupply();
        IERC20(tokenAddress).approve(jesAddress, total);
        
    }
}

contract JesecoLpRewardPool is Ownable{
    using SafeMath for uint256;


  
    address tokenAddress ;
    address jesAddress;


    function setAddress( address token, address jes) public onlyOwner {
       
        jesAddress = jes;
        tokenAddress = token;
        uint256 total = IERC20(tokenAddress).totalSupply();
        IERC20(tokenAddress).approve(jesAddress, total);
    }
    
    function WithdrawalJes(address _adr, uint256 amount) public onlyOwner{
        if(amount == 0){
            uint256 balances = IERC20(tokenAddress).balanceOf(address(this));
            IERC20(tokenAddress).transfer(_adr, balances);

        }else{
            IERC20(tokenAddress).transfer(_adr, amount);
        }
    }

    constructor(address token, address jes){
        jesAddress = jes;
        tokenAddress = token;
        uint256 total = IERC20(tokenAddress).totalSupply();
        IERC20(tokenAddress).approve(jesAddress, total);
        
    }
}

contract MultiSig is Ownable{
    using SafeMath for uint256;


    address public tokenAddress;
    address public address1 ;
    address public address2 ;
    address public address3 ;
    address public address4 ;
    address public address5 ;

    uint256 public isActive1;
    uint256 public isActive2;
    uint256 public isActive3;
    uint256 public isActive4;
    uint256 public isActive5;
    



    function setAddress(address addr1, address addr2, address addr3, address addr4, address addr5) public onlyOwner {
       
        address1 = addr1;
        address2 = addr2;
        address3 = addr3;
        address4 = addr4;
        address5 = addr5;
    }

    function setActive1(bool _bol) public  {
        require(msg.sender == address1, "Only address1 can set active");
        if(_bol){
            isActive1 = 1;
        }else{
            isActive1 = 0;
        }
    }
    function setActive2(bool _bol) public  {
        require(msg.sender == address2, "Only address2 can set active");
        if(_bol){
            isActive2 = 1;
        }else{
            isActive2 = 0;
        }
    }
    function setActive3(bool _bol) public  {
        require(msg.sender == address3, "Only address3 can set active");
        if(_bol){
            isActive3 = 1;
        }else{
            isActive3 = 0;
        }
    }
    function setActive4(bool _bol) public  {
        require(msg.sender == address4, "Only address4 can set active");
        if(_bol){
            isActive4 = 1;
        }else{
            isActive4 = 0;
        }
    }
    function setActive5(bool _bol) public  {
        require(msg.sender == address5, "Only address5 can set active");
        if(_bol){
            isActive5 = 1;
        }else{
            isActive5 = 0;
        }
    }
    
    
    function WithdrawalJes(address _adr, uint256 amount) public onlyOwner{
        uint256 sumOf = isActive1+isActive2+isActive3+isActive4+isActive5;
        require(sumOf>=3, "Not enough active nodes");
        
        if(amount == 0){
            uint256 balances = IERC20(tokenAddress).balanceOf(address(this));
            IERC20(tokenAddress).transfer(_adr, balances);

        }else{
            IERC20(tokenAddress).transfer(_adr, amount);
        }
    }

    constructor(address token, address addr1, address addr2, address addr3, address addr4,address addr5){
        tokenAddress = token;
        address1 = addr1;
        address2 = addr2;
        address3 = addr3;
        address4 = addr4;
        address5 = addr5;

        
    }
}



contract JesecoGameFiPool is Ownable{
    using SafeMath for uint256;


  
    address tokenAddress;
    address jesAddress;
    uint256 finishTime;


    function setAddress( address token, address jes) public onlyOwner {
       
        jesAddress = jes;
        tokenAddress = token;
        uint256 total = IERC20(tokenAddress).totalSupply();
        IERC20(tokenAddress).approve(jesAddress, total);
    }
    
    function WithdrawalJes(address _adr, uint256 amount) public onlyOwner{
        require(block.timestamp>finishTime, "GameFiPool can not be claimed yet");
        if(amount == 0){
            uint256 balances = IERC20(tokenAddress).balanceOf(address(this));
            IERC20(tokenAddress).transfer(_adr, balances);

        }else{
            IERC20(tokenAddress).transfer(_adr, amount);
        }
    }

    constructor(address token, address jes){
        jesAddress = jes;
        tokenAddress = token;
        uint256 total = IERC20(tokenAddress).totalSupply();
        IERC20(tokenAddress).approve(jesAddress, total);
        finishTime = block.timestamp + 3600*24*30*4;
        
    }
}


contract JesecoDAORewardPool is Ownable{
    using SafeMath for uint256;


  
    address tokenAddress ;
    address jesAddress;


    function setAddress( address token, address jes) public onlyOwner {
       
        jesAddress = jes;
        tokenAddress = token;
        uint256 total = IERC20(tokenAddress).totalSupply();
        IERC20(tokenAddress).approve(jesAddress, total);
    }
    
    function WithdrawalJes(address _adr, uint256 amount) public onlyOwner{
        if(amount == 0){
            uint256 balances = IERC20(tokenAddress).balanceOf(address(this));
            IERC20(tokenAddress).transfer(_adr, balances);

        }else{
            IERC20(tokenAddress).transfer(_adr, amount);
        }
    }

    constructor(address token, address jes){
        jesAddress = jes;
        tokenAddress = token;
        uint256 total = IERC20(tokenAddress).totalSupply();
        IERC20(tokenAddress).approve(jesAddress, total);
        
    }
}


contract JesecoBaseLp is Ownable{
    using SafeMath for uint256;


  
    address tokenAddress ;
    address jesAddress;


    function setAddress( address token, address jes) public onlyOwner {
       
        jesAddress = jes;
        tokenAddress = token;
        uint256 total = IERC20(tokenAddress).totalSupply();
        IERC20(tokenAddress).approve(jesAddress, total);
    }
    
    function WithdrawalJes(address _adr, uint256 amount) public onlyOwner{
        if(amount == 0){
            uint256 balances = IERC20(tokenAddress).balanceOf(address(this));
            IERC20(tokenAddress).transfer(_adr, balances);

        }else{
            IERC20(tokenAddress).transfer(_adr, amount);
        }
    }

    constructor(address token, address jes){
        jesAddress = jes;
        tokenAddress = token;
        uint256 total = IERC20(tokenAddress).totalSupply();
        IERC20(tokenAddress).approve(jesAddress, total);
        
    }
}