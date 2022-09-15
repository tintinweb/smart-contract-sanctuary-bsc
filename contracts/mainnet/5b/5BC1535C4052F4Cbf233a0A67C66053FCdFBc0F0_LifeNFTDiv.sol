/**
 *Submitted for verification at BscScan.com on 2022-09-15
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/ownership/Ownable.sol

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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */
interface IERC20 {
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

    function burn(address account, uint amount) external;

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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


interface INFT {
    function tokensOfOwnerBySize(address owner) view external returns (uint256[] memory tokens);

    function ownerOf2(uint256 tokenId) external view returns (address);
}

interface ILife {
    function getMarketBalance() external view returns (uint256);
}

contract LifeNFTDiv is Ownable {

    address _life = 0x743E81c805716a633474FEdB079Ce9d52162D5A7;
    address _nft = 0x7f8cd4a968D9937cA0EBCDeACbd6899bC0dA0f5C;

    address public _dead = 0x000000000000000000000000000000000000dEaD;
    address public _usdt;
    uint256 public rewardtime = 1663171200;
    uint256 public initreward = 0;
    uint256 public nftcount = 158;

    mapping(uint256 => uint256) public nftAlreadyClaim;
    uint256 public nftMaxSupply = 666;

    constructor () public {
        if (block.chainid == 56) {
            _usdt = 0x55d398326f99059fF775485246999027B3197955;
        } else {
            _usdt = 0x89614e3d77C00710C8D87aD5cdace32fEd6177Bd;
        }
    }

    function claim() external {
        require(block.timestamp > rewardtime, "claim no start");

        (uint256 amount, uint256[] memory tokens) = getUserNftReward(msg.sender);
        IERC20(_usdt).transfer(msg.sender, amount);
        uint256 count = getTotalCount();
        for (uint i; i < tokens.length; i++) {
            nftAlreadyClaim[tokens[i]] += getTokenIdReward(tokens[i], count);
        }
    }

    function getUserNftReward(address owner) public view returns (uint256 reward,uint256[] memory tokens) {
        uint256 count = getTotalCount();
        tokens = INFT(_nft).tokensOfOwnerBySize(owner);
        for (uint i = 0; i < tokens.length; i++) {
            reward += getTokenIdReward(tokens[i], count);
        }
        return (reward, tokens);
    }

    function getTokenIdRewardView(uint256 tokenId) public view returns (uint256) {
        uint256 count = getTotalCount();
        return getTokenIdReward(tokenId, count);
    }

    function getTokenIdReward(uint256 tokenId,uint count) private view returns (uint256) {
        uint256 balance = ILife(_life).getMarketBalance() + initreward;
        uint256 reward = balance / count;
        return reward - nftAlreadyClaim[tokenId];
    }

    function getTotalCount() public view returns (uint256) {
        return nftcount;
    }

    function setNftcount(uint256 _nftcount) onlyOwner external {
        nftcount = _nftcount;
    }

    function setRewardtime(uint256 _rewardtime) onlyOwner external {
        rewardtime = _rewardtime;
    }

    function setInitreward(uint256 _initreward) onlyOwner external {
        initreward = _initreward;
    }

    function setLife(address life) onlyOwner external {
        _life = life;
    }

    function setNft(address nft) onlyOwner external {
        _nft = nft;
    }

    function setNftMaxSupply(uint256 _nftMaxSupply) onlyOwner external {
        nftMaxSupply = _nftMaxSupply;
    }

    function claimToken(address _token, address recipient, uint amount) onlyOwner external {
        IERC20(_token).transfer(recipient, amount);
    }
}