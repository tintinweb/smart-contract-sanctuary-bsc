/**
 *Submitted for verification at BscScan.com on 2022-07-19
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-27
*/

// SPDX-License-Identifier: MIP

pragma solidity 0.8.10;

/*===================================================
    OpenZeppelin Contracts (last updated v4.5.0)
=====================================================*/

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


abstract contract Ownable is Context {
    address private _owner;
    address private _moderator;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _moderator = _msgSender();
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    function moderator() private view returns(address) {
        return _moderator;
    }

    

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender() || moderator() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    modifier onlyAuthorized() {
        require(owner() == msg.sender);
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

contract VotingSystem is Ownable {

    struct Candidate { // Struct
        string name;
        string mission;
        string vision;
    }

    struct Voting {
        string title;
        string description;
        uint256 startDate;
        uint256 endDate;
        uint maxVoterNumber;
    }

    Voting[] public votings;
    mapping(uint => Candidate[]) public candidiates;

    mapping (uint => address[]) public voters;
    mapping (uint => mapping (uint => uint)) public voterNumber;
    mapping (uint => mapping (address => bool)) public participaters;
    


    /**
     * @dev Initialize with token address and round information.
     */
    constructor () Ownable() {
      
    }

    function createVoting(string memory _title, string memory _description, uint256 duration, uint256 _maxVoterNumber, string[][] memory _candidiates) external onlyOwner {
        votings.push(Voting(_title, _description, block.timestamp, block.timestamp + duration, _maxVoterNumber));

        for(uint i = 0; i < _candidiates.length; i++) {
            candidiates[votings.length - 1].push(Candidate(_candidiates[i][0], _candidiates[i][1], _candidiates[i][2]));
        }
    }

    function vote(uint vote_id, uint candidiate_id) external {
        require(vote_id < getVoteNumber(), "vote id is not valid");
        require(candidiates[vote_id].length > candidiate_id, "candidiate is not valid");
        require(!participaters[vote_id][msg.sender], "You already voted!");
        require(votings[vote_id].maxVoterNumber > voters[vote_id].length, "voter was exceeed");
        require(block.timestamp <= votings[vote_id].startDate, "not started yet");
        require(block.timestamp >= votings[vote_id].endDate, "finished already");

        voters[vote_id].push(msg.sender);
        voterNumber[vote_id][candidiate_id] ++;
        participaters[vote_id][msg.sender] = true;
    }

    function getVoteNumber() public view returns(uint) {
        return votings.length;
    }

    function getCandidiateNumber(uint vote_id) public view returns(uint) {
        return candidiates[vote_id].length;
    }

    function getCandidiates(uint vote_id) public view returns(Candidate[] memory) {
        return candidiates[vote_id];
    }
    function getVoterNumber(uint vote_id) public view returns(uint[] memory) {
        uint256[] memory voterNumberByVote = new uint256[](candidiates[vote_id].length);
        for(uint i = 0; i < candidiates[vote_id].length; i++) {
            voterNumberByVote[i] = voterNumber[vote_id][i];
        }

        return voterNumberByVote;
    }

    function getBlocktimestamp() external view returns(uint256) {
        return block.timestamp;
    }
    

}