/**
 *Submitted for verification at BscScan.com on 2022-02-01
*/

//
// ████████╗██████╗ ███████╗ █████╗ ███████╗██╗   ██╗██████╗ ███████╗    ██████╗ ██╗      ██████╗ ██╗  ██╗
// ╚══██╔══╝██╔══██╗██╔════╝██╔══██╗██╔════╝██║   ██║██╔══██╗██╔════╝    ██╔══██╗██║     ██╔═══██╗╚██╗██╔╝
//    ██║   ██████╔╝█████╗  ███████║███████╗██║   ██║██████╔╝█████╗      ██████╔╝██║     ██║   ██║ ╚███╔╝
//    ██║   ██╔══██╗██╔══╝  ██╔══██║╚════██║██║   ██║██╔══██╗██╔══╝      ██╔══██╗██║     ██║   ██║ ██╔██╗
//    ██║   ██║  ██║███████╗██║  ██║███████║╚██████╔╝██║  ██║███████╗    ██████╔╝███████╗╚██████╔╝██╔╝ ██╗
//    ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝    ╚═════╝ ╚══════╝ ╚═════╝ ╚═╝  ╚═╝
//                          THE WORLDS FIRST METAVERSGE TREASURE HUNT ADVENTURE!
//

//SPDX-License-Identifier: MIT

pragma solidity 0.8.1;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

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

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
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

////////////////////////////////////// B Game Local and Riddles /////////////////////////////////////////

contract GSB {

    using SafeMath for uint256;


    mapping(address => bool) public contractAccess;
    address public _owner;

    /////////////////////////
    mapping(uint => uint) public totalumberOfTries;
    mapping(uint => uint) public queEndsLastAttemptGlobal;
    mapping(uint => address) public walletFrontOfQueLastAttemptGlobal;
    ////////////////////////////

    struct Time {
      uint id;
      address userAddress;
      uint256 deadline;
      string userName;
      uint gamesTries;
      }

    mapping(uint => mapping(uint => Time)) public allGames;

    // Head start time lock func start
    uint public _headStartTime;
    uint public _timeNow;
    // Head start time lock func End

    // ENTER HUNT Start
    struct Entrants {
      uint huntId;
      bool entered;
      uint headStartTime;
      bool gameLive;
      }
      
    // partner id game id
    mapping(address => mapping(uint => mapping(uint => Entrants))) public huntEntries;

    mapping(uint => mapping(uint => uint)) public numberOfEntries;


    ////////////////////////////
    bool public EnterHuntentered;
    uint public _EnterHuntheadStartTime;
    bool public _EnterHuntgameLive;
    ////////////////////////////

    // Set Winner Info
    struct Winners {
       address winningAddress;
       bool treasurefound;
       uint256 winningPrize;
    }

   mapping(uint => mapping(uint => Winners)) public Pot1AnsweredCorrectly;

    ////////////////////////////
    // Need to include a points value mapping > (game) uint to a (level) uint and uint value for each game
    ////////////////////////////

    // SUBMIT SECRET
    bool public SubmitSecretcurrentGameLive;
    bool public SubmitSecretpayment;
    // Step 1 confirm answer is solved and matching incoming hash
    bytes32 public SubmitSecrethashedCheckSolved;
    bool public SubmitSecretincorrect;

    bytes32 public SubmitSecretanswer;

    // chack the sender is the msg sender and that the hashes match
    bytes32 public SubmitSecrethashedResult1;

    uint public SubmitSecretcurrentGamePrize;

    bytes32 public SubmitLevelSecretanswer;
    bytes32 public SubmitSecrethashedLevelResult;

    uint256 public part0;
    uint256 public part1;
    uint256 public part2;

    //partnerid -  Mapping of addresses to their balances
    mapping(uint => mapping(address => uint)) public BNBbalance;

    // SUBMIT SECRET
    event submitSecretFailEvent(
         uint indexed _partnerId,
         uint indexed _treasureGameid,
         bool indexed _inccorect
        );

    

    /**
     * @dev sets token to be used for game
     */

    // OWNER
    constructor() public {

        require(_owner == address(0), "Already initalized"); //IMPORTANT

         _owner = msg.sender;
  
    }



    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return (msg.sender == _owner);
    }

    // ACCESS

    function setAccess(address _address) public onlyOwner {
        contractAccess[_address] = true;
    }

    function accessContract() public view returns (bool) {
        return (true == contractAccess[msg.sender]);
    }

    modifier permission() {
        require(accessContract(), "Caller has no access!");
        _;
    }

    function setTotalumberOfTries(uint256 _pID) external permission {
        totalumberOfTries[_pID] += 1;
    }

    function setQueEndsLastAttemptGlobal(uint256 _pID,uint _queEndsLastAttemptGlobal) external permission {
        queEndsLastAttemptGlobal[_pID] = _queEndsLastAttemptGlobal;
    }

    function setWalletFrontOfQueLastAttemptGloball(uint256 _pID,address _walletFrontOfQueLastAttemptGlobal) external permission {
        walletFrontOfQueLastAttemptGlobal[_pID] = _walletFrontOfQueLastAttemptGlobal;
    }

    function setHeadStartTimes(uint headStartTime) external permission {
        _headStartTime = headStartTime;
    }

    function setTimeNow(uint timeNow) external permission {
        _timeNow = timeNow;
    }

    function setNumberOfEntries(uint256 _pID,uint _gameId,uint _increase) external permission {
        numberOfEntries[_pID][_gameId] += _increase;
    }

    function setEnterHuntentered(bool _enterHuntentered) external permission {
        EnterHuntentered = _enterHuntentered;
    }

    function setEnterHuntheadStartTime(uint EnterHuntheadStartTime) external permission {
        _EnterHuntheadStartTime = EnterHuntheadStartTime;
    }

    function setEnterHuntgameLive(bool EnterHuntgameLive) external permission {
        _EnterHuntgameLive = EnterHuntgameLive;
    }

    function setSubmitSecretcurrentGameLive(bool _SubmitSecretcurrentGameLive) external permission {
            SubmitSecretcurrentGameLive = _SubmitSecretcurrentGameLive;
    }

    function setSubmitSecretpayment(bool _SubmitSecretpayment) external permission {
            SubmitSecretpayment = _SubmitSecretpayment;
    }

    function setSubmitSecrethashedCheckSolved(bytes32 _SubmitSecrethashedCheckSolved) external permission {
            SubmitSecrethashedCheckSolved = _SubmitSecrethashedCheckSolved;
    }


    function setFailEvent(uint256 _pID,uint _huntId) external permission {
            emit submitSecretFailEvent(_pID,_huntId,true);
    }


    function setSubmitSecretincorrect(bool _SubmitSecretincorrect) external permission {
            SubmitSecretincorrect = _SubmitSecretincorrect;
    }

    function setSubmitSecretanswer(bytes32 _SubmitSecretanswer) external permission {
            SubmitSecretanswer = _SubmitSecretanswer;
    }

    function setSubmitSecrethashedResult1(bytes32 _SubmitSecrethashedResult1) external permission {
            SubmitSecrethashedResult1 = _SubmitSecrethashedResult1;
    }

    function setSubmitSecretcurrentGamePrize1(uint _SubmitSecretcurrentGamePrize) external permission {
            SubmitSecretcurrentGamePrize = _SubmitSecretcurrentGamePrize;
    }

    // payment vars

    function setPart0(uint256 _part0) external permission {
        part0 = _part0;
    }

    function setPart1(uint256 _part1) external permission {
        part1 = _part1;
    }

    function setPart2(uint256 _part2) external permission {
        part2 = _part2;
    }

    function setSubmitLevelSecretanswer(bytes32 _SubmitLevelSecretanswer) external permission {
        SubmitLevelSecretanswer = _SubmitLevelSecretanswer;
    }

    function setSubmitSecrethashedLevelResult(bytes32 _SubmitSecrethashedLevelResult) external permission {
        SubmitSecrethashedLevelResult = _SubmitSecrethashedLevelResult;
    }

    function setBNBbalance(uint256 _pID,address _address,uint256 _value) external permission {
        BNBbalance[_pID][_address] += _value;
    }

    function setTimeItemsTries(uint256 _pID,uint256 _gameId) external permission {
        allGames[_pID][_gameId].gamesTries += 1;
    }

    function getTimeItemsTries(uint256 _pID,uint256 _gameId) external permission returns(uint256 deadline){
        return allGames[_pID][_gameId].gamesTries;
    }

    function getDeadline(uint256 _pID,uint _huntId) external permission returns(uint256 deadline) {
        return (allGames[_pID][_huntId].deadline);
    }

    // Get and Set Time
    function setTime(uint256 _pID,uint _gameId,address _userAddress,uint256 _deadline,string memory _userName,uint _gamesTries) external permission {
        allGames[_pID][_gameId] = Time(_gameId,_userAddress,_deadline,_userName,_gamesTries);
    }

    function getTime(uint256 _pID,uint _huntId) external permission returns(uint id,address userAddress,uint256 deadline,string memory userName,uint gamesTries) {
        return (allGames[_pID][_huntId].id,allGames[_pID][_huntId].userAddress,allGames[_pID][_huntId].deadline,allGames[_pID][_huntId].userName,allGames[_pID][_huntId].gamesTries);
    }

    function getTimeUserAddress(uint256 _pID,uint _huntId) external permission returns(address userAddress) {
        return allGames[_pID][_huntId].userAddress;
    }

    // Set and Get Hunt Entries
    function setHuntEntries(uint256 _pID,address _address,uint _huntId,bool _entered,uint _headStartTime,bool _gameLive) external permission {
        huntEntries[_address][_pID][_huntId] = Entrants(_huntId,_entered,_headStartTime,_gameLive);
    }

    function getHuntEntries(uint256 _pID,address _address,uint _huntId) external permission returns(uint huntId,bool entered,uint headStartTime,bool gameLive) {
            return (huntEntries[_address][_pID][_huntId].huntId,huntEntries[_address][_pID][_huntId].entered,huntEntries[_address][_pID][_huntId].headStartTime,huntEntries[_address][_pID][_huntId].gameLive);
    }

    function getUserEntered(uint256 _pID,address _address,uint _huntId) external permission returns(bool entered) {
            return huntEntries[_address][_pID][_huntId].entered;
    }

    // Set and Get Pot Answered Correctly
    function setPot1AnsweredCorrectly(uint256 _pID,uint _gameId,address _winningAddress,bool _treasurefound,uint256 _winningPrize) external permission {
        Pot1AnsweredCorrectly[_pID][_gameId] = Winners(_winningAddress,_treasurefound,_winningPrize);
    }

    function getPot1AnsweredCorrectly(uint256 _pID,uint _gameId) external permission returns(address winningAddress,bool treasurefound,uint256 winningPrize) {
        return (Pot1AnsweredCorrectly[_pID][_gameId].winningAddress,Pot1AnsweredCorrectly[_pID][_gameId].treasurefound,Pot1AnsweredCorrectly[_pID][_gameId].winningPrize);
    }

}

