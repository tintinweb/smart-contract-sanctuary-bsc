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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./interfaces/IBabyDogeRouter.sol";
import "./interfaces/IBabyDogeFactory.sol";
import "./interfaces/IBabyDogePair.sol";
import "./interfaces/IWETH.sol";
import "./SafeOwnable.sol";

/*
 * @title Provides buy BabyDoge Token discount for BabyDoge burning
 * Leftover income tokens are collected on the contract
 */
contract BurnPortal is SafeOwnable {
    using EnumerableSet for EnumerableSet.AddressSet;

    struct Discount {
        // Discount amount in basis points, where 10_000 is 100% discount, which means purchase without fees
        uint16 discount;
        // Amount of BabyDoge tokens to burn to reach this discount
        uint112 burnAmount;
    }

    IBabyDogeRouter public immutable router;
    IWETH private immutable WETH;
    IERC20 public immutable bbdToken;
    address private constant DEAD_WALLET = 0x000000000000000000000000000000000000dEaD;

    bool public freePurchaseForEveryone = false;
    uint8 public babyDogeTokenTax = 10; //  10% BabyDoge tax
    uint256 public totalBurned = 0;

    Discount[] public discounts;
    mapping(address => uint256) public burnedAmount;
    EnumerableSet.AddressSet private approvedTokens; // Set of token addresses, approved to be TokenIn

    event BabyDogePurchase(
        address account,
        uint256 babyDogeAmount,
        address tokenIn
    );
    event NewDiscounts(Discount[]);
    event NewBabyDogeTokenTax(uint256);
    event FreePurchaseForEveryoneEnabled();
    event FreePurchaseForEveryoneDisabled();
    event TokenInApproved(address);
    event TokenInRemoved(address);
    event BabyDogeBurn(address account, uint256 amount);
    event TokensWithdrawal(address token, address account, uint256 amount);
    event BnbWithdrawal(address account, uint256 amount);

    error InvalidDiscount(uint256);


    /*
     * @param _router BabyDoge router address
     * @param _bbdToken BabyDoge token address
     * @param _discounts Array of Discount structs, containing discount amount and burn amount to receive that discount
     */
    constructor(
        IBabyDogeRouter _router,
        IERC20 _bbdToken,
        Discount[] memory _discounts
    ){
        require(address(_bbdToken) != address(0));
        router = _router;
        WETH = IWETH(_router.WETH());
        _bbdToken.approve(address(_router), type(uint256).max);

        bbdToken = _bbdToken;

        _checkDiscounts(_discounts);
        for(uint i = 0; i < _discounts.length; i++) {
            discounts.push(_discounts[i]);
        }
    }


    /*
     * @notice Swaps BNB for BabyDoge token and sends them to msg.sender
     * @param amountOutMin Minimum amount of BabyDoge tokens to receive
     * @param path Swap path
     * @param deadline Deadline of swap transaction
     * @return amountOut Amount of BabyDoge tokens user has received
     */
    function buyBabyDogeWithBNB(
        uint256 amountOutMin,
        address[] calldata path,
        uint256 deadline
    ) external payable returns(uint256 amountOut){
        require(path[0] == address(WETH) && path.length == 2, "Invalid path");
        require(msg.value > 0, "0 amountIn");

        uint256 personalDiscount = getPersonalDiscount(msg.sender);
        require(personalDiscount > 0, "No discount");
        // calculating personal tax. `babyDogeTokenTax`% with 0% discount, 0% with 100% discount
        uint256 personalTax = babyDogeTokenTax * (10_000 - personalDiscount) / 10_000;
        uint256 amountIn = msg.value * (100 - personalTax) / 100;

        WETH.deposit{value : amountIn}();

        amountOut = _buyBabyDogeWithERC20(
            amountIn,
            amountOutMin,
            path,
            deadline
        );
    }


    /*
     * @notice Swaps ERC20 for BabyDoge token and sends them to msg.sender
     * @param amountIn Amount tokens to spend
     * @param amountOutMin Minimum amount of BabyDoge tokens to receive
     * @param path Swap path
     * @param deadline Deadline of swap transaction
     * @return amountOut Amount of BabyDoge tokens user has received
     */
    function buyBabyDogeWithERC20(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        uint256 deadline
    ) external returns(uint256 amountOut){
        // allow only WBNB -> BBD or Stable -> BBD or Stable -> WBNB -> BBD swaps
        require(
            (path.length == 2 && (path[0] == address(WETH) || approvedTokens.contains(path[0])))
            ||
            (path.length == 3 && path[1] == address(WETH) && approvedTokens.contains(path[0])),
            "Forbidden swap path"
        );

        IERC20(path[0]).transferFrom(msg.sender, address(this), amountIn);

        uint256 personalDiscount = getPersonalDiscount(msg.sender);
        require(personalDiscount > 0, "No discount");
        // calculating personal tax. `babyDogeTokenTax`% with 0% discount, 0% with 100% discount
        uint256 taxAmount = amountIn * babyDogeTokenTax / 100 * (10_000 - personalDiscount) / 10_000;
        uint256 amountInWithTax = amountIn  - taxAmount;

        amountOut = _buyBabyDogeWithERC20(
            amountInWithTax,
            amountOutMin,
            path,
            deadline
        );
    }


    /*
     * @notice Burns BabyDoge tokens by sending them to dead wallet
     * @param amount Amount of BabyDoge tokens to burn
     */
    function burnBabyDoge(uint256 amount) external {
        bbdToken.transferFrom(msg.sender, DEAD_WALLET, amount);
        burnedAmount[msg.sender] += amount;
        totalBurned += amount;

        emit BabyDogeBurn(msg.sender, amount);
    }


    /*
     * @notice Sets new discounts values
     * @param _discounts Array of Discount structs, containing discount amount and burn amount to receive that discount
     */
    function setDiscounts(Discount[] calldata _discounts) external onlyOwner {
        _checkDiscounts(_discounts);
        delete discounts;
        for(uint i = 0; i < _discounts.length; i++) {
            discounts.push(_discounts[i]);
        }

        emit NewDiscounts(_discounts);
    }


    /*
     * @notice Updates BabyDogeToken tax
     */
    function updateBabyDogeTokenTax() external {
        require(msg.sender == tx.origin || msg.sender == owner());
        IBabyDogeToken babyDoge = IBabyDogeToken(address(bbdToken));
        uint256 _babyDogeTokenTax = babyDoge._taxFee() + babyDoge._liquidityFee();
        require(babyDogeTokenTax != _babyDogeTokenTax, "Already set");
        require(_babyDogeTokenTax < 100, "Invalid tax");

        babyDogeTokenTax = uint8(_babyDogeTokenTax);

        emit NewBabyDogeTokenTax(_babyDogeTokenTax);
    }


    /*
     * @notice Allows everyone to purchase without fees
     */
    function enableFreePurchaseForEveryone() external onlyOwner {
        require(freePurchaseForEveryone != true, "Already set");
        freePurchaseForEveryone = true;

        emit FreePurchaseForEveryoneEnabled();
    }


    /*
     * @notice Disable free BabyDoge purchase for everyone. Now individual fees will work
     */
    function disableFreePurchaseForEveryone() external onlyOwner {
        require(freePurchaseForEveryone != false, "Already set");
        freePurchaseForEveryone = false;

        emit FreePurchaseForEveryoneDisabled();
    }


    /*
     * @notice Approves token to be swapped to BBD
     * @param token ERC20 token address
     */
    function approveTokenIn(address token) external onlyOwner {
        require(!approvedTokens.contains(token), "Already approved");
        approvedTokens.add(token);

        emit TokenInApproved(token);
    }


    /*
     * @notice Remove token from the list of approved tokens In
     * @param token ERC20 token address
     */
    function removeTokenIn(address token) external onlyOwner {
        require(approvedTokens.contains(token), "Not approved");
        approvedTokens.remove(token);

        emit TokenInRemoved(token);
    }


    /*
     * @notice Withdraws ERC20 token.
     * @param token IERC20 token address
     * @param account Address of receiver
     * @param amount Amount of tokens to withdraw
     */
    function withdrawERC20(
        IERC20 token,
        address account,
        uint256 amount
    ) external onlyOwner {
        token.transfer(account, amount);

        emit TokensWithdrawal(address(token), account, amount);
    }


    /*
     * @notice Withdraws BNB.
     * @param account Address of receiver
     * @param amount Amount of BNB to withdraw
     */
    function withdrawBNB(
        address account,
        uint256 amount
    ) external onlyOwner {
        (bool success, ) = account.call{value: amount}("");
        require(success, "Failed to send BNB");

        emit BnbWithdrawal(account, amount);
    }


    /*
     * @notice View function go get discounts list
     * @return List or discounts
     */
    function getDiscounts() external view returns(Discount[] memory) {
        return discounts;
    }


    /*
     * @notice View function go get list or approved tokens
     * @return List or approved tokens
     */
    function getApprovedTokens() external view returns(address[] memory) {
        return approvedTokens.values();
    }


    /*
     * @notice View function go determine if token is approved to be swapped to BBD
     * @param token ERC20 token address
     * @return Is approved to be swapped to BBD?
     */
    function isApprovedTokenIn(address token) external view returns(bool) {
        return approvedTokens.contains(token);
    }


    /*
     * @notice View function go get personal discount
     * @return Discount in basis points where 10_000 is 100% discount = purchase without fee
     */
    function getPersonalDiscount(address account) public view returns(uint256) {
        if (freePurchaseForEveryone) {
            return 10_000;
        }
        uint256 numberOfDiscounts = discounts.length;

        int256 min = 0;
        int256 max = int256(numberOfDiscounts - 1);

        uint256 burnedTokens = burnedAmount[account];

        while (min <= max) {
            uint256 mid = uint256(max + min) / 2;

            if (
                burnedTokens == discounts[mid].burnAmount
                ||
                (burnedTokens > discounts[mid].burnAmount && (mid == numberOfDiscounts - 1))
                ||
                (burnedTokens > discounts[mid].burnAmount && (mid == 0 || burnedTokens < discounts[mid + 1].burnAmount))
            ) {
                return discounts[mid].discount;
            }

            if (discounts[mid].burnAmount > burnedTokens) {
                max = int256(mid) - 1;
            } else {
                min = int256(mid) + 1;
            }
        }

        return 0;
    }


    /*
     * @notice Swaps ERC20 for BabyDoge token
     * @param amountIn Amount tokens to spend
     * @param amountOutMin Minimum amount of BabyDoge tokens to receive
     * @param path Swap path
     * @param deadline Deadline of swap transaction
     * @return amountOut Amount of BabyDoge tokens user has received
     */
    function _buyBabyDogeWithERC20(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        uint256 deadline
    ) private returns(uint256 amountOut) {
        require(path[path.length - 1] == address(bbdToken), "Invalid path");
        if (IERC20(path[0]).allowance(address(this), address(router)) < amountIn) {
            IERC20(path[0]).approve(address(router), type(uint256).max);
        }

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountIn,
            0,
            path,
            address(this),
            deadline
        );

        amountOut = bbdToken.balanceOf(address(this));
        bbdToken.transfer(msg.sender, amountOut);

        require(amountOut > amountOutMin, "Below amountOutMin");

        emit BabyDogePurchase(msg.sender, amountOut, path[0]);
    }


    /*
     * @notice Checks discounts array for validity
     */
    function _checkDiscounts(Discount[] memory _discounts) private pure {
        require(_discounts.length > 0, "No discount data");
        Discount memory prevDiscount = _discounts[0];
        if (_discounts[0].discount == 0 || _discounts[0].burnAmount == 0) {
            revert InvalidDiscount(0);
        }
        for(uint i = 1; i < _discounts.length; i++) {
            if (
                _discounts[i].discount == 0
                || prevDiscount.discount >= _discounts[i].discount
                || prevDiscount.burnAmount >= _discounts[i].burnAmount
            ) {
                revert InvalidDiscount(i);
            }
        }
    }
}


