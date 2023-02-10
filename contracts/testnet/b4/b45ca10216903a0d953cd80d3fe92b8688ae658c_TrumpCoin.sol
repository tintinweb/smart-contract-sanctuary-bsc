/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

pragma solidity ^0.8.0;

contract TrumpCoin {
    // Public variables of the token
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public totalSupply;

    // Event that is fired when tokens are transferred
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    // Event that is fired when ownership is renounced
    event OwnershipRenounced(address indexed previousOwner);

    // Mapping from addresses to balances
    mapping(address => uint256) public balances;

    // Owner of the contract
    address public owner;

    // Constructor function
    constructor(
        uint256 initialSupply,
        string memory tokenName,
        string memory tokenSymbol
    ) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balances[msg.sender] = totalSupply;
        name = tokenName;
        symbol = tokenSymbol;
        owner = msg.sender;
    }

    // Transfer function
    function transfer(address _to, uint256 _value) public returns (bool) {
        // Check if the sender has enough
        require(balances[msg.sender] >= _value, "Not enough balance");
        // Check if the receiver is not the zero address
        require(_to != address(0), "Receiver address is 0x0");
        // Transfer the tokens
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    // Function to check the balance of an address
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

    // Mint function
    function mint(address _to, uint256 _value) public onlyOwner {
        require(_to != address(0), "Receiver address is 0x0");
        totalSupply += _value;
        balances[_to] += _value;
        emit Transfer(address(0), _to, _value);
    }

    // Renounce ownership function
    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(owner);
        owner = address(0);
    }

    // Access control function
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }
}