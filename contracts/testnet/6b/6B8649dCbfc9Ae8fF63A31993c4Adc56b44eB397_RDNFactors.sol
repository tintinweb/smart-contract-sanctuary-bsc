pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IRDNRegistry.sol";
import "./IRDNFactors.sol";

contract RDNFactors is IRDNFactors {

    IRDNRegistry public registry;

    uint public decimals = 4;

    uint[7][12] public factors = [
        [1500, 1956, 2413, 2869, 3326, 3782, 4239 ],
        [4239, 4467, 4695, 4924, 5152, 5380, 5608 ],
        [5608, 5760, 5913, 6065, 6217, 6369, 6521 ],
        [6521, 6635, 6750, 6864, 6978, 7092, 7206 ],
        [7206, 7297, 7389, 7480, 7571, 7663, 7754 ],
        [7754, 7830, 7906, 7982, 8058, 8134, 8210 ],
        [8210, 8276, 8341, 8406, 8471, 8536, 8602 ],
        [8602, 8659, 8716, 8773, 8830, 8887, 8944 ],
        [8944, 8995, 9045, 9096, 9147, 9198, 9248 ],
        [9248, 9294, 9340, 9385, 9431, 9477, 9522 ],
        [9522, 9564, 9605, 9647, 9688, 9730, 9771 ],
        [9771, 9809, 9847, 9885, 9923, 9961, 10000 ]
    ];

    constructor (address _registry) {
        registry = IRDNRegistry(_registry);
    }
    
    function getFactor(uint _level, uint _tariff, uint _userId) public view returns(uint) {
        _level = (_level >= 12)?11:(_level-1);
        _tariff = (_tariff >= 7)?6:(_tariff-1);
        return factors[_level][_tariff];
    }

    function calc(uint _level, uint _tariff, uint _userId) public pure returns(uint) {
        uint tariffsCount = 7;
        uint maxFactor = 1 ether;

        // return _level*(maxFactor/12)/(10**14);

        uint min = (_level >= 12 && _tariff >= 7)?maxFactor:(maxFactor - calcStep(_level, 12));
        uint max = (_level >= 12 && _tariff >= 7)?maxFactor:(maxFactor - calcStep(_level+1, 12));
        uint tariffStep = (max - min)/(tariffsCount-1);
        uint factor = min + tariffStep * (_tariff - 1);
        return factor/(10**14);
    }

    function test(uint x) public pure returns(uint) {
        return x*2;
    }

    function calcStep(uint _level, uint _levelMax) pure private returns(uint) {
        uint base = 0.2739 ether;
        if (_level > _levelMax) {
            return 0;
        } else {
            return (base/_levelMax + calcStep(_level, _levelMax-1));
        }
    }

    function getDecimals() public view returns(uint) {
        return decimals;
    }

    // uint[14] public factors = [
    //     0, 
    //     15, 
    //     30, 
    //     42, 
    //     52, 
    //     59, 
    //     65, 
    //     71, 
    //     76, 
    //     81, 
    //     86, 
    //     90, 
    //     94,
    //     97
    // ];

    // uint[13] public tokens = [
    //     0, 
    //     7200000000000000000, 
    //     12480000000000000000, 
    //     23040000000000000000, 
    //     26880000000000000000,
    //     46080000000000000000,
    //     92160000000000000000,
    //     153600000000000000000,
    //     307200000000000000000,
    //     614400000000000000000,
    //     983040000000000000000,
    //     1966080000000000000000,
    //     2949120000000000000000
    // ];



    // function calc(uint8 _level, uint8 _tariff, uint _userId) public view returns(uint) {
    //     if (_level == 0) return 0;
    //     if (_level > 12) return factors[13];
    //     if (depositary.getLockedAmount(_userId) >= tokens[_level]) return factors[_level+1];
    //     return factors[_level];
    // }
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

pragma solidity ^0.8.0;

interface IRDNRegistry {
    
    struct User {
        uint level;
        address userAddress;
        uint parentId;
        uint tariff;
        uint activeUntill;
    }

    function getUser(uint) external view returns(User memory);

    function getUserIdByAddress(address _userAddress) external view returns(uint);

    function usersCount() external view returns(uint);

    function isRegistered(uint _userId) external view returns(bool);
    
    function isRegisteredByAddress(address _userAddress) external view returns(bool);

    function factorsAddress() external view returns(address);

    function getParentId(uint _userId) external view returns(uint);

    function getLevel(uint _userId) external view returns(uint);

    function getUserAddress(uint _userId) external view returns(address);

    function getDistributor(address _token) external view returns(address);

    function setTariff(uint _userId, uint _tariff) external;
    
    function setActiveUntill(uint _userId, uint _activeUntill) external;

    // all public variables

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IRDNFactors {

    function getFactor(uint _level, uint _tariff, uint _userId) external view returns(uint);

    function calc(uint _level, uint _tariff, uint _userId) external pure returns(uint);

    function getDecimals() external view returns(uint);
}