/**
 *Submitted for verification at BscScan.com on 2022-03-28
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12;

contract my_presale {

    event UserDepsitedSuccess(address, uint256);

    modifier onlyOwner() {
        require(owner == msg.sender, "Not presale owner.");
        _;
    }

    uint256 Total_income = 0;
    uint256 Total_outcome = 0;
    address owner;
    address payable outcome_address;

    struct presaleInfo {
        uint256 presale_start;
        uint256 presale_end;
    }

    presaleInfo public presale_info;

    constructor(){
        owner = msg.sender;
        
    }

    function totalIncome() public view returns (uint256) {
        return Total_income;
    }

    function totalOutcome() public view returns (uint256) {
        return Total_outcome;
    }

    function outcomeAddress() public view returns (address payable) {
        return outcome_address;
    }

    function presaleStartDate () public view returns (uint256) {
        return presale_info.presale_start;
    }

    function presaleEndDate () public view returns (uint256) {
        return presale_info.presale_end;
    }

    function setOutAddress(address payable _outcome_address) public onlyOwner{
        outcome_address = _outcome_address;
    }

    function init_presale (
        uint256 _presale_start,
        uint256 _presale_end
    ) public onlyOwner{
        presale_info.presale_start =  _presale_start;
        presale_info.presale_end = _presale_end;
    }

    function presaleStatus() public view returns (uint256) {
        if (block.timestamp > presale_info.presale_end) {
            return 2; // Failure - Presale is always failed 
        }
        if ((block.timestamp >= presale_info.presale_start) && (block.timestamp <= presale_info.presale_end)) {
            return 1; // ACTIVE - Deposits enabled, now in Presale
        }
            return 0; // QUEUED - Awaiting start block
    }

    function user_deposit() public payable {
        Total_income += msg.value;
        emit UserDepsitedSuccess(msg.sender, msg.value);
    }

    function ownerWithdrawBaseToken() public onlyOwner {
        // address payable _owner = address(uint160(owner));
        require(outcome_address != 0x0000000000000000000000000000000000000000, "Current output address is zero, please set your output address");        
        Total_outcome += address(this).balance;
        outcome_address.transfer(address(this).balance);
    }
}



//https://testnet.bscscan.com/address/0xf6815a7a36522cc8f86e87d426e3ad103156ddf0

//https://testnet.bscscan.com/address/0x698489ca8b1bbcd09b9e8f888ab0c1b3fdf5925a