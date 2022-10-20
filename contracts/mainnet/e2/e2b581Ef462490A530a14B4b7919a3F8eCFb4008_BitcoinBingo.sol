// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract BitcoinBingo is Ownable {
  AggregatorV3Interface public priceFeed;
  IERC20 public prizeToken;

  uint256 public prizeFee;
  uint256 public feeDecimal;
  uint8 public bingoDecimal;
  uint256 public bufferSeconds;
  uint256 public intervalLockSeconds; // interval in seconds till Friday midnight
  uint256 public intervalCloseSeconds; // interval in seconds till Sunday midnight

  address public operatorAddress; // address of the operator

  uint256 public currentEpoch; // current epoch for prediction round
  uint256 public oracleLatestRoundId; // converted from uint80 (Chainlink)
  uint256 public oracleUpdateAllowance = 300; // seconds

  uint256 public companyPrize = 1000_00_0000_0000_0000_0000; // 1000 * 10e18
  uint256 public treasuryAmount;

  address public accumulator;
  address public prizeDepositer;


  struct Round {
    uint256 epoch;
    uint256 startTimestamp;
    uint256 lockTimestamp;
    uint256 closeTimestamp;
    int256 closePrice;
    uint256 closeOracleId;
    uint256 totalAmount;
    uint256 rewardAmount;
    bool bingoLocked; // default false
    bool oracleCalled; // default false
    bool prizeDeposited;
  }

  struct ManagerObj {
    uint256 index;
    bool exist;
  }

  // epoch => Round
  mapping(uint256 => Round) public rounds;
  // account => epoch => number of bingo
  mapping(address => mapping(uint256 => uint8)) public userRounds;
  mapping(address => mapping(uint256 => bool)) public userFreeRounds;
  mapping(address => mapping(uint256 => uint8)) public userExtraFreeRounds;
  // epoch => price => accounts
  mapping(uint256 => mapping(int256 => address[])) public priceRounds;
  
  mapping (address => ManagerObj) private _manageAccess;
  address[] private _managerLists;

  // number of extra bingo => USDC
  mapping (uint8 => uint256) public extraStrategies;
  uint8[] public availableExtraBingos;

  event StartRound(uint256 indexed epoch);
  event EndRound(uint256 indexed epoch);
  event LockRound(uint256 indexed epoch, uint256 indexed roundId, int256 price);
  event BingoEvt(address user, uint256 indexed epoch, uint256 indexed roundId, int256 price);

  modifier onlyManager() {
    require(msg.sender == owner() || _manageAccess[msg.sender].exist, "!manager");
    _;
  }

  modifier onlyOperator() {
    require(msg.sender == operatorAddress, "Not operator");
    _;
  }

  modifier onlyAccumulator() {
    require(msg.sender == accumulator, "Not operator");
    _;
  }

  modifier onlyPrizeDepositer() {
    require(msg.sender == prizeDepositer, "Not operator");
    _;
  }

  modifier notContract() {
    require(!_isContract(msg.sender), "Contract not allowed");
    require(msg.sender == tx.origin, "Proxy contract not allowed");
    _;
  }

  constructor(address _priceFeed, address _prizeToken) {
    priceFeed = AggregatorV3Interface(_priceFeed);
    prizeToken = IERC20(_prizeToken);

    prizeFee = 500;
    feeDecimal = 1000;
    bingoDecimal = 6;
    
    bufferSeconds = 30;
    intervalLockSeconds = 432000;
    intervalCloseSeconds = 604800;

    operatorAddress = msg.sender;
    accumulator = 0x75c6D683A7d45bbb0A31F2249c12a11fA26bE9eA;
    prizeDepositer = 0x320e75Db7D2a624bd9DEa117C3092D69F20D8988;
    _manageAccess[0x320e75Db7D2a624bd9DEa117C3092D69F20D8988] = ManagerObj(0, true);
    _managerLists.push(0x320e75Db7D2a624bd9DEa117C3092D69F20D8988);

    availableExtraBingos.push(1);
    availableExtraBingos.push(5);
    extraStrategies[1] = 1_00_0000_0000_0000_0000;
    extraStrategies[5] = 3_00_0000_0000_0000_0000;

    _startRound();
  }

  function bingoBTC(uint256 epoch, int256[] memory prices, uint8 index) external notContract {
    require(epoch == currentEpoch, "Bet is too early/late");
    require(_bettable(epoch), "Round not bettable");

    uint256 bingoBetAmount = extraStrategies[index];
    uint256 bingoLen = prices.length;
    require(bingoLen == index, "Wrong prices");
    require(bingoBetAmount > 0, "No extra free bingo");

    require(IERC20(prizeToken).allowance(msg.sender, address(this)) >= bingoBetAmount, 'Btcbingo: Bingo token is not approved');
    IERC20(prizeToken).transferFrom(msg.sender, address(this), bingoBetAmount);
    Round storage round = rounds[epoch];
    round.totalAmount = round.totalAmount + bingoBetAmount;

    userRounds[msg.sender][epoch] += uint8(bingoLen);
    
    for (uint256 i=0; i<bingoLen; i++) {
      int256 price = prices[i];
      priceRounds[epoch][price].push(msg.sender);
      emit BingoEvt(msg.sender, epoch, userRounds[msg.sender][epoch]-i, price);
    }
  }

  function bingoBTCViaOperator(uint256 epoch, int256 price, address account) external onlyOperator {
    require(epoch == currentEpoch, "Bet is too early/late");
    require(_bettable(epoch), "Round not bettable");
    
    require(userFreeRounds[account][epoch] == false, "Btcbingo: You can do only once bingo");

    userRounds[msg.sender][epoch] += 1;
    userFreeRounds[account][epoch] = true;

    priceRounds[epoch][price].push(account);

    emit BingoEvt(account, epoch, 0, price);
  }

  function bingoBTCViaOperatorExtra(uint256 epoch, int256 price, address account) external onlyOperator {
    require(epoch == currentEpoch, "Bet is too early/late");
    require(_bettable(epoch), "Round not bettable");
    
    require(userExtraFreeRounds[account][epoch] < 2, "Btcbingo: You can do only once bingo");

    userRounds[msg.sender][epoch] += 1;
    userExtraFreeRounds[account][epoch] += 1;

    priceRounds[epoch][price].push(account);

    emit BingoEvt(account, epoch, 0, price);
  }

  function executeRound() external onlyOperator {
    // CurrentEpoch refers to previous round (n-1)
    require(rounds[currentEpoch].lockTimestamp != 0, "Can only end round after round has locked");
    require(block.timestamp >= rounds[currentEpoch].closeTimestamp, "Can only end round after closeTimestamp");
    require(
      block.timestamp <= rounds[currentEpoch].closeTimestamp + bufferSeconds,
      "Can only end round within bufferSeconds"
    );

    Round storage round = rounds[currentEpoch];
    round.closeTimestamp = block.timestamp;
    emit EndRound(currentEpoch);

    uint256 prizeBal = IERC20(prizeToken).balanceOf(address(this));
    if (prizeBal > treasuryAmount) {
      prizeBal = treasuryAmount;
    }
    IERC20(prizeToken).transfer(accumulator, prizeBal);
    treasuryAmount = treasuryAmount - prizeBal;

    uint256 winnerLen = priceRounds[currentEpoch][round.closePrice].length;
    if (winnerLen > 0) {
      uint256 rewardAmount = round.rewardAmount / winnerLen;
      for (uint256 i=0; i<winnerLen; i++) {
        address acc = priceRounds[currentEpoch][round.closePrice][i];
        uint256 prizeBal2 = IERC20(prizeToken).balanceOf(address(this));
        if (prizeBal2 >= rewardAmount) {
          IERC20(prizeToken).transfer(acc, rewardAmount);
        }
      }
    }

    // Increment currentEpoch to current round (n)
    currentEpoch = currentEpoch + 1;
    _startRound();
  }

  function forceExecuteRound(uint256 _intervalLockSeconds, uint256 _intervalCloseSeconds) external onlyOperator {
    int256 currentPrice = 0;
    Round storage round = rounds[currentEpoch];
    round.closeTimestamp = block.timestamp;
    round.closePrice = currentPrice;
    round.closeOracleId = 0;
    round.oracleCalled = false;

    round.rewardAmount = 0;
    treasuryAmount = treasuryAmount + round.totalAmount - round.rewardAmount;

    emit EndRound(currentEpoch);

    currentEpoch = currentEpoch + 1;

    Round storage cround = rounds[currentEpoch];
    cround.startTimestamp = block.timestamp;
    cround.lockTimestamp = block.timestamp + _intervalLockSeconds;
    cround.closeTimestamp = block.timestamp + _intervalCloseSeconds;
    cround.epoch = currentEpoch;
    cround.totalAmount = companyPrize;

    emit StartRound(currentEpoch);
  }

  /**
    * @notice Lock running round
    * @dev Callable by operator
    */
  function genesisLockRound() external onlyOperator {
    (uint80 currentRoundId, int256 currentPrice) = _getPriceFromOracle();

    oracleLatestRoundId = uint256(currentRoundId);

    require(rounds[currentEpoch].startTimestamp != 0, "Can only lock round after round has started");
    require(block.timestamp >= rounds[currentEpoch].lockTimestamp, "Can only lock round after lockTimestamp");
    require(
      block.timestamp <= rounds[currentEpoch].lockTimestamp + bufferSeconds,
      "Can only lock round within bufferSeconds"
    );

    currentPrice = currentPrice / (int256(10) ** bingoDecimal) * (int256(10) ** bingoDecimal);
    
    Round storage round = rounds[currentEpoch];
    round.lockTimestamp = block.timestamp;
    round.bingoLocked = true;
    round.closePrice = currentPrice;
    round.closeOracleId = currentRoundId;
    round.oracleCalled = true;

    if (priceRounds[currentEpoch][currentPrice].length > 0) {
      round.rewardAmount = companyPrize + (round.totalAmount - companyPrize) * prizeFee / feeDecimal;
      treasuryAmount = treasuryAmount + round.totalAmount - round.rewardAmount;
    }
    else {
      round.rewardAmount = 0;
      treasuryAmount = treasuryAmount + round.totalAmount - companyPrize;
    }

    emit LockRound(currentEpoch, currentRoundId, currentPrice);
  }

  function depoistPrizeFromSupplyer() public onlyOperator {
    require(IERC20(prizeToken).allowance(prizeDepositer, address(this)) >= companyPrize, 'Btcbingo: Prize token is not approved');

    Round storage round = rounds[currentEpoch];
    require(round.prizeDeposited == false, 'Btcbingo: Prize token is deposited');

    IERC20(prizeToken).transferFrom(prizeDepositer, address(this), companyPrize);
    round.prizeDeposited = true;
  }

  function depoistPrize() public onlyPrizeDepositer {
    require(IERC20(prizeToken).allowance(msg.sender, address(this)) >= companyPrize, 'Btcbingo: Prize token is not approved');
    IERC20(prizeToken).transferFrom(msg.sender, address(this), companyPrize);
  }

  function withdrawTreasuryFee(uint256 amount) public onlyAccumulator {
    require(treasuryAmount >= amount, "Btcbingo: Wrong amount");
    require(IERC20(prizeToken).balanceOf(address(this)) >= amount, "Btcbingo: Not enough prize token balance");

    IERC20(prizeToken).transfer(msg.sender, amount);
    treasuryAmount = treasuryAmount - amount;
  }

  function recoverPrizeToken() public onlyOwner {
    IERC20(prizeToken).transfer(msg.sender, IERC20(prizeToken).balanceOf(address(this)));
  }

  function getAllExtraBingos() public view returns(uint8[] memory) {
    return availableExtraBingos;
  }


  function setManager(address usraddress, bool access) public onlyOwner {
    if (access == true) {
      if ( ! _manageAccess[usraddress].exist) {
        uint256 newId = _managerLists.length;
        _manageAccess[usraddress] = ManagerObj(newId, true);
        _managerLists.push(usraddress);
      }
    }
    else {
      if (_manageAccess[usraddress].exist) {
        address lastObj = _managerLists[_managerLists.length - 1];
        _managerLists[_manageAccess[usraddress].index] = _managerLists[_manageAccess[lastObj].index];
        _managerLists.pop();
        delete _manageAccess[usraddress];
      }
    }
  }

  function setPriceFeed(address _priceFeed) public onlyManager {
    priceFeed = AggregatorV3Interface(_priceFeed);
  }
  function setPrizeToken(address _prizeToken) public onlyManager {
    prizeToken = IERC20(_prizeToken);
  }
  function setTreasuryFee(uint256 _prizeFee, uint256 _feeDecimal) public onlyManager {
    prizeFee = _prizeFee;
    feeDecimal = _feeDecimal;
  }
  function setBingoDecimal(uint8 _bingoDecimal) public onlyManager {
    bingoDecimal = _bingoDecimal;
  }
  function setBufferSeconds(uint256 _bufferSeconds) public onlyManager {
    bufferSeconds = _bufferSeconds;
  }
  function setIntervalLockSeconds(uint256 _intervalLockSeconds) public onlyManager {
    intervalLockSeconds = _intervalLockSeconds;
  }
  function setIntervalCloseSeconds(uint256 _intervalCloseSeconds) public onlyManager {
    require(_intervalCloseSeconds >= intervalLockSeconds, "Btcbingo: Wrong close timestamp");
    intervalCloseSeconds = _intervalCloseSeconds;
  }
  function setCompanyPrize(uint256 _companyPrize) public onlyManager {
    Round storage round = rounds[currentEpoch];
    round.totalAmount = round.totalAmount - companyPrize + _companyPrize;
    companyPrize = _companyPrize;
  }
  function setAccumulator(address _accumulator) public onlyManager {
    accumulator = _accumulator;
  }
  function setPrizeDepositer(address _prizeDepositer) public onlyManager {
    prizeDepositer = _prizeDepositer;
  }
  function changeExtraStrategy(uint8 index, uint256 amount) public onlyManager {
    require(extraStrategies[index] != 0, "Not Exist strategy");
    extraStrategies[index] = amount;
  }
  function addExtraStrategy(uint8 index, uint256 amount) public onlyManager {
    require(extraStrategies[index] == 0, "Already Exist strategy");
    extraStrategies[index] = amount;
    availableExtraBingos.push(index);
  }
  function removedExtraStrategy(uint8 index) public onlyManager {
    require(extraStrategies[index] != 0, "Not Exist strategy");
    uint256 last = availableExtraBingos.length - 1;
    for (uint i=0; i<=last; i++) {
      if (availableExtraBingos[i] == index) {
        availableExtraBingos[i] = availableExtraBingos[last];
        break;
      }
    }
    availableExtraBingos.pop();
    extraStrategies[index] = 0;
  }

  function _startRound() internal {
    Round storage cround = rounds[currentEpoch];
    cround.startTimestamp = block.timestamp;
    cround.lockTimestamp = block.timestamp + intervalLockSeconds;
    cround.closeTimestamp = block.timestamp + intervalCloseSeconds;
    cround.epoch = currentEpoch;
    cround.totalAmount = companyPrize;

    emit StartRound(currentEpoch);
  }

  /**
    * @notice Determine if a round is valid for receiving bets
    * Round must have started and locked
    * Current timestamp must be within startTimestamp and closeTimestamp
    */
  function _bettable(uint256 epoch) internal view returns (bool) {
    return
      rounds[epoch].startTimestamp != 0 &&
      rounds[epoch].lockTimestamp != 0 &&
      block.timestamp > rounds[epoch].startTimestamp &&
      block.timestamp < rounds[epoch].lockTimestamp;
  }

  /**
    * @notice Get latest recorded price from oracle
    * If it falls below allowed buffer or has not updated, it would be invalid.
    */
  function _getPriceFromOracle() internal view returns (uint80, int256) {
    uint256 leastAllowedTimestamp = block.timestamp + oracleUpdateAllowance;
    (uint80 roundId, int256 price, , uint256 timestamp, ) = priceFeed.latestRoundData();
    require(timestamp <= leastAllowedTimestamp, "Oracle update exceeded max timestamp allowance");
    require(
      uint256(roundId) > oracleLatestRoundId,
      "Oracle update roundId must be larger than oracleLatestRoundId"
    );
    return (roundId, price);
  }

  /**
    * @notice Returns true if `account` is a contract.
    * @param account: account address
    */
  function _isContract(address account) internal view returns (bool) {
    uint256 size;
    assembly {
      size := extcodesize(account)
    }
    return size > 0;
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
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}