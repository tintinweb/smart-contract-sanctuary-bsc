/**
 *Submitted for verification at BscScan.com on 2022-04-05
*/

pragma solidity ^0.4.2;
/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
    constructor() public {
        owner = msg.sender;
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}
/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
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
     * Emits a `Transfer` event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through `transferFrom`. This is
     * zero by default.
     *
     * This value changes when `approve` or `transferFrom` are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * > Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an `Approval` event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to `approve`. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        require(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        //   require(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        //   require(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
}



contract NewCryptoSabong is Ownable {
   using SafeMath for uint96;
 
   enum State {Not_Created, Created, Joined, Finished}

   struct Game {
    uint96 betId;  
    State state;
    
    }
    
   enum PlayerStatus {Not_Joined, Joined, Ended}

   struct Player {
    uint96 amountBet;
    uint teamSelected;
    PlayerStatus _state;

    }

   mapping (address => uint96) public _pendingBalance;
   mapping(address => Player) public playerInfo;
   mapping(uint96 => Game) public gameInfo;
   mapping(address => bool) public Agent;


   event ClaimRewards(address user, uint96 tokens);
   event BetPlayer(address indexed _from, uint96 _amount, uint player);
   event EtherTransfer(address beneficiary, uint256 amount);

   bool public bettingActive = false;
   bool winnerSet;
   address[] public players;
   uint256 public fee = 9400;
   uint96 public minimumBet = 2000000000000000000;
   uint96 public totalBetsOne;
   uint96 public totalBetsTwo;
   uint256 bets;
   uint96 public gameId = 0;
   uint result = 0;
   uint96 tracker = 0;
   IERC20 public tokenAdd;
   IERC20 token;

    //new condition
    uint256 public currentRound;
    bool public genesisStartOnce = false;
    bool public genesisLockOnce = false;

    mapping(uint256 => mapping(address => BetInfo)) public ledger;
    mapping(uint256 => Round) public rounds;
    mapping(address => uint256[]) public userRounds;

    enum Position {
        Red,
        White
    }

    struct Round {
        uint gameResult;
        uint256 idGame;
        uint256 totalAmountBet;
        uint256 redAmount;
        uint256 whiteAmount;
        uint256 rewardAmount;
        bool gameStatus;
    }

    struct BetInfo {
        Position position;
        uint256 amount;
        bool claimed; // default false
    }

    event BetWhite(address indexed sender, uint256 indexed epoch, uint256 amount);
    event BetRed(address indexed sender, uint256 indexed epoch, uint256 amount);
    event Claim(address indexed sender, uint256 indexed epoch, uint256 amount);

    event StartRound(uint256 indexed epoch);

    event RewardsCalculated(
        uint256 indexed epoch,
        uint256 rewardAmount
    );

    constructor (IERC20 tkn) public {
       tokenAdd = tkn;
       token =  IERC20(tkn);
   }
   function() public payable {}

    function betWhite(uint256 epoch, uint256 amount) public  {
        require(epoch == currentRound, "Bet is too early/late");
        require(_bettable(epoch), "Round not bettable");
        require(amount >= minimumBet, "Bet amount must be greater than minBetAmount");
        require(ledger[epoch][msg.sender].amount == 0, "Can only bet once per round");

        // Update round data
        token.transferFrom(msg.sender, address(this), amount);
        Round storage round = rounds[epoch];
        round.totalAmountBet = round.totalAmountBet + amount;
        round.whiteAmount = round.whiteAmount + amount;

        // Update user data
        BetInfo storage betInfo = ledger[epoch][msg.sender];
        betInfo.position = Position.White;
        betInfo.amount = amount;
        userRounds[msg.sender].push(epoch);

        emit BetWhite(msg.sender, epoch, amount);
    }

    function betRed(uint256 epoch, uint256 amount) public  {
        require(epoch == currentRound, "Bet is too early/late");
        require(_bettable(epoch), "Round not bettable");
        require(amount >= minimumBet, "Bet amount must be greater than minBetAmount");
        require(ledger[epoch][msg.sender].amount == 0, "Can only bet once per round");

        // Update round data
        token.transferFrom(msg.sender, address(this), amount);
        Round storage round = rounds[epoch];
        round.totalAmountBet = round.totalAmountBet + amount;
        round.redAmount = round.redAmount + amount;

        // Update user data
        BetInfo storage betInfo = ledger[epoch][msg.sender];
        betInfo.position = Position.Red;
        betInfo.amount = amount;
        userRounds[msg.sender].push(epoch);

        emit BetRed(msg.sender, epoch, amount);
    }

    function _bettable(uint256 epoch) internal view returns (bool) {
        return
            rounds[epoch].gameStatus == true;
    }

    function _setBettableStatus(uint256 epoch, bool _status) external onlyAgent{
       rounds[epoch].gameStatus = _status;
    }

    function _notBettable(uint256 epoch) internal view returns (bool) {
        return
            rounds[epoch].gameStatus == false;
    }


    function executeRound(uint _gameResult) external onlyAgent {
        // require(
        //     genesisStartOnce,
        //     "Can only run after genesisStartRoun is triggered"
        // );
       
        require(_notBettable(currentRound), "Round bettable");
         Round memory round = rounds[currentRound];
        _calculateRewards(currentRound, _gameResult);
        round.gameResult == _gameResult;

        // Increment currentEpoch to current round (n)
        currentRound = currentRound + 1;
        
    }


     function _calculateRewards(uint256 epoch, uint _gameResult) internal {
        require(rounds[epoch].rewardAmount == 0, "Rewards calculated");
        Round storage round = rounds[epoch];
        uint256 rewardAmount;
        uint256 totalBets = 0;
        uint256 ads = 0;


        // Bull wins
        if (_gameResult == 1) {
    
           totalBets = round.totalAmountBet;
           ads =  (totalBets * fee) / round.redAmount;
           rewardAmount = ads;
        }
        // Bear wins
        else if (_gameResult == 2) {

           totalBets = round.totalAmountBet;
           ads =  (totalBets * fee) / round.whiteAmount;
           rewardAmount = ads;
        }

        emit RewardsCalculated(epoch, rewardAmount);
    }


    function claim(uint256[] epochs) external{
        uint256 reward; // Initializes reward

        for (uint256 i = 0; i < epochs.length; i++) {
            require(rounds[epochs[i]].gameStatus == false, "Round has not started");

            uint256 addedReward = 0;
            Round memory round = rounds[epochs[i]];
           // Round valid, claim rewards
            if (rounds[epochs[i]].gameResult == 1) {
                require(claimable(epochs[i], msg.sender), "Not eligible for claim");
                addedReward = (ledger[epochs[i]][msg.sender].amount * round.rewardAmount) / 10000;
            }
            else if(rounds[epochs[i]].gameResult == 2){
                require(claimable(epochs[i], msg.sender), "Not eligible for claim");
                addedReward = (ledger[epochs[i]][msg.sender].amount * round.rewardAmount) / 10000;
            }
            // Round invalid, refund bet amount
            else {
                require(refundable(epochs[i], msg.sender), "Not eligible for refund");
                addedReward = (ledger[epochs[i]][msg.sender].amount * round.rewardAmount) / 10000;
            }

            ledger[epochs[i]][msg.sender].claimed = true;
            reward += addedReward;

            emit Claim(msg.sender, epochs[i], addedReward);
        }

        if (reward > 0) {
            token.transfer(address(msg.sender), reward);
        }
    }

     function claimable(uint256 epoch, address user) public view returns (bool) {
        BetInfo memory betInfo = ledger[epoch][user];
        Round memory round = rounds[epoch];

        return
            round.gameStatus &&
            betInfo.amount != 0 &&
            !betInfo.claimed &&
            ((betInfo.position == Position.Red) ||
                ( betInfo.position == Position.White));
    }


    function refundable(uint256 epoch, address user) public view returns (bool) {
        BetInfo memory betInfo = ledger[epoch][user];
        Round memory round = rounds[epoch];
        return
            !round.gameStatus &&
            !betInfo.claimed &&
            betInfo.amount != 0;
    }


    
    function getUserRoundsLength(address user) external view returns (uint256) {
        return userRounds[user].length;
    }


    function setNewTokenAddress(IERC20 newTokenAddress)public onlyOwner{
            token = IERC20(newTokenAddress);

    }
    

    function balanceOf(address user) public constant returns (uint96) {
        uint96 levs = _pendingBalance[user];
        return levs;
    }

    

    function withdrawEther(address beneficiary) public onlyOwner {
        beneficiary.transfer(address(this).balance);
    }
    function withdrawTokens(IERC20 tknAdd, address beneficiary) public onlyOwner {
        require(IERC20(tknAdd).transfer(beneficiary, IERC20(tknAdd).balanceOf(this)));
    }
    
    function setFee(uint96 newFee) public onlyOwner() {
    fee = newFee;
  }
  function setMinBet(uint96 newMinBet) public onlyOwner() {
    minimumBet = newMinBet;
  }


     // Allow this agent to call the airdrop functions
    function setNewAgent(address _agentAddress, bool state) public onlyOwner {
        Agent[_agentAddress] = state;
    }

    modifier onlyAgent() {
        require(Agent[msg.sender]);
         _;
        
    }
    
}