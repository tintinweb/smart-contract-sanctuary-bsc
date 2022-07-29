/**
 *Submitted for verification at BscScan.com on 2022-07-29
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol

pragma solidity ^0.8.0;

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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
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
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

pragma solidity ^0.8.4;
pragma abicoder v2;

/** @title Blockfantasy Point Contract.
 * @notice A contract for calculating blockfantasy fantasy 
 *  team results from a chainlink external adapter.
 */

 contract Blockfantasy is Ownable{
     using SafeMath for uint256;


     uint256 public currenteventId;
     uint256 public eventuserscount;
     uint256 public totaluserpoint; //make private later
     uint256 public userpoint; //make private later
     address public operatorAddress;
     address private we;
     uint256 private userresultcount;
     uint256 public stakeToPrizeRatio = 50;

     struct Event{
         uint256 eventid; //would be an increment for each new event
         string eventname;
         uint256 eventspool;
         uint256[] playerslist;
         address[] users;
         uint256 closetime;
         uint256 matchtime;
         uint256 entryfee;
         address[] playersrank;
         uint256[] prizeDistribution;
     }

     struct Users{
         uint256 eventid;
         address user;
         uint256[] selectedplayers;
         uint256 userscore;
         //totaluserpoint() function to get players point
     }

     struct Players{
         uint256 eventid;
         uint256 player; //players pid
         uint256 playerscore; //players score
     }

     struct Userresult{
         address user;
         uint256 score;
         uint256 count;
     }

     //mapping
     mapping(uint256 => Event) private _events;
     mapping(address => Users) private _user;
     mapping(uint256 => Players) private _player;
     mapping(uint256 => Userresult) private _userresult;
     mapping(uint256 => mapping(uint256 => uint256)) private playerpoints; //event to players to points
     mapping(address => mapping(uint256 => uint256[])) private selectedusers; //event to players to selected players array
     mapping(address => mapping(uint256 => uint256)) private userpointforevent; //users point for a particular event

    modifier onlyOperator() {
        require(msg.sender == operatorAddress, "Not operator");
        _;
    }

    /*modifier onlyOwnerOrOperator() {
        require((msg.sender == owner()) || (msg.sender == operatorAddress, "Not owner or injector");
        _;
    }*/

     constructor(address operator){
         operatorAddress = operator;
         // this would contain chainlink client contract address
         //to be added
     }

     function CreateEvents(
         string memory name,
         uint256 rewardpool,
         uint256[] calldata playerspid,
         address[] calldata userlist,
         address[] calldata rankshouldbeempty,
         uint256 starttime,
         uint256 Fee,
         uint256[] calldata prizeshouldbeempty
         ) external /*onlyOwner*/{
             //add requirements statement
             currenteventId++;
             _events[currenteventId] = Event({
                 eventid : currenteventId,
                 eventname : name,
                 eventspool : rewardpool,
                 playerslist : playerspid,
                 users : userlist,
                 closetime : 3600 + starttime,
                 matchtime : starttime,
                 entryfee : Fee,
                 playersrank : rankshouldbeempty,
                 prizeDistribution: prizeshouldbeempty
             });
             //create players array loop
             for (uint256 i = 0; i < playerspid.length; i++){
                 uint256 but = playerspid[i];
                 playerpoints[currenteventId][but] = 0;//initialises the playerspoint nested mapping 
                 _player[currenteventId] = Players ({
                     eventid : currenteventId,
                     player : but,
                     playerscore : 0
                 });
             }
    }

    function Joinevent(
        uint256 id,
        address user,
        uint256[] calldata playersselected
    ) public {
        require(block.timestamp <= _events[id].closetime, "Match has started");
        eventuserscount++;
        //confirm the struct pattern
        _user[user] = Users({
            eventid : id,
            user : user,
            selectedplayers : playersselected,
            userscore : 0
        });
        selectedusers[user][id] = playersselected;
        //Add user address to user array in events struct
        _events[id].users.push(user);
    }

    //getalluserspoint
    function getalluserspoint(uint256 eventid) public {
        address[] storage boy = _events[eventid].users;
        //get users struct through the array id
        for (uint256 i = 0; i < boy.length; i++){
            _events[eventid].users[i];
            address few = _events[eventid].users[i];
            require(_user[few].eventid == eventid);
            uint256[] memory tip=_user[few].selectedplayers;
            //get each struct value using the users address
            //uint256 myscore = _user[few].userscore;
            geteachuserspoint(tip,eventid,few);
        }
    }
    //geteachuserspoint
    function geteachuserspoint(uint256[] memory userarray, uint256 eventid, address meet) public returns(uint256)/*can also be internal*/ {
        for (uint256 i = 0; i < userarray.length; i++){
            uint256 me = userarray[i];
            totaluserpoint += playerpoints[eventid][me];
            userpoint = totaluserpoint;
            userpointforevent[meet][eventid] = userpoint;
            //look for a way to update user struct
            _user[meet].userscore = userpoint;
            _userresult[eventid] = Userresult({
                user : meet,
                score : userpoint,
                count : userresultcount++
            });
        }
        uint256 wip = _user[meet].userscore;
        return wip;
    }

    function getalluserresult(uint256 eventid) public view returns (Userresult[] memory){
        uint256 count = _events[eventid].users.length;
        Userresult[] memory results = new Userresult[](count);
        //uint256 count = _userresult[eventid].count;
        for (uint i = 0; i < count; i++) {
            Userresult storage result = _userresult[i];
            results[i] = result; 
        }
        return results;
    }

    /*function getsingleuserscore(address user, uint256 eventid) public view returns (uint256){
        uint256 score = userpointforevent[user][eventid];
        return score;
    }*/
    function getusersplayers(address user, uint256 eventid) public view returns (uint256[] memory){
        uint256[] memory score = selectedusers[user][eventid];
        return score;
    }
    //getplayerspoint
    //Test data to test framework
    function testdata(uint256 test, uint256 eventid) public returns (uint256){
        uint256[] memory playerspid = _events[eventid].playerslist;
        for (uint256 i = 0; i < playerspid.length; i++){
            uint256 but = playerspid[i];
            playerpoints[currenteventId][but] = test; //initialises the playerspoint nested mapping 
        }
        return test;
    }

    //Price Distribution model starts here

     function buildDistribution(uint256 _playerCount, uint256 _stakeToPrizeRatio,uint256 eventid) internal view returns (uint256[] memory){
         uint256[] memory prizeModel = buildFibPrizeModel(_playerCount);
         uint256[] memory distributions = new uint[](_playerCount);
         uint256 prizePool = getPrizePoolLessCommission(eventid);
          for (uint256 i=0; i<prizeModel.length; i++){
              uint256 constantPool = prizePool.mul(_stakeToPrizeRatio).div(100);
              uint256 variablePool = prizePool.sub(constantPool);
              uint256 constantPart = constantPool.div(_playerCount);
              uint256 variablePart = variablePool.mul(prizeModel[i]).div(100);
              uint256 prize = constantPart.add(variablePart);
              distributions[i] = prize;
          }
          return distributions;
     }

    function buildFibPrizeModel (uint256 _playerCount) internal pure returns (uint256[] memory){
        uint256[] memory fib = new uint[](_playerCount);
        uint256 skew = 5;
        for (uint256 i=0; i<_playerCount; i++) {
             if (i <= 1) {
                 fib[i] = 1;
                } else {
                     // as skew increases, more winnings go towards the top quartile
                     fib[i] = ((fib[i.sub(1)].mul(skew)).div(_playerCount)).add(fib[i.sub(2)]);
                }
        }
        uint256 fibSum = getArraySum(fib);
        for (uint256 i=0; i<fib.length; i++) {
            fib[i] = (fib[i].mul(100)).div(fibSum);
        }
        return fib;
    }
    function getCommission(uint256 eventid) public view returns(uint256){
        address[] memory me = _events[eventid].users;
        return me.length.mul(_events[eventid].entryfee)
                        .mul(20)
                        .div(1000);
    }

    function getPrizePoolLessCommission(uint256 eventid) public view returns(uint256){
        address[] memory me = _events[eventid].users;
        uint256 totalPrizePool = (me.length
                                    .mul(20))
                                    .sub(getCommission(eventid));
        return totalPrizePool;
    }

    function submitPlayersByRank(uint256 eventid, address[] memory users) public {
        address[] memory me = _events[eventid].users;
        //_events[eventid].playersrank.length = 0;
        _events[eventid].prizeDistribution = buildDistribution(me.length, stakeToPrizeRatio, eventid);
        for(uint i=0; i < users.length; i++){
            _events[eventid].playersrank.push(users[i]);
        }
    }

    function getArraySum(uint256[] memory _array) internal pure returns (uint256){
        uint256 sum = 0;
        for (uint256 i=0; i<_array.length; i++){
            sum = sum.add(_array[i]);
        }
        return sum;
    }

    function getPrizeDistribution(uint256 eventid) public view returns(uint256[] memory){
        return _events[eventid].prizeDistribution;
    }

     function withdrawPrizes(uint256 eventid) public {
         address[] memory me = _events[eventid].users;
         for(uint256 i=0; i < me.length; i++){
              payable(address(uint160(_events[eventid].playersrank[i])))
              .transfer(_events[eventid].prizeDistribution[i]);
        }
     }
 }