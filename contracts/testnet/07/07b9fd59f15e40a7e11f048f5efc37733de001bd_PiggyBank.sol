/**
 *Submitted for verification at BscScan.com on 2022-07-19
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4; /// @dev Change with the version you prefer

//            ___________________________
//           /                           \
//          ( funds are SAFU, HOINK HOINK )
//           \ __________________________/
//                |/
//         _
//         |\_,,____
//         ( o__o \/
//         /(..)  \
//        (_ )--( _)
//        / ""--"" \
// ,===,=| |-,,,,-| |==,==
// |d  |  WW   |  WW   |
// |s  |   |   |   |   |

contract PiggyBank {
    mapping(address => uint256) piggyBankBalanceOfUserAddress;

    event successfulWithdraw(address indexed, uint256);

    function depositFundsToPiggyBank() external payable {
        piggyBankBalanceOfUserAddress[msg.sender] += msg.value;
    }

    function withdrawPiggyBank(uint256 amountToWithdraw) external {
        require(
            amountToWithdraw <= piggyBankBalanceOfUserAddress[msg.sender],
            "withdrawPiggyBank: You sure it's not you the pig?"
        );
        bool success;
        assembly {
            success := call(gas(), caller(), amountToWithdraw, 0, 0, 0, 0)
        }
        require(success, "withdrawPiggyBank: Error on withdraw");
        piggyBankBalanceOfUserAddress[msg.sender] = 0;
        emit successfulWithdraw(msg.sender, amountToWithdraw);
    }
}