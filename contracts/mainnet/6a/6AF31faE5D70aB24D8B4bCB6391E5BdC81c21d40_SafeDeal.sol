// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

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

struct Deal {
    address payable seller;
    address payable buyer;
    address payable referer;
    uint price;
    uint service_fee;
    uint referer_fee;
}

// final version works with BUSD token
contract SafeDeal {
    IERC20 private _token;
    address private _owner;
    address[] private _moderators;
    mapping(uint => Deal) private _deals; // active deals
    uint[] private _ids; // will help to organize mapping loop

    modifier onlyOwner() {
        require(msg.sender == _owner, "this function can be called by owner only");
        _;
    }

    modifier onlyModerator() {
        bool exists = false;

        for (uint i = 0; i < _moderators.length; i++) {
            if (msg.sender == _moderators[i]) {
                exists = true;
                break;
            }
        }

        require(exists, "this function can be called by moderator only");
        _;
    }

    event Started(uint id, Deal deal);
    event Completed(uint id, Deal deal);
    event Cancelled(uint id, Deal deal);
    event ModeratorAdded(address[] moderators);
    event ModeratorRemoved(address[] moderators);
    event Balance(uint value);
    event BalanceAfterWithdraw(uint value);

    constructor() {
        _token = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); // token contract addr: 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56
        _owner = msg.sender;
    }

    function start(uint id, address payable seller, address payable buyer, address payable referer, uint price, uint service_fee, uint referer_fee) public payable {
        require(msg.sender == buyer, "this function can be called by buyer only");
        Deal memory deal = Deal({
            seller: seller,
            buyer: buyer,
            referer: referer,
            price: price,
            service_fee: service_fee,
            referer_fee: referer_fee
        });
        _deals[id] = deal;
        _ids.push(id);
        bool sent = _token.transferFrom(buyer, address(this), price + service_fee + referer_fee); // approve is not needed, it was done by external transaction
        require(sent, "payment to contract failed");
        emit Started(id, deal);
    }

    function completeByBuyer(uint id) public payable {
        Deal memory deal = _deals[id];
        require(deal.buyer == msg.sender, "this function can be called by buyer only");
        // payment to seller
        bool approved = _token.approve(address(this), deal.price);
        require(approved, "approve failed");
        bool sent = _token.transferFrom(address(this), deal.seller, deal.price);
        require(sent, "payment to seller failed");

        // payment to referer
        if (deal.referer_fee > 0) {
            approved = _token.approve(address(this), deal.referer_fee);
            require(approved, "approve failed");
            sent = _token.transferFrom(address(this), deal.referer, deal.referer_fee);
            require(sent, "payment to referer failed");
        }

        // remove deal after completing
        deleteDeal(id);
        emit Completed(id, deal);
    }

    function completeByModerator(uint id) public onlyModerator payable {
        Deal memory deal = _deals[id];
        // payment to seller
        bool approved = _token.approve(address(this), deal.price);
        require(approved, "approve failed");
        bool sent = _token.transferFrom(address(this), deal.seller, deal.price);
        require(sent, "payment to seller failed");

        // payment to referer
        if (deal.referer_fee > 0) {
            approved = _token.approve(address(this), deal.referer_fee);
            require(approved, "approve failed");
            sent = _token.transferFrom(address(this), deal.referer, deal.referer_fee);
            require(sent, "payment to referer failed");
        }

        // remove deal after completing
        deleteDeal(id);
        emit Completed(id, deal);
    }

    function cancelByModerator(uint id) public onlyModerator payable {
        Deal memory deal = _deals[id];
        bool approved = _token.approve(address(this), deal.price + deal.service_fee + deal.referer_fee);
        require(approved, "approve failed");
        bool sent = _token.transferFrom(address(this), deal.buyer, deal.price + deal.service_fee + deal.referer_fee);
        require(sent, "payment to buyer failed");
        deleteDeal(id); // remove deal after completing
        emit Cancelled(id, deal);
    }

    function addModerator(address moderator) onlyOwner public {
        bool exists = false;

        for (uint i = 0; i < _moderators.length; i++) {
            if (moderator == _moderators[i]) {
                exists = true;
                break;
            }
        }

        require(!exists, "moderator already exists");
        _moderators.push(moderator);
        emit ModeratorAdded(_moderators);
    }

    function removeModerator(address moderator) onlyOwner public {
        uint index;
        bool exists = false;

        for (uint i = 0; i < _moderators.length; i++) {
            if (moderator == _moderators[i]) {
                index = i;
                exists = true;
                break;
            }
        }

        require(exists, "moderator not found");
        _moderators[index] = _moderators[_moderators.length - 1];
        _moderators.pop();
        emit ModeratorRemoved(_moderators);
    }

    function getBalance() onlyOwner public returns(uint) {
        uint reserved = 0;

        for (uint i = 0; i < _ids.length; i++) {
            reserved += (_deals[_ids[i]].price + _deals[_ids[i]].service_fee + _deals[_ids[i]].referer_fee);
        }

        uint balance = _token.balanceOf(address(this)) - reserved;
        emit Balance(balance);
        return balance;
    }

    function withdraw(address payable wallet, uint value) onlyOwner public payable {
        uint balance = getBalance();
        require(balance >= value, "insufficient tokens");
        bool approved = _token.approve(address(this), value);
        require(approved, "approve failed");
        bool sent = _token.transferFrom(address(this), wallet, value);
        require(sent, "payment failed");
        emit BalanceAfterWithdraw(balance - value);
    }

    // utils

    function deleteDeal(uint id) private {
        // delete deal
        delete _deals[id];

        // delete deal id
        uint index;
        bool exists = false;

        for (uint i = 0; i < _ids.length; i++) {
            if (id == _ids[i]) {
                index = i;
                exists = true;
                break;
            }
        }

        require(exists, "cant delete deal id, not found");
        _ids[index] = _ids[_ids.length - 1];
        _ids.pop();
    }
}