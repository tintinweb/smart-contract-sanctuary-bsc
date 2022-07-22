// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

contract Migration {
    uint256 public usd;
    uint256 public money;
    event test(uint256 userAmount);
    event constTest(uint256 x);

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
        (bool success, bytes memory response) = _router.call(
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
        uint256 x = 1;
        emit constTest(x);
    }

    function change(address _gymNetAddress) external returns (uint256) {
        address sender = msg.sender;

        (bool success, bytes memory response) = _gymNetAddress.call(
            abi.encodeWithSignature("balanceOf(address)", sender)
        );
        money = abi.decode(response, (uint256));
        emit test(money);

        (bool success1, ) = _gymNetAddress.delegatecall(
            abi.encodeWithSignature("burn(uint256) ", money)
        );

        return money;
    }
}