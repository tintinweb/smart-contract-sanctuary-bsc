// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;

import "./Waterpacks.sol";
import "./Fertilizers.sol";
import "./IHandler.sol";

struct NodeAddonLog {
    uint256[] creationTime;
    string[] addonKind;
    string[] addonTypeName;
}

contract Addons is Waterpacks, Fertilizers {
    mapping(uint256 => NodeAddonLog) internal nodeAddonLogs;

    constructor(IHandler handler) HandlerAware(handler) {}

    //====== Getters =========================================================//

    struct NodeAddonLogItemView {
        uint256 creationTime;
        string addonKind;
        string addonTypeName;
    }

    function getItemLogForNode(uint256 nodeId)
        public
        view
        returns (NodeAddonLogItemView[] memory)
    {
        NodeAddonLog memory log = nodeAddonLogs[nodeId];
        uint256 logLength = log.creationTime.length;
        NodeAddonLogItemView[] memory logItems = new NodeAddonLogItemView[](
            logLength
        );

        for (uint256 i = 0; i < logLength; i++) {
            logItems[i].creationTime = log.creationTime[i];
            logItems[i].addonKind = log.addonKind[i];
            logItems[i].addonTypeName = log.addonTypeName[i];
        }

        return logItems;
    }

    //====== Handler-only API ================================================//

    function setWaterpackType(
        string calldata name,
        uint256 ratioOfGRP,
        uint256[] calldata prices
    ) external onlyHandler {
        _setWaterpackType(name, UPercentage.wrap(ratioOfGRP), prices);
    }

    function setFertilizerType(
        string calldata name,
        uint256 durationEffect,
        uint256 rewardBoost,
        uint256[] calldata prices
    ) external onlyHandler {
        _setFertilizerType(
            name,
            durationEffect,
            UPercentage.wrap(rewardBoost),
            prices
        );
    }

    function removeFertilizerType(string calldata name)
        external
        onlyHandler
        returns (bool)
    {
        return _removeFertilizerType(name);
    }

    function logWaterpacks(
        uint256[] memory nodeTokenIds,
        string memory waterpackType,
        uint256 creationTime,
        uint256[] memory amounts
    ) external onlyHandler {
        require(
            nodeTokenIds.length == amounts.length,
            "Addons: Length mismatch"
        );
        for (uint256 i = 0; i < nodeTokenIds.length; i++) {
            for (uint256 j = 0; j < amounts[i]; j++) {
                _logAddon(
                    nodeTokenIds[i],
                    "Waterpack",
                    waterpackType,
                    creationTime
                );
            }
        }
    }

    function logFertilizers(
        uint256[] memory nodeTokenIds,
        string memory fertilizerType,
        uint256 creationTime,
        uint256[] memory amounts
    ) external onlyHandler {
        require(
            nodeTokenIds.length == amounts.length,
            "Addons: Length mismatch"
        );

        for (uint256 i = 0; i < nodeTokenIds.length; i++) {
            for (uint256 j = 0; j < amounts[i]; j++) {
                _logAddon(
                    nodeTokenIds[i],
                    "Fertilizer",
                    fertilizerType,
                    creationTime
                );
            }
        }
    }

    //====== Internal API =====================================================//

    function _logAddon(
        uint256 nodeTokenId,
        string memory addonKind,
        string memory addonTypeName,
        uint256 creationTime
    ) internal {
        nodeAddonLogs[nodeTokenId].creationTime.push(creationTime);
        nodeAddonLogs[nodeTokenId].addonKind.push(addonKind);
        nodeAddonLogs[nodeTokenId].addonTypeName.push(addonTypeName);

        assert(
            nodeAddonLogs[nodeTokenId].creationTime.length ==
                nodeAddonLogs[nodeTokenId].addonKind.length
        );

        assert(
            nodeAddonLogs[nodeTokenId].creationTime.length ==
                nodeAddonLogs[nodeTokenId].addonTypeName.length
        );
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;

import "./HandlerAware.sol";
import "./libraries/Percentage.sol";

struct Waterpack {
    /// @dev How much lifetime is added to the node, expressed relative to the
    /// node's GRP time.
    UPercentage ratioOfGRP;
}

abstract contract Waterpacks is HandlerAware {
    using Percentages for UPercentage;

    struct WaterpackTypes {
        Waterpack[] items;
        string[] names;
        /// @dev Name to index + 1, 0 means the waterpack doesn't exists.
        mapping(string => uint256) indexOfPlusOne;
		mapping(string => mapping(string => uint256)) itemToNodeTypeToPrice;
    }

    WaterpackTypes internal waterpackTypes;

    //====== Getters =========================================================//

    function hasWaterpackType(string calldata name)
        external
        view
        returns (bool)
    {
        return _hasWaterpackType(name);
    }

	function getWaterpackType(string calldata name)
		external
		view
		returns (Waterpack memory)
	{
		return _getWaterpackType(name);
	}

	function getWaterpackPriceByNameAndNodeType(
		string calldata name,
		string calldata nodeType
	)
		external
		view
		returns (uint256)
	{
		require(_hasWaterpackType(name), "Waterpack type does not exist");
		return waterpackTypes.itemToNodeTypeToPrice[name][nodeType];
	}

    struct WaterpackView {
        string name;
        UPercentage ratioOfGRP;
        uint256[] prices;
    }

    function getWaterpackTypes() public view returns (WaterpackView[] memory) {
		string[] memory nodeTypes = _handler.getNodeTypesNames();
        WaterpackView[] memory output = new WaterpackView[](
            waterpackTypes.items.length
        );

        for (uint256 i = 0; i < waterpackTypes.items.length; i++) {
			uint256[] memory prices = new uint256[](nodeTypes.length);
			for (uint256 j = 0; j < nodeTypes.length; j++) {
				prices[j] = waterpackTypes.itemToNodeTypeToPrice[
					waterpackTypes.names[i]
				][nodeTypes[j]];
			}
            output[i] = WaterpackView({
                name: waterpackTypes.names[i],
                ratioOfGRP: waterpackTypes.items[i].ratioOfGRP,
                prices: prices
            });
        }

        return output;
    }

    //====== Internal API ====================================================//

    function _setWaterpackType(
        string calldata name,
        UPercentage ratioOfGRP,
        uint256[] calldata prices
    ) internal {
		string[] memory nodeTypes = _handler.getNodeTypesNames();
		require(nodeTypes.length == prices.length, "Waterpacks: length mismatch");

        uint256 indexPlusOne = waterpackTypes.indexOfPlusOne[name];
        if (indexPlusOne == 0) {
            waterpackTypes.names.push(name);
            waterpackTypes.items.push(
                Waterpack({ratioOfGRP: ratioOfGRP})
            );
            waterpackTypes.indexOfPlusOne[name] = waterpackTypes.names.length;
        } else {
            Waterpack storage waterpack = waterpackTypes.items[
                indexPlusOne - 1
            ];
            waterpack.ratioOfGRP = ratioOfGRP;
        }

		for (uint256 i = 0; i < nodeTypes.length; i++) {
			waterpackTypes.itemToNodeTypeToPrice[name][nodeTypes[i]] = prices[i];
		}
    }

    function _hasWaterpackType(string calldata name)
        internal
        view
        returns (bool ret)
    {
        ret = waterpackTypes.indexOfPlusOne[name] != 0;
    }

    function _getWaterpackType(string calldata name)
        internal
        view
        returns (Waterpack memory)
    {
        uint256 idx = waterpackTypes.indexOfPlusOne[name];
        require(idx != 0, "Waterpacks: nonexistant key");
        return waterpackTypes.items[idx - 1];
    }

    function _removeWaterpackType(string calldata name)
        internal
        returns (bool)
    {
        uint256 indexPlusOne = waterpackTypes.indexOfPlusOne[name];
        if (indexPlusOne == 0) {
            return false;
        }

        uint256 toDeleteIndex = indexPlusOne - 1;
        uint256 lastIndex = waterpackTypes.items.length - 1;

        if (lastIndex != toDeleteIndex) {
            Waterpack storage lastValue = waterpackTypes.items[lastIndex];
            string storage lastName = waterpackTypes.names[lastIndex];

            waterpackTypes.items[toDeleteIndex] = lastValue;
            waterpackTypes.names[toDeleteIndex] = lastName;
            waterpackTypes.indexOfPlusOne[lastName] = indexPlusOne;
        }

        waterpackTypes.items.pop();
        waterpackTypes.names.pop();
        waterpackTypes.indexOfPlusOne[name] = 0;

        return true;
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;

import "./HandlerAware.sol";
import "./libraries/Percentage.sol";

struct Fertilizer {
    /// @dev Duration of the effect of the fertilizer, expressed in seconds.
    uint256 durationEffect;
    /// @dev Percentage of additional boost provided during the effect of the
    /// fertilizer.
    UPercentage rewardBoost;
}

abstract contract Fertilizers is HandlerAware {
    using Percentages for UPercentage;

    struct FertilizerTypes {
        Fertilizer[] items;
        string[] names;
        /// @dev Name to index + 1, 0 means the fertilizer doesn't exists.
        mapping(string => uint256) indexOfPlusOne;
        mapping(string => mapping(string => uint256)) itemToNodeTypeToPrice;
    }

    FertilizerTypes internal fertilizerTypes;

    //====== Getters =========================================================//

    function hasFertilizerType(string calldata name)
        external
        view
        returns (bool)
    {
        return _hasFertilizerType(name);
    }

    function getFertilizerType(string calldata name)
        external
        view
        returns (Fertilizer memory)
    {
        return _getFertilizerType(name);
    }

	function getFertilizerPriceByNameAndNodeType(
		string calldata name,
		string calldata nodeType
	)
		external
		view
		returns (uint256)
	{
		require(_hasFertilizerType(name), "Fertilizer type does not exist");
		return fertilizerTypes.itemToNodeTypeToPrice[name][nodeType];
	}

    struct FertilizerView {
        string name;
        uint256 durationEffect;
        UPercentage rewardBoost;
        uint256[] prices;
    }

    function getFertilizerTypes()
        public
        view
        returns (FertilizerView[] memory)
    {
        string[] memory nodeTypes = _handler.getNodeTypesNames();
        FertilizerView[] memory output = new FertilizerView[](
            fertilizerTypes.items.length
        );

        for (uint256 i = 0; i < fertilizerTypes.items.length; i++) {
            string storage fertilizerName = fertilizerTypes.names[i];
            uint256[] memory prices = new uint256[](nodeTypes.length);
            for (uint256 j = 0; j < nodeTypes.length; j++) {
                prices[j] = fertilizerTypes.itemToNodeTypeToPrice[
                    fertilizerName
                ][nodeTypes[j]];
            }

            output[i] = FertilizerView({
                name: fertilizerName,
                durationEffect: fertilizerTypes.items[i].durationEffect,
                rewardBoost: fertilizerTypes.items[i].rewardBoost,
                prices: prices
            });
        }

        return output;
    }

    //====== Internal API ====================================================//

    function _setFertilizerType(
        string calldata name,
        uint256 durationEffect,
        UPercentage rewardBoost,
        uint256[] calldata prices
    ) internal {
		string[] memory nodeTypes = _handler.getNodeTypesNames();
		require(prices.length == nodeTypes.length, "Fertilizers: length mismatch");
        uint256 indexPlusOne = fertilizerTypes.indexOfPlusOne[name];
        if (indexPlusOne == 0) {
            fertilizerTypes.names.push(name);
            fertilizerTypes.items.push(
                Fertilizer({
                    durationEffect: durationEffect,
                    rewardBoost: rewardBoost
                })
            );
            fertilizerTypes.indexOfPlusOne[name] = fertilizerTypes.names.length;
        } else {
            Fertilizer storage fertilizer = fertilizerTypes.items[
                indexPlusOne - 1
            ];
            fertilizer.durationEffect = durationEffect;
            fertilizer.rewardBoost = rewardBoost;
        }

		for (uint256 i = 0; i < nodeTypes.length; i++) {
			fertilizerTypes.itemToNodeTypeToPrice[name][nodeTypes[i]] = prices[i];
		}
    }

    function _hasFertilizerType(string calldata name)
        internal
        view
        returns (bool ret)
    {
        ret = fertilizerTypes.indexOfPlusOne[name] != 0;
    }

    function _getFertilizerType(string calldata name)
        internal
        view
        returns (Fertilizer memory)
    {
        uint256 idx = fertilizerTypes.indexOfPlusOne[name];
        require(idx != 0, "Fertilizers: nonexistant key");
        return fertilizerTypes.items[idx - 1];
    }

    function _removeFertilizerType(string calldata name)
        internal
        returns (bool)
    {
        uint256 indexPlusOne = fertilizerTypes.indexOfPlusOne[name];
        if (indexPlusOne == 0) {
            return false;
        }

        uint256 toDeleteIndex = indexPlusOne - 1;
        uint256 lastIndex = fertilizerTypes.items.length - 1;

        if (lastIndex != toDeleteIndex) {
            Fertilizer storage lastValue = fertilizerTypes.items[lastIndex];
            string storage lastName = fertilizerTypes.names[lastIndex];

            fertilizerTypes.items[toDeleteIndex] = lastValue;
            fertilizerTypes.names[toDeleteIndex] = lastName;
            fertilizerTypes.indexOfPlusOne[lastName] = indexPlusOne;
        }

        fertilizerTypes.items.pop();
        fertilizerTypes.names.pop();
        fertilizerTypes.indexOfPlusOne[name] = 0;

        return true;
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;

interface IHandler {
	function nodeTransferFrom(address from, address to, uint tokenId) external;
	function plotTransferFrom(address from, address to, uint tokenId) external;
	function getAttribute(uint tokenId) external view returns(string memory);
	function getNodeTypesNames() external view returns(string[] memory);
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;

import "./IHandler.sol";

abstract contract HandlerAware {
    IHandler internal _handler;
    modifier onlyHandler {
        require(msg.sender == address(_handler));
        _;
    }

    constructor(
        IHandler handler
    ) {
        _handler = handler;
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.8;

type UPercentage is uint256;

library Percentages {
	function from(uint32 val) internal pure returns (UPercentage) {
		require(val <= 10000, "Percentages: out of bounds");
		return UPercentage.wrap(val);
	}

	function from_unbounded(uint256 val) internal pure returns(UPercentage) {
		return UPercentage.wrap(val);
	}

	function times(UPercentage p, uint256 val) internal pure returns (uint256) {
		return val * UPercentage.unwrap(p) / 10000;
	}
}