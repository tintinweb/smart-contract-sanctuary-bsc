/**
 *Submitted for verification at BscScan.com on 2022-09-30
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
}

interface IERC721 {
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}

interface IERC1155 {
    function balanceOf(address account, uint256 id) external view returns (uint256);
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;
}

contract AssetVault {
    bool public initialized;
    bool public withdrawEnabled;
    address public wNFTAddr;
    uint256 public wNFTId;

    struct NFTHolding {
        address tokenAddress;
        uint256 tokenId;
        uint256 amount; // default amount = 0 ===> ERC721
    }

    NFTHolding[] public bundleNFTHoldings;

    function initialize(address _wNFTAddr, uint256 _wNFTId) external {
        require(initialized == false, "AssetVault: already initialized");
        initialized = true;
        wNFTAddr = _wNFTAddr;
        wNFTId = _wNFTId;
    }

    modifier onlyOwner() {
        require(msg.sender == IERC721(wNFTAddr).ownerOf(wNFTId), "AssetVault: not owner");
        _;
    }

    modifier onlyWithdrawEnabled() {
        if (!withdrawEnabled) revert("AssetVault: withraw disabled");
        _;
    }

    modifier onlyWithdrawDisabled() {
        if (withdrawEnabled) revert("AssetVault: withraw enabled");
        _;
    }

    function enableWithdraw() external onlyOwner onlyWithdrawDisabled {
        withdrawEnabled = true;
    }

    function withdrawERC20(address token, address to) external onlyOwner onlyWithdrawEnabled {
        uint256 balance = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(to, balance);
    }

    function withdrawERC721(
        address token,
        uint256 tokenId,
        address to
    ) external onlyOwner onlyWithdrawEnabled {
        IERC721(token).safeTransferFrom(address(this), to, tokenId);
    }

    function withdrawERC1155(
        address token,
        uint256 tokenId,
        address to
    ) external onlyOwner onlyWithdrawEnabled {
        uint256 balance = IERC1155(token).balanceOf(address(this), tokenId);
        IERC1155(token).safeTransferFrom(address(this), to, tokenId, balance, "");
    }

    function withdrawAll() external onlyOwner onlyWithdrawEnabled {
        for (uint256 i = 0; i < bundleNFTHoldings.length; i++) {
            NFTHolding memory nft = bundleNFTHoldings[i];
            if (nft.amount == 0) {
                IERC721(nft.tokenAddress).safeTransferFrom(
                    address(this),
                    msg.sender,
                    nft.tokenId
                );
            } else {
                IERC1155(nft.tokenAddress).safeTransferFrom(
                    address(this),
                    msg.sender,
                    nft.tokenId,
                    nft.amount, "");
            }
        }
    }

    function onERC721Received(
        address,
        address,
        uint256 tokenId,
        bytes memory
    ) public returns (bytes4) {
        bundleNFTHoldings.push(NFTHolding(msg.sender, tokenId, 0));
        return this.onERC721Received.selector;
    }

    function onERC1155Received(
        address,
        address,
        uint256 tokenId,
        uint256 amount,
        bytes memory
    ) public returns (bytes4) {
        bundleNFTHoldings.push(NFTHolding(msg.sender, tokenId, amount));
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory
    ) public returns (bytes4) {
        require(ids.length == amounts.length, "invaild param");
        for (uint256 i= 0; i < ids.length; i++) {
            bundleNFTHoldings.push(NFTHolding(msg.sender, ids[i], amounts[i]));
        }
        return this.onERC1155BatchReceived.selector;
    }
}