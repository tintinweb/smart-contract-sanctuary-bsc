/**
 *Submitted for verification at BscScan.com on 2022-08-06
*/

pragma solidity 0.4.25;

contract TronspotRoulette {
  
  uint betAmount;
  uint necessaryBalance;
  uint nextRoundTimestamp;
  address creator;
  uint256 maxAmountAllowedInTheBank;
  mapping (address => uint256) winnings;
  uint8[] payouts;  
  uint8[] numberRange;
  address public roiContract;
  
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
    // uint8 [] numArray;
    uint256 betAmt;
  }
  Bet[] public bets;
  
  constructor(address roiContractAddress) public  {
    creator = msg.sender;
    necessaryBalance = 0;
    nextRoundTimestamp = now;
    payouts = [2,3,3,2,2,36];
    numberRange = [1,2,2,1,1,36];
    betAmount = 10000000; /* 10 TRX */
    maxAmountAllowedInTheBank = 200000000000; /* 200000 TRX */
    roiContract = roiContractAddress;
  }

  event RandomNumber(uint256 number);
  event BetResultWin(address bidder,uint _betType,uint _betNumber,uint256 number,bool result,uint _betAmount,uint winAmount);
//   event BetResultLose(address bidder,uint _betType,uint _betNumber,uint256 number);
  
  function getStatus() public view returns(uint, uint, uint, uint, uint) {
    return (
      bets.length,             // number of active bets
      bets.length * betAmount, // value of active bets
      nextRoundTimestamp,      // when can we play again
      address(this).balance,   // roulette balance
      winnings[msg.sender]     // winnings of player
    ); 
  }
    

  function bet(uint8 number, uint8 betType ) payable public {
    /* 
       A bet is valid when:
       1 - the value of the bet is correct (=betAmount)
       2 - betType is known (between 0 and 5)
       3 - the option betted is valid (don't bet on 37!)
       4 - the bank has sufficient funds to pay the bet
    */
    require(msg.value >= betAmount, "Invalid bet amount");                               // 1
    require(betType >= 0 && betType <= 5, "Invalid bet type");                         // 2
    require(number >= 0 && number <= numberRange[betType], "Invalid bet number range");        // 3
    uint payoutForThisBet = payouts[betType] * msg.value;
    // uint provisionalBalance = necessaryBalance + payoutForThisBet;
    // require(provisionalBalance < address(this).balance, "Invalid contract balance");           // 4
    /* we are good to go */
    necessaryBalance += payoutForThisBet;
    
    bets.push(Bet({
      betType: betType,
      player: msg.sender,
      number: number,
      betAmt:msg.value
    //   numArray:_numArray
    }));
    
    //  Bet memory llb;
    //  llb.betType=betType;
    //  llb.player=msg.sender;
    //  llb.number=number;
    
    spinWheel();
    
  }

  function spinWheel() public {
    /* are there any bets? */
    require(bets.length > 0 , "Invalid bets Length");
    /* are we allowed to spin the wheel? */
    require(now > nextRoundTimestamp, "Invalid Time");
    /* next time we are allowed to spin the wheel again */
    nextRoundTimestamp = now;
    /* calculate 'random' number */
    uint diff = block.difficulty;
    bytes32 hash = blockhash(block.number-1);
    Bet memory lb = bets[bets.length-1];
    uint number = uint(keccak256(abi.encodePacked(now, diff, hash, lb.betType, lb.player, lb.number))) % 37;
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
                uint256  _amount= (b.betAmt * payouts[b.betType]);
                require(address(this).balance >= _amount ,"Low contract balance");
                uint256 roiAmount;
                uint256 transferWinningAmount;
                roiAmount=(_amount * 5/100);
                transferWinningAmount=(_amount - roiAmount);
                roiContract.transfer(roiAmount);
                msg.sender.transfer(transferWinningAmount);
                winnings[b.player] += b.betAmt * payouts[b.betType];
               
               emit BetResultWin(b.player,b.betType,b.number,number,true,b.betAmt,_amount);
               
      }
      else{
          emit BetResultWin(b.player,b.betType,b.number,number,false,b.betAmt,b.betAmt * payouts[b.betType]);
      }
    }
    /* delete all bets */
    bets.length = 0;
    /* reset necessaryBalance */
    necessaryBalance = 0;
    /* check if to much money in the bank */
    /* returns 'random' number to UI */
    emit RandomNumber(number);
  }
  

  
 
      function profits(uint256 withdraw) public {
      require(msg.sender == creator,"Invalid address");
      uint profitAmount = address(this).balance;
      require(withdraw <= profitAmount,"Invalid amount");
          creator.transfer(withdraw);
  }
 
}