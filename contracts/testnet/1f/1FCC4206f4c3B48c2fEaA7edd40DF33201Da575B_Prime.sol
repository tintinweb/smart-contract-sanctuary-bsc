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

  function getACLManager() external view returns (address);

  function getSpent() external view returns (address);

  function getEusd() external view returns (address);

  function getACLAdmin() external view returns (address);

  function getZapContract() external view returns (address);

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

  /***************************************************** */
  /*********************SETTERS************************* */
  /***************************************************** */

  function setAddress(bytes32 id, address newAddress) external;

  function setACLManager(address newAclManager) external;

  function setACLAdmin(address newAclAdmin) external;
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

  event Enable(address from, uint256 amountLp, uint256 eusd, uint256 pid);
  event Claim(address by, uint256 amount, uint256 poolId);

  /********************************************************* */
  /************************STRUCT*************************** */
  /********************************************************* */
  struct Pool {
    address rewardToken; // reward token
    address inputToken; // any stable token
    bool trigger; // for member trigger
    uint256 pId; // stake id
    uint256 fId; // fee id
    uint256 dd; // duration deadline
    uint256 tvl; // total tvl in pool
    uint256 multiplier;
    uint256 frp; // fixed return percentage
  }

  struct User {
    uint256 checkpoint; // check point in timestamp
    uint256 endpoint; // end of this / latest depoist reward duration
    uint256 amount; // usd amout of asset
    uint256 debt;
    uint256 hold;
    uint256 lpAmount;
    uint256 lockedTill;
  }

  /********************************************************* */
  /************************FUNCTIONS************************ */
  /********************************************************* */
  function poolApr(uint256 _pId) external returns (uint256 apr);

  function claim(uint256 _pId, address account) external returns (bool);

  function checkClaimable(uint256 _pId, address account) external returns (uint256 currentClaimable, uint256 rewardEarned);

  function stake(uint256 _pId, uint256 amount, address account) external returns (bool);

  function userInfo(uint256 pId, address account) external returns (User memory);

  function poolCount() external returns (uint256);

  function depositCount() external returns (uint256);

  function poolInfo(uint256 index) external returns (Pool memory pool);

  function setFee(uint256 index, uint256 amount) external returns (bool);

  function lock(uint256 _pId, uint256 duration, address account) external returns (bool);

  function unStake(uint256 _pId, uint256 amount, address account) external returns (bool);

  function add(uint256 fid, bool trigger, address rt, address it, uint256 dd, uint256 multiplier, uint256 frp) external returns (bool);
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

  function EnableStableTokens(uint256 _pId, uint256 amount) external returns (bool);

  function EnableSwapLpTokens(uint256 _pId, uint256 amount) external returns (bool);

  function EnableSwapLpToken(uint256 _pId, uint256 amount) external returns (bool);

  function EnableBorrowStakeTokens(uint256 _pId, uint256 amount) external returns (bool);

  function ClaimStableToken(uint256 _pId) external returns (bool);

  function ClaimSwapLpToken(uint256 _pId) external returns (bool);

  function ClaimSwapToken(uint256 _pId) external returns (bool);

  function ClaimBorrowStakeToken(uint256 _pId) external returns (bool);

  function LockStableToken(uint256 pId, uint256 duration) external returns (bool);

  function LockSwapLpToken(uint256 pId, uint256 duration) external returns (bool);

  function LockSwapToken(uint256 pId, uint256 duration) external returns (bool);

  function LockBorrowStakeToken(uint256 pId, uint256 duration) external returns (bool);

  function DisableStableToken(uint256 pId, uint256 amount) external returns (bool);

  function DisableSwapLpToken(uint256 pId, uint256 amount) external returns (bool);

  function DisableSwapToken(uint256 pId, uint256 amount) external returns (bool);

  function DisableBorrowStakeToken(uint256 pId, uint256 amount) external returns (bool);

  /********************************************************* */
  /*********************CROP-YARD*************************** */
  /********************************************************* */
  function EnterFarm(uint256 _pId, uint256 amount) external returns (bool);

  function Harvest(uint256 _pId) external returns (bool);

  function LockFarm(uint256 _pId, uint256 duration) external returns (bool);

  function ExitFarm(uint256 _pId, uint256 amount) external returns (bool);

  /********************************************************* */
  /*********************LEND-BORROW************************* */
  /********************************************************* */
  function BorrowStart(uint256 amount) external returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import { IAddressesProvider } from "../../common/configuration/AddressProvider/IAddressesProvider.sol";
