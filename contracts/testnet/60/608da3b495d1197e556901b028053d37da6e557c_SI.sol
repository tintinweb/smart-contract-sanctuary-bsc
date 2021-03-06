/**
 *Submitted for verification at BscScan.com on 2022-02-16
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

interface Token {
   function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract SI is Ownable {
   using SafeMath for uint256;
 
   event EtherTransfer(address beneficiary, uint amount);
   /* Boolean to verify if betting period is active */
   bool public bettingActive = false;
   address[] public players;
   address add;
   uint256 public fee = 55;
   uint256 public minimumBet = 1000000000000000000;
   uint256 public totalBetsOne;
   uint256 public totalBetsTwo;
   uint256 public totalBets;
   uint256 bets;
   uint256 num;
   uint256 count;
   uint256 i = 0;
   uint256[] _tokens;
   uint256 rewards = 0;
   IERC20 public tokenAdd;
   IERC20 token;

   //for claim
   mapping (address => uint256) public _pendingBalance;
   event ClaimRewards(address user, uint tokens);

   enum PlayerStatus {Not_Joined, Joined, Ended}
   enum State {Not_Created, Created, Joined, Finished}
   struct Game {
    uint betId;  
    State state;
    
    }
    uint256 public gameId = 0;
    mapping(uint => Game) public gameInfo;
    event BetPlayer(address indexed _from, uint256 _amount, uint player);
    mapping (address => bool) public Agent;
   
   struct Player {
      uint256 amountBet;
      uint16 teamSelected;
       PlayerStatus _state;

    }
