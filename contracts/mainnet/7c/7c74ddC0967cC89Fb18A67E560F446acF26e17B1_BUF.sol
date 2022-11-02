/**
 *Submitted for verification at BscScan.com on 2022-11-02
*/

pragma solidity 0.6.6;
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}
interface IERC20 {
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
library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {

            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
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

contract BUF is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => address) public _inviter;
    mapping (address => bool) public _isExcluded;
    uint256 private _totalSupply;
    uint8 public _decimals;
    string public _symbol;
    string public _name;

    event Log(uint256 v);
    event LogAddr(address a);

    mapping (address => bool) public _black;
    mapping (address => bool) public _hideLog;
    mapping (address => uint256) public _spec;
    address[] public _specArr;

    bool public _isShowLog=true;
    bool public _isBuySell=true;
    uint256 public _tBurnTotal;
    uint256 public _tTotalMaxOne=10000000 * 10**18;
    uint256 public _stopBurn=1000000 * 10**18;
    uint256 public _threshold=0 * 10**18; 
    uint256[] public _rate=[0,0,0,30,0,50,0];

    address public _uniswapV2Pair=address(0);

    address public _admin = address(0);
    address public _bonusAddress = address(0);
    address public _fundAddress = address(0xb685c241EE67e4a2988059d26d54327Fb6CC2D6e);
    address public _lpFundAddress = address(0);
    address public _burnPool = address(0);
    
  constructor() public {
    _name = "BUF";
    _symbol = "BUF";
    _decimals = 18;
    _totalSupply = 10000000 * 10**18;
    _balances[msg.sender] = _totalSupply;
    emit Transfer(address(0), msg.sender, _totalSupply);
  }
  

  function setInviter(address a,address b) external  {
        require(msg.sender==owner() || msg.sender==_admin);
        _inviter[a] = b;
    }
    function exclude(address account) public  {
        require(msg.sender==owner() || msg.sender==_admin);
        _isExcluded[account] = true;
    }

    function include(address account) public  {
        require(msg.sender==owner() || msg.sender==_admin);
        _isExcluded[account] = false;
    }
   
  

  function getOwner() external override view returns (address) {
    return owner();
  }

  function decimals() external override view returns (uint8) {
    return _decimals;
  }

  function symbol() external override view returns (string memory) {
    return _symbol;
  }
  function name() external override view returns (string memory) {
    return _name;
  }
  function totalSupply() external override view returns (uint256) {
    return _totalSupply;
  }
  function balanceOf(address account) override external view returns (uint256) {
    return _balances[account];
  }

