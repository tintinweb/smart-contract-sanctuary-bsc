// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import {IERC20} from './IERC20.sol';
import {IUserCowsBoy} from './IUserCowsBoy.sol';
import {SafeMath} from './SafeMath.sol';
import './ReentrancyGuard.sol';


contract COWS_Staking is ReentrancyGuard {
  using SafeMath for uint256;
  // Todo : Update when deploy to production

  address public operator;
  address public USER_COWSBOY;
  address public BUY_TOKEN;
  
  mapping(address => uint256) public buyerAmount;
  mapping(address => uint256) public claimAmount;
  
  uint256 public totalStaking=0;
  uint256 public totalClaimed=0;
  uint256 public totalUser=0;
  
  uint256 public constant DECIMAL_18 = 10**18;
  uint256 public minimumStaking=1*DECIMAL_18;

  bool public _paused = false;
  bool public allowRelease = false; 
  
  event Staking(address indexed user, uint256 indexed sell_amount);
  event ClaimAt(address indexed user, uint256 indexed claimAmount);
  event AllowRelease(bool indexed allowRelease, bool indexed oldAllowRelease);
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  modifier onlyAdmin() {
    require(msg.sender == operator, 'INVALID ADMIN');
    _;
  }

    

  constructor(address _userCowBoy, address _lockToken) public {
    USER_COWSBOY = _userCowBoy;
    BUY_TOKEN = _lockToken;
    operator  = tx.origin;
  }

    function pause() public onlyAdmin {
      _paused=true;
    }

    function unpause() public onlyAdmin {
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
    function transferOwnership(address newOwner) public onlyAdmin {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal onlyAdmin {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(operator, newOwner);
        operator = newOwner;
    }
  

  /**
   * @dev Withdraw IDO Token to an address, revert if it fails.
   * @param recipient recipient of the transfer
   */
  function withdrawToken(address recipient, address token) public onlyAdmin {
    IERC20(token).transfer(recipient, IERC20(token).balanceOf(address(this)));
  }


  /**
   * @dev Update is enable
   */
  function updateUserContract(address _userCowBoy) public onlyAdmin {
    USER_COWSBOY = _userCowBoy;
  }

  /**
   * @dev Update minimumBuy
   */
  function updateMinBuy(uint256 _minimumStaking) public onlyAdmin {
    minimumStaking = _minimumStaking;
  }

  /**
   * @dev Update _allowRelease
   */
  function updateAllowRelease(bool _allowRelease) public onlyAdmin {
    emit AllowRelease(_allowRelease, allowRelease);
    allowRelease = _allowRelease;
  }

  /**
   * @dev Withdraw IDO BNB to an address, revert if it fails.
   * @param recipient recipient of the transfer
   */
  function withdrawBNB(address recipient) public onlyAdmin {
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

  function getStakingInfo(address account) external view returns (uint256 total)
  {
      return (buyerAmount[account]);
  }
   
   function releaseCOWS() public ifNotPaused returns (uint256) {
       address recipient = msg.sender;
       require(allowRelease == true, "Sorry: the function release will open when the event was end");
       require(buyerAmount[recipient] > 0, "Sorry: no tokens to release");
       require(claimAmount[recipient] == 0, "Sorry: your tokens was release ");
       uint256 claim_amount = buyerAmount[recipient];
       require(IERC20(BUY_TOKEN).balanceOf(address(this)) >= claim_amount, "Sorry: not enough tokens to release");
       IERC20(BUY_TOKEN).transfer(recipient, claim_amount);   
       claimAmount[recipient]=  claim_amount;
       totalClaimed += claim_amount;
       emit ClaimAt(recipient, claim_amount);
       return 1;
   }

  function StakingCOWS(uint256 amount) public ifNotPaused returns (address account, uint256 total) {
      // solhint-disable-next-line not-rely-on-time
      address recipient = msg.sender;
      require(IUserCowsBoy(USER_COWSBOY).isRegister(recipient) == true , "Address not exist registed system");
      uint256 allowance = IERC20(BUY_TOKEN).allowance(msg.sender, address(this));
      require(allowance >= amount, "Check the token allowance");
      require(amount >= minimumStaking, "Check the minium amount");
      IERC20(BUY_TOKEN).transferFrom(recipient, address(this), amount);   
      if(buyerAmount[recipient]==0)
      {
          totalUser += 1;
      } 
      buyerAmount[recipient] += amount;
      totalStaking += amount;
      emit Staking(recipient, amount);
      return (recipient , buyerAmount[recipient]);
  }
}