/**
 *Submitted for verification at BscScan.com on 2022-08-20
*/

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

// File: FOFPlayerRaceData.sol

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;




contract FOFPlayerRaceData is Ownable {

    using SafeMath for uint256;

    
    mapping(address => string) public nicknames;

    mapping(uint256 => string) public cardNicknames;

    
    mapping(uint256 => address[]) public clubMembers;

    mapping(address => uint256) public memberToClubIds;

    mapping(uint256 => address[3]) public clubRaceMembers;

    mapping(uint256 => uint256) public raceIds;

    mapping(uint256 => mapping(uint256 => uint256)) public raceTime;

    mapping(uint256 => uint256) public raceDurations;

    mapping(uint256 => mapping(uint256 => uint256[])) public raceVehicles;

    mapping(uint256 => mapping(uint256 => uint256)) public raceReward;
    mapping(uint256 => mapping(uint256 => uint256)) public fofRaceReward;

    uint256 public maxRaceTimes = 20;

    mapping(address => uint256) public uerRaceTotalTimes;

    mapping(address => uint256) public userRaceLeftTimes;

    mapping(address => bool) public uerGetFuelForFree;

    uint256 public rankingRaceTicket = 5 * 10 ** 18;

    uint256 public fuelPrice = 50 * 10 ** 18;

    mapping(uint256 => uint256) public fuelPriceDiscount;

    // mapping(address => uint256) public userBuyFuelTime;
    mapping(address => uint256) public userTodayRaceTimes;

    mapping(address => uint256) public userLastRaceTime;

    uint256 public todayRaceTimes;

    uint256 public LastRaceTime;

    uint256 public discountEndTime = 1693497600;//游戏统一时间，还是每个用户第一次加油的时间+一年？？？


    // address public receiveAddress;
    address public withdrawAddress;

    // address public rankAddress = 0xBdDeeC848161d71851Bcb3ff8A4Bf590eF782E71;
    address public clubAddress = 0x45CbCBf16E1251d2019bEdb940f70Cb6F12068b0;
    address public repokAddress = 0x936380034e18e8E9DBc35DBbdc7248507e935Cc1;
    address public deadWallet = 0x000000000000000000000000000000000000dEaD;


    uint256 public todayDividends;
    uint256 public todayFofDividends;

    uint256 public topDividends = 10 ** 17;

    mapping(uint256 => mapping(uint256 => uint256)) public settlementTimesToDividends;

    mapping(uint256 => mapping(uint256 => uint256)) public settlementTimesToFofDividends;

    uint256[] public settlementTimesToTime;


    mapping(address => bool) public isController;


    constructor() {
    
        //20220801  10:00   /  14:00   /  18:00
        raceTime[1][1] = 7200;
        raceTime[1][2] = 14400;
        raceTime[1][3] = 21600;

        // raceTime[2][1] = 1663243200;//20220915  20:00
        // raceTime[2][1] = 1669377600;//20221125  20:00
        raceTime[2][1] = 1660996800;//2023-8-17 18:00:00
        raceTime[3][1] = 1661428800;//2023-8-15 18:00:00


        raceDurations[1] = 1 hours;
        raceDurations[2] = 1 hours;
        raceDurations[3] = 1 hours;

        fuelPriceDiscount[1] = 90;
        fuelPriceDiscount[2] = 95;
        fuelPriceDiscount[3] = 97;

        raceIds[1] = 1;
        raceIds[2] = 1;
        raceIds[3] = 1;

        // receiveAddress = address(0xC5a89985D57FdddEFCE3E9f26faB99EbF471516A);
        withdrawAddress = address(0xC5a89985D57FdddEFCE3E9f26faB99EbF471516A);
    }

    function addController(address controllerAddr) public onlyOwner {
        isController[controllerAddr] = true;
    }

    function removeController(address controllerAddr) public onlyOwner {
        isController[controllerAddr] = false;
    }

    modifier onlyController {
        require(isController[msg.sender],"Must be controller");
        _;
    }

    // function setReceiveAddress(address _receiveAddress) public onlyController {
    //     receiveAddress = _receiveAddress;
    // }

    function setClubAddress(address _clubAddress) public onlyController {
        clubAddress = _clubAddress;
    }

    function setRepokAddress(address _repokAddress) public onlyController {
        repokAddress = _repokAddress;
    }

    function setWithdrawAddress(address _withdrawAddress) public onlyController {
        withdrawAddress = _withdrawAddress;
    }

    function setMaxRaceTimes(uint256 _maxRaceTimes) public onlyController {
        maxRaceTimes = _maxRaceTimes;
    }

    function setRaceTime(uint256 raceType, uint256 raceid, uint256 time) public onlyController {
        raceTime[raceType][raceid] = time;
    }

    function setTopDividends(uint256 _topDividends) public onlyController {
        topDividends = _topDividends;
    }

    function setDiscountEndTime(uint256 _discountEndTime) public onlyController {
        discountEndTime = _discountEndTime;
    }

    function setRaceDurations(uint256 raceType, uint256 time) public onlyController {
        raceDurations[raceType] = time;
    }

    function setRankingRaceTicket(uint256 _rankingRaceTicket) public onlyController {
        rankingRaceTicket = _rankingRaceTicket;
    }

    function setFuelPrice(uint256 _fuelPrice) public onlyController {
        fuelPrice = _fuelPrice;
    }

    function setNickname(address user, string memory _nickname) public onlyController {
        nicknames[user] = _nickname;
    }

    function setCardNicknames(uint256 tokenId, string memory _nickname) public onlyController {
        cardNicknames[tokenId] = _nickname;
    }

    function joinClub(address user, uint256 tokenId) public onlyController {

        require(memberToClubIds[user] == 0, "You have joined the club");

        memberToClubIds[user] = tokenId;

        clubMembers[tokenId].push(user);
    }

    function deleteClubMember(uint256 clubId, uint256 index, address member) public onlyController {

        delete clubMembers[clubId][index];
        
        memberToClubIds[member] = 0;
    }

    function subUserRaceLeftTimes(address user, uint256 times) public onlyController {
        userRaceLeftTimes[user] -= times;
    }

    function addUserRaceLeftTimes(address user, uint256 times) public onlyController {
        userRaceLeftTimes[user] += times;
    }

    function setUerRaceTotalTimes(address user, uint256 times) public onlyController {
        uerRaceTotalTimes[user] = times;
    }

    function addRaceVehicles(uint256 raceType, uint256 raceId, uint256 tokenId) public onlyController {
        raceVehicles[raceType][raceId].push(tokenId);
    }

    function addRaceIds(uint256 raceType,uint256 num) public onlyController {
        raceIds[raceType] += num;
    }

    function addRaceReward(uint256 raceType, uint256 raceId, uint256 reward) public onlyController {
        raceReward[raceType][raceId] += reward;
    }

    function addFofRaceReward(uint256 raceType, uint256 raceId, uint256 fofReward) public onlyController {
        fofRaceReward[raceType][raceId] += fofReward;
    }

    function addSettlementTimesToTime(uint256 time) public onlyController {
        settlementTimesToTime.push(time);
    }

    function setSettlementTimesToDividends(uint256 dividends) public onlyController {
        settlementTimesToDividends[settlementTimesToTime.length][4] = dividends;
        todayDividends = 0;
    }

    function setSettlementTimesToFofDividends(uint256 fofDividends) public onlyController {
        settlementTimesToFofDividends[settlementTimesToTime.length][4] = fofDividends;
        todayFofDividends = 0;
    }

    function deleteClubRaceMembers(uint256 clubId) public onlyController {
        delete clubRaceMembers[clubId];
    }

    function setClubRaceMembers(uint256 clubId, uint256 index, address user) public onlyController {
        clubRaceMembers[clubId][index] = user;
    }

    function addTodayDividends(uint256 dividends) public onlyController {
        todayDividends = todayDividends.add(dividends);
    }

    function addTodayFofDividends(uint256 fofDividends) public onlyController {
        todayFofDividends = todayFofDividends.add(fofDividends);
    }

    function setTodayDividends(uint256 dividends) public onlyController {
        todayDividends = dividends;
    }

    function setTodayFofDividends(uint256 fofDividends) public onlyController {
        todayFofDividends = fofDividends;
    }

    function setUerGetFuelForFree(address user, bool flag) public onlyController {
        uerGetFuelForFree[user] = flag;
    }

    function addUserTodayRaceTimes(address user, uint256 times) public onlyController {
        userTodayRaceTimes[user] += times;

        todayRaceTimes += times;

        userLastRaceTime[user] = block.timestamp;

        LastRaceTime =  block.timestamp;
    }

    function setUserTodayRaceTimes(address user, uint256 times) public onlyController {
        userTodayRaceTimes[user] = times;
    }

    function setTodayRaceTimes(uint256 times) public onlyController {
        todayRaceTimes = times;
    }

    function getRaceVehicles(uint256 raceType, uint256 raceId) public view returns(uint256[] memory) {
        return raceVehicles[raceType][raceId];
    }

    function getClubMembers(uint256 clubId) public view returns(address[] memory) {
        return clubMembers[clubId];
    }

    function getClubRaceMembers(uint256 clubId) public view returns(address[3] memory) {
        return clubRaceMembers[clubId];
    }

    function getSettlementTimesToTime() public view returns(uint256[] memory) {
        return settlementTimesToTime;
    }

    function getRaceTime(uint256 raceType) public view returns(uint256) {
        return raceTime[raceType][raceIds[raceType]];
    }

}