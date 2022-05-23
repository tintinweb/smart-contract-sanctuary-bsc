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

contract NimbusP2P_V2Proxy is NimbusP2P_V2Storage {
    address public target;
    
    event SetTarget(address indexed newTarget);

    constructor(address _newTarget) NimbusP2P_V2Storage() {
        _setTarget(_newTarget);
    }

    fallback() external payable {
        if (gasleft() <= 2300) {
            return;
        }

        address target_ = target;
        bytes memory data = msg.data;
        assembly {
            let result := delegatecall(gas(), target_, add(data, 0x20), mload(data), 0, 0)
            let size := returndatasize()
            let ptr := mload(0x40)
            returndatacopy(ptr, 0, size)
            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }

    function setTarget(address _newTarget) external onlyOwner {
        _setTarget(_newTarget);
    }

    function _setTarget(address _newTarget) internal {
        require(Address.isContract(_newTarget), "Target not a contract");
        target = _newTarget;
        emit SetTarget(_newTarget);
    }
}