/**
 *Submitted for verification at BscScan.com on 2022-05-03
*/

pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

interface IChainlink {
    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function latestAnswer() external view returns (int256 answer);
}

contract ChainlinkGasReportor {
    address public immutable chainlink;

    constructor(address _chainlink) {
        chainlink = _chainlink;
    }

    function getLatestAnswerGasCost() public view returns (uint256) {
        uint256 gasStart = gasleft();
        IChainlink(chainlink).latestAnswer();
        return gasStart-gasleft();
    }

    function getLatestAnswerWithHeartBeatGasCost() public view returns (uint256) {
        uint256 gasStart = gasleft();
        (,,,uint256 updatedAt,)=IChainlink(chainlink).latestRoundData();
        if(block.timestamp+1<updatedAt){}
        return gasStart-gasleft();
    }

    function repeatGetLatestAnswerGasCost(uint256 repeat) public view returns (uint256) {
        uint256 gasStart = gasleft();
        for (uint256 i=0;i<repeat;i++) {
            IChainlink(chainlink).latestAnswer();
        }
        return gasStart-gasleft();
    }

    function repeatGetLatestAnswerWithHeartBeatGasCost(uint256 repeat) public view returns (uint256) {
        uint256 gasStart = gasleft();
        for (uint256 i=0;i<repeat;i++) {
            (,,,uint256 updatedAt,)=IChainlink(chainlink).latestRoundData();
            if(block.timestamp+1<updatedAt){}
        }
        return gasStart-gasleft();
    }
}