// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ownable.sol";



contract TestWorker is Ownable
{
    uint256 public TotalVal;
    function UpdateTotalVal(uint256 val) public onlyOwner{
        TotalVal = val;
    }
}