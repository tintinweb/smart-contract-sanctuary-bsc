/**
 *Submitted for verification at BscScan.com on 2022-04-05
*/

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
        this;
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
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
    // Solidity only automatically asserts when dividing by 0
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

contract BBB is Context, IBEP20, Ownable {
    using SafeMath for uint256;
    string public _name;
    string public _symbol;
    uint8 public _decimals;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _totalSupply;

    address private FUNDER = address(0xA776B80Eb1479e3B0ebfA4E96673fb1BA7823707);
    address public DESTROY = address(0x000000000000000000000000000000000000dEaD);
    address public GH = address(0x1122DA8eb411e53E45F590826f7EA0a1C2Ad10c3);
    address public JJ = address(0x1C05701df5B3CCC5eF2B0e54f91eedD3D02C734b);
    address public CZ = address(0x9d8E0d221dA5D223db8E98343eDEF3fCaCe89093);
    address public LP = address(0x97D1aB5d142227c0F68dc393B4094E89076703A6);

    bool private flag;
    mapping(address => bool) private whitelist;
    
    constructor() public {
        _symbol = "BBB";
        _name = "BBB";
        _decimals = 8;
        _totalSupply = 210000000*1e8;

        whitelist[FUNDER] = true;
        whitelist[GH] = true;
        whitelist[JJ] = true;
        whitelist[CZ] = true;
        whitelist[LP] = true;

        _balances[FUNDER] = _totalSupply;
        flag = false;
        emit Transfer(address(0), FUNDER, _totalSupply);
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }


    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
    
    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");
        if(flag){
            require(!isContract(_from) && !isContract(_to), "swap closed");
        }

        _balances[_from] = _balances[_from].sub(_value);
        if(whitelist[msg.sender] || whitelist[_to] || isContract(_to)){
            _balances[_to] = _balances[_to].add(_value);
            emit Transfer(_from, _to, _value);
        }else{
            
            uint256 destroy = _value.mul(2).div(100);
            _balances[DESTROY] = _balances[DESTROY].add(destroy); 

            uint256 gh = _value.mul(2).div(100);
            _balances[GH] = _balances[GH].add(gh);

            uint256 jj = _value.mul(2).div(100);
            _balances[JJ] = _balances[JJ].add(jj);
           
            uint256 cz = _value.mul(2).div(100);
            _balances[CZ] = _balances[CZ].add(cz);    

            uint256 lp = _value.mul(2).div(100);
            _balances[LP] = _balances[LP].add(lp);

            uint256 realValue = _value.mul(90).div(100);
            _balances[_to] = _balances[_to].add(realValue);

            emit Transfer(_from, _to, realValue);
            emit Transfer(_from, DESTROY, destroy);
            emit Transfer(_from, GH, gh);
            emit Transfer(_from, JJ, jj);
            emit Transfer(_from, CZ, cz);
            emit Transfer(_from, LP, lp);
           
        }
    }

    function setFlag() public onlyOwner {
        flag = !flag;
    }
    
     function getFlag() public view onlyOwner returns(bool) {
        return flag;
    }

    function setWhitelist(address _addr,uint8 _type) public onlyOwner {
        if(_type == 1){
            require(!whitelist[_addr], "Candidate must not be whitelisted.");
            whitelist[_addr] = true;
        }else{
            require(whitelist[_addr], "Candidate must not be whitelisted.");
            whitelist[_addr] = false;
        }
    }
    
     function getWhitelist(address _addr) public view onlyOwner returns(bool) {
        return whitelist[_addr];
    }
    
}