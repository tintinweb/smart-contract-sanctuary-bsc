/**
 *Submitted for verification at BscScan.com on 2022-10-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

interface IERC20 {
    function transfer(address _to, uint256 _value) external returns (bool);
}


contract AbiEncode {
    function encodeWithSignature(address to, uint amount) internal pure returns (bytes memory)
    {
        // Typo is not checked - "transfer(address, uint)"
        return abi.encodeWithSignature("transfer(address,uint256)", to, amount);
    }

    function encodeWithSelector(address to, uint amount) internal pure returns (bytes memory)
    {
        // Type is not checked - (IERC20.transfer.selector, true, amount)
        return abi.encodeWithSelector(IERC20.transfer.selector, to, amount);
    }

    function encodeCall(address to, uint amount) internal pure returns (bytes memory) {
        // Typo and type errors will not compile
        return abi.encodeCall(IERC20.transfer, (to, amount));
    }
}


contract MyContract is AbiEncode {
   //IERC20 usdt = IERC20(address(0xe8453d3DBB2f2c9662eB88d01A476029d6d9EDb9)); // binance testnet
   bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));


    function _safeTransfer(address token, address to, uint value) public {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'UniswapV2: TRANSFER_FAILED');
    }


}