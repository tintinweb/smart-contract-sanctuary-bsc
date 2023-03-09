/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

/**
           Welcome to FPX Technology smart contract!

           FPX designs virtual and real products using Blockchain and Web 3.0 technology 
           to bring a unique innovation to online pay systems worldwide.

           A single wallet, all accounts, a brand new blockchain architecture.
           " Convert your coins to cash in seconds byclicking on a single button. 
           It's really very cool! "

           The aim of our project is to convert the crypto assets in the existing 
           exchange accounts of the users into coins that can be used in daily life 
           in seconds with the highly secure FPX Mobile Application. 
           With the infrastructure it is developing,

           FPX Token is a technology that contributes to the formation of a structure 
           that is valid everywhere in the world and everywhere in the world and 
           can be easily used by everyone under its leadership.

           www.FpxToken.com
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


/**
 * @dev Collection of functions related to the address type
 */
library Address {

    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionCallWithValue(
                target,
                data,
                0,
                "Address: low-level call failed"
            );
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
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
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
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

    function renounceOwnership() external virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
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
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

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


interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}


contract FpxMobile is Context, IERC20, Ownable {
    using Address for address;
    //Address Definition for use in the contract during deployment
    address payable public treasureWalletAddress = payable(0x9F81a977FF761AAC965f0E234F223ce53d9547f1); // treasure Wallet Address
    address payable public marketingWalletAddress= payable (0x9F81a977FF761AAC965f0E234F223ce53d9547f1); // marketing Wallet Address
    address payable public reserveWalletAddress= payable (0x9F81a977FF761AAC965f0E234F223ce53d9547f1); // reserve Wallet Address
    address public safuDevWallet = 0x9F81a977FF761AAC965f0E234F223ce53d9547f1; //SAFU Dev Wallet for Record.
    address public constant deadWallet = 0x000000000000000000000000000000000000dEaD; //Dead Wallet for Liquidity Related Activities
    //Mapping Definitions
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcluded;
    address[] private _excluded;
    //Log and Events Files
    event Log(string, uint256);
    event AuditLog(string, address);
    //Token Definition
    string private constant _name = "FPX Mobile";
    string private constant _symbol = "FPX";
    uint8 private constant _decimals = 18;
    uint8 private constant _version = 4;
    //Supply Definition
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 1_000_000_000 * 10**_decimals;


    //Tax Definition for Contraact
    uint256 public _liquidityFee = 1;
    uint256 public _treasureFee = 1;
    uint256 public _marketingFee = 2;
    uint256 public _reserveFee = 1;
    uint256 public totalSwapableFee = _treasureFee + _liquidityFee + _marketingFee + _reserveFee;
    //Definition for the swapAndLiquify Trigger.
    uint256 private minimumTokensBeforeSwap = 1_000_000 * 10**_decimals;
   //Swap Controls
    uint256 public constant swapOutput = 0;
    //Trading Controls added for SAFU Requirements
    bool public tradingEnabled;
    //Math to calculate fees correctly and to track progress
    uint256 public liquidityTokensCollected = 0;
    uint256 public treasureTokensCollected = 0;
    uint256 public marketingTokensCollected = 0;
    uint256 public reserveTokensCollected = 0;
    //Swap and Router Data
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public currentRouter;
    address public immutable uniswapV2Pair;

    bool public inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = false;
    //Additional Log and Event Data.
    event RewardLiquidityProviders(uint256 tokenAmount);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    event SwapTokensForETH(uint256 amountIn, address[] path);

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
//Constructor for Deployment
    string private constant _safuDEV = "Tify";

    constructor(uint8 deployedVersion) {
     require (_version == deployedVersion, "Your not the SAFU Deployer, reach to the SAFU Dev for assistance.");
        

        _tOwned[_msgSender()] = _tTotal;

        //Adding Variables for all the routers for easier deployment for our customers.
        if (block.chainid == 56) {
            currentRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // PCS Router
        } else if (block.chainid == 97) {
            currentRouter = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1; // PCS Testnet
        } else if (block.chainid == 43114) {
            currentRouter = 0x60aE616a2155Ee3d9A68541Ba4544862310933d4; //Avax Mainnet
        } else if (block.chainid == 137) {
            currentRouter = 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff; //Polygon Ropsten
        } else if (block.chainid == 250) {
            currentRouter = 0xF491e7B69E4244ad4002BC14e878a34207E38c29; //SpookySwap FTM
        } else if (block.chainid == 6066) {
            currentRouter = 0x3cB3230454d8fA6dbB8956A0EF421e8d58c1AE46; //Tres Chain
        } else if (block.chainid == 1 || block.chainid == 4) {
            currentRouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; //Mainnet
        } else {
            revert();
        }

        //End of Router Variables.

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(currentRouter);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

        

        emit Transfer(address(0), _msgSender(), _tTotal);

    }
//Views to extract data from contract
    function name() external pure returns (string memory) {
        return _name;
    }

    function safuDEV() external pure returns (string memory) {
        return _safuDEV;
    }


    function symbol() external pure returns (string memory) {
        return _symbol;
    }

    function decimals() external pure returns (uint8) {
        return _decimals;
    }

    function version() external pure returns (uint8) {
        return _version;
    }

    function totalSupply() external view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }
