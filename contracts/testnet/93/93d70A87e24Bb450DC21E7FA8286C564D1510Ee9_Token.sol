// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { IOfficer } from "./Officer.sol";
import { AddressArray } from "./Library.sol";

struct TokenInfo {
	/**
	 * Status: uint status
	 * 0: Default value. Token is being checked (not available to use).
	 * 1: Available (supported) - Token status allows to use (user can Deposit & Withdraw).
	 * 2: Stoped - Withdraw only. Token will be suspend.
	 * 3: paused - Tokens are still supported, but users are temporarily unable to withdraw and deposit for a short time.
	 * 4: suspended - discontinued. No longer available.
	 * ... : Other extended state.
	 */
	address token; // Address of token supported.
	uint256 chainid; // For providing off-chain services and for statistics.
	uint8 status; // More component states are possible with the SHIFT (Bitwise) operator, instead of just one.
	uint256 volumeOfToken; // total volume of tokens in the contract (in project)
}

abstract contract TokenData {
	mapping(address => TokenInfo) private tokens;
	address[] private lookup;

	function _isToken(address _token) public view returns (bool) {
		require(_token != address(0), "Token: can not zero address");
		return ((tokens[_token].token == _token) && (tokens[_token].chainid == block.chainid));
	}

	function _getStatusToken(address _token) public view returns (uint8 _status) {
		return tokens[_token].status; // Get the first digit of the status variable
	}

	function _isAvailableToken(address _token) public view returns (bool) {
		uint8 _status = _getStatusToken(_token);
		return (_isToken(_token) && (_status == 1 || _status == 2 || _status == 3));
	}

	function _getToken(address _token) public view returns (TokenInfo memory) {
		return tokens[_token];
	}

	function _getToken() public view returns (TokenInfo[] memory _tokeninfo) {
		_tokeninfo = new TokenInfo[](lookup.length);
		for (uint256 i = 0; i < lookup.length; i++) _tokeninfo[i] = tokens[lookup[i]];
	}

	event TokenDeposited(address _token, uint256 _amount, uint256 _timestamp);
	event TokenWithdrawed(address _token, uint256 _amount, uint256 _timestamp);
	event TokenAddUpdated(address _token, uint256 _timestamp);

	function _tokenDeposit(address _token, uint256 _amount) public {
		uint256 _oldvolume = tokens[_token].volumeOfToken;
		tokens[_token].volumeOfToken += _amount;
		if (tokens[_token].volumeOfToken != _oldvolume + _amount) revert("Token: deposit failed");

		emit TokenDeposited(_token, _amount, block.timestamp);
	}

	function _tokenWithdraw(address _token, uint256 _amount) public {
		uint256 _oldvolume = tokens[_token].volumeOfToken;
		if (_oldvolume >= _amount) tokens[_token].volumeOfToken -= _amount;
		else revert("Token: insufficient balance");
		if (tokens[_token].volumeOfToken != _oldvolume - _amount) revert("Token: withdraw failed");

		emit TokenWithdrawed(_token, _amount, block.timestamp);
	}

	using AddressArray for address[];

	// Everyone can not modify balanceOfToken
	function _addUpdateToken(address _token, uint8 _status) public {
		if (_isToken(_token)) {
			// Update exits token
			if (tokens[_token].status != _status) tokens[_token].status = _status;
		} else {
			// Add new token
			if (lookup.add(_token)) {
				tokens[_token] = TokenInfo(_token, block.chainid, _status, 0);
			} else revert("Token: already exists, add Update failed");
		}

		emit TokenAddUpdated(_token, block.timestamp);
	}
}

interface IToken {
	function getAvailableToken(address token) external returns (TokenInfo memory tokeninfo);

	function getAvailableToken() external returns (TokenInfo[] memory tokeninfo);

	function tokenDeposit(address token, uint256 amount) external;

	function tokenWithdraw(address token, uint256 amount) external;
}

