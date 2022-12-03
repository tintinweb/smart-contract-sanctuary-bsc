/**
 *Submitted for verification at BscScan.com on 2022-12-03
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
contract BITPLUS is Ownable {   
   
  struct Investor {
    bool registered;
    address referer;
    address leftUser;
    address rightUser;
    address parentAssociate;
    //address refererAssociate;
    uint position;
    uint token;
    //uint investedBusd;
    uint userType; //1=customer,2=agent,3=associate,4=diamond
    uint matixPoolId;
    uint referralIncome;
    uint matrixIncome;
    uint matchingIncome;
    uint diamondIncome;
  }

  struct investorData {
    uint generalIncome;
    uint diamondRank; // 1- diamond , 2- double, 3- triple, 4- black, 5- blue
    uint diamondCount;
    uint doubleDiamondCount;
    uint tripleDiamondCount;
    uint blackDiamondCount;
    uint withdrawn;
    uint withdrawnToken;
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

  

  struct allReport{
    uint token;
    uint busdAmt;
    uint cutime;
    uint ptype; // 0 = register, 1=agent,2= assiciate , 3= update pool , 4=diamond
    uint withdraw_type; // 0=token, 1=busd token
    uint income_type; // 0 - referral, 1= matrix, 2 = matching, 3= diamond, 4 = general
    uint report_type; // 0 = purchase, 1 = income, 2= withdrawal
  }

  uint systemIncome;
  uint public decimalVal = (10**18);
  uint public oneDay = 86400; 
  address nullAddr = 0x0000000000000000000000000000000000000000;
  
  uint public tokenPrice = 20;
  uint public tokenDecimal = 100;
  uint public matrixBaseAmount = 25;
  //address public busdToken = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; //mainnet
  address public busdToken = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee; //testnet
  address public customToken = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee; //testnet
  address public contractAddr = address(this);
  address public bitplusUpgradeAddr;

  uint[] public poolBase ;

  uint[] public refReward;  
  //uint[] public referralLevelIncome; 
  uint[] referralLevelIncome = [160,80,40,20,10,10,10,10,5,5,5,5,5,5,5,5,5,5,5,5]; 

  mapping (address => Investor) public investors;
  
  mapping (address => matchingData) public matchingdatas;
  mapping (address => investorData) public investorsData;
  mapping (address => allReport[]) public allReportList;
  

  mapping (uint => mapping(address => MatrixPool)) public matrixpools;
  mapping (uint => mapping(uint=>address[])) public matrixlevel;

  
 

  address [] public binaryAddresses;
  uint public hourlyBinaryUser;




  event registerAt(address user, uint amount, address referer);
  event becomeAssociateAt(address user, address referer, uint amount, uint position);
  event becomeAgentAt(address user, uint amount);
  event withdrawal(address user, uint amount, uint at);
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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

  function calculateToken(uint getAmt) public view returns(uint tokenAmt){
    tokenAmt = (getAmt*tokenPrice)/tokenDecimal;
  }

  function multiplyDecimal(uint _getAmt) public view returns(uint newAmt){
    newAmt = _getAmt*decimalVal;
  }



  function investorCusData(address addr) public view returns(uint userType,
                                                          address parentAssociate,
                                                          address referer,
                                                          address leftUser,
                                                          uint diamondRank
                                                          ){
      userType = investors[addr].userType;
      parentAssociate = investors[addr].parentAssociate;
      leftUser = investors[addr].leftUser;
      diamondRank = investorsData[addr].diamondRank;
      
      referer = investors[addr].referer;
  }

  function investorRef(address addr) public view returns(address referer){
      referer = investors[addr].referer;
  }
  function investorDiamondRank(address addr) public view returns(uint diamondRank){
       diamondRank = investorsData[addr].diamondRank;
  }




  function investorCusDataUpgrade(address addr) public view returns(address referer,
                                                          uint diamondRank,
                                                          uint mdLeftUsers,
                                                          uint mdRightUsers,
                                                          uint diamondCount,
                                                          uint doubleDiamondCount,
                                                          uint tripleDiamondCount,
                                                          uint blackDiamondCount){
     
      referer = investors[addr].referer;
      diamondRank = investorsData[addr].diamondRank;
      mdLeftUsers = matchingdatas[addr].leftUsers;
      mdRightUsers = matchingdatas[addr].rightUsers;
      diamondCount = investorsData[addr].diamondCount;
      doubleDiamondCount = investorsData[addr].doubleDiamondCount;
      tripleDiamondCount = investorsData[addr].tripleDiamondCount;
      blackDiamondCount = investorsData[addr].blackDiamondCount;

  }




  function updateUserReport(address addr,uint tokenAmt, uint bnbAmount,uint ptype, uint income_type, uint report_type ) external  returns(bool){
    require(msg.sender==bitplusUpgradeAddr,"Invalid User");
    allReportList[addr].push(allReport(tokenAmt,bnbAmount,block.timestamp,ptype,0,income_type,report_type));
    return true;
  }



  function updateInvestorData(address addr,uint amount, uint updateType) external returns(bool) {
    require(msg.sender==bitplusUpgradeAddr,"Invalid User");
    if(updateType ==0){
      investors[addr].token += amount;
    }
    else if(updateType ==1){
      investors[addr].userType = amount;
    }
    else if(updateType ==2){
      investors[addr].diamondIncome += amount;
    }
    else if(updateType ==3){
      investorsData[addr].generalIncome += amount;
    }
    else if(updateType ==4){
      investorsData[addr].diamondCount += amount;
    }
    else if(updateType ==5){
      investorsData[addr].doubleDiamondCount += amount;
    }
    else if(updateType ==6){
       investorsData[addr].tripleDiamondCount += amount;
    }
    else if(updateType ==7){
      investorsData[addr].blackDiamondCount += amount;
    }
    else if(updateType ==8 ){
      investorsData[addr].diamondRank = amount;
    }
    return true;
 }


 function changeBitplusUpgradeAddr(address _bitplusUpgradeAddr) external onlyOwner{
    
    bitplusUpgradeAddr = _bitplusUpgradeAddr;
  }

  /*
  register as customer
  */
  function registerCustomer(address referer,uint bnbAmount) external {
        
        require(!investors[msg.sender].registered,"User already registered");
        require(investors[referer].userType>=2,"Invalid Referral");
        require(bnbAmount == 30,"Minimum 30 Busd");
        
        bnbAmount = multiplyDecimal(bnbAmount); 
        //require(BEP20(busdToken).allowance(msg.sender,contractAddr)>=bnbAmount,"insufficient allowance");
        //require(BEP20(busdToken).balanceOf(msg.sender)>=bnbAmount,"insufficient balance");
        uint tokenAmt = calculateToken(bnbAmount);
        uint referAmt;
        if(investors[referer].userType>=3){
            //20% BUSD to sponsor
            referAmt = bnbAmount*20/100;
            investors[referer].referralIncome += referAmt;
            if(referer!=owner){
              tokenAmt += tokenAmt*20/100; // 20% extra token
            }
        }
        else if(investors[referer].userType==2){
            //10% BUSD to sponsor
            referAmt = bnbAmount*10/100;
            investors[referer].referralIncome += referAmt;
           
            if(referer!=owner){
              tokenAmt += tokenAmt*10/100; // 10% extra token
            }
        }
        allReportList[referer].push(allReport(referAmt,0,block.timestamp,0,0,0,1));
        
        // transfer to contract
        //(busdToken).transferFrom(msg.sender,contractAddr,bnbAmount);
       
        investors[msg.sender].registered = true;
        investors[msg.sender].token = tokenAmt;
        investors[msg.sender].referer = referer;
        //investors[msg.sender].investedBusd += bnbAmount;
        investors[msg.sender].userType = 1; //

        allReportList[msg.sender].push(allReport(tokenAmt,bnbAmount,block.timestamp,0,0,0,0));

        emit registerAt(msg.sender,bnbAmount,referer);
    }

    /*
    become agent for referral
    */

    function becomeAgent(uint bnbAmount) external {
        require(investors[msg.sender].registered,"User Not registered");
        require(bnbAmount == 50,"Minimum 50 Busd");
        
        bnbAmount = multiplyDecimal(bnbAmount); 
        //require(BEP20(busdToken).allowance(msg.sender,contractAddr)>=bnbAmount,"insufficient allowance");
        //require(BEP20(busdToken).balanceOf(msg.sender)>=bnbAmount,"insufficient balance");
        
        uint tokenAmt = calculateToken(bnbAmount);

        // transfer to contract
        //BEP20(busdToken).transferFrom(msg.sender,contractAddr,bnbAmount);
        
        investors[msg.sender].token += tokenAmt;
        //investors[msg.sender].investedBusd += bnbAmount;
        investors[msg.sender].userType = 2; //

        allReportList[msg.sender].push(allReport(tokenAmt,bnbAmount,block.timestamp,1,0,0,0));

        emit becomeAgentAt(msg.sender,bnbAmount);
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
        
        bnbAmount = multiplyDecimal(bnbAmount); 
        //require(BEP20(busdToken).allowance(msg.sender,contractAddr)>=bnbAmount,"insufficient allowance");
        //require(BEP20(busdToken).balanceOf(msg.sender)>=bnbAmount,"insufficient balance");
        
        uint tokenAmt = calculateToken(bnbAmount);

        
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
        //investors[msg.sender].refererAssociate = referer;
        investors[msg.sender].position = position;
        //investors[msg.sender].investedBusd += bnbAmount;
        investors[msg.sender].userType = 3; //
        
        allReportList[msg.sender].push(allReport(tokenAmt,bnbAmount,block.timestamp,2,0,0,0));

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

        bnbAmount = multiplyDecimal(bnbAmount);

        // transfer to contract
        //BEP20(busdToken).transferFrom(msg.sender,contractAddr,bnbAmount);

        uint tokenAmt = calculateToken(bnbAmount);

        //investors[msg.sender].investedBusd += bnbAmount;
        investors[msg.sender].token += tokenAmt;
        matrixpools[nextPoolId][msg.sender].exist=true;
        appendMatrix(msg.sender,nextPoolId);

         allReportList[msg.sender].push(allReport(tokenAmt,bnbAmount,block.timestamp,3,0,0,0));
    }   

    /*
      Distribute Matching Income to User By Admin EveryDay
    */

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
            uint matchIncome = distributeIncome*matchinVal;
            investors[singleAddr].matchingIncome +=  matchIncome;  
            allReportList[singleAddr].push(allReport(matchIncome,0,block.timestamp,0,0,2,1));
            matchingdatas[singleAddr].oldLeftUsers += matchinVal;
            matchingdatas[singleAddr].oldRightUsers += matchinVal;
          }

        }
        
        hourlyBinaryUser = 0;
       
    }


    /*
      withdrawal income by user
    */

    function withdraw(uint bnbAmount) external {
        
        require(bnbAmount==1,"Insufficient BNB amount");
        require(investors[msg.sender].registered,"User Should be regsitered");
        bnbAmount = multiplyDecimal(bnbAmount);

        uint balance = investors[msg.sender].referralIncome + investors[msg.sender].matrixIncome +
                      investors[msg.sender].matchingIncome +  investors[msg.sender].diamondIncome +
                      investorsData[msg.sender].generalIncome;
        uint availableBalance =   balance - investorsData[msg.sender].withdrawn;  
        require (availableBalance >= bnbAmount,"Insufficient Balance");        
        //require(BEP20(busdToken).balanceOf(contractAddr)>=bnbAmount,"insufficient balance");
        // BEP20(busdToken).transfer(msg.sender,bnbAmount);
        investorsData[msg.sender].withdrawn += bnbAmount;

        allReportList[msg.sender].push(allReport(bnbAmount,0,block.timestamp,0,1,0,1));
        
        emit withdrawal(msg.sender,bnbAmount,block.timestamp);
    }

      /*
      withdrawal income by user
    */

    function withdrawUserToken(uint amount) external {
        
        require(amount==1,"Insufficient BNB amount");
        require(investors[msg.sender].registered,"User Should be regsitered");
        amount = multiplyDecimal(amount);

        uint availableBalance =   investors[msg.sender].token - investorsData[msg.sender].withdrawn;  
        require (availableBalance >= amount,"Insufficient Balance");        
        //require(BEP20(customToken).balanceOf(contractAddr)>=amount,"insufficient balance");
        //BEP20(customToken).transfer(msg.sender,amount);
        investorsData[msg.sender].withdrawnToken += amount;

        allReportList[msg.sender].push(allReport(amount,0,block.timestamp,0,0,0,1));
        
        emit withdrawal(msg.sender,amount,block.timestamp);
    }


    // function withdrawalBnb(address payable _to, uint _amount) external onlyOwner{
    //     require(_amount != 0, "Zero amount error");
        
    //     payable(_to).transfer( _amount);
    // }

    function withdrawalToken(address payable _to, address _token, uint _amount) external onlyOwner{
        require(msg.sender == owner, "Only owner");
        require(_amount != 0, "Zero amount error");
        BEP20 tokenObj;
        uint amount   = multiplyDecimal(_amount);
        tokenObj = BEP20(_token);
        tokenObj.transfer(_to, amount);
    }
    function transferOwnership(address _to) external onlyOwner{
        require(msg.sender == owner, "Only owner");
        address oldOwner  = owner;
        owner = _to;
        emit OwnershipTransferred(oldOwner,_to);
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



    function referralIncome() internal {
        address rec = investors[msg.sender].referer;
        
        for (uint i = 0; i < 20; i++) {
            if (!investors[rec].registered) {
                break;
            }
            if(investors[rec].userType>=3){
              uint refInc = multiplyDecimal(referralLevelIncome[i])/10;
              investors[rec].referralIncome += refInc;
              allReportList[rec].push(allReport(refInc,0,block.timestamp,0,0,0,1));
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
          uint tenMatrixInc = multiplyDecimal(10);
          investors[parentMatrixAddr].matrixIncome += tenMatrixInc; // add pool income to parent
          allReportList[parentMatrixAddr].push(allReport(tenMatrixInc,0,block.timestamp,0,0,1,1));

          address parentMatrixAddrRefer = matrixpools[poolId][parentMatrixAddr].referral;
          if(matrixpools[poolId][parentMatrixAddrRefer].belowCount!=11 
            && matrixpools[poolId][parentMatrixAddrRefer].belowCount!=12){
            // add pool income to grand parent
            investors[parentMatrixAddrRefer].matrixIncome += tenMatrixInc;
            allReportList[parentMatrixAddrRefer].push(allReport(tenMatrixInc,0,block.timestamp,0,0,1,1));
          }
          else{
            // send 11 and 12th child bonus to system which will user for reborn
            systemIncome += tenMatrixInc;
          }
          if(matrixpools[poolId][parentMatrixAddrRefer].belowCount==12){
            // reset below count of reborn address
            matrixpools[poolId][parentMatrixAddrRefer].belowCount = 0;
            

            appendMatrix(parentMatrixAddrRefer, poolId);
            
            resetReborn(parentMatrixAddrRefer);

            matrixpools[poolId][parentMatrixAddrRefer].leftUser = address(nullAddr);
            matrixpools[poolId][parentMatrixAddrRefer].middleUser = address(nullAddr);
            matrixpools[poolId][parentMatrixAddrRefer].rightUser = address(nullAddr);

          }
        }
        else {
          uint poolAmount = poolBase[poolId];
          uint systemAmt = poolAmount*20/100;
          uint systemAmtDecimal = multiplyDecimal(systemAmt);
          // send 20% to system for all pool expect first
          systemIncome += systemAmtDecimal;

          uint remainingAmt = poolAmount - systemAmt;
          uint distributeAmt = remainingAmt/2;
          distributeAmt = multiplyDecimal(distributeAmt);

          // send half income to parent
          investors[parentMatrixAddr].matrixIncome += distributeAmt;
          allReportList[parentMatrixAddr].push(allReport(distributeAmt,0,block.timestamp,0,0,1,1));
          // send other half income to grand parent
          address parentMatrixAddrRefer = matrixpools[poolId][parentMatrixAddr].referral;
          investors[parentMatrixAddrRefer].matrixIncome += distributeAmt;
          allReportList[parentMatrixAddrRefer].push(allReport(distributeAmt,0,block.timestamp,0,0,1,1));
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


}