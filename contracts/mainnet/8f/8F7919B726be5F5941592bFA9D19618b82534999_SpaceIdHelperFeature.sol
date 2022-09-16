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

import "../../storage/LibHelperStorage.sol";
import "./ISpaceIdHelperFeature.sol";
import "../../HelperOwnable.sol";

contract SpaceIdHelperFeature is HelperOwnable, ISpaceIdHelperFeature {

    struct Storage {
        address registrar;
    }

    function getStorage() internal pure returns (Storage storage stor) {
        uint256 slot = LibHelperStorage.STORAGE_ID_SPACE_ID;
        assembly { stor.slot := slot }
    }

    function setSpaceIdRegistrar(address registrar) external override onlyOwner {
        getStorage().registrar = registrar;
    }

    function getSpaceIdRegistrar() external override view returns (address) {
        if (getStorage().registrar != address(0)) {
            return getStorage().registrar;
        }
        return 0x6D910eDFED06d7FA12Df252693622920fEf7eaA6;
    }

    function querySpaceIdInfos(
        address owner,
        address resolver,
        address addr,
        string[] calldata names,
        uint256[] calldata durations
    ) external override view returns (SpaceIdInfo[] memory infos) {
        require(names.length == durations.length, "querySpaceIdInfos: mismatch items.");

        ISpaceIdRegistrar registrar = ISpaceIdRegistrar(getStorage().registrar);
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
                infos[i].commitId = keccak256(abi.encodePacked(label, owner, secret));
            } else {
                infos[i].commitId = keccak256(abi.encodePacked(label, owner, resolver, owner, secret));
            }
            infos[i].secret = secret;
        }
        return infos;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;


library LibHelperStorage {
    uint256 constant STORAGE_ID_FEATURE = 0 << 128;
    uint256 constant STORAGE_ID_SPACE_ID = 1 << 128;
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
        bytes32 commitId;
    }

    function setSpaceIdRegistrar(address register) external;

    function getSpaceIdRegistrar() external view returns (address);

    function querySpaceIdInfos(
        address owner,
        address resolver,
        address addr,
        string[] calldata names,
        uint256[] calldata durations
    ) external view returns (SpaceIdInfo[] memory infos);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "./storage/LibHelperFeatureStorage.sol";


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract HelperOwnable {

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        if (owner() == address(0)) {
            _transferOwnership(msg.sender);
        }
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return LibHelperFeatureStorage.getStorage().owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) private {
        LibHelperFeatureStorage.Storage storage stor = LibHelperFeatureStorage.getStorage();
        address oldOwner = stor.owner;
        stor.owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "./LibHelperStorage.sol";


library LibHelperFeatureStorage {

    struct Storage {
        address owner;
        // Mapping of function selector -> function implementation
        mapping(bytes4 => address) impls;
    }

    /// @dev Get the storage bucket for this contract.
    function getStorage() internal pure returns (Storage storage stor) {
        // uint256 storageSlot = LibStorage.STORAGE_ID_FEATURE;
        assembly { stor.slot := 0 }
    }
}