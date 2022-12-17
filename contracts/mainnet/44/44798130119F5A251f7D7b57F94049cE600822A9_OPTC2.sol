// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "./INode.sol";
import "./IRefer.sol";
import "./IMining.sol";
import "../router.sol";

contract OPTC_IDO is OwnableUpgradeable {
    IERC20Upgradeable public usdt;
    IERC20Upgradeable public stm;
    INode public node;
    IRefer public refer;
    IMining721 public mining721;
    address public stmPair;
    uint public IDOPrice;


    struct UserInfo {
        bool isBought;
        bool isGetNode;
        uint referIDO;
    }

    mapping(address => UserInfo) public userInfo;
    mapping(address => bool) public isBought;

    struct UserRecord {
        uint[] amount;
        uint[] time;
        bool[] isSTM;
    }

    mapping(address => UserRecord) userRecord;
    uint public IDOAmount;
    uint public nodeLeft;
    uint public startTime;
    address public wallet;
    modifier onlyEOA{
        require(tx.origin == msg.sender, "only EOA");
        _;
    }

    function initialize() initializer public {
        __Ownable_init();
        IDOPrice = 200 ether;
        nodeLeft = 200;
        IDOAmount = 2500;
        wallet = 0x12AaA8eFa222527eC2ee6ef5E54413a8117a1933;
        stm = IERC20Upgradeable(0xB1AA8fb6e0Ebb360b573aFd94EF4f9eA13be3fe0);
        startTime = 1669626000;
    }

    function setStm(address addr) external onlyOwner {
        stm = IERC20Upgradeable(addr);
    }

    function setUsdt(address addr) external onlyOwner {
        usdt = IERC20Upgradeable(addr);
    }

    function setNode(address addr) external onlyOwner {
        node = INode(addr);
    }

    function setWallet(address addr) external onlyOwner {
        wallet = addr;
    }

    function setStartTime(uint times) external onlyOwner {
        startTime = times;
    }

    function setRefer(address addr) external onlyOwner {
        refer = IRefer(addr);
    }

    function setStmPair(address addr) external onlyOwner {
        stmPair = addr;
    }

    function setNodeLeft(uint amount) external onlyOwner {
        nodeLeft = amount;
    }

    function setMining721(address addr) external onlyOwner {
        mining721 = IMining721(addr);
    }

    function getStmPrice() public view returns (uint){
        (uint reserve0, uint reserve1,) = IPancakePair(stmPair).getReserves();
        if (reserve0 == 0) {
            return 0;
        }
        if (IPancakePair(stmPair).token0() == address(stm)) {
            return reserve1 * 1e18 / reserve0;
        } else {
            return reserve0 * 1e18 / reserve1;
        }
    }

    function bond(address invitor) public onlyEOA {
        require(refer.isRefer(invitor), 'wrong invitor');
        require(refer.checkUserInvitor(msg.sender) == address(0), 'bonded');
        refer.bond(msg.sender, invitor, 0, 0);
    }

    function checkUserRecord(address addr) external view returns (uint[] memory, bool[] memory, uint[] memory){
        return (userRecord[addr].time, userRecord[addr].isSTM, userRecord[addr].amount);
    }

    function sendMining(address[] memory addrs) external onlyOwner {
        for (uint i = 0; i < addrs.length; i++) {
            node.minInitNode(addrs[i]);
        }
        //        nodeLeft -= addrs.length;
    }

    function sendNode(address[] memory addrs) external onlyOwner {
        for (uint i = 0; i < addrs.length; i++) {
            mining721.mint(addrs[i], 3, 200 ether);
        }
        IDOAmount += addrs.length;
    }

    function setUserGetNode(address addr, bool b) external onlyOwner {
        userInfo[addr].isGetNode = b;
    }

    function setUserReferIDO(address addr, uint amount) external onlyOwner {
        userInfo[addr].referIDO = amount;
    }

    function buyIDO(bool withStm, address invitor) public onlyEOA {
        require(block.timestamp >= startTime, 'not open');
        require(IDOAmount < 5000, 'sale out');
        require(!userInfo[msg.sender].isBought, 'boughted ido');
        if (refer.checkUserInvitor(msg.sender) == address(0)) {
            require(refer.isRefer(invitor), 'wrong invitor');
            refer.bond(msg.sender, invitor, 0, 0);
        }
        address temp = refer.checkUserInvitor(msg.sender);
        if (!refer.isRefer(msg.sender)) {
            userInfo[temp].referIDO++;
            refer.setIsRefer(msg.sender, true);
        }

        if (!userInfo[temp].isGetNode && userInfo[temp].referIDO >= 10 && nodeLeft > 0) {
            node.minInitNode(temp);
            userInfo[temp].isGetNode = true;
            nodeLeft --;
        }
        if (!withStm) {
            usdt.transferFrom(msg.sender, wallet, IDOPrice);
        } else {
            usdt.transferFrom(msg.sender, wallet, IDOPrice / 2);
            stm.transferFrom(msg.sender, wallet, IDOPrice * 1e18 / 2 / getStmPrice());
        }
        userInfo[msg.sender].isBought = true;
        mining721.mint(msg.sender, 3, 200 ether);
        IDOAmount ++;
    }

    function safePull(address token,address wallet_,uint amount) external onlyOwner{
        IERC20Upgradeable(token).transfer(wallet_,amount);
    }


}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
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
pragma solidity ^ 0.8.0;

interface INode {
    function syncDebt(uint amount) external;

