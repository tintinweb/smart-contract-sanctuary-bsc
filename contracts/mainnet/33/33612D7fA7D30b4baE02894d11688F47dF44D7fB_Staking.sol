/**
 *Submitted for verification at BscScan.com on 2022-10-09
*/

pragma solidity ^0.8.17;

// SPDX-License-Identifier: MIT

interface IBEP20 {
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

contract Staking {
    address owner;
    address token;
    address taxWallet;
    uint256 taxPer;
    uint256 awardPer;
    uint256 punishPer;
    uint256 minStake;
    uint256 maxTime;

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    struct Stake {
        uint256 amount;
        uint256 created;
        bool withdrawn;
    }

    mapping(address => Stake[]) public stakes;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function balanceOf(address account) public view returns (uint256) {
        return IBEP20(token).balanceOf(account);
    }

    function getTokenAdd() public view returns (address) {
        return token;
    }

    function stake(uint256 amount) public {
        require(amount >= minStake, "Amount too low");
        address user = msg.sender;
        IBEP20(token).transferFrom(user, address(this), amount);
        stakes[msg.sender].push(Stake(amount, block.timestamp, false));
        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 index) public {
        require(index < stakes[msg.sender].length, "Invalid index");
        Stake memory userStake = stakes[msg.sender][index];
        require(!userStake.withdrawn, "Already withdrawn");
        uint256 amount = userStake.amount;
        uint256 time = block.timestamp - userStake.created;
        uint256 tax = (amount * taxPer) / 100;
        uint256 award = (amount * awardPer) / 100;
        uint256 punish = (amount * punishPer) / 100;
        address user = msg.sender;
        if (time >= maxTime) {
            if (tax > 0) {
                require(
                IBEP20(token).transfer(taxWallet, tax),
                "Transfer failed for taxes");
            }
            if (amount + award - tax > 0) {
                require(
                IBEP20(token).transfer(user, amount + award - tax),
                "Transfer failed for award");
            }
        } else {
            if (punish + tax > 0) {
                require(
                IBEP20(token).transfer(taxWallet, punish + tax),
                "Transfer failed for punish");
            }
            require(
                IBEP20(token).transfer(user, amount - tax - punish),
                "Transfer failed for withdraw"
            );
        }
        userStake.withdrawn = true;
        userStake.created = 0;
        stakes[msg.sender][index] = userStake;
        emit Withdrawn(msg.sender, amount);
    }

    function getUserData(address user) public view returns (Stake[] memory) {
        return stakes[user];
    }

    function getMaxTime() public view returns (uint256) {
        return maxTime;
    }

    function transferBack(uint256 amount, address rec) public onlyOwner {
        require(
            IBEP20(token).transfer(rec, amount),
            "Transfer failed"
        );
    }

    function getAmount(uint256 index) public view returns (uint256) {
        require(index < stakes[msg.sender].length, "Invalid index");
        return stakes[msg.sender][index].amount;
    }

    function getPercentages()
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        return (taxPer, awardPer, punishPer);
    }

    function changeOwner(address _owner) public onlyOwner {
        owner = _owner;
    }

    function changeTaxWallet(address _taxWallet) public onlyOwner {
        taxWallet = _taxWallet;
    }

    function changeMinStake(uint256 _minStake) public onlyOwner {
        minStake = _minStake;
    }

    function changePunishPer(uint256 _punishPer) public onlyOwner {
        punishPer = _punishPer;
    }

    // In days
    function changeMaxTime(uint256 _maxTime) public onlyOwner {
        maxTime = _maxTime * 3600;
    }

    function changeAwardPer(uint256 _awardPer) public onlyOwner {
        awardPer = _awardPer;
    }

    function changeTaxPer(uint256 _taxPer) public onlyOwner {
        taxPer = _taxPer;
    }

    function changeToken(address _token) public onlyOwner {
        token = _token;
    }

}