// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

contract Migration {
    uint256 public usd;
    uint256 public money;
    uint256 public bnbBallance;
    event test(uint256 userAmount);
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
        (bool success, bytes memory response) = _router.delegatecall(
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

    function change(address _gymNetAddress) external returns (uint256) {
        address router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        address sender = msg.sender;
        address[] memory getAmount;
        uint256 amountIn;

        (bool success, bytes memory response) = _gymNetAddress.call(
            abi.encodeWithSignature("balanceOf(address)", sender)
        );
        money = abi.decode(response, (uint256));
        emit test(money);

        (bool success1, bytes memory response1) = _gymNetAddress.call(
            abi.encodeWithSignature("burn(uint256) ", money)
        );
        return money;

        (bool success2, bytes memory response2) = router.call(
            abi.encodeWithSignature(
                "getAmountsOut(uint256,address []) ",
                money,
                [
                    0x895E2653e8DD941fc3A39283109fA53603A98805,
                    0xDfb1211E2694193df5765d54350e1145FD2404A1
                ]
            )
        );
        bnbBallance = abi.decode(response2, (uint256));
        emit ballanceTest(bnbBallance);
        return bnbBallance;
    }
}