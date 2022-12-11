// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
pragma solidity >= 0.8.17;

//---------------------------------------------------------
// Interface
//---------------------------------------------------------
interface IBullish
{
	function set_chick(address _new_address) external;
	function set_cakebaker(address _new_address) external;
	function set_operator(address _new_operator) external;
	function set_xnft_address(address _address_xnft) external;
	function get_pool_count() external returns(uint256);
	function set_deposit_fee(uint256 _pool_id, uint16 _fee) external;
	function set_withdrawal_fee(uint256 _pool_id, uint16 _fee_max, uint16 _fee_min, uint256 _period) external;
	function set_alloc_point(uint256 _pool_id, uint256 _alloc_point, bool _update_all) external;
	function set_emission_per_block(address _address_reward, uint256 _emission_per_block) external;
	function make_reward(address _address_reward_token, uint256 _reward_mint_start_block_id) external;
	function add_nft_booster(uint256 _pool_id, uint256 _nft_id) external;
	function remove_nft_booster(uint256 _pool_id, uint256 _nft_id) external;
	function get_nft_booster_list(uint256 _pool_id) external returns(uint256[] memory);
	function has_nft(address _address_user) external view returns(bool);
	function get_pending_reward_amount(uint256 _pool_id, address _address_user) external returns(uint256);
	function pause() external;
	function resume() external;
}

// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.17;

