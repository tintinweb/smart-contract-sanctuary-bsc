/**
 *Submitted for verification at BscScan.com on 2022-07-25
*/

// SPDX-License-Identifier: MIT
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


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// File: contracts/ETHBBSEPriceFeedOracle.sol


pragma solidity ^0.8.0;


contract ETHBBSEPriceFeedOracle is Ownable {
  // Max number of blocks before a price update is required
  uint8 public constant MAX_PRICE_AGE = 3;

  // ETH/BBSE rate
  uint private rate;

  // Block number of the last rate update.
  uint public lastUpdateBlock;

  // An event that indicates the price of the priceFeed should be updated
  // Must be listened by the oracle server
  event GetNewRate (string priceFeed);
  
  /**
  * @dev Initializes lastUpdateBlock to current block number and rate to 0.
  * Emits GetNewRate to trigger the oracle server to update the rate.
  * The priceFeed parameter of GetNewRate should be ETH/BBSE
  */
  constructor () { 
    lastUpdateBlock = block.number;
    rate = 0;
    emit GetNewRate("ETH/BBSE");
  }

  /**
  * @dev Updates the rate and sets the lastUpdateBlock to current block number.
  * Can only be called by the owner of the oracle contract.
  * Can't be called internally.
  * @param _rate new rate of the price feed.
  */
  function updateRate (uint _rate) external onlyOwner {
    rate = _rate;
    lastUpdateBlock = block.number;
  }

  /**
  * @dev Returns the current rate.
  * If rate was updated more than MAX_PRICE_AGE block ago,
  * emits GetNewRate event to trigger the oracle server.
  */
  function getRate () public returns (uint){
    if ((block.number - lastUpdateBlock) > MAX_PRICE_AGE) {
      emit GetNewRate("ETH/BBSE");
    }
    return rate;
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

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;




/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
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
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
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
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
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
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
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
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
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
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
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
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

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
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
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

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
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
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// File: contracts/BBSEToken.sol


pragma solidity ^0.8.0;


contract BBSEToken is ERC20 {
  // Minter state variable
  address public minter;

  /**
  * @dev Calls the ERC20 constructor with {name} and {symbol} values.
  * Sets the minter as the contract deployer.
  */
  constructor() payable ERC20("BBSE TOKEN", "BBSE") {
    // Set deployer of the contract as the initial minter
    minter = msg.sender;
  }

  /**
  * @dev Passes the minter role to another address.
  * The minter role can only be passed by the current minter.
  * @param _minter address of the new minter
  */
  function passMinterRole(address _minter) public {
    // Check if msg.sender have minter role
    require(msg.sender == minter, "You are not the minter");
		minter = _minter;
	}

  /**
  * @dev Mints new tokens.
  * Only the minter can mint new tokens.
  * @param account address of receiver of the tokens
  * @param amount amount of the tokens to be issued
  */
  function mint(address account, uint256 amount) public {
    // Check if msg.sender have minter role
    require(msg.sender == minter, "You are not the minter");
		_mint(account, amount);
	}
}
// File: contracts/BBSEBank.sol



pragma solidity ^0.8.0;




contract BBSEBank is Ownable{
  // BBSE Token Contract instance
  BBSEToken private bbseTokenContract;

  // ETHBBSEPriceFeedOracle Contract instance
  ETHBBSEPriceFeedOracle private oracleContract;
  
  // Yearly return rate of the bank
  uint32 public yearlyReturnRate;
  
  // Seconds in a year
  uint32 public constant YEAR_SECONDS = 31536000; 

  // Average block time (set to a large number in order to increase the paid interest i.e., BBSE tokens)
  uint32 public constant AVG_BLOCK_TIME = 10000000;
  
  // Minimum deposit amount (1 Ether, expressed in Wei)
  uint public constant MIN_DEPOSIT_AMOUNT = 10**18;

  /* Min. Collateral value / Loan value
   * Example: To take a 1 ETH loan,
   * an asset worth of at least 1.5 ETH must be collateralized.
  */
  uint8 public constant COLLATERALIZATION_RATIO = 150;

  // 1% of every collateral is taken as fee
  uint8 public constant LOAN_FEE_RATE = 1;

  /* Interest earned per second for a minumum deposit amount.
   * Equals to the yearly return of the minimum deposit amount
   * divided by the number of seconds in a year.
  */
  uint public interestPerSecondForMinDeposit;

  /* The value of the total deposited ETH.
   * BBSEBank shouldn't be giving loans where requested amount + totalDepositAmount > contract's ETH balance.
   * E.g., if all depositors want to withdraw while no borrowers paid their loan back, then the bank contract
   * should still be able to pay.
  */
  uint public totalDepositAmount;

  // Represents an investor record
  struct Investor {
    bool hasActiveDeposit;
    uint amount;
    uint startTime;
  }

  // Address to investor mapping
  mapping (address => Investor) public investors;

   // Represents a borrower record
  struct Borrower {
    bool hasActiveLoan;
    uint amount;
    uint collateral;
  }

  // Address to borrower mapping
  mapping (address => Borrower) public borrowers;

 /**
  * @dev Checks whether the yearlyReturnRate value is between 1 and 100
  */
  modifier validRate (uint _rate) {
    require(_rate > 0 && _rate <= 100, "Yearly return rate must be between 1 and 100");
    _;
  }

  /**
  * @dev Initializes the bbseTokenContract with the provided contract address.
  * Sets the yearly return rate for the bank.
  * Yearly return rate must be between 1 and 100.
  * Calculates and sets the interest earned per second for a minumum deposit amount
  * based on the yearly return rate.
  * @param _bbseTokenContract address of the deployed BBSEToken contract
  * @param _yearlyReturnRate yearly return rate of the bank
  * @param _oracleContract address of the deployed ETHBBSEPriceFeedOracle contract
  */
  constructor (address _bbseTokenContract, uint32 _yearlyReturnRate, address _oracleContract) validRate(_yearlyReturnRate) {
    bbseTokenContract = BBSEToken(_bbseTokenContract);
    oracleContract = ETHBBSEPriceFeedOracle(_oracleContract);
    yearlyReturnRate = _yearlyReturnRate;
    // Calculate interest per second for min deposit (1 Ether)
    interestPerSecondForMinDeposit = ((MIN_DEPOSIT_AMOUNT * yearlyReturnRate) / 100) / YEAR_SECONDS;
  }

  /**
  * @dev Initializes the respective investor object in investors mapping for the caller of the function.
  * Sets the amount to message value and starts the deposit time (hint: use block number as the start time).
  * Minimum deposit amount is 1 Ether (be careful about decimals!)
  * Investor can't have an already active deposit.
  */
  function deposit() payable public{
    require(msg.value >= MIN_DEPOSIT_AMOUNT, "Minimum deposit amount is 1 Ether");
    require(investors[msg.sender].hasActiveDeposit != true, "Account can't have multiple active deposits");

    // Updates total deposited amount
    totalDepositAmount += msg.value;

    investors[msg.sender].amount = msg.value;
    investors[msg.sender].hasActiveDeposit = true;
    investors[msg.sender].startTime = block.number;
  }

  /**
  * @dev Calculates the interest to be paid out based
  * on the deposit amount and duration.
  * Transfers back the deposited amount in Ether.
  * Mints BBSE tokens to investor to pay the interest (1 token = 1 interest).
  * Resets the respective investor object in investors mapping.
  * Investor must have an active deposit.
  */
  function withdraw() public {
    require(investors[msg.sender].hasActiveDeposit == true, "Account must have an active deposit to withdraw");
    Investor storage investor = investors[msg.sender];
    uint depositedAmount = investor.amount;
    uint depositDuration = (block.number - investor.startTime) * AVG_BLOCK_TIME;

    // Updates total deposited amount
    totalDepositAmount -= depositedAmount;

    // Calculate interest per second
    uint interestPerSecond = (interestPerSecondForMinDeposit * depositedAmount) / MIN_DEPOSIT_AMOUNT;
    uint interest = interestPerSecond * depositDuration;

    // Send back deposited Ether to investor
    payable(msg.sender).transfer(depositedAmount);
    // Mint BBSE Tokens to investor, to pay out the interest
    bbseTokenContract.mint(msg.sender, interest);

    // Reset the investor object
    investor.amount = 0;
    investor.hasActiveDeposit = false;
    investor.startTime = 0;
  }

  /**
  * @dev Updates the value of the yearly return rate.
  * Only callable by the owner of the BBSEBank contract.
  * @param _yearlyReturnRate new yearly return rate
  */
  function updateYearlyReturnRate(uint32 _yearlyReturnRate) public onlyOwner validRate (_yearlyReturnRate){
    yearlyReturnRate = _yearlyReturnRate;
  }

  /**
  * @dev Collateralize BBSE Token to borrow ETH.
  * A borrower can't have more than one active loan.
  * ETH amount to be borrowed + totalDepositAmount, must be existing in the contract balance.
  * @param amount the amount of ETH loan request (expressed in Wei)
  */
  function borrow(uint amount) public{
    require (borrowers[msg.sender].hasActiveLoan != true, "Account can't have multiple active loans");
    require ((amount + totalDepositAmount) <= address(this).balance, "The bank can't lend this amount right now");

    // Get the latest price feed rate for ETH/BBSE from the price feed oracle
    uint priceFeedRate = oracleContract.getRate();

    uint collateral = (amount * COLLATERALIZATION_RATIO * priceFeedRate ) / 100;

    /* Try to transfer BBSE tokens from msg.sender to BBSEBank
    *  msg.sender must set an allowance to BBSEBank first, since BBSEBank
    *  needs to transfer the tokens from msg.sender to itself
    */
    require(bbseTokenContract.transferFrom(msg.sender, address(this), collateral), "BBSEBank can't receive your tokens");

    payable(msg.sender).transfer(amount);

    borrowers[msg.sender].hasActiveLoan = true;
    borrowers[msg.sender].amount = amount;
    borrowers[msg.sender].collateral = collateral;
  }

  /** 
  * @dev Pays the borrowed loan.
  * Borrower receives back the collateral - fee BBSE tokens.
  * Borrower must have an active loan.
  * Borrower must send the exact ETH amount borrowed.
  */  
  function payLoan() public payable {
    require (borrowers[msg.sender].hasActiveLoan == true, "Account must have an active loan to pay back");
    require(msg.value == borrowers[msg.sender].amount, "The paid amount must match the borrowed amount");

    uint fee =  (borrowers[msg.sender].collateral * LOAN_FEE_RATE) / 100;

    bbseTokenContract.transfer(msg.sender, borrowers[msg.sender].collateral - fee);

    borrowers[msg.sender].hasActiveLoan = false;
    borrowers[msg.sender].amount = 0;
    borrowers[msg.sender].collateral = 0;
  }

  /** 
  * @dev Called every time Ether is sent to the contract.
  * Required to fund the contract.
  */  
  receive() external payable {}
}