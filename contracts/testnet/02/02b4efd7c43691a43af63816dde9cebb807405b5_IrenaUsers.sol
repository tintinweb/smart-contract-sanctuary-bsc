/**
 *Submitted for verification at BscScan.com on 2023-01-06
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-27
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-24
*/

pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;
// SPDX-License-Identifier: MIT

library SafeMath {
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

contract Owned {
        address payable public owner;
    
        event OwnershipTransferred(address indexed _from, address indexed _to);
    
        constructor() public {
            owner = msg.sender;
        }
    
        modifier onlyOwner {
            require(msg.sender == owner);
            _;
        }
        
        function getOwner() public view returns(address){
        return owner;
        }
    
        function transferOwnership(address payable _newOwner) public onlyOwner {
            owner = _newOwner;
            emit OwnershipTransferred(msg.sender, _newOwner);
        }
    }

    contract VerifySignature {
    function getMessageHash(
        address _to,
        uint _amount,
        string memory _message,
        uint _nonce
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_to, _amount, _message, _nonce));
    }
    function getEthSignedMessageHash(bytes32 _messageHash)
        public
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash)
            );
    }
    function verify(
        address _to,
        uint256 _amount,
        string memory _message,
        uint _nonce,
        bytes memory signature
    ) public pure returns (bool) {
        bytes32 messageHash = getMessageHash(_to, _amount, _message, _nonce);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recoverSigner(ethSignedMessageHash, signature) == _to;
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature)
        public
        pure
        returns (address)
    {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
        public
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, "invalid signature length");

        assembly {

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        // implicitly return (r, s, v)
    }
}


interface IBEP20 {
     function approve(address to, uint256 tokens) external returns (bool success);
     function decimals() external view returns (uint256);
    function transfer(address to, uint256 tokens) external returns (bool success);
    function burnTokens(uint256 _amount) external;
    function balanceOf(address tokenOwner) external view returns (uint256 balance);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function mint(address _to,uint256 amount) external returns (bool success);
    function transferOwnership(address _newOwner) external returns (bool success);
}


