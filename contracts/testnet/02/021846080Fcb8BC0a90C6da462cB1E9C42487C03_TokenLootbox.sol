// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2; // solhint-disable-line

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155HolderUpgradeable.sol";
import "@chainlink/contracts/src/v0.7/VRFConsumerBase.sol";

import "./base/roles/MarketAdminRole.sol";
import "./base/Lootbox.sol";

contract TokenLootbox is
  TLootbox,
  MarketAdminRole,
  ERC1155HolderUpgradeable
{
  constructor(
      address Coordinator,
      address LINK,
      bytes32 _keyHash
      // uint256 feeMultiplier
      ) TLootbox (
            Coordinator,
            LINK,
            _keyHash
            // 0.1
        ) {}
  
  /**
   * @notice Called once to configure the contract after the initial deployment.
   * @dev This farms the initialize call out to inherited contracts as needed.
   */
  function initialize(address payable treasury) public initializer {
    TreasuryNode._initializeTreasuryNode(treasury);
    TLootbox._initializeTokenLootbox();
  }
  
  function updateLootboxFee(uint256 _fee) public onlyMarketAdmin {
    _foundationFee = _fee;
  }

  function changeLinkFee(uint256 _fee) public onlyMarketAdmin {
    fee = _fee;      
  }
  
  function withdrawLink() public onlyMarketAdmin {
    LinkTokenInterface(LINK).transfer(msg.sender, LinkTokenInterface(LINK).balanceOf(address(this)));
  }

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./ERC1155ReceiverUpgradeable.sol";
import "../../proxy/Initializable.sol";

/**
 * @dev _Available since v3.1._
 */
contract ERC1155HolderUpgradeable is Initializable, ERC1155ReceiverUpgradeable {
    function __ERC1155Holder_init() internal initializer {
        __ERC165_init_unchained();
        __ERC1155Receiver_init_unchained();
        __ERC1155Holder_init_unchained();
    }

    function __ERC1155Holder_init_unchained() internal initializer {
    }
    function onERC1155Received(address, address, uint256, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint256[] memory, uint256[] memory, bytes memory) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "./vendor/SafeMathChainlink.sol";

import "./interfaces/LinkTokenInterface.sol";

import "./VRFRequestIDBase.sol";

/** ****************************************************************************
 * @notice Interface for contracts using VRF randomness
 * *****************************************************************************
 * @dev PURPOSE
 *
 * @dev Reggie the Random Oracle (not his real job) wants to provide randomness
 * @dev to Vera the verifier in such a way that Vera can be sure he's not
 * @dev making his output up to suit himself. Reggie provides Vera a public key
 * @dev to which he knows the secret key. Each time Vera provides a seed to
 * @dev Reggie, he gives back a value which is computed completely
 * @dev deterministically from the seed and the secret key.
 *
 * @dev Reggie provides a proof by which Vera can verify that the output was
 * @dev correctly computed once Reggie tells it to her, but without that proof,
 * @dev the output is indistinguishable to her from a uniform random sample
 * @dev from the output space.
 *
 * @dev The purpose of this contract is to make it easy for unrelated contracts
 * @dev to talk to Vera the verifier about the work Reggie is doing, to provide
 * @dev simple access to a verifiable source of randomness.
 * *****************************************************************************
 * @dev USAGE
 *
 * @dev Calling contracts must inherit from VRFConsumerBase, and can
 * @dev initialize VRFConsumerBase's attributes in their constructor as
 * @dev shown:
 *
 * @dev   contract VRFConsumer {
 * @dev     constuctor(<other arguments>, address _vrfCoordinator, address _link)
 * @dev       VRFConsumerBase(_vrfCoordinator, _link) public {
 * @dev         <initialization with other arguments goes here>
 * @dev       }
 * @dev   }
 *
 * @dev The oracle will have given you an ID for the VRF keypair they have
 * @dev committed to (let's call it keyHash), and have told you the minimum LINK
 * @dev price for VRF service. Make sure your contract has sufficient LINK, and
 * @dev call requestRandomness(keyHash, fee, seed), where seed is the input you
 * @dev want to generate randomness from.
 *
 * @dev Once the VRFCoordinator has received and validated the oracle's response
 * @dev to your request, it will call your contract's fulfillRandomness method.
 *
 * @dev The randomness argument to fulfillRandomness is the actual random value
 * @dev generated from your seed.
 *
 * @dev The requestId argument is generated from the keyHash and the seed by
 * @dev makeRequestId(keyHash, seed). If your contract could have concurrent
 * @dev requests open, you can use the requestId to track which seed is
 * @dev associated with which randomness. See VRFRequestIDBase.sol for more
 * @dev details. (See "SECURITY CONSIDERATIONS" for principles to keep in mind,
 * @dev if your contract could have multiple requests in flight simultaneously.)
 *
 * @dev Colliding `requestId`s are cryptographically impossible as long as seeds
 * @dev differ. (Which is critical to making unpredictable randomness! See the
 * @dev next section.)
 *
 * *****************************************************************************
 * @dev SECURITY CONSIDERATIONS
 *
 * @dev A method with the ability to call your fulfillRandomness method directly
 * @dev could spoof a VRF response with any random value, so it's critical that
 * @dev it cannot be directly called by anything other than this base contract
 * @dev (specifically, by the VRFConsumerBase.rawFulfillRandomness method).
 *
 * @dev For your users to trust that your contract's random behavior is free
 * @dev from malicious interference, it's best if you can write it so that all
 * @dev behaviors implied by a VRF response are executed *during* your
 * @dev fulfillRandomness method. If your contract must store the response (or
 * @dev anything derived from it) and use it later, you must ensure that any
 * @dev user-significant behavior which depends on that stored value cannot be
 * @dev manipulated by a subsequent VRF request.
 *
 * @dev Similarly, both miners and the VRF oracle itself have some influence
 * @dev over the order in which VRF responses appear on the blockchain, so if
 * @dev your contract could have multiple VRF requests in flight simultaneously,
 * @dev you must ensure that the order in which the VRF responses arrive cannot
 * @dev be used to manipulate your contract's user-significant behavior.
 *
 * @dev Since the ultimate input to the VRF is mixed with the block hash of the
 * @dev block in which the request is made, user-provided seeds have no impact
 * @dev on its economic security properties. They are only included for API
 * @dev compatability with previous versions of this contract.
 *
 * @dev Since the block hash of the block which contains the requestRandomness
 * @dev call is mixed into the input to the VRF *last*, a sufficiently powerful
 * @dev miner could, in principle, fork the blockchain to evict the block
 * @dev containing the request, forcing the request to be included in a
 * @dev different block with a different hash, and therefore a different input
 * @dev to the VRF. However, such an attack would incur a substantial economic
 * @dev cost. This cost scales with the number of blocks the VRF oracle waits
 * @dev until it calls responds to a request.
 */
abstract contract VRFConsumerBase is VRFRequestIDBase {
  using SafeMathChainlink for uint256;

  /**
   * @notice fulfillRandomness handles the VRF response. Your contract must
   * @notice implement it. See "SECURITY CONSIDERATIONS" above for important
   * @notice principles to keep in mind when implementing your fulfillRandomness
   * @notice method.
   *
   * @dev VRFConsumerBase expects its subcontracts to have a method with this
   * @dev signature, and will call it once it has verified the proof
   * @dev associated with the randomness. (It is triggered via a call to
   * @dev rawFulfillRandomness, below.)
   *
   * @param requestId The Id initially returned by requestRandomness
   * @param randomness the VRF output
   */
  function fulfillRandomness(bytes32 requestId, uint256 randomness) internal virtual;

  /**
   * @dev In order to keep backwards compatibility we have kept the user
   * seed field around. We remove the use of it because given that the blockhash
   * enters later, it overrides whatever randomness the used seed provides.
   * Given that it adds no security, and can easily lead to misunderstandings,
   * we have removed it from usage and can now provide a simpler API.
   */
  uint256 private constant USER_SEED_PLACEHOLDER = 0;

  /**
   * @notice requestRandomness initiates a request for VRF output given _seed
   *
   * @dev The fulfillRandomness method receives the output, once it's provided
   * @dev by the Oracle, and verified by the vrfCoordinator.
   *
   * @dev The _keyHash must already be registered with the VRFCoordinator, and
   * @dev the _fee must exceed the fee specified during registration of the
   * @dev _keyHash.
   *
   * @dev The _seed parameter is vestigial, and is kept only for API
   * @dev compatibility with older versions. It can't *hurt* to mix in some of
   * @dev your own randomness, here, but it's not necessary because the VRF
   * @dev oracle will mix the hash of the block containing your request into the
   * @dev VRF seed it ultimately uses.
   *
   * @param _keyHash ID of public key against which randomness is generated
   * @param _fee The amount of LINK to send with the request
   *
   * @return requestId unique ID for this request
   *
   * @dev The returned requestId can be used to distinguish responses to
   * @dev concurrent requests. It is passed as the first argument to
   * @dev fulfillRandomness.
   */
  function requestRandomness(bytes32 _keyHash, uint256 _fee) internal returns (bytes32 requestId) {
    LINK.transferAndCall(vrfCoordinator, _fee, abi.encode(_keyHash, USER_SEED_PLACEHOLDER));
    // This is the seed passed to VRFCoordinator. The oracle will mix this with
    // the hash of the block containing this request to obtain the seed/input
    // which is finally passed to the VRF cryptographic machinery.
    uint256 vRFSeed = makeVRFInputSeed(_keyHash, USER_SEED_PLACEHOLDER, address(this), nonces[_keyHash]);
    // nonces[_keyHash] must stay in sync with
    // VRFCoordinator.nonces[_keyHash][this], which was incremented by the above
    // successful LINK.transferAndCall (in VRFCoordinator.randomnessRequest).
    // This provides protection against the user repeating their input seed,
    // which would result in a predictable/duplicate output, if multiple such
    // requests appeared in the same block.
    nonces[_keyHash] = nonces[_keyHash].add(1);
    return makeRequestId(_keyHash, vRFSeed);
  }

  LinkTokenInterface internal immutable LINK;
  address private immutable vrfCoordinator;

  // Nonces for each VRF key from which randomness has been requested.
  //
  // Must stay in sync with VRFCoordinator[_keyHash][this]
  mapping(bytes32 => uint256) /* keyHash */ /* nonce */
    private nonces;

  /**
   * @param _vrfCoordinator address of VRFCoordinator contract
   * @param _link address of LINK token contract
   *
   * @dev https://docs.chain.link/docs/link-token-contracts
   */
  constructor(address _vrfCoordinator, address _link) {
    vrfCoordinator = _vrfCoordinator;
    LINK = LinkTokenInterface(_link);
  }

  // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
  // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
  // the origin of the call
  function rawFulfillRandomness(bytes32 requestId, uint256 randomness) external {
    require(msg.sender == vrfCoordinator, "Only VRFCoordinator can fulfill");
    fulfillRandomness(requestId, randomness);
  }
}

// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.7.0;

import "../interfaces/IAdminRole.sol";

import "../TreasuryNode.sol";

/**
 * @notice Allows a contract to leverage the admin role defined by the market treasury.
 */
abstract contract MarketAdminRole is TreasuryNode {
  // This file uses 0 data slots (other than what's included via TreasuryNode)

  modifier onlyMarketAdmin() {
    require(_isMarketAdmin(), "MarketAdminRole: caller does not have the Admin role");
    _;
  }

  function _isMarketAdmin() internal view returns (bool) {
    return IAdminRole(getTreasury()).isAdmin(msg.sender);
  }
}

// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.7.6;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

import "@openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";
import "@chainlink/contracts/src/v0.7/VRFConsumerBase.sol";

import "./SendValueWithFallbackWithdraw.sol";
import "./TreasuryNode.sol";

abstract contract TLootbox is
    Initializable,
    SendValueWithFallbackWithdraw,
    TreasuryNode,
    VRFConsumerBase
{
    using SafeMathUpgradeable for uint256;

    uint256 _foundationFee;
    uint256 _lootboxId;
    mapping(uint256 => Lootbox) private lootboxIdToLootbox;
    mapping(address => uint256[]) sellerToLootboxes;

    mapping(uint256 => mapping(uint256 => mapping(uint256 => Token))) lootboxToRarityToTokenIndexToToken;
    mapping(uint256 => mapping(address => mapping(uint256 => uint256))) lootboxToContractToTokenIdToToken;
    mapping(uint256 => mapping(address => uint256)) lootboxToContractToAmount;
    mapping(uint256 => mapping(address => mapping(uint256 => uint256))) lootboxToContractToTokenIdToIndex;
    mapping(uint256 => mapping(address => uint256)) public lootboxToERC20ToPerDraw;

    //VRF variables
    bytes32 internal keyHash;
    uint256 internal fee;
    mapping(bytes32 => address) private requestIdToRoller;
    mapping(bytes32 => uint256) private requestIdToLootboxId;

    struct Rarity {
        uint256 chance;
        uint256 availableTokens;
    }
    struct Token {
        address contractAddress;
        uint256 tokenType;
        uint256 tokenId;
        uint256 amount;
        bool available;
        uint256 toTransfer;
    }

    struct Lootbox {
        string metadata;
        address payable seller;
        uint256 price;
        bool initialized;
        uint256[] raritiesArray;
        mapping(uint256 => Rarity) rarities;
        uint256[] raritiesSummarized;
    }

    //Events

    event LootboxCreated(
        address indexed seller,
        uint256[] rarities,
        uint256 Price,
        uint256 lootboxId,
        string metadata
    );

    event TokenAdded(
        address indexed seller,
        address indexed contractAddress,
        uint256 tokenId,
        uint256 lootboxId,
        uint256 rarity,
        uint256 amount,
        uint256 tokenType
    );

    event TokensAdded(
        address seller,
        address[] contracts,
        uint256[] tokenIds,
        uint256 lootboxId,
        uint256 rarity
    );

    event LootboxUpdated(bool status, string metadata, uint256 price);

    event statusChanged(uint256 lootboxId, bool status);

    event metadataChanged(uint256 lootboxId, string metadata);

    event priceChanged(uint256 lootboxId, uint256 price);

    event LootboxOpened(
        address indexed opener,
        address indexed contractAddress,
        uint256 tokenId,
        uint256 lootboxId,
        uint256 rarity,
        uint256 amount,
        bool success,
        bytes32 requestId
    );

    event BoxRolled(
        address indexed opener,
        uint256 lootboxId,
        bytes32 requestId
    );

    event TokenWithdraw(
        uint256 lootboxId,
        address contractAddress,
        uint256 tokenId,
        uint256 amount
    );

    constructor(
        address Coordinator,
        address LINK,
        bytes32 _keyHash
    )
        // uint256 feeMultiplier
        VRFConsumerBase(
            Coordinator, // VRF Coordinator
            LINK // LINK Token
        )
    {
        keyHash = _keyHash;
        fee = 0.1 * 10**18;
    }

    function getLinkFee() public view returns (uint256) {
        return fee;
    }

    //Modifiers and internal functions

    modifier lootboxOwnerOnly(uint256 LootboxId) {
        require(
            lootboxIdToLootbox[LootboxId].seller == msg.sender,
            "Lootbox owner only"
        );
        _;
    }

    function getIndexOfRarity(uint256 lootboxId, uint256 rarity)
        internal
        view
        returns (uint256 indexUnsigned)
    {
        Lootbox storage lootbox = lootboxIdToLootbox[lootboxId];
        int256 index = -1;
        for (uint256 i = 0; i < lootbox.raritiesArray.length; i++) {
            if (lootbox.raritiesArray[i] == rarity) {
                index = int256(i);
            }
        }
        require(index >= 0, "Wrong rarity specified");
        return uint256(index);
    }

    function _initializeTokenLootbox() internal {
        _lootboxId = 0;
    }

    function getRandomRarity(uint256 seed, uint256 lootboxId)
        internal
        view
        returns (uint256 rarity)
    {
        Lootbox storage lootbox = lootboxIdToLootbox[lootboxId];
        for (uint256 i = 0; i < lootbox.raritiesSummarized.length; i++) {
            if (i == 0 && (seed < lootbox.raritiesSummarized[i])) {
                return i;
            } else if (
                i < lootbox.raritiesSummarized.length - 1 &&
                i > 0 &&
                seed >= lootbox.raritiesSummarized[i - 1] &&
                seed < lootbox.raritiesSummarized[i]
            ) {
                return i;
            } else if (i == lootbox.raritiesSummarized.length - 1) {
                return i;
            }
        }
    }

    function _distributeFunds(address payable seller, uint256 price) internal {
        uint256 foundationFee = price.mul(_foundationFee) / 10000;
        uint256 sellerFee = price - foundationFee;
        _sendValueWithFallbackWithdrawWithLowGasLimit(
            getTreasury(),
            foundationFee
        );
        _sendValueWithFallbackWithdrawWithMediumGasLimit(seller, sellerFee);
    }

    //Lootbox methods

    //Creation
    function createLootbox(
        uint256[] memory _rarities,
        uint256 _price,
        string memory metadata
    ) public {
        uint256 raritySum;
        for (uint256 i = 0; i < _rarities.length; i++) {
            raritySum += _rarities[i];
        }
        require(_price > 0, "Price can't be set to 0");
        require(raritySum == 10000, "Sum of rarities is not equal to 10,000");
        require(
            bytes(metadata).length >= 46,
            "NFT721Metadata: Invalid IPFS path"
        );
        _lootboxId++;
        lootboxIdToLootbox[_lootboxId].metadata = metadata;
        lootboxIdToLootbox[_lootboxId].price = _price;
        lootboxIdToLootbox[_lootboxId].seller = msg.sender;
        lootboxIdToLootbox[_lootboxId].raritiesArray = _rarities;
        uint256 num = 0;
        for (uint256 i = 0; i < _rarities.length; i++) {
            lootboxIdToLootbox[_lootboxId].rarities[i].chance = _rarities[i];
            num += _rarities[i];
            lootboxIdToLootbox[_lootboxId].raritiesSummarized.push(num);
        }
        sellerToLootboxes[msg.sender].push(_lootboxId);
        emit LootboxCreated(
            msg.sender,
            _rarities,
            _price,
            _lootboxId,
            metadata
        );
    }

    //Lootbox status updates

    function startLootbox(uint256 lootboxId)
        public
        lootboxOwnerOnly(lootboxId)
    {
        Lootbox storage lootbox = lootboxIdToLootbox[lootboxId];
        require(lootbox.price != 0, "Lootbox not found");
        require(lootbox.initialized == false, "Lootbox already initialized");
        for (uint256 i = 0; i < lootbox.raritiesArray.length; i++) {
            require(
                lootbox.rarities[i].availableTokens > 0,
                "Can't initialize lootbox with empty rarities"
            );
        }
        lootbox.initialized = true;
        emit statusChanged(lootboxId, true);
    }

    function stopLootbox(uint256 lootboxId) public lootboxOwnerOnly(lootboxId) {
        Lootbox storage lootbox = lootboxIdToLootbox[lootboxId];
        require(lootbox.price != 0, "Lootbox not found");
        require(lootbox.initialized = true, "Lootbox already frozen");
        lootbox.initialized = false;
        emit statusChanged(lootboxId, false);
    }

    function changeLootboxMetadata(uint256 lootboxId, string memory metadata)
        public
        lootboxOwnerOnly(lootboxId)
    {
        require(
            bytes(metadata).length >= 46,
            "NFT721Metadata: Invalid IPFS path"
        );
        Lootbox storage lootbox = lootboxIdToLootbox[lootboxId];
        require(lootbox.price != 0, "Lootbox not found");
        lootbox.metadata = metadata;
        emit metadataChanged(lootboxId, metadata);
    }

    function changeLootboxPrice(uint256 lootboxId, uint256 price)
        public
        lootboxOwnerOnly(lootboxId)
    {
        require(price > 0, "Can't set price to 0");
        Lootbox storage lootbox = lootboxIdToLootbox[lootboxId];
        require(lootbox.price != 0, "Lootbox not found");
        lootbox.price = price;

        emit priceChanged(lootboxId, price);
    }

    // Adding tokens to lootbox

    //ERC721
    function addToken(
        address contractAddress,
        uint256 tokenId,
        uint256 rarity,
        uint256 lootboxId
    ) public lootboxOwnerOnly(lootboxId) {
        Lootbox storage lootbox = lootboxIdToLootbox[lootboxId];
        require(lootbox.price != 0, "Lootbox not found");
        require(lootbox.initialized == false, "Lootbox already initialized");

        Token memory token = Token(contractAddress, 721, tokenId, 1, true, 1);
        uint256 lootboxRarity = getIndexOfRarity(lootboxId, rarity);
        lootbox.rarities[lootboxRarity].availableTokens++;
        lootboxToRarityToTokenIndexToToken[lootboxId][lootboxRarity][lootbox.rarities[lootboxRarity].availableTokens]=token;
        lootboxToContractToTokenIdToToken[lootboxId][contractAddress][tokenId]=lootbox.rarities[lootboxRarity].availableTokens;
        IERC721Upgradeable(contractAddress).transferFrom(
            msg.sender,
            address(this),
            tokenId
        );
        emit TokenAdded(
            msg.sender,
            contractAddress,
            tokenId,
            lootboxId,
            rarity,
            1,
            721
        );
    }

    //ERC721 Bulk
    function addToken(
        address[] memory contracts,
        uint256[] memory tokenIds,
        uint256 rarity,
        uint256 lootboxId
    ) public lootboxOwnerOnly(lootboxId) {
        Lootbox storage lootbox = lootboxIdToLootbox[lootboxId];
        require(lootbox.price != 0, "Lootbox not found");
        require(lootbox.initialized == false, "Lootbox already initialized");
        uint256 lootboxRarity = getIndexOfRarity(lootboxId, rarity);
        for (uint256 i = 0; i < contracts.length; i++) {
            Token memory token = Token(contracts[i], 721, tokenIds[i], 1, true, 1);
            lootbox.rarities[lootboxRarity].availableTokens++;
            lootboxToRarityToTokenIndexToToken[lootboxId][lootboxRarity][lootbox.rarities[lootboxRarity].availableTokens]=token;
            lootboxToContractToTokenIdToToken[lootboxId][contracts[i]][tokenIds[i]]=lootbox.rarities[lootboxRarity].availableTokens;

            IERC721Upgradeable(contracts[i]).transferFrom(
                msg.sender,
                address(this),
                tokenIds[i]
            );
        }

        emit TokensAdded(msg.sender, contracts, tokenIds, lootboxId, rarity);
    }

    //ERC1155
    function addToken(
        address contractAddress,
        uint256 tokenId,
        uint256 rarity,
        uint256 lootboxId,
        uint256 amount
    ) public lootboxOwnerOnly(lootboxId) {
        Lootbox storage lootbox = lootboxIdToLootbox[lootboxId];
        require(lootbox.price != 0, "Lootbox not found");
        require(lootbox.initialized == false, "Lootbox already initialized");

        uint256 lootboxRarity = getIndexOfRarity(lootboxId, rarity);

        if(lootboxToContractToTokenIdToToken[lootboxId][contractAddress][tokenId]==0){
            Token memory token = Token(contractAddress, 1155, tokenId, amount, true, 1);
            for(uint256 i = 0; i<amount;i++){
                lootbox.rarities[lootboxRarity].availableTokens++;
                lootboxToRarityToTokenIndexToToken[lootboxId][lootboxRarity]
                    [lootbox.rarities[lootboxRarity].availableTokens] = token;
                }
            lootboxToContractToTokenIdToToken[lootboxId][contractAddress][tokenId] = 
                lootbox.rarities[lootboxRarity].availableTokens;    
        } else {
            Token memory token = lootboxToRarityToTokenIndexToToken[lootboxId][lootboxRarity]
                [lootboxToContractToTokenIdToToken[lootboxId][contractAddress][tokenId]];
            token.amount+=amount;
            for(uint256 i = 0; i< amount; i++) {
                lootbox.rarities[lootboxRarity].availableTokens++;
                lootboxToRarityToTokenIndexToToken[lootboxId][lootboxRarity]
                    [lootbox.rarities[lootboxRarity].availableTokens] = token;
            }
        }
        //     lootbox.rarities[lootboxRarity].availableTokens++;
        //     lootboxToRarityToTokenIndexToToken[lootboxId][lootboxRarity]
        //         [lootbox.rarities[lootboxRarity].availableTokens] = token;
        //     lootboxToContractToTokenIdToToken[lootboxId][contractAddress][tokenId] = 
        //         lootbox.rarities[lootboxRarity].availableTokens;
        // } else {
        //     lootboxToRarityToTokenIndexToToken[lootboxId][lootboxRarity]
        //         [lootboxToContractToTokenIdToToken[lootboxId][contractAddress][tokenId]].amount++;
        // }

        IERC1155Upgradeable(contractAddress).safeTransferFrom(
            msg.sender,
            address(this),
            tokenId,
            amount,
            ""
        );
        emit TokenAdded(
            msg.sender,
            contractAddress,
            tokenId,
            lootboxId,
            rarity,
            amount,
            1155
        );
    }

    //ERC20
    function addToken(
        uint256 rarity,
        uint256 lootboxId,
        uint256 amount,
        address contractAddress,
        uint256 perDraw
    ) public lootboxOwnerOnly(lootboxId) {
        Lootbox storage lootbox = lootboxIdToLootbox[lootboxId];
        require(lootbox.price != 0, "Lootbox not found");
        require(lootbox.initialized == false, "Lootbox already initialized");
        uint256 lootboxRarity = getIndexOfRarity(lootboxId, rarity);

        if(lootboxToContractToTokenIdToToken[lootboxId][contractAddress][0]==0){
            Token memory token = Token(contractAddress, 20, 0, amount, true, perDraw);
            lootboxToERC20ToPerDraw[lootboxId][contractAddress]=perDraw;
            for(uint256 i = 0; i<amount;i++){
                lootbox.rarities[lootboxRarity].availableTokens++;
                lootboxToRarityToTokenIndexToToken[lootboxId][lootboxRarity]
                    [lootbox.rarities[lootboxRarity].availableTokens] = token;
                }
            lootboxToContractToTokenIdToToken[lootboxId][contractAddress][0] = 
                lootbox.rarities[lootboxRarity].availableTokens;    
        } else {
            require(lootboxToERC20ToPerDraw[lootboxId][contractAddress]==perDraw,"Wrong ERC amount per draw");
            Token memory token = lootboxToRarityToTokenIndexToToken[lootboxId][lootboxRarity]
                [lootboxToContractToTokenIdToToken[lootboxId][contractAddress][0]];
            token.amount+=amount;
            for(uint256 i = 0; i< amount; i++) {
                lootbox.rarities[lootboxRarity].availableTokens++;
                lootboxToRarityToTokenIndexToToken[lootboxId][lootboxRarity]
                    [lootbox.rarities[lootboxRarity].availableTokens] = token;
            }
        }

        // if(lootboxToContractToAmount[lootboxId][contractAddress]==0){
        //     Token memory token = Token(contractAddress, 20, 0, amount, true, amount);
        //     lootbox.rarities[lootboxRarity].availableTokens++;
        //     lootboxToRarityToTokenIndexToToken[lootboxId][lootboxRarity][lootbox.rarities[lootboxRarity].availableTokens]=token;
        //     lootboxToContractToAmount[lootboxId][contractAddress]+=amount;
        //     lootboxToContractToTokenIdToToken[lootboxId][contractAddress][0] = 
        //         lootbox.rarities[lootboxRarity].availableTokens;
        // } else {
        //     lootboxToRarityToTokenIndexToToken[lootboxId][lootboxRarity][lootboxToContractToTokenIdToToken[lootboxId][contractAddress][0]].amount += amount;
        //     lootboxToContractToAmount[lootboxId][contractAddress] += amount;
        // }

        IERC20Upgradeable(contractAddress).transferFrom(
            msg.sender,
            address(this),
            amount*perDraw
        );
        emit TokenAdded(
            msg.sender,
            contractAddress,
            amount,
            lootboxId,
            rarity,
            amount*perDraw,
            20
        );
    }

    //Withdraw ERC721
    function withdrawToken(
        uint256 rarity,
        uint256 tokenId, 
        address contractAddress, 
        uint256 lootboxId
    ) public lootboxOwnerOnly(lootboxId) {
        Lootbox storage lootbox = lootboxIdToLootbox[lootboxId];
        require(lootbox.price != 0, "Lootbox not found");
        uint256 chosenToken = lootboxToContractToTokenIdToToken[lootboxId][contractAddress][tokenId];
        Token memory token = lootboxToRarityToTokenIndexToToken[lootboxId][rarity][chosenToken];
        require(token.available);
        if(chosenToken != lootbox.rarities[rarity].availableTokens) {
            lootboxToRarityToTokenIndexToToken[lootboxId][rarity][chosenToken] =
                lootboxToRarityToTokenIndexToToken[lootboxId][rarity][lootbox.rarities[rarity].availableTokens];
        }
        lootbox.rarities[rarity].availableTokens--;
        token.available = false;
        token.amount--;

        IERC721Upgradeable(contractAddress).transferFrom(address(this), msg.sender, tokenId);
        emit TokenWithdraw(lootboxId, contractAddress, tokenId, 1);
    }

    //Withdraw ERC1155
    function withdrawToken(
        uint256 rarity, 
        address contractAddress, 
        uint256 tokenId, 
        uint256 lootboxId,
        uint256 amount
    ) public lootboxOwnerOnly(lootboxId) {
        Lootbox storage lootbox = lootboxIdToLootbox[lootboxId];
        require(lootbox.price != 0, "Lootbox not found");
        uint256 chosenToken = lootboxToContractToTokenIdToToken[lootboxId][contractAddress][tokenId];
        Token memory token = lootboxToRarityToTokenIndexToToken[lootboxId][rarity][chosenToken];
        require(token.amount>=amount);
        if(token.amount-amount == 0) {
            if(chosenToken != lootbox.rarities[rarity].availableTokens) {
                lootboxToRarityToTokenIndexToToken[lootboxId][rarity][chosenToken] =
                    lootboxToRarityToTokenIndexToToken[lootboxId][rarity][lootbox.rarities[rarity].availableTokens];
            }
            lootbox.rarities[rarity].availableTokens--;
            token.available = false;
        }
        token.amount-=amount;

        IERC1155Upgradeable(contractAddress).safeTransferFrom(address(this), msg.sender, tokenId, amount, "");
        emit TokenWithdraw(lootboxId, contractAddress, tokenId, amount);
    }

    //Withdraw ERC20
    function withdrawToken(
        uint256 rarity, 
        address contractAddress, 
        uint256 lootboxId,
        uint256 amount
    ) public lootboxOwnerOnly(lootboxId) {
        Lootbox storage lootbox = lootboxIdToLootbox[lootboxId];
        require(lootbox.price != 0, "Lootbox not found");
        uint256 chosenToken = lootboxToContractToTokenIdToToken[lootboxId][contractAddress][0];
        Token memory token = lootboxToRarityToTokenIndexToToken[lootboxId][rarity][chosenToken];

        uint256 totalDeposited = token.amount*token.toTransfer;
        require(totalDeposited>=amount);
        require(totalDeposited%token.toTransfer==0);
        uint256 tokenInstancesToRemove = amount/token.toTransfer;
        token.amount-=tokenInstancesToRemove;

        uint256 cursor = lootbox.rarities[rarity].availableTokens;
        while(tokenInstancesToRemove>0){
            if(lootboxToRarityToTokenIndexToToken[lootboxId][rarity][cursor].contractAddress==contractAddress){
                if(cursor!=lootbox.rarities[rarity].availableTokens){
                    lootboxToRarityToTokenIndexToToken[lootboxId][rarity][cursor] = 
                        lootboxToRarityToTokenIndexToToken[lootboxId][rarity][lootbox.rarities[rarity].availableTokens];
                }
                lootbox.rarities[rarity].availableTokens--;
                tokenInstancesToRemove--;
            }
            cursor--;
        }
        if(totalDeposited-amount == 0) {
            if(chosenToken != lootbox.rarities[rarity].availableTokens) {
                lootboxToRarityToTokenIndexToToken[lootboxId][rarity][chosenToken] =
                    lootboxToRarityToTokenIndexToToken[lootboxId][rarity][lootbox.rarities[rarity].availableTokens];
            }
            lootbox.rarities[rarity].availableTokens--;
            token.available = false;
        }

        IERC20Upgradeable(contractAddress).transferFrom(address(this), msg.sender, amount);
        emit TokenWithdraw(lootboxId, contractAddress, 0, amount);
    }

    //Rolling

    function transferSelectedToken(Token memory token, address opener) internal {
        if (token.tokenType == 721) {
            IERC721Upgradeable(token.contractAddress).transferFrom(
                address(this),
                opener,
                token.tokenId
            );
        } else if (token.tokenType == 1155) {
            IERC1155Upgradeable(token.contractAddress).safeTransferFrom(
                address(this),
                opener,
                token.tokenId,
                1,
                ""
            );
        } else if (token.tokenType == 20) {
            IERC20Upgradeable(token.contractAddress).transferFrom(
                address(this),
                opener,
                token.toTransfer
            );
        }
    }

    //VRF
    function RollRandom(uint256 lootboxId)
        public
        payable
        returns (bytes32 requestId)
    {
        Lootbox storage lootbox = lootboxIdToLootbox[lootboxId];
        require(lootbox.price > 0, "Lootbox not found");
        require(msg.value >= lootbox.price, "Transaction value too low");
        require(lootbox.initialized == true, "Lootbox not up for opening");
        require(
            LINK.balanceOf(address(this)) >= fee,
            "Not enough LINK - fill contract with faucet"
        );
        requestId = requestRandomness(keyHash, fee);
        requestIdToLootboxId[requestId] = lootboxId;
        requestIdToRoller[requestId] = msg.sender;
        _distributeFunds(lootbox.seller, msg.value);
        emit BoxRolled(msg.sender, lootboxId, requestId);
        return requestId;
    }
    //VRF callback
    function fulfillRandomness(bytes32 requestId, uint256 randomness)
        internal
        override
    {
        uint256 lootboxId = requestIdToLootboxId[requestId];
        Lootbox storage lootbox = lootboxIdToLootbox[lootboxId];
        uint256 chosenRarity = getRandomRarity(randomness % 10000, lootboxId);
        if(lootbox.rarities[chosenRarity].availableTokens>0) {
            uint256 chosenToken = (randomness % lootbox.rarities[chosenRarity].availableTokens)+1;
            Token memory token = lootboxToRarityToTokenIndexToToken[lootboxId][chosenRarity][chosenToken];
            bool status = token.available;
                        
            if(status){
                if(token.tokenType != 1155){
                    if(chosenToken != lootbox.rarities[chosenRarity].availableTokens) {
                        lootboxToRarityToTokenIndexToToken[lootboxId][chosenRarity][chosenToken] =
                            lootboxToRarityToTokenIndexToToken[lootboxId][chosenRarity][lootbox.rarities[chosenRarity].availableTokens];
                    }
                    lootbox.rarities[chosenRarity].availableTokens--;
                    token.available = false;
                } else {
                    if(token.amount == 1) {
                        if(chosenToken != lootbox.rarities[chosenRarity].availableTokens) {
                            lootboxToRarityToTokenIndexToToken[lootboxId][chosenRarity][chosenToken] =
                                lootboxToRarityToTokenIndexToToken[lootboxId][chosenRarity][lootbox.rarities[chosenRarity].availableTokens];
                        }
                        lootbox.rarities[chosenRarity].availableTokens--;
                        token.available = false;
                    }
                    token.amount--;
                }

                transferSelectedToken(token, requestIdToRoller[requestId]);
            }

            emit LootboxOpened(
                requestIdToRoller[requestId],
                token.contractAddress,
                token.tokenId,
                lootboxId,
                lootbox.raritiesArray[chosenRarity],
                token.amount,
                status,
                requestId
            );
        }

    }

    //Public calls
    function getLootboxOwner(uint256 lootboxId) public view returns (address) {
        return lootboxIdToLootbox[lootboxId].seller;
    }

    function getLootboxStatus(uint256 lootboxId) public view returns (bool) {
        return lootboxIdToLootbox[lootboxId].initialized;
    }

    function getLootboxIpfs(uint256 lootboxId)
        public
        view
        returns (string memory)
    {
        return lootboxIdToLootbox[lootboxId].metadata;
    }

    function getAddressLootboxes(address lootboxOwner)
        public
        view
        returns (uint256[] memory lootboxIds)
    {
        return sellerToLootboxes[lootboxOwner];
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./IERC1155ReceiverUpgradeable.sol";
import "../../introspection/ERC165Upgradeable.sol";
import "../../proxy/Initializable.sol";

/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155ReceiverUpgradeable is Initializable, ERC165Upgradeable, IERC1155ReceiverUpgradeable {
    function __ERC1155Receiver_init() internal initializer {
        __ERC165_init_unchained();
        __ERC1155Receiver_init_unchained();
    }

    function __ERC1155Receiver_init_unchained() internal initializer {
        _registerInterface(
            ERC1155ReceiverUpgradeable(address(0)).onERC1155Received.selector ^
            ERC1155ReceiverUpgradeable(address(0)).onERC1155BatchReceived.selector
        );
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line compiler-version
pragma solidity >=0.4.24 <0.8.0;

import "../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../../introspection/IERC165Upgradeable.sol";

/**
 * _Available since v3.1._
 */
interface IERC1155ReceiverUpgradeable is IERC165Upgradeable {

    /**
        @dev Handles the receipt of a single ERC1155 token type. This function is
        called at the end of a `safeTransferFrom` after the balance has been updated.
        To accept the transfer, this must return
        `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
        (i.e. 0xf23a6e61, or its own function selector).
        @param operator The address which initiated the transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param id The ID of the token being transferred
        @param value The amount of tokens being transferred
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
    */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);

    /**
        @dev Handles the receipt of a multiple ERC1155 token types. This function
        is called at the end of a `safeBatchTransferFrom` after the balances have
        been updated. To accept the transfer(s), this must return
        `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
        (i.e. 0xbc197c81, or its own function selector).
        @param operator The address which initiated the batch transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param ids An array containing ids of each token being transferred (order and length must match values array)
        @param values An array containing amounts of each token being transferred (order and length must match ids array)
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
    */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./IERC165Upgradeable.sol";
import "../proxy/Initializable.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts may inherit from this and call {_registerInterface} to declare
 * their support of an interface.
 */
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    /*
     * bytes4(keccak256('supportsInterface(bytes4)')) == 0x01ffc9a7
     */
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    /**
     * @dev Mapping of interface ids to whether or not it's supported.
     */
    mapping(bytes4 => bool) private _supportedInterfaces;

    function __ERC165_init() internal initializer {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal initializer {
        // Derived contracts need only register support for their own interfaces,
        // we register support for ERC165 itself here
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     *
     * Time complexity O(1), guaranteed to always use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    /**
     * @dev Registers the contract as an implementer of the interface defined by
     * `interfaceId`. Support of the actual ERC165 interface is automatic and
     * registering its interface id is not required.
     *
     * See {IERC165-supportsInterface}.
     *
     * Requirements:
     *
     * - `interfaceId` cannot be the ERC165 invalid interface (`0xffffffff`).
     */
    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165Upgradeable {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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
pragma solidity ^0.7.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMathChainlink {
  /**
   * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
   * - Addition cannot overflow.
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, "SafeMath: subtraction overflow");
    uint256 c = a - b;

    return c;
  }

  /**
   * @dev Returns the multiplication of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `*` operator.
   *
   * Requirements:
   * - Multiplication cannot overflow.
   */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, "SafeMath: division by zero");
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0, "SafeMath: modulo by zero");
    return a % b;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

interface LinkTokenInterface {
  function allowance(address owner, address spender) external view returns (uint256 remaining);

  function approve(address spender, uint256 value) external returns (bool success);

  function balanceOf(address owner) external view returns (uint256 balance);

  function decimals() external view returns (uint8 decimalPlaces);

  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);

  function increaseApproval(address spender, uint256 subtractedValue) external;

  function name() external view returns (string memory tokenName);

  function symbol() external view returns (string memory tokenSymbol);

  function totalSupply() external view returns (uint256 totalTokensIssued);

  function transfer(address to, uint256 value) external returns (bool success);

  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  ) external returns (bool success);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool success);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

contract VRFRequestIDBase {
  /**
   * @notice returns the seed which is actually input to the VRF coordinator
   *
   * @dev To prevent repetition of VRF output due to repetition of the
   * @dev user-supplied seed, that seed is combined in a hash with the
   * @dev user-specific nonce, and the address of the consuming contract. The
   * @dev risk of repetition is mostly mitigated by inclusion of a blockhash in
   * @dev the final seed, but the nonce does protect against repetition in
   * @dev requests which are included in a single block.
   *
   * @param _userSeed VRF seed input provided by user
   * @param _requester Address of the requesting contract
   * @param _nonce User-specific nonce at the time of the request
   */
  function makeVRFInputSeed(
    bytes32 _keyHash,
    uint256 _userSeed,
    address _requester,
    uint256 _nonce
  ) internal pure returns (uint256) {
    return uint256(keccak256(abi.encode(_keyHash, _userSeed, _requester, _nonce)));
  }

  /**
   * @notice Returns the id for this request
   * @param _keyHash The serviceAgreement ID to be used for this request
   * @param _vRFInputSeed The seed to be passed directly to the VRF
   * @return The id for this request
   *
   * @dev Note that _vRFInputSeed is not the seed passed by the consuming
   * @dev contract, but the one generated by makeVRFInputSeed
   */
  function makeRequestId(bytes32 _keyHash, uint256 _vRFInputSeed) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(_keyHash, _vRFInputSeed));
  }
}

// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.7.0;

/**
 * @notice Interface for AdminRole which wraps the default admin role from
 * OpenZeppelin's AccessControl for easy integration.
 */
interface IAdminRole {
  function isAdmin(address account) external view returns (bool);
}

// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.7.0;

import "@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

/**
 * @notice A mixin that stores a reference to the treasury contract.
 */
abstract contract TreasuryNode is Initializable {
  using AddressUpgradeable for address payable;

  address payable private treasury;

  /**
   * @dev Called once after the initial deployment to set the market treasury address.
   */
  function _initializeTreasuryNode(address payable _treasury) internal initializer {
    require(_treasury.isContract(), "TreasuryNode: Address is not a contract");
    treasury = _treasury;
  }

  /**
   * @notice Returns the address of the market treasury.
   */
  function getTreasury() public view returns (address payable) {
    return treasury;
  }

  // `______gap` is added to each mixin to allow adding new data slots or additional mixins in an upgrade-safe way.
  uint256[2000] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

import "../../introspection/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Upgradeable is IERC165Upgradeable {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
      * @dev Safely transfers `tokenId` token from `from` to `to`.
      *
      * Requirements:
      *
      * - `from` cannot be the zero address.
      * - `to` cannot be the zero address.
      * - `tokenId` token must exist and be owned by `from`.
      * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
      * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
      *
      * Emits a {Transfer} event.
      */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

import "../../introspection/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155Upgradeable is IERC165Upgradeable {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMathUpgradeable {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.7.0;

import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

/**
 * @notice Attempt to send ETH and if the transfer fails or runs out of gas, store the balance
 * for future withdrawal instead.
 */
abstract contract SendValueWithFallbackWithdraw is ReentrancyGuardUpgradeable {
  using AddressUpgradeable for address payable;
  using SafeMathUpgradeable for uint256;

  mapping(address => uint256) private pendingWithdrawals;

  event WithdrawPending(address indexed user, uint256 amount);
  event Withdrawal(address indexed user, uint256 amount);

  /**
   * @notice Returns how much funds are available for manual withdraw due to failed transfers.
   */
  function getPendingWithdrawal(address user) public view returns (uint256) {
    return pendingWithdrawals[user];
  }

  /**
   * @notice Allows a user to manually withdraw funds which originally failed to transfer to themselves.
   */
  function withdraw() public {
    withdrawFor(msg.sender);
  }

  /**
   * @notice Allows anyone to manually trigger a withdrawal of funds which originally failed to transfer for a user.
   */
  function withdrawFor(address payable user) public nonReentrant {
    uint256 amount = pendingWithdrawals[user];
    require(amount > 0, "No funds are pending withdrawal");
    pendingWithdrawals[user] = 0;
    user.sendValue(amount);
    emit Withdrawal(user, amount);
  }

  /**
   * @dev Attempt to send a user ETH with a reasonably low gas limit of 20k,
   * which is enough to send to contracts as well.
   */
  function _sendValueWithFallbackWithdrawWithLowGasLimit(address payable user, uint256 amount) internal {
    _sendValueWithFallbackWithdraw(user, amount, 20000);
  }

  /**
   * @dev Attempt to send a user or contract ETH with a moderate gas limit of 90k,
   * which is enough for a 5-way split.
   */
  function _sendValueWithFallbackWithdrawWithMediumGasLimit(address payable user, uint256 amount) internal {
    _sendValueWithFallbackWithdraw(user, amount, 210000);
  }

  /**
   * @dev Attempt to send a user or contract ETH and if it fails store the amount owned for later withdrawal.
   */
  function _sendValueWithFallbackWithdraw(
    address payable user,
    uint256 amount,
    uint256 gasLimit
  ) private {
    if (amount == 0) {
      return;
    }
    // Cap the gas to prevent consuming all available gas to block a tx from completing successfully
    // solhint-disable-next-line avoid-low-level-calls
    (bool success, ) = user.call{ value: amount, gas: gasLimit }("");
    if (!success) {
      // Record failed sends for a withdrawal later
      // Transfers could fail if sent to a multisig with non-trivial receiver logic
      // solhint-disable-next-line reentrancy
      pendingWithdrawals[user] = pendingWithdrawals[user].add(amount);
      emit WithdrawPending(user, amount);
    }
  }

  uint256[499] private ______gap;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
import "../proxy/Initializable.sol";

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}