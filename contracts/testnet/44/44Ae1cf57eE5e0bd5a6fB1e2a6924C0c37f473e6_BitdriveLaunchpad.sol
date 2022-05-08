/**
 *Submitted for verification at BscScan.com on 2022-05-07
*/

pragma solidity >=0.4.0;


library SafeMath {
   
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }
   
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
    }

   
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

   
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
       
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }

   
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, 'SafeMath: modulo by zero');
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

contract Owned {
    address public owner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address payable _newOwner) public onlyOwner {
        owner = _newOwner;
        emit OwnershipTransferred(msg.sender, _newOwner);
    }
}

// File: @bitdriveswap/bitdrive-swap-lib/contracts/token/BEP20/IBEP20.sol

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.4.0;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    
    function approve(address spender, uint256 amount) external returns (bool);

   
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: @bitdriveswap/bitdrive-swap-lib/contracts/utils/Address.sol


pragma solidity ^0.6.2;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
   
    function isContract(address account) internal view returns (bool) {
       
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

   
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, 'Address: insufficient balance');

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
    }

    
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, 'Address: low-level call failed');
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, 'Address: insufficient balance for call');
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), 'Address: call to non-contract');

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// File: @bitdriveswap/bitdrive-swap-lib/contracts/token/BEP20/SafeBEP20.sol


pragma solidity ^0.6.0;

library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

   
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
       
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            'SafeBEP20: approve from non-zero to non-zero allowance'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            'SafeBEP20: decreased allowance below zero'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, 'SafeBEP20: low-level call failed');
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), 'SafeBEP20: BEP20 operation did not succeed');
        }
    }
}

// File: @bitdriveswap/bitdrive-swap-lib/contracts/utils/ReentrancyGuard.sol


pragma solidity ^0.6.0;


contract ReentrancyGuard {
   
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    
    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

// File: @bitdriveswap/bitdrive-swap-lib/contracts/proxy/Initializable.sol


pragma solidity >=0.4.24 <0.7.0;



abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        
        address self = address(this);
        uint256 cs;
        // solhint-disable-next-line no-inline-assembly
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
}

// File: contracts/IFOByProxy.sol

pragma solidity 0.6.12;