////////////////////////////////////// C Global Teams and Leaderboards /////////////////////////////////////////


contract GSC {

    using SafeMath for uint256;

    address public _owner;
    mapping(address => bool) public contractAccess;

    // Game Teams

    struct EnterantLeader {
      uint256 huntId;
      address usersAddress;
      bool entered;
      string username;
      uint points;
      uint stage;
      uint team;
    }

    mapping(uint => mapping(uint => mapping(uint => EnterantLeader))) public leaderboard;

    struct EnterantLeaderForCount{
      uint256 huntId;
      address usersAddress;
      bool entered;
      string username;
      uint points;
      uint stage;
      uint team;
    }

    mapping(address => mapping(uint => mapping(uint => EnterantLeaderForCount))) public leaderboardAddressMapping;

    mapping(uint256 => mapping(uint256 => uint)) public lengthEntrantLeaderbaord;

     // Level level details

    struct Level {
       uint id;
       bool live;
       bytes32 questionHash;
       uint256 costToEnter;
       uint256 submitSecretCost;
       uint256 entryLimit;
    }
    //Game ID - Level Number
    mapping (uint => mapping(uint => mapping(uint => Level))) public LevelMapping;


    struct TeamPoints {
       uint256 teamid;
       uint256 teamPointsTarget;
       uint256 ppp;
       uint256 teamEntries;
       uint256 teamActualPoints;
    }

    // partner Game id team id
    mapping (uint256 => mapping(uint256 => mapping(uint256 => TeamPoints))) public TeamDetails;



    // OFFICIAL SET GAME
     struct Game {
        bool live;
        uint256 prize;
        bytes32 questionHash;
        uint256 costToEnter;
        string riddle;
        uint256 headStartTime;
     }

     mapping (uint => mapping (uint => Game)) public Games;



    /**
     * @dev sets token to be used for game
     */

    // OWNER
    constructor() public {

        require(_owner == address(0), "Already initalized"); //IMPORTANT

         _owner = msg.sender;

    
    }


    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return (msg.sender == _owner);
    }

    // ACCESS

    function setAccess(address _address) public onlyOwner {
        contractAccess[_address] = true;
    }

    function accessContract() public view returns (bool) {
        return (true == contractAccess[msg.sender]);
    }

    modifier permission() {
        require(accessContract(), "Caller has no access!");
        _;
    }

    function setLengthEntrantLeaderbaord(uint256 _pID,uint256 _huntId,uint _value) external permission {
       lengthEntrantLeaderbaord[_pID][_huntId] = _value;
   }

    //    TreasureHunt TimeLock Update - increasing users points and levels from time lock
    function setTimeLockUpdate(uint256 _pID,address _usersAddress,uint256 _huntId,uint _userLoc,string memory _userName,uint256 _rank) external permission {

            leaderboardAddressMapping[_usersAddress][_pID][_huntId].points += (1*(_rank+1));
            leaderboard[_pID][_huntId][_userLoc].points += (1*(_rank+1));
            TeamDetails[_pID][_huntId][leaderboardAddressMapping[_usersAddress][_pID][_huntId].team].teamActualPoints += (1*(_rank+1));
            leaderboardAddressMapping[_usersAddress][_pID][_huntId].username = _userName;
            leaderboard[_pID][_huntId][_userLoc].username = _userName;
    }


    //    Leaderboard Updates
    function setUsersEntered(uint256 _pID,address _usersAddress,uint256 _huntId,uint _userLoc,bool _value) external permission {
       leaderboardAddressMapping[_usersAddress][_pID][_huntId].entered = _value;
       leaderboard[_pID][_huntId][_userLoc].entered = _value;
   }
   function setUsersUsername(uint256 _pID,address _usersAddress,uint256 _huntId,uint _userLoc,string memory _value) external permission {
       leaderboardAddressMapping[_usersAddress][_pID][_huntId].username = _value;
       leaderboard[_pID][_huntId][_userLoc].username = _value;
   }


   function setUsersPoints(uint256 _pID,address _usersAddress,uint256 _huntId,uint _userLoc,uint _value,bool _add,uint256 _rank) external permission {
       if (_add) {
            leaderboardAddressMapping[_usersAddress][_pID][_huntId].points += (_value*(_rank+1));
            leaderboard[_pID][_huntId][_userLoc].points += (_value*(_rank+1));
        } else if ((leaderboardAddressMapping[_usersAddress][_pID][_huntId].points - (_value)) >= 0) {
            leaderboardAddressMapping[_usersAddress][_pID][_huntId].points -= (_value*(_rank+1));
            leaderboard[_pID][_huntId][_userLoc].points -= (_value*(_rank+1));
        } else {

        }
   }

   function setUsersStage(uint256 _pID,address _usersAddress,uint256 _huntId,uint _userLoc,uint _value,bool _add) external permission {

       if (_add) {
            leaderboardAddressMapping[_usersAddress][_pID][_huntId].stage = _value;
            leaderboard[_pID][_huntId][_userLoc].stage = _value;
        } else if ((leaderboardAddressMapping[_usersAddress][_pID][_huntId].stage - _value) >= 0) {
            leaderboardAddressMapping[_usersAddress][_pID][_huntId].stage = _value;
            leaderboard[_pID][_huntId][_userLoc].stage = _value;
        } else{

        }

    }

    function setTeamPoints(uint256 _pID,address _usersAddress,uint256 _huntId,uint _value,bool _add,uint256 _rank) external permission {
       if (_add) {
            TeamDetails[_pID][_huntId][leaderboardAddressMapping[_usersAddress][_pID][_huntId].team].teamActualPoints += (_value*(_rank+1));
        } else if ((TeamDetails[_pID][_huntId][leaderboardAddressMapping[_usersAddress][_pID][_huntId].team].teamActualPoints - (_value)) >= 0) {
            TeamDetails[_pID][_huntId][leaderboardAddressMapping[_usersAddress][_pID][_huntId].team].teamActualPoints += (_value*(_rank+1));
        } else {

        }
    }


    function setUsersTeam(uint256 _pID,address _usersAddress,uint256 _huntId,uint _userLoc,uint _value,bool _add) external permission {
       leaderboardAddressMapping[_usersAddress][_pID][_huntId].team = _value;
       leaderboard[_pID][_huntId][_userLoc].team = _value;
    }

    // Get and Set leaderboard
    function setLeaderboard(uint256 _pID,uint _num,uint256 _huntId,address _usersAddress,bool _entered,string memory _username,uint _tries,uint _stage,uint _team) external permission {
        leaderboard[_pID][_huntId][_num] = EnterantLeader(_huntId,_usersAddress, _entered, _username, _tries, _stage, _team);
    }

    function getLeaderboard(uint256 _pID,uint _huntId,uint _num) external permission returns(address usersAddress,bool entered,uint tries,uint stage,uint team) {
        return (leaderboard[_pID][_huntId][_num].usersAddress,leaderboard[_pID][_huntId][_num].entered,leaderboard[_pID][_huntId][_num].points,leaderboard[_pID][_huntId][_num].stage,leaderboard[_pID][_huntId][_num].team);
    }

    function getLeaderboardUserName(uint256 _pID,uint _huntId,uint _num) external permission returns(string memory username) {
        return (leaderboard[_pID][_huntId][_num].username);
    }

    // Get Users Team
    function getUsersTeam(uint256 _pID,uint _huntId,uint _num) external permission returns(uint team) {
        return (leaderboard[_pID][_huntId][_num].team);
    }

    // Set A New User In leaderboard
    function setATeam(uint256 _pID,uint _gameId,address _address,uint _team) external permission  {
        leaderboard[_pID][_gameId][lengthEntrantLeaderbaord[_pID][_gameId]+=1] = EnterantLeader(_gameId,_address,true,"New Explorer",0,0,_team);
        leaderboardAddressMapping[_address][_pID][_gameId] = EnterantLeaderForCount(_gameId,_address,true,"New Explorer",0,0,_team);
    }

    // Get and Set leaderboardAddressMapping
    function setLeaderboardAddressMapping(uint256 _pID,uint256 _huntId,address _usersAddress,bool _entered,string memory _username,uint _points,uint _stage,uint _team) external permission {
        leaderboardAddressMapping[_usersAddress][_pID][_huntId] = EnterantLeaderForCount(_huntId,_usersAddress,_entered,_username,_points,_stage,_team);
    }

    function getLeaderboardAddressMapping(uint256 _pID,uint256 _huntId,address _address) external permission returns(uint256 huntId,address usersAddress,bool entered,uint tries,uint stage,uint team) {
            // uint256 huntId,address usersAddress,bool entered,string username,uint tries,uint stage,uint team
            return (leaderboardAddressMapping[_address][_pID][_huntId].huntId,leaderboardAddressMapping[_address][_pID][_huntId].usersAddress,leaderboardAddressMapping[_address][_pID][_huntId].entered,leaderboardAddressMapping[_address][_pID][_huntId].points,leaderboardAddressMapping[_address][_pID][_huntId].stage,leaderboardAddressMapping[_address][_pID][_huntId].team);
    }

    function getLeaderboardAddressMappingUserName(uint256 _pID,uint256 _huntId,address _address) external permission returns(string memory username) {
            // uint256 huntId,address usersAddress,bool entered,string username,uint tries,uint stage,uint team
            return (leaderboardAddressMapping[_address][_pID][_huntId].username);
    }


    function getHuntIdLeaderboardAddressMapping(uint256 _pID,uint256 _huntId,address _address) external permission returns(uint256 huntId) {
            // uint256 huntId,address usersAddress,bool entered,string username,uint tries,uint stage,uint team
            return (leaderboardAddressMapping[_address][_pID][_huntId].huntId);
    }

    function getPointsLeaderboardAddressMapping(uint256 _pID,uint256 _huntId,address _address) external permission returns(uint256 points) {
            // uint256 huntId,address usersAddress,bool entered,string username,uint tries,uint stage,uint team
            return (leaderboardAddressMapping[_address][_pID][_huntId].points);
    }

    function getStageLeaderboardAddressMapping(uint256 _pID,uint256 _huntId,address _address) external permission returns(uint256 stage) {
            // uint256 huntId,address usersAddress,bool entered,string username,uint tries,uint stage,uint team
            return (leaderboardAddressMapping[_address][_pID][_huntId].stage);
    }

    // Get and Set Level
    function setLevel(uint256 _pID,uint _huntId,uint _level,bool _live,bytes32 _questionHash,uint256 _costToEnter,uint256 _submitSecretCost,uint256 _entryLimit) external permission {
        LevelMapping[_pID][_huntId][_level] = Level(_huntId,_live,_questionHash,_costToEnter,_submitSecretCost,_entryLimit);
    }

    function getLevel(uint256 _pID,uint _huntId,uint _level) external permission returns(bool live,bytes32 questionHash,uint256 costToEnter,uint256 submitSecretCost,uint256 entryLimit) {
            return (LevelMapping[_pID][_huntId][_level].live,LevelMapping[_pID][_huntId][_level].questionHash,LevelMapping[_pID][_huntId][_level].costToEnter,LevelMapping[_pID][_huntId][_level].submitSecretCost,LevelMapping[_pID][_huntId][_level].entryLimit);
    }

    function getLevelQuestionHash(uint256 _pID,uint _huntId,uint _level) external permission returns(bytes32 questionHash) {
            return LevelMapping[_pID][_huntId][_level].questionHash;
    }

    // Set and Get Team information
    function setTeamDetailsEntering(uint256 _pID,uint256 _gameId,uint256 _teamId) external permission {
            TeamDetails[_pID][_gameId][_teamId].ppp -= 1;
            TeamDetails[_pID][_gameId][_teamId].teamEntries +=1;
            TeamDetails[_pID][_gameId][_teamId].teamPointsTarget = TeamDetails[_pID][_gameId][_teamId].ppp * TeamDetails[_pID][_gameId][_teamId].teamEntries;
    }

    function ownerCreateNewTeam(uint256 _pID,uint _gameId,uint _teamId,uint256 _teamPPPStart) external permission {
      TeamDetails[_pID][_gameId][_teamId] = TeamPoints(_teamId,_teamPPPStart,_teamPPPStart,0,0);
    }

    function getTeamDetails(uint256 _pID,uint256 _gameId,uint256 _teamId) external permission returns(uint256,uint256,uint256,uint256,uint256) {
            return (TeamDetails[_pID][_gameId][_teamId].teamid,TeamDetails[_pID][_gameId][_teamId].teamPointsTarget,TeamDetails[_pID][_gameId][_teamId].ppp,TeamDetails[_pID][_gameId][_teamId].teamEntries,TeamDetails[_pID][_gameId][_teamId].teamActualPoints);
    }

    function getTeamActualPoints(uint256 _pID,uint256 _gameId,uint256 _teamId) external permission returns(uint256) {
            return (TeamDetails[_pID][_gameId][_teamId].teamActualPoints);
    }

    // Set and Get Game information
    function setGame(uint256 _pID,uint _gameId,bool _live,uint256 _prize,bytes32 _questionHash,uint256 _costToEnterBNB,string memory _riddle,uint256 _headStartTime) external permission {
        Games[_pID][_gameId] = Game(_live,_prize,_questionHash,_costToEnterBNB,_riddle,_headStartTime);
    }

    function getGames(uint256 _pID,uint256 _gameId) external permission returns(bool live,uint256 prize,bytes32 questionHash,uint256 costToEnterBNB,string memory riddle,uint256 headStartTime) {
            return (Games[_pID][_gameId].live,Games[_pID][_gameId].prize,Games[_pID][_gameId].questionHash,Games[_pID][_gameId].costToEnter,Games[_pID][_gameId].riddle,Games[_pID][_gameId].headStartTime);
    }

    // Set and Get Game information
    function setGameSmall(uint256 _pID,uint _gameId,bool _live,uint256 _prize,uint256 _costToEnterBNB) external permission {
        Games[_pID][_gameId].live = _live;
        Games[_pID][_gameId].prize = _prize;
        Games[_pID][_gameId].costToEnter = _costToEnterBNB;
    }

    function getGamesSmall(uint256 _pID,uint256 _gameId) external permission returns(bool live,uint256 prize,uint256 costToEnterBNB) {
            return (Games[_pID][_gameId].live,Games[_pID][_gameId].prize,Games[_pID][_gameId].costToEnter);
    }

    function getGamesFinalQuestionHash(uint256 _pID,uint256 _gameId) external permission returns(bytes32 questionHash) {
            return Games[_pID][_gameId].questionHash;
    }

    // Set BNB Entry Cost
    function setBNBEntry(uint256 _pID,uint _gameId,uint256 _cost) external permission {
        Games[_pID][_gameId].costToEnter = _cost;
    }

    function getTeamPointsCheck(uint256 _pID,uint _gameId,uint _teamId) external permission returns(bool) {
      if (TeamDetails[_pID][_gameId][_teamId].teamActualPoints >= TeamDetails[_pID][_gameId][_teamId].teamPointsTarget) {
      return true;
      }
    }

}