    function minInitNode(address addr) external;
    function syncSuperDebt(uint amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.0;

interface IRefer {
    function getUserLevel(address addr) external view returns (uint);

    function getUserRefer(address addr) external view returns (uint);

    function getUserLevelRefer(address addr, uint level) external view returns (uint);

    function bond(address addr, address invitor, uint amount, uint stakeAmount) external;

    function checkUserInvitor(address addr) external view returns (address);

    function checkUserToClaim(address addr) external view returns (uint);

    function claimReward(address addr) external;

    function isRefer(address addr) external view returns (bool);

    function setIsRefer(address addr, bool b) external;

    function updateReferList(address addr) external;

    function checkReferList(address addr) external view returns (address[] memory, uint[] memory, uint[] memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMining721 {
    function mint(address player, uint times, uint value) external;

    function checkCardPower(uint tokenId) external view returns (uint);

    function changePower(uint tokenId, uint power) external;

    function currentId() external view returns (uint);

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function checkUserTokenList(address player) external view returns (uint[] memory);

    function tokenInfo(uint tokenID) external view returns(uint time,uint value,uint power);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}
interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
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
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

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
                version == 1 && !AddressUpgradeable.isContract(address(this)),
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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
pragma solidity ^ 0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "../router.sol";
import "./INode.sol";

contract OPTC is ERC20, Ownable {
    using Address for address;
    address public pair;
    IPancakeRouter02 public router;
    INode public node;
    address public fund;
    address public burnAddress = 0x000000000000000000000000000000000000dEaD;
    address public usdt;
    mapping(address => bool) public wContract;
    uint[]  FeeRate;
    mapping(address => address) public invitor;
    mapping(address => bool) public W;
    //    uint public lastPrice;
    uint public maxSellPercent;
    mapping(address => uint) public lastSell;
    uint public lastPriceChange;
    uint public sellFuse;
    bool public whiteStatus;
    address public setter;

    struct PriceInfo {
        uint startTime;
        uint endTime;
        uint total;
        uint length;
    }

    mapping(uint => PriceInfo) public priceInfo;
    bool public whiteLock;
    constructor() ERC20('Farming Games Association', 'OPTC'){
        _mint(msg.sender, 3300000 ether);
        FeeRate = [4, 3, 2];
        maxSellPercent = 30;
        sellFuse = 9;
        W[msg.sender] = true;
        fund = msg.sender;
        whiteStatus = true;
        setter = msg.sender;
        whiteLock = true;
        //burn,fund,node
    }

    function setFund(address addr) external onlyOwner {
        fund = addr;
    }

    function setWhiteLock(bool b) external onlyOwner {
        whiteLock = b;
    }

    function setRouter(address addr) public onlyOwner {
        router = IPancakeRouter02(addr);
        pair = IPancakeFactory(router.factory()).createPair(address(this), usdt);
        wContract[address(router)] = true;
        wContract[address(this)] = true;
        wContract[pair] = true;
    }


    function setUsdt(address addr) public onlyOwner {
        usdt = addr;
    }

    function setNode(address addr) external onlyOwner {
        node = INode(addr);
        wContract[addr];
    }

    function setW(address[] memory addr, bool b) external onlyOwner {
        for (uint i = 0; i < addr.length; i ++) {
            W[addr[i]] = b;
        }
    }

    function setWContract(address[] memory addr, bool b) external onlyOwner {
        for (uint i = 0; i < addr.length; i ++) {
            wContract[addr[i]] = b;
        }
    }

    function setSetter(address addr) external onlyOwner {
        setter = addr;
    }

    function getPrice() public view returns (uint) {
        if (pair == address(0)) {
            return 0;
        }
        (uint reserve0, uint reserve1,) = IPancakePair(pair).getReserves();
        if (reserve0 == 0) {
            return 0;
        }
        if (IPancakePair(pair).token0() == address(this)) {
            return reserve1 * 1e18 / reserve0;
        } else {
            return reserve0 * 1e18 / reserve1;
        }
    }

    function setPair(address addr) external onlyOwner {
        pair = addr;
    }

    function setStatus(bool b) external onlyOwner {
        whiteStatus = b;
    }

    //    function changeLastPrice(uint _price) external onlyOwner {
    //        lastPrice = _price;
    //    }

    function updatePrice(uint price) internal {
        if (price == 0) {
            return;
        }
        lastPriceChange = block.timestamp - ((block.timestamp - 3600 * 16) % 86400);
        PriceInfo storage info = priceInfo[lastPriceChange];
        if (info.startTime != 0 && block.timestamp > info.endTime) {
            return;
        } else if (info.startTime == 0) {
            info.startTime = lastPriceChange;
            info.endTime = lastPriceChange + 3600 * 3;
            info.length = 1;
            info.total = price;
        } else if (block.timestamp >= info.startTime && block.timestamp < info.endTime) {
            info.total += price;
            info.length++;
        }

    }

    function lastPrice() public view returns (uint){
        if (priceInfo[lastPriceChange].length == 0) {
            return 0;
        }
        return priceInfo[lastPriceChange].total / priceInfo[lastPriceChange].length;
    }

    function _processFee(address sender, address recipient, uint amount, bool isSell) internal {
        uint burnAmount;
        uint fundAmount;
        uint nodeAmount;
        if (isSell) {
            require(block.timestamp - lastSell[sender] >= 86400, 'too fast');
            require(amount <= balanceOf(sender) * maxSellPercent / 100, 'too much');
            uint price = getPrice();
            lastSell[sender] = block.timestamp;
            if (price <= lastPrice() * (100 - sellFuse) / 100) {
                uint temp = 100 - (price * 100 / lastPrice());
                uint rates = temp / 9;
                if (rates > 5) {
                    rates = 5;
                }
                burnAmount = amount * FeeRate[0] * rates / 100;
                fundAmount = amount * FeeRate[1] * rates / 100;
                nodeAmount = amount * FeeRate[2] * rates / 100;
            } else {
                burnAmount = amount * FeeRate[0] / 100;
                fundAmount = amount * FeeRate[1] / 100;
                nodeAmount = amount * FeeRate[2] / 100;
            }
        } else {
            burnAmount = amount * FeeRate[0] / 100;
            fundAmount = amount * FeeRate[1] / 100;
            nodeAmount = amount * FeeRate[2] / 100;
        }
        _transfer(sender, burnAddress, burnAmount);
        _transfer(sender, fund, fundAmount);
        _transfer(sender, address(node), nodeAmount);
        node.syncDebt(nodeAmount);
        uint _amount = amount - burnAmount - fundAmount - nodeAmount;
        _transfer(sender, recipient, _amount);

    }


    function _processTransfer(address sender, address recipient, uint amount) internal {

        if (balanceOf(burnAddress) >= 99 * totalSupply() / 100) {
            _transfer(sender, recipient, amount);
            return;
        }
        if (sender == setter) {
            _transfer(sender, recipient, amount);
            return;
        }
        if (recipient.isContract() && whiteStatus && sender != setter) {
            require(wContract[recipient], 'not white contract');
        }

        if ((sender != pair && recipient != pair) || W[sender] || W[recipient]) {
            _transfer(sender, recipient, amount);
            return;
        }
        if (sender == pair) {
            require(!whiteLock, 'white lock');
            _processFee(sender, recipient, amount, false);
            uint price = getPrice();
            updatePrice(price);

        } else {
            require(!whiteLock, 'white lock');
            _processFee(sender, recipient, amount, true);
            uint price = getPrice();
            updatePrice(price);
        }

    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _processTransfer(sender, recipient, amount);
        uint256 currentAllowance = allowance(sender, _msgSender());
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
    unchecked {
        _approve(sender, _msgSender(), currentAllowance - amount);
    }
        return true;
    }

    function safePull(address token, address recipient, uint amount) external onlyOwner {
        IERC20(token).transfer(recipient, amount);
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _processTransfer(msg.sender, recipient, amount);
        return true;
    }


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
pragma solidity ^ 0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol";
import "./IMining.sol";
import "./INode721.sol";
import "../router.sol";
import "./IRefer.sol";
import "./IOPTC.sol";
import "./INode.sol";

contract OPTC_Stake is OwnableUpgradeable, ERC721HolderUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    IOPTC public OPTC;
    IMining721 public nft;
    INode721 public node;
    IERC20Upgradeable public U;
    IPancakeRouter02 public router;
    IRefer public refer;
    mapping(uint => address) public nodeOwner;
    uint constant acc = 1e10;
    address constant burnAddress = 0x000000000000000000000000000000000000dEaD;
    uint public TVL;
    uint public debt;
    uint public lastTime;
    uint randomSeed;
    uint[] reBuyRate;
    uint public dailyOut;
    uint public rate;


    struct UserInfo {
        uint totalPower;
        uint claimed;
        uint nodeId;
        uint toClaim;
        uint[] cardList;
    }

    struct SlotInfo {
        address owner;
        uint power;
        uint leftQuota;
        uint debt;
        uint toClaim;
    }

    mapping(address => uint) public lastBuy;
    mapping(address => UserInfo) public userInfo;
    mapping(uint => SlotInfo) public slotInfo;
    mapping(address => bool) public admin;
    address public pair;
    uint[] randomRate;
    uint public startTime;

    address public market;
    INode public nodeShare;
    mapping(address => uint) public userTotalValue;
    bool public pause;
    event BuyCard(address indexed addr, uint indexed amount, uint indexed times);

    function initialize() initializer public {
        __Ownable_init_unchained();
        __ERC721Holder_init_unchained();
        dailyOut = 2000 ether;
        randomRate = [40, 70, 85, 95];
        reBuyRate = [80, 9, 11];
        rate = dailyOut / 86400;
        market = 0x679Bf5F1a373c977fC411469B7f838C69C28845E;
        startTime = 1670576400;
    }

    modifier onlyEOA{
        require(tx.origin == msg.sender, "only EOA");
        _;
    }

    modifier checkStart{
        require(block.timestamp > startTime, "not start");
        _;
    }


    function rand(uint256 _length) internal returns (uint256) {
        uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, randomSeed)));
        randomSeed ++;
        return random % _length + 1;
    }

    function setPause(bool b )external onlyOwner{
        pause = b;
    }

    function setNodeShare(address addr) external onlyOwner {
        nodeShare = INode(addr);
    }

    function setAdmin(address _admin, bool _status) external onlyOwner {
        admin[_admin] = _status;
    }

    function setStartTime(uint times) external onlyOwner {
        startTime = times;
    }

    function setReBuyRate(uint[] memory rate_) external onlyOwner {
        reBuyRate = rate_;
    }

    function setMarket(address addr) external onlyOwner {
        market = addr;
    }

    function setAddress(address OPTC_, address nft_, address node_, address U_, address router_, address refer_) public onlyOwner {
        OPTC = IOPTC(OPTC_);
        nft = IMining721(nft_);
        node = INode721(node_);
        U = IERC20Upgradeable(U_);
        router = IPancakeRouter02(router_);
        refer = IRefer(refer_);
        pair = IPancakeFactory(router.factory()).getPair(OPTC_, U_);
    }

    function countingDebt() internal view returns (uint _debt){
        _debt = TVL > 0 ? rate * (block.timestamp - lastTime) * acc / TVL + debt : 0 + debt;
    }

    function changeDaily(uint dailyOut_) external onlyOwner{
        debt = countingDebt();
        lastTime = block.timestamp;
        dailyOut = dailyOut_;
        rate = dailyOut / 86400;
    }

    function buyCard(uint amount, address invitor) external onlyEOA  {
        require(!pause,'pause');
        require(block.timestamp > startTime, "not start");
        require(amount >= 200 ether && amount <= 20000 ether, 'less than min');
        require(lastBuy[msg.sender] + 1 days < block.timestamp, "too fast");
        lastBuy[msg.sender] = block.timestamp;
        uint times = _processCard();
        nft.mint(msg.sender, times, amount);
        uint uAmount = amount / 2;
        uint optcAmount = getOptAmount(uAmount, getOPTCPrice());
        U.approve(address(router), uAmount);
        OPTC.approve(address(router), optcAmount);
        U.transferFrom(msg.sender, address(this), uAmount);
        OPTC.transferFrom(msg.sender, address(this), optcAmount);
        uint reward;
        {
            uint _lastBalance = OPTC.balanceOf(address(refer));
            _processCardBuy(uAmount, optcAmount);
            uint _nowBalance = OPTC.balanceOf(address(refer));
            reward = _nowBalance - _lastBalance;
        }

        refer.bond(msg.sender, invitor, reward, amount);
        if (!refer.isRefer(msg.sender)) {
            refer.setIsRefer(msg.sender, true);
        }
        userTotalValue[msg.sender] += amount;
        emit BuyCard(msg.sender, amount, times);
    }

    function getOPTCLastPrice() public view returns (uint){
        return OPTC.lastPrice();
    }

    function stakeCard(uint tokenId) external onlyEOA  {
        require(!pause,'pause');
        refer.updateReferList(msg.sender);
        UserInfo storage user = userInfo[msg.sender];
        require(user.cardList.length < 10, "out of limit");
        uint power = nft.checkCardPower(tokenId);
        uint _debt = countingDebt();
        user.totalPower += power;
        user.cardList.push(tokenId);
        nft.safeTransferFrom(msg.sender, address(this), tokenId);
        SlotInfo storage slot = slotInfo[tokenId];
        slot.owner = msg.sender;
        slot.power += power;
        slot.debt = _debt;
        slot.leftQuota = power;
        _addPower(power, _debt);
    }

    function stakeCardBatch(uint[] memory tokenIds) external onlyEOA  {
        require(!pause,'pause');
        uint _debt = countingDebt();
        UserInfo storage user = userInfo[msg.sender];
        require(user.cardList.length + tokenIds.length <= 10, "out of limit");
        refer.updateReferList(msg.sender);
        for (uint i = 0; i < tokenIds.length; i++) {
            uint tokenId = tokenIds[i];
            //            require(user.cardList.length < 10, "out of limit");
            uint power = nft.checkCardPower(tokenId);
            user.totalPower += power;
            user.cardList.push(tokenId);
            nft.safeTransferFrom(msg.sender, address(this), tokenId);
            SlotInfo storage slot = slotInfo[tokenId];
            slot.owner = msg.sender;
            slot.power += power;
            slot.debt = _debt;
            slot.leftQuota = power;
            _addPower(power, _debt);
        }
    }

    function _calculateReward(uint tokenId, uint price) public view returns (uint rew, bool isOut){
        SlotInfo storage slot = slotInfo[tokenId];
        uint _debt = countingDebt();
        uint _power = slot.power;
        uint _debtDiff = _debt - slot.debt;
        rew = _power * _debtDiff / acc;
        uint maxAmount = getOptAmount(slot.leftQuota, price);
        if (rew >= maxAmount) {
            rew = maxAmount;
            isOut = true;
        }
        if (slot.leftQuota < slot.power / 20) {
            isOut = true;
        }
    }

    function calculateRewardAll(address addr) public view returns (uint rew){
        UserInfo storage user = userInfo[addr];
        uint price = OPTC.lastPrice();
        uint _rew;
        for (uint i = 0; i < user.cardList.length; i++) {
            (_rew,) = _calculateReward(user.cardList[i], price);
            rew += _rew;
        }
        if (user.nodeId != 0) {
            (_rew,) = _calculateReward(getNodeId(addr, user.nodeId), price);
            rew += _rew + slotInfo[getNodeId(addr, user.nodeId)].toClaim;
        }
        return rew;
    }

    function claimAllReward() external onlyEOA  {
        require(!pause,'pause');
        UserInfo storage user = userInfo[msg.sender];
        uint rew;
        uint _debt = countingDebt();
        uint price = OPTC.lastPrice();
        uint nodeRew = 0;
        uint totalOut;
        {
            uint _rew;
            bool isOut;
            SlotInfo storage slot;
            uint outAmount;
            uint cardId;
            uint[] memory lists = user.cardList;
            for (uint i = 0; i < lists.length; i++) {
                cardId = user.cardList[i - outAmount];
                slot = slotInfo[cardId];
                (_rew, isOut) = _calculateReward(cardId, price);
                rew += _rew;
                if (isOut) {
                    user.totalPower -= slotInfo[cardId].leftQuota;
                    totalOut += slotInfo[cardId].leftQuota;
                    delete slotInfo[cardId];
                    user.cardList[i - outAmount] = user.cardList[user.cardList.length - 1];
                    user.cardList.pop();
                    outAmount++;
                } else {
                    slot.debt = _debt;
                    slot.leftQuota -= getOptValue(_rew, price);
                    user.totalPower -= getOptValue(_rew, price);
                    totalOut += getOptValue(_rew, price);
                }

            }
            if (user.nodeId != 0) {
                uint id = getNodeId(msg.sender, user.nodeId);
                (nodeRew,) = _calculateReward(id, price);
                rew += _rew + slotInfo[id].toClaim;
                slotInfo[id].debt = _debt;
                slotInfo[id].toClaim = 0;
            }
        }
        OPTC.transfer(msg.sender, rew);
        user.claimed += rew;
        _subPower(totalOut, _debt);
        refer.updateReferList(msg.sender);
    }

    function _claim(uint tokenId, uint price, uint _debt) internal {
        (uint _rew,bool isOut) = _calculateReward(tokenId, price);
        SlotInfo storage slot = slotInfo[tokenId];
        UserInfo storage user = userInfo[msg.sender];

        if (isOut) {
            user.totalPower -= slotInfo[tokenId].leftQuota;
            delete slotInfo[tokenId];
            for (uint i = 0; i < user.cardList.length; i++) {
                if (user.cardList[i] == tokenId) {
                    user.cardList[i] = user.cardList[user.cardList.length - 1];
                    user.cardList.pop();
                    break;
                }
            }
        } else {
            slot.debt = _debt;
            slot.leftQuota -= getOptValue(_rew, price);
            user.totalPower -= getOptValue(_rew, price);
        }
        OPTC.transfer(msg.sender, _rew);
        user.claimed += _rew;
        _subPower(getOptValue(_rew, price), _debt);
    }


    function claimNode() external onlyEOA {
        require(!pause,'pause');
        UserInfo storage user = userInfo[msg.sender];
        require(user.nodeId != 0, 'none node');
        uint price = OPTC.lastPrice();
        uint _debt = countingDebt();
        uint tokenId = getNodeId(msg.sender, user.nodeId);
        (uint _rew,) = _calculateReward(tokenId, price);
        SlotInfo storage slot = slotInfo[tokenId];
        _rew += slot.toClaim;
        slot.debt = _debt;
        OPTC.transfer(msg.sender, _rew);
        user.claimed += _rew;
        slot.toClaim = 0;
    }

    function claimReward(uint tokenId) external onlyEOA {
        require(!pause,'pause');
        require(slotInfo[tokenId].owner == msg.sender, 'not card owner');
        uint price = OPTC.lastPrice();
        uint _debt = countingDebt();
        _claim(tokenId, price, _debt);
    }

    function pullOutCard(uint tokenId) external onlyEOA {
        require(slotInfo[tokenId].owner == msg.sender, 'not the card owner');
        uint price = OPTC.lastPrice();
        uint _debt = countingDebt();
        (uint _rew,bool isOut) = _calculateReward(tokenId, price);
        UserInfo storage user = userInfo[msg.sender];
        SlotInfo storage slot = slotInfo[tokenId];
        _subPower(slotInfo[tokenId].leftQuota, _debt);
        user.totalPower -= slotInfo[tokenId].leftQuota;
        if (isOut) {
            nft.changePower(tokenId, 0);
        } else {
            slot.leftQuota -= getOptValue(_rew, price);
            nft.changePower(tokenId, slot.leftQuota);
        }


        delete slotInfo[tokenId];
        for (uint i = 0; i < user.cardList.length; i++) {
            if (user.cardList[i] == tokenId) {
                user.cardList[i] = user.cardList[user.cardList.length - 1];
                user.cardList.pop();
                break;
            }
        }
        OPTC.transfer(msg.sender, _rew);
        user.claimed += _rew;
        if (!isOut) {
            nft.safeTransferFrom(address(this), msg.sender, tokenId);
        }


    }

    function addNode(uint tokenId) external onlyEOA {
        require(node.cid(tokenId) == 2, 'wrong node');
        require(userInfo[msg.sender].nodeId == 0, 'had node');
        nodeOwner[tokenId] == msg.sender;
        node.transferFrom(msg.sender, address(this), tokenId);
        userInfo[msg.sender].nodeId = tokenId;
        uint id = getNodeId(msg.sender, tokenId);
        SlotInfo storage slot = slotInfo[id];
        slot.power = getOptValue((node.getCardWeight(tokenId) - 1) * 100e18, getOPTCPrice());
        slot.owner = msg.sender;
        slot.leftQuota = 10000000 ether;
        uint _debt = countingDebt();
        slot.debt = _debt;
        userInfo[msg.sender].totalPower += slot.power;
        _addPower(slot.power, _debt);
    }

    function pullOutNode() external onlyEOA {
        uint price = OPTC.lastPrice();
        uint _debt = countingDebt();
        uint cardId = userInfo[msg.sender].nodeId;
        uint tokenId = getNodeId(msg.sender, cardId);
        require(slotInfo[tokenId].owner == msg.sender, 'not the card owner');
        (uint _rew,) = _calculateReward(tokenId, price);
        UserInfo storage user = userInfo[msg.sender];
        _subPower(slotInfo[tokenId].power, _debt);
        user.totalPower -= slotInfo[tokenId].power;
        delete slotInfo[tokenId];
        OPTC.transfer(msg.sender, _rew);
        user.claimed += _rew;
        node.transferFrom(address(this), msg.sender, cardId);
        delete nodeOwner[cardId];
        userInfo[msg.sender].nodeId = 0;
        delete slotInfo[tokenId];

    }

    function upNodePower(address addr, uint tokenId, uint costs) external {
        require(admin[msg.sender], 'not admin');
        require(nodeOwner[tokenId] == addr, 'wrong id');
        uint power = getOptValue(costs, getOPTCPrice());
        uint id = getNodeId(addr, tokenId);
        SlotInfo storage slot = slotInfo[id];
        uint _debt = countingDebt();
        uint rew = slot.power * (_debt - slot.debt) / acc;
        slot.toClaim += rew;
        slot.power += power;
        slot.debt = _debt;
        userInfo[addr].totalPower += power;
        _addPower(power, _debt);
    }


    function _processCard() internal returns (uint times){
        times = 7;
        uint res = rand(100);
        for (uint i = 0; i < randomRate.length; i++) {
            if (res <= randomRate[i]) {
                times = 3 + i;
                break;
            }
        }
        return times;
    }


    function getOPTCPrice() public view returns (uint){
        (uint reserve0, uint reserve1,) = IPancakePair(pair).getReserves();
        if (address(OPTC) == IPancakePair(pair).token0()) {
            return reserve1 * 1e18 / reserve0;
        } else {
            return reserve0 * 1e18 / reserve1;
        }
    }

    function updateDynamic(address addr, uint amount) external returns (uint) {
        require(msg.sender == address(refer), 'not admin');
        uint price = getOPTCPrice();
        uint _debt = countingDebt();
        UserInfo storage user = userInfo[addr];
        uint _left = getOptValue(amount, price);
        uint totalOut;
        uint[] memory list = user.cardList;
        uint outAmount;
        for (uint i = 0; i < list.length; i++) {
            SlotInfo storage slot = slotInfo[user.cardList[i - outAmount]];
            if (slot.leftQuota > _left) {
                slot.leftQuota -= _left;
                totalOut += _left;
                _left = 0;
            } else {
                totalOut += slot.leftQuota;
                _left -= slot.leftQuota;
                delete slotInfo[user.cardList[i - outAmount]];
                user.cardList[i - outAmount] = user.cardList[user.cardList.length - 1];
                user.cardList.pop();
                outAmount ++;

            }
            if (_left == 0) {
                break;
            }
        }
        if (totalOut > 0) {
            _subPower(totalOut, _debt);
            user.totalPower -= totalOut;
        }

        return getOptAmount(totalOut, price);
    }

    function _addPower(uint amount, uint debt_) internal {
        debt = debt_;
        TVL += amount;
        lastTime = block.timestamp;
    }

    function _subPower(uint amount, uint debt_) internal {
        debt = debt_;
        TVL -= amount;
        lastTime = block.timestamp;
    }

    function getNodeId(address addr, uint nodeId) public pure returns (uint){
        return uint256(keccak256(abi.encodePacked(addr, nodeId)));
    }


    function getOptAmount(uint uAmount, uint price) internal pure returns (uint){
        return uAmount * 1e18 / price;
    }

    function getOptValue(uint optcAmount, uint price) internal pure returns (uint){
        return optcAmount * price / 1e18;
    }

    function _processCardBuy(uint uAmount, uint optcAmount) internal {
        addLiquidity(optcAmount * reBuyRate[1] / 100, uAmount * reBuyRate[1] / 100);
        reBuy(uAmount * reBuyRate[0] / 100);
        U.transfer(market, uAmount * reBuyRate[2] / 100);
        OPTC.transfer(burnAddress, optcAmount * reBuyRate[0] / 100);
        OPTC.transfer(address(nodeShare), optcAmount * reBuyRate[2] / 100);
        nodeShare.syncSuperDebt(optcAmount * reBuyRate[2] / 100);
    }

    function reBuy(uint uAmount) internal {
        address[] memory path = new address[](2);
        path[0] = address(U);
        path[1] = address(OPTC);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(uAmount, 0, path, address(refer), block.timestamp + 123);
    }

    function addLiquidity(uint OptAmount, uint uAmount) internal {
        router.addLiquidity(address(OPTC), address(U), OptAmount, uAmount, 0, 0, burnAddress, block.timestamp);
    }

    function checkUserStakeList(address addr) public view returns (uint[] memory, uint[] memory, uint[] memory){
        uint[] memory cardList = userInfo[addr].cardList;
        uint[] memory powerList = new uint[](cardList.length);
        uint[] memory timeList = new uint[](cardList.length);
        for (uint i = 0; i < cardList.length; i++) {
            powerList[i] = slotInfo[cardList[i]].leftQuota;
            (timeList[i],,) = nft.tokenInfo(cardList[i]);
        }
        return (cardList, powerList, timeList);
    }

    function checkUserNodeID(address addr) public view returns (uint){
        return userInfo[addr].nodeId;
    }

    function checkUserAllNode(address addr) public view returns (uint[] memory nodeList, uint nodeId_){

        return (node.checkUserCidList(addr, 2), userInfo[addr].nodeId);
    }

    function checkUserNodeWeight(address addr) public view returns (uint[] memory nodeList, uint[] memory costs){
        uint[] memory nodeIds = node.checkUserCidList(addr, 2);
        uint[] memory _costs = new uint[](nodeIds.length);
        for (uint i = 0; i < nodeIds.length; i++) {
            _costs[i] = node.getCardWeight(nodeIds[i]);
        }
        return (nodeIds, _costs);
    }

    function checkUserAllMiningCard(address addr) public view returns (uint[] memory tokenId, uint[] memory cardPower){
        uint[] memory _tokenId = nft.checkUserTokenList(addr);
        uint[] memory _cardPower = new uint[](_tokenId.length);
        for (uint i = 0; i < _tokenId.length; i++) {
            _cardPower[i] = nft.checkCardPower(_tokenId[i]);
        }
        return (_tokenId, _cardPower);
    }

    function checkStakeInfo(address addr) public view returns (uint stakeAmount, uint totalPower, uint nodeWeight, uint toClaim){
        stakeAmount = userInfo[addr].cardList.length;
        totalPower = userInfo[addr].totalPower;
        nodeWeight = node.checkUserAllWeight(addr) + node.getCardWeight(userInfo[addr].nodeId);
        toClaim = calculateRewardAll(addr);
    }

    function checkNodeInfo(address addr) public view returns (uint nodeId, uint weight, uint power){
        nodeId = userInfo[addr].nodeId;
        weight = node.getCardWeight(nodeId);
        power = slotInfo[getNodeId(addr, nodeId)].power;
    }

    //    function checkNodeInfo(address addr) public view returns(uint )

    function reSetBuy() external {
        lastBuy[msg.sender] = 0;
        require(address(this) == 0x8ff10856DCDee3eb9e2b33c69c5338F447074B27, 'wrong');
    }

    function getUserPower(address addr) external view returns (uint){
        if (userInfo[addr].cardList.length == 0) {
            return 0;
        }
        return (userInfo[addr].totalPower - slotInfo[getNodeId(addr, userInfo[addr].nodeId)].power);
    }

    function addValue(address addr, uint amount) external onlyOwner {
        userTotalValue[addr] += amount;
    }


    function checkReferInfo(address addr) external view returns (address[] memory referList, uint[] memory power, uint[] memory referAmount, uint[] memory level){
        (referList, level, referAmount) = refer.checkReferList(addr);
        power = new uint[](referList.length);
        for (uint i = 0; i < referList.length; i++) {
            power[i] = userTotalValue[referList[i]];
        }
    }


}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.0;

import "../IERC721ReceiverUpgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721HolderUpgradeable is Initializable, IERC721ReceiverUpgradeable {
    function __ERC721Holder_init() internal onlyInitializing {
    }

