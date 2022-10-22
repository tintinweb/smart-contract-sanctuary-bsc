/**
 *Submitted for verification at BscScan.com on 2022-10-21
*/

pragma solidity ^0.8.5;

interface IToken {
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
}
contract test {
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) public {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FROM_FAILED"
        );
    }

    function transferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) public {
        IToken(token).transferFrom(from, to, value);
    }
}