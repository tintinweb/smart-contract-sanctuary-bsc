/**
 *Submitted for verification at BscScan.com on 2022-10-10
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-03
*/

// SPDX-License-Identifier: MIT
// WARNING this contract has not been independently tested or audited
// DO NOT use this contract with funds of real value until officially tested and audited by an independent expert or group

pragma solidity 0.8.11;

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
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IUniswapV2Pair {
    function token0() external pure returns (address);

    function token1() external pure returns (address);
}
interface IDEXRouter {
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

}
interface IBond {
    function deposit(uint256 depositAmmount) external;
}
library SafeMath {
    
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
contract Bond is IBond{
    using EnumerableSet for EnumerableSet.UintSet;
    using SafeMath for uint256;
    mapping (address => EnumerableSet.UintSet) private bondHolders;
    mapping (uint256 => BondData) public bondData;
    BondMetadata[] public bondList ;
    mapping (address => bool) public depositors;
    uint256 private currentBondId = 1;
    struct BondData {
        uint256 amount;
        uint256 bondMetadataId;
        uint256 releaseTimeStamp;
    }
    struct BondMetadata
    {
        string name;
        uint256 weight;
        address lpToken;
        uint256 sigBalance;
        uint256 sigBalanceUpperCap;
        uint256 sigBalanceLowerCap;
        uint256 premiumPercentage;
        uint256 lockingPeriod;
        bool isActive;
    }
    // boolean to prevent reentrancy
    bool internal locked;

    // Library usage
    IDEXRouter router;
    // Contract owner
    address payable public owner;
    address public vault;

    // Contract owner access
    bool public allIncomingDepositsFinalised;

    uint256 public totalWeight = 0;
    uint256 profitDenominator = 10000;

    //this is what the pairing of our token is
    IBEP20 public stableToken;
    address public stableTokenAddress;

    //LP or the token
    IBEP20 public bep20Token;
    address public bep20TokenAddress;

    // Events
    event TokensDeposited(address from, uint256 amount);
    event AllocationPerformed(address recipient, uint256 amount);
    event TokensUnlocked(address recipient, uint256 amount);

    constructor(address _router, address _stableTokenAddress, address _bep20TokenAddress, address _vault) {
        router = IDEXRouter(_router);
        owner = payable(msg.sender);
        stableToken = IBEP20(_stableTokenAddress);
        stableTokenAddress = _stableTokenAddress;
        bep20Token = IBEP20(_bep20TokenAddress);
        bep20TokenAddress = _bep20TokenAddress;
        bep20Token.approve(address(this),bep20Token.totalSupply());
        locked = false;
        vault = _vault;

    }

    // Modifier
    /**
     * @dev Prevents reentrancy
     */
    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    // Modifier
    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Message sender must be the contract's owner.");
        _;
    }

    modifier onlyDepositor() {
        require(depositors[msg.sender] == true || msg.sender == bep20TokenAddress , "Depositor must be authorized or the token itself.");
        _;
    }

    function bondListLength() external view returns (uint256) {
        return bondList.length;
    }
     function addBond(address newVault) public onlyOwner
     {
         vault = newVault;
     }
    function addBond( string memory _name, 
        uint256 _weight, 
        address _lpToken,
        uint256 _premiumPercentage,
        uint256 _lockingPeriod,
        uint256 _sigBalanceUpperCap,
        uint256 _sigBalanceLowerCap) public onlyOwner{
        bondList.push(
            BondMetadata({
                name: _name,
                weight: _weight,
                lpToken: _lpToken,
                sigBalance: 0,
                premiumPercentage: _premiumPercentage,
                lockingPeriod: _lockingPeriod,
                isActive: false,
                sigBalanceUpperCap: _sigBalanceUpperCap,
                sigBalanceLowerCap: _sigBalanceLowerCap
            }));
        totalWeight = totalWeight +  _weight;   
    }
    
    function updateBond(uint256 id, string memory _name, uint256 _weight, uint256 _premiumPercentage ,uint256 _lockingPeriod) public onlyOwner{
        bondList[id].name = _name;
        totalWeight = totalWeight - bondList[id].weight + _weight;   
        bondList[id].weight = _weight;
        bondList[id].premiumPercentage = _premiumPercentage;
        bondList[id].lockingPeriod = _lockingPeriod;
    }

    function configureDepositor(address _depositor, bool enabled) public onlyOwner{
        depositors[_depositor] = enabled;
    }

    function deposit(uint256 depositAmmount) external onlyDepositor{

        bep20Token.transferFrom(msg.sender, address(this), depositAmmount);
        uint256 length = bondList.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            bondList[pid].sigBalance = bondList[pid].sigBalance + depositAmmount.mul(bondList[pid].weight).div(totalWeight);
            if(bondList[pid].sigBalance >= bondList[pid].sigBalanceUpperCap)
            {
                bondList[pid].isActive = true;
            }
        }
        
        emit TokensDeposited(msg.sender, depositAmmount);
    }

    function buyBond(uint256 lpAmount, uint256 bondId) public {
        require( bondList[bondId].isActive && bondList[bondId].sigBalance > bondList[bondId].sigBalanceLowerCap, "Bond have not yet activated");

        uint256 sigAmount = LpToSig(bondList[bondId].lpToken, lpAmount).mul(bondList[bondId].premiumPercentage).div(profitDenominator);

        if(sigAmount > bondList[bondId].sigBalance || bondList[bondId].sigBalance - sigAmount <= bondList[bondId].sigBalanceLowerCap)
        {
            sigAmount = bondList[bondId].sigBalance - bondList[bondId].sigBalanceLowerCap;
            lpAmount = SIGtoLP(bondList[bondId].lpToken,sigAmount).mul(profitDenominator).div(bondList[bondId].premiumPercentage);
        }

        
        bondData[currentBondId].amount = sigAmount;

        //IBEP20(bondList[bondId].lpToken).transferFrom(msg.sender, address(this), lpAmount);
        IBEP20(bondList[bondId].lpToken).transferFrom(msg.sender, vault, lpAmount);

        bondHolders[msg.sender].add(currentBondId);

        bondData[currentBondId].releaseTimeStamp = block.timestamp + bondList[bondId].lockingPeriod;
        bondData[currentBondId].bondMetadataId = bondId;

        currentBondId = currentBondId +1;
        bondList[bondId].sigBalance = bondList[bondId].sigBalance - sigAmount;

        if(bondList[bondId].sigBalance <= bondList[bondId].sigBalanceLowerCap)
        {
            bondList[bondId].isActive = false;
        }
    }
    function LpToToken(address _pair, uint256 lpAmount) public view returns (uint256) {
        address otherBep20Token = IUniswapV2Pair(_pair).token0();
        if(address(otherBep20Token) == address(bep20TokenAddress))
        {
            otherBep20Token = IUniswapV2Pair(_pair).token1();
        }
        uint256 balanceOfotherBep20Token = IBEP20(otherBep20Token).balanceOf(_pair);
        uint256 totalLpTokenSupply = IBEP20(_pair).totalSupply();
        return balanceOfotherBep20Token.mul(2).mul(lpAmount).div(totalLpTokenSupply);
    }

    function TokenToLP(address _pair, uint256 tokenAmount) public view returns (uint256) {
        address token0 = IUniswapV2Pair(_pair).token0();
        if(address(token0) == address(bep20TokenAddress))
        {
            token0 = IUniswapV2Pair(_pair).token1();
        }
        uint256 totalLPToken = IBEP20(_pair).totalSupply();
        uint256 balanceOf1 = IBEP20(token0).balanceOf(_pair);
        return tokenAmount.mul(totalLPToken).div(2).div(balanceOf1);
    }

    //Dont use profit here yet
    function LpToSig(address _pair, uint256 lpAmount) public view returns (uint256) {
        address otherBep20Token = IUniswapV2Pair(_pair).token0();
        uint256 lpAmountToTokenAmount = LpToToken(_pair,lpAmount);
        if(address(otherBep20Token) == address(bep20TokenAddress))
        {
            otherBep20Token = IUniswapV2Pair(_pair).token1();
        }
        address[] memory path = new address[](2);

        path[0] = bep20TokenAddress;
        path[1] = otherBep20Token;
        return IDEXRouter(router).getAmountsIn(lpAmountToTokenAmount, path)[0];
    }

    function maxCanTrade(uint256 bondId) public view returns (uint256 k_)
    {
        if(bondList[bondId].sigBalance <= bondList[bondId].sigBalanceLowerCap) 
        {
            return 0;
        }

        uint256 sigBalanceLeft = bondList[bondId].sigBalance - bondList[bondId].sigBalanceLowerCap;
        return SIGtoLP(bondList[bondId].lpToken, sigBalanceLeft).mul(profitDenominator).div(bondList[bondId].premiumPercentage);        
    }

    //Dont use profit here yet
    function SIGtoLP(address _pair, uint256 sigAmount) public view returns (uint256 k_) {
        address token0 = IUniswapV2Pair(_pair).token0();
        if(address(token0) == address(bep20TokenAddress))
        {
            token0 = IUniswapV2Pair(_pair).token1();
        }
        address[] memory path = new address[](2);

        path[0] = bep20TokenAddress;
        path[1] = token0;
        uint256 totalTokenWorth = IDEXRouter(router).getAmountsOut(sigAmount, path)[1];
        return TokenToLP(_pair, totalTokenWorth);
    }

    function CountBond(address bonder)  public view returns (uint256){
        return bondHolders[bonder].length();
    }

    function GetBondInfo(uint256 index)  public view returns (uint256){
        return bondHolders[msg.sender].at(index);
    }

    function claim(uint256 index) public noReentrant {

        if( bondData[bondHolders[msg.sender].at(index)].releaseTimeStamp < block.timestamp)
        {
            bep20Token.transfer(msg.sender,bondData[bondHolders[msg.sender].at(index)].amount);
            bondHolders[msg.sender].remove(bondHolders[msg.sender].at(index));
        }

    }

    function transferAccidentallyLockedTokens(IBEP20 token, uint256 amount) public onlyOwner noReentrant {
        require(address(token) != address(0), "Token address can not be zero");
        token.transfer(owner, amount);
    }

    function withdrawEth(uint256 amount) public onlyOwner noReentrant{
        require(amount <= address(this).balance, "Insufficient funds");
        owner.transfer(amount);
    }
}