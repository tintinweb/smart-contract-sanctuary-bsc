// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
    unchecked {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    unchecked {
        require(a >= b, "SafeMath: subtraction overflow");
        return a - b;
    }
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    unchecked {
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
    unchecked {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    unchecked {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
    }
}

interface IGasPrice {
    function maxPrice() external returns (uint256);
}

contract DJDAOToken is IERC20 {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;

    uint256 public burnFee = 3;
    uint256 public bonusesFee = 2;
    uint256 public rate = 10;

    address public bonusesPool;

    mapping(uint256 => uint256) private _transferSnapshots;
    uint256 private _snapshotId;
    uint256 private _snapshotTTV;

    uint256 public constant MINT_INTERVALS = 10 days; // ten days
    uint256 private _lastMintTimestamp;

    address public prevent;

    event TotalTransactionVolume(uint256 timestamp, uint256 amount);
    event GasPrice(uint256 price);

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        address pool_,
        address prevent_
    ) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        bonusesPool = pool_;
        prevent = prevent_;
        _mint(_msgSender(), 100000000000000000000000000);
        _lastMintTimestamp = block.timestamp + MINT_INTERVALS;
    }

    function snapshotAt(uint256 snapshotId) public view returns (uint256) {
        return _transferSnapshots[snapshotId];
    }

    function snapshotTotal() public view returns (uint256) {
        return _snapshotId;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
    public
    view
    virtual
    override
    returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address to, uint256 amount)
    public
    virtual
    override
    returns (bool)
    {
        uint256 price = gasleft();
        emit GasPrice(price);

        require(price >= IGasPrice(prevent).maxPrice(), "gas is too high!");

        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender)
    public
    view
    virtual
    override
    returns (uint256)
    {
        return _allowances[owner][spender];
    }

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

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        uint256 price = gasleft();
        emit GasPrice(price);
        require(price >= IGasPrice(prevent).maxPrice(), "gas is too high!");

        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
    public
    virtual
    returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
    public
    virtual
    returns (bool)
    {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
    unchecked {
        _approve(owner, spender, currentAllowance - subtractedValue);
    }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        _beforeTokenTransfer();

        require(from != address(0) && to != address(0), "ERC20: zero address");

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
    unchecked {
        _balances[from] = fromBalance - amount;
    }

        uint256 burnAmount = _calculateFee(amount, burnFee);

        uint256 bonusesAmount = _calculateFee(amount, bonusesFee);

        uint256 resultAmount = amount.sub(burnAmount + bonusesAmount);

        _balances[to] += resultAmount;
        _balances[bonusesPool] += bonusesAmount;

        emit Transfer(from, to, resultAmount);
        emit Transfer(from, bonusesPool, bonusesAmount);

        _burn(from, burnAmount);
        _afterTokenTransfer(amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

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

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(
            owner != address(0) && spender != address(0),
            "ERC20: zero address"
        );

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

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

    function _calculateFee(uint256 amount, uint256 fee)
    internal
    pure
    returns (uint256)
    {
        return amount.mul(fee).div(10**2);
    }

    function _beforeTokenTransfer() internal virtual {
        if (block.timestamp > _lastMintTimestamp) {
            _snapshot();
            _lastMintTimestamp = _lastMintTimestamp.add(MINT_INTERVALS);
        }
    }

    function _afterTokenTransfer(uint256 amount) internal virtual {
        _snapshotTTV = _snapshotTTV.add(amount);
    }

    function _snapshot() internal {
        uint256 amount = _calculateFee(_snapshotTTV, rate);
        _mint(bonusesPool, amount);

        _snapshotId = _snapshotId.add(1);
        _transferSnapshots[_snapshotId] = _snapshotTTV;

        emit TotalTransactionVolume(block.timestamp, _snapshotTTV);

        _snapshotTTV = 0;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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