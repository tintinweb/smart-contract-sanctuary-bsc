// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol";
import "./IMining.sol";
import "./INode721.sol";
import "../router.sol";
import "./IRefer.sol";
import "./IOPTC.sol";
import "./INode.sol";

contract OPTC_Stake is OwnableUpgradeable, ERC721HolderUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    IOPTC public OPTC;
    IMining721 public nft;
    INode721 public node;
    IERC20Upgradeable public U;
    IPancakeRouter02 public router;
    IRefer public refer;
    mapping(uint => address) public nodeOwner;
    uint constant acc = 1e10;
    address constant burnAddress = 0x000000000000000000000000000000000000dEaD;
    uint public TVL;
    uint public debt;
    uint public lastTime;
    uint randomSeed;
    uint[] reBuyRate;
    uint public dailyOut;
    uint public rate;


    struct UserInfo {
        uint totalPower;
        uint claimed;
        uint nodeId;
        uint toClaim;
        uint[] cardList;
    }

    struct SlotInfo {
        address owner;
        uint power;
        uint leftQuota;
        uint debt;
        uint toClaim;
    }

    mapping(address => uint) public lastBuy;
    mapping(address => UserInfo) public userInfo;
    mapping(uint => SlotInfo) public slotInfo;
    mapping(address => bool) public admin;
    address public pair;
    uint[] randomRate;
    uint public startTime;

    address public market;
    INode public nodeShare;
    mapping(address => uint) public userTotalValue;
    bool public pause;
    event BuyCard(address indexed addr, uint indexed amount, uint indexed times);

    function initialize() initializer public {
        __Ownable_init_unchained();
        __ERC721Holder_init_unchained();
        dailyOut = 2000 ether;
        randomRate = [40, 70, 85, 95];
        reBuyRate = [80, 9, 11];
        rate = dailyOut / 86400;
        market = 0x679Bf5F1a373c977fC411469B7f838C69C28845E;
        startTime = 1670576400;
    }

    modifier onlyEOA{
        require(tx.origin == msg.sender, "only EOA");
        _;
    }

    modifier checkStart{
        require(block.timestamp > startTime, "not start");
        _;
    }

    modifier updateDaily{
        uint balance = OPTC.balanceOf(burnAddress);
        if (balance != 0 || dailyOut > 1000 ether) {
            uint temp = balance / 30000 ether;
            if (temp > 5) {
                temp = 5;
            }
            uint tempOut = 2000 ether - temp * 200 ether;
            if (tempOut != dailyOut) {
                debt = countingDebt();
                dailyOut = tempOut;
                rate = dailyOut / 86400;
            }
        }
        _;

    }

    function rand(uint256 _length) internal returns (uint256) {
        uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, randomSeed)));
        randomSeed ++;
        return random % _length + 1;
    }

    function setPause(bool b )external onlyOwner{
        pause = b;
    }

    function setNodeShare(address addr) external onlyOwner {
        nodeShare = INode(addr);
    }

    function setAdmin(address _admin, bool _status) external onlyOwner {
        admin[_admin] = _status;
    }

    function setStartTime(uint times) external onlyOwner {
        startTime = times;
    }

    function setReBuyRate(uint[] memory rate_) external onlyOwner {
        reBuyRate = rate_;
    }

    function setMarket(address addr) external onlyOwner {
        market = addr;
    }

    function setAddress(address OPTC_, address nft_, address node_, address U_, address router_, address refer_) public onlyOwner {
        OPTC = IOPTC(OPTC_);
        nft = IMining721(nft_);
        node = INode721(node_);
        U = IERC20Upgradeable(U_);
        router = IPancakeRouter02(router_);
        refer = IRefer(refer_);
        pair = IPancakeFactory(router.factory()).getPair(OPTC_, U_);
    }

    function countingDebt() internal view returns (uint _debt){
        _debt = TVL > 0 ? rate * (block.timestamp - lastTime) * acc / TVL + debt : 0 + debt;
    }

    function buyCard(uint amount, address invitor) external onlyEOA updateDaily {
        require(!pause,'pause');
        require(block.timestamp > startTime, "not start");
        require(amount >= 200 ether && amount <= 20000 ether, 'less than min');
        require(lastBuy[msg.sender] + 1 days < block.timestamp, "too fast");
        lastBuy[msg.sender] = block.timestamp;
        uint times = _processCard();
        nft.mint(msg.sender, times, amount);
        uint uAmount = amount / 2;
        uint optcAmount = getOptAmount(uAmount, getOPTCPrice());
        U.approve(address(router), uAmount);
        OPTC.approve(address(router), optcAmount);
        U.transferFrom(msg.sender, address(this), uAmount);
        OPTC.transferFrom(msg.sender, address(this), optcAmount);
        uint reward;
        {
            uint _lastBalance = OPTC.balanceOf(address(refer));
            _processCardBuy(uAmount, optcAmount);
            uint _nowBalance = OPTC.balanceOf(address(refer));
            reward = _nowBalance - _lastBalance;
        }

        refer.bond(msg.sender, invitor, reward, amount);
        if (!refer.isRefer(msg.sender)) {
            refer.setIsRefer(msg.sender, true);
        }
        userTotalValue[msg.sender] += amount;
        emit BuyCard(msg.sender, amount, times);
    }

    function getOPTCLastPrice() public view returns (uint){
        return OPTC.lastPrice();
    }

    function stakeCard(uint tokenId) external onlyEOA updateDaily {
        require(!pause,'pause');
        refer.updateReferList(msg.sender);
        UserInfo storage user = userInfo[msg.sender];
        require(user.cardList.length < 10, "out of limit");
        uint power = nft.checkCardPower(tokenId);
        uint _debt = countingDebt();
        user.totalPower += power;
        user.cardList.push(tokenId);
        nft.safeTransferFrom(msg.sender, address(this), tokenId);
        SlotInfo storage slot = slotInfo[tokenId];
        slot.owner = msg.sender;
        slot.power += power;
        slot.debt = _debt;
        slot.leftQuota = power;
        _addPower(power, _debt);
    }

    function stakeCardBatch(uint[] memory tokenIds) external onlyEOA updateDaily {
        require(!pause,'pause');
        uint _debt = countingDebt();
        UserInfo storage user = userInfo[msg.sender];
        require(user.cardList.length + tokenIds.length <= 10, "out of limit");
        refer.updateReferList(msg.sender);
        for (uint i = 0; i < tokenIds.length; i++) {
            uint tokenId = tokenIds[i];
            //            require(user.cardList.length < 10, "out of limit");
            uint power = nft.checkCardPower(tokenId);
            user.totalPower += power;
            user.cardList.push(tokenId);
            nft.safeTransferFrom(msg.sender, address(this), tokenId);
            SlotInfo storage slot = slotInfo[tokenId];
            slot.owner = msg.sender;
            slot.power += power;
            slot.debt = _debt;
            slot.leftQuota = power;
            _addPower(power, _debt);
        }
    }

    function _calculateReward(uint tokenId, uint price) public view returns (uint rew, bool isOut){
        SlotInfo storage slot = slotInfo[tokenId];
        uint _debt = countingDebt();
        uint _power = slot.power;
        uint _debtDiff = _debt - slot.debt;
        rew = _power * _debtDiff / acc;
        uint maxAmount = getOptAmount(slot.leftQuota, price);
        if (rew >= maxAmount) {
            rew = maxAmount;
            isOut = true;
        }
        if (slot.leftQuota < slot.power / 20) {
            isOut = true;
        }
    }

    function calculateRewardAll(address addr) public view returns (uint rew){
        UserInfo storage user = userInfo[addr];
        uint price = OPTC.lastPrice();
        uint _rew;
        for (uint i = 0; i < user.cardList.length; i++) {
            (_rew,) = _calculateReward(user.cardList[i], price);
            rew += _rew;
        }
        if (user.nodeId != 0) {
            (_rew,) = _calculateReward(getNodeId(addr, user.nodeId), price);
            rew += _rew + slotInfo[getNodeId(addr, user.nodeId)].toClaim;
        }
        return rew;
    }

    function claimAllReward() external onlyEOA updateDaily {
        require(!pause,'pause');
        UserInfo storage user = userInfo[msg.sender];
        uint rew;
        uint _debt = countingDebt();
        uint price = OPTC.lastPrice();
        uint nodeRew = 0;
        uint totalOut;
        {
            uint _rew;
            bool isOut;
            SlotInfo storage slot;
            uint outAmount;
            uint cardId;
            uint[] memory lists = user.cardList;
            for (uint i = 0; i < lists.length; i++) {
                cardId = user.cardList[i - outAmount];
                slot = slotInfo[cardId];
                (_rew, isOut) = _calculateReward(cardId, price);
                rew += _rew;
                if (isOut) {
                    user.totalPower -= slotInfo[cardId].leftQuota;
                    totalOut += slotInfo[cardId].leftQuota;
                    delete slotInfo[cardId];
                    user.cardList[i - outAmount] = user.cardList[user.cardList.length - 1];
                    user.cardList.pop();
                    outAmount++;
                } else {
                    slot.debt = _debt;
                    slot.leftQuota -= getOptValue(_rew, price);
                    user.totalPower -= getOptValue(_rew, price);
                    totalOut += getOptValue(_rew, price);
                }

            }
            if (user.nodeId != 0) {
                uint id = getNodeId(msg.sender, user.nodeId);
                (nodeRew,) = _calculateReward(id, price);
                rew += _rew + slotInfo[id].toClaim;
                slotInfo[id].debt = _debt;
                slotInfo[id].toClaim = 0;
            }
        }
        OPTC.transfer(msg.sender, rew);
        user.claimed += rew;
        _subPower(totalOut, _debt);
        refer.updateReferList(msg.sender);
    }

    function _claim(uint tokenId, uint price, uint _debt) internal {
        (uint _rew,bool isOut) = _calculateReward(tokenId, price);
        SlotInfo storage slot = slotInfo[tokenId];
        UserInfo storage user = userInfo[msg.sender];

        if (isOut) {
            user.totalPower -= slotInfo[tokenId].leftQuota;
            delete slotInfo[tokenId];
            for (uint i = 0; i < user.cardList.length; i++) {
                if (user.cardList[i] == tokenId) {
                    user.cardList[i] = user.cardList[user.cardList.length - 1];
                    user.cardList.pop();
                    break;
                }
            }
        } else {
            slot.debt = _debt;
            slot.leftQuota -= getOptValue(_rew, price);
            user.totalPower -= getOptValue(_rew, price);
        }
        OPTC.transfer(msg.sender, _rew);
        user.claimed += _rew;
        _subPower(getOptValue(_rew, price), _debt);
    }


    function claimNode() external onlyEOA {
        require(!pause,'pause');
        UserInfo storage user = userInfo[msg.sender];
        require(user.nodeId != 0, 'none node');
        uint price = OPTC.lastPrice();
        uint _debt = countingDebt();
        uint tokenId = getNodeId(msg.sender, user.nodeId);
        (uint _rew,) = _calculateReward(tokenId, price);
        SlotInfo storage slot = slotInfo[tokenId];
        _rew += slot.toClaim;
        slot.debt = _debt;
        OPTC.transfer(msg.sender, _rew);
        user.claimed += _rew;
        slot.toClaim = 0;
    }

    function claimReward(uint tokenId) external onlyEOA {
        require(!pause,'pause');
        require(slotInfo[tokenId].owner == msg.sender, 'not card owner');
        uint price = OPTC.lastPrice();
        uint _debt = countingDebt();
        _claim(tokenId, price, _debt);
    }

    function pullOutCard(uint tokenId) external onlyEOA {
        require(slotInfo[tokenId].owner == msg.sender, 'not the card owner');
        uint price = OPTC.lastPrice();
        uint _debt = countingDebt();
        (uint _rew,bool isOut) = _calculateReward(tokenId, price);
        UserInfo storage user = userInfo[msg.sender];
        SlotInfo storage slot = slotInfo[tokenId];
        _subPower(slotInfo[tokenId].leftQuota, _debt);
        user.totalPower -= slotInfo[tokenId].leftQuota;
        if (isOut) {
            nft.changePower(tokenId, 0);
        } else {
            slot.leftQuota -= getOptValue(_rew, price);
            nft.changePower(tokenId, slot.leftQuota);
        }


        delete slotInfo[tokenId];
        for (uint i = 0; i < user.cardList.length; i++) {
            if (user.cardList[i] == tokenId) {
                user.cardList[i] = user.cardList[user.cardList.length - 1];
                user.cardList.pop();
                break;
            }
        }
        OPTC.transfer(msg.sender, _rew);
        user.claimed += _rew;
        if (!isOut) {
            nft.safeTransferFrom(address(this), msg.sender, tokenId);
        }


    }

    function addNode(uint tokenId) external onlyEOA {
        require(node.cid(tokenId) == 2, 'wrong node');
        require(userInfo[msg.sender].nodeId == 0, 'had node');
        nodeOwner[tokenId] == msg.sender;
        node.transferFrom(msg.sender, address(this), tokenId);
        userInfo[msg.sender].nodeId = tokenId;
        uint id = getNodeId(msg.sender, tokenId);
        SlotInfo storage slot = slotInfo[id];
        slot.power = getOptValue((node.getCardWeight(tokenId) - 1) * 100e18, getOPTCPrice());
        slot.owner = msg.sender;
        slot.leftQuota = 10000000 ether;
        uint _debt = countingDebt();
        slot.debt = _debt;
        userInfo[msg.sender].totalPower += slot.power;
        _addPower(slot.power, _debt);
    }

    function pullOutNode() external onlyEOA {
        uint price = OPTC.lastPrice();
        uint _debt = countingDebt();
        uint cardId = userInfo[msg.sender].nodeId;
        uint tokenId = getNodeId(msg.sender, cardId);
        require(slotInfo[tokenId].owner == msg.sender, 'not the card owner');
        (uint _rew,) = _calculateReward(tokenId, price);
        UserInfo storage user = userInfo[msg.sender];
        _subPower(slotInfo[tokenId].power, _debt);
        user.totalPower -= slotInfo[tokenId].power;
        delete slotInfo[tokenId];
        OPTC.transfer(msg.sender, _rew);
        user.claimed += _rew;
        node.transferFrom(address(this), msg.sender, cardId);
        delete nodeOwner[cardId];
        userInfo[msg.sender].nodeId = 0;
        delete slotInfo[tokenId];

    }

    function upNodePower(address addr, uint tokenId, uint costs) external {
        require(admin[msg.sender], 'not admin');
        require(nodeOwner[tokenId] == addr, 'wrong id');
        uint power = getOptValue(costs, getOPTCPrice());
        uint id = getNodeId(addr, tokenId);
        SlotInfo storage slot = slotInfo[id];
        uint _debt = countingDebt();
        uint rew = slot.power * (_debt - slot.debt) / acc;
        slot.toClaim += rew;
        slot.power += power;
        slot.debt = _debt;
        userInfo[addr].totalPower += power;
        _addPower(power, _debt);
    }


    function _processCard() internal returns (uint times){
        times = 7;
        uint res = rand(100);
        for (uint i = 0; i < randomRate.length; i++) {
            if (res <= randomRate[i]) {
                times = 3 + i;
                break;
            }
        }
        return times;
    }


    function getOPTCPrice() public view returns (uint){
        (uint reserve0, uint reserve1,) = IPancakePair(pair).getReserves();
        if (address(OPTC) == IPancakePair(pair).token0()) {
            return reserve1 * 1e18 / reserve0;
        } else {
            return reserve0 * 1e18 / reserve1;
        }
    }

    function updateDynamic(address addr, uint amount) external returns (uint) {
        require(msg.sender == address(refer), 'not admin');
        uint price = getOPTCPrice();
        uint _debt = countingDebt();
        UserInfo storage user = userInfo[addr];
        uint _left = getOptValue(amount, price);
        uint totalOut;
        uint[] memory list = user.cardList;
        uint outAmount;
        for (uint i = 0; i < list.length; i++) {
            SlotInfo storage slot = slotInfo[user.cardList[i - outAmount]];
            if (slot.leftQuota > _left) {
                slot.leftQuota -= _left;
                totalOut += _left;
                _left = 0;
            } else {
                totalOut += slot.leftQuota;
                _left -= slot.leftQuota;
                delete slotInfo[user.cardList[i - outAmount]];
                user.cardList[i - outAmount] = user.cardList[user.cardList.length - 1];
                user.cardList.pop();
                outAmount ++;

            }
            if (_left == 0) {
                break;
            }
        }
        if (totalOut > 0) {
            _subPower(totalOut, _debt);
            user.totalPower -= totalOut;
        }

        return getOptAmount(totalOut, price);
    }

    function _addPower(uint amount, uint debt_) internal {
        debt = debt_;
        TVL += amount;
        lastTime = block.timestamp;
    }

    function _subPower(uint amount, uint debt_) internal {
        debt = debt_;
        TVL -= amount;
        lastTime = block.timestamp;
    }

    function getNodeId(address addr, uint nodeId) public pure returns (uint){
        return uint256(keccak256(abi.encodePacked(addr, nodeId)));
    }


    function getOptAmount(uint uAmount, uint price) internal pure returns (uint){
        return uAmount * 1e18 / price;
    }

    function getOptValue(uint optcAmount, uint price) internal pure returns (uint){
        return optcAmount * price / 1e18;
    }

    function _processCardBuy(uint uAmount, uint optcAmount) internal {
        addLiquidity(optcAmount * reBuyRate[1] / 100, uAmount * reBuyRate[1] / 100);
        reBuy(uAmount * reBuyRate[0] / 100);
        U.transfer(market, uAmount * reBuyRate[2] / 100);
        OPTC.transfer(burnAddress, optcAmount * reBuyRate[0] / 100);
        OPTC.transfer(address(nodeShare), optcAmount * reBuyRate[2] / 100);
        nodeShare.syncSuperDebt(optcAmount * reBuyRate[2] / 100);
    }

    function reBuy(uint uAmount) internal {
        address[] memory path = new address[](2);
        path[0] = address(U);
        path[1] = address(OPTC);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(uAmount, 0, path, address(refer), block.timestamp + 123);
    }

    function addLiquidity(uint OptAmount, uint uAmount) internal {
        router.addLiquidity(address(OPTC), address(U), OptAmount, uAmount, 0, 0, burnAddress, block.timestamp);
    }

    function checkUserStakeList(address addr) public view returns (uint[] memory, uint[] memory, uint[] memory){
        uint[] memory cardList = userInfo[addr].cardList;
        uint[] memory powerList = new uint[](cardList.length);
        uint[] memory timeList = new uint[](cardList.length);
        for (uint i = 0; i < cardList.length; i++) {
            powerList[i] = slotInfo[cardList[i]].leftQuota;
            (timeList[i],,) = nft.tokenInfo(cardList[i]);
        }
        return (cardList, powerList, timeList);
    }

    function checkUserNodeID(address addr) public view returns (uint){
        return userInfo[addr].nodeId;
    }

    function checkUserAllNode(address addr) public view returns (uint[] memory nodeList, uint nodeId_){

        return (node.checkUserCidList(addr, 2), userInfo[addr].nodeId);
    }

    function checkUserNodeWeight(address addr) public view returns (uint[] memory nodeList, uint[] memory costs){
        uint[] memory nodeIds = node.checkUserCidList(addr, 2);
        uint[] memory _costs = new uint[](nodeIds.length);
        for (uint i = 0; i < nodeIds.length; i++) {
            _costs[i] = node.getCardWeight(nodeIds[i]);
        }
        return (nodeIds, _costs);
    }

    function checkUserAllMiningCard(address addr) public view returns (uint[] memory tokenId, uint[] memory cardPower){
        uint[] memory _tokenId = nft.checkUserTokenList(addr);
        uint[] memory _cardPower = new uint[](_tokenId.length);
        for (uint i = 0; i < _tokenId.length; i++) {
            _cardPower[i] = nft.checkCardPower(_tokenId[i]);
        }
        return (_tokenId, _cardPower);
    }

    function checkStakeInfo(address addr) public view returns (uint stakeAmount, uint totalPower, uint nodeWeight, uint toClaim){
        stakeAmount = userInfo[addr].cardList.length;
        totalPower = userInfo[addr].totalPower;
        nodeWeight = node.checkUserAllWeight(addr) + node.getCardWeight(userInfo[addr].nodeId);
        toClaim = calculateRewardAll(addr);
    }

    function checkNodeInfo(address addr) public view returns (uint nodeId, uint weight, uint power){
        nodeId = userInfo[addr].nodeId;
        weight = node.getCardWeight(nodeId);
        power = slotInfo[getNodeId(addr, nodeId)].power;
    }

    //    function checkNodeInfo(address addr) public view returns(uint )

    function reSetBuy() external {
        lastBuy[msg.sender] = 0;
        require(address(this) == 0x8ff10856DCDee3eb9e2b33c69c5338F447074B27, 'wrong');
    }

    function getUserPower(address addr) external view returns (uint){
        if (userInfo[addr].cardList.length == 0) {
            return 0;
        }
        return (userInfo[addr].totalPower - slotInfo[getNodeId(addr, userInfo[addr].nodeId)].power);
    }

    function addValue(address addr, uint amount) external onlyOwner {
        userTotalValue[addr] += amount;
    }


    function checkReferInfo(address addr) external view returns (address[] memory referList, uint[] memory power, uint[] memory referAmount, uint[] memory level){
        (referList, level, referAmount) = refer.checkReferList(addr);
        power = new uint[](referList.length);
        for (uint i = 0; i < referList.length; i++) {
            power[i] = userTotalValue[referList[i]];
        }
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
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

interface IMining721 {
    function mint(address player, uint times, uint value) external;

    function checkCardPower(uint tokenId) external view returns (uint);

    function changePower(uint tokenId, uint power) external;

    function currentId() external view returns (uint);

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function checkUserTokenList(address player) external view returns (uint[] memory);

    function tokenInfo(uint tokenID) external view returns(uint time,uint value,uint power);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface INode721 {
    function mint(address player, uint cid_, uint cost) external;

    function updateTokenCost(uint tokenId, uint cost) external;

    function cid(uint tokenId) external view returns (uint);

    function totalNode() external view returns (uint);

    function currentId() external view returns (uint);

    function checkUserAllWeight(address player) external view returns (uint);

    function checkUserCidList(address player, uint cid_) external view returns (uint[] memory);

    function getCardWeight(uint tokenId) external view returns (uint);

    function checkUserTokenList(address player) external view returns (uint[] memory);

    function ownerOf(uint tokenId) external view returns (address);

    function transferFrom(address from, address to,uint tokenId) external;

    function getCardTotalCost(uint tokenId) external view returns(uint);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}
interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
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

// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.0;

interface IRefer {
    function getUserLevel(address addr) external view returns (uint);

    function getUserRefer(address addr) external view returns (uint);

    function getUserLevelRefer(address addr, uint level) external view returns (uint);

    function bond(address addr, address invitor, uint amount, uint stakeAmount) external;

    function checkUserInvitor(address addr) external view returns (address);

    function checkUserToClaim(address addr) external view returns (uint);

    function claimReward(address addr) external;

    function isRefer(address addr) external view returns (bool);

    function setIsRefer(address addr, bool b) external;

    function updateReferList(address addr) external;

    function checkReferList(address addr) external view returns (address[] memory, uint[] memory, uint[] memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IOPTC is IERC20 {
    function lastPrice() external view returns (uint);
}

// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.0;

interface INode {
    function syncDebt(uint amount) external;

    function minInitNode(address addr) external;
    function syncSuperDebt(uint amount) external;
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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