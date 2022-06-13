//contracts/BinaryOption.sol
// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./interfaces/AggregatorV3Interface.sol";

contract BinaryOption is Ownable, Pausable, ReentrancyGuard {
  using SafeMath for uint256;
  using SafeERC20 for ERC20;

  ERC20 public immutable betToken;
  AggregatorV3Interface public oracle;
  bool public genesisLockOnce = false;
  bool public genesisStartOnce = false;

  address public adminAddress; // address of the admin
  address public operatorAddress; // address of the operator

  uint256 public bufferSeconds; // number of seconds for valid execution of a bet round
  uint256 public intervalSeconds; // interval in seconds for each round
  uint256 public lockInSeconds; // number of seconds before round locked

  uint256 public minBetAmount; // minimum betting amount (denominated in wei)
  uint256 public treasuryFee; // treasury rate (e.g. 200 = 2%, 150 = 1.50%)
  uint256 public treasuryAmount; // treasury amount that was not claimed

  uint256 public currentEpoch; // current epoch for bet round

  uint256 public oracleLatestRoundId; // converted from uint80 (Chainlink)
  uint256 public oracleUpdateAllowance; // seconds

  uint256 public constant MAX_TREASURY_FEE = 1000; // 10%

  mapping(uint256 => mapping(address => BetInfo)) public ledger;
  mapping(uint256 => Round) public rounds;
  mapping(address => uint256[]) public userRounds;

  enum Position {
    High,
    Low
  }

  struct Round {
    uint256 epoch;
    uint256 startTimestamp;
    uint256 lockTimestamp;
    uint256 closeTimestamp;
    int256 lockPrice;
    int256 closePrice;
    uint256 lockOracleId;
    uint256 closeOracleId;
    uint256 totalAmount;
    uint256 highAmount;
    uint256 lowAmount;
    uint256 rewardBaseCalAmount;
    uint256 rewardAmount;
    bool oracleCalled;
  }

  struct BetInfo {
    Position position;
    uint256 amount;
    bool claimed; // default false
  }

  /**
   * @notice Constructor
   * @param _oracleAddress: oracle address
   * @param _adminAddress: admin address
   * @param _operatorAddress: operator address
   * @param _intervalSeconds: number of time within an interval
   * @param _bufferSeconds: buffer of time for resolution of price
   * @param _minBetAmount: minimum bet amounts (in wei)
   * @param _oracleUpdateAllowance: oracle update allowance
   * @param _treasuryFee: treasury fee (1000 = 10%)
   * @param _lockInSeconds:
   */
  constructor(
    ERC20 _betToken,
    address _oracleAddress,
    address _adminAddress,
    address _operatorAddress,
    uint256 _intervalSeconds,
    uint256 _bufferSeconds,
    uint256 _minBetAmount,
    uint256 _oracleUpdateAllowance,
    uint256 _treasuryFee,
    uint256 _lockInSeconds
  ) {
    require(_treasuryFee <= MAX_TREASURY_FEE, "BinaryOption: Treasury fee too high");
    require(_bufferSeconds < _lockInSeconds, "BinaryOption: bufferSeconds must be lower than lockInSeconds");
    require(_lockInSeconds < _intervalSeconds, "BinaryOption: lockInSeconds must be lower than intervalSeconds");
    
    betToken = _betToken;
    oracle = AggregatorV3Interface(_oracleAddress);
    adminAddress = _adminAddress;
    operatorAddress = _operatorAddress;
    intervalSeconds = _intervalSeconds;
    bufferSeconds = _bufferSeconds;
    minBetAmount = _minBetAmount;
    oracleUpdateAllowance = _oracleUpdateAllowance;
    treasuryFee = _treasuryFee;
    lockInSeconds = _lockInSeconds;
  }

  event StartRound(uint256 indexed epoch);
  event LockRound(uint256 indexed epoch, uint256 indexed roundId, int256 price);
  event EndRound(uint256 indexed epoch, uint256 indexed roundId, int256 price);
  event BetLow(address indexed sender, uint256 indexed epoch, uint256 amount);
  event BetHigh(address indexed sender, uint256 indexed epoch, uint256 amount);
  event Claim(address indexed sender, uint256 indexed epoch, uint256 amount);
  event RewardsCalculated(
    uint256 indexed epoch,
    uint256 rewardBaseCalAmount,
    uint256 rewardAmount,
    uint256 treasuryAmount
  );

  event NewAdminAddress(address admin);
  event NewOperatorAddress(address operator);
  event NewBufferIntervalAndLockInSeconds(uint256 bufferSeconds, uint256 intervalSeconds, uint256 lockInSeconds);
  event NewMinBetAmount(uint256 indexed epoch, uint256 minBetAmount);
  event NewOracle(address oracle);
  event NewOracleUpdateAllowance(uint256 oracleUpdateAllowance);
  event NewTreasuryFee(uint256 indexed epoch, uint256 treasuryFee);

  event Pause(uint256 indexed epoch);
  event Unpause(uint256 indexed epoch);
  event TokenRecovery(address indexed token, uint256 amount);
  event TreasuryClaim(uint256 amount);

  modifier onlyAdmin() {
    require(msg.sender == adminAddress, "BinaryOption: not admin");
    _;
  }

  modifier onlyAdminOrOperator() {
    require(msg.sender == adminAddress || msg.sender == operatorAddress, "BinaryOption: not operator/admin");
    _;
  }

  modifier onlyOperator() {
    require(msg.sender == operatorAddress, "BinaryOption: not operator");
    _;
  }

  modifier notContract() {
    require(!_isContract(msg.sender), "BinaryOption: contract not allowed");
    require(msg.sender == tx.origin, "BinaryOption: proxy contract not allowed");
    _;
  }

  /**
   * @notice Bet Low position
   * @param _epoch: epoch
   * @param _amount: amount
   */
  function betLow(uint256 _epoch, uint256 _amount) external whenNotPaused nonReentrant notContract {
    require(_epoch == currentEpoch, "BinaryOption: Bet is too early/late");
    require(_bettable(_epoch), "BinaryOption: Round not bettable");
    require(_amount >= minBetAmount, "BinaryOption: Bet amount must be greater than minBetAmount");
    require(ledger[_epoch][msg.sender].amount == 0, "BinaryOption: Can only bet once per round");

    // Update round data
    uint256 preAmount = betToken.balanceOf(address(this));
    betToken.safeTransferFrom(msg.sender, address(this), _amount);
    uint256 postDeposit = betToken.balanceOf(address(this));
    uint256 actualAmount = postDeposit.sub(preAmount);
    Round storage round = rounds[_epoch];
    round.totalAmount = round.totalAmount + actualAmount;
    round.lowAmount = round.lowAmount + actualAmount;

    // Update user data
    BetInfo storage betInfo = ledger[_epoch][msg.sender];
    betInfo.position = Position.Low;
    betInfo.amount = actualAmount;
    userRounds[msg.sender].push(_epoch);

    emit BetLow(msg.sender, _epoch, actualAmount);
  }

  /**
   * @notice Bet High position
   * @param _epoch: epoch
   * @param _amount: amount
   */
  function betHigh(uint256 _epoch, uint256 _amount) external whenNotPaused nonReentrant notContract {
    require(_epoch == currentEpoch, "BinaryOption: Bet is too early/late");
    require(_bettable(_epoch), "BinaryOption: Round not bettable");
    require(_amount >= minBetAmount, "BinaryOption: Bet amount must be greater than minBetAmount");
    require(ledger[_epoch][msg.sender].amount == 0, "BinaryOption: Can only bet once per round");

    // Update round data
    uint256 preAmount = betToken.balanceOf(address(this));
    betToken.safeTransferFrom(msg.sender, address(this), _amount);
    uint256 postDeposit = betToken.balanceOf(address(this));
    uint256 actualAmount = postDeposit.sub(preAmount);
    Round storage round = rounds[_epoch];
    round.totalAmount = round.totalAmount + actualAmount;
    round.highAmount = round.highAmount + actualAmount;

    // Update user data
    BetInfo storage betInfo = ledger[_epoch][msg.sender];
    betInfo.position = Position.High;
    betInfo.amount = actualAmount;
    userRounds[msg.sender].push(_epoch);

    emit BetHigh(msg.sender, _epoch, actualAmount);
  }

  /**
   * @notice Claim reward for an array of epochs
   * @param epochs: array of epochs
   */
  function claim(uint256[] calldata epochs) external nonReentrant notContract {
    uint256 reward; // Initializes reward

    for (uint256 i = 0; i < epochs.length; i++) {
      require(rounds[epochs[i]].startTimestamp != 0, "BinaryOption: Round has not started");
      require(block.timestamp > rounds[epochs[i]].closeTimestamp + bufferSeconds, "BinaryOption: Round has not ended");

      uint256 addedReward = 0;

      // Round valid, claim rewards
      if (rounds[epochs[i]].oracleCalled) {
        require(claimable(epochs[i], msg.sender), "BinaryOption: Not eligible for claim");
        Round memory round = rounds[epochs[i]];
        addedReward = (ledger[epochs[i]][msg.sender].amount * round.rewardAmount) / round.rewardBaseCalAmount;
      }
      // Round invalid, refund bet amount
      else {
        require(refundable(epochs[i], msg.sender), "BinaryOption: Not eligible for refund");
        addedReward = ledger[epochs[i]][msg.sender].amount;
      }

      ledger[epochs[i]][msg.sender].claimed = true;
      reward += addedReward;

      emit Claim(msg.sender, epochs[i], addedReward);
    }

    if (reward > 0) {
      betToken.safeTransfer(address(msg.sender), reward);
    }
  }

  /**
   * @notice Set Oracle address
   * @dev Callable by admin
   */
  function setOracle(address _oracle) external whenPaused onlyAdmin {
    require(_oracle != address(0), "BinaryOption: Cannot be zero address");
    oracleLatestRoundId = 0;
    oracle = AggregatorV3Interface(_oracle);

    // Dummy check to make sure the interface implements this function properly
    oracle.latestRoundData();

    emit NewOracle(_oracle);
  }

  /**
   * @notice Set oracle update allowance
   * @dev Callable by admin
   */
  function setOracleUpdateAllowance(uint256 _oracleUpdateAllowance) external whenPaused onlyAdmin {
    oracleUpdateAllowance = _oracleUpdateAllowance;

    emit NewOracleUpdateAllowance(_oracleUpdateAllowance);
  }

  /**
   * @notice Determine if a round is valid for receiving bets
   * Round must have started and not locked yet
   * Current timestamp must be within startTimestamp and lockTimestamp
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
    (uint80 roundId, int256 price, , uint256 timestamp, ) = oracle.latestRoundData();
    require(timestamp <= leastAllowedTimestamp, "BinaryOption: Oracle update exceeded max timestamp allowance");
    require(
      uint256(roundId) > oracleLatestRoundId,
      "BinaryOption: Oracle update roundId must be larger than oracleLatestRoundId"
    );
    return (roundId, price);
  }

  /**
   * @notice Lock round
   * @param epoch: epoch
   * @param roundId: roundId
   * @param price: price of the round
   */
  function _safeLockRound(
    uint256 epoch,
    uint256 roundId,
    int256 price
  ) internal {
    require(rounds[epoch].startTimestamp != 0, "BinaryOption: Can only lock round after round has started");
    require(block.timestamp >= rounds[epoch].lockTimestamp, "BinaryOption: Can only lock round after lockTimestamp");
    require(
      block.timestamp <= rounds[epoch].lockTimestamp + bufferSeconds,
      "BinaryOption: Can only lock round within bufferSeconds"
    );
    Round storage round = rounds[epoch];
    round.lockPrice = price;
    round.lockOracleId = roundId;

    emit LockRound(epoch, roundId, round.lockPrice);
  }

  /**
   * @notice Calculate rewards for round
   * @param epoch: epoch
   */
  function _calculateRewards(uint256 epoch) internal {
    require(
      rounds[epoch].rewardBaseCalAmount == 0 && rounds[epoch].rewardAmount == 0,
      "BinaryOption: Rewards calculated"
    );
    Round storage round = rounds[epoch];
    uint256 rewardBaseCalAmount;
    uint256 treasuryAmt;
    uint256 rewardAmount;

    // high wins
    if (round.closePrice > round.lockPrice) {
      rewardBaseCalAmount = round.highAmount;
      treasuryAmt = (round.totalAmount * treasuryFee) / 10000;
      rewardAmount = round.totalAmount - treasuryAmt;
    }
    // low wins
    else if (round.closePrice < round.lockPrice) {
      rewardBaseCalAmount = round.lowAmount;
      treasuryAmt = (round.totalAmount * treasuryFee) / 10000;
      rewardAmount = round.totalAmount - treasuryAmt;
    }
    // House wins
    else {
      rewardBaseCalAmount = 0;
      rewardAmount = 0;
      treasuryAmt = round.totalAmount;
    }
    round.rewardBaseCalAmount = rewardBaseCalAmount;
    round.rewardAmount = rewardAmount;

    // Add to treasury
    treasuryAmount += treasuryAmt;

    emit RewardsCalculated(epoch, rewardBaseCalAmount, rewardAmount, treasuryAmt);
  }

  /**
   * @notice End round
   * @param epoch: epoch
   * @param roundId: roundId
   * @param price: price of the round
   */
  function _safeEndRound(
    uint256 epoch,
    uint256 roundId,
    int256 price
  ) internal {
    require(rounds[epoch].lockTimestamp != 0, "BinaryOption: Can only end round after round has locked");
    require(block.timestamp >= rounds[epoch].closeTimestamp, "BinaryOption: Can only end round after closeTimestamp");
    require(
      block.timestamp <= rounds[epoch].closeTimestamp + bufferSeconds,
      "BinaryOption: Can only end round within bufferSeconds"
    );
    Round storage round = rounds[epoch];
    round.closePrice = price;
    round.closeOracleId = roundId;
    round.oracleCalled = true;
    emit EndRound(epoch, roundId, round.closePrice);
  }

  /**
   * @notice Start genesis round
   * @dev Callable by admin or operator
   */
  function genesisStartRound() external whenNotPaused onlyOperator {
    require(!genesisStartOnce, "BinaryOption: Can only run genesisStartRound once");

    currentEpoch = currentEpoch + 1;
    _startRound(currentEpoch);
    genesisStartOnce = true;
  }

  /**
   * @notice Lock genesis round
   * @dev Callable by operator
   */
  function genesisLockRound() external whenNotPaused onlyOperator {
    require(genesisStartOnce, "BinaryOption: Can only run after genesisStartRound is triggered");
    require(!genesisLockOnce, "BinaryOption: Can only run genesisLockRound once");

    (uint80 currentRoundId, int256 currentPrice) = _getPriceFromOracle();

    oracleLatestRoundId = uint256(currentRoundId);

    _safeLockRound(currentEpoch, currentRoundId, currentPrice);

    currentEpoch = currentEpoch + 1;
    _startRound(currentEpoch);
    genesisLockOnce = true;
  }

  /**
   * @notice Start the next round n, lock price for round n-1, end round n-2
   * @dev Callable by operator
   */
  function lockAndStartNextRound() external whenNotPaused onlyOperator {
    require(
      genesisStartOnce && genesisLockOnce,
      "BinaryOption: Can only run after genesisStartRound and genesisLockRound is triggered"
    );

    (uint80 currentRoundId, int256 currentPrice) = _getPriceFromOracle();

    oracleLatestRoundId = uint256(currentRoundId);

    // CurrentEpoch refers to previous round (n-1)
    _safeLockRound(currentEpoch, currentRoundId, currentPrice);

    // Increment currentEpoch to current round (n)
    currentEpoch = currentEpoch + 1;
    _startRound(currentEpoch);
  }

  /**
   * @notice End round
   * @dev Callable by operator
   */
  function endRound() external whenNotPaused onlyOperator {
    require(
      genesisStartOnce && genesisLockOnce,
      "BinaryOption: Can only run after genesisStartRound and genesisLockRound is triggered"
    );

    (uint80 currentRoundId, int256 currentPrice) = _getPriceFromOracle();

    _safeEndRound(currentEpoch - 1, currentRoundId, currentPrice);
    _calculateRewards(currentEpoch - 1);
    claimTreasury();
  }

  /**
   * @notice called by the admin to pause, triggers stopped state
   * @dev Callable by admin or operator
   */
  function pause() external whenNotPaused onlyAdminOrOperator {
    _pause();

    emit Pause(currentEpoch);
  }

  /**
   * @notice called by the admin or operator to unpause, returns to normal state
   * Reset genesis state. Once paused, the rounds would need to be kickstarted by genesis
   */
  function unpause() external whenPaused onlyAdminOrOperator {
    genesisStartOnce = false;
    genesisLockOnce = false;
    _unpause();

    emit Unpause(currentEpoch);
  }

  /**
   * @notice Claim all rewards in treasury
   * @dev Callable by admin
   */
  function claimTreasury() public nonReentrant onlyAdminOrOperator {
    uint256 currentTreasuryAmount = treasuryAmount;
    treasuryAmount = 0;
    betToken.safeTransfer(adminAddress, currentTreasuryAmount);

    emit TreasuryClaim(currentTreasuryAmount);
  }

  /**
   * @notice It allows the owner to recover tokens sent to the contract by mistake
   * @param _token: token address
   * @param _amount: token amount
   * @dev Callable by owner
   */
  function recoverToken(address _token, uint256 _amount) external onlyOwner {
    require(_token != address(betToken), "BinaryOption: cannot recover bet token");

    ERC20(_token).safeTransfer(address(msg.sender), _amount);

    emit TokenRecovery(_token, _amount);
  }

  /**
   * @notice Set buffer, interval and lock (in seconds)
   * @dev Callable by admin
   */
  function setBufferIntervalAndLockInSeconds(
    uint256 _bufferSeconds,
    uint256 _intervalSeconds,
    uint256 _lockInSeconds
  ) external whenPaused onlyAdmin {
    require(_bufferSeconds < _intervalSeconds, "BinaryOption: bufferSeconds must be lower than intervalSeconds");
    require(_bufferSeconds < _lockInSeconds, "BinaryOption: bufferSeconds must be lower than lockInSeconds");
    require(_lockInSeconds < _intervalSeconds, "BinaryOption: lockInSeconds must be lower than intervalSeconds");
    bufferSeconds = _bufferSeconds;
    intervalSeconds = _intervalSeconds;
    lockInSeconds = _lockInSeconds;

    emit NewBufferIntervalAndLockInSeconds(_bufferSeconds, _intervalSeconds, _lockInSeconds);
  }

  /**
   * @notice Set minBetAmount
   * @dev Callable by admin
   */
  function setMinBetAmount(uint256 _minBetAmount) external whenPaused onlyAdmin {
    require(_minBetAmount != 0, "BinaryOption: must be greater than 0");
    minBetAmount = _minBetAmount;

    emit NewMinBetAmount(currentEpoch, minBetAmount);
  }

  /**
   * @notice Set treasury fee
   * @dev Callable by admin
   */
  function setTreasuryFee(uint256 _treasuryFee) external whenPaused onlyAdmin {
    require(_treasuryFee <= MAX_TREASURY_FEE, "BinaryOption: treasury fee too high");
    treasuryFee = _treasuryFee;

    emit NewTreasuryFee(currentEpoch, treasuryFee);
  }

  /**
   * @notice Set operator address
   * @dev Callable by admin
   */
  function setOperator(address _operatorAddress) external onlyAdmin {
    require(_operatorAddress != address(0), "BinaryOption: cannot be zero address");
    operatorAddress = _operatorAddress;

    emit NewOperatorAddress(_operatorAddress);
  }

  /**
   * @notice Set admin address
   * @dev Callable by owner
   */
  function setAdmin(address _adminAddress) external onlyOwner {
    require(_adminAddress != address(0), "BinaryOption: cannot be zero address");
    adminAddress = _adminAddress;

    emit NewAdminAddress(_adminAddress);
  }

  /**
   * @notice Returns round epochs and bet information for a user that has participated
   * @param user: user address
   * @param cursor: cursor
   * @param size: size
   */
  function getUserRounds(
    address user,
    uint256 cursor,
    uint256 size
  )
    external
    view
    returns (
      uint256[] memory,
      BetInfo[] memory,
      uint256
    )
  {
    uint256 length = size;

    if (length > userRounds[user].length - cursor) {
      length = userRounds[user].length - cursor;
    }

    uint256[] memory values = new uint256[](length);
    BetInfo[] memory betInfo = new BetInfo[](length);

    for (uint256 i = 0; i < length; i++) {
      values[i] = userRounds[user][cursor + i];
      betInfo[i] = ledger[values[i]][user];
    }

    return (values, betInfo, cursor + length);
  }

  /**
   * @notice Returns round epochs length
   * @param user: user address
   */
  function getUserRoundsLength(address user) external view returns (uint256) {
    return userRounds[user].length;
  }

  /**
   * @notice Get the claimable stats of specific epoch and user account
   * @param epoch: epoch
   * @param user: user address
   */
  function claimable(uint256 epoch, address user) public view returns (bool) {
    BetInfo memory betInfo = ledger[epoch][user];
    Round memory round = rounds[epoch];
    if (round.lockPrice == round.closePrice) {
      return false;
    }
    return
      round.oracleCalled &&
      betInfo.amount != 0 &&
      !betInfo.claimed &&
      ((round.closePrice > round.lockPrice && betInfo.position == Position.High) ||
        (round.closePrice < round.lockPrice && betInfo.position == Position.Low));
  }

  /**
   * @notice Get the refundable stats of specific epoch and user account
   * @param epoch: epoch
   * @param user: user address
   */
  function refundable(uint256 epoch, address user) public view returns (bool) {
    BetInfo memory betInfo = ledger[epoch][user];
    Round memory round = rounds[epoch];
    return
      !round.oracleCalled &&
      !betInfo.claimed &&
      block.timestamp > round.closeTimestamp + bufferSeconds &&
      betInfo.amount != 0;
  }

  /**
   * @notice Start round
   * @param epoch: epoch
   */
  function _startRound(uint256 epoch) internal {
    Round storage round = rounds[epoch];
    round.startTimestamp = block.timestamp;
    round.lockTimestamp = block.timestamp + lockInSeconds;
    round.closeTimestamp = block.timestamp + intervalSeconds;
    round.epoch = epoch;
    round.totalAmount = 0;

    emit StartRound(epoch);
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

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
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
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
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
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
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// SPDX-License-Identifier: MIT
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

//interfaces/AggregatorV3Interface.sol
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
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
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
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
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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