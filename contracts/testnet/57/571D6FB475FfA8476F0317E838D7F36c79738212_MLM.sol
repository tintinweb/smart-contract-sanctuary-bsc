/**
 *Submitted for verification at BscScan.com on 2022-05-20
*/

pragma solidity ^0.8.10;

// SPDX-License-Identifier: MIT

interface IERC20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external;

    function transfer(address to, uint256 value) external;

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external;
}

contract MLM {
    using SafeMath for uint256;
    IERC20 public usdt;

    address payable public admin;
    address payable public bot;

    uint256 totalUsers;
    struct User {
        string name;
        address userAddress;
        uint256 amountDeposit;
        bool alreadyExists;
    }
    mapping(address => User) public user;
    mapping(uint256 => address) public userID;

    event Deposit(address user, uint256 amount);
    modifier onlyAdmin() {
        require(admin == msg.sender, "only admin");
        _;
    }

    constructor(
        address _admin,
        address _usdt,
        address _bot
    ) {
        admin = payable(_admin);
        bot = payable(_bot);
        usdt = IERC20(_usdt);
    }

    function Invest(uint256 amount, string memory _name) public {
        require(amount >= 0, "amount should be more than 0");
        if (!user[msg.sender].alreadyExists) {
            user[msg.sender].alreadyExists = true;

            totalUsers++;
        }
        usdt.transferFrom(msg.sender, address(this), amount);

        user[msg.sender].name = _name;
        user[msg.sender].userAddress = msg.sender;
        user[msg.sender].amountDeposit = user[msg.sender].amountDeposit.add(
            amount
        );
        bot.transfer(amount);
        emit Deposit(msg.sender, amount);
    }

    function changeAdmin(address newAdmin) public onlyAdmin {
        admin = payable(newAdmin);
    }

    function changeToken(address newToken) public onlyAdmin {
        usdt = IERC20(newToken);
    }

    function changeBot(address newBot) public onlyAdmin {
        bot = payable(newBot);
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}