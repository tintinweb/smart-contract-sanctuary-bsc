// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "./PucakeRouterInterface.sol";

contract Swapper {
    function getRouterAmountOutMin(
        address _router,
        uint256 _amountIn,
        address[] memory _path
    ) public view returns (uint256 amountOutMin) {
        // Get amounts out
        uint256[] memory amountsOut = PuncakeRouterInterface(_router)
            .getAmountsOut(_amountIn, _path);
        return amountsOut[1] - amountsOut[1] / 10;
    }

    function SwapWithPuncake(
        address _router,
        uint256 _amountIn,
        address _tokenIn,
        address _tokenOut,
        uint256 _deadLine
    ) external {
        // Define and intialize Swap contracts
        PuncakeRouterInterface router = PuncakeRouterInterface(_router);
        address[] memory path;
        path[0] = _tokenIn;
        path[1] = _tokenOut;

        // Get amounts out
        uint256 amountOutMin = getRouterAmountOutMin(_router, _amountIn, path);

        // Swap tokens
        router.swapExactTokensForTokens(
            _amountIn,
            amountOutMin,
            path,
            msg.sender,
            _deadLine
        );
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

abstract contract PuncakeRouterInterface {
    function getAmountsOut(uint amountIn, address[] memory path) public virtual view returns(uint[] memory amounts);
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external virtual returns (uint[] memory amounts);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external virtual returns (uint[] memory amounts);
}