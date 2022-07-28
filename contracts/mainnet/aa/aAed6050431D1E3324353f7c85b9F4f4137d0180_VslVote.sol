/**
 *Submitted for verification at BscScan.com on 2022-07-28
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.14;

library Address
{
    function isContract(address account) internal view returns (bool)
    {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly
        {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }
}

abstract contract Context
{
    function _msgSender() internal view virtual returns (address payable)
    {
        return payable(msg.sender);
    }
}

contract Ownable is Context
{
    address private _owner;
    address private _newOwner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor()
    {
        address msgSender = _msgSender();
        _owner = msgSender;
        _newOwner = address(0);
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address)
    {
        return _owner;
    }

    function isOwner(address who) public view returns (bool)
    {
        return _owner == who;
    }

    modifier onlyOwner()
    {
        require(isOwner(_msgSender()), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner
    {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        require(newOwner != _owner, "Ownable: new owner is already the owner");
        _newOwner = newOwner;
    }

    function acceptOwnership() public
    {
        require(_msgSender() == _newOwner);
        emit OwnershipTransferred(_owner, _newOwner);
        _owner = _newOwner;
        _newOwner = address(0);
    }

    function getTime() public view returns (uint256)
    {
        return block.timestamp;
    }
}

interface IERC20
{
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract Transfers is Ownable
{
    using Address for address;

    constructor() payable {}

    // SECTION: Token and BNB Transfers...

    // Used to get random tokens sent to this address out to a wallet...
    function TransferForeignTokens(address _token, address _to) external onlyOwner returns (bool _sent)
    {
        // See what is available...
        uint256 _contractBalance = IERC20(_token).balanceOf(address(this));

        // Perform the send...
        if(_contractBalance != 0) _sent = IERC20(_token).transfer(_to, _contractBalance);
        else _sent = false;
    }

    // Used to get an amount of random tokens sent to this address out to a wallet...
    function TransferForeignAmount(address _token, address _to, uint256 _maxAmount) external onlyOwner returns (bool _sent)
    {
        // See what we have available...
        uint256 amount = IERC20(_token).balanceOf(address(this));

        // Cap it at the max requested...
        if(amount > _maxAmount) amount = _maxAmount;

        // Perform the send...
        if(amount != 0) _sent = IERC20(_token).transfer(_to, amount);
        else _sent = false;
    }

    // Used to get BNB from the contract...
    function TransferBNBToAddress(address payable recipient, uint256 amount) external onlyOwner
    {
        if(address(this).balance < amount) revert("Balance Low");
        if(amount != 0) recipient.transfer(amount);
    }

    // Used to get BNB from the contract...
    function TransferAllBNBToAddress(address payable recipient) external onlyOwner
    {
        uint256 amount = address(this).balance;
        if(amount != 0) recipient.transfer(amount);
    }
}

contract VslVote is Transfers
{
    using Address for address;

    // Used to iterate through the voter list and can be used to display the total number of voters
    enum VoteState
    {
        DidntVote,                  // Has not voted yet
        OptionAVote,                // Has voted for option A
        OptionBVote                 // Has voted for option B
    }

    struct Voter
    {
        address wallet;             // wallet that can vote
        VoteState vote;             // Used to inactivate a list (too much gas to go remove all of the addresses associated)
    }

    uint256 private voterCount;
    mapping (uint256 => Voter) private voters;              // Get the actual voter data
    mapping (address => uint256) private idToVoter;         // Get the ID for a given address

    uint256 private _totalOptionAVotes;                     // how many option A votes
    uint256 private _totalOptionBVotes;                     // how many option B votes

    uint256 private _startingTime;                          // when voters can start voting
    uint256 private _endingTime;                            // when voters are done voting

    error NotAVoter();
    error VotingNotActive();
    error AlreadyRecordedVote();

    constructor() payable
    {
      _startingTime = getTime();
      _endingTime = _startingTime + 4 days;
    }

    // Thank you for any donations!!!
    receive() external payable {}

    //
    // STATUS BLOCK
    //
    function GetVotingResults() view external returns(uint256 votesCounted, uint256 percentOfVoters,uint256 OptionAVotes, uint256 OptionBVotes, uint256 percentOptionA, uint256 percentOptionB)
    {
        OptionAVotes = _totalOptionAVotes;
        OptionBVotes = _totalOptionBVotes;

        votesCounted = GetTotalVotesReceived();
        percentOfVoters = (voterCount == 0) ? 0 : votesCounted * 100 / voterCount;
        percentOptionA = (votesCounted == 0) ? 0 : _totalOptionAVotes * 100 / votesCounted;
        percentOptionB = (votesCounted == 0) ? 0 : _totalOptionBVotes * 100 / votesCounted;
    }

    function GetVoterCount() view external returns(uint256 totalVoters)
    {
        totalVoters = voterCount;
    }

    function GetTotalVotesReceived() view public returns(uint256 totalVotes)
    {
        totalVotes = _totalOptionAVotes + _totalOptionBVotes;
    }

    function GetStartingTime() view external returns(uint256 startingTime)
    {
        startingTime = _startingTime;
    }

    function SetStartingTime(uint startingTime) external onlyOwner
    {
        _startingTime = startingTime;
    }

    function GetEndingTime() view external returns(uint256 endingTime)
    {
        endingTime = _endingTime;
    }

    function SetEndingTime(uint endingTime) external onlyOwner
    {
        _endingTime = endingTime;
    }

    //
    // MANAGE ADDRESSES
    //
    function AddVoters(address [] memory wallets) external onlyOwner
    {
        uint256 numWallets = wallets.length;
        for(uint256 i = 0; i < numWallets; i++) _addVoter(wallets[i]);
    }

    function ResetVoters() external onlyOwner
    {
        for(uint256 i = 1; i <= voterCount; i++) idToVoter[voters[i].wallet] = 0;
        voterCount = 0;
        _totalOptionAVotes = 0;
        _totalOptionBVotes = 0;
    }

    function ResetVoterBatch(uint256 _maxToRemove) external onlyOwner
    {
        // Remove them from the end of the list...
        uint256 numToRemove = (voterCount < _maxToRemove) ? voterCount : _maxToRemove;
        uint256 lastVoter = (voterCount == numToRemove) ? 1 : voterCount - numToRemove;

        for(uint256 i = voterCount; i > lastVoter; i--)
        {
            if (voters[i].vote == VoteState.OptionAVote) _totalOptionAVotes--;
            else if (voters[i].vote == VoteState.OptionBVote) _totalOptionBVotes--;
            idToVoter[voters[i].wallet] = 0;
            voterCount--;
        }
    }

    function _addVoter(address wallet) internal
    {
        if(wallet == address(0)) return;
        if(idToVoter[wallet] != 0) return;

        voterCount++;
        voters[voterCount].wallet = wallet;
        idToVoter[wallet] = voterCount;
    }

    //
    // VOTING SECTION
    //
    function IsReadyForVoting() view external returns(bool)
    {
        if (_startingTime == 0) return false;
        if (_endingTime == 0) return false;
        if (voterCount == 0) return false;
        return true;
    }

    function IsVotingActive() view external returns(bool isActive)
    {
      uint256 _timeNow = getTime();
      if(_startingTime != 0 && (_timeNow >= _startingTime) && _endingTime != 0 && (_timeNow <= _endingTime)) isActive = true;
      else isActive = false;
    }

    function HasVoted(address _wallet) view external returns(bool hasVoted)
    {
        VoteState _vote = voters[idToVoter[_wallet]].vote;

        if (_vote == VoteState.OptionAVote) return true;
        if (_vote == VoteState.OptionBVote) return true;
        return false;
    }

    // May change vote as many times as desired during voting period, but may not vote for the same option again
    function VoteOptionA() external
    {
        // Make sure they are on the list...
        address _wallet = _msgSender();
        if (idToVoter[_wallet] == 0) revert NotAVoter();

        // Make sure we are in the time frame...
        uint256 _timeNow = getTime();
        if(_startingTime == 0 || (_timeNow < _startingTime) || _endingTime == 0 || (_timeNow > _endingTime)) revert VotingNotActive();

        // Make sure they didn't already register an option A vote...
        VoteState _vote = voters[idToVoter[_wallet]].vote;
        if (_vote == VoteState.OptionAVote) revert AlreadyRecordedVote();

        // Handle new option A vote
        // Note: unvote if already voted the other way
        if (_vote == VoteState.OptionBVote) _totalOptionBVotes--;
        voters[idToVoter[_wallet]].vote = VoteState.OptionAVote;
        _totalOptionAVotes++;
    }

    // May change vote as many times as desired during voting period, but may not vote for the same option again
    function VoteOptionB() external
    {
        // Make sure they are on the list...
        address _wallet = _msgSender();
        if (idToVoter[_wallet] == 0) revert NotAVoter();

        // Make sure we are in the time frame...
        uint256 _timeNow = getTime();
        if(_startingTime == 0 || (_timeNow < _startingTime) || _endingTime == 0 || (_timeNow > _endingTime)) revert VotingNotActive();

        // Make sure they didn't already register an option B vote...
        VoteState _vote = voters[idToVoter[_wallet]].vote;
        if (_vote == VoteState.OptionBVote) revert AlreadyRecordedVote();

        // Handle new option B vote
        // Note: unvote if already voted the other way
        if (_vote == VoteState.OptionAVote) _totalOptionAVotes--;
        voters[idToVoter[_wallet]].vote = VoteState.OptionBVote;
        _totalOptionBVotes++;
    }
}