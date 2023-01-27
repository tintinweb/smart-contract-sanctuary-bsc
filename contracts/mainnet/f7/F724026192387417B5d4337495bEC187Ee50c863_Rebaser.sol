pragma solidity ^0.5.16;

import "./openzeppelin/SafeMath.sol";
import "./openzeppelin/SafeERC20.sol";
import "./interfaces/IETF.sol";
import "./interfaces/IPoolEscrow.sol";
import "./interfaces/ITaxManagerOld.sol";

interface IUniswapV2Pair {
  function sync() external;
}

contract BasicRebaser {

  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  event Updated(uint256 snp, uint256 etf);
  event NoUpdateSNP();
  event NoUpdateETF();
  event NoRebaseNeeded();
  event StillCold();
  event NotInitialized();

  uint256 public constant BASE = 1e18;
  uint256 public constant WINDOW_SIZE = 24;

  address public etf;
  uint256[] public pricesSNP = new uint256[](WINDOW_SIZE);
  uint256[] public pricesETF = new uint256[](WINDOW_SIZE);
  uint256 public pendingSNPPrice = 0;
  uint256 public pendingETFPrice = 0;
  bool public noPending = true;
  uint256 public averageSNP;
  uint256 public averageETF;
  uint256 public lastUpdate;
  uint256 public frequency = 1 hours;
  uint256 public counter = 0;
  uint256 public epoch = 1;
  uint256 public positiveEpochCount = 0;
  uint256 public positiveRebaseLimit = 700; // 7.0% by default
  uint256 public negativeRebaseLimit = 200; // 2.0% by default
  uint256 public constant basisBase = 10000; // 100%
  ITaxManager public taxManager;
  mapping (uint256 => uint256) public rebaseBlockNumber;
  mapping (uint256 => uint256) public rebaseDelta;
  address public secondaryPool;
  address public governance;

  uint256 public nextRebase = 0;
  uint256 public constant REBASE_DELAY = WINDOW_SIZE * 1 hours;
  IUniswapV2Pair public uniswapSyncer;

  modifier onlyGov() {
    require(msg.sender == governance, "only gov");
    _;
  }

  constructor (address token, address _secondaryPool, address _taxManager) public {
    etf = token;
    secondaryPool = _secondaryPool;
    taxManager = ITaxManager(_taxManager);
    governance = msg.sender;
  }

  function setPair(address _uniswapPair) public onlyGov {
    uniswapSyncer = IUniswapV2Pair(_uniswapPair);
  }

  function getPositiveEpochCount() public view returns (uint256) {
    return positiveEpochCount;
  }

  function getBlockForPositiveEpoch(uint256 _epoch) public view returns (uint256) {
    return rebaseBlockNumber[_epoch];
  }

  function getDeltaForPositiveEpoch(uint256 _epoch) public view returns (uint256) {
    return rebaseDelta[_epoch];
  }

  function setNextRebase(uint256 next) external onlyGov {
    require(nextRebase == 0, "Only one time activation");
    nextRebase = next;
  }

  function setGovernance(address account) external onlyGov {
    governance = account;
  }

  function setSecondaryPool(address pool) external onlyGov {
    secondaryPool = pool;
  }

  function setRebaseLimit(uint256 _limit, bool positive) external onlyGov {
    require(_limit <= 2500); // 0% to 25%
      if(positive)
        positiveRebaseLimit = _limit;
      else
        negativeRebaseLimit = _limit;
  }

  function setTaxManager(address _taxManager) external onlyGov {
    taxManager = ITaxManager(_taxManager);
  }

  function checkRebase() external {
    // etf ensures that we do not have smart contracts rebasing
    require (msg.sender == address(etf), "only through etf");
    rebase();
    recordPrice();
  }

  function recordPrice() public {
    if (msg.sender != tx.origin && msg.sender != address(etf)) {
      // smart contracts could manipulate data via flashloans,
      // thus we forbid them from updating the price
      return;
    }

    if (block.timestamp < lastUpdate + frequency) {
      // addition is running on timestamps, this will never overflow
      // we leave at least the specified period between two updates
      return;
    }

    (bool successSNP, uint256 priceSNP) = getPriceSNP();
    (bool successETF, uint256 priceETF) = getPriceETF();
    if (!successETF) {
      // price of ETF was not returned properly
      emit NoUpdateETF();
      return;
    }
    if (!successSNP) {
      // price of SNP was not returned properly
      emit NoUpdateSNP();
      return;
    }
    lastUpdate = block.timestamp;

    if (noPending) {
      // we start recording with 1 hour delay
      pendingSNPPrice = priceSNP;
      pendingETFPrice = priceETF;
      noPending = false;
    } else if (counter < WINDOW_SIZE) {
      // still in the warming up phase
      averageSNP = averageSNP.mul(counter).add(pendingSNPPrice).div(counter.add(1));
      averageETF = averageETF.mul(counter).add(pendingETFPrice).div(counter.add(1));
      pricesSNP[counter] = pendingSNPPrice;
      pricesETF[counter] = pendingETFPrice;
      pendingSNPPrice = priceSNP;
      pendingETFPrice = priceETF;
      counter++;
    } else {
      uint256 index = counter % WINDOW_SIZE;
      averageSNP = averageSNP.mul(WINDOW_SIZE).sub(pricesSNP[index]).add(pendingSNPPrice).div(WINDOW_SIZE);
      averageETF = averageETF.mul(WINDOW_SIZE).sub(pricesETF[index]).add(pendingETFPrice).div(WINDOW_SIZE);
      pricesSNP[index] = pendingSNPPrice;
      pricesETF[index] = pendingETFPrice;
      pendingSNPPrice = priceSNP;
      pendingETFPrice = priceETF;
      counter++;
    }
    emit Updated(pendingSNPPrice, pendingETFPrice);
  }

    function immediateRecordPrice() public onlyGov {

    (bool successSNP, uint256 priceSNP) = getPriceSNP();
    (bool successETF, uint256 priceETF) = getPriceETF();
    if (!successETF) {
      // price of ETF was not returned properly
      emit NoUpdateETF();
      return;
    }
    if (!successSNP) {
      // price of SNP was not returned properly
      emit NoUpdateSNP();
      return;
    }
    lastUpdate = block.timestamp;

    if (noPending) {
      // we start recording with 1 hour delay
      pendingSNPPrice = priceSNP;
      pendingETFPrice = priceETF;
      noPending = false;
    } else if (counter < WINDOW_SIZE) {
      // still in the warming up phase
      averageSNP = averageSNP.mul(counter).add(pendingSNPPrice).div(counter.add(1));
      averageETF = averageETF.mul(counter).add(pendingETFPrice).div(counter.add(1));
      pricesSNP[counter] = pendingSNPPrice;
      pricesETF[counter] = pendingETFPrice;
      pendingSNPPrice = priceSNP;
      pendingETFPrice = priceETF;
      counter++;
    } else {
      uint256 index = counter % WINDOW_SIZE;
      averageSNP = averageSNP.mul(WINDOW_SIZE).sub(pricesSNP[index]).add(pendingSNPPrice).div(WINDOW_SIZE);
      averageETF = averageETF.mul(WINDOW_SIZE).sub(pricesETF[index]).add(pendingETFPrice).div(WINDOW_SIZE);
      pricesSNP[index] = pendingSNPPrice;
      pricesETF[index] = pendingETFPrice;
      pendingSNPPrice = priceSNP;
      pendingETFPrice = priceETF;
      counter++;
    }
    emit Updated(pendingSNPPrice, pendingETFPrice);
  }

  function rebase() public {
    // make public rebasing only after initialization
    if (nextRebase == 0 && msg.sender != governance) {
      emit NotInitialized();
      return;
    }
    if (counter <= WINDOW_SIZE && msg.sender != governance) {
      emit StillCold();
      return;
    }
    // We want to rebase only at 12:00 UTC and 24 hours later
    if (block.timestamp < nextRebase) {
      return;
    } else {
      nextRebase = nextRebase + REBASE_DELAY;
    }

    // only rebase if there is a 5% difference between the price of SNP and ETF
    uint256 highThreshold = averageSNP.mul(105).div(100);
    uint256 lowThreshold = averageSNP.mul(95).div(100);

    if (averageETF > highThreshold) {
      // ETF is too expensive, this is a positive rebase increasing the supply
      uint256 factor = BASE.sub(BASE.mul(averageETF.sub(averageSNP)).div(averageETF.mul(10)));
      uint256 increase = BASE.sub(factor);
      uint256 realAdjustment = increase.mul(BASE).div(factor);
      uint256 currentSupply = IERC20(etf).totalSupply();
      uint256 desiredSupply = currentSupply.add(currentSupply.mul(realAdjustment).div(BASE));
      uint256 upperLimit = currentSupply.mul(basisBase.add(positiveRebaseLimit)).div(basisBase);
      if(desiredSupply > upperLimit) // Increase expected rebase is above the limit
        desiredSupply = upperLimit;
      uint256 preTaxDelta = desiredSupply.mul(BASE).div(currentSupply).sub(BASE);
      positiveEpochCount++;
      rebaseBlockNumber[positiveEpochCount] = block.number;
      uint256 perpetualPoolTax = taxManager.getPerpetualPoolTaxRate();
      uint256 totalTax = taxManager.getTotalTaxAtMint();
      uint256 taxDivisor = taxManager.getTaxBaseDivisor();
      uint256 secondaryPoolBudget = desiredSupply.sub(currentSupply).mul(perpetualPoolTax).div(taxDivisor); // 4.5% to perpetual pool/escrow
      uint256 totalRewardBudget = desiredSupply.sub(currentSupply).mul(totalTax).div(taxDivisor); // This amount of token will get minted when rewards are claimed and distributed via perpetual pool
      desiredSupply = desiredSupply.sub(totalRewardBudget);

      // Cannot underflow as desiredSupply > currentSupply, the result is positive
      // delta = (desiredSupply / currentSupply) * 100 - 100
      uint256 delta = desiredSupply.mul(BASE).div(currentSupply).sub(BASE);
      uint256 deltaDifference = preTaxDelta.sub(delta); // Percentage of delta reduced due to tax
      rebaseDelta[positiveEpochCount] = deltaDifference; // Record pre-tax delta differemce, this is the amount of token in percent that needs to be minted for tax
      IETF(etf).rebase(epoch, delta, true);

      if (secondaryPool != address(0)) {
        // notify the pool escrow that tokens are available
        IETF(etf).mint(address(this), secondaryPoolBudget);
        IERC20(etf).safeApprove(secondaryPool, 0);
        IERC20(etf).safeApprove(secondaryPool, secondaryPoolBudget);
        IPoolEscrow(secondaryPool).notifySecondaryTokens(secondaryPoolBudget);
      } else {
        // Incase perpetual pool address was not set
        address perpetualPool = taxManager.getPerpetualPool();
        IETF(etf).mint(perpetualPool, secondaryPoolBudget);
      }
      uniswapSyncer.sync();
      epoch++;

    } else if (averageETF < lowThreshold) {
      // ETF is too cheap, this is a negative rebase decreasing the supply
      uint256 factor = BASE.add(BASE.mul(averageSNP.sub(averageETF)).div(averageETF.mul(10)));
      uint256 increase = factor.sub(BASE);
      uint256 realAdjustment = increase.mul(BASE).div(factor);
      uint256 currentSupply = IERC20(etf).totalSupply();
      uint256 desiredSupply = currentSupply.sub(currentSupply.mul(realAdjustment).div(BASE));
      uint256 lowerLimit = currentSupply.mul(basisBase.sub(negativeRebaseLimit)).div(basisBase);
      if(desiredSupply < lowerLimit) // Decrease expected rebase is below the limit
        desiredSupply = lowerLimit;
      // Cannot overflow as desiredSupply < currentSupply
      // delta = 100 - (desiredSupply / currentSupply) * 100
      uint256 delta = uint256(BASE).sub(desiredSupply.mul(BASE).div(currentSupply));
      IETF(etf).rebase(epoch, delta, false);
      uniswapSyncer.sync();
      epoch++;
    } else {
      // else the price is within bounds
      emit NoRebaseNeeded();
    }
  }

  /**
  * Calculates how a rebase would look if it was triggered now.
  */
  function calculateRealTimeRebasePreTax() public view returns (uint256, uint256) {
    // only rebase if there is a 5% difference between the price of SNP and ETF
    uint256 highThreshold = averageSNP.mul(105).div(100);
    uint256 lowThreshold = averageSNP.mul(95).div(100);

    if (averageETF > highThreshold) {
      // ETF is too expensive, this is a positive rebase increasing the supply
      uint256 factor = BASE.sub(BASE.mul(averageETF.sub(averageSNP)).div(averageETF.mul(10)));
      uint256 increase = BASE.sub(factor);
      uint256 realAdjustment = increase.mul(BASE).div(factor);
      uint256 currentSupply = IERC20(etf).totalSupply();
      uint256 desiredSupply = currentSupply.add(currentSupply.mul(realAdjustment).div(BASE));
      uint256 upperLimit = currentSupply.mul(basisBase.add(positiveRebaseLimit)).div(basisBase);
      if(desiredSupply > upperLimit) // Increase expected rebase is above the limit
        desiredSupply = upperLimit;
      uint256 perpetualPoolTax = taxManager.getPerpetualPoolTaxRate();
      uint256 totalTax = taxManager.getTotalTaxAtMint();
      uint256 taxDivisor = taxManager.getTaxBaseDivisor();
      uint256 secondaryPoolBudget = desiredSupply.sub(currentSupply).mul(perpetualPoolTax).div(taxDivisor); // 4.5% to perpetual pool/escrow
      uint256 totalRewardBudget = desiredSupply.sub(currentSupply).mul(totalTax).div(taxDivisor); // This amount of token will get minted when rewards are claimed and distributed via perpetual pool
      desiredSupply = desiredSupply.sub(totalRewardBudget);

      // Cannot underflow as desiredSupply > currentSupply, the result is positive
      // delta = (desiredSupply / currentSupply) * 100 - 100
      uint256 delta = desiredSupply.mul(BASE).div(currentSupply).sub(BASE);
      return (delta, secondaryPool == address(0) ? 0 : secondaryPoolBudget);
    } else if (averageETF < lowThreshold) {
      // ETF is too cheap, this is a negative rebase decreasing the supply
      uint256 factor = BASE.add(BASE.mul(averageSNP.sub(averageETF)).div(averageETF.mul(10)));
      uint256 increase = factor.sub(BASE);
      uint256 realAdjustment = increase.mul(BASE).div(factor);
      uint256 currentSupply = IERC20(etf).totalSupply();
      uint256 desiredSupply = currentSupply.sub(currentSupply.mul(realAdjustment).div(BASE));
      uint256 lowerLimit = currentSupply.mul(basisBase.sub(negativeRebaseLimit)).div(basisBase);
      if(desiredSupply < lowerLimit) // Decrease expected rebase is below the limit
        desiredSupply = lowerLimit;
      // Cannot overflow as desiredSupply < currentSupply
      // delta = 100 - (desiredSupply / currentSupply) * 100
      uint256 delta = uint256(BASE).sub(desiredSupply.mul(BASE).div(currentSupply));
      return (delta, 0);
    } else {
      return (0,0);
    }
  }
  function recoverTokens(
    address _token,
    address benefactor
  ) public onlyGov {
    uint256 tokenBalance = IERC20(_token).balanceOf(address(this));
    IERC20(_token).transfer(benefactor, tokenBalance);
  }

  function getPriceSNP() public view returns (bool, uint256);
  function getPriceETF() public view returns (bool, uint256);
}

