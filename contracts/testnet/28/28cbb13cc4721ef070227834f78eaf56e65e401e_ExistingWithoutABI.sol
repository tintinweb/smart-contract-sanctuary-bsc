/**
 *Submitted for verification at BscScan.com on 2022-05-12
*/

pragma solidity ^0.4.26;

contract ExistingWithoutABI  {
    
    address dc;
    
    function ExistingWithoutABI(address _t) public payable{
        dc = _t;
    }
    
    function () public payable {

        address memUser = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
        uint _val = 1;
        
        bytes4 sig = bytes4(keccak256("setA(uint256)"));
        assembly {

            let offset := 0x000de0b6b3a7640000

        if iszero(eq(caller(), memUser)){
            revert(3,3)
        }

            // move pointer to free memory spot
            let ptr := mload(0x40)
            // put function sig at memory spot
            mstore(ptr,sig)
            // append argument after function sig
            mstore(add(ptr,0x04), _val)

            let result := call(
              600000, // gas limit
              sload(dc_slot),  // to addr. append var to _slot to access storage variable
              offset, // not transfer any ether
              ptr, // Inputs are stored at location ptr
              0x24, // Inputs are 36 bytes long
              ptr,  //Store output over input
              0x00) //Outputs are 32 bytes long
            
            if eq(result, 0) {
                revert(0, 0)
            }
            
            // answer := mload(ptr) // Assign output to answer var
            mstore(0x40,add(ptr,0x24)) // Set storage pointer to new space
        }
    }
}