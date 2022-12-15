/**
 *Submitted for verification at BscScan.com on 2022-12-14
*/

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/utils/Counters.sol


// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
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

// File: land.sol


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
    address public owner;
    uint public ApyDeposite;
    uint public Price;
    address public USDTAddress;
    address public BetaUSDTToken;
    address public wrapBetaUSDTTokenAddress;
    uint public penalty_fee_for_fd;
    uint public penality_fee_for_RD;
    uint public fee;
    uint public RDPenalty_fee;
    using Counters for Counters.Counter;
    Counters.Counter public DepositeId;
    Counters.Counter public LockId;
    Counters.Counter public WithdrawId;
   Counters.Counter public RDId;
    IBEP20 contractToken;
    IBEP20 NativeContractToken;
    IBEP20 WrapToken;


    mapping(address => User) public UserMaping;
    mapping (address => mapping(uint => Deposite)) public DepositeMap;
    mapping (address => mapping (uint => Lock)) public LockMap;
    mapping (address => mapping(uint => RD)) public RDMap;
    mapping (uint => Withdraw) public WithdrawMap;
    mapping(address => address[]) public userDownline;
   //mapping(address => address[]) public userDownline2;
    mapping(string => bool) public userNameExist;
    mapping (uint => uint) public ApyLock;
    mapping (uint => uint) public ApyRD;
    mapping(address => uint[]) public DepositeList;
    mapping (address => uint[]) public LockList;
   mapping (address => uint[]) public RDList;
    mapping (address => uint[]) public withdrawLockList;
    mapping (address => uint[]) public withdrawDepositeList;
    mapping (address => uint[]) public withdrawRDList;
    mapping (uint => bool) RDstatus;

    struct User{
       string  name;
       address sponsor_address;
       //address second_level;
       uint time;
       uint withdrawLock;
       uint withdrawDepostie;
       uint withdrawEarning;
       address myAddress;
    }
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
        uint PrincipalAmtCollected;
        uint start_time;
        uint end_time;
        uint APY;
        uint Price;
        uint nextPayment;
        uint totalInstallment;
        uint completedInstallment;
        uint withdraw_time;
        uint earningwithdraw;
        address useraddress;
        uint penaltypaid;
        //bool complete;
    }

 constructor (address _owner, uint _price, address UsdAddress, address _nativeToken, address wraptoken, uint apy){
     owner = _owner;
     ApyDeposite = apy;
     Price = _price;
     string memory Owner;
     User memory users = User ({
         name: Owner,
         sponsor_address: _owner,
        // second_level: _owner,
         time : block.timestamp,
         withdrawLock:0,
         withdrawDepostie:0,
         withdrawEarning:0,
         myAddress: _owner
           });
      UserMaping[_owner] = users;
      USDTAddress = UsdAddress;
      contractToken = IBEP20(UsdAddress);
      BetaUSDTToken = _nativeToken;
      NativeContractToken = IBEP20(_nativeToken);
      wrapBetaUSDTTokenAddress = wraptoken;
      WrapToken = IBEP20(wraptoken);

 }   
 function setDepositeAPY(uint APY) public {
     require (msg.sender == owner,"Not an Owner");
      ApyDeposite = APY;
 }
 function setOwner(address _owner) public {
     require (msg.sender == owner,"Not an Owner");
     owner = _owner;
     string memory Owner;
     User memory users = User ({
         name: Owner,
         sponsor_address: _owner,
         //second_level: _owner,
         time : block.timestamp,
        withdrawLock:0,
         withdrawDepostie:0,
         withdrawEarning:0,
         myAddress: _owner
           });
      UserMaping[_owner] = users;
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
 function registration (string memory _username, address sponsor_address) public{
     require(userNameExist[_username] == false, "Sorry, The Useraddress is already a user");
     require(doesUserExist(sponsor_address) == true, "Sponsor is not a Registered User" );
     require(doesUserExist(msg.sender) == false, "User is a Registered User" );
     //address second_line = UserMaping[sponsor_address].sponsor_address;
     User memory users = User({
         name: _username,
         sponsor_address: sponsor_address,
         //second_level: second_line,
         time : block.timestamp,
         withdrawLock:0,
         withdrawDepostie:0,
         withdrawEarning:0,
         myAddress: msg.sender
           });
      UserMaping[msg.sender] = users;
      userNameExist[_username] = true;
      userDownline[sponsor_address].push(msg.sender);
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
        uint newDepositeId = DepositeId.current();
        contractToken.transferFrom(msg.sender,address(this), _amount);
        Deposite memory deposite = Deposite({
            id:newDepositeId,
            amount: _amount,
            APY:ApyDeposite,
            Price:price,
            complete:false,
            start_time: block.timestamp,
            withdraw_time: 0,
            earningwithdraw:0,
            useraddress:msg.sender
        });
        DepositeMap[msg.sender][newDepositeId]=deposite;
        DepositeList[msg.sender].push(newDepositeId);
        WrapToken.transfer(msg.sender, _amount);
    }
    function geDepositeId(address _address) public view returns(uint [] memory ) {
        return DepositeList[_address];
    }

    function LockItem(uint _month, uint _amount) public {
        LockId.increment();
        uint newLockID = LockId.current();
        contractToken.transferFrom(msg.sender, address(this), _amount);
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
            useraddress: msg.sender
        });
        LockMap[msg.sender][newLockID] = lock;
        LockList[msg.sender].push(newLockID);
        WrapToken.transfer(msg.sender, _amount); 
    }
    function getLockId(address _address) public view returns(uint [] memory ) {
        return LockList[_address];
    }
    function WithdrawLock(uint id) public{
        require(LockMap[msg.sender][id].complete == false,"already complete");
        uint Now = block.timestamp;
        uint end = LockMap[msg.sender][id].end_time;
        uint _amount = LockMap[msg.sender][id].amount;
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

    }
   function WithdrawDeposite(uint id) public {
        require(DepositeMap[msg.sender][id].complete == false,"already complete"); 
        uint rest = 100 - fee;
        uint _amount = DepositeMap[msg.sender][id].amount;
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
        uint newRDID = RDId.current(); 
        contractToken.transferFrom(msg.sender, address(this), _amount);
        uint endtime = (2629746 * _month)+ block.timestamp;
        uint price = Price;
        uint apy = ApyRD[_month];
        RD memory rd = RD({
        id: newRDID,
        amount: _amount,
        PrincipalAmtCollected: _amount,
        start_time: block.timestamp,
        end_time: endtime,
        APY: apy,
        Price: price,
        nextPayment: block.timestamp+2629746,
        totalInstallment: _month,
        completedInstallment: 1,
        withdraw_time: 0,
        earningwithdraw: 0,
        useraddress : msg.sender,
        penaltypaid: 0
        //complete : false
        });
        RDMap[msg.sender][newRDID] = rd;
        RDList[msg.sender].push(newRDID);
        RDstatus[newRDID] = false;
        WrapToken.transfer(msg.sender, _amount);

    }

    function payRD(uint id) public {
      require(RDstatus[id] == false,"already complete");  
      uint dueDate = RDMap[msg.sender][id].nextPayment;
      uint _amount = RDMap[msg.sender][id].amount;
      uint inst = RDMap[msg.sender][id].completedInstallment +1;
      uint penaltyFee = (RDPenalty_fee* _amount)/100;
      uint RdpenFE = _amount+penaltyFee;
      uint Now = block.timestamp;
      if (dueDate <= Now){
        contractToken.transferFrom(msg.sender, address(this), _amount);
        RDMap[msg.sender][id].completedInstallment = inst;
        RDMap[msg.sender][id].nextPayment = 2629746 + dueDate;
        RDMap[msg.sender][id].PrincipalAmtCollected = inst* _amount;
      } else {
        contractToken.transferFrom(msg.sender, address(this), RdpenFE);
        RDMap[msg.sender][id].completedInstallment = inst;
        RDMap[msg.sender][id].nextPayment = 2629746 + dueDate;
        RDMap[msg.sender][id].PrincipalAmtCollected = inst* _amount;
        RDMap[msg.sender][id].penaltypaid +=penaltyFee;
      }
      WrapToken.transfer(msg.sender, _amount);
    }
    function getRDIdEarning(uint id, address user) public view returns (uint amt1){
        uint start = RDMap[user][id].start_time;
        uint end = RDMap[user][id].end_time;
        uint amount = RDMap[user][id].PrincipalAmtCollected;
        uint nowt = block.timestamp;
        uint apy = RDMap[user][id].APY;
        uint withdrawTime = RDMap[user][id].withdraw_time;
        uint withdra = RDMap[user][id].earningwithdraw;
         if (RDstatus[id] == false){
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
        require (nowt < RDMap[msg.sender][id].nextPayment,"Pay the due amount");
        uint amt = getRDIdEarning(id, msg.sender);
        uint amtSponr = (10*amt)/100;
        //uint amt2level = (5*amt)/100;
        uint sendamt = (90*amt)/100;
        address sponr = UserMaping[msg.sender].sponsor_address;
       // address seclevel = UserMaping[msg.sender].second_level;
        NativeContractToken.transfer(sponr,amtSponr);
        //NativeContractToken.transfer(seclevel,amt2level);
        NativeContractToken.transfer(msg.sender,sendamt);
        RDMap[msg.sender][id].earningwithdraw += amt;
        UserMaping[msg.sender].withdrawEarning += amt;
    }
    function withdrawRD (uint id) public {
        require(RDstatus[id] == false,"already complete");  
        uint Now = block.timestamp;
        uint end = RDMap[msg.sender][id].end_time;
        uint _amount = RDMap[msg.sender][id].PrincipalAmtCollected;
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
        RDstatus[id] = true;
        RDMap[msg.sender][id].withdraw_time = block.timestamp;
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

    }


}