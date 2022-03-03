// File: https://github.com/OpenZeppelin/openzeppein-contracts/blob/v4.5.0/contracts/utils/Counters.sol

import "./NFTToken_flat.sol";

// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

}
contract MyNFT is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("MyNFT", "NFT") {}

    function mintNFT(address recipient, string memory tokenURI)
        public
        returns (uint256)
    {
        // address skg = 0x00cDf121B927dBa4093D20F9964F48B0Cd60E204;
        // uint256 balance = IERC20(skg).balanceOf(_msgSender());
        // require(balance >= 100000000000000000000, "Address: insufficient balance");
        // IERC20(skg).transfer(0xCA3c62e4c1b8C1De244c84eAB47496656dB4cA8F, 100000000000000000000);

        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(recipient, newItemId);
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }
}