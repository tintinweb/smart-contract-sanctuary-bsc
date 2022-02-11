/**
 *Submitted for verification at BscScan.com on 2022-02-03
*/

pragma solidity ^0.8.0;

interface I3SwapFactory {
  function createTriad(
    address token0,
    address token1,
    address token2
  ) external returns (address triad);

  function getTriads(
    address token0,
    address token1,
    address token2
  ) external returns (address triad);

  function feeTo() external view returns (address);

  function feeToSetter() external view returns (address);

  function setFeeTo(address) external;

  function setFeeToSetter(address) external;

  function allTriadsLength() external view returns (uint);

  function allTriads(uint) external view returns (address triad);
}

pragma solidity ^0.8.0;

interface I3SwapTriad {
  function factory() external view returns (address);

  function token0() external view returns (address);

  function token1() external view returns (address);

  function token2() external view returns (address);

  function mint(address to) external returns (uint liquidity);

  function swap(
    uint amountOout,
    uint amount1Out,
    uint amount2Out,
    address to
  ) external;

  function burn(address to)
    external
    returns (
      uint amount0,
      uint amount1,
      uint amount2
    );

  function initialize(
    address t0,
    address t1,
    address t2
  ) external;

  function MINIMUM_LIQUIDITY() external pure returns (uint);

  function getReserves()
    external
    view
    returns (
      uint112 _reserve0,
      uint112 _reserve1,
      uint112 _reserve2,
      uint32 _blockTimestampLast
    );
}

pragma solidity ^0.8.0;

library Math {
  function min(uint x, uint y) internal pure returns (uint z) {
    z = x < y ? x : y;
  }

  function max(uint x, uint y) internal pure returns (uint z) {
    z = x > y ? x : y;
  }

  function add(uint x, uint y) internal pure returns (uint z) {
    z = x + y;
  }

  function sub(uint x, uint y) internal pure returns (uint z) {
    z = x - y;
  }

  function mul(uint x, uint y) internal pure returns (uint z) {
    z = x * y;
  }

  function div(uint x, uint y) internal pure returns (uint z) {
    require(y != 0);
    z = x / y;
  }

  function pow(uint x, uint y) internal pure returns (uint z) {
    z = x**y;
  }

  // Babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
  function sqrt(uint x) internal pure returns (uint y) {
    uint _x = x;
    uint _y = 1;

    while (_x - _y > uint(0)) {
      _x = (_x + _y) / 2;
      _y = x / _x;
    }
    y = _x * 10**18; // Value in Wei to handle floating point results.
  }
}

pragma solidity ^0.8.0;

