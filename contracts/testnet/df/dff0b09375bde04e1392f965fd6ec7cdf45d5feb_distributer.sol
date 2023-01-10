/**
 *Submitted for verification at BscScan.com on 2023-01-09
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

contract distributer {

    address public admin;

    uint256 public userDistributionPermile;

    event AdminChanged(address previousAdmin, address newAdmin);
    event DistributionValueChanged(uint256 previousValue, uint256 newValue);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Accessble: caller is not an Admin");
        _;
    }

    constructor(address _admin) {
        admin = _admin;
        userDistributionPermile = 400;
    }

    function distributeFunds(address[] calldata accounts) external onlyAdmin {
        require(address(this).balance > 0,"insuffients funds");
        uint256 userDistribution = address(this).balance * userDistributionPermile / 1000;
        uint256 adminDistribution = address(this).balance - userDistribution;
        uint256 amountPerAccount = userDistribution / accounts.length;
        payable(admin).transfer(adminDistribution);
        for(uint256 i = 0; i < accounts.length; i++) {
                payable(accounts[i]).transfer(amountPerAccount);
        }
    }

    function setDistributionPermile(uint256 _userDistributionPermile) external onlyAdmin {
        emit DistributionValueChanged(userDistributionPermile, _userDistributionPermile);
        userDistributionPermile = _userDistributionPermile;
    }

    function changeAdmin(address newAdmin) external onlyAdmin {
        emit AdminChanged(admin, newAdmin);
        admin = newAdmin;
    }

    fallback() external {}
    receive() external payable{}
    
}