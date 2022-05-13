/**
 *Submitted for verification at BscScan.com on 2022-05-13
*/

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
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
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

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


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// File: contracts/updatedminiAA.sol

// contracts/MiniAdoptionAmplifier.sol

pragma solidity ^0.8.7;





interface IPTP {
    function mintAmount(address _to, uint256 _amount) external;
}

/**
 * @title MiniAdoptionAmpifier
 */

contract miniAdoptionAmpifier is Ownable , ReentrancyGuard{
    using SafeMath for uint256;
    // Free Claimers Pool struct
    struct FreeClaimers {
         // Address of the free claimer
        address user;
        // Stores the current year
        uint256 year;
    }
    // Reward pool points Depositers struct
    struct Depositers{
        // Address of the point depositer
        address user;
        // Amount of points 
        uint256 amount;
        // Stores the current year
        uint256 year;
    }

    // ***********  Config  *********** 
    // Set Start Date
    uint public startDate;
    IPTP public ptpToken;    // PTP Token Instance
    uint public DAY = 86400;   // In Seconds 86400
    uint public YEAR = 31558995;
    uint public DECIMAL = 18;  // 
    // ********************************

    // Stores the reward amount of 63 years
    uint256[] public yearsReward;
    // Mappings for Free claim pool
    mapping(uint256 => FreeClaimers[]) public todayFreeClaimers;
    mapping(uint256 => mapping(address => bool)) public claimStatusFreePool;

    // Mappings for Rewards based on points pool
    mapping(address => uint256) public pointsBalance;
    mapping(uint256 => Depositers[]) public todayDepositers;
    mapping(uint256 => mapping(address => bool)) public claimStatusRewardPool;

    

    // ********** Events **********
    /**
    * @notice Emmits whenever the new user added to freeClaim pool.
    */
    event EnteredForFreeClaim(uint indexed _day, address indexed _user);
    /**
    * @notice Emmits when the user claims the previous day free reward.
    */
    event ClaimedFreePTP(uint indexed _day, uint indexed _rewardAmount, address indexed _user);
    /**
    * @notice Emmits whenever the user deposits there points into reward pool.
    */
    event pointsDeposited(uint indexed _day, uint indexed _points, address indexed _user);
    /**
    * @notice Emmits when the user claims the previous day reward of deposited points.
    */
    event RewardClaimed(uint indexed _day, uint indexed _ptpAmount, address indexed _user);

   /**
     * @dev Creates a miniAA contract.
     * @param _start Start date of the pools in Seconds
     * @param _ptp Address of the PTP token Contract
     */
    constructor(uint _start, address _ptp){
        startDate = _start;
        ptpToken = IPTP(_ptp);
        // Init the reward amount for next 63 years from start date
        setYearsReward();
    }

    receive() external payable {}

    fallback() external payable {}
    
    /**
     * @notice OnlyOwner Function
     * @dev set the start date in Seconds.
     * @param _startDate Start date of the pools in Seconds
     */
    function setStartDate(uint _startDate) public onlyOwner {
        startDate = _startDate;
    }

    /**
     * @notice OnlyOwner Function
     * @dev Set the day Duration in Seconds Default 86400.
     * @param _day no of seconds in day
     */
    function setDay(uint _day) public onlyOwner{
        DAY = _day;
    }
    /**
     * @notice OnlyOwner Function
     * @dev Set the year Duration in Seconds Default 31558995.
     * @param _year no of seconds in year.
     */
    function setYear(uint _year) public onlyOwner{
        YEAR = _year;
    }
    
    /**
     * @notice Find and retuns the current year from start date
     */
    function findYear() public view returns(uint256) {
        require(block.timestamp >= startDate, "Not Start Yet!");
        uint year = block.timestamp.sub(startDate);
        year = year.div(YEAR);   
        return year;
    }
    /**
     * @notice Find and retuns the current day from start date
     */
    function findDay() public view returns(uint256) {
        require(block.timestamp >= startDate, "Not Start Yet!");
        uint256 day = block.timestamp.sub(startDate);
        return day.div(DAY);
    }

    
    /**
     * @notice Return the number of free claimers on the given day
     * @param _day enter the day you want no of free claimers
     */
    function countFreeClaimers(uint _day) public view returns (uint){
        return todayFreeClaimers[_day].length;
    }

//   **************Optional Functions**************

    
    /**
     * @notice Sets and init the Reward for next 63 years
     * @dev Private Function (Only called on deployement)
     */
    function setYearsReward() private {
        uint256 ptpAmount = 2000000000;
        uint256 ptpAvailable = 0;
        for(uint256 i = 0; i < 63; i++){
            if(i == 0 ){
                ptpAvailable = ptpAmount;
            }else if(i >= 1 &&  i <= 2){
                ptpAvailable = ptpAmount.div(2);
            }else if(i >= 3 &&  i <= 6){
                ptpAvailable = ptpAmount.div(4);
            }else if(i >= 7 &&  i <= 14){
                ptpAvailable = ptpAmount.div(8);
            }else if(i >= 15 &&  i <= 30){
                ptpAvailable = ptpAmount.div(16);
            }else if(i >= 31 &&  i <= 62){
                ptpAvailable = ptpAmount.div(32);
            }
            yearsReward.push(ptpAvailable);
        }
    }
 
    /**
     * @notice Returns the lenght of years reward 
     * @dev Optional function
     */
    function getYearsLength() public view returns(uint) {
        return yearsReward.length;
    }
    /**
     * @notice Returns the yearReward Array
     * @dev Optional function
     */
    function getAllYearsReward() public view returns(uint256[] memory){
        return yearsReward;
    }
//   **************Free Claim Pool **************
    /**
     * @notice By calling this function the msg.sender will be enterd into free claim pool.
     * @dev Only callable once in a day.
     */
    function enterForFreeClaim() public {
        uint256 _day = findDay();
        uint256 _year = findYear();
        require(!isAlreadyEntered(_day, msg.sender), "Already Entered!");

        FreeClaimers memory tempClaimer = FreeClaimers(msg.sender, _year);
        todayFreeClaimers[_day].push(tempClaimer);

        emit EnteredForFreeClaim(_day, msg.sender);
    }
    
    /**
     * @notice By calling this function the msg.sender claims there reward from daily pool.
     * @dev Only callable if the msg.sender will be enterd in previous day free claim pool and not claim reward yet.
     */
    function freeClaim() public nonReentrant {
        uint _day = findDay();
        uint _preDay = _day -1;
        require(_preDay >= 0 ,"Try at the end of day");
        require(isAlreadyEntered(_preDay, msg.sender), "Not in the Cliam list!");
        require(!claimStatusFreePool[_preDay][msg.sender], "Alredy Claimed!");

        FreeClaimers memory currentClaimer = getFreeClaimerRecord(_preDay, msg.sender);
        uint256 rewardThisYear = yearsReward[currentClaimer.year];
        uint256 rewardPerDay = rewardThisYear.div(365);
        uint256 rewardforFreeClaimers = (rewardPerDay.mul(25)).div(100);
        uint256 allCliamers = countFreeClaimers(_preDay);
        uint256 todayShare = rewardforFreeClaimers.mul(10 ** DECIMAL);
            todayShare = todayShare.div(allCliamers);
            
            claimStatusFreePool[_preDay][msg.sender] = true;
            ptpToken.mintAmount(msg.sender , todayShare);

        emit ClaimedFreePTP(_preDay, todayShare, msg.sender);
    }

//   ************** Reward Claim Pool **************
    /**
     * @notice By calling this function the msg.sender deposit there points in daily pointsReward pool.
     * @dev Only callable if the msg.sender have a pointsBalance entered number of points in contract.
     * @param _points the number of points user wants to deposit.
     */
    function depositPointsForReward(uint _points) public nonReentrant {
        require(pointsBalance[msg.sender] >= _points, "Not have enough points");
        uint256 _day = findDay();
        uint256 _year = findYear();
        if(isAlreadyExist(_day, msg.sender)){
            uint index = getIndex(_day, msg.sender);
            todayDepositers[_day][index].amount += _points;
        } else {
            Depositers memory tempUser = Depositers(msg.sender, _points, _year);
            todayDepositers[_day].push(tempUser);
        }
        pointsBalance[msg.sender] = pointsBalance[msg.sender].sub(_points);

        emit pointsDeposited(_day, _points, msg.sender);
    }

    /**
     * @notice By calling this function the msg.sender claims there reward from daily pointsReward pool.
     * @dev Only callable if the msg.sender will be enterd in previous day pointsReward pool and not claim reward yet.
     */
    function claimReward() public nonReentrant {
        uint _day = findDay();
        uint _preDay = _day -1;
        require(_preDay >= 0 ,"Try at the end of day");
        require(isAlreadyExist(_preDay, msg.sender), "Invalid Claimer!");
        require(!claimStatusRewardPool[_preDay][msg.sender], "Alredy Claimed!");
        Depositers memory currentUser = getUserRecord(_preDay, msg.sender);

        uint256 rewardThisYear = yearsReward[currentUser.year];
        uint256 rewardPerDay = rewardThisYear.div(365);
        uint256 rewardAmount = rewardPerDay.mul(75);
        uint256 finalRewardAmount = rewardAmount.div(100);
        uint256 allPointsOfDay = totalDepositedPoints(_preDay);
        uint256 userAmount = currentUser.amount;
            userAmount = userAmount.mul(10 ** DECIMAL);
        uint256 userShare = userAmount.div(allPointsOfDay);
        uint256 userPTP = userShare.mul(finalRewardAmount);
            claimStatusRewardPool[_preDay][msg.sender] = true;
            ptpToken.mintAmount(msg.sender , userPTP);

        emit RewardClaimed(_preDay, userPTP, msg.sender);
    }
    
    /**
     * @notice Returns the number of users who deposited points for reward on given day in pointsReward pool.
     * @param _day Enter the day you want no of depositers.
     */
    function getNumberOfDepositers(uint256 _day) public view returns(uint){
        return todayDepositers[_day].length;
    }
//****************** Internals ******************
     
    /**
     * @notice Returns ture If given user already have a deposit in pointsReward pool else false.
     * @dev Internal function.
     * @param _day Enter the day.
     * @param _user address of the msg.sender
     */
    function isAlreadyExist(uint _day, address _user) internal view returns(bool){
        Depositers[] memory tempUsers = todayDepositers[_day];
        bool userExist;
        uint allUsers = getNumberOfDepositers(_day);
        if(allUsers > 0){
            for(uint256 i = 0; i < allUsers; i++){
                if(tempUsers[i].user == _user){
                    userExist = true;
                }
            }
        }
        return userExist;
    }
    
    /**
     * @notice Returns ture If given user already entered in freeclaim pool else false.
     * @dev Internal function.
     * @param _day Enter the day.
     * @param _user address of the msg.sender
     */
    function isAlreadyEntered(uint _day, address _user) internal view returns(bool) {
         FreeClaimers[] memory tempClaimers = todayFreeClaimers[_day];
        uint noOfClaimers = countFreeClaimers(_day);
        bool status = false;
        if(noOfClaimers > 0){
            for(uint i = 0; i < noOfClaimers; i++){
                if(tempClaimers[i].user == _user){
                    status = true;
                }  
            }
        }

        return status;
    }

    /**
     * @notice Returns the points deposited on the given day in pointsReward pool.
     * @param _day Enter the day.
     */
    function totalDepositedPoints(uint256 _day) public view returns(uint256){
        Depositers[] memory tempUsers = todayDepositers[_day];
        require(tempUsers.length > 0 ,"Invalid Day");
        uint256 amount;
        for(uint256 i = 0; i< tempUsers.length; i++){
            amount += tempUsers[i].amount;
        }
        return amount;
    }

    
    /**
     * @notice Return the user struct on the given day from pointsReward pool.
     * @param _day Enter the day.
     * @param _user adderss of the user
     * @return userRecord user Struct
     */
    function getUserRecord(uint _day, address _user) public view returns (Depositers memory){
        Depositers[] memory tempUsers = todayDepositers[_day];
        require(tempUsers.length > 0 ,"Invalid Day");
        Depositers memory userRecord;
        for(uint i = 0; i < tempUsers.length; i++){
            if(tempUsers[i].user == _user){
                userRecord = tempUsers[i];
            }
        }
        return userRecord;
    }
    /**
     * @notice Return the user struct on the given day from freeClaim pool.
     * @param _day Enter the day.
     * @param _user adderss of the user
     * @return userRecord user Struct
     */
    function getFreeClaimerRecord(uint _day, address _user) public view returns(FreeClaimers memory){
        FreeClaimers[] memory tempUsers = todayFreeClaimers[_day];
        require(tempUsers.length > 0 , "Invalid Day");
        FreeClaimers memory claimerRecord;
        for(uint i = 0; i < tempUsers.length; i++) {
            if(tempUsers[i].user == _user){
                claimerRecord = tempUsers[i];
            }
        }
        return claimerRecord;
    }

    /**
     * @notice Returns the index of the given user on specific day from pointsReward pool.
     * @param _day Enter the day.
     * @param _user adderss of the user
     * @return index
     */
    function getIndex(uint256 _day, address _user) public view returns (uint256){
        Depositers[] memory tempUsers = todayDepositers[_day];
        require(tempUsers.length > 0 ,"Invalid Day");
        uint tempIndex;
        for(uint i = 0; i < tempUsers.length; i++){
            if(tempUsers[i].user == _user){
                tempIndex = i;
            }
        }
        return tempIndex;
    }

    /**
     * @notice Set the user pointsBalace to given amount.
     * @dev OnlyOwner function
     * @param _user adderss of the user
     * @param _amount no of points
     */
    function updatePoints(address _user, uint256 _amount) public onlyOwner {
        pointsBalance[_user] = _amount;
    }

    /**
     * @notice Adds the given amount into user pointsBalances.
     * @dev OnlyOwner function
     * @param _user adderss of the user
     * @param _amount no of points
     */
    function addPoints(address _user, uint256 _amount) public onlyOwner {
        pointsBalance[_user] += _amount;
    }

    /**
     * @notice Subtracts the given amount from user pointsBalances.
     * @dev OnlyOwner function
     * @param _user adderss of the user
     * @param _amount no of points
     */
    function subPoints(address _user, uint256 _amount) public onlyOwner {
        pointsBalance[_user] -= _amount;
    }
}