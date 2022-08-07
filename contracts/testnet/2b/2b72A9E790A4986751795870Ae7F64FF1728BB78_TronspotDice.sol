/**
 *Submitted for verification at BscScan.com on 2022-08-06
*/

pragma solidity 0.4.25;


contract TronspotDice {
    
     address owner;
     address public roiContract;
  
    
    constructor(address roiContractAddress) public{
        owner=msg.sender;
        roiContract = roiContractAddress;
    }
     using SafeMath for uint256;
       
     struct Bet{
      uint256[]  currentBet;
      bool      isBetSet; //default value is false 
      uint256   destiny; // 
      uint256   amount;
     }
     
     
     mapping(address=>mapping(uint256 => Bet)) public bets;
     uint256 public globalcounter=1;
     uint256 betWinStat;
     uint256 betCounter;
     uint256 MIN_BET_AMOUNT=10000000; // 10 TRX
     uint256 [6] diceElement = [1, 2, 3, 4, 5, 6];
     uint256 betNum=1;
     uint256 totalBets=0;
     uint256 BASE_PERCENT=593;
     uint256 maxAmountAllowedInTheBank=2000000000;
     uint256 maxNumber=6;
     
      

     event NewBetIsSet(address bidder , uint256 [] currentBet);
     event GameResult(address bidder, uint256 currentBetplace1,uint256 currentBetplace2,uint256 currentBetplace3,uint256 currentBetplace4,uint256 currentBetplace5 ,uint256 betAmount,uint256 winAmount, uint256 destiny,bool result);
   
     
     function setNewbet(uint256 [] _bet)  public returns( uint256 []){
             require(bets[msg.sender][totalBets].isBetSet == false);
              bets[msg.sender][totalBets].currentBet=new uint256[](5);
              bets[msg.sender][totalBets].isBetSet = true;
              bets[msg.sender][totalBets].currentBet = _bet;
              betNum++;
              emit NewBetIsSet(msg.sender, bets[msg.sender][totalBets].currentBet);
              return bets[msg.sender][totalBets].currentBet;
      }
      
      
      function roll(uint256 [] _bet) payable public{
          require(msg.value >= MIN_BET_AMOUNT);
              setNewbet(_bet);
              require(bets[msg.sender][totalBets].currentBet.length  >= 1 && bets[msg.sender][totalBets].currentBet.length <=5, "Invalid bet");
              require(bets[msg.sender][totalBets].isBetSet == true);
              bets[msg.sender][totalBets].destiny = getRandomNumber(1,6);
              bets[msg.sender][totalBets].isBetSet = false;
              uint256 _amount=0;
              uint256 _betAmount=msg.value;
              if(betWinStatfun(msg.sender)){
                    _amount=(BASE_PERCENT.mul(msg.value).div(100).div(bets[msg.sender][totalBets].currentBet.length));
               for(uint256 i=bets[msg.sender][totalBets].currentBet.length; i<=5; i++){
                       bets[msg.sender][totalBets].currentBet.push(0);
                   } 
                      if(_amount > 0){
                require( address(this).balance >= _amount ,"Low contract balance");
                roiAmount=0;transferWinningAmount=0;
                uint256 roiAmount;
                uint256 transferWinningAmount;
                roiAmount=(_amount.mul(5).div(100));
                transferWinningAmount=_amount.sub(roiAmount);
                roiContract.transfer(roiAmount);
                msg.sender.transfer(transferWinningAmount);
                         
                emit GameResult(msg.sender,
              bets[msg.sender][totalBets].currentBet[0],
              bets[msg.sender][totalBets].currentBet[1],
              bets[msg.sender][totalBets].currentBet[2],
              bets[msg.sender][totalBets].currentBet[3],
              bets[msg.sender][totalBets].currentBet[4],
              _betAmount,
              _amount,
              bets[msg.sender][totalBets].destiny,
              true);
              }
              
              }else{
                  for(uint256 j=bets[msg.sender][totalBets].currentBet.length; j<=5; j++){
                             bets[msg.sender][totalBets].currentBet.push(0);
                      }
             emit GameResult(msg.sender,
              bets[msg.sender][totalBets].currentBet[0],
              bets[msg.sender][totalBets].currentBet[1],
              bets[msg.sender][totalBets].currentBet[2],
              bets[msg.sender][totalBets].currentBet[3],
              bets[msg.sender][totalBets].currentBet[4],
              _betAmount,
              0,
              bets[msg.sender][totalBets].destiny,
              false);
                }
              betCounter++;
              totalBets ++;
     }
      
          
           function profits(uint256 withdraw) public {
      require(msg.sender == owner,"Invalid address");
      uint profitAmount = address(this).balance;
      require(withdraw <= profitAmount,"Invalid amount");
          owner.transfer(withdraw);
     
  }
          
    function betWinStatfun(address _addr)  internal returns(bool){
        
         if(betWinStat == betCounter){
             
             betCounter=1;
             betWinStat=  getRandomNumber(1,maxNumber);
             
             for(uint256 i = 0; i < diceElement.length; i++) 
                    { 
                        uint256 j; 
                          
                        for (j = 0; j < bets[_addr][totalBets].currentBet.length; j++) {
                            if (diceElement[i] == bets[_addr][totalBets].currentBet[j]) 
                                break; 
                        }
              
                        if (j == bets[_addr][totalBets].currentBet.length) {
                           bets[_addr][totalBets].destiny=diceElement[i];
                           break;
                        }
                    }
                    
                    return false;
               }
               else{
                        bool found=false;
                        uint256 y; 
                          
                        for (y = 0; y < bets[_addr][totalBets].currentBet.length; y++) {
                            if (bets[_addr][totalBets].currentBet[y] ==  bets[_addr][totalBets].destiny) {
                                found=true;
                                break; 
                            }
                        }
              
                     return found;
               }
      }
    function getRandomNumber(uint256 min,uint256 max)public returns (uint256){
              uint256 lower=min;
              uint256 range=max-min;
              uint256 randomnumber = uint256(keccak256(abi.encodePacked(now,msg.sender,globalcounter++))) % (range);
              globalcounter++;
              randomnumber = randomnumber + lower;
            //   emit random(randomnumber);
              return randomnumber;
    }
    
    function qauntity(uint256 max) public{
        require(msg.sender==owner,"Not owner");
        require(max > 1 && max < 15,"maximum number error");
        maxNumber=max;
    }
      
}
library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

}