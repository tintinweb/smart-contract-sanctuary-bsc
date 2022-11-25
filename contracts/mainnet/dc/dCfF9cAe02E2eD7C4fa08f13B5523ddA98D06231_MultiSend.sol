/**
 *Submitted for verification at BscScan.com on 2022-11-25
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract MultiSend {
    address public owner;
    constructor(){
        owner = msg.sender;
    }

    function sendETH(address[] memory tos, uint256 perAmount) external payable {
        uint256 len = tos.length;
        require(msg.value >= perAmount * len, "eth not enough");
        for (uint256 i; i < len;) {
            safeTransferETH(tos[i], perAmount);
        unchecked{
            ++i;
        }
        }
    }

    function sendETHs(address[] memory tos, uint256[] memory amounts) external payable {
        uint256 len = tos.length;
        uint256 totalAmount;
        for (uint256 i; i < len;) {
            safeTransferETH(tos[i], amounts[i]);
            totalAmount += amounts[i];
        unchecked{
            ++i;
        }
        }
        require(msg.value >= totalAmount, "eth not enough");
    }

    function sendToken(address token, address[] memory tos, uint256 perAmount) external {
        uint256 len = tos.length;
        safeTransferFrom(token, msg.sender, address(this), perAmount * len);
        for (uint256 i; i < len;) {
            safeTransfer(token, tos[i], perAmount);
        unchecked{
            ++i;
        }
        }
    }

    function sendTokenV2(address token, address[] memory tos, uint256 perAmount) external {
        uint256 len = tos.length;
        address sender = msg.sender;
        for (uint256 i; i < len;) {
            safeTransferFrom(token, sender, tos[i], perAmount);
        unchecked{
            ++i;
        }
        }
    }

    function sendTokens(address token, address[] memory tos, uint256[] memory amounts) external {
        uint256 len = tos.length;
        address sender = msg.sender;
        for (uint256 i; i < len;) {
            safeTransferFrom(token, sender, tos[i], amounts[i]);
        unchecked{
            ++i;
        }
        }
    }

    function claimETH(uint256 amount) external {
        owner.call{value : amount}(new bytes(0));
    }

    function claimToken(address token, uint256 amount) external {
        token.call(abi.encodeWithSelector(0xa9059cbb, owner, amount));
    }

    receive() external payable {}

    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TAF');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TTF');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TTFF');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value : value}(new bytes(0));
        require(success, 'TF');
    }
}