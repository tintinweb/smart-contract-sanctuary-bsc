/**
 *Submitted for verification at BscScan.com on 2022-11-17
*/

// SPDX-License-Identifier: none
pragma solidity ^0.8.11;

interface BEP20 {
  //predefined functions
    function totalSupply() external view returns (uint theTotalSupply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract Ownable {
  address public owner; 

  constructor() {
    owner = msg.sender;
  }
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
}
contract GUMNAAM is Ownable {   
   


  struct Investor {
    bool registered;
    address referer;
    address leftUser;
    address rightUser;
    address parentAssociate;
    address refererAssociate;
    uint position;
    uint referralIncome;
    uint token;
    //uint investedBusd;
    uint userType; //1=customer,2=agent,3=associate,4=diamond
    uint matixPoolId;
    uint matrixIncome;
    uint matchingIncome;
    uint diamondIncome;
  }


  struct MatrixPool {
      address referral;
      address leftUser;
      address middleUser;
      address rightUser;
      uint belowCount;
      bool exist;
  }

  struct matchingData{
    uint leftUsers;
    uint rightUsers;
    uint oldLeftUsers;
    uint oldRightUsers;
  }

  struct diamondUserLeft{
    uint diamond;
    uint director;
    uint seniorDirector;
    uint regionalDirector;
    uint nationalDirector;
    uint internationalDirector;
    uint worldDirector;
    uint globalDirector;
    uint crownDirector;
    uint royalDirector;
    uint presidentDirector;
  }
  struct diamondUserRight{
    uint diamond;
    uint director;
    uint seniorDirector;
    uint regionalDirector;
    uint nationalDirector;
    uint internationalDirector;
    uint worldDirector;
    uint globalDirector;
    uint crownDirector;
    uint royalDirector;
    uint presidentDirector;
  }

  struct investorRole{
    bool diamond;
    bool director;
    bool seniorDirector;
    bool regionalDirector;
    bool nationalDirector;
    bool internationalDirector;
    bool worldDirector;
    bool globalDirector;
    bool crownDirector;
    bool royalDirector;
    bool presidentDirector;
  }

  struct investorRoleTillTime{
    uint diamondTill;
    uint directorTill;
    uint seniorDirectorTill;
    uint regionalDirectorTill;
    uint nationalDirectorTill;
    uint internationalDirectorTill;
    uint worldDirectorTill;
    uint globalDirectorTill;
    uint crownDirectorTill;
    uint royalDirectorTill;
    uint presidentDirectorTill;
  }



  struct investorRoleAt{
    uint diamondAt;
    uint directorAt;
    uint seniorDirectorAt;
    uint regionalDirectorAt;
    uint nationalDirectorAt;
    uint internationalDirectorAt;
    uint worldDirectorAt;
    uint globalDirectorAt;
    uint crownDirectorAt;
    uint royalDirectorAt;
    uint presidentDirectorAt;
  }

  uint systemIncome;
  uint public decimalVal = (10**18);
  uint public oneDay = 86400; 
  uint public totalInvestors;
  uint public totalInvested;
  address nullAddr = 0x0000000000000000000000000000000000000000;
  
  uint public tokenPrice = 20;
  uint public tokenDecimal = 100;
  uint public matrixBaseAmount = 25;
  //address public busdToken = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; //mainnet
  address public busdToken = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee; //testnet
  address public contractAddr = address(this);

  uint[] public poolBase ;

  uint[] public refReward;  
  //uint[] public referralLevelIncome; 
  uint[] referralLevelIncome = [160,80,40,20,10,10,10,10,5,5,5,5,5,5,5,5,5,5,5,5]; 

  mapping (address => Investor) public investors;
  mapping (address => diamondUserLeft) public diamondUserLefts;
  mapping (address => diamondUserRight) public diamondUserRights;
  mapping (address => investorRole) public investorRoles;
  mapping (address => investorRoleTillTime) public investorRoleTillTimes;
  mapping (address => investorRoleAt) public investorRoleAts;
  mapping (address => matchingData) public matchingdatas;

  mapping (uint => mapping(address => MatrixPool)) public matrixpools;
  mapping (uint => mapping(uint=>address[])) public matrixlevel;

  address[] public diamondList;
  address[] public directorList;
  address[] public seniorDirectorList;
  address[] public regionalDirectorList;
  address[] public nationalDirectorList;
  address[] public internationalDirectorList;
  address[] public worldDirectorList;
  address[] public globalDirectorList;
  address[] public crownDirectorList;
  address[] public royalDirectorList;
  address[] public presidentDirectorList;

  address [] public binaryAddresses;
  uint public hourlyBinaryUser;

  uint public directorCollectAmt;
  uint public seniorDirectorCollectAmt;
  uint public regionalDirectorAmt;
  uint public nationalDirectorAmt;
  uint public internationalDirectorAmt;
  uint public worldDirectorAmt;
  uint public globalDirectorAmt;
  uint public crownDirectorAmt;
  uint public royalDirectorAmt;
  uint public presidentDirectorAmt;

  uint public parentDirectorLimitFirst = 1;
  uint public parentDirectorLimitSecond = 2;
  uint public parentDirectorLimitThird = 3;
  uint public parentDirectorLimitFourth = 4;

  event registerAt(address user, uint amount, address referer);
  event becomeAssociateAt(address user, address referer, uint amount, uint position);
  event becomeAgentAt(address user, uint amount);
  event TransferOwnership(address user);
  

  constructor() {
    investors[owner].registered = true;
    investors[owner].userType = 3; // make owner as default associate
    investors[owner].matixPoolId = 13;
    poolBase.push(20); // update pool Incomes array
    hourlyBinaryUser++;
    for(uint i = 0; i<14; i++){
        if(i!=0){
          poolBase.push((2**(i-1))*50); // update pool Incomes array
        }
        // add owner at top in all metrix pool
        matrixpools[i][owner].referral=address(nullAddr);
        matrixpools[i][owner].exist=true;
        matrixlevel[i][0].push(owner);
    }
  }
  /*
  register as customer
  */
  function registerCustomer(address referer,uint bnbAmount) external {
        
        require(!investors[msg.sender].registered,"User already registered");
        require(investors[referer].userType>=2,"Invalid Referral");
        require(bnbAmount == 30,"Minimum 30 Busd");
        
        bnbAmount = bnbAmount * decimalVal; 
        //require(BEP20(busdToken).allowance(msg.sender,contractAddr)>=bnbAmount,"insufficient allowance");
        //require(BEP20(busdToken).balanceOf(msg.sender)>=bnbAmount,"insufficient balance");
        uint tokenAmt = (bnbAmount*tokenPrice)/tokenDecimal;

        if(investors[referer].userType>=3){
            //20 BUSD to sponsor
            investors[referer].referralIncome += 20*decimalVal;
            if(referer!=owner){
              tokenAmt += tokenAmt*20/100; // 20% extra token
            }
        }
        else if(investors[referer].userType==2){
            //10 BUSD to sponsor
            investors[referer].referralIncome += 10*decimalVal;
            if(referer!=owner){
              tokenAmt += tokenAmt*10/100; // 10% extra token
            }
        }
        
        // transfer to contract
        //BEP20(busdToken).transferFrom(msg.sender,contractAddr,bnbAmount);
       
        investors[msg.sender].registered = true;
        investors[msg.sender].token = tokenAmt;
        investors[msg.sender].referer = referer;
        //investors[msg.sender].investedBusd += bnbAmount;
        investors[msg.sender].userType = 1; //

        emit registerAt(msg.sender,bnbAmount,referer);
    }

    /*
    become agent for referral
    */

    function becomeAgent(uint bnbAmount) external {
        require(investors[msg.sender].registered,"User Not registered");
        require(bnbAmount == 50,"Minimum 50 Busd");
        
        bnbAmount = bnbAmount * decimalVal; 
        //require(BEP20(busdToken).allowance(msg.sender,contractAddr)>=bnbAmount,"insufficient allowance");
        //require(BEP20(busdToken).balanceOf(msg.sender)>=bnbAmount,"insufficient balance");
        
        uint tokenAmt = (bnbAmount*tokenPrice)/tokenDecimal;

        // transfer to contract
        //BEP20(busdToken).transferFrom(msg.sender,contractAddr,bnbAmount);
        
        investors[msg.sender].token += tokenAmt;
        //investors[msg.sender].investedBusd += bnbAmount;
        investors[msg.sender].userType = 2; //

        emit becomeAgentAt(msg.sender,bnbAmount);
    }

    function updateParentUserCount(address user) internal {

      if(user != address(0x0000000000000000000000000000000000000000)){
        address parent = investors[user].parentAssociate;
        if(investors[parent].leftUser == user){
          matchingdatas[parent].leftUsers++;
        }
        else{
          matchingdatas[parent].rightUsers++;
        }
        updateParentUserCount(parent);
      }
    }

    /*
    get binary parent
    */


    function  getParentAssociate(address refUser,uint position) public view returns (address) {
        if(position==1){
            if(investors[refUser].leftUser == address(nullAddr)){
                return refUser;
            }
            else {
                return getParentAssociate(investors[refUser].leftUser,position);
            }
        }
        else {
             if(investors[refUser].rightUser == address(nullAddr)){
                return refUser;
            }
            else {
                return getParentAssociate(investors[refUser].rightUser,position);
            }
        }
       
    }

    /*
    find pool Matrix Parent    
    */
    function getParentMatixAddr(uint poolId) public view returns (address addr,uint i) {
        for( i=0; i < 5; i++){
            for(uint j=0; j < matrixlevel[poolId][i].length;j++){
                    addr = matrixlevel[poolId][i][j];

                    if( addr!=address(nullAddr) &&  (matrixpools[poolId][addr].leftUser==address(nullAddr) ||
                        matrixpools[poolId][addr].middleUser==address(nullAddr) || 
                        matrixpools[poolId][addr].rightUser==address(nullAddr))){
                        return ( addr ,i);
                    }
            }
        }
    }


    function resetReborn(address rebornAddr) internal {
        for(uint i=0; i < 5; i++){
            for(uint j=0; j < matrixlevel[0][i].length;j++){
                   address addr = matrixlevel[0][i][j];
                    if(addr == rebornAddr){
                      matrixlevel[0][i][j] = address(nullAddr);
                      return;
                    }
                    
            }
        }
    }

    /*
    LEFT - 1 
    RIGHT - 2
    */
    function becomeAssociate(address referer,uint bnbAmount,uint position) external {
        
        require(position==1 || position==2,"Invalid Position");
        //require(investors[msg.sender].userType==2,"Invalid User");
        require(investors[referer].userType>=3,"Invalid Referral");
        require(bnbAmount == 130,"Minimum 130 Busd");
        uint poolId = 0;
        if(investors[msg.sender].registered){
            require(investors[msg.sender].userType==2,"Agent could be associate");
        }
        
        bnbAmount = bnbAmount * decimalVal; 
        //require(BEP20(busdToken).allowance(msg.sender,contractAddr)>=bnbAmount,"insufficient allowance");
        //require(BEP20(busdToken).balanceOf(msg.sender)>=bnbAmount,"insufficient balance");
        
        uint tokenAmt = (bnbAmount*tokenPrice)/tokenDecimal;

        
        // transfer to contract
        //BEP20(busdToken).transferFrom(msg.sender,contractAddr,bnbAmount);
       
        address parentAssociate = getParentAssociate(referer,position);

        if(!investors[msg.sender].registered) {
            investors[msg.sender].referer = referer;
            investors[msg.sender].registered = true;
        }

        if(position==1){
           investors[parentAssociate].leftUser = msg.sender;
        }
        else {
           investors[parentAssociate].rightUser = msg.sender;
        }
        hourlyBinaryUser++;
        
        investors[msg.sender].token += tokenAmt;
        investors[msg.sender].parentAssociate = parentAssociate;
        investors[msg.sender].refererAssociate = referer;
        investors[msg.sender].position = position;
        //investors[msg.sender].investedBusd += bnbAmount;
        investors[msg.sender].userType = 3; //


        updateParentUserCount(msg.sender);

        appendMatrix(msg.sender, poolId);

        matrixpools[0][msg.sender].exist=true;

        referralIncome();

        emit becomeAssociateAt(msg.sender, referer, bnbAmount, position);
    }

    /*
    participate in next matrix pool  
    */
    function updateMatixPool(uint bnbAmount) external {
        require(investors[msg.sender].userType>=3,"Become Associate First");
        require(investors[msg.sender].matixPoolId<14,"No More Pool Available");
        uint nextPoolId = investors[msg.sender].matixPoolId + 1;
        require(poolBase[nextPoolId]==bnbAmount,"Insufficient BNB amount");

        //require(BEP20(busdToken).allowance(msg.sender,contractAddr)>=bnbAmount,"insufficient allowance");
        //require(BEP20(busdToken).balanceOf(msg.sender)>=bnbAmount,"insufficient balance");

        bnbAmount = bnbAmount*decimalVal;

        // transfer to contract
        //BEP20(busdToken).transferFrom(msg.sender,contractAddr,bnbAmount);

        uint tokenAmt = (bnbAmount*tokenPrice)/tokenDecimal;

        //investors[msg.sender].investedBusd += bnbAmount;
        investors[msg.sender].token += tokenAmt;
        matrixpools[nextPoolId][msg.sender].exist=true;
        appendMatrix(msg.sender,nextPoolId);
    }

    function referralIncome() internal {
        address rec = investors[msg.sender].referer;
        
        for (uint i = 0; i < 20; i++) {
            if (!investors[rec].registered) {
                break;
            }
            if(investors[rec].userType>=3){
              investors[rec].referralIncome += referralLevelIncome[i]*decimalVal/10;
            }
            rec = investors[rec].referer;
        }
    }
    /*
    add users in pool matrix
    */
    function appendMatrix(address updateAddr,uint poolId) internal {
        
        (address parentMatrixAddr, uint i) = getParentMatixAddr(poolId);
    
        if(matrixpools[poolId][parentMatrixAddr].leftUser==address(nullAddr)){
          matrixpools[poolId][parentMatrixAddr].leftUser = updateAddr;
        }
        else if(matrixpools[poolId][parentMatrixAddr].middleUser==address(nullAddr)){
          matrixpools[poolId][parentMatrixAddr].middleUser = updateAddr;
        }
        else {
          matrixpools[poolId][parentMatrixAddr].rightUser = updateAddr;
        }


        if(matrixpools[poolId][parentMatrixAddr].referral!=address(nullAddr)){
          matrixpools[poolId][matrixpools[poolId][parentMatrixAddr].referral].belowCount++;
        }
        matrixpools[poolId][parentMatrixAddr].belowCount++;
        // if(!matrixpools[poolId][parentMatrixAddr].exist){
        //   matrixpools[poolId][parentMatrixAddr].exist=true;
        // }
        

        matrixlevel[poolId][i+1].push(updateAddr);
        matrixpools[poolId][updateAddr].referral = parentMatrixAddr;

        // Reborn Process for first pool
        if(poolId==0){
          investors[parentMatrixAddr].matrixIncome += 10*decimalVal; // add pool income to parent
          if(matrixpools[poolId][matrixpools[poolId][parentMatrixAddr].referral].belowCount!=11 && matrixpools[poolId][matrixpools[poolId][parentMatrixAddr].referral].belowCount!=12){
            // add pool income to grand parent
            investors[matrixpools[poolId][parentMatrixAddr].referral].matrixIncome += 10*decimalVal;
          }
          else{
            // send 11 and 12th child bonus to system which will user for reborn
            systemIncome += 10*decimalVal;
          }
          if(matrixpools[poolId][matrixpools[poolId][parentMatrixAddr].referral].belowCount==12){
            // reset below count of reborn address
            matrixpools[poolId][matrixpools[poolId][parentMatrixAddr].referral].belowCount = 0;
            

            appendMatrix(matrixpools[poolId][parentMatrixAddr].referral, poolId);
            
            resetReborn(matrixpools[poolId][parentMatrixAddr].referral);

            matrixpools[poolId][matrixpools[poolId][parentMatrixAddr].referral].leftUser = address(nullAddr);
            matrixpools[poolId][matrixpools[poolId][parentMatrixAddr].referral].middleUser = address(nullAddr);
            matrixpools[poolId][matrixpools[poolId][parentMatrixAddr].referral].rightUser = address(nullAddr);

          }
        }
        else {
          uint poolAmount = poolBase[poolId];
          uint systemAmt = poolAmount*20/100;
          uint systemAmtDecimal = systemAmt*decimalVal;
          // send 20% to system for all pool expect first
          systemIncome += systemAmtDecimal;

          uint remainingAmt = poolAmount - systemAmt;
          uint distributeAmt = remainingAmt/2;
          distributeAmt = distributeAmt*decimalVal;

          // send half income to parent
          investors[parentMatrixAddr].matrixIncome += distributeAmt;
          // send other half income to grand parent
          investors[matrixpools[poolId][parentMatrixAddr].referral].matrixIncome += distributeAmt;
        }
    
    }



    function showDistributeMatching() public view returns (uint , uint, uint )  {
        
        uint totalMatching;
        for(uint i=0; i<binaryAddresses.length;i++){
          address singleAddr = binaryAddresses[i];
          uint leftMatching = matchingdatas[singleAddr].leftUsers - matchingdatas[singleAddr].oldLeftUsers;
          uint rightMatching = matchingdatas[singleAddr].rightUsers - matchingdatas[singleAddr].oldRightUsers;
          uint matchinVal = (rightMatching>leftMatching) ? leftMatching : rightMatching;
          if(matchinVal>0) {
            totalMatching += matchinVal;
          }
        }

        uint distributeIncome = hourlyBinaryUser*60/totalMatching;
        return (distributeIncome,totalMatching,hourlyBinaryUser);
    }


    function showUserMatching(address singleAddr) public view returns (uint matchinVal )  {
        
        uint leftMatching = matchingdatas[singleAddr].leftUsers - matchingdatas[singleAddr].oldLeftUsers;
        uint rightMatching = matchingdatas[singleAddr].rightUsers - matchingdatas[singleAddr].oldRightUsers;
        matchinVal = (rightMatching>leftMatching) ? leftMatching : rightMatching;
    }

    function distributeMatchingIncome() external onlyOwner {
        
        uint totalMatching;
        for(uint i=0; i<binaryAddresses.length;i++){
          address singleAddr = binaryAddresses[i];
          uint leftMatching = matchingdatas[singleAddr].leftUsers - matchingdatas[singleAddr].oldLeftUsers;
          uint rightMatching = matchingdatas[singleAddr].rightUsers - matchingdatas[singleAddr].oldRightUsers;
          uint matchinVal = (rightMatching>leftMatching) ? leftMatching : rightMatching;
          if(matchinVal>0) {
            totalMatching += matchinVal;
          }
        }

        uint distributeIncome = hourlyBinaryUser*60/totalMatching;

        for(uint i=0; i<binaryAddresses.length;i++){
          address singleAddr = binaryAddresses[i];
          uint leftMatching = matchingdatas[singleAddr].leftUsers - matchingdatas[singleAddr].oldLeftUsers;
          uint rightMatching = matchingdatas[singleAddr].rightUsers - matchingdatas[singleAddr].oldRightUsers;
          uint matchinVal = (rightMatching>leftMatching) ? leftMatching : rightMatching;
          
          
          if(matchinVal>0) {
            investors[singleAddr].matchingIncome +=  distributeIncome*matchinVal;  
            matchingdatas[singleAddr].oldLeftUsers += matchinVal;
            matchingdatas[singleAddr].oldRightUsers += matchinVal;
          }

        }
        
        hourlyBinaryUser = 0;
       
    }




    function diamondPlan(uint bnbAmount) external {
        
        require(bnbAmount==1000,"Insufficient BNB amount");
        require(investors[msg.sender].userType==3,"User Should be Associate");
        //require(BEP20(busdToken).allowance(msg.sender,contractAddr)>=bnbAmount,"insufficient allowance");
        //require(BEP20(busdToken).balanceOf(msg.sender)>=bnbAmount,"insufficient balance");
        bnbAmount = bnbAmount*(10**18);
        investors[msg.sender].userType=4;
        investorRoles[msg.sender].diamond=true;


        directorCollectAmt += 100 ;
        seniorDirectorCollectAmt += 90;
        regionalDirectorAmt += 80;
        nationalDirectorAmt += 70;
        internationalDirectorAmt += 60;
        worldDirectorAmt += 50;
        globalDirectorAmt += 40;
        crownDirectorAmt += 30;
        royalDirectorAmt += 20;
        presidentDirectorAmt += 10;

        diamondList.push(msg.sender);
        updateDiamondUsers(investors[msg.sender].parentAssociate,msg.sender);
    }



    function userNextRole(address userAddr) internal returns (uint nextRole) {
        if(diamondUserLefts[userAddr].diamond>=12 
          && diamondUserRights[userAddr].diamond>=12 
          && !investorRoles[userAddr].presidentDirector){
          nextRole = 10;
          investorRoles[userAddr].presidentDirector=true;
          investorRoleTillTimes[userAddr].presidentDirectorTill = block.timestamp+(4380*oneDay);
          investorRoleAts[userAddr].presidentDirectorAt = block.timestamp;
          
          presidentDirectorList.push(userAddr);
        }
        else if(diamondUserLefts[userAddr].diamond>=11 
                && diamondUserRights[userAddr].diamond>=11 
                && !investorRoles[userAddr].royalDirector){
          nextRole = 9;
          investorRoles[userAddr].royalDirector=true;
          investorRoleTillTimes[userAddr].royalDirectorTill = block.timestamp+(4380*oneDay);
          investorRoleAts[userAddr].royalDirectorAt = block.timestamp;
          royalDirectorList.push(userAddr);
        }
        else if(diamondUserLefts[userAddr].diamond>=10 
                && diamondUserRights[userAddr].diamond>=10 
                && !investorRoles[userAddr].crownDirector){
          nextRole = 8;
          investorRoles[userAddr].crownDirector=true;
          investorRoleTillTimes[userAddr].crownDirectorTill = block.timestamp+(4380*oneDay);
          investorRoleAts[userAddr].crownDirectorAt = block.timestamp;
          crownDirectorList.push(userAddr);
        }
        else if(diamondUserLefts[userAddr].diamond>=9 
                && diamondUserRights[userAddr].diamond>=9 
                && !investorRoles[userAddr].globalDirector){
          nextRole = 7;
          investorRoles[userAddr].globalDirector=true;
          investorRoleTillTimes[userAddr].globalDirectorTill = block.timestamp+(4380*oneDay);
          investorRoleAts[userAddr].globalDirectorAt = block.timestamp;
          globalDirectorList.push(userAddr);
        }
        else if(diamondUserLefts[userAddr].diamond>=8 
                && diamondUserRights[userAddr].diamond>=8 
                && !investorRoles[userAddr].worldDirector){
          nextRole = 6;
          investorRoles[userAddr].worldDirector=true;
          investorRoleTillTimes[userAddr].worldDirectorTill = block.timestamp+(4380*oneDay);
          investorRoleAts[userAddr].worldDirectorAt = block.timestamp;
          worldDirectorList.push(userAddr);
        }
        else if(diamondUserLefts[userAddr].diamond>=7 
                && diamondUserRights[userAddr].diamond>=7 
                && !investorRoles[userAddr].internationalDirector){
          nextRole = 5;
          investorRoles[userAddr].internationalDirector=true;
          investorRoleTillTimes[userAddr].internationalDirectorTill = block.timestamp+(60*oneDay);
          investorRoleAts[userAddr].internationalDirectorAt = block.timestamp;
          internationalDirectorList.push(userAddr);
        }
        else if(diamondUserLefts[userAddr].diamond>=6 
                && diamondUserRights[userAddr].diamond>=6 
                && !investorRoles[userAddr].nationalDirector){
          nextRole = 4;
          investorRoles[userAddr].nationalDirector=true;
          investorRoleTillTimes[userAddr].nationalDirectorTill = block.timestamp+(60*oneDay);
          investorRoleAts[userAddr].nationalDirectorAt = block.timestamp;
          nationalDirectorList.push(userAddr);
        }
        else if(diamondUserLefts[userAddr].diamond>=5 
                && diamondUserRights[userAddr].diamond>=5 
                && !investorRoles[userAddr].regionalDirector){
          nextRole = 3;
          investorRoles[userAddr].regionalDirector=true;
          investorRoleTillTimes[userAddr].regionalDirectorTill = block.timestamp+(60*oneDay);
          investorRoleAts[userAddr].regionalDirectorAt = block.timestamp;
          regionalDirectorList.push(userAddr);
        }
        else if(diamondUserLefts[userAddr].diamond>=3 
                && diamondUserRights[userAddr].diamond>=3 
                && !investorRoles[userAddr].seniorDirector){
          nextRole = 2;
          investorRoles[userAddr].seniorDirector=true;
          investorRoleTillTimes[userAddr].seniorDirectorTill = block.timestamp+(60*oneDay);
          investorRoleAts[userAddr].seniorDirectorAt = block.timestamp;
          seniorDirectorList.push(userAddr);
        }
        else if(diamondUserLefts[userAddr].diamond>=1 
                && diamondUserRights[userAddr].diamond>=1 
                && !investorRoles[userAddr].director){
          nextRole = 1;
          investorRoles[userAddr].director=true;
          investorRoleTillTimes[userAddr].directorTill = block.timestamp+(60*oneDay);
          investorRoleAts[userAddr].directorAt = block.timestamp;
          directorList.push(userAddr);
        }
    }


    function updateDiamondUsers(address refAddr,address userAddr) internal {
      if(refAddr!=address(0x0000000000000000000000000000000000000000)) {
        if(investors[refAddr].userType==4){
          if(investors[refAddr].leftUser == userAddr){
            diamondUserLefts[refAddr].diamond++;
          }
          else {
            diamondUserRights[refAddr].diamond++;
          }
          
          
          uint nextRole = userNextRole(refAddr);
          if(nextRole>0 && nextRole<5){
            updateRoleCount(refAddr,nextRole);
          }
        }
      
        updateDiamondUsers(investors[refAddr].parentAssociate,refAddr);
      }
    }  




    function updateRoleCount(address user,uint newRole) internal {
          
      // update director Count
      if(newRole==1){
        address parentAssociate = investors[user].parentAssociate;
          
        if(investors[parentAssociate].leftUser == user){
          diamondUserLefts[parentAssociate].director++;
        }
        else {
          diamondUserRights[parentAssociate].director++;
        }
        
        // update time for senior directors
        if(diamondUserLefts[parentAssociate].director>=parentDirectorLimitFourth && diamondUserRights[parentAssociate].director >=parentDirectorLimitFourth){
             investorRoleTillTimes[parentAssociate].seniorDirectorTill =  investorRoleAts[parentAssociate].seniorDirectorAt+(4380*oneDay);
        }
        else if(diamondUserLefts[parentAssociate].director>=parentDirectorLimitThird && diamondUserRights[parentAssociate].director >=parentDirectorLimitThird){
             investorRoleTillTimes[parentAssociate].seniorDirectorTill = investorRoleAts[parentAssociate].seniorDirectorAt+(500*oneDay);
        }
        else if(diamondUserLefts[parentAssociate].director>=parentDirectorLimitSecond && diamondUserRights[parentAssociate].director >=parentDirectorLimitSecond){
             investorRoleTillTimes[parentAssociate].seniorDirectorTill = investorRoleAts[parentAssociate].seniorDirectorAt+(240*oneDay);
        }
        else if(diamondUserLefts[parentAssociate].director>=parentDirectorLimitFirst && diamondUserRights[parentAssociate].director >=parentDirectorLimitFirst){
             investorRoleTillTimes[parentAssociate].seniorDirectorTill = investorRoleAts[parentAssociate].seniorDirectorAt+(120*oneDay);
        }
      }
      else if(newRole==2){
        address parentAssociate = investors[user].parentAssociate;
          
        if(investors[parentAssociate].leftUser == user){
          diamondUserLefts[parentAssociate].seniorDirector++;
        }
        else {
          diamondUserRights[parentAssociate].seniorDirector++;
        }
        
        // update time for regional directors
        if(diamondUserLefts[parentAssociate].seniorDirector>=parentDirectorLimitFourth && diamondUserRights[parentAssociate].seniorDirector >=parentDirectorLimitFourth){
             investorRoleTillTimes[parentAssociate].regionalDirectorTill =  investorRoleAts[parentAssociate].regionalDirectorAt+(4380*oneDay);
        }
        else if(diamondUserLefts[parentAssociate].seniorDirector>=parentDirectorLimitThird && diamondUserRights[parentAssociate].seniorDirector >=parentDirectorLimitThird){
             investorRoleTillTimes[parentAssociate].regionalDirectorTill = investorRoleAts[parentAssociate].regionalDirectorAt+(500*oneDay);
        }
        else if(diamondUserLefts[parentAssociate].seniorDirector>=parentDirectorLimitSecond && diamondUserRights[parentAssociate].seniorDirector >=parentDirectorLimitSecond){
             investorRoleTillTimes[parentAssociate].regionalDirectorTill = investorRoleAts[parentAssociate].regionalDirectorAt+(240*oneDay);
        }
        else if(diamondUserLefts[parentAssociate].seniorDirector>=parentDirectorLimitFirst && diamondUserRights[parentAssociate].seniorDirector >=parentDirectorLimitFirst){
             investorRoleTillTimes[parentAssociate].regionalDirectorTill = investorRoleAts[parentAssociate].regionalDirectorAt+(120*oneDay);
        }

      }
      else if(newRole==3){
        address parentAssociate = investors[user].parentAssociate;
          
        if(investors[parentAssociate].leftUser == user){
          diamondUserLefts[parentAssociate].regionalDirector++;
        }
        else {
          diamondUserRights[parentAssociate].regionalDirector++;
        }

        // update time for national directors
        if(diamondUserLefts[parentAssociate].regionalDirector>=parentDirectorLimitFourth && diamondUserRights[parentAssociate].regionalDirector >=parentDirectorLimitFourth){
             investorRoleTillTimes[parentAssociate].nationalDirectorTill =  investorRoleAts[parentAssociate].nationalDirectorAt+(4380*oneDay);
        }
        else if(diamondUserLefts[parentAssociate].regionalDirector>=parentDirectorLimitThird && diamondUserRights[parentAssociate].regionalDirector >=parentDirectorLimitThird){
             investorRoleTillTimes[parentAssociate].nationalDirectorTill = investorRoleAts[parentAssociate].nationalDirectorAt+(500*oneDay);
        }
        else if(diamondUserLefts[parentAssociate].regionalDirector>=parentDirectorLimitSecond && diamondUserRights[parentAssociate].regionalDirector >=parentDirectorLimitSecond){
             investorRoleTillTimes[parentAssociate].nationalDirectorTill = investorRoleAts[parentAssociate].nationalDirectorAt+(240*oneDay);
        }
        else if(diamondUserLefts[parentAssociate].regionalDirector>=parentDirectorLimitFirst && diamondUserRights[parentAssociate].regionalDirector >=parentDirectorLimitFirst){
             investorRoleTillTimes[parentAssociate].nationalDirectorTill = investorRoleAts[parentAssociate].nationalDirectorAt+(120*oneDay);
        }
        
      }
      else if(newRole==4){
        address parentAssociate = investors[user].parentAssociate;
          
        if(investors[parentAssociate].leftUser == user){
          diamondUserLefts[parentAssociate].nationalDirector++;
        }
        else {
          diamondUserRights[parentAssociate].nationalDirector++;
        }

        // update time for international directors
        if(diamondUserLefts[parentAssociate].nationalDirector>=parentDirectorLimitFourth && diamondUserRights[parentAssociate].nationalDirector >=parentDirectorLimitFourth){
             investorRoleTillTimes[parentAssociate].internationalDirectorTill =  investorRoleAts[parentAssociate].internationalDirectorAt+(4380*oneDay);
        }
        else if(diamondUserLefts[parentAssociate].nationalDirector>=parentDirectorLimitThird && diamondUserRights[parentAssociate].nationalDirector >=parentDirectorLimitThird){
             investorRoleTillTimes[parentAssociate].internationalDirectorTill = investorRoleAts[parentAssociate].internationalDirectorAt+(500*oneDay);
        }
        else if(diamondUserLefts[parentAssociate].nationalDirector>=parentDirectorLimitSecond && diamondUserRights[parentAssociate].nationalDirector >=parentDirectorLimitSecond){
             investorRoleTillTimes[parentAssociate].internationalDirectorTill = investorRoleAts[parentAssociate].internationalDirectorAt+(240*oneDay);
        }
        else if(diamondUserLefts[parentAssociate].nationalDirector>=parentDirectorLimitFirst && diamondUserRights[parentAssociate].nationalDirector >=parentDirectorLimitFirst){
             investorRoleTillTimes[parentAssociate].internationalDirectorTill = investorRoleAts[parentAssociate].internationalDirectorAt+(120*oneDay);
        }
      }
    }

    function validAllTypeDirectors() public view returns (uint director,
                                                          uint seniorDirector,
                                                          uint regionalDirector,
                                                          uint nationalDirector,
                                                          uint internationalDirector,
                                                          uint worldDirector,
                                                          uint globalDirector,
                                                          uint crownDirector,
                                                          uint royalDirector,
                                                          uint presidentDirector) {
      
      if(directorList.length>0) {
        for(uint i=0; i<directorList.length;i++){
          if(investorRoleTillTimes[directorList[i]].directorTill>=block.timestamp){
              director++;
          }
        }
      }

      if(seniorDirectorList.length>0) {
        for(uint i=0; i<seniorDirectorList.length;i++){
          if(investorRoleTillTimes[seniorDirectorList[i]].seniorDirectorTill>=block.timestamp){
              seniorDirector++;
          }
        }
      }
      
      if(regionalDirectorList.length>0) {
        for(uint i=0; i<regionalDirectorList.length;i++){
          if(investorRoleTillTimes[regionalDirectorList[i]].regionalDirectorTill>=block.timestamp){
              regionalDirector++;
          }
        }
      }
      
      if(nationalDirectorList.length>0) {
        for(uint i=0; i<nationalDirectorList.length;i++){
          if(investorRoleTillTimes[nationalDirectorList[i]].nationalDirectorTill>=block.timestamp){
              nationalDirector++;
          }
        }
      }
      
      if(internationalDirectorList.length>0) {
        for(uint i=0; i<internationalDirectorList.length;i++){
          if(investorRoleTillTimes[internationalDirectorList[i]].internationalDirectorTill>=block.timestamp){
              internationalDirector++;
          }
        }
      }

      if(worldDirectorList.length>0) {
        for(uint i=0; i<worldDirectorList.length;i++){
          if(investorRoleTillTimes[worldDirectorList[i]].worldDirectorTill>=block.timestamp){
              worldDirector++;
          }
        }
      }
      
      if(globalDirectorList.length>0) {
        for(uint i=0; i<globalDirectorList.length;i++){
          if(investorRoleTillTimes[globalDirectorList[i]].globalDirectorTill>=block.timestamp){
              globalDirector++;
          }
        }
      }
      
      if(crownDirectorList.length>0) {
        for(uint i=0; i<crownDirectorList.length;i++){
          if(investorRoleTillTimes[crownDirectorList[i]].crownDirectorTill>=block.timestamp){
              crownDirector++;
          }
        }
      }
      
      if(royalDirectorList.length>0) {
        for(uint i=0; i<royalDirectorList.length;i++){
          if(investorRoleTillTimes[royalDirectorList[i]].royalDirectorTill>=block.timestamp){
              royalDirector++;
          }
        }
      }
     
      if(presidentDirectorList.length>0) {
        for(uint i=0; i<presidentDirectorList.length;i++){
          if(investorRoleTillTimes[presidentDirectorList[i]].presidentDirectorTill>=block.timestamp){
              presidentDirector++;
          }
        }
      }
     
    }



  
    function distributeRankAndRecognitionIncome() external{

      // director Income
      if(directorList.length>0) {
        uint validDirector;
        
        for(uint i=0; i<directorList.length;i++){
          if(investorRoleTillTimes[directorList[i]].directorTill>=block.timestamp){
              validDirector++;
          }
        }
        if(validDirector>0){
          uint collectAmt = directorCollectAmt/validDirector;
          for(uint i=0; i<directorList.length;i++){
            if(investorRoleTillTimes[directorList[i]].directorTill>=block.timestamp){
                investors[directorList[i]].diamondIncome += collectAmt;
            }
          }
        }

      }
      directorCollectAmt = 0;


      // senior director Income
      if(seniorDirectorList.length>0) {
        uint valid;
        
        for(uint i=0; i<seniorDirectorList.length;i++){
          if(investorRoleTillTimes[seniorDirectorList[i]].seniorDirectorTill>=block.timestamp){
              valid++;
          }
        }
        if(valid>0) {
          uint collectAmt = seniorDirectorCollectAmt/valid;
          for(uint i=0; i<seniorDirectorList.length;i++){
            if(investorRoleTillTimes[seniorDirectorList[i]].seniorDirectorTill>=block.timestamp){
                investors[directorList[i]].diamondIncome += collectAmt;
            }
          }
        }
      }
      seniorDirectorCollectAmt = 0;

      // REGIONAL DIRECTOR Income
      if(regionalDirectorList.length>0) {
        uint valid;
        
        for(uint i=0; i<regionalDirectorList.length;i++){
          if(investorRoleTillTimes[regionalDirectorList[i]].regionalDirectorTill>=block.timestamp){
              valid++;
          }
        }
        if(valid>0) {
          uint collectAmt = regionalDirectorAmt/valid;
          for(uint i=0; i<regionalDirectorList.length;i++){
            if(investorRoleTillTimes[regionalDirectorList[i]].regionalDirectorTill>=block.timestamp){
                investors[regionalDirectorList[i]].diamondIncome += collectAmt;
            }
          }
        }
      }
      regionalDirectorAmt = 0;

      // NATIONAL DIRECTOR Income
      if(nationalDirectorList.length>0) {
        uint valid;
        
        for(uint i=0; i<nationalDirectorList.length;i++){
          if(investorRoleTillTimes[nationalDirectorList[i]].nationalDirectorTill>=block.timestamp){
              valid++;
          }
        }
        if(valid>0) {
          uint collectAmt = nationalDirectorAmt/valid;
          for(uint i=0; i<nationalDirectorList.length;i++){
            if(investorRoleTillTimes[nationalDirectorList[i]].nationalDirectorTill>=block.timestamp){
                investors[nationalDirectorList[i]].diamondIncome += collectAmt;
            }
          }
        }

      }
      nationalDirectorAmt = 0;


      // INTERNATIONAL DIRECTOR Income
      if(internationalDirectorList.length>0) {
        uint valid;
        
        for(uint i=0; i<internationalDirectorList.length;i++){
          if(investorRoleTillTimes[internationalDirectorList[i]].internationalDirectorTill>=block.timestamp){
              valid++;
          }
        }
        if(valid>0) {
          uint collectAmt = nationalDirectorAmt/valid;
          for(uint i=0; i<internationalDirectorList.length;i++){
            if(investorRoleTillTimes[internationalDirectorList[i]].internationalDirectorTill>=block.timestamp){
                investors[internationalDirectorList[i]].diamondIncome += collectAmt;
            }
          }
        }
      }
      nationalDirectorAmt = 0;


      // WORLD DIRECTOR Income
      if(worldDirectorList.length>0) {
        uint valid;
        
        for(uint i=0; i<worldDirectorList.length;i++){
          if(investorRoleTillTimes[worldDirectorList[i]].worldDirectorTill>=block.timestamp){
              valid++;
          }
        }
        if(valid>0) {
          uint collectAmt = worldDirectorAmt/valid;
          for(uint i=0; i<worldDirectorList.length;i++){
            if(investorRoleTillTimes[worldDirectorList[i]].worldDirectorTill>=block.timestamp){
                investors[worldDirectorList[i]].diamondIncome += collectAmt;
            }
          }
        }
      }
      worldDirectorAmt = 0;

     


      // GLOBAL DIRECTOR Income
      if(globalDirectorList.length>0) {
        uint valid;
        
        for(uint i=0; i<globalDirectorList.length;i++){
          if(investorRoleTillTimes[globalDirectorList[i]].globalDirectorTill>=block.timestamp){
              valid++;
          }
        }

        if(valid>0) {
          uint collectAmt = globalDirectorAmt/valid;
          for(uint i=0; i<globalDirectorList.length;i++){
            if(investorRoleTillTimes[globalDirectorList[i]].globalDirectorTill>=block.timestamp){
                investors[globalDirectorList[i]].diamondIncome += collectAmt;
            }
          }
        }
      }
      globalDirectorAmt = 0;

      // CROWN DIRECTOR Income
      if(crownDirectorList.length>0) {
        uint valid;
        
        for(uint i=0; i<crownDirectorList.length;i++){
          if(investorRoleTillTimes[crownDirectorList[i]].crownDirectorTill>=block.timestamp){
              valid++;
          }
        }
        if(valid>0) {
          uint collectAmt = crownDirectorAmt/valid;
          for(uint i=0; i<crownDirectorList.length;i++){
            if(investorRoleTillTimes[crownDirectorList[i]].crownDirectorTill>=block.timestamp){
                investors[crownDirectorList[i]].diamondIncome += collectAmt;
            }
          }
        }
      }
      crownDirectorAmt = 0;



      // ROYAL DIRECTOR Income
      if(royalDirectorList.length>0) {
        uint valid;
        
        for(uint i=0; i<royalDirectorList.length;i++){
          if(investorRoleTillTimes[royalDirectorList[i]].royalDirectorTill>=block.timestamp){
              valid++;
          }
        }
        if(valid>0) {
          uint collectAmt = royalDirectorAmt/valid;
          for(uint i=0; i<royalDirectorList.length;i++){
            if(investorRoleTillTimes[royalDirectorList[i]].royalDirectorTill>=block.timestamp){
                investors[royalDirectorList[i]].diamondIncome += collectAmt;
            }
          }
        }
      }
      royalDirectorAmt = 0;


      // PRESIDENT DIRECTOR Income
      if(presidentDirectorList.length>0) {
        uint valid;
        
        for(uint i=0; i<presidentDirectorList.length;i++){
          if(investorRoleTillTimes[presidentDirectorList[i]].presidentDirectorTill>=block.timestamp){
              valid++;
          }
        }
        if(valid>0) {
          uint collectAmt = presidentDirectorAmt/valid;
          for(uint i=0; i<presidentDirectorList.length;i++){
            if(investorRoleTillTimes[presidentDirectorList[i]].presidentDirectorTill>=block.timestamp){
                investors[presidentDirectorList[i]].diamondIncome += collectAmt;
            }
          }
        }
      }
      presidentDirectorAmt = 0;



    }






    
}