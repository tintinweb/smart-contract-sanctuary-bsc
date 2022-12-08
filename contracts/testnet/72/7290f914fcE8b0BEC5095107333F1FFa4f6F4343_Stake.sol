// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

interface IBEP20 {
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

contract Stake {
    // address public _tokenAddr;
    IBEP20 public _tokenAddr;
    address public _ceoAddr;
    uint256 fee = 3;
    uint256 day = 86400;
    mapping(address => uint256) public stakeData;
    mapping(address => uint256) public dateData;
    mapping(address => uint256) public rewardData;

    constructor(address tokenAddr, address ceoAddr) {
        _tokenAddr = IBEP20(tokenAddr);
        _ceoAddr = ceoAddr;
    }

    function deposit(uint256 amount) public {
        // require(msg.value >= amount, "invalid amount");

        if (stakeData[msg.sender] > 0) {
            uint256 stakeInterval = block.timestamp - dateData[msg.sender];
            uint256 reward = stakeData[msg.sender] *
                (fee / 1000) *
                (stakeInterval / day);
            rewardData[msg.sender] = rewardData[msg.sender] + reward;
        }

        IBEP20(_tokenAddr).transferFrom(
            msg.sender,
            address(this),
            amount * (10**18)
        );
        stakeData[msg.sender] = stakeData[msg.sender] + amount * (10**18);
        dateData[msg.sender] = block.timestamp;
        // _tokenAddr.transferFrom(msg.sender, address(this), amount);
        IBEP20(_tokenAddr).transfer(
            _ceoAddr,
            ((amount * fee * (10**18)) / 100)
        );
    }

    function withdraw() public {
        require(stakeData[msg.sender] > 0, "YOU did not stake yet.");

        uint256 stakeInterval = block.timestamp - dateData[msg.sender];
        uint256 reward = stakeData[msg.sender] *
            (fee / 1000) *
            (stakeInterval / day);
        uint256 claimAmount = rewardData[msg.sender] + reward;
        dateData[msg.sender] = block.timestamp;
        rewardData[msg.sender] = 0;
        uint256 withdrawAmount = (stakeData[msg.sender] * (100 - fee)) / 100;
        stakeData[msg.sender] = 0;
        IBEP20(_tokenAddr).transfer(msg.sender, (claimAmount + withdrawAmount));
    }

    function claim() public {
        require(stakeData[msg.sender] > 0, "YOU did not stake yet.");
        uint256 stakeInterval = block.timestamp - dateData[msg.sender];
        uint256 reward = stakeData[msg.sender] *
            (fee / 1000) *
            (stakeInterval / day);
        uint256 claimAmount = rewardData[msg.sender] + reward;
        IBEP20(_tokenAddr).transfer(msg.sender, claimAmount);
        dateData[msg.sender] = block.timestamp;
        rewardData[msg.sender] = 0;
    }
}