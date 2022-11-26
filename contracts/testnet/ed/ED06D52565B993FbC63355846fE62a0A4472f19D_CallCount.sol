pragma solidity ^0.8.2;
pragma abicoder v2;
interface Count {
    function UpCount(uint256 _count) external;
}
contract CallCount {
    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('UpCount(uint256)')));
    function callCount(address _countAddress, uint256 _count) external payable{
        (bool success, bytes memory data) = address(Count(_countAddress)).delegatecall(abi.encodeWithSelector(SELECTOR, _count));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'Call Count: TRANSFER_FAILED');
    }
}