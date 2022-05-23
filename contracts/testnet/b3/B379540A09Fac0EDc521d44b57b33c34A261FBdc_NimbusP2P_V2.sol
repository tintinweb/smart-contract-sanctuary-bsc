/**
 *Submitted for verification at BscScan.com on 2022-05-23
*/

pragma solidity ^0.8.0;

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

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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

contract Ownable {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed from, address indexed to);

    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), owner);
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Ownable: Caller is not the owner");
        _;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function transferOwnership(address transferOwner) external onlyOwner {
        require(transferOwner != newOwner);
        newOwner = transferOwner;
    }

    function acceptOwnership() virtual external {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable {
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
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
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
        require(paused(), "Pausable: not paused");
        _;
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
        emit Paused(msg.sender);
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
        emit Unpaused(msg.sender);
    }
}

contract NimbusP2P_V2Storage is Ownable, Pausable {    
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

    uint internal unlocked = 1;

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
    address public target;

    function initialize(
        address[] memory _allowedEIP20Tokens
    ) external onlyOwner {
        for (uint256 i; i < _allowedEIP20Tokens.length; i++) {
            require(Address.isContract(_allowedEIP20Tokens[i]));
            allowedEIP20[_allowedEIP20Tokens[i]] = true;
            emit UpdateAllowedEIP20Tokens(_allowedEIP20Tokens[i], true);
        }
        isAnyNFTAllowed = true;
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
        require(Address.isContract(proposedAsset) && Address.isContract(askedAsset), "NimbusP2P_V2: Not contracts");
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
        require(Address.isContract(askedAsset), "NimbusP2P_V2: Not contract");
        require(msg.value > 0, "NimbusP2P_V2: Zero amount not allowed");
        _requireAllowedEIP20(askedAsset);
        WBNB.deposit{value: msg.value}();
        tradeId = _createTradeSingle(address(WBNB), msg.value, 0, askedAsset, askedAmount, 0, deadline, false);   
    }



    function createTradeEIP20ToNFT(address proposedAsset, uint proposedAmount, address askedAsset, uint tokenId, uint deadline) external returns (uint tradeId) {
        require(Address.isContract(proposedAsset), "NimbusP2P_V2: Not contracts");
        require(proposedAmount > 0, "NimbusP2P_V2: Zero amount not allowed");
        _requireAllowedEIP20(proposedAsset);
        _requireAllowedNFT(askedAsset);
        TransferHelper.safeTransferFrom(proposedAsset, msg.sender, address(this), proposedAmount);
        tradeId = _createTradeSingle(proposedAsset, proposedAmount, 0, askedAsset, 0, tokenId, deadline, true);   
    }

    // for trade NFT -> Native Coin use createTradeNFTtoEIP20 and pass WBNB address as asked asset
    function createTradeNFTtoEIP20(address proposedAsset, uint tokenId, address askedAsset, uint askedAmount, uint deadline) external returns (uint tradeId) {
        require(Address.isContract(proposedAsset), "NimbusP2P_V2: Not contracts");
        _requireAllowedNFT(proposedAsset);
        _requireAllowedEIP20(askedAsset);
        IEIP721(proposedAsset).safeTransferFrom(msg.sender, address(this), tokenId);
        tradeId = _createTradeSingle(proposedAsset, 0, tokenId, askedAsset, askedAmount, 0, deadline, false);   
    }

    function createTradeBNBtoNFT(address askedAsset, uint tokenId, uint deadline) payable external returns (uint tradeId) {
        require(Address.isContract(askedAsset), "NimbusP2P_V2: Not contract");
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
        require(Address.isContract(proposedAsset), "NimbusP2P_V2: Not contracts");
        require(proposedAmount > 0, "NimbusP2P_V2: Zero amount not allowed");
        require(askedAssets.length > 0,"NimbusP2P_V2: askedAssets empty");
        require(askedAssets.length == askedTokenIds.length, "NimbusP2P_V2: Wrong lengths");
        _requireAllowedEIP20(proposedAsset);
        for (uint256 i; i < askedAssets.length; i++) {
            require(Address.isContract(askedAssets[i]));
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
        require(Address.isContract(askedAsset), "NimbusP2P_V2: Not contracts");
        require(proposedAssets.length == proposedTokenIds.length, "NimbusP2P_V2: Wrong lengths");
        require(proposedAssets.length > 0, "NimbusP2P_V2: proposedAssets empty");
        _requireAllowedEIP20(askedAsset);
        for (uint i; i < proposedAssets.length; i++) {
          require(Address.isContract(proposedAssets[i]), "NimbusP2P_V2: Not contracts");
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
          require(Address.isContract(askedAssets[i]), "NimbusP2P_V2: Not contracts");
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
          require(Address.isContract(askedAssets[i]), "NimbusP2P_V2: Not contracts");
        }

        for (uint i; i < proposedAssets.length; i++) {
          require(Address.isContract(proposedAssets[i]), "NimbusP2P_V2: Not contracts");
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
        require(Address.isContract(proposedAsset) && Address.isContract(askedAsset), "NimbusP2P_V2: Not contracts");
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
        require(Address.isContract(proposedAsset), "NimbusP2P_V2: Not contracts");
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
        require(Address.isContract(proposedAsset), "NimbusP2P_V2: Not contracts");
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
        require(Address.isContract(nft), "NimbusP2P_V2: Not a contract");
        allowedNFT[nft] = isAllowed;
        emit UpdateAllowedNFT(nft, isAllowed);
    }

    function toggleAnyEIP20Allowed() external onlyOwner {
        isAnyEIP20Allowed = !isAnyEIP20Allowed;
        emit UpdateIsAnyEIP20Allowed(isAnyEIP20Allowed);
    }

    function updateAllowedEIP20Tokens(address token, bool isAllowed) external onlyOwner {
        require(Address.isContract(token), "NimbusP2P_V2: Not a contract");
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