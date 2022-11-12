// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract BatchTransfer {
    event Reward_Event(address to, uint256 amount);

    // 批量转账
    function div_reward(
        address token_addr,
        address[] memory addrList,
        uint256[] memory quantityList
    ) public {
        IERC20 _token = IERC20(token_addr);
        uint256 total = _token.balanceOf(msg.sender);
        uint256 quantitySum = 0;
        for (uint256 i = 0; i < quantityList.length; i++) {
            quantitySum += quantityList[i];
        }
        require(total >= quantitySum);
        _token.transferFrom(msg.sender, address(this), quantitySum);

        for (uint256 i = 0; i < quantityList.length; i++) {
            address to = addrList[i];
            uint256 amount = quantityList[i];
            _token.transfer(to, amount);
            emit Reward_Event(to, amount);
        }
    }
}