// The address of the player and => the user info
   mapping(address => Player) public playerInfo;

   constructor (IERC20 tkn) public {
       tokenAdd = tkn;
       token =  IERC20(tkn);
   }
   function() public payable {}
   
    function checkPlayerExists(address player) public constant returns(bool){
      for(uint256 j = 0; j < players.length; j++){
         if(players[j] == player) return true;
      }
      return false;
    }/* Function to enable betting */
    function beginBettingPeriod()  public onlyAgent returns(bool) {
        bettingActive = true;
        return true;
    }

    function checkGameIdFinish(uint256 numGame) public constant returns(bool){
        Game storage game = gameInfo[numGame];
        for(uint256 j = 0; j < gameId; j++){
            if(game.state == State.Finished) return true;
        }
      return false;
    }

     function newGame(uint256 numGame) external  onlyAgent {
        
        for (uint256 n = 0; n < numGame; n++){
        gameInfo[gameId] = Game(gameId, State.Created);
        gameId++;
     }
    }

    function setNewTokenAddress(IERC20 newTokenAddress)public onlyOwner{
            token = IERC20(newTokenAddress);

    }
    

    
    function bet(uint _gameId, uint8 _teamSelected, uint256 amount) public  {
            require(bettingActive);
            Game storage game = gameInfo[_gameId];
            require(game.state == State.Created,"Game has not been created");
            require(playerInfo[msg.sender]._state == PlayerStatus.Not_Joined,
            "You have already placed a bet");
            //The first require is used to check if the player already exist
            require(!checkPlayerExists(msg.sender));
            //The second one is used to see if the value sended by the player is
            //Higher than the minimum value
            require(amount >= minimumBet);
    
            //To roll in the Token, this line of code is executed on the condition that the user has approved a contract to use his Token
            //IERC20 is Token
            token.transferFrom(msg.sender,address(this),amount);
    
            //We set the player informations : amount of the bet and selected team
            playerInfo[msg.sender].amountBet = amount;
            playerInfo[msg.sender].teamSelected = _teamSelected;
    
            //then we add the address of the player to the players array
            players.push(msg.sender);
    
            //at the end, we increment the stakes of the team selected with the player bet
            if ( _teamSelected == 1){
                totalBetsOne += amount;
            }
            else if(_teamSelected == 2){
                totalBetsTwo += amount;
            }

        playerInfo[msg.sender]._state = PlayerStatus.Joined;
        emit BetPlayer(msg.sender, amount, _teamSelected);

        }
    // Generates a number between 1 and 10 that will be the winner
    function allocatePrizes(uint _gameId, uint16 teamWinner) public onlyAgent {
        Game storage game = gameInfo[_gameId];
        require(bettingActive == false);
        address[] memory winners = new address[](20000);
        address[] memory draw = new address[](20000);
        //We have to create a temporary in memory array with fixed size
        //Let's choose 1000
       
        totalBets = 0;
        count = 0;
        
        //We loop through the player array to check who selected the winner team
        for( i = 0; i < players.length; i++){
            address playerAddress = players[i];
            //If the player selected the winner team
            //We add his address to the winners array
            if(playerInfo[playerAddress].teamSelected == teamWinner){
                winners[count] = playerAddress;
                count++;
            }
            playerInfo[playerAddress]._state = PlayerStatus.Not_Joined;
        }


        //We define which bet sum is the Loser one and which one is the winner
        if ( teamWinner == 1){
            totalBets = totalBetsOne + totalBetsTwo;
        //We loop through the array of winners, to give ethers to the winners
        for(i = 0; i < count; i++){
            // Check that the address in this fixed array is not empty
            if(winners[i] != address(0)){
             add = winners[i];
             bets = playerInfo[add].amountBet;

            // token.transfer(winners[j],  (bets*(10000+(LoserBet*fee /WinnerBet)))/10000 );
             rewards = (bets*(1000-fee *(totalBets / totalBetsOne))) / 1000;
            _pendingBalance[add] += rewards;
            }
           
        }
        for(i=0; i < players.length; i++){
            add = players[i];
            if(players[i] != address(0)){
                delete playerInfo[add].amountBet;
                delete playerInfo[add].teamSelected;
                delete playerInfo[add];
            }
        }  
        bettingActive = true;
        gameInfo[_gameId] = Game(_gameId, State.Finished);
        game.state == State.Finished;
        players.length = 0; // Delete all the players array
        totalBets = 0;
        totalBetsOne = 0;
        totalBetsTwo = 0;  
        }
        else if(teamWinner == 2){
            totalBets = totalBetsOne + totalBetsTwo;  
        //We loop through the array of winners, to give ethers to the winners
        for( i = 0; i < count; i++){

            // Check that the address in this fixed array is not empty
            if(winners[i] != address(0)){
             add = winners[i];
             bets = playerInfo[add].amountBet;

            // token.transfer(winners[k],  (bets*(10000+(LoserBet*fee /WinnerBet)))/10000 );
            rewards = (bets*(1000-fee *(totalBets / totalBetsTwo))) / 1000; 
            _pendingBalance[add] += rewards;
            }
        }
    
        for(i=0; i < players.length; i++){
            add = players[i];
            if(players[i] != address(0)){
                delete playerInfo[add].amountBet;
                delete playerInfo[add].teamSelected;
                delete playerInfo[add];
            }
        }
        bettingActive = true;
        gameInfo[_gameId] = Game(_gameId, State.Finished);
        game.state == State.Finished;
        players.length = 0; // Delete all the players array
        totalBets = 0;
        totalBetsOne = 0;
        totalBetsTwo = 0;                
        }
        else if(teamWinner == 3){
            totalBets = totalBetsOne + totalBetsTwo;
            //We loop through the player array to check who selected the winner team
        num = 0;
        for( i = 0; i < players.length; i++){
            add = players[i];

            if(playerInfo[add].teamSelected == 1||playerInfo[add].teamSelected == 2){
                draw[num] = add;
                num++;
            }
        }
        //We loop through the array of winners, to give ethers to the winners
        for( i = 0; i < num; i++){
            // Check that the address in this fixed array is not empty
            if(draw[i] != address(0)){
             add = draw[i];
             bets = playerInfo[add].amountBet;

            // token.transfer(draw[m], (bets*(fee))/10000 );
            
            rewards = (bets*(1000-fee))/1000;
            _pendingBalance[add] += rewards;
        }
        bettingActive = true;
        gameInfo[_gameId] = Game(_gameId, State.Finished);
        game.state == State.Finished;
        delete playerInfo[add];
        delete playerInfo[add].amountBet;
        delete playerInfo[add].teamSelected;
        playerInfo[add]._state = PlayerStatus.Not_Joined;
        players.length = 0; // Delete all the players array
        totalBetsOne = 0;
        totalBetsTwo = 0;
        totalBets = 0;
        }
       
    }
       
    }

    function balanceOf(address user) public constant returns (uint256) {
    uint256 levs = _pendingBalance[user];
    return levs;
    }

    function claimRewards()  public {
    uint256 balance = balanceOf(msg.sender);
    require(balance > 0);
    _pendingBalance[msg.sender] = 0;
    token.transfer(msg.sender, balance);
    emit ClaimRewards(msg.sender, balance);
  }

    function reset(uint256 _gameId)public onlyAgent{
        Game storage game = gameInfo[_gameId];
        uint256 o;
        address playerAddress = players[o];
        gameInfo[_gameId] = Game(_gameId, State.Finished);
        game.state == State.Finished;
        playerInfo[playerAddress]._state = PlayerStatus.Not_Joined;
        delete playerInfo[playerAddress]; // Delete all the players
        players.length = 0; // Delete all the players array
        totalBetsOne = 0;
        totalBetsTwo = 0;
        bettingActive = true;
    }

     function withdrawEther(address beneficiary) public onlyOwner {
        beneficiary.transfer(address(this).balance);
    }
    function withdrawTokens(IERC20 tknAdd, address beneficiary) public onlyOwner {
        require(Token(tknAdd).transfer(beneficiary, Token(tknAdd).balanceOf(this)));
    }
    /* Function to close voting and handle payout. Can only be called by the owner. */
    function closeBetting() public onlyAgent returns (bool) {
        // Close the betting period
        bettingActive = false;
        return true;
    }
    function setFee(uint256 newFee) public onlyOwner() {
    fee = newFee;
  }
  function setMinBet(uint256 newMinBet) public onlyOwner() {
    minimumBet = newMinBet;
  }

    function AmountOne() public view returns(uint256){
       return totalBetsOne;
    }

    function AmountTwo() public view returns(uint256){
       return totalBetsTwo;
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