/**
 *Submitted for verification at BscScan.com on 2022-06-24
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }


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


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


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
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }


    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

 
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }


    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }


    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }


    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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


contract Staking is Ownable, ReentrancyGuard{

    using Address for address;
    // Contador de Users para Stake
    uint256 public simpleStakeLimit = 600;
    uint256 public primeStakeLimit = 300;
    // Endereço do Token
    IBEP20 public token;
    // Endereço Owner
    address public wallet;
    // Porcentagem e Rendimento Stake
    uint256 public simpleRHT = 500000;
    uint256 public primeRHT = 5000000;
    uint256 public maxSimpleRHT = 5000000;
    uint256 public maxPrimeRHT = 50000000;
    uint256 public rewardsPerHour = 3600;
    uint256 public rewardsPercentSimpleStake = 20000;
    uint256 public rewardsPercentPrimeStake = 10000;
    uint256 public  endBLockStake = block.timestamp + 2600000;
    // Preço em BNB
    uint public priceBNBSimpleStake = 6000000000000000;
    uint public priceBNBPrimeStake = 6000000000000000;
    // Bolleano para Definir tempo de bloqueio
    bool public isTimeBlock = true;
    bool public isBNB = true;
    bool public isRequireUser = true;
    bool public stopStake = false;

    mapping(address => SimpleStake) public simpleStake;
    mapping(address => PrimeStake) public primeStake;
    mapping(address => Balance) public contractBalance;
    mapping(address => CounterBalance) public counterBalance;



    // Estruturas

    struct CounterBalance {
        uint256 counterSimple;
        uint256 counterPrime;
    }

    struct PrimeStake {
        address payable user;
        uint startBlock;
        uint256 initialBalance;
        uint256 rewardWithdraw;
        uint256 percentReward;
        bool isStaking;
    }

    struct SimpleStake {
        address payable user;
        uint startBlock;
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
    modifier onlyStakeSimple() {
        SimpleStake storage isUser = simpleStake[msg.sender];
        require(isUser.isStaking, "Must be in Staking");
        _;
    }

        modifier onlyStakePrime() {
        PrimeStake storage isUser = primeStake[msg.sender];
        require(isUser.isStaking, "Must be in Staking");
        _;
    }

    // Permite que o contrato Receba e transfira BNB
    receive() external payable {}

    function setIstimeBlockAndBNBPrice(bool _isTimeBlock, bool _isBNB) external onlyOwner {
        isTimeBlock = _isTimeBlock;
        isBNB = _isBNB;
    }



   function setPercents(uint256 _rewardsPerHour, uint256 _rewardsPercentSimpleStake, uint256 _rewardsPercentPrimeStake) external onlyOwner {
      rewardsPerHour =  _rewardsPerHour;
      rewardsPercentSimpleStake = _rewardsPercentSimpleStake;
      rewardsPercentPrimeStake = _rewardsPercentPrimeStake;
   }
   
    function setContractAddress(address _token) external onlyOwner {
        token = IBEP20(_token);
    }

    function setStopStake(bool _stopStake) external onlyOwner {
        stopStake = _stopStake;
    }

    function setLimitePerStake(uint256 _simpleStakeLimit, uint256 _primeStakeLimit) external onlyOwner {
        simpleStakeLimit = _simpleStakeLimit;
        primeStakeLimit = _primeStakeLimit;
    }

    function setWalletAddress(address _wallet) external onlyOwner {
        wallet = _wallet;
    }

    function verifySimpleStake(address sender) public view returns(bool) {
        SimpleStake storage isUser = simpleStake[sender];
        if(isUser.isStaking) {
            return true;
        } else {
            return false;
        }
    }

    function verifyPrimeStake(address sender) public view returns(bool) {
        PrimeStake storage isUser = primeStake[sender];
        if(isUser.isStaking) {
            return true;
        } else {
            return false;
        }
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

    function setCounterEmergency(uint _simple, uint _prime) external onlyOwner {
        CounterBalance storage counters = counterBalance[address(this)];
        counters.counterSimple = _simple;
        counters.counterPrime = _prime;
    }

    function balanceLiquidityStake() public view returns(uint256) {
        Balance storage isContract = contractBalance[address(this)];
        return isContract.lpBalance;
    }

    function removePollRewards() external onlyOwner nonReentrant{
        Balance storage isContract = contractBalance[address(this)];
        IBEP20(token).transfer(msg.sender, isContract.lpBalance);
         isContract.lpBalance = 0;
    }

    function setEndBLock(uint256 timeTo) external onlyOwner {
        endBLockStake = block.timestamp + timeTo;
    }

    function removePoolUser() external onlyOwner nonReentrant{
        Balance storage isContract = contractBalance[address(this)];
        uint totalWithdraw = isContract.primeBalance + isContract.simpleBalance;
        IBEP20(token).transfer(msg.sender, totalWithdraw);
        isContract.simpleBalance = 0;
        isContract.primeBalance  = 0;
        totalWithdraw = 0;
    }

    function _forwardFunds() private {
    require(wallet != address(0), "Cannot withdraw the ETH balance to the zero address");
      payable(wallet).transfer(msg.value);
    }


    function setMaxStake(uint256 _simpleRHT, uint256 _primeRHT, uint256 _maxSimpleRHT, uint256 _maxPrimeRHT) external onlyOwner {
        simpleRHT = _simpleRHT ;
        primeRHT = _primeRHT;
        maxSimpleRHT = _maxSimpleRHT;
        maxPrimeRHT = _maxPrimeRHT;
    }

    function setIsRequireUser(bool _isRequireUser) external onlyOwner {
        isRequireUser = _isRequireUser;
    }
    
    
    function simpleStakeLaunch(uint256 _amount) external payable nonReentrant{
        if(isBNB) {
        require(msg.value == priceBNBSimpleStake, "Must be identical to the set price");
        _forwardFunds();
        }
        // Inicia o Stake do Usuario
        SimpleStake storage isUser = simpleStake[msg.sender];
        require(_amount  > simpleRHT && _amount <= maxSimpleRHT, "Must be greater than the minimum and less than the maximum");
        if(isUser.initialBalance == 0) {
        CounterBalance storage counters = counterBalance[address(this)];
        counters.counterSimple += 1;
        uint256 newUser = counters.counterSimple;
        require(newUser <= simpleStakeLimit, "Holders limit reached");
        isUser.startBlock = block.timestamp;
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
        if(isUser.initialBalance > maxSimpleRHT) {
        require(isUser.initialBalance <= maxSimpleRHT, "Stake Limit Reached");
        }
    }



    function primeStakeLaunch(uint256 _amount) external payable nonReentrant{
        if(isBNB) {
        require(msg.value == priceBNBPrimeStake, "Must be identical to the set price");
        _forwardFunds();
        }
        // Inicia o Stake do Usuario
        PrimeStake storage isUser = primeStake[msg.sender];
        require(_amount > primeRHT && _amount <= maxPrimeRHT, "Must be greater than the minimum and less than the maximum");

        if(isUser.initialBalance == 0) {
        CounterBalance storage counters = counterBalance[address(this)];
        counters.counterPrime += 1;
        uint256 newUser = counters.counterPrime;
        require(newUser <= primeStakeLimit, "Holders limit reached");
        isUser.startBlock = block.timestamp;
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
        if(isUser.initialBalance > maxPrimeRHT) {
         require(isUser.initialBalance <= maxPrimeRHT, "Stake Limit Reached");
        }


    }
    // Retira os Tokens Aportados
    function removeMyTokenSimpleStake(address sender) external payable onlyStakeSimple nonReentrant {
        if(isBNB) {
        require(msg.value == priceBNBSimpleStake, "Must be identical to the set price");
        _forwardFunds();
        }
        require(!stopStake, "Withdrawals Disable");
        // Inicia o Stake do Usuario
        SimpleStake storage isUser = simpleStake[sender];
        require(isUser.isStaking, "Need to be staking");
        // Atualiza o saldo do Contrato
        CounterBalance storage counters = counterBalance[address(this)];
        
        if(counters.counterSimple < 1) {
        counters.counterSimple = 0;
        } else {
            counters.counterSimple -= 1;
        }

        Balance storage isContract = contractBalance[address(this)];
        isUser.isStaking = false;
        isUser.startBlock = 0;
        isUser.rewardWithdraw = 0;
        IBEP20(token).transfer(isUser.user, isUser.initialBalance);
        isContract.simpleBalance -= isUser.initialBalance;
        isUser.initialBalance = 0;
    }
    // Retira os Tokens Aportados
    function removeMyTokenPrimeStake(address sender) external payable onlyStakePrime nonReentrant {
        if(isBNB) {
        require(msg.value == priceBNBSimpleStake, "Must be identical to the set price");
        _forwardFunds();
        }
        require(!stopStake, "Withdrawals Disable");
        // Inicia o Stake do Usuario
        PrimeStake storage isUser = primeStake[sender];
        require(isUser.isStaking, "Need to be staking");
        // Atualiza o saldo do Contrato
        CounterBalance storage counters = counterBalance[address(this)];
        
        if(counters.counterPrime < 1) {
        counters.counterPrime = 0;
        } else {
            counters.counterPrime -= 1;
        }
        
        Balance storage isContract = contractBalance[address(this)];
        isUser.isStaking = false;
        isUser.startBlock = 0;
        isUser.rewardWithdraw = 0;
        IBEP20(token).transfer(isUser.user, isUser.initialBalance);
        isContract.primeBalance -= isUser.initialBalance;
        isUser.initialBalance = 0;
    }
    // Retira Recompensas
    function withdrawRewardSimpleStake(address sender) external payable onlyStakeSimple nonReentrant {
        if(isBNB) {
        require(msg.value == priceBNBSimpleStake, "Must be identical to the set price");
        _forwardFunds();
        }
        // Tempo de Bloqueio para retirada de Recompensas
        if(isTimeBlock) {
            require(vestingTime() == 0, "Blocking time must be set to zero");
        }
        SimpleStake storage isUser = simpleStake[sender];
        require(isUser.isStaking, "Need to be staking");
        isUser.rewardWithdraw += lastRewardUpdateSimpleStake(sender);
        Balance storage isContract = contractBalance[address(this)];
        isContract.lpBalance -= isUser.rewardWithdraw;
        IBEP20(token).transfer(sender, isUser.rewardWithdraw);
        isUser.startBlock = 0;
        isUser.rewardWithdraw = 0;
    }

    // Retira Recompensas
    function withdrawRewardPrimeStake(address sender) external payable onlyStakePrime nonReentrant {
        if(isBNB) {
        require(msg.value == priceBNBSimpleStake, "Must be identical to the set price");
        _forwardFunds();
        }
        // Tempo de Bloqueio para retirada de Recompensas
        if(isTimeBlock) {
            require(vestingTime() == 0, "Blocking time must be set to zero");
        }
        PrimeStake storage isUser = primeStake[sender];
        require(isUser.isStaking, "Need to be staking");
        isUser.rewardWithdraw += lastRewardUpdatePrimeStake(sender);
        Balance storage isContract = contractBalance[address(this)];
        isContract.lpBalance -= isUser.rewardWithdraw;
        IBEP20(token).transfer(sender, isUser.rewardWithdraw);
        isUser.startBlock = 0;
        isUser.rewardWithdraw = 0;
    }

    /*
    *   Retira BNB do Contrato
    * @Apenas Owner
    */
    function withdrawBNB() external onlyOwner nonReentrant {
        uint256 balance = address(this).balance;
        payable(wallet).transfer(balance);
        balance = 0;
    }

    /*
    *   Retira tokens do Contrato
    * @Apenas Owner
    */
    function withdrawToken() external onlyOwner nonReentrant {
        uint256 balance = IBEP20(token).balanceOf(address(this));
        IBEP20(token).transfer(wallet, balance);
        balance = 0;
    }

    // Recompensas do launchpad Stake
    function currentSimpleStake( SimpleStake memory isUser) private view returns(uint256) {
       return ((block.timestamp - isUser.startBlock) * isUser.initialBalance) / rewardsPerHour / rewardsPercentSimpleStake;
    }
    // Recompensas do launchpad Stake
    function currentPrimeStake( PrimeStake memory isUser) private view returns(uint256) {
       return ((block.timestamp - isUser.startBlock) * isUser.initialBalance) / rewardsPerHour / rewardsPercentPrimeStake;
    }

    // Recompensa Simple
    function lastRewardUpdateSimpleStake(address sender) public view  returns(uint256 claimable) {
        SimpleStake memory isUser = simpleStake[sender];
        if(isUser.isStaking) {
            return isUser.rewardWithdraw += currentSimpleStake(isUser);
        } else {
            return isUser.rewardWithdraw = 0;
        }
    }

    // Recompensa Prime
    function lastRewardUpdatePrimeStake(address sender) public view  returns(uint256 claimable) {
        PrimeStake memory isUser = primeStake[sender];
        if(isUser.isStaking) {
            return isUser.rewardWithdraw += currentPrimeStake(isUser);
        } else {
            return isUser.rewardWithdraw = 0;
        }
    }
    

    // Saldo Prime
    function vestingTime() public view returns(uint256 blockTime) {
        uint256 currentTime = block.timestamp;
        if(currentTime >= endBLockStake) {
            return 0;
        }
        else {
            return (endBLockStake - currentTime);
        }
    }

}