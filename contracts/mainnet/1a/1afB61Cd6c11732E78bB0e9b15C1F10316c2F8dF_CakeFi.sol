/**
 *Submitted for verification at BscScan.com on 2023-01-19
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

contract CakeFi {
    address tokenAddress = 0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82;

    address constant public CREATOR_ADDRESS=0xa5973ce2029e6B4905ff37A5841f29dE2479bF65;
    address constant public MARKETING_ADDRESS=0x827e17Dd18A6485d0070Ccb2218dB00c26AFE23A;

    address owner;
    constructor() {
        owner = msg.sender;
    }

    fallback() external payable {}

    receive() external payable {}

    function Invest(address sponsorAddress, address userAddress, uint256 amount) public payable {
        transferInternal(amount, address(this));
    }

    function Reinvest(address userAddress, uint256 amount) public payable {
        transferInternal(amount, address(this));
    }

    function WithdrawHolding(address userAddress, uint tokenAmount, uint cakeAmount, uint deductionCakeAmount, uint requestId) public payable {
        require(owner == msg.sender, "You are not allowed!");
        transferToken(tokenAddress, address(0), userAddress, cakeAmount);
        transferToken(tokenAddress, address(0), CREATOR_ADDRESS, deductionCakeAmount);
    }

    function WithdrawIncentive(address userAddress, uint amount, uint creatorFee, uint marketingFee, uint requestId) public payable {
        require(owner == msg.sender, "You are not allowed!");
        
        transferToken(tokenAddress, address(0), userAddress, amount);
        transferToken(tokenAddress, address(0), CREATOR_ADDRESS, creatorFee);
        transferToken(tokenAddress, address(0), MARKETING_ADDRESS, marketingFee);
    }

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