//Begin Transfer details specific to this contract
    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        external
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()] - amount
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        external
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] - subtractedValue
        );
        return true;
    }

    function minimumTokensBeforeSwapAmount() external view returns (uint256) {
        return minimumTokensBeforeSwap;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    //Transfer function with variables for taxes and trigger the tax collection depening on the swap points.
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(tradingEnabled || _isExcludedFromFee[from] || _isExcludedFromFee[to], "Trading not yet enabled!");



        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinimumTokenBalance = contractTokenBalance >=
            minimumTokensBeforeSwap;

        if (
            !inSwapAndLiquify &&
            swapAndLiquifyEnabled &&
            from != uniswapV2Pair &&
            from != owner()
        ) {
            if (overMinimumTokenBalance) {
                swapAndLiquify();
            }
        }

        bool takeFee = true;
        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }
        _tokenTransfer(from, to, amount, takeFee);
        
    }

    function swapAndLiquify() private lockTheSwap {
        uint256 initialBalance = address(this).balance;
        uint256 halfLiquidityTokens = liquidityTokensCollected / 2;
        swapTokensForEth(halfLiquidityTokens);

        uint256 newBalance = address(this).balance - initialBalance;
        addLiquidity(halfLiquidityTokens, newBalance);
        emit SwapAndLiquify(
            halfLiquidityTokens,
            newBalance,
            halfLiquidityTokens
        );

        uint256 totalTokens = balanceOf(address(this));
        swapTokensForEth(totalTokens);
        newBalance = address(this).balance;

        uint256 walletsTotal = treasureTokensCollected + marketingTokensCollected + reserveTokensCollected;

        uint256 ethForTreasure = (newBalance * treasureTokensCollected) /
            walletsTotal;

        uint256 ethForMarketing = (newBalance * marketingTokensCollected) / walletsTotal;
        
        uint256 ethForReserve = (newBalance * reserveTokensCollected) / walletsTotal;

        transferToAddressETH(treasureWalletAddress, ethForTreasure);
        transferToAddressETH(marketingWalletAddress, ethForMarketing);
        transferToAddressETH(marketingWalletAddress, ethForReserve);

        liquidityTokensCollected = 0;
        treasureTokensCollected = 0;
        marketingTokensCollected = 0;
        reserveTokensCollected = 0;
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            swapOutput, // accept any amount of ETH //testing 1 from 0
            path,
            address(this), // The contract
            block.timestamp
        );

        emit SwapTokensForETH(tokenAmount, path);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            deadWallet, //SAFU Value
            block.timestamp
        );
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        if (takeFee) countUpFeeShare(amount);

        _transferBothExcluded(sender, recipient, amount, takeFee);
    }
