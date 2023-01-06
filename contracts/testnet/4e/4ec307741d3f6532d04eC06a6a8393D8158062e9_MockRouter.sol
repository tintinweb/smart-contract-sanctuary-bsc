/**
 *Submitted for verification at BscScan.com on 2023-01-05
*/

// File: ../leveraged/contracts/libraries/Context.sol

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.10;

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

// File: ../leveraged/contracts/access/Ownable.sol



pragma solidity ^0.8.10;


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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
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
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: ../leveraged/contracts/interfaces/ILeveragedVault.sol



pragma solidity ^0.8.10;

// the address used to identify BNB
address constant BNB_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

/**
* @dev Interface for a LeveragedVault contract
 **/

interface ILeveragedVault {
    struct LPPosition {
        address lpToken; // the address of liquidity provider token (liquidity pool address)
        uint256 amount; // the amount of lp tokens
        address borrowedAsset; // the address of the borrowed asset
        uint256 borrowedAmount; // the amount of debt
        uint256 averageInterestRate; // the average interest rate
        uint256 farmingRewardIndex; // the cumulative farming reward index
        address user; // the address of the user
        uint256 timestamp; // last operation timestamp
        uint256 prevLPPositionId; // id of previous LP position
        uint256 prevUserLPPositionId; // id of previous LP position of the user
        uint256 nextLPPositionId; // id of next LP position
        uint256 nextUserLPPositionId; // id of next LP position of the user
        bool isOpen;
    }

    function getAssetDecimals(address _asset) external view returns (uint256);
    function getAssetITokenAddress(address _asset) external view returns (address);
    function getAssetTotalLiquidity(address _asset) external view returns (uint256);
    function getUserAssetBalance(address _asset, address _user) external view returns (uint256);
    function getUserBorrowBalance(address _borrowedAsset, address _user) external view returns (uint256);
    function getLPPositionDebt(uint256 _lpPositionId) external view returns (uint256);
    function getLPPositionAmount(uint256 lpPositionId) external view returns (uint256);
    function getLPToken(uint256 lpPositionId) external view returns (address);
    function lpPositionIsOpen(uint256 lpPositionId) external view returns (bool);
    function getLPPositionBorrowedAsset(uint256 lpPositionId) external view returns (address);
    function getLPPosition(uint256 lpPositionId) external view returns (LPPosition memory);
    function getUserAverageInterestRate(address _asset, address _user) external view returns (uint256);
    function getAssetInterestRate(address _asset) external view returns (uint256);
    function getFarmPoolTotalValue(address _asset) external view returns (uint256);
    function getAssets() external view returns (address[] memory);
    function setAverageInterestRate(address _asset, address _user, uint256 _averageInterestRate) external;
    function updateBorrowBalance(address _asset, address _user, uint256 _userBorrowBalance) external;
    function openPosition(address _lpToken, address _borrowedAsset, uint256 _margin, uint256 _borrowedAmount, address _user) external returns (uint256);
    function closePosition(uint256 _lpPositionId, uint256 _lpTokenAmount) external;
    function updateMarginBorrowBalance(uint256 _lpPositionId, uint256 _newBorrowedAmount) external;
    function updateTotalCollateralBalance(address _asset) external;
    function transferToVault(address _asset, address payable _depositor, uint256 _amount) external;
    function transferToUser(address _asset, address payable _user, uint256 _amount) external;
    function updatePlatformProfitAndLiquidityIndexLog2(address _asset) external;
    function cumulatedAmount(address _asset, uint256 _storedAmount) external view returns (uint256);
    function storedAmount(address _asset, uint256 _cumulatedAmount) external view returns (uint256);
    function storedPlatformProfit(address _asset) external view returns (uint256);
    function getFullPlatformProfit(address _asset) external view returns (uint256);

    receive() external payable;
}

// File: ../leveraged/contracts/interfaces/IRouter.sol



pragma solidity ^0.8.10;

/**
 * @dev Interface for a router contract.
 */
interface IRouter {
    function setMockFarmPoolTotalValueInUSD(uint256 newFarmPoolTotalValueInUSD) external;
    function getFarmPoolTotalValueInUSD(address _lpToken) external view returns (uint256);
    function getTokens(address _lpToken) external view returns (address token0, address token1);
}

// File: ../leveraged/contracts/mocks/MockRouter.sol



pragma solidity ^0.8.10;




