/**
 *Submitted for verification at BscScan.com on 2022-04-11
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.5.16;

/**
 * @dev It's Area53 Interface
 */
interface IBEP20A53 {
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

  /**
   * @dev Returns the maximum amount of tokens can be mint.
   */
  function maxTotalSupply() external view returns (uint256);

  /**
   * @dev returns the day number of the current day, in days since the UNIX epoch.
   */
  function today() external view returns (uint32 dayNumber);

  /**
   * @dev returns all information about the grant's vesting as of the given day
   * for the given account.
   */
  function vestingForAccountAsOf(
      address grantHolder,
      uint32 onDayOrToday
  )
  external
  view
  returns (
      uint256 amountVested,
      uint256 amountNotVested,
      uint256 amountOfGrant,
      uint32 vestStartDay,
      uint32 cliffDuration,
      uint32 vestDuration,
      uint32 vestIntervalDays,
      bool isExisting,
      bool wasRevoked,
      uint32 revokedDay
  );
  
  /**
   * @dev Returns the available amount of a grantHolder.
   */
  function getAvailableAmount(address grantHolder, uint32 onDayOrToday) external view returns (uint256);

  event VestingScheduleCreated(
      address indexed vestingLocation,
      uint32 cliffDuration, uint32 indexed duration, uint32 interval,
      bool indexed isRevocable);

  event VestingTokensGranted(
      address indexed beneficiary,
      uint256 indexed vestingAmount,
      uint32 startDay,
      address vestingLocation,
      address indexed grantor);

  event GrantRevoked(address indexed grantHolder, uint32 indexed onDay);

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  event SubmitMultiSignTransaction(
      address indexed owner,
      uint indexed txIndex,
      uint32 txCode
  );