contract Token is TokenData, IToken {
	IOfficer public officer;

	constructor(IOfficer _officer) {
		officer = _officer;
	}

	modifier onlyAccepted() {
		require(officer.isAvailableOfficer(msg.sender), "Token: caller not available");
		require(officer.isAvailableOfficer(address(this)), "Token: this contract not available");
		require(officer.isAccepted(msg.sender), "Token: caller not accepted");
		_;
	}

	/** --------------------------------------------------------------------------- */

	function getAvailableToken(address token) public onlyAccepted returns (TokenInfo memory tokeninfo) {
		require(_isAvailableToken(token), "Token: not supported or available");
		tokeninfo = _getToken(token);
	}

	// Dashboard view
	function getAvailableToken() public onlyAccepted returns (TokenInfo[] memory tokeninfo) {
		TokenInfo[] memory _token = _getToken();
		uint256 k = 0;
		for (uint256 i = 0; i < _token.length; i++) if (_isAvailableToken(_token[i].token)) tokeninfo[k++] = _token[i];
	}

	function tokenDeposit(address token, uint256 amount) public onlyAccepted {
		require(amount > 0, "Token: amount need more than 0");
		require(_isAvailableToken(token), "Token: not available");
		require(_getStatusToken(token) == 1, "Token: deposit not allowed"); // can deposit

		_tokenDeposit(token, amount);
	}

	function tokenWithdraw(address token, uint256 amount) public onlyAccepted {
		require(amount > 0, "Token: amount need more than 0");
		require(_isAvailableToken(token), "Token: not available");
		require(_getStatusToken(token) == 1 || _getStatusToken(token) == 2, "Token: withdraw not allowed"); // can withdraw

		_tokenWithdraw(token, amount);
	}

	/** --------------------------------------------------------------------------- */

	function addUpdateToken(ERC20 token, uint8 status) public onlyAccepted {
		require(officer.isGovernment(msg.sender), "Token: caller is not Government");
		require(address(token) != address(0), "Token: can not zero address");
		require(address(token).code.length > 0, "Token: must be contract");
		_addUpdateToken(address(token), status);
	}

	function getToken4Monitoring() public onlyAccepted returns (TokenInfo[] memory tokeninfos) {
		require(officer.isMonitoring(msg.sender), "Token: caller is not Monitoring");
		tokeninfos = _getToken();
		//...
	}

	function getToken4Bridging() public onlyAccepted returns (TokenInfo[] memory tokeninfos) {
		require(officer.isBridging(msg.sender), "Token: caller is not Bridging");
		tokeninfos = _getToken();
		//...
	}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

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

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.15;

import { AddressArray } from "./Library.sol";

abstract contract OfficerData {
	/**
	 * Status:
	 * 0: Default value. Contract is being checked (not available to use).
	 * 1: Available - Office contract is available.
	 * 2: Paused / Stoped - Contracts are still supported, but users will not be able to use for a short time.
	 * 3: suspended - discontinued. No longer available.
	 * ... : Other extended state.
	 **/

	// STATUS & ROLE: More component states are possible with the SHIFT operator, instead of just one.
	mapping(address => uint256) private status; // Officer status
	mapping(address => mapping(address => uint256)) private acceptedRoles; // Officer destination accepted caller with role.

	address[] private officers; // Lookup

	constructor() {
		// testing.......
		_setOfficerStatus(address(this), 1);
		_setOfficerStatus(msg.sender, 1);
		_setAcceptedRole(address(this), msg.sender, 369000001); // Government
	}

	function _getOfficerStatus(address _officer) internal view returns (uint256 officerStatus) {
		require(_officer != address(0), "Officer: cannot zero address");
		return status[_officer]; // Get the first digit of the status variable
	}

	function _isAvailableOfficer(address _officer) internal view returns (bool) {
		return _getOfficerStatus(_officer) == 1;
	}

	function _getOfficer() internal view returns (address[] memory _officers) {
		return officers;
	}

	/** --------------------------------------------------------------------------- */
	function _getacceptedRole(address _destination, address _caller) internal view returns (uint256 _acceptedRole) {
		require(_destination != address(0) && _caller != address(0), "Officer: cannot zero address");
		return acceptedRoles[_destination][_caller]; // Get the first digit of the acceptedRoles variable
	}

	function _isGovernment(address _destination, address _caller) internal view returns (bool) {
		return _getacceptedRole(_destination, _caller) == 369000001; // XXXYYYZZZ
	}

	function _isMonitoring(address _destination, address _caller) internal view returns (bool) {
		return _getacceptedRole(_destination, _caller) == 369000002;
	}

	function _isBridging(address _destination, address _caller) internal view returns (bool) {
		return _getacceptedRole(_destination, _caller) == 369000003;
	}

	/** --------------------------------------------------------------------------- */
	using AddressArray for address[];

	function _setOfficerStatus(address _officer, uint256 _status) internal {
		require(_officer != address(0), "Officer: cannot zero address");
		status[_officer] = _status;
		officers.add(_officer);
	}

	function _setAcceptedRole(
		address _destination,
		address _caller,
		uint256 _role
	) internal {
		require(_isAvailableOfficer(_destination), "Officer: destination not available");
		require(_isAvailableOfficer(_caller), "Officer: caller not available");
		acceptedRoles[_destination][_caller] = _role;
	}
}

interface IOfficer {
	function isAvailableOfficer(address officer) external returns (bool);

	function getOfficerStatus() external returns (uint256 status);

	function isAccepted(address caller) external returns (bool);

	function getAcceptedRole(address caller) external returns (uint256 role);

	function isGovernment(address caller) external returns (bool);

	function isMonitoring(address caller) external returns (bool);

	function isBridging(address caller) external returns (bool);
}

contract Officer is OfficerData, IOfficer {
	modifier onlyAccepted() {
		require(_isAvailableOfficer(msg.sender), "Officer: caller is not available");
		require(_isAvailableOfficer(address(this)), "Officer: this contract not available");
		require(_getacceptedRole(address(this), msg.sender) != 0, "Officer: caller not accepted yet");
		_;
	}

	/** --------------------------------------------------------------------------- */

	function isAvailableOfficer(address officer) external view onlyAccepted returns (bool) {
		return _isAvailableOfficer(officer);
	}

	function getOfficerStatus() external view virtual onlyAccepted returns (uint256 status) {
		return _getOfficerStatus(msg.sender); // Can only get your own status
	}

	function isAccepted(address caller) external view onlyAccepted returns (bool) {
		return _getacceptedRole(msg.sender, caller) != 0;
	}

	function getAcceptedRole(address caller) external view virtual onlyAccepted returns (uint256 role) {
		return _getacceptedRole(msg.sender, caller); // Can only get role of caller
	}

	function isGovernment(address caller) external view onlyAccepted returns (bool) {
		return _isGovernment(msg.sender, caller);
	}

	function isMonitoring(address caller) external view onlyAccepted returns (bool) {
		return _isMonitoring(msg.sender, caller);
	}

	function isBridging(address caller) external view onlyAccepted returns (bool) {
		return _isBridging(msg.sender, caller);
	}

	/** --------------------------------------------------------------------------- */
	function setOfficerStatus(address officer, uint256 status) public virtual onlyAccepted {
		require(_isGovernment(address(this), msg.sender), "Officer: caller is not Government");
		_setOfficerStatus(officer, status);
	}

	function setOfficerAcceptedRole(
		address destination,
		address caller,
		uint256 role
	) public virtual onlyAccepted {
		require(_isGovernment(address(this), msg.sender), "Officer: caller is not Government");
		_setAcceptedRole(destination, caller, role); // != 0 = Accepted
	}

	function checking(address destination, address caller)
		public
		view
		onlyAccepted
		returns (
			uint256 destination_Status,
			uint256 caller_Status,
			uint256 role_
		)
	{
		require(_isGovernment(address(this), msg.sender), "Officer: caller is not Government");
		destination_Status = _getOfficerStatus(destination);
		caller_Status = _getOfficerStatus(caller);
		role_ = _getacceptedRole(destination, caller);
	}

	function Monitoring() external view virtual onlyAccepted returns (address[] memory officers) {
		require(_isMonitoring(address(this), msg.sender), "Officer: caller is not Monitoring");
		officers = _getOfficer();
		//...
	}

	function Bridging() external view virtual onlyAccepted returns (address[] memory officers) {
		require(_isBridging(address(this), msg.sender), "Officer: caller is not Bridging");
		officers = _getOfficer();
		//...
	}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

library AddressArray {
	function remove(address[] storage _array, address _address) internal returns (bool) {
		require(_array.length > 0, "Can't remove from empty array");
		uint256 _oldlength = _array.length;
		// Move the last element into the place to delete
		for (uint256 i = 0; i < _array.length; i++) {
			if (_array[i] == _address) {
				_array[i] = _array[_array.length - 1];
				break;
			}
		}
		// Remove
		_array.pop();
		// Confirm remove
		return (_array.length == _oldlength - 1) ? true : false;
	}

	function add(address[] storage _array, address _address) internal returns (bool) {
		uint256 _oldlength = _array.length;
		// Check exists
		bool _existed = false;
		for (uint256 i = 0; i < _array.length; i++) {
			if (_array[i] == _address) {
				_existed = true;
				break;
			}
		}
		// Add
		if (_existed == false) _array.push(_address);
		// Confirm add
		return ((_array.length == _oldlength + 1) && _array[_array.length - 1] == _address) ? true : false;
	}
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