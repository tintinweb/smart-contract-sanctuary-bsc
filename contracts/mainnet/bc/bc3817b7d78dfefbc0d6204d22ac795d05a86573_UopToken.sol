/**
 *Submitted for verification at BscScan.com on 2023-01-29
*/

pragma solidity ^0.7.0;

contract UopToken {
    address payable owner;
    mapping (address => uint256) public balanceOf;
    uint256 public totalSupply;
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public buyFee = 5;
    uint256 public sellFee = 5;
    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor() public {
        owner = msg.sender;
        totalSupply = 1000000;
        balanceOf[owner] = totalSupply;
        name = "UopToken";
        symbol = "UOP";
        decimals = 18;
    }

    function mint(address payable to, uint256 _value) public {
        require(msg.sender == owner, "Only owner can mint tokens.");
        require(_value > 0, "Cannot mint 0 tokens.");
        balanceOf[to] += _value;
        totalSupply += _value;
        emit Transfer(address(0), to, _value);
    }

    function burn(address payable from, uint256 _value) public {
        require(msg.sender == owner, "Only owner can burn tokens.");
        require(_value > 0, "Cannot burn 0 tokens.");
        require(_value <= balanceOf[from], "Insufficient balance.");
        balanceOf[from] -= _value;
        totalSupply -= _value;
        emit Transfer(from, address(0), _value);
    }

    function buy(address payable to, uint256 _value) public payable {
        require(_value > 0, "Cannot buy 0 tokens.");
        require(msg.value >= _value * (1 + buyFee / 100), "Insufficient ETH.");
        uint256 tokens = _value * (1 - buyFee / 100);
        balanceOf[to] += tokens;
        totalSupply += tokens;
        emit Transfer(address(0), to, tokens);
        owner.transfer(msg.value - tokens);
    }

    function sell(address payable from, uint256 _value) public {
        require(_value > 0, "Cannot sell 0 tokens.");
        require(_value <= balanceOf[from], "Insufficient balance.");
        uint256 tokens = _value * (1 - sellFee / 100);
        balanceOf[from] -= tokens;
        totalSupply -= tokens;
        emit Transfer(from, address(0), tokens);
        msg.sender.transfer(tokens);
    }

}