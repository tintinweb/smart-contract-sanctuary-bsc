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
     
                                                                              
                                                                      CANDLE GENIE MEME RAGE 
                                                                              
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

    function _pause() internal virtual whenNotPaused {
        _paused = true;
    }


    function _unpause() internal virtual whenPaused {
        _paused = false;
    }
}



//PREDICTIONS
contract CandleGenieMemeRage is Ownable, Pausable, ReentrancyGuard 
{
    enum Position {None, Slot1, Slot2, Slot3}

    struct Round 
    {
        uint256 epoch;
        uint256[3] slotAmounts;
        SlotItem[3] slotItems;
        uint256 rewardBaseCalAmount;
        uint256 rewardAmount;
        uint32 openTimestamp;
        uint32 drawTresholdTimestamp;
        Position result;
        uint32 drawTimestamp;
        uint256 randomness;
        bool closed;
        address[] players;
    }

    struct Bet {
        Position position;
        uint256 amount;
        bool claimed;
    }
    
    struct SlotItem {
        uint256 id;
        string name;
        bool active;
    }

    struct User 
    {
        address wallet;
        uint256 latestEpoch;
        uint256 betsCount;
        uint256 betsTotal;
        uint256 paidBetsCount;
        uint256 paidBetsTotal;
    }
    
    // Mappings
    mapping(uint256 => Round) public Rounds;
    mapping(uint256 => mapping(address => Bet)) public Bets;
    mapping(address => User) public Users;
    mapping(address => uint256[]) public UserBets;
    SlotItem[] private SlotItems;  
 
    // Current Round
    uint256 public currentEpoch;  

    // Defaults
    uint256 public rewardRate = 90; 
    uint256 public drawDuration = 1 minutes;
    uint256 public minBetAmount = 0.01 ether;
    uint256 public drawTresholdAmount = 0.02 ether;

    //Statics
    uint256 internal betsCount;
    uint256 internal betsTotal;
    uint256 internal paidBetsCount;
    uint256 internal paidBetsTotal;


    // Events
    event InjectFunds(address indexed sender);
    event MinBetAmountUpdated(uint256 indexed epoch, uint256 minBetAmount);
    event DrawTresholdAmountUpdated(uint256 drawTresholdAmount);
    event DrawDurationUpdated(uint256 drawDuration);
    event RewardRateUpdated(uint256 rewardRate);
    event Paused(uint256 indexed epoch);
    event Unpaused(uint256 indexed epoch);
    event RoundStarted(uint256 indexed epoch);
    event RoundFinished(uint256 indexed epoch, uint256 result, uint256 vrfRandomness);
    event RewardsCalculated(uint256 indexed epoch, uint256 rewardBaseCalAmount, uint256 rewardAmount);
    event Entered(address indexed sender, uint256 indexed epoch, uint256 slot, uint256 amount);
    event Claimed(address indexed sender, uint256 indexed epoch, uint256 amount);

    receive() external payable {}

    modifier notContract() 
    {
        require(!_isContract(msg.sender), "Contracts not allowed");
        require(msg.sender == tx.origin, "Proxy contracts not allowed");
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

     // INTERNAL FUNCTIONS ---------------->
    
    function _safeTransferBNB(address payable to, uint256 amount) internal 
    {
        to.transfer(amount);
    }

    function _calculateRewards(uint256 epoch) internal 
    {
        
        require(Rounds[epoch].rewardBaseCalAmount == 0 && Rounds[epoch].rewardAmount == 0, "Rewards calculated");

        Round storage round = Rounds[epoch];
        uint256 rewardBaseCalAmount;
        uint256 rewardAmount;

        uint256 totalAmount = round.slotAmounts[0] + round.slotAmounts[1] + round.slotAmounts[2];
        
        if (round.result == Position.Slot1) 
        {
            rewardBaseCalAmount = round.slotAmounts[0];
            rewardAmount = totalAmount * rewardRate / 100;
        }
        else if (round.result == Position.Slot2) 
        {
            rewardBaseCalAmount = round.slotAmounts[1];
            rewardAmount = totalAmount * rewardRate / 100;
        }
        else if (round.result == Position.Slot3) 
        {
            rewardBaseCalAmount = round.slotAmounts[2];
            rewardAmount = totalAmount * rewardRate / 100;
        }

        round.rewardBaseCalAmount = rewardBaseCalAmount;
        round.rewardAmount = rewardAmount;

        emit RewardsCalculated(epoch, rewardBaseCalAmount, rewardAmount);
    }
    
  
    // EXTERNAL FUNCTIONS ---------------->

    function FundsInject() external payable onlyOwner 
    {
        emit InjectFunds(msg.sender);
    }
    
    function FundsExtract(uint256 value) external onlyOwner 
    {
        _safeTransferBNB(payable(owner()),  value);
    }


    function Pause() public onlyOwner whenNotPaused 
    {
        _pause();
        emit Paused(currentEpoch);
    }

    function Resume() public onlyOwner whenPaused 
    {
        _unpause();
        emit Unpaused(currentEpoch);
    }

    function UpdateDrawTresholdAmount(uint256 _drawTresholdAmount) external onlyOwner
    {
        drawTresholdAmount = _drawTresholdAmount;
        emit DrawTresholdAmountUpdated(drawTresholdAmount);
    }

    function UpdateDrawDuration(uint256 _drawDuration) external onlyOwner
    {
        drawDuration = _drawDuration;
        emit DrawDurationUpdated(drawDuration);
    }

    function UpdateRewardRate(uint256 _rewardRate) external onlyOwner 
    {
        rewardRate = _rewardRate;
        emit RewardRateUpdated(rewardRate);
    }

    function UpdateMinBetAmount(uint256 _minBetAmount) external onlyOwner 
    {
        minBetAmount = _minBetAmount;
        emit MinBetAmountUpdated(currentEpoch, minBetAmount);
    }


    function SlotItemAdd(string memory name) external onlyOwner 
    {
        SlotItem memory item;
        item.id = SlotItems.length;
        item.name = name;
        item.active = true;
        SlotItems.push(item);
    }

    function SlotItemUpdate(uint256 itemID, string memory name, bool active) external onlyOwner 
    {
        SlotItem storage item = SlotItems[itemID];
        item.name = name;
        item.active = active;
    }

    // USER CALLS ---------------->

    function Enter(uint256 epoch, uint256 slot) external payable whenNotPaused nonReentrant notContract 
    {
        require(epoch == currentEpoch, "Bet is too early/late");
       
        if (Rounds[epoch].drawTresholdTimestamp > 0)
        {
            require(uint32(block.timestamp - Rounds[epoch].drawTresholdTimestamp) <= (drawDuration - 10), "Round not bettable");
        }
       
        require(slot == 1 || slot == 2 || slot == 3, "Invalid slot");
        require(msg.value >= minBetAmount, "Bet amount must be greater than minBetAmount");
        require(Bets[epoch][msg.sender].amount == 0, "Can only bet once per round");
  

        uint256 amount = msg.value;
        Round storage round = Rounds[epoch];

        Bet storage bet = Bets[epoch][msg.sender];
        bet.amount = amount;
        if (slot == 1)
        {
            round.slotAmounts[0] = round.slotAmounts[0] + amount;
            bet.position = Position.Slot1;
        }
        else if (slot == 2)
        {
            round.slotAmounts[1] = round.slotAmounts[1] + amount;
            bet.position = Position.Slot2;
        }
        else if (slot == 3)
        {
            round.slotAmounts[2] = round.slotAmounts[2] + amount;
            bet.position = Position.Slot3;
        }

        // Mark Draw Treshold Timestamp
        uint256 roundTotal = round.slotAmounts[0] + round.slotAmounts[1] + round.slotAmounts[2];
        if (round.drawTresholdTimestamp <= 0 && roundTotal >= drawTresholdAmount)
        {
            round.drawTresholdTimestamp = uint32(block.timestamp);
        }

        // Push Player
        round.players.push(msg.sender);

        // User
        Users[msg.sender].latestEpoch = epoch;
        Users[msg.sender].betsCount++;
        Users[msg.sender].betsTotal += amount;
        UserBets[msg.sender].push(epoch);

        // Stats
        betsCount++;
        betsTotal += amount;

        emit Entered(msg.sender, currentEpoch, slot, amount);
    }
    

    function Claim(uint256[] calldata epochs) external nonReentrant notContract 
    {
            
        uint256 claimTotal; // Initializes reward

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
                    // Sum
                    claimTotal += rewardAmount;
                    //User
                    Users[msg.sender].paidBetsCount++;
                    Users[msg.sender].paidBetsTotal += rewardAmount;
                    // Stats
                    paidBetsCount++;
                    paidBetsTotal += rewardAmount;
                    // Emit
                    emit Claimed(msg.sender, epochs[i], rewardAmount);
                }
            }

        }

        require(claimTotal > 0, "Not found any eligible funds for reward/refund");

        if (claimTotal > 0) 
        {
            _safeTransferBNB(payable(msg.sender), claimTotal);
        }
        
    }


    function RoundExecute(uint256 epoch, uint256 randomness, uint256 nextSlot1, uint256 nextSlot2, uint256 nextSlot3) external onlyOwner whenNotPaused 
    {

        require(Rounds[epoch].drawTresholdTimestamp > 0, "Round not reached to draw treshold");
        require(uint32(block.timestamp - Rounds[epoch].drawTresholdTimestamp) >= drawDuration, "Round not reached to draw treshold");

        Round storage round = Rounds[epoch];

        // Closing
        uint256 random = randomness % 3 + 1;
                            
        if (random == 1)
        {
            round.result = Position.Slot1;
        }
        else if (random == 2)
        {
            round.result = Position.Slot2;
        }
        else if (random == 3)
        {
            round.result = Position.Slot3;
        }
        round.randomness = randomness;
        round.drawTimestamp = uint32(block.timestamp);
        round.closed = true;
     
        
        // Calculating Rewards
         _calculateRewards(currentEpoch);                                                            
        
        // Event
        emit RoundFinished(currentEpoch, random, randomness);

        // Epoch Increment
        currentEpoch++;                                                             
      
        // New Round
        Round storage newRound = Rounds[currentEpoch];
        newRound.slotItems[0] = SlotItems[nextSlot1];
        newRound.slotItems[1] = SlotItems[nextSlot2];
        newRound.slotItems[2] = SlotItems[nextSlot3];
        newRound.openTimestamp = uint32(block.timestamp);
        newRound.epoch = currentEpoch;
            
        // Event
        emit RoundStarted(currentEpoch);

    }


   

    function claimable(uint256 epoch, address user) public view returns (bool) 
    {
        Round memory round = Rounds[epoch];
        Bet memory bet = Bets[epoch][user];
  
        if (round.result == Position.None) 
        {
            return false;
        }
        
        return round.closed && !bet.claimed && round.result == bet.position;
    }
    
    function refundable(uint256 epoch, address user) public view returns (bool) 
    {
        Bet memory bet = Bets[epoch][user];
        Round memory round = Rounds[epoch];
        
        return !round.closed && !bet.claimed && bet.amount != 0;
    }
    
    function getUserRounds(address user, uint256 cursor, uint256 size) external view returns (uint256[] memory, Bet[] memory, uint256)
    {
        uint256 length = size;

        if (length > UserBets[user].length - cursor) 
        {
            length = UserBets[user].length - cursor;
        }

        uint256[] memory epochs = new uint256[](length);
        Bet[] memory bets = new Bet[](length);

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

    function getRoundSlotAmounts(uint256 epoch) external view returns (uint256[3] memory) {
        return Rounds[epoch].slotAmounts;
    }

    function getRoundSlotItems(uint256 epoch) external view returns (SlotItem[3] memory) {
        return Rounds[epoch].slotItems;
    }

    function getRoundPlayers(uint256 epoch) external view returns (address[] memory) {
        return Rounds[epoch].players;
    }

    function getSlotItems() external view returns (SlotItem[] memory) {
        return SlotItems;
    }

}