// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DINW is ERC20{

    address constant public TEAM_WALLET=0x870bDfE9fC9EdB2d2319BB1077E12DF36B677F85;
    address constant public SEED_ROUND_WALLET=0x473dd690F44283ecC74688d92F5C33223C6bC1E7;
    address constant public PRIVATE_ROUND_WALLET=0x1D38F3c8F0CA4970Ed592E99723E0F0daC45FbbB;
    address constant public PUBLIC_SALE_WALLET=0x355A11aa1E0167f148DD546C89Ee2eAEc25fBfbd;
    address constant public REWARDS_WALLET=0x461cd623477D9D6Bc90fEC4Dbf674CB3e410823a;
    address constant public DEV_WALLET=0x770211D3A27daA0EDA370f8f603FC9c111401734;
    address constant public MARKETING_WALLET=0x0a90d77214880Ce48979A647e7BE80e329786040;
    address constant public TREASURY_WALLET=0x369A65aA17540e7762F771346C007B6647D5403d;
    address constant public LIQUIDITY_WALLET=0x029A1B4D47EE8a2177200637B76C5B581CD69FcE;

    address[] internal contract_wallets=[
        TEAM_WALLET,
        SEED_ROUND_WALLET,
        PRIVATE_ROUND_WALLET,
        PUBLIC_SALE_WALLET,
        REWARDS_WALLET, 
        DEV_WALLET,
        MARKETING_WALLET,
        TREASURY_WALLET,
        LIQUIDITY_WALLET
        ];

   
    /**
     * @dev Returns the full amount of locked balance for `wallet`.
     */
    mapping(address => uint256) public _locked_balances;
    /**
     * @dev Returns the amount of partial unlocked balance for `wallet`.
     */
    mapping(address => uint256) public _unlocked_balances;

    /**
     * @dev Returns the amount limits of locked balance for `wallet` per `month`.
     */
    mapping(address => uint256[40]) public _unlock;

    uint40 constant start_date=1683676800; //May 10, 2023
    /**
     * @dev Returns the dates of periods.
     */
    uint40[40] public unlock_plan=[
        1683676800, //May 10, 2023
        1686355200, //Jun 10, 2023
        1688947200, //Jul 10, 2023
        1691625600, //Aug 10, 2023
        1694304000, //Sep 10, 2023
        1696896000, //Oct 10, 2023
        1699574400, //Nov 10, 2023
        1702166400, //Dec 10, 2023
        1704844800, //Jan 10, 2024
        1707523200, //Feb 10, 2024

        1710028800, //Mar 10, 2024
        1712707200, //Apr 10, 2024
        1715299200, //May 10, 2024
        1717977600, //Jun 10, 2024
        1720569600, //Jul 10, 2024
        1723248000, //Aug 10, 2024
        1725926400, //Sep 10, 2024
        1728518400, //Oct 10, 2024
        1731196800, //Nov 10, 2024
        1733788800, //Dec 10, 2024

        1736467200, //Jan 10, 2025
        1739145600, //Feb 10, 2025
        1741564800, //Mar 10, 2025
        1744243200, //Apr 10, 2025
        1746835200, //May 10, 2025
        1749513600, //Jun 10, 2025
        1752105600, //Jul 10, 2025
        1754784000, //Aug 10, 2025
        1757462400, //Sep 10, 2025
        1760054400, //Oct 10, 2025

        1762732800, //Nov 10, 2025
        1765324800, //Dec 10, 2025
        1768003200, //Jan 10, 2026
        1770681600, //Feb 10, 2026
        1773100800, //Mar 10, 2026
        1775779200, //Apr 10, 2026
        1778371200, //May 10, 2026
        1781049600, //Jun 10, 2026
        1783641600, //Jul 10, 2026
        1786320000 //Aug 10, 2026

    ];
    /**
     * @dev Emitted when the unlocked of a `value` for an `spender` is set by
     * a call to {unlock}. `value` is the unlocked value.
     */
    event Unlocked(address indexed spender, uint256 value);

    constructor() ERC20('DINO WARS','DINW') {
        
        _locked_balances[TEAM_WALLET]=5500000e18;
        _locked_balances[SEED_ROUND_WALLET]=3000000e18;
        _locked_balances[PRIVATE_ROUND_WALLET]=8500000e18;
        _locked_balances[PUBLIC_SALE_WALLET]=1500000e18;
        _locked_balances[REWARDS_WALLET]=17500000e18;
        _locked_balances[DEV_WALLET]=4000000e18;
        _locked_balances[MARKETING_WALLET]=1500000e18;
        _locked_balances[TREASURY_WALLET]=3500000e18;
        _locked_balances[LIQUIDITY_WALLET]=5000000e18;
        _unlock[TEAM_WALLET]=[
            0,          0,          0,          0,          0,          0,          0,          0,          0,          0,
            0,          0,          196429e18, 392857e18, 589286e18, 785714e18, 982143e18,1178571e18,1375000e18,1571429e18,
            1767857e18,	1964286e18,2160714e18,2357143e18,2553571e18,2750000e18,2946429e18,3142857e18,3339286e18,3535714e18,
            3732143e18,	3928571e18,4125000e18,4321429e18,4517857e18,4714286e18,4910714e18,5107143e18,5303571e18,5500000e18
            ];
        _unlock[SEED_ROUND_WALLET]=[
            0, 	        0, 	       0,          533333e18, 766667e18,1000000e18,1500000e18,1750000e18,2000000e18,2500000e18,
            2750000e18,	3000000e18,3000000e18,3000000e18,3000000e18,3000000e18,3000000e18,3000000e18,3000000e18,3000000e18,
            3000000e18,	3000000e18,3000000e18,3000000e18,3000000e18,3000000e18,3000000e18,3000000e18,3000000e18,3000000e18,
            3000000e18,	3000000e18,3000000e18,3000000e18,3000000e18,3000000e18,3000000e18,3000000e18,3000000e18,3000000e18
            ];
        _unlock[PRIVATE_ROUND_WALLET]=[
             425000e18, 1322222e18, 2219444e18,	3116667e18, 4013889e18, 4911111e18, 5808333e18, 6705556e18, 7602778e18,	8500000e18,
            8500000e18, 8500000e18, 8500000e18, 8500000e18, 8500000e18, 8500000e18, 8500000e18, 8500000e18, 8500000e18, 8500000e18,
            8500000e18, 8500000e18, 8500000e18, 8500000e18, 8500000e18, 8500000e18, 8500000e18, 8500000e18, 8500000e18, 8500000e18,
            8500000e18, 8500000e18, 8500000e18, 8500000e18, 8500000e18, 8500000e18, 8500000e18, 8500000e18, 8500000e18, 8500000e18
            ];
        _unlock[PUBLIC_SALE_WALLET]=[
             375000e18,  600000e18,  825000e18, 1050000e18, 1275000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18,
            1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18,
            1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18,
            1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18
            ];
        _unlock[REWARDS_WALLET]=[
              525000e18,   525000e18,  1090833e18,  1656667e18,	 2109333e18,  2562000e18,  3354167e18,  3920000e18,  4485833e18,  5051667e18,
             5617500e18,  6183333e18,  6749167e18,  7315000e18,  7880833e18,  8446667e18,  9012500e18,  9578333e18, 10144167e18, 10710000e18,
            11275833e18, 11841667e18, 12407500e18, 12973333e18, 13539167e18, 14105000e18, 14670833e18, 15236667e18, 15802500e18, 16368333e18,
            16934167e18, 17500000e18, 17500000e18, 17500000e18, 17500000e18, 17500000e18, 17500000e18, 17500000e18, 17500000e18, 17500000e18
            ];
        _unlock[DEV_WALLET]=[
            0, 	         0,          0,          133333e18,  266667e18,  400000e18,  533333e18,  666667e18,  800000e18,  933333e18,
            1066667e18, 1200000e18, 1333333e18, 1466667e18, 1600000e18, 1733333e18, 1866667e18, 2000000e18, 2133333e18, 2266667e18,
            2400000e18, 2533333e18, 2666667e18, 2800000e18, 2933333e18, 3066667e18, 3200000e18, 3333333e18, 3466667e18, 3600000e18,
            3733333e18, 3866667e18, 4000000e18, 4000000e18, 4000000e18, 4000000e18, 4000000e18, 4000000e18, 4000000e18, 4000000e18
            ];
        _unlock[MARKETING_WALLET]=[
            0,           125000e18,  250000e18,  375000e18,  500000e18,  625000e18,  750000e18,  875000e18, 1000000e18, 1125000e18,
            1250000e18, 1375000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18,
            1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18,
            1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18, 1500000e18
            ];
        _unlock[TREASURY_WALLET]=[
            0,          0,          0,          0,          0,          0,          0,          0,          0,          0,
            0,          0,           125000e18,  250000e18,  375000e18,  500000e18,  625000e18,  750000e18,  875000e18, 1000000e18,
            1125000e18, 1250000e18, 1375000e18, 1500000e18, 1625000e18, 1750000e18, 1875000e18,	2000000e18, 2125000e18, 2250000e18,
            2375000e18, 2500000e18, 2625000e18, 2750000e18, 2875000e18, 3000000e18, 3125000e18, 3250000e18, 3375000e18, 3500000e18
            ];
        _unlock[LIQUIDITY_WALLET]=[
             750000e18,  750000e18,  750000e18, 1015625e18, 1148438e18, 1281250e18, 1546875e18, 1679688e18, 1812500e18, 1989583e18,
            2166667e18, 2343750e18, 2520833e18, 2697917e18, 2875000e18, 3052083e18, 3229167e18, 3406250e18, 3583333e18, 3760417e18,
            3937500e18, 4114583e18, 4291667e18, 4468750e18, 4645833e18, 4822917e18, 5000000e18, 5000000e18, 5000000e18, 5000000e18,
            5000000e18, 5000000e18, 5000000e18, 5000000e18, 5000000e18, 5000000e18, 5000000e18, 5000000e18, 5000000e18, 5000000e18
            ];
        //Token Generation Event
        unlock(PRIVATE_ROUND_WALLET,425000e18);
        unlock(PUBLIC_SALE_WALLET,375000e18);
        unlock(REWARDS_WALLET,525000e18);
        unlock(LIQUIDITY_WALLET,750000e18);
    }

     /**
     * @dev
     *
     * Emits an {Unlocked} event indicating the unlocked balance. 
     * Unlock vested tokens and add them to the `msg.sender` balance.
     *
     * Requirements:
     *
     * - `amount` available should be checked in `avail_locked_tokens`.
     */
    function unlock(uint256 amount) external {
        require( avail_locked_tokens(msg.sender, uint40(block.timestamp)) >=amount + _unlocked_balances[msg.sender], "No enough tokens");
        unlock(msg.sender, amount);
    }
    
    /**
     * @dev Returns the available `amount` of tokens of `wallet` for exact time `timestamp`.
     */
    function avail_locked_tokens(address wallet, uint40 timestamp) public view returns(uint amount){
        if (_locked_balances[wallet] == 0) return 0;
        if (timestamp < start_date) return 0;
        for(uint40 t=39;t>0;t--){
            if (timestamp > unlock_plan[t]){
                return _unlock[wallet][t];
            }
        }
        return _unlock[wallet][0];
    }
    
    function unlock(address wallet,uint amount) internal{
        _unlocked_balances[wallet]+=amount;
        _mint(wallet, amount);
        emit Unlocked(wallet, amount);
    }
}