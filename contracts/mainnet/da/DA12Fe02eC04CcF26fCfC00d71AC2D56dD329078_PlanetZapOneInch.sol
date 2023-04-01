pragma solidity ^0.8.17;

// SPDX-License-Identifier: MIT

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

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

// "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/ReentrancyGuard.sol";
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
}

library Address {
   
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }


    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
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

library Math {
    function min(uint a, uint b) internal pure returns (uint) {
        return a < b ? a : b;
    }
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'Math: Sub-underflow');
    }
}

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library SafeERC20 {

    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector,spender,newAllowance));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),"SafeERC20: approve from non-zero to non-zero allowance");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Extended {
    function decimals() external view returns (uint256);
}

interface IWBNB is IERC20 {
    function deposit() external payable;
    function withdraw(uint256 wad) external;
}

interface IPlanetRouter {

    function addLiquidity(address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin,
        address to,
        uint deadline) external returns (uint amountA, uint amountB, uint liquidity);
 
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
}

interface IUniswapV2Pair {
    // function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function burn(address to) external returns (uint amount0, uint amount1);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    // function totalSupply() external view returns (uint256);
    // function kLast() external view returns (uint256);
}

interface ISolidlyPair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function stable() external view returns (bool);
    function getAmountOut(uint256 amountIn, address tokenIn) external view returns (uint256);
}

