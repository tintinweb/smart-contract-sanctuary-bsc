/**
 *Submitted for verification at BscScan.com on 2022-09-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

contract WrappedBinaryToken {

    string constant public name = "Wrapped Binary Token";
    string constant public symbol = "WBNRY";
    uint8 constant public decimals = 18;
    uint _totalSupply;

    mapping (address => uint) balances;
    mapping (address => mapping (address => uint)) allowed;

    address public admin;
    address public BRIDGE_CONTRACT;

    event  Approval(address indexed _owner, address indexed _spender, uint _amount);
    event  Transfer(address indexed _from, address indexed _to, uint _amount);
    event  BridgeBurn(address indexed _owner, uint _amount);
    event  BridgeMint(address indexed _owner, uint _amount);

    modifier onlyBridge() {
        require(msg.sender == BRIDGE_CONTRACT, "You are not allowed!");
        _;
    }

    constructor(address _ps) {
        admin = msg.sender;
        _totalSupply = 60*10**24;
        balances[_ps] = 11*10**24;
        balances[admin] = 49*10**24;
    }

    function setBridge(address _addr) external returns(bool) {
        require(msg.sender == admin, "Only admin!");
        require(BRIDGE_CONTRACT == address(0), "Bridge was already set!");
        require(_addr != address(0), "Impossible set address zero as Bridge address!");
        BRIDGE_CONTRACT = _addr;
        return true;
    }

    function balanceOf(address _addr) external view returns(uint) {
        return balances[_addr];
    }

    function allowance(address _owner, address _spender) external view returns(uint) {
        return allowed[_owner][_spender];
    }

    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }


    function transfer(address _to, uint _amount) public returns (bool) {
        require(balances[msg.sender] >= _amount, "Not enough funds!");
        require(msg.sender != address(0) && _to != address(0), "Wrong address!");
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }

    function transferFrom(address _from, address _to, uint _amount) public returns (bool) {
        require(msg.sender != address(0) && _to != address(0), "Wrong address!");
        require(balances[_from] >= _amount, "Not enough funds!");
        require(allowed[_from][msg.sender] >= _amount, "Insufficient allowance!");
        allowed[_from][msg.sender] -= _amount;
        balances[_from] -= _amount;
        balances[_to] += _amount;
        emit Transfer(_from, _to, _amount);
        return true;
    }

    function approve(address _spender, uint _amount) external returns (bool) {
        require(msg.sender != address(0) && _spender != address(0), "Wrong address!");
        allowed[msg.sender][_spender] += _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function reduceAllovance(address _spender, uint _amount) external returns(bool) {
        require(msg.sender != address(0) && _spender != address(0), "Wrong address!");
        allowed[msg.sender][_spender] -= _amount;
        return true;
    }

    // Bridge func

    function burnFromBridge(address _owner, uint _amount) external onlyBridge returns(bool) {
        require(balances[_owner] >= _amount, "Not enough funds!");
        balances[_owner] -= _amount;
        _totalSupply -= _amount;
        emit BridgeBurn(_owner, _amount);
        return true;
    }

    function mintFromBridge(address _owner, uint _amount) external onlyBridge returns(bool) {
        require(_owner != address(0), "Impossible mint to address zero!");
        balances[_owner] += _amount;
        _totalSupply += _amount;
        emit BridgeMint(_owner, _amount);
        return true;
    }
}