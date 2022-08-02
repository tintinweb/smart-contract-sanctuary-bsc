// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.7.0;
import "@mertaswap/interfaces/contracts/solidity-utils/helpers/BalancerErrors.sol";
import "./LogExpMath.sol";
/* solhint-disable private-vars-leading-underscore */
library FixedPoint {
  uint256 internal constant ONE = 1e18; // 18 decimal places
  uint256 internal constant TWO = 2 * ONE;
  uint256 internal constant FOUR = 4 * ONE;
  uint256 internal constant MAX_POW_RELATIVE_ERROR = 10000; // 10^(-14)
  uint256 internal constant MIN_POW_BASE_FREE_EXPONENT = 0.7e18;
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    _require(c >= a, Errors.ADD_OVERFLOW);
    return c;
  }
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    _require(b <= a, Errors.SUB_OVERFLOW);
    uint256 c = a - b;
    return c;
  }
  function mulDown(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 product = a * b;
    _require(a == 0 || product / a == b, Errors.MUL_OVERFLOW);
    return product / ONE;
  }
  function mulUp(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 product = a * b;
    _require(a == 0 || product / a == b, Errors.MUL_OVERFLOW);
    if (product == 0) {
      return 0;
    } else {
      return ((product - 1) / ONE) + 1;
    }
  }
  function divDown(uint256 a, uint256 b) internal pure returns (uint256) {
    _require(b != 0, Errors.ZERO_DIVISION);
    if (a == 0) {
      return 0;
    } else {
      uint256 aInflated = a * ONE;
      _require(aInflated / a == ONE, Errors.DIV_INTERNAL); // mul overflow
      return aInflated / b;
    }
  }
  function divUp(uint256 a, uint256 b) internal pure returns (uint256) {
    _require(b != 0, Errors.ZERO_DIVISION);
    if (a == 0) {
      return 0;
    } else {
      uint256 aInflated = a * ONE;
      _require(aInflated / a == ONE, Errors.DIV_INTERNAL); // mul overflow
      return ((aInflated - 1) / b) + 1;
    }
  }
  function powDown(uint256 x, uint256 y) internal pure returns (uint256) {
    if (y == ONE) {
      return x;
    } else if (y == TWO) {
      return mulDown(x, x);
    } else if (y == FOUR) {
      uint256 square = mulDown(x, x);
      return mulDown(square, square);
    } else {
      uint256 raw = LogExpMath.pow(x, y);
      uint256 maxError = add(mulUp(raw, MAX_POW_RELATIVE_ERROR), 1);
      if (raw < maxError) {
        return 0;
      } else {
        return sub(raw, maxError);
      }
    }
  }
  function powUp(uint256 x, uint256 y) internal pure returns (uint256) {
    if (y == ONE) {
      return x;
    } else if (y == TWO) {
      return mulUp(x, x);
    } else if (y == FOUR) {
      uint256 square = mulUp(x, x);
      return mulUp(square, square);
    } else {
      uint256 raw = LogExpMath.pow(x, y);
      uint256 maxError = add(mulUp(raw, MAX_POW_RELATIVE_ERROR), 1);
      return add(raw, maxError);
    }
  }
  function complement(uint256 x) internal pure returns (uint256) {
    return (x < ONE) ? (ONE - x) : 0;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
import "@mertaswap/interfaces/contracts/solidity-utils/helpers/BalancerErrors.sol";
library Math {
  function abs(int256 a) internal pure returns (uint256) {
    return a > 0 ? uint256(a) : uint256(-a);
  }
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    _require(c >= a, Errors.ADD_OVERFLOW);
    return c;
  }
  function add(int256 a, int256 b) internal pure returns (int256) {
    int256 c = a + b;
    _require((b >= 0 && c >= a) || (b < 0 && c < a), Errors.ADD_OVERFLOW);
    return c;
  }
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    _require(b <= a, Errors.SUB_OVERFLOW);
    uint256 c = a - b;
    return c;
  }
  function sub(int256 a, int256 b) internal pure returns (int256) {
    int256 c = a - b;
    _require((b >= 0 && c <= a) || (b < 0 && c > a), Errors.SUB_OVERFLOW);
    return c;
  }
  function max(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }
  function min(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    _require(a == 0 || c / a == b, Errors.MUL_OVERFLOW);
    return c;
  }
  function div(
    uint256 a,
    uint256 b,
    bool roundUp
  ) internal pure returns (uint256) {
    return roundUp ? divUp(a, b) : divDown(a, b);
  }
  function divDown(uint256 a, uint256 b) internal pure returns (uint256) {
    _require(b != 0, Errors.ZERO_DIVISION);
    return a / b;
  }
  function divUp(uint256 a, uint256 b) internal pure returns (uint256) {
    _require(b != 0, Errors.ZERO_DIVISION);
    if (a == 0) {
      return 0;
    } else {
      return 1 + (a - 1) / b;
    }
  }
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.7.0;

function _require(bool condition, uint256 errorCode) pure {
  if (!condition) _revert(errorCode);
}

function _revert(uint256 errorCode) pure {
  assembly {
    let units := add(mod(errorCode, 10), 0x30)
    errorCode := div(errorCode, 10)
    let tenths := add(mod(errorCode, 10), 0x30)
    errorCode := div(errorCode, 10)
    let hundreds := add(mod(errorCode, 10), 0x30)
    let revertReason := shl(200, add(0x42414c23000000, add(add(units, shl(8, tenths)), shl(16, hundreds))))
    mstore(0x0, 0x08c379a000000000000000000000000000000000000000000000000000000000)
    mstore(0x04, 0x0000000000000000000000000000000000000000000000000000000000000020)
    mstore(0x24, 7)
    mstore(0x44, revertReason)
    revert(0, 100)
  }
}

