/**
 *Submitted for verification at BscScan.com on 2022-06-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-09
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-27
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IERC721 {
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
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

interface Token {
    function totalSupply() external view returns (uint256 supply);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function transfer(address _to, uint256 _value)
        external
        returns (bool success);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);

    function approve(address _spender, uint256 _value)
        external
        returns (bool success);

    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256 remaining);
}

contract HyperwalkStaking is Ownable {
    enum StakingStatus {
        Staked,
        Unstaked
    }

    struct Staking {
        StakingStatus status;
        address owner;
        address token;
        uint tokenId;
    }

    event Staked (
        uint stakingId,
        address owner,
        address token,
        uint tokenId
    );

    event Unstaked (
        uint stakingId,
        address owner,
        address token,
        uint tokenId
    );

    uint private _stakingId = 0;
    mapping(uint => Staking) private _stakings;
    mapping(address => bool) nftApproveList;

    function stakeToken(address token, uint tokenId) external {
        require(nftApproveList[token] == true);
        IERC721(token).transferFrom(msg.sender, address(this), tokenId);

        Staking memory staking = Staking(
            StakingStatus.Staked,
            msg.sender,
            token,
            tokenId
        );

        _stakingId++;

        _stakings[_stakingId] = staking;

        emit Staked(
            _stakingId,
            msg.sender,
            token,
            tokenId
        );
    }

    function getStaking(uint stakingId) public view returns (Staking memory) {
        return _stakings[stakingId];
    }

    function unstakedToken(uint stakingId) public {
        Staking storage staking = _stakings[stakingId];

        require(msg.sender == staking.owner, "Only owner can unstaking");
        require(staking.status == StakingStatus.Staked, "Staking is not active");

        staking.status = StakingStatus.Unstaked;
    
        IERC721(staking.token).transferFrom(address(this), msg.sender, staking.tokenId);

        emit Unstaked(stakingId, staking.owner, staking.token, staking.tokenId);
    }

    function setNFTApproval(address token ,bool approve) public onlyOwner {
        nftApproveList[token] = approve;
    }
}