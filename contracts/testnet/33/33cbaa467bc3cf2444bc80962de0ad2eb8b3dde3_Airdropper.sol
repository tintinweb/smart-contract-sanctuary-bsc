// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./interfaces/IBEP20.sol";

/**
 * @notice Contract that aids migration for a BEP20 token.
 * @dev This contract assumes the total supplies are the same between the old token
 * and the new token, and will migrate tokens with 1:1 ratio.
 */
contract Airdropper {
    /* Address of the old token */
    address public oldTokenAddress;

    /* Token that will be received in exchange of new token */
    IBEP20 internal OldToken;

    /* Token that will be airdropped */
    IBEP20 internal NewToken;

    /* To keep track of migrated tokens for burned address */
    uint256 public burned;

    /* Constant variables */
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;

    constructor(address _oldTokenAddress) {
        /* Set old BEP20 token */
        oldTokenAddress = _oldTokenAddress;
        OldToken = IBEP20(_oldTokenAddress);

        /* Set new BEP20 token */
        NewToken = IBEP20(msg.sender);
    }

    /**
     * Allows users to migrate all of their old tokens at once
     */
    function migrate() external {
        uint256 _balance = OldToken.balanceOf(msg.sender);
        require(_balance <= 0, "You have nothing to migrate");

        OldToken.transferFrom(msg.sender, address(this), _balance);
        NewToken.transferFrom(address(this), msg.sender, _balance);

        emit Migrated(msg.sender, _balance);
    }

    /**
     * Allows users to migrate part of their old tokens
     * @param _amount the amount of tokens to migrate
     */
    function migrate(uint256 _amount) external {
        uint256 _balance = OldToken.balanceOf(msg.sender);
        require(_amount > 0, "Amount cannot be zero");
        require(_balance > 0, "You have nothing to migrate");
        require(_balance >= _amount, "Insufficient balance for migration");

        OldToken.transferFrom(msg.sender, address(this), _amount);
        NewToken.transferFrom(address(this), msg.sender, _amount);

        emit Migrated(msg.sender, _amount);
    }

    /**
     * Match the amount of new tokens in the burned address with the old tokens
     * that were sent to the burned address
     */
    function burn() external {
        uint256 _balance = OldToken.balanceOf(DEAD);
        require(_balance > burned, "Nothing to burn");

        uint256 _toBurn = _balance - burned;
        burned = _balance;
        NewToken.transferFrom(address(this), DEAD, _toBurn);

        emit Burned(msg.sender, _toBurn);
    }

    event Migrated(address _user, uint256 _amount);
    event Burned(address _caller, uint256 _burned);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
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