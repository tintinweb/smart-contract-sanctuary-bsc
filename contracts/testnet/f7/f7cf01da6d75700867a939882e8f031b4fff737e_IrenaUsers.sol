/**
 *Submitted for verification at BscScan.com on 2023-02-08
*/

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;
// SPDX-License-Identifier: MIT

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
        require(
            _initializing || !_initialized,
            "Initializable: contract is already initialized"
        );

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
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
 /*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }
    
    function __Context_init_unchained() internal initializer {}

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    uint256[50] private __gap;
}
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    uint256[49] private __gap;
}

library SafeMathUpgradeable {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

  function ceil(uint a, uint m) internal pure returns (uint r) {
    return (a + m - 1) / m * m;
  }
}




interface IBEP20Upgradeable {
     function approve(address to, uint256 tokens) external returns (bool success);
     function decimals() external view returns (uint256);
    function transfer(address to, uint256 tokens) external returns (bool success);
    function burnTokens(uint256 _amount) external;
    function balanceOf(address tokenOwner) external view returns (uint256 balance);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function mint(address _to,uint256 amount) external returns (bool success);
    function transferOwnership(address _newOwner) external returns (bool success);
}


contract IrenaUsers is OwnableUpgradeable {

    using SafeMathUpgradeable for uint256;

    IBEP20Upgradeable public irena;
    IBEP20Upgradeable public usdt;
    uint256 public adminFeePercent;
    uint256 public intervalBlock;
    bool public isEmergencyWithdrawable;

    function initialize() public initializer {
        __Ownable_init();
        irena = IBEP20Upgradeable(0x2Bbeaf7BB69d2296Aa1d09c9198a111f1A2E6fD9); //maticz token
        usdt = IBEP20Upgradeable(0xAbcfc88996CC86A030DfE47429E31893Ae3A6A69); //busd token
        adminFeePercent = 2;
        intervalBlock = 86400;
    }
   
        
    struct ShoesStruct{
      string shoeName;
      uint256 shoePrice;
      uint256 shoePricePerMeter;
      uint256 shoeDailyMeters;
      uint256 shoeTotalStock;
      uint256 shoeStockLeft;
      uint256 shoeUseDays;
      uint256 shoeStakeDays;
      uint256 shoeTokensToBeStaked;
      bool shoeIsEnabled;
    }

    struct UsersStruct{
      uint256 userId;
      string userName;
      uint256 userCoveredMeters;
      uint256 userTotalStaked;
      uint256 userRewardEarned;
      uint256 paidAmount;
      uint256 userJoinedTime;
      uint256 userAge;
      bool userIsBlocked;
      bool userIsExist;
    }

    struct UserShoeInfo{
      uint256 userId;
      uint256 dateOfBuying;
      uint256 stakedAmount;
      uint256 paidAmount;
      uint256 stakedTime;
      uint256 withdrawTime;
      uint256 MetersCovered;
      uint256 rewardsClaimed;
      uint256 lastClaimedTime;
      bool expired;
    }

    struct TransactionReceipt{
      uint256 userId;
      uint256 shoePid;
      uint256 transactionTime;
      uint256 MetersCovered;
      uint256 rewardsClaimed;
      uint256 lastClaimedTime;
      uint256 lastMetersCovered;
    }

    mapping (address => UsersStruct) private userDetails;
    mapping (uint256 => ShoesStruct) private shoeDetails;
    mapping (address => mapping(uint256 => UserShoeInfo)) private userShoeDetails;
    mapping (address => TransactionReceipt[]) private userTransactionReceipt;

    event Register(address indexed user,UsersStruct info);
    event AddShoe(address indexed user,ShoesStruct info);
    event BuyShoe(address indexed user,UserShoeInfo info);
    event Deposit(address indexed user,UserShoeInfo info);
    event Withdraw(address indexed user,UserShoeInfo info,TransactionReceipt[] receipt);
    event Claim(address indexed user,TransactionReceipt[] info);
 
    function checkIsExpired(uint256 _shoePid) internal {
      if(((block.timestamp.sub(userShoeDetails[msg.sender][_shoePid].dateOfBuying)) > shoeDetails[(_shoePid)].shoeUseDays) ||
        (userShoeDetails[msg.sender][_shoePid].paidAmount == 0)){
        userShoeDetails[msg.sender][_shoePid].expired = true;
        userShoeDetails[msg.sender][_shoePid].dateOfBuying = 0;
        userShoeDetails[msg.sender][_shoePid].MetersCovered = 0;
        userShoeDetails[msg.sender][_shoePid].paidAmount = 0;
        userDetails[msg.sender].paidAmount = (userDetails[msg.sender].paidAmount).sub(shoeDetails[_shoePid].shoePrice);
        shoeDetails[_shoePid].shoeStockLeft = shoeDetails[_shoePid].shoeStockLeft.add(1);
      }
    }

    function emergencyClaim(uint256 _userCoveredMeters, uint256 _shoePid) internal returns(TransactionReceipt[] memory){
      
      uint256 exactMeters = _userCoveredMeters.sub(userShoeDetails[msg.sender][_shoePid].MetersCovered); 
      uint256 exactAmount = exactMeters.mul(shoeDetails[_shoePid].shoePricePerMeter);
      uint256 shoeDailyReward = shoeDetails[_shoePid].shoeDailyMeters.mul(shoeDetails[_shoePid].shoePricePerMeter);
      uint256 exactDays = (block.timestamp.sub(userShoeDetails[msg.sender][_shoePid].lastClaimedTime)).div(intervalBlock);
      require( exactAmount <= shoeDailyReward.mul(exactDays),"Reward exceeds!");
       //check for usdt balance in contract 
      require(exactAmount < IBEP20Upgradeable(usdt).balanceOf(address(this)),"Insufficient liquidity to claim reward!");

      userTransactionReceipt[msg.sender].push(TransactionReceipt({
        userId:userDetails[msg.sender].userId,
        shoePid:_shoePid,
        transactionTime:block.timestamp,
        MetersCovered:exactMeters,
        rewardsClaimed:exactAmount,
        lastClaimedTime:userShoeDetails[msg.sender][_shoePid].lastClaimedTime,
        lastMetersCovered:userShoeDetails[msg.sender][_shoePid].MetersCovered
      }));
      //data updates
      userShoeDetails[msg.sender][_shoePid].MetersCovered = userShoeDetails[msg.sender][_shoePid].MetersCovered.add(exactMeters);
      userShoeDetails[msg.sender][_shoePid].rewardsClaimed = userShoeDetails[msg.sender][_shoePid].rewardsClaimed.add(exactAmount);
      userShoeDetails[msg.sender][_shoePid].lastClaimedTime = block.timestamp;
      userDetails[msg.sender].userCoveredMeters = userDetails[msg.sender].userCoveredMeters.add(exactMeters);
      userDetails[msg.sender].userRewardEarned = userDetails[msg.sender].userRewardEarned.add(exactAmount);
      require(usdt.transfer(msg.sender,exactAmount),"Insufficient Irena!");

      return userTransactionReceipt[msg.sender];
    }

    function claimReward(uint256 _userCoveredMeters, uint256 _shoePid
    //  bytes memory signature, uint256[] memory signDatas, string memory _message
    ) public returns (TransactionReceipt[] memory){
      // signDatas[0] - signatureValue, signDatas[2] - _message, signDatas[3] - _nonce
      // require(verify(msg.sender, signDatas[0], _message, signDatas[1], signature) == true,"Not vaild User");
      checkIsExpired(_shoePid);
      require(!userShoeDetails[msg.sender][_shoePid].expired,"Shoe expired!");
      uint256 exactMeters = _userCoveredMeters.sub(userShoeDetails[msg.sender][_shoePid].MetersCovered); 
      uint256 exactAmount = exactMeters.mul(shoeDetails[_shoePid].shoePricePerMeter);
      uint256 shoeDailyReward = shoeDetails[_shoePid].shoeDailyMeters.mul(shoeDetails[_shoePid].shoePricePerMeter);
      uint256 exactDays = (block.timestamp.sub(userShoeDetails[msg.sender][_shoePid].lastClaimedTime)).div(intervalBlock);
      require( exactDays >= 1 ,"You can't claim again within 1 day of claiming!");
      require( exactAmount <= shoeDailyReward.mul(exactDays),"Reward exceeds!");

      //check for usdt balance in contract 
      require(exactAmount < IBEP20Upgradeable(usdt).balanceOf(address(this)),"Insufficient liquidity to claim reward!");
      
      userTransactionReceipt[msg.sender].push(TransactionReceipt({
        userId:userDetails[msg.sender].userId,
        shoePid:_shoePid,
        transactionTime:block.timestamp,
        MetersCovered:exactMeters,
        rewardsClaimed:exactAmount,
        lastClaimedTime:userShoeDetails[msg.sender][_shoePid].lastClaimedTime,
        lastMetersCovered:userShoeDetails[msg.sender][_shoePid].MetersCovered
      }));
      //data updates
      userShoeDetails[msg.sender][_shoePid].MetersCovered = userShoeDetails[msg.sender][_shoePid].MetersCovered.add(exactMeters);
      userShoeDetails[msg.sender][_shoePid].rewardsClaimed = userShoeDetails[msg.sender][_shoePid].rewardsClaimed.add(exactAmount);
      userShoeDetails[msg.sender][_shoePid].lastClaimedTime = block.timestamp;
      userDetails[msg.sender].userCoveredMeters = userDetails[msg.sender].userCoveredMeters.add(exactMeters);
      userDetails[msg.sender].userRewardEarned = userDetails[msg.sender].userRewardEarned.add(exactAmount);
      require(usdt.transfer(msg.sender,exactAmount),"Insufficient Irena!");
  
      emit Claim(msg.sender,userTransactionReceipt[msg.sender]);
      return userTransactionReceipt[msg.sender];
    }

    function depositTokens(uint256 _shoePid, uint256 _amount) public returns (UserShoeInfo memory){
      
      require(shoeDetails[_shoePid].shoeIsEnabled == true,"Currently this shoe is disabled!");
      require(_amount >= (((shoeDetails[_shoePid].shoeTokensToBeStaked.mul(adminFeePercent)).div(100)).add(shoeDetails[_shoePid].shoeTokensToBeStaked)),"Amount not enough to stake!");
      require(irena.transferFrom(msg.sender,address(this),_amount),"Insufficient Irena!");
      //get amount to be staked 
      uint256 amountToStake = (_amount).sub((shoeDetails[_shoePid].shoeTokensToBeStaked.mul(adminFeePercent)).div(100));
      address owner = owner();
      //admin fee transfer 
      require(irena.transfer(owner,((shoeDetails[_shoePid].shoeTokensToBeStaked.mul(adminFeePercent)).div(100))),"Insufficient irena for admin fee!");
      userShoeDetails[msg.sender][_shoePid] = UserShoeInfo({
         userId : userDetails[msg.sender].userId,
         dateOfBuying : 0,
         MetersCovered : 0,
         rewardsClaimed : 0,
         stakedAmount : amountToStake,
         paidAmount : 0,
         stakedTime : block.timestamp,
         withdrawTime : 0,
         lastClaimedTime : block.timestamp,
         expired : false
      });
      userDetails[msg.sender].userTotalStaked = userDetails[msg.sender].userTotalStaked.add(_amount);
      emit Deposit(msg.sender,userShoeDetails[msg.sender][_shoePid]);
      return userShoeDetails[msg.sender][_shoePid];
    }

    function withdrawTokens(uint256 _shoePid,uint256 _MetersCovered) public returns (UserShoeInfo memory, TransactionReceipt[] memory){
      require(block.timestamp.sub(userShoeDetails[msg.sender][_shoePid].stakedTime) >= shoeDetails[_shoePid].shoeStakeDays,"You're not eligible to withdraw!");
      //get admin fee
      uint256 adminFee = ((userShoeDetails[msg.sender][_shoePid].stakedAmount).mul(adminFeePercent)).div(100);
      address owner = owner();
      require(irena.transfer(msg.sender,(userShoeDetails[msg.sender][_shoePid].stakedAmount).sub(adminFee)),"insufficient irena to withdraw !");
      //admin fee transfer
      require(irena.transfer(owner,adminFee),"insufficient irena for admin fee!");

      TransactionReceipt[] memory claimedReceipt = emergencyClaim(_MetersCovered,_shoePid);
      userDetails[msg.sender].userTotalStaked = userDetails[msg.sender].userTotalStaked.sub(userShoeDetails[msg.sender][_shoePid].stakedAmount);
      userShoeDetails[msg.sender][_shoePid].withdrawTime = block.timestamp;
      userShoeDetails[msg.sender][_shoePid].stakedAmount = 0;
      userShoeDetails[msg.sender][_shoePid].stakedTime = 0;
      if(userShoeDetails[msg.sender][_shoePid].paidAmount != 0){
      userShoeDetails[msg.sender][_shoePid].paidAmount = 0;
      userDetails[msg.sender].paidAmount = (userDetails[msg.sender].paidAmount).sub(shoeDetails[_shoePid].shoePrice);
       userShoeDetails[msg.sender][_shoePid].expired = true;
        userShoeDetails[msg.sender][_shoePid].dateOfBuying = 0;
        userShoeDetails[msg.sender][_shoePid].MetersCovered = 0;
        shoeDetails[_shoePid].shoeStockLeft = shoeDetails[_shoePid].shoeStockLeft.add(1);
      }
      emit Withdraw(msg.sender,userShoeDetails[msg.sender][_shoePid],claimedReceipt);
      return (userShoeDetails[msg.sender][_shoePid],claimedReceipt);
    }

    function emergencyWithdraw(uint256 _shoePid) public returns (UserShoeInfo memory){
     require(isEmergencyWithdrawable,"Admin should enable emergency withdrawable!");

      require(irena.transfer(msg.sender,userShoeDetails[msg.sender][_shoePid].stakedAmount),"insufficient irena to withdraw !");
      
      //data modification after withdraw
      userDetails[msg.sender].userTotalStaked = userDetails[msg.sender].userTotalStaked.sub(userShoeDetails[msg.sender][_shoePid].stakedAmount);
      userShoeDetails[msg.sender][_shoePid].withdrawTime = block.timestamp;
      userShoeDetails[msg.sender][_shoePid].stakedAmount = 0;
      userShoeDetails[msg.sender][_shoePid].stakedTime = 0;
      userShoeDetails[msg.sender][_shoePid].paidAmount = 0;
      if(userDetails[msg.sender].paidAmount > shoeDetails[_shoePid].shoePrice){
        userDetails[msg.sender].paidAmount = (userDetails[msg.sender].paidAmount).sub(shoeDetails[_shoePid].shoePrice);
      }else{
        userDetails[msg.sender].paidAmount = 0;
      }
      userShoeDetails[msg.sender][_shoePid].expired = true;
      userShoeDetails[msg.sender][_shoePid].dateOfBuying = 0;
      userShoeDetails[msg.sender][_shoePid].MetersCovered = 0;
      shoeDetails[_shoePid].shoeStockLeft = shoeDetails[_shoePid].shoeStockLeft.add(1);
      return (userShoeDetails[msg.sender][_shoePid]);
   }

   function withdrawIrena() public onlyOwner (){
     address owner = owner();
     require(irena.transfer(owner,IBEP20Upgradeable(irena).balanceOf(address(this))),"insufficient irena!");
   }

   function withdrawUsdt() public onlyOwner (){
     address owner = owner();
     require(usdt.transfer(owner,IBEP20Upgradeable(usdt).balanceOf(address(this))),"insufficient usdt!");
   }

   function setIsEmergencyWithdrawable() public onlyOwner (){
     isEmergencyWithdrawable = !isEmergencyWithdrawable;
   }

    function addShoe( uint256[] memory _shoeInfo, string memory _shoeName, uint256 _shoePid) public onlyOwner returns (ShoesStruct memory) {
      shoeDetails[_shoePid] = ShoesStruct({
        shoeName : _shoeName, 
        shoePrice : _shoeInfo[0],
        shoePricePerMeter : _shoeInfo[1],
        shoeDailyMeters : _shoeInfo[2],
        shoeTotalStock : _shoeInfo[3],
        shoeStockLeft :_shoeInfo[3],
        shoeUseDays : (_shoeInfo[4]).mul(intervalBlock),
        shoeStakeDays : (_shoeInfo[5]).mul(intervalBlock),
        shoeTokensToBeStaked : _shoeInfo[6],
        shoeIsEnabled : true
      });
      emit AddShoe(msg.sender,shoeDetails[_shoePid]);
      return shoeDetails[_shoePid];
    }

    function buyShoe(uint256 _amount, uint256 _shoePid) public returns (UserShoeInfo memory){
      require(shoeDetails[_shoePid].shoePrice <= _amount, "Amount not enough to buy this shoe!");
      require(userDetails[msg.sender].userIsExist,"User need to register!");
      require(shoeDetails[_shoePid].shoeStockLeft != 0,"Out of Stock!");
      require(shoeDetails[_shoePid].shoeIsEnabled == true,"Currently this shoe is disabled!");
      require(userDetails[msg.sender].userIsBlocked == false,"This user is Blocked!");
      require(userShoeDetails[msg.sender][_shoePid].stakedAmount >= shoeDetails[_shoePid].shoeTokensToBeStaked,"User need to stake to buy this shoe!");
      //usdt transfered to owner wallet
      address owner = owner();
      require(usdt.transferFrom(msg.sender,owner,_amount),"Insufficient Irena!");

      userShoeDetails[msg.sender][_shoePid].dateOfBuying = block.timestamp;
      userShoeDetails[msg.sender][_shoePid].paidAmount = (userShoeDetails[msg.sender][_shoePid].paidAmount).add(_amount);
      userDetails[msg.sender].paidAmount = (userDetails[msg.sender].paidAmount).add(_amount);
      shoeDetails[_shoePid].shoeStockLeft = shoeDetails[_shoePid].shoeStockLeft.sub(1);
      emit BuyShoe(msg.sender,userShoeDetails[msg.sender][_shoePid]);
      return userShoeDetails[msg.sender][_shoePid];
    }
    
   function registerUser(string memory _name, uint256 _age) public returns (UsersStruct memory){
     require(!userDetails[msg.sender].userIsExist,"User Already Exist!");
     userDetails[msg.sender] = UsersStruct({
      userIsExist : true,
      userId : block.timestamp,
      userName : _name,
      userCoveredMeters : 0,
      userTotalStaked : 0,
      userRewardEarned : 0,
      paidAmount : 0,
      userJoinedTime : block.timestamp,
      userAge : _age,
      userIsBlocked : false
     });
     emit Register(msg.sender,userDetails[msg.sender]);
     return userDetails[msg.sender];
   }

   function shoeSettings(uint256 _shoePid) public onlyOwner returns (ShoesStruct memory){
     shoeDetails[_shoePid].shoeIsEnabled = !shoeDetails[_shoePid].shoeIsEnabled;
     return shoeDetails[_shoePid];
   }

   function userSettings(address _address) public onlyOwner returns (UsersStruct memory){
     userDetails[_address].userIsBlocked = !userDetails[_address].userIsBlocked;
     return userDetails[_address];
   }

   function getUserInfo(address _address) public view returns (UsersStruct memory){
     return userDetails[_address];
   }
    
   function getShoeInfo(uint256 _shoePid) public view returns (ShoesStruct memory){
       return shoeDetails[_shoePid];
   }

   function getUserShoeInfo(uint256 _shoePid, address _address) public view returns (UserShoeInfo memory){
     return userShoeDetails[_address][_shoePid];
   }

   function getUserTransactions(address _address) public view returns (TransactionReceipt[] memory){
      return userTransactionReceipt[_address];
    }

   function getAdminFeePercentage() public view returns (uint256){
     return adminFeePercent;
   }

   function setIrenaTokenAddress(address _irena) public onlyOwner {
    irena = IBEP20Upgradeable(_irena);
   }

   function setUsdtTokenAddress(address _usdt) public onlyOwner {
    usdt = IBEP20Upgradeable(_usdt);
   }

}