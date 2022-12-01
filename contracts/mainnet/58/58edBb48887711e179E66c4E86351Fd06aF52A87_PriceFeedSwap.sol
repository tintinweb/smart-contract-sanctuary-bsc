// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

library TransferHelper {
    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: TRANSFER_FAILED");
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: TRANSFER_FROM_FAILED");
    }

    function safeTransferBNB(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "TransferHelper: BNB_TRANSFER_FAILED");
    }
}

interface IEIP721 {
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) external;

    event Transfer(address from, address to, uint256 indexed tokenId);
}

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes memory data
    ) external returns (bytes4);
}

interface IWBNB {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256) external;
}

interface IEIP20Permit {
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

interface IEIP20 {
    function decimals() external returns (uint8);
}

contract NimbusP2P_V2Storage is Initializable, ContextUpgradeable, OwnableUpgradeable, PausableUpgradeable, ReentrancyGuardUpgradeable {
    /**
     * @notice TradeSingle srtuct
     * @param initiator  user that create trade
     * @param counterparty user that take trade
     * @param proposedAsset proposed asset contract address
     * @param proposedAmount proposed amount
     * @param proposedTokenId
     * @param askedAsset asked asset contract address
     * @param askedAmount asked amount
     * @param askedTokenId
     * @param deadline the expiration date of the trade
     * @param status //0: Active, 1: success, 2: canceled, 3: withdrawn
     * @param isAskedAssetNFT
     * @dev
     */
    struct TradeSingle {
        address initiator;
        address counterparty;
        address proposedAsset;
        uint256 proposedAmount;
        uint256 proposedTokenId;
        address askedAsset;
        uint256 askedAmount;
        uint256 askedTokenId;
        uint256 deadline;
        uint256 status; //0: Active, 1: success, 2: canceled, 3: withdrawn
        bool isAskedAssetNFT;
    }
    /**
     * @notice TradeMulti srtuct
     * @param initiator user that create trade
     * @param counterparty user that take trade
     * @param proposedAssets an array of addresses proposed asset contracts
     * @param proposedAmount an array of proposed amounts
     * @param proposedTokenIds array of ID NFT tokens
     * @param askedAssets an array of addresses asked asset contracts
     * @param askedAmount an array of  asked amounts
     * @param askedTokenIds array of ID NFT tokens
     * @param deadline the expiration date of the trade
     * @param status //0: Active, 1: success, 2: canceled, 3: withdrawn
     * @param isAskedAssetNFT
     * @dev
     */
    struct TradeMulti {
        address initiator;
        address counterparty;
        address[] proposedAssets;
        uint256 proposedAmount;
        uint256[] proposedTokenIds;
        address[] askedAssets;
        uint256[] askedTokenIds;
        uint256 askedAmount;
        uint256 deadline;
        uint256 status; //0: Active, 1: success, 2: canceled, 3: withdrawn
        bool isAskedAssetNFTs;
    }
    /**
     * @notice TradeState enum
     * @param  //0: Active, 1: success, 2: canceled, 3: withdrawn
     * @dev
     */
    enum TradeState {
        Active,
        Succeeded,
        Canceled,
        Withdrawn,
        Overdue
    }

    IWBNB public WBNB;
    uint256 public tradeCount;
    mapping(uint256 => TradeSingle) public tradesSingle;
    mapping(uint256 => TradeMulti) public tradesMulti;
    mapping(address => uint256[]) internal _userTrades;

    mapping(address => bool) public allowedNFT;
    mapping(address => bool) public allowedEIP20;

    event NewTradeSingle(
        address user,
        address proposedAsset,
        uint256 indexed proposedAmount,
        uint256 proposedTokenId,
        address askedAsset,
        uint256 askedAmount,
        uint256 askedTokenId,
        uint256 deadline,
        uint256 indexed tradeId
    );
    event NewTradeMulti(
        address user,
        address[] proposedAssets,
        uint256 proposedAmount,
        uint256[] proposedIds,
        address[] askedAssets,
        uint256 askedAmount,
        uint256[] askedIds,
        uint256 deadline,
        uint256 indexed tradeId
    );
    event SupportTrade(uint256 indexed tradeId, address counterparty);
    event CancelTrade(uint256 indexed tradeId);
    event WithdrawOverdueAsset(uint256 indexed tradeId);
    event UpdateAllowedNFT(address nftContract, bool isAllowed);
    event UpdateAllowedEIP20Tokens(address tokenContract, bool isAllowed);
    event Rescue(address to, uint256 amount);
    event RescueToken(address to, address token, uint256 amount);
}

contract NimbusP2P_V2 is NimbusP2P_V2Storage, IERC721Receiver {
    using AddressUpgradeable for address;

    /**
     * @notice Initialize P2P contract
     * @param _allowedEIP20Tokens array of allowed EIP20 tokens addresses
     * @param _allowedEIP20TokenStates allowed EIP20 token states
     * @param _allowedNFTTokens array of allowed NFT tokens addresses
     * @param _allowedNFTTokenStates allowed NFT token states
     * @param _WBNB WBNB address
     * @dev OpenZeppelin initializer ensures this can only be called once
     * This function also calls initializers on inherited contracts
     */
    function initialize(
        address[] calldata _allowedEIP20Tokens,
        bool[] calldata _allowedEIP20TokenStates,
        address[] calldata _allowedNFTTokens,
        bool[] calldata _allowedNFTTokenStates,
        address _WBNB
    ) public initializer {
        require(_WBNB != address(0), "WBNB address should not be zero");

        __Context_init();
        __Ownable_init();
        __Pausable_init();
        __ReentrancyGuard_init();

        WBNB = IWBNB(_WBNB);
        _updateAllowedEIP20Tokens(_allowedEIP20Tokens, _allowedEIP20TokenStates);
        _updateAllowedNFTs(_allowedNFTTokens, _allowedNFTTokenStates);
    }

    receive() external payable {
        require(msg.sender == address(WBNB), "Only accept ETH via fallback from the WBNB contract");
    }

    /**
     * @notice Sets Contract as paused
     * @param isPaused  Pausable mode
     */
    function setPaused(bool isPaused) external onlyOwner {
        if (isPaused) _pause();
        else _unpause();
    }

    /**
     * @notice Creates EIP20 to EIP20 trade
     * @param proposedAsset proposed asset contract address
     * @param proposedAmount proposed amount
     * @param askedAsset asked asset contract address
     * @param askedAmount asked amount
     * @param deadline  the expiration date of the trade
     * @dev This method makes it possible to create a trade for the exchange of tokens BEP20 standard. 
        You can only exchange tokens allowed on the platform.
     */
    function createTradeEIP20ToEIP20(
        address proposedAsset,
        uint256 proposedAmount,
        address askedAsset,
        uint256 askedAmount,
        uint256 deadline
    ) external returns (uint256 tradeId) {
        require(AddressUpgradeable.isContract(proposedAsset) && AddressUpgradeable.isContract(askedAsset), "NimbusP2P_V2: Not contracts");
        require(IEIP20(proposedAsset).decimals() > 0 && IEIP20(askedAsset).decimals() > 0, "NimbusP2P_V2: Propossed and Asked assets are not an EIP20 tokens");
        require(proposedAmount > 0, "NimbusP2P_V2: Zero amount not allowed");
        _requireAllowedEIP20(proposedAsset);
        _requireAllowedEIP20(askedAsset);
        TransferHelper.safeTransferFrom(proposedAsset, msg.sender, address(this), proposedAmount);
        tradeId = _createTradeSingle(proposedAsset, proposedAmount, 0, askedAsset, askedAmount, 0, deadline, false);
    }

    /**
     * @notice Creates BNB to EIP20 trade
     * @param askedAsset proposed asset contract address
     * @param askedAmount proposed amount
     * @param deadline the expiration date of the trade
     * @dev This method makes it possible to create a BNB trade for EIP20 tokens. 
        ProposedAmount is passed in block msg.value
        for trade EIP20 > Native Coin use createTradeEIP20ToEIP20 and pass WBNB address as asked asset
     */
    function createTradeBNBtoEIP20(
        address askedAsset,
        uint256 askedAmount,
        uint256 deadline
    ) external payable returns (uint256 tradeId) {
        require(AddressUpgradeable.isContract(askedAsset), "NimbusP2P_V2: Not contract");
        require(IEIP20(askedAsset).decimals() > 0, "NimbusP2P_V2: Asked asset are not an EIP20 token");
        require(msg.value > 0, "NimbusP2P_V2: Zero amount not allowed");
        _requireAllowedEIP20(askedAsset);
        WBNB.deposit{value: msg.value}();
        tradeId = _createTradeSingle(address(WBNB), msg.value, 0, askedAsset, askedAmount, 0, deadline, false);
    }

    /**
     * @notice Creates EIP20 to NFT trade
     * @param proposedAsset proposed asset contract address
     * @param proposedAmount proposed amount
     * @param askedAsset asked asset contract address
     * @param tokenId  unique NFT token identifier
     * @param deadline the expiration date of the trade
     * @dev This method makes it possible to create a trade for the exchange of tokens BEP20 standard for tokens EIP721 standart. 
        You can only exchange tokens allowed on the platform.
     */
    function createTradeEIP20ToNFT(
        address proposedAsset,
        uint256 proposedAmount,
        address askedAsset,
        uint256 tokenId,
        uint256 deadline
    ) external returns (uint256 tradeId) {
        require(AddressUpgradeable.isContract(proposedAsset) && AddressUpgradeable.isContract(askedAsset), "NimbusP2P_V2: Not contracts");
        require(IEIP20(proposedAsset).decimals() > 0, "NimbusP2P_V2: Propossed asset are not an EIP20 token");
        require(proposedAmount > 0, "NimbusP2P_V2: Zero amount not allowed");
        _requireAllowedEIP20(proposedAsset);
        _requireAllowedNFT(askedAsset);
        TransferHelper.safeTransferFrom(proposedAsset, msg.sender, address(this), proposedAmount);
        tradeId = _createTradeSingle(proposedAsset, proposedAmount, 0, askedAsset, 0, tokenId, deadline, true);
    }

    /**
     * @notice Creates NFT to EIP20 trade
     * @param proposedAsset proposed asset contract address
     * @param tokenId  unique NFT token identifier
     * @param askedAsset asked asset contract address
     * @param askedAmount asked amount
     * @param deadline the expiration date of the trade
     * @dev This method makes it possible to create a trade for the exchange of tokens EIP721 standard for EIP20.
        for trade NFT > Native Coin use createTradeNFTtoEIP20 and pass WBNB address as asked asset
     */
    function createTradeNFTtoEIP20(
        address proposedAsset,
        uint256 tokenId,
        address askedAsset,
        uint256 askedAmount,
        uint256 deadline
    ) external returns (uint256 tradeId) {
        require(AddressUpgradeable.isContract(proposedAsset) && AddressUpgradeable.isContract(askedAsset), "NimbusP2P_V2: Not contracts");
        require(IEIP20(askedAsset).decimals() > 0, "NimbusP2P_V2: Asked asset are not an EIP20 token");
        _requireAllowedNFT(proposedAsset);
        _requireAllowedEIP20(askedAsset);
        IEIP721(proposedAsset).safeTransferFrom(msg.sender, address(this), tokenId);
        tradeId = _createTradeSingle(proposedAsset, 0, tokenId, askedAsset, askedAmount, 0, deadline, false);
    }

    /**
     * @notice Creates BNB to NFT trade
     * @param askedAsset asked asset contract address
     * @param tokenId unique NFT token identifier
     * @param deadline the expiration date of the trade
     * @dev This method makes it possible to create a trade for the exchange BNB for EIP20 tokens. 
        ProposedAmount is passed in block msg.value
     */
    function createTradeBNBtoNFT(
        address askedAsset,
        uint256 tokenId,
        uint256 deadline
    ) external payable returns (uint256 tradeId) {
        require(AddressUpgradeable.isContract(askedAsset), "NimbusP2P_V2: Not contract");
        require(msg.value > 0, "NimbusP2P_V2: Zero amount not allowed");
        _requireAllowedNFT(askedAsset);
        WBNB.deposit{value: msg.value}();
        tradeId = _createTradeSingle(address(WBNB), msg.value, 0, askedAsset, 0, tokenId, deadline, true);
    }

    /**
     * @notice Creates EIP20 to NFTs multi trade
     * @param proposedAsset proposed asset contract address
     * @param proposedAmount proposed amount
     * @param askedAssets an array of addresses asked asset contracts
     * @param askedTokenIds array of ID NFT tokens
     * @param deadline the expiration date of the trade
     * @dev This method makes it possible to create a trade for the exchange of tokens EIP20 standard for any number of NFT tokens. 
        Elements in the arrays asskedAssets and asskedAmounts must have the same indexes. 
        The first element of the asskedAssets array must match the first element of the asskedAmounts array and so on.
     */
    function createTradeEIP20ToNFTs(
        address proposedAsset,
        uint256 proposedAmount,
        address[] memory askedAssets,
        uint256[] memory askedTokenIds,
        uint256 deadline
    ) external returns (uint256 tradeId) {
        require(AddressUpgradeable.isContract(proposedAsset), "NimbusP2P_V2: Not contracts");
        require(IEIP20(proposedAsset).decimals() > 0, "NimbusP2P_V2: Propossed asset are not an EIP20 token");
        require(proposedAmount > 0, "NimbusP2P_V2: Zero amount not allowed");
        require(askedAssets.length > 0, "NimbusP2P_V2: askedAssets empty");
        require(askedAssets.length == askedTokenIds.length, "NimbusP2P_V2: Wrong lengths");
        _requireAllowedEIP20(proposedAsset);
        for (uint256 i = 0; i < askedAssets.length; ) {
            require(AddressUpgradeable.isContract(askedAssets[i]));
            _requireAllowedNFT(askedAssets[i]);

            unchecked {
                ++i;
            }
        }

        TransferHelper.safeTransferFrom(proposedAsset, msg.sender, address(this), proposedAmount);

        address[] memory proposedAssets = new address[](1);
        proposedAssets[0] = proposedAsset;
        uint256[] memory proposedIds = new uint256[](0);
        tradeId = _createTradeMulti(proposedAssets, proposedAmount, proposedIds, askedAssets, 0, askedTokenIds, deadline, true);
    }

    /**
     * @notice Creates NFTs to EIP20 multi trade
     * @param proposedAssets an array of addresses proposed asset contracts
     * @param askedAsset asked asset contract address
     * @param askedAmount asked amount
     * @param proposedTokenIds asked tokens
     * @param deadline the expiration date of the trade
     * @dev This method makes it possible to create a trade for the exchange of any number of tokens EIP721 standard for EIP20 tokens. 
        Elements in the arrays proposedAssets and proposedAmounts must have the same indexes. 
        The first element of the proposedAssets array must match the first element of the proposedAmounts array and so on.
        for trade NFTs > Native Coin use createTradeNFTstoEIP20 and pass WBNB address as asked asset
     */
    function createTradeNFTsToEIP20(
        address[] memory proposedAssets,
        uint256[] memory proposedTokenIds,
        address askedAsset,
        uint256 askedAmount,
        uint256 deadline
    ) external returns (uint256 tradeId) {
        require(AddressUpgradeable.isContract(askedAsset), "NimbusP2P_V2: Not contracts");
        require(IEIP20(askedAsset).decimals() > 0, "NimbusP2P_V2: Asked asset are not an EIP20 token");
        require(proposedAssets.length == proposedTokenIds.length, "NimbusP2P_V2: Wrong lengths");
        require(proposedAssets.length > 0, "NimbusP2P_V2: proposedAssets empty");
        _requireAllowedEIP20(askedAsset);
        for (uint256 i = 0; i < proposedAssets.length; ) {
            require(AddressUpgradeable.isContract(proposedAssets[i]), "NimbusP2P_V2: Not contracts");
            _requireAllowedNFT(proposedAssets[i]);
            IEIP721(proposedAssets[i]).safeTransferFrom(msg.sender, address(this), proposedTokenIds[i]);
            unchecked {
                ++i;
            }
        }
        address[] memory askedAssets = new address[](1);
        askedAssets[0] = askedAsset;
        uint256[] memory askedIds = new uint256[](0);
        tradeId = _createTradeMulti(proposedAssets, 0, proposedTokenIds, askedAssets, askedAmount, askedIds, deadline, false);
    }

    /**
     * @notice Creates BNB to NFTs multi trade
     * @param askedAssets an array of addresses asked asset contracts
     * @param askedTokenIds array of ID NFT tokens
     * @param deadline the expiration date of the trade
     * @dev This method makes it possible to create a trade for the exchange of BNB (Native chain coin) for any number of NFT tokens. 
        Elements in the arrays asskedAssets and asskedAmounts must have the same indexes. 
        The first element of the asskedAssets array must match the first element of the asskedAmounts array and so on.
     */
    function createTradeBNBtoNFTs(
        address[] memory askedAssets,
        uint256[] memory askedTokenIds,
        uint256 deadline
    ) external payable returns (uint256 tradeId) {
        require(askedAssets.length == askedTokenIds.length, "NimbusP2P_V2: Wrong lengths");
        require(msg.value > 0, "NimbusP2P_V2: Zero amount not allowed");
        require(askedAssets.length > 0, "NimbusP2P_V2: askedAssets empty!");
        for (uint256 i = 0; i < askedAssets.length; ) {
            require(AddressUpgradeable.isContract(askedAssets[i]), "NimbusP2P_V2: Not contracts");
            _requireAllowedNFT(askedAssets[i]);
            unchecked {
                ++i;
            }
        }
        require(msg.value > 0);
        WBNB.deposit{value: msg.value}();
        address[] memory proposedAssets = new address[](1);
        proposedAssets[0] = address(WBNB);
        uint256[] memory proposedIds = new uint256[](0);
        tradeId = _createTradeMulti(proposedAssets, msg.value, proposedIds, askedAssets, 0, askedTokenIds, deadline, true);
    }

    /**
     * @notice Creates NFTs to EIP20 multi trade
     * @param proposedAssets an array of addresses proposed asset contracts
     * @param proposedTokenIds array of ID NFT tokens
     * @param askedAssets an array of addresses asked asset contracts
     * @param askedTokenIds array of ID NFT tokens
     * @param deadline  the expiration date of the trade
     * @dev This method makes it possible to create a trade for the exchange of any number of tokens EIP721 standard for any number of tokens EIP721 standard. 
        Elements in the arrays proposedAssets and proposedAmounts must have the same indexes. 
        The first element of the proposedAssets array must match the first element of the proposedAmounts array and so on.
        Elements in the arrays asskedAssets and asskedAmounts must have the same indexes. 
        The first element of the asskedAssets array must match the first element of the asskedAmounts array and so on.
     */
    function createTradeNFTsToNFTs(
        address[] memory proposedAssets,
        uint256[] memory proposedTokenIds,
        address[] memory askedAssets,
        uint256[] memory askedTokenIds,
        uint256 deadline
    ) external returns (uint256 tradeId) {
        require(askedAssets.length > 0, "NimbusP2P_V2: askedAssets empty!");
        require(proposedAssets.length > 0, "NimbusP2P_V2: proposedAssets empty!");
        require(proposedAssets.length == proposedTokenIds.length, "NimbusP2P_V2: AskedAssets wrong lengths");
        require(askedAssets.length == askedTokenIds.length, "NimbusP2P_V2: AskedAssets wrong lengths");
        for (uint256 i = 0; i < askedAssets.length; ) {
            require(AddressUpgradeable.isContract(askedAssets[i]), "NimbusP2P_V2: Not contracts");
            _requireAllowedNFT(askedAssets[i]);
            unchecked {
                ++i;
            }
        }

        for (uint256 i = 0; i < proposedAssets.length; ) {
            require(AddressUpgradeable.isContract(proposedAssets[i]), "NimbusP2P_V2: Not contracts");
            _requireAllowedNFT(proposedAssets[i]);
            IEIP721(proposedAssets[i]).safeTransferFrom(msg.sender, address(this), proposedTokenIds[i]);
            unchecked {
                ++i;
            }
        }
        tradeId = _createTradeMulti(proposedAssets, 0, proposedTokenIds, askedAssets, 0, askedTokenIds, deadline, true);
    }

    /**
     * @notice Creates EIP20 to EIP20 trade with Permit
     * @param proposedAsset proposed asset contract address
     * @param proposedAmount proposed amount
     * @param askedAsset asked asset contract address
     * @param askedAmount asked amount
     * @param deadline the expiration date of the trade
     * @param permitDeadline  the expiration date of the permit
     * @param v the recovery id
     * @param r outputs of an ECDSA signature
     * @param s outputs of an ECDSA signature
     * @dev This method makes it possible to create  trade for the exchange of tokens BEP20 standard. 
        You can only exchange tokens allowed on the platform.
     */
    function createTradeEIP20ToEIP20Permit(
        address proposedAsset,
        uint256 proposedAmount,
        address askedAsset,
        uint256 askedAmount,
        uint256 deadline,
        uint256 permitDeadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 tradeId) {
        require(AddressUpgradeable.isContract(proposedAsset) && AddressUpgradeable.isContract(askedAsset), "NimbusP2P_V2: Not contracts");
        require(IEIP20(proposedAsset).decimals() > 0 && IEIP20(askedAsset).decimals() > 0, "NimbusP2P_V2: Propossed and Asked assets are not an EIP20 tokens");
        require(proposedAmount > 0, "NimbusP2P_V2: Zero amount not allowed");
        _requireAllowedEIP20(askedAsset);
        _requireAllowedEIP20(proposedAsset);
        IEIP20Permit(proposedAsset).permit(msg.sender, address(this), proposedAmount, permitDeadline, v, r, s);
        TransferHelper.safeTransferFrom(proposedAsset, msg.sender, address(this), proposedAmount);
        tradeId = _createTradeSingle(proposedAsset, proposedAmount, 0, askedAsset, askedAmount, 0, deadline, false);
    }

    /**
     * @notice Creates EIP20 to NFT trade with Permit
     * @param proposedAsset proposed asset contract address
     * @param proposedAmount proposed amount
     * @param askedAsset asked asset contract address
     * @param tokenId unique NFT token identifier
     * @param deadline the expiration date of the trade
     * @param permitDeadline the expiration date of the permit
     * @param v the recovery id
     * @param r outputs of an ECDSA signature
     * @param s outputs of an ECDSA signature
     * @dev This method makes it possible to create a trade for the exchange of tokens BEP20 standard for tokens EIP721 standart. 
        You can only exchange tokens allowed on the platform.
     */
    function createTradeEIP20ToNFTPermit(
        address proposedAsset,
        uint256 proposedAmount,
        address askedAsset,
        uint256 tokenId,
        uint256 deadline,
        uint256 permitDeadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 tradeId) {
        require(AddressUpgradeable.isContract(proposedAsset) && AddressUpgradeable.isContract(askedAsset), "NimbusP2P_V2: Not contracts");
        require(IEIP20(proposedAsset).decimals() > 0, "NimbusP2P_V2: Propossed asset are not an EIP20 token");
        require(proposedAmount > 0, "NimbusP2P_V2: Zero amount not allowed");
        _requireAllowedEIP20(proposedAsset);
        _requireAllowedNFT(askedAsset);
        IEIP20Permit(proposedAsset).permit(msg.sender, address(this), proposedAmount, permitDeadline, v, r, s);
        TransferHelper.safeTransferFrom(proposedAsset, msg.sender, address(this), proposedAmount);
        tradeId = _createTradeSingle(proposedAsset, proposedAmount, 0, askedAsset, 0, tokenId, deadline, true);
    }

    /**
     * @notice Creates EIP20 to NFTs multi trade with Permit
     * @param proposedAsset proposed asset contract address
     * @param proposedAmount proposed amount
     * @param askedAssets an array of addresses asked asset contracts
     * @param askedTokenIds array of ID NFT tokens
     * @param deadline the expiration date of the trade
     * @param permitDeadline the expiration date of the permit
     * @param v the recovery id
     * @param r outputs of an ECDSA signature
     * @param s outputs of an ECDSA signature
     * @dev This method makes it possible to create a trade for the exchange of tokens EIP20 standard for any number of NFT tokens. 
        Elements in the arrays asskedAssets and asskedAmounts must have the same indexes. 
        The first element of the asskedAssets array must match the first element of the asskedAmounts array and so on.
     */
    function createTradeEIP20ToNFTsPermit(
        address proposedAsset,
        uint256 proposedAmount,
        address[] memory askedAssets,
        uint256[] memory askedTokenIds,
        uint256 deadline,
        uint256 permitDeadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 tradeId) {
        require(AddressUpgradeable.isContract(proposedAsset), "NimbusP2P_V2: Not contracts");
        require(IEIP20(proposedAsset).decimals() > 0, "NimbusP2P_V2: Propossed  asset are not an EIP20 token");
        require(proposedAmount > 0, "NimbusP2P_V2: Zero amount not allowed");
        require(askedAssets.length == askedTokenIds.length, "NimbusP2P_V2: Wrong lengths");

        for (uint256 i = 0; i < askedAssets.length; ) {
            require(AddressUpgradeable.isContract(askedAssets[i]));
            _requireAllowedNFT(askedAssets[i]);
            unchecked {
                ++i;
            }
        }

        _requireAllowedEIP20(proposedAsset);
        IEIP20Permit(proposedAsset).permit(msg.sender, address(this), proposedAmount, permitDeadline, v, r, s);
        TransferHelper.safeTransferFrom(proposedAsset, msg.sender, address(this), proposedAmount);

        address[] memory proposedAssets = new address[](1);
        proposedAssets[0] = proposedAsset;
        uint256[] memory proposedIds = new uint256[](0);
        tradeId = _createTradeMulti(proposedAssets, proposedAmount, proposedIds, askedAssets, 0, askedTokenIds, deadline, true);
    }

    /**
     * @notice Matches the trade by its id
     * @param tradeId unique trade identifier
     * @dev This method accepts tradeId and supports this trade. 
        As a result of work of this method from a wallet the assked asset on a wallet of the creator of trade is sent.
        This is a method of supporting single trades.
     */
    function supportTradeSingle(uint256 tradeId) external nonReentrant whenNotPaused {
        require(tradeCount >= tradeId && tradeId > 0, "NimbusP2P_V2: Invalid trade id");
        TradeSingle storage trade = tradesSingle[tradeId];
        require(trade.status == 0 && trade.deadline > block.timestamp, "NimbusP2P_V2: Not active trade");

        if (trade.isAskedAssetNFT) {
            IEIP721(trade.askedAsset).safeTransferFrom(msg.sender, trade.initiator, trade.askedTokenId);
        } else {
            TransferHelper.safeTransferFrom(trade.askedAsset, msg.sender, trade.initiator, trade.askedAmount);
        }
        _supportTradeSingle(tradeId);
    }

    /**
     * @notice Matches the trade by its id
     * @param tradeId unique trade identifier
     * @dev This method accepts tradeId and supports this trade. 
        As a result of work of this method from a wallet the BNB on a wallet of the creator of trade is sent.
        This is a method of supporting single trades.
     */
    function supportTradeSingleBNB(uint256 tradeId) external payable nonReentrant whenNotPaused {
        require(tradeCount >= tradeId && tradeId > 0, "NimbusP2P_V2: Invalid trade id");
        TradeSingle storage trade = tradesSingle[tradeId];
        require(trade.status == 0 && trade.deadline > block.timestamp, "NimbusP2P_V2: Not active trade");
        require(msg.value >= trade.askedAmount, "NimbusP2P_V2: Not enough BNB sent");
        require(trade.askedAsset == address(WBNB), "NimbusP2P_V2: BEP20 trade");

        TransferHelper.safeTransferBNB(trade.initiator, trade.askedAmount);
        if (msg.value > trade.askedAmount) TransferHelper.safeTransferBNB(msg.sender, msg.value - trade.askedAmount);
        _supportTradeSingle(tradeId);
    }

    /**
     * @notice Matches the single trade by its id (with Permit)
     * @param tradeId unique trade identifier
     * @param permitDeadline the expiration date of the permit
     * @param v the recovery id
     * @param r outputs of an ECDSA signature
     * @param s outputs of an ECDSA signature
     * @dev This method accepts tradeId and supports this trade. 
        As a result of work of this method from a wallet the assked asset on a wallet of the creator of trade is sent.
        This is a method of supporting single trades.
     */
    function supportTradeSingleWithPermit(
        uint256 tradeId,
        uint256 permitDeadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external nonReentrant whenNotPaused {
        require(tradeCount >= tradeId && tradeId > 0, "NimbusBEP20P2P_V1: Invalid trade id");
        TradeSingle storage trade = tradesSingle[tradeId];
        require(!trade.isAskedAssetNFT, "NimbusBEP20P2P_V1: Permit only allowed for EIP20 tokens");
        require(trade.status == 0 && trade.deadline > block.timestamp, "NimbusBEP20P2P_V1: Not active trade");

        IEIP20Permit(trade.askedAsset).permit(msg.sender, address(this), trade.askedAmount, permitDeadline, v, r, s);
        TransferHelper.safeTransferFrom(trade.askedAsset, msg.sender, trade.initiator, trade.askedAmount);
        _supportTradeSingle(tradeId);
    }

    /**
     * @notice Matches the multi trade by its id
     * @param tradeId unique trade identifier
     * @dev This method accepts tradeId and supports this trade. 
        As a result of work of this method from a wallet the assked asset on a wallet of the creator of trade is sent.
        This is a method of supporting multi trades.
     */
    function supportTradeMulti(uint256 tradeId) external nonReentrant whenNotPaused {
        require(tradeCount >= tradeId && tradeId > 0, "NimbusP2P_V2: Invalid trade id");
        TradeMulti storage tradeMulti = tradesMulti[tradeId];
        require(tradeMulti.status == 0 && tradeMulti.deadline > block.timestamp, "NimbusP2P_V2: Not active trade");
        if (tradeMulti.isAskedAssetNFTs) {
            for (uint256 i = 0; i < tradeMulti.askedAssets.length; ) {
                IEIP721(tradeMulti.askedAssets[i]).safeTransferFrom(msg.sender, tradeMulti.initiator, tradeMulti.askedTokenIds[i]);
                unchecked {
                    ++i;
                }
            }
        } else {
            TransferHelper.safeTransferFrom(tradeMulti.askedAssets[0], msg.sender, tradeMulti.initiator, tradeMulti.askedAmount);
        }

        _supportTradeMulti(tradeId);
    }

    /**
     * @notice Matches the multi trade by its id (with Permit)
     * @param tradeId unique trade identifier
     * @param permitDeadline the expiration date of the permit
     * @param v the recovery id
     * @param r outputs of an ECDSA signature
     * @param s outputs of an ECDSA signature
     * @dev This method accepts tradeId and supports this trade. 
        As a result of work of this method from a wallet the assked asset on a wallet of the creator of trade is sent.
        This is a method of supporting multi trades.
     */
    function supportTradeMultiWithPermit(
        uint256 tradeId,
        uint256 permitDeadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external nonReentrant whenNotPaused {
        require(tradeCount >= tradeId && tradeId > 0, "NimbusP2P_V2: Invalid trade id");
        TradeMulti storage tradeMulti = tradesMulti[tradeId];
        require(!tradeMulti.isAskedAssetNFTs, "NimbusP2P_V2: Only EIP20 supported");
        require(tradeMulti.status == 0 && tradeMulti.deadline > block.timestamp, "NimbusP2P_V2: Not active trade");

        for (uint256 i = 0; i < tradeMulti.askedAssets.length; ) {
            IEIP20Permit(tradeMulti.askedAssets[i]).permit(msg.sender, address(this), tradeMulti.askedAmount, permitDeadline, v, r, s);
            TransferHelper.safeTransferFrom(tradeMulti.askedAssets[i], msg.sender, tradeMulti.initiator, tradeMulti.askedAmount);

            unchecked {
                ++i;
            }
        }

        _supportTradeMulti(tradeId);
    }

    /**
     * @notice Cancels the trade by its id
     * @param tradeId unique trade identifier
     * @dev This method takes tradeId and cancels the thread before the deadline. As a result of his work, the proposed assets are returned to the wallet of the creator of the trade
        This is a method of canceling single trades.
     */
    function cancelTrade(uint256 tradeId) external nonReentrant whenNotPaused {
        require(tradeCount >= tradeId && tradeId > 0, "NimbusP2P_V2: Invalid trade id");
        TradeSingle storage trade = tradesSingle[tradeId];
        require(trade.initiator == msg.sender, "NimbusP2P_V2: Not allowed");
        require(trade.status == 0 && trade.deadline > block.timestamp, "NimbusP2P_V2: Not active trade");

        if (trade.proposedAmount == 0) {
            IEIP721(trade.proposedAsset).transferFrom(address(this), msg.sender, trade.proposedTokenId);
        } else if (trade.proposedAsset != address(WBNB)) {
            TransferHelper.safeTransfer(trade.proposedAsset, msg.sender, trade.proposedAmount);
        } else {
            WBNB.withdraw(trade.proposedAmount);
            TransferHelper.safeTransferBNB(msg.sender, trade.proposedAmount);
        }

        trade.status = 2;
        emit CancelTrade(tradeId);
    }

    /**
     * @notice Cancels the trade by its id
     * @param tradeId unique trade identifier
     * @dev This method takes tradeId and cancels the thread before the deadline. As a result of his work, the proposed assets are returned to the wallet of the creator of the trade
        This is a method of canceling multi trades.
     */
    function cancelTradeMulti(uint256 tradeId) external nonReentrant whenNotPaused {
        require(tradeCount >= tradeId && tradeId > 0, "NimbusP2P_V2: Invalid trade id");
        TradeMulti storage tradeMulti = tradesMulti[tradeId];
        require(tradeMulti.initiator == msg.sender, "NimbusP2P_V2: Not allowed");
        require(tradeMulti.status == 0 && tradeMulti.deadline > block.timestamp, "NimbusP2P_V2: Not active trade");

        if (tradeMulti.proposedAmount == 0) {
            for (uint256 i = 0; i < tradeMulti.proposedAssets.length; ) {
                IEIP721(tradeMulti.proposedAssets[i]).transferFrom(address(this), msg.sender, tradeMulti.proposedTokenIds[i]);
                unchecked {
                    ++i;
                }
            }
        } else if (tradeMulti.proposedAssets[0] != address(WBNB)) {
            TransferHelper.safeTransfer(tradeMulti.proposedAssets[0], msg.sender, tradeMulti.proposedAmount);
        } else {
            WBNB.withdraw(tradeMulti.proposedAmount);
            TransferHelper.safeTransferBNB(msg.sender, tradeMulti.proposedAmount);
        }

        tradeMulti.status = 2;
        emit CancelTrade(tradeId);
    }

    /**
     * @notice Withdraws asset of the particular trade by its id when trade is overdue
     * @param tradeId unique trade identifier
     * @dev This method accepts tradeId and withdraws the proposed assets from the P2P contract after the trade deadline has expired. 
        As a result of his work, the proposed assets are returned to the wallet of the creator of the trade.
     */
    function withdrawOverdueAssetSingle(uint256 tradeId) external nonReentrant whenNotPaused {
        require(tradeCount >= tradeId && tradeId > 0, "NimbusP2P_V2: Invalid trade id");
        TradeSingle storage trade = tradesSingle[tradeId];
        require(trade.initiator == msg.sender, "NimbusP2P_V2: Not allowed");
        require(trade.status == 0 && trade.deadline < block.timestamp, "NimbusP2P_V2: Not available for withdrawal");
        emit WithdrawOverdueAsset(tradeId);
        if (trade.proposedAmount == 0) {
            IEIP721(trade.proposedAsset).transferFrom(address(this), msg.sender, trade.proposedTokenId);
        } else if (trade.proposedAsset != address(WBNB)) {
            TransferHelper.safeTransfer(trade.proposedAsset, msg.sender, trade.proposedAmount);
        } else {
            WBNB.withdraw(trade.proposedAmount);
            TransferHelper.safeTransferBNB(msg.sender, trade.proposedAmount);
        }

        trade.status = 3;
    }

    /**
     * @notice Withdraws asset of the particular trade by its id when trade is overdue
     * @param tradeId unique trade identifier
     * @dev This method accepts tradeId and withdraws the proposed assets from the P2P contract after the trade deadline has expired. 
        As a result of his work, the proposed assets are returned to the wallet of the creator of the trade.
     */
    function withdrawOverdueAssetsMulti(uint256 tradeId) external nonReentrant whenNotPaused {
        require(tradeCount >= tradeId && tradeId > 0, "NimbusP2P_V2: Invalid trade id");
        TradeMulti storage tradeMulti = tradesMulti[tradeId];
        require(tradeMulti.initiator == msg.sender, "NimbusP2P_V2: Not allowed");
        require(tradeMulti.status == 0 && tradeMulti.deadline < block.timestamp, "NimbusP2P_V2: Not available for withdrawal");
        emit WithdrawOverdueAsset(tradeId);
        if (tradeMulti.proposedAmount == 0) {
            for (uint256 i = 0; i < tradeMulti.proposedAssets.length; ) {
                IEIP721(tradeMulti.proposedAssets[i]).transferFrom(address(this), msg.sender, tradeMulti.proposedTokenIds[i]);
                unchecked {
                    ++i;
                }
            }
        } else if (tradeMulti.proposedAssets[0] != address(WBNB)) {
            TransferHelper.safeTransfer(tradeMulti.proposedAssets[0], msg.sender, tradeMulti.proposedAmount);
        } else {
            WBNB.withdraw(tradeMulti.proposedAmount);
            TransferHelper.safeTransferBNB(msg.sender, tradeMulti.proposedAmount);
        }

        tradeMulti.status = 3;
    }

    /**
     * @notice allows particular EIP20 tokens for new trades
     * @param tokens addresses of tokens
     * @param states booleans (is Allowed)
     * @dev This method allows the particular EIP20 tokens contracts to be passed as proposed or asked assets for new trades
     */
    function updateAllowedEIP20Tokens(address[] calldata tokens, bool[] calldata states) external onlyOwner {
        _updateAllowedEIP20Tokens(tokens, states);
    }

    /**
     * @notice Rescues particular EIP20 token`s amount from contract to some address
     * @param to  address of recepient
     * @param tokenAddress address of token
     * @param amount  amount of token to be withdraw
     */
    function rescueEIP20(
        address to,
        address tokenAddress,
        uint256 amount
    ) external onlyOwner whenPaused {
        require(to != address(0), "NimbusP2P_V2: Cannot rescue to the zero address");
        require(amount > 0, "NimbusP2P_V2: Cannot rescue 0");
        emit RescueToken(to, address(tokenAddress), amount);
        TransferHelper.safeTransfer(tokenAddress, to, amount);
    }

    /**
     * @notice Rescues particular NFT by Id from contract to some address
     * @param to address of recepient
     * @param tokenAddress address of NFT
     * @param tokenId id of token to be withdraw
     */
    function rescueEIP721(
        address to,
        address tokenAddress,
        uint256 tokenId
    ) external onlyOwner whenPaused {
        require(to != address(0), "NimbusP2P_V2: Cannot rescue to the zero address");
        emit RescueToken(to, address(tokenAddress), tokenId);
        IEIP721(tokenAddress).safeTransferFrom(address(this), to, tokenId);
    }

    /**
     * @notice allows particular NFT for new trades
     * @param nft address of NFT
     * @param isAllowed boolean (is Allowed)
     * @dev This method allows the particular NFT contract to be passed as proposed or asked assets for new trades
     */
    function updateAllowedNFT(address nft, bool isAllowed) external onlyOwner {
        _updateAllowedNFT(nft, isAllowed);
    }

    /**
     * @notice return the State of given multi trade by id
     * @param id unique trade identifier
     */
    function getTradeMulti(uint256 id) external view returns (TradeMulti memory) {
        return tradesMulti[id];
    }

    /**
     * @notice return whether State of Single trade is active
     * @param tradeId unique trade identifier
     */
    function state(uint256 tradeId) external view returns (TradeState) {
        //TODO
        TradeSingle storage trade = tradesSingle[tradeId];
        require(tradeCount >= tradeId && tradeId > 0 && trade.deadline > 0, "NimbusP2P_V2: Invalid trade id");
        if (trade.status == 1) {
            return TradeState.Succeeded;
        } else if (trade.status == 2 || trade.status == 3) {
            return TradeState(trade.status);
        } else if (trade.deadline < block.timestamp) {
            return TradeState.Overdue;
        } else {
            return TradeState.Active;
        }
    }

    /**
     * @notice return whether State of Multi trade is active
     * @param tradeId unique trade identifier
     */
    function stateMulti(uint256 tradeId) external view returns (TradeState) {
        //TODO
        TradeMulti storage tradeMulti = tradesMulti[tradeId];
        require(tradeCount >= tradeId && tradeId > 0 && tradeMulti.deadline > 0, "NimbusP2P_V2: Invalid trade id");

        if (tradeMulti.status == 1) {
            return TradeState.Succeeded;
        } else if (tradeMulti.status == 2 || tradeMulti.status == 3) {
            return TradeState(tradeMulti.status);
        } else if (tradeMulti.deadline < block.timestamp) {
            return TradeState.Overdue;
        } else {
            return TradeState.Active;
        }
    }

    /**
     * @notice return returns the array of user`s trades Ids
     * @param user user address
     */
    function userTrades(address user) external view returns (uint256[] memory) {
        return _userTrades[user];
    }

    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes memory data
    ) external pure override returns (bytes4) {
        return 0x150b7a02;
    }

    /**
     * @notice requires NFT to be allowed
     * @param nftContract nftContract address to check for allowance
     */
    function _requireAllowedNFT(address nftContract) private view {
        require(allowedNFT[nftContract], "NimbusP2P_V2: Not allowed NFT");
    }

    /**
     * @notice requires EIP20 token to be allowed
     * @param tokenContract  tokenContract to check for allowance
     */
    function _requireAllowedEIP20(address tokenContract) private view {
        require(allowedEIP20[tokenContract], "NimbusP2P_V2: Not allowed EIP20 Token");
    }

    /**
     * @notice Creates new trade
     * @param proposedAsset proposed asset contract address
     * @param proposedAmount proposed amount
     * @param proposedTokenId proposed asset token Id
     * @param askedAsset asked asset contract address
     * @param askedAmount asked amount
     * @param askedTokenId asked asset token Id
     * @param deadline the expiration date of the trade
     * @param isNFTAskedAsset whether asked asset is NFT
     * @dev This method makes it possible to create a trade.
        You can only exchange tokens allowed on the platform.
     */
    function _createTradeSingle(
        address proposedAsset,
        uint256 proposedAmount,
        uint256 proposedTokenId,
        address askedAsset,
        uint256 askedAmount,
        uint256 askedTokenId,
        uint256 deadline,
        bool isNFTAskedAsset
    ) private whenNotPaused returns (uint256 tradeId) {
        require(deadline > block.timestamp, "NimbusP2P_V2: Incorrect deadline");
        require(askedAsset != proposedAsset, "NimbusP2P_V2: Asked asset can't be equal to proposed asset");

        tradeId = ++tradeCount;

        TradeSingle storage trade = tradesSingle[tradeId];
        trade.initiator = msg.sender;
        trade.proposedAsset = proposedAsset;
        if (proposedAmount > 0) trade.proposedAmount = proposedAmount;
        if (proposedTokenId > 0) trade.proposedTokenId = proposedTokenId;
        trade.askedAsset = askedAsset;
        if (askedAmount > 0) trade.askedAmount = askedAmount;
        if (askedTokenId > 0) trade.askedTokenId = askedTokenId;
        trade.deadline = deadline;
        if (isNFTAskedAsset) trade.isAskedAssetNFT = true;
        emit NewTradeSingle(msg.sender, proposedAsset, proposedAmount, proposedTokenId, askedAsset, askedAmount, askedTokenId, deadline, tradeId);
        _userTrades[msg.sender].push(tradeId);
    }

    /**
     * @notice Creates new trade
     * @param proposedAssets proposed assets contract addresses
     * @param proposedAmount proposed amount
     * @param proposedTokenIds proposed assets token Ids
     * @param askedAssets asked assets contract addresses
     * @param askedAmount asked amount
     * @param askedTokenIds asked assets token Ids
     * @param deadline the expiration date of the trade
     * @param isNFTsAskedAsset  whether asked asset is NFT
     * @dev This method makes it possible to create a trade.
        You can only exchange tokens allowed on the platform.
     */
    function _createTradeMulti(
        address[] memory proposedAssets,
        uint256 proposedAmount,
        uint256[] memory proposedTokenIds,
        address[] memory askedAssets,
        uint256 askedAmount,
        uint256[] memory askedTokenIds,
        uint256 deadline,
        bool isNFTsAskedAsset
    ) private whenNotPaused returns (uint256 tradeId) {
        require(deadline > block.timestamp, "NimbusP2P_V2: Incorrect deadline");

        if (askedTokenIds.length > 0 && proposedTokenIds.length > 0) {
            for (uint256 i = 0; i < askedAssets.length; ) {
                for (uint256 j = 0; j < proposedAssets.length; ) {
                    if (askedTokenIds[i] == proposedTokenIds[j]) {
                        require(askedAssets[i] != proposedAssets[j], "NimbusP2P_V2: Asked asset can't be equal to proposed asset");
                    }
                    unchecked {
                        ++j;
                    }
                }
                unchecked {
                    ++i;
                }
            }
        }

        tradeId = ++tradeCount;

        TradeMulti storage tradeMulti = tradesMulti[tradeId];
        tradeMulti.initiator = msg.sender;
        tradeMulti.proposedAssets = proposedAssets;
        if (proposedAmount > 0) tradeMulti.proposedAmount = proposedAmount;
        if (proposedTokenIds.length > 0) tradeMulti.proposedTokenIds = proposedTokenIds;
        tradeMulti.askedAssets = askedAssets;
        if (askedAmount > 0) tradeMulti.askedAmount = askedAmount;
        if (askedTokenIds.length > 0) tradeMulti.askedTokenIds = askedTokenIds;
        tradeMulti.deadline = deadline;
        if (isNFTsAskedAsset) tradeMulti.isAskedAssetNFTs = true;

        emit NewTradeMulti(msg.sender, proposedAssets, proposedAmount, proposedTokenIds, askedAssets, askedAmount, askedTokenIds, deadline, tradeId);
        _userTrades[msg.sender].push(tradeId);
    }

    /**
     * @notice Matches the trade by its id
     * @param tradeId unique trade identifier
     * @dev This method accepts tradeId and supports this trade. 
        As a result of work of this method from a wallet the assked asset on a wallet of the creator of trade is sent.
        This is a method of supporting single trades.
     */
    function _supportTradeSingle(uint256 tradeId) private whenNotPaused {
        TradeSingle memory trade = tradesSingle[tradeId];
        emit SupportTrade(tradeId, msg.sender);
        if (trade.proposedAmount == 0) {
            IEIP721(trade.proposedAsset).transferFrom(address(this), msg.sender, trade.proposedTokenId);
        } else if (trade.proposedAsset != address(WBNB)) {
            TransferHelper.safeTransfer(trade.proposedAsset, msg.sender, trade.proposedAmount);
        } else {
            WBNB.withdraw(trade.proposedAmount);
            TransferHelper.safeTransferBNB(msg.sender, trade.proposedAmount);
        }

        tradesSingle[tradeId].counterparty = msg.sender;
        tradesSingle[tradeId].status = 1;
    }

    /**
     * @notice Matches the multi trade by its id
     * @param tradeId unique trade identifier
     * @dev This method accepts tradeId and supports this trade. 
        As a result of work of this method from a wallet the assked asset on a wallet of the creator of trade is sent.
        This is a method of supporting multi trades.
     */
    function _supportTradeMulti(uint256 tradeId) private whenNotPaused {
        TradeMulti memory tradeMulti = tradesMulti[tradeId];
        emit SupportTrade(tradeId, msg.sender);
        if (tradeMulti.proposedAmount == 0) {
            for (uint256 i = 0; i < tradeMulti.proposedAssets.length; ) {
                IEIP721(tradeMulti.proposedAssets[i]).transferFrom(address(this), msg.sender, tradeMulti.proposedTokenIds[i]);
                unchecked {
                    ++i;
                }
            }
        } else if (tradeMulti.proposedAssets[0] != address(WBNB)) {
            TransferHelper.safeTransfer(tradeMulti.proposedAssets[0], msg.sender, tradeMulti.proposedAmount);
        } else {
            WBNB.withdraw(tradeMulti.proposedAmount);
            TransferHelper.safeTransferBNB(msg.sender, tradeMulti.proposedAmount);
        }

        tradesMulti[tradeId].counterparty = msg.sender;
        tradesMulti[tradeId].status = 1;
    }

    /**
     * @notice allows particular NFT for new trades
     * @param nft address of NFT
     * @param isAllowed  boolean (is Allowed)
     * @dev This method allows the particular NFT contract to be passed as proposed or asked assets for new trades
     */
    function _updateAllowedNFT(address nft, bool isAllowed) private {
        require(AddressUpgradeable.isContract(nft), "NimbusP2P_V2: Not a contract");
        allowedNFT[nft] = isAllowed;
        emit UpdateAllowedNFT(nft, isAllowed);
    }

    /**
     * @notice allows particular NFTs for new trades
     * @param nfts addresses of NFTs
     * @param states booleans (is Allowed)
     * @dev This method allows the particular NFTs contracts to be passed as proposed or asked assets for new trades
     */
    function _updateAllowedNFTs(address[] calldata nfts, bool[] calldata states) private {
        require(nfts.length == states.length, "NimbusP2P_V2: Length mismatch");

        for (uint i = 0; i < nfts.length; ) {
            _updateAllowedNFT(nfts[i], states[i]);

            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice allows particular EIP20 token contract for new trades
     * @param token address of token
     * @param isAllowed boolean (is Allowed)
     * @dev This method allows the particular EIP20 contract to be passed as proposed or asked assets for new trades
     */
    function _updateAllowedEIP20Token(address token, bool isAllowed) private {
        require(AddressUpgradeable.isContract(token), "NimbusP2P_V2: Not a contract");
        allowedEIP20[token] = isAllowed;
        emit UpdateAllowedEIP20Tokens(token, isAllowed);
    }

    /**
     * @notice allows particular EIP20 tokens for new trades
     * @param tokens addresses of tokens
     * @param states booleans (is Allowed)
     * @dev This method allows the particular EIP20 tokens contracts to be passed as proposed or asked assets for new trades
     */
    function _updateAllowedEIP20Tokens(address[] calldata tokens, bool[] calldata states) private {
        require(tokens.length == states.length, "NimbusP2P_V2: Length mismatch");

        for (uint256 i = 0; i < tokens.length; ) {
            _updateAllowedEIP20Token(tokens[i], states[i]);
            unchecked {
                ++i;
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
                /// @solidity memory-safe-assembly
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
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";

contract GNIMB is ERC20, ERC20Burnable, Pausable, Ownable, ERC20Permit {
    constructor()
        ERC20("Nimbus Governance Token", "GNIMB")
        ERC20Permit("Nimbus Governance Token")
    {
        _mint(msg.sender, 100000000 * 10 ** decimals());
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, amount);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/extensions/ERC20Burnable.sol)

pragma solidity ^0.8.0;

import "../ERC20.sol";
import "../../../utils/Context.sol";

/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/extensions/draft-ERC20Permit.sol)

pragma solidity ^0.8.0;

import "./draft-IERC20Permit.sol";
import "../ERC20.sol";
import "../../../utils/cryptography/draft-EIP712.sol";
import "../../../utils/cryptography/ECDSA.sol";
import "../../../utils/Counters.sol";

/**
 * @dev Implementation of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on `{IERC20-approve}`, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * _Available since v3.4._
 */
abstract contract ERC20Permit is ERC20, IERC20Permit, EIP712 {
    using Counters for Counters.Counter;

    mapping(address => Counters.Counter) private _nonces;

    // solhint-disable-next-line var-name-mixedcase
    bytes32 private constant _PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    /**
     * @dev In previous versions `_PERMIT_TYPEHASH` was declared as `immutable`.
     * However, to ensure consistency with the upgradeable transpiler, we will continue
     * to reserve a slot.
     * @custom:oz-renamed-from _PERMIT_TYPEHASH
     */
    // solhint-disable-next-line var-name-mixedcase
    bytes32 private _PERMIT_TYPEHASH_DEPRECATED_SLOT;

    /**
     * @dev Initializes the {EIP712} domain separator using the `name` parameter, and setting `version` to `"1"`.
     *
     * It's a good idea to use the same `name` that is defined as the ERC20 token name.
     */
    constructor(string memory name) EIP712(name, "1") {}

    /**
     * @dev See {IERC20Permit-permit}.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual override {
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");

        bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPEHASH, owner, spender, value, _useNonce(owner), deadline));

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        require(signer == owner, "ERC20Permit: invalid signature");

        _approve(owner, spender, value);
    }

    /**
     * @dev See {IERC20Permit-nonces}.
     */
    function nonces(address owner) public view virtual override returns (uint256) {
        return _nonces[owner].current();
    }

    /**
     * @dev See {IERC20Permit-DOMAIN_SEPARATOR}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }

    /**
     * @dev "Consume a nonce": return the current value and increment.
     *
     * _Available since v4.1._
     */
    function _useNonce(address owner) internal virtual returns (uint256 current) {
        Counters.Counter storage nonce = _nonces[owner];
        current = nonce.current();
        nonce.increment();
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/draft-EIP712.sol)

pragma solidity ^0.8.0;

import "./ECDSA.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 */
abstract contract EIP712 {
    /* solhint-disable var-name-mixedcase */
    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;
    address private immutable _CACHED_THIS;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;

    /* solhint-enable var-name-mixedcase */

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    constructor(string memory name, string memory version) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _CACHED_THIS = address(this);
        _TYPE_HASH = typeHash;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _CACHED_THIS && block.chainid == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.3) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../Strings.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface INimbusRouter {
    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IStakingRewards {
    function earned(address account) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function stake(uint256 amount) external;
    function stakeFor(uint256 amount, address user) external;
    function getReward() external;
    function getRewardForUser(address user) external;
    function withdraw(uint256 nonce) external;
    function withdrawAndGetReward(uint256 nonce) external;
}

interface IPriceFeed {
    function queryRate(address sourceTokenAddress, address destTokenAddress) external view returns (uint256 rate, uint256 precision);
    function wbnbToken() external view returns(address);
}

contract StakingRewardFixedAPY_NFT is IStakingRewards, ReentrancyGuard, Ownable, Pausable {
    using SafeERC20 for IERC20;

    IERC20 public immutable rewardsToken;
    IERC20 public rewardsPaymentToken;
    IERC20 public immutable stakingToken;
    INimbusRouter public swapRouter;
    uint256 public rewardRate; 
    uint256 public constant rewardDuration = 365 days; 
    uint256 public rateChangesNonce;

    mapping(address => uint256) public weightedStakeDate;
    mapping(address => mapping(uint256 => StakeNonceInfo)) public stakeNonceInfos;
    mapping(address => uint256) public stakeNonces;
    mapping(uint256 => APYCheckpoint) APYcheckpoints;

    struct StakeNonceInfo {
        uint256 stakeTime;
        uint256 stakingTokenAmount;
        uint256 rewardsTokenAmount;
        uint256 rewardRate;
    }

    struct APYCheckpoint {
        uint256 timestamp;
        uint256 rewardRate;
    }

    uint256 private _totalSupply;
    uint256 private _totalSupplyRewardEquivalent;
    mapping(address => uint256) private _balances;
    mapping(address => uint256) private _balancesRewardEquivalent;
    mapping(address => bool) private _isStakerAllowed;

    bool public usePriceFeeds;
    IPriceFeed public priceFeed;

    event RewardRateUpdated(uint256 indexed rateChangesNonce, uint256 rewardRate, uint256 timestamp);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, address indexed paymentToken, uint256 reward);
    event RewardsPaymentTokenChanged(address indexed newRewardsPaymentToken);
    event RescueBNB(address indexed to, uint256 amount);
    event RescueEIP20(address indexed to, address indexed token, uint256 amount);
    event UpdateUsePriceFeeds(bool indexed isUsePriceFeeds);

    constructor(
        address _rewardsToken,
        address _rewardsPaymentToken,
        address _stakingToken,
        address _swapRouter,
        uint256 _rewardRate
    ) {
        require(
            _rewardsToken != address(0) && _rewardsPaymentToken != address(0) && _swapRouter != address(0), 
            "StakingRewardFixedAPY: Zero address(es)"
        );
        rewardsToken = IERC20(_rewardsToken);
        rewardsPaymentToken = IERC20(_rewardsPaymentToken);
        stakingToken = IERC20(_stakingToken);
        swapRouter = INimbusRouter(_swapRouter);
        rewardRate = _rewardRate;
        emit RewardRateUpdated(rateChangesNonce, _rewardRate, block.timestamp);
        APYcheckpoints[rateChangesNonce++] = APYCheckpoint(block.timestamp, rewardRate);
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function totalSupplyRewardEquivalent() external view returns (uint256) {
        return _totalSupplyRewardEquivalent;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }
    
    function balanceOfRewardEquivalent(address account) external view returns (uint256) {
        return _balancesRewardEquivalent[account];
    }

    function earnedByNonce(address account, uint256 nonce) public view returns (uint256) {
        uint256 amount = stakeNonceInfos[account][nonce].rewardsTokenAmount * 
            (block.timestamp - stakeNonceInfos[account][nonce].stakeTime) *
             stakeNonceInfos[account][nonce].rewardRate / (100 * rewardDuration);
        return getTokenAmountForToken(address(rewardsToken), address(rewardsPaymentToken), amount);
    }

    function earned(address account) public view override returns (uint256 totalEarned) {
        for (uint256 i = 0; i < stakeNonces[account]; i++) {
            totalEarned += earnedByNonce(account, i);
        }
    }

    function stakeWithPermit(uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external nonReentrant {
        require(amount > 0, "StakingRewardFixedAPY: Cannot stake 0");
        // permit
        IERC20Permit(address(stakingToken)).permit(msg.sender, address(this), amount, deadline, v, r, s);
        _stake(amount, msg.sender);
    }

    function stake(uint256 amount) external override nonReentrant {
        require(amount > 0, "StakingRewardFixedAPY: Cannot stake 0");
        _stake(amount, msg.sender);
    }

    function stakeFor(uint256 amount, address user) external override nonReentrant {
        require(amount > 0, "StakingRewardFixedAPY: Cannot stake 0");
        require(user != address(0), "StakingRewardFixedAPY: Cannot stake for zero address");
        _stake(amount, user);
    }

    function _stake(uint256 amount, address user) private whenNotPaused {
        require(isStakerAllowed(msg.sender), "StakingRewardFixedAPY: Not allowed to stake");
        stakingToken.safeTransferFrom(msg.sender, address(this), amount);
        uint256 amountRewardEquivalent = getEquivalentAmount(amount);

        _totalSupply += amount;
        _totalSupplyRewardEquivalent += amountRewardEquivalent;
        _balances[user] += amount;

        uint256 stakeNonce = stakeNonces[user]++;
        stakeNonceInfos[user][stakeNonce].stakingTokenAmount = amount;
        stakeNonceInfos[user][stakeNonce].stakeTime = block.timestamp;
        stakeNonceInfos[user][stakeNonce].rewardRate = rewardRate;
        stakeNonceInfos[user][stakeNonce].rewardsTokenAmount = amountRewardEquivalent;
        _balancesRewardEquivalent[user] += amountRewardEquivalent;
        emit Staked(user, amount);
    }



    //A user can withdraw its staking tokens even if there is no rewards tokens on the contract account
    function withdraw(uint256 nonce) public override nonReentrant whenNotPaused {
        require(stakeNonceInfos[msg.sender][nonce].stakingTokenAmount > 0, "StakingRewardFixedAPY: This stake nonce was withdrawn");
        uint256 amount = stakeNonceInfos[msg.sender][nonce].stakingTokenAmount;
        uint256 amountRewardEquivalent = stakeNonceInfos[msg.sender][nonce].rewardsTokenAmount;
        _totalSupply -= amount;
        _totalSupplyRewardEquivalent -= amountRewardEquivalent;
        _balances[msg.sender] -= amount;
        _balancesRewardEquivalent[msg.sender] -= amountRewardEquivalent;
        stakeNonceInfos[msg.sender][nonce].stakingTokenAmount = 0;
        stakeNonceInfos[msg.sender][nonce].rewardsTokenAmount = 0;
        stakingToken.safeTransfer(msg.sender, amount);
        
        emit Withdrawn(msg.sender, amount);
    }

    function getReward() public override nonReentrant whenNotPaused {
        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            for (uint256 i = 0; i < stakeNonces[msg.sender]; i++) {
                stakeNonceInfos[msg.sender][i].stakeTime = block.timestamp;
            }
            rewardsPaymentToken.safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, address(rewardsPaymentToken), reward);
        }
    }

    function getRewardForUser(address user) public override nonReentrant whenNotPaused {
        require(msg.sender == owner(), "StakingRewardFixedAPY :: isn`t allowed to call rewards");
        uint256 reward = earned(user);
        if (reward > 0) {
            for (uint256 i = 0; i < stakeNonces[user]; i++) {
                stakeNonceInfos[user][i].stakeTime = block.timestamp;
            }
            rewardsPaymentToken.safeTransfer(msg.sender, reward);
            emit RewardPaid(user, address(rewardsPaymentToken), reward);
        }
    }

    function withdrawAndGetReward(uint256 nonce) external override {
        getReward();
        withdraw(nonce);
    }

    function getTokenAmountForToken(address tokenSrc, address tokenDest, uint256 tokenAmount) public view returns (uint) { 
        if (tokenSrc == tokenDest) return tokenAmount;
        if (usePriceFeeds && address(priceFeed) != address(0)) {
            (uint256 rate, uint256 precision) = priceFeed.queryRate(tokenSrc, tokenDest);
            return tokenAmount * rate / precision;
        } 
        address[] memory path = new address[](2);
        path[0] = tokenSrc;
        path[1] = tokenDest;
        return swapRouter.getAmountsOut(tokenAmount, path)[1];
    }


    function getEquivalentAmount(uint256 amount) public view returns (uint) {
        uint256 equivalent;
        if (stakingToken != rewardsToken) {
            equivalent = getTokenAmountForToken(address(stakingToken), address(rewardsToken), amount);
        } else {
            equivalent = amount;   
        }
        
        return equivalent;
    }

    function isStakerAllowed(address staker) public view returns (bool) {
        return _isStakerAllowed[staker];
    }

    // allowance for particular Staking Sets    
    function updateAllowedStaker(address staker, bool isAllowed) external onlyOwner {
        _isStakerAllowed[staker] = isAllowed;
    }

    function setPaused(bool _paused) external onlyOwner {
        if (_paused) _pause();
        else _unpause();
    }

    function updateRewardRate(uint256 _rewardRate) external onlyOwner {
        rewardRate = _rewardRate;
        emit RewardRateUpdated(rateChangesNonce, _rewardRate, block.timestamp);
        APYcheckpoints[rateChangesNonce++] = APYCheckpoint(block.timestamp, _rewardRate);
    }

    function updateSwapRouter(address newSwapRouter) external onlyOwner {
        require(newSwapRouter != address(0), "StakingRewardFixedAPY: Address is zero");
        swapRouter = INimbusRouter(newSwapRouter);
    }

    function updateRewardsPaymentToken(address newRewardsPaymentToken) external onlyOwner {
        require(Address.isContract(newRewardsPaymentToken), "StakingRewardFixedAPY: Address is zero");
        rewardsPaymentToken = IERC20(newRewardsPaymentToken);
        emit RewardsPaymentTokenChanged(newRewardsPaymentToken);
    }

    function updatePriceFeed(address newPriceFeed) external onlyOwner {
        require(newPriceFeed != address(0), "StakingRewardFixedAPY: Address is zero");
        priceFeed = IPriceFeed(newPriceFeed);
    }

    function updateUsePriceFeeds(bool isUsePriceFeeds) external onlyOwner {
        usePriceFeeds = isUsePriceFeeds;
        emit UpdateUsePriceFeeds(isUsePriceFeeds);
    }

    function rescueEIP20(address to, address token, uint256 amount) external onlyOwner whenPaused {
        require(to != address(0), "StakingRewardFixedAPY: Cannot rescue to the zero address");
        require(amount > 0, "StakingRewardFixedAPY: Cannot rescue 0");
        
        IERC20(token).safeTransfer(to, amount);
        emit RescueEIP20(to, address(token), amount);
    }

    function rescueBNB(address payable to, uint256 amount) external onlyOwner whenPaused {
        require(to != address(0), "StakingRewardFixedAPY: Cannot rescue to the zero address");
        require(amount > 0, "StakingRewardFixedAPY: Cannot rescue 0");

        Address.sendValue(to, amount);
        emit RescueBNB(to, amount);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
                /// @solidity memory-safe-assembly
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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
abstract contract ReentrancyGuard {
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

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
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

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
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
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

interface INimbusRouter {
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IPriceFeed {
    function queryRate(address sourceTokenAddress, address destTokenAddress) external view returns (uint256 rate, uint256 precision);
}

contract PriceFeedSwapModifier is INimbusRouter, Ownable {
    uint256 internal constant WEI_PRECISION = 10**18;

    INimbusRouter immutable public swapRouter;
    IPriceFeed immutable public priceFeed;

    IERC20Metadata public baseToken;
    
    mapping (address => bool) public usePriceFeedForToken;
    mapping (address => address) private tokenAlias;

    constructor(address _swapRouter, address _priceFeed, address _baseToken) {
        require(Address.isContract(_swapRouter), "Swap router should be a contract");
        require(Address.isContract(_priceFeed), "PriceFeed should be a contract");
        require(Address.isContract(_baseToken), "Base token should be a contract");
        swapRouter = INimbusRouter(_swapRouter);
        priceFeed = IPriceFeed(_priceFeed);
        baseToken = IERC20Metadata(_baseToken);
    }

    function setTokenAlias(address _token, address _alias) external onlyOwner {
        require(Address.isContract(_token) && Address.isContract(_alias), "Token and alias should be a contract");
        tokenAlias[_token] = _alias;
    }

    function setBaseToken(address _baseToken) external onlyOwner {
        require(Address.isContract(_baseToken), "Base token should be a contract");
        baseToken = IERC20Metadata(_baseToken);
    }

    function setUsePriceFeedForToken(address _token, bool _usePriceFeed) external onlyOwner {
        require(Address.isContract(_token), "Token should be a contract");
        usePriceFeedForToken[_token] = _usePriceFeed;
    }

    function getAmountsOut(uint256 amountIn, address[] memory path)
        public
        override
        view
        returns (uint256[] memory amounts)
    {
        amounts = new uint256[](2);
        amounts[0] = amountIn;
        amounts[1] = rateConversion(amountIn, path[0], path[1], true);
    }

    function getAmountsIn(uint256 amountOut, address[] memory path)
        public
        override
        view
        returns (uint256[] memory amounts)
    {
        amounts = new uint256[](2);
        amounts[0] = rateConversion(amountOut, path[0], path[1], false);
        amounts[1] = amountOut;
    }

    function rateConversion(uint256 amount, address sourceTokenAddress, address destTokenAddress, bool isOut) public view returns (uint256 result) {
        if (amount == 0) return 0;
        sourceTokenAddress = replaceToken(sourceTokenAddress);
        destTokenAddress = replaceToken(destTokenAddress);

        if (!usePriceFeedForToken[sourceTokenAddress] && !usePriceFeedForToken[destTokenAddress]) {
            // ex. BNB-NIMB(NBU)(sw)
            result = _swapResult(amount, sourceTokenAddress, destTokenAddress, isOut);
            return result;
        } else if (usePriceFeedForToken[sourceTokenAddress] && usePriceFeedForToken[destTokenAddress]) {
            result = _priceFeedResult(amount, sourceTokenAddress, destTokenAddress, isOut);
            return result;
        }

        if (usePriceFeedForToken[sourceTokenAddress] && !usePriceFeedForToken[destTokenAddress]) {
            // ex. BUSD-NIMB(NBU) -> BUSD-BNB(pf)/BNB-NBU(sw)
            uint256 sourceToBaseAmount = _priceFeedResult(amount, sourceTokenAddress, address(baseToken), isOut);
            result = _swapResult(sourceToBaseAmount, address(baseToken), destTokenAddress, isOut);
            return result;
        }
        if (!usePriceFeedForToken[sourceTokenAddress] && usePriceFeedForToken[destTokenAddress]) {
            // ex. NIMB(NBU)-BUSD -> NBU-BNB(sw)/BNB-BUSD(pf)
            uint256 sourceToBaseAmount = _swapResult(amount, sourceTokenAddress, address(baseToken), isOut);
            result = _priceFeedResult(sourceToBaseAmount, address(baseToken), destTokenAddress, isOut);
            return result;
        }
    }

    function _swapResult(uint256 amount, address sourceTokenAddress, address destTokenAddress, bool isOut) public view returns (uint256 result) {
        if (sourceTokenAddress == destTokenAddress) return amount;
        address[] memory path = new address[](2);
        path[0] = sourceTokenAddress;
        path[1] = destTokenAddress;
        result = isOut ? swapRouter.getAmountsOut(amount, path)[1] : swapRouter.getAmountsIn(amount, path)[0];
    }

    function _priceFeedResult(uint256 amount, address sourceTokenAddress, address destTokenAddress, bool isOut) public view returns (uint256 result) {
        if (sourceTokenAddress == destTokenAddress) return amount;
        (uint256 rate, uint256 precision) = priceFeed.queryRate(sourceTokenAddress, destTokenAddress);
        result = isOut ? amount * rate / precision : amount * precision / rate;
    }

    function replaceToken(address token) public view returns (address) {
        return tokenAlias[token] != address(0) ? tokenAlias[token] : token;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

interface IPriceFeedsExt {
    function latestAnswer() external view returns (uint256);
}

interface INimbusRouter {
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

contract PriceFeedSwap is IPriceFeedsExt, Ownable {
    INimbusRouter immutable public swapRouter;
    address[] public swapPath;

    uint8 immutable public decimals;
    uint256 public multiplier;

    uint256 constant MULTIPLIER_DEFAULT = 10000;

    event SetMultiplier(uint256 oldMultiplier, uint256 newMultiplier);

    constructor(address _swapRouter, address[] memory _swapPath) {
        require(Address.isContract(_swapRouter), "Swap router should be a contract");
        swapRouter = INimbusRouter(_swapRouter);
        require(_swapPath.length > 1, "Swap path should consists of more then 2 contracts");
        for (uint8 i = 0; i < _swapPath.length; i++) {
            require(Address.isContract(_swapPath[i]), "Swap path should consists of contracts");
            swapPath.push(_swapPath[i]);
        }
        decimals = IERC20Metadata(_swapPath[_swapPath.length-1]).decimals();
        multiplier = MULTIPLIER_DEFAULT;
    }
    
    /**
     * @notice Sets price multiplier
     * @param newMultiplier new multiplier
     * @dev This method sets new price multiplier, with base multiplier is 10000
     * For example, for 3% change set multiplier to 10300
     * Can be executed only by owner.
     */
    function setMultiplier(uint256 newMultiplier) external onlyOwner {
        emit SetMultiplier(multiplier, newMultiplier);
        multiplier = newMultiplier;
    }
    
    /**
     * @notice Returns last price update timestamp
     * @dev This method returns last price update timestamp
     */
    function lastUpdateTimestamp() external view returns (uint256) {
        return block.timestamp;
    } 
    
    /**
     * @notice Returns rate
     * @dev This method returns rate with applied multiplier
     */
    function latestAnswer() external override view returns (uint256) {
        return swapRouter.getAmountsOut(10 ** decimals, swapPath)[swapPath.length - 1] * multiplier / MULTIPLIER_DEFAULT;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface INimbusRouter {
    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IStakingRewards {
    function earned(address account) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function stake(uint256 amount) external;
    function stakeFor(uint256 amount, address user) external;
    function getReward() external;
    function getRewardForUser(address user) external;
    function withdraw(uint256 nonce) external;
    function withdrawAndGetReward(uint256 nonce) external;
}

interface IPriceFeed {
    function queryRate(address sourceTokenAddress, address destTokenAddress) external view returns (uint256 rate, uint256 precision);
    function wbnbToken() external view returns(address);
}

contract StakingRewardFixedAPY is IStakingRewards, ReentrancyGuard, Ownable, Pausable {
    using SafeERC20 for IERC20;

    IERC20 public immutable rewardsToken;
    IERC20 public rewardsPaymentToken;
    IERC20 public immutable stakingToken;
    INimbusRouter public swapRouter;
    uint256 public rewardRate; 
    uint256 public constant rewardDuration = 365 days; 
    uint256 public rateChangesNonce;

    mapping(address => mapping(uint256 => StakeNonceInfo)) public stakeNonceInfos;
    mapping(address => uint256) public stakeNonces;
    mapping(uint256 => APYCheckpoint) APYcheckpoints;

    struct StakeNonceInfo {
        uint256 stakeTime;
        uint256 stakingTokenAmount;
        uint256 rewardsTokenAmount;
        uint256 rewardRate;
    }

    struct APYCheckpoint {
        uint256 timestamp;
        uint256 rewardRate;
    }

    uint256 private _totalSupply;
    uint256 private _totalSupplyRewardEquivalent;
    mapping(address => uint256) private _balances;
    mapping(address => uint256) private _balancesRewardEquivalent;

    bool public usePriceFeeds;
    IPriceFeed public priceFeed;

    event RewardRateUpdated(uint256 indexed rateChangesNonce, uint256 rewardRate, uint256 timestamp);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, address indexed paymentToken, uint256 reward);
    event RewardsPaymentTokenChanged(address indexed newRewardsPaymentToken);
    event RescueBNB(address indexed to, uint256 amount);
    event RescueEIP20(address indexed to, address indexed token, uint256 amount);
    event UpdateUsePriceFeeds(bool indexed isUsePriceFeeds);

    constructor(
        address _rewardsToken,
        address _rewardsPaymentToken,
        address _stakingToken,
        address _swapRouter,
        uint256 _rewardRate
    ) {
        require(
            _rewardsToken != address(0) && _rewardsPaymentToken != address(0) && _swapRouter != address(0), 
            "StakingRewardFixedAPY: Zero address(es)"
        );
        rewardsToken = IERC20(_rewardsToken);
        rewardsPaymentToken = IERC20(_rewardsPaymentToken);
        stakingToken = IERC20(_stakingToken);
        swapRouter = INimbusRouter(_swapRouter);
        rewardRate = _rewardRate;
        emit RewardRateUpdated(rateChangesNonce, _rewardRate, block.timestamp);
        APYcheckpoints[rateChangesNonce++] = APYCheckpoint(block.timestamp, rewardRate);
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function totalSupplyRewardEquivalent() external view returns (uint256) {
        return _totalSupplyRewardEquivalent;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }
    
    function balanceOfRewardEquivalent(address account) external view returns (uint256) {
        return _balancesRewardEquivalent[account];
    }

    function earnedByNonce(address account, uint256 nonce) public view returns (uint256) {
        uint256 amount = stakeNonceInfos[account][nonce].rewardsTokenAmount * 
            (block.timestamp - stakeNonceInfos[account][nonce].stakeTime) *
             stakeNonceInfos[account][nonce].rewardRate / (100 * rewardDuration);
        return getTokenAmountForToken(address(rewardsToken), address(rewardsPaymentToken), amount);
    }

    function earned(address account) public view override returns (uint256 totalEarned) {
        for (uint256 i = 0; i < stakeNonces[account]; i++) {
            totalEarned += earnedByNonce(account, i);
        }
    }

    function stakeWithPermit(uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external nonReentrant {
        require(amount > 0, "StakingRewardFixedAPY: Cannot stake 0");
        // permit
        IERC20Permit(address(stakingToken)).permit(msg.sender, address(this), amount, deadline, v, r, s);
        _stake(amount, msg.sender);
    }

    function stake(uint256 amount) external override nonReentrant {
        require(amount > 0, "StakingRewardFixedAPY: Cannot stake 0");
        _stake(amount, msg.sender);
    }

    function stakeFor(uint256 amount, address user) external override nonReentrant {
        require(amount > 0, "StakingRewardFixedAPY: Cannot stake 0");
        require(user != address(0), "StakingRewardFixedAPY: Cannot stake for zero address");
        _stake(amount, user);
    }

    function _stake(uint256 amount, address user) private whenNotPaused {
        stakingToken.safeTransferFrom(msg.sender, address(this), amount);
        uint256 amountRewardEquivalent = getEquivalentAmount(amount);

        _totalSupply += amount;
        _totalSupplyRewardEquivalent += amountRewardEquivalent;
        _balances[user] += amount;

        uint256 stakeNonce = stakeNonces[user]++;
        stakeNonceInfos[user][stakeNonce].stakingTokenAmount = amount;
        stakeNonceInfos[user][stakeNonce].stakeTime = block.timestamp;
        stakeNonceInfos[user][stakeNonce].rewardRate = rewardRate;
        stakeNonceInfos[user][stakeNonce].rewardsTokenAmount = amountRewardEquivalent;
        _balancesRewardEquivalent[user] += amountRewardEquivalent;
        emit Staked(user, amount);
    }



    //A user can withdraw its staking tokens even if there is no rewards tokens on the contract account
    function withdraw(uint256 nonce) public override nonReentrant whenNotPaused {
        require(stakeNonceInfos[msg.sender][nonce].stakingTokenAmount > 0, "StakingRewardFixedAPY: This stake nonce was withdrawn");
        uint256 amount = stakeNonceInfos[msg.sender][nonce].stakingTokenAmount;
        uint256 amountRewardEquivalent = stakeNonceInfos[msg.sender][nonce].rewardsTokenAmount;
        _totalSupply -= amount;
        _totalSupplyRewardEquivalent -= amountRewardEquivalent;
        _balances[msg.sender] -= amount;
        _balancesRewardEquivalent[msg.sender] -= amountRewardEquivalent;
        stakeNonceInfos[msg.sender][nonce].stakingTokenAmount = 0;
        stakeNonceInfos[msg.sender][nonce].rewardsTokenAmount = 0;
        stakingToken.safeTransfer(msg.sender, amount);
        
        emit Withdrawn(msg.sender, amount);
    }

    function getReward() public override nonReentrant whenNotPaused {
        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            for (uint256 i = 0; i < stakeNonces[msg.sender]; i++) {
                stakeNonceInfos[msg.sender][i].stakeTime = block.timestamp;
            }
            rewardsPaymentToken.safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, address(rewardsPaymentToken), reward);
        }
    }

    function getRewardForUser(address user) public override nonReentrant whenNotPaused {
        require(msg.sender == owner(), "StakingRewardFixedAPY :: isn`t allowed to call rewards");
        uint256 reward = earned(user);
        if (reward > 0) {
            for (uint256 i = 0; i < stakeNonces[user]; i++) {
                stakeNonceInfos[user][i].stakeTime = block.timestamp;
            }
            rewardsPaymentToken.safeTransfer(msg.sender, reward);
            emit RewardPaid(user, address(rewardsPaymentToken), reward);
        }
    }

    function withdrawAndGetReward(uint256 nonce) external override {
        getReward();
        withdraw(nonce);
    }

    function getTokenAmountForToken(address tokenSrc, address tokenDest, uint256 tokenAmount) public view returns (uint) { 
        if (tokenSrc == tokenDest) return tokenAmount;
        if (usePriceFeeds && address(priceFeed) != address(0)) {
            (uint256 rate, uint256 precision) = priceFeed.queryRate(tokenSrc, tokenDest);
            return tokenAmount * rate / precision;
        } 
        address[] memory path = new address[](2);
        path[0] = tokenSrc;
        path[1] = tokenDest;
        return swapRouter.getAmountsOut(tokenAmount, path)[1];
    }

    function exit() external {
        getReward();
        for (uint256 i = 0; i < stakeNonces[msg.sender]; i++) {
            if (stakeNonceInfos[msg.sender][i].stakingTokenAmount > 0) {
                withdraw(i);
            }
        }

        stakeNonces[msg.sender] = 0;
    }

    function getEquivalentAmount(uint256 amount) public view returns (uint) {
        uint256 equivalent;
        if (stakingToken != rewardsToken) {
            equivalent = getTokenAmountForToken(address(stakingToken), address(rewardsToken), amount);
        } else {
            equivalent = amount;   
        }
        
        return equivalent;
    }

    function setPaused(bool _paused) external onlyOwner {
        if (_paused) _pause();
        else _unpause();
    }

    function updateRewardRate(uint256 _rewardRate) external onlyOwner {
        rewardRate = _rewardRate;
        emit RewardRateUpdated(rateChangesNonce, _rewardRate, block.timestamp);
        APYcheckpoints[rateChangesNonce++] = APYCheckpoint(block.timestamp, _rewardRate);
    }

    function updateSwapRouter(address newSwapRouter) external onlyOwner {
        require(newSwapRouter != address(0), "StakingRewardFixedAPY: Address is zero");
        swapRouter = INimbusRouter(newSwapRouter);
    }

    function updateRewardsPaymentToken(address newRewardsPaymentToken) external onlyOwner {
        require(Address.isContract(newRewardsPaymentToken), "StakingRewardFixedAPY: Address is zero");
        rewardsPaymentToken = IERC20(newRewardsPaymentToken);
        emit RewardsPaymentTokenChanged(newRewardsPaymentToken);
    }

    function updatePriceFeed(address newPriceFeed) external onlyOwner {
        require(newPriceFeed != address(0), "StakingRewardFixedAPY: Address is zero");
        priceFeed = IPriceFeed(newPriceFeed);
    }

    function updateUsePriceFeeds(bool isUsePriceFeeds) external onlyOwner {
        usePriceFeeds = isUsePriceFeeds;
        emit UpdateUsePriceFeeds(isUsePriceFeeds);
    }

    function rescueEIP20(address to, address token, uint256 amount) external onlyOwner whenPaused {
        require(to != address(0), "StakingRewardFixedAPY: Cannot rescue to the zero address");
        require(amount > 0, "StakingRewardFixedAPY: Cannot rescue 0");
        
        IERC20(token).safeTransfer(to, amount);
        emit RescueEIP20(to, address(token), amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

interface INimbusPair is IERC20 {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface INimbusRouter {
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IStakingRewards {
    function earned(address account) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function stake(uint256 amount) external;
    function stakeFor(uint256 amount, address user) external;
    function getReward() external;
    function getRewardForUser(address user) external;
    function withdraw(uint256 nonce) external;
    function withdrawAndGetReward(uint256 nonce) external;
}

interface IPriceFeed {
    function queryRate(address sourceTokenAddress, address destTokenAddress) external view returns (uint256 rate, uint256 precision);
    function wbnbToken() external view returns(address);
}

contract StakingLPRewardFixedAPY is IStakingRewards, ReentrancyGuard, Ownable, Pausable {
    using SafeERC20 for IERC20;
    using SafeERC20 for INimbusPair;

    IERC20 public rewardsToken;
    IERC20 public rewardsPaymentToken;
    INimbusPair public immutable stakingLPToken;

    INimbusRouter public swapRouter;
    address public immutable lPPairTokenA;
    address public immutable lPPairTokenB;
    uint256 public rewardRate; 
    uint256 public rateChangesNonce;
    uint256 public constant rewardDuration = 365 days; 

    mapping(address => mapping(uint256 => StakeNonceInfo)) public stakeNonceInfos;
    mapping(address => uint256) public stakeNonces;
    mapping(uint256 => APYCheckpoint) APYcheckpoints;

    struct StakeNonceInfo {
        uint256 stakeTime;
        uint256 stakingLPTokenAmount;
        uint256 rewardsTokenAmount;
        uint256 rewardRate;
    }

    struct APYCheckpoint {
        uint256 timestamp;
        uint256 rewardRate;
    }

    uint256 private _totalSupply;
    uint256 private _totalSupplyRewardEquivalent;
    uint256 private immutable _tokenADecimalCompensate;
    uint256 private immutable _tokenBDecimalCompensate;
    mapping(address => uint256) private _balances;
    mapping(address => uint256) private _balancesRewardEquivalent;

    bool public usePriceFeeds;
    bool public tokenAUsePriceFeed;
    bool public tokenBUsePriceFeed;
    IPriceFeed public priceFeed;

    event RewardRateUpdated(uint256 indexed rateChangesNonce, uint256 rewardRate, uint256 timestamp);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, address indexed paymentToken, uint256 reward);
    event RescueIERC20(address indexed to, address indexed token, uint256 amount);
    event UpdateUsePriceFeeds(bool indexed usePriceFeeds);
    event RewardsPaymentTokenChanged(address indexed newRewardsPaymentToken);

    constructor(
        address _rewardsToken,
        address _rewardsPaymentToken,
        address _stakingLPToken,
        address _lPPairTokenA,
        address _lPPairTokenB,
        address _swapRouter,
        uint _rewardRate
    ) {
        require(_rewardsToken != address(0) && _stakingLPToken != address(0) && _lPPairTokenA != address(0) && _lPPairTokenB != address(0) && _swapRouter != address(0), "StakingLPRewardFixedAPY: Zero address(es)");
        rewardsToken = IERC20(_rewardsToken);
        rewardsPaymentToken = IERC20(_rewardsPaymentToken);
        stakingLPToken = INimbusPair(_stakingLPToken);
        swapRouter = INimbusRouter(_swapRouter);
        rewardRate = _rewardRate;
        lPPairTokenA = _lPPairTokenA;
        lPPairTokenB = _lPPairTokenB;
        uint tokenADecimals = IERC20Metadata(_lPPairTokenA).decimals();
        require(tokenADecimals >= 6, "StakingLPRewardFixedAPY: small amount of decimals");
        _tokenADecimalCompensate = tokenADecimals - 6;
        uint tokenBDecimals = IERC20Metadata(_lPPairTokenB).decimals();
        require(tokenBDecimals >= 6, "StakingLPRewardFixedAPY: small amount of decimals");
        _tokenBDecimalCompensate = tokenBDecimals - 6;
        emit RewardRateUpdated(rateChangesNonce, _rewardRate, block.timestamp);
        APYcheckpoints[rateChangesNonce++] = APYCheckpoint(block.timestamp, rewardRate);
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function totalSupplyRewardEquivalent() external view returns (uint256) {
        return _totalSupplyRewardEquivalent;
    }

    function getDecimalPriceCalculationCompensate() external view returns (uint tokenADecimalCompensate, uint tokenBDecimalCompensate) { 
        tokenADecimalCompensate = _tokenADecimalCompensate;
        tokenBDecimalCompensate = _tokenBDecimalCompensate;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }
    
    function balanceOfRewardEquivalent(address account) external view returns (uint256) {
        return _balancesRewardEquivalent[account];
    }

    function earnedByNonce(address account, uint256 nonce) public view returns (uint256) {
        uint256 amount = stakeNonceInfos[account][nonce].rewardsTokenAmount * 
            (block.timestamp - stakeNonceInfos[account][nonce].stakeTime) *
             stakeNonceInfos[account][nonce].rewardRate / (100 * rewardDuration);
        return getTokenAmountForToken(address(rewardsToken), address(rewardsPaymentToken), amount);
    }

    function getTokenAmountForToken(address tokenSrc, address tokenDest, uint tokenAmount) public view returns (uint) { 
        if (tokenSrc == tokenDest) return tokenAmount;
        if (usePriceFeeds && address(priceFeed) != address(0)) {
            (uint256 rate, uint256 precision) = priceFeed.queryRate(tokenSrc, tokenDest);
            return tokenAmount * rate / precision;
        } 
        address[] memory path = new address[](2);
        path[0] = tokenSrc;
        path[1] = tokenDest;
        return swapRouter.getAmountsOut(tokenAmount, path)[1];
    }

    function earned(address account) public view override returns (uint256 totalEarned) {
        for (uint256 i = 0; i < stakeNonces[account]; i++) {
            totalEarned += earnedByNonce(account, i);
        }
    }

    function stakeWithPermit(uint256 amount, uint deadline, uint8 v, bytes32 r, bytes32 s) external nonReentrant {
        require(amount > 0, "StakingLPRewardFixedAPY: Cannot stake 0");
        // permit
        IERC20Permit(address(stakingLPToken)).permit(msg.sender, address(this), amount, deadline, v, r, s);
        _stake(amount, msg.sender);
    }

    function stake(uint256 amount) external override nonReentrant {
        require(amount > 0, "StakingLPRewardFixedAPY: Cannot stake 0");
        _stake(amount, msg.sender);
    }

    function stakeFor(uint256 amount, address user) external override nonReentrant {
        require(amount > 0, "StakingLPRewardFixedAPY: Cannot stake 0");
        require(user != address(0), "StakingLPRewardFixedAPY: Cannot stake for zero address");
        _stake(amount, user);
    }

    function _stake(uint256 amount, address user) private {
        IERC20(address(stakingLPToken)).safeTransferFrom(msg.sender, address(this), amount);
        uint amountRewardEquivalent = getCurrentLPPrice() * amount / 1e18;

        _totalSupply += amount;
        _totalSupplyRewardEquivalent += amountRewardEquivalent;
        _balances[user] += amount;

        uint stakeNonce = stakeNonces[user]++;
        stakeNonceInfos[user][stakeNonce].stakingLPTokenAmount = amount;
        stakeNonceInfos[user][stakeNonce].stakeTime = block.timestamp;
        stakeNonceInfos[user][stakeNonce].rewardRate = rewardRate;
        stakeNonceInfos[user][stakeNonce].rewardsTokenAmount = amountRewardEquivalent;
        _balancesRewardEquivalent[user] += amountRewardEquivalent;
        emit Staked(user, amount);
    }


    //A user can withdraw its staking tokens even if there is no rewards tokens on the contract account
    function withdraw(uint256 nonce) public override nonReentrant {
        require(stakeNonceInfos[msg.sender][nonce].stakingLPTokenAmount > 0, "StakingLPRewardFixedAPY: This stake nonce was withdrawn");
        uint amount = stakeNonceInfos[msg.sender][nonce].stakingLPTokenAmount;
        uint amountRewardEquivalent = stakeNonceInfos[msg.sender][nonce].rewardsTokenAmount;
        _totalSupply -= amount;
        _totalSupplyRewardEquivalent -= amountRewardEquivalent;
        _balances[msg.sender] -= amount;
        _balancesRewardEquivalent[msg.sender] -= amountRewardEquivalent;
        stakeNonceInfos[msg.sender][nonce].stakingLPTokenAmount = 0;
        stakeNonceInfos[msg.sender][nonce].rewardsTokenAmount = 0;
        stakingLPToken.safeTransfer(msg.sender, amount);
        
        emit Withdrawn(msg.sender, amount);
    }

      function getReward() public override nonReentrant whenNotPaused {
        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            for (uint256 i = 0; i < stakeNonces[msg.sender]; i++) {
                stakeNonceInfos[msg.sender][i].stakeTime = block.timestamp;
            }
            rewardsPaymentToken.safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, address(rewardsPaymentToken), reward);
        }
    }

    function getRewardForUser(address user) public override nonReentrant whenNotPaused {
        require(msg.sender == owner(), "StakingLPRewardFixedAPY :: isn`t allowed to call rewards");
        uint256 reward = earned(user);
        if (reward > 0) {
            for (uint256 i = 0; i < stakeNonces[user]; i++) {
                stakeNonceInfos[user][i].stakeTime = block.timestamp;
            }
            rewardsPaymentToken.safeTransfer(msg.sender, reward);
            emit RewardPaid(user, address(rewardsPaymentToken), reward);
        }
    }


    function withdrawAndGetReward(uint256 nonce) external override {
        getReward();
        withdraw(nonce);
    }

    function getCurrentLPPrice() public view returns (uint) {
        // LP PRICE = 2 * SQRT(reserveA * reaserveB ) * SQRT(token1/RewardTokenPrice * token2/RewardTokenPrice) / LPTotalSupply
        uint tokenAToRewardPrice;
        uint tokenBToRewardPrice;
        address rewardToken = address(rewardsToken);    
        address[] memory path = new address[](2);
        path[1] = address(rewardToken);

        if (lPPairTokenA != rewardToken) {
            path[0] = lPPairTokenA;
            if (tokenAUsePriceFeed) {
                (uint256 rate, uint256 precision) = priceFeed.queryRate(path[0], path[1]);
                tokenAToRewardPrice = 10 ** 6 * rate / precision;
            } else tokenAToRewardPrice = swapRouter.getAmountsOut(10 ** 6, path)[1];
            
            if (_tokenADecimalCompensate > 0) 
                tokenAToRewardPrice = tokenAToRewardPrice * (10 ** _tokenADecimalCompensate);
        } else {
            tokenAToRewardPrice = 1e18;
        }
        
        if (lPPairTokenB != rewardToken) {
            path[0] = lPPairTokenB;
            if (tokenBUsePriceFeed) {
                (uint256 rate, uint256 precision) = priceFeed.queryRate(path[0], path[1]);
                tokenBToRewardPrice = 10 ** 6 * rate / precision;
            } else tokenBToRewardPrice = swapRouter.getAmountsOut(10 ** 6, path)[1];
            if (_tokenBDecimalCompensate > 0)
                tokenBToRewardPrice = tokenBToRewardPrice * (10 ** _tokenBDecimalCompensate);
        } else {
            tokenBToRewardPrice = 1e18;
        }

        uint totalLpSupply = IERC20(stakingLPToken).totalSupply();
        require(totalLpSupply > 0, "StakingLPRewardFixedAPY: No liquidity for pair");
        (uint reserveA, uint reaserveB,) = stakingLPToken.getReserves();
        uint price = 
            uint(2) * Math.sqrt(reserveA * reaserveB)
            * Math.sqrt(tokenAToRewardPrice * tokenBToRewardPrice) / totalLpSupply;
        
        return price;
    }

    function exit() external {
        getReward();
        for (uint256 i = 0; i < stakeNonces[msg.sender]; i++) {
            if (stakeNonceInfos[msg.sender][i].stakingLPTokenAmount > 0) {
                withdraw(i);
            }
        }

        stakeNonces[msg.sender] = 0;
    }

    function updateRewardRate(uint256 _rewardRate) external onlyOwner {
        rewardRate = _rewardRate;
        emit RewardRateUpdated(rateChangesNonce, _rewardRate, block.timestamp);
        APYcheckpoints[rateChangesNonce++] = APYCheckpoint(block.timestamp, _rewardRate);
    }

    function updateSwapRouter(address newSwapRouter) external onlyOwner {
        require(newSwapRouter != address(0), "StakingLPRewardFixedAPY: Address is zero");
        swapRouter = INimbusRouter(newSwapRouter);
    }

    function updateRewardsPaymentToken(address newRewardsPaymentToken) external onlyOwner {
        require(Address.isContract(newRewardsPaymentToken), "StakingLPRewardFixedAPY: Address is zero");
        rewardsPaymentToken = IERC20(newRewardsPaymentToken);

        emit RewardsPaymentTokenChanged(newRewardsPaymentToken);
    }

    function updateTokenUsePriceFeeds(bool _tokenAUsePriceFeed, bool _tokenBUsePriceFeed) external onlyOwner {
        tokenAUsePriceFeed = _tokenAUsePriceFeed;
        tokenBUsePriceFeed = _tokenBUsePriceFeed;
    }

    function updateUsePriceFeeds(bool isUsePriceFeeds) external onlyOwner {
        usePriceFeeds = isUsePriceFeeds;
        emit UpdateUsePriceFeeds(isUsePriceFeeds);
    }

    function updatePriceFeed(address newPriceFeed) external onlyOwner {
        require(newPriceFeed != address(0), "StakingLPRewardFixedAPY: Address is zero");
        priceFeed = IPriceFeed(newPriceFeed);
    }

    function rescueIERC20(address to, address token, uint256 amount) external onlyOwner whenPaused {
        require(to != address(0), "StakingRewardFixedAPY: Cannot rescue to the zero address");
        require(amount > 0, "StakingRewardFixedAPY: Cannot rescue 0");
        
        IERC20(token).safeTransfer(to, amount);
        emit RescueIERC20(to, address(token), amount);
    }

    function setPaused(bool _paused) external onlyOwner {
        if (_paused) _pause();
        else _unpause();
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. It the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`.
        // We also know that `k`, the position of the most significant bit, is such that `msb(a) = 2**k`.
        // This gives `2**k < a <= 2**(k+1)` → `2**(k/2) <= sqrt(a) < 2 ** (k/2+1)`.
        // Using an algorithm similar to the msb conmputation, we are able to compute `result = 2**(k/2)` which is a
        // good first aproximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1;
        uint256 x = a;
        if (x >> 128 > 0) {
            x >>= 128;
            result <<= 64;
        }
        if (x >> 64 > 0) {
            x >>= 64;
            result <<= 32;
        }
        if (x >> 32 > 0) {
            x >>= 32;
            result <<= 16;
        }
        if (x >> 16 > 0) {
            x >>= 16;
            result <<= 8;
        }
        if (x >> 8 > 0) {
            x >>= 8;
            result <<= 4;
        }
        if (x >> 4 > 0) {
            x >>= 4;
            result <<= 2;
        }
        if (x >> 2 > 0) {
            result <<= 1;
        }

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        uint256 result = sqrt(a);
        if (rounding == Rounding.Up && result * result < a) {
            result += 1;
        }
        return result;
    }
}