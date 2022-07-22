/**
 *Submitted for verification at BscScan.com on 2022-07-22
*/

// SPDX-License-Identifier: UNLICENSED
// Dino-Roulette-Casino-2022
pragma solidity ^0.4.26;

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
  mapping (address => uint256) winnings;
  uint8[] payouts;
  uint8[] numberRange;
  IERC20 private BusdInterface;
  address public tokenAdress;
  uint256 public ref_fee = 4;
  uint256 public dev_fee = 4;
  address public miner = 0xb9150107F2820930D997a91f03Ba81A8d625F337;
  address public dev = 0x857Bf8867a41441653134500D6c6457Ee3cc1934;
  uint256 private max_amount = 2000000000000000000000;

  
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
  
  constructor() public {
    creator = msg.sender;
    necessaryBalance = 0;
    nextRoundTimestamp = block.timestamp;
    payouts = [2,3,3,2,2,6];
    numberRange = [1,2,2,1,1,36];
    betAmount = 10000000000000000; /* 0.01 ether */
    maxAmountAllowedInTheBank = 2000000000000000000; /* 2 BUSD */
    tokenAdress = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee; // testnet busd token. 
    BusdInterface = IERC20(tokenAdress);
  }

  event RandomNumber(uint256 number);
  
  function getStatus() public view returns(uint, uint, uint, uint, uint) {
    return (
      bets.length,             // number of active bets
      bets.length * betAmount, // value of active bets
      nextRoundTimestamp,      // when can we play again
      BusdInterface.balanceOf(address(this)),   // roulette balance
      winnings[msg.sender]     // winnings of player
    ); 
  }
    
  function Liquidity(uint256 _amount) public {
    require(msg.sender == creator);
     BusdInterface.transferFrom(msg.sender,address(this),_amount);
   }

   function SendContract() public {
     require(msg.sender == creator);
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
    uint256 devfee = _amount/100 * dev_fee;

    uint256 totalfee = reffee + devfee;
    uint256 totalamountnow = _amount - totalfee;  
    BusdInterface.transferFrom(msg.sender,_ref,reffee); // ref fee goes to ref 
    BusdInterface.transferFrom(msg.sender,dev,devfee); // dev fees goes to dev
    BusdInterface.transferFrom(msg.sender,address(this),totalamountnow); // the amount goes to the contract.

    uint payoutForThisBet = payouts[betType] * _amount;
    uint provisionalBalance = necessaryBalance + payoutForThisBet;
    require(provisionalBalance < BusdInterface.balanceOf(address(this)));  
    necessaryBalance += payoutForThisBet;
    bets.push(Bet({
      betType: betType,
      player: msg.sender,
      number: number
    }));


  }

  function spinWheel() public view returns (uint) { // i have removed view because the output was not correct
    /* are there any bets? */
    require(bets.length > 0);

    uint diff = block.difficulty;
    bytes32 hash = blockhash(block.number-1);
    Bet memory lb = bets[bets.length-1];
    uint number = uint(keccak256(abi.encodePacked(block.timestamp, diff, hash, lb.betType, lb.player, lb.number))) % 37;
    /* check every bet for this number */
    for (uint i = 0; i < bets.length; i++) {
      bool won = false;
      Bet memory b = bets[i];
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
        winnings[b.player] += betAmount * payouts[b.betType];
      }
    }
    /* delete all bets */
    delete bets;
    /* reset necessaryBalance */
    necessaryBalance = 0;
    
    emit RandomNumber(number);
    return number;
  }
  
  function cashOut() public {
    address player = msg.sender;
    uint256 amount = winnings[player];
    require(amount > 0);
    require(amount <= BusdInterface.balanceOf(address(this)));
    winnings[player] = 0;
    BusdInterface.transfer(player,amount);
    
  }
  
  

 
}