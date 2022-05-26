// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import { IMovingWindowOracle } from "../interfaces/IMovingWindowOracle.sol";

contract PriceOracle {
  // FIXME: Uncomment for mainnet
  // address public constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; // WBNB MAINNET
  // address public constant USD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; // BUSD TESTNET
  // address public constant USD = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d; // USDC TESTNET
  ///////////////////////////////////////////////////////

  // FIXME: need to be removed for mainnet
  address public constant WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd; // WBNB TESTNET
  address public constant USD = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7; // BUSD TESTNET
  // address public constant USD = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd; // USDT TESTNET
  ///////////////////////////////////////////////////////

  address public tokenIn;
  bool public useBNBPath;
  uint8 public tokenInDecimals;
  uint8 public usdDecimals;
  IMovingWindowOracle public pancakeOracle;

  constructor(
    address _tokenIn,
    IMovingWindowOracle _pancakeOracle,
    bool _useBNBPath
  ) {
    tokenIn = _tokenIn;
    tokenInDecimals = IERC20Metadata(_tokenIn).decimals();
    usdDecimals = IERC20Metadata(USD).decimals();
    pancakeOracle = _pancakeOracle;
    useBNBPath = _useBNBPath;
  }

  function peek() public view returns (bytes32, bool) {
    uint256 oneTokenIn = 10**tokenInDecimals;
    uint256 oneTokenOut = 10**usdDecimals;
    uint256 amountOut;
    if (useBNBPath) {
      uint256 bnbAmountOut = pancakeOracle.consult(tokenIn, oneTokenIn, WBNB);
      amountOut = pancakeOracle.consult(WBNB, bnbAmountOut, USD);
    } else {
      amountOut = pancakeOracle.consult(tokenIn, oneTokenIn, USD);
    }
    uint256 price = (amountOut * 10**18) / oneTokenOut;
    return (bytes32(price), true);
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IMovingWindowOracle {
  function consult(
    address tokenIn,
    uint256 amountIn,
    address tokenOut
  ) external view returns (uint256 amountOut);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}