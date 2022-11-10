// SPDX-License-Identifier: MIT

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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
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

pragma solidity 0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract DepositPackageMAT is Ownable, ReentrancyGuard {
    struct Package {
        uint256 id;
        uint256 amount;
    }
    mapping(uint256 => Package) packages;
    uint256[] public packageIds;

    IERC20 private MATToken;

    uint256 public price; // 6 decimal

    mapping(address => bool) public whitelist;
    address vaultWallet;

    enum Stage {
        Unpause,
        Pause
    }

    Stage public stage;
    bool public isPublic;

    event Buy(
        address from,
        uint256 packageId,
        uint256 amount,
        uint256 matAmount,
        uint256 time
    );

    event CreatePackage(uint256 id, uint256 amount, uint256 time);
    event DeletePackage(uint256 id, uint256 time);

    constructor(
        IERC20 _MATToken,
        uint256 _price,
        address _vaultWallet
    ) {
        require(address(_MATToken) != address(0), "Error: address(0)");
        require(_vaultWallet != address(0), "Error: address(0)");

        MATToken = _MATToken;
        price = _price;
        vaultWallet = _vaultWallet;
        isPublic = true;
        stage = Stage.Unpause;
        whitelist[_msgSender()] = true;
    }

    modifier requireOpen() {
        require(stage == Stage.Unpause, "Stage close");
        require(
            isPublic || whitelist[msg.sender],
            "Public sale still not open"
        );

        _;
    }

    modifier onlyWhilelist() {
        require(whitelist[_msgSender()], "Only whilelist");
        _;
    }

    function setMat(IERC20 _MATToken) external onlyOwner {
        require(address(_MATToken) != address(0), "Error: address(0)");
        MATToken = _MATToken;
    }

    function setVault(address _vaultWallet) external onlyOwner {
        require(_vaultWallet != address(0), "Error: address(0)");
        vaultWallet = _vaultWallet;
    }

    function setWhiteLists(
        address[] memory _whitelists,
        bool[] memory _isWhileLists
    ) public onlyOwner {
        require(
            _whitelists.length == _isWhileLists.length,
            "Error: input invalid"
        );
        for (uint8 i = 0; i < _whitelists.length; i++)
            whitelist[_whitelists[i]] = _isWhileLists[i];
    }

    function setStage(Stage _stage) public onlyOwner {
        stage = _stage;
    }

    function setPublic(bool _isPublic) public onlyOwner {
        isPublic = _isPublic;
    }

    function withdrawnBNB() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function withdrawnToken(address token, uint256 amount) external onlyOwner {
        require(
            IERC20(token).balanceOf(address(this)) >= amount,
            "Token insufficient"
        );

        require(
            IERC20(token).approve(owner(), amount),
            "Token approve failed!"
        );

        require(IERC20(token).transfer(owner(), amount), "Token transfer fail");
    }

    function setPrice(uint256 _price) external onlyWhilelist {
        price = _price;
    }

    function setPackage(uint256[] calldata _ids, uint256[] calldata _amounts)
        external
        onlyWhilelist
    {
        require(_ids.length == _amounts.length, "invalid input");
        // require(_ids.length == _names.length, "invalid input");
        // require(_ids.length == _actives.length, "invalid input");
        for (uint256 i = 0; i < _ids.length; i++) {
            packages[_ids[i]] = Package(
                _ids[i],
                _amounts[i]
                // _names[i]
                // _actives[i]
            );
            packageIds.push(_ids[i]);
            emit CreatePackage(
                _ids[i],
                _amounts[i],
                // _names[i],
                block.timestamp
            );
        }
    }

    function deletePackage(uint256 _id) external onlyWhilelist {
        delete packages[_id];
        for (uint256 i = 0; i < packageIds.length; i++) {
            if (packageIds[i] == _id) {
                delete packageIds[i];
            }
        }
        emit DeletePackage(_id, block.timestamp);
    }

    function listPackage()
        public
        view
        returns (
            uint256[] memory,
            uint256[] memory,
            uint256[] memory
        )
    {
        uint256[] memory ids = new uint256[](packageIds.length);
        uint256[] memory amounts = new uint256[](packageIds.length);
        uint256[] memory matAmounts = new uint256[](packageIds.length);
        for (uint256 i = 0; i < packageIds.length; i++) {
            ids[i] = packages[packageIds[i]].id;
            amounts[i] = packages[packageIds[i]].amount;
            matAmounts[i] = (packages[packageIds[i]].amount * 1000000) / price;
        }
        return (ids, amounts, matAmounts);
    }

    function buy(uint256 _id) external requireOpen nonReentrant {
        //require(packages[_id].active, "Package not valid");
        uint256 outputMAT = (packages[_id].amount * 1000000) / price;

        require(
            MATToken.transferFrom(_msgSender(), vaultWallet, outputMAT),
            "MAT transfer fail"
        );
        emit Buy(
            _msgSender(),
            _id,
            packages[_id].amount,
            outputMAT,
            block.timestamp
        );
    }
}