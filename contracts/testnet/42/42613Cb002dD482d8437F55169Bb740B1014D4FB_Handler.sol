// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;

import "./INodeType.sol";
import "./ISpringNode.sol";
import "./ISpringLuckyBox.sol";
import "./ISwapper.sol";
import "./ISpringPlot.sol";
import "./Owners.sol";
import "./Addons.sol";

contract Handler is Owners {
    event NewNode(address indexed owner, string indexed name, uint256 count);

    event NewPlot(address indexed owner, string indexed name, uint256 count);

    struct NodeType {
        string[] keys; // nodeTypeName to address
        mapping(string => address) values;
        mapping(string => uint256) indexOf;
        mapping(string => bool) inserted;
    }

    struct Token {
        uint256[] keys; // token ids to nodeTypeName
        mapping(uint256 => string) values;
        mapping(uint256 => uint256) indexOf;
        mapping(uint256 => bool) inserted;
    }

    NodeType private mapNt;
    Token private mapToken;

    address public nft;

    ISpringLuckyBox private lucky;
    ISwapper private swapper;
    ISpringPlot private plot;

    Addons private addons;

    modifier onlyNft() {
        require(msg.sender == nft, "Handler: Only Nft");
        _;
    }

    // external
    function addNodeType(address _addr) external onlyOwners {
        string memory name = INodeType(_addr).name();
        require(!mapNt.inserted[name], "Handler: NodeType already exists");
        mapNtSet(name, _addr);
    }

    function addMultipleNodeTypes(address[] memory _addrs) external onlyOwners {
        for (uint256 i = 0; i < _addrs.length; i++) {
            string memory name = INodeType(_addrs[i]).name();
            mapNtSet(name, _addrs[i]);
        }
    }

    function updateNodeTypeAddress(string memory name, address _addr)
        external
        onlyOwners
    {
        require(mapNt.inserted[name], "Handler: NodeType doesnt exist");
        mapNt.values[name] = _addr;
    }

    function setPlotType(
        string memory name,
        uint256 price,
        uint256 maxNodes,
        string[] memory allowedNodeTypes,
        UPercentage additionalGRPTime,
        UPercentage waterpackGRPBoost
    ) external onlyOwners {
        plot.setPlotType({
            name: name,
            price: price,
            maxNodes: maxNodes,
            allowedNodeTypes: allowedNodeTypes,
            additionalGRPTime: additionalGRPTime,
            waterpackGRPBoost: waterpackGRPBoost
        });
    }

    function setWaterpackType(
        string calldata name,
        uint256 ratioOfGRP,
        uint256[] calldata prices
    ) external onlyOwners {
        addons.setWaterpackType(name, ratioOfGRP, prices);
    }

    function setFertilizerType(
        string calldata name,
        uint256 durationEffect,
        uint256 rewardBoost,
        uint256[] calldata prices
    ) external onlyOwners {
        addons.setFertilizerType(name, durationEffect, rewardBoost, prices);
    }

    uint256 private transientPlotTokenId = 0;
    modifier setTransientPlotTokenId(uint256 plotId) {
        transientPlotTokenId = plotId;
        _;
        transientPlotTokenId = 0;
    }

    function nodeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external onlyNft {
        INodeType(mapNt.values[mapToken.values[tokenId]]).transferFrom(
            from,
            to,
            tokenId
        );

        plot.moveNodeToPlot(to, tokenId, transientPlotTokenId);
    }

    function plotTransferFrom(
        address from,
        address to,
        uint256 plotTokenId
    ) external setTransientPlotTokenId(plotTokenId) {
        require(msg.sender == address(plot), "Handler: Only Plot");

        PlotInstanceView memory instance = plot.getPlotByTokenId(plotTokenId);

        for (uint256 i = 0; i < instance.nodeTokenIds.length; i++) {
            uint256 nodeTokenId = instance.nodeTokenIds[i];
            ISpringNode(nft).transferFrom(from, to, nodeTokenId);
        }
    }

    function createPlotWithTokens(
        address tokenIn,
        string memory plotType,
        string memory sponso
    ) external returns (uint256) {
        (uint256 totalPrice, uint256 tokenId) = plot.createNewPlot(
            msg.sender,
            plotType
        );
        if (totalPrice > 0) {
            swapper.swapNewPlot(tokenIn, msg.sender, totalPrice, sponso);
        }

        emit NewPlot(msg.sender, plotType, 1);

        return tokenId;
    }

    // function createNodesWithLuckyBoxes(
    // 	uint256[] memory tokenIdsLuckyBoxes
    // ) external {
    // 	uint256[] memory tokenIds = new uint256[](tokenIdsLuckyBoxes.length);
    // 	return _createNodesWithLuckyBoxes(tokenIdsLuckyBoxes, tokenIds);
    // }

    function createNodesWithLuckyBoxes(
        uint256[] memory tokenIdsLuckyBoxes,
        uint256[] memory tokenIdsPlots
    ) external {
        return _createNodesWithLuckyBoxes(tokenIdsLuckyBoxes, tokenIdsPlots);
    }

    function _createNodesWithLuckyBoxes(
        uint256[] memory tokenIdsLuckyBoxes,
        uint256[] memory tokenIdsPlots
    ) internal {
        require(
            tokenIdsLuckyBoxes.length == tokenIdsPlots.length,
            "Handler: Length mismatch"
        );

        string[] memory nodeTypes;
        string[] memory features;

        (nodeTypes, features) = lucky.createNodesWithLuckyBoxes(
            msg.sender,
            tokenIdsLuckyBoxes
        );

        assert(nodeTypes.length == tokenIdsPlots.length);

        for (uint256 i = 0; i < nodeTypes.length; i++) {
            uint256[] memory tokenIdArray = _setUpNodes(
                nodeTypes[i],
                msg.sender,
                1
            );
            assert(tokenIdArray.length == 1);

            INodeType nodeType = INodeType(mapNt.values[nodeTypes[i]]);
            nodeType.createNodeWithLuckyBox(
                msg.sender,
                tokenIdArray,
                features[i]
            );

            if (tokenIdsPlots[i] == 0) {
                tokenIdsPlots[i] = plot.findOrCreateDefaultPlot(msg.sender);
            }

            plot.moveNodeToPlot(msg.sender, tokenIdArray[0], tokenIdsPlots[i]);
            _onMoveNodeToPlot(msg.sender, tokenIdArray[0], tokenIdsPlots[i]);

            emit NewNode(msg.sender, nodeTypes[i], 1);
        }
    }

    function createNodesAirDrop(
        string memory name,
        address user,
        string memory feature,
        uint256 count
    ) external onlyOwners {
        require(count > 0, "Handler: Count must be greater than 0");

        for (uint256 i = 0; i < count; i++) {
            uint256[] memory tokenIds = _setUpNodes(name, user, 1);
            assert(tokenIds.length == 1);

            INodeType(mapNt.values[name]).createNodeCustom(
                user,
                tokenIds,
                feature
            );

            uint256 plotTokenId = plot.findOrCreateDefaultPlot(msg.sender);
            plot.moveNodeToPlot(msg.sender, tokenIds[0], plotTokenId);
            _onMoveNodeToPlot(msg.sender, tokenIds[0], plotTokenId);
        }

        emit NewNode(user, name, count);
    }

    function createLuckyBoxesWithTokens(
        address tokenIn,
        address user,
        string memory name,
        uint256 count,
        string memory sponso
    ) external {
        uint256 price = lucky.createLuckyBoxesWithTokens(name, count, user);

        swapper.swapCreateLuckyBoxesWithTokens(
            tokenIn,
            msg.sender,
            price,
            sponso
        );
    }

    function createLuckyBoxesAirDrop(
        string memory name,
        address user,
        uint256 count
    ) external onlyOwners {
        lucky.createLuckyBoxesAirDrop(name, count, user);
    }

    function nodeEvolution(
        string memory name,
        address user,
        uint256[] memory tokenIds,
        string memory feature
    ) external onlyOwners {
        require(tokenIds.length == 1, "Handler: Evolve one by one");
        require(mapNt.inserted[name], "Handler: NodeType doesnt exist");
        require(mapToken.inserted[tokenIds[0]], "Handler: Token doesnt exist");

        INodeType(mapNt.values[mapToken.values[tokenIds[0]]]).burnFrom(
            user,
            tokenIds
        );

        mapTokenSet(tokenIds[0], name);

        INodeType(mapNt.values[name]).createNodeCustom(
            user,
            tokenIds,
            feature
        );

        ISpringNode(nft).setTokenIdToNodeType(tokenIds[0], name);
    }

    function claimRewardsAll(address tokenOut, address user) external {
        require(
            user == msg.sender || isOwner[msg.sender],
            "Handler: Dont mess with other claims"
        );

        uint256 rewardsTotal;
        uint256 feesTotal;

        for (uint256 i = 0; i < mapNt.keys.length; i++) {
            (uint256 rewards, uint256 fees) = INodeType(
                mapNt.values[mapNt.keys[i]]
            ).claimRewardsAll(user);
            rewardsTotal += rewards;
            feesTotal += fees;
        }

        swapper.swapClaimRewardsAll(tokenOut, user, rewardsTotal, feesTotal);
    }

    function claimRewardsBatch(
        address tokenOut,
        address user,
        string[] memory names,
        uint256[][] memory tokenIds
    ) public {
        require(
            user == msg.sender || isOwner[msg.sender],
            "Handler: Dont mess with other claims"
        );

        uint256 rewardsTotal;
        uint256 feesTotal;

        require(names.length == tokenIds.length, "Handler: Length mismatch");

        for (uint256 i = 0; i < names.length; i++) {
            require(mapNt.inserted[names[i]], "Handler: NodeType doesnt exist");

            (uint256 rewards, uint256 fees) = INodeType(mapNt.values[names[i]])
                .claimRewardsBatch(user, tokenIds[i]);
            rewardsTotal += rewards;
            feesTotal += fees;
        }

        swapper.swapClaimRewardsBatch(tokenOut, user, rewardsTotal, feesTotal);
    }

    function claimRewardsNodeType(
        address tokenOut,
        address user,
        string memory name
    ) public {
        require(
            user == msg.sender || isOwner[msg.sender],
            "Handler: Dont mess with other claims"
        );
        require(mapNt.inserted[name], "Handler: NodeType doesnt exist");

        (uint256 rewardsTotal, uint256 feesTotal) = INodeType(
            mapNt.values[name]
        ).claimRewardsAll(user);

        swapper.swapClaimRewardsNodeType(
            tokenOut,
            user,
            rewardsTotal,
            feesTotal
        );
    }

    function applyWaterpackBatch(
        address tokenIn,
        address user,
        uint256[] memory tokenIds,
        string calldata waterpackTypeName,
        uint256[] memory amounts,
        string memory sponso
    ) external {
        require(
            user == msg.sender || isOwner[msg.sender],
            "Handler: Dont mess with other claims"
        );
        require(
            addons.hasWaterpackType(waterpackTypeName),
            "Handler: Waterpack type doesn't exists"
        );

        require(tokenIds.length == amounts.length, "Handler: Length mismatch");

        Waterpack memory waterpack = addons.getWaterpackType(waterpackTypeName);
        uint256 totalPrice = 0;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            string memory name = ISpringNode(nft).tokenIdsToType(tokenIds[i]);
            assert(mapNt.inserted[name]);

            uint256[] memory waterpackTokenIds = new uint256[](1);
            uint256[] memory amountTokenId = new uint256[](1);
            waterpackTokenIds[0] = tokenIds[i];
            amountTokenId[0] = amounts[i];
            INodeType(mapNt.values[name]).applyWaterpackBatch(
                user,
                waterpackTokenIds,
                waterpack.ratioOfGRP,
                amountTokenId
            );

            UPercentage plotBoost = plot
                .getPlotTypeByNodeTokenId(tokenIds[i])
                .waterpackGRPBoost;

            INodeType(mapNt.values[name]).addPlotAdditionalLifetime(
                user,
                tokenIds[i],
                plotBoost,
                amounts[i]
            );

            totalPrice +=
                addons.getWaterpackPriceByNameAndNodeType(
                    waterpackTypeName,
                    name
                ) *
                amounts[i];
        }

        addons.logWaterpacks(
            tokenIds,
            waterpackTypeName,
            block.timestamp,
            amounts
        );

        swapper.swapApplyWaterpack(tokenIn, user, totalPrice, sponso);
    }

    function applyFertilizerBatch(
        address tokenIn,
        address user,
        string[] memory nodeTypesNames,
        uint256[][] memory tokenIds,
        string calldata fertilizerTypeName,
        uint256[][] memory amount,
        string memory sponso
    ) external {
        require(
            user == msg.sender || isOwner[msg.sender],
            "Handler: Dont mess with other claims"
        );
        require(
            addons.hasFertilizerType(fertilizerTypeName),
            "Handler: Fertilizer type doesn't exists"
        );

        require(
            nodeTypesNames.length == tokenIds.length,
            "Handler: Length mismatch"
        );

        Fertilizer memory fertilizer = addons.getFertilizerType(
            fertilizerTypeName
        );

        uint256 totalPrice = 0;
        for (uint256 i = 0; i < nodeTypesNames.length; i++) {
            string memory name = nodeTypesNames[i];
            require(mapNt.inserted[name], "Handler: NodeType doesnt exist");
            require(
                tokenIds[i].length == amount[i].length,
                "Handler: Length mismatch"
            );

            INodeType(mapNt.values[name]).applyFertilizerBatch(
                user,
                tokenIds[i],
                fertilizer.durationEffect,
                fertilizer.rewardBoost,
                amount[i]
            );

            for (uint256 j = 0; j < tokenIds[i].length; j++) {
                totalPrice +=
                    addons.getFertilizerPriceByNameAndNodeType(
                        fertilizerTypeName,
                        name
                    ) *
                    amount[i][j];
            }

            addons.logFertilizers(
                tokenIds[i],
                fertilizerTypeName,
                block.timestamp,
                amount[i]
            );
        }

        swapper.swapApplyFertilizer(tokenIn, user, totalPrice, sponso);
    }

    function moveNodesToPlots(
        uint256[] memory plotTokenIds,
        uint256[][] memory nodeTokenIds
    ) external {
        require(
            plotTokenIds.length == nodeTokenIds.length,
            "Handler: Length mismatch"
        );

        plot.moveNodesToPlots(msg.sender, nodeTokenIds, plotTokenIds);

        for (uint256 i = 0; i < plotTokenIds.length; i++) {
            for (uint256 j = 0; j < nodeTokenIds[i].length; j++) {
                _onMoveNodeToPlot(
                    msg.sender,
                    nodeTokenIds[i][j],
                    plotTokenIds[i]
                );
            }
        }
    }

    // external setters
    // handler setters
    function setNft(address _new) external onlyOwners {
        require(_new != address(0), "Handler: Nft cannot be address zero");
        nft = _new;
    }

    function setLucky(address _new) external onlyOwners {
        require(_new != address(0), "Handler: Loot cannot be address zero");
        lucky = ISpringLuckyBox(_new);
    }

    function setSwapper(address _new) external onlyOwners {
        require(_new != address(0), "Handler: Swapper cannot be address zero");
        swapper = ISwapper(_new);
    }

    function setPlot(address _new) external onlyOwners {
        require(_new != address(0), "Handler: Plot cannot be address zero");
        plot = ISpringPlot(_new);
    }

    function setAddons(Addons _new) external onlyOwners {
        require(
            address(_new) != address(0),
            "Handler: Addon cannot be address zero"
        );
        addons = _new;
    }

    // external view
    function getNodeTypesSize() external view returns (uint256) {
        return mapNt.keys.length;
    }

    function getNodeTypesNames() external view returns (string[] memory) {
        return mapNt.keys;
    }

    function getTotalCreatedNodes() external view returns (uint256) {
        uint256 totalNodes;
        for (uint256 i = 0; i < mapNt.keys.length; i++) {
            totalNodes += INodeType(mapNt.values[mapNt.keys[i]])
                .totalCreatedNodes();
        }
        return totalNodes;
    }

    function getNodeTypesBetweenIndexes(uint256 iStart, uint256 iEnd)
        external
        view
        returns (string[] memory)
    {
        string[] memory nodeTypes = new string[](iEnd - iStart);
        for (uint256 i = iStart; i < iEnd; i++)
            nodeTypes[i - iStart] = mapNt.keys[i];
        return nodeTypes;
    }

    function getNodeTypesAddress(string memory key)
        external
        view
        returns (address)
    {
        require(mapNt.inserted[key], "NodeType doesnt exist");
        return mapNt.values[key];
    }

    function getAttribute(uint256 tokenId)
        external
        view
        returns (string memory)
    {
        return
            INodeType(mapNt.values[mapToken.values[tokenId]]).getAttribute(
                tokenId
            );
    }

    function getTokenIdsSize() external view returns (uint256) {
        return mapToken.keys.length;
    }

    function getTokenIdsBetweenIndexes(uint256 iStart, uint256 iEnd)
        external
        view
        returns (uint256[] memory)
    {
        uint256[] memory ids = new uint256[](iEnd - iStart);
        for (uint256 i = iStart; i < iEnd; i++)
            ids[i - iStart] = mapToken.keys[i];
        return ids;
    }

    function getTokenIdsNodeTypeBetweenIndexes(uint256 iStart, uint256 iEnd)
        external
        view
        returns (string[] memory)
    {
        string[] memory names = new string[](iEnd - iStart);
        for (uint256 i = iStart; i < iEnd; i++)
            names[i - iStart] = mapToken.values[mapToken.keys[i]];
        return names;
    }

    function getTokenIdNodeTypeName(uint256 key)
        external
        view
        returns (string memory)
    {
        require(mapToken.inserted[key], "TokenId doesnt exist");
        return mapToken.values[key];
    }

    function getTotalNodesOf(address user) external view returns (uint256) {
        uint256 totalNodes;
        for (uint256 i = 0; i < mapNt.keys.length; i++) {
            totalNodes += INodeType(mapNt.values[mapNt.keys[i]])
                .getTotalNodesNumberOf(user);
        }
        return totalNodes;
    }

    function getClaimableRewardsOf(address user)
        external
        view
        returns (uint256, uint256)
    {
        uint256 rewardsTotal;
        uint256 feesTotal;
        for (uint256 i = 0; i < mapNt.keys.length; i++) {
            (uint256 rewards, uint256 fees) = INodeType(
                mapNt.values[mapNt.keys[i]]
            ).calculateUserRewards(user);
            rewardsTotal += rewards;
            feesTotal += fees;
        }
        return (rewardsTotal, feesTotal);
    }

    // internal
    function _setUpNodes(
        string memory name,
        address user,
        uint256 count
    ) private returns (uint256[] memory) {
        require(mapNt.inserted[name], "Handler: NodeType doesnt exist");

        uint256[] memory tokenIds = ISpringNode(nft).generateNfts(
            name,
            user,
            count
        );

        for (uint256 i = 0; i < tokenIds.length; i++)
            mapTokenSet(tokenIds[i], name);

        return tokenIds;
    }

    function _onMoveNodeToPlot(
        address owner,
        uint256 nodeTokenId,
        uint256 plotTokenId
    ) private {
        string memory nodeTypeName = ISpringNode(nft).tokenIdsToType(
            nodeTokenId
        );
        require(
            mapNt.inserted[nodeTypeName],
            "Handler: NodeType doesn't exist"
        );
        return
            _onMoveNodeToPlot(
                owner,
                nodeTokenId,
                plotTokenId,
                INodeType(mapNt.values[nodeTypeName])
            );
    }

    function _onMoveNodeToPlot(
        address owner,
        uint256 nodeTokenId,
        uint256 plotTokenId,
        INodeType nodeType
    ) private {
        nodeType.setPlotAdditionalLifetime(
            owner,
            nodeTokenId,
            plot.getPlotTypeByTokenId(plotTokenId).additionalGRPTime
        );
    }

    function strcmp(string memory s1, string memory s2)
        internal
        pure
        returns (bool)
    {
        return (keccak256(abi.encodePacked((s1))) ==
            keccak256(abi.encodePacked((s2))));
    }

    // private
    // maps
    function mapNtSet(string memory key, address value) private {
        if (mapNt.inserted[key]) {
            mapNt.values[key] = value;
        } else {
            mapNt.inserted[key] = true;
            mapNt.values[key] = value;
            mapNt.indexOf[key] = mapNt.keys.length;
            mapNt.keys.push(key);
        }
    }

    function mapTokenSet(uint256 key, string memory value) private {
        if (mapToken.inserted[key]) {
            mapToken.values[key] = value;
        } else {
            mapToken.inserted[key] = true;
            mapToken.values[key] = value;
            mapToken.indexOf[key] = mapToken.keys.length;
            mapToken.keys.push(key);
        }
    }

    function mapNtRemove(string memory key) private {
        if (!mapNt.inserted[key]) {
            return;
        }

        delete mapNt.inserted[key];
        delete mapNt.values[key];

        uint256 index = mapNt.indexOf[key];
        uint256 lastIndex = mapNt.keys.length - 1;
        string memory lastKey = mapNt.keys[lastIndex];

        mapNt.indexOf[lastKey] = index;
        delete mapNt.indexOf[key];

        if (lastIndex != index) mapNt.keys[index] = lastKey;
        mapNt.keys.pop();
    }

    function mapTokenRemove(uint256 key) private {
        if (!mapToken.inserted[key]) {
            return;
        }

        delete mapToken.inserted[key];
        delete mapToken.values[key];

        uint256 index = mapToken.indexOf[key];
        uint256 lastIndex = mapToken.keys.length - 1;
        uint256 lastKey = mapToken.keys[lastIndex];

        mapToken.indexOf[lastKey] = index;
        delete mapToken.indexOf[key];

        if (lastIndex != index) mapToken.keys[index] = lastKey;
        mapToken.keys.pop();
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;

import "./libraries/Percentage.sol";

interface INodeType {
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function burnFrom(address from, uint256[] memory tokenIds)
        external
        returns (uint256);

    function createNodeWithLuckyBox(
        address user,
        uint256[] memory tokenIds,
        string memory feature
    ) external;

    function createNodeCustom(
        address user,
        uint256[] memory tokenIds,
        string memory feature
    ) external;

    function getTotalNodesNumberOf(address user)
        external
        view
        returns (uint256);

    function getAttribute(uint256 tokenId)
        external
        view
        returns (string memory);

    function claimRewardsAll(address user) external returns (uint256, uint256);

    function claimRewardsBatch(address user, uint256[] memory tokenIds)
        external
        returns (uint256, uint256);

    function calculateUserRewards(address user)
        external
        view
        returns (uint256, uint256);

    function applyWaterpackBatch(
        address user,
        uint256[] memory tokenIds,
        UPercentage ratioOfGRPExtended,
        uint256[] memory amounts
    ) external;

    function applyFertilizerBatch(
        address user,
        uint256[] memory tokenIds,
        uint256 durationEffect,
        UPercentage boostAmount,
        uint256[] memory amounts
    ) external;

    function setPlotAdditionalLifetime(
        address user,
        uint256 tokenId,
        UPercentage amountOfGRP
    ) external;

    function addPlotAdditionalLifetime(
        address user,
        uint256 tokenId,
        UPercentage amountOfGRP,
        uint256 amount
    ) external;

    function name() external view returns (string memory);

    function totalCreatedNodes() external view returns (uint256);
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

interface ISpringNode is IERC721Enumerable {
	function generateNfts(
		string memory name,
		address user,
		uint count
	)
		external
		returns(uint[] memory);
	
	function burnBatch(address user, uint[] memory tokenIds) external;

	function setTokenIdToNodeType(uint tokenId, string memory nodeType) external;

	function tokenIdsToType(uint256 tokenId) external view returns (string memory nodeType);
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;

interface ISpringLuckyBox {
	function createLuckyBoxesWithTokens(
		string memory name,
		uint count,
		address user
	) external returns(uint);
	
	function createLuckyBoxesAirDrop(
		string memory name,
		uint count,
		address user
	) external;
	
	function createNodesWithLuckyBoxes(
		address user,
		uint[] memory tokenIds
	)
		external
		returns(
			string[] memory,
			string[] memory
		);
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;

interface ISwapper {
	function swapCreateNodesWithTokens(
		address tokenIn, 
		address user, 
		uint price,
		string memory sponso
	) external;
	
	function swapCreateNodesWithPending(
		address tokenOut, 
		address user, 
		uint rewardsTotal, 
		uint feesTotal
	) external;
	
	function swapCreateLuckyBoxesWithTokens(
		address tokenIn, 
		address user, 
		uint price,
		string memory sponso
	) external;

	function swapClaimRewardsAll(
		address tokenOut, 
		address user, 
		uint rewardsTotal, 
		uint feesTotal
	) external;

	function swapClaimRewardsBatch(
		address tokenOut, 
		address user, 
		uint rewardsTotal, 
		uint feesTotal
	) external;
	
	function swapClaimRewardsNodeType(
		address tokenOut, 
		address user, 
		uint rewardsTotal, 
		uint feesTotal
	) external;

	function swapApplyWaterpack(
		address tokenIn,
		address user,
		uint amount,
		string memory sponso
	) external;

	function swapApplyFertilizer(
		address tokenIn,
		address user,
		uint amount,
		string memory sponso
	) external;

	function swapNewPlot(
		address tokenIn,
		address user,
		uint amount,
		string memory sponso
	) external;
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./libraries/Percentage.sol";

struct PlotTypeView {
    string name;
    uint256 maxNodes;
    uint256 price;
    string[] allowedNodeTypes;
    UPercentage additionalGRPTime;
    UPercentage waterpackGRPBoost;
}

struct PlotInstanceView {
    string plotType;
    address owner;
    uint256[] nodeTokenIds;
}

/// @notice A plot houses trees (nodes) and adds additional lifetime to the
/// nodes it owns.
/// @dev Token IDs should start at `1`, so we can use `0` as a null value.
interface ISpringPlot is IERC721Enumerable {
    function createNewPlot(address user, string memory plotTypeName)
        external
        returns (uint256 price, uint256 tokenId);

    function moveNodeToPlot(
        address user,
        uint256 nodeTokenId,
        uint256 plotTokenId
    ) external;

    function moveNodesToPlots(
        address user,
        uint256[][] memory nodeTokenId,
        uint256[] memory plotTokenId
    ) external;

    function setPlotType(
        string memory name,
        uint256 price,
        uint256 maxNodes,
        string[] memory allowedNodeTypes,
        UPercentage additionalGRPTime,
        UPercentage waterpackGRPBoost
    ) external;

    /// @dev Returns the plot type of an instanciated plot, given its `tokenId`.
    /// Reverts if the plot doesn't exist.
    function getPlotTypeByTokenId(uint256 tokenId)
        external
        view
        returns (PlotTypeView memory);

    function findOrCreateDefaultPlot(address user)
        external
        returns (uint256 tokenId);

    function getPlotTypeByNodeTokenId(uint256 tokenId)
        external
        view
        returns (PlotTypeView memory);

    // /// @dev Returns the total amount of plot types.
    // function getPlotTypeSize() external view returns (uint256 plotTypeAmount);

    // /// @dev Returns the plot type at a given `index`. Use along with
    // /// {getPlotTypeSize} to enumerate all plot types, or {getPlotTypes}.
    // function getPlotTypeByIndex(uint256 index) external view
    //     returns (PlotTypeView memory);

    // /// @dev Returns the plot type with a given `name`. Reverts if the plot type
    // /// doesn't exist.
    // function getPlotTypeByName(string memory name) external view
    //     returns (PlotTypeView memory);

    // /// @dev Returns the list of all enumerable plot types.
    // function getPlotTypes() external view returns (PlotTypeView[] memory);

    // /// @dev Returns the number of plots detained by a given user.
    // function getPlotsOfUserSize(address user) external view
    //     returns (uint256 plotAmount);

    /// @dev Returns the plot instance of a given token id. Reverts if the plot
    /// doesn't exist.
    function getPlotByTokenId(uint256 tokenId)
        external
        view
        returns (PlotInstanceView memory);

    // /// @dev Returns the plot instance of a given user at a given `index`. Use
    // /// along with {getPlotsOfUserSize} to enumerate all plots of a user, or
    // /// {getPlotsOfUser}.
    // function getPlotsOfUserByIndex(address user, uint256 index) external view
    //     returns (PlotTypeInstance memory);

    // /// @dev Returns the list of all plots of a given user.
    // function getPlotsOfUser(address user) external view
    //     returns (PlotTypeInstance[] memory);

    // /// @dev Returns the token ID of the next available plot of a given type for
    // /// a given user, or `0` if no plot is available.
    // function getPlotTokenIdOfNextEmptyOfType(address user, string memory plotType) external view
    //     returns (uint256 plotTokenIdOrZero);

    // /// @dev Returns the token ID of the plot housing the given node. Reverts if
    // /// the node token ID is not attributed.
    // function getPlotTokenIdOfNodeTokenId(uint256 nodeTokenId) external view
    //     returns (uint256 plotTokenId);
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;

contract Owners {
	
	address[] public owners;
	mapping(address => bool) public isOwner;

	constructor() {
		owners.push(msg.sender);
		isOwner[msg.sender] = true;
	}

	modifier onlySuperOwner() {
		require(owners[0] == msg.sender, "Owners: Only Super Owner");
		_;
	}
	
	modifier onlyOwners() {
		require(isOwner[msg.sender], "Owners: Only Owner");
		_;
	}

	function addOwner(address _new, bool _change) external onlySuperOwner {
		require(!isOwner[_new], "Owners: Already owner");
		isOwner[_new] = true;
		if (_change) {
			owners.push(owners[0]);
			owners[0] = _new;
		} else {
			owners.push(_new);
		}
	}

	function removeOwner(address _new) external onlySuperOwner {
		require(isOwner[_new], "Owners: Not owner");
		require(_new != owners[0], "Owners: Cannot remove super owner");
		for (uint i = 1; i < owners.length; i++) {
			if (owners[i] == _new) {
				owners[i] = owners[owners.length - 1];
				owners.pop();
				break;
			}
		}
		isOwner[_new] = false;
	}

	function getOwnersSize() external view returns(uint) {
		return owners.length;
	}
}

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../ERC721.sol";
import "./IERC721Enumerable.sol";

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
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