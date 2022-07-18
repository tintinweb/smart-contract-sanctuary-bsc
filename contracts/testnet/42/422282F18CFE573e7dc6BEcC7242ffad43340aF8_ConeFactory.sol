// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import "../../interface/IFactory.sol";
import "./ConePair.sol";

contract ConeFactory is IFactory {

  bool public override isPaused;
  address public pauser;
  address public pendingPauser;

  mapping(address => mapping(address => mapping(bool => address))) public override getPair;
  address[] public allPairs;
  /// @dev Simplified check if its a pair, given that `stable` flag might not be available in peripherals
  mapping(address => bool) public override isPair;

  address internal _temp0;
  address internal _temp1;
  bool internal _temp;

  event PairCreated(
    address indexed token0,
    address indexed token1,
    bool stable,
    address pair,
    uint allPairsLength
  );

  constructor() {
    pauser = msg.sender;
    isPaused = false;
  }

  function allPairsLength() external view returns (uint) {
    return allPairs.length;
  }

  function setPauser(address _pauser) external {
    require(msg.sender == pauser, "ConeFactory: Not pauser");
    pendingPauser = _pauser;
  }

  function acceptPauser() external {
    require(msg.sender == pendingPauser, "ConeFactory: Not pending pauser");
    pauser = pendingPauser;
  }

  function setPause(bool _state) external {
    require(msg.sender == pauser, "ConeFactory: Not pauser");
    isPaused = _state;
  }

  function setSwapFee(address pair, uint value) external {
    require(msg.sender == pauser, "ConeFactory: Not pauser");
    ConePair(pair).setSwapFee(value);
  }

  function pairCodeHash() external pure override returns (bytes32) {
    return keccak256(type(ConePair).creationCode);
  }

  function getInitializable() external view override returns (address, address, bool) {
    return (_temp0, _temp1, _temp);
  }

  function createPair(address tokenA, address tokenB, bool stable)
  external override returns (address pair) {
    require(tokenA != tokenB, 'ConeFactory: IDENTICAL_ADDRESSES');
    (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    require(token0 != address(0), 'ConeFactory: ZERO_ADDRESS');
    require(getPair[token0][token1][stable] == address(0), 'ConeFactory: PAIR_EXISTS');
    // notice salt includes stable as well, 3 parameters
    bytes32 salt = keccak256(abi.encodePacked(token0, token1, stable));
    (_temp0, _temp1, _temp) = (token0, token1, stable);
    pair = address(new ConePair{salt : salt}());
    getPair[token0][token1][stable] = pair;
    // populate mapping in the reverse direction
    getPair[token1][token0][stable] = pair;
    allPairs.push(pair);
    isPair[pair] = true;
    emit PairCreated(token0, token1, stable, pair, allPairs.length);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface IFactory {

  function isPair(address pair) external view returns (bool);

  function getInitializable() external view returns (address, address, bool);

  function isPaused() external view returns (bool);

  function pairCodeHash() external pure returns (bytes32);

  function getPair(address tokenA, address token, bool stable) external view returns (address);

  function createPair(address tokenA, address tokenB, bool stable) external returns (address pair);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import "../../interface/IERC20.sol";
import "../../interface/IERC721Metadata.sol";
import "../../interface/IPair.sol";
import "../../interface/IFactory.sol";
import "../../interface/ICallee.sol";
import "../../interface/IUnderlying.sol";
import "./PairFees.sol";
import "../../lib/Math.sol";
import "../../lib/SafeERC20.sol";
import "../Reentrancy.sol";

// The base pair of pools, either stable or volatile
contract ConePair is IERC20, IPair, Reentrancy {
  using SafeERC20 for IERC20;

  string public name;
  string public symbol;
  uint8 public constant decimals = 18;

  /// @dev Used to denote stable or volatile pair
  bool public immutable stable;

  uint public override totalSupply = 0;

  mapping(address => mapping(address => uint)) public override allowance;
  mapping(address => uint) public override balanceOf;

  bytes32 public immutable DOMAIN_SEPARATOR;
  // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
  bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
  uint internal constant _FEE_PRECISION = 1e32;
  mapping(address => uint) public nonces;
  uint public immutable chainId;

  uint internal constant MINIMUM_LIQUIDITY = 10 ** 3;
  /// @dev 0.01% swap fee
  uint internal constant SWAP_FEE_STABLE = 10_000;
  /// @dev 0.05% swap fee
  uint internal constant SWAP_FEE_VOLATILE = 2_000;
  /// @dev 0.1% max allowed swap fee
  uint internal constant SWAP_FEE_MAX = 1_000;
  /// @dev Capture oracle reading every 30 minutes
  uint internal constant PERIOD_SIZE = 1800;


  address public immutable override token0;
  address public immutable override token1;
  address public immutable fees;
  address public immutable factory;

  Observation[] public observations;

  uint public swapFee;
  uint internal immutable decimals0;
  uint internal immutable decimals1;

  uint public reserve0;
  uint public reserve1;
  uint public blockTimestampLast;

  uint public reserve0CumulativeLast;
  uint public reserve1CumulativeLast;

  // index0 and index1 are used to accumulate fees,
  // this is split out from normal trades to keep the swap "clean"
  // this further allows LP holders to easily claim fees for tokens they have/staked
  uint public index0 = 0;
  uint public index1 = 0;

  // position assigned to each LP to track their current index0 & index1 vs the global position
  mapping(address => uint) public supplyIndex0;
  mapping(address => uint) public supplyIndex1;

  // tracks the amount of unclaimed, but claimable tokens off of fees for token0 and token1
  mapping(address => uint) public claimable0;
  mapping(address => uint) public claimable1;

  event Treasury(address indexed sender, uint amount0, uint amount1);
  event Fees(address indexed sender, uint amount0, uint amount1);
  event Mint(address indexed sender, uint amount0, uint amount1);
  event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
  event Swap(
    address indexed sender,
    uint amount0In,
    uint amount1In,
    uint amount0Out,
    uint amount1Out,
    address indexed to
  );
  event Sync(uint reserve0, uint reserve1);
  event Claim(address indexed sender, address indexed recipient, uint amount0, uint amount1);
  event FeesChanged(uint newValue);

  constructor() {
    factory = msg.sender;
    (address _token0, address _token1, bool _stable) = IFactory(msg.sender).getInitializable();
    (token0, token1, stable) = (_token0, _token1, _stable);
    fees = address(new PairFees(_token0, _token1));

    swapFee = _stable ? SWAP_FEE_STABLE : SWAP_FEE_VOLATILE;

    if (_stable) {
      name = string(abi.encodePacked("StableV1 AMM - ", IERC721Metadata(_token0).symbol(), "/", IERC721Metadata(_token1).symbol()));
      symbol = string(abi.encodePacked("sAMM-", IERC721Metadata(_token0).symbol(), "/", IERC721Metadata(_token1).symbol()));
    } else {
      name = string(abi.encodePacked("VolatileV1 AMM - ", IERC721Metadata(_token0).symbol(), "/", IERC721Metadata(_token1).symbol()));
      symbol = string(abi.encodePacked("vAMM-", IERC721Metadata(_token0).symbol(), "/", IERC721Metadata(_token1).symbol()));
    }

    decimals0 = 10 ** IUnderlying(_token0).decimals();
    decimals1 = 10 ** IUnderlying(_token1).decimals();

    observations.push(Observation(block.timestamp, 0, 0));

    DOMAIN_SEPARATOR = keccak256(
      abi.encode(
        keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'),
        keccak256(bytes(name)),
        keccak256('1'),
        block.chainid,
        address(this)
      )
    );
    chainId = block.chainid;
  }

  function setSwapFee(uint value) external {
    require(msg.sender == factory, "!factory");
    require(value >= SWAP_FEE_MAX, "max");
    swapFee = value;
    emit FeesChanged(value);
  }

  function observationLength() external view returns (uint) {
    return observations.length;
  }

  function lastObservation() public view returns (Observation memory) {
    return observations[observations.length - 1];
  }

  function metadata() external view returns (
    uint dec0,
    uint dec1,
    uint r0,
    uint r1,
    bool st,
    address t0,
    address t1
  ) {
    return (decimals0, decimals1, reserve0, reserve1, stable, token0, token1);
  }

  function tokens() external view override returns (address, address) {
    return (token0, token1);
  }

  /// @dev Claim accumulated but unclaimed fees (viewable via claimable0 and claimable1)
  function claimFees() external override returns (uint claimed0, uint claimed1) {
    _updateFor(msg.sender);

    claimed0 = claimable0[msg.sender];
    claimed1 = claimable1[msg.sender];

    if (claimed0 > 0 || claimed1 > 0) {
      claimable0[msg.sender] = 0;
      claimable1[msg.sender] = 0;

      PairFees(fees).claimFeesFor(msg.sender, claimed0, claimed1);

      emit Claim(msg.sender, msg.sender, claimed0, claimed1);
    }
  }

  /// @dev Accrue fees on token0
  function _update0(uint amount) internal {
    // transfer the fees out to PairFees
    IERC20(token0).safeTransfer(fees, amount);
    // 1e32 adjustment is removed during claim
    uint _ratio = amount * _FEE_PRECISION / totalSupply;
    if (_ratio > 0) {
      index0 += _ratio;
    }
    emit Fees(msg.sender, amount, 0);
  }

  /// @dev Accrue fees on token1
  function _update1(uint amount) internal {
    IERC20(token1).safeTransfer(fees, amount);
    uint _ratio = amount * _FEE_PRECISION / totalSupply;
    if (_ratio > 0) {
      index1 += _ratio;
    }
    emit Fees(msg.sender, 0, amount);
  }

  /// @dev This function MUST be called on any balance changes,
  ///      otherwise can be used to infinitely claim fees
  //       Fees are segregated from core funds, so fees can never put liquidity at risk
  function _updateFor(address recipient) internal {
    uint _supplied = balanceOf[recipient];
    // get LP balance of `recipient`
    if (_supplied > 0) {
      uint _supplyIndex0 = supplyIndex0[recipient];
      // get last adjusted index0 for recipient
      uint _supplyIndex1 = supplyIndex1[recipient];
      uint _index0 = index0;
      // get global index0 for accumulated fees
      uint _index1 = index1;
      supplyIndex0[recipient] = _index0;
      // update user current position to global position
      supplyIndex1[recipient] = _index1;
      uint _delta0 = _index0 - _supplyIndex0;
      // see if there is any difference that need to be accrued
      uint _delta1 = _index1 - _supplyIndex1;
      if (_delta0 > 0) {
        uint _share = _supplied * _delta0 / _FEE_PRECISION;
        // add accrued difference for each supplied token
        claimable0[recipient] += _share;
      }
      if (_delta1 > 0) {
        uint _share = _supplied * _delta1 / _FEE_PRECISION;
        claimable1[recipient] += _share;
      }
    } else {
      supplyIndex0[recipient] = index0;
      // new users are set to the default global state
      supplyIndex1[recipient] = index1;
    }
  }

  function getReserves() public view override returns (
    uint112 _reserve0,
    uint112 _reserve1,
    uint32 _blockTimestampLast
  ) {
    _reserve0 = uint112(reserve0);
    _reserve1 = uint112(reserve1);
    _blockTimestampLast = uint32(blockTimestampLast);
  }

  /// @dev Update reserves and, on the first call per block, price accumulators
  function _update(uint balance0, uint balance1, uint _reserve0, uint _reserve1) internal {
    uint blockTimestamp = block.timestamp;
    uint timeElapsed = blockTimestamp - blockTimestampLast;
    // overflow is desired
    if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
    unchecked {
      reserve0CumulativeLast += _reserve0 * timeElapsed;
      reserve1CumulativeLast += _reserve1 * timeElapsed;
    }
    }

    Observation memory _point = lastObservation();
    timeElapsed = blockTimestamp - _point.timestamp;
    // compare the last observation with current timestamp,
    // if greater than 30 minutes, record a new event
    if (timeElapsed > PERIOD_SIZE) {
      observations.push(Observation(blockTimestamp, reserve0CumulativeLast, reserve1CumulativeLast));
    }
    reserve0 = balance0;
    reserve1 = balance1;
    blockTimestampLast = blockTimestamp;
    emit Sync(reserve0, reserve1);
  }

  /// @dev Produces the cumulative price using counterfactuals to save gas and avoid a call to sync.
  function currentCumulativePrices() public view returns (
    uint reserve0Cumulative,
    uint reserve1Cumulative,
    uint blockTimestamp
  ) {
    blockTimestamp = block.timestamp;
    reserve0Cumulative = reserve0CumulativeLast;
    reserve1Cumulative = reserve1CumulativeLast;

    // if time has elapsed since the last update on the pair, mock the accumulated price values
    (uint _reserve0, uint _reserve1, uint _blockTimestampLast) = getReserves();
    if (_blockTimestampLast != blockTimestamp) {
      // subtraction overflow is desired
      uint timeElapsed = blockTimestamp - _blockTimestampLast;
    unchecked {
      reserve0Cumulative += _reserve0 * timeElapsed;
      reserve1Cumulative += _reserve1 * timeElapsed;
    }
    }
  }

  /// @dev Gives the current twap price measured from amountIn * tokenIn gives amountOut
  function current(address tokenIn, uint amountIn) external view returns (uint amountOut) {
    Observation memory _observation = lastObservation();
    (uint reserve0Cumulative, uint reserve1Cumulative,) = currentCumulativePrices();
    if (block.timestamp == _observation.timestamp) {
      _observation = observations[observations.length - 2];
    }

    uint timeElapsed = block.timestamp - _observation.timestamp;
    uint _reserve0 = (reserve0Cumulative - _observation.reserve0Cumulative) / timeElapsed;
    uint _reserve1 = (reserve1Cumulative - _observation.reserve1Cumulative) / timeElapsed;
    amountOut = _getAmountOut(amountIn, tokenIn, _reserve0, _reserve1);
  }

  /// @dev As per `current`, however allows user configured granularity, up to the full window size
  function quote(address tokenIn, uint amountIn, uint granularity)
  external view returns (uint amountOut) {
    uint [] memory _prices = sample(tokenIn, amountIn, granularity, 1);
    uint priceAverageCumulative;
    for (uint i = 0; i < _prices.length; i++) {
      priceAverageCumulative += _prices[i];
    }
    return priceAverageCumulative / granularity;
  }

  /// @dev Returns a memory set of twap prices
  function prices(address tokenIn, uint amountIn, uint points)
  external view returns (uint[] memory) {
    return sample(tokenIn, amountIn, points, 1);
  }

  function sample(address tokenIn, uint amountIn, uint points, uint window)
  public view returns (uint[] memory) {
    uint[] memory _prices = new uint[](points);

    uint length = observations.length - 1;
    uint i = length - (points * window);
    uint nextIndex = 0;
    uint index = 0;

    for (; i < length; i += window) {
      nextIndex = i + window;
      uint timeElapsed = observations[nextIndex].timestamp - observations[i].timestamp;
      uint _reserve0 = (observations[nextIndex].reserve0Cumulative - observations[i].reserve0Cumulative) / timeElapsed;
      uint _reserve1 = (observations[nextIndex].reserve1Cumulative - observations[i].reserve1Cumulative) / timeElapsed;
      _prices[index] = _getAmountOut(amountIn, tokenIn, _reserve0, _reserve1);
      index = index + 1;
    }
    return _prices;
  }

  /// @dev This low-level function should be called from a contract which performs important safety checks
  ///      standard uniswap v2 implementation
  function mint(address to) external lock override returns (uint liquidity) {
    (uint _reserve0, uint _reserve1) = (reserve0, reserve1);
    uint _balance0 = IERC20(token0).balanceOf(address(this));
    uint _balance1 = IERC20(token1).balanceOf(address(this));
    uint _amount0 = _balance0 - _reserve0;
    uint _amount1 = _balance1 - _reserve1;

    uint _totalSupply = totalSupply;
    // gas savings, must be defined here since totalSupply can update in _mintFee
    if (_totalSupply == 0) {
      liquidity = Math.sqrt(_amount0 * _amount1) - MINIMUM_LIQUIDITY;
      // permanently lock the first MINIMUM_LIQUIDITY tokens
      _mint(address(0), MINIMUM_LIQUIDITY);
    } else {
      liquidity = Math.min(_amount0 * _totalSupply / _reserve0, _amount1 * _totalSupply / _reserve1);
    }
    require(liquidity > 0, 'ConePair: INSUFFICIENT_LIQUIDITY_MINTED');
    _mint(to, liquidity);

    _update(_balance0, _balance1, _reserve0, _reserve1);
    emit Mint(msg.sender, _amount0, _amount1);
  }

  /// @dev This low-level function should be called from a contract which performs important safety checks
  ///      standard uniswap v2 implementation
  function burn(address to) external lock override returns (uint amount0, uint amount1) {
    (uint _reserve0, uint _reserve1) = (reserve0, reserve1);
    (address _token0, address _token1) = (token0, token1);
    uint _balance0 = IERC20(_token0).balanceOf(address(this));
    uint _balance1 = IERC20(_token1).balanceOf(address(this));
    uint _liquidity = balanceOf[address(this)];

    // gas savings, must be defined here since totalSupply can update in _mintFee
    uint _totalSupply = totalSupply;
    // using balances ensures pro-rata distribution
    amount0 = _liquidity * _balance0 / _totalSupply;
    // using balances ensures pro-rata distribution
    amount1 = _liquidity * _balance1 / _totalSupply;
    require(amount0 > 0 && amount1 > 0, 'ConePair: INSUFFICIENT_LIQUIDITY_BURNED');
    _burn(address(this), _liquidity);
    IERC20(_token0).safeTransfer(to, amount0);
    IERC20(_token1).safeTransfer(to, amount1);
    _balance0 = IERC20(_token0).balanceOf(address(this));
    _balance1 = IERC20(_token1).balanceOf(address(this));

    _update(_balance0, _balance1, _reserve0, _reserve1);
    emit Burn(msg.sender, amount0, amount1, to);
  }

  /// @dev This low-level function should be called from a contract which performs important safety checks
  function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external override lock {
    require(!IFactory(factory).isPaused(), "ConePair: PAUSE");
    require(amount0Out > 0 || amount1Out > 0, 'ConePair: INSUFFICIENT_OUTPUT_AMOUNT');
    (uint _reserve0, uint _reserve1) = (reserve0, reserve1);
    require(amount0Out < _reserve0 && amount1Out < _reserve1, 'ConePair: INSUFFICIENT_LIQUIDITY');
    uint _balance0;
    uint _balance1;
    {// scope for _token{0,1}, avoids stack too deep errors
      (address _token0, address _token1) = (token0, token1);
      require(to != _token0 && to != _token1, 'ConePair: INVALID_TO');
      // optimistically transfer tokens
      if (amount0Out > 0) IERC20(_token0).safeTransfer(to, amount0Out);
      // optimistically transfer tokens
      if (amount1Out > 0) IERC20(_token1).safeTransfer(to, amount1Out);
      // callback, used for flash loans
      if (data.length > 0) ICallee(to).hook(msg.sender, amount0Out, amount1Out, data);
      _balance0 = IERC20(_token0).balanceOf(address(this));
      _balance1 = IERC20(_token1).balanceOf(address(this));
    }
    uint amount0In = _balance0 > _reserve0 - amount0Out ? _balance0 - (_reserve0 - amount0Out) : 0;
    uint amount1In = _balance1 > _reserve1 - amount1Out ? _balance1 - (_reserve1 - amount1Out) : 0;
    require(amount0In > 0 || amount1In > 0, 'ConePair: INSUFFICIENT_INPUT_AMOUNT');
    {// scope for reserve{0,1}Adjusted, avoids stack too deep errors
      (address _token0, address _token1) = (token0, token1);
      // accrue fees for token0 and move them out of pool
      if (amount0In > 0) _update0(amount0In / swapFee);
      // accrue fees for token1 and move them out of pool
      if (amount1In > 0) _update1(amount1In / swapFee);
      // since we removed tokens, we need to reconfirm balances,
      // can also simply use previous balance - amountIn/ SWAP_FEE,
      // but doing balanceOf again as safety check
      _balance0 = IERC20(_token0).balanceOf(address(this));
      _balance1 = IERC20(_token1).balanceOf(address(this));
      // The curve, either x3y+y3x for stable pools, or x*y for volatile pools
      require(_k(_balance0, _balance1) >= _k(_reserve0, _reserve1), 'ConePair: K');
    }

    _update(_balance0, _balance1, _reserve0, _reserve1);
    emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
  }

  /// @dev Force balances to match reserves
  function skim(address to) external lock {
    (address _token0, address _token1) = (token0, token1);
    IERC20(_token0).safeTransfer(to, IERC20(_token0).balanceOf(address(this)) - (reserve0));
    IERC20(_token1).safeTransfer(to, IERC20(_token1).balanceOf(address(this)) - (reserve1));
  }

  // force reserves to match balances
  function sync() external lock {
    _update(
      IERC20(token0).balanceOf(address(this)),
      IERC20(token1).balanceOf(address(this)),
      reserve0,
      reserve1
    );
  }

  function _f(uint x0, uint y) internal pure returns (uint) {
    return x0 * (y * y / 1e18 * y / 1e18) / 1e18 + (x0 * x0 / 1e18 * x0 / 1e18) * y / 1e18;
  }

  function _d(uint x0, uint y) internal pure returns (uint) {
    return 3 * x0 * (y * y / 1e18) / 1e18 + (x0 * x0 / 1e18 * x0 / 1e18);
  }

  function _getY(uint x0, uint xy, uint y) internal pure returns (uint) {
    for (uint i = 0; i < 255; i++) {
      uint yPrev = y;
      uint k = _f(x0, y);
      if (k < xy) {
        uint dy = (xy - k) * 1e18 / _d(x0, y);
        y = y + dy;
      } else {
        uint dy = (k - xy) * 1e18 / _d(x0, y);
        y = y - dy;
      }
      if (Math.closeTo(y, yPrev, 1)) {
        break;
      }
    }
    return y;
  }

  function getAmountOut(uint amountIn, address tokenIn) external view override returns (uint) {
    (uint _reserve0, uint _reserve1) = (reserve0, reserve1);
    // remove fee from amount received
    amountIn -= amountIn / swapFee;
    return _getAmountOut(amountIn, tokenIn, _reserve0, _reserve1);
  }

  function _getAmountOut(uint amountIn, address tokenIn, uint _reserve0, uint _reserve1) internal view returns (uint) {
    if (stable) {
      uint xy = _k(_reserve0, _reserve1);
      _reserve0 = _reserve0 * 1e18 / decimals0;
      _reserve1 = _reserve1 * 1e18 / decimals1;
      (uint reserveA, uint reserveB) = tokenIn == token0 ? (_reserve0, _reserve1) : (_reserve1, _reserve0);
      amountIn = tokenIn == token0 ? amountIn * 1e18 / decimals0 : amountIn * 1e18 / decimals1;
      uint y = reserveB - _getY(amountIn + reserveA, xy, reserveB);
      return y * (tokenIn == token0 ? decimals1 : decimals0) / 1e18;
    } else {
      (uint reserveA, uint reserveB) = tokenIn == token0 ? (_reserve0, _reserve1) : (_reserve1, _reserve0);
      return amountIn * reserveB / (reserveA + amountIn);
    }
  }

  function _k(uint x, uint y) internal view returns (uint) {
    if (stable) {
      uint _x = x * 1e18 / decimals0;
      uint _y = y * 1e18 / decimals1;
      uint _a = (_x * _y) / 1e18;
      uint _b = ((_x * _x) / 1e18 + (_y * _y) / 1e18);
      // x3y+y3x >= k
      return _a * _b / 1e18;
    } else {
      // xy >= k
      return x * y;
    }
  }

  //****************************************************************************
  //**************************** ERC20 *****************************************
  //****************************************************************************

  function _mint(address dst, uint amount) internal {
    // balances must be updated on mint/burn/transfer
    _updateFor(dst);
    totalSupply += amount;
    balanceOf[dst] += amount;
    emit Transfer(address(0), dst, amount);
  }

  function _burn(address dst, uint amount) internal {
    _updateFor(dst);
    totalSupply -= amount;
    balanceOf[dst] -= amount;
    emit Transfer(dst, address(0), amount);
  }

  function approve(address spender, uint amount) external override returns (bool) {
    require(spender != address(0), "ConePair: Approve to the zero address");
    allowance[msg.sender][spender] = amount;

    emit Approval(msg.sender, spender, amount);
    return true;
  }

  function permit(
    address owner,
    address spender,
    uint value,
    uint deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external override {
    require(deadline >= block.timestamp, 'ConePair: EXPIRED');
    bytes32 digest = keccak256(
      abi.encodePacked(
        '\x19\x01',
        DOMAIN_SEPARATOR,
        keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline))
      )
    );
    address recoveredAddress = ecrecover(digest, v, r, s);
    require(recoveredAddress != address(0) && recoveredAddress == owner, 'ConePair: INVALID_SIGNATURE');
    allowance[owner][spender] = value;

    emit Approval(owner, spender, value);
  }

  function transfer(address dst, uint amount) external override returns (bool) {
    _transferTokens(msg.sender, dst, amount);
    return true;
  }

  function transferFrom(address src, address dst, uint amount) external override returns (bool) {
    address spender = msg.sender;
    uint spenderAllowance = allowance[src][spender];

    if (spender != src && spenderAllowance != type(uint).max) {
      require(spenderAllowance >= amount, "ConePair: Insufficient allowance");
    unchecked {
      uint newAllowance = spenderAllowance - amount;
      allowance[src][spender] = newAllowance;
      emit Approval(src, spender, newAllowance);
    }
    }

    _transferTokens(src, dst, amount);
    return true;
  }

  function _transferTokens(address src, address dst, uint amount) internal {
    require(dst != address(0), "ConePair: Transfer to the zero address");

    // update fee position for src
    _updateFor(src);
    // update fee position for dst
    _updateFor(dst);

    uint srcBalance = balanceOf[src];
    require(srcBalance >= amount, "ConePair: Transfer amount exceeds balance");
  unchecked {
    balanceOf[src] = srcBalance - amount;
  }

    balanceOf[dst] += amount;

    emit Transfer(src, dst, amount);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

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

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import "./IERC721.sol";

/**
* @title ERC-721 Non-Fungible Token Standard, optional metadata extension
* @dev See https://eips.ethereum.org/EIPS/eip-721
*/
interface IERC721Metadata is IERC721 {
  /**
  * @dev Returns the token collection name.
  */
  function name() external view returns (string memory);

  /**
  * @dev Returns the token collection symbol.
  */
  function symbol() external view returns (string memory);

  /**
  * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
  */
  function tokenURI(uint tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface IPair {

  // Structure to capture time period obervations every 30 minutes, used for local oracles
  struct Observation {
    uint timestamp;
    uint reserve0Cumulative;
    uint reserve1Cumulative;
  }

  function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

  function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

  function burn(address to) external returns (uint amount0, uint amount1);

  function mint(address to) external returns (uint liquidity);

  function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);

  function getAmountOut(uint, address) external view returns (uint);

  function claimFees() external returns (uint, uint);

  function tokens() external view returns (address, address);

  function token0() external view returns (address);

  function token1() external view returns (address);

  function stable() external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface ICallee {
  function hook(address sender, uint amount0, uint amount1, bytes calldata data) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface IUnderlying {
  function approve(address spender, uint value) external returns (bool);

  function mint(address, uint) external;

  function totalSupply() external view returns (uint);

  function balanceOf(address) external view returns (uint);

  function transfer(address, uint) external returns (bool);

  function decimals() external returns (uint8);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import "../../interface/IERC20.sol";
import "../../lib/SafeERC20.sol";

/// @title Base V1 Fees contract is used as a 1:1 pair relationship to split out fees,
///        this ensures that the curve does not need to be modified for LP shares
contract PairFees {
  using SafeERC20 for IERC20;

  /// @dev The pair it is bonded to
  address internal immutable pair;
  /// @dev Token0 of pair, saved localy and statically for gas optimization
  address internal immutable token0;
  /// @dev Token1 of pair, saved localy and statically for gas optimization
  address internal immutable token1;

  constructor(address _token0, address _token1) {
    pair = msg.sender;
    token0 = _token0;
    token1 = _token1;
  }

  // Allow the pair to transfer fees to users
  function claimFeesFor(address recipient, uint amount0, uint amount1) external {
    require(msg.sender == pair, "Not pair");
    if (amount0 > 0) {
      IERC20(token0).safeTransfer(recipient, amount0);
    }
    if (amount1 > 0) {
      IERC20(token1).safeTransfer(recipient, amount1);
    }
  }

}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

library Math {

  function max(uint a, uint b) internal pure returns (uint) {
    return a >= b ? a : b;
  }

  function min(uint a, uint b) internal pure returns (uint) {
    return a < b ? a : b;
  }

  function positiveInt128(int128 value) internal pure returns (int128) {
    return value < 0 ? int128(0) : value;
  }

  function closeTo(uint a, uint b, uint target) internal pure returns (bool) {
    if (a > b) {
      if (a - b <= target) {
        return true;
      }
    } else {
      if (b - a <= target) {
        return true;
      }
    }
    return false;
  }

  function sqrt(uint y) internal pure returns (uint z) {
    if (y > 3) {
      z = y;
      uint x = y / 2 + 1;
      while (x < z) {
        z = x;
        x = (y / x + x) / 2;
      }
    } else if (y != 0) {
      z = 1;
    }
  }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity 0.8.15;

import "../interface/IERC20.sol";
import "./Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  using Address for address;

  function safeTransfer(
    IERC20 token,
    address to,
    uint value
  ) internal {
    _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
  }

  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint value
  ) internal {
    _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
  }

  function safeIncreaseAllowance(
    IERC20 token,
    address spender,
    uint value
  ) internal {
    uint newAllowance = token.allowance(address(this), spender) + value;
    _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
  }

  /**
   * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
  function _callOptionalReturn(IERC20 token, bytes memory data) private {
    // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
    // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
    // the target address contains contract code and also asserts for success in the low-level call.

    bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
    if (returndata.length > 0) {
      // Return data is optional
      require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
    }
  }

}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

abstract contract Reentrancy {

  /// @dev simple re-entrancy check
  uint internal _unlocked = 1;

  modifier lock() {
    require(_unlocked == 1, "Reentrant call");
    _unlocked = 2;
    _;
    _unlocked = 1;
  }

}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import "./IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
  /**
   * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
   */
  event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

  /**
   * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
   */
  event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

  /**
   * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
   */
  event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

  /**
   * @dev Returns the number of tokens in ``owner``'s account.
   */
  function balanceOf(address owner) external view returns (uint256 balance);

  /**
   * @dev Returns the owner of the `tokenId` token.
   *
   * Requirements:
   *
   * - `tokenId` must exist.
   */
  function ownerOf(uint256 tokenId) external view returns (address owner);

  /**
   * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
   * are aware of the ERC721 protocol to prevent tokens from being forever locked.
   *
   * Requirements:
   *
   * - `from` cannot be the zero address.
   * - `to` cannot be the zero address.
   * - `tokenId` token must exist and be owned by `from`.
   * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
   * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
   *
   * Emits a {Transfer} event.
   */
  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId
  ) external;

  /**
   * @dev Transfers `tokenId` token from `from` to `to`.
   *
   * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
   *
   * Requirements:
   *
   * - `from` cannot be the zero address.
   * - `to` cannot be the zero address.
   * - `tokenId` token must be owned by `from`.
   * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(
    address from,
    address to,
    uint256 tokenId
  ) external;

  /**
   * @dev Gives permission to `to` to transfer `tokenId` token to another account.
   * The approval is cleared when the token is transferred.
   *
   * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
   *
   * Requirements:
   *
   * - The caller must own the token or be an approved operator.
   * - `tokenId` must exist.
   *
   * Emits an {Approval} event.
   */
  function approve(address to, uint256 tokenId) external;

  /**
   * @dev Returns the account approved for `tokenId` token.
   *
   * Requirements:
   *
   * - `tokenId` must exist.
   */
  function getApproved(uint256 tokenId) external view returns (address operator);

  /**
   * @dev Approve or remove `operator` as an operator for the caller.
   * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
   *
   * Requirements:
   *
   * - The `operator` cannot be the caller.
   *
   * Emits an {ApprovalForAll} event.
   */
  function setApprovalForAll(address operator, bool _approved) external;

  /**
   * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
   *
   * See {setApprovalForAll}
   */
  function isApprovedForAll(address owner, address operator) external view returns (bool);

  /**
   * @dev Safely transfers `tokenId` token from `from` to `to`.
   *
   * Requirements:
   *
   * - `from` cannot be the zero address.
   * - `to` cannot be the zero address.
   * - `tokenId` token must exist and be owned by `from`.
   * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
   * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
   *
   * Emits a {Transfer} event.
   */
  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId,
    bytes calldata data
  ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
  /**
   * @dev Returns true if this contract implements the interface defined by
   * `interfaceId`. See the corresponding
   * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
   * to learn more about how these ids are created.
   *
   * This function call must use less than 30 000 gas.
   */
  function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity 0.8.15;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
  /**
   * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
  function isContract(address account) internal view returns (bool) {
    // This method relies on extcodesize/address.code.length, which returns 0
    // for contracts in construction, since the code is only stored at the end
    // of the constructor execution.

    return account.code.length > 0;
  }

  function functionCall(
    address target,
    bytes memory data,
    string memory errorMessage
  ) internal returns (bytes memory) {
    require(isContract(target), "Address: call to non-contract");
    (bool success, bytes memory returndata) = target.call(data);
    return verifyCallResult(success, returndata, errorMessage);
  }

  /**
   * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
  function verifyCallResult(
    bool success,
    bytes memory returndata,
    string memory errorMessage
  ) internal pure returns (bytes memory) {
    if (success) {
      return returndata;
    } else {
      // Look for revert reason and bubble it up if present
      if (returndata.length > 0) {
        // The easiest way to bubble the revert reason is using memory via assembly
        assembly {
          let returndata_size := mload(returndata)
          revert(add(32, returndata), returndata_size)
        }
      } else {
        revert(errorMessage);
      }
    }
  }
}