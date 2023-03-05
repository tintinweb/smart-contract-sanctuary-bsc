// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

import "./pixel_pictasia_utils.sol";
import "./standard_contract.sol";

// import "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";
interface IERC1155MetadataURI is IERC1155 {
    function uri(uint256 id) external view returns (string memory);
}

// import "@openzeppelin/contracts/interfaces/IERC2981.sol";
interface IERC2981 is IERC165 {
    function royaltyInfo(uint256 tokenId, uint256 salePrice) external view returns (address receiver, uint256 royaltyAmount);
}

contract PixelPictasia is StandardContract, IERC1155MetadataURI, IERC2981 {
    /*
    *
    *
        Errors
    *
    *
    */

    /// @notice The required minting fee has not been paid.
    error MintFeeError(uint256 value, uint256 mintFee);

    /// @notice There are no remaining NFT mints available.
    error NoRemainingMintsError();

    /// @notice The address does not own the NFT.
    error NotNFTOwnerError(uint256 id, address _address, address nftOwner);

    /*
    *
    *
        Events
    *
    *
    */

    /*
    *
    *
        Constants
    *
    *
    */

    PixelPictasiaUtils private constant UTILS = PixelPictasiaUtils(0x4B5D992dE2cD1776479C053c03E83874Ada9f058);

    uint256 private constant CHAIN_ID = 97;
    string private constant CHAIN_NAME = "Binance Smart Chain Testnet";

    uint256 private constant GRID_WIDTH = 10;
    uint256 private constant GRID_HEIGHT = 10;
    uint256 private constant TILE_WIDTH = 3;
    uint256 private constant TILE_HEIGHT = 3;

    uint256 private constant TOTAL_NFTS = GRID_WIDTH * GRID_HEIGHT;

    /*
    *
    *
        Private Variables
    *
    *
    */

    /*
        NFT Variables
    */

    struct NFTConfig {
        uint256 posX;
        uint256 posY;

        uint8 red;
        uint8 green;
        uint8 blue;
    }

    address private royaltyAddress;
    uint256 private royaltyBasisPoints;
    
    string private storeDescription;
    string private storeExternalLinkURI;
    string private storeImageURI;
    string private storeName;

    mapping(uint256 => NFTConfig) private map_id2NFTConfig;
    mapping(uint256 => address) private map_id2NFTOwnerAddress;

    mapping(address => mapping(address => bool)) private map_address2OperatorAddress2IsApproved;
    mapping(uint256 => mapping(address => uint256)) private map_id2Address2Balance;

    /*
    *
    *
        Contract Functions
    *
    *
    */

    /*
        Built-In Functions
    */

    constructor() StandardContract() payable {
        //assert(block.chainid == CHAIN_ID);

        // Defaults are set here, but these can be changed manually after the contract is deployed.
        setRoyaltyAddress(address(this));
        setRoyaltyBasisPoints(300);

        setStoreName(string.concat("Pixel Pictasia NFT Collection (", CHAIN_NAME, ")"));
        //setStoreDescription("A collection of configurable NFT tokens featuring animated pixel art, capped at 100 per network. https://musicslayer.github.io/pixel_pictasia_dapp/");
        setStoreDescription("XYZ. https://musicslayer.github.io/pixel_pictasia_dapp/");
        setStoreImageURI("https://raw.githubusercontent.com/musicslayer/pixel_pictasia_dapp/main/store_image.png");
        setStoreExternalLinkURI("https://musicslayer.github.io/pixel_pictasia_dapp/");

        // Pre-mint all NFT's and assign them to the address deploying the contract.
        bytes memory data = new bytes(0);
        mintAll(msg.sender, data);
    }

    fallback() external payable {
        // There is no legitimate reason for this fallback function to be called.
        punish();
    }

    receive() external payable {}

    /*
        Implementation Functions
    */

    // IERC165 Implementation
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, StandardContract) returns (bool) {
        return interfaceId == type(IERC165).interfaceId
            || interfaceId == type(IERC1155).interfaceId
            || interfaceId == type(IERC1155MetadataURI).interfaceId 
            || interfaceId == type(IERC2981).interfaceId
            || super.supportsInterface(interfaceId);
    }

    // IERC1155 Implementation
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: address zero is not a valid owner");
        return map_id2Address2Balance[id][account];
    }

    function balanceOfBatch(address[] memory accounts, uint256[] memory ids) public view virtual override returns (uint256[] memory) {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for(uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(msg.sender != operator, "ERC1155: setting approval status for self");

        map_address2OperatorAddress2IsApproved[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return map_address2OperatorAddress2IsApproved[account][operator];
    }

    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) public virtual override {
        require(to != address(0), "ERC1155: transfer to the zero address");
        require(from == msg.sender || isApprovedForAll(from, msg.sender), "ERC1155: caller is not token owner or approved");

        uint256 fromBalance = map_id2Address2Balance[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");

        map_id2Address2Balance[id][from] = fromBalance - amount;
        map_id2Address2Balance[id][to] += amount;

        // For this token, the amount is always 1 per id, so we can keep track of the owner directly.
        setNFTOwner(id, to);

        emit TransferSingle(msg.sender, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(msg.sender, from, to, id, amount, data);
    }

    function safeBatchTransferFrom(address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) public virtual override {
        require(to != address(0), "ERC1155: transfer to the zero address");
        require(from == msg.sender || isApprovedForAll(from, msg.sender), "ERC1155: caller is not token owner or approved");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        for(uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = map_id2Address2Balance[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");

            map_id2Address2Balance[id][from] = fromBalance - amount;
            map_id2Address2Balance[id][to] += amount;

            // For this token, the amount is always 1 per id, so we can keep track of the owner directly.
            setNFTOwner(id, to);
        }

        emit TransferBatch(msg.sender, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(msg.sender, from, to, ids, amounts, data);
    }

    function _doSafeTransferAcceptanceCheck(address operator, address from, address to, uint256 id, uint256 amount, bytes memory data) private {
        if(to.code.length > 0) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if(response != IERC1155Receiver.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            }
            catch Error(string memory reason) {
                revert(reason);
            }
            catch {
                revert("ERC1155: transfer to non-ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) private {
        if(to.code.length > 0) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (bytes4 response) {
                if(response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            }
            catch Error(string memory reason) {
                revert(reason);
            }
            catch {
                revert("ERC1155: transfer to non-ERC1155Receiver implementer");
            }
        }
    }

    // IERC1155MetadataURI Implementation
    function uri(uint256 id) external view returns (string memory) {
        // The JSON data is directly encoded here.
        string memory name = createName(id);
        string memory description = createDescription(id);
        string memory imageURI = createImageURI(id);

        string memory uriString = string.concat('{"name":"', name, '", "description":"', description, '", "image":"', imageURI, '"}');
        return string(abi.encodePacked('data:application/json;base64,', Base64.encode(abi.encodePacked(uriString))));
    }

    // IERC2981 Implementation
    function royaltyInfo(uint256, uint256 salePrice) external view returns (address receiver, uint256 royaltyAmount) {
        receiver = royaltyAddress;
        royaltyAmount = (salePrice * royaltyBasisPoints) / 10000;
    }

    // OpenSea Standard
    function contractURI() public view returns (string memory) {
        // The JSON data is directly encoded here.
        string memory uriString = string.concat('{"name":"', storeName, '", "description":"', storeDescription, '", "image":"', storeImageURI, '", "external_link":"', storeExternalLinkURI, '", "seller_fee_basis_points":', uint256ToString(royaltyBasisPoints), ', "fee_recipient":"', addressToString(royaltyAddress), '"}');
        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(abi.encodePacked(uriString))));
    }

    /*
        Action Functions
    */

    function applyConfig(uint256 _id, uint8 _red, uint8 _green, uint8 _blue) private {
        setColors(_id, _red, _green, _blue);
    }

    /*
        Helper Functions
    */

    function createDescription(uint256 _id) private view returns (string memory) {
        if(_id == 0) {
            return "The current image.";
        }
        else if(_id >= 1 && _id <= TOTAL_NFTS) {
            NFTConfig memory nftConfig = map_id2NFTConfig[_id];
            string memory x = uint256ToString(nftConfig.posX);
            string memory y = uint256ToString(nftConfig.posY);
            string memory color = get3Hex(nftConfig.red, nftConfig.green, nftConfig.blue);

            return string.concat("Point = (", x, ",", y, ") --- RGB = ", color);
        }
        else {
            return "(Unminted)";
        }
    }

    function createImageURI(uint256 _id) private view returns (string memory) {
        // Either return a PNG for the tile or for the complete image.
        if(_id == 0) {
            return createCompleteURI();
        }
        else if(_id <= TOTAL_NFTS) {
            return createTileURI(_id);
        }
        else {
            return "";
        }
    }

    function createTileURI(uint256 _id) private view returns (string memory) {
        uint256 N = TILE_WIDTH * TILE_HEIGHT;

        PNGData memory pngData = PNGData(new bytes1[](N), new bytes1[](N), new bytes1[](N));
        NFTConfig memory nftConfig = map_id2NFTConfig[_id];
        for(uint256 n = 0; n < N; n++) {
            pngData.red[n] = bytes1(nftConfig.red);
            pngData.green[n] = bytes1(nftConfig.green);
            pngData.blue[n] = bytes1(nftConfig.blue);
        }

        bytes memory imageData = UTILS.createPNG(TILE_WIDTH, TILE_HEIGHT, pngData);
        return string(abi.encodePacked("data:image/png;base64,", Base64.encode(abi.encodePacked(imageData))));
    }

    function createCompleteURI() private view returns (string memory) {
        //uint256 N = GRID_WIDTH * TILE_WIDTH * GRID_HEIGHT * TILE_HEIGHT;
        uint256 N = 222;
        bytes1[] memory redArray = new bytes1[](N);
        bytes1[] memory greenArray = new bytes1[](N);
        bytes1[] memory blueArray = new bytes1[](N);

        PNGData memory pngData = PNGData(redArray, greenArray, blueArray);

        bytes memory imageData = UTILS.createPNG(GRID_WIDTH * TILE_WIDTH, GRID_HEIGHT * TILE_HEIGHT, pngData);
        return string(abi.encodePacked("data:image/png;base64,", Base64.encode(abi.encodePacked(imageData))));
    }

    function createName(uint256 _id) private pure returns (string memory) {
        return string.concat("Pixel Pictasia NFT #", uint256ToString(_id));
    }

    function mintAll(address _address, bytes memory _data) private {
        // ID 0 represents the entire image, IDs >= 1 represent the individual tiles.
        uint256[] memory ids = new uint256[](TOTAL_NFTS + 1);
        uint256[] memory amounts = new uint256[](TOTAL_NFTS + 1);

        uint256 currentID = 0;

        ids[currentID] = currentID;
        amounts[currentID] = 1;

        map_id2Address2Balance[currentID][_address] = 1;
        setNFTOwner(currentID, _address);

        // This is unused, so just use dummy values.
        map_id2NFTConfig[currentID] = NFTConfig(9999, 9999, 0, 0, 0);

        for(uint256 y = 0; y < GRID_HEIGHT; y++) {
            for(uint256 x = 0; x < GRID_WIDTH; x++) {
                currentID++;

                ids[currentID] = currentID;
                amounts[currentID] = 1;

                map_id2Address2Balance[currentID][_address] = 1;
                setNFTOwner(currentID, _address);
            }
        }

/*
        for(uint256 y = 0; y < GRID_HEIGHT; y++) {
            for(uint256 x = 0; x < GRID_WIDTH; x++) {
                currentID++;

                ids[currentID] = currentID;
                amounts[currentID] = 1;

                map_id2Address2Balance[currentID][_address] = 1;
                setNFTOwner(currentID, _address);

                // Initialize each color to black.
                //map_id2NFTConfig[currentID] = NFTConfig(x, y, 0, 0, 0);

                map_id2NFTConfig[currentID] = NFTConfig(x, y, 255, 255, 0);
            }
        }
        */

        emit TransferBatch(msg.sender, address(0), msg.sender, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(msg.sender, address(0), msg.sender, ids, amounts, _data);
    }

    /*
        Query Functions
    */

    function isNFTOwner(uint256 _id, address _address) private view returns (bool) {
        return _address == getNFTOwner(_id);
    }

    /*
        Require Functions
    */

    function requireNFTOwner(uint256 _id, address _address) private view {
        if(!isNFTOwner(_id, _address)) {
            revert NotNFTOwnerError(_id, _address, getNFTOwner(_id));
        }
    }

    /*
        Get Functions
    */

    function getDescription(uint256 _id) private view returns (string memory) {
        return createDescription(_id);
    }

    function getImageURI(uint256 _id) private view returns (string memory) {
        return createImageURI(_id);
    }

    function getName(uint256 _id) private pure returns (string memory) {
        return createName(_id);
    }

    function getNFTOwner(uint256 _id) private view returns (address) {
        return map_id2NFTOwnerAddress[_id];
    }

    function getOpenSeaData() private view returns (string memory) {
        return contractURI();
    }

    function getRoyaltyAddress() private view returns (address) {
        return royaltyAddress;
    }

    function getRoyaltyBasisPoints() private view returns (uint256) {
        return royaltyBasisPoints;
    }

    /*
        Set Functions
    */

    function setColors(uint256 _id, uint8 _red, uint8 _green, uint8 _blue) private {
        map_id2NFTConfig[_id].red = _red;
        map_id2NFTConfig[_id].green = _green;
        map_id2NFTConfig[_id].blue = _blue;
    }

    function setNFTOwner(uint256 _id, address _address) private {
        map_id2NFTOwnerAddress[_id] = _address;
    }

    function setRoyaltyAddress(address _royaltyAddress) private {
        royaltyAddress = _royaltyAddress;
    }

    function setRoyaltyBasisPoints(uint256 _royaltyBasisPoints) private {
        royaltyBasisPoints = _royaltyBasisPoints;
    }

    function setStoreDescription(string memory _storeDescription) private {
        storeDescription = _storeDescription;
    }

    function setStoreExternalLinkURI(string memory _storeExternalLinkURI) private {
        storeExternalLinkURI = _storeExternalLinkURI;
    }

    function setStoreImageURI(string memory _storeImageURI) private {
        storeImageURI = _storeImageURI;
    }

    function setStoreName(string memory _storeName) private {
        storeName = _storeName;
    }

    /*
    *
    *
        External Functions
    *
    *
    */

    /*
        Action Functions
    */

    /// @notice The NFT owner can configure their NFT.
    /// @param _id The ID of the NFT.
    /// @param _red The new red value.
    /// @param _green The new green value.
    /// @param _blue The new blue value.
    function action_applyConfig(uint256 _id, uint8 _red, uint8 _green, uint8 _blue) external {
        lock();

        requireNFTOwner(_id, msg.sender);

        applyConfig(_id, _red, _green, _blue);

        unlock();
    }

    /*
        Query Functions
    */

    /// @notice Returns whether the address owns the NFT.
    /// @param _id The ID of the NFT.
    /// @param _address The address that we are checking.
    /// @return Whether the address owns the NFT.
    function query_isNFTOwner(uint256 _id, address _address) external view returns (bool) {
        return isNFTOwner(_id, _address);
    }

    /*
        Get Functions
    */

    /// @notice Returns the description of the NFT.
    /// @param _id The ID of the NFT.
    /// @return The description of the NFT.
    function get_description(uint256 _id) external view returns (string memory) {
        return getDescription(_id);
    }

    /// @notice Returns the image URI of the NFT.
    /// @param _id The ID of the NFT.
    /// @return The image URI of the NFT.
    function get_imageURI(uint256 _id) external view returns (string memory) {
        return getImageURI(_id);
    }

    /// @notice Returns the name of the NFT.
    /// @param _id The ID of the NFT.
    /// @return The name of the NFT.
    function get_name(uint256 _id) external pure returns (string memory) {
        return getName(_id);
    }

    /// @notice Returns the address that owns the NFT.
    /// @param _id The ID of the NFT.
    /// @return The address that owns the NFT.
    function get_nftOwner(uint256 _id) external view returns (address) {
        return getNFTOwner(_id);
    }

    /// @notice Returns the OpenSea data.
    /// @return The OpenSea data.
    function get_openSeaData() external view returns (string memory) {
        return getOpenSeaData();
    }

    /// @notice Returns the address that royalties will be paid to.
    /// @return The address that royalties will be paid to.
    function get_royaltyAddress() external view returns (address) {
        return getRoyaltyAddress();
    }

    /// @notice Returns the royalty basis points.
    /// @return The royalty basis points.
    function get_royaltyBasisPoints() external view returns (uint256) {
        return getRoyaltyBasisPoints();
    }

    /*
        Set Functions
    */

    /// @notice The owner can set the address that royalties will be paid to.
    /// @param _royaltyAddress The new address that royalties will be paid to.
    function set_royaltyAddress(address _royaltyAddress) external {
        lock();

        requireOwnerAddress(msg.sender);

        setRoyaltyAddress(_royaltyAddress);

        unlock();
    }

    /// @notice The owner can set the royalty basis points.
    /// @param _royaltyBasisPoints The new royalty basis points.
    function set_royaltyBasisPoints(uint256 _royaltyBasisPoints) external {
        lock();

        requireOwnerAddress(msg.sender);

        setRoyaltyBasisPoints(_royaltyBasisPoints);

        unlock();
    }

    /// @notice The owner can set the store description.
    /// @param _storeDescription The new store description.
    function set_storeDescription(string memory _storeDescription) external {
        lock();

        requireOwnerAddress(msg.sender);

        setStoreDescription(_storeDescription);

        unlock();
    }

    /// @notice The owner can set the store external link URI.
    /// @param _storeExternalLinkURI The new store external link URI.
    function set_storeExternalLinkURI(string memory _storeExternalLinkURI) external {
        lock();

        requireOwnerAddress(msg.sender);

        setStoreExternalLinkURI(_storeExternalLinkURI);

        unlock();
    }

    /// @notice The owner can set the store image URI.
    /// @param _storeImageURI The new store image URI.
    function set_storeImageURI(string memory _storeImageURI) external {
        lock();

        requireOwnerAddress(msg.sender);

        setStoreImageURI(_storeImageURI);

        unlock();
    }

    /// @notice The owner can set the store name.
    /// @param _storeName The new store name.
    function set_storeName(string memory _storeName) external {
        lock();

        requireOwnerAddress(msg.sender);

        setStoreName(_storeName);

        unlock();
    }

    ////
    ////
    ////
    /// @notice The owner can call this to destroy a corrupt contract.
    function failsafe_selfdestruct() external {
        requireOwnerAddress(msg.sender);
        selfdestruct(payable(msg.sender));
    }
}