/**
 *Submitted for verification at BscScan.com on 2022-11-17
*/

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.7;

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

// File @openzeppelin/contracts-upgradeable/proxy/utils/[email protected]

// solhint-disable-next-line compiler-version

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
    require(_initializing || !_initialized, 'Initializable: contract is already initialized');

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

// File @openzeppelin/contracts-upgradeable/utils/[email protected]

/*
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
  function __Context_init() internal initializer {
    __Context_init_unchained();
  }

  function __Context_init_unchained() internal initializer {}

  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes calldata) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }

  uint256[50] private __gap;
}

// File @openzeppelin/contracts-upgradeable/access/[email protected]

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  function __Ownable_init() internal initializer {
    __Context_init_unchained();
    __Ownable_init_unchained();
  }

  function __Ownable_init_unchained() internal initializer {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
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
    require(owner() == _msgSender(), 'Ownable: caller is not the owner');
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
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(newOwner != address(0), 'Ownable: new owner is the zero address');
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }

  uint256[49] private __gap;
}

// File contracts/helpers/CakeMonsterUtils.sol

contract CakeMonsterUtils {
  function pct100(uint256 pct100, uint256 amount) internal pure returns (uint256) {
    return (pct100 * amount) / 10000;
  }

  function pct1000(uint256 pct1000, uint256 amount) internal pure returns (uint256) {
    return (pct1000 * amount) / 100000;
  }
}

// File contracts/CakeMonsterVaultManager.sol

// import 'hardhat/console.sol';

interface ISwapRouter {
  function swapExactTokensForTokensSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;

  function swapExactTokensForETHSupportingFeeOnTransferTokens(
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

  function removeLiquidityETHSupportingFeeOnTransferTokens(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountETH);

  function WETH() external pure returns (address);
}

interface ISwapFactory {
  function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface ICakeMonsterVault {
  function deposit() external payable;

  function withdrawal(uint256 _amount, address _to) external;

  function start() external;

  function finish() external;

  function balance() external view returns (uint256);

  function finalAmount() external view returns (uint256);

  function crumbsAmount() external view returns (uint256);

  function crumbsPending() external view returns (uint256);

  function crumbsNext() external;
}

contract CakeMonsterVaultManager is Initializable, OwnableUpgradeable, CakeMonsterUtils {
  /* old vars */
  address private SWAP_ROUTER;
  address private SWAP_FACTORY;
  address private BASE_TOKEN;
  address private RESERVE_ASSET;
  address private PCS_STAKING_CONTRACT;
  address private SYRUP_TOKEN;
  uint256 public stakingRewardsCollected;
  address private NFT_REWARDS_ADDRESS;

  /* new vars */
  address[] public vaultAddresses;
  mapping(address => uint256) public vaultInterimBalanceTracker;
  mapping(address => uint256) public vaultInterimAmount;
  mapping(address => uint256) public vaultFinalAmount;
  mapping(address => uint256) public vaultDepositPct;

  function initialize(address _SWAP_ROUTER, address _SWAP_FACTORY) public initializer {
    __Ownable_init();

    SWAP_ROUTER = _SWAP_ROUTER;
    SWAP_FACTORY = _SWAP_FACTORY;
  }

  modifier onlyBaseToken() {
    require(msg.sender == BASE_TOKEN, 'Can only be called by the base token contract');
    _;
  }

  /** ONLY OWNER **/

  function setup(address baseToken, address reserveAsset) external onlyOwner {
    BASE_TOKEN = baseToken;
    RESERVE_ASSET = reserveAsset;
  }

  function addVault(address _addyVault) external onlyOwner {
    vaultAddresses.push(_addyVault);

    vaultInterimBalanceTracker[_addyVault] = 0;
    vaultInterimAmount[_addyVault] = 0;
    vaultFinalAmount[_addyVault] = 0;
  }

  function removeVault(uint256 _index) external onlyOwner {
    require(_index < vaultAddresses.length, 'index out of bound');

    for (uint256 i = _index; i < vaultAddresses.length - 1; i++) {
      vaultAddresses[i] = vaultAddresses[i + 1];
    }
    vaultAddresses.pop();
  }

  function setVaultDistribution(address _vaultAddy, uint256 _pct) external onlyOwner {
    vaultDepositPct[_vaultAddy] = _pct;
  }

  /** CM MAIN FUNCTIONS  **/

  function depositVaults(uint256 _amount, bool _isItax) external onlyBaseToken {
    // Sell Monsta for BNB
    _swapTokenToEth(BASE_TOKEN, _amount);

    uint256 bnbBalance = address(this).balance;

    if (_isItax) {
      // Transfer lotto share (5%)
      uint256 lottoShare = CakeMonsterUtils.pct100(500, bnbBalance);

      _buyCakeAndTransfer(lottoShare, 0xdE8D23BfF4f8BeBe690d187CB6E76597b3b5956A);

      // Update bnb balance var
      bnbBalance = address(this).balance;
    }

    // Deposit to vaults
    for (uint256 i = 0; i < vaultAddresses.length; i++) {
      if (vaultDepositPct[vaultAddresses[i]] == 0) {
        continue;
      }

      uint256 vaultSplit = (bnbBalance * vaultDepositPct[vaultAddresses[i]]) / 100;

      if (vaultSplit > 0) {
        ICakeMonsterVault(vaultAddresses[i]).deposit{ value: vaultSplit }();
      }
    }
  }

  /**
   * Trigger next interim round, track current balance and calc delta
   */
  function nextInterim() external onlyBaseToken {
    for (uint256 i = 0; i < vaultAddresses.length; i++) {
      ICakeMonsterVault(vaultAddresses[i]).crumbsNext();
    }
  }

  /**
   * Trigger finish process, store current vault balances
   */
  function finish() external onlyBaseToken {
    for (uint256 i = 0; i < vaultAddresses.length; i++) {
      ICakeMonsterVault(vaultAddresses[i]).finish();
    }
  }

  /**
   * Reset vault balance and trackers and prepare for new cycle
   */
  function reset() external onlyBaseToken {
    for (uint256 i = 0; i < vaultAddresses.length; i++) {
      ICakeMonsterVault(vaultAddresses[i]).start();
    }
  }

  function claimInterim(uint256 _sharePctX1Eth, address _to) external onlyBaseToken {
    for (uint256 i = 0; i < vaultAddresses.length; i++) {
      uint256 userCrumbsAmount = (ICakeMonsterVault(vaultAddresses[i]).crumbsAmount() *
        _sharePctX1Eth) / 1 ether;

      if (userCrumbsAmount == 0) {
        continue;
      }

      ICakeMonsterVault(vaultAddresses[i]).withdrawal(userCrumbsAmount, _to);
    }
  }

  function claimFinal(uint256 _sharePctX1Eth, address _to) external onlyBaseToken {
    for (uint256 i = 0; i < vaultAddresses.length; i++) {
      uint256 userVaultAmount = (ICakeMonsterVault(vaultAddresses[i]).finalAmount() *
        _sharePctX1Eth) / 1 ether;

      ICakeMonsterVault(vaultAddresses[i]).withdrawal(userVaultAmount, _to);
    }
  }

  function addLiquidity(uint256 amount) external onlyBaseToken returns (bool) {
    uint256 initialEthBalance = address(this).balance;

    uint256 half1 = amount / 2;
    uint256 half2 = amount - half1;

    _swapTokenToEth(BASE_TOKEN, half1);

    uint256 newEthBalance = address(this).balance - initialEthBalance;

    _addLiquidity(half2, newEthBalance);

    return true;
  }

  function resetLiquidity() external onlyBaseToken returns (bool) {
    uint256 amount = IERC20(BASE_TOKEN).balanceOf(address(this));

    uint256 ethBalance = address(this).balance;

    _addLiquidity(amount, ethBalance);

    return true;
  }

  function removeLiquidity() external onlyBaseToken returns (bool) {
    _removeLiquidity();

    return true;
  }

  receive() external payable {}

  // ** private functions **

  function _buyCakeAndTransfer(uint256 _amount, address _to) private {
    uint256 cakeAmountBefore = IERC20(RESERVE_ASSET).balanceOf(address(this));

    _swapEthToToken(RESERVE_ASSET, _amount);

    uint256 cakeAmountAfter = IERC20(RESERVE_ASSET).balanceOf(address(this));

    if (cakeAmountAfter > cakeAmountBefore) {
      IERC20(RESERVE_ASSET).transfer(_to, cakeAmountAfter - cakeAmountBefore);
    }
  }

  function _swapTokenToEth(address _tokenIn, uint256 _amountIn) private {
    IERC20(_tokenIn).approve(SWAP_ROUTER, _amountIn);

    address[] memory path = new address[](2);
    path[0] = _tokenIn;
    path[1] = ISwapRouter(SWAP_ROUTER).WETH();

    ISwapRouter(SWAP_ROUTER).swapExactTokensForETHSupportingFeeOnTransferTokens(
      _amountIn,
      0,
      path,
      address(this),
      block.timestamp
    );
  }

  function _swapEthToToken(address _tokenOut, uint256 _amountIn) private {
    address[] memory path = new address[](2);
    path[0] = ISwapRouter(SWAP_ROUTER).WETH();
    path[1] = _tokenOut;

    ISwapRouter(SWAP_ROUTER).swapExactETHForTokensSupportingFeeOnTransferTokens{ value: _amountIn }(
      0,
      path,
      address(this),
      block.timestamp
    );
  }

  function _addLiquidity(uint256 amountBaseToken, uint256 amountEth) private {
    IERC20(BASE_TOKEN).approve(SWAP_ROUTER, amountBaseToken);

    ISwapRouter(SWAP_ROUTER).addLiquidityETH{ value: amountEth }(
      BASE_TOKEN,
      amountBaseToken,
      0,
      0,
      address(this),
      block.timestamp
    );
  }

  function _removeLiquidity() private {
    address pairAddress = ISwapFactory(SWAP_FACTORY).getPair(
      BASE_TOKEN,
      ISwapRouter(SWAP_ROUTER).WETH()
    );

    uint256 amountLiquidityTokens = IERC20(pairAddress).balanceOf(address(this));

    IERC20(pairAddress).approve(SWAP_ROUTER, amountLiquidityTokens);

    ISwapRouter(SWAP_ROUTER).removeLiquidityETHSupportingFeeOnTransferTokens(
      BASE_TOKEN,
      amountLiquidityTokens,
      0,
      0,
      address(this),
      block.timestamp
    );
  }
}