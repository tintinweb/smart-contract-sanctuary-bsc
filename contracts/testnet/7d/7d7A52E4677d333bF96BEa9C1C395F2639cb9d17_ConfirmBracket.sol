// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';

enum Status {
    Pending,
    Open,
    Close,
    Claimable,
    Finish
}

struct Lucky {
    Status status;
    uint256 startTime;
    uint256 endTime;
    uint256 priceTicketInPlearn;
    uint32 maxTicketsPerRound;
    uint32 maxTicketsPerUser;
    uint32[] countLuckyNumbersPerBracket;
    uint32 countReservePerBracket;
    uint256 firstTicketId;
    uint256 lastTicketId;
    uint256 amountCollectedInPlearn;
    bool enableReserve;
    uint32[] luckyNumbers;
    uint32[] reserveNumbers;
}

struct Ticket {
    uint32 number;
    address owner;
}

interface IPlearnLucky {
    function startNumber() external view returns (uint32);

    /**
     * @notice Return current lucky id
     */
    function getCurrentLuckyId() external view returns (uint256);

    /**
     * @notice Get round information
     * @param _luckyId: round id
     */
    function getLuckyInfo(uint256 _luckyId) external view returns (Lucky memory);

    function getLuckyTickets(uint256 _luckyId) external view returns (Ticket[] memory luckyTickets);
}

contract ConfirmBracket is ReentrancyGuard, Ownable {
    IPlearnLucky public plearnLucky;

    struct ConfirmInfo {
        uint32 bracket;
        bool isHaveFollower;
        bytes name;
    }

    modifier notContract() {
        require(!_isContract(msg.sender), 'Contract not allowed');
        require(msg.sender == tx.origin, 'Proxy contract not allowed');
        _;
    }

    mapping(uint256 => uint32[]) private _availablesBracket;
    mapping(uint256 => ConfirmInfo) private _confirmInfo;

    event TicketConfirm(
        address confirmer,
        uint256 luckyId,
        uint256 ticketId,
        uint32 barcket,
        bool isHaveFollower,
        bytes name
    );
    event UpdateBracketsDetail(
        uint256 luckyId,
        uint256[] startTimes,
        uint256[] endTimes,
        string[] yatchs,
        string[] ports
    );
    event UpdateBurnTransaction(uint256 luckyId, string transactionHash);

    function confirmTicket(
        uint256 _luckyId,
        uint32 _ticketNumber,
        uint32 _bracket,
        bool _isHaveFollower,
        bytes memory _name
    ) external notContract nonReentrant {
        Lucky memory lucky = plearnLucky.getLuckyInfo(_luckyId);
        require(lucky.status == Status.Claimable, 'Lucky not claimable');

        bool isLucky = false;
        bool isOwner = false;
        for (uint256 i = 0; i < lucky.luckyNumbers.length; i++) {
            if (lucky.luckyNumbers[i] == _ticketNumber) {
                Ticket memory ticket = plearnLucky.getLuckyTickets(_luckyId)[i];
                isLucky = true;
                isOwner = ticket.owner == msg.sender;
                break;
            }
        }
        require(isLucky, 'Number not lucky');
        require(isOwner, 'Not the owner');

        require(_bracket != 0, 'Bracket must be > 0');
        uint32 bracketIndext = _bracket - 1;
        require(bracketIndext < _availablesBracket[_luckyId].length, 'Bracket too high');
        uint32 availableBracket = _availablesBracket[_luckyId][bracketIndext];

        uint256 ticketId = _getTicketIdFromTicketNumber(
            _ticketNumber,
            plearnLucky.startNumber(),
            lucky.firstTicketId,
            lucky.lastTicketId
        );

        ConfirmInfo memory info = _confirmInfo[ticketId];
        if (info.bracket == 0) {
            require(availableBracket > 0, 'Bracket unavailable');
        } else {
            require(info.bracket == _bracket, 'Ticket is confirmed');
        }

        if (info.bracket == 0) {
            availableBracket--;
            _availablesBracket[_luckyId][bracketIndext] = availableBracket;
        }

        info.bracket = _bracket;
        info.isHaveFollower = _isHaveFollower;
        info.name = _name;
        _confirmInfo[ticketId] = info;

        emit TicketConfirm(msg.sender, _luckyId, ticketId, _bracket, _isHaveFollower, _name);
    }

    function getAvailablesBracket(uint256 _luckyId) external view returns (uint32[] memory) {
        return _availablesBracket[_luckyId];
    }

    function getConfirmBracketInfo(uint256 _ticketId)
        external
        view
        returns (
            uint32 bracket,
            bool isHaveFollower,
            bytes memory name
        )
    {
        ConfirmInfo memory info = _confirmInfo[_ticketId];
        return (info.bracket, info.isHaveFollower, info.name);
    }

    function setAvailablesBracket(uint256 _luckyId, uint32[] memory _avilablesBracket) external onlyOwner {
        Lucky memory lucky = plearnLucky.getLuckyInfo(_luckyId);
        require(lucky.status == Status.Open, 'Lucky not Open');
        _availablesBracket[_luckyId] = _avilablesBracket;
    }

    /**
     * @notice Set the address for the PLearnLuckyDraw
     * @param _plearnLucky: address of the Plearn lucky
     */
    function setPlearnLuckyAddress(address _plearnLucky) external onlyOwner {
        IPlearnLucky(_plearnLucky).getCurrentLuckyId();
        plearnLucky = IPlearnLucky(_plearnLucky);
    }

    function updateBracketsDetail(
        uint256 _luckyId,
        uint256[] calldata startTimes,
        uint256[] calldata endTimes,
        string[] calldata yatchs,
        string[] calldata ports
    ) external onlyOwner nonReentrant {
        require(
            startTimes.length == endTimes.length &&
                endTimes.length == yatchs.length &&
                ports.length == startTimes.length &&
                startTimes.length == _availablesBracket[_luckyId].length,
            'Not same length'
        );
        emit UpdateBracketsDetail(_luckyId, startTimes, endTimes, yatchs, ports);
    }

    function updateBurnTransaction(uint256 _luckyId, string calldata _transactionHash) external onlyOwner nonReentrant {
        emit UpdateBurnTransaction(_luckyId, _transactionHash);
    }

    function _getTicketIdFromTicketNumber(
        uint32 _ticketNumber,
        uint32 _startNumber,
        uint256 _firstTicketId,
        uint256 _lastTicketId
    ) internal pure returns (uint256) {
        require(_ticketNumber >= _startNumber, 'Invalid ticket number');

        uint256 ticketId = ((_ticketNumber - _startNumber) + _firstTicketId);

        require(ticketId >= _firstTicketId && ticketId <= _lastTicketId, 'Invalid ticket number');
        return ticketId;
    }

    /**
     * @notice Check if an address is a contract
     */
    function _isContract(address _addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
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