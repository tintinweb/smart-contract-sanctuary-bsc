/**
 *Submitted for verification at BscScan.com on 2022-05-17
*/

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: contracts/staking.sol


pragma solidity ^0.8.12;



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

library Address {

    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }


    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

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

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
               
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
library CounterNFT {
    struct Counter {
        uint256 _value;
    }
    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }
    function increment(Counter storage counter) internal {
      
            counter._value += 1;
        
    }
    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
     
            counter._value = value - 1;
        
    }
    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

contract Staking is Ownable, ReentrancyGuard{

    using Address for address;
    using CounterNFT for CounterNFT.Counter;
    // Contador Stake Simples
    CounterNFT.Counter public _addSimpleStake;
    CounterNFT.Counter public _removeSimpleStake;
    // Contador Stake Prime
    CounterNFT.Counter public _addPrimeStake;
    CounterNFT.Counter public _removePrimeStake;
    // Contador de Users para Stake
    uint256 public simpleStakeLimit;
    uint256 public primeStakeLimit;
    // Endereço do Token
    IBEP20 public token;
    // Endereço Owner
    address public wallet;
    // Porcentagem e Rendimento Stake
    uint256 public simpleRHT = 200 * 10 ** 18;
    uint256 public primeRHT = 2000 * 10 ** 18;
    uint256 public rewardsPerHour = 60;
    uint256 public rewardsPercentSimpleStake = 300;
    uint256 public rewardsPercentPrimeStake = 100;
    // Preço em BNB
    uint public priceBNBSimpleStake = 10000000000000000 ;
    uint public priceBNBPrimeStake = 40000000000000000;
    // Tempo de Bloqueio
    uint256 public timeToBlock = 300;
    // Bolleano para Definir tempo de bloqueio
    bool public isTimeBlock = true;
    bool public isBNB = true;
    bool public isRequireUser = true;

    mapping(address => SimpleStake) public simpleStake;
    mapping(address => PrimeStake) public primeStake;
    mapping(address => Balance) public contractBalance;

    // Estruturas


    struct PrimeStake {
        address payable user;
        uint startBlock;
        uint endBlock;
        uint256 initialBalance;
        uint256 rewardWithdraw;
        uint256 percentReward;
        bool isStaking;
    }

    struct SimpleStake {
        address payable user;
        uint startBlock;
        uint endBlock;
        uint256 initialBalance;
        uint256 rewardWithdraw;
        uint256 percentReward;
        bool isStaking;
    }

    struct Balance {
        uint256 simpleBalance;
        uint256 primeBalance;
        uint256 lpBalance;
    }


    // Modificadores
    modifier onlyStake() {
        SimpleStake storage isUser = simpleStake[msg.sender];
        require(isUser.isStaking, "Precisa estar no Staking");
        _;
    }

    function setIstimeBlockAndBNBPrice(bool _isTimeBlock, bool _isBNB) external onlyOwner {
        isTimeBlock = _isTimeBlock;
        isBNB = _isBNB;
    }

    function setTimeToBlock(uint256 _timeToBlock) external onlyOwner {
        timeToBlock = _timeToBlock;
    }

   function setPercents(uint256 _rewardsPerHour, uint256 _rewardsPercentSimpleStake, uint256 _rewardsPercentPrimeStake) external onlyOwner {
      rewardsPerHour =  _rewardsPerHour;
      rewardsPercentSimpleStake = _rewardsPercentSimpleStake;
      rewardsPercentPrimeStake = _rewardsPercentPrimeStake;
   }
   
    function setContractAddress(address _token) external onlyOwner {
        token = IBEP20(_token);
    }

    function setLimitePerStake(uint256 _simpleStakeLimit, uint256 _primeStakeLimit) external onlyOwner {
        simpleStakeLimit = _simpleStakeLimit;
        primeStakeLimit = _primeStakeLimit;
    }

    function setWalletAddress(address _wallet) external onlyOwner {
        wallet = _wallet;
    }

    function setPriceToStartStake(uint256 _priceBNBSimpleStake, uint256 _priceBNBPrimeStake) external onlyOwner {
        priceBNBSimpleStake = _priceBNBSimpleStake;
        priceBNBPrimeStake = _priceBNBPrimeStake;
    }

    //------------- Funções Administrativas do Contrato -------------------//
    function addPollRewards(uint256 _amount) external onlyOwner nonReentrant{
        Balance storage isContract = contractBalance[address(this)];
        IBEP20(token).transferFrom(msg.sender, address(this), _amount);
        isContract.lpBalance += _amount;
    }

    function balanceSimpleStake() public view returns(uint256) {
        Balance storage isContract = contractBalance[address(this)];
        return isContract.simpleBalance;
    }

    function balancePrimeStake() public view returns(uint256) {
        Balance storage isContract = contractBalance[address(this)];
        return isContract.primeBalance;
    }

    function balanceLiquidityStake() public view returns(uint256) {
        Balance storage isContract = contractBalance[address(this)];
        return isContract.lpBalance;
    }

    function removePollRewards() external onlyOwner nonReentrant{
        Balance storage isContract = contractBalance[address(this)];
        IBEP20(token).transfer(msg.sender,   isContract.lpBalance);
         isContract.lpBalance = 0;
    }

    function removePoolUser() external onlyOwner nonReentrant{
        Balance storage isContract = contractBalance[address(this)];
        IBEP20(token).transfer(msg.sender, isContract.simpleBalance);
        isContract.simpleBalance = 0;
    }

    function _forwardFunds() private {
    require(wallet != address(0), "Cannot withdraw the ETH balance to the zero address");
      payable(wallet).transfer(msg.value);
    }


    function setMaxStake(uint256 _simpleRHT, uint256 _primeRHT) external onlyOwner {
        simpleRHT = _simpleRHT * 10 ** 18;
        primeRHT = _primeRHT * 10 ** 18;
    }

    function setIsRequireUser(bool _isRequireUser) external onlyOwner {
        isRequireUser = _isRequireUser;
    }
    
    
    function simpleStakeLaunch(uint256 _amount) external payable nonReentrant{
        if(isBNB) {
        require(msg.value == priceBNBSimpleStake, "Precisa ser identico ao preco definido");
        _forwardFunds();
        }
        require(_amount * 10 ** 18 >= simpleRHT, "Precisa ser maior ou igual ao valor de RHT definido");
        // Inicia o Stake do Usuario
        SimpleStake storage isUser = simpleStake[msg.sender];
        if(isUser.initialBalance == 0) {
        _addSimpleStake.increment();
        uint256 newUser = _addSimpleStake.current();
        require(newUser <= simpleStakeLimit, "Limite de Holders atingido");
        }
        isUser.user = payable(msg.sender);
        // Atualiza o saldo do Contrato
        Balance storage isContract = contractBalance[address(this)];
        IBEP20(token).transferFrom(isUser.user, address(this), _amount);
        isContract.simpleBalance += _amount;
        // Strutura do Simple Stake
        isUser.isStaking = true;
        isUser.percentReward = rewardsPercentSimpleStake;
        if(isUser.initialBalance != 0) {
            isUser.rewardWithdraw = lastRewardUpdateSimpleStake(msg.sender);
        }
        isUser.initialBalance += _amount; 

        if(isUser.isStaking ) {
        isUser.startBlock = block.timestamp;
        isUser.endBlock = isUser.startBlock + timeToBlock;
        }


    }

    function primeStakeLaunch(uint256 _amount) external payable nonReentrant{
        if(isBNB) {
        require(msg.value == priceBNBPrimeStake, "Precisa ser identico ao preco definido");
        _forwardFunds();
        }
        require(_amount * 10 ** 18 >= primeRHT, "Precisa ser maior ou igual ao valor de RHT definido");
        // Inicia o Stake do Usuario
        PrimeStake storage isUser = primeStake[msg.sender];
        if(isUser.initialBalance == 0) {
        _addSimpleStake.increment();
        uint256 newUser = _addPrimeStake.current();
        require(newUser <= primeStakeLimit, "Limite de Holders atingido");
        }

        isUser.user = payable(msg.sender);
        // Atualiza o saldo do Contrato
        Balance storage isContract = contractBalance[address(this)];
        IBEP20(token).transferFrom(isUser.user, address(this), _amount);
        isContract.primeBalance += _amount;
        // Strutura do Simple Stake
        isUser.isStaking = true;
        isUser.percentReward = rewardsPercentPrimeStake;
        if(isUser.initialBalance != 0) {
            isUser.rewardWithdraw = lastRewardUpdateSimpleStake(msg.sender);
        }

        isUser.initialBalance += _amount; 

        if(isUser.isStaking ) {
        isUser.startBlock = block.timestamp;
        isUser.endBlock = isUser.startBlock + timeToBlock;
        }

    }

    function removeMyTokenSimpleStake(address sender) external onlyStake nonReentrant {
        // Inicia o Stake do Usuario
        SimpleStake storage isUser = simpleStake[sender];
        // Atualiza o saldo do Contrato
        _removeSimpleStake.decrement();
        Balance storage isContract = contractBalance[address(this)];
        isUser.isStaking = false;
        isUser.startBlock = 0;
        isUser.endBlock = 0;
        isUser.rewardWithdraw = 0;
        IBEP20(token).transfer(isUser.user, isUser.initialBalance);
        isContract.simpleBalance -= isUser.initialBalance;
        isUser.initialBalance = 0;
    }

    function removeMyTokenPrimeStake(address sender) external onlyStake nonReentrant {
        // Inicia o Stake do Usuario
        PrimeStake storage isUser = primeStake[sender];
        // Atualiza o saldo do Contrato
        _removePrimeStake.decrement();
        Balance storage isContract = contractBalance[address(this)];
        isUser.isStaking = false;
        isUser.startBlock = 0;
        isUser.endBlock = 0;
        isUser.rewardWithdraw = 0;
        IBEP20(token).transfer(isUser.user, isUser.initialBalance);
        isContract.primeBalance -= isUser.initialBalance;
        isUser.initialBalance = 0;
    }

    function withdrawRewardSimpleStake(address sender) external onlyStake nonReentrant {
        // Tempo de Bloqueio para retirada de Recompensas
        if(isTimeBlock) {
            require(vestingSimpleStake(sender) == 0, "Tempo de bloqueio precisa estar zerado");
        }
        SimpleStake storage isUser = simpleStake[sender];
        isUser.rewardWithdraw += lastRewardUpdateSimpleStake(sender);
        Balance storage isContract = contractBalance[address(this)];
        isContract.lpBalance -= isUser.rewardWithdraw;
        IBEP20(token).transfer(sender, isUser.rewardWithdraw);
        isUser.startBlock = block.timestamp;
        isUser.endBlock = block.timestamp + timeToBlock;
        isUser.rewardWithdraw = 0;
    }

    function withdrawRewardPrimeStake(address sender) external onlyStake nonReentrant {
        // Tempo de Bloqueio para retirada de Recompensas
        if(isTimeBlock) {
            require(vestingPrimeStake(sender) == 0, "Tempo de bloqueio precisa estar zerado");
        }
        PrimeStake storage isUser = primeStake[sender];
        isUser.rewardWithdraw += lastRewardUpdateSimpleStake(sender);
        Balance storage isContract = contractBalance[address(this)];
        isContract.lpBalance -= isUser.rewardWithdraw;
        IBEP20(token).transfer(sender, isUser.rewardWithdraw);
        isUser.startBlock = block.timestamp;
        isUser.endBlock = block.timestamp + timeToBlock;
        isUser.rewardWithdraw = 0;
    }

    function withdrawBNB() external onlyOwner nonReentrant {
        uint256 balance = address(this).balance;
        payable(wallet).transfer(balance);
        balance = 0;
    }

    function withdrawToken() external onlyOwner nonReentrant {
        uint256 balance = IBEP20(token).balanceOf(address(this));
        IBEP20(token).transfer(payable(wallet), balance);
        balance = 0;
    }

    // Recompensas do launchpad Stake
    function currentSimpleStake( SimpleStake memory isUser) private view returns(uint256) {
       return ((block.timestamp - isUser.startBlock) * isUser.initialBalance) / rewardsPerHour / rewardsPercentSimpleStake;
    }

    function currentPrimeStake( SimpleStake memory isUser) private view returns(uint256) {
       return ((block.timestamp - isUser.startBlock) * isUser.initialBalance) / rewardsPerHour / rewardsPercentPrimeStake;
    }

    function lastRewardUpdateSimpleStake(address sender) public view  returns(uint256 claimable) {
        SimpleStake memory isUser = simpleStake[sender];
        if(isUser.isStaking) {
            return isUser.rewardWithdraw += currentSimpleStake(isUser);
        } else {
            return isUser.rewardWithdraw = 0;
        }
    }

    function lastRewardUpdatePrimeStake(address sender) public view  returns(uint256 claimable) {
        SimpleStake memory isUser = simpleStake[sender];
        if(isUser.isStaking) {
            return isUser.rewardWithdraw += currentPrimeStake(isUser);
        } else {
            return isUser.rewardWithdraw = 0;
        }
    }

    function vestingSimpleStake(address sender) public view returns(uint256 blockTime) {
        SimpleStake memory isUser = simpleStake[sender];
        uint256 currentTime = block.timestamp;
        if(currentTime >= isUser.endBlock) {
            return 0;
        }
        else {
            return (isUser.endBlock - currentTime);
        }
    }

    function vestingPrimeStake(address sender) public view returns(uint256 blockTime) {
        PrimeStake memory isUser = primeStake[sender];
        uint256 currentTime = block.timestamp;
        if(currentTime >= isUser.endBlock) {
            return 0;
        }
        else {
            return (isUser.endBlock - currentTime);
        }
    }

}