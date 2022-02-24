/**
 *Submitted for verification at BscScan.com on 2022-02-23
*/

// File: contracts/utils/Context.sol


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
// File: contracts/access/Ownable.sol



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
 *
 * Updated constructor for ^0.8.0
 */
contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor() {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  /**
   * @dev Returns the address of the current owner.
   */
  function owner() public view returns (address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  /**
   * @dev Leaves the contract without owner. It will not be possible to call
   * `onlyOwner` functions anymore. Can only be called by the current owner.
   *
   * NOTE: Renouncing ownership will leave the contract without an owner,
   * thereby removing any functionality that is only available to the owner.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}
// File: contracts/interfaces/IBEP20.sol



pragma solidity ^0.8.0;

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

// File: contracts/token/BEP20.sol



 /**
 * Modified BEP20 template from https://github.com/binance-chain/bsc-genesis-contract/blob/master/contracts/bep20_template/BEP20Token.template
 * solidity version ^0.8.0
 * no safeMath
 * Context, Ownable, IBEP20 separated
 * fixed constructor
 * interface override
 * no external mint
 */

pragma solidity ^0.8.0;



/// @notice 
contract BEP20Token is Ownable, IBEP20 {

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;
  uint8 private _decimals;
  string private _symbol;
  string private _name;

  constructor(string memory _newName, string memory _newSymbol) {
    _name = _newName;
    _symbol = _newSymbol;
    _decimals = 18;
  }

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view override returns (address) {
    return owner();
  }

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view override returns (uint8) {
    return _decimals;
  }

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view override returns (string memory) {
    return _symbol;
  }

  /**
  * @dev Returns the token name.
  */
  function name() external view override returns (string memory) {
    return _name;
  }

  /**
   * @dev See {BEP20-totalSupply}.
   */
  function totalSupply() external view override returns (uint256) {
    return _totalSupply;
  }

  /**
   * @dev See {BEP20-balanceOf}.
   */
  function balanceOf(address account) external view override returns (uint256) {
    return _balances[account];
  }

  /**
   * @dev See {BEP20-transfer}.
   *
   * Requirements:
   *
   * - `recipient` cannot be the zero address.
   * - the caller must have a balance of at least `amount`.
   */
  function transfer(address recipient, uint256 amount) external override returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  /**
   * @dev See {BEP20-allowance}.
   */
  function allowance(address owner, address spender) external view override returns (uint256) {
    return _allowances[owner][spender];
  }

  /**
   * @dev See {BEP20-approve}.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function approve(address spender, uint256 amount) external override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  /**
   * @dev See {BEP20-transferFrom}.
   *
   * Emits an {Approval} event indicating the updated allowance. This is not
   * required by the EIP. See the note at the beginning of {BEP20};
   *
   * Requirements:
   * - `sender` and `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   * - the caller must have allowance for `sender`'s tokens of at least
   * `amount`.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
    require(_allowances[sender][_msgSender()] >= amount, "BEP20: transfer amount exceeds allowance");
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
    return true;
  }

  /**
   * @dev Atomically increases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {BEP20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
    return true;
  }

  /**
   * @dev Atomically decreases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {BEP20-approve}.
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
    require(_allowances[_msgSender()][spender] >= subtractedValue, "BEP20: decreased allowance below zero");
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - subtractedValue);
    return true;
  }

  /**
   * @dev Moves tokens `amount` from `sender` to `recipient`.
   *
   * This is internal function is equivalent to {transfer}, and can be used to
   * e.g. implement automatic token fees, slashing mechanisms, etc.
   *
   * Emits a {Transfer} event.
   *
   * Requirements:
   *
   * - `sender` cannot be the zero address.
   * - `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   */
  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");
    require(_balances[sender] >= amount, "BEP20: transfer amount exceeds balance");

    _balances[sender] = _balances[sender] - amount;
    _balances[recipient] = _balances[recipient] + amount;
    emit Transfer(sender, recipient, amount);
  }

  /** @dev Creates `amount` tokens and assigns them to `account`, increasing
   * the total supply.
   *
   * Emits a {Transfer} event with `from` set to the zero address.
   *
   * Requirements
   *
   * - `to` cannot be the zero address.
   */
  function _mint(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: mint to the zero address");

    _totalSupply = _totalSupply + amount;
    _balances[account] = _balances[account] + amount;
    emit Transfer(address(0), account, amount);
  }

  /**
   * @dev Destroys `amount` tokens from `account`, reducing the
   * total supply.
   *
   * Emits a {Transfer} event with `to` set to the zero address.
   *
   * Requirements
   *
   * - `account` cannot be the zero address.
   * - `account` must have at least `amount` tokens.
   */
  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: burn from the zero address");
    require(_balances[account] >= amount, "BEP20: burn amount exceeds balance");
    _balances[account] = _balances[account] - amount;
    _totalSupply = _totalSupply - amount;
    emit Transfer(account, address(0), amount);
  }

  /**
   * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
   *
   * This is internal function is equivalent to `approve`, and can be used to
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
   * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
   * from the caller's allowance.
   *
   * See {_burn} and {_approve}.
   */
  function _burnFrom(address account, uint256 amount) internal {
    require(_allowances[account][_msgSender()] >= amount, "BEP20: burn amount exceeds allowance");

    _burn(account, amount);
    _approve(account, _msgSender(), _allowances[account][_msgSender()] - amount);
  }
}
// File: contracts/Derobo.sol


pragma solidity ^0.8.0;

/// @title Derobo
/// @author FormalCrypto


// Vesting smart contract interface.
interface IVesting {
    function addTokens(address _user, uint256 _value) external returns (bool);
}

