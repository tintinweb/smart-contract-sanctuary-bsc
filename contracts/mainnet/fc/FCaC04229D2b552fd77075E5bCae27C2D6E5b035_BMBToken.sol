/**
 *Submitted for verification at BscScan.com on 2023-01-08
*/

// File: contracts/IDEX.sol

pragma solidity 0.8.17;

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



pragma solidity 0.8.17;

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



pragma solidity 0.8.17;

interface IBEP20 {
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

// File: contracts/BEP20.sol



pragma solidity 0.8.17;



contract BEP20 is IBEP20, Ownable {

  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;

  string private constant NAME = "Biconomic";
  string private constant SYMBOL = "BMB";
  uint8 private constant DECIMALS = 18;
  uint256 private TOTAL_SUPPLY = 1000000000 * 10**DECIMALS;

  // set the value owner for Ownable contract
  constructor(address owner) Ownable(owner) {
    _balances[owner] = TOTAL_SUPPLY;
    emit Transfer(address(0), owner, TOTAL_SUPPLY);
  }

  // return owner address conrtact
  function getOwner() public view returns (address) {
    return owner();
  }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
  function decimals() public pure returns (uint8) {
    return DECIMALS;
  }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
  function symbol() external pure returns (string memory) {
    return SYMBOL;
  }

    /**
     * @dev Returns the name of the token.
     */
  function name() external pure returns (string memory) {
    return NAME;
  }

    /**
     * @dev See {IERC20-totalSupply}.
     */
  function totalSupply() external view returns (uint256) {
    return TOTAL_SUPPLY;
  }

    /**
     * @dev See {IERC20-balanceOf}.
     */
  function balanceOf(address account) public view returns (uint256) {
    return _balances[account];
  }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
  function transfer(address recipient, uint256 amount) external returns (bool) {
    _transfer(msg.sender, recipient, amount);
    return true;
  }

    /**
     * @dev See {IERC20-allowance}.
     */
  function allowance(address owner, address spender) external view returns (uint256) {
    return _allowances[owner][spender];
  }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
  function approve(address spender, uint256 amount) external returns (bool) {
    _approve(msg.sender, spender, amount);
    return true;
  }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
  function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
    _transfer(sender, recipient, amount);

    uint256 currentAllowance = _allowances[sender][msg.sender];
    require(currentAllowance >= amount, "BEP20: transfer amount exceeds allowance");

    _approve(sender, msg.sender, currentAllowance - amount);
    return true;
  }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
    return true;
  }


    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    uint256 currentAllowance = _allowances[msg.sender][spender];
    require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");

    _approve(msg.sender, spender, currentAllowance - subtractedValue);
    return true;
  }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
  function _transfer(address sender, address recipient, uint256 amount) internal virtual {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    uint256 senderBalance = _balances[sender];
    require(senderBalance >= amount, "BEP20: transfer amount exceeds balance");
    _balances[sender] = senderBalance - amount;
    _balances[recipient] += amount;

    emit Transfer(sender, recipient, amount);
  }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
  function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");


        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            TOTAL_SUPPLY -= amount;
        }

        emit Transfer(account, address(0), amount);

    }
}


// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

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

// File: contracts/Step.sol

pragma solidity 0.8.17;

