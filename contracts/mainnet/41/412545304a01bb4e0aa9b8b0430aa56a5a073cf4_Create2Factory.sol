/**
 *Submitted for verification at BscScan.com on 2023-02-02
*/

contract Create2Factory {
    event Deploy(address addr);
    // to deploy another contract using owner address and salt specified
   

    function deploy(bytes memory bytecode, uint _salt) external {
        address addr;
        assembly {
            addr := create2(0, add(bytecode, 0x20), mload(bytecode), _salt)
            if iszero(extcodesize(addr)) {
        revert(0, 0)
      }
    }

    emit Deploy(addr);
    }
}