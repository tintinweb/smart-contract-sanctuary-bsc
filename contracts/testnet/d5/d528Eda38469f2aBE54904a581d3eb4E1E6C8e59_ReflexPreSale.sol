// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
abstract contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor () {
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
}

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
  /**
   * @dev Emitted when the pause is triggered by `account`.
   */
  event Paused(address account);

  /**
   * @dev Emitted when the pause is lifted by `account`.
   */
  event Unpaused(address account);

  bool private _paused;

  /**
   * @dev Initializes the contract in unpaused state.
   */
  constructor () {
      _paused = false;
  }

  /**
   * @dev Returns true if the contract is paused, and false otherwise.
   */
  function paused() public view virtual returns (bool) {
      return _paused;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   *
   * Requirements:
   *
   * - The contract must not be paused.
   */
  modifier whenNotPaused() {
      require(!paused(), "Pausable: paused");
      _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   *
   * Requirements:
   *
   * - The contract must be paused.
   */
  modifier whenPaused() {
      require(paused(), "Pausable: not paused");
      _;
  }

  /**
   * @dev Triggers stopped state.
   *
   * Requirements:
   *
   * - The contract must not be paused.
   */
  function _pause() internal virtual whenNotPaused {
      _paused = true;
      emit Paused(_msgSender());
  }

  /**
   * @dev Returns to normal state.
   *
   * Requirements:
   *
   * - The contract must be paused.
   */
  function _unpause() internal virtual whenPaused {
      _paused = false;
      emit Unpaused(_msgSender());
  }
}

/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale,
 * allowing investors to purchase tokens with ether. This contract implements
 * such functionality in its most fundamental form and can be extended to provide additional
 * functionality and/or custom behavior.
 * The external interface represents the basic interface for purchasing tokens, and conform
 * the base architecture for crowdsales. They are *not* intended to be modified / overriden.
 * The internal interface conforms the extensible and modifiable surface of crowdsales. Override
 * the methods to add functionality. Consider using 'super' where appropiate to concatenate
 * behavior.
 */
abstract contract Crowdsale {

  // The token being sold
  IERC20 public token;

  //token decimal
  uint256 public tokenDecimal;

  // How many token units a buyer gets per wei
  uint256 public rate;

  // Amount of wei raised
  uint256 public weiRaised;

  // tokens sold
  uint256 public tokensSold;

  // tracking user bnb balance
  mapping (address => uint256) public userBnbBalance;

  // tracking user token balance
  mapping (address => uint256) public userTokenBalance;


  /**
   * Event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(
    address indexed purchaser,
    address indexed beneficiary,
    uint256 value,
    uint256 amount
  );

  struct IntializeParams {
      uint256 minimumBuyLimit;
      uint256 maximumBuyLimit;
      uint256 softcap;
      uint256 hardcap;
  }

  IntializeParams public params;

  /**
   * @param _rate Number of token units a buyer gets per wei
   * @param _token Address of the token being sold
   */
  constructor(uint256 _rate, IERC20 _token) {
    require(_rate > 0, "Rate cant be 0");

    rate = _rate;
    token = _token;
    tokenDecimal = token.decimals();
  }

  // -----------------------------------------
  // Crowdsale external interface
  // -----------------------------------------

  /**
   * @dev fallback function ***DO NOT OVERRIDE***
   */
  receive () external payable {
    buyTokens(msg.sender);
  }

  /**
   * @dev low level token purchase ***DO NOT OVERRIDE***
   * @param _beneficiary Address performing the token purchase
   */
  function buyTokens(address _beneficiary) internal {
    uint256 weiAmount = msg.value;
    _preValidatePurchase(_beneficiary, weiAmount);

    // calculate token amount to be created
    uint256 tokens = _getTokenAmount(weiAmount);
    tokensSold += tokens;

    // update state
    weiRaised = weiRaised + weiAmount;
    require(weiRaised <= params.hardcap , "Buy Token: Sale reached hardcap.");
    userBnbBalance[_beneficiary] += weiAmount;
    userTokenBalance[_beneficiary] += tokens;

    emit TokenPurchase(
      msg.sender,
      _beneficiary,
      weiAmount,
      tokens
    );
  }



  // -----------------------------------------
  // Internal interface (extensible)
  // -----------------------------------------

  /**
   * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use super to concatenate validations.
   * @param _beneficiary Address performing the token purchase
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _preValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
    virtual
  {
    require(_beneficiary != address(0), "Address cant be zero address");
    require(_weiAmount != 0, "Amount cant be 0");
    require(_weiAmount >= params.minimumBuyLimit && _weiAmount <= params.maximumBuyLimit , "Buy Token: BNB amount exceeds minimum and maximum limit.");
  }

  /**
   * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.
   * @param _beneficiary Address performing the token purchase
   * @param _tokenAmount Number of tokens to be emitted
   */
  function _deliverTokens(
    address _beneficiary,
    uint256 _tokenAmount
  )
    internal
  {
    token.transfer(_beneficiary, _tokenAmount);
  }

  /**
   * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.
   * @param _beneficiary Address receiving the tokens
   * @param _tokenAmount Number of tokens to be purchased
   */
  function _processPurchase(
    address _beneficiary,
    uint256 _tokenAmount
  )
    internal
  {
    _deliverTokens(_beneficiary, _tokenAmount);
  }

  /**
   * @dev Override to extend the way in which ether is converted to tokens.
   * @param _weiAmount Value in wei to be converted into tokens
   * @return Number of tokens that can be purchased with the specified _weiAmount
   */
  function _getTokenAmount(uint256 _weiAmount)
    internal view returns (uint256)
  {
    if(tokenDecimal <= 18) {
      return _weiAmount / 10 ** (18-tokenDecimal) * rate;
    } else {
      return _weiAmount * 10 ** (tokenDecimal-18) * rate;
    }
  }

  /**
   * @dev Change Rate.
   * @param newRate Crowdsale rate
   */
  function _changeRate(uint256 newRate) virtual internal {
    rate = newRate;
  }

  /**
    * @dev Change Token.
    * @param newToken Crowdsale token
    */
  function _changeToken(IERC20 newToken) virtual internal {
    token = newToken;
  }
}

/**
 * @title TimedCrowdsale
 * @dev Crowdsale accepting contributions only within a time frame.
 */
abstract contract TimedCrowdsale is Crowdsale {
  uint256 public openingTime;
  uint256 public closingTime;

  event TimedCrowdsaleExtended(uint256 prevClosingTime, uint256 newClosingTime);

  /**
   * @dev Reverts if not in crowdsale time range.
   */
  modifier onlyWhileOpen {
    // solium-disable-next-line security/no-block-members
    require(block.timestamp >= openingTime && block.timestamp <= closingTime, "Crowdsale has not started or has been ended");
    _;
  }

  /**
   * @dev Constructor, takes crowdsale opening and closing times.
   * @param _openingTime Crowdsale opening time
   * @param _closingTime Crowdsale closing time
   */
  constructor(uint256 _openingTime, uint256 _closingTime) {
    // solium-disable-next-line security/no-block-members
    require(_openingTime >= block.timestamp, "OpeningTime must be greater than current timestamp");
    require(_closingTime >= _openingTime, "Closing time cant be before opening time");

    openingTime = _openingTime;
    closingTime = _closingTime;
  }

  /**
   * @dev Checks whether the period in which the crowdsale is open has already elapsed.
   * @return Whether crowdsale period has elapsed
   */
  function hasClosed() public view returns (bool) {
    // solium-disable-next-line security/no-block-members
    return block.timestamp > closingTime;
  }

  /**
   * @dev Extend crowdsale.
   * @param newClosingTime Crowdsale closing time
   */
  function _extendTime(uint256 newClosingTime) internal {
    closingTime = newClosingTime;
    emit TimedCrowdsaleExtended(closingTime, newClosingTime);
  }
}

/**
 * @title FinalizableCrowdsale
 * @dev Extension of Crowdsale where an owner can do extra work
 * after finishing.
 */
abstract contract FinalizableCrowdsale is TimedCrowdsale, Ownable, Pausable {
  bool public isFinalized = false;

  event Finalized();

  /**
   * @dev Must be called after crowdsale ends, to do some extra finalization
   * work. Calls the contract's finalization function.
   */
  function finalize() onlyOwner public whenNotPaused{
    require(!isFinalized, "Already Finalized");
    require(hasClosed(), "Crowdsale is not yet closed");
    finalization();
    emit Finalized();

    isFinalized = true;
  }

  /**
   * @dev Can be overridden to add finalization logic. The overriding function
   * should call super.finalization() to ensure the chain of finalization is
   * executed entirely.
   */
  function finalization() internal virtual {
  }

  function _updateFinalization() internal {
    isFinalized = false;
  }

}

/**
 * @dev Implementation of the {IBEP20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {BEP20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IBEP20-approve}.
 */

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}
interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


