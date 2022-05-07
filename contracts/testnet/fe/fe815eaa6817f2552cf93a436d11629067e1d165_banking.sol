/**
 *Submitted for verification at BscScan.com on 2022-05-06
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.0;

contract banking{

    struct customer{
        string cid;
        string foreName;
        string surName;
        string dateOfBirth;
        string fullAddress;
        string nationality;
        string idNumber;
        string phoneNumber;
        string religion;
        string occupation;
        string fullNameTrustee;
        string phoneNumberTrustee;
        string relationToTrustee;
    }

    mapping (string => customer) customers;
    mapping (string => bool) isExist;

    function addCustomer (
        customer memory data
        ) public returns (bool){
        customers[data.cid] = customer(data.cid, data.foreName, data.surName, data.dateOfBirth, data.fullAddress, data.nationality, data.idNumber, data.phoneNumber, data.religion, data.occupation, data.fullNameTrustee, data.phoneNumberTrustee, data.relationToTrustee);
        isExist[data.cid] = true;
        return true;
    }

    function deleteCustomer (string memory _cid) public returns (bool){
        delete customers[_cid];
        isExist[_cid] = false;
        return true;
    }

    function getCustomerDetails (string memory _cid) public view returns (customer memory){
        require(isExist[_cid] == true, "User Dont Exist");
        customer memory returnData;
        returnData = customers[_cid];
        return (returnData);
    }
}