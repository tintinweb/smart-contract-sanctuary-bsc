/**
 *Submitted for verification at BscScan.com on 2022-03-20
*/

// SPDX-License-Identifier: Unlicensed


pragma solidity ^0.7.4;

library SafeMathInt {
  int256 private constant MIN_INT256 = int256(1) << 255;
  int256 private constant MAX_INT256 = ~(int256(1) << 255);

  function mul(int256 a, int256 b) internal pure returns (int256) {
    int256 c = a * b;

    require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
    require((b == 0) || (c / b == a));
    return c;
  }

  function div(int256 a, int256 b) internal pure returns (int256) {
    require(b != -1 || a != MIN_INT256);

    return a / b;
  }

  function sub(int256 a, int256 b) internal pure returns (int256) {
    int256 c = a - b;
    require((b >= 0 && c <= a) || (b < 0 && c > a));
    return c;
  }

  function add(int256 a, int256 b) internal pure returns (int256) {
    int256 c = a + b;
    require((b >= 0 && c >= a) || (b < 0 && c < a));
    return c;
  }

  function abs(int256 a) internal pure returns (int256) {
    require(a != MIN_INT256);
    return a < 0 ? -a : a;
  }
}

library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    uint256 c = a / b;

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external
    view
    returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value) external returns (bool);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IPancakeSwapPair {
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);

  function name() external pure returns (string memory);

  function symbol() external pure returns (string memory);

  function decimals() external pure returns (uint8);

  function totalSupply() external view returns (uint256);

  function balanceOf(address owner) external view returns (uint256);

  function allowance(address owner, address spender)
    external
    view
    returns (uint256);

  function approve(address spender, uint256 value) external returns (bool);

  function transfer(address to, uint256 value) external returns (bool);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool);

  function DOMAIN_SEPARATOR() external view returns (bytes32);

  function PERMIT_TYPEHASH() external pure returns (bytes32);

  function nonces(address owner) external view returns (uint256);

  function permit(
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;

  event Mint(address indexed sender, uint256 amount0, uint256 amount1);
  event Burn(
    address indexed sender,
    uint256 amount0,
    uint256 amount1,
    address indexed to
  );
  event Swap(
    address indexed sender,
    uint256 amount0In,
    uint256 amount1In,
    uint256 amount0Out,
    uint256 amount1Out,
    address indexed to
  );
  event Sync(uint112 reserve0, uint112 reserve1);

  function MINIMUM_LIQUIDITY() external pure returns (uint256);

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

  function price0CumulativeLast() external view returns (uint256);

  function price1CumulativeLast() external view returns (uint256);

  function kLast() external view returns (uint256);

  function mint(address to) external returns (uint256 liquidity);

  function burn(address to) external returns (uint256 amount0, uint256 amount1);

  function swap(
    uint256 amount0Out,
    uint256 amount1Out,
    address to,
    bytes calldata data
  ) external;

  function skim(address to) external;

  function sync() external;

  function initialize(address, address) external;
}

interface IPancakeSwapRouter {
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

interface IPancakeSwapFactory {
  event PairCreated(
    address indexed token0,
    address indexed token1,
    address pair,
    uint256
  );

  function feeTo() external view returns (address);

  function feeToSetter() external view returns (address);

  function getPair(address tokenA, address tokenB)
    external
    view
    returns (address pair);

  function allPairs(uint256) external view returns (address pair);

  function allPairsLength() external view returns (uint256);

  function createPair(address tokenA, address tokenB)
    external
    returns (address pair);

  function setFeeTo(address) external;

