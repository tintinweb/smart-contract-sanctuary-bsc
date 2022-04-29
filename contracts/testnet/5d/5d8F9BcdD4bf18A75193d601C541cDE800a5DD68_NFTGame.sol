// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract NFTGame  {
    using SafeMath for uint256;
    address owner;

    // enum for GameWinner
    enum GameWinner {
        CREATOR,
        OPPONENT,
        RESULT_PENDING,
        ERROR_RESPONSE
    }

    enum LobbyStatus {
        BETTING,
        OPPONENT_SELECTED,
        REWARD_CLAIMED
    }

    // struct Bet
    struct Bet{
        uint256 lobbyId;
        address user;
        address NFT;
        uint256 NFTId;
        uint256 etherValue;
        bool isCancelled;
    }

    // struct for the lobby
    struct Lobby{
        uint256 lobbyId;
        address creator;
        uint256 creatorBet;
        uint256 opponentBet;
        bytes10 creatorHash;
        bytes10 opponentHash;
        LobbyStatus lobbyStatus;
        GameWinner winner;
        uint256 gameNumber;
        uint256 blockNumber;
    }

    Lobby[] public lobbies; // array of lobbies
    Bet[] public bets; // arrya of bets

    event LobbyCreated(uint256 lobbyId, address creator, uint256 creatorBet);
    event BetPlaced(uint256 lobbyId, address user, address NFTAddress,uint256 NFTId, uint256 etherValue);
    event BetCancelled(uint256 lobbyId, address user);
    event BetSelected(uint256 lobbyId, uint256 betId,address user, address NFTAddress,uint256 NFTId, uint256 etherValue);
    event RewardClaimed(uint256 lobbyId, GameWinner winner, address winnerAddress, uint256 etherValue);

    function CreateLobby(address _creatorNFT, uint256 _creatorNFTId, uint256 _creatorEtherValue) public payable {
        require(msg.value == _creatorEtherValue, "Not enough ether");
        address _creator = msg.sender;
        if(_creatorNFT != address(0)){
            require(IERC721(_creatorNFT).ownerOf(_creatorNFTId) == _creator);
            // safe transfer from creator to contract
            IERC721(_creatorNFT).transferFrom(_creator, address(this), _creatorNFTId);
        }
        Bet memory newBet = Bet({
            lobbyId: lobbies.length,
            user: _creator,
            NFT: _creatorNFT,
            NFTId: _creatorNFTId,
            etherValue: _creatorEtherValue,
            isCancelled: false
        });
        bets.push(newBet);
        Lobby memory lobby = Lobby(lobbies.length, _creator, bets.length - 1, 0, "", "", LobbyStatus.BETTING, GameWinner.RESULT_PENDING,0,0);
        lobbies.push(lobby);
        emit LobbyCreated(lobbies.length - 1, _creator, bets.length - 1);
        emit BetPlaced(lobbies.length - 1, _creator, _creatorNFT, _creatorNFTId, _creatorEtherValue);
    }

    function CreateOffer(uint256 lobbyId,address _userNFT, uint256 _userNFTId, uint256 _userEtherValue) public payable {
        require(msg.value == _userEtherValue, "Not enough ether");
        address _user = msg.sender;
        Lobby memory lobby = lobbies[lobbyId];
        require(_user != lobby.creator, "You can't offer in your lobby");
        require(lobby.lobbyStatus == LobbyStatus.BETTING, "Lobby is not in betting phase");
        if(_userNFT != address(0)){
            require(IERC721(_userNFT).ownerOf(_userNFTId) == _user);
            // safe transfer from user to contract
            IERC721(_userNFT).transferFrom(_user, address(this), _userNFTId);
        }
        Bet memory bet = Bet(lobbyId, _user, _userNFT, _userNFTId, _userEtherValue, false);
        bets.push(bet);
        emit BetPlaced(lobbyId, _user, _userNFT, _userNFTId, _userEtherValue);
    }

    function WithdrawOffer(uint256 betId) public {
        Bet memory bet = bets[betId];
        require(bet.isCancelled == false, "Bet already cancelled");
        require(bet.user == msg.sender, "Not the owner of the bet");
        Lobby memory lobby = lobbies[bet.lobbyId];
        require(msg.sender != lobby.creator, "You can't withdraw from your lobby");
        if(lobby.lobbyStatus != LobbyStatus.BETTING){
            require(lobby.opponentBet != betId, "You can't withdraw the selected bet");
        }
        bet.isCancelled = true;
        if(bet.NFT != address(0)){
            // safe transfer from contract to user
            IERC721(bet.NFT).transferFrom(address(this), bet.user, bet.NFTId);
        }
        if(bet.etherValue > 0){
            // refund ether
            payable(msg.sender).transfer(bet.etherValue);
        }
        bets[betId] = bet;
        emit BetCancelled(lobby.lobbyId, bet.user);
    }

    function byteToBytes10(bytes1[] memory _bytes) internal pure returns (bytes10 _bytes10) {
        for(uint32 i = 0; i < 9; i++) {
            _bytes10 ^= bytes1(_bytes[i]);
            _bytes10 >>= 8;
        }
    }

    function getHashes() public view returns (bytes10 creatorHash, bytes10 opponentHash){
        uint256[] memory chars = new uint256[](6);
        uint256[] memory nums = new uint256[](10);

        for(uint32 i = 0; i < 3; i++){
            chars[i] = 1;
        }
        for(uint32 i = 0; i < 5; i++){
            nums[i] = 1;
        }
        for(uint32 i = 0; i < 6; i++){
            uint256 random = uint256(keccak256(abi.encodePacked("Salt Adedd", chars[i], block.difficulty, block.timestamp)));
            random = random % 6;
            uint256 temp = chars[random];
            chars[random] = chars[i];
            chars[i] = temp;
        }
        for(uint32 i = 0; i < 10; i++){
            uint256 random = uint256(keccak256(abi.encodePacked("Salt Adedd", nums[i], block.difficulty, block.timestamp)));
            random = random % 10;
            uint256 temp = nums[random];
            nums[random] = nums[i];
            nums[i] = temp;
        }
        bytes1[] memory opponentHashBytes = new bytes1[](10);
        bytes1[] memory creatorHashBytes = new bytes1[](10);
        uint8 ci;
        uint8 oi;
        for(uint32 i = 0; i < 6; i++){
            if(chars[i] == 0){
                creatorHashBytes[ci] = bytes1(uint8(i+10));
                ci++;
            }else{
                opponentHashBytes[oi] = bytes1(uint8(i+10));
                oi++;
            }
        }
        for(uint32 i = 0; i < 10; i++){
            if(nums[i] == 0){
                creatorHashBytes[ci] = bytes1(uint8(i));
                ci++;
            }else{
                opponentHashBytes[oi] = bytes1(uint8(i));
                oi++;
            }
        }
        creatorHash = byteToBytes10(creatorHashBytes);
        opponentHash = byteToBytes10(opponentHashBytes);
        return (creatorHash, opponentHash);
    }

    function SelectOffer(uint256 lobbyId, uint256 betId) public {
        Bet memory bet = bets[betId];
        Lobby memory lobby = lobbies[lobbyId];
        require(bet.lobbyId == lobbyId, "Bet is not in this lobby");
        require(lobby.creator == msg.sender, "Not the owner of the lobby");
        require(bet.isCancelled == false, "Bet already cancelled");   
        require(lobby.creatorBet != betId, "You can't select your own bet");
        require(lobby.lobbyStatus == LobbyStatus.BETTING, "Lobby has already selected a bet");
        lobby.opponentBet = betId;
        lobby.lobbyStatus = LobbyStatus.OPPONENT_SELECTED;
        (lobby.creatorHash,lobby.opponentHash) = getHashes();
        uint256 random = uint256(keccak256(abi.encodePacked(lobby.creatorHash, lobby.opponentHash, block.difficulty, block.timestamp)));
        random = random % 64;
        lobby.gameNumber = random;
        lobby.blockNumber = block.number + 3;
        lobbies[lobbyId] = lobby;
        emit BetSelected(lobbyId, betId, bet.user, bet.NFT, bet.NFTId, bet.etherValue);
    }

    function getWinnerAddress(uint256 lobbyId, GameWinner winner) internal view returns (address winnerAddress){
        Lobby memory lobby = lobbies[lobbyId];
        if(winner == GameWinner.CREATOR){
            return lobby.creator;
        }else if(winner == GameWinner.OPPONENT){
            Bet memory _opponentBet = bets[lobby.opponentBet];
            return _opponentBet.user;
        }else{
            return address(0);
        }
    }

    function getWinner(uint256 lobbyId) public view returns (GameWinner, address){
        Lobby memory lobby = lobbies[lobbyId];
        require(lobby.lobbyStatus != LobbyStatus.BETTING, "The players are not confirmed yet");
        if(block.number <= lobby.blockNumber){
            return (GameWinner.RESULT_PENDING, getWinnerAddress(lobbyId, GameWinner.RESULT_PENDING));
        }
        if(lobby.lobbyStatus == LobbyStatus.REWARD_CLAIMED){
            return (lobby.winner, getWinnerAddress(lobbyId, lobby.winner));
        }

        bytes32 block_hash = blockhash(lobby.blockNumber);
        bytes1 block_hash_bytes = block_hash[lobby.gameNumber/2];
        bytes1 finalCompareHash;
        if(lobby.gameNumber % 2 == 1){
            finalCompareHash = block_hash_bytes << 4;
            finalCompareHash = finalCompareHash >> 4;
        }else{
            finalCompareHash = block_hash_bytes >> 4;
        }
        for(uint32 i=9;i>1;i--){
            if(finalCompareHash == lobby.creatorHash[i]){
                return (GameWinner.CREATOR, getWinnerAddress(lobbyId, GameWinner.CREATOR));
            }
        }
        for(uint32 i=9;i>1;i--){
            if(finalCompareHash == lobby.opponentHash[i]){
                return (GameWinner.OPPONENT, getWinnerAddress(lobbyId, GameWinner.OPPONENT));
            }
        }
        return (GameWinner.RESULT_PENDING, getWinnerAddress(lobbyId, GameWinner.RESULT_PENDING));
    }

    function claimReward(uint256 lobbyId) public {
        Lobby memory lobby = lobbies[lobbyId];
        require(lobby.lobbyStatus != LobbyStatus.REWARD_CLAIMED, "The reward has already been claimed");
        (GameWinner _winner,address _winnerAddress) = getWinner(lobbyId);
        
        require(_winnerAddress != address(0), "The game has not been completed yet");
        require(_winnerAddress == msg.sender, "You are not the winner of the lobby");
        lobby.lobbyStatus = LobbyStatus.REWARD_CLAIMED;
        lobby.winner = _winner;
        Bet memory _opponentBet = bets[lobby.opponentBet];
        Bet memory _creatorBet = bets[lobby.creatorBet];
        uint256 etherValue = _opponentBet.etherValue;
        etherValue.add(_creatorBet.etherValue);
        if(etherValue > 0){
            payable(_winnerAddress).transfer(etherValue);
        }
        if(_opponentBet.NFT != address(0)){
            IERC721(_opponentBet.NFT).transferFrom(address(this), _winnerAddress, _opponentBet.NFTId);
        }
        if(_creatorBet.NFT != address(0)){
            IERC721(_creatorBet.NFT).transferFrom(address(this), _winnerAddress, _creatorBet.NFTId);
        }
        lobbies[lobbyId] = lobby;
        emit RewardClaimed(lobbyId, _winner, _winnerAddress, etherValue);
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC721.sol)

pragma solidity ^0.8.0;

import "../token/ERC721/IERC721.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}