/**
 * @title Non-Fungible Token
 * @dev NFT contract
 *
 * @author - <Felix Götz>
 * on behalf of ArrowTrade-AG
 *
 * SPDX-License-Identifier: Business Source License 1.1
 *
 **/

pragma solidity 0.8.4;

import "./Ownable.sol";
import "./ERC721Enumerable.sol";
import "./IERC20.sol";

contract NFT is Ownable, ERC721Enumerable {
    using Strings for uint256;
    using SafeMath for uint256;

    uint256 public NftLicenceUpdateTicker;
    string public baseTokenURI;
    string public endTokenURI;

    uint256 public nftCounter;
    uint256 public lizenzTime = 31536000;

    bool public counterNFT;
    bool public seasonNFT;

    /**
     * @dev Implements ERC721 contract and sets default values.
     */
    constructor(
        string memory name,
        string memory symbol,
        string memory defaultBaseTokenURI,
        string memory defaultEndTokenURI
    ) ERC721(name, symbol) {
        baseTokenURI = defaultBaseTokenURI;
        endTokenURI = defaultEndTokenURI;
    }

    /**
     * @dev Creates a new NFT.
     * @param _to Receiver of the newly created token.
     * nftCounter Unique if of the NFT.
     */
    function mint(address _to, uint256 _amount) external onlyAuthorized {
        uint256 mintet = 0;
        while (mintet < _amount) {
            nftCounter += 1;
            _safeMint(_to, nftCounter);
            mintet += 1;
        }
    }

    /**
     * @dev update the URI base for all NFTs.
     * @param _newEndTokenURI New URI base.
     */
    function setEndURI(string calldata _newEndTokenURI)
        external
        onlyAuthorized
    {
        endTokenURI = _newEndTokenURI;
    }

    /**
     * @dev Overrides _endURI function so we define the URI base we will be using.
     */
    function _endURI() internal view virtual override returns (string memory) {
        return endTokenURI;
    }

    /**
     * @dev update the URI base for all NFTs.
     * @param _newBaseTokenURI New URI base.
     */
    function setBaseURI(string calldata _newBaseTokenURI)
        external
        onlyAuthorized
    {
        baseTokenURI = _newBaseTokenURI;
    }

    /**
     * @dev Sets or revokes authorized address.
     * @param _address Address we are setting.
     * @param _isAuthorized True is set, false if we are revoking.
     */
    function setAuthorizedAddress(address _address, bool _isAuthorized)
        external
        onlyOwner
    {
        authorizedAddresses[_address] = _isAuthorized;
    }

    /**
     * @dev Overrides _baseURI function so we define the URI base we will be using.
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    /**
     * @dev NFT holder can renew his licence.
     * This function is designed to permanently weed out inactive holders and regulate inflation and deflation
     * renew the licence for 365 days.
     *
     * Requirements:
     *
     * msg.sender is token holder to renew the licence
     */
    function updateLicence(uint256 _tokenId) external onlyAuthorized {
        NftLicenceUpdateTicker += 1;
        nft[_tokenId].endLicence = block.timestamp.add(lizenzTime);
    }

    /**
     * @dev set a new NFT season for all new mintet NFTs.
     *
     * Requirements:
     *
     * msg.sender is onlyAuthorized to burn a NFT.
     */
    function setSeason(uint256 _seasonId) external onlyAuthorized {
        season = _seasonId;
    }

    /**
     * @dev set the activ lizenztime by update lizenztime from a NFT.
     *
     * Requirements:
     *
     * msg.sender is onlyAuthorized to burn a NFT.
     */
    function setLizenzTime(uint256 _lizenzTime) external onlyAuthorized {
        lizenzTime = _lizenzTime;
    }

    /**
     * @dev set the active lizenztime by minting a NFT.
     *
     * Requirements:
     *
     * msg.sender is onlyAuthorized to burn a NFT.
     */
    function setMintLizenzTime(uint256 _mintLizenzTime)
        external
        onlyAuthorized
    {
        mintLizenzTime = _mintLizenzTime;
    }

    /**
     * @dev  set the tokenURI to the Season-Lizenz.
     *
     * Requirements:
     *
     * msg.sender is onlyAuthorized to burn a NFT.
     */
    function setCounterNFT(bool _counterNFT) external onlyAuthorized {
        counterNFT = _counterNFT;
    }

    /**
     * @dev set the tokenURI to the Season-Lizenz.
     *
     * Requirements:
     *
     * msg.sender is onlyAuthorized to burn a NFT.
     */
    function setSeasonNFT(bool _seasonNFT) external onlyAuthorized {
        seasonNFT = _seasonNFT;
    }

    /**
     * @dev burn a NFT from a User via NFT id.
     *
     * Requirements:
     *
     * msg.sender is onlyAuthorized to burn a NFT.
     */
    function burn(uint256 _nftID) external onlyAuthorized {
        _burn(_nftID);
    }

    /**
     * @dev Outputs the current block timestamp
     */
    function timestamp() external view returns (uint256) {
        return block.timestamp;
    }

    /**
     * @dev Outputs the start licence block timestamp
     */
    function startLicenceBlock(uint256 _tokenId)
        external
        view
        returns (uint256)
    {
        return nft[_tokenId].startLicence;
    }

    /**
     * @dev Outputs the end licence block timestamp
     */
    function endLicenceBlock(uint256 _tokenId) external view returns (uint256) {
        return nft[_tokenId].endLicence;
    }

    /**
     * @dev Outputs the remaining time of the licence in days
     */
    function checkLicenceDays(uint256 _tokenId) public view returns (uint256) {
        uint256 licenceTimeBlocks;
        uint256 licenceTimeDays;

        licenceTimeBlocks = nft[_tokenId].endLicence.sub(block.timestamp);
        licenceTimeDays = licenceTimeBlocks.div(1 days);

        return licenceTimeDays;
    }

    /**
     * @dev Outputs licence is active [true or false]
     */
    function checkLicenceAktiv(uint256 _tokenId) public view returns (bool) {
        bool licenceAktiv;

        if (block.timestamp < nft[_tokenId].endLicence) {
            return licenceAktiv = true;
        } else {
            return licenceAktiv = false;
        }
    }

    /**
     * @dev Outputs the start licence block timestamp
     */
    function seasonNFTs(uint256 _tokenId) external view returns (uint256) {
        return nft[_tokenId].season;
    }

    /**
     * @dev set the whitelist true or false.
     *
     * Requirements:
     *
     * bool `_statusNFTWhitelistIs` can be true or false.
     */
    function statusNFTWhitelistIs(bool _statusNFTWhitelistIs) public onlyOwner {
        statusNFTWhitelist = _statusNFTWhitelistIs;
    }

    /**
     * @dev add the address `whitelist` contract.
     *
     * Requirements:
     *
     * address `whitelist` cannot be the zero address.
     * sender is owner.
     */
    function UpdateWhitelistContract(address _whitelistContract)
        public
        onlyOwner
    {
        whitelist = IWhitelist(_whitelistContract);
    }

    /**
     * @dev add the address `blacklist` contract.
     *
     * Requirements:
     *
     * address `blacklist` cannot be the zero address.
     * sender is owner
     */
    function UpdateBlacklistContract(address _blacklistContract)
        public
        onlyOwner
    {
        blacklist = IBlacklist(_blacklistContract);
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 _tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        if (seasonNFT == true) {
            if (block.timestamp < nft[_tokenId].endLicence) {
                string memory baseURI = _baseURI();
                return
                    bytes(baseURI).length > 0
                        ? string(
                            abi.encodePacked(
                                baseURI,
                                nft[_tokenId].season.toString(),
                                ".json"
                            )
                        )
                        : "";
            } else {
                string memory baseURI = _endURI();
                return
                    bytes(baseURI).length > 0
                        ? string(
                            abi.encodePacked(
                                baseURI,
                                nft[_tokenId].season.toString(),
                                ".json"
                            )
                        )
                        : "";
            }
        } else if (counterNFT == true) {
            if (block.timestamp < nft[_tokenId].endLicence) {
                string memory baseURI = _baseURI();
                return
                    bytes(baseURI).length > 0
                        ? string(
                            abi.encodePacked(
                                baseURI,
                                _tokenId.toString(),
                                ".json"
                            )
                        )
                        : "";
            } else {
                string memory baseURI = _endURI();
                return
                    bytes(baseURI).length > 0
                        ? string(
                            abi.encodePacked(
                                baseURI,
                                _tokenId.toString(),
                                ".json"
                            )
                        )
                        : "";
            }
        } else {
            if (block.timestamp < nft[_tokenId].endLicence) {
                string memory baseURI = _baseURI();
                return
                    bytes(baseURI).length > 0
                        ? string(abi.encodePacked(baseURI))
                        : "";
            } else {
                string memory baseURI = _endURI();
                return
                    bytes(baseURI).length > 0
                        ? string(abi.encodePacked(baseURI))
                        : "";
            }
        }
    }
}