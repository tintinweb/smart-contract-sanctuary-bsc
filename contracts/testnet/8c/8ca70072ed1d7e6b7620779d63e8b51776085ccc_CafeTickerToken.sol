// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
 
contract CafeTickerToken is IERC20, Ownable {
    using SafeMath for uint256;

    struct TransferLimit {
        uint256 transferLimit;
        uint256 lastTransferLimitTimestamp;
        uint256 allowedToTransfer;
    }

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => TransferLimit) private _transferLimits;
    
    uint256 private _defaultTransferLimit;

    uint256 private _totalSupply;
    uint256 private _kDecimals;
    uint256 private _k;

    string private _name;
    string private _symbol;

    uint8 private _decimals;

    bool public isEnabledLimit;

    /**
     * @notice CafeTickerToken simply implements a ERC20 token.
     */
    constructor() {
        _name = "Cafe token";
        _symbol = "CFTK";
        _decimals = 0;
        _defaultTransferLimit = 100;
        isEnabledLimit = false;
        _mint(msg.sender, 20000);
    }



    // Public functions

    /// @notice toggle requirement of limits
    /// @param _isEnabledLimit enabling/disabling limits
    function setIsEnabledLimits(bool _isEnabledLimit) public onlyOwner {
        isEnabledLimit = _isEnabledLimit;
    }

    /**
     * @notice Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @notice Returns the symbol of the token.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @notice Returns the number of decimals used to get its user representation.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @notice Returns the amount of tokens in existence.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @notice Returns the amount of tokens owned by `_account`.
     * @param _account Account to check balance.
     */
    function balanceOf(address _account)
        public
        view
        override
        returns (uint256)
    {
        return  _balances[_account];
    }

    /**
     * @notice Returns transfer limit for `_account`.
     * Can be defaul value or personally assigned to the `_account` value.
     * @param _account Account to get transfer limit.
     */
    function getTransferLimit(address _account) public view returns (uint256) {
        if (_transferLimits[_account].transferLimit > 0) {
            return _transferLimits[_account].transferLimit;
        }

        return _defaultTransferLimit;
    }

    /**
     * @notice Get the number of tokens that can be transferred today
     * by `_account`. Can be 0 in 2 cases:
     * a) `_updateTransferLimit` function not called yet;
     * b) transfer limit was set to 0 by limiter.
     * @param _account Account to get amount allowed to transfer today.
     */
    function getAllowedToTransfer(address _account)
        public
        view
        returns (uint256)
    {
        if ( _isLimitOverdue(_account)) {
            if (_transferLimits[_account].transferLimit > 0) {
                return _transferLimits[_account].transferLimit;
            }
            return _defaultTransferLimit;
        }
        return _transferLimits[_account].allowedToTransfer;
    }


    /**
     * @notice Moves `_amount` tokens from the caller's account to `_recipient`.
     * Emits a {Transfer} event.
     * @param _recipient Recipient of the tokens.
     * @param _amount Amount tokens to move.
     * @return A boolean value indicating whether the operation succeeded.
     */
    function transfer(address _recipient, uint256 _amount) 
        payable
        public
        virtual
        override
        returns (bool)
    {
        _transfer(msg.sender, _recipient, _amount);
        return true;
    }

    /**
     * @notice the remaining number of tokens that `_spender` will be
     * allowed to spend on behalf of `_owner` through {transferFrom}. This is
     * zero by default.
     * @param _owner Owner of tokens.
     * @param _spender Spender of tokens.
     */
    function allowance(address _owner, address _spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[_owner][_spender];
    }

    /**
     * @notice Sets `_amount` as the allowance of `_spender` over the caller's tokens.
     * Emits an {Approval} event.
     * @param _spender Spender of the tokens.
     * @param _amount Amount of tokens to set as the allowance.
     * @return A boolean value indicating whether the operation succeeded.
     */
    function approve(address _spender, uint256 _amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(msg.sender, _spender, _amount);

        return true;
    }

    /**
     * @notice Moves `_amount` tokens from `_sender` to `_recipient` using the
     * allowance mechanism. `_amount` is then deducted from the caller's
     * allowance.
     * Emits a {Transfer} event.
     * @param _sender Spender of tokens.
     * @param _recipient Recipient of tokens.
     * @param _amount Amount of tokens to transfer.
     * @return A boolean value indicating whether the operation succeeded.
     *
     * Requirements:
     *
     * - `_amount` must be less or equal allowance for the `_sender`.
     */
    function transferFrom(
        address _sender,
        address _recipient,
        uint256 _amount
    )
        public
        virtual
        override
        returns (bool)
    {
        if (isEnabledLimit) {
          _updateTransferLimit(_sender, _amount);
        }
        _transfer(_sender, _recipient, _amount);
        _approve(
            _sender,
            msg.sender,
            _allowances[_sender][msg.sender].sub(
                _amount,
                "CafeTicker: transfer amount exceeds allowance"
            )
        );

        return true;
    }

    /**
     * @notice Increase allowance for the `_spender`.
     * @param _spender Spender of tokens.
     * @param _addedValue Value to add to the allowance for the `_spender`.
     * @return A boolean value indicating whether the operation succeeded.
     */
    function increaseAllowance(address _spender, uint256 _addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            _spender,
            _allowances[msg.sender][_spender].add(
                _addedValue
            )
        );

        return true;
    }

    /**
     * @notice Decrease allowance for the `_spender`.
     * @param _spender Spender of tokens.
     * @param _subtractedValue Value to substruct from the allowance for the `_spender`.
     * @return A boolean value indicating whether the operation succeeded.
     *
     * Requirements:
     *
     * - result of substruction must be greater or equal to 0.
     */
    function decreaseAllowance(address _spender, uint256 _subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            _spender,
            _allowances[msg.sender][_spender].sub(
                _subtractedValue,
                "CafeTicker: decreased allowance below zero"
            )
        );

        return true;
    }

    // Internal functions

    /**
     * @notice Moves tokens `_amount` from `_sender` to `_recipient`.
     * Emits a {Transfer} event.
     * @param _sender Sender of tokens.
     * @param _recipient Recipient of tokens.
     * @param _amount Amount of tokens to transfer.
     *
     * Requirements:
     *
     * - `_sender` cannot be the zero address.
     * - `_recipient` cannot be the zero address.
     * - `_sender` must have a balance of at least `_amount`.
     */
    function _transfer(
        address _sender,
        address _recipient,
        uint256 _amount
    ) internal virtual {
        require(_sender != address(0), "CafeTicker: transfer from the zero address");
        require(_recipient != address(0), "CafeTicker: transfer to the zero address");

        _balances[_sender] = _balances[_sender].sub(
            _amount,
            "CafeTicker: transfer amount exceeds balance"
        );
        _balances[_recipient] = _balances[_recipient].add(_amount);

        emit Transfer(_sender, _recipient, _amount);
    }

    /** @notice Creates `_amount` tokens and assigns them to `_account`, increasing
     * the total supply.
     * Emits a {Transfer} event with `_from` set to the zero address.
     * @param _account Account where to mint tokens.
     * @param _amount Amount of tokens to mint.
     *
     * Requirements:
     *
     * - `_account` cannot be the zero address.
     */
    function _mint(address _account, uint256 _amount) internal virtual {
        require(_account != address(0), "CafeTicker: mint to the zero address");

        _totalSupply = _totalSupply.add(_amount);
        _balances[_account] = _balances[_account].add(_amount);

        emit Transfer(address(0), _account, _amount);
    }

    /**
     * @notice Destroys `_amount` tokens from `_account`, reducing the
     * total supply.
     * Emits a {Transfer} event with `_to` set to the zero address.
     * @param _account Account where to burn tokens.
     * @param _amount Amount of tokens to burn.
     *
     * Requirements:
     *
     * - `_account` cannot be the zero address.
     * - `_amount` must have at least `amount` tokens.
     */
    function _burn(address _account, uint256 _amount) internal virtual {
        require(_account != address(0), "CafeTicker: burn from the zero address");

        _balances[_account] = _balances[_account].sub(
            _amount,
            "CafeTicker: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(_amount);

        emit Transfer(_account, address(0), _amount);
    }

    /**
     * @notice Sets `_amount` as the allowance of `_spender` over the `_owner` s tokens.
     * Emits an {Approval} event.
     * @param _owner Owner of the tokens.
     * @param _spender Spender of the tokens.
     * @param _amount Amount of tokens to set as the allowance.
     *
     * Requirements:
     *
     * - `_owner` cannot be the zero address.
     * - `_spender` cannot be the zero address.
     */
    function _approve(
        address _owner,
        address _spender,
        uint256 _amount
    ) internal virtual {
        require(_owner != address(0), "CafeTicker: approve from the zero address");
        require(_spender != address(0), "CafeTicker: approve to the zero address");

        _allowances[_owner][_spender] = _amount;

        emit Approval(_owner, _spender, _amount);
    }

    // Private functions

    /**
     * @notice Update transfer limit for `_account` before each operation with
     * tokens.
     * @param _account Account to update transfer limit if needed.
     * @param _amount Amount to substruct from transfer limit after updating.
     */
    function _updateTransferLimit(address _account, uint256 _amount) private {
        if (
           _isLimitOverdue(_account)
        ) {
            _transferLimits[_account].lastTransferLimitTimestamp = block
                .timestamp;

            if (_transferLimits[_account].transferLimit > 0) {
                _transferLimits[_account].allowedToTransfer = _transferLimits[
                    _account
                ]
                    .transferLimit;
            } else {
                _transferLimits[_account]
                    .allowedToTransfer = _defaultTransferLimit;
                _transferLimits[_account].transferLimit = _defaultTransferLimit;
            }
        }

        _transferLimits[_account].allowedToTransfer = _transferLimits[_account]
            .allowedToTransfer
            .sub(_amount, "CafeTicker: transfer exceeds your transfer limit");
    }


    /**
     * @notice function check if limit os overdue.
     * @param _account Account to update transfer limit if needed.
     */
    function _isLimitOverdue(address _account) private view returns (bool) {
        if (
            _transferLimits[_account].lastTransferLimitTimestamp + 1 hours <
            block.timestamp
        ) {
            return true;
        }
        return false;
    }
}