contract ReflexPreSale is Crowdsale, Pausable, FinalizableCrowdsale {
    // whitelisting enable,disable
    bool public enableWhitelisting;

    // account is whitelisted or not
    mapping(address => bool) public whitelisted;

    // router address
    IUniswapV2Router02 public uniswapV2Router;

    // liquidity percentage
    uint256 public liquidityPercentage;

    // listing rate while add liquidity
    uint256 public listingRate;

    // pair address
    address public uniswapV2Pair;

    // if round ends while add liquidity it will take this much percentage of bnb to owner wallet
    uint256 public bnbRaisedFee;

     // fee(%) in token sold fee to reflex owner
    uint256 public tokenSoldFee;

    // reflex owner account
    address public reflexOwner;

    // bool for dex listing
    bool public isListedOnDex;

    // refund type
    uint256 public refundType;

    // penality fee
    uint256 public penalityFee = 10;

    // token contribution status
    bool public isTokenContributed;

    // dead wallet address
    address public deadWallet = 0x000000000000000000000000000000000000dEaD;

    // tokens for presale
    uint256 public tokensForPresale;

    event WhitelistStatusUpdated(bool enable);
    event AccountWhitelistUpdated(address indexed account, bool status);
    event AccountsWhitelistUpdated(address[] indexed account, bool status);
    event DexListing(uint256 tokens,uint256 bnb);
    event WithdrawContributions(uint256 bnbAmount);
    event TokenContributionToPreSale(uint256 amount);
    event WithdrawUserContributions(uint256 amount);
    event ClaimTokens(address indexed account, uint256 tokenAmount);
    event UpdatePenalityFee(uint256 fee);

    constructor(
      uint256 rate,                 // rate, in TKNbits
      IERC20 token,                 // the token
      uint256 openingTime,          // opening time in unix epoch seconds
      uint256 closingTime,          // closing time in unix epoch seconds
      uint256 _refundType,          // refund type 1-Refund to owner,2-Burn
      address _routerAddress,       // router address
      uint256 _liquidityPercentage, // liquidity percentage(%) for how much bnb % depends upon rate of the token to add liquidity 
      uint256 _listingRate,         // listing rate
      uint256 _tokenSoldFee,        // token contribution fee(%)
      uint256 _bnbRaisedFee,        // bnbRaisedFee(%)
      address _reflexOwner          // reflex owner account
    )
      TimedCrowdsale(openingTime, closingTime)
      Crowdsale(rate, token)
    {
      IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_routerAddress);
      // Create a uniswap pair for this new token
      uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(token), _uniswapV2Router.WETH());

      // set the rest of the contract variables
      uniswapV2Router = _uniswapV2Router;
      liquidityPercentage = _liquidityPercentage;
      refundType = _refundType;
      listingRate = _listingRate;
      reflexOwner = _reflexOwner;
      tokenSoldFee = _tokenSoldFee;
      bnbRaisedFee = _bnbRaisedFee;
    }

  function setParams(uint256 _minimumBuyLimit, uint256 _maximumBuyLimit, uint256 _softcap, uint256 _hardcap) external onlyOwner whenNotPaused {
    require(_maximumBuyLimit >= _minimumBuyLimit , "Set Params: Maximum buy must be greater than minimum buy.");
    require(_hardcap >= _softcap , "Set Params: Hardcap must be greater than softcap.");
    params = IntializeParams(_minimumBuyLimit, _maximumBuyLimit, _softcap, _hardcap);
  }

    /**
     * @dev Pause `contract` - pause events.
     *
     * See {ERC20Pausable-_pause}.
     */
    function pauseContract() external virtual onlyOwner {
        _pause();
    }
    
    /**
     * @dev Pause `contract` - pause events.
     *
     * See {ERC20Pausable-_pause}.
     */
    function unPauseContract() external virtual onlyOwner {
        _unpause();
    }

    /**
     * @param _beneficiary Address performing the token purchase
     */
    function buyToken(address _beneficiary) external payable onlyWhileOpen whenNotPaused{
      if(enableWhitelisting) {
        require(whitelisted[_beneficiary], "Buy Token: Address need to whitelist");
      }
      buyTokens(_beneficiary);
    }

    function finalization() virtual internal override{
      require(weiRaised >= params.softcap, "Finalization: Softcap is not reached");
      require(!isListedOnDex, "Finalization: Already listed on dex");
      dexListing();
    }

    function extendSale(uint256 newClosingTime) virtual external onlyOwner whenNotPaused{
      _extendTime(newClosingTime);
      _updateFinalization();
    }

    function changeRate(uint256 newRate) virtual external onlyOwner onlyWhileOpen whenNotPaused{
      require(newRate > 0, "Rate: Amount cannot be 0");
      _changeRate(newRate);
    }

    function changeToken(IERC20 newToken) virtual external onlyOwner onlyWhileOpen whenNotPaused{
      require(address(newToken) != address(0), "Token: Address cant be zero address");
      _changeToken(newToken);
    }

    /**
       @dev Update Enable Whitelisting
       @param enable bool
     */
    function updateEnableWhitelisting(bool enable) external onlyOwner {
        require(enableWhitelisting != enable , "BEP20: Already in same status");
        enableWhitelisting = enable;
        emit WhitelistStatusUpdated(enable);
    }
    
    /**
       @dev Include specific address for Whitelisting
       @param account whitelisting address
    */
    function includeInWhitelist(address account) external onlyOwner {
        require(account != address(0), "BEP20: Account cant be zero address");
        require(!whitelisted[account], "BEP20: Account is already whitelisted");
        whitelisted[account] = true;
        emit AccountWhitelistUpdated(account, true);
    }
    
    /**
       @dev Exclude specific address from Whitelisting
       @param account whitelisting address
    */
    function excludeFromWhitelist(address account) external onlyOwner {
        require(account != address(0), "BEP20: Account cant be zero address");
        require(whitelisted[account], "BEP20: Account is not whitelisted");
        whitelisted[account] = false;
        emit AccountWhitelistUpdated(account, false);
    }
    
    /**
       @dev Include multiple address for Whitelisting
       @param accounts whitelisting addresses
    */
    function includeAllInWhitelist(address[] memory accounts) external onlyOwner {
        for (uint256 account = 0; account < accounts.length; account++) {
            if(!whitelisted[accounts[account]]) {
              whitelisted[accounts[account]] = true;
            }
       }
       emit AccountsWhitelistUpdated(accounts, true);
    }
    
    /**
       @dev Exclude multiple address from Whitelisting
       @param accounts whitelisting address
    */
    function excludeAllFromWhitelist(address[] memory accounts) external onlyOwner {
        for (uint256 account = 0; account < accounts.length; account++) {
             if(whitelisted[accounts[account]]) {
              whitelisted[accounts[account]] = false;
            }
       }
        emit AccountsWhitelistUpdated(accounts, true);
    }
    
    /**
       @dev check wheather the account is whitelisted or not
       @param account address
       @return bool
    */
    function isWhitelisted(address account) view external returns(bool){
        return whitelisted[account];
    }

  function dexListing() private {
    isListedOnDex = true;
    uint256 bnbBalanceInContract = address(this).balance;
    uint256 tokenBalanceInContract = token.balanceOf(address(this));

    // (%) of bnb raised to reflex owner
    uint256 fee = (bnbBalanceInContract * bnbRaisedFee) / 10**2;
    address payable _owner = payable(reflexOwner);   
    _owner.transfer(fee);

    // (%) of token sold to reflex owner
    require(token.balanceOf(address(this)) > 0, "Finalize: Insufficient token balance");
    uint256 tokensForReflexOwner = (tokensSold * tokenSoldFee) / 10 ** 2;
    token.transfer(reflexOwner, tokensForReflexOwner);

    // liquidity percentage for add liquidity.
    uint256 multiplier = getDecimalMultiplier();
    uint256 liquidityTokens = (((bnbBalanceInContract - fee) * listingRate) * liquidityPercentage) / 10 ** 2;
    uint256 bnbForLiquidity = liquidityTokens / listingRate;
    uint256 tokenForLiquidity = liquidityTokens / multiplier;
    // add liquidity to pancakeswap
    addLiquidity(tokenForLiquidity, bnbForLiquidity);

    //burn or refund depends upon refund type
    uint256 refundBalance = tokenBalanceInContract - tokensForReflexOwner - tokenForLiquidity - tokensSold;
    if(refundType == 1){
      token.transfer(owner(), refundBalance);
    }else{
      token.transfer(deadWallet, refundBalance);
    }       

    emit DexListing(liquidityTokens, bnbForLiquidity);

  }

  function getDecimalMultiplier() internal view returns (uint256) {
     if(tokenDecimal <= 18) {
      return 10 ** (18-tokenDecimal);
    } else {
      return 10 ** (tokenDecimal-18);
    }
  }

  function calculation() external view returns (uint256, uint256, uint256) {
    uint256 bnbBalanceInContract = address(this).balance;
    uint256 tokenBalanceInContract = token.balanceOf(address(this));
    uint256 multiplier = getDecimalMultiplier();
    uint256 liquidityTokens = (((bnbBalanceInContract - 10000000000000000) * listingRate) * liquidityPercentage) / 10 ** 2;
    uint256 bnbForLiquidity = liquidityTokens / listingRate;
    uint256 tokenForLiquidity = liquidityTokens / multiplier;

    return (liquidityTokens, tokenForLiquidity, bnbForLiquidity);

  } 

  function multipier() external view returns (uint256) {
     if(tokenDecimal <= 18) {
      return 10 ** (18-tokenDecimal);
    } else {
      return 10 ** (tokenDecimal-18);
    }
  }

  function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
    // add the liquidity
    token.approve(address(uniswapV2Router), tokenAmount);
    uniswapV2Router.addLiquidityETH{value: ethAmount}(
      address(token),
      tokenAmount,
      0, // slippage is unavoidable
      0, // slippage is unavoidable
      owner(),
      block.timestamp
    );
  }

  function withdrawBnbFromContract() external onlyOwner whenNotPaused {
    require(isFinalized, "Withdraw BNB: Not yet listed on dex"); 
    uint256 bnbBalance = address(this).balance; 
    address payable _owner = payable(msg.sender);        
    _owner.transfer(bnbBalance);       
    emit WithdrawContributions(bnbBalance);
  }

  function tokenContributionToPreSale(uint256 amount) external onlyOwner whenNotPaused {
    require(!isTokenContributed, "Token Contributions: Already token contributed");
    require(amount > 0, "Token Contributions: Amount must be greater that 0");
    require(token.balanceOf(owner()) > amount, "Token Contributions: Insufficient token balance");
    //uint256 tokenContribution = (1.02 * (rate * params.hardcap) + 0.98 * (listingRate * params.hardcap) * liquidityPercentage)/100;
    token.transferFrom(owner(), address(this), amount);
    isTokenContributed = true;
    tokensForPresale = amount;
    emit TokenContributionToPreSale(amount);
  }
  
  /**
   @dev After sale end if softcap not reached user can withdraw contribution 100% bnb he spent
  */
  function userWithdrawContributionWhileSoftcapNotReached() external whenNotPaused {
    require(hasClosed(), "Crowdsale is not yet closed");
    require(weiRaised <= params.softcap, "Withdraw Contribution: Softcap is reached");
    require(userBnbBalance[msg.sender] > 0, "Withdraw Contribution: No contribution");
    address payable _user = payable(msg.sender);        
    _user.transfer(userBnbBalance[msg.sender]);
    weiRaised -= userBnbBalance[msg.sender];
    tokensSold -= userTokenBalance[msg.sender];
    userBnbBalance[msg.sender] = 0;
    userTokenBalance[msg.sender] = 0;
    emit WithdrawUserContributions(userBnbBalance[msg.sender]);     
  }

  /** 
    @dev emergencyy withdraw for users only bnb they contributed with penalty 10% (owner or reflex fin owner)
  */
  function userWithdrawContribution() external whenNotPaused {
    require(userBnbBalance[msg.sender] > 0, "Withdraw Contribution: No contribution"); 
    uint256 deductPenality = (userBnbBalance[msg.sender] * penalityFee) / 10**2;
    address payable _owner = payable(owner());   
    _owner.transfer(deductPenality);
    uint256 transferrableBnb = userBnbBalance[msg.sender] - deductPenality;
    address payable _user = payable(msg.sender);        
    _user.transfer(transferrableBnb);
    weiRaised -= userBnbBalance[msg.sender];
    tokensSold -= userTokenBalance[msg.sender]; 
    userBnbBalance[msg.sender] = 0;
    userTokenBalance[msg.sender] = 0;
    emit WithdrawUserContributions(userBnbBalance[msg.sender]);     
  }

  function claimTokens(address account) external whenNotPaused {
    require(account != address(0), "Claim tokens: Account cant be zero address");
    require(userTokenBalance[account] > 0, "Claim tokens: Amount cant be zero");
    token.transfer(account, userTokenBalance[account]);
    emit ClaimTokens(account, userTokenBalance[account]);
  }

  function softcapStatus() view external returns(bool) {
    if(weiRaised >= params.softcap) {
      return true;
    } else {
      return false;
    }
  }

  function updatePenalityFee(uint256 _penalityFee) external onlyOwner whenNotPaused {
    penalityFee = _penalityFee;
    emit UpdatePenalityFee(_penalityFee);
  }

  function getLaunchPadDetails() external view returns (address, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
    return(
      address(token),
      tokensForPresale,
      rate,
      listingRate,
      params.hardcap,
      params.softcap,
      params.minimumBuyLimit,
      params.maximumBuyLimit,
      refundType,
      liquidityPercentage,
      openingTime,
      closingTime
    );
  }

}