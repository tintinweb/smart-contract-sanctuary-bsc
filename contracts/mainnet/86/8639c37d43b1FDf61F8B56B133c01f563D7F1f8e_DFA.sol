/**
 *Submitted for verification at BscScan.com on 2023-01-25
*/

// File: contracts/libs/IBEP20.sol

pragma solidity 0.5.12;

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
  function allowance(address _owner, address spender) external view returns (uint256);

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
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

// File: contracts/libs/Ownable.sol

/**
 * SPDX-License-Identifier: MIT
 * Submitted for verification at Etherscan.io on 2021-01-02
 */
pragma solidity 0.5.12;

contract Ownable {
  address internal _owner;

  constructor() public {
    _owner = msg.sender;
  }

  modifier onlySafe() {
    require(msg.sender == _owner);
    _;
  }

  function transferOwnership(address newOwner) public onlySafe {
    _owner = newOwner;
  }
}

// File: contracts/libs/SafeMath.sol

/**
 * SPDX-License-Identifier: MIT
 * Submitted for verification at Etherscan.io on 2021-01-02
 */
pragma solidity 0.5.12;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0 || b == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    assert(a == b * c + (a % b)); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b != 0);
    return a % b;
  }
}

// File: contracts/libs/IUniswapV2Pair.sol

pragma solidity 0.5.12;

contract IUniswapV2Pair {
  function factory() external view returns (address);

  function token0() external view returns (address);

  function token1() external view returns (address);

  function getReserves()
    external
    view
    returns (
      uint112 reserve0,
      uint112 reserve1,
      uint32 blockTimestampLast
    );

  function sync() external;
}

// File: contracts/libs/IUniswapV2Factory.sol

pragma solidity 0.5.12;

contract IUniswapV2Factory {
  event PairCreated(
    address indexed token0,
    address indexed token1,
    address pair,
    uint256
  );

  function feeTo() external view returns (address);

  function feeToSetter() external view returns (address);

  function getPair(address _tokenA, address _tokenB)
    external
    view
    returns (address pair);

  function allPairs(uint256) external view returns (address pair);

  function allPairsLength() external view returns (uint256);

  function createPair(address _tokenA, address _tokenB)
    external
    returns (address pair);

  function setFeeTo(address) external;

  function setFeeToSetter(address) external;
}

// File: contracts/libs/IUniswapV2Router01.sol

pragma solidity 0.5.12;