contract BMBToken is BEP20 {
  using SafeMath for uint256;

  // set router address 'pancakeswap'
  IDexRouter public constant ROUTER = IDexRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);

  // address pair token / bnb on pancakeswap
  address public immutable pair;

  // reward wallet for get fee transfers token
  address public rewardWallet;

  // marketing wallet for get fee transfers token
  address public marketingWallet;

  // Percentage fee related to the purchase
  uint256 public buyTax = 2;

  // Percentage fee related to sales
  uint256 public sellTax = 3;

  // Percentage fee related to trnsfers
  uint256 public transferTax = 5;

  bool public rewardWalletOn;


  uint256 public transferGas = 25000;

  // for set Centralized Exchange 
  mapping (address => bool) public isCEX;

  // for set marketmaker 'pair token on pancakeswap'
  mapping (address => bool) public isMarketMaker;

  // for set whitelisted 'transfer no fee'
  mapping (address => bool) public isWhitelisted;


    // EVENT //
  event RecoverBNB(uint256 amount);
  event RecoverBEP20(address indexed token, uint256 amount);
  event SetCEX(address indexed account, bool indexed exempt);
  event SetMarketMaker(address indexed account, bool indexed isMM);
  event SetTaxes(uint256 reward, uint256 liquidity, uint256 marketing);
  event SetTransferGas(uint256 newGas, uint256 oldGas);
  event SetRewardWallet(address newAddress, address oldAddress);
  event SetMarketingWallet(address newWallet, address oldWallet);
  event SetWhitelisted (address newAddress, bool value);
  event DepositRewards(address indexed wallet, uint256 amount);
  event AirDrop (address indexed wallet, uint256 amount);


  constructor(address owner, address rewards, address marketings) BEP20(owner) {

    // set pair token
    pair = IDexFactory(ROUTER.factory()).createPair(ROUTER.WETH(), address(this));

    isMarketMaker[pair] = true;

    // set reward wallet token
    rewardWallet = rewards;
    marketingWallet = marketings;
    rewardWalletOn = false;
  }

  // Override

  function _transfer(address sender, address recipient, uint256 amount) internal override {
    // if sender or recipient address is WL no take fees
    if (isWhitelisted[sender] || isWhitelisted[recipient] ) {
      super._transfer(sender, recipient, amount);
      return;
    }

    // get fee on pancakeswap 
    uint256 amountAfterTaxes = _takeTax(sender, recipient, amount);

    super._transfer(sender, recipient, amountAfterTaxes);
  }


  // Private

  // take fee from users for sale - buy - transfer
  function _takeTax(address sender, address recipient, uint256 amount) private returns (uint256) {
    if (amount == 0) { return amount; }
    
    // Obtaining percentage of fee (purchase or sale or transfer)
    uint256 percent = _getTotalTax(sender, recipient) ;

    // Reduce the desired percentage
    uint256 taxAmount = amount.mul(percent).div(100);

    // If the status of the recipient's wallet is true, the prize amount will be sent to that wallet, if not, it will be sent to the token contract address.
    address rewAddr_ ;
    address marketAddr_;
    if (rewardWalletOn)
    {
      uint rewShare = taxAmount.mul(70).div(100);
      uint marketShare = taxAmount.mul(30).div(100);

      if (taxAmount > 0) { 
        rewAddr_ = rewardWallet;
        super._transfer(sender, rewAddr_, rewShare); 

        marketAddr_ = marketingWallet;
        super._transfer(sender, marketAddr_, marketShare); 
      }
    }
    else 
    {
      rewAddr_ = address(this);
      if (taxAmount > 0) { super._transfer(sender, rewAddr_, taxAmount); }
    }

    return amount - taxAmount;
  }

  // Obtaining percentage of fee (purchase or sale or transfer) and return this
  function _getTotalTax(address sender, address recipient) private view returns (uint256) {

    if (isCEX[recipient]) { return 0; }
    if (isCEX[sender]) { return buyTax; }

    if (isMarketMaker[sender]) {
      return buyTax;
    } else if (isMarketMaker[recipient]) {
      return sellTax;
    } else {
      return transferTax;
    }
  }

  // Owner

  // take BNB Balance smartcontract token
  function recoverBNB() external onlyOwner {
    uint256 amount = address(this).balance;
    (bool sent,) = payable(rewardWallet).call{value: amount, gas: transferGas}("");
    require(sent, "Tx failed");
    emit RecoverBNB(amount);
  }

  // take BEP20 Balance smartcontract token
  function recoverBEP20(IBEP20 token, address recipient) external onlyOwner {
    require(address(token) != address(this), "Can't withdraw Step");
    uint256 amount = token.balanceOf(address(this));
    token.transfer(recipient, amount);
    emit RecoverBEP20(address(token), amount);
  }

  // set CEX addresses
  function setIsCEX(address account, bool value) external onlyOwner {
    isCEX[account] = value;
    emit SetCEX(account, value);
  }

  // set marketmaker addresses
  function setIsMarketMaker(address account, bool value) external onlyOwner {
    require(account != pair, "Can't modify pair");
    isMarketMaker[account] = value;
    emit SetMarketMaker(account, value);
  }

  // set WL addresses
  function setIsWhitelisted(address account, bool value) external onlyOwner {
    isWhitelisted[account] = value;
    emit SetWhitelisted(account, value);
  }

  // set taxes 'Setting the fees for buying and selling and transfer' Note (the owner cannot set this percentage higher than 49) 
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

  // set rewardwallet
  function setRewardWallet(address newAddress) external onlyOwner {
    require(newAddress != address(0), "New reward pool is the zero address");
    emit SetRewardWallet(newAddress, rewardWallet);
    rewardWallet = newAddress;
  }

  // set matketing wallet
  function setMarketingWallet(address newWallet) external onlyOwner {
    require(newWallet != address(0), "New marketing wallet is the zero address");
    emit SetMarketingWallet(newWallet, marketingWallet);
    marketingWallet = newWallet;
  }

  // function for airdrop token to a list of specified addresses 
  function doAirDrop(address[] memory _address, uint256 _amount) onlyOwner public returns (bool) {
    uint256 count = _address.length;

    for (uint256 i = 0; i < count; i++)
    {
        BEP20._transfer(msg.sender, _address [i], _amount);
        emit AirDrop (_address[i], _amount);
    }

    return true;
  }

  // get fee tokens from address token to rewardwallet
  function getRewardToken () public onlyOwner
  {
      uint256 amountToSwap = balanceOf(address(this));
      super._transfer(address(this), marketingWallet, amountToSwap);
  }

  // bern function
  function burn (uint256 amount_) public onlyOwner
  {
    _burn (msg.sender, amount_);
  }
  function setRewardWalletOn (bool srwallet) public onlyOwner
  {
    rewardWalletOn = srwallet;
  }
}