library UQ112x112 {
  uint224 constant primer = 2**112;

  function encode(uint112 y) internal pure returns (uint224 z) {
    z = uint224(y) * primer;
  }

  function uqdiv(uint224 x, uint112 y) internal pure returns (uint224 z) {
    z = x / uint224(y);
  }
}

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint);

  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function balanceOf(address account) external view returns (uint);

  /**
   * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint amount) external returns (bool);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
  function allowance(address owner, address spender) external view returns (uint);

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
  function approve(address spender, uint amount) external returns (bool);

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
    uint amount
  ) external returns (bool);

  /**
   * @dev Emitted when `value` tokens are moved from one account (`from`) to
   * another (`to`).
   *
   * Note that `value` may be zero.
   */
  event Transfer(address indexed from, address indexed to, uint value);

  /**
   * @dev Emitted when the allowance of a `spender` for an `owner` is set by
   * a call to {approve}. `value` is the new allowance.
   */
  event Approval(address indexed owner, address indexed spender, uint value);
}

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
contract ERC20 is Context, IERC20, IERC20Metadata {
  mapping(address => uint) private _balances;

  mapping(address => mapping(address => uint)) private _allowances;

  uint private _totalSupply;

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
  function totalSupply() public view virtual override returns (uint) {
    return _totalSupply;
  }

  /**
   * @dev See {IERC20-balanceOf}.
   */
  function balanceOf(address account) public view virtual override returns (uint) {
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
  function transfer(address recipient, uint amount) public virtual override returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  /**
   * @dev See {IERC20-allowance}.
   */
  function allowance(address owner, address spender) public view virtual override returns (uint) {
    return _allowances[owner][spender];
  }

  /**
   * @dev See {IERC20-approve}.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function approve(address spender, uint amount) public virtual override returns (bool) {
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
    uint amount
  ) public virtual override returns (bool) {
    _transfer(sender, recipient, amount);

    uint currentAllowance = _allowances[sender][_msgSender()];
    require(currentAllowance >= amount, 'ERC20: transfer amount exceeds allowance');
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
  function increaseAllowance(address spender, uint addedValue) public virtual returns (bool) {
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
  function decreaseAllowance(address spender, uint subtractedValue) public virtual returns (bool) {
    uint currentAllowance = _allowances[_msgSender()][spender];
    require(currentAllowance >= subtractedValue, 'ERC20: decreased allowance below zero');
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
    uint amount
  ) internal virtual {
    require(sender != address(0), 'ERC20: transfer from the zero address');
    require(recipient != address(0), 'ERC20: transfer to the zero address');

    _beforeTokenTransfer(sender, recipient, amount);

    uint senderBalance = _balances[sender];
    require(senderBalance >= amount, 'ERC20: transfer amount exceeds balance');
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
  function _mint(address account, uint amount) internal virtual {
    require(account != address(0), 'ERC20: mint to the zero address');

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
  function _burn(address account, uint amount) internal virtual {
    require(account != address(0), 'ERC20: burn from the zero address');

    _beforeTokenTransfer(account, address(0), amount);

    uint accountBalance = _balances[account];
    require(accountBalance >= amount, 'ERC20: burn amount exceeds balance');
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
    uint amount
  ) internal virtual {
    require(owner != address(0), 'ERC20: approve from the zero address');
    require(spender != address(0), 'ERC20: approve to the zero address');

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
    uint amount
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
    uint amount
  ) internal virtual {}
}

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
  // Booleans are more expensive than uint256 or any type that takes up a full
  // word because each write operation emits an extra SLOAD to first read the
  // slot's contents, replace the bits taken up by the boolean, and then write
  // back. This is the compiler's defense against contract upgrades and
  // pointer aliasing, and it cannot be disabled.

  // The values being non-zero value makes deployment a bit more expensive,
  // but in exchange the refund on every call to nonReentrant will be lower in
  // amount. Since refunds are capped to a percentage of the total
  // transaction's gas, it is best to keep them low in cases like this one, to
  // increase the likelihood of the full refund coming into effect.
  uint private constant _NOT_ENTERED = 1;
  uint private constant _ENTERED = 2;

  uint private _status;

  constructor() {
    _status = _NOT_ENTERED;
  }

  /**
   * @dev Prevents a contract from calling itself, directly or indirectly.
   * Calling a `nonReentrant` function from another `nonReentrant`
   * function is not supported. It is possible to prevent this from happening
   * by making the `nonReentrant` function external, and making it call a
   * `private` function that does the actual work.
   */
  modifier nonReentrant() {
    // On the first call to nonReentrant, _notEntered will be true
    require(_status != _ENTERED, 'ReentrancyGuard: reentrant call');

    // Any calls to nonReentrant after this point will fail
    _status = _ENTERED;

    _;

    // By storing the original value once again, a refund is triggered (see
    // https://eips.ethereum.org/EIPS/eip-2200)
    _status = _NOT_ENTERED;
  }
}

pragma solidity ^0.8.0;

contract C3SwapTriad is I3SwapTriad, ERC20, ReentrancyGuard {
  using Math for uint;
  using UQ112x112 for uint224;

  event Mint(uint liquidity, address to);
  event Burn(uint liquidity, address to);
  event Update(uint112 reserve0, uint112 reserve1, uint112 reserve2, uint32 timestamp);
  event Swap(
    uint amount0In,
    uint amount1In,
    uint amount2In,
    uint amount0Out,
    uint amount1Out,
    uint amount2Out,
    address to
  );
  event Initialized(address token0, address token1, address token2);

  uint public constant MINIMUM_LIQUIDITY = 10**3;

  struct ReserveKeys {
    uint112 reserve0;
    uint112 reserve1;
    uint112 reserve2;
  } // Added to surmount stack too deep errors

  struct ValueKeys {
    uint amount0;
    uint amount1;
    uint amount2;
  } // Added to surmount stack too deep errors

  address public token0;
  address public token1;
  address public token2;
  address public factory;

  ReserveKeys private reserveKeys;
  uint32 private blockTimestampLast;
  uint public price0CumulativeLast;
  uint public price1CumulativeLast;
  uint public price2CumulativeLast;
  uint public kLast;

  modifier onlyFactory() {
    require(msg.sender == factory, 'forbidden');
    _;
  }

  constructor() ERC20('3Swap Triad', '3Swap V1') {
    factory = msg.sender;
  }

  receive() external payable {}

  function getReserves()
    public
    view
    returns (
      uint112 _reserve0,
      uint112 _reserve1,
      uint112 _reserve2,
      uint32 _blockTimestampLast
    )
  {
    _reserve0 = reserveKeys.reserve0;
    _reserve1 = reserveKeys.reserve1;
    _reserve2 = reserveKeys.reserve2;
    _blockTimestampLast = blockTimestampLast;
  }

  function _mintFee(
    uint112 _reserve0,
    uint112 _reserve1,
    uint112 _reserve2
  ) private returns (bool _feeOn) {
    address feeTo = I3SwapFactory(factory).feeTo();
    _feeOn = feeTo != address(0);
    uint _kLast = kLast;
    if (_feeOn) {
      if (_kLast != 0) {
        uint rootK = Math.sqrt((uint(_reserve0).add(uint(_reserve1))).mul(uint(_reserve2))).div(10**18);
        uint rootKLast = Math.sqrt(_kLast).div(10**18);
        if (rootK > rootKLast) {
          uint totalSup = totalSupply();
          uint liquidity = totalSup.mul(rootK.sub(rootKLast)) / rootK.mul(5).add(rootKLast);

          if (liquidity > 0) _mint(feeTo, liquidity);
        }
      }
    } else if (_kLast != 0) {
      kLast = 0;
    }
  }

  function _update(
    uint balance0,
    uint balance1,
    uint balance2,
    uint112 _reserve0,
    uint112 _reserve1,
    uint112 _reserve2
  ) private {
    require(
      balance0 <= uint112(uint(int(-1))) && balance1 <= uint112(uint(int(-1))) && balance2 <= uint112(uint(int(-1))),
      'overflow'
    );
    uint32 blockTimestamp = uint32(block.timestamp % 2**32);
    uint32 timeElapsed = blockTimestamp - blockTimestampLast;

    if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0 && _reserve2 != 0) {
      price0CumulativeLast += uint(UQ112x112.encode(_reserve1 + _reserve2).uqdiv(_reserve0)) * timeElapsed;
      price1CumulativeLast += uint(UQ112x112.encode(_reserve2 + _reserve0).uqdiv(_reserve1)) * timeElapsed;
      price2CumulativeLast += uint(UQ112x112.encode(_reserve1 + _reserve0).uqdiv(_reserve2)) * timeElapsed;
    }

    reserveKeys = ReserveKeys({reserve0: uint112(balance0), reserve1: uint112(balance1), reserve2: uint112(balance2)});
    blockTimestampLast = blockTimestamp;
    emit Update(reserveKeys.reserve0, reserveKeys.reserve1, reserveKeys.reserve2, blockTimestamp);
  }

  function mint(address to) external nonReentrant returns (uint liquidity) {
    (uint112 _reserve0, uint112 _reserve1, uint112 _reserve2, ) = getReserves();
    uint balance0 = IERC20(token0).balanceOf(address(this));
    uint balance1 = IERC20(token1).balanceOf(address(this));
    uint balance2 = IERC20(token2).balanceOf(address(this));
    uint amount0 = Math.sub(balance0, _reserve0);
    uint amount1 = Math.sub(balance1, _reserve1);
    uint amount2 = Math.sub(balance2, _reserve2);

    bool feeOn = _mintFee(_reserve0, _reserve1, _reserve2);
    uint _totalSupply = totalSupply();

    if (_totalSupply == 0) {
      liquidity = Math.sqrt(((amount0.add(amount1)).mul(amount2))).div(10**18).sub(MINIMUM_LIQUIDITY);
      _mint(msg.sender, MINIMUM_LIQUIDITY);
      _burn(msg.sender, MINIMUM_LIQUIDITY);
    } else {
      liquidity = Math.min(
        amount0.add(amount1).mul(_totalSupply) / uint(_reserve0 + _reserve1),
        amount2.mul(_totalSupply).div(uint(_reserve2))
      );
    }

    require(liquidity > 0, 'insufficient_liquidity_minted');
    _mint(to, liquidity);
    _update(balance0, balance1, balance2, _reserve0, _reserve1, _reserve2);
    if (feeOn) kLast = uint(reserveKeys.reserve0 + reserveKeys.reserve1).mul(reserveKeys.reserve2);
    emit Mint(liquidity, to);
  }

  function burn(address to)
    external
    nonReentrant
    returns (
      uint amount0,
      uint amount1,
      uint amount2
    )
  {
    (uint112 _reserve0, uint112 _reserve1, uint112 _reserve2, ) = getReserves();
    uint balance0 = IERC20(token0).balanceOf(address(this));
    uint balance1 = IERC20(token1).balanceOf(address(this));
    uint balance2 = IERC20(token2).balanceOf(address(this));
    uint liquidity = balanceOf(address(this));

    bool feeOn = _mintFee(_reserve0, _reserve1, _reserve2);
    uint _totalSupply = totalSupply();
    {
      amount0 = liquidity.mul(balance0) / _totalSupply;
      amount1 = liquidity.mul(balance1) / _totalSupply;
      amount2 = liquidity.mul(balance2) / _totalSupply;
    }
    require(amount0 > 0 && amount1 > 0 && amount2 > 0, 'insufficient_liquidity_burned');
    _burn(address(this), liquidity);

    _safeTransfer(token0, to, amount0);
    _safeTransfer(token1, to, amount1);
    _safeTransfer(token2, to, amount2);
    {
      balance0 = IERC20(token0).balanceOf(address(this));
      balance1 = IERC20(token1).balanceOf(address(this));
      balance2 = IERC20(token2).balanceOf(address(this));
    }

    _update(balance0, balance1, balance2, _reserve0, _reserve1, _reserve2);

    if (feeOn) kLast = uint(reserveKeys.reserve0 + reserveKeys.reserve1).mul(reserveKeys.reserve2);
    emit Burn(liquidity, to);
  }

  function _initSwap(ValueKeys memory valueKeys, address to)
    private
    returns (
      ReserveKeys memory _reserveKeys,
      uint balance0,
      uint balance1,
      uint balance2,
      uint amount0In,
      uint amount1In,
      uint amount2In
    )
  {
    require(valueKeys.amount0 > 0 || valueKeys.amount1 > 0 || valueKeys.amount2 > 0, 'insufficient_output_amount');
    (uint112 _reserve0, uint112 _reserve1, uint112 _reserve2, ) = getReserves();
    require(
      valueKeys.amount0 < _reserve0 && valueKeys.amount1 < _reserve1 && valueKeys.amount2 < _reserve2,
      'insufficient_liquidity'
    );
    require(to != token0 && to != token1 && to != token2, 'invalid_to');
    if (valueKeys.amount0 > 0) _safeTransfer(token0, to, valueKeys.amount0);
    if (valueKeys.amount1 > 0) _safeTransfer(token1, to, valueKeys.amount1);
    if (valueKeys.amount2 > 0) _safeTransfer(token2, to, valueKeys.amount2);
    balance0 = IERC20(token0).balanceOf(address(this));
    balance1 = IERC20(token1).balanceOf(address(this));
    balance2 = IERC20(token2).balanceOf(address(this));

    uint _left0 = _reserve0 - valueKeys.amount0;
    uint _left1 = _reserve1 - valueKeys.amount1;
    uint _left2 = _reserve2 - valueKeys.amount2;

    amount0In = balance0 > _left0 ? balance0 - (_left0) : 0;
    amount1In = balance1 > _left1 ? balance1 - (_left1) : 0;
    amount2In = balance2 > _left2 ? balance2 - (_left2) : 0;
    _reserveKeys = ReserveKeys({reserve0: _reserve0, reserve1: _reserve1, reserve2: _reserve2});
  }

  function swap(
    uint amount0Out,
    uint amount1Out,
    uint amount2Out,
    address to
  ) external nonReentrant {
    (
      ReserveKeys memory _keys,
      uint balance0,
      uint balance1,
      uint balance2,
      uint amount0In,
      uint amount1In,
      uint amount2In
    ) = _initSwap(ValueKeys({amount0: amount0Out, amount1: amount1Out, amount2: amount2Out}), to);
    require(amount0In > 0 || amount1In > 0 || amount2In > 0, 'insufficient_input_amount');
    {
      uint balance0Adjusted = balance0.mul(1000).sub(amount0In.mul(3));
      uint balance1Adjusted = balance1.mul(1000).sub(amount1In.mul(3));
      uint balance2Adjusted = balance2.mul(1000).sub(amount2In.mul(3));
      require(
        (balance0Adjusted + balance1Adjusted).mul(balance2Adjusted) >=
          uint(_keys.reserve0 + _keys.reserve1).mul(_keys.reserve2).mul(1000**2),
        'k'
      );
    }

    _update(balance0, balance1, balance2, _keys.reserve0, _keys.reserve1, _keys.reserve2);
    emit Swap(amount0In, amount1In, amount2In, amount0Out, amount1Out, amount2Out, to);
  }

  function initialize(
    address t0,
    address t1,
    address t2
  ) external onlyFactory {
    token0 = t0;
    token1 = t1;
    token2 = t2;
    emit Initialized(token0, token1, token2);
  }

  function skim(address to) external nonReentrant {
    address _token0 = token0;
    address _token1 = token1;
    address _token2 = token2;
    _safeTransfer(_token0, to, IERC20(_token0).balanceOf(address(this)).sub(reserveKeys.reserve0));
    _safeTransfer(_token1, to, IERC20(_token1).balanceOf(address(this)).sub(reserveKeys.reserve1));
    _safeTransfer(_token2, to, IERC20(_token2).balanceOf(address(this)).sub(reserveKeys.reserve2));
  }

  function sync() external nonReentrant {
    _update(
      IERC20(token0).balanceOf(address(this)),
      IERC20(token1).balanceOf(address(this)),
      IERC20(token2).balanceOf(address(this)),
      reserveKeys.reserve0,
      reserveKeys.reserve1,
      reserveKeys.reserve2
    );
  }

  function _safeTransfer(
    address token_,
    address to_,
    uint value
  ) private {
    (bool success, bytes memory data) = token_.call(
      abi.encodeWithSelector(bytes4(keccak256(bytes('transfer(address,uint256)'))), to_, value)
    );
    require(success && (data.length == 0 || abi.decode(data, (bool))));
  }
}

