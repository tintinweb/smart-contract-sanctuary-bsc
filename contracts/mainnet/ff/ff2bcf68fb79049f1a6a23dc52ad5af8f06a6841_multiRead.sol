/**
 *Submitted for verification at BscScan.com on 2022-03-13
*/

// SPDX-License-Identifier: MIT
// @author 4nth0nySLT

pragma solidity >=0.8.12;

interface IToken20 {
    function balanceOf(address account) external view returns (uint256);
}

contract multiRead {
    struct balancesWithOwner {
        address owner;
        uint256 balance;
    }

    struct balances {
        uint256 balance;
    }

    struct results {
        bool success;
        bytes dataResult;
    }

    struct resultsWithKeys{
        bool success;
        bytes callData;
        bytes dataResult;
    }

    function getBalances(address[] calldata addresses)
        external
        view
        returns (uint256 blockNumber, balances[] memory returnBalances)
    {
        blockNumber = block.number;
        returnBalances = new balances[](addresses.length);
        for (uint256 i = 0; i < addresses.length; i++) {
            returnBalances[i] = balances( addresses[i].balance );
        }
    }

    function getTokenBalances(IToken20 token, address[] calldata addresses)
        external
        view
        returns (uint256 blockNumber, balances[] memory returnBalances)
    {
        blockNumber = block.number;
        returnBalances = new balances[](addresses.length);
        for (uint256 i = 0; i < addresses.length; i++) {
            returnBalances[i] = balances( token.balanceOf(addresses[i]) );
        }
    }

    function getBalancesWithOwner(address[] calldata addresses)
        external
        view
        returns (uint256 blockNumber, balancesWithOwner[] memory returnBalancesWithOwner)
    {
        blockNumber = block.number;
        returnBalancesWithOwner = new balancesWithOwner[](addresses.length);
        for (uint256 i = 0; i < addresses.length; i++) {
            returnBalancesWithOwner[i] = balancesWithOwner(
                addresses[i], 
                addresses[i].balance
            );
        }
    }

    function getTokenBalancesWithOwner(
        IToken20 token,
        address[] calldata addresses
    )
        external
        view
        returns (uint256 blockNumber, balancesWithOwner[] memory returnBalancesWithOwner)
    {
        blockNumber = block.number;
        returnBalancesWithOwner = new balancesWithOwner[](addresses.length);
        for (uint256 i = 0; i < addresses.length; i++) {
            returnBalancesWithOwner[i] = balancesWithOwner(
                addresses[i],
                token.balanceOf(addresses[i])
            );
        }
    }

    // For recollect any information in contracts

    function tryMultiReadContract(address _contract, bytes[] calldata callData)
        external
        view
        returns (uint256 blockNumber, results[] memory returnData)
    {
        blockNumber = block.number;
        returnData = new results[](callData.length);
        for (uint256 i = 0; i < callData.length; i++) {
            (bool success, bytes memory dataResult) = _contract.staticcall(
                callData[i]
            );

            returnData[i] = results( success, dataResult );
        }
    }

    function tryMultiReadContractWithKey(address _contract, bytes[] calldata callData)
        external
        view
        returns (uint256 blockNumber, resultsWithKeys[] memory returnDataWithKey)
    {
        blockNumber = block.number;
        returnDataWithKey = new resultsWithKeys[](callData.length);
        for (uint256 i = 0; i < callData.length; i++) {
            (bool success, bytes memory dataResult) = _contract.staticcall(
                callData[i]
            );
            
            returnDataWithKey[i] = resultsWithKeys( success, callData[i], dataResult  );
        }
    }

    //For evade any transfer, this doesn't work with tokens

    receive () external payable{
        revert();
    }
    fallback () external payable{
        revert();
    }
}