/**
 *Submitted for verification at BscScan.com on 2022-10-07
*/

pragma solidity ^0.5.8;

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

library Address {

    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

}

contract Forsage2 {

    struct UserStruct {
        bool isExist;
        uint id;
        uint totalDirects;
        uint referrerID;
        uint8 currentLevel;
        address[] referral;
        mapping (uint8 => bool) levelStatus;
    }
    
    struct AutoPoolUserStruct {
        bool isExist;
        address userAddress;
        uint uniqueId;
        uint referrerID;
        uint8 currentLevel;
        mapping (uint8 => uint[]) referral;
        mapping (uint8 => bool) levelStatus;
        mapping (uint8 => uint) reInvestCount;
    }
    
    using SafeMath for uint256;
    address public passup; 
    address public rebirth;
    uint public userCurrentId = 0;

    IERC20 usdt = IERC20(0x55d398326f99059fF775485246999027B3197955);
    uint256 constant public LEVEL_1 = 25;
    uint256 constant public LEVEL_2 = 5;
    uint256 constant public LEVEL_3 = 4;
    uint256 constant public LEVEL_4 = 7;
    uint256 constant public LEVEL_5 = 9;

    address[] public level_1_users;
    address[] public level_2_users; 
    address[] public level_3_users; 
    address[] public level_4_users; 
    address[] public level_5_users; 
    
    address owner;
    mapping (address => uint) level_1_usersIndex;
    mapping (address => uint) level_2_usersIndex;
    mapping (address => uint) level_3_usersIndex;
    mapping (address => uint) level_4_usersIndex;
    mapping (address => uint) level_5_usersIndex;
    
    mapping (uint8 => uint) public autoPoolcurrentId;
    mapping (address => uint) index;
    mapping (uint8 => uint) public APId;
    mapping (uint => address) public userList;
    mapping (address => uint) public autoPoolId;
    mapping (address => UserStruct) public users;
    mapping (uint8 => uint) public levelPrice;
    mapping (uint8 => mapping (uint => address)) public autoPoolUserList;
    mapping (uint => AutoPoolUserStruct) public autoPoolUniqueUsers;
    mapping (uint8 => mapping (uint => AutoPoolUserStruct)) public autoPoolUsers;
  

    
    modifier onlyOwner() {
        require(msg.sender == passup, "Only Owner");
        _;
    }
        
    constructor(address passupAddress, address rebirthAddress) public {
        passup = passupAddress;
        owner = msg.sender;
        rebirth = rebirthAddress;
    
        levelPrice[1]  =  30000000000000000000;
        levelPrice[2]  =  75000000000000000000;
        levelPrice[3]  =  200000000000000000000;
        levelPrice[4]  =  500000000000000000000;
        levelPrice[5]  =  1000000000000000000000;

        UserStruct memory userStruct;
        
        userCurrentId = 1;

        userStruct = UserStruct({
            isExist: true,
            id: userCurrentId,
            referrerID: 0,
            totalDirects:10,
            currentLevel:1,
            referral: new address[](0)
        });

        users[passup] = userStruct;
        userList[userCurrentId] = passup;
        AutoPoolUserStruct memory autoPoolStruct;
        autoPoolStruct = AutoPoolUserStruct({
            isExist: true,
            userAddress: passup,
            uniqueId: userCurrentId,
            referrerID: 0,
            currentLevel: 1
        });

        autoPoolUniqueUsers[userCurrentId] = autoPoolStruct;
        autoPoolId[passup] = userCurrentId;
        autoPoolUniqueUsers[userCurrentId].currentLevel = 5;
        users[passup].currentLevel = 5;
        for(uint8 i = 1; i <= 5; i++) {   
            users[passup].levelStatus[i] = true;
            autoPoolcurrentId[i] = 1;
            autoPoolUsers[i][autoPoolcurrentId[i]].levelStatus[i] = true;
            autoPoolUserList[i][autoPoolcurrentId[i]] = passup;
            autoPoolUsers[i][autoPoolcurrentId[i]] = autoPoolStruct;
            autoPoolUniqueUsers[userCurrentId].levelStatus[i] = true;
            APId[i] = 1;
        }
    }

    function passupAddress(address _passupAddress) public onlyOwner {
        passup = _passupAddress;
    }

    function rebirthAddress(address _rebirthAddress) public onlyOwner {
        rebirth = _rebirthAddress;
    }
   
    function () external payable {
        revert("Invalid Transaction");
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
    
    function register(uint depAmount, uint _referrerID) public {
        require(!isContract(msg.sender) && msg.sender == tx.origin);
        usdt.transferFrom(msg.sender, address(this), depAmount);
        uint _userId = autoPoolId[msg.sender];
        require(users[msg.sender].isExist == false && autoPoolUniqueUsers[_userId].isExist ==  false);
        require(depAmount == levelPrice[1]);
        require(_referrerID > 0 && _referrerID <= userCurrentId);
        
        // check 
        address UserAddress=msg.sender;
        uint32 size;
        assembly {
            size := extcodesize(UserAddress)
        }
        require(size == 0);
        
        userCurrentId = userCurrentId.add(1);
        userList[userCurrentId] = msg.sender;
        if(!inArrayLevel1(msg.sender)){
            level_1_usersIndex[msg.sender] = level_1_users.length;
            level_1_users.push(msg.sender);
        }
        _workPlanReg(_referrerID);
        _autoPoolReg();
    }
    
    function upgrade(uint depAmount,uint8 _level) public {
        uint _userId = autoPoolId[msg.sender];
        require(!isContract(msg.sender) && msg.sender == tx.origin);
        require(users[msg.sender].isExist && autoPoolUniqueUsers[_userId].isExist); 
        require(users[msg.sender].levelStatus[_level] ==  false && autoPoolUniqueUsers[_userId].levelStatus[_level] == false);
        require(_level > 0 && _level <= 5);
        require(depAmount == levelPrice[_level]);
        usdt.transferFrom(msg.sender, address(this), depAmount);
        if(_level != 1)  
        {
            for(uint8 l =_level - 1; l > 0; l--) 
                require(users[msg.sender].levelStatus[l] == true && autoPoolUniqueUsers[_userId].levelStatus[l] == true);
        }    

        if(_level == 1)  
        {
           if(!inArrayLevel1(msg.sender)){
            level_1_usersIndex[msg.sender] = level_1_users.length;
            level_1_users.push(msg.sender);
           }  
        }    
        if(_level == 2)  
        {
           if(!inArrayLevel2(msg.sender)){
            level_2_usersIndex[msg.sender] = level_2_users.length;
            level_2_users.push(msg.sender);
           }  
            
        }    
        if(_level == 3)  
        {
           if(!inArrayLevel3(msg.sender)){
            level_3_usersIndex[msg.sender] = level_3_users.length;
            level_3_users.push(msg.sender);
           }   
            
        }    
        if(_level == 4)  
        {
           if(!inArrayLevel4(msg.sender)){
            level_4_usersIndex[msg.sender] = level_4_users.length;
            level_4_users.push(msg.sender);
           }    
            
        }    
        if(_level == 5)  
        {
           if(!inArrayLevel5(msg.sender)){
            level_5_usersIndex[msg.sender] = level_5_users.length;
            level_5_users.push(msg.sender);
           }
            
        }    
        _workPlanBuy(_level);
        _autoPoolBuy(_userId,_level);
    }
    
    function failSafe(address payable _toUser, uint _amount) onlyOwner external returns (bool) {
        require(_toUser != address(0));
        usdt.transfer((address(_toUser)), _amount);
        return true;
    }
    
    function viewWPUserReferral(address _userAddress) public view returns(address[] memory) {
        return users[_userAddress].referral;
    }

    function viewAPUserReferral(uint _userId, uint8 _level) public view returns(uint[] memory) {
        return (autoPoolUniqueUsers[_userId].referral[_level]);
    }
    
    function viewAPInternalUserReferral(uint _userId, uint8 _level) public view returns(uint[] memory) {
        return (autoPoolUsers[_level][_userId].referral[_level]);
    }
    function inArrayLevel1(address referer) public view returns (bool) {
        if(level_1_usersIndex[referer] >0){
            return true;
        }
        else{
            return false;
        }
    }

    function inArrayLevel2(address referer) public view returns (bool) {
        if(level_2_usersIndex[referer] >0){
            return true;
        }
        else{
            return false;
        }
    }

    function inArrayLevel3(address referer) public view returns (bool) {
        if(level_3_usersIndex[referer] >0){
            return true;
        }
        else{
            return false;
        }
    }

    function inArrayLevel4(address referer) public view returns (bool) {
        if(level_4_usersIndex[referer] >0){
            return true;
        }
        else{
            return false;
        }
    }

    function inArrayLevel5(address referer) public view returns (bool) {
        if(level_5_usersIndex[referer] >0){
            return true;
        }
        else{
            return false;
        }
    }
    
    function viewUserLevelStatus(address _userAddress, uint8 _matrix, uint8 _level) public view returns(bool) {
        if(_matrix == 1)        
            return users[_userAddress].levelStatus[_level];
            
        if(_matrix == 2) {
            uint256 _userId = autoPoolId[_userAddress];        
            return autoPoolUniqueUsers[_userId].levelStatus[_level];
        }
    }
    
    function viewAPUserReInvestCount(uint _userId, uint8 _level) public view returns(uint) {
        return autoPoolUniqueUsers[_userId].reInvestCount[_level];
    }
   
    function _workPlanReg(uint _referrerID) internal  {
        
        address referer = userList[_referrerID];
        
        UserStruct memory userStruct;
        
        userStruct = UserStruct({
            isExist: true,
            id: userCurrentId,
            referrerID: _referrerID,
            totalDirects:0,
            currentLevel:1,
            referral: new address[](0)
        });

        users[msg.sender] = userStruct;
        users[msg.sender].levelStatus[1] = true;
        users[referer].referral.push(msg.sender);
        users[referer].totalDirects += 1;
        _workPlanPay(0,1, msg.sender);
    }
    
    function _autoPoolReg() internal  {
        
        uint _referrerID;
        
        for(uint i = APId[1]; i <= autoPoolcurrentId[1]; i++) {
            if(autoPoolUsers[1][i].referral[1].length < 5) {
                _referrerID = i; 
                break;
            }
            else if(autoPoolUsers[1][i].referral[1].length == 5) {
                APId[1] = i;
                continue;
            }
        }
        
        AutoPoolUserStruct memory nonWorkUserStruct;
        autoPoolcurrentId[1] = autoPoolcurrentId[1].add(1);
        
        nonWorkUserStruct = AutoPoolUserStruct({
            isExist: true,
            userAddress: msg.sender,
            uniqueId: userCurrentId,
            referrerID: _referrerID,
            currentLevel: 1
        });

        autoPoolUsers[1][autoPoolcurrentId[1]] = nonWorkUserStruct;
        autoPoolUserList[1][autoPoolcurrentId[1]] = msg.sender;
        autoPoolUsers[1][autoPoolcurrentId[1]].levelStatus[1] = true;
        autoPoolUsers[1][autoPoolcurrentId[1]].reInvestCount[1] = 0;
        
        autoPoolUniqueUsers[userCurrentId] = nonWorkUserStruct;
        autoPoolId[msg.sender] = userCurrentId;
        autoPoolUniqueUsers[userCurrentId].referral[1] = new uint[](0);
        autoPoolUniqueUsers[userCurrentId].levelStatus[1] = true;
        autoPoolUniqueUsers[userCurrentId].reInvestCount[1] = 0;
        
        autoPoolUsers[1][_referrerID].referral[1].push(autoPoolcurrentId[1]);
        autoPoolUniqueUsers[autoPoolId[autoPoolUsers[1][_referrerID].userAddress]].referral[1].push(userCurrentId);
        
        _updateNWDetails(_referrerID,1);
    }
    
    function _workPlanBuy(uint8 _level) internal  {
       
        users[msg.sender].levelStatus[_level] = true;
        users[msg.sender].currentLevel = _level;
       
        _workPlanPay(0,_level, msg.sender);
    }
    
    function _autoPoolBuy(uint _userId, uint8 _level) internal  {
        
        uint _referrerID;
        
        for(uint i = APId[_level]; i <= autoPoolcurrentId[_level]; i++) {
            if(autoPoolUsers[_level][i].referral[_level].length < 5) {
                _referrerID = i; 
                break;
            }
            else if(autoPoolUsers[_level][i].referral[_level].length == 5) {
                APId[_level] = i;
                continue;
            }
        }
        
        AutoPoolUserStruct memory nonWorkUserStruct;
        autoPoolcurrentId[_level] = autoPoolcurrentId[_level].add(1);
        
        nonWorkUserStruct = AutoPoolUserStruct({
            isExist: true,
            userAddress: msg.sender,
            uniqueId: _userId,
            referrerID: _referrerID,
            currentLevel: _level
        });
            
        autoPoolUsers[_level][autoPoolcurrentId[_level]] = nonWorkUserStruct;
        autoPoolUserList[_level][autoPoolcurrentId[_level]] = msg.sender;
        autoPoolUsers[_level][autoPoolcurrentId[_level]].levelStatus[_level] = true;
        
        autoPoolUniqueUsers[_userId].levelStatus[_level] = true;
        autoPoolUniqueUsers[_userId].currentLevel = _level;
        autoPoolUniqueUsers[_userId].referral[_level] = new uint[](0);
        autoPoolUniqueUsers[_userId].reInvestCount[_level] = 0;
        
        autoPoolUsers[_level][_referrerID].referral[_level].push(autoPoolcurrentId[_level]);
        autoPoolUniqueUsers[autoPoolId[autoPoolUsers[_level][_referrerID].userAddress]].referral[_level].push(autoPoolId[autoPoolUsers[_level][autoPoolcurrentId[_level]].userAddress]);
        
        _updateNWDetails(_referrerID,_level);
    }
    
    function _updateNWDetails(uint _referrerID, uint8 _level) internal {
        
        autoPoolUsers[_level][autoPoolcurrentId[_level]].referral[_level] = new uint[](0);
        
        if(autoPoolUsers[_level][_referrerID].referral[_level].length == 4) {
            _autoPoolPay(0,_level,autoPoolcurrentId[_level]);
            if(autoPoolUniqueUsers[autoPoolId[autoPoolUsers[_level][_referrerID].userAddress]].levelStatus[_level] = true 
                && autoPoolUniqueUsers[autoPoolId[autoPoolUsers[_level][_referrerID].userAddress]].reInvestCount[_level] < 5) {
                _reInvest(_referrerID,_level);
                autoPoolUniqueUsers[autoPoolId[autoPoolUsers[_level][_referrerID].userAddress]].referral[_level] = new uint[](0);
                autoPoolUniqueUsers[autoPoolId[autoPoolUsers[_level][_referrerID].userAddress]].reInvestCount[_level] =  autoPoolUniqueUsers[autoPoolId[autoPoolUsers[_level][_referrerID].userAddress]].reInvestCount[_level].add(1);
                
            }
            else if(autoPoolUniqueUsers[autoPoolId[autoPoolUsers[_level][_referrerID].userAddress]].reInvestCount[_level] == 5) {
                autoPoolUniqueUsers[autoPoolId[autoPoolUsers[_level][_referrerID].userAddress]].levelStatus[_level] = false;
                users[autoPoolUsers[_level][_referrerID].userAddress].levelStatus[_level] = false;
            }
        }
        else if(autoPoolUsers[_level][_referrerID].referral[_level].length == 1) 
            _autoPoolPay(1,_level,autoPoolcurrentId[_level]);
        else if(autoPoolUsers[_level][_referrerID].referral[_level].length == 2) 
            _autoPoolPay(1,_level,autoPoolcurrentId[_level]);
        else if(autoPoolUsers[_level][_referrerID].referral[_level].length == 3) 
            _autoPoolPay(0,_level,autoPoolcurrentId[_level]);
    }
     
    function _reInvest(uint _refId, uint8 _level) internal  {
        
        uint _reInvestId;
       
        for(uint i = APId[_level]; i <= autoPoolcurrentId[_level]; i++) {
            
            if(autoPoolUsers[_level][i].referral[_level].length < 5) {
                _reInvestId = i; 
                break;
            }
            else if(autoPoolUsers[_level][i].referral[_level].length == 5) {
                APId[_level] = i;
                continue;
            }
            
        }
        AutoPoolUserStruct memory nonWorkUserStruct;
        autoPoolcurrentId[_level] = autoPoolcurrentId[_level].add(1);
        
        nonWorkUserStruct = AutoPoolUserStruct({
            isExist: true,
            userAddress: autoPoolUserList[_level][_refId],
            uniqueId: autoPoolUsers[_level][_refId].uniqueId,
            referrerID: _reInvestId,
            currentLevel: _level
        });
            
        autoPoolUsers[_level][autoPoolcurrentId[_level]] = nonWorkUserStruct;
        autoPoolUserList[_level][autoPoolcurrentId[_level]] = autoPoolUserList[_level][_refId];
        autoPoolUsers[_level][autoPoolcurrentId[_level]].levelStatus[_level] = true;
        
        autoPoolUsers[_level][_reInvestId].referral[_level].push(autoPoolcurrentId[_level]);
        autoPoolUniqueUsers[autoPoolId[autoPoolUsers[_level][_reInvestId].userAddress]].referral[_level].push(autoPoolId[autoPoolUsers[_level][autoPoolcurrentId[_level]].userAddress]);
        
        autoPoolUsers[_level][autoPoolcurrentId[_level]].referral[_level] = new uint[](0);
        
        if(autoPoolUsers[_level][_reInvestId].referral[_level].length == 4) {
            
            if(autoPoolUniqueUsers[autoPoolId[autoPoolUsers[_level][_reInvestId].userAddress]].levelStatus[_level] = true 
                && autoPoolUniqueUsers[autoPoolId[autoPoolUsers[_level][_reInvestId].userAddress]].reInvestCount[_level] < 5) {
                _reInvest(_reInvestId,_level);
                autoPoolUniqueUsers[autoPoolId[autoPoolUsers[_level][_reInvestId].userAddress]].referral[_level] = new uint[](0);
                autoPoolUniqueUsers[autoPoolId[autoPoolUsers[_level][_reInvestId].userAddress]].reInvestCount[_level] =  autoPoolUniqueUsers[autoPoolId[autoPoolUsers[_level][_reInvestId].userAddress]].reInvestCount[_level].add(1);
            }
            else if(autoPoolUniqueUsers[autoPoolId[autoPoolUsers[_level][_reInvestId].userAddress]].reInvestCount[_level] == 5) {
                autoPoolUniqueUsers[autoPoolId[autoPoolUsers[_level][_reInvestId].userAddress]].levelStatus[_level] = false;
                users[autoPoolUsers[_level][_reInvestId].userAddress].levelStatus[_level] = false;
            }
            
        }
       
    }
    
    function _getReferrer(uint8 _level, address _user) internal returns (address) {
        if (_level == 0 || _user == address(0)) {
            return _user;
        }
        
        return _getReferrer( _level - 1,userList[users[_user].referrerID]);
    }

   function _getID(address _user) internal view returns (uint){
         return users[_user].id;
    }
 
    function _workPlanPay(uint8 _flag, uint8 _level, address _userAddress) internal {
        address referer;
        uint refererID;
        for(uint8 i = 1; i <= 5; i++) {   
            uint256 _sharePercentage;
            if(i == 1){
                _sharePercentage = LEVEL_1;
            }
            if(i == 2){
                _sharePercentage = LEVEL_2;
            }
            if(i == 3){
                _sharePercentage = LEVEL_3;
            }
            if(i == 4){
                _sharePercentage = LEVEL_4;
            }
            if(i == 5){
                _sharePercentage = LEVEL_5;
            }
           
            if(_flag == 0){
                 referer = _getReferrer(i,_userAddress);
                 refererID = _getID(referer);
             }
            else if(_flag == 1){ 
                 referer = passup;
                 refererID = _getID(referer);
             }

            if(users[referer].isExist == false){ 
                 referer = passup;
                 refererID = _getID(referer);
             }
            if(users[referer].levelStatus[_level] == true && users[referer].totalDirects >= i) {  
                uint _share = (levelPrice[_level]).mul(_sharePercentage).div(100);
                require(usdt.transfer((address(uint160(referer))), _share));
            }
            else {
                referer = passup;
                uint _share = (levelPrice[_level]).mul(_sharePercentage).div(100);
                require(usdt.transfer((address(uint160(referer))), _share));
            }
      }
    }
    
    function _autoPoolPay(uint8 _flag, uint8 _level, uint _userId) internal {
        uint refId;
        address refererAddress;

        if(_flag == 0)
          refId = autoPoolUsers[_level][_userId].referrerID;

        if(autoPoolUniqueUsers[autoPoolId[autoPoolUsers[_level][refId].userAddress]].levelStatus[_level] = true|| _flag == 1) {

            uint _share = (levelPrice[_level]).div(2);

            if(_flag == 1)
                refererAddress = rebirth;
            else
                refererAddress = autoPoolUserList[_level][refId];

            require(usdt.transfer(refererAddress, _share));
        }
        else {
            refId = autoPoolUsers[_level][_userId].referrerID;
            refererAddress = autoPoolUserList[_level][refId];
            _autoPoolPay(1, _level, refId);

        }
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}