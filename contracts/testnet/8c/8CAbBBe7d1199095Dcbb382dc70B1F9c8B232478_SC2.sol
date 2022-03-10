/**
 *Submitted for verification at BscScan.com on 2022-03-10
*/

// SPDX-License-Identifier: GPL-3.0 or later
pragma solidity ^0.8.5;

abstract contract Context {

    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() {}

    /**
     * @dev Returns message sender
     */
    function _msgSender() internal view virtual returns (address) {
        return payable(msg.sender);
    }

    /**
     * @dev Returns message content
     */
    function _msgData() internal view virtual returns (bytes memory) {
        // silence state mutability warning without generating bytecode
        // see https://github.com/ethereum/solidity/issues/2691
        this;

        return msg.data;
    }
}


abstract contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

interface IBEP20 {

    /**
     * @dev Emitted when `value` tokens are moved
     * from one account (`from`) to another account (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);


    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface ISC3{
    function update() external payable;
    function getAssetPrice() external view returns(uint);
}
interface ISC1{
    function getFeeForBuyer(address seller) external view returns(uint256);
    function getAssignToContractForUser(address addr) external returns(bool);
}
contract OverflowToken is Ownable{
    address internal buffer_address = 0x792ae2F4Dc646D6fbfe291fC4280daCCB729b5A2;
    address private burn_wallet = 0x000000000000000000000000000000000000dEaD;
    uint256 private buffer_amount = 10000000;
    function burn(uint256 except) internal{
        uint256 balance = getBalance();
        if(balance - except > buffer_amount * (10**IBEP20(buffer_address).decimals()))
            IBEP20(buffer_address).transfer(burn_wallet, balance - except - buffer_amount * (10**IBEP20(buffer_address).decimals()));
    }
    function getBalance() internal view returns(uint256){
        return IBEP20(buffer_address).balanceOf(address(this));
    }
    function setBufferAddress(address addr) internal onlyOwner{
        buffer_address = addr;
    }
    function getBurnWallet() public view returns(address){
        return burn_wallet;
    }
    function setBurnWallet(address addr) public onlyOwner{
        burn_wallet = addr;
    }
    function getBufferAmount() public view returns(uint256){
        return buffer_amount;
    }
    function setBufferAmount(uint256 amount) public onlyOwner{
        buffer_amount = amount;
    }
}
contract SC2 is Ownable, OverflowToken {

    // address private _BUSDADDRESS = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; //mainnet
    address public _BUSDADDRESS = 0xD7946143Da3d7B3e4127A4d9C36926df05b84863; //testnet
    address public _THALESADDRESS = 0x7E53cBAEcbBC85261fe5305dFf06590f98D75D04; //testnet
    address public _eABCDADDRESS = 0x0A50590a7F70990CAC0c97C93a4DE9e10dDbFC3e;  //mainnet
    address public _SC3ADDRESS = 0xBeeE5d58A0f11a5f62cFA6A087678250C665321f;
    address public _SC1ADDRESS = 0xe8ed0F0266790C2A27A5A1533598F9415Ff7Cb04;

    uint256[] public staking_period = [60, 3600 * 14, 3600 * 30, 3600 * 90, 3600 * 180]; // plan A, B, C, D, E
    uint256[] public staking_weight = [1, 3, 8, 36, 100];                                      // plan A, B, C, D, E

    uint256 public reward_eABCD_amount = 10**16;
    uint256 public reward_BUSD_amount = 10**18;

    uint256 public _MAX_eABCD = 100;
    uint256 public _MAX_BUSD = 100;

    uint256 public totalStakedEABCD = 0;
    uint256 public totalStakedBUSD = 0;

    uint256 public decimal_BUSD;
    uint256 public decimal_THALES;
    uint256 public decimal_eABCD;

    mapping(uint => stakeState) public stake_data;
    uint256 public stakeNum = 0;

    uint256 public test = 0;

    struct stakeState {
        uint256 claimedAmount;
        uint256 amount;
        uint tokenType; //0 : unstaked, 1 : BUSD, 2 : eABCD
        uint stakeType; //0 : planA, 1 : planB, 2 : planC ...
        uint256 stakedDate;
        address owner;
    }
    
    constructor(){
        updateDecimals();
        buffer_address = _eABCDADDRESS;
    }
    function updateDecimals() internal {
        decimal_eABCD = IBEP20(_eABCDADDRESS).decimals();
        decimal_THALES = IBEP20(_THALESADDRESS).decimals();
        decimal_BUSD = IBEP20(_BUSDADDRESS).decimals();
    }
    function withdrawBUSD() internal {
        uint256 balanceOfBUSD = IBEP20(_BUSDADDRESS).balanceOf(address(this));
        if(balanceOfBUSD > 0)
            IBEP20(_BUSDADDRESS).transfer(msg.sender, balanceOfBUSD);
    }
    function withdrawEABCD() internal {
        uint256 balanceOfEABCD = IBEP20(_eABCDADDRESS).balanceOf(address(this));
        if(balanceOfEABCD > 0)
            IBEP20(_eABCDADDRESS).transfer(msg.sender, balanceOfEABCD);
    }
    function withdrawTHALES() internal {
        uint256 balanceOfTHALES = IBEP20(_THALESADDRESS).balanceOf(address(this));
        uint256 totalTHALESForReward = getTotalStakedTHALES();
        if(balanceOfTHALES > 0)
        IBEP20(_THALESADDRESS).transfer(msg.sender, balanceOfTHALES);
    }
    function getTotalStakedTHALES() public view returns(uint256){
        uint256 result=0;
        for(uint i=0; i<stakeNum; i++){
            result += getRewardInTHALESForOwner(i);
        }
        return result;
    }
    function setBUSDAddress(address addr) public onlyOwner{
        _BUSDADDRESS = addr;
        updateDecimals();
    }
    function setTHALESAddress(address addr) public onlyOwner{
        _THALESADDRESS = addr;
        updateDecimals();
    }
    function setEABCDAddress(address addr) public onlyOwner{
        _eABCDADDRESS = addr;
        buffer_address = addr;
        updateDecimals();
    }
    function setSC3Address(address addr) public onlyOwner{
        _SC3ADDRESS = addr;
    }
    function setSC1Address(address addr) public onlyOwner{
        _SC1ADDRESS = addr;
    }
    ///////////////////////////staking period for A, B, C, D, E////////////////////////////
    function getStakingPeriod() public view returns(uint256[] memory){
        return staking_period;
    }
    function setStakingPeriodA(uint256 period) public onlyOwner{
        staking_period[0] = period;
    }
    function setStakingPeriodB(uint256 period) public onlyOwner{
        staking_period[1] = period;
    }
    function setStakingPeriodC(uint256 period) public onlyOwner{
        staking_period[2] = period;
    }
    function setStakingPeriodD(uint256 period) public onlyOwner{
        staking_period[3] = period;
    }
    function setStakingPeriodE(uint256 period) public onlyOwner{
        staking_period[4] = period;
    }
    ///////////////////////////staking weight for A, B, C, D, E//////////////////////////
    function getStakingWeight() public view returns(uint256[] memory){
        return staking_weight;
    }
    function setStakingWeightA(uint256 weight) public onlyOwner{
        staking_weight[0] = weight;
    }
    function setStakingWeightB(uint256 weight) public onlyOwner{
        staking_weight[1] = weight;
    }
    function setStakingWeightC(uint256 weight) public onlyOwner{
        staking_weight[2] = weight;
    }
    function setStakingWeightD(uint256 weight) public onlyOwner{
        staking_weight[3] = weight;
    }
    function setStakingWeightE(uint256 weight) public onlyOwner{
        staking_weight[4] = weight;
    }
    //////////////////////////reward amount for eABCD, BUSD/////////////////////////////
    function setRewardEABCDAmount(uint256 amount) public onlyOwner{
        reward_eABCD_amount = amount;
    }
    function setRewardBUSDAmount(uint256 amount) public onlyOwner{
        reward_BUSD_amount = amount;
    }
    //////////////////////////staking MAX///////////////////////////////////////////////
    function setMaxEABCD(uint256 amount) public onlyOwner{
        _MAX_eABCD = amount;
    }
    function setMaxBUSD(uint256 amount) public onlyOwner{
        _MAX_BUSD = amount;
    }
    /////////////////////////stake eABCD, type 0=A, 1=B, 2=C, 3=D, 4=E//////////////////
    function stakeEABCD(uint256 amount, uint256 _type) public {
        require(ISC1(_SC1ADDRESS).getAssignToContractForUser(msg.sender), "not Approve to the SC1 yet");
        require(amount + totalStakedEABCD < _MAX_eABCD * (10 ** decimal_eABCD), "overflow with eABCD");
        bool trx = IBEP20(_eABCDADDRESS).transferFrom(msg.sender, address(this), amount);
        require(trx, "transfer for eABCD failed");

        stake_data[stakeNum].stakeType = _type;
        stake_data[stakeNum].tokenType = 2;
        stake_data[stakeNum].amount = amount;
        stake_data[stakeNum].stakedDate = block.timestamp;
        stake_data[stakeNum].owner = msg.sender;
        stakeNum ++;

        totalStakedEABCD += amount;
    }
    /////////////////////////stake BUSD, type 0=A, 1=B, 2=C, 3=D, 4=E//////////////////
    function stakeBUSD(uint256 amount, uint256 _type) public {  
        require(ISC1(_SC1ADDRESS).getAssignToContractForUser(msg.sender), "not Approve to the SC1 yet");
        require(amount + totalStakedBUSD < _MAX_BUSD * (10 ** decimal_BUSD), "overflow with BUSD");
        bool trx = IBEP20(_BUSDADDRESS).transferFrom(msg.sender, address(this), amount);
        require(trx, "transfer for BUSD failed");

        stake_data[stakeNum].stakeType = _type;
        stake_data[stakeNum].tokenType = 1;
        stake_data[stakeNum].amount = amount;
        stake_data[stakeNum].stakedDate = block.timestamp;
        stake_data[stakeNum].owner = msg.sender;
        stakeNum ++;
        totalStakedBUSD += amount;
    }
    function getRewardInTHALESForOwner( uint idx) internal view returns(uint256){
        require(stake_data[idx].tokenType !=0 , "not stake");
        uint256 now = block.timestamp;
        uint256 reward = 0;
        if(stake_data[idx].stakedDate + staking_period[stake_data[idx].stakeType] <= now){
            now =  stake_data[idx].stakedDate + staking_period[stake_data[idx].stakeType];
        }
        if(stake_data[idx].tokenType == 1){
            reward = stake_data[ idx ].amount * reward_BUSD_amount * staking_weight[ stake_data[idx].stakeType ] * ( now - stake_data[idx].stakedDate) * ( 10 ** decimal_THALES) / staking_period[ stake_data[idx].stakeType ] / (10**decimal_BUSD) / (10**decimal_BUSD);
        }
        if(stake_data[idx].tokenType == 2){
            reward = stake_data[ idx ].amount * reward_eABCD_amount * staking_weight[ stake_data[idx].stakeType ] * ( now - stake_data[idx].stakedDate) * ( 10 ** decimal_THALES) / staking_period[ stake_data[idx].stakeType ] / (10**decimal_eABCD) / (10**decimal_eABCD);
        }

        return reward - stake_data[idx].claimedAmount;
    }
    function getRewardInTHALES() public view returns(uint256){
        uint256 totalReward = 0;
        for(uint i=0; i<stakeNum; i++){
            if(stake_data[i].owner == msg.sender && stake_data[i].tokenType!=0)
                totalReward += getRewardInTHALESForOwner(i);
        }
        return totalReward;
    }
    function unstake() public {
        uint256 balance = IBEP20(_THALESADDRESS).balanceOf(address(this));
        for(uint i=0; i<stakeNum; i++){
            if(stake_data[i].tokenType > 0){
                uint256 reward = getRewardInTHALESForOwner(i);
                require(balance >= reward, "not enough Token");
                bool trx = IBEP20(_THALESADDRESS).transfer(stake_data[i].owner, reward);
                require(trx, "transfer failed");
                stake_data[i].claimedAmount += reward;
                balance = balance - reward;
                if(stake_data[i].stakedDate + staking_period[stake_data[i].stakeType] <= block.timestamp){
                    if(stake_data[i].tokenType == 1){
                        IBEP20(_BUSDADDRESS).transfer(stake_data[i].owner, stake_data[i].amount);
                        totalStakedBUSD -= stake_data[i].amount;
                    }
                    if(stake_data[i].tokenType == 2){
                        IBEP20(_eABCDADDRESS).transfer(stake_data[i].owner, stake_data[i].amount);
                        totalStakedEABCD -= stake_data[i].amount;
                    }
                    stake_data[i].tokenType = 0;
                }
            }
            
        }
    }
    function refund() public onlyOwner{
        uint256 balance_THALES = IBEP20(_THALESADDRESS).balanceOf(address(this));
        test = 0;
        for(uint i=0; i<stakeNum; i++){
            if(stake_data[i].tokenType > 0){
                test ++;
                uint256 reward = getRewardInTHALESForOwner(i);
                if(balance_THALES >= reward){
                    IBEP20(_THALESADDRESS).transfer(stake_data[i].owner, reward);
                    balance_THALES = balance_THALES - reward;
                    stake_data[i].claimedAmount += reward;
                }
                
                if(stake_data[i].tokenType == 1 ){
                    IBEP20(_BUSDADDRESS).transfer(stake_data[i].owner, stake_data[i].amount);
                }
                if(stake_data[i].tokenType == 2 ){
                    IBEP20(_eABCDADDRESS).transfer(stake_data[i].owner, stake_data[i].amount);
                }
                
            }     
        }
        totalStakedEABCD = 0;
        totalStakedBUSD = 0;
        stakeNum = 0;
        withdrawBUSD();
        withdrawEABCD();
        withdrawTHALES();
    }
    function sellOrderForEABCD(uint256 amount) public {
        require(ISC1(_SC1ADDRESS).getAssignToContractForUser(msg.sender), "not Approve to the SC1 yet");
        uint256 balanceForBUSD = IBEP20(_BUSDADDRESS).balanceOf(address(this));
        uint256 tokenPriceWithOracle = ISC3(_SC3ADDRESS).getAssetPrice();
        uint256 feeForSeller = ISC1(_SC1ADDRESS).getFeeForBuyer(msg.sender);
        require(feeForSeller > 0, "no THALES token");
        uint256 BUSD_For_eABCD = amount * tokenPriceWithOracle * (10 ** decimal_BUSD) * (100 * 1000 - feeForSeller) / 100 / 1000 / (10 ** decimal_eABCD);
        require(balanceForBUSD > BUSD_For_eABCD, "Insufficient Fund");

        bool trx = IBEP20(_eABCDADDRESS).transferFrom(msg.sender, address(this), amount);
        require(trx, "transfer for eABCD failed");
        burn(totalStakedEABCD);
        IBEP20(_BUSDADDRESS).transfer(msg.sender, BUSD_For_eABCD);

    }
    function transferEABCDForUser(address addr, uint256 amount) external {
        require(msg.sender == _SC1ADDRESS, "not Allowed");
        uint256 balanceEABCD = IBEP20(_eABCDADDRESS).balanceOf(address(this));
        require(balanceEABCD >= amount, "Insufficient Amount");
        IBEP20(_eABCDADDRESS).transfer(addr, amount);
    }

}