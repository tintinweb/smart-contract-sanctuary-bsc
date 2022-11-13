/**
 *Submitted for verification at BscScan.com on 2022-11-13
*/

pragma solidity >=0.4.22 <0.9.0;

// SPDX-License-Identifier: Unlicensed

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
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)



/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}
interface IERC20 {
    function decimals() external view returns (uint8);
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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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


// Dependency file: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


// pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */



// Dependency file: @openzeppelin/contracts/utils/Context.sol


// pragma solidity ^0.8.0;

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


// Dependency file: @openzeppelin/contracts/token/ERC20/ERC20.sol


// pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
// import "@openzeppelin/contracts/utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */

contract Ownable {
    address public owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() public {
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}
 
interface IUniswapV2Router02 {
    function factory() external pure returns (address);
 
    function WETH() external pure returns (address);
 
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
     function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )external returns (uint256 amountA,uint256 amountB,uint256 liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);
}
library IterableMiningPool {
    using SafeMath for uint256;
    // Iterable mapping from address to uint;
    struct PledgeInfo{
        uint256 amount;
        uint256 profitAmount;
        uint256 lpAmount;
        uint256 pledgeTime;
        uint256 deadLine;
    }
    struct MiningPoolInfo{//
        uint256 totalAmount;
        uint256 totalUser;
        uint256 curTotalAmount;
        uint256 totalProfitAmount;
        uint16 profitRate;
        uint16 inviterRate;
        uint16 depositRate;
        mapping(uint256 => address) values;//index useaddress
        address [] keys;
        mapping(address=>PledgeInfo) pledgeInfoMap;
        mapping(address => bool) inserted;
        mapping(address => uint256) indexOf;
    }
    struct Map {
         uint256[] keys;
        //mapping(address => uint256) values;
        uint256 totalAmount;
        uint256 totalUser;
        mapping(uint256 => uint256) indexOf;
        mapping(uint256 => MiningPoolInfo) miningPoolInfoMap;
        mapping(uint256 => bool) inserted;
    }
    function set(Map storage map,uint256 key,uint256 _amount,uint16 _profitRate,uint16 _inviterRate,
    uint16 _depositRate) public {
        if (map.inserted[key]) {
            if(_amount>0){
                map.miningPoolInfoMap[key].totalAmount =map.miningPoolInfoMap[key].totalAmount.add(_amount);
                map.miningPoolInfoMap[key].curTotalAmount =map.miningPoolInfoMap[key].curTotalAmount.add(_amount);
                map.miningPoolInfoMap[key].totalProfitAmount =map.miningPoolInfoMap[key].totalProfitAmount.add(_amount);
            }
        } else {
            map.inserted[key] = true;
            map.miningPoolInfoMap[key].totalAmount =_amount;
            map.miningPoolInfoMap[key].curTotalAmount =_amount;
            map.miningPoolInfoMap[key].totalProfitAmount =_amount;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
        map.miningPoolInfoMap[key].profitRate=_profitRate;
        map.miningPoolInfoMap[key].inviterRate=_inviterRate;
        map.miningPoolInfoMap[key].depositRate=_depositRate;
    }
    function isHasMiningPoolType(Map storage map,uint256 _miningPoolType)public view returns(bool){
        return map.inserted[_miningPoolType];
    }
    function addPledgeUser(Map storage map,uint256 _miningPoolType,address _account,uint256 _amount,uint256 _profitAmount) public{
        if (map.inserted[_miningPoolType]) {
            require(!map.miningPoolInfoMap[_miningPoolType].inserted[_account],"user already has being!");
            map.miningPoolInfoMap[_miningPoolType].inserted[_account]= true;
            map.miningPoolInfoMap[_miningPoolType].indexOf[_account] = map.miningPoolInfoMap[_miningPoolType].keys.length;
            map.miningPoolInfoMap[_miningPoolType].keys.push(_account);
            map.miningPoolInfoMap[_miningPoolType].pledgeInfoMap[_account].amount=_amount;
            map.miningPoolInfoMap[_miningPoolType].pledgeInfoMap[_account].profitAmount=_profitAmount;
            map.miningPoolInfoMap[_miningPoolType].totalAmount =map.miningPoolInfoMap[_miningPoolType].totalAmount.add(_amount);
            map.miningPoolInfoMap[_miningPoolType].totalUser =map.miningPoolInfoMap[_miningPoolType].totalUser.add(1);
            map.miningPoolInfoMap[_miningPoolType].curTotalAmount =map.miningPoolInfoMap[_miningPoolType].curTotalAmount.add(_amount);
            map.totalAmount=map.totalAmount.add(_amount);
            map.totalUser=map.totalUser.add(1);
            map.miningPoolInfoMap[_miningPoolType].totalProfitAmount=map.miningPoolInfoMap[_miningPoolType].totalProfitAmount.add(_profitAmount);
        } 
    }
    function refreshPledgeUser(Map storage map,uint256 _miningPoolType,address _account,uint256 _deadLine) public{
        require(map.miningPoolInfoMap[_miningPoolType].inserted[_account],"user has no being!");
        uint256 _amount=map.miningPoolInfoMap[_miningPoolType].pledgeInfoMap[_account].amount;
        uint256 _profitAmount=map.miningPoolInfoMap[_miningPoolType].pledgeInfoMap[_account].profitAmount;
        map.miningPoolInfoMap[_miningPoolType].pledgeInfoMap[_account].pledgeTime=block.timestamp;
        map.miningPoolInfoMap[_miningPoolType].pledgeInfoMap[_account].deadLine=_deadLine;
        map.miningPoolInfoMap[_miningPoolType].totalAmount =map.miningPoolInfoMap[_miningPoolType].totalAmount.add(_amount);
        map.miningPoolInfoMap[_miningPoolType].totalProfitAmount=map.miningPoolInfoMap[_miningPoolType].totalProfitAmount.add(_profitAmount);
        map.miningPoolInfoMap[_miningPoolType].curTotalAmount =map.miningPoolInfoMap[_miningPoolType].curTotalAmount.add(_amount);
        map.miningPoolInfoMap[_miningPoolType].totalUser =map.miningPoolInfoMap[_miningPoolType].totalUser.add(1);
        
        map.totalAmount=map.totalAmount.add(_amount);
        map.totalUser=map.totalUser.add(1);
    }
    function removePledgeUser(Map storage map,uint256 _miningPoolType,address _account) public{
        require(map.miningPoolInfoMap[_miningPoolType].inserted[_account],"user has no being!");
        delete map.miningPoolInfoMap[_miningPoolType].inserted[_account];
        delete map.miningPoolInfoMap[_miningPoolType].pledgeInfoMap[_account];
        uint256 index = map.miningPoolInfoMap[_miningPoolType].indexOf[_account];
        uint256 lastIndex = map.miningPoolInfoMap[_miningPoolType].keys.length - 1;
        address lastKey = map.miningPoolInfoMap[_miningPoolType].keys[lastIndex];
        map.miningPoolInfoMap[_miningPoolType].indexOf[lastKey] = index;

        delete map.miningPoolInfoMap[_miningPoolType].indexOf[_account];
        map.miningPoolInfoMap[_miningPoolType].keys[index] = lastKey;
        map.miningPoolInfoMap[_miningPoolType].keys.pop();
        map.miningPoolInfoMap[_miningPoolType].curTotalAmount =map.miningPoolInfoMap[_miningPoolType].curTotalAmount.sub(map.miningPoolInfoMap[_miningPoolType].pledgeInfoMap[_account].amount);
    }
    function get(Map storage map, uint256 key) public view returns (uint256 _totalAmount,uint16 _feeRate,uint256 _length) {
        return (map.miningPoolInfoMap[key].totalAmount,map.miningPoolInfoMap[key].profitRate,map.miningPoolInfoMap[key].keys.length);
    }

    function getIndexOfKey(Map storage map, uint256 key) public view returns (int256)
    {
        if (!map.inserted[key]) {
            return -1;
        }
        return int256(map.indexOf[key]);
    }
    function getKeyAtIndex(Map storage map, uint256 index)public view returns (uint256)
    {
        return map.keys[index];
    }
    //totalprofit
    function getMiningTotalProfitAmount(Map storage map) public view returns(uint256[] memory) {
        uint256[] memory isTakePartIn=new uint256[](map.keys.length);
        for(uint i=0;i<map.keys.length;i++){
            uint256 _miningPoolType=map.keys[i];
            MiningPoolInfo storage miningPoolInfo= map.miningPoolInfoMap[_miningPoolType];
            isTakePartIn[i]=miningPoolInfo.totalProfitAmount;
        }
        return isTakePartIn;
    }
    //pledge amount
    function getUserAllPledgeInfo(Map storage map, address _account) public view returns(uint256[] memory) {
        uint256[] memory isTakePartIn=new uint256[](map.keys.length);
        for(uint i=0;i<map.keys.length;i++){
            uint256 _miningPoolType=map.keys[i];
            MiningPoolInfo storage miningPoolInfo= map.miningPoolInfoMap[_miningPoolType];
            isTakePartIn[i]=miningPoolInfo.pledgeInfoMap[_account].amount;
        }
        return isTakePartIn;
    }
    //amount、time、releasetime、profit、LP
    function getSingleUserPledgeInfo(Map storage map, address _account,uint256 _miningPoolType) public view returns(uint256,uint256,uint256,uint256,uint256) {
        MiningPoolInfo storage miningPoolInfo= map.miningPoolInfoMap[_miningPoolType];
        
        return(miningPoolInfo.pledgeInfoMap[_account].amount,miningPoolInfo.pledgeInfoMap[_account].pledgeTime,
        miningPoolInfo.pledgeInfoMap[_account].deadLine,miningPoolInfo.pledgeInfoMap[_account].profitAmount,
        miningPoolInfo.pledgeInfoMap[_account].lpAmount);
    }
    function getCurTotalPledgeInfo(Map storage map) public view returns(uint256,uint256) {
        uint256 totalAmount;uint256 totalUser;
        for(uint i=0;i<map.keys.length;i++){
            uint256 _miningPoolType=map.keys[i];
            totalAmount=totalAmount.add(map.miningPoolInfoMap[_miningPoolType].curTotalAmount);
            totalUser=totalUser.add(map.miningPoolInfoMap[_miningPoolType].keys.length);
        }
        return(totalAmount,totalUser);
    }
    function getMiningPoolPledgeInfo(Map storage map,uint256 _miningPoolType) public view returns(uint256,uint256,uint256,uint256) {
        MiningPoolInfo storage miningPoolInfo= map.miningPoolInfoMap[_miningPoolType];
        return(miningPoolInfo.totalAmount,miningPoolInfo.totalUser,miningPoolInfo.curTotalAmount,miningPoolInfo.keys.length);
    }
    function getMiningPoolInfo(Map storage map,uint256 _miningPoolType) public view returns(uint16,uint16,uint16) {
        MiningPoolInfo storage miningPoolInfo= map.miningPoolInfoMap[_miningPoolType];
        return(miningPoolInfo.profitRate,miningPoolInfo.inviterRate,miningPoolInfo.depositRate);
    }
    function size(Map storage map) public view returns (uint256) {
        return map.keys.length;
    }
    function setFeeType(
        Map storage map,
        uint256 key,
        uint16 _feeRate
    ) public {
        if (map.inserted[key]) {
            map.miningPoolInfoMap[key].profitRate=_feeRate;
        } 
    }

    function remove(Map storage map, uint256 key) public {
        if (!map.inserted[key]) {
            return;
        }
        delete map.inserted[key];
        delete map.miningPoolInfoMap[key];
        uint256 index = map.indexOf[key];
        uint256 lastIndex = map.keys.length - 1;
        uint256 lastKey = map.keys[lastIndex];
        map.indexOf[lastKey] = index;
        delete map.indexOf[key];
        map.keys[index] = lastKey;
        map.keys.pop();
    }
}
library IterableTakePartInUser{
    using SafeMath for uint256;
    struct TakePartInInfo{
        uint256 miningPoolType;
        uint256 amount;
        uint256 [] keys;
        uint256 takePartInTime;
        uint256 deadLine;
    }
    struct UserInfo{
        uint256 totalPledgeAmount;//single total pledge
        uint256 totalProfitAmount;
        uint256 totalInviterPledgeAmount;
        mapping(uint256 => TakePartInInfo) takePartInInfoMap;
        uint256 totalInviterEarnings;
        uint256 curInviterEarnings;
        uint256 oneRankInviterCount;
        uint256 allRankInviterCount;
        uint256 [] keys;
        mapping(address => bool) inviteeInserted;//
        address [] oneRankInviter;
        mapping(uint256=>uint256) lpAmountMap;
    }
    struct Map {
        // address[] keys;
        //mapping(address => uint256) values;
        //mapping(address => uint256) indexOf;
        mapping(address => UserInfo) userInfoMap;
        mapping(address => bool) inserted;
    }
    function set(Map storage map, address key, uint256 _amount,uint256 _profitFee) public {
        if (map.inserted[key]) {
            map.userInfoMap[key].totalPledgeAmount =map.userInfoMap[key].totalPledgeAmount.add(_amount);
            map.userInfoMap[key].totalProfitAmount=map.userInfoMap[key].totalProfitAmount.add(_profitFee);
            map.userInfoMap[key].totalInviterPledgeAmount=map.userInfoMap[key].totalInviterPledgeAmount.add(_amount);
        } else {
            map.inserted[key] = true;
            map.userInfoMap[key].totalPledgeAmount = _amount;
            map.userInfoMap[key].totalProfitAmount=_profitFee;
            map.userInfoMap[key].totalInviterPledgeAmount=_amount; 
            map.userInfoMap[key].allRankInviterCount =map.userInfoMap[key].allRankInviterCount.add(1);
            //map.indexOf[key] = map.keys.length;
            //map.keys.push(key);
        }
    }
    function addInviterCount(Map storage map, address key,address invitee) public {
        if(!map.inserted[key]){
            map.userInfoMap[key].allRankInviterCount =map.userInfoMap[key].allRankInviterCount.add(1);
            map.inserted[key] = true;
        }
        if(!map.userInfoMap[key].inviteeInserted[invitee]){
            map.userInfoMap[key].allRankInviterCount =map.userInfoMap[key].allRankInviterCount.add(1);
            map.userInfoMap[key].oneRankInviterCount =map.userInfoMap[key].oneRankInviterCount.add(1);
            map.userInfoMap[key].oneRankInviter.push(invitee);
            map.userInfoMap[key].inviteeInserted[invitee]=true;
        }
    }
    function addInviterEarnings(Map storage map, address key,uint256 _amount) public {
        map.userInfoMap[key].curInviterEarnings =map.userInfoMap[key].curInviterEarnings.add(_amount);
        map.userInfoMap[key].totalInviterEarnings =map.userInfoMap[key].totalInviterEarnings.add(_amount);
    }
    function addInviterTotalPledge(Map storage map, address key,uint256 _amount) public {
        map.userInfoMap[key].totalInviterPledgeAmount =map.userInfoMap[key].totalInviterPledgeAmount.add(_amount);
       
    }
    function addAllRankInviterCount(Map storage map, address key) public {
        map.userInfoMap[key].allRankInviterCount =map.userInfoMap[key].allRankInviterCount.add(1);
    }
    function getInviterCount(Map storage map, address key) public view returns(uint256,uint256,uint256,uint256,
    uint256,uint256) {
        return (map.userInfoMap[key].oneRankInviterCount,map.userInfoMap[key].allRankInviterCount,
        map.userInfoMap[key].totalInviterPledgeAmount,map.userInfoMap[key].totalPledgeAmount,
        map.userInfoMap[key].totalProfitAmount,map.userInfoMap[key].totalInviterEarnings);
        
    }
    function getInviterEarnings(Map storage map, address key) public view returns(uint256) {
        return map.userInfoMap[key].curInviterEarnings;
    }
    function clearInviterEarnings(Map storage map, address key) public {
        map.userInfoMap[key].curInviterEarnings=0;
    }
}
contract TokenDistributor is Ownable{
    IUniswapV2Router02 private uniswapV2Router;
    address private msgSender;
    address private txOrigin;
    address private lpPair;
    constructor (address betToken,address bonusToken,address _lpPair,IUniswapV2Router02 _uniswapV2Router) {
        msgSender=msg.sender;
        txOrigin=tx.origin;
        lpPair=_lpPair;
        IERC20(betToken).approve(msg.sender, uint(~uint256(0)));
        IERC20(betToken).approve(tx.origin, uint(~uint256(0)));
        IERC20(bonusToken).approve(msg.sender, uint(~uint256(0)));
        IERC20 lpToken= IERC20(lpPair);
        lpToken.approve(msg.sender, uint(~uint256(0)));
        lpToken.approve(address(_uniswapV2Router), uint(~uint256(0)));
        uniswapV2Router=_uniswapV2Router;
    }
    function removeLiquify(uint256 _lpAmount,address _betToken,address _bonusToken) public onlyOwner{ 
        uniswapV2Router.removeLiquidity(_bonusToken,_betToken,_lpAmount,0,0,
        address(msgSender),block.timestamp); 
    }
    function getMsgSender() public view returns(address) { 
        return msgSender; 
    }
    function getTxOrigin() public view returns(address) { 
        return txOrigin; 
    }
    function getDistributor() public view returns(address) { 
        return address(this); 
    }
    function getLPBalance() public view returns(uint256) { 
        IERC20 lpToken= IERC20(lpPair);
        return lpToken.balanceOf(address(this)); 
    }
    function transferLPBalance(uint256 _lpAmount) public onlyOwner { 
        IERC20 lpToken= IERC20(lpPair);
        uint256 lpBalance=lpToken.balanceOf(address(this)); 
        require(lpBalance>=_lpAmount,"LPBalance is low");
        lpToken.transfer(address(msgSender), _lpAmount);
    }
} 
contract LPAMM is Ownable{
     using SafeMath for uint256;
     uint256 private constant MAX = ~uint256(0);
    uint256 private SECONDS_PER_DAY =10;// 24 * 60 * 60;
    address public betTokenAddress=address(0xDa77DF4fE66449B0CFef77f6c539AAc0875bC634);//usdt
    address public bonusTokenAddress=address(0xdE35655B29cBB2940b83d3EDC1939236660e5532);//0xC74e2C4AB44B924264Ee86D34819EEf563869fc0
    address private nftTokenAddress=address(0x2422D6aD1EB9aa4562003a4542BB008c23666977);
    uint256 private minNftAmount=0;
    uint256 private nftInviterFeeRank=3;
    //uint256 public minBetAmount=50*10**18;
    //uint256 public bingoReturnAmount=1*10**18;
    //uint256 public noBingoReturnAmount=55*10**18;
    //uint16 private _inviterFee0=10;//1 1%
    //uint16 private _inviterFee1=5;//2 0.5%
    //uint256 private withdrawMinInviterFee=0;
    uint256[] internal shareConfig = [400,200,100,50,50,40,40,40,40,40];
    uint256 private shareRank=10;
    mapping(address => address) public inviter;
    mapping(address => bool) private marketingAddressMap;
    using IterableTakePartInUser for IterableTakePartInUser.Map;
    IterableTakePartInUser.Map takePartInUserMap;
    using IterableMiningPool for IterableMiningPool.Map;
    IterableMiningPool.Map miningPoolMap;
    //mapping (uint256 => address) private currentSetAddress;
    //found add
    //address private foundAddress=address(0x78c9424e89f647f2927f988c6D09CbA427F0538A);
    //uint16 private foundRate=300;
    //address private marketingAddress=address(0xD3727A6B75D5162609e130b2bEE85e728A994d24);
    //uint16 private marketingRate=700;
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public  uniswapV2Pair=address(0x336Fc7c54d71119c73eb8819954329fa5371a631);
    TokenDistributor private _tokenDistributor;
    bool inSwapAndLiquify;
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    constructor() public {
        //main
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(address(0x10ED43C718714eb63d5aA57B78B54704E256024E));
        uniswapV2Router = _uniswapV2Router;
        betTokenAddress=address( 0x55d398326f99059fF775485246999027B3197955);//usdt
        bonusTokenAddress=address(0x88888888FAedEB25B94A015Af705F18666079038);//ag
        uniswapV2Pair=address(0x8c6BdcaA5DAa66dC851A31Cdf21F2C1b2e83713D);//lp
        nftTokenAddress=address(0x9D8F8EA82b12a6E48D8423F0EC9907ad599233A8);
        //marketingAddress=address(0xC21615Dc830bBf94Ef3d5f2D607Df752Ebf90924);
        marketingAddressMap[address(0xC21615Dc830bBf94Ef3d5f2D607Df752Ebf90924)]=true;
        marketingAddressMap[address(0xe2D2287F74f8d01ca26F30645c997B36869Cb55A)]=true;
        _tokenDistributor = new TokenDistributor(betTokenAddress,bonusTokenAddress,uniswapV2Pair,_uniswapV2Router);

        miningPoolMap.set(7,0,60,0,0);
        miningPoolMap.set(30,0,120,100,100);
        miningPoolMap.set(90,0,160,100,100);
        miningPoolMap.set(180,0,200,100,100);
        miningPoolMap.set(360,0,240,100,100);
        IERC20(betTokenAddress).approve(address(_uniswapV2Router), MAX);
        IERC20(bonusTokenAddress).approve(address(_uniswapV2Router), MAX);
    }
    event TakePartIn(uint32,uint256);
    //event GameBingo(uint32,address[]);
    //event SetRealCount(uint256,uint256);
    //event BingoAddress(address,address);
    function takePartIn(uint256 _betAmount,uint256 _miningPoolType) payable public returns (uint32){
      require(_betAmount>0,"amount is zero");
      require(miningPoolMap.isHasMiningPoolType(_miningPoolType),"miningPoolType no has");
      uint32 status=0;
      IterableMiningPool.MiningPoolInfo storage miningPoolInfo= miningPoolMap.miningPoolInfoMap[_miningPoolType];
      IERC20 erc20token = IERC20(betTokenAddress);
      require(erc20token.balanceOf(address(msg.sender))>=_betAmount,"balance is low");
      erc20token.transferFrom(msg.sender, address(this), _betAmount);
      //.transfer(address(this), _betAmount);
      uint16 _takeRate=miningPoolInfo.inviterRate+miningPoolInfo.depositRate;
      uint256 _addLiquidityAmount=_betAmount;
      if(_takeRate>0){
          uint256 _takeFee=_betAmount.div(1000).mul(_takeRate);
          _addLiquidityAmount=_betAmount.sub(_takeFee);
      }
      swapAndLiquify(_addLiquidityAmount,_miningPoolType);
      //_addArr.push(address(this));
      IterableMiningPool.PledgeInfo storage pledgeInfo= miningPoolInfo.pledgeInfoMap[msg.sender];
      pledgeInfo.amount=_betAmount;
      pledgeInfo.pledgeTime=block.timestamp;
      pledgeInfo.deadLine=block.timestamp.add(_miningPoolType.mul(SECONDS_PER_DAY));
      uint256 _profitFee=_betAmount.div(1000).mul(miningPoolInfo.profitRate);//
      _profitFee=_profitFee.div(360).mul(_miningPoolType);
      miningPoolMap.addPledgeUser(_miningPoolType,address(msg.sender),_betAmount,_profitFee);
      takePartInUserMap.set(address(msg.sender),_betAmount,_profitFee);
      _takeInviterFee(address(msg.sender),_profitFee,_betAmount);
      status=1;
      emit TakePartIn(status,pledgeInfo.deadLine);
      return (status);
    }
    function swapAndLiquify(uint256 contractTokenBalance,uint256 _miningPoolType) private  lockTheSwap{
        
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);
        IERC20 bonusToken = IERC20(bonusTokenAddress);
        uint256 initialBalance = bonusToken.balanceOf(address(_tokenDistributor));
        swapTokensForBaseToken(betTokenAddress,bonusTokenAddress, half,address(_tokenDistributor)); 
        uint256 bonusBalance = bonusToken.balanceOf(address(_tokenDistributor)).sub(initialBalance);
        bonusToken.transferFrom(address(_tokenDistributor), address(this), bonusBalance);

        addLiquidityBaseToken(bonusBalance, otherHalf,_miningPoolType);
    }
    function swapTokensForBaseToken(address token0,address token1,uint256 tokenAmount,address to) private {
        address[] memory path = new address[](2);
        path[0] =token0;// betTokenAddress;
        path[1] =token1;
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount, 0, path, to,block.timestamp);
        
    }
    function addLiquidityBaseToken(uint256 tokenAmount, uint256 ethAmount,uint256 _miningPoolType) private {
        
        IERC20 lpErc20=IERC20(uniswapV2Pair);
        uint256 initialBalance=lpErc20.balanceOf(address(_tokenDistributor));
         uniswapV2Router.addLiquidity(
                    bonusTokenAddress, betTokenAddress, tokenAmount, ethAmount, 0, 0, address(_tokenDistributor), block.timestamp
                );
        uint256 lpBalance=lpErc20.balanceOf(address(_tokenDistributor)).sub(initialBalance);

        IterableMiningPool.MiningPoolInfo storage miningPoolInfo= miningPoolMap.miningPoolInfoMap[_miningPoolType];
        IterableMiningPool.PledgeInfo storage pledgeInfo= miningPoolInfo.pledgeInfoMap[msg.sender];
        pledgeInfo.lpAmount=lpBalance;
    }
    function viewTotalPledgeInfo() public view returns(uint256,uint256){
        return (miningPoolMap.totalAmount,miningPoolMap.totalUser); 
    }
    function viewTotalProfitAmount() public view returns(uint256[] memory){
        return miningPoolMap.getMiningTotalProfitAmount(); 
    }
    //curTotalAmount curTotalUser
    function viewCurTotalPledgeInfo() public view returns(uint256,uint256){
        return miningPoolMap.getCurTotalPledgeInfo(); 
    }
    //all miningPoolType 7、30、90、180、365 amount is 0
    function viewUserAllPledgeInfo(address _account) public view returns(uint256[] memory){
        return miningPoolMap.getUserAllPledgeInfo(_account); 
    }
    //
    function viewSingleUserPledgeInfo(address _account,uint256 _miningPoolType) public view returns(uint256,uint256,uint256,uint256,uint256){
        return miningPoolMap.getSingleUserPledgeInfo(_account,_miningPoolType); 
    }
    //current miningPool totalAmount totalUser curTotalAmount curTotalUser
    function viewMiningPoolPledgeInfo(uint256 _miningPoolType) public view returns(uint256,uint256,uint256,uint256){
        return miningPoolMap.getMiningPoolPledgeInfo(_miningPoolType); 
    }
    function viewMiningPoolInfo(uint256 _miningPoolType) public view returns(uint16,uint16,uint16){
        return miningPoolMap.getMiningPoolInfo(_miningPoolType); 
    }
    function viewSECONDS_PER_DAY() public view returns(uint256){
        return SECONDS_PER_DAY;
    }
    function isInvited(address _account) public view returns(bool){
        bool invited=false;
        address _inviter=inviter[_account] ;
        if(_inviter!=address(0)){
            invited=true;
        }
        return (invited);
    }
   
   
   function viewInviterFee(address _account) public view returns(uint256){
        
        return takePartInUserMap.getInviterEarnings(_account);// 
   }
   function viewInviterCount(address _account) public view returns(uint256,uint256,uint256,uint256,
   uint256,uint256){
        
        return takePartInUserMap.getInviterCount(_account);//
   }
   function viewInvitees(address _account) public view returns(address[] memory){
        return takePartInUserMap.userInfoMap[_account].oneRankInviter;
   }
   function viewInviter(address _account) public view returns(address){
        address _inviter=inviter[_account];
        return _inviter;
   }
   function viewNftAddressAndMinBalance() public view returns(address,uint256,uint256){
        return(nftTokenAddress,minNftAmount,nftInviterFeeRank);
    }
   function withdrawPledge(uint256 _miningPoolType) public lockTheSwap{
        (uint256 amount,uint256 pledgeTime,uint256 deadLine,uint256 profitAmount,uint256 lpAmount)= miningPoolMap.getSingleUserPledgeInfo(address(msg.sender),_miningPoolType);
        if(block.timestamp>=pledgeTime&&block.timestamp>=deadLine&&amount>0&&lpAmount>0){
            IERC20 lpErc20=IERC20(uniswapV2Pair);
            uint256 lpBalance=lpErc20.balanceOf(address(_tokenDistributor));//_tokenDistributor
            require(lpBalance>=lpAmount,"Distributor balance is low");
            IERC20 bonusErc20=IERC20(bonusTokenAddress);
            IERC20 betErc20=IERC20(betTokenAddress);
            uint256 betInitBalance=betErc20.balanceOf(address(this));
            uint256 bonusInitBalance=bonusErc20.balanceOf(address(this));
            
            _tokenDistributor.removeLiquify(lpAmount,betTokenAddress,bonusTokenAddress);
            miningPoolMap.removePledgeUser(_miningPoolType,address(msg.sender));
            //
            uint256 betOtherBalance=betErc20.balanceOf(address(this));
            uint256 bonusOtherBalance=bonusErc20.balanceOf(address(this));
            
            uint256 betRemoveAmount=betOtherBalance.sub(betInitBalance);
            uint256 bonusRemoveAmount=bonusOtherBalance.sub(bonusInitBalance);
            betInitBalance=betErc20.balanceOf(address(_tokenDistributor));
            //sell bonustoken
            swapTokensForBaseToken(bonusTokenAddress,betTokenAddress,bonusRemoveAmount,address(_tokenDistributor));
            // address[] memory path = new address[](2);
            // path[0] = bonusTokenAddress;
            // path[1] = betTokenAddress;// uniswapV2Router.WETH();
            // //_approve(address(this), address(uniswapV2Router), tokenAmount);
            
            // uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            // bonusRemoveAmount, 0, path, address(_tokenDistributor),block.timestamp);
            betOtherBalance=betErc20.balanceOf(address(_tokenDistributor));
            betOtherBalance=betOtherBalance.sub(betInitBalance);
            transferProfit(amount,betOtherBalance,betRemoveAmount,profitAmount);
        }else{

        }
   }
   function transferProfit(uint256 amount,uint256 transferAmount,uint256 betRemoveAmount,uint256 profitAmount)private{
       IERC20 betErc20=IERC20(betTokenAddress);
       betErc20.transferFrom(address(_tokenDistributor), address(this), transferAmount);//sell bonustoken after removeLiquidity
       transferAmount=transferAmount.add(betRemoveAmount.add(profitAmount));
       uint256 totalProfit=amount.add(profitAmount);
        if(transferAmount<totalProfit){
            transferAmount=totalProfit;
        }
        uint256 betContractBalance=betErc20.balanceOf(address(this));
        require(betContractBalance>=transferAmount,"contract balance is low");    
        betErc20.transfer(msg.sender,transferAmount);//);
   }
   //
   function withdrawProfitAndPledge(uint256 _miningPoolType) public lockTheSwap{
        (uint256 amount,uint256 pledgeTime,uint256 deadLine,uint256 profitAmount,uint256 lpAmount)= miningPoolMap.getSingleUserPledgeInfo(address(msg.sender),_miningPoolType);
        if(block.timestamp>=pledgeTime&&block.timestamp>=deadLine&&amount>0&&lpAmount>0){
            IERC20 betErc20=IERC20(betTokenAddress);
            uint256 betBalance=betErc20.balanceOf(address(this));
            require(betBalance>=profitAmount,"betBalance is too low for profitAmount");
            uint256 _deadLine;
            _deadLine=block.timestamp.add(_miningPoolType.mul(SECONDS_PER_DAY));
            miningPoolMap.refreshPledgeUser(_miningPoolType,address(msg.sender),_deadLine);
            betErc20.transfer(msg.sender,profitAmount);
        }else{

        }
   }
  