contract IrenaUsers is Owned,VerifySignature {

    using SafeMath for uint256;

    IBEP20 public irena;
    IBEP20 public usdt;
    uint256 public adminFeePercent;

    constructor(address _irena, address _usdt, uint256 _adminFeePercent) public{
     irena = IBEP20(_irena);
     usdt = IBEP20(_usdt);
     adminFeePercent = _adminFeePercent;
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
    

    // function setIrenaTokenAddress(address _irena) onlyOwner public {
    //   irena = IBEP20(_irena);
    // }

    // function setUsdtTokenAddress(address _usdt) onlyOwner public {
    //   usdt = IBEP20(_usdt);
    // }

    function checkIsExpired(uint256 _shoePid) internal {
      if(((block.timestamp.sub(userShoeDetails[msg.sender][_shoePid].dateOfBuying)) > shoeDetails[(_shoePid)].shoeUseDays) ||
        (userShoeDetails[msg.sender][_shoePid].paidAmount == 0)){
        userShoeDetails[msg.sender][_shoePid].expired = true;
        userShoeDetails[msg.sender][_shoePid].dateOfBuying = 0;
        userShoeDetails[msg.sender][_shoePid].MetersCovered = 0;
        userShoeDetails[msg.sender][_shoePid].paidAmount = 0;
        userDetails[msg.sender].paidAmount = (userDetails[msg.sender].paidAmount).sub(shoeDetails[_shoePid].shoePrice);
      }
    }

    function emergencyClaim(uint256 _userCoveredMeters, uint256 _shoePid) internal returns(TransactionReceipt[] memory){
      
      uint256 exactMeters = _userCoveredMeters.sub(userShoeDetails[msg.sender][_shoePid].MetersCovered); 
      uint256 exactAmount = exactMeters.mul(shoeDetails[_shoePid].shoePricePerMeter);
      uint256 shoeDailyReward = shoeDetails[_shoePid].shoeDailyMeters.mul(shoeDetails[_shoePid].shoePricePerMeter);
      uint256 exactDays = (block.timestamp.sub(userShoeDetails[msg.sender][_shoePid].lastClaimedTime)).div(86400);
      require( exactAmount <= shoeDailyReward.mul(exactDays),"Reward exceeds!");
      userShoeDetails[msg.sender][_shoePid].MetersCovered = userShoeDetails[msg.sender][_shoePid].MetersCovered.add(exactMeters);
      userShoeDetails[msg.sender][_shoePid].rewardsClaimed = userShoeDetails[msg.sender][_shoePid].rewardsClaimed.add(exactAmount);
      userShoeDetails[msg.sender][_shoePid].lastClaimedTime = block.timestamp;
      userDetails[msg.sender].userCoveredMeters = userDetails[msg.sender].userCoveredMeters.add(exactMeters);
      userDetails[msg.sender].userRewardEarned = userDetails[msg.sender].userRewardEarned.add(exactAmount);
      require(usdt.transferFrom(address(this),msg.sender,exactAmount),"Insufficient Irena!");
      
      userTransactionReceipt[msg.sender].push(TransactionReceipt({
        userId:userDetails[msg.sender].userId,
        shoePid:_shoePid,
        transactionTime:block.timestamp,
        MetersCovered:exactMeters,
        rewardsClaimed:exactAmount
      }));
      
      return userTransactionReceipt[msg.sender];
    }

    function claimReward(uint256 _userCoveredMeters, uint256 _shoePid,  bytes memory signature, uint256[] memory signDatas, string memory _message) public returns (TransactionReceipt[] memory){
      // signDatas[0] - signatureValue, signDatas[2] - _message, signDatas[3] - _nonce
      require(verify(msg.sender, signDatas[0], _message, signDatas[1], signature) == true,"Not vaild User");
      checkIsExpired(_shoePid);
      require(!userShoeDetails[msg.sender][_shoePid].expired,"Shoe expired!");
      uint256 exactMeters = _userCoveredMeters.sub(userShoeDetails[msg.sender][_shoePid].MetersCovered); 
      uint256 exactAmount = exactMeters.mul(shoeDetails[_shoePid].shoePricePerMeter);
      uint256 shoeDailyReward = shoeDetails[_shoePid].shoeDailyMeters.mul(shoeDetails[_shoePid].shoePricePerMeter);
      uint256 exactDays = (block.timestamp.sub(userShoeDetails[msg.sender][_shoePid].lastClaimedTime)).div(86400);
      require( exactDays > 1 days,"You can't claim again within 1 day of claiming!");
      require( exactAmount <= shoeDailyReward.mul(exactDays),"Reward exceeds!");
      userShoeDetails[msg.sender][_shoePid].MetersCovered = userShoeDetails[msg.sender][_shoePid].MetersCovered.add(exactMeters);
      userShoeDetails[msg.sender][_shoePid].rewardsClaimed = userShoeDetails[msg.sender][_shoePid].rewardsClaimed.add(exactAmount);
      userShoeDetails[msg.sender][_shoePid].lastClaimedTime = block.timestamp;
      userDetails[msg.sender].userCoveredMeters = userDetails[msg.sender].userCoveredMeters.add(exactMeters);
      userDetails[msg.sender].userRewardEarned = userDetails[msg.sender].userRewardEarned.add(exactAmount);
      require(usdt.transferFrom(address(this),msg.sender,exactAmount),"Insufficient Irena!");
      userTransactionReceipt[msg.sender].push(TransactionReceipt({
        userId:userDetails[msg.sender].userId,
        shoePid:_shoePid,
        transactionTime:block.timestamp,
        MetersCovered:exactMeters,
        rewardsClaimed:exactAmount
      }));
      emit Claim(msg.sender,userTransactionReceipt[msg.sender]);
      return userTransactionReceipt[msg.sender];
    }

    function depositTokens(uint256 _shoePid, uint256 _amount) public returns (UserShoeInfo memory){
      
      require(shoeDetails[_shoePid].shoeIsEnabled == true,"Currently this shoe is disabled!");
      require(_amount >= (((shoeDetails[_shoePid].shoeTokensToBeStaked.mul(adminFeePercent)).div(100)).add(shoeDetails[_shoePid].shoeTokensToBeStaked)),"Amount not enough to stake!");
      require(irena.transferFrom(msg.sender,address(this),_amount),"Insufficient Irena!");
      //get amount to be staked 
      uint256 amountToStake = (_amount).sub((shoeDetails[_shoePid].shoeTokensToBeStaked.mul(adminFeePercent)).div(100));
      address owner = getOwner();
      //admin fee transfer 
      require(irena.transferFrom(address(this),owner,((shoeDetails[_shoePid].shoeTokensToBeStaked.mul(adminFeePercent)).div(100))),"Insufficient irena for admin fee!");
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
      address owner = getOwner();
      require(irena.transferFrom(address(this),msg.sender,(userShoeDetails[msg.sender][_shoePid].stakedAmount).sub(adminFee)),"insufficient irena to withdraw !");
      //admin fee transfer
      require(irena.transferFrom(address(this),owner,adminFee),"insufficient irena for admin fee!");

      TransactionReceipt[] memory claimedReceipt = emergencyClaim(_shoePid,_MetersCovered);
      userDetails[msg.sender].userTotalStaked = userDetails[msg.sender].userTotalStaked.sub(userShoeDetails[msg.sender][_shoePid].stakedAmount);
      userShoeDetails[msg.sender][_shoePid].withdrawTime = block.timestamp;
      userShoeDetails[msg.sender][_shoePid].stakedAmount = 0;
      userShoeDetails[msg.sender][_shoePid].stakedTime = 0;
      if(userShoeDetails[msg.sender][_shoePid].paidAmount != 0){
      userShoeDetails[msg.sender][_shoePid].paidAmount = 0;
      userDetails[msg.sender].paidAmount = (userDetails[msg.sender].paidAmount).sub(shoeDetails[_shoePid].shoePrice);
      }
      emit Withdraw(msg.sender,userShoeDetails[msg.sender][_shoePid],claimedReceipt);
      return (userShoeDetails[msg.sender][_shoePid],claimedReceipt);
    }

    function addShoe( uint256[] memory _shoeInfo, string memory _shoeName, uint256 _shoePid) public onlyOwner returns (ShoesStruct memory) {
      shoeDetails[_shoePid] = ShoesStruct({
        shoeName : _shoeName, 
        shoePrice : _shoeInfo[0],
        shoePricePerMeter : _shoeInfo[1],
        shoeDailyMeters : _shoeInfo[2],
        shoeTotalStock : _shoeInfo[3],
        shoeStockLeft :_shoeInfo[3],
        shoeUseDays : (_shoeInfo[4]).mul(1 days),
        shoeStakeDays : (_shoeInfo[5]).mul(1 days),
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
      require(usdt.transferFrom(msg.sender,address(this),_amount),"Insufficient Irena!");
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

  //  function setAdminFeePercentage(uint256 _adminFeePercent) external onlyOwner returns (uint256){
  //    adminFeePercent = _adminFeePercent;
  //    return adminFeePercent;
  //  }
}