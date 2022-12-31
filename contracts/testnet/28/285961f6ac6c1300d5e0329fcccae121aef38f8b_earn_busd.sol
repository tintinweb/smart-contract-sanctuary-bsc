/**
 *Submitted for verification at BscScan.com on 2022-12-30
*/

pragma solidity >=0.4.23 <0.6.0;

 interface tokenInterface
 {
    function transfer(address _to, uint256 _amount) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);
 }


contract earn_busd {
    
    struct User {
        uint id;
        address referrer;
        uint partnersCount;

        mapping(uint8 => bool) activeEBLevels;
        mapping(uint8 => EB) eBMatrix;
    }
    
    struct EB {
        address currentReferrer;
        address[] firstLevelReferrals;
        address[] secondLevelReferrals;
        bool blocked;
        uint reinvestCount;

        address closedPart;
    }

    uint8 public constant LAST_LEVEL = 6;
    
    mapping(address => User) public users;
    mapping(uint => address) public idToAddress;
    mapping(uint => address) public userIds;
    mapping(address => uint) public balances; 

    uint public lastUserId = 2;
    address public owner;
    
    mapping(uint8 => uint) public levelPrice;
    
    event Registration(address indexed user, address indexed referrer, uint indexed userId, uint referrerId);
    event Reinvest(address indexed user, address indexed currentReferrer, address indexed caller, uint8 level);
    event Upgrade(address indexed user, address indexed referrer, uint8 level);
    event NewUserPlace(address indexed user, address indexed referrer, uint8 level, uint8 place);
    event MissedEthReceive(address indexed receiver, address indexed from, uint8 level);
    event SentExtraEthDividends(address indexed from, address indexed receiver, uint8 level);
    
    
    constructor(address ownerAddress) public {
        levelPrice[1] = 20  * ( 10 ** 18);
        for (uint8 i = 2; i <= LAST_LEVEL; i++) {
            levelPrice[i] = levelPrice[i-1] * 2;
        }
        
        owner = ownerAddress;
        
        User memory user = User({
            id: 1,
            referrer: address(0),
            partnersCount: uint(0)
        });
        
        users[ownerAddress] = user;
        idToAddress[1] = ownerAddress;
        
        for (uint8 i = 1; i <= LAST_LEVEL; i++) {
            users[ownerAddress].activeEBLevels[i] = true;
        }
        
        userIds[1] = ownerAddress;
    }
    

    function registrationExt(address referrerAddress) external payable {
        registration(msg.sender, referrerAddress);
    }
    
    function buyNewLevel(uint8 level) external payable {
        require(isUserExists(msg.sender), "user is not exists. Register first.");

        require(msg.value == levelPrice[level], "invalid price");
        require(level > 1 && level <= LAST_LEVEL, "invalid level");

            require(!users[msg.sender].activeEBLevels[level], "level already activated"); 

            if (users[msg.sender].eBMatrix[level-1].blocked) {
                users[msg.sender].eBMatrix[level-1].blocked = false;
            }

            address freeEBReferrer = findFreeEBReferrer(msg.sender, level);
            
            users[msg.sender].activeEBLevels[level] = true;
            updateEBReferrer(msg.sender, freeEBReferrer, level);
            
            emit Upgrade(msg.sender, freeEBReferrer,level);
    }    
    
    function registration(address userAddress, address referrerAddress) private {
        require(msg.value == 0.05  * ( 10 ** 18), "registration cost 0.05");
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
        
        users[userAddress].activeEBLevels[1] = true;
        
        
        userIds[lastUserId] = userAddress;
        lastUserId++;
        
        users[referrerAddress].partnersCount++;

        updateEBReferrer(userAddress, findFreeEBReferrer(userAddress, 1), 1);
        
        emit Registration(userAddress, referrerAddress, users[userAddress].id, users[referrerAddress].id);
    }
    
    function updateEBReferrer(address userAddress, address referrerAddress, uint8 level) private {
        require(users[referrerAddress].activeEBLevels[level], "500. Referrer level is inactive");
        
        if (users[referrerAddress].eBMatrix[level].firstLevelReferrals.length < 2) {
            users[referrerAddress].eBMatrix[level].firstLevelReferrals.push(userAddress);
            emit NewUserPlace(userAddress, referrerAddress, level, uint8(users[referrerAddress].eBMatrix[level].firstLevelReferrals.length));
            
            //set current level
            users[userAddress].eBMatrix[level].currentReferrer = referrerAddress;

            if (referrerAddress == owner) {
                return sendETHDividends(referrerAddress, userAddress, level);
            }
            
            address ref = users[referrerAddress].eBMatrix[level].currentReferrer;            
            users[ref].eBMatrix[level].secondLevelReferrals.push(userAddress); 
            
            uint len = users[ref].eBMatrix[level].firstLevelReferrals.length;
            
            if ((len == 2) && 
                (users[ref].eBMatrix[level].firstLevelReferrals[0] == referrerAddress) &&
                (users[ref].eBMatrix[level].firstLevelReferrals[1] == referrerAddress)) {
                if (users[referrerAddress].eBMatrix[level].firstLevelReferrals.length == 1) {
                    emit NewUserPlace(userAddress, ref, level, 5);
                } else {
                    emit NewUserPlace(userAddress, ref, level, 6);
                }
            }  else if ((len == 1 || len == 2) &&
                    users[ref].eBMatrix[level].firstLevelReferrals[0] == referrerAddress) {
                if (users[referrerAddress].eBMatrix[level].firstLevelReferrals.length == 1) {
                    emit NewUserPlace(userAddress, ref, level, 3);
                } else {
                    emit NewUserPlace(userAddress, ref, level, 4);
                }
            } else if (len == 2 && users[ref].eBMatrix[level].firstLevelReferrals[1] == referrerAddress) {
                if (users[referrerAddress].eBMatrix[level].firstLevelReferrals.length == 1) {
                    emit NewUserPlace(userAddress, ref, level, 5);
                } else {
                    emit NewUserPlace(userAddress, ref, level, 6);
                }
            }

            return updateEBReferrerSecondLevel(userAddress, ref, level);
        }
        
        users[referrerAddress].eBMatrix[level].secondLevelReferrals.push(userAddress);

        if (users[referrerAddress].eBMatrix[level].closedPart != address(0)) {
            if ((users[referrerAddress].eBMatrix[level].firstLevelReferrals[0] == 
                users[referrerAddress].eBMatrix[level].firstLevelReferrals[1]) &&
                (users[referrerAddress].eBMatrix[level].firstLevelReferrals[0] ==
                users[referrerAddress].eBMatrix[level].closedPart)) {

                updateEB(userAddress, referrerAddress, level, true);
                return updateEBReferrerSecondLevel(userAddress, referrerAddress, level);
            } else if (users[referrerAddress].eBMatrix[level].firstLevelReferrals[0] == 
                users[referrerAddress].eBMatrix[level].closedPart) {
                updateEB(userAddress, referrerAddress, level, true);
                return updateEBReferrerSecondLevel(userAddress, referrerAddress, level);
            } else {
                updateEB(userAddress, referrerAddress, level, false);
                return updateEBReferrerSecondLevel(userAddress, referrerAddress, level);
            }
        }

        if (users[referrerAddress].eBMatrix[level].firstLevelReferrals[1] == userAddress) {
            updateEB(userAddress, referrerAddress, level, false);
            return updateEBReferrerSecondLevel(userAddress, referrerAddress, level);
        } else if (users[referrerAddress].eBMatrix[level].firstLevelReferrals[0] == userAddress) {
            updateEB(userAddress, referrerAddress, level, true);
            return updateEBReferrerSecondLevel(userAddress, referrerAddress, level);
        }
        
        if (users[users[referrerAddress].eBMatrix[level].firstLevelReferrals[0]].eBMatrix[level].firstLevelReferrals.length <= 
            users[users[referrerAddress].eBMatrix[level].firstLevelReferrals[1]].eBMatrix[level].firstLevelReferrals.length) {
            updateEB(userAddress, referrerAddress, level, false);
        } else {
            updateEB(userAddress, referrerAddress, level, true);
        }
        
        updateEBReferrerSecondLevel(userAddress, referrerAddress, level);
    }

    function updateEB(address userAddress, address referrerAddress, uint8 level, bool x2) private {
        if (!x2) {
            users[users[referrerAddress].eBMatrix[level].firstLevelReferrals[0]].eBMatrix[level].firstLevelReferrals.push(userAddress);
            emit NewUserPlace(userAddress, users[referrerAddress].eBMatrix[level].firstLevelReferrals[0], level, uint8(users[users[referrerAddress].eBMatrix[level].firstLevelReferrals[0]].eBMatrix[level].firstLevelReferrals.length));
            emit NewUserPlace(userAddress, referrerAddress, level, 2 + uint8(users[users[referrerAddress].eBMatrix[level].firstLevelReferrals[0]].eBMatrix[level].firstLevelReferrals.length));
            //set current level
            users[userAddress].eBMatrix[level].currentReferrer = users[referrerAddress].eBMatrix[level].firstLevelReferrals[0];
        } else {
            users[users[referrerAddress].eBMatrix[level].firstLevelReferrals[1]].eBMatrix[level].firstLevelReferrals.push(userAddress);
            emit NewUserPlace(userAddress, users[referrerAddress].eBMatrix[level].firstLevelReferrals[1], level, uint8(users[users[referrerAddress].eBMatrix[level].firstLevelReferrals[1]].eBMatrix[level].firstLevelReferrals.length));
            emit NewUserPlace(userAddress, referrerAddress, level, 4 + uint8(users[users[referrerAddress].eBMatrix[level].firstLevelReferrals[1]].eBMatrix[level].firstLevelReferrals.length));
            //set current level
            users[userAddress].eBMatrix[level].currentReferrer = users[referrerAddress].eBMatrix[level].firstLevelReferrals[1];
        }
    }
    
    function updateEBReferrerSecondLevel(address userAddress, address referrerAddress, uint8 level) private {
        if (users[referrerAddress].eBMatrix[level].secondLevelReferrals.length < 4) {
            return sendETHDividends(referrerAddress, userAddress, level);
        }
        
        address[] memory eB = users[users[referrerAddress].eBMatrix[level].currentReferrer].eBMatrix[level].firstLevelReferrals;
        
        if (eB.length == 2) {
            if (eB[0] == referrerAddress ||
                eB[1] == referrerAddress) {
                users[users[referrerAddress].eBMatrix[level].currentReferrer].eBMatrix[level].closedPart = referrerAddress;
            } else if (eB.length == 1) {
                if (eB[0] == referrerAddress) {
                    users[users[referrerAddress].eBMatrix[level].currentReferrer].eBMatrix[level].closedPart = referrerAddress;
                }
            }
        }
        
        users[referrerAddress].eBMatrix[level].firstLevelReferrals = new address[](0);
        users[referrerAddress].eBMatrix[level].secondLevelReferrals = new address[](0);
        users[referrerAddress].eBMatrix[level].closedPart = address(0);

        if (!users[referrerAddress].activeEBLevels[level+1] && level != LAST_LEVEL) {
            users[referrerAddress].eBMatrix[level].blocked = true;
        }

        users[referrerAddress].eBMatrix[level].reinvestCount++;
        
        if (referrerAddress != owner) {
            address freeReferrerAddress = findFreeEBReferrer(referrerAddress, level);

            emit Reinvest(referrerAddress, freeReferrerAddress, userAddress, level);
            updateEBReferrer(referrerAddress, freeReferrerAddress, level);
        } else {
            emit Reinvest(owner, address(0), userAddress, level);
            sendETHDividends(owner, userAddress, level);
        }
    }

    function findFreeEBReferrer(address userAddress, uint8 level) public view returns(address) {
        while (true) {
            if (users[users[userAddress].referrer].activeEBLevels[level]) {
                return users[userAddress].referrer;
            }
            
            userAddress = users[userAddress].referrer;
        }
    }

    function usersActiveEBLevels(address userAddress, uint8 level) public view returns(bool) {
        return users[userAddress].activeEBLevels[level];
    }

    function usersEBMatrix(address userAddress, uint8 level) public view returns(address, address[] memory, address[] memory, bool, address) {
        return (users[userAddress].eBMatrix[level].currentReferrer,
                users[userAddress].eBMatrix[level].firstLevelReferrals,
                users[userAddress].eBMatrix[level].secondLevelReferrals,
                users[userAddress].eBMatrix[level].blocked,
                users[userAddress].eBMatrix[level].closedPart);
    }
    
    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }

    function findEthReceiver(address userAddress, address _from, uint8 level) private returns(address, bool) {
        address receiver = userAddress;
        bool isExtraDividends;

            while (true) {
                if (users[receiver].eBMatrix[level].blocked) {
                    emit MissedEthReceive(receiver, _from, level);
                    isExtraDividends = true;
                    receiver = users[receiver].eBMatrix[level].currentReferrer;
                } else {
                    return (receiver, isExtraDividends);
                }
            }

    }

    function sendETHDividends(address userAddress, address _from,uint8 level) private {
        (address receiver, bool isExtraDividends) = findEthReceiver(userAddress, _from,level);

        if (!address(uint160(receiver)).send(levelPrice[level])) {
            return address(uint160(receiver)).transfer(address(this).balance);
        }
        
        if (isExtraDividends) {
            emit SentExtraEthDividends(_from, receiver,level);
        }
    }
    
    function bytesToAddress(bytes memory bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }
}