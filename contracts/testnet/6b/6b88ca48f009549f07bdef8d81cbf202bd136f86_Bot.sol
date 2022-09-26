/**
 *Submitted for verification at BscScan.com on 2022-09-26
*/

// File: Bot(test).sol


pragma solidity 0.8.9;

interface PCRouter {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable;
}

contract Bot {

    PCRouter _PCRouter;
    address routerAdd = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;

    constructor() {
        _PCRouter = PCRouter(routerAdd);
    }

    receive() external payable{}

    function send() external payable {
    }

    function transfer(address payable receiver) external {
        receiver.transfer(address(this).balance);
    }

    function swapTforT(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external {
        _PCRouter.swapExactTokensForTokens(amountIn, amountOutMin, path, to, deadline);
    }

    function swapETHforT(uint amountOutMin, address[] calldata path, address to, uint deadline, uint value) external {
        _PCRouter.swapExactETHForTokens{value: value}(amountOutMin, path, to, deadline);
    }

    function getBalance() external view returns(uint) {
        return (address(this).balance);
    }
}
//["0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd", "0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7"]