  event SignMultiSignTx(address indexed owner, uint indexed txIndex);
  event RevokeSignature(address indexed owner, uint indexed txIndex);
  event ExecuteMultiSignTx(address indexed owner, uint indexed txIndex);
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

/**
 * @dev Area53 Token Contract
 */
contract BEP20A53 is IBEP20A53 {
  // using Safe Match
  using SafeMath for uint256;

  // list of owners & the minimum number of signatures required for multi-sign transaction 
  address[] private owners;
  uint private numSignaturesRequired;

  // owner status
  mapping(address => bool) public isOwner;
  modifier onlyOwner() {
      require(isOwner[msg.sender], "You are not owner");
      _;
  }

  // balance & allowance
  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 public _maxTotalSupply;
  uint256 private _totalSupply;
  uint8 public _decimals;
  string public _symbol;
  string public _name;
  
  // Date-related constants for sanity-checking dates to reject obvious erroneous inputs
  // and conversions from seconds to days and years that are more or less leap year-aware.
  uint32 private constant THOUSAND_YEARS_DAYS = 365243;                   /* See https://www.timeanddate.com/date/durationresult.html?m1=1&d1=1&y1=2000&m2=1&d2=1&y2=3000 */
  uint32 private constant TEN_YEARS_DAYS = THOUSAND_YEARS_DAYS / 100;     /* Includes leap years (though it doesn't really matter) */
  uint32 private constant SECONDS_PER_DAY = 24 * 60 * 60;                 /* 86400 seconds in a day */
  uint32 private constant JAN_1_2000_SECONDS = 946684800;                 /* Saturday, January 1, 2000 0:00:00 (GMT) (see https://www.epochconverter.com/) */
  uint32 private constant JAN_1_2000_DAYS = JAN_1_2000_SECONDS / SECONDS_PER_DAY;
  uint32 private constant JAN_1_3000_DAYS = JAN_1_2000_DAYS + THOUSAND_YEARS_DAYS;
  uint32 private constant MULTISIGN_TX_TIMEOUT = 1800;                    /* 30 minutes = 1800 seconds */

  /**
   *https://docs.soliditylang.org/en/develop/control-structures.html#default-value
   *A variable which is declared will have an initial default value whose byte-representation is all zeros. 
   *The “default values” of variables are the typical “zero-state” of whatever the type is. 
   *For example, the default value for a bool is false. The default value for the uint or int types is 0
  */

  struct vestingSchedule {
      bool isValid;               /* true if an entry exists and is valid */
      bool isRevocable;           /* true if the vesting option is revocable (a gift), false if irrevocable (purchased) */
      uint32 cliffDuration;       /* Duration of the cliff, with respect to the grant start day, in days. */
      uint32 duration;            /* Duration of the vesting schedule, with respect to the grant start day, in days. */
      uint32 interval;            /* Duration in days of the vesting interval. */
  }

  struct tokenGrant {
      bool isExisting;            /* true if this vesting entry is existence. prevent a beneficiary is granted two times*/
      bool wasRevoked;            /* true if this vesting schedule was revoked. */
      uint32 startDay;            /* Start day of the grant, in days since the UNIX epoch (start of day). */
      uint256 amount;             /* Total number of tokens that vest. */
      address vestingLocation;    /* Address of wallet that is holding the vesting schedule. */
      address grantor;            /* Grantor that made the grant */
      uint32 revokedDay;          /* the day this vesting schedule was revoked */
  }
  
  mapping(address => vestingSchedule) private _vestingSchedules;
  mapping(address => tokenGrant) private _tokenGrants;

  // multi-sign transaction structure
  struct multiSignTransaction {
      /*
      txCode = 0: mint
      txCode = 1: transfer ownership
      txCode = 2: grant vesting
      txCode = 3: revoke grant
      */
      uint32 txCode;
      address from;
      address to;
      uint256 value;

      uint256 vestingAmount;
      uint32 vestingStartDay;
      uint32 vestingDuration;
      uint32 vestingCliffDuration;
      uint32 vestingInterval;
      bool isRevocableVesting;

      uint256 creationTime;
      bool executed;
      uint numSignatures;
  }

  // to check if an address has sign a multi-sign transaction
  mapping(uint => mapping(address => bool)) public isSigned;

  // multi-sign transaction array
  multiSignTransaction[] private multiSignTxs;

  modifier multiSignTx_exists(uint _txIndex) {
      require(_txIndex < multiSignTxs.length, "Transaction does not exist");
      _;
  }

  modifier multiSignTx_have_not_executed(uint _txIndex) {
      require(!multiSignTxs[_txIndex].executed, "Transaction have already executed");
      _;
  }

  modifier i_have_not_signed(uint _txIndex) {
      require(!isSigned[_txIndex][msg.sender], "You have already signed");
      _;
  }

  modifier i_have_signed(uint _txIndex) {
      require(isSigned[_txIndex][msg.sender], "You have not signed");
      _;
  }

  modifier is_time_out(uint _txIndex) {
      require(
        (block.timestamp - multiSignTxs[_txIndex].creationTime) <= MULTISIGN_TX_TIMEOUT,
        "Timeout, execution is only valid for less than 30 minutes from the creation time"
      );
      _;
  }

  /**
   * @dev Eg. ["owner_addr1","owner_addr2","owner_addr3"], 2 => 2/3 multi sign
   */
  constructor(address[] memory _owners, uint _numSignaturesRequired_per_multiSignTx) public {
    _name = "A53 Token";
    _symbol = "A53";
    _decimals = 18;
    _maxTotalSupply = 150000000 * 10**18;
    _totalSupply = 0;

    require(_owners.length >= 3, "At least 3 owners required");
    require(_numSignaturesRequired_per_multiSignTx >= 2 &&
            _numSignaturesRequired_per_multiSignTx <= _owners.length,
            "Invalid number of required signatures");

    for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];

            require(owner != address(0), "Invalid owner");
            require(!isOwner[owner], "The owner already exists");

            owners.push(owner);
            isOwner[owner] = true;

            emit OwnershipTransferred(address(0), owner);
        }