interface ISolidlyRouter{
    function addLiquidity(
        address tokenA,
        address tokenB,
        bool stable,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

        function quoteAddLiquidity(
        address tokenA,
        address tokenB,
        bool stable,
        uint amountADesired,
        uint amountBDesired
    ) external view returns (uint amountA, uint amountB, uint liquidity);
}

pragma solidity ^0.8.17;

// SPDX-License-Identifier: MIT

import "./Dependencies.sol";

/**
@title Planet Zap via OneInch
@author Planet
@notice Use this to Zap and out of any LP on Planet
*/

contract PlanetZapOneInch {
    using SafeERC20 for IERC20;

    address public immutable oneInchRouter; // Router for all the swaps to go through
    address public immutable WBNB; // BNB address
    uint256 public constant minimumAmount = 1000; // minimum number of tokens for the transaction to go through

    enum WantType {
        WANT_TYPE_UNISWAP_V2,
        WANT_TYPE_SOLIDLY_STABLE,
        WANT_TYPE_SOLIDLY_VOLATILE
    }

    event TokenReturned(address token, uint256 amount); // emitted when any pending tokens left with the contract after a function call are sent back to the user
    event Swap(address tokenIn, uint256 amountIn); // emitted after every swap transaction
    event ZapIn(address tokenIn, uint256 amountIn); //  emitted after every ZapIn transaction
    event ZapOut(address tokenOut, uint256 amountOut); // emitted after every ZapOut transaction
    // should we also include destination tokens?

    constructor(address _oneInchRouter, address _WBNB) {
        // Safety checks to ensure WBNB token address
        IWBNB(_WBNB).deposit{value: 0}();
        IWBNB(_WBNB).withdraw(0);
        WBNB = _WBNB;

        oneInchRouter = _oneInchRouter;
    }
    // Zap's main functions external and public functions

    /** 
    @notice Swaps BNB for any token via One Inch Router
    @param _token0 One Inch calldata for swapping BNB to the output token
    @param _outputToken Address of output token
    */
    function swapFromBNB (bytes calldata _token0, address _outputToken) external payable {
        require(msg.value >= minimumAmount, 'Planet: Insignificant input amount');

        IWBNB(WBNB).deposit{value: msg.value}();
        _swap(WBNB, _token0, _outputToken);
        emit Swap(WBNB, msg.value);
    }
    
    /** 
    @notice Swaps any token for another token via One Inch Router
    @param _inputToken Address of input token
    @param _tokenInAmount Amount of input token to be swapped
    @param _token0 One Inch calldata for swapping the input token to the output token
    @param _outputToken Address of output token 
    */ 
    function swap (address _inputToken, uint256 _tokenInAmount, bytes calldata _token0, address _outputToken) external {
        require(_tokenInAmount >= minimumAmount, 'Planet: Insignificant input amount');
        IERC20(_inputToken).safeTransferFrom(msg.sender, address(this), _tokenInAmount);
        _swap(_inputToken, _token0, _outputToken);
        emit Swap(_inputToken, _tokenInAmount);
    }

    /** 
    @notice Zaps BNB into any LP Pair (including aggregated pairs) on Planet via One Inch Router
    @param _token0 One Inch calldata for swapping BNB to token0 of the LP Pair
    @param _token1 One Inch calldata for swapping BNB to token1 of the LP Pair
    @param _type LP Pair type, whether uniswapV2, solidly volatile or solidly stable
    @param _router Rourter where "Add Liquidity" is to be called, to create LP Pair
    @param _pair Address of the output LP Pair token
    */ 
    function zapInBNB (bytes calldata _token0, bytes calldata _token1, WantType _type, address _router, address _pair) external payable {
        require(msg.value >= minimumAmount, 'Planet: Insignificant input amount');

        IWBNB(WBNB).deposit{value: msg.value}();
        _zapIn(WBNB, _token0, _token1, _type, _router, _pair);
        emit ZapIn(WBNB, msg.value);
    }

    /** 
    @notice Zaps any token into any LP Pair (including aggregated pairs) on Planet via One Inch Router
    @param _inputToken Address of input token
    @param _tokenInAmount Amount of input token to be zapped
    @param _token0 One Inch calldata for swapping the input token to token0 of the LP Pair
    @param _token1 One Inch calldata for swapping the input token to token1 of the LP Pair
    @param _type LP Pair type, whether uniswapV2, solidly volatile or solidly stable
    @param _router Rourter where "Add Liquidity" is to be called, to create LP Pair
    @param _pair Address of the output LP Pair token
    */
    function zapIn (address _inputToken, uint256 _tokenInAmount, bytes calldata _token0, bytes calldata _token1, WantType _type, address _router, address _pair) external {
        require(_tokenInAmount >= minimumAmount, 'Planet: Insignificant input amount');

        IERC20(_inputToken).safeTransferFrom(msg.sender, address(this), _tokenInAmount);
        _zapIn(_inputToken, _token0, _token1, _type, _router, _pair /** , _outputToken */);
        emit ZapIn(_inputToken, _tokenInAmount);
    }

    /**
    @notice Zaps out any LP Pair (including aggregated pairs) on Planet to any desired token via One Inch Router
    @param _pair Address of the input LP Pair token
    @param _withdrawAmount Amount of LP Pair token to zapped out
    @param _desiredToken Address of the desired output token
    @param _dataToken0 One Inch calldata for swapping token0 of the LP Pair to the desired output token
    @param _dataToken1 One Inch calldata for swapping token1 of the LP Pair to the desired output token
    @param _type LP Pair type, whether uniswapV2, solidly volatile or solidly stable
    */
    function zapOut(address _pair, uint256 _withdrawAmount, address _desiredToken, bytes calldata _dataToken0, bytes calldata _dataToken1, WantType _type) external {
        require(_withdrawAmount >= minimumAmount, 'Planet: Insignificant withdraw amount');

        IERC20(_pair).safeTransferFrom(msg.sender, address(this), _withdrawAmount);
        _removeLiquidity(_pair, address(this));

        IUniswapV2Pair pair = IUniswapV2Pair(_pair);
        address[] memory path = new address[](3);
        path[0] = pair.token0();
        path[1] = pair.token1();
        path[2] = _desiredToken;

        _approveTokenIfNeeded(path[0], address(oneInchRouter));
        _approveTokenIfNeeded(path[1], address(oneInchRouter));

        if (_desiredToken != path[0]) {
            _swapViaOneInch(path[0], _dataToken0);
        }

        if (_desiredToken != path[1]) {
            _swapViaOneInch(path[1], _dataToken1);
        }
    
        _returnAssets(path); // function _returnAssets also takes care of withdrawing WBNB and sending it to the user as BNB
        emit ZapOut(address(pair), _withdrawAmount);
    }

    // View function helpers for the app

    /** 
    @notice Calculates ratio of input tokens for creating solidly stable pairs
    @dev Since solidly stable pairs can be inbalanced we need the proper ratio for our swap, we need to account both for price of the assets and the ratio of the pair. 
    @param _pair Address of the solidly stable LP Pair token
    @param _router Address of the solidly router associated with the solidly stable LP Pair
    @return ratio1to0 Ratio of Token1 to Token0
    */
    function quoteStableAddLiquidityRatio(ISolidlyPair _pair, address _router) external view returns (uint256 ratio1to0) {
            address tokenA = _pair.token0();
            address tokenB = _pair.token1();

            uint256 investment = IERC20(tokenA).balanceOf(address(_pair)) * 10 / 10000;
            uint out = _pair.getAmountOut(investment, tokenA);
            (uint amountA, uint amountB,) = ISolidlyRouter(_router).quoteAddLiquidity(tokenA, tokenB, _pair.stable(), investment, out);
                
            amountA = amountA * 1e18 / 10**IERC20Extended(tokenA).decimals();
            amountB = amountB * 1e18 / 10**IERC20Extended(tokenB).decimals();
            out = out * 1e18 / 10**IERC20Extended(tokenB).decimals();
            investment = investment * 1e18 / 10**IERC20Extended(tokenA).decimals();
                
            uint ratio = out * 1e18 / investment * amountA / amountB; 
                
            return 1e18 * 1e18 / (ratio + 1e18);
    }

    /**
    @notice Calculates minimum number of LP tokens recieved when creating an LP Pair
    @param _pair Address of the LP Pair token
    @param _tokenA Address of token A of the LP Pair
    @param _tokenB Address of token B of the LP Pair
    @param _amountADesired Desired amount of token A to be used to create the LP Pair
    @param _amountBDesired Desired amount of token B to be used to create the LP Pair
    @return amountA Actual amount of token A that will be used to create the LP Pair
    @return amountB Actual amount of token B that will be used to create the LP Pair
    @return liquidity Amount of LP Tokens to be recieved when adding liquidity
     */
    function quoteAddLiquidity(
        address _pair,
        address _tokenA,
        address _tokenB,
        uint _amountADesired,
        uint _amountBDesired
        ) external view returns (uint amountA, uint amountB, uint liquidity) {
        
        if (_pair == address(0)) {
            return (0,0,0);
        }

        (uint reserveA, uint reserveB) = getReserves(_pair, _tokenA, _tokenB);
        uint _totalSupply = IERC20(_pair).totalSupply();
        
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (_amountADesired, _amountBDesired);
            liquidity = Math.sqrt(amountA * amountB) - minimumAmount;
        } else {

            uint amountBOptimal = quoteLiquidity(_amountADesired, reserveA, reserveB);
            if (amountBOptimal <= _amountBDesired) {
                (amountA, amountB) = (_amountADesired, amountBOptimal);
                liquidity = Math.min(amountA * _totalSupply / reserveA, amountB * _totalSupply / reserveB);
            } else {
                uint amountAOptimal = quoteLiquidity(_amountBDesired, reserveB, reserveA);
                (amountA, amountB) = (amountAOptimal, _amountBDesired);
                liquidity = Math.min(amountA * _totalSupply / reserveA, amountB * _totalSupply / reserveB);
            }
        }
    }

