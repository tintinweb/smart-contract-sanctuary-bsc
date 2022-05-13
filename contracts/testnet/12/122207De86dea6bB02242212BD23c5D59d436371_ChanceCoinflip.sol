// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ChanceInvite.sol";
import "./interface/IChanceInvite.sol";
import "./interface/IVRFv2Consumer.sol";

contract ChanceCoinflip is Ownable {

    event withdrawLog(address indexed _Chance, address _addrWithdraw, uint256 amount);
    event withdrawInviteLog(address _addrWithdraw, uint256 amount);
    event roundStart(uint256 round, address addrA, bool _coinflip, uint256 amount);
    event roundRemove(uint256 round, address addrA);
    event roundEnd(uint256 round, address _winner, address addrB, bool _coinflip, uint256 amount, uint256 winAmount);
    event inviteLog(address _addrMint, address _addrInvite, uint256 amount);

    uint256 round;
    address public _ChanceInvite;
    address public COMMUNITY_ADDR;
    address VRF_ADDR;
    address public constant BLACKHOLE_ADDR = 0x0000000000000000000000000000000000000000;

    struct Game {
        uint256 _round;
        address addrA;
        address addrB;
        address inviterA;
        address inviterB;
        bool choiceA;
        bool _coinflip;
        uint256 _block;
        uint256 amount;
        uint256 winAmount;
    }
    mapping(uint256 => Game) public gameMap;

    mapping(address => uint256) public accountMap;
    mapping(address => uint256) public inviteMap;

    Game[] public gameList;

    function setVRF(address _addr) public onlyOwner {
        VRF_ADDR = _addr;
    }

    function setChanceInvite(address _addr) public onlyOwner {
        _ChanceInvite = _addr;
    }

    function getGames() public view returns (Game[] memory) {
        return gameList;
    }

    function pushRound(uint256 i) internal {
        // Append to array
        // This will increase the array length by 1.
        gameList.push(gameMap[i]);
        // emit pushGame(i);
        emit roundStart(i, gameMap[i].addrA, gameMap[i].choiceA, gameMap[i].amount);
    }

    function removeRound(uint256 r) internal {
        uint256 index;
        for (uint i; i<gameList.length;i++) {
            if (r == gameList[i]._round) {
                index = i;
                break;
            }
        }
        if (index >= gameList.length) return;

        for (uint i = index; i<gameList.length-1; i++){
            gameList[i] = gameList[i+1];
        }
        gameList.pop();
        emit roundRemove(r, gameMap[r].addrA);
    }

    // function pause() public onlyOwner {
    //     _pause();
    // }

    // function unPause() public onlyOwner {
    //     _unpause();
    // }

    function get_rand(uint256 start, uint256 end, uint256 _seed) private pure returns(uint256) {
        if (end == 1) {
            return 1;
        }
        if (start == 0) {
            return 1 + _seed%(end);
        }
        return start + _seed%(end - start + 1);
    }

    function getFlip(uint256 _round) private view returns (bool){
        // uint256 _seed = IVRFv2Consumer(VRF_ADDR).getSeed(_round%24);
        uint256 _seed = uint256(keccak256(abi.encode(block.difficulty, block.timestamp)));
        uint256 number = get_rand(1, 2, _seed);
        bool coinflip;
        if (number == 1) {
            coinflip = true;
        } else {
            coinflip = false;
        }
        return coinflip;
    }

    function deposit(uint256 amount) payable public {
        require(msg.value == amount);
    }

    function allotAmount(uint256 _round) private {
        uint256 community_amount = gameMap[_round].amount * 3 / 100;
        uint256 invite_amount;
        address winner;
        address inviter;
        if (gameMap[_round].choiceA == gameMap[_round]._coinflip) {
            winner = gameMap[_round].addrA;
            inviter = gameMap[_round].inviterA;
        } else {
            winner = gameMap[_round].addrB;
            inviter = gameMap[_round].inviterB;
        }

        if (inviter != BLACKHOLE_ADDR) {
            invite_amount = community_amount  * 10 / 100;
            inviteMap[inviter] += invite_amount;
            emit inviteLog(msg.sender, inviter, invite_amount);
        }

        community_amount = community_amount - invite_amount;
        accountMap[COMMUNITY_ADDR] += community_amount;
        gameMap[_round].winAmount = gameMap[_round].amount - community_amount;
        accountMap[winner] += gameMap[_round].winAmount;

        emit roundEnd(_round, winner, gameMap[_round].addrB, gameMap[_round]._coinflip, gameMap[_round].amount, gameMap[_round].winAmount);
    }

    function createGame(bool choice, string memory _inviteCode) payable public {
        require(msg.value > 0.025 ether || msg.value > 2500 ether, "betLimitError");
        deposit(msg.value);

        Game memory game;
        game.addrA = msg.sender;
        game.choiceA = choice;
        game.amount = msg.value;
        game.inviterA = IChanceInvite(_ChanceInvite).inviteParty(msg.sender, _inviteCode);
        game._round = round;
        gameMap[round] = game;

        pushRound(round);
        round += 1;
    }

    function cancelGame(uint256 _round) public {
        require(gameMap[_round].addrA == msg.sender, "ErrorA");
        require(gameMap[_round].addrB == BLACKHOLE_ADDR, "ErrorB");
        require(gameMap[_round].amount > 0, "Error");
        require(gameMap[_round].amount <= address(this).balance, "NotEnough");
        uint amount = gameMap[_round].amount;
        gameMap[_round].amount = 0;
        removeRound(_round);
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "FailedToSend");
    }

    function joinGame(uint256 _round, string memory _inviteCode) payable public {
        require(msg.value == gameMap[_round].amount, "ErrorAmount");
        require(msg.sender != gameMap[_round].addrA, "ErrorGame");
        require(gameMap[_round].addrB == BLACKHOLE_ADDR, "ErrorGame");
        deposit(msg.value);
        gameMap[_round].addrB = msg.sender;
        gameMap[_round].amount += msg.value;
        gameMap[_round].inviterB = IChanceInvite(_ChanceInvite).inviteParty(msg.sender, _inviteCode);

        bool coinflip = getFlip(_round);
        gameMap[_round]._coinflip = coinflip;

        allotAmount(_round);

        removeRound(_round);
    }

    function withdrawInvite() public {
        require(inviteMap[msg.sender] >= 0.025 ether, "AtLest0.025");
        require(inviteMap[msg.sender] <= address(this).balance, "NotEnough");
        uint amount = inviteMap[msg.sender];
        inviteMap[msg.sender] = 0;
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "FailedToSend");
        emit withdrawInviteLog(msg.sender, amount);
    }

    function withdrawAmount(address payable _to, uint256 _amount) public {
        uint256 amount = accountMap[msg.sender];
        require(amount > 0 ether, "AtLest0");
        require(amount <= address(this).balance, "NotEnough");
        require(_amount <= amount, "NotEnough");
        if (_amount == 0){
            _amount = amount;
        }
        (bool success, ) = _to.call{value: _amount}("");
        accountMap[msg.sender] -= _amount;
        require(success, "FailedToSend");
        emit withdrawLog(address(this), msg.sender, _amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface VRFCoordinatorV2Interface {
  /**
   * @notice Get configuration relevant for making requests
   * @return minimumRequestConfirmations global min for request confirmations
   * @return maxGasLimit global max for request gas limit
   * @return s_provingKeyHashes list of registered key hashes
   */
  function getRequestConfig()
    external
    view
    returns (
      uint16,
      uint32,
      bytes32[] memory
    );

  /**
   * @notice Request a set of random words.
   * @param keyHash - Corresponds to a particular oracle job which uses
   * that key for generating the VRF proof. Different keyHash's have different gas price
   * ceilings, so you can select a specific one to bound your maximum per request cost.
   * @param subId  - The ID of the VRF subscription. Must be funded
   * with the minimum subscription balance required for the selected keyHash.
   * @param minimumRequestConfirmations - How many blocks you'd like the
   * oracle to wait before responding to the request. See SECURITY CONSIDERATIONS
   * for why you may want to request more. The acceptable range is
   * [minimumRequestBlockConfirmations, 200].
   * @param callbackGasLimit - How much gas you'd like to receive in your
   * fulfillRandomWords callback. Note that gasleft() inside fulfillRandomWords
   * may be slightly less than this amount because of gas used calling the function
   * (argument decoding etc.), so you may need to request slightly more than you expect
   * to have inside fulfillRandomWords. The acceptable range is
   * [0, maxGasLimit]
   * @param numWords - The number of uint256 random values you'd like to receive
   * in your fulfillRandomWords callback. Note these numbers are expanded in a
   * secure way by the VRFCoordinator from a single random value supplied by the oracle.
   * @return requestId - A unique identifier of the request. Can be used to match
   * a request to a response in fulfillRandomWords.
   */
  function requestRandomWords(
    bytes32 keyHash,
    uint64 subId,
    uint16 minimumRequestConfirmations,
    uint32 callbackGasLimit,
    uint32 numWords
  ) external returns (uint256 requestId);

  /**
   * @notice Create a VRF subscription.
   * @return subId - A unique subscription id.
   * @dev You can manage the consumer set dynamically with addConsumer/removeConsumer.
   * @dev Note to fund the subscription, use transferAndCall. For example
   * @dev  LINKTOKEN.transferAndCall(
   * @dev    address(COORDINATOR),
   * @dev    amount,
   * @dev    abi.encode(subId));
   */
  function createSubscription() external returns (uint64 subId);

  /**
   * @notice Get a VRF subscription.
   * @param subId - ID of the subscription
   * @return balance - LINK balance of the subscription in juels.
   * @return reqCount - number of requests for this subscription, determines fee tier.
   * @return owner - owner of the subscription.
   * @return consumers - list of consumer address which are able to use this subscription.
   */
  function getSubscription(uint64 subId)
    external
    view
    returns (
      uint96 balance,
      uint64 reqCount,
      address owner,
      address[] memory consumers
    );

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @param newOwner - proposed new owner of the subscription
   */
  function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner) external;

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @dev will revert if original owner of subId has
   * not requested that msg.sender become the new owner.
   */
  function acceptSubscriptionOwnerTransfer(uint64 subId) external;

  /**
   * @notice Add a consumer to a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - New consumer which can use the subscription
   */
  function addConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Remove a consumer from a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - Consumer to remove from the subscription
   */
  function removeConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Cancel a subscription
   * @param subId - ID of the subscription
   * @param to - Where to send the remaining LINK to
   */
  function cancelSubscription(uint64 subId, address to) external;

  function getSeed(uint256 _s) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IChanceInvite {
    function inviteParty(address _addr, string memory _inviteCode) external returns (address);

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ChanceInvite is Ownable {
    using Strings for string;

    mapping(address => string) public inviteCodeMap;
    mapping(string => address) public inviteAddrMap;
    struct INVITE {
        address _inviteAddr;
        uint256 _timestamp;
        uint256 number;
    }
    mapping(address => INVITE) public inviteRecordMap;

    address public constant BLACKHOLE_ADDR = 0x0000000000000000000000000000000000000000;
    address public INVITE_MINTER;
    uint private randNonce = 10000000;
    uint256 public inviteTTL;

    function setInviteTTL(uint256 _t) public onlyOwner {
        inviteTTL = _t;
    }

    modifier onlyBase64Hash (string memory str) {
        bytes memory b = bytes (str);
        for (uint i = 0; i < b.length; i++)
            require (0x7FFFFFE07FFFFFE03FF000000000000 & (uint(1) << uint8 (b [i])) > 0);
        _;
    }

    function setInviteCode(string memory inviteCode) public onlyBase64Hash (inviteCode) {
        require(inviteAddrMap[inviteCode] == BLACKHOLE_ADDR, "invite code is used");
        require(bytes(inviteCodeMap[msg.sender]).length == 0, "invite code only set once");
        require(bytes(inviteCode).length < 64, "invite code too long");
        inviteCodeMap[msg.sender] = inviteCode;
        inviteAddrMap[inviteCode] = msg.sender;
    }

    function setInviteAddr(address _addr) public onlyOwner {
        INVITE_MINTER = _addr;
    }

    function inviteParty(address _addr, string memory _inviteCode) external onlyBase64Hash (_inviteCode) returns (address) {
        // require(msg.sender == INVITE_MINTER, "Permission Denied");
        if (inviteRecordMap[_addr]._inviteAddr == BLACKHOLE_ADDR) {
            if (keccak256(abi.encodePacked((_inviteCode))) == keccak256(abi.encodePacked(("")))) {
                return BLACKHOLE_ADDR;
            }
        }

        // self invite code check
        address inviteAddr = inviteAddrMap[_inviteCode];
        if (inviteAddr == _addr) {
            return BLACKHOLE_ADDR;
        }
        if (inviteAddr != BLACKHOLE_ADDR) {
            bool flag;
            // not in record
            if (inviteRecordMap[_addr]._timestamp == 0) {
                INVITE memory invite;
                invite._inviteAddr = inviteAddr;
                invite._timestamp = block.timestamp;
                invite.number = block.number;
                inviteRecordMap[_addr] = invite;
                flag = true;
            } else {
                // if (block.timestamp - inviteRecordMap[_addr]._timestamp < inviteTTL) {
                if (block.number - inviteRecordMap[_addr].number < inviteTTL) {
                    flag = true;
                }
            }
            if (flag == true) {
                inviteAddr = inviteRecordMap[_addr]._inviteAddr;
            }
            return inviteAddr;
        } else {
            return BLACKHOLE_ADDR;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
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