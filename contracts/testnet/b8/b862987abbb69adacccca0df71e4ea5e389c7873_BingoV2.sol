/**
 *Submitted for verification at BscScan.com on 2022-05-05
*/

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/BingoV2.sol


pragma solidity >=0.4.22 <=0.9.0;



contract BingoV2 {
    IERC20 public utilityToken;
    bool tempLockContract = false;
    uint256 public currentEpoch = 0;
    uint16 public cardAmount = 0;

    uint256 lockPeriod = 600;
    uint256 roundPeriod = 3600;

    mapping(uint => mapping(address => BetInfo[])) ledgers;
    mapping(uint => Round) public rounds;
    mapping(uint => mapping(uint256 => bool)) public roundWinCards;
    mapping(address => uint256[]) public userRounds;
    mapping(uint => uint[]) public results;
    mapping(uint16 => uint256) public cardPrice;

    event NewRound(uint256 indexed epoch);
    event EndedRound(uint256 indexed epoch, uint256[] cards);
    event NewRandomNumber(uint256 indexed epoch, uint randomNo);
    event NewPlaceCard(uint256 indexed epoch, address userAddress, uint256 cardId);
    event NewBingoCard(uint256 amount, address generator, uint256 totalCards);

    struct BetInfo {
        uint epoch;
        uint16 cardId;
        bool claimed;
    }

    struct Round {
        uint epoch;
        uint256 startTimestamp;
        uint256 lockTimestamp;
        uint256 closeTimestamp;
        uint16 players;
        bool isEnded;
    }

    constructor(IERC20 _token) {
        utilityToken = _token;
    }

    /**
     * @notice generate bingo card
     * @dev only admin or dev
     * amount : new card amount as you want, price : price per card
     */
    function generateBingoCard(uint16 amount, uint256 price) external {
        require(amount != 0, "Amount should not equal zero");
        for (uint16 i = 1; i<=amount;i++) {
            cardPrice[cardAmount += i] = price;
        }
        cardAmount += amount;
        emit NewBingoCard(amount, msg.sender, cardAmount);
    }

    /**
     * @notice get user rounds,
     * user > address user
     * offset > pagination
     * size > size of page
     */
    function getUserRound(
        address user,
        uint256 offset,
        uint256 size) 
        external
        view
        returns (
            BetInfo[] memory,
            uint256
        )
    {
        uint256 length = size;
        if (length > userRounds[user].length - offset) {
            length = userRounds[user].length - offset;
        }

        BetInfo[] memory betInfo = new BetInfo[](length);
        for (uint256 k = 0; k<length; k++) {
            uint256 roundId = userRounds[user][k + offset];
            BetInfo[] memory bets = ledgers[roundId][user];
            betInfo = concateBetInfoArrays(betInfo, bets);
        }
        return (betInfo, offset + length);
    }

    function concateBetInfoArrays(BetInfo[] memory b1, BetInfo[] memory b2) internal pure returns(BetInfo[] memory) {
        BetInfo[] memory returnArr = new BetInfo[](b1.length + b2.length);
        uint i=0;
        for (; i < b1.length; i++) {
            returnArr[i] = b1[i];
        }
        uint j=0;
        while (j < b2.length) {
            returnArr[i++] = b2[j++];
        }
        return returnArr;
    } 

    /**
     * @notice start round
     * @dev Callable by admin
     */
    function startRound() external {
        // Increment currentEpoch to current round (n)
        currentEpoch = currentEpoch + 1;
        _safeStartRound(currentEpoch);
    }

    function _safeStartRound(uint256 epoch) internal {
        require(
            !tempLockContract,
            "Bingo contract has temporarily disable."
        );

        require(
            rounds[epoch - 1].isEnded,
            "Previous round not ended"
        );

        Round storage round = rounds[epoch];
        round.epoch = epoch;
        round.startTimestamp = block.timestamp;
        round.lockTimestamp = block.timestamp + roundPeriod - lockPeriod;
        round.closeTimestamp = block.timestamp + roundPeriod;
        round.players = 0;
        round.isEnded = false;
        emit NewRound(epoch);
    }

    /**
     * @notice End rounded with winner card ids
     * @dev Callable by admin
     */
    function endRound(uint256 epoch, uint[] memory winCards) external {
        _safeEndRound(epoch, winCards);
    }

    /**
     * @notice End rounded by specifig round id ( epoch )
     */
    function _safeEndRound(uint epoch, uint[] memory winCards) internal {
        require(
            epoch <= currentEpoch,
            "This round didn't start yet"
        );
        require(
            block.timestamp >= rounds[epoch].closeTimestamp,
            "Can only end round after closeTimestamp"
        );
        Round storage round = rounds[epoch];
        round.isEnded = true;
        for (uint16 i = 0; i < winCards.length; i++) {
            roundWinCards[currentEpoch][winCards[i]] = true;
        }
        emit EndedRound(epoch, winCards);
    }

    /**
     * @notice get results in specific round
     * epoch > round id
     */
    function getResultInRound(uint256 epoch) external view returns(uint256[] memory) {
        return results[epoch];
    }

    /**
     * @notice place bingo card from user with cardId
     */
    function placeBingoCard(uint256 cardId) external {
        require(cardId <= cardAmount, "This card is not exits");
    }

    function claimedReward(uint256 epoch) external {
        
    }

    function _safeClaimed(uint256 epoch) view internal {
        require(epoch <= currentEpoch, "Round this not started yet");
        BetInfo[] memory userBets = ledgers[epoch][msg.sender];
        Round memory round = rounds[epoch];
        require(block.timestamp > round.closeTimestamp && round.closeTimestamp != 0, "Round this not end or not start yet");
        require(userBets.length > 0, "User not has bet in this round");

        uint256 rewards = 0;
        for (uint16 i = 0;i<userBets.length;i++) {
            BetInfo memory bet = userBets[i];
            uint256 _cardPrice = cardPrice[bet.cardId];
            if (roundWinCards[epoch][bet.cardId]) {
                rewards += _cardPrice;
            }
        }

        require(rewards > 0, "No wins in this round");

        /// safe transfer
    }

    /**
     * @notice Playing game : Random result number
     */
    function randomResultInEpoch() external {
        uint256 epoch = currentEpoch;
        require(
            block.timestamp >= rounds[epoch].lockTimestamp && block.timestamp <= rounds[epoch].closeTimestamp, 
            "Not in random number time"
        );
        uint256 randomNo = randomWithoutRepeating(results[epoch]);
        results[epoch].push(randomNo);
        emit NewRandomNumber(epoch, randomNo);
    }

    /**
     * @notice Recursive random.
     */
    function randomWithoutRepeating(uint256[] memory arr) internal returns (uint256) {
        uint256 randomNo = _random();
        for (uint i = 0;i<arr.length;i++) {
            if (arr[i] == randomNo) {
                return randomWithoutRepeating(arr);
            }
        }
        return randomNo;
    }

    function _random() internal view returns(uint256) {
        uint random = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty,  
        msg.sender))) % 51;
        return random;
    }
}