////////////////////////////////////// D Profile and Abilities /////////////////////////////////////////


contract GSD {

    using SafeMath for uint256;

    address public _owner;
    mapping(address => bool) public contractAccess;

    struct Player {
        uint256 rank;
        uint256 wins;
    }
    mapping (address => Player) public PlayerGlobalStats;

    struct PlayerGamesWon {
        uint256 gameId;
        uint256 winningTeamId;
    }
    // player - > Provider id
    mapping (address => mapping(uint256 => PlayerGamesWon)) public PlayerGamesTally;

    struct Abilities {
        string abilityName;
        address abilityAddress;
        uint256 abilityValue;
        uint256 abilityPos;
        uint256 abilityNeg;
    }

    mapping (address => mapping(uint256 => Abilities)) public PlayerGlobalAbalities;

    struct Profile {
        string userName;
        string telegram;
        string messageToWorld;
        address avitar;
        uint Invites;
    }

    mapping (address => Profile) public PlayerGlobalProfile;


    // Userchecklist

    struct PlayerCheckListItems {
        uint256 teamId;
        uint256 enteredHunt;
        uint256 playedQuest;
        uint256 playedRandomGame;
        uint256 usedTimeLock;
        uint256 spareOne;
        uint256 spareTwo;
    }
    
    // player - > Provider id - Game Id
    mapping (address => mapping(uint256 => mapping(uint256 => PlayerCheckListItems))) public PlayerCheckList;


    /**
     * @dev sets token to be used for game
     */

    // OWNER
    constructor() public {

        require(_owner == address(0), "Already initalized"); //IMPORTANT

         _owner = msg.sender;

    
    }


    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return (msg.sender == _owner);
    }

    // ACCESS

    function setAccess(address _address) public onlyOwner {
        contractAccess[_address] = true;
    }

    function accessContract() public view returns (bool) {
        return (true == contractAccess[msg.sender]);
    }

    modifier permission() {
        require(accessContract(), "Caller has no access!");
        _;
    }

    // Set and Get Game information
    function setPlayerGlobalAbalities(address _player,uint256 _abilityId,string memory abilityName,address abilityAddress,uint256 abilityValue,uint256 abilityPos,uint256 abilityNeg) external permission {
        PlayerGlobalAbalities[_player][_abilityId] = Abilities(abilityName, abilityAddress, abilityValue, abilityPos, abilityNeg);
    }

    function getPlayerGlobalAbalities(address _player,uint256 _abilityId) external permission returns(string memory abilityName,address abilityAddress,uint256 abilityValue,uint256 abilityPos,uint256 abilityNeg) {
            return (PlayerGlobalAbalities[_player][_abilityId].abilityName,PlayerGlobalAbalities[_player][_abilityId].abilityAddress,PlayerGlobalAbalities[_player][_abilityId].abilityValue,PlayerGlobalAbalities[_player][_abilityId].abilityPos,PlayerGlobalAbalities[_player][_abilityId].abilityNeg);
    }
    // Set and Get Game information
    function setPlayerGlobalProfile(address _player,string memory userName,string memory telegram,string memory messageToWorld,address avitar,uint Invites) external permission {
        PlayerGlobalProfile[_player] = Profile(userName,telegram,messageToWorld,avitar,Invites);
    }

    function getPlayerGlobalProfile(address _player) external permission returns(string memory userName,string memory telegram,string memory messageToWorld,address avitar,uint Invites) {
            return (PlayerGlobalProfile[_player].userName,PlayerGlobalProfile[_player].telegram,PlayerGlobalProfile[_player].messageToWorld,PlayerGlobalProfile[_player].avitar,PlayerGlobalProfile[_player].Invites);
    }

    // Set and Get Pot Answered Correctly
    function setPlayerStats(address _winningAddress,uint256 _providerId,uint256 _rankValue,uint256 _wins,uint256 _teamId,uint256 _gameId) external permission {
        PlayerGlobalStats[_winningAddress].rank += _rankValue;
        PlayerGlobalStats[_winningAddress].wins += _wins;
        PlayerGamesTally[_winningAddress][_providerId].winningTeamId = _gameId;
        PlayerGamesTally[_winningAddress][_providerId].winningTeamId = _teamId;
    }

    function getPlayerStats(address _winningAddress) external permission returns(uint256 _rank,uint256 _wins) {
        return (PlayerGlobalStats[_winningAddress].rank,PlayerGlobalStats[_winningAddress].wins);
    }

    function getPlayerRank(address _player) external permission returns(uint256 _rank) {
        return (PlayerGlobalStats[_player].rank);
    }

    function getPlayerGamesWon(address _player,uint256 _provider) external permission returns( uint256 gameId,uint256 winningTeamId) {
        return (PlayerGamesTally[_player][_provider].gameId,PlayerGamesTally[_player][_provider].winningTeamId);
    } 

    function setEnterHunt(address _address,uint256 _providerId,uint256 _value,uint256 _gameId,uint256 _teamId) external permission {
        PlayerCheckList[_address][_providerId][_gameId].enteredHunt += _value;
        PlayerCheckList[_address][_providerId][_gameId].teamId = _teamId;
    }

    function setPlayedQuest(address _address,uint256 _providerId,uint256 _value,uint256 _gameId) external permission {
        PlayerCheckList[_address][_providerId][_gameId].playedQuest += _value;
    }

    function setPlayedRandomGame(address _address,uint256 _providerId,uint256 _value,uint256 _gameId) external permission {
        PlayerCheckList[_address][_providerId][_gameId].playedRandomGame += _value;
    }

    function setUsedTimeLock(address _address,uint256 _providerId,uint256 _value,uint256 _gameId) external permission {
        PlayerCheckList[_address][_providerId][_gameId].usedTimeLock += _value;
    }

    function setSpareOne(address _address,uint256 _providerId,uint256 _value,uint256 _gameId) external permission {
        PlayerCheckList[_address][_providerId][_gameId].spareOne += _value;
    }

    function setSpareTwo(address _address,uint256 _providerId,uint256 _value,uint256 _gameId) external permission {
        PlayerCheckList[_address][_providerId][_gameId].spareTwo += _value;
    }



}

