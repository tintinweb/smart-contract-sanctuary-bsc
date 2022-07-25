// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import { IAccount } from "./Accounts/Account.sol";
import { IOfficer } from "./Accounts/Officer.sol";
import { TokenInfo } from "./Accounts/Token.sol";

contract Dashboard {
	using SafeERC20 for IERC20;

	IAccount public account; 
	IOfficer public officer;

	constructor(IOfficer _officer, IAccount _account) {
		account = _account;
		officer = _officer;
	}

	// Check the connection address is registered?
	function isregistered() public returns (bool) {
		return account.isAccount(msg.sender);
	}

	modifier onlyregistered() {
		require(isregistered(), "Dashboard: not registered account yet");
		_;
	}

	/**
	 * ACCOUNT INFORMATION FOR DASHBOARD
	 */

	function balanceOfETH() public onlyregistered returns (uint256 _balanceOfETH) {
		_balanceOfETH = account.balanceOfETH(msg.sender);
	}

	struct TokenOfAccount {
		address token;
		string name;
		string symbol;
		uint256 status;
		uint256 volumeOfToken; // total volume of tokens in the contract (in project)
		uint256 balanceOfToken; // balance per account's tokens
	}

	function tokenOfAccount() public onlyregistered returns (TokenOfAccount[] memory _tokenOfAccounts) {
		(TokenInfo[] memory _availableTokens, uint256[] memory _balanceOfTokens) = account.getTokenOfAccount(
			msg.sender
		);

		for (uint256 i = 0; i < _availableTokens.length; i++) {
			TokenOfAccount memory _t;
			_t.token = _availableTokens[i].token;
			_t.name = ERC20(_availableTokens[i].token).name();
			_t.symbol = ERC20(_availableTokens[i].token).symbol();
			_t.status = _availableTokens[i].status;
			_t.volumeOfToken = _availableTokens[i].volumeOfToken;
			_t.balanceOfToken = _balanceOfTokens[i];

			_tokenOfAccounts[i] = _t;
		}
	}

	function accountAdress() public onlyregistered returns (address[] memory _accountAddress) {
		_accountAddress = account.getAccountAddress(msg.sender);
	}

	function withdrawAddress() public onlyregistered returns (address[] memory _withdrawAddress) {
		_withdrawAddress = account.getwithdrawAddress(msg.sender);
	}

	/*******************************************************************************************************/
	function accountInfo()
		public
		onlyregistered
		returns (
			uint256 _balanceOfETH,
			TokenOfAccount[] memory _tokenOfAccounts,
			address[] memory _accountAddress,
			address[] memory _withdrawAddress
		)
	{
		_balanceOfETH = balanceOfETH();
		_tokenOfAccounts = tokenOfAccount();
		_accountAddress = accountAdress();
		_withdrawAddress = withdrawAddress();
	}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
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

import { IOfficer } from "./Officer.sol";
import { TokenInfo, IToken } from "./Token.sol";
import { AddressArray } from "./Library.sol";

/**
 * ACCOUNT INFO
 */
struct AccountInfo {
	// address contractOfAccount; // One Account can many contract address.
	address[] accountAddr; // User can only login and deposit using address.
	address[] withdrawAddr; // User can only withdraw (or in bulk) with address.
	mapping(address => uint256) balanceOfTokens; // balance per supported token of the account
	uint256 balanceOfETH;
}

abstract contract AccountData {
	using AddressArray for address[];
	IToken public token;

	uint256 private numAccount; // Account ID
	mapping(uint256 => AccountInfo) private accountInfo;
	mapping(address => uint256) private accounts; // Address is already exists account

	function _isAccount(address _address) public view returns (bool) {
		return accounts[_address] != 0;
	}

	//event AccountCreated(address _address, uint256 _timestamp);

	function _creatAccount(address _address) public {
		accounts[_address] = ++numAccount;
		AccountInfo storage n = accountInfo[numAccount];
		n.accountAddr.add(_address);

		//emit AccountCreated(_address, block.timestamp);
	}

	function _getBalanceOfETH(address _accountSigned) public view returns (uint256 _balanceOfETH) {
		_balanceOfETH = accountInfo[accounts[_accountSigned]].balanceOfETH;
	}

	function _getBalanceOfTokens(address _accountSigned)
		public
		returns (TokenInfo[] memory _availableToken, uint256[] memory _balanceOfTokens)
	{
		_availableToken = token.getAvailableToken();
		for (uint256 i = 0; i < _availableToken.length; i++)
			_balanceOfTokens[i] = accountInfo[accounts[_accountSigned]].balanceOfTokens[_availableToken[i].token];
	}

	function _getAccountAddr(address _accountSigned) public view returns (address[] memory _accountAddr) {
		_accountAddr = accountInfo[accounts[_accountSigned]].accountAddr;
	}

	function _getWithdrawAddr(address _accountSigned) public view returns (address[] memory _withdrawAddr) {
		_withdrawAddr = accountInfo[accounts[_accountSigned]].withdrawAddr;
	}

	function _addAccountAddr(address _accountSigned, address _address) public returns (bool) {
		accounts[_address] = accounts[_accountSigned];
		return accountInfo[accounts[_accountSigned]].accountAddr.add(_address);
	}

	function _removeAccountAddr(address _accountSigned, address _address) public returns (bool) {
		accounts[_address] = 0;
		return accountInfo[accounts[_accountSigned]].accountAddr.remove(_address);
	}

	function _addWithdrawAddr(address _accountSigned, address _address) public returns (bool) {
		return accountInfo[accounts[_accountSigned]].withdrawAddr.add(_address);
	}

	function _removeWithdrawAddr(address _accountSigned, address _address) public returns (bool) {
		return accountInfo[accounts[_accountSigned]].withdrawAddr.remove(_address);
	}
}

/*******************************************************************************************************/

interface IAccount {
	function isAccount(address _address) external returns (bool);

	function creatAccount(address _address) external;

	function balanceOfETH(address _accountSigned) external returns (uint256 _balanceOfETH);

	function getTokenOfAccount(address _accountSigned)
		external
		returns (TokenInfo[] memory _availableTokens, uint256[] memory _balanceOfTokens);

	function getAccountAddress(address _accountSigned) external returns (address[] memory _accountAddress);

	function getwithdrawAddress(address _accountSigned) external returns (address[] memory _withdrawAddress);

	function addAccountAddress(address _accountSigned, address _address) external;

	function removeAccountAdress(address _accountSigned, address _address) external;

	function addWithdrawAddress(address _accountSigned, address _address) external;

	function removeWithdrawAddress(address _accountSigned, address _address) external;

	function depositETH(address _accountSigned, uint256 _amount) external;

	function withdrawETH(
		address _accountSigned,
		address _to,
		uint256 _amount
	) external;

	function depositToken(
		address _accountSigned,
		address _token,
		uint256 _amount
	) external;

	function withdrawToken(
		address _accountSigned,
		address _token,
		address _to,
		uint256 _amount
	) external;
}

contract Account is AccountData, IAccount {
	IOfficer public officer;

	constructor(IOfficer _officer, IToken _token) {
		officer = _officer;
		token = _token;
	}

	modifier checkAvailable() {
		require(officer.isAvailableOfficer(msg.sender), "Account: caller not available");
		require(officer.isAvailableOfficer(address(this)), "Account: this contract not available");
		_;
	}

	modifier onlyAccepted() {
		require(officer.isAccepted(msg.sender), "Account: caller not accepted");
		_;
	}

	modifier onlyGovernment() {
		require(officer.isGovernment(msg.sender), "Account: caller is not Government");
		_;
	}

	modifier onlyMonitoring() {
		require(officer.isMonitoring(msg.sender), "Account: caller is not Monitoring");
		_;
	}

	modifier onlyBridging() {
		require(officer.isBridging(msg.sender), "Account: caller is not Bridging");
		_;
	}

	modifier verifyAccount(address _accountSigned) {
		// check available Caller & This
		require(officer.isAvailableOfficer(msg.sender), "Account: caller not available");
		require(officer.isAvailableOfficer(address(this)), "Account: this contract not available");
		// only accepted Caller
		require(officer.isAccepted(msg.sender), "Account: caller not accepted");
		// Check if the address is an existing account
		require(_isAccount(_accountSigned), "Account: does not exist");
		_;
	}

	/*******************************************************************************************************/

	function isAccount(address _address) public checkAvailable onlyAccepted returns (bool) {
		return _isAccount(_address);
	}

	function creatAccount(address _address) public checkAvailable onlyAccepted {
		require(_isAccount(_address) == false, "Account: already exists another");
		require(_address.code.length == 0, "Account: address cannot contract");

		_creatAccount(_address);
	}

	/**********************************************************************************************************
	 *	ACCOUNT INFORMATION FOR DASHBOARD
	 */
	function balanceOfETH(address _accountSigned)
		public
		verifyAccount(_accountSigned)
		returns (uint256 _balanceOfETH)
	{
		_balanceOfETH = _getBalanceOfETH(_accountSigned);
	}

	function getTokenOfAccount(address _accountSigned)
		public
		verifyAccount(_accountSigned)
		returns (TokenInfo[] memory _availableTokens, uint256[] memory _balanceOfTokens)
	{
		(_availableTokens, _balanceOfTokens) = _getBalanceOfTokens(_accountSigned);
	}

	function getAccountAddress(address _accountSigned)
		public
		verifyAccount(_accountSigned)
		returns (address[] memory _accountAddress)
	{
		_accountAddress = _getAccountAddr(_accountSigned);
	}

	function getwithdrawAddress(address _accountSigned)
		public
		verifyAccount(_accountSigned)
		returns (address[] memory _withdrawAddress)
	{
		_withdrawAddress = _getWithdrawAddr(_accountSigned);
	}

	/*******************************************************************************************************/
	function addAccountAddress(address _accountSigned, address _address)
		public
		verifyAccount(_accountSigned)
	{
		require(_address.code.length == 0, "Account: address cannot contract");

		if (_isAccount(_address)) {
			// _address already exists in another account
			// Chưa xủ lý trường hợp này, tạm thời cho hoàn nguyên
			revert("Account: already exists another");
		} else {
			if (_addAccountAddr(_accountSigned, _address) == false) revert("Account: add address failed");
		}
	}

	function removeAccountAdress(address _accountSigned, address _address)
		public
		verifyAccount(_accountSigned)
	{
		if (_removeAccountAddr(_accountSigned, _address) == false) revert("Account: remove address failed");
	}

	function addWithdrawAddress(address _accountSigned, address _address)
		public
		verifyAccount(_accountSigned)
	{
		if (_addWithdrawAddr(_accountSigned, _address) == false) revert("Account: add address failed");
	}

	function removeWithdrawAddress(address _accountSigned, address _address)
		public
		verifyAccount(_accountSigned)
	{
		if (_removeWithdrawAddr(_accountSigned, _address) == false) revert("Account: remove address failed");
	}

	/**********************************************************************************************************
	 *	DEPOSIT & WITHDRAW
	 */
	function depositETH(address _accountSigned, uint256 _amount) public verifyAccount(_accountSigned) {}

	function withdrawETH(
		address _accountSigned,
		address _to,
		uint256 _amount
	) public verifyAccount(_accountSigned) {}

	function depositToken(
		address _accountSigned,
		address _token,
		uint256 _amount
	) public verifyAccount(_accountSigned) {}

	function withdrawToken(
		address _accountSigned,
		address _token,
		address _to,
		uint256 _amount
	) public verifyAccount(_accountSigned) {}

	/**********************************************************************************************************/
	// function getAccount4Monitoring() public checkAvailable onlyMonitoring returns (AccountInfo[] memory tokeninfos) {
	// 	//...
	// }

	// function getAccount4Bridging() public checkAvailable onlyBridging returns (AccountInfo[] memory tokeninfos) {
	// 	//...
	// }
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
	mapping(address => uint8) private status; // Officer status
	mapping(address => mapping(address => uint8)) private acceptedRoles; // Officer destination accepted caller with role.

	address[] private officers; // Lookup

	constructor() {
		// testing.......
		_setOfficerStatus(address(this), 1);
		_setOfficerStatus(msg.sender, 1);
		_setacceptedRole(address(this), msg.sender, 1); // Government
	}

	function _getOfficerStatus(address _officer) public view returns (uint8 officerStatus) {
		return status[_officer]; // Get the first digit of the status variable
	}

	function _isOfficer(address _officer) public view returns (bool) {
		return _getOfficerStatus(_officer) != 0; 
	}	

	function _isAvailableOfficer(address _officer) public view returns (bool) {
		return _getOfficerStatus(_officer) == 1;
	}

	function _getOfficer() public view returns (address[] memory _officers) {
		return officers;
	}

	function _getacceptedRole(address _destination, address _caller) public view returns (uint8 _acceptedRole) {
		return acceptedRoles[_destination][_caller]; // Get the first digit of the acceptedRoles variable
	}

	function _isAccepted(address _destination, address _caller) public view returns (bool) {
		return _getacceptedRole(_destination, _caller) != 0;
	}

	function _setacceptedRole(
		address _destination,
		address _caller,
		uint8 _role
	) public {
		acceptedRoles[_destination][_caller] = _role;
	}

	using AddressArray for address[];

	function _setOfficerStatus(address _officer, uint8 _status) public {
		status[_officer] = _status;
		officers.add(_officer);
	}
}

interface IOfficer {
	function isAvailableOfficer(address officer) external returns (bool);

	function getOfficerStatus() external returns (uint8 status);

	function isAccepted(address caller) external returns (bool);

	function getAcceptedRole(address caller) external returns (uint8 role);

	function isGovernment(address caller) external returns (bool);

	function isMonitoring(address caller) external returns (bool);

	function isBridging(address caller) external returns (bool);

	function setAcceptedRole(
		address destination,
		address caller,
		uint8 role
	) external;

	function setOfficerStatus(address officer, uint8 status) external;

	function getOfficer4Monitoring() external returns (address[] memory officers);

	function getOfficer4Bridging() external returns (address[] memory officers);
}

contract Officer is OfficerData, IOfficer {
	modifier checkAvailable() {
		require(_isAvailableOfficer(msg.sender), "Officer: caller not available");
		require(_isAvailableOfficer(address(this)), "Officer: this contract not available");
		_;
	}
	modifier onlyAccepted() {
		require(_isAccepted(address(this), msg.sender), "Officer: caller not accepted yet");
		_;
	}
	modifier onlyGovernment() {
		require(_getacceptedRole(address(this), msg.sender) == 1, "Officer: caller is not Government");
		_;
	}
	modifier onlyMonitoring() {
		require(_getacceptedRole(address(this), msg.sender) == 2, "Officer: caller is not Monitoring");
		_;
	}
	modifier onlyBridging() {
		require(_getacceptedRole(address(this), msg.sender) == 3, "Officer: caller is not Bridging");
		_;
	}

	/*******************************************************************************************************/

	function isAvailableOfficer(address officer) public view checkAvailable onlyAccepted returns (bool) {
		return _isAvailableOfficer(officer);
	}

	function getOfficerStatus() public view checkAvailable onlyAccepted returns (uint8 status) {
		return _getOfficerStatus(msg.sender); // Can only get your own status
	}

	function isAccepted(address caller) public view checkAvailable onlyAccepted returns (bool) {
		return _isAccepted(msg.sender, caller);
	}

	function getAcceptedRole(address caller) public view checkAvailable onlyAccepted returns (uint8 role) {
		return _getacceptedRole(msg.sender, caller); // Can only get role of caller
	}

	function isGovernment(address caller) public view checkAvailable onlyAccepted returns (bool) {
		return _getacceptedRole(msg.sender, caller) == 1;
	}

	function isMonitoring(address caller) public view checkAvailable onlyAccepted returns (bool) {
		return _getacceptedRole(msg.sender, caller) == 2;
	}

	function isBridging(address caller) public view checkAvailable onlyAccepted returns (bool) {
		return _getacceptedRole(msg.sender, caller) == 3;
	}

	/*******************************************************************************************************/

	function setAcceptedRole(
		address destination,
		address caller,
		uint8 role
	) public checkAvailable onlyGovernment {
		require(destination != address(0) && _isAvailableOfficer(destination), "Officer: destination not available");
		require(caller != address(0) && _isAvailableOfficer(caller), "Officer: caller not available");
		_setacceptedRole(destination, caller, role); // role >= 4
	}

	function setOfficerStatus(address officer, uint8 status) public checkAvailable onlyGovernment {
		require(officer != address(0), "Officer: cannot zero address");
		_setOfficerStatus(officer, status);
	}

	function getOfficer4Monitoring() public view checkAvailable onlyMonitoring returns (address[] memory officers) {
		officers = _getOfficer();
		//...
	}

	function getOfficer4Bridging() public view checkAvailable onlyBridging returns (address[] memory officers) {
		officers = _getOfficer();
		//...
	}
}

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
		return ((tokens[_token].token == _token) && (tokens[_token].chainid == block.chainid));
	}

	function _getStatusToken(address _token) public view returns (uint8 _status) {
		return tokens[_token].status; // Get the first digit of the status variable
	}

	function _isAvailableToken(address _token) public view returns (bool) {
		uint8 _status = _getStatusToken(_token);
		return (_isToken(_token) && (_status == 1 || _status == 2 || _status == 3));
	}

	function _canDepositToken(address _token) public view returns (bool) {
		return (_isToken(_token) && _getStatusToken(_token) == 1);
	}

	function _canWithdrawToken(address _token) public view returns (bool) {
		return ((_isToken(_token) && (_getStatusToken(_token) == 1)) || _getStatusToken(_token) == 2);
	}

	function _getToken(address _token) public view returns (TokenInfo memory) {
		return tokens[_token];
	}

	function _getToken() public view returns (TokenInfo[] memory _tokeninfos) {
		_tokeninfos = new TokenInfo[](lookup.length);
		for (uint256 i = 0; i < lookup.length; i++) _tokeninfos[i] = tokens[lookup[i]];
	}

	// Dashboard view
	function _getAvailableToken() public view returns (TokenInfo[] memory _tokeninfos) {
		uint256 k = 0;
		for (uint256 i = 0; i < lookup.length; i++) if (_isAvailableToken(lookup[i])) _tokeninfos[k++] = tokens[lookup[i]];
	}

	event TokenAddUpdated(address _token, uint256 _timestamp);
	event TokenDeposited(address _token, uint256 _amount, uint256 _timestamp);
	event TokenWithdrawed(address _token, uint256 _amount, uint256 _timestamp);

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
			} else revert("Token: Add Update failed");
		}

		emit TokenAddUpdated(_token, block.timestamp);
	}

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
}

