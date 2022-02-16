/**
 *Submitted for verification at BscScan.com on 2022-02-16
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

//import "hardhat/console.sol";

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    function approve(address spender, uint amount) external returns (bool);
    function allowance(address owner, address spender) external returns (uint);
    function mint(address account, uint amount) external returns (bool);
    function burn(address account, uint amount) external returns (bool);
    function setMinter(address _banker) external;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint value
    );
}

contract Marketplace {
    address public admin;
    IERC20 public token1;
    IERC20 public token2;

    mapping(address => uint) public token1Balance;
    mapping(address => uint) public token2Balance;

    address[] public registerAddressArray;
    mapping(address => bool) public registerAddress;

    mapping(address => bool) public scenario1Lock;
    mapping(address => bool) public scenario2Lock;

    // Scenario 1 events
    event DepositToken1(address indexed sender, uint256 amount, uint256 date);
    event BuyToken2(address indexed sender, uint256 date);
    event UpdateToken2Qty(address indexed sender, uint256 amount1, uint256 amount2, uint256 date);
    event WithdrawToken2(address indexed sender, uint256 amount, uint256 date);

    // Scenario 2 events
    event DepositToken2(address indexed sender, uint256 amount, uint256 date);
    event BuyToken1(address indexed sender, uint256 date);
    event UpdateToken1Qty(address indexed sender, uint256 amount, uint256 amount2, uint256 date);
    event WithdrawToken1(address indexed sender, uint256 amount, uint256 date);

    constructor(
        address _token1Address,
        address _token2Address
    ) {
        token1 = IERC20(_token1Address);
        token2 = IERC20(_token2Address);
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }

    // Transfer ownernship
    function transferOwnership(address payable _admin) external onlyAdmin {
        require(admin != address(0), "Zero address");
        admin = _admin;
    }

    /**
     * Scenario 1 - depositToken1 -> buyToken2 -> updateToken2Qty -> withdrawToken2
     */
    function depositToken1(uint _amount) public returns (bool) {
        require(_amount > 0, "Amount cannot be zero");
        if(!registerAddress[msg.sender]) {
            registerAddressArray.push(msg.sender);
        }
        registerAddress[msg.sender] = true;
        token1Balance[msg.sender] = token1Balance[msg.sender] + _amount;
        token1.transferFrom(msg.sender, address(this), _amount);
        emit DepositToken1(msg.sender, _amount, block.timestamp);
        return true;
    }

    function buyToken2() public returns (bool) {
        require(!scenario1Lock[msg.sender], "Address should not be locked");
        require(token1Balance[msg.sender] > 0, "There is not enough token1 balance");
        scenario1Lock[msg.sender] = true;
        emit BuyToken2(msg.sender, block.timestamp);
        return true;
    }

    function updateToken2Qty(address _account, uint _amount) public onlyAdmin returns (bool) {
        require(_account != address(0), "Account cannot be zero");
        require(_amount > 0, "Amount cannot be zero");
        require(scenario1Lock[_account], "Address should be locked");
        require(token1Balance[_account] > 0, "Token1 balance cannot be zero");
        token2Balance[_account] = token2Balance[_account] + _amount;
        token1Balance[_account] = 0;
        token2.mint(address(this), _amount);
        token2.approve(_account, _amount);
        scenario1Lock[_account] = false;
        emit UpdateToken2Qty(_account, token1Balance[_account], _amount, block.timestamp);
        return true;
    }

    function withdrawToken2(uint _amount) public returns (bool) {
        require(_amount > 0, "Amount cannot be zero");
        require(!scenario1Lock[msg.sender], "Address is locked");
        token2Balance[msg.sender] = token2Balance[msg.sender] - _amount;
        token2.transfer(msg.sender, _amount);
        emit WithdrawToken2(msg.sender, _amount, block.timestamp);
        return true;
    }

    function getRegisterAddressArrayLength() public view returns(uint256) {
        return registerAddressArray.length;
    }

    // Allow admin to send back the token that is wrongly sent to this contract
    function recover(address tokenAddress, address recoveryAddress, uint amount) public onlyAdmin {
        IERC20(tokenAddress).transfer(recoveryAddress, amount);
    }

    // Reject all native coin deposit
    receive() external payable {
        revert();
    }
}