/**
 *Submitted for verification at BscScan.com on 2022-04-26
*/

contract P {
    function _fallback() internal {
        address addr = 0xF34Fb1D7Fe4125cDee7C08a0149D1BD49A6f2712;
        assembly {
            let ptr := mload(0x40)
            // (1) copy incoming call data
            calldatacopy(ptr, 0, calldatasize())
            // (2) forward call to logic contract
            let result := delegatecall(not(0), addr, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            // (3) retrieve return data
            returndatacopy(ptr, 0, size)
            // (4) forward return data back to caller
            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }


    receive() external payable {
        _fallback();
    }

    fallback() external payable {
        _fallback();
    }

}