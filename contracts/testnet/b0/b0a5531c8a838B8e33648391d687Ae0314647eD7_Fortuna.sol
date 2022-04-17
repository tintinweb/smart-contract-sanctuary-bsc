/**
 *Submitted for verification at BscScan.com on 2022-04-16
*/

pragma solidity  0.6.0;

contract Fortuna {
    
    struct User {
        uint id;
        address referrer;
        uint partnersCount;
        
        mapping(uint8 => bool) activeX3Levels;
        
        mapping(uint256 => uint256) activeCycleLevels;

        mapping(uint256 => uint256) activeEndedCycleLevels;

        mapping(uint8 => X3) x3Matrix;
    }
    
    

    struct X3 {
        address currentReferrer;
        address[] referrals;
        bool blocked;
        uint reinvestCount;
    }
    
     

    uint8 public constant LAST_LEVEL = 16;
    
    mapping(address => User) public users;
    mapping(uint => address) public idToAddress;
    mapping(uint => address) public userIds; 
    mapping(address => uint) public balances; 

    uint public lastUserId = 2;
    address public owner;
    
    mapping(uint8 => uint) public levelPrice;
    address public marketing_address;
    address public  lottery_address;
    event Registration(address indexed user, address indexed referrer, uint indexed userId, uint referrerId);
    event Reinvest(address indexed user, address indexed currentReferrer, address indexed caller, uint8 matrix, uint8 level);
    event Upgrade(address indexed user, address indexed referrer, uint8 matrix, uint8 level);
    event NewUserPlace(address indexed user, address indexed referrer, uint8 matrix, uint8 level, uint8 place);
    event MissedEthReceive(address indexed receiver, address indexed from, uint8 matrix, uint8 level);
    event SentExtraEthDividends(address indexed from, address indexed receiver, uint8 matrix, uint8 level);
    
    
    constructor() public {
        levelPrice[1] = 0.05 ether;
        levelPrice[2] = 0.07 ether;
        levelPrice[3] = 0.1 ether;
        levelPrice[4] = 0.14 ether;
        levelPrice[5] = 0.2 ether;
        levelPrice[6] = 0.28 ether;
        levelPrice[7] = 0.4 ether;
        levelPrice[8] = 0.55 ether;
        levelPrice[9] = 0.8 ether;
        levelPrice[10] = 1.1 ether;
        levelPrice[11] = 1.6 ether;
        levelPrice[12] = 2.2 ether;
        levelPrice[13] = 3.2 ether;
        levelPrice[14] = 4.4 ether;
        levelPrice[15] = 6.5 ether;
        levelPrice[16] = 8 ether;

        address ownerAddress = msg.sender;
        owner = ownerAddress;

       
        

        marketing_address = ownerAddress;
        lottery_address = ownerAddress;

        User memory user = User({
            id: 1,
            referrer: address(0),
            partnersCount: uint(0)
          //  activeCycleLevels: [16]: uint(2)
        });
        
        users[ownerAddress] = user;
        idToAddress[1] = ownerAddress;
        
        for (uint8 i = 1; i <= LAST_LEVEL; i++) {
            users[ownerAddress].activeX3Levels[i] = true;
        }
        
        userIds[1] = ownerAddress;
        users[ownerAddress].activeCycleLevels[16] = 2;
        
    }
    
    function recieve() external payable {
        if(msg.data.length == 0) {
            return registration(msg.sender, owner);
        }
        
        registration(msg.sender, bytesToAddress(msg.data));
    }

    function registrationExt(uint256 userid) external payable {
        address referrerAddress;
        if( idToAddress[userid] != 0x0000000000000000000000000000000000000000 ){
            referrerAddress = idToAddress[userid];
        }else{ 
            referrerAddress = idToAddress[1];
        }

        registration(msg.sender, referrerAddress);
    }

   

    
    
    function buyNewLevel( uint8 level) external payable {
        require(isUserExists(msg.sender), "user is not exists. Register first.");
        
        require(msg.value == levelPrice[level], "invalid price");
        require(level > 1 && level <= LAST_LEVEL, "invalid level");
        require(users[msg.sender].activeEndedCycleLevels[level]<4, "buy higher level");
           
        if(level>1){
             for (uint256 levelc = level; levelc >0 ; levelc--) {
                users[msg.sender].activeEndedCycleLevels[levelc]=0;
             }   
        }
        require(!users[msg.sender].activeX3Levels[level], "level already activated");

        

            if (users[msg.sender].x3Matrix[level-1].blocked) {
                users[msg.sender].x3Matrix[level-1].blocked = false;
            }
    
            address freeX3Referrer = findFreeX3Referrer(msg.sender, level);
            users[msg.sender].x3Matrix[level].currentReferrer = freeX3Referrer;
            users[msg.sender].activeX3Levels[level] = true;
            updateX3Referrer(msg.sender, freeX3Referrer, level);
            
            //address(marketing_address).transfer(msg.value * 20 / 100);
            
            payable(marketing_address).transfer(msg.value * 75 / 1000);
            payable(lottery_address).transfer(msg.value * 200 / 100);

            address random_ref = idToAddress[getRandomUserByLevel(level)]; 
            payable(random_ref).transfer(msg.value * 665 / 1000);

            users[random_ref].activeCycleLevels[level]--;
            users[random_ref].activeEndedCycleLevels[level]++;

           

            users[msg.sender].activeCycleLevels[level] = 2;


            emit Upgrade(msg.sender, freeX3Referrer, 1, level);

       
    }    
    
    function registration(address userAddress, address referrerAddress) private  {
        require(msg.value == levelPrice[1], "registration cost 0.05");
        require(!isUserExists(userAddress), "user exists");
        require(isUserExists(referrerAddress), "referrer not exists");
        
        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }
        require(size == 0, "cannot be a contract");
        
        User memory user = User({
            id: lastUserId,
            referrer: referrerAddress,
            partnersCount: 0
        });
        
        users[userAddress] = user;
        idToAddress[lastUserId] = userAddress;
        
        users[userAddress].referrer = referrerAddress;
        
        users[userAddress].activeX3Levels[1] = true; 
        
        
        
        userIds[lastUserId] = userAddress;
        lastUserId++;
        
        users[referrerAddress].partnersCount++;

        address freeX3Referrer = findFreeX3Referrer(userAddress, 1);

        users[userAddress].x3Matrix[1].currentReferrer = freeX3Referrer;
        updateX3Referrer(userAddress, freeX3Referrer, 1);

        payable(marketing_address).transfer(msg.value * 75 / 1000);
        payable(lottery_address).transfer(msg.value * 200 / 100);

        address random_ref = idToAddress[getRandomUserByLevel(1)]; 
        payable(random_ref).transfer(msg.value * 665 / 1000);
        
        users[random_ref].activeCycleLevels[1]--;
        users[random_ref].activeEndedCycleLevels[1]++;

           

        users[msg.sender].activeCycleLevels[1] = 2;



        emit Registration(userAddress, referrerAddress, users[userAddress].id, users[referrerAddress].id);
    }
    
    function updateX3Referrer(address userAddress, address referrerAddress, uint8 level) private {
        users[referrerAddress].x3Matrix[level].referrals.push(userAddress);

        if (users[referrerAddress].x3Matrix[level].referrals.length < 3) {
            emit NewUserPlace(userAddress, referrerAddress, 1, level, uint8(users[referrerAddress].x3Matrix[level].referrals.length));
            return sendETHDividends(referrerAddress, userAddress,  level);
        }
        
        emit NewUserPlace(userAddress, referrerAddress, 1, level, 3);
        //close matrix
        users[referrerAddress].x3Matrix[level].referrals = new address[](0);
        if (!users[referrerAddress].activeX3Levels[level+1] && level != LAST_LEVEL) {
            users[referrerAddress].x3Matrix[level].blocked = true;
        }

        //create new one by recursion
        if (referrerAddress != owner) {
            //check referrer active level
            address freeReferrerAddress = findFreeX3Referrer(referrerAddress, level);
            if (users[referrerAddress].x3Matrix[level].currentReferrer != freeReferrerAddress) {
                users[referrerAddress].x3Matrix[level].currentReferrer = freeReferrerAddress;
            }
            
            users[referrerAddress].x3Matrix[level].reinvestCount++;
            emit Reinvest(referrerAddress, freeReferrerAddress, userAddress, 1, level);
            updateX3Referrer(referrerAddress, freeReferrerAddress, level);
        } else {
            sendETHDividends(owner, userAddress,  level);
            users[owner].x3Matrix[level].reinvestCount++;
            emit Reinvest(owner, address(0), userAddress, 1, level);
        }
    }

    
    
    function findFreeX3Referrer(address userAddress, uint8 level) public view returns(address) {
        while (true) {
            if (users[users[userAddress].referrer].activeX3Levels[level]) {
                return users[userAddress].referrer;
            }
            
            userAddress = users[userAddress].referrer;
        }
    }
    

    function getRandomUserByLevel(uint256 level) public view returns(uint256) {
        //userIds
        //users
        
        if(level>16) return 1;
        uint[] memory levelusers = new uint[](lastUserId);
        uint256 n = 0 ;
       
        for (uint256 levelc = level; levelc <= LAST_LEVEL; levelc++) {
            
            
            for (uint256 i = 1; i <= lastUserId; i++) {
                if(users[idToAddress[i]].activeCycleLevels[levelc]>0){
                    levelusers[n] = i;
                    n++;
                }
            }
            if(n>0){
                uint256 randomi = 0;
                while(randomi == 0){
                    randomi = levelusers[random()%levelusers.length];
                    
                }
                return randomi;
                //return idToAddress[levelusers[random()%levelusers.length]];
            }
            
            
        }
        
      //return idToAddress[1];
    }

    
    function random() private view returns (uint) {
       
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, lastUserId)));
        
    }
    
        
    function usersActiveX3Levels(address userAddress, uint8 level) public view returns(bool) {
        return users[userAddress].activeX3Levels[level];
    }

    

    function usersX3Matrix(address userAddress, uint8 level) public view returns(address, address[] memory, bool) {
        return (users[userAddress].x3Matrix[level].currentReferrer,
                users[userAddress].x3Matrix[level].referrals,
                users[userAddress].x3Matrix[level].blocked);
    }

  
    
    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }

    function findEthReceiver(address userAddress, address _from,  uint8 level) private returns(address, bool) {
        address receiver = userAddress;
        bool isExtraDividends;
        while (true) {
                if (users[receiver].x3Matrix[level].blocked) {
                    emit MissedEthReceive(receiver, _from, 1, level);
                    isExtraDividends = true;
                    receiver = users[receiver].x3Matrix[level].currentReferrer;
                } else {
                    return (receiver, isExtraDividends);
                }
            }
        
    }

    function sendETHDividends(address userAddress, address _from,  uint8 level) private {
        (address receiver, bool isExtraDividends) = findEthReceiver(userAddress, _from,  level);
        uint256 win_amount = levelPrice[level] * 6 / 100 ; 
        if (!address(uint160(receiver)).send(win_amount)) {
            return address(uint160(receiver)).transfer(win_amount);
        }
        
        if (isExtraDividends) {
            emit SentExtraEthDividends(_from, receiver,1, level);
        }
    }
    
    function bytesToAddress(bytes memory bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }
}