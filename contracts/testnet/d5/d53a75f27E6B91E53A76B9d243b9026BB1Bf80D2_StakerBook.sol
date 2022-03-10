// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ICeresFactory {
    
    struct TokenInfo {
        address tokenAddress;
        uint256 tokenType; // 1: asc, 2: crs, 3: col, 4: vol;
        address stakingAddress;
        address oracleAddress;
        bool isStakingRewards;
        bool isStakingMineable;
    }

    // Views
    function getBank() external view returns (address);
    function getReward() external view returns (address);
    function getTokenInfo(address _token) external returns(TokenInfo memory);
    function getStaking(address _token) external view returns (address);
    function getOracle(address _token) external view returns (address);
    function isValidStaking(address sender) external view returns (bool);
    function volTokens(uint256 _index) external view returns (address);

    function getTokens() external view returns (address[] memory);
    function getTokensLength() external view returns (uint256);
    function getVolTokensLength() external view returns (uint256);
    function getValidStakings() external view returns (address[] memory);
    function getTokenPrice(address _token) external view returns(uint256);
    function isStakingRewards(address _staking) external view returns (bool);
    function isStakingMineable(address _staking) external view returns (bool);

    // Mutative
    function setBank(address _newAddress) external;
    function setReward(address _newReward) external;
    function setCreator(address _creator) external;
    function setTokenType(address _token, uint256 _type) external;
    function setStaking(address _token, address _staking) external;
    function setOracle(address _token, address _oracle) external;
    function setIsStakingRewards(address _token, bool _isStakingRewards) external;
    function setIsStakingMineable(address _token, bool _isStakingMineable) external;
    function updateOracles(address[] memory _tokens) external;
    function updateOracle(address _token) external;

    /* public func */
    function createStaking(address _token, bool _createOracle) external returns (address staking, address oracle);
    function createStakingWithLiquidity(address _token, uint256 _tokenAmount, uint256 _quoteAmount, bool _createOracle) external returns (address staking, address oracle);
    function createOracle(address _token) external returns (address);
    function addStaking(address _token, uint256 _tokenType, address _staking, address _oracle, bool _isStakingRewards, bool _isStakingMineable) external;
    function removeStaking(address _token, address _staking) external;

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IStakerBook {
    
    function stake(address staker) external;

    function refer(address staker, address referer) external;
    
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../../interface/ICeresFactory.sol";
import "../../interface/IStakerBook.sol";

contract StakerBook is IStakerBook {

    // staker -> staked
    mapping(address => bool) public staked;
    // stakers
    address[] public stakers;
    // staker -> referer
    mapping(address => address) public referers;
    
    ICeresFactory public factory;

    modifier onlyStakings() {
        require(factory.isValidStaking(msg.sender) == true, "Only Staking!");
        _;
    }

    constructor(address _factory){
        factory = ICeresFactory(_factory);
    }
    
    function stake(address staker) external override onlyStakings {
        if (!staked[staker]) {
            // staked
            staked[staker] = true;
            stakers.push(staker);
        }
    }

    function refer(address staker, address referer) external override onlyStakings {
        if (!staked[staker]) {
            // staked
            staked[staker] = true;
            stakers.push(staker);
            if (referer != address(0))
                referers[staker] = referer;
        }
    }

    function getStakersLength() external view returns (uint256){
        return stakers.length;
    }

    function getStakers() external view returns (address[] memory){
        return stakers;
    }

    function getStakersLimit(uint256 start, uint256 end) external view returns (address[] memory values){
        uint256 _length = stakers.length;
        end = end > _length ? _length : end;
        values = new address[](end - start);

        uint256 index = 0;
        for (uint256 i = start; i < end; i++) {
            values[index] = stakers[i];
            index++;
        }
    }

}