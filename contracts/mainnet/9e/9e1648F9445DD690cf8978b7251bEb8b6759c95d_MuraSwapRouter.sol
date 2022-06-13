// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Interfaces.sol";

contract MuraSwapRouter is Ownable {
    IROUTER router;
    uint public swapETHToTokensFee;

    constructor (address _router, uint _swapETHToTokensFee) {
        router = IROUTER(_router); // Router adress
        swapETHToTokensFee = _swapETHToTokensFee; // Eth to Token Fee
    }

    function swapExactETHForTokens (
        address tokenToSwap,
        uint256 amountOutMin //slip page
    ) external payable {
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = tokenToSwap;
        uint256 ammountInWithTax = msg.value * (1000 - swapETHToTokensFee) / 1000;
        router.swapExactETHForTokens{value: ammountInWithTax}(amountOutMin, path, msg.sender, block.timestamp + (1000 * 60 *60 * 100));
    }
    // Supporting fee transfer token
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        address tokenToSwap,
        uint256 amountOutMin //slip page
    ) external payable {
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = tokenToSwap;
        uint256 ammountInWithTax = msg.value * (1000 - swapETHToTokensFee) / 1000;
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: ammountInWithTax}(amountOutMin, path, msg.sender, block.timestamp + (1000 * 60 *60 * 100));
    }

    function swapExactTokensForETH(
        address token,
        uint256 amountIn,
        uint256 amountOutMin //Slip page
    ) external {
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = router.WETH();
        // Transfer value to this contract
        IERC20(token).transferFrom(msg.sender, address(this), amountIn);
    
        //next we need to allow the router router to spend the token we just sent to this contract
        //by calling IERC20 approve you allow the router contract to spend the tokens in this contract 
        IERC20(token).approve(address(router), amountIn);
        router.swapExactTokensForETH(amountIn, amountOutMin, path, msg.sender, block.timestamp + (1000 * 60 *60 * 100));
    }

    // Supporting fee transfer token
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        address token,
        uint256 amountIn,
        uint256 amountOutMin //Slip page
    ) external {
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = router.WETH();
        // Transfer value to this contract
        IERC20(token).transferFrom(msg.sender, address(this), amountIn);
    
        //next we need to allow the router router to spend the token we just sent to this contract
        //by calling IERC20 approve you allow the router contract to spend the tokens in this contract 
        IERC20(token).approve(address(router), amountIn);
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(amountIn, amountOutMin, path, msg.sender, block.timestamp + (1000 * 60 *60 * 100));
    }
    
    function swapExactTokensForTokens (
        address token,
        address tokenToSwap,
        uint256 amountIn,
        uint256 amountOutMin //Slip page
    ) external {
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = tokenToSwap;
        IERC20(token).transferFrom(msg.sender, address(this), amountIn);
    
        //next we need to allow the router router to spend the token we just sent to this contract
        //by calling IERC20 approve you allow the router contract to spend the tokens in this contract 
        IERC20(token).approve(address(router), amountIn);
        // Transfer value to this contract
        router.swapExactTokensForTokens(amountIn, amountOutMin, path, msg.sender, block.timestamp + (1000 * 60 *60 * 100));
    }
    
    // Supporting fee transfer token
    function swapExactTokensForTokensSupportingFeeOnTransferTokens (
        address token,
        address tokenToSwap,
        uint256 amountIn,
        uint256 amountOutMin //Slip page
    ) external {
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = tokenToSwap;
        IERC20(token).transferFrom(msg.sender, address(this), amountIn);
    
        //next we need to allow the router router to spend the token we just sent to this contract
        //by calling IERC20 approve you allow the router contract to spend the tokens in this contract 
        IERC20(token).approve(address(router), amountIn);
        // Transfer value to this contract
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amountIn, amountOutMin, path, msg.sender, block.timestamp + (1000 * 60 *60 * 100));
    }

    // calculate price based on pair reserves
   function getTokenPrice(address token, address pair, uint amountIn) public view returns(uint[] memory){
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = pair;
       return router.getAmountsOut(amountIn, path);
    }

    function setFee(uint _swapETHToTokensFee) external {
        swapETHToTokensFee = _swapETHToTokensFee; // Eth to Token Fee
    }

    function setRouterAddress(address _router) external {
        router = IROUTER(_router); 
    }
    
    function wethAddress() public view returns (address)  {
        return router.WETH();
    }

    function contractAddress() public view returns (address)  {
        return address(this);
    }

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}