/**
 *Submitted for verification at BscScan.com on 2022-02-12
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
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
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC721 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
    function mint(address to, uint256 tokenId, uint256 tokenLevel, string memory initialURI) external;
    function burn(uint256 tokenId) external;
    function existed(uint256 tokenId) external view returns (bool);
    function identityLevel(uint256 tokenId) external view returns (uint256 tokenLevel);
}

interface ICreate4JIDStrategy {
    event GetTokenLevel(address indexed user, uint256 indexed tokenID, uint256 indexed level);
    function getTokenLevel(address from, uint256 tokenID) external returns(uint256 level);
    function getTokenRLevel(address from, uint256 tokenID) external returns(uint256 level);
    function getTokenSRLevel(address from, uint256 tokenID) external returns(uint256 level);
}

contract FourJAlliance is Ownable {
    using SafeMath for uint256;

    address public receiver;
    IERC721 public immutable fourJPASS; //Alliance NFT
    IERC721 public immutable fourJID;   //4JID NFT
    address public immutable tokenAddress;
    ICreate4JIDStrategy public immutable createStrategy;  //get token level from this contract

    uint256 public minPrice = 10**8 * 10**9;
    uint256 public normalPrice = 6 * 10**8 * 10**9;
    struct AllianceInfo {
        uint256 membershipFee; // membeership fee of each alliance
        uint256 managerFeeRate; // membeership fee rate to the alliance's owner (manager fee = fee * rate / 1000)
        uint256 rewardFeeRate; // membeership fee rate to all members
        uint256 ownerRemainedReward; // total remained membeership manager fee
        uint256 allianceMemNum; //the number of one alliance's members
        uint256 rewardPerShare; // Accumulated CAKEs per share, times 1e12. See below.
    }
    mapping(uint256 => AllianceInfo) public allianceInfos;
    uint256 public characterCount;
    uint256 public priceID = 1e15;
    uint256 public priceID_R = 7e15;
    uint256 public priceID_SR = 7e16;

    uint256 public rewardBase = 2e14;
    uint256 public rewardBase_R = 1e15;
    uint256 public rewardBase_SR = 1e16;
    uint256 public recyclePrice = 3e14;
    uint256 public destroyCount;
    address public rewardAddress;

    uint256 public countID_R;
    uint256 public countID_SR;
    uint256 public countID_SSR;
    uint256 public countID_SP;

    uint256 public countID_R_limit = 20000;
    uint256 public countID_SR_limit = 2000;
    uint256 public countID_SSR_limit = 200;
    uint256 public countID_SP_limit = 20;

    /** 4JID's information about its alliance. */
    mapping(uint256 => mapping(uint256 => uint256)) public allianceMembers;
    mapping(uint256 => uint256) public affiliatedAlliance;
    mapping(uint256 => uint256) public memberIndex;

    mapping(uint256 => mapping(uint256 => uint256)) public memberBaseDebts; // not real debt, just for calculating reward

    event  CreateID(address indexed user, uint256 tokenID, uint256 tokenLevel, string indexed initialURI);
    event  JoinAlliance(address indexed user, uint256 memberID, uint256 allianceID, uint256 membershipFee, uint256 managerFee, uint256 addReward);
    event  CreateIDandJoinAlliance(address indexed user, uint256 characterID, uint256 tokenLevel, string indexed initialURI,
                                   uint256 allianceID, uint256 membershipFee, uint256 managerFee, uint256 addReward);
    event  QuitAlliance(address indexed user, uint256 allianceID, uint256 memberID);
    event  ClaimReward(address indexed user, uint256 allianceID, uint256 memberID, uint256 rewardAmount);
    event  ClaimManagerFee(address indexed manager, uint256 allianceID, uint256 managerRewardAmount);
    event  AddReward(address indexed user, uint256 allianceID, uint256 rewardAmount);
    event  Burn4JID(address indexed user, uint256 tokenID, uint256 recycleAsset);

    constructor(IERC721 _fourJPASS, IERC721 _fourJID, ICreate4JIDStrategy _strategy, address _tokenAddress, address _receiver, address _rewardAddress) {
        fourJPASS = _fourJPASS;
        fourJID = _fourJID;
        createStrategy = _strategy;
        tokenAddress = _tokenAddress;
        receiver = _receiver;
        rewardAddress = _rewardAddress;
    }

    fallback() external payable {}
    receive() external payable {}

    uint private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, 'FourJAlliance: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function create4JID(string memory _initialURI) lock public payable {
        require(!isContract(msg.sender), "Address: call from contract address");
        require(msg.value == priceID, "FourJAlliance: bnb value error.");

        uint256 _characterID = characterCount + 1;
        while (fourJID.existed(_characterID)) {
            _characterID++;
        }
        characterCount = _characterID;

        uint256 _tokenLevel = createStrategy.getTokenLevel(msg.sender, _characterID);
        if (_tokenLevel > 0) {
            countLimit(_tokenLevel);
        }
        fourJID.mint(msg.sender, _characterID, _tokenLevel, _initialURI);
        TransferHelper.safeTransferETH(rewardAddress, rewardBase);

        emit CreateID(msg.sender, _characterID, _tokenLevel, _initialURI);
    }

    function createR4JID(string memory _initialURI) lock public payable {
        require(!isContract(msg.sender), "Address: call from contract address");
        require(msg.value == priceID_R, "FourJAlliance: bnb value error.");

        uint256 _characterID = characterCount + 1;
        while (fourJID.existed(_characterID)) {
            _characterID++;
        }
        characterCount = _characterID;

        uint256 _tokenLevel = createStrategy.getTokenRLevel(msg.sender, _characterID);
        if (_tokenLevel > 0) {
            countLimit(_tokenLevel);
        }
        fourJID.mint(msg.sender, _characterID, _tokenLevel, _initialURI);
        TransferHelper.safeTransferETH(rewardAddress, rewardBase_R);

        emit CreateID(msg.sender, _characterID, _tokenLevel, _initialURI);
    }

    function createSR4JID(string memory _initialURI) lock public payable {
        require(!isContract(msg.sender), "Address: call from contract address");
        require(msg.value == priceID_SR, "FourJAlliance: bnb value error.");

        uint256 _characterID = characterCount + 1;
        while (fourJID.existed(_characterID)) {
            _characterID++;
        }
        characterCount = _characterID;

        uint256 _tokenLevel = createStrategy.getTokenSRLevel(msg.sender, _characterID);
        if (_tokenLevel > 0) {
            countLimit(_tokenLevel);
        }
        fourJID.mint(msg.sender, _characterID, _tokenLevel, _initialURI);
        TransferHelper.safeTransferETH(rewardAddress, rewardBase_SR);

        emit CreateID(msg.sender, _characterID, _tokenLevel, _initialURI);
    }

    function countLimit(uint256 _idLevel) private {
        if (_idLevel == 1) {
            countID_R++;
            require(countID_R <= countID_R_limit, "FourJAlliance: limit count of R level is 20000.");
        } else if (_idLevel == 2) {
            countID_SR++;
            require(countID_SR <= countID_SR_limit, "FourJAlliance: limit count of SR level is 2000.");
        } else if (_idLevel == 3) {
            countID_SSR++;
            require(countID_SSR <= countID_SSR_limit, "FourJAlliance: limit count of SSR level is 200.");
        } else if (_idLevel == 4) {
            countID_SP++;
            require(countID_SP <= countID_SP_limit, "FourJAlliance: limit count of SP level is 20.");
        }
    }

    function burn4JID(uint256 _tokenID) public {
        require(fourJID.ownerOf(_tokenID) == msg.sender, "FourJAlliance: no authority.");
        require(fourJID.identityLevel(_tokenID) == 0, "FourJAlliance: only can burn normal NFT.");

        if (affiliatedAlliance[_tokenID] > 0) {
            quitAlliance(_tokenID, affiliatedAlliance[_tokenID]);
        }
        fourJID.burn(_tokenID);
        destroyCount++;

        TransferHelper.safeTransferETH(msg.sender, recyclePrice);

        emit Burn4JID(msg.sender, _tokenID, recyclePrice);
    }

    function setCountLimit(uint256 _countID_R_limit, uint256 _countID_SR_limit, uint256 _countID_SSR_limit, uint256 _countID_SP_limit) public onlyOwner() {
        countID_R_limit = _countID_R_limit;
        countID_SR_limit = _countID_SR_limit;
        countID_SSR_limit = _countID_SSR_limit;
        countID_SP_limit = _countID_SP_limit;
    }

    function joinAlliance(uint256 _memberID, uint256 _passID, uint256 _membershipFee) public {
        require(fourJPASS.ownerOf(_passID) != address(0), "FourJAlliance: alliance is not existed.");
        require(affiliatedAlliance[_memberID] == 0, "FourJAlliance: already joined in an alliance.");
        require(fourJID.ownerOf(_memberID) == msg.sender, "FourJAlliance: no authority.");
        if (allianceInfos[_passID].membershipFee == 0 || allianceInfos[_passID].membershipFee < minPrice) {
            allianceInfos[_passID].membershipFee = normalPrice;
        }
        require(allianceInfos[_passID].membershipFee == _membershipFee, "FourJAlliance: membership fee error.");

        TransferHelper.safeTransferFrom(tokenAddress, msg.sender, address(this), _membershipFee);
        _addMemberToAllianceEnumeration(_passID, _memberID);

        if (allianceInfos[_passID].managerFeeRate == 0 && allianceInfos[_passID].rewardFeeRate == 0) {
            allianceInfos[_passID].managerFeeRate = 500;
            allianceInfos[_passID].rewardFeeRate = 500;
        }
        uint256 managerFee = _membershipFee * allianceInfos[_passID].managerFeeRate / 1000;
        uint256 addedReward = _membershipFee - managerFee;
        allianceInfos[_passID].allianceMemNum++;
        memberBaseDebts[_passID][_memberID] = allianceInfos[_passID].rewardPerShare;
        allianceInfos[_passID].rewardPerShare += addedReward / allianceInfos[_passID].allianceMemNum;
        allianceInfos[_passID].ownerRemainedReward += managerFee;

        emit JoinAlliance(msg.sender, _memberID, _passID, _membershipFee, managerFee, addedReward);
    }

    function quitAlliance(uint256 _memberID, uint256 _passID) public {
        require(affiliatedAlliance[_memberID] > 0, "FourJAlliance: not in an alliance.");
        require(affiliatedAlliance[_memberID] == _passID, "FourJAlliance: affiliated alliance error.");
        require(fourJID.ownerOf(_memberID) == msg.sender, "FourJAlliance: no authority.");

        claimReward(_passID, _memberID);

        _removeMemberFromAllianceEnumeration(_passID, _memberID);
        allianceInfos[_passID].allianceMemNum--;
        memberBaseDebts[_passID][_memberID] = 0;

        emit QuitAlliance(msg.sender, _passID, _memberID);
    }

    function claimReward(uint256 _passID, uint256 _memberID) public {
        require(affiliatedAlliance[_memberID] > 0, "FourJAlliance: not in an alliance.");
        require(affiliatedAlliance[_memberID] == _passID, "FourJAlliance: affiliated alliance error.");
        require(fourJID.ownerOf(_memberID) == msg.sender, "FourJAlliance: no authority.");

        uint256 rewardAmount = allianceInfos[_passID].rewardPerShare.sub(memberBaseDebts[_passID][_memberID]);
        if (rewardAmount > 0) {
            TransferHelper.safeTransfer(tokenAddress, msg.sender, rewardAmount);
            memberBaseDebts[_passID][_memberID] = allianceInfos[_passID].rewardPerShare;
        }

        emit ClaimReward(msg.sender, _passID, _memberID, rewardAmount);
    }

    /** Alliance NFT's owner claim the manager fee. */
    function claimManagerFee(uint256 _passID) public {
        require(fourJPASS.ownerOf(_passID) == msg.sender, "FourJAlliance: only alliance's owner can claim manager fee.");

        uint256 managerFeeAmount = allianceInfos[_passID].ownerRemainedReward;
        if (managerFeeAmount > 0) {
            TransferHelper.safeTransfer(tokenAddress, msg.sender, managerFeeAmount);
            allianceInfos[_passID].ownerRemainedReward = 0;
        }

        emit ClaimManagerFee(msg.sender, _passID, managerFeeAmount);
    }

    function addReward(uint256 _passID, uint256 _rewardAmount) public {
        TransferHelper.safeTransferFrom(tokenAddress, msg.sender, address(this), _rewardAmount);
        allianceInfos[_passID].rewardPerShare += _rewardAmount.div(allianceInfos[_passID].allianceMemNum);

        emit AddReward(msg.sender, _passID, _rewardAmount);
    }

    function _addMemberToAllianceEnumeration(uint256 _passID, uint256 _memberID) private {
        uint256 length = allianceInfos[_passID].allianceMemNum;
        allianceMembers[_passID][length] = _memberID;
        affiliatedAlliance[_memberID] = _passID;
        memberIndex[_memberID] = length;
    }

    function _removeMemberFromAllianceEnumeration(uint256 _passID, uint256 _memberID) private {
        uint256 lastIndex = allianceInfos[_passID].allianceMemNum - 1;
        uint256 memIndex = memberIndex[_memberID];

        if (memIndex != lastIndex) {
            uint256 lastMemID = allianceMembers[_passID][lastIndex];

            allianceMembers[_passID][memIndex] = lastMemID;
            memberIndex[lastMemID] = memIndex;
        }

        delete memberIndex[_memberID];
        delete affiliatedAlliance[_memberID];
        delete allianceMembers[_passID][lastIndex];
    }

    function setPrice(uint256 _minPrice, uint256 _normalPrice) public onlyOwner() {
        require(_normalPrice >= minPrice, "FourJAlliance: error when set membership fee standard.");
        minPrice = _minPrice;
        normalPrice = _normalPrice;
    }

    function setIDPrice(uint256 _priceID, uint256 _priceID_R, uint256 _priceID_SR, uint256 _recyclePrice) public onlyOwner() {
        require(_priceID >= rewardBase + _recyclePrice, "FourJAlliance: priceID set error.");
        require(_priceID_R > _priceID, "FourJAlliance: priceID_R set error.");
        require(_priceID_SR > _priceID_R, "FourJAlliance: priceID_SR set error.");
        recyclePrice = _recyclePrice;
        priceID = _priceID;
        priceID_R = _priceID_R;
        priceID_SR = _priceID_SR;
    }

    function setRewardBase(uint256 _rewardBase, uint256 _rewardBase_R, uint256 _rewardBase_SR) public onlyOwner() {
        require(_rewardBase_R > _rewardBase, "FourJAlliance: rewardBase_R set error.");
        require(_rewardBase_SR > _rewardBase_R, "FourJAlliance: rewardBase_SR set error.");
        rewardBase = _rewardBase;
        rewardBase_R = _rewardBase_R;
        rewardBase_SR = _rewardBase_SR;
    }

    function setMembershipFee(uint256 _passID, uint256 _membershipFee, uint256 _managerFeeRate) public {
        require(fourJPASS.ownerOf(_passID) == msg.sender, "FourJAlliance: only owner can set membership fee.");
        require(_membershipFee >= minPrice, "FourJAlliance: error when set membership fee.");
        require(_managerFeeRate <= 1000, "FourJAlliance: error when set membership manager fee rate.");
        allianceInfos[_passID].membershipFee = _membershipFee;
        allianceInfos[_passID].managerFeeRate = _managerFeeRate;
        allianceInfos[_passID].rewardFeeRate = 1000 - _managerFeeRate;
    }

    function changeReceiver(address _receiver, address _rewardAddress) public onlyOwner() {
        receiver = _receiver;
        rewardAddress = _rewardAddress;
    }

    function transferAsset(uint256 value) public onlyOwner() {
        uint256 recycleCount = characterCount - destroyCount - countID_R - countID_SR - countID_SSR - countID_SP;
        require(recycleCount * recyclePrice + value <= address(this).balance, "FourJAlliance: not enough asset.");
        TransferHelper.safeTransferETH(receiver, value);
    }

    function transferOtherAsset(address token, uint256 value) public onlyOwner() {
        require(token != tokenAddress, "FourJAlliance: cannot transfer 4JNET from this address.");
        TransferHelper.safeTransfer(token, receiver, value);
    }
}