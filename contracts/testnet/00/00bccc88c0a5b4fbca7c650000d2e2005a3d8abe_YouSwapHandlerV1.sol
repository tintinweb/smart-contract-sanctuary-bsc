/**
 *Submitted for verification at BscScan.com on 2022-06-27
*/

pragma solidity 0.7.4;

interface IYouSwapRouter {
    
    function factory() external view returns (address);
    
    function getAmountsOut(uint amountIn, address[] memory path) external view returns (uint[] memory);

    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] memory path, address to, uint deadLine) external returns (uint[] memory amounts);
    
}


pragma solidity 0.7.4;

interface IYouSwapFactory {
    
    function getPair(address tokenA, address tokenB) external view returns (address);
    
}


pragma solidity 0.7.4;

interface IYouSwapPair {
    
    function getReserves() external view returns (uint256, uint256, uint256);
    
}



pragma solidity 0.7.4;

interface IHandlerV1 {
    
    function swapExtractOut(address tokenIn, address recipient, uint256 amountIn, uint256 amountOutMin, uint256 deadLine, address[] memory path) external returns (uint256[] memory);

    function swapEstimateOut(address tokenIn, address tokenOut, uint256 amountIn) external view returns (uint256, address[] memory);

    function swapEstimateOutV2(uint256 amountIn, address[] memory path) external view returns (uint256);

}



pragma solidity 0.7.4;

interface IERC20 {
    
    function approve(address spender, uint256 amount) external returns (bool);
    
    function transfer(address recipient, uint256 amount) external returns (bool);
    
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    
}



pragma solidity 0.7.4;

abstract contract Ownerable {
    
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);
    
    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable:caller_is_not_the_owner");
        _;
    }
    
    address public owner;
    
    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), owner);
    }
    
    function transferOwnership(address newOwner) external onlyOwner {
        require(address(0) != newOwner, "Ownable:new_owner_is_the_zero_address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
    
}



pragma solidity 0.7.4;
contract YouSwapHandlerV1 is IHandlerV1, Ownerable {
    
    IYouSwapFactory public factory;
    IYouSwapRouter public router;
    address[] public baseTokens;
    
    constructor(IYouSwapRouter _router, address[] memory tokens) {
        _updateRouter(_router);
        for (uint256 i = 0; i < tokens.length; i++) {
            _addBaseToken(tokens[i]);
        }
    }
    
    function swapExtractOut(address tokenIn, address recipient, uint256 amountIn, uint256 amountOutMin, uint256 deadLine, address[] memory path) override external returns (uint256[] memory) {
        IERC20(tokenIn).approve(address(router), amountIn);
        return router.swapExactTokensForTokens(amountIn, amountOutMin, path, recipient, deadLine);
    }
    
    function swapEstimateOut(address tokenIn, address tokenOut, uint256 amountIn) override external view returns (uint256, address[] memory) {
        return _getBestOut(tokenIn, tokenOut, amountIn);
    }

    function swapEstimateOutV2(uint256 amountIn, address[] memory path) override external view returns (uint256) {
        uint256[] memory estimateAmount = _getAmountsOut(amountIn, path);
        return estimateAmount[estimateAmount.length - 1];
    }
    
    function updateRouter(IYouSwapRouter _router) external onlyOwner {
        _updateRouter(_router);
    }

    function addBaseTokens(address[] memory tokens) external onlyOwner {
        for (uint256 i = 0; i < tokens.length; i++) {
            _addBaseToken(tokens[i]);
        }
    }

    function removeBaseToken(address token) external onlyOwner {
        uint256 index;
        bool exist;
        for (uint256 i = 0; i < baseTokens.length; i++) {
            if (token == baseTokens[i]) {
                index = i;
                exist = true;
                break;
            }
        }
        require(exist, "YouSwapHandlerV1:token_not_exist");
        baseTokens[index] = baseTokens[baseTokens.length - 1];
        baseTokens.pop();
    }

    function _getBestOut(address tokenIn, address tokenOut, uint256 amountIn) internal view returns (uint256, address[] memory) {
        address[] memory tempPath;
        uint256[] memory tempAmount;
        uint256 estimateAmount = 0;
        address[] memory path;
        if (address(0) != factory.getPair(tokenIn, tokenOut)) {
            path = new address[](2);
            path[0] = tokenIn;
            path[1] = tokenOut;
            tempAmount = _getAmountsOut(amountIn, path);
            estimateAmount = tempAmount[tempAmount.length - 1];
        }
        for (uint256 i = 0; i < baseTokens.length; i++) {
            if (baseTokens[i] == tokenIn || baseTokens[i] == tokenOut) {
                continue;
            }
            if (address(0) == factory.getPair(tokenIn, baseTokens[i])) {
                continue;
            }
            if (address(0) != factory.getPair(baseTokens[i], tokenOut)) {
                tempPath = new address[](3);
                tempPath[0] = tokenIn;
                tempPath[1] = baseTokens[i];
                tempPath[2] = tokenOut;
                tempAmount = _getAmountsOut(amountIn, tempPath);
                if (estimateAmount < tempAmount[tempAmount.length - 1]) {
                    estimateAmount = tempAmount[tempAmount.length - 1];
                    path = tempPath;
                }
            }
            for (uint256 j = 0; j < baseTokens.length; j++) {
                if (baseTokens[i] == baseTokens[j]) {
                    continue;
                }
                if (baseTokens[j] == tokenIn || baseTokens[j] == tokenOut) {
                    continue;
                }
                if (address(0) == factory.getPair(baseTokens[i], baseTokens[j])) {
                    continue;
                }
                if (address(0) == factory.getPair(baseTokens[j], tokenOut)) {
                    continue;
                }
                tempPath = new address[](4);
                tempPath[0] = tokenIn;
                tempPath[1] = baseTokens[i];
                tempPath[2] = baseTokens[j];
                tempPath[3] = tokenOut;
                tempAmount = _getAmountsOut(amountIn, tempPath);
                if (estimateAmount < tempAmount[tempAmount.length - 1]) {
                    estimateAmount = tempAmount[tempAmount.length - 1];
                    path = tempPath;
                }
            }
        }
        return (estimateAmount, path);
    }
    
    function _updateRouter(IYouSwapRouter _router) internal {
        require(address(0) != address(_router), "YouSwapHandlerV1:router_is_zero_address");
        router = _router;
        factory = IYouSwapFactory(_router.factory());
    }
    
    function _addBaseToken(address token) internal {
        for (uint256 i = 0; i < baseTokens.length; i++) {
            if (baseTokens[i] == token) {
                return;
            }
        }
        baseTokens.push(token);
    }
    
    function _getAmountsOut(uint256 amountIn, address[] memory path) internal view returns (uint256[] memory) {
        uint256 reserve0;
        uint256 reserve1;
        uint256[] memory amounts = new uint256[](path.length);
        amounts[0] = amountIn;
        address[] memory tempPath = new address[](2);
        for (uint256 i; i < path.length - 1; i++) {
            tempPath[0] = path[i];
            tempPath[1] = path[i + 1];
            if (0 == amounts[i]) {
                amounts[i + 1] = 0;
            }else {
                (reserve0, reserve1, ) = IYouSwapPair(factory.getPair(tempPath[0], tempPath[1])).getReserves();
                if (0 == reserve0 || 0 == reserve1) {
                    amounts[i + 1] = 0;
                }else {
                    amounts[i + 1] = router.getAmountsOut(amounts[i], tempPath)[1];    
                }
            }
            
        }
        return amounts;
    }

}