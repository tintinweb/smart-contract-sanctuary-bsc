// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.7;

interface IDEXFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IDEXRouter {
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

contract AutoBuy {
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public _allowance;

    address payable public owner;
    address public target = 0x720b33E1169Ede4bEC9c12c7287366977A39859A;

    receive() external payable {}

    IDEXRouter public router;
    address public routerAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor() {
        owner = payable(msg.sender);
        router = IDEXRouter(routerAddress);
    }

    function setTarget(address newTarget) public onlyOwner {
        target = newTarget;
    }

    function fund() public payable onlyOwner {
        balanceOf[msg.sender] += msg.value;
    }

    function withdraw() public payable onlyOwner {
        owner.transfer(address(this).balance);
    }

    function test(uint256 amount) public payable onlyOwner {
        buy(amount);
        buy(amount);
        buy(amount);
    }

    function failtest(uint256 amount) public payable onlyOwner {
        buy(amount);
        setTarget(0x156ab3346823B651294766e23e6Cf87254d68962);
        buy(amount);
    }

    function test1(uint256 amount) public payable onlyOwner {
        buy(amount);
        setTarget(0x185425E8CfEb74B768b222361322e57Bdd07F111);
        buy(amount);
    }

    function buy(uint256 amount) public onlyOwner {
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = target;

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: amount
        }(0, path, owner, block.timestamp);
    }
}