  function setFeeToSetter(address) external;
}

contract Ownable {
  address private _owner;
  mapping(address => bool) internal authorizations;

  event OwnershipRenounced(address indexed previousOwner);

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  constructor() {
    _owner = msg.sender;
    authorizations[_owner] = true;
  }

  function owner() public view returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  modifier authorized() {
    require(isAuthorized(msg.sender), "!AUTHORIZED");
    _;
  }

  function authorize(address adr) public onlyOwner {
    authorizations[adr] = true;
  }

  function unauthorize(address adr) public onlyOwner {
    require(adr != _owner, "Cant remove owner");
    authorizations[adr] = false;
  }

  function isOwner() public view returns (bool) {
    return msg.sender == _owner;
  }

  function isAuthorized(address adr) public view returns (bool) {
    return authorizations[adr];
  }

  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(_owner);
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

abstract contract ERC20Detailed is IERC20 {
  string private _name;
  string private _symbol;
  uint8 private _decimals;

  constructor(
    string memory name_,
    string memory symbol_,
    uint8 decimals_
  ) {
    _name = name_;
    _symbol = symbol_;
    _decimals = decimals_;
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
}

contract OptiFi is ERC20Detailed, Ownable {
  using SafeMath for uint256;
  using SafeMathInt for int256;

  event LogRebase(uint256 indexed epoch, uint256 totalSupply);

  string public _name = "OptiFi";
  string public _symbol = "$OPTI";
  uint8 public _decimals = 5;

  IPancakeSwapPair public pairContract;
  mapping(address => bool) _isFeeExempt;

  modifier validRecipient(address to) {
    require(to != address(0x0));
    _;
  }

  uint256 public constant DECIMALS = 5;
  uint256 constant MAX_UINT256 = ~uint256(0);
  uint8 public constant RATE_DECIMALS = 7;

  uint256 private constant INITIAL_FRAGMENTS_SUPPLY =
    325 * 10**3 * 10**DECIMALS;

  uint256 public liquidityFee = 50;
  uint256 public treasuryFee = 50;
  uint256 public ecoFee = 10;
  uint256 public insuranceFundFee = 30;
  uint256 public sellFee = 40;
  uint256 public totalFee =
    liquidityFee.add(treasuryFee).add(ecoFee).add(insuranceFundFee);
  uint256 public feeDenominator = 1000;
  uint256 public buyFeeMultiplier = 72;
  uint256 public adjustedFeeTime;
  uint256 public goldenMinutesDuration = 4 minutes;

  uint256 public deadBlocks = 1;
  uint256 public launchBlock = 0;
  bool public tradingOpen;

  address DEAD = 0x000000000000000000000000000000000000dEaD;
  address ZERO = 0x0000000000000000000000000000000000000000;

  address public autoLiquidityReceiver;
  address public treasuryReceiver;
  address public ecoReceiver;
  address public insuranceFundReceiver;
  address public pairAddress;
  bool public swapEnabled = true;
  IPancakeSwapRouter public router;
  address public pair;
  bool inSwap = false;
  modifier swapping() {
    inSwap = true;
    _;
    inSwap = false;
  }

  uint256 private constant TOTAL_GONS =
    MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);

  uint256 private constant MAX_SUPPLY = 325 * 10**7 * 10**DECIMALS;

  bool public _autoRebase;
  bool public _autoAddLiquidity;
  uint256 public _initRebaseStartTime;
  uint256 public _lastRebasedTime;
  uint256 public _lastAddLiquidityTime;
  uint256 public _totalSupply;
  uint256 public _maxTxAmount = TOTAL_GONS.div(100).mul(1);
  uint256 private _gonsPerFragment;

  mapping(address => uint256) private _gonBalances;
  mapping(address => mapping(address => uint256)) private _allowedFragments;
  mapping(address => bool) public blacklist;
  mapping(address => bool) public isTxLimitExempt;

  constructor() ERC20Detailed("OptiFi", "$OPTI", uint8(DECIMALS)) Ownable() {
    router = IPancakeSwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    pair = IPancakeSwapFactory(router.factory()).createPair(
      router.WETH(),
      address(this)
    );

    autoLiquidityReceiver = 0x7f5942bBD09aD495aF81206cf0cbbA19E4a574E3;
    ecoReceiver = 0xe8d2105E7f20D2ebA92B8BD43208A3c3a69687ce;
    treasuryReceiver = 0x1A788076BC9553B4957b4542741B06d48B000660;
    insuranceFundReceiver = 0xe3B230c515464b3A96b72223b2699971e01739a1;

    _allowedFragments[address(this)][address(router)] = uint256(-1);
    pairAddress = pair;
    pairContract = IPancakeSwapPair(pair);

    _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
    _gonBalances[msg.sender] = TOTAL_GONS;
    _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
    _initRebaseStartTime = block.timestamp;
    _lastRebasedTime = block.timestamp;
    _autoRebase = false;
    _autoAddLiquidity = false;
    _isFeeExempt[treasuryReceiver] = true;
    _isFeeExempt[address(this)] = true;
    _isFeeExempt[msg.sender] = true;
    isTxLimitExempt[address(this)] = true;
    isTxLimitExempt[msg.sender] = true;
    isTxLimitExempt[treasuryReceiver] = true;

    emit Transfer(address(0x0), msg.sender, _totalSupply);
  }

  function rebase() internal {
    if (inSwap) return;

    uint256 rebaseRate;
    uint256 deltaTimeFromInit = block.timestamp - _initRebaseStartTime;
    uint256 deltaTime = block.timestamp - _lastRebasedTime;
    uint256 times = deltaTime.div(30 minutes);
    uint256 epoch = times.mul(30);

    if (deltaTimeFromInit < (365 days)) {
      rebaseRate = 4863;
    } else if (deltaTimeFromInit >= (2 * 365 days)) {
      rebaseRate = 4;
    } else if (deltaTimeFromInit >= ((365 days))) {
      rebaseRate = 245;
    }

    for (uint256 i = 0; i < times; i++) {
      _totalSupply = _totalSupply.mul((10**RATE_DECIMALS).add(rebaseRate)).div(
        10**RATE_DECIMALS
      );
    }

    _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
    _lastRebasedTime = _lastRebasedTime.add(times.mul(30 minutes));
    adjustedFeeTime = block.timestamp;

    pairContract.sync();

    emit LogRebase(epoch, _totalSupply);
  }

  function transfer(address to, uint256 value)
    external
    override
    validRecipient(to)
    returns (bool)
  {
    _transferFrom(msg.sender, to, value);
    return true;
  }

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external override validRecipient(to) returns (bool) {
    if (_allowedFragments[from][msg.sender] != uint256(-1)) {
      _allowedFragments[from][msg.sender] = _allowedFragments[from][msg.sender]
        .sub(value, "Insufficient Allowance");
    }
    _transferFrom(from, to, value);
    return true;
  }

  function _basicTransfer(
    address from,
    address to,
    uint256 amount
  ) internal returns (bool) {
    uint256 gonAmount = amount.mul(_gonsPerFragment);
    _gonBalances[from] = _gonBalances[from].sub(gonAmount);
    _gonBalances[to] = _gonBalances[to].add(gonAmount);
    return true;
  }

  function _transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) internal returns (bool) {
    if (!authorizations[sender] && !authorizations[recipient]) {
      require(tradingOpen, "Trading is not enabled");
      require(
        !blacklist[sender] && !blacklist[recipient],
        "Wallet is blacklisted"
      );
    }

    if (inSwap) {
      return _basicTransfer(sender, recipient, amount);
    }
    if (shouldRebase()) {
      rebase();
    }

    if (shouldAddLiquidity()) {
      addLiquidity();
    }

    if (shouldSwapBack()) {
      swapBack();
    }

    uint256 gonAmount = amount.mul(_gonsPerFragment);
    checkTxLimit(sender, gonAmount);

    _gonBalances[sender] = _gonBalances[sender].sub(gonAmount);
    uint256 gonAmountReceived = shouldTakeFee(sender, recipient)
      ? takeFee(sender, recipient, gonAmount)
      : gonAmount;
    _gonBalances[recipient] = _gonBalances[recipient].add(gonAmountReceived);

    emit Transfer(sender, recipient, gonAmountReceived.div(_gonsPerFragment));
    return true;
  }

  function isGoldenMinutes() internal view returns (bool) {
    if (block.timestamp - adjustedFeeTime < goldenMinutesDuration) {
      return true;
    } else {
      return false;
    }
  }

  function takeFee(
    address sender,
    address recipient,
    uint256 gonAmount
  ) internal returns (uint256) {
    uint256 _totalFee = totalFee;

    if (recipient == pair) {
      _totalFee = totalFee.add(sellFee);
    }

    if (sender == pair) {
      if ((launchBlock + deadBlocks) > block.number) {
        _totalFee = 990;
      }
    }

    if (isGoldenMinutes()) {
      if (sender == pair) {
        _totalFee = _totalFee.mul(buyFeeMultiplier).div(100);
      }
    }

    uint256 feeAmount = gonAmount.div(feeDenominator).mul(_totalFee);

    _gonBalances[address(this)] = _gonBalances[address(this)].add(
      feeAmount.mul(_totalFee.sub(liquidityFee)).div(_totalFee)
    );
    _gonBalances[autoLiquidityReceiver] = _gonBalances[autoLiquidityReceiver]
      .add(feeAmount.mul(liquidityFee).div(_totalFee));

    emit Transfer(sender, address(this), feeAmount.div(_gonsPerFragment));
    return gonAmount.sub(feeAmount);
  }

  function addLiquidity() internal swapping {
    uint256 autoLiquidityAmount = _gonBalances[autoLiquidityReceiver].div(
      _gonsPerFragment
    );
    _gonBalances[address(this)] = _gonBalances[address(this)].add(
      _gonBalances[autoLiquidityReceiver]
    );
    _gonBalances[autoLiquidityReceiver] = 0;
    uint256 amountToLiquify = autoLiquidityAmount.div(2);
    uint256 amountToSwap = autoLiquidityAmount.sub(amountToLiquify);

    if (amountToSwap == 0) {
      return;
    }
    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = router.WETH();

    uint256 balanceBefore = address(this).balance;

    router.swapExactTokensForETHSupportingFeeOnTransferTokens(
      amountToSwap,
      0,
      path,
      address(this),
      block.timestamp
    );

    uint256 amountETHLiquidity = address(this).balance.sub(balanceBefore);

    if (amountToLiquify > 0 && amountETHLiquidity > 0) {
      router.addLiquidityETH{value: amountETHLiquidity}(
        address(this),
        amountToLiquify,
        0,
        0,
        autoLiquidityReceiver,
        block.timestamp
      );
    }
    _lastAddLiquidityTime = block.timestamp;
  }

  function swapBack() internal swapping {
    uint256 amountToSwap = _gonBalances[address(this)].div(_gonsPerFragment);

    if (amountToSwap == 0) {
      return;
    }

    uint256 balanceBefore = address(this).balance;
    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = router.WETH();

    router.swapExactTokensForETHSupportingFeeOnTransferTokens(
      amountToSwap,
      0,
      path,
      address(this),
      block.timestamp
    );

    uint256 amountETHToTreasuryAndAIF = address(this).balance.sub(
      balanceBefore
    );

    (bool success, ) = payable(ecoReceiver).call{
      value: amountETHToTreasuryAndAIF.mul(ecoFee).div(
        treasuryFee.add(insuranceFundFee).add(ecoFee)
      ),
      gas: 30000
    }("");
    (success, ) = payable(treasuryReceiver).call{
      value: amountETHToTreasuryAndAIF.mul(treasuryFee).div(
        treasuryFee.add(insuranceFundFee).add(ecoFee)
      ),
      gas: 30000
    }("");
    (success, ) = payable(insuranceFundReceiver).call{
      value: amountETHToTreasuryAndAIF.mul(insuranceFundFee).div(
        treasuryFee.add(insuranceFundFee).add(ecoFee)
      ),
      gas: 30000
    }("");
  }

  function withdrawAllToTreasury() external swapping onlyOwner {
    uint256 amountToSwap = _gonBalances[address(this)].div(_gonsPerFragment);
    require(
      amountToSwap > 0,
      "There are no OptiFi tokens deposited in token contract"
    );
    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = router.WETH();
    router.swapExactTokensForETHSupportingFeeOnTransferTokens(
      amountToSwap,
      0,
      path,
      treasuryReceiver,
      block.timestamp
    );
  }

  function shouldTakeFee(address from, address to)
    internal
    view
    returns (bool)
  {
    return (pair == from || pair == to) && !_isFeeExempt[from];
  }

  function shouldRebase() internal view returns (bool) {
    return
      _autoRebase &&
      (_totalSupply < MAX_SUPPLY) &&
      msg.sender != pair &&
      !inSwap &&
      block.timestamp >= (_lastRebasedTime + 30 minutes);
  }

  function shouldAddLiquidity() internal view returns (bool) {
    return
      _autoAddLiquidity &&
      !inSwap &&
      msg.sender != pair &&
      block.timestamp >= (_lastAddLiquidityTime + 1 days);
  }

  function shouldSwapBack() internal view returns (bool) {
    return !inSwap && msg.sender != pair;
  }

  function setAutoRebase(bool _flag) external onlyOwner {
    if (_flag) {
      _autoRebase = _flag;
      _lastRebasedTime = block.timestamp;
    } else {
      _autoRebase = _flag;
    }
  }

  function setAutoAddLiquidity(bool _flag) external onlyOwner {
    if (_flag) {
      _autoAddLiquidity = _flag;
      _lastAddLiquidityTime = block.timestamp;
    } else {
      _autoAddLiquidity = _flag;
    }
  }

  function allowance(address owner_, address spender)
    external
    view
    override
    returns (uint256)
  {
    return _allowedFragments[owner_][spender];
  }

  function decreaseAllowance(address spender, uint256 subtractedValue)
    external
    returns (bool)
  {
    uint256 oldValue = _allowedFragments[msg.sender][spender];
    if (subtractedValue >= oldValue) {
      _allowedFragments[msg.sender][spender] = 0;
    } else {
      _allowedFragments[msg.sender][spender] = oldValue.sub(subtractedValue);
    }
    emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue)
    external
    returns (bool)
  {
    _allowedFragments[msg.sender][spender] = _allowedFragments[msg.sender][
      spender
    ].add(addedValue);
    emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);
    return true;
  }

