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



contract locker {

    
    address payable public admin;

    uint256 public nonce = 1;

    bool public isPaused = false;

    //structures
    struct tokenLock {
    uint256 lockDate; // the date the token was locked
    uint256 claimableamount; // the amount of the token that is still locked
    uint256 claimedamount; // the amount of the token that has been claimed
    uint256 totalamount; // the initial lock amount
    uint256 unlockDate; // the date the token can be withdrawn
    uint256 lockID; // lockID nonce per locktoken
    address owner; // the owner of the token
    }
  
    struct UserInfo {
    address [] lockedtokensAddresses; // records all tokens the user has locked
    mapping(address => uint256[]) lockIDs; // map erc20 address to lock id for that token
    mapping(address => mapping(uint256 => tokenLock)) locks; // token locks
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

    function lock(address _token,address _owner,uint256 _amount,uint256 _unlocktime) public paused() returns(bool){
      require(_token != address(0),"LOCK :: token address is 0");
      require(_owner != address(0),"LOCK :: Owner address is 0");
      require(_amount > 0,"LOCK :: Amount is 0");
      require(_unlocktime > block.timestamp,"LOCK :: Unlock time is in the past");
      UserInfo storage user = Users[_owner];
      if(!_checktokenexists(_token,_owner)){
        user.lockedtokensAddresses.push(_token);
      }
      uint256 lockID = nonce;
      nonce++;

      user.lockIDs[_token].push(lockID);
      user.locks[_token][lockID] = tokenLock({
        lockDate: block.timestamp,
        claimableamount: _amount,
        claimedamount: 0,
        totalamount: _amount,
        unlockDate: _unlocktime,
        lockID: lockID,
        owner: _owner
      });

      IERC20(_token).transferFrom(msg.sender, address(this), _amount);

      emit LockEvent(_owner,lockID,_amount,block.timestamp,_unlocktime);
      
      return(true);
    }

    function unlock(address _token,uint256 _lockID) public paused() returns(bool){
      require(_token != address(0),"UNLOCK :: token address is 0");
      require(_lockID > 0,"UNLOCK :: Lock ID is 0");
      address _owner = msg.sender;
      UserInfo storage user = Users[_owner];
      require(_checktokenexists(_token,_owner),"UNLOCK :: token does not exist");
      require(_checklockIDexists(_token,_owner,_lockID),"UNLOCK :: Lock ID does not exist");
      tokenLock storage currentlock = user.locks[_token][_lockID];
      require(block.timestamp >= currentlock.unlockDate,"UNLOCK :: lock time has not passed");
      require(currentlock.claimableamount > 0,"UNLOCK :: Lock is already unlocked");
      uint256 amount = currentlock.claimableamount;
      currentlock.claimedamount += amount;
      currentlock.claimableamount = 0;
      IERC20(_token).transfer( _owner, amount);
      emit UnlockEvent(_owner,_lockID,amount,block.timestamp,currentlock.unlockDate);
      return(true);
    }

    function UpdateLock(address _token,uint256 _lockID,uint256 _unlocktime ,uint256 _amount) public paused() returns(bool){
      require(_token != address(0),"UpdateLock :: token address is 0");
      require(_lockID > 0,"UpdateLock :: Lock ID is 0");
      address _owner = msg.sender;
      UserInfo storage user = Users[_owner];
      require(_checktokenexists(_token,_owner),"UpdateLock :: token does not exist");
      require(_checklockIDexists(_token,_owner,_lockID),"UpdateLock :: Lock ID does not exist");
      tokenLock storage currentlock = user.locks[_token][_lockID];
      require(_unlocktime >= currentlock.unlockDate,"UpdateLock :: lock time has not passed");
      require(_amount > currentlock.claimableamount,"UpdateLock :: Amount is less than remaining amount");
      IERC20(_token).transferFrom(msg.sender, address(this), _amount - currentlock.claimableamount);
      currentlock.unlockDate = _unlocktime;
      currentlock.claimableamount = _amount;
      currentlock.totalamount += _amount;
      emit UpdateEvent(_owner,_lockID,_amount - currentlock.claimableamount,block.timestamp,_unlocktime);
      return(true);
    }

    function _checktokenexists(address _token,address _owner) internal view returns(bool){
      require(_token != address(0),"LOCK :: token address is 0");
      require(_owner != address(0),"LOCK :: Owner address is 0");
      UserInfo storage user = Users[_owner];
      for(uint256 i = 0; i < user.lockedtokensAddresses.length; i++){
        if(user.lockedtokensAddresses[i] == _token){
          return(true);
        }
      }
      return(false);
    }

    function _checklockIDexists(address _token,address _owner,uint256 _lockID) internal view returns(bool){
      require(_token != address(0),"LOCK :: token address is 0");
      require(_owner != address(0),"LOCK :: Owner address is 0");
      require(_lockID != 0,"LOCK :: LockID is 0");
      UserInfo storage user = Users[_owner];
      for(uint256 i = 0; i < user.lockIDs[_token].length; i++){
        if(user.lockIDs[_token][i] == _lockID){
          return(true);
        }
      }
      return(false);
    }

    function _getusertokens(address _owner) public view returns(address [] memory ){
      require(_owner != address(0),"LOCK :: Owner address is 0");
      UserInfo storage user = Users[_owner];
      return(user.lockedtokensAddresses);
    }

    function _getlockID(address _token,address _owner) public view returns(uint256 [] memory){
      require(_token != address(0),"LOCK :: token address is 0");
      require(_owner != address(0),"LOCK :: Owner address is 0");
      require(_checktokenexists(_token,_owner),"LOCK :: token does not exist");
      UserInfo storage user = Users[_owner];
      return(user.lockIDs[_token]);
    }

    function _getlock(address _token,address _owner,uint256 _lockID) public view returns(tokenLock memory){
      require(_token != address(0),"LOCK :: token address is 0");
      require(_owner != address(0),"LOCK :: Owner address is 0");
      require(_checklockIDexists(_token,_owner,_lockID),"LOCK :: LockID does not exist");
      require(_checktokenexists(_token,_owner),"LOCK :: token does not exist");
      UserInfo storage user = Users[_owner];
      return(user.locks[_token][_lockID]);
    }

    function pauseContract(bool _pause) public onlyadmin(){
      isPaused = _pause;
    }
    function changeadmin(address _newadmin) public onlyadmin(){
      require(_newadmin != address(0),"CHANGEADMIN :: New admin address is 0 ");
      admin = payable(_newadmin);
    }

}