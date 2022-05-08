/**
 *Submitted for verification at BscScan.com on 2022-05-08
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-23
*/

pragma solidity ^0.6.0;

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

contract FACTOOL {
    event ActiveAccount(address indexed account,address indexed refer);
    event UpdateActive(address indexed account,address indexed refer);
    event MultiTransfer(uint256 total, address tokenAddress);
    mapping (address => address) private _refers;
    address[] private _actives;
    address private _master;

    constructor () public{
        _master = msg.sender;
    }

    function active(address refer) public returns(uint code){
        if(msg.sender == refer){
            return 2;
        }
        if(_refers[msg.sender]!=address(0)){
            return 3;
        }
        if(refer == address(0)){
            refer = _master;
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

    function setMaster(address addr) public {
        require(msg.sender == _master);
        _master=addr;
    }
}