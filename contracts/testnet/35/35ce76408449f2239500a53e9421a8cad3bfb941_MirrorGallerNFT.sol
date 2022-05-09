// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721.sol";
import "./ERC721Enumerable.sol";
import "./Pausable.sol";
import "./Ownable.sol";
import "./Strings.sol";


contract MirrorGallerNFT is ERC721, ERC721Enumerable, Pausable, Ownable {

    using Strings for uint256;

    string public baseURI;
    string public suffix;

    uint256 LAUNCH_MAX_SUPPLY;    // max launch supply
    uint256 LAUNCH_SUPPLY;        // current launch supply
    uint256 TOKEN_INDEX;

    address LAUNCHPAD;

    bool public burnEnable;

    constructor(string memory name_,
        string memory symbol_,
        string memory baseURI_,
        string memory suffix_,
        address launchpad,
        uint256 maxSupply,
        uint256 tokenIndex) ERC721(name_, symbol_) {
        baseURI = baseURI_;
        suffix = suffix_;
        LAUNCHPAD = launchpad;
        LAUNCH_MAX_SUPPLY = maxSupply;
        TOKEN_INDEX = tokenIndex;
        burnEnable = false;
    }

    modifier onlyLaunchpad() {
        require(LAUNCHPAD != address(0), "launchpad address must set");
        require(msg.sender == LAUNCHPAD, "must call by launchpad");
        _;
    }

    function getMaxLaunchpadSupply() view public returns (uint256) {
        return LAUNCH_MAX_SUPPLY;
    }

    function getLaunchpadSupply() view public returns (uint256) {
        return LAUNCH_SUPPLY;
    }

    function getTokenIndex() view public returns (uint256) {
        return TOKEN_INDEX;
    }

    function getLaunchpad() view public returns (address) {
        return LAUNCHPAD;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
    internal
    whenNotPaused
    override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
    public
    view
    override(ERC721, ERC721Enumerable)
    returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _baseURI() internal view virtual override returns (string memory){
        return baseURI;
    }

    function setBaseURI(string memory _newURI) external onlyOwner {
        baseURI = _newURI;
    }

    function setSuffix(string memory _newSuffix) external onlyOwner {
        suffix = _newSuffix;
    }

    function setBurnEnable(bool _burnEnable) external onlyOwner {
        burnEnable = _burnEnable;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token.");
        return string(abi.encodePacked(baseURI, tokenId.toString(), suffix));
    }

    function mintTo(address to, uint size) external onlyLaunchpad {
        require(to != address(0), "can't mint to empty address");
        require(size > 0, "size must greater than zero");
        require(LAUNCH_SUPPLY + size <= LAUNCH_MAX_SUPPLY, "max supply reached");

        for (uint256 i=1; i <= size; i++) {
            _mint(to, TOKEN_INDEX + 1);
            LAUNCH_SUPPLY++;
            TOKEN_INDEX++;
        }
    }

    function burn(uint256 tokenId) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "caller is not owner nor approved");
        require(burnEnable, "burn is disable");
        _burn(tokenId);
    }
}