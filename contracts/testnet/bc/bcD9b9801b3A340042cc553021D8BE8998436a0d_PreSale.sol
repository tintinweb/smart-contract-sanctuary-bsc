/**
 *Submitted for verification at BscScan.com on 2022-04-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IBEP20 {
  
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    }

interface IERC20 {

    function getReserves() external view returns (uint256 _reserve0, uint256 _reserve1, uint32 _blockTimestampLast);

    }

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}
contract Ownable  {

    address public _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    constructor()  {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }
    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }
    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract PreSale is Ownable{

    /////////////////////////////////////////

    IBEP20 public Token;
    IERC20 public LPToken;

    uint256 public minimum = 0.1 ether;
    uint256 public maximum = 12 ether;
    uint256 public softCap = 1500 ether;
    uint256 public hardCap = 3000 ether;
    bool public Start = false;
    uint256 public startTime;
    uint256 public totalSold;

    using SafeMath for uint256;
    
    uint256 public price = 0.009 ether;

    address public wallet = 0x3CdffCaaee6cd6924716ff57765f06046a0bE9e3;

    //    0xe997A97DcA4710bBc53CCA0c0093A939Ca58bAfc

    /////////////////////////////////////////


    constructor(IBEP20 _Token, IERC20 _LPToken ){
    LPToken = _LPToken ;
    Token = _Token;
    }

    function getVal() public view returns(uint256,uint256,uint256) {

    return LPToken.getReserves();

    }

    //FUNCTION TO CALCULATE TOKENS PRICE AGAINST BNB
    function calculate_price(uint256 _BNB_amount) public view returns(uint256) {

        (uint256 reservev0,uint256 reservev1,)=getVal();
        uint256 per_BNB= (reservev0.mul(1 ether).div(reservev1));
        uint256 perBUSD = _BNB_amount.mul(1 ether).div(price);
        uint TotalTOKEN = perBUSD.mul(per_BNB);
        return TotalTOKEN.div(1 ether);

    }

   // BUY FUNCTION TO BUY TOKEN BY BNB
    function buy() public payable {

        require(Start == true ,"Pre Sale not started yet" );
        uint tokens = calculate_price(msg.value);
        require(msg.value >= minimum || msg.value <= maximum,"Insuffienct funds");
        Token.transfer(msg.sender,tokens);

        totalSold += tokens;

    }

    // FUNCTION to SET PRICE OF TOKEN
    function setVal(uint256 _val) public onlyOwner {
        
        price = _val;

    }

    // FUNCTION TO CHANGE THE BNB WALLET 
    function changeWallet(address _recept) public onlyOwner{
        wallet = _recept;
    }

    // FUNCTION TO START THE PRESALE 
    function salestart() external onlyOwner{

        startTime = block.timestamp; 
        Start = true;
        
    }

    function stopSale(bool _hasstarted) external onlyOwner{
        require (Start!=_hasstarted,"Enough");
        Start=_hasstarted;
    }

    
    // FUNCTION TO WITHDRAW BNB
    function withdraw(uint256 _amount) public onlyOwner {

        payable(wallet).transfer(_amount);

    }

    /*

    LP TOKEN ADDRESS:
    0xf855e52ecc8b3b795ac289f85f6fd7a99883492b

    TOKEN ADDRESS:
    0x7e8ea2B90B916f3fAba56162E89A11dDD160aA49

    */

}