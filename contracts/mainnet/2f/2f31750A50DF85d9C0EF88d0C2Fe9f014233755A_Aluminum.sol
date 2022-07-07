/**
 *Submitted for verification at BscScan.com on 2022-07-07
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.12;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

contract Aluminum is Context, IBEP20, Ownable {
    event LiquidityUpdated(
        address indexed oldAddress,
        address indexed newAddress
    );
    event Fee(address indexed sender, uint256 amount);

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromIncomingFee;
    mapping(address => bool) private _isExcludedFromOutgoingFee;

    uint256 private _totalSupply;
    uint256 private _initialSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;
    address public liquidity;

    constructor() {
        _name = "Aluminum";
        _symbol = "ALUM";
        _decimals = 8;
        _initialSupply = 0;
        _totalSupply = _initialSupply;
        _isExcludedFromIncomingFee[owner()] = true;
        _isExcludedFromOutgoingFee[owner()] = true;
        _isExcludedFromIncomingFee[address(this)] = true;
        _isExcludedFromOutgoingFee[address(this)] = true;
    }

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address) {
        return owner();
    }

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory) {
        return _name;
    }

    /**
     * @dev See {BEP20-totalSupply}.
     */
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {BEP20-initial}.
     */
    function initialSupply() external view returns (uint256) {
        return _initialSupply;
    }

    /**
     * @dev See {BEP20-balanceOf}.
     */
    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev Sets the liquidity address and excludes it from fees
     */
    function setLiquidity(address newLiquidity) external onlyOwner {
        require(
            liquidity != newLiquidity,
            "ALUM: liquidity address cannot be the same"
        );
        _isExcludedFromOutgoingFee[newLiquidity] = true;
        _isExcludedFromIncomingFee[newLiquidity] = true;
        emit LiquidityUpdated(liquidity, newLiquidity);
        liquidity = newLiquidity;
    }

    /**
     * @dev See {BEP20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {BEP20-burn}.
     */

    function burn(uint256 amount) external {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev See {BEP20-allowance}.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {BEP20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {BEP20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BEP20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        require(
            _allowances[sender][_msgSender()] >= amount,
            "BEP20: transfer amount exceeds allowance"
        );
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()] - amount
        );
        return true;
    }

    /**
     * @dev Sets true value for `account` in `_isExcludedFromIncomingFee`
     */
    function excludeFromIncomingFee(address account) external onlyOwner {
        _isExcludedFromIncomingFee[account] = true;
    }

    /**
     * @dev Sets false value for `account` in `_isExcludedFromIncomingFee`
     */
    function includeInIncomingFee(address account) external onlyOwner {
        _isExcludedFromIncomingFee[account] = false;
    }

    /**
     * @dev Checks if `account` is excluded from incoming fees
     */
    function isExcludedFromIncomingFee(address account)
        external
        view
        returns (bool)
    {
        return _isExcludedFromIncomingFee[account];
    }

    /**
     * @dev Sets true value for `account` in `_isExcludedFromOutgoingFee`
     */
    function excludeFromOutgoingFee(address account) external onlyOwner {
        _isExcludedFromOutgoingFee[account] = true;
    }

    /**
     * @dev Sets false value for `account` in `_isExcludedFromOutgoingFee`
     */
    function includeInOutgoingFee(address account) external onlyOwner {
        _isExcludedFromOutgoingFee[account] = false;
    }

    /**
     * @dev Checks if `account` is excluded from outgoing fees
     */
    function isExcludedFromOutgoingFee(address account)
        external
        view
        returns (bool)
    {
        return _isExcludedFromOutgoingFee[account];
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
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
        returns (bool)
    {
        require(
            _allowances[_msgSender()][spender] >= subtractedValue,
            "BEP20: decreased allowance below zero"
        );
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] - subtractedValue
        );
        return true;
    }

    /**
     * @dev Creates `amount` tokens and assigns them to `msg.sender`, increasing
     * the total supply.
     *
     * Requirements
     *
     * - `msg.sender` must be the token owner
     */
    function mint(uint256 amount) external onlyOwner returns (bool) {
        _mint(_msgSender(), amount);
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient.
     * Applies `amount` 10% fees if account is not excluded.
     * 4% minning fee + 4% liquidity fee + 2% burn fee
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     * - `amount` must be greater than 0.
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount` plus fees if not excluded.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(
            _balances[sender] >= amount,
            "BEP20: transfer amount exceeds balance"
        );

        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);

        if (_shouldTakeFee(sender, recipient)) {
            uint256 onePercent = _findOnePercent(amount);
            uint256 burnFee = onePercent * 2;
            uint256 miningFee = onePercent * 4;
            uint256 liquidityFee = onePercent * 4;
            uint256 totalFee = burnFee + miningFee + liquidityFee;
            require(
                _balances[sender] > totalFee,
                "ALUM: transfer amount + fees exceeds balance"
            );
            // mining fees
            _balances[sender] = _balances[sender] - miningFee;
            _balances[owner()] = _balances[owner()] + miningFee;
            emit Transfer(sender, owner(), miningFee);
            // liquidity fees
            _balances[sender] = _balances[sender] - liquidityFee;
            _balances[liquidity] = _balances[liquidity] + liquidityFee;
            emit Transfer(sender, liquidity, miningFee);
            // burn
            _burn(sender, burnFee);
            emit Fee(sender, totalFee);
        }
    }

    /**
     * @dev Checks if a fee should be taken from the transaction.
     */
    function _shouldTakeFee(address sender, address recipient)
        internal
        view
        returns (bool)
    {
        return
            !_isExcludedFromIncomingFee[recipient] &&
            !_isExcludedFromOutgoingFee[sender];
    }

    /**
     * @dev Destroys 'amount' tokens from the provided account
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - Amount burned cannot equal 0
     * - Amount burned cannot exceed _totalSupply
     * - Amount burned cannot exceed _balanaces[account]
     */
    function _burn(address account, uint256 amount) internal {
        require(amount != 0);
        require(
            amount <= _totalSupply,
            "BEP20: Burn amount exceeds _totalSupply"
        );
        require(
            amount <= _balances[account],
            "BEP20: Burn amount exceeds balance"
        );
        _totalSupply = _totalSupply - amount;
        _balances[account] = _balances[account] - amount;
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint to the zero address");
        _totalSupply = _totalSupply + amount;
        _balances[account] = _balances[account] + amount;
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
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
    ) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Returns truncated 1% of `value`.
     */
    function _findOnePercent(uint256 value) private pure returns (uint256) {
        return value / 100;
    }
}