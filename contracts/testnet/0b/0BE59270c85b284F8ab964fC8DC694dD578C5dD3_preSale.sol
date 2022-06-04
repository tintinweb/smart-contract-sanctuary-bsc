/**
 *Submitted for verification at BscScan.com on 2022-06-03
*/

pragma solidity ^0.8.4;

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

contract preSale {
    IBEP20 public token;
    using SafeMath for uint256;

    address payable public owner;
    address public referral = 0x58920C303256d6CdfF2177c7d3F7F422aCBf56F4;

    uint256 public tokenPerBnb;
    uint256 public startingTime;
    uint256 public amountRaised;
    uint256 public soldToken;
    uint256 public referralpercent;
    uint256 public endingTime;
    uint256 public whiteListTime;
    uint256 public totalSupply = 16000000 * 1e18;
    mapping(address => bool) public _isWhiteListed;

    modifier onlyOwner() {
        require(msg.sender == owner, "BEP20: Not an owner");
        _;
    }

    event BuyToken(address _user, uint256 _amount);

    constructor(
        address payable _owner,
        address _token,
        uint256 _StartTime
    ) {
        owner = _owner;
        token = IBEP20(_token);
        tokenPerBnb = 4000;
        startingTime = _StartTime;
        whiteListTime = startingTime.sub(10 minutes);
        endingTime = startingTime + 3 days;
        referralpercent = 2;
    }

    receive() external payable {}

    // to buy token during preSale time => for web3 use
    function buyToken(address _referral) public payable {
        if (!_isWhiteListed[msg.sender]) {
            require(block.timestamp > startingTime, "PreSale Not Started Yet");
        } else {
            require(block.timestamp > whiteListTime, " PreSale over");
        }
        uint256 numberOfTokens = bnbToToken(msg.value);
        require(soldToken <= totalSupply, " Sold out");

        if (_referral == referral) {
            token.transferFrom(
                owner,
                msg.sender,
                numberOfTokens.mul(referralpercent).div(100)
            );
        }

        token.transferFrom(owner, msg.sender, numberOfTokens);
        amountRaised = amountRaised.add(msg.value);
        soldToken = soldToken.add(numberOfTokens);
        emit BuyToken(msg.sender, numberOfTokens);
    }

    // to check number of token for given BNB
    function bnbToToken(uint256 _amount) public view returns (uint256) {
        uint256 numberOfTokens = _amount.mul(tokenPerBnb);
        return numberOfTokens;
    }

    function getCurrentTime() external view returns (uint256) {
        return block.timestamp;
    }

    // to Change  time
    function setPreSaleTime(
        uint256 _sTime,
        uint256 _eTime,
        uint256 _wlTime
    ) external onlyOwner {
        startingTime = _sTime;
        whiteListTime = _wlTime;
        endingTime = _eTime;
    }

    // to change price
    function setPriceOfToken(uint256 _totalTokenForSale, uint256 _price)
        external
        onlyOwner
    {
        tokenPerBnb = _price;
        totalSupply = _totalTokenForSale;
    }

    // to ref percent
    function setRefPercent(address _newAddress, uint256 _percent)
        external
        onlyOwner
    {
        referralpercent = _percent;
        referral = _newAddress;
    }

    // transfer ownership
    function changeOwner(address payable _newOwner) external onlyOwner {
        owner = _newOwner;
    }

    function setToken(address newtoken) public onlyOwner {
        token = IBEP20(newtoken);
    }

    function whiteListUser(address[] memory users, bool _state)
        public
        onlyOwner
    {
        for (uint256 i; i < users.length; i++) {
            _isWhiteListed[users[i]] = _state;
        }
    }

    // to draw funds for liquidity
    function migrateFunds(uint256 _value) external onlyOwner {
        owner.transfer(_value);
    }

    function migrateTokens(uint256 _value) external onlyOwner {
        token.transfer(owner, _value);
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