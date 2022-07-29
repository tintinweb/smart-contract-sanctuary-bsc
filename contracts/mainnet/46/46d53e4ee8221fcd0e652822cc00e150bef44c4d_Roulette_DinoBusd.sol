/**
 *Submitted for verification at BscScan.com on 2022-07-28
*/

// SPDX-License-Identifier:IGNORE SPDX WARNINGS
pragma solidity ^0.8.15;


interface IERC20  
{

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);


}

contract Roulette_DinoBusd {
  
  uint betAmount;
  uint necessaryBalance;
  uint nextRoundTimestamp;
  address creator;
  uint256 maxAmountAllowedInTheBank;
  
  uint8[] payouts;
  uint8[] numberRange;
  IERC20 private BusdInterface;
  address public tokenAdress;
  uint256 public ref_fee = 4;
  //uint256 public dev_fee = 4;
  address public miner = 0xb9150107F2820930D997a91f03Ba81A8d625F337;
  address public dev = 0x857Bf8867a41441653134500D6c6457Ee3cc1934;
  uint256 private max_amount = 2000000000000000000000;

  struct winning {
    address userAddr;
    uint256 winingAmount;
  }

  mapping(address => winning) public winnings;

  
  /*
    BetTypes are as follow:
      0: color
      1: column
      2: dozen
      3: eighteen
      4: modulus
      5: number
      
    Depending on the BetType, number will be:
      color: 0 for black, 1 for red
      column: 0 for left, 1 for middle, 2 for right
      dozen: 0 for first, 1 for second, 2 for third
      eighteen: 0 for low, 1 for high
      modulus: 0 for even, 1 for odd
      number: number
  */
  
  struct Bet {
    address player;
    uint8 betType;
    uint8 number;
  }
  Bet[] public bets;
  mapping(address => Bet[]) foo;
  constructor()  {
    creator = msg.sender;
    necessaryBalance = 0;
    nextRoundTimestamp = block.timestamp;
    payouts = [2,3,3,2,2,10];
    numberRange = [1,2,2,1,1,36];
    betAmount = 1000000000000000000; /* 1 BUSD */
    maxAmountAllowedInTheBank = 5000000000000000000; /* 2 BUSD */
    tokenAdress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; //  busd token. 
    BusdInterface = IERC20(tokenAdress);
  }

  event RandomNumber(uint256 number);
  
  function getStatus(address addr) public view returns(uint, uint, uint, uint, uint) {
    return (
      foo[addr].length,             // number of active bets
      foo[addr].length * betAmount, // value of active bets
      nextRoundTimestamp,      // when can we play again
      BusdInterface.balanceOf(address(this)),   // roulette balance
      winnings[addr].winingAmount     // winnings of player
    ); 
  }
    
  function Liquidity(uint256 _amount) public {
    require(msg.sender == creator);
     BusdInterface.transferFrom(msg.sender,address(this),_amount);
   }

   function SendContract() internal {
     uint256 balance = BusdInterface.balanceOf(address(this));
     require(balance >= max_amount);
     uint256 _amount = balance - max_amount;
     BusdInterface.transfer(miner,_amount);
   }

  function bet(address _ref , uint256 _amount, uint8 number, uint8 betType) public {

    require(_amount == betAmount);                               // 1
    require(betType >= 0 && betType <= 5);                         // 2
    require(number >= 0 && number <= numberRange[betType]);        // 3

    uint256 reffee = _amount/100 * ref_fee;
    //uint256 devfee = _amount/100 * dev_fee;

    uint256 totalfee = reffee ;
    uint256 totalamountnow = _amount - totalfee;  
    BusdInterface.transferFrom(msg.sender,_ref,reffee); // ref fee goes to ref 
   // BusdInterface.transferFrom(msg.sender,dev,devfee); // dev fees goes to dev
    BusdInterface.transferFrom(msg.sender,address(this),totalamountnow); // the amount goes to the contract.

    uint payoutForThisBet = payouts[betType] * _amount;
    uint provisionalBalance = necessaryBalance + payoutForThisBet;
    require(provisionalBalance < BusdInterface.balanceOf(address(this)));  
    necessaryBalance += payoutForThisBet;
    foo[msg.sender].push(Bet({
      player: msg.sender,
      betType: betType,
      number: number
    }));


  }


  function spinWheel() public  returns(uint) {
    /* are there any bets? */
    require(foo[msg.sender].length > 0);
    /* are we allowed to spin the wheel? */
    require(block.timestamp > nextRoundTimestamp);
    /* next time we are allowed to spin the wheel again */
     uint number = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, blockhash(block.number-1)))) % 37;
  
   
   
    /* check every bet for this number */
    for (uint256 i = 0; i < foo[msg.sender].length; i++) {
      bool won = false;
      Bet memory b =foo[msg.sender][i];
      if (number == 0) {
        won = (b.betType == 5 && b.number == 0);                   /* bet on 0 */
      } else {
        if (b.betType == 5) { 
          won = (b.number == number);                              /* bet on number */
        } else if (b.betType == 4) {
     
          if (b.number == 0) won = (number % 2 == 0);              /* bet on even */
   
          if (b.number == 1) won = (number % 2 == 1);              /* bet on odd */
    
        } else if (b.betType == 3) {            
          if (b.number == 0) won = (number <= 18);                 /* bet on low 18s */
          if (b.number == 1) won = (number >= 19);                 /* bet on high 18s */
        } else if (b.betType == 2) {                               
          if (b.number == 0) won = (number <= 12);                 /* bet on 1st dozen */
          if (b.number == 1) won = (number > 12 && number <= 24);  /* bet on 2nd dozen */
          if (b.number == 2) won = (number > 24);                  /* bet on 3rd dozen */
        } else if (b.betType == 1) {               
          if (b.number == 0) won = (number % 3 == 1);              /* bet on left column */
          if (b.number == 1) won = (number % 3 == 2);              /* bet on middle column */
          if (b.number == 2) won = (number % 3 == 0);              /* bet on right column */
        } else if (b.betType == 0) {
          if (b.number == 0) {                                     /* bet on black */
            if (number <= 10 || (number >= 20 && number <= 28)) {
              won = (number % 2 == 0);
            } else {
              won = (number % 2 == 1);
            }
          } else {                                                 /* bet on red */
            if (number <= 10 || (number >= 20 && number <= 28)) {
              won = (number % 2 == 1);
            } else {
              won = (number % 2 == 0);
            }
          }
        }
      }

      /* if winning bet, add to player winnings balance */
      if (won) {
        uint256 currentAmount = winnings[msg.sender].winingAmount;
        uint256 NowWon = betAmount * payouts[b.betType];
        uint256 totalWon = currentAmount + NowWon;
        winnings[msg.sender] = winning(msg.sender,totalWon);
      }
    }
    /* delete all bets */
    delete foo[msg.sender];
    /* reset necessaryBalance */
     necessaryBalance = 0;
 
    /* returns 'random' number to UI */
    emit RandomNumber(number);
 return (number);
  }



  
  function cashOut() public  {
    address player = msg.sender;
    uint256 amount = winnings[player].winingAmount;
    require(amount > 0);
    require(amount <= BusdInterface.balanceOf(address(this)));
    winnings[msg.sender] = winning(msg.sender,0);
    uint256 minerfee = amount/100 * 30;
    amount = amount-minerfee;

    BusdInterface.transfer(player,amount);
    BusdInterface.transfer(miner,minerfee);
    SendContract();
  }
  
}