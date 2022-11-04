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

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

interface IPhoenix is IERC20Metadata {
  function getPairs() external view returns (address pair, address[] memory pathBuy, address[] memory pathSell);

  function endRound() external;

  function addLiquidity(uint256 tokens) external payable;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "./ISwapRouter02.sol";

interface IPhoenixTracker is IERC20Metadata {
  function tokenName() external view returns (string memory);

  function router() external view returns (ISwapRouter02);

  function tokenNameExpired() external view returns (string memory);

  function transfer(address sender, address from, address to, uint256 amount) external returns (bool);

  function approve(address owner, address spender, uint256 amount) external returns (bool);

  function burn(address account, uint256 amount) external;

  function swapBack() external;

  function syncFloorPrice(bool isBuy, uint256 tokens, address user) external returns (uint256 fees, uint256 burnTokens);

  function clearTokens(address addr) external;

  function isWhiteList(address addr) external view returns (bool);

  function getHolders() external view returns (address[] memory);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

interface ISwapFactory {
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

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

interface ISwapRouter01 {
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

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "./ISwapRouter01.sol";

interface ISwapRouter02 is ISwapRouter01 {
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

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

library Numbers {
  function percent(uint256 a, uint256 b) internal pure returns (uint256) {
    return (a * b) / 10000;
  }

  function percentOf(uint256 a, uint256 b) internal pure returns (uint256) {
    return (a * 10000) / b;
  }

  function discount(uint256 a, uint256 b) internal pure returns (uint256) {
    return a - percent(a, b);
  }

  function markup(uint256 a, uint256 b) internal pure returns (uint256) {
    return a + percent(a, b);
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    unchecked {
      return b > a ? 0 : a - b;
    }
  }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

library Router {
  function path(address a, address b) internal pure returns (address[] memory pathOut) {
    pathOut = new address[](2);
    pathOut[0] = a;
    pathOut[1] = b;
  }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "../interfaces/ISwapRouter02.sol";
import "../Ownable.sol";

abstract contract PhoenixCommon is Ownable {
  ISwapRouter02 internal _router;
  address internal _currency;
  address[] internal _pathBuy;
  address[] internal _pathSell;
  address internal _pair;

  function __PhoenixCommon_init_unchained() internal {
    //
  }

  function __PhoenixCommon_init() internal {
    __PhoenixCommon_init_unchained();
    __Ownable_init();
  }

  function _isUser(address addr) internal view returns (bool) {
    return addr != NULL_ADDRESS && addr != _pair && addr != address(_router) && addr != _contractAddress && addr != _otherAddr;
  }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IPayable {
  function sendFunds() external payable;
}

abstract contract Ownable {
  address internal constant NULL_ADDRESS = address(0);
  address internal _contractAddress;
  address internal _owner;
  address internal _otherAddr;

  modifier onlyOwner() {
    require(_isOwner());
    _;
  }

  modifier onlyAuth() {
    require(_isOther() || _isOwner());
    _;
  }

  modifier onlyOther() {
    require(_isOther());
    _;
  }

  function __Ownable_init() internal virtual {
    _contractAddress = address(this);
    _owner = msg.sender;
  }

  function _isOwner() internal view returns (bool) {
    return msg.sender == _owner;
  }

  function _isOther() internal view returns (bool) {
    return msg.sender == _otherAddr;
  }

  function setOwner(address owner) external onlyOwner {
    _owner = owner;
  }

  function setOtherAddr(address otherAddr) external onlyAuth {
    _otherAddr = otherAddr;
  }

  // emergency withdraw all stuck funds
  function withdrawETH(uint256 balance) external onlyOwner {
    if (balance == 0) {
      balance = _contractAddress.balance;
    }

    payable(msg.sender).transfer(balance);
  }

  // emergency withdraw all stuck tokens
  function withdrawToken(address tokenAddress, uint256 balance) external onlyOwner {
    IERC20 token = IERC20(tokenAddress);

    if (balance == 0) {
      balance = token.balanceOf(_contractAddress);
    }

    token.transfer(msg.sender, balance);
  }

  receive() external payable {}

  fallback() external payable {}

  function sendFunds() external payable {}
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

/*----------------------------------------------------------------------------------------------------+

██████╗░██╗░░██╗░█████╗░███████╗███╗░░██╗██╗██╗░░██╗   ██████╗░███████╗██╗░░░██╗██╗██╗░░░██╗███████╗
██╔══██╗██║░░██║██╔══██╗██╔════╝████╗░██║██║╚██╗██╔╝   ██╔══██╗██╔════╝██║░░░██║██║██║░░░██║██╔════╝
██████╔╝███████║██║░░██║█████╗░░██╔██╗██║██║░╚███╔╝░   ██████╔╝█████╗░░╚██╗░██╔╝██║╚██╗░██╔╝█████╗░░
██╔═══╝░██╔══██║██║░░██║██╔══╝░░██║╚████║██║░██╔██╗░   ██╔══██╗██╔══╝░░░╚████╔╝░██║░╚████╔╝░██╔══╝░░
██║░░░░░██║░░██║╚█████╔╝███████╗██║░╚███║██║██╔╝╚██╗   ██║░░██║███████╗░░╚██╔╝░░██║░░╚██╔╝░░███████╗
╚═╝░░░░░╚═╝░░╚═╝░╚════╝░╚══════╝╚═╝░░╚══╝╚═╝╚═╝░░╚═╝   ╚═╝░░╚═╝╚══════╝░░░╚═╝░░░╚═╝░░░╚═╝░░░╚══════╝


𝙊𝙣𝙚 𝘾𝙡𝙞𝙘𝙠 𝙄𝙣𝙨𝙩𝙖𝙣𝙩 𝙍𝙚𝙫𝙞𝙫𝙚:
The token has the ability to instantly relaunch itself every optimised opportunity!

𝘼𝙣𝙩𝙞-𝙙𝙪𝙢𝙥 𝙛𝙡𝙤𝙤𝙧 𝙥𝙧𝙞𝙘𝙚:
A dynamic floor price is set in which selling below it will incur a higher tax (50%).

𝙍𝙚𝙫𝙞𝙫𝙚 𝙙𝘼𝙥𝙥:
New and innovative solution for diamond holders of projects which have “died” whereby
the project owner can merge their holders and LP seamlessly into Phoenix Revive.

Website: https://phoenixrevive.io/
Telegram: http://t.me/PhoenixRevive
Announcements: https://t.me/PhoenixReviveNews
Twitter: https://twitter.com/PhoenixReviveW3
Discord: https://discord.gg/WKQNpKPjBf
Reddit: https://www.reddit.com/r/PhoenixRevive/
YouTube: https://www.youtube.com/channel/UC7nH1TMvY_6J-EvAyTc2G_Q
Email: [email protected]

𝙏𝙖𝙭 𝙎𝙮𝙨𝙩𝙚𝙢:
Buy: 5%, Sell: 5%
Treasury: 1%, Marketing: 2%, Liquidity Pool: 2%

**Note: When selling below floor price, sell tax will be 50%, half of which will be burned.

+----------------------------------------------------------------------------------------------------*/

import "./interfaces/IPhoenixTracker.sol";
import "./interfaces/IPhoenix.sol";
import "./interfaces/ISwapFactory.sol";
import "./libraries/Numbers.sol";
import "./libraries/Router.sol";
import "./main/PhoenixCommon.sol";

contract PhoenixRevive is IPhoenix, PhoenixCommon {
  using Numbers for uint256;

  uint8 public constant decimals = 18;
  bool public ended;
  bool private _liquid;

  constructor(address tracker) {
    __PhoenixCommon_init();
    _otherAddr = tracker;
    _router = IPhoenixTracker(_otherAddr).router();
    _currency = _router.WETH();
    _pair = ISwapFactory(_router.factory()).createPair(_currency, _contractAddress);
    _pathBuy = Router.path(_currency, _contractAddress);
    _pathSell = Router.path(_contractAddress, _currency);
  }

  function name() external view returns (string memory) {
    IPhoenixTracker tracker = IPhoenixTracker(_otherAddr);
    return ended ? tracker.tokenNameExpired() : tracker.tokenName();
  }

  function symbol() external view returns (string memory) {
    return IPhoenixTracker(_otherAddr).symbol();
  }

  function totalSupply() external view returns (uint256) {
    return ended ? 0 : IPhoenixTracker(_otherAddr).totalSupply();
  }

  function balanceOf(address account) external view returns (uint256) {
    return ended ? 0 : IPhoenixTracker(_otherAddr).balanceOf(account);
  }

  function transfer(address to, uint256 amount) external returns (bool) {
    return _transfer(msg.sender, to, amount);
  }

  function allowance(address owner, address spender) external view returns (uint256) {
    return IPhoenixTracker(_otherAddr).allowance(owner, spender);
  }

  function _approve(address owner, address spender, uint256 amount) private returns (bool) {
    return IPhoenixTracker(_otherAddr).approve(owner, spender, amount);
  }

  function approve(address spender, uint256 amount) external returns (bool) {
    return _approve(msg.sender, spender, amount);
  }

  function transferFrom(address from, address to, uint256 amount) external returns (bool) {
    return _transfer(from, to, amount);
  }

  function _transfer(address from, address to, uint256 amount) private returns (bool) {
    require(!ended, "ended");
    IPhoenixTracker tracker = IPhoenixTracker(_otherAddr);
    uint256 transferAmount = amount;
    uint256 fees = 0;
    uint256 burnTokens = 0;
    bool success = true;

    if (from == _contractAddress) {
      from = _otherAddr;
    }

    if (to == _contractAddress) {
      to = _otherAddr;
    }

    if (from != NULL_ADDRESS && to != NULL_ADDRESS && !_liquid) {
      bool isBuy = from == _pair && _isUser(to);
      bool isSell = to == _pair && _isUser(from);
      bool isWhiteList = tracker.isWhiteList(from) || tracker.isWhiteList(to);
      bool isTax = !isWhiteList && (isBuy || isSell);

      if (isTax) {
        address user = isBuy ? to : from;
        (fees, burnTokens) = tracker.syncFloorPrice(isBuy, amount, user);
        transferAmount = amount.sub(fees);
      }

      if (isSell && from != _otherAddr) {
        tracker.swapBack();
      }
    }

    success = tracker.transfer(msg.sender, from, to, transferAmount);
    emit Transfer(from, to, transferAmount);

    if (fees > 0) {
      success = tracker.transfer(from, from, _otherAddr, fees);
      emit Transfer(from, _otherAddr, fees);

      if (burnTokens > 0) {
        tracker.burn(_otherAddr, burnTokens);
        emit Transfer(_otherAddr, NULL_ADDRESS, burnTokens);
      }
    }

    return success;
  }

  function getPairs() external view returns (address pair, address[] memory pathBuy, address[] memory pathSell) {
    return (_pair, _pathBuy, _pathSell);
  }

  function endRound() external onlyOther {
    if (!ended) {
      _removeLiquidity(IERC20(_pair).balanceOf(_contractAddress));
      IPayable(_otherAddr).sendFunds{value: _contractAddress.balance}();
      IPhoenixTracker(_otherAddr).clearTokens(_pair);
      ended = true;
    }
  }

  function addLiquidity(uint256 tokens) external payable onlyAuth {
    _addLiquidity(msg.value, tokens);
  }

  function _addLiquidity(uint256 bnb, uint256 tokens) private {
    _liquid = _approve(_contractAddress, address(_router), tokens);
    _router.addLiquidityETH{value: bnb}(_contractAddress, tokens, 0, 0, _contractAddress, block.timestamp);
    _liquid = false;
  }

  function _removeLiquidity(uint256 liquidity) private {
    _liquid = IERC20(_pair).approve(address(_router), liquidity);
    _router.removeLiquidityETH(_contractAddress, liquidity, 0, 0, _contractAddress, block.timestamp);
    _liquid = false;
  }

  function initHolders() external onlyOwner {
    IPhoenixTracker tracker = IPhoenixTracker(_otherAddr);
    address[] memory holders = tracker.getHolders();

    // Sync holders without the need for an actual transfer
    // emitting a Transfer event is much more gas efficient and will show up on bscscan
    for (uint i = 0; i < holders.length; i++) {
      address account = holders[i];
      emit Transfer(NULL_ADDRESS, account, tracker.balanceOf(account));
    }
  }
}