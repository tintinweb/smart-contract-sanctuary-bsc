/**
 *Submitted for verification at BscScan.com on 2022-05-16
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/utils/Counters.sol";
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

/**
 * @title Tournament
 * @notice This contract manages the matches in a NFT tournament in order to elect a NFT winner through voting
 */

contract TrollerArtTournament is Ownable {
    using Counters for Counters.Counter;
    struct TournamentData {
        address[] wallets; // Player wallet
        address[] tokenAddresses; // Corresponding NFT contract address
        uint256[] tokenIds; // Player NFT ID
        uint256[] currentBalances; // Player balance in the current round
        uint8[] bracketWinners; // Array of player IDs in the current round
        uint256 currentRound; // Current round
    }

    address private _owner;
    Counters.Counter private tournamentIds;
    mapping(uint256 => TournamentData) private tournaments;

    event TournamentCreated(uint256 indexed tournamentId);
    event RoundEnded(uint256 indexed tournamentId, uint256 indexed round, uint8[] bracketWinners, uint256[] playersScores);
    event TournamentEnded(uint256 indexed tournamentId, uint8 indexed bracketWinner, uint256[] playersScores);   

    constructor() {
        _owner = msg.sender;
    }

    /* @param _tournamentId The corresponding tournament ID
      @return Array of addresses of players wallets */

    function getWallets(uint256 _tournamentId)
        external
        view
        returns (address[] memory)
    {
        return tournaments[_tournamentId].wallets;
    }

    /* @param _tournamentId The corresponding tournament ID
       @return Array of corresponding player NFT addresses */

    function getTokenAddresses(uint256 _tournamentId)
        external
        view
        returns (address[] memory)
    {
        return tournaments[_tournamentId].tokenAddresses;
    }

    /* @param _tournamentId The corresponding tournament ID
     @return Array of corresponding player NFT ID */

    function getTokenIds(uint256 _tournamentId)
        external
        view
        returns (uint256[] memory)
    {
        return tournaments[_tournamentId].tokenIds;
    }

    /* @param _tournamentId The corresponding tournament ID
       @return Array of current player balance */

    function getCurrentBalances(uint256 _tournamentId)
        external
        view
        returns (uint256[] memory)
    {
        return tournaments[_tournamentId].currentBalances;
    }

    /* @param _tournamentId The corresponding tournament ID
      @return Array of current winners in the tournament */

    function getBracketWinners(uint256 _tournamentId)
        external
        view
        returns (uint8[] memory)
    {
        return tournaments[_tournamentId].bracketWinners;
    }

    /* @param _tournamentId The corresponding tournament ID
     @return Current round number */

    function getCurrentRound(uint256 _tournamentId)
        external
        view
        returns (uint256)
    {
        return tournaments[_tournamentId].currentRound;
    }

    /* @dev Creates a new TournamentData object and store in the tournament mapping
     @dev Auto increments the current tournament ID created
     @param _playerWallets Array of player wallet addresses. The winner will receive the NFTs in this wallet
     @param _tokenAddresses Array of corresponding player NFT addresses
     @param _tokenIds Array of corresponding player NFT ID */

    function createTournament(
        address[] calldata _playerWallets,
        address[] calldata _tokenAddresses,
        uint256[] calldata _tokenIds,
        uint8 _currentRound
        // uint8 totalMembers
    ) external onlyOwner {
        tournamentIds.increment();
        uint256 newTournamentId = tournamentIds.current();
        uint256 [] memory _currentBalance;
        uint8 [] memory _bracketWinners;
        
        tournaments[newTournamentId] = TournamentData({
            wallets: _playerWallets,
            tokenAddresses: _tokenAddresses,
            tokenIds: _tokenIds,
            currentBalances: _currentBalance,
            bracketWinners: _bracketWinners,
            currentRound: _currentRound
        });
        
        emit TournamentCreated(newTournamentId);
    }

    /* @dev Ends the current round decrementing the round counter
       @dev Calculates the new voting balance for each player
       @dev Updates the winner bracket maintaining an orderly structure
       @param _tournamentId The corresponding tournament ID
       @param _playersRoundScores The scores of each player in the current round */

    function endCurrentRound(
        uint256 _tournamentId,
        uint256[] calldata _playersRoundScores
    ) external onlyOwner {
        require(
            tournaments[_tournamentId].currentRound > 1,
            "Tournament must not be reached the last round"
        );

        require(_playersRoundScores.length > 0 && _playersRoundScores.length <= 100 ,  "Number of Players are Invalid");

        tournaments[_tournamentId].currentRound--;

        // Calculates the needed bracket size based on the current round
        uint256 currentBracketSize = 2**tournaments[_tournamentId].currentRound;
        uint256 playerId1;
        uint256 playerId2;
        uint256 i = 0;

        // Iterates until the max size of the bracket winner array for the current round
        // Compares player balances in each match and assign the winner to the bracketWinner array
        for (
            uint256 bracketIndex = 0;
            bracketIndex < currentBracketSize;
            bracketIndex++
        ) {
            // Get the corresponding player IDs for each match from the current bracketWinners array
            playerId1 = tournaments[_tournamentId].bracketWinners[i];
            playerId2 = tournaments[_tournamentId].bracketWinners[i + 1];

            // Stores the player cumulative balance
            tournaments[_tournamentId].currentBalances[playerId1] += _playersRoundScores[i];
            tournaments[_tournamentId].currentBalances[playerId2] += _playersRoundScores[i + 1];

            // Save match winner in the bracketWinners array
            tournaments[_tournamentId].bracketWinners[bracketIndex] = 
                _playersRoundScores[i] > _playersRoundScores[i + 1]
                ? tournaments[_tournamentId].bracketWinners[i]
                : tournaments[_tournamentId].bracketWinners[i + 1];

            i += 2;
        }

        emit RoundEnded(_tournamentId, tournaments[_tournamentId].currentRound + 1, tournaments[_tournamentId].bracketWinners, _playersRoundScores);
    }

    /* @dev Ends the tournament decrementing the round counter
      @dev Calculates the new voting balance for each player
      @dev Updates the winner bracket with the tournament winner in the first position
      @param _tournamentId The corresponding tournament ID
      @param _playersRoundScores The scores of each player in the current round */

    function endTournament(
        uint256 _tournamentId,
        uint256[] calldata _playersRoundScores
    ) external onlyOwner {
        require(
            tournaments[_tournamentId].currentRound == 1,
            "Tournament must be in the last round"
        );

        require(_playersRoundScores.length == 2 ,  "Player Round scores length must be two");

        tournaments[_tournamentId].currentRound--;

        // Get the corresponding player IDs for each match from the current bracketWinners array
        uint256 playerId1 = tournaments[_tournamentId].bracketWinners[0];
        uint256 playerId2 = tournaments[_tournamentId].bracketWinners[1];

        // Stores the player cumulative balance
        tournaments[_tournamentId].currentBalances[playerId1] += _playersRoundScores[0];
        tournaments[_tournamentId].currentBalances[playerId2] += _playersRoundScores[1];

        // Save the tournament winner in the first position bracketWinners array
        tournaments[_tournamentId].bracketWinners[0] =
            _playersRoundScores[0] > _playersRoundScores[1]
            ? tournaments[_tournamentId].bracketWinners[0]
            : tournaments[_tournamentId].bracketWinners[1];

    emit TournamentEnded(_tournamentId, tournaments[_tournamentId].bracketWinners[0], _playersRoundScores);

    }
}