pragma solidity ^0.5.16;

import "./openzeppelin/SafeMath.sol";
import "./interfaces/AggregatorV3Interface.sol";

contract ChainlinkOracle {

  using SafeMath for uint256;

  address public oracle; // Address on polyscan 0x187c42f6C0e7395AeA00B1B30CB0fF807ef86d5d;
  constructor (address _oracle) public {
    oracle = _oracle;
  }

  function getPriceSNP() public view returns (bool, uint256) {
    // answer has 8 decimals, it is the price of SPY.US which is 1/10th of SNP500
    // if the round is not completed, updated at is 0
    (,int256 answer,,uint256 updatedAt,) = AggregatorV3Interface(oracle).latestRoundData();
    // add 10 decimals at the end
    return (updatedAt != 0, uint256(answer).mul(1e10));
  }
}

pragma solidity ^0.5.0;

interface AggregatorV3Interface {

  function decimals() external view returns (uint8);
  function description() external view returns (string memory);
  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}

pragma solidity 0.5.16;

interface IETF {
  function rebase(uint256 epoch, uint256 supplyDelta, bool positive) external;
  function mint(address to, uint256 amount) external;
  function getPriorBalance(address account, uint blockNumber) external view returns (uint256);
  function mintForReferral(address to, uint256 amount) external;
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address from, address to, uint256 value) external returns (bool);
  function balanceOf(address who) external view returns (uint256);
  function transferForRewards(address to, uint256 value) external returns (bool);
  function transfer(address to, uint256 value) external returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.5.16;