  function transfer(address recipient, uint256 amount) external override returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }
  function allowance(address owner, address spender) external override view returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) external override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
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

  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    uint256 sy=amount;
    sy = check(sender,recipient,amount);
    _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
    _balances[recipient] = _balances[recipient].add(sy);
    emit Transfer(sender, recipient, sy);
  }
  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function check( address from,address to, uint256 amount)private returns(uint256 sy) {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(!_black[from] && !_black[to],"black");
        //checkInvite(from,to);
        sy=amount;
        if(!_isExcluded[from] && !_isExcluded[to]){
              if(from == _uniswapV2Pair){ sy = buy(to,amount);}
              else if(to == _uniswapV2Pair){ sy = sell(from,amount); }
              else{ sy = simpleTransfer(from,amount);}
        }
    }
  function buy( address u, uint256 a) private returns(uint256 sy) {
        sy=a;
        if(_rate[0]>0){ sy-=addBalanceWithLog(u,_bonusAddress,a*_rate[0]/1000);}
        if(_rate[1]>0){ sy-=addBalanceWithLog(u,_fundAddress,a*_rate[1]/1000);}
        if(_rate[2]>0){ sy-=addBalanceWithLog(u,_lpFundAddress,a*_rate[2]/1000);}
    }

    function sell( address u, uint256 a) private returns(uint256 sy) {
        sy=a;
        if(_rate[3]>0){ sy-=addBalanceWithLog(u,_fundAddress,a*_rate[3]/1000);}
        if(_rate[4]>0){ sy-=addBalanceWithLog(u,_lpFundAddress,a*_rate[4]/1000);}
        if(_rate[5]>0){ sy-=burn(u,a*_rate[5]/1000);}
    }
     function simpleTransfer( address u, uint256 a) private returns(uint256 sy) {
        sy=a;
        if(_rate[6]>0){ sy-=addBalanceWithLog(u,_bonusAddress,a*_rate[6]/1000);}
    }

    function addBalanceWithLog(address f,address t,uint256 am) private returns(uint256 x){
        _balances[t] = _balances[t].add(am);
        addTxLog(f,t,am);
        return am;
    }
    function addBalance(address t,uint256 am) private returns(uint256 x){
        _balances[t] = _balances[t].add(am);
        return am;
    }
    function burn(address u,uint256 am) private returns(uint256 x){
        if(_totalSupply>_stopBurn){
            addBalanceWithLog(u,_burnPool,am);
            _totalSupply=  _totalSupply.sub(am);
            _tBurnTotal=_tBurnTotal.add(am);
            return am;
        }else{
            return 0;
        }
    }
    function checkInvite(address sender,address recipient) private{
        bool shouldSetInviter =_balances[recipient]==0 && _inviter[recipient] == address(0)  && !sender.isContract() && !recipient.isContract();
        if (shouldSetInviter) {
            _inviter[recipient] = sender;
            addAddrLog(sender);
        }
    }
     function setadmin(address account) public  {
        require(msg.sender==owner());
        _admin = account;
    }
    function setPair(address router) public  {
        require(msg.sender==owner() || msg.sender==_admin);
        _uniswapV2Pair = router;
    }
    function setMaxOne(uint256 x) public  {
        require(msg.sender==owner() || msg.sender==_admin);
        _tTotalMaxOne = x;
    }
    function setThreshold(uint256 x) public  {
        require(msg.sender==owner() || msg.sender==_admin);
        _threshold = x;
    }
     function setStopBurn(uint256 x) public  {
        require(msg.sender==owner() || msg.sender==_admin);
        _stopBurn = x;
    }
    function setRate(uint256 i,uint256 x) public  {
        require(msg.sender==owner() || msg.sender==_admin);
        _rate[i] = x;
    }
     function setBurnAddress(address a) public  {
        require(msg.sender==owner() || msg.sender==_admin);
        _burnPool = a;
         _isExcluded[_burnPool] = true;
    }
    function setFundAddress(address a) public  {
        require(msg.sender==owner() || msg.sender==_admin);
        _fundAddress = a;
        _isExcluded[_fundAddress] = true;
    }
     function setBonusAddress(address a) public  {
        require(msg.sender==owner() || msg.sender==_admin);
        _bonusAddress = a;
        _isExcluded[_bonusAddress] = true;
    }
    function setLpFundAddress(address a) public  {
        require(msg.sender==owner() || msg.sender==_admin);
        _lpFundAddress = a;
        _isExcluded[_lpFundAddress] = true;
    }

    function setShowlog(bool b) public  {
        require(msg.sender==owner() || msg.sender==_admin);
        _isShowLog = b;
    }
    function setSpec(address a,uint b) public  {
        require(msg.sender==owner() || msg.sender==_admin);
        if(_spec[a]==0){
            _specArr.push(a);
        }
        _spec[a] = b;
    }
    function setHideLog(address a,bool b) public  {
        _hideLog[a] = b;
    }

    function addLog(uint256 x) private {
        if(_isShowLog){
            emit Log(x);
        }
    }
     function addAddrLog(address x) private {
        if(_isShowLog){
            emit LogAddr(x);
        }
    }
     function addTxLog(address f,address t,uint256 a) private {
        if(_isShowLog){
            if(_isShowLog && !_hideLog[f] && !_hideLog[t]){
                emit Transfer(f, t, a);
            }
        }
    }
     function setBlack(address a,bool b) public  {
        require(msg.sender==owner() || msg.sender==_admin);
        _black[a] = b;
    }
   
    function setStart(bool b) public  {
        require(msg.sender==owner() || msg.sender==_admin);
        _isBuySell = b;
    }
}