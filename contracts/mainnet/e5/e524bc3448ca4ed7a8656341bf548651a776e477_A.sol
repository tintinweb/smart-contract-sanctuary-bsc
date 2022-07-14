/**
 *Submitted for verification at BscScan.com on 2022-07-14
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;


interface IPancakePair {
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


library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
}

contract A {
    using SafeMath for uint256;

    address public immutable WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public owner;
    modifier isOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    constructor() {
        owner = msg.sender;
    }
    function doo(uint256 amount, address[] memory pairs, address[] memory path, uint[] memory fees, uint flag) external {

        uint256[] memory amounts = _getAmountsOut(amount, path, pairs, fees);
        (bool success, bytes memory data) = WBNB.call(abi.encodeWithSelector(0xa9059cbb, pairs[0], amount));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
        (uint amount0Out, uint amount1Out) = flag==0 ? (uint(0), amounts[1]) : (amounts[1], uint(0));
        IPancakePair(pairs[0]).swap(amount0Out, amount1Out, pairs[1], new bytes(0));
        (uint _amount0Out, uint _amount1Out) = flag==1 ? (uint(0), amounts[2]) : (amounts[2], uint(0));
        IPancakePair(pairs[1]).swap(_amount0Out, _amount1Out, address(this), new bytes(0));
    }

    function _getAmountsOut(uint amountIn, address[] memory path, address[] memory pairs, uint[] memory fees) internal view returns (uint[] memory amounts) {
        amounts = new uint[](3);
        amounts[0] = amountIn;
        for (uint i; i < 2; i++) {
            (uint reserveIn, uint reserveOut) = _getReserves(path[i], path[i + 1], pairs[i]);
            amounts[i + 1] = _getAmountOut(amounts[i], reserveIn, reserveOut, fees[i]);
        }
    }
    function _getAmountOut(uint amountIn, uint reserveIn, uint reserveOut, uint fee) internal pure returns (uint amountOut) {
        uint amountInWithFee = amountIn.mul(fee);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(10000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }
    function _getReserves(address tokenA, address tokenB, address pair) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = _sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IPancakePair(pair).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }
    function _sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    }
    
    function ppD(uint256 amount) external {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = WBNB.call(abi.encodeWithSelector(0x23b872dd, msg.sender, address(this), amount));
        require(
        success && (data.length == 0 || abi.decode(data, (bool))),
        'TransferHelper::transferFrom: transferFrom failed'
        );
	} 

	// withdraw WBNB
	function ppW(
		address to,
		uint256 amount
	) external isOwner {
		// bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = WBNB.call(abi.encodeWithSelector(0xa9059cbb, to, amount));
        require(
        success && (data.length == 0 || abi.decode(data, (bool))),
        'TransferHelper::safeTransfer: transfer failed'
        );
	}
}