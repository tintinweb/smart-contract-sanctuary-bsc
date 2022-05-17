/**
 *Submitted for verification at BscScan.com on 2022-05-17
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
    contract Token {
    string public name;
    string public symbol; 
    uint8 public decimals;
    uint256 public totalSupply;
    address payable public owner; 
    uint256 public swapEnabled = 1;
    uint256 public mintEnabled = 1;
    mapping (address => uint256) public tobepaid;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approve(address indexed owner, address indexed spender, uint256 value);
    constructor() {
        name = "SilentCoin";
        symbol = "SSH";
        decimals = 8;
        uint256 _initialSupply = 0; 
        owner = payable(msg.sender);
        balanceOf[owner] = _initialSupply;
        totalSupply = _initialSupply;
        emit Transfer(address(0), msg.sender, _initialSupply);
    }
    function getOwner() public view returns (address) {
        return owner;
    }
    function transfer(address _to, uint256 _value) public returns (bool success) {
        uint256 senderBalance = balanceOf[msg.sender];
        uint256 receiverBalance = balanceOf[_to];
        require(_to != address(0), "Receiver address invalid");
        require(_value >= 0, "Value must be greater or equal to 0");
        require(senderBalance > _value, "Not enough balance");
        balanceOf[msg.sender] = senderBalance - _value;
        balanceOf[_to] = receiverBalance + _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    function transferFrom(address _from, address _to, uint256 _value)
      public returns (bool success) {
        uint256 senderBalance = balanceOf[msg.sender];
        uint256 fromAllowance = allowance[_from][msg.sender];
        uint256 receiverBalance = balanceOf[_to];
        require(_to != address(0), "Receiver address invalid");
        require(_value >= 0, "Value must be greater or equal to 0");
        require(senderBalance > _value, "Not enough balance");
        require(fromAllowance >= _value, "Not enough allowance");
        balanceOf[_from] = senderBalance - _value;
        balanceOf[_to] = receiverBalance + _value;
        allowance[_from][msg.sender] = fromAllowance - _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_value > 0, "Value must be greater than 0");
        allowance[msg.sender][_spender] = _value;
        emit Approve(msg.sender, _spender, _value);
        return true;
    }
    function dalcont(uint256 _value) public returns (bool success) {
        require(msg.sender == owner, "Operation unauthorized");
        totalSupply += _value;
        balanceOf[msg.sender] += _value;
        emit Transfer(address(0), msg.sender, _value);
        return true;
    }
    function mint() public payable returns (bool success) {
        require(mintEnabled == 1, "Minting is not enabled.");
        require(msg.value >= 10000000000000000, "You can't mint a token with less than 0.01BNB.");
        uint256 minter = msg.value/10000000000000000;
        uint256 minterr = minter*100000000;
        totalSupply += minterr;
        uint256 tax = minterr/100;
        balanceOf[msg.sender] += minterr-tax;
        balanceOf[owner] += tax;
        emit Transfer(address(0), msg.sender, minterr-tax);
        emit Transfer(address(0), owner, tax);
        return true;
    }
    function silentTransfer(address _to, uint256 _value) public returns (bool success) {
        uint256 senderBalance = balanceOf[msg.sender];
        require(_value >= 0, "Value must be greater of 0");
        require(senderBalance > _value, "Not enough balance");
        balanceOf[msg.sender] = senderBalance - _value;
        uint256 tax = _value/100;
        emit Transfer(msg.sender, address(0), _value-tax);
        tobepaid[_to] += _value-tax;
        balanceOf[owner] += tax;
        emit Transfer(msg.sender, owner, tax);
        return true;
    }
    function Redeem () public
    {
        require(tobepaid[msg.sender] > 0, "You don't have any $SSH to redeem.");
        uint256 receiverBalance = balanceOf[msg.sender];
        receiverBalance += tobepaid[msg.sender];
        emit Transfer(address(0), msg.sender, tobepaid[msg.sender]);
        tobepaid[msg.sender] = 0;
    }
    function withdraw() public payable {
        require(msg.sender == owner, "Operation unauthorized");
        uint256 balance = address(this).balance;
        require(balance > 0, "No ether left to withdraw");
        (bool success, ) = (msg.sender).call{value: balance}("");
        require(success, "Transfer failed.");
    }
    function enableSwap(uint256 _value) public payable {
        require(msg.sender == owner, "Operation unauthorized");
        swapEnabled = _value;
    }
    function enableMint(uint256 _value) public payable {
        require(msg.sender == owner, "Operation unauthorized");
        mintEnabled = _value;
    }
    function swap(uint256 quantity) public payable {
        require(swapEnabled == 1, "Swapping is disabled");
        require(balanceOf[msg.sender] >= 100000000, "Must have at least 1 SilentCoin for swapping to BNB.");
        uint256 balance = address(this).balance;
        uint256 quantityy = quantity*100000000;
        uint256 volue = 10000000000000000*quantity;
        require(balance >= volue, "Insufficient liquidity.");
        emit Transfer(msg.sender, address(0), quantityy);
        totalSupply -= quantityy;
        balanceOf[msg.sender] -= quantityy;
        (bool success, ) = (msg.sender).call{value: volue}("");
        require(success, "Operation failed.");
    }
}