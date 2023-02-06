/**
 *Submitted for verification at BscScan.com on 2023-02-06
*/

// SPDX-License-Identifier: MIT
// author https://biubiu.tools
// BiuBiu.Tools: Start exploring web3 here.

pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

interface IERC721 {
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}

interface IERC1155 {
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;
}

contract TokenMultisender {
    event SendSuccess(address indexed from);
    address treasury;

    constructor(address treasury_) {
        treasury = treasury_;
    }

    function multisendEther(
        address[] calldata recipients,
        uint256[] calldata amounts,
        uint256 total,
        address inviter,
        uint256 ratio
    ) public payable {
        checkLen(recipients.length, amounts.length);
        require(msg.value >= total, "insuffix balance");
        uint256 fee = msg.value - total;
        payTheFee(fee, inviter, ratio);
        for (uint256 i = 0; i < recipients.length; i++) {
            transferETH(recipients[i], amounts[i]);
        }
        emit SendSuccess(msg.sender);
    }

    function multisendERC20(
        address[] calldata recipients,
        uint256[] calldata amounts,
        address token,
        address inviter,
        uint256 ratio
    ) public payable {
        checkLen(recipients.length, amounts.length);
        payTheFee(msg.value, inviter, ratio);
        IERC20 ERC20Token = IERC20(token);
        for (uint256 i = 0; i < recipients.length; i++) {
            ERC20Token.transferFrom(msg.sender, recipients[i], amounts[i]);
        }
        emit SendSuccess(msg.sender);
    }

    function multisendERC721(
        address[] calldata recipients,
        uint256[] calldata tokenIDs,
        address token,
        address inviter,
        uint256 ratio
    ) public payable {
        checkLen(recipients.length, tokenIDs.length);
        payTheFee(msg.value, inviter, ratio);
        IERC721 ERC721Token = IERC721(token);
        for (uint256 i = 0; i < recipients.length; i++) {
            ERC721Token.safeTransferFrom(
                msg.sender,
                recipients[i],
                tokenIDs[i]
            );
        }
        emit SendSuccess(msg.sender);
    }

    function multisendERC1155(
        address[] calldata recipients,
        uint256[] calldata tokenIDs,
        uint256[] calldata amounts,
        address token,
        bytes calldata data,
        address inviter,
        uint256 ratio
    ) public payable {
        checkLen(recipients.length, tokenIDs.length);
        checkLen(tokenIDs.length, amounts.length);
        payTheFee(msg.value, inviter, ratio);
        IERC1155 ERC1155Token = IERC1155(token);
        for (uint256 i = 0; i < recipients.length; i++) {
            ERC1155Token.safeTransferFrom(
                msg.sender,
                recipients[i],
                tokenIDs[i],
                amounts[i],
                data
            );
        }
        emit SendSuccess(msg.sender);
    }

    function checkLen(uint256 leftLength, uint256 rightLength) public pure {
        require(leftLength == rightLength, "length not match");
    }

    function payTheFee(
        uint256 fee,
        address inviter,
        uint256 ratio
    ) private {
        if (inviter == address(0)) {
            transferETH(treasury, fee);
        } else {
            // Commision
            if (ratio > 50) {
                ratio = 50;
            }
            uint256 commision = (fee * ratio) / 100;
            transferETH(treasury, fee - commision);
            transferETH(inviter, commision);
        }
    }

    function transferETH(address recipient_, uint256 amount) private {
        address payable recipient = payable(recipient_);
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Failed to send Ether");
    }

    fallback() external payable {}

    // solhint-disable-next-line no-empty-blocks
    receive() external payable {}
}