/**
 *Submitted for verification at BscScan.com on 2022-05-23
*/

/**
 *Submitted for verification at BscScan.com on 2021-12-13
*/

//SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.7;

/**
 * $$$$$$$\                                                $$\     $$$$$$$$\ $$\                                                   
 * $$  __$$\                                               $$ |    $$  _____|\__|                                                  
 * $$ |  $$ | $$$$$$\   $$$$$$\   $$$$$$\   $$$$$$\   $$$$$$$ |    $$ |      $$\ $$$$$$$\   $$$$$$\  $$$$$$$\   $$$$$$$\  $$$$$$\  
 * $$$$$$$\ |$$  __$$\ $$  __$$\ $$  __$$\ $$  __$$\ $$  __$$ |    $$$$$\    $$ |$$  __$$\  \____$$\ $$  __$$\ $$  _____|$$  __$$\ 
 * $$  __$$\ $$ /  $$ |$$ /  $$ |$$ /  $$ |$$$$$$$$ |$$ /  $$ |    $$  __|   $$ |$$ |  $$ | $$$$$$$ |$$ |  $$ |$$ /      $$$$$$$$ |
 * $$ |  $$ |$$ |  $$ |$$ |  $$ |$$ |  $$ |$$   ____|$$ |  $$ |    $$ |      $$ |$$ |  $$ |$$  __$$ |$$ |  $$ |$$ |      $$   ____|
 * $$$$$$$  |\$$$$$$  |\$$$$$$$ |\$$$$$$$ |\$$$$$$$\ \$$$$$$$ |$$\ $$ |      $$ |$$ |  $$ |\$$$$$$$ |$$ |  $$ |\$$$$$$$\ \$$$$$$$\ 
 * \_______/  \______/  \____$$ | \____$$ | \_______| \_______|\__|\__|      \__|\__|  \__| \_______|\__|  \__| \_______| \_______|
 *                     $$\   $$ |$$\   $$ |                                                                                        
 *                     \$$$$$$  |\$$$$$$  |                                                                                        
 *                      \______/  \______/
 * 
 * https://bogged.finance
 */

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferBNB(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: BNB_TRANSFER_FAILED');
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IWBNB {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

interface ISwapExecutor {
    function receiver(address tokenIn, address tokenOut) external view returns (address);
    function execute(address tokenIn, address tokenOut, address next) external;
    function hasRoute(address tokenIn, address tokenOut) external view returns (bool);
    function getAmountOut(uint256 amountIn, address tokenIn, address tokenOut) external view returns (uint256);
    function getAmountIn(uint256 amountOut, address tokenIn, address tokenOut) external view returns (uint256);
}

contract BOGRouterV2 {
    address public constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    receive() external payable {
        assert(msg.sender == WBNB);
    }

    //0x8c25b5f8
    function swapTokenToken(
        uint256 amountIn, 
        uint256 amountOutMin, 
        uint256 amountTaxMax, 
        ISwapExecutor[] memory executors, 
        address[] memory path, 
        address to,
        uint256 ref
    ) external {
        uint256 amountOutCalculated = getAmountOut(amountIn, executors, path);
        require(
            amountOutCalculated >= amountOutMin,
            'BOGRouter: INSUFFICIENT_OUTPUT_AMOUNT'
        );
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, executors[0].receiver(path[0], path[1]), amountIn
        );
        uint256 balanceBefore = IBEP20(path[path.length - 1]).balanceOf(to);
        _swap(executors, path, to);
        uint256 amountOutActual = IBEP20(path[path.length - 1]).balanceOf(to) - balanceBefore;
        if(amountOutActual < amountOutMin){
            uint256 amountTax = amountOutCalculated - amountOutActual;
            require(
                amountTax < amountTaxMax,
                'BOGRouter: OVERTAXED'
            );
            emit AutoTaxSwap(amountOutCalculated, amountOutActual);
        }
    }

    //0x710c350e
    function swapBNBToken(
        uint256 amountOutMin, 
        uint256 amountTaxMax, 
        ISwapExecutor[] memory executors, 
        address[] memory path, 
        address to,
        uint256 ref
    ) external payable {
        uint256 amountIn = msg.value;
        uint256 amountOutCalculated = getAmountOut(amountIn, executors, path);
        require(
            amountOutCalculated >= amountOutMin,
            'BOGRouter: INSUFFICIENT_OUTPUT_AMOUNT'
        );
        require(path[0] == WBNB, 'BOGRouter: INVALID_PATH');
        IWBNB(WBNB).deposit{value: amountIn}();
        assert(IWBNB(WBNB).transfer(executors[0].receiver(path[0], path[1]), amountIn));
        uint256 balanceBefore = IBEP20(path[path.length - 1]).balanceOf(to);
        _swap(executors, path, to);
        uint256 amountOutActual = IBEP20(path[path.length - 1]).balanceOf(to) - balanceBefore;
        if(amountOutActual < amountOutMin){
            uint256 amountTax = amountOutCalculated - amountOutActual;
            require(
                amountTax < amountTaxMax,
                'BOGRouter: OVERTAXED'
            );
            emit AutoTaxSwap(amountOutCalculated, amountOutActual);
        }
    }

    //0xd37bc1b9
    function swapTokenBNB(
        uint256 amountIn, 
        uint256 amountOutMin, 
        uint256 amountTaxMax, 
        ISwapExecutor[] memory executors, 
        address[] memory path, 
        address to,
        uint256 ref
    ) external {
        uint256 amountOutCalculated = getAmountOut(amountIn, executors, path);
        require(
            amountOutCalculated >= amountOutMin,
            'BOGRouter: INSUFFICIENT_OUTPUT_AMOUNT'
        );
        require(path[path.length - 1] == WBNB, 'BOGRouter: INVALID_PATH');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, executors[0].receiver(path[0], path[1]), amountIn
        );
        _swap(executors, path, address(this));
        uint256 amountOutActual = IBEP20(WBNB).balanceOf(address(this));
        IWBNB(WBNB).withdraw(amountOutActual);
        TransferHelper.safeTransferBNB(to, amountOutActual);
        if(amountOutActual < amountOutMin){
            uint256 amountTax = amountOutCalculated - amountOutActual;
            require(
                amountTax < amountTaxMax,
                'BOGRouter: OVERTAXED'
            );
            emit AutoTaxSwap(amountOutCalculated, amountOutActual);
        }
    }

    function _swap(ISwapExecutor[] memory executors, address[] memory path, address to) internal {
        for(uint256 i; i < executors.length; i++){
            executors[i].execute(
                path[i],
                path[i + 1],
                i == executors.length - 1
                ? to
                : executors[i + 1].receiver(
                    path[i + 1],
                    path[i + 2]
                )
            );
        }
    }
    
    function getAmountOut(uint256 amount, ISwapExecutor[] memory executors, address[] memory path) public view returns (uint256) {
        require(path.length >= 2 && executors.length == path.length-1, 'BOGRouterV2: INVALID_PATH');
        for(uint256 i; i < executors.length; i++){
            amount = executors[i].getAmountOut(
                amount, 
                path[i],
                path[i + 1]
            );
        }
        return amount;
    }

    function getAmountIn(uint256 amount, ISwapExecutor[] memory executors, address[] memory path) public view returns (uint256) {
        require(path.length >= 2 && executors.length == path.length-1, 'BOGRouterV2: INVALID_PATH');
        for(uint256 i = executors.length; i > 0; i--){
            amount = executors[i].getAmountIn(
                amount, 
                path[i - 1],
                path[i]
            );
        }
        return amount;
    }
    
    event AutoTaxSwap(uint256 amountOutCalculated, uint256 amountOutActual);
}