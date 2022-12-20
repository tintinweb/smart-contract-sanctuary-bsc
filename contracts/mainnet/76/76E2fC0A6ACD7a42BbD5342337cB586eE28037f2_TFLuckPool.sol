pragma solidity >=0.7.0 <0.9.0;

import "./ERC20Upgradeable.sol";
import "./SafeERC20Upgradeable.sol";
import "./SafeMathUpgradeable.sol";
import "./OwnableUpgradeable.sol";
import "./EnumerableSetUpgradeable.sol";
import "./ReentrancyGuardUpgradeable.sol";

contract TFLuckPool is OwnableUpgradeable, ReentrancyGuardUpgradeable {
    using SafeMathUpgradeable for uint;
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    uint public lockBegin;
    uint public lockEnd;
    IERC20Upgradeable public token;

    uint public totalBalance;
    uint public topLimit;
    uint public lastBalance;
    address public lastAddress;

    mapping(address => uint) public balance;
    EnumerableSetUpgradeable.AddressSet topAddress;
    
    uint256[50] private __gap;

    event Deposit(address indexed user, uint amount, uint total);
    event Withdraw(address indexed user, uint amount);

    function initialize(address _token, uint _begin, uint _end) external initializer {
        __Ownable_init();
        token = IERC20Upgradeable(_token);
        require(_begin > block.timestamp, '!_begin');
        require(_end > block.timestamp, '!_end');
        lockBegin = _begin;
        lockEnd = _end;
        topLimit = 50;
        lastBalance = 10000e18;
    }

    function setLockBegin(uint _begin) external onlyOwner {
        lockBegin = _begin;
    }

    function setLockEnd(uint _end) external onlyOwner {
        lockEnd = _end;
    }

    function deposit(uint amount) external nonReentrant {
        require(amount >= 0, '!amount');
        require(lockBegin > block.timestamp, '!timestamp');

        // 计算 用户抵押数
        token.safeTransferFrom(msg.sender, address(this), amount);

        balance[msg.sender] = balance[msg.sender].add(amount);
        totalBalance = totalBalance.add(amount);
        require(totalBalance == token.balanceOf(address(this)) , '!totalBalance');

        if(balance[msg.sender] >= lastBalance) {
            if(topAddress.length() >= topLimit) {
                topAddress.remove(lastAddress);
            }
            topAddress.add(msg.sender);
            sortLast();
        }
        emit Deposit(msg.sender, amount, balance[msg.sender]);
    }

    function sortLast() private {
        if(topAddress.length() < topLimit) {
            return;
        }

        for(uint i = 0; i < topAddress.length(); i ++) {
            address key = topAddress.at(i);
            if(i == 0 || balance[key] < lastBalance) {
                lastAddress = key;
                lastBalance = balance[key];
            }
        }
    }

    function pending() public view returns (address[] memory wallet, uint[] memory amount) {
        uint length = topAddress.length();
        wallet = new address[](length);
        amount = new uint[](length);
        for(uint i = 0; i < length; i ++) {
            address key = topAddress.at(i);
            wallet[i] = key;
            amount[i] = balance[key];
        }
    }

    function withdraw() external nonReentrant {
        require(lockEnd < block.timestamp, '!timestamp');
        uint userAmount = balance[msg.sender];
        totalBalance = totalBalance.sub(userAmount);
        balance[msg.sender] = 0;
        token.safeTransfer(msg.sender, userAmount);
        require(totalBalance == token.balanceOf(address(this)) , '!totalBalance');

        emit Withdraw(msg.sender, userAmount);
    }
}