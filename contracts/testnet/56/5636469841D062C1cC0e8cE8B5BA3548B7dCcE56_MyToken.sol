// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "./ERC721.sol";
import "./ERC721Enumerable.sol";
import "./ERC721Burnable.sol";
import "./Ownable.sol";
import "./EIP712.sol";
import "./ERC721Votes.sol";
import "./Counters.sol";
import "./IERC20.sol";
import "./SafeERC20.sol";
import "./ERC2981PerTokenRoyalties.sol";
import "./ISoulbound.sol";
import "./FounderzDAOSoulbound.sol";

contract MyToken is ERC721, ERC721Enumerable, ERC721Burnable, Ownable, EIP712, ERC721Votes, ERC2981PerTokenRoyalties {
    using Counters for Counters.Counter;
    using SafeERC20 for IERC20;  

    Counters.Counter private _tokenIdCounter;

    ISoulbound public soulbound;

    uint256 public contractRoyalties = 1000;
    address public royaltiesReceiver;
    string constant ContractCreator = "t.me/FrankFourier";
    string public baseTokenURI;
    string public baseExtension = ".json";
    uint public price = 1 * 10 ** 18;

    mapping(address => bool) public isWhitelisted;
    mapping(uint256 => string) private TokenURIs;
    mapping(uint256 => bool) public isCapsule;

    event NonFungibleTokenRecovery(address indexed token, uint256 tokenId);
    event TokenRecovery(address indexed token, uint256 amount);
    event CreateFounderzNFT(uint256 indexed id);

    constructor() ERC721("MyToken", "MTK") EIP712("MyToken", "1") {
        soulbound = new FounderzDAOSoulbound(address(this));
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function setBaseURI(string memory baseURI) external onlyOwner {
        baseTokenURI = baseURI;
    }

    function mint(address _to) external onlyOwner {
        _mintAnElement(_to);
    }
	
    function _mintAnElement(address _to) private {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(_to, tokenId);
        _setTokenRoyalty(tokenId, royaltiesReceiver, contractRoyalties);
        emit CreateFounderzNFT(tokenId);
    }

    function walletOfOwner(address _owner) external view returns (uint256[] memory) {
        uint256 tokenCount = balanceOf(_owner);
        uint256[] memory tokensId = new uint256[](tokenCount);
        for (uint256 i = 0; i < tokenCount; i++) {
            tokensId[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokensId;
    }

    function withdraw(uint256 amount) public onlyOwner {
		uint256 balance = address(this).balance;
        require(balance >= amount);
        _withdraw(owner(), amount);
    }

    function withdrawAll() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0);
        _withdraw(owner(), address(this).balance);
    }

    function _withdraw(address _address, uint256 _amount) private {
        (bool success, ) = _address.call{value: _amount}("");
        require(success, "Transfer failed.");
    }

    function setWhitelist(address account, bool status) external onlyOwner {
        isWhitelisted[account] = status;
    }

    function setRoyaltiesReceiver(address receiver) external onlyOwner {
        royaltiesReceiver = receiver;
    }

    function setPresalePrice(uint256 newPrice) external onlyOwner {
        price = newPrice;
    }

    function buyPresale() external payable {
        require(isWhitelisted[msg.sender] == true, "Sender is not whitelisted");
        uint256 total = 10;
        require(totalSupply() <= total, "Sale end");
        require(msg.value >= price, "Value below price");
        _mintAnElement(msg.sender);
        soulbound.mint(msg.sender);
    }

    /**
     * @notice Allows the owner to recover non-fungible tokens sent to the contract by mistake
     * @param _token: NFT token address
     * @param _tokenId: tokenId
     * @dev Callable by owner
     */
    function recoverNonFungibleToken(address _token, uint256 _tokenId) external onlyOwner {
        IERC721(_token).transferFrom(address(this), address(msg.sender), _tokenId);

        emit NonFungibleTokenRecovery(_token, _tokenId);
    }

    /**
     * @notice Allows the owner to recover tokens sent to the contract by mistake
     * @param _token: token address
     * @dev Callable by owner
     */
    function recoverToken(address _token) external onlyOwner {
        uint256 balance = IERC20(_token).balanceOf(address(this));
        require(balance != 0, "Operations: Cannot recover zero balance");

        IERC20(_token).safeTransfer(address(msg.sender), balance);

        emit TokenRecovery(_token, balance);
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _afterTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Votes)
    {
        super._afterTokenTransfer(from, to, tokenId, batchSize);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, ERC2981PerTokenRoyalties)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function setTokenURI(uint256 tokenId, string memory URI) external onlyOwner {
        TokenURIs[tokenId] = URI;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        if (isCapsule[tokenId]) {
            return TokenURIs[tokenId];
        } else {
            return _baseURI();
        }
    }
}