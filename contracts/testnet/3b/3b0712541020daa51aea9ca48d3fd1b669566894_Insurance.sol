/**
 *Submitted for verification at BscScan.com on 2022-07-19
*/

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol


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

// File: Insurance.sol



pragma solidity ^0.8.7;


contract Insurance {

    using SafeMath for uint;

    mapping (address => bool) insurers;

    enum PolicyState { INITIALIZED, LOCKED, PREMIUM, PAYOUT, COMPLETED }

    address owner;

    struct Policy {
        string terms;
        uint256 premium;
        uint256 payout;
        uint256 claimTime;
        address payable insurer;
        address payable insured;
        PolicyState state;
    }

    mapping (uint256 => Policy) policies;

    uint256 policyCount = 0;

    struct PolicyOwner {
        uint256 count;
        uint256[] policies;
    }

    mapping (address => PolicyOwner) policyOwners;

    mapping (address => bool) agents;

    modifier onlyValidAddress() {
        require(msg.sender == address(0), "ERROR: invalid account");
        _;
    }

    modifier onlyValidPolicy(uint256 id) {
        require(policies[id].insured != address(0), "ERROR: invalid account");
        _;
    }

    modifier onlyNonInitializedPolicy(uint256 id) {
        require(policies[id].state != PolicyState.INITIALIZED, "ERROR: policy has been completed");
        _;
    }

    modifier onlyAgent() {
        require(agents[msg.sender] == true, "ERROR: address does not belong to an agent");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "ERROR: address does not belong to owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createPolicy(
        string memory terms,
        uint256 premium,
        uint256 payout,
        uint256 claimTime,
        address payable insurer) public payable {

            require(msg.value == premium, "ERROR: not enough value");

            policies[policyCount] = Policy(
                terms, 
                premium, 
                payout, 
                claimTime, 
                insurer,
                payable(msg.sender),
                PolicyState.INITIALIZED
            );

            policyOwners[msg.sender].policies[policyOwners[msg.sender].count] = policyCount;

            policyOwners[msg.sender].count += 1;

    }

    function getPolicy(uint256 id) public onlyValidPolicy(id) view returns (string memory, uint256, uint256, uint256, address, address) {
        
        return (
            policies[id].terms,
            policies[id].premium,
            policies[id].payout,
            policies[id].claimTime,
            policies[id].insurer,
            policies[id].insured
        );

    }

    function acceptPolicy(uint256 id) public payable onlyValidAddress onlyValidPolicy(id) onlyNonInitializedPolicy(id) {

        require(address(0) == policies[id].insurer, "ERROR: policy already accepted");

        require(msg.sender != policies[id].insured, "ERROR: you can not accept a policy made by you");

        require(policies[id].payout == msg.value, "ERROR: Not enough value to accept policy");

        payable(msg.sender).transfer(policies[id].premium);

        policies[id].insurer = payable(msg.sender);

        policies[id].state = PolicyState.LOCKED;

    }

    function claimPremiumByInsurer(uint256 id) public payable onlyValidAddress onlyValidPolicy(id) {

        require(msg.sender == policies[id].insurer, "ERROR: you can not make a claim");

        require(block.timestamp >= policies[id].claimTime + 3 days, "ERROR: claim not matured");

        require(policies[id].state == PolicyState.PREMIUM, "ERROR: you can not claim the premium");

        payable(msg.sender).transfer(policies[id].payout);
        
        policies[id].state = PolicyState.COMPLETED;

    }

    function claimPayoutByInsured(uint256 id) public payable onlyValidAddress onlyValidPolicy(id)  {

        require(msg.sender == policies[id].insured, "ERROR: you can not make a claim");

        require(block.timestamp >= policies[id].claimTime + 3 days, "ERROR: claim not matured");

        require(policies[id].state == PolicyState.PAYOUT, "ERROR: you can not claim the premium");

        payable(msg.sender).transfer(policies[id].payout);

        policies[id].state = PolicyState.COMPLETED;

    }

    function awardToInsurer(uint256 id) public payable onlyValidAddress onlyAgent onlyValidPolicy(id)  {

        require(block.timestamp >= policies[id].claimTime + 3 days, "ERROR: claim not matured");

        require(policies[id].state == PolicyState.LOCKED, "ERROR: claim is not locked");

        require(agents[msg.sender] == true, "ERROR: not an agent");

        policies[id].state = PolicyState.PREMIUM;

    }

    function awardToInsured(uint256 id) public payable onlyValidAddress onlyAgent onlyValidPolicy(id)  {

        require(block.timestamp >= policies[id].claimTime + 3 days, "ERROR: claim not matured");

        require(policies[id].state == PolicyState.LOCKED, "ERROR: claim is not locked");

        require(agents[msg.sender] == true, "ERROR: not an agent");

        policies[id].state = PolicyState.PAYOUT;

    }

    function addAgent(address agentWallet) public onlyOwner {
        agents[agentWallet] = true;
    }


    function removeAgent(address agentWallet) public onlyOwner {
        agents[agentWallet] = true;
    }


}