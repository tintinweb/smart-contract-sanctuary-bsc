// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "IPancakeRouter02.sol";
import "IPancakePair.sol";
import "IERC20.sol";
import "IWETH.sol";
import "IERC3156FlashBorrower.sol";
import "Ownable.sol";


contract SathnaStableArb is Ownable, IERC3156FlashBorrower{

    address wrappedNative;
    address Beneficiary;
    address bank;

    RouterArgs[] routerArgsList;

    constructor(address _wrappedNative, address _Beneficiary, address _bank) public {
        wrappedNative = _wrappedNative;
        Beneficiary = _Beneficiary;
        bank = _bank;

    }
    function changeWrappedNative(address _wrappedNative) external onlyOwner {
        wrappedNative = _wrappedNative;
    }
    function changeBeneficiary(address _beneficiary) external onlyOwner {
        Beneficiary = _beneficiary;
    }
    function changeBank(address _bank) external onlyOwner {
        bank = _bank;
    }

    function getBank() view public onlyOwner returns(address) {

        return bank;
    }

    function getBeneficiary() view public onlyOwner returns(address) {

        return Beneficiary;
    }
    function getWrappedNative() view public onlyOwner returns(address) {

        return wrappedNative;
    }


    struct RouterArgs {
        address tokenIn; 
        address tokenOut;
        uint amountIn;
        uint amountOutMin;
        address router;
        uint16 timeOutSecs;
    }

    event BalanceChanged(uint256 tokenA, uint256 tokenB);

    // to receive native from external contracts
    receive() payable external{}

    // just returns amountIn or balance of a token that contract stored
    function getAmountIn(IERC20 _tokenIn, uint _amountIn) private returns(uint) {
        
        if (_amountIn == 0) {

            return _tokenIn.balanceOf(address(this));
            
        }
        else {
            return _amountIn;
        }
        
        

    } 

    // just do a swap on UniswapV2 like exchanges
    function swapExactInputForOutput(
        RouterArgs memory routerArgs
        )

     private {
        // Initialize router and tokens
        address[] memory path = new address[](2);
        path[0] =   routerArgs.tokenIn;
        path[1] = routerArgs.tokenOut;
        

        IERC20 tokenIn = IERC20(routerArgs.tokenIn);
        IERC20 tokenOut = IERC20(routerArgs.tokenOut);
        IPancakeRouter02 router = IPancakeRouter02(routerArgs.router);

        uint amountIn = getAmountIn(tokenIn, routerArgs.amountIn);

        if (tokenIn.allowance(address(this), address(router)) < amountIn) {
            require(tokenIn.approve(address(router), amountIn), "Approval Failed");
        }
        
        
        uint deadline = block.timestamp + routerArgs.timeOutSecs; // e.d. timeOutSecs=10,  10 secs
        // swapping
        router.swapExactTokensForTokens(amountIn, routerArgs.amountOutMin, path, address(this), deadline);
        
        emit BalanceChanged(tokenIn.balanceOf(address(this)), tokenOut.balanceOf(address(this)));

    }
    
    // merge all deals in a single for loop
    function swapThemAll() public {
        
        require(address(msg.sender) == bank || address(msg.sender) == owner(), "YOU SHALL NOT PASS!");
        
        for (uint i=0; i <routerArgsList.length; i++ ) {
            
            swapExactInputForOutput(routerArgsList[i]);


        }
    }


    // filling routerArgsList variable
    function fillRouterArgsList(RouterArgs[] memory _routerArgsList) external onlyOwner {
        
        // delete all previous elements from routerArgsList
        if (routerArgsList.length>0) {
            delete routerArgsList;
        }

        for(uint256 i = 0; i < _routerArgsList.length; i++)
            routerArgsList.push(_routerArgsList[i]);
        } 


    // withdraw funds
    function withdraw(uint percentFee) onlyOwner external  {

        // casting all currencies to the wrapped native
        castToWrappedNative();
        
        IWETH WRAPPED = IWETH(wrappedNative);

        address payable owner = payable(owner());
        address payable ben = payable(Beneficiary);
        uint balance = WRAPPED.balanceOf(address(this));
        WRAPPED.withdraw(balance);
        uint gasFee = address(this).balance * percentFee / 100;
        owner.transfer(gasFee);
        ben.transfer(address(this).balance);

    }

    // casting all lefted currencies to the wrapped native
    function castToWrappedNative() private {
        
        for (uint i=0; i <routerArgsList.length; i++ ) {

            IWETH WRAPPED = IWETH(wrappedNative);
            IERC20 tokenIn = IERC20(routerArgsList[i].tokenIn);
            IERC20 tokenOut = IERC20(routerArgsList[i].tokenOut);
            address routerAddress = routerArgsList[i].router;
            
            uint tokenInBalance = tokenIn.balanceOf(address(this));
            uint tokenOutBalance = tokenOut.balanceOf(address(this));

            if (tokenInBalance > 0 && address(tokenIn) != address(WRAPPED))
            {

                swapExactInputForOutput(
                    RouterArgs(
                        address(tokenIn),
                        address(WRAPPED),
                        tokenInBalance,
                        0,
                        routerAddress,
                        routerArgsList[i].timeOutSecs
                    )
                );
                emit BalanceChanged(tokenIn.balanceOf(address(this)), WRAPPED.balanceOf(address(this)));

            }

            else if (tokenOutBalance > 0 && address(tokenOut) != address(WRAPPED))
            {

                swapExactInputForOutput(
                    RouterArgs(
                        address(tokenOut),
                        address(WRAPPED),
                        tokenOutBalance,
                        0,
                        routerAddress,
                        routerArgsList[i].timeOutSecs
                    )
                );

                emit BalanceChanged(tokenOut.balanceOf(address(this)), WRAPPED.balanceOf(address(this)));

            }

        }
    }


    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
        // RouterArgs[] memory routerArgsList
    ) external override returns (bytes32) {
        

        // Set the allowance to payback the flash loan
        IERC20(token).approve(address(msg.sender), amount);
        
        // Build your trading business logic here
        swapThemAll();
        emit BalanceChanged(IERC20(token).balanceOf(address(this)), 0);

        // Return success to the lender, he will transfer get the funds back if allowance is set accordingly
        return keccak256('ERC3156FlashBorrower.onFlashLoan');
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.2;

import "IPancakeRouter01.sol";

interface IPancakeRouter02 is IPancakeRouter01 {
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

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.2;

interface IPancakeRouter01 {
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

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

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
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
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

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

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

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IWETH {

    function deposit() external payable;
    function withdraw(uint) external;
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (interfaces/IERC3156FlashBorrower.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC3156 FlashBorrower, as defined in
 * https://eips.ethereum.org/EIPS/eip-3156[ERC-3156].
 *
 * _Available since v4.1._
 */
interface IERC3156FlashBorrower {
    /**
     * @dev Receive a flash loan.
     * @param initiator The initiator of the loan.
     * @param token The loan currency.
     * @param amount The amount of tokens lent.
     * @param fee The additional amount of tokens to repay.
     * @param data Arbitrary data structure, intended to contain user-defined parameters.
     * @return The keccak256 hash of "IERC3156FlashBorrower.onFlashLoan"
     */
    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "Context.sol";

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