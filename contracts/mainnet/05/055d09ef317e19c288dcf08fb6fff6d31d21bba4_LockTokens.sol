/**
 *Submitted for verification at BscScan.com on 2023-01-28
*/

// SPDX-License-Identifier: MIT

// First try to create a token lock

pragma solidity >=0.6.0;

library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
}

library TransferLib {
    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferLib: ETH_TRANSFER_FAILED');
    }
    function safeTransferFrom(address token, address from, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }
    function safeTransfer(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }
}

interface LockToken {
    function lock_tokens(address token, uint value) payable external returns (bool);

    function withdraw(uint lock_id) external returns (bool);
}

contract LockTokens is LockToken {

    struct LockParams{
        address tokenAddress;
        address ownerAddress;
        uint256 id_lock;
        uint256 depositedValue;
        bool Withdrawed;
    }

    uint256 public finnaly_id = 0;

    mapping(uint256 => LockParams) public LOCK;

    using SafeMath for uint;

    address public Owner;
    constructor() {
        Owner = msg.sender;
    }

    function lock_tokens(address token, uint value) 
        external
        virtual
        override
        payable
        returns (bool)
    {
        require(msg.value > 9999999999999999, 'No money no funny');
        TransferLib.safeTransferETH(address(0xfF8014A802cE653aBCa0c51C8774f7A7705E458D), msg.value);
        TransferLib.safeTransferFrom(token,address(msg.sender),address(this), value);

        LockParams memory data_lock;
        data_lock.tokenAddress = token;
        data_lock.ownerAddress = msg.sender;
        data_lock.id_lock = finnaly_id;
        data_lock.depositedValue = value;
        data_lock.Withdrawed = false;

        LOCK[finnaly_id] = data_lock;
        finnaly_id ++;
        return true;
    }

    function withdraw(uint256 lock_id)
        external
        virtual
        override
        returns (bool)
    {
        LockParams storage userLock = LOCK[lock_id];
        require(userLock.ownerAddress == msg.sender, 'You are not the owner');
        require(userLock.Withdrawed != true, 'u cant destroy the system');
        TransferLib.safeTransfer(userLock.tokenAddress, userLock.ownerAddress, userLock.depositedValue);

        userLock.Withdrawed = true;
        return true;
    }
}