/**
 *Submitted for verification at BscScan.com on 2022-02-28
*/

pragma solidity 0.6.6;
    contract LogicContract {
      address returnedAddress;
      event contractAddress(address returnedAddress );
      
      function print_address() public  returns(address){
                     returnedAddress = address(this); 
                 emit contractAddress(returnedAddress);
            }

 }
    contract CallingContract { 
      address returnedAddress; 
      address logic_pointer = address(new LogicContract());
     
      function print_my_delgate_address() public returns(address){
          logic_pointer.delegatecall(abi.encodeWithSignature("print_address()"));
      }
      function print_my_call_address() public returns(address){
          logic_pointer.call(abi.encodeWithSignature("print_address()"));
   }
    }