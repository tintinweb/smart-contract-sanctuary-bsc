/**
 *Submitted for verification at BscScan.com on 2022-04-30
*/

// PEPPERBIRD TOKEN BEP 20 Source Code
// BUILD 007
// pepperbird.finance
// 4/29/2022
//////////////////////////////////////////////////////////////

// SPDX-License-Identifier: MIT
pragma solidity =0.8.9;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
  /**
   * @dev Returns the addition of two unsigned integers, with an overflow flag.
   *
   * _Available since v3.4._
   */
  function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
      uint256 c = a + b;
      if (c < a) return (false, 0);
      return (true, c);
    }
  }

  /**
   * @dev Returns the substraction of two unsigned integers, with an overflow flag.
   *
   * _Available since v3.4._
   */
  function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
      if (b > a) return (false, 0);
      return (true, a - b);
    }
  }

  /**
   * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
   *
   * _Available since v3.4._
   */
  function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
      // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
      // benefit is lost if 'b' is also tested.
      // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
      if (a == 0) return (true, 0);
      uint256 c = a * b;
      if (c / a != b) return (false, 0);
      return (true, c);
    }
  }

  /**
   * @dev Returns the division of two unsigned integers, with a division by zero flag.
   *
   * _Available since v3.4._
   */
  function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
      if (b == 0) return (false, 0);
      return (true, a / b);
    }
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
   *
   * _Available since v3.4._
   */
  function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
      if (b == 0) return (false, 0);
      return (true, a % b);
    }
  }

  /**
   * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
   *
   * - Addition cannot overflow.
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    return a + b;
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   *
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return a - b;
  }

  /**
   * @dev Returns the multiplication of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `*` operator.
   *
   * Requirements:
   *
   * - Multiplication cannot overflow.
   */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    return a * b;
  }

  /**
   * @dev Returns the integer division of two unsigned integers, reverting on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator.
   *
   * Requirements:
   *
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return a / b;
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * reverting when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   *
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return a % b;
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
   * overflow (when the result is negative).
   *
   * CAUTION: This function is deprecated because it requires allocating memory for the error
   * message unnecessarily. For custom revert reasons use {trySub}.
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   *
   * - Subtraction cannot overflow.
   */
  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    unchecked {
      require(b <= a, errorMessage);
      return a - b;
    }
  }

  /**
   * @dev Returns the integer division of two unsigned integers, reverting with custom message on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   *
   * - The divisor cannot be zero.
   */
  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    unchecked {
      require(b > 0, errorMessage);
      return a / b;
    }
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * reverting with custom message when dividing by zero.
   *
   * CAUTION: This function is deprecated because it requires allocating memory for the error
   * message unnecessarily. For custom revert reasons use {tryMod}.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   *
   * - The divisor cannot be zero.
   */
  function mod(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    unchecked {
      require(b > 0, errorMessage);
      return a % b;
    }
  }
}

