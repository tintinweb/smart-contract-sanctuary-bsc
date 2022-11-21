/**
 *Submitted for verification at BscScan.com on 2022-11-21
*/

// File: contracts/test.sol


pragma solidity ^0.8.7;
contract Demo {

    Account[] public arrAccount;

    struct Account {
        string _ID;
        address _Wallet;
    }

    event Sent_Data(string _id, address _wallet);

    function Create(string memory _id) public {
        Account memory accountnew = Account(_id, msg.sender);
        arrAccount.push(accountnew);
        emit Sent_Data(_id, msg.sender);
    }
    event Incremented (uint256 Total, uint256 _newValue);
    uint256 public Total;
    function increment(uint256 _newValue) external {
        Total += _newValue;
        emit Incremented(Total,_newValue);
    }

}