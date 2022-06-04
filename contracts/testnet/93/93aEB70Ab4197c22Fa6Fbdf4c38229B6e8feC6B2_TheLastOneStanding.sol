/**
 *Submitted for verification at BscScan.com on 2022-06-03
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
  /**
   * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
   * - Addition cannot overflow.
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  /**
   * @dev Returns the multiplication of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `*` operator.
   *
   * Requirements:
   * - Multiplication cannot overflow.
   */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts with custom message when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
  // Empty internal constructor, to prevent people from mistakenly deploying
  // an instance of this contract, which should be used via inheritance.

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
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
contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor () {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  /**
   * @dev Returns the address of the current owner.
   */
  function owner() public view returns (address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  /**
   * @dev Leaves the contract without owner. It will not be possible to call
   * `onlyOwner` functions anymore. Can only be called by the current owner.
   *
   * NOTE: Renouncing ownership will leave the contract without an owner,
   * thereby removing any functionality that is only available to the owner.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract TheLastOneStanding is Context, Ownable{

  using SafeMath for uint;
  using Address for address;

//=====================================================================================\\
//==================================== Game Wallets ===================================\\
  address private marketingAddress;
  address private teamAddress;
  uint8   private marketingFee;
  uint8   private teamFee;
  uint    private feeAmount;
  uint    private playerAmount;
//==================================== Game Wallets ===================================\\
//|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||\\
//=================================== Struct Section ==================================\\

  struct Player {
    uint      internalId;
    uint      externalId;
    address   addressPlayer;
    string    name;
    uint      balance;
    uint[]    playerGameCardId;
    uint      gamesWon;
    uint      gameStreak;
    uint      amountInvested;
    uint      roi;
    uint      gameBlock;
  }
  struct Edition {
    uint      id;
    bool      active;
    uint      gameModeId;
    uint      totalWinners;
    uint[]    idWinners;
    uint      prize;
  }
  struct GameMode{
    uint8 gameModeType;
    GameModeDsc[] gameModesDsc;
  }
  struct GameModeDsc{
    uint      id;
    uint      editionId;
    string    startDate;
    string    endDate;
    uint      gameDays;
    uint      dailyAmount;
    uint      totalAmount;
    uint      totalPoints;
  }
   struct Round {
    uint      id;
    uint      gameModeId;
    uint[2]   playersIdVersus;
    string[2] playersName;
    uint8[2]  playersMove;
    uint      winnerId;
    bool      draw;
    bool      processed;
    uint      processBlock;
  }
   struct PlayerGameCard {
    uint      id;
    uint      playerId;
    string    playerName;
    uint      editionId;
    uint      gameModeId;
    uint[7]   roundId;
    uint8[7]  playerMoves;
    bool[7]   dailyPlay;
    uint      totalAmount;
    uint      roundsWon;
    uint      playerPoints;
  }
  
  mapping(address => Player[]) private players;

  Edition[] public editions;

/*   GameMode[] public gameModes; */

  GameMode[] private gameModes;

  Round[] private rounds;

  mapping(address => PlayerGameCard[]) private playerGameCards;

//================================ End of Struct Section ==============================\\
//|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||\\
//============================== System Variables Section =============================\\

  uint private totalPlayers;
  uint private gameBalance;
  bool public updatingGame;
  uint private blockSize;

//========================== End of System Variables Section ==========================\\
//|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||\\
//================================ Constructor Section ================================\\
//Constructor section
constructor() {
  marketingAddress = 0xdD870fA1b7C4700F2BD7f44238821C26f7392148;
  teamAddress = 0x583031D1113aD414F02576BD6afaBfb302140225;
  marketingFee = 3;
  teamFee = 2;
  feeAmount = 0;
  playerAmount = 95;
  totalPlayers = 0;
  players[msg.sender].push();
  editions.push();
  gameModes.push();
  playerGameCards[msg.sender].push();
  updatingGame = true;
  blockSize = 100;
}
//============================= End of Constructor Section ============================\\
//|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||\\
//================================ Owner Only Section =================================\\

  function setMarketingAddress(address _newMarketingAddress) public onlyOwner{
    marketingAddress = _newMarketingAddress;
  }

  function setTeamAddress(address _newTeamAddress) public onlyOwner{
    teamAddress = _newTeamAddress;
  }

  function setDailyAmount(uint8 _gameModeType, uint _gameModeId, uint _newAmount) public onlyOwner{
    require(editions[_gameModeId].active == true,"Edition Deactivated");
    gameModes[_gameModeType].gameModesDsc[_gameModeId].dailyAmount = _newAmount;
    gameModes[_gameModeType].gameModesDsc[_gameModeId].totalAmount += _newAmount;
  }

  function setUpdatingGame(bool _updatingGame) public onlyOwner{
    updatingGame = _updatingGame;
  }
  
  // FUNCTION THAT PLAYS THE GAME
  // ROCK = 1  || SCISSOR = 2 || PAPER = 3
  // ROCK > SCISSOR
  // SCISSOR > PAPER
  // PAPER > ROCK
  function processRounds(uint _processBlock) public onlyOwner{

    uint _id = ((_processBlock * 100) - 99);
    while(_id < rounds.length || _id/100 == _processBlock ){
      if(rounds[_id].processed == false){
        if(rounds[_id].playersMove[0] == 1 && rounds[_id].playersMove[1] == 2){
          rounds[_id].winnerId = rounds[_id].playersIdVersus[0];
        }
        else if(rounds[_id].playersMove[0] == 2 && rounds[_id].playersMove[1] == 3){
          rounds[_id].winnerId = rounds[_id].playersIdVersus[0];
        }
        else if(rounds[_id].playersMove[0] == 3 && rounds[_id].playersMove[1] == 1){
          rounds[_id].winnerId = rounds[_id].playersIdVersus[0];
        }
        else if(rounds[_id].playersMove[1] == 1 && rounds[_id].playersMove[0] == 2){
          rounds[_id].winnerId = rounds[_id].playersIdVersus[1];
        }
        else if(rounds[_id].playersMove[1] == 2 && rounds[_id].playersMove[0] == 3){
          rounds[_id].winnerId = rounds[_id].playersIdVersus[1];
        }
        else if(rounds[_id].playersMove[1] == 3 && rounds[_id].playersMove[0] == 1){
          rounds[_id].winnerId = rounds[_id].playersIdVersus[1];
        }
        else if(rounds[_id].playersMove[1] == rounds[_id].playersMove[0]){
          rounds[_id].draw = true;
        }
        rounds[_id].processed = true;
      }
      _id++;
    }
  }


// IN CASE SOMEONE BRAKE THE GAME - Reseting Game
/*   function resetGame() private onlyOwner{
      delete players;
  }
 */

//============================= End of Owner Only Section =============================\\
//|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||\\
//================================== Usage Section ====================================\\

//Player Section
  function newPlayer(string calldata _namePlayer) private{
    uint idNewPlayer = players[msg.sender].length;  
    totalPlayers++;
    players[msg.sender].push();
    players[msg.sender][idNewPlayer].internalId = idNewPlayer;
    players[msg.sender][idNewPlayer].externalId = totalPlayers;
    players[msg.sender][idNewPlayer].addressPlayer = msg.sender;
    players[msg.sender][idNewPlayer].name = _namePlayer;
    players[msg.sender][idNewPlayer].balance = 0;
    players[msg.sender][idNewPlayer].gamesWon = 0;
    players[msg.sender][idNewPlayer].amountInvested = 0;
    players[msg.sender][idNewPlayer].roi = 0;
    players[msg.sender][idNewPlayer].gameBlock = idNewPlayer/100;
  }

  function setName(string calldata _newName) public{
    require(players[msg.sender][players[msg.sender].length-1].addressPlayer == msg.sender,"You can't change others player's name!");
    players[msg.sender][players[msg.sender].length-1].name = _newName;
  }

  function getPlayerData() public view returns(Player memory){
    return players[msg.sender][players[msg.sender].length-1];
  }

  function getTotalPlayers() public view returns(uint){
    return totalPlayers;
  }

  function findPlayer() public view returns(bool found){
    if(players[msg.sender].length == 0){
      return false;
    }else{
      return true;
    }
  }
  
  function createPlayer(string calldata _playerName) public{
    require(findPlayer() == false,"Player already registered");
    newPlayer(_playerName);
  }

//Edition Section
  function newEdition() public onlyOwner{
    uint idNewEditions = editions.length;
    editions.push();
    editions[idNewEditions].id = idNewEditions;
    editions[idNewEditions].active = true;
    editions[idNewEditions].gameModeId = 1;
    editions[idNewEditions].totalWinners = 0;
    editions[idNewEditions].prize = 0;
  }

//GameMode Section
  function NewGameMode(uint _editionId, string calldata _startDate, string calldata _endDate, uint _dailyAmount, uint _totalPoints, uint8 _gameModeType) public onlyOwner{
    if(_gameModeType == 1){
      newGameMode2(_editionId,_startDate,_endDate,_dailyAmount,_totalPoints);
    }else if(_gameModeType == 2 ){
      newGameMode2(_editionId,_startDate,_endDate,_dailyAmount,_totalPoints);
    }else{
      newGameMode2(_editionId,_startDate,_endDate,_dailyAmount,_totalPoints);
    }
  }

  function newGameMode2(uint _editionId, string calldata _startDate, string calldata _endDate, uint _dailyAmount, uint _totalPoints) private onlyOwner{
    uint idNewGameMode = gameModes[2].gameModesDsc.length;
    gameModes[2].gameModesDsc.push();
    gameModes[2].gameModesDsc[idNewGameMode].id = idNewGameMode;
    gameModes[2].gameModesDsc[idNewGameMode].editionId = _editionId;
    gameModes[2].gameModesDsc[idNewGameMode].startDate = _startDate;
    gameModes[2].gameModesDsc[idNewGameMode].endDate = _endDate;
    gameModes[2].gameModesDsc[idNewGameMode].gameDays = 1;
    gameModes[2].gameModesDsc[idNewGameMode].dailyAmount = _dailyAmount;
    gameModes[2].gameModesDsc[idNewGameMode].totalAmount = 0;
    gameModes[2].gameModesDsc[idNewGameMode].totalPoints = _totalPoints;
  }

//Round Section
  function createRound(uint8 _playersMove) private {
    uint idNewRound = rounds.length;
    rounds.push();
    rounds[idNewRound].id = idNewRound;
    rounds[idNewRound].gameModeId = playerGameCards[msg.sender][playerGameCards[msg.sender].length-1].gameModeId;
    rounds[idNewRound].playersIdVersus[0] = playerGameCards[msg.sender][players[msg.sender].length-1].playerId;
    rounds[idNewRound].playersName[0] = playerGameCards[msg.sender][players[msg.sender].length-1].playerName;
    rounds[idNewRound].playersMove[0] = _playersMove; 
    rounds[idNewRound].winnerId = 0 ;
    rounds[idNewRound].draw = false;
    rounds[idNewRound].processed = false;
    rounds[idNewRound].processBlock = idNewRound/50;
  }

  function enterRound(uint8 _playersMove) private {
    uint idNewRound = rounds.length-1;
    rounds[idNewRound].playersIdVersus[1] = playerGameCards[msg.sender][players[msg.sender].length-1].playerId;
    rounds[idNewRound].playersName[1] = players[msg.sender][players[msg.sender].length-1].name;
    rounds[idNewRound].playersMove[1] = _playersMove; 
  }

  function findRound() private view returns(bool found){
    if(rounds[rounds.length-1].playersIdVersus[1] == 0){
      return true;
    }else{
      return false;
    }
  }

//PlayerGameCard Section
  function createPlayerGameCard() private{
    uint idPlayerGameCards = playerGameCards[msg.sender].length;
    playerGameCards[msg.sender].push();
    playerGameCards[msg.sender][idPlayerGameCards].id = idPlayerGameCards;
    playerGameCards[msg.sender][idPlayerGameCards].playerId = players[msg.sender][players[msg.sender].length-1].internalId;
    playerGameCards[msg.sender][idPlayerGameCards].playerName = players[msg.sender][players[msg.sender].length-1].name;
    playerGameCards[msg.sender][idPlayerGameCards].editionId = editions.length-1;
    playerGameCards[msg.sender][idPlayerGameCards].gameModeId = gameModes.length-1;
    playerGameCards[msg.sender][idPlayerGameCards].dailyPlay[0] = false;
    playerGameCards[msg.sender][idPlayerGameCards].totalAmount = 0;
    playerGameCards[msg.sender][idPlayerGameCards].roundsWon = 0;
    playerGameCards[msg.sender][idPlayerGameCards].playerPoints = 0;
  }

//Change Name
  function createPlayerGameCard(string calldata _newName) private{
    playerGameCards[msg.sender][playerGameCards[msg.sender].length-1].playerName = _newName;
    players[msg.sender][players[msg.sender].length-1].name = _newName;
  }

  modifier isRegistered() {
    require(players[msg.sender].length != 0,"Player needs to be registered");
    _;
  }

//=============================== End of Usage Section ================================\\
//|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||\\
//=============================== Game Logic Section ==================================\\
  function depositBNB() payable public isRegistered{
    uint _balance = msg.value;
    players[msg.sender][players[msg.sender].length-1].balance = _balance.mul(playerAmount).div(100);
    discountTaxes(); 
  }

  function discountTaxes() private{
    uint totalValue = msg.value;
    feeAmount = totalValue.mul(teamFee).div(100);
    payable(teamAddress).transfer(feeAmount);
    feeAmount = totalValue.mul(marketingFee).div(100);
    payable(marketingAddress).transfer(feeAmount);
  }

  function withdraw(uint _withdrawValue) public isRegistered{
    players[msg.sender][players[msg.sender].length-1].balance -= _withdrawValue;
    payable(msg.sender).transfer(_withdrawValue);
  }

  function enterGame() public isRegistered{
    createPlayerGameCard();
  }


}