/**
 *Submitted for verification at BscScan.com on 2022-10-05
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

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

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

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

interface IERC20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

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
}

contract Arbitrage {
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    mapping(address => uint256) public executors;
    address public owner;
    address public constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public constant ANCHOR = 0x4aac18De824eC1b553dbf342829834E4FF3F7a9F;
    IPancakeRouter02 public router;

    modifier onlyOwner() {
        require(owner == msg.sender, "not the owner");
        _;
    }

    modifier onlyExecutor() {
        require(executors[msg.sender] > 0, "not the executor");
        _;
    }

    constructor() {
        _transferOwnership(msg.sender);

        router = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    }

    function buyAnchor(address token, uint256 out_amount) public onlyExecutor {
        address[] memory paths = new address[](2);
        paths[0] = token;
        paths[1] = ANCHOR;
        uint256[] memory in_amounts = router.getAmountsIn(out_amount, paths);
        if (token == WBNB) {
            router.swapExactETHForTokensSupportingFeeOnTransferTokens{
                value: in_amounts[0]
            }(0, paths, address(this), block.timestamp + 600);
        } else {
            IERC20(token).approve(address(router), in_amounts[0]);
            router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                in_amounts[0],
                out_amount,
                paths,
                address(this),
                block.timestamp + 600
            );
        }
    }

    function sellAnchor(address token) public onlyExecutor {
        address[] memory paths = new address[](2);
        paths[0] = ANCHOR;
        paths[1] = token;
        uint256 token_amount = IERC20(ANCHOR).balanceOf(address(this));
        IERC20(ANCHOR).approve(address(router), token_amount);
        if (token == WBNB) {
            router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                token_amount,
                0,
                paths,
                address(this),
                block.timestamp + 600
            );
        } else {
            router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                token_amount,
                0,
                paths,
                address(this),
                block.timestamp + 600
            );
        }
    }

    function setExecutorState(address executor) public onlyOwner {
        executors[executor] = 1 - executors[executor];
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        address oldOwner = owner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function withdraw(address token) external onlyOwner {
        if (token == address(0)) {
            uint256 balance = address(this).balance;
            (bool success, ) = msg.sender.call{value: balance}("");
            require(success, "withdraw failed");
        } else {
            uint256 balance = IERC20(token).balanceOf(address(this));
            IERC20(token).transfer(msg.sender, balance);
        }
    }

    receive() external payable {}
}