interface IERC20Extended {
  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address _owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Burn(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Auth {
  address internal owner;
  mapping(address => bool) internal authorizations;

  constructor(address _owner) {
    owner = _owner;
    authorizations[_owner] = true;
  }

  /**
   * Function modifier to require caller to be contract owner
   */
  modifier onlyOwner() {
    require(isOwner(msg.sender), "!OWNER");
    _;
  }

  /**
   * Function modifier to require caller to be authorized
   */
  modifier authorized() {
    require(isAuthorized(msg.sender), "!AUTHORIZED");
    _;
  }

  /**
   * Authorize address. Owner only
   */
  function authorize(address adr) external onlyOwner {
    authorizations[adr] = true;
  }

  /**
   * Remove address' authorization. Owner only
   */
  function unauthorize(address adr) external onlyOwner {
    authorizations[adr] = false;
  }

  /**
   * Check if address is owner
   */
  function isOwner(address account) public view returns (bool) {
    return account == owner;
  }

  /**
   * Return address' authorization status
   */
  function isAuthorized(address adr) public view returns (bool) {
    return authorizations[adr];
  }
}

interface IUniswapV2Router01 {
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

  function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

  function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
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

interface IUniswapV2Factory {
  event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

  function feeTo() external view returns (address);

  function feeToSetter() external view returns (address);

  function getPair(address tokenA, address tokenB) external view returns (address pair);

  function allPairs(uint256) external view returns (address pair);

  function allPairsLength() external view returns (uint256);

  function createPair(address tokenA, address tokenB) external returns (address pair);

  function setFeeTo(address) external;

  function setFeeToSetter(address) external;
}

interface IDividendDistributor {
  function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;

  function setShare(address shareholder, uint256 amount) external;

  function deposit() external payable;

  function process(uint256 gas) external;
}

contract DividendDistributor is IDividendDistributor {
  using SafeMath for uint256;

  address _token;

  struct Share {
    uint256 amount;
    uint256 totalExcluded;
    uint256 totalRealised;
  }

  IERC20Extended BEP_TOKEN;

  address WBNB;
  IUniswapV2Router02 router;

  address[] shareholders;
  mapping(address => uint256) shareholderIndexes;
  mapping(address => uint256) shareholderClaims;

  mapping(address => Share) public shares;

  uint256 public totalShares;
  uint256 public totalDividends;
  uint256 public totalDistributed;
  uint256 public dividendsPerShare;
  uint256 public constant dividendsPerShareAccuracyFactor = 10**36;

  uint256 public minPeriod = 1 hours;
  uint256 public minDistribution = 1 * (10**18);

  uint256 currentIndex;
  address constant pancakeSwapV2Router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

  bool initialized;
  modifier initialization() {
    require(!initialized);
    _;
    initialized = true;
  }

  modifier onlyFactory() {
    require(msg.sender == _token);
    _;
  }

  constructor(
    address _router,
    address _BEP_TOKEN,
    address _wbnb
  ) {
    router = _router != address(0) ? IUniswapV2Router02(_router) : IUniswapV2Router02(pancakeSwapV2Router);
    _token = msg.sender;
    BEP_TOKEN = IERC20Extended(_BEP_TOKEN);
    WBNB = _wbnb;
  }

  function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external override onlyFactory {
    minPeriod = _minPeriod;
    minDistribution = _minDistribution;
  }

  function setShare(address shareholder, uint256 amount) external override onlyFactory {
    if (shares[shareholder].amount > 0) {
      distributeDividend(shareholder);
    }

    if (amount > 0 && shares[shareholder].amount == 0) {
      addShareholder(shareholder);
    } else if (amount == 0 && shares[shareholder].amount > 0) {
      removeShareholder(shareholder);
    }

    totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
    shares[shareholder].amount = amount;

    shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
  }

  function deposit() external payable override onlyFactory {
    uint256 balanceBefore = BEP_TOKEN.balanceOf(address(this));

    address[] memory path = new address[](2);
    path[0] = WBNB;
    path[1] = address(BEP_TOKEN);
    router.swapExactETHForTokensSupportingFeeOnTransferTokens{ value: msg.value }(0, path, address(this), block.timestamp);

    uint256 amount = BEP_TOKEN.balanceOf(address(this)).sub(balanceBefore);

    totalDividends = totalDividends.add(amount);
    dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
  }

  function process(uint256 gas) external override onlyFactory {
    uint256 shareholderCount = shareholders.length;

    if (shareholderCount == 0) {
      return;
    }

    uint256 gasUsed = 0;
    uint256 gasLeft = gasleft();

    uint256 iterations = 0;

    while (gasUsed < gas && iterations < shareholderCount) {
      if (currentIndex >= shareholderCount) {
        currentIndex = 0;
      }

      if (shouldDistribute(shareholders[currentIndex])) {
        distributeDividend(shareholders[currentIndex]);
      }

      gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
      gasLeft = gasleft();
      currentIndex++;
      iterations++;
    }
  }

  function shouldDistribute(address shareholder) internal view returns (bool) {
    return shareholderClaims[shareholder] + minPeriod < block.timestamp && getUnpaidEarnings(shareholder) > minDistribution;
  }

  function distributeDividend(address shareholder) internal {
    if (shares[shareholder].amount == 0) {
      return;
    }

    uint256 amount = getUnpaidEarnings(shareholder);

    if (amount > 0) {
      totalDistributed = totalDistributed.add(amount);
      BEP_TOKEN.transfer(shareholder, amount);
      shareholderClaims[shareholder] = block.timestamp;
      shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
      shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }
  }

  function claimDividend() external {
    distributeDividend(tx.origin);
  }

  function getTotalRealized() external view returns (uint256) {
    return shares[tx.origin].totalRealised;
  }

  function getUnpaidEarnings(address shareholder) public view returns (uint256) {
    if (shares[shareholder].amount == 0) {
      return 0;
    }

    uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
    uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

    if (shareholderTotalDividends <= shareholderTotalExcluded) {
      return 0;
    }

    return shareholderTotalDividends.sub(shareholderTotalExcluded);
  }

  function getCumulativeDividends(uint256 share) internal view returns (uint256) {
    return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
  }

  function addShareholder(address shareholder) internal {
    shareholderIndexes[shareholder] = shareholders.length;
    shareholders.push(shareholder);
  }

  function getShareholders() external view onlyFactory returns (address[] memory) {
    return shareholders;
  }

  function getShareholderAmount(address shareholder) external view returns (uint256) {
    return shares[shareholder].amount;
  }

  function removeShareholder(address shareholder) internal {
    shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length - 1];
    shareholderIndexes[shareholders[shareholders.length - 1]] = shareholderIndexes[shareholder];
    shareholders.pop();
  }
}

contract DistributorFactory {
  using SafeMath for uint256;
  address _token;
  address _tokenHolder;

  struct structDistributors {
    DividendDistributor distributorAddress;
    uint256 index;
    string tokenName;
    bool exists;
  }

  struct structCustomReflections {
    uint256 index;
    address token_holder;
    address[] reflection_tokens;
    bool exists;
  }

  mapping(address => structDistributors) public distributorsMapping;
  address[] public distributorsArrayOfKeys;

  mapping(address => structCustomReflections) public customReflectionMapping;
  address[] customReflectionArrayOfKeys;
  address[] public defaultReflectionsAddress;

  uint256 maxCustomReflections = 3;

  bool customReflectionsOn = true;

  modifier onlyToken() {
    require(msg.sender == _token);
    _;
  }

  modifier onlyTokenHolder() {
    require(tx.origin == _tokenHolder);
    _;
  }

  constructor() {
    _token = msg.sender;
    _tokenHolder = tx.origin;
  }

  function customReflectionsExist(address[] memory _reflectionAddresses) internal view returns (bool) {
    bool state = true;
    uint256 arrayLength = _reflectionAddresses.length;
    for (uint256 i = 0; i < arrayLength; i++) {
      if (!distributorsMapping[_reflectionAddresses[i]].exists) {
        return false;
      }
    }

    return state;
  }

  function addDefaultReflections(address[] memory _defaultReflectionAddresses) external onlyToken {
    require((_defaultReflectionAddresses.length <= maxCustomReflections), "Max Custom Reflection Exceeded.");
    defaultReflectionsAddress = _defaultReflectionAddresses;
  }

  function getDefaultReflections() external view returns (address[] memory) {
    return defaultReflectionsAddress;
  }

  function addCustomReflections(address _owner, address[] memory _reflectionAddresses) external returns (bool) {
    require((_reflectionAddresses.length <= maxCustomReflections), "Max Custom Reflection Exceeded.");
    require(customReflectionsExist(_reflectionAddresses), "Address not in master list.");

    uint256 arrayLength = _reflectionAddresses.length;
    // Clean reflection array to hold new set.
    delete customReflectionMapping[_owner].reflection_tokens;
    //Check if we already have a mapping for token user
    if (!customReflectionMapping[_owner].exists) {
      customReflectionArrayOfKeys.push(_owner);
      if (customReflectionArrayOfKeys.length != 0) {
        customReflectionMapping[_owner].index = customReflectionArrayOfKeys.length - 1;
      } else {
        customReflectionMapping[_owner].index = 0;
      }
      customReflectionMapping[_owner].exists = true;
    }

    for (uint256 i = 0; i < arrayLength; i++) {
      customReflectionMapping[_owner].reflection_tokens.push(_reflectionAddresses[i]);
    }

    return true;
  }

  function getCustomReflections(address _owner) external view returns (address[] memory) {
    return customReflectionMapping[_owner].reflection_tokens;
  }

  function addDistributor(
    address _router,
    address _BEP_TOKEN,
    address _wbnb
  ) external onlyToken returns (bool) {
    require(!distributorsMapping[_BEP_TOKEN].exists, "Distributor already exists");

    IERC20Extended BEP_TOKEN = IERC20Extended(_BEP_TOKEN);
    DividendDistributor distributor = new DividendDistributor(_router, _BEP_TOKEN, _wbnb);

    distributorsArrayOfKeys.push(_BEP_TOKEN);
    distributorsMapping[_BEP_TOKEN].distributorAddress = distributor;
    distributorsMapping[_BEP_TOKEN].index = distributorsArrayOfKeys.length - 1;
    distributorsMapping[_BEP_TOKEN].tokenName = BEP_TOKEN.name();
    distributorsMapping[_BEP_TOKEN].exists = true;

    // set shares
    if (distributorsArrayOfKeys.length > 0) {
      address firstDistributerKey = distributorsArrayOfKeys[0];

      uint256 shareholdersCount = distributorsMapping[firstDistributerKey].distributorAddress.getShareholders().length;

      for (uint256 i = 0; i < shareholdersCount; i++) {
        address shareholderAddress = distributorsMapping[firstDistributerKey].distributorAddress.getShareholders()[i];

        uint256 shareholderAmount = distributorsMapping[firstDistributerKey].distributorAddress.getShareholderAmount(shareholderAddress);

        distributor.setShare(shareholderAddress, shareholderAmount);
      }
    }

    return true;
  }

  function getShareholderAmount(address _BEP_TOKEN, address shareholder) external view returns (uint256) {
    return distributorsMapping[_BEP_TOKEN].distributorAddress.getShareholderAmount(shareholder);
  }

  function claimDividend(address _BEP_TOKEN) external {
    return distributorsMapping[_BEP_TOKEN].distributorAddress.claimDividend();
  }

  function getTotalRealized(address _BEP_TOKEN) external view returns (uint256) {
    return distributorsMapping[_BEP_TOKEN].distributorAddress.getTotalRealized();
  }

  function getUnpaidEarnings(address shareholder, address _BEP_TOKEN) external view returns (uint256) {
    return distributorsMapping[_BEP_TOKEN].distributorAddress.getUnpaidEarnings(shareholder);
  }

  function deleteDistributor(address _BEP_TOKEN) external onlyToken returns (bool) {
    require(distributorsMapping[_BEP_TOKEN].exists, "Distributor not found");

    structDistributors memory deletedDistributer = distributorsMapping[_BEP_TOKEN];
    // if index is not the last entry
    if (deletedDistributer.index != distributorsArrayOfKeys.length - 1) {
      address lastAddress = distributorsArrayOfKeys[distributorsArrayOfKeys.length - 1];
      distributorsArrayOfKeys[deletedDistributer.index] = lastAddress;
      distributorsMapping[lastAddress].index = deletedDistributer.index;
    }
    delete distributorsMapping[_BEP_TOKEN];
    distributorsArrayOfKeys.pop();
    return true;
  }

  function getDistributorsAddresses() external view returns (address[] memory) {
    return distributorsArrayOfKeys;
  }

  function useCustomReflection(address _shareholder) internal view returns (bool) {
    bool state = true;
    if (!customReflectionsOn) {
      state = false;
    } else {
      if (!customReflectionMapping[_shareholder].exists) {
        state = false;
      }
    }
    return state;
  }

  /// @dev
  /// This functions runs through the contract's list of custom reflection token then
  /// checks if the shareholder has enabled that token as a reward before setting the share amount.

  function setShare(address shareholder, uint256 amount) external onlyToken {
    uint256 arrayLength = distributorsArrayOfKeys.length;
    if (useCustomReflection(shareholder)) {
      for (uint256 i = 0; i < arrayLength; i++) {
        // Looping through master set of reflections
        for (uint256 j = 0; j < customReflectionMapping[shareholder].reflection_tokens.length; j++) {
          //looping through tokenHolder custom reflection list
          if (distributorsArrayOfKeys[i] == customReflectionMapping[shareholder].reflection_tokens[j]) {
            distributorsMapping[distributorsArrayOfKeys[i]].distributorAddress.setShare(shareholder, amount);
          }
        }
      }
    } else {
      // use default reflection code
      uint256 defaultReflectionArrayLength = defaultReflectionsAddress.length;
      for (uint256 i = 0; i < defaultReflectionArrayLength; i++) {
        distributorsMapping[defaultReflectionsAddress[i]].distributorAddress.setShare(shareholder, amount);
      }
    }
  }

  function process(uint256 gas) external onlyToken {
    uint256 arrayLength = distributorsArrayOfKeys.length;
    for (uint256 i = 0; i < arrayLength; i++) {
      distributorsMapping[distributorsArrayOfKeys[i]].distributorAddress.process(gas);
    }
  }

  function deposit() external payable onlyToken {
    uint256 arrayLength = distributorsArrayOfKeys.length;
    uint256 valuePerToken = msg.value.div(arrayLength);

    for (uint256 i = 0; i < arrayLength; i++) {
      distributorsMapping[distributorsArrayOfKeys[i]].distributorAddress.deposit{ value: valuePerToken }();
    }
  }

  function getDistributor(address _BEP_TOKEN) external view returns (DividendDistributor) {
    return distributorsMapping[_BEP_TOKEN].distributorAddress;
  }

  function getTotalDistributers() external view returns (uint256) {
    return distributorsArrayOfKeys.length;
  }

  function getMaxUserReflections() external view returns (uint256) {
    return maxCustomReflections;
  }

  function setMaxUserReflection(uint256 _maxReflections) external onlyToken {
    maxCustomReflections = _maxReflections;
  }

  function isCustomReflectionActive() external view returns (bool) {
    return customReflectionsOn;
  }

  function setCustomReflectionToOn(bool state) external onlyToken {
    customReflectionsOn = state;
  }

  function setDistributionCriteria(
    address _BEP_TOKEN,
    uint256 _minPeriod,
    uint256 _minDistribution
  ) external onlyToken {
    distributorsMapping[_BEP_TOKEN].distributorAddress.setDistributionCriteria(_minPeriod, _minDistribution);
  }
}

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
  struct Counter {
    // This variable should never be directly accessed by users of the library: interactions must be restricted to
    // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
    // this feature: see https://github.com/ethereum/solidity/issues/4637
    uint256 _value; // default: 0
  }

  function current(Counter storage counter) internal view returns (uint256) {
    return counter._value;
  }

  function increment(Counter storage counter) internal {
    unchecked {
      counter._value += 1;
    }
  }

  function decrement(Counter storage counter) internal {
    uint256 value = counter._value;
    require(value > 0, "Counter: decrement overflow");
    unchecked {
      counter._value = value - 1;
    }
  }

  function reset(Counter storage counter) internal {
    counter._value = 0;
  }
}

/**
 * @dev String operations.
 */
library Strings {
  bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

  /**
   * @dev Converts a `uint256` to its ASCII `string` decimal representation.
   */
  function toString(uint256 value) internal pure returns (string memory) {
    // Inspired by OraclizeAPI's implementation - MIT licence
    // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

    if (value == 0) {
      return "0";
    }
    uint256 temp = value;
    uint256 digits;
    while (temp != 0) {
      digits++;
      temp /= 10;
    }
    bytes memory buffer = new bytes(digits);
    while (value != 0) {
      digits -= 1;
      buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
      value /= 10;
    }
    return string(buffer);
  }

  /**
   * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
   */
  function toHexString(uint256 value) internal pure returns (string memory) {
    if (value == 0) {
      return "0x00";
    }
    uint256 temp = value;
    uint256 length = 0;
    while (temp != 0) {
      length++;
      temp >>= 8;
    }
    return toHexString(value, length);
  }

  /**
   * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
   */
  function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
    bytes memory buffer = new bytes(2 * length + 2);
    buffer[0] = "0";
    buffer[1] = "x";
    for (uint256 i = 2 * length + 1; i > 1; --i) {
      buffer[i] = _HEX_SYMBOLS[value & 0xf];
      value >>= 4;
    }
    require(value == 0, "Strings: hex length insufficient");
    return string(buffer);
  }
}

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
  enum RecoverError {
    NoError,
    InvalidSignature,
    InvalidSignatureLength,
    InvalidSignatureS,
    InvalidSignatureV
  }

  function _throwError(RecoverError error) private pure {
    if (error == RecoverError.NoError) {
      return; // no error: do nothing
    } else if (error == RecoverError.InvalidSignature) {
      revert("ECDSA: invalid signature");
    } else if (error == RecoverError.InvalidSignatureLength) {
      revert("ECDSA: invalid signature length");
    } else if (error == RecoverError.InvalidSignatureS) {
      revert("ECDSA: invalid signature 's' value");
    } else if (error == RecoverError.InvalidSignatureV) {
      revert("ECDSA: invalid signature 'v' value");
    }
  }

  /**
   * @dev Returns the address that signed a hashed message (`hash`) with
   * `signature` or error string. This address can then be used for verification purposes.
   *
   * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
   * this function rejects them by requiring the `s` value to be in the lower
   * half order, and the `v` value to be either 27 or 28.
   *
   * IMPORTANT: `hash` _must_ be the result of a hash operation for the
   * verification to be secure: it is possible to craft signatures that
   * recover to arbitrary addresses for non-hashed data. A safe way to ensure
   * this is by receiving a hash of the original message (which may otherwise
   * be too long), and then calling {toEthSignedMessageHash} on it.
   *
   * Documentation for signature generation:
   * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
   * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
   *
   * _Available since v4.3._
   */
  function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
    // Check the signature length
    // - case 65: r,s,v signature (standard)
    // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
    if (signature.length == 65) {
      bytes32 r;
      bytes32 s;
      uint8 v;
      // ecrecover takes the signature parameters, and the only way to get them
      // currently is to use assembly.
      assembly {
        r := mload(add(signature, 0x20))
        s := mload(add(signature, 0x40))
        v := byte(0, mload(add(signature, 0x60)))
      }
      return tryRecover(hash, v, r, s);
    } else if (signature.length == 64) {
      bytes32 r;
      bytes32 vs;
      // ecrecover takes the signature parameters, and the only way to get them
      // currently is to use assembly.
      assembly {
        r := mload(add(signature, 0x20))
        vs := mload(add(signature, 0x40))
      }
      return tryRecover(hash, r, vs);
    } else {
      return (address(0), RecoverError.InvalidSignatureLength);
    }
  }

  /**
   * @dev Returns the address that signed a hashed message (`hash`) with
   * `signature`. This address can then be used for verification purposes.
   *
   * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
   * this function rejects them by requiring the `s` value to be in the lower
   * half order, and the `v` value to be either 27 or 28.
   *
   * IMPORTANT: `hash` _must_ be the result of a hash operation for the
   * verification to be secure: it is possible to craft signatures that
   * recover to arbitrary addresses for non-hashed data. A safe way to ensure
   * this is by receiving a hash of the original message (which may otherwise
   * be too long), and then calling {toEthSignedMessageHash} on it.
   */
  function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
    (address recovered, RecoverError error) = tryRecover(hash, signature);
    _throwError(error);
    return recovered;
  }

  /**
   * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
   *
   * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
   *
   * _Available since v4.3._
   */
  function tryRecover(
    bytes32 hash,
    bytes32 r,
    bytes32 vs
  ) internal pure returns (address, RecoverError) {
    bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
    uint8 v = uint8((uint256(vs) >> 255) + 27);
    return tryRecover(hash, v, r, s);
  }

  /**
   * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
   *
   * _Available since v4.2._
   */
  function recover(
    bytes32 hash,
    bytes32 r,
    bytes32 vs
  ) internal pure returns (address) {
    (address recovered, RecoverError error) = tryRecover(hash, r, vs);
    _throwError(error);
    return recovered;
  }

  /**
   * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
   * `r` and `s` signature fields separately.
   *
   * _Available since v4.3._
   */
  function tryRecover(
    bytes32 hash,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) internal pure returns (address, RecoverError) {
    // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
    // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
    // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
    // signatures from current libraries generate a unique signature with an s-value in the lower half order.
    //
    // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
    // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
    // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
    // these malleable signatures as well.
    if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
      return (address(0), RecoverError.InvalidSignatureS);
    }
    if (v != 27 && v != 28) {
      return (address(0), RecoverError.InvalidSignatureV);
    }

    // If the signature is valid (and not malleable), return the signer address
    address signer = ecrecover(hash, v, r, s);
    if (signer == address(0)) {
      return (address(0), RecoverError.InvalidSignature);
    }

    return (signer, RecoverError.NoError);
  }

  /**
   * @dev Overload of {ECDSA-recover} that receives the `v`,
   * `r` and `s` signature fields separately.
   */
  function recover(
    bytes32 hash,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) internal pure returns (address) {
    (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
    _throwError(error);
    return recovered;
  }

  /**
   * @dev Returns an Ethereum Signed Message, created from a `hash`. This
   * produces hash corresponding to the one signed with the
   * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
   * JSON-RPC method as part of EIP-191.
   *
   * See {recover}.
   */
  function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
    // 32 is the length in bytes of hash,
    // enforced by the type signature above
    return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
  }

  /**
   * @dev Returns an Ethereum Signed Message, created from `s`. This
   * produces hash corresponding to the one signed with the
   * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
   * JSON-RPC method as part of EIP-191.
   *
   * See {recover}.
   */
  function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
  }

  /**
   * @dev Returns an Ethereum Signed Typed Data, created from a
   * `domainSeparator` and a `structHash`. This produces hash corresponding
   * to the one signed with the
   * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
   * JSON-RPC method as part of EIP-712.
   *
   * See {recover}.
   */
  function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
  }
}

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 */
abstract contract EIP712 {
  /* solhint-disable var-name-mixedcase */
  // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
  // invalidate the cached domain separator if the chain id changes.
  bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
  uint256 private immutable _CACHED_CHAIN_ID;
  address private immutable _CACHED_THIS;

  bytes32 private immutable _HASHED_NAME;
  bytes32 private immutable _HASHED_VERSION;
  bytes32 private immutable _TYPE_HASH;

  /* solhint-enable var-name-mixedcase */

  /**
   * @dev Initializes the domain separator and parameter caches.
   *
   * The meaning of `name` and `version` is specified in
   * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
   *
   * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
   * - `version`: the current major version of the signing domain.
   *
   * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
   * contract upgrade].
   */
  constructor(string memory name, string memory version) {
    bytes32 hashedName = keccak256(bytes(name));
    bytes32 hashedVersion = keccak256(bytes(version));
    bytes32 typeHash = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    _HASHED_NAME = hashedName;
    _HASHED_VERSION = hashedVersion;
    _CACHED_CHAIN_ID = block.chainid;
    _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
    _CACHED_THIS = address(this);
    _TYPE_HASH = typeHash;
  }

  /**
   * @dev Returns the domain separator for the current chain.
   */
  function _domainSeparatorV4() internal view returns (bytes32) {
    if (address(this) == _CACHED_THIS && block.chainid == _CACHED_CHAIN_ID) {
      return _CACHED_DOMAIN_SEPARATOR;
    } else {
      return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
    }
  }

  function _buildDomainSeparator(
    bytes32 typeHash,
    bytes32 nameHash,
    bytes32 versionHash
  ) private view returns (bytes32) {
    return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
  }

  /**
   * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
   * function returns the hash of the fully encoded EIP712 message for this domain.
   *
   * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
   *
   * ```solidity
   * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
   *     keccak256("Mail(address to,string contents)"),
   *     mailTo,
   *     keccak256(bytes(mailContents))
   * )));
   * address signer = ECDSA.recover(digest, signature);
   * ```
   */
  function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
    return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
  }
}

