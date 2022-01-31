//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SafeToken.sol";


contract Airdrop {

    using SafeToken for address;

    struct Air {
        address to;
        uint256 amount;
    }
    function transferBatch( address _token, Air[] memory trs) external payable  {
        if (_token == address(0)) {
            for(uint i = 0; i < trs.length; i++) {
                SafeToken.safeTransferETH(trs[i].to, trs[i].amount);
            }
        } else {
            for(uint i = 0; i < trs.length; i++) {
                _token.safeTransferFrom(msg.sender, trs[i].to, trs[i].amount);
            }
        }
    }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ERC20Interface {
    function balanceOf(address user) external view returns (uint256);
}

library SafeToken {
    function myBalance(address token) internal view returns (uint256) {
        return ERC20Interface(token).balanceOf(address(this));
    }

    function balanceOf(address token, address user) internal view returns (uint256) {
        return ERC20Interface(token).balanceOf(user);
    }

    function safeApprove(address token, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "!safeApprove");
    }

    function safeTransfer(address token, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "!safeTransfer");
    }

    function safeTransferFrom(address token, address from, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "!safeTransferFrom");
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value:value}(new bytes(0));
        require(success, "!safeTransferETH");
    }
}