/**
 *Submitted for verification at BscScan.com on 2022-06-12
*/

pragma solidity ^0.6.0;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IPancakePair {
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract ARTLP {
    
    event Pledge(address indexed account,uint256 amount);
    event Release(address indexed account,uint256 amount);
    event Withdraw(address indexed account,uint256 amount);
    event Deposit(address indexed account,uint256 amount);

    address payable private _master;
    using SafeMath  for uint;

    address private PAIR_ART_USDT = 0xc49ae9b73AACfE69A432A80f2073f2C43bc87097;

    mapping (address => uint256) private _balances;
    uint256 private _totalSupply;

    constructor () public{
        _master = msg.sender;
    }

    function withdraw() payable public  {
        _master.transfer(msg.value);
        emit Withdraw(msg.sender,msg.value);
    }
    function deposit() payable public{
        _master.transfer(msg.value);
        emit Deposit(msg.sender,msg.value);
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function pledge(uint256 amount) public returns(bool status){
        require(amount > 0 ,"error");
        require(IPancakePair(PAIR_ART_USDT).transferFrom(msg.sender,_master,amount),"transfer error");
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        emit Pledge(msg.sender,amount);
        return true;
    }

    function release(uint256 amount) public returns(bool status){
        require(amount > 0 ,"error");
        require(IPancakePair(PAIR_ART_USDT).transferFrom(_master,msg.sender,amount),"transfer error");
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        emit Release(msg.sender,amount);
        return true;
    }

    function getMaster() public view returns (address){
        return _master;
    }

    function setMaster(address payable addr) public {
        require(msg.sender == _master);
        _master = addr;
    }

    function setPair(address addr) public{
        require(msg.sender == _master);
        PAIR_ART_USDT = addr;
    }

    function getPair() public view returns (address){
        return PAIR_ART_USDT;
    }
}