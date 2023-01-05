/**
 *Submitted for verification at BscScan.com on 2023-01-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract BackBoneProSeedSale {
    
    IERC20 public immutable BBP;
    address payable public  owner;
    uint256 public tokenPrice;
    uint256 public tokensSold;

    uint256 public minOrder;
    uint256 public maxOrder;

    uint256 public totalSupply; // Total token for Sale
    uint256 LockingTime = 0;
    uint256 VestingTime = 94672800;
    uint256 ClaimPeriod = 500;

    mapping(address => uint256) public userBuy;
    mapping(address => uint256) public buyDate;
    mapping(address => uint256) public lastClaim;
    mapping(address => uint256) public claimed;

    event Buy(address indexed _buyer, uint256 _amount, uint256 date); // Save event to BlockChain
    event Claim(address indexed _buyer, uint256 _amount, uint256 date); // Save event to BlockChain
    event Transfer(address indexed _beneficiary, uint256 _destination, uint256 date); // Save event to BlockChain

    constructor(
        address _tokenAddress,
        uint256 _tokenPrice,
        uint256 _minOrder,
        uint256 _maxOrder,
        uint256 _totalSupply
    ) {
        owner = payable(msg.sender);
        BBP = IERC20(_tokenAddress);
        tokenPrice = _tokenPrice;
        minOrder = _minOrder;
        maxOrder = _maxOrder;
        totalSupply = _totalSupply;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not authorized");
        _;
    }

    function transferVesting(address _destination) public {
        require(userBuy[msg.sender] > 0, "You dont have any vested amount");
        require(userBuy[_destination] == 0, "Cannot transfer to available users");
        userBuy[_destination] = userBuy[msg.sender];
        buyDate[_destination] = buyDate[msg.sender];
        lastClaim[_destination] = lastClaim[msg.sender];
     
        userBuy[msg.sender] = 0;
        buyDate[msg.sender] = 0;
        lastClaim[msg.sender] = 0;
    }

    function buyTokens(uint256 _numberOfTokens) public payable {
        require(userBuy[msg.sender] == 0);
        require(_numberOfTokens >= minOrder);
        require(_numberOfTokens <= maxOrder);
        require(_numberOfTokens <= totalSupply);

        require(msg.value == mul((_numberOfTokens/1e18), tokenPrice));
        // require(BBP.balanceOf(address(this)) >= _numberOfTokens);
        // require(BBP.transfer(msg.sender, _numberOfTokens));

        owner.transfer(address(this).balance); //send BNB to owner
        tokensSold += _numberOfTokens;
        lastClaim[msg.sender] = block.timestamp + LockingTime;
        buyDate[msg.sender] = block.timestamp;
        userBuy[msg.sender] = _numberOfTokens;
        totalSupply -= _numberOfTokens;
        
        emit Buy(msg.sender, _numberOfTokens, block.timestamp);
    }

    function claim() public {
        require(
            block.timestamp >= buyDate[msg.sender] + LockingTime,
            "Claim available after 180 days"
        );

        require(
            (lastClaim[msg.sender] + ClaimPeriod) < block.timestamp,
            "Claim is available after 24H from last claim"
        );

        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            BBP.transfer(msg.sender, reward);
            claimed[msg.sender] += reward;
            lastClaim[msg.sender] = block.timestamp;
            emit Claim(msg.sender, reward, block.timestamp);
        }        
    }

    function calculate(uint256 _numberOfTokens) public view returns (uint256) {
        return mul((_numberOfTokens/1e18), tokenPrice);
    }

    function earned(address _account) public view returns (uint256) {
        // 63120000 24 month in seconds
        return ((block.timestamp - lastClaim[_account]) *
            div(userBuy[_account], VestingTime));
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        unchecked {
            require(b > 0, "The divisor cannot be zero");
            return a / b;
        }
    }

    function totalBuy() public view returns (uint256) {
        return userBuy[msg.sender];
    }
}

interface IERC20 {
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