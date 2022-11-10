// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./Ownable.sol";
import "./ReentrancyGuard.sol";
import "./IERC2981.sol";
import "./MerkleProof.sol";
import "./IERC20.sol";

import "./ERC721A.sol";

contract LeggiNFT is ERC721A, IERC2981, Ownable, ReentrancyGuard {
    string public metaURI;

    uint256 public constant MAX_SUPPLY = 0xfffffffffffffffffffffffffffffffffff;
    mapping(address => uint256)[] public addressMinted;

    event Received(address indexed, uint256);
    event StageMintConfigChanged(StageMintConfig config);

    modifier onlyEOA() {
        require(tx.origin == _msgSender(), "only EOA allowed");
        _;
    }

    constructor() ERC721A("Leggi", "Leggi") {
        addressMinted.push();
        stageMintConfig = StageMintConfig(0, 0, 1, false, true, 1668081600, 1668254400); // prod 北京时间 10号晚上8点～12号晚上8点
    }

    struct StageMintConfig {
        uint64 stageNum;
        uint64 maxPerStage; // Maximum number that can be minted at this stage
        uint64 maxPerAddress;
        bool isWhiteListMintActive;
        // bytes32 merkleRoot;
        bool isPublicMintActive;
        uint64 beginTime;
        uint64 endTime;
    }

    StageMintConfig public stageMintConfig;

    function setStageMintConfig(StageMintConfig calldata config_)
    external
    onlyOwner
    {
        stageMintConfig = config_;
        emit StageMintConfigChanged(config_);
    }

    /**
     * @dev Equivalent to `_burn(tokenId, false)`.
     */
    function burn(uint256 tokenId) public {
        _burn(tokenId, false);
    }

    function publicMint(uint64 quantity) external onlyEOA nonReentrant {
        require(
            stageMintConfig.isPublicMintActive,
            "public mint has not started"
        );
        _claim(quantity);
    }

    function _claim(uint64 quantity) internal {
        uint time = block.timestamp;
        require(stageMintConfig.beginTime <= time && stageMintConfig.endTime >= time, "Mint is not enabled");
        require(quantity > 0, "invalid number of tokens");
        require(
            addressMinted[stageMintConfig.stageNum][_msgSender()] + quantity <=
            stageMintConfig.maxPerAddress,
            "exceeded maxPerAddress"
        );

        addressMinted[stageMintConfig.stageNum][_msgSender()] += quantity;
        _safeMint(_msgSender(), quantity);
    }

    function totalMinted() public view returns (uint256) {
        return _totalMinted();
    }

    /***************Royalty***************/
    function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(ERC721A, IERC165)
    returns (bool)
    {
        return
        interfaceId == type(IERC2981).interfaceId ||
        super.supportsInterface(interfaceId);
    }

    function royaltyInfo(uint256 tokenId, uint256 salePrice)
    external
    view
    override
    returns (address receiver, uint256 royaltyAmount)
    {
        require(_exists(tokenId), "query for nonexistent token");
        return (address(this), (salePrice * 250) / 10000);
    }

    function withdraw() external onlyOwner nonReentrant {
        (bool success, ) = _msgSender().call{value: address(this).balance}("");
        require(success, "withdraw failed");
    }

    function withdrawTokens(IERC20 token) external onlyOwner nonReentrant {
        uint256 balance = token.balanceOf(address(this));
        token.transfer(_msgSender(), balance);
    }

    receive() external payable {
        emit Received(_msgSender(), msg.value);
    }

    /***************TokenURI***************/
    function setTokenURI(string calldata tokenURI_) external onlyOwner {
        metaURI = tokenURI_;
    }

    /**
    * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view override virtual returns (string memory) {
        return metaURI;
    }

}