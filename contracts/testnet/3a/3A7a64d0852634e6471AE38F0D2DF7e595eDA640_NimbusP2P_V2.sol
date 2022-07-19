// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }
    function safeTransfer(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }
    function safeTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }
    function safeTransferBNB(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: BNB_TRANSFER_FAILED');
    }
}

interface IEIP721 {
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) external;    
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
}

interface IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) external returns (bytes4);
}

interface IWBNB {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

interface IEIP20Permit {
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
}

interface IEIP20 {
    function decimals() external returns (uint8);
}

contract NimbusP2P_V2Storage is Initializable, ContextUpgradeable, OwnableUpgradeable, PausableUpgradeable {    
    struct TradeSingle {
        address initiator;
        address counterparty;
        address proposedAsset;
        uint proposedAmount;
        uint proposedTokenId;
        address askedAsset;
        uint askedAmount;
        uint askedTokenId;
        uint deadline;
        uint status; //0: Active, 1: success, 2: canceled, 3: withdrawn
        bool isAskedAssetNFT;
    }

    struct TradeMulti {
        address initiator;
        address counterparty;
        address[] proposedAssets;
        uint proposedAmount;
        uint[] proposedTokenIds;
        address[] askedAssets;
        uint[] askedTokenIds;
        uint askedAmount;
        uint deadline;
        uint status; //0: Active, 1: success, 2: canceled, 3: withdrawn
        bool isAskedAssetNFTs;
    }

    enum TradeState {
        Active,
        Succeeded,
        Canceled,
        Withdrawn,
        Overdue
    }

    IWBNB public constant WBNB = IWBNB(0xA2CA18FC541B7B101c64E64bBc2834B05066248b);
    uint public tradeCount;
    mapping(uint => TradeSingle) public tradesSingle;
    mapping(uint => TradeMulti) public tradesMulti;
    mapping(address => uint[]) internal _userTrades;

    bool public isAnyNFTAllowed;
    mapping(address => bool) public allowedNFT;

    bool public isAnyEIP20Allowed;
    mapping(address => bool) public allowedEIP20;

    uint internal unlocked;

    event NewTradeSingle(address indexed user, address indexed proposedAsset, uint proposedAmount, uint proposedTokenId, address indexed askedAsset, uint askedAmount, uint askedTokenId, uint deadline, uint tradeId);
    event NewTradeMulti(address indexed user, address[] proposedAssets, uint proposedAmount, uint[] proposedIds, address[] askedAssets, uint askedAmount, uint[] askedIds, uint deadline, uint indexed tradeId);
    event SupportTrade(uint indexed tradeId, address indexed counterparty);
    event CancelTrade(uint indexed tradeId);
    event WithdrawOverdueAsset(uint indexed tradeId);
    event UpdateIsAnyNFTAllowed(bool indexed isAllowed);
    event UpdateAllowedNFT(address indexed nftContract, bool indexed isAllowed);
    event UpdateIsAnyEIP20Allowed(bool indexed isAllowed);
    event UpdateAllowedEIP20Tokens(address indexed tokenContract, bool indexed isAllowed);
    event Rescue(address indexed to, uint amount);
    event RescueToken(address indexed to, address indexed token, uint amount);
}

contract NimbusP2P_V2 is NimbusP2P_V2Storage, IERC721Receiver {    
    using AddressUpgradeable for address;

    function initialize(
        address[] memory _allowedEIP20Tokens
    ) public initializer {
        __Context_init();
        __Ownable_init();
        __Pausable_init();

        for (uint256 i; i < _allowedEIP20Tokens.length; i++) {
            require(AddressUpgradeable.isContract(_allowedEIP20Tokens[i]));
            allowedEIP20[_allowedEIP20Tokens[i]] = true;
            emit UpdateAllowedEIP20Tokens(_allowedEIP20Tokens[i], true);
        }
        isAnyNFTAllowed = true;
        unlocked = 1;
        emit UpdateIsAnyNFTAllowed(isAnyNFTAllowed);
    }

    receive() external payable {
        assert(msg.sender == address(WBNB)); // only accept ETH via fallback from the WBNB contract
    }
    
    modifier lock() {
        require(unlocked == 1, 'NimbusP2P_V2: locked');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function setPaused(bool _paused) external onlyOwner {
        if (_paused) _pause();
        else _unpause();
    }

    function createTradeEIP20ToEIP20(address proposedAsset, uint proposedAmount, address askedAsset, uint askedAmount, uint deadline) external returns (uint tradeId) {
        require(AddressUpgradeable.isContract(proposedAsset) && AddressUpgradeable.isContract(askedAsset), "NimbusP2P_V2: Not contracts");
         require(IEIP20(proposedAsset).decimals() >= 0, "NimbusP2P_V2: Propossed asset is not an EIP20 token" );
        require(IEIP20(askedAsset).decimals() >= 0, "NimbusP2P_V2: Asked asset is not an EIP20 token" );
        require(proposedAmount > 0, "NimbusP2P_V2: Zero amount not allowed");
        _requireAllowedEIP20(proposedAsset);
        _requireAllowedEIP20(askedAsset);
        TransferHelper.safeTransferFrom(proposedAsset, msg.sender, address(this), proposedAmount);
        tradeId = _createTradeSingle(proposedAsset, proposedAmount, 0, askedAsset, askedAmount, 0, deadline, false);   
    }

    // for trade EIP20 -> Native Coin use createTradeEIP20ToEIP20 and pass WBNB address as asked asset
    function createTradeBNBtoEIP20(address askedAsset, uint askedAmount, uint deadline) payable external returns (uint tradeId) {
        require(AddressUpgradeable.isContract(askedAsset), "NimbusP2P_V2: Not contract");
        require(msg.value > 0, "NimbusP2P_V2: Zero amount not allowed");
        _requireAllowedEIP20(askedAsset);
        WBNB.deposit{value: msg.value}();
        tradeId = _createTradeSingle(address(WBNB), msg.value, 0, askedAsset, askedAmount, 0, deadline, false);   
    }



    function createTradeEIP20ToNFT(address proposedAsset, uint proposedAmount, address askedAsset, uint tokenId, uint deadline) external returns (uint tradeId) {
        require(AddressUpgradeable.isContract(proposedAsset), "NimbusP2P_V2: Not contracts");
        require(proposedAmount > 0, "NimbusP2P_V2: Zero amount not allowed");
        _requireAllowedEIP20(proposedAsset);
        _requireAllowedNFT(askedAsset);
        TransferHelper.safeTransferFrom(proposedAsset, msg.sender, address(this), proposedAmount);
        tradeId = _createTradeSingle(proposedAsset, proposedAmount, 0, askedAsset, 0, tokenId, deadline, true);   
    }

    // for trade NFT -> Native Coin use createTradeNFTtoEIP20 and pass WBNB address as asked asset
    function createTradeNFTtoEIP20(address proposedAsset, uint tokenId, address askedAsset, uint askedAmount, uint deadline) external returns (uint tradeId) {
        require(AddressUpgradeable.isContract(proposedAsset), "NimbusP2P_V2: Not contracts");
        _requireAllowedNFT(proposedAsset);
        _requireAllowedEIP20(askedAsset);
        IEIP721(proposedAsset).safeTransferFrom(msg.sender, address(this), tokenId);
        tradeId = _createTradeSingle(proposedAsset, 0, tokenId, askedAsset, askedAmount, 0, deadline, false);   
    }

    function createTradeBNBtoNFT(address askedAsset, uint tokenId, uint deadline) payable external returns (uint tradeId) {
        require(AddressUpgradeable.isContract(askedAsset), "NimbusP2P_V2: Not contract");
        require(msg.value > 0, "NimbusP2P_V2: Zero amount not allowed");
        _requireAllowedNFT(askedAsset);
        WBNB.deposit{value: msg.value}();
        tradeId = _createTradeSingle(address(WBNB), msg.value, 0, askedAsset, 0, tokenId, deadline, true);   
    }

    function createTradeEIP20ToNFTs(
        address proposedAsset, 
        uint proposedAmount, 
        address[] memory askedAssets, 
        uint[] memory askedTokenIds, 
        uint deadline
    ) external returns (uint tradeId) {
        require(AddressUpgradeable.isContract(proposedAsset), "NimbusP2P_V2: Not contracts");
        require(proposedAmount > 0, "NimbusP2P_V2: Zero amount not allowed");
        require(askedAssets.length > 0,"NimbusP2P_V2: askedAssets empty");
        require(askedAssets.length == askedTokenIds.length, "NimbusP2P_V2: Wrong lengths");
        _requireAllowedEIP20(proposedAsset);
        for (uint256 i; i < askedAssets.length; i++) {
            require(AddressUpgradeable.isContract(askedAssets[i]));
            _requireAllowedNFT(askedAssets[i]);
        }
        
        TransferHelper.safeTransferFrom(proposedAsset, msg.sender, address(this), proposedAmount);

        address[] memory proposedAssets = new address[](1);
        proposedAssets[0] = proposedAsset;
        uint[] memory proposedIds = new uint[](0);
        tradeId = _createTradeMulti(proposedAssets, proposedAmount, proposedIds, askedAssets, 0, askedTokenIds, deadline, true);   
    }

    // for trade NFTs -> Native Coin use createTradeNFTstoEIP20 and pass WBNB address as asked asset
    function createTradeNFTsToEIP20(
        address[] memory proposedAssets, 
        uint[] memory proposedTokenIds, 
        address askedAsset, 
        uint askedAmount, 
        uint deadline
    ) external returns (uint tradeId) {
        require(AddressUpgradeable.isContract(askedAsset), "NimbusP2P_V2: Not contracts");
        require(proposedAssets.length == proposedTokenIds.length, "NimbusP2P_V2: Wrong lengths");
        require(proposedAssets.length > 0, "NimbusP2P_V2: proposedAssets empty");
        _requireAllowedEIP20(askedAsset);
        for (uint i; i < proposedAssets.length; i++) {
          require(AddressUpgradeable.isContract(proposedAssets[i]), "NimbusP2P_V2: Not contracts");
          _requireAllowedNFT(proposedAssets[i]);
          IEIP721(proposedAssets[i]).safeTransferFrom(msg.sender, address(this), proposedTokenIds[i]);
        }
        address[] memory askedAssets = new address[](1);
        askedAssets[0] = askedAsset;
        uint[] memory askedIds = new uint[](0);
        tradeId = _createTradeMulti(proposedAssets, 0, proposedTokenIds, askedAssets, askedAmount, askedIds, deadline, false);   
    }

    function createTradeBNBtoNFTs(address[] memory askedAssets, uint[] memory askedTokenIds, uint deadline) 
        payable external returns (uint tradeId) 
    {
        require(askedAssets.length == askedTokenIds.length, "NimbusP2P_V2: Wrong lengths");
        require(msg.value > 0, "NimbusP2P_V2: Zero amount not allowed");
        require(askedAssets.length > 0,"NimbusP2P_V2: askedAssets empty!");
        for (uint i; i < askedAssets.length; i++) {
          require(AddressUpgradeable.isContract(askedAssets[i]), "NimbusP2P_V2: Not contracts");
            _requireAllowedNFT(askedAssets[i]);
        }
        require(msg.value > 0);
        WBNB.deposit{value: msg.value}();
        address[] memory proposedAssets = new address[](1);
        proposedAssets[0] = address(WBNB);
        uint[] memory proposedIds = new uint[](0);
        tradeId = _createTradeMulti(proposedAssets, msg.value, proposedIds, askedAssets, 0, askedTokenIds, deadline, true);   
    }

    function createTradeNFTsToNFTs(
        address[] memory proposedAssets, 
        uint[] memory proposedTokenIds, 
        address[] memory askedAssets, 
        uint[] memory askedTokenIds, 
        uint deadline
    ) external returns (uint tradeId) {
        require(askedAssets.length > 0,"NimbusP2P_V2: askedAssets empty!");
        require(proposedAssets.length > 0,"NimbusP2P_V2: proposwdAssets empty!");
        require(proposedAssets.length == proposedTokenIds.length, "NimbusP2P_V2: AskedAssets wrong lengths");
        require(askedAssets.length == askedTokenIds.length, "NimbusP2P_V2: AskedAssets wrong lengths");
        for (uint i; i < askedAssets.length; i++) {
          require(AddressUpgradeable.isContract(askedAssets[i]), "NimbusP2P_V2: Not contracts");
        }

        for (uint i; i < proposedAssets.length; i++) {
          require(AddressUpgradeable.isContract(proposedAssets[i]), "NimbusP2P_V2: Not contracts");
          IEIP721(proposedAssets[i]).safeTransferFrom(msg.sender, address(this), proposedTokenIds[i]);
        }        
        tradeId = _createTradeMulti(proposedAssets, 0, proposedTokenIds, askedAssets, 0, askedTokenIds, deadline, true);   
    }



    function createTradeEIP20ToEIP20Permit(
        address proposedAsset, 
        uint proposedAmount, 
        address askedAsset, 
        uint askedAmount, 
        uint deadline, 
        uint permitDeadline, 
        uint8 v, 
        bytes32 r, 
        bytes32 s
    ) external returns (uint tradeId) {
        require(AddressUpgradeable.isContract(proposedAsset) && AddressUpgradeable.isContract(askedAsset), "NimbusP2P_V2: Not contracts");
        require(proposedAmount > 0, "NimbusP2P_V2: Zero amount not allowed");
        _requireAllowedEIP20(askedAsset);
        _requireAllowedEIP20(proposedAsset);
        IEIP20Permit(proposedAsset).permit(msg.sender, address(this), proposedAmount, permitDeadline, v, r, s);
        TransferHelper.safeTransferFrom(proposedAsset, msg.sender, address(this), proposedAmount);
        tradeId = _createTradeSingle(proposedAsset, proposedAmount, 0, askedAsset, askedAmount, 0, deadline, false);   
    }

    function createTradeEIP20ToNFTPermit(
        address proposedAsset, 
        uint proposedAmount, 
        address askedAsset, 
        uint tokenId, 
        uint deadline, 
        uint permitDeadline, 
        uint8 v, 
        bytes32 r, 
        bytes32 s
    ) external returns (uint tradeId) {
        require(AddressUpgradeable.isContract(proposedAsset), "NimbusP2P_V2: Not contracts");
        require(proposedAmount > 0, "NimbusP2P_V2: Zero amount not allowed");
        _requireAllowedEIP20(proposedAsset);
        IEIP20Permit(proposedAsset).permit(msg.sender, address(this), proposedAmount, permitDeadline, v, r, s);
        TransferHelper.safeTransferFrom(proposedAsset, msg.sender, address(this), proposedAmount);
        tradeId = _createTradeSingle(proposedAsset, proposedAmount, 0, askedAsset, 0, tokenId, deadline, true);   
    }

    function createTradeEIP20ToNFTsPermit(
        address proposedAsset, 
        uint proposedAmount, 
        address[] memory askedAssets, 
        uint[] memory askedTokenIds, 
        uint deadline, 
        uint permitDeadline, 
        uint8 v, 
        bytes32 r, 
        bytes32 s
    ) external returns (uint tradeId) {
        require(AddressUpgradeable.isContract(proposedAsset), "NimbusP2P_V2: Not contracts");
        require(proposedAmount > 0, "NimbusP2P_V2: Zero amount not allowed");
        require(askedAssets.length == askedTokenIds.length, "NimbusP2P_V2: Wrong lengths");
        _requireAllowedEIP20(proposedAsset);
        IEIP20Permit(proposedAsset).permit(msg.sender, address(this), proposedAmount, permitDeadline, v, r, s);
        TransferHelper.safeTransferFrom(proposedAsset, msg.sender, address(this), proposedAmount);

        address[] memory proposedAssets = new address[](1);
        proposedAssets[0] = proposedAsset;
        uint[] memory proposedIds = new uint[](0);
        tradeId = _createTradeMulti(proposedAssets, proposedAmount, proposedIds, askedAssets, 0, askedTokenIds, deadline, true);   
    }



    function supportTradeSingle(uint tradeId) external lock whenNotPaused {
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

    function supportTradeSingleBNB(uint tradeId) payable external lock whenNotPaused {
        require(tradeCount >= tradeId && tradeId > 0, "NimbusP2P_V2: Invalid trade id");
        TradeSingle storage trade = tradesSingle[tradeId];
        require(trade.status == 0 && trade.deadline > block.timestamp, "NimbusP2P_V2: Not active trade");
        require(msg.value >= trade.askedAmount, "NimbusP2P_V2: Not enough BNB sent");
        require(trade.askedAsset == address(WBNB), "NimbusP2P_V2: BEP20 trade");

        TransferHelper.safeTransferBNB(trade.initiator, trade.askedAmount);
        if (msg.value > trade.askedAmount) TransferHelper.safeTransferBNB(msg.sender, msg.value - trade.askedAmount);
        _supportTradeSingle(tradeId);
    }
    
    function supportTradeSingleWithPermit(uint tradeId, uint permitDeadline, uint8 v, bytes32 r, bytes32 s) external lock whenNotPaused {
        require(tradeCount >= tradeId && tradeId > 0, "NimbusBEP20P2P_V1: Invalid trade id");
        TradeSingle storage trade = tradesSingle[tradeId];
        require(!trade.isAskedAssetNFT, "NimbusBEP20P2P_V1: Permit only allowed for EIP20 tokens");
        require(trade.status == 0 && trade.deadline > block.timestamp, "NimbusBEP20P2P_V1: Not active trade");

        IEIP20Permit(trade.askedAsset).permit(msg.sender, address(this), trade.askedAmount, permitDeadline, v, r, s);
        TransferHelper.safeTransferFrom(trade.askedAsset, msg.sender, trade.initiator, trade.askedAmount);
        _supportTradeSingle(tradeId);
    }

    function supportTradeMulti(uint tradeId) external lock whenNotPaused {
        require(tradeCount >= tradeId && tradeId > 0, "NimbusP2P_V2: Invalid trade id");
        TradeMulti storage tradeMulti = tradesMulti[tradeId];
        require(tradeMulti.status == 0 && tradeMulti.deadline > block.timestamp, "NimbusP2P_V2: Not active trade");
        if (tradeMulti.isAskedAssetNFTs) {
            for (uint i; i < tradeMulti.askedAssets.length; i++) {
                IEIP721(tradeMulti.askedAssets[i]).safeTransferFrom(msg.sender, tradeMulti.initiator, tradeMulti.askedTokenIds[i]);
            }
        } else {
            TransferHelper.safeTransferFrom(tradeMulti.askedAssets[0], msg.sender, tradeMulti.initiator, tradeMulti.askedAmount);
        }

        _supportTradeMulti(tradeId);
    }   



    function cancelTrade(uint tradeId) external lock whenNotPaused { 
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

    function cancelTradeMulti(uint tradeId) external lock whenNotPaused { 
        require(tradeCount >= tradeId && tradeId > 0, "NimbusP2P_V2: Invalid trade id");
        TradeMulti storage tradeMulti = tradesMulti[tradeId];
        require(tradeMulti.initiator == msg.sender, "NimbusP2P_V2: Not allowed");
        require(tradeMulti.status == 0 && tradeMulti.deadline > block.timestamp, "NimbusP2P_V2: Not active trade");

        if (tradeMulti.proposedAmount == 0) {
            for (uint i; i < tradeMulti.proposedAssets.length; i++) {           
                IEIP721(tradeMulti.proposedAssets[i]).transferFrom(address(this), msg.sender, tradeMulti.proposedTokenIds[i]);
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



    function withdrawOverdueAssetSingle(uint tradeId) external lock whenNotPaused { 
        require(tradeCount >= tradeId && tradeId > 0, "NimbusP2P_V2: Invalid trade id");
        TradeSingle storage trade = tradesSingle[tradeId];
        require(trade.initiator == msg.sender, "NimbusP2P_V2: Not allowed");
        require(trade.status == 0 && trade.deadline < block.timestamp, "NimbusP2P_V2: Not available for withdrawal");

        if (trade.proposedAmount == 0) {
            IEIP721(trade.proposedAsset).transferFrom(address(this), msg.sender, trade.proposedTokenId);
        } else if (trade.proposedAsset != address(WBNB)) {
            TransferHelper.safeTransfer(trade.proposedAsset, msg.sender, trade.proposedAmount);
        } else {
            WBNB.withdraw(trade.proposedAmount);
            TransferHelper.safeTransferBNB(msg.sender, trade.proposedAmount);
        }

        trade.status = 3;
        emit WithdrawOverdueAsset(tradeId);
    }

    function withdrawOverdueAssetsMulti(uint tradeId) external lock whenNotPaused { 
        require(tradeCount >= tradeId && tradeId > 0, "NimbusP2P_V2: Invalid trade id");
        TradeMulti storage tradeMulti = tradesMulti[tradeId];
        require(tradeMulti.initiator == msg.sender, "NimbusP2P_V2: Not allowed");
        require(tradeMulti.status == 0 && tradeMulti.deadline < block.timestamp, "NimbusP2P_V2: Not available for withdrawal");
        
        if (tradeMulti.proposedAmount == 0) {
            for (uint i; i < tradeMulti.proposedAssets.length; i++) {           
                IEIP721(tradeMulti.proposedAssets[i]).transferFrom(address(this), msg.sender, tradeMulti.proposedTokenIds[i]);
            } 
        } else if (tradeMulti.proposedAssets[0] != address(WBNB)) {
            TransferHelper.safeTransfer(tradeMulti.proposedAssets[0], msg.sender, tradeMulti.proposedAmount);
        } else {
            WBNB.withdraw(tradeMulti.proposedAmount);
            TransferHelper.safeTransferBNB(msg.sender, tradeMulti.proposedAmount);
        }

        tradeMulti.status = 3;
        emit WithdrawOverdueAsset(tradeId);
    }
    


    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) external pure override returns (bytes4) {
        return 0x150b7a02;
    }

    function getTradeMulti(uint id) external view returns(TradeMulti memory) {
        return tradesMulti[id];
    }

    function state(uint tradeId) public view returns (TradeState) { //TODO
        require(tradeCount >= tradeId && tradeId > 0, "NimbusP2P_V2: Invalid trade id");
        TradeSingle storage trade = tradesSingle[tradeId];
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

    function stateMulti(uint tradeId) public view returns (TradeState) { //TODO
        require(tradeCount >= tradeId && tradeId > 0, "NimbusP2P_V2: Invalid trade id");
        TradeMulti storage tradeMulti = tradesMulti[tradeId];
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

    function userTrades(address user) public view returns (uint[] memory) {
        return _userTrades[user];
    }

    function _requireAllowedNFT(address nftContract) private view {
        require(isAnyNFTAllowed || allowedNFT[nftContract], "NimbusP2P_V2: Not allowed NFT");
    }

    function _requireAllowedEIP20(address tokenContract) private view {
        require(isAnyEIP20Allowed || allowedEIP20[tokenContract], "NimbusP2P_V2: Not allowed EIP20 Token");
    }

    function _createTradeSingle(
        address proposedAsset, 
        uint proposedAmount, 
        uint proposedTokenId, 
        address askedAsset, 
        uint askedAmount, 
        uint askedTokenId, 
        uint deadline, 
        bool isNFTAskedAsset
    ) private returns (uint tradeId) { 
        require(askedAsset != proposedAsset, "NimbusP2P_V2: Asked asset can't be equal to proposed asset");
        require(deadline > block.timestamp, "NimbusP2P_V2: Incorrect deadline");
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
        
        _userTrades[msg.sender].push(tradeId);        
        emit NewTradeSingle(msg.sender, proposedAsset, proposedAmount, proposedTokenId, askedAsset, askedAmount, askedTokenId, deadline, tradeId);
    }

    function _createTradeMulti(
        address[] memory proposedAssets, 
        uint proposedAmount, 
        uint[] memory proposedTokenIds, 
        address[] memory askedAssets, 
        uint askedAmount, 
        uint[] memory askedTokenIds, 
        uint deadline, 
        bool isNFTsAskedAsset
        //uint tradeType
    ) private returns (uint tradeId) { 
        require(deadline > block.timestamp, "NimbusP2P_V2: Incorrect deadline");
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
        
        _userTrades[msg.sender].push(tradeId);       
        emit NewTradeMulti(msg.sender, proposedAssets, proposedAmount, proposedTokenIds, askedAssets, askedAmount, askedTokenIds, deadline, tradeId);
    }

    function _supportTradeSingle(uint tradeId) private { 
        TradeSingle memory trade = tradesSingle[tradeId];
        
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
        emit SupportTrade(tradeId, msg.sender);
    }

    function _supportTradeMulti(uint tradeId) private { 
        TradeMulti memory tradeMulti = tradesMulti[tradeId];

        if (tradeMulti.proposedAmount == 0) {
            for (uint i; i < tradeMulti.proposedAssets.length; i++) {           
                IEIP721(tradeMulti.proposedAssets[i]).transferFrom(address(this), msg.sender, tradeMulti.proposedTokenIds[i]);
            }
        } else if (tradeMulti.proposedAssets[0] != address(WBNB)) {
            TransferHelper.safeTransfer(tradeMulti.proposedAssets[0], msg.sender, tradeMulti.proposedAmount);
        } else {
            WBNB.withdraw(tradeMulti.proposedAmount);
            TransferHelper.safeTransferBNB(msg.sender, tradeMulti.proposedAmount);
        }

        tradesMulti[tradeId].counterparty = msg.sender;
        tradesMulti[tradeId].status = 1;
        emit SupportTrade(tradeId, msg.sender);
    }


    function toggleAnyNFTAllowed() external onlyOwner {
        isAnyNFTAllowed = !isAnyNFTAllowed;
        emit UpdateIsAnyNFTAllowed(isAnyNFTAllowed);
    }

    function updateAllowedNFT(address nft, bool isAllowed) external onlyOwner {
        require(AddressUpgradeable.isContract(nft), "NimbusP2P_V2: Not a contract");
        allowedNFT[nft] = isAllowed;
        emit UpdateAllowedNFT(nft, isAllowed);
    }

    function toggleAnyEIP20Allowed() external onlyOwner {
        isAnyEIP20Allowed = !isAnyEIP20Allowed;
        emit UpdateIsAnyEIP20Allowed(isAnyEIP20Allowed);
    }

    function updateAllowedEIP20Tokens(address token, bool isAllowed) external onlyOwner {
        require(AddressUpgradeable.isContract(token), "NimbusP2P_V2: Not a contract");
        allowedEIP20[token] = isAllowed;
        emit UpdateAllowedEIP20Tokens(token, isAllowed);
    }

    function rescue(address to, address tokenAddress, uint256 amount) external onlyOwner whenPaused {
        require(to != address(0), "NimbusP2P_V2: Cannot rescue to the zero address");
        require(amount > 0, "NimbusP2P_V2: Cannot rescue 0");

        TransferHelper.safeTransfer(tokenAddress, to, amount);
        emit RescueToken(to, address(tokenAddress), amount);
    }

    function rescueEIP721(address to, address tokenAddress, uint256 tokenId) external onlyOwner whenPaused {
        require(to != address(0), "NimbusP2P_V2: Cannot rescue to the zero address");

        IEIP721(tokenAddress).safeTransferFrom(address(this), to, tokenId);
        emit RescueToken(to, address(tokenAddress), tokenId);
    }

    function rescue(address payable to, uint256 amount) external onlyOwner whenPaused {
        require(to != address(0), "NimbusP2P_V2: Cannot rescue to the zero address");
        require(amount > 0, "NimbusP2P_V2: Cannot rescue 0");

        to.transfer(amount);
        emit Rescue(to, amount);
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