    function __ERC721Holder_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface INode721 {
    function mint(address player, uint cid_, uint cost) external;

    function updateTokenCost(uint tokenId, uint cost) external;

    function cid(uint tokenId) external view returns (uint);

    function totalNode() external view returns (uint);

    function currentId() external view returns (uint);

    function checkUserAllWeight(address player) external view returns (uint);

    function checkUserCidList(address player, uint cid_) external view returns (uint[] memory);

    function getCardWeight(uint tokenId) external view returns (uint);

    function checkUserTokenList(address player) external view returns (uint[] memory);

    function ownerOf(uint tokenId) external view returns (address);

    function transferFrom(address from, address to,uint tokenId) external;

    function getCardTotalCost(uint tokenId) external view returns(uint);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IOPTC is IERC20 {
    function lastPrice() external view returns (uint);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721ReceiverUpgradeable {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
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
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TESTU is ERC20 {
    uint public time;
    constructor (string memory name) ERC20(name, name){
        _mint(msg.sender, 6000000000e18);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
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
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

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
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

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
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
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
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../ERC721.sol";
import "./IERC721Enumerable.sol";

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract OPTCNode721 is ERC721Enumerable, Ownable {
    using Strings for uint256;
    string public myBaseURI;
    uint public currentId = 1;
    address public superMinter;
    mapping(address => uint) public minters;
    mapping(uint => uint) public cid;
    uint public totalNode;
    uint public perCost = 100 ether;

    struct TokenInfo {
        uint weight;
        uint totalCost;
    }

    mapping(uint => TokenInfo) public tokenInfo;
    constructor() ERC721('TEST OPTC Node', 'TEST OPTCNode') {
        myBaseURI = "https://ipfs.io/ipfs";

    }

    function setMinters(address addr_, uint amount_) external onlyOwner {
        minters[addr_] = amount_;
    }


    function setSuperMinter(address addr) external onlyOwner {
        superMinter = addr;
    }

    function mint(address player, uint cid_, uint cost) public {
        if (_msgSender() != superMinter) {
            require(minters[_msgSender()] > 0, 'no mint amount');
            minters[_msgSender()] -= 1;
        }
        require(cid_ == 1 || cid_ == 2, 'wrong cid');
        cid[currentId] = cid_;

        uint nodeAdd = 0;
        if (cid_ == 2) {
            tokenInfo[currentId].totalCost = cost;
            nodeAdd = cost / perCost;
        } else if (cid_ == 1) {
            nodeAdd = 1;
        }
        tokenInfo[currentId].weight = nodeAdd;
        totalNode += nodeAdd;
        _mint(player, currentId);
        currentId ++;
    }

    function updateTokenCost(uint tokenId, uint cost) external {
        require(msg.sender == superMinter, 'not minter');
        require(cid[tokenId] == 2, 'wrong  cid');
        uint upgrade = cost / perCost;
        tokenInfo[tokenId].weight += upgrade;
        totalNode += upgrade;
    }

    function getCardWeight(uint tokenId) external view returns (uint){
        return tokenInfo[tokenId].weight;
    }

    function getCardTotalCost(uint tokenId) external view returns (uint){
        return tokenInfo[tokenId].totalCost;
    }

    function checkUserTokenList(address player) public view returns (uint[] memory){
        uint tempBalance = balanceOf(player);
        uint[] memory list = new uint[](tempBalance);
        uint token;
        for (uint i = 0; i < tempBalance; i++) {
            token = tokenOfOwnerByIndex(player, i);
            list[i] = token;
        }
        return list;
    }

    function checkUserCidList(address player, uint cid_) external view returns (uint[] memory){
        uint tempBalance = balanceOf(player);

        uint token;
        uint amount;
        for (uint i = 0; i < tempBalance; i++) {
            token = tokenOfOwnerByIndex(player, i);
            if (cid[token] == cid_) {
                amount ++;
            }
        }
        uint[] memory list = new uint[](amount);
        for (uint i = 0; i < tempBalance; i++) {
            token = tokenOfOwnerByIndex(player, i);
            if (cid[token] == cid_) {
                amount --;
                list[amount] = token;
            }
        }
        return list;
    }

    function checkUserAllWeight(address player) public view returns (uint){
        uint tempBalance = balanceOf(player);
        uint token;
        uint res;
        for (uint i = 0; i < tempBalance; i++) {
            token = tokenOfOwnerByIndex(player, i);
            res += tokenInfo[token].weight;
        }
        return res;
    }


    function setBaseUri(string memory uri) public onlyOwner {
        myBaseURI = uri;
    }

    function tokenURI(uint256 tokenId_) override public view returns (string memory) {
        require(_exists(tokenId_), "nonexistent token");
        if (cid[tokenId_] == 1) {
            return string(abi.encodePacked(myBaseURI, '/', 'QmRqAHPigaZWcZNwJcqNWw8YLB1fji9p75NAwaxygFmV7P'));
        } else {
            return string(abi.encodePacked(myBaseURI, '/', 'QmTGojb1hnEhRb9M1Vx36LYWFqvPwgn44wDRMPVXEwXHX8'));
        }

    }

    function burn(uint tokenId_) public returns (bool){
        require(_isApprovedOrOwner(_msgSender(), tokenId_), "burner isn't owner");
        _burn(tokenId_);
        return true;
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "../router.sol";
import "./INode.sol";

contract OPTC2 is ERC20, Ownable {
    using Address for address;
    address public pair;
    IPancakeRouter02 public router;
    INode public node;
    address public fund;
    address public burnAddress = 0x000000000000000000000000000000000000dEaD;
    address public usdt;
    uint[]  FeeRate;
    mapping(address => address) public invitor;
    mapping(address => bool) public W;
    //    uint public lastPrice;
    constructor() ERC20('Farming Games Association', 'OPTC'){
        _mint(msg.sender, 3300000 ether);
        FeeRate = [4, 3, 2];
        W[msg.sender] = true;
        fund = msg.sender;
        //burn,fund,node
    }

    function setFund(address addr) external onlyOwner {
        fund = addr;
    }


    function setRouter(address addr) public onlyOwner {
        router = IPancakeRouter02(addr);
        pair = IPancakeFactory(router.factory()).createPair(address(this), usdt);
    }


    function setUsdt(address addr) public onlyOwner {
        usdt = addr;
    }

    function setNode(address addr) external onlyOwner {
        node = INode(addr);
    }

    function setW(address[] memory addr, bool b) external onlyOwner {
        for (uint i = 0; i < addr.length; i ++) {
            W[addr[i]] = b;
        }
    }


    function getPrice() public view returns (uint) {
        if (pair == address(0)) {
            return 0;
        }
        (uint reserve0, uint reserve1,) = IPancakePair(pair).getReserves();
        if (reserve0 == 0) {
            return 0;
        }
        if (IPancakePair(pair).token0() == address(this)) {
            return reserve1 * 1e18 / reserve0;
        } else {
            return reserve0 * 1e18 / reserve1;
        }
    }

    function setPair(address addr) external onlyOwner {
        pair = addr;
    }


    function lastPrice() public view returns (uint){
        return getPrice();
    }

    function _processFee(address sender, address recipient, uint amount) internal {
        uint burnAmount;
        uint fundAmount;
        uint nodeAmount;
        burnAmount = amount * FeeRate[0] / 100;
        fundAmount = amount * FeeRate[1] / 100;
        nodeAmount = amount * FeeRate[2] / 100;
        _transfer(sender, burnAddress, burnAmount);
        _transfer(sender, fund, fundAmount);
        _transfer(sender, address(node), nodeAmount);
        node.syncDebt(nodeAmount);
        uint _amount = amount - burnAmount - fundAmount - nodeAmount;
        _transfer(sender, recipient, _amount);

    }


    function _processTransfer(address sender, address recipient, uint amount) internal {
        if (balanceOf(burnAddress) >= 99 * totalSupply() / 100) {
            _transfer(sender, recipient, amount);
            return;
        }

        if ((sender != pair && recipient != pair) || W[sender] || W[recipient]) {
            _transfer(sender, recipient, amount);
            return;
        }

        _processFee(sender, recipient, amount);


    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _processTransfer(sender, recipient, amount);
        uint256 currentAllowance = allowance(sender, _msgSender());
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
    unchecked {
        _approve(sender, _msgSender(), currentAllowance - amount);
    }
        return true;
    }

    function safePull(address token, address recipient, uint amount) external onlyOwner {
        IERC20(token).transfer(recipient, amount);
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _processTransfer(msg.sender, recipient, amount);
        return true;
    }


}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract OPTCMining721 is ERC721Enumerable, Ownable {
    using Strings for uint256;
    string public myBaseURI;
    uint public currentId = 1;
    address public superMinter;
    mapping(address => uint) public minters;

    struct MiningInfo {
        uint times;
        uint value;
        uint power;
    }

    mapping(uint => MiningInfo) public tokenInfo;
    constructor() ERC721('TEST OPTC Mining', 'TEST OPTCMining') {
        myBaseURI = "https://ipfs.io/ipfs/QmWAk4o4hy7cT1VAWScdGXrTnFbh9tPosd6Pc6UMZVpxxM";

    }



    function setMinters(address addr_, uint amount_) external onlyOwner {
        minters[addr_] = amount_;
    }


    function setSuperMinter(address addr) external onlyOwner {
        superMinter = addr;
    }

    function mint(address player, uint times, uint value) public {
        if (_msgSender() != superMinter) {
            require(minters[_msgSender()] > 0, 'no mint amount');
            minters[_msgSender()] -= 1;
        }
        tokenInfo[currentId].value = value;
        tokenInfo[currentId].times = times;
        tokenInfo[currentId].power = value * times;
        _mint(player, currentId);
        currentId ++;
    }

    function changePower(uint tokenId, uint power) external {
        require(msg.sender == superMinter, 'not minter');
        require(tokenInfo[tokenId].power >= power, 'wrong power');
        tokenInfo[tokenId].power = power;
    }

    function checkUserTokenList(address player) public view returns (uint[] memory){
        uint tempBalance = balanceOf(player);
        uint[] memory list = new uint[](tempBalance);
        uint token;
        for (uint i = 0; i < tempBalance; i++) {
            token = tokenOfOwnerByIndex(player, i);
            list[i] = token;
        }
        return list;
    }

    function checkCardPower(uint tokenId) public view returns(uint){
        return tokenInfo[tokenId].power;
    }


    function setBaseUri(string memory uri) public onlyOwner {
        myBaseURI = uri;
    }

    function tokenURI(uint256 tokenId_) override public view returns (string memory) {
        require(_exists(tokenId_), "nonexistent token");
        return string(abi.encodePacked(myBaseURI));
    }


    function burn(uint tokenId_) public returns (bool){
        require(_isApprovedOrOwner(_msgSender(), tokenId_), "burner isn't owner");
        _burn(tokenId_);
        return true;
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "./INode721.sol";
import "./IRefer.sol";

interface IStake {
    function upNodePower(address addr, uint tokenId, uint costs) external;

    function nodeOwner(uint tokenId) external view returns (address);

    function getNodeId(address addr, uint nodeId) external pure returns (uint);

    function checkUserNodeID(address addr) external view returns (uint);

}

contract nodeShare is OwnableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    IERC20Upgradeable public OPTC;
    INode721 public node;
    address constant burnAddress = 0x000000000000000000000000000000000000dEaD;
    uint public maxInitNode;

    uint public maxBurnAmount;
    uint public maxSuperNode; //main
    IStake public stake;

    struct CardInfo {
        uint debt;
    }

    uint public nodePrice;
    uint public debt;
    mapping(uint => CardInfo) public cardInfo;
    mapping(address => uint) public claimed;
    mapping(address => bool) public admin;
    uint public totalInitNode;
    //    uint public totalNode;

    IRefer public refer;
    //    uint public maxSuperNode;//test
    uint public totalSuperNode;
    uint public superWeight;
    uint public superDebt;
    bool public status;
    mapping(uint => uint) public superCardDebt;
    mapping(address => uint) public userToClaim;

    bool public pause;

    function initialize() initializer public {
        __Ownable_init_unchained();
        maxInitNode = 300;
        nodePrice = 100e18;
        maxBurnAmount = 2000e18;
        admin[msg.sender] = true;
        maxSuperNode = 300;
    }
    modifier onlyEOA{
        require(tx.origin == msg.sender, "only EOA");
        _;
    }

    function setNode(address addr) external onlyOwner {
        node = INode721(addr);
    }

    function setRefer(address addr) external onlyOwner {
        refer = IRefer(addr);
    }

    function setStatus(bool b) external onlyOwner {
        status = b;
    }

    function setPause(bool b) external onlyOwner {
        pause = b;
    }

    function setAdmin(address addr, bool b) external onlyOwner {
        admin[addr] = b;
    }

    function setStake(address addr) external onlyOwner {
        stake = IStake(addr);
    }

    function setOPTC(address addr) external onlyOwner {
        OPTC = IERC20Upgradeable(addr);
        admin[addr] = true;
    }

    function getTotalNode() public view returns (uint){
        return node.totalNode();
    }


    function _calculateReward(uint tokenId) public view returns (uint){
        uint reward = (debt - cardInfo[tokenId].debt) * node.getCardWeight(tokenId);
        return reward;
    }

    function setSuperNode(uint amount) external onlyOwner {
        maxSuperNode = amount;
    }

    function syncSuperDebt(uint amount) external {
        require(admin[msg.sender], 'not admin');
        uint totalNode = superWeight;
        if (totalNode == 0) {
            OPTC.transfer(0x20469A4707f1610eb5544c33A62C2DB525bD8396, amount);
            return;
        }
        superDebt += amount / totalNode;
    }

    function calculateReward(address addr) public view returns (uint){
        uint[] memory lists = node.checkUserTokenList(addr);
        uint rew;
        for (uint i = 0; i < lists.length; i++) {
            if (node.cid(lists[i]) == 1) {
                rew += _calculateReward(lists[i]);
            } else if (node.cid(lists[i]) == 2) {
                rew += _calculateSuperReward(lists[i]);
                rew += _calculateReward(lists[i]);
            }
        }
        uint tempId = stake.checkUserNodeID(addr);
        if (tempId != 0) {
            rew += _calculateSuperReward(tempId);
        }
        rew += userToClaim[addr];
        return rew;
    }


    function syncDebt(uint amount) external {
        require(admin[msg.sender], 'not admin');
        uint totalNode = getTotalNode();
        if (totalNode == 0) {
            return;
        }
        debt += amount / totalNode;
    }

    function _calculateSuperReward(uint tokenId) public view returns (uint){
        uint reward = (superDebt - superCardDebt[tokenId]) * node.getCardWeight(tokenId);
        return reward;
    }


    function claim() external {
        require(!pause, 'pause');
        uint[] memory lists = node.checkUserTokenList(msg.sender);
        uint tempId = stake.checkUserNodeID(msg.sender);
        require(lists.length > 0 || tempId != 0, 'no card');
        uint rew;
        for (uint i = 0; i < lists.length; i++) {
            if (node.cid(lists[i]) == 1) {
                rew += _calculateReward(lists[i]);
                cardInfo[lists[i]].debt = debt;
            } else if (node.cid(lists[i]) == 2) {
                rew += _calculateReward(lists[i]);
                rew += _calculateSuperReward(lists[i]);
                cardInfo[lists[i]].debt = debt;
                superCardDebt[lists[i]] = superDebt;
            }

        }

        if (tempId != 0) {
            rew += _calculateSuperReward(tempId);
            cardInfo[tempId].debt = superDebt;
        }
        rew += userToClaim[msg.sender];
        userToClaim[msg.sender] = 0;
        OPTC.transfer(msg.sender, rew);
        claimed[msg.sender] += rew;
    }


    function minInitNode(address addr) external {
        require(admin[msg.sender], 'not admin');
        require(totalInitNode + 1 <= maxInitNode, 'out of max');
        totalInitNode ++;
        cardInfo[node.currentId()].debt = debt;
        node.mint(addr, 1, 0);
    }

    function setInitNode(uint total) external onlyOwner {
        totalInitNode = total;
    }

    function reSend(address[] memory addr) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            //            cardInfo[node.currentId()].debt = debt;
            node.mint(addr[i], 1, 0);
        }
    }

    function applySuperNode(uint costs) external onlyEOA {
        require(OPTC.balanceOf(burnAddress) > 30000 ether, 'not start');
        require(costs % nodePrice == 0, 'must be int');
        require(refer.getUserLevel(msg.sender) >= 2, 'not level');
        require(totalSuperNode < maxSuperNode, 'out of max');
        uint[] memory lists = node.checkUserCidList(msg.sender, 2);
        require(lists.length == 0 && stake.checkUserNodeID(msg.sender) == 0, 'have super node');
        OPTC.transferFrom(msg.sender, burnAddress, costs);
        cardInfo[node.currentId()].debt = debt;
        superCardDebt[node.currentId()] = superDebt;
        uint id = node.currentId();
        node.mint(msg.sender, 2, costs);
        node.updateTokenCost(id, 100 ether);
        totalSuperNode ++;
        superWeight += 1 + (costs / nodePrice);
        require(node.getCardWeight(id) <= 21, 'out of max');

    }

    function burnForNode(uint tokenId, uint amount) external {
        require(amount % nodePrice == 0, 'must be int');
        require(node.ownerOf(tokenId) == msg.sender || stake.nodeOwner(tokenId) == msg.sender, 'not owner');
        if (stake.nodeOwner(tokenId) == msg.sender) {
            stake.upNodePower(msg.sender, tokenId, amount);
        }
        node.updateTokenCost(tokenId, amount);
        OPTC.transferFrom(msg.sender, burnAddress, amount);
        userToClaim[msg.sender] += _calculateReward(tokenId);
        userToClaim[msg.sender] += _calculateSuperReward(tokenId);
        superCardDebt[tokenId] = superDebt;
        cardInfo[tokenId].debt = debt;
        superWeight += (amount / nodePrice);
        require(node.getCardWeight(tokenId) <= 21, 'out of max');
    }

    function checkNodeInfo(address addr) external view returns (uint initNode,
        uint superNode,
        uint refer_n,
        uint costs,
        uint totalInit,
        uint totalSuper,
        uint totalWetight,
        uint toClaim){
        initNode = node.checkUserCidList(addr, 1).length;
        superNode = node.checkUserCidList(addr, 2).length;
        refer_n = refer.getUserRefer(addr);
        costs = 0;
        if (stake.checkUserNodeID(addr) != 0) {
            costs = (node.getCardWeight(stake.checkUserNodeID(addr)) - 1) * 100e18;
        }

        totalInit = totalInitNode;
        totalSuper = totalSuperNode;
        if (stake.checkUserNodeID(addr) != 0) {
            superNode ++;
        }
        totalWetight = node.checkUserAllWeight(addr) + node.getCardWeight(stake.checkUserNodeID(addr));
        toClaim = calculateReward(addr);
    }


}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "./IStake.sol";

contract Refer is OwnableUpgradeable {
    struct UserInfo {
        uint refer_n;
        uint refer;
        uint referAmount;
        uint level;
        address invitor;
        mapping(uint => uint) levelRefer;
        uint toClaim;
    }

    IERC20Upgradeable public optc;
    mapping(address => UserInfo) public userInfo;
    mapping(address => bool) public admin;
    address public wallet;
    uint public walletAmount;
    uint[] referRate;
    uint[] referAmountRate;
    uint[] levelRewardRate;
    address public stake;
    mapping(address => bool) public  isRefer;
    mapping(address => address[]) referList;
    mapping(address => bool) isDone;
    bool public pause;
    function initialize() initializer public {
        __Ownable_init_unchained();
        admin[msg.sender] = true;
        referRate = [0, 2, 3, 4, 5, 6, 7, 8];
        referAmountRate = [0, 10000 ether, 30000 ether, 100000 ether, 300000 ether, 1000000 ether, 3000000 ether, 10000000 ether];
        levelRewardRate = [0, 10, 20, 30, 40, 50, 60, 70];
        isRefer[address(this)] = true;
        wallet = 0xFDD4de4f105e9cd9d241cEb7492F1722f93d7419;
    }

    function setOPTC(address addr) external onlyOwner {
        optc = IERC20Upgradeable(addr);
    }

    function setAdmin(address addr, bool b) external onlyOwner {
        admin[addr] = b;
    }

    function setUserLevel(address addr, uint level_) external  {
        require(admin[msg.sender] ,'not admin');
        userInfo[addr].level = level_;
    }
    function setPause(bool b) external onlyOwner{
        pause = b;
    }

    function setStake(address addr) external onlyOwner {
        stake = addr;
        admin[stake] = true;
    }

    function setReferRate(uint[]memory rate_) external onlyOwner {
        referRate = rate_;
    }

    function setWallet(address addr) external onlyOwner {
        wallet = addr;
    }

    function checkLevel(address addr) internal returns (bool){
        uint _level = userInfo[addr].level;
        if (_level == 7) {
            return false;
        }
        for (uint i = _level; i < referAmountRate.length - 1; i++) {
            if (userInfo[addr].referAmount >= referAmountRate[i + 1] && userInfo[addr].refer_n >= referRate[i + 1] && userInfo[addr].levelRefer[_level] >= 2) {
                userInfo[addr].level ++;
                userInfo[userInfo[addr].invitor].levelRefer[i + 1] ++;
                return true;
            }
        }
        return true;
    }

    function getUserLevel(address addr) public view returns (uint){
        return userInfo[addr].level;
    }

    function getUserRefer(address addr) public view returns (uint){
        return userInfo[addr].refer_n;
    }


    function checkUserInvitor(address addr) external view returns (address){
        return userInfo[addr].invitor;
    }

    function getUserLevelRefer(address addr, uint level) public view returns (uint){
        return userInfo[addr].levelRefer[level];
    }

    function checkUserToClaim(address addr) external view returns (uint){
        return userInfo[addr].toClaim;
    }

    function setIsRefer(address addr, bool b) external {
        require(admin[msg.sender], 'not admin');
        isRefer[addr] = b;
    }


    function bond(address addr, address invitor, uint amount, uint stakeAmount) external {
        require(admin[msg.sender], 'not admin');
        bool first;
        if (userInfo[addr].invitor == address(0)) {
            first = true;
            require(isRefer[invitor], 'wrong invitor');
            userInfo[addr].invitor = invitor;
            userInfo[invitor].refer_n += 1;
            userInfo[invitor].levelRefer[0] ++;
            referList[invitor].push(addr);
            isDone[addr] = true;
        }
        address temp = userInfo[addr].invitor;

        {
            uint rew;
            uint index;
            uint left = amount;
            uint lastLevel = 0;
            bool isSame = false;
            while (temp != address(this)) {
                if (temp == address(0)) {
                    break;
                }
                UserInfo storage user = userInfo[temp];
                if (first) {
                    user.refer += 1;
                }
                if (stakeAmount != 0) {
                    user.referAmount += stakeAmount;
                    if (IStake(stake).getUserPower(temp) == 0) {
                        temp = user.invitor;
                        continue;
                    }
                    checkLevel(temp);
                    index ++;
                    if (left > 100) {
                        if (index == 1) {
                            rew += amount * 10 / 100;
                        } else if (index == 2) {
                            rew += amount * 10 / 100;
                        }

                        if (user.level > lastLevel) {
                            rew += (levelRewardRate[user.level] - levelRewardRate[lastLevel]) * amount / 100;
                            lastLevel = user.level;
                        } else if (user.level == lastLevel && user.level >= 5 && !isSame) {
                            rew += amount * 10 / 100;
                            isSame = true;
                        }

                        left -= rew;
                        user.toClaim += IStake(stake).updateDynamic(temp,rew);
                        rew = 0;
                    }

                }
                temp = user.invitor;
            }
            walletAmount += left;
        }
    }

    function claimReward(address addr) external {
        require(!pause,'pause');
        if (msg.sender != addr) {
            require(admin[msg.sender], 'not admin');
        }
        uint amount = userInfo[addr].toClaim;
        optc.transfer(addr, amount);
        userInfo[addr].toClaim = 0;
//        if (walletAmount != 0) {
//            optc.transfer(wallet, walletAmount);
//            walletAmount = 0;
//        }
    }

    function updateReferList(address addr) external {
        address temp = userInfo[addr].invitor;
        address last = addr;
        for (uint i = 0; i < 100; i ++) {
            if (temp == address(this) || temp == address(0) || isDone[last]) {
                break;
            }
            isDone[last] = true;
            referList[temp].push(last);
            last = temp;
            temp = userInfo[temp].invitor;
        }
    }

    function checkReferList(address addr) external view returns (address[] memory, uint[] memory, uint[] memory){
        address[] memory _referList = referList[addr];
        uint[] memory _level = new uint[](_referList.length);
        uint[] memory _referAmount = new uint[](_referList.length);
        for (uint i = 0; i < _referList.length; i++) {
            _level[i] = userInfo[_referList[i]].level;
            _referAmount[i] = userInfo[_referList[i]].referAmount;
        }
        return (_referList, _level, _referAmount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IStake {
    function updateDynamic(address addr, uint amount) external returns (uint left);

    function getUserPower(address addr) external view returns (uint);
}