/**
 *Submitted for verification at BscScan.com on 2022-07-20
*/

//smart contract BSC

pragma solidity <0.6.0;

contract SmartBeComBee {
    
    struct B3 {
        address currentReferrer;
        address[] referrals;
        uint reinvestCount;
        bool blocked;
    }
    
    struct B6 {
        address currentReferrer;
        address[] firstLevelReferrals;
        address[] secondLevelReferrals;
        uint reinvestCount;
        bool blocked;

        address closedPart;
    }

    struct User {
        uint id;
        address referrer;
        uint partnersCount;
        
        mapping(uint8 => bool) activeB3Levels;
        mapping(uint8 => bool) activeB6Levels;
        
        mapping(uint8 => B3) b3Matrix;
        mapping(uint8 => B6) b6Matrix;
    }

    uint8 public constant LAST_LEVEL = 9;
    
    mapping(address => uint) public balances; 
    mapping(uint => address) public userIds;
    mapping(address => User) public users;
    mapping(uint => address) public idToAddress;

    address public owner;
    uint public lastUserId = 2;
    
    event SentExtraEthDividends(address indexed from, address indexed receiver, uint8 matrix, uint8 level);
    event MissedEthReceive(address indexed receiver, address indexed from, uint8 matrix, uint8 level);
    event NewUserPlace(address indexed user, address indexed referrer, uint8 matrix, uint8 level, uint8 place);
    event Upgrade(address indexed user, address indexed referrer, uint8 matrix, uint8 level);
    event Reinvest(address indexed user, address indexed currentReferrer, address indexed caller, uint8 matrix, uint8 level);
    event Registration(address indexed user, address indexed referrer, uint indexed userId, uint referrerId);
    
    mapping(uint8 => uint) public levelCost;

    constructor(address ownerAddress) public {

        levelCost[1] = 30;
        levelCost[2] = 70;
        levelCost[3] = 150;
        levelCost[4] = 300;
        levelCost[5] = 600;
        levelCost[6] = 1500;
        levelCost[7] = 3000;
        levelCost[8] = 6000;
        levelCost[9] = 12000;
        
        owner = ownerAddress;
        
        User memory user = User({
            id: 1,
            partnersCount: uint(0),
            referrer: address(0)
        });
        
        idToAddress[1] = ownerAddress;
        users[ownerAddress] = user;
        
        for (uint8 i = 1; i <= LAST_LEVEL; i++) {
            users[ownerAddress].activeB3Levels[i] = true;

            users[ownerAddress].activeB6Levels[i] = true;
        }
        
        userIds[1] = ownerAddress;
    }

    function registration(address referrerAddress) external payable {
        registrationbase(msg.sender, referrerAddress);
    }

    function() external payable {
        
        if(msg.data.length == 0) {

            return registrationbase(msg.sender, owner);
        }
        
        registrationbase(msg.sender, bytesToAddress(msg.data));
    }
    
    function registrationbase(address userAddress, address referrerAddress) private {
        require(!isUserExists(userAddress), "user exists");
        require(isUserExists(referrerAddress), "referrer not exists");
        require(msg.value == 0.05 ether, "registration cost 0.05");
        
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
        
        userIds[lastUserId] = userAddress;
        lastUserId++;

        users[userAddress].activeB3Levels[1] = true; 
        users[userAddress].activeB6Levels[1] = true;
        
        address freeX3Referrer = findFreeB3Refer(userAddress, 1);
        users[userAddress].b3Matrix[1].currentReferrer = freeX3Referrer;

        users[referrerAddress].partnersCount++;

        updB3Refer(userAddress, freeX3Referrer, 1);
        
        emit Registration(userAddress, referrerAddress, users[userAddress].id, users[referrerAddress].id);
    }

    function buyLevel(uint8 matrix, uint8 level) external payable {
        require(isUserExists(msg.sender), "user is not exists. Register first.");
        require(matrix == 1 || matrix == 2, "invalid matrix");
        require(msg.value == levelCost[level], "invalid price");
        require(level > 1 && level <= LAST_LEVEL, "invalid level");

        if (matrix == 1) {
            require(!users[msg.sender].activeB3Levels[level], "level already activated");

            if (users[msg.sender].b3Matrix[level-1].blocked) {
                users[msg.sender].b3Matrix[level-1].blocked = false;
            }
    
            address freeB3Refer = findFreeB3Refer(msg.sender, level);
            users[msg.sender].b3Matrix[level].currentReferrer = freeB3Refer;
            users[msg.sender].activeB3Levels[level] = true;
            updB3Refer(msg.sender, freeB3Refer, level);
            
            emit Upgrade(msg.sender, freeB3Refer, 1, level);

        } else {

        }
    }      
    
    function updB3Refer(address userAddress, address referrerAddress, uint8 level) private {
        users[referrerAddress].b3Matrix[level].referrals.push(userAddress);

        if (users[referrerAddress].b3Matrix[level].referrals.length < 3) {
            emit NewUserPlace(userAddress, referrerAddress, 1, level, uint8(users[referrerAddress].b3Matrix[level].referrals.length));
            return sendETHDividends(referrerAddress, userAddress, 1, level);
        }
        
        emit NewUserPlace(userAddress, referrerAddress, 1, level, 3);
        //close matrix
        users[referrerAddress].b3Matrix[level].referrals = new address[](0);
        if (!users[referrerAddress].activeB3Levels[level+1] && level != LAST_LEVEL) {
            users[referrerAddress].b3Matrix[level].blocked = true;
        }

        //create new one by recursion
        if (referrerAddress != owner) {
            //check referrer active level
            address freeReferrerAddress = findFreeB3Refer(referrerAddress, level);
            if (users[referrerAddress].b3Matrix[level].currentReferrer != freeReferrerAddress) {
                users[referrerAddress].b3Matrix[level].currentReferrer = freeReferrerAddress;
            }
            
            users[referrerAddress].b3Matrix[level].reinvestCount++;
            emit Reinvest(referrerAddress, freeReferrerAddress, userAddress, 1, level);
            updB3Refer(referrerAddress, freeReferrerAddress, level);
        } else {
            sendETHDividends(owner, userAddress, 1, level);
            users[owner].b3Matrix[level].reinvestCount++;
            emit Reinvest(owner, address(0), userAddress, 1, level);
        }
    }    
    
    function findFreeB3Refer(address userAddress, uint8 level) public view returns(address) {
        while (true) {
            if (users[users[userAddress].referrer].activeB3Levels[level]) {
                return users[userAddress].referrer;
            }
            
            userAddress = users[userAddress].referrer;
        }
    }
        
    function usersActiveB3Levels(address userAddress, uint8 level) public view returns(bool) {
        return users[userAddress].activeB3Levels[level];
    }

    function usersB3Matrix(address userAddress, uint8 level) public view returns(address, address[] memory, bool) {
        return (users[userAddress].b3Matrix[level].currentReferrer,
                users[userAddress].b3Matrix[level].referrals,
                users[userAddress].b3Matrix[level].blocked);
    }
    
    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }

    function findEthReceiver(address userAddress, address _from, uint8 matrix, uint8 level) private returns(address, bool) {
        address receiver = userAddress;
        bool isExtraDividends;
        if (matrix == 1) {
            while (true) {
                if (users[receiver].b3Matrix[level].blocked) {
                    emit MissedEthReceive(receiver, _from, 1, level);
                    isExtraDividends = true;
                    receiver = users[receiver].b3Matrix[level].currentReferrer;
                } else {
                    return (receiver, isExtraDividends);
                }
            }
        } else {
            while (true) {
                if (users[receiver].b6Matrix[level].blocked) {
                    emit MissedEthReceive(receiver, _from, 2, level);
                    isExtraDividends = true;
                    receiver = users[receiver].b6Matrix[level].currentReferrer;
                } else {
                    return (receiver, isExtraDividends);
                }
            }
        }
    }

    function sendETHDividends(address userAddress, address _from, uint8 matrix, uint8 level) private {
        (address receiver, bool isExtraDividends) = findEthReceiver(userAddress, _from, matrix, level);

        if (!address(uint160(receiver)).send(levelCost[level])) {
            return address(uint160(receiver)).transfer(address(this).balance);
        }
        
        if (isExtraDividends) {
            emit SentExtraEthDividends(_from, receiver, matrix, level);
        }
    }
    
    function bytesToAddress(bytes memory bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }
}