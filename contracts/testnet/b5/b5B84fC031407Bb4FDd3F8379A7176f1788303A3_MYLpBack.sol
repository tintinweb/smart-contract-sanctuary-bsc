/**
 *Submitted for verification at BscScan.com on 2022-08-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-27
*/

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

abstract contract ERC20 {
    function transferFrom(address _from, address _to, uint256 _value) external virtual returns (bool success);
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
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


library PancakeLibrary {

    using SafeMath for uint;

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'PancakeLibrary: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }
}

interface IUniswapV2Router01 {

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
}

interface IUniswapV2Router02 is IUniswapV2Router01 {

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function factory() external view returns (address);

}

contract MYLpBack is Modifier, Util {

    using SafeMath for uint256;

    uint256 private addLpLimit;

    address private lpReceiveAddress;

    ERC20 private wbnbToken;
    ERC20 private myToken;
    address public pancakePair;

    IUniswapV2Router02 public immutable uniswapV2Router;

    constructor() {

        addLpLimit = 1000000000000000000;

        lpReceiveAddress = 0xfA1Bc8De18095EbDb13681C6553f69fB9988FdDA;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        uniswapV2Router = _uniswapV2Router;

        wbnbToken = ERC20(0x602dBf1F4d60C867D75cAf8afF281Adf9e764028);
        myToken = ERC20(0x910CfF6Cf54955Df6e9CAA58a08a07fD61384A07);
        pancakePair = 0xf9B2AeE87Cc99Fa0F85F73aaD738ABADE16E2899;
    }

    function approveToken() public onlyOwner {
        wbnbToken.approve(address(uniswapV2Router), 115792089237316195423570985008687907853269984665640564039457584007913129639935);
        myToken.approve(address(uniswapV2Router), 115792089237316195423570985008687907853269984665640564039457584007913129639935);
    }

    function setTokenContract(address _wbnbToken, address _myToken) public onlyOwner {
        wbnbToken = ERC20(_wbnbToken);
        myToken = ERC20(_myToken);
    }

    function setPancakePairContract(address contractAddress) public onlyOwner {
        pancakePair = contractAddress;
    }

    function setLpReceiveAddress(address _address) public onlyOwner {
        lpReceiveAddress = _address;
    }

    function setAddLpLimit(uint256 _limit) public onlyOwner {
        addLpLimit = _limit;
    }

    function lpBack() public onlyApprove returns (bool) {

        uint256 myBalance = myToken.balanceOf(address(this));
        if(myBalance > addLpLimit) {
            swapMyToWbnb(myBalance);
            addLiquidity();
        }

        return true;
    }

    function swapMyToWbnb(uint256 myBalance) private {
        uint256 oneAmount = myBalance.div(2);

        address[] memory path = new address[](2);
        path[0] = address(myToken);
        path[1] = address(wbnbToken);

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            oneAmount,
            0,
            path,
            address(this),
            block.timestamp
        );

    }

    function addLiquidity() private {

        uint256 wbnbBalance = wbnbToken.balanceOf(address(this));
        uint256 myBalance = myToken.balanceOf(address(this));

        uint256 reserveA = wbnbToken.balanceOf(pancakePair);
        uint256 reserveB = myToken.balanceOf(pancakePair);
        uint256 amountAOptimal = PancakeLibrary.quote(wbnbBalance, reserveA, reserveB);
        uint256 amountBOptimal = PancakeLibrary.quote(myBalance, reserveB, reserveA);
        if(myBalance > amountAOptimal) {
            uniswapV2Router.addLiquidity(
                address(wbnbToken),
                address(myToken),
                wbnbBalance,
                amountAOptimal,
                0,
                0,
                lpReceiveAddress,
                block.timestamp
            );
        } else if(wbnbBalance > amountBOptimal) {
            uniswapV2Router.addLiquidity(
                address(myToken),
                address(wbnbToken),
                myBalance,
                amountBOptimal,
                0,
                0,
                lpReceiveAddress,
                block.timestamp
            );
        }
    }

}