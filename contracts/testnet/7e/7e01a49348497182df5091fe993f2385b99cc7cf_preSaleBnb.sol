/**
 *Submitted for verification at BscScan.com on 2023-03-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
pragma experimental ABIEncoderV2;

interface IDexRouter {
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );
}

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

contract Ownable {
    address payable private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = payable(msg.sender);
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address payable) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = payable(address(0));
    }

    function transferOwnership(address payable newOwner)
        public
        virtual
        onlyOwner
    {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract preSaleBnb is Ownable {
    using SafeMath for uint256;

    IERC20 public token;
    address public tokenOwner;
    IDexRouter public routerAddress;

    uint256 public tokenPrice;
    uint256 public bnbFeePercent;
    uint256 public tokenFeePercent;
    uint256 public referralPercent;
    uint256 public presaleStartTime;
    uint256 public preSaleEndTime;
    uint256 public minAmount;
    uint256 public maxAmount;
    uint256 public softCap;
    uint256 public hardCap;
    uint256 public listingPrice;
    uint256 public liquidityPercent;
    uint256 public totalUser;
    uint256 public soldTokens;
    uint256 public amountRaised;
    uint256 public percentDivider;

    bool public allow;
    bool public canClaim;
    bool public refund;
    bool public whitelistEnable;
    bool public publicEnable;

    struct User {
        uint256 coinBalance;
        uint256 tokenBalance;
        uint256 referralBonus;
        uint256 claimedAmount;
        bool isClaimed;
    }

    mapping(address => User) public users;
    mapping(address => bool) public whitelistedUsers;

    modifier allowed() {
        require(allow == true, "Pegasus: Not allowed");
        _;
    }

    event tokenBought(
        address indexed user,
        uint256 indexed numberOfTokens,
        uint256 indexed amountBusd
    );

    event tokenClaimed(address indexed user, uint256 indexed numberOfTokens);

    event unSoldTokens(address indexed user, uint256 indexed numberOfTokens);

    constructor(
        IERC20 _token,
        uint256[12] memory _values,
        // uint256 _bnbFee,
        // uint256 _tokenFee,
        // uint256 _referralPercent,
        // uint256 _presaleStartTime,
        // uint256 _presaleEndTime,
        // uint256 _minAmount,
        // uint256 _maxAmount,
        // uint256 _hardCap,
        // uint256 _softCap,
        // uint256 _listingPrice,
        // uint256 _liquidityPercent,
        bool _refund
    ) {
        token = _token;
        tokenPrice = _values[0];
        bnbFeePercent = _values[1];
        tokenFeePercent = _values[2];
        referralPercent = _values[3];
        presaleStartTime = _values[4];
        preSaleEndTime = _values[5];
        minAmount = _values[6];
        maxAmount = _values[7];
        hardCap = _values[8];
        softCap = _values[9];
        listingPrice = _values[10];
        liquidityPercent = _values[11];
        refund = _refund;
        allow = true;
        routerAddress = IDexRouter(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd);
        percentDivider = 100;
    }

    receive() external payable {
        _buy(address(0), msg.value);
    }

    // to buy token during preSale time => for web3 use
    function buy(address referrer) public payable {
        _buy(referrer, msg.value);
    }

    function _buy(address referrer, uint256 amount) internal allowed {
        require(
            block.timestamp > presaleStartTime,
            "Pegasus: Wait for start time"
        );
        require(block.timestamp < preSaleEndTime, "Pegasus: Time over");

        if (whitelistEnable) {
            require(
                whitelistedUsers[msg.sender],
                "Pegasus: User not whitelisted"
            );
        } else {
            require(publicEnable, "Pegasus: Public sale not started");
        }

        require(amount >= minAmount, "Pegasus: Less than min amount");
        require(
            users[msg.sender].coinBalance.add(amount) <= maxAmount,
            "Pegasus: Greater than max amount"
        );
        require(
            amountRaised.add(amount) <= hardCap,
            "Pegasus: Hardcap reached"
        );

        if (users[msg.sender].coinBalance == 0) {
            totalUser++;
        }
        if (referralPercent > 0) {
            if (referrer != msg.sender && referrer != address(0)) {
                users[referrer].referralBonus = amount
                    .mul(referralPercent)
                    .div(percentDivider);
            }
        }
        uint256 numberOfTokens = bnbToToken(amount);
        users[msg.sender].tokenBalance += numberOfTokens;
        soldTokens += numberOfTokens;
        users[msg.sender].coinBalance += amount;
        amountRaised += amount;

        emit tokenBought(msg.sender, numberOfTokens, amount);
    }

    function claim() public allowed {
        require(canClaim == true, "Pegasus: Wait for admin to finalize");
        uint256 numberOfTokens;
        if (amountRaised < softCap) {
            require(!users[msg.sender].isClaimed, "Pegasus: Already claimed");
            numberOfTokens = users[msg.sender].coinBalance;
            require(numberOfTokens > 0, "Pegasus: Zero balance");
            payable(msg.sender).transfer(numberOfTokens);
            users[msg.sender].isClaimed = true;
        } else {
            require(!users[msg.sender].isClaimed, "Pegasus: Already claimed");
            numberOfTokens = users[msg.sender].tokenBalance.add(
                users[msg.sender].referralBonus
            );
            require(numberOfTokens > 0, "Pegasus: Zero balance");
            token.transfer(msg.sender, numberOfTokens);
            users[msg.sender].claimedAmount = numberOfTokens;
            users[msg.sender].isClaimed = true;
        }
        emit tokenClaimed(msg.sender, numberOfTokens);
    }

    function finalize() public onlyOwner {
        require(
            block.timestamp > preSaleEndTime || amountRaised >= hardCap,
            "Pegasus: PreSale not over yet"
        );
        canClaim = true;
        if (amountRaised > softCap) {
            uint256 bnbAmountForLiquidity = amountRaised
                .mul(liquidityPercent)
                .div(percentDivider);
            uint256 tokenAmountForLiquidity = listingTokens(
                bnbAmountForLiquidity
            );
            token.approve(address(routerAddress), tokenAmountForLiquidity);
            addLiquidity(
                tokenOwner,
                bnbAmountForLiquidity,
                tokenAmountForLiquidity
            );

            if (bnbFeePercent > 0) {
                owner().transfer(
                    amountRaised.mul(bnbFeePercent).div(percentDivider)
                );
            }
            if (tokenFeePercent > 0) {
                token.transfer(
                    owner(),
                    soldTokens.mul(bnbFeePercent).div(percentDivider)
                );
            }

            payable(tokenOwner).transfer(getContractCoinBalance());
            uint256 remainingAmount = getContractTokenBalance().sub(soldTokens);
            if (remainingAmount > 0) {
                if (refund == true) {
                    token.transfer(tokenOwner, remainingAmount);
                    emit unSoldTokens(tokenOwner, remainingAmount);
                } else {
                    token.transfer(address(0), remainingAmount);
                    emit unSoldTokens(address(0), remainingAmount);
                }
            }
        } else {
            token.transfer(owner(), getContractTokenBalance());

            emit unSoldTokens(owner(), getContractCoinBalance());
        }
    }

    function addLiquidity(
        address receiver,
        uint256 tokenAmount,
        uint256 bnbAmount
    ) internal {
        // add the liquidity
        routerAddress.addLiquidityETH{value: bnbAmount}(
            address(token),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            receiver,
            block.timestamp
        );
    }

    // to check number of token for buying
    function bnbToToken(uint256 _amount)
        public
        view
        returns (uint256 numberOfTokens)
    {
        numberOfTokens = _amount
            .mul(tokenPrice)
            .mul(10**(token.decimals()))
            .div(1 ether);
    }

    // to calculate number of tokens for listing price
    function listingTokens(uint256 _amount)
        public
        view
        returns (uint256 numberOfTokens)
    {
        numberOfTokens = _amount
            .mul(listingPrice)
            .mul(10**(token.decimals()))
            .div(1 ether);
    }

    // to Stop preSale in case of scam
    function startOrStopSale() external onlyOwner {
        if (allow == true) {
            allow = false;
        } else {
            allow = true;
        }
    }

    // to switch sale type between public and whitelist
    function switchSaleType() external onlyOwner {
        if (whitelistEnable == true) {
            whitelistEnable = false;
            publicEnable = true;
        } else {
            publicEnable = false;
            whitelistEnable = true;
        }
    }

    // to set white listed users for whitelist sale
    function setWhitelistedUsers(address[] memory _users, bool _value)
        external
        onlyOwner
    {
        for (uint32 i = 0; i < _users.length; i++) {
            whitelistedUsers[_users[i]] = _value;
        }
    }

    // to draw funds for liquidity
    function transferFunds(uint256 _value) external onlyOwner {
        owner().transfer(_value);
    }

    // to draw out tokens
    function transferTokens(uint256 _value) external onlyOwner {
        token.transfer(owner(), _value);
    }

    function getContractCoinBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getContractTokenBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
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