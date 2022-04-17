// SPDX-License-Identifier: MIT

//       #~~
//      )#(
//     ( # )
//      ___
//     |   |
//     |   |
//     |   |
//     |   |
//     |   |
// ___ |   |
// \  \|   |
//  \  |   |
//  /-------\
// (_________)
//  \_______/  GANJA INU

pragma solidity ^0.8.4;
import './AddressUpgradeable.sol';
import "./Initializable.sol";
import './ContextUpgradeable.sol';
import './OwnableUpgradeable.sol';

interface IERC20Upgradeable {
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

interface IERC20MetadataUpgradeable is IERC20Upgradeable {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
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

library SafeMath {
  function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
      uint256 c = a + b;
      if (c < a) return (false, 0);
      return (true, c);
    }
  }

  function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
      if (b > a) return (false, 0);
      return (true, a - b);
    }
  }

  function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
      // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
      // benefit is lost if 'b' is also tested.
      // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
      if (a == 0) return (true, 0);
      uint256 c = a * b;
      if (c / a != b) return (false, 0);
      return (true, c);
    }
  }

  function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
      if (b == 0) return (false, 0);
      return (true, a / b);
    }
  }

  function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
      if (b == 0) return (false, 0);
      return (true, a % b);
    }
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    return a + b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return a - b;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    return a * b;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return a / b;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return a % b;
  }

  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    unchecked {
      require(b <= a, errorMessage);
      return a - b;
    }
  }

  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    unchecked {
      require(b > 0, errorMessage);
      return a / b;
    }
  }

  function mod(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    unchecked {
      require(b > 0, errorMessage);
      return a % b;
    }
  }
}

interface IPancakeRouter01 {
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

  function getAmountsOut(uint256 amountIn, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);

  function getAmountsIn(uint256 amountOut, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
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

interface IPancakeFactory {
  event PairCreated(
    address indexed token0,
    address indexed token1,
    address pair,
    uint256
  );

  function feeTo() external view returns (address);

  function feeToSetter() external view returns (address);

  function getPair(address tokenA, address tokenB)
    external
    view
    returns (address pair);

  function allPairs(uint256) external view returns (address pair);

  function allPairsLength() external view returns (uint256);

  function createPair(address tokenA, address tokenB)
    external
    returns (address pair);

  function setFeeTo(address) external;

  function setFeeToSetter(address) external;

  function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}

interface IPancakePair {
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);

  function name() external pure returns (string memory);

  function symbol() external pure returns (string memory);

  function decimals() external pure returns (uint8);

  function totalSupply() external view returns (uint256);

  function balanceOf(address owner) external view returns (uint256);

  function allowance(address owner, address spender)
    external
    view
    returns (uint256);

  function approve(address spender, uint256 value) external returns (bool);

  function transfer(address to, uint256 value) external returns (bool);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool);

  function DOMAIN_SEPARATOR() external view returns (bytes32);

  function PERMIT_TYPEHASH() external pure returns (bytes32);

  function nonces(address owner) external view returns (uint256);

  function permit(
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;

  event Mint(address indexed sender, uint256 amount0, uint256 amount1);
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
  event Sync(uint112 reserve0, uint112 reserve1);

  function MINIMUM_LIQUIDITY() external pure returns (uint256);

  function factory() external view returns (address);

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

  function skim(address to) external;

  function sync() external;

  function initialize(address, address) external;
}

interface IPancakeswap {
  function WETH() external pure returns (address);

  function getAmountOut(
    uint256 amountIn,
    uint256 reserveIn,
    uint256 reserveOut
  ) external pure returns (uint256 amountOut);

  function getReserves()
    external
    view
    returns (
      uint112 reserve0,
      uint112 reserve1,
      uint32 blockTimestampLast
    );

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

  function removeLiquidity(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountA, uint256 amountB);

  function getPair(address tokenA, address tokenB)
    external
    view
    returns (address pair);

