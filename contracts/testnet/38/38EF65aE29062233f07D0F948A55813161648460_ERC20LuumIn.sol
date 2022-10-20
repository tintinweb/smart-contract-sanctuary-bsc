// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;
import "./SafeMath.sol";


interface IERC20{
    function totalSupply() external view returns (uint256);
    function balanceOf (address account) external view returns (uint256);
    function allowance(address owner,address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferencia_SDV(address sender, address recipient, uint256 amount) external returns (bool);
    function approve (address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    
    event Burn(address indexed from, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval (address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
}

contract ERC20LuumIn is IERC20 {
    string public constant name = "LUUM IN";
    string public constant symbol = "LUUM";
    uint256 public constant decimals = 18;
    uint256 private totalSupply_;
    address private _owner;

    modifier onlyOwner{
         require(msg.sender == _owner, "Only the owner can execute this function.");
         _;
    }
    
    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    
    mapping (address => uint256) balances;
    mapping(address => mapping (address => uint)) allowed;
    
    using SafeMath for uint256;
    
    constructor (uint256 total) public{
        totalSupply_ = total * 10 ** decimals;
        balances[msg.sender] = totalSupply_;
        _owner = msg.sender;

        emit Transfer(address(0),msg.sender, totalSupply_);
    }
    
    function totalSupply() public override view returns (uint256){
        return totalSupply_;
    }
    
    function increaseTotalSuply(uint newTokens) public{
        totalSupply_ += newTokens;
        balances[msg.sender] += newTokens;
    }
    
    function balanceOf (address tokenOwner) public override view returns (uint256){
        return balances[tokenOwner];
    }
    
    function transfer(address receiver, uint256 numTokens) public override returns (bool){
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(msg.sender,receiver,numTokens);
        return true;
    } 
    
    function transferencia_SDV(address sender, address receiver, uint256 numTokens) public override returns (bool){
        require(numTokens <= balances[sender]);
        balances[sender] = balances[sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(sender,receiver,numTokens);
        return true;
    } 
    
    function approve (address delegate, uint256 numTokens) public override returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }
    
    function allowance (address owner, address delegate) public override view returns (uint){
        return allowed[owner][delegate];
    }
    
    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool){
        require (numTokens <= balances[owner]);
        require (numTokens <= allowed[owner][msg.sender]);
        
        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        emit Transfer(owner,buyer,numTokens);
        return true;
    }

    function mint (uint256 value) public onlyOwner returns (bool) {
        require(msg.sender == _owner, "Only owner can mint new tokens");
        uint256 amount = value * 10 ** 18;
        totalSupply_ += amount;
        balances[_owner] += amount;
        emit Transfer(address(0), _owner, amount);
        return true;
    }

     function _burn(uint256 value) internal onlyOwner returns (bool) {
      uint256 amount = value * 10 ** 18;
      require(balances[_owner] >= amount,"amount exceeded" );
      totalSupply_ = totalSupply_.sub(amount);
      balances[_owner] = balances[_owner].sub(amount);
      emit Burn(msg.sender, amount);
      return true;
    }

    function burn(uint256 amount) public {
        _burn(amount);
    }

    function _transferOwnership(address _newOwner) internal {
        require(_newOwner != address(0));
        balances[_newOwner] = balances[_owner];
        balances[_owner] = 0;
        emit OwnershipTransferred(_owner, _newOwner);
        _owner = _newOwner;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        _transferOwnership(_newOwner);
     }
    
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;


// Implementacion de la libreria SafeMath para realizar las operaciones de manera segura
// Fuente: "https://gist.github.com/giladHaimov/8e81dbde10c9aeff69a1d683ed6870be"

library SafeMath{
    // Restas
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }
    
    // Sumas
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }
    
    // Multiplicacion
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
}