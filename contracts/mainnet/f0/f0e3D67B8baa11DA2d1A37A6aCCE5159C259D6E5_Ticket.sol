// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

abstract contract IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) virtual external returns (bool);

    function transfer(address to, uint256 amount) public virtual returns (bool);
}

contract Ticket is Ownable, ReentrancyGuard {
    event reportWinner(address winner, uint256 time, uint256 bonus);

    struct WinnerStruct {
        address winner;
        uint256 bonus;
        uint256 time;
        uint8 status;
    }

    uint256 public ticketPrice;
    uint256 public startTime;
    uint256 public endTime;
    mapping(address => uint256) userBuyTotalMoney;
    mapping(address => uint256) refTotalMoney;
    address[] smallTicketUserList;
    WinnerStruct[] smallWinnerWithdraw;
    uint256 public smallWinnerBonus;
    uint[] public bigWinnerWithdrawRate;
    uint256 public totalBonus;
    mapping(uint256 => WinnerStruct[]) private bigWinnerWithdraw;
    mapping(uint256 => uint8) private bigRoundHiveOpen;
    address[10] private bigWinnerList;
    uint256 private bigRound = 0;
    uint256 private _numberSmallRound = 1;
    address public usdtAddress;
    address public inviteWallet;
    address public nextWallet;
    address public feeWallet;
    uint256[] addTime;
    uint256 public bigTotalJoinCount;
    bool public gameStatus;


    constructor(uint256[] memory _bigWinnerWithdrawRate, uint256 _smallWinnerBonus, uint256 _ticketPrice,
        address _usdtAddress, address _inviteWallet, address _nextWallet,address _feeWallet, uint256[] memory _addTime){
        bigWinnerWithdrawRate = _bigWinnerWithdrawRate;
        smallWinnerBonus = _smallWinnerBonus;
        ticketPrice = _ticketPrice;
        usdtAddress = _usdtAddress;
        inviteWallet = _inviteWallet;
        nextWallet = _nextWallet;
        feeWallet = _feeWallet;
        addTime = _addTime;
    }

    function buyTicket(address ref) public callerIsUser nonReentrant {
        require(block.timestamp >= startTime, "game not start");
        require(gameStatus, "game not start");
        require(endTime >= block.timestamp, "game end");
        if (ref == msg.sender || ref == address(0) || ref == address(0x000000000000000000000000000000000000dEaD)) {
            ref = inviteWallet;
        }
        refTotalMoney[ref] = refTotalMoney[ref] + ticketPrice / 10;
        IERC20(usdtAddress).transferFrom(msg.sender, ref, ticketPrice / 10);
        IERC20(usdtAddress).transferFrom(msg.sender, address(this), ticketPrice - ticketPrice / 10);
        userBuyTotalMoney[msg.sender] = userBuyTotalMoney[msg.sender] + ticketPrice;
        bigTotalJoinCount++;
        uint256 currentStep = bigTotalJoinCount / 1000;
        if (currentStep >= addTime.length) {
            currentStep = addTime.length - 1;
        }
        endTime = endTime + addTime[currentStep];
        if (endTime - block.timestamp > 3600) {
            endTime = block.timestamp + 3600;
        }
        smallTicketUserList.push(msg.sender);
        if (smallTicketUserList.length >= 50) {
            WinnerStruct memory smallWinner = WinnerStruct(smallTicketUserList[getRandom(50)], smallWinnerBonus, block.timestamp, 2);
            smallWinnerWithdraw.push(smallWinner);
            _numberSmallRound++;
            delete smallTicketUserList;
            totalBonus -= smallWinnerBonus;
            IERC20(usdtAddress).transfer(smallWinner.winner, smallWinnerBonus);
            emit reportWinner(smallWinner.winner, smallWinner.time, smallWinner.bonus);
        }
        removeAndAddLast(msg.sender);
        totalBonus += ticketPrice - ticketPrice / 10;
        if (bigTotalJoinCount / 1000 >= addTime.length - 1) {
            if (getRandom(1000) == 1) {
                gameStatus = false;
            }
        }
    }

    function openBig() internal {
        require(block.timestamp >= endTime || !gameStatus, "game not end");
        require(bigRoundHiveOpen[bigRound] != 1, "have open");
        gameStatus = false;
        uint256 totalSendWinnerBonus = 0;
        for (uint i = 0; i < bigWinnerList.length; i++) {
            WinnerStruct memory bigWinner = WinnerStruct(bigWinnerList[i], totalBonus * bigWinnerWithdrawRate[i] / 100000000, block.timestamp, 2);
            bigWinnerWithdraw[bigRound].push(bigWinner);
            IERC20(usdtAddress).transfer(bigWinnerList[i], bigWinner.bonus);
            totalSendWinnerBonus = totalSendWinnerBonus + bigWinner.bonus;
            emit reportWinner(bigWinner.winner, bigWinner.time, bigWinner.bonus);
        }
        uint256 fee = totalBonus * 15 / 100;
        IERC20(usdtAddress).transfer(feeWallet, fee);
        IERC20(usdtAddress).transfer(nextWallet, totalBonus - totalSendWinnerBonus - fee);
        bigRoundHiveOpen[bigRound] = 1;
        totalBonus = 0;
    }

    function endGame() external onlyOwner {
        openBig();
    }

    function initStartGame(uint256 _startTime, uint256 _endTime) external onlyOwner {
        gameStatus = true;
        startTime = _startTime;
        endTime = _endTime;
    }

    function startGame(uint256 _startTime, uint256 _endTime, uint256[] memory _addTime, uint256 initBouns) external onlyOwner {
        bigRound++;
        startTime = _startTime;
        endTime = _endTime;
        addTime = _addTime;
        delete smallTicketUserList;
        delete bigWinnerList;
        gameStatus = true;
        bigTotalJoinCount = 0;
        IERC20(usdtAddress).transferFrom(nextWallet, address(this), initBouns);
        totalBonus = totalBonus + initBouns;
    }

    function querySomeInfo() external view returns (uint256[] memory){
        uint256[] memory resultList = new uint256[](5);
        resultList[0] = startTime;
        resultList[1] = endTime;
        resultList[2] = totalBonus;
        resultList[3] = userBuyTotalMoney[msg.sender];
        resultList[4] = refTotalMoney[msg.sender];
        return resultList;
    }

    function querySmallWinnerList() external view returns (WinnerStruct[] memory){
        return smallWinnerWithdraw;
    }

    function queryBigWinnerWithdraw(uint round) external view returns (WinnerStruct[] memory){
        return bigWinnerWithdraw[round];
    }

    function queryBigWinnerList() external onlyOwner view returns (address[10] memory){
        return bigWinnerList;
    }

    function queryUserBuyTotalMoney() external view returns (uint256){
        return userBuyTotalMoney[msg.sender];
    }

    function queryRefTotalMoney() external view returns (uint256){
        return refTotalMoney[msg.sender];
    }

    function setBigWinnerWithdrawRate(uint256[] memory newPrice) external onlyOwner {
        bigWinnerWithdrawRate = newPrice;
    }

    function setTicketPrice(uint256 newPrice) external onlyOwner {
        ticketPrice = newPrice;
    }

    function setSmallWinnerBonus(uint256 newPrice) external onlyOwner {
        smallWinnerBonus = newPrice;
    }
    /**
     * @notice for security reasons, CA is not allowed to call sensitive methods.
     */
    modifier callerIsUser() {
        require(tx.origin == _msgSender(), "caller is another contract");
        _;
    }
    function removeAndAddLast(address user) internal {
        for (uint i = 0; i < bigWinnerList.length - 1; i++) {
            bigWinnerList[i] = bigWinnerList[i + 1];
        }
        bigWinnerList[bigWinnerList.length - 1] = user;
    }
    function getRandom(uint256 num) internal view returns (uint256) {
    unchecked {
        uint256 pos = unsafeRandom() % num;
        return pos;
    }
    }

    function unsafeRandom() internal view returns (uint256) {
    unchecked {
        return uint256(keccak256(abi.encodePacked(
                blockhash(block.number - 1),
                block.difficulty,
                block.timestamp,
                block.coinbase,
                _numberSmallRound,
                bigTotalJoinCount,
                tx.origin
            )));
    }
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
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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