//we count up the taxes collected using this function for auditing purpose
    function countUpFeeShare(uint256 amount) private {
        liquidityTokensCollected += (amount * _liquidityFee) / 100;
        treasureTokensCollected += (amount * _treasureFee) / 100;
        marketingTokensCollected += (amount * _marketingFee) / 100;
        reserveTokensCollected += (amount * _reserveFee) / 100;
    }

    function _transferBothExcluded(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        uint256 tTransferAmount = tAmount;
        uint256 tLiquidity = 0;
        if (takeFee) {
            (tTransferAmount, tLiquidity) = _getTValues(tAmount);
            _takeLiquidity(tLiquidity);
        }
        _tOwned[sender] = _tOwned[sender] - tAmount;

        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;

        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _getTValues(uint256 tAmount)
        private
        view
        returns (uint256, uint256)
    {
        //uint256 tFee = calculateTaxFee(tAmount);
        uint256 tLiquidity = (tAmount * totalSwapableFee) / 100;
        uint256 tTransferAmount = (tAmount) - tLiquidity;
        return (tTransferAmount, tLiquidity);
    }

    function _takeLiquidity(uint256 tLiquidity) private {
        _tOwned[address(this)] = _tOwned[address(this)] + tLiquidity;
        //emit Transfer(address(0), address(this), tLiquidity);
    }
//Include, Exclude from Fees and a view to confirm.
    function isExcludedFromFee(address account) external view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function excludeFromFee(address account) external onlyOwner {
        require(_isExcludedFromFee[account] != true,"Account is already excluded");
        _isExcludedFromFee[account] = true;
        emit AuditLog(
            "We have excluded the following walled in fees:",
            account
        );
    }

    function includeInFee(address account) external onlyOwner {
        require(_isExcludedFromFee[account] != false,"Account is already included");
        _isExcludedFromFee[account] = false;
        emit AuditLog("We have include the following walled in fees:", account);
    }
//Trigger Point for SwapandLiquify, Enable Swap and Manual Swap Trigger
    function setNumTokensSellToAddToLiquidity(uint256 _minimumTokensBeforeSwap)
        external
        onlyOwner
    {
        require(_minimumTokensBeforeSwap >_tTotal / 1_000_000, "setNumTokensSellToAddToLiquidity must be greater than 0.0001% of total supply");
        minimumTokensBeforeSwap = _minimumTokensBeforeSwap;
        emit Log("We have updated minimunTokensBeforeSwap to:",minimumTokensBeforeSwap);
    }

    function setSwapAndLiquifyEnabled(bool _enabled) external onlyOwner {
        require(swapAndLiquifyEnabled != _enabled , "You can't set it to a value that is already defined.");
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function manualSwap () external onlyOwner {
    swapAndLiquify();
    emit AuditLog("Owner has trigger a manual contract swap:",msg.sender);
    }
//Update of tax values
function setNewTaxes (uint256 _newMarketingFee, uint256 _newTreasuryFee, uint256 _newReserveFee, uint256 _newLiquidityFee) external onlyOwner {
require (totalSwapableFee < 15, "Fees need to be lower than 15% for the total amount.");
_liquidityFee = _newLiquidityFee;
 _treasureFee = _newTreasuryFee;
_marketingFee = _newMarketingFee;
 _reserveFee = _newReserveFee;
totalSwapableFee = _treasureFee + _liquidityFee + _marketingFee + _reserveFee;
 emit Log("We have updated the total taxes to",totalSwapableFee);

}

//Update Walllet Functions
    function seTreasureWalletAddress(address _treasureWallet)
        external
        onlyOwner
    {
        require(_treasureWallet != address(0),"seTreasureWalletAddress: ZERO");
        treasureWalletAddress = payable(_treasureWallet);
        emit AuditLog("We have Updated the treasureWallet:",treasureWalletAddress);
    }

    function setReserveWalletAddress(address _reserveWallet)
        external
        onlyOwner
    {
        require(_reserveWallet != address(0),"setReserveWalletAddress: ZERO");
        reserveWalletAddress = payable(_reserveWallet);
        emit AuditLog("We have Updated the reserveWallet:",reserveWalletAddress);
    }
    function setMarketingWalletAddress(address _marketingWallet) external onlyOwner {
        require(_marketingWallet != address(0), "setMarketingWalletAddress: ZERO");
        marketingWalletAddress = payable(_marketingWallet);
        emit AuditLog("We have Updated the marketingWallet:", marketingWalletAddress);
    }
//Dev Definitions to be used as fallback from contract.
    function transferToAddressETH(address payable recipient, uint256 amount)
        private
    {
        recipient.transfer(amount);
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    /////---dev----////
    event SwapETHForTokens(uint256 amountIn, address[] path);

    // Withdraw ETH that's potentially stuck in the Contract
    function recoverETHfromContract() public virtual onlyOwner {
        payable(treasureWalletAddress).transfer(address(this).balance);
        emit AuditLog(
            "We have recover the stock eth from contract.",
            treasureWalletAddress
        );
    }
            // Withdraw ERC20 tokens that are potentially stuck in Contract
    function recoverTokensFromContract(address _tokenAddress, uint256 _amount) external onlyOwner {   
require(_tokenAddress != address(this), "Owner can't claim contract's balance of its own tokens");	
        IERC20(_tokenAddress).transfer(treasureWalletAddress, _amount);
        emit Log("We have recovered tokens from contract:", _amount);
    }
    //Trading Controls for SAFU Contract
        function enableTrading() external onlyOwner{
        require(!tradingEnabled, "Trading already enabled.");
        tradingEnabled = true;
    }


}