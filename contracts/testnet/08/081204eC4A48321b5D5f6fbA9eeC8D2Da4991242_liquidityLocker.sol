pragma solidity 0.8.9;

//SPDX-License-Identifier: MIT Licensed
interface IERC20 {
    
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface IDexPair {
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
}

interface IDexFactory {
    function getPair(address PairA, address PairB) external view returns (address);
}



contract liquidityLocker {

    
    address payable public admin;

    uint256 public nonce = 1;

    bool public isPaused = false;

    //structures
    struct PairLock {
    uint256 lockDate; // the date the Pair was locked
    uint256 claimableamount; // the amount of the Pair that is still locked
    uint256 claimedamount; // the amount of the Pair that has been claimed
    uint256 totalamount; // the initial lock amount
    uint256 unlockDate; // the date the Pair can be withdrawn
    uint256 lockID; // lockID nonce per lockPair
    address owner; // the owner of the Pair
    }
  
    struct UserInfo {
    address [] lockedPairsAddresses; // records all Pairs the user has locked
    mapping(address => uint256[]) lockIDs; // map erc20 address to lock id for that Pair
    mapping(address => mapping(uint256 => PairLock)) locks; // Pair locks
  }

    mapping(address => UserInfo) internal Users;


        modifier onlyadmin(){
        require(msg.sender == admin,"LOCK :: Not an admin");
        _;
        }
        modifier paused(){
        require(!isPaused,"LOCK :: Contract is paused");
        _;
        }
        event LockEvent(address indexed user, uint256 lockID, uint256 amount, uint256 lockDate, uint256 unlockDate);
        event UnlockEvent(address indexed user, uint256 lockID, uint256 amount, uint256 lockDate, uint256 unlockDate);
        event UpdateEvent(address indexed user, uint256 lockID, uint256 amount, uint256 lockDate, uint256 unlockDate);
    constructor(
    ) {
        admin = payable(msg.sender);
    }

    receive() external payable {}

    function lock(address _Pair,address _owner,uint256 _amount,uint256 _unlocktime) public paused() returns(bool){
      require(_Pair != address(0),"LOCK :: Pair address is 0");
      // ensure this pair is a Factory pair by querying the factory
      IDexPair lpair = IDexPair(address(_Pair));
      address factoryPairAddress = IDexFactory(lpair.factory()).getPair(lpair.token0(), lpair.token1());
      require(factoryPairAddress == address(_Pair), 'NOT Pair');
      require(_owner != address(0),"LOCK :: Owner address is 0");
      require(_amount > 0,"LOCK :: Amount is 0");
      require(_unlocktime > block.timestamp,"LOCK :: Unlock time is in the past");
      UserInfo storage user = Users[_owner];
      if(!_checkPairexists(_Pair,_owner)){
        user.lockedPairsAddresses.push(_Pair);
      }
      uint256 lockID = nonce;
      nonce++;

      user.lockIDs[_Pair].push(lockID);
      user.locks[_Pair][lockID] = PairLock({
        lockDate: block.timestamp,
        claimableamount: _amount,
        claimedamount: 0,
        totalamount: _amount,
        unlockDate: _unlocktime,
        lockID: lockID,
        owner: _owner
      });

      IERC20(_Pair).transferFrom(msg.sender, address(this), _amount);

      emit LockEvent(_owner,lockID,_amount,block.timestamp,_unlocktime);
      
      return(true);
    }

    function unlock(address _Pair,uint256 _lockID) public paused() returns(bool){
      require(_Pair != address(0),"UNLOCK :: Pair address is 0");
      require(_lockID > 0,"UNLOCK :: Lock ID is 0");
      address _owner = msg.sender;
      UserInfo storage user = Users[_owner];
      require(_checkPairexists(_Pair,_owner),"UNLOCK :: Pair does not exist");
      require(_checklockIDexists(_Pair,_owner,_lockID),"UNLOCK :: Lock ID does not exist");
      PairLock storage currentlock = user.locks[_Pair][_lockID];
      require(block.timestamp >= currentlock.unlockDate,"UNLOCK :: lock time has not passed");
      require(currentlock.claimableamount > 0,"UNLOCK :: Lock is already unlocked");
      uint256 amount = currentlock.claimableamount;
      currentlock.claimedamount += amount;
      currentlock.claimableamount = 0;
      IERC20(_Pair).transfer( _owner, amount);
      emit UnlockEvent(_owner,_lockID,amount,block.timestamp,currentlock.unlockDate);
      return(true);
    }

    function UpdateLock(address _Pair,uint256 _lockID,uint256 _unlocktime ,uint256 _amount) public paused() returns(bool){
      require(_Pair != address(0),"UpdateLock :: Pair address is 0");
      require(_lockID > 0,"UpdateLock :: Lock ID is 0");
      address _owner = msg.sender;
      UserInfo storage user = Users[_owner];
      require(_checkPairexists(_Pair,_owner),"UpdateLock :: Pair does not exist");
      require(_checklockIDexists(_Pair,_owner,_lockID),"UpdateLock :: Lock ID does not exist");
      PairLock storage currentlock = user.locks[_Pair][_lockID];
      require(_unlocktime >= currentlock.unlockDate,"UpdateLock :: lock time has not passed");
      require(_amount > currentlock.claimableamount,"UpdateLock :: Amount is less than remaining amount");
      IERC20(_Pair).transferFrom(msg.sender, address(this), _amount - currentlock.claimableamount);
      currentlock.unlockDate = _unlocktime;
      currentlock.claimableamount = _amount;
      currentlock.totalamount += _amount;
      emit UpdateEvent(_owner,_lockID,_amount - currentlock.claimableamount,block.timestamp,_unlocktime);
      return(true);
    }

    function _checkPairexists(address _Pair,address _owner) internal view returns(bool){
      require(_Pair != address(0),"LOCK :: Pair address is 0");
      require(_owner != address(0),"LOCK :: Owner address is 0");
      UserInfo storage user = Users[_owner];
      for(uint256 i = 0; i < user.lockedPairsAddresses.length; i++){
        if(user.lockedPairsAddresses[i] == _Pair){
          return(true);
        }
      }
      return(false);
    }

    function _checklockIDexists(address _Pair,address _owner,uint256 _lockID) internal view returns(bool){
      require(_Pair != address(0),"LOCK :: Pair address is 0");
      require(_owner != address(0),"LOCK :: Owner address is 0");
      require(_lockID != 0,"LOCK :: LockID is 0");
      UserInfo storage user = Users[_owner];
      for(uint256 i = 0; i < user.lockIDs[_Pair].length; i++){
        if(user.lockIDs[_Pair][i] == _lockID){
          return(true);
        }
      }
      return(false);
    }

    function _getuserPairs(address _owner) public view returns(address [] memory ){
      require(_owner != address(0),"LOCK :: Owner address is 0");
      UserInfo storage user = Users[_owner];
      return(user.lockedPairsAddresses);
    }

    function _getlockID(address _Pair,address _owner) public view returns(uint256 [] memory){
      require(_Pair != address(0),"LOCK :: Pair address is 0");
      require(_owner != address(0),"LOCK :: Owner address is 0");
      require(_checkPairexists(_Pair,_owner),"LOCK :: Pair does not exist");
      UserInfo storage user = Users[_owner];
      return(user.lockIDs[_Pair]);
    }

    function _getlock(address _Pair,address _owner,uint256 _lockID) public view returns(PairLock memory){
      require(_Pair != address(0),"LOCK :: Pair address is 0");
      require(_owner != address(0),"LOCK :: Owner address is 0");
      require(_checklockIDexists(_Pair,_owner,_lockID),"LOCK :: LockID does not exist");
      require(_checkPairexists(_Pair,_owner),"LOCK :: Pair does not exist");
      UserInfo storage user = Users[_owner];
      return(user.locks[_Pair][_lockID]);
    }

    function pauseContract(bool _pause) public onlyadmin(){
      isPaused = _pause;
    }
    function changeadmin(address _newadmin) public onlyadmin(){
      require(_newadmin != address(0),"CHANGEADMIN :: New admin address is 0 ");
      admin = payable(_newadmin);
    }
    function _checkPair(address _Pair) public view returns(bool){
      require(_Pair != address(0),"CHECKPAIR :: Pair address is 0");
      IDexPair lpair = IDexPair(address(_Pair));
      address factoryPairAddress = IDexFactory(lpair.factory()).getPair(lpair.token0(), lpair.token1());
      if(factoryPairAddress == address(_Pair)){
        return(true);
      }
      return(false);
      }

}