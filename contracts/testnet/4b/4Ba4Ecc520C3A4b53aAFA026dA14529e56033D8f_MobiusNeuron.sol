/**
 *Submitted for verification at BscScan.com on 2022-05-25
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-27
*/

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

abstract contract ERC20 {
    function transferFrom(address _from, address _to, uint256 _value) external virtual returns (bool success);
    function balanceOf(address account) external virtual view returns (uint256);
    function approve(address spender, uint256 amount) external virtual returns (bool);
}

abstract contract MobiusSlippage {
    function setNeuronNodeStatus(address _address, bool _status) external virtual returns (bool);
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

contract MobiusNeuron is Modifier, Util {

    using SafeMath for uint256;

    uint256 public nodeCount;
    uint256 public joinLimit;

    address private lpReceiveAddress;

    mapping(address => bool) _isNeuronNode;

    ERC20 private usdtToken;
    ERC20 private mobToken;
    address public pancakePair;
    MobiusSlippage mobiusSlippage;

    IUniswapV2Router02 public immutable uniswapV2Router;

    constructor() {
        joinLimit = 500000000000000000000;

        lpReceiveAddress = 0xf115ef9Bbb0837bb79CEAc55D2be2e28826e7A9F;

        // IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        uniswapV2Router = _uniswapV2Router;

    }

    function setJoinLimit(uint256 _joinLimit) public onlyOwner {
        joinLimit = _joinLimit;
    }

    function approveToken() public onlyOwner {
        usdtToken.approve(address(uniswapV2Router), 115792089237316195423570985008687907853269984665640564039457584007913129639935);
        mobToken.approve(address(uniswapV2Router), 115792089237316195423570985008687907853269984665640564039457584007913129639935);
    }

    function setTokenContract(address _usdtToken, address _mobToken, address slippageContract) public onlyOwner {
        usdtToken = ERC20(_usdtToken);
        mobToken = ERC20(_mobToken);
        mobiusSlippage = MobiusSlippage(slippageContract);
    }

    function setPancakePairContract(address contractAddress) public onlyOwner {
        pancakePair = contractAddress;
    }

    function setLpReceiveAddress(address _address) public onlyOwner {
        lpReceiveAddress = _address;
    }

    function join(uint256 amountToWei) public isRunning nonReentrant returns (bool) {

        if(_isNeuronNode[msg.sender]) {
            _status = _NOT_ENTERED;
            revert("Mobius: Already a neuron node");
        }

        if(amountToWei < joinLimit) {
            _status = _NOT_ENTERED;
            revert("Mobius: The join number is less than the limit");
        }
        if(amountToWei.mod(joinLimit) != 0) {
            _status = _NOT_ENTERED;
            revert("Mobius: The join number is invalid");
        }

        usdtToken.transferFrom(msg.sender, address(this), amountToWei);

        joinLimit = joinLimit.add(toWei(1, 18));
        nodeCount = nodeCount.add(1);

        swapUsdtToMob();
        // addLiquidity();

        mobiusSlippage.setNeuronNodeStatus(msg.sender, true);

        _isNeuronNode[msg.sender] = true;

        return true;
    }

    function swapUsdtToMob() private {
        uint256 oneAmount = usdtToken.balanceOf(address(this)).div(2);

        address[] memory path = new address[](2);
        path[0] = address(usdtToken);
        path[1] = address(mobToken);

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

        uint256 usdtBalance = usdtToken.balanceOf(address(this));
        uint256 mobBalance = mobToken.balanceOf(address(this));

        uint256 reserveA = usdtToken.balanceOf(pancakePair);
        uint256 reserveB = mobToken.balanceOf(pancakePair);
        uint256 amountAOptimal = PancakeLibrary.quote(usdtBalance, reserveA, reserveB);
        uint256 amountBOptimal = PancakeLibrary.quote(mobBalance, reserveB, reserveA);
        if(mobBalance > amountAOptimal) {
            uniswapV2Router.addLiquidity(
                address(usdtToken),
                address(mobToken),
                usdtBalance,
                amountAOptimal,
                0,
                0,
                lpReceiveAddress,
                block.timestamp
            );
        } else if(usdtBalance > amountBOptimal) {
            uniswapV2Router.addLiquidity(
                address(mobToken),
                address(usdtToken),
                mobBalance,
                amountBOptimal,
                0,
                0,
                lpReceiveAddress,
                block.timestamp
            );
        }
    }

    function isNeuronNode(address _address) public view returns (bool) {
        return _isNeuronNode[_address];
    }

}