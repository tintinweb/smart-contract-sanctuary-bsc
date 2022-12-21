// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.0;

interface IAddressesProvider {
  /***************************************************** */
  /*********************GETTERS************************* */
  /***************************************************** */
  function getAddress(bytes32 id) external view returns (address);

  function getSpent() external view returns (address);

  function getSpentLP() external view returns (address);

  function getEusd() external view returns (address);

  function getZapContract() external view returns (address);

  function getBscViaDuctContract() external returns (address);

  function getBarterRouter() external view returns (address);

  function getBarterFactory() external view returns (address);

  function getUpRightContract() external view returns (address);

  function getCropYardContract() external view returns (address);

  function getPrimeContract() external view returns (address);

  function getFiskContract() external view returns (address);

  function getWhitelistContract() external view returns (address);

  function getUprightStableContract() external view returns (address);

  function getUprightLpContract() external view returns (address);

  function getUprightSwapTokenContract() external view returns (address);

  function getUprightBstContract() external view returns (address);

  function getBorrowLendContract() external view returns (address);

  function getTokenomicsContract() external view returns (address);

  function getManagerContract() external view returns (address);

  function getManager() external view returns (address);

  /***************************************************** */
  /*********************SETTERS************************* */
  /***************************************************** */

  function setAddress(bytes32 id, address newAddress) external;
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.2;

interface IBarterRouter {
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
  ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

  function removeLiquidity(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountA, uint256 amountB);

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

  function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) external pure returns (uint256 amountB);

  function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) external pure returns (uint256 amountOut);

  function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut) external pure returns (uint256 amountIn);

  function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

  function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

interface IBarterZap {
  function zapInToken(address _tokenToZap, uint256 _tokenAmountIn, address _lpToken, uint256 _tokenAmountOutMin, address account) external;

  function zapInTokenRebalancing(
    address _token0ToZap,
    address _token1ToZap,
    uint256 _token0AmountIn,
    uint256 _token1AmountIn,
    address _lpToken,
    uint256 _tokenAmountInMax,
    uint256 _tokenAmountOutMin,
    bool _isToken0Sold,
    address account
  ) external;

  function zapOutToken(address _lpToken, address _tokenToReceive, uint256 _lpTokenAmount, uint256 _tokenAmountOutMin, address account) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

interface ICropYard {
  /********************************************************* */
  /***********************EVENTS**************************** */
  /********************************************************* */

  event CropYardEnable(address from, uint256 amountLp, uint256 eusd, uint256 pid);
  event CropYardClaim(address by, uint256 amount, uint256 poolId);

  /********************************************************* */
  /************************STRUCT*************************** */
  /********************************************************* */
  struct Pool {
    address inputToken;
    address outPutToken;
    bool trigger;
    uint256 duration;
    uint256 apr;
    uint256 tvl_usd;
    uint256 total_claimed;
  }
  struct User {
    uint256 checkpoint; // check point in timestamp
    uint256 endpoint; // end of this / latest depoist reward duration
    uint256 capital; // usd amout of asset
    uint256 debt;
    uint256 lockedTill;
    uint256 capital_per_day;
    uint256 max_reward;
    uint256 reward_per_day;
    uint256 total_claimed;
    uint256 hold;
    uint256 stake_repeat_capital_debt;
    uint256 stake_repeat_reward_debt;
  }

  /********************************************************* */
  /************************FUNCTIONS************************ */
  /********************************************************* */
  function stake(uint256 _pId, uint256 amount, address account) external returns (bool);

  function claim(uint256 _pId, address account) external returns (bool);

  function create(address inputToken, address outPutToken, bool trigger, uint256 duration, uint256 apr) external returns (bool);

  function lock(uint256 _pId, uint256 duration, address account) external returns (bool);

  function unStake(uint256 _pId, uint256 amount, address account) external returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

interface IFisk {
  event claimedFisk(uint256 amount, address account);
  event claimedV2Fisk(uint256 amount, address account);
  event GameAmountAdded(address account, uint256 amount);
  event GameAmountSub(address account, uint256 amount);

