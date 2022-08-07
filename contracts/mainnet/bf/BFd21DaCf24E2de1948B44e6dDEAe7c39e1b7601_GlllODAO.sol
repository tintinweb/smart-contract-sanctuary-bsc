/**
 *Submitted for verification at BscScan.com on 2022-08-07
*/

pragma solidity 0.7.0; 

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /** 
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

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

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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

interface IERC{
    function balanceOf(address owner) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function userAllTokens(address account) external view returns(uint256[] memory);
    function itemProperties(uint tokenId) external view returns(uint[] memory);
}

contract GlllODAO is Ownable {
    
    using SafeMath for uint256;
    address immutable auer = msg.sender;
    mapping (address => Voter) voters;
    Proposal[] proposals;
    address public nftAddress = 0x07BB7574e2C1DA332bbf28B6E9cCCF3FF0d13A53;
    address public tokenAddress = 0x2E9F45c7b64CB54e6786110A088F8A614ab9170F;
    event AddProposal(uint pid);
    
    struct Voter {
        uint[] pids;
        uint[] usedCounts;
        uint[] depositCounts;
    }
    
    struct Proposal {
        bytes32[] proposalNames;
        uint[] proposalCounts; 
        uint lockTime;
        uint voteTime;
        uint releaseTime;
    }

    uint pCount = 50;
    uint mCount = 100*10**18;
    uint vTime = 604800;//7 day
    uint rTime = 691200;//8 day

    constructor(){
        
    }

    function init(uint p,uint m,uint v,uint r) public onlyOwner{
        pCount = p;
        mCount = m;
        vTime = v;
        rTime = r;
    }

    function getMedal() private view returns(uint256){
        uint256 count = 0;
        uint256[] memory tokenIds = IERC(nftAddress).userAllTokens(msg.sender);
        for(uint i=0;i<tokenIds.length;i++){
            uint[] memory props = IERC(nftAddress).itemProperties(tokenIds[i]);
            if(props[4] > 0){
                count = count.add(1);
            }
        }
        return count;
    }
    
    function getNoMedal() private view returns(uint256){
        uint256 count = 0;
        uint256[] memory tokenIds = IERC(nftAddress).userAllTokens(msg.sender);
        for(uint i=0;i<tokenIds.length;i++){
            uint[] memory props = IERC(nftAddress).itemProperties(tokenIds[i]);
            if(props[4] == 0){
                count = count.add(1);
            }
        }
        return count;
    }

    function balanceOfToken(address owner) public view virtual returns(uint256){
        return IERC(tokenAddress).balanceOf(owner);
    }
    
    function balanceOfNFT(address owner) public view virtual returns(uint256){
        return IERC(nftAddress).balanceOf(owner);
    }

    function checkProposal() public view virtual returns(bool){
        if(getMedal() > 0 || getNoMedal() >= pCount){
            return true;
        }else{
            return false;
        }
    }

    function checkVote(uint pid,uint amount) public view virtual returns(bool){
        uint depositCounts = 0;
        uint usedCounts = 0;
        for(uint i=0;i<voters[msg.sender].pids.length;i++){
            if(voters[msg.sender].pids[i] == pid){
                usedCounts = voters[msg.sender].usedCounts[i];
                depositCounts = voters[msg.sender].depositCounts[i];
            }
        }
        if(depositCounts >= usedCounts + amount){
            return true;
        }else{
            return false;
        }
    }

    function addProposal(bytes32[] memory pNames) public {
        require(getMedal() > 0 || getNoMedal() >= pCount, "no nft");
        uint _lock = block.timestamp;
        uint _vote = _lock + vTime;
        uint release = _vote + rTime;
        uint[] memory counts = new uint[](pNames.length);
        for(uint i=0;i<pNames.length;i++){
            counts[i] = 0;
        }
        proposals.push(Proposal({
            proposalNames:pNames,
            proposalCounts:counts,
            lockTime:_lock,
            voteTime:_vote,
            releaseTime:release
        }));
        deposits(proposals.length,mCount);
        votes(proposals.length,pNames[0],mCount);
        emit AddProposal(proposals.length);
    }

    function vote(uint pid,bytes32 pName,uint amount) public {
        deposits(pid,amount);
        votes(pid,pName,amount);
    }

    function votes(uint pid,bytes32 pName,uint amount) private {
        require(IERC(nftAddress).balanceOf(msg.sender) > 0, "no nft");
        require(pid > 0 && pid <= proposals.length,"pid error");
        require(block.timestamp >= proposals[pid-1].lockTime,"lockTime end");
        require(block.timestamp <= proposals[pid-1].voteTime,"voteTime end");
        require(amount > 0, "amount err");
        uint usedCounts = 0;
        uint depositCounts = 0;
        for(uint i=0;i<voters[msg.sender].pids.length;i++){
            if(voters[msg.sender].pids[i] == pid){
                usedCounts = voters[msg.sender].usedCounts[i];
                depositCounts = voters[msg.sender].depositCounts[i];
            }
        }
        require(depositCounts >= usedCounts + amount,"depositCounts error");
        for(uint i=0;i<voters[msg.sender].pids.length;i++){
            if(voters[msg.sender].pids[i] == pid){
                voters[msg.sender].usedCounts[i] = voters[msg.sender].usedCounts[i].add(amount);
            }
        }
        bool f = false;
        for(uint i=0;i<proposals[pid-1].proposalNames.length;i++){
            if(proposals[pid-1].proposalNames[i] == pName){
                proposals[pid-1].proposalCounts[i] = proposals[pid-1].proposalCounts[i].add(amount);
                f = true;
            }
        }
        require(f,"proposalName err");
    }

    function deposits(uint pid,uint256 amount) private {
        require(pid > 0 && pid <= proposals.length,"pid err");
        require(block.timestamp >= proposals[pid-1].lockTime,"lockTime end");
        require(block.timestamp <= proposals[pid-1].voteTime,"voteTime end");
        require(amount > 0, "amount err");
        require(IERC(tokenAddress).allowance(msg.sender,address(this)) >= amount,"approve err");
        if(voters[msg.sender].pids.length > 0){
        }else{
            uint[] memory pids; 
            uint[] memory usedCounts; 
            uint[] memory depositCounts; 
            voters[msg.sender] = Voter(pids,usedCounts,depositCounts);
        }
        bool f = false;
        for(uint i=0;i<voters[msg.sender].pids.length;i++){
            if(voters[msg.sender].pids[i] == pid){
                require(voters[msg.sender].depositCounts[i].add(amount) <= mCount,"more than err");
                voters[msg.sender].depositCounts[i] = voters[msg.sender].depositCounts[i].add(amount);
                f = true;
            }
        }
        if(!f){
            voters[msg.sender].pids.push(pid);
            voters[msg.sender].usedCounts.push(0);
            voters[msg.sender].depositCounts.push(amount);
        }
        IERC(tokenAddress).transferFrom(msg.sender,address(this), amount);
    }

    function withdraw(uint pid,uint256 amount) public {
        require(pid > 0 && pid <= proposals.length,"pid err");
        require(block.timestamp >= proposals[pid-1].releaseTime,"releaseTime end");
        require(amount > 0, "amount err");
        uint depositCounts = 0;
        uint usedCounts = 0;
        for(uint i=0;i<voters[msg.sender].pids.length;i++){
            if(voters[msg.sender].pids[i] == pid){
                usedCounts = voters[msg.sender].usedCounts[i];
                depositCounts = voters[msg.sender].depositCounts[i];
            }
        }
        require(depositCounts >= amount, "depositCounts err");
        for(uint i=0;i<voters[msg.sender].pids.length;i++){
            if(voters[msg.sender].pids[i] == pid){
                voters[msg.sender].depositCounts[i] = voters[msg.sender].depositCounts[i].sub(amount);
            }
        }
        IERC(tokenAddress).transfer(msg.sender,amount);
    }

    function getProposalCount(uint pid,bytes32 pName) public view virtual returns(uint){
        for(uint i=0;i<proposals[pid-1].proposalNames.length;i++){
            if(proposals[pid-1].proposalNames[i] == pName){
                return proposals[pid-1].proposalCounts[i];
            }
        }
        return 0;
    }

    function getProposalCounts(uint pid) public view virtual returns(uint[] memory){
        return proposals[pid-1].proposalCounts;
    }

    function getProposalNames(uint pid) public view virtual returns(bytes32[] memory){
        return proposals[pid-1].proposalNames;
    }

    function getLockTime(uint pid) public view virtual returns(uint){
        return proposals[pid-1].lockTime;
    }

    function getVoteTime(uint pid) public view virtual returns(uint){
        return proposals[pid-1].voteTime;
    }

    function getReleaseTime(uint pid) public view virtual returns(uint){
        return proposals[pid-1].releaseTime;
    }

    function getPids(address voter) public view virtual returns(uint[] memory){
        return voters[voter].pids;
    }

    function getUsedCounts(address voter) public view virtual returns(uint[] memory){
        return voters[voter].usedCounts;
    }

    function getDepositCounts(address voter) public view virtual returns(uint[] memory){
        return voters[voter].depositCounts;
    }

    function getBlockTime() public view virtual returns (uint256){
        return block.timestamp;
    }

}