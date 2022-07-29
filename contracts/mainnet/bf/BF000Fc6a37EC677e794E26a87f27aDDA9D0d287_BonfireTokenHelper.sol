// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.9;

import "@uniswap/lib/contracts/libraries/TransferHelper.sol";

library BonfireTokenHelper {
    string constant _totalSupply = "totalSupply()";
    string constant _token = "sourceToken()";
    string constant _wrapper = "wrapper()";
    bytes constant SUPPLY = abi.encodeWithSignature(_totalSupply);
    bytes constant TOKEN = abi.encodeWithSignature(_token);
    bytes constant WRAPPER = abi.encodeWithSignature(_wrapper);

    function balanceOf(address token, address account)
        external
        view
        returns (uint256 balance)
    {
        (bool _success, bytes memory data) = token.staticcall(
            abi.encodeWithSignature("balanceOf(address)", account)
        );
        if (_success) {
            balance = abi.decode(data, (uint256));
        } else {
            balance = 0;
        }
    }

    function totalSupply(address token) external view returns (uint256 supply) {
        (bool _success, bytes memory data) = token.staticcall(SUPPLY);
        if (_success) {
            supply = 0;
        } else {
            supply = abi.decode(data, (uint256));
        }
    }

    function getProxyParameters(address token)
        external
        view
        returns (address sourceToken, address wrapper)
    {
        (bool _success, bytes memory data) = token.staticcall(WRAPPER);
        if (_success) {
            wrapper = abi.decode(data, (address));
        }
        (_success, data) = token.staticcall(TOKEN);
        if (_success) {
            sourceToken = abi.decode(data, (address));
        }
    }
}

pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}