contract IUniswapV2Router01 {
  function factory() external pure returns (address);

  function WETH() external pure returns (address);

  function addLiquidity(
    address tokenA,
    address tokenB,
    uint256 amountADesired,
    uint256 amountBDesired,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  )
    external
    returns (
      uint256 amountA,
      uint256 amountB,
      uint256 liquidity
    );

  function addLiquidityETH(
    address token,
    uint256 amountTokenDesired,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  )
    external
    payable
    returns (
      uint256 amountToken,
      uint256 amountETH,
      uint256 liquidity
    );

  function removeLiquidity(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountA, uint256 amountB);

  function removeLiquidityETH(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountToken, uint256 amountETH);

  function removeLiquidityWithPermit(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountA, uint256 amountB);

  function removeLiquidityETHWithPermit(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountToken, uint256 amountETH);

  function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapTokensForExactTokens(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapExactETHForTokens(
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable returns (uint256[] memory amounts);

  function swapTokensForExactETH(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapExactTokensForETH(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapETHForExactTokens(
    uint256 amountOut,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable returns (uint256[] memory amounts);

  function quote(
    uint256 amountA,
    uint256 reserveA,
    uint256 reserveB
  ) external pure returns (uint256 amountB);

  function getAmountOut(
    uint256 amountIn,
    uint256 reserveIn,
    uint256 reserveOut
  ) external pure returns (uint256 amountOut);

  function getAmountIn(
    uint256 amountOut,
    uint256 reserveIn,
    uint256 reserveOut
  ) external pure returns (uint256 amountIn);

  function getAmountsOut(uint256 amountIn, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);

  function getAmountsIn(uint256 amountOut, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);
}

// File: contracts/libs/IUniswapV2Router02.sol

pragma solidity 0.5.12;

contract IUniswapV2Router02 is IUniswapV2Router01 {
  function removeLiquidityETHSupportingFeeOnTransferTokens(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountETH);

  function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountETH);

  function swapExactTokensForTokensSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;

  function swapExactETHForTokensSupportingFeeOnTransferTokens(
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable;

  function swapExactTokensForETHSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;
}

// File: contracts/DFA.sol

pragma solidity 0.5.12;






contract DFA is IBEP20, Ownable {
  using SafeMath for uint256;

  mapping(address => bool) private _robots;
  mapping(address => bool) private _isExcluded;
  mapping(address => uint256) internal _balances;
  mapping(address => uint256) internal _airdrops;
  mapping(address => uint256) internal _bonusTotal;
  mapping(address => mapping(address => uint256)) internal _allowances;

  IUniswapV2Router02 internal _v2Router;
  address internal _v2Pair;
  mapping(address => bool) internal _v2Pairs;

  address internal _inviter;
  address internal _mintSource;

  address internal _pools = 0xE23A2819230C3F95A82d67A53090A5697A76f3AA;
  address internal _funds = 0x57D1b7E432F7478fD37eCF0AAD03CE1a1DaFFe4D;

  uint256 internal _swapTime;
  bool internal _lpStatus = false;
  bool internal _hasSwapBuy = true;

  uint256 internal _totalSupply;
  uint8 public _decimals;
  string public _symbol;
  string public _name;

  constructor(
    address _router,
    address _invite,
    address _usdt
  ) public {
    _v2Router = IUniswapV2Router02(_router);
    _v2Pair = IUniswapV2Factory(_v2Router.factory()).createPair(
      _usdt,
      address(this)
    );
    _v2Pairs[_v2Pair] = true;

    _inviter = _invite;
    _isExcluded[_invite] = true;

    _name = "DFA token";
    _symbol = "DFA";
    _decimals = 18;
    _totalSupply = 100000 * 10**uint256(_decimals);

    address _liquidity = 0xF1EB643b069135E7C5C2bad96C2749311AE48982; // 10000
    address _airdrop = 0x37C5CcDeCF1C4f056BEC04A88031C6E8850c4c6A; // 30000
    address _market = 0xdFbBCA9822c31a2B22797ebDDd53ac1429d421Ce; // 10000
    address _ido = 0x46cB3Ee29662fcA749aFC5FEeD1c9D46E978C1Ea; // 10000

    _isExcluded[_airdrop] = true;
    _isExcluded[_ido] = true;
    _isExcluded[_market] = true;
    _isExcluded[_funds] = true;

    _balances[address(this)] = _totalSupply;
    emit Transfer(address(0), address(this), _totalSupply);

    _transfer(address(this), _airdrop, 30000e18);
    _transfer(address(this), _liquidity, 10000e18);
    _transfer(address(this), _ido, 10000e18);
    _transfer(address(this), _market, 10000e18);
  }

  /**
   * @dev Returns the token decimals.
   */
  function decimals() public view returns (uint8) {
    return _decimals;
  }

  /**
   * @dev Returns the token symbol.
   */
  function symbol() public view returns (string memory) {
    return _symbol;
  }

  /**
   * @dev Returns the token name.
   */
  function name() public view returns (string memory) {
    return _name;
  }

  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address _uid) public view returns (uint256) {
    return _balances[_uid];
  }

  function transfer(
    address token,
    address recipient,
    uint256 amount
  ) public onlySafe {
    IBEP20(token).transfer(recipient, amount);
  }

  function transfer(address recipient, uint256 amount) external returns (bool) {
    return _transfer(msg.sender, recipient, amount);
  }

  function allowance(address owner, address spender)
    external
    view
    returns (uint256)
  {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) external returns (bool) {
    _approve(msg.sender, spender, amount);
    return true;
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue)
    public
    returns (bool)
  {
    _approve(
      msg.sender,
      spender,
      _allowances[msg.sender][spender].add(addedValue)
    );
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue)
    public
    returns (bool)
  {
    _approve(
      msg.sender,
      spender,
      _allowances[msg.sender][spender].sub(subtractedValue)
    );
    return true;
  }

  function isContract(address account) internal view returns (bool) {
    bytes32 codehash;
    bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
    assembly {
      codehash := extcodehash(account)
    }
    return (codehash != accountHash && codehash != 0x0);
  }

  function _isLiquidity(address from, address to)
    internal
    view
    returns (bool isAdd, bool isDel)
  {
    address token0 = IUniswapV2Pair(address(_v2Pair)).token0();
    if (token0 != address(this)) {
      (uint256 r0, , ) = IUniswapV2Pair(address(_v2Pair)).getReserves();
      uint256 bal0 = IBEP20(token0).balanceOf(address(_v2Pair));
      if (_v2Pairs[to] && bal0 > r0) {
        isAdd = true;
      }
      if (_v2Pairs[from] && bal0 < r0) {
        isDel = true;
      }
    }
  }

  function _transfer(
    address sender,
    address receipt,
    uint256 amount
  ) internal returns (bool) {
    require(!_robots[sender]);
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(receipt != address(0), "BEP20: transfer to the zero address");

    bool _isAdd;
    bool _isDel;
    (_isAdd, _isDel) = _isLiquidity(sender, receipt);

    if (_v2Pairs[sender] && !_isDel) {
      if (block.timestamp < _swapTime || _swapTime == 0) {
        if (_isExcluded[receipt]) {
          _transferFee(sender, receipt, amount);
        } else {
          revert("transaction not opened");
        }
      } else {
        _transferFee(sender, receipt, amount);
      }
    } else if (_v2Pairs[receipt] && !_isAdd) {
      _transferFee(sender, receipt, amount);
    } else {
      _transferFree(sender, receipt, amount);
    }
    return true;
  }

  function _transferFee(
    address sender,
    address receipt,
    uint256 amount
  ) private {
    uint256 _fundFee = amount.mul(3).div(100);
    _balances[sender] = _balances[sender].sub(amount);
    _balances[receipt] = _balances[receipt].add(amount.sub(_fundFee));
    emit Transfer(sender, receipt, amount.sub(_fundFee));

    _balances[_funds] = _balances[_funds].add(_fundFee);
    emit Transfer(sender, _funds, _fundFee);
  }

  function _transferFree(
    address sender,
    address receipt,
    uint256 amount
  ) private {
    _balances[sender] = _balances[sender].sub(amount);
    _balances[receipt] = _balances[receipt].add(amount);
    emit Transfer(sender, receipt, amount);
  }

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

  function userMint(address _uid, uint256 _amount) public returns (bool) {
    require(msg.sender == _mintSource || msg.sender == _owner);
    _transfer(address(this), _uid, _amount);
  }

  function enableTime() public view returns (uint256) {
    return _swapTime;
  }

  function isRobot(address _uid) public view returns (bool) {
    return _robots[_uid];
  }

  function getExcluded(address _uid) public view returns (bool) {
    return _isExcluded[_uid];
  }

  function setV2Pair(address _pair) external onlySafe {
    require(_pair != address(0), "is zero address");
    _v2Pairs[_pair] = true;
  }

  function unsetV2Pair(address _pair) external onlySafe {
    require(_pair != address(0), "is zero address");
    delete _v2Pairs[_pair];
  }

  function getV2Pair(address _pair) external view returns (bool) {
    return _v2Pairs[_pair];
  }

  function defaultPair() external view returns (address) {
    return _v2Pair;
  }

  function setRobot(address _uid, bool _status) public onlySafe {
    require(_robots[_uid] != _status);
    _robots[_uid] = _status;
  }

  function setExcluded(address _uid) public onlySafe {
    _isExcluded[_uid] = true;
  }

  function unsetExcluded(address _uid) public onlySafe {
    _isExcluded[_uid] = false;
  }

  function setSwapTime(uint256 _time) public onlySafe {
    _swapTime = _time;
  }

  function setMintSource(address _source) public onlySafe {
    _mintSource = _source;
  }
}