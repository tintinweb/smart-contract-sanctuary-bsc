// SPDX-License-Identifier: Apache-2.0
/*

  Copyright 2022 Element.Market

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.8.15;

import "./ISpaceIdHelperFeature.sol";

contract SpaceIdHelperFeature is ISpaceIdHelperFeature {

    function querySpaceIdInfos(
        address owner,
        address resolver,
        string[] calldata names,
        uint256[] calldata durations
    ) external override view returns (SpaceIdInfo[] memory infos) {
        require(names.length == durations.length, "querySpaceIdInfos: mismatch items.");

        ISpaceIdRegistrar registrar = ISpaceIdRegistrar(0x6D910eDFED06d7FA12Df252693622920fEf7eaA6);
        infos = new SpaceIdInfo[](durations.length);

        uint256 start = block.timestamp * 10000;
        for (uint256 i; i < infos.length; i++) {
            try registrar.rentPrice(names[i], durations[i]) returns (ISpaceIdRegistrar.Price memory price) {
                infos[i].base = price.base;
                infos[i].premium = price.premium;
                infos[i].available = registrar.available(names[i]);
            } catch {
            }

            bytes32 secret = keccak256(abi.encode(start + i));
            bytes32 label = keccak256(bytes(names[i]));
            if (resolver == address(0)) {
                infos[i].commitHash = keccak256(abi.encodePacked(label, owner, secret));
            } else {
                infos[i].commitHash = keccak256(abi.encodePacked(label, owner, resolver, owner, secret));
            }
            infos[i].secret = secret;
        }
        return infos;
    }
}

// SPDX-License-Identifier: Apache-2.0
/*

  Copyright 2022 Element.Market

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.8.15;


interface ISpaceIdRegistrar {

    struct Price {
        uint256 base;
        uint256 premium;
    }

    function valid(string calldata name) external pure returns (bool);
    function available(string calldata name) external view returns(bool);
    function rentPrice(string calldata name, uint256 duration) external view returns (Price memory price);
}

interface ISpaceIdHelperFeature {

    struct SpaceIdInfo {
        uint256 base;
        uint256 premium;
        bool available;
        bytes32 secret;
        bytes32 commitHash;
    }

    function querySpaceIdInfos(
        address owner,
        address resolver,
        string[] calldata names,
        uint256[] calldata durations
    ) external view returns (SpaceIdInfo[] memory infos);
}