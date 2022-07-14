/**
 *Submitted for verification at BscScan.com on 2022-07-14
*/

/**
 *Submitted for verification at Etherscan.io on 2020-03-27
*/

pragma solidity 0.5.9; /*


___________________________________________________________________
  _      _                                        ______           
  |  |  /          /                                /              
--|-/|-/-----__---/----__----__---_--_----__-------/-------__------
  |/ |/    /___) /   /   ' /   ) / /  ) /___)     /      /   )     
__/__|____(___ _/___(___ _(___/_/_/__/_(___ _____/______(___/__o_o_



 ██████╗ ██╗██╗     ██╗     ██╗ ██████╗ ███╗   ██╗    ███╗   ███╗ ██████╗ ███╗   ██╗███████╗██╗   ██╗
 ██╔══██╗██║██║     ██║     ██║██╔═══██╗████╗  ██║    ████╗ ████║██╔═══██╗████╗  ██║██╔════╝╚██╗ ██╔╝
 ██████╔╝██║██║     ██║     ██║██║   ██║██╔██╗ ██║    ██╔████╔██║██║   ██║██╔██╗ ██║█████╗   ╚████╔╝ 
 ██╔══██╗██║██║     ██║     ██║██║   ██║██║╚██╗██║    ██║╚██╔╝██║██║   ██║██║╚██╗██║██╔══╝    ╚██╔╝  
 ██████╔╝██║███████╗███████╗██║╚██████╔╝██║ ╚████║    ██║ ╚═╝ ██║╚██████╔╝██║ ╚████║███████╗   ██║   
 ╚═════╝ ╚═╝╚══════╝╚══════╝╚═╝ ╚═════╝ ╚═╝  ╚═══╝    ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝   ╚═╝   
                                                                                            


-------------------------------------------------------------------
 Copyright (c) 2020 onwards Billion Money Inc. ( https://billionmoney.live )
-------------------------------------------------------------------
 */


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



//*******************************************************************//
//------------------         token interface        -------------------//
//*******************************************************************//

 interface tokenInterface
 {
    function transfer(address _to, uint256 _amount) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);
 }


interface oldContractInerface
{
    function autoPoolLevel(uint _lvl, uint _index) external view returns (uint32, uint32);     
}

interface AdminControl 
{

// it will manage all price dist

}




//*******************************************************************//
//------------------        MAIN contract         -------------------//
//*******************************************************************//