interface IToken {
	function getAvailableToken(address token) external returns (TokenInfo memory tokeninfo);

	function getAvailableToken() external returns (TokenInfo[] memory tokeninfos);

	function tokenDeposit(address token, uint256 amount) external;

	function tokenWithdraw(address token, uint256 amount) external;

	function addUpdateToken(ERC20 token, uint8 status) external;

	function getToken4Monitoring() external returns (TokenInfo[] memory tokeninfos);

	function getToken4Bridging() external returns (TokenInfo[] memory tokeninfos);
}

contract Token is TokenData, IToken {
	IOfficer public officer;

	constructor(IOfficer _officer) {
		officer = _officer;
	}

	modifier checkAvailable() {
		require(officer.isAvailableOfficer(msg.sender), "Token: caller not available");
		require(officer.isAvailableOfficer(address(this)), "Token: this contract not available");
		_;
	}

	modifier onlyAccepted() {
		require(officer.isAccepted(msg.sender), "Token: caller not accepted");
		_;
	}

	modifier onlyGovernment() {
		require(officer.isGovernment(msg.sender), "Token: caller is not Government");
		_;
	}

	modifier onlyMonitoring() {
		require(officer.isMonitoring(msg.sender), "Token: caller is not Monitoring");
		_;
	}

	modifier onlyBridging() {
		require(officer.isBridging(msg.sender), "Token: caller is not Bridging");
		_;
	}

	/*******************************************************************************************************/

	// Dashboard view
	function getAvailableToken() public checkAvailable onlyAccepted returns (TokenInfo[] memory tokeninfos) {
		tokeninfos = _getAvailableToken();
	}

	function tokenDeposit(address token, uint256 amount) public checkAvailable onlyAccepted {
		require(amount > 0, "Token: amount need more than 0");
		require(_isAvailableToken(token) && _canDepositToken(token), "Token: deposit not allowed");

		_tokenDeposit(token, amount);
	}

	function tokenWithdraw(address token, uint256 amount) public checkAvailable onlyAccepted {
		require(amount > 0, "Token: amount need more than 0");
		require(_isAvailableToken(token) && _canWithdrawToken(token), "Token: withdraw not allowed");

		_tokenWithdraw(token, amount);
	}

	/*******************************************************************************************************/

	// Officer can check token info
	function getAvailableToken(address token) public checkAvailable onlyAccepted returns (TokenInfo memory tokeninfo) {
		require(_isAvailableToken(token), "Token: not supported or available");
		tokeninfo = _getToken(token);
	}

	function addUpdateToken(ERC20 token, uint8 status) public checkAvailable onlyGovernment {
		require(address(token) != address(0), "Token: can not zero address");
		require(address(token).code.length > 0, "Token: must be contract");
		_addUpdateToken(address(token), status);
	}

	function getToken4Monitoring() public checkAvailable onlyMonitoring returns (TokenInfo[] memory tokeninfos) {
		tokeninfos = _getToken();
		//...
	}

	function getToken4Bridging() public checkAvailable onlyBridging returns (TokenInfo[] memory tokeninfos) {
		tokeninfos = _getToken();
		//...
	}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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
                /// @solidity memory-safe-assembly
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