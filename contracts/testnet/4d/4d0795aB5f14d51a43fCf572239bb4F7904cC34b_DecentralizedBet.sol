/**
 *Submitted for verification at BscScan.com on 2022-11-17
*/

/**
 *Submitted for verification at BscScan.com on 2021-09-27
*/

pragma solidity ^0.7.6;


/* 
   [̲̅S][̲̅O][̲̅C][̲̅C][̲̅E][̲̅R][̲̅C][̲̅R][̲̅Y][̲̅P][̲̅T]
   
   &

   𝕄𝕒𝕥𝕔𝕙 𝕋𝕠𝕜𝕖𝕟 𝕋𝕖𝕒𝕞

*/


interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
    external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value)
    external returns (bool);

    function transferFrom(address from, address to, uint256 value)
    external returns (bool);

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library SafeMath {

    /**
     * @dev Multiplies two numbers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two numbers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }


}

library SafeMath64 {

    /**
     * @dev Multiplies two numbers, reverts on overflow.
     */
    function mul(uint64 a, uint64 b) internal pure returns (uint64) {
        uint64 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
     */
    function div(uint64 a, uint64 b) internal pure returns (uint64) {
        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint64 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint64 a, uint64 b) internal pure returns (uint64) {
        require(b <= a);
        uint64 c = a - b;

        return c;
    }

    /**
     * @dev Adds two numbers, reverts on overflow.
     */
    function add(uint64 a, uint64 b) internal pure returns (uint64) {
        uint64 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint64 a, uint64 b) internal pure returns (uint64) {
        require(b != 0);
        return a % b;
    }


}

contract Owner {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    event OwnershipTransferred(address indexed previousOwner,address indexed newOwner);

    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != address(0x0),"no 0");
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner,owner);
    }
}


