/**
 *Submitted for verification at BscScan.com on 2022-12-10
*/

pragma solidity ^0.5.0;

// ERC20 token contract
contract CacheToken {
    // Public variables of the token
    string public name = "Cache";
    string public symbol = "CAC";
    uint8 public decimals = 18;
    uint256 public totalSupply = 1000000 * 10 ** uint256(decimals);

    // Mapping from addresses to balances
    mapping (address => uint256) public balanceOf;

    // Mapping from addresses to allowances
    mapping (address => mapping (address => uint256)) public allowance;

    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // Functions
    function CacheTokenContract() public {
        // Initialize the contract with the total supply
        balanceOf[msg.sender] = totalSupply;
    }

    // Transfer tokens from one address to another
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value && _value > 0, "Insufficient balance or invalid value");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    // Approve another address to spend a certain amount of tokens on your behalf
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // Transfer tokens from one address to another on behalf of the approved address
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value && allowance[_from][msg.sender] >= _value && _value > 0, "Insufficient balance or allowance");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
}