////////////////////////////////////// Enter Game Free Dev /////////////////////////////////////////


contract FREE_PLAY {

    using SafeMath for uint256;

    address _owner;

    GSB public gsb;
    GSC public gsc;
    GSD public gsd;
    VOLT public mr;

    uint public i;
    address public thisUserLocalAddress;

    IERC20 public _token;
    mapping(address => bool) public excludedFromTax;

    // @dev sets to be used for game and partner memory contract


    // @dev sets token to be used for game and partner memory contract
    constructor(GSB _addressGetsetGameB,GSC _addressGetsetGlobalTeamsC,GSD _addressGetsetPlayerInfoD,IERC20 partner_token,VOLT volt_contract) public {

        gsb = _addressGetsetGameB;
        gsc = _addressGetsetGlobalTeamsC;
        gsd = _addressGetsetPlayerInfoD;
        mr = volt_contract;

        _owner = msg.sender;
        _token = partner_token;
        excludedFromTax[msg.sender] = true;

    }

    function setBNB(uint256 _pID, uint _gameId,uint256 _costBNB) public onlyOwner {
        gsc.setBNBEntry(_pID,_gameId,_costBNB);
    }

    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return (msg.sender == _owner);
    }

    function enterGame(address _address,uint256 _pID,uint _gameId,uint _team) public onlyOwner {

            (bool live,uint256 prize,bytes32 questionHash,uint256 costToEnterBNB,string memory riddle,uint256 headStartTime) = gsc.getGames(_pID,_gameId);

            gsd.setEnterHunt(_address,_pID,1,_gameId,_team);
            // Add Person To Game
            enterHuntList(_address,_pID,_gameId,_team);

    }

    function localUserAddress(uint256 _pID,uint256 _huntId,uint256 _i) internal returns(address _usersAddress){
                    (uint256 _huntId,address usersAddress,bool entered,string memory username,uint tries,uint stage,uint team) = gsc.leaderboard(_pID,_huntId,_i);
                    (_usersAddress) = localUserAddressPart2( _pID,_huntId,usersAddress);
        return (_usersAddress);
    }

    function localUserAddressPart2(uint256 _pID,uint256 _huntId,address usersAddress) internal returns(address _usersAddress){
                    (uint256 _huntId,address _usersAddress,bool _entered,uint _tries,uint _stage,uint _team) = gsc.getLeaderboardAddressMapping(_pID,_huntId,usersAddress);
        return (_usersAddress);
    }

    function enterHuntList(address _address, uint256 _pID,uint _gameId,uint _team) internal {

        (bool live,uint256 prize,bytes32 questionHash,uint256 costToEnterBNB,string memory riddle,uint256 headStartTime) = gsc.getGames(_pID,_gameId);
        gsb.setHuntEntries(_pID,_address,_gameId,true,headStartTime,live);

        if (localUserAddressPart2( _pID,_gameId,_address)  != _address) {

            gsc.setATeam(_pID,_gameId,_address,_team);
            gsc.setTeamDetailsEntering(_pID,_gameId,_team);

            }

            gsb.setNumberOfEntries(_pID,_gameId,1);
    }
}


////////////////////////////////////// Main Game /////////////////////////////////////////

contract MAIN_GAME {

    using SafeMath for uint256;

    address _owner;

    GSB public gsb;
    GSC public gsc;
    GSD public gsd;
    VOLT public mr;

    uint public i;
    address public thisUserLocalAddress;

    IERC20 public _token;
    mapping(address => bool) public excludedFromTax;

    // @dev sets to be used for game and partner memory contract


    // @dev sets token to be used for game and partner memory contract
    constructor(GSB _addressGetsetGameB,GSC _addressGetsetGlobalTeamsC,GSD _addressGetsetPlayerInfoD,IERC20 partner_token,VOLT volt_contract) public {

        gsb = _addressGetsetGameB;
        gsc = _addressGetsetGlobalTeamsC;
        gsd = _addressGetsetPlayerInfoD;
        mr = volt_contract;

        _owner = msg.sender;
        _token = partner_token;
        excludedFromTax[msg.sender] = true;

    }

    function setBNB(uint256 _pID, uint _gameId,uint256 _costBNB) public onlyOwner {
        gsc.setBNBEntry(_pID,_gameId,_costBNB);
    }

    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return (msg.sender == _owner);
    }

    function headStartTimeLock(uint256 _pID,string memory _userName,uint256 _huntId) public payable {

        require(!gsc.getTeamPointsCheck(_pID,_huntId, 1),"Game Over");
        require(!gsc.getTeamPointsCheck(_pID,_huntId, 2),"Game Over");

        (uint huntId,bool entered,uint headStartTime,bool gameLive)  = gsb.getHuntEntries(_pID,msg.sender,_huntId);

        gsd.setUsedTimeLock(msg.sender,_pID,1,_huntId);

        // Check time now less than short list deadline
        if (block.timestamp < headStartTime){

            // check short list
            if (entered){

                timeLockTreasureHunt(_pID,_userName,_huntId);
            }

        }else {

            if (entered){

                timeLockTreasureHunt( _pID,_userName,_huntId);
            }
    }
    }
    function localUserAddress(uint256 _pID,uint256 _huntId,uint256 _i) internal returns(address _usersAddress){
                    (uint256 _huntId,address usersAddress,bool entered,string memory username,uint tries,uint stage,uint team) = gsc.leaderboard(_pID,_huntId,_i);
                    (_usersAddress) = localUserAddressPart2( _pID,_huntId,usersAddress);
        return (_usersAddress);
    }

    function localUserAddressPart2(uint256 _pID,uint256 _huntId,address usersAddress) internal returns(address _usersAddress){
                    (uint256 _huntId,address _usersAddress,bool _entered,uint _tries,uint _stage,uint _team) = gsc.getLeaderboardAddressMapping(_pID,_huntId,usersAddress);
        return (_usersAddress);
    }

    function timeLockTreasureHunt(uint256 _pID,string memory _userName,uint256 _huntId) internal {

      (bool live,uint256 prize,uint256 costToEnterBNB) = gsc.getGamesSmall(_pID,_huntId);
      (uint256 deadline) = gsb.getDeadline(_pID,_huntId);

      if (live == true) {

            if (deadline <= block.timestamp) {

                mr._token().transferFrom(msg.sender,mr.gamePotUsedForGames(),mr.CostToPlay());

                prize += mr.CostToPlay();
                gsc.setGameSmall(_pID,_huntId, live, prize, costToEnterBNB);
                gsb.setTimeItemsTries(_pID,_huntId);


                // // if the user address exsists in leader board update it with number of tries
                for(i = 1; i <= gsc.lengthEntrantLeaderbaord(_pID,_huntId);  i++) {

                        // check this with addresses etc
                        if (localUserAddress(_pID,_huntId,i) == msg.sender){
                            gsc.setTimeLockUpdate(_pID,localUserAddress(_pID,_huntId,i),_huntId,i,_userName,gsd.getPlayerRank(msg.sender));
                        }
                }

                gsb.setTime(_pID,_huntId,msg.sender,block.timestamp + 105 seconds,_userName,gsb.getTimeItemsTries(_pID,_huntId));
                gsb.setTotalumberOfTries(_pID);
                gsb.setQueEndsLastAttemptGlobal(_pID,deadline);
                gsb.setWalletFrontOfQueLastAttemptGloball(_pID,msg.sender);

            } else {

            }
        }
    }

    function enterGame(uint256 _pID,uint _gameId,uint _team) external payable {

        require(!gsc.getTeamPointsCheck(_pID,_gameId, 1),"Game Over");
        require(!gsc.getTeamPointsCheck(_pID,_gameId, 2),"Game Over");

        (bool live,uint256 prize,bytes32 questionHash,uint256 costToEnterBNB,string memory riddle,uint256 headStartTime) = gsc.getGames(_pID,_gameId);

        require(msg.value >= costToEnterBNB, "Insufficient balance.");
        payable(_owner).transfer(msg.value);

        // For Network Token Entry
        // gsb.setBNBbalance(_pID,msg.sender, msg.value);

        // For Tokens Entry
        // _token.transferFrom(msg.sender, _owner, msg.value);

        // Add user check list 
        gsd.setEnterHunt(msg.sender,_pID,1,_gameId,_team);

        // Add Person To Game
        enterHuntList( _pID,_gameId,_team);

    }

    function enterHuntList(uint256 _pID,uint _gameId,uint _team) internal {

        (bool live,uint256 prize,bytes32 questionHash,uint256 costToEnterBNB,string memory riddle,uint256 headStartTime) = gsc.getGames(_pID,_gameId);
        gsb.setHuntEntries(_pID,msg.sender,_gameId,true,headStartTime,live);

        if (localUserAddressPart2( _pID,_gameId,msg.sender)  != msg.sender) {

            gsc.setATeam(_pID,_gameId,msg.sender,_team);
            gsc.setTeamDetailsEntering(_pID,_gameId,_team);

            }

            gsb.setNumberOfEntries(_pID,_gameId,1);
    }
    
    function withdraw() onlyOwner public {
        payable(msg.sender).transfer(address(this).balance);
    }

    function addTeam(uint256 _pID,uint _gameId,uint256 _teamId,uint256 _teamPPPStart) onlyOwner public {
        gsc.ownerCreateNewTeam(_pID,_gameId,_teamId,_teamPPPStart);

    }

    function setTreasureHuntGame(uint256 _pID,uint _gameId,bool _live, uint256 _prize, bytes32 _submitQuestionHash,uint256 _costToEnterBNB,string memory _riddle,uint256 _headStartTime) public onlyOwner {
        gsc.setGame(_pID,_gameId,_live,_prize,_submitQuestionHash,_costToEnterBNB,_riddle,_headStartTime);
        gsb.setTime(_pID,_gameId,msg.sender,block.timestamp + 105 seconds,"Treasure Team Deployment",0);
    }

    function createLevel(uint256 _pID,uint _huntId,uint _level,bool _live,bytes32 _questionHash,uint256 _costToEnterToken,uint256 _submitSecretCost,uint256 _entryLimit) public onlyOwner {
                gsc.setLevel(_pID, _huntId, _level, _live, _questionHash, _costToEnterToken, _submitSecretCost, _entryLimit);
    }

    function makePaymentPlayQuest(uint256 _pID,uint _huntId) public payable returns(bool){

        require(!gsc.getTeamPointsCheck(_pID,_huntId, 1),"Game Over");
        require(!gsc.getTeamPointsCheck(_pID,_huntId, 2),"Game Over");

        (bool live,uint256 prize,bytes32 questionHash,uint256 costToEnterBNB,string memory riddle,uint256 headStartTime) = gsc.getGames(_pID,_huntId);

        if (live == true) {

            if(gsb.getUserEntered(_pID,msg.sender,_huntId) == true) {

                mr._token().transferFrom(msg.sender, mr.gamePotUsedForGames(),mr.CostToPlay());

                prize += mr.CostToPlay();
                gsc.setGame(_pID,_huntId, live, prize, questionHash, costToEnterBNB, riddle, headStartTime);

                gsd.setPlayedQuest(msg.sender,_pID,1,_huntId);

                for(i = 0; i <= gsc.lengthEntrantLeaderbaord(_pID,_huntId);  i++) {

                    if (localUserAddress(_pID,_huntId,i) == msg.sender){

                        gsc.setUsersPoints(_pID,msg.sender,_huntId,i,2,true,gsd.getPlayerRank(msg.sender));
                        gsc.setTeamPoints(_pID,msg.sender,_huntId,2,true,gsd.getPlayerRank(msg.sender));

                    }

                }

                return true;
            }

        }

    }

}