/**
  Inital Min: 100,000,000,000,000 100T
*/

/// @custom:security-contact [email protected]
contract PepperBirdToken is IERC20Extended, Auth, EIP712 {
  event Log(string message);
  using SafeMath for uint256;
  using Counters for Counters.Counter;
  mapping(address => Counters.Counter) private _nonces;
  string public contractBuild = "7";
  mapping(address => bool) private _isBot;

  address private constant DEAD = address(0xdead);
  address private constant ZERO = address(0);
  uint8 private constant _decimals = 18;

  string private _name;
  string private _symbol;
  uint256 private _totalSupply;

  IUniswapV2Router02 public router;
  address public pair;
  address public autoLiquidityReceiver;
  address public marketingFeeReceiver;
  address public charityFeeReceiver;
  address public gasWalletFeeReceiver;

  uint256 public liquidityFee; // default: 300
  uint256 public buybackFee; // default: 050
  uint256 public reflectionFee; // default: 600
  uint256 public marketingFee; // default: 100
  uint256 public charityFee; // default 100;
  uint256 public gasWalletFee; // default: 050
  uint256 public totalFee; // default: 12%
  uint256 public feeDenominator; // default: 10000

  uint256 public targetLiquidity; // default: 25
  uint256 public targetLiquidityDenominator; // default: 100

  uint256 public buybackMultiplierNumerator; // default: 200
  uint256 public buybackMultiplierDenominator; // default: 100
  uint256 public buybackMultiplierTriggeredAt;
  uint256 public buybackMultiplierLength; // default: 30 mins

  uint256 public maxWalletToken;

  bool public autoBuybackEnabled;

  bool public isPostLaunchMode;
  bool public isReflectionOnTimer;

  uint256 public autoBuybackCap;
  uint256 public autoBuybackAccumulator;
  uint256 public autoBuybackAmount;
  uint256 public autoBuybackBlockPeriod;
  uint256 public autoBuybackBlockLast;
  address public futureOwnershipTransferAddress;
  uint256 private _futureOwnershipTransferAddressInitTime;
  uint256 public constant timeToClearNewOwnershipAddress = 172800000; // 48 Hours in Milliseconds

  DistributorFactory distributor;

  uint256 public distributorGas;

  bool public swapEnabled;
  uint256 public swapThreshold;

  mapping(address => uint256) private _balances;
  mapping(address => mapping(address => uint256)) private _allowances;

  mapping(address => bool) public buyBacker;
  mapping(address => bool) public isFeeExempt;
  mapping(address => bool) public isDividendExempt;
  mapping(address => bool) isTxLimitExempt;

  event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
  event BuybackMultiplierActive(uint256 duration);

  bool inSwap;
  modifier swapping() {
    inSwap = true;
    _;
    inSwap = false;
  }

  modifier onlyBuybacker() {
    require(buyBacker[msg.sender], "Not a buybacker");
    _;
  }

  bytes32 private constant _PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
  bytes32 private _PERMIT_TYPEHASH_DEPRECATED_SLOT;

  error WalletLimitReached(uint256 walletBalance, uint256 proposedWalletBalance, uint256 walletMaxBalance);
  error TransferAddressNotWhitelisted(address transferAddress);

  event OwnershipTransferred(address owner);
  event DistributionCriteriaUpdated(address indexed bepToken, uint256 minPeriod, uint256 minDistribution);
  event MaxNumberReflectionUpdated(uint256 amount);
  event AutoBuyBackSettingsUpdated(bool enabled, uint256 cap, uint256 amount, uint256 period);
  event BuyBackMultiplierSettingsUpdated(uint256 numerator, uint256 deonimator, uint256 length);
  event SwapBackSettingsUpdated(bool enabled, uint256 amount);
  event TargetLiquidityUpdated(uint256 target, uint256 denominator);

  constructor(address router_) payable Auth(msg.sender) EIP712(_name, "1") {
    uint256[7] memory feeSettings_;
    feeSettings_[0] = 300;
    // Liquidity Fee
    feeSettings_[1] = 50;
    // BuyBackFee
    feeSettings_[2] = 600;
    // ReflectionFee
    feeSettings_[3] = 100;
    // MarketingFee
    feeSettings_[4] = 100;
    // CharityFee
    feeSettings_[5] = 50;
    // GasWalletFee
    feeSettings_[6] = 10000;
    // Denominator

    _name = "PEPPERBIRD";
    _symbol = "PBIRD";
    _totalSupply = 100000000000000 * 10**18;
    maxWalletToken = (_totalSupply * 3) / 100;
    //set at 3%

    router = IUniswapV2Router02(router_);

    pair = IUniswapV2Factory(router.factory()).createPair(address(this), router.WETH());

    distributor = new DistributorFactory();

    _initializeFees(feeSettings_);
    _initializeLiquidityBuyBack();

    distributorGas = 500000;
    swapEnabled = true;
    swapThreshold = _totalSupply / 20000;
    // 0.005% 5,000,000,000

    isFeeExempt[msg.sender] = true;
    isTxLimitExempt[msg.sender] = true;
    isDividendExempt[pair] = true;
    isDividendExempt[address(this)] = true;
    isDividendExempt[DEAD] = true;
    buyBacker[msg.sender] = true;
    isPostLaunchMode = false;
    isReflectionOnTimer = false;

    autoLiquidityReceiver = msg.sender;
    marketingFeeReceiver = msg.sender;
    charityFeeReceiver = msg.sender;
    gasWalletFeeReceiver = msg.sender;

    _allowances[address(this)][address(router)] = _totalSupply;
    _allowances[address(this)][address(pair)] = _totalSupply;

    approve(router_, _totalSupply);
    approve(address(pair), _totalSupply);

    _balances[msg.sender] = _totalSupply;

    emit Transfer(address(0), msg.sender, _totalSupply);
    emit Log("Token Created");
  }

  function getDistributorFactory() external view returns (DistributorFactory) {
    return distributor;
  }

  function addDistributor(
    address _Router,
    address _BEP_TOKEN,
    address _WBNB
  ) external authorized {
    distributor.addDistributor(_Router, _BEP_TOKEN, _WBNB);
  }

  function getCustomReflections() external view returns (address[] memory) {
    address _owner = msg.sender;
    return distributor.getCustomReflections(_owner);
  }

  function addCustomReflections(address[] memory _customReflections) external {
    address _owner = msg.sender;
    distributor.addCustomReflections(_owner, _customReflections);
  }

  function getShareholderAmount(address _BEP_TOKEN, address shareholder) external view returns (uint256) {
    return distributor.getShareholderAmount(_BEP_TOKEN, shareholder);
  }

  function claimDividend(address _BEP_TOKEN) external {
    return distributor.claimDividend(_BEP_TOKEN);
  }

  function getTotalRealized(address _BEP_TOKEN) external view returns (uint256) {
    return distributor.getTotalRealized(_BEP_TOKEN);
  }

  function getUnpaidEarnings(address shareholder, address _BEP_TOKEN) external view returns (uint256) {
    return distributor.getUnpaidEarnings(shareholder, _BEP_TOKEN);
  }

  function getMaxUserReflections() external view returns (uint256) {
    return distributor.getMaxUserReflections();
  }

  function setMaxUserReflections(uint256 amount) external authorized {
    distributor.setMaxUserReflection(amount);
    emit MaxNumberReflectionUpdated(amount);
  }

  function isCustomReflectionActive() external view returns (bool) {
    return distributor.isCustomReflectionActive();
  }

  function setIsPostLaunch(bool state) external authorized {
    isPostLaunchMode = state;
  }

  function setReflectionOnTimer(bool state) external authorized {
    isReflectionOnTimer = state;
  }

  function setCustomReflectionToOn(bool state) external authorized {
    distributor.setCustomReflectionToOn(state);
  }

  function deleteDistributor(address _BEP_TOKEN) external authorized {
    distributor.deleteDistributor(_BEP_TOKEN);
  }

  function getDistributersBEP20Keys() external view returns (address[] memory) {
    return distributor.getDistributorsAddresses();
  }

  function getDistributer(address _BEP_TOKEN) external view returns (DividendDistributor) {
    return distributor.getDistributor(_BEP_TOKEN);
  }

  function getTotalDividends(address _BEP_TOKEN) external view returns (uint256) {
    DividendDistributor singleDistributor = distributor.getDistributor(_BEP_TOKEN);
    return singleDistributor.totalDividends();
  }

  function _initializeFees(uint256[7] memory feeSettings_) internal {
    _setFees(
      feeSettings_[0], // liquidityFee
      feeSettings_[1], // buybackFee
      feeSettings_[2], // reflectionFee
      feeSettings_[3], // marketingFee
      feeSettings_[4], // charityFee
      feeSettings_[5], // gasFee
      feeSettings_[6] // feeDenominator
    );
  }

  function _initializeLiquidityBuyBack() internal {
    targetLiquidity = 25;
    targetLiquidityDenominator = 100;

    buybackMultiplierNumerator = 200;
    buybackMultiplierDenominator = 100;
    buybackMultiplierLength = 30 minutes;
  }

  receive() external payable {}

  function getPairContract() external view returns (address) {
    return _getPairContract();
  }

  function totalSupply() external view override returns (uint256) {
    return _totalSupply;
  }

  function decimals() external pure override returns (uint8) {
    return _decimals;
  }

  function symbol() external view override returns (string memory) {
    return _symbol;
  }

  function name() external view override returns (string memory) {
    return _name;
  }

  function balanceOf(address account) public view override returns (uint256) {
    return _balances[account];
  }

  function allowance(address holder, address spender) external view override returns (uint256) {
    return _allowances[holder][spender];
  }

  function approve(address spender, uint256 amount) public override returns (bool) {
    _allowances[msg.sender][spender] = amount;
    emit Approval(msg.sender, spender, amount);
    return true;
  }

  function approveMax(address spender) external returns (bool) {
    return approve(spender, _totalSupply);
  }

  function transfer(address recipient, uint256 amount) external override returns (bool) {
    return _transferFrom(msg.sender, recipient, amount);
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external override returns (bool) {
    if (_allowances[sender][msg.sender] != _totalSupply) {
      _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
    }

    return _transferFrom(sender, recipient, amount);
  }

  function setFutureOwnershipTransferAddress(address _address) external onlyOwner {
    futureOwnershipTransferAddress = _address;
    _futureOwnershipTransferAddressInitTime = block.timestamp.add(timeToClearNewOwnershipAddress);
  }

  function setMaxWalletPercent(uint256 _maxWalletPercent) external onlyOwner {
    require(_maxWalletPercent >= 3, "Max wallet can not be less than 3%");
    maxWalletToken = (_totalSupply * _maxWalletPercent) / 100;
  }

  function transferOwnership(address payable adr) external onlyOwner {
    if (!_isTransferAddressConfirmed(adr)) {
      revert TransferAddressNotWhitelisted({ transferAddress: adr });
    }
    owner = adr;
    authorizations[adr] = true;
    emit OwnershipTransferred(adr);
  }

  function _getPairContract() internal view returns (address) {
    address pairContract = IUniswapV2Factory(router.factory()).getPair(address(this), router.WETH());
    return pairContract;
  }

  function _isTransferAddressConfirmed(address _address) internal view returns (bool) {
    bool _state = false;
    if ((block.timestamp <= _futureOwnershipTransferAddressInitTime) && (_address == futureOwnershipTransferAddress)) {
      _state = true;
    }
    return _state;
  }

  function burn(uint256 amount) public virtual {
    _burn(msg.sender, amount);
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
    emit Burn(account, address(0), amount);
  }

  function _transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) internal returns (bool) {
    require(!_isBot[sender] && !_isBot[recipient], "You are a bot");
    if (inSwap) {
      return _basicTransfer(sender, recipient, amount);
    }
    // Setting Max Available In Wallet
    if (
      isPostLaunchMode &&
      !authorizations[sender] &&
      recipient != address(this) &&
      recipient != address(DEAD) &&
      recipient != pair &&
      recipient != marketingFeeReceiver &&
      recipient != autoLiquidityReceiver
    ) {
      uint256 heldTokens = balanceOf(recipient);
      if ((heldTokens + amount) > maxWalletToken) {
        revert WalletLimitReached({ walletBalance: heldTokens, proposedWalletBalance: (heldTokens + amount), walletMaxBalance: maxWalletToken });
      }
    }

    if (shouldSwapBack()) {
      swapBack();
    }
    if (shouldAutoBuyback()) {
      triggerAutoBuyback();
    }

    _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

    uint256 amountReceived = amount;
    // DISABLE FEEs PreLaunch
    if (isPostLaunchMode) {
      amountReceived = shouldTakeFee(sender) ? takeFee(sender, recipient, amount) : amount;
    }

    _balances[recipient] = _balances[recipient].add(amountReceived);

    // DISABLE Dividends PreLaunch
    if (isPostLaunchMode) {
      if (!isDividendExempt[sender]) {
        try distributor.setShare(sender, _balances[sender]) {} catch {}
      }
      if (!isDividendExempt[recipient]) {
        try distributor.setShare(recipient, _balances[recipient]) {} catch {}
      }
      if (!isReflectionOnTimer) {
        try distributor.process(distributorGas) {} catch {}
      }
    }

    emit Transfer(sender, recipient, amountReceived);
    return true;
  }

  function _basicTransfer(
    address sender,
    address recipient,
    uint256 amount
  ) internal returns (bool) {
    _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
    return true;
  }

  function shouldTakeFee(address sender) internal view returns (bool) {
    return !isFeeExempt[sender];
  }

  function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
    uint256 amountBNB = address(this).balance;
    payable(marketingFeeReceiver).transfer((amountBNB * amountPercentage) / 100);
  }

  function getTotalFee(bool selling) public view returns (uint256) {
    if (selling) {
      return getMultipliedFee();
    }
    return totalFee;
  }

  function getChainID() external view returns (uint256) {
    return block.chainid;
  }

  function getMultipliedFee() public view returns (uint256) {
    if (buybackMultiplierTriggeredAt.add(buybackMultiplierLength) > block.timestamp) {
      uint256 remainingTime = buybackMultiplierTriggeredAt.add(buybackMultiplierLength).sub(block.timestamp);
      uint256 feeIncrease = totalFee.mul(buybackMultiplierNumerator).div(buybackMultiplierDenominator).sub(totalFee);
      return totalFee.add(feeIncrease.mul(remainingTime).div(buybackMultiplierLength));
    }
    return totalFee;
  }

  function takeFee(
    address sender,
    address receiver,
    uint256 amount
  ) internal returns (uint256) {
    uint256 feeAmount = amount.mul(getTotalFee(receiver == pair)).div(feeDenominator);

    _balances[address(this)] = _balances[address(this)].add(feeAmount);
    emit Transfer(sender, address(this), feeAmount);

    return amount.sub(feeAmount);
  }

  function shouldSwapBack() internal view returns (bool) {
    return msg.sender != pair && !inSwap && swapEnabled && _balances[address(this)] >= swapThreshold;
  }

  function swapBack() internal swapping {
    uint256 dynamicLiquidityFee = isOverLiquified(targetLiquidity, targetLiquidityDenominator) ? 0 : liquidityFee;
    uint256 amountToLiquify = swapThreshold.mul(dynamicLiquidityFee).div(totalFee).div(2);
    uint256 amountToSwap = swapThreshold.sub(amountToLiquify);

    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = router.WETH();
    uint256 balanceBefore = address(this).balance;

    router.swapExactTokensForETHSupportingFeeOnTransferTokens(amountToSwap, 0, path, address(this), block.timestamp);

    uint256 amountBNB = address(this).balance.sub(balanceBefore);

    uint256 totalBNBFee = totalFee.sub(dynamicLiquidityFee.div(2));

    uint256 amountBNBLiquidity = amountBNB.mul(dynamicLiquidityFee).div(totalBNBFee).div(2);
    uint256 amountBNBReflection = amountBNB.mul(reflectionFee).div(totalBNBFee);
    uint256 amountBNBMarketing = amountBNB.mul(marketingFee).div(totalBNBFee);
    uint256 amountBNBCharity = amountBNB.mul(charityFee).div(totalBNBFee);
    uint256 amountBNBGasWallet = amountBNB.mul(gasWalletFee).div(totalBNBFee);

    try distributor.deposit{ value: amountBNBReflection }() {} catch {}
    payable(marketingFeeReceiver).transfer(amountBNBMarketing);
    payable(charityFeeReceiver).transfer(amountBNBCharity);
    payable(gasWalletFeeReceiver).transfer(amountBNBGasWallet);

    if (amountToLiquify > 0) {
      router.addLiquidityETH{ value: amountBNBLiquidity }(address(this), amountToLiquify, 0, 0, autoLiquidityReceiver, block.timestamp);
      emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
    }
  }

  function shouldAutoBuyback() internal view returns (bool) {
    return
      msg.sender != pair &&
      !inSwap &&
      autoBuybackEnabled &&
      autoBuybackBlockLast + autoBuybackBlockPeriod <= block.number && // After N blocks from last buyback
      address(this).balance >= autoBuybackAmount;
  }

  function triggerZeusBuyback(uint256 amount, bool triggerBuybackMultiplier) external authorized {
    buyTokens(amount, DEAD);
    if (triggerBuybackMultiplier) {
      buybackMultiplierTriggeredAt = block.timestamp;
      emit BuybackMultiplierActive(buybackMultiplierLength);
    }
  }

  function clearBuybackMultiplier() external authorized {
    buybackMultiplierTriggeredAt = 0;
  }

  function triggerAutoBuyback() internal {
    buyTokens(autoBuybackAmount, DEAD);
    autoBuybackBlockLast = block.number;
    autoBuybackAccumulator = autoBuybackAccumulator.add(autoBuybackAmount);
    if (autoBuybackAccumulator > autoBuybackCap) {
      autoBuybackEnabled = false;
    }
  }

  function rescueBNB(uint256 weiAmount) external onlyOwner {
    require(address(this).balance >= weiAmount, "insufficient BNB balance");
    payable(msg.sender).transfer(weiAmount);
  }

  function rescueAnyBEP20Tokens(
    address _tokenAddress,
    address _to,
    uint256 _amount
  ) public onlyOwner {
    require(_tokenAddress != address(this), "Cannot transfer out Token123!");
    IERC20Extended(_tokenAddress).transfer(_to, _amount);
  }

  function buyTokens(uint256 amount, address to) internal swapping {
    address[] memory path = new address[](2);
    path[0] = router.WETH();
    path[1] = address(this);

    router.swapExactETHForTokensSupportingFeeOnTransferTokens{ value: amount }(0, path, to, block.timestamp);
  }

  function setAutoBuybackSettings(
    bool _enabled,
    uint256 _cap,
    uint256 _amount,
    uint256 _period
  ) external authorized {
    autoBuybackEnabled = _enabled;
    autoBuybackCap = _cap;
    autoBuybackAccumulator = 0;
    autoBuybackAmount = _amount;
    autoBuybackBlockPeriod = _period;
    autoBuybackBlockLast = block.number;
    emit AutoBuyBackSettingsUpdated(_enabled, _cap, _amount, _period);
  }

  function setBuybackMultiplierSettings(
    uint256 numerator,
    uint256 denominator,
    uint256 length
  ) external authorized {
    require(numerator / denominator <= 2 && numerator > denominator);
    buybackMultiplierNumerator = numerator;
    buybackMultiplierDenominator = denominator;
    buybackMultiplierLength = length;
    emit BuyBackMultiplierSettingsUpdated(numerator, denominator, length);
  }

  function setIsDividendExempt(address holder, bool exempt) external authorized {
    require(holder != address(this) && holder != pair);
    isDividendExempt[holder] = exempt;
    if (exempt) {
      distributor.setShare(holder, 0);
    } else {
      distributor.setShare(holder, _balances[holder]);
    }
  }

  function setIsFeeExempt(address holder, bool exempt) external authorized {
    isFeeExempt[holder] = exempt;
  }

  function setBuyBacker(address acc, bool add) external authorized {
    buyBacker[acc] = add;
  }

  function setFees(
    uint256 _liquidityFee,
    uint256 _buybackFee,
    uint256 _reflectionFee,
    uint256 _marketingFee,
    uint256 _charityFee,
    uint256 _gasWalletFee,
    uint256 _feeDenominator
  ) external authorized {
    _setFees(_liquidityFee, _buybackFee, _reflectionFee, _marketingFee, _charityFee, _gasWalletFee, _feeDenominator);
  }

  function _setFees(
    uint256 _liquidityFee,
    uint256 _buybackFee,
    uint256 _reflectionFee,
    uint256 _marketingFee,
    uint256 _charityFee,
    uint256 _gasWalletFee,
    uint256 _feeDenominator
  ) internal {
    liquidityFee = _liquidityFee;
    buybackFee = _buybackFee;
    reflectionFee = _reflectionFee;
    marketingFee = _marketingFee;
    charityFee = _charityFee;
    gasWalletFee = _gasWalletFee;
    totalFee = _liquidityFee.add(_buybackFee).add(_reflectionFee).add(_marketingFee).add(_charityFee);
    totalFee = totalFee.add(_gasWalletFee);
    feeDenominator = _feeDenominator;
    require(totalFee < feeDenominator / 4, "Total fee should not be greater than 1/4 of fee denominator");
  }

  function setFeeReceivers(
    address _autoLiquidityReceiver,
    address _marketingFeeReceiver,
    address _charityFeeReceiver,
    address _gasWalletReceiver
  ) external authorized {
    autoLiquidityReceiver = _autoLiquidityReceiver;
    marketingFeeReceiver = _marketingFeeReceiver;
    charityFeeReceiver = _charityFeeReceiver;
    gasWalletFeeReceiver = _gasWalletReceiver;
  }

  function setSwapBackSettings(bool _enabled, uint256 _amount) external authorized {
    swapEnabled = _enabled;
    swapThreshold = _amount;
    emit SwapBackSettingsUpdated(_enabled, _amount);
  }

  function setTargetLiquidity(uint256 _target, uint256 _denominator) external authorized {
    targetLiquidity = _target;
    targetLiquidityDenominator = _denominator;
    emit TargetLiquidityUpdated(_target, _denominator);
  }

  function addDefaultReflections(address[] memory _defaultReflectionAddresses) external authorized {
    distributor.addDefaultReflections(_defaultReflectionAddresses);
  }

  function getDefaultReflections() external view returns (address[] memory) {
    return distributor.getDefaultReflections();
  }

  function setDistributionCriteria(
    address _BEP_TOKEN,
    uint256 _minPeriod,
    uint256 _minDistribution
  ) external authorized {
    distributor.setDistributionCriteria(_BEP_TOKEN, _minPeriod, _minDistribution);
    emit DistributionCriteriaUpdated(_BEP_TOKEN, _minPeriod, _minDistribution);
  }

  function processReflections() external authorized {
    try distributor.process(distributorGas) {} catch {}
  }

  function setDistributorSettings(uint256 gas) external authorized {
    distributorGas = gas;
  }

  function getCirculatingSupply() public view returns (uint256) {
    return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
  }

  function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
    return accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply());
  }

  function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
    return getLiquidityBacking(accuracy) > target;
  }

  function setAntibot(address account, bool state) external onlyOwner {
    require(_isBot[account] != state, "Value already set");
    _isBot[account] = state;
  }

  function isBot(address account) public view returns (bool) {
    return _isBot[account];
  }

  function bulkAntiBot(address[] memory accounts, bool state) external onlyOwner {
    for (uint256 i = 0; i < accounts.length; i++) {
      _isBot[accounts[i]] = state;
    }
  }

  function airdrop(address[] calldata addresses, uint256[] calldata tokens) external onlyOwner {
    uint256 PBT = 0;

    require(addresses.length == tokens.length, "Mismatch between Address and token count");

    for (uint256 i = 0; i < addresses.length; i++) {
      PBT = PBT + tokens[i];
    }

    require(balanceOf(msg.sender) >= PBT, "Not enough tokens in wallet for airdrop");

    for (uint256 i = 0; i < addresses.length; i++) {
      _basicTransfer(msg.sender, addresses[i], tokens[i]);
      if (isPostLaunchMode) {
        if (!isDividendExempt[addresses[i]]) {
          try distributor.setShare(addresses[i], _balances[addresses[i]]) {} catch {}
        }
      }
    }

    // Dividend tracker
    if (isPostLaunchMode) {
      if (!isDividendExempt[msg.sender]) {
        try distributor.setShare(msg.sender, _balances[msg.sender]) {} catch {}
      }
    }
  }

  /**
   * @dev Sets the allowance granted to `spender` by `owner`.
   *
   * Emits an {Approval} event indicating the updated allowance.
   */
  function _setAllowance(
    address owner,
    address spender,
    uint256 wad
  ) internal virtual returns (bool) {
    _allowances[owner][spender] = wad;
    emit Approval(owner, spender, wad);

    return true;
  }

  /**
   * @dev See {IERC20Permit-permit}.
   */
  function permit(
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) public virtual {
    require(block.timestamp <= deadline, "Pepperbird Permit: expired deadline");

    bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPEHASH, owner, spender, value, _useNonce(owner), deadline));

    bytes32 hash = _hashTypedDataV4(structHash);

    address signer = ECDSA.recover(hash, v, r, s);
    require(signer == owner, "Pepperbird Permit: invalid signature");

    _setAllowance(owner, spender, value);
  }

  /**
   * @dev See {IERC20Permit-nonces}.
   */
  function nonces(address owner) public view virtual returns (uint256) {
    return _nonces[owner].current();
  }

  /**
   * @dev See {IERC20Permit-DOMAIN_SEPARATOR}.
   */
  // solhint-disable-next-line func-name-mixedcase
  function DOMAIN_SEPARATOR() external view returns (bytes32) {
    return _domainSeparatorV4();
  }

  /**
   * @dev "Consume a nonce": return the current value and increment.
   *
   * _Available since v4.1._
   */
  function _useNonce(address owner) internal virtual returns (uint256 current) {
    Counters.Counter storage nonce = _nonces[owner];
    current = nonce.current();
    nonce.increment();
  }
}