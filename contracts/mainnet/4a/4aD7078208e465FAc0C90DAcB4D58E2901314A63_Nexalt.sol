/**
 *Submitted for verification at BscScan.com on 2022-09-21
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

contract Nexalt {

    string public _name; // Holds the name of the token
    string public _symbol; // Holds the symbol of the token
    uint8 public _decimals; // Holds the decimal places of the token
    uint256 public _totalSupply; // Holds the total suppy of the token
    uint256 public maxSupply; // Holds the max suppy of the token
    address payable public owner; // Holds the owner of the token

    /* This creates a mapping with all balances */
    mapping (address => uint256) public balanceOf;
    /* This creates a mapping of accounts with allowances */
    mapping (address => mapping (address => uint256)) public allowance;

    /* This event is always fired on a successfull call of the
       transfer, transferFrom, mint, and burn methods */
    event Transfer(address indexed from, address indexed to, uint256 value);
    /* This event is always fired on a successfull call of the approve method */
    event Approve(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        _name = "Nexalt"; // Sets the name of the token, i.e Ether
        _symbol = "XLT"; // Sets the symbol of the token, i.e ETH
        _decimals = 8; // Sets the number of decimal places
        uint256 _initialSupply = 1000 * 10 ** 8; // Holds an initial supply of coins
        uint256 _maxSupply = 100800000 * 10 ** 8; // Holds an initial supply of coins

        maxSupply = _maxSupply;

        /* Sets the owner of the token to whoever deployed it */
        owner = payable(msg.sender);

        balanceOf[owner] = _initialSupply; // Transfers all tokens to owner
        _totalSupply = _initialSupply; // Sets the total supply of tokens

        /* Whenever tokens are created, burnt, or transfered,
            the Transfer event is fired */
        emit Transfer(address(0), msg.sender, _initialSupply);
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function decimals() external view returns (uint8) {
    return _decimals;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function name() external view returns (string memory) {
    return _name;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
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

    function mint(uint256 _amount) external returns (bool success) {
        require(msg.sender == owner, "Operation unauthorised");
        _totalSupply += _amount;

        require(maxSupply >= _totalSupply , "Can't mint token limit excedes");

        balanceOf[msg.sender] += _amount;

        emit Transfer(address(0), msg.sender, _amount);
        return true;
    }
}