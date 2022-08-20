// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
import "./interfaces/IConeLens.sol";
import "./interfaces/IVe.sol";
import "./interfaces/IBribe.sol";
import "./interfaces/IVoter.sol";
import "./interfaces/IController.sol";
import "./interfaces/IConePool.sol";
import "./interfaces/ICone.sol";
import "./ProxyImplementation.sol";
import "./libraries/Math.sol";

/**************************************************
 *                   Interfaces
 **************************************************/

interface IMinter {
    function veDist() external view returns (address);
}

interface IERC20 {
    function decimals() external view returns (uint8);
}

/**************************************************
 *                 Core contract
 **************************************************/
contract ConeLens is ProxyImplementation {
    address public veAddress;
    address public ownerAddress;

    // Internal interfaces
    IVoter internal voter;
    IController internal controller;
    IMinter internal minter;
    IVe internal ve;
    ICone internal cone;

    /**************************************************
     *                   Structs
     **************************************************/
    struct Pool {
        address id;
        string symbol;
        bool stable;
        address token0Address;
        address token1Address;
        address gaugeAddress;
        address bribeAddress;
        address[] bribeTokensAddresses;
        address fees;
        uint256 totalSupply;
    }

    struct ProtocolMetadata {
        address veAddress;
        address coneAddress;
        address voterAddress;
        address poolsFactoryAddress;
        address gaugesFactoryAddress;
        address minterAddress;
    }

    /**************************************************
     *                   Configuration
     **************************************************/

    /**
     * @notice Initialize proxy storage
     */
    function initializeProxyStorage(address _veAddress)
        public
        checkProxyInitialized
    {
        veAddress = _veAddress;
        ownerAddress = msg.sender;
        ve = IVe(veAddress);
        cone = ICone(ve.token());
        controller = IController(ve.controller());
        voter = IVoter(controller.voter());
        minter = IMinter(cone.minter());
    }

    function setVeAddress(address _veAddress) external {
        require(msg.sender == ownerAddress, "Only owner");
        veAddress = _veAddress;
    }

    function setOwnerAddress(address _ownerAddress) external {
        require(msg.sender == ownerAddress, "Only owner");
        ownerAddress = _ownerAddress;
    }

    /**************************************************
     *                 Protocol addresses
     **************************************************/
    function voterAddress() public view returns (address) {
        return controller.voter();
    }

    function poolsFactoryAddress() public view returns (address) {
        return voter.factory();
    }

    function gaugesFactoryAddress() public view returns (address) {
        return voter.gaugeFactory();
    }

    function coneAddress() public view returns (address) {
        return ve.token();
    }

    function routerAddress() public view returns (address) {
        return cone.router();
    }

    function veDistAddress() public view returns (address) {
        return controller.veDist();
    }

    function minterAddress() public view returns (address) {
        return cone.minter();
    }

    /**************************************************
     *                  Protocol data
     **************************************************/
    function protocolMetadata()
        external
        view
        returns (ProtocolMetadata memory)
    {
        return
            ProtocolMetadata({
                veAddress: veAddress,
                voterAddress: voterAddress(),
                coneAddress: coneAddress(),
                poolsFactoryAddress: poolsFactoryAddress(),
                gaugesFactoryAddress: gaugesFactoryAddress(),
                minterAddress: minterAddress()
            });
    }

    function poolsLength() public view returns (uint256) {
        return voter.poolsLength();
    }

    function poolsAddresses() public view returns (address[] memory) {
        uint256 _poolsLength = poolsLength();
        address[] memory _poolsAddresses = new address[](_poolsLength);
        for (uint256 poolIndex; poolIndex < _poolsLength; poolIndex++) {
            address poolAddress = voter.pools(poolIndex);
            _poolsAddresses[poolIndex] = poolAddress;
        }
        return _poolsAddresses;
    }

    function poolInfo(address poolAddress)
        public
        view
        returns (IConeLens.Pool memory)
    {
        IConePool pool = IConePool(poolAddress);
        address token0Address = pool.token0();
        address token1Address = pool.token1();
        address gaugeAddress = voter.gauges(poolAddress);
        address bribeAddress = voter.bribes(gaugeAddress);
        address[]
            memory _bribeTokensAddresses = bribeTokensAddressesByBribeAddress(
                bribeAddress
            );
        uint256 totalSupply = pool.totalSupply();
        if (_bribeTokensAddresses.length < 2) {
            _bribeTokensAddresses = new address[](2);
            _bribeTokensAddresses[0] = token0Address;
            _bribeTokensAddresses[1] = token1Address;
        }
        return
            IConeLens.Pool({
                id: poolAddress,
                symbol: pool.symbol(),
                stable: pool.stable(),
                token0Address: token0Address,
                token1Address: token1Address,
                gaugeAddress: gaugeAddress,
                bribeAddress: bribeAddress,
                bribeTokensAddresses: _bribeTokensAddresses,
                fees: pool.fees(),
                totalSupply: totalSupply
            });
    }

    function poolsInfo() external view returns (IConeLens.Pool[] memory) {
        address[] memory _poolsAddresses = poolsAddresses();
        IConeLens.Pool[] memory pools = new IConeLens.Pool[](
            _poolsAddresses.length
        );
        for (
            uint256 poolIndex;
            poolIndex < _poolsAddresses.length;
            poolIndex++
        ) {
            address poolAddress = _poolsAddresses[poolIndex];
            IConeLens.Pool memory _poolInfo = poolInfo(poolAddress);
            pools[poolIndex] = _poolInfo;
        }
        return pools;
    }

    function poolReservesInfo(address poolAddress)
        public
        view
        returns (IConeLens.PoolReserveData memory)
    {
        IConePool pool = IConePool(poolAddress);
        address token0Address = pool.token0();
        address token1Address = pool.token1();
        (uint256 token0Reserve, uint256 token1Reserve, ) = pool.getReserves();
        uint8 token0Decimals = IERC20(token0Address).decimals();
        uint8 token1Decimals = IERC20(token1Address).decimals();
        return
            IConeLens.PoolReserveData({
                id: poolAddress,
                token0Address: token0Address,
                token1Address: token1Address,
                token0Reserve: token0Reserve,
                token1Reserve: token1Reserve,
                token0Decimals: token0Decimals,
                token1Decimals: token1Decimals
            });
    }

    function poolsReservesInfo(address[] memory _poolsAddresses)
        external
        view
        returns (IConeLens.PoolReserveData[] memory)
    {
        IConeLens.PoolReserveData[]
            memory _poolsReservesInfo = new IConeLens.PoolReserveData[](
                _poolsAddresses.length
            );
        for (
            uint256 poolIndex;
            poolIndex < _poolsAddresses.length;
            poolIndex++
        ) {
            address poolAddress = _poolsAddresses[poolIndex];
            _poolsReservesInfo[poolIndex] = poolReservesInfo(poolAddress);
        }
        return _poolsReservesInfo;
    }

    function gaugesAddresses() public view returns (address[] memory) {
        address[] memory _poolsAddresses = poolsAddresses();
        address[] memory _gaugesAddresses = new address[](
            _poolsAddresses.length
        );
        for (
            uint256 poolIndex;
            poolIndex < _poolsAddresses.length;
            poolIndex++
        ) {
            address poolAddress = _poolsAddresses[poolIndex];
            address gaugeAddress = voter.gauges(poolAddress);
            _gaugesAddresses[poolIndex] = gaugeAddress;
        }
        return _gaugesAddresses;
    }

    function bribesAddresses() public view returns (address[] memory) {
        address[] memory _gaugesAddresses = gaugesAddresses();
        address[] memory _bribesAddresses = new address[](
            _gaugesAddresses.length
        );
        for (uint256 gaugeIdx; gaugeIdx < _gaugesAddresses.length; gaugeIdx++) {
            address gaugeAddress = _gaugesAddresses[gaugeIdx];
            address bribeAddress = voter.bribes(gaugeAddress);
            _bribesAddresses[gaugeIdx] = bribeAddress;
        }
        return _bribesAddresses;
    }

    function bribeTokensAddressesByBribeAddress(address bribeAddress)
        public
        view
        returns (address[] memory)
    {
        uint256 bribeTokensLength = IBribe(bribeAddress).rewardTokensLength();
        address[] memory _bribeTokensAddresses = new address[](
            bribeTokensLength
        );
        for (
            uint256 bribeTokenIdx;
            bribeTokenIdx < bribeTokensLength;
            bribeTokenIdx++
        ) {
            address bribeTokenAddress = IBribe(bribeAddress).rewardTokens(
                bribeTokenIdx
            );
            _bribeTokensAddresses[bribeTokenIdx] = bribeTokenAddress;
        }
        return _bribeTokensAddresses;
    }

    function poolsPositionsOf(
        address accountAddress,
        uint256 startIndex,
        uint256 endIndex
    ) public view returns (IConeLens.PositionPool[] memory) {
        uint256 _poolsLength = poolsLength();
        IConeLens.PositionPool[]
            memory _poolsPositionsOf = new IConeLens.PositionPool[](
                _poolsLength
            );
        uint256 positionsLength;
        endIndex = Math.min(endIndex, _poolsLength);
        for (
            uint256 poolIndex = startIndex;
            poolIndex < endIndex;
            poolIndex++
        ) {
            address poolAddress = voter.pools(poolIndex);
            uint256 balanceOf = IConePool(poolAddress).balanceOf(
                accountAddress
            );
            if (balanceOf > 0) {
                _poolsPositionsOf[positionsLength] = IConeLens.PositionPool({
                    id: poolAddress,
                    balanceOf: balanceOf
                });
                positionsLength++;
            }
        }

        bytes memory encodedPositions = abi.encode(_poolsPositionsOf);
        assembly {
            mstore(add(encodedPositions, 0x40), positionsLength)
        }
        return abi.decode(encodedPositions, (IConeLens.PositionPool[]));
    }

    function poolsPositionsOf(address accountAddress)
        public
        view
        returns (IConeLens.PositionPool[] memory)
    {
        uint256 _poolsLength = poolsLength();
        IConeLens.PositionPool[]
            memory _poolsPositionsOf = new IConeLens.PositionPool[](
                _poolsLength
            );

        uint256 positionsLength;

        for (uint256 poolIndex; poolIndex < _poolsLength; poolIndex++) {
            address poolAddress = voter.pools(poolIndex);
            uint256 balanceOf = IConePool(poolAddress).balanceOf(
                accountAddress
            );
            if (balanceOf > 0) {
                _poolsPositionsOf[positionsLength] = IConeLens.PositionPool({
                    id: poolAddress,
                    balanceOf: balanceOf
                });
                positionsLength++;
            }
        }

        bytes memory encodedPositions = abi.encode(_poolsPositionsOf);
        assembly {
            mstore(add(encodedPositions, 0x40), positionsLength)
        }
        return abi.decode(encodedPositions, (IConeLens.PositionPool[]));
    }

    function veTokensIdsOf(address accountAddress)
        public
        view
        returns (uint256[] memory)
    {
        uint256 veBalanceOf = ve.balanceOf(accountAddress);
        uint256[] memory _veTokensOf = new uint256[](veBalanceOf);

        for (uint256 tokenIdx; tokenIdx < veBalanceOf; tokenIdx++) {
            uint256 tokenId = ve.tokenOfOwnerByIndex(accountAddress, tokenIdx);
            _veTokensOf[tokenIdx] = tokenId;
        }
        return _veTokensOf;
    }

    function gaugeAddressByPoolAddress(address poolAddress)
        external
        view
        returns (address)
    {
        return voter.gauges(poolAddress);
    }

    function bribeAddresByPoolAddress(address poolAddress)
        public
        view
        returns (address)
    {
        address gaugeAddress = voter.gauges(poolAddress);
        address bribeAddress = voter.bribes(gaugeAddress);
        return bribeAddress;
    }

    function bribeTokensAddressesByPoolAddress(address poolAddress)
        public
        view
        returns (address[] memory)
    {
        address bribeAddress = bribeAddresByPoolAddress(poolAddress);
        return bribeTokensAddressesByBribeAddress(bribeAddress);
    }

    function bribesPositionsOf(
        address accountAddress,
        address poolAddress,
        uint256 tokenId
    ) public view returns (IConeLens.PositionBribe[] memory) {
        address bribeAddress = bribeAddresByPoolAddress(poolAddress);
        address[]
            memory bribeTokensAddresses = bribeTokensAddressesByBribeAddress(
                bribeAddress
            );
        IConeLens.PositionBribe[]
            memory _bribesPositionsOf = new IConeLens.PositionBribe[](
                bribeTokensAddresses.length
            );
        uint256 currentIdx;
        for (
            uint256 bribeTokenIdx;
            bribeTokenIdx < bribeTokensAddresses.length;
            bribeTokenIdx++
        ) {
            address bribeTokenAddress = bribeTokensAddresses[bribeTokenIdx];
            uint256 earned = IBribe(bribeAddress).earned(
                bribeTokenAddress,
                tokenId
            );
            if (earned > 0) {
                _bribesPositionsOf[currentIdx] = IConeLens.PositionBribe({
                    bribeTokenAddress: bribeTokenAddress,
                    earned: earned
                });
                currentIdx++;
            }
        }
        bytes memory encodedBribes = abi.encode(_bribesPositionsOf);
        assembly {
            mstore(add(encodedBribes, 0x40), currentIdx)
        }
        IConeLens.PositionBribe[] memory filteredBribes = abi.decode(
            encodedBribes,
            (IConeLens.PositionBribe[])
        );
        return filteredBribes;
    }

    function bribesPositionsOf(address accountAddress, address poolAddress)
        public
        view
        returns (IConeLens.PositionBribesByTokenId[] memory)
    {
        address bribeAddress = bribeAddresByPoolAddress(poolAddress);
        address[]
            memory bribeTokensAddresses = bribeTokensAddressesByBribeAddress(
                bribeAddress
            );

        uint256[] memory veTokensIds = veTokensIdsOf(accountAddress);
        IConeLens.PositionBribesByTokenId[]
            memory _bribePositionsOf = new IConeLens.PositionBribesByTokenId[](
                veTokensIds.length
            );

        uint256 currentIdx;
        for (
            uint256 veTokenIdIdx;
            veTokenIdIdx < veTokensIds.length;
            veTokenIdIdx++
        ) {
            uint256 tokenId = veTokensIds[veTokenIdIdx];
            _bribePositionsOf[currentIdx] = IConeLens
                .PositionBribesByTokenId({
                    tokenId: tokenId,
                    bribes: bribesPositionsOf(
                        accountAddress,
                        poolAddress,
                        tokenId
                    )
                });
            currentIdx++;
        }
        return _bribePositionsOf;
    }

    function vePositionsOf(address accountAddress)
        public
        view
        returns (IConeLens.PositionVe[] memory)
    {
        uint256 veBalanceOf = ve.balanceOf(accountAddress);
        IConeLens.PositionVe[]
            memory _vePositionsOf = new IConeLens.PositionVe[](veBalanceOf);

        for (uint256 tokenIdx; tokenIdx < veBalanceOf; tokenIdx++) {
            uint256 tokenId = ve.tokenOfOwnerByIndex(accountAddress, tokenIdx);
            uint256 balanceOf = ve.balanceOfNFT(tokenId);
            uint256 locked = ve.locked(tokenId);
            _vePositionsOf[tokenIdx] = IConeLens.PositionVe({
                tokenId: tokenId,
                balanceOf: balanceOf,
                locked: locked
            });
        }
        return _vePositionsOf;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IConeLens {
    struct Pool {
        address id;
        string symbol;
        bool stable;
        address token0Address;
        address token1Address;
        address gaugeAddress;
        address bribeAddress;
        address[] bribeTokensAddresses;
        address fees;
        uint256 totalSupply;
    }

    struct PoolReserveData {
        address id;
        address token0Address;
        address token1Address;
        uint256 token0Reserve;
        uint256 token1Reserve;
        uint8 token0Decimals;
        uint8 token1Decimals;
    }

    struct PositionVe {
        uint256 tokenId;
        uint256 balanceOf;
        uint256 locked;
    }

    struct PositionBribesByTokenId {
        uint256 tokenId;
        PositionBribe[] bribes;
    }

    struct PositionBribe {
        address bribeTokenAddress;
        uint256 earned;
    }

    struct PositionPool {
        address id;
        uint256 balanceOf;
    }

    function poolsLength() external view returns (uint256);

    function voterAddress() external view returns (address);

    function veAddress() external view returns (address);

    function poolsFactoryAddress() external view returns (address);

    function gaugesFactoryAddress() external view returns (address);

    function minterAddress() external view returns (address);

    function coneAddress() external view returns (address);

    function vePositionsOf(address) external view returns (PositionVe[] memory);

    function bribeAddresByPoolAddress(address) external view returns (address);

    function gaugeAddressByPoolAddress(address) external view returns (address);

    function poolsPositionsOf(address)
        external
        view
        returns (PositionPool[] memory);

    function poolsPositionsOf(
        address,
        uint256,
        uint256
    ) external view returns (PositionPool[] memory);

    function poolInfo(address) external view returns (Pool memory);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IVe {
    function safeTransferFrom(
        address,
        address,
        uint256
    ) external;

    function ownerOf(uint256) external view returns (address);

    function balanceOf(address) external view returns (uint256);

    function balanceOfNFT(uint256) external view returns (uint256);

    function balanceOfNFTAt(uint256, uint256) external view returns (uint256);

    function balanceOfAtNFT(uint256, uint256) external view returns (uint256);

    function locked(uint256) external view returns (uint256);

    function createLock(uint256, uint256) external returns (uint256);

    function approve(address, uint256) external;

    function merge(uint256, uint256) external;

    function token() external view returns (address);

    function controller() external view returns (address);

    function voted(uint256) external view returns (bool);

    function tokenOfOwnerByIndex(address, uint256)
        external
        view
        returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IBribe {
    function rewardTokensLength() external view returns (uint256);

    function rewardTokens(uint256) external view returns (address);

    function earned(address, uint256) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IVoter {
    function listingFee() external view returns (uint);

    function isWhitelisted(address) external view returns (bool);

    function poolsLength() external view returns (uint256);

    function pools(uint256) external view returns (address);

    function gauges(address) external view returns (address);

    function bribes(address) external view returns (address);

    function factory() external view returns (address);

    function gaugeFactory() external view returns (address);

    function vote(
        uint256,
        address[] memory,
        int256[] memory
    ) external;

    function whitelist(address, uint256) external;

    function updateFor(address[] memory _gauges) external;

    function claimRewards(address[] memory _gauges, address[][] memory _tokens)
        external;

    function distribute(address _gauge) external;

    function usedWeights(uint256) external returns (uint256);

    function reset(uint256 _tokenId) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface IController {

  function veDist() external view returns (address);

  function voter() external view returns (address);

}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IConePool {
    function token0() external view returns (address);

    function token1() external view returns (address);

    function fees() external view returns (address);

    function stable() external view returns (bool);

    function symbol() external view returns (string memory);

    function claimable0(address) external view returns (uint256);

    function claimable1(address) external view returns (uint256);

    function approve(address, uint256) external;

    function transfer(address, uint256) external;

    function transferFrom(
        address src,
        address dst,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address) external view returns (uint256);

    function getReserves()
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );

    function reserve0() external view returns (uint256);

    function reserve1() external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function claimFees() external returns (uint256 claimed0, uint256 claimed1);

    function allowance(address, address) external returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface ICone {
    function transferFrom(
        address,
        address,
        uint256
    ) external;

    function allowance(address, address) external view returns (uint256);

    function approve(address, uint256) external;

    function balanceOf(address) external view returns (uint256);

    function router() external view returns (address);

    function minter() external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11||0.6.12;

/**
 * @title Implementation meant to be used with a proxy
 * @author Unknown
 */
contract ProxyImplementation {
    bool public proxyStorageInitialized;

    /**
     * @notice Nothing in constructor, since it only affects the logic address, not the storage address
     * @dev public visibility so it compiles for 0.6.12
     */
    constructor() public {}

    /**
     * @notice Only allow proxy's storage to be initialized once
     */
    modifier checkProxyInitialized() {
        require(
            !proxyStorageInitialized,
            "Can only initialize proxy storage once"
        );
        proxyStorageInitialized = true;
        _;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

library Math {
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function abs(int256 x) internal pure returns (uint256) {
        return uint256(x >= 0 ? x : -x);
    }
}