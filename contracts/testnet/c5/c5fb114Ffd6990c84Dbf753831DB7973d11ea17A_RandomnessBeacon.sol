// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.9;

contract RandomnessBeacon
{
	struct RandomInfo
	{
		uint256 futureBlock;
		uint256 randomValue;
	}

	uint256 public currentEpoch;
	mapping(uint256 => RandomInfo) public entries;

	constructor()
	{
		currentEpoch = 0;
		entries[currentEpoch] = RandomInfo({
			futureBlock: block.number + 5,
			randomValue: block.difficulty
		});
		emit Epoch(currentEpoch);
	}

	function checkRandom(uint256 _epoch) external view returns (bool _ready, uint256 _randomValue)
	{
		return (currentEpoch > _epoch, entries[_epoch].randomValue);
	}

	function resolveRandom(uint256 _epoch) external returns (uint256 _randomValue)
	{
		requestRandom();
		require(currentEpoch > _epoch, "unavailable");
		return entries[_epoch].randomValue;
	}

	function requestRandom() public returns (uint256 _epoch)
	{
		uint256 _futureBlock = entries[currentEpoch].futureBlock;
		if (_futureBlock >= block.number) {
			return currentEpoch;
		}
		if (block.number - 256 > _futureBlock - 5) {
			entries[currentEpoch] = RandomInfo({
				futureBlock: block.number + 5,
				randomValue: block.difficulty
			});
			return currentEpoch;
		}
		entries[currentEpoch].randomValue = uint256(keccak256(abi.encodePacked(
			entries[currentEpoch].randomValue,
			blockhash(_futureBlock),
			blockhash(_futureBlock - 1),
			blockhash(_futureBlock - 2),
			blockhash(_futureBlock - 3),
			blockhash(_futureBlock - 4),
			blockhash(_futureBlock - 5)
		)));
		currentEpoch++;
		entries[currentEpoch] = RandomInfo({
			futureBlock: block.number + 5,
			randomValue: block.difficulty
		});
		emit Epoch(currentEpoch);
		return currentEpoch;
	}

	event Epoch(uint256 indexed _epoch);
}