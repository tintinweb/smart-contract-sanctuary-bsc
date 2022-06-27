// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract PolarBear is Ownable, ERC20 {
    constructor() ERC20("PolarBear", "PLB") {}

    function mint(address account, uint256 amount) public onlyOwner {
        _mint(account, amount);
    }
}

contract Flake is Ownable, ERC20 {
    address public minter;
    address private _taxvault;

    struct User {
        //Referral Info
        address upline;
        uint256 referrals;
        uint256 total_structure;
        //Long-term Referral Accounting
        uint256 direct_bonus;
        uint256 match_bonus;
        //Deposit Accounting
        uint256 deposits;
        uint256 deposit_time;
        //Payout and Roll Accounting
        uint256 payouts;
        // rolls = hydrate
        uint256 rolls;
        //Upline Round Robin tracking
        uint256 ref_claim_pos;
    }

    mapping(address => User) private users;

    uint256[] public ref_balances;

    PolarBear polarBear;

    // stats
    uint256 public total_users = 1;

    // constants
    uint256 private constant ref_depth = 15;
    uint256 private minimumAmount = 1e18;
    uint256 private minimumInitial = 10e18;

    event Deposit(address, uint256);
    event Compound(address, uint256);
    event Claim(address, uint256);

    constructor(address taxvault_, address polarBearAddress)
        ERC20("Flake", "FLK")
    {
        _taxvault = taxvault_;
        polarBear = PolarBear(polarBearAddress);

        //Referral Balances
        ref_balances.push(2e18);
        ref_balances.push(3e18);
        ref_balances.push(5e18);
        ref_balances.push(8e18);
        ref_balances.push(12e18);
        ref_balances.push(21e18);
        ref_balances.push(34e18);
        ref_balances.push(55e18);
        ref_balances.push(89e18);
        ref_balances.push(144e18);
        ref_balances.push(233e18);
        ref_balances.push(377e18);
        ref_balances.push(610e18);
        ref_balances.push(987e18);
        ref_balances.push(1597e18);
    }

    // ******** Administrative functions ******

    function setTaxVault(address account) public onlyOwner {
        require(_taxvault != address(0), "tax vault cannot be a void address");
        _taxvault = account;
    }

    function setMinimumAmount(uint256 amount) public onlyOwner {
        minimumAmount = amount;
    }

    function setMinimumInitial(uint256 amount) public onlyOwner {
        minimumInitial = amount;
    }

    function mint(address account, uint256 amount) public onlyOwner {
        _mint(account, amount);
    }

    function mintTaxvault(uint256 amount) private {
        _mint(_taxvault, amount);
    }

    // ******** Getter functions ******

    function depositsOf(address account)
        public
        view
        returns (uint256 deposits)
    {
        return users[account].deposits;
    }

    function depositTimeOf(address account)
        public
        view
        returns (uint256 depositTime)
    {
        return users[account].deposit_time;
    }

    function uplineOf(address account) public view returns (address upline) {
        return users[account].upline;
    }

    function getTaxVault() public view returns (address taxvault) {
        return _taxvault;
    }

    function buddyOf(address account) public view returns (address taxvault) {
        return users[account].upline;
    }

    function maxPayoutOf(address account)
        public
        view
        returns (uint256 maxPayout)
    {
        return (depositsOf(account) / 100) * 365;
    }

    // ******** Utils functions ******

    // Get the 1 % daily reward payout of account
    function payoutOf(address account) public view returns (uint256 payout) {
        return
            ((block.timestamp - users[account].deposit_time) *
                users[account].deposits) / (24 * 3600 * 100);
    }

    //@dev Returns true if the address is net positive
    function isNetPositive(address account) public view returns (bool) {
        User memory user = users[account];

        return (user.rolls + user.deposits) > user.payouts;
    }

    //@dev Returns the level of the PLB address
    function polarBearBalanceLevel(address account)
        public
        view
        returns (uint8)
    {
        uint8 _level = 0;
        for (uint8 i = 0; i < ref_depth; i++) {
            if (polarBear.balanceOf(account) < ref_balances[i]) break;
            _level += 1;
        }

        return _level;
    }

    //@dev Returns whether PLB balance matches level
    function isBalanceCovered(address account, uint8 _level)
        public
        view
        returns (bool)
    {
        return polarBearBalanceLevel(account) >= _level;
    }

    // Referral algorith (round-robin) to pay upline
    // Takes address of depositer/hydrater, find the buddy and pay him the referral amount
    // The bonus must be the rewarded amount
    function referralPayout(address account, uint256 bonus) internal {
        address upline = users[account].upline;

        for (uint8 i = 0; i < ref_depth; i++) {
            // we've reached the top of the chain, aka the owner
            if (upline == address(0)) {
                users[account].ref_claim_pos = ref_depth;
                break;
            }

            // we only math if the position is eligible
            if (
                users[account].ref_claim_pos == i &&
                isNetPositive(upline) &&
                isBalanceCovered(upline, i + 1) &&
                payoutOf(upline) < maxPayoutOf((upline))
            ) {
                //Team wallets are split 75/25%
                if (users[upline].referrals >= 5) {
                    uint256 self_share = bonus / 4;
                    uint256 up_share = bonus - self_share;

                    users[upline].deposits += up_share;
                    users[account].deposits += self_share;

                    users[upline].match_bonus += up_share;
                    users[account].match_bonus += self_share;
                } else {
                    users[upline].deposits += bonus;
                    users[upline].match_bonus += bonus;
                }

                // referral done
                break;
            }

            upline = users[upline].upline;
        }

        // reward next in upline
        users[account].ref_claim_pos += 1;

        if (
            users[account].ref_claim_pos >= ref_depth ||
            users[upline].upline == address(0)
        ) {
            users[account].ref_claim_pos = 0;
        }
    }

    // ******** External functions ******

    function deposit(uint256 amount) public {
        uint256 total_amount = amount;

        require(amount <= balanceOf(msg.sender), "Insufficient balance.");
        require(
            users[msg.sender].upline != address(0) || msg.sender == owner(),
            "You need a buddy to deposit."
        );
        require(amount >= minimumAmount, "Minimum deposit amount not reached");

        // If fresh account require 10 Flakes
        if (users[msg.sender].deposits == 0) {
            require(
                amount >= minimumInitial,
                "Initial deposit amount not reached"
            );
        }

        // claim if divs are greater than 1% of the deposit
        if (payoutOf(msg.sender) > amount / 100) {
            total_amount += payoutOf(msg.sender);
        }

        uint256 tax = (total_amount * 1) / 10;
        _transfer(msg.sender, _taxvault, tax);
        _burn(msg.sender, amount - tax);
        users[msg.sender].deposits += total_amount - tax;
        users[msg.sender].deposit_time = block.timestamp;

        // 10% direct commission only if net positive

        // Referral
        uint256 referralAmount = ((amount - tax) * 10) / 100;
        referralPayout(msg.sender, referralAmount);

        emit Deposit(msg.sender, amount);
    }

    function compound() public {
        require(depositsOf(msg.sender) > 0, "Insufficient deposit balance.");
        uint256 value = payoutOf(msg.sender);
        require(
            balanceOf(_taxvault) >= value,
            "Insufficent tax vault balance."
        );
        users[msg.sender].deposits += value;
        users[msg.sender].deposit_time = block.timestamp;
        users[msg.sender].rolls += value;
        _burn(_taxvault, value);
        emit Compound(msg.sender, value);
    }

    function claim() public {
        require(users[msg.sender].deposits > 0);

        uint256 amount = ((block.timestamp - users[msg.sender].deposit_time) *
            users[msg.sender].deposits) / (24 * 3600 * 100);

        uint256 maxPayout = maxPayoutOf(msg.sender);

        if ((amount + users[msg.sender].payouts) > maxPayout) {
            amount = maxPayout - users[msg.sender].payouts;
        }

        uint256 tax = amount / 10;

        if (balanceOf(_taxvault) < (amount - tax)) {
            mintTaxvault(amount - tax - balanceOf(_taxvault) + 1);
        }

        _transfer(_taxvault, msg.sender, amount - tax);

        users[msg.sender].deposits = 0;

        users[msg.sender].payouts += amount;

        emit Claim(msg.sender, amount);
    }

    function addBuddy(address buddyAddress) public {
        require(
            users[msg.sender].upline == address(0),
            "You already have a buddy"
        );
        require(
            msg.sender != buddyAddress,
            "You cannot be buddy with yourself"
        );

        require(
            users[buddyAddress].deposit_time > 0 || buddyAddress == owner(),
            "Your buddy must have done a deposit before"
        );

        users[msg.sender].upline = buddyAddress;
        users[buddyAddress].referrals++;

        total_users++;

        address _upline = buddyAddress;

        for (uint8 i = 0; i < ref_depth; i++) {
            if (_upline == address(0)) break;

            users[_upline].total_structure++;

            _upline = users[_upline].upline;
        }
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