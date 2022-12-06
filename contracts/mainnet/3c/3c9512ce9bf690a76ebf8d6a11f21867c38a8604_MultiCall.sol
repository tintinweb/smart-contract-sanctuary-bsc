/**
 *Submitted for verification at BscScan.com on 2022-12-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;


contract MultiCall {
    
  function call(
    address[] memory targets,
    bytes[] memory datas
  ) public returns(uint256) {
    uint256 len = targets.length;
    require(datas.length == len, "Error: Array lengths do not match.");
    uint256 startGas = gasleft();

    bytes[] memory returnDatas = new bytes[](len);

    for (uint256 i = 0; i < len; i++) {
      address target = targets[i];
      bytes memory data = datas[i];
      (bool success, bytes memory returnData) = target.call(data);
      if (!success) {
        returnDatas[i] = bytes("");
      } else {
        returnDatas[i] = returnData;
      }
    }
    bytes memory data = abi.encode(block.number, returnDatas);
    uint256 gasUsed = startGas - gasleft();
    return(gasUsed);
  }
}