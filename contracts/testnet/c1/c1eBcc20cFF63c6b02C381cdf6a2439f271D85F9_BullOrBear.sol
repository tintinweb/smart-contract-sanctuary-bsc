// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract BullOrBear is Ownable, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    /// STATE
    IERC20 public immutable token; // Prediction token

    AggregatorV3Interface public oracle;

    uint256 public betSeconds; // Time of bet phase
    uint256 public lockSeconds; // Time of lock phase
    uint256 public bufferSeconds; // Time of buffer

    address public operator; // Address of operator
    address public admin; // Address of admin

    uint256 public minBetAmount; // Minimum bet amount
    uint256 public treasuryFee; // Fee service in basis points. 5% -> 500/10_000
    uint256 public treasuryAmount; // treasury amount that was not claimed
    uint256 public cancelFee; // Penalty for cancel position

    uint256 public currentEpoch; // Current round

    bool public genesisStartOnce = false;

    uint256 public oracleLatestRoundId;

    /**
    One invariant we need to ensure is that the latest epoch must use the latest price of the oracle to guarantee fairness for players. 
    If the epoch timestamp and the price timestamp from the oracle mismatch, 
        this means either the round is in the past but it tries to get the current price, 
        or the price from oracle cannot keep up with current epoch timestamp which is invalid. 
    To decide if they are mismatched, we use oracleUpdateAllowance to form a timestamp range and compare using the range instead of comparing two exact timestamps.
    */
    uint256 public oracleUpdateAllowance;

    mapping(uint256 => mapping(address => BetInfo)) ledger;
    mapping(uint256 => RoundInfo) rounds;
    mapping(address => UserInfo) users;
    uint256[] BET_LVLs;
    uint256[] MAX_BET_LVLs;

    /// CONSTANTs
    uint256 constant MAX_TREASURY_FEE = 10_000;
    uint256 constant MAX_CANCEL_FEE = 10_000;

    enum Position {
        Bull,
        Bear
    }

    struct RoundInfo {
        uint256 epoch;
        uint256 startTimestamp; // Timestamp round bắt đầu
        uint256 lockTimestamp; // Timestamp round bị lock, users không thể sửa đổi position
        uint256 closeTimestamp; // Timestamp round kết thúc
        int256 lockPrice;
        int256 closePrice;
        uint256 lockOracleId; // Oracle Round Id của lock price
        uint256 closeOracleId; // Oracle Round Id của close price
        uint256 totalAmount; // Tổng bet amount của cả 2 bên
        uint256 bullAmount; // Tổng bet amount của bên bull
        uint256 bearAmount; // Tổng bet amount của bên bear
        uint256 rewardBaseCalAmount; // Reward gốc (chưa tính fee dịch vụ) cho bên thắng
        uint256 rewardAmount; // Reward (đã trừ fee dịch vụ) cho bên thắng
        bool oracleCalled; // Flag để xác định round này có corrupted hay không
    }

    struct BetInfo {
        uint256 bullAmount;
        uint256 bearAmount;
        bool claimed; // Đã claim
    }

    struct UserInfo {
        uint256 betCounter;
        uint256[] rounds;
    }

    // Used to avoid "stack too deep" error
    struct PhaseTimeConfig {
        uint256 betSeconds;
        uint256 lockSeconds;
        uint256 bufferSeconds;
    }

    event BetBear(address indexed sender, uint256 indexed epoch, uint256 amount, uint256 totalAmount);
    event BetBull(address indexed sender, uint256 indexed epoch, uint256 amount, uint256 totalAmount);
    event Claim(address indexed sender, uint256 indexed epoch, uint256 amount);
    event StartRound(uint256 indexed epoch, uint256 indexed oracleRoundId, int256 lockPrice);
    event EndRound(uint256 indexed epoch, uint256 indexed oracleRoundId, int256 closePrice);

    event NewAdminAddress(address admin);
    event NewOperatorAddress(address operator);

    event NewMinBetAmount(uint256 indexed epoch, uint256 minBetAmount);
    event NewTreasuryFee(uint256 indexed epoch, uint256 treasuryFee);
    event NewOracle(address oracle);
    event NewOracleUpdateAllowance(uint256 oracleUpdateAllowance);
    event NewCancelFee(uint256 indexed epoch, uint256 cancelFee);
    event NewBetLevelData(uint256 indexed epoch, uint256[] betLVs, uint256[] maxBetLVs);

    event TreasuryClaim(address indexed to, uint256 amount);

    event RewardsCalculated(
        uint256 indexed epoch,
        uint256 rewardBaseCalAmount,
        uint256 rewardAmount,
        uint256 treasuryAmount
    );

    event Pause(uint256 indexed epoch);
    event Unpause(uint256 indexed epoch);
    event NewBetAndLockAndBufferSeconds(uint256 betSeconds, uint256 lockSeconds, uint256 bufferSeconds);
    event CancelPosition(address indexed sender, uint256 indexed epoch, Position position, uint256 amount);

    event TokenRecovery(address indexed token, uint256 amount);

    modifier onlyAdmin() {
        require(msg.sender == admin, "BullBear-A1: Not admin");
        _;
    }

    modifier onlyAdminOrOperator() {
        require(msg.sender == admin || msg.sender == operator, "BullBear-A2: Not operator/admin");
        _;
    }

    modifier onlyOperator() {
        require(msg.sender == operator, "BullBear-A3: Not operator");
        _;
    }

    modifier notContract() {
        require(!_isContract(msg.sender), "BullBear-A4: Contract not allowed");
        require(msg.sender == tx.origin, "BullBear-A5: Proxy contract not allowed");
        _;
    }

    constructor(
        IERC20 _token,
        address _oracleAddress,
        PhaseTimeConfig memory _phaseTimeConfig,
        address _admin,
        address _operator,
        uint256 _minBetAmount,
        uint256 _treasuryFee,
        uint256 _cancelFee,
        uint256 _oracleUpdateAllowance,
        uint256[] memory _betLvls,
        uint256[] memory _maxBetLvls
    ) {
        require(_treasuryFee <= MAX_TREASURY_FEE, "BullBear-STF1: Treasury fee too high");
        require(_cancelFee <= MAX_CANCEL_FEE, "BullBear-SCF1: Cancel fee too high");

        token = _token;
        oracle = AggregatorV3Interface(_oracleAddress);

        betSeconds = _phaseTimeConfig.betSeconds;
        lockSeconds = _phaseTimeConfig.lockSeconds;
        bufferSeconds = _phaseTimeConfig.bufferSeconds;
        admin = _admin;
        operator = _operator;
        minBetAmount = _minBetAmount;
        treasuryFee = _treasuryFee;
        cancelFee = _cancelFee;
        oracleUpdateAllowance = _oracleUpdateAllowance;

        require(_checkBetLevelData(_betLvls, _maxBetLvls), "BullBear-BLD1: Invalid bet level data");
        BET_LVLs = _betLvls;
        MAX_BET_LVLs = _maxBetLvls;
    }

    function betBull(uint256 epoch, uint256 amount) external whenNotPaused nonReentrant notContract {
        BetInfo storage betInfo = ledger[epoch][msg.sender];
        if (betInfo.bearAmount + betInfo.bullAmount == 0) {
            users[msg.sender].betCounter++;
        }
        require(
            amount <= getMaxBetAmount(users[msg.sender].betCounter - 1),
            "BullBear-BBU1: Bet amount exceeded max bet amount"
        );

        require(epoch == currentEpoch, "BullBear-BBU2: Bet is too early/late");
        require(_bettable(epoch), "BullBear-BBU3: Round not bettable");
        require(amount >= minBetAmount, "BullBear-BBU4: Bet amount must be greater than minBetAmount");

        token.safeTransferFrom(msg.sender, address(this), amount);

        // Update round data
        RoundInfo storage round = rounds[epoch];
        round.totalAmount = round.totalAmount + amount;
        round.bullAmount = round.bullAmount + amount;

        // Update user data
        betInfo.bullAmount += amount;
        users[msg.sender].rounds.push(epoch);

        emit BetBull(msg.sender, epoch, amount, betInfo.bullAmount);
    }

    function betBear(uint256 epoch, uint256 amount) external whenNotPaused nonReentrant notContract {
        BetInfo storage betInfo = ledger[epoch][msg.sender];
        if (betInfo.bearAmount + betInfo.bullAmount == 0) {
            users[msg.sender].betCounter++;
        }
        require(
            amount <= getMaxBetAmount(users[msg.sender].betCounter - 1),
            "BullBear-BBE1: Bet amount exceeded max bet amount"
        );

        require(epoch == currentEpoch, "BullBear-BBE2: Bet is too early/late");
        require(_bettable(epoch), "BullBear-BBE3: Round not bettable");
        require(amount >= minBetAmount, "BullBear-BBE4: Bet amount must be greater than minBetAmount");

        token.safeTransferFrom(msg.sender, address(this), amount);

        // Update round data
        RoundInfo storage round = rounds[epoch];
        round.totalAmount = round.totalAmount + amount;
        round.bearAmount = round.bearAmount + amount;

        // Update user data
        betInfo.bearAmount += amount;
        users[msg.sender].rounds.push(epoch);

        emit BetBear(msg.sender, epoch, amount, betInfo.bearAmount);
    }

    function cancelPosition(uint256 epoch, Position position) external whenNotPaused nonReentrant notContract {
        require(epoch == currentEpoch, "BullBear-CP1: Can only cancel the position within the current round");
        require(block.timestamp < rounds[epoch].lockTimestamp, "BullBear-CP2: Can only cancel position in bet phase");
        BetInfo storage betInfo = ledger[epoch][msg.sender];
        uint256 cancelAmount;
        if (position == Position.Bear) {
            require(betInfo.bearAmount > 0, "BullBear-CP3: Not bet yet");
            cancelAmount = betInfo.bearAmount;
            uint256 cancelFeeAmount = (betInfo.bearAmount * cancelFee) / 10_000;
            treasuryAmount += cancelFeeAmount;
            token.safeTransfer(msg.sender, betInfo.bearAmount - cancelFeeAmount);
            betInfo.bearAmount = 0;
        } else if (position == Position.Bull) {
            require(betInfo.bullAmount > 0, "BullBear-CP4: Not bet yet");
            cancelAmount = betInfo.bearAmount;
            uint256 cancelFeeAmount = (betInfo.bullAmount * cancelFee) / 10_000;
            treasuryAmount += cancelFeeAmount;
            token.safeTransfer(msg.sender, betInfo.bearAmount - cancelFeeAmount);
            betInfo.bullAmount = 0;
        }

        if (betInfo.bearAmount + betInfo.bullAmount == 0) {
            users[msg.sender].betCounter--;
        }

        emit CancelPosition(msg.sender, epoch, position, cancelAmount);
    }

    function claim(uint256[] calldata epochs) external nonReentrant notContract {
        uint256 reward; // Initializes reward

        for (uint256 i = 0; i < epochs.length; i++) {
            require(rounds[epochs[i]].startTimestamp != 0, "BullBear-CLM1: Round has not started");
            require(block.timestamp > rounds[epochs[i]].closeTimestamp, "BullBear-CLM2: Round has not ended");

            uint256 addedReward = 0;

            // Round valid, claim rewards
            if (rounds[epochs[i]].oracleCalled) {
                bool bearClaimable = claimable(epochs[i], msg.sender, Position.Bear);
                bool bullClaimable = claimable(epochs[i], msg.sender, Position.Bull);
                require(bearClaimable || bullClaimable, "BullBear-CLM3: Not eligible for claim");
                RoundInfo memory round = rounds[epochs[i]];
                if (bearClaimable) {
                    addedReward =
                        (ledger[epochs[i]][msg.sender].bearAmount * round.rewardAmount) /
                        round.rewardBaseCalAmount;
                }

                if (bullClaimable) {
                    addedReward =
                        (ledger[epochs[i]][msg.sender].bullAmount * round.rewardAmount) /
                        round.rewardBaseCalAmount;
                }
            }
            // Round invalid, refund bet amount
            else {
                require(refundable(epochs[i], msg.sender), "BullBear-CLM4: Not eligible for refund");
                addedReward = ledger[epochs[i]][msg.sender].bullAmount + ledger[epochs[i]][msg.sender].bearAmount;
            }

            ledger[epochs[i]][msg.sender].claimed = true;
            reward += addedReward;

            emit Claim(msg.sender, epochs[i], addedReward);
        }

        if (reward > 0) {
            token.safeTransfer(msg.sender, reward);
        }
    }

    /**
     * @notice Start genesis round
     * @dev Callable by admin or operator
     */
    function genesisStartRound() external whenNotPaused onlyOperator {
        require(!genesisStartOnce, "BullBear-GSR1: Can only run genesisStartRound once");

        (uint80 currentRoundId, int256 currentPrice) = _getPriceFromOracle();
        oracleLatestRoundId = uint256(currentRoundId);

        currentEpoch = currentEpoch + 1;
        _startRound(currentEpoch, currentRoundId, currentPrice);
        genesisStartOnce = true;
    }

    function executeRound() external whenNotPaused onlyOperator {
        require(genesisStartOnce, "BullBear-ER1: Can only run after genesisStartRound is triggered");

        (uint80 currentRoundId, int256 currentPrice) = _getPriceFromOracle();

        oracleLatestRoundId = uint256(currentRoundId);

        _safeEndRound(currentEpoch, currentRoundId, currentPrice);
        _calculateRewards(currentEpoch);

        currentEpoch = currentEpoch + 1;
        _safeStartRound(currentEpoch, currentRoundId, currentPrice);
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
     * @notice called by the admin to unpause, returns to normal state
     * Reset genesis state. Once paused, the rounds would need to be kickstarted by genesis
     * @dev Callable by admin or operator
     */
    function unpause() external whenPaused onlyAdminOrOperator {
        genesisStartOnce = false;
        _unpause();

        emit Unpause(currentEpoch);
    }

    function claimTreasury(address to, uint256 amount) external onlyAdmin {
        require(amount <= treasuryAmount, "BullBear-CT1: Amount exceeded treasury amount");
        treasuryAmount -= amount;
        token.safeTransfer(to, amount);
        emit TreasuryClaim(to, amount);
    }

    /**
     * @notice It allows the owner to recover tokens sent to the contract by mistake
     * @param _token: token address
     * @param _amount: token amount
     * @dev Callable by owner
     */
    function recoverToken(address _token, uint256 _amount) external onlyOwner {
        require(_token != address(token), "BullBear-RCT1: Cannot be prediction token address");
        IERC20(_token).safeTransfer(address(msg.sender), _amount);

        emit TokenRecovery(_token, _amount);
    }

    /**
     * @notice Set admin address
     * @dev Callable by owner
     */
    function setAdmin(address _adminAddress) external onlyOwner {
        require(_adminAddress != address(0), "BullBear-SAD1: Cannot be zero address");
        admin = _adminAddress;

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

        if (length > users[user].rounds.length - cursor) {
            length = users[user].rounds.length - cursor;
        }

        uint256[] memory values = new uint256[](length);
        BetInfo[] memory betInfo = new BetInfo[](length);

        for (uint256 i = 0; i < length; i++) {
            values[i] = users[user].rounds[cursor + i];
            betInfo[i] = ledger[values[i]][user];
        }

        return (values, betInfo, cursor + length);
    }

    /**
     * @notice Returns round epochs length
     * @param user: user address
     */
    function getUserRoundsLength(address user) external view returns (uint256) {
        return users[user].rounds.length;
    }

    function getRoundInfo(uint256 epoch) external view returns (RoundInfo memory round) {
        return rounds[epoch];
    }

    function getLedger(uint256 round, address user) external view returns (BetInfo memory betInfo) {
        return ledger[round][user];
    }

    function getUserInfo(address user) external view returns (UserInfo memory userInfo) {
        return users[user];
    }

    /**
     * @notice Get the claimable stats of specific epoch and user account
     * @param epoch: epoch
     * @param user: user address
     */
    function claimable(
        uint256 epoch,
        address user,
        Position position
    ) public view returns (bool) {
        BetInfo memory betInfo = ledger[epoch][user];
        RoundInfo memory round = rounds[epoch];

        return
            round.oracleCalled &&
            ((betInfo.bullAmount != 0 && position == Position.Bull) ||
                (betInfo.bearAmount != 0 && position == Position.Bear)) &&
            !betInfo.claimed &&
            ((round.lockPrice != round.closePrice && round.lockPrice < round.closePrice && position == Position.Bull) ||
                (round.lockPrice != round.closePrice &&
                    round.lockPrice > round.closePrice &&
                    position == Position.Bear) ||
                round.lockPrice == round.closePrice ||
                round.bullAmount == 0 ||
                round.bearAmount == 0);
    }

    /**
     * @notice Get the refundable stats of specific epoch and user account
     * @param epoch: epoch
     * @param user: user address
     */
    function refundable(uint256 epoch, address user) public view returns (bool) {
        BetInfo memory betInfo = ledger[epoch][user];
        RoundInfo memory round = rounds[epoch];
        return
            !round.oracleCalled &&
            !betInfo.claimed &&
            block.timestamp > round.closeTimestamp + bufferSeconds &&
            betInfo.bullAmount + betInfo.bearAmount > 0;
    }

    /**
     * @notice Set operator address
     * @dev Callable by admin
     */
    function setOperator(address _operatorAddress) external onlyAdmin {
        require(_operatorAddress != address(0), "BullBear-SOP1: Cannot be zero address");
        operator = _operatorAddress;

        emit NewOperatorAddress(_operatorAddress);
    }

    /**
     * @notice Set minBetAmount
     * @dev Callable by admin
     */
    function setMinBetAmount(uint256 _minBetAmount) external whenPaused onlyAdmin {
        require(_minBetAmount != 0, "BullBear-SMB1: Must be superior to 0");
        minBetAmount = _minBetAmount;

        emit NewMinBetAmount(currentEpoch, minBetAmount);
    }

    function setBetAndLockAndBuffer(
        uint256 _betSeconds,
        uint256 _lockSeconds,
        uint256 _bufferSeconds
    ) external whenPaused onlyAdmin {
        require(
            _bufferSeconds < _betSeconds + _lockSeconds,
            "BullBear-SBLB1: bufferSeconds must be inferior to phase seconds"
        );
        bufferSeconds = _bufferSeconds;
        lockSeconds = _lockSeconds;
        betSeconds = _betSeconds;

        emit NewBetAndLockAndBufferSeconds(_betSeconds, _lockSeconds, _bufferSeconds);
    }

    /**
     * @notice Set treasury fee
     * @dev Callable by admin
     */
    function setTreasuryFee(uint256 _treasuryFee) external whenPaused onlyAdmin {
        require(_treasuryFee <= MAX_TREASURY_FEE, "BullBear-STF1: Treasury fee too high");
        treasuryFee = _treasuryFee;

        emit NewTreasuryFee(currentEpoch, treasuryFee);
    }

    function setCancelFee(uint256 _cancelFee) external whenPaused onlyAdmin {
        require(_cancelFee <= MAX_CANCEL_FEE, "BullBear-SCF1: Cancel fee too high");
        cancelFee = _cancelFee;

        emit NewCancelFee(currentEpoch, cancelFee);
    }

    /**
     * @notice Set betLvlsData
     * @dev Callable by admin
     */
    function setBetLevelData(uint256[] memory _betLvls, uint256[] memory _maxBetLvls) external whenPaused onlyAdmin {
        require(_checkBetLevelData(_betLvls, _maxBetLvls), "BullBear-BLD1: Invalid bet lvl data");
        BET_LVLs = _betLvls;
        MAX_BET_LVLs = _maxBetLvls;

        emit NewBetLevelData(currentEpoch, BET_LVLs, MAX_BET_LVLs);
    }

    /**
     * @notice Set Oracle address
     * @dev Callable by admin
     */
    function setOracle(address _oracle) external whenPaused onlyAdmin {
        require(_oracle != address(0), "BullBear-SOR1: Cannot be zero address");
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

    function getMaxBetAmount(uint256 betCounter) public view returns (uint256 maxBetAmount) {
        for (uint256 index = BET_LVLs.length - 1; index >= 0; index--) {
            if (betCounter >= BET_LVLs[index]) {
                return MAX_BET_LVLs[index];
            }
        }
        return 0;
    }

    /**
     * @notice Start round
     * Previous round n-1 must end
     * @param epoch: epoch
     */
    function _safeStartRound(
        uint256 epoch,
        uint80 currentRoundId,
        int256 lockPrice
    ) internal {
        require(genesisStartOnce, "BullBear-SSR1: Can only run after genesisStartRound is triggered");
        require(rounds[epoch - 1].closeTimestamp != 0, "BullBear-SSR2: Can only start round after round n-1 has ended");
        require(
            block.timestamp >= rounds[epoch - 1].closeTimestamp,
            "BullBear-SSR3: Can only start new round after round n-1 closeTimestamp"
        );
        _startRound(epoch, currentRoundId, lockPrice);
    }

    function _startRound(
        uint256 epoch,
        uint80 currentRoundId,
        int256 lockPrice
    ) internal {
        RoundInfo storage round = rounds[epoch];
        round.startTimestamp = block.timestamp;
        round.lockTimestamp = block.timestamp + betSeconds;
        round.closeTimestamp = block.timestamp + betSeconds + lockSeconds;
        round.epoch = epoch;
        round.lockPrice = lockPrice;
        round.totalAmount = 0;
        round.bearAmount = 0;
        round.bullAmount = 0;

        emit StartRound(epoch, currentRoundId, lockPrice);
    }

    /**
     * @notice Calculate rewards for round
     * @param epoch: epoch
     */
    function _calculateRewards(uint256 epoch) internal {
        require(
            rounds[epoch].rewardBaseCalAmount == 0 && rounds[epoch].rewardAmount == 0,
            "BullBear-CR1: Rewards calculated"
        );
        RoundInfo storage round = rounds[epoch];
        uint256 rewardBaseCalAmount;
        uint256 treasuryAmt;
        uint256 rewardAmount;

        // Round fail
        if (round.closePrice == round.lockPrice || round.bearAmount == 0 || round.bullAmount == 0) {
            rewardBaseCalAmount = round.totalAmount;
            treasuryAmt = (round.totalAmount * treasuryFee) / 10_000;
            rewardAmount = round.totalAmount - treasuryAmt;
        }
        // Bull wins
        else if (round.closePrice > round.lockPrice) {
            rewardBaseCalAmount = round.bullAmount;
            treasuryAmt = (round.totalAmount * treasuryFee) / 10_000;
            rewardAmount = round.totalAmount - treasuryAmt;
        }
        // Bear wins
        else if (round.closePrice < round.lockPrice) {
            rewardBaseCalAmount = round.bearAmount;
            treasuryAmt = (round.totalAmount * treasuryFee) / 10_000;
            rewardAmount = round.totalAmount - treasuryAmt;
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
        require(
            block.timestamp >= rounds[epoch].closeTimestamp,
            "BullBear-SER1: Can only end round after closeTimestamp"
        );
        require(
            block.timestamp <= rounds[epoch].closeTimestamp + bufferSeconds,
            "BullBear-SER2: Can only end round within bufferSeconds"
        );
        RoundInfo storage round = rounds[epoch];
        round.closePrice = price;
        round.closeOracleId = roundId;
        round.oracleCalled = true;
        round.closeTimestamp = block.timestamp;

        emit EndRound(epoch, roundId, round.closePrice);
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
            genesisStartOnce &&
            block.timestamp >= rounds[epoch].startTimestamp &&
            block.timestamp < rounds[epoch].lockTimestamp;
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

    /**
     * @notice Get latest recorded price from oracle
     * If it falls below allowed buffer or has not updated, it would be invalid.
     */
    function _getPriceFromOracle() internal view returns (uint80, int256) {
        uint256 leastAllowedTimestamp = block.timestamp + oracleUpdateAllowance;
        (uint80 roundId, int256 price, , uint256 timestamp, ) = oracle.latestRoundData();
        require(timestamp <= leastAllowedTimestamp, "BullBear-ORC1: Oracle update exceeded max timestamp allowance");
        require(
            uint256(roundId) > oracleLatestRoundId,
            "BullBear-ORC2: Oracle update roundId must be larger than oracleLatestRoundId"
        );
        return (roundId, price);
    }

    function _checkBetLevelData(uint256[] memory betLVs, uint256[] memory maxBetLVs) internal pure returns (bool) {
        if (betLVs.length == 0 || maxBetLVs.length == 0 || betLVs.length != maxBetLVs.length) {
            return false;
        }

        for (uint256 index = 0; index < betLVs.length - 1; index++) {
            if (betLVs[index] >= betLVs[index + 1]) {
                return false;
            }
        }

        for (uint256 index = 0; index < maxBetLVs.length - 1; index++) {
            if (maxBetLVs[index] >= maxBetLVs[index + 1]) {
                return false;
            }
        }

        return true;
    }
}

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
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

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
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
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
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
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

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
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
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
                /// @solidity memory-safe-assembly
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}