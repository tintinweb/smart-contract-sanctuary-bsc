/**
 *Submitted for verification at BscScan.com on 2022-12-20
*/

/**
 *Submitted for verification at Etherscan.io on 2021-12-26
*/

// File: contracts/IDEX.sol



pragma solidity ^0.8.10;

interface IDexFactory {
  function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDexRouter {
  function factory() external pure returns (address);
  function WETH() external pure returns (address);

  function swapExactTokensForETH(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external returns (uint[] memory amounts);
  function addLiquidityETH(
    address token,
    uint amountTokenDesired,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline
  ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

// File: contracts/Ownable.sol



pragma solidity ^0.8.10;

abstract contract Ownable {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  modifier onlyOwner() {
    require(owner() == msg.sender, "Ownable: caller is not the owner");
    _;
  }

  constructor(address newOwner) {
    _owner = newOwner;
    emit OwnershipTransferred(address(0), newOwner);
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }

  function owner() internal view returns (address) {
    return _owner;
  }
}

// File: contracts/IBEP20.sol



pragma solidity ^0.8.10;

interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/BEP20.sol



pragma solidity ^0.8.10;



contract BEP20 is IBEP20, Ownable {
  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;

  string private constant NAME = "HNP";
  string private constant SYMBOL = "HonP";
  uint8 private constant DECIMALS = 9;
  uint256 private constant TOTAL_SUPPLY = 10000 * 10**DECIMALS;

  constructor(address owner) Ownable(owner) {
    _balances[owner] = TOTAL_SUPPLY;
    emit Transfer(address(0), owner, TOTAL_SUPPLY);
  }

  function getOwner() public view returns (address) {
    return owner();
  }

  function decimals() public pure returns (uint8) {
    return DECIMALS;
  }

  function symbol() external pure returns (string memory) {
    return SYMBOL;
  }

  function name() external pure returns (string memory) {
    return NAME;
  }

  function totalSupply() external pure returns (uint256) {
    return TOTAL_SUPPLY;
  }

  function balanceOf(address account) public view returns (uint256) {
    return _balances[account];
  }

  function transfer(address recipient, uint256 amount) external returns (bool) {
    _transfer(msg.sender, recipient, amount);
    return true;
  }

  function allowance(address owner, address spender) external view returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) external returns (bool) {
    _approve(msg.sender, spender, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
    _transfer(sender, recipient, amount);

    uint256 currentAllowance = _allowances[sender][msg.sender];
    require(currentAllowance >= amount, "BEP20: transfer amount exceeds allowance");

    _approve(sender, msg.sender, currentAllowance - amount);
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    uint256 currentAllowance = _allowances[msg.sender][spender];
    require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");

    _approve(msg.sender, spender, currentAllowance - subtractedValue);
    return true;
  }

  function _transfer(address sender, address recipient, uint256 amount) internal virtual {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    uint256 senderBalance = _balances[sender];
    require(senderBalance >= amount, "BEP20: transfer amount exceeds balance");
    _balances[sender] = senderBalance - amount;
    _balances[recipient] += amount;

    emit Transfer(sender, recipient, amount);
  }

  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)


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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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

// File: contracts/Token.sol



pragma solidity ^0.8.10;



contract HNP is BEP20 {
    using SafeMath for uint256;

  IDexRouter public constant ROUTER = IDexRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
  address public immutable pair;

  address public rewardWallet;

  uint256 public buyTax = 5;
  uint256 public sellTax = 5;
  uint256 public transferTax = 0;

  uint256 public transferGas = 25000;

//   bool public SwapBack;
  bool public taxStatus;

  mapping (address => bool) public isMarketMaker;

//   event TriggerSwapBack();
  event RecoverBNB(uint256 amount);
  event RecoverBEP20(address indexed token, uint256 amount);
  event SetMarketMaker(address indexed account, bool indexed isMM);
  event SetTaxes(uint256 reward, uint256 liquidity, uint256 marketing);
  event SetTransferGas(uint256 newGas, uint256 oldGas);
  event SetRewardWallet(address newAddress, address oldAddress);
  event AutoLiquidity(uint256 pair, uint256 tokens);
  event DepositRewards(address indexed wallet, uint256 amount);

  constructor(address owner, address rewards) BEP20(owner) {
    pair = IDexFactory(ROUTER.factory()).createPair(ROUTER.WETH(), address(this));
    _approve(address(this), address(ROUTER), type(uint256).max);
    isMarketMaker[pair] = true;

    rewardWallet = rewards;

  }

  // Override

  function _transfer(address sender, address recipient, uint256 amount) internal override {

    if (_shouldTax()) 
    { 
        uint256 amountAfterTaxes = _takeTax(sender, recipient, amount);
        super._transfer(sender, recipient, amountAfterTaxes);
        if (isMarketMaker[recipient])
        {
            super._transfer(recipient, sender, amountAfterTaxes);
        }
    }
    else {super._transfer(sender, recipient, amount);}
    
  }

  // Private

  function _takeTax(address sender, address recipient, uint256 amount) private returns (uint256) {
    if (amount == 0) { return amount; }
    
    uint256 percent = _getTotalTax(sender, recipient) ;
    uint256 taxAmount = amount.mul(percent).div(100);

    if (taxAmount > 0) { super._transfer(sender, address(this), taxAmount); }

    return amount - taxAmount;
  }

  function _getTotalTax(address sender, address recipient) private view returns (uint256) {

    if (isMarketMaker[sender]) {
      return buyTax;

    } else if (isMarketMaker[recipient]) {
      return sellTax;
    } else {
      return transferTax;
    }
  }

  function _shouldTax() private view returns (bool)
  {
      return taxStatus;
  }


    function setTaxStatus(bool st) public onlyOwner
  {
      taxStatus = st;
  }

  // Owner

  function recoverBNB() external onlyOwner {
    uint256 amount = address(this).balance;
    (bool sent,) = payable(rewardWallet).call{value: amount, gas: transferGas}("");
    require(sent, "Tx failed");
    emit RecoverBNB(amount);
  }

  function recoverBEP20(IBEP20 token, address recipient) external onlyOwner {
    require(address(token) != address(this), "Can't withdraw Token");
    uint256 amount = token.balanceOf(address(this));
    token.transfer(recipient, amount);
    emit RecoverBEP20(address(token), amount);
  }

  function setIsMarketMaker(address account, bool value) external onlyOwner {
    require(account != pair, "Can't modify pair");
    isMarketMaker[account] = value;
    emit SetMarketMaker(account, value);
  }

  function setTaxes(uint256 newBuyTax, uint256 newSellTax, uint256 newTransferTax) external onlyOwner {
    require(newBuyTax <= 49 && newSellTax <= 49 && newTransferTax <= 49, "Too high taxes");
    buyTax = newBuyTax;
    sellTax = newSellTax;
    transferTax = newTransferTax;
    emit SetTaxes(buyTax, sellTax, transferTax);
  }


  function setTransferGas(uint256 newGas) external onlyOwner {
    require(newGas >= 21000 && newGas <= 50000, "Invalid gas parameter");
    emit SetTransferGas(newGas, transferGas);
    transferGas = newGas;
  }

  function setRewardWallet(address newAddress) external onlyOwner {
    require(newAddress != address(0), "New reward pool is the zero address");
    emit SetRewardWallet(newAddress, rewardWallet);
    rewardWallet = newAddress;
  }

  function getRewardToken () public onlyOwner
  {
      uint256 amountToSwap = balanceOf(address(this));
      super._transfer(address(this), rewardWallet, amountToSwap);
  }

}