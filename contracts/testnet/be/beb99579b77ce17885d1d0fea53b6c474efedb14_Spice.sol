/**
 *Submitted for verification at BscScan.com on 2022-10-13
*/

// File: 2Spice.sol



pragma solidity 0.8.13;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
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
    function balanceOf(address account) public view virtual override returns (uint256) {
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
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
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
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
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
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
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
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
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
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

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
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
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
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

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
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
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

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */

interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result << 3) < value ? 1 : 0);
        }
    }
}

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

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


abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(account),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * May emit a {RoleGranted} event.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

contract Treasury is AccessControl {
    bytes32 public constant DEV_ROLE = keccak256("DEV_ROLE");
    address internal busd;
    event Log(string func, address sender, uint256 value, bytes data);

    constructor(address _busd) {
        busd = _busd;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    fallback() external payable {
        emit Log("fallback", msg.sender, msg.value, msg.data);
    }

    receive() external payable {
        emit Log("fallback", msg.sender, msg.value, "");
    }

    function transferTo(address rec, uint256 amount) public onlyRole(DEV_ROLE) {
        IERC20(busd).transfer(rec, amount);
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

interface IPancakeRouter01 {
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

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

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

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

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

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
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

contract SpiceLiquidityHandler is Ownable {
    ISpice spiceContract;
    address busd;
    address spice;
    address pairContract;
    IPancakeRouter02 router;

    uint256 SWAP_THRESHOLD = 5000000;

    constructor(
        address _spiceAddress,
        address _busd,
        address _router,
        address _pair
    ) {
        spiceContract = ISpice(_spiceAddress);
        spice = _spiceAddress;
        busd = _busd;
        router = IPancakeRouter02(_router);
        pairContract = _pair;
        IERC20(busd).approve(_router, type(uint256).max);
        IERC20(spice).approve(_router, type(uint256).max);
    }

    function swapAndEvolve() public {
        //divide our busd balance into two
        uint256 half = IERC20(busd).balanceOf(address(this)) / 2;
        uint256 initialBalance = IERC20(spice).balanceOf(address(this));
        if (half > 0 && (half * 2) > SWAP_THRESHOLD) {
            uint256 otherHalf = IERC20(busd).balanceOf(address(this)) - half;
            //swap half busd for spice
            _swapBusdForSpice(half, address(this));
            //pair the half

            uint256 newBalance = IERC20(spice).balanceOf(address(this)) -
                initialBalance;

            //add liquiditys
            if (newBalance > 0) {
                _addLiquidity(newBalance, newBalance);
            }
        }
    }

    function changeSwapTreshold(uint256 newSwapTreshold) external onlyOwner {
        require(newSwapTreshold > 1e18, "treshold must be higher");
        SWAP_THRESHOLD = newSwapTreshold;
    }

    function _swapBusdForSpice(uint256 tokenAmount, address receiver) private {
        uint256 deadline = block.timestamp;
        address[] memory cvxPath = new address[](2);
        cvxPath[0] = busd;
        cvxPath[1] = spice;
        router.swapExactTokensForTokens(
            tokenAmount,
            0,
            cvxPath,
            receiver,
            deadline
        );
    }

    //allows the contract to add liquidity
    function _addLiquidity(uint256 tokenAmount, uint256 busdAmount) private {
        router.addLiquidity(
            spice,
            busd,
            tokenAmount,
            busdAmount,
            0,
            0,
            spice,
            block.timestamp
        );
    }
}

abstract contract ERC20Burnable is Context, ERC20 {
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
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
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

interface ISpice {
    function addInitialLiquidity(uint256 tokenA, uint256 tokenB) external;
}

contract Presale is Ownable {
    //the presale functions to create new tokens

    address public SpiceAddress;
    address public busd;
    uint256 public presaleTimer;
    bool public presaleOpen = false;
    bool public presaleOver = false;
    bool public tokensSet = false;
    address presaleWithdrawWallet;
    uint256 public presalePrice = 1;

    constructor(address _withdrawWallet) {
        presaleWithdrawWallet = _withdrawWallet;
    }

    modifier checkPresaleOpen() {
        require(presaleOpen == true, "the presale has not yet open");
        _;
    }

    //sets the presale as open and sets timer
    function openPresale() external onlyOwner {
        require(presaleOpen == false, "presale is already open");
        presaleOpen = true;
        uint256 time = 1 weeks + block.timestamp;
        presaleTimer = time;
        emit PresaleOpened(time, msg.sender);
    }

    function setTokenAddresses(address _spiceAddress, address _busd)
        external
        onlyOwner
    {
        tokensSet = true;
        SpiceAddress = _spiceAddress;
        busd = _busd;
    }

    //presale function mints new tokens in exchange for busd

    function presale(uint256 busdAmount) external checkPresaleOpen {
        require(busdAmount > 0); //busd amount must be greater than zero
        require(block.timestamp <= presaleTimer, "presale has ended");
        uint256 spiceAmount = busdAmount;
        IERC20(busd).transferFrom(msg.sender, address(this), busdAmount);
        IERC20(SpiceAddress).transfer(msg.sender, spiceAmount);
    }

    //withdraw presale funds to presale wallet
    function openContractAndWithdrawPresale() public onlyOwner {
        require(presaleOpen == true, "presale is not yet open");
        require(block.timestamp > presaleTimer, "presale is not over yet");
        presaleOpen = false;
        presaleOver = true;
        uint256 busdBalance = IERC20(busd).balanceOf(address(this));
        uint256 amountToPCS = (60 * busdBalance) / 100;
        uint256 remainder = busdBalance - amountToPCS;
        IERC20(busd).transfer(SpiceAddress, amountToPCS);
        ISpice(SpiceAddress).addInitialLiquidity(amountToPCS, amountToPCS);
        IERC20(busd).transfer(presaleWithdrawWallet, remainder);
        emit PresaleWithdrawn(presaleWithdrawWallet, remainder);
    }

    event PresaleWithdrawn(address wallet, uint256 busdBalance);
    event PresaleOpened(uint256 time, address sender);
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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

contract GameReward is Ownable, ReentrancyGuard {
    bytes32 public constant CAN_MAKE_WITHDRAWAL =
        keccak256("CAN_MAKE_WITHDRAWAL");
    mapping(address => uint256) balances;
    mapping(address => bool) depositor;
    mapping(address => uint256) _withdrawLimit;
    mapping(address => bool) public admins;
    uint256 totalRewardsBalance;
    uint256 withdrawalFees = 15000000000000000;
    uint256 totalWithdrawFees;
    address spiceContract;

    event Deposit(
        uint256 tID,
        uint256 time,
        string email,
        address despositor,
        uint256 amount
    );
    event Withdraw(
        uint256 tID,
        uint256 time,
        string email,
        address withdrawer,
        uint256 amount,
        address to
    );
    uint256 dId;
    uint256 wId;

    IPancakeRouter02 router;
    address busd;

    constructor(
        address _spiceContract,
        address _router,
        address _busd
    ) {
        admins[msg.sender] = true;
        spiceContract = _spiceContract;
        router = IPancakeRouter02(_router);
        busd = _busd;

        IERC20(spiceContract).approve(_router, type(uint256).max);
        IERC20(busd).approve(_router, type(uint256).max);
    }

    modifier canWithdraw() {
        require(admins[msg.sender], "Action prohitibited");
        _;
    }

    function setNewAdmin(address _newAdmin) public onlyOwner {
        admins[_newAdmin] = true;
    }

    function revokeAdmin(address _admin) public onlyOwner {
        require(_admin != owner(), "default admin cannot be revoked");
        admins[_admin] = false;
    }

    function updateFees(uint256 newFees) public onlyOwner {
        withdrawalFees = newFees;
    }

    function deposit(uint256 _spice, string memory email) public nonReentrant {
        dId = dId + 1;
        uint256 newId = dId;
        uint256 transaction_id = uint256(
            keccak256(abi.encode(newId, block.timestamp))
        ) % 10;
        totalRewardsBalance += _spice;
        IERC20(spiceContract).transferFrom(msg.sender, address(this), _spice);
        depositor[msg.sender] = true;
        balances[msg.sender] += _spice;

        emit Deposit(
            transaction_id,
            block.timestamp,
            email,
            msg.sender,
            _spice
        );
    }

    function adminWithdrawFor(
        uint256 _gems,
        string memory email,
        address receiver
    ) public canWithdraw {
        address ownerAddress = owner();
        uint256 c_balance = IERC20(spiceContract).balanceOf(address(this));
        require(
            receiver != ownerAddress,
            "owner cannot withdraw fee funds from the contract"
        );
        require(_gems > withdrawalFees, "not enough to withdraw");
        require(c_balance >= _gems, "inadequate gem balance");
        wId = wId + 1;
        uint256 newId = wId;
        uint256 transaction_id = uint256(
            keccak256(abi.encode(newId, block.timestamp))
        ) % 10;

        //takes two percent of the withdrawal fees to boost the reward contract balance
        uint256 boostRewardBalancePerecent = (withdrawalFees * 2) / 100;

        totalRewardsBalance -= (_gems - boostRewardBalancePerecent);

        //amount to be sent to receiver
        uint256 totalAmount = _gems - withdrawalFees;

        //fees save as contract balance
        totalWithdrawFees += withdrawalFees - boostRewardBalancePerecent;

        IERC20(spiceContract).transfer(receiver, totalAmount);
        if (totalWithdrawFees >= withdrawalFees) {
            address ownerAddress = msg.sender;
            _swapFees(totalWithdrawFees, ownerAddress);
        }
        emit Withdraw(
            transaction_id,
            block.timestamp,
            email,
            msg.sender,
            _gems,
            receiver
        );
    }

    function _swapFees(uint256 tokenAmount, address receiver) private {
        require(admins[receiver], "You cannot withdraw fees for this address");
        address[] memory path = new address[](2);
        path[0] = spiceContract;
        path[1] = busd;

        address[] memory path2 = new address[](3);
        path2[0] = spiceContract;
        path2[1] = busd;
        path2[2] = router.WETH();

        uint256 spiceBalance = IERC20(spiceContract).balanceOf(address(this));
        if (spiceBalance > withdrawalFees) {
            router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                receiver,
                block.timestamp
            );
        }

        uint256 busdBalance = IERC20(busd).balanceOf(address(this));

        if (busdBalance > 0) {
            //set up for live deploys
            // router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            //     busdBalance,
            //     0,
            //     path2,
            //     receiver,
            //     block.timestamp
            // );
        }
    }
}

contract Dev is AccessControl {
    bytes32 public constant DEV_ROLE = keccak256("DEV_ROLE");
    address internal busd;
    event Log(string func, address sender, uint256 value, bytes data);

    constructor(address _busd) {
        busd = _busd;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    fallback() external payable {
        emit Log("fallback", msg.sender, msg.value, msg.data);
    }

    receive() external payable {
        emit Log("fallback", msg.sender, msg.value, "");
    }

    function transferTo(address rec, uint256 amount) public onlyRole(DEV_ROLE) {
        IERC20(busd).transfer(rec, amount);
    }
}

contract Charity is AccessControl {
    bytes32 public constant DEV_ROLE = keccak256("DEV_ROLE");
    address internal busd;
    event Log(string func, address sender, uint256 value, bytes data);

    constructor(address _busd) {
        busd = _busd;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    fallback() external payable {
        emit Log("fallback", msg.sender, msg.value, msg.data);
    }

    receive() external payable {
        emit Log("fallback", msg.sender, msg.value, "");
    }

    function transferTo(address rec, uint256 amount) public onlyRole(DEV_ROLE) {
        IERC20(busd).transfer(rec, amount);
    }
}

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        require(
            c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256),
            "mul: invalid with MIN_INT256"
        );
        require((b == 0) || (c / b == a), "mul: combi values invalid");
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256, "div: b == 1 or a == MIN_INT256");
        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require(
            (b >= 0 && c <= a) || (b < 0 && c > a),
            "sub: combi values invalid"
        );
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require(
            (b >= 0 && c >= a) || (b < 0 && c < a),
            "add: combi values invalid"
        );
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256, "abs: a equal MIN INT256");
        return a < 0 ? -a : a;
    }
}

interface IPancakeFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface InterfaceLP {
    function sync() external;
}

interface ILiquidityManager {
    function swapAndEvolve() external;
}

contract Spice is ERC20, ERC20Burnable, Ownable {
    using SafeMathInt for int256;
    using SafeMath for uint256;

    IPancakeRouter02 private router;

    address public busd;
    address public liquidityReceiver;
    address public pairBusd;

    address public devAndMarketingWallet;
    address public treasuryWallet;
    address public charityWallet;
    address public liqudityHandlerWallet;

    address presaleWithdrawWallet;

    mapping(address => uint256) private _balances;
    mapping(address => bool) _isFeeExempt;
    mapping(address => bool) marketPairs;
    mapping(address => mapping(address => uint256)) private _allowedFragments;
    address[] _markerPairs;
    address[] path = [busd, address(this)];

    uint256 private _totalSupply;

    uint256 initialSupply = 1000e18; //check for deploy var
    uint256 public presalePrice = 1;
    uint256 public presaleTimer;
    uint256 public feeCollectedSpice;
    uint256 feeCollectedBusd;
    uint256 stuckFees;
    uint256 SWAP_TRESHOLD = 50000000;

    // fees
    uint256 public totalBuyFee = 5;
    uint256 public totalSellFee = 10;
    uint256 buyLP = 3;
    uint256 buyTreasury = 2;

    uint256 sellDevMarketing = 2;
    uint256 sellLP = 3;
    uint256 sellTreasury = 3;
    uint256 sellCharity = 2;

    uint256 MaxPoolBurn = 10000e18;

    uint256 internalPoolBusdReserves;

    bool public presaleOpen = false;
    bool public presaleOver = false;
    bool swapEnabled = false;
    bool private inSwap;
    address presaleContract;

    modifier swapping() {
        require(inSwap == false, "ReentrancyGuard: reentrant call");
        inSwap = true;
        _;
        inSwap = false;
    }

    modifier isReadyForTrade() {
        require(presaleOver == true, "the presale has not yet ended");
        _;
    }

    constructor(
        address _busd,
        address _presaleContract,
        address _router,
        uint256 _presaleSupply
    )
        //busd address,
        ERC20("T2Spice", "TSpice")
        ERC20Burnable()
    {
        busd = _busd;
        router = IPancakeRouter02(_router);

        pairBusd = IPancakeFactory(router.factory()).createPair(
            address(this),
            busd
        );

        address routerAddress = _router;
        _markerPairs.push(pairBusd);
        marketPairs[pairBusd] = true;

        IERC20(busd).approve(routerAddress, type(uint256).max);
        IERC20(busd).approve(address(pairBusd), type(uint256).max);
        IERC20(busd).approve(address(this), type(uint256).max);

        _allowedFragments[address(this)][address(router)] = type(uint256).max;
        _allowedFragments[address(this)][address(this)] = type(uint256).max;
        _allowedFragments[address(this)][pairBusd] = type(uint256).max;

        _isFeeExempt[address(this)] = true;

        _isFeeExempt[msg.sender] = true;
        _isFeeExempt[_presaleContract] = true;

        presaleContract = _presaleContract;
        //test mints
        _mint(msg.sender, initialSupply);
        _mint(_presaleContract, initialSupply);
    }

    //Internal pool sell to function, takes fees in BUSD
    function sellToThis(uint256 spiceAmount) external {
        require(spiceAmount > 0);
        //gets the spice price
        uint256 spicePrice = fetchPCSPrice();
        uint256 busdAmountBeforeFees = (spiceAmount * spicePrice) / 1e18;
        uint256 IP_BUSD_Balance = IERC20(busd).balanceOf(address(this));
        require(
            busdAmountBeforeFees <= IP_BUSD_Balance,
            "insufficient liquidity in the internal pool"
        );
        //fees
        uint256 fee = (busdAmountBeforeFees * totalSellFee) / 100;
        feeCollectedBusd += fee;
        //amount after fees
        uint256 sellAmount = busdAmountBeforeFees - fee;

        //burns all spice sent to contract
        _balances[msg.sender] -= spiceAmount;
        _totalSupply -= spiceAmount;
        internalPoolBusdReserves -= busdAmountBeforeFees;

        ILPTransferFees(false, busdAmountBeforeFees);
        IERC20(busd).transfer(msg.sender, sellAmount);

        emit Transfer(msg.sender, address(0), spiceAmount);
    }

    //Internal pool buy from function, takes fees in BUSD
    function purchaseFromThis(uint256 busdAmount) external {
        require(busdAmount > 0);
        //fetch spice price
        uint256 spicePrice = fetchPCSPrice();
        // get fees
        uint256 fee = (busdAmount * totalBuyFee) / 100;
        feeCollectedBusd += fee;
        //busd received
        uint256 busdReceived = busdAmount - fee;
        //send busd yo contract with fees
        uint256 spiceAmount = (busdReceived * 1e18) / spicePrice;
        IERC20(busd).transferFrom(msg.sender, address(this), busdAmount);
        ILPTransferFees(true, busdAmount);
        //mint token to sender's balances
        _mint(msg.sender, spiceAmount);
        internalPoolBusdReserves += busdReceived;
    }

    //helper function that allows the contract to swap with PCS pool
    function _swapSpiceForBusd(uint256 tokenAmount, address receiver) private {
        uint256 deadline = block.timestamp + 1 minutes;
        address[] memory cvxPath = new address[](2);
        cvxPath[0] = address(this);
        cvxPath[1] = address(busd);
        router.swapExactTokensForTokens(
            tokenAmount,
            0,
            cvxPath,
            receiver,
            deadline
        );
    }

    //check
    //set accounts that are exempt from fees
    function setFeeExempt(address _addr, bool _value) external onlyOwner {
        require(_isFeeExempt[_addr] != _value, "Not changed");
        _isFeeExempt[_addr] = _value;
        emit SetFeeExempted(_addr, _value);
    }

    function setPresaleWallet(address _presaleC) external onlyOwner {
        presaleContract = _presaleC;
    }

    //ERC20 overidden functions

    //check
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

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowanceForUser(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function _spendAllowanceForUser(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = _allowedFragments[owner][spender];
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

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);
        uint256 feesCollected = feeCollectedSpice;

        if (
            canSwapFees(feesCollected) &&
            !marketPairs[from] &&
            !inSwap &&
            !_isFeeExempt[from]
        ) {
            inSwap = true;
            swapAndTransferFees(feesCollected);
            inSwap = false;
        }

        if (canEvolve(from)) {
            inSwap = true;
            ILiquidityManager(liqudityHandlerWallet).swapAndEvolve();
            inSwap = false;
        }

        uint256 fromBalance = _balances[from];

        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        uint256 amountReceived = _shouldTakeFee(from, to)
            ? takeFees(from, to, amount)
            : amount;

        unchecked {
            _balances[from] = fromBalance.sub(amount);
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amountReceived;
        }

        emit Transfer(from, to, amountReceived);

        _afterTokenTransfer(from, to, amountReceived);
    }

    //check
    //set take fee amount returns amount minus fees
    function takeFees(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (uint256) {
        uint256 _realFee = 0;
        bool isBuy;
        //determine the fee
        if (marketPairs[recipient]) _realFee = totalSellFee;
        if (marketPairs[sender]) _realFee = totalBuyFee;

        _realFee = (_realFee * amount) / 100;
        uint256 gonAmount = amount.sub(_realFee);
        uint256 feeAmount = amount - gonAmount;
        _balances[address(this)] = _balances[address(this)] += feeAmount;
        feeCollectedSpice += feeAmount;

        emit Transfer(sender, address(this), feeAmount);
        //return fee
        return gonAmount;
    }

    //check
    function _shouldTakeFee(address from, address to)
        private
        view
        returns (bool isExempt)
    {
        if (_isFeeExempt[from] || _isFeeExempt[to]) {
            return false;
        } else if (marketPairs[from] || marketPairs[to]) {
            return true;
        } else {
            return false;
        }
    }

    //check
    //allows the contract to add liquidity
    function addLiquidityBusd(uint256 tokenAmount, uint256 busdAmount) public {
        router.addLiquidity(
            address(this),
            busd,
            tokenAmount,
            busdAmount,
            0,
            0,
            liquidityReceiver,
            block.timestamp
        );
    }

    function addInitialLiquidity(uint256 tokenA, uint256 tokenB) external {
        require(msg.sender == presaleContract);
        require(tokenA == tokenB, "amount not equal");
        _mint(address(this), tokenB);
        addLiquidityBusd(tokenA, tokenB);
    }

    function manualSync() public {
        for (uint256 i = 0; i < _markerPairs.length; i++) {
            InterfaceLP(_markerPairs[i]).sync();
        }
    }

    function canSwapFees(uint256 _fee) public view returns (bool canswap) {
        uint256 pairBalance = IERC20(busd).balanceOf(pairBusd);
        uint256 amount = fetchPCSPrice();
        if (
            pairBalance > (_fee.mul(amount).div(1e18)) &&
            _fee > 0 &&
            swapEnabled == true
        ) {
            return true;
        } else {
            return false;
        }
    }

    function canEvolve(address _from) public view returns (bool evolve) {
        uint256 liqudityHandlerWalletBusdBalance = IERC20(busd).balanceOf(
            liqudityHandlerWallet
        );
        if (
            liqudityHandlerWalletBusdBalance > SWAP_TRESHOLD &&
            !_isFeeExempt[_from] &&
            inSwap == false &&
            !marketPairs[_from] &&
            swapEnabled == true
        ) {
            return true;
        } else {
            return false;
        }
    }

    function toggleFeeSwapping(bool isEnabled) public onlyOwner {
        swapEnabled = isEnabled;
        emit SwappingStateChanged(isEnabled);
    }

    //distributes fess
    function swapAndTransferFees(uint256 _fee) public {
        uint256 totalFee = totalSellFee + totalBuyFee; //gas savings
        uint256 amountToTreasury = (_fee *
            ((sellTreasury.add(buyTreasury) * 100) / totalFee)) / 100;
        uint256 amountToLP = (_fee * ((sellLP.add(buyLP) * 100) / totalFee)) /
            100;
        uint256 amountToMarketing = (_fee *
            ((sellDevMarketing * 100) / totalFee)) / 100;
        uint256 amountToCharity = (_fee * ((sellCharity * 100) / totalFee)) /
            100;
        _swapSpiceForBusd(amountToTreasury, treasuryWallet);
        _swapSpiceForBusd(amountToLP, liqudityHandlerWallet);
        _swapSpiceForBusd(amountToMarketing, devAndMarketingWallet);
        _swapSpiceForBusd(amountToCharity, charityWallet);
        feeCollectedSpice -=
            amountToTreasury +
            amountToMarketing +
            amountToLP +
            amountToCharity;
    }

    //transfers busd fees collected
    function ILPTransferFees(bool isBuy, uint256 _fee) public {
        if (isBuy == true) {
            uint256 amountToTreasury = (buyTreasury * _fee) / 100;
            uint256 amountToLP = (buyLP * _fee) / 100;
            IERC20(busd).transfer(treasuryWallet, amountToTreasury);
            _mint(address(this), amountToLP);
            addLiquidityBusd(amountToLP, amountToLP);
        } else if (isBuy == false) {
            uint256 amountToTreasury = (sellTreasury * _fee) / 100;
            uint256 amountToLP = (sellLP * _fee) / 100;
            uint256 amountToMarketing = (sellDevMarketing * _fee) / 100;
            uint256 amountToCharity = (sellCharity * _fee) / 100;
            IERC20(busd).transfer(treasuryWallet, amountToTreasury);
            IERC20(busd).transfer(devAndMarketingWallet, amountToMarketing);
            IERC20(busd).transfer(charityWallet, amountToCharity);
            _mint(address(this), amountToLP);
            addLiquidityBusd(amountToLP, amountToLP);
        }
    }

    //setter functions
    //check
    function setNewMarketMakerPair(address _pair, bool _value)
        public
        onlyOwner
    {
        require(marketPairs[_pair] != _value, "Value already set");

        marketPairs[_pair] = _value;
        _markerPairs.push(_pair);
    }

    //check
    //Erc20 function overrides
    function balanceOf(address who) public view override returns (uint256) {
        return _balances[who];
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual override {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowedFragments[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowedFragments[owner][spender];
    }

    //check
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function _mint(address account, uint256 amount) internal virtual override {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);
        _afterTokenTransfer(address(0), account, amount);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        override
        returns (bool)
    {
        uint256 oldValue = _allowedFragments[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedFragments[msg.sender][spender] = 0;
        } else {
            _allowedFragments[msg.sender][spender] = oldValue.sub(
                subtractedValue
            );
        }
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        override
        returns (bool)
    {
        _allowedFragments[msg.sender][spender] = _allowedFragments[msg.sender][
            spender
        ].add(addedValue);
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    //check
    function checkFeeExempt(address _addr) external view returns (bool) {
        return _isFeeExempt[_addr];
    }

    //check
    function clearStuckFees(address _receiver) external onlyOwner {
        uint256 balance = feeCollectedSpice; //gas optimization
        transfer(_receiver, balance);
        emit ClearStuckBalance(_receiver);
    }

    //check
    //burn from the Pancake swap pair
    function burnFromPool(address holder, uint256 amount) public onlyOwner {
        uint256 poolBalance = balanceOf(pairBusd);
        require((poolBalance - MaxPoolBurn) > amount);
        _burnInternal(holder, amount);
    }

    //check
    function _burnInternal(address holder, uint256 amount) internal {
        require(marketPairs[holder], "It must be a pair contract");
        _totalSupply -= amount;
        _balances[holder] -= amount;
        InterfaceLP(holder).sync();
        emit Transfer(holder, address(0), amount);
    }

    function fetchPCSPrice() public view returns (uint256) {
        uint256[] memory out = router.getAmountsOut(1 ether, path);
        return out[1];
    }

    function _calcPCSPrice() public view returns (uint256) {
        uint256 spiceBalance = balanceOf(pairBusd);
        uint256 busdBalance = IERC20(busd).balanceOf(pairBusd);
        if (spiceBalance > 0) {
            uint256 price = busdBalance / spiceBalance;
            return price;
        } else {
            return 1;
        }
    }

    function changeSwapTreshold(uint256 newSwapTreshold) external onlyOwner {
        require(newSwapTreshold >= 1e18, "treshold must be higher");
        SWAP_TRESHOLD = newSwapTreshold;
    }

    //set fee wallets:
    function setFeeReceivers(
        address _liquidityReceiver,
        address _treasuryReceiver,
        address _charityValueReceiver,
        address _devAndMarketing
    ) external onlyOwner {
        liqudityHandlerWallet = _liquidityReceiver;
        treasuryWallet = _treasuryReceiver;
        charityWallet = _charityValueReceiver;
        devAndMarketingWallet = _devAndMarketing;
        _isFeeExempt[liqudityHandlerWallet] = true;
        _isFeeExempt[treasuryWallet] = true;
        _isFeeExempt[charityWallet] = true;
        _isFeeExempt[devAndMarketingWallet] = true;
        emit SetFeeReceivers(
            _liquidityReceiver,
            _treasuryReceiver,
            _charityValueReceiver,
            _devAndMarketing
        );
    }

    //events
    event SetFeeExempted(address _addr, bool _value);
    event BurnPCS(uint256 time, uint256 amount);
    event WalletTransfers(uint256 time, uint256 amount);
    event NewMarketMakerPair(address _pair, uint256 time);
    event PresaleWithdrawn(address receiver, uint256 amount);
    event PresaleOver(bool _over);
    event PresaleOpened(uint256 time, address sender);
    event SetFeeReceivers(
        address _liquidityReceiver,
        address _treasuryReceiver,
        address _riskFreeValueReceiver,
        address _marketing
    );
    event SwapBack(
        uint256 contractTokenBalance,
        uint256 amountToLiquify,
        uint256 amountToRFV,
        uint256 amountToDevMarketing,
        uint256 amountToTreasury,
        bool buy
    );
    event ClearStuckBalance(address _receiver);
    event SwappingStateChanged(bool enabled);
}