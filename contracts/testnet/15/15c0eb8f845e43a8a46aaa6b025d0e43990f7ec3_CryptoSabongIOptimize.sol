/**
 *Submitted for verification at BscScan.com on 2022-03-23
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



contract CryptoSabongIOptimize is Ownable {
   using SafeMath for uint96;
 
   event EtherTransfer(address beneficiary, uint256 amount);
   /* Boolean to verify if betting period is active */
   bool public bettingActive = false;
   address[] public players;
   uint96 public fee = 9400;
   uint96 public minimumBet = 2000000000000000000;
   uint96 public totalBetsOne;
   uint96 public totalBetsTwo;
   uint96 bets;
   uint96[] _tokens;
   IERC20 public tokenAdd;
   IERC20 token;

   //for claim
   mapping (address => uint96) public _pendingBalance;
   event ClaimRewards(address user, uint96 tokens);

   enum PlayerStatus {Not_Joined, Joined, Ended}
   enum State {Not_Created, Created, Joined, Finished}
   struct Game {
    uint96 betId;  
    State state;
    
    }
    uint96 public gameId = 0;
    mapping(uint256 => Game) public gameInfo;
    event BetPlayer(address indexed _from, uint96 _amount, uint96 player);
    mapping (address => bool) public Agent;
   
   struct Player {
      uint96 amountBet;
      uint96 teamSelected;
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
      for(uint96 j = 0; j < players.length; j++){
         if(players[j] == player) return true;
      }
      return false;
    }/* Function to enable betting */
    function beginBettingPeriod()  public onlyAgent returns(bool) {
        bettingActive = true;
        return true;
    }

    function checkGameIdFinish(uint96 numGame) public constant returns(bool){
        Game storage game = gameInfo[numGame];
        for(uint256 j = 0; j < gameId; j++){
            if(game.state == State.Finished) return true;
        }
      return false;
    }

     function newGame(uint96 numGame) external  onlyAgent {
        
        for (uint96 n = 0; n < numGame; n++){
        gameInfo[gameId] = Game(gameId, State.Created);
        gameId++;
     }
    }

    function setNewTokenAddress(IERC20 newTokenAddress)public onlyOwner{
            token = IERC20(newTokenAddress);

    }
    

    function bet(uint96 _gameId, uint96 _teamSelected, uint96 amount) public  {
            require(bettingActive);
            Game storage game = gameInfo[_gameId];
            require(game.state == State.Created,"Game has not been created");
            require( playerInfo[msg.sender].teamSelected == _teamSelected || 
            playerInfo[msg.sender].teamSelected == 0, "Only 1 team to Bet");
            require(amount >= minimumBet);

            
            if(playerInfo[msg.sender].amountBet > 0){
                token.transferFrom(msg.sender,address(this),amount);

                playerInfo[msg.sender].amountBet += amount;
                playerInfo[msg.sender].teamSelected = _teamSelected;
                if ( _teamSelected == 1){
                    totalBetsOne += amount;
                }
                else if(_teamSelected == 2){
                    totalBetsTwo += amount;
                }
            }
            else{
                token.transferFrom(msg.sender,address(this),amount);

                playerInfo[msg.sender].amountBet += amount;
                playerInfo[msg.sender].teamSelected = _teamSelected;
                
                 if ( _teamSelected == 1){
                totalBetsOne += amount;
                players.push(msg.sender);
                }
                else if(_teamSelected == 2){
                    totalBetsTwo += amount;
                    players.push(msg.sender);
                }
            }

        uint96 updatedBalance = playerInfo[msg.sender].amountBet;

        playerInfo[msg.sender]._state = PlayerStatus.Joined;
        emit BetPlayer(msg.sender, updatedBalance, _teamSelected);
        }
    // Generates a number between 1 and 10 that will be the winner
    function allocatePrizes(uint96 _gameId, uint96 teamWinner) public onlyAgent {
        Game storage game = gameInfo[_gameId];
        require(bettingActive == false);
        require(teamWinner == 1 ||teamWinner == 2||teamWinner == 3);
        address[] memory winners = players;
        address[] memory playersAdd = players;
        //We have to create a temporary in memory array with fixed size
        //Let's choose 1000
       
        address add;
        uint96 rewards = 0;
        uint96 count = 0;
        uint96 totalBets = 0;
        uint96 ads = 0;
        uint96 i = 0;
        
        //We loop through the player array to check who selected the winner team
        for(i = 0; i < playersAdd.length; i++){
            address playerAddress = playersAdd[i];
            //If the player selected the winner team
            //We add his address to the winners array
            if(playerInfo[playerAddress].teamSelected == teamWinner){
                winners[count] = playerAddress;
                count++;
            }
            playerInfo[playerAddress]._state = PlayerStatus.Not_Joined;
        }


        if ( teamWinner == 1){
           totalBets = totalBetsOne + totalBetsTwo;
           ads =  (totalBets * fee) / totalBetsOne;

        for(i = 0; i < count; i++){

             add = winners[i];
             bets = playerInfo[add].amountBet;


            rewards = (bets * ads) / 10000;
            _pendingBalance[add] += rewards;
        
            }
        }
        else if(teamWinner == 2){
            totalBets = totalBetsOne + totalBetsTwo;
            ads =  (totalBets * fee) / totalBetsTwo;
        //We loop through the array of winners, to give ethers to the winners
        for( i = 0; i < count; i++){

            // Check that the address in this fixed array is not empty
             add = winners[i];
             bets = playerInfo[add].amountBet;

            rewards = (bets * ads) / 10000;
            _pendingBalance[add] += rewards;
        }        
    }
        for(i=0; i < playersAdd.length; i++){
            add = playersAdd[i];
                delete playerInfo[add].amountBet;
                delete playerInfo[add].teamSelected;
                delete playerInfo[add];
        }  
        gameInfo[_gameId] = Game(_gameId, State.Finished);
        game.state == State.Finished;
        players.length = 0; // Delete all the players array
        totalBets = 0;
        totalBetsOne = 0;
        totalBetsTwo = 0; 
        bettingActive = true;
    }

    function drawFight(uint96 _gameId) public onlyAgent{
        Game storage game = gameInfo[_gameId];
        require(bettingActive == false);
        address[] memory draw = new address[](players.length);

        uint96 num = 0;
        uint96 i = 0;
        uint96 rewards = 0;
        for( i = 0; i < players.length; i++){
            address addD = players[i];

            if(playerInfo[addD].teamSelected == 1||playerInfo[addD].teamSelected == 2){
                draw[num] = addD;
                num++;
            }
        }
         for( i = 0; i < num; i++){
            // Check that the address in this fixed array is not empty
             addD = draw[i];
             bets = playerInfo[addD].amountBet;
            
            rewards = bets;
            _pendingBalance[addD] += rewards;

            }
        for(i=0; i < players.length; i++){
            address addR = players[i];
                delete playerInfo[addR].amountBet;
                delete playerInfo[addR].teamSelected;
                delete playerInfo[addR];
        }  
        gameInfo[_gameId] = Game(_gameId, State.Finished);
        game.state == State.Finished;
        players.length = 0; // Delete all the players array
        totalBetsOne = 0;
        totalBetsTwo = 0; 
        bettingActive = true;
    }

    function balanceOf(address user) public constant returns (uint96) {
    uint96 levs = _pendingBalance[user];
    return levs;
    }

    function claimRewards()  public {
    uint96 balance = balanceOf(msg.sender);
    require(balance > 0);
    _pendingBalance[msg.sender] = 0;
    token.transfer(msg.sender, balance);
    emit ClaimRewards(msg.sender, balance);
  }

     function reset(uint96 _gameId)public onlyAgent{
        Game storage game = gameInfo[_gameId];
        for(uint96 i=0; i < players.length; i++){
            address adds = players[i];
            if(players[i] != address(0)){
                delete playerInfo[adds].amountBet;
                delete playerInfo[adds].teamSelected;
                delete playerInfo[adds];
            }
        }  
        gameInfo[_gameId] = Game(_gameId, State.Finished);
        game.state == State.Finished;
        players.length = 0; // Delete all the players array
        totalBetsOne = 0;
        totalBetsTwo = 0; 
        bettingActive = true;
    }

     function withdrawEther(address beneficiary) public onlyOwner {
        beneficiary.transfer(address(this).balance);
    }
    function withdrawTokens(IERC20 tknAdd, address beneficiary) public onlyOwner {
        require(IERC20(tknAdd).transfer(beneficiary, IERC20(tknAdd).balanceOf(this)));
    }
    /* Function to close voting and handle payout. Can only be called by the owner. */
    function closeBetting() public onlyAgent returns (bool) {
        // Close the betting period
        bettingActive = false;
        return true;
    }
    function setFee(uint96 newFee) public onlyOwner() {
    fee = newFee;
  }
  function setMinBet(uint96 newMinBet) public onlyOwner() {
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