/**
 *Submitted for verification at BscScan.com on 2022-07-27
*/

// SPDX-License-Identifier: UNLICENCED
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// File: @openzeppelin/contracts/interfaces/IERC20.sol


// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;


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


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

interface FGCasino {
    function gameToken() external view returns (address token);
    function maxBetAllowed() external view returns (uint256);
    function potAmount() external view returns (uint256);
    function stateCallMain() external view returns ( uint256 _maxBetAllowed, uint256 _quickBetAmount, uint256 _payOutDivisor);
    
    function sendIsWinnerGame(uint256 amount, uint256 multiplier, address _user) external returns (uint256 payOut);
    function sendIsWinnerPrePaidGame(uint256 amount, uint256 multiplier, address _user) external  returns (uint256 winnings);
    function sendFeesGame(uint256 amount) external;
}

pragma solidity ^0.8.7;

contract GamesCollection2 is Ownable {

    address public gameToken;
    address public mainCasino;
    FGCasino casino;
    
    constructor(address _mainCasino, address _gameToken) {
        mainCasino = _mainCasino;
        casino = FGCasino(mainCasino);
        gameToken = _gameToken;
        
    }

    bool public isPaused = false;
    modifier pausable() {
        require(!isPaused, "games are paused");
        _;
    }
    function pauseGames(bool _isPaused) external onlyOwner {
        isPaused = _isPaused;
    }

    function rng(uint256 mod) internal view returns(uint256 value) {
        uint256 seed = block.timestamp + block.difficulty + block.gaslimit * gasleft() + block.number; 
        value = uint256(keccak256(abi.encodePacked(seed))) % mod;
    }

    function checkReqs(uint256 _betAmount) internal view {
        require(_betAmount <= casino.maxBetAllowed(), "your bet is above the limit");
        require(IERC20(gameToken).balanceOf(msg.sender) >= _betAmount, "Insufficient balance");
        require(IERC20(gameToken).allowance(msg.sender, address(this)) >= _betAmount,"please approve contract on GameToken");
    }

     function stateCallMain() external view returns ( uint256 _maxBetAllowed, uint256 _quickBetAmount, uint256 _payOutDivisor) {
        (_maxBetAllowed, _quickBetAmount, _payOutDivisor) = casino.stateCallMain();
    }

    function potAmount() external view returns (uint256) {
        return casino.potAmount();
    }

    // Multiplier calls below
    uint256 highRoller6M = 100;
    uint256 highRoller12M = 150;
    uint256 highRoller20M = 200;

    function getMultipliers() external view returns (uint256 _highRoller6M, uint256 _highRoller12M, uint256 _highRoller20M) {
        return (highRoller6M, highRoller12M, highRoller20M);
    }

    function changeMultipliers(uint256 _highRoller6M, uint256 _highRoller12M, uint256 _highRoller20M) external onlyOwner {
        highRoller6M = _highRoller6M;
        highRoller12M = _highRoller12M;
        highRoller20M = _highRoller20M;
    }

    // high roller

    struct HighRoller {
        uint256 houseDice1;
        uint256 houseDice2;
        uint256 playerDice1;
        uint256 playerDice2;
        uint256 currentBet;
        uint256 diceChoice;
        bool gameStarted;  
    }

    mapping(address => uint256) usersRound;
    mapping(address => mapping(uint256 => HighRoller)) highRollerByRound;

    event highRollerGame( uint256 houseDice1, uint256 houseDice2, uint256 playerDice1, uint256 playerDice2, uint256 amount, uint256 diceChoice, bool isWinner , bool isLoser);

    function highRollerInfo(address _user) external view returns (
        uint256 houseDice1,
        uint256 houseDice2,
        uint256 playerDice1,
        uint256 playerDice2,
        uint256 currentBet,
        uint256 diceChoice,
        bool gameStarted
    ) { 
        uint256 round = usersRound[_user];
        HighRoller storage user = highRollerByRound[_user][round];
        return (user.houseDice1, user.houseDice2, user.playerDice1, user.playerDice2, user.currentBet, user.diceChoice, user.gameStarted);
        }

    function startHR(uint256 _betAmount, uint256 diceChoice) external {
        require(diceChoice == 6 || diceChoice == 12 || diceChoice == 20, "not a dice size available");
        uint256 round = usersRound[msg.sender];
        HighRoller storage user = highRollerByRound[msg.sender][round];
        require(!user.gameStarted, "Must finish last Game");
        
        checkReqs(user.currentBet);

        user.diceChoice = diceChoice;
        user.houseDice1 = rng(user.diceChoice);
        user.houseDice2 = rng(user.diceChoice);
        user.currentBet = _betAmount;
        user.gameStarted = true;
       
        IERC20(gameToken).transferFrom(msg.sender, mainCasino, _betAmount);

        emit highRollerGame( user.houseDice1, user.houseDice2, user.playerDice1, user.playerDice2, user.currentBet, user.diceChoice,  false, false);
    }

    function PlayerRoll(bool Double) external {
        uint256 round = usersRound[msg.sender];
        HighRoller storage user = highRollerByRound[msg.sender][round];
        require(user.gameStarted, "Game Not Started");
        bool isWinner = false;
        bool isLoser = false;
        uint256 amount;

        user.playerDice1 = rng(user.diceChoice);
        user.playerDice2 = rng(user.diceChoice);
        Double ? amount = user.currentBet*2 : amount = user.currentBet;

        if(user.playerDice1 + user.playerDice2 > user.houseDice1 + user.houseDice2){
            isWinner = true;
            amount = casino.sendIsWinnerPrePaidGame(amount, user.diceChoice, msg.sender);
        } else {
            isLoser = true;
            IERC20(gameToken).transferFrom(msg.sender, mainCasino, user.currentBet);
            casino.sendFeesGame(amount);
        }

        emit highRollerGame( user.houseDice1, user.houseDice2, user.playerDice1, user.playerDice2, amount, user.diceChoice, isWinner, isLoser);

        usersRound[msg.sender] += 1;

    }
 
}