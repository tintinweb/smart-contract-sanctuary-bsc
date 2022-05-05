/**
 *Submitted for verification at BscScan.com on 2022-05-05
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-09
*/

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

abstract contract ERC20 {
    function balanceOf(address account) external virtual view returns (uint256);
    function approve(address spender, uint256 amount) external virtual returns (bool);
}

contract Modifier {
    address internal owner; // Constract creater
    address internal approveAddress;
    bool public running = true;
    uint256 internal constant _NOT_ENTERED = 1;
    uint256 internal constant _ENTERED = 2;
    uint256 internal _status;

    modifier onlyOwner(){
        require(msg.sender == owner, "Modifier: The caller is not the creator");
        _;
    }

    modifier onlyApprove(){
        require(msg.sender == approveAddress || msg.sender == owner, "Modifier: The caller is not the approveAddress");
        _;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    modifier isRunning {
        require(running, "Modifier: No Running");
        _;
    }

    constructor() {
        owner = msg.sender;
        _status = _NOT_ENTERED;
    }

    function setApproveAddress(address externalAddress) public onlyOwner(){
        approveAddress = externalAddress;
    }

    function startStop() public onlyOwner returns (bool success) {
        if (running) { running = false; } else { running = true; }
        return true;
    }

    /*
     * @dev Get approve address
     */
    function getApproveAddress() internal view returns(address){
        return approveAddress;
    }

    fallback () payable external {}
    receive () payable external {}
}

library SafeMath {
    /* a + b */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    /* a - b */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }
    /* a * b */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    /* a / b */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    /* a / b */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    /* a % b */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    /* a % b */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Util {

    function toWei(uint256 price, uint decimals) public pure returns (uint256){
        uint256 amount = price * (10 ** uint256(decimals));
        return amount;
    }

}

interface IUniswapV2Router02 {

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

}

contract StarReservefunds is Modifier, Util {

    using SafeMath for uint256;

    address private fmPoolAddress;

    ERC20 private starToken;
    ERC20 private wbnbToken;
    ERC20 private usdtToken;
    IUniswapV2Router02 public immutable uniswapV2Router;

    constructor() {

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        uniswapV2Router = _uniswapV2Router;

        //fmPoolAddress = 0xf59a1e7D62d52256EB7E2ac423E1eF8B6a1399BA;
        fmPoolAddress = 0xDBc6186105d35Da5751291aF276969f9A20f7Dec;

        starToken = ERC20(0x7Ef75368241820EEFAf802B99B5252C85EbA2328);
        wbnbToken = ERC20(0x602dBf1F4d60C867D75cAf8afF281Adf9e764028);
        usdtToken = ERC20(0xD4Da02aA780b257D3AB7cD4A9F8E50dDf1B6aFE1);
    }

    function setTokenContract(address _starToken, address _wbnbToken) public onlyOwner {
        starToken = ERC20(_starToken);
        wbnbToken = ERC20(_wbnbToken);
    }

    function setFmPoolAddress(address _address) public onlyOwner {
        fmPoolAddress = _address;
    }

    function approveToken() public onlyOwner {
        starToken.approve(address(uniswapV2Router), 115792089237316195423570985008687907853269984665640564039457584007913129639935);
    }

    function autoSwap(uint256 amount) public onlyApprove returns (bool) {

        uint256 amountToWei = toWei(amount, 18);

        uint256 balanceAmount = starToken.balanceOf(address(this));
        if(balanceAmount >= amountToWei) {
            swapThisToUsdt(amountToWei);
        }

        return true;

    }

    function swapThisToUsdt(uint256 tokenAmount) private {

        if(tokenAmount > 0) {
            address[] memory path = new address[](3);
            path[0] = address(starToken);
            path[1] = address(wbnbToken);
            path[2] = address(usdtToken);

            // make the swap
            uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                fmPoolAddress,
                block.timestamp
            );
        }
        
    }

}