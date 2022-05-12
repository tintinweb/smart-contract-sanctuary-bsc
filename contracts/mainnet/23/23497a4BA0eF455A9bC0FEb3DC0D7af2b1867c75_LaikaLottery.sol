/**
 *Submitted for verification at BscScan.com on 2022-05-12
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = address (0x58ba02BD12064c691241f7729958e370d1d0d201);
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "not owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "0 owner");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract LaikaLottery is Ownable {
    bool private enableOpen = true;
    uint256 private max = 2;
    uint256 private price = 200000000000000000;
    uint256 private allSoldCount = 0;

    uint256 private currentIndex = 0;
    mapping(uint256 => uint256) private indexCount;
    mapping(uint256 => mapping(uint256 => address)) private indexNumAddress;
    mapping(uint256 => uint256[]) private indexRewardNum;
    mapping(address => uint256) private rewards;

    mapping(uint256 => uint256) private tokenReward;

    constructor(){
        tokenReward[1] = 360000000000000000;
    }

    function buy(uint256 num) external payable {
        address account = msg.sender;
        if (tx.origin != account) {
            return;
        }
        require(enableOpen, "not open");
        uint256 qty = max - indexCount[currentIndex];
        require(qty > 0, "qty exceed");
        require(msg.value >= num * price, "payable not enough");
        if (num > qty) {
            account.call{value : (num - qty) * price}("");
            num = qty;
        }
        allSoldCount += num;

        uint256 no = indexCount[currentIndex];

        for (uint256 i = 0; i < num; i++) {
            indexNumAddress[currentIndex][no] = account;
            no++;
        }
        indexCount[currentIndex] = no;
        if (max == no) {
            _open();
        }
    }

    uint256 _random;

    function _open() private {
        uint256[] memory nos = new uint256[](max);
        for (uint256 i = 0; i < max; i++) {
            nos[i] = i;
        }
        uint256 random = uint256(keccak256(abi.encode(_random, block.number, currentIndex)));
        uint256 index;
        for (uint256 i = 0; i < 1; ++i) {
            index = uint32(random) % (max - i);
            indexRewardNum[currentIndex].push(nos[index]);
            nos[index] = nos[max - 1 - i];
            random = random >> 1;
        }
        uint256 no;
        address account;
        uint256 reward;
        for (uint256 i = 0; i < 1; ++i) {
            no = indexRewardNum[currentIndex][i];
            account = indexNumAddress[currentIndex][no];
            if (0 >= i) {
                reward = 1;
            }
            _giveReward(account, reward);
        }
        currentIndex++;
        _random = random;
    }

    function _giveReward(address addr, uint256 reward) private {
        rewards[addr] += tokenReward[reward];
    }

    function claim() external {
        address account = msg.sender;
        address payable addr = payable(account);
        addr.transfer(rewards[account]);
        rewards[account] = 0;
    }

    function pendingReward(address addr) external view returns (uint256){
        return rewards[addr];
    }

    function info() external view returns (bool, uint256, uint256, uint256, uint256, uint256) {
        return (enableOpen, price, currentIndex, max, indexCount[currentIndex], allSoldCount);
    }

    function indexInfo(uint256 index) external view returns (address[] memory addrs, uint256[] memory rewardNum) {
        uint256 count = indexCount[index];
        addrs = new address[](count);
        for (uint256 i = 0; i < count; i++) {
            addrs[i] = indexNumAddress[index][i];
        }
        rewardNum = indexRewardNum[index];
    }

    function setPrice(uint256 p) external onlyOwner {
        price = p;
    }

    function setEnableOpen(bool e) external onlyOwner {
        enableOpen = e;
    }

    function setTokenReward(uint256 level, uint256 reward) external onlyOwner {
        tokenReward[level] = reward;
    }

    function getTokenReward(uint256 level) external view returns (uint256 reward) {
        reward = tokenReward[level];
    }

    function withdrawERC20(address erc20Address, address account, uint256 amount) external onlyOwner {
        IERC20 erc20 = IERC20(erc20Address);
        erc20.transfer(account, amount);
    }

    function withdrawBalance(address account, uint256 amount) external onlyOwner {
        address payable addr = payable(account);
        addr.transfer(amount);
    }

    receive() external payable {}
}