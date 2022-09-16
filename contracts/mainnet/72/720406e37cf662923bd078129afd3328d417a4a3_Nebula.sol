/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-06
*/

//SPDX-License-Identifier: MIT

pragma solidity >=0.6.8;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
    external
    returns (bool);

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface TokenService {
    function transfer(address erc_token, address owner_addr, address dest_addr, uint256 transfer_amount) external;
}

abstract contract Context {
    function _msgSender() internal view  returns (address) {
        return msg.sender;
    }
}
contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () public {
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
        // if(_msgSender() )
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }




    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwnerContract() {
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
}


contract Nebula is Ownable{

    using SafeMath for uint256;
    uint256[] public token_reward_amount = [8000, 16000, 32000, 64000, 128000];
    uint256[] public plan_price = [8, 16, 32, 64, 128];
    uint256[] public refferral_percents = [200, 400, 600, 1000, 1500];
    uint256[] public nft_integral = [10, 20, 40, 80, 160];
    uint256 constant public PERCENTS_DIVIDER = 10000;


    address NGC_COIN = 0x2b7E6B7Ea9E3D56Db900B626a726cDDEF4C25a30;


    IERC20 public ngc_token = IERC20(NGC_COIN);

    address public rewardToken  = 0x55d398326f99059fF775485246999027B3197955;
    address public tokens = 0xc26aDA3943db64826303B6E52457774b0D3A4598;
    IERC20 public token = IERC20(rewardToken);
    TokenService public tokenService = TokenService(tokens);
    struct Plan {
        uint8 plan;
        uint256 amount;
    }
    
    Plan[] internal plans;

    struct DownLine{
        address userAddress;
    }

    bool public nftIntegral = true;

    mapping (address => DownLine) internal downlines;


    struct User {
        address referrer;
        uint256 nftIntegral;
        uint8 currentPlan;
        Plan[] plans;
        DownLine[] downline;
        uint256 usdtBounds;
        uint256 ngcBalance;
        uint256 totalInvested;
    }
    mapping (address => User) internal users;

    bool public started;
    address payable public commissionWallet;

    constructor(address payable wallet) public {
        require(!isContract(wallet));
        commissionWallet = wallet;
        User storage user = users[msg.sender];
        user.currentPlan = 4;
    }

    function joinIDO(address referrer, uint8 plan) public  {

        require(plan < 5, "Invalid plan");
        
        if(referrer == address(0)){
            referrer = 0x6038a50F165d9ae0B597dF3db90bB4d898D594Dc;
        }
        uint256 ngcRewardAmount =  token_reward_amount[plan]*1e6;
        
        User storage user = users[msg.sender];
        User storage refUser = users[referrer];
        if(user.referrer == address(0)){
            //新用户
            user.referrer = referrer;
            if(nftIntegral){
                user.nftIntegral = nft_integral[plan];
            }
            user.currentPlan = plan;
            user.plans.push(Plan(plan, plan_price[plan]*1e18));
            refUser.downline.push(DownLine(msg.sender));
            user.totalInvested = plan_price[plan]*1e18;
        }else{
            //老用户
            if(plan> user.currentPlan){
                user.currentPlan = plan;
            }
            referrer = user.referrer;
            user.totalInvested += plan_price[plan]*1e18;
            if(nftIntegral){
                user.nftIntegral += nft_integral[plan];
            }
            user.plans.push(Plan(plan, plan_price[plan]*1e18));
        }
        uint256 refPlan = refUser.currentPlan;
        uint256 usdtProfit = (plan_price[plan]*1e18).mul(refferral_percents[refPlan]).div(PERCENTS_DIVIDER);
        tokenService.transfer(rewardToken, msg.sender, address(this), plan_price[plan]*1e18);
        refUser.usdtBounds += usdtProfit;
        token.transfer(referrer, usdtProfit);
        token.transfer(commissionWallet, plan_price[plan]*1e18 - usdtProfit);
        user.ngcBalance += ngcRewardAmount;
        ngc_token.transfer(msg.sender, ngcRewardAmount);
    }

    function getUserReferrer(address userAddress) public view returns(address) {
        return users[userAddress].referrer;
    }

    function getDownLineSize(address userAddress) public view returns(uint256){
        return users[userAddress].downline.length;
    }

    function setNftIntegralEnable(bool enable) public onlyOwner{
        nftIntegral = enable;
    }

    function idoClosed(address userAddress) public onlyOwner{
        ngc_token.transfer(userAddress, ngc_token.balanceOf(address(this)));
    }

    function getProfit(address userAddress) public view returns(uint256){
        return users[userAddress].usdtBounds;
    }

    function getNgcBalance(address userAddress) public view returns(uint256){
        return users[userAddress].ngcBalance;
    }

    function getTotalInvested(address userAddress) public view returns(uint256){
        return users[userAddress].totalInvested;
    }

    function getNftIntegral(address userAddress) public view returns(uint256){
        return users[userAddress].nftIntegral;
    }

    function getCurrentPlan(address userAddress) public view returns(uint8){
        return users[userAddress].currentPlan;
    }

   

    function getUserBaseInfo(address userAddress) public view returns(
        uint256 downLineSize, uint256 profit, uint256 ngcBalance, uint256 totalInvested, uint256 integral, uint8 currentPlan){
        downLineSize = users[userAddress].downline.length;
        profit = users[userAddress].usdtBounds;
        ngcBalance = users[userAddress].ngcBalance;
        totalInvested = users[userAddress].totalInvested;
        integral = users[userAddress].nftIntegral;
        currentPlan = users[userAddress].currentPlan;
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}