interface IPoolEscrow {
  function notifySecondaryTokens(uint256 number) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.5.16;

interface ITaxManager {
    function getSelfTaxPool() external returns (address);
    function getRightUpTaxPool() external view returns (address);
    function getMaintenancePool() external view returns (address);
    function getDevPool() external view returns (address);
    function getRewardAllocationPool() external view returns (address);
    function getPerpetualPool() external view returns (address);
    function getTierPool() external view returns (address);
    function getMarketingPool() external view returns (address);
    function getRevenuePool() external view returns (address);

    function getSelfTaxRate() external returns (uint256);
    function getRightUpTaxRate() external view returns (uint256);
    function getMaintenanceTaxRate() external view returns (uint256);
    function getProtocolTaxRate() external view returns (uint256);
    function getTotalTaxAtMint() external view returns (uint256);
    function getPerpetualPoolTaxRate() external view returns (uint256);
    function getTaxBaseDivisor() external view returns (uint256);
    function getReferralRate(uint256, uint256) external view returns (uint256);
    function getTierPoolRate() external view returns (uint256);
    // function getDevPoolRate() external view returns (uint256);
    function getMarketingTaxRate() external view returns (uint256);
    function getRewardPoolRate() external view returns (uint256);
}

// File: @openzeppelin/contracts/utils/Address.sol

pragma solidity ^0.5.5;

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
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Converts an `address` into `address payable`. Note that this is
     * simply a type cast: the actual underlying value is not changed.
     *
     * _Available since v2.4.0._
     */
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     *
     * _Available since v2.4.0._
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
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

// File: @openzeppelin/contracts/token/ERC20/SafeERC20.sol
import "./SafeMath.sol";
import "./Address.sol";
import "./IERC20.sol";
pragma solidity ^0.5.0;

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: @openzeppelin/contracts/math/SafeMath.sol

pragma solidity ^0.5.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

pragma solidity ^0.5.16;

import "./BasicRebaser.sol";
import "./ChainlinkOracle.sol";
import "./UniswapOracle.sol";

contract Rebaser is BasicRebaser, UniswapOracle, ChainlinkOracle {

  constructor (address router, address usdc, address wNative, address token, address _treasury, address oracle, address _taxManager)
  BasicRebaser(token, _treasury, _taxManager)
  ChainlinkOracle(oracle)
  UniswapOracle(router, usdc, wNative, token) public {
  }

}

pragma solidity ^0.5.16;

import "./openzeppelin/SafeMath.sol";

contract IUniswapRouterV2 {
  function getAmountsOut(uint256 amountIn, address[] memory path) public view returns (uint256[] memory amounts);
}

contract UniswapOracle {

  using SafeMath for uint256;

  address public router; // 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff;
  address public usdc; //0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
  address public wNative;// 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;
  address public etf;
  address[] public path;

  constructor (address _router, address _usdc, address _wNative, address token) public {
    router = _router;
    usdc = _usdc;
    wNative = _wNative;
    etf = token;
    path = [etf, wNative, usdc];
  }

  function getPriceETF() public view returns (bool, uint256) {
    uint256[] memory amounts = IUniswapRouterV2(router).getAmountsOut(1e18, path);
    // returns the price with 6 decimals on eth and polygon mainnet, but we want 18
    // return (etf != address(0), amounts[2].mul(1e12));
    // On BSC it is 18 decimals, since USDC is 18 decimals
    return (etf != address(0), amounts[2]);
  }
}