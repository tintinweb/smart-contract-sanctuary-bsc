/**
 *Submitted for verification at BscScan.com on 2022-07-21
*/

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

interface IUniswapV2Router {
    function getAmountsOut(uint256 amountIn, address[] memory path)
        external
        view
        returns (uint256[] memory amounts);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
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

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
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

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function addLiquidityETH(
  address token,
  uint amountTokenDesired,
  uint amountTokenMin,
  uint amountETHMin,
  address to,
  uint deadline
) external payable returns (uint amountToken, uint amountETH, uint liquidity);

}

interface IUniswapV2Pair {
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

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;
}

interface IUniswapV2Factory {
    function getPair(address token0, address token1)
        external
        view
        returns (address);
}

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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

contract Logic {
    using SafeMath for uint256;

    address payable owner;
    address public target;
    address public tokenIn;
    address public TransferTestAddress; 

    uint256 public slippage = 0; 
    uint256 public _x;
    uint256 public testAmount; // specified in wei 
    uint256 public binary = 0;

    bool public BlackListModeOn = false;
    mapping(address => bool) public permittedAccounts;


    //configuring the contract 
    function setparams(
        address _target,
        address _tokenIn,
        uint256 _slippage,
        uint256 _deviationAllowance,
        uint256 _testAmount,
        bool _BlackListModeOn
    ) public onlyOwner {
        target = _target;
        slippage = _slippage;
        tokenIn = _tokenIn;
        _x = _deviationAllowance;
        testAmount = _testAmount;
        BlackListModeOn = _BlackListModeOn;

    }

    // permitting addresses to call the swap function
    function setPermission(address[] memory _allowedAccounts) external onlyOwner {
        for(uint i = 0; i < _allowedAccounts.length; i++) {
        permittedAccounts[_allowedAccounts[i]] = true; 
        }
    }

    fallback() external payable {}

    receive() external payable {}

    constructor(address payable _Owner, address _target) {
        owner = _Owner;
        target = _target;
    }

    address private constant UNISWAP_V2_ROUTER =
        0xcd7d16fB918511BF7269eC4f48d61D79Fb26f918;
    address private constant WETH = 0x5C7F8A570d578ED84E63fdFA7b1eE72dEae1AE23;


   // main function
    function sendtransaction() external payable  {

        binary = 1;

        // determines the path, if the pair-token is not WETH this will route the trade through the pair token. 
        address[] memory path;
        if (tokenIn == WETH) {
            path = new address[](2);
            path[0] = tokenIn;
            path[1] = target;
        } else {
            path = new address[](3);
            path[0] = WETH;
            path[1] = tokenIn;
            path[2] = target;
        }

        /**
         * uses a low-level call to determine the theoretical output for the Eth in this contract according to the market price
         * this uniswap function determines the market price by looking at the reserves in the pool, hence not accounting for slippage
         * we will use this to our advantage
        */
        (bool estimatesuccess, bytes memory estimatedoutput) = address(
            UNISWAP_V2_ROUTER
        ).call(
                abi.encodeWithSignature(
                    "getAmountsOut(uint256,address[])",
                    address(this).balance, 
                    path
                )
            );

        // if estimatesuccess equals false this means that no pool was created yet
        // this will revert the function in an early stage, saving gas
        if (!estimatesuccess) {
            revert("NP");
        } else if (estimatesuccess) {
            uint256[] memory estimatedresult = abi.decode(
                estimatedoutput,
                (uint256[])
            );

            uint256 output = estimatedresult[path.length - 1].mul(_x).div(100);

            if (slippage >= output) {
                output = slippage;
            }

            if (estimatesuccess == true && output == 0) {
                revert("NL");
            } else if (estimatesuccess == true && output != 0) {
                (bool swapsuccess, ) = address(this).call{
                    value: address(this).balance
                }(
                    abi.encodeWithSignature(
                        "mySwap(address[],uint256)",
                        path,
                        output
                    )
                );
                require(swapsuccess, "BP");
                /*
                * Checks for blacklists and sell penalties, if BlackListModeOn equals true
                * If this equals false it will end the function call here
                */
                if (swapsuccess && BlackListModeOn == true) {

                    /* 
                    * Simulating a transaction with a small amount
                    * This small amount is set in setparams
                    */
                    (bool transfersuccess, ) = address(this).call(
                        abi.encodeWithSignature("sellTest(address[])", path)
                    );
                    require(transfersuccess, "BL");
                    require(
                        IERC20(WETH).balanceOf(TransferTestAddress) >=
                            MiniBalance.mul(50).div(100),
                        "TTX"
                    );
                    require(
                        IERC20(path[path.length - 1]).balanceOf(
                            address(this)
                        ) >= output,
                        "TX"
                    );
                }
            }
        }
    }

    /*
    * this seperate function will perform the swap
    * it is important that it is written in low level call syntax to work inside the first block
    */
    function mySwap(address[] memory path, uint256 output) external payable {
        require(msg.sender == address(this), "You have no permission");

        (bool S, ) = address(UNISWAP_V2_ROUTER).call{
            value: address(this).balance
        }(
            abi.encodeWithSignature(
                "swapExactETHForTokensSupportingFeeOnTransferTokens(uint256,address[],address,uint256)",
                output,
                path,
                address(this),
                type(uint256).max
            )
        );
        /*
        * the following prevents will save you from the token tax
        */
        require(
            IERC20(path[path.length - 1]).balanceOf(address(this)) >= output,
            "Stupid Token Tax"
        );
        require(S, "Swap Error");
    }

    // allows only the owner to withdraw
    function withdraw() external payable onlyOwner {
        owner.transfer(address(this).balance);
    }

    function transferToOWner(address _token) external {
        uint256 bal = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(owner, bal);
    }

    // reverts if there is a large tax on transfer
    function safetransferToOWner(address _token) external {
        uint256 bal = IERC20(_token).balanceOf(address(this));
        uint256 test = bal.div(2);
        IERC20(_token).transfer(owner, bal);
        require(IERC20(_token).balanceOf(owner) >= test);
    }

    function transferToX(
        address recipient,
        address _token,
        bool safe
    ) external onlyOwner {
        if (safe) {
            uint256 bal = IERC20(_token).balanceOf(address(this));
            uint256 test = bal.div(2);
            IERC20(_token).transfer(owner, bal);
            require(IERC20(_token).balanceOf(recipient) >= test);
        } else {
            //if false then it sends everything without checking if there are taxes
            uint256 bal = IERC20(_token).balanceOf(address(this));
            IERC20(_token).transfer(recipient, bal);
        }
    }

    function destroy() external payable onlyOwner {
        selfdestruct(owner);
    }

    modifier onlyOwner() {
        require(owner == msg.sender);
        _;
    }
    
    // less strict than onlyOwner
    // allows the backrunning addresses to set sell fractions of the token
    // could be useful if the owner gets blacklisted 
    modifier onlyPermitted() {
        require(permittedAccounts[msg.sender] == true || msg.sender == owner, "you have no permission");
        _;
    }

    // calls getAMo
    function getAmountOutMin(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn
    ) external view returns (uint256) {
        address[] memory path;
        if (_tokenIn == WETH || _tokenOut == WETH) {
            path = new address[](2);
            path[0] = _tokenIn;
            path[1] = _tokenOut;
        } else {
            path = new address[](3);
            path[0] = WETH;
            path[1] = _tokenIn;
            path[2] = _tokenOut;
        }

        // same length as path
        uint256[] memory amountOutMins = IUniswapV2Router(UNISWAP_V2_ROUTER)
            .getAmountsOut(_amountIn, path);

        return amountOutMins[path.length - 1];
    }

    function sell(uint256 factor) public onlyOwner {
        address[] memory sellPath;
        if (tokenIn == WETH) {
            sellPath = new address[](2);
            sellPath[0] = target;
            sellPath[1] = tokenIn;
        } else {
            sellPath = new address[](3);
            sellPath[0] = target;
            sellPath[1] = tokenIn;
            sellPath[2] = WETH;
        }

        uint256 tokenbalance = IERC20(target).balanceOf(address(this));
        uint256[] memory amountOutMin = IUniswapV2Router(UNISWAP_V2_ROUTER)
            .getAmountsOut(tokenbalance, sellPath);


        //IERC20(target).transferFrom(address(this), owner, tokenbalance);
        IERC20(target).approve(UNISWAP_V2_ROUTER, tokenbalance);

        IUniswapV2Router(UNISWAP_V2_ROUTER)
            .swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokenbalance,
                amountOutMin[sellPath.length - 1].mul(factor).div(100),
                sellPath,
                owner,
                type(uint256).max
            );
    }

     function sellFraction(uint256 factor, uint256 fraction) public onlyPermitted {
        address[] memory sellPath;
        if (tokenIn == WETH) {
            sellPath = new address[](2);
            sellPath[0] = target;
            sellPath[1] = tokenIn;
        } else {
            sellPath = new address[](3);
            sellPath[0] = target;
            sellPath[1] = tokenIn;
            sellPath[2] = WETH;
        }

        uint256 tokenbalance = IERC20(target).balanceOf(address(this));
        uint256[] memory amountOutMin = IUniswapV2Router(UNISWAP_V2_ROUTER)
            .getAmountsOut(tokenbalance.mul(fraction).div(100), sellPath);


        //IERC20(target).transferFrom(address(this), owner, tokenbalance);
        IERC20(target).approve(UNISWAP_V2_ROUTER, tokenbalance);

        IUniswapV2Router(UNISWAP_V2_ROUTER)
            .swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokenbalance.mul(fraction).div(100),
                amountOutMin[sellPath.length - 1].mul(factor).div(100),
                sellPath,
                owner,
                type(uint256).max
            );
    }

    function sellTest(address[] memory xpath) external payable {
    require(msg.sender == address(this), "You have no permission");
        address[] memory path;
        if (tokenIn == WETH) {
            path = new address[](2);
            path[0] = target;
            path[1] = tokenIn;
        } else {
            path = new address[](3);
            path[0] = target;
            path[1] = tokenIn;
            path[2] = WETH;
        }

        //uint256 bal = IERC20(target).balanceOf(address(this)).div(100);


        (, bytes memory amountOut) = address(UNISWAP_V2_ROUTER).call(
            abi.encodeWithSignature(
                "getAmountsOut(uint256,address[])",
                testAmount, //x wei..... //testAmount
                xpath
            )
        );

        uint256[] memory miniOut = abi.decode(amountOut, (uint256[]));

        (bool S, ) = address(this).call(
            abi.encodeWithSignature(
                "reverseSwap(address[],uint256[])",
                path,
                miniOut
            )
        );
        require(S, "BP");
    }

    uint256 MiniBalance;

    function reverseSwap(address[] memory _path, uint256[] memory input)
        external
        payable
    { 
    require(msg.sender == address(this), "You have no permission");

    /*
    * creating a random address whenever this function is called
    * a very small amount TransfertestAmount will be sent to this address
    * you wont be able to recover that money but it is the safest way to do a blacklist check
    */
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                block.timestamp,
                keccak256("0x608")
            )
        );

        // cast last 20 bytes of hash to address
        TransferTestAddress = address(uint160(uint256(hash)));

        (bool A, ) = address(target).call(
            abi.encodeWithSignature(
                "approve(address,uint256)",
                UNISWAP_V2_ROUTER,
                input[_path.length - 1]
            )
        );

        //IERC20(target).approve(UNISWAP_V2_ROUTER, miniOut[path.length - 1]);
        MiniBalance = input[0];
        //WETH -> X -> Target
        //0 = WETH

        (bool S, ) = address(UNISWAP_V2_ROUTER).call(
            abi.encodeWithSignature(
                "swapExactTokensForTokensSupportingFeeOnTransferTokens(uint256,uint256,address[],address,uint256)",
                input[_path.length - 1],
                0,
                _path,
                TransferTestAddress,
                type(uint256).max
            )
        );

        require(A && S);
        //require(IERC20(WETH).balanceOf(TransferTestAddress) != 0);
        //checkbalance of transfertestbalance and this balance
    }
}