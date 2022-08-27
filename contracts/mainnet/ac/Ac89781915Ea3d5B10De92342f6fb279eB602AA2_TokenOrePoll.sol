/**
 *Submitted for verification at BscScan.com on 2022-08-27
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

interface IOrePoll{
    event AddPledgePair(address indexed account, uint256 id, uint256 value);
    event RemovePledgePair(address indexed account, uint256 id, uint256 value);
    
    function getCount() external view returns(uint256);
    function getStatus(uint256 id) external view returns(bool);
    function getOrePollToken(uint256 id) external view returns(address);
    function getRegularTime(uint256 id) external view returns(uint256);
    function getTotalPledge(uint256 id) external view returns(uint256);
    function getBalanceOf(uint256 id, address account) external view returns(uint256);
    function getLastPledgeTime(uint256 id, address account) external view returns(uint256);
    function addPledgeToken(uint256 id, uint256 amount) external returns(bool);
    function removePledgePair(uint256 id) external returns(bool);
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

contract TokenOrePoll is IOrePoll, Context, Ownable {
    
    using SafeMath for uint256;
    
    uint256 private _count;
    
    mapping(uint256 => bool) private _status;
    
    mapping(uint256 => address) private _orePollList;
    
    mapping(uint256 => uint256) private _regularTimeList;
    
    mapping(uint256 => uint256) private _totalPledge;
    
    mapping(uint256 => mapping(address => uint256)) private _balanceOf;
    
    mapping(uint256 => mapping(address => uint256)) private _lastPledgeTime;
    
    function createOrePoll(address token, uint256 regularTime) external onlyOwner returns(uint256 id){
        _orePollList[_count] = token;
        _regularTimeList[_count] = regularTime;
        id = _count;
        _status[id] = true;
        _count++;
    }
    
    function openAndClose(uint256 id, bool open) external onlyOwner returns(bool success){
        require(_orePollList[id] != address(0), "ore poll id non-existent");
        _status[id] = open;
        success = true;
    }
    
    function getCount() external view returns(uint256){
        return _count;
    }
    
    function getStatus(uint256 id) external view returns(bool){
        return _status[id];
    }
    
    function getOrePollToken(uint256 id) external view returns(address){
        return _orePollList[id];
    }
    
    function getRegularTime(uint256 id) external view returns(uint256){
        return _regularTimeList[id];
    }
    
    function getTotalPledge(uint256 id) external view returns(uint256){
        return _totalPledge[id];
    }
    
    function getBalanceOf(uint256 id, address account) external view returns(uint256){
        return _balanceOf[id][account];
    }
    
    function getLastPledgeTime(uint256 id, address account) external view returns(uint256){
        return _lastPledgeTime[id][account];
    }
    
    function addPledgeToken(uint256 id, uint256 amount) external returns(bool){
        require(_orePollList[id] != address(0), "ore poll id non-existent");
        require(_status[id], "ore poll not open");
        require(amount > 0, "Quantity cannot be less than 0");
        require(IBEP20(_orePollList[id]).balanceOf(_msgSender()) >= amount, "token balance insufficient");
        
        bool success = IBEP20(_orePollList[id]).transferFrom(_msgSender(), address(this), amount);
        if (success){
            _balanceOf[id][_msgSender()] = _balanceOf[id][_msgSender()].add(amount);
            _totalPledge[id] = _totalPledge[id].add(amount);
            if(_regularTimeList[id] > 0){
                _lastPledgeTime[id][_msgSender()] = block.timestamp;
            }
            emit AddPledgePair(_msgSender(), id, amount);
        }
    }
    
    function removePledgePair(uint256 id) external returns(bool){
        require(_orePollList[id] != address(0), "ore poll id non-existent");
        require(_status[id], "ore poll not open");
        
        uint256 amount = _balanceOf[id][_msgSender()];
        require(amount > 0, "pledge balance insufficient");
        if (_regularTimeList[id] > 0){
            require(_lastPledgeTime[id][_msgSender()].add(_regularTimeList[id]) < block.timestamp, "Unexpired");
        }
        bool success = IBEP20(_orePollList[id]).transfer(_msgSender(), amount);
        if (success){
            _balanceOf[id][_msgSender()] = 0;
            _totalPledge[id] = _totalPledge[id].sub(amount);
            emit RemovePledgePair(_msgSender(), id, amount);
        }
    }
    
}