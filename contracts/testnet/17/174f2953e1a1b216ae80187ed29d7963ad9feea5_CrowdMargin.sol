/**
 *Submitted for verification at BscScan.com on 2022-11-09
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


contract CrowdMargin {
    token public DAI = token(0xCE77d2a7a42fD230dDa717988df6820572f6F05e);

    address public owner;
    address public a1;
    address public a2;
    address public a3;
    address public stakingFunder;
    DAIGON public daigon;

    PoolInfo[] public poolInfos;
    mapping(uint32 => Blob[]) public poolBlobs;
    mapping(uint32 => mapping(uint32 => bool)) isPoolBlobClaimed;

    mapping(uint32 => uint32[]) public vacantBlobs;
    mapping(uint32 => uint32) public vacantBlobIndex;

    mapping(uint32 => mapping(uint32 => uint32[])) public vacantBlobByBlob;
    mapping(uint32 => mapping(uint32 => uint32)) public vacantBlobIndexByBlob;

    mapping(address => uint32[]) public userData;
    mapping(address => uint32) public lastDownlineCount;

    mapping(address => uint128) public totalIncome;

    uint32 public minimumDownline = 2;
    uint32 public repeatMinimum = 0;

    struct Blob {
    	address owner;
    	uint32 up;
    	uint32 left;
    	uint32 right;
    }

    struct PoolInfo {
    	uint128 amount;
    	uint32 nextPool;
    	uint96 penaltyAmount;
    }

    constructor(address _daigon,address _stakingFunder, address _a1, address _a2, address _a3) {
    	daigon = DAIGON(_daigon);
    	stakingFunder = _stakingFunder;
    	a1 = _a1;
    	a2 = _a2;
    	a3 = _a3;
    	owner = msg.sender;

    	createPool(100 ether, 1, 0);
    	createPool(200 ether, 2, 0);
    	createPool(400 ether, 3, 0);
    	createPool(800 ether, 0, 1000 ether);

    	addToPool(address(this), 0, 0);
    	addToPool(address(this), 0, 0);
    	addToPool(address(this), 0, 0);
    }

    function claimBlobAuto(uint32 poolNumber, uint32 blobNumber) internal {
    	PoolInfo memory poolInfo = poolInfos[poolNumber];
    	Blob memory blob = poolBlobs[poolNumber][blobNumber];

		PoolInfo memory nextPool = poolInfos[poolInfo.nextPool];

		DAI.transfer(stakingFunder, poolInfo.amount);
		uint256 transferAmount = poolInfo.amount * 3;
		transferAmount -= nextPool.amount;

		if(blob.owner == address(this)) {
			DAI.transfer(a1, transferAmount / 3);
			DAI.transfer(a2, transferAmount / 3);
			DAI.transfer(a3, transferAmount / 3);
		}
		else {
			if(poolInfo.penaltyAmount > 0) {
	        	(,,,,,uint32 downlines_0,,,,,) = daigon.users(blob.owner);
	        	uint32 newDownlines = downlines_0 - lastDownlineCount[blob.owner];
	        	if(downlines_0 < minimumDownline || newDownlines < repeatMinimum) {
	        		uint256 penaltyBlobsCount = poolInfo.penaltyAmount / nextPool.amount;
	        		for(uint256 i = 0; i < penaltyBlobsCount; ++i) {
	        			transferAmount -= nextPool.amount;
						addToPool(address(this), poolInfo.nextPool, 0);
	        		}
	        	}
	        	lastDownlineCount[blob.owner] = downlines_0;
			}
			DAI.transfer(blob.owner, transferAmount);
		}
		emit Claimed(blob.owner, transferAmount);

		totalIncome[blob.owner] += uint128(transferAmount);

		isPoolBlobClaimed[poolNumber][blobNumber] = true;

		if(poolInfo.nextPool != 0) {
			addToPool(blob.owner, poolInfo.nextPool, 0);
		}
		else {
			addToPool(address(this), poolInfo.nextPool, 0);
		}
    }

    function addToPool(address addr, uint32 poolNumber, uint32 origBlobNumber) internal {

		uint32 blobNumber = origBlobNumber;

		if(origBlobNumber != 0) {
			Blob memory currentBlob = poolBlobs[poolNumber][origBlobNumber];
			require(currentBlob.owner != address(0), "Invalid Group Number");
			if(currentBlob.left != 0 && currentBlob.right != 0) {
				uint32 vacantIndex = vacantBlobIndexByBlob[poolNumber][origBlobNumber];
				uint256 length = vacantBlobByBlob[poolNumber][origBlobNumber].length;
				for(uint256 i = vacantIndex; i < length; ++i) {
					blobNumber = vacantBlobByBlob[poolNumber][origBlobNumber][i];
					currentBlob = poolBlobs[poolNumber][blobNumber];
					if(currentBlob.left == 0 || currentBlob.right == 0) {
						if(i != vacantIndex) vacantBlobIndexByBlob[poolNumber][origBlobNumber] = uint32(i);
						break;
					}
				}
			}
		}
		else if(vacantBlobs[poolNumber].length > 0) {
			uint32 vacantIndex = vacantBlobIndex[poolNumber];
			uint256 length = vacantBlobs[poolNumber].length;
			Blob memory currentBlob;
			for(uint256 i = vacantIndex; i < length; ++i) {
				blobNumber = vacantBlobs[poolNumber][i];
				currentBlob = poolBlobs[poolNumber][blobNumber];
				if(currentBlob.left == 0 || currentBlob.right == 0) {
					if(i != vacantIndex) vacantBlobIndex[poolNumber] = uint32(i);
					break;
				}
			}
		}

		poolBlobs[poolNumber].push(Blob(addr, blobNumber, 0, 0));
        uint32 blobId = uint32(poolBlobs[poolNumber].length) - 1;
		vacantBlobs[poolNumber].push(blobId);
		if(origBlobNumber != 0) {
			 vacantBlobByBlob[poolNumber][origBlobNumber].push(blobId);
		}

		userData[addr].push(poolNumber);
		userData[addr].push(blobId);

		if(blobNumber != 0) {
			Blob storage upBlob = poolBlobs[poolNumber][blobNumber];

			emit DirectFill(addr, upBlob.owner, origBlobNumber);

			uint32 upupIndex = upBlob.up;
			Blob memory upupBlob = poolBlobs[poolNumber][upupIndex];

			if(upBlob.left == 0) {
				upBlob.left = blobId;

				if(upupIndex != 0) {
					emit SecondFill(addr, upupBlob.owner, origBlobNumber);
				}
			}
			else if(upBlob.right == 0) {
				upBlob.right = blobId;

				if(upupIndex != 0) {
					emit SecondFill(addr, upupBlob.owner, origBlobNumber);

					if(upupBlob.right == blobNumber) {
						claimBlobAuto(poolNumber, upupIndex);
					}
				}
			}
		}
    }

    function joinPool(uint32 poolNumber, uint32 origBlobNumber) public {
    	PoolInfo memory poolInfo = poolInfos[poolNumber];
    	require(poolInfo.amount > 0, "Invalid Pool.");

    	(address referrer,,,,,,,,,,) = daigon.users(msg.sender);
    	require(referrer != address(0), "You need to stake atleast once to join");

		DAI.transferFrom(msg.sender, address(this), poolInfo.amount);

		addToPool(msg.sender, poolNumber, origBlobNumber);
    }

    function getUserInfo(address addr) external view returns (uint128, uint32, uint32, uint32) {
    	return (totalIncome[addr], lastDownlineCount[addr], minimumDownline, repeatMinimum);
    }

    function getUserData(address addr) external view returns (uint32[] memory, uint32[] memory, bool[] memory) {
		uint256 length = userData[addr].length;
		uint32[] memory poolNumber = new uint32[](length / 2);
		uint32[] memory blobNumber = new uint32[](length / 2);
		bool[] memory isClaimed = new bool[](length / 2);

		for(uint256 i = 0; i < length; i+=2) {
			poolNumber[i / 2] = userData[addr][i];
			blobNumber[i / 2] = userData[addr][i + 1];
			isClaimed[i] = isPoolBlobClaimed[userData[addr][i]][userData[addr][i + 1]];
		}

		return (poolNumber, blobNumber, isClaimed);
    }

    function getPoolInfos() external view returns(uint128[] memory, uint96[] memory) {
		uint256 length = poolInfos.length;
		uint128[] memory amount = new uint128[](length);
		uint96[] memory penaltyAmount = new uint96[](length);

		for(uint256 i = 0; i < length; ++i) {
			amount[i] = poolInfos[i].amount;
			penaltyAmount[i] = poolInfos[i].penaltyAmount;
		}
		return (amount, penaltyAmount);
    }

    function createPool(uint128 amount, uint32 nextPool, uint96 penaltyAmount) public onlyOwner {
    	poolInfos.push(PoolInfo(amount, nextPool, penaltyAmount));
    	poolBlobs[uint32(poolInfos.length) - 1].push(Blob(address(0), 0, 0, 0));
    }

    function editPool(uint32 poolNumber, uint128 amount, uint32 nextPool, uint96 penaltyAmount) external onlyOwner {
    	poolInfos[poolNumber].amount = amount;
    	poolInfos[poolNumber].nextPool = nextPool;
    	poolInfos[poolNumber].penaltyAmount = penaltyAmount;
    }

	function changeAddress(uint256 n, address addr) external onlyOwner {
		if(n == 1) {
			a1 = addr;
		}
		else if(n == 2) {
			a2 = addr;
		}
		else if(n == 3) {
			a3 = addr;
		}
		else if(n == 4) {
			stakingFunder = addr;
		}
		else if(n == 5) {
			owner = addr;
		}
	}

	function changeValue(uint256 n, uint32 value) external onlyOwner {
		if(n == 1) {
			minimumDownline = value;
		}
		else if(n == 2) {
			repeatMinimum = value;
		}
	}

	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}

	event Claimed(address indexed user, uint256 amount);
	event DirectFill(address indexed user, address indexed upline, uint32 indexed groupNumber);
	event SecondFill(address indexed user, address indexed upline, uint32 indexed groupNumber);
}

interface DAIGON {
	function users(address) external view returns (address, uint32, uint32, uint128, uint96, uint32, uint96, uint32, uint96, uint32, uint96);
}

interface token {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}