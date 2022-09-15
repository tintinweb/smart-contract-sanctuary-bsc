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
    function getTokens(address owner) view external returns (uint256[] memory tokens, uint256[] memory levels, uint256[] memory createT);

    function level(uint tokenId) view external returns (uint);
}

interface IMining {
    function nftTotalFeeAmount() view external returns (uint256);
}

contract WccMiningNFTDivident is Ownable {

    address public _wcc = 0xFe2B80bdF45bAB068616F0d38C300B4762BC1819;
    address public _nft = 0x7f8cd4a968D9937cA0EBCDeACbd6899bC0dA0f5C;
    address public _mining = 0x9E0D34ED610eeB475308bAb902f2C123AD32D7AD;

    mapping(uint256 => uint256) public nftAlreadyClaim;
    uint256 public nftMaxSupply = 666;
    uint256 public rewardtime = 1663171200;
    uint256 public initreward = 10000000000000000000;
    uint256 public _lev1 = 81;
    uint256 public _lev2 = 2;

    function claim() external {
        require(block.timestamp > rewardtime, "claim no start");

        (uint256 amount, uint256[] memory tokens, uint256[] memory levels) = getUserNftReward(msg.sender);
        IERC20(_wcc).transfer(msg.sender, amount);
        (uint lev1len,uint lev2len) = getLevelCount();
        for (uint i; i < tokens.length; i++) {
            nftAlreadyClaim[tokens[i]] += getTokenIdReward(tokens[i], levels[i],lev1len,lev2len);
        }
    }

    //nft
    function getUserNftReward(address owner) public view returns (uint256 reward,uint256[] memory tokens,uint256[] memory levels) {
        uint256[] memory createT;
        (uint lev1len,uint lev2len) = getLevelCount();
        (tokens, levels,createT) = INFT(_nft).getTokens(owner);
        for (uint i = 0; i < tokens.length; i++) {
            reward += getTokenIdReward(tokens[i], levels[i],lev1len,lev2len);
        }
        return (reward, tokens, levels);
    }

    function getTokenIdRewardView(uint256 tokenId) public view returns (uint256) {
        uint level = INFT(_nft).level(tokenId);
        (uint lev1len,uint lev2len) = getLevelCount();
        return getTokenIdReward(tokenId,level,lev1len,lev2len);
    }

    function getTokenIdReward(uint256 tokenId, uint256 level,uint lev1len,uint lev2len) private view returns (uint256) {
        uint256 balance = IMining(_mining).nftTotalFeeAmount() + initreward;
        uint256 reward;
        if (level == 1) {
            reward = (balance * 38 / lev1len) / 100;
        } else if (level == 2) {
            reward = (balance * 62 / lev2len) / 100;
        }
        return reward - nftAlreadyClaim[tokenId];
    }

    function getLevelCount() public view returns (uint lev1, uint lev2) {
        return (_lev1, _lev2);
    }

    function setRewardtime(uint256 _rewardtime) onlyOwner external {
        rewardtime = _rewardtime;
    }

    function setInitreward(uint256 _initreward) onlyOwner external {
        initreward = _initreward;
    }

    function setMining(address mining) onlyOwner external {
        _mining = mining;
    }

    function setNft(address nft) onlyOwner external {
        _nft = nft;
    }

    function setWcc(address wcc) onlyOwner external {
        _wcc = wcc;
    }

    function setLev1(uint256 lev1) onlyOwner external {
        _lev1 = lev1;
    }

    function setLev2(uint256 lev2) onlyOwner external {
        _lev2 = lev2;
    }

    function setNftMaxSupply(uint256 _nftMaxSupply) onlyOwner external {
        nftMaxSupply = _nftMaxSupply;
    }

    function claimToken(address _token, address recipient, uint amount) onlyOwner external {
        IERC20(_token).transfer(recipient, amount);
    }
}