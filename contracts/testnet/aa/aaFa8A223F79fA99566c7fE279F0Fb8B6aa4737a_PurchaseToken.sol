interface IBEP20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "./IBEP20.sol";

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract PurchaseToken {
    IBEP20 private token;
    uint256 price;
    address public owner;

    constructor(IBEP20 _tokenAddress, uint256 _price){
      require(_price >0, "Invalid Price");
      token = _tokenAddress;
      price = _price;
      owner = msg.sender;
    }
    modifier onlyOwner(){
        require(msg.sender ==owner,"NOt_Admin");
        _;
    }
   /**
    *  Events
    * @param sender Calleror Purchaser
    * @param bnbValue  is the value of BNB from that want to purchae token
    * @param totalToken  Total Number of SYS Token that they received
    */
 event PurchasedToken(address sender, uint256 bnbValue, uint256 totalToken);
 event SetPrice(address sender,uint256 _price);
 event WithdrawBNB(address owner, address _to, uint256 _amount);
 event WithdrawSYS(address sender, address _to,uint256  _amount);
 event ChangeToken(address sender,address _tokenAddress);


/**
 * @dev PurchaseToken Called when someone Purchase Token
 */
function purchaseToken()public payable{
    require(msg.value > price,"VALUE_MUST_GREATER_THEN_ZERO");  
    uint256 totalToken = calculatePrice(msg.value);
    token.transfer(msg.sender,totalToken);
    emit PurchasedToken(msg.sender, msg.value, totalToken);
}
/**
 * 
 * @dev calculatePrice is Actually calculating the amount of token for the amount that user want to puchase through BNB
 * @param _amount Amount of BNB to purchase Token
 */
function calculatePrice(uint256 _amount)public view returns(uint256){
    return _amount/price;  
}
/**
 * 
 * setPrice set price of SYS token accoding to BNB by Admin
 * @param _price set price of token in BNB
 */
function setPrice(uint256 _price)public onlyOwner{
   require(_price > 0,"Price Must be Greater than Zero");
   price = _price;
   emit SetPrice(msg.sender, _price);
}
/**
 * 
 * @param _to BNB Receiver Address
 * @param _amount Amount of BNB withdrawing
 */
function withdrawBNB(address _to, uint256 _amount) public onlyOwner{
    uint balance = address(this).balance;
   require(_amount >= balance,"Not enough Amount");
   payable(_to).transfer(_amount);
   emit WithdrawBNB(msg.sender, _to, _amount); 
}
/**
 * @dev WithdrawSYS Token of SYS token withdraw by owner
 * @param _to Token Transfered Address
 * @param _amount of Token that transfering
 */
function withdrawSYS(address _to ,uint256 _amount )public onlyOwner{
   uint balnace = token.balanceOf(address(this));
   require(balnace>= _amount,"Not Enough Balance found");
   token.transfer(_to, _amount);
   emit WithdrawSYS(msg.sender, _to, _amount);
}
/**
 * @dev change Token By Owner to sell Token
 * @param _tokenAddress new TokenAddress
 */
function changeToken(IBEP20 _tokenAddress)public onlyOwner{
    require(address(_tokenAddress) != address(0),"zero Address");
    token = _tokenAddress;
    emit ChangeToken(msg.sender, address(_tokenAddress));
}

fallback() external payable { }
receive() external payable{}


}