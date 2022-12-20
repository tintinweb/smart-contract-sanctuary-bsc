/**
 *Submitted for verification at BscScan.com on 2022-12-19
*/

pragma solidity >=0.4.0 <0.7.0; contract MLMBusiness {
    // Define state variables
    uint totalSupply;
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) referral;
    mapping(address => mapping(address => uint)) allowed;

    // Events
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
    event ReferralAdded(address indexed _referrer, address indexed _referred);

    // Constructor
    constructor() public {
        totalSupply = 100000000;
    }
    /// @notice Function to get the balance of an address
/// @param _owner The address of the owner
/// @return The balance of the address
function balanceOf(address _owner) public view returns (uint) {
    return balances[_owner];
}
/// @notice Function to transfer tokens from one address to another
/// @param _from The address of the sender
/// @param _to The address of the recipient
/// @param _value The amount of tokens to be transferred
function transfer(address _from, address _to, uint _value) public {
    require(_from != address(0));
    require(_to != address(0));
    require(_value <= balances[_from]);
    balances[_from] -= _value;
    balances[_to] += _value;
    emit Transfer(_from, _to, _value);
}
/// @notice Function to allow an address to transfer tokens on behalf of another address
/// @param _owner The address of the owner
/// @param _spender The address of the spender
/// @param _value The amount of tokens to be approved
function approve(address _owner, address _spender, uint _value) public {
    require(_owner != address(0));
    require(_spender != address(0));
    allowed[_owner][_spender] = _value;
    emit Approval(_owner, _spender, _value);
}
/// @notice Function to transfer tokens from one address to another, taking the source address allowance into account
/// @param _from The address of the sender
/// @param _to The address of the recipient
/// @param _value The amount of tokens to be transferred
function transferFrom(address _from, address _to, uint _value) public {
    require(_from != address(0));
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    balances[_from] -= _value;
    allowed[_from][msg.sender] -= _value;
    balances[_to] += _value;
    emit Transfer(_from, _to, _value);
}
/// @notice Function to increase the allowance of an address
/// @param _spender The address of the spender
/// @param _addedValue The amount of tokens to be added
function increaseAllowance(address _spender, uint _addedValue) public {
    require(_spender != address(0));
    allowed[msg.sender][_spender] += _addedValue;
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
}
/// @notice Function to decrease the allowance of an address
/// @param _spender The address of the spender
/// @param _subtractedValue The amount of tokens to be subtracted
function decreaseAllowance(address _spender, uint _subtractedValue) public {
    require(_spender != address(0));
    require(_subtractedValue <= allowed[msg.sender][_spender]);
    allowed[msg.sender][_spender] -= _subtractedValue;
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
}
}