pragma solidity ^0.8.0;

contract C3SwapFactory is I3SwapFactory {
  address public feeTo;
  address public feeToSetter;

  event TriadCreated(
    address indexed token0,
    address indexed token1,
    address indexed token2,
    address triad,
    bytes bytecode
  );

  mapping(address => mapping(address => mapping(address => address))) public getTriads;
  address[] public allTriads;

  constructor(address _feeToSetter) {
    feeToSetter = _feeToSetter;
  }

  function allTriadsLength() external view returns (uint) {
    return allTriads.length;
  }

  function createTriad(
    address token0,
    address token1,
    address token2
  ) external returns (address triad) {
    require(token0 != token1 && token1 != token2 && token0 != token2);
    (address tokenA, address tokenB) = token0 < token1 ? (token0, token1) : (token1, token0);
    (address tokenX, address tokenY) = tokenB < token2 ? (tokenB, token2) : (token2, tokenB);
    require(tokenA != address(0));
    require(getTriads[tokenA][tokenX][tokenY] == address(0));
    bytes memory bytecode = type(C3SwapTriad).creationCode;
    bytes32 salt = keccak256(abi.encodePacked(tokenA, tokenX, tokenY));

    assembly {
      triad := create2(0, add(bytecode, 32), mload(bytecode), salt)
    }
    I3SwapTriad(triad).initialize(tokenA, tokenX, tokenY);
    // Populate mapping in various directions. There are 6 ways this can be done (using n! = nx(n-1)x(n-2)x...3x2x1)
    getTriads[tokenA][tokenX][tokenY] = triad;
    getTriads[tokenX][tokenA][tokenY] = triad;
    getTriads[tokenX][tokenY][tokenA] = triad;
    getTriads[tokenY][tokenX][tokenA] = triad;
    getTriads[tokenY][tokenA][tokenX] = triad;
    getTriads[tokenA][tokenY][tokenX] = triad;
    allTriads.push(triad);

    emit TriadCreated(token0, token1, token2, triad, bytecode);
  }

  function setFeeTo(address _feeTo) external {
    require(msg.sender == feeToSetter);
    feeTo = _feeTo;
  }

  function setFeeToSetter(address _feeToSetter) external {
    require(msg.sender == feeToSetter);
    feeToSetter = _feeToSetter;
  }
}