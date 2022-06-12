// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./core/erc20/IWrappedNative.sol";
import "./uniswapV2/IUniswapV2Factory.sol";
import "./uniswapV2/IUniswapV2Pair.sol";
import "./uniswapV2/IUniswapV2Router02.sol";
import "./MetaheroLPM.sol";


/**
 * @title Metahero liquidity pool manager for Uniswap v2
 *
 * @author Stanisław Głogowski <[email protected]>
 */
contract MetaheroLPMForUniswapV2 is MetaheroLPM {
  struct Settings {
    uint256 enableBurnLPAtValue; // value of the tokens that turned on the burnLP method
    address stableCoin; // stable coin address eg. BUSD, DAI
  }

  Settings public settings;

  /**
   * @return Uniswap V2 factory address
   */
  IUniswapV2Factory public uniswapFactory;

  /**
   * @return Uniswap V2 pair address
   */
  IUniswapV2Pair public uniswapPair;

  /**
   * @return Uniswap V2 router02 address
   */
  IUniswapV2Router02 public uniswapRouter;

  IWrappedNative private wrappedNative;
  bool private correctPairOrder;

  // events

  /**
   * @dev Emitted the contract is initialized
   * @param enableBurnLPAtValue value of the tokens that turned on the burnLP method
   * @param stableCoin stable coin address eg. BUSD, DAI
   * @param token token address
   * @param uniswapRouter Uniswap V2 router02 address
   * @param uniswapPair Uniswap V2 pair address
   */
  event Initialized(
    uint256 enableBurnLPAtValue,
    address stableCoin,
    address token,
    address uniswapRouter,
    address uniswapPair
  );

  /**
   * @dev Public constructor
   */
  constructor ()
    MetaheroLPM()
  {
    //
  }

  // external functions

  /**
   * @dev Mints stable coins to the contract
   */
  receive()
    external
    payable
  {
    _deposit(msg.value);
  }

  /**
   * @dev Mints stable coins to the contract
   */
  function deposit()
    external
    payable
  {
    _deposit(msg.value);
  }

  /**
   * @dev Withraws LPs in case of DEX migration
   */
  function migrate(uint256 amount)
    external
    onlyOwner
  {
    uniswapPair.transfer(msg.sender, amount);
  }

  /**
   * @dev Initializes the contract
   * @param enableBurnLPAtValue value of the tokens that turned on the burnLP method
   * @param stableCoin stable coin address eg. BUSD, DAI
   * @param token_ token address
   * @param uniswapRouter_ Uniswap V2 router02 address
   */
  function initialize(
    uint256 enableBurnLPAtValue,
    address stableCoin,
    address token_,
    address uniswapRouter_
  )
    external
    onlyInitializer
  {
    _initialize(token_);

    if (enableBurnLPAtValue != 0) {
      require(
        stableCoin != address(0),
        "MetaheroLPMForUniswapV2#2" // stable coin is the zero address
      );

      settings.enableBurnLPAtValue = enableBurnLPAtValue;
      settings.stableCoin = stableCoin;
    }

    require(
      uniswapRouter_ != address(0),
      "MetaheroLPMForUniswapV2#3" // Uniswap V2 router02 is the zero address
    );

    uniswapRouter = IUniswapV2Router02(uniswapRouter_);
    uniswapFactory = IUniswapV2Factory(uniswapRouter.factory());

    wrappedNative = IWrappedNative(uniswapRouter.WETH());

    // create a pair
    uniswapPair = IUniswapV2Pair(uniswapFactory.createPair(
      address(token),
      address(wrappedNative)
    ));

    correctPairOrder = address(token) < address(wrappedNative);

    emit Initialized(
      enableBurnLPAtValue,
      stableCoin,
      token_,
      uniswapRouter_,
      address(uniswapPair)
    );
  }

  // external functions (views)

  /**
   * @notice Checks when to sync the liquidity pool
   * @param sender sender address
   * @param recipient recipient address
   */
  function canSyncLP(
    address sender,
    address recipient
  )
    external
    view
    override
    returns (
      bool shouldSyncLPBefore,
      bool shouldSyncLPAfter
    )
  {
    if (sender != address(uniswapPair)) { // omit when swap HERO > BNB
      if (recipient == address(uniswapPair)) {
        shouldSyncLPBefore = true; // swap BNB > HERO
      } else {
        shouldSyncLPAfter = true;
      }
    }

    return (shouldSyncLPBefore, shouldSyncLPAfter);
  }

  // internal functions

  function _syncLP()
    internal
    override
  {
    uint256 totalAmount = token.balanceOf(address(this));

    if (totalAmount >= 2) {
      uint256 swapAmount = totalAmount / 2;
      uint256 liquidityAmount = totalAmount - swapAmount;

      // swap half for native
      _swapTokens(swapAmount);

      // add other half with received native
      _addTokensToLiquidity(liquidityAmount);
    }
  }

  function _burnLP(
    uint256 amount
  )
    internal
    override
  {
    if (settings.enableBurnLPAtValue != 0) {
      (uint256 tokenReserve, ) = _getLiquidityReserves();

      require(
        tokenReserve != 0,
        "MetaheroLPMForUniswapV2#4" // token reserve is zero
      );

      require(
        amount <= tokenReserve,
        "MetaheroLPMForUniswapV2#5" // amount higher than token reserve
      );

      uint256 tokenReserveValue = _calcTokensValue(tokenReserve);

      require(
        tokenReserveValue > settings.enableBurnLPAtValue,
        "MetaheroLPMForUniswapV2#6" // burnLP disabled
      );

      uint256 amountValue = _calcTokensValue(amount);
      uint256 maxAmountValue = tokenReserveValue - settings.enableBurnLPAtValue;

      require(
        amountValue <= maxAmountValue,
        "MetaheroLPMForUniswapV2#7" // amount is too high
      );
    }

    // remove liquidity
    _removeLiquidity();

    uint256 totalAmount = token.balanceOf(address(this));

    require(
      totalAmount >= amount,
      "MetaheroLPMForUniswapV2#8" // amount is too high
    );

    token.burn(amount); // burn tokens

    _addTokensToLiquidity( // adds others to liquidity
      totalAmount - amount
    );
  }

  // private functions

  function _deposit(
    uint256 amount
  )
    private
  {
    require(
      amount != 0,
      "MetaheroLPMForUniswapV2#1" // amount is zero
    );

    wrappedNative.deposit{value: amount}();
  }

  function _swapTokens(
    uint256 amount
  )
    private
  {
    token.approve(
      address(uniswapRouter),
      amount
    );

    address[] memory path = new address[](2);

    path[0] = address(token);
    path[1] = address(wrappedNative);

    // omit revert, let's use those tokens on the next swap
    try uniswapRouter.swapExactTokensForTokens(
      amount,
      0,
      path,
      address(this),
      block.timestamp // solhint-disable-line not-rely-on-time
    ) {
      //
    } catch {
      //
    }
  }

  function _addTokensToLiquidity(
    uint256 tokensAmount
  )
    private
  {
    uint256 wrappedNativeAmount = wrappedNative.balanceOf(address(this));

    if (
      tokensAmount != 0 &&
      wrappedNativeAmount != 0
    ) {
      token.approve(
        address(uniswapRouter),
        tokensAmount
      );

      wrappedNative.approve(
        address(uniswapRouter),
        wrappedNativeAmount
      );

      // omit revert, let's use those tokens on the next swap
      try uniswapRouter.addLiquidity(
        address(token),
        address(wrappedNative),
        tokensAmount,
        wrappedNativeAmount,
        0,
        0,
        address(this),
        block.timestamp // solhint-disable-line not-rely-on-time
      ) {
        //
      } catch {
        //
      }
    }
  }

  function _removeLiquidity()
    private
  {
    uint256 liquidity = uniswapPair.balanceOf(address(this));

    if (liquidity != 0) {
      uniswapPair.approve(
        address(uniswapRouter),
        liquidity
      );

      uniswapRouter.removeLiquidity(
        address(token),
        address(wrappedNative),
        liquidity,
        0,
        0,
        address(this),
        block.timestamp // solhint-disable-line not-rely-on-time
      );
    }
  }

  // private functions (views)

  function _calcTokensValue(
    uint256 amount
  )
    private
    view
    returns (uint256)
  {
    address[] memory path = new address[](3);

    path[0] = address(token);
    path[1] = address(wrappedNative);
    path[2] = settings.stableCoin;

    uint256[] memory amounts = uniswapRouter.getAmountsOut(amount, path);

    return amounts[2];
  }

  function _getLiquidityReserves()
    private
    view
    returns (
      uint256 tokenReserve,
      uint256 wrappedNativeReserve
    )
  {
    (
      uint112 reserve0,
      uint112 reserve1,
    ) = uniswapPair.getReserves();

    (tokenReserve, wrappedNativeReserve) = correctPairOrder
      ? (reserve0, reserve1)
      : (reserve1, reserve0);

    return (tokenReserve, wrappedNativeReserve);
  }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.14;

import "./IERC20.sol";


/**
 * @title Wrapped native (eg. WBNB, WETH) token interface
 *
 * @notice Based on https://github.com/Uniswap/uniswap-v2-periphery/blob/dda62473e2da448bc9cb8f4514dadda4aeede5f4/contracts/interfaces/IWETH.sol
 */
interface IWrappedNative is IERC20 {
  // external functions

  function deposit()
    external
    payable;

  function withdraw(
    uint256 amount
  )
    external;
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.14;

/**
 * @title Uniswap v2 factory interface
 *
 * @notice Based on https://github.com/Uniswap/uniswap-v2-core/blob/4dd59067c76dea4a0e8e4bfdda41877a6b16dedc/contracts/interfaces/IUniswapV2Factory.sol
 */
interface IUniswapV2Factory {
  // events

  event PairCreated(
    address indexed token0,
    address indexed token1,
    address pair,
    uint256
  );

  // external functions

  function createPair(
    address tokenA,
    address tokenB
  )
    external
    returns (address);

  function setFeeTo(
    address
  )
    external;

  function setFeeToSetter(
    address
  )
    external;

  // external functions (views)

  function feeTo()
    external
    view
    returns (address);

  function feeToSetter()
    external
    view
    returns (address);

  function getPair(
    address tokenA,
    address tokenB
  )
    external
    view
    returns (address);

  function allPairs(
    uint256
  )
    external
    view
    returns (address);

  function allPairsLength()
    external
    view
    returns (uint256);
}

// SPDX-License-Identifier: GPL-3.0
/* solhint-disable func-name-mixedcase */
pragma solidity ^0.8.14;

import "../core/erc20/IERC20.sol";


/**
 * @title Uniswap V2 pair interface
 *
 * @notice Based on https://github.com/Uniswap/uniswap-v2-core/blob/4dd59067c76dea4a0e8e4bfdda41877a6b16dedc/contracts/interfaces/IUniswapV2Pair.sol
 */
interface IUniswapV2Pair is IERC20 {
  // events

  event Mint(
    address indexed sender,
    uint256 amount0,
    uint256 amount1
  );

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

  event Sync(
    uint112 reserve0,
    uint112 reserve1
  );

  // external functions

  function initialize(
    address,
    address
  )
    external;

  function mint(
    address to
  )
    external
    returns (uint256);

  function burn(
    address to
  )
    external
    returns (uint256, uint256);

  function swap(
    uint256 amount0Out,
    uint256 amount1Out,
    address to,
    bytes calldata data
  )
    external;

  function skim(
    address to
  )
    external;

  function sync()
    external;

  function permit(
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  )
    external;

  // external functions (views)

  function DOMAIN_SEPARATOR()
    external
    view
    returns (bytes32);

  function nonces(
    address owner
  )
    external
    view
    returns (uint256);

  function factory()
    external
    view
    returns (address);

  function token0()
    external
    view
    returns (address);

  function token1()
    external
    view
    returns (address);

  function getReserves()
    external
    view
    returns (uint112, uint112, uint32);

  function price0CumulativeLast()
    external
    view
    returns (uint256);

  function price1CumulativeLast()
    external
    view
    returns (uint256);

  function kLast()
    external
    view
    returns (uint256);

  // external functions (pure)

  function PERMIT_TYPEHASH()
    external
    pure
    returns (bytes32);

  function MINIMUM_LIQUIDITY()
    external
    pure
    returns (uint256);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.14;

import "./IUniswapV2Router01.sol";


/**
 * @title Uniswap V2 router02 interface
 *
 * @notice Based on https://github.com/Uniswap/uniswap-v2-periphery/blob/dda62473e2da448bc9cb8f4514dadda4aeede5f4/contracts/interfaces/IUniswapV2Router02.sol
 */
interface IUniswapV2Router02 is IUniswapV2Router01 {
  // external functions

  function swapExactETHForTokensSupportingFeeOnTransferTokens(
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  )
    external
    payable;

  function removeLiquidityETHSupportingFeeOnTransferTokens(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  )
    external
    returns (uint256);

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
  )
    external
    returns (uint256);

  function swapExactTokensForTokensSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  )
    external;

  function swapExactTokensForETHSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  )
    external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./core/access/Lockable.sol";
import "./core/access/Owned.sol";
import "./core/lifecycle/Initializable.sol";
import "./core/math/SafeMathLib.sol";
import "./MetaheroToken.sol";


/**
 * @title Metahero abstract liquidity pool manager
 *
 * @author Stanisław Głogowski <[email protected]>
 */
abstract contract MetaheroLPM is Lockable, Owned, Initializable {
  using SafeMathLib for uint256;

  /**
   * @return token address
   */
  MetaheroToken public token;

  // modifiers

  /**
   * @dev Throws if msg.sender is not the token
   */
  modifier onlyToken() {
    require(
      msg.sender == address(token),
      "MetaheroLPM#1" // msg.sender is not the token
    );

    _;
  }

  // events

  /**
   * @dev Emitted when tokens from the liquidity pool are burned
   * @param amount burnt amount
   */
  event LPBurnt(
    uint256 amount
  );

  /**
   * @dev Internal constructor
   */
  constructor ()
    Lockable()
    Owned()
    Initializable()
  {
    //
  }

  // external functions

  /**
   * @notice Syncs liquidity pool
   */
  function syncLP()
    external
    onlyToken
    lock
  {
    _syncLP();
  }

  /**
   * @notice Burns tokens from the liquidity pool
   * @param amount tokens amount
   */
  function burnLP(
    uint256 amount
  )
    external
    onlyOwner
    lockOrThrowError
  {
    require(
      amount != 0,
      "MetaheroLPM#2" // amount is zero
    );

    _burnLP(amount);

    emit LPBurnt(
      amount
    );
  }

  // external functions (views)

  function canSyncLP(
    address sender,
    address recipient
  )
    external
    view
    virtual
    returns (
      bool shouldSyncLPBefore,
      bool shouldSyncLPAfter
    );

  // internal functions

  function _initialize(
    address token_
  )
    internal
  {
    require(
      token_ != address(0),
      "MetaheroLPM#3" // token is the zero address
    );

    token = MetaheroToken(token_);
  }

  function _syncLP()
    internal
    virtual;

  function _burnLP(
    uint256 amount
  )
    internal
    virtual;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

/**
 * @title ERC20 token interface
 *
 * @notice See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 */
interface IERC20 {
  // events

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  // external functions

  function approve(
    address spender,
    uint256 value
  )
    external
    returns (bool);

  function transfer(
    address to,
    uint256 value
  )
    external
    returns (bool);

  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    external
    returns (bool);

  // external functions (views)

  function totalSupply()
    external
    view
    returns (uint256);

  function balanceOf(
    address owner
  )
    external
    view
    returns (uint256);

  function allowance(
    address owner,
    address spender
  )
    external
    view
    returns (uint256);

  // external functions (pure)

  function name()
    external
    view
    returns (string memory);

  function symbol()
    external
    view
    returns (string memory);

  function decimals()
    external
    view
    returns (uint8);
}

// SPDX-License-Identifier: GPL-3.0
/* solhint-disable func-name-mixedcase */
pragma solidity ^0.8.14;

/**
 * @title Uniswap V2 router01 interface
 *
 * @notice Based on https://github.com/Uniswap/uniswap-v2-periphery/blob/dda62473e2da448bc9cb8f4514dadda4aeede5f4/contracts/interfaces/IUniswapV2Router01.sol
 */
interface IUniswapV2Router01 {
  // external functions

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
    returns (uint256, uint256, uint256);

  function swapExactETHForTokens(
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  )
    external
    payable
    returns (uint256[] memory);

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
    returns (uint256, uint256, uint256);

  function removeLiquidity(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  )
    external
    returns (uint256, uint256);

  function removeLiquidityETH(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  )
    external
    returns (uint256, uint256);

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
  )
    external
    returns (uint256, uint256);

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
  )
    external
    returns (uint256, uint256);

  function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  )
    external
    returns (uint256[] memory);

  function swapTokensForExactTokens(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  )
    external
    returns (uint256[] memory);

  function swapTokensForExactETH(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  )
    external
    returns (uint256[] memory);

  function swapExactTokensForETH(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  )
    external
    returns (uint256[] memory);

  function swapETHForExactTokens(
    uint256 amountOut,
    address[] calldata path,
    address to,
    uint256 deadline
  )
    external
    payable
    returns (uint256[] memory);

  // external functions (views)

  function getAmountsOut(
    uint256 amountIn,
    address[] calldata path
  )
    external
    view
    returns (uint256[] memory);

  function getAmountsIn(
    uint256 amountOut,
    address[] calldata path
  )
    external
    view
    returns (uint256[] memory);

  // external functions (pure)

  function quote(
    uint256 amountA,
    uint256 reserveA,
    uint256 reserveB
  )
    external
    pure
    returns (uint256);

  function getAmountOut(
    uint256 amountIn,
    uint256 reserveIn,
    uint256 reserveOut
  )
    external
    pure
    returns (uint256);

  function getAmountIn(
    uint256 amountOut,
    uint256 reserveIn,
    uint256 reserveOut
  )
    external
    pure
    returns (uint256);

  function factory()
    external
    view
    returns (address);

  function WETH()
    external
    view
    returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

