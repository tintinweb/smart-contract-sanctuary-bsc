/**
 *Submitted for verification at BscScan.com on 2022-02-21
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

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



/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}



// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
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

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
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

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}





/*
* Esse sistema foi Desenvolvido Por RedHawk
* É expressamente proibido a venda desse Sistema sem minha autorização
* Este é um sistema completo de Staking, aonde você pode fazer staking tanto do token e tambem de um sistema NFT totalmente inovador
* Este contrato possui tudo o que há de mais moderno na atualidade de um contrato solidity
* Você tem total autonomia sobre o contrato, isso permite que o projeto tenha muita flexibilidade uma vez que seja encontrado eventuais problemas
* é possivel mudar os contrato sempre que desejar, use esse sistema com consciencia e sabedoria
* Contato Telegram: https://t.me/redhawknfts
* Todo esse sistema foi criado para a minha plataforma Arcane Cards
* Conheça meu Projeto: https://arcanecards.io/
* Preços e negociações entre no meu Telegram
* Plataforma Front-end e Back-end totalmente exclusiva e desenvolvida com base em suas necessidades
*/








// Simples Interface do Contrato do Token
interface IBEP20 {
        function totalSupply() external view returns (uint);
        function allowance(address owner, address spender) external view  returns (uint256);
        function transfer(address recipient, uint256 amount) external returns (bool) ;
        function transferFrom( address sender, address recipient, uint256 amount) external returns (bool);
        function balanceOf(address account) external view  returns (uint256);
        function approve(address _spender, uint256 _amount) external returns (bool);
        event Transfer(address indexed from, address indexed to, uint256 value);
        event Approval(address indexed owner, address indexed spender, uint256 value);  
        }
        

