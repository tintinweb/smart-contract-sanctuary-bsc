/**
 *Submitted for verification at BscScan.com on 2022-04-21
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
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







contract MyDAO is Ownable {
    
    enum VotingOptions { Yes, No }
    enum Status { Accepted, Rejected, Pending }
    struct ProposalSub {
        uint256 id;
        address author;
        string name;
        string descrption;
        string contractAddress;
        string website;
        string telegram;
        string audit;
        string whitepaper;
        uint256 createdAt;
    }

        struct Proposal {
        uint256 id;
        string name;
        uint8 proposerId;
        uint256 createdAt;
        uint256 votesForYes;
        uint256 votesForNo;
        Status status;
    }

    // store all proposals
    mapping(uint => Proposal) public  proposals;
    mapping(uint => ProposalSub) public  proposers;
    // who already votes for who and to avoid vote twice
    mapping(address => mapping(uint => bool)) public votes;
    // the IERC20 allow us to use avax like our governance token.
    IERC20 public token;
    // the user need minimum 25 Creed to create a proposal.
    uint public CREATE_PROPOSAL_MIN_SHARE = 20 * 1000;
    uint public tokenDecimals = 1;
    uint public VOTE_MIN_SHARE = 1;
    uint constant VOTING_PERIOD = 7 days;
    uint public nextProposalId;
    uint public nextProposerId;
    uint public minimumVotes = 255;
    
    constructor(address _token, uint _decimals) {
        token = IERC20(_token); 
        tokenDecimals = _decimals;
        
    }

    function setLimits (uint _voteMinimumShare, uint _proposalMinimumShare, uint _minimumVotes) external onlyOwner {
        VOTE_MIN_SHARE = _voteMinimumShare;
        CREATE_PROPOSAL_MIN_SHARE = _proposalMinimumShare;
        minimumVotes = _minimumVotes;
    }

    function emegencyPowers(uint _proposalId, uint _Status_0isApproved_1isRejected) external onlyOwner {
    require(_Status_0isApproved_1isRejected == 0  || _Status_0isApproved_1isRejected == 1);
    
    if(_Status_0isApproved_1isRejected == 0){
    proposals[_proposalId].status = Status.Accepted;
    } else if(_Status_0isApproved_1isRejected == 1){
    proposals[_proposalId].status = Status.Rejected;
    } 


    }


    function createProposal(
        
        string memory name, 
        uint8  _proposalId
        
        ) external onlyOwner {
        // validate the user has enough shares to create a proposal
      //  require(token.balanceOf(msg.sender) >= CREATE_PROPOSAL_MIN_SHARE, 'Not enough balance to create a proposal');
        
        proposals[nextProposalId] = Proposal(
            nextProposalId,
            name,
            _proposalId,
            block.timestamp,
            0,
            0,
            Status.Pending
        );
        nextProposalId++;
    }
    

        function proposeProposal(
         
        string memory name, 
        string memory _descrption,
        string memory _contractAddress,
        string memory _website,
        string memory _telegram,
        string memory _audit,
        string memory _whitepaper
        
        ) external  {
        // validate the user has enough shares to create a proposal
       require(token.balanceOf(msg.sender) >= CREATE_PROPOSAL_MIN_SHARE * 10 ** tokenDecimals, 'Not enough balance to create a proposal');
        
        proposers[nextProposerId] = ProposalSub(
            nextProposalId,
            msg.sender,
            name,
            _descrption,
            _contractAddress,
            _website,
            _telegram,
            _audit,
            _whitepaper,
            block.timestamp
        );
        nextProposerId++;
    }



    function vote(uint _proposalId, VotingOptions _vote) external {
    Proposal storage proposal = proposals[_proposalId];
   require(token.balanceOf(msg.sender) >= VOTE_MIN_SHARE * 10 ** tokenDecimals, 'Not enough balance to vote');
    require(votes[msg.sender][_proposalId] == false, 'already voted');
    require(proposal.status == Status.Pending, 'Voting period is over');
    votes[msg.sender][_proposalId] = true;
   
    if(_vote == VotingOptions.Yes) {
       proposal.votesForYes++;
        if(proposal.votesForYes * 100 / (proposal.votesForYes + proposal.votesForNo) > 50 && minimumVotes <= (proposal.votesForYes + proposal.votesForNo)) {
            proposal.status = Status.Accepted;
        }
                if(proposal.votesForNo * 100 / (proposal.votesForYes + proposal.votesForNo) > 50 && minimumVotes <= (proposal.votesForYes + proposal.votesForNo)) {
            proposal.status = Status.Rejected;
        }
    } else {
        proposal.votesForNo += 1;
        if(proposal.votesForNo * 100 / (proposal.votesForYes + proposal.votesForNo) > 50 && minimumVotes <= (proposal.votesForYes + proposal.votesForNo)) {
            proposal.status = Status.Rejected;
        }
                if(proposal.votesForYes * 100 / (proposal.votesForYes + proposal.votesForNo) > 50 && minimumVotes <= (proposal.votesForYes + proposal.votesForNo)) {
            proposal.status = Status.Accepted;
        }
    }

  
}


  function checkBalance()  view  public  returns(uint){
      Proposal storage proposal = proposals[nextProposalId-1];
        return  (proposal.votesForYes + proposal.votesForNo);
    }

}