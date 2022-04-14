/**
 *Submitted for verification at BscScan.com on 2022-04-14
*/

// SPDX-License-Identifier: agpl-3.0

pragma solidity ^0.8.0;


interface ILog {
    function log(uint a, uint b) external;
}

contract Log is ILog{
    
    event X(uint a, uint b);

    function log(uint a, uint b) external override  {
        emit X(a,b);
    }

}