// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Algoblocks is ERC20 {

    enum Role {
        NONE,
        TEAM,
        ADVISORS,
        PARTNERSHIPS,
        IDO_INVESTORS,
        PRIVATE_INVESTORS,
        STRATEGIC_INVESTORS,
        GRANTS,
        MARKETING,
        MARKET_MAKERS,
        ECOSYSTEM_DEV
    }  // Available roles in the contract

    struct Holdup {
        uint paymentDate;       // When payment has been made
        uint256 amount;         // Amount transfered
    }

    struct VestingPlan {
        uint cliff;             // Number of days until linear release of funds
        uint vestingMonths;     // Number of months (month = 30.5 days) of vesting release
        uint256 dayOneRelease;  // Percentage (in 0.01 units) released on day one - excluded from vesting
    }

    event TokenGeneration(uint256 amount);
    event TransferWithVesting(address to, uint256 amount, uint role);
    event ReturnFrom(address account, uint256 amount);

    uint private _fullReleaseTimestamp; // Timestamp when all funds are released and no more checks on transfer is needed
   
    /*
    * @dev Total token supply. ALGOBLKs are fixed token supply
    */
    uint256 public constant TOTAL_SUPPLY = 188_000_000;

    /**
    * Marks Token generation event
    */
    bool private _executed = false;

    mapping(Role => mapping(address => Holdup)) private _lockedRecipients;
    mapping(address => Role) private _lockedMap;
    mapping(Role => VestingPlan) private _vestingPlan;

    address private _owner;

    modifier onlyOwner() {
        require(_owner == _msgSender(), "caller is not the owner");
        _;
    }
    modifier executedOnlyOnce(){
        require(!_executed, "Tokens have already been generated");
        _;
    }

    constructor(address ownerWallet)
    ERC20("Algoblocks", "ALGOBLK")
    {
        // Configure Vesting system here
        _configurePlan(Role.TEAM, 8 * (30.5 days), 24, 0);
        _configurePlan(Role.ADVISORS, 8 * (30.5 days), 24, 0);
        _configurePlan(Role.PRIVATE_INVESTORS, (30.5 days), 15, 750);
        _configurePlan(Role.STRATEGIC_INVESTORS, 2 * (30.5 days), 18, 250);
        _configurePlan(Role.IDO_INVESTORS, 0, 3, 2500);
        _configurePlan(Role.MARKETING, (7 days), 12, 0);
        _configurePlan(Role.PARTNERSHIPS, (7 days), 24, 0);
        _configurePlan(Role.GRANTS, (30.5 days), 12, 0);
        _configurePlan(Role.MARKET_MAKERS, (7 days), 12, 0);
        _configurePlan(Role.ECOSYSTEM_DEV, (30.5 days), 12, 0);
        _owner = ownerWallet;
    }

    function generateTokens(
        address[] memory teamAddresses,
        uint256[] memory teamAmounts,
        address[] memory advisorsAddresses,
        uint256[] memory advisorsAmounts,
        address[] memory privateInvestorsAddresses,
        uint256[] memory privateInvestorsAmounts,
        address[] memory strategicInvestorsAddresses,
        uint256[] memory strategicInvestorsAmounts,
        address[] memory idoInvestorsAddresses,
        uint256[] memory idoInvestorsAmounts
    )
    external
    onlyOwner
    executedOnlyOnce 
    returns (uint256 team, uint256 mintedToOwner) {
        _fullReleaseTimestamp = block.timestamp + (30.5 days) * 32;
        uint256 supply = TOTAL_SUPPLY * (10 ** decimals());
        // Full release after 30 months - team and advisors
        uint256 distributedTeamAmount = _distribute(Role.TEAM, teamAddresses, teamAmounts);
        supply -= distributedTeamAmount;
        supply -= _distribute(Role.ADVISORS, advisorsAddresses, advisorsAmounts);
        supply -= _distribute(Role.PRIVATE_INVESTORS, privateInvestorsAddresses, privateInvestorsAmounts);
        supply -= _distribute(Role.STRATEGIC_INVESTORS, strategicInvestorsAddresses, strategicInvestorsAmounts);
        supply -= _distribute(Role.IDO_INVESTORS, idoInvestorsAddresses, idoInvestorsAmounts);
        _mint(_owner, supply);
        _executed = true;
        emit TokenGeneration(TOTAL_SUPPLY * (10 ** decimals()) - supply);
        return (
            distributedTeamAmount,
            supply
        );
    }

    function burn(uint256 amount) external {
        _burn(_msgSender(), amount);
    }

    function transferWithVesting(address to, uint256 amount, uint role) external onlyOwner {
        require(_lockedMap[to] == Role.NONE, "Recipient already received vested money");

        _transfer(_msgSender(), to, amount);

        Role r = _toRole(role);
        _lockedMap[to] = r;
        _lockedRecipients[r][to].amount = amount;
        _lockedRecipients[r][to].paymentDate = block.timestamp;

        uint256 finalReleaseDate = _fullReleaseDateForRole(r, to);
        if (finalReleaseDate > _fullReleaseTimestamp) {
            _fullReleaseTimestamp = finalReleaseDate;
        }
        emit TransferWithVesting(to, amount, role);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {

        // If we haven't reached a global deadline, we need to make additional checks
        if (to != _owner && block.timestamp < _fullReleaseTimestamp) {

            // First, if sender is in the group of locked recipients
            if (_lockedMap[from] != Role.NONE) {

                // Now we know how much money owner has available
                uint256 availableFunds = balanceOf(from) - _amountLocked(from);

                // Time to check if the transfer does not exceed the amount available
                require(amount <= availableFunds, "Tokens are locked accordingly to your vesting plan.");
            }
        }

        super._beforeTokenTransfer(from, to, amount);
    }

    function _toRole(uint roleId) private pure returns (Role) {
        require(roleId >= 0, "Role Id too small");
        require(roleId <= 10, "Role Id too big");

        if (roleId == 1) {
            return Role.TEAM;
        } else if (roleId == 2) {
            return Role.ADVISORS;
        } else if (roleId == 3) {
            return Role.PARTNERSHIPS;
        } else if (roleId == 4) {
            return Role.IDO_INVESTORS;
        } else if (roleId == 5) {
            return Role.PRIVATE_INVESTORS;
        } else if (roleId == 6) {
            return Role.STRATEGIC_INVESTORS;
        } else if (roleId == 7) {
            return Role.GRANTS;
        } else if (roleId == 8) {
            return Role.MARKETING;
        } else if (roleId == 9) {
            return Role.MARKET_MAKERS;
        } else if (roleId == 10) {
            return Role.ECOSYSTEM_DEV;
        }
        return Role.NONE;
    }

    function _configurePlan(Role role, uint cliff, uint vestingMonths, uint dayOneRelease) private {
        _vestingPlan[role].cliff = cliff;
        _vestingPlan[role].vestingMonths = vestingMonths;
        _vestingPlan[role].dayOneRelease = dayOneRelease;
    }

    function lockedBalanceOf(address account) external view returns (uint256) {
        return _amountLocked(account);
    }

    function returnFrom(address account) external onlyOwner returns (uint256) {
        Role role = _lockedMap[account];

        require(role == Role.TEAM, 'account is not a team holder');

        uint256 lockedAmount = _amountLocked(account);

        if (lockedAmount > 0) {
            _transfer(account, _owner, lockedAmount);
            _lockedRecipients[role][account].paymentDate = 0;
            _lockedRecipients[role][account].amount = 0;
            _lockedMap[account] = Role.NONE;
        }
        emit ReturnFrom(account, lockedAmount);
        return lockedAmount;
    }

    function _amountLocked(address account) private view returns (uint256) {

        Role role = _lockedMap[account];

        if (role == Role.NONE) {
            return 0;
        }

        // Checking how much was initially transfered and locked
        uint256 amountLocked = _lockedRecipients[role][account].amount;

        // First, substract tokens released on TGE
        amountLocked -= (_vestingPlan[role].dayOneRelease * amountLocked) / 10000;

        // Only if cliff timestamp has been reached we can calculate further
        uint256 cliff = _lockedRecipients[role][account].paymentDate + _vestingPlan[role].cliff;
        if (block.timestamp > cliff) {
            // To check how much money one can use we need to divide time passed since the cliff by number of months
            
            uint256 monthsPassed = (block.timestamp - cliff) / (30.5 days);
            if (monthsPassed < _vestingPlan[role].vestingMonths) {
                amountLocked -= (amountLocked / _vestingPlan[role].vestingMonths) * monthsPassed;
            } else {
                amountLocked = 0;
            }
        }

        return amountLocked;
    }


    function _distribute(Role role,
        address[] memory addresses,
        uint256[] memory amounts) private returns (uint256) {
        require(addresses.length == amounts.length, "Wrong number of members");
        uint256 used = 0;
        for (uint i = 0; i < addresses.length; i++) {
            uint256 amount = amounts[i] * (10 ** decimals());
            _mint(addresses[i], amount);
            used += amount;
            _lockedRecipients[role][addresses[i]].paymentDate = block.timestamp;
            _lockedRecipients[role][addresses[i]].amount = amount;
            _lockedMap[addresses[i]] = role;
        }

        return used;
    }

    function _fullReleaseDateForRole(Role role, address account) private view returns (uint) {
        return _lockedRecipients[role][account].paymentDate + _vestingPlan[role].cliff + _vestingPlan[role].vestingMonths * (30.5 days);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/ERC20.sol)

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

// SPDX-License-Identifier: MIT
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