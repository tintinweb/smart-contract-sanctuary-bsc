/**
 *Submitted for verification at BscScan.com on 2022-08-02
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

library SafeMath {
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
        require(c >= a, 'SafeMath: addition overflow');

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
        return sub(a, b, 'SafeMath: subtraction overflow');
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
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
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
        return div(a, b, 'SafeMath: division by zero');
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, 'SafeMath: modulo by zero');
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
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
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}


/**
 * @dev Interface of the Energy system as a draft.
 */
interface IEnergy {

    function transferProceed(address account, uint256 amount) external returns (bool);

    /**
     * @dev Returns the total energy produced from the past.
     */
    function totalProduced() external view returns (uint256);

    /**
     * @dev This shadows totalProduced() for compatibility with block explorers.
     */
    function totalSupply() external view returns (uint256);
    /**
     * @dev Returns the energy owned by a `account`
     */
    function balanceOf(address account) external view returns (int256);

    /**
     * @dev Moves `amount` energy from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining amount of energy that an `exchange` will be
     * allowed to transfer on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address exchange) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `exchange` over the caller's energy.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the exchange's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address exchange, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` energy from an `account` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address account, address recipient, uint256 amount) external returns (bool);

    /* 
    * @dev get the grid address
     */
    function gridAddress() external view returns (address);

    /**
     * @dev Emitted when `value` energy are moved from one account (`from`) to
     * another (`to`)
     */
    event Transfer(address indexed from, address indexed to, uint256 value);
    event GreenTransfer(address indexed from, address indexed to, uint256 green);
    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
     /**
     * @dev Emitted when energy is produced by an approved producer
     * to monitor the degree of cleanness and total energy that have been produced by a producer
     */
     event Production(address indexed producer, uint256 amount, uint cleanness);

     /* 
     * @dev Emitted when trade contract address is updated
     */
     event TradeAddress(address indexed previousTradeAddress, address indexed newTradeAddress);
}

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
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
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
        require(address(this).balance >= amount, 'Address: insufficient balance');

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
        return functionCall(target, data, 'Address: low-level call failed');
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
        return _functionCallWithValue(target, data, 0, errorMessage);
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
        return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
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
        require(address(this).balance >= value, 'Address: insufficient balance for call');
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), 'Address: call to non-contract');

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

contract Trader {
    using SafeMath for uint256;
    using Address for address;

    enum OrderSide {
        BUY, // 0
        SELL // 1
    }

    struct Order {
        address meter;
        uint256 energy;
        uint256 price;
        OrderSide side;
    } 

    address[] private _registerdMeters;
    address[] private _localProducers;
    mapping(address => bool) public registerdMeters;
    mapping(address => bool) public localProducers;
 
    address public energyAddress = 0xbf8f1A9D8c0eF338D2789BeeDD0a27Bc8236F56d;
    IEnergy public energySystem = IEnergy(energyAddress);
    uint public energyRate = 3; // per unit of energy
   
    event Trade(address indexed buyer, address indexed seller, uint256 energy, uint256 price);

    function registerMeter(address meter) public {
        registerdMeters[meter] = true;
        _registerdMeters.push(meter);
    }

    function registerProducer(address _pv) public {
        localProducers[_pv] = true;
        _localProducers.push(_pv);
    }

    function setEnergyAddress(address _iEnergy) public {
        energyAddress = _iEnergy;
    }

    function negate256(int256 _i) public pure returns(int256) {
        return -_i;
    }

    function meterLoad(address _meter) public view returns(Order memory order) {
        int256 balance = energySystem.balanceOf(_meter);
        OrderSide side = OrderSide.SELL;

        if (balance < 0) {
            balance = negate256(balance);
            side = OrderSide.BUY;
        }
        uint256 load = uint(balance);
        order.side = side;
        order.meter = _meter;
        order.energy = load;
        order.price = load.mul(energyRate);
    }

    function buyOrders() public view returns(Order[] memory) {
        uint _length = _registerdMeters.length;
        Order[] memory orders = new Order[](_length);

        for (uint i = 0; i < _length; i++) {
            Order memory order = meterLoad(_registerdMeters[i]);
            
            if (order.side == OrderSide.BUY) {
                orders[i] = order;
            }
        }

        return orders;
    }

    function sellOrders() public view returns(Order[] memory) {
        uint _length = _localProducers.length;
        Order[] memory orders = new Order[](_length);

        for (uint i = 0; i < _length; i++) {
            Order memory order = meterLoad(_localProducers[i]);
            
            if (order.side == OrderSide.SELL) {
                orders[i] = order;
            }
        }

        return orders;
    }

    function matchOrder() public {
        // this will be call on a defined interval
        Order[] memory _buyOrders = buyOrders();

        for (uint i = 0; i < _buyOrders.length; i++) {
            Order memory buy = _buyOrders[i];
            executeOrder(buy);
        }
    }

    function executeOrder(Order memory _buy) internal {
        // needs to log event trade event
        // should also deduct the appropriate energy cost
        Order[] memory _sellOrders = sellOrders();
        for (uint i = 0; i < _sellOrders.length; i++) {
            Order memory _sell = _sellOrders[i];

            if (_buy.energy == 0) break;

            if (_sell.energy >= _buy.energy) {
                energySystem.transferFrom(_sell.meter, _buy.meter, _buy.energy);
                energySystem.transferProceed(_sell.meter, _buy.price); // give the proceeding from sale
                emit Trade(_buy.meter, _sell.meter, _buy.energy, _buy.price);
                break; // _buy.energy has been consumed, nothing to do again
            } else {
                energySystem.transferFrom(_sell.meter, _buy.meter, _sell.energy); // _sell.energy is consumed
                energySystem.transferProceed(_sell.meter, _sell.energy.mul(energyRate)); // give the proceeding from sale
                _buy.energy = _buy.energy - _sell.energy;
                emit Trade(_buy.meter, _sell.meter, _sell.energy, _sell.energy.mul(energyRate));
            }
        }

        // if _buy.energy still greater than zero after
        // scanning available sell orders then we can
        // purchase from the grid here
        address _grid = energySystem.gridAddress();
        uint256 _gridBalance = uint(energySystem.balanceOf(_grid));

        if (_buy.energy > 0 && _gridBalance >= _buy.energy) {
            energySystem.transferFrom(_grid, _buy.meter, _buy.energy);
            energySystem.transferProceed(_grid, _buy.energy.mul(energyRate)); // give the proceeding from sale
            emit Trade(_buy.meter, _grid, _buy.energy, _buy.energy.mul(energyRate));
        }
    }
}