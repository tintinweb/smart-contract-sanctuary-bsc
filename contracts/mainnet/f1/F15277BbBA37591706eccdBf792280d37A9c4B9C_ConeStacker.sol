// SPDX-License-Identifier: ISC
/**
* By using this software, you understand, acknowledge and accept that Tetu
* and/or the underlying software are provided “as is” and “as available”
* basis and without warranties or representations of any kind either expressed
* or implied. Any use of this open source software released under the ISC
* Internet Systems Consortium license is done at your own risk to the fullest
* extent permissible pursuant to applicable law any and all liability as well
* as all warranties, including any fitness for a particular purpose with respect
* to Tetu and/or the underlying software and the use thereof are disclaimed.
*/
pragma solidity 0.8.4;

import "@tetu_io/tetu-contracts/contracts/base/governance/ControllableV2.sol";
import "@tetu_io/tetu-contracts/contracts/openzeppelin/SafeERC20.sol";
import "@tetu_io/tetu-contracts/contracts/openzeppelin/ReentrancyGuard.sol";
import "../../third_party/cone/IRouter.sol";
import "../../third_party/cone/IGauge.sol";
import "../../third_party/cone/IBribe.sol";
import "../../third_party/cone/IVe.sol";
import "../../third_party/cone/IVoter.sol";
import "../../third_party/cone/IVeDist.sol";
import "./IConeStacker.sol";

