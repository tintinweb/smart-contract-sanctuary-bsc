/**
 *Submitted for verification at BscScan.com on 2023-01-08
*/

pragma solidity ^0.6.12;

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

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

contract PresaleMetaPlanetary {
    IBEP20 public token;
    using SafeMath for uint256;

    address payable public owner;
    uint256 public minAmount;
    uint256 public maxAmount;
    
    uint256 public preSaleTime;
    uint256 public soldToken;
    uint256 public raisedBNB;
    uint256 public rate;

    mapping(address => uint256) public balances;
    mapping(address => uint256) public balancesBNB;
    mapping(address => bool) public claimed;

    modifier onlyOwner() {
        require(msg.sender == owner, "BEP20: Not an owner");
        _;
    }

    event BuyToken(address _user, uint256 _amount);

    constructor() public {
        owner = payable(msg.sender);
        token = IBEP20(0xb6119339DE7C7B38E788b5D74E0cf49006922eC0);
        rate = 2e5;
        minAmount = 0.01 ether;
        maxAmount = 50 ether;
        preSaleTime = block.timestamp + 30 days;
    }

    receive() external payable {}

    // to buy token during preSale time => for web3 use
    function buyTokenMPY() public payable {
        uint256 numberOfTokens = bnbToToken(msg.value);
        uint256 maxToken = bnbToToken(maxAmount);

        require(
            msg.value >= minAmount && msg.value <= maxAmount,
            "BEP20: Amount not correct"
        );

        require(
            numberOfTokens.add(balances[msg.sender]) <= maxToken,
            "BEP20: Amount exceeded max reservable"
        );

        require(block.timestamp < preSaleTime, "BEP20: PreSale over");

        balances[msg.sender] += numberOfTokens;
        
        // Accounting
        soldToken = soldToken.add(numberOfTokens);
        raisedBNB = raisedBNB.add(msg.value);
        
        emit BuyToken(msg.sender, balances[msg.sender]);
    }

    function claimTokenMPY() public {
        require(block.timestamp > preSaleTime , "presale didn't complete");
        token.transferFrom(owner, msg.sender, balances[msg.sender]);
        balances[msg.sender] = 0;
    }

    // to check number of token for given BNB
    function bnbToToken(uint256 _amount) public view returns (uint256) {
        return (_amount).mul(1e18).div(rate);
    }

    // to change Price of the token
    function changePrice(uint256 _rate) external onlyOwner {
        rate = _rate;
    }

    function setPreSaleAmount(uint256 _minAmount, uint256 _maxAmount)
        external
        onlyOwner
    {
        minAmount = _minAmount;
        maxAmount = _maxAmount;
    }

    function setpreSaleTime(uint256 _time) external onlyOwner {
        preSaleTime = _time;
    }

    // transfer ownership
    function changeOwner(address payable _newOwner) external onlyOwner {
        owner = _newOwner;
    }

    // to draw funds for liquidity
    function transferFunds(uint256 _value) external onlyOwner returns (bool) {
        owner.transfer(_value);
        return true;
    }

    function getCurrentTime() public view returns (uint256) {
        return block.timestamp;
    }

    function contractBalanceBnb() external view returns (uint256) {
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