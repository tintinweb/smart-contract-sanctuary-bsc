/**
 *Submitted for verification at BscScan.com on 2022-10-28
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
    uint256 private mainCarryPercent = 0;
    uint256 private secondCarryPercent = 10000;
    uint256 private raffleTime = 604800;
    uint256 private deadTicketRatio = 1;

    address public treasuryAddress = msg.sender;

    IShadowFiDonate public donationContract;

    address private ZERO_ADDRESS = 0x0000000000000000000000000000000000000000;

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
        address winner;
        mapping (uint256 => address) ticketOwnerList;
        mapping (address => uint256[]) ticketsOwnedByUser;
        uint256 deadAccrual;
        bytes32 blockHashValue;
        uint256 blockNumber;
    }

    uint256 public currentRaffleId;
    mapping (uint256 => RaffleInfo) public raffleInfos;

    struct PoolInfo {
        uint256 mainPool;
        uint256 mainPoolPercent;
        uint256 mainCarryPercent;
        uint256 secondPool;
        uint256 secondPoolPercent;
        uint256 secondCarryPercent;
        uint256 treasuryPercent;
    }

    PoolInfo public poolInfo;

    constructor(
        address _donationContract
    ) {
        donationContract = IShadowFiDonate(_donationContract);
        poolInfo.mainPoolPercent = 7142;
        poolInfo.secondPoolPercent = 1429;
        poolInfo.treasuryPercent = 1429;
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

    function injectPool() public payable nonReentrant onlyOwner {
        poolInfo.mainPool += msg.value;
    }

    function setDonationAddress(address _donationContract) public onlyOwner {
        donationContract = IShadowFiDonate(address(_donationContract));
    }

    function setTreasury(address _treasuryAddress) public onlyOwner {
        treasuryAddress = _treasuryAddress;
    }

    function setPoolPercents(uint256 _mainPoolPercent, uint256 _secondPoolPercent, uint256 _treasuryPercent) public onlyOwner {
        require(_mainPoolPercent + _secondPoolPercent + _treasuryPercent == 10000, "All three percents summed must equal 100%.");
        require(_treasuryPercent <= 2858, "20% is the largest amount allowed to Treasury");
        
        poolInfo.mainPoolPercent = _mainPoolPercent;
        poolInfo.secondPoolPercent = _secondPoolPercent;
        poolInfo.treasuryPercent = _treasuryPercent;
    }

    function setSessionParameters(uint256 _sessionTime, uint256 _deadAccrual, uint256 _percentToMainPool, uint256 _percentToSecondPool) public onlyOwner {
        require(_percentToMainPool + _percentToSecondPool == 10000, "Main + Secondary percents must equal 100%.");
        raffleTime = _sessionTime;
        deadTicketRatio = _deadAccrual;
        mainCarryPercent = _percentToMainPool;
        secondCarryPercent = _percentToSecondPool;
    }

    function startSession(uint256 _sessionId, uint256 _sessionTime, uint256 _deadAccrual, uint256 _mainCarryPercent, uint256 _secondCarryPercent) public onlyOwner {
        require(raffleInfos[currentRaffleId].startTime == 0, "You already initiated the raffle contract.");
        _startSession(_sessionId, _sessionTime, _deadAccrual, _mainCarryPercent, _secondCarryPercent);
    }

    /*******************************************************************************************************/
    /************************************* Court Functions *************************************************/
    /*******************************************************************************************************/

    function draw() public onlyCourt {
        require(block.timestamp >= raffleInfos[currentRaffleId].endTime, "The raffle period has not completed yet.");

        raffleInfos[currentRaffleId].blockNumber = block.number;
        emit Draw(raffleInfos[currentRaffleId].blockNumber);

        if (raffleInfos[currentRaffleId].lastSoldTicketNo == 0) {
            _startSession(currentRaffleId + 1, raffleTime, deadTicketRatio, mainCarryPercent, secondCarryPercent);
        }

    }

    function revealWinner() public onlyCourt {
        require(block.timestamp >= raffleInfos[currentRaffleId].endTime, "The raffle period has not completed yet.");
        
        bytes32 blockHashValue = blockhash(raffleInfos[currentRaffleId].blockNumber);
        raffleInfos[currentRaffleId].blockHashValue = blockHashValue;
        require(blockHashValue != 0x0, "Invalid Blockhash.");

        uint256 winnerTicketNo;
        uint256 rangeFromZero = raffleInfos[currentRaffleId].lastSoldTicketNo;

        winnerTicketNo = uint256(blockHashValue) % rangeFromZero;
        raffleInfos[currentRaffleId].winningNo = winnerTicketNo;
        address winningUser = raffleInfos[currentRaffleId].ticketOwnerList[winnerTicketNo];

        raffleInfos[currentRaffleId].winner = winningUser;

        if (winningUser == ZERO_ADDRESS || raffleInfos[currentRaffleId].lastSoldTicketNo == 0) {
            poolInfo.mainPool += (poolInfo.secondPool * poolInfo.mainCarryPercent) / 10000;
            poolInfo.secondPool = (poolInfo.secondPool * poolInfo.secondCarryPercent) / 10000;
            emit NoWinner(winningUser, raffleInfos[currentRaffleId].winningNo, poolInfo.mainPool);
        }
        else if (donationContract.getUserStakedTier(winningUser) > 0) {            
            uint256 mainPoolBonusPercent = donationContract.getUserStakedTier(winningUser) * 2;
            uint256 payout = (poolInfo.mainPool * (90 + (mainPoolBonusPercent + 2)) / 100);
            payable(winningUser).transfer(payout);
            poolInfo.mainPool = poolInfo.secondPool + (poolInfo.mainPool - payout);
            poolInfo.secondPool = 0;
            emit Winner(winningUser, raffleInfos[currentRaffleId].winningNo, poolInfo.mainPool);
        } else {
            uint256 payout = (poolInfo.mainPool * 90) / 100;
            payable(winningUser).transfer(payout);
            poolInfo.mainPool = poolInfo.secondPool + (poolInfo.mainPool - payout);
            poolInfo.secondPool = 0;
            emit Winner(winningUser, raffleInfos[currentRaffleId].winningNo, poolInfo.mainPool);
            }

        _startSession(currentRaffleId + 1, raffleTime, deadTicketRatio, mainCarryPercent, secondCarryPercent);
    }
    
    // This is a backup method to reveal winner.
    // Should an event arise where draw is called, but 256 blocks are allowed to pass before revealWinner.
    // Court address can only utilize this function if 256 blocks have passed since draw call.

    function revealWinnerManual(bytes32 _blockHash) public onlyCourt {
        require(block.timestamp >= raffleInfos[currentRaffleId].endTime, "The raffle period has not completed yet.");
        require(block.number - raffleInfos[currentRaffleId].blockNumber >= 256, "Can only be used if 256 blocks have passed.");
        
        raffleInfos[currentRaffleId].blockHashValue = _blockHash;
        require(_blockHash != 0x0, "Invalid Blockhash.");

        uint256 winnerTicketNo;
        uint256 rangeFromZero = raffleInfos[currentRaffleId].lastSoldTicketNo;

        winnerTicketNo = uint256(_blockHash) % rangeFromZero;
        raffleInfos[currentRaffleId].winningNo = winnerTicketNo;
        address winningUser = raffleInfos[currentRaffleId].ticketOwnerList[winnerTicketNo];

        if (winningUser == ZERO_ADDRESS || raffleInfos[currentRaffleId].lastSoldTicketNo == 0) {
            poolInfo.mainPool += (poolInfo.secondPool * poolInfo.mainCarryPercent) / 10000;
            poolInfo.secondPool = (poolInfo.secondPool * poolInfo.secondCarryPercent) / 10000;
            emit NoWinner(raffleInfos[currentRaffleId].ticketOwnerList[winnerTicketNo], raffleInfos[currentRaffleId].winningNo, poolInfo.mainPool);
        }

        else {
            uint256 mainPoolBonusPercent = donationContract.getUserStakedTier(winningUser) * 2;
            uint256 payout = (poolInfo.mainPool * (92 + mainPoolBonusPercent)) / 100;
            payable(winningUser).transfer(payout);
            poolInfo.mainPool = poolInfo.secondPool + (poolInfo.mainPool - payout);
            poolInfo.secondPool = 0;
            emit Winner(raffleInfos[currentRaffleId].ticketOwnerList[winnerTicketNo], raffleInfos[currentRaffleId].winningNo, poolInfo.mainPool);
        }

        _startSession(currentRaffleId + 1, raffleTime, deadTicketRatio, mainCarryPercent, secondCarryPercent);
    }

    /*******************************************************************************************************/
    /******************************* Donation Contract Functions *******************************************/
    /*******************************************************************************************************/

    function deposit(address user, uint256 ticketAmount) external payable {
        require(msg.sender == address(donationContract), "Only the donation contract can interact with this function.");
        require(block.timestamp <= raffleInfos[currentRaffleId].endTime, "Please wait for the next raffle session to begin.");

        poolInfo.mainPool += (msg.value * poolInfo.mainPoolPercent) / 10000;
        poolInfo.secondPool += (msg.value * poolInfo.secondPoolPercent) / 10000;
        payable(treasuryAddress).transfer((msg.value * poolInfo.treasuryPercent) / 10000);

        if (block.timestamp % 2 == 0) {
            raffleInfos[currentRaffleId].lastSoldTicketNo = raffleInfos[currentRaffleId].lastSoldTicketNo + (raffleInfos[currentRaffleId].deadAccrual * ticketAmount);
        }
            
        for (uint256 ticketNo = raffleInfos[currentRaffleId].lastSoldTicketNo + 1; ticketNo <= raffleInfos[currentRaffleId].lastSoldTicketNo + ticketAmount; ticketNo++) {
            raffleInfos[currentRaffleId].ticketOwnerList[ticketNo] = user;
            raffleInfos[currentRaffleId].ticketsOwnedByUser[user].push(ticketNo);
            emit Ticket(user, ticketNo);
        }

        raffleInfos[currentRaffleId].lastSoldTicketNo = raffleInfos[currentRaffleId].lastSoldTicketNo + ticketAmount;

        if (block.timestamp % 2 == 1) {
            raffleInfos[currentRaffleId].lastSoldTicketNo = raffleInfos[currentRaffleId].lastSoldTicketNo + (raffleInfos[currentRaffleId].deadAccrual * ticketAmount);
        }
    }

    /*******************************************************************************************************/
    /*********************************** Internal Functions ************************************************/
    /*******************************************************************************************************/

    function _startSession(uint256 _sessionId, uint256 _sessionTime, uint256 _deadAccrual, uint256 _mainCarryPercent, uint256 _secondCarryPercent) internal {
        currentRaffleId = _sessionId;
        raffleInfos[currentRaffleId].sessionTime = _sessionTime;
        raffleInfos[currentRaffleId].startTime = block.timestamp;
        raffleInfos[currentRaffleId].endTime = raffleInfos[currentRaffleId].startTime + raffleInfos[currentRaffleId].sessionTime;
        raffleInfos[currentRaffleId].deadAccrual = _deadAccrual;
        poolInfo.mainCarryPercent = _mainCarryPercent;
        poolInfo.secondCarryPercent = _secondCarryPercent;

        emit SessionStarted(_sessionId);
    }

    /*******************************************************************************************************/
    /************************************* View Functions **************************************************/
    /*******************************************************************************************************/

    function verifyResult(bytes32 _blockhash, uint256 ticketAmount) public pure returns (uint256) {
        return uint256(_blockhash) % ticketAmount;
    }

    function getTicketOwner(uint256 _ticketNo) public view returns (address) {
        return raffleInfos[currentRaffleId].ticketOwnerList[_ticketNo];
    }

    function getTicketsOwnedByUser(address _user) public view returns (uint256[] memory) {
        return raffleInfos[currentRaffleId].ticketsOwnedByUser[_user];
    }

    receive() external payable {}
    fallback() external payable {}
}