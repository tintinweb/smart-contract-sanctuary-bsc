// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "../mock_router/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "../interfaces/IOptVaultFactory.sol";
// import "../interfaces/IOptVaultLp.sol";
import "../interfaces/ITokenSwap.sol";
import "../interfaces/IOptVault.sol";
import "../interfaces/ILpSwap.sol";
import "../interfaces/IAdmin.sol";

contract ReceiptSwap is Initializable{
    using SafeERC20 for IERC20;
    address public router;
    IAdmin public Admin;

    function initialize( 
    address _router, 
    address _Admin
    ) external initializer{
        router = _router;
        Admin = IAdmin(_Admin);
    }
    receive() external payable {
    }

    //@param dtoken is address of token of which receipt token we use
    function RecieptTokenToToken(address dtoken,address token,uint amount, uint minAmount, address sendTo) public payable {
        (address vaultaddress, bool isLp,address recieptToken) = IOptVaultFactory(IAdmin(Admin).optVaultFactory()).getPoolInfo(IOptVaultFactory(IAdmin(Admin).optVaultFactory()).PIDsOfRewardVault(dtoken));
        IERC20(recieptToken).safeApprove(vaultaddress,amount);
        IERC20(recieptToken).safeApprove(sendTo,amount);
        IERC20(recieptToken).safeTransferFrom(sendTo,address(this),amount);
        uint recieve = IOptVault(vaultaddress).sell(address(this), amount, minAmount);
        if(!isLp){
            if(dtoken == token){
                IERC20(dtoken).safeTransfer(sendTo,recieve);
            }else{
                IERC20(dtoken).safeApprove(IAdmin(Admin).tokenSwap(),recieve);
                ITokenSwap(IAdmin(Admin).tokenSwap()).swapTOKENtoTOKEN(dtoken, token, recieve, sendTo);
        }
        }else{
               IERC20(dtoken).approve(IAdmin(Admin).LPSwap(),recieve);
               ILpSwap(IAdmin(Admin).LPSwap()).LPToToken(token, dtoken, recieve, sendTo);
        }    
    }
    function RecieptTokenToVault(address dtoken,address token,uint amount,uint _level, uint minAmount, address sendTo) public payable{
        (, bool isLp,) = IOptVaultFactory(IAdmin(Admin).optVaultFactory()).getPoolInfo(IOptVaultFactory(IAdmin(Admin).optVaultFactory()).PIDsOfRewardVault(token));
        (address vaultaddress, bool isLPVaultDToken,address recieptToken) = IOptVaultFactory(IAdmin(Admin).optVaultFactory()).getPoolInfo(IOptVaultFactory(IAdmin(Admin).optVaultFactory()).PIDsOfRewardVault(dtoken));
        if(dtoken == token){
            if(!isLp){
                IOptVaultFactory(IAdmin(Admin).optVaultFactory()).Deposit(msg.sender,token,_level,amount);    
            }else{
                IOptVaultFactory(IAdmin(Admin).optVaultFactory()).Deposit(msg.sender,token,_level,amount);
            }
        }else{
            IERC20(recieptToken).safeApprove(vaultaddress,amount);
            IERC20(recieptToken).safeApprove(sendTo,amount);
            IERC20(recieptToken).safeTransferFrom(sendTo,address(this),amount);
            uint recieve = IOptVault(vaultaddress).sell(address(this), amount, minAmount);
            if(!isLp){
                if(!isLPVaultDToken){
                    IERC20(dtoken).safeApprove(IAdmin(Admin).tokenSwap(),recieve);
                    ITokenSwap(IAdmin(Admin).tokenSwap()).swapTOKENtoTOKEN(dtoken, token, recieve, address(this));
                }else{
                    IERC20(dtoken).safeApprove(IAdmin(Admin).tokenSwap(),recieve);
                    ITokenSwap(IAdmin(Admin).tokenSwap()).swapTOKENtoLP(dtoken,token,recieve,address(this));
                }  
            }else{
                if(!isLPVaultDToken){
                    IERC20(dtoken).safeApprove(IAdmin(Admin).LPSwap(),recieve);
                    ILpSwap(IAdmin(Admin).LPSwap()).LPToToken(token, dtoken, recieve, address(this));

                }else{
                    IERC20(dtoken).safeApprove(IAdmin(Admin).LPSwap(),recieve);
                     ILpSwap(IAdmin(Admin).LPSwap()).LPToLP(dtoken,token,address(this),recieve);
                    }                    
                }
            IERC20(token).safeTransfer(sendTo,IERC20(token).balanceOf(address(this)));
            IOptVaultFactory(IAdmin(Admin).optVaultFactory()).Deposit(msg.sender,token,_level,IERC20(token).balanceOf(sendTo));
        
        } 
    }

    function RecieptTokenToLP(address dtoken,address lp,uint amount, uint minAmount, address sendTo) public{
        (address vaultaddress, bool isLp,address recieptToken) = IOptVaultFactory(IAdmin(Admin).optVaultFactory()).getPoolInfo(IOptVaultFactory(IAdmin(Admin).optVaultFactory()).PIDsOfRewardVault(dtoken));
        IERC20(recieptToken).safeApprove(vaultaddress,amount);
        IERC20(recieptToken).safeApprove(sendTo,amount);
        IERC20(recieptToken).safeTransferFrom(sendTo,address(this),amount);
        uint recieve = IOptVault(vaultaddress).sell(address(this), amount, minAmount); 
        if(!isLp){
            IERC20(dtoken).safeApprove(IAdmin(Admin).tokenSwap(),amount);
            ITokenSwap(IAdmin(Admin).tokenSwap()).swapTOKENtoLP(dtoken, lp, amount, sendTo);
        }else{
            if(dtoken == lp){
                IERC20(dtoken).safeTransfer(sendTo,recieve);
            }else{
                IERC20(dtoken).safeApprove(IAdmin(Admin).LPSwap(),recieve);
                ILpSwap(IAdmin(Admin).LPSwap()).LPToLP(dtoken,lp,sendTo,amount);
            }  
        }
    } 

    function RecieptTokenToReciept(address dtoken,address token,uint amount, uint minAmount, address sendTo) public{
        (address vaultaddress, bool isLp,address recieptToken) = IOptVaultFactory(IAdmin(Admin).optVaultFactory()).getPoolInfo(IOptVaultFactory(IAdmin(Admin).optVaultFactory()).PIDsOfRewardVault(dtoken));
        (address vaultaddressToken, bool isLPVaultToken,) = IOptVaultFactory(IAdmin(Admin).optVaultFactory()).getPoolInfo(IOptVaultFactory(IAdmin(Admin).optVaultFactory()).PIDsOfRewardVault(token));
        IERC20(recieptToken).safeApprove(vaultaddressToken,amount);
        IERC20(recieptToken).safeApprove(sendTo,amount);
        IERC20(recieptToken).safeTransferFrom(sendTo,address(this),amount);
        IERC20(recieptToken).approve(vaultaddress,amount);
        uint recieve = IOptVault(vaultaddress).sell(address(this), amount, minAmount);
        if(!isLp){
            if(!isLPVaultToken){
                IERC20(dtoken).safeApprove(IAdmin(Admin).tokenSwap(),recieve);
                ITokenSwap(IAdmin(Admin).tokenSwap()).swapTOKENtoTOKEN(dtoken, token, recieve, address(this));
            }else{
                IERC20(dtoken).safeApprove(IAdmin(Admin).tokenSwap(),recieve);
                ITokenSwap(IAdmin(Admin).tokenSwap()).swapTOKENtoLP(dtoken, token, recieve, address(this));
            }
        }else{
            if(!isLPVaultToken){
                IERC20(dtoken).safeApprove(IAdmin(Admin).LPSwap(),recieve);
                ILpSwap(IAdmin(Admin).LPSwap()).LPToToken(token,dtoken,recieve,address(this));
            }else{
                IERC20(dtoken).safeApprove(IAdmin(Admin).LPSwap(),recieve);
                ILpSwap(IAdmin(Admin).LPSwap()).LPToLP(dtoken,token,address(this),recieve);
            }
        }

            IERC20(token).safeTransfer(sendTo,IERC20(token).balanceOf(address(this)));
            IERC20(token).safeApprove(vaultaddressToken,IERC20(token).balanceOf(sendTo));
            IOptVault(vaultaddressToken).purchase(sendTo,IERC20(token).balanceOf(sendTo), minAmount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

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
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IOptVaultFactory{
     struct UserInfo {
        uint256 time;
        bool phoenixNFTStatus;
        nftStatus NFT;
        uint256 amount;
    }
    enum nftStatus {
        NOT_MINTED,
        ACTIVE
    }
    struct PoolInfo {
        IERC20 token;
        address vault;
        address recieptInstance;
        bool status;
        bool isLp;
        bool isAuto;
        bool isCustomVault;
        uint32[] multiplier;
    }

    enum LiqStatus {
        SWAP_WANT_TO_BUSD,
        CONTROLLER_FEE,
        OPTIMIZATION_TAX,
        OPTIMIZATION_REWARDS
    }
     function initialize(address owner,address _BUSD,address _distributor,address _tempHolding,address _USDy,address _masterNTT,address nft,address phoenix,address _masterChef) external;
     function add( IERC20 _token, address _strat,string memory _name,string memory _symbol,uint32[] memory _multiplier) external;
     function setMultipliersLevel(address _token,uint32[] calldata _multiplier,uint32[] memory deductionValue) external;
     function Deposit(address user,address _token,uint _level,uint256 _amount) external ;
     function withdraw(address user,address _token,bool isReceipt,uint _recieptAmount) external ;
     function userInfo(uint pid,address user) external returns(UserInfo memory);
     function getPoolInfo(uint index) external view returns(address vaultAddress, bool isLP, address recieptInstance );
     function PIDsOfRewardVault(address token) external returns(uint256);
     function optimizationRewards(address user,address _token) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

interface ITokenSwap{
    function swapTOKENtoTOKEN(address path0, address path1, uint amount, address sendTo) external payable returns(uint);
    function swapTOKENtoLP(address depositToken, address LPToken, uint amount, address sendTo) external payable;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IOptVault {
    function initialize(uint256 _id, address _owner,  address _token, address _want, address _Admin) external;
    function setMultiplierLevel(uint32 _level,uint32 amount) external returns(uint32);
    function vaultToken() external view returns(address);
    function swapWantToBUSD() external;
    function UserLevel(address _user) external returns(uint);
    function setreciept(address _reciept) external;
    function optimizationReward(address user, uint optMultiplier) external;
    function deductControllerFee(uint fee) external;
    function purchase(address user,uint amount, uint minAmount) external returns(uint);
    function sell(address user,uint amount, uint minAmount) external returns(uint);
    function collectOptimizationTax() external;
    function deposit(address user,uint amount,uint32 _level) external;
    function withdraw(address user, bool isReciept, uint _amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface ILpSwap{
    function initialize(address _owner, address _router,address _admin) external;
    function LPToToken(address token,address lp,  uint _amount,address sendTo) external;
    function LPToVault(address lp, address token, uint amount,address sendTo,bool isReceipt) external payable;
    function LPToLP(address lp1, address lp2, address _amount, uint sendTo) external payable;
    function LPToRecieptToken(address lp, address token, address vault, uint amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
interface IAdmin{
    function BUSDProtocol() external returns(address);
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
    function xYSLS() external returns(address);
    function YSLS() external returns(address);
    function swapPage() external returns(address);
    function PhoenixNFT() external returns(address);
    function Opt1155() external returns(address);
    function EarlyAccess() external returns(address);
    function LPSwap() external returns(address);
    function optVaultFactory() external returns(address);
    function ReceiptSwap() external returns(address);
    function swap() external returns(address);
    function temporaryHolding() external returns(address);
    function tokenSwap() external returns(address);
    function vaultSwap() external returns(address);
    function whitelist() external returns(address);
    function BUSD() external view returns(address);
    function WBNB() external returns(address);
    function BShareVault() external returns(address);
    function masterNTT() external returns (address);
    function biswapRouter() external returns (address);
    function ApeswapRouter() external returns (address);
    function pancakeRouter() external returns (address);
    function TeamAddress() external returns (address);
    function MasterChef() external returns (address);


    function initialize(address owner) external;
    function setWBNB(address _WBNB) external;
    function setBUSD(address _BUSD) external;
    function setWhitelist(address _whitelist) external;
    function setVaultSwap(address _vaultSwap) external;
    function setTokenSwap(address _tokenSwap) external;
    function setTemporaryHolding(address _temporaryHolding) external;
    function setSwap(address _swap) external;
    function setReceiptSwap(address _ReceiptSwap) external;
    function setOptVaultFactory(address _optVaultFactory) external;
    function setLPSwap(address _LPSwap) external;
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
    function setBUSDProtocol(address _BUSDProtocol) external;
    function setmasterNTT(address _masterntt) external;
    function setbiswapRouter(address _biswapRouter)external;
    function setApeswapRouter(address _ApeswapRouter)external;
    function setpancakeRouter(address _pancakeRouter)external;
    function setTeamAddress(address _TeamAddress)external;
    function setMasterChef(address _MasterChef)external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

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