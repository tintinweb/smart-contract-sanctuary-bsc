// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol';
import './IFCoin.sol';
import '../controller/IController.sol';


contract FCoin is IERC20, IERC20Metadata, IFCoin
{


string private _name;
string private _symbol;

mapping(address => uint256) private _balances;

// Modules
IController public immutable CONTROLLER;
address public aPlayers;
address public aCars;
address public aRaces;
bool private _initialized;


constructor(string memory name_, string memory symbol_, address controller_, address mintTo_, uint mintAmount_)
{
	_name = name_;
	_symbol = symbol_;

	CONTROLLER = IController(controller_);

	// Optional initial mint
	if (mintTo_ != address(0) && mintAmount_ > 0)
		_mint(mintTo_, mintAmount_);
}

function init() external
{
	require(!_initialized, 'FCC: initialized');

	aPlayers = CONTROLLER.aPlayers();
	aCars = CONTROLLER.aCars();
	aRaces = CONTROLLER.aRaces();

	_initialized = true;
}


function _isManager(address account) private view returns(bool)
{
	return account == aPlayers
		|| account == aCars
		|| account == aRaces;
}

function fcMint(address to, uint amount) external
{
	require(_isManager(msg.sender), 'FCC: not allowed');
	_mint(to, amount);
}

function fcBurn(address from, uint amount) external
{
	require(_isManager(msg.sender), 'FCC: not allowed');
	_burn(from, amount);
}

function fcTransfer(address from, address to, uint amount) external
{
	require(_isManager(msg.sender) || (msg.sender == from && CONTROLLER.isAdmin(from)),
		'FCC: not allowed');
	_transfer(from, to, amount);
}


function name() public view virtual override returns (string memory)
{ return _name; }

function symbol() public view virtual override returns (string memory)
{ return _symbol; }

function decimals() public view virtual override returns (uint8)
{ return 18; }

function totalSupply() public view virtual override returns (uint256)
{ return 1000000000 ether; }

function balanceOf(address account) public view virtual override returns (uint256)
{ return _balances[account]; }

function transfer(address to, uint256 amount) public virtual override returns (bool)
{ require(false, 'FCC: disabled'); return false; }

function allowance(address owner, address spender) public view virtual override returns (uint256)
{ return 0; }

function approve(address spender, uint256 amount) public virtual override returns (bool)
{ require(false, 'FCC: disabled'); return false; }

function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool)
{ require(false, 'FCC: disabled'); return false; }

function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool)
{ require(false, 'FCC: disabled'); return false; }

function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool)
{ require(false, 'FCC: disabled'); return false; }

function _transfer(address from, address to, uint256 amount) internal virtual
{
	require(to != address(0), 'ERC20: transfer to the zero address');

	require(_balances[from] >= amount, 'ERC20: transfer amount exceeds balance');
	unchecked {
		_balances[from] -= amount;
	}
	_balances[to] += amount;

	emit Transfer(from, to, amount);
}

function _mint(address account, uint256 amount) internal virtual
{
	require(account != address(0), 'ERC20: mint to the zero address');

	_balances[account] += amount;
	emit Transfer(address(0), account, amount);
}

function _burn(address account, uint256 amount) internal virtual
{
	require(_balances[account] >= amount, 'ERC20: burn amount exceeds balance');
	unchecked {
		_balances[account] -= amount;
	}

	emit Transfer(account, address(0), amount);
}


}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


interface IFCoin
{
	function fcMint(address to, uint amount) external;
	function fcBurn(address from, uint amount) external;
	function fcTransfer(address from, address to, uint amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


interface IController
{
	function aFCG() external view returns(address);
	function aFCC() external view returns(address);
	function aPlayers() external view returns(address);
	function aCars() external view returns(address);
	function aRaces() external view returns(address);

	function isOwner(address account) external view returns(bool);
	function isAdmin(address account) external view returns(bool);
	function isModer(address account) external view returns(bool);
	function isDispatcher(address account) external view returns(bool);
	function isRelayer(address account) external view returns(bool);

	function onlyDispatcher(address account) external view;
	function onlyRelayer(address account) external view;

	function fccToFcgExchangeEnabled() external view returns(bool);
	function fcgToFccExchangeEnabled() external view returns(bool);
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