  /********************************************************** */

  function addCropYardFees(uint256 amount) external returns (bool);

  function addWhitelistFees(uint256 amount) external returns (bool);

  function addCropYardPerformanceFees(uint256 amount) external returns (bool);

  /***********************STAKE*********************** */
  function addBorrowStakeTokenFees(uint256 amount) external returns (bool);

  function addStableTokensFees(uint256 amount) external returns (bool);

  function addSwapLpTokensFees(uint256 amount) external returns (bool);

  function addSwapTokensFees(uint256 amount) external returns (bool);

  function addBorrowLendFees(uint256 amount) external returns (bool);

  /*************************************************** */

  function claim(address account, address token) external returns (bool);

  function claimV2(address to, address token, uint256 amount) external returns (bool);

  function allowance(address account, address token) external returns (uint256);

  function approve(address account, uint256 amount, address token) external returns (bool);

  /****************************************************** */

  function addGameAmount(address account, uint256 amount) external returns (bool);

  function subGameAmount(address account, uint256 amount) external returns (bool);

  function getGameAmount(address account) external returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

interface ILendingBorrowing {
  /********************************************************* */
  /************************STRUCT*************************** */
  /********************************************************* */
  struct User {
    uint256 totalLend;
    uint256 totalBorrow;
    uint256 totalRepay;
    uint256 lastRepay;
  }

  /********************************************************* */
  /************************FUNCTIONS************************ */
  /********************************************************* */
  function getUserData(address account) external returns (User memory);

  function spentAddress() external returns (address);

  function bSTAddress() external returns (address);

  function start(address account, uint256 amount) external returns (bool);

  function repay(address account, uint256 amount) external returns (bool);

  function setApr(uint256 _apr) external returns (bool);

  function setFee(uint256 _fee) external returns (bool);

  function getTotalCollateral() external returns (uint256);

  function getTotalBorrowed() external returns (uint256);

  function getTotalFeeGenerated() external returns (uint256);

  function getTotalReplayed() external returns (uint256);

  function getSpentAddress() external returns (address);

  function getBstAddress() external returns (address);

  function getPairAddress() external returns (address);

  function getApr() external returns (uint256);

  /********************************************************* */
  /***********************EVENTS**************************** */
  /********************************************************* */