////////////////////////////////////// Volt /////////////////////////////////////////

// This will be the game pot contract
contract VOLT {

    using SafeMath for uint256;

    address _owner;

    GSB public gsb;
    GSC public gsc;
    GSD public gsd;
    VOLT public mr;

    uint public i;
    address public thisUserLocalAddress;

    address payable public gamePotUsedForGames;
    IERC20 public _token;
    mapping(address => bool) public excludedFromTax;

    mapping(address => bool) public approveRandomNumberGameContract;

    uint256 public CostToPlay;

    // @dev sets to be used for game and partner memory contract
    function setApproveRandGameContract(address payable _randGameContract,uint256 _tokenValue) onlyOwner public {
        approveRandomNumberGameContract[_randGameContract] = true;
        _token.approve(_randGameContract,_tokenValue);
    }


    // @dev sets to be used for game and partner memory contract
    function setMainGameWallet(address payable _gamePotUsedForGames) onlyOwner public {
        gamePotUsedForGames = _gamePotUsedForGames;
    }

    function setCostToPlay(uint _Cost) public onlyOwner {
            CostToPlay = _Cost;
    }

    // @dev sets token to be used for game and partner memory contract
    constructor(GSB _addressGetsetGameB,GSC _addressGetsetGlobalTeamsC,GSD _addressGetsetPlayerInfoD,IERC20 partner_token) public {

        gsb = _addressGetsetGameB;
        gsc = _addressGetsetGlobalTeamsC;
        gsd = _addressGetsetPlayerInfoD;

        _owner = msg.sender;
        _token = partner_token;
        excludedFromTax[msg.sender] = true;

    }

    function setThisAddress(VOLT riddle_contract) public onlyOwner {
        mr = riddle_contract;

    }

    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return (msg.sender == _owner);
    }

    function getBalance() onlyOwner public view returns (uint256) {
        return address(this).balance;
    }

    function withdraw() onlyOwner public {
        payable(msg.sender).transfer(address(this).balance);
    }

    // EMERGENCY ONLY
    function withdrawPrizePotDev(uint256 _amount) onlyOwner public {
        _token.transfer(msg.sender,_amount);
    }


    function localUserAddress(uint256 _pID,uint256 _huntId,uint256 _i) internal returns(address _usersAddress){
                    (uint256 _huntId,address usersAddress,bool entered,string memory username,uint tries,uint stage,uint team) = gsc.leaderboard(_pID,_huntId,_i);
                    (_usersAddress) = localUserAddressPart2( _pID,_huntId,usersAddress);
        return (_usersAddress);
    }

    function localUserAddressPart2(uint256 _pID,uint256 _huntId,address usersAddress) internal returns(address _usersAddress){
                    (uint256 _huntId,address _usersAddress,bool _entered,uint _tries,uint _stage,uint _team) = gsc.getLeaderboardAddressMapping(_pID,_huntId,usersAddress);
        return (_usersAddress);
    }

    function TeamCheck(uint256 _pID,uint _gameId,uint256 _teamId) public {

        if (gsc.getTeamPointsCheck(_pID, _gameId, _teamId)) {
            // set treasure hunt to false
            WinnersMain( _pID,bytes32("Team Win"),_gameId,_teamId);
        }
    }

    function WinnersMain(uint256 _pID,bytes32 SubmitSecretanswer,uint _huntId,uint256 _teamId) internal returns(bool){

        (address winningAddress,bool treasurefound,uint256 winningPrize) = gsb.getPot1AnsweredCorrectly(_pID,_huntId);
        (bool live,uint256 prize,bytes32 questionHash,uint256 costToEnterBNB,string memory riddle,uint256 headStartTime) = gsc.getGames(_pID,_huntId);

        if (treasurefound == false){

            if (winningAddress != msg.sender){

                gsc.setGame( _pID,_huntId, false, prize, questionHash, costToEnterBNB, riddle, headStartTime);
                gsb.setPot1AnsweredCorrectly(_pID,_huntId,msg.sender,true,prize);

                PayPlayers(_pID,_huntId,prize,msg.sender,_teamId);

                // return bool
                gsb.setFailEvent(_pID,_huntId);

                return false;

            }

        }
    }

    function PayPlayers(uint256 _pID,uint _gameId,uint _GamePrize,address _address,uint256 _teamId) internal returns(bool) {

            gsd.setPlayerStats(msg.sender,1,4,1,_teamId,_gameId);

            _token.transfer(msg.sender,_GamePrize.div(10).mul(3));

            for(i = 1; i <= gsc.lengthEntrantLeaderbaord(_pID,_gameId);  i++) {

                if (gsc.getUsersTeam(_pID,_gameId,i) == _teamId){

                    if (gsc.getHuntIdLeaderboardAddressMapping(_pID,_gameId,localUserAddress(_pID,_gameId,i)) == _gameId){

                        gsb.setPart0((gsc.getPointsLeaderboardAddressMapping(_pID,_gameId,localUserAddress(_pID,_gameId,i)).mul(100))/gsc.getTeamActualPoints(_pID,_gameId,_teamId));

                        gsb.setPart1(_GamePrize.div(10).mul(7));

                        gsb.setPart2((gsb.part1()*gsb.part0())/100);

                        _token.transfer(localUserAddress(_pID,_gameId,i),gsb.part2());

                        gsd.setPlayerStats(localUserAddress(_pID,_gameId,i),1,2,1,_teamId,_gameId);

                    }
                }
            }

        return true;
    }

    function makePaymentForSecret(uint256 _pID,uint _huntId) internal returns(bool){

        _token.transferFrom(msg.sender, gamePotUsedForGames,CostToPlay);

        (bool live,uint256 prize,bytes32 questionHash,uint256 costToEnter,string memory riddle,uint256 headStartTime) = gsc.getGames(_pID,_huntId);
        prize += CostToPlay;
        gsc.setGame( _pID,_huntId, live, prize, questionHash, costToEnter, riddle, headStartTime);

        return true;
    }

    function SubmitSecret(uint256 _pID,bytes32 hashedConfirm,string memory _answer,uint _huntId,string memory _winningMessage,uint256 _teamId) external payable {

        require(!gsc.getTeamPointsCheck(_pID,_huntId, 1),"Game Over");
        require(!gsc.getTeamPointsCheck(_pID,_huntId, 2),"Game Over");
        
        (bool live,uint256 prize,uint256 costToEnterBNB) = gsc.getGamesSmall(_pID,_huntId);
        (address userAddress) = gsb.getTimeUserAddress(_pID,_huntId);

            if (live == true) {

                if (userAddress == msg.sender){

                    // Payment for secret!
                    gsb.setSubmitSecretpayment(makePaymentForSecret(_pID,_huntId));


                    if (gsb.SubmitSecretpayment()) {

                        // Step 1 confirm answer is solved and matching incoming hash //#c4d31f
                        gsb.setSubmitSecrethashedCheckSolved(bytes32(keccak256(abi.encodePacked(bytes32(keccak256(abi.encodePacked(msg.sender))),bytes32(keccak256(abi.encodePacked(_answer)))))));

                        // check the question has been solved and that the incoming hashedConfirm are the same so things cant be changed. 196211..

                        if (gsb.SubmitSecrethashedCheckSolved() != hashedConfirm) {

                            // emit // emit id, prize and answer not solved the pot
                            gsb.setFailEvent(_pID,_huntId);

                        }

                        if (gsb.SubmitSecrethashedCheckSolved() == hashedConfirm){

                            if (gsc.getStageLeaderboardAddressMapping(_pID,_huntId,msg.sender) == 0){
                                gsb.setSubmitSecretanswer(gsc.getLevelQuestionHash(_pID,_huntId,1));
                            }

                            if (gsc.getStageLeaderboardAddressMapping(_pID,_huntId,msg.sender) == 1){
                                gsb.setSubmitSecretanswer(gsc.getLevelQuestionHash(_pID,_huntId,2));
                            }

                            if (gsc.getStageLeaderboardAddressMapping(_pID,_huntId,msg.sender) == 3){
                                gsb.setSubmitSecretanswer(gsc.getLevelQuestionHash(_pID,_huntId,4));
                            }

                            if (gsc.getStageLeaderboardAddressMapping(_pID,_huntId,msg.sender) == 4){
                                gsb.setSubmitSecretanswer(gsc.getLevelQuestionHash(_pID,_huntId,5));
                            }

                            if (gsc.getStageLeaderboardAddressMapping(_pID,_huntId,msg.sender) == 6){
                                gsb.setSubmitSecretanswer(gsc.getLevelQuestionHash(_pID,_huntId,7));
                            }

                            if (gsc.getStageLeaderboardAddressMapping(_pID,_huntId,msg.sender) == 7){
                                gsb.setSubmitSecretanswer(gsc.getLevelQuestionHash(_pID,_huntId,8));
                            }

                            if (gsc.getStageLeaderboardAddressMapping(_pID,_huntId,msg.sender) == 9){
                                gsb.setSubmitSecretanswer(gsc.getGamesFinalQuestionHash(_pID,_huntId));
                            }

                            

                            // chack the sender is the msg sender and that the hashes match - Life is an adventure
                            gsb.setSubmitSecrethashedResult1(bytes32(keccak256(abi.encodePacked(bytes32(keccak256(abi.encodePacked(msg.sender))),gsb.SubmitSecretanswer()))));

                            if (hashedConfirm != gsb.SubmitSecrethashedResult1()) {

                            // emit // emit id, prize and answer not solved the pot
                            gsb.setFailEvent(_pID,_huntId);

                            }

                          // WARNING // Need to check a level 3 cant resubmit a level 2 answer to win the pot!

                                if (hashedConfirm == gsb.SubmitSecrethashedResult1()) {

                                    for(i = 1; i <= gsc.lengthEntrantLeaderbaord(_pID,_huntId);  i++) {

                                        if (localUserAddress(_pID,_huntId,i) == msg.sender){

                                            // Get the person solving the clue and the game they are in

                                            uint _stage = gsc.getStageLeaderboardAddressMapping(_pID,_huntId,msg.sender);
                                            uint actual;
                                            uint _somePoints;
                                            bool notWin = false;
                                            
                                            _somePoints = 0;
                                            actual = 0;
                                            notWin = false;

                                            // rand 8 to 9

                                            if (_stage == 7) {
                                                actual = 8;
                                                _somePoints = 80;
                                                notWin = true;
                                            }

                                            if (_stage == 6) {
                                                actual = 7;
                                                _somePoints = 70;
                                                notWin = true;
                                            }
                                            
                                            // rand 5 to 6

                                            if (_stage == 4) {
                                                actual = 5;
                                                _somePoints = 50;
                                                notWin = true;
                                            }

                                            if (_stage == 3) {
                                                actual = 4;
                                                _somePoints = 40;
                                                notWin = true;
                                            }
                                            
                                            // rand 2 to 3

                                            if (_stage == 1) {
                                                actual = 2;
                                                _somePoints = 20;
                                                notWin = true;
                                            }

                                            if (_stage == 0) {
                                                actual = 1;
                                                _somePoints = 10;
                                                notWin = true;
                                            }

                                            if (_stage == 9) {
                                                WinnersMain(_pID,bytes32("User Win"),_huntId,_teamId);
                                            }

                                            if (notWin) {

                                                gsc.setUsersPoints(_pID,msg.sender,_huntId,i,_somePoints,true,gsd.getPlayerRank(msg.sender));
                                                gsc.setUsersStage(_pID,msg.sender,_huntId,i,actual,true);
                                                gsc.setTeamPoints(_pID,msg.sender,_huntId,_somePoints,true,gsd.getPlayerRank(msg.sender));

                                            }
                                            
                                        }

                                    }

                                // emit id, prize and answer not solved the pot
                                gsb.setFailEvent(_pID,_huntId);

                            }

                        }

                    }

                }

            }

        }
}

