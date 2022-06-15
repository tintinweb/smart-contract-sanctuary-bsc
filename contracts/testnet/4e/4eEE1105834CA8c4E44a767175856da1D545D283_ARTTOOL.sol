/**
 *Submitted for verification at BscScan.com on 2022-06-15
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

interface IPancakeFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IPancakePair {
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract ARTTOOL {
    event ActiveAccount(address indexed account,address indexed refer);
    event UpdateActive(address indexed account,address indexed refer);
    event MultiTransfer(uint256 total, address tokenAddress);
    mapping (address => address) private _refers;
    address[] private _actives;
    address payable private _master;
    using SafeMath  for uint;


    mapping (address => uint256) private _balances;
    uint256 private _totalSupply;

    constructor () public{
        _master = msg.sender;
        _refers[msg.sender]=msg.sender;
    }

    function active(address refer) public returns(uint code){
        if(_refers[refer] == address(0)){
            return 1;
        }
        if(msg.sender == refer){
            return 2;
        }
        if(_refers[msg.sender]!=address(0)){
            return 3;
        }
        _refers[msg.sender] = refer;
        _actives.push(msg.sender);
        emit ActiveAccount(msg.sender,refer);
        return 0;
    }

    function isActive() view public returns(bool status){
        return _refers[msg.sender] != address(0);
    }

    function getActive(address addr) view public returns(bool status){
        return _refers[addr] != address(0);
    }

    function activeRefer(address addr) public view returns(address refer){
        return _refers[addr];
    }

    function updateActive(address addr,address refer) public{
        require(msg.sender == _master);
        _refers[addr] = refer;
        emit UpdateActive(addr,refer);
    }

    function activeAllList() public view returns(address[] memory keys,address[] memory values){
        address[] memory list=new address[](_actives.length);
        for(uint i=0;i<_actives.length;i++){
            address key=_actives[i];
            address addr=_refers[key];
            list[i]=addr;
        }
        return(_actives,list);
    }

    function multiTransfer(address _token, address[] memory addresses, uint256[] memory counts) public returns (bool){
        uint256 total;
        IERC20 token = IERC20(_token);
        for(uint i = 0; i < addresses.length; i++) {
            require(token.transferFrom(msg.sender, addresses[i], counts[i]));
            total += counts[i];
        }
        emit MultiTransfer(total,_token);
        return true;
    }

    function getMaster() public view returns (address){
        return _master;
    }

    function setMaster(address payable addr) public {
        require(msg.sender == _master);
        _master = addr;
    }





}