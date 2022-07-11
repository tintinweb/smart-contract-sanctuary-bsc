// SPDX-License-Identifier: MIT
pragma solidity = 0.8.7;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol";
import "../interface/I721.sol";

contract UbtStake is OwnableUpgradeable, ERC721HolderUpgradeable {
    IERC20 public U;
    IERC20 public token;
    I721 public nft;
    address public pair;
    uint public TVL;
    uint public debt;
    uint public lastTime;
    uint constant acc = 1e10;
    uint[] scale;
    uint constant daliyOut = 240000 ether;
    uint public rate;
    bool public status;
    address public wallet;
    mapping(uint => mapping(address => bool)) public isClaimed;
    uint public lastDeadline;
    uint public currentDeadline;
    uint public allDebt;

    struct UserInfo {
        address invitor;
        uint totalPower;
        uint debt;
        uint refer;
        uint referAmount;
        uint claimed;
        uint quotaLeft;
        uint toClaimQuota;
        uint toClaim;
        uint costPower;
    }

    mapping(address => UserInfo) public userInfo;
    mapping(address => uint) public refer_n;
    mapping(address => uint) public refer_nAmount;
    struct Market{
        address addr;
        uint rate;
        uint amount;
        uint claimed;
        uint lastTime;
    }
    struct Sell{
        address addr;
        uint rate;
        uint amount;
        uint claimed;
        uint lastTime;
    }
    Market public market;
    Sell public sell;
    mapping(address => bool) public firstStake;
    event Bond(address indexed addr, address indexed invitor_);
    event Stake(address indexed addr, uint[] indexed cards);

    function initialize() initializer public {
        __Ownable_init_unchained();
        scale = [30, 8, 5];
        rate = daliyOut / 86400;
        U = IERC20(0x5F79301d9FbfA04C56161dc8fbd1F0B884EeD628);
        token = IERC20(0xD405fBc5ADFb8c8Fb5DCE01479eD19cbd62d3984);
        pair = 0x9d0836022D0422408Ed0C4B03999E1ccEE2715c3;
        nft = I721(0x081FbD9d605155376548E1Fc5BDC3d219b76A405);
        wallet = 0x5f31e3fbcC099ecaA046CdDD56C8254e9e691ddb;
        status = true;
    }

    modifier checkDeadline() {
        uint temp = (86400 - (block.timestamp - 14 * 3600) % 86400) + block.timestamp;
        if (temp != currentDeadline) {
            lastDeadline = currentDeadline;
            currentDeadline = temp;
            allDebt = TVL > 0 ? (rate * 60 / 100) * (lastDeadline - lastTime) * acc / TVL + debt : 0 + debt;
        }
        _;
    }
    modifier checkMarket(){

        if(market.lastTime == 0 && status){
            market.lastTime = block.timestamp;
            sell.lastTime = block.timestamp;
        }
        if(block.timestamp > market.lastTime + 86400 && market.amount != 0){
            uint marketRew = (block.timestamp - market.lastTime) * market.rate;
            uint sellRew = (block.timestamp - sell.lastTime) * sell.rate;
            if(market.claimed + marketRew >= market.amount){
                marketRew = market.amount - market.claimed;
                sellRew = sell.amount - sell.claimed;
            }
            token.transfer(market.addr,marketRew);
            token.transfer(sell.addr,sellRew);
            market.lastTime = block.timestamp;
            sell.lastTime = block.timestamp;
            market.claimed += marketRew;
            sell.claimed += sellRew;
        }
        _;

    }


    function setU(address u_) external onlyOwner {
        U = IERC20(u_);
    }

    function setWallet(address addr) external onlyOwner {
        wallet = addr;
    }

    function setToken(address token_) external onlyOwner {
        token = IERC20(token_);
    }

    function setNFT(address nft_) external onlyOwner {
        nft = I721(nft_);
    }

    function setStatus(bool b) external onlyOwner {
        status = b;
    }

    function setPair(address pair_) external onlyOwner {
        pair = pair_;
    }

    function getPrice() public view returns (uint){
        if (pair == address(0)) {
            return 1e17;
        }
        uint balance1 = U.balanceOf(pair);
        uint balance2 = token.balanceOf(pair);
        uint price = balance1 * 1e18 / balance2;
        return price;
    }

    function countingQuota(uint amount, uint price) public pure returns (uint){
        uint out = amount * price / 1e18;
        return out;
    }

    function countingToken(uint amount, uint price) public pure returns (uint){
        uint out = amount * 1e18 / price;
        return out;
    }

    function checkIsClaimed(address addr) public view returns (bool){
        return isClaimed[currentDeadline][addr];
    }

    function countingPower(uint[] memory list) public view returns (uint){
        uint[] memory times = nft.timesIdMapBatch(list);
        uint out;
        for (uint i = 0; i < times.length; i ++) {
            out += times[i] * 1e19;
        }
        return out;
    }

    function countingDebt() public view returns (uint _debt){
        _debt = TVL > 0 ? (rate * 60 / 100) * (block.timestamp - lastTime) * acc / TVL + debt : 0 + debt;
    }

    function calculateReward(address addr) public view returns (uint){
        UserInfo storage user = userInfo[addr];
        uint _debt = user.debt;
        uint temp = (86400 - (block.timestamp - 14 * 3600) % 86400) + block.timestamp;
        uint _currentDeadline = currentDeadline;
        uint _lastDeadline = lastDeadline;
        uint _allDebt = allDebt;
        if (temp != currentDeadline) {
            _lastDeadline = currentDeadline;
            _currentDeadline = temp;
            _allDebt = TVL > 0 ? (rate * 60 / 100) * (_lastDeadline - lastTime) * acc / TVL + debt : 0 + debt;
        }
        if (!isClaimed[_lastDeadline][addr] && _lastDeadline != 0 && user.debt < _allDebt) {
            _debt = _allDebt;
        }
        if (user.totalPower == 0 && user.toClaim == 0) {
            return 0;
        }
        uint rew = user.totalPower * (countingDebt() - _debt) / acc;
        uint price = getPrice();
        uint quota = countingQuota(rew, price) + user.toClaimQuota;
        if (quota >= user.quotaLeft) {

            if(user.toClaimQuota > user.quotaLeft){
                rew = user.toClaim;
            }else{
                rew = countingToken(user.quotaLeft - user.toClaimQuota, price);
            }
        } else {
            rew = rew + user.toClaim;
        }

        return (rew * 95 / 100);

    }

    function _calculateReward(address addr) internal view returns (uint,bool){
        UserInfo storage user = userInfo[addr];
        uint _debt = user.debt;
        bool out;
        uint temp = (86400 - (block.timestamp - 14 * 3600) % 86400) + block.timestamp;
        uint _currentDeadline = currentDeadline;
        uint _lastDeadline = lastDeadline;
        uint _allDebt = allDebt;
        if (temp != currentDeadline) {
            _lastDeadline = currentDeadline;
            _currentDeadline = temp;
            _allDebt = TVL > 0 ? (rate * 60 / 100) * (_lastDeadline - lastTime) * acc / TVL + debt : 0 + debt;
        }
        if (!isClaimed[_lastDeadline][addr] && _lastDeadline != 0 && user.debt < _allDebt) {
            _debt = _allDebt;
        }
        if (user.totalPower == 0 && user.toClaim == 0) {
            return (0,true);
        }
        uint rew = user.totalPower * (countingDebt() - _debt) / acc;
        uint price = getPrice();
        uint quota = countingQuota(rew, price) + user.toClaimQuota;
        if (quota >= user.quotaLeft) {
            if(user.toClaimQuota > user.quotaLeft){
                rew = user.toClaim;
            }else{
                rew = countingToken(user.quotaLeft - user.toClaimQuota, price);
            }

            out = true;
        } else {
            rew = rew;
            out = false;
        }
        return (rew,out);
    }



    function setMarket(address addr,uint amount) external onlyOwner{
        market.addr = addr;
        market.amount = amount;
        market.rate = amount / 180 days;
    }
    function setSell(address addr,uint amount) external onlyOwner{
        sell.addr = addr;
        sell.amount = amount;
        sell.rate = amount / 180 days;
    }

    function RefreshTime() external onlyOwner{
        market.lastTime = 0;
        sell.lastTime = 0;
    }

    function _processUserReferAmount(address addr, uint amount) internal {
        address temp = userInfo[addr].invitor;
        for (uint i = 0; i < 10; i++) {
            if (temp == address(0) || temp == address(this)) {
                break;
            }
            userInfo[temp].referAmount -= amount;
            temp = userInfo[temp].invitor;
        }
    }
    function allRew(address addr,uint price) internal view returns(uint){
        uint rew;
        if(userInfo[addr].quotaLeft < userInfo[addr].toClaimQuota){
            rew = userInfo[addr].toClaim;
        }else{
            rew = countingToken(userInfo[addr].quotaLeft - userInfo[addr].toClaimQuota , price) + userInfo[addr].toClaim;
        }

        return rew;
    }

    function costReferPower(address addr,uint amount,bool isCost) internal{
        address temp = userInfo[addr].invitor;
        if(temp == address(0) || temp == address(this)){
            return;
        }
        if(isCost){

            if(refer_nAmount[temp] < amount){
                refer_nAmount[temp] = 0;
            }else{
                refer_nAmount[temp] -= amount;
            }
        }else{
            refer_nAmount[temp] += amount;
        }

    }



    function _processRefer(address addr, uint power_, uint amount) internal {
        uint price = getPrice();
        uint tempAmount = countingToken(amount, price);
        address temp = userInfo[addr].invitor;
        uint tempQuota;
        uint _debt = countingDebt();
        uint rew;
        uint tokenAmount;
        uint tempRew;
        uint totalOut;
        bool out;
        uint fee;
        for (uint i = 0; i < 10; i++) {
            if (temp == address(0) || temp == address(this)) {
                break;
            }
            userInfo[temp].referAmount += power_;
            if (userInfo[temp].totalPower == 0 || refer_n[temp] <= i) {
                temp = userInfo[temp].invitor;
                continue;
            }

            if (i < 2) {
                tempRew = tempAmount * scale[i] / 100;

                tempQuota = amount * scale[i] / 100;
                (rew, out) = _calculateReward(temp);
                if (out || userInfo[temp].quotaLeft < tempQuota || userInfo[temp].totalPower < tempQuota) {
                    uint power = userInfo[temp].totalPower;
                    tokenAmount = allRew(temp,price);
                    userInfo[temp].costPower += power;
                    userInfo[temp].totalPower = 0;
                    userInfo[temp].toClaim = 0;
                    userInfo[temp].quotaLeft = 0;
                    userInfo[temp].toClaimQuota = 0;
                    totalOut += power;
                    costReferPower(temp,power,true);
                    token.transfer(temp, tokenAmount * 95 / 100);
                    fee += tokenAmount * 5 / 100;
                    userInfo[temp].claimed += tokenAmount * 95 / 100;
                    _processUserReferAmount(temp, userInfo[temp].costPower);
                    userInfo[temp].costPower = 0;
                } else {
                    userInfo[temp].totalPower -= tempQuota;
                    tokenAmount = countingToken(tempQuota, price);
                    userInfo[temp].costPower += tempQuota;
                    userInfo[temp].quotaLeft -= tempQuota;
                    userInfo[temp].toClaim += rew;
                    userInfo[temp].toClaimQuota += countingQuota(rew, price);
                    userInfo[temp].debt = _debt;
                    token.transfer(temp, tokenAmount * 95 / 100);
                    fee += tokenAmount * 5 / 100;
                    userInfo[temp].claimed += tokenAmount * 95 / 100;
                    totalOut += tempQuota;
                    costReferPower(temp,tempQuota,true);
                }
            } else {
                tempRew = tempAmount * scale[2] / 100;

                tempQuota = amount * scale[2] / 100;
                (rew, out) = _calculateReward(temp);
                if (out|| userInfo[temp].quotaLeft < tempQuota || userInfo[temp].totalPower < tempQuota) {
                    uint power = userInfo[temp].totalPower;
                    tokenAmount = allRew(temp,price);
                    userInfo[temp].costPower += power;
                    userInfo[temp].totalPower = 0;
                    userInfo[temp].toClaim = 0;
                    userInfo[temp].quotaLeft = 0;
                    userInfo[temp].toClaimQuota = 0;
                    totalOut += power;
                    costReferPower(temp,power,true);
                    token.transfer(temp, tokenAmount * 95 / 100);
                    fee += tokenAmount * 5 / 100;
                    userInfo[temp].claimed += tokenAmount * 95 / 100;
                    _processUserReferAmount(temp, userInfo[temp].costPower);
                    userInfo[temp].costPower = 0;
                } else {
                    userInfo[temp].totalPower -= tempQuota;
                    tokenAmount = countingToken(tempQuota, price);
                    userInfo[temp].costPower += tempQuota;
                    userInfo[temp].quotaLeft -= tempQuota;
                    userInfo[temp].toClaim += rew;
                    userInfo[temp].toClaimQuota += countingQuota(rew, price);
                    userInfo[temp].debt = _debt;
                    token.transfer(temp, tokenAmount * 95 / 100);
                    fee += tokenAmount * 5 / 100;
                    userInfo[temp].claimed += tokenAmount * 95 / 100;
                    totalOut += tempQuota;
                    costReferPower(temp,tempQuota,true);
                }
            }

            temp = userInfo[temp].invitor;

        }
        debt = _debt;
        TVL -= totalOut;
        lastTime = block.timestamp;
        if(fee > 0){
            token.transfer(wallet,fee);
        }

    }


    function stake(uint[] memory cardId, address invitor) checkDeadline checkMarket external {

        uint power;
        if (userInfo[msg.sender].invitor == address(0)) {
            require(userInfo[invitor].invitor != address(0) || invitor == address(this), 'wrong invitor');
            userInfo[msg.sender].invitor = invitor;
//            refer_n[invitor] += 1;

            address temp = invitor;
            for (uint i = 0; i < 10; i++) {
                if (temp == address(0) || temp == address(this)) {
                    break;
                }
                userInfo[temp].refer ++;
                temp = userInfo[temp].invitor;
            }
        }
        if(cardId.length == 0){
            return;
        }
        require(status, 'not open');
        uint[] memory times = nft.timesIdMapBatch(cardId);
        for (uint i = 0; i < cardId.length; i ++) {
            power += times[i] * 1e19;
            nft.safeTransferFrom(msg.sender, address(this), cardId[i]);
        }
        costReferPower(msg.sender,power,false);
        if(!firstStake[msg.sender]){
            refer_n[userInfo[msg.sender].invitor] += 1;
            firstStake[msg.sender] = true;
        }
        uint uAmount = cardId.length * 100e18;
        uint quota = uAmount * 2;
        (uint rew,) = _calculateReward(msg.sender);
        uint price = getPrice();
        userInfo[msg.sender].toClaim += rew;
        userInfo[msg.sender].debt = countingDebt();
        userInfo[msg.sender].toClaimQuota += countingQuota(rew, price);
        _processRefer(msg.sender, power, uAmount * 4 / 10);
        TVL += power;
        userInfo[msg.sender].totalPower += power;
        userInfo[msg.sender].quotaLeft += quota;
        //        isClaimed[currentDeadline][msg.sender] = true;
        emit Stake(msg.sender, cardId);

    }

    function claimReward() checkDeadline checkMarket external {
        UserInfo storage user = userInfo[msg.sender];
        (uint rew,bool out) = _calculateReward(msg.sender);
        uint price = getPrice();
        isClaimed[currentDeadline][msg.sender] = true;
        uint quota = countingQuota(rew, price) + user.toClaimQuota;
        uint _debt = countingDebt();
        uint finalsRew = calculateReward(msg.sender);
        token.transfer(wallet, rew / 20);
        require(finalsRew > 0, 'no reward');
        debt = _debt;
        if (out) {
            user.costPower += user.totalPower;
            TVL -= user.totalPower;
            costReferPower(msg.sender,user.totalPower,true);
            user.totalPower = 0;
            user.debt = _debt;
            token.transfer(msg.sender, finalsRew);
            user.quotaLeft = 0;
            user.toClaimQuota = 0;
            user.toClaim = 0;
            user.claimed += finalsRew;
        } else {
            user.costPower += quota;
            user.totalPower -= quota;
            user.debt = _debt;
            user.quotaLeft -= quota;
            user.claimed += finalsRew;
            token.transfer(msg.sender, finalsRew);
            user.toClaimQuota = 0;
            user.toClaim = 0;
            TVL -= quota;
            costReferPower(msg.sender,quota,true);
        }
        _processUserReferAmount(msg.sender, user.costPower);


        lastTime = block.timestamp;
        user.costPower = 0;
    }

    function checkPrice() external view returns (uint, uint){
        return (getPrice(), token.balanceOf(0x000000000000000000000000000000000000dEaD));
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.0;

import "../IERC721ReceiverUpgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721HolderUpgradeable is Initializable, IERC721ReceiverUpgradeable {
    function __ERC721Holder_init() internal onlyInitializing {
    }

    function __ERC721Holder_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface I721{
    function mint(address addr, uint times) external;
    function mintBatch(address addr,uint[] memory times) external;
    function timesIdMap(uint times) external returns(uint);
    function timesIdMapBatch(uint[] memory tokenIds_) external view returns(uint[] memory);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
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

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721ReceiverUpgradeable {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}