// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

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

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

contract PresaleContract is IBEP20, ReentrancyGuard {
    struct presaleItem {
        uint256 startTime;
        uint256 amount;
        uint256 claimedTillNow;
        uint8 index;
    }

    IBEP20 public _KindToken;

    bool public saleStart = false;
    uint256 public price = 1167 * 10**11;
    uint256 public _decimal = 10**9;
    uint256 public endDate;
    uint256 _amount;
    uint256 public tokensSold;
    uint256 public tokensWithdrawnTillNow;

    event BuyKindTokens(address indexed from, uint256 value);

    address public owner;
    address public treasuryWallet;

    mapping(address => presaleItem) public presaleAddr;

    uint256[] public lockPercents = [20, 25, 30, 25];
    uint256[] public lockDays = [
        270 days,
        365 days,
        540 days,
        730 days
    ];

    address public immutable deadWallet = 0x000000000000000000000000000000000000dEaD;

    uint256 public kindSupply = 10**16;
    uint256 public userThreshold = 10**14;

    constructor(address _tokenaddress) {
        _KindToken = IBEP20(_tokenaddress);
        owner = msg.sender;
        treasuryWallet = msg.sender;
    }

    function setStart() public onlyOwner {
        saleStart = !saleStart;
    }

    function setEndDate(uint256 _enddate) public onlyOwner {
        endDate = _enddate;
    }

    function buyToken() public payable nonReentrant {
        require(saleStart, "Sale didn't start. Please wait");
        require(endDate != 0, "Didn't set endDate yet");
        require(block.timestamp <= endDate, "Presale has already finished");
        _amount = (msg.value * _decimal) / price;
        require(_amount <= kindSupply - tokensSold, "Amount exceedes Presale tokens limit");
        require(_amount <= userThreshold - presaleAddr[msg.sender].amount, "user threshold exceeds" );
        presaleAddr[msg.sender].startTime = calculationTime();
        presaleAddr[msg.sender].amount = presaleAddr[msg.sender].amount + _amount;
        tokensSold = tokensSold + _amount;
        emit BuyKindTokens(msg.sender, _amount);
    }

    function calculationTime() internal view returns (uint256) { 
        return block.timestamp - (block.timestamp % 86400); // 59936 1660840736 - (1660840736 % 86400) = 1660780800
    }

    function withDraw() external nonReentrant {
        presaleItem storage user = presaleAddr[msg.sender];
        uint8 _index = user.index;
        require(
            saleStart == true && user.amount > 0,
            "Impossible to withdraw tokens if Presale still disabled"
        );
        require(_index < 4, "You have already claimed all ");

        require(
            user.startTime + lockDays[_index] <= block.timestamp,
            "Please wait! You can not withdraw now"
        );
        uint256 withdrawAmount = (lockPercents[_index] * user.amount) / 100;

        _KindToken.transfer(
            msg.sender, withdrawAmount
        );
        user.claimedTillNow = user.claimedTillNow + withdrawAmount;
        tokensWithdrawnTillNow = tokensWithdrawnTillNow + withdrawAmount;
        user.index = user.index + 1;
    }

    function getInfoAmount(address _addr) external view returns (uint256) {
        presaleItem storage user = presaleAddr[_addr];
        if (user.startTime == 0 || user.index == 4) return 0;
        return (user.amount * lockPercents[user.index]) / 100;
    }

    function getInfoPeriod(address _addr) external view returns (uint256) {
        presaleItem storage user = presaleAddr[_addr];
        if (user.startTime == 0 || user.index == 4) return 0;
        uint256 nextDay = lockDays[user.index];
        return user.startTime + nextDay;
    }

    function adminWithdraw() external payable onlyOwner {
        payable(treasuryWallet).transfer(address(this).balance);
    }

    function kindWithdraw() external onlyOwner {
        require(block.timestamp >= endDate, "Presale is yet to be finished");
         _KindToken.transfer(
            deadWallet, _KindToken.balanceOf(address(this))
        );
    }

    function setTreasuryWallet(address _addr) public onlyOwner {
        treasuryWallet = _addr;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function totalSupply() external view override returns (uint256) {}

    function decimals() external view override returns (uint8) {}

    function symbol() external view override returns (string memory) {}

    function name() external view override returns (string memory) {}

    function getOwner() external view override returns (address) {}

    function balanceOf(address account)
        external
        view
        override
        returns (uint256)
    {}

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {}

    function allowance(address _owner, address spender)
        external
        view
        override
        returns (uint256)
    {}

    function approve(address spender, uint256 amount)
        external
        override
        returns (bool)
    {}

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {}
}