/**
 *Submitted for verification at BscScan.com on 2022-06-07
*/

pragma solidity >=0.6.2 <0.7.0;
pragma experimental ABIEncoderV2;

contract HappyIndiaOrganization {
    string  public name = "Fund Token";                        // Sets the name for display purposes
    string  public symbol = "FND";                            // Sets the symbol for display purposes
    uint256 public totalSupply_ = 100000000;                //Updates total supply (100000 for example)

    uint8   public decimals = 18;
    address burnAddress = 0x0000000000000000000000000000000000000000;                         // Amount of decimals for display purposes
    address owner;
    uint8 voteThreshold = 200;

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

    struct CharityAccount {
        uint target_amount;
        string[] votes;
        string description;
        string proof;
        uint raised_amount;
        uint vote_count;
        bool is_activated;
        bool is_closed;
    }

    modifier onlyOwner {
      require(msg.sender == owner, "Only contract owner is permitted");
      _;
    }

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;
    mapping(address => CharityAccount) public charity_accounts;

    constructor() public {
        balances[msg.sender] = totalSupply_;
        owner = msg.sender;
    }
   
 /// return total amount of tokens
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }
   
 /// _owner The address from which the balance will be retrieved
    /// return The balance
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }
    
    /// sends a certain `_value` of token to `_to` from `msg.sender`
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value, "You have insufficient balance");
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
    
    /// `msg.sender` approves `_addr` to spend a certain `_value` tokens
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
	
	/// return amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
	}
	
    /// sends a certain `_value` of token to `_to` from `_from` 
	/// on the condition it is approved by `_from`
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balances[_from], "You have insufficient balance");
        require(_value <= allowed[_from][msg.sender], "you are not permitted to send that amount");
        balances[_from] -= _value;
        balances[_to] += _value;
        allowed[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
    
function setCharityAccount(address charityAddress, uint256 target_amount, string memory description, string memory proof ) public returns (bool success) {
        // charity_accounts[charityAddress] = CharityAccount( target_amount, votes, description, proof, raised_amount, vote_count, is_activated );
        charity_accounts[charityAddress].target_amount = target_amount;
        charity_accounts[charityAddress].description = description;
        charity_accounts[charityAddress].proof = proof;
        return true;
    }

    function getCharityAccount(address fundAddress) public view returns (CharityAccount memory c_account) {
        return charity_accounts[fundAddress];
    }

    function burn(uint _value) public onlyOwner returns (bool success) {
    //   owner = _owner;
        require(_value <= balances[msg.sender], "You don't have enough token to burn");
        balances[msg.sender] -= _value;
        emit Transfer(msg.sender, burnAddress, _value);
        return true;
    }
    
    function voteAccount(address fundAddress, uint voteValue, string memory voteHash, bool is_activated) public onlyOwner returns (bool success) {
        require(!charity_accounts[fundAddress].is_closed, "The account is closed for voting");
        charity_accounts[fundAddress].vote_count += voteValue;
        charity_accounts[fundAddress].votes.push(voteHash);
        charity_accounts[fundAddress].is_activated = is_activated;
        return true;
    }

    function closeAccount(address fundAddress) public onlyOwner returns (bool success) {
        require(charity_accounts[fundAddress].raised_amount >= charity_accounts[fundAddress].target_amount, "Account is not fully funded yet");
        require(!charity_accounts[fundAddress].is_closed, "Account is already closed");
        charity_accounts[fundAddress].is_closed = true;
        return true;
    }
    
    function activateAccount(address fundAddress) public onlyOwner returns (bool success) {
        require(charity_accounts[fundAddress].vote_count >= voteThreshold, "The threshold is not met yet");
        require(!charity_accounts[fundAddress].is_closed, "The account is closed for voting");
        charity_accounts[fundAddress].is_closed = true;
        return true;
    }

    function fundCharity(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balances[_from], "You have insufficient balance");
        require(_value <= allowed[_from][msg.sender], "You are not permitted to spend that amount");
        require(charity_accounts[_to].is_activated, "The account is not activated for funding yet");
        balances[_from] -= _value;
        balances[_to] += _value;
        charity_accounts[_from].raised_amount += _value;
        allowed[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
}