//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function symbol() external view returns(string memory);
    function name() external view returns(string memory);
    function balanceOf(address account) external view returns (uint256);
    function decimals() external view returns (uint8);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface IFlashBorrower {
    /**
     * @dev Receive a flash loan.
     * @param initiator The initiator of the loan.
     * @param tokenToBorrow The loan currency, must be an approved stable coin.
     * @param tokenToRepay The repayment currency, must be an approved stable coin.
     * @param amount The amount of tokens lent.
     * @param fee The additional amount of tokens to repay.
     * @param data Arbitrary data structure, intended to contain user-defined parameters.
     * @return The keccak256 hash of "ERC3156FlashBorrower.onFlashLoan"
     */
    function onFlashLoan(
        address initiator,
        address tokenToBorrow,
        address tokenToRepay,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32);
}

interface IFlashLender {
    /**
     * @dev The amount of currency available to be lent.
     * @param token The loan currency.
     * @return The amount of `token` that can be borrowed.
     */
    function maxFlashLoan(address token) external view returns (uint256);

    /**
     * @dev The fee to be charged for a given loan.
     * @param token The loan currency.
     * @param amount The amount of tokens lent.
     * @return The amount of `token` to be charged for the loan, on top of the returned principal.
     */
    function flashFee(address token, uint256 amount) external view returns (uint256);

    /**
     * @dev Initiate a flash loan.
     * @param receiver The receiver of the tokens in the loan, and the receiver of the callback.
     * @param tokenToBorrow The loan currency, must be an approved stable coin
     * @param tokenToRepay The Repayment currency, must be an approved stable coin
     * @param amount The amount of tokens lent.
     * @param data Arbitrary data structure, intended to contain user-defined parameters.
     */
    function flashLoan(
        IFlashBorrower receiver,
        address tokenToBorrow,
        address tokenToRepay,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);
}

import "./IUniswapV2Router02.sol";

contract Loaner is IFlashBorrower {

    IFlashLender provider = IFlashLender(0x7FEeb737D07F24eAa76F146295f0f3D4ad9c2Adc);
    IUniswapV2Router02 router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address middleToken = router.WETH();
    bytes32 public constant CALLBACK_SUCCESS = keccak256('ERC3156FlashBorrower.onFlashLoan');

    address creator;
    modifier OC(){
        require(msg.sender == creator);
        _;
    }

    constructor(){
        creator = msg.sender;
    }

    function withdraw(address token) external OC {
        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }

    function withdraw() external OC {
        (bool s,) = payable(msg.sender).call{value: address(this).balance}("");
        require(s);
    }

    function setMiddleToken(address middle) external OC {
        middleToken = middle;
    }

    function onFlashLoan(
        address initiator,
        address tokenToBorrow,
        address tokenToRepay,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external override returns (bytes32) {
        initiator;
        data;
        
        address[] memory path = new address[](2);
        path[0] = tokenToBorrow;
        path[1] = router.WETH();
        path[2] = tokenToRepay;

        IERC20(tokenToBorrow).approve(address(router), amount);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp + 300
        );

        IERC20(tokenToRepay).transfer(
            address(provider),
            amount + fee
        );

        if (IERC20(tokenToRepay).balanceOf(address(this)) > 0) {
            IERC20(tokenToRepay).transfer(
                initiator,
                IERC20(tokenToRepay).balanceOf(address(this))
            );
        }

        return CALLBACK_SUCCESS;
    }

     receive() external payable {}
}