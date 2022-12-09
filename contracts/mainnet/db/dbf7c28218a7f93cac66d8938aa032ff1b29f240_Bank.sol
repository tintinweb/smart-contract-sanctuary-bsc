/**
 *Submitted for verification at BscScan.com on 2022-12-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

IERC20 constant DDDDS = IERC20(0xa51Bb0D78200B90977A84Eb2D9F58977A276F083);
IERC20 constant USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);
IRouter constant ROUTER = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);

address constant rec = 0x3669E0215654F7d091317DDC827d04D5090fa280;

interface IERC20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
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

interface IRouter {
    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

contract Bank is Owned {
    mapping(address => bool) public called;
    address public RECEIVER = rec;
    event Deposit(address indexed sender, uint256 amount, uint256 price);
    event Log(string message);
    struct Receord {
        address depositer;
        uint256 amount;
    }
    Receord[] public historyReceords;
    mapping(address => uint256[]) indexs;

    function deposit(uint256 amount) external {
        USDT.transferFrom(msg.sender, RECEIVER, amount);
        uint256 price = getPrice();
        if (price > 0) {
            DDDDS.transferFrom(
                msg.sender,
                RECEIVER,
                (amount * price) / 1 ether
            );
        }
        historyReceords.push(Receord({depositer: msg.sender, amount: amount}));
        uint256 counter = historyReceords.length - 1;
        indexs[msg.sender].push(counter);

        emit Deposit(msg.sender, amount, price);
    }

    function setReceiver(address _receiver) external onlyOwner {
        RECEIVER = _receiver;
    }

    function getPrice() public returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(USDT);
        path[1] = address(DDDDS);

        try ROUTER.getAmountsOut(1e18, path) returns (
            uint256[] memory amounts
        ) {
            return amounts[0];
        } catch {
            emit Log("external call failed");
            return 0;
        }
    }
}