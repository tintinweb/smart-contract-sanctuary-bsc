// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "./interfaces/ILBlockLottery.sol";
import "./LBlockAdmin.sol";
import "./LBlockPrice.sol";
import "./LBlockMerkleTreeV3.sol";
import "./VRFv2/interfaces/IVRFv2Consumer.sol";
import "./interfaces/INFTDraw.sol";

contract LBlockLotteryV3 is
    ILBlockLotteryV3,
    LBlockAdmin,
    IVRFClient,
    Initializable
{
    string public constant VERSION = "3.0.0";

    uint256 public ticketsAmount;
    uint256 public randomness;
    address public lotteryWinner;

    address holderReward;
    address NFTDraw;
    address VRFWrapper;
    address marketing;
    address merkleTreeVerifier;
    LBlockPrice lblockPrice;
    mapping(address => uint256[]) holderBlocks;
    mapping(address => bool) freeTicketClaimed;
    bool public isRandomnessSet;
    bool public isLotteryFinished;

    TicketBlock[] ticketBlocks;

    function initialize(
        address _lotteryToken,
        address _admin,
        address _holderReward,
        address _NFTDraw,
        address _merkleTreeVerifier,
        address _VRFWrapper,
        address _marketing,
        address _taxWallet,
        address _lblockPrice
    ) public ownerOrAdmin initializer {
        holderReward = _holderReward;
        NFTDraw = _NFTDraw;
        merkleTreeVerifier = _merkleTreeVerifier;
        VRFWrapper = _VRFWrapper;
        marketing = _marketing;
        lblockPrice = LBlockPrice(_lblockPrice);
        isRandomnessSet = false;
        initializeAdmin(_lotteryToken, _admin, _taxWallet);
    }

    function _registerBlock(uint256 amount, TicketType _type)
        internal
        whenSalesOn
    {
        require(amount > 0, "You should purchase at least 1 ticket");
        uint256 newTicketId = ticketBlocks.length;
        holderBlocks[msg.sender].push(newTicketId);
        ticketBlocks.push(
            TicketBlock(
                ticketsAmount + 1,
                ticketsAmount + amount,
                msg.sender,
                _type
            )
        );
        ticketsAmount += amount;
        emit TicketBlockCreated(
            msg.sender,
            ticketBlocks[newTicketId],
            block.timestamp,
            _type
        );
    }

    function buyTicket(uint256 _amount) external whenSalesOn {
        (
            bool paid,
            bool transferredToNFTDraw,
            bool transferredToHolderReward
        ) = _takePayment(
                _amount *
                    lotteryParams.ticketPrice *
                    lblockPrice.getLBlockPrice() *
                    10**9
            );
        _registerBlock(_amount, TicketType.purchased);
        require(
            paid && transferredToNFTDraw && transferredToHolderReward,
            "Payment troubles"
        );
    }

    function claimFreeTicket(bytes32[] calldata proof) external whenSalesOn {
        require(
            LBlockMerkleTreeV3(merkleTreeVerifier).verify(msg.sender, proof),
            "Your proof was declined"
        );
        require(!freeTicketClaimed[msg.sender], "Free ticket already claimed");
        freeTicketClaimed[msg.sender] = true;
        _registerBlock(1, TicketType.free);
    }

    function postalEntry(uint256 _amount) external whenSalesOn ownerOrAdmin {
        _registerBlock(_amount, TicketType.postal);
    }

    function getUserBlocks(address _user)
        public
        view
        returns (uint256[] memory)
    {
        return holderBlocks[_user];
    }

    function getBlocks(uint256 _blockId)
        public
        view
        returns (TicketBlock memory)
    {
        return ticketBlocks[_blockId];
    }

    function getWinningTicket() public view returns (uint256) {
        require(ticketsAmount > 0, "No tickets were bought");
        require(isRandomnessSet, "Randomness is not set");
        return (randomness % ticketsAmount) + 1;
    }

    function _searchWinner() internal {
        uint256 winningTicket = getWinningTicket();
        uint256 step = ticketBlocks.length / 2;
        if (step == 0) {
            step = 1;
        }
        uint256 searchPointer = ticketBlocks.length - step;
        TicketBlock memory pointedBlock = ticketBlocks[searchPointer];
        while (
            pointedBlock.startTicket > winningTicket ||
            pointedBlock.endTicket < winningTicket
        ) {
            step = step / 2;
            if (step == 0) {
                step = 1;
            }
            if (pointedBlock.startTicket > winningTicket) {
                searchPointer -= step;
            } else {
                searchPointer += step;
            }
            pointedBlock = ticketBlocks[searchPointer];
        }
        lotteryWinner = pointedBlock.ticketHolder;
    }

    function _takePayment(uint256 _amount)
        internal
        returns (
            bool,
            bool,
            bool
        )
    {
        bool paid = applicationState.lotteryToken.transferFrom(
            msg.sender,
            address(this),
            _amount
        );
        uint256 toNFTDraw = (_amount *
            lotteryPercentages.nftJackpotPercentage) / 100;
        uint256 toHolderReward = (_amount *
            lotteryPercentages.tokenHoldersPercentage) / 100;
        bool transferredToNFTDraw = applicationState.lotteryToken.transfer(
            NFTDraw,
            toNFTDraw
        );
        bool transferredToHolderReward = applicationState.lotteryToken.transfer(
            holderReward,
            toHolderReward
        );
        return (paid, transferredToNFTDraw, transferredToHolderReward);
    }

    // @title The official step to start lottery
    function startLottery() public ownerOrAdmin whenSalesOff isLotterySet {
        lotteryState = LotteryState.saleOn;
    }

    // @title The official step to finish lottery, stop sales of tickets. and request Random number
    function finishLottery() public ownerOrAdmin charityIsSet {
        IVRFv2Consumer(VRFWrapper).requestRandomWords();
        lotteryState = LotteryState.saleOff;
    }

    // @title The internal function to ensure that Random number is set
    // @dev If Random is set (got RandomnessFullfilled event), call announceWinner() directly
    function fulfillRandomWords(uint256 _randomWord) external {
        require(
            msg.sender == VRFWrapper,
            "You are not allowed to run this function"
        );
        randomness = _randomWord;
        isRandomnessSet = true;
        emit RandomnessFullfilled(randomness);
    }

    // @title The function to announce winners, call rewards allocation and other final step to finish current lottery
    function announceWinner() external ownerOrAdmin whenSalesOff {
        require(isRandomnessSet, "Randomness is not set");
        _closeLottery();
        INFTDraw(NFTDraw).pickWinner(randomness);
        isLotteryFinished = true;
    }

    function _closeLottery() internal {
        if (ticketsAmount > 0) {
            _searchWinner();
        }
        _sendTokens();
        _sendRemainingFunds(applicationState.taxWallet);
    }

    function _sendTokens() internal {
        uint256 lotteryBalance = applicationState.lotteryToken.balanceOf(
            address(this)
        );
        uint8 remainingPercents = 100 -
            lotteryPercentages.tokenHoldersPercentage -
            lotteryPercentages.nftJackpotPercentage;
        if (lotteryWinner != address(0)) {
            uint256 jackpotAmount = (lotteryBalance *
                lotteryPercentages.jackpotPercentage) / remainingPercents;
            applicationState.lotteryToken.transfer(
                lotteryWinner,
                jackpotAmount
            );
            emit JackpotTransferred(
                getWinningTicket(),
                lotteryWinner,
                jackpotAmount,
                lblockPrice.getLBlockPrice()
            );
        }
        uint256 charityAmount = (lotteryBalance *
            lotteryPercentages.charityPercentage) / remainingPercents;
        uint256 marketingAmount = (lotteryBalance *
            lotteryPercentages.marketingWalletPercentage) / remainingPercents;
        applicationState.lotteryToken.transfer(
            applicationState.charityAddress,
            charityAmount
        );
        applicationState.lotteryToken.transfer(marketing, marketingAmount);
    }

    function _sendRemainingFunds(address _to) internal {
        uint256 currentBalance = applicationState.lotteryToken.balanceOf(
            address(this)
        );
        if (currentBalance > 0)
            applicationState.lotteryToken.transfer(_to, currentBalance);
    }

    function claimRemainingFunds(address _to)
        external
        override
        ownerOrAdmin
        whenSalesOff
    {
        require(isRandomnessSet, "Randomness is not set");
        require(isLotteryFinished, "Lottery is not finished");
        _sendRemainingFunds(_to);
    }
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
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/Address.sol";

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
        bool isTopLevelCall = _setInitializedVersion(1);
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
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
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
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !Address.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

/// @title The interface to describe Lottery functions
interface ILBlockLotteryV3 {
    /// @notice Available ticket types
    enum TicketType {
        purchased,
        free,
        postal
    }

    /// @notice Block of any amount of tickets
    struct TicketBlock {
        uint256 startTicket;
        uint256 endTicket;
        address ticketHolder;
        TicketType ticketsType;
    }

    /// @dev Emitted when a ticket block is created.
    event TicketBlockCreated(
        address indexed buyer,
        TicketBlock block,
        uint256 timestamp,
        TicketType ticketType
    );

    /// @dev Emitted when the jackpot is transferred to winner.
    event JackpotTransferred(
        uint256 winningTicket,
        address jackpotWinner,
        uint256 jackpotAmountInLuckyBlock,
        uint256 USDToLuckyBlock
    );

    /// @dev Emitted after setting randomness.
    event RandomnessFullfilled(uint256 randomNumber);

    /// @notice The function take money from sender and register appropriate ticket block
    /// @param _amount - amount of tickets to buy
    function buyTicket(uint256 _amount) external;

    /// @notice The function checks proof and gives free ticket if proof is correct
    /// @param _proof - merkle tree proof
    function claimFreeTicket(bytes32[] calldata _proof) external;

    /// @notice The function for registering ticket block for postal card
    /// @param _amount - amount of tickets to register
    function postalEntry(uint256 _amount) external;

    /// @notice The function returns indexes of ticket blocks belonging to user
    /// @param _user - the address of the user whose ticket block indexes need to be returned
    /// @return uint256[] - array that contains indexes of ticket blocks, that belongs to passed user
    function getUserBlocks(address _user)
        external
        view
        returns (uint256[] memory);

    /// @notice The function returns ticket block with passed id
    /// @param _blockId - the of ticket block that needs to be returned
    /// @return TicketBlock - ticket block with passed id
    function getBlocks(uint256 _blockId)
        external
        view
        returns (TicketBlock memory);

    // @notice The function for getting won ticket
    /// @return uint256 - number of won ticket
    function getWinningTicket() external view returns (uint256);

    // @notice The function to announce winners, call rewards allocation and other final step to finish current lottery
    function announceWinner() external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import "./interfaces/ILBlockAdmin.sol";

abstract contract LBlockAdmin is ILBlockAdmin {
    address private immutable _owner;
    LotteryState public lotteryState;
    LotteryParams public lotteryParams;
    LotteryPercentages internal lotteryPercentages;
    ApplicationState internal applicationState;

    constructor() {
        _owner = msg.sender;
    }

    function initializeAdmin(
        address _lotteryToken,
        address _admin,
        address _taxWallet
    ) internal {
        applicationState.admin = _admin;
        applicationState.taxWallet = _taxWallet;
        lotteryPercentages = LotteryPercentages(70, 10, 2, 8, 10);
        lotteryParams.startBlock = block.number;

        setLotteryToken(_lotteryToken);
        applicationState.decimals = applicationState.lotteryToken.decimals();
    }

    modifier ownerOrAdmin() {
        require(
            _owner == msg.sender || msg.sender == applicationState.admin,
            "Caller is not the owner or admin"
        );
        _;
    }

    modifier whenSalesOn() {
        require(lotteryState == LotteryState.saleOn, "Ticket sales is Off");
        _;
    }

    modifier whenSalesOff() {
        require(lotteryState == LotteryState.saleOff, "Ticket sales is On");
        _;
    }

    modifier isLotterySet() {
        require(
            lotteryParams.ticketPrice != 0 &&
                lotteryParams.endDateTime != 0 &&
                lotteryParams.startDateTime != 0 &&
                lotteryParams.endDateTime > lotteryParams.startDateTime,
            "Lottery parameters are not set"
        );
        _;
    }

    modifier charityIsSet() {
        require(
            applicationState.charityAddress != address(0x0),
            "Charity is not set"
        );
        _;
    }

    function setLotteryToken(address _tokenAddress) public ownerOrAdmin {
        applicationState.lotteryToken = ERC20(_tokenAddress);
    }

    function setupLottery(
        uint256 _startDateTime,
        uint256 _endDateTime,
        uint256 _ticketPrice
    ) public ownerOrAdmin {
        lotteryParams = LotteryParams(
            _startDateTime,
            _endDateTime,
            lotteryParams.startBlock,
            _ticketPrice
        );
    }

    function fundLottery(uint256 _busdAmount) public ownerOrAdmin {}

    function setRewardsAllocation(
        uint8 _jackpotPercentage,
        uint8 _charityPercentage,
        uint8 _nftJackpotPercentage,
        uint8 _marketingWalletPercentage,
        uint8 _tokenHoldersPercentage
    ) public ownerOrAdmin {
        uint256 totalPercentage = _jackpotPercentage +
            _charityPercentage +
            _nftJackpotPercentage +
            _marketingWalletPercentage +
            _tokenHoldersPercentage;

        require(totalPercentage == 100, "The sum of % is not equal to 100");

        lotteryPercentages = LotteryPercentages(
            _jackpotPercentage,
            _charityPercentage,
            _nftJackpotPercentage,
            _marketingWalletPercentage,
            _tokenHoldersPercentage
        );
    }

    function setTicketPrice(uint256 _ticketPrice)
        public
        ownerOrAdmin
        whenSalesOff
    {
        lotteryParams.ticketPrice = _ticketPrice;
    }

    function setLotteryState(uint256 _lotteryState) public ownerOrAdmin {
        lotteryState = LotteryState(_lotteryState);
    }

    function setCharity(address _charityAddress) public ownerOrAdmin {
        applicationState.charityAddress = _charityAddress;
    }

    function claimRemainingFunds(address _to) external virtual;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

interface IPancakePair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1);

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

contract LBlockPrice {
    using SafeMath for uint112;
    using SafeMath for uint256;
    address pairAddress = 0x655bcaaf028592a86FEa45C480d85766830b6bb9; //testnet pair address
    address owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: available only for owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function setPairAddress(address _newPairAddress) external onlyOwner {
        pairAddress = _newPairAddress;
    }

    function getLBlockPrice() public view returns (uint256) {
        (uint112 reserve0, uint112 reserve1) = IPancakePair(pairAddress)
            .getReserves();
        uint256 amount = ((reserve0.mul(10**9)).div(reserve1));
        return (amount);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Context.sol";

contract LBlockMerkleTreeV3 is Context {
    address private _merkleTreeVerifier;
    address private admin;
    bytes32 private merkleRoot;

    modifier onlyAdmin() {
        require(
            _msgSender() == admin,
            "Ownable: caller is not the owner or admin"
        );
        _;
    }

    modifier onlyVerifier() {
        require(
            _msgSender() == _merkleTreeVerifier,
            "Ownable: caller is not merkle tree verifier"
        );
        _;
    }

    constructor(address _admin) {
        require(_admin != address(0x0), "Admin address can't be zero");
        admin = _admin;
        _merkleTreeVerifier = _admin;
    }

    function setMerkleTreeRoot(bytes32 root) external onlyVerifier {
        merkleRoot = root;
    }

    function setMerkleTreeVerifier(address merkleTreeVerifier)
        external
        onlyAdmin
    {
        require(
            merkleTreeVerifier != address(0x0),
            "merkleTreeVerifier address can't be zero"
        );
        _merkleTreeVerifier = merkleTreeVerifier;
    }

    function verify(address user, bytes32[] calldata proof)
        external
        view
        returns (bool)
    {
        return
            MerkleProof.verify(
                proof,
                merkleRoot,
                keccak256(abi.encodePacked(user))
            );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/access/IAccessControl.sol";
import "./IVRFClient.sol";

interface IVRFv2Consumer is IAccessControl {
    // @notice Contains data about requests for random values
    struct RandomWordsRequest {
        address client;
        uint256 randomWord;
    }

    /// @dev The event to emmit after a client requested random word
    event RequestRandomWords(address indexed client, uint256 requestId);
    /// @dev The event to emmit after a VRF coordinator send random word
    event GotRandomWords(
        address indexed client,
        uint256 requestId,
        uint256 randomWord
    );

    /**
     * @notice Sets options for random value queries
     * @param _subscriptionId - The ID of the VRF subscription. Must be funded
     * with the minimum subscription balance required for the selected keyHash.
     * @param _keyHash - Corresponds to a particular oracle job which uses
     * that key for generating the VRF proof. Different keyHash's have different gas price
     * ceilings, so you can select a specific one to bound your maximum per request cost.
     * @param _requestConfirmations - How many blocks you'd like the
     * oracle to wait before responding to the request. See SECURITY CONSIDERATIONS
     * for why you may want to request more. The acceptable range is
     * [minimumRequestBlockConfirmations, 200].
     * @param _callbackGasLimit - How much gas you'd like to receive in your
     * fulfillRandomWords callback. Note that gasleft() inside fulfillRandomWords
     * may be slightly less than this amount because of gas used calling the function
     * (argument decoding etc.), so you may need to request slightly more than you expect
     * to have inside fulfillRandomWords. The acceptable range is
     * [0, maxGasLimit]
     * @dev Сan only be called by the client
     */
    function setRequestParams(
        uint64 _subscriptionId,
        bytes32 _keyHash,
        uint32 _callbackGasLimit,
        uint16 _requestConfirmations,
        uint96 _minimumLinkBalance
    ) external;

    /**
     * @notice Creates a request for a random word
     * @dev Can only be called by the client and if the subscription has a balance >= minimumLinkBalance
     */
    function requestRandomWords() external;
}

pragma solidity ^0.8.0;

interface INFTDraw {
    /**
     * @dev Gets all sold NFTLaunchpad's tokens.
     * @dev Gets tokens from Wrapper Contract.
     */

    function getTokens() external view returns (uint256[] memory);

    /**
     * @dev Gets all sold NFTLaunchpad's tokens.
     * @dev Gets owner of winnerToken.
     * @dev Sends all LBlocks from the current contract to winner.
     * @param _randomNumber . Randomly generated number passed from Lottery Contract.
     * @dev amount variable. Amount of LuckyBlock that are needed to be sent to the nft winner
     * @dev nftWinner variable. Address of winner.
     * @dev winnerToken . Token chosen by passed number.
     * @notice Picks a winner.
     */

    function pickWinner(uint256 _randomNumber) external;

    /**
     * @dev Sets the operator (lottery).
     * @dev Only admin can do that.
     * @param _operator . Lottery address.
     */

    function setOperator(address _operator) external;
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

pragma solidity ^0.8.8;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title The interface to describe Lottery Admin functions
interface ILBlockAdmin {
    enum LotteryState {
        saleOff,
        saleOn
    }

    /// @notice Keeps a state of the percentages to allocate rewards
    /// @dev sum of the percentages must be equal to 100
    struct LotteryPercentages {
        uint8 jackpotPercentage;
        uint8 charityPercentage;
        uint8 nftJackpotPercentage;
        uint8 marketingWalletPercentage;
        uint8 tokenHoldersPercentage;
    }

    /// @notice Keeps the LBlockLottery application state by wrapping its in a single tuple object
    /// @dev Most of the state variables going to be set in the `constructor`
    struct ApplicationState {
        address charityAddress;
        address admin;
        address taxWallet;
        ERC20 lotteryToken;
        uint256 decimals;
    }

    /// @notice Keeps the lottery state in a single tuple object
    /// @dev This state can be set and changed by admin using setter function `setupLottery`
    struct LotteryParams {
        uint256 startDateTime;
        uint256 endDateTime;
        uint256 startBlock;
        uint256 ticketPrice;
    }

    /// @notice The setter function to define start and end date-time and a ticket price for the particular lottery
    /// @param _startDateTime The start lottery date-time
    /// @param _endDateTime The end lottery date-time
    /// @param _ticketPrice The ticket price for the current lottery
    function setupLottery(
        uint256 _startDateTime,
        uint256 _endDateTime,
        uint256 _ticketPrice
    ) external;

    /// @notice The function to set lottery balance manually
    /// @param _busdAmount The amount of BUSD to define lottery balance manually
    /// @dev LBLockLottery V3 is not 100% clarified around lottery balance. The reason of having of this function is not defined
    function fundLottery(uint256 _busdAmount) external;

    /// @notice The function to set the percentages to allocate rewards.
    /// @param _jackpotPercentage The percentage of the lottery balance (lottery pool) that will be transferred to jackpot winner
    /// @param _charityPercentage The percentage of the lottery balance (lottery pool) that will be transferred to charity
    /// @param _nftJackpotPercentage The percentage of the lottery balance (lottery pool) that will be transferred to NFT winner
    /// @param _marketingWalletPercentage The percentage of the lottery balance (lottery pool) that will be transferred to Marketing Wallet
    /// @param _tokenHoldersPercentage The percentage of the lottery balance (lottery pool) that will be transferred to a separate wallet to pay rewards for LBlock token holders
    /// @dev The default values are set in the `constructor`
    function setRewardsAllocation(
        uint8 _jackpotPercentage,
        uint8 _charityPercentage,
        uint8 _nftJackpotPercentage,
        uint8 _marketingWalletPercentage,
        uint8 _tokenHoldersPercentage
    ) external;

    /// @notice The setter function to define or change the ticket price
    /// @param _ticketPrice The price of the ticket for the current lottery
    function setTicketPrice(uint256 _ticketPrice) external;

    /// @notice The function set sale ticket status (On, Off, Hold)
    /// @param _saleStatus The status of the sale (0 or 1)
    /// @dev The enum used for that 0 - off, 1- on. The `saleStatus` public variable should indicate the current status
    function setLotteryState(uint256 _saleStatus) external;

    /// @notice The function to set charity address
    /// @param _charityAddress The charity contract\wallet address
    function setCharity(address _charityAddress) external;

    /// @notice The function to set address of the token that will be used for lottery
    /// @param _tokenAddress The address of ERC20 contract
    /// @dev LuckyBlock going to be used
    function setLotteryToken(address _tokenAddress) external;

    /// @notice The function to start new lottery
    /// @dev Must have require statement to prevent start lottery during the previous one is active (sales is On)
    function startLottery() external;

    /// @notice The function to finish lottery and announce the jackpot winner, nft winner and redistribute lottery pool according the percentages
    function finishLottery() external;

    /// @notice The function to transfer remaining funds from the lottery pool to admin wallet (in the case holders did not claim their rewards fro ex.)
    /// @dev The need of this function is not defined 100%
    function claimRemainingFunds(address _to) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)

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
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
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
        return a / b + (a % b == 0 ? 0 : 1);
    }
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
// OpenZeppelin Contracts (last updated v4.6.0) (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.0;

/**
 * @dev These functions deal with verification of Merkle Trees proofs.
 *
 * The proofs can be generated using the JavaScript library
 * https://github.com/miguelmota/merkletreejs[merkletreejs].
 * Note: the hashing algorithm should be keccak256 and pair sorting should be enabled.
 *
 * See `test/utils/cryptography/MerkleProof.test.js` for some examples.
 *
 * WARNING: You should avoid using leaf values that are 64 bytes long prior to
 * hashing, or use a hash function other than keccak256 for hashing leaves.
 * This is because the concatenation of a sorted pair of internal nodes in
 * the merkle tree could be reinterpreted as a leaf value.
 */
library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     *
     * _Available since v4.4._
     */
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                // Hash(current computed hash + current element of the proof)
                computedHash = _efficientHash(computedHash, proofElement);
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = _efficientHash(proofElement, computedHash);
            }
        }
        return computedHash;
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

interface IVRFClient {
    function fulfillRandomWords(uint256 randomWord) external;
}