import { ILendingBorrowing } from "../LendingBorrowing/interface/ILendingBorrowing.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { IBarterRouter } from "../Barter/interface/IBarterRouter.sol";
import { ICropYard } from "../CropYard/interface/ICropYard.sol";
import { IBarterZap } from "../Barter/interface/IBarterZap.sol";
import { IUpRight } from "../UpRight/interface/IUpRight.sol";
import { IPrime } from "./interface/IPrime.sol";

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
  ) public override returns (uint256 amountA, uint256 amountB, uint256 liquidity) {
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
  ) public override returns (uint256 amountA, uint256 amountB) {
    return IBarterRouter(ADDRESSES_PROVIDER.getBarterRouter()).removeLiquidity(tokenA, tokenB, liquidity, amountAMin, amountBMin, msg.sender, deadline);
  }

  // **** SWAP ****
  function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    uint256 deadline
  ) public override returns (uint256[] memory amounts) {
    return IBarterRouter(ADDRESSES_PROVIDER.getBarterRouter()).swapExactTokensForTokens(amountIn, amountOutMin, path, msg.sender, deadline);
  }

  // **** SWAP ****
  function swapTokensForExactTokens(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    uint256 deadline
  ) public override returns (uint256[] memory amounts) {
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
  function EnableStableTokens(uint256 _pId, uint256 amount) public override nonReentrant returns (bool) {
    IUpRight(ADDRESSES_PROVIDER.getUpRightContract()).EnableStableTokens(_pId, amount, msg.sender);
    return true;
  }

  function EnableSwapLpTokens(uint256 _pId, uint256 amount) public override nonReentrant returns (bool) {
    IUpRight(ADDRESSES_PROVIDER.getUpRightContract()).EnableSwapLpTokens(_pId, amount, msg.sender);
    return true;
  }

  function EnableSwapLpToken(uint256 _pId, uint256 amount) public override nonReentrant returns (bool) {
    IUpRight(ADDRESSES_PROVIDER.getUpRightContract()).EnableSwapLpTokens(_pId, amount, msg.sender);
    return true;
  }

  function EnableBorrowStakeTokens(uint256 _pId, uint256 amount) public override nonReentrant returns (bool) {
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

  function DisableStableToken(uint256 pId, uint256 amount) public override nonReentrant returns (bool) {
    IUpRight(ADDRESSES_PROVIDER.getUpRightContract()).DisableStableToken(pId, amount, msg.sender);
    return true;
  }

  function DisableSwapLpToken(uint256 pId, uint256 amount) public override nonReentrant returns (bool) {
    IUpRight(ADDRESSES_PROVIDER.getUpRightContract()).DisableSwapLpToken(pId, amount, msg.sender);
    return true;
  }

  function DisableSwapToken(uint256 pId, uint256 amount) public override nonReentrant returns (bool) {
    IUpRight(ADDRESSES_PROVIDER.getUpRightContract()).DisableSwapToken(pId, amount, msg.sender);
    return true;
  }

  function DisableBorrowStakeToken(uint256 pId, uint256 amount) public override nonReentrant returns (bool) {
    IUpRight(ADDRESSES_PROVIDER.getUpRightContract()).DisableBorrowStakeToken(pId, amount, msg.sender);
    return true;
  }

  /********************************************************* */
  /************************CROP-YARD************************ */
  /********************************************************* */

  function EnterFarm(uint256 _pId, uint256 amount) public override nonReentrant returns (bool) {
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

  function ExitFarm(uint256 _pId, uint256 amount) public override nonReentrant returns (bool) {
    ICropYard(ADDRESSES_PROVIDER.getCropYardContract()).unStake(_pId, amount, msg.sender);
    return true;
  }

  /********************************************************* */
  /*********************LEND-BORROW************************* */
  /********************************************************* */
  function BorrowStart(uint256 amount) public override nonReentrant returns (bool) {
    ILendingBorrowing(ADDRESSES_PROVIDER.getBorrowLendContract()).start(msg.sender, amount);
    return true;
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