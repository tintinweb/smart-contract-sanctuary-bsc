/**
 *Submitted for verification at BscScan.com on 2022-08-20
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

// File: InvestmentDAO/DAO.sol


pragma solidity ^0.8.7;


interface xDAOContract {
    function balanceOf(address,uint256) external view returns(uint256);
}

//INVESTMENT DAO

contract secretDAO{
    address public owner;
    uint256 nextProposal;
    uint256[] public validTokensCreator;
    uint256[] public validTokensVoter;
    xDAOContract daoContract;
    
    constructor(address xdaocontract){
        owner = msg.sender;
        nextProposal = 1;
        daoContract = xDAOContract(xdaocontract); 
        validTokensCreator = [1];
        validTokensVoter = [1,2,3]; 
    }

    struct proposal{
        uint256 id;
        bool exists;
        string title;
        string description;
        string category;
        bool canceled;
        uint deadline;
        uint256 votesUp;
        uint256 votesDown;
        mapping (address => bool) voteStatus;
        bool countConducted;
        bool passed;
        address creator;
    }

    mapping(uint256 => proposal) public Proposals;

    event proposalCreated(uint256 id, string description, address proposer);
    event newVote(uint256 votesUp, uint256 votesDown, address voter, uint256 proposal, bool votedFor);
    event proposalCount(uint256 id, bool passed);

    function checkProposalEligibility(address _proposalist) private view returns (bool){
        for(uint i = 0; i < validTokensCreator.length; i++){
            if(daoContract.balanceOf(_proposalist, validTokensCreator[i]) >= 1){
                return true;
            }
        }
        return false;
    }

    function checkVoteEligibility( address _proposalist) private view returns (bool){
        for(uint i = 0; i < validTokensVoter.length; i++){
            if(daoContract.balanceOf(_proposalist, validTokensVoter[i]) >= 1){
                return true;
            }
        }
        return false;
    }

    function createdProposal(string memory _title, string memory _category, string memory _description) public{
        require(checkProposalEligibility(msg.sender), "Only NFT holders can put forth Proposals");

        proposal storage newProposal = Proposals[nextProposal];
        newProposal.id = nextProposal;
        newProposal.exists = true;
        newProposal.canceled = false;
        newProposal.description = _description;
        newProposal.title = _title;
        newProposal.category = _category;

        newProposal.deadline = block.timestamp + 30 minutes;
        newProposal.creator = msg.sender;

        emit proposalCreated(nextProposal, _description,msg.sender);
        nextProposal++;
    }

    function voteOnProposal(uint256 _id, bool _vote) public {
        require(Proposals[_id].exists, "This Proposal does not exist");
        require(checkVoteEligibility(msg.sender), "You can not vote on this Proposal");
        require(!Proposals[_id].voteStatus[msg.sender], "You have already voted on this Proposal");
        require(block.timestamp <= Proposals[_id].deadline, "The deadline has passed for this Proposal");

        proposal storage p = Proposals[_id];

        if(_vote) {
            p.votesUp++;
        }else{
            p.votesDown++;
        }

        p.voteStatus[msg.sender] = true;

        emit newVote(p.votesUp, p.votesDown, msg.sender, _id, _vote);
        
    }

    function countVotes(uint256 _id) public {
        require(msg.sender == owner, "Only Owner Can Count Votes");
        require(Proposals[_id].exists, "This Proposal does not exist");
        require(block.number > Proposals[_id].deadline, "Voting has not concluded");
        require(!Proposals[_id].countConducted, "Count already conducted");

        proposal storage p = Proposals[_id];
        
        if(Proposals[_id].votesDown < Proposals[_id].votesUp){
            p.passed = true;            
        }

        if(block.timestamp > Proposals[_id].deadline){
            p.passed = true;
        }

        p.countConducted = true;

        emit proposalCount(_id, p.passed);
    }

    function addTokenId(uint256 _tokenId) public {
        require(msg.sender == owner, "Only Owner Can Add Tokens");

        validTokensVoter.push(_tokenId);
    }

    function cancelProposal(uint256 _id,bool _canceled) public{
        proposal storage p = Proposals[_id];
        require(p.creator == msg.sender, "Cancel not possible! Your aren't the creator!");
        p.canceled = _canceled;
    }

    function checkDeadlineToSwap(uint256 _id) public view returns(string memory){
        proposal storage p = Proposals[_id];
        require(p.passed,"This havn't matched!");
        return "This is a Match";
    }

    function addVaultStrategy() private {

    }

    function removeVaultStrategy() private {
        
    }


}