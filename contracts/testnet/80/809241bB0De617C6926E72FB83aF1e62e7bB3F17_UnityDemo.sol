//SPDX-License-Identifier: Business Source License 1.1

pragma solidity ^0.8.9;

contract UnityDemo {
    string public data;

    event DataUpdate(string indexed prev, string indexed curr);

    function setData(string calldata newData) external {
        emit DataUpdate(data, newData);
        data = newData;
    }
}