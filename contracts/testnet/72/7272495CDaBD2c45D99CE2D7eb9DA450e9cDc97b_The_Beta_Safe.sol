/**
 *Submitted for verification at BscScan.com on 2023-02-10
*/

// SPDX-License-Identifier: MIT


pragma solidity ^0.8.0;



library Counters {
    struct Counter {
        uint256 _value; 
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}




pragma solidity ^0.8.0;

interface IBEP20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}
contract The_Beta_Safe {

    address owner;
    uint  ApyDeposite;
    uint Price;
    //address  USDTAddress;
    //address  BetaUSDTToken;
    //address  wrapBetaUSDTTokenAddress;
    uint penalty_fee_for_fd;
    uint penality_fee_for_RD;
    uint  fee;
    uint RDPenalty_fee;
    uint level1;
    uint level2;
    uint level3;
    using Counters for Counters.Counter;
    Counters.Counter private  DepositeId;
    Counters.Counter private LockId;
    Counters.Counter private  WithdrawId;
    Counters.Counter private RDId;
    IBEP20 contractToken;
    IBEP20 NativeContractToken;
    IBEP20 WrapToken;


    mapping(address => User) UserMaping;
  //  mapping (address => ExtendUser) public UserMapping2;
    mapping (address => mapping(uint => Deposite))  DepositeMap;
    mapping (address => mapping (uint => Lock)) LockMap;
    mapping (address => mapping(uint => RD))  RDMap;
    mapping (address => mapping(uint => ExtendedStructRD)) public  RDMap2;
    mapping (uint => Withdraw) public WithdrawMap;
    mapping(address => address[])  userDownline;
    mapping(address => address[])  userDownline2;
    mapping(address => address[]) userDownline3;
    mapping(string => bool) public userNameExist;
    mapping (uint => uint) public ApyLock;
    mapping (uint => uint) public ApyRD;
    //mapping(address => uint[]) DepositeList;
   // mapping (address => uint[]) LockList;
  //  mapping (address => uint[])  RDList;
    mapping (address => uint[]) public withdrawLockList;
    mapping (address => uint[]) public withdrawDepositeList;
    mapping (address => uint[]) public withdrawRDList;
   // mapping (uint => bool)  RDstatus;
    mapping (address => uint)  earningFromLevel1;
    mapping (address => uint) earningFromLevel2;
    mapping (address => uint)  earningFromLevel3;
    mapping (address => uint) earningtoLevel1;
    mapping (address => uint) earningtoLevel2;
    mapping (address => uint) earningtoLevel3;
    mapping (address =>uint) fddeposite;
    mapping (address =>uint) Totaldeposite;
    mapping (address =>uint) RDdeposite;
  //  mapping (uint => uint) public depositeamt;
   // mapping (uint => uint) public FDamt;
   // mapping (uint => uint) public RDamt;
    mapping (address => uint)  totalWithdraw;

    struct User{
       string  name;
       address sponsor_address;
       address second_level;
       address third_level;
       uint time;
       uint withdrawLock;
       uint withdrawDepostie;
       uint withdrawRD;
       uint withdrawEarning;
       address myAddress;
       uint numberofinvest;
    }
   /* struct ExtendUser{
        User base;
        uint toearninglevl1;
       uint toearninglevl2;
       uint toearninglevl3;
       uint fromearningLevel1;
       uint fromearningLevel2;
       uint fromearningLevel3;
       uint totalearning;
       uint fddeposite;
       uint Totaldeposite;
       uint RDdeposite;
       uint totalWithdraw;
    }*/
   struct Deposite{
        uint id;
        uint amount;
        uint APY;
        uint Price;
        bool complete;
        uint start_time;
        uint withdraw_time;
        uint earningwithdraw;
        address useraddress;
        uint amt;
        //uint earning;
    }  
    struct Lock{
        uint id;
        uint amount;
        uint start_time;
        uint end_time;
        uint APY;
        uint Price;
        bool complete;
        uint withdraw_time;
        uint month;
        uint earningwithdraw;
        address useraddress;
       // uint earning;
        uint amt;
        
    }
    struct Withdraw{
        uint id;
        uint amount;
        uint time;
        address useraddress;
        uint Type;
    }
    struct RD{
        uint id;
        uint amount;
       // uint PrincipalAmtCollected;//
        uint start_time;
        //uint amt;
        uint end_time;
        uint APY;
        uint Price;
       // uint nextPayment;//
        uint totalInstallment;
       // uint completedInstallment;//
       // uint withdraw_time;//
        //uint earningwithdraw;//
        address useraddress;
        //uint penaltypaid;//
        //bool complete;
    }
    struct ExtendedStructRD{
        RD base;
        uint PrincipalAmtCollected;//
        uint nextPayment;//
        uint completedInstallment;//
        uint withdraw_time;//
        uint earningwithdraw;//
        uint penaltypaid;//
        uint id;
        bool complete;
       // uint earning;
        uint amt;
        address useraddress;

    }

 constructor (address _owner, uint _price, address UsdAddress, address _nativeToken, address wraptoken, uint apy, uint _level1,uint _level2,uint _level3){
     owner = _owner;
     ApyDeposite = apy;
     Price = _price;
     string memory Owner;
     UserMaping[_owner] = User (
         Owner,
         _owner,
          _owner,
         _owner,
         block.timestamp,
         0,
         0,
         0,
         0,
         _owner,
        0
        );
       /* UserMapping2[_owner] = ExtendUser(
         UserMaping[_owner] ,
         earningtoLevel1[_owner],
         earningtoLevel2[_owner],
         earningtoLevel3[_owner],
         earningFromLevel1[_owner],
         earningFromLevel2[_owner],
         earningFromLevel3[_owner],
         earningFromLevel1[_owner]+earningFromLevel2[_owner]+earningFromLevel3[_owner],
         fddeposite[_owner],
         Totaldeposite[_owner],
         RDdeposite[_owner],
         totalWithdraw[_owner]
           );*/
      //UserMaping[_owner] = users;
      //USDTAddress = UsdAddress;
      contractToken = IBEP20(UsdAddress);
      //BetaUSDTToken = _nativeToken;
      NativeContractToken = IBEP20(_nativeToken);
      //wrapBetaUSDTTokenAddress = wraptoken;
      WrapToken = IBEP20(wraptoken);
      level1 = _level1;
      level2 = _level2;
      level3 = _level3;

 }   
 function setDepositeAPY(uint APY) public {
     require (msg.sender == owner,"Not an Owner");
      ApyDeposite = APY;
 }
 function setOwner(address _owner) public {
     require (msg.sender == owner,"Not an Owner");
     owner = _owner;
     string memory Owner;
     UserMaping[_owner] = User (
         Owner,
         _owner,
          _owner,
         _owner,
         block.timestamp,
         0,
         0,
         0,
         0,
         _owner,
         0
        );
       /* UserMapping2[_owner] = ExtendUser(
         UserMaping[_owner] ,
         earningtoLevel1[_owner],
         earningtoLevel2[_owner],
         earningtoLevel3[_owner],
         earningFromLevel1[_owner],
         earningFromLevel2[_owner],
         earningFromLevel3[_owner],
         earningFromLevel1[_owner]+earningFromLevel2[_owner]+earningFromLevel3[_owner],
         fddeposite[_owner],
         Totaldeposite[_owner],
         RDdeposite[_owner],
         totalWithdraw[_owner]
           );*/
 }
 function setPrice(uint price) public{
     require (msg.sender == owner,"Not an Owner");// 1 = 0.01 usd
     Price = price;
 }
    function setpenalty_fee_for_fd(uint _fee)public {
    require (msg.sender == owner,"Not an Owner");
    penalty_fee_for_fd = _fee;
 }
    function setpenalty_fee_for_RD(uint _fee)public {
    require (msg.sender == owner,"Not an Owner");
    penality_fee_for_RD = _fee;
 }
    function setFee(uint _fee) public{
    require (msg.sender == owner,"Not an Owner");
    fee = _fee;
    }
    function setRDPenalty_fee(uint _fee) public{
         require (msg.sender == owner,"Not an Owner");
        RDPenalty_fee =_fee;
    }
    function setLevel1(uint _level1) public {
        require(msg.sender == owner,"Not an Owner");
        level1 = _level1;
    }
    function setLevel2(uint _level2) public {
        require(msg.sender == owner,"Not an Owner");
        level2 = _level2;
    }
    function setLevel3(uint _level3) public {
        require(msg.sender == owner,"Not an Owner");
        level3 = _level3;
    }
 function registration (string memory _username, address sponsor_address) public{
     require(userNameExist[_username] == false, "Sorry, The Useraddress is already a user");
     require(doesUserExist(sponsor_address) == true, "Sponsor is not a Registered User" );
     require(doesUserExist(msg.sender) == false, "User is a Registered User" );
     address second_line = UserMaping[sponsor_address].sponsor_address;
     address thirl_line = UserMaping[second_line].sponsor_address;
     UserMaping[msg.sender] = User({
         name: _username,
         sponsor_address: sponsor_address,
         second_level: second_line,
         third_level: thirl_line,
         time : block.timestamp,
         withdrawLock:0,
         withdrawDepostie:0,
         withdrawRD:0,
         withdrawEarning:0,
         myAddress: msg.sender,
         numberofinvest:0
           });
       /* UserMapping2[msg.sender] = ExtendUser(
        UserMaping[msg.sender], 
        earningtoLevel1[msg.sender],
         earningtoLevel2[msg.sender],
         earningtoLevel3[msg.sender],
         earningFromLevel1[msg.sender],
         earningFromLevel2[msg.sender],
         earningFromLevel3[msg.sender],
         earningFromLevel1[msg.sender]+earningFromLevel2[msg.sender]+earningFromLevel3[msg.sender],
         fddeposite[msg.sender],
         Totaldeposite[msg.sender],
         RDdeposite[msg.sender],
         totalWithdraw[msg.sender]
        );*/
      //UserMaping[msg.sender] = users;
      userNameExist[_username] = true;
      userDownline[sponsor_address].push(msg.sender);
      userDownline2[second_line].push(msg.sender);
      userDownline3[thirl_line].push(msg.sender);
      
 }

 function setLockAPY(uint _month, uint APY) public{
     require (msg.sender == owner,"Not an Owner");
     ApyLock[_month] = APY;
 }
 function setRDAPY(uint _month, uint APY) public{
     require (msg.sender == owner,"Not an Owner");
     ApyRD[_month] = APY;
     }

function doesUserExist (address username) public view returns(bool) {
        return UserMaping[username].myAddress != address(0);
    }
   function DepositeItem(uint _amount) public{
        DepositeId.increment();
        uint price = Price;
        uint level1amt = (level1*_amount)/100;
        uint level2amt = (level2*_amount)/100;
        uint level3amt = (level3*_amount)/100;
        uint amt = _amount-level1amt-level2amt-level3amt;
        address level1_add = UserMaping[msg.sender].sponsor_address;
        address level2_add = UserMaping[msg.sender].second_level;
        address level3_add = UserMaping[msg.sender].third_level;
        uint newDepositeId = DepositeId.current();
        contractToken.transferFrom(msg.sender,address(this), amt);
        contractToken.transferFrom(msg.sender,level1_add, level1amt);
        contractToken.transferFrom(msg.sender,level2_add, level2amt);
        contractToken.transferFrom(msg.sender,level3_add, level3amt);
        Deposite memory deposite = Deposite({
            id:newDepositeId,
            amount: _amount,
            APY:ApyDeposite,
            Price:price,
            complete:false,
            start_time: block.timestamp,
            withdraw_time: 0,
            earningwithdraw:0,
            useraddress:msg.sender,
            amt: amt
            //earning: getDepositeIdEarning(newDepositeId,msg.sender)
        });
        DepositeMap[msg.sender][newDepositeId]=deposite;
        //DepositeList[msg.sender].push(newDepositeId);
        WrapToken.transfer(msg.sender, amt);
        earningFromLevel1[level1_add] +=level1amt;
        earningFromLevel2[level2_add] +=level2amt;
        earningFromLevel3[level3_add] +=level3amt;
        earningtoLevel1[msg.sender] += level1amt;
        earningtoLevel2[msg.sender] +=level2amt;
        earningtoLevel3[msg.sender] += level3amt;
        Totaldeposite[msg.sender] +=_amount;
       // depositeamt[newDepositeId] = amt;
        UserMaping[msg.sender].numberofinvest +=1;
    }
    /*function geDepositeId(address _address) public view returns(uint [] memory ) {
        return DepositeList[_address];
    }*/

    function LockItem(uint _month, uint _amount) public {
        LockId.increment();
        uint level1amt = (level1*_amount)/100;
        uint level2amt = (level2*_amount)/100;
        uint level3amt = (level3*_amount)/100;
        uint amt = _amount-level1amt-level2amt-level3amt;
        address level1_add = UserMaping[msg.sender].sponsor_address;
        address level2_add = UserMaping[msg.sender].second_level;
        address level3_add = UserMaping[msg.sender].third_level;
        uint newLockID = LockId.current();
        contractToken.transferFrom(msg.sender, address(this), amt);
        contractToken.transferFrom(msg.sender,level1_add, level1amt);
        contractToken.transferFrom(msg.sender,level2_add, level2amt);
        contractToken.transferFrom(msg.sender,level3_add, level3amt);
        uint endtime = (2629746 * _month)+ block.timestamp;
        uint price = Price;
        uint apy = ApyLock[_month];
        Lock memory lock = Lock({
            id : newLockID,
            amount : _amount,
            start_time: block.timestamp,
            end_time: endtime,
            APY:apy,
            Price : price,
            complete: false,
            withdraw_time: 0,
            month: _month,
            earningwithdraw: 0,
            useraddress: msg.sender,
            amt : amt
            //earning : getlockidearning(newLockID,msg.sender)
        });
        LockMap[msg.sender][newLockID] = lock;
        //LockList[msg.sender].push(newLockID);
        WrapToken.transfer(msg.sender, amt); 
        earningFromLevel1[level1_add] +=level1amt;
        earningFromLevel2[level2_add] +=level2amt;
        earningFromLevel3[level3_add] +=level3amt;
        earningtoLevel1[msg.sender] += level1amt;
        earningtoLevel2[msg.sender] +=level2amt;
        earningtoLevel3[msg.sender] += level3amt;
        fddeposite[msg.sender] +=_amount;
       // FDamt[newLockID] = amt;
        UserMaping[msg.sender].numberofinvest +=1;
    }
    /*function getLockId(address _address) public view returns(uint [] memory ) {
        return LockList[_address];
    }*/
    function WithdrawLock(uint id) public{
        require(LockMap[msg.sender][id].complete == false,"already complete");
        uint Now = block.timestamp;
        uint end = LockMap[msg.sender][id].end_time;
        uint _amount = LockMap[msg.sender][id].amt;
        if (Now < end ){
            uint rest = 100 - penalty_fee_for_fd;
            uint exactAmount = (rest*_amount)/100;
            contractToken.transfer(msg.sender, exactAmount);
            UserMaping[msg.sender].withdrawLock += _amount;
            WrapToken.transferFrom(msg.sender,address(this),  _amount);
           
        }else{
            uint rest1 = 100- fee;
            uint sendAmount = (rest1*_amount)/100;
            contractToken.transfer(msg.sender, sendAmount);
            UserMaping[msg.sender].withdrawLock += _amount;
             WrapToken.transferFrom(msg.sender,address(this),  _amount);
        }
        LockMap[msg.sender][id].complete = true;
        LockMap[msg.sender][id].withdraw_time = block.timestamp;
        WithdrawId.increment();
        uint newWithdrawId = WithdrawId.current();
        Withdraw memory withdraw = Withdraw({
            id: newWithdrawId,
            amount : _amount,
            time: block.timestamp,
            useraddress : msg.sender,
            Type:1
        });
        WithdrawMap[newWithdrawId] = withdraw;
        withdrawLockList[msg.sender].push(newWithdrawId);
        totalWithdraw[msg.sender] += _amount;

    }
   function WithdrawDeposite(uint id) public {
        require(DepositeMap[msg.sender][id].complete == false,"already complete"); 
        uint rest = 100 - fee;
        uint _amount = DepositeMap[msg.sender][id].amt;
        uint send = (rest*_amount)/100;
        contractToken.transfer( msg.sender, send);
        WrapToken.transferFrom(msg.sender,address(this),  send);
        _amount += UserMaping[msg.sender].withdrawDepostie ;
        DepositeMap[msg.sender][id].complete = true;
        DepositeMap[msg.sender][id].withdraw_time = block.timestamp;
         WithdrawId.increment();
        uint newWithdrawId = WithdrawId.current();
        Withdraw memory withdraw = Withdraw({
            id: newWithdrawId,
            amount : _amount,
            time: block.timestamp,
            useraddress : msg.sender,
            Type:2
        });
        WithdrawMap[newWithdrawId] = withdraw;
        DepositeMap[msg.sender][id].complete = true;
        withdrawDepositeList[msg.sender].push(newWithdrawId);
        totalWithdraw[msg.sender] += _amount;

    }
    function getlockidearning(uint id, address user) public view returns (uint ){
        uint Now = block.timestamp;
        uint end = LockMap[user][id].end_time;
        uint start = LockMap[user][id].start_time;
        uint with1 = LockMap[user][id].withdraw_time;
        uint _amountinUsd = LockMap[user][id].amount * LockMap[user][id].Price;
        uint apy = LockMap[user][id].APY;
        uint withdra = LockMap[user][id].earningwithdraw;
        if (LockMap[user][id].complete== false){
        if (Now < end ){
         uint earning = (_amountinUsd*(Now - start)*apy)/315360000000;
         uint amt= earning - withdra;
         return amt;
        }else {
             uint earning = (_amountinUsd*(end - start)*apy)/315360000000;
              uint amt= earning - withdra;
             return amt;
         }}else{
             uint earning = (_amountinUsd*(with1 - start)*apy)/315360000000;
              uint amt= earning - withdra;
             return amt;
         }

    }
    function withdrawLockearning (uint id)public {
        uint amt = getlockidearning(id, msg.sender);
        uint amtSponr = (10*amt)/100;
        //uint amt2level = (5*amt)/100;
        uint sendamt = (90*amt)/100;
        address sponr = UserMaping[msg.sender].sponsor_address;
       // address seclevel = UserMaping[msg.sender].second_level;
        NativeContractToken.transfer(sponr,amtSponr);
        //NativeContractToken.transfer(seclevel,amt2level);
        NativeContractToken.transfer(msg.sender,sendamt);
        LockMap[msg.sender][id].earningwithdraw += amt;
        UserMaping[msg.sender].withdrawEarning += amt;
    }

    function witdraw (uint amount) public {
        require (msg.sender == owner,"not an owner");
        contractToken.transfer(owner,amount);
    }
  function getDepositeIdEarning(uint id, address user) public view returns(uint amt){
        uint Now = block.timestamp;
        uint start = DepositeMap[user][id].start_time;
        uint apy = DepositeMap[user][id].APY;
        uint withdra = DepositeMap[user][id].earningwithdraw;
        //uint originalWithda = (90*withdra)/100;
        uint end = DepositeMap[user][id].withdraw_time;
        uint _amountinUsd = DepositeMap[user][id].amount * DepositeMap[user][id].Price;
        if (DepositeMap[user][id].complete == false){
         uint earning = (_amountinUsd*(Now - start)*apy)/315360000000;
         amt= earning - withdra;
         return amt; 
        }else{
            uint earning = (_amountinUsd*(end - start)*apy)/315360000000;
            amt = earning - withdra;
            return amt;
        }
    }
    function withdrawDepsoiteEarning(uint id) public  {
        uint amt = getDepositeIdEarning(id, msg.sender); 
        uint amtSponr = (10 * amt)/100;
        //uint amt2level = (5*amt)/100;
        uint sendamt =  (90*amt)/100; //                                         change
        address sponr = UserMaping[msg.sender].sponsor_address;
        //address seclevel = UserMaping[msg.sender].second_level;
        NativeContractToken.transfer(sponr,amtSponr);
        //NativeContractToken.transfer(seclevel,amt2level);
        NativeContractToken.transfer(msg.sender,sendamt);
        UserMaping[msg.sender].withdrawEarning += amt;
        DepositeMap[msg.sender][id].earningwithdraw += amt;
        //return sendamt;
    }

    function RDItem(uint _month, uint _amount) public {
        RDId.increment();
        uint level1amt = (level1*_amount)/100;
        uint level2amt = (level2*_amount)/100;
        uint level3amt = (level3*_amount)/100;
        uint amt = _amount-level1amt-level2amt-level3amt;
        address level1_add = UserMaping[msg.sender].sponsor_address;
        address level2_add = UserMaping[msg.sender].second_level;
        address level3_add = UserMaping[msg.sender].third_level;
        uint newRDID = RDId.current(); 
        contractToken.transferFrom(msg.sender, address(this), amt);
        contractToken.transferFrom(msg.sender,level1_add, level1amt);
        contractToken.transferFrom(msg.sender,level2_add, level2amt);
        contractToken.transferFrom(msg.sender,level3_add, level3amt);
        uint endtime = (2629746 * _month)+ block.timestamp;
        uint price = Price;
        uint apy = ApyRD[_month];
        RDMap[msg.sender][newRDID] = RD({
        id: newRDID,
        amount: _amount,
        //amt : amt,
        //PrincipalAmtCollected: _amount,
        start_time: block.timestamp,
        end_time: endtime,
        APY: apy,
        Price: price,
        //nextPayment: block.timestamp+2629746,
        totalInstallment: _month,
        //completedInstallment: 1,
       // withdraw_time: 0,
       // earningwithdraw: 0,
        useraddress : msg.sender
       // penaltypaid: 0
        //complete : false
        });
        RDMap2[msg.sender][newRDID]= ExtendedStructRD(
           RDMap[msg.sender][newRDID],
           _amount,
           block.timestamp+2629746,
           1,
           0,
           0,
           0,
           newRDID,
           false,
           //getRDIdEarning(newRDID, msg.sender),
           amt,
           msg.sender
        );
        //RDMap[msg.sender][newRDID] = rd;
       // RDList[msg.sender].push(newRDID);
        //RDstatus[newRDID] = false;
        WrapToken.transfer(msg.sender, amt);
        earningFromLevel1[level1_add] +=level1amt;
        earningFromLevel2[level2_add] +=level2amt;
        earningFromLevel3[level3_add] +=level3amt;
        earningtoLevel1[msg.sender] += level1amt;
        earningtoLevel2[msg.sender] +=level2amt;
        earningtoLevel3[msg.sender] += level3amt;
        RDdeposite[msg.sender] +=_amount;
        //RDamt[newRDID] = amt;
        UserMaping[msg.sender].numberofinvest +=1;
    }

    function payRD(uint id) public {
      require(RDMap2[msg.sender][id].complete == false,"already complete");  
      uint dueDate = RDMap2[msg.sender][id].nextPayment;
      uint _amount = RDMap[msg.sender][id].amount;
      //uint inst = RDMap[msg.sender][id].completedInstallment +1;
      uint level1amt = (level1*_amount)/100;
      uint level2amt = (level2*_amount)/100;
      uint level3amt = (level3*_amount)/100;
      uint amt = _amount-level1amt-level2amt-level3amt;
      uint penaltyFee = (RDPenalty_fee* _amount)/100;
      uint RdpenFE = amt+penaltyFee;
      uint Now = block.timestamp;
      if (Now <= dueDate){
        address level1_add = UserMaping[msg.sender].sponsor_address;
        address level2_add = UserMaping[msg.sender].second_level;
        address level3_add = UserMaping[msg.sender].third_level;
        contractToken.transferFrom(msg.sender, address(this), amt);
        contractToken.transferFrom(msg.sender,level1_add, level1amt);
        contractToken.transferFrom(msg.sender,level2_add, level2amt);
        contractToken.transferFrom(msg.sender,level3_add, level3amt);
        RDMap2[msg.sender][id].completedInstallment = (RDMap2[msg.sender][id].completedInstallment +1);
        RDMap2[msg.sender][id].nextPayment = 2629746 + dueDate;
        RDMap2[msg.sender][id].PrincipalAmtCollected = (RDMap2[msg.sender][id].completedInstallment +1)* _amount;
        earningFromLevel1[level1_add] +=level1amt;
        earningFromLevel2[level2_add] +=level2amt;
        earningFromLevel3[level3_add] +=level3amt;
        earningtoLevel1[msg.sender] += level1amt;
        earningtoLevel2[msg.sender] +=level2amt;
        earningtoLevel3[msg.sender] += level3amt;
        //RDamt[id] += amt;
      } else {
         address level1_add = UserMaping[msg.sender].sponsor_address;
        address level2_add = UserMaping[msg.sender].second_level;
        address level3_add = UserMaping[msg.sender].third_level;
        contractToken.transferFrom(msg.sender, address(this), RdpenFE);
        contractToken.transferFrom(msg.sender,level1_add, level1amt);
        contractToken.transferFrom(msg.sender,level2_add, level2amt);
        contractToken.transferFrom(msg.sender,level3_add, level3amt);
        //contractToken.transferFrom(msg.sender, address(this), RdpenFE);
        RDMap2[msg.sender][id].completedInstallment = (RDMap2[msg.sender][id].completedInstallment +1);
        RDMap2[msg.sender][id].nextPayment = 2629746 + dueDate;
        RDMap2[msg.sender][id].PrincipalAmtCollected = (RDMap2[msg.sender][id].completedInstallment +1)* _amount;
        RDMap2[msg.sender][id].penaltypaid +=penaltyFee;
        earningFromLevel1[level1_add] +=level1amt;
        earningFromLevel2[level2_add] +=level2amt;
        earningFromLevel3[level3_add] +=level3amt;
        earningtoLevel1[msg.sender] += level1amt;
        earningtoLevel2[msg.sender] +=level2amt;
        earningtoLevel3[msg.sender] += level3amt;
        //RDamt[id] += amt;
      }
      WrapToken.transfer(msg.sender, amt);
      RDdeposite[msg.sender] +=_amount;
    }
    function getRDIdEarning(uint id, address user) public view returns (uint amt1){
        uint start = RDMap[user][id].start_time;
        uint end = RDMap[user][id].end_time;
        uint amount = RDMap2[user][id].PrincipalAmtCollected;
        uint nowt = block.timestamp;
        uint apy = RDMap[user][id].APY;
        uint withdrawTime = RDMap2[user][id].withdraw_time;
        uint withdra = RDMap2[user][id].earningwithdraw;
         if (RDMap2[msg.sender][id].complete == false){
        if (nowt < end ){
         uint earning = (amount*(nowt - start)*apy)/315360000000;
         amt1= earning - withdra;
         return amt1;
        }else {
             uint earning = (amount*(end - start)*apy)/315360000000;
              amt1= earning - withdra;
            return amt1;
         }}else{
             uint earning = (amount*(withdrawTime - start)*apy)/315360000000;
               amt1= earning - withdra;
            return amt1;
         }
    }
        function withdrawRDearning (uint id) public {
        uint nowt = block.timestamp;
        require (nowt < RDMap2[msg.sender][id].nextPayment,"Pay the due amount");
        uint amt = getRDIdEarning(id, msg.sender);
        uint amtSponr = (10*amt)/100;
        //uint amt2level = (5*amt)/100;
        uint sendamt = (90*amt)/100;
        address sponr = UserMaping[msg.sender].sponsor_address;
       // address seclevel = UserMaping[msg.sender].second_level;
        NativeContractToken.transfer(sponr,amtSponr);
        //NativeContractToken.transfer(seclevel,amt2level);
        NativeContractToken.transfer(msg.sender,sendamt);
        RDMap2[msg.sender][id].earningwithdraw += amt;
        UserMaping[msg.sender].withdrawEarning += amt;
    }
    function withdrawRD (uint id) public {
        require(RDMap2[msg.sender][id].complete == false,"already complete");  
        uint Now = block.timestamp;
        uint end = RDMap[msg.sender][id].end_time;
        uint _amount = RDMap2[msg.sender][id].amt;
        if (Now < end ){
            uint rest = 100 - penality_fee_for_RD;
            uint exactAmount = (rest*_amount)/100;
            contractToken.transfer(msg.sender, exactAmount);
            UserMaping[msg.sender].withdrawLock += _amount;
            WrapToken.transferFrom(msg.sender,address(this),  _amount);
           
        }else{
            uint rest1 = 100- fee;
            uint sendAmount = (rest1*_amount)/100;
            contractToken.transfer(msg.sender, sendAmount);
            UserMaping[msg.sender].withdrawLock += _amount;
            WrapToken.transferFrom(msg.sender,address(this),  _amount);
        }
        RDMap2[msg.sender][id].complete = true;
        RDMap2[msg.sender][id].withdraw_time = block.timestamp;
        WithdrawId.increment();
        uint newWithdrawId = WithdrawId.current();
        Withdraw memory withdraw = Withdraw({
            id: newWithdrawId,
            amount : _amount,
            time: block.timestamp,
            useraddress : msg.sender,
            Type:3
        });
        WithdrawMap[newWithdrawId] = withdraw;
        withdrawLockList[msg.sender].push(newWithdrawId);
        totalWithdraw[msg.sender] += _amount;
        UserMaping[msg.sender].withdrawRD +=_amount;

    }
    /*function getRDId(address _address) public view returns(uint [] memory ) {
        return RDList[_address];
    }*/
    function getDowline1() public view returns (address [] memory){
        return userDownline[msg.sender];
    }
    /*function getDowline2() public view returns (address [] memory){
        return userDownline2[msg.sender];
    }
    function getDowline3() public view returns (address [] memory){
        return userDownline3[msg.sender];
    }*/
    function listMyDepositeID() public view returns (Deposite [] memory){
        uint depositecountItem = DepositeId.current();
        uint activeTradeCount =0;
        uint current =0;
        for (uint i=0; i< depositecountItem; i++){
            if(DepositeMap[msg.sender][i+1].useraddress == msg.sender){
                activeTradeCount +=1;
        }
    }
     Deposite[] memory items1 = new Deposite[](activeTradeCount);
      for (uint i=0; i< depositecountItem; i++){
             if(DepositeMap[msg.sender][i+1].useraddress == msg.sender){
                uint currentId = DepositeMap[msg.sender][i+1].id;
                Deposite storage currentItem = DepositeMap[msg.sender][currentId];
                items1[current] = currentItem;
                current +=1;
             }
        }
        return items1;

}
function totalDepositeearning () public view returns (uint earning){
    uint depositecountItem = DepositeId.current();
    uint activeTradeCount =0;
     for (uint i=0; i< depositecountItem; i++){
            if(LockMap[msg.sender][i+1].useraddress == msg.sender){
                earning += getDepositeIdEarning(i,msg.sender);
                activeTradeCount +=1;
        }
}
return earning;
}
function listMyFDID() public view returns (Lock [] memory){
        uint LockcountItem = LockId.current();
        uint activeTradeCount =0;
        uint current =0;
        for (uint i=0; i< LockcountItem; i++){
            if(LockMap[msg.sender][i+1].useraddress == msg.sender){
                activeTradeCount +=1;
        }
    }
     Lock[] memory items1 = new Lock[](activeTradeCount);
      for (uint i=0; i< LockcountItem; i++){
             if(LockMap[msg.sender][i+1].useraddress == msg.sender){
                uint currentId = LockMap[msg.sender][i+1].id;
                Lock storage currentItem = LockMap[msg.sender][currentId];
                items1[current] = currentItem;
                current +=1;
             }
        }
        return items1;

}
function totalfdearning () public view returns (uint earning){
    uint LockcountItem = LockId.current();
    uint activeTradeCount =0;
     for (uint i=0; i< LockcountItem; i++){
            if(LockMap[msg.sender][i+1].useraddress == msg.sender){
                earning += getlockidearning(i,msg.sender);
                activeTradeCount +=1;
        }
}
return earning;
}

function listMyRDID(address _address) public view returns (ExtendedStructRD [] memory){
        uint RDcountItem = RDId.current();
        uint activeTradeCount =0;
        uint current =0;
        for (uint i=0; i< RDcountItem; i++){
            if(RDMap2[_address][i+1].useraddress == _address){
                activeTradeCount +=1;
        }
    }
     ExtendedStructRD[] memory items1 = new ExtendedStructRD[](activeTradeCount);
      for (uint i=0; i< RDcountItem; i++){
             if(RDMap2[_address][i+1].useraddress == _address){
                uint currentId = RDMap2[_address][i+1].id;
                ExtendedStructRD storage currentItem = RDMap2[_address][currentId];
                items1[current] = currentItem;
                current +=1;
             }
        }
        return items1;

}
function totalRDearning () public view returns (uint earning){
    uint RDcountItem = RDId.current();
    uint activeTradeCount =0;
     for (uint i=0; i< RDcountItem; i++){
            if(RDMap2[msg.sender][i+1].useraddress == msg.sender){
                earning += getRDIdEarning(i,msg.sender);
                activeTradeCount +=1;
        }
}
return earning;
}

  function getdownline(address _adddress) public view returns (User [] memory,uint [] memory,uint [] memory,uint [] memory){
       uint length1 = userDownline[_adddress].length;
       //uint [] memory Toearninglevl1;
       //uint activeTradeCount =0;
       User[] memory users = new User[](length1);
       uint256[] memory earninglevel1 = new uint256[](length1);
       uint256[] memory earninglevel2 = new uint256[](length1);
       uint256[] memory earninglevel3 = new uint256[](length1);//earningFromLevel1
       for (uint i=0; i< length1; i++){
           users[i] = UserMaping[userDownline[_adddress][i]];
           earninglevel1[i] = earningtoLevel1[userDownline[_adddress][i]];
           earninglevel2[i] = earningtoLevel2[userDownline[_adddress][i]];
           earninglevel3[i] = earningtoLevel2[userDownline[_adddress][i]];
       }
       return (users,earninglevel1,earninglevel2,earninglevel3);
   }
   function getuplineearning (address _address) public view returns (User memory user,uint a, uint b, uint c,uint d){
       user = UserMaping[_address];
       a = earningFromLevel1[_address];
       b= earningFromLevel2[_address];
       c = earningFromLevel2[_address];
       d = a+b+c;
       return (user,a,b,c,d);
   }
   function gettotalamount(address _address) public view returns(uint,uint,uint,uint) {
    uint a = fddeposite[_address];
    uint b = Totaldeposite [_address];
    uint c = RDdeposite[_address];
    uint d = totalWithdraw[_address];
    return (a,b,c,d);
   }

   function geteverything () public view returns (address,uint,uint,uint,uint,uint,uint,uint,uint,uint){
       return (owner,ApyDeposite,Price,penalty_fee_for_fd,penality_fee_for_RD,fee,RDPenalty_fee,level1,level2,level3); 
   }
   

}