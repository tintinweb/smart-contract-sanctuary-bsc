// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./ERC721Upgradeable.sol";
import "./ERC721EnumerableUpgradeable.sol";
import "./ERC721URIStorageUpgradeable.sol";
import "./PausableUpgradeable.sol";
import "./OwnableUpgradeable.sol";
import "./Initializable.sol";
import "./CountersUpgradeable.sol";
import "./IERC721Upgradeable.sol";
import "./ERC721RoyaltyUpgradeable.sol";
import "./IERC20Upgradeable.sol";
import "./SafeERC20Upgradeable.sol";
import "./SafeMathUpgradeable.sol";
contract OmniverseNFT is Initializable, ERC721Upgradeable, ERC721EnumerableUpgradeable, ERC721URIStorageUpgradeable, ERC721RoyaltyUpgradeable, PausableUpgradeable, OwnableUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    using SafeERC20Upgradeable for IERC20Upgradeable;
    CountersUpgradeable.Counter private _tokenIdCounter;
    using SafeMathUpgradeable for uint256;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    address public oca$hAddress;

    uint256 public requiredHoldingBalance;

    uint96 private _maxRoyaltyFee;
    uint96 private _minRoyaltyFee;

    function initialize(address ocashAddress_, uint256 requiredHoldingBalance_) initializer public {
        __ERC721_init("OmniverseNFT", "ONFT");
        __ERC721Enumerable_init();
        __ERC721URIStorage_init();
        __ERC721Royalty_init();
        __Pausable_init();
        __Ownable_init();

        oca$hAddress = ocashAddress_; // 0xb340F67E9Cc3927eBeEB04c2e03f74bd0543F4fc;
        requiredHoldingBalance = requiredHoldingBalance_;
        _maxRoyaltyFee = uint96(10)*uint96(100);
        _minRoyaltyFee = uint96(1)*uint96(100);
    }

    function setRequiredHoldingBalance(uint256 holdBalance) external onlyOwner {
        requiredHoldingBalance = holdBalance;
    }

    function setOcashAddress(address ocashAddress) external onlyOwner {
        oca$hAddress = ocashAddress;
    }

    function minMaxRoyalty() external view returns (uint96, uint96) {
        return (_minRoyaltyFee, _maxRoyaltyFee);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function safeMint(string memory uri, uint96 royalty) external whenNotPaused {
        address to = _msgSender();
        require(to!=address(0),"Address zero");

        // if has royalty then it should satisfy the minimum and maximum royalty
        if(royalty>0){
            require(royalty>= _minRoyaltyFee  && royalty<= _maxRoyaltyFee,"Invalid royalty value");
        }


        // // check if user has a ocash balance 
        uint256 ocashBalance = IERC20Upgradeable(oca$hAddress).balanceOf(to);
        require(ocashBalance>=requiredHoldingBalance,"Hold balance is not enough");

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);

        // set royalty info 
        _setTokenRoyalty(tokenId, to, royalty);
    }

    function feeDenominator() external pure virtual returns (uint256) {
        return _feeDenominator();
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable )
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId)
        internal
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable, ERC721RoyaltyUpgradeable)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable, ERC721RoyaltyUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}