/**
 *Submitted for verification at BscScan.com on 2022-07-14
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

// File: allGames-New.sol





pragma solidity ^0.8.7;

contract FGCasino is Ownable {

    address public gameToken = 0xd51237A6F3219d186f0C8d8Dd957b1Bcb3Ce5d48;
    address public lotteryAddress = 0xDF7ca526F053a661684a6FE41d53aC758351e051;
    
    uint256 public amountToSendAt = 100000000000000000000; // currently 100
    uint256 public feesCollected = 0;
    uint256 public quickBetAmount = 10000000000000000000;   // currently 10
    uint256 public FeeDivisor = 10;
    uint256 public payOutDivisor = 90;
    uint256 public maxBetDivisor = 10;
    // coinFlip event
    event results(address player, bool win, uint256 amount, bool isHeads);
    event cutTheDeckResults(address player, uint256 houseCard, uint256 houseSuit, uint256 playerCard, uint256 playerSuit, uint256 result, uint256 amount);
    event diceCallResults(address player, uint256 houseRoll, uint256 playerChoice, uint256 diceSize, bool isWinner, uint256 amount);
    
    uint256 coinFlipM = 100;
    uint256 deckCutM = 100;
    uint256 diceCall6M = 200;
    uint256 diceCall12M = 300;
    uint256 diceCall20M = 400;
    uint256 highCardStart = 25;
    uint256 blackJackM = 100;


    function stateCallMain() external view returns (
        uint256 _maxBetAllowed,
        uint256 _quickBetAmount,
        uint256 _payOutDivisor
    ) {return (maxBetAllowed(), quickBetAmount, payOutDivisor);}

    function multipliers() external view returns (
        uint256 _coinFlipM,
        uint256 _deckCutM,
        uint256 _diceCall6M,
        uint256 _diceCall12M,
        uint256 _diceCall20M,
        uint256 _highCardStart,
        uint256 _blackJackM
    ) {
        return (coinFlipM, deckCutM, diceCall6M, diceCall12M, diceCall20M, highCardStart, blackJackM );
    }

    function setGameToken(address _token) external onlyOwner {
        gameToken = _token;
    }

    function setGameMultipliers(
    uint256 _coinFlipM,
    uint256 _deckCutM,
    uint256 _diceCall6M,
    uint256 _diceCall12M,
    uint256 _diceCall20M,
    uint256 _highCardStart,
    uint256 _blackJackM
    ) external onlyOwner {
    coinFlipM = _coinFlipM;
     deckCutM = _deckCutM;
     diceCall6M = _diceCall6M;
     diceCall12M = _diceCall12M;
     diceCall20M = _diceCall20M;
     highCardStart = _highCardStart;
     blackJackM = _blackJackM;
    }

     // Subscription
    modifier onlyGames() {
      require(isGame[msg.sender], "you are not a game contract for FG");
      _;
    }

    mapping(address => bool) public isGame;

    function setNewGame(address newGame, bool isActive) external onlyOwner {
      require(!isGame[newGame], "game already added");
      isGame[newGame] = isActive;
    }

    bool public isPaused = false;
    modifier pausable() {
        require(!isPaused, "games are paused");
        _;
    }
    function pauseGames(bool _isPaused) external onlyOwner {
        isPaused = _isPaused;
    }
    


    function setAmountToSendAt(uint256 amount) external onlyOwner {
        amountToSendAt = amount;
    }

    function setMaxBetDivisor(uint256 amount) external onlyOwner {
        maxBetDivisor = amount;
    }

    function setPayOutDivisor(uint256 newPayOutDivisor) external onlyOwner {
        require(newPayOutDivisor >= 50 && newPayOutDivisor <= 200, "must be between 50 and 200 %");
        payOutDivisor = newPayOutDivisor;
    }
    
    function setFeeDivisor(uint256 newDivisor) external onlyOwner {
        require(newDivisor <= 100,"must be between 0 and 100 %");
        FeeDivisor = newDivisor;
    }

    function setQuickBetAmount(uint256 amount) external onlyOwner {
        require(amount <= maxBetAllowed() /  4, "would be more than maxBetAllowed divided by 4");
        quickBetAmount = amount;
    }

    function setLotteryAddress(address newLottery) external onlyOwner{
        lotteryAddress = newLottery;
    }

    // betting functions

    function potAmount() external view returns (uint256) {
        return IERC20(gameToken).balanceOf(address(this)) - feesCollected;
    }

    function maxBetAllowed() public view returns (uint256){
        return ( IERC20(gameToken).balanceOf(address(this)) - feesCollected ) / maxBetDivisor;
    }

    function rng(uint256 mod) internal view returns(uint256 value) {
        uint256 seed = block.timestamp + block.difficulty + block.gaslimit * gasleft() + block.number; 
        value = uint256(keccak256(abi.encodePacked(seed))) % mod;
    }

   function sendIsWinner(uint256 amount, uint256 multiplier) internal returns (uint256 payOut) {
        payOut = (amount * payOutDivisor / 100) * multiplier / 100;
        IERC20(gameToken).transfer(msg.sender, payOut);
    }
    
    function sendIsWinnerGame(uint256 amount, uint256 multiplier, address _user) public onlyGames returns (uint256 payOut) {
        payOut = (amount * payOutDivisor / 100) * multiplier / 100;
        IERC20(gameToken).transfer(_user, payOut);
    }
    
    function sendIsWinnerPrePaid(uint256 amount, uint256 multiplier) internal returns (uint256 winnings) {
        winnings = ((amount * payOutDivisor / 100) * multiplier / 100) + amount;
        IERC20(gameToken).transfer(msg.sender, winnings);
    }
    
    function sendIsWinnerPrePaidGame(uint256 amount, uint256 multiplier, address _user) public onlyGames returns (uint256 winnings) {
        winnings = ((amount * payOutDivisor / 100) * multiplier / 100) + amount;
        IERC20(gameToken).transfer(_user, winnings);
    }

    function sendIsLoser(uint256 _betAmount) internal returns(uint256 value) {
        value = _betAmount;
        IERC20(gameToken).transferFrom(msg.sender, address(this), _betAmount);
        if(FeeDivisor > 0) sendFees(_betAmount);
    }

    function setFees(uint256 amount) internal {
        uint256 amountToLottery = amount * FeeDivisor / 100;
        feesCollected += amountToLottery;        
        if(feesCollected >= amountToSendAt) {
            IERC20(gameToken).transfer(lotteryAddress, feesCollected);
            feesCollected = 0;
        } 
    }
    
    function sendFees(uint256 amount) public onlyGames {
        uint256 amountToLottery = amount * FeeDivisor / 100;
        feesCollected += amountToLottery;        
        if(feesCollected >= amountToSendAt) {
            IERC20(gameToken).transfer(lotteryAddress, feesCollected);
            feesCollected = 0;
        } 
    }

    function checkReqs(uint256 _betAmount) internal view {
        require(_betAmount <= maxBetAllowed(), "your bet is above the limit");
        require(IERC20(gameToken).balanceOf(msg.sender) >= _betAmount, "Insufficient balance");
        require(IERC20(gameToken).allowance(msg.sender, address(this)) >= _betAmount,"please approve contract on GameToken");
    }

  // to receive Eth From Router when Swapping
    receive() external payable {}

  function withdrawBNB() external onlyOwner {
    require(payable(msg.sender).send(address(this).balance));
  }

  function withdrawlToken(address _tokenAddress) external onlyOwner {
    uint256 _tokenAmount = IERC20(_tokenAddress).balanceOf(address(this));
    IERC20(_tokenAddress).transfer(address(msg.sender), _tokenAmount);
    feesCollected = 0;
  }

// coin flip games Below

    function quickBetHeads() external pausable returns (bool isHeads, bool isWinner){
        (isHeads, isWinner) = flipTheCoin(quickBetAmount, true);
        
    }

    function BetHeads(uint256 amount) external pausable  returns (bool isHeads, bool isWinner){
        (isHeads, isWinner) = flipTheCoin(amount, true);
    }

    function quickBetTails() external pausable returns (bool isHeads, bool isWinner){
        (isHeads, isWinner) = flipTheCoin(quickBetAmount, false);
    }

    function BetTails(uint256 amount) external pausable returns (bool isHeads, bool isWinner){
        (isHeads, isWinner) = flipTheCoin(amount, false);
    }

    function flipTheCoin(uint256 _betAmount, bool chooseHeads) internal pausable returns (bool resultIsHeads, bool isWinner) {
        checkReqs(_betAmount);
        uint256 result = rng(2);
        result == 0 ? resultIsHeads = true : resultIsHeads = false;
        chooseHeads == resultIsHeads ? isWinner = true : isWinner = false;

        uint256 amount;

        if(isWinner) amount = sendIsWinner(_betAmount, coinFlipM);
        if(!isWinner) amount = sendIsLoser(_betAmount);

        emit results(msg.sender, isWinner, amount, resultIsHeads);
    }

    function drawACard(bool[] memory cards) internal view returns ( uint256 number, uint256 suit,  bool[] memory newCards) {
        uint256 card;
        newCards = cards;
        do {
            suit = rng(4);
            number = rng(13);
            card = (suit * 13) + number;
        } while (cards[card]);
        newCards[card] = true;
    }


// Cut the Deck game below

    function cutTheDeckQuick() external pausable returns (uint256 houseCard, uint256 houseSuit, uint256 playerCard, uint256 playerSuit, uint256 result) {
     (houseCard, houseSuit, playerCard, playerSuit, result) = cutTheDeck(quickBetAmount);
    }

    function cutTheDeck(uint256 _betAmount) public pausable returns (uint256 houseCard, uint256 houseSuit, uint256 playerCard, uint256 playerSuit, uint256 result) {
        checkReqs(_betAmount);
        
        bool[] memory cards = new bool[](52); 

        (playerCard, playerSuit, cards) = drawACard(cards);
        (houseCard, houseSuit,) = drawACard(cards);

        if(playerCard > houseCard) result = 0;  // win
        if(playerCard < houseCard) result = 1;  // loss
        if(playerCard == houseCard) result = 2; // tie

        uint256 amount;
        if(result == 0) amount = sendIsWinner(_betAmount, deckCutM);
        if(result == 1) amount = sendIsLoser(_betAmount);
        if(result == 2) amount = 0;

        emit cutTheDeckResults(msg.sender, houseCard, houseSuit, playerCard, playerSuit, result, amount);
        
    }

// Dice Roll

    function diceCall( uint256 _betAmount, uint256 choice, uint256 diceChoice) public pausable  returns (uint256 houseRoll, uint256 playerChoice, uint256 diceSize, bool isWinner) {
        require(diceChoice == 6 || diceChoice == 12 || diceChoice == 20, "not a dice size available");
        require(choice > 0 && choice <= diceChoice, " must be within specs");
        checkReqs(_betAmount);
        
        uint256 multiplier = diceCall6M;
        if(diceChoice == 120) multiplier = diceCall12M;
        if(diceChoice == 200) multiplier = diceCall20M;

        playerChoice = choice;
        diceSize = diceChoice;

        isWinner = false;

        houseRoll = rng(diceChoice) +1;

        if(houseRoll == choice) isWinner = true;

        uint256 amount;

       if(isWinner) amount = sendIsWinner(_betAmount, multiplier);
       if(!isWinner) amount = sendIsLoser(_betAmount);

        emit diceCallResults(msg.sender, houseRoll, playerChoice, diceSize ,isWinner, amount);
    }


    // High card / or color or suit???
    struct HighCard {
        uint256 currentCardSuit;
        uint256 currentCardNumber;
        bool[] cards;
        uint256 currentBet;
        uint256 multiplier;
        uint256 winnings;
        bool gameStarted;
    }

    mapping(address => HighCard) public highCard;

    function resetHighCard() internal {
        HighCard storage user = highCard[msg.sender];
            bool[] memory cards = new bool[](52);
            user.cards = cards;
            user.multiplier = highCardStart;
            user.winnings = 0;
            user.currentBet = 0;
            user.gameStarted = false;
    }

    event HighCardFirst(address player, uint256 suit, uint256 number, uint256 bet);
    event HighCardTakeMoney(address player, uint256 amount);
    event HighCardGuess(address player, uint256 LastCardSuit, uint256 LastCardNumber, uint256 newCardSuit, uint256 newCardNumber, bool isWinner, uint256 winnings, bool isJackpot, uint256 currentBet);

    function startHighCard(uint256 _betAmount) public pausable  returns (uint256 currentCardSuit, uint256 currentCardNumber) {
        HighCard storage user = highCard[msg.sender];
        require(!user.gameStarted, "Must finish last Game");
        
        checkReqs(user.currentBet);
        resetHighCard();
  
        user.currentBet = _betAmount;
        user.gameStarted = true;
        IERC20(gameToken).transferFrom(msg.sender, address(this), _betAmount);
        // draw first card
        (user.currentCardNumber, user.currentCardSuit, user.cards) = drawACard(user.cards);
       
        emit HighCardFirst(msg.sender, user.currentCardSuit,user.currentCardNumber, _betAmount);
        return (user.currentCardSuit,user.currentCardNumber);
    }
        
    
    function highCardGuess(bool guessHigh) external pausable  returns (bool resultHigh, uint256 LastCardSuit, uint256 LastCardNumber, uint256 newCardSuit, uint256 newCardNumber, bool isWinner, bool isJackpot, uint256 winnings ) {
        HighCard storage user = highCard[msg.sender];
        require(user.gameStarted, "StartNewGame to play again");
                
        LastCardSuit = user.currentCardSuit;
        LastCardNumber = user.currentCardNumber;
        uint256 currentBet = user.currentBet;

        (user.currentCardNumber, user.currentCardSuit, user.cards) = drawACard(user.cards);

        if(user.currentCardNumber > LastCardNumber) resultHigh = true;

        if(guessHigh == resultHigh) {
            user.multiplier = user.multiplier * 2;
            user.winnings = ( (user.currentBet * user.multiplier) / 100 ) + user.currentBet;
            winnings = user.winnings;
            isWinner = true;
            if(user.multiplier >= 1000) {
                isJackpot = true;
                highCardTakeMoney();
            }
        } else resetHighCard();
         
        emit HighCardGuess( msg.sender, LastCardSuit,  LastCardNumber,  user.currentCardSuit,  user.currentCardNumber,  isWinner, winnings, isJackpot, currentBet);
               
        return ( resultHigh, LastCardSuit,  LastCardNumber,  user.currentCardSuit, user.currentCardNumber, isWinner, isJackpot, winnings);
    }

    function highCardTakeMoney() public pausable returns( uint256 amount) {
        HighCard storage user = highCard[msg.sender];
        require(user.gameStarted, "not in a game");
                
        amount = sendIsWinnerPrePaid(user.currentBet, user.multiplier);
        
        resetHighCard();
        emit HighCardTakeMoney(msg.sender, amount);
    }

    // BLACKJACK 21

    struct BlackJack {
        uint256[] playerCardsSuit;
        uint256[] playerCardsNumber;
        uint256[] houseCardsSuit;
        uint256[] houseCardsNumber;
        uint256 currentBet;
        uint256 total;
        uint256 Dtotal;
        bool gameStarted;
        bool[] cards;
        
    }
    
    mapping(address => BlackJack) blackJack;
    
    function blackJackUser(address _user) external view returns (
        uint256[] memory _playerSuits,
        uint256[] memory _playerNumbers,
        uint256[] memory _houseSuits,
        uint256[] memory _houseNumbers,
        uint256 _currentBet,
        uint256 _total,
        uint256 _Dtotal,
        bool _gameStarted
    ) {
        BlackJack storage user = blackJack[_user];
         _playerSuits = new uint256[](user.playerCardsSuit.length);
        _playerSuits = user.playerCardsSuit;
         _playerNumbers = new uint256[](user.playerCardsSuit.length);
        _playerNumbers = user.playerCardsNumber;
         _houseSuits = new uint256[](user.houseCardsSuit.length);
        _houseSuits = user.houseCardsSuit;
         _houseNumbers = new uint256[](user.playerCardsSuit.length);
         _houseNumbers = user.houseCardsNumber;
         _currentBet = user.currentBet;
         _total = user.total;
         _Dtotal = user.Dtotal;
         _gameStarted = user.gameStarted;
    }   

    event BlackJackGame(address player, uint256[] playersSuits ,uint256[] playersNumbers, uint256[] Dsuit, uint256[] Dnumber, uint256 betAmount, uint256 total, uint256 Dtotal, bool bust, bool isWinner);

    function resetBlackJack() internal {
        BlackJack storage user = blackJack[msg.sender];
            bool[] memory cards = new bool[](52);
            user.cards = cards;
            delete user.playerCardsSuit;
            delete user.playerCardsNumber;
            delete user.houseCardsNumber;
            delete user.houseCardsSuit;
    }

    function checkIfBust(uint256[] memory numbers) public pure returns (bool bust, uint256 total) {
        total = 0;
        uint256 aces = 0;
        // calculate without aces -- do aces last;
        for(uint i=0; i<numbers.length; i++) {
            uint256 value;
            if(numbers[i] > 0 && numbers[i] < 9) value = numbers[i] + 1;
            // if jack of higher
            if(numbers[i] >= 9) value = 10;
            // how many aces?
            if(numbers[i] == 0){
                aces += 1;
                value = 0;
            }
            total += value;
        }
        // can we use an ace?
        if(aces > 0) {
            uint256 check = total;
            for(uint j=0; j<aces; j++) {
                uint256 value;
                if(check + 11 <= 21) value = 11;
                else value = 1;
                check += value;
            }
            if(check <= 21) total = check;
            else total += aces;
        }

        if(total > 21) bust = true;
        return (bust, total);
    }
        
    function startBlackJack(uint256 _betAmount) external pausable {
        BlackJack storage user = blackJack[msg.sender];
        require(!user.gameStarted, "Must finish last Game");
        
        // checkReqs(user.currentBet);
        resetBlackJack();
  
        user.currentBet = _betAmount;
        user.gameStarted = true;
        // IERC20(gameToken).transferFrom(msg.sender, address(this), _betAmount);
        uint256 suit;
        uint256 number;

        for(uint i=0; i<2; i++) {
            (number, suit, user.cards) = drawACard(user.cards);
            user.playerCardsSuit.push(suit);
            user.playerCardsNumber.push(number);
        }
        (bool bust, uint256 total) = checkIfBust(user.playerCardsNumber);
        user.total = total;

        (number, suit, user.cards) = drawACard(user.cards);
        user.houseCardsSuit.push(suit);
        user.houseCardsNumber.push(number);
        
        (, uint256 dtotal) = checkIfBust(user.houseCardsNumber);
       user.Dtotal = dtotal;
        if(bust) user.gameStarted = false;
        
        emit BlackJackGame(msg.sender, user.playerCardsSuit ,user.playerCardsNumber, user.houseCardsSuit, user.houseCardsNumber, _betAmount, user.total, user.Dtotal, bust, false);
    }

    function blackJackHitMe() external pausable  {
       BlackJack storage user = blackJack[msg.sender];
        require(user.gameStarted, "StartNewGame to play again");

        uint256 suit;
        uint256 number;
        (number, suit, user.cards) = drawACard(user.cards);
        user.playerCardsSuit.push(suit);
        user.playerCardsNumber.push(number);

         (bool bust, uint256 total) = checkIfBust(user.playerCardsNumber);
         user.total = total;
        if(bust) user.gameStarted = false;
        

        emit BlackJackGame(msg.sender, user.playerCardsSuit ,user.playerCardsNumber, user.houseCardsSuit, user.houseCardsNumber, user.currentBet, user.total, user.Dtotal, bust, false);

    }

    function blackJackHold() external pausable  {
        BlackJack storage user = blackJack[msg.sender];
        require(user.gameStarted, "StartNewGame to play again");

        uint256 total = 0;
        bool isWinner = false;
        uint256 amount = 0;

        uint256 suit;
        uint256 number;

        do {
            (number, suit, user.cards) = drawACard(user.cards);
            user.houseCardsSuit.push(suit);
            user.houseCardsNumber.push(number);
            (, total) = checkIfBust(user.houseCardsNumber);
        } while (total < 17 && total < user.total);

        if(total > 21 || user.total > total){
            isWinner = true;
            // amount = sendIsWinnerPrePaid(user.currentBet, blackJackM, msg.sender);
        }
        user.gameStarted = false;
               
         emit BlackJackGame(msg.sender, user.playerCardsSuit ,user.playerCardsNumber, user.houseCardsSuit, user.houseCardsNumber, amount, user.total, total, false, isWinner);
        
    }
}