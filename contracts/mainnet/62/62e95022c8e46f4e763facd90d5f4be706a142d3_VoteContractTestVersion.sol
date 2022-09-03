/**
 *Submitted for verification at BscScan.com on 2022-09-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

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

interface StakeContract {
    function getUserDepositAmountByPid(uint256 pid, address addr) external view returns(uint256);
}

interface NFTContract {
    function getCommunityLeader(address addr) external view returns(bool);
}

contract VoteContractTestVersion is Ownable {
    address public stakeContract;
    address public nftContract;
    uint256 public stakeTOVoteMultiple;
    uint256 public transferFee = 0.001 ether;
    address public transferFeeRecipient = 0x0fBB5A560fd138F93593A341ec5425C44778e02d;

    struct UserData {
        uint256 totalReceivedVotes;
        uint256 remainingVotes;
        uint256 totalVotedVotes;
        address voteWho;
    }

    event Claim(address addr,uint256 amount);

    mapping(address => UserData) public userData;
    mapping(uint256 => mapping(address => uint256)) public userClaimVotes;
    mapping(address => uint256) public communityleaderVotes;

    constructor() {
        setStakeTOVoteMultiple(10000);
    }

    function claim(uint256 pid) public {
        uint256 userDepositLP = StakeContract(stakeContract).getUserDepositAmountByPid(pid, msg.sender);
        require(userDepositLP > 0, "claim: You are not staked in this pool and cannot get votes!");
        uint256 pendingVotes = userDepositLP * stakeTOVoteMultiple - userClaimVotes[pid][msg.sender];
        require(pendingVotes > 0, "claim: You have no more votes to claim at the moment!");
        userClaimVotes[pid][msg.sender] = userClaimVotes[pid][msg.sender] + pendingVotes;
        userData[msg.sender].totalReceivedVotes = userData[msg.sender].totalReceivedVotes + pendingVotes;
        userData[msg.sender].remainingVotes = userData[msg.sender].remainingVotes + pendingVotes;
        emit Claim(msg.sender, pendingVotes);
    }

    function vote(address addr) public {
        require(NFTContract(nftContract).getCommunityLeader(addr), "vote: The wallet address you voted for is not the community leader!");
        require(voteDetection(addr), "vote: You cannot vote for two people, please withdraw the votes first if necessary!");
        require(userData[msg.sender].remainingVotes > 0, "vote: You don't have extra votes to vote!");
        communityleaderVotes[addr] = communityleaderVotes[addr] + userData[msg.sender].remainingVotes;
        userData[msg.sender].totalVotedVotes = userData[msg.sender].totalVotedVotes + userData[msg.sender].remainingVotes;
        userData[msg.sender].remainingVotes = 0;
        userData[msg.sender].voteWho = addr;
    }

    function voteDetection(address addr) internal view returns(bool) {
        if(userData[msg.sender].voteWho != address(0)){
            return (addr == userData[msg.sender].voteWho);
        } else {
            return true;
        }
    }

    function withdrawVote() public payable {
        require(msg.value == transferFee, "transferFrom: Insufficient funds!");
        require(userData[msg.sender].totalVotedVotes > 0, "withdrawVote: You haven't voted yet!");
        (bool success, ) = payable(transferFeeRecipient).call{value: transferFee}('');
        require(success, "withdrawVote: unable to send transferFee, recipient may have reverted");
        communityleaderVotes[userData[msg.sender].voteWho] = communityleaderVotes[userData[msg.sender].voteWho] - userData[msg.sender].totalVotedVotes;
        userData[msg.sender].remainingVotes = userData[msg.sender].remainingVotes + userData[msg.sender].totalVotedVotes;
        userData[msg.sender].totalVotedVotes = 0;
        userData[msg.sender].voteWho = address(0);
    }

    function destroyVote(uint256 pid, address addr) public {
        require(msg.sender == stakeContract, "destroyVote: not the correct caller");
        if(userData[addr].remainingVotes > userClaimVotes[pid][addr] && userData[addr].totalReceivedVotes > userClaimVotes[pid][addr]) {
            userData[addr].totalReceivedVotes = userData[addr].totalReceivedVotes - userClaimVotes[pid][addr];
            userData[addr].remainingVotes = userData[addr].remainingVotes - userClaimVotes[pid][addr];
            userClaimVotes[pid][addr] = 0;
        } else if (userData[addr].remainingVotes < userClaimVotes[pid][addr] && userData[addr].totalReceivedVotes > userClaimVotes[pid][addr]) {
            uint256 difference = userClaimVotes[pid][addr] - userData[addr].remainingVotes;
            userData[addr].totalReceivedVotes = userData[addr].totalReceivedVotes - userClaimVotes[pid][addr];
            userData[addr].totalVotedVotes = userData[addr].totalVotedVotes - difference;
            communityleaderVotes[userData[addr].voteWho] = communityleaderVotes[userData[addr].voteWho] - difference;
            userData[addr].remainingVotes = 0;
            userClaimVotes[pid][addr] = 0;
        } else if (userData[addr].totalReceivedVotes == userClaimVotes[pid][addr]) {
            communityleaderVotes[userData[addr].voteWho] = communityleaderVotes[userData[addr].voteWho] - userData[addr].totalVotedVotes;
            userData[addr].totalReceivedVotes = 0;
            userData[addr].remainingVotes = 0;
            userData[addr].totalVotedVotes = 0;
            userData[addr].voteWho = address(0);
            userClaimVotes[pid][addr] = 0;
        } 
    }

    function getCLeaderVotes(address addr) public view returns(uint256) {
        return communityleaderVotes[addr];
    }

    function getPendingVotes(uint256 pid, address addr) external view returns(uint256 pendingVotes) {
        uint256 userDepositLP = StakeContract(stakeContract).getUserDepositAmountByPid(pid, addr);
        pendingVotes = userDepositLP * stakeTOVoteMultiple - userClaimVotes[pid][addr];
        return pendingVotes;    
    }

    function setTransferFee(uint256 _transferFee) public onlyOwner {
        transferFee = _transferFee;
    }

    function setTransferFeeRecipient(address _transferFeeRecipient) public onlyOwner {
        transferFeeRecipient = _transferFeeRecipient;
    }

    function setStakeContract(address _newStakeContract) public onlyOwner {
        stakeContract = _newStakeContract;
    }

    function setNFTContract(address _newNFTContract) public onlyOwner {
        nftContract = _newNFTContract;
    }

    function setStakeTOVoteMultiple(uint256 _newStakeTOVoteMultiple) public onlyOwner {
        stakeTOVoteMultiple = _newStakeTOVoteMultiple;
    }
}