  function sync() external;
}

contract GanjaInu is Initializable, IERC20Upgradeable, IERC20MetadataUpgradeable, ContextUpgradeable, OwnableUpgradeable {

  using SafeERC20Upgradeable for IERC20Upgradeable;
  using SafeMath for uint256;

  address public pcsV2Pair;
  IPancakeRouter02 public pcsV2Router;

  address pcsv2Router;
  address pcsv2Factory;

  address teamWallet;
  address marketingWallet;
  address buyBackWallet;

  //testnet
  address WBNB_BUSD_PAIR;
  address BUSD;

  mapping(address => uint256) private _balances;
  mapping(address => mapping(address => uint256)) private _allowances;

  uint256 private _totalSupply;
  string private _name;
  string private _symbol;

  uint256 public transferTax;
  uint256 public buyTax;
  uint256 public sellTax;

  uint256 public marketingFeeShare;
  uint256 public teamFeeShare;
  uint256 public buyBackFeeShare;

  uint256 previousBuyTax;
  uint256 previousSellTax;

  uint256 private swapFee;
  uint256 public totalBuys;
  uint256 public totalSells;

  mapping(address => bool) public isExcludedFromFees_;
  mapping(address => bool) public isBlacklisted_;

  uint256 public launchTime;
  uint256 private abt;
  uint256 public initialSupply;
  uint256 public ATH;

  bool public tradingEnabled;
  uint256 ds;

  string public telegram;
  string public website;
  string public audit;

  string public taxMode;

  bool private inSwap;

  uint8 public txCount;
  uint8 private swapTrigger;
  bool public inSwapAndLiquify;

  bool public swapAndLiquifyEnabled;
  bool public noFeeToTransfer;
  bool public autoTaxesEnabled;

  uint256 public tokensBurnt;

  event SwapAndLiquifyEnabledUpdated(bool enabled);
  event SwapAndLiquify(
    uint256 tokensSwapped,
    uint256 ethReceived,
    uint256 tokensIntoLiqudity
  );

  event setTaxesUpdate(
    uint256 buyTax_,
    uint256 buyTaxDenominator_,
    uint256 sellTax_,
    uint256 sellTaxDenominator_
  );
  event setFeeShareUpdate(
    uint256 marketingFeeShare_,
    uint256 teamFeeShare_,
    uint256 buyBackFeeShare_
  );
  event changeTaxMode(uint256 mode_, string taxMode);
  event changeTransferTax(uint256 tax_);
  event startTrading(uint256 ds);
  event changeFeeWallets(
    address marketingWallet_,
    address teamWallet_,
    address buyBackWallet_
  );
  event sentToWallet(address wallet, uint256 amount);
  event withdrawnBNB(address payout);
  event withdrawnBEP20(address payout, address token);
  event excludeFromFees(address account, bool isExcluded);
  event blacklist(address account, bool isBlacklisted);
  event swapLiquify(
    uint256 contractBNB,
    uint256 cBNB_Marketing,
    uint256 cBNB_Team,
    uint256 cBNB_buyBack
  );
  event swapTokensBNB(uint256 tokenAmount);

  modifier lockTheSwap() {
    inSwapAndLiquify = true;
    _;
    inSwapAndLiquify = false;
  }

  // function initialize() public initializer{
    
  //   //mainnet
  //   //pcsv2Router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
  //   //pcsv2Factory = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
  //   //WBNB_BUSD_PAIR = 0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16;
  //   //BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

  //   //testnet pcsRouter & factory
  //   pcsv2Router = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
  //   pcsv2Factory = 0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc;
  //   WBNB_BUSD_PAIR = 0xe0e92035077c39594793e61802a350347c320cf2;
  //   BUSD = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;

  //   teamWallet = payable(0xEC3C5E518bE0706247feFeEd51913eCaFA8C7B93);
  //   marketingWallet = payable(0x86A8C9b2Dc4F62Ca1F89b9fa4772bfA383080950);
  //   buyBackWallet = payable(0x6ffEb3bBA82D3bC39c0A7AeDa8afdac36A5dAD79);

  //   totalBuys = 0;
  //   totalSells = 0;

  //   tradingEnabled = false;

  //   inSwap = false;

  //   txCount = 0;
  //   swapTrigger = 3;
  //   inSwapAndLiquify;

  //   swapAndLiquifyEnabled = true;
  //   noFeeToTransfer = true;
  //   autoTaxesEnabled = false;

  //   _name = "GanjaInu";
  //   _symbol = "GINU";
  //   uint256 totalSupply_ = 420000000;

  //   __Ownable_init();

  //   telegram = "https://t.me/GanjaInuOfficial";
  //   website = "https://ganjainubsc.com";
  //   audit = "COMING SOON";

  //   buyTax = 4;
  //   sellTax = 20;
  //   transferTax = 2;

  //   marketingFeeShare = 10;
  //   teamFeeShare = 10;
  //   buyBackFeeShare = 80;

  //   previousBuyTax = buyTax;
  //   previousSellTax = sellTax;

  //   tokensBurnt = 0;
  //   ATH = 0;
  //   taxMode = "LAUNCH MODE";

  //   isExcludedFromFees_[owner()] = true;
  //   isExcludedFromFees_[teamWallet] = true;
  //   isExcludedFromFees_[marketingWallet] = true;
  //   isExcludedFromFees_[buyBackWallet] = true;
  //   isExcludedFromFees_[0x000000000000000000000000000000000000dEaD] = true;
  //   isExcludedFromFees_[address(0)] = true;

  //   IPancakeRouter02 _pancakeswapV2Router = IPancakeRouter02(pcsv2Router);

  //   pcsV2Pair = IPancakeFactory(_pancakeswapV2Router.factory()).createPair(
  //     address(this),
  //     _pancakeswapV2Router.WETH()
  //   );

  //   pcsV2Router = _pancakeswapV2Router;
  //   initialSupply = (totalSupply_ * 10**decimals());

  //   _mint(msg.sender, totalSupply_ * 10**decimals());
  // }

  function setSwapTrigger(uint8 swapTrigger_) public onlyOwner {
    swapTrigger = swapTrigger_;
  }

  function tranferFeeEnabled(bool _noFeeTransfer) public onlyOwner {
    noFeeToTransfer = _noFeeTransfer;
  }

  function setAutoTaxesEnabled(bool enabled_) public onlyOwner {
    autoTaxesEnabled = enabled_;
  }

  function setFeeShares(
    uint256 marketingFeeShare_,
    uint256 teamFeeShare_,
    uint256 buyBackFeeShare_
  ) public onlyOwner {
    require(
      marketingFeeShare_.add(teamFeeShare_).add(buyBackFeeShare_) == 100,
      "GanjaInu: Share1 + Share2 + Share3 != 100"
    );
    marketingFeeShare = marketingFeeShare_;
    teamFeeShare = teamFeeShare_;
    buyBackFeeShare = buyBackFeeShare_;
    emit setFeeShareUpdate(marketingFeeShare_, teamFeeShare_, buyBackFeeShare_);
  }

  function setSocials(
    string memory telegram_,
    string memory website_,
    string memory audit_
  ) public onlyOwner {
    telegram = telegram_;
    website = website_;
    audit = audit_;
  }

  function openTrading(uint256 t_) public onlyOwner {
    tradingEnabled = true;
    launchTime = block.timestamp;
    abt = launchTime.add(t_);
    emit startTrading(t_);
  }

  function toggleExcludeFromFees(address account_) public onlyOwner {
    require(
      account_ != address(0),
      "GanjaInu: Cannot exlude the dead address from fees."
    );
    if (isExcludedFromFees_[account_] == true) {
      isExcludedFromFees_[account_] = false;
      emit excludeFromFees(account_, false);
    } else if (isExcludedFromFees_[account_] == false) {
      isExcludedFromFees_[account_] = true;
      emit excludeFromFees(account_, true);
    }
  }

  function toggleBlacklist(address account_) public onlyOwner {
    require(
      account_ != address(0),
      "GanjaInu: Cannot blacklist the dead address."
    );
    if (isBlacklisted_[account_] == true) {
      isBlacklisted_[account_] = false;
      emit blacklist(account_, false);
    } else if (isBlacklisted_[account_] == false) {
      isBlacklisted_[account_] = true;
      emit blacklist(account_, true);
    }
  }

  function compare(string memory a, string memory b)
    internal
    view
    returns (bool)
  {
    return (keccak256(abi.encodePacked((a))) ==
      keccak256(abi.encodePacked((b))));
  }

  function toggleModes(uint256 mode_) internal {
    if (mode_ == 1 && !compare(taxMode, "STONED MODE")) {
      buyTax = 1;
      sellTax = 4;
      marketingFeeShare = 24;
      teamFeeShare = 24;
      buyBackFeeShare = 52;
      taxMode = "STONED MODE";
    } else if (mode_ == 2 && !compare(taxMode, "420 MODE")) {
      buyTax = 4;
      sellTax = 4;
      marketingFeeShare = 24;
      teamFeeShare = 24;
      buyBackFeeShare = 52;
      taxMode = "420 MODE";
    } else if (mode_ == 3 && !compare(taxMode, "MUNCHIE MODE")) {
      buyTax = 4;
      sellTax = 20;
      marketingFeeShare = 10;
      teamFeeShare = 10;
      buyBackFeeShare = 80;
      taxMode = "MUNCHIE MODE";
    }
    emit changeTaxMode(mode_, taxMode);
  }

  function bnbPrice() public view returns (uint256 BNBUSDprice) {
    uint256 wbnbReserve = IERC20Upgradeable(IPancakeswap(pcsv2Router).WETH()).balanceOf(
      WBNB_BUSD_PAIR
    );
    uint256 busdReserve = IERC20Upgradeable(BUSD).balanceOf(WBNB_BUSD_PAIR);
    BNBUSDprice = busdReserve / wbnbReserve;
  }

  function getGanjaInuPrice() public view returns (uint256) {
    address tLP = IPancakeswap(pcsv2Factory).getPair(
      IPancakeswap(pcsv2Router).WETH(),
      address(this)
    );
    uint256 WBNB_Reserve = IERC20Upgradeable(IPancakeswap(pcsv2Router).WETH()).balanceOf(
      tLP
    );
    uint256 ganjaInuReserve = _balances[tLP];
    return ((WBNB_Reserve * 10**18) / ganjaInuReserve) * bnbPrice();
  }

  function setTransferTax(uint256 transferTax_) public onlyOwner {
    transferTax = transferTax_;
    emit changeTransferTax(transferTax_);
  }

  function getTotalTax() public view returns (uint256) {
    return buyTax.add(sellTax);
  }

  function getTotalBuys() public view returns (uint256) {
    return totalBuys;
  }

  function getTotalSells() public view returns (uint256) {
    return totalSells;
  }

  function getTotalTrades() public view returns (uint256) {
    return totalBuys.add(totalSells);
  }

  function buyBackWalletBalance() public view returns (uint256) {
    return address(buyBackWallet).balance;
  }

  function setFeeWallets(
    address marketingWallet_,
    address teamWallet_,
    address buyBackWallet_
  ) public onlyOwner {
    teamWallet = teamWallet_;
    marketingWallet = marketingWallet_;
    buyBackWallet = buyBackWallet_;
    emit changeFeeWallets(marketingWallet_, teamWallet_, buyBackWallet_);
  }

  function setTaxes(
    uint256 buyTax_,
    uint256 buyTaxDenominator_,
    uint256 sellTax_,
    uint256 sellTaxDenominator_
  ) public onlyOwner {
    uint256 bTax = buyTax_.div(buyTaxDenominator_);
    uint256 sTax = sellTax_.div(sellTaxDenominator_);

    require(bTax <= 30, "GanjaInu: Buy tax cannot be greater than 30%");
    require(sTax <= 30, "GanjaInu: Sell tax cannot be greater than 30%");

    previousBuyTax = bTax;
    previousSellTax = sTax;

    buyTax = bTax;
    sellTax = sTax;
    taxMode = "CUSTOM";

    emit setTaxesUpdate(
      buyTax_,
      buyTaxDenominator_,
      sellTax_,
      sellTaxDenominator_
    );
  }

  function name() public view virtual override returns (string memory) {
    return _name;
  }

  function symbol() public view virtual override returns (string memory) {
    return _symbol;
  }

  function decimals() public view virtual override returns (uint8) {
    return 18;
  }

  function totalSupply() public view virtual override returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account)
    public
    view
    virtual
    override
    returns (uint256)
  {
    return _balances[account];
  }

