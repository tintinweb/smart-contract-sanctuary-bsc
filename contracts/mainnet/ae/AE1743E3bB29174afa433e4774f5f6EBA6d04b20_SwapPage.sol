// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "../Interfaces/IProtocolOwnedLiquidity.sol";
import "../Interfaces/IAdmin.sol";
import "../Interfaces/IBYSL.sol";
import "../Interfaces/IEarlyAccessNFT.sol";
import "../Interfaces/IReferralNFT.sol";

/**
@dev this contract is for swap page
 */
contract SwapPage is Initializable, Pausable {
    using SafeERC20 for IERC20;
    address public BUSD; //address of BUSD
    address public bYSL; // address of bYSL
    address public Treasury; // address of Treasury
    address public POL; // address of POL
    address public WETH; //address of WETH
    address public APE_SWAP_ROUTER_ADDRESS;
    uint256 public exit_Fees = 1000; //Tax multiply by 100
    uint256 public startTime;
    uint256 public lastBYSLSupply;
    uint256[] public exit_Fees_Allocation = [1000];
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    mapping(address => uint256) public transactionTimeLimit;
    IAdmin public Admin; // address of Admin

    /**
 @dev an Initialize function 
 */
    function initialize(address _admin) external initializer {
        Admin = IAdmin(_admin);
        bYSL = Admin.bYSL();
    }

    /**
    @dev a modifier for Admin
 */
    modifier _isAdmin() {
        require(Admin.hasRole(DEFAULT_ADMIN_ROLE, msg.sender));
        _;
    }

    /**
    @dev function is used to purchase BYSl by providing BUSD
    @param givenToken address of token 
    @param amount amount as uint
     */
    function purchaseBYSL(address givenToken, uint256 amount) external whenNotPaused{
        require(amount > 0, "amount is greater than zero.");
        require(startTime != 0, "purchase yet to start");
        if (
            startTime +
                (IEarlyAccessNFT(Admin.EarlyAccess()).top() * 1 hours) >=
            block.timestamp
        ) {
            require(
                (IEarlyAccessNFT(Admin.EarlyAccess()).Won(msg.sender) != 0) &&  (startTime +
                    ((IEarlyAccessNFT(Admin.EarlyAccess()).Won(msg.sender) -
                        1) * 1 hours) <=
                    block.timestamp)
                    ,
                "no access to purchase"
            );
        }
        if (givenToken == Admin.BUSD()) {
            IERC20(Admin.BUSD()).safeTransferFrom(
                msg.sender,
                address(this),
                amount
            );
        } else {
            IERC20(givenToken).safeTransferFrom(
                msg.sender,
                address(this),
                amount
            );
            IERC20(givenToken).approve(Admin.ApeswapRouter(), amount);
            address[] memory path = new address[](2);
            path[0] = givenToken;
            path[1] = Admin.BUSD();
            amount = IUniswapV2Router02(Admin.ApeswapRouter())
                .swapExactTokensForTokens(
                    amount,
                    0,
                    path,
                    address(this),
                    block.timestamp + 1000
                )[1];
        }
        (uint256 BUSDAmount, uint256 leftAmount) = IReferralNFT(Admin.Refferal()).rewardDistribution
                        (msg.sender,(amount * 9) / 100,amount);
        if (BUSDAmount != 0) {
            IERC20(Admin.BUSD()).transfer(msg.sender, (amount * 1) / 100);
            IERC20(Admin.BUSD()).transfer(Admin.Refferal(), BUSDAmount);
        }else{
            IERC20(Admin.BUSD()).transfer(Admin.TeamAddress(), (amount * 1) / 100);
        }
        if (leftAmount != 0) {
            IERC20(Admin.BUSD()).transfer(Admin.TeamAddress(), leftAmount);
        }
        IERC20(Admin.BUSD()).safeTransfer(
            Admin.TeamAddress(),
            ((amount * 9) / 20)
        );
        IERC20(Admin.BUSD()).safeTransfer(
            Admin.Treasury(),
            ((amount * 9) / 20)
        );
        uint256 ProtocolPricebYSL = ((((amount * 9) / 10) * (10**18)) /
            (IBYSL(bYSL).calculateProtocolPrice())); //Divide by 10**18 for testing
        IBYSL(Admin.bYSL()).mint(msg.sender, ProtocolPricebYSL);
        lastBYSLSupply += ProtocolPricebYSL;
        if(lastBYSLSupply != IBYSL(Admin.bYSL()).totalSupply()){
            _pause();
        }
    }

    function setStartTime(uint256 _startTime) external {
        require(
            msg.sender == Admin.EarlyAccess() || msg.sender == Admin.operator()
        );
        startTime = _startTime;
    }

    /**
    @dev function to sell bysl via swappage contract
    @param wantToken address of desired token
    @param amount amount for token as uint
     */
    function sellBYSLviaSWAP(address wantToken, uint256 amount) external whenNotPaused{
        require(amount > 0, "Amount cannot be zero");
        uint256 BUSDAmount;
        uint256 leftAmount;
        IProtocolOwnedLiquidity(Admin.POL()).sellBYSL(msg.sender, amount);
        lastBYSLSupply -= amount;
        if(lastBYSLSupply != IBYSL(Admin.bYSL()).totalSupply()){
            _pause();
        }
        amount = IERC20(Admin.BUSD()).balanceOf(address(this));
        (BUSDAmount, leftAmount) = IReferralNFT(Admin.Refferal()).rewardDistribution(
                msg.sender,((amount * 9) / 100),amount);
        if (BUSDAmount != 0) {
            IERC20(Admin.BUSD()).safeTransfer(
                msg.sender,
                ((amount * 1) / 100)
            );
            IERC20(Admin.BUSD()).transfer(Admin.Refferal(), BUSDAmount);
        }else{
            IERC20(Admin.BUSD()).safeTransfer(Admin.TeamAddress(),((amount * 1) / 100));
        }
        if (leftAmount != 0) {
            IERC20(Admin.BUSD()).transfer(Admin.TeamAddress(), leftAmount);
        }
        BUSDAmount = (amount * 9) / 10;
        if (wantToken == Admin.BUSD()) {
            IERC20(Admin.BUSD()).safeTransfer(
                msg.sender,
                BUSDAmount
            );
        } else {
            address[] memory path = new address[](2);
            path[0] = Admin.BUSD();
            path[1] = wantToken;
            IERC20(Admin.BUSD()).safeApprove(Admin.ApeswapRouter(),amount);
            IUniswapV2Router02(Admin.ApeswapRouter()).swapExactTokensForTokens(
                amount,
                0,
                path,
                msg.sender,
                block.timestamp + 1000
            );
        }
    }

    /**
    @dev set tax and allocation points

    @param ExitFees total tax
    @param allocationExitFees array of allocation point

    Note allocation point should be equal to tax
        all the values should enter with 100 cofficient
        only admin can call 
     */
    function setbYSLAndAllocationTax(
        uint256 ExitFees,
        uint256[] memory allocationExitFees
    ) external _isAdmin {
        require(ExitFees > 0, "bYSL: Tax Should be greater than Zero");
        require(
            allocationExitFees.length > 0,
            "bYSL: AllocationTax should not be empty"
        );
        uint256 total;
        for (uint256 i; i < allocationExitFees.length; i++) {
            total += allocationExitFees[i];
        }
        require(
            total == ExitFees,
            "bYSL: Tax not equal to sum of allocation tax"
        );
        exit_Fees = ExitFees;
        exit_Fees_Allocation = allocationExitFees;
    }

    function unpause() public _isAdmin{
        _unpause();
    }
}

pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
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

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
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
// OpenZeppelin Contracts v4.4.0 (token/ERC20/utils/SafeERC20.sol)

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
// OpenZeppelin Contracts v4.4.0 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
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
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
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
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (security/Pausable.sol)

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
pragma solidity ^0.8.7;
// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


interface IProtocolOwnedLiquidity {
    function convertedBUSDForbYSL(uint amount) external;
    function sellBYSL(address user,uint byslAmount)  external ;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/IAccessControl.sol";
interface IAdmin is IAccessControl{
    function lpDeposit() external returns(bool);
    function admin() external returns(address);
    function operator() external returns(address);
    function Trigger() external returns(address);
    function POL() external  view returns(address);
    function Treasury() external view returns(address);
    function BShareBUSDVault() external returns(address);
    function bYSLVault() external returns(address);
    function USDyBUSDVault() external returns(address);
    function USDyVault() external returns(address);
    function xYSLBUSDVault() external returns(address);
    function xYSLVault() external returns(address);
    function YSLBUSDVault() external returns(address);
    function YSLVault() external returns(address);
    function BShare() external returns(address);
    function bYSL() external returns(address);
    function USDs() external returns(address);
    function USDy() external returns(address);
    function YSL() external returns(address);
    function xYSL() external returns(address); 
    function xBUSD() external returns(address);
    function xYSLS() external returns(address);
    function YSLS() external returns(address);
    function swapPage() external returns(address);
    function PhoenixNFT() external returns(address);
    function Opt1155() external returns(address);
    function EarlyAccess() external returns(address);
    function helperSwap() external returns(address);
    function optVaultFactory() external returns(address);
    function swap() external returns(address);
    function temporaryHolding() external returns(address);
    function whitelist() external returns(address);
    function Blacklist() external returns(address);
    function BUSD() external view returns(address);
    function WBNB() external returns(address);
    function BShareVault() external returns(address);
    function masterNTT() external returns (address);
    function biswapRouter() external returns (address);
    function ApeswapRouter() external returns (address);
    function pancakeRouter() external returns (address);
    function TeamAddress() external returns (address);
    function MasterChef() external returns (address);
    function Refferal() external returns (address);
    function liquidityProvider() external returns(address);
    function temporaryReferral() external returns(address);
    function initialize(address owner) external;
    function setLpDeposit(bool deposit) external;
    function setRefferal(address _refferal)  external;
    function setWBNB(address _WBNB) external;
    function setBUSD(address _BUSD) external;
    function setLiquidityProvider(address _liquidityProvider) external;
    function setWhitelist(address _whitelist) external;
    function setBlacklist(address _blacklist) external;
    function sethelperSwap(address _helperSwap) external;
    function setTemporaryHolding(address _temporaryHolding) external;
    function setSwap(address _swap) external;
    function setOptVaultFactory(address _optVaultFactory) external;
    function setEarlyAccess(address _EarlyAccess) external;
    function setOpt1155(address _Opt1155) external;
    function setPhoenixNFT(address _PhoenixNFT) external;
    function setSwapPage(address _swapPage) external;
    function setYSL(address _YSL) external;
    function setYSLS(address _YSLS) external;
    function setxYSLs(address _xYSLS) external;
    function setxYSL(address _xYSL) external;
    function setUSDy(address _USDy) external;
    function setUSDs(address _USDs) external;
    function setbYSL(address _bYSL) external;
    function setBShare(address _BShare) external;
    function setYSLVault(address _YSLVault) external;
    function setYSLBUSDVault(address _YSLBUSDVault) external;
    function setxYSLVault(address _xYSLVault) external;
    function setxYSLBUSDVault(address _xYSLBUSDVault) external;
    function setUSDyVault(address _USDyVault) external;
    function setUSDyBUSDVault(address _USDyBUSDVault) external;
    function setbYSLVault(address _bYSLVault) external;
    function setBShareBUSD(address _BShareBUSD) external;
    function setPOL(address setPOL) external;
    function setBShareVault(address _BShareVault) external;
    function setTrigger(address _Trigger) external;
    function setmasterNTT(address _masterntt) external;
    function setbiswapRouter(address _biswapRouter)external;
    function setApeswapRouter(address _ApeswapRouter)external;
    function setpancakeRouter(address _pancakeRouter)external;
    function setTeamAddress(address _TeamAddress)external;
    function setMasterChef(address _MasterChef)external;
    function setTemporaryReferral(address _temporaryReferral)external;

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IBYSL {

    function isMinter(address _address) external view returns (bool result);
    function mint(address account, uint amount) external;
    function burn(address account, uint amount) external;
    function setMinter(address _minter) external;
    function removeMinter(address _minter) external; 
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function protocolPrice() external view returns(uint);
    function backedPrice() external returns(uint);
    function calculateProtocolPrice() external returns(uint);
    function setTransactionLimit(address sender) external;
    function transactionTimeLimit(address) external view returns(uint);
}

pragma solidity ^0.8.7;

interface IEarlyAccessNFT{

    function top() external returns(uint);

    function Won(address) external returns(uint);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IReferralNFT{
    function rewardDistribution(address user, uint _reward, uint volume) external returns(uint amount, uint leftAmount);
    function getReferrer(address user) external returns(address);
}

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
// OpenZeppelin Contracts v4.4.0 (utils/Address.sol)

pragma solidity ^0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
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
// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

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
// OpenZeppelin Contracts v4.4.0 (access/IAccessControl.sol)

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