   function withdrawInviterFee() public{
        IERC20 erc20token = IERC20(betTokenAddress);
        uint256 earningsTotal= takePartInUserMap.getInviterEarnings(msg.sender);
        require(earningsTotal>0,"Inviter Fee is zero!");
        uint256 balance =erc20token.balanceOf(address(this));
        require(balance>=earningsTotal,"balance is too low!"); 
        takePartInUserMap.clearInviterEarnings(msg.sender);
        erc20token.transfer(msg.sender,earningsTotal);
        //_userTakePartInInfo.inviterEarnings=0;
   }
    function _takeInviterFee(
        address sender,
        uint256 _profitFee,
        uint256 tAmount
    ) private {
        address cur = sender;
        //uint256 earningsTotal=0;
        IERC721 nftToken=IERC721(nftTokenAddress);
        for (uint256 i = 0; i < shareRank; i++) {
            uint256 rate;
            rate= shareConfig[i];
            cur = inviter[cur];
            if (cur != address(0)) {
                uint256 nftBalance=nftToken.balanceOf(cur);
                uint256 curRAmount;
                if(nftBalance>minNftAmount){
                    curRAmount = _profitFee.mul(rate).div(1000);
                    takePartInUserMap.addInviterEarnings(cur,curRAmount);
                    takePartInUserMap.addInviterTotalPledge(cur,tAmount);
                }else{
                    if(i<nftInviterFeeRank){
                        curRAmount = _profitFee.mul(rate).div(1000);
                        takePartInUserMap.addInviterEarnings(cur,curRAmount);
                        takePartInUserMap.addInviterTotalPledge(cur,tAmount);
                    }
                }
            }
        }
        //return earningsTotal;
    }
    function setInviter(address _account,address _inviter) public {
        require(_inviter!=address(0),"inviter can not be the zero address");
        inviter[address(msg.sender)] = _inviter;
        takePartInUserMap.addInviterCount(_inviter,address(msg.sender));
        IERC721 nftToken=IERC721(nftTokenAddress);
        address cur = _inviter;
        for (uint256 i = 0; i <(shareRank-1); i++) {
            cur = inviter[cur];
            if (cur != address(0)) {
                uint256 nftBalance=nftToken.balanceOf(cur);
                if(nftBalance>minNftAmount){
                    takePartInUserMap.addAllRankInviterCount(cur);
                }else{
                    if(i<(nftInviterFeeRank-1)){
                      takePartInUserMap.addAllRankInviterCount(cur);  
                    }
                }
            }
        }
    }
   
//    function getSingleSetCount(uint64 _setIndex) public view returns(uint256, address[] memory){
//        IterableSingleSet.Map  storage singleSet= _MapAllSet[_setIndex];
//        return (singleSet.keys.length, singleSet.keys);
//     }
    
