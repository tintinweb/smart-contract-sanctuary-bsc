/**
 *Submitted for verification at BscScan.com on 2022-11-07
*/

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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
}

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// File: @openzeppelin/contracts/utils/Counters.sol


// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// File: contracts/IRand.sol



pragma solidity ^0.8.0;


interface IRand {
    function getRandomNumber() external returns (bytes32 requestId);
    function getRandomVal() external view returns (uint256); 

}

// File: contracts/IERC20.sol



pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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
    ) external;

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
     function withdraw(uint) external;
    function deposit() payable external;
    function mint(address recipient, uint256 amount) external returns(bool);
}

// File: contracts/BNFT.sol

pragma solidity ^0.8.0;
interface BNFT {
    function mint(address to_, uint256 countNFTs_) external returns (uint256, uint256);
    function burnAdmin(uint256 tokenId) external;
    function TransferFromAdmin(uint256 tokenId, address to) external;
}

// File: contracts/NFTDUELStorage.sol



pragma solidity ^0.8.0;





contract NFTDUELStorage {
  using SafeMath for uint256;
   address admin;
   //league e.g bronze 2 => 2 and so on
   mapping(string => uint256) dailyRewardMultiplyer;

   struct League {
    uint256 startTime;
    uint256 endTime;
   }

   mapping (uint256=>League) season;
   //user struct
   struct User{
     string league;
     uint256 points;
     uint256 missionCount;
     uint256 chests;
     uint256[] chestRewards;
     uint256 fuel;
     uint256 duel;
     uint256 unstakeAt;
   }

   struct UserBattleRecord {
    uint256 wins;
    uint256 loses;
    uint256 draws;
   }

   mapping(address => UserBattleRecord) _userBattleRecord;

   mapping (address => mapping(uint256 => uint256)) _userDailyBattles;

   mapping (address=> uint256[]) _userDuelIds;

   // user address => user detail
   mapping(address => User) users;
   Counters.Counter _leagueId;
   Counters.Counter _duelId;
   struct Deul{
       address winner;
       address loser;
       uint256 leagueId;
    //    string league;
       address p1;
       address p2;
       uint256 duelTime;
       uint256 duelEndTime;
   }
   mapping (uint256=>Deul) _deulDetail;

   mapping (address=> bool) userInDuel;

   mapping (uint256=>string) leagues;
   // how much points must be deducted or added 
   mapping (string=> uint256) points;
   mapping (string=> uint256) minimumStakeAmount;
  
   //for duel token
   IERC20 duelToken;
   // for rare nft
   BNFT nft;
   uint256 averageDuelValue; //average duel value
   uint256 upAverage; // 20 % up avrage value
   uint256 downAverage; // 20% down average value

   uint256 dailyMaxChest;
   uint256 missionToGetOneChest;
   uint256 missionCountToday;

   uint256[] public rewards;  

   uint256 seed; 
}

// File: contracts/NFTDUEL.sol



pragma solidity ^0.8.0;




