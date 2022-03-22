// SPDX-License-Identifier: MIT


pragma solidity 0.6.12;
// import "./Pausable.sol";
import './Ownable.sol';
import "./BEP20.sol";


contract UFX_DirectExchange is Ownable {  
  
  /**  
  * @dev Details of each transfer * @param contract_ contract address of ER20 token to transfer * @param to_ receiving account * @param amount_ number of tokens to transfer to_ account * @param failed_ if transfer was successful or not */  
 
  /**  
  * @dev a mapping from transaction ID's to the sender address * that initiates them. Owners can create several transactions */  
  mapping(address => uint[]) public transactionIndexesToSender;  
  


  
  /**  
  * @dev list of all supported tokens for transfer * @param string token symbol * @param address contract address of token */  
  mapping(uint => address) public tokens;  
  BEP20 public BEP20Interface;  
  
  /**  
  * @dev Event to notify if transfer successful or failed * after account approval verified */  
  
  event TransferSuccessful(address indexed from_, address indexed to_, uint256 amount_);  
  event TransferFailed(address indexed from_, address indexed to_, uint256 amount_);  
  


  /**  
  * @dev add address of token to list of supported tokens using * token symbol as identifier in mapping */  
  function addNewToken(uint tokenNumber, address address_) public onlyOwner returns (bool) {  
    tokens[tokenNumber] = address_;  
    return true;  
  }  
 
  /**  
  * @dev remove address of token we no more support */  
  function removeToken(uint tokenNumber) public onlyOwner returns (bool) {  
      
    delete(tokens[tokenNumber]);  
    return true;  
  }  


  /**  
  * @dev method that handles transfer of BEP20 tokens to other address * it assumes the calling address has approved this contract * as spender * @param tokenNumber identifier mapping to a token contract address * @param to_ beneficiary address * @param amount_ numbers of token to transfer */  
  function transferTokens(uint tokenNumber, address to_, uint256 amount_) public {  
      
    require(amount_ > 0);  
  
    address contract_ = tokens[tokenNumber];  
    address from_ = msg.sender;  
  
    BEP20Interface = BEP20(contract_);  
  
  
  
    if(amount_ > BEP20Interface.allowance(from_, address(this))) {  
      emit TransferFailed(from_, to_, amount_);  
      revert();  
    }  
    BEP20Interface.transferFrom(from_, to_, amount_);  
  
  
    emit TransferSuccessful(from_, to_, amount_);  
  }  

  /**  
 * @dev allow contract to receive funds */  
 
    receive() external payable {}
  
  /**  
 * @dev withdraw funds from this contract * @param beneficiary address to receive ether */  
 function withdraw(address payable beneficiary) public payable onlyOwner  {  
  beneficiary.transfer(address(this).balance);  
 }
}