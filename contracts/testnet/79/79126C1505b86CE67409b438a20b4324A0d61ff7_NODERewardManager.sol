// SPDX-License-Identifier: MIT
// WGMI

pragma solidity ^0.8.0;

import "./deps/PaymentSplitter.sol";
import "./interfaces/IERC20.sol";
import "./deps/IterableNodeTypeMapping.sol";
import "./interfaces/IPancakeRouter02.sol";

contract NODERewardManager is PaymentSplitter {
    using IterableNodeTypeMapping for IterableNodeTypeMapping.Map;

    struct NodeEntity {
        string nodeTypeName;       
        uint256 creationTime;
        uint256 lastClaimTime;
    }
    
    IterableNodeTypeMapping.Map private _nodeTypes;
	mapping(string => mapping(address => NodeEntity[])) private _nodeTypeOwner;
	mapping(string => mapping(address => uint256)) private _nodeTypeOwnerLevelUp;
	mapping(string => mapping(address => uint256)) private _nodeTypeOwnerCreatedPending;

    address public _gateKeeper;
    address public _trapezTokenAddress;


    string public _defaultNodeTypeName;

    IPancakeRouter02 public _uniswapV2Router;

    address public futurUsePool;
    address public distributionPool;
    address public poolHandler;

    uint256 public rewardsFee;
    uint256 public liquidityPoolFee;
    uint256 public futurFee;
    uint256 public totalFees;

    uint256 public cashoutFee;

    bool private swapping = false;
    bool private swapLiquify = true;
    uint256 public swapTokensAmount;

	bool private openCreate = false;
	bool private openLevelUp = false;
	bool private openPending = false;

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    constructor(
        address token,
        address[] memory payees,
        uint256[] memory shares,
        address[] memory addresses,
        uint256[] memory fees,
        uint256 swapAmount,
        address uniV2Router
    ) PaymentSplitter(payees, shares) {
        _gateKeeper = msg.sender;
        _trapezTokenAddress = token;
        
		futurUsePool = addresses[0];
        distributionPool = addresses[1];
		poolHandler = addresses[2];

        require(futurUsePool != address(0) && 
			distributionPool != address(0) && 
			poolHandler != address(0), 
			"FUTUR, REWARD & POOL ADDRESS CANNOT BE ZERO");
        
		require(uniV2Router != address(0), "ROUTER CANNOT BE ZERO");
        _uniswapV2Router = IPancakeRouter02(uniV2Router);

        require(
            fees[0] != 0 && fees[1] != 0 && fees[2] != 0 && fees[3] != 0,
            "CONSTR: Fees equal 0"
        );
        futurFee = fees[0];
        rewardsFee = fees[1];
        liquidityPoolFee = fees[2];
        cashoutFee = fees[3];

        totalFees = rewardsFee + liquidityPoolFee + futurFee;

        require(swapAmount > 0, "CONSTR: Swap amount incorrect");
        swapTokensAmount = swapAmount * (10**18);
    }

    modifier onlySentry() {
        require(msg.sender == _trapezTokenAddress || msg.sender == _gateKeeper, "Fuck off");
        _;
    }

	// Core
	function addNodeType(
		string memory nodeTypeName, 
		uint256[] memory values
	) public onlySentry {
		require(bytes(nodeTypeName).length > 0, "addNodeType: Empty name");
        require(!_doesNodeTypeExist(nodeTypeName), "addNodeType: same nodeTypeName exists.");

        _nodeTypes.set(nodeTypeName, IterableNodeTypeMapping.NodeType({
                nodeTypeName: nodeTypeName,
                nodePrice: values[0],
                claimTime: values[1],
                rewardAmount: values[2],
                claimTaxBeforeTime: values[3],
				count: 0,
				max: values[4],
				earlyClaimTax: values[5],
				maxLevelUpGlobal: values[6],
				maxLevelUpUser: values[7],
				maxCreationPendingGlobal: values[8],
				maxCreationPendingUser: values[9]
            })
        );
    }

	function changeNodeType(
		string memory nodeTypeName, 
		uint256 nodePrice, 
		uint256 claimTime, 
		uint256 rewardAmount, 
		uint256 claimTaxBeforeTime,
		uint256 max,
		uint256 earlyClaimTax,
		uint256 maxLevelUpGlobal,
		uint256 maxLevelUpUser,
		uint256 maxCreationPendingGlobal,
		uint256 maxCreationPendingUser
	) public onlySentry {
        require(_doesNodeTypeExist(nodeTypeName), 
				"changeNodeType: nodeTypeName does not exist");

        IterableNodeTypeMapping.NodeType storage nt = _nodeTypes.get(nodeTypeName);

        if (nodePrice > 0) {
            nt.nodePrice = nodePrice;
        }
        if (claimTime > 0) {
            nt.claimTime = claimTime;
        }
        if (rewardAmount > 0) {
            nt.rewardAmount = rewardAmount;
        }
        if (claimTaxBeforeTime > 0) {
            nt.claimTaxBeforeTime = claimTaxBeforeTime;
        }
        if (max > 0) {
            nt.max = max;
        }
        if (earlyClaimTax > 0) {
            nt.earlyClaimTax = earlyClaimTax;
        }
        if (maxLevelUpGlobal> 0) {
            nt.maxLevelUpGlobal = maxLevelUpGlobal;
        }
        if (maxLevelUpUser > 0) {
            nt.maxLevelUpUser = maxLevelUpUser;
        }
        if (maxCreationPendingGlobal > 0) {
            nt.maxCreationPendingGlobal = maxCreationPendingGlobal;
        }
        if (maxCreationPendingUser > 0) {
            nt.maxCreationPendingUser = maxCreationPendingUser;
        }
    }

	function createNodeWithTokens(string memory nodeTypeName, uint256 count) public {
		require(openCreate, "Node creation not authorized yet");
		require(_doesNodeTypeExist(nodeTypeName), "nodeTypeName does not exist");
		address sender = msg.sender;
		require(
            sender != futurUsePool && sender != distributionPool,
            "futur and rewardsPool cannot create node"
        );
		uint256 nodePrice = _nodeTypes.get(nodeTypeName).nodePrice * count;
		require(
            IERC20(_trapezTokenAddress).balanceOf(sender) >= nodePrice,
            "Balance too low for creation."
        );
		IERC20(_trapezTokenAddress).transferFrom(sender, address(this), nodePrice);

		uint256 contractTokenBalance = IERC20(_trapezTokenAddress).balanceOf(address(this));
        bool swapAmountOk = contractTokenBalance >= swapTokensAmount;
        if (
            swapAmountOk &&
            swapLiquify &&
            !swapping
        ) {
            swapping = true;

            uint256 futurTokens = contractTokenBalance * futurFee / 100;

            swapAndSendToFee(futurUsePool, futurTokens);

            uint256 rewardsPoolTokens = contractTokenBalance * rewardsFee / 100;

            IERC20(_trapezTokenAddress).transfer(
                distributionPool,
                rewardsPoolTokens
            );

            uint256 swapTokens = contractTokenBalance * liquidityPoolFee / 100;

            swapAndLiquify(swapTokens);

            swapTokensForEth(IERC20(_trapezTokenAddress).balanceOf(address(this)));

            swapping = false;
        }

		_createNodes(sender, nodeTypeName, count);
	}

	function createNodeWithPending(string memory nodeTypeName, uint256 count) public {
		require(openCreate, "Node creation not authorized yet");
		require(openPending, "Buy node with pending reward not authorized yet");
		require(_doesNodeTypeExist(nodeTypeName), "nodeTypeName does not exist");
		address sender = msg.sender;
		require(
            sender != futurUsePool && sender != distributionPool,
            "futur and rewardsPool cannot create node"
        );
		
		IterableNodeTypeMapping.NodeType storage ntarget = _nodeTypes.get(nodeTypeName);

		require(ntarget.maxCreationPendingGlobal >= count, 
				"Global limit reached");
		ntarget.maxCreationPendingGlobal -= count;
		_nodeTypeOwnerCreatedPending[nodeTypeName][msg.sender] += count;
		require(_nodeTypeOwnerCreatedPending[nodeTypeName][msg.sender] <= ntarget.maxCreationPendingUser, 
				"Creation with pending limit reached for user");
		
		uint256 nodePrice = ntarget.nodePrice * count;
		IterableNodeTypeMapping.NodeType memory nt;
		uint256 rewardAmount;
		
		for (uint256 i=0; i < _nodeTypes.size() && nodePrice > 0; i++) {
			nt = _nodeTypes.getValueAtIndex(i);
			NodeEntity[] storage nes = _nodeTypeOwner[nt.nodeTypeName][sender];
			for (uint256 j=0; j < nes.length && nodePrice > 0; j++) {
				rewardAmount = _calculateNodeReward(nes[j]);
				if (nodePrice >= rewardAmount) {
					nes[j].lastClaimTime = block.timestamp;
					nodePrice -= rewardAmount;
				} else {
					nes[j].lastClaimTime = block.timestamp - rewardAmount * nt.claimTime / nt.rewardAmount;
					nodePrice = 0;
				}
			}
		}
		require(nodePrice == 0, "Insufficient Pending");

		_createNodes(sender, nodeTypeName, count);
	}

	function _createNodes(address account, string memory nodeTypeName, uint256 count)
        private
    {
        require(_doesNodeTypeExist(nodeTypeName), "_createNodes: nodeTypeName does not exist");
        require(count > 0, "_createNodes: count cannot be less than 1.");

		IterableNodeTypeMapping.NodeType storage nt;

		nt = _nodeTypes.get(nodeTypeName);
		nt.count += count;
		require(nt.count <= nt.max, "Max already reached");

        for (uint256 i = 0; i < count; i++) {
			_nodeTypeOwner[nodeTypeName][account].push(
                NodeEntity({
                    nodeTypeName: nodeTypeName,
                    creationTime: block.timestamp,   
                    lastClaimTime: block.timestamp
                })
			);
        }
    }

	function cashoutAll() public {
		address sender = msg.sender;

		IterableNodeTypeMapping.NodeType memory nt;
		uint256 rewardAmount = 0;
		
		for (uint256 i=0; i < _nodeTypes.size(); i++) {
			nt = _nodeTypes.getValueAtIndex(i);
			NodeEntity[] storage nes = _nodeTypeOwner[nt.nodeTypeName][sender];
			for (uint256 j=0; j < nes.length; j++) {
				rewardAmount += _calculateNodeReward(nes[j]);
				nes[j].lastClaimTime = block.timestamp;
			}
		}
		
		require(rewardAmount > 0, "Nothing to claim");

		IERC20(_trapezTokenAddress).transferFrom(distributionPool, address(this), rewardAmount);

		if (swapLiquify) {
			uint256 feeAmount;
            if (cashoutFee > 0) {
                feeAmount = rewardAmount * cashoutFee / 100;
                swapTokensForEth(feeAmount);
            }
            rewardAmount -= feeAmount;
		}

		IERC20(_trapezTokenAddress).transfer(sender, rewardAmount);
	}

	function calculateAllClaimableRewards(address user) public view returns (uint256) {
		IterableNodeTypeMapping.NodeType memory nt;
		uint256 rewardAmount = 0;
		
		for (uint256 i=0; i < _nodeTypes.size(); i++) {
			nt = _nodeTypes.getValueAtIndex(i);
			NodeEntity[] storage nes = _nodeTypeOwner[nt.nodeTypeName][user];
			for (uint256 j=0; j < nes.length; j++) {
				rewardAmount += _calculateNodeReward(nes[j]);
			}
		}
		return rewardAmount;
	}

	function _calculateNodeReward(NodeEntity memory node) private view returns(uint256) {
		IterableNodeTypeMapping.NodeType memory nt = _nodeTypes.get(node.nodeTypeName);

		uint256 rewards;
		if (block.timestamp - node.lastClaimTime < nt.claimTime) {
			rewards =  nt.rewardAmount * (block.timestamp - node.lastClaimTime) * (100 - nt.claimTaxBeforeTime) / (nt.claimTime * 100);
		} else {
			rewards = nt.rewardAmount * (block.timestamp - node.lastClaimTime) / nt.claimTime;
		}
		if (nt.rewardAmount * (block.timestamp - node.creationTime) / nt.claimTime < nt.nodePrice) {
			rewards = rewards * (100 - nt.earlyClaimTax) / 100;
		}
		return rewards;
	}

	function levelUp(string[] memory nodeTypeNames, string memory target) public {
		require(openLevelUp, "Node level up not authorized yet");
		require(_doesNodeTypeExist(target), "target doesnt exist");
		IterableNodeTypeMapping.NodeType storage ntarget = _nodeTypes.get(target);

		require(ntarget.maxLevelUpGlobal >= 1, "No one can level up this type of node");
		ntarget.maxLevelUpGlobal -= 1;
		_nodeTypeOwnerLevelUp[target][msg.sender] += 1;
		require(_nodeTypeOwnerLevelUp[target][msg.sender] <= ntarget.maxLevelUpUser, 
				"Level up limit reached for user");

		uint256 targetPrice = ntarget.nodePrice;
		uint256 updatedPrice = targetPrice;
		for (uint256 i = 0; i < nodeTypeNames.length && updatedPrice > 0; i++) {

			string memory name = nodeTypeNames[i];
			require(_doesNodeTypeExist(name), "name doesnt exist");
			require(_nodeTypeOwner[name][msg.sender].length > 0, "Not owned");
			
			IterableNodeTypeMapping.NodeType storage nt;
			nt = _nodeTypes.get(name);

			require(targetPrice > nt.nodePrice, "Cannot level down");

			_nodeTypeOwner[name][msg.sender].pop();
			nt.count -= 1;

			if (nt.nodePrice > updatedPrice) {
				updatedPrice = 0;
			} else {
				updatedPrice -= nt.nodePrice;
			}
		}
		require(updatedPrice == 0, "Not enough sent");
		_createNodes(msg.sender, target, 1);
	}


	// getters
	function getTotalCreatedNodes() public view returns(uint256) {
		uint256 total = 0;
		for (uint256 i=0; i < _nodeTypes.size(); i++) {
			total += _nodeTypes.getValueAtIndex(i).count;
		}
		return total;
	}

	function getTotalCreatedNodesOf(address who) public view returns(uint256) {
		uint256 total = 0;
		for (uint256 i=0; i < getNodeTypesSize(); i++) {
			string memory name = _nodeTypes.getValueAtIndex(i).nodeTypeName;
			total += getNodeTypeOwnerNumber(name, who);
		}
		return total;
	}
	
	function getNodeTypesSize() public view returns(uint256) {
		return _nodeTypes.size();
	}
	
	function getNodeTypeNameAtIndex(uint256 i) public view returns(string memory) {
        return _nodeTypes.getValueAtIndex(i).nodeTypeName;
	}
	
	function getNodeTypeOwnerNumber(string memory nodeTypeName, address _owner) 
			public view returns(uint256) {
		if (!_doesNodeTypeExist(nodeTypeName)) {
			return 0;
		}
		return _nodeTypeOwner[nodeTypeName][_owner].length;
	}

	function getNodeTypeLevelUp(string memory nodeTypeName, address _owner) 
			public view returns(uint256) {
		if (!_doesNodeTypeExist(nodeTypeName)) {
			return 0;
		}
		return _nodeTypeOwnerLevelUp[nodeTypeName][_owner];
	}

	function getNodeTypeOwnerCreatedPending(string memory nodeTypeName, address _owner) 
			public view returns(uint256) {
		if (!_doesNodeTypeExist(nodeTypeName)) {
			return 0;
		}
		return _nodeTypeOwnerCreatedPending[nodeTypeName][_owner];
	}

	function getNodeTypeNameData(string memory nodeTypeName, uint256 i) public view returns (uint256) {
		if (!_doesNodeTypeExist(nodeTypeName)) {
			return 0;
		}
		if (i == 0) {
			return _nodeTypes.get(nodeTypeName).nodePrice;
		} else if (i == 1) {
			return _nodeTypes.get(nodeTypeName).claimTime;
		} else if (i == 2) {
			return _nodeTypes.get(nodeTypeName).rewardAmount;
		} else if (i == 3) {
			return _nodeTypes.get(nodeTypeName).claimTaxBeforeTime;
		} else if (i == 4) {
			return _nodeTypes.get(nodeTypeName).count;
		} else if (i == 5) {
			return _nodeTypes.get(nodeTypeName).max;
		} else if (i == 6) {
			return _nodeTypes.get(nodeTypeName).earlyClaimTax;
		} else if (i == 7) {
			return _nodeTypes.get(nodeTypeName).maxLevelUpGlobal;
		} else if (i == 8) {
			return _nodeTypes.get(nodeTypeName).maxLevelUpUser;
		} else if (i == 9) {
			return _nodeTypes.get(nodeTypeName).maxCreationPendingGlobal;
		} else if (i == 10) {
			return _nodeTypes.get(nodeTypeName).maxCreationPendingUser;
		}
		return 0;
	}

	function getNodeTypeAll(string memory nodeTypeName) public view returns(uint256[] memory) {
		require(_doesNodeTypeExist(nodeTypeName), "Name doesnt exist");
		uint256[] memory all = new uint256[](11);
		IterableNodeTypeMapping.NodeType memory nt;
		nt = _nodeTypes.get(nodeTypeName);
		all[0] = nt.nodePrice;
		all[1] = nt.claimTime;
		all[2] = nt.rewardAmount;
		all[3] = nt.claimTaxBeforeTime;
		all[4] = nt.count;
		all[5] = nt.max;
		all[6] = nt.earlyClaimTax;
		all[7] = nt.maxLevelUpGlobal;
		all[8] = nt.maxLevelUpUser;
		all[9] = nt.maxCreationPendingGlobal;
		all[10] = nt.maxCreationPendingUser;
		return all;
	}

	function getNodeTypesAllAt(uint256 start, uint256 end) public view returns(uint256[][] memory) {
		uint256[][] memory all = new uint256[][](end - start);
		for (uint256 i = start; i < end; i++) {
			all[i - start] = getNodeTypeAll(_nodeTypes.getValueAtIndex(i).nodeTypeName); 
		}
		return all;
	}

	// Helpers
	function _doesNodeTypeExist(string memory nodeTypeName) private view returns (bool) {
        return _nodeTypes.getIndexOfKey(nodeTypeName) >= 0;
    }

	// Setters
	function setDefaultNodeTypeName(string memory nodeTypeName) public onlySentry {
		require(_doesNodeTypeExist(nodeTypeName), "NodeType doesn exist");
        _defaultNodeTypeName = nodeTypeName;
    }
	
	function setToken (address token) external onlySentry {
        _trapezTokenAddress = token;
    }


	function updateUniswapV2Router(address newAddress) public onlySentry {
        require(newAddress != address(_uniswapV2Router), "TKN: The router already has that address");
        _uniswapV2Router = IPancakeRouter02(newAddress);
    }

    function updateSwapTokensAmount(uint256 newVal) external onlySentry {
        swapTokensAmount = newVal;
    }

    function updateFuturWall(address payable wall) external onlySentry {
        futurUsePool = wall;
    }

    function updateRewardsWall(address payable wall) external onlySentry {
        distributionPool = wall;
    }

    function updateRewardsFee(uint256 value) external onlySentry {
        rewardsFee = value;
        totalFees = rewardsFee + liquidityPoolFee + futurFee;
    }

    function updateLiquiditFee(uint256 value) external onlySentry {
        liquidityPoolFee = value;
        totalFees = rewardsFee + liquidityPoolFee + futurFee;
    }

    function updateFuturFee(uint256 value) external onlySentry {
        futurFee = value;
        totalFees = rewardsFee + liquidityPoolFee + futurFee;
    }

    function updateCashoutFee(uint256 value) external onlySentry {
        cashoutFee = value;
    }
    
	function updateGateKeeper(address _new) external onlySentry {
        _gateKeeper = _new;
    }
	
	function updateOpenCreate(bool value) external onlySentry {
        openCreate = value;
    }

	function updateOpenPending(bool value) external onlySentry {
		openPending = value;
	}
	
	function updateOpenLevelUp(bool value) external onlySentry {
        openLevelUp = value;
    }

	// swaps
	function swapAndSendToFee(address destination, uint256 tokens) private {
        uint256 initialETHBalance = address(this).balance;
        swapTokensForEth(tokens);
        uint256 newBalance = (address(this).balance) - initialETHBalance;
		payable(destination).transfer(newBalance);
    }

    function swapAndLiquify(uint256 tokens) private {
        uint256 half = tokens / 2;
        uint256 otherHalf = tokens - half;

        uint256 initialBalance = address(this).balance;

        swapTokensForEth(half);

        uint256 newBalance = address(this).balance - initialBalance;

        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = _trapezTokenAddress;
        path[1] = _uniswapV2Router.WETH();

        IERC20(_trapezTokenAddress).approve(address(_uniswapV2Router), tokenAmount);

        _uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        IERC20(_trapezTokenAddress).approve(address(_uniswapV2Router), tokenAmount);

        _uniswapV2Router.addLiquidityETH{value: ethAmount}(
            _trapezTokenAddress,                  // token address
            tokenAmount,                    // amountTokenDesired
            0, // slippage is unavoidable   // amountTokenMin
            0, // slippage is unavoidable   // amountAVAXMin
            poolHandler,                    // to address
            block.timestamp                 // deadline
        );
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (finance/PaymentSplitter.sol)

pragma solidity ^0.8.0;

import "../libs/SafeERC20.sol";
import "../libs/Address.sol";
import "./Context.sol";

/**
 * @title PaymentSplitter
 * @dev This contract allows to split Ether payments among a group of accounts. The sender does not need to be aware
 * that the Ether will be split in this way, since it is handled transparently by the contract.
 *
 * The split can be in equal parts or in any other arbitrary proportion. The way this is specified is by assigning each
 * account to a number of shares. Of all the Ether that this contract receives, each account will then be able to claim
 * an amount proportional to the percentage of total shares they were assigned.
 *
 * `PaymentSplitter` follows a _pull payment_ model. This means that payments are not automatically forwarded to the
 * accounts but kept in this contract, and the actual transfer is triggered as a separate step by calling the {release}
 * function.
 *
 * NOTE: This contract assumes that ERC20 tokens will behave similarly to native tokens (Ether). Rebasing tokens, and
 * tokens that apply fees during transfers, are likely to not be supported as expected. If in doubt, we encourage you
 * to run tests before sending real value to this contract.
 */
contract PaymentSplitter is Context {
    event PayeeAdded(address account, uint256 shares);
    event PaymentReleased(address to, uint256 amount);
    event ERC20PaymentReleased(IERC20 indexed token, address to, uint256 amount);
    event PaymentReceived(address from, uint256 amount);

    uint256 private _totalShares;
    uint256 private _totalReleased;

    mapping(address => uint256) private _shares;
    mapping(address => uint256) private _released;
    address[] private _payees;

    mapping(IERC20 => uint256) private _erc20TotalReleased;
    mapping(IERC20 => mapping(address => uint256)) private _erc20Released;

    /**
     * @dev Creates an instance of `PaymentSplitter` where each account in `payees` is assigned the number of shares at
     * the matching position in the `shares` array.
     *
     * All addresses in `payees` must be non-zero. Both arrays must have the same non-zero length, and there must be no
     * duplicates in `payees`.
     */
    constructor(address[] memory payees, uint256[] memory shares_) payable {
        require(payees.length == shares_.length, "PaymentSplitter: payees and shares length mismatch");
        require(payees.length > 0, "PaymentSplitter: no payees");

        for (uint256 i = 0; i < payees.length; i++) {
            _addPayee(payees[i], shares_[i]);
        }
    }

    /**
     * @dev The Ether received will be logged with {PaymentReceived} events. Note that these events are not fully
     * reliable: it's possible for a contract to receive Ether without triggering this function. This only affects the
     * reliability of the events, and not the actual splitting of Ether.
     *
     * To learn more about this see the Solidity documentation for
     * https://solidity.readthedocs.io/en/latest/contracts.html#fallback-function[fallback
     * functions].
     */
    receive() external payable virtual {
        emit PaymentReceived(_msgSender(), msg.value);
    }

    /**
     * @dev Getter for the total shares held by payees.
     */
    function totalShares() public view returns (uint256) {
        return _totalShares;
    }

    /**
     * @dev Getter for the total amount of Ether already released.
     */
    function totalReleased() public view returns (uint256) {
        return _totalReleased;
    }

    /**
     * @dev Getter for the total amount of `token` already released. `token` should be the address of an IERC20
     * contract.
     */
    function totalReleased(IERC20 token) public view returns (uint256) {
        return _erc20TotalReleased[token];
    }

    /**
     * @dev Getter for the amount of shares held by an account.
     */
    function shares(address account) public view returns (uint256) {
        return _shares[account];
    }

    /**
     * @dev Getter for the amount of Ether already released to a payee.
     */
    function released(address account) public view returns (uint256) {
        return _released[account];
    }

    /**
     * @dev Getter for the amount of `token` tokens already released to a payee. `token` should be the address of an
     * IERC20 contract.
     */
    function released(IERC20 token, address account) public view returns (uint256) {
        return _erc20Released[token][account];
    }

    /**
     * @dev Getter for the address of the payee number `index`.
     */
    function payee(uint256 index) public view returns (address) {
        return _payees[index];
    }

    /**
     * @dev Triggers a transfer to `account` of the amount of Ether they are owed, according to their percentage of the
     * total shares and their previous withdrawals.
     */
    function release(address payable account) public virtual {
        require(_shares[account] > 0, "PaymentSplitter: account has no shares");

        uint256 totalReceived = address(this).balance + totalReleased();
        uint256 payment = _pendingPayment(account, totalReceived, released(account));

        require(payment != 0, "PaymentSplitter: account is not due payment");

        _released[account] += payment;
        _totalReleased += payment;

        Address.sendValue(account, payment);
        emit PaymentReleased(account, payment);
    }

    /**
     * @dev Triggers a transfer to `account` of the amount of `token` tokens they are owed, according to their
     * percentage of the total shares and their previous withdrawals. `token` must be the address of an IERC20
     * contract.
     */
    function release(IERC20 token, address account) public virtual {
        require(_shares[account] > 0, "PaymentSplitter: account has no shares");

        uint256 totalReceived = token.balanceOf(address(this)) + totalReleased(token);
        uint256 payment = _pendingPayment(account, totalReceived, released(token, account));

        require(payment != 0, "PaymentSplitter: account is not due payment");

        _erc20Released[token][account] += payment;
        _erc20TotalReleased[token] += payment;

        SafeERC20.safeTransfer(token, account, payment);
        emit ERC20PaymentReleased(token, account, payment);
    }

    /**
     * @dev internal logic for computing the pending payment of an `account` given the token historical balances and
     * already released amounts.
     */
    function _pendingPayment(
        address account,
        uint256 totalReceived,
        uint256 alreadyReleased
    ) private view returns (uint256) {
        return (totalReceived * _shares[account]) / _totalShares - alreadyReleased;
    }

    /**
     * @dev Add a new payee to the contract.
     * @param account The address of the payee to add.
     * @param shares_ The number of shares owned by the payee.
     */
    function _addPayee(address account, uint256 shares_) private {
        require(account != address(0), "PaymentSplitter: account is the zero address");
        require(shares_ > 0, "PaymentSplitter: shares are 0");
        require(_shares[account] == 0, "PaymentSplitter: account already has shares");

        _payees.push(account);
        _shares[account] = shares_;
        _totalShares = _totalShares + shares_;
        emit PayeeAdded(account, shares_);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;

library IterableNodeTypeMapping {
    //# types of node tiers
    //# each node type's properties are different
    struct NodeType {
        string nodeTypeName;
        uint256 nodePrice;          //# cost to buy a node
        uint256 claimTime;          //# length of an epoch
        uint256 rewardAmount;       //# reward per an epoch
        uint256 claimTaxBeforeTime; //# claim tax before claimTime is passed
		uint256 count; // created Node Count
		uint256 max; // max nodes
		uint256 earlyClaimTax; // before roi tax
		uint256 maxLevelUpGlobal; // max remaining levelup to get this node for everyone
		uint256 maxLevelUpUser; // max authorized levelUp per user for this node
		uint256 maxCreationPendingGlobal; // max remaining creation with pending for everyone
		uint256 maxCreationPendingUser; // max authorized creation with pending for a user
    }

    // Iterable mapping from string to NodeType;
    struct Map {
        string[] keys;
        mapping(string => NodeType) values;
        mapping(string => uint256) indexOf;
        mapping(string => bool) inserted;
    }

    function get(Map storage map, string memory key) public view returns (NodeType storage) {
        return map.values[key];
    }

    function getIndexOfKey(Map storage map, string memory key)
    public
    view
    returns (int256)
    {
        if (!map.inserted[key]) {
            return -1;
        }
        return int256(map.indexOf[key]);
    }

    function getKeyAtIndex(Map storage map, uint256 index)
    public
    view
    returns (string memory)
    {
        return map.keys[index];
    }

    function getValueAtIndex(Map storage map, uint256 index)
    public
    view
    returns (NodeType memory)
    {
        return map.values[map.keys[index]];
    }

    function size(Map storage map) public view returns (uint256) {
        return map.keys.length;
    }

    function set(
        Map storage map,
        string memory key,
        NodeType memory value
    ) public {
        if (map.inserted[key]) {
            map.values[key] = value;
        } else {
            map.inserted[key] = true;
            map.values[key] = value;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, string memory key) public {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];
        delete map.values[key];

        uint256 index = map.indexOf[key];
        uint256 lastIndex = map.keys.length - 1;
        string memory lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
    }
}

pragma solidity ^0.8.0;

import "./IPancakeRouter01.sol";


interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../interfaces/IERC20.sol";
import "./Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

pragma solidity ^0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data)
    internal
    returns (bytes memory)
    {
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
        return
        functionCallWithValue(
            target,
            data,
            value,
            "Address: low-level call with value failed"
        );
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
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
    internal
    view
    returns (bytes memory)
    {
        return
        functionStaticCall(
            target,
            data,
            "Address: low-level static call failed"
        );
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
    function functionDelegateCall(address target, bytes memory data)
    internal
    returns (bytes memory)
    {
        return
        functionDelegateCall(
            target,
            data,
            "Address: low-level delegate call failed"
        );
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

pragma solidity ^0.8.0;


interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}