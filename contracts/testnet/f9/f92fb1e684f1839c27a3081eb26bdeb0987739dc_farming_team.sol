/**
 *Submitted for verification at BscScan.com on 2022-12-10
*/

pragma solidity >=0.4.23 <0.6.0;


//*******************************************************************//
//------------------ Contract to Manage Ownership -------------------//
//*******************************************************************//
contract owned
{
    address internal owner;
    address internal newOwner;
    address public signer;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
        signer = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }


    modifier onlySigner {
        require(msg.sender == signer, 'caller must be signer');
        _;
    }


    function changeSigner(address _signer) public onlyOwner {
        signer = _signer;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    //the reason for this flow is to protect owners from sending ownership to unintended address due to human error
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}


interface interfaceMintNFT {
    function mintToken(address recipient, uint _type) external returns (bool);
}

contract farming_team is owned {
    
    struct User {
        uint id;
        address referrer;
        uint partnersCount;
        
        mapping(uint8 => bool) activeUserLevels;
        
        mapping(uint8 => uStat) UserMatrix;
    }

    address public nftMinterContract;

    struct uStat {
        address currentReferrer;
        address[] referrals;
        bool blocked;
        uint reinvestCount;
    }
    
    // level 1 = common nft
    // level 2 = rare nft
    // level 3 = epic nft
    // level 4 = legendary nft

    uint8 public constant LAST_LEVEL = 4;
    
    mapping(address => User) public users;
    mapping(uint => address) public idToAddress;
    mapping(uint => address) public userIds;
    mapping(address => uint) public balances; 

    uint public lastUserId = 2;
    address public owner;
    uint public rewardPercent = 2000; // 2000 = 20% two digits for decimal

    
    mapping(uint8 => uint) public levelPrice;
    
    event Registration(address indexed user, address indexed referrer, uint indexed userId, uint referrerId);
    event Reinvest(address indexed user, address indexed currentReferrer, address indexed caller,uint8 level);
    event Upgrade(address indexed user, address indexed referrer,uint8 level);
    event NewUserPlace(address indexed user, address indexed referrer, uint8 level, uint8 place);
    event MissedEthReceive(address indexed receiver, address indexed from, uint8 level);
    event SentExtraEthDividends(address indexed from, address indexed receiver,uint8 level);
    
    
    constructor() public {
        levelPrice[1] = 0.05 ether;
        for (uint8 i = 2; i <= LAST_LEVEL; i++) {
            levelPrice[i] = levelPrice[i-1] * 2;
        }
        
        owner = msg.sender;
        
        User memory user = User({
            id: 1,
            referrer: msg.sender,
            partnersCount: uint(0)
        });
        
        users[msg.sender] = user;
        idToAddress[1] = msg.sender;
        
        for (uint8 i = 1; i <= LAST_LEVEL; i++) {
            users[msg.sender].activeUserLevels[i] = true;
            users[msg.sender].UserMatrix[i].currentReferrer = msg.sender;
        }
        
        userIds[1] = msg.sender;
    }
    
    function() external payable {
        if(msg.data.length == 0) {
            return registration(msg.sender, owner);
        }
        
        registration(msg.sender, bytesToAddress(msg.data));
    }

    function setNftMinterContract(address _nftMinterContract) public onlyOwner returns(bool)
    {
        nftMinterContract = _nftMinterContract;
        return true;
    }

    function registrationExt(address referrerAddress) external payable {
        registration(msg.sender, referrerAddress);
    }

    function setRewardPercent(uint _rewardPercent)  public returns(bool)
    {
        require(msg.sender == owner, "Invalid Caller");
        rewardPercent = _rewardPercent;
        return true;
    }

    function buyNewLevel(uint8 level) external payable {
        require(isUserExists(msg.sender), "user is not exists. Register first.");

        require(msg.value == levelPrice[level], "invalid price");
        require(level > 1 && level <= LAST_LEVEL, "invalid level");

            require(!users[msg.sender].activeUserLevels[level], "level already activated");

            if (users[msg.sender].UserMatrix[level-1].blocked) {
                users[msg.sender].UserMatrix[level-1].blocked = false;
            }
    
            address freeUserReferrer = findFreeUserReferrer(msg.sender, level);
            users[msg.sender].UserMatrix[level].currentReferrer = freeUserReferrer;
            users[msg.sender].activeUserLevels[level] = true;
            updateUserReferrer(msg.sender, freeUserReferrer, level);

            interfaceMintNFT(nftMinterContract).mintToken(msg.sender, level);

            emit Upgrade(msg.sender, freeUserReferrer,level);
    }    
    
    function registration(address userAddress, address referrerAddress) private {
        require(msg.value == levelPrice[1], "invalid reg price");
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
        
        users[userAddress].activeUserLevels[1] = true; 
        
        
        userIds[lastUserId] = userAddress;
        lastUserId++;
        
        users[referrerAddress].partnersCount++;

        address freeUserReferrer = findFreeUserReferrer(userAddress, 1);
        users[userAddress].UserMatrix[1].currentReferrer = freeUserReferrer;
        updateUserReferrer(userAddress, freeUserReferrer, 1);
        
        interfaceMintNFT(nftMinterContract).mintToken(userAddress, 1);

        emit Registration(userAddress, referrerAddress, users[userAddress].id, users[referrerAddress].id);
    }
    
    function updateUserReferrer(address userAddress, address referrerAddress, uint8 level) private {
        users[referrerAddress].UserMatrix[level].referrals.push(userAddress);

        if (users[referrerAddress].UserMatrix[level].referrals.length < 3) {
            emit NewUserPlace(userAddress, referrerAddress,level, uint8(users[referrerAddress].UserMatrix[level].referrals.length));
            return sendDividends(referrerAddress, userAddress,level);
        }
        
        emit NewUserPlace(userAddress, referrerAddress,level, 3);
        //close matrix
        users[referrerAddress].UserMatrix[level].referrals = new address[](0);
        if (!users[referrerAddress].activeUserLevels[level+1] && level != LAST_LEVEL) {
            users[referrerAddress].UserMatrix[level].blocked = true;
        }

        //create new one by recursion
        if (referrerAddress != owner) {
            //check referrer active level
            address freeReferrerAddress = findFreeUserReferrer(referrerAddress, level);
            if (users[referrerAddress].UserMatrix[level].currentReferrer != freeReferrerAddress) {
                users[referrerAddress].UserMatrix[level].currentReferrer = freeReferrerAddress;
            }
            
            users[referrerAddress].UserMatrix[level].reinvestCount++;
            emit Reinvest(referrerAddress, freeReferrerAddress, userAddress,level);
            //updateUserReferrerR(referrerAddress, freeReferrerAddress, level);
        } else {
            sendDividends(owner, userAddress,level);
            users[owner].UserMatrix[level].reinvestCount++;
            emit Reinvest(owner, address(0), userAddress,level);
        }
    }
/*
    function updateUserReferrerR(address userAddress, address referrerAddress, uint8 level) private {
        users[referrerAddress].UserMatrix[level].referrals.push(userAddress);

        if (users[referrerAddress].UserMatrix[level].referrals.length < 3) {
            emit NewUserPlace(userAddress, referrerAddress,level, uint8(users[referrerAddress].UserMatrix[level].referrals.length));
            return;
        }

        emit NewUserPlace(userAddress, referrerAddress,level, 3);
        //close matrix
        users[referrerAddress].UserMatrix[level].referrals = new address[](0);
        if (!users[referrerAddress].activeUserLevels[level+1] && level != LAST_LEVEL) {
            users[referrerAddress].UserMatrix[level].blocked = true;
        }

        //create new one by recursion
        if (referrerAddress != owner) {
            //check referrer active level
            address freeReferrerAddress = findFreeUserReferrer(referrerAddress, level);
            if (users[referrerAddress].UserMatrix[level].currentReferrer != freeReferrerAddress) {
                users[referrerAddress].UserMatrix[level].currentReferrer = freeReferrerAddress;
            }
            
            users[referrerAddress].UserMatrix[level].reinvestCount++;
            emit Reinvest(referrerAddress, freeReferrerAddress, userAddress,level);
            updateUserReferrerR(referrerAddress, freeReferrerAddress, level);
        } else {
            sendDividends(owner, userAddress,level);
            users[owner].UserMatrix[level].reinvestCount++;
            emit Reinvest(owner, address(0), userAddress,level);
        }
    }

*/
    
    function findFreeUserReferrer(address userAddress, uint8 level) public view returns(address) {
        while (true) {
            if (users[users[userAddress].referrer].activeUserLevels[level]) {
                return users[userAddress].referrer;
            }
            
            userAddress = users[userAddress].referrer;
        }
    }
    
        
    function usersActiveUserLevels(address userAddress, uint8 level) public view returns(bool) {
        return users[userAddress].activeUserLevels[level];
    }

    function usersUserMatrix(address userAddress, uint8 level) public view returns(address, address[] memory, bool) {
        return (users[userAddress].UserMatrix[level].currentReferrer,
                users[userAddress].UserMatrix[level].referrals,
                users[userAddress].UserMatrix[level].blocked);
    }

    
    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }

    function findReceiver(address userAddress, address _from,uint8 level) public returns(address, bool) {
        address receiver = userAddress;
        bool isExtraDividends;
            while (true) {
                if (users[receiver].UserMatrix[level].blocked) {
                    emit MissedEthReceive(receiver, _from,level);
                    isExtraDividends = true;
                    receiver = users[receiver].UserMatrix[level].currentReferrer;
                } else {
                    return (receiver, isExtraDividends);
                }
            }

            return (receiver, isExtraDividends);
    }

    function sendDividends(address userAddress, address _from,uint8 level) public  {
        (address receiver, bool isExtraDividends) = findReceiver(userAddress, _from,level);

        if (!address(uint160(receiver)).send(levelPrice[level])) {
            return address(uint160(receiver)).transfer(address(this).balance * rewardPercent / 10000);
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

    function moveToFarming(uint _amount) public returns(bool)
    {
        require(msg.sender == owner, "Invalid Caller");
        address(uint160(owner)).transfer(_amount);
        return true;
    }

    
}