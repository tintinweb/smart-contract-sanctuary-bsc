/**
 *Submitted for verification at BscScan.com on 2023-01-10
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

// File: contracts/Utopia/Botra.sol


pragma solidity ^0.8.17;



interface IERC20Ext is IERC20 {
    function decimals() external view returns(uint8);
    function uniswapV2Pair() external view returns(address);
    function destruction(uint256 amount) external;
}

interface IUniswapV2Pair {
    function balanceOf(address owner) external view returns (uint);
    function transfer(address to, uint value) external returns (bool);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);
    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;
    function initialize(address, address) external;
}

interface UtopiaRalationship {
    function setRecommender(address account, address recommender) external;
    function getRecommender(address account) external view returns (address);
}

interface UtopiaInsurance {
    function setLastTime() external;
}

contract Botra is  Ownable {

    bool public pause;
    mapping(address=>bool) public derivation;
    uint256 public invitedAddNum;//每次增加的允许邀请次数
    bool public invitationRestrictions;//是否判断邀请次数
    mapping(address=>uint256) public invitePermissionNum;

    IERC20Ext public usdt;
    IERC20Ext public utopiaPlanet;
    IERC20Ext public utopiaToken;
    IUniswapV2Pair utopiaPlanetPair;
    UtopiaRalationship public utopiaRalationship;

    mapping(address => address[]) public recommended_address;
    mapping(address => uint256) public consensusTotalNum;//购买总次数
    uint256 public dynamicAllocationRatio;
    address public operatingFund;
    uint256 public consensusPrices;
    uint256 public joinNodePrices;
    uint256 public upTotalBonus;
    uint256 public usdtTotalBonus;
    mapping(address=>bool) public nodeAddress;
    mapping(address=>uint256) public totalBonus;

    constructor(address utopiaToken_, address utopiaRalationship_, address utopiaPlanet_, address operatingFund_) {
        utopiaToken = IERC20Ext(utopiaToken_);
        usdt = IERC20Ext(0x0B7E566590D26Ec368e08e23cEa6B18e618f541c);
        utopiaPlanet = IERC20Ext(utopiaPlanet_);
        setInvitedAddNum(5);
        setUtopiaPlanetPair(utopiaPlanet.uniswapV2Pair());
        setUtopiaRalationship(utopiaRalationship_);
        setInvitationRestrictions(false);
        setDynamicAllocationRatio(70);//100%
        setOperatingFund(operatingFund_);
        setConsensusPrices(100 ether);
        setJoinNodePrices(1000 ether);
    }

    function setRecommender(address recommender) public {
        require(msg.sender != owner(),"[Botra] woner do not operate");
        require(consensusTotalNum[recommender] != 0 || owner() == recommender || invitationRestrictions == false, "[Botra] Invalid recommender!");
        require(getRecommender(msg.sender) == address(0), "[Botra] Referrer has been bound!");

        if(invitationRestrictions == true){
            require(invitePermissionNum[recommender] > 0, "[Botra] Referrer invitation permission has been exhausted!");
            invitePermissionNum[recommender] --;
        }
        recommended_address[recommender].push(msg.sender);
        utopiaRalationship.setRecommender(msg.sender, recommender);
    }

    function getRecommender(address account) public view returns(address) {
        return utopiaRalationship.getRecommender(account);
    }

    function consensus(uint256 num) public {
        require(msg.sender != owner(),"[Botra] Woner do not operate");
        require(pause == false, "[Botra] Temporarily paused consensus!");
        require(getRecommender(msg.sender) != address(0), "[Botra] You cant mint without recommender!");
        address recommender_address = getRecommender(msg.sender);
        uint256 usdt_price = consensusPrices*num;
        uint256 up_price = getUPAmountForUsdt(usdt_price);
        require(utopiaPlanet.balanceOf(msg.sender) >= up_price, "[Botra] Your balance is insufficient balance!");
        utopiaPlanet.transferFrom(msg.sender, address(this), up_price);
        utopiaPlanet.destruction(up_price);
        uint256 amount = (up_price*(100-dynamicAllocationRatio))/100;
        utopiaPlanet.transfer(operatingFund,amount);
        usdtTotalBonus += usdt_price;
        upTotalBonus += up_price;
        consensusTotalNum[msg.sender] += num;
        invitePermissionNum[msg.sender] += invitedAddNum*num;
        invitePermissionNum[recommender_address] += invitedAddNum*num;
    }

    function joinNode(uint256 id) public {
        require(msg.sender != owner(),"[Botra] Woner do not operate");
        require(pause == false, "[Botra] Temporarily paused to mint!");
        require(getRecommender(msg.sender) != address(0), "[Botra] You cant mint without recommender!");
        require(nodeAddress[msg.sender] == false,"[Botra] Joined node!");
        if(id == 1){
            require(usdt.balanceOf(msg.sender) >= joinNodePrices, "[Botra] USDT Insufficient quantity");
            usdt.transferFrom(msg.sender, address(this), joinNodePrices);
            nodeAddress[msg.sender] = true;
        }
        if(id == 2){
            require(utopiaToken.balanceOf(msg.sender) >= joinNodePrices, "[Botra] UTP Insufficient quantity");
            utopiaToken.transferFrom(msg.sender, address(this), joinNodePrices);
            nodeAddress[msg.sender] = true;
        }
    }

    function setNode(address account, bool flag) public onlyOwner {
        nodeAddress[account] = flag;
    }

    function setConsensusPrices(uint256 consensusPrices_) public onlyOwner {
        consensusPrices = consensusPrices_;
    }

    function setUtopiaRalationship(address utopiaRalationship_) public onlyOwner {
        utopiaRalationship = UtopiaRalationship(utopiaRalationship_);
    }

    function setJoinNodePrices(uint256 joinNodePrices_) public onlyOwner {
        joinNodePrices = joinNodePrices_;
    }

    function setOperatingFund(address operatingFund_) public onlyOwner {
        operatingFund = operatingFund_;
    }

    function setDynamicAllocationRatio(uint256 ratio_) public onlyOwner {
        dynamicAllocationRatio = ratio_;
    }

    function setInvitationRestrictions(bool flag) public onlyOwner {
        invitationRestrictions = flag;
    }

    function setInvitedAddNum(uint256 _invitedAddNum) public onlyOwner{
        invitedAddNum = _invitedAddNum;
    }

    function setUtopiaPlanetPair(address pair) public onlyOwner{
        utopiaPlanetPair = IUniswapV2Pair(pair);
    }

    function getUPAmountForUsdt(uint256 usdtAmount) public view returns(uint256) {
        (uint256 amountUPInPair, uint256 amountUsdtInPair) = getLiquidityPairAmount();
        return (amountUPInPair * usdtAmount) / amountUsdtInPair;
    }

    function getUsdtAmountForUP(uint256 meAmount) public view returns(uint256) {
        (uint256 amountUPInPair, uint256 amountUsdtInPair) = getLiquidityPairAmount();
        return (amountUsdtInPair * meAmount) / amountUPInPair;
    }

    function getLiquidityPairAmount() public view returns(uint256 amountTk, uint256 amountUsdt)  {
        (uint256 token0, uint256 token1, ) = utopiaPlanetPair.getReserves();
        if (utopiaPlanetPair.token0() == address(utopiaPlanet)) {
            amountTk = token0;
            amountUsdt = token1;
        }
        else {
            amountTk = token1;
            amountUsdt = token0;
        }
    }

    function allocated(address account1, address account2, uint256 amount1, uint256 amount2) public onlyDerivation{
        totalBonus[account1] += amount1;
        totalBonus[account2] += amount2;
        usdt.transfer(account1,amount1);
        usdt.transfer(account2,amount2);
    }

    function allocateds(address[] memory accounts, uint256[] memory amount) public onlyDerivation{
        require(accounts.length == amount.length, "[Botra] Parameter error!");
        for(uint256 i=0;i<accounts.length;i++){
            totalBonus[accounts[i]] += amount[i];
            usdt.transfer(accounts[i],amount[i]);
        }
    }

    function setDerivation(address contract_) public onlyOwner{
        derivation[contract_] = true;
    }

    function closeDerivation(address contract_) public onlyOwner{
        derivation[contract_] = false;
    }

    modifier onlyDerivation() {
        require(derivation[msg.sender] == true || msg.sender == owner(), "[Botra] This function can be called only from admin!");
        _;
    }

    function _tokenAllocation(IERC20 _ERC20, address _address, uint256 _amount) external onlyOwner{
        _ERC20.transfer(_address, _amount);
    }
}