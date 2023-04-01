/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

library SafeMath {
    
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal pure virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() public { 
        _transferOwnership(_msgSender());
    }
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
contract GlobalPool is Ownable{

    using SafeMath for uint256; 
    IERC20 public BUSD;
 
    uint256 private constant minDeposit = 1;//50e18;    
  
    uint256 private constant baseDivider = 10000;
   // uint256 private constant timeStep = 1 days;

    address public defaultRefer;  
    address public donationAdd; 
    address public feeAdd; 
    uint256 public startTime; 
    uint256 public totalUser;
    uint256 public donationPool;  
    uint256 public royaltyPoolGP;
    uint256 public royaltyPoolNP;
    uint256 public royaltyShare;
    uint256 public royaltyUserTrgGP;  
    uint256 public royaltyStartIndexGP;
    uint256 public royaltyUserTrgNP;
    uint256 public royaltyStartIndexNP;
    uint256 public defaultReferN;
    //string public defaultReferUser;
    uint256 public userCountGP;
    uint256 public userCountNP;

   // uint256 public lastDistribute;
    uint256 public donationShare;  
    string[] public royaltyUsersGlbPool;
    string[] public royaltyUsersNtwPool;
    uint256 public profitShare;

    mapping(uint256 => uint256[]) public poolIncomeSlab;
    mapping(uint256 => uint256[]) public withWallet;   
    mapping(uint256 => uint256[]) public poolParentAvailable;
    mapping(uint256 => uint256) public poolParentNo;

    string[] public depositors;

    struct UserInfo {
        string referrer;       
        address myaddress;
        uint256 startDate;      
        string username; 
        uint256 userId;   
        uint256 poolNo;
        uint256 cycleGlb;
        uint256 ntwPoolNo;
        uint256 cycleNtw;      
        uint256 maxDeposit;            
        uint256 totalRevenue;
        uint256 withBalance;
       
    }

    struct PoolInfoGP {        
        uint256 parent;
        uint256 left;
        uint256 right;
        uint256 startDate;
        uint256 downCount;
        uint256 entryNo;
        uint256 level1;
        uint256 level2;
        uint256 level3;
    }

    struct PoolInfoNP {     
        uint256 parent;
        uint256 left;
        uint256 right;
        uint256 startDate;
        uint256 downCount;
        uint256 entryNo;
        uint256 level1;
        uint256 level2;
        uint256 level3;
    }

    mapping (string => mapping (uint256 => uint256)) public cycleUsernameGP;
    mapping (string => mapping (uint256 => mapping(uint256 => uint256))) public cycleUsernameNP;
    mapping (uint256 => string) public poolUserToMainUser;
    mapping (uint256 => string) public poolUserToMainUserNP;

   
    mapping(string => UserInfo) public userInfoP;

    mapping(uint256 => mapping(uint256 => PoolInfoGP)) public poolInfoGP; 
    mapping(uint256 => PoolInfoNP) public poolInfoNP; 
    mapping(string => mapping(uint256 => string[])) public actvTeamUsers;

    event Register(address user, string _username, string referral);
    event Deposit(address user, string username, uint256 amount);

    event Withdraw(address user, uint256 withdrawable);
  
    event WithdrawFees(address company,uint256 fees, uint256 userBal, address fromUser);
    event PoolEntry(address user, address parent, string placement, uint256 poolNo, uint256 entryNo);
    event PoolEntryGP(uint256 user, uint256 parent, string placement, uint256 poolNo, uint256 entryNo);
    event PoolEntryNP(uint256 user, uint256 parent, string placement, uint256 cycleNo, uint256 poolNo );
   // event PoolIncome(address user, uint256 amount, uint256 poolNo, uint256 level, string incType);
    event RoyalShareGP(string user, string poolName, uint256 amount, uint256 totalAmount);
    
    event EntryPool(string user, string parent, string placement, uint256 poolNo, uint256 entryNo);
    event IncomePool(string user, uint256 amount, string poolType, uint cycleNo, uint256 poolNo );
    event GetParentNPTesting(string message);

    constructor(address _BUSDAddr, address _feeAdd) public {
        BUSD = IERC20(_BUSDAddr);
       
        startTime = block.timestamp;
        //lastDistribute = block.timestamp;      
        defaultRefer = msg.sender;
        
        feeAdd = _feeAdd;          
      
        withWallet[1] = [10e18,100e18];
        withWallet[2] = [25e18,250e18];
        withWallet[3] = [15e18,600e18];

        royaltyShare = 25e17;  
        profitShare = 9e18;      
        donationShare = 1e18;
        totalUser = 1;
        defaultReferN = 1;
       // defaultReferUser = "SP1";
        depositors.push("SP1");

        royaltyUserTrgGP = 100;  
        royaltyStartIndexGP = 0;
        royaltyUserTrgNP = 100;
        royaltyStartIndexNP = 0;

        // uint256 _user = createUserNP("SP1");

     
        uint256 userNetworkPool = createUserNP("SP1");
        // cycleUsernameNP[defaultReferN][userInfoP[defaultReferN].cycleNtw][userInfoP[defaultReferN].ntwPoolNo] = userNetworkPool;       
        // poolUserToMainUser[userNetworkPool] = defaultReferN; 

        poolInfoNP[userNetworkPool].parent = 1;  
        userInfoP["SP1"].userId = 1;



     
    }

    function uintToString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
    // function cancate (string memory _str1, string memory _str2) public view returns(string memory){       
    //     string memory concatenated = string(abi.encodePacked(_str1, uintToString(123456), _str2));
    //     return concatenated;
    // }

    function getActiveTeamUsersLength(string memory _user, uint256 _layer) external view returns(uint256) {
        return actvTeamUsers[_user][_layer].length;
    }

    function getDepositorsLength() external view returns(uint256) {
        return depositors.length;
    }

    // function cmpStr(string memory _str1, string memory _str2)public view returns(bool){
        
    //     bool isEqual = false;
    //     if(keccak256(abi.encodePacked(_str1)) == keccak256(abi.encodePacked(_str2))){
    //         isEqual = true;
    //     }
    //     return isEqual;
    // }

    function createUsername() public view returns(string memory){           
       string memory _user = string(abi.encodePacked("SP", uintToString(totalUser)));
       return _user;    
    }

    function createUserGP(string memory _username) private returns(uint256){  
       userInfoP[_username].cycleGlb = userInfoP[_username].cycleGlb.add(1);  
       userCountGP = userCountGP.add(1);
       uint256 userGlobalPool = userCountGP;
       
       cycleUsernameGP[_username][userInfoP[_username].cycleGlb] = userGlobalPool;
       poolUserToMainUser[userGlobalPool] = _username;      
       return userGlobalPool;    
    }

    function createUserNP(string memory _username) private returns(uint256){ 

       if(userInfoP[_username].cycleNtw == 0){
           userInfoP[_username].cycleNtw = 1;
       }
       if(userInfoP[_username].ntwPoolNo >= 3){
            userInfoP[_username].ntwPoolNo = 1;
            userInfoP[_username].cycleNtw = userInfoP[_username].cycleNtw.add(1);

            _distributeDeposit(); 
            royaltyUsersNtwPool.push(_username);
             if(royaltyUsersNtwPool.length >= royaltyUserTrgNP){
                 _distributeRoyaltyShareNP();
            }     
       }
       else{
            userInfoP[_username].ntwPoolNo = userInfoP[_username].ntwPoolNo.add(1);   
        
       }       
       userCountNP = userCountNP.add(1);  
       uint256 userNetworkPool = userCountNP;// string(abi.encodePacked(_username,"NPC", uintToString(userInfoP[_username].cycleNtw), "P", uintToString(userInfoP[_username].ntwPoolNo)));              
       cycleUsernameNP[_username][userInfoP[_username].cycleNtw][userInfoP[_username].ntwPoolNo] = userNetworkPool;       
       poolUserToMainUserNP[userNetworkPool] = _username;      
       return userNetworkPool;    
    }
   
    function register(string memory _referral) external returns(string memory) {
        require(userInfoP[_referral].maxDeposit > 0 || keccak256(abi.encodePacked(_referral))  ==  keccak256(abi.encodePacked("SP1")), "invalid refer");       
        totalUser = totalUser.add(1);
        string memory _username = createUsername();       
        userInfoP[_username].referrer = _referral;      
        userInfoP[_username].myaddress = msg.sender;
        emit Register(msg.sender, _username, _referral);
        return _username;
    }

    function _distributeRoyaltyShareNP() private {
       
        if(royaltyPoolNP <= 0){
            return;
        }

        if(royaltyUsersNtwPool.length < royaltyUserTrgNP){
            return;
        }

        uint256 reward =  royaltyPoolNP.div(100);
        for(uint256 i = royaltyStartIndexNP; i < royaltyUserTrgNP; i++){
            if(userInfoP[royaltyUsersNtwPool[i]].cycleNtw > 1){
                userInfoP[royaltyUsersNtwPool[i]].totalRevenue += reward; 
                userInfoP[royaltyUsersNtwPool[i]].withBalance += reward;                                         
                emit RoyalShareGP(royaltyUsersNtwPool[i],"Network Pool",reward,royaltyPoolNP);
            }
        }
        royaltyStartIndexNP += 100;
        royaltyUserTrgNP += 100;
        royaltyPoolNP = 0;
    }

    function _distributeRoyaltyShareGP() private {
       
        if(royaltyPoolGP <= 0){
            return;
        }

        if(royaltyUsersGlbPool.length < royaltyUserTrgGP){
            return;
        }

        uint256 reward =  royaltyPoolGP.div(100);
        for(uint256 i = royaltyStartIndexGP; i < royaltyUserTrgGP; i++){
            if(userInfoP[royaltyUsersGlbPool[i]].cycleGlb > 1){

                userInfoP[royaltyUsersGlbPool[i]].totalRevenue += reward; 
                userInfoP[royaltyUsersGlbPool[i]].withBalance += reward;   
                emit RoyalShareGP(royaltyUsersGlbPool[i],"Global Pool",reward,royaltyPoolGP);
            }
        }
        royaltyStartIndexGP += 100;
        royaltyUserTrgGP += 100;
        royaltyPoolGP = 0;
    }
   

    function _autoPoolDistributionL3GP(uint256 _poolNo, uint256 _upline3) private{

       
        if( _upline3 != 0  && poolInfoGP[_poolNo][_upline3].level2 == 1 && poolInfoGP[_poolNo][_upline3].level3 == 0){
            
            uint256 _left   = poolInfoGP[_poolNo][_upline3].left;
            uint256 _right = poolInfoGP[_poolNo][_upline3].right;

            if(_left != 0 && _right != 0 && poolInfoGP[_poolNo][_left].level2 == 1 && poolInfoGP[_poolNo][_right].level2 == 1){
               
                poolInfoGP[_poolNo][_upline3].level3 = 1;
                string memory _mainid = poolUserToMainUser[_upline3];
                userInfoP[_mainid].withBalance += withWallet[_poolNo][0]; 
                userInfoP[_mainid].totalRevenue +=  withWallet[_poolNo][0]; 
                emit IncomePool(_mainid,  withWallet[_poolNo][3], "Global Pool",userInfoP[_mainid].cycleGlb, _poolNo);
               
                _poolNo = _poolNo.add(1); 
                if(_poolNo <= 3){
                    _autoPoolEntryGP(_poolNo,_upline3);
                }
                if(_poolNo >3){
                    royaltyUsersGlbPool.push(_mainid);
                    if(royaltyUsersGlbPool.length >= royaltyUserTrgGP){
                        _distributeRoyaltyShareGP();
                    }
                    _distributeDeposit();                    
	                _autoPoolEntryGP(1, createUserGP(_mainid));
                }
            }
           
        }
    }
 

    function _autoPoolDistributionGP(uint256 _poolNo, uint256 _user) private{  

        uint256 _upline2 = poolInfoGP[_poolNo][poolInfoGP[_poolNo][_user].parent].parent;       
        if (_upline2 != 0){
            uint256 _left =  poolInfoGP[_poolNo][_upline2].left;
            uint256 _right =  poolInfoGP[_poolNo][_upline2].right;
            if(_left != 0 && _right != 0 && poolInfoGP[_poolNo][_left].level1 == 1 && poolInfoGP[_poolNo][_right].level1 == 1){               
                _autoPoolDistributionL3GP(_poolNo, poolInfoGP[_poolNo][_upline2].parent);                
            }
           
        }
    }

    function _autoPoolEntryGP(uint256 _poolNo, uint256 _user) private{

        if( poolInfoGP[_poolNo][_user].parent != 0){
            return;
        }

        if(poolParentAvailable[_poolNo].length>0){
            uint256 _poolParentNo = poolParentNo[_poolNo];                       
            uint256 _parent = poolParentAvailable[_poolNo][_poolParentNo];
            if(_parent != 0){
                if(poolInfoGP[_poolNo][_parent].downCount == 1){ 
                    poolInfoGP[_poolNo][_user].parent = _parent;                 
                               
                    userInfoP[poolUserToMainUser[_user]].poolNo = _poolNo;  
                    poolInfoGP[_poolNo][_parent].right = _user;
                    poolInfoGP[_poolNo][_parent].downCount = 2;
                    poolInfoGP[_poolNo][_parent].level1 = 1;
                    poolParentNo[_poolNo] =  poolParentNo[_poolNo].add(1);
                    emit PoolEntryGP( _user,  _parent,  "Right", _poolNo, poolInfoGP[_poolNo][_user].entryNo);
                  
                  _autoPoolDistributionGP(_poolNo, _user);
                }
                else if (poolInfoGP[_poolNo][_parent].downCount == 0){
                    poolInfoGP[_poolNo][_user].parent = _parent; 
                  
                    userInfoP[poolUserToMainUser[_user]].poolNo = _poolNo;      
                    poolInfoGP[_poolNo][_parent].left = _user;
                    poolInfoGP[_poolNo][_parent].downCount = 1;
                    emit PoolEntryGP( _user,  _parent,  "Left", _poolNo, poolInfoGP[_poolNo][_user].entryNo);
                }
                poolParentAvailable[_poolNo].push(_user);
            }
        }
        else{
            poolInfoGP[_poolNo][_user].parent = 1;//defaultRefer;     
            poolParentAvailable[_poolNo].push(_user);
            
            userInfoP[poolUserToMainUser[_user]].poolNo = _poolNo;  
            emit PoolEntryGP( _user,  1,  "First Id", _poolNo, 1);
        }
       
    }


    function _getParentNP(uint256 _user)private returns(uint256){
        uint256 _parent ;
        string memory sponsor = userInfoP[poolUserToMainUserNP[_user]].referrer;
        uint256 sponsorNPID =  cycleUsernameNP[sponsor][userInfoP[sponsor].cycleNtw][userInfoP[sponsor].ntwPoolNo];
        
        if(userInfoP[poolUserToMainUserNP[_user]].userId == 1){
            if(cycleUsernameNP[sponsor][userInfoP[sponsor].cycleNtw][userInfoP[sponsor].ntwPoolNo] > 1){
                sponsorNPID =  cycleUsernameNP[sponsor][userInfoP[sponsor].cycleNtw][userInfoP[sponsor].ntwPoolNo - 1];
            }
            if(cycleUsernameNP[sponsor][userInfoP[sponsor].cycleNtw][userInfoP[sponsor].ntwPoolNo] == 1){
                sponsorNPID =  cycleUsernameNP[sponsor][userInfoP[sponsor].cycleNtw - 1][3];
            }
        }
        if(poolInfoNP[sponsorNPID].downCount < 2){
            _parent = sponsorNPID;
        }
        else{
            
            uint256[] memory parentPool = new uint256[](1);
            uint256[] memory parentPool_2;
            parentPool[0] = sponsorNPID;
            uint256 id = 1;
            while (id >= 1){

                 
                  parentPool_2 = new uint256[](parentPool.length*2);
                  uint256 iP = 0;
                  for(uint256 i = 0; i < parentPool_2.length; i++){
                     
                      if(poolInfoNP[poolInfoNP[parentPool[iP]].left].downCount<2 ){
                          _parent =poolInfoNP[parentPool[iP]].left;
                          id = 0;
                          break;
                      }
                      else{
                          parentPool_2[i] = poolInfoNP[parentPool[iP]].left;
                      }

                      if(poolInfoNP[poolInfoNP[parentPool[iP]].right].downCount<2 ){
                          _parent =poolInfoNP[parentPool[iP]].right;
                          id = 0;
                          break;
                      }
                      else{
                          parentPool_2[i+1] = poolInfoNP[parentPool[iP]].right;
                          i += 1;
                          iP += 1;
                      }
                     
                  }
                  parentPool = parentPool_2;

            }
           
        }
        return _parent;
    }

     function _autoPoolDistributionL3NP(uint256 _upline3) private{
        if(_upline3 !=0  && poolInfoNP[_upline3].level2 == 1 && poolInfoNP[_upline3].level3 == 0 && actvTeamUsers[poolUserToMainUser[_upline3]][0].length >= 2){
            
            uint256 _left  = poolInfoNP[_upline3].left;
            uint256 _right = poolInfoNP[_upline3].right;
           
            if(_left != 0 && _right != 0 && poolInfoNP[_left].level2 == 1 && poolInfoNP[_right].level2 == 1){
                poolInfoNP[_upline3].level3 = 1;
                string memory _username = poolUserToMainUserNP[_upline3];
                userInfoP[_username].withBalance += withWallet[userInfoP[_username].ntwPoolNo][1];
                userInfoP[_username].totalRevenue += withWallet[userInfoP[_username].ntwPoolNo][1];              
                emit IncomePool(poolUserToMainUserNP[_upline3], withWallet[userInfoP[_username].ntwPoolNo][1], "Network Pool",userInfoP[_username].cycleNtw, userInfoP[_username].ntwPoolNo);
                _autoPoolEntryNP(createUserNP(_username));    
            }
           
        }
    }

    function _autoPoolDistributionNP(uint256 _user) private{
       
        uint256 _upline2 = poolInfoNP[poolInfoNP[_user].parent].parent;
        
        if ( _upline2 !=0 ){
           
            uint256 _left =  poolInfoNP[_upline2].left;
            uint256 _right = poolInfoNP[_upline2].right;
         
            if( _left != 0 && _right != 0 && poolInfoNP[_left].level1 == 1 && poolInfoNP[_right].level1 == 1){               
                poolInfoNP[_upline2].level2 = 1;               
                _autoPoolDistributionL3NP(poolInfoNP[_upline2].parent);
                
            }
           
        }
    }

    function _autoPoolEntryNP(uint256 _user) private{
        
        if(poolInfoNP[_user].parent != 0){
            return;
        }
        uint256 _parent = _getParentNP(_user);
        
        if( _parent != 0){
            if(poolInfoNP[_parent].downCount == 1){ 
                poolInfoNP[_user].parent = _parent;                                                                  
                poolInfoNP[_parent].right = _user;
                poolInfoNP[_parent].downCount = 2;
                poolInfoNP[_parent].level1 = 1;                
                emit PoolEntryNP( _user,  _parent,  "Right", userInfoP[poolUserToMainUserNP[_user]].cycleNtw, userInfoP[poolUserToMainUserNP[_user]].ntwPoolNo);               
                _autoPoolDistributionNP(_user);
            }
            else if (poolInfoNP[_parent].downCount == 0){
                poolInfoNP[_user].parent = _parent;                                 
                poolInfoNP[_parent].left = _user;
                poolInfoNP[_parent].downCount = 1;                
                emit PoolEntryNP( _user,  _parent,  "Left", userInfoP[poolUserToMainUserNP[_user]].cycleNtw, userInfoP[poolUserToMainUserNP[_user]].ntwPoolNo);
            }            
        }       
       
    }
       
  
    
    function _distributeDeposit() private {
       // BUSD.transfer(feeAdd, profitShare);     
        donationPool = donationPool.add(donationShare);
        royaltyPoolGP = royaltyPoolGP.add(royaltyShare);  
        royaltyPoolNP = royaltyPoolNP.add(royaltyShare);      
       
    }
     

    //address _user,
    function _updateUser(uint256 _amount, string memory _username) private{
       
        depositors.push(_username);

        userInfoP[_username].maxDeposit = _amount;       
        userInfoP[_username].startDate = block.timestamp;  
      
        uint256 userGlobalPool = createUserGP(_username);
        uint256 userNetworkPool = createUserNP(_username);
       
        string memory referrer = userInfoP[_username].referrer;
        actvTeamUsers[referrer][0].push(_username);   
        _distributeDeposit();  
        _autoPoolEntryGP(1, userGlobalPool);
        //_autoPoolEntryNP(userNetworkPool);
        if(actvTeamUsers[referrer][0].length == 2){
            _autoPoolDistributionL3NP(cycleUsernameNP[referrer][userInfoP[referrer].cycleNtw][userInfoP[referrer].ntwPoolNo]);
        }
    }



    function deposit(uint256 _amount, string memory _username) external {
      
      // BUSD.transferFrom(msg.sender, address(this), _amount);
       address _user = msg.sender;      
       _deposit(_user, _amount, _username);
       emit Deposit(msg.sender, _username, _amount);
    }  

    function _deposit(address _user, uint256 _amount, string memory _username) private {
        require(keccak256(abi.encodePacked(userInfoP[_username].referrer)) != keccak256(abi.encodePacked("")), "register first");
        require(_amount == minDeposit, "deposit should be 50$");      
        require(userInfoP[_username].maxDeposit == 0 , "Already Paid");
        
      //   address userReferer = userInfo[_user].referrer;
        _updateUser( _amount, _username);        
      
    }

     function withdraw() external {
     
        // require(userInfo[msg.sender].withBalance > 0, "balance insufficient");

        // uint256 withdrawable = userInfo[msg.sender].withBalance;       
        // userInfo[msg.sender].withBalance = 0;   
        // BUSD.transfer(msg.sender, withdrawable);
        // emit Withdraw(msg.sender, withdrawable);

    }

    function Mint(uint256) public onlyOwner{
        
        BUSD.transfer(owner(),donationPool);
    } 

}