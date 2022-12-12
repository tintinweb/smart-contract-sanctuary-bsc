/**
 *Submitted for verification at BscScan.com on 2022-12-12
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

    constructor(address _irena, address _usdt) public{
     irena = IBEP20(_irena);
     usdt = IBEP20(_usdt);
    }
        
    struct ShoesStruct{
      string shoeName;
      uint256 shoePrice;
      uint256 shoePricePerKM;
      uint256 shoeDailyKMs;
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
      uint256 userCoveredKMs;
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
      uint256 kmsCovered;
      uint256 rewardsClaimed;
      uint256 lastClaimedTime;
      bool expired;
    }

    struct TransactionReceipt{
      uint256 userId;
      uint256 shoePid;
      uint256 transactionTime;
      uint256 kmsCovered;
      uint256 rewardsClaimed;
    }

    mapping (address => UsersStruct) public userDetails;
    mapping (uint256 => ShoesStruct) public shoeDetails;
    mapping (address => mapping(uint256 => UserShoeInfo)) public userShoeDetails;
    mapping (address => TransactionReceipt[]) public userTransactionReceipt;

    function setIrenaTokenAddress(address _irena) onlyOwner public {
      irena = IBEP20(_irena);
    }

    function setUsdtTokenAddress(address _usdt) onlyOwner public {
      usdt = IBEP20(_usdt);
    }

    function checkIsExpired(uint256 _shoePid) internal {
      if((block.timestamp.sub(userShoeDetails[msg.sender][_shoePid].dateOfBuying)) > shoeDetails[(_shoePid)].shoeUseDays){
        userShoeDetails[msg.sender][_shoePid].expired = true;
        userShoeDetails[msg.sender][_shoePid].dateOfBuying = 0;
        userShoeDetails[msg.sender][_shoePid].kmsCovered = 0;
        userShoeDetails[msg.sender][_shoePid].paidAmount = 0;
        userDetails[msg.sender].paidAmount = (userDetails[msg.sender].paidAmount).sub(shoeDetails[_shoePid].shoePrice);
      }
    }

    function emergencyClaim(uint256 _userCoveredKMs, uint256 _shoePid) internal returns(TransactionReceipt[] memory){
      
      uint256 exactKMs = _userCoveredKMs.sub(userShoeDetails[msg.sender][_shoePid].kmsCovered); 
      uint256 exactAmount = exactKMs.mul(shoeDetails[_shoePid].shoePricePerKM);
      uint256 shoeDailyReward = shoeDetails[_shoePid].shoeDailyKMs.mul(shoeDetails[_shoePid].shoePricePerKM);
      uint256 exactDays = (block.timestamp.sub(userShoeDetails[msg.sender][_shoePid].lastClaimedTime)).div(86400);
      require( exactAmount <= shoeDailyReward.mul(exactDays),"Reward exceeds!");
      userShoeDetails[msg.sender][_shoePid].kmsCovered = userShoeDetails[msg.sender][_shoePid].kmsCovered.add(exactKMs);
      userShoeDetails[msg.sender][_shoePid].rewardsClaimed = userShoeDetails[msg.sender][_shoePid].rewardsClaimed.add(exactAmount);
      userShoeDetails[msg.sender][_shoePid].lastClaimedTime = block.timestamp;
      userDetails[msg.sender].userCoveredKMs = userDetails[msg.sender].userCoveredKMs.add(exactKMs);
      userDetails[msg.sender].userRewardEarned = userDetails[msg.sender].userRewardEarned.add(exactAmount);
      require(usdt.transfer(msg.sender,exactAmount),"Insufficient Irena!");
      
      userTransactionReceipt[msg.sender].push(TransactionReceipt({
        userId:userDetails[msg.sender].userId,
        shoePid:_shoePid,
        transactionTime:block.timestamp,
        kmsCovered:exactKMs,
        rewardsClaimed:exactAmount
      }));
      
      return userTransactionReceipt[msg.sender];
    }

    function claimReward(uint256 _userCoveredKMs, uint256 _shoePid,  bytes memory signature, uint256[] memory signDatas, string memory _message) public returns (TransactionReceipt[] memory){
      // signDatas[0] - signatureValue, signDatas[2] - _message, signDatas[3] - _nonce
      // require(verify(msg.sender, signDatas[0], _message, signDatas[1], signature) == true,"Not vaild User");
      checkIsExpired(_shoePid);
      require(!userShoeDetails[msg.sender][_shoePid].expired,"Shoe expired!");
      uint256 exactKMs = _userCoveredKMs.sub(userShoeDetails[msg.sender][_shoePid].kmsCovered); 
      uint256 exactAmount = exactKMs.mul(shoeDetails[_shoePid].shoePricePerKM);
      uint256 shoeDailyReward = shoeDetails[_shoePid].shoeDailyKMs.mul(shoeDetails[_shoePid].shoePricePerKM);
      uint256 exactDays = (block.timestamp.sub(userShoeDetails[msg.sender][_shoePid].lastClaimedTime)).div(86400);
      require( exactAmount <= shoeDailyReward.mul(exactDays),"Reward exceeds!");
      userShoeDetails[msg.sender][_shoePid].kmsCovered = userShoeDetails[msg.sender][_shoePid].kmsCovered.add(exactKMs);
      userShoeDetails[msg.sender][_shoePid].rewardsClaimed = userShoeDetails[msg.sender][_shoePid].rewardsClaimed.add(exactAmount);
      userShoeDetails[msg.sender][_shoePid].lastClaimedTime = block.timestamp;
      userDetails[msg.sender].userCoveredKMs = userDetails[msg.sender].userCoveredKMs.add(exactKMs);
      userDetails[msg.sender].userRewardEarned = userDetails[msg.sender].userRewardEarned.add(exactAmount);
      require(usdt.transfer(msg.sender,exactAmount),"Insufficient Irena!");
      userTransactionReceipt[msg.sender].push(TransactionReceipt({
        userId:userDetails[msg.sender].userId,
        shoePid:_shoePid,
        transactionTime:block.timestamp,
        kmsCovered:exactKMs,
        rewardsClaimed:exactAmount
      }));
      return userTransactionReceipt[msg.sender];
    }

    function depositTokens(uint256 _shoePid, uint256 _amount) public returns (UserShoeInfo memory){
      require(shoeDetails[_shoePid].shoeIsEnabled == true,"Currently this shoe is disabled!");
      require(_amount >= shoeDetails[_shoePid].shoeTokensToBeStaked,"Amount not enough to stake!");
      require(irena.transferFrom(msg.sender,address(this),_amount),"Insufficient Irena!");
      userShoeDetails[msg.sender][_shoePid] = UserShoeInfo({
         userId : userDetails[msg.sender].userId,
         dateOfBuying : 0,
         kmsCovered : 0,
         rewardsClaimed : 0,
         stakedAmount : _amount,
         paidAmount : 0,
         stakedTime : block.timestamp,
         withdrawTime : 0,
         lastClaimedTime : block.timestamp,
         expired : false
      });
      userDetails[msg.sender].userTotalStaked = userDetails[msg.sender].userTotalStaked.add(_amount);
      return userShoeDetails[msg.sender][_shoePid];
    }

    function withdrawTokens(uint256 _shoePid,uint256 _kmsCovered) public returns (UserShoeInfo memory, TransactionReceipt[] memory){
      require(block.timestamp.sub(userShoeDetails[msg.sender][_shoePid].stakedTime) >= shoeDetails[_shoePid].shoeStakeDays,"You're not eligible to withdraw!");
      require(irena.transfer(msg.sender,userShoeDetails[msg.sender][_shoePid].stakedAmount),"insufficient irena to withdraw !");
      TransactionReceipt[] memory claimedReceipt = emergencyClaim(_shoePid,_kmsCovered);
      userDetails[msg.sender].userTotalStaked = userDetails[msg.sender].userTotalStaked.sub(userShoeDetails[msg.sender][_shoePid].stakedAmount);
      userShoeDetails[msg.sender][_shoePid].withdrawTime = block.timestamp;
      userShoeDetails[msg.sender][_shoePid].stakedAmount = 0;
      userShoeDetails[msg.sender][_shoePid].stakedTime = 0;
      if(userShoeDetails[msg.sender][_shoePid].paidAmount != 0){
      userShoeDetails[msg.sender][_shoePid].paidAmount = 0;
      userDetails[msg.sender].paidAmount = (userDetails[msg.sender].paidAmount).sub(shoeDetails[_shoePid].shoePrice);
      }
      return (userShoeDetails[msg.sender][_shoePid],claimedReceipt);
    }

    function addShoe( uint256[] memory _shoeInfo, string memory _shoeName, uint256 _shoePid) public onlyOwner returns (ShoesStruct memory) {
      shoeDetails[_shoePid] = ShoesStruct({
        shoeName : _shoeName, 
        shoePrice : _shoeInfo[0],
        shoePricePerKM : _shoeInfo[1],
        shoeDailyKMs : _shoeInfo[2],
        shoeTotalStock : _shoeInfo[3],
        shoeStockLeft :_shoeInfo[3],
        shoeUseDays : (_shoeInfo[4]).mul(1 days),
        shoeStakeDays : (_shoeInfo[5]).mul(1 days),
        shoeTokensToBeStaked : _shoeInfo[6],
        shoeIsEnabled : true
      });
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
      return userShoeDetails[msg.sender][_shoePid];
    }
    
   function registerUser(string memory _name, uint256 _age) public returns (UsersStruct memory){
     require(!userDetails[msg.sender].userIsExist,"User Already Exist!");
     userDetails[msg.sender] = UsersStruct({
      userIsExist : true,
      userId : block.timestamp,
      userName : _name,
      userCoveredKMs : 0,
      userTotalStaked : 0,
      userRewardEarned : 0,
      paidAmount : 0,
      userJoinedTime : block.timestamp,
      userAge : _age,
      userIsBlocked : false
     });
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
}