contract DecentralizedBet is Owner{

  using SafeMath for uint256;
  using SafeMath64 for uint64;

  uint64 private constant PROVIDER_FEE = 300;
  uint64 private constant REFERRAL_FEE = 1000;
  uint8 private constant MAKER_WIN = 1;
  uint8 private constant TAKER_WIN = 2;
  uint8 private constant BOTH_WIN = 100;
  uint64 constant public DIVIDER = 10000;
  address public providerAddress = 0x62FC14aE7B197f3a4c9eafd2Aa0957382Aa7EBa5 ; 
  address public refereeAddress = 0x62FC14aE7B197f3a4c9eafd2Aa0957382Aa7EBa5 ; 
  address private constant matchContract = 0x62FC14aE7B197f3a4c9eafd2Aa0957382Aa7EBa5;
  mapping (uint256 => Order) internal orders;
  mapping (bytes32 => uint256[]) internal orderGroups;

  mapping(address => mapping(uint256 => Reff)) internal reffSystem;
  mapping(uint256 => Token) internal allowedTokens;

  struct Token{
    IBEP20 bep20;
    address _address;
    uint256 _MINIMUM_BET;
  }
  struct Reff{
    address referrer;
    uint256 claimable;
  }
  struct Order{
    bool makerClaimed;
    bool takerClaimed;
    uint8 winner;
    uint8 betType ;
    uint8 status;
    uint16 valueBetType;
    uint32 odds;
    uint32 startTime;
    uint64 matchId;
    uint64 orderId;
    uint256 makerPot;
    uint256 makerTotalPot;
    uint256 takerPot;
    address makerSide;
    address takerSide;
    uint64 tokenCode;
  }

  
  constructor() public {

    addToken(matchContract,100,1 * (10 ** 18));
  }

  event Claimed(address indexed user, uint64 orderId, uint256 amount);
  event OrderCreated(bytes32 _groupId, uint64 _matchId, uint64 _orderId,uint256 createdTime);
  event MatchSettled(bytes32 _groupId);


  function recoverAddress(bytes memory abiEncoded, bytes memory signature) internal pure returns(address){

    bytes32 hashed = keccak256(abiEncoded);

    bytes32  r = convertToBytes32(slice(signature, 0, 32));
    bytes32  s = convertToBytes32(slice(signature, 32, 32));
    byte  v1 = slice(signature, 64, 1)[0];
    uint8 v = uint8(v1);
    return (ecrecover(hashed, v,r,s));
  }

  function slice(bytes memory data, uint start, uint len) internal pure returns (bytes memory){
      bytes memory b = new bytes(len);
      for(uint i = 0; i < len; i++){
          b[i] = data[i + start];
      }
      return b;
  }

  function convertToBytes32(bytes memory source) internal pure returns (bytes32 result) {
      assembly {
          result := mload(add(source, 32))
      }
  }
    
  bytes constant prefix = "\x19Ethereum Signed Message:\n32";

  /// @notice Creating an order / betslip
  /// @param makerParams parameters of the maker. it will be 9-length array of uint64
  /// @param _orderId id for the betslip from the referee
  /// @param orderGroupId id for betslip that grouped by bet type
  /// @param _takerPot value of taker pot in the betslip
  /// @param makerSignature the signature of makerParams
  /// @param refereeSignature the signature from Referee that will protect the maker params, _orderId & orderGroupId
  /// @param referrer the taker's referrer
  function createOrder(uint256[] memory makerParams,uint64 _orderId, bytes32 orderGroupId, uint256 _takerPot, bytes memory makerSignature,bytes memory refereeSignature,address referrer) public returns(bool){
    
    require(!isContract(msg.sender),"Contract is not allowed");
    require(makerParams.length == 9 , "Invalid makerParams");
    require(allowedTokens[makerParams[8]]._address != address(0), "Invalid tokens");
    require(_orderId > 0 , "Invalid takerParams");
    require(_takerPot >= allowedTokens[makerParams[8]]._MINIMUM_BET,"Raise your bet!");
    bytes32 hashed = keccak256(abi.encodePacked(makerParams));
    bytes memory encoded = abi.encodePacked(prefix,hashed);
    address addrMaker = recoverAddress(encoded,makerSignature);

    //require(addrMaker == maker,"Invalid maker");

    Order storage order = orders[_orderId];
    require(order.orderId == 0 , "Duplicate Order ID");

    order.matchId = uint64(makerParams[0]);
    order.odds = uint32(makerParams[1]);
    order.startTime = uint32(makerParams[2]);
    order.makerTotalPot = makerParams[4];
    order.betType = uint8(makerParams[5]);
    order.status = 99;
    order.valueBetType = uint16(makerParams[6]);
    order.orderId = _orderId;
    order.takerPot = _takerPot;
    order.makerSide = addrMaker;
    order.makerClaimed=false;
    order.takerClaimed=false;
    order.tokenCode = uint64(makerParams[8]);

    require(block.timestamp<= makerParams[7],"Maker order Expired");
    require(block.timestamp < makerParams[2],"The match already started");
    require(makerParams[2] < makerParams[3],"StartTime > EndTime");
    require(order.odds > 100,"Minimum Odds 101");

    //require(memOrder.makerSide!= msg.sender,"Maker == Taker"); //maker != taker
    hashed = keccak256(abi.encodePacked(_orderId,orderGroupId,makerSignature));
    encoded = abi.encodePacked(prefix,hashed);
    require(recoverAddress(encoded,refereeSignature) == refereeAddress, "Invalid Referee");
    order.takerSide = msg.sender;

    emit OrderCreated(orderGroupId,order.matchId,order.orderId,block.timestamp);
    uint256 makerTotalPotUsed = 0;
    uint makerOrdersLength = orderGroups[orderGroupId].length;
    for(uint i=0 ; i < makerOrdersLength ; i++){
      uint256 loopOrderId = orderGroups[orderGroupId][i];
      if(orders[loopOrderId].odds > 0){
        require(orders[loopOrderId].odds == order.odds,"Duplicate order on Maker Side for one Match!");
      }
      makerTotalPotUsed = makerTotalPotUsed.add(orders[loopOrderId].makerPot);
    }
    order.makerTotalPot = order.makerTotalPot.sub(makerTotalPotUsed);
    order.makerPot = uint256(order.odds).sub(100).mul(order.takerPot).div(100);
    require(order.makerPot<=order.makerTotalPot,"Maker Pot Limit Exceeded");

    IBEP20 bep20 = allowedTokens[order.tokenCode].bep20;
    require(bep20.allowance(order.makerSide,address(this))>=order.makerPot,"insufficient maker allowance");
    require(bep20.allowance(order.takerSide,address(this))>=order.takerPot,"insufficient taker allowance");

    require(bep20.balanceOf(order.makerSide)>=order.makerPot,"insufficient maker balance");
    require(bep20.balanceOf(order.takerSide)>=order.takerPot,"insufficient taker balance");

    order.status = 0;
    orderGroups[orderGroupId].push(order.orderId);


    if (referrer != providerAddress && referrer != msg.sender ){
      if(reffSystem[msg.sender][order.tokenCode].referrer == address(0) && allowedTokens[order.tokenCode]._address != matchContract){
        reffSystem[msg.sender][order.tokenCode].referrer = referrer;
      }
    }

    bep20.transferFrom(order.makerSide,address(this),order.makerPot);
    bep20.transferFrom(order.takerSide,address(this),order.takerPot);
   
    return true;
  }

  /// @notice to get referrer balance
  /// @param addr referrer's address
  /// @param tokenCode code of token
  /// @return claimable balance of referrer
  function getRefClaimable(address addr,uint256 tokenCode) public view returns(uint256){
    return reffSystem[addr][tokenCode].claimable;
  }

  /// @notice claim referral fee. only for match token
  /// @param tokenCode code of token
  function claimReferralFee(uint256 tokenCode) public{
    uint256 claimable = reffSystem[msg.sender][tokenCode].claimable;
    reffSystem[msg.sender][tokenCode].claimable =0;
    allowedTokens[tokenCode].bep20.transfer(msg.sender,claimable);
  
  }

  /// @notice get order information by id
  /// @param orderId identifier for the order
  /// @return rInt 17-length array of uint256
  function getOrderById(uint64 orderId) public view returns(uint256[] memory rInt){
     rInt = new uint256[](17);
     rInt[0] = uint256(orders[orderId].orderId);
     rInt[1] = uint256(orders[orderId].matchId);
     rInt[2] = uint256(orders[orderId].odds);
     rInt[3] = uint256(orders[orderId].takerSide);
     rInt[4] = uint256(orders[orderId].makerSide);
     rInt[5] = uint256(orders[orderId].makerPot);
     rInt[6] = uint256(orders[orderId].makerTotalPot);
     rInt[7] = uint256(orders[orderId].takerPot);
     rInt[8] = uint256(orders[orderId].betType);
     rInt[9] = uint256(orders[orderId].status);
     rInt[10] = uint256(orders[orderId].valueBetType);
     rInt[11] = uint256(orders[orderId].startTime);
     rInt[13] = orders[orderId].makerClaimed?1:0;
     rInt[14] = orders[orderId].takerClaimed?1:0;
     rInt[15] = uint256(orders[orderId].winner);
     rInt[16] = uint256(orders[orderId].tokenCode);
  }

  /// @notice to get token that can be used in de-bet
  /// @param codeToken identifier for the token
  /// @return the address of the token
  function getAllowedTokens(uint256 codeToken) public view returns(address){
 
    return allowedTokens[codeToken]._address;
  }

  /// @notice to get list of order id by the group id
  /// @param groupId identifier of the group
  /// @return list of order id from the group
  function getOrderIdsByGroup(bytes32 groupId) public view returns(uint256[] memory){

    return orderGroups[groupId];

  }

   /// @notice to claim the win
  /// @param orderId identifier of the order
  /// @return status of the claim
  function claim(uint256 orderId) public returns(bool) {

    Order storage order = orders[orderId];
    require(order.status == 1 || order.status == BOTH_WIN,"1");
    require(allowedTokens[order.tokenCode]._address != address(0), "2");
    IBEP20 bep20 = allowedTokens[order.tokenCode].bep20;
    address referrer = reffSystem[order.takerSide][order.tokenCode].referrer;
    if(order.status == 1){
      require(order.winner == MAKER_WIN || order.winner == TAKER_WIN ,"3");
      require(!order.makerClaimed && !order.takerClaimed,"4");
      uint256 pot = 0;
      uint256 fee = 0;
      if(order.winner == MAKER_WIN){
       require(order.makerSide == msg.sender,"5");
        pot = order.takerPot;
        fee = 0;
        if(allowedTokens[order.tokenCode]._address != matchContract){
          fee = pot.mul(PROVIDER_FEE).div(DIVIDER);
        }

        pot = pot.sub(fee).add(order.makerPot);

        if(fee > 0){
          if(referrer != address(0)){
            uint256 rFee = fee.mul(REFERRAL_FEE).div(DIVIDER);
            fee = fee.sub(rFee);
            reffSystem[referrer][order.tokenCode].claimable = reffSystem[referrer][order.tokenCode].claimable.add(rFee);
          }
       }

        emit Claimed(msg.sender, order.orderId, pot);
        order.makerClaimed=true;

        if(fee>0){
          bep20.transfer(providerAddress,fee);
        }
        
        bep20.transfer(msg.sender,pot);
        
        return true;

      }else if(order.winner == TAKER_WIN){
        require(order.takerSide == msg.sender,"6");
        pot = order.makerPot;
        fee = 0;
        if(allowedTokens[order.tokenCode]._address != matchContract){
          fee = pot.mul(PROVIDER_FEE).div(DIVIDER);
        }

        pot = pot.sub(fee).add(order.takerPot);
        if(fee > 0){
          if(referrer != address(0)){
            uint256 rFee = fee.mul(REFERRAL_FEE).div(DIVIDER);
            fee = fee.sub(rFee);
            reffSystem[referrer][order.tokenCode].claimable = reffSystem[referrer][order.tokenCode].claimable.add(rFee);
          }
        }

        emit Claimed(msg.sender,order.orderId, pot);
        order.takerClaimed=true;

        if(fee>0){
          bep20.transfer(providerAddress,fee);
        }
        
        bep20.transfer(msg.sender,pot);
        
        return true;

      }

    }else if (order.status == BOTH_WIN){
      require(order.winner == BOTH_WIN ,"7");
      if(order.makerSide == msg.sender){
        require(!order.makerClaimed ,"8");
        order.makerClaimed = true;
        emit Claimed(msg.sender,order.orderId, order.makerPot);
        bep20.transfer(msg.sender,order.makerPot);
        return true;
        
      }else if(order.takerSide == msg.sender){
        require(!order.takerClaimed,"9");
        order.takerClaimed = true;
        emit Claimed(msg.sender,order.orderId, order.takerPot);
        bep20.transfer(msg.sender,order.takerPot);
        return true;
      }
    }

    return false;
  }


  function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
  }

   /// @notice setting result of the match
  /// @param winner set the winner side (taker or maker)
  /// @param groupId identifier of the group
  /// @return status of setting of the match result
  function setMatchResult(bool winner,bytes32 groupId) public returns(bool){
    require(msg.sender == refereeAddress,"1");
    uint length = orderGroups[groupId].length;
    require(length >0, "4");
    for(uint i = 0 ; i < length ; i ++){
      Order storage order = orders[orderGroups[groupId][i]];

      require(order.matchId>0,"5");
      require(order.status == 0,"6");
      require(order.startTime+7200 < block.timestamp, "7"); //total 45 mins first half, 15 mins break, 45 mins second half, 15 mins of extra time 
      order.status = 1;
      if(winner){
          order.winner = TAKER_WIN;
         
      }else{
          order.winner = MAKER_WIN;
      }
    }
    
    emit MatchSettled(groupId);
    return length>0?true:false;
  }

  /// @notice cancelling the match due to unexpected event
  /// @param groupId identifier of the group
  function cancelByOrderGroup(bytes32 groupId) public{

    uint256 length = orderGroups[groupId].length;

    for(uint256 i = 0 ; i < length ; i ++){
      Order storage order = orders[orderGroups[groupId][i]];
      require(order.startTime>0,"1");
      uint256 currTime = block.timestamp-(24*3600); //24 hours waiting time. will be written in FAQ

      require(order.status == 0 ,"2");
      require((msg.sender == order.takerSide) || (msg.sender == order.makerSide) || (msg.sender == refereeAddress),"3");

      if(msg.sender == refereeAddress){
        require(block.timestamp > order.startTime+14400,"4");
      }else{
          require(currTime > order.startTime+7200,"5");
      }
       order.status = BOTH_WIN;
       order.winner = BOTH_WIN;
    }

   
  }
  
  /// @notice cancelling the match due to unexpected event
  /// @param _orderId identifier of the order
  function cancel(uint64 _orderId) public{

    require(orders[_orderId].startTime>0,"Invalid Match");
    uint256 currTime = block.timestamp-(24*3600); //24 hours waiting time. will be written in FAQ
    Order storage _order = orders[_orderId];

    require(_order.status == 0 ,"Invalid Match");
    require((msg.sender == _order.takerSide) || (msg.sender == _order.makerSide) || (msg.sender == refereeAddress),"You're not allowed to do this");

    if(msg.sender == refereeAddress){
      require(block.timestamp > _order.startTime+14400,"Cancel Failed. Invalid Time (Ref)");
    }else{
          require(currTime > _order.startTime+6300,"Cancel Failed. Invalid Time");
    }
     _order.status = 100;
     _order.winner = 100;
  }

  function addToken(address token,uint64 code,uint256 minimumBet) public onlyOwner{
    allowedTokens[code]._address = token;
    allowedTokens[code].bep20 = IBEP20(allowedTokens[code]._address);
    allowedTokens[code]._MINIMUM_BET = minimumBet;
  }

  function removeToken(uint64 code)public onlyOwner{
    allowedTokens[code]._address = address(0);
  }

  function setReferee(address _refereeAddress) public onlyOwner{
    refereeAddress = _refereeAddress;
  }

   function setProviderAddress(address _providerAddress) public onlyOwner{
    providerAddress = _providerAddress;
  }

}