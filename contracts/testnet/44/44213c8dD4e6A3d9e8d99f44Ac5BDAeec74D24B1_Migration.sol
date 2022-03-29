//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

contract Migration is Auth  {
    IERC20 public rsun;
    IERC20 public inf;
    IERC20 public apeLP;
    IERC20 public wbnb;

    bool public unpairLPEnabled = false;
    uint public lpTotal;
    uint public lpRSUNTotal;
    uint public lpBNBTotal;

    uint public rsunDepositedTotal = 0;
    uint public infDepositedTotal = 0;
    uint public lpDepositedTotal = 0;

    mapping(address => uint) public rsunBalances;
    mapping(address => uint) public infBalances;

    event DepositedRSUN(address indexed user, uint amount);
    event DepositedINF(address indexed user, uint amount);
    event DepositedApeLP(address indexed user, uint amount);
    event SnapshottedLP(uint total, uint rsun, uint bnb);
    event Received(address, uint);

    constructor(address _rsun, address _inf, address _apeLP, address _wbnb) Auth(msg.sender) {
        rsun = IERC20(_rsun);
        inf = IERC20(_inf);
        apeLP = IERC20(_apeLP);
        wbnb = IERC20(_wbnb);

        // snapshot LP balances
        lpTotal = apeLP.totalSupply();
        lpRSUNTotal = rsun.balanceOf(_apeLP);
        lpBNBTotal = wbnb.balanceOf(_apeLP);
        emit SnapshottedLP(lpTotal, lpRSUNTotal, lpBNBTotal);
    }

    function depositRSUN(uint amount) external {
        require(rsun.balanceOf(msg.sender) >= amount, "You do not own enough rsun");

        rsunBalances[msg.sender] += amount;
        rsunDepositedTotal += amount;

        // INTERACTIONS
        require(rsun.transferFrom(msg.sender, address(this), amount), "We didn't receive the rsun");

        emit DepositedRSUN(msg.sender, amount);
    }

    function depositINF(uint amount) external {
        require(inf.balanceOf(msg.sender) >= amount, "You do not own enough inf");

        infBalances[msg.sender] += amount;
        infDepositedTotal += amount;

        // INTERACTIONS
        require(inf.transferFrom(msg.sender, address(this), amount), "We didn't receive the inf");

        emit DepositedINF(msg.sender, amount);
    }

    /**
     * The share calculation should stay accurate even while LP is paired and unpaired.
     */
    function unpairApeLP(uint lpAmount) external {
        require(unpairLPEnabled, "unpairApeLP not enabled");
        require(apeLP.balanceOf(msg.sender) >= lpAmount, "You do not own enough lp");

        lpDepositedTotal += lpAmount;
        (uint rsunAmount, uint bnbAmount) = unpairApeLPExpected(lpAmount);

        // INTERACTIONS
        require(apeLP.transferFrom(msg.sender, address(this), lpAmount), "We didn't receive the apeLP");
        require(rsun.transfer(msg.sender, rsunAmount), "Failed to send RSUN");
        (bool success,) = payable(msg.sender).call{ value: bnbAmount }("");
        require(success, "Failed to send BNB");
    }

    /**
     * Returns expected unpaired RSUN, BNB amount for given ApeLp amount.
     */
    function unpairApeLPExpected(uint lpAmount) public view returns (uint, uint) {
        // calculate share first to prevent overflow
        uint share = 10000 * lpAmount / lpTotal;
        uint rsunAmount = lpRSUNTotal * share / 10000;
        uint bnbAmount = lpBNBTotal * share / 10000;

        return (rsunAmount, bnbAmount);
    }

    function enableUnpairLP(bool enabled) external authorized {
        unpairLPEnabled = enabled;
    }

    function setLPValues(uint _lpTotal, uint _lpRSUNTotal, uint _lpBNBTotal) external authorized {
        lpTotal = _lpTotal;
        lpRSUNTotal = _lpRSUNTotal;
        lpBNBTotal = _lpBNBTotal;

        emit SnapshottedLP(lpTotal, lpRSUNTotal, lpBNBTotal);
    }

    function snapshotLPValues() external authorized {
        // snapshot LP balances
        lpTotal = apeLP.totalSupply();
        lpRSUNTotal = rsun.balanceOf(address(apeLP));
        lpBNBTotal = wbnb.balanceOf(address(apeLP));

        emit SnapshottedLP(lpTotal, lpRSUNTotal, lpBNBTotal);
    }

    /**
     * Retrieve tokens.
     */
    function retrieveTokens(address _token, uint amount) external authorized {
        require(IERC20(_token).transfer(msg.sender, amount), "Transfer failed");
    }

    /**
     * Retrieve stuck BNB. 
     */
    function retrieveBNB(uint amount) external authorized {
        (bool success,) = payable(msg.sender).call{ value: amount }("");
        require(success, "Failed to retrieve BNB");
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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