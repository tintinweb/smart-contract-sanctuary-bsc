/**
 *Submitted for verification at BscScan.com on 2022-02-26
*/

pragma solidity 0.5.14;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


contract ERC20 {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    function mint(address reciever, uint256 value,bytes32[3] memory _mrs, uint8 _v) public returns(bool);
    function transfer(address to, uint256 value) public returns(bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract OpenAlexalO {

    struct UserStruct {
        bool isExist;
        uint id;
        uint referrerID;
        uint currentLevel;
        uint totalEarningEth;
        address[] referral;
        mapping(uint => uint) levelExpired;
    }
    
    using SafeMath for uint256;
    address public ownerAddress;
    uint public adminFee = 16 ether;
    uint public currentId = 0;
    uint referrer1Limit = 2;
    uint public PERIOD_LENGTH = 60 days;
    bool lockStatus;
    ERC20 Token;
    

    mapping(uint => uint) public LEVEL_PRICE;
    mapping (address => UserStruct) public users;
    mapping (uint => address) public userList;
    mapping(address => mapping (uint => uint)) public EarnedEth;
    mapping(address=> uint) loopCheck;
    
    event regLevelEvent(address indexed UserAddress, address indexed ReferrerAddress, uint Time);
    event buyLevelEvent(address indexed UserAddress, uint Levelno, uint Time);
    event getMoneyForLevelEvent(address indexed UserAddress,uint UserId,address indexed ReferrerAddress, uint ReferrerId, uint Levelno, uint LevelPrice, uint Time);
    event lostMoneyForLevelEvent(address indexed UserAddress,uint UserId,address indexed ReferrerAddress, uint ReferrerId, uint Levelno, uint LevelPrice, uint Time);
    
    constructor(address _tokenAddress) public {
        ownerAddress = msg.sender;
        Token = ERC20(_tokenAddress);
        
        // Level_Price
        LEVEL_PRICE[1] = 0.03 ether;
        LEVEL_PRICE[2] = 0.05 ether;
        LEVEL_PRICE[3] = 0.1 ether;
        LEVEL_PRICE[4] = 0.5 ether;
        LEVEL_PRICE[5] = 1 ether;
        LEVEL_PRICE[6] = 3 ether;
        LEVEL_PRICE[7] = 7 ether;
        LEVEL_PRICE[8] = 12 ether;
        LEVEL_PRICE[9] = 15 ether;
        LEVEL_PRICE[10] = 25 ether;
        LEVEL_PRICE[11] = 30 ether;
        LEVEL_PRICE[12] = 39 ether;
        
        UserStruct memory userStruct;
        currentId = currentId.add(1);

        userStruct = UserStruct({
            isExist: true,
            id: currentId,
            referrerID: 0,
            currentLevel:1,
            totalEarningEth:0,
            referral: new address[](0)
        });
        users[ownerAddress] = userStruct;
        userList[currentId] = ownerAddress;

        for(uint i = 1; i <= 12; i++) {
            users[ownerAddress].currentLevel = i;
            users[ownerAddress].levelExpired[i] = 55555555555;
        }
    }
    
    /**
     * @dev To register the User
     * @param _referrerID id of user/referrer who is already in matrix
     * @param _mrs _mrs[0] - message hash _mrs[1] - r of signature _mrs[2] - s of signature 
     * @param _v  v of signature
     */ 
    function regUser(uint _referrerID, bytes32[3] calldata _mrs, uint8 _v) external payable {
        require(lockStatus == false,"Contract Locked");
        require(users[msg.sender].isExist == false, "User exist");
        require(_referrerID > 0 && _referrerID <= currentId, "Incorrect referrer Id");
        
        require(msg.value == LEVEL_PRICE[1],"Incorrect Value");
        
        
        if(users[userList[_referrerID]].referral.length >= referrer1Limit) _referrerID = users[findFreeReferrer(userList[_referrerID])].id;

        UserStruct memory userStruct;
        currentId++;
        
        userStruct = UserStruct({
            isExist: true,
            id: currentId,
            referrerID: _referrerID,
            currentLevel: 1,
            totalEarningEth:0,
            referral: new address[](0)
        });

        users[msg.sender] = userStruct;
        userList[currentId] = msg.sender;

        users[msg.sender].levelExpired[1] = now.add(PERIOD_LENGTH);

        users[userList[_referrerID]].referral.push(msg.sender);
        
        loopCheck[msg.sender] = 0;

        payForLevel(0,1, msg.sender,((LEVEL_PRICE[1].mul(adminFee)).div(10**20)),_mrs,_v, msg.value);

        emit regLevelEvent(msg.sender, userList[_referrerID], now);
    }
    
    /**
     * @dev To update the admin fee percentage
     * @param _adminFee  feePercentage (in ether)
     */ 
    function updateFeePercentage(uint256 _adminFee) public returns(bool) {
        require(msg.sender == ownerAddress,"only OwnerWallet");
        adminFee = _adminFee;
        return true;  
    }
    
    /**
     * @dev To update the level price
     * @param _level Level which wants to change
     * @param _price Level price (in ether)
     */ 
    function updatePrice(uint _level, uint _price) external returns(bool) {
          require(msg.sender == ownerAddress,"only OwnerWallet");
          LEVEL_PRICE[_level] = _price;
          return true;
    }
    
    /**
     * @dev To buy the next level by User
     * @param _level level wants to buy
     * @param _mrs _mrs[0] - message hash _mrs[1] - r of signature _mrs[2] - s of signature 
     * @param _v  v of signature
     */ 
    function buyLevel(uint256 _level,bytes32[3] calldata _mrs,uint8 _v) external payable {
        require(lockStatus == false,"Contract Locked");
        require(users[msg.sender].isExist,"User not exist"); 
        require(_level > 0 && _level <= 12,"Incorrect level");

        if(_level == 1) {
            require(msg.value == LEVEL_PRICE[1],"Incorrect Value");
            users[msg.sender].levelExpired[1] =  users[msg.sender].levelExpired[1].add(PERIOD_LENGTH);
            users[msg.sender].currentLevel = 1;
        }
        else {
            require(msg.value == LEVEL_PRICE[_level],"Incorrect Value");
            
            users[msg.sender].currentLevel = _level;

            for(uint l =_level - 1; l > 0; l--) require(users[msg.sender].levelExpired[l] >= now,"Buy the previous level");
            
            if(users[msg.sender].levelExpired[_level] == 0)
                users[msg.sender].levelExpired[_level] = now + PERIOD_LENGTH;
            else 
                users[msg.sender].levelExpired[_level] += PERIOD_LENGTH;
        }
       
       loopCheck[msg.sender] = 0;
       
       payForLevel(0,_level, msg.sender,((LEVEL_PRICE[_level].mul(adminFee)).div(10**20)),_mrs,_v,msg.value);

        emit buyLevelEvent(msg.sender, _level, now);
    }
    
    function payForLevel(uint _flag,uint _level,address _userAddress,uint _adminPrice,bytes32[3] memory _mrs,uint8 _v,uint256 _amt) internal {
        
        address[6] memory referer;
        
        if(_flag == 0) 
        {
            if(_level == 1 || _level == 7) {
                referer[0] = userList[users[_userAddress].referrerID];
            }
            else if(_level == 2 || _level == 8) {
                referer[1] = userList[users[_userAddress].referrerID];
                referer[0] = userList[users[referer[1]].referrerID];
            }
            else if(_level == 3 || _level == 9) {
                referer[1] = userList[users[_userAddress].referrerID];
                referer[2] = userList[users[referer[1]].referrerID];
                referer[0] = userList[users[referer[2]].referrerID];
            }
            else if(_level == 4 || _level == 10) {
                referer[1] = userList[users[_userAddress].referrerID];
                referer[2] = userList[users[referer[1]].referrerID];
                referer[3] = userList[users[referer[2]].referrerID];
                referer[0] = userList[users[referer[3]].referrerID];
            }
            else if(_level == 5 || _level == 11) {
                referer[1] = userList[users[_userAddress].referrerID];
                referer[2] = userList[users[referer[1]].referrerID];
                referer[3] = userList[users[referer[2]].referrerID];
                referer[4] = userList[users[referer[3]].referrerID];
                referer[0] = userList[users[referer[4]].referrerID];
            }
            else if(_level == 6 || _level == 12) {
                referer[1] = userList[users[_userAddress].referrerID];
                referer[2] = userList[users[referer[1]].referrerID];
                referer[3] = userList[users[referer[2]].referrerID];
                referer[4] = userList[users[referer[3]].referrerID];
                referer[5] = userList[users[referer[4]].referrerID];
                referer[0] = userList[users[referer[5]].referrerID];
            }
            
        }
        
        else if(_flag == 1) {
             referer[0] = userList[users[_userAddress].referrerID];
        }


        if(!users[referer[0]].isExist) referer[0] = userList[1];
        
        if(loopCheck[msg.sender] >= 12) {
            referer[0] = userList[1];
        }

        
        if(users[referer[0]].levelExpired[_level] >= now) {
          
            uint256 tobeminted = ((_amt).mul(10**18)).div(0.01 ether);
            
            
            // transactions 
            require((address(uint160(referer[0])).send(LEVEL_PRICE[_level].sub(_adminPrice))) && (address(uint160(ownerAddress)).send(_adminPrice)) &&   Token.mint(msg.sender,tobeminted,_mrs,_v), "Transaction Failure");
           
            users[referer[0]].totalEarningEth = users[referer[0]].totalEarningEth.add(LEVEL_PRICE[_level]);
            EarnedEth[referer[0]][_level] =  EarnedEth[referer[0]][_level].add(LEVEL_PRICE[_level]);
          
            
            emit getMoneyForLevelEvent(msg.sender,users[msg.sender].id,referer[0],users[referer[0]].id, _level, LEVEL_PRICE[_level],now);
        }
        
        else  {
            if(loopCheck[_userAddress] < 12) {
                loopCheck[_userAddress] = loopCheck[_userAddress].add(1);
                emit lostMoneyForLevelEvent(msg.sender,users[msg.sender].id,referer[0],users[referer[0]].id, _level, LEVEL_PRICE[_level],now);
                payForLevel(1,_level, referer[0],_adminPrice,_mrs,_v,_amt);
            }
        }
    }
    
    /**
     * @dev To get the free Referrer Address
     * @param _userAddress User address who is already in matrix  (mostly prefer ownerAddress address)
     */ 
    function findFreeReferrer(address _userAddress) public view returns(address) {
        if(users[_userAddress].referral.length < referrer1Limit) return _userAddress;

        address[] memory referrals = new address[](254);
        referrals[0] = users[_userAddress].referral[0];
        referrals[1] = users[_userAddress].referral[1];

        address freeReferrer;
        bool noFreeReferrer = true;

        for(uint i = 0; i < 254; i++) { 
            if(users[referrals[i]].referral.length == referrer1Limit) {
                if(i < 126) {
                    referrals[(i+1)*2] = users[referrals[i]].referral[0];
                    referrals[(i+1)*2+1] = users[referrals[i]].referral[1];
                }
            }
            else {
                noFreeReferrer = false;
                freeReferrer = referrals[i];
                break;
            }
        }

        require(!noFreeReferrer, "No Free Referrer");

        return freeReferrer;
    }
    
    
   /**
     * @dev To view the referrals
     * @param _userAddress  User who is already in matrix
     */ 
    function viewUserReferral(address _userAddress) external view returns(address[] memory) {
        return users[_userAddress].referral;
    }
    
    
    /**
     * @dev To view the level expired time
     * @param _userAddress  User who is already in matrix
     * @param _level Level which is wants to view
     */ 
    function viewUserLevelExpired(address _userAddress,uint _level) external view returns(uint) {
        return users[_userAddress].levelExpired[_level];
    }
    
    
    /**
     * @dev To lock/unlock the contract
     * @param _lockStatus  status in bool
     */ 
    function contractLock(bool _lockStatus) public returns(bool) {
        require(msg.sender == ownerAddress, "Invalid User");
        lockStatus = _lockStatus;
        return true;
    }
    
    
    /**
     * @dev To update the token contract address
     * @param _newToken  new Token Address 
     */ 
    function updateToken(address _newToken) public returns(bool) {
        require(msg.sender == ownerAddress, "Invalid User");
        Token = ERC20(_newToken);
        return true;
    }
    
    
    /**
     * @dev To get the total earning ether till now
     */
    function getTotalEarnedEther() public view returns(uint) {
        uint totalEth;
        
        for( uint i=1;i<=currentId;i++) {
            totalEth = totalEth.add(users[userList[i]].totalEarningEth);
        }
        
        return totalEth;
    }
        
    
    function () external payable {
        revert("Invalid Transaction");
    }
}