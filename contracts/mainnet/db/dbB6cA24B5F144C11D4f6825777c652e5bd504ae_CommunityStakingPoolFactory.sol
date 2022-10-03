// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.11;

// import "./interfaces/IHook.sol";
// import "./interfaces/ICommunityCoin.sol";

// import "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

// import "./interfaces/IERC20Dpl.sol";

// import "@openzeppelin/contracts-upgradeable/token/ERC777/IERC777RecipientUpgradeable.sol";
import "./interfaces/ICommunityStakingPoolErc20.sol";
import "./interfaces/ICommunityStakingPool.sol";
import "./interfaces/ICommunityStakingPoolFactory.sol";

import "@openzeppelin/contracts-upgradeable/proxy/ClonesUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./interfaces/IStructs.sol";

//------------------------------------------------------------------------------
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

import "./interfaces/ICommunityStakingPoolFactory.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC777/IERC777Upgradeable.sol";
import "./libs/SwapSettingsLib.sol";

//------------------------------------------------------------------------------

// import "hardhat/console.sol";

contract CommunityStakingPoolFactory is Initializable, ICommunityStakingPoolFactory, IStructs {
    using ClonesUpgradeable for address;

    uint64 internal constant FRACTION = 100000; // fractions are expressed as portions of this

    // vars will setup in method `initialize`
    address internal uniswapRouter;
    address internal uniswapRouterFactory;

    mapping(address => mapping(address => mapping(uint256 => address))) public override getInstance;

    mapping(address => mapping(uint256 => address)) public override getInstanceErc20;

    address public implementation;
    address public implementationErc20;

    address public creator;

    address[] private _instances;
    InstanceType[] private _instanceTypes;
    InstanceType internal typeProducedByFactory;
    mapping(address => uint256) private _instanceIndexes;
    mapping(address => address) private _instanceCreators;

    mapping(address => InstanceInfo) public _instanceInfos;

    function initialize(address impl, address implErc20) external initializer {
        // setup swap addresses
        (uniswapRouter, uniswapRouterFactory) = SwapSettingsLib.netWorkSettings();

        implementation = impl;
        implementationErc20 = implErc20;
        creator = msg.sender;

        typeProducedByFactory = InstanceType.NONE;
    }

    function instancesByIndex(uint256 index) external view returns (address instance_) {
        return _instances[index];
    }

    function instances() external view returns (address[] memory instances_) {
        return _instances;
    }

    /**
     * @dev view amount of created instances
     * @return amount amount instances
     * @custom:shortd view amount of created instances
     */
    function instancesCount() external view override returns (uint256 amount) {
        amount = _instances.length;
    }

    /**
     * @dev note that `duration` is 365 and `LOCKUP_INTERVAL` is 86400 (seconds) means that tokens locked up for an year
     * @notice view instance info by reserved/traded tokens and duration
     * @param reserveToken address of reserve token. like a WETH, USDT,USDC, etc.
     * @param tradedToken address of traded token. usual it intercoin investor token
     * @param duration duration represented in amount of `LOCKUP_INTERVAL`
     * @custom:shortd view instance info
     */
    function getInstanceInfo(
        address reserveToken,
        address tradedToken,
        uint64 duration
    ) public view returns (InstanceInfo memory) {
        address instance = getInstance[reserveToken][tradedToken][duration];
        return _instanceInfos[instance];
    }

    function getInstanceInfoByPoolAddress(address addr) external view returns (InstanceInfo memory) {
        return _instanceInfos[addr];
    }

    function getInstancesInfo() external view returns (InstanceInfo[] memory) {
        InstanceInfo[] memory ret = new InstanceInfo[](_instances.length);
        for (uint256 i = 0; i < _instances.length; i++) {
            ret[i] = _instanceInfos[_instances[i]];
        }
        return ret;
    }

    function produce(
        address reserveToken,
        address tradedToken,
        uint64 duration,
        uint64 bonusTokenFraction,
        IStructs.StructAddrUint256[] memory donations,
        uint64 lpFraction,
        address lpFractionBeneficiary,
        uint64 rewardsRateFraction,
        uint64 numerator,
        uint64 denominator
    ) external returns (address instance) {
        require(msg.sender == creator);

        _createInstanceValidate(
            reserveToken,
            tradedToken,
            duration,
            bonusTokenFraction,
            lpFraction,
            lpFractionBeneficiary
        );

        address instanceCreated = _createInstance(
            reserveToken,
            tradedToken,
            duration,
            bonusTokenFraction,
            lpFraction,
            lpFractionBeneficiary,
            rewardsRateFraction,
            numerator,
            denominator
        );

        require(instanceCreated != address(0), "CommunityCoin: INSTANCE_CREATION_FAILED");
        require(duration != 0, "cant be zero duration");

        // if (duration == 0) {
        //     IStakingTransferRules(instanceCreated).initialize(
        //         reserveToken,  tradedToken, reserveTokenClaimFraction, tradedTokenClaimFraction, lpClaimFraction
        //     );
        // } else {
        ICommunityStakingPool(instanceCreated).initialize(
            creator,
            reserveToken,
            tradedToken,
            donations,
            lpFraction,
            lpFractionBeneficiary,
            rewardsRateFraction
        );
        // }

        //Ownable(instanceCreated).transferOwnership(_msgSender());
        instance = instanceCreated;
    }

    function produceErc20(
        address tokenErc20,
        uint64 duration,
        uint64 bonusTokenFraction,
        IStructs.StructAddrUint256[] memory donations,
        uint64 lpFraction,
        address lpFractionBeneficiary,
        uint64 rewardsRateFraction,
        uint64 numerator,
        uint64 denominator
    ) external returns (address instance) {
        require(msg.sender == creator);

        _createInstanceErc20Validate(tokenErc20, duration, bonusTokenFraction, lpFraction, lpFractionBeneficiary);

        address instanceCreated = _createInstanceErc20(
            tokenErc20,
            duration,
            bonusTokenFraction,
            lpFraction,
            lpFractionBeneficiary,
            rewardsRateFraction,
            numerator,
            denominator
        );

        require(instanceCreated != address(0), "CommunityCoin: INSTANCE_CREATION_FAILED");
        require(duration != 0, "cant be zero duration");

        // if (duration == 0) {
        //     IStakingTransferRules(instanceCreated).initialize(
        //         reserveToken,  tradedToken, reserveTokenClaimFraction, tradedTokenClaimFraction, lpClaimFraction
        //     );
        // } else {
        ICommunityStakingPoolErc20(instanceCreated).initialize(
            creator,
            tokenErc20,
            donations,
            lpFraction,
            lpFractionBeneficiary,
            rewardsRateFraction
        );
        // }

        //Ownable(instanceCreated).transferOwnership(_msgSender());
        instance = instanceCreated;
    }

    function _createInstanceValidate(
        address reserveToken,
        address tradedToken,
        uint64 duration,
        uint64 bonusTokenFraction,
        uint64 lpFraction,
        address lpFractionBeneficiary
    ) internal view {
        require(reserveToken != tradedToken, "CommunityCoin: IDENTICAL_ADDRESSES");
        require(reserveToken != address(0) && tradedToken != address(0), "CommunityCoin: ZERO_ADDRESS");
        require(lpFraction <= FRACTION, "CommunityCoin: WRONG_CLAIM_FRACTION");
        address instance = getInstance[reserveToken][tradedToken][duration];
        require(instance == address(0), "CommunityCoin: PAIR_ALREADY_EXISTS");
        require(
            typeProducedByFactory == InstanceType.NONE || typeProducedByFactory == InstanceType.USUAL,
            "CommunityCoin: INVALID_INSTANCE_TYPE"
        );
    }

    function _createInstanceErc20Validate(
        address tokenErc20,
        uint64 duration,
        uint64 bonusTokenFraction,
        uint64 lpFraction,
        address lpFractionBeneficiary
    ) internal view {
        address instance = getInstanceErc20[tokenErc20][duration];
        require(instance == address(0), "CommunityCoin: PAIR_ALREADY_EXISTS");
        require(lpFraction <= FRACTION, "CommunityCoin: WRONG_CLAIM_FRACTION");
        require(
            typeProducedByFactory == InstanceType.NONE || typeProducedByFactory == InstanceType.ERC20,
            "CommunityCoin: INVALID_INSTANCE_TYPE"
        );
    }

    function _createInstance(
        address reserveToken,
        address tradedToken,
        uint64 duration,
        uint64 bonusTokenFraction,
        uint64 lpFraction,
        address lpFractionBeneficiary,
        uint64 rewardsRateFraction,
        uint64 numerator,
        uint64 denominator
    ) internal returns (address instance) {
        instance = implementation.clone();

        getInstance[reserveToken][tradedToken][duration] = instance;

        _instanceIndexes[instance] = _instances.length;
        _instances.push(instance);

        _instanceTypes.push(InstanceType.USUAL);

        _instanceCreators[instance] = msg.sender; // real sender or trusted forwarder need to store?
        _instanceInfos[instance] = InstanceInfo(
            reserveToken,
            duration,
            bonusTokenFraction,
            tradedToken,
            lpFraction,
            lpFractionBeneficiary,
            rewardsRateFraction,
            numerator,
            denominator,
            true,
            uint8(InstanceType.USUAL),
            address(0)
        );

        if (typeProducedByFactory == InstanceType.NONE) {
            typeProducedByFactory = InstanceType.USUAL;
        }
        emit InstanceCreated(reserveToken, tradedToken, instance, _instances.length, address(0));
    }

    function _createInstanceErc20(
        address tokenErc20,
        uint64 duration,
        uint64 bonusTokenFraction,
        uint64 lpFraction,
        address lpFractionBeneficiary,
        uint64 rewardsRateFraction,
        uint64 numerator,
        uint64 denominator
    ) internal returns (address instance) {
        instance = implementationErc20.clone();

        getInstanceErc20[tokenErc20][duration] = instance;

        _instanceIndexes[instance] = _instances.length;
        _instances.push(instance);

        _instanceTypes.push(InstanceType.ERC20);

        _instanceCreators[instance] = msg.sender; // real sender or trusted forwarder need to store?
        _instanceInfos[instance] = InstanceInfo(
            address(0),
            duration,
            bonusTokenFraction,
            address(0),
            lpFraction,
            lpFractionBeneficiary,
            rewardsRateFraction,
            numerator,
            denominator,
            true,
            uint8(InstanceType.ERC20),
            tokenErc20
        );
        if (typeProducedByFactory == InstanceType.NONE) {
            typeProducedByFactory = InstanceType.ERC20;
        }
        emit InstanceCreated(address(0), address(0), instance, _instances.length, tokenErc20);
    }

    /**
     * @param instancesToRedeem instancesToRedeem
     * @param valuesToRedeem valuesToRedeem
     * @param swapPaths array of arrays uniswap swapPath
     */
    function amountAfterSwapLP(
        address[] memory instancesToRedeem,
        uint256[] memory valuesToRedeem,
        address[][] memory swapPaths
    ) external view returns (address finalToken, uint256 finalAmount) {
        uint256 tradedAmount;
        address tradedToken;
        uint256 reserveAmount;
        address reserveToken;

        uint256 adjusted;
        finalAmount = 0;
        for (uint256 i = 0; i < instancesToRedeem.length; i++) {
            //1 calculate  how much traded and reserve tokens we will obtain if redeem and remove liquidity from uniswap
            // take into account LpFraction
            adjusted = _instanceInfos[instancesToRedeem[i]].lpFraction != 0
                ? valuesToRedeem[i] - (valuesToRedeem[i] * _instanceInfos[instancesToRedeem[i]].lpFraction) / FRACTION
                : valuesToRedeem[i];
            (tradedAmount, tradedToken, reserveAmount, reserveToken) = getPairsAmount(
                instancesToRedeem[i],
                adjusted //valuesToRedeem[i]
            );

            uint256 amountTmp;
            address tokenTmp;

            // swap TradedToken to reverved
            (tokenTmp, amountTmp) = expectedAmount(
                tradedToken,
                tradedAmount,
                swapPaths,
                reserveToken,
                tradedAmount,
                reserveAmount
            );

            // swap total reverved token through swapPaths (in order)
            (tokenTmp, amountTmp) = expectedAmount(
                reserveToken,
                amountTmp + reserveAmount,
                swapPaths,
                address(0),
                0,
                0
            );

            finalAmount += amountTmp;
            finalToken = tokenTmp;
        }
    }

    function getPairsAmount(address poolAddress, uint256 amountLp)
        internal
        view
        returns (
            uint256 tradedAmount,
            address tradedToken,
            uint256 reserveAmount,
            address reserveToken
        )
    {
        tradedToken = _instanceInfos[poolAddress].tradedToken;
        reserveToken = _instanceInfos[poolAddress].reserveToken;
        require(tradedToken != address(0) && reserveToken != address(0), "addresses can not be empty");

        address pair = IUniswapV2Factory(uniswapRouterFactory).getPair(tradedToken, reserveToken);

        require(pair != address(0), "pair does not exists");
        uint256 balance0 = IERC777Upgradeable(reserveToken).balanceOf(pair);
        uint256 balance1 = IERC777Upgradeable(tradedToken).balanceOf(pair);
        //bool feeOn = _mintFee(_reserve0, _reserve1);
        // feeTo calculation (We skip for now), but totalSupply depend of fee that can be minted
        uint256 _totalSupply = IERC777Upgradeable(pair).totalSupply();
        reserveAmount = (amountLp * balance0) / _totalSupply;
        tradedAmount = (amountLp * balance1) / _totalSupply;
    }

    function expectedAmount(
        address tokenFrom,
        uint256 amount0,
        address[][] memory swapPaths,
        address forceTokenSwap,
        uint256 subReserveFrom,
        uint256 subReserveTo
    ) internal view returns (address, uint256) {
        if (forceTokenSwap == address(0)) {
            address tokenFromTmp;
            uint256 amount0Tmp;

            for (uint256 i = 0; i < swapPaths.length; i++) {
                if (tokenFrom == swapPaths[i][swapPaths[i].length - 1]) {
                    // if tokenFrom is already destination token
                    return (tokenFrom, amount0);
                }

                tokenFromTmp = tokenFrom;
                amount0Tmp = amount0;

                for (uint256 j = 0; j < swapPaths[i].length; j++) {
                    (bool success, uint256 amountOut) = _swap(
                        tokenFromTmp,
                        swapPaths[i][j],
                        amount0Tmp,
                        subReserveFrom,
                        subReserveTo
                    );
                    if (success) {
                        //ret = amountOut;
                    } else {
                        break;
                    }

                    // if swap didn't brake before last iteration then we think that swap is done
                    if (j == swapPaths[i].length - 1) {
                        return (swapPaths[i][j], amountOut);
                    } else {
                        tokenFromTmp = swapPaths[i][j];
                        amount0Tmp = amountOut;
                    }
                }
            }
            revert("paths invalid");
        } else {
            (bool success, uint256 amountOut) = _swap(tokenFrom, forceTokenSwap, amount0, subReserveFrom, subReserveTo);
            if (success) {
                return (forceTokenSwap, amountOut);
            }
            revert("force swap invalid");
        }
    }

    function _swap(
        address tokenFrom,
        address tokenTo,
        uint256 amountFrom,
        uint256 subReserveFrom,
        uint256 subReserveTo
    )
        internal
        view
        returns (
            bool success,
            uint256 ret //address pair
        )
    {
        success = false;
        address pair = IUniswapV2Factory(uniswapRouterFactory).getPair(tokenFrom, tokenTo);

        if (pair == address(0)) {
            //break;
            //revert("pair == address(0)");
        } else {
            (uint112 _reserve0, uint112 _reserve1, ) = IUniswapV2Pair(pair).getReserves();

            if (_reserve0 == 0 || _reserve1 == 0) {
                //break;
            } else {
                (_reserve0, _reserve1) = (tokenFrom == IUniswapV2Pair(pair).token0())
                    ? (_reserve0, _reserve1)
                    : (_reserve1, _reserve0);
                if (subReserveFrom >= _reserve0 || subReserveTo >= _reserve1) {
                    //break;
                } else {
                    _reserve0 -= uint112(subReserveFrom);
                    _reserve1 -= uint112(subReserveTo);
                    // amountin reservein reserveout
                    ret = IUniswapV2Router02(uniswapRouter).getAmountOut(amountFrom, _reserve0, _reserve1);

                    if (ret != 0) {
                        success = true;
                    }
                }
            }
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./IStructs.sol";

interface ICommunityStakingPoolErc20 {
    
    function initialize(
        address stakingProducedBy_,
        address token_,
        IStructs.StructAddrUint256[] memory donations_,
        uint64 lpFraction_,
        address lpFractionBeneficiary_,
        uint64 rewardsRateFraction_
    ) external;

    function redeem(address account, uint256 amount) external returns(uint256 affectedAmount, uint64 rewardsRateFraction);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./IStructs.sol";

interface ICommunityStakingPool {
    
    function initialize(
        address stakingProducedBy_,
        address reserveToken_,
        address tradedToken_, 
        IStructs.StructAddrUint256[] memory donations_,
        uint64 lpFraction_,
        address lpFractionBeneficiary_,
        uint64 rewardsRateFraction_
    ) external;
    /*
    function stake(address addr, uint256 amount) external;
    function getMinimum(address addr) external view returns(uint256);
    */
    function unstake(address account, uint256 amount) external returns(uint256 affectedLPAmount, uint64 rewardsRateFraction);
    function unstakeAndRemoveLiquidity(address account, uint256 amount) external returns(uint256 affectedReservedAmount, uint256 affectedTradedAmount, uint64 rewardsRateFraction);
    function redeem(address account, uint256 amount) external returns(uint256 affectedLPAmount, uint64 rewardsRateFraction);
    function redeemAndRemoveLiquidity(address account, uint256 amount) external returns(uint256 affectedReservedAmount, uint256 affectedTradedAmount, uint64 rewardsRateFraction);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./IStructs.sol";

interface ICommunityStakingPoolFactory {
    
    
    struct InstanceInfo {
        address reserveToken;
        uint64 duration;
        uint64 bonusTokenFraction;
        address tradedToken;
        uint64 lpFraction;
        address lpFractionBeneficiary;
        uint64 rewardsRateFraction;
        uint64 numerator;
        uint64 denominator;
        bool exists;
        uint8 instanceType;
        address tokenErc20;
    }

    event InstanceCreated(address indexed tokenA, address indexed tokenB, address instance, uint instancesCount, address indexed erc20);

    function initialize(address impl, address implErc20) external;
    function getInstance(address reserveToken, address tradedToken, uint256 lockupIntervalCount) external view returns (address instance);
    function getInstanceErc20(address tokenErc20, uint256 lockupIntervalCount) external view returns (address instance);
    function instancesByIndex(uint index) external view returns (address instance);
    function instances() external view returns (address[] memory instances);
    function instancesCount() external view returns (uint);
    function produce(address reserveToken, address tradedToken, uint64 duration, uint64 bonusTokenFraction, IStructs.StructAddrUint256[] memory donations, uint64 lpFraction, address lpFractionBeneficiary, uint64 rewardsRateFraction, uint64 numerator, uint64 denominator) external returns (address instance);
    function produceErc20(address tokenErc20, uint64 duration, uint64 bonusTokenFraction, IStructs.StructAddrUint256[] memory donations, uint64 lpFraction, address lpFractionBeneficiary, uint64 rewardsRateFraction, uint64 numerator, uint64 denominator) external returns (address instance);
    function getInstanceInfoByPoolAddress(address addr) external view returns(InstanceInfo memory);
    function amountAfterSwapLP(address[] memory instancesToRedeem, uint256[] memory valuesToRedeem, address[][] memory swapPaths) external view returns(address, uint256);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.11;

interface IStructs {
    struct StructAddrUint256 {
        address account;
        uint256 amount;
    }

    struct CommunitySettings {
        uint256 invitedByFraction;
        address addr;
        uint8 adminRoleId;
        uint8 redeemRoleId;
        uint8 circulationRoleId;
        uint8 tariffRoleId;
    }

    struct Total {
        uint256 totalUnstakeable;
        uint256 totalRedeemable;
        // it's how tokens will store in pools. without bonuses.
        // means totalReserves = SUM(pools.totalSupply)
        uint256 totalReserves;
    }

    enum InstanceType{ USUAL, ERC20, NONE }

}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

library SwapSettingsLib {
 
    function netWorkSettings(
    )
        internal
        view
        returns(address,address)
    {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        if ((chainId == 0x1) || (chainId == 0x3) || (chainId == 0x4) || (chainId == 0x539) || (chainId == 0x7a69)) {  //+ localganache chainId, used for fork 
            // Ethereum-Uniswap
            return( 
                0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, //uniswapRouter
                0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f  //uniswapRouterFactory
            );
        } else if(chainId == 0x89) {
            // Matic-QuickSwap
            return( 
                0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff, //uniswapRouter
                0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32  //uniswapRouterFactory
            );
        } else if(chainId == 0x38) {
            // Binance-PancakeSwap
            return( 
                0x10ED43C718714eb63d5aA57B78B54704E256024E, //uniswapRouter
                0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73  //uniswapRouterFactory
            );
        } else {
            revert("unsupported chain");
        }
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/Clones.sol)

pragma solidity ^0.8.0;

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */
library ClonesUpgradeable {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC777/IERC777.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC777Token standard as defined in the EIP.
 *
 * This contract uses the
 * https://eips.ethereum.org/EIPS/eip-1820[ERC1820 registry standard] to let
 * token holders and recipients react to token movements by using setting implementers
 * for the associated interfaces in said registry. See {IERC1820Registry} and
 * {ERC1820Implementer}.
 */
interface IERC777Upgradeable {
    /**
     * @dev Emitted when `amount` tokens are created by `operator` and assigned to `to`.
     *
     * Note that some additional user `data` and `operatorData` can be logged in the event.
     */
    event Minted(address indexed operator, address indexed to, uint256 amount, bytes data, bytes operatorData);

    /**
     * @dev Emitted when `operator` destroys `amount` tokens from `account`.
     *
     * Note that some additional user `data` and `operatorData` can be logged in the event.
     */
    event Burned(address indexed operator, address indexed from, uint256 amount, bytes data, bytes operatorData);

    /**
     * @dev Emitted when `operator` is made operator for `tokenHolder`
     */
    event AuthorizedOperator(address indexed operator, address indexed tokenHolder);

    /**
     * @dev Emitted when `operator` is revoked its operator status for `tokenHolder`
     */
    event RevokedOperator(address indexed operator, address indexed tokenHolder);

    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the smallest part of the token that is not divisible. This
     * means all token operations (creation, movement and destruction) must have
     * amounts that are a multiple of this number.
     *
     * For most token contracts, this value will equal 1.
     */
    function granularity() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by an account (`owner`).
     */
    function balanceOf(address owner) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * If send or receive hooks are registered for the caller and `recipient`,
     * the corresponding functions will be called with `data` and empty
     * `operatorData`. See {IERC777Sender} and {IERC777Recipient}.
     *
     * Emits a {Sent} event.
     *
     * Requirements
     *
     * - the caller must have at least `amount` tokens.
     * - `recipient` cannot be the zero address.
     * - if `recipient` is a contract, it must implement the {IERC777Recipient}
     * interface.
     */
    function send(
        address recipient,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev Destroys `amount` tokens from the caller's account, reducing the
     * total supply.
     *
     * If a send hook is registered for the caller, the corresponding function
     * will be called with `data` and empty `operatorData`. See {IERC777Sender}.
     *
     * Emits a {Burned} event.
     *
     * Requirements
     *
     * - the caller must have at least `amount` tokens.
     */
    function burn(uint256 amount, bytes calldata data) external;

    /**
     * @dev Returns true if an account is an operator of `tokenHolder`.
     * Operators can send and burn tokens on behalf of their owners. All
     * accounts are their own operator.
     *
     * See {operatorSend} and {operatorBurn}.
     */
    function isOperatorFor(address operator, address tokenHolder) external view returns (bool);

    /**
     * @dev Make an account an operator of the caller.
     *
     * See {isOperatorFor}.
     *
     * Emits an {AuthorizedOperator} event.
     *
     * Requirements
     *
     * - `operator` cannot be calling address.
     */
    function authorizeOperator(address operator) external;

    /**
     * @dev Revoke an account's operator status for the caller.
     *
     * See {isOperatorFor} and {defaultOperators}.
     *
     * Emits a {RevokedOperator} event.
     *
     * Requirements
     *
     * - `operator` cannot be calling address.
     */
    function revokeOperator(address operator) external;

    /**
     * @dev Returns the list of default operators. These accounts are operators
     * for all token holders, even if {authorizeOperator} was never called on
     * them.
     *
     * This list is immutable, but individual holders may revoke these via
     * {revokeOperator}, in which case {isOperatorFor} will return false.
     */
    function defaultOperators() external view returns (address[] memory);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient`. The caller must
     * be an operator of `sender`.
     *
     * If send or receive hooks are registered for `sender` and `recipient`,
     * the corresponding functions will be called with `data` and
     * `operatorData`. See {IERC777Sender} and {IERC777Recipient}.
     *
     * Emits a {Sent} event.
     *
     * Requirements
     *
     * - `sender` cannot be the zero address.
     * - `sender` must have at least `amount` tokens.
     * - the caller must be an operator for `sender`.
     * - `recipient` cannot be the zero address.
     * - if `recipient` is a contract, it must implement the {IERC777Recipient}
     * interface.
     */
    function operatorSend(
        address sender,
        address recipient,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the total supply.
     * The caller must be an operator of `account`.
     *
     * If a send hook is registered for `account`, the corresponding function
     * will be called with `data` and `operatorData`. See {IERC777Sender}.
     *
     * Emits a {Burned} event.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     * - the caller must be an operator for `account`.
     */
    function operatorBurn(
        address account,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;

    event Sent(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 amount,
        bytes data,
        bytes operatorData
    );
}

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
                /// @solidity memory-safe-assembly
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

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
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