contract Staking is Ownable {
    

    /*
    *Matematica Segura
    * @NOTA apesar do contrato ser compilado na versão 0.8.11 que nao enfrenta problemas de "OVERFLOW"
    * É seguro mesmo assim utilizar SafeMath e Math
    */
    using SafeMath for uint256;
    using Math for uint;
    //---------Math-----------//
    



    constructor (
    
    IBEP20 _token,
    uint256 _rewardPercent,
    uint256 _rewardsPerHour

        ) 

     {
    // Endereço do Token
    token = _token;
    // Porcentagem de Recompensa
    rewardPercent = _rewardPercent;
    // Recompensa em minutos/Horas
    rewardsPerHour = _rewardsPerHour;
    }


    // Endereço do Token
    IBEP20 public token;
    // Endereço de Saldo Pool
    uint private _poolBalance;
    // Endereço de Saldo Users
    uint private _staking;
    // Percentual de recompensa do contrato 
    uint256 public rewardPercent; // 0,96407407% Percent Per Block
    // Bloco de recompensa, aqui está como Horas!! 3600 = 1 Hours
    uint public rewardsPerHour; // 1 Hours 
  
    
    // Eventos do contrato
    event stakingHolder(address indexed _from,  uint _amount);
    event unstakingHolder(address indexed _from, uint _amount);
    event rewardHolder(address indexed _from, uint _amount);

    

    // Mapeamento e Estruturas
    
    mapping(address => userStake) public stakes;
    

    
  
   
    
    /*
    * @NOTA runningStake por padrão retorna FALSE ou seja o contrato não esta liberado para Stake
    * Você precisa por ele como TRUE para que o contrato libere as funções
    */ 
    bool public runningStake = false;



    // Estrutura de todos os dados _addStake (users)
    struct userStake {
        // USer
        address user;
        // Valor aportado no Stake
        uint value;
        // Bloco inicial/final
        uint blockTime;
        // Recompensas clamaveis
        uint claimable;
        // Boleano
        bool exist;
    }

    struct unstakes {
        uint total_stake;
        userStake[]  staked;
    }

 


    /*
    *  Você precisa pertimir que o contrato inicie suas funções
    *  esse modificador permite que você pause o contrato quando desejar!! 
    *  Tenha certeza que é isso que você quer fazer com o contrato antes de pausar.
    *  Por Padrão o contrato  "PAUSADO" você precisa por ele como "BOOL = TRUE"
    */
    modifier running() {
        require(runningStake == true, "Arcane: Stake esta desativado!");
        _;
    }

    modifier updateRewards() {
         userStake storage user = stakes[msg.sender];
         user.claimable = lastRewardUpdate(msg.sender);
         user.blockTime = block.timestamp;
         _;
    }

    //-------Running Staking-------//



    function stake(uint256 _amount)  external  running {
        // Amount é quantidade de Token que você está disposto a apostar
        require(_amount > 0, "Arcane: Voce precisa adicionar um saldo maior do que Zero");
        // _poolBalance precisa sempre ser maior do que zero para retiradas!
        require(_poolBalance > 0, "Arcane: Saldo da Pool esta Zerado!!");
        // Tranfere os Tokens para o contrato de Staking
        IBEP20(token).transferFrom(msg.sender, address(this), _amount);
        
        // _staking representa de forma visual aonde estão alocados os Tokens dos Users
        _staking += _amount;

       
        userStake storage user = stakes[msg.sender];
        // já depositado antes
        if (user.value != 0) {
        user.claimable = lastRewardUpdate(msg.sender);
        }

        user.user = msg.sender;
        user.value = user.value.add(_amount);
        user.blockTime = block.timestamp;
        user.exist = true;
        // Bloco de tempo Inicial do Stake por Indice
        
    
         // Emite um evento do User >> msg.sender >> montante >> Bloco Inicial
        emit stakingHolder(msg.sender, _amount);
    }

   function unstake() external running {
       
       userStake storage user = stakes[msg.sender];
       require( user.value > 0, "Arcane:Saldo de Staking precisa ser maior do que Zero");
       uint totalStaked = user.value;
       
       // Atualiza Stake
       user.claimable = lastRewardUpdate(msg.sender);
       user.value = user.value.sub(totalStaked);
       user.blockTime = block.timestamp;

       uint attTvl = _staking.sub(totalStaked);
       _staking = attTvl;

       user.value  = 0;
       user.exist = false;
       IBEP20(token).transfer(msg.sender, totalStaked);
       emit unstakingHolder(msg.sender, totalStaked);
   }

   function unstakeReward() external running {
        require(lastRewardUpdate(msg.sender) > 0,"Arcane:Recompensa precisa ser maior do que Zero");
        userStake storage user = stakes[msg.sender];
        require(user.exist, "Arcane: Voce precisa estar fazendo Stake para retirar as recompensas restantes");
        user.claimable = lastRewardUpdate(msg.sender);
        uint totalRewards = user.claimable ;

        // Retira recompensa e reseta o time de recompensa
        user.claimable = lastRewardUpdate(msg.sender).sub(totalRewards);
        user.blockTime = block.timestamp;

        uint attPool = _poolBalance.sub(totalRewards);
        _poolBalance = attPool;

        user.claimable = 0;
        IBEP20(token).transfer(msg.sender, totalRewards);
        emit rewardHolder(msg.sender,totalRewards);
   }
  

   function getInfo(address accounts) public view returns(address user, uint value, uint blockTime,  bool exist) {
       userStake memory users = stakes[accounts];
       require(users.exist, "User nao encontrado");
       return(users.user, users.value, users.blockTime, users.exist);
   }
    
    //------------------------FUNÇÕES ADMINISTRATIVA DO CONTRATO---------------------//
    // Adiciona liquidez na Pool
    function mintAddPool(uint256 _amount) external onlyOwner{
        require(_amount > 0);
        IBEP20(token).transferFrom(msg.sender, address(this), _amount);
        _poolBalance += _amount;
    }

    // Remove a liquidez da Pool
    function removePoolBalance() external onlyOwner{
        require(_poolBalance > 0,"Arcane:Pool esta Zerada!");
        uint poolSaldo = _poolBalance;
        _poolBalance = 0;
        IBEP20(token).transfer(msg.sender, poolSaldo);
    }

    /*
    * @NOTA emergencialWithdraw apenas utilize essa função caso exista alguma erro com contrato
    * em hipotese alguma utilize essa função para beneficio proprio
    * emergencialWithdraw retira os tokens de todos os users que apostaram na Pool
    * @Dev em caso de haver algum problema e o sistema parar de efetuar pagamentos ou o user não conseguir retirar 
    * Utilize essa função que retira todos os token do _staking e devolva para os holders
    */
    function emergencialWithdraw() external onlyOwner {
        uint stakingUsers = _staking;
        _staking = 0;
        IBEP20(token).transfer(msg.sender, stakingUsers);
    }
     
   
  /*
  * @NOTA está função precisa estar como "TRUE" para o contrato iniciar
  * caso esteja como "FALSE" nenhuma função funciona
  * é recomendavel utilizar essa função caso você verifique algum erro no "CONTRATO"
  * Por padrão stakeStatus é "FALSE"
  */
   function stakeStatus(bool _status) external onlyOwner {
        runningStake = _status;
    }

  /*
  * @DEV setNewAddressStake muda o contrato de pagamento atual para um novo contrato.
  * Tenha certeza de estar com a POOL zerada e todos os holders terem retirado seu capital
  * Antes de trocar o contrato verifique todas essas informções
  */
    function setNewAddressStake(IBEP20 _token) external onlyOwner {
        require(_poolBalance == 0, "Arcane: Pool precisa ser zero");
        require(_staking == 0, "Arcane: TVL precisa ser Zero");
        token = _token;
    }


    function setRewardPercent(uint256 percent) external onlyOwner updateRewards {
        rewardPercent = percent;
    } 


    function setRewardsPerHour(uint256 percent) external onlyOwner updateRewards {
        rewardsPerHour = percent;
    }
//------------------------ FIM FUNÇÕES ADMINISTRATIVA DO CONTRATO---------------------//

//------------------------FUNÇÕES VISUAIS DO CONTRATO---------------------//

    // RETORNA QUANTIDADE DE TOKENS NA pOOL DE LIQUIDEZ
    function poolBalance() public view returns(uint) {
       return _poolBalance;
   }

   // RETORNA QUANTIDADE DE TOKENS DE TODOS OS USERS
   function stakeBalance() public view returns(uint) {
       return _staking;
   }


   function viewStake(address _staker) public view returns(uint256) {
       userStake memory user = stakes[_staker];

       return user.value;
   }

   function _currentRewards(userStake memory user) internal view running returns(uint256) {
       return ((block.timestamp - user.blockTime) * user.value) / rewardsPerHour / rewardPercent;
   }

   function lastRewardUpdate(address account) public view  returns(uint256) {
      userStake memory user = stakes[account];
      return user.claimable.add(_currentRewards(user));
   }

   
  //------------------------FIM FUNÇÕES VISUAIS DO CONTRATO---------------------//


}