//---------------------------------------------------------
// Contract
//---------------------------------------------------------
interface IChick
{
	function pause() external;
	function resume() external;
	function set_address_vault(address _address_busd_vault, address _address_wbnb_vault) external;
	function set_address_token(address _address_arrow, address _address_target) external;
	function set_bnb_per_busd_vault_ratio(uint256 _bnd_ratio) external;
	function set_swap_threshold(uint256 _threshold) external;
	function handle_stuck(address _token, uint256 _amount, address _to) external;
	function make_juice() external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >= 0.8.17;

//---------------------------------------------------------
// Imports
//---------------------------------------------------------
import "./TokenXBaseV3.sol";

//---------------------------------------------------------
// Contract
//---------------------------------------------------------
contract TokenArrow is TokenXBaseV3
{
	constructor() TokenXBaseV3("ARROW on xTEN farm", "AROW")
	{
		tax_rate_send_e4 = 1000; // 10%
		tax_rate_recv_e4 = 200; // 2%

		super._mint(msg.sender, 40000 * (10 ** 18));
	}
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >= 0.8.17;

//---------------------------------------------------------
// Imports
//---------------------------------------------------------
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IChick.sol";
import "./interfaces/IBullish.sol";

//---------------------------------------------------------
// Contract
//---------------------------------------------------------
contract TokenXBaseV3 is ERC20, Ownable
{
	uint256 public constant MAX_TAX_BUY = 501; // 5%
	uint256 public constant MAX_TAX_SELL = 2001; // 20%
	uint256 public constant TAX_FREE = 8888; // 8888 means zero tax in this code

	address public constant ADDRESS_BURN = 0x000000000000000000000000000000000000dEaD;

	address public address_operator;
	address public address_controller;
	address public address_chick;

	bool private chick_work = true;
	bool private is_chick_busy = false;

	uint256 internal tax_rate_send_e4 = MAX_TAX_SELL;
	uint256 internal tax_rate_recv_e4 = MAX_TAX_BUY;
	uint256 internal tax_rate_send_with_nft_e4 = MAX_TAX_SELL;
	uint256 internal tax_rate_recv_with_nft_e4 = MAX_TAX_BUY;
	
	mapping(address => bool) private is_send_blocked;
	mapping(address => bool) private is_recv_blocked;
	mapping(address => bool) private is_sell_blocked;

	mapping(address => bool) private is_tax_free_send;
	mapping(address => bool) private is_tax_free_recv;
	mapping(address => uint256) private send_limit_amount;

	mapping(address => bool) private is_address_lp;
	mapping(address => bool) private is_internal_contract;

	//---------------------------------------------------------------
	// Front-end connectors
	//---------------------------------------------------------------
	event SetOperatorCB(address indexed operator, address _new_address_operator, address _new_address);
	event SetControllerCB(address indexed operator, address _new_address_operator, address _new_address);
	event SetChickCB(address indexed operator, address _chick);
	event SetSendTaxFreeCB(address indexed operator, address _address, bool _is_free);
	event SetRecvTaxFreeCB(address indexed operator, address _address, bool _is_free);
	event SetNativeLPAddressCB(address indexed operator, address _lp_address, bool _is_enabled);
	event SetSellAmountLimitCB(address indexed operator, address _lp_address, uint256 _limit);
	event ToggleTransferPauseCB(address indexed operator, bool _is_paused);
	event ToggleBlockSendCB(address indexed operator, address[] _accounts, bool _is_blocked);
	event ToggleBlockRecvCB(address indexed operator, address[] _accounts, bool _is_blocked);
	event SetSendTaxCB(address indexed operator, uint256 _tax_rate, uint256 _tax_with_nft_rate);
	event SetRecvTaxCB(address indexed operator, uint256 _tax_rate, uint256 _tax_with_nft_rate);
	event SetChickWorkCB(address indexed operator, bool _is_work);

	//---------------------------------------------------------------
	// Modifier
	//---------------------------------------------------------------
	modifier onlyOperator() { require(address_operator == msg.sender, "onlyOperator: caller is not the operator");	_; }
	modifier onlyController() { require(address_controller == msg.sender, "onlyController: caller is not the controller");	_; }
	modifier onlyAdmin() { require(address_operator == msg.sender || address_controller == msg.sender, "onlyAdmin: caller is not the administrator");	_; }

	//---------------------------------------------------------------
	// Setters
	//---------------------------------------------------------------
	function set_operator(address _new_address) public onlyOperator
	{
		require(_new_address != address(0), "set_operator: Wrong address");

		exchange_internal_address(address_operator, _new_address);
		address_operator = _new_address;

		emit SetOperatorCB(msg.sender, address_operator, _new_address);
	}

	function set_controller(address _new_address) public onlyOperator
	{
		require(_new_address != address(0), "set_operator: Wrong address");

		exchange_internal_address(address_controller, _new_address);
		address_controller = _new_address;

		emit SetControllerCB(msg.sender, address_operator, _new_address);
	}

	function set_chick(address _new_chick) external onlyController
	{
		require(!is_chick_busy, "set_chick: the chick is working.");

		exchange_internal_address(address_chick, _new_chick);
		address_chick = _new_chick;

		emit SetChickCB(msg.sender, address_chick);
	}

	function set_send_tax_free(address _address, bool _is_free) public onlyOperator
	{
		require(_address != address(0), "set_send_tax_free: Wrong address");
		is_tax_free_send[_address] = _is_free;
		emit SetSendTaxFreeCB(msg.sender, _address, _is_free);
	}

	function set_recv_tax_free(address _address, bool _is_free) public onlyOperator
	{
		require(_address != address(0), "set_recv_tax_free: Wrong address");
		is_tax_free_recv[_address] = _is_free;
		emit SetRecvTaxFreeCB(msg.sender, _address, _is_free);
	}

	function set_lp_address(address _lp_address, bool _is_enabled) public onlyOperator
	{
		require(_lp_address != address(0), "set_native_lp_address_list: Wrong address");
		is_address_lp[_lp_address] = _is_enabled;
		emit SetNativeLPAddressCB(msg.sender, _lp_address, _is_enabled);
	}

	function set_sell_amount_limit(address _address_to_limit, uint256 _limit) public onlyOperator
	{
		require(_address_to_limit != address(0), "set_sell_amount_limit: Wrong address");
		send_limit_amount[_address_to_limit] = _limit;
		emit SetSellAmountLimitCB(msg.sender, _address_to_limit, _limit);
	}

	function toggle_block_send(address[] memory _accounts, bool _is_blocked) external onlyOperator
	{
		for(uint256 i=0; i < _accounts.length; i++)
			is_send_blocked[_accounts[i]] = _is_blocked;
		
		emit ToggleBlockSendCB(msg.sender, _accounts, _is_blocked);
	}

	function toggle_block_recv(address[] memory _accounts, bool _is_blocked) external onlyOperator
	{
		for(uint256 i=0; i < _accounts.length; i++)
			is_recv_blocked[_accounts[i]] = _is_blocked;
		
		emit ToggleBlockRecvCB(msg.sender, _accounts, _is_blocked);
	}

	function set_send_tax_e4(uint256 _tax_rate, uint256 _tax_with_nft_rate) public onlyOperator
	{
		require(_tax_rate < MAX_TAX_SELL, "set_send_tax_e4: tax rate manimum exceeded.");
		require(_tax_with_nft_rate < MAX_TAX_SELL, "set_send_tax_e4: tax rate manimum exceeded.");

		tax_rate_send_e4 = _tax_rate;
		tax_rate_send_with_nft_e4 = _tax_with_nft_rate;
		emit SetSendTaxCB(msg.sender, _tax_rate, _tax_with_nft_rate);
	}
	
	function set_recv_tax_e4(uint256 _tax_rate, uint256 _tax_with_nft_rate) public onlyOperator
	{
		require(_tax_rate < MAX_TAX_BUY, "set_recv_tax_e4: tax rate manimum exceeded.");
		require(_tax_with_nft_rate < MAX_TAX_BUY, "set_recv_tax_e4: tax rate manimum exceeded.");

		tax_rate_recv_e4 = _tax_rate;
		tax_rate_recv_with_nft_e4 = _tax_with_nft_rate;
		emit SetRecvTaxCB(msg.sender, _tax_rate, _tax_with_nft_rate);
	}

	function set_chick_work(bool _is_work) external onlyOperator
	{
		chick_work = _is_work;
		emit SetChickWorkCB(msg.sender, _is_work);
	}

	//---------------------------------------------------------------
	// External Method
	//---------------------------------------------------------------
	constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol)
	{
		address_operator = msg.sender;

		is_tax_free_send[address_operator] = true;
		is_tax_free_recv[address_operator] = true;

		is_tax_free_send[ADDRESS_BURN] = true;
		is_tax_free_recv[ADDRESS_BURN] = true;
	}

	function mint(address _to, uint256 _amount) external onlyController
	{
		super._mint(_to, _amount);
	}

	function burn(uint256 _amount) external onlyOwner
	{
		super._burn(msg.sender, _amount);
	}

	//---------------------------------------------------------------
	// Internal Method
	//---------------------------------------------------------------
	function _transfer(address sender, address recipient, uint256 amount) internal virtual override
	{
		require(sender != address(0), "_transfer: Wrong sender address");
		require(!is_send_blocked[sender], "_transfer: Sender is blocked by contract.");

		require(recipient != address(0), "_transfer: Wrong recipient address");
		require(!is_recv_blocked[recipient], "_transfer: Recipient is blocked by contract.");

		_check_send_limit(sender, recipient, amount);

		_make_juice_by_chick(sender, recipient);
		
		uint256 cur_tax_e4 = (chick_work == false)? TAX_FREE : _get_tax_rate_e4(sender, recipient);
		
		if(cur_tax_e4 == TAX_FREE)
			super._transfer(sender, recipient, amount);
		else
		{
			uint256 tax_amount = amount * cur_tax_e4 / 1e4;
			uint256 final_send_amount = amount - tax_amount;

			super._transfer(sender, address_chick, tax_amount);
			super._transfer(sender, recipient, final_send_amount);
		}
	}

	function _make_juice_by_chick(address _from, address _to) internal
	{
		if(chick_work == true && is_chick_busy == false && address_chick != address(0x0))
		{
			if(!is_internal_contract[_from] && !is_internal_contract[_to])
			{
				IChick chick = IChick(address_chick);
				is_chick_busy = true;
					chick.make_juice();
				is_chick_busy = false;
			}
		}
	}

	function _check_send_limit(address _from, address _to, uint256 _amount) internal view
	{
		if(is_address_lp[_to]) // User -> LP // Sell
			require(_amount <= send_limit_amount[_from], "_check_send_limit: Sender is sending-limited.");
	}

	function _get_tax_rate_e4(address _from, address _to) internal view returns(uint256)
	{		
		// 지갑에서 지갑으로 전송은 sell, buy가 아닌것으로 처리
		uint256 tax_rate_e4 = TAX_FREE;

		// LP에 들어오고 나간다는 것이 sell, buy를 말함
		// LP에서 들어오고 나가는건 무조건 택스를 떼되, 
		if(is_address_lp[_from]) // LP -> User // Buy
		{
			// 사이트에서 하는건 텍스를 안 떼게
			// (중간에 넘기는 놈 LPTool을 두고 그 놈을 화이트리스트 처리)
			if(!is_tax_free_send[_from])
				tax_rate_e4 = tax_rate_send_e4;
			else if(address_controller != address(0x0))
			{
				IBullish controller = IBullish(address_controller);
				if(controller.has_nft(_to))
					tax_rate_e4 = tax_rate_send_with_nft_e4;
			}
		}
		else if(is_address_lp[_to]) // User -> LP // Sell
		{
			if(!is_tax_free_recv[_from])
				tax_rate_e4 = tax_rate_recv_e4;
			else if(address_controller != address(0x0))
			{
				IBullish controller = IBullish(address_controller);
				if(controller.has_nft(_from))
					tax_rate_e4 = tax_rate_recv_with_nft_e4;
			}
		}

		return tax_rate_e4;
	}

	function exchange_internal_address(address _address_old, address _address_new) private
	{
		if(_address_old != address(0x0))
		{
			is_internal_contract[_address_old] = false;
			is_tax_free_send[_address_old] = false;
			is_tax_free_recv[_address_old] = false;
		}

		if(_address_new != address(0x0))
		{
			is_internal_contract[_address_new] = true;
			is_tax_free_send[_address_new] = true;
			is_tax_free_recv[_address_new] = true;			
		}
	}
}