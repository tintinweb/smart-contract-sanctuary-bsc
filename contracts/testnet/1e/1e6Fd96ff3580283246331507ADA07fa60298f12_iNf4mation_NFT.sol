pragma solidity 0.8.12;

// SPDX-License-Identifier: MIT

import "./ERC721.sol";
import "./ERC721Enumerable.sol";
import "./ERC721URIStorage.sol";
import "./Pausable.sol";
import "./Ownable.sol";
import "./ERC721Burnable.sol";
import "./SafeMath.sol";
import "./IContract.sol";

contract iNf4mation_NFT is ERC721, ERC721Enumerable, ERC721URIStorage, Pausable, Ownable, ERC721Burnable {
    using SafeMath for uint256;

    mapping (address => bool) public minters;

    constructor() ERC721("iNf4mation", "$SNFT") {
    }
    
    modifier onlyMinter() {
        require(minters[msg.sender], "Restricted to minters.");
        _;
    }

    function getNFTsByOwner(address _wallet) public view returns (uint256[] memory) {
        uint256 numOfTokens = balanceOf(_wallet);
        uint256[] memory tokensId = new uint256[](numOfTokens);
        for (uint256 i; i < numOfTokens; i++) {
            tokensId[i] = tokenOfOwnerByIndex(_wallet, i);
        }
        return tokensId;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function addMinter(address account) public onlyOwner {
        minters[account] = true;
    }

    function removeMinter(address account) public onlyOwner {
        minters[account] = false;
    }

    function Approve(address to, uint256 tokenId) public {
        _approve(to, tokenId);
    }

    function setApprover(address _approver) public onlyOwner {
        isApprover[_approver] = true;
    }

    function safeMint(address to, uint256 tokenId) public onlyMinter {
        _safeMint(to, tokenId);
        
    }

    function addURI(uint256[] memory tokenId, string[] memory uri) public onlyOwner {
        require(tokenId.length == uri.length, "$SNFT: Please enter equal tokenId & uri length..");
        
        for (uint256 i = 0; i < tokenId.length; i++) {
            _setTokenURI(tokenId[i], uri[i]);
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
    
    // function to allow admin to transfer *any* BEP20 tokens from this contract..
    function transferAnyBEP20Tokens(address tokenAddress, address recipient, uint256 amount) public onlyOwner {
        require(amount > 0, "$SNFT: amount must be greater than 0");
        require(recipient != address(0), "$SNFT: recipient is the zero address");
        IContract(tokenAddress).transfer(recipient, amount);
    }
}