/**
 *Submitted for verification at BscScan.com on 2022-07-21
*/

// File: Itreasury.sol


pragma solidity ^0.8.0;


interface ITreasury{
    function isAdmin(address account) external view returns (bool);
    function isSuperOperator(address account) external view returns (bool);
    function isModerationOperator(address account) external view returns (bool);
}
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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
}

// File: dao.sol



pragma solidity ^0.8.7;


contract Dao {
    address public owner;
    uint256 nextProposal;
    IERC20 validToken;
    ITreasury treasury;
    constructor(address coin,address _treasury){
        owner = msg.sender;
        nextProposal = 1;
        treasury=ITreasury(_treasury);
        validToken = IERC20(coin);
    }

    struct proposal{
        uint256 id;
        bool exists;
        string description;
        uint256 deadline;
        uint256 votesUp;
        uint256 votesDown;
        uint256 maxVotes;
        address[] voters;
        mapping(address => bool) voteStatus;
        mapping(address => uint256) votersAmounts;
        bool countConducted;
        bool passed;
    }

    mapping(uint256 => proposal) public Proposals;

    event proposalCreated(
        uint256 id,
        string description,
        uint256 maxVotes,
        address proposer
    );

    event newVote(
        uint256 votesUp,
        uint256 votesDown,
        address voter,
        uint256 proposal,
        bool votedFor
    );

    event proposalCount(
        uint256 id,
        bool passed
    );


    function checkProposalEligibility(address _proposalist) private view returns (
        bool
    ){
            if(validToken.balanceOf(_proposalist) >= 1 * 10 ** 18){
                return true;
        }
        return false;
    }


    function createProposal(string memory _description,uint256 maxVotes) public {
        require(checkProposalEligibility(msg.sender), "Only  holders can put forth Proposals");

        proposal storage newProposal = Proposals[nextProposal];
        newProposal.id = nextProposal;
        newProposal.exists = true;
        newProposal.description = _description;
        newProposal.deadline = block.timestamp + 60 * 60;
        newProposal.maxVotes = maxVotes;

        emit proposalCreated(nextProposal, _description,maxVotes, msg.sender);
        nextProposal++;
    }


    function voteOnProposal(uint256 _id, bool _vote,uint256 _amountVote) public {
        require(Proposals[_id].exists, "This Proposal does not exist");
        require(!Proposals[_id].voteStatus[msg.sender], "You have already voted on this Proposal");
        require(block.timestamp <= Proposals[_id].deadline, "The deadline has passed for this Proposal");
        require(validToken.balanceOf(msg.sender) >= _amountVote * 10 ** 18,"Not enough coins");
        validToken.transferFrom(msg.sender,address(this),_amountVote * 10 ** 18);
        proposal storage p = Proposals[_id];
        p.voters.push(msg.sender);
        p.votersAmounts[msg.sender]=_amountVote;
        if(_vote) {
            p.votesUp++;
        }else{
            p.votesDown++;
        }

        p.voteStatus[msg.sender] = true;

        emit newVote(p.votesUp, p.votesDown, msg.sender, _id, _vote);
    }
    function countVotes(uint256 _id) public {
        require(treasury.isAdmin(msg.sender),"AdminRole: caller does not have the Admin role");
        require(Proposals[_id].exists, "This Proposal does not exist");
        require(block.timestamp > Proposals[_id].deadline, "Voting has not concluded");
        require(!Proposals[_id].countConducted, "Count already conducted");

        proposal storage p = Proposals[_id];
        for (uint256 i = 0; i < p.voters.length; i++) {
             validToken.transfer(p.voters[i],p.votersAmounts[p.voters[i]] * 10 ** 18);
        }
        if(Proposals[_id].votesDown < Proposals[_id].votesUp){
            p.passed = true;            
        }

        p.countConducted = true;

        emit proposalCount(_id, p.passed);
    }
}