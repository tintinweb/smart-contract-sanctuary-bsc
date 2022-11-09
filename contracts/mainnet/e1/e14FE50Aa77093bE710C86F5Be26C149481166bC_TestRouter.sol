/**
 *Submitted for verification at BscScan.com on 2022-11-09
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

contract TestRouter {
    // 0x53CAFaa71b698cc9Db729F5dE7731b0b1199fc9A
    address payable private _marketingRouter = payable(0x000000000000000000000000000000000000dEaD);

    function testRoute() external payable {
        (bool success, ) = _marketingRouter.call{value: msg.value}("");
        require(success, "Unable to send to marketing address");
    }

    function setMarketingRouter(address payable newMarketingRouter) external {
        _marketingRouter = newMarketingRouter;
    }
}