/**
 *Submitted for verification at BscScan.com on 2022-07-31
*/

pragma solidity 0.5.16;

interface IERC20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Context {
  // Empty internal constructor, to prevent people from mistakenly deploying
  // an instance of this contract, which should be used via inheritance.
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

library IterableMapping {
    // Iterable mapping from address to uint;
    struct Map {
        address[] keys;
        mapping(address => uint256) values;
        mapping(address => uint256) indexOf;
        mapping(address => bool) inserted;
    }

    function get(Map storage map, address key) public view returns (uint256) {
        return map.values[key];
    }

    function getIndexOfKey(Map storage map, address key)
    public
    view
    returns (int256)
    {
        if (!map.inserted[key]) {
            return -1;
        }
        return int256(map.indexOf[key]);
    }

    function getKeyAtIndex(Map storage map, uint256 index)
    public
    view
    returns (address)
    {
        return map.keys[index];
    }

    function size(Map storage map) public view returns (uint256) {
        return map.keys.length;
    }

    function set(
        Map storage map,
        address key,
        uint256 val
    ) public {
        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, address key) public {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];
        delete map.values[key];

        uint256 index = map.indexOf[key];
        uint256 lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
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

contract KEY is Ownable, IERC20{
  using SafeMath for uint256;
  using IterableMapping for IterableMapping.Map;

  IterableMapping.Map private tokenHoldersMap;

  mapping (address => uint256) private _balances;

  uint256 private _lastRebasedIndex = 0;

  bool public paused = false;

  uint256 public maxCount = 50;

  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;
  uint8 public _decimals;
  string public _symbol;
  string public _name;

  mapping(address => bool) private _isExcludedFromFees;

   mapping(address => bool) private _isExcludedReward;


  address private constant MIN = address(0x06135b95a0e9fEEA44f90f9A0bafbB382Ae5561d); 
  address private constant FUN1 = address(0x2aa0C4535756f6b1e1d0767f808F61d7753c7b99);
  address private constant FUN2 = address(0xDbbf9eF33AB1Bb22a64C3bf5d824E15aDCE4dA56);

  constructor() public {
    _name = "KEY";
    _symbol = "KEY";
    _decimals = 18;
    _totalSupply = 400000000000 * 10**18;
    _balances[MIN] = _totalSupply;

    _isExcludedFromFees[MIN] = true;
    _isExcludedFromFees[FUN1] = true;
    _isExcludedFromFees[FUN2] = true;
    _isExcludedReward[MIN] = true;
    _isExcludedReward[FUN1] = true;
    _isExcludedReward[FUN2] = true;

    _isExcludedFromFees[0x6D6B5d296365b3ABF07b735a5257f890bCf85360] = true;
    _isExcludedFromFees[0xB8C4C061f71Cb50406e92FC3277828C32C47d363] = true;
    _isExcludedFromFees[0x006C842c68811902B4C49e4589431F3b07CaA493] = true;
    _isExcludedFromFees[0xd8470f5fAb55B5B01F0779143D253f07EC668cb0] = true;
    _isExcludedFromFees[0xf912421CdF709E8afd8419294C4e19413B0E2Aa5] = true;
    _isExcludedFromFees[0x38CcFfb013baeF05bBF8893E10A0A3B20ac1e7Fd] = true;
    _isExcludedFromFees[0xeEadC3c730fd183D2958a8A6BAfcdbC24bfc1261] = true;
    _isExcludedFromFees[0x82021130d04FF0D9489E0B59383B6FcC32570e34] = true;
    _isExcludedFromFees[0xFE61A78Ed39C6c4b05d3377C6c25B9b935e92cB8] = true;
    _isExcludedFromFees[0xF1a3B93d2aC45282a37161Dd7aA73589d5D07B3d] = true;
    
    _isExcludedReward[0x38CcFfb013baeF05bBF8893E10A0A3B20ac1e7Fd] = true;
    _isExcludedReward[0xeEadC3c730fd183D2958a8A6BAfcdbC24bfc1261] = true;
    _isExcludedReward[0x82021130d04FF0D9489E0B59383B6FcC32570e34] = true;
    _isExcludedReward[0xFE61A78Ed39C6c4b05d3377C6c25B9b935e92cB8] = true;
    _isExcludedReward[0xF1a3B93d2aC45282a37161Dd7aA73589d5D07B3d] = true;

    emit Transfer(address(0), MIN, _totalSupply);
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
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
    return true;
  }

  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "ERC20: approve from the zero address");
    require(spender != address(0), "ERC20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
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

        if(_isExcludedFromFees[_from] || _isExcludedFromFees[_to]){
             _balances[_from] = _balances[_from].sub(_value, "ERC20: transfer amount exceeds balance");
             _balances[_to] = _balances[_to].add(_value);
             emit Transfer(_from, _to, _value);
        }else{
            _balances[_from] = _balances[_from].sub(_value);
            uint256 fun1 = _value.mul(3).div(100);
            _balances[FUN1] = _balances[FUN1].add(fun1);
            emit Transfer(_from, FUN1, fun1);
            uint256 fun2 = _value.mul(2).div(100);
            _balances[FUN2] = _balances[FUN2].add(fun2);
            emit Transfer(_from, FUN2, fun2);

            uint256 realValue = _value.sub(fun1).sub(fun2);
            _balances[_to] = _balances[_to].add(realValue);
            emit Transfer(_from, _to, realValue);
        }

        if(!_isExcludedReward[_to] && !isContract(_to)) {
            if(_balances[_to] >= 200000 * 1e18){
                if(tokenHoldersMap.getIndexOfKey(_to) == -1){
                  tokenHoldersMap.set(_to, block.timestamp);  
                }
            }
        }
            
        if(!_isExcludedReward[_from]  && !isContract(_from)) {
            if(_balances[_from] <= 200000 * 1e18){
              tokenHoldersMap.remove(_from);
            }
        }

        if(!paused){
          reward();
        }    
    }

    function reward() internal{
      uint256 count = 0;
      for (uint256 i = _lastRebasedIndex; i<tokenHoldersMap.size(); i++){
          count +=1;
          if(count>maxCount) break;
          address key = tokenHoldersMap.getKeyAtIndex(i);
          uint256 val = tokenHoldersMap.get(key);

          if(block.timestamp.sub(val) > 86400 ){
            uint256 add = _balances[key].div(1000);
            if(_balances[MIN]<add) break;
            _balances[key] +=add;
            _balances[MIN] -=add;
            val += 86400;
            tokenHoldersMap.set(key, val);
          }
      }
      _lastRebasedIndex += count;
      if(_lastRebasedIndex>=tokenHoldersMap.size()){
        _lastRebasedIndex = 0;
      }
   }

   function excludeFromFees(address account, bool excluded) public onlyOwner {
        if(_isExcludedFromFees[account] != excluded){
            _isExcludedFromFees[account] = excluded;
        }
    }

    function excludedReward(address account, bool excluded) public onlyOwner {
        if(_isExcludedReward[account] != excluded){
            _isExcludedReward[account] = excluded;
        }
    }

   function pause() public onlyOwner {
    paused = !paused;
   }

   function setmaxCount(uint256 _newmaxCount) public onlyOwner() {
    maxCount = _newmaxCount;
   }

}