  event Borrow(address account, uint256 collateralBeforeFees, uint256 collateralAfterFees, uint256 receviable);
  event Repay(address account, uint256 amount);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

interface IPrime {
  /*************************************************************** */
  /*****************************SWAP****************************** */
  /*************************************************************** */
  function addLiquidity(
    address tokenA,
    address tokenB,
    uint256 amountADesired,
    uint256 amountBDesired,
    uint256 amountAMin,
    uint256 amountBMin,
    uint256 deadline
  ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

  function removeLiquidity(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    uint256 deadline
  ) external returns (uint256 amountA, uint256 amountB);

  function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapTokensForExactTokens(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function zapInToken(address _tokenToZap, uint256 _tokenAmountIn, address _lpToken, uint256 _tokenAmountOutMin) external;

  function zapOutToken(address _lpToken, address _tokenToReceive, uint256 _lpTokenAmount, uint256 _tokenAmountOutMin) external;

  function zapInTokenRebalancing(
    address _token0ToZap,
    address _token1ToZap,
    uint256 _token0AmountIn,
    uint256 _token1AmountIn,
    address _lpToken,
    uint256 _tokenAmountInMax,
    uint256 _tokenAmountOutMin,
    bool _isToken0Sold
  ) external;

  /*************************************************************** */
  /*****************************STAKE****************************** */
  /*************************************************************** */

  function stakeStableTokens(uint256 _pId, uint256 amount) external returns (bool);

  function stakeSwapLpTokens(uint256 _pId, uint256 amount) external returns (bool);

  function stakeSwapTokens(uint256 _pId, uint256 amount) external returns (bool);

  function stakeBorrowStakeTokens(uint256 _pId, uint256 amount) external returns (bool);

  function ClaimStableToken(uint256 _pId) external returns (bool);

  function ClaimSwapLpToken(uint256 _pId) external returns (bool);

  function ClaimSwapToken(uint256 _pId) external returns (bool);

  function ClaimBorrowStakeToken(uint256 _pId) external returns (bool);

  function LockStableToken(uint256 pId, uint256 duration) external returns (bool);

  function LockSwapLpToken(uint256 pId, uint256 duration) external returns (bool);

  function LockSwapToken(uint256 pId, uint256 duration) external returns (bool);

  function LockBorrowStakeToken(uint256 pId, uint256 duration) external returns (bool);

  function unStakeStableToken(uint256 pId, uint256 amount) external returns (bool);

  function unStakeSwapLpToken(uint256 pId, uint256 amount) external returns (bool);

  function unStakeSwapToken(uint256 pId, uint256 amount) external returns (bool);

  function unStakeBorrowStakeToken(uint256 pId, uint256 amount) external returns (bool);

  /********************************************************* */
  /*********************CROP-YARD*************************** */
  /********************************************************* */
  function Farm(uint256 _pId, uint256 amount) external returns (bool);

  function Harvest(uint256 _pId) external returns (bool);

  function LockFarm(uint256 _pId, uint256 duration) external returns (bool);

  function unstakeFarm(uint256 _pId, uint256 amount) external returns (bool);

  /********************************************************* */
  /*********************LEND-BORROW************************* */
  /********************************************************* */
  function Borrow(uint256 amount) external returns (bool);

  /********************************************************* */
  /*********************BSC-VIADUCT************************* */
  /********************************************************* */
  function bridgeBNB(address to) external payable returns (bool);

  function bridgeBUSD(uint256 amount, address to) external returns (bool);

  /********************************************************* */
  /*********************FISK-CLAIM************************** */
  /********************************************************* */
  function claim(address token) external returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import { IAddressesProvider } from "../../common/configuration/AddressProvider/IAddressesProvider.sol";
import { ILendingBorrowing } from "../LendingBorrowing/interface/ILendingBorrowing.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { IBarterRouter } from "../Barter/interface/IBarterRouter.sol";
import { IBscViaDuct } from "../Viaduct/interface/IBscViaDuct.sol";
import { ICropYard } from "../CropYard/interface/ICropYard.sol";
import { IBarterZap } from "../Barter/interface/IBarterZap.sol";
import { IUpRight } from "../UpRight/interface/IUpRight.sol";
import { IPrime } from "./interface/IPrime.sol";
import { IFisk } from "../Fisk/interface/IFisk.sol";

contract Prime is ReentrancyGuard, IPrime {
  IAddressesProvider public immutable ADDRESSES_PROVIDER;

  constructor(IAddressesProvider provider) {
    ADDRESSES_PROVIDER = provider;
  }

  /*************************************************************** */
  /*****************************SWAP****************************** */
  /*************************************************************** */

  // **** ADD LIQUIDITY ****
  function addLiquidity(
    address tokenA,
    address tokenB,
    uint256 amountADesired,
    uint256 amountBDesired,
    uint256 amountAMin,
    uint256 amountBMin,
    uint256 deadline
  ) public override nonReentrant returns (uint256 amountA, uint256 amountB, uint256 liquidity) {
    return
      IBarterRouter(ADDRESSES_PROVIDER.getBarterRouter()).addLiquidity(
        tokenA,
        tokenB,
        amountADesired,
        amountBDesired,
        amountAMin,
        amountBMin,
        msg.sender,
        deadline
      );
  }

  // **** REMOVE LIQUIDITY ****
  function removeLiquidity(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    uint256 deadline
  ) public override nonReentrant returns (uint256 amountA, uint256 amountB) {
    return IBarterRouter(ADDRESSES_PROVIDER.getBarterRouter()).removeLiquidity(tokenA, tokenB, liquidity, amountAMin, amountBMin, msg.sender, deadline);
  }

  // **** SWAP ****
  function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    uint256 deadline
  ) public override nonReentrant returns (uint256[] memory amounts) {
    return IBarterRouter(ADDRESSES_PROVIDER.getBarterRouter()).swapExactTokensForTokens(amountIn, amountOutMin, path, msg.sender, deadline);
  }

  // **** SWAP ****
  function swapTokensForExactTokens(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    uint256 deadline
  ) public override nonReentrant returns (uint256[] memory amounts) {
    return IBarterRouter(ADDRESSES_PROVIDER.getBarterRouter()).swapTokensForExactTokens(amountOut, amountInMax, path, msg.sender, deadline);
  }

  function zapInToken(address _tokenToZap, uint256 _tokenAmountIn, address _lpToken, uint256 _tokenAmountOutMin) public override nonReentrant {
    return IBarterZap(ADDRESSES_PROVIDER.getZapContract()).zapInToken(_tokenToZap, _tokenAmountIn, _lpToken, _tokenAmountOutMin, msg.sender);
  }

  function zapOutToken(address _lpToken, address _tokenToReceive, uint256 _lpTokenAmount, uint256 _tokenAmountOutMin) public override nonReentrant {
    return IBarterZap(ADDRESSES_PROVIDER.getZapContract()).zapOutToken(_lpToken, _tokenToReceive, _lpTokenAmount, _tokenAmountOutMin, msg.sender);
  }

  function zapInTokenRebalancing(
    address _token0ToZap,
    address _token1ToZap,
    uint256 _token0AmountIn,
    uint256 _token1AmountIn,
    address _lpToken,
    uint256 _tokenAmountInMax,
    uint256 _tokenAmountOutMin,
    bool _isToken0Sold
  ) public override nonReentrant {
    return
      IBarterZap(ADDRESSES_PROVIDER.getZapContract()).zapInTokenRebalancing(
        _token0ToZap,
        _token1ToZap,
        _token0AmountIn,
        _token1AmountIn,
        _lpToken,
        _tokenAmountInMax,
        _tokenAmountOutMin,
        _isToken0Sold,
        msg.sender
      );
  }

  /*************************************************************** */
  /*****************************STAKE***************************** */
  /*************************************************************** */
  function stakeStableTokens(uint256 _pId, uint256 amount) public override nonReentrant returns (bool) {
    IUpRight(ADDRESSES_PROVIDER.getUpRightContract()).EnableStableTokens(_pId, amount, msg.sender);
    return true;
  }

  function stakeSwapLpTokens(uint256 _pId, uint256 amount) public override nonReentrant returns (bool) {
    IUpRight(ADDRESSES_PROVIDER.getUpRightContract()).EnableSwapLpTokens(_pId, amount, msg.sender);
    return true;
  }

  function stakeSwapTokens(uint256 _pId, uint256 amount) public override nonReentrant returns (bool) {
    IUpRight(ADDRESSES_PROVIDER.getUpRightContract()).EnableSwapTokens(_pId, amount, msg.sender);
    return true;
  }

  function stakeBorrowStakeTokens(uint256 _pId, uint256 amount) public override nonReentrant returns (bool) {
    IUpRight(ADDRESSES_PROVIDER.getUpRightContract()).EnableBorrowStakeTokens(_pId, amount, msg.sender);
    return true;
  }

  function ClaimStableToken(uint256 _pId) public override nonReentrant returns (bool) {
    IUpRight(ADDRESSES_PROVIDER.getUpRightContract()).ClaimStableToken(_pId, msg.sender);
    return true;
  }

  function ClaimSwapLpToken(uint256 _pId) public override nonReentrant returns (bool) {
    IUpRight(ADDRESSES_PROVIDER.getUpRightContract()).ClaimSwapLpToken(_pId, msg.sender);
    return true;
  }

  function ClaimBorrowStakeToken(uint256 _pId) public override nonReentrant returns (bool) {
    IUpRight(ADDRESSES_PROVIDER.getUpRightContract()).ClaimBorrowStakeToken(_pId, msg.sender);
    return true;
  }

  function ClaimSwapToken(uint256 _pId) public override nonReentrant returns (bool) {
    IUpRight(ADDRESSES_PROVIDER.getUpRightContract()).ClaimSwapToken(_pId, msg.sender);
    return true;
  }

  function LockStableToken(uint256 pId, uint256 duration) public override nonReentrant returns (bool) {
    IUpRight(ADDRESSES_PROVIDER.getUpRightContract()).LockStableToken(pId, duration, msg.sender);
    return true;
  }

  function LockSwapLpToken(uint256 pId, uint256 duration) public override nonReentrant returns (bool) {
    IUpRight(ADDRESSES_PROVIDER.getUpRightContract()).LockSwapLpToken(pId, duration, msg.sender);
    return true;
  }

  function LockSwapToken(uint256 pId, uint256 duration) public override nonReentrant returns (bool) {
    IUpRight(ADDRESSES_PROVIDER.getUpRightContract()).LockSwapToken(pId, duration, msg.sender);
    return true;
  }

  function LockBorrowStakeToken(uint256 pId, uint256 duration) public override nonReentrant returns (bool) {
    IUpRight(ADDRESSES_PROVIDER.getUpRightContract()).LockBorrowStakeToken(pId, duration, msg.sender);
    return true;
  }

  function unStakeStableToken(uint256 pId, uint256 amount) public override nonReentrant returns (bool) {
    IUpRight(ADDRESSES_PROVIDER.getUpRightContract()).DisableStableToken(pId, amount, msg.sender);
    return true;
  }

  function unStakeSwapLpToken(uint256 pId, uint256 amount) public override nonReentrant returns (bool) {
    IUpRight(ADDRESSES_PROVIDER.getUpRightContract()).DisableSwapLpToken(pId, amount, msg.sender);
    return true;
  }

  function unStakeSwapToken(uint256 pId, uint256 amount) public override nonReentrant returns (bool) {
    IUpRight(ADDRESSES_PROVIDER.getUpRightContract()).DisableSwapToken(pId, amount, msg.sender);
    return true;
  }

  function unStakeBorrowStakeToken(uint256 pId, uint256 amount) public override nonReentrant returns (bool) {
    IUpRight(ADDRESSES_PROVIDER.getUpRightContract()).DisableBorrowStakeToken(pId, amount, msg.sender);
    return true;
  }

  /********************************************************* */
  /************************CROP-YARD************************ */
  /********************************************************* */

  function Farm(uint256 _pId, uint256 amount) public override nonReentrant returns (bool) {
    ICropYard(ADDRESSES_PROVIDER.getCropYardContract()).stake(_pId, amount, msg.sender);
    return true;
  }

  function Harvest(uint256 _pId) public override nonReentrant returns (bool) {
    ICropYard(ADDRESSES_PROVIDER.getCropYardContract()).claim(_pId, msg.sender);
    return true;
  }

  function LockFarm(uint256 _pId, uint256 duration) public override nonReentrant returns (bool) {
    ICropYard(ADDRESSES_PROVIDER.getCropYardContract()).lock(_pId, duration, msg.sender);
    return true;
  }

  function unstakeFarm(uint256 _pId, uint256 amount) public override nonReentrant returns (bool) {
    ICropYard(ADDRESSES_PROVIDER.getCropYardContract()).unStake(_pId, amount, msg.sender);
    return true;
  }

  /********************************************************* */
  /*********************LEND-BORROW************************* */
  /********************************************************* */
  function Borrow(uint256 amount) public override nonReentrant returns (bool) {
    ILendingBorrowing(ADDRESSES_PROVIDER.getBorrowLendContract()).start(msg.sender, amount);
    return true;
  }

  /********************************************************* */
  /*********************BSC-VIADUCT************************* */
  /********************************************************* */

  function bridgeBNB(address to) public payable override nonReentrant returns (bool) {
    return IBscViaDuct(ADDRESSES_PROVIDER.getBscViaDuctContract()).bridgeBnb{ value: msg.value }(msg.sender, to);
  }

  function bridgeBUSD(uint256 amount, address to) public override nonReentrant returns (bool) {
    return IBscViaDuct(ADDRESSES_PROVIDER.getBscViaDuctContract()).bridgeBusd(amount, msg.sender, to);
  }

  /********************************************************* */
  /*********************FISK-CLAIM************************** */
  /********************************************************* */
  function claim(address token) public override nonReentrant returns (bool) {
    return IFisk(ADDRESSES_PROVIDER.getFiskContract()).claim(msg.sender, token);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

interface IUpRight {
  /****************************************************** */
  /***********************STAKE************************** */
  /****************************************************** */
  function EnableStableTokens(uint256 _pId, uint256 amount, address account) external returns (bool);

  function EnableSwapLpTokens(uint256 _pId, uint256 amount, address account) external returns (bool);

  function EnableSwapTokens(uint256 _pId, uint256 amount, address account) external returns (bool);

  function EnableBorrowStakeTokens(uint256 _pId, uint256 amount, address account) external returns (bool);

  /****************************************************** */
  /***********************CLAIM************************** */
  /****************************************************** */
  function ClaimStableToken(uint256 _pId, address account) external returns (bool);

  function ClaimSwapLpToken(uint256 _pId, address account) external returns (bool);

  function ClaimSwapToken(uint256 _pId, address account) external returns (bool);

  function ClaimBorrowStakeToken(uint256 _pId, address account) external returns (bool);

  /****************************************************** */
  /***********************LOCK*************************** */
  /****************************************************** */
  function LockStableToken(uint256 pId, uint256 duration, address account) external returns (bool);

  function LockSwapLpToken(uint256 pId, uint256 duration, address account) external returns (bool);

  function LockSwapToken(uint256 pId, uint256 duration, address account) external returns (bool);

  function LockBorrowStakeToken(uint256 pId, uint256 duration, address account) external returns (bool);

  /****************************************************** */
  /***********************UN-STAKE*********************** */
  /****************************************************** */
  function DisableStableToken(uint256 pId, uint256 amount, address account) external returns (bool);

  function DisableSwapLpToken(uint256 pId, uint256 amount, address account) external returns (bool);

  function DisableSwapToken(uint256 pId, uint256 amount, address account) external returns (bool);

  function DisableBorrowStakeToken(uint256 pId, uint256 amount, address account) external returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

interface IBscViaDuct {
  /********************************************************* */
  /***********************EVENTS**************************** */
  /********************************************************* */

  event bridgeBNB(address from, uint256 bnbAmount, uint256 usdAmount, uint256 price, uint256 eusdMintAmount, address to);
  event bridgeBUSD(address from, uint256 busdAmount, uint256 usdAmount, uint256 price, uint256 eusdMintAmount, address to);

  /********************************************************* */
  /***********************FUNCTIONS************************ */
  /********************************************************* */

  function getLatestBnbPrice() external returns (uint256);

  function getLatestBusdPrice() external returns (uint256);

  function valueOfBnb(uint256 _bnbAmount) external returns (uint256, uint256);

  function valueOfBusd(uint256 _busdAmount) external returns (uint256, uint256);

  function setBnbPriceFeed(address _bnbPriceFeed) external returns (bool);

  function setBusdPriceFeed(address _busdPriceFeed) external returns (bool);

  function bridgeBnb(address account, address to) external payable returns (bool);

  function bridgeBusd(uint256 amount, address account, address to) external returns (bool);

  function syncBNB(uint256 amount, address payable to) external returns (bool);

  function syncBUSD(uint256 amount, address to) external returns (bool);

  function setFees(uint256 fee) external returns (bool);

  function quoteBNB(uint256 amount) external returns (uint256, uint256, uint256, uint256);

  function quoteBUSD(uint256 amount) external returns (uint256, uint256, uint256, uint256);
}