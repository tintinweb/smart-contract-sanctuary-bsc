// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

contract Migration {
    uint256 public userLpBalance;
    uint256 public userWbnbBalance;
    event ballance(uint256 userAmount);
    event ballanceTest(uint256 bnbBallance);

    fallback() external payable {}

    receive() external payable {}

    constructor(
        address _router,
        address _gymToken,
        address _wbnbToken,
        uint256 _amountGymDesired,
        uint256 _amountWbnbDesired,
        uint256 _amountGymMin,
        uint256 _amountWbnbMin,
        address _to,
        uint256 _deadline
    ) {
        (, bytes memory response) = _router.call(
            abi.encodeWithSignature(
                "addLiquidity(address,address,address,uint256,uint256,uint256,uint256,address,uint256)",
                _router,
                _gymToken,
                _wbnbToken,
                _amountGymDesired,
                _amountWbnbDesired,
                _amountGymMin,
                _amountWbnbMin,
                _to,
                _deadline
            )
        );
    }

    function change(address lpAddress) external {
        // address router = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
        // address mlmAddress = 0x7109f664CA6ab7973C15E691687a84E54d5d9d99;
        address sender = msg.sender;

        (, bytes memory response) = lpAddress.call(
            abi.encodeWithSignature("balanceOf(address)", sender)
        );
        userLpBalance = abi.decode(response, (uint256));
        emit ballance(userLpBalance);

        (, bytes memory response1) = lpAddress.call(
            abi.encodeWithSignature(
                "removeLiquidityETHSupportingFeeOnTransferTokens(address,uint,uint,uint,address,uint)",
                lpAddress,
                userLpBalance,
                userLpBalance
            )
        );
        userLpBalance = abi.decode(response1, (uint256));

        (, bytes memory response2) = lpAddress.call(
            abi.encodeWithSignature(
                "uint256,uint256,address,bytes",
                lpAddress,
                0xDfb1211E2694193df5765d54350e1145FD2404A1,
                sender
            )
        );
        userWbnbBalance = abi.decode(response2, (uint256));
    }
}