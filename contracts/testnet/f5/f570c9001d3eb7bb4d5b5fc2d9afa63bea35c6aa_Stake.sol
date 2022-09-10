/**
 *Submitted for verification at BscScan.com on 2022-09-09
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-30
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


/**
 * @dev Interface of the BEP20 standard as defined in the BIP.
 */
interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

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

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

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
}

contract Stake is Ownable {

    IBEP20 private token;

    struct UserStruct{
        bool isExist;
        address referral;   
        uint256 totalClaimed;
        uint256 directReferralCount;
        uint256[] stakingIds; 
    }

    struct StakeStruct {
        address staker;
        uint256 amount;
        uint256 stakeTime;
    }

    uint256 private stakingId = 0;
    uint256 private userId = 0;
    uint256 private rewardPer = 50;
    address private signer;

    mapping(address => UserStruct)private userDetails;
    mapping (uint256 => StakeStruct) private stakeDetails;

    event Staked(address indexed staker, uint256 amount, address referral, uint256 time);
   
    event Claimed(address staker, uint256 amount, uint256 time);

    function intialize(address _token) public onlyOwner returns (bool){
        require(_token != address(0),"Invalid Address");
        token = IBEP20(_token);
        return true;
    }

    function stake(uint256 _amount, address _referral) public returns(bool) {
        require(msg.sender != _referral, "Staker and referral address must not same");
        require(_referral == address(0) || userDetails[_referral].isExist || userDetails[msg.sender].isExist, "Wrong Referral");
        require (IBEP20(token).allowance(msg.sender, address(this)) >= _amount, "Token not approved");  
        require((_amount * 10**20) / 10 **20 == _amount, "Amount must be multiply by 10");
        IBEP20(token).transferFrom(msg.sender, address(this), _amount);     
        if(!userDetails[msg.sender].isExist){
            UserStruct memory userInfo;
            userInfo = UserStruct({
                isExist             : true, 
                referral            : _referral,
                totalClaimed        : 0,
                directReferralCount : 0,
                stakingIds          : new uint256[](0)
            });
            userDetails[msg.sender] = userInfo;  
            userDetails[_referral].directReferralCount++;
        }
        
        StakeStruct memory stakerinfo;
        stakerinfo = StakeStruct({
            staker  : msg.sender,
            amount : _amount,
            stakeTime : block.timestamp
        });       
        stakeDetails[stakingId] = stakerinfo;       
        userDetails[msg.sender].stakingIds.push(stakingId);
        stakingId++;
        emit Staked(msg.sender, _amount, userDetails[msg.sender].referral, block.timestamp);
        return true;
    }

    function changeRewardPer(uint256 _per) public onlyOwner returns(bool){
        rewardPer = _per;
        return true;
    }

    function setSigner(address _signer) public onlyOwner returns(bool){
        signer = _signer;
        return true;
    }

    function transferTokens(uint256 _amount, address _token) public onlyOwner{
        require(IBEP20(_token).balanceOf(address(this)) > _amount , "Not Enough Tokens");
        IBEP20(_token).transfer(owner(), _amount);
    } 

    function claim(bytes32 _hash, uint8 _v, bytes32 _r, bytes32 _s, string memory message) public returns (bool){      
        require(userDetails[msg.sender].isExist, "Address is not a staker");
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHashMessage = keccak256(abi.encodePacked(prefix, _hash));
        bytes32 hashedMessage = keccak256(abi.encodePacked(message));
        uint256 amount = st2num(message);
        if(ecrecover(prefixedHashMessage, _v, _r, _s) == signer && hashedMessage == _hash){          
            token.transfer(msg.sender, amount);
            userDetails[msg.sender].totalClaimed += amount;  
            emit Claimed(msg.sender, amount, block.timestamp);          
        }                       
        return true;
    }

    function st2num(string memory numString) public pure returns(uint) {
        uint  val=0;
        bytes memory stringBytes = bytes(numString);
        for (uint  i =  0; i<stringBytes.length; i++) {
            uint exp = stringBytes.length - i;
            bytes1 ival = stringBytes[i];
            uint8 uval = uint8(ival);
           uint jval = uval - uint(0x30);
   
           val +=  (uint(jval) * (10**(exp-1))); 
        }
        return val;
    }

    function viewToken() public view returns(IBEP20){
        return token;
    }

    function viewUserDetails(address _staker) public view returns(uint256 len, uint256[] memory id, UserStruct memory){
        return (userDetails[_staker].stakingIds.length, userDetails[_staker].stakingIds, userDetails[_staker]);
    }

    function viewStakingDetails(uint256 _stakingId) public view returns(StakeStruct memory){
        return stakeDetails[_stakingId];
    }

    function viewCurrentStakingId() public view returns(uint256){
        return stakingId;
    }

    function viewROIPer() public view returns(uint256){
        return rewardPer;
    }
}