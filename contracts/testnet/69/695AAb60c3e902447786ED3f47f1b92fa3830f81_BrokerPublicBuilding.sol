// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "./Distributor.sol";
import "./interfaces/IActivatableNFT.sol";
import "./interfaces/IStandardParcel.sol";
import "./interfaces/IMiner.sol";
import "./interfaces/IBusinessParcel.sol";
import "./interfaces/IBrokerPublicBuilding.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

/**
    parcel Types 
    0: standartParcel;
    1: businesParcel;

    nftTypes for standartParcel
    0: aestheticNFT
    1: minerNFT

    nftTypes for businesParcel
    0: Broker
    1: Factory
    2: Bank
    3: nftMarketplace
 */

contract BrokerPublicBuilding is Distributor, Ownable, IBrokerPublicBuilding {

    uint256[2] public parcelMintingPricesInBNB;
    IBusinessParcel public businessParcelContract;
    IStandardParcel public standardParcelContract;
    uint256 public upgradePriceInBNB;
    IActivatableNFT[6] public nftContracts;

    constructor(IERC20 _distributionTokenAddress) {
        _setDistributionToken(_distributionTokenAddress);
    }

    function mintParcel(
        int256 _x,
        int256 _y,
        ParcelTypes _type
    ) external payable {
        require(_type <= ParcelTypes.Business, "BrokerPublicBuilding: Invalid parcel type");
        require(
            msg.value == parcelMintingPricesInBNB[uint8(_type)],
            "BrokerPublicBuilding: Invalid money amount"
        );

        require(
            !standardParcelContract.existsByCoordinates(_x, _y),
            "BrokerPublicBuilding: Parcel already exists as standard parcel"
        );
        require(
            !businessParcelContract.existsByCoordinates(_x, _y),
            "BrokerPublicBuilding: Parcel already exists"
        );
        if (ParcelTypes(_type) == ParcelTypes.Standard) {
            standardParcelContract.mintParcelFor(msg.sender, _x, _y);
        } else {
            businessParcelContract.mintParcelFor(msg.sender, _x, _y);
        }
    }

    function upgradeStandardParcel(int256 _x, int256 _y)
        external
        payable
    {
        uint tokenId = standardParcelContract.getTokenId(_x, _y);
        require(
            standardParcelContract.isAuthorized(msg.sender, tokenId),
            "BrokerPublicBuilding: You are not authorized to upgrade this parcel"
        );
        require(
            msg.value == upgradePriceInBNB,
            "BrokerPublicBuilding: Invalid money amount "
        );
        standardParcelContract.upgradeParcel(_x, _y);
    }

    function assignNFT(
        int256 _x,
        int256 _y,
        ParcelNFTTypes _nftType,
        ParcelTypes _parcelType,
        uint256 _nftTokenId
    ) external {
        require(_parcelType <= ParcelTypes.Business, "BrokerPublicBuilding: Invalid parcel type");
        require(_nftType <= ParcelNFTTypes.NFTMarketplace, "BrokerPublicBuilding: invalid nft Type");
        if (ParcelTypes(_parcelType) == ParcelTypes.Standard) {
            require(
                msg.sender == standardParcelContract.ownerOfParcel(_x, _y),
                "BrokerPublicBuilding: You are not the owner of this Parcel"
            );
            require(
                msg.sender == nftContracts[uint8(_nftType)].ownerOf(_nftTokenId),
                "BrokerPublicBuilding: You are not the owner of this NFT"
            );
            require(
                !nftContracts[uint8(_nftType)].isLocked(_nftTokenId),
                "BrokerPublicBuilding: NFT is already assigned"
            );
            require(
                _nftType <= ParcelNFTTypes.Aesthetic, 
                "BrokerPublicBuilding: This Type of building can not be place on standard parcel"
            );

            if(_nftType == ParcelNFTTypes.Aesthetic) {
                standardParcelContract.assignNFT(
                    IStandardParcel.ActivatableNFTs.Aesthetic, 
                    _x, _y,
                     _nftTokenId
                );
            } else {
                standardParcelContract.assignNFT(
                    IStandardParcel.ActivatableNFTs.Miner, 
                    _x, _y, 
                    _nftTokenId
                );
            }

            nftContracts[uint8(_nftType)].changeTokenLocking(_nftTokenId, true);
        } else {
            require(
                msg.sender == businessParcelContract.ownerOfParcel(_x, _y),
                "BrokerPublicBuilding: You are not the owner of this Parcel"
            );
            require(
                msg.sender == nftContracts[uint8(_nftType)].ownerOf(_nftTokenId),
                "BrokerPublicBuilding: You are not the owner of this NFT"
            );
            require(
                !nftContracts[uint8(_nftType)].isLocked(_nftTokenId),
                "BrokerPublicBuilding: NFT already assigned"
            );
            require(
                _nftType >=  ParcelNFTTypes.Aesthetic, 
                "BrokerPublicBuilding: This Type of building can not be place on business parcel"
            );

            if(_nftType == ParcelNFTTypes.Aesthetic) {
                businessParcelContract.assignNFT(
                    IBusinessParcel.PublicBuildings.Aesthetic, 
                    _x, _y, 
                    _nftTokenId
                );
            } else if(_nftType == ParcelNFTTypes.Broker) {
                businessParcelContract.assignNFT(
                    IBusinessParcel.PublicBuildings.Broker, 
                    _x, _y, 
                    _nftTokenId
                );
                _addNFTStaking(msg.sender);
            } else if(_nftType == ParcelNFTTypes.Factory) {
                businessParcelContract.assignNFT(
                    IBusinessParcel.PublicBuildings.Factory,
                    _x, _y, 
                    _nftTokenId
                );
            } else if(_nftType == ParcelNFTTypes.Bank) {
                businessParcelContract.assignNFT(
                    IBusinessParcel.PublicBuildings.Bank, 
                    _x, _y,
                     _nftTokenId
                );
            } else {
                businessParcelContract.assignNFT(
                    IBusinessParcel.PublicBuildings.NFTMarketplace,
                    _x, _y,
                    _nftTokenId
                );
            }

            nftContracts[uint8(_nftType)].changeTokenLocking(_nftTokenId, true);
        }
    }

    function unassignNFT(
        int256 _x,
        int256 _y,
        ParcelNFTTypes _nftType,
        ParcelTypes _parcelType,
        uint256 _nftTokenId
    ) external {
        require(_parcelType <= ParcelTypes.Business, "BrokerPublicBuilding: Invalid parcel type");
        require(_nftType <= ParcelNFTTypes.NFTMarketplace, "BrokerPublicBuilding: invalid NFT Type");
        if (_parcelType == ParcelTypes.Standard) {
            require(
                msg.sender == standardParcelContract.ownerOfParcel(_x, _y),
                "BrokerPublicBuilding: You are not the owner of this Parcel"
            );
            require(
                msg.sender == nftContracts[uint8(_nftType)].ownerOf(_nftTokenId),
                "BrokerPublicBuilding: You are not the owner of this NFT"
            );
            require(
                nftContracts[uint8(_nftType)].isLocked(_nftTokenId),
                "BrokerPublicBuilding: NFT already unAssigned"
            );
            require(
                _nftType <= ParcelNFTTypes.Aesthetic, 
                "BrokerPublicBuilding: This Type of building can not be place on standard parcel"
            );
            if(_nftType == ParcelNFTTypes.Aesthetic) {
                standardParcelContract.unassignNFT(
                    IStandardParcel.ActivatableNFTs.Aesthetic, 
                    _x, _y, 
                    _nftTokenId
                );
            } else {
                standardParcelContract.unassignNFT(
                    IStandardParcel.ActivatableNFTs.Miner, 
                    _x, _y, 
                    _nftTokenId
                );
            }
            nftContracts[uint8(_nftType)].changeTokenLocking(_nftTokenId, false);
        } else {
            require(
                msg.sender == businessParcelContract.ownerOfParcel(_x, _y),
                "BrokerPublicBuilding: You aren't owner of this Parcel"
            );
            require(
                msg.sender == nftContracts[uint8(_nftType)].ownerOf(_nftTokenId),
                "BrokerPublicBuilding: You aren't owner of this NFT"
            );
            require(
                nftContracts[uint8(_nftType)].isLocked(_nftTokenId),
                "BrokerPublicBuilding: NFT already unAssigned"
            );
            require(
                _nftType >= ParcelNFTTypes.Aesthetic, 
                "BrokerPublicBuilding: This Type of building can not be place on business parcel"
            );

            if(_nftType == ParcelNFTTypes.Aesthetic) {
                businessParcelContract.unassignNFT(
                    IBusinessParcel.PublicBuildings.Aesthetic, 
                    _x, _y, 
                    _nftTokenId
                );
            } else if(_nftType == ParcelNFTTypes.Broker) {
                businessParcelContract.unassignNFT(
                    IBusinessParcel.PublicBuildings.Broker, 
                    _x, _y, 
                    _nftTokenId
                );
                _removeNFTStaking(msg.sender);
            } else if(_nftType == ParcelNFTTypes.Factory) {
                businessParcelContract.unassignNFT(
                    IBusinessParcel.PublicBuildings.Factory, 
                    _x, _y, 
                    _nftTokenId
                );
            } else if(_nftType == ParcelNFTTypes.Bank) {
                businessParcelContract.unassignNFT(
                    IBusinessParcel.PublicBuildings.Bank, 
                    _x, _y, 
                    _nftTokenId
                );
            } else {
                businessParcelContract.unassignNFT(
                    IBusinessParcel.PublicBuildings.NFTMarketplace, 
                    _x, _y, 
                    _nftTokenId
                );
            }
            nftContracts[uint8(_nftType)].changeTokenLocking(_nftTokenId, false);
        }
    }

    function getParcelIdFromNFTId(
        ParcelNFTTypes _nftTokenType,
        ParcelTypes _parcelType,
        uint256 _nftTokenId
    ) external view returns (uint256) {
        require(_nftTokenId != 0, "BrokerPublicBuilding: Invalid token ID");
        require(_parcelType <= ParcelTypes.Business, "BrokerPublicBuilding: Invalid Parcel type");
        require(_nftTokenType <= ParcelNFTTypes.NFTMarketplace, "BrokerPublicBuilding: Invalid NFT type");
        if (_parcelType == ParcelTypes.Standard) {
            if (_nftTokenType == ParcelNFTTypes.Aesthetic) {
                return standardParcelContract.getNFTParcel(
                    IStandardParcel.ActivatableNFTs.Aesthetic, 
                    _nftTokenId
                );
            } else {
                return standardParcelContract.getNFTParcel(
                    IStandardParcel.ActivatableNFTs.Miner, 
                    _nftTokenId
                );
            }
        } else {

            if(_nftTokenType == ParcelNFTTypes.Aesthetic) {
                return businessParcelContract.getNFTParcel(
                    IBusinessParcel.PublicBuildings.Aesthetic, 
                    _nftTokenId
                );
            } else if(_nftTokenType == ParcelNFTTypes.Broker) {
                return businessParcelContract.getNFTParcel(
                    IBusinessParcel.PublicBuildings.Broker,
                    _nftTokenId
                );
            } else if(_nftTokenType == ParcelNFTTypes.Factory) {
                return businessParcelContract.getNFTParcel(
                    IBusinessParcel.PublicBuildings.Factory,
                    _nftTokenId
                );
            } else if(_nftTokenType == ParcelNFTTypes.Bank) {
                return businessParcelContract.getNFTParcel(
                    IBusinessParcel.PublicBuildings.Bank, 
                    _nftTokenId
                );
            } else {
                return businessParcelContract.getNFTParcel(
                    IBusinessParcel.PublicBuildings.NFTMarketplace, 
                    _nftTokenId
                );
            }
        }
    }

    function setNFTContract(
        IActivatableNFT _ActivatableNFTContract, 
        ParcelNFTTypes _nftType
        ) external
        onlyOwner
    {
        nftContracts[uint(_nftType)] = _ActivatableNFTContract;
    }

    function setParcelMintingPrice(uint256 _price, ParcelTypes _parcelType)
        external
        onlyOwner
    {
        parcelMintingPricesInBNB[uint(_parcelType)] = _price;
    }

    function setUpgradePrice(uint256 _price) external onlyOwner {
        upgradePriceInBNB = _price;
    }

    function setBusinessParcelContract(IBusinessParcel _contract)
        external
        onlyOwner
    {
        businessParcelContract = _contract;
    }

    function setStandardParcelContract(IStandardParcel _contract)
        external
        onlyOwner
    {
        standardParcelContract = _contract;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./interfaces/IDistributor.sol";

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract Distributor is IDistributor {
    /// @dev This contract uses SafeERC20 libraries functions
    using SafeERC20 for IERC20;

    /// @notice Amount of users that have staked NFTs now
    uint256 internal usersCount;

    /// @notice Amount of NFTs that have been staked
    uint256 internal stakedNFTsCount;

    /// @notice Addresses of all users who have their NFTs staked
    address[] internal NFTStakers;

    /// @notice Record of amount of staked NFT's of user
    mapping(address => uint256) internal userNFTCount;

    /// @notice Record of amount of pending rewards of user
    mapping(address => uint256) internal userPendingRewards;

    /// @notice Token which contract recives and distributes
    IERC20 internal distributionToken;

    /// @notice Event that is emitted when distribution token address is set
    event DistributionTokenContractAddressSet(
        address indexed distributionTokenContractAddress
    );

    function getUsersCount() external view returns (uint) {
        return usersCount;
    }

    function getNftsCount() external view returns (uint) {
        return stakedNFTsCount;
    }

    function getUsers() external view returns (address[] memory) {
        return NFTStakers;
    }

    function getUserActiveNFTCount(address _userAddress) external view returns (uint) {
        return userNFTCount[_userAddress];
    }

    function getUserPendingRewards(address _userAddress) external view returns (uint) {
        return userPendingRewards[_userAddress];
    }

    function getDistributionToken() external view returns (address) {
        return address(distributionToken);
    }


    /**
     * @notice Function which sets distribution token contract address
     *         Only contract owner can call this function
     * @param _distributionToken address of distribution token contract
     */
    function _setDistributionToken(IERC20 _distributionToken) internal {
        require(
            address(_distributionToken) != address(0),
            "Distributor: Distribution token contract address can not be address 0"
        );
        require(
            address(_distributionToken) != address(distributionToken),
            "Distributor: Distribution contract address is already set to this address"
        );
        distributionToken = _distributionToken;
        emit DistributionTokenContractAddressSet(address(distributionToken));
    }

    /**
     * @notice Function which distributes rewards
     *         Only manager contract can call this function
     * @param _amount amount of tokens that will be distributed
     */
    function _distributeRewards(uint256 _amount) internal {
        uint256 rewardPerToken = _amount / stakedNFTsCount;
        for (uint256 i; i < NFTStakers.length; i++) {
            address user = NFTStakers[i];
            userPendingRewards[user] += rewardPerToken * userNFTCount[user];
        }
        emit RewardsDistributed(_amount);
    }

    /**
     * @notice Function which adds a new NFT staking
     *         Only manager contract can call this function
     * @param _userAddress address of the user who stakes
     */
    function _addNFTStaking(address _userAddress) internal {
        if(userNFTCount[_userAddress] == 0) {
            NFTStakers.push(_userAddress);
            usersCount++;
        }
        userNFTCount[_userAddress]++;
        stakedNFTsCount++;
        emit NFTStaked(_userAddress);
    }

    /**
     * @notice Function which unstakes NFT
     *         Only manager contract can call this function
     * @param _userAddress address of the user who unstakes
     */
    function _removeNFTStaking(address _userAddress) internal {
        require(userNFTCount[_userAddress] > 0, "Distributor: User does not have any NFTs Activated");
        if(userNFTCount[_userAddress] == 1) {
            _requestPayment(_userAddress);
            usersCount--;
            uint256 userIndex = _getUserIndex(_userAddress);
            NFTStakers[userIndex] = NFTStakers[NFTStakers.length - 1];
            NFTStakers.pop();
        }
        userNFTCount[_userAddress]--;
        stakedNFTsCount--;
        emit NFTUnstaked(_userAddress);
    }

    /**
     * @notice Function which sends pending rewards to given user
     *         Only manager contract can call this function
     * @param _userAddress address of the user who claims rewards
     */
    function _requestPayment(address _userAddress) internal {
        uint256 rewardAmount = userPendingRewards[_userAddress];
        userPendingRewards[_userAddress] = 0;
        emit RewardsClaimed(_userAddress, rewardAmount);
        distributionToken.safeTransfer(_userAddress, rewardAmount);
    }

    /**
     * @dev Function which finds index of given address in NFTStakers array
     * @param _userAddress address of the user who's index is found
     * @return index of the user
     */
    function getUserIndex(address _userAddress) external view returns (uint256) {
        return _getUserIndex(_userAddress);
    }

    function _getUserIndex(address _userAddress) internal view returns (uint256) {
        for (uint256 i; i < usersCount; i++) {
            if (_userAddress == NFTStakers[i]) {
                return i;
            }
        }
        return 0;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;
import "./IERC721Base.sol";

interface IActivatableNFT is IERC721Base {
    function changeTokenLocking(uint256 _tokenID, bool _lockStatus) external;
    function setBranchPublicBuildingContractAddress(address _brokerPBContractAddress) external;
    function getBranchPublicBuildingContractAddress() external view returns (address);
    function mintNFTTo(address _to) external returns(uint tokenId);
    function setBaseURI(string memory _uRI) external;
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

pragma solidity ^0.8.14;

import "./IParcel.sol";

interface IBusinessParcel is IParcel{

    enum PublicBuildings {Aesthetic, Broker, Factory, Bank, NFTMarketplace}

    function setParcelSlotsCount(uint8 _parcelSlotsCount) external;

    function assignNFT(
        PublicBuildings _publicBuildingType,
        int256 _x,
        int256 _y,
        uint256 _tokenId
    ) external;

    function unassignNFT(
        PublicBuildings _publicBuildingType,
        int256 _x,
        int256 _y,
        uint256 _tokenId
    ) external;

    function getParcelBuildings(
        PublicBuildings _publicBuildingType,
        int256 _x, 
        int256 _y
        ) external
        view
        returns (uint256);

    function getNFTParcel(PublicBuildings _publicBuildingType, uint256 _tokenId)
        external
        view
        returns (uint256);

    function existsByCoordinates(int256 _x, int256 _y)
        external
        view
        returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "./IActivatableNFT.sol";
import "./IStandardParcel.sol";
import "./IBusinessParcel.sol";

interface IBrokerPublicBuilding {

    enum ParcelTypes{Standard,  Business}
    enum ParcelNFTTypes {Miner, Aesthetic, Broker, Factory, Bank, NFTMarketplace}

    function mintParcel(
        int256 _x,
        int256 _y,
        ParcelTypes _type
    ) external payable ;

    function upgradeStandardParcel(int256 _x, int256 _y)
        external
        payable;

    function assignNFT(
        int256 _x,
        int256 _y,
        ParcelNFTTypes _nftType,
        ParcelTypes _parcelType,
        uint256 _nftTokenId
    ) external;

    function unassignNFT(
        int256 _x,
        int256 _y,
        ParcelNFTTypes _nftType,
        ParcelTypes _parcelType,
        uint256 _nftTokenId
    ) external;

    function getParcelIdFromNFTId(
        ParcelNFTTypes _nftTokenType,
        ParcelTypes _parcelType,
        uint256 _nftTokenId
    ) external view returns (uint256);

    function setNFTContract(
        IActivatableNFT _ActivatableNFT, 
        ParcelNFTTypes _nftType
        ) external;

    function setParcelMintingPrice(
        uint256 _price, 
        ParcelTypes _parcelType
        ) external;

    function setUpgradePrice(uint256 _price) external;

    function setBusinessParcelContract(IBusinessParcel _contract) external;

    function setStandardParcelContract(IStandardParcel _contract) external;
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

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IDistributor {

    /// @notice Event that is emitted when rewards are distributed
    event RewardsDistributed(uint256 indexed amount);

    /// @notice Event that is emitted when rewards are claimed
    event RewardsClaimed(address indexed user, uint256 amount);

    /// @notice Event that is emitted when user stakes new NFT
    event NFTStaked(address indexed user);

    /// @notice Event that is emitted when user unstakes new NFT
    event NFTUnstaked(address indexed user);

    
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
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