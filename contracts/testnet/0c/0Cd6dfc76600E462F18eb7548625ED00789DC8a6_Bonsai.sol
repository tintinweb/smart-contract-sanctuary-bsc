/**
 *Submitted for verification at BscScan.com on 2022-02-10
*/

// File: contracts/library/IBEP20.sol


pragma solidity ^0.8.11;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function allowance(address _owner, address spender) external view returns (uint256);

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
// File: contracts/interface/IUniswapV2Factory.sol


pragma solidity ^0.8.11;

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
// File: contracts/interface/IUniswapV2Router02.sol


pragma solidity ^0.8.11;

// import "./IUniswapV2Router01.sol";

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
}
// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
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

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
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

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
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

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
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

// File: contracts/Bonsai.sol

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;







contract Bonsai is IBEP20, Context, Ownable {
  using SafeMath for uint256;

  address bonsaiOwner;

  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;
  mapping (address => bool) private _isExcludedFromFee;
  mapping (address => bool) private _isWhitelist;

  uint256 private _totalSupply;
  uint8 private _decimals;
  string private _symbol;
  string private _name;

  uint256 public _taxFee;
  bool public _IsTaxEnabled;

  bool private inSwap = false;

  address public _teamWallet;
  address public _developmentWallet;
  address public _lotteryWallet;
  address public _burnWallet;
  address public _charityWallet;
  address public _otherBurnWallet;

  address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

  uint8 public _liquidityTax;
  uint8 public _teamWalletTax;
  uint8 public _developmentWalletTax;
  uint8 public _lotteryWalletTax;
  uint8 public _burnWalletTax;
  uint8 public _charityWalletTax;
  uint8 public _otherBurnWalletTax;

  IUniswapV2Router02 private uniswapV2Router;
  address private uniswapV2Pair;

  modifier lockTheSwap {
    inSwap = true;
    _;
    inSwap = false;
  }

  modifier checkWhiteList(address addr) {
    require(addr == owner() || _isWhitelist[addr], "This address is not on whitelist...");
    _;
  }
  constructor(address pcsRouterAddress) {
    _name = "Bonsai Coin";
    _symbol = "BONSAI";
    _decimals = 4;
    _totalSupply = 10**11 * 10**18;
    _balances[msg.sender] = _totalSupply;    
    _taxFee = 200;
    _IsTaxEnabled = true;

    _isExcludedFromFee[owner()] = true;
    _isExcludedFromFee[address(this)] = true;

    _teamWallet = payable(BURN_ADDRESS);
    _developmentWallet = payable(BURN_ADDRESS);
    _lotteryWallet = payable(BURN_ADDRESS);
    _burnWallet = payable(BURN_ADDRESS);
    _charityWallet = payable(BURN_ADDRESS);
    _otherBurnWallet = payable(BURN_ADDRESS);

    _liquidityTax = 4;
    _teamWalletTax = 10;
    _developmentWalletTax = 10;
    _lotteryWalletTax = 10;
    _burnWalletTax = 10;
    _charityWalletTax = 10;
    _otherBurnWalletTax = 10;

    bonsaiOwner = msg.sender;

    IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(pcsRouterAddress);
    uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
    uniswapV2Router = _uniswapV2Router;

    emit Transfer(address(0), msg.sender, _totalSupply);
  }

  function getOwner() external override view returns (address) {
    return owner();
  }

  function decimals() external override view returns (uint8) {
    return _decimals;
  }

  function symbol() external override view returns (string memory) {
    return _symbol;
  }

  function name() external override view returns (string memory) {
    return _name;
  }

  function totalSupply() external override view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) public view override returns (uint256) {
    return _balances[account];
  }

  function excludeFromFee(address account) public onlyOwner {
    _isExcludedFromFee[account] = true;
  }
  
  function includeInFee(address account) public onlyOwner {
    _isExcludedFromFee[account] = false;
  }

  function transfer(address recipient, uint256 amount) external override returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function allowance(address ownerAddr, address spender) external view override returns (uint256) {
    return _allowances[ownerAddr][spender];
  }

  function approve(address spender, uint256 amount) public override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) public override checkWhiteList(sender) returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }

  function _transfer(address from, address to, uint256 amount) internal {

    require(from != address(0), "BEP20: transfer from the zero address");
    require(to != address(0), "BEP20: transfer to the zero address");
    require(amount > 0, "Transfer amount must be greater than zero");

    if (_isExcludedFromFee[from] || _isExcludedFromFee[to])
      _IsTaxEnabled = false;
    else
      _IsTaxEnabled = true;

    _tokenTransfer(from, to, amount);
  }

  function _approve(address ownerAddr, address spender, uint256 amount) internal {
    require(ownerAddr != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[ownerAddr][spender] = amount;
    emit Approval(ownerAddr, spender, amount);
  }

  function _tokenTransfer(address sender, address recipient, uint256 amount) private lockTheSwap {
    uint256 fee = amount.mul(_taxFee).div(10000);

    if (!_IsTaxEnabled)
      fee = 0;

    uint256 senderBalance = _balances[sender];

    require(senderBalance >= amount, "BEP20: transfer amount exceeds balance");

    _balances[sender] = senderBalance - amount;

    uint256 amountnew = amount - fee;
    _balances[recipient] += (amountnew);

    if (fee > 0) {
      _balances[address(this)] += (fee);
      emit Transfer(sender, address(this), fee);
    }

    emit Transfer(sender, recipient, amountnew);
  }

  function withdrawTax() external lockTheSwap onlyOwner {
    uint256 tokenBalance = balanceOf(address(this));
    uint256 liquidityTokens = tokenBalance.div(_liquidityTax);
    uint256 otherBNBTokens = tokenBalance.div(_liquidityTax);

    uint256 initialBalance = address(this).balance;
    swapTokensForEth(otherBNBTokens);

    uint256 newBNBBalance = address(this).balance.sub(initialBalance);
    addLiqudity(liquidityTokens, newBNBBalance);


    uint256 devTokens = tokenBalance.div(_developmentWalletTax);
    initialBalance = address(this).balance;
    swapTokensForEth(devTokens);
    newBNBBalance = address(this).balance.sub(initialBalance);    
    payable(_developmentWallet).transfer(newBNBBalance);

    uint256 lotteryTokens = tokenBalance.div(_lotteryWalletTax);
    initialBalance = address(this).balance;
    swapTokensForEth(lotteryTokens);
    newBNBBalance = address(this).balance.sub(initialBalance);    
    payable(_lotteryWallet).transfer(newBNBBalance);

    uint256 burnTokens = tokenBalance.div(_burnWalletTax);
    initialBalance = address(this).balance;
    swapTokensForEth(burnTokens);
    newBNBBalance = address(this).balance.sub(initialBalance);    
    payable(_burnWallet).transfer(newBNBBalance);

    uint256 charityTokens = tokenBalance.div(_charityWalletTax);
    initialBalance = address(this).balance;
    swapTokensForEth(charityTokens);
    newBNBBalance = address(this).balance.sub(initialBalance);    
    payable(_charityWallet).transfer(newBNBBalance);

    uint256 otherTokens = tokenBalance.div(_otherBurnWalletTax);
    initialBalance = address(this).balance;
    swapTokensForEth(otherTokens);
    newBNBBalance = address(this).balance.sub(initialBalance);    
    payable(_otherBurnWallet).transfer(newBNBBalance);
  }

  function swapTokensForEth(uint256 tokenAmount) private {
    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = uniswapV2Router.WETH();
    approve(address(uniswapV2Router), tokenAmount);
    uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp);
  }

  function addLiqudity(uint256 tokenAmount, uint256 ethAmount) private {
    approve(address(uniswapV2Router), tokenAmount);

    uniswapV2Router.addLiquidityETH{value: ethAmount}(
        address(this),
        tokenAmount,
        0,
        0,
        owner(),
        block.timestamp
    );
  }

  function contractBalanceSwap() external onlyOwner {
      uint256 contractBalance = balanceOf(address(this));
      swapTokensForEth(contractBalance);
  }

  function contractBalanceSend(uint256 amount, address payable _destAddr) external onlyOwner {
    uint256 contractETHBalance = address(this).balance - 1 * 10**17;
    if(contractETHBalance > amount){
      _destAddr.transfer(amount);
    }
  }

  function setWhitelist(address addr, bool isWhitelist) public onlyOwner {
    _isWhitelist[addr] = isWhitelist;
  }

  function setTeamWalletAddress(address teamWalletAddr) public onlyOwner {
    _teamWallet = payable(teamWalletAddr);
  }

  function setDevelopmentWalletAddress(address developmentWallet) external onlyOwner {
    _developmentWallet = payable(developmentWallet);
  }

  function setLotteryWalletAddress(address lotteryWallet) external onlyOwner {
    _lotteryWallet = payable(lotteryWallet);
  }

  function setBurnWalletAddress(address burnWallet) external onlyOwner {
    _burnWallet = payable(burnWallet);
  }

  function setCharityWalletAddress(address charityWallet) external onlyOwner {
    _charityWallet = payable(charityWallet);
  }

  function setOtherBurnWalletAddress(address otherBurnWallet) external onlyOwner {
    _otherBurnWallet = payable(otherBurnWallet);
  }

  function setLiquidityTax(uint8 liquidityTax) external onlyOwner {
    _liquidityTax = liquidityTax;
  }

  function setTeamWalletTax(uint8 teamWalletTax) external onlyOwner {
    _teamWalletTax = teamWalletTax;
  }

  function setDevelopmentWalletTax(uint8 developmentWalletTax) external onlyOwner {
    _developmentWalletTax = developmentWalletTax;
  }

  function setLotteryWalletTax(uint8 lotteryWalletTax) external onlyOwner {
    _lotteryWalletTax = lotteryWalletTax;
  }

  function setBurnWalletTax(uint8 burnWalletTax) external onlyOwner {
    _burnWalletTax = burnWalletTax;
  }

  function setCharityWalletTax(uint8 charityWalletTax) external onlyOwner {
    _charityWalletTax = charityWalletTax;
  }

  function setOtherBurnWalletTax(uint8 otherBurnWalletTax) external onlyOwner {
    _otherBurnWalletTax = otherBurnWalletTax;
  }

  function setTaxFee(uint256 taxFee) external onlyOwner {
    _taxFee = taxFee;
  }

  function setAMMRouter(address newRouter) public onlyOwner {
    require(newRouter != address(0), "New router is the zero address...");
    emit AMMRouterTransferred(address(uniswapV2Router), newRouter);
    uniswapV2Router = IUniswapV2Router02(newRouter);
  }

  function setOwner(address payable _newOwner) external onlyOwner {
    require(_newOwner != address(0), "Invalid input address...");
    bonsaiOwner = _newOwner;
    transferOwnership(bonsaiOwner);
  }
  
  event AMMRouterTransferred(address indexed oldRouter, address indexed newRouter);

  receive() payable external {

  }

  fallback() payable external {

  }
}