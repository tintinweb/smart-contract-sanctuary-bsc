/**
 *Submitted for verification at BscScan.com on 2022-06-06
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    

}

interface Uni {
    function swapExactTokensForTokens(
        uint256,
        uint256,
        address[] calldata,
        address,
        uint256
    ) external;
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
}


contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }
    
    //Added function
    // 1 minute = 60
    // 1h 3600
    // 24h 86400
    // 1w 604800
    
    function getTime() public view returns (uint256) {
        return block.timestamp;
    }

    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

contract ALC is Ownable{

    address public constant uniRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // Live
    address public BUSD = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); // Live
    address public SSID = address(0xC3241e111CCd9CF6c5a11dADE9498070082F2ed3); // Live

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    event SwapAndLiquifyOwner(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    function swapAndLiquify(uint256 contractTokenBalance) public {
        uint256 half = contractTokenBalance / 2;
        emit SwapAndLiquify(half, 0, half);
    }

    function swapAndLiquifyOwner() public{
        uint256 half = IERC20(SSID).balanceOf(address(this)) / 2;
        swapTokensForBUSD(half);

        // how much ETH did we just swap into?
        uint256 newBalance = IERC20(BUSD).balanceOf(address(this));

        // add liquidity to uniswap
        addLiquidity(half, newBalance);

        emit SwapAndLiquifyOwner(half, newBalance, half);
    }

    function setAddress(address _busd, address _ssid) external onlyOwner{
        BUSD = _busd;
        SSID = _ssid;
    }

    function addLiquidity(uint256 token0Amt, uint256 token1Amt) public {
        
        if(token0Amt > 0 && token1Amt > 0) {
            IERC20(SSID).approve(uniRouter, 0);
            IERC20(SSID).approve(uniRouter, 115792089237316195423570985008687907853269984665640564039457584007913129639935);
            IERC20(BUSD).approve(uniRouter, 0);
            IERC20(BUSD).approve(uniRouter, 115792089237316195423570985008687907853269984665640564039457584007913129639935);
            Uni(uniRouter).addLiquidity(
                SSID,
                BUSD,
                token0Amt,
                token1Amt,
                0,
                0,
                address(this),
                block.timestamp
            );
        }
    }

    function swapTokensForBUSD(uint256 tokenAmount) public {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = SSID;
        path[1] = BUSD;

        IERC20(SSID).approve(uniRouter, 0);
        IERC20(SSID).approve(uniRouter, 115792089237316195423570985008687907853269984665640564039457584007913129639935);
        // make the swap
        Uni(uniRouter).swapExactTokensForTokens(
            tokenAmount,
            0, // accept any amount of BUSD
            path,
            address(this),
            block.timestamp + (1800)
        );
    }

    function withdraw(IERC20 _token, uint256 amount) external onlyOwner{
        _token.transfer(msg.sender, amount);
    }
}