  receive() external payable {}

  function transfer(address recipient, uint256 amount)
    public
    override
    returns (bool)
  {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) public override returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(
      sender,
      _msgSender(),
      _allowances[sender][_msgSender()].sub(
        amount,
        "GanjaInu: transfer amount exceeds allowance"
      )
    );
    return true;
  }

  function allowance(address owner, address spender)
    public
    view
    virtual
    override
    returns (uint256)
  {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount)
    public
    virtual
    override
    returns (bool)
  {
    address owner = _msgSender();
    _approve(owner, spender, amount);
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue)
    public
    virtual
    returns (bool)
  {
    address owner = _msgSender();
    _approve(owner, spender, allowance(owner, spender) + addedValue);
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue)
    public
    virtual
    returns (bool)
  {
    address owner = _msgSender();
    uint256 currentAllowance = allowance(owner, spender);
    require(
      currentAllowance >= subtractedValue,
      "GanjaInu: decreased allowance below zero"
    );
    unchecked {
      _approve(owner, spender, currentAllowance - subtractedValue);
    }

    return true;
  }

  function removeAllFee() private {
    if (buyTax == 0 && sellTax == 0) return;
    previousBuyTax = buyTax;
    previousSellTax = sellTax;
    buyTax = 0;
    sellTax = 0;
  }

  function restoreAllFee() private {
    buyTax = previousBuyTax;
    sellTax = previousSellTax;
  }

  function _transfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual {
    require(from != address(0), "GanjaInu: transfer from the zero address");
    require(to != address(0), "GanjaInu: transfer to the zero address");
    require(isBlacklisted_[from] == false, "GanjaInu: Sender is blacklisted");
    require(isBlacklisted_[to] == false, "GanjaInu: Reciever is blacklisted");

    uint256 fromBalance = _balances[from];

    require(fromBalance >= amount, "GanjaInu: transfer amount exceeds balance");

    if (!isExcludedFromFees_[from] && !isExcludedFromFees_[to]) {
      require(tradingEnabled == true, "GanjaInu: Trading is not open yet");
    }

    bool takeFee = true;

    //transfer
    if (from != pcsV2Pair && to != pcsV2Pair) {

      if (!noFeeToTransfer) {
        if(isExcludedFromFees_[from] || isExcludedFromFees_[to]){
          _basicTransfer(from, to, amount);
        } else {
          _takeFeeWithTransferTax(from, to, amount);
        }
      } else if (noFeeToTransfer) {
        _basicTransfer(from, to, amount);
      }

    } else {

      // SwapAndLiquify is triggered after every X transactions - this number can be adjusted using swapTrigger
      if (
        txCount >= swapTrigger &&
        from != pcsV2Pair &&
        !inSwapAndLiquify &&
        swapAndLiquifyEnabled
      ) {
        txCount = 0;
        uint256 contractTokenBalance = balanceOf(address(this));
        if (contractTokenBalance > 0) {
          swapAndLiquify(contractTokenBalance);
          _balances[address(this)] = 0;
        }
      }

      //swapping
      if (isExcludedFromFees_[from] || isExcludedFromFees_[to]) {
        takeFee = false;
      } else if (from == pcsV2Pair) {
        swapFee = buyTax;
        totalBuys++;
      } else if (to == pcsV2Pair) {
        swapFee = sellTax;
        totalSells++;
      }

      if(!isExcludedFromFees_[from] || isExcludedFromFees_[to]){
        if (block.timestamp <= abt) {
          if (from != pcsV2Pair) {
            isBlacklisted_[from] = true;
          } else if (to != pcsV2Pair) {
            isBlacklisted_[to] = true;
          }
        }
      }

      _tokenTransfer(from, to, amount, takeFee);
    }

    if (tradingEnabled) {
      uint256 currentPrice = getGanjaInuPrice();

      if (currentPrice > ATH) {
        ATH = currentPrice;
      }

      //calculate the auto taxes if its enabled
      if (autoTaxesEnabled) {
        if (
          currentPrice <= ATH && currentPrice >= ATH.sub(ATH.mul(20).div(100))
        ) {
          toggleModes(1); //stoned mode
        } else if (
          currentPrice <= ATH.sub(ATH.mul(21).div(100)) &&
          currentPrice >= ATH.sub(ATH.mul(70).div(100))
        ) {
          toggleModes(2); //420 mode
        } else if (currentPrice <= ATH.sub(ATH.mul(71).div(100))) {
          toggleModes(3); //munchie mode
        }
      }
    }
  }

  function _tokenTransfer(
    address sender,
    address recipient,
    uint256 amount,
    bool takeFee
  ) private {
    if (!takeFee) {
      removeAllFee();
    } else {
      txCount++;
    }

    _transferTokens(sender, recipient, amount);

    if (!takeFee) restoreAllFee();
  }

  function _transferTokens(
    address sender,
    address recipient,
    uint256 tAmount
  ) private {
    (
      uint256 tTransferAmount,
      uint256 totalFee
    ) = _getValues(tAmount);

    _balances[sender] = _balances[sender].sub(tAmount);
    _balances[recipient] = _balances[recipient].add(tTransferAmount);
    _balances[address(this)] = _balances[address(this)].add(totalFee);

    emit Transfer(sender, recipient, tTransferAmount);
  }

  function _getValues(uint256 tAmount)
    private
    view
    returns (
      uint256,
      uint256
    )
  {
    uint256 totalFee = tAmount.mul(swapFee).div(100);
    uint256 tTransferAmount = tAmount.sub(totalFee);
    return (tTransferAmount, totalFee);
  }

  // Send BNB to external wallet
  function sendToWallet(address wallet, uint256 amount) private {
    payable(wallet).transfer(amount);
    emit sentToWallet(wallet, amount);
  }

  function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
    swapTokensForBNB(contractTokenBalance);
    uint256 contractBNB = address(this).balance;
    uint256 cBNB_Marketing = contractBNB.mul(marketingFeeShare).div(100);
    uint256 cBNB_Team = contractBNB.mul(teamFeeShare).div(100);
    uint256 cBNB_buyBack = contractBNB.mul(buyBackFeeShare).div(100);
    sendToWallet(marketingWallet, cBNB_Marketing);
    sendToWallet(teamWallet, cBNB_Team);
    sendToWallet(buyBackWallet, cBNB_buyBack);
    emit swapLiquify(contractBNB, cBNB_Marketing, cBNB_Team, cBNB_buyBack);
  }

  function swapTokensForBNB(uint256 tokenAmount) private {
    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = pcsV2Router.WETH();
    _approve(address(this), address(pcsV2Router), tokenAmount);
    IPancakeRouter02(pcsV2Router)
      .swapExactTokensForETHSupportingFeeOnTransferTokens(
        tokenAmount,
        0,
        path,
        address(this),
        block.timestamp
      );
    emit swapTokensBNB(tokenAmount);
  }

  function _mint(address account, uint256 amount) internal virtual {
    require(account != address(0), "GanjaInu: mint to the zero address");
    _totalSupply += amount;
    _balances[account] += amount;
    emit Transfer(address(0), account, amount);
  }

  function _basicTransfer(
    address from,
    address to,
    uint256 amount
  ) internal {
    uint256 fromBalance = _balances[from];
    uint256 toBalance = _balances[to];
    _balances[from] = fromBalance.sub(amount);
    _balances[to] = toBalance.add(amount);
    emit Transfer(from, to, amount);
  }

  function _takeFeeWithTransferTax(
    address from,
    address to,
    uint256 amount
  ) internal {
    uint256 teamWalletAmount = amount.mul(transferTax).div(100);
    uint256 transferAmount = amount.sub(teamWalletAmount);
    _basicTransfer(from, teamWallet, teamWalletAmount);
    _basicTransfer(from, to, transferAmount);
  }

  function commitBurn(address account_, uint256 amount_) public onlyOwner {
    require(
      amount_ <= totalSupply(),
      "GanjaInu: Burnable amount must be less than the total supply"
    );
    _burn(account_, amount_);
    tokensBurnt = tokensBurnt.add(amount_);
  }

  function _burn(address account, uint256 amount) internal virtual {
    require(account != address(0), "GanjaInu: burn from the zero address");

    uint256 accountBalance = _balances[account];

    require(accountBalance >= amount, "GanjaInu: burn amount exceeds balance");

    unchecked {
      _balances[account] = accountBalance - amount;
    }

    _totalSupply -= amount;
    emit Transfer(account, address(0), amount);
  }

  function _approve(
    address owner,
    address spender,
    uint256 amount
  ) internal virtual {
    require(owner != address(0), "GanjaInu: approve from the zero address");
    require(spender != address(0), "GanjaInu: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function _spendAllowance(
    address owner,
    address spender,
    uint256 amount
  ) internal virtual {
    uint256 currentAllowance = allowance(owner, spender);
    if (currentAllowance != type(uint256).max) {
      require(currentAllowance >= amount, "GanjaInu: insufficient allowance");
      unchecked {
        _approve(owner, spender, currentAllowance - amount);
      }
    }
  }

  function withdrawBNB(address payout) public onlyOwner {
    payable(payout).transfer(address(this).balance);
    emit withdrawnBNB(payout);
  }

  function withdrawBEP20(address payout, address token) public onlyOwner {
    uint256 balance = IERC20Upgradeable(token).balanceOf(address(this));
    IERC20Upgradeable(token).transfer(payout, balance);
    emit withdrawnBEP20(payout, token);
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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

pragma solidity ^0.8.2;
import './AddressUpgradeable.sol';

abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}

pragma solidity ^0.8.0;
import "./Initializable.sol";

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

pragma solidity ^0.8.0;

import './Initializable.sol';
import './ContextUpgradeable.sol';

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}