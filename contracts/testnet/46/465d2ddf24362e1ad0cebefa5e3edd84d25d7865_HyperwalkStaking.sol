/**
 *Submitted for verification at BscScan.com on 2022-06-13
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
    event Staked (
        address owner,
        address token,
        uint tokenId
    );

    event Unstaked (
        address owner,
        address token,
        uint tokenId
    );

    uint public totalNftStakings = 0;
    mapping(address => uint) public userTotalNftStakings;
    mapping(address => bool) nftApproveList;
    mapping(address => mapping(uint => address)) stakingOwners;

    function stakeToken(address token, uint tokenId) external {
        require(nftApproveList[token] == true);
        IERC721(token).transferFrom(msg.sender, address(this), tokenId);

        totalNftStakings++;
        userTotalNftStakings[msg.sender]++;
        stakingOwners[token][tokenId] = msg.sender;

        emit Staked(
            msg.sender,
            token,
            tokenId
        );
    }

    function getStakingOwner(address token, uint tokenId) public view returns (address) {
        return stakingOwners[token][tokenId];
    }

    function unstakedToken(address token, uint tokenId) public {
        address nftOwner = stakingOwners[token][tokenId];
        require(nftOwner != address(0), "NFT not found");
        require(msg.sender == stakingOwners[token][tokenId], "Only owner can unstaking");
    
        IERC721(token).transferFrom(address(this), nftOwner, tokenId);

        totalNftStakings--;
        userTotalNftStakings[msg.sender]--;
        stakingOwners[token][tokenId] = address(0);

        emit Unstaked(stakingOwners[token][tokenId], token, tokenId);
    }

    function emergencyWithdrawToken(address token, uint tokenId) public onlyOwner {
        address nftOwner = stakingOwners[token][tokenId];
        require(nftOwner != address(0), "NFT not found");
    
        IERC721(token).transferFrom(address(this), nftOwner, tokenId);

        totalNftStakings--;
        userTotalNftStakings[msg.sender]--;
        stakingOwners[token][tokenId] = address(0);

        emit Unstaked(stakingOwners[token][tokenId], token, tokenId);
    }

    function setNFTApproval(address token ,bool approve) public onlyOwner {
        nftApproveList[token] = approve;
    }
}