/**
 *Submitted for verification at BscScan.com on 2022-01-31
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.9;
pragma experimental ABIEncoderV2;
/**
 * @title EtherSniper Game Contract
 * @dev Store & Retrieve EtherSniper Game data
 */

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


/**
 * @dev `EtherSniper` token interface
 */
interface ETSInterface {
    function approve(
        address spender, 
        uint256 amount
    ) external returns (bool success);
    
    function transfer(
        address recipient, 
        uint256 amount
    ) external returns (bool);
    
    function transferFrom(
        address sender, 
        address recipient, 
        uint256 amount
    ) external returns (bool);
}

/**
 * @dev Room Information struct. 
 * It will contains betting racing room information
 */ 
struct Room {
    uint256 betAmount;
    uint256 memberCount;
    uint256 roomStatus;
    string name;
    address winner;
    address creator;
    mapping(address => uint256) members;
}

/**
 * @dev Player Information Struct.
 * It will save player's Information detail.
 */

struct PlayerInfo {
    string playerName;
    uint256 playerLevel;
    uint256 playerExp;
    uint256[] playerWeapons;
}

/**
 * @dev Weapon Information struct.
 */

struct WeaponInfo {
    uint256 weaponPrice;
    bool    weaponUsable;
}

contract Ownable {
    address public owner;
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    
    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
    constructor() {
        owner = msg.sender;
    }
    
    
    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

/**
 * @dev Basic game contract.
 * It will manage point that will use in the game token, point.
 */
contract Game {
    // Game Token address.
    address public tokenAddress = 0x8b854973A6d35d85C364bb0D151BBDcf64BD8172;

    /**
     * @dev Game  wallet for the game rooms.
     * All earnings from game goes here
     */
    address public gameWallet = 0xF1CBd8CC86bCEcd2C5b900d8B20932eB0f4d15CA;
    address public tempGameWallet = 0xF1CBd8CC86bCEcd2C5b900d8B20932eB0f4d15CA;
    
    // Mapping of player point
    mapping(address => uint256) public userPoint;    

    // Point buy rate
    uint256 public pointBuyRate = 1000; // 1:1

    // Point sell rate
    uint256 public pointSellRate = 1000; // 1:1
}

/**
 * @dev Room Game Contract.
 * It will manage rooms of the game - Create, Join, Finish, ClaimReward 
 */

contract RoomGame is Ownable, Game {
    using SafeMath for uint256;

    // Array of Rooms 
    mapping(uint256 => Room) public rooms;

    // Array of members in a room
    mapping(uint256 => address[]) public members;

    // Array of rooms of a user
    mapping(address => uint256[]) public userRooms;

    // Array of created rooms of a user
    mapping(address => uint256[]) public creatorRooms;
            
    // Owner Fee for From pool amount
    uint256 public ownerFee = 300 ; // 30% Fee

    // Array of Room IDs
    uint256[] public roomsIds; 
    
    // Pool Colleced for a room
    mapping(uint256 => uint256) public poolcollected;

    // Room functions
    function createRoom(uint256 _pointAmount) public {
        require(userPoint[msg.sender] >= _pointAmount);
        userPoint[msg.sender] = userPoint[msg.sender].sub(_pointAmount);
        userPoint[tempGameWallet] = userPoint[tempGameWallet].add(_pointAmount);

        uint256 id = roomsIds.length; 
        roomsIds.push(id);
        rooms[id].betAmount = _pointAmount;
        rooms[id].memberCount = 1;
        rooms[id].roomStatus = 0;           // Room opened for join.
        rooms[id].creator = msg.sender;
        rooms[id].members[msg.sender] = 1;  // Joined Room
        
        userRooms[msg.sender].push(id); 
        creatorRooms[msg.sender].push(id); 
    }
    
    // Retrieve last created room id.
    function retrieveRoomId() public view returns (uint256) {
        return creatorRooms[msg.sender][creatorRooms[msg.sender].length - 1];
    }

    // Join room with room id
    function joinRoom(uint256 _id) public  {
        require(userPoint[msg.sender] >= rooms[_id].betAmount);

        require(rooms[_id].roomStatus == 0, "Room is not opened.");
        require(rooms[_id].members[msg.sender] != 1, "Already a member");
        userPoint[msg.sender] = userPoint[msg.sender].sub(rooms[_id].betAmount);
        userPoint[tempGameWallet] = userPoint[tempGameWallet].add(rooms[_id].betAmount);
        rooms[_id].memberCount += 1;
        rooms[_id].members[msg.sender] = 1; //Joined Room
        userRooms[msg.sender].push(_id); 
    }
    
    // Start room with room id
    function startRoom(uint256 _id, address[] memory roomMembers) public {
        require(rooms[_id].roomStatus == 0, "Room is not opened.");
        
        for(uint i = 0; i < roomMembers.length; i++) {
            require(rooms[_id].members[roomMembers[i]] == 1);
        }
        
        for(uint i = 0; i < roomMembers.length; i++) {
            rooms[_id].members[roomMembers[i]] = 2;     // Players are in the game room. Points are locked.
        }
        
        rooms[_id].roomStatus = 1;          // Room closed for join. But not finished yet.
     
        poolcollected[_id] = rooms[_id].betAmount.mul(roomMembers.length);
    }
    
    // Finish room with id and winner address   
    function finishRoom(uint256 _id, address _winner) public onlyOwner {
        require(rooms[_id].roomStatus == 1, "Room not closed");

        uint256 _fee = poolcollected[_id].mul(ownerFee).div(1000); 
        uint256 _amt = poolcollected[_id]; 

        if(_fee > 0 ){
            _amt = _amt.sub(_fee); 
        }

        userPoint[gameWallet] = userPoint[gameWallet].add(_fee);
        userPoint[_winner] = userPoint[_winner].add(_amt);
        
        rooms[_id].winner = msg.sender;
        rooms[_id].roomStatus = 2;
        poolcollected[_id] = 0 ;
    }
    
    function claimPoint() public {
        uint256 claimAmount = 0;
        for(uint i = 0;i < userRooms[msg.sender].length; i++) {
            if(rooms[userRooms[msg.sender][i]].members[msg.sender] == 1) {  // 
                claimAmount += rooms[userRooms[msg.sender][i]].betAmount;
                rooms[userRooms[msg.sender][i]].members[msg.sender] = 3;    // Claimed unlocked points.
            }
        }
        
        userPoint[tempGameWallet] = userPoint[tempGameWallet].sub(claimAmount);
        userPoint[msg.sender] = userPoint[msg.sender].add(claimAmount);
    }
}

contract EtherSniper is RoomGame {
    using SafeMath for uint256;

    // Mapping of Player Information
    mapping(address => PlayerInfo) public playerInfo;
    
    // Array of Weapon Price Information
    WeaponInfo[] weaponInfo;

    // ETS Token Interface
    ETSInterface public ETS = ETSInterface(tokenAddress);
    
    /**
     * @dev Initializes the contract information and setting the deployer as the initial owner.
     */
    constructor() {
        owner = msg.sender;
    }
    
    // Purchase point with ETS token
    function purchasePoint(uint256 _tokenAmount) public {
        require(ETS.transferFrom(msg.sender, address(this), _tokenAmount.mul(1e18)));
        
        userPoint[msg.sender] += _tokenAmount.mul(pointBuyRate).div(1000);
    }
    
    // Sell point for ETS Token
    function sellPoint(uint256 _amount) public {
        require(userPoint[msg.sender] >= _amount);
        
        uint256 tokenAmount = _amount.mul(1000).div(pointSellRate).mul(1e18);
        
        require(ETS.transfer(msg.sender, tokenAmount));
        
        userPoint[msg.sender] = userPoint[msg.sender].sub(_amount);
    }
    
    // Retrieve point
    function retrievePoint() public view returns(uint256){
        return userPoint[msg.sender];
    }

    // Retrieve Point Buy / Sell Rate
    function retrievePointRate() public view returns(uint256, uint256) {
        return (pointBuyRate, pointSellRate);        
    }
    
    // Retrieve Weapon information
    function retrieveWeaponInfo() public view returns(WeaponInfo[] memory) {
        return weaponInfo;
    }

    // Retrieve Player Information
    function retrievePlayerInfo() public view returns(PlayerInfo memory) {
        return playerInfo[msg.sender];
    }
    
    // Purchase weapon with point
    function purchaseWeaponWithPoint(uint256 _weaponId) public {
        require(weaponInfo.length > _weaponId, "No such weapon");
        require(weaponInfo[_weaponId].weaponUsable, "Not usable weapon");
        
        uint256 price = weaponInfo[_weaponId].weaponPrice;
        require(userPoint[msg.sender] >= price, "No enough point");
        
        for(uint i = 0; i < playerInfo[msg.sender].playerWeapons.length; i++) {
            require(playerInfo[msg.sender].playerWeapons[i] != _weaponId, "Already Purchased");
        }
        
        userPoint[msg.sender] = userPoint[msg.sender].sub(price);
        playerInfo[msg.sender].playerWeapons.push(_weaponId);
    }
    
    // Purchase weapon with token
    function purchaseWeaponWithToken(uint256 _weaponId) public {
        require(weaponInfo.length > _weaponId, "No such weapon");
        require(weaponInfo[_weaponId].weaponUsable, "Not usable weapon");

        uint256 price = weaponInfo[_weaponId].weaponPrice;
        uint256 tokenAmount = price.mul(pointSellRate).div(1000);

        for(uint i = 0; i < playerInfo[msg.sender].playerWeapons.length; i++) {
            require(playerInfo[msg.sender].playerWeapons[i] != _weaponId, "Already Purchased");
        }
        
        require(ETS.transferFrom(msg.sender, address(this), tokenAmount.mul(1e18)));
        
        playerInfo[msg.sender].playerWeapons.push(_weaponId);
    }

    // Admin functions
    function updatePointBuyRate(uint256 _rate) public onlyOwner {
        pointBuyRate = _rate;
    }
    
    function updatePointSellRate(uint256 _rate) public onlyOwner {
        pointSellRate = _rate;
    }
    
    function addWeapon(uint256 price) public onlyOwner {
        WeaponInfo memory newWeapon;
        newWeapon.weaponPrice = price;
        newWeapon.weaponUsable = true;
        weaponInfo.push(newWeapon);
    }
    
    function updateWeaponPrice(uint256 weaponId, uint256 price) public onlyOwner {
        weaponInfo[weaponId].weaponPrice = price;
    }
    
    function updateWeaponUsable(uint256 weaponId, bool usable) public onlyOwner {
        weaponInfo[weaponId].weaponUsable = usable;
    }
}