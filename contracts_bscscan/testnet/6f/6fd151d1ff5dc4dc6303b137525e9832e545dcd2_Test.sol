/**
 *Submitted for verification at BscScan.com on 2022-02-07
*/

interface IERC20Minimal {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract Test {
    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));

    function _safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'e2'
        );
    }

    function _safeTransfer2(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(IERC20Minimal.transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'e2');
    }

    function SafeTransfer1(address token, address to, uint256 value) public {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'e2');
    }

    function SafeTransfer2(address token, address to, uint256 value) public {
        _safeTransfer(token,to,value);
    }

    function SafeTransfer3(address token, address to, uint256 value) public {
        _safeTransfer2(token,to,value);
    }

}