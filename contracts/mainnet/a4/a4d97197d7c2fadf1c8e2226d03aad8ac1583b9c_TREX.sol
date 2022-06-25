/**
 *Submitted for verification at BscScan.com on 2022-06-25
*/

// SPDX-License-Identifier: RXFNDTN

pragma solidity ^0.7.4;

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ //
// ░░██████╗░░░███████╗░░██╗░░░██╗░░ //  TREX TOKEN
// ░░██╔══██╗░░██╔════╝░░╚██╗░██╔╝░░ //
// ░░██████╔╝░░█████╗░░░░░╚████╔╝░░░ //  PART OF "REX" SMART CONTRACTS
// ░░██╔══██╗░░██╔══╝░░░░░██╔═██╗░░░ //
// ░░██║░░██║░░███████╗░░██╔╝░░██╗░░ //  FOR DEPLOYMENT ON NETWORK:
// ░░╚═╝░░╚═╝░░╚══════╝░░╚═╝░░░╚═╝░░ //  BINANCE SMART CHAIN - ID: 56
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ //
// ░░ Latin: king, ruler, monarch ░░ //
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ //
// ░░░ Copyright (C) 2022 rex.io ░░░ //  SINGLE SOURCE OF TRUTH: rex.io
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ //

// Name     :: TREX
// Ticker   :: XTRX
// Decimals :: 0

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library SafeMath32 {

    function add(uint32 a, uint32 b) internal pure returns (uint32) {
        uint32 c = a + b;
        require(c >= a);
        return c;
    }

    function sub(uint32 a, uint32 b) internal pure returns (uint32) {
        require(b <= a);
        uint32 c = a - b;
        return c;
    }

    function mul(uint32 a, uint32 b) internal pure returns (uint32) {

        if (a == 0) {
            return 0;
        }

        uint32 c = a * b;
        require(c / a == b);
        return c;
    }

    function div(uint32 a, uint32 b) internal pure returns (uint32) {
        require(b > 0);
        uint32 c = a / b;
        return c;
    }

    function mod(uint32 a, uint32 b) internal pure returns (uint32) {
        require(b != 0);
        return a % b;
    }
}

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, 'Address: insufficient balance');

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, 'Address: low-level call failed');
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, 'Address: insufficient balance for call');
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), 'Address: call to non-contract');

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }

//  function _msgData() internal view returns (bytes memory) {
//    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
//    return msg.data;
//  }
}

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
contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor () {
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
  function renounceOwnership() external onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) external onlyOwner {
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

contract BEP20Token is Context, Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 0;
    }

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address) {
      return owner();
    }

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8) {
      return _decimals;
    }

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory) {
      return _symbol;
    }

    /**
    * @dev Returns the token name.
    */
    function name() external view returns (string memory) {
      return _name;
    }

    /**
     * @dev See {BEP20-totalSupply}.
     */
    function totalSupply() external view returns (uint256) {
      return _totalSupply;
    }

    /**
     * @dev See {BEP20-balanceOf}.
     */
    function balanceOf(address account) public view returns (uint256) {
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
    function transfer(address recipient, uint256 amount) external returns (bool) {
      _transfer(_msgSender(), recipient, amount);
      return true;
    }

    /**
     * @dev See {BEP20-allowance}.
     */
    function allowance(address owner, address spender) external view returns (uint256) {
      return _allowances[owner][spender];
    }

    /**
     * @dev See {BEP20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) external returns (bool) {
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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
      _transfer(sender, recipient, amount);
      _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
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
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
      _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
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
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
      _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
      return true;
    }

    /**
     * @dev Creates `amount` tokens and assigns them to `msg.sender`, increasing
     * the total supply.
     *
     * Requirements
     *
     * - `msg.sender` must be the token owner
     */
    function mint(uint256 amount) external onlyOwner returns (bool) {
      _mint(_msgSender(), amount);
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

      _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
      _balances[recipient] = _balances[recipient].add(amount);
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

      _totalSupply = _totalSupply.add(amount);
      _balances[account] = _balances[account].add(amount);
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

      _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
      _totalSupply = _totalSupply.sub(amount);
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

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

interface IBEP20 {
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

/**
 * @title TREX
 * @dev TREX BEP20 Token - used in REX smart contract
 */
contract TREX is BEP20Token {

    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using Address for address;

    uint32 constant SELL_EVERY_X_DAYS = 3;              // number of days, another TREX is sellable for airdropped addresses)

    uint256 constant SECONDS_IN_DAY = 86400 seconds;
    uint256 constant HALVING_EVERY = 100;               // number of soldTREX until next halving (price rise)
    uint256 public constant MAX_DEX_SUPPLY = 40000;     // max DEX supply: 40,000 TREX (+ 10*totalAirdropAdresses)

    uint256 public LAUNCH_TIME;
    uint256 public price = 500E18;              // public number, 500 BUSD is the start price, public
    uint256 public constant priceRise = 5E18;   // public number, price rises every halving by 5 BUSD
    uint256 public soldTREX;                    // public number, total number of sold TREX (buyers from the contract)
    uint256 public unSoldAirdropTREXes;         // public number, total number of UNSOLD TREX (from airdrop)
    uint256 public halvingNumber;               // public number, counts the halvings (when price rises)
    uint256 public totalAirdropAdresses;        // public number, counts number of airdropped addresses (to verify after deployment)
    uint256 public soldAirTrexBUSD;             // public number, total number of BUSD from sold TREX (from airdrop)

    IBEP20 public BUSD_TOKEN;

    address constant busd_address = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address private constant MARKETING_ADDR = 0x231f8084fECEee5b90021C42C083FEB73d4182F9;
    address private constant DEVELOPMENT_ADDR = 0xF3393b11Dc4CADFDc5BCed0F7BEB9d09Ce5C78D6;

    mapping (address => uint32) public _airdropBalances;       // CONSTANT number of airdropped TREX per address
    mapping (address => uint32) public _airdropBalancesLeft;   // KEEP TRACK of UNSOLD airdropped TREX per address, initilized on init()
    mapping (address => bool) public _airdropClaimed;          // Reentrancy guard, prevent from multiple claims

    event ReceivedTREX(address indexed receiver, uint256 amount);
    event SoldAirdroppedTREX(address indexed seller, uint256 price);

    constructor() BEP20Token("TREX", "XTRX") {
        BUSD_TOKEN = IBEP20(busd_address);
        LAUNCH_TIME = block.timestamp;
    }

    /**
     * @notice A function for saving the airdrop amounts after deployment
     * @param _address for the airdrop
     * @param _amount for the airdrop
     */
    function initClaimables(
        address[] memory _address,
        uint32[] memory _amount
    )
        external onlyOwner
    {
        for(uint256 i = 0; i < _address.length; i++) {
            if (_airdropBalances[_address[i]] == 0 && !isContract(_address[i])) {   // if not counted before and not contract
                totalAirdropAdresses = totalAirdropAdresses.add(1);                 // both for totalAirdropAdresses
                unSoldAirdropTREXes = unSoldAirdropTREXes.add(_amount[i]);          // and unSoldAirdropTREXes
                _airdropBalances[_address[i]] = _amount[i];                         // and assign amount to address
            }
        }
    }

    function isContract(address account) internal view returns (bool) {
        bytes32 codehash; bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function getHalving(uint256 sold) internal pure returns (bool) {
        return sold % HALVING_EVERY == 0;
    }

    function _daysFromStart() internal view returns (uint32) {
        return uint32((block.timestamp - LAUNCH_TIME) / SECONDS_IN_DAY);
    }

    function _getNeededAirdropReserve() internal view returns (uint256) {
        return price.mul(unSoldAirdropTREXes);
    }

    /**
     * @notice Function to buy TREX by sending BUSD
     * @dev APPROVE (contract, amount) first
     */
    function buyOneTREX() external {
        require(! isContract(msg.sender) && msg.sender == tx.origin, "TREX: Contracts cannot buy!");
        require(BUSD_TOKEN.transferFrom(msg.sender, address(this), price), "TREX: Transfer of BUSD failed." );
        require(soldTREX < MAX_DEX_SUPPLY, "TREX: All TREX sold.");

        soldTREX = soldTREX.add(1);

            // if more BUSD in contract than needed for airdrop sales, send all to marketing, else put 20% into marketing / dev fund
        if ( BUSD_TOKEN.balanceOf(address(this)) >= _getNeededAirdropReserve() )
        {
            BUSD_TOKEN.transfer(MARKETING_ADDR, price);
        }
        else
        {
            uint256 marketingAndDevFundBUSD = price.mul(10).div(100);
            BUSD_TOKEN.transfer(MARKETING_ADDR, marketingAndDevFundBUSD);
            BUSD_TOKEN.transfer(DEVELOPMENT_ADDR, marketingAndDevFundBUSD);
        }

        if (getHalving(soldTREX)) {
            price = price.add(priceRise);
            halvingNumber = halvingNumber.add(1);
        }

        _mint(msg.sender, 1);

        emit ReceivedTREX(msg.sender, 1);
    }

    /**
     * @notice Function to allow airdropped addresses to sell TREX, as long as there is BUSD in the contract
     */
    function sellAirdroppedTREX() external {
        require(balanceOf(msg.sender) > 0, "TREX: Address cannot sell.");               // msg.sender must have a TREX to sell
        require(_airdropBalancesLeft[msg.sender] > 0, "TREX: No TREX left to sell.");   // msg.sender must have a TREX from airdrop left to sell
        require(BUSD_TOKEN.balanceOf(address(this)) >= price, "TREX: Not enough BUSD in the contract.");

          // check noOfTREXSellable: an address may sell 1/10 of airdropped TREX amount every X days:
        require(noOfTREXSellable(msg.sender) > 0, "TREX: Address cannot sell right now.");

        _burn(msg.sender, 1);
        _airdropBalancesLeft[msg.sender] = _airdropBalancesLeft[msg.sender].sub(1);
        unSoldAirdropTREXes = unSoldAirdropTREXes.sub(1);
        soldAirTrexBUSD = soldAirTrexBUSD.add(price);

        BUSD_TOKEN.transfer(msg.sender, price);

        emit SoldAirdroppedTREX(msg.sender, price);
    }

    /**
     * @notice Function to get the number of sellable TREX now for an airdropped address
     */
    function noOfTREXSellable(address _seller) public view returns (uint32) {
        return
            (
            ( _airdropBalances[_seller].div(10) )
            .mul( _daysFromStart().div(SELL_EVERY_X_DAYS).add(1) )
            .sub( _airdropBalances[_seller].sub(_airdropBalancesLeft[_seller]) )
            )
            > _airdropBalancesLeft[_seller]
            ? _airdropBalancesLeft[_seller]
            : (
            ( _airdropBalances[_seller].div(10) )
            .mul( _daysFromStart().div(SELL_EVERY_X_DAYS).add(1) )
            .sub( _airdropBalances[_seller].sub(_airdropBalancesLeft[_seller]) )
            );
    }


    // AIRDROP claim functions

    // WEB: check for _airdropClaimed[address] (bool) if address has claimed already
    // WEB: check for canClaimAirdropNow(address) (bool) if address can claim NOW

    /**
     * @notice Function to CHECK eligibility to claim TREX Airdrop
     */
    function canClaimAirdropNow(address _claimer) external view returns (bool) {
        return _airdropBalances[_claimer] > 0 && !_airdropClaimed[_claimer];
    }

    /**
      * @notice Function to CLAIM TREX Airdrop,  mints the amount of TREX to the address
     */
    function claimAirdrop() external {
        require(_airdropBalances[msg.sender] > 0, "TREX: Address not eligible.");
        require(! _airdropClaimed[msg.sender], "TREX: Address has already claimed.");

        _airdropClaimed[msg.sender] = true;
        _airdropBalancesLeft[msg.sender] = _airdropBalances[msg.sender]; // save balances in the "left" balances, to subtract from later

        uint256 _toMint = uint256(_airdropBalances[msg.sender]);
        _mint(msg.sender, _toMint);

        emit ReceivedTREX(msg.sender, _toMint);
    }

    receive() external payable { revert(); }
    fallback() external payable { revert(); }

}