contract BitdriveLaunchpad is ReentrancyGuard, Initializable {
  using SafeMath for uint256;
  using SafeBEP20 for IBEP20;

  // Info of each user.
  struct UserInfo {
      uint256 amount;
      uint256 tier;
      uint256 round1withdraw;
      uint256 round2withdraw;
      uint256 round3withdraw;
      uint256 tieramount;
      bool isExits; 
      bool isPublicsale; 
      uint256 round3invest;
      uint256 round3withdrawtime;
  }

  // admin address
  address public adminAddress;
  IBEP20 public lpToken;
  IBEP20 public offeringToken;
  uint256 public startBlock;
  uint256 public endBlock;
  uint256 public offeringAmount;
  uint256 public totalAmount;
  uint256 public balanceAmount;
  uint256 public round3totalAmount;

  mapping (address => UserInfo) public userInfo;
  mapping (uint => uint) public STAKING_PRICE;
  mapping (uint => uint) public POOL_WEIGHT;

  uint256 public currentRound=1;
  uint256 public tokenPrice=0;
  uint256 public instantpercentage=20;

  uint public Bronzeusers;
  uint public Silverusers;
  uint public Goldusers;
  uint public Diamondusers;
  uint public totalparticipant;
  
  uint256 public totalBronzeAmount;
  uint256 public totalSilverAmount;
  uint256 public totalGoldAmount;
  uint256 public totalDiamondAmount;

  uint256 public SilverEligibleUsers;
  uint256 public GoldEligibleUsers;
  uint256 public DiamondEligibleUsers;

  uint256 public round1HarvestAmount;
  uint256 public round2HarvestAmount;
  uint256 public round3HarvestAmount;

  uint256 public Round1Allocate;
  uint256 public Round2Allocate;

  uint public test;
  uint public PERIOD_LENGTH = 60 days;
  uint256 public endTime;
  uint256 public intervalDays;

  event Deposit(address indexed user, uint256 amount);
  event Harvest(address indexed user, uint256 offeringAmount, uint256 excessAmount);

  constructor() public {
  }

  function initialize(
      IBEP20 _lpToken,
      IBEP20 _offeringToken,
      uint256 _offeringAmount,
      address _adminAddress,
      uint256 _tokenPrice,
      uint numberOfdays
  ) public initializer {
      lpToken = _lpToken;
      offeringToken = _offeringToken;
      offeringAmount = _offeringAmount;
      balanceAmount = _offeringAmount;
      Round1Allocate = _offeringAmount;
      tokenPrice=_tokenPrice;
      adminAddress = _adminAddress;
      currentRound = 1;
      intervalDays = numberOfdays.mul(1 days);
      endTime = block.timestamp.add(intervalDays);

      STAKING_PRICE[1]  = 10*1e18;
      STAKING_PRICE[2]  = 100*1e18;
      STAKING_PRICE[3]  = 500*1e18;
      STAKING_PRICE[4]  = 1000*1e18;

      POOL_WEIGHT[1]  = 10;
      POOL_WEIGHT[2]  = 30;
      POOL_WEIGHT[3]  = 60;
  }

  modifier onlyAdmin() {
    require(msg.sender == adminAddress, "admin: wut?");
    _;
  }

  function deposit(uint256 _amount) public {

    require (block.timestamp < endTime, 'not ifo time');
    require (_amount == STAKING_PRICE[1] || _amount == STAKING_PRICE[2] || 
    _amount == STAKING_PRICE[3] || _amount == STAKING_PRICE[4], 'Invalid amount');
    require (userInfo[msg.sender].tier==0, 'already joined');

    uint256 balance = IBEP20(lpToken).balanceOf(msg.sender);
    require (balance >= _amount, 'insufficient balance');

    lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
    
    if(!userInfo[msg.sender].isExits){
        userInfo[msg.sender].isExits=true;
        totalparticipant++;
    }

    userInfo[msg.sender].amount = userInfo[msg.sender].amount.add(_amount);

    if(_amount==STAKING_PRICE[1]){
        userInfo[msg.sender].tier =1;
        Bronzeusers++;
        totalBronzeAmount = totalBronzeAmount.add(_amount);
        userInfo[msg.sender].tieramount = userInfo[msg.sender].tieramount.add(_amount);
    }else if(_amount==STAKING_PRICE[2]){
        userInfo[msg.sender].tier =2;
        Silverusers++;
        totalSilverAmount = totalSilverAmount.add(_amount);
        userInfo[msg.sender].tieramount = userInfo[msg.sender].tieramount.add(_amount);
    }else if(_amount==STAKING_PRICE[3]){
        userInfo[msg.sender].tier =3;
        Goldusers++;
        totalGoldAmount = totalGoldAmount.add(_amount);
        userInfo[msg.sender].tieramount = userInfo[msg.sender].tieramount.add(_amount);
    }else if(_amount==STAKING_PRICE[4]){
        userInfo[msg.sender].tier =4;
        Diamondusers++;
        totalDiamondAmount = totalDiamondAmount.add(_amount);
        userInfo[msg.sender].tieramount = userInfo[msg.sender].tieramount.add(_amount);
    }

    totalAmount = totalAmount.add(_amount);
    emit Deposit(msg.sender, _amount);
  }
  
  function harvestReward(uint256 _amount) public nonReentrant {

    require (block.timestamp > endTime && currentRound==1, 'not harvest time');
    require (_amount>0, 'invalid amount');
    require (balanceAmount>0, 'unable to withdraw');
    
    uint currentTier = userInfo[msg.sender].tier;
    require (currentTier>1, 'not eligible');

    bool isPublicsale = userInfo[msg.sender].isPublicsale;
    uint perAmount = getuserAllocated(msg.sender);
    uint round1withdraw = userInfo[msg.sender].round1withdraw;
    uint available = perAmount.sub(round1withdraw);
    require (available >= _amount, 'insufficient balance');
    userInfo[msg.sender].round1withdraw += _amount;
    
    offeringToken.safeTransfer(address(msg.sender), _amount);

    balanceAmount = balanceAmount.sub(_amount);
    round1HarvestAmount += _amount;

    uint cal = perAmount/2;
    if(cal<=userInfo[msg.sender].round1withdraw && !isPublicsale){
        if(currentTier==2){
            SilverEligibleUsers++;
        }
        if(currentTier==3){
            GoldEligibleUsers++;
        }
        if(currentTier==4){
            DiamondEligibleUsers++;
        }
        userInfo[msg.sender].isPublicsale=true;
    }
    emit Harvest(msg.sender, _amount,tokenPrice);
    
  }

   function getuserAllocated(address _user) public view returns (uint) {
       (uint tieramount2, uint tieramount3,uint tieramount4) = tierAllocation();
       uint currentTier = userInfo[_user].tier;
       uint tieramount=0;
       if(currentTier==2){
            tieramount =(tieramount2>0)?tieramount2/Silverusers:0;
       }else if(currentTier==3){
            tieramount =(tieramount3>0)?tieramount3/Goldusers:0;
       }else if(currentTier==4){
            tieramount =(tieramount4>0)?tieramount4/Diamondusers:0;
       }
       tieramount = tieramount*1e18;
       return tieramount;
    }

    function tierAllocation() public view returns (uint,uint,uint) {

        uint perAmount = tokenAllocated();
        uint tieramount2 =(Silverusers.mul(perAmount).mul(POOL_WEIGHT[1]));
        uint tieramount3 =(Goldusers.mul(perAmount).mul(POOL_WEIGHT[2]));
        uint tieramount4 =(Diamondusers.mul(perAmount).mul(POOL_WEIGHT[3]));

        return (tieramount2,tieramount3,tieramount4);
    }

  function tokenAllocated() public view returns (uint) {
        uint allocate= (
            (Silverusers.mul(POOL_WEIGHT[1])).add(Goldusers.mul(POOL_WEIGHT[2]))
        .add(Diamondusers.mul(POOL_WEIGHT[3])));
        allocate = allocate*1e18;
        uint perUser=0;
        if(allocate>0){
             perUser=(Round1Allocate/allocate);
        }
        perUser = perUser;
        return perUser;
  }

  function tokenAllocatedPublicSale() public view returns (uint) {
        uint totalUsers = Bronzeusers.add(SilverEligibleUsers).add(GoldEligibleUsers).add(DiamondEligibleUsers);
        uint perUser=0;
        if(totalUsers>0){
            perUser=Round2Allocate.div(totalUsers);
        }
        return perUser;
  }

  function harvestPublicReward(uint256 _amount) public nonReentrant {

    require (block.timestamp > endTime && currentRound==2, 'not harvest time');

    require (_amount>0, 'invalid amount');
    require (balanceAmount>0, 'unable to withdraw');
    uint256 perAmount = tokenAllocatedPublicSale();
    uint256 round2withdraw = userInfo[msg.sender].round2withdraw;
    uint256 available = perAmount.sub(round2withdraw);
    require (available >= _amount, 'insufficient balance');

    userInfo[msg.sender].round2withdraw = userInfo[msg.sender].round2withdraw.add(_amount);
    offeringToken.safeTransfer(address(msg.sender), _amount);

    balanceAmount = balanceAmount.sub(_amount);
    round2HarvestAmount += _amount;
    emit Harvest(msg.sender, _amount,tokenPrice);
  }

  function round3Deposit(uint256 _amount) public {

    require (block.timestamp < endTime && currentRound==3, 'not harvest time');
    require (_amount<=balanceAmount, 'invalid invest amount');
    require (_amount > 0, 'need _amount > 0');
    require (userInfo[msg.sender].round3invest == 0, 'already joined');
    lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);

    uint cal = _amount.mul(instantpercentage).div(100);
    
    offeringToken.safeTransfer(address(msg.sender), cal);

    if(!userInfo[msg.sender].isExits){
        userInfo[msg.sender].isExits=true;
        totalparticipant++;
    }
    userInfo[msg.sender].round3invest = userInfo[msg.sender].round3invest.add(_amount);
    userInfo[msg.sender].round3withdraw = userInfo[msg.sender].round3withdraw.add(cal);
    userInfo[msg.sender].round3withdrawtime = block.timestamp;

    totalAmount = totalAmount.add(_amount);
    round3totalAmount = round3totalAmount.add(_amount);
    round3HarvestAmount += cal;
    balanceAmount = balanceAmount.sub(_amount);
    emit Deposit(msg.sender, _amount);
  }

  function round3Harvest() public {
      require (block.timestamp > endTime && currentRound==3, 'not harvest time');
      uint diff = block.timestamp - userInfo[msg.sender].round3withdrawtime;
      test =diff;
      uint available= availableMcar(msg.sender);
      require (available>0, 'insufficient reward');
      userInfo[msg.sender].round3withdraw = userInfo[msg.sender].round3withdraw.add(available);
      userInfo[msg.sender].round3withdrawtime = block.timestamp;
      offeringToken.safeTransfer(address(msg.sender), available);

      balanceAmount = balanceAmount.sub(available);
      round3HarvestAmount += available;

      emit Harvest(msg.sender, available,tokenPrice);
  }

  function availableMcar(address _user) public view returns (uint256) {
      uint diff = 0;
      if(userInfo[_user].round3withdrawtime>block.timestamp){
        diff = userInfo[_user].round3withdrawtime-block.timestamp;
      }
      uint invest = userInfo[_user].round3invest;
      uint withdraw = userInfo[_user].round3withdraw;
      uint balance = invest-withdraw;
      
      uint256 available = 0;
      if( block.timestamp < userInfo[_user].round3withdrawtime && diff > PERIOD_LENGTH && balance >0 ){
            uint calcMcar = diff / PERIOD_LENGTH;
            if(calcMcar >= 4){
                available = balance;
            }else{
                available = uint256(calcMcar) * invest.mul(instantpercentage)/100;
            }
      }else{
          available = 0;
      }
      available = available;
      return available;
  }

  function changeStakingPrice(uint256 level, uint256 amount) public onlyAdmin {
      STAKING_PRICE[level] = amount;
  }

  function changePoolWeight(uint256 level, uint256 weight) public onlyAdmin {
      POOL_WEIGHT[level] = weight;
  }
  function changePrice(uint256 _price) public onlyAdmin {
      tokenPrice = _price;
  }
  function changePercentage(uint256 _percentage) public onlyAdmin {
      instantpercentage = _percentage;
  }
  
  function startRound(uint256 round,uint numberOfdays) public onlyAdmin {
      currentRound = round;
      intervalDays = numberOfdays.mul(1 days);
      endTime = block.timestamp.add(intervalDays);
      if(round==2){
         Round2Allocate = balanceAmount;
      }
  }

  function closeRoundTest() public onlyAdmin {
      endTime = block.timestamp;
  }

   function withdrawtimeTest(address _user,uint numberOfdays) public onlyAdmin {
     uint Days = numberOfdays.mul(1 days);
      uint changeTime = block.timestamp.add(Days);
      userInfo[_user].round3withdrawtime = changeTime;
  }

  function finalWithdrawInvest(uint256 _lpAmount) public onlyAdmin {
    require(_lpAmount < lpToken.balanceOf(address(this)), 'not enough token 0');
    lpToken.safeTransfer(address(msg.sender), _lpAmount);
  }
  function finalWithdrawReward(uint256 _offerAmount) public onlyAdmin {
    require (_offerAmount < offeringToken.balanceOf(address(this)), 'not enough token 1');
    offeringToken.safeTransfer(address(msg.sender), _offerAmount);
  }

}

contract BitdrivePresale is Owned {
    mapping(address => address) public _presale;
    function createPresale(address _tokenAddress) public onlyOwner {
        _presale[_tokenAddress] = address(new BitdriveLaunchpad());
    }
    function getPresale(address _token) public view returns (address){
        return _presale[_token];
    }
}