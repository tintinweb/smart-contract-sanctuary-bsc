/**
 *Submitted for verification at BscScan.com on 2022-04-14
*/

// PEPPERBIRD TOKEN BEP 20 Source Code
// BUILD 005
// pepperbird.finance
// 4/09/2022
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
  event Approval(address indexed owner, address indexed spender, uint256 value);
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
  function authorize(address adr) public onlyOwner {
    authorizations[adr] = true;
  }

  /**
   * Remove address' authorization. Owner only
   */
  function unauthorize(address adr) public onlyOwner {
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

  /**
   * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
   */
  function transferOwnership(address payable adr) public onlyOwner {
    owner = adr;
    authorizations[adr] = true;
    emit OwnershipTransferred(adr);
  }

  event OwnershipTransferred(address owner);
}

interface IDividendDistributor {
  function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;

  function setShare(address shareholder, uint256 amount) external;

  function deposit() external payable;

  function process(uint256 gas) external;
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
  uint256 public dividendsPerShareAccuracyFactor = 10**36;

  uint256 public minPeriod = 1 hours;
  uint256 public minDistribution = 1 * (10**18);

  uint256 currentIndex;
  address pancakeSwapV2Router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

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
        state = false;
      }
    }

    return state;
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
      for (uint256 i = 0; i < arrayLength; i++) {
        customReflectionMapping[_owner].reflection_tokens.push(_reflectionAddresses[i]);
      }
    } else {
      for (uint256 i = 0; i < arrayLength; i++) {
        customReflectionMapping[_owner].reflection_tokens.push(_reflectionAddresses[i]);
      }
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

  function getUnpaidEarnings(address shareholder, address _BEP_TOKEN) public view returns (uint256) {
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

  function getDistributorsAddresses() public view returns (address[] memory) {
    return distributorsArrayOfKeys;
  }

  function useCustomReflection(address _shareholder) internal view returns (bool) {
    bool state = true;
    if (customReflectionsOn == false) {
      state = false;
    } else {
      if (customReflectionMapping[_shareholder].exists == false) {
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
    if (useCustomReflection(shareholder) == true) {
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
      for (uint256 i = 0; i < maxCustomReflections; i++) {
        distributorsMapping[distributorsArrayOfKeys[i]].distributorAddress.setShare(shareholder, amount);
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

  function getDistributor(address _BEP_TOKEN) public view returns (DividendDistributor) {
    return distributorsMapping[_BEP_TOKEN].distributorAddress;
  }

  function getTotalDistributers() public view returns (uint256) {
    return distributorsArrayOfKeys.length;
  }

  function getMaxUserReflections() public view returns (uint256) {
    return maxCustomReflections;
  }

  function setMaxUserReflection(uint256 _maxReflections) external onlyToken {
    maxCustomReflections = _maxReflections;
  }

  function isCustomReflectionActive() public view returns (bool) {
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
  Inital Min: 100,000,000,000,000 100T
*/

contract PepperBirdToken is IERC20Extended, Auth {
  event Log(string message);
  using SafeMath for uint256;

  string public constant VERSION = "5";

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

  DistributorFactory distributor;

  uint256 public distributorGas;

  bool public swapEnabled;
  uint256 public swapThreshold;

  mapping(address => uint256) private _balances;
  mapping(address => mapping(address => uint256)) private _allowances;
  mapping(address => uint256) public nonces;

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
    require(buyBacker[msg.sender] == true, "Not a buybacker");
    _;
  }

  // --- EIP712 niceties ---
  bytes32 public DOMAIN_SEPARATOR;

  bytes32 public constant PERMIT_TYPEHASH = keccak256("Permit(address holder,address spender,uint256 nonce,uint256 expiry,uint256 amount)");

  error WalletLimitReached(uint256 walletBalance, uint256 proposedWalletBalance, uint256 walletMaxBalance);

  constructor(address router_) payable Auth(msg.sender) {
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

    DOMAIN_SEPARATOR = keccak256(
      abi.encode(
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
        keccak256(bytes(_name)),
        keccak256(bytes(version())),
        block.chainid,
        address(this)
      )
    );

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

  function getUnpaidEarnings(address shareholder, address _BEP_TOKEN) public view returns (uint256) {
    return distributor.getUnpaidEarnings(shareholder, _BEP_TOKEN);
  }

  function getMaxUserReflections() external view returns (uint256) {
    return distributor.getMaxUserReflections();
  }

  function setMaxUserReflections(uint256 amount) external authorized {
    distributor.setMaxUserReflection(amount);
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

  function getPairContract() public view returns (address) {
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

  function setMaxWalletPercent(uint256 maxWallPercent) external onlyOwner {
    maxWalletToken = (_totalSupply * maxWallPercent) / 100;
  }

  function _getPairContract() internal view returns (address) {
    address pairContract = IUniswapV2Factory(router.factory()).getPair(address(this), router.WETH());
    return pairContract;
  }

  function _transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) internal returns (bool) {
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

  /// @dev Setting the version as a function so that it can be overriden
  function version() public pure virtual returns (string memory) {
    return VERSION;
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
  ) public authorized {
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
  }

  function setTargetLiquidity(uint256 _target, uint256 _denominator) external authorized {
    targetLiquidity = _target;
    targetLiquidityDenominator = _denominator;
  }

  function setDistributionCriteria(
    address _BEP_TOKEN,
    uint256 _minPeriod,
    uint256 _minDistribution
  ) external authorized {
    distributor.setDistributionCriteria(_BEP_TOKEN, _minPeriod, _minDistribution);
  }

  function processReflections() external payable authorized {
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

  // --- Approve by signature ---
  function permit(
    address holder,
    address spender,
    uint256 nonce,
    uint256 expiry,
    bool allowed,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external {
    bytes32 digest = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, keccak256(abi.encode(PERMIT_TYPEHASH, holder, spender, nonce, expiry, allowed))));

    require(holder != address(0), "Pepperbird/invalid-address-0");
    require(holder == ecrecover(digest, v, r, s), "Pepperbird/invalid-permit");
    require(expiry == 0 || block.timestamp <= expiry, "Pepperbird/permit-expired");
    require(nonce == nonces[holder]++, "Pepperbird/invalid-nonce");
    uint256 wad = allowed ? _totalSupply : 0;
    _setAllowance(holder, spender, wad);
  }
}