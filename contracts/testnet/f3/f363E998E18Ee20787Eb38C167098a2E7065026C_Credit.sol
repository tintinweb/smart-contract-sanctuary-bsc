//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface IPancakePair {

    function balanceOf(address owner) external view returns (uint256);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface IPancakeFactory {

    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface Proof {

    function mint(address _recipient) external returns (uint256);

    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId) external view returns (address);

    function ownerOf(uint256 tokenId) external view returns (address);

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function safeTransfer(address to, uint256 tokenId) external;
}

contract Credit is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public FuelAddress;

    uint256 public FuelAmount;

    address public collectAddress;

    address public NFTAddress;

    address public PancakeFactoryAddress;

    address public DAOsAddress;

    address public DAOsFeeAddress;

    address public UsdtAddress;

    uint256 public repayPeriod;

    address public FuelPledgeAwardAddress;

    mapping(address => uint256[]) tokenIds;

    struct Members {
        address account;
        uint256 loanStatus;
        uint256 repayCount;
        bool isLoan;
    }

    struct GroupInfo {
        uint256 level;
        uint256 tokenId;
        uint256 activateStatus;
        uint256 createTime;
    }

    struct CreditConfig {
        uint256 quota;
        uint256 period;
        uint256 repayRatio;
        uint256 interestRatio;
        uint256 overduePeriod;
        uint256 overdueRatio;
    }

    struct DebitRepay {
        uint256 tokenId;
        address account;
        uint256 debitAmount;
        uint256 period;
        uint256 repayRatio;
        uint256 repayAmount;
        uint256 interestRatio;
        uint256 interest;
        uint256 overdueRatio;
        uint256 overdueAmount;
        uint256 repayTime;
        uint256 overdueTime;
        uint256 status;
    }

    struct RepayRatioConfig {
        uint256 creatorRatio;
        uint256 pledgeAwardRatio;
    }

    mapping(address => GroupInfo[]) public groupInfos;

    mapping(uint256 => Members[]) public members;

    mapping(address => bool) public isMember;

    mapping(address => bool) public isLeader;

    mapping(uint256 => CreditConfig) public creditConfig;

    mapping(address => DebitRepay[]) public debitRepays;

    mapping(uint256 => address) public creatorAddress;

    RepayRatioConfig public repayRatioConfig;

    function setFuelAddress(address _FuelAddress) public onlyOwner {
        FuelAddress = _FuelAddress;
    }

    function setFuelAmount(uint256 _FuelAmount) public onlyOwner {
        FuelAmount = _FuelAmount;
    }

    function setNFTAddress(address _NFTAddress) public onlyOwner {
        NFTAddress = _NFTAddress;
    }

    function setDAOsAddress(address _DAOsAddress) public onlyOwner {
        DAOsAddress = _DAOsAddress;
    }

    function setDAOsFeeAddress(address _DAOsFeeAddress) public onlyOwner {
        DAOsFeeAddress = _DAOsFeeAddress;
    }

    function setCollectAddress(address _collectAddress) public onlyOwner {
        collectAddress = _collectAddress;
    }

    function setUsdtAddress(address _UsdtAddress) public onlyOwner {
        UsdtAddress = _UsdtAddress;
    }

    function getFuelAmount() public view returns (uint256) {
        return FuelAmount;
    }

    function setIPancakeFactory(address _PancakeFactoryAddress) public onlyOwner {
        PancakeFactoryAddress = _PancakeFactoryAddress;
    }

    function setPepayPeriod(uint256 _repayPeriod) public onlyOwner {
        repayPeriod = _repayPeriod;
    }

    function setFuelPledgeAwardAddress(address _FuelPledgeAwardAddress) public onlyOwner {
        FuelPledgeAwardAddress = _FuelPledgeAwardAddress;
    }

    function getGroupInfoByAddress(address _address) public view returns (GroupInfo[] memory) {
        return groupInfos[_address];
    }

    function getTokenIdByAddress(address _address) public view returns (uint256[] memory) {
        return tokenIds[_address];
    }

    function getMemberInfoByTokenId(uint256 tokenId) public view returns(Members[] memory){
        return members[tokenId];
    }

    function getRepayInfoByAddress(address _address) public view returns (DebitRepay[] memory) {
        return debitRepays[_address];
    }

    function setCreditConfig(
        uint256 _level,
        uint256 _quota,
        uint256 _period,
        uint256 _repayRatio,
        uint256 _interestRatio,
        uint256 _overduePeriod,
        uint256 _overdueRatio
    ) public onlyOwner {
        creditConfig[_level].quota = _quota;
        creditConfig[_level].period = _period;
        creditConfig[_level].repayRatio = _repayRatio;
        creditConfig[_level].interestRatio = _interestRatio;
        creditConfig[_level].overduePeriod = _overduePeriod;
        creditConfig[_level].overdueRatio = _overdueRatio;
    }

    function setRepayRatioConfig(uint256 _creatorRatio, uint256 _pledgeAwardRatio) public onlyOwner {
        repayRatioConfig.creatorRatio = _creatorRatio;
        repayRatioConfig.pledgeAwardRatio = _pledgeAwardRatio;
    }

    function mint() public returns (uint256) {
        require(FuelAddress != address(0), "FuelAddress contract empty");
        require(collectAddress != address(0), "Collection address empty");
        IERC20(FuelAddress).safeTransferFrom(address(msg.sender), address(this), FuelAmount);
        IERC20(FuelAddress).transfer(collectAddress, FuelAmount);
        uint256 tokenId = Proof(NFTAddress).mint(msg.sender);
        tokenIds[msg.sender].push(tokenId);
        return tokenId;
    }

    function approve(address _to, uint256 _tokenId) public {
        Proof(NFTAddress).approve(_to, _tokenId);
    }

    function createGroup(address[] memory _addrArr, uint256 _tokenId) public {
        require(tokenIds[msg.sender].length > 0, "Not hold NFT");
        require(!checkAddress(_addrArr), "Member has Team");
        address approvedAddress = Proof(NFTAddress).getApproved(_tokenId);
        require(approvedAddress != address(0), "NFT must be approved first");
        address owner = Proof(NFTAddress).ownerOf(_tokenId);
        require(owner == msg.sender, "NFT owner is not you");
        require(_addrArr.length == 4, "Understaffed");
        for (uint256 i = 0; i < _addrArr.length; i++) {
            addMemberInfo(_addrArr[i], _tokenId);
        }
        addGroupOwnerInfo(_tokenId);
        creatorAddress[_tokenId] = msg.sender;
    }

    function pledgeNFT(uint256 _tokenId) public {
        address owner = Proof(NFTAddress).ownerOf(_tokenId);
        require(owner == msg.sender, "NFT owner is not you");
        require(!checkLeader(msg.sender), "Leader has actived Team");
        Proof(NFTAddress).safeTransferFrom(msg.sender, address(this), _tokenId);
        uint256[] storage myTokenIds = tokenIds[msg.sender];
        for (uint256 i = 0; i < myTokenIds.length; i++) {
            uint256 id = myTokenIds[i];
            if (id == _tokenId) {
                delete myTokenIds[i];
            }
        }
        Members[] storage memberList = members[_tokenId];
        for (uint256 i = 0; i < memberList.length; i++) {
            if (memberList[i].account != msg.sender) {
                memberList[i].loanStatus = 1;
            }
        }
        GroupInfo[] storage groupInfoList = groupInfos[msg.sender];
        for (uint256 i = 0; i < groupInfoList.length; i++) {
            GroupInfo storage groupInfo = groupInfoList[i];
            if (groupInfo.tokenId == _tokenId) {
                groupInfo.activateStatus = 1;
            }
        }
        isLeader[msg.sender] = true;
    }

    function redeem(uint256 _tokenId) public {
        address owner = Proof(NFTAddress).ownerOf(_tokenId);
        require(owner != msg.sender, "NFT owner is you");
        require(!checkIsLoan(_tokenId), "Member is Loaning");
        Proof(NFTAddress).safeTransfer(msg.sender, _tokenId);
        Members[] storage memberList = members[_tokenId];
        for (uint256 i = 0; i < memberList.length; i++) {
            memberList[i].loanStatus = 0;
        }
        GroupInfo[] storage groupInfoList = groupInfos[msg.sender];
        for (uint256 i = 0; i < groupInfoList.length; i++) {
            if (groupInfoList[i].tokenId == _tokenId) {
                groupInfoList[i].activateStatus = 0;
            }
        }
        tokenIds[msg.sender].push(_tokenId);
        isLeader[msg.sender] = false;
    }

    function checkLevelUp(address _address, uint256 _index) public view returns (bool) {
        GroupInfo memory groupInfo = groupInfos[_address][_index];
        uint256 tokenId = groupInfo.tokenId;
        Members[] memory memberList = members[tokenId];
        for (uint256 i = 0; i < memberList.length; i++) {
            if (memberList[i].loanStatus != 3) {
                return false;
            }
        }
        return true;
    }

    function levelUp(address _address, uint256 _index) public {
        require(checkLevelUp(_address, _index), "Upgrade conditions not met");
        GroupInfo storage groupInfo = groupInfos[_address][_index];
        Members[] storage memberList = members[groupInfo.tokenId];
        for (uint256 i = 0; i < memberList.length; i++) {
            memberList[i].loanStatus = 1;
        }
        groupInfo.level += 1;
    }

    function borrow(address _address, uint256 _index) public {
        require(checkIsCreator(msg.sender, _index), "No permission");
        GroupInfo memory groupInfo = groupInfos[msg.sender][_index];
        Members[] storage memberList = members[groupInfo.tokenId];
        if (_address == msg.sender) {
           require(checkBorrow(memberList, 4, msg.sender), "Conditions not met");     
        } else {
           uint256 count = countLoanNumber(groupInfo.tokenId);  
           if (count >= 2) {
               require(checkBorrow(memberList, 2, msg.sender), "Conditions not met");     
           }
        }
        CreditConfig memory config = creditConfig[groupInfo.level];
        uint256 price = getTokenPrice(DAOsAddress, UsdtAddress);
        uint256 amount = config.quota.div(price);
        for (uint256 i = 0; i < config.period; i++) {
            addRepayInfo(config, _address, amount, groupInfo.tokenId, i);
        }
        Members storage member;
        for (uint256 i = 0; i < memberList.length; i++) {
            if (memberList[i].account == _address) {
                member = memberList[i];
                member.loanStatus = 2;
            }
        }
    }

    function repay(uint256 _period) public {
        DebitRepay storage debitRepay = debitRepays[msg.sender][_period-1];
        require(debitRepay.status == 0, "DebitRepay Status Error");
        require(block.timestamp > debitRepay.repayTime, "No repayment required");

        uint overdueAmount;
        if (block.timestamp > debitRepay.overdueTime) {
             overdueAmount =  debitRepay.overdueAmount;     
        }
        uint256 price = getTokenPrice(UsdtAddress, DAOsAddress);
        uint256 repayAmount = (debitRepay.repayAmount
        .add((debitRepay.interest.add(overdueAmount)).mul(repayRatioConfig.creatorRatio).div(1e18))).div(price);
        IERC20(UsdtAddress).safeTransferFrom(address(msg.sender), FuelPledgeAwardAddress, repayAmount);
        uint256 reward = (debitRepay.interest.add(overdueAmount).mul(repayRatioConfig.creatorRatio).div(1e18)).div(price);
        IERC20(UsdtAddress).safeTransferFrom(address(msg.sender), creatorAddress[debitRepay.tokenId], reward);
        
        debitRepay.status = 1;
        Members[] storage memberList = members[debitRepay.tokenId];
        Members storage member;
        for (uint256 i = 0; i < memberList.length; i++) {
            if (memberList[i].account == msg.sender) {
                member = memberList[i];
                member.loanStatus = 3;
            }
        }
    }

    function getTokenPrice(address token1, address token2) public view returns (uint256) {
        address pair = IPancakeFactory(PancakeFactoryAddress).getPair(token1, token2);
        uint256 balanceA = IPancakePair(token1).balanceOf(pair);  
        uint256 balanceB = IPancakePair(token2).balanceOf(pair); 
        return balanceB.div(balanceA);   
    }

    function addMemberInfo(address _address, uint256 _tokenId) private {
        members[_tokenId].push(
            Members({
                account: _address,
                loanStatus: 0,
                repayCount: 0,
                isLoan: false
            })
        );
        groupInfos[_address].push(
            GroupInfo({
                level: 1,
                tokenId: _tokenId,
                activateStatus: 0,
                createTime: block.timestamp
            })
        );
        isMember[_address] = true;
    }

    function addGroupOwnerInfo(uint256 _tokenId) private {
        members[_tokenId].push(
            Members({
                account: msg.sender,
                loanStatus: 0,
                repayCount: 0,
                isLoan: false
            })
        );
        groupInfos[msg.sender].push(
            GroupInfo({
                level: 1,
                tokenId: _tokenId,
                activateStatus: 0,
                createTime: block.timestamp
            })
        );
    }

    function addRepayInfo (CreditConfig memory config, address _address, uint256 _amount, uint256 _tokenId, uint i) private {
        uint256 _repayAmount = _amount.mul(config.repayRatio).div(1e18);
        uint256 _repayTime = block.timestamp + repayPeriod * i;
        debitRepays[_address].push(
            DebitRepay({
                tokenId : _tokenId, 
                account: _address,
                debitAmount: _amount,
                period : i + 1,
                repayRatio: config.repayRatio,
                repayAmount: _repayAmount,
                interestRatio: config.interestRatio,
                interest: _repayAmount.mul(config.interestRatio).div(1e18),
                overdueRatio: config.overdueRatio,
                overdueAmount: _repayAmount.mul(config.overdueRatio).div(1e18),
                repayTime: _repayTime,
                overdueTime : _repayTime + repayPeriod * config.overduePeriod,
                status: 0
            })
        );
    }

    function checkMember(address _address) private view returns (bool) {
        return isMember[_address];
    }

    function checkLeader(address _address) private view returns (bool) {
        return isLeader[_address];
    }

    function checkIsLoan(uint256 _tokenId) private view returns (bool) {
        Members[] memory memberList = members[_tokenId];
        for (uint256 i = 0; i < memberList.length; i++) {
            if (memberList[i].loanStatus == 2) {
                return true;
            }
        }
        return false;
    }

    function checkIsCreator(address _address, uint256 _index)  private view returns (bool) {
        GroupInfo memory groupInfo = groupInfos[_address][_index];
        uint256 tokenId = groupInfo.tokenId;
        if(creatorAddress[tokenId] == msg.sender) {
            return true;
        }
        return false;
    }

    function countLoanNumber(uint256 _tokenId) private view returns (uint256) {
        Members[] memory memberList = members[_tokenId];
        uint256 count;
        for (uint256 i = 0; i < memberList.length; i++) {
            if (memberList[i].loanStatus == 2) {
                count += 1;
            }
        }
        return count;
    }

    function checkBorrow(Members[] memory memberList, uint256 number, address _msgSender) private pure returns(bool) {
        uint256 count;
        for (uint256 i = 0; i < memberList.length; i++) {
            if (memberList[i].repayCount >= 6 && memberList[i].account != _msgSender) {
                count += 1;
            }
        }
        if (count == number) {
            return true;
        }
        return false;
    }

    function checkAddress(address[] memory addressList) private view returns (bool) {
        for (uint256 i = 0; i < addressList.length; i++) {
            address _address = addressList[i];
            if (isMember[_address] || checkLeader(_address)) {
                return true;
            }
        }
        return false;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
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
        IERC20 token,
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
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
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
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
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
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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