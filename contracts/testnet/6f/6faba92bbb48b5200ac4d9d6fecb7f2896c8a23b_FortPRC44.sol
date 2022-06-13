/**
 *Submitted for verification at BscScan.com on 2022-06-13
*/

// Sources flattened with hardhat v2.5.0 https://hardhat.org

// File @openzeppelin/contracts/token/ERC20/[email protected]

// SPDX-License-Identifier: MIT

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


// File @openzeppelin/contracts/token/ERC20/extensions/[email protected]

// MIT

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


// File contracts/libs/SimpleERC20.sol

// MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;
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
abstract contract SimpleERC20 is IERC20, IERC20Metadata {
    mapping(address => uint256) _balances;

    mapping(address => mapping(address => uint256)) _allowances;

    uint256 _totalSupply;

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() external view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) external view virtual override returns (uint256) {
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
    function transfer(address to, uint256 amount) external virtual override returns (bool) {
        _transfer(msg.sender, to, amount);
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
    function approve(address spender, uint256 amount) external virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
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
        _spendAllowance(from, msg.sender, amount);
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
    function increaseAllowance(address spender, uint256 addedValue) external virtual returns (bool) {
        _approve(msg.sender, spender, allowance(msg.sender, spender) + addedValue);
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
    function decreaseAllowance(address spender, uint256 subtractedValue) external virtual returns (bool) {
        uint256 currentAllowance = allowance(msg.sender, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(msg.sender, spender, currentAllowance - subtractedValue);
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

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);
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

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
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

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
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
}


// File contracts/interfaces/IFortMapping.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;

/// @dev The interface defines methods for Fort builtin contract address mapping
interface IFortMapping {

    /// @dev Set the built-in contract address of the system
    /// @param dcuToken Address of dcu token contract
    /// @param fortDAO IFortDAO implementation contract address
    /// @param fortOptions IFortOptions implementation contract address
    /// @param fortFutures IFortFutures implementation contract address
    /// @param fortVaultForStaking IFortVaultForStaking implementation contract address
    /// @param nestPriceFacade INestPriceFacade implementation contract address
    function setBuiltinAddress(
        address dcuToken,
        address fortDAO,
        address fortOptions,
        address fortFutures,
        address fortVaultForStaking,
        address nestPriceFacade
    ) external;

    /// @dev Get the built-in contract address of the system
    /// @return dcuToken Address of dcu token contract
    /// @return fortDAO IFortDAO implementation contract address
    /// @return fortOptions IFortOptions implementation contract address
    /// @return fortFutures IFortFutures implementation contract address
    /// @return fortVaultForStaking IFortVaultForStaking implementation contract address
    /// @return nestPriceFacade INestPriceFacade implementation contract address
    function getBuiltinAddress() external view returns (
        address dcuToken,
        address fortDAO,
        address fortOptions,
        address fortFutures,
        address fortVaultForStaking,
        address nestPriceFacade
    );

    /// @dev Get address of dcu token contract
    /// @return Address of dcu token contract
    function getDCUTokenAddress() external view returns (address);

    /// @dev Get IFortDAO implementation contract address
    /// @return IFortDAO implementation contract address
    function getHedgeDAOAddress() external view returns (address);

    /// @dev Get IFortOptions implementation contract address
    /// @return IFortOptions implementation contract address
    function getHedgeOptionsAddress() external view returns (address);

    /// @dev Get IFortFutures implementation contract address
    /// @return IFortFutures implementation contract address
    function getHedgeFuturesAddress() external view returns (address);

    /// @dev Get IFortVaultForStaking implementation contract address
    /// @return IFortVaultForStaking implementation contract address
    function getHedgeVaultForStakingAddress() external view returns (address);

    /// @dev Get INestPriceFacade implementation contract address
    /// @return INestPriceFacade implementation contract address
    function getNestPriceFacade() external view returns (address);

    /// @dev Registered address. The address registered here is the address accepted by Fort system
    /// @param key The key
    /// @param addr Destination address. 0 means to delete the registration information
    function registerAddress(string calldata key, address addr) external;

    /// @dev Get registered address
    /// @param key The key
    /// @return Destination address. 0 means empty
    function checkAddress(string calldata key) external view returns (address);
}


// File contracts/interfaces/IFortGovernance.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;
/// @dev This interface defines the governance methods
interface IFortGovernance is IFortMapping {

    /// @dev Set governance authority
    /// @param addr Destination address
    /// @param flag Weight. 0 means to delete the governance permission of the target address. Weight is not 
    ///        implemented in the current system, only the difference between authorized and unauthorized. 
    ///        Here, a uint96 is used to represent the weight, which is only reserved for expansion
    function setGovernance(address addr, uint flag) external;

    /// @dev Get governance rights
    /// @param addr Destination address
    /// @return Weight. 0 means to delete the governance permission of the target address. Weight is not 
    ///        implemented in the current system, only the difference between authorized and unauthorized. 
    ///        Here, a uint96 is used to represent the weight, which is only reserved for expansion
    function getGovernance(address addr) external view returns (uint);

    /// @dev Check whether the target address has governance rights for the given target
    /// @param addr Destination address
    /// @param flag Permission weight. The permission of the target address must be greater than this weight 
    /// to pass the check
    /// @return True indicates permission
    function checkGovernance(address addr, uint flag) external view returns (bool);
}


// File contracts/FortBase.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;
/// @dev Base contract of Fort
contract FortBase {

    /// @dev IFortGovernance implementation contract address
    address public _governance;

    /// @dev To support open-zeppelin/upgrades
    /// @param governance IFortGovernance implementation contract address
    function initialize(address governance) public virtual {
        require(_governance == address(0), "Fort:!initialize");
        _governance = governance;
    }

    /// @dev Rewritten in the implementation contract, for load other contract addresses. Call 
    ///      super.update(newGovernance) when overriding, and override method without onlyGovernance
    /// @param newGovernance IFortGovernance implementation contract address
    function update(address newGovernance) public virtual {

        address governance = _governance;
        require(governance == msg.sender || IFortGovernance(governance).checkGovernance(msg.sender, 0), "Fort:!gov");
        _governance = newGovernance;
    }

    //---------modifier------------

    modifier onlyGovernance() {
        require(IFortGovernance(_governance).checkGovernance(msg.sender, 0), "Fort:!gov");
        _;
    }
}


// File contracts/custom/FortFrequentlyUsed.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;
// /// @dev This contract include frequently used data
// contract FortFrequentlyUsed is FortBase {

//     // Address of DCU contract
//     address constant DCU_TOKEN_ADDRESS = 0xf56c6eCE0C0d6Fbb9A53282C0DF71dBFaFA933eF;

//     // Address of NestOpenPrice contract
//     address constant NEST_OPEN_PRICE = 0xE544cF993C7d477C7ef8E91D28aCA250D135aa03;
    
//     // USDT base
//     uint constant USDT_BASE = 1 ether;
// }

/// @dev This contract include frequently used data
contract FortFrequentlyUsed is FortBase {

    // Address of DCU contract
    address DCU_TOKEN_ADDRESS;

    // Address of NestOpenPrice contract
    address NEST_OPEN_PRICE;
    
    address USDT_TOKEN_ADDRESS;

    // USDT base
    uint constant USDT_BASE = 1 ether;

    // TODO:
    /// @dev Rewritten in the implementation contract, for load other contract addresses. Call 
    ///      super.update(newGovernance) when overriding, and override method without onlyGovernance
    /// @param newGovernance IFortGovernance implementation contract address
    function update(address newGovernance) public override {

        super.update(newGovernance);
        (
            DCU_TOKEN_ADDRESS,//address dcuToken,
            ,//address fortDAO,
            ,//address fortOptions,
            ,//address fortFutures,
            ,//address fortVaultForStaking,
            NEST_OPEN_PRICE //address nestPriceFacade
        ) = IFortGovernance(newGovernance).getBuiltinAddress();
    }
}


// File contracts/FortPRCToken.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;
/// @dev Guarantee
contract FortPRCToken is FortFrequentlyUsed, SimpleERC20 {

    /// @dev Mining permission flag change event
    /// @param account Target address
    /// @param oldFlag Old flag
    /// @param newFlag New flag
    event MinterChanged(address account, uint oldFlag, uint newFlag);

    // Flags for account
    mapping(address=>uint) _flags;

    constructor() {
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public pure virtual override returns (string memory) {
        return "Probability Coin";
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public pure virtual override returns (string memory) {
        return "PRC";
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
    function decimals() public pure virtual override returns (uint8) {
        return 18;
    }

    /// @dev Set mining permission flag
    /// @param account Target address
    /// @param flag Mining permission flag
    function setMinter(address account, uint flag) external onlyGovernance {
        emit MinterChanged(account, _flags[account], flag);
        _flags[account] = flag;
    }

    /// @dev Check mining permission flag
    /// @param account Target address
    /// @return flag Mining permission flag
    function checkMinter(address account) external view returns (uint) {
        return _flags[account];
    }

    /// @dev Mint FortRPC
    /// @param to Target address
    /// @param value Mint amount
    function mint(address to, uint value) external {
        require(_flags[msg.sender] & 0x01 == 0x01, "FortRPC:!mint");
        _mint(to, value);
    }

    /// @dev Burn FortRPC
    /// @param from Target address
    /// @param value Burn amount
    function burn(address from, uint value) external {
        require(_flags[msg.sender] & 0x02 == 0x02, "FortRPC:!burn");
        _burn(from, value);
    }
}


// File @openzeppelin/contracts/utils/[email protected]

// MIT

pragma solidity ^0.8.0;

/*
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


// File @openzeppelin/contracts/token/ERC20/[email protected]

// MIT

pragma solidity ^0.8.0;



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
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
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
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
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


// File contracts/DCU.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;
/// @dev DCU token
contract DCU is FortBase, ERC20("Decentralized Currency Unit", "DCU") {

    // Flags for account
    mapping(address=>uint) _minters;

    constructor() {
    }

    modifier onlyMinter {
        require(_minters[msg.sender] == 1, "DCU:not minter");
        _;
    }

    /// @dev Set mining permission flag
    /// @param account Target address
    /// @param flag Mining permission flag
    function setMinter(address account, uint flag) external onlyGovernance {
        _minters[account] = flag;
    }

    /// @dev Check mining permission flag
    /// @param account Target address
    /// @return flag Mining permission flag
    function checkMinter(address account) external view returns (uint) {
        return _minters[account];
    }

    /// @dev Mint DCU
    /// @param to Target address
    /// @param value Mint amount
    function mint(address to, uint value) external onlyMinter {
        _mint(to, value);
    }

    /// @dev Burn DCU
    /// @param from Target address
    /// @param value Burn amount
    function burn(address from, uint value) external onlyMinter {
        _burn(from, value);
    }
}


// File contracts/FortPRC.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;
/// @dev Guarantee
contract FortPRC is FortPRCToken {

    // Roll dice structure
    struct Dice {
        address owner;
        uint32 n;
        uint32 m;
        uint32 openBlock;
    }

    // Roll dice information view
    struct DiceView {
        uint index;
        address owner;
        uint32 n;
        uint32 m;
        uint32 openBlock;
        uint gained;
    }

    // The span from current block to hash block
    uint constant OPEN_BLOCK_SPAN = 1;
    // Times base, 4 decimals
    uint constant TIMES_BASE = 10000;
    // Max times, 100000.0000. [1.0000, 100000.0000]
    uint constant MAX_M = 100000 * TIMES_BASE;

    // Roll dice array
    Dice[] _dices;

    /// @dev Find the dices of the target address (in reverse order)
    /// @param start Find forward from the index corresponding to the given contract address 
    /// (excluding the record corresponding to start)
    /// @param count Maximum number of records returned
    /// @param maxFindCount Find records at most
    /// @param owner Target address
    /// @return diceArray Matched dice array
    function find(
        uint start, 
        uint count, 
        uint maxFindCount, 
        address owner
    ) external view returns (DiceView[] memory diceArray) {
        
        diceArray = new DiceView[](count);
        
        // Calculate search region
        Dice[] storage dices = _dices;
        uint i = dices.length;
        uint end = 0;
        if (start > 0) {
            i = start;
        }
        if (i > maxFindCount) {
            end = i - maxFindCount;
        }
        
        // Loop lookup to write qualified records to the buffer
        for (uint index = 0; index < count && i > end;) {
            Dice memory dice = dices[--i];
            if (dice.owner == owner) {
                diceArray[index++] = _toDiceView(dice, i);
            }
        }
    }

    /// @dev List dice
    /// @param offset Skip previous (offset) records
    /// @param count Return (count) records
    /// @param order Order. 0 reverse order, non-0 positive order
    /// @return diceArray Matched dice array
    function list(
        uint offset, 
        uint count, 
        uint order
    ) external view returns (DiceView[] memory diceArray) {

        // Load dices
        Dice[] storage dices = _dices;
        // Create result array
        diceArray = new DiceView[](count);
        uint length = dices.length;
        uint i = 0;

        // Reverse order
        if (order == 0) {
            uint index = length - offset;
            uint end = index > count ? index - count : 0;
            while (index > end) {
                Dice memory gi = dices[--index];
                diceArray[i++] = _toDiceView(gi, index);
            }
        } 
        // Positive order
        else {
            uint index = offset;
            uint end = index + count;
            if (end > length) {
                end = length;
            }
            while (index < end) {
                diceArray[i++] = _toDiceView(dices[index], index);
                ++index;
            }
        }
    }

    /// @dev Obtain the number of dices that have been opened
    /// @return Number of dices opened
    function getDiceCount() external view returns (uint) {
        return _dices.length;
    }
    /*
    /// @dev start a roll dice
    /// @param n count of PRC
    /// @param m times, 4 decimals
    function roll(uint n, uint m) external {
        require(n == 1 && m >= TIMES_BASE && m <= MAX_M, "PRC:n or m not valid");
        _burn(msg.sender, n * 1 ether);
        _dices.push(Dice(msg.sender, uint32(n), uint32(m), uint32(block.number)));
    }

    /// @dev Claim gained DCU
    /// @param index index of bet
    function claim(uint index) external {
        Dice memory dice = _dices[index];
        uint gain = _gained(dice, index);
        if (gain > 0) {
            DCU(DCU_TOKEN_ADDRESS).mint(dice.owner, gain);
        }

        _dices[index].n = uint32(0);
    }

    /// @dev Batch claim gained DCU
    /// @param indices Indices of bets
    function batchClaim(uint[] calldata indices) external {
        
        address owner = address(0);
        uint gain = 0;

        for (uint i = indices.length; i > 0;) {
            uint index = indices[--i];
            Dice memory dice = _dices[index];
            if (owner == address(0)) {
                owner = dice.owner;
            } else {
                require(owner == dice.owner, "PRC:different owner");
            }
            gain += _gained(dice, index);
            _dices[index].n = uint32(0);
        }

        if (owner > address(0)) {
            DCU(DCU_TOKEN_ADDRESS).mint(owner, gain);
        }
    }
    */
    
    // Calculate gained number of DCU
    function _gained(Dice memory dice, uint index) private view returns (uint gain) {
        uint hashBlock = uint(dice.openBlock) + OPEN_BLOCK_SPAN;
        require(block.number > hashBlock, "PRC:!hashBlock");
        uint hashValue = uint(blockhash(hashBlock));
        if (hashValue > 0) {
            hashValue = uint(keccak256(abi.encodePacked(hashValue, index)));
            if (hashValue % uint(dice.m) < TIMES_BASE) {
                gain = uint(dice.n) * uint(dice.m) * 1 ether / TIMES_BASE;
            }
        }
    }

    // Convert Dice to DiceView
    function _toDiceView(Dice memory dice, uint index) private view returns (DiceView memory div) {
        div = DiceView(
            index,
            dice.owner,
            dice.n,
            dice.m,
            dice.openBlock,
            block.number > uint(dice.openBlock) + OPEN_BLOCK_SPAN ? _gained(dice, index) : 0
        );
    }
}


// File contracts/FortPRC44.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;
/// @dev Guarantee
contract FortPRC44 is FortPRC {

    // Roll dice44 structure
    struct Dice44 {
        address owner;
        uint32 n;
        uint32 m;
        uint32 openBlock;
    }

    // Roll dice44 information view
    struct DiceView44 {
        uint index;
        address owner;
        uint32 n;
        uint32 m;
        uint32 openBlock;
        uint gained;
    }

    // The span from current block to hash block
    uint constant OPEN_BLOCK_SPAN44 = 1;
    // // Times base, 4 decimals
    // uint constant TIMES_BASE = 10000;
    // Max times, 100000.0000. [1.0000, 100000.0000]

    // 4 decimals for M
    uint constant M_BASE44 = 10000;

    // 4 decimals for N
    uint constant N_BASE44 = 10000;
    
    // MAX M. [1.0000, 100.0000]
    uint constant MAX_M44 = 100 * M_BASE44;
    
    // MAX N, [0.0001, 1000.0000]
    uint constant MAX_N44 = 1000 * N_BASE44;

    // Roll dice44 array
    Dice44[] _dices44;

    /// @dev Find the dices44 of the target address (in reverse order)
    /// @param start Find forward from the index corresponding to the given contract address 
    /// (excluding the record corresponding to start)
    /// @param count Maximum number of records returned
    /// @param maxFindCount Find records at most
    /// @param owner Target address
    /// @return diceArray44 Matched dice44 array
    function find44(
        uint start, 
        uint count, 
        uint maxFindCount, 
        address owner
    ) external view returns (DiceView44[] memory diceArray44) {
        
        diceArray44 = new DiceView44[](count);
        
        // Calculate search region
        Dice44[] storage dices44 = _dices44;
        uint i = dices44.length;
        uint end = 0;
        if (start > 0) {
            i = start;
        }
        if (i > maxFindCount) {
            end = i - maxFindCount;
        }
        
        // Loop lookup to write qualified records to the buffer
        for (uint index = 0; index < count && i > end;) {
            Dice44 memory dice44 = dices44[--i];
            if (dice44.owner == owner) {
                diceArray44[index++] = _toDiceView44(dice44, i);
            }
        }
    }

    /// @dev List dice44
    /// @param offset Skip previous (offset) records
    /// @param count Return (count) records
    /// @param order Order. 0 reverse order, non-0 positive order
    /// @return diceArray44 Matched dice44 array
    function list44(
        uint offset, 
        uint count, 
        uint order
    ) external view returns (DiceView44[] memory diceArray44) {

        // Load dices44
        Dice44[] storage dices44 = _dices44;
        // Create result array
        diceArray44 = new DiceView44[](count);
        uint length = dices44.length;
        uint i = 0;

        // Reverse order
        if (order == 0) {
            uint index = length - offset;
            uint end = index > count ? index - count : 0;
            while (index > end) {
                Dice44 memory gi = dices44[--index];
                diceArray44[i++] = _toDiceView44(gi, index);
            }
        } 
        // Positive order
        else {
            uint index = offset;
            uint end = index + count;
            if (end > length) {
                end = length;
            }
            while (index < end) {
                diceArray44[i++] = _toDiceView44(dices44[index], index);
                ++index;
            }
        }
    }

    /// @dev Obtain the number of dices44 that have been opened
    /// @return Number of dices44 opened
    function getDiceCount44() external view returns (uint) {
        return _dices44.length;
    }

    /// @dev start a roll dice44
    /// @param n count of PRC
    /// @param m times, 4 decimals
    function roll44(uint n, uint m) external {
        require(n > 0 && n < MAX_N44  && m >= M_BASE44 && m <= MAX_M44, "PRC:n or m not valid");
        _burn(msg.sender, n * 1 ether / N_BASE44);
        _dices44.push(Dice44(msg.sender, uint32(n), uint32(m), uint32(block.number)));
    }

    /// @dev Claim gained DCU
    /// @param index index of bet
    function claim44(uint index) external {
        Dice44 memory dice44 = _dices44[index];
        uint gain = _gained44(dice44, index);
        if (gain > 0) {
            DCU(DCU_TOKEN_ADDRESS).mint(dice44.owner, gain);
        }

        _dices44[index].n = uint32(0);
    }

    /// @dev Batch claim gained DCU
    /// @param indices Indices of bets
    function batchClaim44(uint[] calldata indices) external {
        
        address owner = address(0);
        uint gain = 0;

        for (uint i = indices.length; i > 0;) {
            uint index = indices[--i];
            Dice44 memory dice44 = _dices44[index];
            if (owner == address(0)) {
                owner = dice44.owner;
            } else {
                require(owner == dice44.owner, "PRC:different owner");
            }
            gain += _gained44(dice44, index);
            _dices44[index].n = uint32(0);
        }

        if (owner > address(0)) {
            DCU(DCU_TOKEN_ADDRESS).mint(owner, gain);
        }
    }

    // Calculate gained number of DCU
    function _gained44(Dice44 memory dice44, uint index) private view returns (uint gain) {
        uint hashBlock = uint(dice44.openBlock) + OPEN_BLOCK_SPAN44;
        require(block.number > hashBlock, "PRC:!hashBlock");
        uint hashValue = uint(blockhash(hashBlock));
        if (hashValue > 0) {
            hashValue = uint(keccak256(abi.encodePacked(hashValue, index)));
            if (hashValue % uint(dice44.m) < M_BASE44) {
                gain = uint(dice44.n) * uint(dice44.m) * 1 ether / M_BASE44 / N_BASE44;
            }
        }
    }

    // Convert Dice44 to DiceView44
    function _toDiceView44(Dice44 memory dice44, uint index) private view returns (DiceView44 memory div) {
        div = DiceView44(
            index,
            dice44.owner,
            dice44.n,
            dice44.m,
            dice44.openBlock,
            block.number > uint(dice44.openBlock) + OPEN_BLOCK_SPAN44 ? _gained44(dice44, index) : 0
        );
    }
}