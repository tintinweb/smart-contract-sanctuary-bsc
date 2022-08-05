pragma solidity ^0.8.15;
//SPDX-License-Identifier: UNLICENSED

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC20Ext is IERC20{
  function decimals() external view returns(uint8);
  function pair() external view returns(address);
  function usdt() external view returns(address);
}

interface IUniswapV2Pair {
  function balanceOf(address owner) external view returns (uint);
  function transfer(address to, uint value) external returns (bool);
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

contract MeStake is Ownable {
  struct ConsensusPool {
    uint8     star;
    uint256   amount;
    uint256   claimed;
    uint256   birthday;
  }

  IERC20Ext public meToken;
  mapping(uint8 => uint256) public poolPrices;
  mapping(address => uint256) public poolBalance;
  mapping(address => uint) public recommended;
  mapping(address => ConsensusPool[]) public cpools;
  uint256 public rewardDuration;

  constructor(address _meToken) {
    meToken = IERC20Ext(_meToken);
    poolPrices[1] = 100 ether;
    poolPrices[2] = 200 ether;
    poolPrices[3] = 300 ether;
    poolPrices[4] = 400 ether;
    poolPrices[5] = 500 ether;
    poolPrices[6] = 600 ether;
    poolPrices[7] = 700 ether;
    rewardDuration = 60;
  }

  event ClaimReward(uint256);
  event PurchaseStar(uint);

  function getMeAmountForUsdt(uint256 usdtAmount) public view returns(uint256) {
    IUniswapV2Pair pair = IUniswapV2Pair(meToken.pair());
    (uint256 amountMeInPair, uint256 amountUsdtInPair) = getLiquidityPairAmount(pair);
    return (amountMeInPair * usdtAmount) / amountUsdtInPair;
  }

  function getLiquidityPairAmount(IUniswapV2Pair pair) public view returns(uint256 amountTk, uint256 amountUsdt)  {
    (uint256 token0, uint256 token1, ) = pair.getReserves();
    if (pair.token0() == address(meToken)) {
      amountTk = token0;
      amountUsdt = token1;
    }
    else {
      amountTk = token1;
      amountUsdt = token0;
    }
  }

  function availStarToPurchase(address account) public view returns(uint8) {
    (, uint256 residual) = getBalance(account);
    uint8 star = 0;
    if (residual == 0)
      star = 1;
    else if (residual > 0 && residual <= 200 ether)
      star = 2;
    else if (residual > 200 ether && residual <= 600 ether)
      star = 3;
    else if (residual > 600 ether && residual <= 1200 ether)
      star = 4;
    else if (residual > 1200 ether && residual <= 2000 ether)
      star = 5;
    else if (residual > 2000 ether && residual <= 3000 ether)
      star = 6;
    else 
      star = 7;
    return star;
  }

  function purchaseStar() public {
    uint8 star = availStarToPurchase(msg.sender);
    ConsensusPool memory cp;
    cp.star = star;
    cp.amount = poolPrices[star] * 2;
    cp.birthday = block.timestamp;
    cpools[msg.sender].push(cp);
    emit PurchaseStar(star);
  }

  function getRewardRate(address account) public view returns(uint) {
    uint recmCount = recommended[account];
    if (recmCount < 4)
      return 30; // 0.3%
    if (recmCount < 7)
      return 40; // 0.4%
    if (recmCount < 9)
      return 50; // 0.5%
    return 50; // 0.6%
  }
  
  function getBalance(address account) public view returns(uint256 tReward, uint256 tResidual) {
    ConsensusPool[] storage cpArray = cpools[account];
    for(uint8 i = 0; i < cpArray.length; i ++) {
      ConsensusPool memory c = cpArray[i];
      uint rRate = getRewardRate(account);
      uint256 dayPassed = (block.timestamp - c.birthday) / rewardDuration;
      uint256 reward = (dayPassed * c.amount * rRate) / 10000;
      if ((reward + c.claimed) > c.amount)
        reward = c.amount - c.claimed;

      tReward += reward;
      tResidual += (c.amount - reward - c.claimed);
    }
  }

  function getReward(address account) public view returns(uint256) {
    (uint256 reward, ) = getBalance(account);
    return reward;
  }

  function claimReward() public {
    address account = msg.sender;
    uint256 tReward = 0;
    ConsensusPool[] storage cpArray = cpools[account];
    uint8 i;
    for(i = 0; i < cpArray.length; i ++) {
      ConsensusPool storage c = cpArray[i];
      uint rRate = getRewardRate(account);
      uint256 dayPassed = (block.timestamp - c.birthday) / rewardDuration;
      uint256 reward = (dayPassed * c.amount * rRate) / 10000;
      if ((reward + c.claimed) > c.amount)
        reward = c.amount - c.claimed;
      c.claimed += reward;
      c.birthday += dayPassed * rewardDuration;
      tReward += reward;
    }

    // remove all claimed pools
    while(true) {
      cpArray = cpools[account];
      uint arrLength = cpArray.length;
      for(i = 0; i < arrLength; i ++) {
        ConsensusPool memory c = cpArray[i];
        if (c.claimed < c.amount)
          continue;
        
        uint last = arrLength - 1;
        if (i == last)
          cpArray.pop();
        else {
          c = cpArray[last];
          cpArray[i] = c;
          cpArray.pop();
          break;
        }
      }
      if (i == arrLength)
        break;
    }

    emit ClaimReward(tReward);
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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
        return msg.data;
    }
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
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
}