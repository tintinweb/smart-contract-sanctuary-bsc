/**
 *Submitted for verification at BscScan.com on 2022-08-28
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface IBEP20 {
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
    function allowance(address owner, address spender)
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

interface IOwnable {
    function owner() external view returns (address);

    function renounceOwnership() external;

    function transferOwnership(address newOwner_) external;
}

contract Ownable is IOwnable {
    address internal _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view override returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    modifier onlyOwnerOrigin() {
        require(_owner == tx.origin, "Ownable: tx.origin is not the owner");
        _;
    }

    function renounceOwnership() public virtual override onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner_)
        public
        virtual
        override
        onlyOwner
    {
        require(
            newOwner_ != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner_);
        _owner = newOwner_;
    }
}

interface IPriceCalculator {
    function getUSDValue(address token_, uint256 amount_) external view returns (uint256);
}

interface IGame {
    function totalGlobalWinsUSDLocal(bool human_) external view returns (uint256);
    function totalHouseRiskableUSDLocal(bool human_) external view returns (uint256);
}

contract House is Ownable {
    address[] public games;
    address[] public tokens;
    address public priceCalc;

    modifier onlyGame() {
        bool isGame = false;
        for (uint256 i = 0; i < games.length; i++) {
            if (msg.sender == games[i]) {
                isGame = true;
                break;
            }
        }
        require(isGame, "House: Caller is not a game");
        _;
    }

    constructor(address priceCalc_) {
        priceCalc = priceCalc_;
    }

    function payout(
        address recipient_,
        uint256 amount_,
        address token_
    ) external onlyGame {
        IBEP20(token_).transfer(recipient_, amount_);
    }

    function addGame(address newGame_) external onlyOwnerOrigin {
        bool alreadyGame = false;

        for (uint256 i = 0; i < games.length; i++) {
            if (games[i] == newGame_) {
                alreadyGame = true;
                break;
            }
        }

        if (!alreadyGame) {
            games.push(newGame_);
        }
    }

    function allowToken(address token_) external onlyGame {
        bool alreadyAdded = false;
        for (uint i = 0; i < tokens.length; i++) {
            if (tokens[i] == token_) {
                alreadyAdded = true;
                break;
            }
        }

        if (!alreadyAdded) {
            tokens.push(token_);
        }
    }

    function totalHouseReservesUSD(bool human_) external view returns (uint256) {
        uint256 total = 0;
        for (uint i = 0; i < tokens.length; i++) {
            total += IPriceCalculator(priceCalc).getUSDValue(tokens[i],IBEP20(tokens[i]).balanceOf(address(this)));
        }
        if (human_) {
            return total / 1e18;
        }
        return total;
    }

    function totalHouseRiskableUSD(bool human_) external view returns (uint256) {
        uint256 total = 0;
        for (uint i = 0; i < games.length; i++) {
            total += IGame(games[i]).totalHouseRiskableUSDLocal(false);
        }
        if (human_) {
            return total / 1e18;
        }
        return total;
    }

    function totalGlobalWinsUSD(bool human_) external view returns (uint256) {
        uint256 total = 0;
        for (uint i = 0; i < games.length; i++) {
            total += IGame(games[i]).totalGlobalWinsUSDLocal(false);
        }
        if (human_) {
            return total / 1e18;
        }
        return total;
    }

    // Only callable by the owner. Changes the PriceCalculator contract address.
    function setPriceCalcAddress(address newPriceCalcAddress_) external onlyOwner {
        require(
            newPriceCalcAddress_ != address(0),
            "Roulette::setPriceCalcAddress: Random number generator address cannot be the zero address"
        );

        priceCalc = newPriceCalcAddress_;
    }
}