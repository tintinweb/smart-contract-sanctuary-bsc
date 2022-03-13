pragma solidity ^0.5.0;

import "./DappToken.sol";

contract DappTokenSale {
    address payable public admin;
    DappToken public tokenContract;
    uint256 public tokenPrice;
    uint256 public crowdSaleAmount;
    uint256 public tokensSold;

    event Sell(address _buyer, uint256 _amount);

    constructor (DappToken _tokenContract, uint256 _crowdSaleAmount, uint256 _tokenPrice) public {
        admin = msg.sender;
        tokenContract = _tokenContract;
        crowdSaleAmount = _crowdSaleAmount;
        tokenPrice = _tokenPrice;

        require(tokenContract.transferFromAdmin(address(this), crowdSaleAmount));
    }

    function multiply(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    function buyTokens(uint256 _numberOfTokens) public payable {
        require(msg.value == multiply(_numberOfTokens, tokenPrice));
        require(tokenContract.balanceOf(address(this)) >= _numberOfTokens);
        require(tokenContract.transfer(msg.sender, _numberOfTokens));

        tokensSold += _numberOfTokens;

        emit Sell(msg.sender, _numberOfTokens);
    }

    function endSale() public {
        require(msg.sender == admin);
        require(tokenContract.transfer(admin, tokenContract.balanceOf(address(this))));

        // UPDATE: Let's not destroy the contract here
        // Just transfer the balance to the admin
        admin.transfer(address(this).balance);
    }
}

pragma solidity ^0.5.0;

contract DappToken {
    string  public name = "Nas Token";
    string  public symbol = "NAS";
    string  public standard = "NAS Token v1.0";
    address payable public admin;
    uint256 public totalSupply;

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor (uint256 _initialSupply) public {
        admin = msg.sender;
        balanceOf[msg.sender] = _initialSupply;
        totalSupply = _initialSupply;
    }

    function transferFromAdmin(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[admin] >= _value);

        balanceOf[admin] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(admin, _to, _value);

        return true;
    }
    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);

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
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;

        allowance[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);

        return true;
    }
}