/**
 *Submitted for verification at BscScan.com on 2022-11-03
*/

pragma solidity 0.8.17;


library SafeMath {
  /**
   * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
   * - Addition cannot overflow.
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  /**
   * @dev Returns the multiplication of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `*` operator.
   *
   * Requirements:
   * - Multiplication cannot overflow.
   */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts with custom message when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}


contract BetProfitBSC is ReentrancyGuard{
  using SafeMath for uint256;

    struct gameTx { 
        uint256 assetId;
        address player;
        uint256 betAmount;
        bool bull;
        uint256 startedAt;
        uint256 minutesToPlay;
        bool evaluated;
        bool refunded;
        bool won;
    }

    event NewGame(uint256 gameId,uint256 assetId,address player,uint256 betAmount,bool bull,uint256 startedAt,uint256 minutesToPlay);

    mapping(uint256=>gameTx) games;
    mapping(uint256=>bool) gameAllowed;
    mapping(uint256=>bool) assetAllowed;
    mapping(address=>uint256) myCurrentGame;
    mapping(address=>bool) hasGameInProgress;

    address public owner=0x7650F39bA8D036b1f7C7b974a6b02aAd4B7F71F7;
    address public oracle=0x2432110099C0F034854389444829F7Bdca4eBf05;

    uint256 minimumBetAmount=0.01 ether;
    uint256 payout=195;


    uint256 gameId=0;
    bool gameEnabled=true;

    receive() external payable {
        // nothing to do
    }

    function currentGameId() public view returns(uint256){
        return gameId;
    }

    function enableGame() public{
        require(msg.sender==owner);
        gameEnabled=true;
    }
    function disableGame() public{
        require(msg.sender==owner);
        gameEnabled=false;
    }
    function readGame(uint256 id) public view returns(gameTx memory){
        return games[id];
    }

    function modifyMinBet(uint256 amt) public{
        require(msg.sender==owner);
        minimumBetAmount=amt;
    }

    function modifyOwner(address newowner) public{
        require(msg.sender==owner);
        owner=newowner;
    }
    function modifyOracle(address neworacle) public {
        require(msg.sender==owner);
        oracle=neworacle;
    }    
    function modifyPayout(uint256 newPayout) public {
        require(msg.sender==owner);
        payout=newPayout;
    }
    function allowGame(uint256 mins) public  {
        require(msg.sender==owner);
        gameAllowed[mins]=true;
    }
    function disallowGame(uint256 mins) public  {
        require(msg.sender==owner);
        gameAllowed[mins]=false;   
    }
    function allowAsset(uint256 mins) public  {
        require(msg.sender==owner);
        assetAllowed[mins]=true;
    }
    function disallowAsset(uint256 mins) public  {
        require(msg.sender==owner);
        assetAllowed[mins]=false;   
    }    

    function withdrawFunds(uint256 amount) public nonReentrant {
        require(msg.sender==owner);
        payable(owner).transfer(amount);
    }

    function evaluate(uint256 id) public nonReentrant {
        require(msg.sender==oracle);
        require(!games[id].evaluated,"Game already evaluated");
        require(!games[id].refunded,"Game refunded");
        require(hasGameInProgress[games[id].player],"Player does not have a game in progress");
        hasGameInProgress[games[id].player]=false;
        games[id].evaluated=true;
    }

    function isEvaluated(uint256 id) public view returns(bool){
        return games[id].evaluated;
    }

    function refund(uint256 id) public nonReentrant {
        require(msg.sender==games[id].player,"Not your game");
        require(!games[id].evaluated,"Game already evaluated");
        require(hasGameInProgress[games[id].player],"Player does not have a game in progress");
        hasGameInProgress[games[id].player]=false;
        games[id].refunded=true;
        payable(games[id].player).transfer(SafeMath.mul(SafeMath.div(games[id].betAmount,100),50));
    }    

    function isRefunded(uint256 id) public view returns(bool){
        return games[id].refunded;
    }

    function hasGame(address user) public view returns(bool){
        return hasGameInProgress[user];
    }

    function readUsersGame(address user) public view returns(uint256){
        return myCurrentGame[user];
    }

    function sendPayout(uint256 id) public nonReentrant {
        require(msg.sender==oracle);
        require(!games[id].evaluated,"Game already evaluated");
        require(!games[id].refunded,"Game refunded");
        require(hasGameInProgress[games[id].player],"Player does not have a game in progress");
        games[id].evaluated=true;
        games[id].won=true;
        hasGameInProgress[games[id].player]=false;
        payable(games[id].player).transfer(SafeMath.mul(SafeMath.div(games[id].betAmount,100),payout));
    }

    function isWin(uint256 id) public view returns(bool){
        return games[id].won;
    }

    function goBull(uint256 asset,uint256 mins) public payable nonReentrant {
        require(gameEnabled,"Game disabled");
        require(!hasGameInProgress[msg.sender],"Game already in progress");
        require(msg.value>=minimumBetAmount,"Bet too small");
        require(gameAllowed[mins],"Timeframe not allowed");
        require(assetAllowed[asset],"Asset not allowed");
        games[gameId].assetId=asset;
        games[gameId].player=msg.sender;
        games[gameId].betAmount=msg.value;
        games[gameId].bull=true;
        games[gameId].startedAt=block.timestamp;
        games[gameId].minutesToPlay=mins;
        myCurrentGame[msg.sender]=gameId;
        hasGameInProgress[msg.sender]=true;
        gameId++;
    }

    function goBear(uint256 asset,uint256 mins) public payable nonReentrant {
        require(gameEnabled,"Game disabled");
        require(!hasGameInProgress[msg.sender],"Game already in progress");
        require(msg.value>=minimumBetAmount,"Bet too small");
        require(gameAllowed[mins],"Timeframe not allowed");
        require(assetAllowed[asset],"Asset not allowed");
        games[gameId].assetId=asset;
        games[gameId].player=msg.sender;
        games[gameId].betAmount=msg.value;
        games[gameId].bull=false;
        games[gameId].startedAt=block.timestamp;
        games[gameId].minutesToPlay=mins;
        myCurrentGame[msg.sender]=gameId;
        hasGameInProgress[msg.sender]=true;
        gameId++;
    }    
    

}