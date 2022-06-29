// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.6;

interface IMasterChef {
  struct UserInfo {
    uint256 amount;
    uint256 rewardDebt;
  }

  struct PoolInfo {
    address lpToken;
    uint256 allocPoint;
    uint256 lastRewardBlock;
    uint256 accCakePerShare;
  }

  function cake() external view returns (address);

  function poolInfo(uint256 pool) external view returns (PoolInfo memory);

  function userInfo(uint256 pool, address user) external view returns (UserInfo memory);

  function pendingCake(uint256 pool, address user) external view returns (uint256);

  function deposit(uint256 pool, uint256 amount) external;

  function withdraw(uint256 pool, uint256 amount) external;

  function emergencyWithdraw(uint256 pool) external;
}

// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./utils/DFH/Automate.sol";
import "./utils/DFH/IStorage.sol";
import "./utils/Uniswap/IUniswapV2Router02.sol";
import {ERC20Tools} from "./utils/ERC20Tools.sol";
import "./IMasterChef.sol";

/**
 * @notice Use with simple token only.
 */
contract MasterChefSingleRestake is Automate {
  using ERC20Tools for IERC20;

  struct Swap {
    address[] path;
    uint256 outMin;
  }

  IMasterChef public staking;

  address public liquidityRouter;

  uint256 public pool;

  uint16 public slippage;

  uint16 public deadline;

  IERC20 public stakingToken;

  IERC20 public rewardToken;

  // solhint-disable-next-line no-empty-blocks
  constructor(address _info) Automate(_info) {}

  function init(
    address _staking,
    address _liquidityRouter,
    uint256 _pool,
    uint16 _slippage,
    uint16 _deadline
  ) external initializer {
    require(
      !_initialized || address(staking) == _staking,
      "MasterChefSingleRestake::init: reinitialize staking address forbidden"
    );
    staking = IMasterChef(_staking);
    require(
      !_initialized || liquidityRouter == _liquidityRouter,
      "MasterChefSingleRestake::init: reinitialize liquidity router address forbidden"
    );
    liquidityRouter = _liquidityRouter;
    require(!_initialized || pool == _pool, "MasterChefSingleRestake::init: reinitialize pool index forbidden");
    pool = _pool;
    slippage = _slippage;
    deadline = _deadline;

    if (!_initialized) {
      IMasterChef.PoolInfo memory poolInfo = staking.poolInfo(pool);
      stakingToken = IERC20(poolInfo.lpToken);
      rewardToken = IERC20(staking.cake());
    }
  }

  function deposit() external onlyOwner {
    IERC20 _stakingToken = stakingToken; // gas optimisation
    uint256 balance = _stakingToken.balanceOf(address(this));
    _stakingToken.safeApprove(address(staking), balance);
    staking.deposit(pool, balance);
  }

  function refund() external onlyOwner {
    IMasterChef _staking = staking; // gas optimisation
    address __owner = owner(); // gas optimisation
    IMasterChef.UserInfo memory userInfo = _staking.userInfo(pool, address(this));
    _staking.withdraw(pool, userInfo.amount);
    stakingToken.transfer(__owner, stakingToken.balanceOf(address(this)));
    rewardToken.transfer(__owner, rewardToken.balanceOf(address(this)));
  }

  function emergencyWithdraw() external onlyOwner {
    address __owner = owner(); // gas optimisation
    staking.emergencyWithdraw(pool);
    stakingToken.transfer(__owner, stakingToken.balanceOf(address(this)));
    rewardToken.transfer(__owner, rewardToken.balanceOf(address(this)));
  }

  function _swap(
    address[] memory path,
    uint256[2] memory amount,
    uint256 _deadline
  ) internal {
    if (path[0] == path[path.length - 1]) return;

    IUniswapV2Router02(liquidityRouter).swapExactTokensForTokens(amount[0], amount[1], path, address(this), _deadline);
  }

  function run(
    uint256 gasFee,
    uint256 _deadline,
    Swap memory swap
  ) external bill(gasFee, "PancakeSwapMasterChefSingleRestake") {
    IMasterChef _staking = staking; // gas optimization
    IERC20 _stakingToken = stakingToken;
    require(_staking.pendingCake(pool, address(this)) > 0, "MasterChefSingleRestake::run: no earned");

    _staking.deposit(pool, 0); // get all reward
    uint256 rewardAmount = rewardToken.balanceOf(address(this));
    rewardToken.safeApprove(liquidityRouter, rewardAmount);
    _swap(swap.path, [rewardAmount, swap.outMin], _deadline);

    uint256 stakingAmount = _stakingToken.balanceOf(address(this));
    _stakingToken.safeApprove(address(_staking), stakingAmount);
    _staking.deposit(pool, stakingAmount);
  }
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

// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.6;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./proxy/ERC1167.sol";
import "./IStorage.sol";
import "./IBalance.sol";

// solhint-disable avoid-tx-origin
abstract contract Automate {
  using ERC1167 for address;

  /// @notice Storage contract address.
  address internal _info;

  /// @notice Contract owner.
  address internal _owner;

  /// @notice Is contract paused.
  bool internal _paused;

  /// @notice Protocol fee in USD (-1 if value in global storage).
  int256 internal _protocolFee;

  /// @notice Is contract already initialized.
  bool internal _initialized;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  event ProtocolFeeChanged(int256 protocolFee);

  constructor(address __info) {
    _info = __info;
    _owner = tx.origin;
    _protocolFee = -1;
  }

  /**
   * @notice Returns address of Storage contract.
   */
  function info() public view returns (address) {
    address impl = address(this).implementation();
    if (impl == address(this)) return _info;

    return Automate(impl).info();
  }

  /// @dev Modifier to protect an initializer function from being invoked twice.
  modifier initializer() {
    if (_owner == address(0)) {
      _owner = tx.origin;
      _protocolFee = -1;
    } else {
      require(_owner == msg.sender, "Automate: caller is not the owner");
    }
    _;
    _initialized = true;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(_owner == msg.sender, "Automate: caller is not the owner");
    _;
  }

  /**
   * @notice Returns the address of the current owner.
   */
  function owner() public view returns (address) {
    return _owner;
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) external onlyOwner {
    require(address(this).implementation() == address(this), "Automate: change the owner failed");

    address oldOwner = _owner;
    _owner = newOwner;
    emit OwnershipTransferred(oldOwner, newOwner);
  }

  /**
   * @dev Throws if called by any account other than the pauser.
   */
  modifier onlyPauser() {
    if (address(this).implementation() == address(this)) {
      address pauser = IStorage(info()).getAddress(keccak256("DFH:Pauser"));
      require(msg.sender == _owner || msg.sender == pauser, "Automate: caller is not the pauser");
    } else {
      require(msg.sender == _owner, "Automate: caller is not the pauser");
    }
    _;
  }

  /**
   * @notice Returns true if the contract is paused, and false otherwise.
   */
  function paused() public view returns (bool) {
    address impl = address(this).implementation();
    if (impl == address(this)) return _paused;

    return _paused || Automate(impl).paused();
  }

  /**
   * @dev Throws if contract unpaused.
   */
  modifier whenPaused() {
    require(paused(), "Automate: not paused");
    _;
  }

  /**
   * @dev Throws if contract paused.
   */
  modifier whenNotPaused() {
    require(!paused(), "Automate: paused");
    _;
  }

  /**
   * @notice Pause contract.
   */
  function pause() external onlyPauser whenNotPaused {
    _paused = true;
  }

  /**
   * @notice Unpause contract.
   */
  function unpause() external onlyPauser whenPaused {
    _paused = false;
  }

  /**
   * @return Current protocol fee.
   */
  function protocolFee() public view returns (uint256) {
    address impl = address(this).implementation();
    if (impl != address(this) && _protocolFee < 0) {
      return Automate(impl).protocolFee();
    }

    IStorage __info = IStorage(info());
    uint256 feeOnUSD = _protocolFee < 0 ? __info.getUint(keccak256("DFH:Fee:Automate")) : uint256(_protocolFee);
    if (feeOnUSD == 0) return 0;

    (, int256 price, , , ) = AggregatorV3Interface(__info.getAddress(keccak256("DFH:Fee:PriceFeed"))).latestRoundData();
    require(price > 0, "Automate: invalid price");

    return (feeOnUSD * 1e18) / uint256(price);
  }

  /**
   * @notice Change protocol fee.
   * @param __protocolFee New protocol fee.
   */
  function changeProtocolFee(int256 __protocolFee) external {
    address impl = address(this).implementation();
    require(
      (impl == address(this) ? _owner : Automate(impl).owner()) == msg.sender,
      "Automate::changeProtocolFee: caller is not the protocol owner"
    );

    _protocolFee = __protocolFee;
    emit ProtocolFeeChanged(__protocolFee);
  }

  /**
   * @dev Claim fees from owner.
   * @param gasFee Claim gas fee.
   * @param operation Claim description.
   */
  function _bill(uint256 gasFee, string memory operation) internal whenNotPaused returns (uint256) {
    address account = owner(); // gas optimisation
    if (tx.origin == account) return 0; // free if called by the owner

    IStorage __info = IStorage(info());

    address balance = __info.getAddress(keccak256("DFH:Contract:Balance"));
    require(balance != address(0), "Automate::_bill: balance contract not found");

    return IBalance(balance).claim(account, gasFee, protocolFee(), operation);
  }

  /**
   * @dev Claim fees from owner.
   * @param gasFee Claim gas fee.
   * @param operation Claim description.
   */
  modifier bill(uint256 gasFee, string memory operation) {
    _bill(gasFee, operation);
    _;
  }

  /**
   * @notice Transfer ERC20 token to recipient.
   * @param token The address of the token to be transferred.
   * @param recipient Token recipient address.
   * @param amount Transferred amount of tokens.
   */
  function transfer(
    address token,
    address recipient,
    uint256 amount
  ) external onlyOwner {
    IERC20(token).transfer(recipient, amount);
  }
}

// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.6;

interface IStorage {
  function getBytes(bytes32 key) external view returns (bytes memory);

  function getBool(bytes32 key) external view returns (bool);

  function getUint(bytes32 key) external view returns (uint256);

  function getInt(bytes32 key) external view returns (int256);

  function getAddress(bytes32 key) external view returns (address);

  function getString(bytes32 key) external view returns (string memory);
}

// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.6;

// solhint-disable func-name-mixedcase
interface IUniswapV2Router02 {
  function factory() external view returns (address);

  function WETH() external view returns (address);

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

// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

library ERC20Tools {
  function safeApprove(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {
    uint256 allowance = token.allowance(address(this), spender);
    if (allowance != 0 && allowance < value) {
      token.approve(spender, 0);
    }
    if (allowance != value) {
      token.approve(spender, value);
    }
  }

  function safeApproveAll(IERC20 token, address spender) internal {
    safeApprove(token, spender, 2**256 - 1);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {

  function decimals()
    external
    view
    returns (
      uint8
    );

  function description()
    external
    view
    returns (
      string memory
    );

  function version()
    external
    view
    returns (
      uint256
    );

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(
    uint80 _roundId
  )
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

// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.6;

// solhint-disable no-inline-assembly
library ERC1167 {
  bytes public constant CLONE =
    hex"363d3d373d3d3d363d73bebebebebebebebebebebebebebebebebebebebe5af43d82803e903d91602b57fd5bf3";

  /**
   * @notice Make new proxy contract.
   * @param impl Address prototype contract.
   * @return proxy Address new proxy contract.
   */
  function clone(address impl) external returns (address proxy) {
    assembly {
      let ptr := mload(0x40)
      mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
      mstore(add(ptr, 0x14), shl(0x60, impl))
      mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
      proxy := create(0, ptr, 0x37)
    }
    require(proxy != address(0), "ERC1167: create failed");
  }

  /**
   * @notice Returns address of prototype contract for proxy.
   * @param proxy Address proxy contract.
   * @return impl Address prototype contract (current contract address if not proxy).
   */
  function implementation(address proxy) external view returns (address impl) {
    uint256 size;
    assembly {
      size := extcodesize(proxy)
    }

    impl = proxy;
    if (size <= 45 && size >= 41) {
      bool matches = true;
      uint256 i;

      bytes memory code;
      assembly {
        code := mload(0x40)
        mstore(0x40, add(code, and(add(add(size, 0x20), 0x1f), not(0x1f))))
        mstore(code, size)
        extcodecopy(proxy, add(code, 0x20), 0, size)
      }
      for (i = 0; matches && i < 9; i++) {
        matches = code[i] == CLONE[i];
      }
      for (i = 0; matches && i < 15; i++) {
        if (i == 4) {
          matches = code[code.length - i - 1] == bytes1(uint8(CLONE[45 - i - 1]) - uint8(45 - size));
        } else {
          matches = code[code.length - i - 1] == CLONE[45 - i - 1];
        }
      }
      if (code[9] != bytes1(0x73 - uint8(45 - size))) {
        matches = false;
      }
      uint256 forwardedToBuffer;
      if (matches) {
        assembly {
          forwardedToBuffer := mload(add(code, 30))
        }
        forwardedToBuffer &= (0x1 << (20 * 8)) - 1;
        impl = address(uint160(forwardedToBuffer >> ((45 - size) * 8)));
      }
    }
  }
}

// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.6;

interface IBalance {
  function claim(
    address account,
    uint256 gasFee,
    uint256 protocolFee,
    string memory description
  ) external returns (uint256);
}

// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./utils/DFH/Automate.sol";
import "./utils/DFH/IStorage.sol";
import "./utils/Uniswap/IUniswapV2Router02.sol";
import {ERC20Tools} from "./utils/ERC20Tools.sol";
import "./ISmartChefInitializable.sol";

/**
 * @notice Use with simple token only.
 */
contract SmartChefInitializableRestake is Automate {
  using ERC20Tools for IERC20;

  struct Swap {
    address[] path;
    uint256 outMin;
  }

  ISmartChefInitializable public staking;

  address public liquidityRouter;

  uint16 public slippage;

  uint16 public deadline;

  IERC20 public stakingToken;

  IERC20 public rewardToken;

  // solhint-disable-next-line no-empty-blocks
  constructor(address _info) Automate(_info) {}

  function init(
    address _staking,
    address _liquidityRouter,
    uint16 _slippage,
    uint16 _deadline
  ) external initializer {
    require(
      !_initialized || address(staking) == _staking,
      "SmartChefInitializableRestake::init: reinitialize staking address forbidden"
    );
    staking = ISmartChefInitializable(_staking);
    require(
      !_initialized || liquidityRouter == _liquidityRouter,
      "SmartChefInitializableRestake::init: reinitialize liquidity router address forbidden"
    );
    liquidityRouter = _liquidityRouter;
    slippage = _slippage;
    deadline = _deadline;

    if (!_initialized) {
      stakingToken = IERC20(staking.stakedToken());
      rewardToken = IERC20(staking.rewardToken());
    }
  }

  function deposit() external onlyOwner {
    IERC20 _stakingToken = stakingToken; // gas optimisation
    uint256 balance = _stakingToken.balanceOf(address(this));
    _stakingToken.safeApprove(address(staking), balance);
    staking.deposit(balance);
  }

  function refund() external onlyOwner {
    ISmartChefInitializable _staking = staking; // gas optimisation
    address __owner = owner(); // gas optimisation
    ISmartChefInitializable.UserInfo memory userInfo = _staking.userInfo(address(this));
    _staking.withdraw(userInfo.amount);
    stakingToken.transfer(__owner, stakingToken.balanceOf(address(this)));
    rewardToken.transfer(__owner, rewardToken.balanceOf(address(this)));
  }

  function emergencyWithdraw() external onlyOwner {
    address __owner = owner(); // gas optimisation
    staking.emergencyWithdraw();
    stakingToken.transfer(__owner, stakingToken.balanceOf(address(this)));
    rewardToken.transfer(__owner, rewardToken.balanceOf(address(this)));
  }

  function _swap(
    address[] memory path,
    uint256[2] memory amount,
    uint256 _deadline
  ) internal {
    if (path[0] == path[path.length - 1]) return;

    IUniswapV2Router02(liquidityRouter).swapExactTokensForTokens(amount[0], amount[1], path, address(this), _deadline);
  }

  function run(
    uint256 gasFee,
    uint256 _deadline,
    Swap memory swap
  ) external bill(gasFee, "PancakeSwapSmartChefInitializable") {
    ISmartChefInitializable _staking = staking; // gas optimization
    IERC20 _stakingToken = stakingToken;
    require(_staking.pendingReward(address(this)) > 0, "SmartChefInitializableRestake::run: no earned");

    _staking.deposit(0); // get all reward
    uint256 rewardAmount = rewardToken.balanceOf(address(this));
    rewardToken.safeApprove(liquidityRouter, rewardAmount);
    _swap(swap.path, [rewardAmount, swap.outMin], _deadline);

    uint256 stakingAmount = _stakingToken.balanceOf(address(this));
    _stakingToken.safeApprove(address(_staking), stakingAmount);
    _staking.deposit(stakingAmount);
  }
}

// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.6;

interface ISmartChefInitializable {
  struct UserInfo {
    uint256 amount;
    uint256 rewardDebt;
  }

  function rewardToken() external view returns (address);

  function stakedToken() external view returns (address);

  function userInfo(address user) external view returns (UserInfo memory);

  function pendingReward(address user) external view returns (uint256);

  function deposit(uint256 amount) external;

  function withdraw(uint256 amount) external;

  function emergencyWithdraw() external;
}

// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./utils/DFH/Automate.sol";
import "./utils/DFH/IStorage.sol";
import "./utils/Uniswap/IUniswapV2Router02.sol";
import "./utils/Uniswap/IUniswapV2Pair.sol";
import {ERC20Tools} from "./utils/ERC20Tools.sol";
import "./IMasterChef.sol";

/**
 * @notice Use with LP token only.
 */
contract MasterChefLpRestake is Automate {
  using ERC20Tools for IERC20;

  struct Swap {
    address[] path;
    uint256 outMin;
  }

  IMasterChef public staking;

  address public liquidityRouter;

  uint256 public pool;

  uint16 public slippage;

  uint16 public deadline;

  IERC20 public stakingToken;

  IERC20 public rewardToken;

  // solhint-disable-next-line no-empty-blocks
  constructor(address _info) Automate(_info) {}

  function init(
    address _staking,
    address _liquidityRouter,
    uint256 _pool,
    uint16 _slippage,
    uint16 _deadline
  ) external initializer {
    require(
      !_initialized || address(staking) == _staking,
      "MasterChefLpRestake::init: reinitialize staking address forbidden"
    );
    staking = IMasterChef(_staking);
    require(
      !_initialized || liquidityRouter == _liquidityRouter,
      "MasterChefLpRestake::init: reinitialize liquidity router address forbidden"
    );
    liquidityRouter = _liquidityRouter;
    require(!_initialized || pool == _pool, "MasterChefLpRestake::init: reinitialize pool index forbidden");
    pool = _pool;
    slippage = _slippage;
    deadline = _deadline;

    if (!_initialized) {
      IMasterChef.PoolInfo memory poolInfo = staking.poolInfo(pool);
      stakingToken = IERC20(poolInfo.lpToken);
      rewardToken = IERC20(staking.cake());
    }
  }

  function deposit() external onlyOwner {
    IERC20 _stakingToken = stakingToken; // gas optimisation
    uint256 balance = _stakingToken.balanceOf(address(this));
    _stakingToken.safeApprove(address(staking), balance);
    staking.deposit(pool, balance);
  }

  function refund() external onlyOwner {
    IMasterChef _staking = staking; // gas optimisation
    address __owner = owner(); // gas optimisation
    IMasterChef.UserInfo memory userInfo = _staking.userInfo(pool, address(this));
    _staking.withdraw(pool, userInfo.amount);
    stakingToken.transfer(__owner, stakingToken.balanceOf(address(this)));
    rewardToken.transfer(__owner, rewardToken.balanceOf(address(this)));
  }

  function emergencyWithdraw() external onlyOwner {
    address __owner = owner(); // gas optimisation
    staking.emergencyWithdraw(pool);
    stakingToken.transfer(__owner, stakingToken.balanceOf(address(this)));
    rewardToken.transfer(__owner, rewardToken.balanceOf(address(this)));
  }

  function _swap(
    address[] memory path,
    uint256[2] memory amount,
    uint256 _deadline
  ) internal {
    if (path[0] == path[path.length - 1]) return;

    IUniswapV2Router02(liquidityRouter).swapExactTokensForTokens(amount[0], amount[1], path, address(this), _deadline);
  }

  function _addLiquidity(
    address token0,
    address token1,
    uint256 _deadline
  ) internal {
    address _liquidityRouter = liquidityRouter; // gas optimisation
    uint256 amountIn0 = IERC20(token0).balanceOf(address(this));
    uint256 amountIn1 = IERC20(token1).balanceOf(address(this));
    IERC20(token0).safeApprove(_liquidityRouter, amountIn0);
    IERC20(token1).safeApprove(_liquidityRouter, amountIn1);
    IUniswapV2Router02(_liquidityRouter).addLiquidity(
      token0,
      token1,
      amountIn0,
      amountIn1,
      0,
      0,
      address(this),
      _deadline
    );
  }

  function run(
    uint256 gasFee,
    uint256 _deadline,
    Swap memory swap0,
    Swap memory swap1
  ) external bill(gasFee, "PancakeSwapMasterChefLpRestake") {
    IMasterChef _staking = staking; // gas optimization
    require(_staking.pendingCake(pool, address(this)) > 0, "MasterChefLpRestake::run: no earned");

    _staking.deposit(pool, 0); // get all reward
    uint256 rewardAmount = rewardToken.balanceOf(address(this));
    rewardToken.safeApprove(liquidityRouter, rewardAmount);
    _swap(swap0.path, [rewardAmount / 2, swap0.outMin], _deadline);
    _swap(swap1.path, [rewardAmount - rewardAmount / 2, swap1.outMin], _deadline);

    IUniswapV2Pair _stakingToken = IUniswapV2Pair(address(stakingToken));
    _addLiquidity(_stakingToken.token0(), _stakingToken.token1(), _deadline);
    uint256 stakingAmount = _stakingToken.balanceOf(address(this));
    stakingToken.safeApprove(address(_staking), stakingAmount);
    _staking.deposit(pool, stakingAmount);
  }
}

// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// solhint-disable func-name-mixedcase
interface IUniswapV2Pair is IERC20 {
  function nonces(address owner) external view returns (uint256);

  function MINIMUM_LIQUIDITY() external pure returns (uint256);

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
}

// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./utils/DFH/Automate.sol";
import "./utils/DFH/IStorage.sol";
import "./utils/Uniswap/IUniswapV2Router02.sol";
import {ERC20Tools} from "./utils/ERC20Tools.sol";
import "./IMasterChef2.sol";

/**
 * @notice Use with simple token only.
 */
contract MasterChef2SingleRestake is Automate {
  using ERC20Tools for IERC20;

  struct Swap {
    address[] path;
    uint256 outMin;
  }

  IMasterChef2 public staking;

  address public liquidityRouter;

  uint256 public pool;

  uint16 public slippage;

  uint16 public deadline;

  IERC20 public stakingToken;

  IERC20 public rewardToken;

  // solhint-disable-next-line no-empty-blocks
  constructor(address _info) Automate(_info) {}

  function init(
    address _staking,
    address _liquidityRouter,
    uint256 _pool,
    uint16 _slippage,
    uint16 _deadline
  ) external initializer {
    require(
      !_initialized || address(staking) == _staking,
      "MasterChef2SingleRestake::init: reinitialize staking address forbidden"
    );
    staking = IMasterChef2(_staking);
    require(
      !_initialized || liquidityRouter == _liquidityRouter,
      "MasterChef2SingleRestake::init: reinitialize liquidity router address forbidden"
    );
    liquidityRouter = _liquidityRouter;
    require(!_initialized || pool == _pool, "MasterChef2SingleRestake::init: reinitialize pool index forbidden");
    pool = _pool;
    slippage = _slippage;
    deadline = _deadline;

    if (!_initialized) {
      address lpToken = staking.lpToken(pool);
      stakingToken = IERC20(lpToken);
      rewardToken = IERC20(staking.CAKE());
    }
  }

  function deposit() external onlyOwner {
    IERC20 _stakingToken = stakingToken; // gas optimisation
    uint256 balance = _stakingToken.balanceOf(address(this));
    _stakingToken.safeApprove(address(staking), balance);
    staking.deposit(pool, balance);
  }

  function refund() external onlyOwner {
    IMasterChef2 _staking = staking; // gas optimisation
    address __owner = owner(); // gas optimisation
    IMasterChef2.UserInfo memory userInfo = _staking.userInfo(pool, address(this));
    _staking.withdraw(pool, userInfo.amount);
    stakingToken.transfer(__owner, stakingToken.balanceOf(address(this)));
    rewardToken.transfer(__owner, rewardToken.balanceOf(address(this)));
  }

  function emergencyWithdraw() external onlyOwner {
    address __owner = owner(); // gas optimisation
    staking.emergencyWithdraw(pool);
    stakingToken.transfer(__owner, stakingToken.balanceOf(address(this)));
    rewardToken.transfer(__owner, rewardToken.balanceOf(address(this)));
  }

  function _swap(
    address[] memory path,
    uint256[2] memory amount,
    uint256 _deadline
  ) internal {
    if (path[0] == path[path.length - 1]) return;

    IUniswapV2Router02(liquidityRouter).swapExactTokensForTokens(amount[0], amount[1], path, address(this), _deadline);
  }

  function run(
    uint256 gasFee,
    uint256 _deadline,
    Swap memory swap
  ) external bill(gasFee, "PancakeSwapMasterChef2SingleRestake") {
    IMasterChef2 _staking = staking; // gas optimization
    IERC20 _stakingToken = stakingToken;
    require(_staking.pendingCake(pool, address(this)) > 0, "MasterChef2SingleRestake::run: no earned");

    _staking.deposit(pool, 0); // get all reward
    uint256 rewardAmount = rewardToken.balanceOf(address(this));
    rewardToken.safeApprove(liquidityRouter, rewardAmount);
    _swap(swap.path, [rewardAmount, swap.outMin], _deadline);

    uint256 stakingAmount = _stakingToken.balanceOf(address(this));
    _stakingToken.safeApprove(address(_staking), stakingAmount);
    _staking.deposit(pool, stakingAmount);
  }
}

// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.6;

interface IMasterChef2 {
  struct UserInfo {
    uint256 amount;
    uint256 rewardDebt;
  }

  struct PoolInfo {
    uint256 allocPoint;
    uint256 lastRewardBlock;
    uint256 accCakePerShare;
    bool isRegular;
  }

  // solhint-disable-next-line func-name-mixedcase
  function CAKE() external view returns (address);

  function poolInfo(uint256 pool) external view returns (PoolInfo memory);

  function lpToken(uint256 pool) external view returns (address);

  function userInfo(uint256 pool, address user) external view returns (UserInfo memory);

  function pendingCake(uint256 pool, address user) external view returns (uint256);

  function deposit(uint256 pool, uint256 amount) external;

  function withdraw(uint256 pool, uint256 amount) external;

  function emergencyWithdraw(uint256 pool) external;
}

// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./utils/DFH/Automate.sol";
import "./utils/DFH/IStorage.sol";
import "./utils/Uniswap/IUniswapV2Router02.sol";
import "./utils/Uniswap/IUniswapV2Pair.sol";
import {ERC20Tools} from "./utils/ERC20Tools.sol";
import "./IMasterChef2.sol";

/**
 * @notice Use with LP token only.
 */
contract MasterChef2LpRestake is Automate {
  using ERC20Tools for IERC20;

  struct Swap {
    address[] path;
    uint256 outMin;
  }

  IMasterChef2 public staking;

  address public liquidityRouter;

  uint256 public pool;

  uint16 public slippage;

  uint16 public deadline;

  IERC20 public stakingToken;

  IERC20 public rewardToken;

  // solhint-disable-next-line no-empty-blocks
  constructor(address _info) Automate(_info) {}

  function init(
    address _staking,
    address _liquidityRouter,
    uint256 _pool,
    uint16 _slippage,
    uint16 _deadline
  ) external initializer {
    require(
      !_initialized || address(staking) == _staking,
      "MasterChef2LpRestake::init: reinitialize staking address forbidden"
    );
    staking = IMasterChef2(_staking);
    require(
      !_initialized || liquidityRouter == _liquidityRouter,
      "MasterChef2LpRestake::init: reinitialize liquidity router address forbidden"
    );
    liquidityRouter = _liquidityRouter;
    require(!_initialized || pool == _pool, "MasterChef2LpRestake::init: reinitialize pool index forbidden");
    pool = _pool;
    slippage = _slippage;
    deadline = _deadline;

    if (!_initialized) {
      address lpToken = staking.lpToken(pool);
      stakingToken = IERC20(lpToken);
      rewardToken = IERC20(staking.CAKE());
    }
  }

  function deposit() external onlyOwner {
    IERC20 _stakingToken = stakingToken; // gas optimisation
    uint256 balance = _stakingToken.balanceOf(address(this));
    _stakingToken.safeApprove(address(staking), balance);
    staking.deposit(pool, balance);
  }

  function refund() external onlyOwner {
    IMasterChef2 _staking = staking; // gas optimisation
    address __owner = owner(); // gas optimisation
    IMasterChef2.UserInfo memory userInfo = _staking.userInfo(pool, address(this));
    _staking.withdraw(pool, userInfo.amount);
    stakingToken.transfer(__owner, stakingToken.balanceOf(address(this)));
    rewardToken.transfer(__owner, rewardToken.balanceOf(address(this)));
  }

  function emergencyWithdraw() external onlyOwner {
    address __owner = owner(); // gas optimisation
    staking.emergencyWithdraw(pool);
    stakingToken.transfer(__owner, stakingToken.balanceOf(address(this)));
    rewardToken.transfer(__owner, rewardToken.balanceOf(address(this)));
  }

  function _swap(
    address[] memory path,
    uint256[2] memory amount,
    uint256 _deadline
  ) internal {
    if (path[0] == path[path.length - 1]) return;

    IUniswapV2Router02(liquidityRouter).swapExactTokensForTokens(amount[0], amount[1], path, address(this), _deadline);
  }

  function _addLiquidity(
    address token0,
    address token1,
    uint256 _deadline
  ) internal {
    address _liquidityRouter = liquidityRouter; // gas optimisation
    uint256 amountIn0 = IERC20(token0).balanceOf(address(this));
    uint256 amountIn1 = IERC20(token1).balanceOf(address(this));
    IERC20(token0).safeApprove(_liquidityRouter, amountIn0);
    IERC20(token1).safeApprove(_liquidityRouter, amountIn1);
    IUniswapV2Router02(_liquidityRouter).addLiquidity(
      token0,
      token1,
      amountIn0,
      amountIn1,
      0,
      0,
      address(this),
      _deadline
    );
  }

  function run(
    uint256 gasFee,
    uint256 _deadline,
    Swap memory swap0,
    Swap memory swap1
  ) external bill(gasFee, "PancakeSwapMasterChef2LpRestake") {
    IMasterChef2 _staking = staking; // gas optimization
    require(_staking.pendingCake(pool, address(this)) > 0, "MasterChef2LpRestake::run: no earned");

    _staking.deposit(pool, 0); // get all reward
    uint256 rewardAmount = rewardToken.balanceOf(address(this));
    rewardToken.safeApprove(liquidityRouter, rewardAmount);
    _swap(swap0.path, [rewardAmount / 2, swap0.outMin], _deadline);
    _swap(swap1.path, [rewardAmount - rewardAmount / 2, swap1.outMin], _deadline);

    IUniswapV2Pair _stakingToken = IUniswapV2Pair(address(stakingToken));
    _addLiquidity(_stakingToken.token0(), _stakingToken.token1(), _deadline);
    uint256 stakingAmount = _stakingToken.balanceOf(address(this));
    stakingToken.safeApprove(address(_staking), stakingAmount);
    _staking.deposit(pool, stakingAmount);
  }
}