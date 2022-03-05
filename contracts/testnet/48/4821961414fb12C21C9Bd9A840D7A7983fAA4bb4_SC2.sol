/**
 *Submitted for verification at BscScan.com on 2022-03-04
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

contract SC2 is Ownable {

    // address private _BUSDADDRESS = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; //mainnet
    address public _BUSDADDRESS = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7; //testnet
    address public _THALESADDRESS = 0xdb87DAA927182eA2FCb1626aCcf89a0F82BE8d5e; //testnet
    address public _eABCDADDRESS = 0x792ae2F4Dc646D6fbfe291fC4280daCCB729b5A2;  //mainnet
    address public _SC3ADDRESS = 0x8CeD8414c507AF9cB4082a4044cFB372998bA382;

    uint256 public stake_eABCD_period = 3600;
    uint256 public stake_BUSD_period = 3600;
    uint256 public stake_eABCD_amount = 10;
    uint256 public stake_BUSD_amount = 10;

    uint256 public _MAX_eABCD = 100;
    uint256 public _MAX_BUSD = 100;

    address [] public address_staked;
    mapping (address => stakeState) public stake_data;

    struct stakeState {
        bool isStaked;
        stakeItem[] stakeElement;
    }
    
    struct stakeItem {
        uint256 amount;
        uint256 dateStaked;
        uint256 stakeType; //0 : unstaked, 1 : BUSD, 2 : eABCD
        
    }
    
    function setTHALESAddress(address addr) public onlyOwner{
        _THALESADDRESS = addr;
    }
    function setEABCDAddress(address addr) public onlyOwner{
        _eABCDADDRESS = addr;
    }
    function setSC3Address(address addr) public onlyOwner{
        _SC3ADDRESS = addr;
    }
    function setStakeEABCDPeriod(uint256 period) public onlyOwner{
        stake_eABCD_period = period;
    }
    function setStakeBUSDPeriod(uint256 period) public onlyOwner{
        stake_BUSD_period = period;
    }
    function setStakeEABCDAmount(uint256 amount) public onlyOwner{
        stake_eABCD_amount = amount;
    }
    function setStakeBUSDAmount(uint256 amount) public onlyOwner{
        stake_BUSD_amount = amount;
    }
    function setMaxEABCD(uint256 amount) public onlyOwner{
        _MAX_eABCD = amount;
    }
    function setMaxBUSD(uint256 amount) public onlyOwner{
        _MAX_BUSD = amount;
    }
    function stakeEABCD(uint256 amount) public {
        require((amount + IBEP20(_eABCDADDRESS).balanceOf(address(this))) < _MAX_eABCD * 10 ** 18, "overflow with eABCD");
        bool trx = IBEP20(_eABCDADDRESS).transferFrom(msg.sender, address(this), amount);
        require(trx, "transfer for eABCD failed");
        stakeItem memory init;
        init.amount = amount;
        init.dateStaked = block.timestamp;
        init.stakeType = 2;
        stake_data[msg.sender].isStaked = true;
        stake_data[msg.sender].stakeElement.push(init);
    }
    function stakeBUSD(uint256 amount) public {
        require((amount + IBEP20(_BUSDADDRESS).balanceOf(address(this))) < _MAX_BUSD * 10 ** 18, "overflow with BUSD");
        bool trx = IBEP20(_BUSDADDRESS).transferFrom(msg.sender, address(this), amount);
        require(trx, "transfer for BUSD failed");
        stakeItem memory init;
        init.amount = amount;
        init.dateStaked = block.timestamp;
        init.stakeType = 1;
        stake_data[msg.sender].isStaked = true;
        stake_data[msg.sender].stakeElement.push(init);
    }
    function getRewardInTHALESForOwner( address addr) internal view returns(uint256){
        require(stake_data[msg.sender].isStaked, "not stake yet");
        uint256 BUSD_decimal = IBEP20(_BUSDADDRESS).decimals();
        uint256 THALES_decimal = IBEP20(_THALESADDRESS).decimals();
        uint256 eABCD_decimal = IBEP20(_eABCDADDRESS).decimals();
        uint256 totalReward = 0;
        for(uint i=0; i<stake_data[msg.sender].stakeElement.length; i++){
            if(stake_data[msg.sender].stakeElement[i].stakeType == 2)
                totalReward += stake_data[msg.sender].stakeElement[i].amount * stake_eABCD_amount * (block.timestamp - stake_data[msg.sender].stakeElement[i].dateStaked) * ( 10 ** THALES_decimal) / stake_eABCD_period / (10 ** eABCD_decimal);
            if(stake_data[msg.sender].stakeElement[i].stakeType == 1)
                totalReward += stake_data[msg.sender].stakeElement[i].amount * stake_BUSD_amount * (block.timestamp - stake_data[msg.sender].stakeElement[i].dateStaked) * ( 10 ** THALES_decimal) / stake_BUSD_period / ( 10 ** BUSD_decimal);
        }
        return totalReward;
    }
    function getRewardInTHALES() public view returns(uint256){
        return getRewardInTHALESForOwner(msg.sender);
    }
    function claimRewardInTHALES(uint256 amount) public {
        require(amount < getRewardInTHALESForOwner(msg.sender), "Insufficient Fund For msgSender");
        require(amount <= IBEP20(_THALESADDRESS).balanceOf(address(this)), "Insufficient Fund");
        IBEP20(_THALESADDRESS).transfer(msg.sender, amount);
    }
    function sellOrderForEABCD(uint256 amount) public onlyOwner{
        uint256 balanceForBUSD = IBEP20(_BUSDADDRESS).balanceOf(address(this));
        bool trx = IBEP20(_eABCDADDRESS).transferFrom(msg.sender, address(this), amount);
        require(trx, "transfer for eABCD failed");
        uint256 tokenPriceWithOracle = ISC3(_SC3ADDRESS).getAssetPrice();
        require(balanceForBUSD > amount * tokenPriceWithOracle, "Insufficient Fund");
        IBEP20(_BUSDADDRESS).transfer(msg.sender, amount * tokenPriceWithOracle);

    }
}