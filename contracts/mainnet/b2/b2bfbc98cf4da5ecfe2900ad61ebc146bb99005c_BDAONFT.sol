// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Utils.sol";

contract BDAONFT is ERC721Enumerable, Ownable {
    using Strings for uint;

    //the wallet address of the deployer
    address public deployer;

    //the path at which the NFT images are stored
    string public baseURI;

    //base extension
    string public baseExtension = ".json";

    //total number of all NFT's
    uint public maxSupply;

    //use this to enable/disable minting for other addresses rather than the deployer's address
    bool public isMintableOnlyByDeployer = true;

    //use this to enable/disable minting
    bool public isMintable = true;

    //the token for which the NFT's can be bought (BUSD)
    IERC20 public token;

    //the price for which the NFT's can be bought
    uint public mintPrice = 0;

    struct TierInfo {
        string name;
        uint id;
        uint maxSupply;
        uint mintedAmt;
    }

    TierInfo[] public tierInfos;
    mapping(uint => TierInfo) public tokenIdToTierInfo;

    event minted(address _user, uint _mintedAmt, uint[] tokenIds);
    event baseURIset(string _newVal);
    event mintPriceSet(uint _newVal);
    event baseExtentionSet(string _newVal);
    event mintableOnlyByDeployerStatusSet(bool _newVal);
    event mintableStatusSet(bool _newVal);
    event withdrawn(uint _val);
    event lastMinted(bool _val);

    constructor (string memory _name, string memory _symbol, string memory _tokeBaseURI, address _tokenAddr) ERC721(_name, _symbol) {
        setBaseURI(_tokeBaseURI);
        token = IERC20(_tokenAddr);
        deployer = msg.sender;

        tierInfos.push(TierInfo("ENTRY", 0, 200, 0));
        tierInfos.push(TierInfo("FRIENDS", 1, 150, 0));
        tierInfos.push(TierInfo("HODLER", 2, 100, 0));
        tierInfos.push(TierInfo("WARRIOR", 3, 25, 0));
        tierInfos.push(TierInfo("WAR", 4, 10, 0));
        tierInfos.push(TierInfo("COUNCIL", 5, 100, 0));

        _updateMaxSupply();
    }


    function _updateMaxSupply() private {
        uint newMaxSupply = 0;

        for (uint i = 0; i < tierInfos.length; i++) {
            newMaxSupply = newMaxSupply + tierInfos[i].maxSupply;
        }

        maxSupply = newMaxSupply;
    }


    function mint(uint _id) public {
        //check if minting is enabled
        require(isMintable, "Minting new NFT is not available");

        //check if the caller has inputed a valid tier id
        require(_id == 0 || _id == 1 || _id == 2 || _id == 3 || _id == 4 || _id == 5 || _id == 999, "Tier id invalid");

        //check if there are still NFT's to be minted
        require(totalSupply() + 1 <= maxSupply, "Not allowed to mint more than maxSupply");

        if (isMintableOnlyByDeployer == true) {
            //check if the current caller is the deployer
            require(deployer == msg.sender, "Non deployers can't currently mint NFT's");
        }

        if (mintPrice > 0) {
            //check if the caller has enough tokens to pay for the minting
            require(token.balanceOf(msg.sender) > mintPrice, "Make sure you have enough tokens");
        }

        uint[] memory tokenIds;

        if (_id == 999) {
            tokenIds = _mintRandomTier();
        } else {
            //check if the caller is the deployer
            require(deployer == msg.sender, "Only the deployer can mint specific NFT tiers");

            //check if specific are not all minted already
            TierInfo memory tierInfo = pickSpecificTier(_id);
            require(tierInfo.mintedAmt + 1 <= tierInfo.maxSupply, "All the NFT's of this tiers are already minted");

            tokenIds = _mintSpecificTier(_id);
        }

        if (mintPrice > 0) {
            //transfer tokens to the NFT contract in case the price in not 0
            token.transferFrom(msg.sender, address(this), mintPrice);
        }

        emit minted(msg.sender, tokenIds.length, tokenIds);
    }

    /*
    ** Override functions (ERC721)
    */

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory currentBaseURI = _baseURI();
        // return bytes(currentBaseURI).length > 0 ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension)) : "";
        return bytes(currentBaseURI).length > 0 ? string(abi.encodePacked(currentBaseURI, tokenIdToTierInfo[tokenId].name, baseExtension)) : "";

    }

    /*
    ** Helper functions (public)
    */

    function walletOfOwner(address _user) public view returns(uint[] memory) {
        uint[] memory tokens = new uint[](balanceOf(_user));

        for (uint i = 0; i < balanceOf(_user); i++){
            tokens[i] = tokenOfOwnerByIndex(_user, i);
        }

        return tokens;
    }

    function getTierInfo(uint id) public view returns(string memory _name, uint _id, uint _maxSupply, uint _mintedAmt) {
        for (uint i = 0; i < tierInfos.length; i++) {
            if (tierInfos[i].id == id) {
                return (tierInfos[i].name, tierInfos[i].id, tierInfos[i].maxSupply, tierInfos[i].mintedAmt);
            }
        }
    }

    /*
    ** Helper functions (owner)
    */

    function setBaseURI(string memory _newVal) public onlyOwner {
        baseURI = _newVal;
        emit baseURIset(_newVal);
    }

    function setMintPrice(uint _newVal) external onlyOwner {
        mintPrice = _newVal;
        emit mintPriceSet(_newVal);
    }

    function setBaseExtention(string memory _newVal) external onlyOwner {
        baseExtension = _newVal;
        emit baseExtentionSet(_newVal);
    }

    function setMintableOnlyByDeployerStatus(bool _newVal) external onlyOwner {
        isMintableOnlyByDeployer = _newVal;
        emit mintableOnlyByDeployerStatusSet(_newVal);
    }

    function setMintableStatus(bool _newVal) external onlyOwner {
        isMintable = _newVal;
        emit mintableStatusSet(_newVal);
    }

    function withdraw() external onlyOwner {
        token.transfer(msg.sender, token.balanceOf(address(this)));
        emit withdrawn(address(this).balance);
    }

    /*
    ** Internal utils
    */

    function getRandomness(uint seed) internal view returns(uint){
        return uint(keccak256(abi.encodePacked(
                block.timestamp,
                block.difficulty,
                msg.sender,
                block.number,
                block.coinbase,
                seed
            ))) % maxSupply;
    }

    function pickRandomTier(uint seed) internal view returns(TierInfo memory tierInfo, uint randomNum) {
        uint randomness = getRandomness(seed);
        uint sumVal = 0;

        for (uint i = 0; i < tierInfos.length; i++) {
            sumVal = sumVal + tierInfos[i].maxSupply;

            if (randomness <= sumVal) {
                return (tierInfos[i], randomness);
            }
        }
    }

    function pickSpecificTier(uint _id) internal view returns(TierInfo memory tierInfo) {
        for (uint i = 0; i < tierInfos.length; i++) {
            if (tierInfos[i].id == _id) {
                return tierInfos[i];
            }
        }
    }

    function updateMintedAmt(uint id) private {
        for (uint i = 0; i < tierInfos.length; i++) {
            if (tierInfos[i].id == id) {
                tierInfos[i].mintedAmt ++;
            }
        }
    }

    function _mintRandomTier() private returns(uint[] memory tokenIds) {
        uint[] memory mintedTokens = new uint[](1);

        uint newTokenId = totalSupply()+1;
        mintedTokens[0] = newTokenId;
        (TierInfo memory pickedTier,) = pickRandomTier(1);
        uint seedCumulater = 1;

        while(pickedTier.mintedAmt == pickedTier.maxSupply){
            (pickedTier,) = pickRandomTier(1+seedCumulater);
            seedCumulater ++;
        }

        tokenIdToTierInfo[newTokenId] = pickedTier;
        updateMintedAmt(pickedTier.id);
        _safeMint(msg.sender, newTokenId);

        return mintedTokens;
    }

    function _mintSpecificTier(uint _id) private returns(uint[] memory tokenIds) {
        uint[] memory mintedTokens = new uint[](1);

        uint newTokenId = totalSupply()+1;
        mintedTokens[0] = newTokenId;
        TierInfo memory pickedTier = pickSpecificTier(_id);
        tokenIdToTierInfo[newTokenId] = pickedTier;
        updateMintedAmt(pickedTier.id);
        _safeMint(msg.sender, newTokenId);

        return mintedTokens;
    }
}