  function approve(address spender, uint256 value)
    external
    override
    returns (bool)
  {
    _allowedFragments[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  function checkFeeExempt(address _addr) external view returns (bool) {
    return _isFeeExempt[_addr];
  }

  function checkTxLimit(address sender, uint256 gonAmount) internal view {
    require(
      gonAmount <= _maxTxAmount || isTxLimitExempt[sender],
      "TX Limit Exceeded"
    );
  }

  function checkMaxTxAmount() external view returns (uint256) {
    return _maxTxAmount.div(_gonsPerFragment);
  }

  function setMaxTxPercent_base1000(uint256 maxTXPercentage_base1000)
    external
    onlyOwner
  {
    _maxTxAmount = TOTAL_GONS.div(1000).mul(maxTXPercentage_base1000);
  }

  function setIsTxLimitExempt(address holder, bool exempt) external onlyOwner {
    isTxLimitExempt[holder] = exempt;
  }

  function getCirculatingSupply() public view returns (uint256) {
    return
      (TOTAL_GONS.sub(_gonBalances[DEAD]).sub(_gonBalances[ZERO])).div(
        _gonsPerFragment
      );
  }

  function isNotInSwap() external view returns (bool) {
    return !inSwap;
  }

  function manualSync() external {
    IPancakeSwapPair(pair).sync();
  }

  function setFeeReceivers(
    address _autoLiquidityReceiver,
    address _treasuryReceiver,
    address _insuranceFundReceiver,
    address _ecoReceiver
  ) external onlyOwner {
    autoLiquidityReceiver = _autoLiquidityReceiver;
    treasuryReceiver = _treasuryReceiver;
    insuranceFundReceiver = _insuranceFundReceiver;
    ecoReceiver = _ecoReceiver;
  }

  function setGoldenMinutesMultiplier(uint256 _buyMultiplier)
    external
    onlyOwner
  {
    require(_buyMultiplier <= 100, "Cannot increase buy fees");
    buyFeeMultiplier = _buyMultiplier;
  }

  function setGoldenMinutesDuration(uint256 _durationInSec) external onlyOwner {
    goldenMinutesDuration = _durationInSec;
  }

  function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
    uint256 liquidityBalance = _gonBalances[pair].div(_gonsPerFragment);
    return accuracy.mul(liquidityBalance.mul(2)).div(getCirculatingSupply());
  }

  function airDrop(
    address from,
    address[] calldata addresses,
    uint256[] calldata tokens
  ) external onlyOwner {
    require(
      addresses.length == tokens.length,
      "Length of addresses and tokens dont match"
    );
    require(
      (from == owner()) || from == (address(this)),
      "Can airDrop only from owner or contract balance"
    );
    for (uint256 i; i < addresses.length; ++i) {
      _basicTransfer(from, addresses[i], tokens[i]);
    }
  }

  function setWhitelist(address _addr) external onlyOwner {
    _isFeeExempt[_addr] = true;
  }

  function setBotBlacklist(address _botAddress, bool _flag) external onlyOwner {
    blacklist[_botAddress] = _flag;
  }

  function setPairAddress(address _pairAddress) public onlyOwner {
    pairAddress = _pairAddress;
  }

  function setLP(address _address) external onlyOwner {
    pairContract = IPancakeSwapPair(_address);
  }

  function totalSupply() external view override returns (uint256) {
    return _totalSupply;
  }

  function rescueToken(address tokenAddress, uint256 tokens)
    external
    onlyOwner
    returns (bool success)
  {
    return ERC20Detailed(tokenAddress).transfer(msg.sender, tokens);
  }

  function balanceOf(address who) external view override returns (uint256) {
    return _gonBalances[who].div(_gonsPerFragment);
  }

  function tradingStatus(bool _status, uint256 _deadBlocks) public onlyOwner {
    tradingOpen = _status;
    require(_deadBlocks <= 10, "Max 10 deadblocks allowed");
    if (tradingOpen && launchBlock == 0) {
      launchBlock = block.number;
      deadBlocks = _deadBlocks;
    }
  }

  receive() external payable {}
}