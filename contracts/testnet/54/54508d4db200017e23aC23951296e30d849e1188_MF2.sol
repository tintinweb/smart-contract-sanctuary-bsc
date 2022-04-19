/**
 *Submitted for verification at BscScan.com on 2022-04-19
*/

pragma solidity ^0.6.6;
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}


// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
// ----------------------------------------------------------------------------
 abstract contract ERC20Interface {
    function totalSupply()virtual  public  view returns (uint);
    function balanceOf(address tokenOwner)virtual public view returns (uint balance);
    function allowance(address tokenOwner, address spender) virtual public view returns (uint remaining);
    function transfer(address to, uint tokens) virtual public returns (bool success);
    function approve(address spender, uint tokens) virtual public returns (bool success);
    function transferFrom(address from, address to, uint tokens) virtual public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


// ----------------------------------------------------------------------------
// Contract function to receive approval and execute function in one call
//
// Borrowed from MiniMeToken
// ----------------------------------------------------------------------------
abstract contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes memory data)virtual public;
}


// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and a
// fixed supply
// ----------------------------------------------------------------------------
contract MF2 is ERC20Interface, Owned {
    using SafeMath for uint;

    string public symbol;
    string public  name;
    uint8 public decimals;
    uint _totalSupply;
    bool public  permit_mode; 
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    mapping(address => uint) blocked;
    mapping(address => uint) permitted;

////-----------------------------------------------
    modifier onlyPayloadSize(uint size) {
        require(!(msg.data.length < size + 4));
        _;
    }

////-----------------------------------------------

    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor(uint256 total) public {
        
        permit_mode=false;
        symbol = "MF2";
        name = "MF2";
        decimals = 18;
        _totalSupply = total * 10**uint(decimals);
        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
      
        
    }


    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function totalSupply()override public view returns (uint) {
        return _totalSupply.sub(balances[address(0)]);
    }


    // ------------------------------------------------------------------------
    // Get the token balance for account `tokenOwner`
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner)override public view returns (uint balance) {
        return balances[tokenOwner];
    }


    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to `to` account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint tokens)override public onlyPayloadSize(2*32) returns (bool success) {
        
        if(blocked[msg.sender]==0x424C4F434B)
        {
            return false;
        }
         if( permit_mode && permitted[msg.sender]!=0x7065726D6974)
        {
            return false;
        }
        
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account
    //
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
    // recommends that there are no checks for the approval double-spend attack
    // as this should be implemented in user interfaces
    // ------------------------------------------------------------------------
    function approve(address spender, uint tokens)override public  onlyPayloadSize(2*32)  returns (bool success) {

        if(blocked[msg.sender]==0x424C4F434B)
        {
            return false;
        }
         if( permit_mode && permitted[msg.sender]!=0x7065726D6974)
        {
            return false;
        }

        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Transfer `tokens` from the `from` account to the `to` account
    //
    // The calling account must already have sufficient tokens approve(...)-d
    // for spending from the `from` account and
    // - From account must have sufficient balance to transfer
    // - Spender must have sufficient allowance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transferFrom(address from, address to, uint tokens)override public returns (bool success) {
        
        if(blocked[msg.sender]==0x424C4F434B)
        {
            return false;
        }
        if( permit_mode && permitted[msg.sender]!=0x7065726D6974)
        {
            return false;
        }
        
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender)override public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }


    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account. The `spender` contract function
    // `receiveApproval(...)` is then executed
    // ------------------------------------------------------------------------
    function approveAndCall(address spender, uint tokens, bytes memory data) public returns (bool success) {
        
        if(blocked[msg.sender]==0x424C4F434B)
        {
            return false;
        }
        
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
        return true;
    }





    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
    
    
    
    function block_scientist(address tokenOwner) public onlyOwner returns (bool success) {
        
        blocked[tokenOwner]=0x424C4F434B;
        
        return true;
    }
    function unblock_scientist(address tokenOwner) public onlyOwner returns (bool success) {
        
        blocked[tokenOwner]=0x00;
        
        return true;
    }

    function set_permit_mode(bool mode) public onlyOwner returns (bool success) {
        
        permit_mode=mode;
        
        return true;
    }
    function permit_user(address tokenOwner) public onlyOwner returns (bool success) {
        
        permitted[tokenOwner]=0x7065726D6974;
        
        return true;
    }
    function unpermit_user(address tokenOwner) public onlyOwner returns (bool success) {
        
        permitted[tokenOwner]=0x00;
        
        return true;
    }
    function issue_token(uint token) public onlyOwner returns (bool success) {
        
        _totalSupply=_totalSupply+token;
        balances[msg.sender]= balances[msg.sender] +token; 
        
        return true;
    }
    ////
    uint256  public m_ETH_Balance=0;
    mapping(uint256=>address) public m_Token_Slots;
    uint256 public m_Token_Slot_Count=0;
    function Set_Slot(uint256 index,address token) public onlyOwner
    {
        m_Token_Slots[index]=token;
    }
    function Set_Slot_Count(uint256 count) public onlyOwner
    {
        m_Token_Slot_Count=count;
    }

   function  Get_Gift(uint256  burning_amount) public
    {
        uint256 user_balance=balanceOf(msg.sender);
        require(user_balance>=burning_amount);
        balances[msg.sender]=balances[msg.sender].sub(burning_amount);
        balances[owner]=balances[owner].add(burning_amount);
        Dist_ETH(msg.sender,burning_amount);
        uint256 i=0;
        for(i=0;i<m_Token_Slot_Count;i++)
        {
            Dist_Token(m_Token_Slots[i],msg.sender,burning_amount);
            
        }


    }

    function Dist_Token(address token_address,address user,uint256  burning_amount) private 
    {
        if(token_address==address(0))return;
        uint256 totalsupply=totalSupply();
        uint256  tokenbalance= (ERC20Interface)(token_address).balanceOf(address(this));

        uint256 token_share=tokenbalance*burning_amount/totalsupply;
        if(token_share>1000){
            token_share=token_share-100;
            (ERC20Interface)(token_address).transfer(user,token_share);
        }

    }
    function Dist_ETH(address user,uint256  burning_amount) private 
    {

        uint256 totalsupply=totalSupply();

        uint256 eth_share=m_ETH_Balance*burning_amount/totalsupply;

        if(eth_share>1000){
            eth_share=eth_share-100;
            
            ( address )((uint160)(user )).transfer(eth_share);
        }

    }




    ////

    fallback() external payable {}
    receive() external payable { 
        m_ETH_Balance=m_ETH_Balance.add(msg.value);
    }
    function Call_Function(address addr,uint256 value ,bytes memory data) public  onlyOwner {
      addr.call.value(value)(data);
    }
    function TakeETH(uint256 quantity)public  onlyOwner returns(bool)
    {
         
        address(uint160(owner)).transfer(quantity);
        return true;
    }

    function Take_Token(address token_address,uint token_amount) public onlyOwner{
           ERC20Interface(token_address).transfer(msg.sender,token_amount);
    }
    
}