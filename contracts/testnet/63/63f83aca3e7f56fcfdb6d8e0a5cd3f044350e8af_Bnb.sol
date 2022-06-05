/**
 *Submitted for verification at BscScan.com on 2022-06-04
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.12;

contract Bnb {
    using SafeMath for uint256;
    uint public totalPlayers;
    uint public totalPayout;
    uint public totalInvested;
    uint public activedeposits;
    address public referral;
    address public owner;
    address public dev;
    address public proadmin;
    uint256 public vel ; //(100*(86400*69445))/1000000000000  69445==0.60%
    uint public adminFees;
    uint public reffralPercentage ;
    uint private releaseTime;
    uint private interestRateDivisor = 1000000000000;
    //uint private minDepositSize = 250000000000000000; //0.25
    uint private minDepositSize = 10000000000000000; //0.01


 

    struct Player {
        uint bnbDeposit;
        uint packageamount;
        uint time;
        uint rTime;
        uint interestProfit;
        uint affRewards;
        uint payoutSum;
        address affFrom; 
        uint poolincome;
        uint booster;
        uint star;
        uint suprtstar;
    }
    struct Lvl{
        uint lvl1count;
        uint lvl1total;
        uint lvl2count;
        uint lvl2total;
        uint lvl3count;
        uint lvl3total;
        uint lvl4count;
        uint lvl4total;
        uint lvl5count;
        uint lvl5total;
    }

    struct Lvl1{
        uint lvl6count;
        uint lvl6total;
        uint lvl7count;
        uint lvl7total;
        uint lvl8count;
        uint lvl8total;
    }

    mapping(address => Player) public players;
    mapping(address => Lvl) public lvls;
    mapping(address => Lvl1) public lvl1s;

    event Newbie(address indexed user, address indexed _referrer, uint _time);  
	event NewDeposit(address indexed user, uint256 amount, uint _time);  
	event Withdrawn(address indexed user, uint256 amount, uint _time);  
    event Reinvest (address indexed user, uint256 amount, uint _time);  
	event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount, uint _time);
    event Booster(address indexed user,uint level,uint amount);
   
    constructor(address _proadmin,address _referral,address _owner,address _dev) public {
		proadmin = _proadmin;
        referral = _referral;
		owner = _owner;
        dev = _dev;        
        releaseTime = now;
        vel = 69445; //0.60%
        reffralPercentage = 5;
        adminFees = 10;

	}


    fallback() external payable {
        revert("Invalid Transaction");
    }

    receive() external payable {
         revert("Invalid Transaction");
    }

    function setAddr(address _r ,address _o,address _d, address _p) public {
        require(msg.sender == proadmin, "Invalid User!");
        referral = _r;
		owner = _o;
        dev = _d;
        proadmin = _p;

    }

    function setOwner(address _owner) public {
        require(msg.sender == owner, "Invalid User!");
        owner = _owner;
    }
    function setReferral(address _referral) public {
        require(msg.sender == owner, "Invalid User!");
        referral = _referral;
    }
    function setDev(address _dev) public {
        require(msg.sender == owner, "Invalid User!");
        dev = _dev;
    }
     function setRoi(uint256 _vel) public {
        require(msg.sender == owner, "Invalid User!");
        vel = _vel;
    }
     function setReffralPercentage(uint _ref) public {
        require(msg.sender == owner, "Invalid User!");
        reffralPercentage = _ref;
    }

    
     function setAdminFees(uint _adminFees) public {
        require(msg.sender == owner, "Invalid User!");
        adminFees = _adminFees;
    }

    function deposit(address _affAddr) public payable {
                //check lunch time
        if (now >= releaseTime){
        collect(msg.sender);
        
        }
        //minium deposit
        require(msg.sender != _affAddr, "Invalid Reffral!");
        require(msg.value >= minDepositSize, "not minimum amount!");
        uint depositAmount = msg.value;
        Player storage player = players[msg.sender];
        if (player.time == 0) {
            
            if (now < releaseTime) {
               player.time = releaseTime; 
               player.rTime = releaseTime;
                
            }
            else{
               
               player.time = now; 
               player.rTime = now;
            }    
            totalPlayers++;
         
            if(_affAddr != address(0) && players[_affAddr].bnbDeposit > 0){
                 emit Newbie(msg.sender, _affAddr, now);
              register(msg.sender, _affAddr,depositAmount);
            }
            else{
                emit Newbie(msg.sender, owner, now);
              register(msg.sender, owner,depositAmount);
            }
        }
        //player.rTime = now;
        player.bnbDeposit = player.bnbDeposit.add(depositAmount);
        player.packageamount = player.packageamount.add(depositAmount);
        distributeRef(msg.value, player.affFrom);  
   
        totalInvested = totalInvested.add(depositAmount);
        activedeposits = activedeposits.add(depositAmount);

     


    }
    function PayReferral(address  payable ref, uint256 ref_amount) public {
	    require(msg.sender == referral, "Referral not allowed!");
		ref.transfer(ref_amount);
	}

   

    function distributeRef(uint256 _mtc, address _affFrom) private{
        
        address  _affAddr1 = _affFrom;
        uint256 _affRewards = 0;
         if (_affAddr1 != address(0)) {
            _affRewards = (_mtc.mul(reffralPercentage)).div(100);
           
           
           if (now > releaseTime) {
               collect(_affAddr1);
                
            }

            players[_affAddr1].affRewards = _affRewards.add(players[_affAddr1].affRewards);
            payable(_affAddr1).transfer(_affRewards);
            emit RefBonus(_affAddr1, msg.sender, 1, _affRewards, now);
    
          
        }

        
    }
    
    function register(address _addr, address _affAddr,uint _depositAmount) private{
      
      uint depositAmount = _depositAmount;
      Player storage player = players[_addr];
      player.affFrom = _affAddr;

      address _affAddr1 = _affAddr;
      address _affAddr2 = players[_affAddr1].affFrom;
      address _affAddr3 = players[_affAddr2].affFrom;
      address _affAddr4 = players[_affAddr3].affFrom;
      address _affAddr5 = players[_affAddr4].affFrom;
      address _affAddr6 = players[_affAddr5].affFrom;
      address _affAddr7 = players[_affAddr6].affFrom;
      address _affAddr8 = players[_affAddr7].affFrom;
      address _affAddr9 = players[_affAddr8].affFrom;
      address _affAddr10 = players[_affAddr9].affFrom;
      
   
   

    lvls[_affAddr1].lvl1count = lvls[_affAddr1].lvl1count.add(1);
    lvls[_affAddr2].lvl2count = lvls[_affAddr2].lvl2count.add(1);
    lvls[_affAddr3].lvl3count = lvls[_affAddr3].lvl3count.add(1);
    lvls[_affAddr4].lvl4count = lvls[_affAddr4].lvl4count.add(1);
    lvls[_affAddr5].lvl5count = lvls[_affAddr5].lvl5count.add(1);

    lvls[_affAddr1].lvl1total = lvls[_affAddr1].lvl1total.add(depositAmount);
    lvls[_affAddr2].lvl2total = lvls[_affAddr2].lvl2total.add(depositAmount);
    lvls[_affAddr3].lvl3total = lvls[_affAddr3].lvl3total.add(depositAmount);
    lvls[_affAddr4].lvl4total = lvls[_affAddr4].lvl4total.add(depositAmount);
    lvls[_affAddr5].lvl5total = lvls[_affAddr5].lvl5total.add(depositAmount);

    lvl1s[_affAddr6].lvl6count = lvl1s[_affAddr6].lvl6count.add(1);
    lvl1s[_affAddr7].lvl6count = lvl1s[_affAddr7].lvl6count.add(1);
    lvl1s[_affAddr8].lvl6count = lvl1s[_affAddr8].lvl6count.add(1);
    lvl1s[_affAddr9].lvl6count = lvl1s[_affAddr9].lvl6count.add(1);
    lvl1s[_affAddr10].lvl6count = lvl1s[_affAddr10].lvl6count.add(1);
    


    lvl1s[_affAddr6].lvl6total = lvl1s[_affAddr6].lvl6total.add(depositAmount);
    lvl1s[_affAddr7].lvl6total = lvl1s[_affAddr7].lvl6total.add(depositAmount);
    lvl1s[_affAddr8].lvl6total = lvl1s[_affAddr8].lvl6total.add(depositAmount);
    lvl1s[_affAddr9].lvl6total = lvl1s[_affAddr9].lvl6total.add(depositAmount);
    lvl1s[_affAddr10].lvl6total = lvl1s[_affAddr10].lvl6total.add(depositAmount);
    _register1(_affAddr10,depositAmount);
       
    }

    function _register1(address _addr, uint Amount) private{
     uint depositAmount = Amount;
        
      address _affAddr10 = _addr;
      address _affAddr11 = players[_affAddr10].affFrom;
      address _affAddr12 = players[_affAddr11].affFrom;
      address _affAddr13 = players[_affAddr12].affFrom;
      address _affAddr14 = players[_affAddr13].affFrom;
      address _affAddr15 = players[_affAddr14].affFrom;
      address _affAddr16 = players[_affAddr15].affFrom;
      address _affAddr17 = players[_affAddr16].affFrom;
      address _affAddr18 = players[_affAddr17].affFrom;
      address _affAddr19 = players[_affAddr18].affFrom;
      address _affAddr20 = players[_affAddr19].affFrom;

      lvl1s[_affAddr11].lvl7count = lvl1s[_affAddr11].lvl7count.add(1);
      lvl1s[_affAddr12].lvl7count = lvl1s[_affAddr12].lvl7count.add(1);
      lvl1s[_affAddr13].lvl7count = lvl1s[_affAddr13].lvl7count.add(1);
      lvl1s[_affAddr14].lvl7count = lvl1s[_affAddr14].lvl7count.add(1);
      lvl1s[_affAddr15].lvl7count = lvl1s[_affAddr15].lvl7count.add(1);
      
      lvl1s[_affAddr16].lvl8count = lvl1s[_affAddr16].lvl8count.add(1);
      lvl1s[_affAddr17].lvl8count = lvl1s[_affAddr17].lvl8count.add(1);
      lvl1s[_affAddr18].lvl8count = lvl1s[_affAddr18].lvl8count.add(1);
      lvl1s[_affAddr19].lvl8count = lvl1s[_affAddr19].lvl8count.add(1);
      lvl1s[_affAddr20].lvl8count = lvl1s[_affAddr20].lvl8count.add(1);

      lvl1s[_affAddr11].lvl7total = lvl1s[_affAddr11].lvl7total.add(depositAmount);
      lvl1s[_affAddr12].lvl7total = lvl1s[_affAddr12].lvl7total.add(depositAmount);
      lvl1s[_affAddr13].lvl7total = lvl1s[_affAddr13].lvl7total.add(depositAmount);
      lvl1s[_affAddr14].lvl7total = lvl1s[_affAddr14].lvl7total.add(depositAmount);
      lvl1s[_affAddr15].lvl7total = lvl1s[_affAddr15].lvl7total.add(depositAmount);

      lvl1s[_affAddr16].lvl8total = lvl1s[_affAddr16].lvl8total.add(depositAmount);
      lvl1s[_affAddr17].lvl8total = lvl1s[_affAddr17].lvl8total.add(depositAmount);
      lvl1s[_affAddr18].lvl8total = lvl1s[_affAddr18].lvl8total.add(depositAmount);
      lvl1s[_affAddr19].lvl8total = lvl1s[_affAddr19].lvl8total.add(depositAmount);
      lvl1s[_affAddr20].lvl8total = lvl1s[_affAddr20].lvl8total.add(depositAmount);

        
    }

    function withdraw() public {
        collect(msg.sender);
        require(players[msg.sender].interestProfit > 0);
        easypool(msg.sender, players[msg.sender].interestProfit);
        transferPayout(msg.sender, players[msg.sender].interestProfit);
    }

    function easypool (address _addr , uint _amount) internal {

      uint j=0;
      address l = players[_addr].affFrom; 
      uint payamount = _amount;

      for (j = 1 ; j <= 20; j++) {
         
        if (l != address(0)) {
            if(j==1){
                uint directBusiness = lvls[l].lvl1total;
                if (directBusiness >= 1000000000000000000){
                    payable(l).transfer((payamount.mul(20)).div(100));
                    players[l].poolincome = players[l].poolincome.add((payamount.mul(20)).div(100));
                }
                
            }
            if(j==2)
            {   
                uint directBusiness = lvls[l].lvl1total;
                uint direct = lvls[l].lvl1count;
                 if (directBusiness >= 1000000000000000000){
                    if(direct > 1){
                        payable(l).transfer((payamount.mul(10)).div(100));
                        players[l].poolincome = players[l].poolincome.add((payamount.mul(10)).div(100));
                     }
                 }
                

            }
            if(j==3)
            {   
                 uint directBusiness = lvls[l].lvl1total;
                uint direct = lvls[l].lvl1count;
                 if (directBusiness >= 1000000000000000000){
                    if(direct > 2){
                        payable(l).transfer((payamount.mul(5)).div(100));
                        players[l].poolincome = players[l].poolincome.add((payamount.mul(5)).div(100));
                     }
                 }
            }
            if(j==4)
            {   
                uint directBusiness = lvls[l].lvl1total;
                uint direct = lvls[l].lvl1count;
                 if (directBusiness >= 1000000000000000000){
                    if(direct > 3){
                        payable(l).transfer((payamount.mul(3)).div(100));
                        players[l].poolincome = players[l].poolincome.add((payamount.mul(3)).div(100));
                     }
                 }

            }
            if(j==5)
            {   
                uint directBusiness = lvls[l].lvl1total;
                uint direct = lvls[l].lvl1count;
                 if (directBusiness >= 1000000000000000000){
                    if(direct > 4){
                        payable(l).transfer((payamount.mul(2)).div(100));
                        players[l].poolincome = players[l].poolincome.add((payamount.mul(2)).div(100));
                     }
                 }

            }
            if(j>=6 || j<=10)
            {   
                uint directBusiness = lvls[l].lvl1total;
                uint direct = lvls[l].lvl1count;
                uint pamount = players[l].packageamount;
                 if (directBusiness >= 20000000000000000000){
                    if(direct > 5 && pamount > 5000000000000000000){
                        payable(l).transfer((payamount.mul(1)).div(100));
                        players[l].poolincome = players[l].poolincome.add((payamount.mul(1)).div(100));
                     }
                 }

            }
            if(j>=11 || j<=15)
            {   
                uint directBusiness = lvls[l].lvl1total;
                uint direct = lvls[l].lvl1count;
                uint pamount = players[l].packageamount;
                 if (directBusiness >= 50000000000000000000){
                    if(direct > 6 && pamount > 10000000000000000000){
                        payable(l).transfer((payamount.mul(1)).div(100));
                        players[l].poolincome = players[l].poolincome.add((payamount.mul(1)).div(100));
                     }
                 }

            }
            if(j>=16 || j<=20)
            {   
                
                uint directBusiness = lvls[l].lvl1total;
                uint direct = lvls[l].lvl1count;
                uint pamount = players[l].packageamount;
                 if (directBusiness >= 100000000000000000000 ){
                    if(direct > 7 && pamount > 15000000000000000000){
                        payable(l).transfer((payamount.mul(1)).div(100));
                        players[l].poolincome = players[l].poolincome.add((payamount.mul(1)).div(100));
                        if(j == 20){
                            uint pstar = players[l].star;
                            if(pstar == 0)
                            {
                                players[l].star = 1;
                                address k = players[l].affFrom;
                                uint kstar = players[k].star;
                                if(kstar == 1)
                                {
                                    players[k].suprtstar = players[k].suprtstar.add(1);
                                }

                            }
                        }
                     }
                 }

            }
            
           

          
        }else{
            j = 21;
        }
         l = players[l].affFrom;        
      }

    } 
     function transferPayout(address _receiver, uint _amount) internal {
        if (_amount > 0 && _receiver != address(0)) {
          uint contractBalance = address(this).balance;
            if (contractBalance > 0) {
                uint payout = _amount > contractBalance ? contractBalance : _amount;
                totalPayout = totalPayout.add(payout);
                activedeposits = activedeposits.sub(payout);

                uint256 aFees = (payout.mul(10)).div(100);
                payable(owner).transfer(aFees);
                payout = payout.sub(aFees);           

                uint reinvest = (payout.mul(20)).div(100);
                activedeposits = activedeposits.add(reinvest);
                

                Player storage player = players[_receiver];
                player.bnbDeposit = player.bnbDeposit.add(reinvest);

                player.payoutSum = player.payoutSum.add((payout.mul(80)).div(100));
                player.interestProfit = player.interestProfit.sub((payout.mul(80)).div(100));
                player.bnbDeposit = player.bnbDeposit.sub((payout.mul(80)).div(100));
  
                msg.sender.transfer(payout);
                emit Withdrawn(msg.sender, payout, now);
                emit Reinvest(msg.sender, reinvest, now);
            }
        }
    }

    function collect(address _addr) internal {
        Player storage player = players[_addr];
        
    	
	
       uint secPassed = now.sub(player.time);
       if (secPassed > 0 && player.time > 0) {
           uint collectProfit = (player.bnbDeposit.mul(secPassed.mul(vel))).div(interestRateDivisor);
          player.interestProfit = player.interestProfit.add(collectProfit);
            if (player.interestProfit >= player.bnbDeposit.mul(2)){
              player.interestProfit = player.bnbDeposit.mul(2);
            }
            
            player.time = player.time.add(secPassed);
       }
    }
    function getProfit(address _addr) public view returns (uint) {
      address playerAddress= _addr;
      Player storage player = players[playerAddress];
      require(player.time > 0);

        if ( now < releaseTime){
        return 0;
            
            
        }
        else{


      uint secPassed = now.sub(player.time);
      
	  
	  uint collectProfit =0 ;
      if (secPassed > 0) {
          collectProfit = (player.bnbDeposit.mul(secPassed.mul(vel))).div(interestRateDivisor);
      }
      
      if (collectProfit.add(player.interestProfit) >= player.bnbDeposit.mul(2)){
               return player.bnbDeposit.mul(2);
            }
        else{
      return collectProfit.add(player.interestProfit);
        }
        }
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