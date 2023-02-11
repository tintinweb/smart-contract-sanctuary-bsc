/**
 *Submitted for verification at BscScan.com on 2023-02-10
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.12;
/**
 * @title Ballot
 * @author PoongodiWealwin
 * @dev Implements voting process along with winning candidate
 */

 abstract contract Context {

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    uint256[50] private __gap;
}

abstract contract Ownable is Context{
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    uint256[49] private __gap;
}

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


contract Ballot is Ownable{
    struct Voter {
        uint256 aadharNumber; // voter unique ID
        string name;
        uint8 age;
        bool isAlive;
        uint256 votedTo; // aadhar number of the candidate
    }

    struct Candidate {
        // Note: If we can limit the length to a certain number of bytes,
        // we can use one of bytes1 to bytes32 because they are much cheaper
        string name;
        string partyShortcut;
        string partyFlag;
        uint256 nominationNumber; // unique ID of candidate
    }

    struct Results {
        string name;
        string partyShortcut;
        string partyFlag;
        uint256 voteCount; // number of accumulated votes
        uint256 nominationNumber; // unique ID of candidate
    }
    mapping(uint256 => Voter) voter;
    mapping(uint256 => Candidate) candidate;
    mapping(uint256 => uint256) internal votesCount;
    uint256[] public joinedAadhar;
    address electionChief;
    uint256 private votingStartTime;
    uint256 private votingEndTime;
    uint256 public  candidatesCount;

    using SafeMath for uint256;

    /**
     * @dev Create a new ballot to choose one of 'candidateNames'
     * @param startTime_ When the voting process will start
     * @param endTime_ When the voting process will end
     */
    constructor(uint256 startTime_, uint256 endTime_) {
        initializeCandidateDatabase_();
        initializeVoterDatabase_();
        votingStartTime = startTime_;
        votingEndTime = endTime_;
        electionChief = msg.sender;
        candidatesCount = 6;
    }

    /**
     * @dev Get candidate list.
     * @return candidatesList_ All the politicians who participate in the election
     */
    function getCandidateList()
        public
        view
        returns (Candidate[] memory)
    {
        Candidate[] memory ret = new Candidate[](joinedAadhar.length);
        for (uint i = 0; i < joinedAadhar.length; i++) {
            uint256 _id = joinedAadhar[i];
            ret[i] = candidate[_id];
        }
        return ret;
    }

    /**
     * @dev Get candidate list.
     * @param voterAadharNumber Aadhar number of the current voter to send the relevent candidates list
     * @return voterEligible_ Whether the voter with provided aadhar is eligible or not
     */
    function isVoterEligible(uint256 voterAadharNumber)
        public
        view
        returns (bool voterEligible_)
    {
        Voter storage voter_ = voter[voterAadharNumber];
        if (voter_.age >= 18 && voter_.isAlive) voterEligible_ = true;
    }

    /**
     * @dev Know whether the voter casted their vote or not. If casted get candidate object.
     * @param voterAadharNumber Aadhar number of the current voter
     * @return userVoted_ Boolean value which gives whether current voter casted vote or not
     * @return candidate_ Candidate details to whom voter casted his/her vote
     */
    function didCurrentVoterVoted(uint256 voterAadharNumber)
        public
        view
        returns (bool userVoted_, Candidate memory candidate_)
    {
        userVoted_ = (voter[voterAadharNumber].votedTo != 0);
        if (userVoted_)
            candidate_ = candidate[voter[voterAadharNumber].votedTo];
    }

    /**
     * @dev Give your vote to candidate.
     * @param nominationNumber Aadhar Number of the candidate
     * @param voterAadharNumber Aadhar Number of the voter to avoid re-entry
     * @param currentTime_ To check if the election has started or not
     */
    function vote(
        uint256 nominationNumber,
        uint256 voterAadharNumber,
        uint256 currentTime_
    )
        public
        votingLinesAreOpen(currentTime_)
        isEligibleVote(voterAadharNumber, nominationNumber)
    {
        // updating the current voter values
        voter[voterAadharNumber].votedTo = nominationNumber;

        // updates the votes the politician
        uint256 voteCount_ = votesCount[nominationNumber];
        votesCount[nominationNumber] = voteCount_ + 1;
    }

    /**
     * @dev Gives ending epoch time of voting
     * @return endTime_ When the voting ends
     */
    function getVotingEndTime() public view returns (uint256 endTime_) {
        endTime_ = votingEndTime;
    }

    /**
     * @dev used to update the voting start & end times
     * @param startTime_ Start time that needs to be updated
     * @param currentTime_ Current time that needs to be updated
     */
    function updateVotingStartTime(uint256 startTime_, uint256 currentTime_)
        public
        isElectionChief
    {
        require(votingStartTime > currentTime_);
        votingStartTime = startTime_;
    }

    /**
     * @dev To extend the end of the voting
     * @param endTime_ End time that needs to be updated
     * @param currentTime_ Current time that needs to be updated
     */
    function extendVotingTime(uint256 endTime_, uint256 currentTime_)
        public
        isElectionChief
    {
        require(votingStartTime < currentTime_);
        require(votingEndTime > currentTime_);
        votingEndTime = endTime_;
    }

    /**
     * @dev sends all candidate list with their votes count
     * @param currentTime_ Current epoch time of length 10.
     * @return candidateList_ List of Candidate objects with votes count
     */
    function getResults(uint256 currentTime_)
        public
        view
        returns (Results[] memory)
    {
        require(votingEndTime < currentTime_);
        Results[] memory resultsList_ = new Results[](
            joinedAadhar.length
        );
        for (uint256 i = 0; i < joinedAadhar.length; i++) {
            uint256 _id = joinedAadhar[i];
            resultsList_[i] = Results({
                name: candidate[_id].name,
                partyShortcut: candidate[_id].partyShortcut,
                partyFlag: candidate[_id].partyFlag,
                nominationNumber: candidate[_id].nominationNumber,
                voteCount: votesCount[candidate[_id].nominationNumber]
            });
        }
        return resultsList_;
    }

    /**
     * @notice To check if the voter's age is greater than or equal to 18
     * @param currentTime_ Current epoch time of the voter
     */
    modifier votingLinesAreOpen(uint256 currentTime_) {
        require(currentTime_ >= votingStartTime);
        require(currentTime_ <= votingEndTime);
        _;
    }

    /**
     * @notice To check if the voter's age is greater than or equal to 18
     * @param voterAadhar_ Aadhar number of the current voter
     * @param nominationNumber_ Nomination number of the candidate
     */
    modifier isEligibleVote(uint256 voterAadhar_, uint256 nominationNumber_) {
        Voter memory voter_ = voter[voterAadhar_];
        Candidate memory politician_ = candidate[nominationNumber_];
        require(voter_.age >= 18);
        require(voter_.isAlive);
        require(voter_.votedTo == 0);
        _;
    }

    /**
     * @notice To check if the user is Election Chief or not
     */
    modifier isElectionChief() {
        require(msg.sender == electionChief);
        _;
    }

    function addCandidates(string memory _name , string memory _party , string memory _flag) public onlyOwner returns (bool) {
        uint256 id_ = addID(1).add(block.timestamp);
        Candidate memory _detail  = Candidate({
                            name: _name,
                            partyShortcut: _party,
                            partyFlag: _flag,
                            nominationNumber: uint256(id_)
                        });
        candidate[id_] = _detail;
        return true;
    }

    function editCandidates(string memory _name , string memory _party , string memory _flag , uint256 _nominateid) public onlyOwner returns (bool) {
        candidate[_nominateid].name = _name;
        candidate[_nominateid].partyShortcut = _party;
        candidate[_nominateid].partyFlag = _flag;
        return true;
    }

    function addVoters(string memory _name,uint256 _aadhar,uint8 age) public onlyOwner returns (bool) {
        require(voter[_aadhar].aadharNumber != _aadhar, "User exist");
        voter[uint256(_aadhar)] = Voter({
            name: _name,
            aadharNumber: uint256(_aadhar),
            age: uint8(age),
            isAlive: true,
            votedTo: uint256(0)
        });
        return true;
    }

    function addID(uint256 value) public returns (uint256) {
        candidatesCount = candidatesCount + value;
        return candidatesCount;
    }

    /**
     * Dummy data for Candidates
     * In the future, we can accept the same from construction,
     * which will be called at the time of deployment
     */
    function initializeCandidateDatabase_() internal {
        Candidate memory _detail;
        _detail = Candidate({
            name: "Chandra Babu Naidu",
            partyShortcut: "TDP",
            partyFlag: "https://res.cloudinary.com/dj9ttsbgm/image/upload/v1648101065/tdp_qh1rkj.png",
            nominationNumber: uint256(727477314982)
        });
        candidate[uint256(727477314982)] = _detail;
        joinedAadhar.push(uint256(727477314982));
        _detail= Candidate({
            name: "Jagan Mohan Reddy",
            partyShortcut: "YSRCP",
            partyFlag: "https://res.cloudinary.com/dj9ttsbgm/image/upload/v1648101065/ysrcp_sas311.png",
            nominationNumber: uint256(835343722350)
        });
        candidate[uint256(835343722350)] = _detail;
        joinedAadhar.push(uint256(835343722350));
        _detail = Candidate({
            name: "Narendra Modi",
            partyShortcut: "BJP",
            partyFlag: "https://res.cloudinary.com/dj9ttsbgm/image/upload/v1648101064/bjp_nk4snw.png",
            nominationNumber: uint256(895363124093)
        });
        candidate[uint256(895363124093)] = _detail;
        joinedAadhar.push(uint256(895363124093));
        _detail  = Candidate({
            name: "Jyoti Basu",
            partyShortcut: "CPIM",
            partyFlag: "https://res.cloudinary.com/dj9ttsbgm/image/upload/v1648101064/1024px-Cpim_party_symbol.svg_mu1gpp.png",
            nominationNumber: uint256(615325500020)
        });
        candidate[uint256(615325500020)] = _detail;
        joinedAadhar.push(uint256(615325500020));
        _detail = Candidate({
            name: "Priyanka Gandhi",
            partyShortcut: "INC",
            partyFlag: "https://res.cloudinary.com/dj9ttsbgm/image/upload/v1648101064/inc_s1oqn5.png",
            nominationNumber: uint256(866627241136)
        });
        candidate[uint256(866627241136)] = _detail;
        joinedAadhar.push(uint256(866627241136));
        _detail = Candidate({
            name: "Lalu Yadav",
            partyShortcut: "RJD",
            partyFlag: "https://res.cloudinary.com/dj9ttsbgm/image/upload/v1648101065/1200px-RJD_Flag.svg_arrrvt.png",
            nominationNumber: uint256(765724506305)
        });
        candidate[uint256(765724506305)] = _detail;
        joinedAadhar.push(uint256(765724506305));
        _detail = Candidate({
            name: "Manish Sisodia",
            partyShortcut: "AAP",
            partyFlag: "https://res.cloudinary.com/dj9ttsbgm/image/upload/v1648101065/aap_ujguyl.png",
            nominationNumber: uint256(897855877716)
        });
        candidate[uint256(897855877716)] = _detail;
        joinedAadhar.push(uint256(897855877716));
    }

    /**
     * Dummy data for Aadhar users
     * In the future, we can have a an external API cal to centralized aadhar DB
     * https://ethereum.stackexchange.com/a/334
     * https://docs.chain.link/docs/make-a-http-get-request/
     */
    function initializeVoterDatabase_() internal {
        // Andhra Pradesh
        voter[uint256(482253918244)] = Voter({
            name: "Suresh",
            aadharNumber: uint256(482253918244),
            age: uint8(21),
            isAlive: true,
            votedTo: uint256(0)
        });
        voter[uint256(532122269467)] = Voter({
            name: "Ramesh",
            aadharNumber: uint256(532122269467),
            age: uint8(37),
            isAlive: false,
            votedTo: uint256(0)
        });
        voter[uint256(468065932286)] = Voter({
            name: "Mahesh",
            aadharNumber: uint256(468065932286),
            age: uint8(26),
            isAlive: true,
            votedTo: uint256(0)
        });
        voter[uint256(809961147437)] = Voter({
            name: "Krishna",
            aadharNumber: uint256(809961147437),
            age: uint8(19),
            isAlive: true,
            votedTo: uint256(0)
        });
        voter[uint256(908623597782)] = Voter({
            name: "Narendra",
            aadharNumber: uint256(908623597782),
            age: uint8(36),
            isAlive: true,
            votedTo: uint256(0)
        });
        voter[uint256(760344621247)] = Voter({
            name: "Raghu",
            aadharNumber: uint256(760344621247),
            age: uint8(42),
            isAlive: true,
            votedTo: uint256(0)
        });
        voter[uint256(908704156902)] = Voter({
            name: "Pushkar Kumar",
            aadharNumber: uint256(908704156902),
            age: uint8(25),
            isAlive: true,
            votedTo: uint256(0)
        });
        voter[uint256(778925466180)] = Voter({
            name: "Kunal Kumar",
            aadharNumber: uint256(778925466180),
            age: uint8(37),
            isAlive: true,
            votedTo: uint256(0)
        });
        voter[uint256(393071790055)] = Voter({
            name: "Kumar Sanket",
            aadharNumber: uint256(393071790055),
            age: uint8(29),
            isAlive: true,
            votedTo: uint256(0)
        });
        voter[uint256(983881786161)] = Voter({
            name: "Pratik",
            aadharNumber: uint256(983881786161),
            age: uint8(40),
            isAlive: true,
            votedTo: uint256(0)
        });
        voter[uint256(756623869645)] = Voter({
            name: "Aausi",
            aadharNumber: uint256(756623869645),
            age: uint8(85),
            isAlive: false,
            votedTo: uint256(0)
        });
        voter[uint256(588109459505)] = Voter({
            name: "Pratiba",
            aadharNumber: uint256(588109459505),
            age: uint8(68),
            isAlive: false,
            votedTo: uint256(0)
        });
        voter[uint256(967746320661)] = Voter({
            name: "Ruchika",
            aadharNumber: uint256(967746320661),
            age: uint8(26),
            isAlive: true,
            votedTo: uint256(0)
        });
        voter[uint256(727938171119)] = Voter({
            name: "Rambabu",
            aadharNumber: uint256(727938171119),
            age: uint8(17),
            isAlive: true,
            votedTo: uint256(0)
        });
        voter[uint256(609015917688)] = Voter({
            name: "Matajii",
            aadharNumber: uint256(609015917688),
            age: uint8(98),
            isAlive: true,
            votedTo: uint256(0)
        });
        voter[uint256(620107691388)] = Voter({
            name: "Mamata",
            aadharNumber: uint256(620107691388),
            age: uint8(63),
            isAlive: false,
            votedTo: uint256(0)
        });
        voter[uint256(403561319377)] = Voter({
            name: "Ravi Varma",
            aadharNumber: uint256(403561319377),
            age: uint8(42),
            isAlive: true,
            votedTo: uint256(0)
        });
        voter[uint256(837970229674)] = Voter({
            name: "Rahul",
            aadharNumber: uint256(837970229674),
            age: uint8(56),
            isAlive: true,
            votedTo: uint256(0)
        });
    }
}