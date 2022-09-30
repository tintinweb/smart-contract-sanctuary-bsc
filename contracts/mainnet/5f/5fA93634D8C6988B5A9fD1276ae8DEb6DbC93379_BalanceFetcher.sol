//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";
import "./Ownable.sol";

interface IListingManager {
    function fetchAllAvailableTokens() external view returns (address[] memory);
}

interface IOTC {
    function ListingManager() external view returns (address);
}

interface ILottoManager {
    function currentLotto() external view returns (address);
}

interface IOracle {
    function priceOf(address token) external view returns (uint256);
    function priceOfBNB() external view returns (uint256);
}

contract BalanceFetcher is Ownable {

    address public otc;
    address public oracle;
    address public lottoManager;

    constructor(address otc_, address oracle_, address lottoManager_) {
        otc = otc_;
        oracle = oracle_;
        lottoManager = lottoManager_;
    }

    function setOTC(address otc_) external onlyOwner {
        otc = otc_;
    }

    function setOracle(address oracle_) external onlyOwner {
        oracle = oracle_;
    }

    function setLottoManager(address lottoManager_) external onlyOwner {
        lottoManager = lottoManager_;
    }

    function priceOf(address token) public view returns (uint256) {
        return IOracle(oracle).priceOf(token);
    }

    function priceOfBNB() public view returns (uint256) {
        return IOracle(oracle).priceOfBNB();
    }

    function pricesOf(address[] calldata tokens) external view returns (uint256[] memory) {
        uint len = tokens.length;
        uint256[] memory prices = new uint256[](len);
        for (uint i = 0; i < len;) {
            prices[i] = IOracle(oracle).priceOf(tokens[i]);
            unchecked { ++i; }
        }
        return prices;
    }

    function valueOfDestination(address token, address destination) public view returns (uint256) {
        return valueOfAmount(token, IERC20(token).balanceOf(destination));
    }

    function valueOfETHDestination(address destination) public view returns (uint256) {
        return ( priceOfBNB() * address(destination).balance ) / 10**18;
    }

    function valueOfETHInLotto() public view returns (uint256) {
        return valueOfETHDestination(currentLotto());
    }

    function valueOfAmount(address token, uint256 amount) public view returns (uint256) {
        return ( amount * priceOf(token) ) / 10**IERC20(token).decimals();
    }

    function combinedValueOf(address[] calldata tokens, address destination) public view returns (uint256 total) {
        uint len = tokens.length;
        for (uint i = 0; i < len;) {
            total += valueOfDestination(tokens[i], destination);
            unchecked { ++i; }
        }
    }

    function combinedValueOfLotto(address[] calldata tokens) external view returns (uint256 total) {
        return combinedValueOf(tokens, currentLotto());
    }

    function valueOfLotto() external view returns (uint256 total) {
        address[] memory tokens = allAvailableTokens();
        uint len = tokens.length;
        total = valueOfETHInLotto();
        for (uint i = 0; i < len;) {
            total += valueOfDestination(tokens[i], currentLotto());
            unchecked { ++i; }
        }
    }

    function getBalances() external view returns (uint256[] memory) {
        return _getBalancesForListAtDestination(currentLotto(), allAvailableTokens());
    }

    function getBalancesAndTokenList() external view returns (address[] memory, uint256[] memory) {
        address[] memory list = allAvailableTokens();
        return (list, _getBalancesForListAtDestination(currentLotto(), list));
    }

    function getBalancesForList(address[] calldata tokens) public view returns (uint256[] memory) {
        return getBalancesForListAtDestination(currentLotto(), tokens);
    }

    function currentLotto() public view returns (address) {
        return ILottoManager(lottoManager).currentLotto();
    }

    function allAvailableTokens() public view returns (address[] memory) {
        return IListingManager(IOTC(otc).ListingManager()).fetchAllAvailableTokens();
    }

    function getBalancesForListAtDestination(address destination, address[] calldata tokens) public view returns (uint256[] memory) {

        uint len = tokens.length + 1;
        uint256[] memory balances = new uint256[](len);
        balances[0] = address(destination).balance;
        for (uint i = 0; i < len-1;) {
            balances[i+1] = IERC20(tokens[i]).balanceOf(address(destination));
            unchecked { ++i; }
        }
        return balances;
    }

    function _getBalancesForListAtDestination(address destination, address[] memory tokens) internal view returns (uint256[] memory) {
        uint len = tokens.length + 1;
        uint256[] memory balances = new uint256[](len);
        balances[0] = address(destination).balance;
        for (uint i = 0; i < len-1;) {
            balances[i+1] = IERC20(tokens[i]).balanceOf(address(destination));
            unchecked { ++i; }
        }
        return balances;
    }

}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.14;

/**
 * @title Owner
 * @dev Set & change owner
 */
contract Ownable {

    address private owner;
    
    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    // modifier to check if caller is owner
    modifier onlyOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    /**
     * @dev Set contract deployer as owner
     */
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }

    /**
     * @dev Change owner
     * @param newOwner address of new owner
     */
    function changeOwner(address newOwner) public onlyOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Return owner address 
     * @return address of owner
     */
    function getOwner() external view returns (address) {
        return owner;
    }
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    
    function symbol() external view returns(string memory);
    
    function name() external view returns(string memory);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
    
    /**
     * @dev Returns the number of decimal places
     */
    function decimals() external view returns (uint8);

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