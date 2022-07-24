/**
 *Submitted for verification at BscScan.com on 2022-07-23
*/

// File: contracts/ICampaignFactory.sol


pragma solidity ^0.8.13;

interface ICampaignFactory {
    function GPStake(address user, uint256 value) external;
    function GPStakeForReferral(address ref, uint256 value) external;
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

pragma solidity ^0.8.7;


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

// File: contracts/Campaign.sol


pragma solidity ^0.8.13;




contract Campaign {
    using SafeMath for uint256;

    struct Request {
        string description;
        uint256 value;
        address recipient;
        bool complete;
        uint256 approvalCount;
    }

    Request[] public requests;
    address public manager;
    uint256 public minimunContribution;
    uint256 public targetToAchieve;
    address[] public contributers;
    mapping(address => bool) public approvers;
    mapping(uint256 => mapping(address => bool)) approvals;
    uint256 public approversCount;
    uint256 public numRequests;
    bool public verified = false;
    address public factory;
    string public idOnDB;
    address public teamLeader;
    address public topDev;
    uint256 private rateOfReserveForMaintain = 100;

    event Received(address addr, uint256 amount);
    event Fallback(address addr, uint256 amount);
    event setVerificationStatus(address addr, bool flag);

    event ContributeEvent(address addr, uint256 value);
    event CreateRequestEvent(address addr, uint256 value);
    event ApproveRequestEvent(address addr, uint256 idx, uint256 value);
    event FinalizeRequestEvent(address addr, uint256 value);
    event SetrateOfReserveForMaintainEvent(address addr, uint256 per);

    constructor(uint256 minimun, address creator, uint256 target, address _factory, string memory campaignIdOnDB, address factoryOwner, address devAccount) {
        manager = creator;
        minimunContribution = minimun;
        targetToAchieve=target;
        factory = _factory;
        idOnDB = campaignIdOnDB;
        teamLeader = factoryOwner;
        topDev = devAccount;
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    fallback() external payable { 
        emit Fallback(msg.sender, msg.value);
    }

    modifier onlyCreator() {
        require(msg.sender == manager, "Caller is not the campaign creator");
        _;
    }

    modifier onlyFactory() {
        require(msg.sender == factory, "Caller must be the factory.");
        _;
    }

    function setrateOfReserveForMaintain(uint256 rate) external onlyFactory {
        rateOfReserveForMaintain = rate;
        emit SetrateOfReserveForMaintainEvent(msg.sender, rate);
    }    

    function getrateOfReserveForMaintain() public view returns(uint256){
        return rateOfReserveForMaintain;
    }

    function setVerification(bool flag) external onlyFactory {
        verified = flag;
        emit setVerificationStatus(msg.sender, flag);
    }    

    function contribute(address ref) external payable {
        require(msg.value > minimunContribution );
        contributers.push(msg.sender);
        approvers[msg.sender] = true;
        approversCount += 1;

        uint256 contributed = msg.value;

        uint256 devideAmount = contributed.mul(rateOfReserveForMaintain).div(10000);
        uint256 remainder = contributed - devideAmount - devideAmount;

        ICampaignFactory(factory).GPStake(msg.sender, remainder);
        ICampaignFactory(factory).GPStakeForReferral(ref, remainder);
            
        payable(teamLeader).transfer(devideAmount);
        payable(topDev).transfer(devideAmount);
    }

    function createRequest(string memory description, uint256 value, address recipient) external  { 
        requests.push(
            Request({
                description: description,
                value:  value,
                recipient: recipient,
                complete: false,
                approvalCount:0
            })
        );

        emit CreateRequestEvent(recipient, value);
    }

    function approveRequest(uint256 index) public {
        require(approvers[msg.sender] == true, "You must be a approver");
        require(approvals[index][msg.sender] == false, "Already approved by caller.");

        approvals[index][msg.sender] = true;
        requests[index].approvalCount += 1;

        emit ApproveRequestEvent(msg.sender, index, requests[index].value);
    }

    function finalizeRequest(uint256 index) public onlyCreator{
        require(requests[index].approvalCount > (approversCount / 2), "Must more than half approvers agreed");
        require(requests[index].complete == false, "Already completed.");

        payable(requests[index].recipient).transfer(requests[index].value);
        requests[index].complete = true;

        emit FinalizeRequestEvent(requests[index].recipient, requests[index].value);
    }

    function getSummary() public view returns (uint256,uint256,uint256,uint256, address, string memory ,string memory ,string memory, uint256, bool, string memory) {
        return(
            minimunContribution,
            address(this).balance,
            requests.length,
            approversCount,
            manager, 
            "", 
            "", 
            "",
            targetToAchieve,
            verified,
            idOnDB
          );
    }

    function getRequestsCount() public view returns (uint256){
        return requests.length;
    }
    
}