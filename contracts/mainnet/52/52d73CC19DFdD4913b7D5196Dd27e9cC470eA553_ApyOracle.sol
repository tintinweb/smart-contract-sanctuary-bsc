/**
 *Submitted for verification at BscScan.com on 2023-01-28
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
pragma solidity ^0.5.0;


/**
 * @dev Optional functions from the ERC20 standard.
 */
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
     * these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}
// File: contracts/ApyOracle.sol

pragma solidity 0.5.16;

contract IUniswapRouterV2 {
  function getAmountsOut(uint256 amountIn, address[] memory path) public view returns (uint256[] memory amounts);
}

interface IUniswapV2Pair {
  function token0() external view returns (address);
  function token1() external view returns (address);
  function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
  function totalSupply() external view returns (uint256);
}

contract ApyOracle {

  address public router;
  address public usdc;
  address public wNative; // This is address for wrapped native token of the ecosystem

  constructor (address _router, address _usdc, address _wNative) public {
    router = _router;
    usdc = _usdc;
    wNative = _wNative;
  }

  function getApy(
    address stakeToken,
    bool isUni,
    address token,
    uint256 incentive, // amount of token loaded into the contract
    uint256 howManyWeeks,
    address pool) public view returns (uint256) {
    address[] memory p = new address[](3);
    p[1] = wNative;
    p[2] = usdc;
    p[0] = token;
    uint256[] memory tokenPriceAmounts = IUniswapRouterV2(router).getAmountsOut(1e18, p);
    uint256 poolBalance = IERC20(stakeToken).balanceOf(pool);
    uint256 stakeTokenPrice = 1000000;
    p[0] = stakeToken;
    if (stakeToken != usdc) {
      if (isUni) {
        stakeTokenPrice = getUniPrice(IUniswapV2Pair(stakeToken));
      } else {
        uint256 unit = 10 ** uint256(ERC20Detailed(stakeToken).decimals());
        uint256[] memory stakePriceAmounts = IUniswapRouterV2(router).getAmountsOut(unit, p);
        stakeTokenPrice = stakePriceAmounts[2];
      }
    }
    uint256 temp = (
      1e8 * tokenPriceAmounts[2] * incentive * (52 / howManyWeeks)
    ) / (poolBalance * stakeTokenPrice);
    if (ERC20Detailed(stakeToken).decimals() == uint8(18)) {
      return temp;
    } else {
      uint256 divideBy = 10 ** uint256(18 - ERC20Detailed(stakeToken).decimals());
      return temp / divideBy;
    }
  }

  function getUniPrice(IUniswapV2Pair unipair) public view returns (uint256) {
    // find the token price that is not wNative
    (uint112 r0, uint112 r1, ) = unipair.getReserves();
    uint256 total = 0;
    if (unipair.token0() == wNative) {
      total = uint256(r0) * 2;
      uint256 singlePriceInWeth = 1e18 * total / unipair.totalSupply();
      address[] memory p = new address[](2);
      p[0] = wNative;
      p[1] = usdc;
      uint256[] memory prices = IUniswapRouterV2(router).getAmountsOut(1e18, p);
      return prices[1] * singlePriceInWeth / 1e18; // price of single token in USDC
    }
    else if (unipair.token1() == wNative) {
      total = uint256(r1) * 2;
      uint256 singlePriceInWeth = 1e18 * total / unipair.totalSupply();
      address[] memory p = new address[](2);
      p[0] = wNative;
      p[1] = usdc;
      uint256[] memory prices = IUniswapRouterV2(router).getAmountsOut(1e18, p);
      return prices[1] * singlePriceInWeth / 1e18; // price of single token in USDC
    }
     else {
      total = uint256(r1) * 2;
      address t1 = unipair.token1();
      address[] memory p = new address[](3);
      p[0] = t1;
      p[1] = wNative;
      p[2] = usdc;
      uint256[] memory prices = IUniswapRouterV2(router).getAmountsOut(1e18, p);
      uint256 tokenValue = prices[2] * total;
      return tokenValue/unipair.totalSupply();
    }

  }

  function getTvl(address pool, address token, bool isUniswap) public view returns (uint256) {
    uint256 balance = IERC20(token).balanceOf(pool);
    uint256 decimals = ERC20Detailed(token).decimals();
    if (balance == 0) {
      return 0;
    }
    if (!isUniswap) {
      address[] memory p = new address[](3);
      p[1] = wNative;
      p[2] = usdc;
      p[0] = token;
      uint256 one = 10 ** decimals;
      uint256[] memory amounts = IUniswapRouterV2(router).getAmountsOut(one, p);
      return amounts[2] * balance / (10 ** decimals);
    } else {
      uint256 price = getUniPrice(IUniswapV2Pair(token));
      return price * balance / (10 ** decimals);
    }
  }
  function tokenPerLP(address pool, address token) public view returns (uint256) {
    // Incase result is too small we multiply by 1*e18 to ensure we get a more precision
    uint256 tokenBalance = IERC20(token).balanceOf(pool);
    uint256 totalLP = IERC20(pool).totalSupply();
    uint256 result = (tokenBalance * 1e18) / totalLP;
    return result;
  }

  function batchUniPrices(address[] memory tokens) public view returns (uint256[] memory) {
    uint256[] memory prices = new uint256[](tokens.length);
    for(uint256 i = 0; i < tokens.length; i++) {
      prices[i] = getUniPrice(IUniswapV2Pair(tokens[i]));
    }
    return prices;
  }

  function batchTvl(address[] memory pool, address token, bool isUniswap) public view returns (uint256[] memory) {
    uint256[] memory tvl = new uint256[](pool.length);
    for(uint256 i = 0; i < pool.length; i++) {
      tvl[i] = getTvl(pool[i], token, isUniswap);
    }
    return tvl;
  }

  function batchAPY(
    address[] memory stakeTokens,
    bool isUni,
    address token,
    uint256 incentive,
    uint256 howManyWeeks,
    address[] memory pools) public view returns (uint256[] memory) {
    uint256[] memory apy =  new uint256[](stakeTokens.length);
    for(uint256 i = 0; i < stakeTokens.length; i++) {
      apy[i] = getApy(stakeTokens[i], isUni, token, incentive, howManyWeeks, pools[i]);
    }
    return apy;
  }
}