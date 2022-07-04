/**
 * Staking for the NFT collection for the Birb game ecosystem.
 * Check out Birb, a fun currency for everyone!
 *
 * https://birb.com/
 * https://t.me/BirbDefi
 *
 *
 * NFTs and staking system powered by Hibiki.finance
 */

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./Auth.sol";
import "./IBEP20.sol";
import "./IERC721.sol";

interface IBirbRarity {
	function getIdRarity(uint256 index) external view returns (uint8 rarity);
}

contract BirbNftStaking is Auth {

    struct Stake {
        uint256 amount;
		uint256 nfts;
        uint256 totalExcluded;
        uint256 totalRealised;
		uint256 totalExcludedBnb;
        uint256 totalRealisedBnb;
    }

	address _birbNft;
	address _birbRarity;
    address public rewardToken;

    uint256 public totalRealised;
	uint256 public totalRealisedBnb;
    uint256 public totalStaked;

    mapping (address => Stake) public stakes;
	mapping (uint256 => address) public stakedBy;
	mapping (address => uint256[]) public stakedIds;
	mapping (uint256 => uint8) stakedIdToStakedPoints;

	uint256 _accuracyFactor = 10 ** 18;
    uint256 _rewardsPerScore;
	uint256 _rewardsPerScoreBnb;
    uint256 _lastContractBalance;
	uint256 _lastContractBalanceBnb;

	uint256 sendBnbRewardGas = 34000;

	event Realised(address account, uint256 amount, uint256 amountBnb);
    event Staked(address account, uint256 id, uint256 value);
    event Unstaked(address account, uint256 id, uint256 value);

    constructor(address cs, address stats, address _rewardToken) Auth(msg.sender) {
		_birbNft = cs;
		_birbRarity = stats;
        rewardToken = _rewardToken;
    }

	function setBirbNft(address addy) external authorized {
		_birbNft = addy;
	}

	function setStats(address addy) external authorized {
		_birbRarity = addy;
	}

	function setRewardToken(address addy) external authorized {
		rewardToken = addy;
	}

	function setGas(uint256 gas) external authorized {
		sendBnbRewardGas = gas;
	}

    function getTotalRewards() external view returns (uint256) {
        return totalRealised + IBEP20(rewardToken).balanceOf(address(this));
    }

	function getTotalRewardsBnb() external view returns (uint256) {
        return totalRealisedBnb + address(this).balance;
    }

    function getCumulativeRewardsPerToken() external view returns (uint256) {
        return _rewardsPerScore;
    }

	function getCumulativeRewardsPerTokenBNB() external view returns (uint256) {
        return _rewardsPerScoreBnb;
    }

    function getLastContractBalance() external view returns (uint256) {
        return _lastContractBalance;
    }

	function getLastContractBalanceBnb() external view returns (uint256) {
        return _lastContractBalanceBnb;
    }

    function getAccuracyFactor() external view returns (uint256) {
        return _accuracyFactor;
    }

    function getStake(address account) public view returns (uint256) {
        return stakes[account].amount;
    }

	function getStakedNftCount(address account) public view returns (uint256) {
        return stakes[account].nfts;
    }

    function getRealisedEarnings(address staker) external view returns (uint256) {
        return stakes[staker].totalRealised;
    }

	function getRealisedEarningsBnb(address staker) external view returns (uint256) {
        return stakes[staker].totalRealisedBnb;
    }

    function getUnrealisedEarnings(address staker) external view returns (uint256) {
        if (stakes[staker].amount == 0) {
			return 0;
		}

        uint256 stakerTotalRewards = (stakes[staker].amount * getCurrentRewardsPerScore()) / _accuracyFactor;
        uint256 stakerTotalExcluded = stakes[staker].totalExcluded;

        if (stakerTotalRewards <= stakerTotalExcluded) {
			return 0;
		}

        return stakerTotalRewards - stakerTotalExcluded;
    }

	function getUnrealisedEarningsBnb(address staker) external view returns (uint256) {
        if (stakes[staker].amount == 0) {
			return 0;
		}

        uint256 stakerTotalRewards = (stakes[staker].amount * getCurrentRewardsPerScoreBnb()) / _accuracyFactor;
        uint256 stakerTotalExcluded = stakes[staker].totalExcludedBnb;

        if (stakerTotalRewards <= stakerTotalExcluded) {
			return 0;
		}

        return stakerTotalRewards - stakerTotalExcluded;
    }

    function getCumulativeRewards(uint256 amount) public view returns (uint256) {
        return amount * _rewardsPerScore / _accuracyFactor;
    }

	function getCumulativeRewardsBnb(uint256 amount) public view returns (uint256) {
        return amount * _rewardsPerScoreBnb / _accuracyFactor;
    }

    function stake(uint256 id) public {
        IERC721(_birbNft).safeTransferFrom(msg.sender, address(this), id);

        _stake(msg.sender, id);
    }

	function multiStake(uint256[] calldata ids) external {
		for (uint256 i = 0; i < ids.length; i++) {
			stake(ids[i]);
		}
	}

	function valuePerNft(uint256 nft) public view returns(uint8 value) {
		uint8 rarity;
		try IBirbRarity(_birbRarity).getIdRarity(nft) returns(uint8 rar) {
			rarity = rar;
		} catch {
			rarity = 0;
		}

		return birbStakeValue(rarity);
	}

	function birbStakeValue(uint8 rarity) public pure returns(uint8 value) {
		// Uncommon
		if (rarity == 1) {
			return 10;
		}
		// Rare
		if (rarity == 2) {
			return 25;
		}
		// Epic
		if (rarity == 3) {
			return 55;
		}
		// Legendary
		if (rarity == 4) {
			return 120;
		}

		// Common
		return 5;
	}

    function stakeFor(address staker, uint256 id) external {
        IBEP20(_birbNft).transferFrom(msg.sender, address(this), id);

        _stake(staker, id);
    }

    function unstake(uint id) external {
        require(stakedBy[id] == msg.sender);

        _unstake(msg.sender, id);
    }

    function unstakeAll(uint256[] calldata ids) external {
        for (uint256 i = 0; i < ids.length; i++) {
			_unstake(msg.sender, ids[i]);
		}
    }

    function realise() external {
        _realise(msg.sender);
    }

    function _realise(address staker) internal {
        _updateRewards();
		_updateRewardsBnb();

        uint256 amount = earnt(staker);
		uint256 amountBnb = earntBnb(staker);

        if (getStake(staker) == 0 || (amount == 0 && amountBnb == 0)) {
            return;
        }

		if (amount > 0) {
			stakes[staker].totalRealised += amount;
			stakes[staker].totalExcluded += amount;
			totalRealised += amount;
        	IBEP20(rewardToken).transfer(staker, amount);
		}
		if (amountBnb > 0) {
			stakes[staker].totalRealisedBnb += amountBnb;
			stakes[staker].totalExcludedBnb += amountBnb;
			totalRealisedBnb += amountBnb;
			(bool sent, bytes memory data) = staker.call{value: amountBnb, gas: sendBnbRewardGas}("");
			require(sent, "Failed to send BNB on realise");
		}

        _updateRewards();
		_updateRewardsBnb();

        emit Realised(staker, amount, amountBnb);
    }

    function earnt(address staker) internal view returns (uint256) {
        if (stakes[staker].amount == 0) {
			return 0;
		}

        uint256 stakerTotalRewards = getCumulativeRewards(stakes[staker].amount);
        uint256 stakerTotalExcluded = stakes[staker].totalExcluded;

        if (stakerTotalRewards <= stakerTotalExcluded) {
			return 0;
		}

        return stakerTotalRewards - stakerTotalExcluded;
    }

	function earntBnb(address staker) internal view returns (uint256) {
        if (stakes[staker].amount == 0) {
			return 0;
		}

        uint256 stakerTotalRewards = getCumulativeRewardsBnb(stakes[staker].amount);
        uint256 stakerTotalExcluded = stakes[staker].totalExcludedBnb;

        if (stakerTotalRewards <= stakerTotalExcluded) {
			return 0;
		}

        return stakerTotalRewards - stakerTotalExcluded;
    }

    function _stake(address staker, uint256 id) internal {
		stakedBy[id] = msg.sender;
		stakedIds[msg.sender].push(id);

        _realise(staker);

		uint8 amount = valuePerNft(id);
		stakedIdToStakedPoints[id] = amount;

        _addToStake(staker, amount);

		emit Staked(staker, id, amount);
    }

	function _addToStake(address staker, uint256 amount) internal {
		// add to current address' stake
        stakes[staker].amount += amount;
        stakes[staker].totalExcluded = getCumulativeRewards(stakes[staker].amount);
		stakes[staker].totalExcludedBnb = getCumulativeRewardsBnb(stakes[staker].amount);
        totalStaked += amount;
	}

    function _unstake(address staker, uint256 id) internal {
		// realise staking gains
        _realise(staker);

		uint256 amount = stakedIdToStakedPoints[id];
        _removeStake(staker, amount);
		_removeStakedNftFromList(id);
		emit Unstaked(staker, id, amount);

		IERC721(_birbNft).safeTransferFrom(address(this), msg.sender, id);
    }

	function _removeStakedNftFromList(uint256 id) internal {
		uint256[] memory arr = stakedIds[msg.sender];
		uint256 index = findArrayIndex(arr, id);
		if (index == arr.length - 1) {
			stakedIds[msg.sender].pop();
		} else {
			stakedIds[msg.sender][index] = stakedIds[msg.sender][stakedIds[msg.sender].length - 1];
			stakedIds[msg.sender].pop();
		}
	}

	function findArrayIndex(uint256[] memory arr, uint256 num) public pure returns(uint256) {
		for (uint256 i = 0; i < arr.length; i++) {
			if (arr[i] == num) {
				return i;
			}
		}

		// We return max as a way to indicate an error.
		return type(uint256).max;
	}

	function _removeStake(address staker, uint256 amount) internal {
        stakes[staker].amount -= amount;
        stakes[staker].totalExcluded = getCumulativeRewards(stakes[staker].amount);
        totalStaked -= amount;
	}

	function updateRewards() external {
		_updateRewards();
		_updateRewardsBnb();
	}

    function _updateRewards() internal  {
        uint tokenBalance = IBEP20(rewardToken).balanceOf(address(this));

		if (tokenBalance == _lastContractBalance) {
			return;
		}

        if (tokenBalance > _lastContractBalance && totalStaked != 0) {
            uint256 newRewards = tokenBalance - _lastContractBalance;
			if (newRewards > 0) {
				uint256 additionalAmountPerLP = newRewards * _accuracyFactor / totalStaked;
				_rewardsPerScore += additionalAmountPerLP;
			}
        }

        if (totalStaked > 0) {
			_lastContractBalance = tokenBalance;
		}
    }

	function _updateRewardsBnb() internal  {
        uint256 balance = address(this).balance;

		if (balance == _lastContractBalanceBnb) {
			return;
		}

        if (balance > _lastContractBalanceBnb && totalStaked != 0) {
            uint256 newRewards = balance - _lastContractBalanceBnb;
			if (newRewards > 0) {
				uint256 additionalAmountPerLP = newRewards * _accuracyFactor / totalStaked;
				_rewardsPerScoreBnb += additionalAmountPerLP;
			}
        }

        if (totalStaked > 0) {
			_lastContractBalanceBnb = balance;
		}
    }

    function getCurrentRewardsPerScore() public view returns (uint256 currentRewardsPerLP) {
        uint tokenBalance = IBEP20(rewardToken).balanceOf(address(this));
        if (tokenBalance > _lastContractBalance && totalStaked != 0) {
            uint256 newRewards = tokenBalance - _lastContractBalance;
            uint256 additionalAmountPerLP = newRewards * _accuracyFactor / totalStaked;
            currentRewardsPerLP = _rewardsPerScore + additionalAmountPerLP;
        } else {
			currentRewardsPerLP = _rewardsPerScore;
		}
    }

	function getCurrentRewardsPerScoreBnb() public view returns (uint256 currentRewardsPerLP) {
        uint256 balance = address(this).balance;
        if (balance > _lastContractBalanceBnb && totalStaked != 0) {
            uint256 newRewards = balance - _lastContractBalanceBnb;
            uint256 additionalAmountPerLP = newRewards * _accuracyFactor / totalStaked;
            currentRewardsPerLP = _rewardsPerScoreBnb + additionalAmountPerLP;
        } else {
			currentRewardsPerLP = _rewardsPerScoreBnb;
		}
    }

    function setAccuracyFactor(uint256 newFactor) external authorized {
        _rewardsPerScore = _rewardsPerScore * newFactor / _accuracyFactor;
        _accuracyFactor = newFactor;
    }

	function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) public pure returns (bytes4) {
        return 0x150b7a02;
    }

	function emergencyUnstake(uint256 id) external {
		require(stakedBy[id] == msg.sender);
		IERC721(_birbNft).safeTransferFrom(address(this), msg.sender, id);
	}

	function viewMyStakedIds() external view returns(uint256[] memory) {
		return stakedIds[msg.sender];
	}

	receive() external payable {}
	fallback() external payable {}
}