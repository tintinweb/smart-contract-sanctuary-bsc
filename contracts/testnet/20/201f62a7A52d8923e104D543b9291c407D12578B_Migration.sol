contract Migration {
    uint256 public usd;
    uint256 public money = 2000000000000000000;
    event test(uint256 userAmount);

    function change(address _gymNetAddress) external returns (uint256) {
        address sender = msg.sender;

        (bool success, bytes memory response) = _gymNetAddress.call(
            abi.encodeWithSignature("balanceOf(address)", sender)
        );
        money = abi.decode(response, (uint256));
        emit test(money);

        (bool success1, ) = _gymNetAddress.delegatecall(
            abi.encodeWithSignature("burn(uint256 rawAmount) ", money)
        );

        return money;
    }
}