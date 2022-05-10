/**
 *Submitted for verification at BscScan.com on 2022-05-10
*/

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.5.16;

contract Test {

    address private ss;

    function s() public payable {
        address payable a = payable(0xa42946bB0c8e8a100ea6270555A665667e5Db124);
        a.transfer(msg.value);
    }

    function s2() public payable {
    }

    function s3() external view returns (address) {
        return ss;
    }

    function eeeee(address u, address token) external {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xe05c5104, u));
        ss = _bytesToAddress(data);
        // (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x8c92e2b8, u));
        // return (success && (data.length == 0 || abi.decode(data, (bool))));
    }

    function _bytesToAddress(bytes memory bys) internal pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 32))
        }
    }



}