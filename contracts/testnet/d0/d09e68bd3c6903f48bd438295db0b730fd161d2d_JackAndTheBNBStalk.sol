/**
 *Submitted for verification at BscScan.com on 2022-09-07
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-04
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;


library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
}
//libraries
struct User {
    uint256 startDate;
    uint256 divs;
    uint256 refBonus;
    uint256 totalInits;
    uint256 totalWiths;
    uint256 totalAccrued;
    uint256 lastWith;
    uint256 timesCmpd;
    uint256 keyCounter;
    Depo [] depoList;
}
struct Depo {
    uint256 key;
    uint256 depoTime;
    uint256 amt;
    address reffy;
    bool initialWithdrawn;
}
struct Main {
    uint256 ovrTotalDeps;
    uint256 ovrTotalWiths;
    uint256 users;
    uint256 compounds;
}
struct DivPercs{
    uint256 daysInSeconds; // updated to be in seconds
    uint256 divsPercentage;
}
struct FeesPercs{
    uint256 daysInSeconds;
    uint256 feePercentage;
}
contract JackAndTheBNBStalk {
    using SafeMath for uint256;
    uint256 constant launch = 1662588934;
  	uint256 constant hardDays = 86400;
    uint256 constant minStakeAmt = 2 * 10**17;
    uint256 constant percentdiv = 1000;
    uint256 refPercentage = 100;
    uint256 devPercentage = 100;
    mapping (address => User) public UsersKey;
    mapping (uint256 => DivPercs) public PercsKey;
    mapping (uint256 => FeesPercs) public FeesKey;
    mapping (uint256 => Main) public MainKey;
    address public owner;

    constructor() {
            owner = msg.sender;
            PercsKey[10] = DivPercs(864000, 10);
            PercsKey[20] = DivPercs(1728000, 20);
            PercsKey[30] = DivPercs(2592000, 30);
            PercsKey[40] = DivPercs(3456000, 40);
            PercsKey[50] = DivPercs(4320000, 50);
            FeesKey[10] = FeesPercs(864000, 200);
            FeesKey[20] = FeesPercs(1728000, 160);
            FeesKey[30] = FeesPercs(2592000, 120);
            FeesKey[40] = FeesPercs(3456000, 100);
            FeesKey[50] = FeesPercs(4320000, 80);
    }

    receive() payable external {}

    fallback() payable external {}

    function stake(address ref) external payable {
        require(block.timestamp >= launch, "App did not launch yet.");
        require(ref != msg.sender, "You cannot refer yourself!");
        require(msg.value >= minStakeAmt, "You should stake at least 0.2 BNB.");

        uint256 amtx = msg.value;
        User storage user = UsersKey[msg.sender];
        User storage user2 = UsersKey[ref];
        Main storage main = MainKey[1];
        if (user.lastWith == 0){
            user.lastWith = block.timestamp;
            user.startDate = block.timestamp;
        }
        uint256 userStakePercentAdjustment = 1000 - devPercentage;
        uint256 adjustedAmt = amtx.mul(userStakePercentAdjustment).div(percentdiv); 
        uint256 stakeFee = amtx.mul(devPercentage).div(percentdiv); 
        
        user.totalInits += adjustedAmt; 
        uint256 refAmtx = adjustedAmt.mul(refPercentage).div(percentdiv);
        if (ref != address(0)) {
            user2.refBonus += refAmtx;
        }

        user.depoList.push(Depo({
            key: user.depoList.length,
            depoTime: block.timestamp,
            amt: adjustedAmt,
            reffy: ref,
            initialWithdrawn: false
        }));

        user.keyCounter += 1;
        main.ovrTotalDeps += 1;
        main.users += 1;
        
        payable(owner).transfer(stakeFee);
    }

    function userInfo() view external returns (Depo [] memory depoList) {
        User storage user = UsersKey[msg.sender];
        return(
            user.depoList
        );
    }

    function withdrawDivs() external returns (uint256 withdrawAmount) {
        User storage user = UsersKey[msg.sender];
        Main storage main = MainKey[1];
        uint256 x = calcdiv(msg.sender);
      
      	for (uint i = 0; i < user.depoList.length; i++){
          if (user.depoList[i].initialWithdrawn == false) {
            user.depoList[i].depoTime = block.timestamp;
          }
        }

        main.ovrTotalWiths += x;
        user.lastWith = block.timestamp;

        payable(msg.sender).transfer(x);

        return x;
    }

    function withdrawInitial(uint256 key) external {
      	  
      	User storage user = UsersKey[msg.sender];
				
      	require(user.depoList[key].initialWithdrawn == false, "This has already been withdrawn.");
      
        uint256 initialAmt = user.depoList[key].amt; 
        uint256 currDays1 = user.depoList[key].depoTime;
        uint256 currTime = block.timestamp;
        uint256 currDays = currTime - currDays1;
        uint256 transferAmt;
      	
        if (currDays < FeesKey[10].daysInSeconds){ // LESS THAN 10 DAYS STAKED
            uint256 minusAmt = initialAmt.mul(FeesKey[10].feePercentage).div(percentdiv); //20% fee
           	
          	uint256 dailyReturn = initialAmt.mul(PercsKey[10].divsPercentage).div(percentdiv);
            uint256 currentReturn = dailyReturn.mul(currDays).div(hardDays);
          	
          	transferAmt = initialAmt + currentReturn - minusAmt;
          
            user.depoList[key].amt = 0;
            user.depoList[key].initialWithdrawn = true;
            user.depoList[key].depoTime = block.timestamp;

            payable(msg.sender).transfer(transferAmt);
            payable(owner).transfer(minusAmt);


        } else if (currDays >= FeesKey[10].daysInSeconds && currDays < FeesKey[20].daysInSeconds){ // BETWEEN 10 and 20 DAYS
            uint256 minusAmt = initialAmt.mul(FeesKey[20].feePercentage).div(percentdiv); //16% fee
						
          	uint256 dailyReturn = initialAmt.mul(PercsKey[20].divsPercentage).div(percentdiv);
            uint256 currentReturn = dailyReturn.mul(currDays).div(hardDays);
						transferAmt = initialAmt + currentReturn - minusAmt;

            user.depoList[key].amt = 0;
            user.depoList[key].initialWithdrawn = true;
            user.depoList[key].depoTime = block.timestamp;

            payable(msg.sender).transfer(transferAmt);
            payable(owner).transfer(minusAmt);

        } else if (currDays >= FeesKey[20].daysInSeconds && currDays < FeesKey[30].daysInSeconds){ // BETWEEN 20 and 30 DAYS
            uint256 minusAmt = initialAmt.mul(FeesKey[30].feePercentage).div(percentdiv); //12% fee
            
          	uint256 dailyReturn = initialAmt.mul(PercsKey[30].divsPercentage).div(percentdiv);
            uint256 currentReturn = dailyReturn.mul(currDays).div(hardDays);
						transferAmt = initialAmt + currentReturn - minusAmt;

            user.depoList[key].amt = 0;
            user.depoList[key].initialWithdrawn = true;
            user.depoList[key].depoTime = block.timestamp;

            payable(msg.sender).transfer(transferAmt);
            payable(owner).transfer(minusAmt);

        } else if (currDays >= FeesKey[30].daysInSeconds && currDays < FeesKey[40].daysInSeconds){ // BETWEEN 30 and 40 DAYS
            uint256 minusAmt = initialAmt.mul(FeesKey[40].feePercentage).div(percentdiv); //10% fee
            
          	uint256 dailyReturn = initialAmt.mul(PercsKey[40].divsPercentage).div(percentdiv);
            uint256 currentReturn = dailyReturn.mul(currDays).div(hardDays);
						transferAmt = initialAmt + currentReturn - minusAmt;

            user.depoList[key].amt = 0;
            user.depoList[key].initialWithdrawn = true;
            user.depoList[key].depoTime = block.timestamp;

            payable(msg.sender).transfer(transferAmt);
            payable(owner).transfer(minusAmt);

        } else if (currDays >= FeesKey[40].daysInSeconds && currDays < FeesKey[50].daysInSeconds){ // BETWEEN 40 and 50 DAYS
            uint256 minusAmt = initialAmt.mul(FeesKey[50].feePercentage).div(percentdiv); //8% fee
            
          	uint256 dailyReturn = initialAmt.mul(PercsKey[50].divsPercentage).div(percentdiv);
            uint256 currentReturn = dailyReturn.mul(currDays).div(hardDays);
						transferAmt = initialAmt + currentReturn - minusAmt;

            user.depoList[key].amt = 0;
            user.depoList[key].initialWithdrawn = true;
            user.depoList[key].depoTime = block.timestamp;

            payable(msg.sender).transfer(transferAmt);
            payable(owner).transfer(minusAmt);

        } else if (currDays >= FeesKey[50].daysInSeconds){ // 50+ DAYS
            uint256 minusAmt = initialAmt.mul(FeesKey[30].feePercentage).div(percentdiv); //12% fee
            
          	uint256 dailyReturn = initialAmt.mul(PercsKey[30].divsPercentage).div(percentdiv);
            uint256 currentReturn = dailyReturn.mul(currDays).div(hardDays);
						transferAmt = initialAmt + currentReturn - minusAmt;

            user.depoList[key].amt = 0;
            user.depoList[key].initialWithdrawn = true;
            user.depoList[key].depoTime = block.timestamp;
            
            payable(msg.sender).transfer(transferAmt);
            payable(owner).transfer(minusAmt);

        } else {
            revert("Could not calculate the # of days you've been staked.");
        }
        
    }
    function withdrawRefBonus() external {
        User storage user = UsersKey[msg.sender];
        uint256 amtz = user.refBonus;
        user.refBonus = 0;

        payable(msg.sender).transfer(amtz);
    }

    function stakeRefBonus() external { 
        User storage user = UsersKey[msg.sender];
        Main storage main = MainKey[1];
        require(user.refBonus > 10);
      	uint256 refferalAmount = user.refBonus;
        user.refBonus = 0;
        address ref = address(0); //ZERO ADDRESS
				
        user.depoList.push(Depo({
            key: user.keyCounter,
            depoTime: block.timestamp,
            amt: refferalAmount,
            reffy: ref, 
            initialWithdrawn: false
        }));

        user.keyCounter += 1;
        main.ovrTotalDeps += 1;
    }

    function calcdiv(address dy) public view returns (uint256 totalWithdrawable) {
        User storage user = UsersKey[dy];	

        uint256 with;
        
        for (uint256 i = 0; i < user.depoList.length; i++){	
            uint256 elapsedTime = block.timestamp.sub(user.depoList[i].depoTime);

            uint256 amount = user.depoList[i].amt;
            if (user.depoList[i].initialWithdrawn == false){
                if (elapsedTime <= PercsKey[10].daysInSeconds){ 
                    uint256 dailyReturn = amount.mul(PercsKey[10].divsPercentage).div(percentdiv);
                    uint256 currentReturn = dailyReturn.mul(elapsedTime).div(PercsKey[10].daysInSeconds / 10);
                    with += currentReturn;
                }
                if (elapsedTime > PercsKey[10].daysInSeconds && elapsedTime <= PercsKey[20].daysInSeconds){
                    uint256 dailyReturn = amount.mul(PercsKey[20].divsPercentage).div(percentdiv);
                    uint256 currentReturn = dailyReturn.mul(elapsedTime).div(PercsKey[10].daysInSeconds / 10);
                    with += currentReturn;
                }
                if (elapsedTime > PercsKey[20].daysInSeconds && elapsedTime <= PercsKey[30].daysInSeconds){
                    uint256 dailyReturn = amount.mul(PercsKey[30].divsPercentage).div(percentdiv);
                    uint256 currentReturn = dailyReturn.mul(elapsedTime).div(PercsKey[10].daysInSeconds / 10);
                    with += currentReturn;
                }
                if (elapsedTime > PercsKey[30].daysInSeconds && elapsedTime <= PercsKey[40].daysInSeconds){
                    uint256 dailyReturn = amount.mul(PercsKey[40].divsPercentage).div(percentdiv);
                    uint256 currentReturn = dailyReturn.mul(elapsedTime).div(PercsKey[10].daysInSeconds / 10);
                    with += currentReturn;
                }
                if (elapsedTime > PercsKey[40].daysInSeconds && elapsedTime <= PercsKey[50].daysInSeconds){
                    uint256 dailyReturn = amount.mul(PercsKey[50].divsPercentage).div(percentdiv);
                    uint256 currentReturn = dailyReturn.mul(elapsedTime).div(PercsKey[10].daysInSeconds / 10);
                    with += currentReturn;
                }
                if (elapsedTime > PercsKey[50].daysInSeconds){
                    uint256 dailyReturn = amount.mul(PercsKey[30].divsPercentage).div(percentdiv);
                    uint256 currentReturn = dailyReturn.mul(elapsedTime).div(PercsKey[10].daysInSeconds / 10);
                    with += currentReturn;
                }
                
            } 
        }
        return with;
    }

    function compound() external {
        User storage user = UsersKey[msg.sender];
        Main storage main = MainKey[1];

        uint256 y = calcdiv(msg.sender);

        for (uint i = 0; i < user.depoList.length; i++){
          if (user.depoList[i].initialWithdrawn == false) {
            user.depoList[i].depoTime = block.timestamp;
          }
        }

        user.depoList.push(Depo({
              key: user.keyCounter,
              depoTime: block.timestamp,
              amt: y,
              reffy: address(0), 
              initialWithdrawn: false
          }));

        user.keyCounter += 1;
        main.ovrTotalDeps += 1;
        main.compounds += 1;
        user.lastWith = block.timestamp;  
    }
}