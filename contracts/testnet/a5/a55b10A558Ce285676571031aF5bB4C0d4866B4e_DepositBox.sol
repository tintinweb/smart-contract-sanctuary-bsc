/**
 *Submitted for verification at BscScan.com on 2022-07-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

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

    function hardcap() external view returns (uint256);

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor(address owner_) {
        _owner = owner_;
        emit OwnershipTransferred(address(0), owner_);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract DepositBox is Ownable {
    using SafeMath for *;
    address payable public paymentWallet;
    address payable public feeWallet;

    uint256 public currentSale;
    uint256 public totalSales;
    uint256 public feePercent;
    uint256 public feeDivider;

    mapping(uint256 => address) public token;
    mapping(uint256 => uint256) public tokenPerEth;
    mapping(uint256 => uint256) public minAmount;
    mapping(uint256 => uint256) public maxAmount;
    mapping(uint256 => uint256) public startTime;
    mapping(uint256 => uint256) public endTime;
    mapping(uint256 => uint256) public amountRaised;
    mapping(uint256 => uint256) public soldToken;
    mapping(uint256 => uint256) public totalInvestors;
    mapping(uint256 => uint256) public hardcap;
    mapping(uint256 => mapping(address => uint256)) public coinBalance;
    mapping(uint256 => mapping(address => uint256)) public tokenBalance;
    mapping(uint256 => address[]) public usersListPerSale;

    event BuyToken(address indexed _user, uint256 indexed _amount);
    event SaleCreated(address indexed _token, uint256 indexed _saleIndex);

    constructor(address payable _paymentWallet, address payable _feeWallet) Ownable(msg.sender) {
        paymentWallet = _paymentWallet;
        feeWallet = _feeWallet;
    }

    receive() external payable {
        _invest(msg.value);
    }

    function invest() public payable {
        _invest(msg.value);
    }

    function _invest(uint256 _ethAmount) internal {
        require(
            block.timestamp >= startTime[currentSale],
            "PreSale not started yet."
        );
        require(block.timestamp < endTime[currentSale], "PreSale ended.");
        require(_ethAmount >= minAmount[currentSale], "Less than min amount");
        require(
            coinBalance[currentSale][msg.sender].add(_ethAmount) <=
                maxAmount[currentSale],
            "Amount exceeds max limit"
        );
        require(
            amountRaised[currentSale] <= hardcap[currentSale],
            "Hardcap reached."
        );
        uint256 _fee = _ethAmount.mul(feePercent).div(feeDivider);
        paymentWallet.transfer(_ethAmount.sub(_fee));
        feeWallet.transfer(_fee);
        if(coinBalance[currentSale][msg.sender] == 0){
            totalInvestors[currentSale]++;
            usersListPerSale[currentSale].push(msg.sender);
        }

        uint256 numberOfTokens = _ethAmount
            .mul(tokenPerEth[currentSale])
            .div(1 ether);
        tokenBalance[currentSale][msg.sender] = tokenBalance[currentSale][
            msg.sender
        ].add(numberOfTokens);
        soldToken[currentSale] = soldToken[currentSale].add(numberOfTokens);
        coinBalance[currentSale][msg.sender] = coinBalance[currentSale][
            msg.sender
        ].add(_ethAmount);
        amountRaised[currentSale] = amountRaised[currentSale].add(_ethAmount);

        emit BuyToken(msg.sender, numberOfTokens);
    }

    function setNextSale(
        address _tokenAddress,
        uint256 _tokenPerEth,
        uint256 _minAmount,
        uint256 _maxAmount,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _hardcap
    ) public {
        currentSale++;
        totalSales++;
        token[currentSale] = _tokenAddress;
        tokenPerEth[currentSale] = _tokenPerEth;
        minAmount[currentSale] = _minAmount;
        maxAmount[currentSale] = _maxAmount;
        startTime[currentSale] = _startTime;
        endTime[currentSale] = _endTime;
        hardcap[currentSale] = _hardcap;
    }

    function setDesiredSale(
        uint256 _saleIndex,
        address _tokenAddress,
        uint256 _tokenPerEth,
        uint256 _minAmount,
        uint256 _maxAmount,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _hardcap
    ) public {
        token[currentSale] = _tokenAddress;
        tokenPerEth[_saleIndex] = _tokenPerEth;
        minAmount[_saleIndex] = _minAmount;
        maxAmount[_saleIndex] = _maxAmount;
        startTime[_saleIndex] = _startTime;
        endTime[_saleIndex] = _endTime;
        hardcap[_saleIndex] = _hardcap;
    }

    function setCurrentSaleIndex(uint256 _saleIndex) public {
        currentSale = _saleIndex;
    }

    function setPaymentWallet(address payable _newWallet) public {
        paymentWallet = _newWallet;
    }

    function setFeeWallet(address payable _newWallet, uint256 _percent, uint256 _divider) public {
        feeWallet = _newWallet;
        feePercent = _percent;
        feeDivider = _divider;
    }

    function removeStuckEth() public {
        feeWallet.transfer(address(this).balance);
    }

    function removeStuckTokens(address _token) public {
        IERC20(_token).transfer(feeWallet, IERC20(_token).balanceOf(address(this)));
    }

    function getUsersListLength(uint256 _saleIndex) public view returns(uint256) {
        return usersListPerSale[_saleIndex].length;
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