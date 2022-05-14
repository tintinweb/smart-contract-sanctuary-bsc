// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

struct sLogReporting {
    string contractName;
}

library LogReporting {
    function reportError(sLogReporting storage self, string memory error)
        public
        view
        returns (string memory)
    {
        return string(abi.encodePacked(self.contractName, " - [ERROR]: ", error));
    }

    function reportError(
        sLogReporting storage self,
        string memory error1,
        string memory error2
    ) public view returns (string memory) {
        return string(abi.encodePacked(self.contractName, " - [ERROR]: ", error1, error2));
    }
}