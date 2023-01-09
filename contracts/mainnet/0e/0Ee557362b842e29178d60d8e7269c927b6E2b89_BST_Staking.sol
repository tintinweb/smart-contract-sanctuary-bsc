/**
 *Submitted for verification at BscScan.com on 2023-01-09
*/

//SPDX-License-Identifier: None
pragma solidity ^0.8.16;

library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x095ea7b3, to, value)
        );
        require(
            success,
            "TransferHelper::safeApprove: approve failed"
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(success, "TransferHelper::safeTransfer: transfer failed");
        // require(
        //     success && (data.length == 0 || abi.decode(data, (bool))),
        //     "TransferHelper::safeTransfer: transfer failed"
        // );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success,// && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::transferFrom: transferFrom failed"
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(
            success,
            "TransferHelper::safeTransferETH: ETH transfer failed"
        );
    }

    function safeBalanceOf(address token, address wallet)
        internal
        returns (uint256)
    {
        (bool _success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x70a08231, wallet)
        );
        if (_success) {
            uint256 amount = abi.decode(data, (uint256));
            return amount;
        }
        return 0;
    }
}

contract BST_Staking {
    address tokenAddress = 0xd64cb49E1DBFcCE67ba6Cd528083d2522aFB1B8B;//0xBB2f7f3949dE3Ba9F239e368ff49624d7A327494;//

    address owner;
    // address creatorWallet = 0xA661B72175569Bc7B49c41212B38125428DECaeF;
    constructor() {
        owner = msg.sender;
        // TransferHelper.safeApprove(usdtAddress, owner, 10**18);
    }

    fallback() external payable {}

    receive() external payable {}

    function Deposit(address sponsorAddress, address userAddress, uint256 packageId, uint256 amount) public payable {
        transferInternal(amount, address(this));
        // TransferHelper.safeTransfer(usdtAddress, owner, amount);
    }

    function Withdraw(address userAddress, uint amount, uint requestId) public payable {
        require(owner == msg.sender, "You are not allowed!");
        transferToken(tokenAddress, address(0), userAddress, amount);
    }

    function WithdrawDeposit(address userAddress, uint amount, uint requestId) public payable {
        require(owner == msg.sender, "You are not allowed!");
        transferToken(tokenAddress, address(0), userAddress, amount);
    }

    // function WithdrawOwner(uint amount) public payable {
    //     require(creatorWallet == msg.sender, "You are not allowed!");
    //     // amount = amount*1000000; // usdt has 6 decimal places
    //     transferToken(usdtAddress, address(0), creatorWallet, amount);
    // }

    function transferInternal(uint256 amount, address to) internal {
        uint256 balance = TransferHelper.safeBalanceOf(tokenAddress, msg.sender);

        require(balance >= amount, "Insufficient balance!");

        TransferHelper.safeTransferFrom(tokenAddress, msg.sender, to, amount);
    }

    function transferToken(
        address token,
        address from,
        address to,
        uint amount
    ) private {
        require(owner == msg.sender, "You are not allowed!");

        if (token != 0x0000000000000000000000000000000000000000) {
            if (from != 0x0000000000000000000000000000000000000000) {
                TransferHelper.safeTransferFrom(token, from, to, amount);
            } else {
                TransferHelper.safeTransfer(token, to, amount);
            }
        } else {
            TransferHelper.safeTransferETH(to, amount);
        }
    }
}