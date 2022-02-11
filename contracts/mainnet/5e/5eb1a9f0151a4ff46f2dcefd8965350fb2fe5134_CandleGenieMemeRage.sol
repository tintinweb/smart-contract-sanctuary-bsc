/**
 *Submitted for verification at BscScan.com on 2022-02-11
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;


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
     
                                                                              
                                                                CANDLE GENIE MEME RAGE (CHAINLINK VRF)
                                                                              
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

    event Paused(address account);

    event Unpaused(address account);

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
        emit Unpaused(_msgSender());
    }
}

// LINK TOKEN INTERFACE
interface LinkTokenInterface {

  function allowance(
    address owner,
    address spender
  )
    external
    view
    returns (
      uint256 remaining
    );

  function approve(
    address spender,
    uint256 value
  )
    external
    returns (
      bool success
    );

  function balanceOf(
    address owner
  )
    external
    view
    returns (
      uint256 balance
    );

  function decimals()
    external
    view
    returns (
      uint8 decimalPlaces
    );

  function decreaseApproval(
    address spender,
    uint256 addedValue
  )
    external
    returns (
      bool success
    );

  function increaseApproval(
    address spender,
    uint256 subtractedValue
  ) external;

  function name()
    external
    view
    returns (
      string memory tokenName
    );

  function symbol()
    external
    view
    returns (
      string memory tokenSymbol
    );

  function totalSupply()
    external
    view
    returns (
      uint256 totalTokensIssued
    );

  function transfer(
    address to,
    uint256 value
  )
    external
    returns (
      bool success
    );

  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  )
    external
    returns (
      bool success
    );

  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    external
    returns (
      bool success
    );

}

// VRF ID BASE
contract VRFRequestIDBase {

  function makeVRFInputSeed(
    bytes32 _keyHash,
    uint256 _userSeed,
    address _requester,
    uint256 _nonce
  )
    internal
    pure
    returns (
      uint256
    )
  {
    return uint256(keccak256(abi.encode(_keyHash, _userSeed, _requester, _nonce)));
  }

  function makeRequestId(
    bytes32 _keyHash,
    uint256 _vRFInputSeed
  )
    internal
    pure
    returns (
      bytes32
    )
  {
    return keccak256(abi.encodePacked(_keyHash, _vRFInputSeed));
  }
}

// VRF COSUMER BASE
abstract contract VRFConsumerBase is VRFRequestIDBase {


    function fulfillRandomness(bytes32 requestId,uint256 randomness) internal virtual;
    
    
    uint256 constant private USER_SEED_PLACEHOLDER = 0;

    function requestRandomness(bytes32 _keyHash,uint256 _fee) internal returns (bytes32 requestId)
    {
      LINK.transferAndCall(vrfCoordinator, _fee, abi.encode(_keyHash, USER_SEED_PLACEHOLDER));
      uint256 vRFSeed  = makeVRFInputSeed(_keyHash, USER_SEED_PLACEHOLDER, address(this), nonces[_keyHash]);
      nonces[_keyHash] = nonces[_keyHash] + 1;
      return makeRequestId(_keyHash, vRFSeed);
    }
  
    function transferLinkTokens(address to, uint256 amount) internal 
    {
        LINK.transfer(to, amount);
    }

    LinkTokenInterface immutable internal LINK;
    address immutable private vrfCoordinator;


    mapping(bytes32 /* keyHash */ => uint256 /* nonce */) private nonces;


    constructor(address _vrfCoordinator,address _link) 
    {
        vrfCoordinator = _vrfCoordinator;
        LINK = LinkTokenInterface(_link);
    }


    function rawFulfillRandomness(bytes32 requestId, uint256 randomness) external
    {
        require(msg.sender == vrfCoordinator, "Only VRFCoordinator can fulfill");
        fulfillRandomness(requestId, randomness);
    }
}