    numSignaturesRequired = _numSignaturesRequired_per_multiSignTx;
  }

  /**
   * @dev Submit multi-sign transaction 
   */
  function submitMulSigTx(
      uint32 _txCode,
      address _from,
      address _to,
      uint256 _value,
      uint256 _vestingAmount,
      uint32 _vestingStartDay,
      uint32 _vestingDuration,
      uint32 _vestingCliffDuration,
      uint32 _vestingInterval,
      bool _isRevocableVesting
  ) public onlyOwner returns (bool){
      require(_txCode <= 3, "Transaction code does not exist");
      uint txIndex = multiSignTxs.length;

      // Audit multi sign transaction
      if(_txCode != 2){
        if(_txCode == 0 || _txCode == 3){
          _from = 0x0000000000000000000000000000000000000000;
        }
        if(_txCode == 1 ||_txCode == 3){
          _value = 0;
        }
        _vestingAmount = 0;
        _vestingStartDay = 0;
        _vestingDuration = 0;
        _vestingCliffDuration = 0;
        _vestingInterval = 0;
        _isRevocableVesting = false;
      }else{
          // Submiters can only grant their token
          require(_fundsAreAvailableOn(msg.sender, _value, today()), "Fund are unavailable");
          _from = msg.sender;
      }

      multiSignTxs.push(
          multiSignTransaction({
              txCode: _txCode,
              from: _from,
              to: _to,
              value: _value,
              vestingAmount: _vestingAmount,
              vestingStartDay: _vestingStartDay,
              vestingDuration: _vestingDuration,
              vestingCliffDuration: _vestingCliffDuration,
              vestingInterval: _vestingInterval,
              isRevocableVesting: _isRevocableVesting,
            
              creationTime: block.timestamp,
              executed: false,
              numSignatures: 0
          })
      );

      emit SubmitMultiSignTransaction(msg.sender, txIndex, _txCode);

      return true;
  }

  /**
   * @dev Sign a submitted transaction
   */
  function signMulSigTx(uint _txIndex)
      public
      onlyOwner
      multiSignTx_exists(_txIndex)
      multiSignTx_have_not_executed(_txIndex)
      i_have_not_signed(_txIndex)
      is_time_out(_txIndex)
      returns (bool)
  {
      multiSignTransaction storage multiSignTx = multiSignTxs[_txIndex];
      multiSignTx.numSignatures = multiSignTx.numSignatures.add(1);
      isSigned[_txIndex][msg.sender] = true;
      emit SignMultiSignTx(msg.sender, _txIndex);
      return true;
  }

  /**
   * @dev Revoke a signature
   */
  function revokeSignature(uint _txIndex)
      public
      onlyOwner
      multiSignTx_exists(_txIndex)
      multiSignTx_have_not_executed(_txIndex)
      i_have_signed(_txIndex)
      is_time_out(_txIndex)
      returns (bool)
  {
      multiSignTransaction storage multiSignTx = multiSignTxs[_txIndex];
      multiSignTx.numSignatures = multiSignTx.numSignatures.sub(1);
      isSigned[_txIndex][msg.sender] = false;
      emit RevokeSignature(msg.sender, _txIndex);
      return true;
  }

  /**
   * @dev Return total existing multi-sign transactions
   */
  function getMulSigTxCnt() public view returns (uint totalMulSigTxs) {
      return (multiSignTxs.length);
  }

  /**
   * @dev Return number of signature required
   */
  function getNumOfSignatureRequired() public view returns (uint256) {
      return numSignaturesRequired;
  }

  /**
   * @dev Return detail of a multi-sign transaction
   */
  function getMulSigTxByIndex(uint _txIndex)
      public
      view
      returns (
          uint32 txCode,
          address from,
          address to,
          uint256 value,

          uint256 vestingAmount,
          uint32 vestingStartDay,
          uint32 vestingDuration,
          uint32 vestingCliffDuration,
          uint32 vestingInterval,
          bool isRevocableVesting,

          uint256 creationTime,
          bool executed,
          uint256 numSignatures
      )
  {
      require(_txIndex < multiSignTxs.length, "Transaction does not exist");
      multiSignTransaction storage multiSignTx = multiSignTxs[_txIndex];
      
      return (
          multiSignTx.txCode,
          multiSignTx.from,
          multiSignTx.to,
          multiSignTx.value,

          multiSignTx.vestingAmount,
          multiSignTx.vestingStartDay,
          multiSignTx.vestingDuration,
          multiSignTx.vestingCliffDuration,
          multiSignTx.vestingInterval,
          multiSignTx.isRevocableVesting,

          multiSignTx.creationTime,
          multiSignTx.executed,
          multiSignTx.numSignatures
      );
  }

  /**
   * @dev Execute a multi-sign transaction
   */
  function executeMulSigTx(uint _txIndex)
      public
      onlyOwner
      multiSignTx_exists(_txIndex)
      multiSignTx_have_not_executed(_txIndex)
      is_time_out(_txIndex)
      returns (bool)
  {
      multiSignTransaction storage multiSignTx = multiSignTxs[_txIndex];

      require(
        multiSignTx.numSignatures >= numSignaturesRequired,
        "The number of signatures is not enough to execute this transaction"
      );

      multiSignTx.executed = true;

      // Execute mint transaction
      if(multiSignTx.txCode == 0){
        _mint(multiSignTx.to, multiSignTx.value);
      }

      // Execute transfer ownership transaction
      else if(multiSignTx.txCode == 1){
        _transferOwnership(multiSignTx.from, multiSignTx.to);
      }

      // Execute grant vesting transaction
      else if(multiSignTx.txCode == 2){
        _grantVesting(
          multiSignTx.from, // grantor
          multiSignTx.to, // beneficiary
          multiSignTx.value, // total amount
          multiSignTx.vestingAmount,
          multiSignTx.vestingStartDay,
          multiSignTx.vestingDuration,
          multiSignTx.vestingCliffDuration,
          multiSignTx.vestingInterval,
          multiSignTx.isRevocableVesting);
      }

      // Execute revoke grant transaction
      else if (multiSignTx.txCode == 3){
        _revokeGrant(multiSignTx.to);
      }
      // default case
      else{
        return false;
      }

      emit ExecuteMultiSignTx(msg.sender, _txIndex);
      return true;
  }

  /**
   * @dev Returns the active bep token owners.
   * getCode = true: return active owners
   * getcode = false: return revoked owners
   */
  function getOwners(bool _getCode) public view returns (uint32 owners_cnt, address[] memory list_owners) {
    owners_cnt = 0;
    list_owners = new address[](owners.length);

    for (uint i = 0; i < owners.length; i++) {
            address owner = owners[i];
            if(isOwner[owner]==_getCode){
                list_owners[owners_cnt] = owner;
                owners_cnt += 1;
        }
    }

    return (owners_cnt, list_owners);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   */
  function _transferOwnership(address oldOwner, address newOwner) internal returns (bool){
    require(newOwner != address(0), "Invalid owner");

    // Check if source address is not an owner
    require(isOwner[oldOwner], "Source address is not an Owner");

    // Check if destination address is an owner/revoked owner
    for(uint i = 0; i < owners.length; i++) {
        // Check if address is unique
        require(owners[i] != newOwner, "Destination address is already an owner/revoked owner");
    }

    // Revoking the signatures of the revoked owner on valid transaction
    for(uint j = 0; j < multiSignTxs.length; j++) {
        // Check if valid transaction which the revoked owner has signed
        if(
          (multiSignTxs[j].executed == false) 
          && ((block.timestamp - multiSignTxs[j].creationTime) <= MULTISIGN_TX_TIMEOUT)
          && (isSigned[j][oldOwner] == true)
          ){
              // Revoke signature of revoked owner
              multiSignTxs[j].numSignatures = multiSignTxs[j].numSignatures.sub(1);
              isSigned[j][oldOwner] = false;
              emit RevokeSignature(oldOwner, j);
        }
    }

    // Update ownership
    isOwner[oldOwner] = false;
    isOwner[newOwner] = true;

    owners.push(newOwner);
    emit OwnershipTransferred(oldOwner, newOwner);

    return true;
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
  * @dev Returns max token can be mint.
  */
  function maxTotalSupply() external view returns (uint256) {
    return _maxTotalSupply;
  }

  /**
   * @dev See {BEP20-balanceOf}.
   */
  function balanceOf(address account) external view returns (uint256) {
    return _balances[account];
  }

  /**
   * @dev This one-time operation permanently establishes a vesting schedule in the given account.
   *
   * @param vestingLocation = Account into which to store the vesting schedule.
   * @param cliffDuration = Duration of the cliff, with respect to the grant start day, in days.
   * @param duration = Duration of the vesting schedule, with respect to the grant start day, in days.
   * @param interval = Number of days between vesting increases.
   * @param isRevocable = True if the grant can be revoked (i.e. was a gift) or false if it cannot
   *   be revoked (i.e. tokens were purchased).
   */
  function _setVestingSchedule(
      address vestingLocation,
      uint32 cliffDuration, uint32 duration, uint32 interval,
      bool isRevocable) internal returns (bool) {

      // Create and populate a vesting schedule.
      _vestingSchedules[vestingLocation] = vestingSchedule(
          true/*isValid*/,
          isRevocable,
          cliffDuration, duration, interval
      );

      // Emit the event and return success.
      emit VestingScheduleCreated(
          vestingLocation,
          cliffDuration, duration, interval,
          isRevocable);
      return true;
  }

  function _hasVestingSchedule(address account) internal view returns (bool) {
      return _vestingSchedules[account].isValid;
  }

  /**
   * @dev Immediately grants tokens to an account, referencing a vesting schedule which may be
   * stored in the same account (individual/one-off) or in a different account (shared/uniform).
   *
   * @param beneficiary = Address to which tokens will be granted.
   * @param totalAmount = Total number of tokens to deposit into the account.
   * @param vestingAmount = Out of totalAmount, the number of tokens subject to vesting.
   * @param startDay = Start day of the grant's vesting schedule, in days since the UNIX epoch
   *   (start of day). The startDay may be given as a date in the future or in the past, going as far
   *   back as year 2000.
   * @param vestingLocation = Account where the vesting schedule is held (must already exist).
   * @param grantor = Account which performed the grant. Also the account from where the granted
   *   funds will be withdrawn.
   */
  function _grantVestingTokens(
      address beneficiary,
      uint256 totalAmount,
      uint256 vestingAmount,
      uint32 startDay,
      address vestingLocation,
      address grantor
  )
  internal returns (bool)
  {
      // Make sure the vesting schedule we are about to use is valid.
      require(_hasVestingSchedule(vestingLocation), "No such vesting schedule");

      // Transfer the total number of tokens from grantor into the account's holdings.
      _transfer(grantor, beneficiary, totalAmount);

      // Create and populate a token grant, referencing vesting schedule.
      _tokenGrants[beneficiary] = tokenGrant(
          true/*isExisting*/,
          false/*wasRevoked*/,
          startDay,
          vestingAmount,
          vestingLocation, /* The wallet address where the vesting schedule is kept. */
          grantor,             /* The account that performed the grant (where revoked funds would be sent) */
          0 /* RevokedDay = 0 */
      );

      // Emit the event and return success.
      emit VestingTokensGranted(beneficiary, vestingAmount, startDay, vestingLocation, grantor);
      return true;
  }

  /**
   * @dev Immediately grants tokens to an address, including a portion that will vest over time
   * according to a set vesting schedule. The overall duration and cliff duration of the grant must
   * be an even multiple of the vesting interval.
   *
   * @param beneficiary = Address to which tokens will be granted.
   * @param totalAmount = Total number of tokens to deposit into the account.
   * @param vestingAmount = Out of totalAmount, the number of tokens subject to vesting.
   * @param startDay = Start day of the grant's vesting schedule, in days since the UNIX epoch
   *   (start of day). The startDay may be given as a date in the future or in the past, going as far
   *   back as year 2000.
   * @param duration = Duration of the vesting schedule, with respect to the grant start day, in days.
   * @param cliffDuration = Duration of the cliff, with respect to the grant start day, in days.
   * @param interval = Number of days between vesting increases.
   * @param isRevocable = True if the grant can be revoked (i.e. was a gift) or false if it cannot
   *   be revoked (i.e. tokens were purchased).
   */
  function _grantVesting(
      address grantor,
      address beneficiary,
      uint256 totalAmount,
      uint256 vestingAmount,
      uint32 startDay,
      uint32 duration,
      uint32 cliffDuration,
      uint32 interval,
      bool isRevocable
  ) internal onlyOwner returns (bool) {
      // Make sure no prior vesting schedule has been set.
      require(!_tokenGrants[beneficiary].isExisting, "Grant already exists");

      // Check for a valid vesting schedule given (disallow absurd values to reject likely bad input).
      require(
          (interval >= 1) 
          && (duration >= (interval + cliffDuration)) 
          && (duration <= TEN_YEARS_DAYS),
          "Invalid vesting schedule"
      );

      // Make sure the duration values are in harmony with interval (both should be an exact multiple of interval).
      require(
          (duration % interval == 0) 
          && (cliffDuration % interval == 0),
          "Invalid cliff/duration for interval"
      );

      // Check for valid vestingAmount
      require(
          (vestingAmount > 0) 
          && (vestingAmount <= totalAmount)
          && (startDay >= today()) 
          && (startDay < JAN_1_3000_DAYS),
          "Invalid vesting params");

      // The vesting schedule is unique to this wallet and so will be stored here,
      _setVestingSchedule(beneficiary, cliffDuration, duration, interval, isRevocable);

      // Issue grantor tokens to the beneficiary, using beneficiary's own vesting schedule.
      _grantVestingTokens(beneficiary, totalAmount, vestingAmount, startDay, beneficiary, grantor);

      return true;
  }

  /**
   * @dev returns the day number of the current day, in days since the UNIX epoch.
   * From 0:0:0 GMT of the day
   */
  function today() public view returns (uint32 dayNumber) {
      return uint32(block.timestamp / SECONDS_PER_DAY);
  }

  function _effectiveDay(uint32 onDayOrToday) internal view returns (uint32 dayNumber) {
      return onDayOrToday == 0 ? today() : onDayOrToday;
  }

  /**
   * @dev Determines the amount of tokens that have not vested in the given account.
   *
   * The math is: not vested amount = vesting amount * (end date - on date)/(end date - start date)
   *
   * @param grantHolder = The account to check.
   * @param onDayOrToday = The day to check for, in days since the UNIX epoch. Can pass
   *   the special value 0 to indicate today.
   */
  function _getNotVestedAmount(address grantHolder, uint32 onDayOrToday) internal view returns (uint256 amountNotVested) {
      tokenGrant storage grant = _tokenGrants[grantHolder];
      vestingSchedule storage vesting = _vestingSchedules[grant.vestingLocation];
      uint32 onDay = _effectiveDay(onDayOrToday);
      uint32 daysVested;

      // Grant is existing and was not revoke
      if(grant.isExisting && !grant.wasRevoked)
      {
        // onDay is before the vesting cliff
        // then the full amount is not vested.
        if (onDay < (grant.startDay + vesting.cliffDuration))
        {
            // None are vested (all are not vested)
            return grant.amount;
        } 
        // onDay is after the vesting durarion
        // then the not vested amount is zero (all are vested).
        else if (onDay > (grant.startDay + vesting.duration))
        {
            // All are vested (none are not vested)
            return uint256(0);
        } 
        // Otherwise, the is in the vesting process, a fractional amount is vested.
        // (grant.startDay + vesting.cliffDuration) <= onDay <= (grant.startDay + vesting.duration)
        else
        {
            // Compute the exact number of days vested.
            daysVested = onDay - grant.startDay - vesting.cliffDuration;
        }
      }
      // Grant is existing but was revoke or Grant is not existing
      else
      {
        // No more vesting or It is not existing
        return uint256(0);
      }
          
     // Adjust result rounding down to take into consideration the interval.
     uint32 effectiveDaysVested = (daysVested / vesting.interval) * vesting.interval;

     // Compute the fraction vested from schedule using 224.32 fixed point math for date range ratio.
     // Note: This is safe in 256-bit math because max value of X billion tokens = X*10^27 wei, and
     // typical token amounts can fit into 90 bits. Scaling using a 32 bits value results in only 125
     // bits before reducing back to 90 bits by dividing. There is plenty of room left, even for token
     // amounts many orders of magnitude greater than mere billions.
     uint256 vested = grant.amount.mul(effectiveDaysVested).div(vesting.duration - vesting.cliffDuration);
     return grant.amount.sub(vested);
  }

  /**
   * @dev Computes the amount of funds in the given account which are available for use as of
   * the given day. If there's no vesting schedule then 0 tokens are considered to be vested and
   * this just returns the full account balance.
   *
   * The math is: available amount = total funds - notVestedAmount.
   *
   * @param grantHolder = The account to check.
   * @param onDay = The day to check for, in days since the UNIX epoch.
   */
  function _getAvailableAmount(address grantHolder, uint32 onDay) internal view returns (uint256 amountAvailable) {
      uint256 totalTokens = _balances[grantHolder];
      return totalTokens.sub(_getNotVestedAmount(grantHolder, onDay));
  }

  /**
   * @dev returns all information about the grant's vesting as of the given day
   * for the given account.
   *
   * @param grantHolder = The address to do this for.
   * @param onDayOrToday = The day to check for, in days since the UNIX epoch. Can pass
   *   the special value 0 to indicate today.
   * @return = A tuple with the following values:
   *   amountVested = the amount out of vestingAmount that is vested
   *   amountNotVested = the amount that is vested (equal to vestingAmount - vestedAmount)
   *   amountOfGrant = the amount of tokens subject to vesting.
   *   vestStartDay = starting day of the grant (in days since the UNIX epoch).
   *   vestDuration = grant duration in days.
   *   cliffDuration = duration of the cliff.
   *   vestIntervalDays = number of days between vesting periods.
   *   isExisting = true if the vesting schedule is currently existing.
   *   wasRevoked = true if the vesting schedule was revoked.
   */
  function vestingForAccountAsOf(
      address grantHolder,
      uint32 onDayOrToday
  )
  public
  view
  returns (
      uint256 amountVested,
      uint256 amountNotVested,
      uint256 amountOfGrant,
      uint32 vestStartDay,
      uint32 vestDuration,
      uint32 cliffDuration,
      uint32 vestIntervalDays,
      bool isExisting,
      bool wasRevoked,
      uint32 revokedDay
  )
  {
      tokenGrant storage grant = _tokenGrants[grantHolder];
      vestingSchedule storage vesting = _vestingSchedules[grant.vestingLocation];
      uint256 notVestedAmount = _getNotVestedAmount(grantHolder, onDayOrToday);
      uint256 grantAmount = grant.amount;

      if(grant.isExisting && grant.wasRevoked)
      {
        if (grant.revokedDay < (grant.startDay + vesting.cliffDuration)){
            notVestedAmount = grant.amount;
        }
        else if (grant.revokedDay > (grant.startDay + vesting.duration)){
            notVestedAmount = uint256(0);
        }
        else{
            uint32 daysVested = grant.revokedDay - grant.startDay - vesting.cliffDuration;
            uint32 effectiveDaysVested = (daysVested / vesting.interval) * vesting.interval;

            uint256 vested = grant.amount.mul(effectiveDaysVested).div(vesting.duration - vesting.cliffDuration);
            notVestedAmount = grant.amount.sub(vested);
        }
      }

      return (
      grantAmount.sub(notVestedAmount),
      notVestedAmount,
      grantAmount,
      grant.startDay,
      vesting.duration,
      vesting.cliffDuration,
      vesting.interval,
      grant.isExisting,
      grant.wasRevoked,
      grant.revokedDay
      );
  }

  /**
   * @dev returns true if the account has sufficient funds available to cover the given amount,
   *   including consideration for vesting tokens.
   *
   * @param account = The account to check.
   * @param amount = The required amount of vested funds.
   * @param onDay = The day to check for, in days since the UNIX epoch.
   */
  function _fundsAreAvailableOn(address account, uint256 amount, uint32 onDay) internal view returns (bool) {
      return (amount <= _getAvailableAmount(account, onDay));
  }

  /**
   * @dev If the account has a revocable grant, this forces the grant to end based on computing
   * the amount vested up to the given date. All tokens that would no longer vest are returned
   * to the account of the original grantor.
   *
   * @param grantHolder = Address to which tokens will be granted.
   */
  function _revokeGrant(address grantHolder) internal onlyOwner returns (bool) {
      tokenGrant storage grant = _tokenGrants[grantHolder];
      vestingSchedule storage vesting = _vestingSchedules[grant.vestingLocation];
      uint256 notVestedAmount;

      // Make sure a vesting schedule has previously been set.
      require(grant.isExisting, "No existing vesting schedule");
      // Make sure it's revocable.
      require(vesting.isRevocable, "Irrevocable");
      // Make sure it's NOT revoked
      require(!grant.wasRevoked, "It's revoked already");
        
      uint32 onDay = _effectiveDay(0);
      // Fail on likely erroneous input.
      require((onDay <= (grant.startDay + vesting.duration)), "No effect");

      notVestedAmount = _getNotVestedAmount(grantHolder, onDay);

      // take back not-vested tokens from grantHolder.
      _transfer(grantHolder, grant.grantor, notVestedAmount);

      // Kill the grant by updating wasRevoked
      _tokenGrants[grantHolder].wasRevoked = true;
      _tokenGrants[grantHolder].revokedDay = onDay;

      emit GrantRevoked(grantHolder, onDay);
      /* Emits the GrantRevoked event. */
      return true;
  }
  
  /**
   * @dev Returns the available amount of a grantHolder.
   */
  function getAvailableAmount(address grantHolder, uint32 onDayOrToday) external view returns (uint256){
      return _getAvailableAmount(grantHolder, onDayOrToday);
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
    require(_fundsAreAvailableOn(msg.sender, amount, today()), "Fund are unavailable");
    _transfer(msg.sender, recipient, amount);
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
    require(_fundsAreAvailableOn(msg.sender, amount, today()), "Fund are unavailable");
    _approve(msg.sender, spender, amount);
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
    require(_fundsAreAvailableOn(sender, amount, today()), "Fund are unavailable");
    _transfer(sender, recipient, amount);
    _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "BEP20: transfer amount exceeds allowance"));
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
    require(_fundsAreAvailableOn(msg.sender, _allowances[msg.sender][spender] + addedValue, today()), "Fund are unavailable");
    _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
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
    _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }

  /**
   * @dev Burn `amount` tokens and decreasing the total supply.
   */
  function burn(uint256 amount) public returns (bool) {
    require(_fundsAreAvailableOn(msg.sender, amount, today()), "Fund are unavailable");
    _burn(msg.sender, amount);
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
  function _mint(address account, uint256 amount) internal returns (bool){
    require(account != address(0), "BEP20: mint to the zero address");
    require(_totalSupply.add(amount) <= _maxTotalSupply,"Max Supply Exceeds");

    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
    return true;
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
}