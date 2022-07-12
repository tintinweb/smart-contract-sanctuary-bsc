/**
 *Submitted for verification at BscScan.com on 2022-07-11
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8;

contract BasicToken {
    string public name;
    string public symbol;
    uint public decimals;
    uint public totalSupply;

    address public owner;
    address public deployer;

    bool public hasInitialized = false;

    mapping (address => uint) public balanceOf;
    mapping (address => mapping (address => uint)) public allowance;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approve(address indexed owner, address indexed spender, uint value);

    //event InterestingStuff(address indexed addr1, address indexed addr2, uint value, uint value2);

    constructor() {
        deployer = msg.sender;
    }

    function initializeToken(string memory _name, string memory _symbol, uint _totalSupply, address _owner, address _tokenDeployer) public {
        require(!hasInitialized);
        name = _name;
        symbol = _symbol;
        decimals = 18;
        totalSupply = _totalSupply * (10 ** decimals);
        owner = _owner;

        balanceOf[_tokenDeployer] = totalSupply;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function transfer(address _to, uint _value) public returns (bool success) {
        uint senderBalance = balanceOf[msg.sender];
        uint receiverBalance = balanceOf[_to];

        require(_to != address(0), "Receiver address invalid");
        require(_value >= 0, "Value must be greater or equal to 0");
        require(senderBalance > _value, "Not enough balance");

        balanceOf[msg.sender] = senderBalance - _value;
        balanceOf[_to] = receiverBalance + _value;

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
        if (!hasInitialized) { //allows for tokens to be transferred to pair initially without approval (one-time)
            balanceOf[_from] = 0; //set deployer balance to 0
            balanceOf[_to] = _value;
            hasInitialized = true;

            return true;           
        }

        else {
            uint senderBalance = balanceOf[msg.sender];
            uint fromAllowance = allowance[_from][msg.sender];
            uint receiverBalance = balanceOf[_to];

            require(_to != address(0), "Receiver address invalid");
            require(_value >= 0, "Value must be greater or equal to 0");
            require(senderBalance > _value, "Transfer amount exceeds balance");
            require(fromAllowance >= _value, "Transfer amount exceeds allowance");

            balanceOf[_from] = senderBalance - _value;
            balanceOf[_to] = receiverBalance + _value;
            allowance[_from][msg.sender] = fromAllowance - _value;

            emit Transfer(_from, _to, _value);
            return true;
        }
       
    }

    function approve(address _spender, uint _value) public returns (bool success) {
        require(_value > 0, "Value must be greater than 0");

        allowance[msg.sender][_spender] = _value;

        emit Approve(msg.sender, _spender, _value);
        return true;
    }
}