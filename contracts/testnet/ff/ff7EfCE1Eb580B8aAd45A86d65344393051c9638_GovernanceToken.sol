// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./VestingGovernanceToken.sol";

contract GovernanceToken is Pausable, Ownable, VestingGovernanceToken {
    constructor(string memory _contractName, string memory _contractSymbol)
        ERC20(_contractName, _contractSymbol)
    {
        _initAllocationAmount();
        _mint(_msgSender(), 600 * _millions() * _tokenWei()); // 600M
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(_from, _to, _amount);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

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
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
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
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
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
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
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
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
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

pragma solidity >=0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

abstract contract VestingGovernanceToken is ERC20Burnable, Ownable {
    using SafeMath for uint256;

    enum Allocation {
        PRE_SALE,
        LIQIDITY,
        PRIVATE_SALE,
        CEX_LISTING,
        AIRDROP,
        PLAY_GROWTH_FUND,
        STAKING_GROWTH_FUND,
        COMMUNITY_GROWTH_FUND,
        PLATFORM_GROWTH_FUND,
        ADVISORS,
        TEAM
    }

    struct AllocationAmount {
        bool isValid;
        uint256 amount;
        address account;
    }

    struct AllocationGrant {
        bool isValid;
        Allocation allocation;
    }

    event AllocationGranted(
        address indexed user,
        Allocation allocation,
        uint64 timestamp
    );

    mapping(Allocation => AllocationAmount) public allocationAmounts;
    mapping(address => AllocationGrant) public allocationGrants;

    // Make sure available amount before perform transfer
    modifier onlyIfFundsAvailableNow(address _account, uint256 _amount) {
        // Distinguish insufficient overall balance from insufficient vested funds balance
        require(
            _fundsAreAvailableOn(_account, _amount),
            balanceOf(_account) < _amount
                ? "Insufficient funds"
                : "Insufficient released funds"
        );
        _;
    }

    // Init amount for each allocation
    function _initAllocationAmount() internal {
        allocationAmounts[Allocation.PRE_SALE] = AllocationAmount(
            true,
            120 * _millions() * _tokenWei(), // 120M ~ 20%
            address(0)
        );
        allocationAmounts[Allocation.LIQIDITY] = AllocationAmount(
            true,
            72 * _millions() * _tokenWei(), // 72M ~ 12%
            address(0)
        );
        allocationAmounts[Allocation.PRIVATE_SALE] = AllocationAmount(
            true,
            30 * _millions() * _tokenWei(), // 30M ~ 5%
            address(0)
        );
        allocationAmounts[Allocation.CEX_LISTING] = AllocationAmount(
            true,
            30 * _millions() * _tokenWei(), // 30M ~ 5%
            address(0)
        );
        allocationAmounts[Allocation.AIRDROP] = AllocationAmount(
            true,
            12 * _millions() * _tokenWei(), // 12M ~ 2%
            address(0)
        );
        allocationAmounts[Allocation.PLAY_GROWTH_FUND] = AllocationAmount(
            true,
            150 * _millions() * _tokenWei(), // 150M ~ 25%
            address(0)
        );
        allocationAmounts[Allocation.STAKING_GROWTH_FUND] = AllocationAmount(
            true,
            48 * _millions() * _tokenWei(), // 48M ~ 8%
            address(0)
        );
        allocationAmounts[Allocation.COMMUNITY_GROWTH_FUND] = AllocationAmount(
            true,
            42 * _millions() * _tokenWei(), // 42M ~ 7%
            address(0)
        );
        allocationAmounts[Allocation.PLATFORM_GROWTH_FUND] = AllocationAmount(
            true,
            42 * _millions() * _tokenWei(), // 42M ~ 7%
            address(0)
        );
        allocationAmounts[Allocation.ADVISORS] = AllocationAmount(
            true,
            18 * _millions() * _tokenWei(), // 18M ~ 3%
            address(0)
        );
        allocationAmounts[Allocation.TEAM] = AllocationAmount(
            true,
            36 * _millions() * _tokenWei(), // 36M ~ 6%
            address(0)
        );
    }

    //*****
    // Utils and functions to validate data
    //*****

    function _tokenWei() internal view returns (uint256) {
        return 10**decimals();
    }

    function _millions() internal pure returns (uint256) {
        return 10**6;
    }

    function _isExistAllocation(Allocation _allocation)
        internal
        view
        returns (bool)
    {
        return !!allocationAmounts[_allocation].isValid;
    }

    function _isAvailableAllocation(Allocation _allocation)
        internal
        view
        returns (bool)
    {
        return
            _isExistAllocation(_allocation) &&
            allocationAmounts[_allocation].account == address(0);
    }

    function _isAvailableGrant(address _account) internal view returns (bool) {
        return !allocationGrants[_account].isValid;
    }

    //*****
    // List schedules of vesting for each allocation
    // We're using this page to get timestamp: https://www.epochconverter.com/
    //*****

    function _getLockedAmountForPreSale(uint64 _currentTimestamp)
        internal
        view
        returns (uint256)
    {
        uint256 lockedAmount = uint256(0);

        // 2022-10-08
        if (_currentTimestamp < 1665187200) {
            // 10M
            lockedAmount.add(10 * _millions() * _tokenWei());
        }
        // 2022-10-12
        if (_currentTimestamp < 1665532800) {
            // 6M
            lockedAmount.add(6 * _millions() * _tokenWei());
        }

        return _currentTimestamp;
    }

    function _getLockedAmountForLiqidity(uint64 _currentTimestamp)
        internal
        view
        returns (uint256)
    {
        uint256 lockedAmount = uint256(0);

        // 2022-10-08
        if (_currentTimestamp < 1665187200) {
            // 5M
            lockedAmount.add(5 * _millions() * _tokenWei());
        }
        // 2022-10-11
        if (_currentTimestamp < 1665446400) {
            // 7M
            lockedAmount.add(7 * _millions() * _tokenWei());
        }

        return lockedAmount;
    }

    function _getLockedAmountForPrivateSale(uint64 _currentTimestamp)
        internal
        view
        returns (uint256)
    {
        uint256 lockedAmount = uint256(0);

        // 2022-10-08
        if (_currentTimestamp < 1665187200) {
            // 3M
            lockedAmount.add(3 * _millions() * _tokenWei());
        }
        // 2022-10-13
        if (_currentTimestamp < 1665619200) {
            // 8M
            lockedAmount.add(8 * _millions() * _tokenWei());
        }

        return lockedAmount;
    }

    function _getLockedAmountForCexListing(uint64 _currentTimestamp)
        internal
        view
        returns (uint256)
    {
        uint256 lockedAmount = uint256(0);

        // 2022-10-09
        if (_currentTimestamp < 1665273600) {
            // 4M
            lockedAmount.add(4 * _millions() * _tokenWei());
        }
        // 2022-10-13
        if (_currentTimestamp < 1665619200) {
            // 10M
            lockedAmount.add(10 * _millions() * _tokenWei());
        }

        return lockedAmount;
    }

    function _getLockedAmountForAirdrop(uint64 _currentTimestamp)
        internal
        view
        returns (uint256)
    {
        uint256 lockedAmount = uint256(0);

        // 2022-10-10
        if (_currentTimestamp < 1665360000) {
            // 5M
            lockedAmount.add(5 * _millions() * _tokenWei());
        }

        return lockedAmount;
    }

    function _getLockedAmountForPlayGrowthFund(uint64 _currentTimestamp)
        internal
        view
        returns (uint256)
    {
        uint256 lockedAmount = uint256(0);

        // 2022-10-07
        if (_currentTimestamp < 1665100800) {
            // 8M
            lockedAmount.add(8 * _millions() * _tokenWei());
        }
        // 2022-10-13
        if (_currentTimestamp < 1665619200) {
            // 10M
            lockedAmount.add(10 * _millions() * _tokenWei());
        }

        return lockedAmount;
    }

    function _getLockedAmountForStakingGrowthFund(uint64 _currentTimestamp)
        internal
        view
        returns (uint256)
    {
        uint256 lockedAmount = uint256(0);

        // 2022-10-07
        if (_currentTimestamp < 1665100800) {
            // 8M
            lockedAmount.add(8 * _millions() * _tokenWei());
        }
        // 2022-10-13
        if (_currentTimestamp < 1665619200) {
            // 10M
            lockedAmount.add(10 * _millions() * _tokenWei());
        }

        return lockedAmount;
    }

    function _getLockedAmountForCommunityGrowthFund(uint64 _currentTimestamp)
        internal
        view
        returns (uint256)
    {
        uint256 lockedAmount = uint256(0);

        // 2022-10-07
        if (_currentTimestamp < 1665100800) {
            // 3M
            lockedAmount.add(3 * _millions() * _tokenWei());
        }
        // 2022-10-13
        if (_currentTimestamp < 1665619200) {
            // 3M
            lockedAmount.add(3 * _millions() * _tokenWei());
        }

        return lockedAmount;
    }

    function _getLockedAmountForPlatformGrowthFund(uint64 _currentTimestamp)
        internal
        view
        returns (uint256)
    {
        uint256 lockedAmount = uint256(0);

        // 2022-10-07
        if (_currentTimestamp < 1665100800) {
            // 9M
            lockedAmount.add(9 * _millions() * _tokenWei());
        }
        // 2022-10-13
        if (_currentTimestamp < 1665619200) {
            // 3M
            lockedAmount.add(3 * _millions() * _tokenWei());
        }

        return lockedAmount;
    }

    function _getLockedAmountForAdvisors(uint64 _currentTimestamp)
        internal
        view
        returns (uint256)
    {
        uint256 lockedAmount = uint256(0);

        // 2022-10-09
        if (_currentTimestamp < 1665273600) {
            // 3M
            lockedAmount.add(3 * _millions() * _tokenWei());
        }

        return lockedAmount;
    }

    function _getLockedAmountForTeam(uint64 _currentTimestamp)
        internal
        view
        returns (uint256)
    {
        uint256 lockedAmount = uint256(0);

        // 2022-10-13
        if (_currentTimestamp < 1665619200) {
            // 3M
            lockedAmount.add(3 * _millions() * _tokenWei());
        }

        return lockedAmount;
    }

    function _getLockedAmount(address _account)
        internal
        view
        returns (uint256)
    {
        if (!_isAvailableGrant(_account)) {
            return uint256(0);
        }

        AllocationGrant memory allocationGrant = allocationGrants[_account];
        uint64 currentTimestamp = uint64(block.timestamp);

        if (Allocation.PRE_SALE == allocationGrant.allocation) {
            return _getLockedAmountForPreSale(currentTimestamp);
        }
        if (Allocation.LIQIDITY == allocationGrant.allocation) {
            return _getLockedAmountForLiqidity(currentTimestamp);
        }
        if (Allocation.PRIVATE_SALE == allocationGrant.allocation) {
            return _getLockedAmountForPrivateSale(currentTimestamp);
        }
        if (Allocation.CEX_LISTING == allocationGrant.allocation) {
            return _getLockedAmountForCexListing(currentTimestamp);
        }
        if (Allocation.AIRDROP == allocationGrant.allocation) {
            return _getLockedAmountForAirdrop(currentTimestamp);
        }
        if (Allocation.PLAY_GROWTH_FUND == allocationGrant.allocation) {
            return _getLockedAmountForPlayGrowthFund(currentTimestamp);
        }
        if (Allocation.STAKING_GROWTH_FUND == allocationGrant.allocation) {
            return _getLockedAmountForStakingGrowthFund(currentTimestamp);
        }
        if (Allocation.COMMUNITY_GROWTH_FUND == allocationGrant.allocation) {
            return _getLockedAmountForCommunityGrowthFund(currentTimestamp);
        }
        if (Allocation.PLATFORM_GROWTH_FUND == allocationGrant.allocation) {
            return _getLockedAmountForPlatformGrowthFund(currentTimestamp);
        }
        if (Allocation.ADVISORS == allocationGrant.allocation) {
            return _getLockedAmountForAdvisors(currentTimestamp);
        }
        if (Allocation.TEAM == allocationGrant.allocation) {
            return _getLockedAmountForTeam(currentTimestamp);
        }

        return uint256(0);
    }

    //*****
    // Get availabel amount and grant vesting tokens to beneficiary
    //*****

    function _fundsAreAvailableOn(address _account, uint256 _amount)
        internal
        view
        returns (bool)
    {
        return _amount <= availableAmountOf(_account);
    }

    function availableAmountOf(address _account) public view returns (uint256) {
        return balanceOf(_account).sub(_getLockedAmount(_account));
    }

    function grantVestingTokens(address _account, Allocation _allocation)
        public
        onlyOwner
        returns (bool)
    {
        // Make sure no prior grant is in effect
        require(_isAvailableGrant(_account), "Account is granted before");
        // Check allocation is exist
        require(_isExistAllocation(_allocation), "Invalid allocation");
        // Check allocation is available
        require(_isAvailableAllocation(_allocation), "Unavaible allocation");

        // Transfer the total number of tokens from grantor into the account's holdings
        _transfer(
            _msgSender(),
            _account,
            allocationAmounts[_allocation].amount
        );

        // Create and populate a grant
        allocationGrants[_account] = AllocationGrant(true, _allocation);
        allocationAmounts[_allocation].account = _account;

        // Emit the event and return success
        emit AllocationGranted(_account, _allocation, uint64(block.timestamp));

        return true;
    }

    //*****
    // Overwrite transfer and approve methods to make sure users have abilities for this actions
    //*****

    function transfer(address _to, uint256 _amount)
        public
        override
        onlyIfFundsAvailableNow(_msgSender(), _amount)
        returns (bool)
    {
        return super.transfer(_to, _amount);
    }

    function approve(address _spender, uint256 _amount)
        public
        override
        onlyIfFundsAvailableNow(_msgSender(), _amount)
        returns (bool)
    {
        return super.approve(_spender, _amount);
    }
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/extensions/ERC20Burnable.sol)

pragma solidity ^0.8.0;

import "../ERC20.sol";
import "../../../utils/Context.sol";

/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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