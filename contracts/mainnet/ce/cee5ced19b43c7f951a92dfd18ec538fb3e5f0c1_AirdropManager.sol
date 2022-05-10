/**
 *Submitted for verification at BscScan.com on 2022-05-10
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

interface IERC20 {
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
}

contract Airdrop {
    address public _contract;
    mapping (address => uint256) private userRatio;
    address[] private userArray;
    uint256 public totalRatio;

    constructor(address __contract) {
        _contract = __contract;
    }

    receive() external payable {}

    modifier onlyContract() {
        require(_contract == msg.sender, "Caller =/= main contract.");
        _;
    }

    function getTotalUsers() external view returns (uint256) {
        return userArray.length;
    }

    function getTotalRatio() external view returns (uint256) {
        return totalRatio;
    }

    function getUserRatio(address account) external view returns (uint256) {
        return userRatio[account];
    }

    function addUser(address account, uint256 ratio) public onlyContract {
        if(userRatio[account] == 0) {
            userArray.push(account);
        }
        totalRatio -= userRatio[account];
        userRatio[account] = ratio;
        totalRatio += ratio;
    }

    function addManyUsers(address[] calldata accounts, uint256[] calldata ratios) external onlyContract {
        require(accounts.length == ratios.length, "Lengths of arrays do not match.");
        for (uint256 i = 0; i< accounts.length; i++){
            addUser(accounts[i], ratios[i]);
        }
    }

    function removeUser(address account) external onlyContract {
        for (uint256 i = 0; i < userArray.length; i++) {
            if (userArray[i] == account) {
                userArray[i] = userArray[userArray.length - 1];
                userRatio[userArray[i]] = 0;
                userArray.pop();
                break;
            }
        }
    }

    function airdrop() external payable onlyContract returns (uint256) {
        require(msg.value > 0, "Cannot call with no currency.");
        uint256 balance = msg.value;
        uint256 _totalRatio = totalRatio;
        address user;
        uint256 ratio;
        uint256 userLength = userArray.length;
        bool success;
        uint256 iterations;
        for (uint256 i = 0; i < userLength - 1; i++) {
            user = userArray[i];
            ratio = userRatio[user];
            uint256 amount = (balance * ratio) / _totalRatio;
            if(ratio > 0) {
                (success,) = payable(user).call{value: amount, gas: 35000}("");
                if(success) {
                    iterations++;
                }
            }
        }
        user = userArray[userLength - 1];
        if(userRatio[user] > 0) {
            (success,) = payable(user).call{value: address(this).balance, gas: 35000}("");
            if(success) {
                iterations++;
            }
        }
        return iterations;
    }

    function sweep(address account) external onlyContract {
        // In case the contract has native currency for some reason.
        payable(account).transfer(address(this).balance);
    }

    function sweepTokens(address token, address account) external onlyContract {
        // In case the contract has tokens for some reason.
        IERC20 TOKEN = IERC20(token);
        TOKEN.transfer(account, TOKEN.balanceOf(address(this)));
    }

    function ecksuploshan(address payable account) external onlyContract {
        selfdestruct(account);
    }
}

contract AirdropManager {
    address public owner;
    uint256 public totalAirdropped;

    Airdrop public airdropper;

    constructor() payable {
        owner = msg.sender;
        airdropper = new Airdrop(address(this));
    }

    receive() external payable {}

    modifier onlyOwner() {
        require(owner == msg.sender, "Caller =/= main contract.");
        _;
    }

    modifier contractInitialized() {
        require(address(airdropper) != address(0), "The airdrop contract is not initialized, do so first.");
        _;
    }

    function transferOwnership(address account) external onlyOwner {
        owner = account;
    }

    function getTotalUsers() external view contractInitialized returns (uint256) {
        return airdropper.getTotalUsers();
    }

    function getTotalRatio() external view contractInitialized returns (uint256) {
        return airdropper.getTotalRatio();
    }

    function getUserRatio(address account) external view contractInitialized returns (uint256) {
        return airdropper.getUserRatio(account);
    }

    function addUser(address account, uint256 ratio) public onlyOwner contractInitialized {
        airdropper.addUser(account, ratio);
    }

    function addManyUsers(address[] calldata accounts, uint256[] calldata ratios) external onlyOwner contractInitialized {
        airdropper.addManyUsers(accounts, ratios);
    }

    function removeUser(address account) external onlyOwner contractInitialized {
        airdropper.removeUser(account);
    }

    function airdrop() external onlyOwner contractInitialized {
        require(address(this).balance > 0, "Contract has no funds to airdrop.");
        uint256 balance = address(this).balance;
        totalAirdropped += balance;
        airdropper.airdrop{value: balance}();
    }

    function sweep() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function sweepTokens(address token) external onlyOwner {
        // In case the contract has tokens for some reason.
        IERC20 TOKEN = IERC20(token);
        TOKEN.transfer(owner, TOKEN.balanceOf(address(this)));
    }

    function sweepAD() external onlyOwner contractInitialized {
        airdropper.sweep(msg.sender);
    }

    function sweepTokensAD(address token) external onlyOwner contractInitialized {
        airdropper.sweepTokens(token, msg.sender);
    }

    function explosion() external onlyOwner contractInitialized {
        // Kaboom
        airdropper.ecksuploshan(payable(msg.sender));
        airdropper = Airdrop(payable(address(0)));
    }

    function initalizeAirdropper() external onlyOwner {
        require(address(airdropper) == address(0), "Airdropper already exists.");
        airdropper = new Airdrop(address(this));
    }
}