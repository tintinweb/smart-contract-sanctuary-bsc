/**
 *Submitted for verification at BscScan.com on 2022-10-26
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;


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
     
                                                                              
                                                                     🕹 CG CHAIN ROUTER 🕹
                                                                              
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


//CHAIN ROUTER
contract CandleGenieChainRouter is Ownable, Pausable, ReentrancyGuard 
{

    struct Game {
        string name;
        uint256 fee;
        uint256 currentRound;
        bool active;
    }

   struct Entry {
        uint256 game;
        uint256 round;
        uint256 amount;
        uint256 reward;
        uint32 entryTimestamp;
        uint32 closeTimestamp;
        uint32 claimTimestamp;
        uint32[] resultData;
        bool claimed;
        bool cancelled;
    }

    struct Result {
        address user;
        uint256 game;
        uint256 round;
        uint256 reward;
        uint32[] resultData;
    }

    struct User {
        address wallet;
        uint256 latestEpoch;
        uint256 paidRewardsCount;
        uint256 paidRewardsTotal;
    }

    uint256 internal paidRewardsCount;
    uint256 internal paidRewardsTotal;

    // MAPPINGS ---------------->
    mapping(uint256 => Game) public Games;
    mapping(uint256 => mapping(uint256 => mapping(address => Entry))) public Entries;
    mapping(uint256 => mapping(address => uint256[])) public UserEntries;
    mapping(address => User) public Users;
    mapping(uint256 => mapping(uint256 => bool)) public CancelledRounds;

    // INTERNALS ---------------->
    function _isContract(address addr) internal view returns (bool) 
    {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
    
    function _safeTransferBNB(address to, uint256 value) internal 
    {
        (bool success,) = to.call{value: value}("");
        require(success, "Transfer Failed");
    }

    // MODIFIERS ---------------->
    modifier notContract() 
    {
        require(!_isContract(msg.sender), "contract not allowed");
        require(msg.sender == tx.origin, "proxy contract not allowed");
        _;
    }

    // EVENTS ---------------->
    event FundsInjected(address indexed sender);
    event RoundEntered(address indexed sender,  uint256 indexed game, uint256 indexed round, uint256 amount);
    event RoundCancelled(address indexed sender,  uint256 indexed game, uint256 indexed round);
    event Claimed(address indexed sender, uint256 indexed round, uint256 amount);
    event Refunded(address indexed sender, uint256 indexed round, uint256 amount);

    // EXTERNALS ---------------->
    function FundsInject() external payable onlyOwner {emit FundsInjected(msg.sender);}
    function FundsExtract(uint256 value) external onlyOwner {_safeTransferBNB(_owner,  value);}

    function InstallGame(uint256 ID, string memory name, uint256 fee, uint256 currentRound, bool active) external onlyOwner 
    {
        Game storage game = Games[ID];
        game.name = name;
        game.fee = fee;
        game.currentRound = currentRound;
        game.active = active;
    }

    function Enter(uint256 game, uint256 round) external payable whenNotPaused nonReentrant notContract 
    {

        require(bytes(Games[game].name).length != 0, "Game not found");
        require(Games[game].active, "Game is not active");
        require(round >= Games[game].currentRound + 1, "Wrong round number!");
        require(msg.value >= Games[game].fee, "Amount must be equal to game fee");
        require(Entries[game][round][msg.sender].amount <= 0, "You have already entered this round");

        uint256 amount = msg.value;
     
        // Entry
        Entry storage entry = Entries[game][round][msg.sender];
        entry.game = game;
        entry.round = round;
        entry.entryTimestamp = uint32(block.timestamp);
        entry.amount = amount;

        // User
        UserEntries[game][msg.sender].push(round);  

        // Event
        emit RoundEntered(msg.sender,  game, round, amount);
    
    }
    
    function Claim(uint256 game, uint256[] calldata rounds) external nonReentrant notContract 
    {
            
        uint256 amountToClaim; 

        for (uint256 i = 0; i < rounds.length; i++) 
        {
            Entry storage entry = Entries[game][rounds[i]][msg.sender];

            // Reward
            if (entry.reward > 0 && entry.cancelled == false) 
            {
                if (entry.claimed == false)
                {
                    uint256 rewardAmount =  entry.reward;
                    // Mark
                    entry.claimed = true;
                    entry.claimTimestamp = uint32(block.timestamp);
                    // Sum
                    amountToClaim += entry.reward;
                    //User
                    Users[msg.sender].paidRewardsCount++;
                    Users[msg.sender].paidRewardsTotal += rewardAmount;
                    //Stats
                    paidRewardsCount++;
                    paidRewardsTotal += rewardAmount;
                    // Emit
                    emit Claimed(msg.sender, rounds[i], rewardAmount);
                }
            }

            // Refund
            if (entry.amount > 0 && CancelledRounds[game][rounds[i]] == true) 
            {
                if (entry.claimed == false)
                {
                    uint256 refundAmount = entry.amount;
                    // Mark
                    entry.claimed = true;
                    entry.claimTimestamp = uint32(block.timestamp);
                    // Sum
                    amountToClaim += refundAmount;
                    //User
                    Users[msg.sender].paidRewardsCount++;
                    Users[msg.sender].paidRewardsTotal += refundAmount;
                    //Stats
                    paidRewardsCount++;
                    paidRewardsTotal += refundAmount;
                    // Emit
                    emit Refunded(msg.sender, rounds[i], refundAmount);
                }
            }

        }

        require(amountToClaim > 0, "Not found any eligible reward/refund funds");

        if (amountToClaim > 0) 
        {
            _safeTransferBNB(payable(msg.sender), amountToClaim);
        }
        
    }


    function EndRound(uint256 game, uint256 round, Result[] memory results) external onlyOwner 
    {
        //Game
        Game storage _game = Games[game];
        _game.currentRound = round;

        //Entries
        for (uint i = 0; i < results.length; i++) {
            Entry storage entry = Entries[game][round][results[i].user];
            entry.reward = results[i].reward;
            entry.closeTimestamp = uint32(block.timestamp);
            entry.resultData = results[i].resultData;
        }
    }

    function CancelRound(uint256 game, uint256 round) external onlyOwner 
    {
        CancelledRounds[game][round] = true;
        emit RoundCancelled(msg.sender, game, round);
    }


    function getUserEntries(uint256 game, address user, uint256 cursor, uint256 size) external view returns (uint256[] memory, Entry[] memory, uint256)
    {
        uint256 length = size;

        if (length > UserEntries[game][user].length - cursor) 
        {
            length = UserEntries[game][user].length - cursor;
        }

        uint256[] memory rounds = new uint256[](length);
        Entry[] memory entries = new Entry[](length);
    
        for (uint256 i = 0; i < length; i++) 
        {
            rounds[i] = UserEntries[game][user][cursor + i];
            entries[i] = Entries[game][rounds[i]][user];
        }

        return (rounds, entries, cursor + length);
    }
    
    function getUserEntryLength(uint256 game, address user) external view returns (uint256) {
        return UserEntries[game][user].length;
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