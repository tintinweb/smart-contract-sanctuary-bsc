/**
 *Submitted for verification at BscScan.com on 2022-08-24
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

interface IPancakeERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
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

contract PairPrePoll is Context, Ownable {
    
    event AddPledgePair(address indexed account, uint256 value);
    event RemovePledgePair(address indexed account, uint256 value);
    
    using SafeMath for uint256;
    
    uint256 private _totalPledge;
    
    address _pairToken;
    
    constructor(address pairToken) public {
        _pairToken = pairToken;
    }
    
    mapping(address=>uint256) private _pledgeQuantity;
    
    function getPledgeQuantity(address account) external view returns(uint256){
        return _pledgeQuantity[account];
    }
    
    function getTotalPledge() external view returns(uint256){
        return _totalPledge;
    }
    
    function addPledgePair(uint256 amount) external returns(bool){
        require(_pairToken != address(0), "pair zero");
        require(amount > 0, "Quantity cannot be less than 0");
        require(IPancakeERC20(_pairToken).balanceOf(_msgSender()) >= amount, "pair balance insufficient");
        bool success = IPancakeERC20(_pairToken).transferFrom(_msgSender(), address(this), amount);
        if (success){
            _pledgeQuantity[_msgSender()] = _pledgeQuantity[_msgSender()].add(amount);
            _totalPledge = _totalPledge.add(amount);
            emit AddPledgePair(_msgSender(), amount);
        }
    }
    
    function removePledgePair() external returns(bool){
        require(_pairToken != address(0), "pair zero");
        uint256 amount = _pledgeQuantity[_msgSender()];
        require(amount > 0, "pledge balance insufficient");
        bool success = IPancakeERC20(_pairToken).transfer(_msgSender(), amount);
        if (success){
            _pledgeQuantity[_msgSender()] = 0;
            _totalPledge = _totalPledge.sub(amount);
            emit RemovePledgePair(_msgSender(), amount);
        }
    }
    
    
}