/**
 *Submitted for verification at BscScan.com on 2022-06-19
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract BatchExecuterContract {
    struct Entry {
        address addr;
        bytes data;
    }
    function callContractsWithStruct(Entry[] memory entries)
        public
        returns (bytes[] memory)
    {
        bytes[] memory response = new bytes[](entries.length);
        for (uint16 i = 0; i < entries.length; i++) {
            response[i] = safeCall(entries[i].addr, entries[i].data);
        }
        return response;
    }
    function callContracts(address[] memory addresses, bytes[] memory data)
        public
        returns (bytes[] memory)
    {
        uint256 count = addresses.length;
        bytes[] memory response = new bytes[](count);
        for (uint16 i = 0; i < count; i++) {
            response[i] = safeCall(addresses[i], data[i]);
        }
        return response;
    }
    function safeCall(address contractAddress, bytes memory data)
        public
        returns (bytes memory)
    {
        (bool success, bytes memory response) = contractAddress.call(data);
        require(success, string(response));
        return response;
    }
    function getReserves(Entry memory entry, uint256 offset, uint256 limit)
        public
        returns (address[] memory, uint112[][] memory)
    {
        // Get the maximum number of pairs in the provided factory
        bytes memory pairsRes = safeCall(entry.addr, entry.data);
        (uint pairsLength) = abi.decode(pairsRes, (uint));
        address[] memory pairs = new address[](limit);
        uint112[][] memory reserves = new uint112[][](limit);
        for(uint256 i=0; i<limit; i++) {
            uint256 pairIndex = i + offset;
            if (pairsLength > pairsLength) {
                break;
            }
            // Get pair's contract address
            bytes memory pairAddrRes = safeCall(entry.addr, abi.encodeWithSignature("allPairs(uint256)", pairIndex));
            (address pairAddr) = abi.decode(pairAddrRes, (address));
            // Get pair reserves
            bytes memory reserveAddrRes = safeCall(pairAddr, abi.encodeWithSignature("getReserves()"));
            (uint112 reserve0, uint112 reserve1, ) = abi.decode(reserveAddrRes, (uint112, uint112, uint32));
            // Set pair reserves
            pairs[i] = pairAddr;
            reserves[i] = new uint112[](2);
            reserves[i][0] = reserve0;
            reserves[i][1] = reserve1;
        }
        return (pairs, reserves);
    }
}