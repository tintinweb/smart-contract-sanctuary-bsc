// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function approve(address to, uint256 tokenId) external;

    function setApprovalForAll(address operator, bool _approved) external;

    function getApproved(uint256 tokenId) external view returns (address operator);

    function isApprovedForAll(address owner, address operator) external view returns (bool);
}
contract Mint {
    address public admin = 0x3Fee4cF166162Ded2F50Ad4D0Bc724d2E9ae43E9;
    IERC721 public crr = IERC721(0x3727c5A044e09177786055CF8071233EF763ebE7);
    address devWallet = payable(0x3Fee4cF166162Ded2F50Ad4D0Bc724d2E9ae43E9);
    uint256 public salePrice = 0.2 ether;
    constructor() {}

    function mint(address account, uint256 tokenId) public payable {
        require(crr.ownerOf(tokenId) != devWallet, "This key is already minted.");
		require(msg.value >= salePrice, "Price is less than salePrice.");
        crr.approve(account, tokenId);
        crr.safeTransferFrom(devWallet, account, tokenId);
    }
}