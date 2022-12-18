/**
 *Submitted for verification at BscScan.com on 2022-12-17
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
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


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// File: contracts/LuckyKing.sol


pragma solidity ^0.8.17;



interface IERC20Ext is IERC20 {
    function decimals() external view returns(uint8);
    function allowance(address owner, address spender) external view returns(uint256);
}

interface UtopiaRalationship {
    function setRecommender(address account, address recommender) external;
    function getRecommender(address account) external view returns (address);
}

interface UtopiaNFT {
    function balanceOf(address account) external view returns (uint256);
}

contract LuckyKing is  Ownable {
    IERC20Ext public UT;
    UtopiaRalationship public utopiaRalationship;
    UtopiaNFT public utopiaNFT;
    bool public pause;
    mapping(uint256 => bool) public moneys;
    uint256 public DrawAPrizeMoneys;
    uint256 public maxMoneys;
    address[] public participants;
    mapping(address => uint256) public userMaxStage;
    mapping(address => uint256[99999999]) public personalDetails;
    uint256 public stage;
    uint256 public randNonce;
    address[3] public winner;
    uint256[3] public luckyNumber;
    mapping(uint256 => address[]) public stageWinners;

    uint8 winnerRewardRatio = 90;
    uint8 recommendationRewardRatio = 10;
    uint8 serviceCharge = 10;

    constructor() {
        UT = IERC20Ext(0xE21Fe38F6f07BaeA3564e8dEF47bB66c8132afa5);
        setUtopiaRalationship(0x0154D748D57A6caDa0Faf15918af7bBc2f628f92);
        setUtopiaNFT(0x0154D748D57A6caDa0Faf15918af7bBc2f628f92);
        DrawAPrizeMoneys = 100;
        maxMoneys = 10;
        stage = 1;
        for(uint256 i=1;i<=DrawAPrizeMoneys;i++){
            moneys[i] = true;
        }
    }

    function join(uint256 num) public {
        require(pause == false, "[LuckyKing] paused!");
        require(utopiaNFT.balanceOf(msg.sender) > 0, "[LuckyKing] Not eligible to participate!");
        require(moneys[num] == true, "[LuckyKing] Invalid amount!");
        uint256 decimals = 10**UT.decimals();
        uint256 UT_amount = UT.allowance(msg.sender, address(this));
        uint256 amount = num*decimals;
        require(UT_amount >= amount,"[LuckyKing] UT Insufficient authorized amount!");
        require(UT.balanceOf(msg.sender) >= amount,"[LuckyKing] Insufficient token balance!");
        if(userMaxStage[msg.sender] != stage){
            personalDetails[msg.sender][stage] = 0;
            userMaxStage[msg.sender] = stage;
        }
        uint256 thisStageNum = personalDetails[msg.sender][stage];
        require(maxMoneys >= thisStageNum + num,"[LuckyKing] Purchase limit exceeded!");
        personalDetails[msg.sender][stage] += num;
        uint256 len = getLen();
        require(num <= DrawAPrizeMoneys-len,"[LuckyKing] Invalid number of participants!");
        UT.transferFrom(msg.sender, address(this), amount);
        for(uint256 i=0;i<num;i++){
            participants.push(msg.sender);
        }
        if( num + len >= DrawAPrizeMoneys ) {
            uint256 rAmount = DrawAPrizeMoneys * decimals;
            luckyNumber[0] = random(DrawAPrizeMoneys,1);
            luckyNumber[1] = random(DrawAPrizeMoneys,2);
            luckyNumber[2] = random(DrawAPrizeMoneys,3);
            winner[0] = participants[luckyNumber[0]];
            winner[1] = participants[luckyNumber[1]];
            winner[2] = participants[luckyNumber[2]];

            uint256 Reward;
            for(uint256 i=0;i<3;i++){
                Reward = DrawAPrizeMoneys * decimals * (100 - serviceCharge) / 100 / 3  * winnerRewardRatio / 100;
                UT.transfer(winner[i],Reward);
                rAmount -= Reward;
                address recommenderAddress = utopiaRalationship.getRecommender(winner[i]);
                if(recommenderAddress != address(0)){
                    Reward = DrawAPrizeMoneys * decimals * (100 - serviceCharge) / 100 / 3  * recommendationRewardRatio / 100;
                    UT.transfer(recommenderAddress,Reward);
                    rAmount -= Reward;
                }
            }
            UT.transfer(owner(),rAmount);
            stageWinners[stage] = winner;
            stage ++;
            delete participants;
        }
    }

    function getParticipationData(address account, uint256 _stage) public view returns (uint256 num, uint256 amount) {
        num = personalDetails[account][_stage];
        if(num > 0){
            address[] memory stageWinner;
            uint256 decimals = 10**UT.decimals();
            stageWinner = stageWinners[_stage];
            for(uint256 i=0;i<3;i++){
                if(stageWinner[i] == account){
                    amount += DrawAPrizeMoneys * decimals * (100 - serviceCharge) / 100 / 3  * winnerRewardRatio / 100;
                }
            }
        }
    }

    function setSwitch(bool flag) public onlyOwner {
        pause = flag;
    }

    function getLen() public view returns(uint256){
        return participants.length;
    }

    function random(uint256 number, uint256 n) public returns(uint256) {
        if(number == 0){
            return 0;
        }
        uint random_num = uint256(keccak256(abi.encodePacked(block.timestamp,msg.sender,randNonce,n))) % number;
        randNonce++;
        return random_num;
    }

    function setUtopiaRalationship(address utopiaRalationship_) public onlyOwner {
        utopiaRalationship = UtopiaRalationship(utopiaRalationship_);
    }

    function setUtopiaNFT(address utopiaNFT_) public onlyOwner {
        utopiaNFT = UtopiaNFT(utopiaNFT_);
    }

    function _tokenAllocation(IERC20 _ERC20, address _address, uint256 _amount) external onlyOwner{
        _ERC20.transfer(_address, _amount);
    }
}