/// @notice Upgraded BEP20 token with a whitelisted swap performed by a dedicated user.
contract Derobo is BEP20Token {

    /*///////////////////////////////////////////////////////////////
                    Global STATE
    //////////////////////////////////////////////////////////////*/

    uint256 private constant DENOM = 10 ** 18;
    uint256 public constant MAX_SUPPLY = 108000000 * DENOM;

    // The address to perform the swap.
    address public swapper;

    // The instance of a swap vesting smart contract interface.
    IVesting public swapVesting;

    // BSC testnet wallets.
    address public constant PRIVATE_SALE_FUNDS = 0x1210BeBdEbF721F688027E7b98dba416028cb6d6;
    address public constant PRIVATE_SALE_INFL = 0x2e8368BB165A381F1f6cf705b7Abc20665Df3B0f;
    address public constant PUBLIC_SALE = 0xCD3826B21bbaA0AD5F76b8306aAA39536613Ad63;
    address public constant LIQUIDITY = 0x4067aeBD2c88888C178D85bDF44cDbA866358472;
    address public constant TEAM = 0x8A4A1D3a15fe11c03983c71d3CEA1fe2Cf5607Ac;
    address public constant PARTNERSHIPS = 0x2264749ca26D6B90C48F5ecD172E03d76c5c2d3E;
    address public constant ADVISORS = 0x8b7ed22A4996e5A07DaB07Fd7A7e4edDa7B54728;
    address public constant COMMUNITY = 0xF970E355c949bC7309818d5CFd190D4525D0a3bC;
    address public constant RESERVE_FUNDS = 0xD0A33C6105074e7b2cc1BFca5e38CE8c01Ffbfa5;

    // Amount available for swap.
    uint256 public availableForSwap = 7560000 * DENOM;
    
    /*///////////////////////////////////////////////////////////////
                    DATA STRUCTURES 
    //////////////////////////////////////////////////////////////*/

    // Ethereum wallets that can get DEROBO tokens in exchange for ROBO.
    mapping(address => bool) public whiteList;

    /*///////////////////////////////////////////////////////////////
                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    // Performs initial minting.
    constructor() BEP20Token("Cryptorobotics", "DEROBO") {

        _mint(PRIVATE_SALE_FUNDS, 15000000 * DENOM);

        _mint(PRIVATE_SALE_INFL, 8000000 * DENOM);

        _mint(PUBLIC_SALE, 4000000 * DENOM);

        _mint(LIQUIDITY, getPercent(MAX_SUPPLY,25));

        _mint(TEAM, getPercent(MAX_SUPPLY,8));

        _mint(PARTNERSHIPS, getPercent(MAX_SUPPLY,7));

        _mint(ADVISORS, getPercent(MAX_SUPPLY,3));

        _mint(COMMUNITY, getPercent(MAX_SUPPLY,20));

        _mint(RESERVE_FUNDS, getPercent(MAX_SUPPLY,5));

    }

    /*///////////////////////////////////////////////////////////////
                    OWNER'S FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Adds an address that is allowed to use the swap function.
     * @param _swapper The address of the new swapper.
     */
    function setSwapper(address _swapper) external onlyOwner {
        swapper = _swapper;
    }

    /**
     * @dev Adds addresses that are allowed to swap ROBO tokens.
     * @param _addresses An array of addresses.
     */
    function addToWhiteList(address[] calldata _addresses) external onlyOwner { 
        for (uint256 i = 0; i < _addresses.length; i++) {
            require(_addresses[i] != address(0), "Approve to the zero address");
            whiteList[_addresses[i]] = true;
        }
    }

    /**
     * @dev Removes addresses that are allowed to swap ROBO tokens.
     * @param _addresses An array of addresses.
     */
    function removeFromWhiteList(address[] calldata _addresses) external onlyOwner {
        for (uint256 i = 0; i < _addresses.length; i++) {
            whiteList[_addresses[i]] = false;
        }
    }

    /**
     * @dev Adds an address of the vesting smart contract.
     * @param _swapVesting The address of the vesting smart contract.
     */
    function setSwapVesting(IVesting _swapVesting) external onlyOwner {
        swapVesting = _swapVesting;
        _approve(address(this), address(_swapVesting), availableForSwap);
    }

    /*///////////////////////////////////////////////////////////////
                    PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Mints new tokens to the vesting smart contract as an exchange of ERC20 ROBO tokens on Ethereum for BEP20 DEROBO tokens on BSC.
     * @param _account The address of the receiver.
     * @param _amount The amount of tokens to mint.
     */
    function swap(address _account, uint256 _amount) external {
        require(swapper == _msgSender(), "Caller is not the swapper");
        require(_amount <= availableForSwap, "Swap amount exceeds availableForSwap");
        _mint(address(this), _amount);
        availableForSwap = availableForSwap - _amount;
        whiteList[_account] = false;
        swapVesting.addTokens(_account, _amount);
    }

    /**
     * @dev See BEP20 _burn.
     * @param _amount The amount of tokens to be burned.
     */
    function burn(uint256 _amount) external {
        _burn(_msgSender(), _amount);
    }

    /**
     * @dev see BEP20 _burnFrom.
     * @param _account The address to burn from.
     * @param _amount The amount of tokens to be burned.
     */
    function burnFrom(address _account, uint256 _amount) external {
        require(_account != _msgSender(), "Please, use regular burn for decreasing your own balance");
        _burnFrom(_account, _amount);
    }

    /*///////////////////////////////////////////////////////////////
                    INTERNAL  HELPERS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Returns the amount equal to the specified percentage of the value.
     * @param _value The amount to get percent from.
     * @param _percent The required percentage.
     */
    function getPercent(uint256 _value, uint256 _percent) private pure returns(uint256) {
        uint256 _quotient = _value * _percent / 100;
        return _quotient;
    }
}