    // Whether the user has already take part in the game
    // function getUserIsTakePartIn(uint64 _setIndex,address _userAdd) public view returns(bool){
    //    IterableSingleSet.Map  storage singleSet= _MapAllSet[_setIndex];
    //    return (singleSet.inserted[_userAdd]);
    // }
    

    function withdrawMarketing(uint256 amount,uint256 _type) public{
        require(marketingAddressMap[msg.sender]==true);
        if(_type==0){
            IERC20 erc20token = IERC20(betTokenAddress);
            require(erc20token.balanceOf(address(this))>=amount,"token balance is low");
            erc20token.transfer(msg.sender, amount);
        }else{
            if(_type==1){
                IERC20 bonusErc20 = IERC20(bonusTokenAddress);
                require(bonusErc20.balanceOf(address(this))>=amount,"bonus balance is low");
                bonusErc20.transfer(msg.sender, amount);
            }
        }
    }
    // function withdrawDistributorLP(uint256 _lpAmount) public onlyOwner{ 
    //     return _tokenDistributor.transferLPBalance(_lpAmount); 
    // }
    // function updateBonusTokenAddress(address _token) public onlyOwner{
    //     require(bonusTokenAddress!=_token,"Token is the same!");
    //     bonusTokenAddress=_token;
    // }
    // function updateBetTokenAddress(address _token) public onlyOwner{
    //     require(betTokenAddress!=_token,"Token is the same!");
    //     betTokenAddress=_token;
    // }
    // function updateLpPairAddress(address _token) public onlyOwner{
    //     require(uniswapV2Pair!=_token,"Account is the same!");
    //     uniswapV2Pair=_token;
    // }
    function updateMarketingAddress(address _account) public onlyOwner{
        require(marketingAddressMap[_account]!=true,"Account is true!");
        marketingAddressMap[_account]=true;
    }
    function updateMiningPoolInfo(uint256 _miningPoolType,uint256 _amount,uint16 _profitRate,uint16 _inviterRate,
    uint16 _depositRate) public onlyOwner{
        IERC20 betErc20=IERC20(betTokenAddress);
        _amount=_amount * 10 ** betErc20.decimals();
        miningPoolMap.set(_miningPoolType,_amount,_profitRate,_inviterRate,_depositRate);
    }
    function updateNftAddressAndMinBalance(address _nftTokenAddress,uint256 _minNftBalance,uint256 _nftInviterFeeRank) public onlyOwner{
        require(_nftTokenAddress!=address(0),"nft address is zero");
        nftTokenAddress=_nftTokenAddress;
        minNftAmount=_minNftBalance;
        nftInviterFeeRank=_nftInviterFeeRank;
    }
    function updateSecondsPerDay(uint256 _secondsPerDay) public onlyOwner{
        SECONDS_PER_DAY=_secondsPerDay;
    }
    function updateShareRank(uint256 _shareRank) public onlyOwner{
        require(_shareRank<=10);
        shareRank=_shareRank;
    }
    function getDistributorMsgSender() public view returns(address) { 
        return _tokenDistributor.getMsgSender(); 
    }
    function getDistributorTxOrigin() public view returns(address) { 
        return _tokenDistributor.getTxOrigin(); 
    }
    function getDistributor() public view returns(address) { 
        return _tokenDistributor.getDistributor(); 
    }
    function getLpBalanceDistributor() public view returns(uint256) { 
        IERC20 lpErc20=IERC20(uniswapV2Pair);
        return lpErc20.balanceOf(_tokenDistributor.getDistributor()); 
    }
    
    function claim(address _token) public onlyOwner {
        if (_token == owner) {
            payable(owner).transfer(address(this).balance);
            return;
        }
        IERC20 erc20token = IERC20(_token);
        uint256 balance = erc20token.balanceOf(address(this));
        erc20token.transfer(owner, balance);
    }
    receive() external payable {}
}