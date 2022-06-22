/**
 *Submitted for verification at BscScan.com on 2022-06-22
*/

pragma solidity ^0.5.17;

/**/

contract BabyElon100M 
{
    /* Triggered when tokens are transferred. */
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
  
    /* Triggered whenever approve(address _spender, uint256 _value) is called. */
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    /* This notifies clients about the amount burned */
    event Burn(address indexed from, uint256 value);
    
    /* And we begin: */
    string public constant symbol = "BABYELON100M";
    string public constant name = "BABY ELON 100M";
    uint8 public constant decimals = 18;
    uint256 _totalSupply = 1000000000000000000000000;    // 1,000,000 tokens with 18 decimal places.
    uint256 _totalBurned = 0;                            // Total burned initially starts at 0.
     
    /* The owner of this contract (initial address) */
    address public owner;
  
    /* Dictionary containing balances for each account */
    mapping(address => uint256) balances;
  
    /* Owner of account can approve (allow) the transfer of an amount to another account */
    mapping(address => mapping (address => uint256)) allowed;
  
     /* Constructor, this function only gets called once, when the contract is deployed. */
     constructor() public
     {
        owner = msg.sender;
        balances[owner] = _totalSupply;
     }
  
     function totalSupply() public view returns (uint256 l_totalSupply) 
     {
        l_totalSupply = _totalSupply;
     }

     function totalBurned() public view returns (uint256 l_totalBurned)
     {
        l_totalBurned = _totalBurned;
     }
  
     /* What is the balance of a particular account? */
     function balanceOf(address _owner) public view returns (uint256 balance) 
     {
        return balances[_owner];
     }
  
     /* Transfer the balance from owner's account to another account. */
     function transfer(address _to, uint256 _amount) public returns (bool success) 
     {  /* Prevents transferring to 0x0 addresses. Use burn() instead. */
        require(_to != address(0), "error: will not allow sending to 0x0 address, use burn().");  
        if (balances[msg.sender] >= _amount && _amount > 0 && balances[_to] + _amount > balances[_to]) 
        {
            balances[msg.sender] -= _amount;
            balances[_to] += _amount;
            emit Transfer(msg.sender, _to, _amount);
            return true;
         } 
         else
         {
            return false;
         }
     }
  
     function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success) 
     {  /* Prevents transferring to 0x0 addresses. Use burn() instead. */
        require(_to != address(0), "error: will not allow sending to 0x0 address.");
        if (balances[_from] >= _amount && allowed[_from][msg.sender] >= _amount && _amount > 0 && balances[_to] + _amount > balances[_to]) 
        {
            balances[_from] -= _amount;
            allowed[_from][msg.sender] -= _amount;
            balances[_to] += _amount;
            emit Transfer(_from, _to, _amount);
            return true;
         } 
         else 
         {
            return false;
         }
     }
  
     /*  Allow _spender to withdraw from your account, multiple times, up to the _value amount. 
          If this function is called again it overwrites the current allowance with _value. */
     function approve(address _spender, uint256 _amount) public returns (bool success) 
     {
        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
     }
  
     /* Is the _spender allowed to spend on the behalf of _owner? */ 
     function allowance(address _owner, address _spender) public view returns (uint256 remaining) 
     {
        return allowed[_owner][_spender];
     }
    
    /* Burn! */
    function burn(uint256 _value) public returns (bool success) 
    {
        if (balances[msg.sender] < _value) revert();            // Check if the sender has enough
        balances[msg.sender] -= _value;                        // Subtract from the sender
        /* Updating indicator variables */
        _totalSupply -= _value;          
        _totalBurned += _value;                             
        /* Send the event notification */
        emit Burn(msg.sender, _value);
        return true;
    }

    function burnFrom(address _from, uint256 _value) public returns (bool success) 
    {
        if (balances[_from] < _value) revert();                // Check if the sender has enough
        if (_value > allowed[_from][msg.sender]) revert();    // Check allowance
        balances[_from] -= _value;                           // Subtract from the sender
        /* Updating indicator variables */
        _totalSupply -= _value;                           
        _totalBurned += _value;
        /* Send the event notification */
        emit Burn(_from, _value);
        return true;
    }
 }