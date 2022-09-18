// SPDX-License-Identifier: MIT

pragma solidity >=0.4.22 <0.9.0;
import "./gamblerse.sol";


contract GamblerseDao {
  using SafeMath for uint256;
  address [] public BeterAddresses;
  address private owner;
  GAMBLERSE public GamblerseAddress;
  uint public WithrdrawTaxRate;
  uint public TotalBetAmount ;
  uint public AmountCollectedByTax;
  bool public IsBetActive;
  struct Account {
    bool exists;
    string TeamName;
    uint BetAmount;
    uint WonAmount;
  }
   mapping(address => Account) public accounts;
constructor(GAMBLERSE _GamblerseAddress) {
    owner = msg.sender;
      WithrdrawTaxRate = 5;
      GamblerseAddress = _GamblerseAddress;
   TotalBetAmount =0;
   AmountCollectedByTax = 0;
  }
  function ActivateOrDeactivateBet(uint check) public returns(bool){
    require(msg.sender == owner, "You must be the owner to run this.");
    if(check==1){
      IsBetActive = true;
    }
    else {
      IsBetActive = false;
    }

    return true;
  }
  function Bet(address _address, string memory team ,uint _betAmount) public returns(bool) {
    require(_address != address(0), "Address can not be null");
    require(msg.sender == _address,"Only user can bet");
    require(_betAmount>0 ,"Bet must be greater then 0");
    require(!accounts[_address].exists , "You have already bet or you have not claimed your won amount");
    require(IsBetActive,"Bet is not active");
    Account memory account;
    uint bet = _betAmount;
    
    
    account = Account(true, team, bet,0);
    BeterAddresses.push(_address);
    accounts[_address] = account;
    TotalBetAmount += bet;
    GamblerseAddress.transferFrom(_address,address(this),bet);
    return(true);

  }
  
   function FindWiningBets(string memory team) internal view returns(uint){
      uint i;
    uint accLength= BeterAddresses.length;
    uint WinBet;
    for(i = 0; i <= accLength-1; i++){
      address a = BeterAddresses[i];
      Account memory acc = accounts[a];
      if(keccak256(abi.encodePacked((acc.TeamName))) == keccak256(abi.encodePacked((team))) ){
       WinBet += acc.BetAmount;
      }
     
    }
   return WinBet;
  }
  function CalculateWinAmount(uint distAmount,uint betAmount, uint b) internal pure returns(uint){
     uint perWon = betAmount.mul(100*10**18).div(b);
     return perWon.mul(distAmount).div(100*10**18);
  }
  function CheckWins(string calldata team) public  returns(bool){
     require(msg.sender == owner, "You must be the owner to run this.");
    AmountCollectedByTax += TotalBetAmount.mul(WithrdrawTaxRate*10**18).div(100*10**18);
    uint AmountToBeDistributed = TotalBetAmount.sub(TotalBetAmount.mul(WithrdrawTaxRate*10**18).div(100*10**18));
    uint i;
    uint accLength= BeterAddresses.length;
    uint bet = FindWiningBets(team);
    for(i = 0; i <= accLength-1; i++){
      address a = BeterAddresses[i];
      Account memory acc = accounts[a];
      if(keccak256(abi.encodePacked((acc.TeamName))) == keccak256(abi.encodePacked((team))) ){
       acc.WonAmount = CalculateWinAmount(AmountToBeDistributed,acc.BetAmount,bet);
       accounts[a]= acc;
      }
      else {
         delete accounts[a];
      }
    }
    delete BeterAddresses;
    TotalBetAmount = 0;
    return(true);
  }
  function WithdrawWonAmount(address _address) public returns(bool){
    require(_address != address(0), "Address can not be null");
    require(msg.sender == _address,"Only user can withdraw");
    require(accounts[_address].WonAmount >= 0,"You have not won anything yet");
    Account memory acc = accounts[_address];

    GamblerseAddress.transfer(_address,acc.WonAmount);
    
    delete accounts[_address];
    return true;

  }
  function WithdrawTaxCollected() public returns(bool){
    require(msg.sender == owner, "You must be the owner to run this.");
    GamblerseAddress.transfer(owner,AmountCollectedByTax);
    AmountCollectedByTax =0;
    return true;

  }
  function ChangeTax(uint NewTax) public returns(bool){
    require(msg.sender == owner, "You must be the owner to run this.");
    WithrdrawTaxRate = NewTax;
    return true;
  }
}