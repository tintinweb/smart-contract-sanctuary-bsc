// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "./LogReporting.sol";

struct sWhitelist {
    sLogReporting logger;
    address[] contracts;
}

library Whitelist {
    using LogReporting for sLogReporting;

    function init(sWhitelist storage self, sLogReporting memory logger) public {
        self.logger = logger;
    }

    function add(sWhitelist storage self, address contractAddr) public {
        require(
            contractAddr != address(0),
            self.logger.reportError("Contract address can't be 0x")
        );
        require(
            isWhitelisted(self, contractAddr) == false,
            self.logger.reportError("Contract address already whitelisted")
        );
        self.contracts.push(contractAddr);
    }

    function remove(sWhitelist storage self, address contractAddr) public {
        require(
            contractAddr != address(0),
            self.logger.reportError("Contract address can't be 0x")
        );
        require(
            isWhitelisted(self, contractAddr) != false,
            self.logger.reportError("Contract address not whitelisted")
        );
        for (uint64 i = 0; i < self.contracts.length; i++) {
            if (self.contracts[i] == contractAddr) {
                self.contracts[i] = self.contracts[self.contracts.length - 1];
                self.contracts.pop();
                break;
            }
        }
    }

    function isWhitelisted(sWhitelist storage self, address contractAddr)
        public
        view
        returns (bool)
    {
        for (uint64 i = 0; i < self.contracts.length; i++) {
            if (self.contracts[i] == contractAddr) {
                return true;
            }
        }
        return false;
    }
}

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