/**
 *Submitted for verification at BscScan.com on 2022-05-13
*/

pragma solidity >=0.4.23 <0.6.0;

contract OyesMatic {
    struct User {
        uint id;
        address referrer;
        uint partnersCount;
        uint O3MaxLevel;
        uint O6MaxLevel;
        uint O3Income;
        uint O6Income;
        mapping(uint8 => bool) activeO3Levels;
        mapping(uint8 => bool) activeO6Levels;
        mapping(uint8 => O3) O3Matrix;
        mapping(uint8 => O6) O6Matrix;
    }
    
    struct O3 {
        address currentReferrer;
        address[] referrals;
        bool blocked;
        uint reinvestCount;
    }
    
    struct O6 {
        address currentReferrer;
        address[] firstLevelReferrals;
        address[] secondLevelReferrals;
        bool blocked;
        uint reinvestCount;
        address closedPart;
    }

    uint8 public constant LAST_LEVEL = 12;
    
    mapping(address => User) public users;
    mapping(uint => address) public idToAddress;
    mapping(uint => address) public userIds;
    mapping(address => uint) public balances; 

    uint public lastUserId = 2;
    uint public adminFee = 5;
    uint public totalearnedMatic = 0 ether;
    address payable public owner;
    
    mapping(uint8 => uint) public levelPrice;
    
    event Registration(address indexed user, address indexed referrer, uint indexed userId, uint referrerId,uint256 time);
    event Reinvest(address indexed user, address indexed currentReferrer, address indexed caller, uint8 matrix, uint8 level,uint256 time);
    event Upgrade(address indexed user, address indexed referrer, uint8 matrix, uint8 level,uint256 time);
    event NewUserPlace(address indexed user,uint indexed userId, address indexed referrer,uint referrerId, uint8 matrix, uint8 level, uint8 place,uint256 time,uint8 partnerType);
    event MissedMaticReceive(address indexed receiver,uint receiverId, address indexed from,uint indexed fromId, uint8 matrix, uint8 level,uint256 time,uint256 missedtype);
    event SentDividends(address indexed from,uint indexed fromId, address indexed receiver,uint receiverId, uint8 matrix, uint8 level, bool isExtra,uint256 time);
    
    constructor(address payable ownerAddress) public {
        levelPrice[1] = 0.00001 ether;
        for (uint8 i = 2; i <= LAST_LEVEL; i++) {
            levelPrice[i] = levelPrice[i-1] * 2;
        }
        
        owner = ownerAddress;
        
        User memory user = User({
            id: 1,
            referrer: address(0),
            partnersCount: uint(0),
            O3MaxLevel:uint(0),
            O6MaxLevel:uint(0),
            O3Income:uint8(0),
            O6Income:uint8(0)
        });
        
        users[ownerAddress] = user;
        idToAddress[1] = ownerAddress;
        
        for (uint8 i = 1; i <= LAST_LEVEL; i++) {
            users[ownerAddress].activeO3Levels[i] = true;
            users[ownerAddress].activeO6Levels[i] = true;
        }
        users[ownerAddress].O3MaxLevel = 12;
        users[ownerAddress].O6MaxLevel = 12;
        userIds[1] = ownerAddress;
    }
    
    function() external payable {
        if(msg.data.length == 0) {
            return registration(msg.sender, owner);
        }
        
        registration(msg.sender, bytesToAddress(msg.data));
    }

    function registrationExt(address referrerAddress) external payable {
        registration(msg.sender, referrerAddress);
    }
    
    function buyNewLevel(uint8 matrix, uint8 level) external payable {
        require(isUserExists(msg.sender), "user is not exists. Register first.");
        require(matrix == 1 || matrix == 2, "invalid matrix");
        require(msg.value == levelPrice[level], "invalid price");
        require(level > 1 && level <= LAST_LEVEL, "invalid level");
        
        if (matrix == 1) {
            require(!users[msg.sender].activeO3Levels[level], "level already activated");
            require(users[msg.sender].activeO3Levels[level - 1], "previous level should be activated");

            if (users[msg.sender].O3Matrix[level-1].blocked) {
                users[msg.sender].O3Matrix[level-1].blocked = false;
            }
    
            address freeO3Referrer = findFreeO3Referrer(msg.sender, level);
            if(freeO3Referrer != users[msg.sender].referrer){
                emit MissedMaticReceive(users[msg.sender].referrer,users[users[msg.sender].referrer].id, msg.sender,users[msg.sender].id, 1, level,block.timestamp,1);
            }
            users[msg.sender].O3MaxLevel = level;
            users[msg.sender].O3Matrix[level].currentReferrer = freeO3Referrer;
            users[msg.sender].activeO3Levels[level] = true;
            updateO3Referrer(msg.sender, freeO3Referrer, level);
            totalearnedMatic = totalearnedMatic+levelPrice[level];
            emit Upgrade(msg.sender, freeO3Referrer, 1, level,block.timestamp);

        } else {
            require(!users[msg.sender].activeO6Levels[level], "level already activated"); 
            require(users[msg.sender].activeO6Levels[level - 1], "previous level should be activated"); 

            if (users[msg.sender].O6Matrix[level-1].blocked) {
                users[msg.sender].O6Matrix[level-1].blocked = false;
            }

            address freeO6Referrer = findFreeO6Referrer(msg.sender, level);
            if(freeO6Referrer != users[msg.sender].referrer){
                emit MissedMaticReceive(users[msg.sender].referrer,users[users[msg.sender].referrer].id, msg.sender,users[msg.sender].id, 2, level,block.timestamp,1);
            }
            users[msg.sender].O6MaxLevel = level;
            users[msg.sender].activeO6Levels[level] = true;
            updateO6Referrer(msg.sender, freeO6Referrer, level);
            
        
          totalearnedMatic = totalearnedMatic+levelPrice[level];
            emit Upgrade(msg.sender, freeO6Referrer, 2, level,block.timestamp);
        }
        uint256 feeamount = msg.value * adminFee / 100;
        owner.transfer(feeamount);
    }    
    
    function registration(address userAddress, address referrerAddress) private {
        require(msg.value == 0.00002 ether, "registration cost 100");
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
            partnersCount: 0,
            O3MaxLevel:1,
            O6MaxLevel:1,
            O3Income:0 ether,
            O6Income:0 ether
        });
        
        users[userAddress] = user;
        idToAddress[lastUserId] = userAddress;
        
        users[userAddress].referrer = referrerAddress;
        
        users[userAddress].activeO3Levels[1] = true; 
        users[userAddress].activeO6Levels[1] = true;
        
        
        userIds[lastUserId] = userAddress;
        lastUserId++;
        totalearnedMatic = totalearnedMatic+0.00002 ether;
        users[referrerAddress].partnersCount++;

        address freeO3Referrer = findFreeO3Referrer(userAddress, 1);
        users[userAddress].O3Matrix[1].currentReferrer = freeO3Referrer;
        updateO3Referrer(userAddress, freeO3Referrer, 1);
        updateO6Referrer(userAddress, findFreeO6Referrer(userAddress, 1), 1);
        
        emit Registration(userAddress, referrerAddress, users[userAddress].id, users[referrerAddress].id,block.timestamp);
        uint256 feeamount = msg.value * adminFee / 100;
        owner.transfer(feeamount);
    }
    
    function updateO3Referrer(address userAddress, address referrerAddress, uint8 level) private {
        users[referrerAddress].O3Matrix[level].referrals.push(userAddress);
        uint8 partnerType;
        User memory _userdetail = users[userAddress];
        User memory _referrerdetail = users[referrerAddress];
        if(_userdetail.referrer != referrerAddress){
            if(!users[_userdetail.referrer].activeO3Levels[level]){
                partnerType = 4;
            } else if(_referrerdetail.id < users[_userdetail.referrer].id){
                partnerType = 2;
            } else if (_referrerdetail.id > users[_userdetail.referrer].id){
                partnerType = 3;
            }
        }else{
            partnerType = 1;
        }
        if (users[referrerAddress].O3Matrix[level].referrals.length < 3) {
            emit NewUserPlace(userAddress,users[userAddress].id, referrerAddress, users[referrerAddress].id, 1, level, uint8(users[referrerAddress].O3Matrix[level].referrals.length),block.timestamp,partnerType);
            return sendMaticDividends(referrerAddress, userAddress, 1, level);
        }
        
        emit NewUserPlace(userAddress,users[userAddress].id, referrerAddress,users[referrerAddress].id, 1, level, 3,block.timestamp,partnerType);
        //close matrix
        users[referrerAddress].O3Matrix[level].referrals = new address[](0);
        if (!users[referrerAddress].activeO3Levels[level+1] && level != LAST_LEVEL) {
            users[referrerAddress].O3Matrix[level].blocked = true;
        }

        //create new one by recursion
        if (referrerAddress != owner) {
            //check referrer active level
            address freeReferrerAddress = findFreeO3Referrer(referrerAddress, level);
            if (users[referrerAddress].O3Matrix[level].currentReferrer != freeReferrerAddress) {
                users[referrerAddress].O3Matrix[level].currentReferrer = freeReferrerAddress;
            }
            
            users[referrerAddress].O3Matrix[level].reinvestCount++;
            emit Reinvest(referrerAddress, freeReferrerAddress, userAddress, 1, level,block.timestamp);
            updateO3Referrer(referrerAddress, freeReferrerAddress, level);
        } else {
            sendMaticDividends(owner, userAddress, 1, level);
            users[owner].O3Matrix[level].reinvestCount++;
            emit Reinvest(owner, address(0), userAddress, 1, level,block.timestamp);
        }
    }

    function updateO6Referrer(address userAddress, address referrerAddress, uint8 level) private {
        require(users[referrerAddress].activeO6Levels[level], "500. Referrer level is inactive");
        uint8 partnerType;
        User memory _userdetail = users[userAddress];
        User memory _referrerdetail = users[referrerAddress];
        if(_userdetail.referrer != referrerAddress){
            if(!users[_userdetail.referrer].activeO6Levels[level]){
                partnerType = 4;
            } else if(_referrerdetail.id < users[_userdetail.referrer].id){
                partnerType = 2;
            } else if (_referrerdetail.id > users[_userdetail.referrer].id){
                partnerType = 3;
            }
        }else{
            partnerType = 1;
        }
        if (users[referrerAddress].O6Matrix[level].firstLevelReferrals.length < 2) {
            users[referrerAddress].O6Matrix[level].firstLevelReferrals.push(userAddress);
            emit NewUserPlace(userAddress,users[userAddress].id, referrerAddress,users[referrerAddress].id, 2, level, uint8(users[referrerAddress].O6Matrix[level].firstLevelReferrals.length),block.timestamp,partnerType);
            //set current level
            users[userAddress].O6Matrix[level].currentReferrer = referrerAddress;
            if (referrerAddress == owner) {
                return sendMaticDividends(referrerAddress, userAddress, 2, level);
            }
            address ref = users[referrerAddress].O6Matrix[level].currentReferrer;            
            users[ref].O6Matrix[level].secondLevelReferrals.push(userAddress); 
            uint len = users[ref].O6Matrix[level].firstLevelReferrals.length;
            _referrerdetail = users[ref];
            if(_userdetail.referrer != ref){
                if(_referrerdetail.id < users[_userdetail.referrer].id){
                    partnerType = 2;
                } else if (_referrerdetail.id > users[_userdetail.referrer].id){
                    partnerType = 3;
                }
            }else{
                partnerType = 1;
            }
            if ((len == 2) && 
                (users[ref].O6Matrix[level].firstLevelReferrals[0] == referrerAddress) &&
                (users[ref].O6Matrix[level].firstLevelReferrals[1] == referrerAddress)) {
                if (users[referrerAddress].O6Matrix[level].firstLevelReferrals.length == 1) {
                    emit NewUserPlace(userAddress,_userdetail.id, ref,users[ref].id, 2, level, 5,block.timestamp,partnerType);
                } else {
                    emit NewUserPlace(userAddress,_userdetail.id,ref,users[ref].id,2, level, 6,block.timestamp,partnerType);
                }
            }  else if ((len == 1 || len == 2) &&
                    users[ref].O6Matrix[level].firstLevelReferrals[0] == referrerAddress) {
                if (users[referrerAddress].O6Matrix[level].firstLevelReferrals.length == 1) {
                    emit NewUserPlace(userAddress,_userdetail.id, ref,users[ref].id, 2, level, 3,block.timestamp,partnerType);
                } else {
                    emit NewUserPlace(userAddress,_userdetail.id, ref,users[ref].id, 2, level, 4,block.timestamp,partnerType);
                }
            } else if (len == 2 && users[ref].O6Matrix[level].firstLevelReferrals[1] == referrerAddress) {
                if (users[referrerAddress].O6Matrix[level].firstLevelReferrals.length == 1) {
                    emit NewUserPlace(userAddress,_userdetail.id, ref,users[ref].id, 2, level, 5,block.timestamp,partnerType);
                } else {
                    emit NewUserPlace(userAddress,_userdetail.id, ref,users[ref].id, 2, level, 6,block.timestamp,partnerType);
                }
            }
            return updateO6ReferrerSecondLevel(userAddress, ref, level);
        }
        users[referrerAddress].O6Matrix[level].secondLevelReferrals.push(userAddress);
        if (users[referrerAddress].O6Matrix[level].closedPart != address(0)) {
            if ((users[referrerAddress].O6Matrix[level].firstLevelReferrals[0] == 
                users[referrerAddress].O6Matrix[level].firstLevelReferrals[1]) &&
                (users[referrerAddress].O6Matrix[level].firstLevelReferrals[0] ==
                users[referrerAddress].O6Matrix[level].closedPart)) {
                updateO6(userAddress, referrerAddress, level, true);
                return updateO6ReferrerSecondLevel(userAddress, referrerAddress, level);
            } else if (users[referrerAddress].O6Matrix[level].firstLevelReferrals[0] == 
                users[referrerAddress].O6Matrix[level].closedPart) {
                updateO6(userAddress, referrerAddress, level, true);
                return updateO6ReferrerSecondLevel(userAddress, referrerAddress, level);
            } else {
                updateO6(userAddress, referrerAddress, level, false);
                return updateO6ReferrerSecondLevel(userAddress, referrerAddress, level);
            }
        }
        if (users[referrerAddress].O6Matrix[level].firstLevelReferrals[1] == userAddress) {
            updateO6(userAddress, referrerAddress, level, false);
            return updateO6ReferrerSecondLevel(userAddress, referrerAddress, level);
        } else if (users[referrerAddress].O6Matrix[level].firstLevelReferrals[0] == userAddress) {
            updateO6(userAddress, referrerAddress, level, true);
            return updateO6ReferrerSecondLevel(userAddress, referrerAddress, level);
        }
        if (users[users[referrerAddress].O6Matrix[level].firstLevelReferrals[0]].O6Matrix[level].firstLevelReferrals.length <= 
            users[users[referrerAddress].O6Matrix[level].firstLevelReferrals[1]].O6Matrix[level].firstLevelReferrals.length) {
            updateO6(userAddress, referrerAddress, level, false);
        } else {
            updateO6(userAddress, referrerAddress, level, true);
        }
        updateO6ReferrerSecondLevel(userAddress, referrerAddress, level);
    }

    function updateO6(address userAddress, address referrerAddress, uint8 level, bool x2) private {
        uint8 partnerType;
        if (!x2) {
            users[users[referrerAddress].O6Matrix[level].firstLevelReferrals[0]].O6Matrix[level].firstLevelReferrals.push(userAddress);
            address firstlevel = users[referrerAddress].O6Matrix[level].firstLevelReferrals[0];
            User storage _userdetail = users[userAddress];
            User storage _referrerdetail = users[firstlevel];
            if(_userdetail.referrer != firstlevel){
                if(_referrerdetail.id < users[_userdetail.referrer].id){
                    partnerType = 2;
                } else if (_referrerdetail.id > users[_userdetail.referrer].id){
                    partnerType = 3;
                }
            }else{
                partnerType = 1;
            }
            uint8 partner2;
            _referrerdetail = users[referrerAddress];
            if(_userdetail.referrer != referrerAddress){
                if(!users[_userdetail.referrer].activeO6Levels[level]){
                    partnerType = 4;
                } else if(_referrerdetail.id < users[_userdetail.referrer].id){
                    partner2 = 2;
                } else if (_referrerdetail.id > users[_userdetail.referrer].id){
                    partner2 = 3;
                }
            }else{
                partner2 = 1;
            }
            emit NewUserPlace(userAddress,_userdetail.id, firstlevel,users[firstlevel].id, 2, level, uint8(users[firstlevel].O6Matrix[level].firstLevelReferrals.length),block.timestamp,partnerType);
            emit NewUserPlace(userAddress,_userdetail.id, referrerAddress,users[referrerAddress].id, 2, level, 2 + uint8(_referrerdetail.O6Matrix[level].firstLevelReferrals.length),block.timestamp,partner2);
            _userdetail.O6Matrix[level].currentReferrer = firstlevel;
        } else {
            users[users[referrerAddress].O6Matrix[level].firstLevelReferrals[1]].O6Matrix[level].firstLevelReferrals.push(userAddress);
            address firstlevel = users[referrerAddress].O6Matrix[level].firstLevelReferrals[1];
            User storage _userdetail = users[userAddress];
            User storage _referrerdetail = users[firstlevel];
            if(_userdetail.referrer != firstlevel){
                if(_referrerdetail.id < users[_userdetail.referrer].id){
                    partnerType = 2;
                } else if (_referrerdetail.id > users[_userdetail.referrer].id){
                    partnerType = 3;
                }
            }else{
                partnerType = 1;
            }
            uint8 partner2;
            _referrerdetail = users[referrerAddress];
            if(_userdetail.referrer != referrerAddress){
                if(!users[_userdetail.referrer].activeO6Levels[level]){
                    partnerType = 4;
                } else if(_referrerdetail.id < users[_userdetail.referrer].id){
                    partner2 = 2;
                } else if (_referrerdetail.id > users[_userdetail.referrer].id){
                    partner2 = 3;
                }
            }else{
                partner2 = 1;
            }
            emit NewUserPlace(userAddress,_userdetail.id, firstlevel,users[firstlevel].id, 2, level, uint8(users[firstlevel].O6Matrix[level].firstLevelReferrals.length),block.timestamp,partnerType);
            emit NewUserPlace(userAddress,_userdetail.id, referrerAddress,users[referrerAddress].id, 2, level, 4 + uint8(_referrerdetail.O6Matrix[level].firstLevelReferrals.length),block.timestamp,partner2);
            _userdetail.O6Matrix[level].currentReferrer = firstlevel;
        }
    }
    
    function updateO6ReferrerSecondLevel(address userAddress, address referrerAddress, uint8 level) private {
        if (users[referrerAddress].O6Matrix[level].secondLevelReferrals.length < 4) {
            return sendMaticDividends(referrerAddress, userAddress, 2, level);
        }
        address[] memory O6 = users[users[referrerAddress].O6Matrix[level].currentReferrer].O6Matrix[level].firstLevelReferrals;
        if (O6.length == 2) {
            if (O6[0] == referrerAddress ||
                O6[1] == referrerAddress) {
                users[users[referrerAddress].O6Matrix[level].currentReferrer].O6Matrix[level].closedPart = referrerAddress;
            } else if (O6.length == 1) {
                if (O6[0] == referrerAddress) {
                    users[users[referrerAddress].O6Matrix[level].currentReferrer].O6Matrix[level].closedPart = referrerAddress;
                }
            }
        }
        
        users[referrerAddress].O6Matrix[level].firstLevelReferrals = new address[](0);
        users[referrerAddress].O6Matrix[level].secondLevelReferrals = new address[](0);
        users[referrerAddress].O6Matrix[level].closedPart = address(0);

        if (!users[referrerAddress].activeO6Levels[level+1] && level != LAST_LEVEL) {
            users[referrerAddress].O6Matrix[level].blocked = true;
        }

        users[referrerAddress].O6Matrix[level].reinvestCount++;
        
        if (referrerAddress != owner) {
            address freeReferrerAddress = findFreeO6Referrer(referrerAddress, level);

            emit Reinvest(referrerAddress, freeReferrerAddress, userAddress, 2, level,block.timestamp);
            updateO6Referrer(referrerAddress, freeReferrerAddress, level);
        } else {
            emit Reinvest(owner, address(0), userAddress, 2, level,block.timestamp);
            sendMaticDividends(owner, userAddress, 2, level);
        }
    }
    
    function findFreeO3Referrer(address userAddress, uint8 level) public view returns(address) {
        while (true) {
            if (users[users[userAddress].referrer].activeO3Levels[level]) {
                return users[userAddress].referrer;
            }
            userAddress = users[userAddress].referrer;
        }
    }
    
    function findFreeO6Referrer(address userAddress, uint8 level) public view returns(address) {
        while (true) {
            if (users[users[userAddress].referrer].activeO6Levels[level]) {
                return users[userAddress].referrer;
            }
            userAddress = users[userAddress].referrer;
        }
    }
        
    function usersActiveO3Levels(address userAddress, uint8 level) public view returns(bool) {
        return users[userAddress].activeO3Levels[level];
    }

    function usersActiveO6Levels(address userAddress, uint8 level) public view returns(bool) {
        return users[userAddress].activeO6Levels[level];
    }

    function get3XMatrix(address userAddress, uint8 level) public view returns(address, address[] memory, uint, bool) {
        return (users[userAddress].O3Matrix[level].currentReferrer,
                users[userAddress].O3Matrix[level].referrals,
                users[userAddress].O3Matrix[level].reinvestCount,
                users[userAddress].O3Matrix[level].blocked);
    }

    function getO6Matrix(address userAddress, uint8 level) public view returns(address, address[] memory, address[] memory, bool, uint, address) {
        return (users[userAddress].O6Matrix[level].currentReferrer,
                users[userAddress].O6Matrix[level].firstLevelReferrals,
                users[userAddress].O6Matrix[level].secondLevelReferrals,
                users[userAddress].O6Matrix[level].blocked,
                users[userAddress].O6Matrix[level].reinvestCount,
                users[userAddress].O6Matrix[level].closedPart);
    }
    
    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }

    function findMaticReceiver(address userAddress, address _from, uint8 matrix, uint8 level) private returns(address, bool) {
        address receiver = userAddress;
        bool isExtraDividends;
        if (matrix == 1) {
            while (true) {
                if (users[receiver].O3Matrix[level].blocked) {
                    emit MissedMaticReceive(receiver,users[receiver].id, _from,users[_from].id, 1, level,block.timestamp,2);
                    isExtraDividends = true;
                    receiver = users[receiver].O3Matrix[level].currentReferrer;
                } else {
                    return (receiver, isExtraDividends);
                }
            }
        } else {
            while (true) {
                if (users[receiver].O6Matrix[level].blocked) {
                    emit MissedMaticReceive(receiver,users[receiver].id, _from,users[_from].id, 2, level,block.timestamp,2);
                    isExtraDividends = true;
                    receiver = users[receiver].O6Matrix[level].currentReferrer;
                } else {
                    return (receiver, isExtraDividends);
                }
            }
        }
    }

    function sendMaticDividends(address userAddress, address _from, uint8 matrix, uint8 level) private {
        (address receiver, bool isExtraDividends) = findMaticReceiver(userAddress, _from, matrix, level);
        uint256 feeamount = levelPrice[level] * adminFee / 100;
        if(matrix==1)
        { 
            users[receiver].O3Income += (levelPrice[level] - feeamount);
        }
        else if(matrix==2)
        {
            users[receiver].O6Income +=(levelPrice[level] - feeamount) ;    
        }
        if (!address(uint160(receiver)).send((levelPrice[level] - feeamount))) {
            return address(uint160(receiver)).transfer(address(this).balance);
        }
        emit SentDividends(_from,users[_from].id, receiver,users[receiver].id, matrix, level, isExtraDividends,block.timestamp);
    }
    
    function bytesToAddress(bytes memory bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }
    function setAdminFee(uint _fees) public payable {
        require(msg.sender == owner,"Permission Denied");
        adminFee = _fees;
    }
    function safeWithdraw() public payable {
        require(msg.sender == owner,"Permission Denied");
        owner.transfer(address(this).balance);
    }
}