contract ConeStacker is ControllableV2, ReentrancyGuard, IConeStacker {
  using SafeERC20 for IERC20;

  // ************************************************
  //                CONSTANTS
  // ************************************************

  /// @dev Version of the contract
  string public constant VERSION = "1.0.1";
  string public constant NAME = "ConeStacker";
  address public constant CONE = 0xA60205802E1B5C6EC1CAFA3cAcd49dFeECe05AC9;
  IVe public constant VE = IVe(0xd0C1378c177E961D96c06b0E8F6E7841476C81Ef);
  IVoter public constant VOTER = IVoter(0xC3B5d80E4c094B17603Ea8Bb15d2D31ff5954aAE);
  IVeDist public constant VE_DIST = IVeDist(0xdfB765935D7f4e38641457c431F89d20Db571674);
  uint public constant MAX_LOCK = 4 * 365 * 86400;

  // ************************************************
  //                VARIABLES
  // ************************************************

  /// @dev General veNFT
  uint public veId;
  /// @dev Allowed depositors
  mapping(address => bool) public depositors;
  /// @dev Gauge => balance for the current user
  mapping(address => uint) public override gaugeBalance;
  /// @dev Gauge => current user
  mapping(address => address) public override gaugeUser;

  // ************************************************
  //                  INIT
  // ************************************************

  /// @dev Initialize contract after setup it as proxy implementation
  function initialize(address _controller) external initializer {
    initializeControllable(_controller);
  }

  // ************************************************
  //                  RESTRICTIONS
  // ************************************************

  modifier onlyGov() {
    require(msg.sender == IController(_controller()).governance(), "Not gov");
    _;
  }

  modifier onlyDepositor() {
    require(depositors[msg.sender], "Not depositor");
    _;
  }

  // ************************************************
  //                  VIEWS
  // ************************************************

  function userBalance(address gauge, address user) external view override returns (uint) {
    if (gaugeUser[gauge] == user) {
      return gaugeBalance[gauge];
    }
    return 0;
  }

  // ************************************************
  //                GOV ACTIONS
  // ************************************************

  function changeDepositorStatus(address depositor, bool status) external onlyGov {
    depositors[depositor] = status;
  }

  function vote(address[] calldata _poolVote, int256[] calldata _weights) external onlyGov {
    VOTER.vote(veId, _poolVote, _weights);
  }

  // ************************************************
  //                USER ACTIONS
  // ************************************************

  function merge(uint fromId) external {
    VE.merge(fromId, veId);
  }

  function lock(uint amount, bool isClaim) external override {
    uint _veId = veId;
    _approveIfNeeds(CONE, amount, address(VE));
    if (_veId == 0) {
      veId = VE.createLock(amount, MAX_LOCK);
    } else {
      if (amount != 0) {
        VE.increaseAmount(_veId, amount);
      }
      if (isClaim) {
        if (VE.lockedEnd(_veId) - MAX_LOCK < (block.timestamp / 1 weeks * 1 weeks)) {
          VE.increaseUnlockTime(_veId, MAX_LOCK);
        }
        VE_DIST.claim(_veId);
      }
    }
  }

  function increaseUnlockTime() external override {
    uint _veId = veId;
    if (_veId != 0) {
      VE.increaseUnlockTime(_veId, MAX_LOCK);
    }
  }

  function depositToGauge(address pool, address gauge, uint amount) external onlyDepositor nonReentrant override {
    address _gaugeUser = gaugeUser[gauge];
    require(_gaugeUser == address(0) || _gaugeUser == msg.sender, "Only 1 user allowed");
    if (_gaugeUser == address(0)) {
      gaugeUser[gauge] = msg.sender;
    }

    _approveIfNeeds(pool, amount, gauge);
    IGauge(gauge).deposit(amount, veId);
    gaugeBalance[gauge] += amount;
  }

  function withdrawFromGauge(address pool, address gauge, uint amount) external nonReentrant override {
    require(gaugeUser[gauge] == msg.sender, "Not user");

    uint balance = gaugeBalance[gauge];
    require(balance >= amount, "Not enough balance");
    IGauge(gauge).withdraw(amount);
    if (balance == amount) {
      delete gaugeUser[gauge];
    } else {
      gaugeBalance[gauge] = balance - amount;
    }
    IERC20(pool).safeTransfer(msg.sender, amount);
  }

  function claim(address gauge, address[] memory gaugeTokens, address[] memory bribeTokens) external nonReentrant override {
    require(gaugeUser[gauge] == msg.sender, "Not user");

    IGauge(gauge).getReward(address(this), gaugeTokens);

    if (veId != 0) {
      IBribe(IGauge(gauge).bribe()).getReward(veId, bribeTokens);
    }

    for (uint i; i < gaugeTokens.length; i++) {
      uint balance = IERC20(gaugeTokens[i]).balanceOf(address(this));
      IERC20(gaugeTokens[i]).safeTransfer(msg.sender, balance);
    }
    if (veId != 0) {
      for (uint i; i < bribeTokens.length; i++) {
        uint balance = IERC20(bribeTokens[i]).balanceOf(address(this));
        IERC20(bribeTokens[i]).safeTransfer(msg.sender, balance);
      }
    }
  }

  // ************************************************
  //                INTERNAL
  // ************************************************

  function _approveIfNeeds(address token, uint amount, address spender) internal {
    if (IERC20(token).allowance(address(this), spender) < amount) {
      IERC20(token).safeApprove(spender, 0);
      IERC20(token).safeApprove(spender, type(uint).max);
    }
  }

}

// SPDX-License-Identifier: ISC
/**
* By using this software, you understand, acknowledge and accept that Tetu
* and/or the underlying software are provided “as is” and “as available”
* basis and without warranties or representations of any kind either expressed
* or implied. Any use of this open source software released under the ISC
* Internet Systems Consortium license is done at your own risk to the fullest
* extent permissible pursuant to applicable law any and all liability as well
* as all warranties, including any fitness for a particular purpose with respect
* to Tetu and/or the underlying software and the use thereof are disclaimed.
*/

pragma solidity 0.8.4;

import "../../openzeppelin/Initializable.sol";
import "../interface/IControllable.sol";
import "../interface/IControllableExtended.sol";
import "../interface/IController.sol";

