/**
 *Submitted for verification at BscScan.com on 2022-12-22
*/

//SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
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

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract LatteSwap is Context, Ownable {
    event SwapEvent(
        uint256 amountIn,
        address receiver,
        address[] pairs,
        uint256 amountOut
    );
    event BuyEvent(
        address token,
        address receiver,
        uint256 bnbAmountIn,
        uint256 tokenAmountOut
    );
    event SellEvent(
        address token,
        address seller,
        uint256 amount,
        uint256 bnbAmountOut
    );

    struct Pair {
        address token1;
        address token2;
        uint256 rate;
    }

    mapping(bytes32 => Pair) pairRates;
    mapping(address => uint256) tokenRates;
    bytes32[] pairList;
    address[] tokenList;
    bool selling = false;

    constructor() {}

    modifier canSell() {
        require(selling, "you cannot sell your tokens at this time");
        _;
    }

    function swap(
        uint256 amount,
        address receiver,
        address[] calldata pairs
    ) external {
        require(amount > 0, "invalid amount");
        bytes32 hash = keccak256(abi.encodePacked(pairs[0], pairs[1]));
        require(pairRates[hash].rate > 0, "pair not found");
        uint256 tokenAmount = (pairRates[hash].rate * amount) / 10**18;
        require(
            IBEP20(pairs[1]).balanceOf(address(this)) >= tokenAmount,
            "vault: insufficient balance"
        );
        IBEP20(pairs[0]).transferFrom(msg.sender, address(this), amount);
        IBEP20(pairs[1]).transfer(receiver, tokenAmount);
        emit SwapEvent(amount, receiver, pairs, tokenAmount);
    }

    function buy(address token, address receiver) external payable {
        require(msg.value > 0, "insufficient balance");
        require(tokenRates[token] > 0, "rate not found");
        uint256 tokenAmount = (tokenRates[token] * msg.value) / 10**18;
        require(
            IBEP20(token).balanceOf(address(this)) >= tokenAmount,
            "vault: insufficient balance"
        );
        IBEP20(token).transfer(receiver, tokenAmount);
        emit BuyEvent(token, receiver, msg.value, tokenAmount);
    }

    function sell(
        uint256 amount,
        address receiver,
        address token
    ) external canSell {
        require(IBEP20(token).balanceOf(token) >= amount, "rate not found");
        require(tokenRates[token] > 0, "rate not found");
        uint256 bnbAmount = (amount * 10**18) / tokenRates[token];
        require(
            address(this).balance >= bnbAmount,
            "vault: insufficient balance"
        );
        IBEP20(token).transferFrom(msg.sender, address(this), amount);
        payable(receiver).transfer(bnbAmount);

        emit SellEvent(token, receiver, amount, bnbAmount);
    }

    function createPair(address[] calldata pairs, uint256 rate)
        external
        onlyOwner
    {
        bytes32 hash = keccak256(abi.encodePacked(pairs[0], pairs[1]));
        pairRates[hash].rate = rate;
        pairRates[hash].token1 = pairs[0];
        pairRates[hash].token2 = pairs[1];
        uint256 length = pairList.length;
        bool exist = false;
        for (uint256 i = 0; i < length; ) {
            if (pairList[i] == hash) {
                exist = true;
                break;
            }
            unchecked {
                i++;
            }
        }
        if (!exist) {
            pairList.push(hash);
        }
    }

    function setTokenRate(address token, uint256 rate) external onlyOwner {
        tokenRates[token] = rate;
        uint256 length = tokenList.length;
        bool exist = false;
        for (uint256 i = 0; i < length; ) {
            if (tokenList[i] == token) {
                exist = true;
                break;
            }
            unchecked {
                i++;
            }
        }
        if (!exist) {
            tokenList.push(token);
        }
    }

    function getPairList() external view returns (Pair[] memory) {
        Pair[] memory result = new Pair[](pairList.length);
        for (uint256 i = 0; i < pairList.length; ) {
            result[i] = pairRates[pairList[i]];
            unchecked {
                i++;
            }
        }
        return result;
    }

    function getTokenList() external view returns (Pair[] memory) {
        Pair[] memory result = new Pair[](tokenList.length);
        for (uint256 i = 0; i < tokenList.length; ) {
            result[i] = Pair(
                tokenList[i],
                address(0),
                tokenRates[tokenList[i]]
            );
            unchecked {
                i++;
            }
        }
        return result;
    }

    function getPairRate(address[] calldata pairs)
        external
        view
        returns (uint256)
    {
        bytes32 hash = keccak256(abi.encodePacked(pairs[0], pairs[1]));
        return pairRates[hash].rate;
    }

    function getTokenRate(address token) external view returns (uint256) {
        return tokenRates[token];
    }

    function withdrawToken(address token, uint256 amount) external onlyOwner {
        IBEP20(token).transfer(msg.sender, amount);
    }

    function depositToken(address token, uint256 amount) external onlyOwner {
        IBEP20(token).transferFrom(msg.sender, address(this), amount);
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    function flipSelling() external onlyOwner {
        selling = !selling;
    }
}