    /**
    @notice Calculates minimum number of tokens recieved when removing liquidity from an LP Pair
    @param _pair Address of the LP Pair token
    @param _tokenA Address of token A of the LP Pair
    @param _tokenB Address of token B of the LP Pair
    @param _liquidity Amount of LP Tokens desired to be removed
    @return amountA Amount of token A that will be recieved on removing liquidity
    @return amountB Amount of token B that will be recieved on removing liquidity

    */
    function quoteRemoveLiquidity(
        address _pair,
        address _tokenA,
        address _tokenB,
        uint _liquidity
        ) external view returns (uint amountA, uint amountB) {

        if (_pair == address(0)) {
            return (0,0);
        }

        (uint reserveA, uint reserveB) = getReserves(_pair, _tokenA, _tokenB);
        uint _totalSupply = IERC20(_pair).totalSupply();

        amountA = _liquidity * reserveA / _totalSupply; // using balances ensures pro-rata distribution
        amountB = _liquidity * reserveB / _totalSupply; // using balances ensures pro-rata distribution

    }

    // internal functions

     // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'PlanetLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'PlanetLibrary: ZERO_ADDRESS');
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address _pair, address _tokenA, address _tokenB) public view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(_tokenA, _tokenB);
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(_pair).getReserves();
        (reserveA, reserveB) = _tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quoteLiquidity(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'PlanetLibrary: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'PlanetLibrary: INSUFFICIENT_LIQUIDITY');
        amountB = amountA * reserveB / reserveA;
    }

    // provides allowance for the spender to access the token when allowance is not already given
    function _approveTokenIfNeeded(address _token, address _spender) private {
        if (IERC20(_token).allowance(address(this), _spender) == 0) {
            IERC20(_token).safeApprove(_spender, type(uint).max);
        }
    }
    // swaps tokens via One Inch router
    function _swap(address _inputToken, bytes calldata _token0, address _outputToken) private {
        address[] memory path;
        path = new address[](2);
        path[0] = _outputToken;
        path[1] = _inputToken;

        _swapViaOneInch(_inputToken, _token0);

        _returnAssets(path);
    }

    // Zaps any token into any LP Pair on Planet via One Inch Router
    function _zapIn(address _inputToken, bytes calldata _token0, bytes calldata _token1, WantType _type, address _router, address _pair) private {

        IUniswapV2Pair pair = IUniswapV2Pair(_pair);

        address[] memory path;
        path = new address[](3);
        path[0] = pair.token0();
        path[1] = pair.token1();
        path[2] = _inputToken;

        if (_inputToken != path[0]) {
            _swapViaOneInch(_inputToken, _token0);
        }

        if (_inputToken != path[1]) {
            _swapViaOneInch(_inputToken, _token1);
        }

        _approveTokenIfNeeded(path[0], address(_router));
        _approveTokenIfNeeded(path[1], address(_router));
        uint256 lp0Amt = IERC20(path[0]).balanceOf(address(this));
        uint256 lp1Amt = IERC20(path[1]).balanceOf(address(this));

        uint256 amountLiquidity;
        if (_type == WantType.WANT_TYPE_SOLIDLY_STABLE || _type == WantType.WANT_TYPE_SOLIDLY_VOLATILE) {
            bool stable = _type == WantType.WANT_TYPE_SOLIDLY_STABLE ? true : false;
            (,, amountLiquidity) = ISolidlyRouter(_router)
            .addLiquidity(path[0], path[1], stable,  lp0Amt, lp1Amt, 1, 1, msg.sender, block.timestamp);
        } else {
            (,, amountLiquidity) = IPlanetRouter(_router)
            .addLiquidity(path[0], path[1], lp0Amt, lp1Amt, 1, 1, msg.sender, block.timestamp);
        }
        _returnAssets(path);   
    }

    // removes liquidity from the pair by burning LP pair tokens of the input address 
    function _removeLiquidity(address _pair, address _to) private {
        IERC20(_pair).safeTransfer(_pair, IERC20(_pair).balanceOf(address(this)));
        (uint256 amount0, uint256 amount1) = IUniswapV2Pair(_pair).burn(_to);

        require(amount0 >= minimumAmount, 'UniswapV2Router: INSUFFICIENT_A_AMOUNT');
        require(amount1 >= minimumAmount, 'UniswapV2Router: INSUFFICIENT_B_AMOUNT');
    }

    // Our main swap function call. We call the aggregator contract with our fed data. If we get an error we revert and return the error result. 
    function _swapViaOneInch(address _inputToken, bytes memory _callData) private {
        
        _approveTokenIfNeeded(_inputToken, address(oneInchRouter));

        (bool success, bytes memory retData) = oneInchRouter.call(_callData);

        propagateError(success, retData, "1inch");

        require(success == true, "calling 1inch got an error");
    }

    // Error reporting from our call to the aggrator contract when we try to swap. 
    function propagateError(
        bool success,
        bytes memory data,
        string memory errorMessage
        ) public pure {
        // Forward error message from call/delegatecall
        if (!success) {
            if (data.length == 0) revert(errorMessage);
            assembly {
                revert(add(32, data), mload(data))
            }
        }
    }

    // Returns any pending assets left with the contract after a swap, zapIn or ZapOut back to the user
    function _returnAssets (address[] memory _tokens) private {
        uint256 balance;
        for (uint256 i; i < _tokens.length; i++) {
            balance = IERC20(_tokens[i]).balanceOf(address(this));
            if (balance > 0) {
                if (_tokens[i] == WBNB) {
                    IWBNB(WBNB).withdraw(balance);
                    (bool success,) = msg.sender.call{value: balance}(new bytes(0));
                    require(success, 'Planet: BNB transfer failed');
                    emit TokenReturned(_tokens[i], balance);
                } else {
                    IERC20(_tokens[i]).safeTransfer(msg.sender, balance);
                    emit TokenReturned(_tokens[i], balance);
                }
            }
        }
    }

    // enabling the contract to receive BNB
    receive() external payable {
        assert(msg.sender == WBNB);
    }

}