/**
* @title Mock Router contract
* @dev Implements functions to transfer assets from Vault contract to external protocols and back.
**/
contract MockRouter is IRouter, Ownable {
    ILeveragedVault public vault;
    uint256 mockFarmPoolTotalValueInUSD;

    mapping(string => address) public tokens;

    constructor(
        address payable _vault
    ) {
        vault = ILeveragedVault(_vault);
        mockFarmPoolTotalValueInUSD = 100000 * 10**8;
    }

    function setMockFarmPoolTotalValueInUSD(uint256 newFarmPoolTotalValueInUSD) external onlyOwner {
        mockFarmPoolTotalValueInUSD = newFarmPoolTotalValueInUSD;
    }

    function getFarmPoolTotalValueInUSD(address _lpToken) external view returns (uint256) {
        return mockFarmPoolTotalValueInUSD;
    }

    function getTokens(address _lpToken) external view
        returns (
            address token0,
            address token1
        )
    {
        if (_lpToken == 0x014608E87AF97a054C9a49f81E1473076D51d9a3) { // MATIC-BNB
            token0 = tokens['MATIC'] == address(0) ? 0x96029C3Bc6Ea39601bF086Ce3554c7830205aF91 : tokens['MATIC'];
            token1 = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
        } else if (_lpToken == 0x1CEa83EC5E48D9157fCAe27a19807BeF79195Ce1) { // CAKE-BNB
            token0 = tokens['CAKE'] == address(0) ? 0x9B61855fed421F0BCF49728C2Cf45d62b7dbe3EF : tokens['CAKE'];
            token1 = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
        } else if (_lpToken == 0x2139C481d4f31dD03F924B6e87191E15A33Bf8B4) { // CAKE-USDT
            token0 = tokens['CAKE'] == address(0) ? 0x9B61855fed421F0BCF49728C2Cf45d62b7dbe3EF : tokens['CAKE'];
            token1 = tokens['USDT'] == address(0) ? 0x6EE6727b9E04cA1a5E1E45992Cf5FD4345625687 : tokens['USDT'];
        } else if (_lpToken == 0xe267018C943E77992e7e515724B07b9CE7938124) { // CAKE-BUSD
            token0 = tokens['CAKE'] == address(0) ? 0x9B61855fed421F0BCF49728C2Cf45d62b7dbe3EF : tokens['CAKE'];
            token1 = tokens['BUSD'] == address(0) ? 0x2184110dd6886cd2B1F1CCD0870DaB819152be30 : tokens['BUSD'];
        } else if (_lpToken == 0xc736cA3d9b1E90Af4230BD8F9626528B3D4e0Ee0) { // GMT-USDT
            token0 = tokens['GMT'] == address(0) ? 0xC6614716abfEBc1179B38730F709E90AE6d25CF6 : tokens['GMT'];
            token1 = tokens['USDT'] == address(0) ? 0x6EE6727b9E04cA1a5E1E45992Cf5FD4345625687 : tokens['USDT'];
        } else if (_lpToken == 0x352008bf4319c3B7B8794f1c2115B9Aa18259EBb) { // XRP-BNB
            token0 = tokens['XRP'] == address(0) ? 0x29ba6CaEEF999ffB47afc34d947Dd42b6e659504 : tokens['XRP'];
            token1 = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
        } else if (_lpToken == 0x2407A09D25F8b72c8838A56b4100Ce600fbFA4ed) { // BNB-USDT
            token0 = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
            token1 = tokens['USDT'] == address(0) ? 0x6EE6727b9E04cA1a5E1E45992Cf5FD4345625687 : tokens['USDT'];
        } else if (_lpToken == 0xc803790dD1a234b326Cd4E593b05337a0c84a05e) { // FIL-USDT
            token0 = tokens['FIL'] == address(0) ? 0x86366e304Fed8306d83c6F341f1f209097476A44 : tokens['FIL'];
            token1 = tokens['USDT'] == address(0) ? 0x6EE6727b9E04cA1a5E1E45992Cf5FD4345625687 : tokens['USDT'];
        } else if (_lpToken == 0xD254a3C351DAd83F8B369554B420047A1ED60f1C) { // SFP-BNB
            token0 = tokens['SFP'] == address(0) ? 0x9b265f7548735752De4ae0Ae8acD07A9a8224a59 : tokens['SFP'];
            token1 = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
        } else if (_lpToken == 0x51dCAF423FE39F620A13379Cd26821cF8d433308) { // DOGE-BNB
            token0 = tokens['DOGE'] == address(0) ? 0xF7a5fC580C20288dd09Dd3a40D6687053198766C : tokens['DOGE'];
            token1 = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
        } else if (_lpToken == 0xe7987f07C01B6CA83971E8407D67CAfB3193619c) { // TWT-BNB
            token0 = tokens['TWT'] == address(0) ? 0x9f6FfE5b9d02D57080F373c756cA92aF8eF7Af1D : tokens['TWT'];
            token1 = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
        } else if (_lpToken == 0xB450CBF17F6723Ef9c1bf3C3f0e0aBA368D09bF5) { // SXP-BNB
            token0 = tokens['SXP'] == address(0) ? 0x6468d3c0D1f18E54591F8D628c0109D8fF1D8829 : tokens['SXP'];
            token1 = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
        } else if (_lpToken == 0xED2eC734193626282e105A4A44bf39C1F6B44d78) { // DOT-BNB
            token0 = tokens['DOT'] == address(0) ? 0x33DEd922C79E76A116D0cA35C2e328a87E22eEAe : tokens['DOT'];
            token1 = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
        } else if (_lpToken == 0x007A5E4e2C6D377852e843a6d624120af450A073) { // BNB-BUSD
            token0 = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
            token1 = tokens['BUSD'] == address(0) ? 0x2184110dd6886cd2B1F1CCD0870DaB819152be30 : tokens['BUSD'];
        } else if (_lpToken == 0x78B7220f37B8F6e30d03018558B0C8c4430662C7) { // MBOX-BNB
            token0 = tokens['MBOX'] == address(0) ? 0xaA9a8283EAaaFF785aC5658706c3D11DF81Dc6d2 : tokens['MBOX'];
            token1 = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
        } else { // XVS-BNB
            token0 = tokens['XVS'] == address(0) ? 0x0f950A6ddDC12E3ECa0F0f5d4f16A5D35b3Fa54F : tokens['XVS'];
            token1 = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
        }
    }    

    /**
    * @dev set the token address
    * @param _tokenName the token name
    * @param _tokenAddress the token address
    **/
    function setToken(
        string memory _tokenName,
        address _tokenAddress
    ) external onlyOwner {
        tokens[_tokenName] = _tokenAddress;
    }
}