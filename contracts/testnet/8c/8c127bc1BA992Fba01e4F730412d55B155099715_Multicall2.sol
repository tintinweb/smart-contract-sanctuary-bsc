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
        string returnData;
    }

    function aggregate(Call[] memory calls) public returns (uint256 blockNumber, bytes[] memory returnData) {
        blockNumber = block.number;
        returnData = new bytes[](calls.length);
        for(uint256 i = 0; i < calls.length; i++) {
            (bool success, bytes memory ret) = calls[i].target.call(calls[i].callData);
            require(success, "Multicall aggregate: call failed");
            returnData[i] = ret;
        }
    }

    function test() public  pure returns(Result[] memory results) {

        results = new Result[](1);

        Result memory r1 = Result({
            success: true,
            returnData: "test1"
        });
        results[0] = r1;

    }
}