library Errors {
  // Math
  uint256 internal constant ADD_OVERFLOW = 0;
  uint256 internal constant SUB_OVERFLOW = 1;
  uint256 internal constant SUB_UNDERFLOW = 2;
  uint256 internal constant MUL_OVERFLOW = 3;
  uint256 internal constant ZERO_DIVISION = 4;
  uint256 internal constant DIV_INTERNAL = 5;
  uint256 internal constant X_OUT_OF_BOUNDS = 6;
  uint256 internal constant Y_OUT_OF_BOUNDS = 7;
  uint256 internal constant PRODUCT_OUT_OF_BOUNDS = 8;
  uint256 internal constant INVALID_EXPONENT = 9;

  // Input
  uint256 internal constant OUT_OF_BOUNDS = 100;
  uint256 internal constant UNSORTED_ARRAY = 101;
  uint256 internal constant UNSORTED_TOKENS = 102;
  uint256 internal constant INPUT_LENGTH_MISMATCH = 103;
  uint256 internal constant ZERO_TOKEN = 104;

  // Shared pools
  uint256 internal constant MIN_TOKENS = 200;
  uint256 internal constant MAX_TOKENS = 201;
  uint256 internal constant MAX_SWAP_FEE_PERCENTAGE = 202;
  uint256 internal constant MIN_SWAP_FEE_PERCENTAGE = 203;
  uint256 internal constant MINIMUM_BPT = 204;
  uint256 internal constant CALLER_NOT_VAULT = 205;
  uint256 internal constant UNINITIALIZED = 206;
  uint256 internal constant BPT_IN_MAX_AMOUNT = 207;
  uint256 internal constant BPT_OUT_MIN_AMOUNT = 208;
  uint256 internal constant EXPIRED_PERMIT = 209;
  uint256 internal constant NOT_TWO_TOKENS = 210;
  uint256 internal constant DISABLED = 211;

  // Pools
  uint256 internal constant MIN_AMP = 300;
  uint256 internal constant MAX_AMP = 301;
  uint256 internal constant MIN_WEIGHT = 302;
  uint256 internal constant MAX_STABLE_TOKENS = 303;
  uint256 internal constant MAX_IN_RATIO = 304;
  uint256 internal constant MAX_OUT_RATIO = 305;
  uint256 internal constant MIN_BPT_IN_FOR_TOKEN_OUT = 306;
  uint256 internal constant MAX_OUT_BPT_FOR_TOKEN_IN = 307;
  uint256 internal constant NORMALIZED_WEIGHT_INVARIANT = 308;
  uint256 internal constant INVALID_TOKEN = 309;
  uint256 internal constant UNHANDLED_JOIN_KIND = 310;
  uint256 internal constant ZERO_INVARIANT = 311;
  uint256 internal constant ORACLE_INVALID_SECONDS_QUERY = 312;
  uint256 internal constant ORACLE_NOT_INITIALIZED = 313;
  uint256 internal constant ORACLE_QUERY_TOO_OLD = 314;
  uint256 internal constant ORACLE_INVALID_INDEX = 315;
  uint256 internal constant ORACLE_BAD_SECS = 316;
  uint256 internal constant AMP_END_TIME_TOO_CLOSE = 317;
  uint256 internal constant AMP_ONGOING_UPDATE = 318;
  uint256 internal constant AMP_RATE_TOO_HIGH = 319;
  uint256 internal constant AMP_NO_ONGOING_UPDATE = 320;
  uint256 internal constant STABLE_INVARIANT_DIDNT_CONVERGE = 321;
  uint256 internal constant STABLE_GET_BALANCE_DIDNT_CONVERGE = 322;
  uint256 internal constant RELAYER_NOT_CONTRACT = 323;
  uint256 internal constant BASE_POOL_RELAYER_NOT_CALLED = 324;
  uint256 internal constant REBALANCING_RELAYER_REENTERED = 325;
  uint256 internal constant GRADUAL_UPDATE_TIME_TRAVEL = 326;
  uint256 internal constant SWAPS_DISABLED = 327;
  uint256 internal constant CALLER_IS_NOT_LBP_OWNER = 328;
  uint256 internal constant PRICE_RATE_OVERFLOW = 329;
  uint256 internal constant INVALID_JOIN_EXIT_KIND_WHILE_SWAPS_DISABLED = 330;
  uint256 internal constant WEIGHT_CHANGE_TOO_FAST = 331;
  uint256 internal constant LOWER_GREATER_THAN_UPPER_TARGET = 332;
  uint256 internal constant UPPER_TARGET_TOO_HIGH = 333;
  uint256 internal constant UNHANDLED_BY_LINEAR_POOL = 334;
  uint256 internal constant OUT_OF_TARGET_RANGE = 335;
  uint256 internal constant UNHANDLED_EXIT_KIND = 336;
  uint256 internal constant UNAUTHORIZED_EXIT = 337;
  uint256 internal constant MAX_MANAGEMENT_SWAP_FEE_PERCENTAGE = 338;
  uint256 internal constant UNHANDLED_BY_MANAGED_POOL = 339;
  uint256 internal constant UNHANDLED_BY_PHANTOM_POOL = 340;
  uint256 internal constant TOKEN_DOES_NOT_HAVE_RATE_PROVIDER = 341;
  uint256 internal constant INVALID_INITIALIZATION = 342;
  uint256 internal constant OUT_OF_NEW_TARGET_RANGE = 343;
  uint256 internal constant FEATURE_DISABLED = 344;
  uint256 internal constant UNINITIALIZED_POOL_CONTROLLER = 345;
  uint256 internal constant SET_SWAP_FEE_DURING_FEE_CHANGE = 346;
  uint256 internal constant SET_SWAP_FEE_PENDING_FEE_CHANGE = 347;
  uint256 internal constant CHANGE_TOKENS_DURING_WEIGHT_CHANGE = 348;
  uint256 internal constant CHANGE_TOKENS_PENDING_WEIGHT_CHANGE = 349;
  uint256 internal constant MAX_WEIGHT = 350;
  uint256 internal constant UNAUTHORIZED_JOIN = 351;
  uint256 internal constant MAX_MANAGEMENT_AUM_FEE_PERCENTAGE = 352;

  // Lib
  uint256 internal constant REENTRANCY = 400;
  uint256 internal constant SENDER_NOT_ALLOWED = 401;
  uint256 internal constant PAUSED = 402;
  uint256 internal constant PAUSE_WINDOW_EXPIRED = 403;
  uint256 internal constant MAX_PAUSE_WINDOW_DURATION = 404;
  uint256 internal constant MAX_BUFFER_PERIOD_DURATION = 405;
  uint256 internal constant INSUFFICIENT_BALANCE = 406;
  uint256 internal constant INSUFFICIENT_ALLOWANCE = 407;
  uint256 internal constant ERC20_TRANSFER_FROM_ZERO_ADDRESS = 408;
  uint256 internal constant ERC20_TRANSFER_TO_ZERO_ADDRESS = 409;
  uint256 internal constant ERC20_MINT_TO_ZERO_ADDRESS = 410;
  uint256 internal constant ERC20_BURN_FROM_ZERO_ADDRESS = 411;
  uint256 internal constant ERC20_APPROVE_FROM_ZERO_ADDRESS = 412;
  uint256 internal constant ERC20_APPROVE_TO_ZERO_ADDRESS = 413;
  uint256 internal constant ERC20_TRANSFER_EXCEEDS_ALLOWANCE = 414;
  uint256 internal constant ERC20_DECREASED_ALLOWANCE_BELOW_ZERO = 415;
  uint256 internal constant ERC20_TRANSFER_EXCEEDS_BALANCE = 416;
  uint256 internal constant ERC20_BURN_EXCEEDS_ALLOWANCE = 417;
  uint256 internal constant SAFE_ERC20_CALL_FAILED = 418;
  uint256 internal constant ADDRESS_INSUFFICIENT_BALANCE = 419;
  uint256 internal constant ADDRESS_CANNOT_SEND_VALUE = 420;
  uint256 internal constant SAFE_CAST_VALUE_CANT_FIT_INT256 = 421;
  uint256 internal constant GRANT_SENDER_NOT_ADMIN = 422;
  uint256 internal constant REVOKE_SENDER_NOT_ADMIN = 423;
  uint256 internal constant RENOUNCE_SENDER_NOT_ALLOWED = 424;
  uint256 internal constant BUFFER_PERIOD_EXPIRED = 425;
  uint256 internal constant CALLER_IS_NOT_OWNER = 426;
  uint256 internal constant NEW_OWNER_IS_ZERO = 427;
  uint256 internal constant CODE_DEPLOYMENT_FAILED = 428;
  uint256 internal constant CALL_TO_NON_CONTRACT = 429;
  uint256 internal constant LOW_LEVEL_CALL_FAILED = 430;
  uint256 internal constant NOT_PAUSED = 431;
  uint256 internal constant ADDRESS_ALREADY_ALLOWLISTED = 432;
  uint256 internal constant ADDRESS_NOT_ALLOWLISTED = 433;
  uint256 internal constant ERC20_BURN_EXCEEDS_BALANCE = 434;
  uint256 internal constant INVALID_OPERATION = 435;
  uint256 internal constant CODEC_OVERFLOW = 436;
  uint256 internal constant IN_RECOVERY_MODE = 437;
  uint256 internal constant NOT_IN_RECOVERY_MODE = 438;
  uint256 internal constant INDUCED_FAILURE = 439;
  uint256 internal constant EXPIRED_SIGNATURE = 440;
  uint256 internal constant MALFORMED_SIGNATURE = 441;

  // Vault
  uint256 internal constant INVALID_POOL_ID = 500;
  uint256 internal constant CALLER_NOT_POOL = 501;
  uint256 internal constant SENDER_NOT_ASSET_MANAGER = 502;
  uint256 internal constant USER_DOESNT_ALLOW_RELAYER = 503;
  uint256 internal constant INVALID_SIGNATURE = 504;
  uint256 internal constant EXIT_BELOW_MIN = 505;
  uint256 internal constant JOIN_ABOVE_MAX = 506;
  uint256 internal constant SWAP_LIMIT = 507;
  uint256 internal constant SWAP_DEADLINE = 508;
  uint256 internal constant CANNOT_SWAP_SAME_TOKEN = 509;
  uint256 internal constant UNKNOWN_AMOUNT_IN_FIRST_SWAP = 510;
  uint256 internal constant MALCONSTRUCTED_MULTIHOP_SWAP = 511;
  uint256 internal constant INTERNAL_BALANCE_OVERFLOW = 512;
  uint256 internal constant INSUFFICIENT_INTERNAL_BALANCE = 513;
  uint256 internal constant INVALID_ETH_INTERNAL_BALANCE = 514;
  uint256 internal constant INVALID_POST_LOAN_BALANCE = 515;
  uint256 internal constant INSUFFICIENT_ETH = 516;
  uint256 internal constant UNALLOCATED_ETH = 517;
  uint256 internal constant ETH_TRANSFER = 518;
  uint256 internal constant CANNOT_USE_ETH_SENTINEL = 519;
  uint256 internal constant TOKENS_MISMATCH = 520;
  uint256 internal constant TOKEN_NOT_REGISTERED = 521;
  uint256 internal constant TOKEN_ALREADY_REGISTERED = 522;
  uint256 internal constant TOKENS_ALREADY_SET = 523;
  uint256 internal constant TOKENS_LENGTH_MUST_BE_2 = 524;
  uint256 internal constant NONZERO_TOKEN_BALANCE = 525;
  uint256 internal constant BALANCE_TOTAL_OVERFLOW = 526;
  uint256 internal constant POOL_NO_TOKENS = 527;
  uint256 internal constant INSUFFICIENT_FLASH_LOAN_BALANCE = 528;

  // Fees
  uint256 internal constant SWAP_FEE_PERCENTAGE_TOO_HIGH = 600;
  uint256 internal constant FLASH_LOAN_FEE_PERCENTAGE_TOO_HIGH = 601;
  uint256 internal constant INSUFFICIENT_FLASH_LOAN_FEE_AMOUNT = 602;
  uint256 internal constant AUM_FEE_PERCENTAGE_TOO_HIGH = 603;

  // Misc
  uint256 internal constant SHOULD_NOT_HAPPEN = 999;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
import "@mertaswap/interfaces/contracts/solidity-utils/helpers/BalancerErrors.sol";
library LogExpMath {
  int256 constant ONE_18 = 1e18;
  int256 constant ONE_20 = 1e20;
  int256 constant ONE_36 = 1e36;
  int256 constant MAX_NATURAL_EXPONENT = 130e18;
  int256 constant MIN_NATURAL_EXPONENT = -41e18;
  int256 constant LN_36_LOWER_BOUND = ONE_18 - 1e17;
  int256 constant LN_36_UPPER_BOUND = ONE_18 + 1e17;
  uint256 constant MILD_EXPONENT_BOUND = 2**254 / uint256(ONE_20);
  int256 constant x0 = 128000000000000000000; // 2ˆ7
  int256 constant a0 = 38877084059945950922200000000000000000000000000000000000; // eˆ(x0) (no decimals)
  int256 constant x1 = 64000000000000000000; // 2ˆ6
  int256 constant a1 = 6235149080811616882910000000; // eˆ(x1) (no decimals)
  int256 constant x2 = 3200000000000000000000; // 2ˆ5
  int256 constant a2 = 7896296018268069516100000000000000; // eˆ(x2)
  int256 constant x3 = 1600000000000000000000; // 2ˆ4
  int256 constant a3 = 888611052050787263676000000; // eˆ(x3)
  int256 constant x4 = 800000000000000000000; // 2ˆ3
  int256 constant a4 = 298095798704172827474000; // eˆ(x4)
  int256 constant x5 = 400000000000000000000; // 2ˆ2
  int256 constant a5 = 5459815003314423907810; // eˆ(x5)
  int256 constant x6 = 200000000000000000000; // 2ˆ1
  int256 constant a6 = 738905609893065022723; // eˆ(x6)
  int256 constant x7 = 100000000000000000000; // 2ˆ0
  int256 constant a7 = 271828182845904523536; // eˆ(x7)
  int256 constant x8 = 50000000000000000000; // 2ˆ-1
  int256 constant a8 = 164872127070012814685; // eˆ(x8)
  int256 constant x9 = 25000000000000000000; // 2ˆ-2
  int256 constant a9 = 128402541668774148407; // eˆ(x9)
  int256 constant x10 = 12500000000000000000; // 2ˆ-3
  int256 constant a10 = 113314845306682631683; // eˆ(x10)
  int256 constant x11 = 6250000000000000000; // 2ˆ-4
  int256 constant a11 = 106449445891785942956; // eˆ(x11)
  function pow(uint256 x, uint256 y) internal pure returns (uint256) {
    if (y == 0) {
      return uint256(ONE_18);
    }
    if (x == 0) {
      return 0;
    }
    _require(x >> 255 == 0, Errors.X_OUT_OF_BOUNDS);
    int256 x_int256 = int256(x);
    _require(y < MILD_EXPONENT_BOUND, Errors.Y_OUT_OF_BOUNDS);
    int256 y_int256 = int256(y);
    int256 logx_times_y;
    if (LN_36_LOWER_BOUND < x_int256 && x_int256 < LN_36_UPPER_BOUND) {
      int256 ln_36_x = _ln_36(x_int256);      logx_times_y = ((ln_36_x / ONE_18) * y_int256 + ((ln_36_x % ONE_18) * y_int256) / ONE_18);
    } else {
      logx_times_y = _ln(x_int256) * y_int256;
    }
    logx_times_y /= ONE_18;    _require(
      MIN_NATURAL_EXPONENT <= logx_times_y && logx_times_y <= MAX_NATURAL_EXPONENT,
      Errors.PRODUCT_OUT_OF_BOUNDS
    );    return uint256(exp(logx_times_y));
  }  function exp(int256 x) internal pure returns (int256) {
    _require(x >= MIN_NATURAL_EXPONENT && x <= MAX_NATURAL_EXPONENT, Errors.INVALID_EXPONENT);    if (x < 0) {
      return ((ONE_18 * ONE_18) / exp(-x));
    }    int256 firstAN;
    if (x >= x0) {
      x -= x0;
      firstAN = a0;
    } else if (x >= x1) {
      x -= x1;
      firstAN = a1;
    } else {
      firstAN = 1; // One with no decimal places
    }    x *= 100;    int256 product = ONE_20;    if (x >= x2) {
      x -= x2;
      product = (product * a2) / ONE_20;
    }
    if (x >= x3) {
      x -= x3;
      product = (product * a3) / ONE_20;
    }
    if (x >= x4) {
      x -= x4;
      product = (product * a4) / ONE_20;
    }
    if (x >= x5) {
      x -= x5;
      product = (product * a5) / ONE_20;
    }
    if (x >= x6) {
      x -= x6;
      product = (product * a6) / ONE_20;
    }
    if (x >= x7) {
      x -= x7;
      product = (product * a7) / ONE_20;
    }
    if (x >= x8) {
      x -= x8;
      product = (product * a8) / ONE_20;
    }
    if (x >= x9) {
      x -= x9;
      product = (product * a9) / ONE_20;
    }    int256 seriesSum = ONE_20; // The initial one in the sum, with 20 decimal places.
    int256 term; // Each term in the sum, where the nth term is (x^n / n!).    term = x;
    seriesSum += term;    term = ((term * x) / ONE_20) / 2;
    seriesSum += term;    term = ((term * x) / ONE_20) / 3;
    seriesSum += term;    term = ((term * x) / ONE_20) / 4;
    seriesSum += term;    term = ((term * x) / ONE_20) / 5;
    seriesSum += term;    term = ((term * x) / ONE_20) / 6;
    seriesSum += term;    term = ((term * x) / ONE_20) / 7;
    seriesSum += term;    term = ((term * x) / ONE_20) / 8;
    seriesSum += term;    term = ((term * x) / ONE_20) / 9;
    seriesSum += term;    term = ((term * x) / ONE_20) / 10;
    seriesSum += term;    term = ((term * x) / ONE_20) / 11;
    seriesSum += term;    term = ((term * x) / ONE_20) / 12;
    seriesSum += term;    return (((product * seriesSum) / ONE_20) * firstAN) / 100;
  }  function log(int256 arg, int256 base) internal pure returns (int256) {
    int256 logBase;
    if (LN_36_LOWER_BOUND < base && base < LN_36_UPPER_BOUND) {
      logBase = _ln_36(base);
    } else {
      logBase = _ln(base) * ONE_18;
    }    int256 logArg;
    if (LN_36_LOWER_BOUND < arg && arg < LN_36_UPPER_BOUND) {
      logArg = _ln_36(arg);
    } else {
      logArg = _ln(arg) * ONE_18;
    }    return (logArg * ONE_18) / logBase;
  }  function ln(int256 a) internal pure returns (int256) {
    _require(a > 0, Errors.OUT_OF_BOUNDS);
    if (LN_36_LOWER_BOUND < a && a < LN_36_UPPER_BOUND) {
      return _ln_36(a) / ONE_18;
    } else {
      return _ln(a);
    }
  }  function _ln(int256 a) private pure returns (int256) {
    if (a < ONE_18) {
      return (-_ln((ONE_18 * ONE_18) / a));
    }    int256 sum = 0;
    if (a >= a0 * ONE_18) {
      a /= a0; // Integer, not fixed point division
      sum += x0;
    }    if (a >= a1 * ONE_18) {
      a /= a1; // Integer, not fixed point division
      sum += x1;
    }    sum *= 100;
    a *= 100;    if (a >= a2) {
      a = (a * ONE_20) / a2;
      sum += x2;
    }    if (a >= a3) {
      a = (a * ONE_20) / a3;
      sum += x3;
    }    if (a >= a4) {
      a = (a * ONE_20) / a4;
      sum += x4;
    }    if (a >= a5) {
      a = (a * ONE_20) / a5;
      sum += x5;
    }    if (a >= a6) {
      a = (a * ONE_20) / a6;
      sum += x6;
    }    if (a >= a7) {
      a = (a * ONE_20) / a7;
      sum += x7;
    }    if (a >= a8) {
      a = (a * ONE_20) / a8;
      sum += x8;
    }    if (a >= a9) {
      a = (a * ONE_20) / a9;
      sum += x9;
    }    if (a >= a10) {
      a = (a * ONE_20) / a10;
      sum += x10;
    }    if (a >= a11) {
      a = (a * ONE_20) / a11;
      sum += x11;
    }    int256 z = ((a - ONE_20) * ONE_20) / (a + ONE_20);
    int256 z_squared = (z * z) / ONE_20;    int256 num = z;    int256 seriesSum = num;    num = (num * z_squared) / ONE_20;
    seriesSum += num / 3;    num = (num * z_squared) / ONE_20;
    seriesSum += num / 5;    num = (num * z_squared) / ONE_20;
    seriesSum += num / 7;    num = (num * z_squared) / ONE_20;
    seriesSum += num / 9;    num = (num * z_squared) / ONE_20;
    seriesSum += num / 11;    seriesSum *= 2;    return (sum + seriesSum) / 100;
  }  function _ln_36(int256 x) private pure returns (int256) {
    x *= ONE_18;    int256 z = ((x - ONE_36) * ONE_36) / (x + ONE_36);
    int256 z_squared = (z * z) / ONE_36;    int256 num = z;    int256 seriesSum = num;    num = (num * z_squared) / ONE_36;
    seriesSum += num / 3;    num = (num * z_squared) / ONE_36;
    seriesSum += num / 5;    num = (num * z_squared) / ONE_36;
    seriesSum += num / 7;    num = (num * z_squared) / ONE_36;
    seriesSum += num / 9;    num = (num * z_squared) / ONE_36;
    seriesSum += num / 11;    num = (num * z_squared) / ONE_36;
    seriesSum += num / 13;    num = (num * z_squared) / ONE_36;
    seriesSum += num / 15;    return seriesSum * 2;
  }
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.7.0;
import "@mertaswap/solidity-utils/contracts/math/Math.sol";
import "@mertaswap/interfaces/contracts/solidity-utils/openzeppelin/IERC20.sol";
import "@mertaswap/interfaces/contracts/solidity-utils/openzeppelin/IERC20Permit.sol";
import "@mertaswap/solidity-utils/contracts/openzeppelin/EIP712.sol";
contract BalancerPoolToken is IERC20, IERC20Permit, EIP712 {
  using Math for uint256;
  // State variables
  uint8 private constant _DECIMALS = 18;
  mapping(address => uint256) private _balance;
  mapping(address => mapping(address => uint256)) private _allowance;
  uint256 private _totalSupply;
  string private _name;
  string private _symbol;
  mapping(address => uint256) private _nonces;
  // solhint-disable-next-line var-name-mixedcase
  bytes32 private immutable _PERMIT_TYPE_HASH = keccak256(
    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
  );
  // Function declarations
  constructor(string memory tokenName, string memory tokenSymbol) EIP712(tokenName, "1") {
    _name = tokenName;
    _symbol = tokenSymbol;
  }
  // External functions
  function allowance(address owner, address spender) external view override returns (uint256) {
    return _allowance[owner][spender];
  }
  function balanceOf(address account) external view override returns (uint256) {
    return _balance[account];
  }
  function approve(address spender, uint256 amount) external override returns (bool) {
    _setAllowance(msg.sender, spender, amount);
    return true;
  }
  function increaseApproval(address spender, uint256 amount) external returns (bool) {
    _setAllowance(msg.sender, spender, _allowance[msg.sender][spender].add(amount));
    return true;
  }
  function decreaseApproval(address spender, uint256 amount) external returns (bool) {
    uint256 currentAllowance = _allowance[msg.sender][spender];
    if (amount >= currentAllowance) {
      _setAllowance(msg.sender, spender, 0);
    } else {
      _setAllowance(msg.sender, spender, currentAllowance.sub(amount));
    }
    return true;
  }
  function transfer(address recipient, uint256 amount) external override returns (bool) {
    _move(msg.sender, recipient, amount);
    return true;
  }
  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external override returns (bool) {
    uint256 currentAllowance = _allowance[sender][msg.sender];
    _require(msg.sender == sender || currentAllowance >= amount, Errors.INSUFFICIENT_ALLOWANCE);
    _move(sender, recipient, amount);
    if (msg.sender != sender && currentAllowance != uint256(-1)) {
      // Because of the previous require, we know that if msg.sender != sender then currentAllowance >= amount
      _setAllowance(sender, msg.sender, currentAllowance - amount);
    }
    return true;
  }
  function permit(
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) public virtual override {
    // solhint-disable-next-line not-rely-on-time
    _require(block.timestamp <= deadline, Errors.EXPIRED_PERMIT);
    uint256 nonce = _nonces[owner];
    bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPE_HASH, owner, spender, value, nonce, deadline));
    bytes32 hash = _hashTypedDataV4(structHash);
    address signer = ecrecover(hash, v, r, s);
    _require((signer != address(0)) && (signer == owner), Errors.INVALID_SIGNATURE);
    _nonces[owner] = nonce + 1;
    _setAllowance(owner, spender, value);
  }
  // Public functions
  function name() public view returns (string memory) {
    return _name;
  }
  function symbol() public view returns (string memory) {
    return _symbol;
  }
  function decimals() public pure returns (uint8) {
    return _DECIMALS;
  }
  function totalSupply() public view override returns (uint256) {
    return _totalSupply;
  }
  function nonces(address owner) external view override returns (uint256) {
    return _nonces[owner];
  }
  // solhint-disable-next-line func-name-mixedcase
  function DOMAIN_SEPARATOR() external view override returns (bytes32) {
    return _domainSeparatorV4();
  }
  // Internal functions
  function _mintPoolTokens(address recipient, uint256 amount) internal {
    _balance[recipient] = _balance[recipient].add(amount);
    _totalSupply = _totalSupply.add(amount);
    emit Transfer(address(0), recipient, amount);
  }
  function _burnPoolTokens(address sender, uint256 amount) internal {
    uint256 currentBalance = _balance[sender];
    _require(currentBalance >= amount, Errors.INSUFFICIENT_BALANCE);
    _balance[sender] = currentBalance - amount;
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(sender, address(0), amount);
  }
  function _move(
    address sender,
    address recipient,
    uint256 amount
  ) internal {
    uint256 currentBalance = _balance[sender];
    _require(currentBalance >= amount, Errors.INSUFFICIENT_BALANCE);
    _require(recipient != address(0), Errors.ERC20_TRANSFER_TO_ZERO_ADDRESS);
    _balance[sender] = currentBalance - amount;
    _balance[recipient] = _balance[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }
  function _setAllowance(
    address owner,
    address spender,
    uint256 amount
  ) private {
    _allowance[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

interface IERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

interface IERC20Permit {
  function permit(
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;
  function nonces(address owner) external view returns (uint256);
  function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
abstract contract EIP712 {
  bytes32 private immutable _HASHED_NAME;
  bytes32 private immutable _HASHED_VERSION;
  bytes32 private immutable _TYPE_HASH;
  constructor(string memory name, string memory version) {
    _HASHED_NAME = keccak256(bytes(name));
    _HASHED_VERSION = keccak256(bytes(version));
    _TYPE_HASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
  }
  function _domainSeparatorV4() internal view virtual returns (bytes32) {
    return keccak256(abi.encode(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION, _getChainId(), address(this)));
  }
  function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
    return keccak256(abi.encodePacked("\x19\x01", _domainSeparatorV4(), structHash));
  }
  function _getChainId() private view returns (uint256 chainId) {
    this;
    assembly {
      chainId := chainid()
    }
  }
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.7.0;
import "@mertaswap/interfaces/contracts/solidity-utils/openzeppelin/IERC20.sol";
import "@mertaswap/interfaces/contracts/solidity-utils/helpers/BalancerErrors.sol";
library InputHelpers {
  function ensureInputLengthMatch(uint256 a, uint256 b) internal pure {
    _require(a == b, Errors.INPUT_LENGTH_MISMATCH);
  }
  function ensureInputLengthMatch(
    uint256 a,
    uint256 b,
    uint256 c
  ) internal pure {
    _require(a == b && b == c, Errors.INPUT_LENGTH_MISMATCH);
  }
  function ensureArrayIsSorted(IERC20[] memory array) internal pure {
    address[] memory addressArray;
    // solhint-disable-next-line no-inline-assembly
    assembly {
      addressArray := array
    }
    ensureArrayIsSorted(addressArray);
  }
  function ensureArrayIsSorted(address[] memory array) internal pure {
    if (array.length < 2) {
      return;
    }
    address previous = array[0];
    for (uint256 i = 1; i < array.length; ++i) {
      address current = array[i];
      _require(previous < current, Errors.UNSORTED_ARRAY);
      previous = current;
    }
  }
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.7.0;
import "@mertaswap/interfaces/contracts/solidity-utils/helpers/BalancerErrors.sol";
import "@mertaswap/interfaces/contracts/solidity-utils/helpers/ITemporarilyPausable.sol";
abstract contract TemporarilyPausable is ITemporarilyPausable {
  uint256 private constant _MAX_PAUSE_WINDOW_DURATION = 0 days;
  uint256 private constant _MAX_BUFFER_PERIOD_DURATION = 0 days;
  uint256 private immutable _pauseWindowEndTime;
  uint256 private immutable _bufferPeriodEndTime;
  bool private _paused;
  constructor(uint256 pauseWindowDuration, uint256 bufferPeriodDuration) {
    _require(pauseWindowDuration <= _MAX_PAUSE_WINDOW_DURATION, Errors.MAX_PAUSE_WINDOW_DURATION);
    _require(bufferPeriodDuration <= _MAX_BUFFER_PERIOD_DURATION, Errors.MAX_BUFFER_PERIOD_DURATION);
    uint256 pauseWindowEndTime = block.timestamp + pauseWindowDuration;
    _pauseWindowEndTime = pauseWindowEndTime;
    _bufferPeriodEndTime = pauseWindowEndTime + bufferPeriodDuration;
  }
  modifier whenNotPaused() {
    _ensureNotPaused();
    _;
  }
  function getPausedState()
    external
    view
    override
    returns (
      bool paused,
      uint256 pauseWindowEndTime,
      uint256 bufferPeriodEndTime
    )
  {
    paused = !_isNotPaused();
    pauseWindowEndTime = _getPauseWindowEndTime();
    bufferPeriodEndTime = _getBufferPeriodEndTime();
  }
  function _setPaused(bool paused) internal {
    if (paused) {
      _require(block.timestamp < _getPauseWindowEndTime(), Errors.PAUSE_WINDOW_EXPIRED);
    } else {
      _require(block.timestamp < _getBufferPeriodEndTime(), Errors.BUFFER_PERIOD_EXPIRED);
    }
    _paused = paused;
    emit PausedStateChanged(paused);
  }
  function _ensureNotPaused() internal view {
    _require(_isNotPaused(), Errors.PAUSED);
  }
  function _ensurePaused() internal view {
    _require(!_isNotPaused(), Errors.NOT_PAUSED);
  }
  function _isNotPaused() internal view returns (bool) {
    return block.timestamp > _getBufferPeriodEndTime() || !_paused;
  }
  function _getPauseWindowEndTime() private view returns (uint256) {
    return _pauseWindowEndTime;
  }
  function _getBufferPeriodEndTime() private view returns (uint256) {
    return _bufferPeriodEndTime;
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import "@mertaswap/interfaces/contracts/solidity-utils/helpers/BalancerErrors.sol";
import "@mertaswap/interfaces/contracts/solidity-utils/openzeppelin/IERC20.sol";

import "./SafeMath.sol";

contract ERC20 is IERC20 {
  using SafeMath for uint256;

  mapping(address => uint256) private _balances;

  mapping(address => mapping(address => uint256)) private _allowances;

  uint256 private _totalSupply;

  string private _name;
  string private _symbol;
  uint8 private _decimals;

  constructor(string memory name_, string memory symbol_) {
    _name = name_;
    _symbol = symbol_;
    _decimals = 18;
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

  function totalSupply() public view override returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) public view override returns (uint256) {
    return _balances[account];
  }

  function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
    _transfer(msg.sender, recipient, amount);
    return true;
  }

  function allowance(address owner, address spender) public view virtual override returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) public virtual override returns (bool) {
    _approve(msg.sender, spender, amount);
    return true;
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) public virtual override returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(
      sender,
      msg.sender,
      _allowances[sender][msg.sender].sub(amount, Errors.ERC20_TRANSFER_EXCEEDS_ALLOWANCE)
    );
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
    _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
    _approve(
      msg.sender,
      spender,
      _allowances[msg.sender][spender].sub(subtractedValue, Errors.ERC20_DECREASED_ALLOWANCE_BELOW_ZERO)
    );
    return true;
  }

  function _transfer(
    address sender,
    address recipient,
    uint256 amount
  ) internal virtual {
    _require(sender != address(0), Errors.ERC20_TRANSFER_FROM_ZERO_ADDRESS);
    _require(recipient != address(0), Errors.ERC20_TRANSFER_TO_ZERO_ADDRESS);

    _beforeTokenTransfer(sender, recipient, amount);

    _balances[sender] = _balances[sender].sub(amount, Errors.ERC20_TRANSFER_EXCEEDS_BALANCE);
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }

  function _mint(address account, uint256 amount) internal virtual {
    _beforeTokenTransfer(address(0), account, amount);

    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  function _burn(address account, uint256 amount) internal virtual {
    _require(account != address(0), Errors.ERC20_BURN_FROM_ZERO_ADDRESS);

    _beforeTokenTransfer(account, address(0), amount);

    _balances[account] = _balances[account].sub(amount, Errors.ERC20_BURN_EXCEEDS_BALANCE);
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
  }

  function _approve(
    address owner,
    address spender,
    uint256 amount
  ) internal virtual {
    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function _setupDecimals(uint8 decimals_) internal {
    _decimals = decimals_;
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual {
    // solhint-disable-previous-line no-empty-blocks
  }
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.7.0;
import "@mertaswap/solidity-utils/contracts/helpers/InputHelpers.sol";
import "@mertaswap/solidity-utils/contracts/math/FixedPoint.sol";
import "@mertaswap/solidity-utils/contracts/math/Math.sol";
/* solhint-disable private-vars-leading-underscore */
contract WeightedMath {
  using FixedPoint for uint256;
  uint256 internal constant _MIN_WEIGHT = 0.01e18;
  uint256 internal constant _MAX_WEIGHTED_TOKENS = 100;
  uint256 internal constant _MAX_IN_RATIO = 0.3e18;
  uint256 internal constant _MAX_OUT_RATIO = 0.3e18;
  uint256 internal constant _MAX_INVARIANT_RATIO = 3e18;
  uint256 internal constant _MIN_INVARIANT_RATIO = 0.7e18;
  function _calculateInvariant(uint256[] memory normalizedWeights, uint256[] memory balances)
    internal
    pure
    returns (uint256 invariant)
  {
    invariant = FixedPoint.ONE;
    for (uint256 i = 0; i < normalizedWeights.length; i++) {
      invariant = invariant.mulDown(balances[i].powDown(normalizedWeights[i]));
    }
    _require(invariant > 0, Errors.ZERO_INVARIANT);
  }
  function _calcOutGivenIn(
    uint256 balanceIn,
    uint256 weightIn,
    uint256 balanceOut,
    uint256 weightOut,
    uint256 amountIn
  ) internal pure returns (uint256) {
    _require(amountIn <= balanceIn.mulDown(_MAX_IN_RATIO), Errors.MAX_IN_RATIO);
    uint256 denominator = balanceIn.add(amountIn);
    uint256 base = balanceIn.divUp(denominator);
    uint256 exponent = weightIn.divDown(weightOut);
    uint256 power = base.powUp(exponent);
    return balanceOut.mulDown(power.complement());
  }
  // Computes how many tokens must be sent to a pool in order to take `amountOut`, given the
  // current balances and weights.
  function _calcInGivenOut(
    uint256 balanceIn,
    uint256 weightIn,
    uint256 balanceOut,
    uint256 weightOut,
    uint256 amountOut
  ) internal pure returns (uint256) {
    _require(amountOut <= balanceOut.mulDown(_MAX_OUT_RATIO), Errors.MAX_OUT_RATIO);
    uint256 base = balanceOut.divUp(balanceOut.sub(amountOut));
    uint256 exponent = weightOut.divUp(weightIn);
    uint256 power = base.powUp(exponent);
    uint256 ratio = power.sub(FixedPoint.ONE);
    return balanceIn.mulUp(ratio);
  }
  function _calcBptOutGivenExactTokensIn(
    uint256[] memory balances,
    uint256[] memory normalizedWeights,
    uint256[] memory amountsIn,
    uint256 bptTotalSupply,
    uint256 swapFee
  ) internal pure returns (uint256) {
    uint256[] memory balanceRatiosWithFee = new uint256[](amountsIn.length);
    uint256 invariantRatioWithFees = 0;
    for (uint256 i = 0; i < balances.length; i++) {
      balanceRatiosWithFee[i] = balances[i].add(amountsIn[i]).divDown(balances[i]);
      invariantRatioWithFees = invariantRatioWithFees.add(balanceRatiosWithFee[i].mulDown(normalizedWeights[i]));
    }
    uint256 invariantRatio = FixedPoint.ONE;
    for (uint256 i = 0; i < balances.length; i++) {
      uint256 amountInWithoutFee;
      if (balanceRatiosWithFee[i] > invariantRatioWithFees) {
        uint256 nonTaxableAmount = balances[i].mulDown(invariantRatioWithFees.sub(FixedPoint.ONE));
        uint256 taxableAmount = amountsIn[i].sub(nonTaxableAmount);
        amountInWithoutFee = nonTaxableAmount.add(taxableAmount.mulDown(FixedPoint.ONE.sub(swapFee)));
      } else {
        amountInWithoutFee = amountsIn[i];
      }
      uint256 balanceRatio = balances[i].add(amountInWithoutFee).divDown(balances[i]);
      invariantRatio = invariantRatio.mulDown(balanceRatio.powDown(normalizedWeights[i]));
    }
    if (invariantRatio >= FixedPoint.ONE) {
      return bptTotalSupply.mulDown(invariantRatio.sub(FixedPoint.ONE));
    } else {
      return 0;
    }
  }
  function _calcTokenInGivenExactBptOut(
    uint256 balance,
    uint256 normalizedWeight,
    uint256 bptAmountOut,
    uint256 bptTotalSupply,
    uint256 swapFee
  ) internal pure returns (uint256) {
    uint256 invariantRatio = bptTotalSupply.add(bptAmountOut).divUp(bptTotalSupply);
    _require(invariantRatio <= _MAX_INVARIANT_RATIO, Errors.MAX_OUT_BPT_FOR_TOKEN_IN);
    uint256 balanceRatio = invariantRatio.powUp(FixedPoint.ONE.divUp(normalizedWeight));
    uint256 amountInWithoutFee = balance.mulUp(balanceRatio.sub(FixedPoint.ONE));
    uint256 taxablePercentage = normalizedWeight.complement();
    uint256 taxableAmount = amountInWithoutFee.mulUp(taxablePercentage);
    uint256 nonTaxableAmount = amountInWithoutFee.sub(taxableAmount);
    return nonTaxableAmount.add(taxableAmount.divUp(swapFee.complement()));
  }
  function _calcBptInGivenExactTokensOut(
    uint256[] memory balances,
    uint256[] memory normalizedWeights,
    uint256[] memory amountsOut,
    uint256 bptTotalSupply,
    uint256 swapFee
  ) internal pure returns (uint256) {
    // BPT in, so we round up overall.
    uint256[] memory balanceRatiosWithoutFee = new uint256[](amountsOut.length);
    uint256 invariantRatioWithoutFees = 0;
    for (uint256 i = 0; i < balances.length; i++) {
      balanceRatiosWithoutFee[i] = balances[i].sub(amountsOut[i]).divUp(balances[i]);
      invariantRatioWithoutFees = invariantRatioWithoutFees.add(
        balanceRatiosWithoutFee[i].mulUp(normalizedWeights[i])
      );
    }
    uint256 invariantRatio = FixedPoint.ONE;
    for (uint256 i = 0; i < balances.length; i++) {
      uint256 amountOutWithFee;
      if (invariantRatioWithoutFees > balanceRatiosWithoutFee[i]) {
        uint256 nonTaxableAmount = balances[i].mulDown(invariantRatioWithoutFees.complement());
        uint256 taxableAmount = amountsOut[i].sub(nonTaxableAmount);
        amountOutWithFee = nonTaxableAmount.add(taxableAmount.divUp(swapFee.complement()));
      } else {
        amountOutWithFee = amountsOut[i];
      }
      uint256 balanceRatio = balances[i].sub(amountOutWithFee).divDown(balances[i]);
      invariantRatio = invariantRatio.mulDown(balanceRatio.powDown(normalizedWeights[i]));
    }
    return bptTotalSupply.mulUp(invariantRatio.complement());
  }
  function _calcTokenOutGivenExactBptIn(
    uint256 balance,
    uint256 normalizedWeight,
    uint256 bptAmountIn,
    uint256 bptTotalSupply,
    uint256 swapFee
  ) internal pure returns (uint256) {
    uint256 invariantRatio = bptTotalSupply.sub(bptAmountIn).divUp(bptTotalSupply);
    _require(invariantRatio >= _MIN_INVARIANT_RATIO, Errors.MIN_BPT_IN_FOR_TOKEN_OUT);
    uint256 balanceRatio = invariantRatio.powUp(FixedPoint.ONE.divDown(normalizedWeight));
    uint256 amountOutWithoutFee = balance.mulDown(balanceRatio.complement());
    uint256 taxablePercentage = normalizedWeight.complement();
    uint256 taxableAmount = amountOutWithoutFee.mulUp(taxablePercentage);
    uint256 nonTaxableAmount = amountOutWithoutFee.sub(taxableAmount);
    return nonTaxableAmount.add(taxableAmount.mulDown(swapFee.complement()));
  }
  function _calcTokensOutGivenExactBptIn(
    uint256[] memory balances,
    uint256 bptAmountIn,
    uint256 totalBPT
  ) internal pure returns (uint256[] memory) {
    uint256 bptRatio = bptAmountIn.divDown(totalBPT);
    uint256[] memory amountsOut = new uint256[](balances.length);
    for (uint256 i = 0; i < balances.length; i++) {
      amountsOut[i] = balances[i].mulDown(bptRatio);
    }
    return amountsOut;
  }
  function _calcDueTokenProtocolSwapFeeAmount(
    uint256 balance,
    uint256 normalizedWeight,
    uint256 previousInvariant,
    uint256 currentInvariant,
    uint256 protocolSwapFeePercentage
  ) internal pure returns (uint256) {
    if (currentInvariant <= previousInvariant) {
      return 0;
    }
    uint256 base = previousInvariant.divUp(currentInvariant);
    uint256 exponent = FixedPoint.ONE.divDown(normalizedWeight);
    base = Math.max(base, FixedPoint.MIN_POW_BASE_FREE_EXPONENT);
    uint256 power = base.powUp(exponent);
    uint256 tokenAccruedFees = balance.mulDown(power.complement());
    return tokenAccruedFees.mulDown(protocolSwapFeePercentage);
  }
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.7.0;
import "@mertaswap/interfaces/contracts/solidity-utils/openzeppelin/IERC20.sol";
import "./WeightedPool.sol";
library WeightedPoolUserDataHelpers {
  function joinKind(bytes memory self) internal pure returns (WeightedPool.JoinKind) {
    return abi.decode(self, (WeightedPool.JoinKind));
  }
  function exitKind(bytes memory self) internal pure returns (WeightedPool.ExitKind) {
    return abi.decode(self, (WeightedPool.ExitKind));
  }
  // Joins
  function initialAmountsIn(bytes memory self) internal pure returns (uint256[] memory amountsIn) {
    (, amountsIn) = abi.decode(self, (WeightedPool.JoinKind, uint256[]));
  }
  function exactTokensInForBptOut(bytes memory self)
    internal
    pure
    returns (uint256[] memory amountsIn, uint256 minBPTAmountOut)
  {
    (, amountsIn, minBPTAmountOut) = abi.decode(self, (WeightedPool.JoinKind, uint256[], uint256));
  }
  function tokenInForExactBptOut(bytes memory self) internal pure returns (uint256 bptAmountOut, uint256 tokenIndex) {
    (, bptAmountOut, tokenIndex) = abi.decode(self, (WeightedPool.JoinKind, uint256, uint256));
  }
  // Exits
  function exactBptInForTokenOut(bytes memory self) internal pure returns (uint256 bptAmountIn, uint256 tokenIndex) {
    (, bptAmountIn, tokenIndex) = abi.decode(self, (WeightedPool.ExitKind, uint256, uint256));
  }
  function exactBptInForTokensOut(bytes memory self) internal pure returns (uint256 bptAmountIn) {
    (, bptAmountIn) = abi.decode(self, (WeightedPool.ExitKind, uint256));
  }
  function bptInForExactTokensOut(bytes memory self)
    internal
    pure
    returns (uint256[] memory amountsOut, uint256 maxBPTAmountIn)
  {
    (, amountsOut, maxBPTAmountIn) = abi.decode(self, (WeightedPool.ExitKind, uint256[], uint256));
  }
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.7.0;
import "@mertaswap/interfaces/contracts/vault/IAuthorizer.sol";
import "@mertaswap/solidity-utils/contracts/helpers/Authentication.sol";
import "./BasePool.sol";
abstract contract BasePoolAuthorization is Authentication {
  address private immutable _owner;
  address private constant _DELEGATE_OWNER = 0xBA1BA1ba1BA1bA1bA1Ba1BA1ba1BA1bA1ba1ba1B;
  constructor(address owner) {
    _owner = owner;
  }
  function getOwner() public view returns (address) {
    return _owner;
  }
  function getAuthorizer() external view returns (IAuthorizer) {
    return _getAuthorizer();
  }
  function _canPerform(bytes32 actionId, address account) internal view override returns (bool) {
    if ((getOwner() != _DELEGATE_OWNER) && _isOwnerOnlyAction(actionId)) {
      return msg.sender == getOwner();
    } else {
      return _getAuthorizer().canPerform(actionId, account, address(this));
    }
  }
  function _isOwnerOnlyAction(bytes32 actionId) private view returns (bool) {
    return actionId == getActionId(BasePool.setSwapFeePercentage.selector);
  }
  function _getAuthorizer() internal view virtual returns (IAuthorizer);
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "./IBasePool.sol";

interface IMinimalSwapInfoPool is IBasePool {
  function onSwap(
    SwapRequest memory swapRequest,
    uint256 currentBalanceTokenIn,
    uint256 currentBalanceTokenOut
  ) external returns (uint256 amount);
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.7.0;

interface ITemporarilyPausable {
  event PausedStateChanged(bool paused);
  function getPausedState()
    external
    view
    returns (
      bool paused,
      uint256 pauseWindowEndTime,
      uint256 bufferPeriodEndTime
    );
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import "@mertaswap/interfaces/contracts/solidity-utils/helpers/BalancerErrors.sol";

library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    _require(c >= a, Errors.ADD_OVERFLOW);

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, Errors.SUB_OVERFLOW);
  }

  function sub(
    uint256 a,
    uint256 b,
    uint256 errorCode
  ) internal pure returns (uint256) {
    _require(b <= a, errorCode);
    uint256 c = a - b;

    return c;
  }
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;
import "@mertaswap/solidity-utils/contracts/math/FixedPoint.sol";
import "@mertaswap/solidity-utils/contracts/helpers/InputHelpers.sol";
import "@mertaswap/pool-utils/contracts/BaseMinimalSwapInfoPool.sol";
import "./WeightedMath.sol";
import "./WeightedPoolUserDataHelpers.sol";

contract WeightedPool is BaseMinimalSwapInfoPool, WeightedMath {
  using FixedPoint for uint256;
  using WeightedPoolUserDataHelpers for bytes;
  uint256 private immutable _maxWeightTokenIndex;
  uint256 private immutable _normalizedWeight0;
  uint256 private immutable _normalizedWeight1;
  uint256 private immutable _normalizedWeight2;
  uint256 private immutable _normalizedWeight3;
  uint256 private immutable _normalizedWeight4;
  uint256 private immutable _normalizedWeight5;
  uint256 private immutable _normalizedWeight6;
  uint256 private immutable _normalizedWeight7;
  uint256 private _lastInvariant;
  enum JoinKind { INIT, EXACT_TOKENS_IN_FOR_BPT_OUT, TOKEN_IN_FOR_EXACT_BPT_OUT }
  enum ExitKind { EXACT_BPT_IN_FOR_ONE_TOKEN_OUT, EXACT_BPT_IN_FOR_TOKENS_OUT, BPT_IN_FOR_EXACT_TOKENS_OUT }
  constructor(
    IVault vault,
    string memory name,
    string memory symbol,
    IERC20[] memory tokens,
    uint256[] memory normalizedWeights,
    uint256 swapFeePercentage,
    uint256 pauseWindowDuration,
    uint256 bufferPeriodDuration,
    address owner
  )
    BaseMinimalSwapInfoPool(
      vault,
      name,
      symbol,
      tokens,
      swapFeePercentage,
      pauseWindowDuration,
      bufferPeriodDuration,
      owner
    )
  {
    uint256 numTokens = tokens.length;
    InputHelpers.ensureInputLengthMatch(numTokens, normalizedWeights.length);
    // Ensure  each normalized weight is above them minimum and find the token index of the maximum weight
    uint256 normalizedSum = 0;
    uint256 maxWeightTokenIndex = 0;
    uint256 maxNormalizedWeight = 0;
    for (uint8 i = 0; i < numTokens; i++) {
      uint256 normalizedWeight = normalizedWeights[i];
      _require(normalizedWeight >= _MIN_WEIGHT, Errors.MIN_WEIGHT);
      normalizedSum = normalizedSum.add(normalizedWeight);
      if (normalizedWeight > maxNormalizedWeight) {
        maxWeightTokenIndex = i;
        maxNormalizedWeight = normalizedWeight;
      }
    }
    // Ensure that the normalized weights sum to ONE
    _require(normalizedSum == FixedPoint.ONE, Errors.NORMALIZED_WEIGHT_INVARIANT);
    _maxWeightTokenIndex = maxWeightTokenIndex;
    _normalizedWeight0 = normalizedWeights.length > 0 ? normalizedWeights[0] : 0;
    _normalizedWeight1 = normalizedWeights.length > 1 ? normalizedWeights[1] : 0;
    _normalizedWeight2 = normalizedWeights.length > 2 ? normalizedWeights[2] : 0;
    _normalizedWeight3 = normalizedWeights.length > 3 ? normalizedWeights[3] : 0;
    _normalizedWeight4 = normalizedWeights.length > 4 ? normalizedWeights[4] : 0;
    _normalizedWeight5 = normalizedWeights.length > 5 ? normalizedWeights[5] : 0;
    _normalizedWeight6 = normalizedWeights.length > 6 ? normalizedWeights[6] : 0;
    _normalizedWeight7 = normalizedWeights.length > 7 ? normalizedWeights[7] : 0;
  }
  function _normalizedWeight(IERC20 token) internal view virtual returns (uint256) {
    // prettier-ignore
    if (token == _token0) { return _normalizedWeight0; }
    else if (token == _token1) { return _normalizedWeight1; }
    else if (token == _token2) { return _normalizedWeight2; }
    else if (token == _token3) { return _normalizedWeight3; }
    else if (token == _token4) { return _normalizedWeight4; }
    else if (token == _token5) { return _normalizedWeight5; }
    else if (token == _token6) { return _normalizedWeight6; }
    else if (token == _token7) { return _normalizedWeight7; }
    else {
      _revert(Errors.INVALID_TOKEN);
    }
  }
  function _normalizedWeights() internal view virtual returns (uint256[] memory) {
    uint256 totalTokens = _getTotalTokens();
    uint256[] memory normalizedWeights = new uint256[](totalTokens);
    // prettier-ignore
    {
      if (totalTokens > 0) { normalizedWeights[0] = _normalizedWeight0; } else { return normalizedWeights; }
      if (totalTokens > 1) { normalizedWeights[1] = _normalizedWeight1; } else { return normalizedWeights; }
      if (totalTokens > 2) { normalizedWeights[2] = _normalizedWeight2; } else { return normalizedWeights; }
      if (totalTokens > 3) { normalizedWeights[3] = _normalizedWeight3; } else { return normalizedWeights; }
      if (totalTokens > 4) { normalizedWeights[4] = _normalizedWeight4; } else { return normalizedWeights; }
      if (totalTokens > 5) { normalizedWeights[5] = _normalizedWeight5; } else { return normalizedWeights; }
      if (totalTokens > 6) { normalizedWeights[6] = _normalizedWeight6; } else { return normalizedWeights; }
      if (totalTokens > 7) { normalizedWeights[7] = _normalizedWeight7; } else { return normalizedWeights; }
    }
    return normalizedWeights;
  }
  function getLastInvariant() external view returns (uint256) {
    return _lastInvariant;
  }
  /**
   * @dev Returns the current value of the invariant.
   */
  function getInvariant() public view returns (uint256) {
    (, uint256[] memory balances, ) = getVault().getPoolTokens(getPoolId());
    // Since the Pool hooks always work with upscaled balances, we manually
    // upscale here for consistency
    _upscaleArray(balances, _scalingFactors());
    uint256[] memory normalizedWeights = _normalizedWeights();
    return WeightedMath._calculateInvariant(normalizedWeights, balances);
  }
  function getNormalizedWeights() external view returns (uint256[] memory) {
    return _normalizedWeights();
  }
  // Base Pool handlers
  // Swap
  function _onSwapGivenIn(
    SwapRequest memory swapRequest,
    uint256 currentBalanceTokenIn,
    uint256 currentBalanceTokenOut
  ) internal view virtual override whenNotPaused returns (uint256) {
    // Swaps are disabled while the contract is paused.
    return
      WeightedMath._calcOutGivenIn(
        currentBalanceTokenIn,
        _normalizedWeight(swapRequest.tokenIn),
        currentBalanceTokenOut,
        _normalizedWeight(swapRequest.tokenOut),
        swapRequest.amount
      );
  }
  function _onSwapGivenOut(
    SwapRequest memory swapRequest,
    uint256 currentBalanceTokenIn,
    uint256 currentBalanceTokenOut
  ) internal view virtual override whenNotPaused returns (uint256) {
    // Swaps are disabled while the contract is paused.
    return
      WeightedMath._calcInGivenOut(
        currentBalanceTokenIn,
        _normalizedWeight(swapRequest.tokenIn),
        currentBalanceTokenOut,
        _normalizedWeight(swapRequest.tokenOut),
        swapRequest.amount
      );
  }
  // Initialize
  function _onInitializePool(
    bytes32,
    address,
    address,
    bytes memory userData
  ) internal virtual override whenNotPaused returns (uint256, uint256[] memory) {
    // It would be strange for the Pool to be paused before it is initialized, but for consistency we prevent
    // initialization in this case.
    WeightedPool.JoinKind kind = userData.joinKind();
    _require(kind == WeightedPool.JoinKind.INIT, Errors.UNINITIALIZED);
    uint256[] memory amountsIn = userData.initialAmountsIn();
    InputHelpers.ensureInputLengthMatch(_getTotalTokens(), amountsIn.length);
    _upscaleArray(amountsIn, _scalingFactors());
    uint256[] memory normalizedWeights = _normalizedWeights();
    uint256 invariantAfterJoin = WeightedMath._calculateInvariant(normalizedWeights, amountsIn);
    uint256 bptAmountOut = Math.mul(invariantAfterJoin, _getTotalTokens());
    _lastInvariant = invariantAfterJoin;
    return (bptAmountOut, amountsIn);
  }
  // Join
  function _onJoinPool(
    bytes32,
    address,
    address,
    uint256[] memory balances,
    uint256,
    uint256 protocolSwapFeePercentage,
    bytes memory userData
  )
    internal
    virtual
    override
    whenNotPaused
    returns (
      uint256,
      uint256[] memory,
      uint256[] memory
    )
  {
    // All joins are disabled while the contract is paused.
    uint256[] memory normalizedWeights = _normalizedWeights();
    uint256 invariantBeforeJoin = WeightedMath._calculateInvariant(normalizedWeights, balances);
    uint256[] memory dueProtocolFeeAmounts = _getDueProtocolFeeAmounts(
      balances,
      normalizedWeights,
      _lastInvariant,
      invariantBeforeJoin,
      protocolSwapFeePercentage
    );
    // Update current balances by subtracting the protocol fee amounts
    _mutateAmounts(balances, dueProtocolFeeAmounts, FixedPoint.sub);
    (uint256 bptAmountOut, uint256[] memory amountsIn) = _doJoin(balances, normalizedWeights, userData);
    _lastInvariant = _invariantAfterJoin(balances, amountsIn, normalizedWeights);
    return (bptAmountOut, amountsIn, dueProtocolFeeAmounts);
  }
  function _doJoin(
    uint256[] memory balances,
    uint256[] memory normalizedWeights,
    bytes memory userData
  ) private view returns (uint256, uint256[] memory) {
    JoinKind kind = userData.joinKind();
    if (kind == JoinKind.EXACT_TOKENS_IN_FOR_BPT_OUT) {
      return _joinExactTokensInForBPTOut(balances, normalizedWeights, userData);
    } else if (kind == JoinKind.TOKEN_IN_FOR_EXACT_BPT_OUT) {
      return _joinTokenInForExactBPTOut(balances, normalizedWeights, userData);
    } else {
      _revert(Errors.UNHANDLED_JOIN_KIND);
    }
  }
  function _joinExactTokensInForBPTOut(
    uint256[] memory balances,
    uint256[] memory normalizedWeights,
    bytes memory userData
  ) private view returns (uint256, uint256[] memory) {
    (uint256[] memory amountsIn, uint256 minBPTAmountOut) = userData.exactTokensInForBptOut();
    InputHelpers.ensureInputLengthMatch(_getTotalTokens(), amountsIn.length);
    _upscaleArray(amountsIn, _scalingFactors());
    uint256 bptAmountOut = WeightedMath._calcBptOutGivenExactTokensIn(
      balances,
      normalizedWeights,
      amountsIn,
      totalSupply(),
      _swapFeePercentage
    );
    _require(bptAmountOut >= minBPTAmountOut, Errors.BPT_OUT_MIN_AMOUNT);
    return (bptAmountOut, amountsIn);
  }
  function _joinTokenInForExactBPTOut(
    uint256[] memory balances,
    uint256[] memory normalizedWeights,
    bytes memory userData
  ) private view returns (uint256, uint256[] memory) {
    (uint256 bptAmountOut, uint256 tokenIndex) = userData.tokenInForExactBptOut();
    // Note that there is no maximum amountIn parameter: this is handled by `IVault.joinPool`.
    _require(tokenIndex < _getTotalTokens(), Errors.OUT_OF_BOUNDS);
    uint256[] memory amountsIn = new uint256[](_getTotalTokens());
    amountsIn[tokenIndex] = WeightedMath._calcTokenInGivenExactBptOut(
      balances[tokenIndex],
      normalizedWeights[tokenIndex],
      bptAmountOut,
      totalSupply(),
      _swapFeePercentage
    );
    return (bptAmountOut, amountsIn);
  }
  // Exit
  function _onExitPool(
    bytes32,
    address,
    address,
    uint256[] memory balances,
    uint256,
    uint256 protocolSwapFeePercentage,
    bytes memory userData
  )
    internal
    virtual
    override
    returns (
      uint256 bptAmountIn,
      uint256[] memory amountsOut,
      uint256[] memory dueProtocolFeeAmounts
    )
  {
    uint256[] memory normalizedWeights = _normalizedWeights();
    if (_isNotPaused()) {
      uint256 invariantBeforeExit = WeightedMath._calculateInvariant(normalizedWeights, balances);
      dueProtocolFeeAmounts = _getDueProtocolFeeAmounts(
        balances,
        normalizedWeights,
        _lastInvariant,
        invariantBeforeExit,
        protocolSwapFeePercentage
      );
      _mutateAmounts(balances, dueProtocolFeeAmounts, FixedPoint.sub);
    } else {
      dueProtocolFeeAmounts = new uint256[](_getTotalTokens());
    }
    (bptAmountIn, amountsOut) = _doExit(balances, normalizedWeights, userData);
    _lastInvariant = _invariantAfterExit(balances, amountsOut, normalizedWeights);
    return (bptAmountIn, amountsOut, dueProtocolFeeAmounts);
  }
  function _doExit(
    uint256[] memory balances,
    uint256[] memory normalizedWeights,
    bytes memory userData
  ) private view returns (uint256, uint256[] memory) {
    ExitKind kind = userData.exitKind();
    if (kind == ExitKind.EXACT_BPT_IN_FOR_ONE_TOKEN_OUT) {
      return _exitExactBPTInForTokenOut(balances, normalizedWeights, userData);
    } else if (kind == ExitKind.EXACT_BPT_IN_FOR_TOKENS_OUT) {
      return _exitExactBPTInForTokensOut(balances, userData);
    } else {
      return _exitBPTInForExactTokensOut(balances, normalizedWeights, userData);
    }
  }
  function _exitExactBPTInForTokenOut(
    uint256[] memory balances,
    uint256[] memory normalizedWeights,
    bytes memory userData
  ) private view whenNotPaused returns (uint256, uint256[] memory) {
    (uint256 bptAmountIn, uint256 tokenIndex) = userData.exactBptInForTokenOut();
    // Note that there is no minimum amountOut parameter: this is handled by `IVault.exitPool`.
    _require(tokenIndex < _getTotalTokens(), Errors.OUT_OF_BOUNDS);
    // We exit in a single token, so we initialize amountsOut with zeros
    uint256[] memory amountsOut = new uint256[](_getTotalTokens());
    // And then assign the result to the selected token
    amountsOut[tokenIndex] = WeightedMath._calcTokenOutGivenExactBptIn(
      balances[tokenIndex],
      normalizedWeights[tokenIndex],
      bptAmountIn,
      totalSupply(),
      _swapFeePercentage
    );
    return (bptAmountIn, amountsOut);
  }
  function _exitExactBPTInForTokensOut(uint256[] memory balances, bytes memory userData)
    private
    view
    returns (uint256, uint256[] memory)
  {
    uint256 bptAmountIn = userData.exactBptInForTokensOut();
    uint256[] memory amountsOut = WeightedMath._calcTokensOutGivenExactBptIn(balances, bptAmountIn, totalSupply());
    return (bptAmountIn, amountsOut);
  }
  function _exitBPTInForExactTokensOut(
    uint256[] memory balances,
    uint256[] memory normalizedWeights,
    bytes memory userData
  ) private view whenNotPaused returns (uint256, uint256[] memory) {
    (uint256[] memory amountsOut, uint256 maxBPTAmountIn) = userData.bptInForExactTokensOut();
    InputHelpers.ensureInputLengthMatch(amountsOut.length, _getTotalTokens());
    _upscaleArray(amountsOut, _scalingFactors());
    uint256 bptAmountIn = WeightedMath._calcBptInGivenExactTokensOut(
      balances,
      normalizedWeights,
      amountsOut,
      totalSupply(),
      _swapFeePercentage
    );
    _require(bptAmountIn <= maxBPTAmountIn, Errors.BPT_IN_MAX_AMOUNT);
    return (bptAmountIn, amountsOut);
  }
  // Helpers
  function _getDueProtocolFeeAmounts(
    uint256[] memory balances,
    uint256[] memory normalizedWeights,
    uint256 previousInvariant,
    uint256 currentInvariant,
    uint256 protocolSwapFeePercentage
  ) private view returns (uint256[] memory) {
    uint256[] memory dueProtocolFeeAmounts = new uint256[](_getTotalTokens());
    if (protocolSwapFeePercentage == 0) {
      return dueProtocolFeeAmounts;
    }
    dueProtocolFeeAmounts[_maxWeightTokenIndex] = WeightedMath._calcDueTokenProtocolSwapFeeAmount(
      balances[_maxWeightTokenIndex],
      normalizedWeights[_maxWeightTokenIndex],
      previousInvariant,
      currentInvariant,
      protocolSwapFeePercentage
    );
    return dueProtocolFeeAmounts;
  }
  function _invariantAfterJoin(
    uint256[] memory balances,
    uint256[] memory amountsIn,
    uint256[] memory normalizedWeights
  ) private view returns (uint256) {
    _mutateAmounts(balances, amountsIn, FixedPoint.add);
    return WeightedMath._calculateInvariant(normalizedWeights, balances);
  }
  function _invariantAfterExit(
    uint256[] memory balances,
    uint256[] memory amountsOut,
    uint256[] memory normalizedWeights
  ) private view returns (uint256) {
    _mutateAmounts(balances, amountsOut, FixedPoint.sub);
    return WeightedMath._calculateInvariant(normalizedWeights, balances);
  }
  function _mutateAmounts(
    uint256[] memory toMutate,
    uint256[] memory arguments,
    function(uint256, uint256) pure returns (uint256) mutation
  ) private view {
    for (uint256 i = 0; i < _getTotalTokens(); ++i) {
      toMutate[i] = mutation(toMutate[i], arguments[i]);
    }
  }
  function getRate() public view returns (uint256) {
    return Math.mul(getInvariant(), _getTotalTokens()).divDown(totalSupply());
  }
}

// SPDX-License-Identifier: GPL-3.0-or-later


pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "./BasePool.sol";
import "@mertaswap/interfaces/contracts/vault/IMinimalSwapInfoPool.sol";

abstract contract BaseMinimalSwapInfoPool is IMinimalSwapInfoPool, BasePool {
  constructor(
    IVault vault,
    string memory name,
    string memory symbol,
    IERC20[] memory tokens,
    uint256 swapFeePercentage,
    uint256 pauseWindowDuration,
    uint256 bufferPeriodDuration,
    address owner
  )
    BasePool(
      vault,
      tokens.length == 2 ? IVault.PoolSpecialization.TWO_TOKEN : IVault.PoolSpecialization.MINIMAL_SWAP_INFO,
      name,
      symbol,
      tokens,
      swapFeePercentage,
      pauseWindowDuration,
      bufferPeriodDuration,
      owner
    )
  {
    // solhint-disable-previous-line no-empty-blocks
  }

  // Swap Hooks

  function onSwap(
    SwapRequest memory request,
    uint256 balanceTokenIn,
    uint256 balanceTokenOut
  ) external view virtual override returns (uint256) {
    uint256 scalingFactorTokenIn = _scalingFactor(request.tokenIn);
    uint256 scalingFactorTokenOut = _scalingFactor(request.tokenOut);

    if (request.kind == IVault.SwapKind.GIVEN_IN) {
      request.amount = _subtractSwapFeeAmount(request.amount);

      balanceTokenIn = _upscale(balanceTokenIn, scalingFactorTokenIn);
      balanceTokenOut = _upscale(balanceTokenOut, scalingFactorTokenOut);
      request.amount = _upscale(request.amount, scalingFactorTokenIn);

      uint256 amountOut = _onSwapGivenIn(request, balanceTokenIn, balanceTokenOut);

      return _downscaleDown(amountOut, scalingFactorTokenOut);
    } else {
      balanceTokenIn = _upscale(balanceTokenIn, scalingFactorTokenIn);
      balanceTokenOut = _upscale(balanceTokenOut, scalingFactorTokenOut);
      request.amount = _upscale(request.amount, scalingFactorTokenOut);

      uint256 amountIn = _onSwapGivenOut(request, balanceTokenIn, balanceTokenOut);

      amountIn = _downscaleUp(amountIn, scalingFactorTokenIn);

      return _addSwapFeeAmount(amountIn);
    }
  }

  function _onSwapGivenIn(
    SwapRequest memory swapRequest,
    uint256 balanceTokenIn,
    uint256 balanceTokenOut
  ) internal view virtual returns (uint256);

  function _onSwapGivenOut(
    SwapRequest memory swapRequest,
    uint256 balanceTokenIn,
    uint256 balanceTokenOut
  ) internal view virtual returns (uint256);
}

// SPDX-License-Identifier: GPL-3.0-or-later


pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "@mertaswap/solidity-utils/contracts/math/Math.sol";
import "@mertaswap/solidity-utils/contracts/math/FixedPoint.sol";
import "@mertaswap/solidity-utils/contracts/helpers/InputHelpers.sol";
import "@mertaswap/solidity-utils/contracts/openzeppelin/ERC20.sol";
import "@mertaswap/solidity-utils/contracts/helpers/TemporarilyPausable.sol";

import "./BalancerPoolToken.sol";
import "./BasePoolAuthorization.sol";
import "@mertaswap/interfaces/contracts/vault/IVault.sol";
import "@mertaswap/interfaces/contracts/vault/IBasePool.sol";


// solhint-disable max-states-count
abstract contract BasePool is IBasePool, BasePoolAuthorization, BalancerPoolToken, TemporarilyPausable {
  using FixedPoint for uint256;

  uint256 private constant _MIN_TOKENS = 2;
  uint256 private constant _MAX_TOKENS = 8;

  // 1e18 corresponds to 1.0, or a 100% fee
  uint256 private constant _MIN_SWAP_FEE_PERCENTAGE = 1e12; // 0.0001%
  uint256 private constant _MAX_SWAP_FEE_PERCENTAGE = 1e17; // 10%

  uint256 private constant _MINIMUM_BPT = 1e6;

  uint256 internal _swapFeePercentage;

  IVault private immutable _vault;
  bytes32 private immutable _poolId;
  uint256 private immutable _totalTokens;

  IERC20 internal immutable _token0;
  IERC20 internal immutable _token1;
  IERC20 internal immutable _token2;
  IERC20 internal immutable _token3;
  IERC20 internal immutable _token4;
  IERC20 internal immutable _token5;
  IERC20 internal immutable _token6;
  IERC20 internal immutable _token7;

  uint256 internal immutable _scalingFactor0;
  uint256 internal immutable _scalingFactor1;
  uint256 internal immutable _scalingFactor2;
  uint256 internal immutable _scalingFactor3;
  uint256 internal immutable _scalingFactor4;
  uint256 internal immutable _scalingFactor5;
  uint256 internal immutable _scalingFactor6;
  uint256 internal immutable _scalingFactor7;

  event SwapFeePercentageChanged(uint256 swapFeePercentage);

  constructor(
    IVault vault,
    IVault.PoolSpecialization specialization,
    string memory name,
    string memory symbol,
    IERC20[] memory tokens,
    uint256 swapFeePercentage,
    uint256 pauseWindowDuration,
    uint256 bufferPeriodDuration,
    address owner
  )
    Authentication(bytes32(uint256(msg.sender)))
    BalancerPoolToken(name, symbol)
    BasePoolAuthorization(owner)
    TemporarilyPausable(pauseWindowDuration, bufferPeriodDuration)
  {
    _require(tokens.length >= _MIN_TOKENS, Errors.MIN_TOKENS);
    _require(tokens.length <= _MAX_TOKENS, Errors.MAX_TOKENS);

    InputHelpers.ensureArrayIsSorted(tokens);

    _setSwapFeePercentage(swapFeePercentage);

    bytes32 poolId = vault.registerPool(specialization);

    vault.registerTokens(poolId, tokens, new address[](tokens.length));

    _vault = vault;
    _poolId = poolId;
    _totalTokens = tokens.length;

    _token0 = tokens.length > 0 ? tokens[0] : IERC20(0);
    _token1 = tokens.length > 1 ? tokens[1] : IERC20(0);
    _token2 = tokens.length > 2 ? tokens[2] : IERC20(0);
    _token3 = tokens.length > 3 ? tokens[3] : IERC20(0);
    _token4 = tokens.length > 4 ? tokens[4] : IERC20(0);
    _token5 = tokens.length > 5 ? tokens[5] : IERC20(0);
    _token6 = tokens.length > 6 ? tokens[6] : IERC20(0);
    _token7 = tokens.length > 7 ? tokens[7] : IERC20(0);

    _scalingFactor0 = tokens.length > 0 ? _computeScalingFactor(tokens[0]) : 0;
    _scalingFactor1 = tokens.length > 1 ? _computeScalingFactor(tokens[1]) : 0;
    _scalingFactor2 = tokens.length > 2 ? _computeScalingFactor(tokens[2]) : 0;
    _scalingFactor3 = tokens.length > 3 ? _computeScalingFactor(tokens[3]) : 0;
    _scalingFactor4 = tokens.length > 4 ? _computeScalingFactor(tokens[4]) : 0;
    _scalingFactor5 = tokens.length > 5 ? _computeScalingFactor(tokens[5]) : 0;
    _scalingFactor6 = tokens.length > 6 ? _computeScalingFactor(tokens[6]) : 0;
    _scalingFactor7 = tokens.length > 7 ? _computeScalingFactor(tokens[7]) : 0;
  }

  function getVault() public view returns (IVault) {
    return _vault;
  }

  function getPoolId() public view returns (bytes32) {
    return _poolId;
  }

  function _getTotalTokens() internal view returns (uint256) {
    return _totalTokens;
  }

  function getSwapFeePercentage() external view returns (uint256) {
    return _swapFeePercentage;
  }

  function setSwapFeePercentage(uint256 swapFeePercentage) external virtual authenticate whenNotPaused {
    _setSwapFeePercentage(swapFeePercentage);
  }

  function _setSwapFeePercentage(uint256 swapFeePercentage) private {
    _require(swapFeePercentage >= _MIN_SWAP_FEE_PERCENTAGE, Errors.MIN_SWAP_FEE_PERCENTAGE);
    _require(swapFeePercentage <= _MAX_SWAP_FEE_PERCENTAGE, Errors.MAX_SWAP_FEE_PERCENTAGE);

    _swapFeePercentage = swapFeePercentage;
    emit SwapFeePercentageChanged(swapFeePercentage);
  }

  function setPaused(bool paused) external authenticate {
    _setPaused(paused);
  }

  modifier onlyVault(bytes32 poolId) {
    _require(msg.sender == address(getVault()), Errors.CALLER_NOT_VAULT);
    _require(poolId == getPoolId(), Errors.INVALID_POOL_ID);
    _;
  }

  function onJoinPool(
    bytes32 poolId,
    address sender,
    address recipient,
    uint256[] memory balances,
    uint256 lastChangeBlock,
    uint256 protocolSwapFeePercentage,
    bytes memory userData
  ) external virtual override onlyVault(poolId) returns (uint256[] memory, uint256[] memory) {
    uint256[] memory scalingFactors = _scalingFactors();

    if (totalSupply() == 0) {
      (uint256 bptAmountOut, uint256[] memory amountsIn) = _onInitializePool(poolId, sender, recipient, userData);

      _require(bptAmountOut >= _MINIMUM_BPT, Errors.MINIMUM_BPT);
      _mintPoolTokens(address(0), _MINIMUM_BPT);
      _mintPoolTokens(recipient, bptAmountOut - _MINIMUM_BPT);

      _downscaleUpArray(amountsIn, scalingFactors);

      return (amountsIn, new uint256[](_getTotalTokens()));
    } else {
      _upscaleArray(balances, scalingFactors);
      (uint256 bptAmountOut, uint256[] memory amountsIn, uint256[] memory dueProtocolFeeAmounts) = _onJoinPool(
        poolId,
        sender,
        recipient,
        balances,
        lastChangeBlock,
        protocolSwapFeePercentage,
        userData
      );

      _mintPoolTokens(recipient, bptAmountOut);

      _downscaleUpArray(amountsIn, scalingFactors);
      _downscaleDownArray(dueProtocolFeeAmounts, scalingFactors);

      return (amountsIn, dueProtocolFeeAmounts);
    }
  }

  function onExitPool(
    bytes32 poolId,
    address sender,
    address recipient,
    uint256[] memory balances,
    uint256 lastChangeBlock,
    uint256 protocolSwapFeePercentage,
    bytes memory userData
  ) external virtual override onlyVault(poolId) returns (uint256[] memory, uint256[] memory) {
    uint256[] memory scalingFactors = _scalingFactors();
    _upscaleArray(balances, scalingFactors);

    (uint256 bptAmountIn, uint256[] memory amountsOut, uint256[] memory dueProtocolFeeAmounts) = _onExitPool(
      poolId,
      sender,
      recipient,
      balances,
      lastChangeBlock,
      protocolSwapFeePercentage,
      userData
    );


    _burnPoolTokens(sender, bptAmountIn);

    _downscaleDownArray(amountsOut, scalingFactors);
    _downscaleDownArray(dueProtocolFeeAmounts, scalingFactors);

    return (amountsOut, dueProtocolFeeAmounts);
  }

  function queryJoin(
    bytes32 poolId,
    address sender,
    address recipient,
    uint256[] memory balances,
    uint256 lastChangeBlock,
    uint256 protocolSwapFeePercentage,
    bytes memory userData
  ) external returns (uint256 bptOut, uint256[] memory amountsIn) {
    InputHelpers.ensureInputLengthMatch(balances.length, _getTotalTokens());

    _queryAction(
      poolId,
      sender,
      recipient,
      balances,
      lastChangeBlock,
      protocolSwapFeePercentage,
      userData,
      _onJoinPool,
      _downscaleUpArray
    );

    return (bptOut, amountsIn);
  }

  function queryExit(
    bytes32 poolId,
    address sender,
    address recipient,
    uint256[] memory balances,
    uint256 lastChangeBlock,
    uint256 protocolSwapFeePercentage,
    bytes memory userData
  ) external returns (uint256 bptIn, uint256[] memory amountsOut) {
    InputHelpers.ensureInputLengthMatch(balances.length, _getTotalTokens());

    _queryAction(
      poolId,
      sender,
      recipient,
      balances,
      lastChangeBlock,
      protocolSwapFeePercentage,
      userData,
      _onExitPool,
      _downscaleDownArray
    );

    return (bptIn, amountsOut);
  }

  function _onInitializePool(
    bytes32 poolId,
    address sender,
    address recipient,
    bytes memory userData
  ) internal virtual returns (uint256 bptAmountOut, uint256[] memory amountsIn);

  function _onJoinPool(
    bytes32 poolId,
    address sender,
    address recipient,
    uint256[] memory balances,
    uint256 lastChangeBlock,
    uint256 protocolSwapFeePercentage,
    bytes memory userData
  )
    internal
    virtual
    returns (
      uint256 bptAmountOut,
      uint256[] memory amountsIn,
      uint256[] memory dueProtocolFeeAmounts
    );

  function _onExitPool(
    bytes32 poolId,
    address sender,
    address recipient,
    uint256[] memory balances,
    uint256 lastChangeBlock,
    uint256 protocolSwapFeePercentage,
    bytes memory userData
  )
    internal
    virtual
    returns (
      uint256 bptAmountIn,
      uint256[] memory amountsOut,
      uint256[] memory dueProtocolFeeAmounts
    );

  function _addSwapFeeAmount(uint256 amount) internal view returns (uint256) {
    return amount.divUp(_swapFeePercentage.complement());
  }

  function _subtractSwapFeeAmount(uint256 amount) internal view returns (uint256) {
    uint256 feeAmount = amount.mulUp(_swapFeePercentage);
    return amount.sub(feeAmount);
  }

  function _computeScalingFactor(IERC20 token) private view returns (uint256) {
    uint256 tokenDecimals = ERC20(address(token)).decimals();

    uint256 decimalsDifference = Math.sub(18, tokenDecimals);
    return 10**decimalsDifference;
  }

  function _scalingFactor(IERC20 token) internal view returns (uint256) {
    // prettier-ignore
    if (token == _token0) { return _scalingFactor0; }
    else if (token == _token1) { return _scalingFactor1; }
    else if (token == _token2) { return _scalingFactor2; }
    else if (token == _token3) { return _scalingFactor3; }
    else if (token == _token4) { return _scalingFactor4; }
    else if (token == _token5) { return _scalingFactor5; }
    else if (token == _token6) { return _scalingFactor6; }
    else if (token == _token7) { return _scalingFactor7; }
    else {
      _revert(Errors.INVALID_TOKEN);
    }
  }

  function _scalingFactors() internal view returns (uint256[] memory) {
    uint256 totalTokens = _getTotalTokens();
    uint256[] memory scalingFactors = new uint256[](totalTokens);

    // prettier-ignore
    {
      if (totalTokens > 0) { scalingFactors[0] = _scalingFactor0; } else { return scalingFactors; }
      if (totalTokens > 1) { scalingFactors[1] = _scalingFactor1; } else { return scalingFactors; }
      if (totalTokens > 2) { scalingFactors[2] = _scalingFactor2; } else { return scalingFactors; }
      if (totalTokens > 3) { scalingFactors[3] = _scalingFactor3; } else { return scalingFactors; }
      if (totalTokens > 4) { scalingFactors[4] = _scalingFactor4; } else { return scalingFactors; }
      if (totalTokens > 5) { scalingFactors[5] = _scalingFactor5; } else { return scalingFactors; }
      if (totalTokens > 6) { scalingFactors[6] = _scalingFactor6; } else { return scalingFactors; }
      if (totalTokens > 7) { scalingFactors[7] = _scalingFactor7; } else { return scalingFactors; }
    }

    return scalingFactors;
  }

  function _upscale(uint256 amount, uint256 scalingFactor) internal pure returns (uint256) {
    return Math.mul(amount, scalingFactor);
  }

  function _upscaleArray(uint256[] memory amounts, uint256[] memory scalingFactors) internal view {
    for (uint256 i = 0; i < _getTotalTokens(); ++i) {
      amounts[i] = Math.mul(amounts[i], scalingFactors[i]);
    }
  }

  function _downscaleDown(uint256 amount, uint256 scalingFactor) internal pure returns (uint256) {
    return Math.divDown(amount, scalingFactor);
  }

  function _downscaleDownArray(uint256[] memory amounts, uint256[] memory scalingFactors) internal view {
    for (uint256 i = 0; i < _getTotalTokens(); ++i) {
      amounts[i] = Math.divDown(amounts[i], scalingFactors[i]);
    }
  }

  function _downscaleUp(uint256 amount, uint256 scalingFactor) internal pure returns (uint256) {
    return Math.divUp(amount, scalingFactor);
  }

  function _downscaleUpArray(uint256[] memory amounts, uint256[] memory scalingFactors) internal view {
    for (uint256 i = 0; i < _getTotalTokens(); ++i) {
      amounts[i] = Math.divUp(amounts[i], scalingFactors[i]);
    }
  }

  function _getAuthorizer() internal view override returns (IAuthorizer) {
    return getVault().getAuthorizer();
  }

  function _queryAction(
    bytes32 poolId,
    address sender,
    address recipient,
    uint256[] memory balances,
    uint256 lastChangeBlock,
    uint256 protocolSwapFeePercentage,
    bytes memory userData,
    function(bytes32, address, address, uint256[] memory, uint256, uint256, bytes memory)
      internal
      returns (uint256, uint256[] memory, uint256[] memory) _action,
    function(uint256[] memory, uint256[] memory) internal view _downscaleArray
  ) private {

    if (msg.sender != address(this)) {

      // solhint-disable-next-line avoid-low-level-calls
      (bool success, ) = address(this).call(msg.data);

      // solhint-disable-next-line no-inline-assembly
      assembly {
        switch success
          case 0 {
            returndatacopy(0, 0, 0x04)
            let error := and(mload(0), 0xffffffff00000000000000000000000000000000000000000000000000000000)

            if eq(eq(error, 0x43adbafb00000000000000000000000000000000000000000000000000000000), 0) {
              returndatacopy(0, 0, returndatasize())
              revert(0, returndatasize())
            }

            returndatacopy(0, 0x04, 32)

            mstore(0x20, 64)

            returndatacopy(0x40, 0x24, sub(returndatasize(), 36))

            return(0, add(returndatasize(), 28))
          }
          default {
            invalid()
          }
      }
    } else {
      uint256[] memory scalingFactors = _scalingFactors();
      _upscaleArray(balances, scalingFactors);

      (uint256 bptAmount, uint256[] memory tokenAmounts, ) = _action(
        poolId,
        sender,
        recipient,
        balances,
        lastChangeBlock,
        protocolSwapFeePercentage,
        userData
      );

      _downscaleArray(tokenAmounts, scalingFactors);

      // solhint-disable-next-line no-inline-assembly
      assembly {
        let size := mul(mload(tokenAmounts), 32)

        let start := sub(tokenAmounts, 0x20)
        mstore(start, bptAmount)

        mstore(sub(start, 0x20), 0x0000000000000000000000000000000000000000000000000000000043adbafb)
        start := sub(start, 0x04)

        revert(start, add(size, 68))
      }
    }
  }
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma experimental ABIEncoderV2;
import "../solidity-utils/openzeppelin/IERC20.sol";
import "../solidity-utils/helpers/IAuthentication.sol";
import "../solidity-utils/helpers/ISignaturesValidator.sol";
import "../solidity-utils/helpers/ITemporarilyPausable.sol";
import "../solidity-utils/misc/IWETH.sol";
import "./IAsset.sol";
import "./IAuthorizer.sol";
import "./IFlashLoanRecipient.sol";
import "./IProtocolFeesCollector.sol";
pragma solidity ^0.7.0;
interface IVault is ISignaturesValidator, ITemporarilyPausable, IAuthentication {
  function getAuthorizer() external view returns (IAuthorizer);
  function setAuthorizer(IAuthorizer newAuthorizer) external;
  event AuthorizerChanged(IAuthorizer indexed newAuthorizer);
  function hasApprovedRelayer(address user, address relayer) external view returns (bool);
  function setRelayerApproval(
    address sender,
    address relayer,
    bool approved
  ) external;
  event RelayerApprovalChanged(address indexed relayer, address indexed sender, bool approved);
  function getInternalBalance(address user, IERC20[] memory tokens) external view returns (uint256[] memory);
  function manageUserBalance(UserBalanceOp[] memory ops) external payable;
  struct UserBalanceOp {
    UserBalanceOpKind kind;
    IAsset asset;
    uint256 amount;
    address sender;
    address payable recipient;
  }
  enum UserBalanceOpKind { DEPOSIT_INTERNAL, WITHDRAW_INTERNAL, TRANSFER_INTERNAL, TRANSFER_EXTERNAL }
  event InternalBalanceChanged(address indexed user, IERC20 indexed token, int256 delta);
  event ExternalBalanceTransfer(IERC20 indexed token, address indexed sender, address recipient, uint256 amount);
  enum PoolSpecialization { GENERAL, MINIMAL_SWAP_INFO, TWO_TOKEN }
  function registerPool(PoolSpecialization specialization) external returns (bytes32);
  event PoolRegistered(bytes32 indexed poolId, address indexed poolAddress, PoolSpecialization specialization);
  function getPool(bytes32 poolId) external view returns (address, PoolSpecialization);
  function registerTokens(
    bytes32 poolId,
    IERC20[] memory tokens,
    address[] memory assetManagers
  ) external;
  event TokensRegistered(bytes32 indexed poolId, IERC20[] tokens, address[] assetManagers);
  function deregisterTokens(bytes32 poolId, IERC20[] memory tokens) external;
  event TokensDeregistered(bytes32 indexed poolId, IERC20[] tokens);
  function getPoolTokenInfo(bytes32 poolId, IERC20 token)
    external
    view
    returns (
      uint256 cash,
      uint256 managed,
      uint256 lastChangeBlock,
      address assetManager
    );
  function getPoolTokens(bytes32 poolId)
    external
    view
    returns (
      IERC20[] memory tokens,
      uint256[] memory balances,
      uint256 lastChangeBlock
    );
  function joinPool(
    bytes32 poolId,
    address sender,
    address recipient,
    JoinPoolRequest memory request
  ) external payable;
  struct JoinPoolRequest {
    IAsset[] assets;
    uint256[] maxAmountsIn;
    bytes userData;
    bool fromInternalBalance;
  }
  function exitPool(
    bytes32 poolId,
    address sender,
    address payable recipient,
    ExitPoolRequest memory request
  ) external;
  struct ExitPoolRequest {
    IAsset[] assets;
    uint256[] minAmountsOut;
    bytes userData;
    bool toInternalBalance;
  }
  event PoolBalanceChanged(
    bytes32 indexed poolId,
    address indexed liquidityProvider,
    IERC20[] tokens,
    int256[] deltas,
    uint256[] protocolFeeAmounts
  );
  enum PoolBalanceChangeKind { JOIN, EXIT }
  enum SwapKind { GIVEN_IN, GIVEN_OUT }
  function swap(
    SingleSwap memory singleSwap,
    FundManagement memory funds,
    uint256 limit,
    uint256 deadline
  ) external payable returns (uint256);
  struct SingleSwap {
    bytes32 poolId;
    SwapKind kind;
    IAsset assetIn;
    IAsset assetOut;
    uint256 amount;
    bytes userData;
  }
  function batchSwap(
    SwapKind kind,
    BatchSwapStep[] memory swaps,
    IAsset[] memory assets,
    FundManagement memory funds,
    int256[] memory limits,
    uint256 deadline
  ) external payable returns (int256[] memory);
  struct BatchSwapStep {
    bytes32 poolId;
    uint256 assetInIndex;
    uint256 assetOutIndex;
    uint256 amount;
    bytes userData;
  }
  event Swap(
    bytes32 indexed poolId,
    IERC20 indexed tokenIn,
    IERC20 indexed tokenOut,
    uint256 amountIn,
    uint256 amountOut
  );
  struct FundManagement {
    address sender;
    bool fromInternalBalance;
    address payable recipient;
    bool toInternalBalance;
  }
  function queryBatchSwap(
    SwapKind kind,
    BatchSwapStep[] memory swaps,
    IAsset[] memory assets,
    FundManagement memory funds
  ) external returns (int256[] memory assetDeltas);
  function flashLoan(
    IFlashLoanRecipient recipient,
    IERC20[] memory tokens,
    uint256[] memory amounts,
    bytes memory userData
  ) external;
  event FlashLoan(IFlashLoanRecipient indexed recipient, IERC20 indexed token, uint256 amount, uint256 feeAmount);
  function managePoolBalance(PoolBalanceOp[] memory ops) external;
  struct PoolBalanceOp {
    PoolBalanceOpKind kind;
    bytes32 poolId;
    IERC20 token;
    uint256 amount;
  }
  enum PoolBalanceOpKind { WITHDRAW, DEPOSIT, UPDATE }
  event PoolBalanceManaged(
    bytes32 indexed poolId,
    address indexed assetManager,
    IERC20 indexed token,
    int256 cashDelta,
    int256 managedDelta
  );
  function getProtocolFeesCollector() external view returns (IProtocolFeesCollector);
  function setPaused(bool paused) external;
  function WETH() external view returns (IWETH);
}

// SPDX-License-Identifier: GPL-3.0-or-later


pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "./IVault.sol";
import "./IPoolSwapStructs.sol";

interface IBasePool is IPoolSwapStructs {
  function onJoinPool(
    bytes32 poolId,
    address sender,
    address recipient,
    uint256[] memory balances,
    uint256 lastChangeBlock,
    uint256 protocolSwapFeePercentage,
    bytes memory userData
  ) external returns (uint256[] memory amountsIn, uint256[] memory dueProtocolFeeAmounts);

  function onExitPool(
    bytes32 poolId,
    address sender,
    address recipient,
    uint256[] memory balances,
    uint256 lastChangeBlock,
    uint256 protocolSwapFeePercentage,
    bytes memory userData
  ) external returns (uint256[] memory amountsOut, uint256[] memory dueProtocolFeeAmounts);
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.7.0;

interface IAuthorizer {
  function canPerform(
    bytes32 actionId,
    address account,
    address where
  ) external view returns (bool);
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.7.0;

import "@mertaswap/interfaces/contracts/solidity-utils/helpers/BalancerErrors.sol";
import "@mertaswap/interfaces/contracts/solidity-utils/helpers/IAuthentication.sol";


abstract contract Authentication is IAuthentication {
  bytes32 private immutable _actionIdDisambiguator;

  constructor(bytes32 actionIdDisambiguator) {
    _actionIdDisambiguator = actionIdDisambiguator;
  }

  modifier authenticate() {
    _authenticateCaller();
    _;
  }

  function _authenticateCaller() internal view {
    bytes32 actionId = getActionId(msg.sig);
    _require(_canPerform(actionId, msg.sender), Errors.SENDER_NOT_ALLOWED);
  }

  function getActionId(bytes4 selector) public view override returns (bytes32) {
    return keccak256(abi.encodePacked(_actionIdDisambiguator, selector));
  }

  function _canPerform(bytes32 actionId, address user) internal view virtual returns (bool);
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.7.0;

interface IAuthentication {
  function getActionId(bytes4 selector) external view returns (bytes32);
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.7.0;

interface ISignaturesValidator {
  function getDomainSeparator() external view returns (bytes32);
  function getNextNonce(address user) external view returns (uint256);
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.7.0;

import "../openzeppelin/IERC20.sol";

interface IWETH is IERC20 {
  function deposit() external payable;
  function withdraw(uint256 amount) external;
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.7.0;
interface IAsset {
  // solhint-disable-previous-line no-empty-blocks
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.7.0;

import "../solidity-utils/openzeppelin/IERC20.sol";

interface IFlashLoanRecipient {
  function receiveFlashLoan(
    IERC20[] memory tokens,
    uint256[] memory amounts,
    uint256[] memory feeAmounts,
    bytes memory userData
  ) external;
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;
import "../solidity-utils/openzeppelin/IERC20.sol";
import "./IVault.sol";
import "./IAuthorizer.sol";
interface IProtocolFeesCollector {
  event SwapFeePercentageChanged(uint256 newSwapFeePercentage);
  event FlashLoanFeePercentageChanged(uint256 newFlashLoanFeePercentage);
  function withdrawCollectedFees(
    IERC20[] calldata tokens,
    uint256[] calldata amounts,
    address recipient
  ) external;
  function setSwapFeePercentage(uint256 newSwapFeePercentage) external;
  function setFlashLoanFeePercentage(uint256 newFlashLoanFeePercentage) external;
  function getSwapFeePercentage() external view returns (uint256);
  function getFlashLoanFeePercentage() external view returns (uint256);
  function getCollectedFeeAmounts(IERC20[] memory tokens) external view returns (uint256[] memory feeAmounts);
  function getAuthorizer() external view returns (IAuthorizer);
  function vault() external view returns (IVault);
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "../solidity-utils/openzeppelin/IERC20.sol";

import "./IVault.sol";

interface IPoolSwapStructs {
  struct SwapRequest {
    IVault.SwapKind kind;
    IERC20 tokenIn;
    IERC20 tokenOut;
    uint256 amount;
    // Misc data
    bytes32 poolId;
    uint256 lastChangeBlock;
    address from;
    address to;
    bytes userData;
  }
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

contract FactoryWidePauseWindow {
  // solhint-disable not-rely-on-time

  uint256 private constant _INITIAL_PAUSE_WINDOW_DURATION = 0 days;
  uint256 private constant _BUFFER_PERIOD_DURATION = 0 days;

  uint256 private immutable _poolsPauseWindowEndTime;

  constructor() {
    _poolsPauseWindowEndTime = block.timestamp + _INITIAL_PAUSE_WINDOW_DURATION;
  }

  function getPauseConfiguration() public view returns (uint256 pauseWindowDuration, uint256 bufferPeriodDuration) {
    uint256 currentTime = block.timestamp;
    if (currentTime < _poolsPauseWindowEndTime) {
      pauseWindowDuration = _poolsPauseWindowEndTime - currentTime; // No need for checked arithmetic.
      bufferPeriodDuration = _BUFFER_PERIOD_DURATION;
    } else {
      pauseWindowDuration = 0;
      bufferPeriodDuration = 0;
    }
  }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "@mertaswap/solidity-utils/contracts/helpers/SingletonAuthentication.sol";
import "@mertaswap/interfaces/contracts/vault/IVault.sol";

import "@mertaswap/solidity-utils/contracts/helpers/BaseSplitCodeFactory.sol";

abstract contract BasePoolSplitCodeFactory is BaseSplitCodeFactory, SingletonAuthentication {
  mapping(address => bool) private _isPoolFromFactory;
  bool private _disabled;

  event PoolCreated(address indexed pool);
  event FactoryDisabled();

  constructor(IVault vault, bytes memory creationCode)
    BaseSplitCodeFactory(creationCode)
    SingletonAuthentication(vault)
  {
    // solhint-disable-previous-line no-empty-blocks
  }

  function isPoolFromFactory(address pool) external view returns (bool) {
    return _isPoolFromFactory[pool];
  }

  function isDisabled() public view returns (bool) {
    return _disabled;
  }

  function disable() external authenticate {
    _ensureEnabled();

    _disabled = true;

    emit FactoryDisabled();
  }

  function _ensureEnabled() internal view {
    _require(!isDisabled(), Errors.DISABLED);
  }

  function _create(bytes memory constructorArgs) internal override returns (address) {
    _ensureEnabled();

    address pool = super._create(constructorArgs);

    _isPoolFromFactory[pool] = true;
    emit PoolCreated(pool);

    return pool;
  }
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.7.0;

import "@mertaswap/interfaces/contracts/liquidity-mining/IAuthorizerAdaptor.sol";
import "@mertaswap/interfaces/contracts/vault/IVault.sol";

import "./Authentication.sol";

abstract contract SingletonAuthentication is Authentication {
  IVault private immutable _vault;

  constructor(IVault vault) Authentication(bytes32(uint256(address(this)))) {
    _vault = vault;
  }

  function getVault() public view returns (IVault) {
    return _vault;
  }

  function getAuthorizer() public view returns (IAuthorizer) {
    return getVault().getAuthorizer();
  }

  function _canPerform(bytes32 actionId, address account) internal view override returns (bool) {
    return getAuthorizer().canPerform(actionId, account, address(this));
  }

  function _canPerform(
    bytes32 actionId,
    address account,
    address where
  ) internal view returns (bool) {
    return getAuthorizer().canPerform(actionId, account, where);
  }
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "./CodeDeployer.sol";

abstract contract BaseSplitCodeFactory {
  address private immutable _creationCodeContractA;
  uint256 private immutable _creationCodeSizeA;

  address private immutable _creationCodeContractB;
  uint256 private immutable _creationCodeSizeB;

  constructor(bytes memory creationCode) {
    uint256 creationCodeSize = creationCode.length;

    uint256 creationCodeSizeA = creationCodeSize / 2;
    _creationCodeSizeA = creationCodeSizeA;

    uint256 creationCodeSizeB = creationCodeSize - creationCodeSizeA;
    _creationCodeSizeB = creationCodeSizeB;

    bytes memory creationCodeA;
    assembly {
      creationCodeA := creationCode
      mstore(creationCodeA, creationCodeSizeA)
    }

    _creationCodeContractA = CodeDeployer.deploy(creationCodeA);

    bytes memory creationCodeB;
    bytes32 lastByteA;

    assembly {
      creationCodeB := add(creationCode, creationCodeSizeA)
      lastByteA := mload(creationCodeB)
      mstore(creationCodeB, creationCodeSizeB)
    }

    _creationCodeContractB = CodeDeployer.deploy(creationCodeB);

    assembly {
      mstore(creationCodeA, creationCodeSize)
      mstore(creationCodeB, lastByteA)
    }
  }

  function getCreationCodeContracts() public view returns (address contractA, address contractB) {
    return (_creationCodeContractA, _creationCodeContractB);
  }

  function getCreationCode() public view returns (bytes memory) {
    return _getCreationCodeWithArgs("");
  }

  function _getCreationCodeWithArgs(bytes memory constructorArgs) private view returns (bytes memory code) {
    address creationCodeContractA = _creationCodeContractA;
    uint256 creationCodeSizeA = _creationCodeSizeA;
    address creationCodeContractB = _creationCodeContractB;
    uint256 creationCodeSizeB = _creationCodeSizeB;

    uint256 creationCodeSize = creationCodeSizeA + creationCodeSizeB;
    uint256 constructorArgsSize = constructorArgs.length;

    uint256 codeSize = creationCodeSize + constructorArgsSize;

    assembly {
      code := mload(0x40)
      mstore(0x40, add(code, add(codeSize, 32)))
      mstore(code, codeSize)
      let dataStart := add(code, 32)
      extcodecopy(creationCodeContractA, dataStart, 0, creationCodeSizeA)
      extcodecopy(creationCodeContractB, add(dataStart, creationCodeSizeA), 0, creationCodeSizeB)
    }

    uint256 constructorArgsDataPtr;
    uint256 constructorArgsCodeDataPtr;
    assembly {
      constructorArgsDataPtr := add(constructorArgs, 32)
      constructorArgsCodeDataPtr := add(add(code, 32), creationCodeSize)
    }

    _memcpy(constructorArgsCodeDataPtr, constructorArgsDataPtr, constructorArgsSize);
  }

  function _create(bytes memory constructorArgs) internal virtual returns (address) {
    bytes memory creationCode = _getCreationCodeWithArgs(constructorArgs);

    address destination;
    assembly {
      destination := create(0, add(creationCode, 32), mload(creationCode))
    }

    if (destination == address(0)) {
      assembly {
        returndatacopy(0, 0, returndatasize())
        revert(0, returndatasize())
      }
    }

    return destination;
  }

  function _memcpy(
    uint256 dest,
    uint256 src,
    uint256 len
  ) private pure {
    for (; len >= 32; len -= 32) {
      assembly {
        mstore(dest, mload(src))
      }
      dest += 32;
      src += 32;
    }

    uint256 mask = 256**(32 - len) - 1;
    assembly {
      let srcpart := and(mload(src), not(mask))
      let destpart := and(mload(dest), mask)
      mstore(dest, or(destpart, srcpart))
    }
  }
}

// SPDX-License-Identifier: GPL-3.0-or-later
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity ^0.7.0;

import "../solidity-utils/helpers/IAuthentication.sol";
import "../vault/IVault.sol";

interface IAuthorizerAdaptor is IAuthentication {
    /**
     * @notice Returns the Balancer Vault
     */
    function getVault() external view returns (IVault);

    /**
     * @notice Returns the Authorizer
     */
    function getAuthorizer() external view returns (IAuthorizer);

    /**
     * @notice Performs an arbitrary function call on a target contract, provided the caller is authorized to do so.
     * @param target - Address of the contract to be called
     * @param data - Calldata to be sent to the target contract
     * @return The bytes encoded return value from the performed function call
     */
    function performAction(address target, bytes calldata data) external payable returns (bytes memory);
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.7.0;
import "@mertaswap/interfaces/contracts/solidity-utils/helpers/BalancerErrors.sol";
library CodeDeployer {
  bytes32 private constant _DEPLOYER_CREATION_CODE = 0x602038038060206000396000f3fefefefefefefefefefefefefefefefefefefe;
  function deploy(bytes memory code) internal returns (address destination) {
    bytes32 deployerCreationCode = _DEPLOYER_CREATION_CODE;
    assembly {
      let codeLength := mload(code)
      mstore(code, deployerCreationCode)
      destination := create(0, code, add(codeLength, 32))
      mstore(code, codeLength)
    }
    _require(destination != address(0), Errors.CODE_DEPLOYMENT_FAILED);
  }
}

// SPDX-License-Identifier: GPL-3.0-or-later
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "@mertaswap/interfaces/contracts/vault/IVault.sol";

import "@mertaswap/pool-utils/contracts/factories/BasePoolSplitCodeFactory.sol";
import "@mertaswap/pool-utils/contracts/factories/FactoryWidePauseWindow.sol";

import "./WeightedPool.sol";

contract WeightedPoolFactory is BasePoolSplitCodeFactory, FactoryWidePauseWindow {
  constructor(IVault vault) BasePoolSplitCodeFactory(vault, type(WeightedPool).creationCode) {
    // solhint-disable-previous-line no-empty-blocks
  }

  /**
   * @dev Deploys a new `WeightedPool`.
   */
  function create(
    string memory name,
    string memory symbol,
    IERC20[] memory tokens,
    uint256[] memory weights,
    // address[] memory assetManagers,
    uint256 swapFeePercentage,
    address owner
  ) external returns (address) {
    (uint256 pauseWindowDuration, uint256 bufferPeriodDuration) = getPauseConfiguration();

    return
      _create(
        abi.encode(
          getVault(),
          name,
          symbol,
          tokens,
          weights,
          // assetManagers,
          swapFeePercentage,
          pauseWindowDuration,
          bufferPeriodDuration,
          owner
        )
      );
  }
}