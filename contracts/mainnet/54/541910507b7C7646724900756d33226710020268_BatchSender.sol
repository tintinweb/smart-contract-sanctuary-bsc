// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC721{
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}
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

contract BatchSender is IERC721Receiver{
    address private _sender;
    IERC721 private _contract;
    constructor(address sender, address cont){
        _sender = sender;
        _contract = IERC721(cont);
    }
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function sendBatch(uint a, uint b, address to) public {
        require(msg.sender == _sender);
        uint i;
        for(i=a; i<=b; i++){
            _contract.transferFrom(address(this), to, i);
        }

    }
}