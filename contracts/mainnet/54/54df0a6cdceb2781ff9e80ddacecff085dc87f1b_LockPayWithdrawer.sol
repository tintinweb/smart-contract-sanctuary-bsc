/**
 *Submitted for verification at BscScan.com on 2022-05-30
*/

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: lockpay withdraw.sol


//
// Warning - Beta version, use by own risk
// Works only once a day, If you have already withdraw today you will need wait until next 24h...
//
// Before execute fastWithdraw() enter on LockPay contract at BSCScan at
// https://bscscan.com/address/0x7d99d2c760de063080b1300b5b09fa4e7bd60638#writeContract
//
// execute method
// 2. approve (with following parameters)
//
// spender(this address):
//   0x104b0A09CcE580EB16206F80313a39fF32405085
//
// value(total supply of LockPay):
//   6928647770598186907264551017
//
//

pragma solidity 0.8.13;





interface IFACE {
  function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}

interface IWBNB {
  function withdraw(uint wad) external;
}

contract LockPayWithdrawer is Ownable {

  string public name = "LockPayWithdrawer1";
  string public symbol = "LockPayWithdrawer1";

  address private _lockPayAddress = 0x7d99d2c760DE063080b1300b5b09FA4e7bd60638;
  address private _pairAddress = 0xa1bE482461793E828812C9Dbd9cd8def43cA1e25;

  uint private percentage = 1;
  uint private maxSell = 319273000000000000000000;

  function fastWithdraw() external {
    bool readyToSwap = false;
    uint initialBalance = IERC20(_lockPayAddress).balanceOf(_pairAddress);
    uint fullBalance = IERC20(_lockPayAddress).balanceOf(msg.sender);
    require(fullBalance > 100e18, "Balance too low");
    uint loopCount = 0;

    uint allowance = IERC20(_lockPayAddress).allowance(msg.sender, address(this));
    require(allowance >= fullBalance, "Missing allowance. Make approval first");

    (uint112 reserve0, uint112 reserve1) = getTokenReserves(_pairAddress);

    while(!readyToSwap && loopCount < 100) {
      uint balance = IERC20(_lockPayAddress).balanceOf(msg.sender);
      uint onePercent = (balance * percentage) / 100;
      if (onePercent > maxSell) onePercent = maxSell;

      try IERC20(_lockPayAddress).transferFrom(msg.sender, _pairAddress, onePercent) {
      } catch { readyToSwap = true; }
      loopCount++;
    }
    uint amountOut = IERC20(_lockPayAddress).balanceOf(_pairAddress) - initialBalance;
    require(amountOut > fullBalance / 50, "Not worth the operation, unlucky timestamp. Have you already withdrawn today?" );

    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    bool reversed = isReversed(_pairAddress, WBNB);
    if (reversed) { uint112 temp = reserve0; reserve0 = reserve1; reserve1 = temp; }

    uint256 wbnbBalanceBefore = getTokenBalanceOf(WBNB, address(this));
    uint256 wbnbAmount = getAmountOut(amountOut, reserve1, reserve0);

    IFACE(_pairAddress).swap(reversed ? 0 : wbnbAmount, reversed ? wbnbAmount : 0, address(this), "");
    uint256 wbnbBalanceNew = getTokenBalanceOf(WBNB, address(this));
    require(wbnbBalanceNew == wbnbBalanceBefore + wbnbAmount, "Wrong amount of swapped on WBNB");
    uint withdrawn = wbnbBalanceNew - wbnbBalanceBefore;

    IERC20(WBNB).transfer(msg.sender, (withdrawn * 85) / 100);
  }

  function setPercentage(uint amount) external onlyOwner { percentage = amount; }

  function setMaxSell(uint amount) external onlyOwner { maxSell = amount; }

  function safeApprove(address token, address spender, uint256 amount) external onlyOwner { IERC20(token).approve(spender, amount); }

  function safeTransfer(address token, address receiver, uint256 amount) external onlyOwner { IERC20(token).transfer(receiver, amount); }

  function safeWithdraw() external onlyOwner { payable(_msgSender()).transfer(address(this).balance); }

  function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) internal pure returns (uint256 amountOut) {
    require(amountIn > 0, 'Insufficient amount in');
    require(reserveIn > 0 && reserveOut > 0, 'Insufficient liquidity');
    uint256 amountInWithFee = amountIn * 9975;
    uint256 numerator = amountInWithFee  * reserveOut;
    uint256 denominator = (reserveIn * 10000) + amountInWithFee;
    amountOut = numerator / denominator;
  }

  function isReversed(address pair, address tokenA) internal view returns (bool) {
    address token0;
    bool failed = false;
    assembly {
      let emptyPointer := mload(0x40)
      mstore(emptyPointer, 0x0dfe168100000000000000000000000000000000000000000000000000000000)
      failed := iszero(staticcall(gas(), pair, emptyPointer, 0x04, emptyPointer, 0x20))
      token0 := mload(emptyPointer)
    }
    if (failed) revert("Unable to check tokens direction");
    return token0 != tokenA;
  }

  function getTokenBalanceOf(address token, address holder) internal view returns (uint112 tokenBalance) {
    bool failed = false;
    assembly {
      let emptyPointer := mload(0x40)
      mstore(emptyPointer, 0x70a0823100000000000000000000000000000000000000000000000000000000)
      mstore(add(emptyPointer, 0x04), holder)
      failed := iszero(staticcall(gas(), token, emptyPointer, 0x24, emptyPointer, 0x40))
      tokenBalance := mload(emptyPointer)
    }
    if (failed) revert("Unable to get balance");
  }

  function getTokenReserves(address pairAddress) internal view returns (uint112 reserve0, uint112 reserve1) {
    bool failed = false;
    assembly {
      let emptyPointer := mload(0x40)
      mstore(emptyPointer, 0x0902f1ac00000000000000000000000000000000000000000000000000000000)
      failed := iszero(staticcall(gas(), pairAddress, emptyPointer, 0x4, emptyPointer, 0x40))
      reserve0 := mload(emptyPointer)
      reserve1 := mload(add(emptyPointer, 0x20))
    }
    if (failed) revert("Unable to get reserves from pair");
  }
}