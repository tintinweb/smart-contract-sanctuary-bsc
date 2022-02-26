/**
 *Submitted for verification at BscScan.com on 2022-02-26
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
     
                                                                              
                                                                        KILL THE BOSS 2.0
                                                                              
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

//REFEREE
abstract contract CandleGenieKillTheBossReferee
{
    function Resolve(uint256 id, uint256 maxRewardMultiplier) external virtual; 
}


contract CandleGenieKillTheBoss is Ownable, ReentrancyGuard 
{
    
    enum Status {Idle, Punching , Impacted, Refunded}

    struct Punch 
    {
        address user;
        uint256 id;
        uint256 punchTimestamp;
        uint256 impactTimestamp;
        uint256 punchAmount;
        uint256 rewardAmount;
        bool paid;
        Status status;
    }

    struct Stat 
    {
        uint256 punchesCount;
        uint256 punchesTotal;
        uint256 paidPunchesCount;
        uint256 paidPunchesTotal;
    }
    
    mapping(uint256 => Punch) public Punches;
    mapping(address => Stat) public UserStats;
    mapping(address => uint256[]) public UserPunches;

  
    uint256 public currentPunchIndex;
    uint256 public maxRewardMultiplier = 400; // 400%
    uint256 public minimumAmount = 0.01 ether;
    uint256 public maximumAmount = 10000 ether;

    // Stats
    uint256 internal punchesCount;
    uint256 internal punchesTotal;
    uint256 internal paidPunchesCount;
    uint256 internal paidPunchesTotal;


    CandleGenieKillTheBossReferee internal refereeContract;

    event PunchEvent(address indexed sender, uint256 indexed id, uint256 timestamp, uint256 punchAmount);
    event ImpactEvent(address indexed sender, uint256 indexed id, uint256 punchTimestamp, uint256 punchAmount, uint256 ImpactTimestamp, uint256 rewardAmount);
    event RefundEvent(uint256 indexed id, address user);
    event MinimumAmountUpdatedEvent(uint256 minimumAmount);
    event MaximumAmountUpdatedEvent(uint256 maximumAmount);

    // MODIFIERS
    modifier notContract() 
    {
        require(!_isContract(msg.sender), "Contracts not allowed");
        require(msg.sender == tx.origin, "Proxy contracts not allowed");
        _;
    }

    modifier onlyReferreeContract() 
    {
        require(msg.sender == address(refereeContract), "Only referree contract allowed");
        _;
    }

    receive() external payable {}

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

    // EXTERNAL FUNCTIONS ---------------->
    
    function FundsInject() external payable onlyOwner {}
    
    function FundsExtract(uint256 value) external onlyOwner 
    {
        _safeTransferBNB(payable(owner()),  value);
    }

    function SetMaxRewardMultiplier(uint8 _maxRewardMultiplier) external onlyOwner 
    {
        maxRewardMultiplier = _maxRewardMultiplier;
    }

    function SetMinimumAmount(uint256 _minimumAmount) external onlyOwner 
    {
        minimumAmount = _minimumAmount;
        emit MinimumAmountUpdatedEvent(minimumAmount);
    }

    function SetMaximumAmount(uint256 _maximumAmount) external onlyOwner 
    {
        maximumAmount = _maximumAmount;
        emit MaximumAmountUpdatedEvent(maximumAmount);
    }

    function SetReferee(address _refereeAddress) external onlyOwner 
    {
        refereeContract = CandleGenieKillTheBossReferee(_refereeAddress);
    }

    function RefundPunch(uint256 id) external onlyOwner
    {
        require(Punches[id].punchAmount != 0, "Punch not found");  

        Punch storage punch = Punches[id];
        punch.status = Status.Refunded;
        punch.paid = true;

        _safeTransferBNB(payable(punch.user), punch.punchAmount);

        emit RefundEvent(punch.id, punch.user);
   
    }
    
    function MakePunch() external payable nonReentrant notContract
    {
        require(msg.value >= minimumAmount, "Punch amount must be greater than minimum amount");
        require(msg.value <= maximumAmount, "Punch amount must be less than maximum amount");

        // Punch
        address user = msg.sender;
        uint256 amount = msg.value;
        _safePunch(user, amount);
    }

    function _safePunch(address user, uint256 amount) internal
    {
        
        // Storing Punch
        Punch storage punch = Punches[currentPunchIndex];
        punch.user = user;
        punch.id = currentPunchIndex;
        punch.punchTimestamp = block.timestamp;
        punch.punchAmount = amount;
        punch.status = Status.Punching;

        UserPunches[user].push(currentPunchIndex);
            
        // ID ++
        currentPunchIndex++;
        
        // User Stats
        UserStats[user].punchesCount++;
        UserStats[user].punchesTotal += amount;

        // Global Stats
        punchesCount++;
        punchesTotal += amount;

        // Emit Event
        emit PunchEvent(user, punch.id, punch.punchTimestamp, punch.punchAmount);

        // Referee
        refereeContract.Resolve(punch.id, maxRewardMultiplier); 

    }

        
    // FALLBACK  ------------------->
    
    function Impact(uint256 id, uint256 reward) external onlyReferreeContract
    {
       
        require(Punches[id].punchAmount != 0, "Punch not found");

        Punch storage punch = Punches[id];
        punch.impactTimestamp = block.timestamp;
        punch.status = Status.Impacted;
     
        // Payment 
        if (reward > 0)
        {
            _safeTransferBNB(payable(punch.user), reward);
            punch.rewardAmount = reward;
            punch.paid = true;

            // User Stats
            UserStats[punch.user].paidPunchesCount++;
            UserStats[punch.user].paidPunchesTotal += reward;

            // Global Stats
            paidPunchesCount++;
            paidPunchesTotal += reward;

        }
        
        emit ImpactEvent(address(this), punch.id, punch.punchTimestamp, punch.punchAmount, punch.impactTimestamp, punch.rewardAmount);

    }

    function getUserPunches(address user, uint256 cursor, uint256 size) external view returns (uint256[] memory, Punch[] memory, uint256)
    {
        uint256 length = size;

        if (length > UserPunches[user].length - cursor) 
        {
            length = UserPunches[user].length - cursor;
        }

        uint256[] memory values = new uint256[](length);
        Punch[] memory userPunches = new Punch[](length);

        for (uint256 i = 0; i < length; i++) 
        {
            values[i] = UserPunches[user][cursor + i];
            userPunches[i] = Punches[values[i]];
        }

        return (values, userPunches, cursor + length);
    }

    function getUserPunchesLength(address user) external view returns (uint256) {
        return UserPunches[user].length;
    }
    
    function getPunch(uint256 id) external view returns (Punch memory)
    {
        return Punches[id];
    }

    function getStats() external view returns (uint256, uint256, uint256, uint256) {
        return (punchesCount, punchesTotal, paidPunchesCount, paidPunchesTotal);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }


}