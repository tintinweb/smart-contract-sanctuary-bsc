/**
 *Submitted for verification at BscScan.com on 2022-10-10
*/

// SPDX-License-Identifier: MIT

/*
    Contrato e stake CFarm.

    Your money farm!

    https://coinfarm.com.br/
    https://coinfarm.com.br/en
    https://t.me/coinfarmoficial
    
    dev @gamer_noob_blockchain
*/

pragma solidity ^0.8.0;


//Declaração do codificador experimental ABIEncoderV2 para retornar tipos dinâmicos
pragma experimental ABIEncoderV2;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 */

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
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

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
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



contract CFarmStake is Pausable, Ownable, ReentrancyGuard {

    using SafeMath for uint256;

    uint256 liquidityFundToStake = 42600000 * 10 ** 8;

    uint256 public amountTokensDeposited;
    uint256 public amountTokensInStake;
    uint256 public amountTokensInStake30days;
    uint256 public amountTokensInStake90days;
    uint256 public amountTokensInStake180days;
    uint256 public amountTokensInStake360days;
    
    uint256 public amountTokensClaimedRewards30days;
    uint256 public amountTokensClaimedRewards90days;
    uint256 public amountTokensClaimedRewards180days;
    uint256 public amountTokensClaimedRewards360days;

    uint256 sumTokensDepositedLast24hrs;
    uint256 lastTimeForSumTokensDepositedLast24hrs;

    uint256 public totalStakersOn;
    uint256 public quantosStakesForamFeitos;

    uint256 public timeDeployContractThis;
    uint256 public timeOpenPoolsStake;
    uint256 public timeLimitToEmergencyWhithDrawlTokens;

    uint256 time30daysStake = 30 days;
    uint256 time90daysStake = 90 days;
    uint256 time180daysStake = 180 days;
    uint256 time360daysStake = 360 days;

    address public   addressCFarm;
    address internal addressBUSD =    0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address internal addressPCVS2 =   0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address internal addressWBNB =    0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    struct stakeInfo1 {
        uint256 startStake;
        uint256 amountTokens;
    }

    struct stakeInfo2 {
        uint256 startStake;
        uint256 amountTokens;
    }

    struct stakeInfo3 {
       uint256 startStake;
        uint256 amountTokens;
    }

    struct stakeInfo4 {   
        uint256 startStake;
        uint256 amountTokens;
    }

    mapping(address => uint256) public totalAmountTokensClaimed;
    mapping(address => uint256) public totalAmountRewardsClaimed;

    mapping(address => stakeInfo1) public mappingStakeInfo1;
    mapping(address => stakeInfo2) public mappingStakeInfo2;
    mapping(address => stakeInfo3) public mappingStakeInfo3;
    mapping(address => stakeInfo4) public mappingStakeInfo4;

    event ApostouStaked(address indexed addressStaker, uint256 amountTokens, uint256 whatsNumberStake);
    event Retirado(address indexed addressStaker, uint256 amountTokens, uint256 amountClaimed, uint256 whatsNumberStake);

    receive() external payable {}

    constructor() {
        timeDeployContractThis = block.timestamp;
    }

    function getDaysPassed() public view returns (uint256){
        return (block.timestamp - timeOpenPoolsStake).div(1 days); 
    }

    function amountTokensUnlockedPerMinutes() public view returns (uint256) {
        uint256 factorMinutesPassed = (block.timestamp - timeOpenPoolsStake).div(1 minutes); 
        uint256 amountUnlockPerMinutes = (liquidityFundToStake).mul(10 ** 6).div(12).div(12).div(30).div(24).div(60);
        uint256 amountUnlocked = factorMinutesPassed.mul(amountUnlockPerMinutes);

        return amountUnlocked;
    }

    function amountTokensUnlockedPerDays() public view returns (uint256) {
        uint256 factorMinutesPassed = (block.timestamp - timeOpenPoolsStake).div(1 days); 
        uint256 amountUnlockPerDays = (liquidityFundToStake).mul(10 ** 6).div(12).div(12).div(30).div(24);
        uint256 amountUnlocked = factorMinutesPassed.mul(amountUnlockPerDays);

        return amountUnlocked;
    }

    //Obtém informações específicas de stakers e informaçõe gerais
    function getInfos(address staker, uint256 whatsNumberStake) public view returns 
    (uint256, uint256, uint256, uint256, uint256, uint256) {
        
        uint256 startStake;
        uint256 amountTokens;
        uint256 limitStake;
        uint256 amountTokensStaked;
        uint256 amountTokensClaimedRewards;
        uint256 timePassed;

        if (whatsNumberStake == 1) {
            startStake = mappingStakeInfo1[staker].startStake;
            amountTokens =  mappingStakeInfo1[staker].amountTokens;
            timePassed = 30 * 24 * 60 * 60;
            amountTokensStaked = amountTokensInStake30days;
            amountTokensClaimedRewards = amountTokensClaimedRewards30days;
            limitStake = time30daysStake;
        } else if (whatsNumberStake == 2) {
            startStake = mappingStakeInfo2[staker].startStake;
            amountTokens =  mappingStakeInfo2[staker].amountTokens;
            timePassed = 90 * 24 * 60 * 60;
            amountTokensStaked = amountTokensInStake90days;
            amountTokensClaimedRewards = amountTokensClaimedRewards90days;
            limitStake = time90daysStake;
        } else if (whatsNumberStake == 3) {
            startStake = mappingStakeInfo3[staker].startStake;
            amountTokens =  mappingStakeInfo3[staker].amountTokens;
            timePassed = 180 * 24 * 60 * 60;
            amountTokensStaked = amountTokensInStake180days;
            amountTokensClaimedRewards = amountTokensClaimedRewards90days;
            limitStake = time180daysStake;
        } else if (whatsNumberStake == 4) {
            startStake = mappingStakeInfo4[staker].startStake;
            amountTokens =  mappingStakeInfo4[staker].amountTokens;
            timePassed = 360 * 24 * 60 * 60;
            amountTokensStaked = amountTokensInStake360days;
            amountTokensClaimedRewards = amountTokensClaimedRewards180days;
            limitStake = time360daysStake;
        }
        return (startStake,amountTokens,timePassed,amountTokensStaked,amountTokensClaimedRewards,limitStake);
    }


    function getTimeForEndMyStake(address staker, uint256 whatsNumberStake) external view returns (uint256) {
        uint256 getPrazoParaExpirarStakeReturn;
        uint256 startStake;
        uint256 limitStake;

        (startStake,,,,,limitStake) = getInfos(staker, whatsNumberStake);
        
        if (startStake > 0) {
           if (startStake + limitStake > block.timestamp) {
                //retorno está em segundo; banckend tem que converter para horas ou dias
                return getPrazoParaExpirarStakeReturn = startStake + limitStake - block.timestamp;
            } else {
               return getPrazoParaExpirarStakeReturn = 0;
            }
        } else {
            return getPrazoParaExpirarStakeReturn = 0;
        }
    }

    function getTotalTokensCFarmInStake(address staker) external view returns (uint256) {
        return (mappingStakeInfo1[staker].amountTokens + 
                mappingStakeInfo2[staker].amountTokens +
                mappingStakeInfo3[staker].amountTokens +
                mappingStakeInfo4[staker].amountTokens);
    }

    function getRewardsWasClaimed(address staker) external view returns (uint256) {
        return totalAmountRewardsClaimed[staker];
    }

    function getTotalAmountTokensClaimed(address staker) external view returns (uint256) {
        return totalAmountTokensClaimed[staker];
    }

    //Retorna o saldo a ser clamado do stake 
    function getEarningTokens (address staker, uint256 whatsNumberStake) public view returns (uint256){

        uint256 amountRewardClaim;

        uint256 startStake;
        uint256 amountTokens;
        uint256 timePassed;
        uint256 amountTokensStaked;
        uint256 limitStake;

        (startStake,amountTokens,timePassed,amountTokensStaked,,limitStake) = getInfos(staker, whatsNumberStake);

        if (amountTokensStaked == 0) {
            return 0;
        }

        uint256 amountUnlockPerMinutes = (liquidityFundToStake).mul(10 ** 6).div(12).div(12).div(30).div(24).div(60);
        uint256 percentAmountTokens = amountTokens.mul(10 ** 6).div(amountTokensStaked);

        if (block.timestamp < startStake + limitStake) {
            timePassed = (block.timestamp - startStake).div(60);
        } else {
            timePassed = timePassed.div(60);
        }

        amountRewardClaim = percentAmountTokens.mul(amountUnlockPerMinutes).mul(timePassed).mul(25).div(100)
                            .div(10 ** 6).div(10 ** 6);  

        return amountRewardClaim;  
    } 


    //retorna a atualização atual para o saldo de tokens depositados convertendo
    //para BUSD para o calculo do APR e TVL
    function getConvertCFarmToBUSD(uint256 amount) public view returns (uint256) {
        uint256 retorno;
        if (amount != 0) {
            // generate the uniswap pair path of CFarm to WBNB/BNB
            address[] memory path = new address[](3);
            path[0] = addressCFarm;
            path[1] = addressWBNB;
            path[2] = addressBUSD;

            uint256[] memory amountOutMins = IUniswapV2Router(addressPCVS2)
            .getAmountsOut(amount, path);
            retorno = amountOutMins[path.length -1];
        }
        return retorno;
    } 


    //valor total bloqueado nas POOLS de stakes da CFarm. Retorno em dólars
    //Total Value Locked
    function TVL (uint256 whatsNumberStake) public view returns (uint256,uint256) {

        uint256 liquidityTokensLocked;
        uint256 liquidityForPay;
        uint256 percentPerPoolStake;
        uint256 amountTokensClaimedRewards;
        uint256 amountTokensStaked;


        if (whatsNumberStake == 0) {
            amountTokensStaked = amountTokensInStake;
            amountTokensClaimedRewards = amountTokensClaimedRewards30days + amountTokensClaimedRewards90days +
                                         amountTokensClaimedRewards180days + amountTokensClaimedRewards360days;
            percentPerPoolStake = 100;

        } else {
            (,,,amountTokensStaked,
            amountTokensClaimedRewards,) = getInfos(address(0x0), whatsNumberStake);
            percentPerPoolStake = 25;

        }

        //uint256 timePassed = (block.timestamp - timeOpenPoolsStake).div(1 days);

        //amountUnlockByDays
        //disponibilidades da liquidez para pagamentos para a referida pool de stake
        uint256 liquidityForPayCalc = (liquidityFundToStake)
        .mul(10 ** 6).div(12).div(12).div(30).mul(percentPerPoolStake).div(100) - amountTokensClaimedRewards;

        liquidityForPay = getConvertCFarmToBUSD(liquidityForPayCalc);

        if (amountTokensStaked == 0) {
            return (0,liquidityForPay);
        }

        liquidityTokensLocked = getConvertCFarmToBUSD(amountTokensStaked);

        //backend deve dividir o valor por 10 ** 6
        return (liquidityTokensLocked,liquidityForPay);
    }


    //based https://docs.pancakeswap.finance/products/yield-farming
    function APR (uint256 whatsNumberStake) public view returns (uint256) {
        uint256 amountTokensStaked;
        uint256 percentPerPoolStake;
        
        if (whatsNumberStake == 0) {
            amountTokensStaked = amountTokensInStake;
            percentPerPoolStake = 100;
        } else {
            (,,,amountTokensStaked,,) = getInfos(address(0x0), whatsNumberStake);
            percentPerPoolStake = 25;
        }

        if (amountTokensStaked == 0) {
            return 0;
        }

        //amountUnlockByDays
        //disponibilidades da liquidez para pagamentos para a referida pool de stake
        uint256 liqudityUnlockForPayPerDays = (liquidityFundToStake).mul(10**6).div(12)
                        .mul(percentPerPoolStake).div(100);

        uint256 rewardsAPR = liqudityUnlockForPayPerDays
                             .div(amountTokensStaked).mul(100).div(10**6);
        //retorno em percentual, multiplicado por 100.
        return rewardsAPR;

    }

    //based https://docs.pancakeswap.finance/products/yield-farming
    function APR2 (uint256 whatsNumberStake) public view returns (uint256) {
        uint256 amountTokensStaked;
        uint256 percentPerPoolStake;
        
        if (whatsNumberStake == 0) {
            amountTokensStaked = amountTokensInStake;
            percentPerPoolStake = 100;
        } else {
            (,,,amountTokensStaked,,) = getInfos(address(0x0), whatsNumberStake);
            percentPerPoolStake = 25;
        }

        if (amountTokensStaked == 0) {
            return 0;
        }

        //amountUnlockByDays
        //disponibilidades da liquidez para pagamentos para a referida pool de stake
        uint256 liqudityUnlockForPayPerDays = (liquidityFundToStake)
                            .mul(10 ** 6).div(12).div(12).div(30).mul(percentPerPoolStake).div(100);

        uint256 liqudityUnlockForPayPerDaysProjetedForYearly = liqudityUnlockForPayPerDays.mul(365);
        uint256 rewardsAPR = liqudityUnlockForPayPerDaysProjetedForYearly
                             .div(amountTokensStaked).mul(100).div(10 ** 6);

        //retorno em percentual, multiplicado por 100.
        return rewardsAPR;

    }

    function stake(address staker, uint256 stakeAmount, uint256 whatsNumberStake) external whenNotPaused nonReentrant {
        require(staker == _msgSender(), "Somente a conta detentora que pode apostar");
        require(stakeAmount > 0, "Por favor, aposte um valor de tokens maior que ZERO");
        require(IERC20(addressCFarm).balanceOf(staker) >= stakeAmount, "Voce nao possui tokens suficientes");
        require(whatsNumberStake <= 4 && whatsNumberStake != 0, "Stake fornecido invalido");
        require(timeOpenPoolsStake != 0, "As pools de stake ainda nao estao abertas");

        IERC20(addressCFarm).transferFrom(staker, address(this), stakeAmount);

        if (whatsNumberStake == 1) {
            require(mappingStakeInfo1[staker].amountTokens == 0, "Voce ja fez stake de 30 dias");
            mappingStakeInfo1[staker].startStake = block.timestamp;
            mappingStakeInfo1[staker].amountTokens = stakeAmount;
            amountTokensInStake30days += stakeAmount;

        } else if (whatsNumberStake == 2) {
            require(mappingStakeInfo2[staker].amountTokens == 0, "Voce ja fez stake de 90 dias");
            mappingStakeInfo2[staker].startStake = block.timestamp;
            mappingStakeInfo2[staker].amountTokens = stakeAmount;
            amountTokensInStake90days += stakeAmount;

        } else if (whatsNumberStake == 3) {
            require(mappingStakeInfo3[staker].amountTokens == 0, "Voce ja fez stake de 180 dias");
            mappingStakeInfo3[staker].startStake = block.timestamp;
            mappingStakeInfo3[staker].amountTokens = stakeAmount;
            amountTokensInStake180days += stakeAmount;

        } else if (whatsNumberStake == 4) {
            require(mappingStakeInfo4[staker].amountTokens == 0, "Voce ja fez stake de 360 dias");
            mappingStakeInfo4[staker].startStake = block.timestamp;
            mappingStakeInfo4[staker].amountTokens = stakeAmount;
            amountTokensInStake360days += stakeAmount;

        } 

        quantosStakesForamFeitos++;
        totalStakersOn++;
        amountTokensDeposited += stakeAmount;
        amountTokensInStake += stakeAmount;

        emit ApostouStaked(staker, stakeAmount, whatsNumberStake);

    }    


    function claim(address staker, uint256 whatsNumberStake) public whenNotPaused nonReentrant returns (bool){
        require(staker == _msgSender(), "Somente a conta detentora que pode clamar");
        require(whatsNumberStake <= 4 && whatsNumberStake != 0, "Stake fornecido invalido");

        uint256 startStake;
        uint256 amountTokens;
        uint256 limitStake;
        uint256 timePassed;

        uint256 amountUnlockPerMinutes = (liquidityFundToStake).mul(10 ** 6).div(12).div(12).div(30).div(24).div(60);
        uint256 amountTokensStaked;

        //contrato já possi várias proteções contra ataques hacker
        //as alterações de saldos são feitas corretamente para evitar que um hacker drene os saldos do contrato

        if (whatsNumberStake == 1) {
            startStake =    mappingStakeInfo1[staker].startStake;
            limitStake =    time30daysStake;
            require(startStake + limitStake < block.timestamp, "Prazo de 30 dias de bloqueio");
            amountTokens =  mappingStakeInfo1[staker].amountTokens;
            require(amountTokens > 0, "Nao ha stake de 30 dias apostado");
            mappingStakeInfo1[staker].amountTokens = 0;
            timePassed = 30 * 24 * 60; //em minutos
            amountTokensStaked = amountTokensInStake30days;
            amountTokensInStake30days -= amountTokens;
            
        } else if (whatsNumberStake == 2) {
            startStake =    mappingStakeInfo2[staker].startStake;
            limitStake =    time90daysStake;
            require(startStake + limitStake < block.timestamp, "Prazo de 3 meses dias de bloqueio");
            amountTokens =  mappingStakeInfo2[staker].amountTokens;
            require(amountTokens > 0, "Nao ha stake de 3 meses apostado");
            mappingStakeInfo2[staker].amountTokens = 0;
            timePassed = 90 * 24 * 60; //em minutos
            amountTokensStaked = amountTokensInStake90days;
            amountTokensInStake90days -= amountTokens;

        } else if (whatsNumberStake == 3) {
            startStake =    mappingStakeInfo3[staker].startStake;
            limitStake =    time180daysStake;
            require(startStake + limitStake < block.timestamp, "Prazo de 6 meses  de bloqueio");
            amountTokens =  mappingStakeInfo3[staker].amountTokens;
            require(amountTokens > 0, "Nao ha stake de 6 meses apostado");
            mappingStakeInfo3[staker].amountTokens = 0;
            timePassed = 180 * 24 * 60; //em minutos
            amountTokensStaked = amountTokensInStake180days;
            amountTokensInStake180days -= amountTokens;

        } else if (whatsNumberStake == 4) {
            startStake =    mappingStakeInfo4[staker].startStake;
            limitStake =    time360daysStake;
            require(startStake + limitStake < block.timestamp, "Prazo de 1 ano de bloqueio");
            amountTokens =  mappingStakeInfo4[staker].amountTokens;
            require(amountTokens > 0, "Nao ha stake de 1 ano apostado");
            mappingStakeInfo4[staker].amountTokens = 0;
            timePassed = 360 * 24 * 60; //em minutos
            amountTokensStaked = amountTokensInStake360days;
            amountTokensInStake360days -= amountTokens;

        }
        
        uint256 percentAmountTokens = amountTokens.mul(10 ** 6).div(amountTokensStaked);
        uint256 amountRewardClaim = 
        percentAmountTokens.mul(amountUnlockPerMinutes).mul(timePassed).mul(25).div(100)
        .div(10 ** 6).div(10 ** 6);  

        IERC20(addressCFarm).transfer(staker, amountTokens);
        IERC20(addressCFarm).transfer(staker, amountRewardClaim);

        if (whatsNumberStake == 1) {
            amountTokensClaimedRewards30days += amountRewardClaim;
        } else if (whatsNumberStake == 2) {
            amountTokensClaimedRewards90days += amountRewardClaim;
        } else if (whatsNumberStake == 3) {
            amountTokensClaimedRewards180days += amountRewardClaim;
        } else if (whatsNumberStake == 4) {
            amountTokensClaimedRewards360days += amountRewardClaim;
        }

        amountTokensInStake -= amountTokens;
        totalStakersOn--;
        totalAmountTokensClaimed[staker] += amountTokens;
        totalAmountRewardsClaimed[staker] += amountRewardClaim;

        emit Retirado(staker, amountTokens, amountRewardClaim, whatsNumberStake);

        return true;
    }

    //Função chamada para abrir as 4 pools de liquidez e setar a emergência
    function setOpenPoolStake(uint256 _timeLimitToEmergencyWhithDrawlTokens) external onlyOwner {
        timeLimitToEmergencyWhithDrawlTokens = _timeLimitToEmergencyWhithDrawlTokens;
        timeOpenPoolsStake = block.timestamp;
    }

    //função de emergência para devolver os tokens para o proprietário
    //pode ser usada nos primeiros dias do lançamento do stake somente
    //após isso nunca pode ser chamada
    function emergencyWhithDrawlTokens () public onlyOwner {
        require(
            timeOpenPoolsStake + timeLimitToEmergencyWhithDrawlTokens >= block.timestamp,
           "Tempo limite para retirada de emergencia passou"
        );

        IERC20(addressCFarm).transfer(owner(), IERC20(addressCFarm).balanceOf(address(this)));
    }

    function setCFarmAddressContract (address _addressCFarm) external onlyOwner {
        addressCFarm = _addressCFarm;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function removeBNB () public onlyOwner {
        uint256 amount = address(this).balance;
        payable(msg.sender).transfer(amount);
    }

    //tokens do contrato da CFarm nunca podem ser removidos desse contrato
    //função usada para recuperação tokens diversos depositados no contrato
    /*fundo inicial de 71 milhões SOMENTE poderão ser retirados pelos apostadores do stake conforme
      o prazo de desbloqueio de até 12 anos */
    function removeAnotherERC20 (address anotherERC20address) public onlyOwner {
        require(
            anotherERC20address != address(addressCFarm)
        );

        IERC20(anotherERC20address).transfer(msg.sender, IERC20(anotherERC20address).balanceOf(address(this)));
    }
}