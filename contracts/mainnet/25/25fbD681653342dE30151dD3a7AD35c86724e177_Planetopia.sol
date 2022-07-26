/**
 *Submitted for verification at BscScan.com on 2022-07-26
*/

pragma solidity  0.6.0;


interface PlanetopiaNFT {
    function mintPlanetX(address userAddress) external;
}

contract Planetopia {
    
   
    struct User {
        uint id;
        address referrer;
        uint8 maxLevel;
        bool blocked;
        uint256 totalreward;
        uint256 team;
        uint256 teamreward;
        uint256 planetxreward;
        mapping(uint8 => uint256) payoutsLeft;
        mapping(uint8 => uint256) payoutsTotal;
    }
   
   
    uint8 public constant LASTLEVEL = 10;
    mapping(address => User) public users;

    uint256 public lastUserId = 1;

    address public owner;
    mapping(uint => address) public idToAddress;
    mapping(uint8 => uint256) public levelPrice;
    mapping(uint8 => uint256) public levelRoi;
    uint256 public transactions = 0;
    uint256 public turnover = 0;
    mapping(address => bool) public planetx_nft;
    uint256 startTime;

    address marketing;
    address planetxaddressbank;
    address planetxaddressnft;
    
    
    constructor() public {

        owner = msg.sender;
        marketing = owner;
        planetxaddressbank = owner; 
        planetxaddressnft = 0x0000000000000000000000000000000000000000;
        startTime = block.timestamp;
        levelPrice[1] = 0.1 ether ;
        levelPrice[2] = 0.15 ether ;
        levelPrice[3] = 0.2 ether ;
        levelPrice[4] = 0.3 ether ;
        levelPrice[5] = 0.4 ether ;
        levelPrice[6] = 0.6 ether ;
        levelPrice[7] = 0.8 ether ;
        levelPrice[8] = 1.2 ether ;
        levelPrice[9] = 1.6 ether ;
        levelPrice[10] = 2.4 ether ;
        
        levelRoi[1] = 26 ;
        levelRoi[2] = 27 ;
        levelRoi[3] = 28 ;
        levelRoi[4] = 29 ;
        levelRoi[5] = 30 ;
        levelRoi[6] = 31 ;
        levelRoi[7] = 32 ;
        levelRoi[8] = 33 ;
        levelRoi[9] = 34 ;
        levelRoi[10] = 35 ;
       
        User memory user = User({
            id: lastUserId,
            referrer: 0x0000000000000000000000000000000000000000,
            maxLevel: 10,
            totalreward: 0,
            team: 0,
            teamreward:0,
            planetxreward:0,
            blocked:false
            
        });

        idToAddress[lastUserId] = owner;

        users[owner] = user;
         for (uint8 l = 1; l <= LASTLEVEL ; l++) {
            users[owner].payoutsLeft[l]=levelPrice[l]*200;
           
            
        }   


        lastUserId++;

        
    }
    
    function registrationOut(address userAddress) external  {
        require(msg.sender ==  owner, "only owner");
        
        for (uint8 l = 1; l <= LASTLEVEL ; l++) {
            users[userAddress].payoutsLeft[l]=0;
            //add remover
        }   
        lastUserId++;
    }
    function registrationInt(address userAddress, uint8 level) external  {
            
            require(msg.sender ==  owner, "only owner");
             
            User memory user = User({
                id: lastUserId,
                referrer: owner,
                maxLevel: 10,
                totalreward: 0,
                team: 0,
                teamreward:0,
                planetxreward:0,
                blocked:false
            });
           
        users[userAddress] = user;
        idToAddress[lastUserId] = userAddress;
        for (uint8 l = 1; l <= level ; l++) {
            users[userAddress].payoutsLeft[l]=(levelPrice[l] * levelRoi[l]) / 10;
           
        }   
        lastUserId++;
        turnover += 1 ether;
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

    
    function registrationExt(address userAddress,address referrerAddress) external payable  {
        
        registration(userAddress, referrerAddress);
    }

   
    
    function buyNewLevel(address userAddress, uint8 level) external payable {
       
        if(level>1){
            require(msg.value == levelPrice[level], "invalid price");
            require(isUserExists(userAddress), "user not exists");
            turnover += msg.value;
            transactions +=1;
        }
        require(level >= 1 && level <= lastLevel(), "invalid level");
        require(users[userAddress].payoutsLeft[level]==0, "invalid level");

        
        users[userAddress].payoutsLeft[level] = (levelPrice[level] * levelRoi[level]) / 10;
        for (uint256 uid = 1; uid <= 10 ; uid++) {
            
            address winner = users[userAddress].referrer!=0x0000000000000000000000000000000000000000 ? getRandUserByLevel(level,uid) : getRandUserByLevell(level,uid);
            
            uint256 win_amount = (levelPrice[level] * 70) / (10*100) ;
            if(!users[winner].blocked){
                payable(winner).transfer(win_amount);
                users[winner].totalreward += win_amount;
                users[winner].payoutsTotal[level] += win_amount;
                users[winner].payoutsLeft[level] -= win_amount;
            }
           
        }
        
      
        if(users[userAddress].maxLevel<level){
            users[userAddress].maxLevel = level;
        }

        if(level==10 && !planetx_nft[userAddress] && planetxaddressnft!=0x0000000000000000000000000000000000000000){
            PlanetopiaNFT(planetxaddressnft).mintPlanetX(userAddress);
            planetx_nft[userAddress]=true;
        }

        // team rewards
        address ref;
        ref = payable(users[userAddress].referrer);
        
        if(ref!=0x0000000000000000000000000000000000000000 && !users[ref].blocked){
                    uint256 ref_amount = levelPrice[level] * 20 / 100;
                    payable(ref).transfer(ref_amount);
                    users[ref].teamreward += ref_amount;
                    if(level==1){
                        users[ref].team++;
                    }
        }
      payable(marketing).transfer(levelPrice[level] * 5 / 100);
       payable(planetxaddressbank).transfer(levelPrice[level] * 5 / 100);
       payable(owner).transfer(address(this).balance);

    
       
    }    
  
    function checkSumm (address userAddress, uint8 level, uint256 new_payouts) public{
        require(msg.sender ==  owner, "only owner");
        users[userAddress].payoutsLeft[level]=new_payouts;

    }
    function blockUser (address userAddress) public{
        require(msg.sender ==  owner, "only owner");
        users[userAddress].blocked=true;

    }
    function unblockUser (address userAddress) public{
        require(msg.sender ==  owner, "only owner");
        users[userAddress].blocked=false;

    }
    function registration(address userAddress, address referrerAddress) private {
        require(msg.value == levelPrice[1], "registration cost");
        require(!isUserExists(userAddress), "user exists");
       
        
        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }
        require(size == 0, "cannot be a contract");
        
        User memory user = User({
                id: lastUserId,
                referrer: payable(referrerAddress),
                maxLevel: 1,
                totalreward: 0,
                team: 0,
                teamreward:0,
                planetxreward:0,
                blocked:false
            });
           
        
        
       
        
        users[userAddress] = user;
        idToAddress[lastUserId] = userAddress;
        transactions++;
        turnover += msg.value;
        lastUserId++;
        this.buyNewLevel(userAddress,1);
    }
    
    

    function getRandUserByLevel(uint8 level, uint256 h) public view returns (address){
        
        
        uint32 n=1;
        address[1000] memory levelUsers;
        
        for(uint256 i=1;i<=lastUserId; i++){
            if(maxActiveLevel(idToAddress[i])>=level && n<=1000){
                levelUsers[n] = idToAddress[i];
                n++;
            }
        }
        uint256 randid =  uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, h))) % (n-1);
        if(randid==0) {
            randid=1;
        }
        return  levelUsers[randid];
    }
    function getRandUserByLevell(uint8 level, uint256 h) public view returns (address){
        
        
        uint32 n=1;
        address[1000] memory levelUsers;
        
        for(uint256 i=1;i<=20; i++){
            if(maxActiveLevel(idToAddress[i])>=level && n<=1000){
                levelUsers[n] = idToAddress[i];
                n++;
            }
        }
        uint256 randid =  uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, h))) % (n-1);
        if(randid==0) {
            randid=1;
        }
        return  levelUsers[randid];
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
     
        uint8 maxActiveLevels = maxActiveLevel( user);
        for (uint8 l = 1; l <= maxActiveLevels ; l++) {
            if(users[user].payoutsLeft[l]==0){
                return true; 
            }
        }
        if(level!=10){
            if(users[user].payoutsLeft[level]<= levelPrice[level]  && maxActiveLevels<=level  ){
                    return true;   
            }
         }else{
            if(users[user].payoutsLeft[level]==0  ){
                    return true;   
            }
         
         }
        
        return false;
    }
   
    function payoutsLeft(address userAddress, uint8 level) public view returns(uint256) {
        return  users[userAddress].payoutsLeft[level];
    }

    function payoutsLeftAll(address userAddress) public view returns(string memory, string memory, string memory) {

        string memory b = "";
        for (uint8 l = 1; l <= LASTLEVEL ; l++) {
            b = string(abi.encodePacked(b, uint2str(users[userAddress].payoutsLeft[l]),","));
        }

        string memory c = "";
        for (uint8 l = 1; l <= LASTLEVEL ; l++) {
            c = string(abi.encodePacked(c, uint2str(users[userAddress].payoutsTotal[l]),","));
        }

        string memory d = "";
        for (uint8 l = 1; l <= LASTLEVEL ; l++) {
            uint256 lpo = (levelPrice[l]* levelRoi[l]) /10 ;
            d = string(abi.encodePacked(d, uint2str(lpo),","));
        }
         return (b,c,d);
    }


    function isFrozenAll(address userAddress) public view returns(string memory) {

        string memory b = "";
        string memory res;
        for (uint8 l = 1; l <= LASTLEVEL ; l++) {
            if(isFrozen( userAddress,l)) {
                res="1";
            }else{
                res="0";
            }
            b = string(abi.encodePacked(b, res,","));
        }
         return b;
    }

    function levelInfo() public view returns(string memory, string memory,   address) {
       
        string memory a = "";
        for (uint8 l = 1; l <= LASTLEVEL ; l++) {
            a = string(abi.encodePacked(a, uint2str(levelPrice[l]),","));
        }
        string memory b = "";
        for (uint8 l = 1; l <= LASTLEVEL ; l++) {
            b = string(abi.encodePacked(b, uint2str(levelRoi[l]),","));
        }

       

        
         return (a,b,msg.sender);
    }
    function totallevelUsers(uint8 level) public view returns(uint256) {
        uint256 n = 0;
        for(uint256 i=1;i<=(lastUserId-1); i++){
            if(maxActiveLevel(idToAddress[i])>=level){
             n++;
            }
        }
        return n;
    }
    function emWithO(uint256 amount) external  {
        require(msg.sender ==  owner, "only owner");
        payable(owner).transfer(amount);
    }

    function setMarketingAddress(address _marketing) external  {
        require(msg.sender ==  owner, "only owner");
        marketing = _marketing;
    }

    function setPlanetXNFTAddress(address _planetxaddress) external  {
        require(msg.sender ==  owner, "only owner");
        planetxaddressnft = _planetxaddress;
    }
    function setPlanetXBankAddress(address _planetxaddress) external  {
        require(msg.sender ==  owner, "only owner");
        planetxaddressbank = _planetxaddress;
    }
    function reset() external  {
        require(msg.sender ==  owner, "only owner");
        startTime = block.timestamp;
    }
}