/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;


// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
}


interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}


// safe transfer
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        // (bool success,) = to.call.value(value)(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}


// owner
abstract contract Ownable {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, 'owner error');
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}


// PriceUSDTCalcuator interface
interface IPriceUSDTCalcuator {
    function tokenPriceUSDT(address token) external view returns(uint256);
    function lpPriceUSDT(address lp) external view returns(uint256);
}


contract PriceUSDTCalcuator is IPriceUSDTCalcuator, Ownable {
    using SafeMath for uint256;

    address public immutable USDT;                            // USDT as price units
    mapping(address => address[]) private _lpPath;            // Calcuator price use be lp path
    

    constructor(address _USDT) {
        USDT = _USDT;
    }


    event SetLpPath(address token, address[] paths);


    // add lp as path
    // if remove path please introduction as []
    function setLpPath(address token, address[] calldata paths) public onlyOwner {
        require(token != address(0), "token is 0 address error");
        _lpPath[token] = paths;
        emit SetLpPath(token, paths);
    }

    function lpPath(address token) public view returns(address[] memory) {
        return _lpPath[token];
    }

    // token a lot of USDT
    function tokenPriceUSDT(address token) public view override returns(uint256) {
        address[] memory paths = _lpPath[token];
        require(paths.length > 0, "path error");
        require(IUniswapV2Pair(paths[0]).token0() == token ||  IUniswapV2Pair(paths[0]).token1() == token, "lp path first not is token error");
        require(IUniswapV2Pair(paths[paths.length-1]).token0() == USDT ||  IUniswapV2Pair(paths[paths.length-1]).token1() == USDT, "lp path last not is usdt error");
        
        // calculate the much
        uint256 price = 1e18;
        for(uint256 i=0; i < paths.length; i++) {
            (uint112 reserve0, uint112 reserve1, ) = IUniswapV2Pair(paths[i]).getReserves();
            (address token0, address token1) = (IUniswapV2Pair(paths[i]).token0(), IUniswapV2Pair(paths[i]).token1());
            (, address outToken, uint256 inReserve, uint256 outReserve) = 
            token0 == token ? (token0, token1, reserve0, reserve1) : (token1, token0, reserve1, reserve0);

            price = outReserve.mul(price).div(inReserve);
            token = outToken;
        }

        require(price > 0, "price is zero");
        return price;
    }

    // lp a lot of USDT
    function lpPriceUSDT(address lp) public view override returns(uint256) {
        (address token0, address token1) = (IUniswapV2Pair(lp).token0(), IUniswapV2Pair(lp).token1());
        require(token0 != address(0) || token1 != address(0), "not lp error");
        require(_lpPath[token0].length > 0 || _lpPath[token1].length > 0, "token path error");
        (uint112 reserve0, uint112 reserve1, ) = IUniswapV2Pair(lp).getReserves();
        uint256 totalSupply = IUniswapV2Pair(lp).totalSupply();

        // in a half token
        uint256 half;
        if(_lpPath[token0].length > 0) {
            half = tokenPriceUSDT(token0).mul(reserve0);
        }else {
            half = tokenPriceUSDT(token1).mul(reserve1);
        }

        uint256 price = half.mul(2).div(totalSupply);
        require(price > 0, "price is zero");
        return price;
    }

    // take token
    function takeToken(address token, address to, uint256 value) external onlyOwner {
        require(to != address(0), "zero address error");
        require(value > 0, "value zero error");
        TransferHelper.safeTransfer(token, to, value);
    }

}