////////////////////////////////////// Random Games 1/4 /////////////////////////////////////////

contract RANDOMGAME1 {

    // Provide Access for this contract

    using SafeMath for uint256;

    address _owner;
    address _collection;

    GSB public gsb;
    GSC public gsc;
    GSD public gsd;
    VOLT public mr;
    
    address private access_address;


    uint public i;
    address public thisUserLocalAddress;

    address payable public gamePotUsedForGames;
    IERC20 public _token;
    mapping(address => bool) public excludedFromTax;



    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return (msg.sender == _owner);
    }

    uint256 private constant ROLL_IN_PROGRESS = 42;

    bytes32 private s_keyHash;
    uint256 private s_fee;

    mapping(bytes32 => address) private s_rollers;
    mapping(bytes32 => bool) private _numUsed;

    struct history {
        uint256 player_guess;
        uint256 actual_result;
        bool win;
        uint _huntId;
    }

    // Address of player - requesId - num the player choose
    mapping(address => mapping(bytes32 => history)) public player_history;

    // --------------------------------------------

    struct pending { 
        bool pending_waiting;
        bytes32 pending_requestIdhash;
        uint256 pending_player_guess;
        uint pending_huntId;
        uint256 pending_partnerId;
        uint256 time;
    }

    // Id of player 
    mapping(address => pending) internal player_pending;

    // -------------------------------------------- 


    mapping(address => uint256) private s_results;

    mapping(address => uint256) private user_guess;

    bool public win;
    bool public loss;
    bool public waiting;
    uint256 public result;

    event DiceRolled(bytes32 indexed s_keyHash, address indexed roller, uint256 indexed pID);
    event DiceLanded(bytes32 indexed requestId, uint256 indexed result,uint256 indexed pID);
    event Win(address indexed _player, uint256 indexed result,uint256 indexed pID);
    event Loss(address indexed _player, uint256 indexed result,uint256 indexed pID);

    // AggregatorV3Interface internal wingsBNB;

   

    constructor(bytes32 keyHash, uint256 fee,GSB _addressGetsetGameB,GSC _addressGetsetGlobalTeamsC,GSD _addressGetsetPlayerInfoD,IERC20 partner_token,VOLT volt_contract,address access,address _collectionAddress)

    {
        access_address = access;
        s_keyHash = keyHash;
        s_fee = fee;

        gsb = _addressGetsetGameB;
        gsc = _addressGetsetGlobalTeamsC;
        gsd = _addressGetsetPlayerInfoD;
        mr = volt_contract;

        _owner = msg.sender;
        _token = partner_token;
        excludedFromTax[msg.sender] = true;
        _collection = _collectionAddress;
        // main net
        // wingsBNB = AggregatorV3Interface(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);

        // testnet bnb usd
        // wingsBNB = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526);

    }


        /** !UPDATE
    *
    * Returns latest ETH/USD price from Chainlink oracles.
    */
    // function wingsInBNB() public view returns (int) {
    //     (uint80 roundId, int price, uint startedAt, uint timeStamp, uint80 answeredInRound) = wingsBNB.latestRoundData();

    //     return price;
    // }

    /** !UPDATE
    *
    * bnbUsd - latest price from Chainlink oracles (BNB in USD * 10**8).
    * weiUsd - USD in Wei, received by dividing:
    *          ETH in Wei (converted to compatibility with etUsd (10**18 * 10**8)),
    *          by ethUsd.
    */
    // function weiInBNB() public view returns (uint) {
    //     int bnbUsd = wingsInBNB();
    //     int weiBNB = 10**26/bnbUsd;

    //     return uint(weiBNB);
    // }
    

    function rollDice(uint256 _pID,address roller,uint256 _userGuess,uint _huntId) public returns (bytes32 requestId) {

        require(!gsc.getTeamPointsCheck(_pID,_huntId, 1),"Game Over");
        require(!gsc.getTeamPointsCheck(_pID,_huntId, 2),"Game Over");

        mr._token().transferFrom(msg.sender,mr.gamePotUsedForGames(),mr.CostToPlay()*3);
        mr._token().transferFrom(msg.sender,_collection,mr.CostToPlay()*3);

        // require(msg.value >= 10, "Minimum bonded amount hasn't been met,");

        // check player has entered...
        (uint huntId,bool entered,uint headStartTime,bool gameLive)  = gsb.getHuntEntries(_pID,msg.sender,_huntId);

        require(entered, "Not Entered!");
        require(_numUsed[requestId] != true, "Result already used");
        require((_userGuess >= 0 && _userGuess <= 3), "Number should be 0 to 9");

        // require(_token.transfer(address(this), mr.CostToPlay()), "Not enough Token");
        // require(_token.balanceOf(address(this)) >= mr.CostToPlay(), "Not enough Tokens to pay fee");

        require(s_results[roller] == 0, "Already rolled");

        // check player has entered...
        
        // custom hash
        requestId = bytes32(keccak256(abi.encodePacked(bytes32(keccak256(abi.encodePacked(roller))),block.timestamp,s_keyHash)));
        
        s_rollers[requestId] = roller;

        player_history[roller][requestId].player_guess = _userGuess;
        player_history[roller][requestId]._huntId = _huntId;

        s_results[roller] = ROLL_IN_PROGRESS;
        user_guess[roller] = _userGuess;

        // not required
        waiting = true;

        player_pending[roller] = pending(true,requestId,_userGuess,_huntId,_pID,block.timestamp + 90 seconds);

        // // Set view details  
        // player_pending[roller].pending_waiting = true;
        // player_pending[roller].pending_requestIdhash = requestId;
        // player_pending[roller].pending_player_guess = _userGuess;
        // player_pending[roller].pending_huntId = _huntId;
        // player_pending[roller].pending_partnerId = _pID;
        // player_pending[roller].time = block.timestamp + 90 seconds;

        gsd.setPlayedRandomGame(roller,_pID,1,_huntId);

        emit DiceRolled(requestId, roller,_pID);
        
    }

    function fulfillRandomness(uint256 _pID,bytes32 requestId, uint256 randomness) public payable onlyOwner {
        
        address _player = s_rollers[requestId];

        require(!gsc.getTeamPointsCheck(_pID,player_history[_player][requestId]._huntId, 1),"Game Over");
        require(!gsc.getTeamPointsCheck(_pID,player_history[_player][requestId]._huntId, 2),"Game Over");

        uint256 randomResult = (randomness % 4) + 1;

        verdict(_pID,randomResult,_player,requestId,player_history[_player][requestId]._huntId);

        player_history[_player][requestId].actual_result = randomResult;
        // Set completed details for address 
        player_pending[_player] = pending(false,0x0000000000000000000000000000000000000000000000000000000000000000,0,0,0,0);
        

        emit DiceLanded(requestId, randomResult,_pID);
    }

    function quickCheckResult(address _address) public view returns (bool,bytes32,uint256,uint,uint256) {
        if (player_pending[_address].time > block.timestamp){
           return (player_pending[_address].pending_waiting,player_pending[_address].pending_requestIdhash,player_pending[_address].pending_player_guess,player_pending[_address].pending_huntId,player_pending[_address].pending_partnerId);
        } else {
           return (false,player_pending[_address].pending_requestIdhash,player_pending[_address].pending_player_guess,player_pending[_address].pending_huntId,player_pending[_address].pending_partnerId);
        }

    }


    function verdict(uint256 _pID,uint256 random,address _player,bytes32 requestId,uint _huntId) public payable onlyOwner  {
    // check the state of the wallet address has it won?
        require(_numUsed[requestId] != true, "Result already used");
        _numUsed[requestId] = true;

        if (user_guess[_player] == random) {

            player_history[_player][requestId].win = true;

            for(i = 1; i <= gsc.lengthEntrantLeaderbaord(_pID,_huntId);  i++) {

                
                if (gsc.getStageLeaderboardAddressMapping(_pID,_huntId,_player) == 2) {
                    gsc.setUsersPoints(_pID,msg.sender,_huntId,i,30,true,gsd.getPlayerRank(msg.sender));
                    gsc.setUsersStage(_pID,msg.sender,_huntId,i,3,true);
                    gsc.setTeamPoints(_pID,msg.sender,_huntId,30,true,gsd.getPlayerRank(msg.sender));
                } else {
                    gsc.setUsersPoints(_pID,_player,_huntId,i,30,true,gsd.getPlayerRank(_player));
                    gsc.setTeamPoints(_pID,_player,_huntId,30,true,gsd.getPlayerRank(_player));
                
                }

            }

            win = true;
            loss = false;
            result = random;
            mr._token().transferFrom(mr.gamePotUsedForGames(),_player,mr.CostToPlay()*2);
            emit Win(_player, random, _pID);

            // mr._token().transfer(_player,mr.CostToPlay());

        } else {

            player_history[_player][requestId].win = false;

            

            win = false;
            loss = true;
            result = random;
            emit Loss(_player, random, _pID);


    }


    waiting = false;
    // can play again mapping once everything is paid
    s_results[_player] = 0;

    }

    /**
     * @notice Withdraw LINK from this contract.
     * @dev this is an example only, and in a real contract withdrawals should
     * happen according to the established withdrawal pattern:
     * https://docs.soliditylang.org/en/v0.4.24/common-patterns.html#withdrawal-from-contracts
     * @param to the address to withdraw LINK to
     * @param value the amount of LINK to withdraw
     */
    function withdrawToken(address to, uint256 value) public onlyOwner {      
        require(_token.transfer(to, value), "Not enough Token");
    }

    /**
     * @notice Set the key hash for the oracle
     *
     * @param keyHash bytes32
     */
    function setKeyHash(bytes32 keyHash) public onlyOwner {
        s_keyHash = keyHash;
    }

    /**
     * @notice Get the current key hash
     *
     * @return bytes32
     */
    function keyHash() public view returns (bytes32) {
        return s_keyHash;
    }

    /**
     * @notice Set the oracle fee for requesting randomness
     *
     * @param fee uint256
     */
    function setFee(uint256 fee) public onlyOwner {
        s_fee = fee;
    }

    /**
     * @notice Get the current fee
     *
     * @return uint256
     */
    function fee() public view returns (uint256) {
        return s_fee;
    }
}

