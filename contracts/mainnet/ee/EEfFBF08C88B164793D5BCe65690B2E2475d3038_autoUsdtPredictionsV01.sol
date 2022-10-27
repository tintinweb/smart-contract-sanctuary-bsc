/**
 *Submitted for verification at BscScan.com on 2022-10-27
*/

// File: contracts/bet.sol

pragma solidity ^0.8.14;


//CONTEXT
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

//REENTRANCY GUARD
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}


abstract contract ExtraModifiers {
    modifier notContract() {
        require(!_isContract(msg.sender), "contract not allowed");
        require(msg.sender == tx.origin, "proxy contract not allowed");
        _;
    }

    function _isContract(address addr) internal view returns (bool) 
    {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}


abstract contract EtherTransfer {
    function _safeTransferBNB(address to, uint256 value) internal 
    {
        (bool success, ) = to.call{gas: 23000, value: value}("");
        require(success, "Transfer Failed");
    }
}

//OWNABLE
abstract contract Ownable is Context {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() { address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function OwnershipRenounce() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function OwnershipTransfer(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

//PAUSABLE
abstract contract Pausable is Context {
    event ContractPaused(address account);
    event ContractUnpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function IsPaused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    function _Pause() internal virtual whenNotPaused {
        _paused = true;
        emit ContractPaused(_msgSender());
    }

    function _Unpause() internal virtual whenPaused {
        _paused = false;
        emit ContractUnpaused(_msgSender());
    }
}


//PREDICTIONS
contract autoUsdtPredictionsV01 is Ownable, Pausable, ReentrancyGuard, ExtraModifiers, EtherTransfer {
    struct Round {
        uint256 epoch;
        uint256 bullAmount;
        uint256 bearAmount;
        uint256 rewardBaseCalAmount;
        uint256 rewardAmount;
        int256 lockPrice;
        int256 closePrice;
        uint32 startTimestamp;
        uint32 lockTimestamp;
        uint32 closeTimestamp;
        uint32 lockPriceTimestamp;
        uint32 closePriceTimestamp;
        bool closed;
        bool canceled;
    }

    enum Position {Bull, Bear}

    struct PlayInfo {
        Position position;
        uint256 amount;
        bool claimed; // default false
    }
    
    mapping(uint256 => Round) public Rounds;
    mapping(uint256 => mapping(address => PlayInfo)) public Plays;
    mapping(address => uint256[]) public UserPlays;
        
    uint256 public currentEpoch;
        
    address public operatorAddress;
    address public devAddress;
    address public mktAddress;
    string public priceSource;

    // Defaults
    uint256 internal _minHousePlayRatio = 90;        // housePlayBear/housePlayBull min value
    uint256 public rewardRate = 940;                 // Percents
    uint256 constant public minimumRewardRate = 900; // Minimum reward rate 90%
    uint256 public roundInterval = 300;             // In seconds
    uint256 public roundBuffer = 30;                // In seconds
    uint256 public minPlayAmount = 1000000000000000;
    uint256 public maxPlayAmount = 500000000000000000;

    bool public startedOnce = false;
    bool public lockedOnce = false;

    event PlayBear(address indexed sender, uint256 indexed epoch, uint256 amount);
    event PlayBull(address indexed sender, uint256 indexed epoch, uint256 amount);
    event HousePlayMade(address indexed sender, uint256 indexed epoch, uint256 bullAmount, uint256 bearAmount);
    event LockRound(uint256 indexed epoch, int256 price, uint32 timestamp);
    event EndRound(uint256 indexed epoch, int256 price, uint32 timestamp);
    event Claim(address indexed sender, uint256 indexed epoch, uint256 amount);
    
    event StartRound(uint256 indexed epoch);
    event CancelRound(uint256 indexed epoch);
    event ContractPaused(uint256 indexed epoch);
    event ContractUnpaused(uint256 indexed epoch);
          
    event RewardsCalculated(
        uint256 indexed epoch,
        uint256 rewardBaseCalAmount,
        uint256 rewardAmount
    );

    event InjectFunds(address indexed sender);
    event MinPlayAmountUpdated(uint256 indexed epoch, uint256 minPlayAmount);
    event MaxPlayAmountUpdated(uint256 indexed epoch, uint256 maxPlayAmount);
    event BufferAndIntervalSecondsUpdated(uint256 roundBuffer, uint256 roundInterval);
    event HousePlayMinRatioUpdated(uint256 minRatioPercents);
    event RewardRateUpdated(uint256 rewardRate);
    event NewPriceSource(string priceSource);

    constructor(address newOperatorAddress, address newDevAddress, address newMktAddress, string memory newPriceSource) {
        operatorAddress = newOperatorAddress;
        devAddress = newDevAddress;
        mktAddress = newMktAddress;
        priceSource = newPriceSource;
    }

    modifier onlyOwnerOrOperator() {
        require(msg.sender == _owner || msg.sender == operatorAddress, "Only owner or operator can call this function");
        _;
    }

        modifier onlyOperator() {
        require(msg.sender == operatorAddress, "Only operator can call this function");
        _;
    }

    // INTERNAL FUNCTIONS ---------------->
    
    function _safeStartRound(uint256 epoch) internal 
    {
        Round storage round = Rounds[epoch];
        round.startTimestamp = uint32(block.timestamp);
        round.lockTimestamp  = uint32(block.timestamp + roundInterval);
        round.closeTimestamp = uint32(block.timestamp + (2 * roundInterval));
        round.epoch = epoch;

        emit StartRound(epoch);
    }

    function _safeLockRound(uint256 epoch, int256 price, uint32 timestamp) internal 
    { 
        Round storage round = Rounds[epoch];
        round.lockPrice = price;
        round.lockPriceTimestamp = timestamp;

        emit LockRound(epoch, price, timestamp);
    }


    function _safeEndRound(uint256 epoch, int256 price, uint32 timestamp) internal 
    { 
        Round storage round = Rounds[epoch];
        round.closePrice = price;
        round.closePriceTimestamp = timestamp;
        round.closed = true;
        
        emit EndRound(epoch, price, timestamp);
    }

    function _calculateRewards(uint256 epoch) internal 
    {
        require(Rounds[epoch].rewardBaseCalAmount == 0 && Rounds[epoch].rewardAmount == 0, "Rewards calculated");
        Round storage round = Rounds[epoch];
        uint256 rewardBaseCalAmount;
        uint256 rewardAmount;

        uint256 totalAmount = round.bullAmount + round.bearAmount;
        
        // Bull wins
        if (round.closePrice > round.lockPrice) 
        {
            rewardBaseCalAmount = round.bullAmount;
            rewardAmount = totalAmount * rewardRate / 1000;
        }
        // Bear wins
        else if (round.closePrice < round.lockPrice) 
        {
            rewardBaseCalAmount = round.bearAmount;
            rewardAmount = totalAmount * rewardRate / 1000;

        }
        // House wins
        else 
        {
            rewardBaseCalAmount = 0;
            rewardAmount = 0;
        }
        round.rewardBaseCalAmount = rewardBaseCalAmount;
        round.rewardAmount = rewardAmount;

        emit RewardsCalculated(epoch, rewardBaseCalAmount, rewardAmount);
    }

    function _safeCancelRound(uint256 epoch, bool canceled, bool closed) internal 
    {
        Round storage round = Rounds[epoch];
        round.canceled = canceled;
        round.closed = closed;
        emit CancelRound(epoch);
    }

    function _safeHousePlay(uint256 bullAmount, uint256 bearAmount) internal
    {
        // Putting Bull Play
        if (bullAmount > 0)
        {
            // Update round data
            Round storage round = Rounds[currentEpoch];
            round.bullAmount += bullAmount;
    
            // Update user data
            PlayInfo storage playInfo = Plays[currentEpoch][address(this)];
            playInfo.position = Position.Bull;
            playInfo.amount = bullAmount;
            UserPlays[address(this)].push(currentEpoch);
        }

        // Putting Bear Play
        if (bearAmount > 0)
        {
            // Update round data
            Round storage round = Rounds[currentEpoch];
            round.bearAmount += bearAmount;
    
            // Update user data
            PlayInfo storage playInfo = Plays[currentEpoch][address(this)];
            playInfo.position = Position.Bear;
            playInfo.amount = bearAmount;
            UserPlays[address(this)].push(currentEpoch);
        }
        
        emit HousePlayMade(address(this), currentEpoch, bullAmount, bearAmount);
    }
  

    function _playable(uint256 epoch) internal view returns (bool) 
    {
        return
            Rounds[epoch].startTimestamp != 0 &&
            Rounds[epoch].lockTimestamp != 0 &&
            block.timestamp > Rounds[epoch].startTimestamp &&
            block.timestamp < Rounds[epoch].lockTimestamp;
    }
    
    // EXTERNAL FUNCTIONS ---------------->
    
    function SetOperator(address _operatorAddress) external onlyOwner 
    {
        require(_operatorAddress != address(0), "Cannot be zero address");
        operatorAddress = _operatorAddress;
    }

    function SetDev(address _devAddress) external onlyOwner 
    {
        require(_devAddress != address(0), "Cannot be zero address");
        devAddress = _devAddress;
    }

    function SetMkt(address _mktAddress) external onlyOperator 
    {
        require(_mktAddress != address(0), "Cannot be zero address");
        mktAddress = _mktAddress;
    }

    function FundsInject() external payable onlyOwner 
    {
        emit InjectFunds(msg.sender);
    }
    
    function FundsExtract(uint256 value) external onlyOwner 
    {
        uint256 transferValue= value * 500 / 1000;
        _safeTransferBNB(devAddress,  transferValue);
        _safeTransferBNB(mktAddress,  transferValue);
    }
    
    function RewardUser(address user, uint256 value) external onlyOwner 
    {
        _safeTransferBNB(user,  value);
    }
    
   
    function ChangePriceSource(string memory newPriceSource) external onlyOwner 
    {
        require(bytes(newPriceSource).length > 0, "Price source can not be empty");
        
        priceSource = newPriceSource;
        emit NewPriceSource(newPriceSource);
    }

    function HousePlay(uint256 bullAmount, uint256 bearAmount) external onlyOwnerOrOperator whenNotPaused notContract 
    {
        require(_playable(currentEpoch), "Round not playable");
        require(address(this).balance >= bullAmount + bearAmount, "Contract balance must be greater than house play totals");

        _safeHousePlay(bullAmount, bearAmount);
    } 

    function Pause() public onlyOwnerOrOperator whenNotPaused 
    {
        _Pause();

        emit ContractPaused(currentEpoch);
    }

    function Unpause() public onlyOwnerOrOperator whenPaused 
    {
        startedOnce = false;
        lockedOnce = false;
        _Unpause();

        emit ContractUnpaused(currentEpoch);
    }

    function RoundStart() external onlyOwnerOrOperator whenNotPaused 
    {
        require(!startedOnce, "Can only run startRound once");

        currentEpoch = currentEpoch + 1;
        _safeStartRound(currentEpoch);
        startedOnce = true;
    }


    function RoundLock(int256 price, uint32 timestamp) external onlyOwnerOrOperator whenNotPaused 
    {
        require(startedOnce, "Can only run after startRound is triggered");
        require(!lockedOnce, "Can only run lockRound once");

        require(Rounds[currentEpoch].startTimestamp != 0, "Can only lock round after round has started");
        require(block.timestamp >= Rounds[currentEpoch].lockTimestamp, "Can only lock round after lock timestamp");
        require(block.timestamp <= Rounds[currentEpoch].closeTimestamp, "Can only lock before end timestamp");

        _safeLockRound(currentEpoch, price, timestamp);

        currentEpoch = currentEpoch + 1;
        _safeStartRound(currentEpoch);
        lockedOnce = true;
    }
    
    function Execute(int256 price, uint32 timestamp, uint256 playOnBull, uint256 playOnBear) external onlyOwnerOrOperator whenNotPaused 
    {
        require(startedOnce && lockedOnce, "Can only execute after StartRound and LockRound is triggered");
        require(Rounds[currentEpoch - 2].closeTimestamp != 0, "Can only execute after round n-2 has ended(closeTimestamp != 0)");
        require(block.timestamp >= Rounds[currentEpoch - 2].closeTimestamp, "Can only start new round after round n-2 endBlock");
 
        // LockRound conditions

        require(block.timestamp >= Rounds[currentEpoch].lockTimestamp, "Too soon! Can only execute after current round .lockTimestamp");
        require(block.timestamp <= Rounds[currentEpoch].closeTimestamp, "Too late! Can only execute before current round .closeTimestamp");

        // HousePlay conditions
        require(address(this).balance >= playOnBull + playOnBear, "Contract balance must be greater than house play totals");
        require(HousePlaysWithinLimits(playOnBull, playOnBear), "Difference playween house plays is too great");

        _safeLockRound(currentEpoch, price, timestamp);                                     
        _safeEndRound(currentEpoch - 1, price, timestamp);                                  
        
        _calculateRewards(currentEpoch - 1);                                                            
      
        _safeStartRound(currentEpoch + 1);                                                                 
        currentEpoch = currentEpoch + 1; // to reflect the fact that we have added a new round

        _safeHousePlay(playOnBull, playOnBear);
    }


    function RoundCancel(uint256 epoch, bool canceled, bool closed) external onlyOwnerOrOperator
    {
        _safeCancelRound(epoch, canceled, closed);
    }


    function SetRoundBufferAndInterval(uint256 roundBufferSeconds, uint256 roundIntervalSeconds) external onlyOwnerOrOperator
    {
        require(roundBufferSeconds < roundIntervalSeconds, "roundBufferSeconds must be less than roundIntervalSeconds");
        roundBuffer = roundBufferSeconds;
        roundInterval = roundIntervalSeconds;
        emit BufferAndIntervalSecondsUpdated(roundBufferSeconds, roundIntervalSeconds);
    }

    function SetHousePlayMinRatio(uint256 minBearToBullRatioPercents) external onlyOwner 
    {
        require(0 < minBearToBullRatioPercents && minBearToBullRatioPercents < 100, "Supplied value is out-of-bounds: 0 < minBearToBullRatioPercents < 100");

        _minHousePlayRatio = minBearToBullRatioPercents;
        emit HousePlayMinRatioUpdated(_minHousePlayRatio);
    }

    function SetRewardRate(uint256 newRewardRate) external onlyOwner 
    {
        require(newRewardRate >= minimumRewardRate, "Reward rate can't be lower than minimum reward rate");
        rewardRate = newRewardRate;
        emit RewardRateUpdated(rewardRate);
    }

    function SetMinPlayAmount(uint256 newMinPlayAmount) external onlyOwner 
    {
        minPlayAmount = newMinPlayAmount;
        emit MinPlayAmountUpdated(currentEpoch, minPlayAmount);
    }

        function SetMaxPlayAmount(uint256 newMaxPlayAmount) external onlyOwner 
    {
        maxPlayAmount = newMaxPlayAmount;
        emit MaxPlayAmountUpdated(currentEpoch, maxPlayAmount);
    }


    function _CheckPlayRequirements(uint epoch) internal {
        require(epoch == currentEpoch, "Play is too early/late");
        require(_playable(epoch), "Round not playable. You might be too early/too late");
        require(msg.value >= minPlayAmount, "Play amount must be greater than minPlayAmount");
        require(msg.value <= maxPlayAmount, "Play amount must be greater than maxPlayAmount");
        require(Plays[epoch][msg.sender].amount == 0, "Can only play once per round");
    }


    function _SafePlay(Position chosenPosition, uint epoch) internal {
        uint amount = msg.value;
        Round storage round = Rounds[epoch];

        if (chosenPosition == Position.Bull) {
            round.bullAmount = round.bullAmount + amount;
            PlayInfo storage playInfo = Plays[epoch][msg.sender];
            playInfo.position = Position.Bull;
            playInfo.amount = amount;
            UserPlays[msg.sender].push(epoch);
            emit PlayBull(msg.sender, currentEpoch, amount);
        }
        else if (chosenPosition == Position.Bear) {
            round.bearAmount = round.bearAmount + amount;
            PlayInfo storage playInfo = Plays[epoch][msg.sender];
            playInfo.position = Position.Bear;
            playInfo.amount = amount;
            UserPlays[msg.sender].push(epoch);
            emit PlayBear(msg.sender, epoch, amount);
        }
        else {
            revert('unreachable code reached; this should never be reachable in normal operation');
        }

    }


    function user_PlayBull(uint epoch) external payable whenNotPaused nonReentrant notContract {
        _CheckPlayRequirements(epoch);
        _SafePlay(Position.Bull, epoch);
    }

    
    function user_PlayBear(uint epoch) external payable whenNotPaused nonReentrant notContract {
        _CheckPlayRequirements(epoch);
        _SafePlay(Position.Bear, epoch);
    }


    function user_Claim(uint256[] calldata epochs) external nonReentrant notContract 
    {
        uint256 reward; // Initializes reward

        for (uint256 i = 0; i < epochs.length; i++) {
            require(Rounds[epochs[i]].startTimestamp != 0, "Round has not started");
            require(block.timestamp > Rounds[epochs[i]].closeTimestamp, "Round has not ended");

            uint256 addedReward = 0;

            // Round valid, claim rewards
            if (Rounds[epochs[i]].closed) {
                require(Claimable(epochs[i], msg.sender), "Not eligible to claim");
                Round memory round = Rounds[epochs[i]];
                addedReward = (Plays[epochs[i]][msg.sender].amount * round.rewardAmount) / round.rewardBaseCalAmount;
            }
            // Round invalid, refund play amount
            else {
                require(Refundable(epochs[i], msg.sender), "Not eligible for refund");
                addedReward = Plays[epochs[i]][msg.sender].amount;
            }

            Plays[epochs[i]][msg.sender].claimed = true;
            reward += addedReward;

            emit Claim(msg.sender, epochs[i], addedReward);
        }

        if (reward > 0) 
        {
            _safeTransferBNB(address(msg.sender), reward);
        }
        
    }
    
    function GetUserRounds(address user, uint256 cursor, uint256 size) external view returns (uint256[] memory, PlayInfo[] memory, uint256)
    {
        uint256 length = size;

        if (length > UserPlays[user].length - cursor) 
        {
            length = UserPlays[user].length - cursor;
        }

        uint256[] memory values = new uint256[](length);
        PlayInfo[] memory playInfo = new PlayInfo[](length);

        for (uint256 i = 0; i < length; i++) 
        {
            values[i] = UserPlays[user][cursor + i];
            playInfo[i] = Plays[values[i]][user];
        }

        return (values, playInfo, cursor + length);
    }
    
    function GetUserRoundsLength(address user) external view returns (uint256) {
        return UserPlays[user].length;
    }


    function Claimable(uint256 epoch, address user) public view returns (bool) 
    {
        PlayInfo memory playInfo = Plays[epoch][user];
        Round memory round = Rounds[epoch];
        
        if (round.lockPrice == round.closePrice) 
        {
            return false;
        }
        
        return round.closed && !playInfo.claimed && playInfo.amount != 0 && ((round.closePrice > round.lockPrice 
        && playInfo.position == Position.Bull) || (round.closePrice < round.lockPrice && playInfo.position == Position.Bear));
    }
    

    function Refundable(uint256 epoch, address user) public view returns (bool) 
    {
        PlayInfo memory playInfo = Plays[epoch][user];
        Round memory round = Rounds[epoch];
        
        return !round.closed && !playInfo.claimed && block.timestamp > round.closeTimestamp + roundBuffer && playInfo.amount != 0;
    }


    function HousePlaysWithinLimits(uint256 playBull, uint256 playBear) public view returns (bool)
    {
        uint256 inverseRatio = (100 * 100) / _minHousePlayRatio;
        uint256 currentRatio = (playBull * 100) / playBear;
        return (_minHousePlayRatio <= currentRatio && currentRatio <= inverseRatio);
    }


    function currentSettings() public view returns (bool, bool, bool, uint256, uint256, string memory, uint256) 
    {
        return (IsPaused(), startedOnce, lockedOnce, roundInterval, roundBuffer, priceSource, _minHousePlayRatio);
    }


    function currentBlockNumber() public view returns (uint256) 
    {
        return block.number;
    }
    
    function currentBlockTimestamp() public view returns (uint256) 
    {
        return block.timestamp;
    }
    
}