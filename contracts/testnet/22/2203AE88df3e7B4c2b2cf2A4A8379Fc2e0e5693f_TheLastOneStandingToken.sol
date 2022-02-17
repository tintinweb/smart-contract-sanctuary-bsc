/**
 *Submitted for verification at BscScan.com on 2022-02-16
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

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
        assembly { codehash := extcodehash(account) }
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
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
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
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
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
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

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
abstract contract Context {
  // Empty internal constructor, to prevent people from mistakenly deploying
  // an instance of this contract, which should be used via inheritance.

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
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

contract BEP20Token is Context, IBEP20, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;
  uint8 private _decimals;
  string private _symbol;
  string private _name;

  constructor() {
    _name = "The Last One Standing";
    _symbol = "TLOS";
    _decimals = 2;
    _totalSupply = 5000000;
    _balances[msg.sender] = _totalSupply;

    emit Transfer(address(0), msg.sender, _totalSupply);
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
  function balanceOf(address account) external override view returns (uint256) {
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
  function allowance(address owner, address spender) external override view returns (uint256) {
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
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
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
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
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
  function _transfer(address sender, address recipient, uint256 amount) internal virtual{
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
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
}

contract TheLastOneStandingToken is Context, Ownable, BEP20Token{

// TAX FEE IS LOCKED 20% ON THE BUY
    using SafeMath for uint;
    using Address for address;
    uint8 private taxFee;
//=====================================================================================//
// Game Wallets //
    address public bucketAddress;
    uint8   public prizePoolFee;
    uint    private winnerPrize;

    address public marketingFeeReceiverAddress;
    uint8   public marketingFee;

    address public teamFeeReceiverAddress;
    uint8   public teamFee;
    uint8   public bucketPrizeFee;

    address public autoLiquidityReceiverAddress;
    uint8   public liquidityFee;
// Game Wallets //
//=====================================================================================//
// Player Information //
    struct Player {
      uint    id;
      string  name;
      uint    gameMode;
      bool    status;
      address addressPlayer;
      uint    amountPlayer;
      uint    roundWon;
      uint    editionId;
      uint    bucketId;
      uint    gameBlock;
    }

    Player[] private players;

    uint internal idNewPlayer;

    struct SemiWinner {
      uint    id;
      uint    playerId;
      address playerAddress;
      uint    playerAmount;
    }

    struct RealWinner {
      uint    id;
      uint    playerId;
      address playerAddress;
    }

    RealWinner[] private realWinners;
    SemiWinner[] private semiWinners;

// Player Information //
//=====================================================================================//
// Round Information //

    uint[7]       private newMoves = [0,0,0,0,0,0,0];
    string[7]     private newWins = [' ',' ',' ',' ',' ',' ',' '];

    struct PlayerRound {
      uint      id;
      uint      playerId;
      uint[7]   moves;
      string[7] win;
    }

    PlayerRound[] private playerRounds;
    
    struct Round {
      uint      id;
      uint      idEdition;
      uint      dayGame;
      uint[2]   playersIdVersus;
      uint8[2]  playersMove;
      uint      winner;
      bool      draw;
      bool      processed;
    }

    uint[2]   private newplayersVersus = [0,0];
    uint8[2]  private newplayersMove = [0,0];

    Round[]   private rounds;

    uint internal idNewRound;
// Round Information //
//=============================//
// Edition Information //
    struct Edition {
      uint   id;
      bool   active;
      uint   qtyDays;
      string startDate;
      string endDate;
      uint   gameMode;
    }

    Edition[] private editions;

    uint internal idNewEdition;
// Edition Information //
//=============================//
// Bucket Information //
    struct Bucket {
      uint id;
      bool active;
      uint bucketAmount;
      uint editionId;
      uint winner;
    }

    Bucket[] private buckets;

    uint internal idNewBucket;
// Bucket Information //
//=====================================================================================//
// Game Information //
    uint private _amountRequired;
    uint private _totalAmount;
    uint private _totalPlayersPlaying;
    uint private _gameEdition;
    uint private _bucketId;
    bool private _winner;
    bool private _maintenance;
    uint private _playerAmountToReceive;
    uint8 private _dayGame;
// Game Information //
//=====================================================================================//
//Constructor section
  constructor() {
    prizePoolFee = 15;
    marketingFee = 1;
    teamFee = 2;
    liquidityFee = 2;
    _totalAmount = 0;
    idNewPlayer = 0;
    idNewBucket = 0;
    idNewEdition = 0;
    idNewRound = 1;
    _totalPlayersPlaying = 0;
    bucketPrizeFee = 10;
    winnerPrize = 90;
    _winner = false;
    _maintenance = true;
    _playerAmountToReceive = 80;
    _dayGame = 1;
  }
//Constructor section
//=====================================================================================//
// Owner Section //

    function setBucketAddress(address newbucketAddress) private onlyOwner{
      bucketAddress = newbucketAddress;
    }

    function setMarketingFeeReceiverAddress(address  newMarketingFeeReceiverAddress) private onlyOwner{
      marketingFeeReceiverAddress = newMarketingFeeReceiverAddress;
    }

    function setTeamFeeReceiverAddress(address  newTeamFeeReceiverAddress) private onlyOwner{
      teamFeeReceiverAddress = newTeamFeeReceiverAddress;
    }

    function setAutoLiquidityReceiverAddress(address  newAutoLiquidityReceiverAddress) private onlyOwner{
      autoLiquidityReceiverAddress = newAutoLiquidityReceiverAddress;
    }

    function setGameWallets(uint typeWallet,address walletAddress) public onlyOwner{
      if(typeWallet == 1){setBucketAddress(walletAddress);}
      else if(typeWallet == 2){setMarketingFeeReceiverAddress(walletAddress);}
      else if(typeWallet == 3){setTeamFeeReceiverAddress(walletAddress);}
      else if(typeWallet == 4){setAutoLiquidityReceiverAddress(walletAddress);}
    }

    function setBuyAmount(uint16 newAmount) public onlyOwner{
      _amountRequired = newAmount;
      _totalAmount.add(newAmount);
    }

    function setNewEditionBucket(string memory startDate, string memory endDate) public onlyOwner returns(uint id){
      return(newBucket(newEdition(startDate, endDate)));
    }

    function setUpdateMaintenance(uint8 maintenance) public onlyOwner returns(bool){
      if(maintenance == 1){
        _maintenance = true;
      }else{
        _maintenance = false;
      }
      return(_maintenance);
    }

    function setDaysPlaying() private onlyOwner{
      if(editions[editions.length-1].gameMode == 1){
        editions[editions.length-1].qtyDays++;
      }
    }

    // FUNCTION THAT PLAYS THE GAME
    // ROCK = 1  || SCISSOR = 2 || PAPER = 3
    // ROCK > SCISSOR
    // SCISSOR > PAPER
    // PAPER > ROCK
    function setPlayRounds() private onlyOwner{
      uint _id;
      while(_id < rounds.length-1){
        if(rounds[_id].processed == false){
          if(rounds[_id].playersIdVersus[0] != 0){
            if(rounds[_id].playersMove[0] == 1 && rounds[_id].playersMove[1] == 2){
              rounds[_id].winner = rounds[_id].playersIdVersus[0];
              playerRounds[rounds[_id].playersIdVersus[0]].playerId = rounds[_id].playersIdVersus[0];
              playerRounds[rounds[_id].playersIdVersus[0]].moves[_dayGame] = rounds[_id].playersMove[0];
              playerRounds[rounds[_id].playersIdVersus[0]].win[_dayGame] = "Rock";
            }
            else if(rounds[_id].playersMove[0] == 2 && rounds[_id].playersMove[1] == 3){
              rounds[_id].winner = rounds[_id].playersIdVersus[0];
              playerRounds[rounds[_id].playersIdVersus[0]].playerId = rounds[_id].playersIdVersus[0];
              playerRounds[rounds[_id].playersIdVersus[0]].moves[_dayGame] = rounds[_id].playersMove[0];
              playerRounds[rounds[_id].playersIdVersus[0]].win[_dayGame] = "Scissor";
            }
            else if(rounds[_id].playersMove[0] == 3 && rounds[_id].playersMove[1] == 1){
              rounds[_id].winner = rounds[_id].playersIdVersus[0];
              playerRounds[rounds[_id].playersIdVersus[0]].playerId = rounds[_id].playersIdVersus[0];
              playerRounds[rounds[_id].playersIdVersus[0]].moves[_dayGame] = rounds[_id].playersMove[0];
              playerRounds[rounds[_id].playersIdVersus[0]].win[_dayGame] = "Paper";
            }
            else if(rounds[_id].playersMove[1] == 1 && rounds[_id].playersMove[0] == 2){
              rounds[_id].winner = rounds[_id].playersIdVersus[1];
              playerRounds[rounds[_id].playersIdVersus[1]].playerId = rounds[_id].playersIdVersus[1];
              playerRounds[rounds[_id].playersIdVersus[1]].moves[_dayGame] = rounds[_id].playersMove[1];
              playerRounds[rounds[_id].playersIdVersus[1]].win[_dayGame] = "Rock";
            }
            else if(rounds[_id].playersMove[1] == 2 && rounds[_id].playersMove[0] == 3){
              rounds[_id].winner = rounds[_id].playersIdVersus[1];
              playerRounds[rounds[_id].playersIdVersus[1]].playerId = rounds[_id].playersIdVersus[1];
              playerRounds[rounds[_id].playersIdVersus[1]].moves[_dayGame] = rounds[_id].playersMove[1];
              playerRounds[rounds[_id].playersIdVersus[1]].win[_dayGame] = "Scissor";
            }
            else if(rounds[_id].playersMove[1] == 3 && rounds[_id].playersMove[0] == 1){
              rounds[_id].winner = rounds[_id].playersIdVersus[1];
              playerRounds[rounds[_id].playersIdVersus[1]].playerId = rounds[_id].playersIdVersus[1];
              playerRounds[rounds[_id].playersIdVersus[1]].moves[_dayGame] = rounds[_id].playersMove[1];
              playerRounds[rounds[_id].playersIdVersus[1]].win[_dayGame] = "Paper";
            }
            else if(rounds[_id].playersMove[1] == rounds[_id].playersMove[0]){
              rounds[_id].draw = true;
            }
          }
          rounds[_id].processed = true;
        }
      }
    }

    function setMaintenanceUpdate(uint16 newAmount) public onlyOwner{
      setBuyAmount(newAmount);
      setPlayRounds();
      _dayGame++;
    }


//Finding the Last One Standing//
    function findWinner() private onlyOwner returns (bool){
     //SELECTING WINNERS WHO WON THE GAME
      uint _id = players.length-1;
      uint _winnerId = 0;
      do{
         if(players[_id].amountPlayer.add(players[_id].roundWon) >= _totalAmount){
           _winnerId++;
           semiWinners.push(SemiWinner(_winnerId,players[_id].id,players[_id].addressPlayer,players[_id].amountPlayer.add(players[_id].roundWon))); 
         }
         _id--;
      }while(players[_id].editionId == editions.length-1);
       //SELECTING TOP WINNERS
      uint _realWinnerId = 0;
      uint biggestAmount = semiWinners[0].playerAmount;
      //DEFINING THE BIGGEST AMOUNT
      while(_realWinnerId < semiWinners.length-1){
        if(biggestAmount < semiWinners[_realWinnerId].playerAmount){
          biggestAmount = semiWinners[_realWinnerId].playerAmount;
        }
        _realWinnerId++;
      }

      //Getting all players that has the biggest amount
      _realWinnerId = 0;
      while(_realWinnerId < semiWinners.length-1){
        if(semiWinners[_realWinnerId].playerAmount == biggestAmount){
           realWinners.push(RealWinner(_winnerId,players[_id].id,players[_id].addressPlayer)); 
        }
        _realWinnerId++;
      }
      if(realWinners.length >= 1){
        _winner = true;
        return true;
      }else{
        return false;
       }
    }

// IN CASE SOMEONE BRAKE THE GAME - Reseting Game
    function resetGame() private onlyOwner{
        delete players;
        delete buckets;
        delete editions;
    }

// Owner Section //
//=====================================================================================//
//Creating new edition //
    function newEdition(string memory startDate,string memory endDate) private returns(uint id){
      _gameEdition = idNewEdition;
      editions.push(Edition(_gameEdition,true,1,startDate,endDate,1));
      idNewEdition++;
      return(_gameEdition);
    }

//Getting edition info//
    function getEditionInformation(uint _id) view public returns (uint id, bool active, string memory start_Date, string memory end_Date,uint qtyDays, uint game_mode) {
      return (editions[_id].id,editions[_id].active,editions[_id].startDate,editions[_id].endDate,editions[_id].qtyDays,editions[_id].gameMode);
    }

    function getEditionDay() public view returns(uint day){
      return(editions[editions.length-1].qtyDays);
    }

    function getCurrentEdition() public view returns(uint edition){
      return(editions.length-1);
    }

//Creating new bucket //
    function newBucket(uint editionId) private returns(uint id){
      _bucketId = idNewBucket;
      buckets.push(Bucket(_bucketId,true,0,editionId,0));
      idNewBucket++;
      return(_bucketId);
    }

//Getting bucket info//
    function getBucketInformation(uint _id) view public returns (uint Id, bool Active, uint Bucket_amount, uint Edition_Id) {
      return (buckets[_id].id,buckets[_id].active,buckets[_id].bucketAmount,buckets[_id].editionId);
    }

//Creating new player //
    function setNewPlayer(address playerAddress, uint amount) public{
      uint _id = idNewPlayer;
      players.push(Player(_id,"No name",1,true,playerAddress,amount,0,_gameEdition,_bucketId,_id/500));
      playerRounds.push(PlayerRound(_id,_id,newMoves,newWins));
      if(_id % 2 == 1){
        setNewRound(_id);
      }else{
        rounds[rounds.length-1].playersIdVersus[1] = _id;
       }
      idNewPlayer++;
    }

//Updating player Amount//
    function setPlayerAmount(uint _id, uint amount) view private{
      players[_id].amountPlayer.add(amount);
    }

//Updating player Status(if he/she is playing or not)//
    function setPlayerStatus(uint _id, bool status) private{
      players[_id].status = status;
    }

//Getting player info//
    function getPlayerInfo(uint _id) view public returns (uint id, bool status, address addressPlayer, uint amountPlayer, uint editionId, uint gameBlock, uint gameMode) {
      return (players[_id].id,
              players[_id].status,
              players[_id].addressPlayer,
              players[_id].amountPlayer,
              players[_id].editionId,
              players[_id].gameBlock,
              players[_id].gameMode);
    }

//Getting player Status(if he/she is playing or not)//
    function getPlayerStatus(uint _id) private view returns (bool){
      return(players[_id].status);
    }

//Getting player info during transfer//
    function getFindPlayer(address playerAddress,uint editionId) view private returns (uint id) {
     uint _id = players.length - 1;
      while (players[_id].editionId == editionId && players[_id].addressPlayer != playerAddress) {
         _id--;
      }
      return (players[_id].id);
    }

//Knowing if player is already registered into the current edition//
    function getPlayerRegistered(address playerAddress,uint editionId) view private returns (bool found) {
     uint _id = players.length - 1;
      while (players[_id].editionId == editionId && players[_id].addressPlayer != playerAddress) {
         _id--;
      }
      if(players[_id].addressPlayer == playerAddress){
       return (true);
      }else{
        return (false);
      }
    }

//Getting Player Id of the current Edition//
    function getPlayerId(address playerAddress,uint editionId) view public returns (uint Id) {
     uint _id = players.length - 1;
     bool found;
      while (players[_id].addressPlayer != playerAddress && found == false) {
        if(players[_id].addressPlayer == playerAddress && players[_id].editionId == editionId){
          break;
        }
         _id--;
      }
      return _id;
    }

//Get total players//
    function getTotalPlayer() view public returns (uint) {
      return players.length;
    }

//Get player Amount //
    function getPlayerAmount(uint _id) view private returns (uint) {
      return players[_id].amountPlayer;
    }

//Creating round for 2 players //
    function setNewRound(uint playerId) private{
      uint _id = idNewRound;
      newplayersVersus[0] = playerId;
      rounds.push(Round(_id,editions.length-1,_dayGame,newplayersVersus,newplayersMove,0,false,false));
      idNewRound++;
    }

//Updating total players playing //
    function setTotalAddressPlaying() private {
      _totalPlayersPlaying = 0;
      for (uint id = players.length - 1; players[id].editionId == editions.length - 1; id--){
        if(players[id].status == true){
          _totalPlayersPlaying.add(1);
        }else{
          continue;
        }
      }
    }

//Getting total players playing //
    function getTotalAddressPlaying() public view returns(uint){
      return(_totalPlayersPlaying);
    }

//Transfer taxes
    function preTransfer(address sender, uint amount) private{
        super._transfer(sender, bucketAddress, amount.mul(prizePoolFee).div(100));
        super._transfer(sender, marketingFeeReceiverAddress, amount.mul(marketingFee).div(100));
        super._transfer(sender, teamFeeReceiverAddress, amount.mul(teamFee).div(100));
        super._transfer(sender, autoLiquidityReceiverAddress, amount.mul(liquidityFee).div(100));
        amount = amount.mul(_playerAmountToReceive).div(100);
    }

  function _transfer(address sender, address payable recipient , uint256 amount) internal virtual {
    require(_maintenance == false,"Game is Updating");
      if(sender != owner()){
        //Minimal verification
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        require(amount <= _amountRequired,"Amount can't be greater than maximum");
        if(getEditionDay() == 1 && getPlayerRegistered(recipient,getCurrentEdition()) == false){
          preTransfer(sender, amount);
          setNewPlayer(recipient,amount);
        }else if(getPlayerRegistered(recipient,getCurrentEdition())){
          uint playerId = getPlayerId(recipient,getCurrentEdition());
          preTransfer(sender, amount);
          require(getPlayerAmount(playerId).add(amount)<=_totalAmount,"Player amount can't exceed maximum amount");
          setPlayerAmount(playerId,amount);
        }else{
          preTransfer(sender, amount);
        }
      }
      if(sender == owner() && _winner){
        super._transfer(bucketAddress, teamFeeReceiverAddress, amount.mul(bucketPrizeFee).div(100));
        super._transfer(bucketAddress, recipient, amount.mul(winnerPrize).div(100));
        _dayGame = 1;
        _winner = false;
      }else{
        super._transfer(sender, recipient, amount);
      }
  }
}