////////////////////////////////////// Random Games 1/6 /////////////////////////////////////////

contract RANDOMGAME2 {

    // Provide Access for this contract

    using SafeMath for uint256;

    address _owner;
    address _collection;

    GSB public gsb;
    GSC public gsc;
    GSD public gsd;
    VOLT public mr;
    
    address private access_address;


    uint public i;
    address public thisUserLocalAddress;

    address payable public gamePotUsedForGames;
    IERC20 public _token;
    mapping(address => bool) public excludedFromTax;



    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return (msg.sender == _owner);
    }

    uint256 private constant ROLL_IN_PROGRESS = 42;

    bytes32 private s_keyHash;
    uint256 private s_fee;

    mapping(bytes32 => address) private s_rollers;
    mapping(bytes32 => bool) private _numUsed;

    struct history {
        uint256 player_guess;
        uint256 actual_result;
        bool win;
        uint _huntId;
    }

    // Address of player - requesId - num the player choose
    mapping(address => mapping(bytes32 => history)) public player_history;

    // --------------------------------------------

    struct pending { 
        bool pending_waiting;
        bytes32 pending_requestIdhash;
        uint256 pending_player_guess;
        uint pending_huntId;
        uint256 pending_partnerId;
        uint256 time;
    }

    // Id of player 
    mapping(address => pending) internal player_pending;

    // -------------------------------------------- 


    mapping(address => uint256) private s_results;

    mapping(address => uint256) private user_guess;

    bool public win;
    bool public loss;
    bool public waiting;
    uint256 public result;

    event DiceRolled(bytes32 indexed s_keyHash, address indexed roller, uint256 indexed pID);
    event DiceLanded(bytes32 indexed requestId, uint256 indexed result,uint256 indexed pID);
    event Win(address indexed _player, uint256 indexed result,uint256 indexed pID);
    event Loss(address indexed _player, uint256 indexed result,uint256 indexed pID);

    // AggregatorV3Interface internal wingsBNB;

   

    constructor(bytes32 keyHash, uint256 fee,GSB _addressGetsetGameB,GSC _addressGetsetGlobalTeamsC,GSD _addressGetsetPlayerInfoD,IERC20 partner_token,VOLT volt_contract,address access,address _collectionAddress)

    {
        access_address = access;
        s_keyHash = keyHash;
        s_fee = fee;

        gsb = _addressGetsetGameB;
        gsc = _addressGetsetGlobalTeamsC;
        gsd = _addressGetsetPlayerInfoD;
        mr = volt_contract;

        _owner = msg.sender;
        _token = partner_token;
        excludedFromTax[msg.sender] = true;
        _collection = _collectionAddress;
        // main net
        // wingsBNB = AggregatorV3Interface(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);

        // testnet bnb usd
        // wingsBNB = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526);

    }


        /** !UPDATE
    *
    * Returns latest ETH/USD price from Chainlink oracles.
    */
    // function wingsInBNB() public view returns (int) {
    //     (uint80 roundId, int price, uint startedAt, uint timeStamp, uint80 answeredInRound) = wingsBNB.latestRoundData();

    //     return price;
    // }

    /** !UPDATE
    *
    * bnbUsd - latest price from Chainlink oracles (BNB in USD * 10**8).
    * weiUsd - USD in Wei, received by dividing:
    *          ETH in Wei (converted to compatibility with etUsd (10**18 * 10**8)),
    *          by ethUsd.
    */
    // function weiInBNB() public view returns (uint) {
    //     int bnbUsd = wingsInBNB();
    //     int weiBNB = 10**26/bnbUsd;

    //     return uint(weiBNB);
    // }
    

    function rollDice(uint256 _pID,address roller,uint256 _userGuess,uint _huntId) public returns (bytes32 requestId) {

        require(!gsc.getTeamPointsCheck(_pID,_huntId, 1),"Game Over");
        require(!gsc.getTeamPointsCheck(_pID,_huntId, 2),"Game Over");

        mr._token().transferFrom(msg.sender,mr.gamePotUsedForGames(),mr.CostToPlay()*3);
        mr._token().transferFrom(msg.sender,_collection,mr.CostToPlay()*3);

        // require(msg.value >= 10, "Minimum bonded amount hasn't been met,");

        // check player has entered...
        (uint huntId,bool entered,uint headStartTime,bool gameLive)  = gsb.getHuntEntries(_pID,msg.sender,_huntId);

        require(entered, "Not Entered!");
        require(_numUsed[requestId] != true, "Result already used");
        require((_userGuess >= 0 && _userGuess <= 5), "Number should be 0 to 6");

        // require(_token.transfer(address(this), mr.CostToPlay()), "Not enough Token");
        // require(_token.balanceOf(address(this)) >= mr.CostToPlay(), "Not enough Tokens to pay fee");

        require(s_results[roller] == 0, "Already rolled");

        // check player has entered...
        
        // custom hash
        requestId = bytes32(keccak256(abi.encodePacked(bytes32(keccak256(abi.encodePacked(roller))),block.timestamp,s_keyHash)));
        
        s_rollers[requestId] = roller;

        player_history[roller][requestId].player_guess = _userGuess;
        player_history[roller][requestId]._huntId = _huntId;

        s_results[roller] = ROLL_IN_PROGRESS;
        user_guess[roller] = _userGuess;

        // not required
        waiting = true;

        // Set view details  
        player_pending[roller] = pending(true,requestId,_userGuess,_huntId,_pID,block.timestamp + 90 seconds);

        
        

        gsd.setPlayedRandomGame(roller,_pID,1,_huntId);

        emit DiceRolled(requestId, roller,_pID);
        
    }

    function fulfillRandomness(uint256 _pID,bytes32 requestId, uint256 randomness) public payable onlyOwner {
        
        address _player = s_rollers[requestId];

        require(!gsc.getTeamPointsCheck(_pID,player_history[_player][requestId]._huntId, 1),"Game Over");
        require(!gsc.getTeamPointsCheck(_pID,player_history[_player][requestId]._huntId, 2),"Game Over");

        uint256 randomResult = (randomness % 6) + 1;

        verdict(_pID,randomResult,_player,requestId,player_history[_player][requestId]._huntId);

        player_history[_player][requestId].actual_result = randomResult;
        
        // Set completed details for address
        player_pending[_player] = pending(false,0x0000000000000000000000000000000000000000000000000000000000000000,0,0,0,0);

        emit DiceLanded(requestId, randomResult,_pID);
    }

    function quickCheckResult(address _address) public view returns (bool,bytes32,uint256,uint,uint256) {
        if (player_pending[_address].time > block.timestamp){
           return (player_pending[_address].pending_waiting,player_pending[_address].pending_requestIdhash,player_pending[_address].pending_player_guess,player_pending[_address].pending_huntId,player_pending[_address].pending_partnerId);
        } else {
           return (false,player_pending[_address].pending_requestIdhash,player_pending[_address].pending_player_guess,player_pending[_address].pending_huntId,player_pending[_address].pending_partnerId);
        }

    }


    function verdict(uint256 _pID,uint256 random,address _player,bytes32 requestId,uint _huntId) public payable onlyOwner  {
    // check the state of the wallet address has it won?
        require(_numUsed[requestId] != true, "Result already used");
        _numUsed[requestId] = true;

        if (user_guess[_player] == random) {

            player_history[_player][requestId].win = true;

            for(i = 1; i <= gsc.lengthEntrantLeaderbaord(_pID,_huntId);  i++) {

                
                if (gsc.getStageLeaderboardAddressMapping(_pID,_huntId,_player) == 5) {
                    gsc.setUsersPoints(_pID,msg.sender,_huntId,i,60,true,gsd.getPlayerRank(msg.sender));
                    gsc.setUsersStage(_pID,msg.sender,_huntId,i,6,true);
                    gsc.setTeamPoints(_pID,msg.sender,_huntId,60,true,gsd.getPlayerRank(msg.sender));
                } else {
                    gsc.setUsersPoints(_pID,_player,_huntId,i,60,true,gsd.getPlayerRank(_player));
                    gsc.setTeamPoints(_pID,_player,_huntId,60,true,gsd.getPlayerRank(_player));
                
                }

            }

            win = true;
            loss = false;
            result = random;
            mr._token().transferFrom(mr.gamePotUsedForGames(),_player,mr.CostToPlay()*2);
            emit Win(_player, random, _pID);

            // mr._token().transfer(_player,mr.CostToPlay());

        } else {

            player_history[_player][requestId].win = false;

            

            win = false;
            loss = true;
            result = random;
            emit Loss(_player, random, _pID);


    }


    waiting = false;
    // can play again mapping once everything is paid
    s_results[_player] = 0;

    }

    /**
     * @notice Withdraw LINK from this contract.
     * @dev this is an example only, and in a real contract withdrawals should
     * happen according to the established withdrawal pattern:
     * https://docs.soliditylang.org/en/v0.4.24/common-patterns.html#withdrawal-from-contracts
     * @param to the address to withdraw LINK to
     * @param value the amount of LINK to withdraw
     */
    function withdrawToken(address to, uint256 value) public onlyOwner {      
        require(_token.transfer(to, value), "Not enough Token");
    }

    /**
     * @notice Set the key hash for the oracle
     *
     * @param keyHash bytes32
     */
    function setKeyHash(bytes32 keyHash) public onlyOwner {
        s_keyHash = keyHash;
    }

    /**
     * @notice Get the current key hash
     *
     * @return bytes32
     */
    function keyHash() public view returns (bytes32) {
        return s_keyHash;
    }

    /**
     * @notice Set the oracle fee for requesting randomness
     *
     * @param fee uint256
     */
    function setFee(uint256 fee) public onlyOwner {
        s_fee = fee;
    }

    /**
     * @notice Get the current fee
     *
     * @return uint256
     */
    function fee() public view returns (uint256) {
        return s_fee;
    }
}

