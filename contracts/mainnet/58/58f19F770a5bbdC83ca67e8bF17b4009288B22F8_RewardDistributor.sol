/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

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

interface IReward {
    function depositRewards(uint256 amount) external;
}

contract RewardDistributor is Ownable {

    // PUSD Reward Token
    IERC20 public constant PUSD = IERC20(0x9fE2C7040c4b3a8F08d6a8f271a6d15bDADD52B9);

    // NFTs
    address public common;
    address public uncommon;
    address public wanderer;
    address public rare;
    address public legendary;

    // Cuts
    uint256 public commonCut;
    uint256 public uncommonCut;
    uint256 public wandererCut;
    uint256 public rareCut;
    uint256 public legendaryCut;

    constructor(
        address common_,
        address uncommon_,
        address wanderer_,
        address rare_,
        address legendary_,
        uint commonCut_,
        uint uncommonCut_,
        uint wandererCut_,
        uint rareCut_,
        uint legendaryCut_
    ) {
        require(
            common_ != address(0) &&
            uncommon_ != address(0) &&
            wanderer_ != address(0) &&
            rare_ != address(0) &&
            legendary_ != address(0),
            'Zero Addresses'
        );
        common = common_;
        uncommon = uncommon_;
        wanderer = wanderer_;
        rare = rare_;
        legendary = legendary_;

        commonCut = commonCut_;
        uncommonCut = uncommonCut_;
        wandererCut = wandererCut_;
        rareCut = rareCut_;
        legendaryCut = legendaryCut_;
    }

    function setPercentages(
        uint comm,
        uint uncomm,
        uint wander,
        uint rare_,
        uint legendary_
    ) external onlyOwner {

        commonCut = comm;
        uncommonCut = uncomm;
        wandererCut = wander;
        rareCut = rare_;
        legendaryCut = legendary_;
    }

    receive() external payable {
        (bool s,) = payable(address(PUSD)).call{value: address(this).balance}("");
        require(s, 'Failure On PUSD Purchase');
        _distribute();
    }

    function buyAndDistribute() external payable {
        (bool s,) = payable(address(PUSD)).call{value: address(this).balance}("");
        require(s, 'Failure On PUSD Purchase');
        _distribute();
    }

    function distribute() external {
        _distribute();
    }

    function _distribute() internal {

        (
            uint256 amt0,
            uint256 amt1,
            uint256 amt2,
            uint256 amt3,
            uint256 amt4
        ) = getAmounts();

        _send(common, amt0);
        _send(uncommon, amt1);
        _send(wanderer, amt2);
        _send(rare, amt3);
        _send(legendary, amt4);
    }

    function _send(address to, uint256 amount) internal {
        if (to == address(0) || amount == 0) {
            return;
        }
        PUSD.approve(to, amount);
        IReward(to).depositRewards(amount);
    }

    function getAmounts() public view returns (uint256 comm, uint256 uncomm, uint256 wander, uint256 rare_, uint256 legendary_) {

        uint balance = balanceOf();
        uint denom = getDenom();

        comm = ( balance * commonCut ) / denom;
        uncomm = ( balance * uncommonCut ) / denom;
        wander = ( balance * wandererCut ) / denom;
        rare_ = ( balance * rareCut ) / denom;
        legendary_ = balance - ( comm + uncomm + wander + rare_ );
    }

    function balanceOf() public view returns (uint256) {
        return PUSD.balanceOf(address(this));
    }

    function getDenom() public view returns (uint256) {
        return commonCut + uncommonCut + wandererCut + rareCut + legendaryCut;
    }
}