// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "./Parcel.sol";
import "./interfaces/IStandardParcel.sol";
import "./interfaces/IMiner.sol";

contract StandardParcel is Parcel, IStandardParcel {


    struct ParcelInfo {
        bool upgradeStatus;
        uint256[] minerNFTTokenIds;
        uint256[] aestheticNFTTokenIds;
    }

    /// @notice Record of Parcel upgraded status
    mapping(uint256 => ParcelInfo) parcels;

    /// @notice Record of assigned Aesthetic NFTs on parcel
    mapping(uint256 => uint256) aestheticNFTIdToParcelId;

    /// @notice Record of assignet miner on parcel
    mapping(uint256 => uint256) minerIdToParcelId;

    /// @notice Amount of slots on Standard parcel
    uint8 standardParcelSlotsLimit;

    /// @notice Amount of slots on upgraded parcel
    uint8 upgradedParcelSlotsLimit;

    /// @notice Amount of all assigned Miners
    uint256 public totalMinerNFTsAmount;

    /// @notice Amount of all assigned aesthetic NFTs
    uint256 public totalAestheticNFTsAmount;

    /// @notice Event that is emitted when parcel is upgraded
    event ParcelUpgraded(uint256 _tokenId);

    /// @notice Event that is emitted when some token is assigned on parcel
    event Assigned(uint256 _parcelId, uint256 _tokenId);

    /// @notice Event that is emitted when some token is unassigned on parcel
    event Unassigned(uint256 _parcelId, uint256 _tokenId);

    constructor(
        uint8 _standardParcelSlotsLimit,
        uint8 _upgradedParcelSlotsLimit,
        address _brokerPBContractAddress,
        string memory _collectionName,
        string memory _collectionSymbol,
        string memory _collectionBaseURI
    ) {
        standardParcelSlotsLimit = _standardParcelSlotsLimit;
        upgradedParcelSlotsLimit = _upgradedParcelSlotsLimit;
        _setBrokerPBContractAddress (_brokerPBContractAddress);
        _name = _collectionName;
        _symbol = _collectionSymbol;
        _baseURI = _collectionBaseURI;
    }

    /**
     * @notice Function which sets Standard parcel slots amount
     *         Only Managers can call this functions
     * @param _standardParcelSlotsLimit amount of slots
     */
    function setStandardParcelSlotsLimit(uint8 _standardParcelSlotsLimit) external onlyBroker {
        standardParcelSlotsLimit = _standardParcelSlotsLimit;
    }

    /**
     * @notice Function which sets upgraded parcel slots amount
     *         Only Managers can call this functions
     * @param _upgradedParcelSlotsLimit amount of slots
     */
    function setUpgradedParcelSlots(uint8 _upgradedParcelSlotsLimit) external onlyBroker {
        upgradedParcelSlotsLimit = _upgradedParcelSlotsLimit;
    }

    /**
     * @notice Function which upgrade parcel
     *         Only Managers can call this functions
     * @param _x X cordinat of parcel
     * @param _y Y cordinat of parcel
     */
    function upgradeParcel(int256 _x, int256 _y) external onlyBroker {
        uint256 _tokenId = _getTokenId(_x, _y);
        require(
            _exists(_tokenId),
            "StandardParcel: Parcel does not exist or is a Bussiness Parcel"
        );
        require(
            !parcels[_tokenId].upgradeStatus,
            "StandardParcel: Parcel is already upgraded"
        );
        parcels[_tokenId].upgradeStatus = true;
        emit ParcelUpgraded(_tokenId);
    }

    /**
     * @dev Function which assign token on parcel
     *         Only Managers can call this functions
     * @param _activatableNFTType Type of token (miner/aesthetic)
     * @param _x X cordinat of parcel
     * @param _y Y cordinat of parcel
     * @param _tokenId ID of Assigned Token
     */
    function assignNFT(
        ActivatableNFTs _activatableNFTType,
        int256 _x,
        int256 _y,
        uint256 _tokenId
    ) external onlyBroker {
        uint256 parcelId = _getTokenId(_x, _y);
        require(_exists(parcelId), "StandardParcel: Parcel does not exist");

        if (_activatableNFTType == ActivatableNFTs.Aesthetic) {
            aestheticNFTIdToParcelId[_tokenId] = parcelId;
            parcels[parcelId].aestheticNFTTokenIds.push(_tokenId);
            totalAestheticNFTsAmount++;
        } else {
            uint8 slotsLimit = parcels[parcelId].upgradeStatus
                ? standardParcelSlotsLimit
                : upgradedParcelSlotsLimit;
            require(
                parcels[parcelId].minerNFTTokenIds.length <= slotsLimit,
                "StandardParcel: This parcell does not have any available slots"
            );
            totalMinerNFTsAmount++;
            minerIdToParcelId[_tokenId] = parcelId;
            parcels[parcelId].minerNFTTokenIds.push(_tokenId);
        }
        emit Assigned(parcelId, _tokenId);
    }

    /**
     * @dev Function which unassign token on parcel
     *         Only Managers can call this functions
     * @param _activatableNFTType Type of token (miner/aesthetic)
     * @param _x X cordinat of parcel
     * @param _y Y cordinat of parcel
     * @param _tokenId ID of Assigned Token
     */
    function unassignNFT(
        ActivatableNFTs _activatableNFTType,
        int256 _x,
        int256 _y,
        uint256 _tokenId
    ) external onlyBroker {
        uint256 parcelId = _getTokenId(_x, _y);
        require(_exists(_tokenId), "StandardParcel: This parcel does not exist");

        if (_activatableNFTType == ActivatableNFTs.Aesthetic) {
            require(
                aestheticNFTIdToParcelId[_tokenId] == parcelId,
                "StandardParcel: This Aesthetic NFT is not activated on this parcel"
            );

            parcels[parcelId].aestheticNFTTokenIds[_tokenId] = 0;
            for (uint256 i; i < parcels[parcelId].aestheticNFTTokenIds.length; i++) {
                if (parcels[parcelId].aestheticNFTTokenIds[i] == _tokenId) {
                    parcels[parcelId].aestheticNFTTokenIds[i] = parcels[parcelId]
                        .aestheticNFTTokenIds[
                            parcels[parcelId].aestheticNFTTokenIds.length - 1
                        ];
                    parcels[parcelId].aestheticNFTTokenIds.pop();
                    totalAestheticNFTsAmount--;
                    break;
                }
            }
        } else {
            require(
                minerIdToParcelId[_tokenId] == parcelId,
                "StandardParcel: This Miner NFT is not activated on this parcel"
            );
            minerIdToParcelId[_tokenId] = 0;
            for (uint256 i; i < parcels[parcelId].minerNFTTokenIds.length; i++) {
                if (parcels[parcelId].minerNFTTokenIds[i] == _tokenId) {
                    parcels[parcelId].minerNFTTokenIds[i] = parcels[parcelId]
                        .minerNFTTokenIds[parcels[parcelId].minerNFTTokenIds.length - 1];
                    parcels[parcelId].minerNFTTokenIds.pop();
                    totalMinerNFTsAmount--;
                    break;
                }
            }
        }
        emit Unassigned(parcelId, _tokenId);
    }


    /**
     * @notice Function which return upgraded status of parcel
     * @param _parcelId ID of Assigned Token
     * @return bool Upgraded status
     */
    function isUpgraded(uint256 _parcelId) external view returns (bool) {
        return parcels[_parcelId].upgradeStatus;
    }

    /**
     * @notice Function which return all miners  assagined on parcel
     * @param _x X cordinat of parcel
     * @param _y Y cordinat of parcel
     * @return uint256[]  list of miners IDs
     */
    function getParcelNFTs(
        ActivatableNFTs _activatableNFTType,
        int256 _x, 
        int256 _y
        ) external
        view
        returns (uint256[] memory)
    {
        require(
            _activatableNFTType <= ActivatableNFTs.Miner,
            "StandardParcel: Invalid activatable NFT type"
        );
        uint256 parcelId = _getTokenId(_x, _y);
        if(_activatableNFTType == ActivatableNFTs.Aesthetic){
            return parcels[parcelId].aestheticNFTTokenIds;
        } else {
            return parcels[parcelId].minerNFTTokenIds; 
        }

    }

    function getNFTParcel(
        ActivatableNFTs _activatableNFTType,
        uint256 _tokenId
        ) external view returns (uint256) {
        require(
            _activatableNFTType <= ActivatableNFTs.Miner,
            "StandardParcel: Invalid activatable NFT type"
        );
        if (_activatableNFTType == ActivatableNFTs.Aesthetic) {
            return aestheticNFTIdToParcelId[_tokenId];
        } else {
            return (minerIdToParcelId[_tokenId]);
        }
    }

    function existsByCoordinates(int256 _x, int256 _y)
        external
        view
        returns (bool)
    {
        uint256 _tokenId = _getTokenId(_x, _y);
        return _exists(_tokenId);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "./ERC721Base.sol";
import "./interfaces/IParcel.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

contract Parcel is ERC721Base, Ownable, IParcel {
    address internal brokerPBContractAddress;
    uint256 maxCoordinate = 10000;
    event BrokerChanged(address brokerPBContractAddress);

    modifier onlyBroker() {
        require(msg.sender == brokerPBContractAddress, "Parcel: This funcrion can be called only by Broker Public Building Contract");
        _;
    }

    function _setBrokerPBContractAddress(address _brokerPBContractAddress) internal {
        require(
            _brokerPBContractAddress != address(0),
            "Parcel: Broker Public Building contract address can not be address 0"
        );
        require(
            _brokerPBContractAddress != brokerPBContractAddress,
            "Parcel: Broker Public Building address is already set to this address"
        );

        brokerPBContractAddress = _brokerPBContractAddress;
        emit BrokerChanged(_brokerPBContractAddress);
    }

    function setBrokerPBContractAddress(address _brokerPBContractAddress) external onlyOwner {
        _setBrokerPBContractAddress(_brokerPBContractAddress);
    }

    function getTokenId(int256 _x, int256 _y)
        external
        view
        returns (uint256 tokenId)
    {
        tokenId = _getTokenId(_x, _y);
    }

    function _getTokenId(int256 _x, int256 _y)
        internal
        view
        returns (uint256 tokenId)
    {
        uint256 x = uint256(_abs(_x));
        uint256 y = uint256(_abs(_y));
        require(x < maxCoordinate, "Land: x coordinate is out of the bounds");
        require(y < maxCoordinate, "Land: y coordinate is out of the bounds");
        tokenId += maxCoordinate * 10 * x + y;
        if (_x <= 0) {
            tokenId += (maxCoordinate ** 2) * 10;
        }
        if (_y <= 0) {
            tokenId += maxCoordinate;
        }
    }

    function getX(uint256 _tokenId) external view returns (int256) {
        return _getX(_tokenId);
    }

    function _getX(uint256 _tokenId) internal view returns (int256) {
        uint256 x = _tokenId / (maxCoordinate * 10);
        if (x > maxCoordinate) {
            return -int256(x - maxCoordinate);
        }
        return int256(x);
    }

    function getY(uint256 _tokenId) external view returns (int256) {
        return _getY(_tokenId);
    }

    function _getY(uint256 _tokenId) internal view returns (int256) {
        uint256 y = _tokenId % (maxCoordinate * 10);
        if (y > maxCoordinate) {
            return -int256(y - maxCoordinate);
        }
        return int256(y);
    }

    function mintParcelFor(
        address _beneficiary,
        int256 _x,
        int256 _y
    ) external onlyBroker {
        uint tokenId = _getTokenId(_x, _y);
        require(
            !_exists(tokenId),
            "Parcel: Parcel already exists"
        );
        _mintFor(tokenId, _beneficiary);
    }

    function mintParcelFor(address _beneficiary, uint256 _tokenId)
        external
        onlyBroker
    {
        require(
            !_exists(_tokenId),
            "Parcel: Parcel already exists"
        );
        _mintFor(_tokenId, _beneficiary);
    }

    function mintMultipleParcelsFor(
        address _beneficiary,
        int256[] memory _x,
        int256[] memory _y
    ) external onlyBroker {
        require(
            _x.length == _y.length,
            "Parcel: Length's of coordinate arrays do not match"
        );
        for (uint256 index; index < _x.length; index++) {
            _mintFor(_getTokenId(_x[index], _y[index]), _beneficiary);
        }
    }

    function mintAdjacentQuadraticParcels(
        address _beneficiary,
        int256 _x,
        int256 _y,
        uint256 _size
    ) external onlyBroker {
        require(_size > 0 && _size < 5, "Parcel: invalid size value");
        for (int256 x = _x; x < _x + int256(_size); x++) {
            for (int256 y = _y; y > _y - int256(_size); y--) {
                _mintFor(_getTokenId(x, y), _beneficiary);
            }
        }
    }

    function transferParcelFrom(
        address _from,
        address _to,
        int256 _x,
        int256 _y
    ) external {
        _transferToken(_from, _to, _getTokenId(_x, _y), "", false);
    }

    function transferMultipleParcels(
        address _to,
        int256[] memory _x,
        int256[] memory _y
    ) external {
        require(
            _x.length == _y.length,
            "Parcel: Length's of coordinate arrays do not match"
        );
        uint256 tokenId;
        for (uint256 index; index < _x.length; index++) {
            tokenId = _getTokenId(_x[index], _y[index]);
            _transferToken(_tokenOwner[tokenId], _to, tokenId, "", false);
        }
    }

    function transferAdjacentQuadraticParcels(
        address _to,
        int256 _x,
        int256 _y,
        uint256 _size
    ) external {
        require(_size > 0 && _size < 5, "Parcel: invalid size value");
        for (int256 x = _x; x < _x + int256(_size); x++) {
            for (int256 y = _y; y > _y - int256(_size); y--) {
                uint256 tokenId = _getTokenId(x, y);
                _transferToken(_tokenOwner[tokenId], _to, tokenId, "", false);
            }
        }
    }

    function parcelExists(int256 _x, int256 _y) external view returns (bool) {
        return _exists(_getTokenId(_x, _y));
    }

    function ownerOfParcel(int256 _x, int256 _y)
        external
        view
        returns (address)
    {
        return _tokenOwner[_getTokenId(_x, _y)];
    }

    function ownersOfMultipleParcels(int256[] memory _x, int256[] memory _y)
        external
        view
        returns (address[] memory ownerAddresses)
    {
        require(
            _x.length == _y.length,
            "Parcel: Length's of coordinate arrays do not match"
        );
        for (uint256 index; index < _x.length; index++) {
            ownerAddresses[index] = _tokenOwner[
                _getTokenId(_x[index], _y[index])
            ];
        }
    }

    function allParcelsOf(address _owner)
        external
        view
        returns (int256[] memory, int256[] memory)
    {
        uint256[] memory userTokens = _userTokens[_owner];
        int256[] memory x = new int[](userTokens.length);
        int256[] memory y = new int[](userTokens.length);
        for (uint256 index; index < userTokens.length; index++) {
            x[index] = _getX(userTokens[index]);
            y[index] = _getY(userTokens[index]);
        }
        return (x,y);
    }

    function _abs(int256 _num) internal pure returns (int256) {
        return _num >= 0 ? _num : -_num;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "./IParcel.sol";

interface IStandardParcel is IParcel {

    enum ActivatableNFTs { Aesthetic, Miner }

    function setStandardParcelSlotsLimit(uint8 _standardParcelSlotsLimit) external;

    function setUpgradedParcelSlots(uint8 _upgradedParcelSlotsLimit) external;

    function upgradeParcel(int256 _x, int256 _y) external;

    function assignNFT(
        ActivatableNFTs _activatableNFTType,
        int256 _x,
        int256 _y,
        uint256 _tokenId
    ) external;

    function unassignNFT(
        ActivatableNFTs _activatableNFTType,
        int256 _x,
        int256 _y,
        uint256 _tokenId
    ) external;

    function isUpgraded(uint256 _parcelId) external view returns (bool);

    function getParcelNFTs(
        ActivatableNFTs _activatableNFTType,
        int256 _x, 
        int256 _y
        ) external
        view
        returns (uint256[] memory);

    function getNFTParcel(
        ActivatableNFTs _activatableNFTType,
        uint256 _tokenId
        ) external view returns (uint256);

    function existsByCoordinates(int256 _x, int256 _y)
        external
        view
        returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;
import "./IERC721Base.sol";

interface IMiner is IERC721Base {
    function changeTokenLocking(uint256 _tokenId, bool _lockStatus) external;
    function reduceMinerDurability(uint256 _tokenId) external;
    function getMinerDurability(uint256 _tokenId) external returns(uint256);
    function getMinerHashrate(uint256 _tokenId) external returns(uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

import "./interfaces/IERC165.sol";
import "./interfaces/IERC721Base.sol";
import "./interfaces/IERC721Lockable.sol";
import "./interfaces/IERC721Metadata.sol";
import "./interfaces/IERC721TokenReceiver.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract ERC721Base is IERC721Base {
    /// @dev This contract uses SafeMath library functionality with type
    using SafeMath for uint256;

    /// @dev Calculated by "bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))"
    bytes4 private constant ERC721_RECEIVED = 0x150b7a02;

    /// @dev Id of the ERC165 interface
    bytes4 private constant InterfaceId_ERC165 = 0x01ffc9a7;

    /// @dev Id of the ERC721 interface
    bytes4 private constant InterfaceId_ERC721 = 0x80ac58cd;

    string internal _name;

    string internal _symbol;

    string internal _baseURI;

    /// @dev Amount of NFT tokens in circulation
    uint256 internal _tokensCount;

    /// @dev Index of the token inside owner's tokens array
    mapping(uint256 => uint256) internal _indexOfToken;

    /// @dev Reflets weather token is locked
    mapping(uint256 => bool) internal _isLocked;

    /// @dev Reflects owner of a token
    mapping(uint256 => address) internal _tokenOwner;

    /// @dev Reflects operator of a token
    mapping(uint256 => address) internal _tokenOperator;

    /// @dev Array of the user's tokens in holding
    mapping(address => uint256[]) internal _userTokens;

    /// @dev Reflects weather an address can operate all of the user's tokens
    mapping(address => mapping(address => bool)) internal _operatorForAll;

    /// @dev Modifier that reverts if caller is not authorized for given token
    modifier onlyAuthorized(uint256 _tokenId) {
        require(
            _isAuthorized(msg.sender, _tokenId),
            "ERC721Base: You are not authorized to call this function"
        );
        _;
    }

    /// @dev Modifier that reverts if token is locked
    modifier onlyUnlockedToken(uint256 _tokenId) {
        require(
            !_isLocked[_tokenId],
            "ERC721Base: This token is locked and can not be used"
        );
        _;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function baseURI() external view returns (string memory) {
        return _baseURI;
    }
    
    /**
     * @notice Returns weather contract supports fiven interface
     * @dev This contract supports ERC165 and ERC721 interfaces
     * @param _interfaceId id of the interface which is checked to be supported
     * @return true - given interface is supported, false - given interface is not supported
     */
    function supportsInterface(bytes4 _interfaceId)
        external
        pure
        returns (bool)
    {
        return
            _interfaceId == InterfaceId_ERC165 ||
            _interfaceId == InterfaceId_ERC721;
    }

    /// @notice Total amount of NFT tokens in circulation
    function totalSupply() external view returns (uint256) {
        return _tokensCount;
    }

    /**
     * @notice Gives the number of NFT tokens that a given user owns
     * @param _owner address of the user who's token's count will be returned
     * @return amount of tokens given user owns
     */
    function balanceOf(address _owner) external view returns (uint256) {
        return _userTokens[_owner].length;
    }

    function tokensOf(address _owner) external view returns (uint256[] memory) {
        return _userTokens[_owner];
    }

    /**
     * @notice Tells weather a token exists
     * @param _tokenId id of the token who's existence is returned
     * @return true - exists, false - does not exist
     */
    function exists(uint256 _tokenId) external view returns (bool) {
        return _exists(_tokenId);
    }

    /**
     * @notice Tells weather a token is locked
     * @param _tokenId id of the token who's lock status is returned
     * @return true - is locked, false - is not locked
     */
    function isLocked(uint256 _tokenId) external view returns (bool) {
        return _isLocked[_tokenId];
    }

    /**
     * @notice Gives owner address of a given token
     * @param _tokenId id of the token who's owner address is returned
     * @return address of the given token owner
     */
    function ownerOf(uint256 _tokenId) external view returns (address) {
        return _ownerOf(_tokenId);
    }

    /**
     * @notice Gives the approved address of the given token
     * @param _tokenId id of the token who's approved user is returned
     * @return address of the user who is approved for the given token
     */
    function getApproved(uint256 _tokenId) external view returns (address) {
        return _getApproved(_tokenId);
    }

    /**
     * @notice Tells weather given user (_operator) is approved to use given token (_tokenId)
     * @param _operator address of the user who's checked to be approved for given token
     * @param _tokenId id of the token for which approval will be checked
     * @return true - approved, false - disapproved
     */
    function isAuthorized(address _operator, uint256 _tokenId)
        external
        view
        returns (bool)
    {
        return _isAuthorized(_operator, _tokenId);
    }

    /**
     * @notice Tells weather given user (_operator) is approved to use tokens of another given user (_owner)
     * @param _owner address of the user who's tokens are checked to be aproved to another user
     * @param _operator address of the user who's checked to be approved by owner of the tokens
     * @return true - approved, false - disapproved
     */
    function isApprovedForAll(address _owner, address _operator)
        external
        view
        returns (bool)
    {
        return _isApprovedForAll(_owner, _operator);
    }

    /**
     * @notice Approves an address to use given token
     *         Only authorized users can call this function
     * @dev Only one user can be approved at any given moment
     * @param _approved address of the user who gets approved
     * @param _tokenId id of the token the given user get aproval on
     */
    function approve(address _approved, uint256 _tokenId)
        external
        onlyAuthorized(_tokenId)
    {
        require(
            _approved != _tokenOperator[_tokenId],
            "ERC721Base: Address is already an operator"
        );
        _tokenOperator[_tokenId] = _approved;
        emit Approval(_tokenOwner[_tokenId], _approved, _tokenId);
    }

    /**
     * @notice Approves or disapproves an address to use all tokens of the caller
     * @param _operator address of the user who gets approved/disapproved
     * @param _approved true - approves, false - disapproves
     */
    function setApprovalForAll(address _operator, bool _approved) external {
        require(
            _operatorForAll[msg.sender][_operator] != _approved,
            "ERC721Base: Address already has this approval status"
        );
        _operatorForAll[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    /**
     * @notice Transfers token and checkes weather it was recieved if reciver is ERC721Reciver contract
     *         Only authorized users can call this function
     *         Only unlocked tokens can be used to transfer
     * @dev When calling "onERC721Received" function passes "_data" from this function arguments
     * @param _from address of the user from whom token is transfered
     * @param _to address of the user who will recive the token
     * @param _tokenId id of the token which will be transfered
     * @param _data argument which will be passed to "onERC721Received" function
     */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory _data
    ) external onlyUnlockedToken(_tokenId) {
        _transferToken(_from, _to, _tokenId, _data, true);
    }

    /**
     * @notice Transfers token and checkes weather it was recieved if reciver is ERC721Reciver contract
     *         Only authorized users can call this function
     *         Only unlocked tokens can be used to transfer
     * @dev When calling "onERC721Received" function passes an empty string for "data" parameter
     * @param _from address of the user from whom token is transfered
     * @param _to address of the user who will recive the token
     * @param _tokenId id of the token which will be transfered
     */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external onlyUnlockedToken(_tokenId) {
        _transferToken(_from, _to, _tokenId, "", true);
    }

    /**
     * @notice Transfers token without checking weather it was recieved
     *         Only authorized users can call this function
     *         Only unlocked tokens can be used to transfer
     * @dev Does not call "onERC721Received" function even if the reciver is ERC721TokenReceiver
     * @param _from address of the user from whom token is transfered
     * @param _to address of the user who will recive the token
     * @param _tokenId id of the token which will be transfered
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external onlyUnlockedToken(_tokenId) {
        _transferToken(_from, _to, _tokenId, "", false);
    }

    function _setName(string memory _newName) internal {
        _name = _newName;
    }

    function _setSymbol(string memory _newSymbol) internal {
        _symbol = _newSymbol;
    }

    function _setBaseURI(string memory _newBaseURI) internal {
        _baseURI = _newBaseURI;
    }

    /**
     * @dev Tells weather given user (_operator) is approved to use given token (_tokenId)
     * @param _operator address of the user who's checked to be approved for given token
     * @param _tokenId id of the token for which approval will be checked
     * @return true - approved, false - disapproved
     */
    function _isAuthorized(address _operator, uint256 _tokenId)
        internal
        view
        returns (bool)
    {
        require(
            _operator != address(0),
            "ERC721Base: Operator address can not be address 0"
        );
        address tokenOwner = _tokenOwner[_tokenId];
        return
            _operator == tokenOwner ||
            _isApprovedForAll(tokenOwner, _operator) ||
            _getApproved(_tokenId) == _operator;
    }

    function _mintFor(uint256 _tokenId, address _owner) internal {
        require(
            _tokenOwner[_tokenId] == address(0),
            "ERC721Base: Token has already been minted"
        );
        _addTokenTo(_owner, _tokenId);
        emit Transfer(address(0), _owner, _tokenId);
    }

    /**
     * @dev Adds or removes locking on given token
     *         Locked tokens can not be transfered by anyone
     * @param _tokenId token which will be locked or unlocked
     * @param _lock true- lock the token, false - unlock the token
     */
    function _changeTokenLocking(uint256 _tokenId, bool _lock) internal {
        require(
            _isLocked[_tokenId] != _lock,
            "ERC721Base: This token already has this locking status"
        );
        _isLocked[_tokenId] = _lock;
        emit LockStatusSet(_tokenId, _lock);
    }

    /**
     * @dev Tells weather given user (_operator) is approved to use tokens of another given user (_owner)
     * @param _owner address of the user who's tokens are checked to be aproved to another user
     * @param _operator address of the user who's checked to be approved by owner of the tokens
     * @return true - approved, false - disapproved
     */
    function _isApprovedForAll(address _owner, address _operator)
        internal
        view
        returns (bool)
    {
        return _operatorForAll[_owner][_operator];
    }

    /**
     * @dev Gives the approved address of the given token
     * @param _tokenId id of the token who's approved user is returned
     * @return address of the user who is approved for the given token
     */
    function _getApproved(uint256 _tokenId) internal view returns (address) {
        return _tokenOperator[_tokenId];
    }

    /**
     * @dev This function is called from all the different transfer functions
     * @param _from address of the user from whom token is transfered
     * @param _to address of the user who will recive the token
     * @param _tokenId id of the token which will be transfered
     * @param _data argument which will be passed to "onERC721Received" function
     */
    function _transferToken(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory _data,
        bool _check
    ) internal onlyAuthorized(_tokenId) onlyUnlockedToken(_tokenId) {
        require(_to != address(0), "ERC721Base: Can not transfer to address 0");
        address tokenOwner = _tokenOwner[_tokenId];
        require(
            _to != tokenOwner,
            "ERC721Base: Can not transfer token to its owner"
        );
        require(
            _from == tokenOwner,
            "ERC721Base: Address from does not match token owner"
        );

        _resetApproval(_tokenId);
        _removeTokenFrom(_from, _tokenId);
        _addTokenTo(_to, _tokenId);
        emit Transfer(tokenOwner, _to, _tokenId);

        if (_check && _isContract(_to)) {
            require(
                IERC721TokenReceiver(_to).onERC721Received(
                    msg.sender,
                    _from,
                    _tokenId,
                    _data
                ) == ERC721_RECEIVED,
                "ERC721Base: Token was not received"
            );
        }
    }

    /**
     * @dev Resets approval of the given token
     * @param _tokenId id of the tokens who's approval will be resetn
     */
    function _resetApproval(uint256 _tokenId) private {
        _tokenOperator[_tokenId] = address(0);
        emit Approval(_tokenOwner[_tokenId], address(0), _tokenId);
    }

    /**
     * @dev Removes given token from the given addrese's ownership
     * @param _from address of the user from whom the token will be removed
     * @param _tokenId id of the tokens that will be removed
     */
    function _removeTokenFrom(address _from, uint256 _tokenId) internal {
        uint256 tokenIndex = _indexOfToken[_tokenId];
        uint256 lastTokenIndex = _userTokens[_from].length.sub(1);
        uint256 lastTokenId = _userTokens[_from][lastTokenIndex];

        if(lastTokenId != 0) {
            _userTokens[_from][tokenIndex] = lastTokenId;
            _indexOfToken[lastTokenId] = tokenIndex;
        }

        _userTokens[_from].pop();

        _tokenOwner[_tokenId] = address(0);
        _tokensCount = _tokensCount.sub(1);
    }

    /**
     * @dev Sets given address as owner for the given token
     * @param _to address to which token will be tranfered
     * @param _tokenId id of the tokens that will be transfered
     */
    function _addTokenTo(address _to, uint256 _tokenId) internal {
        _tokenOwner[_tokenId] = _to;
        _userTokens[_to].push(_tokenId);
        _indexOfToken[_tokenId] = _userTokens[_to].length;
        _tokensCount = _tokensCount.add(1);
    }

    function _ownerOf(uint256 _tokenId) internal view returns (address) {
        return _tokenOwner[_tokenId];
    }

    function _exists(uint256 _tokenId) internal view returns (bool) {
        return _tokenOwner[_tokenId] != address(0);
    }

    /**
     * @dev Tells weather given address is contract or not
     * @param _to address which will be checked to be contract address
     * @return true - is a contract address, false - is not a contract address
     */
    function _isContract(address _to) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_to)
        }
        return size > 0;
    }

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "./IERC721Base.sol";

interface IParcel is IERC721Base {
    function getTokenId(int256 _x, int256 _y)
        external
        view
        returns (uint256 tokenId);

    function getX(uint256 _tokenId) external view returns (int256);

    function getY(uint256 _tokenId) external view returns (int256);

    function mintParcelFor(
        address _beneficiary,
        int256 _x,
        int256 _y
    ) external;

    function mintParcelFor(address _beneficiary, uint256 _tokenId) external;

    function mintMultipleParcelsFor(
        address _beneficiary,
        int256[] memory _x,
        int256[] memory _y
    ) external;

    function mintAdjacentQuadraticParcels(
        address _beneficiary,
        int256 _x,
        int256 _y,
        uint256 _size
    ) external;

    function transferParcelFrom(
        address _from,
        address _to,
        int256 _x,
        int256 _y
    ) external;

    function transferMultipleParcels(
        address _to,
        int256[] memory _x,
        int256[] memory _y
    ) external;

    function transferAdjacentQuadraticParcels(
        address _to,
        int256 _x,
        int256 _y,
        uint256 _size
    ) external;

    function parcelExists(int256 _x, int256 _y) external view returns (bool);

    function ownerOfParcel(int256 _x, int256 _y)
        external
        view
        returns (address);

    function ownersOfMultipleParcels(int256[] memory _x, int256[] memory _y)
        external
        view
        returns (address[] memory ownerAddresses);

    function allParcelsOf(address _owner)
        external
        view
        returns (int256[] memory x, int256[] memory y);


}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface IERC165 {

    /**
     * @notice Returns weather contract supports fiven interface
     * @dev This contract supports ERC165 and ERC721 interfaces
     * @param _interfaceId id of the interface which is checked to be supported
     * @return true - given interface is supported, false - given interface is not supported
     */
    function supportsInterface(bytes4 _interfaceId) external view returns (bool);
    
}

// SPDX-License-Identifier: MIT

import "./IERC165.sol";
import "./IERC721Lockable.sol";
import "./IERC721Metadata.sol";

pragma solidity ^0.8.14;

interface IERC721Base is IERC165, IERC721Lockable, IERC721Metadata{
    /**
     * @dev This event is emitted when token is transfered
     * @param _from address of the user from whom token is transfered
     * @param _to address of the user who will recive the token
     * @param _tokenId id of the token which will be transfered
     */
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );

    /**
     * @dev This event is emitted when user is approved for token
     * @param _owner address of the owner of the token
     * @param _approval address of the user who gets approved
     * @param _tokenId id of the token that gets approved
     */
    event Approval(
        address indexed _owner,
        address indexed _approval,
        uint256 indexed _tokenId
    );

    /**
     * @dev This event is emitted when an address is approved/disapproved for another user's tokens
     * @param _owner address of the user whos tokens are being approved/disapproved to be used
     * @param _operator address of the user who gets approved/disapproved
     * @param _approved true - approves, false - disapproves
     */
    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );

    /// @notice Total amount of NFT tokens in circulation
    function totalSupply() external view returns (uint256);

    /**
     * @notice Gives the number of NFT tokens that a given user owns
     * @param _owner address of the user who's token's count will be returned
     * @return amount of tokens given user owns
     */
    function balanceOf(address _owner) external view returns (uint256);

    /**
     * @notice Tells weather a token exists
     * @param _tokenId id of the token who's existence is returned
     * @return true - exists, false - does not exist
     */
    function exists(uint256 _tokenId) external view returns (bool);

    /**
     * @notice Gives owner address of a given token
     * @param _tokenId id of the token who's owner address is returned
     * @return address of the given token owner
     */
    function ownerOf(uint256 _tokenId) external view returns (address);

    /**
     * @notice Transfers token and checkes weather it was recieved if reciver is ERC721Reciver contract
     *         Only authorized users can call this function
     *         Only unlocked tokens can be used to transfer
     * @dev When calling "onERC721Received" function passes "_data" from this function arguments
     * @param _from address of the user from whom token is transfered
     * @param _to address of the user who will recive the token
     * @param _tokenId id of the token which will be transfered
     * @param _data argument which will be passed to "onERC721Received" function
     */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory _data
    ) external;

    /**
     * @notice Transfers token and checkes weather it was recieved if reciver is ERC721Reciver contract
     *         Only authorized users can call this function
     *         Only unlocked tokens can be used to transfer
     * @dev When calling "onERC721Received" function passes an empty string for "data" parameter
     * @param _from address of the user from whom token is transfered
     * @param _to address of the user who will recive the token
     * @param _tokenId id of the token which will be transfered
     */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external;

    /**
     * @notice Transfers token without checking weather it was recieved
     *         Only authorized users can call this function
     *         Only unlocked tokens can be used to transfer
     * @dev Does not call "onERC721Received" function even if the reciver is ERC721TokenReceiver
     * @param _from address of the user from whom token is transfered
     * @param _to address of the user who will recive the token
     * @param _tokenId id of the token which will be transfered
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external;

    /**
     * @notice Approves an address to use given token
     *         Only authorized users can call this function
     * @dev Only one user can be approved at any given moment
     * @param _approved address of the user who gets approved
     * @param _tokenId id of the token the given user get aproval on
     */
    function approve(address _approved, uint256 _tokenId) external;

    /**
     * @notice Approves or disapproves an address to use all tokens of the caller
     * @param _operator address of the user who gets approved/disapproved
     * @param _approved true - approves, false - disapproves
     */
    function setApprovalForAll(address _operator, bool _approved) external;

    /**
     * @notice Gives the approved address of the given token
     * @param _tokenId id of the token who's approved user is returned
     * @return address of the user who is approved for the given token
     */
    function getApproved(uint256 _tokenId) external view returns (address);

    /**
     * @notice Tells weather given user (_operator) is approved to use tokens of another given user (_owner)
     * @param _owner address of the user who's tokens are checked to be aproved to another user
     * @param _operator address of the user who's checked to be approved by owner of the tokens
     * @return true - approved, false - disapproved
     */
    function isApprovedForAll(address _owner, address _operator)
        external
        view
        returns (bool);

    /**
     * @notice Tells weather given user (_operator) is approved to use given token (_tokenId)
     * @param _operator address of the user who's checked to be approved for given token
     * @param _tokenId id of the token for which approval will be checked
     * @return true - approved, false - disapproved
     */
    function isAuthorized(address _operator, uint256 _tokenId)
        external
        view
        returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface IERC721Lockable {

     /**
     * @dev Event that is emitted when token lock status is set
     * @param _tokenId id of the token who's lock status is set
     * @param _lock true - is locked, false - is not locked
     */
    event LockStatusSet(uint _tokenId, bool _lock);

     /**
     * @notice Tells weather a token is locked
     * @param _tokenId id of the token who's lock status is returned
     * @return true - is locked, false - is not locked
     */
    function isLocked(uint _tokenId) external view returns (bool);

}

// SPDX-License-Identifier: MIT 

pragma solidity 0.8.14;

interface IERC721Metadata {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function baseURI() external view returns (string memory);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface IERC721TokenReceiver {

    /**
     * @notice Returns data which is used to understand weather contract has recived given token
     * @param _operator address of the operator
     * @param _from address of the token owner
     * @param _tokenId id of the token for which was transfered
     * @param _data additional data with no specific format
     * @return Returns `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
     */
    function onERC721Received(address _operator, address _from, uint _tokenId, bytes calldata _data) external returns (bytes4);

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}