// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.0;

import "./TransferHelper.sol";

import "./IPancakePair.sol";

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

contract Swapper{
    address private owner;

    constructor() {
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function sendSwap(address pair, address input, address output, uint256 amount) public onlyOwner{
        TransferHelper.safeTransfer(input,  pair,  amount);
    
        (address token0,) = input < output ? (input, output) : (output, input);
        (uint reserve0, uint reserve1,) = IPancakePair(pair).getReserves();
        (uint reserveIn, uint reserveOut) = input == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint amountOut = getAmountOut(amount, reserveIn, reserveOut);
        (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOut) : (amountOut, uint(0));
        
        IPancakePair(pair).swap(
            amount0Out, amount1Out, address(this), new bytes(0)
        );

    }

    function getAmountOut(uint256 amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        uint amountInWithFee = SafeMath.mul(amountIn, 9975);
        uint numerator = SafeMath.mul(amountInWithFee,reserveOut);
        uint denominator = SafeMath.add(SafeMath.mul(reserveIn,10000),amountInWithFee);
        amountOut = numerator / denominator;
    }

    function transfer(uint256 amount, address token) public onlyOwner{
        TransferHelper.safeTransfer(token,  msg.sender,  amount);
    }
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.0;

library TransferHelper {

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

}

// File: contracts\interfaces\IPancakePair.sol

pragma solidity 0.8.0;

interface IPancakePair {

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

}