/// @title Implement basic functionality for any contract that require strict control
///        V2 is optimised version for less gas consumption
/// @dev Can be used with upgradeable pattern.
///      Require call initializeControllable() in any case.
/// @author belbix
abstract contract ControllableV2 is Initializable, IControllable, IControllableExtended {

  bytes32 internal constant _CONTROLLER_SLOT = bytes32(uint256(keccak256("eip1967.controllable.controller")) - 1);
  bytes32 internal constant _CREATED_SLOT = bytes32(uint256(keccak256("eip1967.controllable.created")) - 1);
  bytes32 internal constant _CREATED_BLOCK_SLOT = bytes32(uint256(keccak256("eip1967.controllable.created_block")) - 1);

  event ContractInitialized(address controller, uint ts, uint block);

  /// @notice Initialize contract after setup it as proxy implementation
  ///         Save block.timestamp in the "created" variable
  /// @dev Use it only once after first logic setup
  /// @param __controller Controller address
  function initializeControllable(address __controller) public initializer {
    _setController(__controller);
    _setCreated(block.timestamp);
    _setCreatedBlock(block.number);
    emit ContractInitialized(__controller, block.timestamp, block.number);
  }

  /// @dev Return true if given address is controller
  function isController(address _value) external override view returns (bool) {
    return _isController(_value);
  }

  function _isController(address _value) internal view returns (bool) {
    return _value == _controller();
  }

  /// @notice Return true if given address is setup as governance in Controller
  function isGovernance(address _value) external override view returns (bool) {
    return _isGovernance(_value);
  }

  function _isGovernance(address _value) internal view returns (bool) {
    return IController(_controller()).governance() == _value;
  }

  // ************* SETTERS/GETTERS *******************

  /// @notice Return controller address saved in the contract slot
  function controller() external view override returns (address) {
    return _controller();
  }

  function _controller() internal view returns (address result) {
    bytes32 slot = _CONTROLLER_SLOT;
    assembly {
      result := sload(slot)
    }
  }

  /// @dev Set a controller address to contract slot
  function _setController(address _newController) private {
    require(_newController != address(0));
    bytes32 slot = _CONTROLLER_SLOT;
    assembly {
      sstore(slot, _newController)
    }
  }

  /// @notice Return creation timestamp
  /// @return ts Creation timestamp
  function created() external view override returns (uint256 ts) {
    bytes32 slot = _CREATED_SLOT;
    assembly {
      ts := sload(slot)
    }
  }

  /// @dev Filled only once when contract initialized
  /// @param _value block.timestamp
  function _setCreated(uint256 _value) private {
    bytes32 slot = _CREATED_SLOT;
    assembly {
      sstore(slot, _value)
    }
  }

  /// @notice Return creation block number
  /// @return ts Creation block number
  function createdBlock() external view returns (uint256 ts) {
    bytes32 slot = _CREATED_BLOCK_SLOT;
    assembly {
      ts := sload(slot)
    }
  }

  /// @dev Filled only once when contract initialized
  /// @param _value block.number
  function _setCreatedBlock(uint256 _value) private {
    bytes32 slot = _CREATED_BLOCK_SLOT;
    assembly {
      sstore(slot, _value)
    }
  }

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";
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
    uint256 value
  ) internal {
    _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
  }

  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 value
  ) internal {
    _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
  }

  /**
   * @dev Deprecated. This function has issues similar to the ones found in
   * {IERC20-approve}, and its usage is discouraged.
   *
   * Whenever possible, use {safeIncreaseAllowance} and
   * {safeDecreaseAllowance} instead.
   */
  function safeApprove(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {
    // safeApprove should only be called when setting an initial allowance,
    // or when resetting it to zero. To increase and decrease it, use
    // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
    require(
      (value == 0) || (token.allowance(address(this), spender) == 0),
      "SafeERC20: approve from non-zero to non-zero allowance"
    );
    _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
  }

  function safeIncreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {
    uint256 newAllowance = token.allowance(address(this), spender) + value;
    _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
  }

  function safeDecreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {
  unchecked {
    uint256 oldAllowance = token.allowance(address(this), spender);
    require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
    uint256 newAllowance = oldAllowance - value;
    _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
  }
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
   * by making the `nonReentrant` function external, and make it call a
   * `private` function that does the actual work.
   */
  modifier nonReentrant() {
    // On the first call to nonReentrant, _notEntered will be true
    require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

    // Any calls to nonReentrant after this point will fail
    _status = _ENTERED;

    _;

    // By storing the original value once again, a refund is triggered (see
    // https://eips.ethereum.org/EIPS/eip-2200)
    _status = _NOT_ENTERED;
  }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

interface IRouter {
    struct Route {
        address from;
        address to;
        bool stable;
    }

    function factory() external view returns (address);

    function WMATIC() external view returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        bool stable,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    
    function addLiquidityMATIC(
        address token,
        bool stable,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountMATICMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountMATIC, uint liquidity);
    
    function removeLiquidity(
        address tokenA,
        address tokenB,
        bool stable,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityMATIC(
        address token,
        bool stable,
        uint liquidity,
        uint amountTokenMin,
        uint amountMATICMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountMATIC);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        bool stable,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityMATICWithPermit(
        address token,
        bool stable,
        uint liquidity,
        uint amountTokenMin,
        uint amountMATICMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountMATIC);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        Route[] calldata routes,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        Route[] calldata routes,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactMATICForTokens(
        uint amountOutMin,
        Route[] calldata routes,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function swapTokensForExactMATIC(
        uint amountOut,
        uint amountInMax,
        Route[] calldata routes,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactTokensForMATIC(
        uint amountIn,
        uint amountOutMin,
        Route[] calldata routes,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapMATICForExactTokens(
        uint amountOut,
        Route[] calldata routes,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function quoteRemoveLiquidity(
        address tokenA,
        address tokenB,
        bool stable,
        uint liquidity
    ) external view returns (uint amountA, uint amountB);

    function quoteAddLiquidity(
        address tokenA,
        address tokenB,
        bool stable,
        uint amountADesired,
        uint amountBDesired
    )
        external
        view
        returns (
            uint amountA,
            uint amountB,
            uint liquidity
        );

    function pairFor(
        address tokenA,
        address tokenB,
        bool stable
    ) external view returns (address pair);

    function sortTokens(address tokenA, address tokenB)
        external
        pure
        returns (address token0, address token1);

    function quoteLiquidity(
        uint amountA,
        uint reserveA,
        uint reserveB
    ) external pure returns (uint amountB);

    function getAmountOut(
        uint amountIn,
        address tokenIn,
        address tokenOut
    ) external view returns (uint amount, bool stable);

    function getAmountIn(
        uint amountOut,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountIn, bool stable);

    function getAmountsOut(uint amountIn, Route[] memory routes)
        external
        view
        returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, Route[] memory routes)
        external
        view
        returns (uint[] memory amounts);

    function getReserves(
        address tokenA,
        address tokenB,
        bool stable
    ) external view returns (uint reserveA, uint reserveB);

    function getExactAmountOut(
        uint amountIn,
        address tokenIn,
        address tokenOut,
        bool stable
    ) external view returns (uint amount);

    function isPair(address pair) external view returns (bool);

    function swapExactTokensForTokensSimple(
        uint amountIn,
        uint amountOutMin,
        address tokenFrom,
        address tokenTo,
        bool stable,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactTokensForMATICSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        Route[] calldata routes,
        address to,
        uint deadline
    ) external;

    function swapExactMATICForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        Route[] calldata routes,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        Route[] calldata routes,
        address to,
        uint deadline
    ) external;

    function removeLiquidityMATICWithPermitSupportingFeeOnTransferTokens(
        address token,
        bool stable,
        uint liquidity,
        uint amountTokenMin,
        uint amountFTMMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountToken, uint amountFTM);

    function removeLiquidityMATICSupportingFeeOnTransferTokens(
        address token,
        bool stable,
        uint liquidity,
        uint amountTokenMin,
        uint amountFTMMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountFTM);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

interface IGauge {

  function notifyRewardAmount(address token, uint amount) external;

  function getReward(address account, address[] memory tokens) external;

  function claimFees() external returns (uint claimed0, uint claimed1);

  function deposit(uint amount, uint tokenId) external;

  function withdraw(uint amount) external;

  function bribe() external view returns (address);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

interface IBribe {

  function notifyRewardAmount(address token, uint amount) external;

  function _deposit(uint amount, uint tokenId) external;

  function _withdraw(uint amount, uint tokenId) external;

  function getReward(uint tokenId, address[] memory tokens) external;

  function getRewardForOwner(uint tokenId, address[] memory tokens) external;

}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

interface IVe {

  enum DepositType {
    DEPOSIT_FOR_TYPE,
    CREATE_LOCK_TYPE,
    INCREASE_LOCK_AMOUNT,
    INCREASE_UNLOCK_TIME,
    MERGE_TYPE
  }

  struct Point {
    int128 bias;
    int128 slope; // # -dweight / dt
    uint ts;
    uint blk; // block
  }
  /* We cannot really do block numbers per se b/c slope is per time, not per block
  * and per block could be fairly bad b/c Ethereum changes blocktimes.
  * What we can do is to extrapolate ***At functions */

  struct LockedBalance {
    int128 amount;
    uint end;
  }

  function token() external view returns (address);

  function balanceOfNFT(uint) external view returns (uint);

  function isApprovedOrOwner(address, uint) external view returns (bool);

  function merge(uint _from, uint _to) external;

  function createLockFor(uint, uint, address) external returns (uint);

  function createLock(uint _value, uint _lockDuration) external returns (uint);

  function increaseUnlockTime(uint _tokenId, uint _lockDuration) external;

  function increaseAmount(uint _tokenId, uint _value) external;

  function userPointEpoch(uint tokenId) external view returns (uint);

  function epoch() external view returns (uint);

  function userPointHistory(uint tokenId, uint loc) external view returns (Point memory);

  function pointHistory(uint loc) external view returns (Point memory);

  function checkpoint() external;

  function depositFor(uint tokenId, uint value) external;

  function attachToken(uint tokenId) external;

  function detachToken(uint tokenId) external;

  function voting(uint tokenId) external;

  function abstain(uint tokenId) external;

  function lockedEnd(uint _tokenId) external view returns (uint);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

interface IVoter {

  function ve() external view returns (address);

  function attachTokenToGauge(uint _tokenId, address account) external;

  function detachTokenFromGauge(uint _tokenId, address account) external;

  function emitDeposit(uint _tokenId, address account, uint amount) external;

  function emitWithdraw(uint _tokenId, address account, uint amount) external;

  function distribute(address _gauge) external;

  function notifyRewardAmount(uint amount) external;

  function vote(uint tokenId, address[] calldata _poolVote, int256[] calldata _weights) external;

}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

interface IVeDist {

  function checkpointToken() external;

  function checkpointTotalSupply() external;

  function claim(uint _tokenId) external returns (uint);

}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

interface IConeStacker {

  function gaugeBalance(address gauge) external view returns (uint);

  function gaugeUser(address gauge) external view returns (address);

  function userBalance(address gauge, address user) external view returns (uint);

  function lock(uint amount, bool isClaim) external;

  function increaseUnlockTime() external;

  function depositToGauge(address pool, address gauge, uint amount) external;

  function withdrawFromGauge(address pool, address gauge, uint amount) external;

  function claim(address gauge, address[] memory gaugeTokens, address[] memory bribeTokens) external;

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private _initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private _initializing;

  /**
   * @dev Modifier to protect an initializer function from being invoked twice.
   */
  modifier initializer() {
    require(_initializing || !_initialized, "Initializable: contract is already initialized");

    bool isTopLevelCall = !_initializing;
    if (isTopLevelCall) {
      _initializing = true;
      _initialized = true;
    }

    _;

    if (isTopLevelCall) {
      _initializing = false;
    }
  }
}

// SPDX-License-Identifier: ISC
/**
* By using this software, you understand, acknowledge and accept that Tetu
* and/or the underlying software are provided “as is” and “as available”
* basis and without warranties or representations of any kind either expressed
* or implied. Any use of this open source software released under the ISC
* Internet Systems Consortium license is done at your own risk to the fullest
* extent permissible pursuant to applicable law any and all liability as well
* as all warranties, including any fitness for a particular purpose with respect
* to Tetu and/or the underlying software and the use thereof are disclaimed.
*/

pragma solidity 0.8.4;

interface IControllable {

  function isController(address _contract) external view returns (bool);

  function isGovernance(address _contract) external view returns (bool);

}

// SPDX-License-Identifier: ISC
/**
* By using this software, you understand, acknowledge and accept that Tetu
* and/or the underlying software are provided “as is” and “as available”
* basis and without warranties or representations of any kind either expressed
* or implied. Any use of this open source software released under the ISC
* Internet Systems Consortium license is done at your own risk to the fullest
* extent permissible pursuant to applicable law any and all liability as well
* as all warranties, including any fitness for a particular purpose with respect
* to Tetu and/or the underlying software and the use thereof are disclaimed.
*/

pragma solidity 0.8.4;

/// @dev This interface contains additional functions for Controllable class
///      Don't extend the exist Controllable for the reason of huge coherence
interface IControllableExtended {

  function created() external view returns (uint256 ts);

  function controller() external view returns (address adr);

}

// SPDX-License-Identifier: ISC
/**
* By using this software, you understand, acknowledge and accept that Tetu
* and/or the underlying software are provided “as is” and “as available”
* basis and without warranties or representations of any kind either expressed
* or implied. Any use of this open source software released under the ISC
* Internet Systems Consortium license is done at your own risk to the fullest
* extent permissible pursuant to applicable law any and all liability as well
* as all warranties, including any fitness for a particular purpose with respect
* to Tetu and/or the underlying software and the use thereof are disclaimed.
*/

pragma solidity 0.8.4;

interface IController {


  function VERSION() external view returns (string memory);

  function addHardWorker(address _worker) external;

  function addStrategiesToSplitter(
    address _splitter,
    address[] memory _strategies
  ) external;

  function addStrategy(address _strategy) external;

  function addVaultsAndStrategies(
    address[] memory _vaults,
    address[] memory _strategies
  ) external;

  function announcer() external view returns (address);

  function bookkeeper() external view returns (address);

  function changeWhiteListStatus(address[] memory _targets, bool status)
  external;

  function controllerTokenMove(
    address _recipient,
    address _token,
    uint256 _amount
  ) external;

  function dao() external view returns (address);

  function distributor() external view returns (address);

  function doHardWork(address _vault) external;

  function feeRewardForwarder() external view returns (address);

  function fund() external view returns (address);

  function fundDenominator() external view returns (uint256);

  function fundKeeperTokenMove(
    address _fund,
    address _token,
    uint256 _amount
  ) external;

  function fundNumerator() external view returns (uint256);

  function fundToken() external view returns (address);

  function governance() external view returns (address);

  function hardWorkers(address) external view returns (bool);

  function initialize() external;

  function isAllowedUser(address _adr) external view returns (bool);

  function isDao(address _adr) external view returns (bool);

  function isHardWorker(address _adr) external view returns (bool);

  function isPoorRewardConsumer(address _adr) external view returns (bool);

  function isRewardDistributor(address _adr) external view returns (bool);

  function isValidStrategy(address _strategy) external view returns (bool);

  function isValidVault(address _vault) external view returns (bool);

  function mintAndDistribute(uint256 totalAmount, bool mintAllAvailable)
  external;

  function mintHelper() external view returns (address);

  function psDenominator() external view returns (uint256);

  function psNumerator() external view returns (uint256);

  function psVault() external view returns (address);

  function pureRewardConsumers(address) external view returns (bool);

  function rebalance(address _strategy) external;

  function removeHardWorker(address _worker) external;

  function rewardDistribution(address) external view returns (bool);

  function rewardToken() external view returns (address);

  function setAnnouncer(address _newValue) external;

  function setBookkeeper(address newValue) external;

  function setDao(address newValue) external;

  function setDistributor(address _distributor) external;

  function setFeeRewardForwarder(address _feeRewardForwarder) external;

  function setFund(address _newValue) external;

  function setFundNumeratorDenominator(uint256 numerator, uint256 denominator)
  external;

  function setFundToken(address _newValue) external;

  function setGovernance(address newValue) external;

  function setMintHelper(address _newValue) external;

  function setPSNumeratorDenominator(uint256 numerator, uint256 denominator)
  external;

  function setPsVault(address _newValue) external;

  function setPureRewardConsumers(address[] memory _targets, bool _flag)
  external;

  function setRewardDistribution(
    address[] memory _newRewardDistribution,
    bool _flag
  ) external;

  function setRewardToken(address _newValue) external;

  function setVaultController(address _newValue) external;

  function setVaultStrategyBatch(
    address[] memory _vaults,
    address[] memory _strategies
  ) external;

  function strategies(address) external view returns (bool);

  function strategyTokenMove(
    address _strategy,
    address _token,
    uint256 _amount
  ) external;

  function upgradeTetuProxyBatch(
    address[] memory _contracts,
    address[] memory _implementations
  ) external;

  function vaultController() external view returns (address);

  function vaults(address) external view returns (bool);

  function whiteList(address) external view returns (bool);
}

// SPDX-License-Identifier: MIT

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

pragma solidity ^0.8.0;

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
    // This method relies on extcodesize, which returns 0 for contracts in
    // construction, since the code is only stored at the end of the
    // constructor execution.

    uint256 size;
    assembly {
      size := extcodesize(account)
    }
    return size > 0;
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
   */
  function sendValue(address payable recipient, uint256 amount) internal {
    require(address(this).balance >= amount, "Address: insufficient balance");

    (bool success, ) = recipient.call{value: amount}("");
    require(success, "Address: unable to send value, recipient may have reverted");
  }

  /**
   * @dev Performs a Solidity function call using a low level `call`. A
   * plain `call` is an unsafe replacement for a function call: use this
   * function instead.
   *
   * If `target` reverts with a revert reason, it is bubbled up by this
   * function (like regular Solidity function calls).
   *
   * Returns the raw returned data. To convert to the expected return value,
   * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
   *
   * Requirements:
   *
   * - `target` must be a contract.
   * - calling `target` with `data` must not revert.
   *
   * _Available since v3.1._
   */
  function functionCall(address target, bytes memory data) internal returns (bytes memory) {
    return functionCall(target, data, "Address: low-level call failed");
  }

  /**
   * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
   * `errorMessage` as a fallback revert reason when `target` reverts.
   *
   * _Available since v3.1._
   */
  function functionCall(
    address target,
    bytes memory data,
    string memory errorMessage
  ) internal returns (bytes memory) {
    return functionCallWithValue(target, data, 0, errorMessage);
  }

  /**
   * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
   * but also transferring `value` wei to `target`.
   *
   * Requirements:
   *
   * - the calling contract must have an ETH balance of at least `value`.
   * - the called Solidity function must be `payable`.
   *
   * _Available since v3.1._
   */
  function functionCallWithValue(
    address target,
    bytes memory data,
    uint256 value
  ) internal returns (bytes memory) {
    return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
  }

  /**
   * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
   * with `errorMessage` as a fallback revert reason when `target` reverts.
   *
   * _Available since v3.1._
   */
  function functionCallWithValue(
    address target,
    bytes memory data,
    uint256 value,
    string memory errorMessage
  ) internal returns (bytes memory) {
    require(address(this).balance >= value, "Address: insufficient balance for call");
    require(isContract(target), "Address: call to non-contract");

    (bool success, bytes memory returndata) = target.call{value: value}(data);
    return verifyCallResult(success, returndata, errorMessage);
  }

  /**
   * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
   * but performing a static call.
   *
   * _Available since v3.3._
   */
  function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
    return functionStaticCall(target, data, "Address: low-level static call failed");
  }

  /**
   * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
   * but performing a static call.
   *
   * _Available since v3.3._
   */
  function functionStaticCall(
    address target,
    bytes memory data,
    string memory errorMessage
  ) internal view returns (bytes memory) {
    require(isContract(target), "Address: static call to non-contract");

    (bool success, bytes memory returndata) = target.staticcall(data);
    return verifyCallResult(success, returndata, errorMessage);
  }

  /**
   * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
   * but performing a delegate call.
   *
   * _Available since v3.4._
   */
  function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
    return functionDelegateCall(target, data, "Address: low-level delegate call failed");
  }

  /**
   * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
   * but performing a delegate call.
   *
   * _Available since v3.4._
   */
  function functionDelegateCall(
    address target,
    bytes memory data,
    string memory errorMessage
  ) internal returns (bytes memory) {
    require(isContract(target), "Address: delegate call to non-contract");

    (bool success, bytes memory returndata) = target.delegatecall(data);
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