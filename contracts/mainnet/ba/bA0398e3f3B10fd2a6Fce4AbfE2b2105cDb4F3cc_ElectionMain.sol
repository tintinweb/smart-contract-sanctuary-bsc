// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ElectionMain is Ownable{
    address[] approvedElections;
    address[] pendingElections;
    address gctcAddress;
    uint256 public requiredGCTCamountToCreateTopic;
    uint256 public requiredGCTCamountToVote;
    uint256[] stringLimit = [32,1000,32];
    uint public totalTopics;

    constructor(address _gctcAddress, uint256 _requiredGCTCamountToCreateTopic, uint256 _requiredGCTCamountToVote) {
        gctcAddress = _gctcAddress;
        requiredGCTCamountToCreateTopic = _requiredGCTCamountToCreateTopic;
        requiredGCTCamountToVote = _requiredGCTCamountToVote;
    }

    mapping(address => bool) public moderators;
    mapping(address => uint256) ids;
    mapping(address => bool) hasApproved;
    mapping(address => bool) hasRejected;
    mapping(address => bool) valid;
    
    function createElection(string memory title, string memory description, string memory category) public {
        require(IERC20(gctcAddress).balanceOf(msg.sender) >= requiredGCTCamountToCreateTopic,"Not enough token to create election.");
        require(bytes(title).length> 0,"Require Valid title.");
        require(bytes(description).length> 0,"Require Valid description");
        require(bytes(title).length<= stringLimit[0],"expect less char for title");
        require(bytes(description).length<= stringLimit[1],"expect less char for description");
        require(bytes(category).length<= stringLimit[2],"expect less char for category");

        address cont = address(new Election(msg.sender, title, description, category, gctcAddress, requiredGCTCamountToVote));
        
        ++totalTopics;
        ids[cont] = totalTopics; 
        pendingElections.push(cont);
        valid[cont] = true;
    }

    function approveTopic(address _topicAddress) public{
        require(valid[_topicAddress],"Not Valid Address");
        require(!hasApproved[_topicAddress],"Already Approved");
        require(!hasRejected[_topicAddress],"Already Rejected");
        require(moderators[msg.sender], "You need to be Moderator");
        uint256 id = ids[_topicAddress];
        delete pendingElections[id-1];
        approvedElections.push(_topicAddress);
        hasApproved[_topicAddress] = true;
    } 

    function rejectTopic(address _topicAddress) public{
        require(valid[_topicAddress],"Not Valid Address");
        require(!hasApproved[_topicAddress],"Already Approved");
        require(!hasRejected[_topicAddress],"Already Rejected");
        require(moderators[msg.sender], "You need to be Moderator");
        uint256 id = ids[_topicAddress];
        delete pendingElections[id-1];
        hasRejected[_topicAddress] = true;
    }

    function addModerator(address _addModerator) public onlyOwner{
        moderators[_addModerator] = true;
    }   

    function addManyModerator(address[] memory _addModerators) public onlyOwner {
        for (uint256 i = 0; i < _addModerators.length; i++) {
        moderators[_addModerators[i]] = true;
    }
    }

    function removeModerator(address _removeModerator) public onlyOwner{
        moderators[_removeModerator] = false;
    } 

    function verifyModerators(address _moderatorAddress) public view returns (bool) {
        bool userIsModerator = moderators[_moderatorAddress];
        return userIsModerator;
    }    

    function setRequiredGCTCamountToCreateTopic(uint256 _requiredGCTCamountToCreateTopic) public onlyOwner{
        requiredGCTCamountToCreateTopic = _requiredGCTCamountToCreateTopic;
    }   

    function setRequiredGCTCamountToVote(uint256 _requiredGCTCamountToVote) public onlyOwner{
        requiredGCTCamountToVote = _requiredGCTCamountToVote;
    }

    function getApprovedElections() public view returns (address[] memory) {
        return approvedElections;
    }

    function getPendingElections() public view returns (address[] memory) {
        return pendingElections;
    }

    function setStringLimit(uint256 titleStringLimit,uint256 descriptionStringLimit,uint256 categoryStringLimit) public onlyOwner {
        stringLimit[0] = titleStringLimit;
        stringLimit[1] = descriptionStringLimit;
        stringLimit[2] = categoryStringLimit;
    }

    function getStringLimit() public view returns (uint256[] memory) {
        return stringLimit;
    }

}

contract Election {
    address public ORGANIZER;
    string[] public options;
    
    mapping(string => uint) totalVotes;
    mapping(address => bool) hasVoted;
    
    bool public votingStatus = false;
    string public description;
    string public title;
    string public category;
    address gctcAddress;
    uint256 requiredGCTCamountToVote;
    string winner;

    constructor(address _org, string memory _title, string memory _description, string memory _category, address _gctcAddress, uint256 _requiredGCTCamountToVote) {
        title = _title;
        description = _description;
        category = _category;
        ORGANIZER = _org;
        gctcAddress = _gctcAddress;
        requiredGCTCamountToVote = _requiredGCTCamountToVote;
        options = ["Accept","Reject"];
        for(uint i = 0; i<options.length; i++){
            totalVotes[options[i]] = 0;
        }
        winner = "";
        votingStatus = true;
    }
    
    function vote(uint i) public {
        require(votingStatus,"Voting is ended.");
        require(!hasVoted[msg.sender],"Already did a vote.");
        require(IERC20(gctcAddress).balanceOf(msg.sender) >= requiredGCTCamountToVote,"Not enough token to vote."); 

        hasVoted[msg.sender] = true;
        totalVotes[options[i]]++;
    }
    
    function endVoting() public{
        require(votingStatus);
        require(msg.sender == ORGANIZER,"You are not owner.");
            if(totalVotes[options[0]] > totalVotes[options[1]]){
                winner = options[0];
            }else if (totalVotes[options[0]] < totalVotes[options[1]]){
                winner = options[1];
            }else{
                winner = "neutral";   
            }
        votingStatus = false;
        ORGANIZER = address(0);
    }
    
    function votesCount() public view returns (uint256[2] memory, uint256){
        uint256[2] memory count;
        uint256 total;
        count = [totalVotes[options[0]],totalVotes[options[1]]];
        total = count[0]+count[1];
        return (count,total);
    }   

    function result() public view returns (string memory){
        require(!votingStatus,"voting is not ended yet.");
        return winner;
    }

    function giveOptionsList() public view returns (string[] memory) {
        return options;
    }
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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