////////////////////////////////////// Random Games 1/20 /////////////////////////////////////////

contract RANDOMGAME3 {

    // Provide Access for this contract

    using SafeMath for uint256;

    address _owner;
    address _collection;

    GSB public gsb;
    GSC public gsc;
    GSD public gsd;
    VOLT public mr;
    
    address private access_address;


    uint public i;
    address public thisUserLocalAddress;

    address payable public gamePotUsedForGames;
    IERC20 public _token;
    mapping(address => bool) public excludedFromTax;



    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return (msg.sender == _owner);
    }

    uint256 private constant ROLL_IN_PROGRESS = 42;

    bytes32 private s_keyHash;
    uint256 private s_fee;

    mapping(bytes32 => address) private s_rollers;
    mapping(bytes32 => bool) private _numUsed;

    struct history {
        uint256 player_guess;
        uint256 actual_result;
        bool win;
        uint _huntId;
    }

    // Address of player - requesId - num the player choose
    mapping(address => mapping(bytes32 => history)) public player_history;

    // --------------------------------------------

    struct pending { 
        bool pending_waiting;
        bytes32 pending_requestIdhash;
        uint256 pending_player_guess;
        uint pending_huntId;
        uint256 pending_partnerId;
        uint256 time;
    }

    // Id of player 
    mapping(address => pending) internal player_pending;

    // -------------------------------------------- 


    mapping(address => uint256) private s_results;

    mapping(address => uint256) private user_guess;

    bool public win;
    bool public loss;
    bool public waiting;
    uint256 public result;

    event DiceRolled(bytes32 indexed s_keyHash, address indexed roller, uint256 indexed pID);
    event DiceLanded(bytes32 indexed requestId, uint256 indexed result,uint256 indexed pID);
    event Win(address indexed _player, uint256 indexed result,uint256 indexed pID);
    event Loss(address indexed _player, uint256 indexed result,uint256 indexed pID);

    // AggregatorV3Interface internal wingsBNB;

   

    constructor(bytes32 keyHash, uint256 fee,GSB _addressGetsetGameB,GSC _addressGetsetGlobalTeamsC,GSD _addressGetsetPlayerInfoD,IERC20 partner_token,VOLT volt_contract,address access,address _collectionAddress)

    {
        access_address = access;
        s_keyHash = keyHash;
        s_fee = fee;

        gsb = _addressGetsetGameB;
        gsc = _addressGetsetGlobalTeamsC;
        gsd = _addressGetsetPlayerInfoD;
        mr = volt_contract;

        _owner = msg.sender;
        _token = partner_token;
        excludedFromTax[msg.sender] = true;
        _collection = _collectionAddress;
        // main net
        // wingsBNB = AggregatorV3Interface(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);

        // testnet bnb usd
        // wingsBNB = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526);

    }


        /** !UPDATE
    *
    * Returns latest ETH/USD price from Chainlink oracles.
    */
    // function wingsInBNB() public view returns (int) {
    //     (uint80 roundId, int price, uint startedAt, uint timeStamp, uint80 answeredInRound) = wingsBNB.latestRoundData();

    //     return price;
    // }

    /** !UPDATE
    *
    * bnbUsd - latest price from Chainlink oracles (BNB in USD * 10**8).
    * weiUsd - USD in Wei, received by dividing:
    *          ETH in Wei (converted to compatibility with etUsd (10**18 * 10**8)),
    *          by ethUsd.
    */
    // function weiInBNB() public view returns (uint) {
    //     int bnbUsd = wingsInBNB();
    //     int weiBNB = 10**26/bnbUsd;

    //     return uint(weiBNB);
    // }


    function rollDice(uint256 _pID,address roller,uint256 _userGuess,uint _huntId) public returns (bytes32 requestId) {

        require(!gsc.getTeamPointsCheck(_pID,_huntId, 1),"Game Over");
        require(!gsc.getTeamPointsCheck(_pID,_huntId, 2),"Game Over");

        mr._token().transferFrom(msg.sender,mr.gamePotUsedForGames(),mr.CostToPlay()*3);
        mr._token().transferFrom(msg.sender,_collection,mr.CostToPlay()*3);

        // require(msg.value >= 10, "Minimum bonded amount hasn't been met,");

        // check player has entered...
        (uint huntId,bool entered,uint headStartTime,bool gameLive)  = gsb.getHuntEntries(_pID,msg.sender,_huntId);

        require(entered, "Not Entered!");
        require(_numUsed[requestId] != true, "Result already used");
        require((_userGuess >= 0 && _userGuess <= 19), "Number should be 0 to 19");

        // require(_token.transfer(address(this), mr.CostToPlay()), "Not enough Token");
        // require(_token.balanceOf(address(this)) >= mr.CostToPlay(), "Not enough Tokens to pay fee");

        require(s_results[roller] == 0, "Already rolled");

        // check player has entered...
        
        // custom hash
        requestId = bytes32(keccak256(abi.encodePacked(bytes32(keccak256(abi.encodePacked(roller))),block.timestamp,s_keyHash)));
        
        s_rollers[requestId] = roller;

        player_history[roller][requestId].player_guess = _userGuess;
        player_history[roller][requestId]._huntId = _huntId;

        s_results[roller] = ROLL_IN_PROGRESS;
        user_guess[roller] = _userGuess;

        // not required
        waiting = true;

        // Set view details
        player_pending[roller] = pending(true,requestId,_userGuess,_huntId,_pID,block.timestamp + 90 seconds);

        gsd.setPlayedRandomGame(roller,_pID,1,_huntId);

        emit DiceRolled(requestId, roller,_pID);
        
    }

    function fulfillRandomness(uint256 _pID,bytes32 requestId, uint256 randomness) public payable onlyOwner {
        
        address _player = s_rollers[requestId];

        require(!gsc.getTeamPointsCheck(_pID,player_history[_player][requestId]._huntId, 1),"Game Over");
        require(!gsc.getTeamPointsCheck(_pID,player_history[_player][requestId]._huntId, 2),"Game Over");

        uint256 randomResult = (randomness % 20) + 1;

        verdict(_pID,randomResult,_player,requestId,player_history[_player][requestId]._huntId);

        player_history[_player][requestId].actual_result = randomResult;
        
        // Set completed details for address 
        player_pending[_player] = pending(false,0x0000000000000000000000000000000000000000000000000000000000000000,0,0,0,0);

        emit DiceLanded(requestId, randomResult,_pID);
    }

    function quickCheckResult(address _address) public view returns (bool,bytes32,uint256,uint,uint256) {
        if (player_pending[_address].time > block.timestamp){
           return (player_pending[_address].pending_waiting,player_pending[_address].pending_requestIdhash,player_pending[_address].pending_player_guess,player_pending[_address].pending_huntId,player_pending[_address].pending_partnerId);
        } else {
           return (false,player_pending[_address].pending_requestIdhash,player_pending[_address].pending_player_guess,player_pending[_address].pending_huntId,player_pending[_address].pending_partnerId);
        }

    }


    function verdict(uint256 _pID,uint256 random,address _player,bytes32 requestId,uint _huntId) public payable onlyOwner  {
    // check the state of the wallet address has it won?
        require(_numUsed[requestId] != true, "Result already used");
        _numUsed[requestId] = true;

        if (user_guess[_player] == random) {

            player_history[_player][requestId].win = true;

            for(i = 1; i <= gsc.lengthEntrantLeaderbaord(_pID,_huntId);  i++) {

                if (gsc.getStageLeaderboardAddressMapping(_pID,_huntId,_player) == 8) {
                    gsc.setUsersPoints(_pID,msg.sender,_huntId,i,90,true,gsd.getPlayerRank(msg.sender));
                    gsc.setUsersStage(_pID,msg.sender,_huntId,i,9,true);
                    gsc.setTeamPoints(_pID,msg.sender,_huntId,90,true,gsd.getPlayerRank(msg.sender));
                } else {
                    gsc.setUsersPoints(_pID,_player,_huntId,i,90,true,gsd.getPlayerRank(_player));
                    gsc.setTeamPoints(_pID,_player,_huntId,90,true,gsd.getPlayerRank(_player));
                
                }

            }

            win = true;
            loss = false;
            result = random;
            mr._token().transferFrom(mr.gamePotUsedForGames(),_player,mr.CostToPlay()*2);
            emit Win(_player, random, _pID);

            // mr._token().transfer(_player,mr.CostToPlay());

        } else {

            player_history[_player][requestId].win = false;

            

            win = false;
            loss = true;
            result = random;
            emit Loss(_player, random, _pID);


    }


    waiting = false;
    // can play again mapping once everything is paid
    s_results[_player] = 0;

    }

    /**
     * @notice Withdraw LINK from this contract.
     * @dev this is an example only, and in a real contract withdrawals should
     * happen according to the established withdrawal pattern:
     * https://docs.soliditylang.org/en/v0.4.24/common-patterns.html#withdrawal-from-contracts
     * @param to the address to withdraw LINK to
     * @param value the amount of LINK to withdraw
     */
    function withdrawToken(address to, uint256 value) public onlyOwner {      
        require(_token.transfer(to, value), "Not enough Token");
    }

    /**
     * @notice Set the key hash for the oracle
     *
     * @param keyHash bytes32
     */
    function setKeyHash(bytes32 keyHash) public onlyOwner {
        s_keyHash = keyHash;
    }

    /**
     * @notice Get the current key hash
     *
     * @return bytes32
     */
    function keyHash() public view returns (bytes32) {
        return s_keyHash;
    }

    /**
     * @notice Set the oracle fee for requesting randomness
     *
     * @param fee uint256
     */
    function setFee(uint256 fee) public onlyOwner {
        s_fee = fee;
    }

    /**
     * @notice Get the current fee
     *
     * @return uint256
     */
    function fee() public view returns (uint256) {
        return s_fee;
    }
}