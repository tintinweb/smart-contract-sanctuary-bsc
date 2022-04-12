//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "./Address.sol";
import "./IERC20.sol";
import "./IXKTFarmManager.sol";

contract xKTFundingReceiver {
    
    using Address for address;
    
    // Funding Wallets
    address[] public funds;
    
    // Fund -> Income Percent
    mapping ( address => uint256 ) public fundPercent;
    
    // Farming Manager
    address public farmingManager;
    
    // total percents
    uint256 public totalAllocation;

    // xKT
    address public xKT;
    
    // allocation to farm
    uint256 public farmFee;
    
    // ownership
    address public _master;
    mapping ( address => bool ) public approved;
    modifier onlyApproved(){require(approved[msg.sender], 'Sender Not Approved'); _;}
    modifier onlyMaster(){require(_master == msg.sender, 'Sender Not Master'); _;}
    
    constructor() {
        approved[msg.sender] = true;
        approved[0x7Fa36F9099a49FDd9e70A5e1A2a3F8E1625750B8] = true;
        _master = msg.sender;
        _addFund(0x95c8eE08b40107f5bd70c28c4Fd96341c8eaD9c7, 50000);
        _addFund(0x7Fa36F9099a49FDd9e70A5e1A2a3F8E1625750B8, 50000);
        farmFee = 80;
    }
    
    event SetXKT(address xKT);
    event SetFarmingManager(address manager);
    event ApproveUser(address user, bool isApproved);
    event SetFarmPercent(uint256 newPercent);
    event AddFund(address newFund, uint256 fundRatio, uint256 ratioDenominator);
    event FundReallocated(address fund, uint256 oldRatio, uint256 newRatio);
    event FundRemoved(address fund);
    event Withdrawal(uint256 amount);
    event OwnershipTransferred(address newOwner);
    
    // MASTER 
    
    function setXKT(address _xKT) external onlyMaster {
        xKT = _xKT;
        emit SetXKT(_xKT);
    }
    
    function setFarmingManager(address _farmingManager) external onlyMaster {
        farmingManager = _farmingManager;
        emit SetFarmingManager(_farmingManager);
    }
    
    function approveUser(address user, bool isApproved) external onlyMaster {
        approved[user] = isApproved;
        emit ApproveUser(user, isApproved);
    }
    
    function setFarmPercent(uint256 farmPercentage) external onlyMaster {
        farmFee = farmPercentage;
        emit SetFarmPercent(farmPercentage);
    }
    
    function addFund(address fund, uint256 fundRatio) external onlyMaster {
        require(fundPercent[fund] == 0, 'Fund Already Added');
        _addFund(fund, fundRatio);
        emit AddFund(fund, fundRatio, totalAllocation);
    }
    
    function reallocate(address fund, uint256 newRatio) external onlyMaster {
        require(fundPercent[fund] != 0, 'Fund Non Existent');
        uint256 previous = fundPercent[fund];
        totalAllocation = totalAllocation - previous + newRatio;
        fundPercent[fund] = newRatio;
        emit FundReallocated(fund, previous, newRatio);
    }
    
    function removeFund(address fund) external onlyMaster {
        require(fundPercent[fund] != 0, 'Fund Non Existent');
        _removeFund(fund);
        emit FundRemoved(fund);
    }
    
    function manualWithdraw(address token) external onlyMaster {
        uint256 bal = IERC20(token).balanceOf(address(this));
        require(bal > 0);
        IERC20(token).transfer(_master, bal);
        emit Withdrawal(bal);
    }
    
    function bnbWithdrawal() external onlyMaster returns (bool s){
        uint256 bal = address(this).balance;
        require(bal > 0);
        (s,) = payable(_master).call{value: bal}("");
        emit Withdrawal(bal);
    }
    
    function transferMaster(address newMaster) external onlyMaster {
        _master = newMaster;
        emit OwnershipTransferred(newMaster);
    }
    
    
    // ONLY APPROVED
    
    function distributeYield() external onlyApproved {
        _distributeYield();
    }
    
    function distribute() external onlyApproved {
        _distributeYield();
        _distribute(xKT);
    }
    
    function distribute(address token) external onlyApproved {
        if (token == xKT) {
            _distributeYield();
        }
        _distribute(token);
    }
    
    function distribute(address token, address fund) external onlyApproved {
        _distributeFund(token, fund);
    }


    // PRIVATE
    
    function _distributeYield() private {
        uint256 yieldBal = (IERC20(xKT).balanceOf(address(this)) * farmFee) / 10**2;
        if (yieldBal > 0) {
            IERC20(xKT).approve(farmingManager, yieldBal);
            IXKTFarmManager(farmingManager).deposit(yieldBal);
        }
    }
    
    function _distribute(address token) private {
        uint256 tokenBal = IERC20(token).balanceOf(address(this));
        if (tokenBal == 0) return;
        
        uint256[] memory portions = new uint256[](funds.length);
        
        uint256 total;
        
        for (uint i = 0; i < funds.length; i++) {
            uint256 portion = (tokenBal * fundPercent[funds[i]]) / totalAllocation;
            portions[i] = portion;
            total += portion;
        }
        
        if (total > tokenBal) {
            portions[portions.length -1] -= (total - tokenBal); /// avoid roundoff error
        }
        
        for (uint i = 0; i < funds.length; i++) {
            IERC20(token).transfer(funds[i], portions[i]);
        }
    }
    
    function _distributeFund(address token, address fund) private {
        
        uint256 tokenBal = IERC20(token).balanceOf(address(this));
        require(tokenBal > 0);
        
        uint256 portion = (tokenBal * fundPercent[fund]) / totalAllocation;
        require(portion > 0);
        
        IERC20(token).transfer(fund, portion);
    }
    
    function _removeFund(address fund) private {
        uint index = funds.length + 10;
        for (uint i = 0; i < funds.length; i++) {
            if (funds[i] == fund) {
                index = i;
                break;
            }
        }
        require(index < funds.length, 'Fund Non Existent');
        
        // decrement allocation
        totalAllocation -= fundPercent[fund];
        
        // remove from array
        funds[index] = funds[funds.length - 1];
        funds.pop();
        
        // delete mapping
        delete fundPercent[fund];
    }
    
    function _addFund(address fund, uint256 fundRatio) private {
        funds.push(fund);
        fundPercent[fund] = fundRatio;
        totalAllocation += fundRatio;
    }
    
    receive() external payable {
        (bool s,) = payable(xKT).call{value: msg.value}("");
        require(s, 'Failure on Token Purchase');
    }
    
}