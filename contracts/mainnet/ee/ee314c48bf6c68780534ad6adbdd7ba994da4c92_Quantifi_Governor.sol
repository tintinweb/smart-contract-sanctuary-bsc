/**
 *Submitted for verification at BscScan.com on 2023-03-09
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

// File: quantifi/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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
// File: quantifi/governance.sol


pragma solidity 0.8.10;



contract QNTFI{
    function getWeightAt(address who, uint timestamp) external view returns(uint weight){}
    function getTotalStakes() external view returns(uint _totalStakes){}
   }

contract Quantifi_Governor is Ownable {
    address public QNTFI_ADDRESS; // address of governance token
    uint public voteStartDelay;
    uint public voteOpenTime;
    uint public executeDelay;
    uint public voteCount;
    uint public quorumPercent;
    uint public passProposalPercent;
    struct Vote {
        uint stakeWeight;
        mapping (address=>uint) choice;
        uint weightVoted;
        uint weightYes;
        uint proposeTimestamp;
        uint voteStartTimestamp;
        uint voteEndTimestamp;
        uint executeAfter;
        string description;
        address[] targets;
        bytes[] data;
        uint executed;
    }

    mapping (uint => Vote) public votes;

    event NewProposalCreated(uint voteId, string description);
    event VoteExecuted(uint voteId);
    event VoteRecorded(uint voteId, address addr, uint weight, uint choice);
    constructor(address _QNTFI) {
        voteStartDelay=1 days;
        voteOpenTime=7 days;
        executeDelay =2 days;
        quorumPercent = 20;
        passProposalPercent = 50;
        QNTFI_ADDRESS=_QNTFI;
    }

    // we are going to explicitly specify the things that can be proposed - i.e each proposal option will have a separate function call
    function proposeVote(address[] memory _targets, string memory _description, bytes[] memory _data) external{
        votes[voteCount].proposeTimestamp=block.timestamp;
        votes[voteCount].voteStartTimestamp = block.timestamp + voteStartDelay;
        votes[voteCount].voteEndTimestamp = votes[voteCount].voteStartTimestamp + voteOpenTime;
        votes[voteCount].executeAfter = votes[voteCount].voteEndTimestamp + executeDelay;
        votes[voteCount].targets = _targets;
        votes[voteCount].description = _description;
        votes[voteCount].data = _data;

        // emit event
        emit NewProposalCreated(voteCount,_description);
        // increment votecount
        voteCount+=1;
    }

    // we are defining 0 as not voted, 1 as voted yes, 2 as anything else
    function voteOnProposal(uint voteId, uint choice) external {
        require(block.timestamp>=votes[voteId].voteStartTimestamp,"Voting has not yet started");
        require(block.timestamp<=votes[voteId].voteEndTimestamp,"Voting has already finished");
        require(votes[voteId].choice[msg.sender]==0,"Sender address has already voted");

        // if this is the first vote, we set the stake weight at this point in time
        if (votes[voteId].stakeWeight==0){
            votes[voteId].stakeWeight = QNTFI(QNTFI_ADDRESS).getTotalStakes();
        }
        uint weight = QNTFI(QNTFI_ADDRESS).getWeightAt(msg.sender,votes[voteId].voteStartTimestamp);
        require(weight>0,"Not eligible to vote");
        votes[voteId].weightVoted+=weight;
        votes[voteId].choice[msg.sender]=choice;
        if (choice == 1){
            votes[voteId].weightYes += weight;
        }
        emit VoteRecorded(voteId, msg.sender, weight, choice);
    }
    
    function executeVote(uint voteId) external{
        require(votes[voteId].voteStartTimestamp>0,"No proposal exists for this voteId");
        require(votes[voteId].executeAfter<block.timestamp,"Execute time has not yet passed");
        require(votes[voteId].weightVoted>=votes[voteId].stakeWeight * quorumPercent / 100,"Not enough votes were received");
        require(votes[voteId].weightYes>=votes[voteId].weightVoted * passProposalPercent / 100,"Vote did not pass");
        require(votes[voteId].executed==0,"Vote has already been executed");
        
        // execute the vote
        votes[voteId].executed=1;
        address[] memory targets = votes[voteId].targets;
        bytes[] memory calldatas = votes[voteId].data;
        for (uint256 i = 0; i < targets.length; ++i) {
            (bool success, ) = targets[i].call(calldatas[i]);
            require(success);
        }   
        emit VoteExecuted(voteId);     
    }

    function getTargets(uint voteId) external view returns (address[] memory){
        return votes[voteId].targets;
    }

    function getCalldatas(uint voteId) external view returns (bytes[] memory){
        return votes[voteId].data;
    }

    function hasVoted(uint voteId,address addr)external view returns (bool res){
        return votes[voteId].choice[addr]>0;
    }
    
    // Owner functions - will be called by the contract itself
    function updateVoteOpenTime(uint numDays) public onlyOwner{
        voteOpenTime = numDays * 1 days;
    }

    function updateQuorum(uint percentage) public onlyOwner {
        require(percentage>0 && percentage<100);
        quorumPercent = percentage;
    }
}