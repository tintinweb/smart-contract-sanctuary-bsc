// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

interface SetDataInterface {
    function totalStake() external view returns (uint256);

    function totalUnstake() external view returns (uint256);
}

contract VyncPoolInfo is Ownable {
    SetDataInterface data;
    address public VyncPool;

    uint256 s; // total staking
    uint256 u; // total unstaking
    uint256 b; // available Staking
    uint256 pl = 100000; // yearly interst;
    bool r_ed = true; // r enable disable
    uint256 r; // extra apr basesd on yearly interst
    uint256 apr = 1 * 1e18; //daily apr
    uint256 a; // total apr: r+apr;
    uint256 compoundRate = 300; // compound rate in seconds
    uint256 up = 50; // unstake percentage

    function poolInfo()
        external
        view
        returns (
            uint256 _s,
            uint256 _u,
            uint256 _b,
            uint256 _pl,
            bool _r_ed,
            uint256 _r,
            uint256 _apr,
            uint256 _a,
            uint256 _compoundRate,
            uint256 _up
        )
    {
        (_s, , ) = set_sub();
        (, _u, ) = set_sub();
        (, , _b) = set_sub();
        _pl = pl;
        _r_ed = r_ed;
        _r = set_r();
        _apr = apr;
        _a = set_a();
        _compoundRate = compoundRate;
        _up = up;
    }

    function returnData()
        external
        view
        returns (
            uint256 _a,
            uint256 _compoundRate,
            uint256 _up
        )
    {
        _a = set_a();
        _compoundRate = compoundRate;
        _up = up;
    }

    function set_VyncPool(address _VyncPool) public onlyOwner {
        VyncPool = _VyncPool;
        data = SetDataInterface(_VyncPool);
    }

    // set staking,unstaking, available staking
    function set_sub()
        private
        view
        returns (
            uint256 _s,
            uint256 _u,
            uint256 _b
        )
    {
        _s = data.totalStake();
        _u = data.totalUnstake();
        _b = _s - _u;
    }

    //set pl
    function set_pl(uint256 _pl) public onlyOwner {
        pl = _pl;
    }

    //set r_ed
    function set_r_ed(bool _r_ed) public onlyOwner {
        r_ed = _r_ed;
    }

    //set r
    function set_r() private view returns (uint256 _r) {
        uint256 _b = data.totalStake() - data.totalUnstake();
        if (r_ed == true) {
            uint256 _pl = pl;
            _r = _b / _pl;
        }
        if (r_ed == false) {
            _r = 0;
        }
    }

    //set apr
    function set_apr(uint256 _apr) public onlyOwner {
        apr = _apr;
    }

    //set a
    function set_a() private view returns (uint256 _a) {
        uint256 _r = set_r();
        _a = apr + _r;
    }

    //set compound rate
    function setCompoundRate(uint256 _compoundRate) public onlyOwner {
        compoundRate = _compoundRate;
    }

    //set up
    function set_up(uint256 _up) public onlyOwner {
        require(
            _up >= 0 && _up <= 100,
            "invalid percentage, input between 0 to 100"
        );
        up = _up;
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