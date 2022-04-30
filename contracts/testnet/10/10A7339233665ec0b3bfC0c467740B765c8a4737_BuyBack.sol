// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// import "./pancakeswap_interface/IPancakeRouter.sol";

interface IPancakeRouter {

    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address to, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract BuyBack {
    //代币地址
    address private _tokenAddress = 0x8c57765a9fAEe0392604c1aca3ff763Da7716093;

    //最小回购数量
    uint256 private _minBuyBackAmount;

    //pancakerouter 实例
    IPancakeRouter _router;
    //代币实例
    IERC20 _token;
    //接收BNB的地址
    address _receiveAddress = 0xe7C78292e78772be49902A59d2C6612a5d2C6393;

    constructor() {
        _minBuyBackAmount = 100 * 10**6;
        _router = IPancakeRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        _token = IERC20(_tokenAddress);
    }

    receive() external payable {}

    function buyBack() public returns (bool) {
        require(
            _token.balanceOf(address(this)) >= _minBuyBackAmount,
            "buyBack amount is not enough"
        );
        address[] memory path = new address[](2);
        path[0] = address(_tokenAddress);
        path[1] = _router.WETH();
        _token.approve(address(_router), _token.balanceOf(address(this)));
        //调用pancakerouter把token兑换成WBNB的
        _router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            _token.balanceOf(address(this)),
            0,
            path,
            _receiveAddress,
            block.timestamp
        );
        return true;
    }

    //
    function getBalance() public view returns (uint256, address) {
        return (_token.balanceOf(address(this)), _router.WETH());
    }
}