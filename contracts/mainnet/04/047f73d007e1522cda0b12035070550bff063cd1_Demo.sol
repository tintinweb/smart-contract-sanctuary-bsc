/**
 *Submitted for verification at BscScan.com on 2022-06-23
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Demo {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;
    address private _owner;

    /**
     * Sets the values 
     * and 
     * calling function _mint for initial token creation and distribution. 
     */
    constructor() {
        _name = "Semen";
        _symbol = "SMN";
        _decimals = 18;
        _owner = msg.sender;

        _mint(_owner, 1000000 * 10 ** _decimals);
    }

    /**
     * Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * Returns the symbol of the token.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * Returns the number of decimals.
     */
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    /**
     * Returns the total token supply.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /**
     * Returns the account balance of another account with address _account.
     */
    function balanceOf() public view virtual returns (uint256) {
        return _balances[msg.sender];
    }

    /**
     * Transfers _amount value of tokens to address _to.
     *
     * Requirements:
     *
     * - _to cannot be the zero address.
     * - the caller must have a balance of at least _amount.
     */
    function transfer(address _to, uint256 _amount) public virtual returns (bool success ) {
        address _from = msg.sender;
        _transfer(_from, _to, _amount);
        return true;
    }
    
    /**
     * Transfers _amount value of tokens from address _from to address _to.
     *
     * Emits an {Approval} event indicating the updated allowance. 
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - _from and _to cannot be the zero address.
     * - _from must have a balance of at least _amount.
     * - the caller must have allowance for _from 's tokens of at least _amount.
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) public virtual returns (bool success) {
        address _spender = msg.sender;
        _spendAllowance(_from, _spender, _amount);
        _transfer(_from, _to, _amount);
        return true;
    }

    /**
     * Technical execution of transfers functions.
     * 
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - _from cannot be the zero address.
     * - _to cannot be the zero address.
     * - _from must have a balance of at least _amount.
     */
    function _transfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal virtual {
        require(_from != address(0), "BEP20: transfer from the zero address");
        require(_to != address(0), "BEP20: transfer to the zero address");
       
        require(_balances[_from] >= _amount, "BEP20: transfer amount exceeds balance");
        unchecked {
            _balances[_from] -= _amount;
        }
        _balances[_to] += _amount;
    }

    /**
     * Allows _spender to withdraw from your account multiple times, up to the _amount value.
     *
     * NOTE: If _amount is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - _spender cannot be the zero address.
     */
    function approve(address _spender, uint256 _amount) public virtual returns (bool success) {
        address _holder = msg.sender;
        _approve(_holder, _spender, _amount);
        return true;
    }

    /**
     * Sets _amount as the allowance of _spender over the _holder s tokens. 
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - _holder cannot be the zero address.
     * - _spender cannot be the zero address.
     */
    function _approve(
        address _holder,
        address _spender,
        uint256 _amount
    ) internal virtual {
        require(_holder != address(0), "BEP20: approve from the zero address");
        require(_spender != address(0), "BEP20: approve to the zero address");

        _allowances[_holder][_spender] = _amount;
    }

    /**
     * Returns the value which _spender is still allowed to withdraw from _holder.
     */
    function allowance(address _holder, address _spender) public view virtual returns (uint256 remaining) {
        return _allowances[_holder][_spender];
    } 

    /**
     * Updates _holder allowance for _spender based on spent _amount.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address _holder,
        address _spender,
        uint256 _amount
    ) internal virtual {
        uint256 _currentAllowance = allowance(_holder, _spender);
        if (_currentAllowance != type(uint256).max) {
            require(_currentAllowance >= _amount, "BEP20: insufficient allowance");
            unchecked {
                _approve(_holder, _spender, _currentAllowance - _amount);
            }
        }
    }

    /**
     * Atomically increases the allowance granted to _spender by the caller by the value _addedValue.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - _spender cannot be the zero address.
     */
    function increaseAllowance(address _spender, uint256 _addedValue) public virtual returns (bool success) {
        address _holder = msg.sender;
        _approve(_holder, _spender, allowance(_holder, _spender) + _addedValue);
        return true;
    }

    /** 
     * Atomically decreases the allowance granted to _spender by the caller by the value _subtractedValue.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - _spender cannot be the zero address.
     * - _spender must have allowance for the caller of at least _subtractedValue.
     */
    function decreaseAllowance(address _spender, uint256 _subtractedValue) public virtual returns (bool success) {
        address _holder = msg.sender;
        uint256 _currentAllowance = allowance(_holder, _spender);
        require(_currentAllowance >= _subtractedValue, "BEP20: decreased allowance below zero");
        unchecked {
            _approve(_holder, _spender, _currentAllowance - _subtractedValue);
        }       
        return true;
    }
  
    /**
     * Creates _amount tokens and assigns them to _account, increasing the total supply.
     *
     * Emits a {Transfer} event with _from set to the zero address.
     *
     * Requirements:
     *
     * - _account cannot be the zero address.
     */
    function _mint(address _account, uint256 _amount) internal virtual {
        require(_account != address(0), "BEP20: mint to the zero address");

        _totalSupply += _amount;
        _balances[_account] += _amount;
    }

    /**
     * Destroys _amount tokens from _account, reducing the total supply.
     *
     * Emits a {Transfer} event with _to set to the zero address.
     *
     * Requirements:
     *
     * - _account cannot be the zero address.
     * - _account must have at least _amount tokens.
     */
    function burn(uint256 _amount) public virtual {
        address _account = msg.sender;

        require(_balances[_account] >= _amount, "BEP20: burn amount exceeds balance");
        unchecked {
            _balances[_account] -= _amount;
        }
        _totalSupply -= _amount;
    }
}