/**
 * @title Lockable
 *
 * @author Stanisław Głogowski <[email protected]>
 */
contract Lockable {
  /**
   * @return true when contract is locked
   */
  bool public locked;

  // modifiers


  /**
   * @dev Calls only when contract is unlocked
   */
  modifier lock() {
    if (!locked) {
      locked = true;

      _;

      locked = false;
    }
  }

  /**
   * @dev Throws if contract is locked
   */
  modifier lockOrThrowError() {
    require(
      !locked,
      "Lockable#1" // contract is locked
    );

    locked = true;

    _;

    locked = false;
  }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

/**
 * @title Owned
 *
 * @author Stanisław Głogowski <[email protected]>
 */
contract Owned {
  /**
   * @return owner address
   */
  address public owner;

  // modifiers

  /**
   * @dev Throws if msg.sender is not the owner
   */
  modifier onlyOwner() {
    require(
      msg.sender == owner,
      "Owned#1" // msg.sender is not the owner
    );

    _;
  }

  // events

  /**
   * @dev Emitted when the owner is updated
   * @param owner new owner address
   */
  event OwnerUpdated(
    address owner
  );

  /**
   * @dev Internal constructor
   */
  constructor()
  {
    owner = msg.sender;
  }

  // external functions

  /**
   * @notice Sets a new owner
   * @param owner_ owner address
   */
  function setOwner(
    address owner_
  )
    external
    onlyOwner
  {
    _setOwner(owner_);
  }

  // internal functions

  function _setOwner(
    address owner_
  )
    internal
  {
    require(
      owner_ != address(0),
      "Owned#2" // owner is the zero address
    );

    require(
      owner_ != owner,
      "Owned#3" // does not update the owner
    );

    owner = owner_;

    emit OwnerUpdated(
      owner_
    );
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

/**
 * @title Initializable
 *
 * @author Stanisław Głogowski <[email protected]>
 */
contract Initializable {
  address private initializer;

  // modifiers

  /**
   * @dev Throws if msg.sender is not the initializer
   */
  modifier onlyInitializer() {
    require(
      initializer != address(0),
      "Initializable#1" // already initialized
    );

    require(
      msg.sender == initializer,
      "Initializable#2" // msg.sender is not the initializer
    );

    /// @dev removes initializer
    initializer = address(0);

    _;
  }

  /**
   * @dev Internal constructor
   */
  constructor()
  {
    initializer = msg.sender;
  }

  // external functions (views)

  /**
   * @notice Checks if contract is initialized
   * @return true when contract is initialized
   */
  function initialized()
    external
    view
    returns (bool)
  {
    return initializer == address(0);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

/**
 * @title Safe math library
 *
 * @notice Based on https://github.com/OpenZeppelin/openzeppelin-contracts/blob/5fe8f4e93bd1d4f5cc9a6899d7f24f5ffe4c14aa/contracts/math/SafeMath.sol
 */
library SafeMathLib {
  // internal functions (pure)

  /**
   * @notice Calcs a + b
   */
  function add(
    uint256 a,
    uint256 b
  )
    internal
    pure
    returns (uint256)
  {
    uint256 c = a + b;

    require(
      c >= a,
      "SafeMathLib#1"
    );

    return c;
  }

  /**
   * @notice Calcs a - b
   */
  function sub(
    uint256 a,
    uint256 b
  )
    internal
    pure
    returns (uint256)
  {
    require(
      b <= a,
      "SafeMathLib#2"
    );

    return a - b;
  }

  /**
   * @notice Calcs a x b
   */
  function mul(
    uint256 a,
    uint256 b
  )
    internal
    pure
    returns (uint256 result)
  {
    if (a != 0 && b != 0) {
      result = a * b;

      require(
        result / a == b,
        "SafeMathLib#3"
      );
    }

    return result;
  }

  /**
   * @notice Calcs a / b
   */
  function div(
    uint256 a,
    uint256 b
  )
    internal
    pure
    returns (uint256)
  {
    require(
      b != 0,
      "SafeMathLib#4"
    );

    return a / b;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./core/access/Controlled.sol";
import "./core/access/Owned.sol";
import "./core/erc20/ERC20.sol";
import "./core/lifecycle/Initializable.sol";
import "./core/math/MathLib.sol";
import "./core/math/SafeMathLib.sol";
import "./IMetaheroDAO.sol";
import "./MetaheroLPM.sol";


/**
 * @title Metahero token
 *
 * @author Stanisław Głogowski <[email protected]>
 */
contract MetaheroToken is Controlled, Owned, ERC20, Initializable {
  using MathLib for uint256;
  using SafeMathLib for uint256;

  struct Fees {
    uint256 sender; // percent from sender
    uint256 recipient; // percent from recipient
  }

  struct Settings {
    Fees burnFees; // fee taken and burned
    Fees lpFees; // fee taken and added to the liquidity pool manager
    Fees rewardsFees; // fee taken and added to rewards
    uint256 minTotalSupply; // min amount of tokens total supply
  }

  struct Summary {
    uint256 totalExcluded; // total held by excluded accounts
    uint256 totalHolding; // total held by holder accounts
    uint256 totalRewards; // total rewards
    uint256 totalSupply; // total supply
  }

  struct ExcludedAccount {
    bool exists; // true if exists
    bool excludeSenderFromFee; // removes the fee from all sender accounts on incoming transfers
    bool excludeRecipientFromFee; // removes the fee from all recipient accounts on outgoing transfers
  }

  // globals

  uint256 private constant MAX_FEE = 30; // max sum of all fees - 30%

  // metadata

  string private constant TOKEN_NAME = "Metahero";
  string private constant TOKEN_SYMBOL = "HERO";
  uint8 private constant TOKEN_DECIMALS = 18; // 0.000000000000000000

  /**
   * @return liquidity pool manager address
   */
  MetaheroLPM public lpm;

  Settings public settings;

  Summary public summary;

  mapping (address => uint256) private accountBalances;
  mapping (address => mapping (address => uint256)) private accountAllowances;
  mapping (address => ExcludedAccount) private excludedAccounts;

  // events

  /**
   * @dev Emitted when the contract is initialized
   * @param burnFees burn fees
   * @param lpFees liquidity pool fees
   * @param rewardsFees rewards fees
   * @param minTotalSupply min total supply
   * @param lpm liquidity pool manager address
   * @param controller controller address
   */
  event Initialized(
    Fees burnFees,
    Fees lpFees,
    Fees rewardsFees,
    uint256 minTotalSupply,
    address lpm,
    address controller
  );

  /**
   * @dev Emitted when the dao is updated
   * @param dao dao address
   */
  event DAOUpdated(
    address dao
  );

  /**
   * @dev Emitted when fees are updated
   * @param burnFees burn fees
   * @param lpFees liquidity pool fees
   * @param rewardsFees rewards fees
   */
  event FeesUpdated(
    Fees burnFees,
    Fees lpFees,
    Fees rewardsFees
  );

  /**
   * @dev Emitted when account is excluded
   * @param account account address
   * @param excludeSenderFromFee exclude sender from fee
   * @param excludeRecipientFromFee exclude recipient from fee
   */
  event AccountExcluded(
    address indexed account,
    bool excludeSenderFromFee,
    bool excludeRecipientFromFee
  );

  /**
   * @dev Emitted when total rewards amount is updated
   * @param totalRewards total rewards amount
   */
  event TotalRewardsUpdated(
    uint256 totalRewards
  );

  // modifiers

  /**
   * @dev Throws if msg.sender is not the excluded account
   */
  modifier onlyExcludedAccount() {
    require(
      excludedAccounts[msg.sender].exists,
      "MetaheroToken#2" // msg.sender is not the excluded account
    );

    _;
  }

  /**
   * @dev Public constructor
   */
  constructor ()
    Controlled()
    ERC20(TOKEN_NAME, TOKEN_SYMBOL, TOKEN_DECIMALS) // sets metadata
    Initializable()
  {
    //
  }

  // external functions

  /**
   * @dev Initializes the contract
   * @param burnFees burn fees
   * @param lpFees liquidity pool fees
   * @param rewardsFees rewards fees
   * @param minTotalSupply min total supply
   * @param lpm_ liquidity pool manager address
   * @param controller_ controller address
   * @param totalSupply_ total supply
   */
  function initialize(
    Fees memory burnFees,
    Fees memory lpFees,
    Fees memory rewardsFees,
    uint256 minTotalSupply,
    address payable lpm_,
    address controller_,
    uint256 totalSupply_,
    address[] calldata excludedAccounts_
  )
    external
    onlyInitializer
  {
    _verifyFees(burnFees, lpFees, rewardsFees);

    settings.burnFees = burnFees;
    settings.lpFees = lpFees;
    settings.rewardsFees = rewardsFees;
    settings.minTotalSupply = minTotalSupply;

    if (
      lpFees.sender != 0 ||
      lpFees.recipient != 0
    ) {
      require(
        lpm_ != address(0),
        "MetaheroToken#3" // lpm is the zero address
      );

      lpm = MetaheroLPM(lpm_);
    }

    _initializeController(controller_);

    emit Initialized(
      burnFees,
      lpFees,
      rewardsFees,
      minTotalSupply,
      lpm_,
      controller_
    );

    // excludes owner account
    _excludeAccount(msg.sender, true, true);

    if (totalSupply_ != 0) {
      _mint(
        msg.sender,
        totalSupply_
      );
    }

    // adds predefined excluded accounts
    uint256 excludedAccountsLen = excludedAccounts_.length;

    for (uint256 index; index < excludedAccountsLen; index++) {
      _excludeAccount(excludedAccounts_[index], false, false);
    }
  }

  /**
   * @dev Updates fees
   * @param burnFees burn fees
   * @param lpFees liquidity pool fees
   * @param rewardsFees rewards fees
   */
  function updateFees(
    Fees memory burnFees,
    Fees memory lpFees,
    Fees memory rewardsFees
  )
    external
    onlyOwner
  {
    _verifyFees(burnFees, lpFees, rewardsFees);

    settings.burnFees = burnFees;
    settings.lpFees = lpFees;
    settings.rewardsFees = rewardsFees;

    emit FeesUpdated(
      burnFees,
      lpFees,
      rewardsFees
    );
  }

  /**
   * @dev Excludes account
   * @param account account address
   * @param excludeSenderFromFee exclude sender from fee
   * @param excludeRecipientFromFee exclude recipient from fee
   */
  function excludeAccount(
    address account,
    bool excludeSenderFromFee,
    bool excludeRecipientFromFee
  )
    external
    onlyOwner
  {
    _excludeAccount(
      account,
      excludeSenderFromFee,
      excludeRecipientFromFee
    );
  }

  /**
   * @dev Approve spending limit
   * @param spender spender address
   * @param amount spending limit
   */
  function approve(
    address spender,
    uint256 amount
  )
    external
    override
    returns (bool)
  {
    _approve(
      msg.sender,
      spender,
      amount
    );

    return true;
  }

  /**
   * @dev Mints tokens to recipient
   * @param recipient recipient address
   * @param amount tokens amount
   */
  function mintTo(
    address recipient,
    uint256 amount
  )
    external
    onlyController
  {
    _mint(
      recipient,
      amount
    );
  }

  /**
   * @dev Burns tokens from msg.sender
   * @param amount tokens amount
   */
  function burn(
    uint256 amount
  )
    external
    onlyExcludedAccount
  {
    _burn(
      msg.sender,
      amount
    );
  }

  /**
   * @dev Burns tokens from sender
   * @param sender sender address
   * @param amount tokens amount
   */
  function burnFrom(
    address sender,
    uint256 amount
  )
    external
    onlyController
  {
    _burn(
      sender,
      amount
    );
  }

  /**
   * @dev Transfers tokens to recipient
   * @param recipient recipient address
   * @param amount tokens amount
   */
  function transfer(
    address recipient,
    uint256 amount
  )
    external
    override
    returns (bool)
  {
    _transfer(
      msg.sender,
      recipient,
      amount
    );

    return true;
  }

  /**
   * @dev Transfers tokens from sender to recipient
   * @param sender sender address
   * @param recipient recipient address
   * @param amount tokens amount
   */
  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  )
    external
    override
    returns (bool)
  {
    _transfer(
      sender,
      recipient,
      amount
    );

    uint256 currentAllowance = accountAllowances[sender][msg.sender];

    require(
      currentAllowance >= amount,
      "MetaheroToken#6"  // amount exceeds allowance
    );

    _approve( // update allowance
      sender,
      msg.sender,
      currentAllowance.sub(amount)
    );

    return true;
  }

  // external functions (views)

  /**
   * @dev Gets excluded account
   * @param account account address
   */
  function getExcludedAccount(
    address account
  )
    external
    view
    returns (
      bool exists,
      bool excludeSenderFromFee,
      bool excludeRecipientFromFee
    )
  {
    return (
      excludedAccounts[account].exists,
      excludedAccounts[account].excludeSenderFromFee,
      excludedAccounts[account].excludeRecipientFromFee
    );
  }

  /**
   * @dev Gets total supply
   * @return total supply
   */
  function totalSupply()
    external
    view
    override
    returns (uint256)
  {
    return summary.totalSupply;
  }

  /**
   * @dev Gets allowance
   * @param owner owner address
   * @param spender spender address
   * @return allowance
   */
  function allowance(
    address owner,
    address spender
  )
    external
    view
    override
    returns (uint256)
  {
    return accountAllowances[owner][spender];
  }

  /**
   * @dev Gets balance of
   * @param account account address
   * @return result account balance
   */
  function balanceOf(
    address account
  )
    external
    view
    override
    returns (uint256 result)
  {
    result = accountBalances[account].add(
      _calcRewards(account)
    );

    return result;
  }

  /**
   * @dev Gets balance summary
   * @param account account address
   */
  function getBalanceSummary(
    address account
  )
    external
    view
    returns (
      uint256 totalBalance,
      uint256 holdingBalance,
      uint256 totalRewards
    )
  {
    holdingBalance = accountBalances[account];
    totalRewards = _calcRewards(account);
    totalBalance = holdingBalance.add(totalRewards);

    return (totalBalance, holdingBalance, totalRewards);
  }

  // private functions

  function _excludeAccount(
    address account,
    bool excludeSenderFromFee,
    bool excludeRecipientFromFee
  )
    private
  {
    require(
      account != address(0),
      "MetaheroToken#7" // account is the zero address
    );

    // if already excluded
    if (excludedAccounts[account].exists) {
      require(
        excludedAccounts[account].excludeSenderFromFee != excludeSenderFromFee ||
        excludedAccounts[account].excludeRecipientFromFee != excludeRecipientFromFee,
        "MetaheroToken#8" // does not update exclude account
      );

      excludedAccounts[account].excludeSenderFromFee = excludeSenderFromFee;
      excludedAccounts[account].excludeRecipientFromFee = excludeRecipientFromFee;
    } else {
      require(
        accountBalances[account] == 0,
        "MetaheroToken#9" // can not exclude holder account
      );

      excludedAccounts[account].exists = true;
      excludedAccounts[account].excludeSenderFromFee = excludeSenderFromFee;
      excludedAccounts[account].excludeRecipientFromFee = excludeRecipientFromFee;
    }

    emit AccountExcluded(
      account,
      excludeSenderFromFee,
      excludeRecipientFromFee
    );
  }

  function _approve(
    address owner,
    address spender,
    uint256 amount
  )
    private
  {
    require(
      spender != address(0),
      "MetaheroToken#11" // spender is the zero address
    );

    accountAllowances[owner][spender] = amount;

    emit Approval(
      owner,
      spender,
      amount
    );
  }

  function _mint(
    address recipient,
    uint256 amount
  )
    private
  {
    require(
      recipient != address(0),
      "MetaheroToken#12" // recipient is the zero address
    );

    require(
      amount != 0,
      "MetaheroToken#13" // amount is zero
    );

    summary.totalSupply = summary.totalSupply.add(amount);

    // if exclude account
    if (excludedAccounts[recipient].exists) {
      summary.totalExcluded = summary.totalExcluded.add(amount);

      accountBalances[recipient] = accountBalances[recipient].add(amount);
    } else {
      _updateHoldingBalance(
        recipient,
        accountBalances[recipient].add(amount),
        summary.totalHolding.add(amount)
      );
    }

    _emitTransfer(
      address(0),
      recipient,
      amount
    );
  }

  function _burn(
    address sender,
    uint256 amount
  )
    private
  {
    require(
      sender != address(0),
      "MetaheroToken#14" // sender is the zero address
    );

    require(
      amount != 0,
      "MetaheroToken#15" // amount is zero
    );

    require(
      accountBalances[sender] >= amount,
      "MetaheroToken#16" // amount exceeds sender balance
    );

    uint256 totalSupply_ = summary.totalSupply.sub(amount);

    if (settings.minTotalSupply != 0) {
      require(
        totalSupply_ >= settings.minTotalSupply,
        "MetaheroToken#17" // new total supply exceeds min total supply
      );
    }

    summary.totalSupply = totalSupply_;

    // if exclude account
    if (excludedAccounts[sender].exists) {
      summary.totalExcluded = summary.totalExcluded.sub(amount);

      accountBalances[sender] = accountBalances[sender].sub(amount);
    } else {
      _updateHoldingBalance(
        sender,
        accountBalances[sender].sub(amount),
        summary.totalHolding.sub(amount)
      );
    }

    _emitTransfer(
      sender,
      address(0),
      amount
    );
  }

  function _transfer(
    address sender,
    address recipient,
    uint256 amount
  )
    private
  {
    require(
      sender != address(0),
      "MetaheroToken#18" // sender is the zero address
    );

    require(
      recipient != address(0),
      "MetaheroToken#19" // recipient is the zero address
    );

    if (sender == recipient) { // special transfer type
      _syncLP(); // sync only LP

      _emitTransfer(
        sender,
        recipient,
        0
      );
    } else {
      require(
        amount != 0,
        "MetaheroToken#21" // amount is zero
      );

      if (
        !excludedAccounts[sender].exists &&
        !excludedAccounts[recipient].exists
      ) {
        _transferBetweenHolderAccounts(
          sender,
          recipient,
          amount
        );
      } else if (
        excludedAccounts[sender].exists &&
        !excludedAccounts[recipient].exists
      ) {
        _transferFromExcludedAccount(
          sender,
          recipient,
          amount
        );
      } else if (
        !excludedAccounts[sender].exists &&
        excludedAccounts[recipient].exists
      ) {
        _transferToExcludedAccount(
          sender,
          recipient,
          amount
        );
      } else {
        _transferBetweenExcludedAccounts(
          sender,
          recipient,
          amount
        );
      }
    }
  }

  function _transferBetweenHolderAccounts(
    address sender,
    address recipient,
    uint256 amount
  )
    private
  {
    uint256 senderAmount;
    uint256 senderBurnFee;
    uint256 senderLpFee;

    uint256 recipientAmount;
    uint256 recipientBurnFee;
    uint256 recipientLpFee;

    uint256 totalFee;

    {
      uint256 totalSupply_ = summary.totalSupply;

      // calc fees for sender and recipient
      {
        uint256 senderTotalFee;
        uint256 recipientTotalFee;

        (
          senderTotalFee,
          senderBurnFee,
          senderLpFee
        ) = _calcTransferSenderFees(amount);

        (
          totalSupply_,
          senderTotalFee,
          senderBurnFee
        ) = _matchTotalSupplyWithFees(totalSupply_, senderTotalFee, senderBurnFee);

        (
          recipientTotalFee,
          recipientBurnFee,
          recipientLpFee
        ) = _calcTransferRecipientFees(amount);

        (
          totalSupply_,
          recipientTotalFee,
          recipientBurnFee
        ) = _matchTotalSupplyWithFees(totalSupply_, recipientTotalFee, recipientBurnFee);

        totalFee = senderTotalFee.add(recipientTotalFee);
        senderAmount = amount.add(senderTotalFee);
        recipientAmount = amount.sub(recipientTotalFee);
      }

      // appends total rewards
      if (summary.totalRewards != 0) {
        uint256 totalHoldingWithRewards = summary.totalHolding.add(
          summary.totalRewards
        );

        senderAmount = senderAmount.mul(summary.totalHolding).div(
          totalHoldingWithRewards
        );
        recipientAmount = recipientAmount.mul(summary.totalHolding).div(
          totalHoldingWithRewards
        );
        totalFee = totalFee.mul(summary.totalHolding).div(
          totalHoldingWithRewards
        );
      }

      require(
        accountBalances[sender] >= senderAmount,
        "MetaheroToken#22" // amount exceeds sender balance
      );

      summary.totalSupply = totalSupply_;

      // reduce local vars
      senderAmount = accountBalances[sender].sub(senderAmount);
      recipientAmount = accountBalances[recipient].add(recipientAmount);

      _updateHoldingBalances(
        sender,
        senderAmount,
        recipient,
        recipientAmount,
        summary.totalHolding.sub(totalFee)
      );

      _increaseTotalLP(senderLpFee.add(recipientLpFee));
    }

    // emits events

    {
      _emitTransfer(
        sender,
        recipient,
        amount
      );

      _emitTransfer(
        sender,
        address(0),
        senderBurnFee
      );

      _emitTransfer(
        sender,
        address(lpm),
        senderLpFee
      );

      _emitTransfer(
        recipient,
        address(0),
        recipientBurnFee
      );

      _emitTransfer(
        recipient,
        address(lpm),
        recipientLpFee
      );

      _updateTotalRewards();

      _syncLP();
    }
  }

  function _transferFromExcludedAccount(
    address sender,
    address recipient,
    uint256 amount
  )
    private
  {
    require(
      accountBalances[sender] >= amount,
      "MetaheroToken#23" // amount exceeds sender balance
    );

    (
      bool shouldSyncLPBefore,
      bool shouldSyncLPAfter
    ) = _canSyncLP(
      sender,
      address(0)
    );

    if (shouldSyncLPBefore) {
      lpm.syncLP();
    }

    uint256 recipientTotalFee;
    uint256 recipientBurnFee;
    uint256 recipientLPFee;

    uint256 totalSupply_ = summary.totalSupply;

    // when sender does not remove the fee from the recipient
    if (!excludedAccounts[sender].excludeRecipientFromFee) {
      (
        recipientTotalFee,
        recipientBurnFee,
        recipientLPFee
      ) = _calcTransferRecipientFees(amount);

      (
        totalSupply_,
        recipientTotalFee,
        recipientBurnFee
      ) = _matchTotalSupplyWithFees(totalSupply_, recipientTotalFee, recipientBurnFee);
    }

    uint256 recipientAmount = amount.sub(recipientTotalFee);

    summary.totalSupply = totalSupply_;
    summary.totalExcluded = summary.totalExcluded.sub(amount);

    accountBalances[sender] = accountBalances[sender].sub(amount);

    _updateHoldingBalance(
      recipient,
      accountBalances[recipient].add(recipientAmount),
      summary.totalHolding.add(recipientAmount)
    );

    _increaseTotalLP(recipientLPFee);

    // emits events

    _emitTransfer(
      sender,
      recipient,
      amount
    );

    _emitTransfer(
      recipient,
      address(0),
      recipientBurnFee
    );

    _emitTransfer(
      recipient,
      address(lpm),
      recipientLPFee
    );

    _updateTotalRewards();

    if (shouldSyncLPAfter) {
      lpm.syncLP();
    }
  }

  function _transferToExcludedAccount(
    address sender,
    address recipient,
    uint256 amount
  )
    private
  {
    (
      bool shouldSyncLPBefore,
      bool shouldSyncLPAfter
    ) = _canSyncLP(
      address(0),
      recipient
    );

    if (shouldSyncLPBefore) {
      lpm.syncLP();
    }

    uint256 senderTotalFee;
    uint256 senderBurnFee;
    uint256 senderLpFee;

    uint256 totalSupply_ = summary.totalSupply;

    // when recipient does not remove the fee from the sender
    if (!excludedAccounts[recipient].excludeSenderFromFee) {
      (
        senderTotalFee,
        senderBurnFee,
        senderLpFee
      ) = _calcTransferSenderFees(amount);

      (
        totalSupply_,
        senderTotalFee,
        senderBurnFee
      ) = _matchTotalSupplyWithFees(totalSupply_, senderTotalFee, senderBurnFee);
    }

    uint256 senderAmount = amount.add(senderTotalFee);

    // append total rewards
    if (summary.totalRewards != 0) {
      uint256 totalHoldingWithRewards = summary.totalHolding.add(
        summary.totalRewards
      );

      senderAmount = senderAmount.mul(summary.totalHolding).div(
        totalHoldingWithRewards
      );
    }

    require(
      accountBalances[sender] >= senderAmount,
      "MetaheroToken#24" // amount exceeds sender balance
    );

    summary.totalSupply = totalSupply_;
    summary.totalExcluded = summary.totalExcluded.add(amount);

    accountBalances[recipient] = accountBalances[recipient].add(amount);

    _updateHoldingBalance(
      sender,
      accountBalances[sender].sub(senderAmount),
      summary.totalHolding.sub(senderAmount)
    );

    _increaseTotalLP(senderLpFee);

    // emits events

    _emitTransfer(
      sender,
      recipient,
      amount
    );

    _emitTransfer(
      sender,
      address(0),
      senderBurnFee
    );

    _emitTransfer(
      sender,
      address(lpm),
      senderLpFee
    );

    _updateTotalRewards();

    if (shouldSyncLPAfter) {
      lpm.syncLP();
    }
  }

  function _transferBetweenExcludedAccounts(
    address sender,
    address recipient,
    uint256 amount
  )
    private
  {
    require(
      accountBalances[sender] >= amount,
      "MetaheroToken#25" // amount exceeds sender balance
    );

    (
      bool shouldSyncLPBefore,
      bool shouldSyncLPAfter
    ) = _canSyncLP(
      address(0),
      recipient
    );

    if (shouldSyncLPBefore) {
      lpm.syncLP();
    }

    accountBalances[sender] = accountBalances[sender].sub(amount);
    accountBalances[recipient] = accountBalances[recipient].add(amount);

    _emitTransfer(
      sender,
      recipient,
      amount
    );

    if (shouldSyncLPAfter) {
      lpm.syncLP();
    }
  }

  function _updateHoldingBalance(
    address holder,
    uint256 holderBalance,
    uint256 totalHolding
  )
    private
  {
    accountBalances[holder] = holderBalance;
    summary.totalHolding = totalHolding;

  }

  function _updateHoldingBalances(
    address holderA,
    uint256 holderABalance,
    address holderB,
    uint256 holderBBalance,
    uint256 totalHolding
  )
    private
  {
    accountBalances[holderA] = holderABalance;
    accountBalances[holderB] = holderBBalance;
    summary.totalHolding = totalHolding;

  }

  function _emitTransfer(
    address sender,
    address recipient,
    uint256 amount
  )
    private
  {
    if (amount != 0) { // when amount is not zero
      emit Transfer(
        sender,
        recipient,
        amount
      );
    }
  }

  function _increaseTotalLP(
    uint256 amount
  )
    private
  {
    if (amount != 0) { // when amount is not zero
      accountBalances[address(lpm)] = accountBalances[address(lpm)].add(amount);

      summary.totalExcluded = summary.totalExcluded.add(amount);
    }
  }

  function _syncLP()
    private
  {
    if (address(lpm) != address(0)) { // if lpm is not the zero address
      lpm.syncLP();
    }
  }

  function _updateTotalRewards()
    private
  {
    // totalRewards = totalSupply - totalExcluded - totalHolding
    uint256 totalRewards = summary.totalSupply
    .sub(summary.totalExcluded)
    .sub(summary.totalHolding);

    if (totalRewards != summary.totalRewards) {
      summary.totalRewards = totalRewards;

      emit TotalRewardsUpdated(
        totalRewards
      );
    }
  }

  // private functions (views)

  function _matchTotalSupplyWithFees(
    uint256 totalSupply_,
    uint256 totalFee,
    uint256 burnFee
  )
    private
    view
    returns (uint256, uint256, uint256)
  {
    if (burnFee != 0) {
      uint256 newTotalSupply = totalSupply_.sub(burnFee);

      if (newTotalSupply >= settings.minTotalSupply) {
        totalSupply_ = newTotalSupply;
      } else  { // turn of burn fee
        totalFee = totalFee.sub(burnFee);
        burnFee = 0;
      }
    }

    return (totalSupply_, totalFee, burnFee);
  }


  function _canSyncLP(
    address sender,
    address recipient
  )
    private
    view
    returns (
      bool shouldSyncLPBefore,
      bool shouldSyncLPAfter
    )
  {
    if (address(lpm) != address(0)) { // if lpm is not the zero address
      (shouldSyncLPBefore, shouldSyncLPAfter) = lpm.canSyncLP(
        sender,
        recipient
      );
    }

    return (shouldSyncLPBefore, shouldSyncLPAfter);
  }

  function _calcRewards(
    address account
  )
    private
    view
    returns (uint256 result)
  {
    if (
      !excludedAccounts[account].exists && // only for holders
      summary.totalRewards != 0
    ) {
      result = summary.totalRewards
        .mul(accountBalances[account])
        .div(summary.totalHolding);
    }

    return result;
  }

  function _calcTransferSenderFees(
    uint256 amount
  )
    private
    view
    returns (
      uint256 totalFee,
      uint256 burnFee,
      uint256 lpFee
    )
  {
    uint256 rewardsFee = amount.percent(settings.rewardsFees.sender);

    lpFee = amount.percent(settings.lpFees.sender);
    burnFee = amount.percent(settings.burnFees.sender);

    totalFee = lpFee.add(rewardsFee).add(burnFee);

    return (totalFee, burnFee, lpFee);
  }

  function _calcTransferRecipientFees(
    uint256 amount
  )
    private
    view
    returns (
      uint256 totalFee,
      uint256 burnFee,
      uint256 lpFee
    )
  {
    uint256 rewardsFee = amount.percent(settings.rewardsFees.recipient);

    lpFee = amount.percent(settings.lpFees.recipient);
    burnFee = amount.percent(settings.burnFees.recipient);

    totalFee = lpFee.add(rewardsFee).add(burnFee);

    return (totalFee, burnFee, lpFee);
  }

  // private functions (pure)

  function _verifyFees(
    Fees memory burnFees,
    Fees memory lpFees,
    Fees memory rewardsFees
  )
    private
    pure
  {
    uint256 totalFee = burnFees.sender.add(
      burnFees.recipient
    ).add(
      lpFees.sender.add(lpFees.recipient)
    ).add(
      rewardsFees.sender.add(rewardsFees.recipient)
    );

    require(
      totalFee <= MAX_FEE,
      "MetaheroToken#26" // the total fee is too high
    );
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

/**
 * @title Controlled
 *
 * @author Stanisław Głogowski <[email protected]>
 */
contract Controlled {
  /**
   * @return controller address
   */
  address public controller;

  // modifiers

  /**
   * @dev Throws if msg.sender is not the controller
   */
  modifier onlyController() {
    require(
      msg.sender == controller,
      "Controlled#1" // msg.sender is not the controller
    );

    _;
  }

  // events

  /**
   * @dev Emitted when the controller is updated
   * @param controller new controller address
   */
  event ControllerUpdated(
    address controller
  );

  // internal functions

  function _initializeController(
    address controller_
  )
    internal
  {
    controller = controller_;
  }

  function _setController(
    address controller_
  )
    internal
  {
    require(
      controller_ != address(0),
      "Controlled#2" // controller is the zero address
    );

    require(
      controller_ != controller,
      "Controlled#3" // does not update the controller
    );

    controller = controller_;

    emit ControllerUpdated(
      controller_
    );
  }

  function _removeController()
    internal
  {
    require(
      controller != address(0),
      "Controlled#4" // controller is the zero address
    );

    controller = address(0);

    emit ControllerUpdated(
      address(0)
    );
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./IERC20.sol";


/**
 * @title ERC20 abstract token
 *
 * @author Stanisław Głogowski <[email protected]>
 */
abstract contract ERC20 is IERC20 {
  string public override name;
  string public override symbol;
  uint8 public override decimals;

  /**
   * @dev Internal constructor
   * @param name_ name
   * @param symbol_ symbol
   * @param decimals_ decimals amount
   */
  constructor (
    string memory name_,
    string memory symbol_,
    uint8 decimals_
  )
  {
    name = name_;
    symbol = symbol_;
    decimals = decimals_;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./SafeMathLib.sol";


/**
 * @title Math library
 *
 * @author Stanisław Głogowski <[email protected]>
 */
library MathLib {
  using SafeMathLib for uint256;

  // internal functions (pure)

  /**
   * @notice Calcs a x p / 100
   */
  function percent(
    uint256 a,
    uint256 p
  )
    internal
    pure
    returns (uint256 result)
  {
    if (a != 0 && p != 0) {
      result = a.mul(p).div(100);
    }

    return result;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

/**
 * @title Metahero DAO interface
 *
 * @author Stanisław Głogowski <[email protected]>
 */
interface IMetaheroDAO {
  // external functions

  /**
   * @notice Called by a token to sync a dao member
   * @param member member address
   * @param memberWeight member weight
   * @param totalWeight all members weight
   */
  function syncMember(
    address member,
    uint256 memberWeight,
    uint256 totalWeight
  )
    external;

  /**
   * @notice Called by a token to sync a dao members
   * @param memberA member A address
   * @param memberAWeight member A weight
   * @param memberB member B address
   * @param memberBWeight member B weight
   * @param totalWeight all members weight
   */
  function syncMembers(
    address memberA,
    uint256 memberAWeight,
    address memberB,
    uint256 memberBWeight,
    uint256 totalWeight
  )
    external;
}