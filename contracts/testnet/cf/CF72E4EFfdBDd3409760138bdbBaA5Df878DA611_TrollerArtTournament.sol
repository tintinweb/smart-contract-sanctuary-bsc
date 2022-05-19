/**
 *Submitted for verification at BscScan.com on 2022-05-19
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

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

contract TrollerArtTournament is Ownable {
    using Counters for Counters.Counter;
    
    struct TournamentData{
        string tournamentName;
        uint256 startDate;
        uint256 endDate;
        uint8 totalRounds;
        uint256[] topListed;
    }

    struct nftInfo{
        string nftName;
        uint8 voteCount;
        string hashKey;
        address nftOwnerWallet;
    }
    
    mapping(uint256 => nftInfo[]) public nftData;
    address private _owner;
    Counters.Counter private tournamentIds;
    mapping(uint256 => TournamentData) public tournaments;

    
    event TournamentCreated(uint256 indexed tournamentId);
    event TournamentEnded(uint256 tournamentId, uint256 winner1,uint256 winner2,uint256 winner3);   

    constructor() {
            _owner = msg.sender;
        }

    function getTournamentId() public view returns(uint256){
       return tournamentIds.current();
    }

    function createTournament(string memory _tournamentName, uint256 _startDate, uint256 _endDate, uint8 _totalRounds) external{
        require(_endDate > block.timestamp,"End time must be greater than current time.");
        require(_endDate > _startDate ,"End time must be greater than start time.");
        uint256[] memory _Winners;
        tournamentIds.increment();
        uint256 newTournamentId = tournamentIds.current();
        tournaments[newTournamentId] = TournamentData({
            tournamentName: _tournamentName,
            startDate: _startDate,
            endDate: _endDate,
            totalRounds:_totalRounds,
            topListed: _Winners
        });
        
        emit TournamentCreated(newTournamentId);
    }

    function setWinners(uint256 _tournamentId,string[] memory _nftName ,uint8[] memory _voteCount,string[] memory _hashKey,address[] memory _nftOwnerWallet) external
    {
        require(_tournamentId > 0 ,"Invalid tournamentId");
        uint256 n = _nftName.length ; 
        require( (n<=100 ) && (_nftName.length == n) && (_hashKey.length == n) && (_nftOwnerWallet.length == n) && ( _voteCount.length == n) , "Invalid data length");
        for(uint8 i=0; i<n; i++){
            nftInfo memory currentInfo;
            tournaments[_tournamentId].topListed.push(_voteCount[i]);
            currentInfo.nftName = _nftName[i];
            currentInfo.voteCount =_voteCount[i];
            currentInfo.hashKey = _hashKey[i];
            currentInfo.nftOwnerWallet = _nftOwnerWallet[i];
            nftData[_tournamentId].push(currentInfo);
        }
    }

    function getWinners(uint256 _tournamentId) public view returns(uint256[] memory){
        require(_tournamentId > 0 ,"Invalid tournamentId");
        return (tournaments[_tournamentId].topListed);
       
    }

    function endTournament(
        uint256 _tournamentId
    ) external {
        require(_tournamentId > 0 ,"Invalid tournamentId");
        emit TournamentEnded(_tournamentId, tournaments[_tournamentId].topListed[0],tournaments[_tournamentId].topListed[1],tournaments[_tournamentId].topListed[2]);
    }
}