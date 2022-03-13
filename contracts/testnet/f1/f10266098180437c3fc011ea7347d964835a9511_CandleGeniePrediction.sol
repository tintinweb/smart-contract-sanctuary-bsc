/**
 *Submitted for verification at BscScan.com on 2022-03-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-28
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;


/*

      ___           ___           ___           ___           ___       ___                    ___           ___           ___                       ___     
     /\  \         /\  \         /\__\         /\  \         /\__\     /\  \                  /\  \         /\  \         /\__\          ___        /\  \    
    /::\  \       /::\  \       /::|  |       /::\  \       /:/  /    /::\  \                /::\  \       /::\  \       /::|  |        /\  \      /::\  \   
   /:/\:\  \     /:/\:\  \     /:|:|  |      /:/\:\  \     /:/  /    /:/\:\  \              /:/\:\  \     /:/\:\  \     /:|:|  |        \:\  \    /:/\:\  \  
  /:/  \:\  \   /::\~\:\  \   /:/|:|  |__   /:/  \:\__\   /:/  /    /::\~\:\  \            /:/  \:\  \   /::\~\:\  \   /:/|:|  |__      /::\__\  /::\~\:\  \ 
 /:/__/ \:\__\ /:/\:\ \:\__\ /:/ |:| /\__\ /:/__/ \:|__| /:/__/    /:/\:\ \:\__\          /:/__/_\:\__\ /:/\:\ \:\__\ /:/ |:| /\__\  __/:/\/__/ /:/\:\ \:\__\
 \:\  \  \/__/ \/__\:\/:/  / \/__|:|/:/  / \:\  \ /:/  / \:\  \    \:\~\:\ \/__/          \:\  /\ \/__/ \:\~\:\ \/__/ \/__|:|/:/  / /\/:/  /    \:\~\:\ \/__/
  \:\  \            \::/  /      |:/:/  /   \:\  /:/  /   \:\  \    \:\ \:\__\             \:\ \:\__\    \:\ \:\__\       |:/:/  /  \::/__/      \:\ \:\__\  
   \:\  \           /:/  /       |::/  /     \:\/:/  /     \:\  \    \:\ \/__/              \:\/:/  /     \:\ \/__/       |::/  /    \:\__\       \:\ \/__/  
    \:\__\         /:/  /        /:/  /       \::/__/       \:\__\    \:\__\                 \::/  /       \:\__\         /:/  /      \/__/        \:\__\    
     \/__/         \/__/         \/__/         ~~            \/__/     \/__/                  \/__/         \/__/         \/__/                     \/__/  
     
                                                                              
                                                                  CANDLE GENIE BNB PREDICTION V4🗲
                                                                              
                                                                      https://candlegenie.io


*/


