/**
 *Submitted for verification at BscScan.com on 2022-08-31
*/

// SPDX-License-Identifier: MIT
// ver1.2
pragma solidity >=0.7.0 <0.9.0;
interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
   }
contract ERC20Basic is IERC20 {
    string public constant name = "CyaToken";
    string public constant symbol = "CYA";
    uint8 public constant decimals = 18;
    address admin;
    address cyadex;
    bool dexup;
    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;
constructor() {
    admin=msg.sender;  }
   function cyadexup(address _cyadex)public{   
    require(admin==msg.sender,"no admin");
    require(dexup == false,"only one up");  
    cyadex = _cyadex;
    dexup = true;}
   
   function balanceOf(address tokenOwner) public override view returns (uint256) {
        return balances[tokenOwner]; }
   function transfer(address receiver, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender]-numTokens;
        balances[receiver] = balances[receiver]+numTokens;
        emit Transfer(msg.sender, receiver, numTokens);
        return true; }
   function approve(address owner, uint256 numTokens) public override returns (bool) {
        allowed[owner][msg.sender] = numTokens;
        emit Approval(owner, msg.sender, numTokens);
        return true; }
    function allowance(address owner, address delegate) public override view returns (uint) {
        return allowed[owner][delegate];
    }
    function mint() public {
        require(admin==msg.sender);
        balances[cyadex] += 1000000*1e18;  }
    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);

        balances[owner] = balances[owner]-numTokens;
        allowed[owner][msg.sender] = allowed[owner][msg.sender]+numTokens;
        balances[buyer] = balances[buyer]+numTokens;
        emit Transfer(owner, buyer, numTokens);
        return true;}
}