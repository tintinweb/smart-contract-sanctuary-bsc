/**
 *Submitted for verification at BscScan.com on 2022-12-13
*/

// SPDX-License-Identifier: MIT

/*
    Contrato de Staking Pool e Farm de NFTs da Rayons Energy
    https://rayonsenergy.com/
    https://t.me/RayonsEnergy


    dev @italo_blockchain
    https://twitter.com/ItaloH_SA

*/




pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}





contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }
}


abstract contract Pausable is Context {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    modifier whenPaused() {
        _requirePaused();
        _;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }


    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}


interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (uint256);    

    function transfer(address to, uint256 amount) external returns (bool);
}

interface IUniswapV2Router {
    function getAmountsOut(uint256 amountIn, address[] memory path)
        external
        view
        returns (uint256[] memory amounts);
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

interface IRayonsNFTold_interface {

    struct Data {
        address ownerNFT;
        string nameNFT;
        uint256 amount;
        uint256 rarity;
        uint256 boost;
        uint256 amountBoost;
        uint256 idNumber;
        string idNFT;
        bool isUser;
    }

    function data(uint256 ID)
        external
        view
        returns (address,string memory,uint256,uint256,
        uint256,uint256,uint256,string memory,bool);

    function fetchMyNfts(address account)
        external
        view
        returns (Data[] memory _data);

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory dataSBTCH
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata dataSafeTransferFrom
    ) external;

    function transferMyNFT (
        address from,
        address to,
        uint256 id,
        uint256 amount
    ) external;
}

interface IRayonsNFTnew_interface {
    function balanceOf(address account)
        external
        view
        returns (uint256);
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
}



