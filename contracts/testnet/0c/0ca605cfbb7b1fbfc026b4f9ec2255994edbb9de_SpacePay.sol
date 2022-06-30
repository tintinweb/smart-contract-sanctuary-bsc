// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./IERC20Metadata.sol";
import "./Context.sol";
import "./Ownable.sol";

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
contract SpacePay is Context, IERC20, IERC20Metadata, Ownable {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    address private _feeAccount;

    mapping(address => bool) private _isExcluded;
    address[] private _excluded;

    string private _name = "SpacePay";
    string private _symbol = "SPAY";

    uint256 publishTime = 1656551803;

    /// @notice tax varibles
    uint8 private _taxOnBuy;
    uint8 private _taxOnSell;

    address private _preSaleAddress =
        0xE81B19b46c48eFdC4545aD15B3172AA791f0a3aE;
    address private _fairLaunchAddress =
        0x54FCAAb442F0e92F8587b053f6455aFeD8fdB929;
    address private _marsPoolAddress =
        0xA44AC7a13d88fc9b21Da354454900aBa818cBA83;
    address private _earnSystemAddress =
        0xBF363cb69E1a3E8daE784596dc3B7BAd900BBCA1;
    address private _liquidityAddress =
        0x8f0F3da786F55fD7c31D8fe7cceD930D49C39FF6;
    address private _teamAddress = 0xbEf6A17339574e04269Ee92B01fEb225538C8B5c;
    address private _exchangesAddress =
        0xEdf0B0AA4eB7F6eb1A16D9b3E7b90743321e2020;
    address private _ecoSystemFoundAddress =
        0xAd6eA67586Ec34AF8c2d42F78c0A126DD145dA57;
    address private _routerAddress = 0x976EA74026E726554dB657fA54763abd0C3a0aa9;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(
        address initialAccount,
        uint256 initialBalance,
        uint8 taxOnBuy_,
        uint8 taxOnSell_
    ) {
        _taxOnBuy = taxOnBuy_;
        _taxOnSell = taxOnSell_;

        _mint(
            initialAccount,
            initialBalance * 10 ** decimals()
        );
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
        return 9;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Returns the tax on sell percentage.
     */
    function taxOnSell() public view virtual returns (uint8) {
        return _taxOnSell;
    }

    /**
     * @dev Returns the tax on purchase percentage.
     */
    function taxOnBuy() public view virtual returns (uint8) {
        return _taxOnBuy;
    }

    /**
     * @dev Set on buy tax percentage.
     */
    function setOnPurchaseTax(uint8 taxPercentage) public virtual onlyOwner {
        _taxOnBuy = taxPercentage;
    }

    /**
     * @dev Set on purchase tax percentage.
     */
    function setOnSellTax(uint8 taxPercentage) public virtual onlyOwner {
        _taxOnSell = taxPercentage;
    }

    // Addresses

    function preSaleAddress() public view virtual returns (address) {
        return _preSaleAddress;
    }

    function setPreSaleAddress(address newAddress) public  virtual onlyOwner {
        _preSaleAddress = newAddress;
    }

    function fairLaunchAddress() public view virtual returns (address) {
        return _fairLaunchAddress;
    }

    function setFairLaunchAddress(address newAddress) public  virtual onlyOwner {
        _fairLaunchAddress = newAddress;
    }

    function marsPoolAddress() public view virtual returns (address) {
        return _marsPoolAddress;
    }

    function setMarsPoolAddress(address newAddress) public  virtual onlyOwner {
        _marsPoolAddress = newAddress;
    }

    function earnSystemAddress() public view virtual returns (address) {
        return _earnSystemAddress;
    }

    function setEarnSystemAddress(address newAddress) public  virtual onlyOwner {
        _earnSystemAddress = newAddress;
    }

    function liquidityAddress() public view virtual returns (address) {
        return _liquidityAddress;
    }

    function setLiquidityAddress(address newAddress) public  virtual onlyOwner {
        _liquidityAddress = newAddress;
    }

    function teamAddress() public view virtual returns (address) {
        return _teamAddress;
    }

    function setTeamAddress(address newAddress) public  virtual onlyOwner {
        _teamAddress = newAddress;
    }

    function exchangesAddress() public view virtual returns (address) {
        return _exchangesAddress;
    }

    function setExchangesAddress(address newAddress) public  virtual onlyOwner {
        _exchangesAddress = newAddress;
    }

    function ecoSystemFoundAddress() public view virtual returns (address) {
        return _ecoSystemFoundAddress;
    }

    function setEcoSystemFoundAddress(address newAddress) public  virtual onlyOwner {
        _ecoSystemFoundAddress = newAddress;
    }

    function routerAddress() public view virtual returns (address) {
        return _routerAddress;
    }

    function setRouterAddress(address newAddress) public  virtual onlyOwner {
        _routerAddress = newAddress;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
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
    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
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
    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
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
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
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
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
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

        uint256 feeValue = 0;
        if (to == routerAddress()) {
            uint8 sellTaxFee;
            if (isExcluded(from)) {
                sellTaxFee = 80;
            } else {
                sellTaxFee = taxOnSell();
            }
            feeValue = (amount * sellTaxFee) / 100;
            uint256 fromBalance = _balances[from];
            require(
                fromBalance >= amount,
                "ERC20: transfer amount exceeds balance"
            );
            unchecked {
                _balances[from] = fromBalance - amount;
            }
            _balances[to] += amount - feeValue;
            _balances[liquidityAddress()] += feeValue;
        } else if (from == routerAddress()) {
            uint8 purchaseTaxFee = taxOnBuy();
            feeValue = (amount * purchaseTaxFee) / 100;
            uint256 receiverTaxedValue = amount - feeValue;
            uint256 fromBalance = _balances[from];
            _balances[to] += receiverTaxedValue;
            unchecked {
                _balances[from] = fromBalance - amount;
            }
            _balances[liquidityAddress()] += feeValue;
        } else {
            feeValue = 0;
            uint256 senderBalance = _balances[from];
            require(
                senderBalance >= amount,
                "ERC20: transfer amount exceeds balance"
            );
            unchecked {
                _balances[from] = senderBalance - amount;
            }
            _balances[to] += amount;
        }
        // todo: if some1 buys tokens in the first 5 minutes, he'll be added to the black list

        if (block.timestamp < (publishTime + 5 minutes)) {
            excludeAccount(to);
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
        _balances[account] += 14000000 * 10**decimals();
        _balances[_preSaleAddress] += 25000000 * 10**decimals();
        _balances[_fairLaunchAddress] += 75000000 * 10**decimals();
        _balances[_marsPoolAddress] += 37500000 * 10**decimals();
        _balances[_earnSystemAddress] += 37500000 * 10**decimals();
        _balances[_liquidityAddress] += 25000000 * 10**decimals();
        _balances[_teamAddress] += 25000000 * 10**decimals();
        _balances[_exchangesAddress] += 12500000 * 10**decimals();
        _balances[_ecoSystemFoundAddress] += 12500000 * 10**decimals();

        emit Transfer(address(0), account, amount);
        emit Transfer(address(0), _preSaleAddress, amount);
        emit Transfer(address(0), _fairLaunchAddress, amount);
        emit Transfer(address(0), _marsPoolAddress, amount);
        emit Transfer(address(0), _earnSystemAddress, amount);
        emit Transfer(address(0), _liquidityAddress, amount);
        emit Transfer(address(0), _teamAddress, amount);
        emit Transfer(address(0), _exchangesAddress, amount);
        emit Transfer(address(0), _ecoSystemFoundAddress, amount);

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
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
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

    function isExcluded(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function excludeAccount(address account) internal virtual {
        require(!_isExcluded[account], "Account is already excluded");
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeAccount(address account) internal virtual {
        require(_isExcluded[account], "Account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }
}