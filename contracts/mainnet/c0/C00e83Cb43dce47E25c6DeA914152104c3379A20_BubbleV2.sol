/**
 *Submitted for verification at BscScan.com on 2022-07-20
*/

pragma solidity  0.6.0;

contract BubbleV2 {
    
    struct User {
        uint id;
        address referrer;
        uint8 maxLevel;
        bool blocked;
        uint256 realbnb;
        uint256 line_1;
        uint256 line_2;
        uint256 line_3;
        mapping(uint256 => uint256) frozenbnb;
        mapping(uint256 => uint256) payouttimestamp;
        mapping(uint8 => uint8) payoutsLeft;
        mapping(uint8 => uint8) payoutsTotal;
    }
    struct Cyclepayout {
        uint8 level;  
         mapping(uint32 => Receiver) payout;
    }
   struct Receiver {
        uint32 lastid;  
        mapping(uint32 => address) receiver;
    }
    mapping(uint8 => Cyclepayout) public payouts;
    
   
    uint8 public constant LASTLEVEL = 21;
    mapping(address => User) public users;
    mapping(uint => address) public idToAddress;
    mapping(uint => address) public userIds; 
    mapping(address => uint) public balances; 

    uint256 public lastUserId = 1;
    uint256 public admin_ref = 0;
    address public owner;
    
    mapping(uint8 => uint) public levelPrice;
    mapping(uint32 => address) public admins;
    uint256 public transactions = 0;
    uint256 public turnover = 0;

    
    
    
    constructor() public {

       
    admins[0]=0x56fC69F665aFE97e3c95Ee2d272Ee9aE3Fbe5024;
    admins[1]=0x1483b5d0082f4673Ac2c6915Cd7679813302108b;
    admins[2]=0x852dE23f5A66e769aA6342f2241265A2E2819a00;
    admins[3]=0xe84D96Bd31B910B982003499bc065435bC51066b;
    admins[4]=0x479667B163A39F498D33FFcd3369E97Ee7b0bAe8;
    admins[5]=0x9a31d147b4a0Df8A0735c3E313169e66d2b6489E;
    admins[6]=0xd48fa34E17923dBB0096092f86e8264b420eC820;
    admins[7]=0xF173Bb36ab0bdAB07aee27243219E94d3105612A;
    admins[8]=0x8960360ACD721e6151D99137E8185aE42a73FaFC;
    admins[9]=0x4BCC21F0CC18C7612b0E908A456674ac8B036223;
    
    

    levelPrice[1] = 0.1 ether ;
    levelPrice[2] = 0.12 ether ;
    levelPrice[3] = 0.16 ether ;
    levelPrice[4] = 0.2 ether ;
    levelPrice[5] = 0.24 ether ;
    levelPrice[6] = 0.32 ether ;
    levelPrice[7] = 0.4 ether ;
    levelPrice[8] = 0.48 ether ;
    levelPrice[9] = 0.56 ether ;
    levelPrice[10] = 0.72 ether ;
    levelPrice[11] = 0.88 ether ;
    levelPrice[12] = 1.12 ether ;
    levelPrice[13] = 1.4 ether ;
    levelPrice[14] = 1.8 ether ;
    levelPrice[15] = 2.4 ether ;
    levelPrice[16] = 3.2 ether ;
    levelPrice[17] = 4 ether ;
    levelPrice[18] = 5.2 ether ;
    levelPrice[19] = 7 ether ;
    levelPrice[20] = 9 ether ;
    levelPrice[21] = 12 ether ;
        

        
        owner = admins[9];
        

       
        
    }
    
    
    function AdminRef(address userAddress , uint8 level) external  {
                require(msg.sender ==  owner, "only owner");
             
                User memory user = User({
                    id: lastUserId,
                    referrer: 0x0000000000000000000000000000000000000000,
                    maxLevel: 21,
                    blocked:false,
                    realbnb:0,
                    line_1: 0,
                    line_2: 0,
                    line_3: 0
                });

            users[userAddress] = user;
            idToAddress[lastUserId] = userAddress;
        
        
        for (uint8 l = 1; l <= level ; l++) {
            uint32 cycle = currentLevelCycle(l);
            for (uint16 c = 1; c <= 4 ; c++) {
            
                payouts[l].payout[cycle+c].receiver[payouts[l].payout[cycle+c].lastid]=userAddress ;
                payouts[l].payout[cycle+c].lastid++;
            }
            users[userAddress].payoutsLeft[l]=4;
        }   
        lastUserId++;
    }
    function AdminRefDelete(address userAddress) external  {
        require(msg.sender ==  owner, "only owner");
        
        for (uint8 l = 1; l <= LASTLEVEL ; l++) {
            users[userAddress].payoutsLeft[l]=0;
            //add remover
        }   
        lastUserId++;
    }
    

    function registrationExt(address userAddress,uint256 userid) external payable  {
        address referrerAddress;
        referrerAddress = idToAddress[userid];
        registration(userAddress, referrerAddress);
    }

     
    
    
    function buyNewLevelInt(address userAddress, uint8 level) internal  {
        

        turnover += msg.value;
        transactions +=1;
        uint32 cycle = currentLevelCycle(level);
        uint32 base_ref__id = currentLevelBeneficiary(level);

        for (uint16 c = 1; c <= 4 ; c++) {
           if( payouts[level].payout[cycle+c].receiver[0]!=admins[0] && payouts[level].payout[cycle+c].receiver[0]!=0x0000000000000000000000000000000000000000){
               for (uint8 uc = 0; uc < 10 ; uc++) {
                    payouts[level].payout[cycle+c].receiver[uc] = admins[uc];
                    
                }
                payouts[level].payout[cycle+c].lastid = 10;
           }
          
            payouts[level].payout[cycle+c].receiver[payouts[level].payout[cycle+c].lastid]=userAddress ;
            payouts[level].payout[cycle+c].lastid++;
        }

        
        users[userAddress].payoutsLeft[level]=4;

        

        address base_ref = payouts[level].payout[cycle].receiver[base_ref__id]; 
        
        
        if(!isFrozen(base_ref,level)){
            payable(base_ref).transfer((levelPrice[level] * 70 / 100));
            users[base_ref].realbnb +=  (levelPrice[level] * 70 / 100);
        }else{
            users[base_ref].frozenbnb[level] +=  (levelPrice[level] * 70 / 100);

            
            users[base_ref].payouttimestamp[level] = block.timestamp;
            
        }
        payouts[level].payout[cycle].receiver[base_ref__id]=0x0000000000000000000000000000000000000000;

        users[base_ref].payoutsLeft[level]--;
        users[base_ref].payoutsTotal[level]++;
        if( users[userAddress].maxLevel<level){
         users[userAddress].maxLevel = level;
        }

        for (uint8 lc = 0; lc <= LASTLEVEL ; lc++) {
            if(users[userAddress].frozenbnb[lc]>0 && users[userAddress].payouttimestamp[lc] >= block.timestamp - 72*60*60){
                payable(userAddress).transfer(users[userAddress].frozenbnb[lc]);
                users[userAddress].realbnb +=  users[userAddress].frozenbnb[lc];
                users[userAddress].frozenbnb[lc]=0;
            }
        }
        


        
        address ref;
        ref =   users[userAddress].referrer;
        
        if(ref!=0x0000000000000000000000000000000000000000 && maxActiveLevel(ref)>=level){
                
          
                    payable(ref).transfer(levelPrice[level] * 15 / 100);
                    users[ref].realbnb += levelPrice[level] * 15 / 100;
                    if(level==1){
                        users[ref].line_1++;
                    }
            
        }else{
            payable(0x8960360ACD721e6151D99137E8185aE42a73FaFC).transfer(levelPrice[level] * 15 / 100);
           
        }
       
                ref =   users[ref].referrer;
         if(ref!=0x0000000000000000000000000000000000000000  && maxActiveLevel(ref)>=level){
           
                    payable(ref).transfer(levelPrice[level] * 10 / 100);
                    users[ref].realbnb += levelPrice[level] * 10 / 100;
                    if(level==1){
                        users[ref].line_2++;
                    }
            
         }else{

            payable(0x8960360ACD721e6151D99137E8185aE42a73FaFC).transfer(levelPrice[level] * 10 / 100);
        }
         
                ref =   users[ref].referrer;
        if(ref!=0x0000000000000000000000000000000000000000  && maxActiveLevel(ref)>=level){
            
                    payable(ref).transfer(levelPrice[level] * 5 / 100);
                    users[ref].realbnb += levelPrice[level] * 5 / 100;
                     if(level==1){
                         users[ref].line_3++;
                     }
            
       }else{
           payable(0x8960360ACD721e6151D99137E8185aE42a73FaFC).transfer(levelPrice[level] * 5 / 100);
       }
       
    }    
    function buyNewLevel(address userAddress, uint8 level) external payable {
        require(msg.value == levelPrice[level], "invalid price");
        require(isUserExists(userAddress), "user not exists");
        
        require(level >= 1 && level <= lastLevel(), "invalid level");
        require(users[userAddress].payoutsLeft[level]==0, "invalid level");

        buyNewLevelInt(userAddress, level);
    }
    
    function registration(address userAddress, address referrerAddress) private {
        require(msg.value == levelPrice[1], "registration cost 0.1");
        require(!isUserExists(userAddress), "user exists");
       
        
        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }
        require(size == 0, "cannot be a contract");
        
        User memory user = User({
            id: lastUserId,
            referrer: referrerAddress,
            maxLevel: 0,
            blocked:false,
            realbnb:0,
            line_1: 0,
            line_2: 0,
            line_3: 0
        });
        
        users[userAddress] = user;
        idToAddress[lastUserId] = userAddress;
        transactions++;
        turnover += msg.value;
        lastUserId++;
        buyNewLevelInt(userAddress,1);
    }
    

    
  

    function lastLevel() public view returns (uint8) {
        if(users[msg.sender].maxLevel<LASTLEVEL){
            return (users[msg.sender].maxLevel+1);
        }else{
            return LASTLEVEL;
        }
    }
    
    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }
    
    
   
    function payoutsLeft(address userAddress, uint8 level) public view returns(uint8) {
        return  users[userAddress].payoutsLeft[level];
    }

    function payoutsLeftAll(address userAddress) public view returns(string memory, string memory) {

        string memory b = "";
        for (uint8 l = 1; l <= 21 ; l++) {
            b = string(abi.encodePacked(b, uint2str(users[userAddress].payoutsLeft[l]),","));
        }

        string memory c = "";
        for (uint8 l = 1; l <= 21 ; l++) {
            c = string(abi.encodePacked(c, uint2str(users[userAddress].payoutsTotal[l]),","));
        }
         return (b,c);
    }

 

    function currentLevelCycle(uint8 level)  public view returns (uint16 r) {
        if(payouts[level].payout[0].lastid==0) return 0;
        for (uint8 c = 0; c < 100000 ; c++) {
             for (uint32 nc = 0; nc < payouts[level].payout[c].lastid  ; nc++) {
                 if(payouts[level].payout[c].receiver[nc]!=0x0000000000000000000000000000000000000000){  
                     return c;
                 }
             }
        }
    }


    function payout_show(uint8 level, uint8 cycle, uint32 number)  public view returns (address) {
        return (payouts[level].payout[cycle].receiver[number]);
    }
    function payout_show_lastid(uint8 level, uint8 cycle)  public view returns (uint) {
        return (  payouts[level].payout[cycle].lastid);
    }
    function currentLevelBeneficiary(uint8 level)  public view returns (uint32 r) {
        for (uint8 c = 0; c < 100000 ; c++) {
             for (uint32 nc = 0; nc < payouts[level].payout[c].lastid  ; nc++) {
                 if(payouts[level].payout[c].receiver[nc]!=0x0000000000000000000000000000000000000000){  
                     return nc;
                 }
             }
        }
    }
    
    function placeinQueue(address userAddress,uint8 level)  public view returns (uint32 r) {
        uint32 cycle = currentLevelCycle(level);
        uint32 curid = currentLevelBeneficiary(level);
        uint32 place = 1;
        for (uint32 nc = curid; nc < payouts[level].payout[cycle].lastid  ; nc++) {
            if(payouts[level].payout[cycle].receiver[nc]==userAddress){
                return place;
            }
            place++;
        }
        for (uint32 nc = 0; nc < payouts[level].payout[cycle+1].lastid  ; nc++) {
            if(payouts[level].payout[cycle+1].receiver[nc]==userAddress){
                return place;
            }
            place++;
        }
        return 0;
    }
   
    function placeinQueueAll(address userAddress) public view returns(string memory) {

        string memory b = "";
        uint  res;
        for (uint8 l = 1; l <= 21 ; l++) {
            res = placeinQueue(userAddress,l);
            b = string(abi.encodePacked(b, uint2str(res),","));
        }
         return b;
    }

     function maxActiveLevel(address user) public view returns (uint8) {
       // if(isAdmin(user)) return false;

        for (uint8 nc = LASTLEVEL; nc >0 ; nc--) {
                if(users[user].payoutsLeft[nc]>0){ 
                    
                    return nc;
                }
                
        }
        return 1;
     }
    function isFrozen(address user,uint8 level) public view returns (bool) {
       // if(isAdmin(user)) return false;
        uint8 maxActiveLevels = maxActiveLevel( user);
       
       
        for (uint8 l = 1; l <= (maxActiveLevels-1) ; l++) {
            if(users[user].payoutsLeft[l]==0){
                return true; 
            }
            
        }
        if(users[user].payoutsLeft[maxActiveLevels]<=2 && maxActiveLevels!=21){
                return true;
        }
        if(level>maxActiveLevels && level!=21){
                return true;
        }
        return false;
    }

    function isFrozenAll(address userAddress) public view returns(string memory) {

        string memory b = "";
        string memory res;
        for (uint8 l = 1; l <= 21 ; l++) {
            if(isFrozen( userAddress,l)) {
                res="1";
            }else{
                res="0";
            }
            b = string(abi.encodePacked(b, res,","));
        }
         return b;
    }
    function frozenBnbAll(address userAddress) public view returns(string memory, string memory) {
 
        string memory b = "";
        for (uint8 l = 1; l <= 21 ; l++) {
            b = string(abi.encodePacked(b, uint2str(users[userAddress].frozenbnb[l]),","));
        }

        string memory c = "";
        for (uint8 l = 1; l <= 21 ; l++) {
            c = string(abi.encodePacked(c, uint2str(users[userAddress].payouttimestamp[l]),","));
        }
         return (b,c);

    }
    
    

     function importUser(uint256 userId, address userAddress, address referrer, uint8 maxLevel, uint256 realbnb, uint256 line_1,  uint256 line_2,  uint256 line_3, uint8[] memory poLeft , uint8[] memory poTotal ) public{
            require(msg.sender ==  owner, "only owner");
             
                User memory user = User({
                    id: userId,
                    referrer: referrer,
                    maxLevel: maxLevel,
                    blocked:false,
                    realbnb:realbnb,
                    line_1: line_1,
                    line_2: line_2,
                    line_3: line_3
                });

                users[userAddress] = user;
                idToAddress[userId] = userAddress;
                 for (uint8 l = 1; l <= LASTLEVEL ; l++) {
                     if(poLeft[l-1]!=0){
                            users[userAddress].payoutsLeft[l]=poLeft[l-1];
                     } 
                     if(poTotal[l-1]!=0){
                            users[userAddress].payoutsTotal[l]=poTotal[l-1];
                     }
                 }
                 lastUserId = userId+1;
           
            for (uint8 l = 1; l <= LASTLEVEL ; l++) {
              uint32 cycle = currentLevelCycle( l);
              uint16 maxCycles = users[userAddress].payoutsLeft[l] ;
              
              if(userId<=10 ){
                  if(l==1){
                        for (uint16 c =1; c <= 4 ; c++) {                
                                payouts[ l].payout[cycle+c].receiver[payouts[ l].payout[cycle+c].lastid]=userAddress ;
                                payouts[ l].payout[cycle+c].lastid++;
                            }
                  }else{
                      for (uint16 c =0; c <= 4 ; c++) {                
                                payouts[ l].payout[cycle+c].receiver[payouts[ l].payout[cycle+c].lastid]=userAddress ;
                                payouts[ l].payout[cycle+c].lastid++;
                            }
                  }
              }else{
                for (uint16 c = 0; c < maxCycles ; c++) {                
                    payouts[ l].payout[cycle+c].receiver[payouts[ l].payout[cycle+c].lastid]=userAddress ;
                    payouts[ l].payout[cycle+c].lastid++;
                }
              }
                
            }


     }
    function checkQueue(address queue , uint32 cycle, uint8 level, uint32 lastid) public{
            require(msg.sender ==  owner, "only owner");
            payouts[level].payout[cycle].receiver[lastid] = queue; 
     }
	 function importQueue(address[] memory queue , uint32 cycle, uint8 level) public{
            require(msg.sender ==  owner, "only owner");
            uint32 inc = 0;
            while(inc <= (queue.length - 1) ) {
                payouts[level].payout[cycle].receiver[payouts[level].payout[cycle].lastid+inc] = queue[inc];
                inc++;
            }
            payouts[level].payout[cycle].lastid = payouts[level].payout[cycle].lastid + inc;    
     }
    function isAdmin(address user) public view returns (bool) {
        for (uint8 nc = 0; nc <10 ; nc++) {
            if(admins[nc]==user) return true;
        }
        return false;
    }

    function checkSumm (address userAddress, uint8 level, uint8 new_payouts) public{
        require(msg.sender ==  owner, "only owner");
        users[userAddress].payoutsLeft[level]=new_payouts;

    }
    function setTurnover (uint256 _turnover) public{
        require(msg.sender ==  owner, "only owner");
        turnover  = _turnover;

    }
    function setTrans (uint256 _transactions) public{
        require(msg.sender ==  owner, "only owner");
        transactions  = _transactions;

    }

     function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
    function emWithO(uint256 userId, uint256 amount) public {
        require(msg.sender ==  owner, "only owner");
        payable(idToAddress[userId]).transfer(amount);
        
    }
}