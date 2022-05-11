//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import  "./interfaces/IController.sol";
import  "./interfaces/IDUSD.sol";
import  "./interfaces/IDYToken.sol";
import  "./interfaces/IDusdMinter.sol";
import "./interfaces/ILiquidateCallee.sol";
import "./interfaces/IPancakeFactory.sol";
import "./interfaces/IRouter02.sol";


import "./interfaces/IPair.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Liquidate is ILiquidateCallee, Ownable {
    using SafeERC20 for IERC20;

    address public immutable controller;
    address public immutable dusd;
    IPancakeFactory public immutable factory;
    IRouter02 immutable router;

    address public immutable bUSD;
    address public immutable minter;
    uint public leftLimit;

    mapping(address => bool) public isV2Lp;
    mapping(address => bool) public isV3Lp;
    mapping(address => bool) public liquidator;
    mapping(address => address) public forBridge;

    constructor(address _controller, address _dusd, address _router, address _bUSD, address _minter) {
        controller = _controller;
        dusd = _dusd;

        router = IRouter02(_router);
        factory = IPancakeFactory(IRouter02(_router).factory());
        bUSD = _bUSD;
        minter = _minter;

        leftLimit = 100e18;
        IERC20(_bUSD).safeIncreaseAllowance(_minter, type(uint).max);

        liquidator[msg.sender] = true;

        // CAKE_DUET LP
        isV2Lp[address(0xecd30328108Fe62603705A56B5dF6757A2c9902E)] = true;
        // DUET_DUSD_LP
        isV2Lp[address(0x33C8Fb945d71746f448579559Ea04479a23dFF17)] = true;
        // DUET_WBNB_LP
        isV2Lp[address(0x27027Ef46202B0ff4D091E4bEd5685295aFbD98B)] = true;
        // DUSD_BUSD_LP
        isV2Lp[address(0x4124A6dF3989834c6aCbEe502b7603d4030E18eC)] = true;
        // CAKE_WBNB_LP
        isV2Lp[address(0x0eD7e52944161450477ee417DE9Cd3a859b14fD0)] = true;
        // BTCB_ETH_LP
        isV2Lp[address(0xD171B26E4484402de70e3Ea256bE5A2630d7e88D)] = true;
        // USDC_USDT_LP
        isV2Lp[address(0xEc6557348085Aa57C72514D67070dC863C0a5A8c)] = true;
        // USDT_BUSD_LP
        isV2Lp[address(0x7EFaEf62fDdCCa950418312c6C91Aef321375A00)] = true;

        // forBridge
        // DUET -> CAKE
        forBridge[address(0x95EE03e1e2C5c4877f9A298F1C0D6c98698FAB7B)] = address(0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82);

        // CAKE -> BUSD 
        forBridge[address(0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82)] = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
        // USDT -> BUSD
        forBridge[address(0x55d398326f99059fF775485246999027B3197955)] = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
        // WBNB -> BUSD
        forBridge[address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c)] = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
        // ETH -> WBNB
        forBridge[address(0x2170Ed0880ac9A755fd29B2688956BD959F933F8)] = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
        // BTCB -> BUSD
        forBridge[address(0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c)] = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
        // USDC -> BUSD
        forBridge[address(0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d)] = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

    }

    function approveToken(address[] memory tokens, address[] memory targets) external onlyOwner {
        require(tokens.length == targets.length, "mismatch length");
        for (uint256 i = 0; i <tokens.length; i ++) {
            IERC20(tokens[i]).safeIncreaseAllowance(targets[i], type(uint).max);
        }
    }

    modifier onlyLiquidator() {
        require(liquidator[tx.origin], "Invalid caller");
        _;
    }

    function liquidate(address _borrower, bytes calldata data) external onlyLiquidator {
        IController(controller).liquidate(_borrower, data);
    }

    function setLiquidator(address _liquidator, bool enable) external onlyOwner {
        liquidator[_liquidator] = enable;
    }

    function setLeftLimit(uint limit) external onlyOwner {
        leftLimit = limit;
    }

    function setV2Lp(address pair, bool isv2) external onlyOwner {
        isV2Lp[pair] = isv2;
    }

    function setBridge(address token, address bridge) external onlyOwner {
        forBridge[token] = bridge;
    }

    function execTransaction(address target, uint value, string memory signature, bytes memory data, uint eta) public payable onlyOwner returns (bool success) {
        bytes memory callData;
        if (bytes(signature).length == 0) {
            callData = data;
        } else {
            callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);
        }

        (success,) = target.call{value:value}(callData);
    }

    function withdraw(address token, uint256 amount) external onlyOwner {
        IERC20(token).safeTransfer(owner(), amount);
    }

    function withdrawEth(uint256 amount) external onlyOwner {
        (bool success, ) = owner().call{value: amount}(new bytes(0));
        require(success, 'safeTransferETH: ETH transfer failed');
    }

    function approveTokenIfNeeded(address token, address spender, uint amount) private {
        uint allowed = IERC20(token).allowance(address(this), spender);
        if (allowed == 0) {
            IERC20(token).safeApprove(spender, type(uint).max);
        } else if (allowed < amount) {
            IERC20(token).safeIncreaseAllowance(spender, type(uint).max - allowed);
        }
    }

    function swap(address token0, address token1) public onlyLiquidator returns (uint output)  {
        uint balance = IERC20(token0).balanceOf(address(this));
        address[] memory path = new address[](2);
        path[0] = token0;
        path[1] = token1;

        approveTokenIfNeeded(token0, address(router), balance);
        uint[] memory amounts = router.swapExactTokensForTokens(balance, 0, path, address(this), block.timestamp);
        output = amounts[amounts.length - 1];
    }

    function swapForExectOut(uint256 amountOut, address token0, address token1) public onlyLiquidator returns (uint input)  {
        address[] memory path = new address[](2);
        path[0] = token0;
        path[1] = token1;

        approveTokenIfNeeded(token0, address(router), 0);
        uint[] memory amounts = router.swapTokensForExactTokens(amountOut, type(uint256).max, path, address(this), block.timestamp); //todo slippage
        input = amounts[0];
    }

    function convert(address token) public onlyLiquidator returns (uint output) {
        
        uint balance = IERC20(token).balanceOf(address(this));
        if (token == dusd) {
            output = balance;
        } else if (token == bUSD) {
            
            output = IDusdMinter(minter).mineDusd(balance, 0, address(this));
        } else if (forBridge[token] != address(0)) {
            address target = forBridge[token];
            swap(token, target);
            output = convert(target);
        } else {
            output = swap(token, dusd);
        }
    }

    function liquidateDeposit(address borrower, address underlying, uint amount, bytes calldata data)  external override onlyLiquidator {
        IDYToken(underlying).withdraw(address(this), amount, false);
        address under = IDYToken(underlying).underlying();
        
        if (isV2Lp[under]) {
            IPair pair = IPair(under);
            IERC20(under).safeTransfer(
                under,
                pair.balanceOf(address(this))
            );

            pair.burn(address(this));
            address token0 = pair.token0();
            address token1 = pair.token1();

            if (forBridge[token0] == token1) {
                swap(token0, token1);
                convert(token1);
            } else if (forBridge[token1] == token0) {
                swap(token1, token0);
                convert(token0);
            } else {
                convert(token0);
                convert(token1);
            }
        } else if (isV3Lp[under]) {

        } else {
            convert(under);
        }

    }

    function liquidateBorrow(address borrower, address underlying, uint amount, bytes calldata data) external override onlyLiquidator {
        // msg.sender is vault  
        approveTokenIfNeeded(underlying, msg.sender, amount);

        uint b = IERC20(underlying).balanceOf(address(this));


        if (b >= amount) {
            uint left = b - amount;
            if (left > leftLimit) {
                if (left/2 < leftLimit) {
                    IERC20(underlying).safeTransfer(owner(), left/2);
                } else {
                    IERC20(underlying).safeTransfer(owner(), left - leftLimit);
                }
                
            }
        }else{
            if(underlying != dusd){ 
                swapForExectOut(amount, dusd, underlying);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IController {
  function dyTokens(address) external view returns (address);
  function getValueConf(address _underlying) external view returns (address oracle, uint16 dr, uint16 pr);
  function getValueConfs(address token0, address token1) external view returns (address oracle0, uint16 dr0, uint16 pr0, address oracle1, uint16 dr1, uint16 pr1);

  function strategies(address) external view returns (address);
  function dyTokenVaults(address) external view returns (address);

  function beforeDeposit(address , address _vault, uint) external view;
  function beforeBorrow(address _borrower, address _vault, uint256 _amount) external view;
  function beforeWithdraw(address _redeemer, address _vault, uint256 _amount) external view;
  function beforeRepay(address _repayer , address _vault, uint256 _amount) external view;

  function joinVault(address _user, bool isDeposit) external;
  function exitVault(address _user, bool isDeposit) external;

  function userValues(address _user, bool _dp) external view returns(uint totalDepositValue, uint totalBorrowValue);
  function userTotalValues(address _user, bool _dp) external view returns(uint totalDepositValue, uint totalBorrowValue);

  function liquidate(address _borrower, bytes calldata data) external;
}

//SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;

interface IDUSD {
  function mint(address to, uint256 amount) external;
  function burn(uint256 amount) external;
  function burnme(uint256 amount) external;
  function approve(address to, uint256 amount) external;
}

//SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;


interface IDYToken {
  function deposit(uint _amount, address _toVault) external;
  function depositTo(address _to, uint _amount, address _toVault) external;
  function depositCoin(address to, address _toVault) external payable;

  function withdraw(address _to, uint _shares, bool needWETH) external;
  function underlyingTotal() external view returns (uint);

  function underlying() external view returns(address);
  function balanceOfUnderlying(address _user) external view returns (uint);
  function underlyingAmount(uint amount) external view returns (uint);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IDusdMinter {
    function dusd() external view returns(address);
    function stableToken() external view returns(address);
    function mineDusd(uint amount, uint minDusd, address to) external returns(uint amountOut);
    function calcInputFee(uint amountOut) external view returns (uint amountIn, uint fee);
}

//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface ILiquidateCallee {
  function liquidateDeposit(address borrower, address underlying, uint amount, bytes calldata data) external;
  function liquidateBorrow(address borrower, address underlying, uint amount, bytes calldata data) external;
}

interface IPancakeFactory {
  function getPair(address tokenA, address tokenB) external view returns (address pair);
}

//SPDX-License-Identifier: MIT

pragma solidity >=0.6.2;
interface IRouter02 {
    function factory() external pure returns (address);
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

//SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

// for PancakePair or UniswapPair
interface IPair {

  function factory() external view returns (address);
  function token0() external view returns (address);
  function token1() external view returns (address);
  function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

  function mint(address to) external returns (uint liquidity);
  function burn(address to) external returns (uint amount0, uint amount1);
  function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
  function skim(address to) external;
  function sync() external;

  function balanceOf(address owner) external view returns (uint);

}

// SPDX-License-Identifier: MIT

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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

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