//CONTEXT
abstract contract Context 
{
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

// REENTRANCY GUARD
abstract contract ReentrancyGuard 
{
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


//OWNABLE
abstract contract Ownable is Context 
{
    address private _owner;

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
abstract contract Pausable is Context 
{

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

    function _unpause() internal virtual whenPaused {
        _paused = false;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
    }

}


//CONTRACT
contract CandleGeniePrediction is Ownable, Pausable, ReentrancyGuard 
{

    struct Round 
    {
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
        bool closed;
        bool cancelled;
        Player[] players;
    }

    enum Position {Bull, Bear}

    struct Bet 
    {
        Position position;
        uint256 betTimestamp;
        uint256 claimTimestamp;
        uint256 amount;
        bool claimed; 
    }
    
    struct Player {
        address user;
        Position position;
        uint256 amount;
        uint256 timestamp;
    }

    struct User 
    {
        address wallet;
        uint256 latestEpoch;
        uint256 bullBetsCount;
        uint256 bullBetsTotal;
        uint256 bearBetsCount;
        uint256 bearBetsTotal;
        uint256 paidBetsCount;
        uint256 paidBetsTotal;
    }


    mapping(uint256 => Round) public Rounds;
    mapping(uint256 => mapping(address => Bet)) public Bets;
    mapping(address => User) public Users;
    mapping(address => uint256[]) public UserBets;


    // ID
    uint256 public currentEpoch;
  
    // Variables
    string public priceSource;
    uint256 public rewardRate = 95;
    uint256 public roundDuration = 5 minutes;
    uint256 public minBetAmount = 0.01 ether;

    // State
    bool public startOnce;
    bool public lockOnce;

    // Events
    event RoundStarted(uint256 indexed epoch);
    event RoundLocked(uint256 indexed epoch, int256 price);
    event RoundEnded(uint256 indexed epoch, int256 price);
    event RoundEndedCancelled(uint256 indexed epoch);
    event BearBet(address indexed sender, uint256 indexed epoch, uint256 amount);
    event BullBet(address indexed sender, uint256 indexed epoch, uint256 amount);
    event HouseBet(address indexed sender, uint256 indexed epoch, uint256 bullAmount, uint256 bearAmount);
    event Refunded(address indexed sender, uint256 indexed epoch, uint256 amount);
    event Claimed(address indexed sender, uint256 indexed epoch, uint256 amount);
    event Paused(uint256 indexed epoch);
    event Unpaused(uint256 indexed epoch);
    event RoundDuratioUpdated(uint256 roundDuration);
    event MinBetAmountUpdated(uint256 indexed epoch, uint256 minBetAmount);

    //Statics
    uint256 internal bullBetsCount;
    uint256 internal bullBetsTotal;
    uint256 internal bearBetsCount;
    uint256 internal bearBetsTotal;
    uint256 internal paidBetsCount;
    uint256 internal paidBetsTotal;

    receive() external payable {}


    modifier notContract() 
    {
        require(!_isContract(msg.sender), "Contracts not allowed");
        require(msg.sender == tx.origin, "Proxy contracts not allowed");
        _;
    }

    // INTERNAL FUNCTIONS ---------------->
    
    function _isContract(address addr) internal view returns (bool) 
    {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
    
    function _safeTransferBNB(address payable to, uint256 amount) internal 
    {
        to.transfer(amount);
    }

    function _safeStartRound(uint256 epoch) internal 
    {

        Round storage round = Rounds[epoch];
        round.startTimestamp = uint32(block.timestamp);
        round.lockTimestamp =  uint32(block.timestamp + roundDuration);
        round.closeTimestamp =  uint32(block.timestamp + (2 * roundDuration));
        round.epoch = epoch;

        emit RoundStarted(epoch);
    }

    function _safeLockRound(uint256 epoch, int256 price) internal 
    {
        require(Rounds[epoch].startTimestamp != 0, "Can only lock round after round has started");
        require(block.timestamp >= Rounds[epoch].lockTimestamp, "Can only lock round after lock timestamp");
        require(block.timestamp <= Rounds[epoch].closeTimestamp, "Can only lock before end timestamp");
        
        Round storage round = Rounds[epoch];
        round.lockPrice = price;
        emit RoundLocked(epoch, price);

    }

    function _safeEndRound(uint256 epoch, int256 price) internal 
    {
        require(Rounds[epoch].lockTimestamp != 0, "Can only end round after round has locked");
        require(block.timestamp >= Rounds[epoch].closeTimestamp, "Can only end round after close timestamp");
        
        Round storage round = Rounds[epoch];
        round.closePrice = price;
        round.closed = true;
        
        emit RoundEnded(epoch, price);
    }

    function _calculateRewards(uint256 epoch) internal 
    {
        
        require(Rounds[epoch].rewardBaseCalAmount == 0 && Rounds[epoch].rewardAmount == 0, "Rewards calculated already");

        Round storage round = Rounds[epoch];
        uint256 rewardBaseCalAmount;
        uint256 rewardAmount;

        uint256 totalAmount = round.bullAmount + round.bearAmount;
        
        // Bull wins
        if (round.closePrice > round.lockPrice) 
        {
            rewardBaseCalAmount = round.bullAmount;
            rewardAmount = totalAmount * rewardRate / 100;
        }
        // Bear wins
        else if (round.closePrice < round.lockPrice) 
        {
            rewardBaseCalAmount = round.bearAmount;
            rewardAmount = totalAmount * rewardRate / 100;
        }
        
        round.rewardBaseCalAmount = rewardBaseCalAmount;
        round.rewardAmount = rewardAmount;

    }

    function _safeCancelRound(uint256 epoch, bool cancelled, bool closed) internal 
    {
        Round storage round = Rounds[epoch];
        round.cancelled = cancelled;
        round.closed = closed;
        emit RoundEndedCancelled(epoch);
    }

    function _bettable(uint256 epoch) internal view returns (bool) 
    {
        return
            Rounds[epoch].startTimestamp != 0 &&
            Rounds[epoch].lockTimestamp != 0 &&
            block.timestamp > Rounds[epoch].startTimestamp &&
            block.timestamp < Rounds[epoch].lockTimestamp;
    }

    // EXTERNAL FUNCTIONS ---------------->
    
    function FundsInject() external payable onlyOwner {}
    
    function FundsExtract(uint256 value) external onlyOwner 
    {
        _safeTransferBNB(payable(owner()),  value);
    }

    function SetPriceSource(string memory _priceSource) external onlyOwner 
    {
        require(bytes(_priceSource).length > 0, "Price source can not be empty");
        priceSource = _priceSource;
    }

    function SetRewardRate(uint256 _rewardRate) external onlyOwner 
    {
        rewardRate = _rewardRate;
    }

    function SetMinBetAmount(uint256 _minBetAmount) external onlyOwner 
    {
        minBetAmount = _minBetAmount;

        emit MinBetAmountUpdated(currentEpoch, minBetAmount);
    }

    function SetRoundDuration(uint256 _roundDuration) external onlyOwner
    {
        roundDuration = _roundDuration;
        emit RoundDuratioUpdated(_roundDuration);
    }

    // GAME FUNCTIONS ---------------->

    function Pause() public onlyOwner whenNotPaused 
    {
        _pause();
        emit Paused(currentEpoch);
    }

    function Resume() public onlyOwner whenPaused 
    {
        startOnce = false;
        lockOnce = false;
        _unpause();
        emit Unpaused(currentEpoch);
    }

    function RoundStart() external onlyOwner whenNotPaused 
    {
        require(!startOnce, "Start function can only run once");

        currentEpoch = currentEpoch + 1;
        _safeStartRound(currentEpoch);
        startOnce = true;
    }

    function RoundLock(int256 price) external onlyOwner whenNotPaused 
    {
        require(startOnce, "Round not started");
        require(!lockOnce, "Lock function can only run once");

        _safeLockRound(currentEpoch, price);

        // EPOCH++
        currentEpoch++;

        _safeStartRound(currentEpoch);
        
        lockOnce = true;
        
    }

    function RoundExecute(int256 price) external onlyOwner whenNotPaused 
    {                                                                                               
        require(startOnce && lockOnce,"Can only run after startRound and lockRound is triggered");
        require(Rounds[currentEpoch - 2].closeTimestamp != 0, "Can only start round after previous round started");
        require(block.timestamp >= Rounds[currentEpoch - 2].closeTimestamp, "Can only start new round after previous round ended");
        
        // EXECUTE
        _safeLockRound(currentEpoch, price);                                     
        _safeEndRound(currentEpoch - 1, price);                                  
        _calculateRewards(currentEpoch - 1);                                                            
      
        // EPOCH++
        currentEpoch++;                                                               

        // START
        _safeStartRound(currentEpoch);                                                                 
           
    }

    function RoundCancel(uint256 epoch, bool cancelled, bool closed) external onlyOwner 
    {
        _safeCancelRound(epoch, cancelled, closed);
    }


    function BetHouse(uint256 bullAmount, uint256 bearAmount) external onlyOwner whenNotPaused notContract 
    {
    
        require(_bettable(currentEpoch), "Round not bettable");
     
        // Putting Bull Bet
        if (bullAmount > 0)
        {
            // Update round data
            Round storage round = Rounds[currentEpoch];
            round.bullAmount += bullAmount;
    
            // Update user data
            Bet storage bet = Bets[currentEpoch][address(this)];
            bet.position = Position.Bull;
            bet.amount = bullAmount;
            bet.betTimestamp = block.timestamp;
            UserBets[address(this)].push(currentEpoch);
        }

        // Putting Bear Bet
        if (bearAmount > 0)
        {
            // Update round data
            Round storage round = Rounds[currentEpoch];
            round.bearAmount += bearAmount;
    
            // Update user data
            Bet storage bet = Bets[currentEpoch][address(this)];
            bet.position = Position.Bear;
            bet.amount = bearAmount;
            bet.betTimestamp = block.timestamp;
            UserBets[address(this)].push(currentEpoch);
        }
        
        emit HouseBet(address(this), currentEpoch, bullAmount, bearAmount);
    }
    

    // USER FUNCTIONS ---------------->

    function BetBull(uint256 epoch) external payable whenNotPaused nonReentrant notContract 
    {
        require(epoch == currentEpoch, "Bet is too early/late");
        require(_bettable(epoch), "Round not bettable");
        require(msg.value >= minBetAmount, "Bet amount must be greater than minimum amount");
        require(Bets[epoch][msg.sender].amount == 0, "Can only bet once per round");

        uint256 amount = msg.value;
        Round storage round = Rounds[epoch];
        round.bullAmount = round.bullAmount + amount;

        // Bet
        Bet storage bet = Bets[epoch][msg.sender];
        bet.position = Position.Bull;
        bet.amount = amount;
        bet.betTimestamp = block.timestamp;

        // User
        Users[msg.sender].latestEpoch = epoch;
        Users[msg.sender].bullBetsCount++;
        Users[msg.sender].bullBetsTotal += amount;
        UserBets[msg.sender].push(epoch);

        // Player
        Player memory player;
        player.user = msg.sender;
        player.position = Position.Bull;
        player.amount = amount;
        player.timestamp = block.timestamp;
        round.players.push(player);

        // Stats
        bullBetsCount++;
        bullBetsTotal += amount;

        emit BullBet(msg.sender, currentEpoch, amount);
    }
    
    
    function BetBear(uint256 epoch) external payable whenNotPaused nonReentrant notContract 
    {
        
        require(epoch == currentEpoch, "Bet is too early/late");
        require(_bettable(epoch), "Round not bettable");
        require(msg.value >= minBetAmount, "Bet amount must be greater than minimum amount");
        require(Bets[epoch][msg.sender].amount == 0, "Can only bet once per round");
 
        uint256 amount = msg.value;
        Round storage round = Rounds[epoch];
        round.bearAmount = round.bearAmount + amount;

        // Bet
        Bet storage bet = Bets[epoch][msg.sender];
        bet.position = Position.Bear;
        bet.amount = amount;
        bet.betTimestamp = block.timestamp;

        // User
        Users[msg.sender].latestEpoch = epoch;
        Users[msg.sender].bearBetsCount++;
        Users[msg.sender].bearBetsTotal += amount;
        UserBets[msg.sender].push(epoch);

        // Player
        Player memory player;
        player.user = msg.sender;
        player.position = Position.Bear;
        player.amount = amount;
        player.timestamp = block.timestamp;
        round.players.push(player);

        // Stats
        bearBetsCount++;
        bearBetsTotal += amount;

        emit BearBet(msg.sender, epoch, amount);

    }


    function Claim(uint256[] calldata epochs) external nonReentrant notContract 
    {
            
        uint256 amountToClaim; 

        for (uint256 i = 0; i < epochs.length; i++) 
        {
  
            // Reward
            if (Rounds[epochs[i]].closed) 
            {
                if (claimable(epochs[i], msg.sender))
                {
                    Round memory round = Rounds[epochs[i]];
                    uint256 rewardAmount = (Bets[epochs[i]][msg.sender].amount * round.rewardAmount) / round.rewardBaseCalAmount;
                    // Mark
                    Bets[epochs[i]][msg.sender].claimed = true;
                    Bets[epochs[i]][msg.sender].claimTimestamp = block.timestamp;
                    // Sum
                    amountToClaim += rewardAmount;
                    //User
                    Users[msg.sender].paidBetsCount++;
                    Users[msg.sender].paidBetsTotal += rewardAmount;
                    //Stats
                    paidBetsCount++;
                    paidBetsTotal += rewardAmount;
                    // Emit
                    emit Claimed(msg.sender, epochs[i], rewardAmount);
                }
            }

            // Refund
            if (Rounds[epochs[i]].cancelled) 
            {
                if (refundable(epochs[i], msg.sender))
                {
                    uint256 refundAmount = Bets[epochs[i]][msg.sender].amount;
                    // Mark
                    Bets[epochs[i]][msg.sender].claimed = true;
                    Bets[epochs[i]][msg.sender].claimTimestamp = block.timestamp;
                    // Sum
                    amountToClaim += refundAmount;
                    //User
                    Users[msg.sender].paidBetsCount++;
                    Users[msg.sender].paidBetsTotal += refundAmount;
                    //Stats
                    paidBetsCount++;
                    paidBetsTotal += refundAmount;
                    // Emit
                    emit Refunded(msg.sender, epochs[i], refundAmount);
                }
            }

        }

        require(amountToClaim > 0, "Not found any eligible reward/refund funds");

        if (amountToClaim > 0) 
        {
            _safeTransferBNB(payable(msg.sender), amountToClaim);
        }
        
    }
    
     // PUBLIC FUNCTIONS ---------------->

    function getUserRounds(address user, uint256 cursor, uint256 size) external view returns (uint256[] memory, Bet[] memory, uint256)
    {
        uint256 length = size;

        if (length > UserBets[user].length - cursor) 
        {
            length = UserBets[user].length - cursor;
        }

        uint256[] memory epochs = new uint256[](length);
        Bet[] memory bets  = new Bet[](length);

        for (uint256 i = 0; i < length; i++) 
        {
            epochs[i] = UserBets[user][cursor + i];
            bets[i] = Bets[epochs[i]][user];
        }

        return (epochs, bets, cursor + length);
    }
    
    function getUserRoundsLength(address user) external view returns (uint256) {
        return UserBets[user].length;
    }

    
    function getRoundPlayers(uint256 epoch) external view returns (Player[] memory) {
        return Rounds[epoch].players;
    }

    function getStats() external view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        return (bullBetsCount, bullBetsTotal, bearBetsCount, bearBetsTotal, paidBetsCount, paidBetsTotal);
    }


    function claimable(uint256 epoch, address user) public view returns (bool) 
    {
        Bet memory bet = Bets[epoch][user];
        Round memory round = Rounds[epoch];
        
        if (round.lockPrice == round.closePrice) 
        {
            return false;
        }
        
        return round.closed && !bet.claimed && ((round.closePrice > round.lockPrice 
        && bet.position == Position.Bull) || (round.closePrice < round.lockPrice && bet.position == Position.Bear));
    }
    
    function refundable(uint256 epoch, address user) public view returns (bool) 
    {
        Bet memory bet = Bets[epoch][user];
        Round memory round = Rounds[epoch];
        
        return !round.closed && !bet.claimed && block.timestamp > round.closeTimestamp && bet.amount != 0;
    }

 
}