interface IBabyDogeToken {
    function _taxFee() external returns(uint256);
    function _liquidityFee() external returns(uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBabyDogeFactory {
  function feeTo() external view returns (address);
  function feeToTreasury() external view returns (address);
  function feeToSetter() external view returns (address);

  function getPair(address tokenA, address tokenB)
    external
    view
    returns (address pair);

  function allPairs(uint256) external view returns (address pair);

  function allPairsLength() external view returns (uint256);

  function createPair(address tokenA, address tokenB)
    external
    returns (address pair);

  function setRouter(address) external;

  function setFeeTo(
    address _feeTo,
    address _feeToTreasury
  ) external;

  function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBabyDogePair {
  function totalSupply() external view returns (uint256);
  function balanceOf(address owner) external view returns (uint256);
  function allowance(address owner, address spender)
    external
    view
    returns (uint256);

  function approve(address spender, uint256 value) external returns (bool);

  function transfer(address to, uint256 value) external returns (bool);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool);

  function nonces(address owner) external view returns (uint256);

  function permit(
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;

  function factory() external view returns (address);
  function token0() external view returns (address);
  function token1() external view returns (address);

  function getReserves()
    external
    view
    returns (
      uint112 reserve0,
      uint112 reserve1,
      uint32 blockTimestampLast
    );

  function price0CumulativeLast() external view returns (uint256);
  function price1CumulativeLast() external view returns (uint256);
  function kLast() external view returns (uint256);
  function mint(address to) external returns (uint256 liquidity);
  function burn(address to) external returns (uint256 amount0, uint256 amount1);

  function swap(
    uint256 amount0Out,
    uint256 amount1Out,
    address to,
    bytes calldata data
  ) external;

  function skim(address to) external;

  function sync() external;

  function initialize(
    address,
    address,
    address
  ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBabyDogeRouter {
  function removeLiquidityETHSupportingFeeOnTransferTokens(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountETH);

  function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountETH);

  function swapExactTokensForTokensSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;

  function swapExactETHForTokensSupportingFeeOnTransferTokens(
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable;

  function swapExactTokensForETHSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;

  function transactionFee(address _tokenIn, address _tokenOut, address _msgSender)
    external
    view
    returns (uint256);
  function factory() external pure returns (address);

  function WETH() external pure returns (address);

  function addLiquidity(
    address tokenA,
    address tokenB,
    uint256 amountADesired,
    uint256 amountBDesired,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  )
  external
  returns (
    uint256 amountA,
    uint256 amountB,
    uint256 liquidity
  );

  function addLiquidityETH(
    address token,
    uint256 amountTokenDesired,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  )
  external
  payable
  returns (
    uint256 amountToken,
    uint256 amountETH,
    uint256 liquidity
  );

  function removeLiquidity(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountA, uint256 amountB);

  function removeLiquidityETH(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountToken, uint256 amountETH);

  function removeLiquidityWithPermit(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountA, uint256 amountB);

  function removeLiquidityETHWithPermit(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountToken, uint256 amountETH);

  function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapTokensForExactTokens(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapExactETHForTokens(
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable returns (uint256[] memory amounts);

  function swapTokensForExactETH(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapExactTokensForETH(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapETHForExactTokens(
    uint256 amountOut,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable returns (uint256[] memory amounts);

  function quote(
    uint256 amountA,
    uint256 reserveA,
    uint256 reserveB
  ) external pure returns (uint256 amountB);

  function getAmountsOut(uint256 amountIn, address[] calldata path)
  external
  view
  returns (uint256[] memory amounts);

  function getAmountsIn(uint256 amountOut, address[] calldata path)
  external
  view
  returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IWETH is IERC20 {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership} and {updateOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract SafeOwnable is Context {
    address private _owner;
    address private _newOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event OwnershipUpdated(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _owner = _msgSender();
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
        _owner = address(0);
    }

    /**
     * @dev Allows newOwner to claim ownership
     * @param newOwner Address that should become a new owner
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to msg.sender
     */
    function updateOwnership() external {
        _updateOwnership();
    }

    /**
     * @dev Allows newOwner to claim ownership
     * @param newOwner Address that should become a new owner
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _newOwner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to msg.sender
     * Internal function without access restriction.
     */
    function _updateOwnership() private {
        address oldOwner = _owner;
        address newOwner = _newOwner;
        require(msg.sender == newOwner, "Not a new owner");
        require(oldOwner != newOwner, "Already updated");
        _owner = newOwner;
        emit OwnershipUpdated(oldOwner, newOwner);
    }
}