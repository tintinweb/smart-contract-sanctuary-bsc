/**
 *Submitted for verification at BscScan.com on 2022-06-13
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.7;

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

contract LaunchPool {
    using SafeMath for uint256;
    address payable public owner;
    uint256[3] public vestDuration = [0, 30 days, 60 days];
    uint256[3] public vestingClaim = [30, 35, 35]; // in percentage

    IERC20 tokenSell;
    uint64 perTokenBuy;
    uint256 public startTime;
    uint256 public endTime;
    uint256 totalTokenSell;
    uint256 softCap;
    uint256 hardCap;
    uint256 maxBuy;
    uint256 minBuy;
    uint256 public alreadyRaised;
    bool release;
    uint256 releaseTime;

    struct UserInfo {
        uint256 totalToken;
        uint256 totalSpent;
        bool firstClaim;
        bool secondClaim;
        bool thirdClaim;
    }

    enum Claims {
        FIRST_CLAIM,
        SECOND_CLAIM,
        THIRD_CLAIM,
        FAILED
    }

    mapping(address => UserInfo) public usersTokenBought; // userAddress => User Info

    modifier onlyOwner() {
        require(owner == msg.sender, "only owner");
        _;
    }

    modifier withdrawCheck() {
        require(getSoftFilled() == true, "Can't withdraw");
        _;
    }

    event BUY(address Buyer, uint256 amount);
    event CLAIM(address Buyer, Claims claim);
    event RELEASE(bool released);

    constructor(address payable _owner) {
        owner = _owner;
    }

    // onlyOwner Function
    function setEventPeriod(uint256 _startTime, uint256 _endTime)
        external
        onlyOwner
    {
        require(address(tokenSell) != address(0), "Setup raised first");
        require(_startTime != 0, "Cannot set 0 value");
        require(_endTime > _startTime, "End time must be greater");
        startTime = _startTime;
        endTime = _endTime;
    }

    function setRaised(
        address _tokenSale,
        uint64 _perTokenBuy,
        uint256 _softcap,
        uint256 _hardcap,
        uint256 _maxBuy,
        uint256 _minBuy
    ) external onlyOwner {
        // _tokenBuy gabutuh, total token sale diitung dari hardcap * per tokenbuy
        require(startTime == 0, "Raising period already start");
        require(_hardcap > _softcap, "Hardcap must greater than softcap");

        tokenSell = IERC20(_tokenSale);

        uint256 _totalTokenSale = _hardcap.mul(_perTokenBuy);

        uint256 allowance = tokenSell.allowance(msg.sender, address(this));
        uint256 balance = tokenSell.balanceOf(msg.sender);
        require(balance >= _totalTokenSale, "Not enough tokens");
        require(allowance >= _totalTokenSale, "Check the token allowance");

        perTokenBuy = _perTokenBuy;
        totalTokenSell = _totalTokenSale;
        softCap = _softcap;
        hardCap = _hardcap;
        maxBuy = _maxBuy; // in BNB
        minBuy = _minBuy; // in BNB
        tokenSell.transferFrom(msg.sender, address(this), _totalTokenSale);
    }

    function setRelease(bool _release) external onlyOwner {
        require(startTime != 0, "Raise no start");
        require(release != _release, "Can't setup same release");
        require(getSoftFilled(), "Softcap not fullfiled");
        if (getHardFilled() == false) {
            require(block.timestamp > endTime, "Raising not end");
        }
        release = _release;
        releaseTime = block.timestamp;

        emit RELEASE(_release);
    }

    function withdrawBNB() public onlyOwner withdrawCheck {
        uint256 balance = address(this).balance;
        require(balance > 0, "does not have any balance");
        payable(msg.sender).transfer(balance);
    }

    function withdrawToken(address _tokenAddress, uint256 _amount)
        public
        onlyOwner
        withdrawCheck
    {
        IERC20(_tokenAddress).transfer(msg.sender, _amount);
    }

    // Buy Function
    function getHardFilled() public view returns (bool) {
        return alreadyRaised >= hardCap;
    }

    function getSoftFilled() public view returns (bool) {
        return alreadyRaised >= softCap;
    }

    function getSellTokenAmount(uint256 _amount)
        internal
        view
        returns (uint256)
    {
        return _amount * perTokenBuy;
    }

    function buy() external payable {
        require(block.timestamp != 0, "Raising period not set");
        require(block.timestamp >= startTime, "Raising period not started yet");
        require(block.timestamp < endTime, "Raising period already end");
        require(msg.value > 0, "Please input value");
        require(getHardFilled() == false, "Raise already fullfilled");
        require(msg.value >= minBuy, "Less than min buy");
        require(msg.value <= maxBuy, "More than max buy");
        require(
            msg.value + alreadyRaised <= hardCap,
            "amount buy more than total hardcap"
        );


        UserInfo memory userInfo = usersTokenBought[msg.sender];

        uint256 tokenSellAmount = getSellTokenAmount(msg.value);
        userInfo.totalToken = userInfo.totalToken.add(tokenSellAmount);
        userInfo.totalSpent = userInfo.totalSpent.add(msg.value);
        usersTokenBought[msg.sender] = userInfo;

        alreadyRaised = alreadyRaised.add(msg.value);

        emit BUY(msg.sender, tokenSellAmount);
    }

    // Claim Function
    function claimFailed() external {
        require(block.timestamp > endTime, "Raising not end");
        require(getSoftFilled() == false, "Soft cap already fullfiled");

        uint256 userSpent = usersTokenBought[msg.sender].totalSpent;

        require(userSpent > 0, "Already claimed");

        payable(msg.sender).transfer(userSpent);

        delete usersTokenBought[msg.sender];
        emit CLAIM(msg.sender, Claims.FAILED);
    }

    modifier checkPeriod(uint256 _claim) {
        require(
            vestDuration[_claim] + releaseTime <= block.timestamp,
            "Claim not avalaible yet"
        );
        _;
    }

    function claimSuccess(Claims _claim) external checkPeriod(uint256(_claim)) {
        require(release, "Not Release Time");
        UserInfo memory userInfo = usersTokenBought[msg.sender];
        require(userInfo.totalToken > 0, "You can't claim any amount");

        uint256 amountClaim;
        Claims claim;

        if (_claim == Claims.FIRST_CLAIM) {
            require(userInfo.firstClaim == false, "Already claim");
            amountClaim = userInfo.totalToken.mul(vestingClaim[0]).div(100);
            userInfo.firstClaim = true;
            claim = Claims.FIRST_CLAIM;
        }
        if (_claim == Claims.SECOND_CLAIM) {
            require(userInfo.secondClaim == false, "Already claim");
            amountClaim = userInfo.totalToken.mul(vestingClaim[1]).div(100);
            userInfo.secondClaim = true;
            claim = Claims.SECOND_CLAIM;
        }
        if (_claim == Claims.THIRD_CLAIM) {
            require(userInfo.thirdClaim == false, "Already claim");
            amountClaim = userInfo.totalToken.mul(vestingClaim[2]).div(100);
            userInfo.thirdClaim = true;
            claim = Claims.THIRD_CLAIM;
        }

        usersTokenBought[msg.sender] = userInfo;
        tokenSell.transfer(msg.sender, amountClaim);
        emit CLAIM(msg.sender, claim);
    }
}