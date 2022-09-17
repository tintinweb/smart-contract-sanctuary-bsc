/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

/**
 *Submitted for verification at Etherscan.io on 2021-04-29
*/

/**
 *Submitted for verification at Etherscan.io on 2021-03-23
*/

pragma solidity >=0.5.0;
pragma experimental ABIEncoderV2;

/// @title Multicall2 - Aggregate results from multiple read-only function calls
/// @author Michael Elliot <[email protected]>
/// @author Joshua Levine <[email protected]>
/// @author Nick Johnson <[email protected]>

contract Multicall2 {
    struct Call {
        address target;
        bytes callData;
    }
    struct Result {
        bool success;
        uint id;
        uint blocktime;
        string returnData;
    }

    mapping (uint=>Result) public _results;

    function aggregate(Call[] memory calls) public returns (uint256 blockNumber, bytes[] memory returnData) {
        blockNumber = block.number;
        returnData = new bytes[](calls.length);
        for(uint256 i = 0; i < calls.length; i++) {
            (bool success, bytes memory ret) = calls[i].target.call(calls[i].callData);
            require(success, "Multicall aggregate: call failed");
            returnData[i] = ret;
        }
    }

    function test(uint size) public  view returns(Result[] memory results) {

        results = new Result[](size);

        for(uint i; i< size; i++) {
            Result memory r1 = Result({
                success: true,
                id: i,
                blocktime: block.timestamp,
                returnData: "test1"
            });

            results[i] = r1;
        }

    }

    function test2(Result[] memory results) public {

        for(uint i; i< results.length;i++) {
            _results[i] = results[i];
        }

    }
}