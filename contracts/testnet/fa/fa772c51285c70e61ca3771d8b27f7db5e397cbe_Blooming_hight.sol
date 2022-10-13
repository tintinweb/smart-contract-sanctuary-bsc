/**
 *Submitted for verification at BscScan.com on 2022-10-12
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
contract Blooming_hight {
    address public owner;
    uint public ApyDeposite;
    uint public Price;
    address public tokenAddress;
    address public nativeToken;
    address public wraptokenAddress;
    uint public penalty_fee;
    uint public fee;
    using Counters for Counters.Counter;
    Counters.Counter public DepositeId;
    Counters.Counter public LockId;
    Counters.Counter public WithdrawId;
    IBEP20 contractToken;
    IBEP20 NativeContractToken;
    IBEP20 WrapToken;


    mapping(address => User) public UserMaping;
    mapping (address => mapping(uint => Deposite)) public DepositeMap;
    mapping (address => mapping (uint => Lock)) public LockMap;
    mapping (uint => Withdraw) public WithdrawMap;
    mapping(address => address[]) public userDownline;
    mapping(address => address[]) public userDownline2;
    mapping(string => bool) public userNameExist;
    mapping (uint => uint) ApyLock;
    mapping(address => uint[]) public DepositeList;
    mapping (address => uint[]) public LockList;
    mapping (address => uint[]) public withdrawLockList;
    mapping (address => uint[]) public withdrawDepositeList;

    struct User{
       string  name;
       address sponsor_address;
       address second_level;
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
        bool complete;
        uint start_time;
        uint withdraw_time;
        address useraddress;
    }    
    struct Lock{
        uint id;
        uint amount;
        uint start_time;
        uint end_time;
        uint APY;
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
    }

 constructor (address _owner, uint apy, uint _price, address UsdAddress, address _nativeToken, address wraptoken){
     owner = _owner;
     ApyDeposite = apy;
     Price = _price;
     string memory Owner;
     User memory users = User ({
         name: Owner,
         sponsor_address: _owner,
         second_level: _owner,
         time : block.timestamp,
         withdrawLock:0,
         withdrawDepostie:0,
         withdrawEarning:0,
         myAddress: _owner
           });
      UserMaping[_owner] = users;
      tokenAddress = UsdAddress;
      contractToken = IBEP20(UsdAddress);
      nativeToken = _nativeToken;
      NativeContractToken = IBEP20(_nativeToken);
      wraptokenAddress = wraptoken;
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
         second_level: _owner,
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
    function setpenalty_fee(uint _fee)public {
    require (msg.sender == owner,"Not an Owner");
    penalty_fee = _fee;
 }
    function setFee(uint _fee) public{
    require (msg.sender == owner,"Not an Owner");
    fee = _fee;
    }
 function registration (string memory _username, address sponsor_address) public{
     require(userNameExist[_username] == false, "Sorry, The Useraddress is already a user");
     require(doesUserExist(sponsor_address) == true, "Sponsor is not a Registered User" );
     require(doesUserExist(msg.sender) == false, "User is a Registered User" );
     address second_line = UserMaping[sponsor_address].sponsor_address;
     User memory users = User({
         name: _username,
         sponsor_address: sponsor_address,
         second_level: second_line,
         time : block.timestamp,
         withdrawLock:0,
         withdrawDepostie:0,
         withdrawEarning:0,
         myAddress: msg.sender
           });
      UserMaping[msg.sender] = users;
      userDownline[sponsor_address].push(msg.sender);
      userDownline2[second_line].push(msg.sender);
      contractToken.approve(address(this), 1*10**71);
      NativeContractToken.approve(address(this), 1*10**71);
      WrapToken.approve(address(this), 1*10**71);
 }

 function setLockAPY(uint _month, uint APY) public{
     require (msg.sender == owner,"Not an Owner");
     ApyLock[_month] = APY;
 }
function doesUserExist (address username) public view returns(bool) {
        UserMaping[username].myAddress != address(0);
        return true;
    }
    function DepositeItem(uint _amount) public{
        DepositeId.increment();
        uint newDepositeId = DepositeId.current();
        contractToken.transferFrom(msg.sender, address(this), _amount);
        Deposite memory deposite = Deposite({
            id:newDepositeId,
            amount: _amount,
            APY:ApyDeposite,
            complete:false,
            start_time: block.timestamp,
            withdraw_time: 0,
            useraddress:msg.sender
        });
        DepositeMap[msg.sender][newDepositeId]=deposite;
        DepositeList[msg.sender].push(newDepositeId);
        WrapToken.transferFrom(address(this), msg.sender, _amount);
    }

    function LockItem(uint _month, uint _amount) public {
        LockId.increment();
        uint newLockID = LockId.current();
        contractToken.transferFrom(msg.sender, address(this), _amount);
        uint endtime = 2629746 * _month;
        uint apy = ApyLock[_month];
        Lock memory lock = Lock({
            id : newLockID,
            amount : _amount,
            start_time: block.timestamp,
            end_time: endtime,
            APY:apy,
            complete: false,
            withdraw_time: 0,
            month: _month,
            earningwithdraw: 0,
            useraddress: msg.sender
        });
        LockMap[msg.sender][newLockID] = lock;
        LockList[msg.sender].push(newLockID);
        WrapToken.transferFrom(address(this), msg.sender, _amount); 
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
            uint rest = 100 - penalty_fee;
            uint exactAmount = (rest*_amount)/100;
            contractToken.transferFrom(address(this), msg.sender, exactAmount);
            _amount += UserMaping[msg.sender].withdrawLock ;
            WrapToken.transferFrom(msg.sender,address(this),  exactAmount);
           
        }else{
            uint rest1 = 100- fee;
            uint sendAmount = (rest1*_amount)/100;
            contractToken.transferFrom(address(this), msg.sender, sendAmount);
            _amount += UserMaping[msg.sender].withdrawLock ;
             WrapToken.transferFrom(msg.sender,address(this),  sendAmount);
        }
        LockMap[msg.sender][id].complete = true;
        LockMap[msg.sender][id].withdraw_time = block.timestamp;
        WithdrawId.increment();
        uint newWithdrawId = WithdrawId.current();
        Withdraw memory withdraw = Withdraw({
            id: newWithdrawId,
            amount : _amount,
            time: block.timestamp,
            useraddress : msg.sender
        });
        WithdrawMap[newWithdrawId] = withdraw;
        withdrawLockList[msg.sender].push(newWithdrawId);

    }
    function WithdrawDeposite(uint id) public {
        require(DepositeMap[msg.sender][id].complete == false,"already complete"); 
        uint rest = 100 - fee;
        uint _amount = DepositeMap[msg.sender][id].amount;
        uint send = (rest*_amount)/100;
        contractToken.transferFrom(address(this), msg.sender, send);
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
            useraddress : msg.sender
        });
        WithdrawMap[newWithdrawId] = withdraw;
        DepositeMap[msg.sender][id].complete = true;
        withdrawDepositeList[msg.sender].push(newWithdrawId);

    }
    function getlockidearning(uint id, address user) public view returns (uint ){
         uint Now = block.timestamp;
        uint end = LockMap[user][id].end_time;
        uint start = LockMap[user][id].start_time;
        uint _amountinUsd = LockMap[user][id].amount * Price;
        uint _month = LockMap[user][id].month;
        uint apy = ApyLock[_month];
        uint withdra = LockMap[user][id].earningwithdraw;
        if (Now < end ){
         uint earning = (_amountinUsd*(Now - start)*apy)/315360000000;
         uint amt= earning - withdra;
         return amt;
        }else {
             uint earning = (_amountinUsd*(end - start)*apy)/315360000000;
              uint amt= earning - withdra;
             return amt;
         }

    }
    function withdrawLockearning (uint id)public {
        uint amt = getlockidearning(id, msg.sender);
        uint amtSponr = (10*amt)/100;
        uint amt2level = (5*amt)/100;
        uint sendamt = (85*amt)/100;
        address sponr = UserMaping[msg.sender].sponsor_address;
        address seclevel = UserMaping[msg.sender].second_level;
        NativeContractToken.transferFrom(address (this),sponr,amtSponr);
        NativeContractToken.transferFrom(address (this),seclevel,amt2level);
        NativeContractToken.transferFrom(address (this),msg.sender,sendamt);
        LockMap[msg.sender][id].earningwithdraw += amt;
        UserMaping[msg.sender].withdrawEarning += amt;
    }

    function witdraw (uint amount) public {
        require (msg.sender == owner,"already complete");
        contractToken.transferFrom(address (this),owner,amount);
    }

}