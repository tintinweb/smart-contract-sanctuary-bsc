/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Bep20TokenStaking {
    function users(uint256, address) external view returns (uint256, uint256, uint256, uint256);
    function poolInfo(uint256) external view returns (uint16, uint16, uint256, uint256, uint256, uint256);
    function poolLength() external view returns (uint256);
}

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
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
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


contract VotingContract is Ownable {

    using SafeMath for uint256;
    uint256 public proposalCount;
    uint32 public votingDuration;
    struct Proposal {
        string name;
        string[] choices;
        uint proposalId;
        uint startTime;
        uint totalVotes;
    }
    mapping(uint256 => Proposal) proposals;
    mapping(uint256 => mapping(string => uint256)) public proposalVotes; //how many votes a particular choice get
    mapping(uint256 => mapping(address => bool)) public proposalHasVoted; //mapping if a person voted in particular purposal
    Bep20TokenStaking public stakingContract;

    constructor(address _staking) {
        stakingContract = Bep20TokenStaking(_staking);
        proposalCount = 0;
    }

    /// @dev owner can add proposal description and choices using addProposal
    function addProposal(string memory _name, string[] memory _choices) public onlyOwner {
        if (proposalCount > 0){
        require(block.timestamp >= proposals[proposalCount - 1].startTime + votingDuration, "Previous proposal is still ongoing");
        }
        proposals[proposalCount] = Proposal({
            name: _name,
            choices: _choices,
            proposalId: proposalCount,
            startTime: block.timestamp,
            totalVotes: 0
        });
        for (uint i = 0; i < _choices.length; i++) {
            proposalVotes[proposalCount][_choices[i]] = 0;
        }
        proposalCount++;
    }

    /// @notice voters can vote using proposalID and selecting there choice
    function vote(uint _proposalId, string calldata _choice) public {
        require(_proposalId == 0 ||_proposalId < proposalCount, "Invalid proposal ID");
        require(block.timestamp <= proposals[proposalCount - 1].startTime + votingDuration, "Proposal has ended");
        require(!proposalHasVoted[_proposalId][msg.sender], "You have already voted for this proposal");
         Proposal storage proposal = proposals[_proposalId];
         uint256 votingPower = getVotingPower(msg.sender);
         require(votingPower > 0
         , "No voting power");
         proposalHasVoted[_proposalId][msg.sender] = true;
         for (uint i = 0; i < proposal.choices.length; i++) {
        if (keccak256(abi.encodePacked(proposal.choices[i])) == keccak256(abi.encodePacked(_choice))) {
        proposalVotes[_proposalId][_choice] = proposalVotes[_proposalId][_choice].add(votingPower);
        proposal.totalVotes = proposal.totalVotes.add(votingPower);
        break;
       }
     }

          proposal.totalVotes = proposal.totalVotes.add(votingPower);
   
    }

    /// @dev owner can set the voting period upto 1 month
    function setVotingPeriod (uint32 _seconds) external onlyOwner {
        require (_seconds <= 2592000 && _seconds >= 69120, "voting period should be b/w 2 to 30 days");
        votingDuration = _seconds;
    }

    /// @notice returns leading choice /winner for particular round
    ///@dev input proposalID to get the winner/leading choice
    function getWinner(uint _proposalId) public view returns (string memory) {
        require(_proposalId < proposalCount, "Invalid proposal ID");
        string memory winner;
        uint maxVotes = 0;
        for (uint i = 0; i < proposals[_proposalId].choices.length; i++) {
            if (proposalVotes[_proposalId][proposals[_proposalId].choices[i]] > maxVotes) {
                winner = proposals[_proposalId].choices[i];
                maxVotes = proposalVotes[_proposalId][winner];
            }
        }
        return winner;
    }

    /// @notice returns number of choice to be available for voting of current proposal 
    function getChoices() public view returns (string[] memory) {
        return proposals[proposalCount - 1].choices;
    }

    /// @notice returns current proposal id
    function getCurrentPurposalId () public view returns (uint256){
        if (proposalCount == 0) {
            return 0;
        }
        else {
            return proposalCount - 1;
        }
    }
    
    /// @notice returns voter power
    function getVotingPower(address _voter) public view returns (uint256) {
         uint256 poolList = stakingContract.poolLength();
         uint256 votingPower = 0;

         for (uint256 i=0; i<poolList; i++){
         (uint16 apy, , , uint256 startDate, , ) = stakingContract.poolInfo(i);
         (uint256 total_invested,,,) = stakingContract.users(i,_voter);
         uint256 reward = total_invested.mul(apy).mul(block.timestamp.sub(startDate)).div(365 days).div(10000);
         votingPower += total_invested + reward;
        }
         return votingPower.div(1e18);
    }

    /// @notice returns number of votes of particular proposal choice
    function getChoiceVotes(uint _proposalId, string memory _choice) public view returns (uint) {
        require(_proposalId < proposalCount, "Invalid proposal ID");
        return proposalVotes[_proposalId][_choice];
    }

    
}