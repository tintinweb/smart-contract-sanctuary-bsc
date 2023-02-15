// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Simple single owner authorization mixin.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/Owned.sol)
abstract contract Owned {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event OwnershipTransferred(address indexed user, address indexed newOwner);

    /*//////////////////////////////////////////////////////////////
                            OWNERSHIP STORAGE
    //////////////////////////////////////////////////////////////*/

    address public owner;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _owner) {
        owner = _owner;

        emit OwnershipTransferred(address(0), _owner);
    }

    /*//////////////////////////////////////////////////////////////
                             OWNERSHIP LOGIC
    //////////////////////////////////////////////////////////////*/

    function transferOwnership(address newOwner) public virtual onlyOwner {
        owner = newOwner;

        emit OwnershipTransferred(msg.sender, newOwner);
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import {Owned} from "lib/solmate/src/auth/Owned.sol";
import {B3ERC20Lib} from "./libraries/B3ERC20Lib.sol";
import {B3TokenLib} from "./libraries/B3TokenLib.sol";
import {Token} from "./libraries/Types.sol";
import {TokenErrors} from "./libraries/Errors.sol";
import {IB3Token} from "./interfaces/IB3Token.sol";

contract B3Token is IB3Token, Owned {
  using B3TokenLib for mapping(address => Token.Details);
  using B3ERC20Lib for address;

  mapping(address => Token.Details) public override getTokenDetails;

  constructor(address owner_) Owned(owner_) {}

  // View functions ----------------------------------------
  function getTokenInfo(address token)
    external
    view
    override
    returns (
      uint256 price,
      uint256 decimals,
      uint256 deviation
    )
  {
    if (!isTokenAvailable(token)) revert TokenErrors.TokenNotExits(token);

    decimals = token.decimals();
    (price, deviation) = getTokenDetails.priceOf(token);
  }

  function getTokenSymbol(address token) external view override returns (string memory) {
    return token.symbol();
  }

  function getTokenDecimals(address token) external view override returns (uint256) {
    return token.decimals();
  }

  function userTokenBalance(address user, address token)
    public
    view
    override
    returns (uint256)
  {
    return token.balanceOf(user);
  }

  function userTokenAllowance(
    address user,
    address token,
    address spender
  ) public view override returns (uint256) {
    return token.allowance(user, spender);
  }

  function userTokenInfo(
    address user,
    address token,
    address spender
  )
    external
    view
    override
    returns (
      string memory symbol,
      uint256 decimals,
      uint256 balance,
      uint256 allowance,
      uint256 price,
      uint256 deviation
    )
  {
    symbol = token.symbol();
    decimals = token.decimals();
    balance = token.balanceOf(user);
    allowance = token.allowance(user, spender);
    (price, deviation) = getTokenDetails.priceOf(token);
  }

  function isTokenAvailable(address token) public view override returns (bool) {
    return getTokenDetails.isAvailable(token);
  }

  // Modify functions ---------------------------------------
  function addToken(address token, Token.Details calldata details) public onlyOwner {
    if (isTokenAvailable(token)) revert TokenErrors.TokenExits(token);

    uint256 id = getTokenDetails.add(token, details);

    emit NewToken(token, id, details.feed);
  }

  function updateToken(address token, Token.Details calldata details) external onlyOwner {
    if (!isTokenAvailable(token)) revert TokenErrors.TokenNotExits(token);

    uint256 id = getTokenDetails.update(token, details);

    emit UpdateToken(token, id, details.feed);
  }

  function removeToken(address token) external onlyOwner {
    uint256 id = getTokenDetails.remove(token);

    emit RemoveToken(token, id);
  }

  function batchAddToken(
    address[] memory tokenArray,
    Token.Details[] calldata tokenParams
  ) external onlyOwner {
    if (tokenArray.length != tokenParams.length) revert TokenErrors.InvalidInputLength();
    for (uint256 i = 0; i < tokenArray.length; i++) {
      addToken(tokenArray[i], tokenParams[i]);
    }
  }

  function batchRemoveToken(address[] memory tokenArray) external onlyOwner {
    for (uint256 i = 0; i < tokenArray.length; i++) {
      address token = tokenArray[i];

      uint256 id = getTokenDetails.remove(token);

      emit RemoveToken(token, id);
    }
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IAggregator {
  function latestAnswer() external view returns (int256);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;
import {Token} from "src/libraries/Types.sol";

interface IB3Token {
  event NewToken(address token, uint256 id, address feed);
  event UpdateToken(address token, uint256 id, address feed);
  event RemoveToken(address token, uint256 id);

  function getTokenDetails(address token)
    external
    view
    returns (
      uint24 id,
      address feed,
      uint8 decimals,
      uint16 deviation,
      uint32 twapInterval,
      Token.Status status,
      Token.Category category
    );

  function getTokenSymbol(address token) external view returns (string memory);

  function getTokenDecimals(address token) external view returns (uint256);

  function getTokenInfo(address token)
    external
    view
    returns (
      uint256 price,
      uint256 decimals,
      uint256 deviation
    );

  function userTokenBalance(address user, address token) external view returns (uint256);

  function userTokenAllowance(
    address user,
    address token,
    address spender
  ) external view returns (uint256);

  function userTokenInfo(
    address token,
    address user,
    address spender
  )
    external
    view
    returns (
      string memory symbol,
      uint256 decimals,
      uint256 balance,
      uint256 allowance,
      uint256 price,
      uint256 deviation
    );

  function isTokenAvailable(address token) external view returns (bool);
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Minimal ERC20 interface for Uniswap
/// @notice Contains a subset of the full ERC20 interface that is used in Uniswap V3
interface IERC20 {
  /// @notice Returns the symbol of the token
  /// @return The symbol of the token
  function symbol() external view returns (string memory);

  /// @notice Returns the number of decimals used to get its user representation
  /// @return The number of decimals
  function decimals() external view returns (uint8);

  /// @notice Returns the balance of a token
  /// @param account The account for which to look up the number of tokens it has, i.e. its balance
  /// @return The number of tokens held by the account
  function balanceOf(address account) external view returns (uint256);

  /// @notice Transfers the amount of token from the `msg.sender` to the recipient
  /// @param recipient The account that will receive the amount transferred
  /// @param amount The number of tokens to send from the sender to the recipient
  /// @return Returns true for a successful transfer, false for an unsuccessful transfer
  function transfer(address recipient, uint256 amount) external returns (bool);

  /// @notice Returns the current allowance given to a spender by an owner
  /// @param owner The account of the token owner
  /// @param spender The account of the token spender
  /// @return The current allowance granted by `owner` to `spender`
  function allowance(address owner, address spender) external view returns (uint256);

  /// @notice Sets the allowance of a spender from the `msg.sender` to the value `amount`
  /// @param spender The account which will be allowed to spend a given amount of the owners tokens
  /// @param amount The amount of tokens allowed to be used by `spender`
  /// @return Returns true for a successful approval, false for unsuccessful
  function approve(address spender, uint256 amount) external returns (bool);

  /// @notice Transfers `amount` tokens from `sender` to `recipient` up to the allowance given to the `msg.sender`
  /// @param sender The account from which the transfer will be initiated
  /// @param recipient The recipient of the transfer
  /// @param amount The amount of the transfer
  /// @return Returns true for a successful transfer, false for unsuccessful
  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IPermit2 {
  struct TokenPermissions {
    address token;
    uint256 amount;
  }

  struct PermitTransferFrom {
    TokenPermissions permitted;
    uint256 nonce;
    uint256 deadline;
  }

  struct PermitBatchTransferFrom {
    TokenPermissions[] permitted;
    uint256 nonce;
    uint256 deadline;
  }

  struct SignatureTransferDetails {
    address to;
    uint256 requestedAmount;
  }

  function permitTransferFrom(
    PermitBatchTransferFrom calldata permit,
    SignatureTransferDetails[] calldata transferDetails,
    address owner,
    bytes calldata signature
  ) external;

  function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IUniswapV2TWAP {
  function consult(address token, uint amountIn) external view returns (uint amountOut);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IUniswapV3Pool {
  function slot0()
    external
    view
    returns (
      uint160 sqrtPriceX96,
      int24 tick,
      uint16 observationIndex,
      uint16 observationCardinality,
      uint16 observationCardinalityNext,
      uint8 feeProtocol,
      bool unlocked
    );

  function observations(
    uint256 index
  )
    external
    view
    returns (
      uint32 blockTimestamp,
      int56 tickCumulative,
      uint160 secondsPerLiquidityCumulativeX128,
      bool initialized
    );

  function observe(
    uint32[] calldata secondsAgos
  )
    external
    view
    returns (
      int56[] memory tickCumulatives,
      uint160[] memory secondsPerLiquidityCumulativeX128s
    );

  function token0() external view returns (address);

  function token1() external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "src/interfaces/IERC20.sol";
import "./Errors.sol";

// make a library for addresses that can use for permit2
library B3ERC20Lib {
  function symbol(address token) internal view returns (string memory) {
    if (token == address(0)) return "ETH";

    (bool success, bytes memory data) = token.staticcall(
      abi.encodeWithSelector(IERC20.symbol.selector)
    );

    if (!success && data.length < 32) revert TokenErrors.InvalidToken(token);

    return abi.decode(data, (string));
  }

  function decimals(address token) internal view returns (uint256) {
    if (token == address(0)) return 18;

    (bool success, bytes memory data) = token.staticcall(
      abi.encodeWithSelector(IERC20.decimals.selector)
    );

    if (!success && data.length < 32) revert TokenErrors.InvalidToken(token);

    return abi.decode(data, (uint256));
  }

  function balanceOf(address token, address user) internal view returns (uint256) {
    if (token == address(0)) return user.balance;

    (bool success, bytes memory data) = token.staticcall(
      abi.encodeWithSelector(IERC20.balanceOf.selector, user)
    );

    if (!success && data.length < 32) revert TokenErrors.InvalidToken(token);

    return abi.decode(data, (uint256));
  }

  function allowance(
    address token,
    address user,
    address spender
  ) internal view returns (uint256) {
    if (token == address(0)) return type(uint256).max;

    (bool success, bytes memory data) = token.staticcall(
      abi.encodeWithSelector(IERC20.allowance.selector, user, spender)
    );

    if (!success && data.length < 32) revert TokenErrors.InvalidToken(token);

    return abi.decode(data, (uint256));
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "src/interfaces/IAggregator.sol";
import "src/interfaces/IUniswapV3Pool.sol";
import "src/interfaces/IUniswapV2TWAP.sol";
import "src/libraries/SafeTick.sol";
import {Token} from "src/libraries/Types.sol";
import {TokenErrors} from "src/libraries/Errors.sol";

// make a library for addresses that can use for permit2
library B3TokenLib {
  using SafeTick for int24;

  uint128 private constant Q96 = 2**96;

  function add(
    mapping(address => Token.Details) storage self,
    address token,
    Token.Details memory details
  ) internal returns (uint256) {
    if (details.feed == address(0)) revert TokenErrors.InvalidToken(token);

    self[token] = details;

    return block.chainid;
  }

  function update(
    mapping(address => Token.Details) storage self,
    address token,
    Token.Details calldata details
  ) internal returns (uint256) {
    if (isAvailable(self, token)) revert TokenErrors.TokenNotExits(token);

    self[token] = details;
    return block.chainid;
  }

  function remove(mapping(address => Token.Details) storage self, address token)
    internal
    returns (uint256)
  {
    if (!isAvailable(self, token)) revert TokenErrors.TokenNotExits(token);

    delete self[token];
    return block.chainid;
  }

  function isAvailable(mapping(address => Token.Details) storage self, address token)
    public
    view
    returns (bool)
  {
    return self[token].feed != address(0);
  }

  function priceOf(mapping(address => Token.Details) storage self, address token)
    internal
    view
    returns (uint256 price, uint256 deviation)
  {
    if (!isAvailable(self, token)) revert TokenErrors.InvalidToken(token);
    if (self[token].status == Token.Status.Locked) revert TokenErrors.LockedToken(token);

    if (self[token].category == Token.Category.Unknown)
      revert TokenErrors.UnknownToken(token);

    if (self[token].category == Token.Category.Oracle) {
      price = fromAggregator(self[token].feed);
    }

    if (self[token].category == Token.Category.UniswapV2) {
      price = fromPool(token, self[token].feed, 10**self[token].decimals);
    }

    if (self[token].category == Token.Category.UniswapV2TWAP) {
      // TODO test this on mainnet
      price = fromV2TWAP(token, self[token].feed, 10**self[token].decimals);
    }

    if (self[token].category == Token.Category.UnisawpV3) {
      price = fromPool(token, self[token].feed, 10**self[token].decimals);
    }

    if (self[token].category == Token.Category.UnisawpV3TWAP) {
      uint256 power = 10**(self[token].decimals + 8);
      price = fromV3TWAP(token, self[token].feed, self[token].twapInterval, power);
    }

    if (price == 0) revert TokenErrors.InvalidToken(token);

    deviation = self[token].deviation;
  }

  function fromAggregator(address feed) private view returns (uint256) {
    (bool success, bytes memory data) = feed.staticcall(
      abi.encodeWithSelector(IAggregator.latestAnswer.selector)
    );

    if (!success && data.length < 32) return 0;

    return uint256(abi.decode(data, (int256)));
  }

  function fromV2TWAP(
    address token,
    address feed,
    uint256 power
  ) private view returns (uint256) {
    uint256 price = IUniswapV2TWAP(feed).consult(token, power);

    return price;
  }

  function fromV3TWAP(
    address token,
    address feed,
    uint32 twapInterval,
    uint256 power
  ) private view returns (uint256) {
    uint256 sqrtPriceX96 = getTWAPSqrtPriceX96(feed, twapInterval);

    address token0 = IUniswapV3Pool(feed).token0();
    address token1 = IUniswapV3Pool(feed).token1();

    uint256 sqrtPrice;
    if (token0 == token) sqrtPrice = (sqrtPriceX96 * power) / Q96;
    else if (token1 == token) sqrtPrice = (Q96 * power) / sqrtPriceX96;
    else revert TokenErrors.InvalidToken(token);

    return (sqrtPrice * sqrtPrice) / power;
  }

  function getTWAPSqrtPriceX96(address feed, uint32 twapInterval)
    public
    view
    returns (uint256)
  {
    uint32[] memory secondsAgos = new uint32[](2);

    twapInterval = twapInterval == 0 ? 10 : twapInterval;

    secondsAgos[0] = twapInterval;

    (int56[] memory tickCumulatives, ) = IUniswapV3Pool(feed).observe(secondsAgos);

    int56 tick = (tickCumulatives[1] - tickCumulatives[0]) / int56(uint56(twapInterval));

    return int24(tick).getSqrtRatioAtTick();
  }

  function fromPoolTick(
    address token,
    address feed,
    uint256 power
  ) private view returns (uint256) {
    (bool success, bytes memory data) = feed.staticcall(
      abi.encodeWithSelector(IUniswapV3Pool.slot0.selector)
    );

    if (!success && data.length < 32) revert TokenErrors.InvalidToken(token);

    (, int24 tick) = abi.decode(data, (uint160, int24));

    uint256 sqrtPriceX96 = tick.getSqrtRatioAtTick();

    address token0 = IUniswapV3Pool(feed).token0();
    address token1 = IUniswapV3Pool(feed).token1();

    uint256 sqrtPrice;
    if (token0 == token) sqrtPrice = (sqrtPriceX96 * power) / Q96;
    else if (token1 == token) sqrtPrice = (Q96 * power) / sqrtPriceX96;
    else revert TokenErrors.InvalidToken(token);

    return (sqrtPrice * sqrtPrice) / power;
  }

  function fromPool(
    address token,
    address feed,
    uint256 power
  ) private view returns (uint256) {
    (bool success, bytes memory data) = feed.staticcall(
      abi.encodeWithSelector(IUniswapV3Pool.slot0.selector)
    );

    if (!success && data.length < 32) revert TokenErrors.InvalidToken(token);

    uint160 sqrtPriceX96 = abi.decode(data, (uint160));

    address token0 = IUniswapV3Pool(feed).token0();

    uint256 sqrtPrice = token0 == token
      ? (sqrtPriceX96 * power) / Q96
      : (Q96 * power) / sqrtPriceX96;

    return (sqrtPrice * sqrtPrice) / power;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

library TokenErrors {
  error TokenExits(address token);
  error TokenNotExits(address token);
  error UnknownToken(address token);
  error InvalidToken(address token);
  error LockedToken(address token);
  error InvalidInputLength();
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IPermit2} from "../interfaces/IPermit2.sol";

// make a library for addresses that can use for permit2
library SafeTick {
  /// @dev The minimum tick that may be passed to #getSqrtRatioAtTick computed from log base 1.0001 of 2**-128
  int24 internal constant MIN_TICK = -887272;
  /// @dev The maximum tick that may be passed to #getSqrtRatioAtTick computed from log base 1.0001 of 2**128
  int24 internal constant MAX_TICK = -MIN_TICK;

  function getSafeTick(int24 tick) private pure returns (uint256 absTick) {
    int256 safeTick = tick < 0 ? -int256(tick) : int256(tick);
    require(safeTick <= MAX_TICK, "T");

    absTick = uint256(safeTick);
  }

  /// @notice Calculates sqrt(1.0001^tick) * 2^96
  /// @dev Throws if |tick| > max tick
  /// @param tick The input tick for the above formula
  /// @return sqrtPriceX96 A Fixed point Q64.96 number representing the sqrt of the ratio of the two assets (token1/token0)
  /// at the given tick
  function getSqrtRatioAtTick(int24 tick) internal pure returns (uint160 sqrtPriceX96) {
    uint256 absTick = getSafeTick(tick);

    uint256 ratio = absTick & 0x1 != 0
      ? 0xfffcb933bd6fad37aa2d162d1a594001
      : 0x100000000000000000000000000000000;
    if (absTick & 0x2 != 0) ratio = (ratio * 0xfff97272373d413259a46990580e213a) >> 128;
    if (absTick & 0x4 != 0) ratio = (ratio * 0xfff2e50f5f656932ef12357cf3c7fdcc) >> 128;
    if (absTick & 0x8 != 0) ratio = (ratio * 0xffe5caca7e10e4e61c3624eaa0941cd0) >> 128;
    if (absTick & 0x10 != 0) ratio = (ratio * 0xffcb9843d60f6159c9db58835c926644) >> 128;
    if (absTick & 0x20 != 0) ratio = (ratio * 0xff973b41fa98c081472e6896dfb254c0) >> 128;
    if (absTick & 0x40 != 0) ratio = (ratio * 0xff2ea16466c96a3843ec78b326b52861) >> 128;
    if (absTick & 0x80 != 0) ratio = (ratio * 0xfe5dee046a99a2a811c461f1969c3053) >> 128;
    if (absTick & 0x100 != 0) ratio = (ratio * 0xfcbe86c7900a88aedcffc83b479aa3a4) >> 128;
    if (absTick & 0x200 != 0) ratio = (ratio * 0xf987a7253ac413176f2b074cf7815e54) >> 128;
    if (absTick & 0x400 != 0) ratio = (ratio * 0xf3392b0822b70005940c7a398e4b70f3) >> 128;
    if (absTick & 0x800 != 0) ratio = (ratio * 0xe7159475a2c29b7443b29c7fa6e889d9) >> 128;
    if (absTick & 0x1000 != 0)
      ratio = (ratio * 0xd097f3bdfd2022b8845ad8f792aa5825) >> 128;
    if (absTick & 0x2000 != 0)
      ratio = (ratio * 0xa9f746462d870fdf8a65dc1f90e061e5) >> 128;
    if (absTick & 0x4000 != 0)
      ratio = (ratio * 0x70d869a156d2a1b890bb3df62baf32f7) >> 128;
    if (absTick & 0x8000 != 0)
      ratio = (ratio * 0x31be135f97d08fd981231505542fcfa6) >> 128;
    if (absTick & 0x10000 != 0)
      ratio = (ratio * 0x9aa508b5b7a84e1c677de54f3e99bc9) >> 128;
    if (absTick & 0x20000 != 0) ratio = (ratio * 0x5d6af8dedb81196699c329225ee604) >> 128;
    if (absTick & 0x40000 != 0) ratio = (ratio * 0x2216e584f5fa1ea926041bedfe98) >> 128;
    if (absTick & 0x80000 != 0) ratio = (ratio * 0x48a170391f7dc42444e8fa2) >> 128;

    if (tick > 0) ratio = type(uint256).max / ratio;

    // this divides by 1<<32 rounding up to go from a Q128.128 to a Q128.96.
    // we then downcast because we know the result always fits within 160 bits due to our tick input constraint
    // we round up in the division so getTickAtSqrtRatio of the output price is always consistent
    sqrtPriceX96 = uint160((ratio >> 32) + (ratio % (1 << 32) == 0 ? 0 : 1));
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

library Token {
  enum Status {
    Locked,
    Unlocked
  }

  enum Category {
    Unknown,
    Oracle,
    UnisawpV3,
    UnisawpV3TWAP,
    UniswapV2,
    UniswapV2TWAP
  }

  struct Details {
    uint24 id;
    address feed;
    uint8 decimals;
    uint16 deviation;
    uint32 twapInterval;
    Status status;
    Category category;
  }
}