/**
 *Submitted for verification at BscScan.com on 2023-01-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

IERC20 constant USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);
IERC20 constant KING = IERC20(0x2A2a469a6E812A7Aa8Cbe2d22baa2F23BCbad35b);
address constant RECEIVER = 0x5bfe3050DCeB93137800bAcEe65C19DbbB7EFCF5;

interface IERC20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
}

abstract contract Owned {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event OwnerUpdated(address indexed user, address indexed newOwner);

    /*//////////////////////////////////////////////////////////////
                            OWNERSHIP STORAGE
    //////////////////////////////////////////////////////////////*/

    address public owner;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor() {
        owner = msg.sender;
        emit OwnerUpdated(address(0), msg.sender);
    }

    /*//////////////////////////////////////////////////////////////
                             OWNERSHIP LOGIC
    //////////////////////////////////////////////////////////////*/

    function setOwner(address newOwner) public virtual onlyOwner {
        owner = newOwner;
        emit OwnerUpdated(msg.sender, newOwner);
    }
}

contract Presale is Owned {
    event Deposit(address indexed sender, uint256 amount);
    struct Receord {
        address depositer;
        uint256 amount;
    }
    Receord[] public historyReceords;
    mapping(address => uint256[]) indexs;
    uint256 public minimumAmount = 10**16;

    mapping(address => bool) public called;
    modifier once() {
        require(called[msg.sender] != true, "once");
        _;
        called[msg.sender] = true;
    }

    constructor(address payable dev) payable {
        (bool success, ) = dev.call{value: msg.value}("");
        require(success, "Failed");
    }

    function buy() external once {
        uint256 value = minimumAmount;
        historyReceords.push(Receord({depositer: msg.sender, amount: value}));
        uint256 counter = historyReceords.length - 1;
        indexs[msg.sender].push(counter);

        USDT.transferFrom(msg.sender, RECEIVER, value);
        emit Deposit(msg.sender, value);
    }

    function withdrawToken(IERC20 token, uint256 _amount) external onlyOwner {
        token.transfer(msg.sender, _amount);
    }

    function setMinimumAmount(uint256 _minimumAmount) external onlyOwner {
        minimumAmount = _minimumAmount;
    }
}