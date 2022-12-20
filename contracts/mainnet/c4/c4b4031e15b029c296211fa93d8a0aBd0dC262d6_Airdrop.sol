/**
 *Submitted for verification at BscScan.com on 2022-12-20
*/

// SPDX-License-Identifier: NOVACLUB

pragma solidity ^0.8.17;

library TransferHelper {
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
}

contract Airdrop {
    address public owner = 0x7BD284BeDcBeD337874768701490CE1F64033B60;

    modifier onlyOwner() {
        require(msg.sender == owner, "caller is not the owner");
        _;
    }

    function happyNewYearSir(uint256 _amount, address _token, address _from, address[] memory _users) external onlyOwner {
        for (uint256 i=0; i<_users.length; ++i) {
            TransferHelper.safeTransferFrom(_token, _from, _users[i], _amount);
        }
    }

    function withdraw(address _token, uint256 _amount) external onlyOwner {
        if (_token != address(0)) {
            TransferHelper.safeTransfer(_token, owner, _amount);
        } else{
            payable(owner).transfer(address(this).balance);
        }
    }
}