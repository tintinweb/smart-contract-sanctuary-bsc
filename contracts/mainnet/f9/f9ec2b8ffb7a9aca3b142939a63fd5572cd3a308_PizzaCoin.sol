/**
 *Submitted for verification at BscScan.com on 2022-11-22
*/

pragma solidity ^0.8.16;

contract PizzaCoin {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    uint256 public totalSupply;
    uint256 public totalMinted;
    string public constant name = "Pizza Coin";
    string public constant symbol = "PIZZA";
    uint256 public constant decimals = 18;
    uint256 constant startSupply = 100e6 * (10**decimals);
    address public constant pizzaTower = 0xb3fFc8fc884203a645B59392c0EC722ae676B5dD;

    constructor() {
        balanceOf[msg.sender] = startSupply;
        totalSupply = startSupply;
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        balanceOf[msg.sender] -= amount;
        if (recipient != address(0)) {
            balanceOf[recipient] += amount;
        } else {
            totalSupply -= amount;
        }
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        if (recipient != address(0)) {
            balanceOf[recipient] += amount;
        } else {
            totalSupply -= amount;
        }
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function mint(address user, uint256 money) external {
        require(msg.sender == pizzaTower, "Access denied");
        uint256 amount = (money * (10**decimals)) / 100;
        balanceOf[user] += amount;
        totalSupply += amount;
        totalMinted += amount;
        emit Transfer(address(0), user, amount);
    }

    function burn(address user, uint256 coins) external {
        require(msg.sender == pizzaTower, "Access denied");
        uint256 amount = coins * (10**decimals);
        balanceOf[user] -= amount;
        totalSupply -= amount;
        emit Transfer(user, address(0), amount);
    }

    function totalBurned() external view returns(uint256) {
        return startSupply + totalMinted - totalSupply;
    }
}