//PREDICTIONS
contract CandleGenieMemeRage is Ownable, Pausable, ReentrancyGuard, VRFConsumerBase 
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
        uint256 vrfRequestId;
        uint256 vrfRandomness;
        bool closed;
        bool cancelled;
        address[] players;
    }

    struct Bet {
        Position position;
        uint256 amount;
        bool claimed;
    }
    
    struct SlotItem {
        string name;
        bool active;
    }
    

    // Mappings
    mapping(uint256 => Round) public Rounds;
    mapping(uint256 => mapping(address => Bet)) public Bets;
    mapping(address => uint256[]) public UserBets;
    SlotItem[] private SlotItems;  
 
    // Current Round
    uint256 public currentEpoch;  
    uint256[3] internal nextSlotItems;

    // Defaults
    uint256 public rewardRate = 90; 
    uint256 public drawDuration = 3 minutes;
    uint256 public minBetAmount = 0.01 ether;
    uint256 public drawTresholdAmount = 0.5 ether;

    // Events
    event InjectFunds(address indexed sender);
    event MinBetAmountUpdated(uint256 indexed epoch, uint256 minBetAmount);
    event DrawTresholdAmountUpdated(uint256 drawTresholdAmount);
    event DrawDurationUpdated(uint256 drawDuration);
    event RewardRateUpdated(uint256 rewardRate);
    event GamePaused(uint256 indexed epoch);
    event GameUnpaused(uint256 indexed epoch);
    event RoundStarted(uint256 indexed epoch);
    event RoundEnded(uint256 indexed epoch, uint256 result, uint256 vrfRequestId, uint256 vrfRandomness);
    event RoundCancelled(uint256 indexed epoch);
    event RewardsCalculated(uint256 indexed epoch, uint256 rewardBaseCalAmount, uint256 rewardAmount);
    event Entered(address indexed sender, uint256 indexed epoch, uint256 slot, uint256 amount);
    event Claimed(address indexed sender, uint256 indexed epoch, uint256 amount);
 
    receive() external payable {}

    bytes32 internal vrfKeyHash;
    uint256 internal vrfFee;

    constructor() 
        VRFConsumerBase(
            0x747973a5A2a4Ae1D3a8fDF5479f1514F65Db9C31, // VRF Coordinator
            0x404460C6A5EdE2D891e8297795264fDe62ADBB75  // LINK Token
        )
    {
        vrfKeyHash = 0xc251acd21ec4fb7f31bb8868288bfdbaeb4fbfec2df3735ddbd4f7dc8d60103c;
        vrfFee = 0.2 * 10 ** 18; // 0.2 LINK  
    }

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
    
    
    // VRF FALLBACK ---------------->
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override 
    {
        if (randomness > 0)
        {
            uint256 random = randomness % 3 + 1;
                            
            Round storage round = Rounds[currentEpoch];
            round.vrfRequestId = uint256(requestId);
            round.vrfRandomness = randomness;

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

            round.drawTimestamp = uint32(block.timestamp);
            round.closed = true;
        
            // Calculating Rewards
            _calculateRewards(currentEpoch);                                                            
        
            // Event
            emit RoundEnded(currentEpoch, random, uint256(requestId), randomness);

            // Epoch Increment
            currentEpoch = currentEpoch + 1;                                                                
      
            // New Round
            _safeStartRound(currentEpoch, nextSlotItems[0], nextSlotItems[1], nextSlotItems[2]);  

        }
    }

    // OWNER CALLS ---------------->

    function FundsInject() external payable onlyOwner 
    {
        emit InjectFunds(msg.sender);
    }
    
    function FundsExtract(uint256 value) external onlyOwner 
    {
        _safeTransferBNB(payable(owner()),  value);
    }

    function TransferLink(address to, uint256 amount) external onlyOwner {
        transferLinkTokens(to, amount);
    }
    
    function UpdateVRFKeyHash(bytes32 _keyHash) external onlyOwner {
        vrfKeyHash = _keyHash;
    }

    function UpdateVRFFee(uint256 _fee) external onlyOwner {
        vrfFee = _fee;
    }
    
    function GamePause() public onlyOwner whenNotPaused 
    {
        _pause();
        emit GamePaused(currentEpoch);
    }

    function GameResume() public onlyOwner whenPaused 
    {
        _unpause();
        emit GameUnpaused(currentEpoch);
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

    function RoundStart(uint256 slot1,  uint256 slot2,  uint256 slot3) external onlyOwner whenNotPaused 
    {
        currentEpoch = currentEpoch + 1;
        _safeStartRound(currentEpoch, slot1, slot2, slot3);
    }

    function SlotItemAdd(string memory name) external onlyOwner 
    {
        SlotItem memory item;
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


    function RoundExecute(uint256 epoch, uint256 nextSlot1, uint256 nextSlot2, uint256 nextSlot3) external onlyOwner whenNotPaused returns (uint256 requestId) 
    {

        require(Rounds[epoch].drawTresholdTimestamp > 0, "Round not reached to draw treshold");
        require(uint32(block.timestamp - Rounds[epoch].drawTresholdTimestamp) <= 0, "Can only end round after end draw duration");
  

        // Next Slot Items Assign
        nextSlotItems[0] = nextSlot1;
        nextSlotItems[1] = nextSlot2;
        nextSlotItems[2] = nextSlot3;
        
        // VRF CALL
        return uint256(requestRandomness(vrfKeyHash, vrfFee));
   
    }

    function RoundCancel(uint256 epoch, bool cancelled, bool closed) external onlyOwner 
    {
        _safeCancelRound(epoch, cancelled, closed);
    }


    // INTERNAL FUNCTIONS ---------------->
    
    function _safeTransferBNB(address payable to, uint256 amount) internal 
    {
        to.transfer(amount);
    }

    function _safeStartRound(uint256 epoch, uint256 slot1,  uint256 slot2,  uint256 slot3) internal 
    {
        
        require(SlotItems.length > 3, "Not enough slot items to start round");
        
        Round storage round = Rounds[epoch];
        round.slotItems[0] = SlotItems[slot1];
        round.slotItems[1] = SlotItems[slot2];
        round.slotItems[2] = SlotItems[slot3];
        round.openTimestamp = uint32(block.timestamp);
        round.epoch = epoch;

        emit RoundStarted(epoch);
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

    function _safeCancelRound(uint256 epoch, bool cancelled, bool closed) internal 
    {
        Round storage round = Rounds[epoch];
        round.cancelled = cancelled;
        round.closed = closed;
        emit RoundCancelled(epoch);
    }


     // USER CALLS ---------------->

    function Enter(uint256 epoch, uint256 slot) external payable whenNotPaused nonReentrant notContract 
    {
        require(epoch == currentEpoch, "Bet is too early/late");
       
        if (Rounds[epoch].drawTresholdTimestamp > 0)
        {
            require(uint32(block.timestamp - Rounds[epoch].drawTresholdTimestamp) <= drawDuration, "Round has locked");
        }
       

        require(slot == 1 || slot == 2 || slot == 3, "Invalid slot");
        require(msg.value >= minBetAmount, "Bet amount must be greater than minBetAmount");
        require(Bets[epoch][msg.sender].amount == 0, "Can only bet once per round");
  

        uint256 amount = msg.value;
        Round storage round = Rounds[epoch];
        Bet storage bet = Bets[epoch][msg.sender];

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

        // Push Bet
        bet.amount = amount;
        UserBets[msg.sender].push(epoch);

        emit Entered(msg.sender, currentEpoch, slot, amount);
    }
    

    function Claim(uint256[] calldata epochs) external nonReentrant notContract 
    {
            
        uint256 rewardTotal; // Initializes reward

        for (uint256 i = 0; i < epochs.length; i++) 
        {
            
            uint256 addedReward = 0;

            // Round valid, claim rewards
            if (Rounds[epochs[i]].closed) 
            {
                require(claimable(epochs[i], msg.sender), "Not eligible for claim");
                Round memory round = Rounds[epochs[i]];
                addedReward = (Bets[epochs[i]][msg.sender].amount * round.rewardAmount) / round.rewardBaseCalAmount;
            }

            if (Rounds[epochs[i]].cancelled) 
            {
                require(refundable(epochs[i], msg.sender), "Not eligible for refund");
                addedReward = Bets[epochs[i]][msg.sender].amount;
            }

            Bets[epochs[i]][msg.sender].claimed = true;
            rewardTotal += addedReward;

            emit Claimed(msg.sender, epochs[i], addedReward);
        }

        if (rewardTotal > 0) 
        {
            _safeTransferBNB(payable(msg.sender), rewardTotal);
        }
        
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