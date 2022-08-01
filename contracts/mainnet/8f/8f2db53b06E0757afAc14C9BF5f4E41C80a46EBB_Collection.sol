// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./Strings.sol";
import "./Ownable.sol";

contract Collection is Strings, Ownable {

    struct CollecterData {
        address collecter;
        bool isCollecter;
    }
    uint32 collecterCount;
    mapping(address => bool) mapCollecter;
    mapping(uint32 => CollecterData) mapCollecterList;

    struct WithdrawerData {
        address withdrawer;
        bool isWithdrawer;
    }
    uint32 withdrawerCount;
    mapping(address => bool) mapWithdrawer;
    mapping(uint32 => WithdrawerData) mapWithdrawerList;

    address usdtTokenAddress;

    struct DepositCount {
        uint256 count;
        bool exists;
    }

    struct DepositData {
        address addr;
        uint256 amount;
        uint time;
        bool exists;
    }

    uint256 lastIndex;

    mapping(address => DepositCount) mapDepositCount;
    mapping(address => mapping(uint256 => DepositData)) mapUserDeposit;
    mapping(uint256 => DepositData) mapAllUserDeposit;

    event usdtCollected(address account, uint256 amount);
    event usdtSent(address account, uint256 amount);

    constructor(address _usdtTokenAddress) {
        owner = msg.sender;
        usdtTokenAddress = _usdtTokenAddress;
        lastIndex = 0;
    }

    function setUsdtTokenAddress(address to) external onlyOwner {
        usdtTokenAddress = to;
    }

    function getUsdtTokenAddress() external view returns (address res) {
        res = usdtTokenAddress;
    }

    function addCollecter() external {
        require(!mapCollecter[msg.sender], "collecter exists");
        require(msg.sender != owner, "don't add owner as collecter");
        mapCollecter[msg.sender] = true;
        mapCollecterList[++collecterCount] = CollecterData(msg.sender, true);
    }

    function isCollecter(address addr) external view returns (bool res) {
        res = _isCollecter(addr);
    }

    function _isCollecter(address addr) internal view returns (bool res) {
        res = mapCollecter[addr];
    }

    function getCollecterCount() external view returns (uint32 res) {
        res = collecterCount;
    }

    function removeCollecter(address addr) external onlyOwner{
        if(mapCollecter[addr]) {
            delete mapCollecter[addr];
            for(uint32 i = 1; i <= collecterCount; ++i) {
                if(mapCollecterList[i].collecter == addr) {
                    CollecterData storage cd = mapCollecterList[i];
                    cd.isCollecter = false;
                    break;
                }
            }
        }
    }

    function addWithdrawer(address withdrawer) external onlyOwner {
        require(!mapWithdrawer[withdrawer], "collecter exists");
        require(withdrawer != owner, "don't add owner as withdrawer");
        mapWithdrawer[withdrawer] = true;
        mapWithdrawerList[++withdrawerCount] = WithdrawerData(withdrawer, true);
    }

    function isWithdrawer(address addr) external view returns (bool res) {
        res = _isWithdrawer(addr);
    }

    function _isWithdrawer(address addr) internal view returns (bool res) {
        res = mapWithdrawer[addr];
    }

    function getWithdrawerCount() external view returns (uint32 res) {
        res = withdrawerCount;
    }

    function removeWithdrawer(address addr) external onlyOwner{
        if(mapWithdrawer[addr]) {
            delete mapWithdrawer[addr];
            for(uint32 i = 1; i <= withdrawerCount; ++i) {
                if(mapWithdrawerList[i].withdrawer == addr) {
                    WithdrawerData storage cd = mapWithdrawerList[i];
                    cd.isWithdrawer = false;
                    break;
                }
            }
        }
    }

    function deposit(uint256 amount) external {
        require(msg.sender != owner, "no owner");
        require(msg.sender != address(0), "zero address");
        require(ERC20(usdtTokenAddress).balanceOf(msg.sender) >= amount, "insufficient balance");
        require(ERC20(usdtTokenAddress).allowance(msg.sender, address(this)) >= amount, "not allowed to spend");
        (bool transfered) = ERC20(usdtTokenAddress).transferFrom(msg.sender, address(this), amount);
        require(transfered, "deposit error");
        _collectUSDT(msg.sender, amount);
    }
    
    function collectUsdt(address from, uint256 amount) external {
        require(_isCollecter(msg.sender), "collecter only");
        require(ERC20(usdtTokenAddress).balanceOf(from) >= amount, "insufficient balance");
        require(ERC20(usdtTokenAddress).allowance(from, address(this)) >= amount, "not allowed to spend");
        (bool transfered) = ERC20(usdtTokenAddress).transferFrom(from, address(this), amount);
        require(transfered, "collect error");
        _collectUSDT(from, amount);
    }
    
    function _collectUSDT(address from, uint256 amount) internal {
        uint256 userCount = 0;
        if(mapDepositCount[from].exists) {
            DepositCount storage dc = mapDepositCount[from];
            dc.count += 1;
            userCount = dc.count;
        } else {
            mapDepositCount[from] = DepositCount(1, true);
            userCount = 1;
        }

        DepositData memory newDC = DepositData(from, amount, block.timestamp, true);
        mapUserDeposit[from][userCount] = newDC;

        lastIndex = lastIndex + 1;
        mapAllUserDeposit[lastIndex] = newDC;
        
        emit usdtCollected(from, amount);
    }

    function sendUsdt(address to, uint256 amount) external {
        require(_isWithdrawer(msg.sender), "withdrawer only");
        require(ERC20(usdtTokenAddress).balanceOf(address(this)) >= amount, "insufficient balance");
        (bool transfered) = ERC20(usdtTokenAddress).transfer(to, amount);
        require(transfered, "sendUsdt error");
        emit usdtSent(to, amount);
    }

    function usdtBalance() external view returns (uint256 res) {
        res = ERC20(usdtTokenAddress).balanceOf(address(this));
    }

    function getDepositCount() external view returns (uint256 res) {
        res = lastIndex;
    }

    function getDespositData(uint256 index) external view returns 
    (  
        bool res,
        string memory addr,
        uint256 amount,
        uint time
    ) {
        if(mapAllUserDeposit[index].exists){
            res = true;
            addr = toHexString(mapAllUserDeposit[index].addr);
            amount = mapAllUserDeposit[index].amount;
            time = mapAllUserDeposit[index].time;
        }
    }

    function getUserDepositCount(address account) external view returns (uint256 res) {
        res = mapDepositCount[account].count;
    }

    function getUserDepositData(address account, uint256 index) external view returns 
    (
        bool res,
        string memory addr,
        uint256 amount,
        uint time
    ) {
        if(mapUserDeposit[account][index].exists) {
            res = true;
            addr = toHexString(mapUserDeposit[account][index].addr);
            amount = mapUserDeposit[account][index].amount;
            time = mapUserDeposit[account][index].time;
        }
    }
}