contract RayonsStakingTokensAndFarmPool is Pausable, Ownable, ReentrancyGuard {

    using SafeMath for uint256;

    uint256 public amountTokensInStaking;
    uint256 public amountTokensWasStaked;
    uint256 public amountTokensInFarm;
    uint256 public amountTokensWasFarmed;

    uint256 public totalStakingMade;
    uint256 public totalFarmMade;
    uint256 public totalStakingOn;

    bool private boolCountFarmers;
    uint256 public totalFarmers;

    uint256 public depositRayonsToStakingPool;
    uint256 public depositBUSDToStakingPool;
    uint256 public depositRayonsToFarm;
    uint256 public depositBUSDtoFarm;

    uint256 public amountRayonsClaimedStakingPool;
    uint256 public amountRayonsClaimedFarmNFT;
    uint256 public amountBUSDclaimedStakingPool;
    uint256 public amountBUSDclaimedFarmNFT;

    uint256 public lastDepositRayonsToStakingPool;
    uint256 public lastDepositBUSDtoStakingPool;
    uint256 public lastDepositRayonsToFarm;
    uint256 public lastDepositBUSDtoFarm;

    uint256 public timeLastDepositRayonsToStakingPool;
    uint256 public timeLastDepositRayonsToFarm;
    uint256 public timeLastDepositBUSDtoFarm;

    uint256 public timeDeployContractThis;
    uint256 public timeOpenPoolsStaking;
    uint256 public timeClaimRayonsStaking;
    uint256 public timeClaimBUSDstaking;
    uint256 public timeToWithdrawStaking;

    bool public settedTimeOpenPoolStaking;
    bool public checkSecurityActived;

    uint256 public denominatorIncreaseFactor;

    mapping(address => bool) public mappingAuth;

    address public  addressRYS          = 0xDe95A749Cbb93940A06c68FfA78ECFce1b1F7d9a;
    address public  addressRayonsNFTold = 0x34a22c21E11900740668B8DeC888834446026Ce3;
    address public  addressRayonsNFTnew;

    address public addressBUSD         = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public addressWBNB         = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public addressPCVS2        = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address public addressRayonsADMIN = 0xBc631F653EB4a90CfDC7D7faEFE3d189949e36C8;

    struct stakeInfos {
        uint256 amountTokensInicial;
        uint256 amountTokens;
        uint256 startStaking;
    }

    struct claimStakingInfos {
        uint256 totalRayonsClaimed;
        uint256 totalBUSDClaimed;
        uint256 lastTimeClaimRayons;
        uint256 lastTimeClaimBUSD;
    }

    struct rewardsEarnStaking {
        uint256 whatsLastBalanceRayonsContract;
        uint256 whatsLastBalanceBUSDContract;

    }

    struct farmInfos {
        uint256[] amountBoost;
        uint256[] startStaking;
        uint256[] ID;
        uint256[] rarity;
   }

    struct claimFarmInfos {
        uint256 totalRayonsClaimed;
        uint256 totalBUSDClaimed;
        uint256 lastTimeClaimRayons;
        uint256 lastTimeClaimBUSD;

    }

    struct rewardsEarnFarm {
        uint256 whatsLastBalanceRayonsContract;
        uint256 whatsLastBalanceBUSDContract;

    }
    
    address[] public allAddressStaking;
    address[] public allAddressFarmer;
    uint256[] public allFarmerIDs;

    address[] public allOwnersFarmAtualized;

    mapping(address => stakeInfos) mappingStakingInfos;
    mapping(address => claimStakingInfos) mappingClaimStakingInfos;
    mapping(address => rewardsEarnStaking) mappingRewardsEarnStaking;

    mapping(address => farmInfos) mappingFarmInfos;
    mapping(address => claimFarmInfos) mappingClaimFarmInfos;
    mapping(address => rewardsEarnFarm) mappingRewardsEarnFarm;

    event farmNFTevent(
        address indexed addressStaking, 
        uint256 amountTokens, 
        address msgSender);

    event claimRewardsFarmEvent(
        address indexed farmer,
        uint256 amountClaimedRYS,
        uint256 amountClaimedBUSD,
        address msgSender);

    event claimRewardsAndNFTsFarmEvent(
        address indexed farmer,
        uint256 amountTokens,
        uint256 amountClaimedRYS,
        uint256 amountClaimedBUSD,
        address msgSender);

    event stakingEvent(
        address indexed addressStaking, 
        uint256 amountTokens, 
        address msgSender);

    event claimStakingEvent(
        address indexed addressStaking, 
        uint256 amountTokens, 
        uint256 calculateUnpaidEarningsRayons,
        uint256 calculateUnpaidEarningsBUSD,
        address msgSender);

    event autoReinvestEvent(
        address indexed addressStaking, 
        uint256 calculateUnpaidEarningsRayons, 
        address msgSender);

    event ownersFarmAtualized(
        address indexed farmer, 
        address indexed ownerNFT, 
        uint256 ID);

    constructor() {
        timeDeployContractThis = block.timestamp;
        timeClaimRayonsStaking = 24 hours;
        timeClaimBUSDstaking = 30 days;
        timeToWithdrawStaking = 30 days;

        checkSecurityActived = true;
        denominatorIncreaseFactor = 15;

        mappingAuth[addressRayonsADMIN] = true;
    }

    modifier onlyAuth() {
        require(getMappingAuth(_msgSender()), "Nao autorizado");
        _;
    }

    function getMappingAuth(address account) public view returns (bool){
        return mappingAuth[account]; 
    }

    function getSecondsPassed() public view returns (uint256){
        return (block.timestamp - timeOpenPoolsStaking).div(1 seconds); 
    }

    function getBytes32(string memory stringIn) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(bytes(stringIn)));
    }

    function checkSecurity (address account) public view returns (bool checkSecurityReturn) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }

        if (!getMappingAuth(account)) {
            if (size == 0 && tx.origin == account) {
                checkSecurityReturn = true;
            } else {
                require(false,"Verificacao de seguranca nao aprovada");
            }
        } else {
            checkSecurityReturn = true;
        }
        return checkSecurityReturn;
    }

    //Obtém informações específicas de farmers
    function getArrays () public view returns
        (address[] memory, address[] memory, uint256[] memory) {
        
        return (
            allAddressStaking,
            allAddressFarmer,
            allFarmerIDs
        );
    }


    //Obtém informações específicas de stakers e informaçõe gerais
    function getInfosStaking(
        address staker,
        uint256 whatsRwardsToClaim) public view returns
        (uint256, uint256, uint256, uint256, uint256, uint256) {
            
        uint256 amountTokens;
        uint256 amountTokensInicial;
        uint256 startStaking;
        uint256 totalClaimed;
        uint256 lastTimeClaim;
        uint256 whatsLastBalance;

        startStaking = mappingStakingInfos[staker].startStaking;
        amountTokens = mappingStakingInfos[staker].amountTokens;
        amountTokensInicial = mappingStakingInfos[staker].amountTokensInicial;

        if (whatsRwardsToClaim == 1) {
            totalClaimed = mappingClaimStakingInfos[staker].totalRayonsClaimed;
            lastTimeClaim = mappingClaimStakingInfos[staker].lastTimeClaimRayons;
            whatsLastBalance = mappingRewardsEarnStaking[staker].whatsLastBalanceRayonsContract;

        //BUSD    
        } else if (whatsRwardsToClaim == 2) {
            totalClaimed = mappingClaimStakingInfos[staker].totalBUSDClaimed;
            lastTimeClaim = mappingClaimStakingInfos[staker].lastTimeClaimBUSD;
            whatsLastBalance = mappingRewardsEarnStaking[staker].whatsLastBalanceBUSDContract;

        }
        return (
            amountTokensInicial,
            amountTokens,
            startStaking,
            totalClaimed,
            lastTimeClaim,
            whatsLastBalance);
    }


    //Obtém informações específicas de farmers
    function getInfosFarm(
        address farmer,
        uint256 whatsRwardsToClaim) public view returns
        (uint256, uint256, uint256) {
        
        uint256 totalClaimed;
        uint256 lastTimeClaim;
        uint256 whatsLastBalance;

        //RYS
        if (whatsRwardsToClaim == 1) {

            totalClaimed = mappingClaimFarmInfos[farmer].totalRayonsClaimed;
            lastTimeClaim = mappingClaimFarmInfos[farmer].lastTimeClaimRayons;
            whatsLastBalance = mappingRewardsEarnFarm[farmer].whatsLastBalanceRayonsContract;
        
        //BUSD
        } else if (whatsRwardsToClaim == 2) {
            totalClaimed = mappingClaimFarmInfos[farmer].totalBUSDClaimed;
            lastTimeClaim = mappingClaimFarmInfos[farmer].lastTimeClaimBUSD;
            whatsLastBalance = mappingRewardsEarnFarm[farmer].whatsLastBalanceBUSDContract;

        }

        return (
            totalClaimed, 
            lastTimeClaim, 
            whatsLastBalance
            );

    }

    //Obtém informações específicas de farmers
    function getInfosFarmArrays (
        address farmer) public view returns
        (uint256[] memory, uint256[] memory, uint256[] memory, uint256[] memory) {
        
        return (
            mappingFarmInfos[farmer].amountBoost,
            mappingFarmInfos[farmer].startStaking,
            mappingFarmInfos[farmer].ID,
            mappingFarmInfos[farmer].rarity
            );
            
    }

    function getPriceUSD(uint256 amountIn) public view returns (uint256) {

        uint256 retorno;
        if (amountIn != 0) {
            address[] memory path = new address[](3);
            path[0] = addressRYS;
            path[1] = addressWBNB;
            path[2] = addressBUSD;

            uint256[] memory amountOutMins = IUniswapV2Router(addressPCVS2)
            .getAmountsOut(amountIn, path);
            retorno = amountOutMins[path.length -1];
        }
        return retorno;
    } 


    //valor total bloqueado na pool de stakes. Retonar a quantidade de tokens e seu valor em dólars
    //Total Value Locked
    function TVL_staking() public view returns (uint256,uint256) {
        uint256 amountTokensInStaking_USD = getPriceUSD(amountTokensInStaking);
        return (amountTokensInStaking,amountTokensInStaking_USD);
    }

    //valor total bloqueado na pool de farm. Retonar a quantidade de tokens e seu valor em dólars
    //Total Value Locked
    function TVL_farm() public view returns (uint256,uint256) {
        uint256 amountTokensInFarm_USD = getPriceUSD(amountTokensInFarm);
        return (amountTokensInFarm,amountTokensInFarm_USD);
    }

    function APR_staking (uint256 whatsClaim) public view returns (
        //o APR retorna em porcetagem multiplicada por 10 ** 4 
        uint256 APR_Weeks, uint256 APR_balanceOf, uint256 APR_historic, 
        uint256 APR_historic_2, uint256 APR_historic_3) {

        if (whatsClaim == 1) {
            if (amountTokensInStaking == 0 || amountTokensWasStaked == 0) return (0,0,0,0,0);
            APR_Weeks = lastDepositRayonsToStakingPool * 10 ** 6 / amountTokensInStaking;
            APR_balanceOf = IERC20(addressRYS).balanceOf(address(this)) * 10 ** 6 / amountTokensInStaking;
            //simula os ganhos do APR caso o staker tivesse investido e até o momento não retirado suas apostas
            APR_historic = depositRayonsToStakingPool * 10 ** 6 / amountTokensInStaking;
            APR_historic_2 = depositRayonsToStakingPool * 10 ** 6 / amountTokensWasStaked;
            APR_historic_3 = ((depositRayonsToStakingPool * 10 ** 6 / getSecondsPassed()) * 365) / amountTokensWasStaked;

        } else if (whatsClaim == 2) {
            uint256 amountTokensInStaking_USD = getPriceUSD(amountTokensInStaking);
            uint256 amountTokensWasStakingd_USD = getPriceUSD(amountTokensWasStaked);

            if (amountTokensInStaking_USD == 0 || amountTokensWasStakingd_USD == 0) return (0,0,0,0,0);
            APR_Weeks = lastDepositBUSDtoStakingPool * 10 ** 6 / amountTokensInStaking_USD;
            APR_balanceOf = IERC20(addressBUSD).balanceOf(address(this)) * 10 ** 6 / amountTokensInStaking_USD;
            //simula os ganhos do APR caso o staker tivesse investido e até o momento não retirado suas apostas
            APR_historic = depositBUSDToStakingPool * 10 ** 6 / amountTokensInStaking_USD;
            APR_historic_2 = depositBUSDToStakingPool * 10 ** 6 / amountTokensWasStakingd_USD;
            APR_historic_3 = ((depositBUSDToStakingPool * 10 ** 6 / getSecondsPassed()) * 365) / amountTokensWasStakingd_USD;

        }
    }


    function APR_farm (uint256 whatsClaim) public view returns (
        //o APR retorna em porcetagem multiplicada por 10 ** 4 
        uint256 APR_Weeks, uint256 APR_balanceOf, uint256 APR_historic, 
        uint256 APR_historic_2, uint256 APR_historic_3) {

        if (whatsClaim == 1) {
            if (amountTokensInFarm == 0 || amountTokensWasFarmed == 0) return (0,0,0,0,0);
            APR_Weeks = lastDepositRayonsToFarm * 10 ** 6 / amountTokensInFarm;
            APR_balanceOf = IERC20(addressRYS).balanceOf(address(this)) * 10 ** 6 / amountTokensInFarm;
            //simula os ganhos do APR caso o staker tivesse investido e até o momento não retirado suas apostas
            APR_historic = depositRayonsToFarm * 10 ** 6 / amountTokensInFarm;
            APR_historic_2 = depositRayonsToFarm * 10 ** 6 / amountTokensWasFarmed;
            APR_historic_3 = ((depositRayonsToFarm * 10 ** 6 / getSecondsPassed()) * 365) / amountTokensWasFarmed;

        } else if (whatsClaim == 2) {
            uint256 amountTokensInFarm_USD = getPriceUSD(amountTokensInFarm);
            uint256 amountTokensWasFarmed_USD = getPriceUSD(amountTokensWasFarmed);
            if (amountTokensInFarm_USD == 0 || amountTokensWasFarmed_USD == 0) return (0,0,0,0,0);

            APR_Weeks = lastDepositBUSDtoFarm * 10 ** 6 / amountTokensInFarm_USD;
            APR_balanceOf = IERC20(addressBUSD).balanceOf(address(this)) / amountTokensInFarm_USD;
            //simula os ganhos do APR caso o staker tivesse investido e até o momento não retirado suas apostas
            APR_historic = depositBUSDToStakingPool * 10 ** 6 / amountTokensInFarm_USD;
            APR_historic_2 = depositBUSDToStakingPool * 10 ** 6 / amountTokensWasFarmed_USD;
            APR_historic_3 = ((depositBUSDToStakingPool * 10 ** 6 / getSecondsPassed()) * 365) / amountTokensWasFarmed_USD;

        }
    }


    function getRayonsToPayStaking() public view returns (uint256 rayonsToPayStaking) {

        uint256 lastRYStoDistribute;
        if (block.timestamp < timeLastDepositRayonsToStakingPool + 1 days) {
            lastRYStoDistribute = lastDepositRayonsToStakingPool * 15 / 100;
        } else if (block.timestamp < timeLastDepositRayonsToStakingPool + 2 days) {
            lastRYStoDistribute = lastDepositRayonsToStakingPool * 30 /100;
        } else if (block.timestamp < timeLastDepositRayonsToStakingPool + 3 days) {
            lastRYStoDistribute = lastDepositRayonsToStakingPool * 45 /100;
        } else if (block.timestamp < timeLastDepositRayonsToStakingPool + 4 days) {
            lastRYStoDistribute = lastDepositRayonsToStakingPool * 60 /100;
        } else if (block.timestamp < timeLastDepositRayonsToStakingPool + 5 days) {
            lastRYStoDistribute = lastDepositRayonsToStakingPool * 75 /100;
        } else if (block.timestamp < timeLastDepositRayonsToStakingPool + 6 days) {
            lastRYStoDistribute = lastDepositRayonsToStakingPool * 90 /100;
        } else if (block.timestamp >= timeLastDepositRayonsToStakingPool + 6 days) {
            lastRYStoDistribute = lastDepositRayonsToStakingPool;
        } 

        rayonsToPayStaking = depositRayonsToStakingPool - lastDepositRayonsToStakingPool + lastRYStoDistribute;
        return rayonsToPayStaking;
    }


    //retorno percentual
    function increaseFactorNFT_StakingPool(
        address staker) 
        public view returns 
        (uint256 sumBoost) {

        uint256 i;
        uint256 length = getFetchMyNfts(staker).length;
        for(i; i < length; i++) {
            sumBoost += getBoostFetchMyNfts(staker,i);
        }

        uint256 rarity5_balanceOf = IRayonsNFTnew_interface(addressRayonsNFTnew).balanceOf(staker);

        sumBoost = (sumBoost + rarity5_balanceOf * 5) * 10 ** 3;

        if (1 < i || 1 < rarity5_balanceOf) {
            //denominatorIncreaseFactor setado como 15, ou seja, 1,5 * 10 ** 1
            sumBoost = sumBoost * 10 ** 1 / denominatorIncreaseFactor;
        }
        return sumBoost;
    }


    function getUnpaidEarningStaking(
        address staker,
        uint256 whatsRwardsToClaim)
        public 
        view 
        returns 
        (uint256) {

        uint256 amountRewardClaim;
        uint256 amountTokens;
        uint256 whatsLastBalance;

        (,amountTokens,,,,whatsLastBalance)
        = getInfosStaking(staker,whatsRwardsToClaim);

        if (amountTokensInStaking == 0) return (0);

        //multiplicação por 10 ** 6 para evitar resultado zero
        uint256 percentTokens = (amountTokens.mul(10 ** 6)).div(amountTokensInStaking);

        //RYS
        if (whatsRwardsToClaim == 1) {
            uint256 increaseFactor = increaseFactorNFT_StakingPool(staker);
            uint256 rayonsToPay = getRayonsToPayStaking();

            //checkagem necessária, pois o increaseFactor pode extrapolar o saldo depositado para pagamento
            if (whatsLastBalance < rayonsToPay) {
                //increaseFactor retorna multiplicado por 10 **3
                if (rayonsToPay > amountRayonsClaimedStakingPool) {
                    amountRewardClaim = (rayonsToPay - amountRayonsClaimedStakingPool)
                    .mul(percentTokens).mul(10 ** 5 + increaseFactor).div(10 ** 5).div(10 ** 6);

                    if (rayonsToPay < amountRayonsClaimedStakingPool + amountRewardClaim)
                    //sem overflow, pois já asseguramos que rayonsToPay > amountRayonsClaimedStakingPool
                    amountRewardClaim = rayonsToPay - amountRayonsClaimedStakingPool;
                } else {
                    amountRewardClaim = 0;

                } 
            }

        //BUSD    
        } else if (whatsRwardsToClaim == 2) {
            amountRewardClaim = (depositBUSDToStakingPool - whatsLastBalance)
            .mul(percentTokens).div(10 ** 6);

            if (amountBUSDclaimedStakingPool > depositBUSDToStakingPool) amountRewardClaim = 0;
            if (amountBUSDclaimedStakingPool + amountRewardClaim > depositBUSDToStakingPool) 
            amountRewardClaim = depositBUSDToStakingPool - amountBUSDclaimedStakingPool;
        }

        return amountRewardClaim;  
    }


    function getUnpaidEarningFarm_Total(address farmer, uint256 whatsRwardsToClaim)
        public 
        view 
        returns 
        (uint256 amountRewardClaim) {

        uint256 length = mappingFarmInfos[farmer].ID.length;

        for (uint256 index; index < length; index++) {
            amountRewardClaim += getUnpaidEarningFarm(farmer,index,whatsRwardsToClaim);
        }

        if (whatsRwardsToClaim == 1) {
            if (amountRayonsClaimedFarmNFT > depositRayonsToFarm) amountRewardClaim = 0;
            if (amountRayonsClaimedFarmNFT + amountRewardClaim > depositRayonsToFarm) 
            amountRewardClaim = depositRayonsToFarm - amountRayonsClaimedFarmNFT;
        } else {
            if (amountBUSDclaimedFarmNFT > depositBUSDtoFarm) amountRewardClaim = 0;
            if (amountBUSDclaimedFarmNFT + amountRewardClaim > depositBUSDtoFarm) 
            amountRewardClaim = depositBUSDtoFarm - amountBUSDclaimedFarmNFT;
        }
        return amountRewardClaim;
    }


    function getUnpaidEarningFarm(
        address farmer,
        uint256 index,
        uint256 whatsRwardsToClaim)
        public 
        view 
        returns 
        (uint256 amountRewardClaim) {

        if (amountTokensInFarm == 0) return (0);

        uint256 whatsLastBalance;
        uint256 amountBoost = mappingFarmInfos[farmer].amountBoost[index];
        uint256 percentTokens = (amountBoost.mul(10**6)).div(amountTokensInFarm);

        //RYS
        if (whatsRwardsToClaim == 1) {
            (,,whatsLastBalance) = 
            getInfosFarm(farmer,whatsRwardsToClaim);

            amountRewardClaim = (depositRayonsToFarm - whatsLastBalance)
            .mul(percentTokens).div(10**6);

        //BUSD    
        } else if (whatsRwardsToClaim == 2) {
            (,,whatsLastBalance) = 
            getInfosFarm(farmer,whatsRwardsToClaim);

            amountRewardClaim = (depositBUSDtoFarm - whatsLastBalance)
            .mul(percentTokens).div(10**6);

        }
    }


    function getUnpaidEarningFarm_atualizeOwners(
        uint256 unpaidEarning, 
        uint256 whatsRwardsToClaim)
        public 
        view 
        returns 
        (uint256 amountRewardClaim) {

        amountRewardClaim = unpaidEarning;

        if (whatsRwardsToClaim == 1) {
            if (amountRayonsClaimedFarmNFT > depositRayonsToFarm) amountRewardClaim = 0;
            if (amountRayonsClaimedFarmNFT + amountRewardClaim > depositRayonsToFarm) 
            amountRewardClaim = depositRayonsToFarm - amountRayonsClaimedFarmNFT;
        } else {
            if (amountBUSDclaimedFarmNFT > depositBUSDtoFarm) amountRewardClaim = 0;
            if (amountBUSDclaimedFarmNFT + amountRewardClaim > depositBUSDtoFarm) 
            amountRewardClaim = depositBUSDtoFarm - amountBUSDclaimedFarmNFT;
        }
        return amountRewardClaim;
    }


    function getFetchMyNfts(address staker) 
        public 
        view
        returns (IRayonsNFTold_interface.Data[] memory _data) {

        _data = IRayonsNFTold_interface(addressRayonsNFTold).fetchMyNfts(staker);

        return _data;
    }

    function getBoostFetchMyNfts(address staker, uint256 i) 
        public 
        view
        returns (uint256) {

        IRayonsNFTold_interface.Data[] memory _data;
        _data = IRayonsNFTold_interface(addressRayonsNFTold).fetchMyNfts(staker);

        return _data[i].boost;
    }

    function getIDFetchMyNfts(address staker, uint256 i) 
        public 
        view
        returns (uint256) {

        IRayonsNFTold_interface.Data[] memory _data;
        _data = IRayonsNFTold_interface(addressRayonsNFTold).fetchMyNfts(staker);

        return _data[i].idNumber;
    }

    function getData(uint256 ID) public view returns (
        address ownerNFT,
        uint256 rarity,
        uint256 amountBoost) {

        (ownerNFT,,,rarity,,amountBoost,,,) =
        IRayonsNFTold_interface(addressRayonsNFTold).data(ID);

    }
    

    //isAlowedClaimStakingAndRewards retorna se pode sair do staking
    //isAlowedClaimRewardsRayons retorna se pode  retirar os tokens RYS do staking
    //isAlowedClaimRewardsBUSD retorna se pode retirar os BUSD do staking
    function isAllowedClaim_Staking (address staker) public view returns (
        bool isAlowedClaimStakingAndRewards, 
        bool isAlowedClaimRewardsRayons, 
        bool isAlowedClaimRewardsBUSD) {
        
        uint256 startStaking;
        uint256 lastTimeClaim;

        (,,startStaking,,,)
        = getInfosStaking(staker, 0);

        //isAlowedClaimStakingAndRewards
        if (startStaking + timeToWithdrawStaking <= block.timestamp && startStaking != 0) {
            isAlowedClaimStakingAndRewards = true;
        }

        (,,,,lastTimeClaim,)
        = getInfosStaking(staker, 1);
        //isAlowedClaimRewardsRayons
        if (lastTimeClaim + timeClaimRayonsStaking <= block.timestamp && startStaking != 0) {
            isAlowedClaimRewardsRayons = true;
        }

        (,,,,lastTimeClaim,)
        = getInfosStaking(staker, 2);
        //isAlowedClaimRewardsBUSD
        if (lastTimeClaim + timeClaimBUSDstaking <= block.timestamp && startStaking != 0) {
            isAlowedClaimRewardsBUSD = true;
        }
    }



    function isAllowedToHarvest_Farm(address farmer, uint256 whatsRwardsToClaim) 
    public view returns (bool) {

        bool isAllowedToHarvest = false;

        uint256 index;
        uint256 indexRarity;
        uint256 length = mappingFarmInfos[farmer].ID.length;
        uint256 startStaking;

        uint256 rarity;
        uint256 lastRarity = 5;
        for(index; index < length; index++) {
            rarity = mappingFarmInfos[farmer].rarity[index];
            if (lastRarity > rarity) {
                lastRarity = rarity;
                indexRarity = index;
            }
        }

        uint256 time;
        if (whatsRwardsToClaim == 1) time = timeLastDepositRayonsToFarm;
        if (whatsRwardsToClaim == 2) time = timeLastDepositBUSDtoFarm;

        (,uint256 lastTimeClaim,) = getInfosFarm(farmer,whatsRwardsToClaim);

        //obtendo o startStaking da raridade específica
        startStaking = mappingFarmInfos[farmer].startStaking[indexRarity];

        time = time < startStaking ? startStaking : time;

        time = time < lastTimeClaim ? lastTimeClaim : time;

        if (lastRarity == 1 && time + 30 days < block.timestamp) {
            isAllowedToHarvest = true;
        }

        if (lastRarity == 2 && time + 35 days < block.timestamp) {
            isAllowedToHarvest = true;
        }

        if (lastRarity == 3 && time + 40 days < block.timestamp) {
            isAllowedToHarvest = true;
        }
        
        if (lastRarity == 4 && time + 45 days < block.timestamp) {
            isAllowedToHarvest = true;
        }

        //parece que rarity IMPREVISIVELMENTE as vezes retorna zero
        if (lastRarity == 0 && time + 50 days < block.timestamp) {
            isAllowedToHarvest = true;
        }

        return isAllowedToHarvest;
    }

    //encotrar se uma ID já está farmada
    function findID(address farmer, uint256 ID) 
    public view returns (bool found) {

        found = false;

        uint256 index;
        uint256 length = mappingFarmInfos[farmer].ID.length;
        for(index; index < length; index++) {
            if (ID == mappingFarmInfos[farmer].ID[index]) {
                //compilador solidity exige um retorno explícito 
                found = true;
                //redundância necessária pra evitar que o código continue a percorrer o array
                //mesmo após ter encontrato o resultado, o que gastaria mais gás
                return true;
            }
        }

        return found;
    }


    //Na transferência de NFT e saída do farm deletamos todas entradas dos arrays dos IDs 
    //farmados para evitar problemas nas leituras
    //referente ao bug do contrato old de NFT
    //função implementada mas não utilizada
    //Se o contrato Old de NFT for corrigida pode ser utilizada
    function removeAllElementsOnArray(address farmer) internal {

        uint256 index;
        uint256 length = 10;
        for(index; index < length; index++) {

            delete mappingFarmInfos[farmer].ID[index];
        }
    }



    //O farm a princípio iria transferir as NFTs do farmer para uma wallet do projeto
    //Para isso o usuário deveria enviar uma transação para permitir que este contrato retire as NFTs da conta do Farmer
    //A transação seria setApprovalForAll(address(this), true)
    function farmAllNFTs(
        address farmer)
        external {
        require(getFetchMyNfts(farmer).length >= 1, "Sem NFTs para farmar");

        uint256 ID;
        uint256 i;
        uint256 length = getFetchMyNfts(farmer).length;
        for (i; i < length; i++) {
            ID = getIDFetchMyNfts(farmer,i);
            farmFTs(farmer,ID);
        }

        if (boolCountFarmers) totalFarmers ++;  
        boolCountFarmers = false;
    }


    //O farm a princípio iria transferir as NFTs do farmer para uma wallet do projeto
    //Para isso o usuário deveria enviar uma transação para permitir que este contrato retire as NFTs da conta do Farmer
    //A transação seria setApprovalForAll(address(this), true)
    function farmFTs(
        address farmer,
        uint256 ID)
        public 
        whenNotPaused() 
        nonReentrant() {

        require(timeOpenPoolsStaking != 0, "As pools de staking ainda nao estao abertas");
        require(farmer == _msgSender() || getMappingAuth(_msgSender()), "Nao aprovado");
        require(getFetchMyNfts(farmer).length >= 1, "Sem NFTs para farmar");

        if (checkSecurityActived) {
            require(checkSecurity(_msgSender()), "Verificacao nao aprovada!");
        }

        address ownerNFT;
        uint256 rarity;
        uint256 amountBoost;

        (ownerNFT,rarity,amountBoost) = getData(ID);
        require(_msgSender() == ownerNFT, "Nao e o detentor da NFT");


        if (!findID(farmer,ID)) {
            boolCountFarmers = true;

            //Toda NFT do contrato old emite somente 1 NFT para cada ID. Vide as chamadas para _mint
            //Todas são _mint(_msgSender(), newID, 1, "" )

            //IRayonsNFTold_interface(addressRayonsNFTold).
            //safeTransferFrom(farmer, addressRayonsADMIN, ID, 1, "");
        
            mappingFarmInfos[farmer].startStaking.push(block.timestamp);
            mappingFarmInfos[farmer].amountBoost.push(amountBoost);
            mappingFarmInfos[farmer].ID.push(ID);
            mappingFarmInfos[farmer].rarity.push(rarity);

            mappingClaimFarmInfos[farmer].lastTimeClaimRayons = block.timestamp;
            mappingClaimFarmInfos[farmer].lastTimeClaimBUSD = block.timestamp;

            totalFarmMade ++;
            allAddressFarmer.push(farmer);
            allFarmerIDs.push(ID);
            amountTokensInFarm += amountBoost;
            amountTokensWasFarmed += amountBoost;
            boolCountFarmers = true;

            emit farmNFTevent(
                farmer, 
                amountBoost, 
                msg.sender);

        }
    }


    //o claim é liberado conforme o prazo de conheita
    //caso o prazo de colheita ainda não tenha sido liberado então a conta receberá zero rewards
    function claimRewardsFarm(
        address farmer) 
        external 
        whenNotPaused() 
        nonReentrant() {

        require(farmer == _msgSender() || getMappingAuth(_msgSender()), "Nao aprovado");

        if (checkSecurityActived) {
            require(checkSecurity(_msgSender()), "Verificacao nao aprovada");
        }

        uint256 getUnpaidEarningFarm_Total_Rayons = getUnpaidEarningFarm_Total(farmer,1);
        uint256 getUnpaidEarningFarm_Total_BUSD = getUnpaidEarningFarm_Total(farmer,2);

        //buscar os ganhos através de getUnpaidEarningFarm iterando todo array de IDS 
        //custa menos gás do que
        //buscar por getUnpaidEarningFarm_Total, porém está mais de acordo com o padrão MVC
        if (isAllowedToHarvest_Farm(farmer,1) && getUnpaidEarningFarm_Total_Rayons > 0) {

            mappingClaimFarmInfos[farmer].totalRayonsClaimed += getUnpaidEarningFarm_Total_Rayons;
            mappingClaimFarmInfos[farmer].lastTimeClaimRayons = block.timestamp;
            mappingRewardsEarnFarm[farmer].whatsLastBalanceRayonsContract = depositRayonsToFarm;

            IERC20(addressRYS).transfer(farmer, getUnpaidEarningFarm_Total_Rayons); 

            amountRayonsClaimedFarmNFT += getUnpaidEarningFarm_Total_Rayons;
        }

        //buscar os ganhos através de getUnpaidEarningFarm iterando o array de IDS 
        //custa menos gás do que
        //buscar por getUnpaidEarningFarm_Total, porém está mais de acordo com o padrão MVC
        if (isAllowedToHarvest_Farm(farmer,2) && getUnpaidEarningFarm_Total_BUSD > 0) {

            mappingClaimFarmInfos[farmer].totalBUSDClaimed += getUnpaidEarningFarm_Total_BUSD;
            mappingClaimFarmInfos[farmer].lastTimeClaimBUSD = block.timestamp;
            mappingRewardsEarnFarm[farmer].whatsLastBalanceBUSDContract = depositBUSDtoFarm;

            IERC20(addressBUSD).transfer(farmer, getUnpaidEarningFarm_Total_BUSD); 

            amountBUSDclaimedFarmNFT += getUnpaidEarningFarm_Total_BUSD;
        }

        emit claimRewardsFarmEvent(
            farmer,
            getUnpaidEarningFarm_Total_Rayons,
            getUnpaidEarningFarm_Total_BUSD,
            msg.sender);

    }

    function claimRewardsAndNFTsFarm(
        address farmer) 
        public 
        whenNotPaused() 
        nonReentrant() {

        require(farmer == _msgSender() || getMappingAuth(_msgSender()), "Nao aprovado");

        if (checkSecurityActived) {
            require(checkSecurity(_msgSender()), "Verificacao nao aprovada!");
        }

        uint256 amountBoost;

        if (!getMappingAuth(_msgSender())) {
            require(isAllowedToHarvest_Farm(farmer,1) && 
                    isAllowedToHarvest_Farm(farmer,2),  "Antes do prazo da colheita");
        }

        uint256 getUnpaidEarningFarm_Total_Rayons = getUnpaidEarningFarm_Total(farmer,1);
        uint256 getUnpaidEarningFarm_Total_BUSD = getUnpaidEarningFarm_Total(farmer,2);

        uint256 length = mappingFarmInfos[farmer].ID.length;

        for (uint256 index; index < length; index ++) {

            //ID = mappingFarmInfos[farmer].ID[index];
            amountBoost = mappingFarmInfos[farmer].amountBoost[index];

            //gambiarra necessária para contornar os erros e execução nas transferências do contrato 
            //old de NFT
            //o normal e o correto seria não zerar as infos do Farmer 
            //removeAllElementsOnArray(farmer);

            //gambiarra necessária para contornar os erros e execução nas transferências de NFTs 
            //o normal e o correto seria não zerar as infos do Farmer 
            mappingFarmInfos[farmer].amountBoost[index] = 0;
            mappingFarmInfos[farmer].startStaking[index] = 0;
            mappingFarmInfos[farmer].ID[index] = 0;
            mappingFarmInfos[farmer].rarity[index] = 0;

            //IRayonsNFTold_interface(addressRayonsNFTold).
            //safeTransferFrom(addressRayonsADMIN, farmer, ID, 1, "");

            amountTokensInFarm -= amountBoost;
        }

        mappingClaimFarmInfos[farmer].totalRayonsClaimed += getUnpaidEarningFarm_Total_Rayons;
        mappingClaimFarmInfos[farmer].lastTimeClaimRayons = block.timestamp;
        mappingRewardsEarnFarm[farmer].whatsLastBalanceRayonsContract = depositRayonsToFarm;

        mappingClaimFarmInfos[farmer].totalBUSDClaimed += getUnpaidEarningFarm_Total_BUSD;
        mappingClaimFarmInfos[farmer].lastTimeClaimBUSD = block.timestamp;
        mappingRewardsEarnFarm[farmer].whatsLastBalanceBUSDContract = depositBUSDtoFarm;

        IERC20(addressRYS).transfer(farmer, getUnpaidEarningFarm_Total_Rayons); 
        IERC20(addressBUSD).transfer(farmer, getUnpaidEarningFarm_Total_BUSD); 

        amountRayonsClaimedFarmNFT += getUnpaidEarningFarm_Total_Rayons;
        amountBUSDclaimedFarmNFT += getUnpaidEarningFarm_Total_BUSD;

        emit claimRewardsAndNFTsFarmEvent(
            farmer,
            amountBoost,
            getUnpaidEarningFarm_Total_Rayons,
            getUnpaidEarningFarm_Total_BUSD,
            msg.sender);

    }

    //staking tokens
    function stakingTokens(
        address staker,
        uint256 amountTokens)
        external 
        whenNotPaused() 
        nonReentrant() {

        require(staker == _msgSender() || getMappingAuth(_msgSender()), "Nao aprovado");
        require(timeOpenPoolsStaking != 0, "As pools de staking ainda nao estao abertas");
        require(IERC20(addressRYS).balanceOf(staker) > amountTokens, "Voce nao possui RYS suficiente");

        if (checkSecurityActived) {
            require(checkSecurity(_msgSender()), "Verificacao nao aprovada!");
        }

        IERC20(addressRYS).transferFrom(staker, address(this), amountTokens);

        mappingStakingInfos[staker].amountTokensInicial += amountTokens;
        mappingStakingInfos[staker].amountTokens += amountTokens;
        mappingStakingInfos[staker].startStaking = block.timestamp;

        mappingClaimStakingInfos[staker].lastTimeClaimRayons = block.timestamp;
        mappingClaimStakingInfos[staker].lastTimeClaimBUSD = block.timestamp;

        totalStakingMade ++;
        totalStakingOn ++;
        allAddressStaking.push(staker);
        amountTokensInStaking += amountTokens;
        amountTokensWasStaked += amountTokens;

        emit stakingEvent(
            staker, 
            amountTokens, 
            msg.sender);
    }


    function reinvestRewardsTokensStaking(
        address staker)
        external 
        whenNotPaused() 
        nonReentrant() {

        require(staker == _msgSender() || getMappingAuth(_msgSender()), "Nao aprovado");

        if (checkSecurityActived) {
            require(checkSecurity(_msgSender()), "Verificacao nao aprovada!");
        }

        uint256 amountTokens;
        uint256 startStaking;
        uint256 lastTimeClaim;

        (,amountTokens,startStaking,,lastTimeClaim,)
        = getInfosStaking(staker, 1);

        require(amountTokens > 0, "Voce nao tem stakes e ganhos para reinvestir");

        //Antes do prazo para reinvest
        if (block.timestamp < startStaking + timeClaimRayonsStaking ||
            block.timestamp < lastTimeClaim + timeClaimRayonsStaking) return;

        uint256 calculateUnpaidEarningsRayons = getUnpaidEarningStaking(staker,1);

        if (calculateUnpaidEarningsRayons != 0) {
        
            //Se um staker já reinvestiu os ganhos é possível que o amount tokens 
            //dele chegue a superar o saldo do contrato
            //Porém, todas verificações de limites de disponibilidades são assetivamente feitas
            //O que evita a possibilidade de ter saldo maior que o disponível ou de se apropriar
            //dos tokens de outros stakers
            mappingStakingInfos[staker].amountTokens += calculateUnpaidEarningsRayons;
            mappingStakingInfos[staker].startStaking = block.timestamp;
            mappingClaimStakingInfos[staker].totalRayonsClaimed += calculateUnpaidEarningsRayons;
            mappingRewardsEarnStaking[staker].whatsLastBalanceRayonsContract = getRayonsToPayStaking();
            mappingClaimStakingInfos[staker].lastTimeClaimRayons = block.timestamp;

            amountRayonsClaimedStakingPool += calculateUnpaidEarningsRayons;
            amountTokensInStaking += calculateUnpaidEarningsRayons;

            emit autoReinvestEvent(
                staker,
                calculateUnpaidEarningsRayons,
                msg.sender);

        }
    }

    function claimRewardsStaking(
        address staker)
        external 
        whenNotPaused() 
        nonReentrant() {

        require(staker == _msgSender() || getMappingAuth(_msgSender()), "Nao aprovado");

        if (checkSecurityActived) {
            require(checkSecurity(_msgSender()), "Verificacao nao aprovada!");
        }

        uint256 amountTokens;
        uint256 startStaking;
        uint256 lastTimeClaim;

        (,amountTokens,startStaking,,lastTimeClaim,)
        = getInfosStaking(staker, 0);

        require(amountTokens > 0, "Voce nao tem stakes e ganhos para retirar");
        if (block.timestamp < startStaking + timeToWithdrawStaking) return;
        uint256 calculateUnpaidEarningsRYS;
        uint256 calculateUnpaidEarningsBUSD;

        //RYS
        if (lastTimeClaim + timeClaimRayonsStaking < block.timestamp) {
            calculateUnpaidEarningsRYS = getUnpaidEarningStaking(staker,1);

            mappingClaimStakingInfos[staker].totalRayonsClaimed += calculateUnpaidEarningsRYS;
            mappingRewardsEarnStaking[staker].whatsLastBalanceRayonsContract = getRayonsToPayStaking();
            mappingClaimStakingInfos[staker].lastTimeClaimRayons = block.timestamp;

            IERC20(addressRYS).transfer(staker, calculateUnpaidEarningsRYS); 
            amountRayonsClaimedStakingPool += calculateUnpaidEarningsRYS;
        }

        //BUSD    
        if (lastTimeClaim + timeClaimBUSDstaking < block.timestamp) {
            calculateUnpaidEarningsBUSD = getUnpaidEarningStaking(staker,2);

            mappingClaimStakingInfos[staker].totalBUSDClaimed += calculateUnpaidEarningsBUSD;
            mappingRewardsEarnStaking[staker].whatsLastBalanceBUSDContract = depositBUSDToStakingPool;
            mappingClaimStakingInfos[staker].lastTimeClaimBUSD = block.timestamp;

            IERC20(addressBUSD).transfer(staker, calculateUnpaidEarningsBUSD); 
            amountBUSDclaimedStakingPool += calculateUnpaidEarningsBUSD;
        }

        emit claimStakingEvent(
            staker,
            amountTokens,
            calculateUnpaidEarningsRYS,
            calculateUnpaidEarningsBUSD,
            msg.sender);
    }

    function claimRewardsAndRayonsStaking(
        address staker)
        public 
        whenNotPaused() 
        nonReentrant() {

        require(staker == _msgSender() || getMappingAuth(_msgSender()), "Nao aprovado");

        if (checkSecurityActived) {
            require(checkSecurity(_msgSender()), "Verificacao nao aprovada!");
        }

        uint256 amountTokens;
        uint256 startStaking;
        uint256 lastTimeClaim;

        (,amountTokens,startStaking,,lastTimeClaim,)
        = getInfosStaking(staker, 0);

        (bool isAlowedClaimStakingAndRewards,bool isAlowedClaimRewardsRayons,bool isAlowedClaimRewardsBUSD) = 
        isAllowedClaim_Staking(staker);

        if (!getMappingAuth(_msgSender())) {
            require(amountTokens > 0, "Voce nao tem stakes e ganhos para retirar");

            require(isAlowedClaimStakingAndRewards, "Prazo minimo para saque do staking");
            require(isAlowedClaimRewardsRayons, "Prazo minimo de claim de RYS andamento");
            require(isAlowedClaimRewardsBUSD, "Prazo minimo de claim de BUSD andamento");

        }

        IERC20(addressRYS).transfer(staker, amountTokens); 

        uint256 calculateUnpaidEarningsRayons = getUnpaidEarningStaking(staker,1);
        uint256 calculateUnpaidEarningsBUSD = getUnpaidEarningStaking(staker,2);

        IERC20(addressRYS).transfer(staker, calculateUnpaidEarningsRayons); 
        IERC20(addressBUSD).transfer(staker, calculateUnpaidEarningsBUSD); 

        mappingStakingInfos[staker].amountTokens = 0;

        mappingClaimStakingInfos[staker].totalRayonsClaimed += calculateUnpaidEarningsRayons;
        mappingRewardsEarnStaking[staker].whatsLastBalanceRayonsContract = getRayonsToPayStaking();
        mappingClaimStakingInfos[staker].lastTimeClaimRayons = block.timestamp;

        mappingClaimStakingInfos[staker].totalBUSDClaimed += calculateUnpaidEarningsBUSD;
        mappingRewardsEarnStaking[staker].whatsLastBalanceBUSDContract = depositBUSDToStakingPool;
        mappingClaimStakingInfos[staker].lastTimeClaimBUSD = block.timestamp;

        amountRayonsClaimedStakingPool += calculateUnpaidEarningsRayons;
        amountBUSDclaimedStakingPool += calculateUnpaidEarningsBUSD;
        
        totalStakingOn --;
        amountTokensInStaking -= amountTokens;

        emit claimStakingEvent(
            staker,
            amountTokens,
            calculateUnpaidEarningsRayons,
            calculateUnpaidEarningsBUSD,
            msg.sender);
    }

    //Função chamada para abrir as interações com o contrato
    function setOpenPoolStaking() external onlyOwner {
        require(settedTimeOpenPoolStaking == false);
        settedTimeOpenPoolStaking = true;
        timeOpenPoolsStaking = block.timestamp;
    }

    //Consultar i++ dessa forma ajuda a economizar gás
    function uncheckedI (uint256 i) private pure returns (uint256) {
        unchecked { return i + 1; }
    }


    /*
        Como não usamos safeTransferFrom para transferir as NFTs dos farmers,
        é possível que o farmer chegue a vender suas NFTs em algum momento
        Por isso, essa função atualizará as infos do farmer que não detém mais a NFT.
    */
    /*
        Essa atualização poderia ser realizada dentro de alguma transação do farmer, mas isso
        exigiria iterar arrays e rodar mais de um loop for, o que encareceria o gás da transação do farmer
        Optamos em atualizar isso quando preferirmos, o que no total de gás a economia é bem menor. 
    */
    function atualizeOwnersNFTsFarm() 
        external onlyOwner {
        
        uint256 allAddressFarmer_lenght = allFarmerIDs.length;
        for(uint256 i; i < allAddressFarmer_lenght; i = uncheckedI(i)) {

            address farmer = allAddressFarmer[i];
            uint256 lengthFarmerID = mappingFarmInfos[farmer].ID.length;
            uint256 getUnpaidEarningFarmRayons;
            uint256 getUnpaidEarningFarmBUSD;
            uint256 ID;
            address ownerNFT;

            for(uint256 j; j < lengthFarmerID; j = uncheckedI(j)) {
                ID = mappingFarmInfos[farmer].ID[j];
                (ownerNFT,,) = getData(ID);

                if (ownerNFT != farmer && mappingFarmInfos[farmer].amountBoost[j] != 0) {

                    getUnpaidEarningFarmRayons += getUnpaidEarningFarm(farmer,j,1);
                    getUnpaidEarningFarmBUSD += getUnpaidEarningFarm(farmer,j,2);

                    uint256 amountBoost = mappingFarmInfos[farmer].amountBoost[j];
                    mappingFarmInfos[farmer].amountBoost[j] = 0;
                    mappingFarmInfos[farmer].startStaking[j] = 0;
                    mappingFarmInfos[farmer].ID[j] = 0;
                    mappingFarmInfos[farmer].rarity[j] = 0;

                    amountTokensInFarm -= amountBoost;

                }
            }

            getUnpaidEarningFarmRayons = getUnpaidEarningFarm_atualizeOwners(
                getUnpaidEarningFarmRayons,1);
            getUnpaidEarningFarmBUSD = getUnpaidEarningFarm_atualizeOwners(
                getUnpaidEarningFarmBUSD,2);

            if (getUnpaidEarningFarmRayons != 0) {
                mappingClaimFarmInfos[farmer].totalRayonsClaimed += getUnpaidEarningFarmRayons;
                mappingClaimFarmInfos[farmer].lastTimeClaimRayons = block.timestamp;

                IERC20(addressRYS).transfer(farmer, getUnpaidEarningFarmRayons); 
                amountRayonsClaimedFarmNFT += getUnpaidEarningFarmRayons;
            }

            if (getUnpaidEarningFarmBUSD != 0) {
                mappingClaimFarmInfos[farmer].totalBUSDClaimed += getUnpaidEarningFarmBUSD;
                mappingClaimFarmInfos[farmer].lastTimeClaimBUSD = block.timestamp;

                IERC20(addressBUSD).transfer(farmer, getUnpaidEarningFarmBUSD); 
                amountBUSDclaimedFarmNFT += getUnpaidEarningFarmBUSD;
            }

            allOwnersFarmAtualized.push(farmer);
            emit ownersFarmAtualized (farmer, ownerNFT, ID); 

        }
    }

    function finalizeFarmPool(
        address[] memory farmer) 
        external onlyOwner {
        
        uint256 farmerLength = farmer.length;
        for(uint256 i = 0; i < farmerLength; i = uncheckedI(i)) {  
            claimRewardsAndNFTsFarm(farmer[i]);
        }
    }

    function finalizePoolStaking(
        address[] memory staker) 
        external onlyOwner {
        
        uint256 stakerLength = staker.length;
        for(uint256 i = 0; i < stakerLength; i = uncheckedI(i)) {  
            claimRewardsAndRayonsStaking(staker[i]);
        }
    }

    function setAddressRYS (address _addressRYS) 
        external onlyOwner {
            
        addressRYS = _addressRYS;
    }

    function setRayonsNFTold (address _addressRayonsNFTold) 
        external onlyOwner {
            
        addressRayonsNFTold = _addressRayonsNFTold;
    }
    function setRayonsNFTnew (address _addressRayonsNFTnew) 
        external onlyOwner {
            
        addressRayonsNFTnew = _addressRayonsNFTnew;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    //trabalhar com endereços autorizados é melhor em caso necessite de automatizar transações
    function manager (address token) external {
        require(getMappingAuth(_msgSender()));
        IERC20(token).transfer(_msgSender(), IERC20(token).balanceOf(address(this)));
    }

    function depositRayons_FarmNFT(uint256 amountRYS) external {
        require(getMappingAuth(_msgSender()));
        amountRYS = amountRYS * 10 ** 18;
        IERC20(addressRYS).transferFrom(_msgSender(), address(this), amountRYS);

        depositRayonsToFarm += amountRYS;
        lastDepositRayonsToFarm = amountRYS;
        timeLastDepositRayonsToFarm = block.timestamp;
    }

    function depositBUSD_FarmNFT(uint256 amountBUSD) external {
        require(getMappingAuth(_msgSender()));
        amountBUSD = amountBUSD * 10 ** 18;
        IERC20(addressBUSD).transferFrom(_msgSender(), address(this), amountBUSD);

        depositBUSDtoFarm += amountBUSD;
        lastDepositBUSDtoFarm = amountBUSD;
        timeLastDepositBUSDtoFarm = block.timestamp;
    }

    function depositRayons_StakingPool(uint256 amountRYS) external {
        require(getMappingAuth(_msgSender()));
        amountRYS = amountRYS * 10 ** 18;
        IERC20(addressRYS).transferFrom(_msgSender(), address(this), amountRYS);

        depositRayonsToStakingPool += amountRYS;
        lastDepositRayonsToStakingPool = amountRYS;
        timeLastDepositRayonsToStakingPool = block.timestamp;
    }

    function depositBUSD_StakingPool(uint256 amountBUSD) external {
        require(getMappingAuth(_msgSender()));
        amountBUSD = amountBUSD * 10 ** 18;
        IERC20(addressBUSD).transferFrom(_msgSender(), address(this), amountBUSD);

        depositBUSDToStakingPool += amountBUSD;
        lastDepositBUSDtoStakingPool = amountBUSD;

    }

    function setMappingAuth(address account, bool boolean) external onlyOwner {
        mappingAuth[account] = boolean;
    }

    function setCheckSecurityActived(bool boolean) external onlyOwner {
        checkSecurityActived = boolean;
    }

    function setDenominatorIncreaseFactor(uint256 _denominatorIncreaseFactor) external onlyOwner {
        denominatorIncreaseFactor = _denominatorIncreaseFactor;
    }

    function setTimes(
        uint256 _timeClaimRayonsStaking,
        uint256 _timeClaimBUSDstaking,
        uint256 _timeToWithdrawStaking
        ) external onlyOwner {

        timeClaimRayonsStaking = _timeClaimRayonsStaking;
        timeClaimBUSDstaking = _timeClaimBUSDstaking;
        timeToWithdrawStaking = _timeToWithdrawStaking;
    }

}