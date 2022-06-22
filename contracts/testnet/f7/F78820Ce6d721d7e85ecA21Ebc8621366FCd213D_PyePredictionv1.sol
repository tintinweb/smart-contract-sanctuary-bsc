/**
 *Submitted for verification at BscScan.com on 2022-06-22
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function removeOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

pragma solidity ^0.8.0;

abstract contract Pausable is Context {
    
    event Paused(address account);

    event Playing(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Playing(_msgSender());
    }
}

pragma solidity ^0.8.0;

//reentrancy guard
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _stat;

    constructor() {
        _stat = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_stat != _ENTERED, "ReentrancyGuard: reentrant call");

        _stat = _ENTERED;

        _;

        _stat = _NOT_ENTERED;
    }
}

pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity ^0.8.0;

library Address {
    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {

            if (returndata.length > 0) {

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

pragma solidity ^0.8.0;


library SafeERC20 {
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom( IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

pragma solidity ^0.8.0;

interface Aggregator {

  function decimals() external view returns (
      uint8
    );

  function description() external view returns (
      string memory
    );

  function version() external view returns (
      uint256
    );

  function getRoundData(uint80 _roundId)  external view returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData() external view returns 
    (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}

pragma solidity ^0.8.0;
pragma abicoder v2;

contract PyePredictionv1 is Ownable, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    Aggregator public RoundData;

    bool public genesisLockOnce = false;
    bool public firstround = false;

    address public adaddr; // address of the admin
    address public opaddr; // address of the operator

    uint256 public buffer; // number of seconds for valid execution of a prediction round
    uint256 public interval; // interval in seconds between two prediction rounds

    uint256 public minbet; // minimum betting amount (denominated in wei)
    uint256 public betfee; // dev rate (e.g. 200 = 2%, 150 = 1.50%)
    uint256 public unclaimed; // locked amount that was not claimed

    uint256 public timeperiod; // current  prediction round

    uint256 public latestround; // converted from uint80 (Chainlink)
    uint256 public upAllowance; // seconds

    uint256 public constant MAX_BET_FEE = 1000; // 10%

    mapping(uint256 => mapping(address => BetInfo)) public ledger;
    mapping(uint256 => Round) public rounds;
    mapping(address => uint256[]) public userRounds;

    enum Position {
        Up,
        Down
    }

    struct Round {
        uint256 currperiod;
        uint256 starttime;
        uint256 locktime;
        uint256 closetime;
        int256 lockPrice;
        int256 closePrice;
        uint256 lockId;
        uint256 closeId;
        uint256 totalAmount;
        uint256 upAmount;
        uint256 downAmount;
        uint256 basereward;
        uint256 rewardAmount;
        bool RoundDataCalled;
    }

    struct BetInfo {
        Position position;
        uint256 amount;
        bool claimed; // default false
    }

    event BetUp(address indexed sender, uint256 indexed currperiod, uint256 amount);
    event BetDown(address indexed sender, uint256 indexed currperiod, uint256 amount);
    event Cashout(address indexed sender, uint256 indexed currperiod, uint256 amount);
    event EndRound(uint256 indexed currperiod, uint256 indexed roundId, int256 price);
    event LockRound(uint256 indexed currperiod, uint256 indexed roundId, int256 price);

    event NewAdmin(address admin);
    event NewBuffInt(uint256 buffer, uint256 interval);
    event NewMinBet(uint256 indexed currperiod, uint256 minbet);
    event NewBetFee(uint256 indexed currperiod, uint256 betfee);
    event NewOperator(address operator);
    event NewRoundData(address RoundData);
    event NewRoundDataUpdateAllowance(uint256 upAllowance);

    event Pause(uint256 indexed currperiod);
    event RewardsCalculated(
        uint256 indexed currperiod,
        uint256 basereward,
        uint256 rewardAmount,
        uint256 unclaimed
    );

    event StartRound(uint256 indexed currperiod);
    event TokenRecovery(address indexed token, uint256 amount);
    event TreasuryClaim(uint256 amount);
    event Playing(uint256 indexed currperiod);

    modifier onlyAdmin() {
        require(msg.sender == adaddr, "Not admin");
        _;
    }

    modifier onlyAdminOrOperator() {
        require(msg.sender == adaddr || msg.sender == opaddr, "Not operator/admin");
        _;
    }

    modifier onlyOperator() {
        require(msg.sender == opaddr, "Not operator");
        _;
    }

    modifier notContract() {
        require(!_isContract(msg.sender), "Contract not allowed");
        require(msg.sender == tx.origin, "Proxy contract not allowed");
        _;
    }

    
    constructor(
        address _RoundDataAddress, address _adminAddress, address _operatorAddress, 
        uint256 _intervalSeconds, uint256 _bufferSeconds, uint256 _minBetAmount, uint256 _RoundDataUpdateAllowance, uint256 _treasuryFee
    ) {
        require(_treasuryFee <= MAX_BET_FEE, "Treasury fee too high");

        RoundData = Aggregator(_RoundDataAddress);
        adaddr = _adminAddress;
        opaddr = _operatorAddress;
        interval = _intervalSeconds;
        buffer = _bufferSeconds;
        minbet = _minBetAmount;
        upAllowance = _RoundDataUpdateAllowance;
        betfee = _treasuryFee;
    }

    function betUp(uint256 currperiod) external payable whenNotPaused nonReentrant notContract {
        require(currperiod == timeperiod, "Bet is too early/late");
        require(_bettable(currperiod), "Round not bettable");
        require(msg.value >= minbet, "Bet amount must be greater than minbet");
        require(ledger[currperiod][msg.sender].amount == 0, "Can only bet once per round");

        // Update round data
        uint256 amount = msg.value;
        Round storage round = rounds[currperiod];
        round.totalAmount = round.totalAmount + amount;
        round.downAmount = round.downAmount + amount;

        // Update user data
        BetInfo storage betInfo = ledger[currperiod][msg.sender];
        betInfo.position = Position.Up;
        betInfo.amount = amount;
        userRounds[msg.sender].push(currperiod);

        emit BetUp(msg.sender, currperiod, amount);
    }

    function betDown(uint256 currperiod) external payable whenNotPaused nonReentrant notContract {
        require(currperiod == timeperiod, "Bet is too early/late");
        require(_bettable(currperiod), "Round not bettable");
        require(msg.value >= minbet, "Bet amount must be greater than minbet");
        require(ledger[currperiod][msg.sender].amount == 0, "Can only bet once per round");

        // Update round data
        uint256 amount = msg.value;
        Round storage round = rounds[currperiod];
        round.totalAmount = round.totalAmount + amount;
        round.upAmount = round.upAmount + amount;

        // Update user data
        BetInfo storage betInfo = ledger[currperiod][msg.sender];
        betInfo.position = Position.Down;
        betInfo.amount = amount;
        userRounds[msg.sender].push(currperiod);

        emit BetDown(msg.sender, currperiod, amount);
    }

    function cashout(uint256[] calldata currperiods) external nonReentrant notContract {
        uint256 reward; // Initializes reward

        for (uint256 i = 0; i < currperiods.length; i++) {
            require(rounds[currperiods[i]].starttime != 0, "Round has not started");
            require(block.timestamp > rounds[currperiods[i]].closetime, "Round has not ended");

            uint256 addedReward = 0;

            // Round valid, cashout rewards
            if (rounds[currperiods[i]].RoundDataCalled) {
                require(claimable(currperiods[i], msg.sender), "Not eligible for cashout");
                Round memory round = rounds[currperiods[i]];
                addedReward = (ledger[currperiods[i]][msg.sender].amount * round.rewardAmount) / round.basereward;
            }
            // Round invalid, refund bet amount
            else {
                require(refundable(currperiods[i], msg.sender), "Not eligible for refund");
                addedReward = ledger[currperiods[i]][msg.sender].amount;
            }

            ledger[currperiods[i]][msg.sender].claimed = true;
            reward += addedReward;

            emit Cashout(msg.sender, currperiods[i], addedReward);
        }

        if (reward > 0) {
            _safeTransferBNB(address(msg.sender), reward);
        }
    }

    function executeRound() external whenNotPaused onlyOperator {
        require(
            firstround && genesisLockOnce,
            "Can only run after startrounds and genesisLockRound is triggered"
        );

        (uint80 currentRoundId, int256 currentPrice) = _getPriceFromRoundData();

        latestround = uint256(currentRoundId);

        // timeperiod refers to previous round 
        _safeLockRound(timeperiod, currentRoundId, currentPrice);
        _safeEndRound(timeperiod - 1, currentRoundId, currentPrice);
        _calculateRewards(timeperiod - 1);

        // Increment timeperiod to current round 
        timeperiod = timeperiod + 1;
        _safeStartRound(timeperiod);
    }

    function genesisLockRound() external whenNotPaused onlyOperator {
        require(firstround, "Can only run after startrounds is triggered");
        require(!genesisLockOnce, "Can only run genesisLockRound once");

        (uint80 currentRoundId, int256 currentPrice) = _getPriceFromRoundData();

        latestround = uint256(currentRoundId);

        _safeLockRound(timeperiod, currentRoundId, currentPrice);

        timeperiod = timeperiod + 1;
        _startRound(timeperiod);
        genesisLockOnce = true;
    }

    function startrounds() external whenNotPaused onlyOperator {
        require(!firstround, "Can only run startrounds once");

        timeperiod = timeperiod + 1;
        _startRound(timeperiod);
        firstround = true;
    }

    function pause() external whenNotPaused onlyAdminOrOperator {
        _pause();

        emit Pause(timeperiod);
    }

    function claimTreasury() external nonReentrant onlyAdmin {
        uint256 currentTreasuryAmount = unclaimed;
        unclaimed = 0;
        _safeTransferBNB(adaddr, currentTreasuryAmount);

        emit TreasuryClaim(currentTreasuryAmount);
    }

    function playing() external whenPaused onlyAdmin {
        firstround = false;
        genesisLockOnce = false;
        _unpause();

        emit Playing(timeperiod);
    }

    function setBufferAndIntervalSeconds(uint256 _bufferSeconds, uint256 _intervalSeconds) external whenPaused onlyAdmin {
        require(_bufferSeconds < _intervalSeconds, "buffer must be inferior to interval");
        buffer = _bufferSeconds;
        interval = _intervalSeconds;

        emit NewBuffInt(_bufferSeconds, _intervalSeconds);
    }

    function setMinBetAmount(uint256 _minBetAmount) external whenPaused onlyAdmin {
        require(_minBetAmount != 0, "Must be superior to 0");
        minbet = _minBetAmount;

        emit NewMinBet(timeperiod, minbet);
    }

    function setOperator(address _operatorAddress) external onlyAdmin {
        require(_operatorAddress != address(0), "Cannot be zero address");
        opaddr = _operatorAddress;

        emit NewOperator(_operatorAddress);
    }

    function setRoundData(address _RoundData) external whenPaused onlyAdmin {
        require(_RoundData != address(0), "Cannot be zero address");
        latestround = 0;
        RoundData = Aggregator(_RoundData);

        // check to make sure the interface implements this function
        RoundData.latestRoundData();

        emit NewRoundData(_RoundData);
    }

    function setRoundDataUpdateAllowance(uint256 _RoundDataUpdateAllowance) external whenPaused onlyAdmin {
        upAllowance = _RoundDataUpdateAllowance;

        emit NewRoundDataUpdateAllowance(_RoundDataUpdateAllowance);
    }

    function setTreasuryFee(uint256 _treasuryFee) external whenPaused onlyAdmin {
        require(_treasuryFee <= MAX_BET_FEE, "Treasury fee too high");
        betfee = _treasuryFee;

        emit NewBetFee(timeperiod, betfee);
    }

    function recoverToken(address _token, uint256 _amount) external onlyOwner {
        IERC20(_token).safeTransfer(address(msg.sender), _amount);

        emit TokenRecovery(_token, _amount);
    }

    function setAdmin(address _adminAddress) external onlyOwner {
        require(_adminAddress != address(0), "Cannot be zero address");
        adaddr = _adminAddress;

        emit NewAdmin(_adminAddress);
    }

    function getUserRounds(address user, uint256 cursor, uint256 size) external view returns (uint256[] memory, BetInfo[] memory, uint256){
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

    function getUserRoundsLength(address user) external view returns (uint256) {
        return userRounds[user].length;
    }

    function claimable(uint256 currperiod, address user) public view returns (bool) {
        BetInfo memory betInfo = ledger[currperiod][user];
        Round memory round = rounds[currperiod];
        if (round.lockPrice == round.closePrice) {
            return false;
        }
        return
            round.RoundDataCalled &&
            betInfo.amount != 0 &&
            !betInfo.claimed &&
            ((round.closePrice > round.lockPrice && betInfo.position == Position.Down) ||
                (round.closePrice < round.lockPrice && betInfo.position == Position.Up));
    }

    function refundable(uint256 currperiod, address user) public view returns (bool) {
        BetInfo memory betInfo = ledger[currperiod][user];
        Round memory round = rounds[currperiod];
        return
            !round.RoundDataCalled &&
            !betInfo.claimed &&
            block.timestamp > round.closetime + buffer &&
            betInfo.amount != 0;
    }

    function _calculateRewards(uint256 currperiod) internal {
        require(rounds[currperiod].basereward == 0 && rounds[currperiod].rewardAmount == 0, "Rewards calculated");
        Round storage round = rounds[currperiod];
        uint256 basereward;
        uint256 treasuryAmt;
        uint256 rewardAmount;

        if (round.closePrice > round.lockPrice) {
            basereward = round.upAmount;
            treasuryAmt = (round.totalAmount * betfee) / 10000;
            rewardAmount = round.totalAmount - treasuryAmt;
        }
        else if (round.closePrice < round.lockPrice) {
            basereward = round.downAmount;
            treasuryAmt = (round.totalAmount * betfee) / 10000;
            rewardAmount = round.totalAmount - treasuryAmt;
        }
        // House wins
        else {
            basereward = 0;
            rewardAmount = 0;
            treasuryAmt = round.totalAmount;
        }
        round.basereward = basereward;
        round.rewardAmount = rewardAmount;

        // Add to treasury
        unclaimed += treasuryAmt;

        emit RewardsCalculated(currperiod, basereward, rewardAmount, treasuryAmt);
    }

    function _safeEndRound(uint256 currperiod, uint256 roundId, int256 price) internal {
        require(rounds[currperiod].locktime != 0, "Can only end round after round has locked");
        require(block.timestamp >= rounds[currperiod].closetime, "Can only end round after closetime");
        require(
            block.timestamp <= rounds[currperiod].closetime + buffer,
            "Can only end round within buffer"
        );
        Round storage round = rounds[currperiod];
        round.closePrice = price;
        round.closeId = roundId;
        round.RoundDataCalled = true;

        emit EndRound(currperiod, roundId, round.closePrice);
    }

    function _safeLockRound(uint256 currperiod, uint256 roundId, int256 price) internal {
        require(rounds[currperiod].starttime != 0, "Can only lock round after round has started");
        require(block.timestamp >= rounds[currperiod].locktime, "Can only lock round after locktime");
        require(
            block.timestamp <= rounds[currperiod].locktime + buffer,
            "Can only lock round within buffer"
        );
        Round storage round = rounds[currperiod];
        round.closetime = block.timestamp + interval;
        round.lockPrice = price;
        round.lockId = roundId;

        emit LockRound(currperiod, roundId, round.lockPrice);
    }

    function _safeStartRound(uint256 currperiod) internal {
        require(firstround, "Can only run after startrounds is triggered");
        require(rounds[currperiod - 2].closetime != 0, "Can only start round after round n-2 has ended");
        require(
            block.timestamp >= rounds[currperiod - 2].closetime,
            "Can only start new round after round n-2 closetime"
        );
        _startRound(currperiod);
    }

    function _safeTransferBNB(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}("");
        require(success, "TransferHelper: BNB_TRANSFER_FAILED");
    }

    function _startRound(uint256 currperiod) internal {
        Round storage round = rounds[currperiod];
        round.starttime = block.timestamp;
        round.locktime = block.timestamp + interval;
        round.closetime = block.timestamp + (2 * interval);
        round.currperiod = currperiod;
        round.totalAmount = 0;

        emit StartRound(currperiod);
    }

    function _bettable(uint256 currperiod) internal view returns (bool) {
        return
            rounds[currperiod].starttime != 0 &&
            rounds[currperiod].locktime != 0 &&
            block.timestamp > rounds[currperiod].starttime &&
            block.timestamp < rounds[currperiod].locktime;
    }

    function _getPriceFromRoundData() internal view returns (uint80, int256) {
        uint256 leastAllowedTimestamp = block.timestamp + upAllowance;
        (uint80 roundId, int256 price, , uint256 timestamp, ) = RoundData.latestRoundData();
        require(timestamp <= leastAllowedTimestamp, "RoundData update exceeded max timestamp allowance");
        require(
            uint256(roundId) > latestround,
            "RoundData update roundId must be larger than latestround"
        );
        return (roundId, price);
    }

    function _isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}