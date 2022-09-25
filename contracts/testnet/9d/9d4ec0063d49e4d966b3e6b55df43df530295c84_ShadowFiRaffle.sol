/**
 *Submitted for verification at BscScan.com on 2022-09-25
*/

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


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

// File: ShadowFiRaffle.sol


pragma solidity ^0.8.4;


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
    address private _court;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    event CourtUpdated(
        address indexed previousOwner,
        address indexed newCourt
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
        _setCourtAddress(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Returns the address of the current court.
     */
    function court() public view virtual returns (address) {
        return _court;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyCourt() {
        require(court() == _msgSender(), "Ownable: caller is not the court");
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    /**
     * @dev Sets court address of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function setCourtAddress(address newCourt) public virtual onlyOwner {
        require(
            newCourt != address(0),
            "Ownable: new court is the zero address"
        );
        _setCourtAddress(newCourt);
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

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _setCourtAddress(address newCourt) internal virtual {
        address oldCourt = _court;
        _court = newCourt;
        emit CourtUpdated(oldCourt, newCourt);
    }
}

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
}

interface IShadowFiDonate {
    function getUserStakedTier(address user) external view returns (uint256);
}

contract ShadowFiRaffle is Ownable, ReentrancyGuard {
    uint256 public mainPool;
    uint256 public secondPool;
    uint256 public thirdPool;

    uint256 public mainPoolPercent = 7142;
    uint256 public secondPoolPercent = 1429;
    uint256 public thirdPoolPercent = 1429;

    uint256 public mainCarryPercent = 7500;
    uint256 public secondCarryPercent = 2500;
    uint256 public raffleTime = 604800;
    uint256 public deadTicketRatio = 1;

    IShadowFiDonate public donationContract;

    address public DEAD_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    event Ticket(address user, uint256 ticketNo);
    event Draw(uint256 blockForHash);
    event Winner(address user, uint256 ticket, uint256 amount);
    event NoWinner(address user, uint256 ticket, uint256 amountCarryover);
    event SessionStarted(uint256 sessionID);


    struct RaffleInfo {
        uint256 lastSoldTicketNo;
        uint256 sessionTime;
        uint256 startTime;
        uint256 endTime;
        uint256 winningNo;
        mapping (uint256 => address) ticketOwnerList;
        uint256 deadAccrual;
        uint256 blockHashValue;
        uint256 blockNumber;
    }

    uint256 currentRaffleId;
    mapping (uint256 => RaffleInfo) raffleInfos;
    mapping (address => uint256) ticketsOwnedByUser;

    constructor(
        address _donationContract
    ) {
        donationContract = IShadowFiDonate(_donationContract);
    }


    /*******************************************************************************************************/
    /************************************* Admin Functions *************************************************/
    /*******************************************************************************************************/

    function withdrawBNB() public nonReentrant onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    function withdrawTokens(address _token) public nonReentrant onlyOwner {
        IERC20 token = IERC20(_token);
        uint256 amount = token.balanceOf(address(this));
        token.transfer(address(msg.sender), amount);
    }

    function setDonationAddress(address _donationContract) public onlyOwner {
        donationContract = IShadowFiDonate(address(_donationContract));
    }

    function setPoolPercents(uint256 _mainPoolPercent, uint256 _secondPoolPercent, uint256 _thirdPoolPercent) public onlyOwner {
        require(mainPoolPercent + secondPoolPercent + thirdPoolPercent == 10000, "All three percents summed must equal 100%.");
        
        mainPoolPercent = _mainPoolPercent;
        secondPoolPercent = _secondPoolPercent;
        thirdPoolPercent = _thirdPoolPercent;
    }

    function setSessionParameters(uint256 _sessionTime, uint256 _deadAccrual, uint256 _percentToMainPool, uint256 _percentToSecondPool) public onlyOwner {
        raffleTime = _sessionTime;
        deadTicketRatio = _deadAccrual;
        mainCarryPercent = _percentToMainPool;
        secondCarryPercent = _percentToSecondPool;
    }

    function startSession(uint256 _sessionId, uint256 _sessionTime, uint256 _deadAccrual, uint256 _mainPercent, uint256 _secondPercent) public onlyOwner {
        require(raffleInfos[currentRaffleId].startTime == 0, "You already initiated the raffle contract.");
        _startSession(_sessionId, _sessionTime, _deadAccrual, _mainPercent, _secondPercent);
    }

    /*******************************************************************************************************/
    /************************************* Court Functions *************************************************/
    /*******************************************************************************************************/

    function draw() public onlyCourt {
        require(block.timestamp >= raffleInfos[currentRaffleId].endTime, "The raffle period has not completed yet.");
        raffleInfos[currentRaffleId].blockNumber = block.number;
        emit Draw(raffleInfos[currentRaffleId].blockNumber);
    }

    function revealWinner() public onlyCourt {
        require(block.timestamp >= raffleInfos[currentRaffleId].endTime, "The raffle period has not completed yet.");
        
        bytes32 blockHashValue = blockhash(raffleInfos[currentRaffleId].blockNumber);

        require(blockHashValue != 0x0, "Invalid Blockhash.");

        uint256 winnerTicketNo;
        uint256 rangeFromZero = raffleInfos[currentRaffleId].lastSoldTicketNo;

        winnerTicketNo = uint256(blockHashValue) % rangeFromZero ;
        raffleInfos[currentRaffleId].winningNo = winnerTicketNo;
        address winningUser = raffleInfos[currentRaffleId].ticketOwnerList[winnerTicketNo];

        if (winningUser == DEAD_ADDRESS || winnerTicketNo == 0) {
            mainPool += (secondPool * mainCarryPercent) / 10000;
            secondPool = (secondPool * secondCarryPercent) / 10000;
            emit NoWinner(raffleInfos[currentRaffleId].ticketOwnerList[winnerTicketNo], raffleInfos[currentRaffleId].winningNo, mainPool);
        } else  {
            uint256 mainPoolBonusPercent = donationContract.getUserStakedTier(msg.sender) * 2;
            uint256 payout = (mainPool * 100) / (92 + mainPoolBonusPercent);
            payable(winningUser).transfer(payout);
            mainPool = secondPool + (mainPool - payout);
            emit Winner(raffleInfos[currentRaffleId].ticketOwnerList[winnerTicketNo], raffleInfos[currentRaffleId].winningNo, mainPool);
        }

        _startSession(currentRaffleId + 1, raffleTime, deadTicketRatio, mainCarryPercent, secondCarryPercent);
    }

    /*******************************************************************************************************/
    /******************************* Donation Contract Functions *******************************************/
    /*******************************************************************************************************/

    function deposit(address user, uint256 ticketAmount) external payable {
        require(msg.sender == address(donationContract), "Only the donation contract can interact with this function.");
        require(block.timestamp <= raffleInfos[currentRaffleId].endTime, "Please wait for the next raffle session to begin.");

        mainPool += (msg.value * mainPoolPercent) / 10000;
        secondPool += (msg.value * secondPoolPercent) / 10000;

        payable(owner()).transfer((msg.value * thirdPoolPercent) / 10000);

        uint256 ticketCount = ticketAmount;
        uint256 lastTicketNo = raffleInfos[currentRaffleId].lastSoldTicketNo;

        address addr1 = user;
        address addr2 = DEAD_ADDRESS;

        uint256 accrual1 = 1;
        uint256 accrual2 = raffleInfos[currentRaffleId].deadAccrual;

        if (block.timestamp % 2 == 0) {
            addr1 = DEAD_ADDRESS;
            addr2 = user;

            accrual1 = raffleInfos[currentRaffleId].deadAccrual;
            accrual2 = 1;
        }

        for (uint256 ticketNo = lastTicketNo + 1; ticketNo <= lastTicketNo + (ticketCount * accrual1); ticketNo++) {
            raffleInfos[currentRaffleId].ticketOwnerList[ticketNo] = addr1;
            raffleInfos[currentRaffleId].lastSoldTicketNo = raffleInfos[currentRaffleId].lastSoldTicketNo + 1;
            ticketsOwnedByUser[msg.sender] = raffleInfos[currentRaffleId].lastSoldTicketNo + 1;
            emit Ticket(addr1, ticketNo);
        }

        for (uint256 ticketNo = lastTicketNo + (ticketCount * accrual1) + 1; ticketNo <= lastTicketNo + ticketCount * (accrual1 + accrual2); ticketNo++) {
            raffleInfos[currentRaffleId].ticketOwnerList[ticketNo] = addr2;
            raffleInfos[currentRaffleId].lastSoldTicketNo = raffleInfos[currentRaffleId].lastSoldTicketNo + 1;
            ticketsOwnedByUser[msg.sender] = raffleInfos[currentRaffleId].lastSoldTicketNo + 1;
            emit Ticket(addr2, ticketNo);
        }
    }

    /*******************************************************************************************************/
    /*********************************** Internal Functions ************************************************/
    /*******************************************************************************************************/

    function _startSession(uint256 _sessionId, uint256 _sessionTime, uint256 _deadAccrual, uint256 _mainPercent, uint256 _secondPercent) internal {
        currentRaffleId = _sessionId;
        raffleInfos[currentRaffleId].sessionTime = _sessionTime;
        raffleInfos[currentRaffleId].startTime = block.timestamp;
        raffleInfos[currentRaffleId].endTime = raffleInfos[currentRaffleId].startTime + raffleInfos[currentRaffleId].sessionTime;
        raffleInfos[currentRaffleId].deadAccrual = _deadAccrual;
        mainCarryPercent = _mainPercent;
        secondCarryPercent = _secondPercent;

        emit SessionStarted(_sessionId);
    }

    /*******************************************************************************************************/
    /************************************* View Functions **************************************************/
    /*******************************************************************************************************/

    function getBlockHash() public view returns (bytes32) {
        return blockhash(raffleInfos[currentRaffleId].blockNumber);
    }

    function verifyResult(bytes32 _blockhash, uint256 ticketAmount) public pure returns (uint256) {
        return uint256(_blockhash) % ticketAmount;
    }

    function getRaffleInfo(uint256 _raffleID) public view returns(uint256 lastSoldTicketNo, uint256 endTime, uint256 winningNo, uint256 deadAccrual, uint256 blockHashValue, uint256 blockNumber) {
        return (raffleInfos[_raffleID].lastSoldTicketNo, raffleInfos[_raffleID].endTime, raffleInfos[_raffleID].winningNo, raffleInfos[_raffleID].deadAccrual, raffleInfos[_raffleID].blockHashValue, raffleInfos[_raffleID].blockNumber);
    }

    function getTicketOwner(uint256 _ticketNo) public view returns (address) {
        return raffleInfos[currentRaffleId].ticketOwnerList[_ticketNo];
    }

    function getTicketsOwnedByUser(address _user) public view returns (uint256) {
        return ticketsOwnedByUser[_user];
    }

    receive() external payable {}
    fallback() external payable {}
}