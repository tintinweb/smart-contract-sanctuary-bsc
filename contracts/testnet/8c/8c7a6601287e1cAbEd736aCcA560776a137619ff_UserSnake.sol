// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import {IERC20} from './IERC20.sol';
import {SafeMath} from './SafeMath.sol';
import './ReentrancyGuard.sol';

contract UserSnake is ReentrancyGuard {
  using SafeMath for uint256;
  address public operator;
  address public owner;
  uint256 public constant DECIMAL_18 = 10**18;

  struct UserInfo {
        uint256 cowsDeposit;
        uint256 rimDeposit;
        uint256 snakeDeposit;
        uint256 eggDeposit;
        uint256 eggpieceDeposit;
        uint256 lastUpdatedAt;
        uint256 cowsRewardClaimed;
        uint256 rimRewardClaimed;
        uint256 snakeRewardClaimed;
        uint256 eggRewardClaimed;
        uint256 eggpieceRewardClaimed;  
        uint8 status;  // 0 : not active ; 1 active ; 2 is lock ; 2 is ban
  }

  mapping(address => UserInfo) public userInfo;
  mapping(address => address) public referrers;
 
  uint256 public totalUser=0;


  bool public _paused = false;
 
  
  event NewReferral(address indexed user, address indexed ref, uint8 indexed level);
  event UpdateToken(address indexed user, uint256 indexed amount, string wallet);
  event UpdateClaim(address indexed user, uint256 indexed amount, string wallet);
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  event UpdateRefUser(address indexed account, address indexed newRefaccount);

  modifier onlyOwner() {
    require(msg.sender == owner, 'INVALID owner');
    _;
  }

  modifier onlyOperator() {
    require(msg.sender == operator, 'INVALID operator');
    _;
  }

    

  constructor(address _operator) public {
    owner  = tx.origin;
    operator = _operator;
  }

   fallback() external {
    }

    receive() payable external {
        
    }

    function pause() public onlyOwner {
      _paused=true;
    }

    function unpause() public onlyOwner {
      _paused=false;
    }

    
    modifier ifPaused(){
      require(_paused,"");
      _;
    }

    modifier ifNotPaused(){
      require(!_paused,"");
      _;
    }  
  
    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal onlyOwner {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Transfers operator of the contract to a new account (`operator`).
     * Can only be called by the current owner.
     */
    function transferOperator(address _operator) public onlyOwner {
        operator = _operator;
    }


    
  /**
   * @dev 
   */
  function updateRefUser(address account, address newRefAccount) public onlyOwner {
     referrers[account] = newRefAccount;
     emit UpdateRefUser(account, newRefAccount);
  }

  /**
   * @dev Withdraw Token to an address, revert if it fails.
   * @param recipient recipient of the transfer
   */
  function clearToken(address recipient, address token) public onlyOwner {
    IERC20(token).transfer(recipient, IERC20(token).balanceOf(address(this)));
  }

  /**
   * @dev Withdraw  BNB to an address, revert if it fails.
   * @param recipient recipient of the transfer
   */
  function clearBNB(address payable recipient) public onlyOwner {
    _safeTransferBNB(recipient, address(this).balance);
  }

  /**
   * @dev transfer ETH to an address, revert if it fails.
   * @param to recipient of the transfer
   * @param value the amount to send
   */
  function _safeTransferBNB(address to, uint256 value) internal {
    (bool success, ) = to.call{value: value}(new bytes(0));
    require(success, 'BNB_TRANSFER_FAILED');
  }
  
  function updateCowsDeposit(address account, uint256 _cowsDeposit) public onlyOperator  ifNotPaused returns (bool) {
      UserInfo storage _user = userInfo[account];     
      _user.cowsDeposit = _cowsDeposit;
      _user.lastUpdatedAt=block.timestamp;
      emit UpdateToken(account,_cowsDeposit,"COWS");
      return true;
  }

  function updateRimDeposit(address account, uint256 _rimDeposit) public onlyOperator  ifNotPaused returns (bool) {
      UserInfo storage _user = userInfo[account];     
      _user.rimDeposit = _rimDeposit;
      _user.lastUpdatedAt=block.timestamp;
      emit UpdateToken(account,_rimDeposit,"RIM");
      return true;
  }

  function updateSnakeDeposit(address account, uint256 _snakeDeposit) public onlyOperator ifNotPaused returns (bool) {
      UserInfo storage _user = userInfo[account];     
      _user.snakeDeposit = _snakeDeposit;
      _user.lastUpdatedAt=block.timestamp;
      emit UpdateToken(account,_snakeDeposit,"SNAKE");
      return true;
  }

  function updateEggDeposit(address account, uint256 _eggDeposit) public onlyOperator ifNotPaused returns (bool) {
      UserInfo storage _user = userInfo[account];     
      _user.eggDeposit = _eggDeposit;
      _user.lastUpdatedAt=block.timestamp;
      emit UpdateToken(account,_eggDeposit,"EGG");
      return true;
  }

  function updateEggpieceDeposit(address account, uint256 _eggpieceDeposit) public onlyOperator ifNotPaused returns (bool) {
      UserInfo storage _user = userInfo[account];     
      _user.eggpieceDeposit = _eggpieceDeposit;
      _user.lastUpdatedAt=block.timestamp;
      emit UpdateToken(account,_eggpieceDeposit,"PEICE");
      return true;
  }

  function updateCowsRewardClaimed(address account, uint256 _cowsRewardClaimed) public onlyOperator ifNotPaused returns (bool) {
      UserInfo storage _user = userInfo[account];     
      _user.cowsRewardClaimed = _cowsRewardClaimed;
      _user.lastUpdatedAt=block.timestamp;
      emit UpdateClaim(account,_cowsRewardClaimed,"COWS");
      return true;
  }

  function updateRimRewardClaimed(address account, uint256 _rimRewardClaimed) public onlyOperator ifNotPaused returns (bool) {
      UserInfo storage _user = userInfo[account];     
      _user.rimRewardClaimed = _rimRewardClaimed;
      _user.lastUpdatedAt=block.timestamp;
      emit UpdateClaim(account,_rimRewardClaimed,"RIM");
      return true;
  }

  function updateSnakeRewardClaimed(address account, uint256 _snakeRewardClaimed) public onlyOperator ifNotPaused returns (bool) {
      UserInfo storage _user = userInfo[account];     
      _user.snakeRewardClaimed = _snakeRewardClaimed;
      _user.lastUpdatedAt=block.timestamp;
      emit UpdateClaim(account,_snakeRewardClaimed,"SNAKE");
      return true;
  }

  function updateEggRewardClaimed(address account, uint256 _eggRewardClaimed) public onlyOperator ifNotPaused returns (bool) {
      UserInfo storage _user = userInfo[account];     
      _user.eggRewardClaimed = _eggRewardClaimed;
      _user.lastUpdatedAt=block.timestamp;
      emit UpdateClaim(account,_eggRewardClaimed,"EGG");
      return true;
  }
  
  function updateEggpieceRewardClaimed(address account, uint256 _eggpieceRewardClaimed) public onlyOperator ifNotPaused returns (bool) {
      UserInfo storage _user = userInfo[account];     
      _user.eggpieceRewardClaimed = _eggpieceRewardClaimed;
      _user.lastUpdatedAt=block.timestamp;
      emit UpdateClaim(account,_eggpieceRewardClaimed,"PEICE");
      return true;
  }

  function updateUserStatus(address account, uint8 _status) public onlyOperator ifNotPaused returns (bool) {
      
      UserInfo storage _user = userInfo[account];   
      if(isRegister(account)==false)  
      {
        return false;
      }
      if(_status !=1 && _status != 2 && _status != 3)  
      {
        return false;
      }
      _user.status = _status;
      _user.lastUpdatedAt=block.timestamp;
      return true;
  }
  

  function getUserInfo (address account) public view returns(
        uint256 cowsDeposit,
        uint256 rimDeposit,
        uint256 snakeDeposit,
        uint256 eggDeposit,
        uint256 eggpieceDeposit,
        uint256 lastUpdatedAt,
        uint256 cowsRewardClaimed,
        uint256 rimRewardClaimed,
        uint256 snakeRewardClaimed,
        uint256 eggRewardClaimed,
        uint256 eggpieceRewardClaimed      
        ) {

        UserInfo storage _user = userInfo[account];      
        return (
            _user.cowsDeposit,
            _user.rimDeposit, 
            _user.snakeDeposit,
            _user.eggDeposit,
            _user.eggpieceDeposit,
            _user.lastUpdatedAt,
            _user.cowsRewardClaimed,
            _user.rimRewardClaimed,
            _user.snakeRewardClaimed,
            _user.eggRewardClaimed,
            _user.eggpieceRewardClaimed);
  }

 

  function getReff(address account) public view returns (address){
        return referrers[account];
  }

  function isRegister(address account) public view returns (bool){
        if(userInfo[account].status > 0)
            return true;
        else
            return false;
  }

  /**
   * @dev Register
  */
   
   function Register(address _referrer) public ifNotPaused returns (bool) {
        // solhint-disable-next-line not-rely-on-time
        require(isRegister(msg.sender) == false  , "Sorry: your address was registed");
        address recipient = msg.sender;
        if (referrers[msg.sender] == address(0)
            && _referrer != address(0)
            && msg.sender != _referrer
            && msg.sender != referrers[_referrer]) {
            referrers[msg.sender] = _referrer;
            emit NewReferral(_referrer, msg.sender, 1);
            if (referrers[_referrer] != address(0)) {
                emit NewReferral(referrers[_referrer], msg.sender, 2);
            }
        }
        userInfo[recipient].status = 1;
        userInfo[recipient].lastUpdatedAt = block.timestamp;
        return true;    
   }
}