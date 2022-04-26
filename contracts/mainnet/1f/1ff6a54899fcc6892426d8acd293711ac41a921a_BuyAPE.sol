pragma solidity 0.8.11;

import "./GetStuck.sol";
import "./Ownable.sol";

interface APE {
    function walletOfOwner(address _owner)
        external
        view
        returns (uint256[] memory);

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function balanceOf(address owner) external view returns (uint256 balance);

    function tokenOfOwnerByIndex(address owner, uint256 index)
        external
        view
        returns (uint256 tokenId);

    function cost() external view returns (uint256 _cost);
}

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

contract BuyAPE is Ownable, GetStuck, IERC721Receiver {
    APE ape;

    constructor(APE _ape) public {
        ape = _ape;
    }

    function updateApe(APE _ape) public onlyOwner {
        ape = _ape;
    }

    function getBoughtIds(uint256 len)
        internal
        view
        returns (uint256[] memory)
    {
        uint256[] memory all = ape.walletOfOwner(address(this));

        uint256[] memory ids = new uint256[](all.length - len);
        uint256 index = 0;

        for (uint256 i = len; i < all.length; i++) {
            ids[index] = all[i];
            index++;
        }

        return ids;
    }

    function buyApe() public payable {
        address thisContract = address(this);
        uint256 len = ape.walletOfOwner(thisContract).length;

        (bool success, ) = address(ape).call{value: msg.value}(
            abi.encodeWithSignature("mint(uint256)", msg.value / ape.cost())
        );
        require(success, "Buy failed");

        uint256[] memory ids = getBoughtIds(len);

        for (uint256 i = 0; i < ids.length; i++) {
            ape.transferFrom(thisContract, msg.sender, ids[i]);
        }
    }

    function getStuckERC721(APE collection, uint256[] memory tokenIds)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            collection.transferFrom(address(this), owner(), tokenIds[i]);
        }
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    receive() external payable {
        buyApe();
    }
}