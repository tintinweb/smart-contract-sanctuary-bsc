/**
 *Submitted for verification at BscScan.com on 2023-01-10
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



contract DKdAK is Context, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private AGX;
    mapping (address => mapping (address => uint256)) private DGX;
    uint8 EGX = 8;
    uint256 FGX = 100*10**8;
    string name = "DKdKA";
    string symbol = "DdKKA";



    constructor () 
{   AGX[msg.sender] = 100;
 AGX[msg.sender] = FGX;
   emit Transfer(address(0),msg.sender, FGX); } 

    


    function decimals() public view returns (uint8) {
        return EGX;
    }

    function totalSupply() public view  returns (uint256) {
        return FGX;
    }

    function balanceOf(address account) public view  returns (uint256) {
        return AGX[account];
    }
	 function allowance(address owner, address spender) public view  returns (uint256) {
        return DGX[owner][spender];
    }
	

function approve(address spender, uint256 amount) public returns (bool success) {    
        DGX[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true; }

			   
  		
    function transfer(address recipient, uint256 amount) public returns (bool) {
}
 
	   
	   
    function transferFrom(address sender, address recipient, uint256 amount) public returns
     (bool) {}
	

 

}