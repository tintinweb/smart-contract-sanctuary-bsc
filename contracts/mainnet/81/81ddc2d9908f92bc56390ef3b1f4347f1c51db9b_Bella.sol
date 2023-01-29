/**
 *Submitted for verification at BscScan.com on 2023-01-29
*/

// SPDX-License-Identifier: MIT
// @VKah33 Big thanks from Bella and VKah33 to the OpenZeppelin community.
// The whole community appreciates your works. 
// commented like this // is from @VKah33 and also /*@VKah33 and only in the ERC20 contract
// otherwise it is the OpenZeppelin's @dev comments and their secure code

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
//----------------------------------------------------------------------------------------------------------------------------------
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

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
//-----------------------------------------------------------------------------------------------------------------------------------
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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
//------------------------------------------------------------------------------------------------------------------------------------
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
//-------------------------------------------------------------------------------------------------------------------------------------
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)
// ERC20 standard and the main contract.
// The whole project will be survey driven by the community
// Also Burnable, but isn't written here directly, 
// because it is in the same contract (ERC20) at the end. 

contract Bella is Context, IERC20, IERC20Metadata, Ownable {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;
    mapping (address => bool) public whiteList;

    string private tokenName;
    string private tokenSymbol;


    uint256 private _totalSupply;

    // Anti Whale Wallet Limit. Changeable to prevent Whales at the start radically and be more open afterwards

    uint256 public walletLimit;

    // Fee variables for tax percentage and tax wallet addresses

    uint256 Fee;
    address taxWallet_1;
    address taxWallet_2;

    // setting the start values, but besides name and symbol, all values are changeable

    constructor (uint256 _walletLimit, uint256 _fee, address _taxWallet_1, address _taxWallet_2, uint256 writeTotalSupply) {

        tokenName = "Bella";
        tokenSymbol = "BL";

        walletLimit = _walletLimit;

        Fee = _fee;
        taxWallet_1 = _taxWallet_1;
        taxWallet_2 = _taxWallet_2;
        _totalSupply = writeTotalSupply;
        _balances[msg.sender] = _totalSupply;
    }
  
    // modifying the Anti Whale to be more or less radical

    function walletLimitModifier (uint256 _walletLimit) public {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        walletLimit = _walletLimit;
    }
    
    // modifying the total fee percentage amount. Can be from zero to nine percentage.

    function feeModifier (uint256 _fee) public {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        require(_fee <= 9, "Bella: Fee can never ever be above 9%" );
        Fee = _fee;
    }

    // modifying the tax wallets. Mainly marketing, liquiditypool or for burns.
    // The community will decide

    function taxWallet_1_Modifier (address _taxWallet_1) public {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        taxWallet_1 = _taxWallet_1;
    }

    function taxWallet_2_Modifier (address _taxWallet_2) public {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        taxWallet_2 = _taxWallet_2;
    }

    // tax calculator for calculating the fee amount

    function taxCalculator (uint256 _amount) public view returns(uint256){
        return Fee * _amount  / 100;
    }

    // whitelisting accounts that must have the ability like liquidity pools and exchanges and so on

    function whiteListing (address account) public {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        whiteList[account] = true;
    }

    // whitelisted loosing ability by owner

    function unDo_whiteListing (address account) public {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        whiteList[account] = false;
    }

    // returns the name of the token

    function name() public view virtual override returns (string memory) {
        return tokenName;
    }

    // returns symbol of the token

    function symbol() public view virtual override returns (string memory) {
        return tokenSymbol;
    }

    // returns decimals of the token

    function decimals() public view virtual override returns (uint8) {
        return 8;
    }

    // returns total supply of the token

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
     * 
     */

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 toBalance = _balances[to];
        uint256 fromBalance = _balances[from];

        require(fromBalance >= amount, "ERC20: Transfer amount exceeds Balance");

    /** @VKah33 No buy tax! because the liquidity pool(s) will be whitelisted. 
    * If address is whitelisted no tax and Anti-Whale. Necessary for exchanges and project wallets etc. .
    * the net (Netto) transfer amount will be calculated in the taxCalculator function
    * and will be sent back into the local Fees variable. The Fees will be taken from the transfer amount
    * A requirement if the Anti-Whale rule will not be broken. The Fees will split and be sent to the tax wallet addresses.
    * The transfer will then be completed.
    */

        if( whiteList[from] == true && whiteList[to] == true) {
            unchecked {
                _balances[from] = fromBalance - amount;
                _balances[to] += amount;
                } 
            } else if ( whiteList[from] == true && whiteList[to] == false ) {
                 require(walletLimit >= (toBalance + amount), "Bella: Transfer amount exceeds Anti-Whale Wallet Limit");
        
            unchecked {
                _balances[from] = fromBalance - amount;
                _balances[to] += amount;
                }
            } else if ( whiteList[from] == false && whiteList[to] == true ) {
                uint256 Fees = taxCalculator(amount);
                uint256 Netto = amount - Fees;
                
                unchecked {
                _balances[taxWallet_1] += Fees/2 ;
                _balances[taxWallet_2] += Fees/2 ;
                _balances[from] = fromBalance - amount;
                _balances[to] += Netto;
                }    
            } else if ( whiteList[from] == false && whiteList[to] == false ) {
                uint256 Fees = taxCalculator(amount);
                uint256 Netto = amount - Fees;
                
                require(walletLimit >= (toBalance + Netto), "Bella: Transfer amount exceeds Anti-Whale Wallet Limit");

                unchecked {
                _balances[taxWallet_1] += Fees/2 ;
                _balances[taxWallet_2] += Fees/2 ;
                _balances[from] = fromBalance - amount;
                _balances[to] += Netto;
                }    
            }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }
    
    // @VKah33 here is the the place where the minting function was. It is deleted from this contract

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
//-------------same-contract----------but-burning-part------------------------------------------------------------------------------
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