contract billionMoney is owned {

    // Replace below address with main token token
    address public tokenAddress;
    address public nextSwapAddress;
    address public oldBMContractAddress;
    mapping(address => uint) public maxDownLimit_;
    uint public startTime = now;
    uint public levelLifeTime = 900;  // =120 days;
    uint public lastIDCount = 0;
    uint public defaultRefID = 1;   //this ref ID will be used if user joins without any ref 
    address payable defaultAddress;
    bool public goLive;

    mapping(address => bool ) public lockWithdraw;

    struct userInfo {
        bool joined;
        uint id;
        uint parentID;
        uint referrerID;
        uint directCount;
        address[] parent;
        address[] referral;
        uint8 maxLevel;
        bool isRoiDeactive;
        

    }


    struct userGain{

        uint256  totalGainInMainNetwork; //Main lavel income system income will go here with owner mapping
        uint256  totalGainInUniLevel; 
        uint256  totalGainInAutoPool;
        uint256  netTotalUserWithdrawable_;  //Dividend is not included in it
        uint256  totalGainDirect;  //Dividend is not included in it

        uint256  totalWithdrawnInMainNetwork; //Main lavel income system income will go here with owner mapping
        uint256  totalWithdrawnInUniLevel; 
        uint256  totalWithdrawnInAutoPool;
        uint256  netTotalUserWithdrawn_;  //Dividend is not included in it
        uint256  totalWithdrawnDirect;  //Dividend is not included in it
        uint     totalWithdrawn;

        uint expReturn;
        uint returnShare;
        uint totalPassiveGain;

    }

    uint public returnTodayCollection; // IT WILL HOLD DAILY  ROI COLLECTION
  
    uint returnTotalFundCollection; //total ROI fund
    uint totalPassiveEligible; // total people eligible for ROI

    uint lastPassiveClose;
 
    
    mapping(uint => uint) public priceOfLevel;
    mapping(uint => uint) public distForLevel;
    mapping(uint => uint) public autoPoolDist;
    mapping(uint => uint) public uniLevelDistPart;

    uint public dividendGraceDays = 600;
  

    uint256 public totalIncomingFund;
    uint256 public totalPaidFromSystem;


    uint[11] public globalDivDistPart;
    uint systemDistPart;
    
    uint public oneMonthDuration = 300; // = 30 days
    uint public thisMonthEnd;

    
    struct autoPool
    {
        uint userID;
        uint autoPoolParent;
    }
    mapping(uint => autoPool[]) public autoPoolLevel;  // users lavel records under auto pool scheme
    mapping(address => mapping(uint => uint[])) private autoPoolIndex; //to find index of user inside auto pool
    uint[10] public nextMemberFillIndex;  // which auto pool index is in top of queue to fill in 
    uint[10] public nextMemberFillBox;   // 3 downline to each, so which downline need to fill in

    uint[10][10] private autoPoolSubDist;

    uint public inActivePenalty = 500000;
    uint public penaltyGracePeriod = 600;
    mapping(address => uint) public debitNote;

    mapping (address => userInfo) public userInfos;
    mapping(address=> userGain) public userGains;
    mapping (uint => address payable) public userAddressByID;


    event regLevelEv(address indexed _userWallet, uint indexed _userID, uint indexed _parentID, uint _time, address _refererWallet, uint _referrerID);
    event levelBuyEv(address indexed _user, uint _level, uint _amount, uint _time);
    event paidForLevelEv(address indexed _user, address indexed _referral, uint _level, uint _amount, uint _time);
    event lostForLevelEv(address indexed _user, address indexed _referral, uint _level, uint _amount, uint _time);
    event payDividendEv(uint timeNow,uint payAmount,address paitTo);
    event payDividendEv_(uint timeNow,uint payAmount,address paitTo);
    event updateAutoPoolEv(uint timeNow,uint autoPoolLevelIndex,uint userIndexInAutoPool, address user);
    event autoPoolPayEv(uint timeNow,address paidTo,uint paidForLevel, uint paidAmount, address paidAgainst);
    event paidForUniLevelEv(uint timeNow,address PaitTo,uint Amount);
    event paidForSystem(address _against, uint _amount);
    event paidToDirect(address from,address to , uint amount);
    
    constructor(address payable ownerAddress, address payable ID1address) public {
        owner = ownerAddress;
        defaultAddress = address(uint160(owner));

        emit OwnershipTransferred(address(0), owner);
        address payable ownerWallet = ID1address;

        systemDistPart = 1000000;

        globalDivDistPart[1] = 1000000;
        globalDivDistPart[2] = 1000000;
        globalDivDistPart[3] = 2000000;
        globalDivDistPart[4] = 6000000;
        globalDivDistPart[5] = 27500000;
        globalDivDistPart[6] = 120000000;
        globalDivDistPart[7] = 135000000;
        globalDivDistPart[8] = 225000000;
        globalDivDistPart[9] = 360000000;
        globalDivDistPart[10] = 690000000;

        priceOfLevel[1] = 25000000;
        priceOfLevel[2] = 25000000;
        priceOfLevel[3] = 50000000;
        priceOfLevel[4] = 140000000;
        priceOfLevel[5] = 600000000;
        priceOfLevel[6] = 2500000000;
        priceOfLevel[7] = 3000000000;
        priceOfLevel[8] = 5000000000;
        priceOfLevel[9] = 8000000000;
        priceOfLevel[10] = 15000000000;

        distForLevel[1] = 10000000;
        distForLevel[2] = 15000000;
        distForLevel[3] = 30000000;
        distForLevel[4] = 90000000;
        distForLevel[5] = 412500000;
        distForLevel[6] = 1800000000;
        distForLevel[7] = 2025000000;
        distForLevel[8] = 3375000000;
        distForLevel[9] = 5400000000;
        distForLevel[10] = 10350000000;

        autoPoolDist[1] = 4000000;
        autoPoolDist[2] = 5000000;
        autoPoolDist[3] = 10000000;
        autoPoolDist[4] = 20000000;
        autoPoolDist[5] = 50000000;
        autoPoolDist[6] = 100000000;
        autoPoolDist[7] = 300000000;
        autoPoolDist[8] = 500000000;
        autoPoolDist[9] = 800000000;
        autoPoolDist[10]= 1200000000;         



        uniLevelDistPart[1] = 1000000;
        uniLevelDistPart[2] = 800000;
        uniLevelDistPart[3] = 600000;
        uniLevelDistPart[4] = 400000;

        for (uint i = 5 ; i < 11; i++)
        {
           uniLevelDistPart[i] =  200000;
        } 


        userInfo memory UserInfo;
        lastIDCount++;

        UserInfo = userInfo({
            joined: true,
            id: lastIDCount,
            parentID: 0,
            referrerID: 0,
            directCount: 31,  
            referral: new address[](0),
            parent: new address[](0),
            maxLevel:10,
            isRoiDeactive:false
        });
        userInfos[ownerWallet] = UserInfo;
        userAddressByID[lastIDCount] = ownerWallet;


        autoPool memory temp;
        for (uint i = 11 ; i < 21; i++)
        {
           uniLevelDistPart[i] =  100000;
           uint a = i-11;
           temp.userID = lastIDCount;  
           autoPoolLevel[a].push(temp);
         
           autoPoolIndex[ownerWallet][a].push(0);
           uint distPart = autoPoolDist[a+1];
           autoPoolSubDist[a][0] = distPart * 1250 / 10000;
           autoPoolSubDist[a][1] = distPart * 1250 / 10000;
           autoPoolSubDist[a][2] = distPart * 1000 / 10000;
           autoPoolSubDist[a][3] = distPart * 750 / 10000;
           autoPoolSubDist[a][4] = distPart * 750 / 10000;
           autoPoolSubDist[a][5] = distPart * 750 / 10000;
           autoPoolSubDist[a][6] = distPart * 750 / 10000;
           autoPoolSubDist[a][7] = distPart * 1000 / 10000;
           autoPoolSubDist[a][8] = distPart * 1250 / 10000;                                                                             
           autoPoolSubDist[a][9] = distPart * 1250 / 10000;
        }

      
        emit regLevelEv(ownerWallet, 1, 0, now, address(this), 0);

    }

    function () payable external {
        regUser(defaultRefID, 0);
    }


    function goLive_() public onlyOwner returns(bool)
    {
        goLive = true;
        return true;
    }
    function regUser(uint _referrerID, uint _parentID) public payable returns(bool) 
    {

        require(goLive, "pls wait");
        address(uint160(owner)).transfer(msg.value);
        //this saves gas while using this multiple times
        address msgSender = msg.sender; 
        uint pID = _referrerID;

        if(_parentID > 0 && _parentID != _referrerID) pID = _parentID;

        address origRef = userAddressByID[_referrerID];
        if(_referrerID == _parentID && _parentID != 0) increaseDownLimit(origRef);

        //checking all conditions
        require(!userInfos[msgSender].joined, 'User exist');

        _parentID = lastIDCount; // from here _parentID is lastIDCount
        if(!(pID > 0 && pID <= _parentID)) pID = defaultRefID;

        address pidAddress = userAddressByID[pID];
        if(userInfos[pidAddress].parent.length >= maxDownLimit(pidAddress) ) pID = userInfos[findFreeReferrer(pidAddress)].id;


        uint prc = priceOfLevel[1];
        //transferring tokens from smart user to smart contract for level 1
        require( tokenInterface(tokenAddress).transferFrom(msgSender, address(this), prc),"token transfer failed");
        totalIncomingFund += prc;
        //update variables
        userInfo memory UserInfo;
        _parentID++;

        UserInfo = userInfo({
            joined: true,
            id: _parentID,
            parentID: pID,
            referrerID: _referrerID,
            directCount: 0,             
            referral: new address[](0),
            parent: new address[](0),
            maxLevel:1,
            isRoiDeactive:false


        });

        userInfos[msgSender] = UserInfo;
        userAddressByID[_parentID] = address(uint160(msgSender));

       

        userInfos[userAddressByID[pID]].parent.push(msgSender);

        // actlive

        setUserGain(userAddressByID[_referrerID],1,globalDivDistPart[1] * 4);


        userGains[userAddressByID[1]].totalGainInMainNetwork += systemDistPart;
        userGains[userAddressByID[1]].netTotalUserWithdrawable_ += systemDistPart;
        emit paidForSystem(msgSender, systemDistPart);

        CalculateDailyRoi(1);
 
        updateROI( msgSender, priceOfLevel[1]); // only when level buy is not calling inside calling block
        
        userInfos[origRef].directCount++;
        userInfos[origRef].referral.push(msgSender);
     
        lastIDCount = _parentID;
        require(spkitPart(msgSender,_parentID,pID,_referrerID,prc),"split part failed");
        return true;
    }

    function spkitPart(address msgSender, uint lID, uint pID, uint _referrerID, uint prc) internal returns(bool)
    {
        require(payForLevel(1, msgSender,0),"pay for level fail");
        emit regLevelEv(msgSender, lID, pID, now,userAddressByID[pID], _referrerID );
        emit levelBuyEv(msgSender, 1, prc, now);
        require(updateNPayAutoPool(1,msgSender),"auto pool update fail");        
        return true;
    }

    function maxDownLimit(address _user) public view returns(uint)
    {
        uint dl = maxDownLimit_[_user];
        if(dl == 0 ) dl = 2;
        return dl;
    }


    function increaseDownLimit(address _user) internal  returns(bool)
    {
        if(maxDownLimit_[_user] == 0) maxDownLimit_[_user] = 3;
        else maxDownLimit_[_user] ++;
        return true;
    }



    function lockMyWithdraw() public returns(bool)
    {
        lockWithdraw[msg.sender] = true;
        return true;
    }

    


    function buyLevel(uint8 _level) public payable returns(bool){
        require(goLive, "pls wait");
        //require(msg.value == levelBuyTxCost, "pls pay tx cost");
        address(uint160(owner)).transfer(msg.value);
        //this saves gas while using this multiple times
        address msgSender = msg.sender;   
        
        
        //checking conditions
        require(userInfos[msgSender].joined, 'User not exist'); 

        require(_level >= 1 && _level <= 10, 'Incorrect level');
        require(_level<=userInfos[msgSender].maxLevel+1,"level Invalid");
        
        //transfer tokens
        require( tokenInterface(tokenAddress).transferFrom(msgSender, address(this), priceOfLevel[_level]),"token transfer failed");
        totalIncomingFund += priceOfLevel[_level];
      
        
 

        address reff = userAddressByID[userInfos[msgSender].referrerID];
        setUserGain(reff,_level,globalDivDistPart[_level] * 4);
        
    
        // address origRef = userAddressByID[userInfos[msgSender].referrerID];

        if (userInfos[msgSender].maxLevel<_level){

            userInfos[msgSender].maxLevel=_level;
        }


        //userInfos[origRef].directCount++;
      
        //topBase[origRef]++; 

        // div update--
        CalculateDailyRoi(_level);
        updateROI( msgSender, priceOfLevel[_level]);

        require(payForLevel(_level, msgSender,0),"pay for level fail");
        emit levelBuyEv(msgSender, _level, priceOfLevel[_level] , now);
        require(updateNPayAutoPool(_level,msgSender),"auto pool update fail");
        return true;
    }

    function anyActive(address _user, uint8 _level) internal view returns(bool)
    {
        if (userInfos[_user].maxLevel>=_level){

             return true;
        }

        return false;

      
    }


    function payForLevel(uint8 _level, address _user, uint _runtime) internal returns(bool) {

        address [] memory userGainList; 
        address [] memory userLostList;

        uint gainId;
        uint looseId;

        address referer=_user;

        for (uint i=0; i<_level;i++){

             referer = userAddressByID[userInfos[referer].referrerID];
             // use a check for maxLevel
             
			if(anyActive(referer,_level))
			{
                userGainList[gainId]=(referer);
                gainId++;

            }else{

                userLostList[looseId]=(referer);
                looseId++;
            }

        }

        if (userGainList.length==0 && _runtime==5){

            userGainList[0]=(defaultAddress); // default is only eligible after checking recursive five times
        }

        // dist fund calculation

        uint lvlAmount = distForLevel[_level];
        uint loosePerPerson;
        uint gainPerPerson ;

        if (userLostList.length>0){

            loosePerPerson= lvlAmount/(userGainList.length+userLostList.length);
        }

        if (userGainList.length>0){

            gainPerPerson = lvlAmount/userGainList.length;            
        }
       
        for(uint i=0; i< userLostList.length;i++){

            emit lostForLevelEv(userLostList[i], _user, _level,loosePerPerson, now);
        }


        if (userGainList.length>0){

            // distribute

            for(uint i=0; i<userGainList.length;i++){

                userGains[userGainList[i]].totalGainInMainNetwork += gainPerPerson;
				userGains[userGainList[i]].netTotalUserWithdrawable_ += gainPerPerson;
				emit paidForLevelEv(userGainList[i], _user, _level, gainPerPerson, now);
                // if current is level 1 then only run unilevel

                if (_level==1){

                        payForUniLevel(userInfos[_user].parentID, _level);		
                }
            }


        }else{

            // recursion
            _runtime++;
            payForLevel( _level,referer,_runtime);

        }

        return true;


    }




    function findFreeReferrer(address _user) public view returns(address) {
        uint _limit = maxDownLimit(_user);
        if(userInfos[_user].parent.length < _limit ) return _user;

        address[] memory referrals = new address[](126);

        uint j;
        for(j=0;j<_limit;j++)
        {
            referrals[j] = userInfos[_user].parent[j];
        }

        address freeReferrer;
        bool noFreeReferrer = true;

        for(uint i = 0; i < 126; i++) {

            _limit = maxDownLimit(referrals[i]);

            if(userInfos[referrals[i]].parent.length == _limit) {

                if(j < 62) {
                    
                    for(uint k=0;k< _limit;k++)
                    {
                        referrals[j] = userInfos[referrals[i]].parent[k];
                        j++;
                    }

                }
            }
            else {
                noFreeReferrer = false;
                freeReferrer = referrals[i];
                break;
            }
        }

        require(!noFreeReferrer, 'No Free Referrer');

        return freeReferrer;
    }


    function payForUniLevel(uint _referrerID, uint8 _level) internal returns(bool)
    {
        uint256 endID = 21;
        for (uint i = 0 ; i < endID; i++)
        {
            address usr = userAddressByID[_referrerID];
            _referrerID = userInfos[usr].parentID;
            if(usr == address(0) ) usr = defaultAddress;
            uint Amount = uniLevelDistPart[i + 1 ];
            if(anyActive(usr,_level))
            {
                userGains[usr].totalGainInUniLevel += Amount;
                userGains[usr].netTotalUserWithdrawable_ += Amount;
            }
            else
            {
                userGains[defaultAddress].totalGainInUniLevel += Amount;
               userGains[defaultAddress].netTotalUserWithdrawable_ += Amount;
            }
            emit paidForUniLevelEv(now,usr, Amount);
        }
        return true;
    }

    event withdrawMyGainEv(uint timeNow,address caller,uint totalAmount);
    event debitAdjusted(address _user, uint amount);
    function withdrawMyDividendNAll() public payable returns(uint)
    {
        
        require(!lockWithdraw[msg.sender], "you locked withdraw");
            
        address(uint160(owner)).transfer(msg.value);
        address payable caller = msg.sender;
        require(userInfos[caller].joined, 'User not exist');
        uint totalAmount;
        uint totalAmount_;

        

        totalAmount = totalAmount + totalAmount_ + userGains[caller].netTotalUserWithdrawable_;
        uint dN = debitNote[msg.sender];
        if(totalAmount >= dN)
        {
            totalAmount = totalAmount - dN;
            emit debitAdjusted(msg.sender, dN);
            debitNote[msg.sender] = 0;
        }
        else
        {
            debitNote[msg.sender] = dN - totalAmount;
            emit debitAdjusted(msg.sender, totalAmount);
            totalAmount = 0;
        }

        // income reset

        userGains[caller].netTotalUserWithdrawn_+= userGains[caller].netTotalUserWithdrawable_;
        userGains[caller].totalWithdrawnDirect += userGains[caller].totalGainDirect;
        userGains[caller].totalWithdrawnInAutoPool += userGains[caller].totalGainInAutoPool;
        userGains[caller].totalWithdrawnInMainNetwork += userGains[caller].totalGainInMainNetwork;
        userGains[caller].totalWithdrawnInUniLevel += userGains[caller].totalGainInUniLevel;
        totalPaidFromSystem += totalAmount;
        resetUserGain(caller);
        userGains[caller].totalWithdrawn += totalAmount;
        // usergains
        if(totalAmount > 0 && goLive) require(tokenInterface(tokenAddress).transfer(msg.sender, totalAmount),"token transfer failed");
        emit withdrawMyGainEv(now, caller, totalAmount);
        
    }





    function updateNPayAutoPool(uint _level,address _user) internal returns (bool)
    {
        uint a = _level -1;
        uint len = autoPoolLevel[a].length;
        autoPool memory temp;
        temp.userID = userInfos[_user].id;
        uint idx = nextMemberFillIndex[a];
        temp.autoPoolParent = idx;       
        autoPoolLevel[a].push(temp);        
        

        address payable usr = userAddressByID[autoPoolLevel[a][idx].userID];
        if(usr == address(0)) usr = userAddressByID[1];
        for(uint i=0;i<10;i++)
        {
            uint amount = autoPoolSubDist[a][i];
            userGains[usr].totalGainInAutoPool += amount;
            userGains[usr].netTotalUserWithdrawable_ += amount;
            emit autoPoolPayEv(now, usr,a+1, amount, _user);
            idx = autoPoolLevel[a][idx].autoPoolParent; 
            usr = userAddressByID[autoPoolLevel[a][idx].userID];
            if(usr == address(0)) usr = userAddressByID[1];
        }

        if(nextMemberFillBox[a] == 0)
        {
            nextMemberFillBox[a] = 1;
        }   
        else if (nextMemberFillBox[a] == 1)
        {
            nextMemberFillBox[a] = 2;
        }
        else
        {
            nextMemberFillIndex[a]++;
            nextMemberFillBox[a] = 0;
        }
        autoPoolIndex[_user][_level - 1].push(len);
        emit updateAutoPoolEv(now, _level, len, _user);
        return true;
    }


    function viewUserReferral(address _user) public view returns(address[] memory) {
        return userInfos[_user].referral;
    }





    function viewUsersOfParent(address _user) public view returns(address[] memory) {
        return userInfos[_user].parent;
    }



    function bytesToAddress(bytes memory bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }
    
    function indexLength(uint _level) public view returns(uint)
    {
        if(!(_level > 0  || _level < 11)) return 0;
        return autoPoolLevel[_level - 1].length;
    }  



    /*======================================
    =            OWNER FUNCTIONS           =
    ======================================*/



    function changetokenaddress(address newtokenaddress,address _oldBMContractAddress, address _nextSwapAddress) onlyOwner public returns(string memory){
        //if owner makes this 0x0 address, then it will halt all the operation of the contract. This also serves as security feature.
        //so owner can halt it in any problematic situation. Owner can then input correct address to make it all come back to normal.
        tokenAddress = newtokenaddress;
        oldBMContractAddress = _oldBMContractAddress;
        nextSwapAddress = _nextSwapAddress;
        return("token address updated successfully");
    }


    function changeDefaultRefID(uint newDefaultRefID) onlyOwner public returns(string memory){
        //this ref ID will be assigned to user who joins without any referral ID.
        defaultRefID = newDefaultRefID;
        return("Default Ref ID updated successfully");
    }

    function changeDefaultAddress(address payable _defaultAddress) onlyOwner public returns(string memory){
        //this ref ID will be assigned to user who joins without any referral ID.
        userInfo memory UserInfo;
        UserInfo = userInfo({
            joined: true,
            id: 0,
            parentID: 0,
            referrerID: 0,
            directCount: 31,  
            referral: new address[](0),
            parent: new address[](0),
            maxLevel:10,
            isRoiDeactive:false
        });
        userInfos[_defaultAddress] = UserInfo;
        userAddressByID[0] = _defaultAddress;
        defaultAddress = _defaultAddress;

        if(defaultAddress == address(0))
        {
            userInfos[userAddressByID[1]].parentID = 1;
            userInfos[userAddressByID[1]].referrerID = 1;
        }

        return("Default address updated successfully");
    }

    function swapContract(uint amount) public onlyOwner returns(bool){
        tokenInterface(tokenAddress).transfer(nextSwapAddress, amount);
        return true;        
    }

    function swapContract_(uint amount) public onlyOwner returns(bool){
        address(uint160(nextSwapAddress)).transfer(amount);
        return true;        
    }



    function setInactiveFineNDays(uint _inActivePenalty, uint _penaltyGracePeriod ) public onlyOwner returns(bool)
    {
        inActivePenalty = _inActivePenalty;
        penaltyGracePeriod = _penaltyGracePeriod;
        return true;
    }


    // only admin can call this function on request of user in case private key is compormised 
    function changeUserAddress(address oldAddress, address newAddress) public onlyOwner returns(bool)
    {
        require(!userInfos[newAddress].joined , "this is existing address ");
        uint uid = userInfos[oldAddress].id;
        uint pid = userInfos[oldAddress].parentID;
        uint rid = userInfos[oldAddress].referrerID;

        userInfos[newAddress] = userInfos[oldAddress];
        
        uint i;


        userInfo memory temp;
        userInfos[oldAddress] = temp;

        userAddressByID[uid] = address(uint160(newAddress));

        address parent_ = userAddressByID[pid];
        for(i=0;i<userInfos[parent_].parent.length; i++)
        {
            if(userInfos[parent_].parent[i] == oldAddress ) 
            {
                userInfos[parent_].parent[i] = newAddress;
                break;
            }
        }

        address referal_ = userAddressByID[rid];
        for(i=0;i<userInfos[referal_].referral.length; i++)
        {
            if(userInfos[referal_].referral[i] == oldAddress ) 
            {
                userInfos[referal_].referral[i] = newAddress;
                break;
            }
        } 

       // transfer all gain
        userGains[newAddress].netTotalUserWithdrawable_ = userGains[oldAddress].netTotalUserWithdrawable_;

        userGains[newAddress].totalGainDirect = userGains[oldAddress].totalGainDirect;
      
        userGains[newAddress].totalGainInAutoPool = userGains[oldAddress].totalGainInAutoPool;
      
        userGains[newAddress].totalGainInMainNetwork = userGains[oldAddress].totalGainInMainNetwork;
       
        userGains[newAddress].totalGainInUniLevel = userGains[oldAddress].totalGainInUniLevel;

        resetUserGain(oldAddress);
        
        userGains[newAddress].totalWithdrawn = userGains[oldAddress].totalWithdrawn;        
        userGains[oldAddress].totalWithdrawn = 0;



        return true;
    }

/*
    function setTxCost(uint _regTxCost, uint _levelBuyTxCost, uint _withdrawTxCost) public onlyOwner returns(bool)
    {
        regTxCost = _regTxCost;
        levelBuyTxCost = _levelBuyTxCost;
        withdrawTxCost = _withdrawTxCost;
        return true;
    }
*/

    function unLockWithdraw(address _user) public onlyOwner returns(bool)
    {
        lockWithdraw[_user] = false;
        return true;
    }

    /*======================================
    =            SWAP FUNCTIONS           =
    ======================================*/



    function swapRegUser(address _user, uint _referrerID, uint _parentID) public onlySigner returns(bool) 
    {
        require(startTime + 120 days > now, "this function is blocked forever");
        //this saves gas while using this multiple times
        address msgSender = _user; 
        uint pID = _referrerID;

        if(_parentID > 0 && _parentID != _referrerID) pID = _parentID;

        address origRef = userAddressByID[_referrerID];
        if(_referrerID == _parentID && _parentID != 0) increaseDownLimit(origRef);

        //checking all conditions
        require(!userInfos[msgSender].joined, 'User exist');

        _parentID = lastIDCount; // from here _parentID is lastIDCount
        if(!(pID > 0 && pID <= _parentID)) pID = defaultRefID;

        address pidAddress = userAddressByID[pID];
        if(userInfos[pidAddress].parent.length >= maxDownLimit(pidAddress) ) pID = userInfos[findFreeReferrer(pidAddress)].id;


        uint prc = priceOfLevel[1];
        totalIncomingFund += prc;

        //update variables
        userInfo memory UserInfo;
        _parentID++;

        UserInfo = userInfo({
            joined: true,
            id: _parentID,
            parentID: pID,
            referrerID: _referrerID,
            directCount: 0,             
            referral: new address[](0),
            parent: new address[](0),
            maxLevel:1,
            isRoiDeactive:false
        });

        userInfos[msgSender] = UserInfo;
        userAddressByID[_parentID] = address(uint160(msgSender));


        userInfos[userAddressByID[pID]].parent.push(msgSender);

         setUserGain(userAddressByID[_referrerID],1, globalDivDistPart[1] * 4); // optimized call

  
        userGains[userAddressByID[1]].totalGainInMainNetwork += systemDistPart;
        userGains[userAddressByID[1]].netTotalUserWithdrawable_ += systemDistPart;
        emit paidForSystem(msgSender, systemDistPart);
        
        
        userInfos[origRef].directCount++;
        userInfos[origRef].referral.push(msgSender);
    
      
        lastIDCount = _parentID;
        require(spkitPart_(msgSender,_parentID,pID,_referrerID,prc),"split part failed");
        return true;
    }

    function spkitPart_(address msgSender, uint lID, uint pID, uint _referrerID, uint prc) internal returns(bool)
    {
        require(payForLevel(1, msgSender,0),"pay for level fail");
        emit regLevelEv(msgSender, lID, pID, now,userAddressByID[pID], _referrerID );
        emit levelBuyEv(msgSender, 1, prc, now);
        require(updateNPayAutoPool(1,msgSender),"auto pool update fail");        
        return true;
    }

    function swapBuyLevel(address _user, uint8 _level) public onlySigner returns(bool)
    {
        require(startTime + 120 days > now, "this function is blocked forever");
        //require(lastUserInLevel(_level) != _user, "This user just punched in the last");
        address msgSender = _user;   
        
        
        //checking conditions
        require(userInfos[msgSender].joined, 'User not exist'); 

        require(_level >= 1 && _level <= 10, 'Incorrect level');
        

        address reff = userAddressByID[userInfos[msgSender].referrerID];

        setUserGain(reff,_level,globalDivDistPart[_level] * 4); // optimized call

        totalIncomingFund += priceOfLevel[_level];
   
        require(payForLevel(_level, msgSender,0),"pay for level fail");
        emit levelBuyEv(msgSender, _level, priceOfLevel[_level] , now);
        require(updateNPayAutoPool(_level,msgSender),"auto pool update fail");

        return true;        

    }

    function viewAutoPoolIndex(address _user, uint _level) public view returns(uint[] memory)
    {
        return autoPoolIndex[_user][_level-1];
    }

    function oldDebit(address _user, uint _amount) public onlyOwner returns(bool)
    {
        require(startTime + 120 days > now, "this function is blocked forever");
        debitNote[_user] = _amount;
        return true;
    }

    function lastUserAddress() external view returns(address _user)
    {
        return userAddressByID[lastIDCount]; 
    }


    function lastIDView() external view returns (uint lastID){
        lastID = lastIDCount;
    }

    function lastUserInLevel(uint level) public view returns(address user)
    {
        return userAddressByID[autoPoolLevel[level-1][autoPoolLevel[level-1].length -1].userID]; 
    }


	function findRefById(uint _id) public view returns(uint)
    {
        return userInfos[(findFreeReferrer(userAddressByID[_id]))].id;
    }


    //------------------OPTIMIZED CODE BLOCKS----------------

    function setUserGain(address _user, uint8 _level, uint _amount) internal {
        address msgSender= msg.sender;

        if(anyActive(_user,_level))
        {        
            userGains[_user].totalGainDirect += _amount;
            userGains[_user].netTotalUserWithdrawable_ += _amount;
            emit paidToDirect(msgSender, _user, _amount);
        }
        else
        {
            userGains[defaultAddress].totalGainDirect += _amount;
            userGains[defaultAddress].netTotalUserWithdrawable_ += _amount;
            emit paidToDirect(msgSender, defaultAddress, _amount);            
        }
    }

    function resetUserGain(address caller) internal{

        userGains[caller].netTotalUserWithdrawable_ = 0;
        userGains[caller].totalGainDirect = 0;
        userGains[caller].totalGainInAutoPool = 0;
        userGains[caller].totalGainInMainNetwork = 0;
        userGains[caller].totalGainInUniLevel = 0;
        
    }

    function updateROI(address userAddress, uint _amount) internal {

        // update user return share 
        if (userGains[userAddress].expReturn==0 && userGains[userAddress].returnShare==0){

            // newly user 
            totalPassiveEligible++;
            userGains[userAddress].expReturn=_amount;

        }else if (userGains[userAddress].expReturn==0 && userGains[userAddress].returnShare!=0 && userInfos[userAddress].isRoiDeactive==false ){

            // when user get his all expfund

                totalPassiveEligible--;
                userInfos[userAddress].isRoiDeactive=true;


        }else if (userInfos[userAddress].isRoiDeactive==true && userGains[userAddress].expReturn==0 ){

            // re-active old user
            totalPassiveEligible++;
            userGains[userAddress].expReturn=_amount;
            userInfos[userAddress].isRoiDeactive=false;
        }

        userGains[userAddress].returnShare=returnTotalFundCollection;
        

        if(userInfos[userAddress].directCount>=5){

            userGains[userAddress].expReturn=_amount*2;
        }

        //return closing 

        if(lastPassiveClose>= 86400){
            returnTotalFundCollection+=returnTodayCollection;
            returnTodayCollection=0; //reset 
            lastPassiveClose= block.timestamp;
        }

    }


    // passive call

    function CalculateDailyRoi(uint8 _level) internal{

        uint calcAmount = priceOfLevel[_level];
        returnTodayCollection+=calcAmount;

    } 

    function closeTodayPassiveIncome() public returns(bool) {

        require(returnTodayCollection>0,"You don't have enough roiFund");
        require(lastPassiveClose>=86400,"you can't close before 1 day ");
        returnTotalFundCollection+=returnTodayCollection;
        returnTodayCollection=0; //reset 
        lastPassiveClose= block.timestamp;

        //todayROIShare = returnTotalFundCollection/totalRoiEligible;
        
        return true;

     }

    function claimPassiveIncome() public returns(bool) {

        require(returnTotalFundCollection>0 ,"You don't have enough roiFund");
        require(userGains[msg.sender].returnShare>0 && userGains[msg.sender].expReturn>0,"invalid");
        uint lastShare = userGains[msg.sender].returnShare;
        uint transAmount= returnTotalFundCollection-lastShare;
        
        if (transAmount>userGains[msg.sender].expReturn){

            transAmount=userGains[msg.sender].expReturn;
        }

        if (transAmount>0){

            userGains[msg.sender].totalPassiveGain+=transAmount;
            userGains[msg.sender].netTotalUserWithdrawable_ += transAmount;
            userGains[msg.sender].expReturn-=transAmount;
        }
        
        userGains[msg.sender].returnShare=returnTotalFundCollection;

        return true;

    }




}