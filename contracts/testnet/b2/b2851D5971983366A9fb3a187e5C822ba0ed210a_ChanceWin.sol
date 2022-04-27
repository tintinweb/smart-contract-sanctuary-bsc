// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./interface/IChance.sol";
import "./interface/IChanceInvite.sol";
import "./interface/IChanceDrop.sol";

contract ChanceWin is Ownable, Pausable, ReentrancyGuard{

    event mintLog(address _addrMint, uint256 _id, uint256 round, uint256 lastEnd);
    event inviteLog(address indexed _addrMint, address _addrInvite, uint256 amount);
    event dropLog(uint256 round, uint256 winner, uint256 jackpot);
    event withdrawLog(address indexed _Chance, address _addrWithdraw, uint256 amount);
    event winnerWithdrawLog(address indexed _Chance, address _addrWithdraw, uint256 amount, uint256 tokenID);

    address public CHANCE_ADDR;
    address public constant BLACKHOLE_ADDR = 0x0000000000000000000000000000000000000000;
    address public COMMUNITY_ADDR;
    // address public DEVELOP_ADDR;
    address public _ChanceInvite;
    address public DROP_ADDR;
    address public DROP_MINTER;
    
    mapping(address => uint256) public accountMap;

    struct WINNER {
        uint256 _winnerID;
        uint256 _jackpot;
        bool _withdraw;
        uint256 _timestamp;
        uint256 number;
    }
    mapping(uint256 => WINNER) public winnerMap;

    uint256 public round;
    uint256 public roundAmount;
    uint256 public jackpot;
    uint256 public currentID;
    uint256 public lastEnd;
    string public baseTokenURI;

    constructor(address drop_addr, address invite_addr) {
        DROP_ADDR = drop_addr;
        _ChanceInvite = invite_addr;
        DROP_MINTER = msg.sender;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unPause() public onlyOwner {
        _unpause();
    }

    function setChanceAddr(address _addr) public onlyOwner {
        CHANCE_ADDR = _addr;
    }

    function setCommunityAddr(address _addr) public onlyOwner {
        COMMUNITY_ADDR = _addr;
    }

    function setDropMinter(address _addr) public onlyOwner {
        DROP_MINTER = _addr;
    }

    uint256 public _mintPrice;

    function setMintPrice(uint256 price) public onlyOwner {
        _mintPrice = price;
    }

    function deposit(uint256 amount) payable public {
        require(msg.value == amount);
    }

    function allotAmount(uint256 amount, uint256 invite_amount) private {
       uint256 community_amount = amount * 3 / 100;
       accountMap[COMMUNITY_ADDR] += community_amount;
       jackpot += amount - community_amount - invite_amount;
    }

    modifier onlyDropMinter() {
        require(msg.sender == DROP_MINTER, "DropPermissionDenied" );
        _;
    }

    function dropChanceWinner(uint256 _timestamp) public onlyDropMinter {
        uint256 winner_id = IChanceDrop(DROP_ADDR).drop_winner_token_id(round, currentID, lastEnd);

        WINNER memory winner;
        winner._jackpot = jackpot;
        winner._winnerID = winner_id;
        winner._timestamp = _timestamp;
        winnerMap[round] = winner;
        emit dropLog(round, winner_id, jackpot);

        jackpot = 0;
        roundAmount = 0;
        round += 1;
        lastEnd = currentID;
    }

    function batchMintWIN(string memory _inviteCode, uint256 _count) public whenNotPaused payable {
        require(currentID + _count - lastEnd <= 100, "roundJoinMax"); 
        uint amount = _mintPrice * _count;
        roundAmount += amount;
        deposit(amount);

        uint invite_amount = 0;
        address inviteAddr = IChanceInvite(_ChanceInvite).inviteParty(msg.sender, _inviteCode);
        if (inviteAddr != BLACKHOLE_ADDR) {
            invite_amount = amount * 10 / 100;
            accountMap[inviteAddr] += invite_amount;
            emit inviteLog(msg.sender, inviteAddr, invite_amount);
        }

        allotAmount(amount, invite_amount);
        uint256[] memory tokenIDs = IChance(CHANCE_ADDR).batchMint(msg.sender, _count);
        
        uint256 tokenId;
        for (uint i = 0; i < tokenIDs.length; i++) {
            tokenId = tokenIDs[i];
            emit mintLog(msg.sender, tokenId, round, lastEnd);
        }
        currentID = tokenId;
    }

    modifier checkWin(uint256 _r) {
        require(winnerMap[_r]._winnerID != 0, "NotDropThisRound" );
        require(winnerMap[_r]._withdraw == false, "AlreadyWithdrew" );
        _;
    }

    function updateTreasury(uint256 _r) public onlyOwner checkWin(_r) {
        winnerMap[_r]._withdraw = true;
        accountMap[COMMUNITY_ADDR] += winnerMap[_r]._jackpot;
    }

    function withdrawAmount(address payable _to, uint256 _amount) public whenNotPaused nonReentrant {
        uint256 amount = accountMap[msg.sender];
        require(amount >= 0.025 ether, "AtLest0.025");
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

    function withdrawByWinner(uint256 _r, address payable _to) public checkWin(_r) whenNotPaused nonReentrant {
        address winner = IChance(CHANCE_ADDR).ownerOf(winnerMap[_r]._winnerID);
        require(winner == msg.sender, "NotWin");
        uint256 amount = winnerMap[_r]._jackpot;
        require(amount <= address(this).balance, "NotEnough");
        winnerMap[_r]._withdraw = true;
        (bool success, ) = _to.call{value: amount}("");
        require(success, "FailedToSend");
        emit winnerWithdrawLog(address(this), msg.sender, amount, winnerMap[_r]._winnerID);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IChanceInvite {
    function inviteParty(address _addr, string memory _inviteCode) external returns (address);

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IChanceDrop {
    function drop_winner_token_id(uint256 round, uint256 end, uint256 lastEnd) external returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IChance {
    function ownerOf(uint256 id) external returns(address);
    function batchMint(address _addr, uint256 c) external returns(uint256[] memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
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