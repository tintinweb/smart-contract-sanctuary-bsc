// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;
pragma abicoder v2;

import "./Context.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./IERC1155.sol";
import "./IERC20.sol";
import "./Address.sol";
import "./Strings.sol";
import "./ReentrancyGuard.sol";

contract LaunchpadAirdrop is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using Address for address;
    using Strings for uint256;

    LaunchpadNFTERC1155Core private LaunchpadCore;
    IERC1155 private LaunchpadNFT;

    constructor(
        address _LaunchpadNFT
    )  {
        LaunchpadNFT = IERC1155(_LaunchpadNFT);
        LaunchpadCore = LaunchpadNFTERC1155Core(_LaunchpadNFT);
    }

    function onERC1155Received(address, address, uint256, uint256, bytes memory) public pure virtual returns (bytes32) {
        return this.onERC1155Received.selector;
    }

    function airdrop(string memory launchpad_id, address user, uint256 qty) public onlyOwner {
        require(qty > 0, "qty null");
        uint256 tokenId = LaunchpadCore.getLaunchpadToTokenId(launchpad_id);
        if (tokenId == 0) {
            tokenId = LaunchpadCore.getNextNFTId();
            LaunchpadNFTERC1155 memory launchpad = LaunchpadNFTERC1155(
                tokenId,
                launchpad_id,
                0,
                0,
                "",
                0,
                "",
                0,
                "",
                0,
                ""
            );
            LaunchpadCore.setNFTFactory(launchpad, tokenId);
        }
        LaunchpadCore.safeMintNFT(user, tokenId, qty);
    }

    function updateLaunchpadId(string memory launchpad_id, uint256 tokenId) public onlyOwner {
        require(tokenId > 0, "tokenId null");
        LaunchpadNFTERC1155 memory launchpad = LaunchpadNFTERC1155(
            tokenId,
            launchpad_id,
            0,
            0,
            "",
            0,
            "",
            0,
            "",
            0,
            ""
        );
        LaunchpadCore.setNFTFactory(launchpad, tokenId);
    }

    function sendNFT(uint256 tokenId, address user, uint256 qty) public {
        require(tokenId > 0, "tokenId null");
        require(user != address(0), "user is address 0");
        require(qty > 0, "qty is 0");
        LaunchpadNFT.safeTransferFrom(_msgSender(), user, tokenId, qty, "0x0");
    }
}