contract NFTDuel is Ownable, NFTDUELStorage {
using Counters for Counters.Counter;
using SafeMath for uint256;

   constructor() {
       admin = msg.sender;
   }

   function setAdmin(address _admin) onlyOwner public {
       admin = _admin;
   } 


   modifier onlyAdmin() {
       require(admin == msg.sender);
       _;
   }

   function init( address _nft, address _deulToken) onlyOwner public {
       seed = 478959347695;
       nft = BNFT(_nft);
       duelToken = IERC20(_deulToken);

   }

    //to set leagues daily multiplyer
   function setLeaguesDailyMultiplyer(string[] memory _leagues, uint256[] memory multiplyer ) onlyOwner public {
       require(_leagues.length == multiplyer.length, "invalid data");
       for (uint256 index = 0; index < _leagues.length; index++) {
          
           dailyRewardMultiplyer[leagues[index]] = multiplyer[index];
       }
   }

   function setDailyMaxChest(uint256 _dailyMaxChest) onlyOwner public {
       dailyMaxChest = _dailyMaxChest;
   }

   function setMissionCountToday(uint256 _missionCountToday) onlyOwner public {
       missionCountToday = _missionCountToday;
   }

   function setMissionToGetOneChest(uint256 _missionToGetOneChest) onlyOwner public {
       missionToGetOneChest = _missionToGetOneChest;
   }

   function startSeason(uint256 startTime, uint256 endTime) onlyOwner public {
    require(season[_leagueId.current()].endTime < block.timestamp, "season on going");
    _leagueId.increment();

    season[_leagueId.current()] = League(startTime, endTime);

   }

   function leaguesDefinition(uint256 start, uint256 end, string memory league, uint256 point) onlyOwner public {
       points[league] = point;
       for (uint256 index = start; index <= end; index++) {
           leagues[index] = league;
       }
   }
   
   //update user leagues data
   function updateUserData(address[] memory addresses, User[] memory _users) onlyOwner public {
       require(addresses.length == _users.length, "invalid data");
       for (uint256 index = 0; index < addresses.length; index++) {
           users[addresses[index]] = _users[index];
       }
   }

  function calculateWinnerLeaguePoints(address winner, address loser) internal {
      users[winner].points = users[winner].points + points[users[loser].league];
      if(points[users[loser].league] > users[loser].points){
          users[loser].points = 0;
      } else {
          users[loser].points = users[loser].points - points[users[loser].league];
      }
      
  }

  /**
@notice function to calculate league
 @param user user address 
 Note only aadmin can call this function
 */

  function leagueCalculation(address user) internal {
      User storage tempUser = users[user];
      tempUser.league = leagues[tempUser.points];
  }

   /**
@notice function to update end of duel of league and calculate duel points
 @param duelId on goin leagueId
 @param winner challenger 
 @param loser other player
 Note only aadmin can call this function
 */
  function duelEnded(uint256 duelId, address winner, address loser) onlyAdmin public {
    // require(condition); //verify users duel
    // require(); // verify users
    _deulDetail[duelId] = Deul(winner, loser, _deulDetail[duelId].leagueId, _deulDetail[duelId].p1, _deulDetail[duelId].p2, _deulDetail[duelId].duelTime, block.timestamp);
    calculateWinnerLeaguePoints(winner, loser);
    leagueCalculation(winner);
    leagueCalculation(loser);
  }

   /**
@notice function to update start of duel
 @param p1 challenger 
 @param p2 other player
 Note only aadmin can call this function
 */

  function duelStarted(address p1, address p2) onlyAdmin public {
    // require();
    _duelId.increment();
    _deulDetail[_duelId.current()] = Deul(address(0x0), address(0x0), _leagueId.current(), p1, p2, block.timestamp, 0);

  }

  function updateUserDailyMission(address user, uint256 mission) onlyAdmin public {
      users[user].missionCount = mission;
  }

  function updateUsersDailyMission(address[] memory user, uint256[] memory mission) onlyAdmin public {
   
    require(user.length == mission.length, "invalid data");
    for (uint256 index = 0; index < user.length; index++) {
        users[user[index]].missionCount = mission[index];
    }
  }

  function setAverageValue(uint256 value) onlyOwner public {
      averageDuelValue = value;
      upAverage = averageDuelValue + (averageDuelValue * 20) / 100;
      downAverage = averageDuelValue - (averageDuelValue * 20) / 100;
  }


    function userClaimChests() public {
        require(users[msg.sender].missionCount > 0, "not applicable");
        User memory tempUser= users[msg.sender];
        users[msg.sender].missionCount = 0;
        uint256 userClaimable;
        
        uint256 rand = seed;
        if(tempUser.missionCount == missionCountToday){
            userClaimable = dailyMaxChest + dailyRewardMultiplyer[tempUser.league];
            users[msg.sender].chests = userClaimable;
            
        }else {
            userClaimable = tempUser.missionCount.div(missionToGetOneChest) + dailyRewardMultiplyer[tempUser.league];
        }
        for (uint256 index = 0; index < userClaimable; index++) {
             uint256 indexReward = uint256(keccak256(abi.encodePacked(block.coinbase, rand, msg.sender, block.timestamp))).mod(10);
            users[msg.sender].chestRewards.push(rewards[indexReward]);
        }
        
    }

    function userOpenChest() public {
        require(users[msg.sender].chestRewards.length > 0, "not applicable");
        uint256[] memory tempChestRewards = users[msg.sender].chestRewards;
        // delete users[msg.sender].chestRewards;
        uint256 tokenToMint = 0;
        uint256 nftToMint = 0;
        for (uint256 index = 0; index < tempChestRewards.length; index++) {
            if(tempChestRewards[index] == 0){
                nftToMint++;
            }else {
                tokenToMint += tempChestRewards[index];
            }
        }
        if(nftToMint > 0) nft.mint(msg.sender, nftToMint);
        if(tokenToMint > 0) duelToken.mint(msg.sender, tokenToMint);
    }
 

    function rewardArray() onlyOwner public {
       
        uint256 rand = seed;
        uint256 nftCounter;
        for (uint256 index = 0; index < 10; index++) {
            uint256 choose = uint256(keccak256(abi.encodePacked(block.coinbase, rand, msg.sender, index))).mod(2);
            if(choose != 0){
                uint256 choose2 = uint256(keccak256(abi.encodePacked(block.coinbase, rand, msg.sender, index))).mod(2);
                if(choose2 != 0 || nftCounter >=3){
                    rewards[index] = upAverage;
                }else {
                    rewards[index] = downAverage;
                }
            }else {
                rewards[index] = choose;
                nftCounter++;
            }
        }
    }


    function stakeDuel() public {
        uint256 amount =  calculateStakeAmount();
        require(duelToken.balanceOf(msg.sender) > calculateStakeAmount(), "not enough balance");
        require(users[msg.sender].unstakeAt < season[_leagueId.current()].startTime, "can not stake for current season" );
        duelToken.transferFrom(msg.sender, address(this), amount);

        users[msg.sender].duel += amount;
        users[msg.sender].fuel += amount;
        emit DUELStaked(msg.sender, amount);
    }

     function unstakeDuel() public {
       duelToken.transferFrom(address(this),msg.sender, users[msg.sender].duel);
        uint256 amount = users[msg.sender].duel;
        users[msg.sender].duel = 0;
        users[msg.sender].fuel = 0;
        users[msg.sender].unstakeAt = block.timestamp;
        emit DUELUnStaked(msg.sender, amount);
    }


    function calculateStakeAmount() internal view returns(uint256) {
        User storage tempUser =  users[msg.sender];
        uint256 minimumAmount = minimumStakeAmount[tempUser.league];
        if(minimumAmount < tempUser.duel){
            return minimumAmount - tempUser.duel;
        } else {
            return 0;
        }
    }

    function setMinimumStakedAmount(string[] memory _leagues, uint256[] memory _minimumAmount) onlyOwner public {

        for (uint256 index = 0; index < _leagues.length; index++) {
            minimumStakeAmount[_leagues[index]] = _minimumAmount[index];
        }
    }

    event DUELStaked(address from, uint256 amount);
    event DUELUnStaked(address from, uint256 amount);

}