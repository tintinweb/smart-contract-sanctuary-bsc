/**
 *Submitted for verification at BscScan.com on 2022-04-19
*/

pragma solidity ^0.8.10;

//SPDX-License-Identifier: MIT Licensed

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

contract preSalePhase1 {
    IBEP20 public token;
    using SafeMath for uint256;

    address payable public owner;

    uint256 public tokenPerBnb;
    uint256 public endTime;
    uint256 public amountRaised;
    uint256 public soldToken;
    uint256 public startTime;
    uint256 public totalSupply;
    uint256 public minAmount;
    uint256 public maxAmount;
    uint256[6] public plans = [
        0.05 ether,
        0.1 ether,
        0.5 ether,
        1 ether,
        5 ether,
        10 ether
    ];
    uint256[6] public bonus = [0, 1000, 2000, 3000, 4000, 5000];
    uint256 public percentDivider = 10000;

    mapping(address => uint256) public coinBalance;
    mapping(address => uint256) public tokenBalance;

    modifier onlyOwner() {
        require(msg.sender == owner, "BEP20: Not an owner");
        _;
    }

    event BuyToken(address _user, uint256 _amount);

    constructor(address payable _owner, address _token) {
        owner = _owner;
        token = IBEP20(_token);
        tokenPerBnb = 15000000;
        minAmount = 0.05 ether;
        maxAmount = 10 ether;
        totalSupply = 1500000000;
        startTime = block.timestamp;
        endTime = block.timestamp + 45 days;
    }

    receive() external payable {}

    // to buy token during preSale time => for web3 use
    function buyToken(uint256 planIndex) public payable {
        require(planIndex < 6, "Invalid plan");
        require(msg.value == plans[planIndex], "invalid amount");

        require(
            block.timestamp > startTime,
            "BEP20: wait for owner to start presale "
        );
        require(block.timestamp < endTime, "BEP20: PreSale over");
        require(
            coinBalance[msg.sender].add(msg.value) <= maxAmount,
            "PRESALE: Amount exceeds max limit"
        );
        require(msg.value >= minAmount, "PRESALE: Amount less than min amount");

        uint256 numberOfTokens = bnbToToken(msg.value);
        uint256 bonusAmount = numberOfTokens.mul(bonus[planIndex]).div(percentDivider);
        token.transferFrom(owner, msg.sender, numberOfTokens.add(bonusAmount));

        amountRaised = amountRaised.add(msg.value);
        coinBalance[msg.sender] = coinBalance[msg.sender].add(msg.value);
        soldToken = soldToken.add(numberOfTokens);
        tokenBalance[msg.sender] = tokenBalance[msg.sender].add(numberOfTokens);

        emit BuyToken(msg.sender, numberOfTokens);
    }

    //  to check number of token for given BNB
    function bnbToToken(uint256 _amount) public view returns (uint256) {
        uint256 numberOfTokens = _amount.mul(tokenPerBnb).div(1e18);
        return numberOfTokens.mul(1e9);
    }

    function Setplans(
        uint256 first,
        uint256 second,
        uint256 third,
        uint256 fourth,
        uint256 fifth,
        uint256 sixth
    ) external onlyOwner {
        plans[0] = first;
        plans[1] = second;
        plans[2] = third;
        plans[3] = fourth;
        plans[4] = fifth;
        plans[5] = sixth;
    }

    function SetBonus(
        uint256 first,
        uint256 second,
        uint256 third,
        uint256 fourth,
        uint256 fifth,
        uint256 sixth
    ) external onlyOwner {
        bonus[0] = first;
        bonus[1] = second;
        bonus[2] = third;
        bonus[3] = fourth;
        bonus[4] = fifth;
        bonus[5] = sixth;
    }

    // to change price
    function setPercentDivider(uint256 divider) external onlyOwner {
        percentDivider = divider;
    }

    // to change price
    function setPriceOfToken(uint256 _price) external onlyOwner {
        tokenPerBnb = _price;
    }

    function getProgress() public view returns (uint256 _percent) {
        uint256 remaining = totalSupply.sub(soldToken.div(1e9));
        remaining = remaining.mul(100).div(totalSupply);
        uint256 hundred = 100;
        return hundred.sub(remaining);
    }

    function setPreSaletLimits(
        uint256 _minAmount,
        uint256 _maxAmount,
        uint256 _total
    ) external onlyOwner {
        minAmount = _minAmount;
        maxAmount = _maxAmount;
        totalSupply = _total;
    }

    // transfer ownership
    function changeOwner(address payable _newOwner) external onlyOwner {
        owner = _newOwner;
    }

    function setToken(address newtoken) public onlyOwner {
        token = IBEP20(newtoken);
    }

    function setPresaleTime(uint256 _startTime, uint256 _endTime)
        public
        onlyOwner
    {
        startTime = _startTime;
        endTime = _endTime;
    }

    // to draw funds for liquidity
    function migrateFunds(uint256 _value) external onlyOwner {
        owner.transfer(_value);
    }

    function removeStuckToken(
        IBEP20 _token,
        address _account,
        uint256 _amount
    ) external onlyOwner {
        _token.transfer(_account, _amount);
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getContractTokenBalance() external view returns (uint256) {
        return token.allowance(owner, address(this));
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