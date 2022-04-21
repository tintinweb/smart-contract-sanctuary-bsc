/**
 *Submitted for verification at BscScan.com on 2022-04-21
*/

contract Manager {
    function generateHash(uint count) external view returns (bytes32) {
        return keccak256(abi.encodePacked(msg.sender, count));
    }
}