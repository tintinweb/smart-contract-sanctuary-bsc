/**
 *Submitted for verification at BscScan.com on 2022-04-19
*/

contract Proxy{
    address public implementation;
    function setImplementation(address implementation_) public{
        implementation = implementation_;
    }
    function getImplementation() public view returns (address){
        return implementation;
    }
    fallback() external{
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr,0,calldatasize())
            let result := delegatecall(
                gas(),
                sload(implementation.slot),
                ptr,
                calldatasize(),
                0,
                0
            )

            let size :=returndatasize()
            returndatacopy(ptr,0,size)
            switch result
            case 0 {
                revert(ptr,size)
            }
            default {
                return(ptr,size)
            }
        }
    }
}